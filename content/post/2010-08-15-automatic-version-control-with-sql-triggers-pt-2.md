---
title: Automatic Version Control with SQL Triggers pt. 2
author: Marcus
layout: post
date: 2010-08-14T22:00:50+00:00
url: /2010/08/15/automatic-version-control-with-sql-triggers-pt-2/
categories:
  - Uncategorized
tags:
  - programming
  - Python
  - sql
  - sqlite
  - version control

---
In the first part of this mini series, we saw a database schema for storing all versions of all objects in an ORM database, using SQL triggers as the main mechanism. In this part, we will dig deep into the implementation. We will use [SQL Alchemy][1], SQLite3, and a couple of standard libraries:

```python
import os
import datetime
import sqlite3
import sqlalchemy
from sqlalchemy import (Table, Column, Integer, String, DateTime,
                        MetaData, ForeignKey, DDL)
			from sqlalchemy.ext.declarative import declarative_base
```

To start off, we define the support tables that do not depend on specific object types. Only `VcCommits` entries are constructed directly.

```python
Base = declarative_base()

class VcCommits(Base):
    __tablename__ = 'VcCommits'
    id = Column(Integer, primary_key=True)
    parent = Column(Integer)
    description = Column(String, nullable=False)
    timestamp = Column(DateTime)
    def __init__(self, description, parent):
        self.description = description
        self.parent = parent

class VcTables(Base):
    __tablename__ = 'VcTables'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    revisions = Column(String, nullable=False)

class VcRevisions(Base):
    __tablename__ = 'VcRevisions'
    id = Column(Integer, primary_key=True)
    cid = Column(Integer, ForeignKey("VcCommits.id", ondelete="cascade"))
    action = Column(Integer)
    tid = Column(Integer, ForeignKey("VcTables.id", ondelete="cascade"))

class VcBranches(Base):
    __tablename__ = 'VcBranches'
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True, nullable=False)
    cid = Column(Integer)
```


We use SQL DDL hooks to dynamically create a `HEAD` branch if none exists already. This makes writing the trigger sequences simpler, as they can assume that such a branch exists already.

```python
ins_ref = DDL("INSERT INTO VcBranches SELECT NULL, 'HEAD', 0 WHERE "
              "NOT EXISTS (SELECT 1 FROM VcBranches WHERE name = 'HEAD')")
ins_ref.execute_at('after-create', VcBranches.__table__)
```

We also use SQL DDL hooks to create object-specific `Vc_` tables and triggers for insert/update/delete operations dynamically:

```
class VcDDL(object):
    """A DDL extension which integrates SQLAlchemy table create/drop
    methods with Vc's trigger system.

    Usage::
        sometable = Table('sometable', metadata, ...) # or use declarative
        VcDDL(sometable)
        sometable.create()
    """

    def __init__(self, decl_table):
        table = decl_table.__table__
        # Note that this puts a reference to self into table.
        # self is a callable (see __call__ below).
        for event in ('after-create', 'before-drop'):
            table.append_ddl_listener(event, self)

        # Get the names of all columns.
        cc = table.columns
        columns = cc.keys()
        ur_columns = [Column ('id', Integer(), primary_key=True)]
        ur_columns += [Column ('_' + cc[c].name, cc[c].type)
                       for c in columns]

        # This registers the object-specific revisions table with the
        # metadata and causes it to be created along with decl_table.
        self.undotable = Table('Vc_' + table.name, decl_table.metadata,
                               *ur_columns)

        # For triggers, we need certain patterns.
        self.null_columns = ", ".join (['NULL' for c in columns])
        self.new_columns = ", ".join (['new.' + cc[c].name for c in columns])

    def __call__(self, event, table, bind):
        # Create and destroy trigger.
        if event == 'after-create':
            str_action_insert = '0'
            bind.engine.execute \
                ('CREATE TRIGGER IF NOT EXISTS ' + self.undotable.name + '_ti'
                 + ' AFTER INSERT ON ' + table.name
                 + ' FOR EACH ROW BEGIN'
                 + ' SELECT RAISE(ABORT, "no active undo item")'
                 + '  WHERE ((SELECT id FROM VcCommits LIMIT 1) IS NULL);'
                 + ' SELECT RAISE(ABORT, "no active undo item") '
                 + '  WHERE (SELECT timestamp IS NOT NULL '
                 + '         FROM VcCommits ORDER BY id DESC LIMIT 1);'
                 + ' INSERT INTO VcRevisions (cid, action, tid) '
                 + '  VALUES ((SELECT MAX(id) FROM VcCommits), '
                 + '      ' + str_action_insert + ', '
                 + '          (SELECT id FROM VcTables '
                 + '           WHERE name = "' + table.name + '")); '
                 + ' INSERT INTO ' + self.undotable.name
                 + '  VALUES ((SELECT MAX(id) FROM VcRevisions), '
                 + '      ' + self.new_columns + ');'
                 + ' END')

            str_action_update = '1'
            bind.engine.execute \
                ('CREATE TRIGGER IF NOT EXISTS ' + self.undotable.name + '_tu'
                 + ' AFTER UPDATE ON ' + table.name
                 + ' FOR EACH ROW BEGIN'
                 + ' SELECT RAISE(ABORT, "no active undo item")'
                 + '  WHERE ((SELECT id FROM VcCommits LIMIT 1) IS NULL);'
                 + ' SELECT RAISE(ABORT, "no active undo item") '
                 + '  WHERE (SELECT timestamp IS NOT NULL '
                 + '         FROM VcCommits ORDER BY id DESC LIMIT 1);'
                 + ' INSERT INTO VcRevisions (cid, action, tid) '
                 + '  VALUES ((SELECT MAX(id) FROM VcCommits), '
                 + '      ' + str_action_update + ', '
                 + '          (SELECT id FROM VcTables '
                 + '           WHERE name = "' + table.name + '")); '
                 + ' INSERT INTO ' + self.undotable.name
                 + '  VALUES ((SELECT MAX(id) FROM VcRevisions), '
                 + '      ' + self.new_columns + ');'
                 + ' END')

            str_action_delete = '2'
            bind.engine.execute \
                ('CREATE TRIGGER IF NOT EXISTS ' + self.undotable.name + '_td'
                 + ' AFTER DELETE ON ' + table.name
                 + ' FOR EACH ROW BEGIN'
                 + ' SELECT RAISE(ABORT, "no active undo item")'
                 + '  WHERE ((SELECT id FROM VcCommits LIMIT 1) IS NULL);'
                 + ' SELECT RAISE(ABORT, "no active undo item") '
                 + '  WHERE (SELECT timestamp IS NOT NULL '
                 + '         FROM VcCommits ORDER BY id DESC LIMIT 1);'
                 + ' INSERT INTO VcRevisions (cid, action, tid) '
                 + '  VALUES ((SELECT MAX(id) FROM VcCommits), '
                 + '      ' + str_action_delete + ', '
                 + '          (SELECT id FROM VcTables '
                 + '           WHERE name = "' + table.name + '")); '
                 + ' INSERT INTO ' + self.undotable.name
                 + '  VALUES ((SELECT MAX(id) FROM VcRevisions), '
                 + '      ' + self.null_columns + ');'
                 + ' END')
        elif event == 'before-drop':
            bind.engine.execute ('DROP TRIGGER IF EXISTS ' + self.undotable.name + '_ti')
            bind.engine.execute ('DROP TRIGGER IF EXISTS ' + self.undotable.name + '_tu')
            bind.engine.execute ('DROP TRIGGER IF EXISTS ' + self.undotable.name + '_td')
            self.undotable.drop (bind=bind)
```

Two example tables contain objects used in the example of part 1.

```
class Labels(Base):
    __tablename__ = 'Labels'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    color = Column(String)

    def __init__(self, name, color):
        self.name = name
        self.color = color

class Blobs(Base):
    __tablename__ = 'Blobs'
    id = Column(Integer, primary_key=True)
    prop1 = Column(String)

    def __init__(self, prop1):
        self.prop1 = prop1
```

Finally, the DDL hooks to put these example tables under version control are registered:

```
VcDDL(Labels)
VcDDL(Blobs)
```

We also need an object that allows to create new commits. The flexibility of SQL Alchemy demands that this is a bit more complex, as we also need to set up a database connection:

```
class Vc(object):
    def __init__(self, name=None):
        if name is None:
            self.filename = ':memory:'
        else:
            # This also avoids issues with specials like ':memory:',
            # because an absolute path starts with a slash.
            self.filename = os.path.abspath(name)

        self._pool = sqlalchemy.pool.SingletonThreadPool \
            (lambda: sqlite3.connect(self.filename))
        self._engine = sqlalchemy.create_engine('sqlite://', pool=self._pool,
                                                echo=True)
        self._Session = sqlalchemy.orm.sessionmaker(bind=self._engine)

        Base.metadata.create_all(self._engine)

        # A session in which the current undo/redo commit transaction persists.
        self.commit_session = None
        self.commit_object = None

    def start_commit(self, description):
        assert self.commit_session is None
        session = self._Session()
        # Find out the parent commit.
        head = session.query(VcBranches).filter_by(name='HEAD').first()
        parent = head.cid
        new_commit = VcCommits (description, parent)
        session.add (new_commit)
        # We must flush the session, because subsequent triggers need
        # to see the new commit item.
        session.flush()
        self.commit_session = session
        self.commit_object = new_commit

    def end_commit(self):
        assert self.commit_session is not None        
        session = self.commit_session
        # We must flush the session, because triggers must not see the
        # commit time stamp we are about to write.
        session.flush()
        self.commit_object.timestamp = datetime.datetime.now()
        session.commit()
        self.commit_session = None
        self.commit_object = None
        # FIXME: Increment HEAD ?
```

As you can see, the implementation is not yet complete, because the `HEAD` is not updated. Also, the implementation of undo/redo and the export to/import from git is missing. Stay tuned for updates.

 [1]: http://www.sqlalchemy.org/

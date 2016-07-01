---
title: SQL Alchemy and string interning
author: Marcus
layout: post
date: 2010-08-19T22:00:45+00:00
url: /2010/08/20/sql-alchemy-and-string-interning/
categories:
  - Uncategorized
tags:
  - programming
  - sql
  - sqlalchemy
  - sqlite
  - string interning

---
In a recent post I explored hash values as a more efficient alternative for string discriminators in joined table inheritance with SQLAlchemy. This time, I present an alternative solution, less efficient, but also a bit clearer and with no mathematical background: [String interning][1].
  
Normalizing databases so that referenced table names (or discriminators) are stored in a separate table and referenced by their primary ID is a well known best practice. The problem is to make SQLAlchemy dynamically allocate and look up the IDs as discriminators in an open name space. The solution is to leave the dirty work to the database: Views can be used to provide sqlalchemy with string-ish access to the discriminator, while triggers can be used to map write accesses by sqlalchemy to operations in the real tables. A [message by Dan Bishop][2] on the SQLite Users mailing list leads the way to an implementation. One remaining trick necessary is to create the view in the first place. SQL Alchemy does check for existance of a table before running the before-create DDL listener hooks, so we can not preempt SQL Alchemy in creating the table. The solution is to create the view in the after-create DDL listener hook, after dropping the freshly created table:

```python
def view_ddl_listener(event, table, bind):
    if event == 'after-create':
        bind.engine.execute \
            ("DROP TABLE VcRevisions")
        bind.engine.execute \
            ('CREATE VIEW VcRevisions AS SELECT '
             '  vc_id, vc_cid, vc_action, name "vc_tname" FROM '
             '  VcRevisions_ LEFT JOIN VcTables ON (vc_tid = id)')
        bind.engine.execute \
            ('CREATE TRIGGER IF NOT EXISTS VcRevisions_ti'
             + ' INSTEAD OF INSERT ON VcRevisions'
             + ' BEGIN'
             + '   INSERT OR IGNORE INTO VcTables (name) '
             + '     VALUES (new.vc_tname);'
             + '   INSERT INTO VcRevisions_ '
             + '     VALUES (new.vc_id, new.vc_cid, new.vc_action, '
             + '             (SELECT id FROM VcTables '
             + '              WHERE name = new.vc_tname));'
             + ' END')

VcRevisions.__table__.append_ddl_listener('after-create', view_ddl_listener)

```

Depending on your application, you may also need update and delete triggers.

 [1]: http://en.wikipedia.org/wiki/String_interning
 [2]: http://www.mail-archive.com/sqlite-users@sqlite.org/msg51706.html
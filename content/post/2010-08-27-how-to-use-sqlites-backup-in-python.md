---
title: How to use SQLite’s backup in Python
author: Marcus
layout: post
date: 2010-08-26T22:00:35+00:00
url: /2010/08/27/how-to-use-sqlites-backup-in-python/
categories:
  - Uncategorized
tags:
  - crock
  - interface
  - programming
  - Python
  - sql
  - sqlalchemy
  - sqlite

---
SQLite is a very portable database that is easy to deploy, as it does not require a server and work off a single file. This makes it ideally suited as an [application file format][1]. An important part of any application is the ability make copies of documents (“Save-As”). There is no way to do this within SQL, but SQLite provides a [backup interface][2] that can be used for that purpose.
  
Unfortunately, SQLite's backup interface is not generally part of the generic database APIs in many higher level languages, including Python. The [sqlite3][3] module that comes with the standard library implements the DB-API 2.0 but lacks the backup extensions. On the other hand, [Another Python SQLite Wrapper][4] (APSW) provides the backup extension, but does not implement the standard DB-API 2.0 API. This means that APSW can not be used as a driver for other python modules, such as [SQL Alchemy][5].
  
Luckily, there is a<del datetime="2010-08-31T13:45:17+00:00">n undocumented</del> _(see comments)_ feature of the SQLite3 module in Python: The constructor can take an APSW connection and provide the Python DB-API 2.0 on top of that, like this:

```python
import sqlite3
import apsw
_connection = apsw.Connection(':memory:')
connection = sqlite3.connect(_connection)
# Use connection as DB-API 2.0, then "Save-As" like this:
destdb = apsw.Connection('some-file')
with destdb.backup("main", _connection, "main") as backup:
    while not backup.done:
    backup.step(100)
```

This way you can combine the best of both worlds, and access the database through the SQLite3 interface for database operations and through the APSW interface for the backup operations. This is how to use the above connection with SQL Alchemy:

```python
_pool = sqlalchemy.pool.SingletonThreadPool (lambda: sqlite3.connect(_connection))
_engine = sqlalchemy.create_engine('sqlite://', pool=_pool)
```

P.S.: This is how it works internally: In Python 2.6, in the file `Modules/_sqlite/connection.c`, you find:

```
int pysqlite_connection_init(pysqlite_Connection* self, PyObject* args, PyObject* kwargs)
{
    int is_apsw_connection = 0;
...
        /* Create a pysqlite connection from a APSW connection */
        class_attr = PyObject_GetAttrString(database, "__class__");
        if (class_attr) {
            class_attr_str = PyObject_Str(class_attr);
            if (class_attr_str) {
                if (strcmp(PyString_AsString(class_attr_str), "<type 'apsw.Connection'>") == 0) {
                    /* In the APSW Connection object, the first entry after
                     * PyObject_HEAD is the sqlite3* we want to get hold of.
                     * Luckily, this is the same layout as we have in our
                     * pysqlite_Connection */
                    self->db = ((pysqlite_Connection*)database)->db;

                    Py_INCREF(database);
                    self->apsw_connection = database;
                    is_apsw_connection = 1;
                }
            }
...
}
```

As you can see, the way it grabs the pointer from the apsw C implementation is quite a [crock][6]!

 [1]: http://www.sqlite.org/whentouse.html
 [2]: http://www.sqlite.org/backup.html
 [3]: http://docs.python.org/library/sqlite3.html
 [4]: http://code.google.com/p/apsw/
 [5]: http://www.sqlalchemy.org/
 [6]: http://catb.org/jargon/html/C/crock.html
---
title: Automatic Version Control with SQL Triggers pt. 1
author: Marcus
date: 2010-08-13T22:00:45+00:00
url: /2010/08/14/automatic-version-control-with-sql-triggers/
categories:
  - Uncategorized
tags:
  - redo
  - sql
  - sqlite
  - undo
  - version control

---
Here is an expansion on the idea to [use SQLite triggers for undo/redo in applications][1]. In particular, this solution keeps all history, and thus can be converted to and from git (or other version control systems), using CSV files for example.

The presentation style is that of a napkin during dinner. I'll put in more details later, in particular how to integrate this into python/sqlalchemy.

{{< figure src="/wp-content/gallery/automatic-version-control-with-sql-triggers/page1.png" >}}
{{< figure src="/wp-content/gallery/automatic-version-control-with-sql-triggers/page2.png" >}}
{{< figure src="/wp-content/gallery/automatic-version-control-with-sql-triggers/page3_0.png" >}}

**Update:** Some comments on the notes.  Page 1 shows the application view.  The user performs some actions on the program that cause changes to the object database: New instances are created, existing ones changed or deleted.  Some actions (like “Create Blob”) affect more than one object and should be committed in a transaction.  Undoing an action should also undo all related object changes in one atomic operation.  The solution to this problem is to track all changes to object tables in the database automatically using SQL triggers, leaving enough trace information to be able to undo and redo individual actions, and maybe even exporting them to a Git repository where more complex actions can be taken (cherry picking, rebasing, etc).

Page 2 shows the additional tables needed by the version control system (`Vc` prefix).  The VcCommits table has one row for each user action, or “commit”.  The description is a human-readable string, usually shown in the Edit menu of the application in the Undo/Redo items.  The timestamp can be used for conversion to a Git repository, it is informative but serves a double purpose: A missing timestamp shows a commit “in construction”: While the timestamp is not assigned, further individual object changes can be added to the commit.  Only when the timestamp is filled in is the commit complete.  Most important is the parent column, which indicates the order in which actions were performed.  The parent relationship overlays a tree structure on the set of all commits.  If a user undo's an action and then performs new actions, a branch is created that shares the parent with the previous redo item.

The VcRevisions table lists all object changes in commits.  It has a foreign key reference to the VcCommits table to express the one-to-many relationship between commits and (object) revisions.  The foreign key reference can take the “on delete cascade” option.  An object can be inserted, updated, or deleted, as indicated by the action column.  As the object-specific data does not fit a single table schema, we keep one additional `Vc\_` table per object type, holding the object specific data.  As there are many different such tables, we have to reference them indirectly by name instead of using foreign key references; this is what the tid column does.  We do not say which row id in the “Vc\_” table belongs to this VcRevision entry, as that would mean another table update which serves no useful purpose.

The triggers then check for a pending commit object in the VcCommits table, and if it is found, they append an item to the VcRevisions table, before filling in the object-specific data.  Because we can not transfer information from one query to another in a trigger sequence, we have to use sub-queries.  An example is shown in page 3.

Some notes on the schema design:

  * In the case of a delete operation, we assign NULL to every data column in the object-specific `Vc_` table.  We could also emit the row entirely for delete actions, but keeping them makes these tables more readable stand-alone, and makes the schema more consistent, thus simpler to understand in a first approach.

  * The “Vc\_” tables reference the VcRevisions table, and not the other way round.  Although there is a one-to-one relationship, only this way we can use real foreign key references, because every rid column in a “Vc\_” table points to the same VcRevision table, but the VcRevisions table would have to point to many different `Vc_` tables.

  * The underscore in `Vc_` creates a private namespace for all object-specific tables and thus prevents name collisions (imagine an object type “Commits” or “Revisions”).

 [1]: http://www.sqlite.org/cvstrac/wiki?p=UndoRedo
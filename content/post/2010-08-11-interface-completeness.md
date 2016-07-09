---
title: Interface Completeness
author: Marcus
date: 2010-08-10T22:00:41+00:00
url: /2010/08/11/interface-completeness/
categories:
  - Uncategorized
tags:
  - interface
  - programming

---
An interface is complete when it provides enough methods to implement all desirable operations. Of course, not all operations need to be elementary methods, and the definition of desirable is arbitrary. An efficient interface design is complete without being redundant, but redundancy can be added for ease of use, performance, or historic reasons. Here are just a few examples related to virtual memory management of processes:

  * Linux does not have an interface to manipulate the address space of a process that is not the current one. The authors of User Mode Linux had to write a non-standard kernel module to add this feature. Efforts to extend Linux failed, partly because the problem was not considered important enough, and partly because it was too specific, while a general solution was too invasive.
  * The original `MapViewOfFile` in the Windows API did not allow to specify a base address for the file mapping, so a new function `MapViewOfFileEx` was added that allows it. In fact, every `FooEx` is a sign that some interface `Foo` was not complete.
  * Windows CE does not have `MapViewOfFileEx`, making it impossible to predict reliably the base address for file mappings, making it harder to write a DLL loader in user space. Note that the system can map image files at their intended load address, but it does not expose the interfaces that are required to do this.

As the first and second examples show, one sign of interface incompleteness is that the interface is not fully virtualizable: An interface that can not be implemented given only functions in the interface must either be uninteresting or lacking some interesting functions! So, when designing interfaces, try to be aware of the virtualization property and see if your interface is complete in this regard or not, and for which reasons.
  
Here are some more examples not related to memory management:

  * Linux got a lot of functions that work on file descriptors instead of path names when Ulrich Drepper desired [race-free filesystem traversal.][1]
  * The Python keyword `yield` was a statement in Python 2.3, but in Python 2.5 it was promoted to an expression, to allow it to return a value. Is it complete now? Maybe, but Python has defects in other places. For example, the top-level scope of a module is special and can thus not be wrapped: It affects the name space in a different way than blocks do, and `yield` is not allowed.
  * One strong argument for `zope.interface` over Abstract Base Classes is that `zope.interface` can be used for any python object, not only classes.

Listing many more examples would easily be possible, and some are very instructive. Defects in the interface tell a story about the programmer's intent that is not part of the official narrative. Next time you learn a new interface, try to ask yourself the question what it can't do, and why that is.

 [1]: http://lwn.net/Articles/164584/
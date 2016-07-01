---
title: Documenting Interfaces in Python
author: Marcus
layout: post
date: 2010-08-09T08:00:05+00:00
url: /2010/08/09/hello-world/
categories:
  - Uncategorized
tags:
  - C
  - EAFTP
  - interface
  - LBYL
  - modularity
  - programming
  - Python

---
Programs are written for humans as well as for computers, and never the twain shall meet.  On the one hand, we are not smart enough to understand executables the way computers do: Programmers are notoriously bad at predicting the performance of their work as it is interpreted by actual machines, and much time is expended in chasing down bugs that result from an insufficient mental model of the machine in the programmer's head.  On the other hand, we do not have tools that are good enough to automatically extract efficient and reliable programs from high-level descriptions of problem solutions that appear, at surface level, quite sufficient for humans, often even those not specifically trained in the problem domain.

Somewhere in between all this lies the daily routine of a programmer at work: Translating high level descriptions to machine programs and vice versa, depending on the history and goals of the project, and leaving enough documentation behind, so that other programmers do not have to start from scratch.  We build cathedrals and we explore ruins, we construct and appraise.  To do this efficiently requires a superb toolbox and a deep understanding of the fundamentals as well as the specifics of the chosen tools.

It is for this reason that learning a new language can be a very tedious and slow process.  Python does not differ much from C, not in the way that functional programming differs from procedural programming, for example. C programmers have used duck typing, hash tables, name spaces, and so on, well before Python existed.  But Python does differ in the set of standard idioms that are included in the programmers toolbox, and in the balance these idioms strike in the never-ending pursuit of reconciling human and computer needs in a program.

One example is the documentation of the interface between program components, in the most abstract sense the set of methods supported by object instances of a certain type.  Python hails the use of duck-typing, untyped variable names and the rule of thumb that &#8220;it is easier to ask for forgiveness than for permission.&#8221;  This leads to program components that are maximally independent, a property that is usually quite desirable (the other extreme would be inheritance in C++, which makes code maximally dependent, which leads to many problems, some so obscure that those are blessed who never have to deal with them).

But the dependencies between program components, or interfaces, are objects in their own right, and omitting them removes documentation of the program that is important for the humans trying to tag along. That's why I am using `zope.interface` for documenting the interfaces and the dependencies between program components. And type checks (Pythonistas don&#8217;t like to &#8220;look before you leap&#8221;) are as much a statement of intent of the programmer as they are a safety measure in a complex dynamic system with emergent behaviour beyond the explicit intent of the programmer.
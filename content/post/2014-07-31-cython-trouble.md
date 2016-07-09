---
title: Cython Trouble
author: Marcus
date: 2014-07-31T15:15:55+00:00
url: /2014/07/31/cython-trouble/
categories:
  - Programming
tags:
  - C
  - Cython
  - programming
  - Python

---
Here are a couple of things I experienced using Cython to wrap my C++ library [grakopp][1]:

**Assignment and Coercion**

  * I couldn't find a nice way to wrap boost::variant. Although the direct approach works, an assignment to the variant requires an unsafe cast, but that also adds the overhead of a copy. To work around this, I used accessor functions (requires changing the C++ implementation).
  * The operator= is not supported to declare custom assignment functions.
  * There is no other way to add custom coercion rules. The support for STL container coercion is hardcoded in `Cython/Compiler/PyrexTypes.py`. This also makes the builtin coercions less useful.
  * string coercion seems to be unhappy quite often, so you have to cast to string or char* even constant strings.

**Imports**

  * Relative cimports are not supported.
  * Unintuitively, a corresponding pxd file is automatically included, which can not be supressed. So renaming its imports with &#8220;as&#8221; in a cimport is not possible.
  * There is no sensible place to put shared pxd files. [[Wiki]][2] [[Forum]][3]

**References and Initializers**

  * References can not be initialized with an assignment, so pointers or slow copies have to be used everywhere.
  * Only the default constructor can be used to instantiate stack or instance variables.

**Overloading**

  * Cython could not resolve function overloading which differed only in the constness of the return type.

**Templates**

  * It's not possible to write meta-extension classes for template classes directly &#8211; only extension types for specific instantiations. [[Forum]][4]
  * It's not possible to use non-type template arguments (as a workaround, you can use `ctypedef int THREE "3"`). [[Forum]][5]
  * It's also not possible to instantiate function templates, but there is a similar workaround. [[Forum]][6]

 [1]: http://github.com/lambdafu/grakopp
 [2]: https://github.com/cython/cython/wiki/PackageHierarchy
 [3]: https://groups.google.com/forum/#!topic/cython-users/fYaqdkSfCI0
 [4]: https://groups.google.com/forum/#!topic/cython-users/qQpMo3hGQqI
 [5]: https://groups.google.com/d/msg/cython-users/JVzbh2Vbm60/p99NBPUmxYIJ
 [6]: https://groups.google.com/d/msg/cython-users/JVzbh2Vbm60/GquI2kVkKKoJ
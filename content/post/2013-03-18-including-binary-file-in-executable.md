---
title: Including binary file in executable
author: Marcus
date: 2013-03-18T11:37:34+00:00
url: /2013/03/18/including-binary-file-in-executable/
categories:
  - Programming
tags:
  - obfuscation
  - programming

---
A friend asked how to include a binary file in an executable. Under Windows, one would use resource files, but under Linux the basic tools are sufficient to include arbitrary binary data in object files and access them as extern symbols. Here is my example file. To make it more fun, the same file is also a Makefile and a shell script, and the program prints itself when run (without requiring the source file to be present).

Note that the first character in most of these lines is TAB, not space. Get the raw [source file][1] from pastebin.com instead of using c&p here.

```c
# /* Self-printer using objcopy. To build, save as foo.c and run "sh foo.c".
dummy= exec make -f foo.c
all:
	objcopy -I binary -O elf64-x86-64 -B i386:x86-64 foo.c foo-src.o
	gcc -g -o foo foo.c foo-src.o

dummy:
#  */
	#include <stdio.h>

	extern char _binary_foo_c_start;
	extern char _binary_foo_c_size;
	extern char _binary_foo_c_end;

	char *bin_start = &_binary_foo_c_start;
	char *bin_end = &_binary_foo_c_end;
	ssize_t bin_size = (ssize_t) &_binary_foo_c_size;

	int
	main (int argc, char *argv[])
	{
	  printf ("%*s\n", (int) bin_size, bin_start);
	  return 0;
	}
```

 [1]: http://pastebin.com/raw.php?i=C18SJGTF
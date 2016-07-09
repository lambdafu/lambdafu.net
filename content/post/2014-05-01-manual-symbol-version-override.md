---
title: Manual symbol version override
author: Marcus
date: 2014-04-30T23:16:14+00:00
url: /2014/05/01/manual-symbol-version-override/
categories:
  - Programming
tags:
  - elf
  - glibc
  - symbol versioning

---
I had to deal with a proprietary software library that wouldn't run on CentOS 6.5, because the library was compiled against a newer glibc (>= 2.14) while CentOS was running on glibc 2.12. Actually, there was only one symbol versioned later than 2.11, which was memcpy@2.14. It turns out that this is due to a well-known optimization (nice discussion with links [[here][1]).

Normally, one would install an appropriate version of the library and set `LD_LIBRARY_PATH` accordingly, but for libc that ain't so easy, because you also need a matching runtime linker, and the kernel will always use `/lib64/ld-linux-x86-64.so.2` or whatever is found in the INTERP program header of the ELF executable. You can run the matching linker manually, but this only works for the invoked processes, not its children. It's a huge PITA, and short of a chroot filesystem or other virtualization I don't know a good way to replace the system C library (if you know a way, leave a comment!).

Anyway, I decided to patch the binary. First, I checked the older version of the library, and saw that it required memcpy@2.2.5. So here we go:

```
$ readelf -V libfoo.so

Version symbols section '.gnu.version' contains 3627 entries:
 Addr: 000000000003688e  Offset: 0x03688e  Link: 2 (.dynsym)
  000:   0 (*local*)       0 (*local*)       1 (*global*)      1 (*global*)
....
  d7c:   9 (GLIBC_2.14)    1 (*global*)      1 (*global*)      1 (*global*)
....

Version needs section '.gnu.version_r' contains 4 entries:
 Addr: 0x00000000000384e8  Offset: 0x0384e8  Link: 3 (.dynstr)
  000000: Version: 1  File: libgcc_s.so.1  Cnt: 1
  0x0010:   Name: GCC_3.0  Flags: none  Version: 8
  0x0020: Version: 1  File: libstdc++.so.6  Cnt: 3
  0x0030:   Name: CXXABI_1.3.1  Flags: none  Version: 7
  0x0040:   Name: CXXABI_1.3  Flags: none  Version: 6
  0x0050:   Name: GLIBCXX_3.4  Flags: none  Version: 4
  0x0060: Version: 1  File: libc.so.6  Cnt: 3
  0x0070:   Name: GLIBC_2.14  Flags: none  Version: 9
  0x0080:   Name: GLIBC_2.11  Flags: none  Version: 5
  0x0090:   Name: GLIBC_2.2.5  Flags: none  Version: 3
  0x00a0: Version: 1  File: libm.so.6  Cnt: 1
  0x00b0:   Name: GLIBC_2.2.5  Flags: none  Version: 2
```

Let's check if reference 0xd7c (== 3452) really is memcpy:

```
$ readelf --dyn-syms libfoo.so|grep $((0xd7c))
  3452: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memcpy@GLIBC_2.14 (9)
```

We look up the [specification][2] for the layout of these .gnu.version sections. The plan is to copy the entry for GLIBC\_2.2.5 into the entry for GLIBC\_2.14, so that all references to version “9” go to glibc 2.2.5 instead of 2.14.

```
$ od -j $((0x384e8+0x60)) -N $((0x40)) -Ax -t x1 libfoo.so
038548 01 00 03 00 ed b9 01 00 10 00 00 00 40 00 00 00
038558 94 91 96 06 00 00 09 00 43 ba 01 00 10 00 00 00
038568 91 91 96 06 00 00 05 00 4e ba 01 00 10 00 00 00
038578 75 1a 69 09 00 00 03 00 59 ba 01 00 00 00 00 00
```

We can see the verneed (“version needed”) entry for libc here, together with three vernaux (“version needed auxiliary”) entries. Each vernaux entry consists of a 4-byte hash value for the version name (for faster comparison than strcmp, here 0x06969194 for GLIBC_2.14), 4 bytes flags and other information (such as the version number referenced by the .gnu.version section in the last byte), a 4-byte offset into the string table with the human-readable version string, and a 4-byte length for the entry (always 0x10).

We want to keep the indirectly referenced version number (“9&#8243;), so there are no duplicate entries, but copy the hash and string pointer values. Of course, the next offset stays, too. After editing with a hex editor, we have:

```
$ od -j $((0x384e8+0x60)) -N $((0x40)) -Ax -t x1 libfoo.so
038548 01 00 03 00 ed b9 01 00 10 00 00 00 40 00 00 00
038558 75 1a 69 09 00 00 09 00 59 ba 01 00 10 00 00 00
038568 91 91 96 06 00 00 05 00 4e ba 01 00 10 00 00 00
038578 75 1a 69 09 00 00 03 00 59 ba 01 00 00 00 00 00
```

Let's see if this worked:

```
$ readelf -V libfoo.so
...
  0x0060: Version: 1  File: libc.so.6  Cnt: 3
  0x0070:   Name: GLIBC_2.2.5  Flags: none  Version: 9
  0x0080:   Name: GLIBC_2.11  Flags: none  Version: 5
  0x0090:   Name: GLIBC_2.2.5  Flags: none  Version: 3
... 

$ readelf --dyn-syms libfoo.so|grep $((0xd7c))
  3452: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND memcpy@GLIBC_2.2.5 (9) 
```

There is an extra memcpy@@2.14 reference, but no entry for it in the version table. I can get rid of that with `strip --strip-unneeded`, if I want to.

This seems to work for me just fine, and in fact it would have worked even if there wasn't a GLIBC_2.2.5 entry already, but an entry for some other version. However, if there are more symbols to deal with, we might actually need to edit the actual symbol versions in the .gnu.version section (change the “9” into a “3” in this case), or do more complicated editing.

 [1]: http://www.win.tue.nl/~aeb/linux/misc/gcc-semibug.html
 [2]: http://refspecs.linuxfoundation.org/LSB_3.2.0/LSB-Core-generic/LSB-Core-generic/symversion.html
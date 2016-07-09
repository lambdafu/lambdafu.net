---
title: How many digits of SHA1 are needed to differentiate english words?
author: Marcus
date: 2010-08-17T22:00:45+00:00
url: /2010/08/18/how-many-digits-of-sha1-are-needed-to-differentiate-english-words/
categories:
  - Uncategorized
tags:
  - birthday paradox
  - programming
  - sha1
  - sqlalchemy
  - sqlite

---
For SQLAlchemy, when using joined table inheritance, a discriminator needs to be provided that specifies the type of a derived object, so that additional object data can be looked up in tables specific to that type. The problem is how to choose a discriminator in an open system, such as an application extensible by plugins that add their own types. One way to do this is to take the hash value of a representation of the exact signature of the type. By choosing a large enough hash range, collisions are practically avoided, giving distinct types distinct discriminators. (This technique is not new, but I don't know the original reference. I heard about it from Jonathan Shapiro when he explained to me the IDL system of a capability operating system.)
  
One way to represent a type is to represent recursively all members of the type and concatenate the result. This gives structurally identical types the same representation. Another way would be to just take the type name as the representation, which makes no assertions on structure and presupposes some kind of managed namespace. For a plugin-extensible application, assuming a managed namespace is reasonable, so we take this approach here. Of course, other representations are possible.
  
How large does the hash range need to be? Specifically, how many hexadecimal digits of SHA1 do we need to avoid collisions among all reasonable type names? The formula to calculate this, making some assumptions about the distribution of type names, is given by the [birthday paradox][1]. For a given hash range of `n` bits, the probability of a collision among `k` subjects is:
  
```gnuplot
gnuplot> p(x,n)=1-exp(-(x*x)/(2*(n)))
gnuplot> plot [1:50] p(x,n), n=365.0  
```
  
For the problem of a dictionary of `w` words and `b` bits of a SHA1 hash sum, the graph is calculated by this:
  
```
gnuplot> plot [b=1:256] p(w,2.0**b), w=1e5
```
  
For a dictionary of 100,000 words (number of entries in a large dictionary), The probability of at least one collision is above 50% if you take a hash funtion with a range of 32 bits. It's one in a million above 48 bits. Even with 64 bits there is still a 1 in 3.7 bil chance of a collision, but we are now approaching a margin of safety that may be sufficient for simple applications with a small number of types. These odds start to advance from reasonable to excellent if the dictionary is much smaller than 100,000.
  
To verify these results practically, we use a one-liner on the command line. The first `sort | uniq -c` sequence counts the number of collisions, the second `sort | uniq -c` sequence counts the number of collision groups of a certain size. Once we get `w` groups of size 1, there are no more collisions.
  
```
$ for cnt in {1..32}; do echo "For $cnt"; perl -n -mDigest::SHA1=sha1_hex -e '$_ = sha1_hex($_); $_ = substr $_, 0, '$cnt'; print $_."\n";' /usr/share/dict/words| sort |uniq -c | awk '{print $1}' | sort -n| uniq -c; done
For 1
      1 5942
      1 5989
      1 6049
[...]
For 2
      1 323
      1 334
      1 336
      2 340
[...]
For 3
      1 7
      2 10
      6 11
     13 12
[...]
For 4
  21808 1
  16428 2
   8374 3
   3055 4
    938 5
    238 6
     55 7
      5 8
      1 9
      1 11
For 5
  89659 1
   4235 2
    144 3
      2 4
For 6
  97987 1
    291 2
For 7
  98533 1
     18 2
For 8
  98569 1
For 9
  98569 1
```

As expected, there are no collision among the words in the dictionary (which has 98569 entries) once the hash range exceeds 8*4 = 32 bits. However, as there are collisions with 28 bits, there is no margin of safety here. In fact, if we prefix every word in the dictionary with \`_[/cci\] (a common symbol prefix in operating systems), we find conflicts with a hash range of 32 bits:
  
```
$ perl -n -mDigest::SHA1=sha1_hex -e '$w = $_ ; $s = sha1_hex('_' . $w); print $s." _".$w;' /usr/share/dict/words |sort |colrm 9 | sort |uniq -d
6534ca5e
e41c32ec
$ perl -n -mDigest::SHA1=sha1_hex -e '$w = $_ ; $s = sha1_hex('_' . $w); print $s." _".$w;' /usr/share/dict/words |grep 6534ca5e
6534ca5e0945227ed1e93c5306dead4f _grapefruit
6534ca5e6b6b8828505308f51f5b9ecf _overheads
$ perl -n -mDigest::SHA1=sha1_hex -e '$w = $_ ; $s = sha1_hex('_' . $w); print $s." _".$w;' /usr/share/dict/words |grep e41c32ec
e41c32ecf72bd7ed3feeea80fedb86be _Hartford
e41c32ecc4d02ee028f1c686c21ad179 _snapdragons
  
```
  
A typical application uses dozens or hundreds of important types rather than thousands (recall that every type in an ORM requires a table in the database). That provides sufficient margin of safety with a hash range of 64 bits. SQLite uses 8 byte signed integer numbers internally, which provides 63 bits if we want to avoid negative numbers. You might want to run the numbers for your own application needs.
  
Of course, it is also possible to allocate discriminators dynamically and assign them to types by using a table in the database. However, this makes the database scheme (for ORM) more complicated, as the SQLAlchemy database schema then depends on auxiliary data. It also makes data migration a bit more complicated, as discriminators would have to be translated.

 [1]: http://en.wikipedia.org/wiki/Birthday_paradox
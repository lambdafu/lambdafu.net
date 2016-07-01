---
title: Parsing Unicode text with Python PLY
author: Marcus
layout: post
date: 2011-08-18T01:05:18+00:00
url: /2011/08/18/parsing-unicode-text-with-python-ply/
categories:
  - Uncategorized
tags:
  - PLY
  - programming
  - Python
  - unicode

---
[Python PLY][1] is quite helpful in writing a simple scanner and parser, but I had some trouble figuring out how to make it accept Unicode tokens. I kept getting weird errors like this:

```
Getr. Zählung
Syntax Error: '̈hlung'
```

The syntax error is displayed as an h with umlaut, something that does not even exist in German. On closer inspection, the problem turns out to be the COMBINING DIAERESIS character, which prevents the regular expressions in PLY from matching.

The solution is to use the [Unicode normalization form][2] KC (Compatibility Decomposition, followed by Canonical Composition), and to make sure that PLY uses unicode for matching:

```
lex.lex(reflags=re.UNICODE)
lex.input(unicodedata.normalize('NFKC', s)
```

**Update:**

Because I keep losing [this snippet][3], I will record it here. It's what you add at the top of the file if `print` doesn't work. Don't ask.

```
import codecs, sys
sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
```

 [1]: http://www.dabeaz.com/ply/
 [2]: http://unicode.org/reports/tr15/
 [3]: http://kbyanc.blogspot.com/2007/04/python-printing-unicode.html
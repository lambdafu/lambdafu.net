---
title: Attention, elasticsearch counts in UTF-16
author: Marcus
date: 2013-03-09T15:34:06+00:00
url: /2013/03/09/attention-elasticsearch-counts-in-utf-16/
categories:
  - Uncategorized
tags:
  - elasticsearch
  - unicode

---
Here is a surprise. Trying to extract the text of analyzed tokens in elasticsearch, I found that it didn't match my expectations. The positions start\_offset and end\_offset were not counted in bytes, and not counted in Unicode graphemes. What was going on?

A hint was the behavior of the standard analyzer:

```
$ python -c 'print "X \xf0\x9d\x9b\xbe Y"' > test.txt
$ curl -XGET 'http://localhost:9200/diss/_analyze?analyzer=standard&pretty=1' -d @test.txt
{
  "tokens" : [ {
    "token" : "x",
    "start_offset" : 0,
    "end_offset" : 1,
    "type" : "<ALPHANUM>",
    "position" : 1
  }, {
    "token" : "\uD835\uDEFE",
    "start_offset" : 2,
    "end_offset" : 4,
    "type" : "<ALPHANUM>",
    "position" : 2
  }, {
    "token" : "y",
    "start_offset" : 5,
    "end_offset" : 6,
    "type" : "<ALPHANUM>",
    "position" : 3
  } ]
}
```

Apparently, the input was converted to UTF-16, and the offsets were measured in multibytes (2-byte sequences). That worked fine for me, so maybe this will help you, too.
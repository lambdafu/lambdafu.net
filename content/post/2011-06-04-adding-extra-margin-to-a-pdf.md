---
title: Adding extra margin to a PDF
author: Marcus
layout: post
date: 2011-06-03T22:11:51+00:00
url: /2011/06/04/adding-extra-margin-to-a-pdf/
categories:
  - Uncategorized
tags:
  - PDF
  - Python

---
I wanted to add my own little margin notes to any PDF file (using LaTeX and the multistamp feature of PDFTk). However, because the PDF was arbitrary, I could not write on the existing margin. Instead, I had to add an extra margin at the side. But none of the standard tools supports that, and using pypdf and similar toolsets loses the metadata like bookmarks. Here is a quick hack to expand the relevant page boxes:

```
#!env python2.7

import os
import os.path
import subprocess
import re

# Margin in points.
margin = 150

def addmargin(fn_src, fn_dst):
    fn_tmp = fn_dst + '.tmp'

    subprocess.call(['pdftk', fn_src, 'output', fn_dst, 'uncompress'])

    # We leave rotate pages alone, as they usually contain tables or images.
    rotate = 0
    # We leave Bleed and Art alone. 
    box = re.compile(r'^/(Media|Crop|Trim)Box\s+\[(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\]$')
    rot = re.compile(r'^/Rotate\s+(.+)$')

    infile  = open(fn_dst, 'rb')
    outfile = open(fn_tmp, 'wb')

    # This is a hack, but what the hell.
    for line in infile:
        lr = rot.match(line)
        if lr:
            print line
            rotate = int(lr.group(1))
        elif rotate == 0:
            lm = box.match(line)
            if lm:
                print line
                (btype, bl, bt, br, bb) = lm.groups()
                line = '/%sBox[%s %s %.3f %s]\n' % (btype, bl, bt, float(br) + margin, bb)
        outfile.write(line)

    outfile.close()
    infile.close()

    subprocess.call(['pdftk', fn_tmp, "output", fn_dst, "compress"])
    os.remove(fn_tmp)

if __name__ == '__main__':
    addmargin("in.pdf", "out.pdf")
  
```

Adding rotation support is left as an exercise for the reader.

I also made a custom version of pdftk to disable scaling of the stamp, because I controlled the stamp PDF in such a way that each page was a perfect fit on the original page. The positions of text elements on the original page were available due to `pdftotext -bbox-extended -xmlmeta`. The xmlmeta option is not part of the regular PDFTk distribution: We enriched our version of pdftotext (poppler) to have a more complete xml output to do that.
---
title: 6 things you didn’t know about MediaWiki
author: Marcus
date: 2013-09-06T15:13:12+00:00
url: /2013/09/06/6-things-you-didnt-know-about-mediawiki/
categories:
  - Programming
tags:
  - bugs
  - mediawiki
  - parsing
  - programming

---
&#8230; (and were afraid to ask).

**HTML Tag Scope:** If you mix HTML tags with wikitext, which is allowed for so-called “transparent tags”, MediaWiki will check the element nesting independent of the wikitext structure in a preprocessing step (`include/Sanitizer.php::removeHTMLtags`). Later on, when parsing the wikitext, some elements may be closed automatically (for example at the end of a block). The now-dangling close tag will be ignored, although it is detached from its counterpart by then:

```
<span style="color: red">test
 this</span>
```

will result in:

<p><span style="color: red">test</span></p><pre>
this
</pre>

while

```
test
 this</span>
```

will result in:

<p>test</p><pre>
this&lt;/span&gt;
</pre>

This can happen across a long part of the wikitext document, with many intermediate blocks, so the treatment of close tags has a wide context-sensitivity, which is generally bad for formal parsing.

**Breaking the cssCheck:** If a CSS style attribute contains character references to invalid Unicode code points, the page renderer terminates with a fatal error from `include/normal/UtfNormalUtil.php::codepointToUtf8` called through `include/Sanitizer.php::decodeCharReferencesCallback`:

```
<span style="\110000">x</span>
```

leads to the fatal error:

```
Asked for code outside of range (1114112)
```

It's a rare chance to see an uncaught exception to leak through to the user, and could be avoided by calling `include/Sanitizer.php::validateCodepoint` first and falling back to `UTF8_REPLACEMENT`.

_Update:_ I submitted a [patch for this][1] to MediaWiki's code review platform.

**HTML attribute junk:** You can write just about anything (except `&lt;`, `&gt;` or `/&gt;`) in the attribute space of an HTML opening tag, and MediaWiki will ignore it. This even includes a signature, like in the following example:

```
<strong !@#$%^&*()_foobar?,./';": style="color: red" ~~~~>test</strong>
```

yields

<strong style="color: red">test</strong>

As long as attributes are separated from junk by whitespace, they are preserved (such as the `style` attribute above).

**Missing block elements:** You can avoid generation of paragraph elements (`<p>`) around inline text by inserting an empty `<div style="display:inline">` element on the same line. If you drop the style attribute, the text will be broken in two paragraphs by the browser, though, and the text before and after the div will not connect to preceding or following inline elements.

**Table header data synonymity:** In a table, after a `!`, the table data cell separator `||` is synonymous with the table header cell separator `!!`:

```
{|
! header1 || header2
|}
```

yields

<table>
<tr>
<th> header1 </th>
<th> header2
</th></tr></table>

with two table headers. The opposite does not work, though:

```
{|
| data1 !! data2
|}
```

yields

<table>
<tr>
<td> data1&#160;!! data2
</td></tr></table>

Note that this example also introduces a non-breakable space character after “data1”, because MediaWiki interprets the following exclamation mark as french interpunction.

**Using indent-pre were it is not allowed:** In some places, indent-pre (creating `<pre>` elements by indenting text lines with a space) is disallowed for compatibility. This affects `<blockquote>`, `<p>`, `<li>`, `<dt>`, and `<dd&gt;` elements, and also prevents you from creating new paragraphs and `&lt;br/&gt;` elements with empty lines. The restriction is only active up to the first block level element, though, so it is easy to avoid it:

```
<ul><li>test


 this
 <div></div>
and


 this
</li></ul>
```

yields

<ul><li>test this
 <div></div>
<p>and
</p><p><br />
</p>
<pre>this
</pre>
</li></ul>

which demonstrates the limitation of the restriction.

 [1]: https://gerrit.wikimedia.org/r/#/c/87648/
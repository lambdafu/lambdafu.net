+++
date = "2015-10-20T12:00:00"
draft = false
image = ""
tags = ["programming", "html5"]
title = "The whole browser window but a border"
math = false
+++

Filling the whole browser window except for a border is surprisingly
difficult. Here are three solutions.

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css" href="test.css">
  </head>
  <body>
    <div class="outer outer1">
      <div class="inner">
      </div>
    </div>
  </body>
</html>
```

Instead of `outer1`, there is also `outer2` and `outer3`. The
solutions use different approaches: The `calc()` function to do math
in CSS, absolute positioning with top, left, bottom, right and the new
box-sizing property. Here is the stylesheet:

```css
html, body
{
    margin: 0px;
    padding: 0px;
}

.outer
{
    background-color: red;
    position: absolute;
    padding: 8px;
}

.outer1
{
    width: calc(100% - 16px);
    height: calc(100% - 16px);
}

.outer2
{
    top: 0px;
    left: 0px;
    right: 0px;
    bottom: 0px;
}

.outer3
{
    box-sizing: border-box;
    height: 100%;
    width: 100%;
}

.inner
{
    box-sizing: border-box;
    background-color: green;
    width: 100%;
    height: 100%;
}
```

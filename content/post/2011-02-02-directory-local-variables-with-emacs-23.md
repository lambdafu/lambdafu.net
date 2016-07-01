---
title: Directory-local variables with Emacs 23
author: Marcus
layout: post
date: 2011-02-02T14:13:13+00:00
url: /2011/02/02/directory-local-variables-with-emacs-23/
categories:
  - Uncategorized
tags:
  - dir-locals.el
  - directory-local variables
  - dirvars.el
  - emacs

---
If you manage different projects, it can be useful to define some Emacs variables local to the directory tree you are in. For example, I have different email addresses for different software projects, and I want the ChangeLog entry to show the email address for all software within the project directory. In the past, I used `dirvars.el` from the `emacs-goodies` package, but this has now been superseeded by `dir-locals.el` which is also upstream in Emacs&nbsp;23. Unfortunately, the documentation in the cloud for this tiny little helper is out of date. This is how it works in Emacs&nbsp;23 today:

1. Activate `dir-locals-mode` by adding to your `.emacs` file:

   	```lisp
        (dir-locals-mode)
	```

2. In any directory you want to customize variables, create an `.emacs-locals` file with a block like this:

        ```lisp
        Local variables:
        add-log-mailing-address: "marcus@atwork.example.com"
        End:
        ```

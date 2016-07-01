---
title: Remove passwords from PDF files
author: Marcus
layout: post
date: 2011-06-08T01:51:47+00:00
url: /2011/06/08/remove-password-from-pdf/
categories:
  - Uncategorized
tags:
  - PDF

---
Passwords on public PDF documents are a horrible idea. They are not effective, and they make legitimate uses harder. Encrypted PDFs even have a flag that can be used to discourage extraction for accessibility. Let's not even consider the moral of that.
  
[Pdftk][1] seems to have a problem processing some encrypted PDFs. I am not sure if this is due to lack of algorithmic support or due to other issues. In my case, the owner password had four letters and the user password was the empty string. But no matter what I tried, I got:

```
Error: Failed to open PDF file: 
   Gemmel.pdf
   OWNER PASSWORD REQUIRED, but not given (or incorrect)
Errors encountered.  No output created.
Done.  Input errors, so no output created.
```

Other tools cope in some way or another. Poppler can process the file without any manual intervention. The older pdfedit application asks for a password, but happily accepts the empty password in this case.

So, let's give Pdftk a little help. You can find instructions on how to remove the password [elsewhere on the internet][2], and this also works for the empty password:

```
$ qpdf --password= --decrypt encrypted.pdf decrypted.pdf
```

Conveniently, qpdf also handles the empty password automatically:

```
$ qpdf --decrypt encrypted.pdf decrypted.pdf
```

Now, how do you get the password in the first place? pdfcrack does the job quite nicely:

```
 $ pdfcrack -o -q encrypted.pdf<br /> found owner-password: 'xoxi'<br /> found user-password: ''
```
  </div>
</div>

 [1]: http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
 [2]: http://www.cyberciti.biz/faq/removing-password-from-pdf-on-linux/
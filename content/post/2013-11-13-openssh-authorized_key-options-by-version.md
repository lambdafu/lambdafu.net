---
title: OpenSSH authorized_key options by version
author: Marcus
layout: post
date: 2013-11-13T17:05:24+00:00
url: /2013/11/13/openssh-authorized_key-options-by-version/
categories:
  - Uncategorized

---
This should be in the official documentation, but for what it's worth:

All versions of OpenSSH support the following options in authorized_keys:
  
**command=&#8221;&#8221;**, **environment=&#8221;&#8221;**, **from=&#8221;&#8221;**, **no-agent-forwarding**, **no-port-forwarding**, **no-pty**, **no-X11-forwarding**.

Starting with version 2.5.2, OpenSSH supports **permitopen**.

Starting with version 4.3, OpenSSH supports **tunnel**.

Starting with version 4.9, OpenSSH supports **no-user-rc**.

Starting with version 5.4, OpenSSH supports **cert-authority**.

Starting with version 5.6, OpenSSH supports **principals**.
---
title: Fedora 18 Beta on Thinkpad T430s
author: Marcus
date: 2012-12-07T21:27:23+00:00
url: /2012/12/07/fedora-18-beta-on-thinkpad-t430s/
categories:
  - Uncategorized

---
I'm dreading this post. So much nice things have happened in free software over the last decade, that it is always a huge disappointment to me when I am thrown back into the seat of a new user and get a flash back to the horrible times of abysmal failures and sloppy engineering.

Let's get it over with as quickly as possible.

  * Linux kernel is struggeling with a desastrous SSD communication problem under workloads typical of database applications (such as the popular LAMP stack, so by no means anything extraordinary). This problem seemed to crop up in different hardware and software configurations over the last years. Not all COMRESET problems have the same cause, but clearly every single one of them is a serious concern if one expects reliable operation. [Kernel #43182][1].
  
    This is a major productivity killer, and enough to discredit the use of Linux, period.
  * The laptop spuriously wakes up from S3, without any apparent trigger. There is absolutely no indication why this is happening, and I don't even know where to start to debug this.
  
    After waking up unattendend, it of course drains the battery, and hibernates. From hibernation it can't resume correctly, because the systemd-cryptsetup thingie timed out waiting for the passphrase. The user is dropped into a rescue text terminal, from which the only way out is a reboot. Way to go!
  
    This is a major utility killer. A Laptop that doesn't sleep reliably is utterly disfunctional.
  * The sound and brightness control doesn't work when the screen is locked.
  * The microphone control doesn't work at all.
  * There is no on-screen-display for the caps lock key (arguably Lenovo should have given it an LED). There is a gnome-shell extension for it, but:
  * Gnome-shell still crashes to a blue screen under some situations, with no way out but a reboot. I suspect this had something to do with a package update and installing extensions in some order. Apparently, Gnome Shell developers have given up on updating software without a reboot, or at least making sure that updates don't break the running instance. Or probably never entertained such ideas at all.
  * Of course, Fedora has now made that official with their new concepts of &#8220;offline updates&#8221;. Of course, every package install that's not a menu-app is now considered to require an &#8220;offline update&#8221;, which means that every update is an offline update. That is possibly acceptable in the Mac universe, where updates are rare enough that they can be mostly ignored. It might even be acceptable in Windows land, where rebooting the system once in a while gives the busy office employee a rest from work. In a system that is shipped broken and that needs to be patched daily just to make it work, it&#8217;s ridiculous.
  * Oh yeah, I almost forgot: GNOME-SHELL IS LEAKING MEMORY LIKE A DONKEYS ARSE! In fact, it is leaking 1.5 MB on every popping up of its activity screen, merrily accumulating GBs of memory over the course of weeks. Good that I use the activity screen so rarely. Why does it even exist? Well, if it keeps the designers experiments from my desktop, it's well worth to keep it around.
  * gpointing-device-settings are not restored on restart. Why I even need that extra program I don't know. The settings should be available through the standard settings program.
  * Fedora has split the TeX packages into 1650 little packages, in order to allow users to install only those packages that they want. Yeah. I always wanted to micromanage my TeX installation. Luckily there are some meta-packages, but you have to dig a bit to find them (and then you are left blind because there is no list of what they contain). To save you some work: you want to install texlive-scheme-medium. Right. It's a scheme.
  * The graphical GRUB menu screen is dead slow. What is going on in the second between a key press and the response? Do I really want to know? It's great that we have so much developer time to waste that we can work on crap features like that. But it would be even nicer if the task were given to somebody who cared enough to make it work well.
  * Let's give some special mention to the worst bug report response of the last decade: [Fedora #855976][2]. With this attitude, the free software community is utterly screwed.

Of course, not all things are shittedyfuck. Usability of the Gnome Shell has improved noticably. I am also sure that a zillion things have improved that I will never notice, and some that I will notice.

 [1]: https://bugzilla.kernel.org/show_bug.cgi?id=43182
 [2]: https://bugzilla.redhat.com/show_bug.cgi?id=855976
---
title: Installing Fedora 16
author: Marcus
layout: post
date: 2012-02-02T16:05:50+00:00
url: /2012/02/02/installing-fedora-16/
categories:
  - Uncategorized

---
Random notes from installing Fedora 16, focussing on the negative things, because that is what is needed to make progress.

Installer failures:

  * The default ISO image is 32 bit, and one has to search for the 64 bit version. That's ridiculous.
  * There is no default option to install a RAID + Encryption + LVM configuration, so the custom partitioning method must be used.
  * There is no way to start with a degraded RAID, so a spare disk needs to be available as backup.
  * The custom method does not create a GPT disk label at least under some circumstances, leading to a disk that not only doesn't work, but even hangs up my AHCI BIOS detection routine.
  * This is particularly bad if the drive in question is known to hang up at BIOS POST (Seagate 7000.11) with a previous firmware. Chasing ghosts is no fun.
  * Although Fedora can not fix my BIOS, they can double check that the disk label and boot sector are OK. Truecrypt has very thorough consistency checks in their bootloader when using system encryption, going to the trouble of creating a rescue disk for restore. Fedora could do that, too.
  * The system does not come up because of a known bug in the installer. But the fix in the FAQ on the Fedora web site is incomplete and wrong.
  * The Fedora rescue system can't even mount the resulting mess, it has to be mounted and repaired manually.
  * Reinstalling over a failed install fails because the installer crashes when it sees the RAID it created.

GNOME Shell failures:

  * The GNOME shell crashed when I restored my home directory from a test install, for unknown reasons (because it does give no diagnostics, just an empathetic smile). I suspect SE Linux.
  * The default theme has many issues: The terminal font is too bright on a white background, the fonts are mediocre, the active window title not distinctive enough. In the Tree Style Tab plugin of firefox, the active tab has no highlight at all anymore (it used to in Gtk 2).
  * There is no way to change the theme (the selection box in gnome-tweak-tools is greyed out). An extension that is supposed to allow theme changes on extensions.gnome.org is not installable due to a version mismatch.
  * Everything is so bright, it's hurting my eyes. I&#8217;d love to use the darker theme that totem has on other windows, too.
  * I found out that ALT+Escape does something weird, it pops up black frames randomly across the screen, supposedly they should highlight application windows, but they are off by a fair amount.
  * The controls of gnome shell are not documented in the gnome-shell itself.
  * There is no way to remap the controls for gnome shell. I have a keyboard without a Windows key, so there is no way to get to the Activities screen with the keyboard.
  * gnome-tweak-tools has the ugliest splash screen I have seen in the last decade, but it still is a vital program that should be installed by default and widely advertised in the activities screen. Then make it pretty, please.
  * I could crash the gnome shell twice with the javascript console in 20 seconds, using 5 mouseclicks and 6 keypresses. Gratulations for making a safe language trivially unsafe. The second time it crashed, it brought down the entire session.
  * xbmc compiled and ran fine, then when quitting the program, the gnome shell and the session stuck. Only the mouse pointer moved, but there was no response to any input. I had to log in on the text console and kill the shell, so that it restarted itself.
  * I am too scared to try any extensions, but I know I will need them.

SE Linux failures:

  * Restoring a home directory from backup resulting in a gnome-shell crash. I suspect it's a SE Linux thing, because after restoring the original home dir (which I just moved out of the way) it worked again and there were a bunch of SE Linux related warnings for dbus, gconf etc.
  * Installing a proprietary printer driver from Samsung required manual patching up the installed files.
  * The troubleshoot messages come with &#8220;fix this problem&#8221; instructions that don't fix the problem.
  * Grepping for substrings in an audit log and then piping the result into a security policy manager. Srsly? LOL.

And&#8230;

  * Firefox sells my searches to Google.
  * Thunderbird spies on me at startup.
  * The installer asks me for confirmation if I don't want it to spy on my hardware profile. Aside from overwriting all disks, this is the only time it asks for confirmation. At least it defaults to no. How sad is it that we have to be thankful for that?

I might update this as as I find out more. Sadly, this was a lot of trouble.
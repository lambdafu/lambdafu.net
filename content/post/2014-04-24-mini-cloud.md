---
title: Virtualization Technologies
author: Marcus
layout: post
date: 2014-04-24T02:40:56+00:00
url: /2014/04/24/mini-cloud/
categories:
  - Programming
tags:
  - cloud
  - virtualization

---
Virtualization technology is moving fast, and what used to be hot yesterday is as cold as ice today. There is a lot of material to digest, and a lot of documentation that seems somewhat relevant but can be out of date. Surely, this blog post will suffer the same fate, but nevertheless, here it is: A quick list of the most relevant and up to date technology that I could find to set up a small cloud.

**KVM** provides low-level access to hardware virtualization.

**Virtio** provides I/O paravirtualization to grant guest systems faster, more direct access to host system peripherals.

**Qemu** has full support for KVM and virtio. As an extra bonus, it also supports legacy I/O virtualization as well as full system emulation (for example, running ARM systems on X86 hardware). It's the glue that binds things together to a complete virtualized machine (system board and peripherals).

**libvirtd** is daemon to manage virtual machine instances and the underlying storage and network devices. This is the productive level for actual user interaction (while the above are building blocks used only indirectly through the libvirtd interface). libvirtd uses policykit for access control. In addition to the CLI tool virsh, there are many other tools that build on libvirtd, some graphical, such as virt-manager.

For a small personal cloud, libvirtd with its basic tools, command line and graphical, may be all you need. Of course, enterprisey users may require more complete management interfaces such as OpenStack etc.

As for the operating system images, it is possible to install from scratch, but that is very old style. Today, most vendors provide OpenStack images in qcow2 format, which can also be used with various cloud providers, which can be very convenient to use. These are basically pre-installed systems with the cloud-init utility that runs at boot time and looks in various places for special configuration files. Beside fancy provisioning servers, it is possible to use a simple ISO image with meta-data.yml and user-data.yml files.

And there you have it, a blue print for your own personal cloud. Once you picked up these basic building blocks, understanding integrated solutions such as OpenStack should be much less confusing. Or at least that's what I am hoping.
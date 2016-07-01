---
title: HSDPA USB stick repair
author: Marcus
layout: post
date: 2012-02-27T00:42:34+00:00
url: /2012/02/27/hsdpa-usb-stick-repair/
categories:
  - Electronics
tags:
  - electronics
  - repair

---
I noticed a friend of mine used a clothespin to keep her USB surf stick working, so I suspected a broken solder joint. It was easy to fix, so here are some disassembling instructions for that particular HUAWEI Mobile Connect (Model E160) HSDPA USB stick. It's a real shame so much electronics is thrown away at the first sign of trouble, as quite a lot of it is actually repairable. Often it is a simple problem such as a broken solder joint due to mechanic stress or blown electrolytic caps due to wear. Happy hacking!

{{< figure src="/wp-content/gallery/hsdpa-repair/hsdpa-1.jpg" >}}

Time: 30 minutes

Tools: PH0x60 screw driver, soldering iron, solder

1. Remove the SIM card, open the case by lifting it at the outer edge and following around the bottom until the lid comes off.
{{< figure src="/wp-content/gallery/hsdpa-repair/hsdpa-2.jpg" >}}
2. Remove the little plastic cover at the end (2 screws), then remove the top circuit board (3 self-tapping screws and a black screw with blue loctite). The top board is connected to the other by a connector, but lifts straight off with just a litte force. Finally, unhook the black plastic spacer that covers the USB connector pins.
{{< figure src="/wp-content/gallery/hsdpa-repair/hsdpa-3.jpg" >}}
  3. On inspection, the USB connector was loose and one of its pins was lifted from its pad. Resoldering the pin and the little clamps (on both sides) fixed the loose connection and restabilized the USB plug. Using fine solder (0.5mm) for the pin is recommended, as there is not a lot of space to work in. Pay attention not to damage the various SMD parts nearby.
{{< figure src="/wp-content/gallery/hsdpa-repair/hsdpa-4.jpg" >}}
  4. Assemble in reverse of disassembly.
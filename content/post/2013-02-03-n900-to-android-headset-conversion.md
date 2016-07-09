---
title: N900 to HTC One X+ Headset Conversion
author: Marcus
date: 2013-02-03T16:56:25+00:00
url: /2013/02/03/n900-to-android-headset-conversion/
categories:
  - Electronics
tags:
  - android
  - electronics
  - headset
  - N900
  - repair

---

{{< figure src="/wp-content/uploads/2013/02/headset-conversion.jpg" >}}
  
The N900 smart phone has a nice in-ear headset, but it doesn't conform to current headset standards. However, headsets are incredibly simple and there is no reason to buy a new one just for such a simple compatibility problem. So here is what to do if you find yourself in this situation.

The N900 headset and the HTC One X+ headset have slightly different pin-outs:

  * The tip connects to the left speaker signal (L) on both devices.
  * The outer ring connects to the right speaker signal \(R) on both devices.
  * The middle ring connects to the microphone signal (M+) on the Nokia N900 headset and ground (GND=GL=GR=M-) on HTC One X+ devices.
  * The inner ring connects to ground (GL=GR=M-) on HTC One X+ devices and to the microphone signal (M+) on the Nokia N900 headset.

On either device, the microphone signal line is also the control line for the button. The way this works is that the button bypasses the microphone over a much smaller resistance, which is then detected by the device. Different resistance values can be used to implement different buttons. In this case, the N900 and HTC One X+ have both one button, but different resistors: 48 Ohm for the N900 and 0 Ohm for the HTC One X+ device.

To check that the headset you have follows the specification, measure resistance from GND to any other pin. It should be approximately 33 Ohm for L and R and approximately 2k Ohm for M+ if the button is not pushed. The resistance to M+ should drop to 48 Ohm if you push the button. If this is the case, you have a N900 headset that you can convert to an HTC One X+ headset following these instructions.

What you need:

  * multimeter that can measure resistance (Ohms)
  * soldering iron and solder
  * fine tweezer (e.g. for SMD soldering)
  * X-Acto knife (or similar tool for unhooking clips)

Steps:

From the above measurements, we can see that all we need to do is to exchange GND with M+ and reduce the 48 Ohm resistance to 0 Ohm.

  1. Pull off the rubber ends of the N900 remote.
  2. Remove the button of the remote by unhooking the side clips of the button. Lift the button and put it aside.
  3. Unhook the 2 clips at either side of the remote and lift off the cover, peeling off the sticky ring of foam between the cover and the mic.
  4. Unhook the PCB and lift it out of the bottom of the remote case. There is some glue protecting the contacts, which might stick to the case. Use the X-Acto knife to carefully separate the glue from the case while lifting the PCB.
  5. De-solder R1 from the button/mic-side of the PCB and replace it with a solder bridge (not shown in the picture). You want a 0 Ohm resistance across the push button.
  6. Lift the glue from the connectors at the back of the PCB, covering the cable towards the 3.5mm plug, as shown in the picture.
  7. Swap M- and M+ by de-soldering the cables, and holding them in place of their new position with the tweezer.
  8. De-solder GL and GR, and solder them on top of &#8220;M+&#8221; pad on the PCB (which is now connected to the cable that was M-).
  9. Create a solder bridge across M- and GR, and then use a piece of wire (that you hold down with your tweezer) to connect both pads to GL. You want all three pads connected to the cable that was M+ (but is now soldered to M-).
 10. Measure the plug to see if it now conforms to the HTC One X+ specification. Don't forget to test the button!
 11. Test the headset on an HTC One X+ phone, and also test it in a conventional 3.5mm stereo out (e.g. your notebook). It should work fine, and pushing the button should not have any effect on the sound quality in a conventional stereo out. If the sound is broken or the button press changes the sound quality, you have either miswired something or your soldering is bad. In this case, double-check every connection to make sure you picked the right wires, all connections are proper and there are nounintentional shorts.
 12. Reassemble everything and do a final test.
---
title: Testing Budget LEDs
author: Marcus
date: 2012-04-07T21:55:49+00:00
url: /2012/04/07/testing-budget-leds/
categories:
  - Electronics
tags:
  - borg16
  - das-labor
  - leds

---
I found a source for rather inexpensive crystal clear 10mm LEDs (easyseller24.de), which I want to use in the [Borg16][1] project. But how well do they fare, without a datasheet to rely on? Building a quick LED matrix plugged into the CNC routed board, I could compare them side-by-side. The colors orange, yellow and red are at around 2V, while the others are at around 3V, so they had to be tested in two groups. Both were driven with 10 Ohm resistors. Here you can see the result (you can click the picture for a larger version), and there are more pictures of the test setup in the gallery below:

{{< figure src="/wp-content/gallery/led-test/led-colors.jpg" >}}

The two lonely red LEDs at the lower right side are Kingbright brand LEDs (10mm red, clear), which are three times as expensive as the others, which are the following colors from the above mentioned shop: pink, blue, white, warm-white, green, orange, yellow, red. In general I can say that green is the brightest, followed by the white, blue and warm-white LEDs, leaving the pink far behind. The red-to-yellow tones are comparable in brightness, and especially the yellow and orange show a distinct center dot which is not very consistently manufactured. This is not necessarily a problem as there will be an opal acrylic sheet in front of them, which is emulated here by the plastic lid of an IKEA storage container.

{{< figure src="/wp-content/gallery/led-test/board-back.jpg" >}}
{{< figure src="/wp-content/gallery/led-test/board-front.jpg" >}}
{{< figure src="/wp-content/gallery/led-test/led-back-2.jpg" >}}
{{< figure src="/wp-content/gallery/led-test/led-back.jpg" >}}
{{< figure src="/wp-content/gallery/led-test/led-colors.jpg" >}}
{{< figure src="/wp-content/gallery/led-test/led-front.jpg" >}}

 [1]: http://das-labor.org/wiki/Borg16
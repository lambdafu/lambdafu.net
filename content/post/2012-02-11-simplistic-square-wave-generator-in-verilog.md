---
title: Simplistic Square Wave Generator in Verilog
author: Marcus
date: 2012-02-11T15:47:35+00:00
url: /2012/02/11/simplistic-square-wave-generator-in-verilog/
categories:
  - Uncategorized

---
Doodling around with electronics, I wanted to measure the frequency response of a simple capacitor-resistor circuit. It's easy to calculate, but usually there is a lot to learn from actually doing the experiment and dealing with the problems that pop up. The interesting part of the problem was actually how to create a driver for the input AC signal, as I don&#8217;t have a function generator here, and my analog circuit fu is not good enough to build one from scratch without help.

So I cheated using two hacks. First, I tried to drive a TBA-820M audio amp (vintage IC) in feedback mode. That worked fine, except that I couldn't get it to oscillate above 700 Hz, which does not cover enough of the spectrum.

The other idea was to generate a square wave using an FPGA development board I had lying around. In the end, this didn't work either. Although I could produce signals of a huge range of frequencies, the driver is far from ideal, and thus the frequency response of the circuit to be tested is distorted.

In any case, here is the simple circuit design for the FPGA chip in Verilog. First, I define the clock divider module that produces the desired output frequency by counting off a certain number of ticks from the input clock:

```
module clockdiv(input clk, input [24:0] ticks, output oclk);
  reg [24:0] tick = 0;
  reg dclk = 0;
  assign oclk = dclk;
  always @(posedge clk)  begin
    tick = tick + 1;
    if (tick >= ticks) begin
      tick = 0;
      dclk = ~dclk;
    end
  end
endmodule  
  
```

There are 16 different frequencies, ranging from 10 Hz to 50 kHz, and a push button can be used to cycle through them:

```
module mode_selector (input next, output [3:0] omode, output [24:0] oticks);
/* External clock frequency divided by two gives number of ticks per second.  */
parameter frequency = 27000000 / 2;

reg [3:0] mode = 0;
assign omode = mode;

reg [24:0] ticks = 0;
assign oticks = ticks;

always @(posedge next) mode = mode + 1;
always @(mode) begin
  case(mode)
  0: ticks = frequency / 10;
  1: ticks = frequency / 20;
  2: ticks = frequency / 30;
  3: ticks = frequency / 50;
  4: ticks = frequency / 100;
  5: ticks = frequency / 200;
  6: ticks = frequency / 300;
  7: ticks = frequency / 500;
  8: ticks = frequency / 1000;
  9: ticks = frequency / 2000;
  10: ticks = frequency / 3000;
  11: ticks = frequency / 5000;
  12: ticks = frequency / 10000;
  13: ticks = frequency / 20000;
  14: ticks = frequency / 30000;
  15: ticks = frequency / 50000;
  endcase
end
endmodule
```

A push button is directly connected to an input I/O pin of the microchip. Unfortunately, a push button bounces when pushed and thus the signal is not a clean on/off but a very rapid succession of on/off states. In other words, the push button needs to be debounced. There are many ways to do it, I followed a [simple approach][1]. When the button is activated, we signal the event and start a timer to count down from 100ms to zero. Only when the timer reaches zero we allow another event to be sent.

```
module button (input clk, input butin, output butout);
parameter timeout = 27000000 / 10; /* 100ms */
reg [31:0] counter;
initial counter = 0;
always @(posedge clk)
begin
    if(butin)
           counter = timeout;
    else if(counter > 0)
      counter = counter - 1;
end
wire down = counter != 0;
reg prev_down;
always @(posedge clk)
begin
  prev_down = down;
end
assign butout = down == 1 && prev_down == 0;
endmodule
  
```

Now we can pick up the pieces:

```
module main(input USER_CLOCK, input GPIO_BUTTON0, output GPIO_HDR0,
            output GPIO_LED_0, output GPIO_LED_1, output GPIO_LED_2, output GPIO_LED_3);
wire [24:0] ticks;
wire [3:0] mode;
assign GPIO_LED_0 = mode[0];
assign GPIO_LED_1 = mode[1];
assign GPIO_LED_2 = mode[2];
assign GPIO_LED_3 = mode[3];

wire butnext;
button butn (USER_CLOCK, GPIO_BUTTON0, butnext);
mode_selector msel(butnext, mode, ticks);
clockdiv slowclk (USER_CLOCK, ticks, GPIO_HDR0);
endmodule  
```

The four output LEDs are used to display the currently selected mode, very simple.

 [1]: http://objectmix.com/verilog/189666-help-switch-debouncing.html
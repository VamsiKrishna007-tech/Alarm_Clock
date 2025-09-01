Overview

What it does (brief): a 24-hour digital clock (HH:MM:SS) with an alarm.

You can load/set the current time and load/set an alarm time.

The clock runs in real seconds (derived from a fast board clock).

When current time == alarm time and the alarm is enabled, Alarm goes high and stays high until stopped.

High-level blocks:

Clock Divider — makes a 1 Hz tick.

Counters — seconds, minutes, hours.

Load logic — load current time and alarm time.

Comparator & Alarm control — raises and clears the alarm.

BCD digit extraction for display (tens/ones).


Signals (API)

Inputs

clk — fast input clock (e.g., 50 MHz).

reset — active high reset (clears counters & alarm).

H_in1 (MSB hour), H_in0 (LSB hour), M_in1, M_in0 — BCD/time-set inputs.

LD_time — load the current time from inputs.

LD_alarm — load the alarm time from inputs.

AL_ON — enable/disable alarm.

STOP_al — stop/silence the alarm.

Outputs

Alarm — high when alarm is ringing (latched until STOP_al).

H_out1, H_out0 — hour digits (tens, ones).

M_out1, M_out0 — minute digits.

S_out1, S_out0 — second digits.


1 — Clock Divider (make 1-second ticks)

Goal: convert fast board clock (e.g., 50 MHz) into a 1 Hz clock that pulses once per second.

Why: counters should increment once every real second — not every FPGA cycle.

Design idea (simple)

Count a fixed number of input clock cycles; when the count reaches half period toggle the slow clock.

For a 50 MHz input: 50,000,000 cycles = 1 second. So toggle every 25,000,000 cycles (half period).

Half period = 50,000,000 / 2 = 25,000,000.


2 — Time Counters (HH:MM:SS)

Goal: keep tmp_second, tmp_minute, tmp_hour updated every second (driven by clk_1s).

Storage sizes

Seconds: 0..59

Minutes: 0..59

Hours: 0..23


If LD_time is asserted → set hours, minutes from inputs; seconds = 0.

Else increment seconds. If seconds == 59 → seconds=0, increment minutes. If minutes==59 → minutes=0, increment hours. If hours==23 → hours=0.


3 — Digit Extraction (MOD-10 / tens and ones)

Goal: split seconds/minutes/hours numeric counters into digits for display: tens (most significant) and ones (least significant).


4 — Alarm Registers & Loading

Goal: store desired alarm time and allow the user to load it (via LD_alarm).

On reset: clear alarm registers to 0: alarm_hour=0, alarm_minute=0, alarm_second=0.

On LD_alarm: set alarm_hour = H_in1*10 + H_in0, alarm_minute = M_in1*10 + M_in0, alarm_second = 0.


5 — Alarm Comparator & Control

Goal: when current_time == alarm_time and AL_ON==1 → set Alarm = 1. Keep it high until STOP_al or reset.



6 — Reset Behavior

On reset (active high):

Set time to provided H_in/M_in (or zero — choose policy), seconds = 0.

Alarm registers clear.

clk_1s counter resets.

Alarm cleared.

------------------------------------------
input clock,

input reset,

input [1:0] H_in1,        // Input used to set MSB of Hour digit of the clock

input [2:0] H_in0,        // Input used to set LSB of Hour digit of the clock

input [3:0] M_in1,        // Input used to set MSB of Minute digit of the clock

input [3:0] M_in0,        // Input used to set LSB of Minute digit of the clock

input LD_time,            // If LD_time=1, clock time is set to input time
                          // If LD_time=0, clock time acts normally by incrementing every 10sec

input LD_alarm,           // If LD_alarm=1, alarm time is set to input time 
                          // If LD_alarm=0, alarm time acts normally

input STOP_alarm,         // If STOP_alarm is high, then it will bring Alarm_ON to low

input Alarm_ON,           // If alarm time is equal to current time, Alarm_ON is high then alarm will ring

output reg Alarm,             // Alarm goes high if Alarm_ON is high and remains high untill STOP_alarm is high        
           
output [1:0] H_out1,      // Output used to represent MSB of Hour digit of the clock

output [2:0] H_out0,      // Output used to represent LSB of Hour digit of the clock

output [3:0] M_out1,      // Output used to represent MSB of Minute digit of the clock

output [3:0] M_out0,      // Output used to represent LSB of Minute digit of the clock

output [3:0] S_out1,      // Output used to represent MSB of Seconds digit of the clock

output [3:0] S_out0       // Output used to represent LSB of Seconds digit of the clock
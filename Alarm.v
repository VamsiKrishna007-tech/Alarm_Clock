module alarm_clock (
input clock,
input reset,
input [1:0] H_in1;        // Input used to set MSB of Hour digit of the clock
input [2:0] H_in0;        // Input used to set LSB of Hour digit of the clock
input [3:0] M_in1;        // Input used to set MSB of Minute digit of the clock
input [3:0] M_in0;        // Input used to set LSB of Minute digit of the clock
input LD_time;            // If LD_time=1, clock time is set to input time
                          // If LD_time=0, clock time acts normally by incrementing every 10sec
input LD_alarm;           // If LD_alarm=1, alarm time is set to input time 
                          // If LD_alarm=0, alarm time acts normally
input STOP_alarm;         // If STOP_alarm is high, then it will bring Alarm_ON to low
input Alarm_ON;           // If alarm time is equal to current time, Alarm_ON is high then alarm will ring
output Alarm;             // Alarm goes high if Alarm_ON is high and remains high untill STOP_alarm is high                   
output [1:0] H_out1;      // Output used to represent MSB of Hour digit of the clock
output [2:0] H_out0;      // Output used to represent LSB of Hour digit of the clock
output [3:0] M_out1;      // Output used to represent MSB of Minute digit of the clock
output [3:0] M_out0;      // Output used to represent LSB of Minute digit of the clock
output [3:0] S_out1;      // Output used to represent MSB of Seconds digit of the clock
output [3:0] S_out0       // Output used to represent LSB of Seconds digit of the clock
);

// Temparary Variables
reg [5:0] temp_hour, temp_minute, temp_second;
reg [1:0] c_hour1, a_hour1;
reg [3:0] c_hour0, a_hour0;
reg [3:0] c_minute1, a_minute0;
reg [3:0] c_minute0, a_minute0;
reg [3:0] c_second1, a_second1;
reg [3:0] c_second0, a_second0;

// 1sec clock from 10Hz input clock
always @(posedge clock or posedge reset)
if (reset)
begin 
 temp_1s <= 0;
 clock_1s <= 0;
end
else
begin
 temp_1s <= temp_1s + 1;
 if (temp_1s <= 5)
  clock_1s <= 0;
 else if (temp_1s >= 10)  begin
  clock_1s <= 1;
  temp_1s <= 0;
 end
 else
  clock_1s <= 1;
 end
end




// Function used to take Modules of a number
function [3:0] Mod_10;
input [5:0] number;
begin
 Mod_10 = (number>=50)? 5: ((number>=40)? 4: ((number>=30)? 3 :((number>=20)? 2 :(number>=10)? 1 :0))));
end
endfunction

//Setting and Disabling Alarm:
// if clock time and alarm time are same & if alarm is turned on then alarm rings untill it is stopped.
always @(posedge clock)
begin
if (reset)
 Alarm <= 0;
else
 begin
  if ({a_hour1,a_hour0,a_minute1,a_minute0,a_second1,a_second0} == {c_hour1,c_hour0,c_minute1,c_minute0,c_second1,c_second0})
   begin
    if(Alarm_ON == 1)
	 Alarm = 1;
	else if(STOP_alarm == 1)
	 Alarm = 0;
   end
 end
end




always @(posedge clock or posedge reset)  // Asynchronous Reset
begin
 if (reset)
  begin
    
    temp_hour <= H_in1*10 + H_in0;
	temp_minute <= M_in1*10 + M_in0;
	temp_second <= 0;
	

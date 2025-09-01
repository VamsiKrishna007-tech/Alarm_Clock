module alarm_clock (
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
);
integer temp_1s;
reg clock_1s;
parameter clock_freq = 10;
parameter target_freq = 1;

// Temparary Variables
reg [5:0] temp_hour, temp_minute, temp_second;
reg [1:0] c_hour1, a_hour1;
reg [3:0] c_hour0, a_hour0;
reg [3:0] c_minute1, a_minute1;
reg [3:0] c_minute0, a_minute0;
reg [3:0] c_second1, a_second1;
reg [3:0] c_second0, a_second0;

// Clock divider
localparam integer count_max = (clock_freq / (2*target_freq))-1;
always @(posedge clock or posedge reset)
if (reset)
begin 
 temp_1s <= 0;
 clock_1s <= 0;
end
else
begin
 if (temp_1s >= count_max) begin  
  temp_1s <= 0; 
  clock_1s <= ~clock_1s;
 end
 else 
  begin
  temp_1s <= temp_1s + 1;
  end
 end

//Setting and Disabling Alarm:
// if clock time and alarm time are same & if alarm is turned on then alarm rings untill it is stopped.
always @(posedge clock_1s or posedge reset)
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


//  Alarm Registers and Loading
always @(posedge clock_1s or posedge reset)
begin
if (reset)                             // Reset Clock & Alarm
 begin
 a_hour1 = 2'b00;
 a_hour0 = 4'b0000;
 a_minute1 = 4'b0000; 
 a_minute0 = 4'b0000;
 a_second1 = 4'b0000;
 a_second0 = 4'b0000;
 temp_hour <= H_in1*10 + H_in0;
 temp_minute <= M_in1*10 + M_in0;
 temp_second <= 0;
 end
else begin
 if (LD_alarm)begin                    // Set Alarm
 a_hour1 <= H_in1;
 a_hour0 <= H_in0;
 a_minute1 <= M_in1;
 a_minute0 <= M_in0;
 a_second1 <= 4'b0000;
 a_second0 <= 4'b0000;
 end
 if (LD_time)begin                     // Set Time
 temp_hour <= H_in1*10 + H_in0;
 temp_minute <= M_in1*10 + M_in0;
 temp_second <= 0;
 end
 else begin                            // Increment Time
 temp_second <= temp_second + 1;
  if(temp_second >= 59) begin
   temp_minute <= temp_minute + 1;
   temp_second <= 0;
  if(temp_minute >= 59) begin
   temp_hour <= temp_hour + 1;
   temp_minute <= 0;
  if(temp_hour >= 24) begin
   temp_hour <= 0;
  end
  end
  end
 end
end
end 
   
// Function used to take Modules of a number( will be used while displaying clock time)
function [3:0] Mod_10;
input [5:0] number;
begin
 Mod_10 = number / 10;
end
endfunction


// Set Clock
always @(*) begin
c_hour1 = Mod_10(temp_hour);
c_hour0 = temp_hour - c_hour1*10;
c_minute1 = Mod_10(temp_minute);
c_minute0 = temp_minute - c_minute1*10;
c_second1 = Mod_10(temp_second);
c_second0 = temp_second - c_second1*10;
end

// output
assign H_out1 = c_hour1;
assign H_out0 = c_hour0;
assign M_out1 = c_minute1;
assign M_out0 = c_minute0;
assign S_out1 = c_second1;
assign S_out0 = c_second0;

endmodule

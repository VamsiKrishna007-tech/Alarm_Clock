`timescale 1ns / 1ps

module Alarm_tb();

// Variables for Test Bench
reg clock;
reg reset;
reg [1:0] H_in1;        
reg [2:0] H_in0;        
reg [3:0] M_in1;        
reg [3:0] M_in0;        
reg LD_time;            
reg LD_alarm;           
reg STOP_alarm;         
reg Alarm_ON;           

wire Alarm;                                
wire [1:0] H_out1;      
wire [2:0] H_out0;      
wire [3:0] M_out1;      
wire [3:0] M_out0;      
wire [3:0] S_out1;      
wire [3:0] S_out0;      

// Instantiate DUT (Device Under Test)
alarm_clock uut (
    .clock(clock),
    .reset(reset),
    .H_in1(H_in1),
    .H_in0(H_in0),
    .M_in1(M_in1),
    .M_in0(M_in0),
    .LD_time(LD_time),
    .LD_alarm(LD_alarm),
    .STOP_alarm(STOP_alarm),
    .Alarm_ON(Alarm_ON),
    .Alarm(Alarm),
    .H_out1(H_out1),
    .H_out0(H_out0),
    .M_out1(M_out1),
    .M_out0(M_out0),
    .S_out1(S_out1),
    .S_out0(S_out0)
);

// Clock Generation: 10ns period => 100MHz
always #5 clock = ~clock;

// Test sequence
initial begin
    // Initialize inputs
    clock      = 0;
    reset      = 1;
    H_in1      = 0;
    H_in0      = 0;
    M_in1      = 0;
    M_in0      = 0;
    LD_time    = 0;
    LD_alarm   = 0;
    STOP_alarm = 0;
    Alarm_ON   = 0;

    // Apply reset
    #20 reset = 0;

    // Load initial time: 06:59:00
    H_in1   = 0;  // MSB hour
    H_in0   = 6;  // LSB hour
    M_in1   = 5;  // MSB min
    M_in0   = 9;  // LSB min
    LD_time = 1;
    #10 LD_time = 0;

    // Load alarm time: 07:00:00
    H_in1   = 0;
    H_in0   = 7;
    M_in1   = 0;
    M_in0   = 0;
    LD_alarm = 1;
    #10 LD_alarm = 0;

    // Enable alarm
    Alarm_ON = 1;

    // Wait for 70 simulated seconds (clock will tick)
    #1000;

    // Stop the alarm
    STOP_alarm = 1;
    #10 STOP_alarm = 0;

    // Finish simulation
    #200 $stop;
end

endmodule

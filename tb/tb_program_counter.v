/* The first code is called the physical design code, and this code, is called testbench
A testbench is a set of specified codes which acts as a virtual lab for the hardware, and it's testing the circuit in the computer instead of real hardware
This helps us understand what we do irl while in software, so that if there is any misfiring, we can correct it right away !!
A testbench is strictly for simulation
*/
`timescale 1ns / 1ps
//here we redefine the created module for the refrences, but in different format
/* module name
decleration
assingation 
initilization of the testbench
endmodule
*/
module tb_program_counter;
    reg clk; // a reg is shortform for register, all the clock reset and all those, which are in the always stuff, need to be for sure in this reg only, and now wire
    reg rst; 
    wire [31:0] pc_next; // wire is simply a transport for the output to a place, any assign or any output must be in this wire only
    wire [31:0] pc;
    //now we configure this testbench to that of the actual code 
    program_counter uut ( .clk(clk), .rst(rst), .pc_next(pc_next), .pc(pc) );// uut means unit under test, this way it will know that we are testing for this one 
    //here we assign the initial stuff like clock and the next address 
    assign pc_next = pc + 32'd4; //Since RSIC-V is 32 bit long, it has to just 4 bytes (32 bits) every time for a new instruction
    always #5 clk = ~clk; // #5 means with for 5 nanoseconds (nanoseconds cause, we defined it as 1ns), and every 5ns shift the pulse 
    // This is the begining of the test benck.
    initial begin //twist ye hai ki, always runs every time the code is on, but initial runs exactly ONCE 
        //bhai these are the special names to tell our Mr. Icarus Verilog to record all the signals and save them in that waveform.vcd file. That .vcd file is for GTKWave sir to read later 
        $dumpfile("waveform.vcd"); 
        $dumpvars(0, tb_program_counter);
        clk = 0;//set clock to 0
        rst = 1;//set reset to 1
        #15; //wait for 15ns 
        rst = 0;//afater 15ns set reset to 0
        #80;//wait 80ns
        rst = 1; // after 80ns set reset to 1
        #10;//wait 10ns
        rst = 0; //after 10ns again reset reset to 0
        #20;//last and final 20 ns of the program
        $finish; //katam, over it's stops
    end
    initial begin
        $monitor("Time=%0t | rst=%b | pc=%h | pc_next=%h", $time, rst, pc, pc_next);// same as printf in C and cout in C++ and print in python 
    end
endmodule
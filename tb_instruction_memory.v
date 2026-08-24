`timescale 1ns / 1ps
module tb_instruction_memory;
    // Reg is used because we manually drive the input address in initial blocks
    reg  [31:0] addr; 
    // Wire is used to catch the output instruction coming out of the module
    wire [31:0] instruction;
    // Connect our testbench signals to the Instruction Memory hardware module
    instruction_memory uut ( .addr(addr), .instruction(instruction) );
    initial begin
        // Save the electrical signals for GTKWave
        $dumpfile("waveform_im.vcd");
        $dumpvars(0, tb_instruction_memory);
        // Fetch Instruction 0 (at byte address 0)
        addr = 32'd0;
        #10; // Wait 10ns
        // Fetch Instruction 1 (at byte address 4)
        addr = 32'd4;
        #10; // Wait 10ns
        // Fetch Instruction 2 (at byte address 8)
        addr = 32'd8;
        #10; // Wait 10ns
        // Fetch Instruction 3 (at byte address 12)
        addr = 32'd12; 
        #10; // Wait 10ns
        // Stop the simulation
        $finish; // Bye bye
    end
    // Print values to the console whenever the address or instruction changes
    initial begin
        $monitor("Time=%0t | Address=%d (0x%h) | Instruction=0x%h", $time, addr, addr, instruction);
    end
endmodule
// Same time scale, and it has to be common in all the codes without fail
`timescale 1ns / 1ps
/* 
An instruction memory is the acting ROM and it does the following
    Whenever the PC outputs an address, this IM recieves the address, and then it looks inside the memory array and immediately splits it out into 32 bit instructions for the processor to decode.
This instruction memory works as follows, will be said in the codes
*/  
module instruction_memory ( input wire [31:0] addr, output wire [31:0] instruction );
    reg [31:0] memory [0:63]; // This is a array of 64 words, with 32 bits each !! (a word is a memory brew......)
    // This part we are going to do addition
    initial begin 
        memory[0] = 32'h00500113; // addi x2, x0, 5 (Add immediately, and put 5 into the register x2)
        memory[1] = 32'h00700193; // addi x3, x0, 7 (same as before, put value 7 into x3)
        memory[2] = 32'h00310233; // add  x4, x2, x3 (Here add x2 and x4, and store it in x3)
        memory[3] = 32'h00000013; // nop (Basically do nothing)
    end
    assign instruction = memory[addr[31:2]]; // This part I know very well
    /*
    A memory address works as following
    
    Byte address 0  = Instruction 0
    Byte address 4  = Instruction 1
    Byte address 8  = Instruction 2
    Byte address 12 = Instruction 3
    
    In binary, multiples of 4 always end in 00:
    
    0 in binary  = ...000000
    4 in binary  = ...000100
    8 in binary  = ...001000
    12 in binary = ...001100
    
    Since the last is always ending with 00, we can strip the last two bits to get the following
    In binary, dropping the last two bits ([31:2]) is the exact same thing as dividing by 4:
    Address 0 (binary 0000) -> slice off last 2 bits -> Index 0 -> memory[0]
    Address 4 (binary 0100) -> slice off last 2 bits -> Index 1 -> memory[1]
    Address 8 (binary 1000) -> slice off last 2 bits -> Index 2 -> memory[2]
    Address 12 (binary 1100) -> slice off last 2 bits -> Index 3 -> memory[3]
    */
endmodule
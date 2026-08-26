// same timescale
`timescale 1ns / 1ps
// Hardware module for RISC-V Instruction ROM preloaded with full test program
module instruction_memory (
    // 32-bit address input coming directly from Program Counter
    input  wire [31:0] addr,
    // 32-bit machine code instruction output sent to Decoder
    output wire [31:0] instruction
);
    // Array of 64 words with 32 bits each acting as ROM storage
    reg [31:0] memory [0:63];
    // Initial block to preload test assembly program in machine hex
    initial begin
        // Index 0 (Address 0x00): addi x1, x0, 10 (Load 10 into register x1)
        memory[0] = 32'h00a00093;
        // Index 1 (Address 0x04): addi x2, x0, 20 (Load 20 into register x2)
        memory[1] = 32'h01400113;
        // Index 2 (Address 0x08): add x3, x1, x2 (Calculate 10 + 20 = 30 and save in x3)
        memory[2] = 32'h002081b3;
        // Index 3 (Address 0x0C): sw x3, 0(x0) (Store value 30 from x3 into RAM address 0)
        memory[3] = 32'h00302023;
        // Index 4 (Address 0x10): lw x4, 0(x0) (Load value 30 from RAM address 0 into register x4)
        memory[4] = 32'h00002203;
        // Index 5 (Address 0x14): beq x3, x4, 8 (Since x3 == x4 == 30, branch ahead by 8 bytes to 0x1C)
        memory[5] = 32'h00418463;
        // Index 6 (Address 0x18): addi x5, x0, 99 (Must be SKIPPED by the branch, so x5 stays 0)
        memory[6] = 32'h06300293;
        // Index 7 (Address 0x1C): addi x6, x0, 42 (Branch landing target, loads 42 into register x6)
        memory[7] = 32'h02a00313;
    end
    // Combinational read slicing off bottom 2 bits to convert byte address into word index
    assign instruction = memory[addr[31:2]];
endmodule
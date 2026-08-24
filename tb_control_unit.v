// Same timescale
`timescale 1ns / 1ps
// Testbench module for verifying Control Unit decoding
module tb_control_unit;
    // Testbench registers driving control unit inputs
    reg  [6:0] opcode;      // Register driving instruction opcode
    reg  [2:0] funct3;      // Register driving instruction funct3
    reg  [6:0] funct7;      // Register driving instruction funct7
    // Testbench wires capturing decoded control outputs
    wire       reg_write;   // Wire capturing register write enable
    wire       alu_src;     // Wire capturing ALU source multiplexer signal
    wire       mem_read;    // Wire capturing data memory read enable
    wire       mem_write;   // Wire capturing data memory write enable
    wire       mem_to_reg;  // Wire capturing memory to register multiplexer signal
    wire       branch;      // Wire capturing branch decision flag
    wire [3:0] alu_control; // Wire capturing 4-bit ALU control code
    // Instantiate unit under test
    control_unit uut (
        .opcode(opcode),           // Connect opcode port
        .funct3(funct3),           // Connect funct3 port
        .funct7(funct7),           // Connect funct7 port
        .reg_write(reg_write),     // Connect reg_write port
        .alu_src(alu_src),         // Connect alu_src port
        .mem_read(mem_read),       // Connect mem_read port
        .mem_write(mem_write),     // Connect mem_write port
        .mem_to_reg(mem_to_reg),   // Connect mem_to_reg port
        .branch(branch),           // Connect branch port
        .alu_control(alu_control)  // Connect alu_control port
    );
    // Initial procedural block executing test stimuli
    initial begin
        // Configure waveform dump file for GTKWave
        $dumpfile("waveform_cu.vcd");
        // Dump all signals in testbench scope
        $dumpvars(0, tb_control_unit);
        // Test 1: R-Type ADD instruction (opcode=0110011, funct3=000, funct7=0000000)
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        // Test 2: R-Type SUB instruction (opcode=0110011, funct3=000, funct7=0100000)
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;
        // Test 3: I-Type ADDI instruction (opcode=0010011, funct3=000, funct7=0000000)
        opcode = 7'b0010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        // Test 4: Load Word (LW) instruction (opcode=0000011, funct3=010, funct7=0000000)
        opcode = 7'b0000011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;
        // Test 5: Store Word (SW) instruction (opcode=0100011, funct3=010, funct7=0000000)
        opcode = 7'b0100011;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #10;
        // Test 6: Branch Equal (BEQ) instruction (opcode=1100011, funct3=000, funct7=0000000)
        opcode = 7'b1100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        // Terminate simulation
        $finish;
    end
    // Monitor block for logging decoding results to terminal
    initial begin
        // Display signal values on each transition
        $monitor("Time=%0t | Op=0x%h | RegW=%b | ALUSrc=%b | MemR=%b | MemW=%b | Mem2Reg=%b | Branch=%b | ALUCtrl=%b",
                 $time, opcode, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_control);
    end
endmodule
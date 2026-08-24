// same timescale
`timescale 1ns / 1ps
// Testbench module to execute complete program on RV32I core
module tb_riscv_core;
    // Clock and reset driving registers
    reg         clk;
    reg         rst;
    // Top-level observation wires
    wire [31:0] pc_out;
    wire [31:0] alu_result_out;
    // Instantiate full top-level processor core
    riscv_core uut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .alu_result_out(alu_result_out)
    );
    // Generate continuous clock with 10ns period (100 MHz equivalent)
    always #5 clk = ~clk;
    // Stimulus block running the full program execution
    initial begin
        // Configure VCD dump file for GTKWave
        $dumpfile("waveform_core.vcd");
        // Dump all signals in hierarchy
        $dumpvars(0, tb_riscv_core);
        // Initialize clock and assert reset
        clk = 0;
        rst = 1;
        // Hold reset for 10ns
        #10;
        // Deassert reset to begin program execution
        rst = 0;
        // Run processor for 100ns to allow full program execution
        #100;
        // Terminate simulation
        $finish;
    end
    // Terminal monitor block logging processor register state on clock edges
    initial begin
        $monitor("Time=%0t | PC=0x%h | Inst=0x%h | ALU_Res=%0d | x1=%0d | x2=%0d | x3=%0d | x4=%0d | x5=%0d | x6=%0d",
                 $time, 
                 uut.pc_current, 
                 uut.instruction, 
                 uut.alu_result,
                 uut.rf_unit.registers[1], 
                 uut.rf_unit.registers[2], 
                 uut.rf_unit.registers[3], 
                 uut.rf_unit.registers[4], 
                 uut.rf_unit.registers[5], 
                 uut.rf_unit.registers[6]);
    end
endmodule
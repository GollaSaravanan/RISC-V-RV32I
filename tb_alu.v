// Same time
`timescale 1ns / 1ps
// Testbench module for verifying ALU operations
module tb_alu;
    // 32-bit register signal to drive operand A
    reg  [31:0] a;
    // 32-bit register signal to drive operand B
    reg  [31:0] b;
    // 4-bit register signal to drive ALU operation selector
    reg  [3:0]  alu_control;
    // 32-bit wire to capture the calculated ALU output
    wire [31:0] result;
    // 1-bit wire to capture the zero flag status
    wire        zero;
    // Signed wire declaration to display negative integers cleanly in decimal
    wire signed [31:0] signed_result;
    // Continuous assignment connecting unsigned wire to signed wire
    assign signed_result = result;
    // Instantiation of the ALU module under test
    alu uut (
        // Hook up testbench operand a to module input a
        .a(a),
        // Hook up testbench operand b to module input b
        .b(b),
        // Hook up testbench control code to module input alu_control
        .alu_control(alu_control),
        // Hook up module result output to testbench wire result
        .result(result),
        // Hook up module zero output to testbench wire zero
        .zero(zero)
    );
    // Initial procedural block containing simulation stimulus sequence
    initial begin
        // Configure VCD dump file name for GTKWave
        $dumpfile("waveform_alu.vcd");
        // Dump all signals in this testbench scope
        $dumpvars(0, tb_alu);
        // Test 1: Test addition with 15 + 10 = 25
        a = 32'd15;
        b = 32'd10;
        alu_control = 4'b0000;
        // Wait 10 simulation time units
        #10;
        // Test 2: Test subtraction with equal values 20 - 20 = 0 to trigger zero flag
        a = 32'd20;
        b = 32'd20;
        alu_control = 4'b0001;
        // Wait 10 simulation time units
        #10;
        // Test 3: Test bitwise AND with hex masks
        a = 32'h0000000F;
        b = 32'h00000007;
        alu_control = 4'b0010;
        // Wait 10 simulation time units
        #10;
        // Test 4: Test bitwise OR with hex values
        a = 32'h000000F0;
        b = 32'h0000000F;
        alu_control = 4'b0011;
        // Wait 10 simulation time units
        #10;
        // Test 5: Test shift left logical by shifting 1 left by 3 bits
        a = 32'd1;
        b = 32'd3;
        alu_control = 4'b0101;
        // Wait 10 simulation time units
        #10;
        // Test 6: Test arithmetic right shift preserving negative sign on -16 shifted by 2
        a = -32'd16;
        b = 32'd2;
        alu_control = 4'b0111;
        // Wait 10 simulation time units
        #10;
        // Test 7: Test signed set less than where -10 is less than 5
        a = -32'd10;
        b = 32'd5;
        alu_control = 4'b1000;
        // Wait 10 simulation time units
        #10;
        // Test 8: Test unsigned set less than where negative bit pattern evaluates as large unsigned magnitude
        a = -32'd10;
        b = 32'd5;
        alu_control = 4'b1001;
        // Wait 10 simulation time units
        #10;
        // Terminate the simulation
        $finish;
    end
    // Initial block for logging console output during simulation run
    initial begin
        // Print header and variable values whenever monitored signals change
        $monitor("Time=%0t | Ctrl=%b | A=%0d (0x%h) | B=%0d (0x%h) | Result=%0d (0x%h) | Zero=%b",
                 $time, alu_control, a, a, b, b, signed_result, result, zero);
    end
endmodule
// Same timings
`timescale 1ns / 1ps
module tb_register_file;
    reg         clk;
    reg         rst;
    reg         reg_write;
    reg  [4:0]  rs1_addr;
    reg  [4:0]  rs2_addr;
    reg  [4:0]  rd_addr;
    reg  [31:0] rd_data;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    register_file uut (.clk(clk), .rst(rst), .reg_write(reg_write), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr), .rd_data(rd_data), .rs1_data(rs1_data), .rs2_data(rs2_data) );
    always #5 clk = ~clk; // As before making a pulsating clock every 5ns
    initial begin
        // Creating files for the GTK
        $dumpfile("waveform_rf.vcd");
        $dumpvars(0, tb_register_file);
        // Initial config
        clk = 0;
        rst = 1;
        reg_write = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        rd_data = 0;
        #10;
        rst = 0;
        // Test 1: Write 42 into register x1
        #10;// Wait 10 ns
        reg_write = 1; // setting write enbling
        rd_addr = 5'd1; // This is the addr of the register.
        rd_data = 32'd42; // the data to be stored inside the register 
        // Test 2: Write 99 into register x2
        #10;// Wait 10 ns
        rd_addr = 5'd2; // This is the addr of the register.
        rd_data = 32'd99; // the data to be stored inside the register 
        // Test 3: Attempt to write 123 into x0 (Must fail / stay 0)
        #10;// Wait 10 ns
        rd_addr = 5'd0; // This is the addr of the register, but here, there is a catch, the address is x0, where it shouldn't write !!
        rd_data = 32'd123; // Failed !!
        // Test 4: Disable write, read x1 on Port 1 and x2 on Port 2
        #10;// Wait 10 ns
        reg_write = 0; // Write is now disabled
        rs1_addr = 5'd1; // This is the addr of the register, but we are going to read it !!
        rs2_addr = 5'd2;
        // Test 5: Read x0 on Port 1 (Should output 0)
        #10;// Wait 10 ns
        rs1_addr = 5'd0;
        #20;// Wait 20 ns
        $finish;//Tata 
    end
    initial begin
        // Update in the GTK
        $monitor("Time=%0t | rst=%b | we=%b | rd=x%0d (Data=%0d) | rs1=x%0d (Val=%0d) | rs2=x%0d (Val=%0d)",
                 $time, rst, reg_write, rd_addr, rd_data, rs1_addr, rs1_data, rs2_addr, rs2_data);
    end
endmodule
// same time
`timescale 1ns / 1ps
// Testbench module for verifying Data Memory operations
module tb_data_memory;
    // Testbench register driving clock signal
    reg        clk;
    // Testbench register driving reset signal
    reg        rst;
    // Testbench register driving memory write enable
    reg        mem_write;
    // Testbench register driving memory read enable
    reg        mem_read;
    // Testbench register driving memory address
    reg  [31:0] addr;
    // Testbench register driving data to be written
    reg  [31:0] write_data;
    // Testbench wire capturing loaded data output
    wire [31:0] read_data;
    // Unit under test instantiation
    data_memory uut (
        // Connect clock port
        .clk(clk),
        // Connect reset port
        .rst(rst),
        // Connect write enable port
        .mem_write(mem_write),
        // Connect read enable port
        .mem_read(mem_read),
        // Connect address port
        .addr(addr),
        // Connect write data port
        .write_data(write_data),
        // Connect read data port
        .read_data(read_data)
    );
    // Generate continuous clock pulse every 5ns
    always #5 clk = ~clk;
    // Stimulus initial block
    initial begin
        // Configure waveform dump file for GTKWave
        $dumpfile("waveform_dm.vcd");
        // Dump all testbench variables
        $dumpvars(0, tb_data_memory);
        // Initialize control signals
        clk = 0;
        rst = 1;
        mem_write = 0;
        mem_read = 0;
        addr = 32'd0;
        write_data = 32'd0;
        // Wait 10ns for reset to take effect
        #10;
        // Release reset
        rst = 0;
        // Test 1: Store word 0xDEADBEEF at byte address 0 (word index 0)
        #10;
        mem_write = 1;
        mem_read = 0;
        addr = 32'd0;
        write_data = 32'hDEADBEEF;
        // Test 2: Store word 0x12345678 at byte address 4 (word index 1)
        #10;
        addr = 32'd4;
        write_data = 32'h12345678;
        // Test 3: Disable write and read back data from byte address 0
        #10;
        mem_write = 0;
        mem_read = 1;
        addr = 32'd0;
        // Test 4: Read back data from byte address 4
        #10;
        addr = 32'd4;
        // Test 5: Disable read enable to verify output zeroes out
        #10;
        mem_read = 0;
        // Finish simulation
        #10;
        $finish;
    end
    // Monitor block for terminal logging
    initial begin
        // Display memory activity across time steps
        $monitor("Time=%0t | rst=%b | we=%b | re=%b | Addr=0x%h | WData=0x%h | RData=0x%h",
                 $time, rst, mem_write, mem_read, addr, write_data, read_data);
    end
endmodule
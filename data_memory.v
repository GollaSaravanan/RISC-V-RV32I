// Same time
`timescale 1ns / 1ps
// Hardware module for single-cycle RV32I Data Memory
module data_memory (
    input  wire        clk,        // Clock signal for synchronous write operations
    input  wire        rst,        // Active high reset to clear memory contents
    input  wire        mem_write,  // Write enable control signal for store instructions
    input  wire        mem_read,   // Read enable control signal for load instructions
    input  wire [31:0] addr,       // 32-bit memory address calculated by ALU
    input  wire [31:0] write_data, // 32-bit data to store into memory from rs2
    output wire [31:0] read_data   // 32-bit data loaded from memory to destination register
);
    // Declare internal RAM array of 64 words each 32 bits wide
    reg [31:0] memory [0:63];
    // Integer loop variable for reset initialization
    integer i;
    // Asynchronous read logic returning word when read enable is high
    assign read_data = (mem_read) ? memory[addr[31:2]] : 32'd0;
    // Synchronous write block triggering on rising clock edge
    always @(posedge clk) begin
        // Check if synchronous reset is active
        if (rst) begin
            // Iterate through all 64 memory locations
            for (i = 0; i < 64; i = i + 1) begin
                // Clear memory location to zero
                memory[i] <= 32'd0;
            end
        // Write data if write enable is active
        end else if (mem_write) begin
            // Store 32-bit word using upper address bits as word index
            memory[addr[31:2]] <= write_data;
        end
    end
endmodule
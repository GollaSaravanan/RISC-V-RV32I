// Same time
`timescale 1ns / 1ps
/*
A register file is a file, bot file, which processes high speed trains and flights which come as memory. 
In this RISC V it holds 32 addresses from x0 to x31
where wach one stores 32 bit values 
Some rules which are ment to follow:
1. All those 32 registers need 5 bit addressing (cause 2^5=32 man)
2. Reading in ALU is done by 2 ports, namely rs1 and rs2 and HAS TO GIVE OUTPUT BEFORE THE CLOCK EDGE ENDS
3. Writing data needs just 1 register (rd), not 2, and it's done during the RISING CLOCK EDGE ONLY when Write enable is active (reg_write)  
4.  Most cringest but the most important, by chance you try to write into the x0 (which holds 0x00000000), IT DOES NOTHING. Reading this x0 returns a clean duck !!
*/
module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        reg_write,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
); // Ik look like many, but aren't those much
    reg [31:0] registers [0:31];
    integer i; // This integer i is for that for loop things !!
    // Asynchronous / Combinational Reads 
    //  Basically what we do is as follows, this doesn't need a clock tick, and thus we check if the rs1 and rs2 addr is 0, if so we put the data as 0 else, we put the data present in the addr 
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : registers[rs1_addr]; // As we knoe that ? is that ternary operator
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : registers[rs2_addr];
    // Synchronous Writes on Clock Edge 
    /* Bro I'm not someone who likes to use corrupt values, so we do the following operations during a clock cycle !!
    We are going to permanently write into the register, so we use the clock edges
    */
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0; // In this loop we are going to set all the register's values to 0
            end
        end else if (reg_write && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= rd_data; // If it's not 0, then we write, IF AND ONLY IF, the reg_write is true and the rd_addr is not 0
        end
    end
endmodule
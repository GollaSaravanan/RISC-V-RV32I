// Same
`timescale 1ns / 1ps
// Hardware module for the RV32I Arithmetic Logic Unit
module alu (
    input  wire [31:0] a,           // First 32-bit operand coming from rs1 register
    input  wire [31:0] b,           // Second 32-bit operand coming from rs2 or immediate generator
    input  wire [3:0]  alu_control, // 4-bit control code deciding which operation to perform
    output reg  [31:0] result,      // 32-bit calculation output
    output wire        zero         // 1-bit active-high flag that turns 1 when result is exactly 0
);
    // Operation code constant for addition
    localparam ALU_ADD  = 4'b0000;
    // Operation code constant for subtraction
    localparam ALU_SUB  = 4'b0001;
    // Operation code constant for bitwise AND
    localparam ALU_AND  = 4'b0010;
    // Operation code constant for bitwise OR
    localparam ALU_OR   = 4'b0011;
    // Operation code constant for bitwise XOR
    localparam ALU_XOR  = 4'b0100;
    // Operation code constant for shift left logical
    localparam ALU_SLL  = 4'b0101;
    // Operation code constant for shift right logical
    localparam ALU_SRL  = 4'b0110;
    // Operation code constant for shift right arithmetic with sign preservation
    localparam ALU_SRA  = 4'b0111;
    // Operation code constant for signed set less than comparison
    localparam ALU_SLT  = 4'b1000;
    // Operation code constant for unsigned set less than comparison
    localparam ALU_SLTU = 4'b1001;
    // Combinational evaluation block that triggers on any input change
    always @(*) begin
        // Multiplexer logic switching based on the 4-bit control signal
        case (alu_control)
            // Add operand a and operand b
            ALU_ADD:  result = a + b;
            // Subtract operand b from operand a
            ALU_SUB:  result = a - b;
            // Perform bitwise AND between a and b
            ALU_AND:  result = a & b;
            // Perform bitwise OR between a and b
            ALU_OR:   result = a | b;
            // Perform bitwise XOR between a and b
            ALU_XOR:  result = a ^ b;
            // Shift operand a left by the lower 5 bits of operand b
            ALU_SLL:  result = a << b[4:0];
            // Shift operand a right logically by the lower 5 bits of operand b
            ALU_SRL:  result = a >> b[4:0];
            // Shift operand a right arithmetically preserving sign bit
            ALU_SRA:  result = $signed(a) >>> b[4:0];
            // Signed comparison: output 1 if a is less than b, otherwise 0
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            // Unsigned comparison: output 1 if magnitude of a is less than b, otherwise 0
            ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            // Default fallback value for safety to avoid latch inference
            default:  result = 32'd0;
        // Close the case switch block
        endcase
    end
    // Combinational assign setting zero flag to 1 if result equals 0, else 0
    assign zero = (result == 32'd0) ? 1'b1 : 1'b0;
endmodule
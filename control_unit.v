// Same time scale
`timescale 1ns / 1ps
// Hardware module for single-cycle RISC-V Main Control Unit and ALU Decoder
module control_unit (
    input  wire [6:0] opcode,      // 7-bit opcode field from instruction[6:0]
    input  wire [2:0] funct3,      // 3-bit sub-operation field from instruction[14:12]
    input  wire [6:0] funct7,      // 7-bit extended function code from instruction[31:25]
    output reg        reg_write,   // Register file write enable signal
    output reg        alu_src,     // Selects ALU operand B: 0 for rs2, 1 for immediate
    output reg        mem_read,    // Data memory read enable for load instructions
    output reg        mem_write,   // Data memory write enable for store instructions
    output reg        mem_to_reg,  // Writeback selector: 0 for ALU result, 1 for Data memory
    output reg        branch,      // Active high when processing branch instructions
    output reg  [3:0] alu_control  // 4-bit operational selector code passed directly to the ALU
);
    // Local constants for 4-bit ALU operation control codes
    localparam ALU_ADD  = 4'b0000; // ALU addition opcode
    localparam ALU_SUB  = 4'b0001; // ALU subtraction opcode
    localparam ALU_AND  = 4'b0010; // ALU bitwise AND opcode
    localparam ALU_OR   = 4'b0011; // ALU bitwise OR opcode
    localparam ALU_XOR  = 4'b0100; // ALU bitwise XOR opcode
    localparam ALU_SLL  = 4'b0101; // ALU shift left logical opcode
    localparam ALU_SRL  = 4'b0110; // ALU shift right logical opcode
    localparam ALU_SRA  = 4'b0111; // ALU shift right arithmetic opcode
    localparam ALU_SLT  = 4'b1000; // ALU signed comparison set less than opcode
    localparam ALU_SLTU = 4'b1001; // ALU unsigned comparison set less than opcode
    // Combinational evaluation block for control signal decoding
    always @(*) begin
        // Safe default assignments to prevent latch creation
        reg_write   = 1'b0;        // Default register write disabled
        alu_src     = 1'b0;        // Default operand B comes from register rs2
        mem_read    = 1'b0;        // Default memory read disabled
        mem_write   = 1'b0;        // Default memory write disabled
        mem_to_reg  = 1'b0;        // Default writeback source from ALU
        branch      = 1'b0;        // Default branch disabled
        alu_control = ALU_ADD;     // Default ALU operation is addition
        // Decode signals based on instruction opcode
        case (opcode)
            // R-Type Instructions (add, sub, and, or, xor, sll, srl, sra, slt, sltu)
            7'b0110011: begin
                reg_write   = 1'b1; // Write result back to destination register rd
                alu_src     = 1'b0; // Second ALU operand is rs2 register data
                mem_read    = 1'b0; // No RAM read needed
                mem_write   = 1'b0; // No RAM write needed
                mem_to_reg  = 1'b0; // Route ALU calculation output to register file
                branch      = 1'b0; // PC continues sequentially to next instruction
                // Decode ALU operation using funct3 and funct7
                case (funct3)
                    // ADD or SUB instruction selector
                    3'b000:  alu_control = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    // SLL shift left logical instruction selector
                    3'b001:  alu_control = ALU_SLL;
                    // SLT signed set less than instruction selector
                    3'b010:  alu_control = ALU_SLT;
                    // SLTU unsigned set less than instruction selector
                    3'b011:  alu_control = ALU_SLTU;
                    // XOR bitwise operation instruction selector
                    3'b100:  alu_control = ALU_XOR;
                    // SRL or SRA right shift instruction selector
                    3'b101:  alu_control = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    // OR bitwise operation instruction selector
                    3'b110:  alu_control = ALU_OR;
                    // AND bitwise operation instruction selector
                    3'b111:  alu_control = ALU_AND;
                    // Default fallback to addition
                    default: alu_control = ALU_ADD;
                endcase
            end
            // I-Type Arithmetic Instructions (addi, andi, ori, xori, slli, srli, srai, slti, sltiu)
            7'b0010011: begin
                reg_write   = 1'b1; // Write result back to destination register rd
                alu_src     = 1'b1; // Second ALU operand is sign-extended immediate
                mem_read    = 1'b0; // No RAM read needed
                mem_write   = 1'b0; // No RAM write needed
                mem_to_reg  = 1'b0; // Route ALU calculation output to register file
                branch      = 1'b0; // PC continues sequentially to next instruction
                // Decode ALU operation using funct3 and funct7 for shift variants
                case (funct3)
                    // ADDI immediate addition selector
                    3'b000:  alu_control = ALU_ADD;
                    // SLLI immediate shift left logical selector
                    3'b001:  alu_control = ALU_SLL;
                    // SLTI immediate signed comparison selector
                    3'b010:  alu_control = ALU_SLT;
                    // SLTIU immediate unsigned comparison selector
                    3'b011:  alu_control = ALU_SLTU;
                    // XORI immediate bitwise XOR selector
                    3'b100:  alu_control = ALU_XOR;
                    // SRLI or SRAI immediate right shift selector
                    3'b101:  alu_control = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    // ORI immediate bitwise OR selector
                    3'b110:  alu_control = ALU_OR;
                    // ANDI immediate bitwise AND selector
                    3'b111:  alu_control = ALU_AND;
                    // Default fallback to addition
                    default: alu_control = ALU_ADD;
                // End of I-type ALU decoder case
                endcase
            end
            // I-Type Load Instructions (lw)
            7'b0000011: begin
                reg_write   = 1'b1;    // Write loaded data back into register rd
                alu_src     = 1'b1;    // ALU adds base register to sign-extended offset
                mem_read    = 1'b1;    // Assert RAM read enable to load word
                mem_write   = 1'b0;    // RAM write disabled during load
                mem_to_reg  = 1'b1;    // Select Data Memory output for register writeback
                branch      = 1'b0;    // PC continues sequentially
                alu_control = ALU_ADD; // ALU computes effective memory address via addition
            end
            // S-Type Store Instructions (sw)
            7'b0100011: begin
                reg_write   = 1'b0;    // Do not modify any general-purpose registers
                alu_src     = 1'b1;    // ALU adds base register to sign-extended offset
                mem_read    = 1'b0;    // RAM read disabled during store
                mem_write   = 1'b1;    // Assert RAM write enable to save word
                mem_to_reg  = 1'b0;    // Value is irrelevant since reg_write is 0
                branch      = 1'b0;    // PC continues sequentially
                alu_control = ALU_ADD; // ALU computes effective target memory address
            end
            // B-Type Conditional Branch Instructions (beq)
            7'b1100011: begin
                reg_write   = 1'b0;    // Do not modify any general-purpose registers
                alu_src     = 1'b0;    // Compare values between rs1 and rs2
                mem_read    = 1'b0;    // RAM read disabled
                mem_write   = 1'b0;    // RAM write disabled
                mem_to_reg  = 1'b0;    // Irrelevant because reg_write is 0
                branch      = 1'b1;    // Assert branch line to evaluate ALU zero flag
                alu_control = ALU_SUB; // Subtract operands to check equality via zero flag
            end
            // Default safe case for unknown opcodes
            default: begin
                reg_write   = 1'b0;    // Disable register file writes
                alu_src     = 1'b0;    // Select register operand
                mem_read    = 1'b0;    // Disable RAM read
                mem_write   = 1'b0;    // Disable RAM write
                mem_to_reg  = 1'b0;    // Select default datapath
                branch      = 1'b0;    // Disable branch
                alu_control = ALU_ADD; // Default to addition
            end
        endcase
    end
endmodule
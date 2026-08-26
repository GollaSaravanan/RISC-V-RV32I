// Reference time unit is 1ns, with a calculation precision down to 1ps
`timescale 1ns / 1ps
/*
INSTRUCTION DECODER & IMMEDIATE GENERATOR
Role in the CPU:
    Receives a 32-bit machine instruction from Instruction Memory.
    Extracts control fields (opcode, registers, function codes) using fixed bit slices.
    Reconstructs and sign-extends immediate constants according to the instruction format (I, S, B, U, J).
Instruction Formats handled:
    1. R-Type (Register-Register): No immediate. Fields: funct7, rs2, rs1, funct3, rd, opcode.
    2. I-Type (Immediate/Load): 12-bit signed immediate [31:20].
    3. S-Type (Store): 12-bit signed immediate split across [31:25] and [11:7].
    4. B-Type (Branch): 13-bit signed offset targeting even addresses (bit 0 is always 0).
    5. U-Type (Upper Immediate): 20-bit immediate loaded into upper bits [31:12], lowest 12 bits set to 0.
    6. J-Type (Jump): 21-bit signed jump target offset (bit 0 is always 0).
*/
module instruction_decoder (
    input  wire [31:0] instruction, // 32-bit binary instruction word from ROM
    output wire [6:0]  opcode,      // [6:0]   Specifies operation category
    output wire [4:0]  rd,          // [11:7]  Destination register index (x0-x31)
    output wire [2:0]  funct3,      // [14:12] Sub-operation selector code
    output wire [4:0]  rs1,         // [19:15] First source register index (x0-x31)
    output wire [4:0]  rs2,         // [24:20] Second source register index (x0-x31)
    output wire [6:0]  funct7,      // [31:25] Extended sub-operation code
    output reg  [31:0] imm_ext      // Fully sign-extended 32-bit immediate output
);
    // FIXED BIT SLICES (Combinational / Asynchronous)
    // In RISC-V, these fields are always at the exact same bit positions across all formats.
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];
    // IMMEDIATE GENERATION LOGIC
    // Re-evaluates combinatorially whenever any bit of the instruction changes
    always @(*) begin
        case (opcode)
            // I-Type: Arithmetic Immediate (addi: 0010011), Load (lw: 0000011), Jump Register (jalr: 1100111)
            // Immediate format: 12-bit signed number in bits [31:20]
            // Sign extension: duplicate bit 31 twenty times to make 32 bits total (20 + 12 = 32)
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            end
            // S-Type: Store Instructions (sw, sb, sh: 0100011)
            // Immediate format: 12 bits split into [31:25] (upper 7) and [11:7] (lower 5)
            // Sign extension: duplicate bit 31 twenty times, stitch pieces together (20 + 7 + 5 = 32)
            7'b0100011: begin
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            // B-Type: Branch Instructions (beq, bne, blt: 1100011)
            // Immediate format: 13-bit signed offset. Bit 0 is always 0 because instructions are word-aligned.
            // Spliced layout: bit 31 (sign), bit 7 (bit 11), bits 30:25 (bits 10:5), bits 11:8 (bits 4:1), 1'b0 (bit 0)
            // Sign extension: duplicate bit 31 twenty times (20 + 1 + 1 + 6 + 4 + 1 = 32)
            7'b1100011: begin
                imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            // U-Type: Upper Immediate (lui: 0110111, auipc: 0010111)
            // Immediate format: 20 bits placed in upper half [31:12], lower 12 bits zero-padded (20 + 12 = 32)
            7'b0110111, 7'b0010111: begin
                imm_ext = {instruction[31:12], 12'b0};
            end
            // J-Type: Jump and Link (jal: 1101111)
            // Immediate format: 21-bit signed jump offset. Bit 0 is always 0.
            // Spliced layout: bit 31 (sign), bits 19:12, bit 20, bits 30:21, 1'b0
            // Sign extension: duplicate bit 31 twelve times (12 + 8 + 1 + 10 + 1 = 32)
            7'b1101111: begin
                imm_ext = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            // Default: R-Type instructions (add, sub) or unused opcodes do not use immediate values
            default: begin
                imm_ext = 32'd0;
            end
        endcase
    end
endmodule
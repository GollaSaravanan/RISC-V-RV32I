`timescale 1ns / 1ps

module tb_instruction_decoder;

    reg  [31:0] instruction;
    wire [6:0]  opcode;
    wire [4:0]  rd;
    wire [2:0]  funct3;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [6:0]  funct7;
    wire [31:0] imm_ext;

    // Separate declaration and continuous assignment
    wire signed [31:0] imm_ext_signed;
    assign imm_ext_signed = imm_ext;

    // Instantiate Decoder Unit Under Test
    instruction_decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm_ext(imm_ext)
    );

    initial begin
        $dumpfile("waveform_id.vcd");
        $dumpvars(0, tb_instruction_decoder);

        // Test 1: I-Type -> addi x2, x0, 5 (0x00500113)
        instruction = 32'h00500113;
        #10;

        // Test 2: R-Type -> add x4, x2, x3 (0x00310233)
        instruction = 32'h00310233;
        #10;

        // Test 3: S-Type -> sw x3, 8(x2) (0x00312423)
        instruction = 32'h00312423;
        #10;

        // Test 4: B-Type -> beq x1, x2, offset (0x00208463)
        instruction = 32'h00208463;
        #10;

        // Test 5: U-Type -> lui x5, 0x12345 (0x123452B7)
        instruction = 32'h123452B7;
        #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | Inst=0x%h | Opcode=0x%h | rd=x%0d | rs1=x%0d | rs2=x%0d | Imm=%0d (0x%h)",
                 $time, instruction, opcode, rd, rs1, rs2, imm_ext_signed, imm_ext);
    end

endmodule
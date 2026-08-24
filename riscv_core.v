// same timescale
`timescale 1ns / 1ps
// Top-level module integrating the single-cycle RV32I processor core
module riscv_core (
    input  wire        clk,          // Primary system clock
    input  wire        rst,          // Global synchronous reset
    output wire [31:0] pc_out,       // Current Program Counter value for debug
    output wire [31:0] alu_result_out// Current ALU computation output for debug
);
    // Internal Program Counter wires
    wire [31:0] pc_current;          // Output from Program Counter register
    wire [31:0] pc_next;             // Target address for next clock cycle
    wire [31:0] pc_plus_4;           // Sequential next instruction address
    wire [31:0] pc_branch;           // Calculated branch target address
    wire        pc_sel;              // Multiplexer select line for branch decision
    // Internal Instruction Memory and Decoder wires
    wire [31:0] instruction;         // 32-bit fetched machine instruction
    wire [6:0]  opcode;              // Opcode field from instruction
    wire [4:0]  rd;                  // Destination register index
    wire [2:0]  funct3;              // 3-bit sub-operation field
    wire [4:0]  rs1;                 // First source register index
    wire [4:0]  rs2;                 // Second source register index
    wire [6:0]  funct7;              // 7-bit extended function field
    wire [31:0] imm_ext;             // 32-bit sign-extended immediate constant
    // Internal Control Unit signals
    wire        reg_write;           // Register write enable signal
    wire        alu_src;             // ALU operand B source selector
    wire        mem_read;            // Data Memory read enable signal
    wire        mem_write;           // Data Memory write enable signal
    wire        mem_to_reg;          // Register writeback source selector
    wire        branch;              // Branch instruction active signal
    wire [3:0]  alu_control;         // 4-bit ALU operation selector
    // Internal Register File and ALU datapath wires
    wire [31:0] rs1_data;            // Read data port 1 from register file
    wire [31:0] rs2_data;            // Read data port 2 from register file
    wire [31:0] alu_operand_b;       // Second ALU input after multiplexer
    wire [31:0] alu_result;          // Output from ALU calculation
    wire        zero;                // Zero status flag from ALU
    // Internal Data Memory wires
    wire [31:0] mem_read_data;       // Data loaded from Data Memory RAM
    wire [31:0] writeback_data;      // Data routed to destination register rd
    // Assign debug probe outputs
    assign pc_out         = pc_current;
    assign alu_result_out = alu_result;
    // Sequential PC increment calculation
    assign pc_plus_4 = pc_current + 32'd4;
    // Branch target calculation (PC + sign-extended immediate)
    assign pc_branch = pc_current + imm_ext;
    // Branch decision logic: branch taken only if branch flag is asserted and ALU zero is true
    assign pc_sel = branch & zero;
    // Next PC multiplexer selecting branch target or sequential address
    assign pc_next = (pc_sel) ? pc_branch : pc_plus_4;
    // Program Counter hardware instance
    program_counter pc_unit (
        .clk(clk),                   // Connect clock
        .rst(rst),                   // Connect reset
        .pc_next(pc_next),           // Connect calculated next address
        .pc(pc_current)              // Output current address
    );
    // Instruction Memory hardware instance
    instruction_memory imem_unit (
        .addr(pc_current),           // Address driven by current PC
        .instruction(instruction)    // Output fetched instruction word
    );
    // Instruction Decoder hardware instance
    instruction_decoder dec_unit (
        .instruction(instruction),   // Connect fetched instruction
        .opcode(opcode),             // Output opcode
        .rd(rd),                     // Output destination register index
        .funct3(funct3),             // Output funct3
        .rs1(rs1),                   // Output source register 1 index
        .rs2(rs2),                   // Output source register 2 index
        .funct7(funct7),             // Output funct7
        .imm_ext(imm_ext)            // Output sign-extended immediate
    );
    // Main Control Unit hardware instance
    control_unit cu_unit (
        .opcode(opcode),             // Connect opcode
        .funct3(funct3),             // Connect funct3
        .funct7(funct7),             // Connect funct7
        .reg_write(reg_write),       // Output reg_write enable
        .alu_src(alu_src),           // Output alu_src selector
        .mem_read(mem_read),         // Output mem_read enable
        .mem_write(mem_write),       // Output mem_write enable
        .mem_to_reg(mem_to_reg),     // Output mem_to_reg selector
        .branch(branch),             // Output branch enable
        .alu_control(alu_control)    // Output 4-bit ALU control code
    );
    // Register writeback multiplexer selecting ALU calculation or Data Memory word
    assign writeback_data = (mem_to_reg) ? mem_read_data : alu_result;
    // Register File hardware instance
    register_file rf_unit (
        .clk(clk),                   // Connect clock
        .rst(rst),                   // Connect reset
        .reg_write(reg_write),       // Connect write enable
        .rs1_addr(rs1),              // First source register address
        .rs2_addr(rs2),              // Second source register address
        .rd_addr(rd),                // Destination register address
        .rd_data(writeback_data),    // Data to write back
        .rs1_data(rs1_data),         // Output data 1
        .rs2_data(rs2_data)          // Output data 2
    );
    // ALU input B multiplexer selecting between register data and immediate
    assign alu_operand_b = (alu_src) ? imm_ext : rs2_data;
    // Arithmetic Logic Unit hardware instance
    alu alu_unit (
        .a(rs1_data),                // Operand A from rs1
        .b(alu_operand_b),           // Operand B from multiplexer
        .alu_control(alu_control),   // 4-bit operational selector
        .result(alu_result),         // Output computation result
        .zero(zero)                  // Output zero status flag
    );
    // Data Memory RAM hardware instance
    data_memory dmem_unit (
        .clk(clk),                   // Connect clock
        .rst(rst),                   // Connect reset
        .mem_write(mem_write),       // Connect write enable
        .mem_read(mem_read),         // Connect read enable
        .addr(alu_result),           // Memory address calculated by ALU
        .write_data(rs2_data),       // Store data from rs2 register
        .read_data(mem_read_data)    // Loaded memory data output
    );
endmodule
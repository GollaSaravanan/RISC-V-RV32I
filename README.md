# RISC V Processor 
By Saravanan Golla

## What is RISC-V?
RISC-V (pronounced "risk-five") is an open-standard instruction set architecture (ISA) originally developed at UC Berkeley. Unlike traditional architectures like x86 (Intel/AMD) or ARM which are proprietary and require expensive licenses, RISC-V is completely open source. Anyone can design, manufacture, and sell a RISC-V chip or core without paying royalties or licensing fees. 

## What does RV32I mean?
* **RV:** Stands for RISC-V.
* **32:** Means it is a 32-bit architecture, meaning its registers, data paths, and memory addresses are 32 bits wide.
* **I:** Stands for the Integer base instruction set, which is the foundational core required for any standard RISC-V processor to execute basic arithmetic, logic, and memory instructions.

## Why is it a big deal?
It gives engineers and students total freedom to build custom processors from scratch. Because the ISA specification is public and modular, you can take the base integer set, add your own custom extensions, or build a simple single-cycle processor just like we are doing right now.

---

## Phase 1: Program Counter (PC) - RISC-V Journey

### What we did
* Got Icarus Verilog and GTKWave working on Windows and fixed the system PATH so commands run smoothly in the terminal.
* Built our first hardware module (`program_counter.v`) for a 32-bit RISC-V Program Counter.
* Wrote a testbench (`tb_program_counter.v`) to act as our virtual testing lab, handling the clock and reset signals.
* Compiled everything via terminal, ran the simulation, and verified the output square wave signals in GTKWave.

### Key concepts we learned
* **Hardware runs parallel:** Unlike normal programming (C or Python) where lines run one by one from top to bottom, physical circuits run everywhere at once. That is why we use non-blocking assignments (`<=`) inside clock blocks.
* **Timescales:** Using `` `timescale 1ns / 1ps `` as a configuration instruction so the simulator knows our time units (nanoseconds and picoseconds).
* **What a testbench is:** A virtual testing environment strictly for simulation (never goes onto actual silicon) that feeds inputs like clock pulses into our module and records everything into a `.vcd` file.
* **Posedge:** Short for positive edge. It means the register updates right when the clock signal jumps from low to high.

### Commands we used
* Compile code: `iverilog -o sim.vvp program_counter.v tb_program_counter.v`
* Run simulation: `vvp sim.vvp`
* Open waveform viewer: `gtkwave waveform.vcd`

---

## Phase 2: Instruction Memory (ROM) - RISC-V Journey

### What we did
* Built our second module (`instruction_memory.v`), which acts as the processor's ROM storage.
* Pre-loaded machine code instructions in hex into a 64-word memory array to run basic operations (`addi`, `add`, `nop`).
* Handled word alignment and address indexing using bit-slicing.
* Wrote `tb_instruction_memory.v`, simulated stepping through addresses (`0x0`, `0x4`, `0x8`, `0xC`), and verified that each address outputs its exact instruction in GTKWave.

### Key concepts we learned
* **Instruction Memory Role:** Receives a 32-bit address from the Program Counter and outputs the corresponding 32-bit machine instruction to the decoder.
* **Word Alignment & Bit Slicing:** RISC-V instructions are 4 bytes (32 bits) wide. Because byte addresses increment by 4 (`0, 4, 8, 12...`), slicing off the bottom two bits with `addr[31:2]` divides the byte address by 4 to map it directly to array indices (`0, 1, 2, 3...`).
* **Machine Code vs Assembly:** Hardware circuits cannot read text like `addi x2, x0, 5`. An assembler translates those human-readable commands into 32-bit hex values (like `0x00500113`) that our memory module stores.

### Commands we used
* Compile code: `iverilog -o sim_im.vvp instruction_memory.v tb_instruction_memory.v`
* Run simulation: `vvp sim_im.vvp`
* Open waveform viewer: `gtkwave waveform_im.vcd`

---

## Phase 3: Register File - RISC-V Journey

### What we did
* Built the core storage scratchpad (`register_file.v`) with 32 general-purpose registers (`x0` to `x31`).
* Implemented dual asynchronous read ports (`rs1_data`, `rs2_data`) and a single synchronous write port (`rd_data`).
* Hardwired register `x0` permanently to zero so that any write attempts to `x0` are discarded.
* Wrote `tb_register_file.v` and verified simultaneous reads, writes, and `x0` lock in GTKWave.

### Key concepts we learned
* **Dual Read / Single Write:** Hardware often requires two operands at once (e.g. `add x3, x1, x2`), meaning reading must happen immediately through combinational logic, while writing occurs only on the rising clock edge (`posedge clk`) when `reg_write` is enabled.
* **Hardwired Zero (`x0`):** In RISC-V, `x0` is permanently tied to `0x00000000` to simplify operations (like creating a `nop` or moving registers).
* **5-bit Addressing:** Since $2^5 = 32$, we only need 5 bits (`[4:0]`) to select any of the 32 registers.

### Commands we used
* Compile code: `iverilog -o sim_rf.vvp register_file.v tb_register_file.v`
* Run simulation: `vvp sim_rf.vvp`
* Open waveform viewer: `gtkwave waveform_rf.vcd`

---

## Phase 4: Instruction Decoder & Immediate Generator - RISC-V Journey

### What we did
* Built `instruction_decoder.v` to parse raw 32-bit instruction words into standard RISC-V control fields.
* Extracted opcode, rd, funct3, rs1, rs2, and funct7 using fixed bit slicing.
* Implemented sign-extension logic for I-Type, S-Type, B-Type, U-Type, and J-Type formats.
* Wrote `tb_instruction_decoder.v` and verified immediate reconstruction across different instruction types in GTKWave.

### Key concepts we learned
* **Fixed Field Positions:** RISC-V architectures intentionally keep register indexes (`rs1`, `rs2`, `rd`) at the same bit positions across all instruction formats, allowing hardware decoders to slice them in parallel without complex routing.
* **Sign Extension (`{{20{instruction[31]}}, ...}`):** Immediate numbers are signed 2's complement values. Hardware duplicates the sign bit (bit 31) across the upper bits to expand 12-bit or 20-bit values to 32 bits without changing their numeric value.
* **S-Type / B-Type Bit Splitting:** Because the immediate fields are split across different parts of the instruction word to keep register bit locations fixed, the decoder stitches these slices back into a continuous number using Verilog concatenation (`{}`).

### Commands we used
* Compile code: `iverilog -o sim_id.vvp instruction_decoder.v tb_instruction_decoder.v`
* Run simulation: `vvp sim_id.vvp`
* Open waveform viewer: `gtkwave waveform_id.vcd`

---

## Phase 5: Arithmetic Logic Unit (ALU) - RISC-V Journey

### What we did
* Built `alu.v` to execute all RV32I mathematical, logical, shifting, and comparison operations.
* Implemented a 4-bit ALU control code multiplexer to route operations based on instruction requirements.
* Handled signed arithmetic shifts (`>>>`) and distinct signed (`SLT`) vs unsigned (`SLTU`) magnitude comparisons.
* Added an active-high `zero` flag to detect when a result is zero for branch decisions.
* Wrote `tb_alu.v` and verified every arithmetic and logical operation in GTKWave.

### Key concepts we learned
* **Shift Bit Truncation (`b[4:0]`):** In a 32-bit CPU, shifting by 32 or more is invalid or redundant, so the hardware only reads the lower 5 bits of operand B ($2^5 = 32$).
* **Signed vs Unsigned Operations:** Signed arithmetic uses 2's complement (`$signed(...)`), while unsigned operations treat bit vectors purely by binary magnitude.
* **Zero Flag:** Serves as the comparison output for conditional branches (like evaluating `beq` by computing `rs1 - rs2 == 0`).

### Commands we used
* Compile code: `iverilog -o sim_alu.vvp alu.v tb_alu.v`
* Run simulation: `vvp sim_alu.vvp`
* Open waveform viewer: `gtkwave waveform_alu.vcd`

---

## Phase 6: Data Memory (RAM) - RISC-V Journey

### What we did
* Built `data_memory.v` to manage read and write memory operations for Load/Store instructions.
* Configured synchronous write logic on `posedge clk` gated by `mem_write`.
* Configured asynchronous/combinational read logic gated by `mem_read`.
* Mapped 32-bit word addresses to array indices using `addr[31:2]`.
* Wrote `tb_data_memory.v` and verified storage and retrieval of test words (`0xDEADBEEF` and `0x12345678`) in GTKWave.

### Key concepts we learned
* **RAM vs ROM:** ROM (`instruction_memory`) is read-only and stores static code, whereas RAM (`data_memory`) dynamically stores and loads runtime program variables.
* **Single-Cycle Timing Requirements:** Load instructions (`lw`) must calculate addresses, query RAM, and deliver data back to registers within a single clock cycle, requiring combinational reads. Writes modify architectural state and are kept synchronous on clock edges.
* **Word Alignment:** Byte-addressed memory increments by 4, so dropping the lowest 2 address bits (`addr[31:2]`) maps byte addresses directly to 32-bit word slots in the array.

### Commands we used
* Compile code: `iverilog -o sim_dm.vvp data_memory.v tb_data_memory.v`
* Run simulation: `vvp sim_dm.vvp`
* Open waveform viewer: `gtkwave waveform_dm.vcd`

---

## Phase 7: Main Control Unit - RISC-V Journey

### What we did
* Built `control_unit.v` to decode opcodes, funct3, and funct7 fields into CPU control lines.
* Routed multiplexer selectors (`alu_src`, `mem_to_reg`), RAM access flags (`mem_read`, `mem_write`), register write flags (`reg_write`), and branch enable lines (`branch`).
* Integrated sub-operation decoding to select exact 4-bit ALU operations for R-Type and I-Type instructions.
* Wrote `tb_control_unit.v` and verified control signal generation across all core instruction types in GTKWave.

### Key concepts we learned
* **The Brain of the CPU:** The Control Unit takes high-level instruction opcodes and coordinates which hardware blocks activate during each cycle.
* **Multiplexer Control:** `alu_src` toggles whether the ALU computes on register data or immediate constants; `mem_to_reg` selects whether the ALU output or loaded memory data is written back to registers.
* **Zero-Overhead Branch Setup:** Generates a `branch` control signal that combines with the ALU's `zero` flag to dynamically switch the Program Counter to branch target addresses.

### Commands we used
* Compile code: `iverilog -o sim_cu.vvp control_unit.v tb_control_unit.v`
* Run simulation: `vvp sim_cu.vvp`
* Open waveform viewer: `gtkwave waveform_cu.vcd`

---

## Phase 8: Top-Level Integration & Full Processor Simulation - RISC-V Journey

### What we did
* Integrated all individual modules into a complete single-cycle processor core in `riscv_core.v`.
* Built the datapath multiplexers for ALU operands, writeback data sources, and branch target program counter selection.
* Pre-loaded an end-to-end assembly program testing arithmetic (`addi`, `add`), memory storage and retrieval (`sw`, `lw`), and conditional branching (`beq`).
* Wrote `tb_riscv_core.v`, simulated the complete processor execution, and verified cycle-by-cycle register updates and branching in GTKWave.

### Key concepts we learned
* **Single-Cycle Datapath Execution:** Every instruction completes in a single clock cycle across Fetch, Decode, Execute, Memory, and Writeback stages.
* **Datapath Multiplexing:** Hardware multiplexers route data dynamically between registers, memory, and immediate generator outputs based on control unit signals.
* **Branch Execution:** The branch target address (`PC + immediate`) is calculated in parallel with the ALU equality check (`zero` flag), seamlessly redirecting execution without bubbles.

### Commands we used
* Compile code: `iverilog -o sim_core.vvp program_counter.v instruction_memory.v instruction_decoder.v control_unit.v register_file.v alu.v data_memory.v riscv_core.v tb_riscv_core.v`
* Run simulation: `vvp sim_core.vvp`
* Open waveform viewer: `gtkwave waveform_core.vcd`
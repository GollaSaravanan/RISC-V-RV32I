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

## Phase1: Program Counter (PC) - RISC-V Journey

### What we did today
* Got Icarus Verilog and GTKWave working on Windows and fixed the system PATH so commands run smoothly in the terminal.
* Built our first hardware module (`program_counter.v`) for a 32-bit RISC-V Program Counter.
* Wrote a testbench (`tb_program_counter.v`) to act as our virtual testing lab, handling the clock and reset signals.
* Compiled everything via terminal, ran the simulation, and checked out the actual square wave signals in GTKWave.

### Key concepts we learned
* **Hardware runs parallel:** Unlike normal programming (C or Python) where lines run one by one from top to bottom, physical circuits run everywhere at once. That is why we use non-blocking assignments (`<=`) inside clock blocks.
* **Timescales:** Using `` `timescale 1ns / 1ps `` as a configuration instruction so the simulator knows our time units (nanoseconds and picoseconds).
* **What a testbench is:** A virtual testing environment strictly for simulation (never goes onto actual silicon) that feeds fake inputs like clock pulses into our module and records everything into a `.vcd` file.
* **Posedge:** Short for positive edge. It means the register updates right when the clock signal jumps from low to high.

### Commands we used
* Compile code: `iverilog -o sim.vvp program_counter.v tb_program_counter.v`
* Run simulation: `vvp sim.vvp`
* Open waveform viewer: `gtkwave waveform.vcd`

---

## Phase2: Instruction Memory (ROM) - RISC-V Journey

### What we did today
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

## Phase3: Register File - RISC-V Journey

### What we did today
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

## Phase4: Instruction Decoder & Immediate Generator - RISC-V Journey

### What we did today
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
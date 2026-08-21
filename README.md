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
## Day 1: Program Counter (PC) - RISC-V Journey

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
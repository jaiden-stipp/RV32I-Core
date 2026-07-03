# RV32I Core

This repository is my RISC-V CPU project written in SystemVerilog. The goal was to learn real processor design by starting from a simple single-cycle core and then building a 5-stage pipelined core with hazard handling, forwarding, and branch control.

## What This Project Is

This project implements a subset of the RISC-V ISA (RV32I) in two versions:

- `SingleCore/`: a single-cycle baseline core
![RTL synthesized view of single-cycle processor](image-1.png)
- `5-Stage-Pipeline/`: a pipelined core (IF/ID/EX/MEM/WB)
![RTL synthesized view of 5-stage Processor](image.png)

The pipelined version is the main focus and includes:

- Pipeline registers: `IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`
- Hazard detection for load-use stalls
- Forwarding paths to reduce bubbles
- Branch and jump control (`beq`, `bne`, signed/unsigned compare branches, `jal`, `jalr`)
- Basic performance counters through `Monitor.sv` (cycles, instructions, stalls, flushes, forwards)



## Repository Layout

- `5-Stage-Pipeline/`
- `5-Stage-Pipeline/RV32I_Pipeline.sv`: top-level pipelined CPU
- `5-Stage-Pipeline/RV32I_Pipeline_tb.sv`: testbench
- `5-Stage-Pipeline/tests/asm/`: assembly tests (`.S`)
- `5-Stage-Pipeline/tests/programs/`: generated hex programs for instruction memory
- `5-Stage-Pipeline/tests/runall.do`: ModelSim batch run for the full suite
- `SingleCore/`: earlier single-cycle implementation and testbenches

## Supported Instruction Categories (Current)

The tests in `5-Stage-Pipeline/tests/asm/` currently cover core RV32I categories:

- R-type ALU: `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`
- I-type ALU: `addi`, `andi`, `ori`, `xori`
- Memory: `lw`, `sw`
- Branches: `beq`, `bne`, plus signed/unsigned branch matrix tests
- Jumps: `jal`, `jalr`
- Pipeline-focused directed tests: load-use hazards, dual forwarding, branch condition matrix, jalr link behavior

## Test Strategy

Each assembly test follows the same structure:

- run instruction sequence
- branch to `pass` or `fail`
- write `1` (pass) or `2` (fail) to data memory location `0`

The testbench watches `DM.mem[0]` and prints pass/fail and counters.

This was built out so that I can write programs to test the processor easier.

## How To Run

From `5-Stage-Pipeline/tests`:

1. Build hex for a single test:

   `python tests.py addi`

2. Add test to runsingle.do:

    `vsim work.tb_RV32I_Pipeline +TEST=programs/cpitest.hex`

    Replace cpitest.hex with whatever specific test you want to run


3. Run the full simulation suite:

   `vsim -c -do runall.do`

Notes:

- `tests.py` expects a RISC-V GCC toolchain in PATH (for example `riscv64-unknown-elf-gcc`).
- `runall.do` and `runstress.do` use ModelSim/Questa batch mode.

## What I Learned

Biggest takeaways from this project:

- Correct hazard handling is mostly about exact cycle timing, not just logic equations.
- Small control/datapath mismatches can cause hard-to-debug wrong-path behavior.
- Forwarding needs to be validated with directed dependency tests, not only simple ALU tests.
- A consistent pass/fail assembly harness makes regression testing much easier.

## Next Steps

Planned improvements:

My next goals are to continue expanding the verification environment, improve branch performance, and begin exploring more advanced computer architecture and SoC concepts. Some of the areas I want to investigate next include more complex branch prediction, memory-mapped peripherals, VGA output, interrupts and exception handling, cache design, and potentially superscalar execution.


By Jaiden Stipp - 2026
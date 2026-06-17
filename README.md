# RV32I Core

A single-cycle implementation of the RV32I base integer instruction set, written in SystemVerilog by Jaiden Stipp

<img width="2243" height="852" alt="RV32I single-cycle datapath" src="https://github.com/user-attachments/assets/2d431fad-5f39-4557-bd11-c253a96afcf3" />

## Status

Single-cycle core (`SingleCore/`) implements the RV32I base ISA: R/I/L/S/B-type instructions, JAL/JALR, LUI, and AUIPC. A pipelined core is planned but I have not started it yet

## Layout

```
SingleCore/
  RV32I_Single.sv     Top-level datapath, wires all modules together
  ControlUnit.sv       Decodes opcode/funct3/funct7 into control signals
  ALU.sv                Arithmetic/logic unit (add, sub, and, or, xor, slt, sltu, sll, srl, sra, passb)
  ImmGen.sv             Generates sign-extended immediates for I/S/B/U/J formats
  RegFile.sv            32x32 register file, x0 hardwired to zero
  InstructionMem.sv     Instruction ROM, loaded via $readmemh
  DataMem.sv             Data RAM
  ResultMux.sv           Selects writeback value (ALU result / memory / PC+4)
  PC_Logic.sv             Next-PC computation (sequential, branch, jump, jalr)
  programs/               Assembled .hex test programs (base, fibonacci)
  tb/                     Testbenches for the ALU, RegFile, full core, and fibonacci program
  notes/references.md     Reference material used while building the core
```

## Running the testbenches

The testbenches are plain SystemVerilog and can be run with any simulator that supports `$readmemh` (e.g. ModelSim/Questa bundled with Quartus, or Verilator with `--timing`).

Example with Questa:

```
vlog SingleCore/*.sv SingleCore/tb/RV32I_tb.sv
vsim -c RV32I_tb -do "run -all; quit"
```

`InstructionMem.sv` loads `programs/fibonacci.hex` by default; override with the `MEM_PATH` macro to point at a different program:

```
vlog +define+MEM_PATH=\"programs/base.hex\" SingleCore/*.sv SingleCore/tb/RV32I_tb.sv
```

## References

See [`SingleCore/notes/references.md`](SingleCore/notes/references.md) for the ISA documentation and other material referenced while building this core.

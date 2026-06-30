References for the pipelined core, in addition to everything in `SingleCore/notes/references.md` (the ISA spec and opcode references still apply unchanged).

- "Digital Design and Computer Architecture, RISC-V Edition" by Harris & Harris — pipelined microarchitecture and hazard chapters; the direct continuation of what was used for the single-cycle core.
- "Computer Organization and Design RISC-V Edition" by Patterson & Hennessy — "The Processor" chapter covers pipelining, hazards, and forwarding in more architectural depth.
- https://zipcpu.com — practical Verilog/pipelining/formal-verification writeups; useful for seeing pipeline hazard handling discussed outside a textbook's idealized example.
- https://github.com/riscv/riscv-tests — official RISC-V test suite; optional stretch goal for Assignment 8 broader coverage.

Per `plan.md`: the emulator (Rust/Python) built earlier in the summer is the golden-reference model for Assignment 8's commit-log cross-check — no external reference needed for that, just your own prior work.

# SoC Software

This folder contains the bare-metal software flow for the memory-mapped SoC.

Memory map:

- RAM: `0x0000_0000` to `0x0000_FFFF`
- GPIO: `0x1000_0000` to `0x1000_00FF`
- GPIO output register: `0x1000_0000`
- GPIO input register: `0x1000_0004`

Build a program from this directory:

```powershell
python c.py blink
```

The script emits:

- `elf/blink.elf`
- `bin/blink.bin`
- `asm/blink.asm`
- `programs/blink.hex`
- `programs/blink.mif`

The generated `.mif` can be loaded into the SoC RAM for simulation or FPGA memory initialization.

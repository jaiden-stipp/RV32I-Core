from pathlib import Path
import subprocess
import sys

ASM_DIR = Path("/asm")
BIN_DIR = Path("/bin")
PROGRAM_DIR = Path("/programs")

TOOL = "riscv64-unknown-elf"

test = sys.argv[1]

asm = Path(f"asm/{test}.S")
elf = Path(f"elf/{test}.elf")
bin = Path(f"bin/{test}.bin")
hexf = Path(f"programs/{test}.hex")

if not asm.exists():
    print(f"Error: {asm} does not exist.")
    sys.exit(1)

subprocess.run([
    f"{TOOL}-gcc",
    "-march=rv32i",
    "-mabi=ilp32",
    "-nostdlib",
    "-Ttext=0",
    str(asm),
    "-o",
    str(elf)
], check=True)

subprocess.run([
    "riscv64-unknown-elf-objcopy",
    "-O", "binary",
    str(elf),
    str(bin)
], check=True)

data = bin.read_bytes()

with open(hexf, "w") as f:
    for i in range(0, len(data), 4):
        word = data[i:i+4].ljust(4, b"\x00")
        value = int.from_bytes(word, byteorder="little")
        f.write(f"{value:08x}\n")

print(f"{test} test assembled")
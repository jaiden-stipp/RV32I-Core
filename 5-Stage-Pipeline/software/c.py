from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parent
EXAMPLES_DIR = ROOT / "examples"
ELF_DIR = ROOT / "elf"
BIN_DIR = ROOT / "bin"
PROGRAM_DIR = ROOT / "programs"

TOOL = "riscv64-unknown-elf"


def find_c_file(test) :
    candidates = [
        ROOT / f"{test}.c",
        EXAMPLES_DIR / f"{test}.c",
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    print(f"Error: could not find {test}.c in {ROOT} or {EXAMPLES_DIR}")
    sys.exit(1)


def write_hex(bin_file, hex_file):
    data = bin_file.read_bytes()

    with hex_file.open("w") as f:
        for i in range(0, len(data), 4):
            word = data[i:i + 4].ljust(4, b"\x00")
            value = int.from_bytes(word, byteorder="little")
            f.write(f"{value:08x}\n")


def main():
    test = sys.argv[1] if len(sys.argv) > 1 else "add"
    c_file = find_c_file(test)

    ELF_DIR.mkdir(exist_ok=True)
    BIN_DIR.mkdir(exist_ok=True)
    PROGRAM_DIR.mkdir(exist_ok=True)

    elf = ELF_DIR / f"{test}.elf"
    bin_file = BIN_DIR / f"{test}.bin"
    hex_file = PROGRAM_DIR / f"{test}.hex"

    subprocess.run([
        f"{TOOL}-gcc",
        "-march=rv32i",
        "-mabi=ilp32",
        "-ffreestanding",
        "-nostdlib",
        "-nostartfiles",
        "-msmall-data-limit=0",
        "-O1",
        "-T", "link.ld",
        "ctrl0.S",
        str(c_file.relative_to(ROOT)),
        "-o", str(elf.relative_to(ROOT)),
    ], cwd=ROOT, check=True)

    subprocess.run([
        f"{TOOL}-objcopy",
        "-O", "binary",
        str(elf.relative_to(ROOT)),
        str(bin_file.relative_to(ROOT)),
    ], cwd=ROOT, check=True)

    write_hex(bin_file, hex_file)

    print(f"{test} C test assembled")
    return 0


if __name__ == "__main__":
    sys.exit(main())

from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parent
EXAMPLES_DIR = ROOT / "examples"
ELF_DIR = ROOT / "elf"
BIN_DIR = ROOT / "bin"
PROGRAM_DIR = ROOT / "programs"

TOOL = "riscv64-unknown-elf"
RAM_WORDS = 16384
RAM_WIDTH = 32


def find_c_file(program):
    candidates = [
        ROOT / f"{program}.c",
        EXAMPLES_DIR / f"{program}.c",
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    print(f"Error: could not find {program}.c in {ROOT} or {EXAMPLES_DIR}")
    sys.exit(1)


def write_hex(bin_file, hex_file):
    data = bin_file.read_bytes()

    with hex_file.open("w") as f:
        for i in range(0, len(data), 4):
            word = data[i:i + 4].ljust(4, b"\x00")
            value = int.from_bytes(word, byteorder="little")
            f.write(f"{value:08x}\n")


def write_mif(bin_file, mif_file):
    data = bin_file.read_bytes()
    word_count = (len(data) + 3) // 4

    if word_count > RAM_WORDS:
        print(f"Error: program needs {word_count} words, but RAM holds {RAM_WORDS}")
        sys.exit(1)

    with mif_file.open("w") as f:
        f.write(f"WIDTH={RAM_WIDTH};\n")
        f.write(f"DEPTH={RAM_WORDS};\n\n")
        f.write("ADDRESS_RADIX=HEX;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        for addr in range(word_count):
            i = addr * 4
            word = data[i:i + 4].ljust(4, b"\x00")
            value = int.from_bytes(word, byteorder="little")
            f.write(f"    {addr:04X} : {value:08X};\n")

        if word_count < RAM_WORDS:
            f.write(f"    [{word_count:04X}..{RAM_WORDS - 1:04X}] : 00000000;\n")

        f.write("END;\n")


def main():
    program = sys.argv[1] if len(sys.argv) > 1 else "blink"
    c_file = find_c_file(program)

    ELF_DIR.mkdir(exist_ok=True)
    BIN_DIR.mkdir(exist_ok=True)
    PROGRAM_DIR.mkdir(exist_ok=True)

    elf = ELF_DIR / f"{program}.elf"
    bin_file = BIN_DIR / f"{program}.bin"
    hex_file = PROGRAM_DIR / f"{program}.hex"
    mif_file = PROGRAM_DIR / f"{program}.mif"

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
        "crt0.S",
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
    write_mif(bin_file, mif_file)

    print(f"{program} program assembled")
    return 0


if __name__ == "__main__":
    sys.exit(main())

from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parent
ASM_DIR = ROOT / "asm"


def main():
    tests = sorted(path.stem for path in ASM_DIR.glob("*.S"))

    if not tests:
        print(f"No assembly tests found in {ASM_DIR}")
        return 1

    failures = []

    for test in tests:
        print(f"\nAssembling {test}")
        result = subprocess.run(
            [sys.executable, "tests.py", test],
            cwd=ROOT,
        )

        if result.returncode != 0:
            failures.append(test)

    print(f"\nAssembled {len(tests) - len(failures)}/{len(tests)} tests")

    if failures:
        print("Failed tests:")
        for test in failures:
            print(f"  {test}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

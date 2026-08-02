#!/usr/bin/env python3
"""Keep sclang stdin open and forward termination signals cleanly."""

from __future__ import annotations

import signal
import subprocess
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: sclang-supervisor.py /path/to/sclang", file=sys.stderr)
        return 2

    child = subprocess.Popen(
        [sys.argv[1], "-D", "-s"],
        stdin=subprocess.PIPE,
    )

    def terminate(_signum: int, _frame: object) -> None:
        if child.poll() is None:
            child.terminate()

    signal.signal(signal.SIGTERM, terminate)
    signal.signal(signal.SIGINT, terminate)

    return child.wait()


if __name__ == "__main__":
    raise SystemExit(main())

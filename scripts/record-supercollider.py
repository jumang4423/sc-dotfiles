#!/usr/bin/env python3
"""Record scsynth output bus 0 directly through OSC and DiskOut."""

from __future__ import annotations

import argparse
import socket
import struct
import time
from pathlib import Path


def padded(data: bytes) -> bytes:
    return data + (b"\0" * ((-len(data)) % 4))


def osc_string(value: str) -> bytes:
    return padded(value.encode("utf-8") + b"\0")


def osc_blob(value: bytes) -> bytes:
    return struct.pack(">i", len(value)) + padded(value)


def osc_message(address: str, *arguments: object) -> bytes:
    tags = ","
    payload = b""
    for argument in arguments:
        if isinstance(argument, int):
            tags += "i"
            payload += struct.pack(">i", argument)
        elif isinstance(argument, float):
            tags += "f"
            payload += struct.pack(">f", argument)
        elif isinstance(argument, str):
            tags += "s"
            payload += osc_string(argument)
        elif isinstance(argument, bytes):
            tags += "b"
            payload += osc_blob(argument)
        else:
            raise TypeError(f"unsupported OSC argument: {argument!r}")
    return osc_string(address) + osc_string(tags) + payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("output", type=Path)
    parser.add_argument("synthdef", type=Path)
    parser.add_argument("--duration", type=float, default=5.0)
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    target = ("127.0.0.1", 57110)
    buffer_id = 700
    node_id = 900700

    def send(address: str, *values: object) -> None:
        sock.sendto(osc_message(address, *values), target)

    send("/b_alloc", buffer_id, 65536, 2)
    time.sleep(0.15)
    send(
        "/b_write",
        buffer_id,
        str(args.output.resolve()),
        "wav",
        "float",
        0,
        0,
        1,
    )
    time.sleep(0.15)
    send("/d_recv", args.synthdef.read_bytes())
    time.sleep(0.15)
    send(
        "/s_new",
        "sc_dotfiles_recorder_2",
        node_id,
        1,
        0,
        "bufnum",
        buffer_id,
        "in",
        0,
    )
    time.sleep(args.duration)
    send("/n_free", node_id)
    time.sleep(0.1)
    send("/b_close", buffer_id)
    time.sleep(0.2)
    send("/b_free", buffer_id)
    sock.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

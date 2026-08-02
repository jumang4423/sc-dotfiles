#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
pid_file="$repo_dir/.run/sclang.pid"

if [[ -f "$pid_file" ]]; then
    pid=$(<"$pid_file")
    if kill -0 "$pid" 2>/dev/null; then
        echo "SuperCollider is running (PID $pid)"
        exit 0
    fi
fi

echo "SuperCollider is not running through this repository"

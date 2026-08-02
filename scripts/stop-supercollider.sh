#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
pid_file="$repo_dir/.run/sclang.pid"

if [[ ! -f "$pid_file" ]]; then
    echo "SuperCollider is not running through this repository"
    exit 0
fi

pid=$(<"$pid_file")
if ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$pid_file"
    echo "Removed a stale SuperCollider PID file"
    exit 0
fi

kill -TERM "$pid"
for _ in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$pid_file"
        echo "SuperCollider stopped"
        exit 0
    fi
    sleep 0.25
done

echo "SuperCollider did not stop cleanly (PID $pid)" >&2
exit 1

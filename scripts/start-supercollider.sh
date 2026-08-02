#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
run_dir="$repo_dir/.run"
pid_file="$run_dir/sclang.pid"
log_file="$run_dir/supercollider.log"
sclang_bin=${SCLANG:-sclang}

mkdir -p "$run_dir"

if [[ -f "$pid_file" ]]; then
    old_pid=$(<"$pid_file")
    if kill -0 "$old_pid" 2>/dev/null; then
        echo "SuperCollider is already running (PID $old_pid)"
        exit 0
    fi
    rm -f "$pid_file"
fi

: >"$log_file"
nohup python3 "$repo_dir/scripts/sclang-supervisor.py" "$sclang_bin" >"$log_file" 2>&1 &
pid=$!
echo "$pid" >"$pid_file"

for _ in {1..60}; do
    if grep -q "sc-dotfiles ready" "$log_file"; then
        echo "SuperCollider is ready (PID $pid)"
        exit 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "SuperCollider failed to start" >&2
        cat "$log_file" >&2
        rm -f "$pid_file"
        exit 1
    fi
    sleep 0.5
done

echo "SuperCollider startup timed out; see $log_file" >&2
kill -TERM "$pid" 2>/dev/null || true
rm -f "$pid_file"
exit 1

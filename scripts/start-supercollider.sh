#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
run_dir="$repo_dir/.run"
pid_file="$run_dir/sclang.pid"
log_file="$run_dir/supercollider.log"
sclang_bin=${SCLANG:-sclang}

mkdir -p "$run_dir"

# Always begin from a known-clean state. This also catches orphaned scsynth
# processes and SuperCollider instances that were not started by this repo.
"$repo_dir/scripts/stop-supercollider.sh" >/dev/null

: >"$log_file"
nohup python3 "$repo_dir/scripts/sclang-supervisor.py" "$sclang_bin" >"$log_file" 2>&1 &
pid=$!
echo "$pid" >"$pid_file"

for _ in {1..60}; do
    if grep -q "sc-dotfiles ready" "$log_file"; then
        supervisors=(${(f)"$(pgrep -f "$repo_dir/scripts/sclang-supervisor.py" 2>/dev/null || true)"})
        sclangs=(${(f)"$(pgrep -x sclang 2>/dev/null || true)"})
        scsynths=(${(f)"$(pgrep -x scsynth 2>/dev/null || true)"})
        if (( ${#supervisors} != 1 || ${#sclangs} != 1 || ${#scsynths} != 1 )); then
            echo "SuperCollider did not reach a single-instance state" >&2
            "$repo_dir/scripts/stop-supercollider.sh" >&2
            exit 1
        fi
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
"$repo_dir/scripts/stop-supercollider.sh" >/dev/null
exit 1

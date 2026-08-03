#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
pid_file="$repo_dir/.run/sclang.pid"

find_supercollider_pids() {
    local -a found
    local name

    for name in SuperCollider sclang scsynth supernova; do
        found+=( ${(f)"$(pgrep -x "$name" 2>/dev/null || true)"} )
    done
    found+=( ${(f)"$(pgrep -f "$repo_dir/scripts/sclang-supervisor.py" 2>/dev/null || true)"} )
    print -l -- ${${(u)found}:#}
}

pids=( ${(f)"$(find_supercollider_pids)"} )
if (( ${#pids} == 0 )); then
    rm -f "$pid_file"
    echo "No SuperCollider processes were running"
    exit 0
fi

kill -TERM $pids 2>/dev/null || true
for _ in {1..40}; do
    remaining=( ${(f)"$(find_supercollider_pids)"} )
    if (( ${#remaining} == 0 )); then
        rm -f "$pid_file"
        echo "All SuperCollider processes stopped"
        exit 0
    fi
    sleep 0.25
done

remaining=( ${(f)"$(find_supercollider_pids)"} )
echo "Force-killing remaining SuperCollider processes: ${remaining[*]}" >&2
kill -KILL $remaining 2>/dev/null || true
sleep 0.25

remaining=( ${(f)"$(find_supercollider_pids)"} )
rm -f "$pid_file"
if (( ${#remaining} != 0 )); then
    echo "Failed to stop SuperCollider processes: ${remaining[*]}" >&2
    exit 1
fi

echo "All SuperCollider processes stopped (forced)"

#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
log_file=$(mktemp -t sc-dotfiles-check)
pid=""
sclang_bin=${SCLANG:-sclang}

cleanup() {
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null || true
    fi
    rm -f "$log_file"
}
trap cleanup EXIT INT TERM

SC_DOTFILES_CHECK=1 "$sclang_bin" -D -s "$repo_dir/scripts/daemon.scd" >"$log_file" 2>&1 &
pid=$!

for _ in {1..60}; do
    if ! kill -0 "$pid" 2>/dev/null; then
        if wait "$pid"; then
            if grep -q "sc-dotfiles ready" "$log_file"; then
                echo "SuperCollider startup check passed"
                exit 0
            fi
        fi
        echo "SuperCollider startup check failed" >&2
        cat "$log_file" >&2
        exit 1
    fi
    sleep 0.5
done

echo "SuperCollider startup check timed out" >&2
cat "$log_file" >&2
exit 1

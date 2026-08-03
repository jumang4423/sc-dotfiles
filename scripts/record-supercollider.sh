#!/bin/zsh

set -euo pipefail

repo_dir="${0:A:h:h}"
duration="${1:-}"
synthdef_dir="/tmp/sc-dotfiles-recorder-synthdef"
synthdef_path="$synthdef_dir/sc_dotfiles_recorder_2.scsyndef"
sclang_path="${SCLANG:-/Applications/SuperCollider.app/Contents/MacOS/sclang}"

case "$duration" in
    5|10|30) ;;
    *)
        echo "Recording duration must be 5, 10, or 30 seconds." >&2
        exit 2
        ;;
esac

if ! pgrep -x scsynth >/dev/null; then
    echo "SuperCollider is not running. Run make start first." >&2
    exit 1
fi

if [[ ! -f "$synthdef_path" ]]; then
    mkdir -p "$synthdef_dir"
    SC_DOTFILES_SKIP_STARTUP=1 "$sclang_path" \
        "$repo_dir/scripts/write-recorder-synthdef.scd" >/dev/null
fi

timestamp="$(date +%y%m%d-%H%M%S)"
output="$repo_dir/recordings/${timestamp}-${duration}s.wav"

echo "Recording SuperCollider output for ${duration}s..."
python3 "$repo_dir/scripts/record-supercollider.py" \
    "$output" \
    "$synthdef_path" \
    --duration "$duration"
echo "$output"

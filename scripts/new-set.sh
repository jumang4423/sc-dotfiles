#!/bin/zsh
set -eu

repo_dir=${0:A:h:h}
sets_dir="$repo_dir/sets"
date_prefix=$(date +%y%m%d)

mkdir -p "$sets_dir"

for number in {1..99}; do
    suffix=$(printf '%02d' "$number")
    set_file="$sets_dir/$date_prefix-$suffix.tidal"

    if [[ ! -e "$set_file" ]]; then
        touch "$set_file"
        echo "$set_file"
        exit 0
    fi
done

echo "No free set number remains for $date_prefix (01-99)" >&2
exit 1

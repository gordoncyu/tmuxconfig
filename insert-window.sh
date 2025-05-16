#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"
if [[ "$mode" != "before" && "$mode" != "after" ]]; then
    echo "Usage: $0 [before|after]" >&2
    exit 1
fi

cur=$(tmux display-message -p '#I')
if [[ "$mode" == "before" ]]; then
    idx=$cur
else
    idx=$((cur + 1))
fi

readarray -t used < <(tmux list-windows -F '#I' | sort -n)

# Find first free index
free=$idx
while printf '%s\n' "${used[@]}" | grep -qx "$free"; do
    free=$((free + 1))
done

# Shift conflicting windows up, from high to low
for ((i=free-1; i>=idx; i--)); do
    tmux move-window -s "$i" -t $((i + 1))
done

# Create the new window
tmux new-window -t "$idx"

#!/usr/bin/env bash
# Execute a launcher-chosen bash alias/function and notify the result.
#
# Usage: qs-alias-run.sh <name> [args...]
#
# Runs <name> (alias, function, or command string) in the interactive bash
# environment (so aliases/functions from ~/.bashrc_usr etc. exist), then sends
# a desktop notification via notify-send (swaync):
#   - success: "✓ <name>" with the last lines of output
#   - failure: "✗ <name> (exit N)" with error/output tail
# Same PATH-stub trick as qs-alias-dump.sh to keep rc side effects quiet.
set -u

name="${1:?usage: qs-alias-run.sh <alias-or-command> [args...]}"
shift

stubdir="$(mktemp -d)"
out="$(mktemp)"
err="$(mktemp)"
trap 'rm -rf "$stubdir" "$out" "$err"' EXIT
for c in ssh-agent ssh-add fastfetch uwsm; do
    printf '#!/bin/sh\nexit 0\n' > "$stubdir/$c"
    chmod +x "$stubdir/$c"
done

# $name is intentionally NOT quoted inside the command string: it may be a
# multi-word command (e.g. "power performance") — the user typed it.
PATH="$stubdir:$PATH" bash -ic "shopt -s expand_aliases; $name \"\$@\"" _ "$@" >"$out" 2>"$err"
rc=$?

tail_out="$(grep -v '^$' "$out" | tail -n 6 | tail -c 500)"
tail_err="$(grep -v "cannot set terminal process group\|no job control in this shell" "$err" | grep -v '^$' | tail -n 6 | tail -c 500)"

if [ "$rc" -eq 0 ]; then
    body="$tail_out"
    [ -z "$body" ] && body="$tail_err"
    [ -z "$body" ] && body="command ran successfully"
    notify-send -a launcher -u normal "✓ $name" "$body"
else
    body=""
    [ -n "$tail_out" ] && body="stdout: $tail_out"
    if [ -n "$tail_err" ]; then
        body="${body:+$body

}$tail_err"
    fi
    [ -z "$body" ] && body="no output"
    notify-send -a launcher -u critical "✗ $name (exit $rc)" "$body"
fi
exit 0
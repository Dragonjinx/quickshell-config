#!/usr/bin/env bash
# Dump bash aliases + functions from the interactive rc, for the quickshell
# launcher alias mode (":" prefix).
#
# Output: "name<TAB>definition" per line (functions show "<function>" as the
# definition), sorted by name.
#
# The rc's side effects (eval $(ssh-agent), ssh-add, the `ff` fastfetch logo,
# uwsm checks) are neutralized with PATH stubs: no orphan ssh-agents, no
# terminal noise, ~0.1s total.
set -u

stubdir="$(mktemp -d)"
trap 'rm -rf "$stubdir"' EXIT
for c in ssh-agent ssh-add fastfetch uwsm; do
    printf '#!/bin/sh\nexit 0\n' > "$stubdir/$c"
    chmod +x "$stubdir/$c"
done

PATH="$stubdir:$PATH" bash -ic '
    shopt -s expand_aliases
    # Skip bash-internal/completion helpers and prompt machinery.
    _skip() {
        case "$1" in
            _*|.*)                      true ;;
            command_not_found_handle|dequote|quote|quote_readline) true ;;
            starship_*)                 true ;;
            *)                          false ;;
        esac
    }
    alias | while IFS= read -r line; do
        line="${line#alias }"
        name="${line%%=*}"
        _skip "$name" || printf "%s\t%s\n" "$name" "${line#*=}"
    done
    declare -F | while read -r _ _ fn; do
        _skip "$fn" || printf "%s\t<function>\n" "$fn"
    done
' 2>/dev/null | sort
#!/bin/bash
# Rofi script mode - returns apps matching the query

if [[ -n "$ROFI_INFO" ]]; then
    # User selected an app - launch it
    coproc ( $ROFI_INFO &>/dev/null )
    exit 0
fi

query="$1"

# If no query, return empty (no suggestions)
[[ -z "$query" ]] && exit 0

# Search for matching apps
find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read -r file; do
    name=$(grep -m1 "^Name=" "$file" 2>/dev/null | cut -d= -f2)
    icon=$(grep -m1 "^Icon=" "$file" 2>/dev/null | cut -d= -f2)
    exec_cmd=$(grep -m1 "^Exec=" "$file" 2>/dev/null | cut -d= -f2 | sed 's/ %[fFuUdDnNickvm]//g')

    [[ -z "$name" ]] && continue

    if [[ "${name,,}" == *"${query,,}"* ]]; then
        echo -en "${name}\0icon\x1f${icon}\x1finfo\x1f${exec_cmd}\n"
    fi
done

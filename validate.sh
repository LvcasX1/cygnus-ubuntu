#!/bin/bash
# Cygnus-Ubuntu: Dotfiles Validation Script
# Compares current system configs with cygnus-ubuntu dotfiles

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Counters
MATCHED=0
DIFFERENT=0
MISSING=0

print_header "Cygnus-Ubuntu Dotfiles Validation"

echo -e "${BLUE}→ Comparing dotfiles in: $DOTFILES_DIR${NC}"
echo -e "${BLUE}→ With system configs in: ~/.config${NC}"
echo ""

# Compare directories
compare_dir() {
    local name=$1
    local dotfile_path="$DOTFILES_DIR/$name"
    local system_path="$HOME/.config/$name"

    if [[ ! -d "$dotfile_path" ]]; then
        return
    fi

    if [[ ! -d "$system_path" ]]; then
        echo -e "${YELLOW}? $name - not in system${NC}"
        ((MISSING++))
        return
    fi

    # Use diff -rq but exclude log files
    local diff_output
    diff_output=$(diff -rq "$dotfile_path" "$system_path" 2>/dev/null | grep -v "\.log" | grep -v "__pycache__" | grep -v "\.luarc" | grep -v "lazy-lock")

    if [[ -z "$diff_output" ]]; then
        echo -e "${GREEN}✓ $name${NC}"
        ((MATCHED++))
    else
        local diff_count=$(echo "$diff_output" | wc -l)
        echo -e "${RED}✗ $name - $diff_count difference(s)${NC}"
        ((DIFFERENT++))

        # Store for later display
        DIFF_DETAILS+=("$name|$diff_output")
    fi
}

# Array to store diff details
declare -a DIFF_DETAILS=()

# Compare all config directories
echo -e "${CYAN}[Configuration Directories]${NC}"
echo ""

for dir in btop cava fastfetch gtk-3.0 hypr kitty Kvantum nvim qt5ct qt6ct rofi swaync wallust waybar wezterm; do
    compare_dir "$dir"
done

# Compare zshrc
echo ""
echo -e "${CYAN}[Single Files]${NC}"
echo ""

if [[ -f "$DOTFILES_DIR/zshrc" ]]; then
    if diff -q "$DOTFILES_DIR/zshrc" "$HOME/.zshrc" &>/dev/null; then
        echo -e "${GREEN}✓ zshrc${NC}"
        ((MATCHED++))
    else
        echo -e "${RED}✗ zshrc - different${NC}"
        ((DIFFERENT++))
    fi
fi

# Summary
print_header "Summary"

TOTAL=$((MATCHED + DIFFERENT + MISSING))
echo -e "Total checked:    ${BOLD}$TOTAL${NC}"
echo -e "Matched:          ${GREEN}$MATCHED${NC}"
echo -e "Different:        ${RED}$DIFFERENT${NC}"
echo -e "Missing:          ${YELLOW}$MISSING${NC}"

# Show details if there are differences
if [[ $DIFFERENT -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}Would you like to see the differences? [y/N]${NC}"
    read -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for entry in "${DIFF_DETAILS[@]}"; do
            IFS='|' read -r name details <<< "$entry"
            echo ""
            echo -e "${CYAN}━━━ $name ━━━${NC}"
            echo "$details" | head -20
        done
    fi
fi

# Final status
echo ""
if [[ $DIFFERENT -eq 0 && $MISSING -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}✓ All configurations match! Ready for deployment.${NC}"
    exit 0
else
    echo -e "${YELLOW}${BOLD}! Some differences found. Review above for details.${NC}"
    exit 1
fi

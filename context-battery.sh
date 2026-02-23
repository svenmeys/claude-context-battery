#!/bin/bash
# Context battery widget for Claude Code
# Shows context window usage as a visual bar in your status line
#
# Usage: Pipe Claude Code's JSON via stdin (works with ccstatusline custom-command widget)
# Output: Colored battery bar, e.g. [██████░░░░] 62%
#
# The bar is normalized to 80% of the context window — when it shows 100%,
# you still have ~20% buffer before Claude Code auto-compacts. This gives you
# a realistic "time to /clear" indicator instead of raw token math.
#
# Colors:
#   Green  — <50%  (plenty of room)
#   Orange — 50-80% (start wrapping up)
#   Red    — >80%  (compact is imminent)
#
# Dependencies: jq (gracefully degrades if missing)
# License: MIT

command -v jq &>/dev/null || { echo "░░░░░░░░░░"; exit 0; }

input=$(cat)

# Get context metrics with safe defaults
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage // null')

# Validate CONTEXT_SIZE is numeric and non-zero
[[ ! "$CONTEXT_SIZE" =~ ^[0-9]+$ ]] && CONTEXT_SIZE=200000
[[ "$CONTEXT_SIZE" -eq 0 ]] && CONTEXT_SIZE=200000

if [ "$USAGE" = "null" ]; then
    echo "[░░░░░░░░░░] 0%"
    exit 0
fi

# Calculate current tokens (default to 0 if null)
CURRENT=$(echo "$USAGE" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens // 0')
[[ ! "$CURRENT" =~ ^[0-9]+$ ]] && CURRENT=0

# Calculate percentage (normalized to 80% — reserves buffer for tools/skills/compact)
RAW_PCT=$((CURRENT * 100 / CONTEXT_SIZE))
PCT=$((RAW_PCT * 100 / 80))  # 80% actual = 100% displayed

# Clamp to 0-100
[ $PCT -lt 0 ] && PCT=0
[ $PCT -gt 100 ] && PCT=100

# Build battery bar (10 segments)
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))

BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# Color based on percentage
if [ $PCT -ge 80 ]; then
    COLOR="\033[31m"  # Red
elif [ $PCT -ge 50 ]; then
    COLOR="\033[33m"  # Orange/Yellow
else
    COLOR="\033[32m"  # Green
fi
RESET="\033[0m"

echo -e "${COLOR}[${BAR}] ${PCT}%${RESET}"

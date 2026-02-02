#!/usr/bin/env bash
set -euo pipefail

# Read JSON from stdin
data=$(cat)

# Extract information
model=$(echo "$data" | jq -r '.model.display_name // "Unknown"')
branch=$(git branch --show-current 2>/dev/null || echo "no-git")
tokens_used=$(echo "$data" | jq -r '.context_window.tokens_used // 0')
tokens_total=$(echo "$data" | jq -r '.context_window.tokens_total // 0')
percent_remaining=$(echo "$data" | jq -r '.context_window.percent_remaining // 100')

# Rate limit info
requests_remaining=$(echo "$data" | jq -r '.rate_limit.requests_remaining // "N/A"')
reset_time=$(echo "$data" | jq -r '.rate_limit.requests_reset // "N/A"')

# ANSI colors
ORANGE='\033[38;5;208m'
BLUE='\033[38;5;33m'
CYAN='\033[38;5;51m'
GREEN='\033[38;5;2m'
RESET='\033[0m'

# Build statusline
printf "${ORANGE}%s${RESET} | ${BLUE}%s${RESET} | ${CYAN}%d/%d (%.0f%%)${RESET} ctx | ${GREEN}%s req${RESET} @ %s" \
  "$model" \
  "$branch" \
  "$tokens_used" \
  "$tokens_total" \
  "$percent_remaining" \
  "$requests_remaining" \
  "$reset_time"

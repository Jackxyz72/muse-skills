#!/bin/bash
# Diff contract upgrades for Watchman mode
# Usage: ./diff-upgrade.sh <old-dir-or-commit> <new-dir-or-commit> [file-pattern]
#
# Examples:
#   ./diff-upgrade.sh v1.0 v2.0                    # compare git tags
#   ./diff-upgrade.sh ./old-contracts ./new-contracts  # compare directories
#   ./diff-upgrade.sh abc123 def456 "*.sol"         # compare commits, only .sol

set -e

OLD=${1:?"Usage: ./diff-upgrade.sh <old> <new> [pattern]"}
NEW=${2:?"Usage: ./diff-upgrade.sh <old> <new> [pattern]"}
PATTERN=${3:-"*.sol"}

echo "=== Upgrade Diff ==="
echo "Old: $OLD"
echo "New: $NEW"
echo "Pattern: $PATTERN"
echo ""

# Detect if inputs are git refs or directories
if git rev-parse "$OLD" &>/dev/null 2>&1 && git rev-parse "$NEW" &>/dev/null 2>&1; then
    MODE="git"
else
    MODE="dir"
fi

if [ "$MODE" = "git" ]; then
    echo "## Changed Files"
    git diff --name-only "$OLD" "$NEW" -- "$PATTERN" | grep -v "test\|mock\|lib" || echo "(no changes)"
    echo ""

    echo "## Stats"
    git diff --stat "$OLD" "$NEW" -- "$PATTERN" | grep -v "test\|mock\|lib" | tail -5
    echo ""

    echo "## Security-Relevant Changes"
    echo ""

    echo "### New external/public functions (new entry points)"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep "^+" | grep -E "function.*(external|public)" | grep -v "view\|pure\|test\|mock\|interface" || echo "(none)"
    echo ""

    echo "### Removed checks (require/assert/revert removed)"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep "^-" | grep -E "require\(|assert\(|revert " || echo "(none)"
    echo ""

    echo "### Changed access control"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep -E "^[+-].*(onlyOwner|onlyAdmin|onlyRole|auth|modifier)" || echo "(none)"
    echo ""

    echo "### New unchecked blocks"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep "^+" | grep "unchecked" || echo "(none)"
    echo ""

    echo "### Changed oracle/price logic"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep -E "^[+-].*(latestRoundData|getPrice|oracle|priceFeed)" || echo "(none)"
    echo ""

    echo "### Changed math/conversion logic"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep -E "^[+-].*(convertTo|mulDiv|totalAssets|totalSupply|exchangeRate)" || echo "(none)"
    echo ""

    echo "### New external calls"
    git diff "$OLD" "$NEW" -- "$PATTERN" | grep "^+" | grep -E "\.call\{|delegatecall|safeTransfer" || echo "(none)"
    echo ""

    echo "### Full diff (security-relevant files only)"
    CHANGED=$(git diff --name-only "$OLD" "$NEW" -- "$PATTERN" | grep -v "test\|mock\|lib")
    if [ -n "$CHANGED" ]; then
        git diff "$OLD" "$NEW" -- $CHANGED
    fi

elif [ "$MODE" = "dir" ]; then
    echo "## Directory comparison"
    diff -rq "$OLD" "$NEW" --include="$PATTERN" 2>/dev/null | grep -v "test\|mock\|lib" || echo "(identical)"
    echo ""

    echo "## Full diff"
    diff -ru "$OLD" "$NEW" --include="$PATTERN" 2>/dev/null | grep -v "test\|mock\|lib" || echo "(identical)"
fi

echo ""
echo "=== Review focus: removed checks, new entry points, changed math ==="

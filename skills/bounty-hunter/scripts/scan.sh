#!/bin/bash
# Automated static analysis scanner for bounty targets
# Usage: ./scan.sh [path-to-contracts]
# Runs Slither + Aderyn + custom grep patterns in parallel

set -e

TARGET=${1:-.}
REPORT_DIR="scan-results"
mkdir -p "$REPORT_DIR"

echo "=== Scanning $TARGET ==="
echo ""

# Count contracts
SOL_COUNT=$(find "$TARGET" -name "*.sol" -not -path "*/test/*" -not -path "*/mock/*" -not -path "*/lib/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
echo "Contracts found: $SOL_COUNT"
echo ""

# ─── GREP PATTERNS (instant) ───────────────────────────────────

echo "[1/4] Running grep patterns..."

{
    echo "# Grep Pattern Scan Results"
    echo "Generated: $(date)"
    echo ""

    echo "## Dangerous Patterns"
    echo ""

    echo "### delegatecall"
    grep -rn "delegatecall" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### selfdestruct"
    grep -rn "selfdestruct\|SELFDESTRUCT" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### tx.origin"
    grep -rn "tx.origin" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### ecrecover (check for address(0) handling)"
    grep -rn "ecrecover" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### abi.encodePacked (hash collision risk)"
    grep -rn "abi.encodePacked" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### Assembly blocks"
    echo "Count: $(grep -rn "assembly" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')"
    echo ""

    echo "### Unchecked blocks"
    echo "Count: $(grep -rn "unchecked" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')"
    echo ""

    echo "## Attack Surface"
    echo ""

    echo "### External/public state-changing functions (entry points)"
    grep -rn "function.*external\|function.*public" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "view\|pure\|test\|mock\|interface\|lib\|node_modules" | head -50
    echo ""

    echo "### External calls (reentrancy surface)"
    grep -rn "\.call{" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### Oracle reads"
    grep -rn "latestRoundData\|getPrice\|slot0\|observe\|consult\|getReserves" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" || echo "(none)"
    echo ""

    echo "### Token operations"
    echo "Transfer calls: $(grep -rn "safeTransfer\|\.transfer\b" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')"
    echo "Balance reads: $(grep -rn "balanceOf" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')"
    echo ""

    echo "### TODO/FIXME/HACK (code quality signals)"
    grep -rn "TODO\|FIXME\|HACK\|XXX\|BUG" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "lib\|node_modules" | head -20 || echo "(none)"
    echo ""

} > "$REPORT_DIR/grep-patterns.md"

echo "  -> $REPORT_DIR/grep-patterns.md"

# ─── SLITHER (if installed) ─────────────────────────────────────

if command -v slither &>/dev/null; then
    echo "[2/4] Running Slither..."
    slither "$TARGET" --filter-paths "test|mock|lib|node_modules" \
        --exclude-informational --exclude-optimization \
        2>&1 | tee "$REPORT_DIR/slither-report.txt" >/dev/null
    echo "  -> $REPORT_DIR/slither-report.txt"

    # Also generate call graph and auth analysis
    slither "$TARGET" --print vars-and-auth --filter-paths "test|mock|lib|node_modules" \
        2>&1 > "$REPORT_DIR/slither-auth.txt" || true
    echo "  -> $REPORT_DIR/slither-auth.txt"
else
    echo "[2/4] Slither not installed — skipping (pip3 install slither-analyzer)"
fi

# ─── ADERYN (if installed) ──────────────────────────────────────

if command -v aderyn &>/dev/null; then
    echo "[3/4] Running Aderyn..."
    aderyn "$TARGET" --output "$REPORT_DIR/aderyn-report.md" 2>/dev/null || true
    echo "  -> $REPORT_DIR/aderyn-report.md"
else
    echo "[3/4] Aderyn not installed — skipping (cyfrinup)"
fi

# ─── SUMMARY ────────────────────────────────────────────────────

echo "[4/4] Generating summary..."

{
    echo "# Scan Summary"
    echo "Target: $TARGET"
    echo "Date: $(date)"
    echo "Contracts: $SOL_COUNT"
    echo ""
    echo "## Priority Review Areas"
    echo ""

    DELEGATECALL_COUNT=$(grep -rn "delegatecall" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')
    UNCHECKED_COUNT=$(grep -rn "unchecked" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')
    ASSEMBLY_COUNT=$(grep -rn "assembly" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')
    ORACLE_COUNT=$(grep -rn "latestRoundData\|getPrice\|slot0\|observe" --include="*.sol" "$TARGET" 2>/dev/null | grep -v "test\|mock\|lib\|node_modules" | wc -l | tr -d ' ')

    [ "$DELEGATECALL_COUNT" -gt 0 ] && echo "- **delegatecall**: $DELEGATECALL_COUNT instances (check for controlled targets)"
    [ "$UNCHECKED_COUNT" -gt 0 ] && echo "- **unchecked blocks**: $UNCHECKED_COUNT instances (check for user-controlled inputs)"
    [ "$ASSEMBLY_COUNT" -gt 0 ] && echo "- **assembly**: $ASSEMBLY_COUNT instances (manual memory = manual bugs)"
    [ "$ORACLE_COUNT" -gt 0 ] && echo "- **oracle reads**: $ORACLE_COUNT instances (check staleness + manipulation)"

    echo ""
    echo "## Full Reports"
    echo "- Grep patterns: grep-patterns.md"
    echo "- Slither: slither-report.txt"
    echo "- Aderyn: aderyn-report.md"
    echo ""
    echo "## Next Steps"
    echo "1. Review grep-patterns.md for quick wins"
    echo "2. Triage Slither high/medium findings"
    echo "3. Cross-reference Aderyn with Slither (look for overlaps)"
    echo "4. Start manual review on flagged areas"

} > "$REPORT_DIR/summary.md"

echo "  -> $REPORT_DIR/summary.md"
echo ""
echo "=== Scan complete. Start with $REPORT_DIR/summary.md ==="

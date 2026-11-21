#!/bin/bash
# Initialize a bounty hunting workspace for a new target
# Usage: ./init-target.sh <protocol-name> [chain] [fork-block]

set -e

PROTOCOL=${1:?"Usage: ./init-target.sh <protocol-name> [chain] [fork-block]"}
CHAIN=${2:-"mainnet"}
FORK_BLOCK=${3:-"latest"}

echo "🎯 Initializing bounty target: $PROTOCOL"
echo "   Chain: $CHAIN"
echo "   Fork block: $FORK_BLOCK"

# Create workspace
mkdir -p "targets/$PROTOCOL"
cd "targets/$PROTOCOL"

# Initialize Foundry project
forge init --no-commit . 2>/dev/null || true

# Create findings tracker
cat > findings.md << 'EOF'
# Findings — ${PROTOCOL}

## Weird Things (log everything, evaluate later)

| # | File:Line | Description | Severity Guess | Status |
|---|-----------|-------------|----------------|--------|
| 1 | | | | |

## Confirmed Vulnerabilities

(move items here once PoC works)

## Rejected

(move items here with reason why it's not exploitable)
EOF

sed -i "s/\${PROTOCOL}/$PROTOCOL/g" findings.md

# Create scope notes
cat > scope.md << 'EOF'
# Scope — ${PROTOCOL}

## Bounty Program
- URL:
- Max bounty:
- Platform: Immunefi / HackenProof / Cantina / Self-hosted
- Assets in scope:

## Project Risk Assessment
- [ ] Team reputation checked (Twitter, Discord, prior hunter reports)
- [ ] Treasury verified on-chain (can they afford to pay?)
- [ ] Bounty rules are clear and specific
- [ ] Prior payout history exists (link: )
- [ ] Rules archived/screenshotted before submission
- Risk level: LOW / MEDIUM / HIGH

## Target Score (from SKILL.md Phase 0)
- Launch age:
- Complexity:
- Innovation:
- Audit status:
- **Total score: /20**
- **Decision: HUNT / SKIM / SKIP**

## Contracts in Scope
| Contract | Address | Lines | Notes |
|----------|---------|-------|-------|
| | | | |

## Out of Scope
-

## Known Issues (from audits — check BEFORE hunting)
-

## Architecture Notes
(fill in after Phase 1 recon)
EOF

sed -i "s/\${PROTOCOL}/$PROTOCOL/g" scope.md

# Set up foundry.toml for forking
cat > foundry.toml << EOF
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.24"
via_ir = false
optimizer = true
optimizer_runs = 200

[rpc_endpoints]
mainnet = "\${ETH_RPC_URL}"
arbitrum = "\${ARBITRUM_RPC_URL}"
optimism = "\${OPTIMISM_RPC_URL}"
base = "\${BASE_RPC_URL}"
bsc = "\${BSC_RPC_URL}"

[fuzz]
runs = 1000
max_test_rejects = 65536
EOF

echo ""
echo "Workspace ready at targets/$PROTOCOL/"
echo ""
echo "Next steps:"
echo "  1. Fill in scope.md with bounty details"
echo "  2. Clone/copy in-scope contracts to src/"
echo "  3. Run: forge build"
echo "  4. Run: ../../scripts/scan.sh src/  (automated scan)"
echo "  5. Review scan-results/summary.md"
echo "  6. Start manual review on flagged areas"
echo ""
echo "For upgrades (Watchman mode):"
echo "  ../../scripts/diff-upgrade.sh <old-tag> <new-tag>"

# Automated Detection Pipeline

Top hunters layer tools: Static Analysis → Fuzzing → Formal Verification → Manual Review. Each layer catches what the others miss. Slither alone found $3M+ in bounties. But 50% of real exploits are logic errors that no tool catches — automation is a filter, not a replacement.

---

## Layer 1: Static Analysis (run first, takes minutes)

### Slither (83+ built-in detectors)

```bash
# Install
pip3 install slither-analyzer

# Run all detectors — triage the output
slither . --print human-summary
slither . 2>&1 | tee slither-report.txt

# Focus on high/medium findings
slither . --filter-paths "test|mock|lib" --exclude-informational --exclude-low

# Specific high-value checks
slither . --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign
slither . --detect uninitialized-state,uninitialized-storage,uninitialized-local
slither . --detect arbitrary-send-erc20,arbitrary-send-eth
slither . --detect suicidal,controlled-delegatecall
slither . --detect unchecked-transfer,unchecked-lowlevel
slither . --detect locked-ether,incorrect-equality

# Print useful analysis views
slither . --print call-graph          # visualize contract interactions
slither . --print function-summary    # all functions with visibility/modifiers
slither . --print vars-and-auth       # state vars + who can write them
slither . --print require             # all require/assert statements
slither . --print modifiers           # modifier usage across functions
```

### Custom Slither Detectors (protocol-specific)

Write these for patterns Slither doesn't catch by default. Save in `detectors/`.

```python
# detectors/unchecked_oracle_staleness.py
"""Detect Chainlink oracle reads without staleness checks."""
from slither.detectors.abstract_detector import AbstractDetector, DetectorClassification
from slither.core.cfg.node import NodeType

class UncheckedOracleStaleness(AbstractDetector):
    ARGUMENT = "unchecked-oracle-staleness"
    HELP = "Chainlink latestRoundData() without staleness check"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.MEDIUM

    WIKI = "https://github.com/example"
    WIKI_TITLE = "Unchecked Oracle Staleness"
    WIKI_DESCRIPTION = "Detects calls to latestRoundData() without checking updatedAt"

    def _detect(self):
        results = []
        for contract in self.compilation_unit.contracts:
            for function in contract.functions:
                has_latest_round = False
                has_staleness_check = False
                for node in function.nodes:
                    for ir in node.irs:
                        if hasattr(ir, 'function') and hasattr(ir.function, 'name'):
                            if ir.function.name == "latestRoundData":
                                has_latest_round = True
                    if node.contains_require_or_assert():
                        source = str(node)
                        if "updatedAt" in source or "timestamp" in source:
                            has_staleness_check = True
                if has_latest_round and not has_staleness_check:
                    info = [function, " reads oracle without staleness check\n"]
                    results.append(self.generate_result(info))
        return results
```

```bash
# Run with custom detector
slither . --detect unchecked-oracle-staleness --plugin detectors/
```

### Aderyn (Rust-based, fast, extensible)

```bash
# Install
curl -L https://raw.githubusercontent.com/Cyfrin/aderyn/dev/cyfrinup/install | bash
cyfrinup

# Run analysis
aderyn .                    # full report
aderyn . --output report.md # markdown output
aderyn . --src src/         # specific directory
```

### Quick grep patterns (catch what tools miss)

```bash
# Dangerous patterns — run on every target
grep -rn "delegatecall" --include="*.sol" | grep -v "test\|mock\|lib"
grep -rn "selfdestruct\|SELFDESTRUCT" --include="*.sol"
grep -rn "tx.origin" --include="*.sol"
grep -rn "block.timestamp\|block.number" --include="*.sol" | head -30
grep -rn "ecrecover" --include="*.sol"
grep -rn "abi.encodePacked" --include="*.sol"  # hash collision risk
grep -rn "assembly" --include="*.sol" | wc -l  # manual memory = manual bugs

# Access control surface
grep -rn "onlyOwner\|onlyAdmin\|onlyRole\|require.*msg.sender" --include="*.sol" | head -30
grep -rn "function.*external\|function.*public" --include="*.sol" | grep -v "view\|pure\|test\|mock\|interface" | wc -l

# Unchecked math surface
grep -rn "unchecked" --include="*.sol" | wc -l

# Find all external calls (reentrancy surface)
grep -rn "\.call\|\.transfer\|\.send\|safeTransfer\|safeTransferFrom" --include="*.sol" | grep -v "test\|mock\|lib"

# Token handling
grep -rn "balanceOf\|totalSupply\|allowance" --include="*.sol" | head -20

# Price/oracle reads
grep -rn "latestRoundData\|getPrice\|slot0\|observe\|consult" --include="*.sol"
```

---

## Layer 2: Fuzzing (run on high-value targets, takes hours)

Fuzzing finds bugs that are hard to spot in review — complex state transitions, edge cases in math, unexpected interaction sequences.

### Foundry Invariant Testing (fastest setup)

Define what should ALWAYS be true, let the fuzzer try to break it.

```solidity
// test/invariants/VaultInvariant.t.sol
contract VaultInvariantTest is Test {
    Vault vault;
    ERC20 token;

    // Handler constrains fuzzer to valid actions
    VaultHandler handler;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), FORK_BLOCK);
        vault = Vault(DEPLOYED_ADDRESS);
        token = ERC20(TOKEN_ADDRESS);
        handler = new VaultHandler(vault, token);

        // Tell fuzzer to only call handler functions
        targetContract(address(handler));
    }

    // INVARIANT: totalAssets >= sum of all user deposits minus withdrawals
    function invariant_solvency() public {
        assertGe(
            token.balanceOf(address(vault)),
            vault.totalAssets(),
            "Vault is insolvent"
        );
    }

    // INVARIANT: no user can withdraw more than they deposited + yield
    function invariant_no_free_money() public {
        assertLe(
            handler.totalWithdrawn(),
            handler.totalDeposited() + vault.totalAssets(),
            "More withdrawn than deposited + yield"
        );
    }

    // INVARIANT: share price should never decrease (for non-lossy vaults)
    function invariant_share_price_monotonic() public {
        uint256 currentPrice = vault.totalAssets() * 1e18 / vault.totalSupply();
        assertGe(currentPrice, handler.lastSharePrice(), "Share price decreased");
    }
}

// Handler limits fuzzer to realistic actions
contract VaultHandler is Test {
    Vault vault;
    ERC20 token;
    uint256 public totalDeposited;
    uint256 public totalWithdrawn;
    uint256 public lastSharePrice;

    address[] actors;

    constructor(Vault _vault, ERC20 _token) {
        vault = _vault;
        token = _token;
        // Create bounded set of actors
        for (uint i = 0; i < 5; i++) {
            actors.push(makeAddr(string(abi.encodePacked("actor", i))));
        }
    }

    function deposit(uint256 amount, uint256 actorSeed) public {
        address actor = actors[actorSeed % actors.length];
        amount = bound(amount, 1, 1000e18);

        deal(address(token), actor, amount);
        vm.startPrank(actor);
        token.approve(address(vault), amount);
        vault.deposit(amount, actor);
        vm.stopPrank();

        totalDeposited += amount;
        _updateSharePrice();
    }

    function withdraw(uint256 shares, uint256 actorSeed) public {
        address actor = actors[actorSeed % actors.length];
        uint256 balance = vault.balanceOf(actor);
        if (balance == 0) return;
        shares = bound(shares, 1, balance);

        vm.startPrank(actor);
        uint256 assets = vault.redeem(shares, actor, actor);
        vm.stopPrank();

        totalWithdrawn += assets;
        _updateSharePrice();
    }

    function _updateSharePrice() internal {
        if (vault.totalSupply() > 0) {
            lastSharePrice = vault.totalAssets() * 1e18 / vault.totalSupply();
        }
    }
}
```

```toml
# foundry.toml — fuzzing config
[invariant]
runs = 256           # number of fuzzing campaigns
depth = 50           # calls per campaign
fail_on_revert = false
```

```bash
# Run invariant tests
forge test --match-contract Invariant -vvv
```

### Echidna (deeper fuzzing, grammar-based)

```yaml
# echidna.yaml
testMode: assertion
testLimit: 50000
seqLen: 100
deployer: "0x30000"
sender: ["0x10000", "0x20000"]
cryticArgs: ["--solc-remaps", "@openzeppelin/=lib/openzeppelin-contracts/"]
coverage: true
corpusDir: "echidna-corpus"
```

```solidity
// Echidna test contract
contract EchidnaVaultTest {
    Vault vault;

    constructor() {
        vault = new Vault(...);
    }

    // Prefix with "echidna_" for property tests
    function echidna_solvency() public returns (bool) {
        return vault.totalAssets() >= 0;
    }

    // Or use assertions
    function test_deposit_withdraw_roundtrip(uint256 amount) public {
        amount = amount % 1e24;
        if (amount < 1) return;
        // ... deposit, then withdraw, assert no profit
    }
}
```

```bash
echidna . --contract EchidnaVaultTest --config echidna.yaml
```

### Medusa (parallel fuzzing, fastest for invariant breaking)

```json
// medusa.json
{
  "fuzzing": {
    "workers": 4,
    "testLimit": 100000,
    "callSequenceLength": 100,
    "targetContracts": ["VaultInvariantTest"],
    "testing": {
      "propertyTesting": { "enabled": true },
      "assertionTesting": { "enabled": true }
    }
  }
}
```

```bash
medusa fuzz --config medusa.json
```

### Which fuzzer when

| Situation | Tool | Why |
|---|---|---|
| Quick invariant check | Foundry | Fastest setup, integrated with existing tests |
| Deep stateful fuzzing | Echidna | Best sequence shrinking, grammar-based coverage |
| Speed + parallelism | Medusa | 4+ workers, breaks invariants fastest |
| All three | Use Foundry first, then Echidna/Medusa if nothing found | Layered coverage |

---

## Layer 3: Formal Verification (high-value targets only)

Only worth the time for protocols with >$100K bounty caps and critical mathematical invariants.

### Halmos (symbolic testing, Foundry-compatible)

```bash
pip3 install halmos

# Run symbolic tests (same syntax as Foundry tests)
halmos --contract VaultSymbolicTest --function test_no_profit
```

```solidity
// Symbolic test — proves for ALL inputs, not just fuzzed ones
function test_no_profit_on_deposit_withdraw(uint256 amount) public {
    vm.assume(amount > 0 && amount < type(uint128).max);

    uint256 before = token.balanceOf(attacker);

    vm.startPrank(attacker);
    uint256 shares = vault.deposit(amount, attacker);
    uint256 assets = vault.redeem(shares, attacker, attacker);
    vm.stopPrank();

    // This must hold for ALL possible amounts
    assert(token.balanceOf(attacker) <= before);
}
```

---

## Pipeline: Putting It Together

```
Target acquired
    │
    ├── 1. grep patterns (2 min) ──→ flag dangerous patterns
    ├── 2. slither (5 min) ──→ triage high/medium findings
    ├── 3. aderyn (3 min) ──→ cross-reference with slither
    │
    ├── [If vault/lending/math-heavy]:
    │   └── 4. Write invariants (30 min) → fuzz (background)
    │
    └── 5. Manual review (hours) ──→ informed by tool output
                                      focus on what tools CAN'T find:
                                      - business logic
                                      - economic attacks
                                      - cross-contract interactions
                                      - composability issues
```

The tools eliminate false starts. You don't waste 2 hours tracing a reentrancy path only to find there's a guard — Slither already told you. Spend human time on logic bugs.

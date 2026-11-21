# Vulnerability Database

Ranked by frequency of payout on Immunefi. Each entry includes: the pattern, how to detect it, and why automated tools miss it.

---

## 1. Share/Asset Rounding Errors

**Frequency**: Most common vault bug. Pays $5K-$100K.

**The pattern**: Vault uses `shares = deposit * totalShares / totalAssets`. When `totalShares` and `totalAssets` diverge (via donation, yield, or fee), rounding creates arbitrage.

**Detection method**:
```
1. Find convertToShares() and convertToAssets() (or equivalent)
2. Check rounding direction — deposit should round DOWN (fewer shares), withdraw should round DOWN (fewer assets returned)
3. Check if rounding is CONSISTENT across all code paths
4. Look for: can totalAssets() be manipulated independently of totalShares?
```

**What tools miss**: The rounding might be correct in each function but inconsistent BETWEEN functions. Deposit rounds down, but a separate `redeem` path rounds up. Or a fee mechanism changes the ratio in a way that creates a 1-wei profit loop.

**The first-depositor variant**: Attacker deposits 1 wei, donates 1e18 tokens to vault. Now 1 share = 1e18 + 1 assets. Next depositor's deposit of < 1e18 rounds to 0 shares. Attacker redeems, stealing the deposit.

**Check**:
- Is there a minimum deposit?
- Does the vault use virtual shares/assets (ERC4626 mitigation)?
- Can tokens be sent directly to the vault (donation)?

---

## 2. Oracle Manipulation

**Frequency**: Second most common. Pays $10K-$500K.

**The pattern**: Protocol uses a price that can be moved within a single transaction (spot price from an AMM, TWAP with short window, or stale Chainlink feed).

**Detection method**:
```
1. Find every price read — grep for "latestRoundData", "getPrice", "observe", "slot0"
2. Trace: who provides the price? How fresh must it be?
3. Check: can the price be manipulated with a flashloan?
4. For Chainlink: is there a staleness check? What happens if the sequencer is down?
5. For TWAP: what's the observation window? <30 min is usually manipulable.
```

**What tools miss**: The oracle might be "correct" but the protocol uses it in a context where a 1-block delay matters. Example: liquidation uses a price that lags by 1 block, attacker sandwich-attacks the price update to liquidate a healthy position.

**Flashloan oracle attacks**:
```
1. Flashloan large amount
2. Swap to move AMM spot price
3. Call protocol function that reads the manipulated price
4. Swap back
5. Repay flashloan
6. Profit from mispriced operation
```

---

## 3. Reentrancy (Modern Variants)

**Frequency**: Still common despite awareness. Pays $25K-$1M.

Classic reentrancy (calling back into the same function) is mostly caught. These variants aren't:

**Cross-function reentrancy**: Function A updates state, calls external contract, Function B reads stale state.
```
1. Find all external calls (call, transfer, send, safeTransfer, callbacks)
2. For each: what state has NOT been updated yet?
3. Is there another function that reads that stale state?
```

**Cross-contract reentrancy**: Contract A calls Contract B, which calls back into Contract A via a different entry point.
```
1. Map all inter-contract calls
2. Check: does Contract A call Contract B BEFORE updating its own state?
3. Can Contract B call back into Contract A through any path?
```

**Read-only reentrancy (ERC-4626/Balancer style)**: No state modification, but a view function returns an inconsistent value during a callback.
```
1. Find view functions used by other protocols (totalAssets, getRate, etc.)
2. Check: during an external call, would these return stale values?
3. If another protocol reads your view function mid-callback, do they get wrong data?
```

**ERC-777 / hooks**: Tokens with transfer hooks (ERC-777, ERC-1155, some ERC-721) trigger callbacks on transfer. If protocol doesn't expect this:
```
1. Check if protocol handles arbitrary ERC-20 tokens
2. Does it use safeTransfer for ERC-721/1155?
3. Is there a reentrancy guard on all state-modifying functions?
```

---

## 4. Access Control

**Frequency**: Common in newer protocols. Pays $10K-$100K.

**Patterns to check**:
```
1. Unprotected initializers — can initialize() be called twice? By anyone?
2. Missing access control on sensitive functions (pause, setOracle, setFee)
3. Role confusion — function checks wrong role
4. Proxy admin overlap — admin of proxy can call implementation directly
5. Timelocks that can be bypassed (emergency functions without delay)
6. tx.origin used for authentication
```

**Modern twist — governance attacks**:
```
1. Can a governance proposal execute arbitrary calls?
2. Is there a timelock? Can it be bypassed?
3. Flash loan governance — borrow governance tokens, vote, return
```

---

## 5. Integer Overflow in Unchecked Blocks

**Frequency**: Increasing since Solidity 0.8+ made unchecked explicit. Pays $5K-$50K.

```solidity
// Solidity 0.8+ doesn't overflow by default, BUT:
unchecked {
    // This block CAN overflow
    uint256 result = a - b; // underflow if b > a
}
```

**Detection**:
```
1. Find all `unchecked` blocks
2. For each arithmetic operation inside: can the inputs cause overflow/underflow?
3. Are the inputs user-controlled?
4. Especially dangerous: unchecked in fee calculations, reward distributions, time deltas
```

---

## 6. Liquidation Logic Bugs

**Frequency**: Common in lending protocols. Pays $25K-$500K.

**Key checks**:
```
1. Can a position be partially liquidated to a state that's WORSE than before?
2. What happens if collateral value drops to exactly the liquidation threshold?
3. Can the liquidator receive more value than the debt they repay?
4. What happens with dust amounts — position too small to liquidate profitably?
5. Is there a race condition between price update and liquidation?
6. Can bad debt accumulate? Who absorbs it?
```

---

## 7. Token Integration Issues

**Frequency**: Very common. Pays $5K-$50K.

**Weird tokens to test against**:
```
- Fee-on-transfer tokens (actual received < amount sent)
- Rebasing tokens (balance changes without transfers)
- Tokens with blacklists (USDC, USDT)
- Tokens that return false instead of reverting (USDT approve)
- Tokens with 0 decimals or >18 decimals
- Tokens with permit() that can be front-run
- Tokens that can be paused
- Tokens with multiple entry points (TUSD proxied twice)
```

**The pattern**: Protocol assumes `balanceOf(this)` increases by exactly `amount` after `transferFrom(user, this, amount)`. With fee-on-transfer tokens, it doesn't.

**Detection**:
```
1. Does the protocol use balanceOf differences or just trust the amount parameter?
2. Does the protocol hardcode 18 decimals anywhere?
3. Does it use approve() without first setting to 0? (USDT reverts)
4. Does it handle the case where safeTransferFrom succeeds but amount received differs?
```

---

## 8. Signature Vulnerabilities

**Frequency**: Medium. Pays $10K-$100K.

**FIRST: Identify the system boundary.** Before reporting a signature issue, determine where the signature is used. Off-chain signing standards (e.g., ADR-036, EIP-191 for login) may lack replay protection by design because the transaction layer (nonces, sequence numbers) handles it. A "missing nonce" in an off-chain signing spec is not a vulnerability if the chain's ante handler enforces sequence numbers. Only report signature issues where the signature is the SOLE authorization mechanism for an on-chain state change.

```
0. System boundary check — is this signature used on-chain or off-chain?
   If off-chain: does the transaction layer already prevent replay?
   If yes: this is not a vulnerability. Stop here.
1. Missing nonce — signature can be replayed (on-chain permit, meta-tx, gasless relay)
2. Missing chain ID — signature valid across chains
3. Missing deadline — signature valid forever
4. ecrecover returns address(0) on invalid signature — is this checked?
5. Signature malleability (s-value) — can same message produce two valid signatures?
6. EIP-712 domain separator hardcoded — breaks on chain fork
```

---

## 9. Flash Loan Attacks (General Framework)

Any state that can be temporarily changed and read within one transaction is a flash loan attack surface.

```
1. Identify all "snapshot" reads — balance checks, price reads, voting power
2. For each: can the underlying value be moved with borrowed capital?
3. What protocol action depends on this read?
4. Can attacker: borrow → manipulate → exploit → restore → repay?
```

**Common flash loan targets**:
- AMM spot prices
- Token balances used as collateral calculations  
- Governance voting power
- Reward distribution calculations
- Vault share prices via donation

---

## 10. Denial of Service

**Frequency**: Common. Usually Medium severity ($1K-$10K) but can be High if funds are frozen.

```
1. Unbounded loops over user-growable arrays
2. External calls in loops (one revert blocks all)
3. Block gas limit exhaustion
4. Griefing by dust deposits (creating many small positions)
5. Front-running to make transactions revert
6. Blocking withdrawals by manipulating balance/state
```

---

## 11. Game Theory & Economic Exploits

**Frequency**: Underreported. Pays $10K-$500K when properly demonstrated.

Most auditors skip these because they require economic reasoning, not just code reading. This is an edge.

**Incentive misalignment**:
```
1. Can a rational actor profit by acting against the protocol's intended behavior?
2. Is there a dominant strategy that extracts value from other participants?
3. Can someone profitably grief other users (e.g., front-run their liquidations)?
4. Does the reward distribution create a race condition?
```

**MEV extraction by design**:
```
1. Does the protocol create MEV opportunities? (e.g., liquidation rewards, arbitrage)
2. Can searchers extract more value than intended?
3. Can block proposers manipulate ordering to profit from protocol operations?
4. Does the protocol assume transaction ordering that miners/validators can violate?
```

**Governance attacks**:
```
1. Flash loan governance: borrow governance tokens, vote, return
2. Can a single proposal execute arbitrary calls?
3. Is the timelock meaningful, or can it be bypassed via emergency functions?
4. Can someone accumulate just enough voting power to pass malicious proposals?
```

**Oracle Extractable Value (OEV)**:
```
1. Can someone profit from knowing the next oracle update?
2. Can they front-run the oracle update to position for liquidations?
3. Does the protocol assume oracle updates are atomic with state changes?
```

---

## 12. Proxy & Upgrade Bugs

**Frequency**: Medium. Pays $25K-$500K.

```
1. Uninitialized implementation behind proxy — can anyone call initialize()?
2. Storage collision between proxy and implementation
3. selfdestruct in implementation destroys proxy's logic
4. Function selector clashes between proxy admin and implementation
5. Upgrade to incompatible storage layout
6. UUPS missing _authorizeUpgrade protection
7. Transparent proxy — admin can't call implementation functions (or can they?)
```

**Real example**: Wormhole's $10M bug was an uninitialized proxy.

---

## Payout Calibration (what bug classes pay what)

**$1M+ payouts — the bug classes that produce them:**
- Uninitialized proxy implementations
- Infinite spend / infinite mint
- Logic errors enabling direct fund theft
- Consensus bypass on L1/L2

**$100K-$1M payouts:**
- Rounding errors (especially in vault/LP share math)
- Custom approval/access control logic flaws
- Flash loan oracle manipulation
- Logic errors in financial math (interest, fees, conversions)

**$10K-$100K payouts:**
- Access control on sensitive functions
- Protocol insolvency bugs
- Liquidation math edge cases
- Chain-level fee/gas theft
- Bridge token theft

**$0 payouts (valid bugs, not paid — learn from these patterns):**
- "Known issue" defense without proof
- "Out of scope" retroactive rule changes
- Team ghosting / indefinite silence
- Disputed severity with moving goalposts
- "Won't fix" for design-level issues

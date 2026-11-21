# Advanced Attack Vectors (2025-2026)

These are the patterns top hunters prioritize. Based on actual loss data — not theory.

---

## Access Control ($1.83B lost in H1 2025 — the #1 bug class)

59% of all losses. This is not just "missing onlyOwner." Modern access control bugs are subtle.

**What to check beyond the basics:**

```
□ Unprotected initializers on implementation contracts behind proxies
  - Can anyone call initialize() on the implementation directly?
  - Does the proxy's initialize protect the implementation too?
  - UUPS: is _authorizeUpgrade() properly restricted?

□ Role confusion in multi-role systems
  - ADMIN can do X, OPERATOR can do Y — but can OPERATOR reach X through a different path?
  - Are roles checked consistently across all entry points?
  - Can a role be granted to address(0)? What happens?

□ Cross-contract privilege escalation
  - Contract A trusts Contract B (whitelisted caller)
  - Can attacker interact with Contract B to indirectly call Contract A's privileged functions?
  - Are trust relationships one-way or can they be exploited bidirectionally?

□ Governance + timelock bypass
  - Emergency functions that skip the timelock
  - Governance proposals that execute arbitrary calls
  - Flash loan governance: borrow tokens → vote → execute → return
  - Quorum manipulation via strategic voting/delegation timing

□ Signature-based access control
  - Is the signer role validated? Can it be rotated without revoking old signatures?
  - Are there nonce gaps that allow replay?
  - Cross-chain replay (missing chainId in domain separator)
  - Missing deadline — signatures valid forever
```

**Real-world patterns:**
- Multisig key compromise → billions in cumulative losses
- N/M threshold too low (e.g., 7/10 keys compromised = full control)
- Uninitialized proxy implementations → 8-figure payouts

---

## Precision Loss & Rounding ($128M+ in 2025 alone)

This is not just "round up vs round down." Top hunters look for amplifiable rounding.

**Amplification techniques:**

```
□ Loop amplification
  - Can an attacker repeat deposit/withdraw in a loop, profiting 1 wei each time?
  - With flash loans, they can do this with massive capital → massive profit
  - Real examples: 9-figure drains from rounding error amplification

□ Cross-function rounding inconsistency
  - deposit() rounds one way, mint() rounds another
  - Internal accounting uses one precision, external view uses another
  - Fee application changes the rounding direction

□ Token decimal mismatch amplification
  - Protocol uses 18-decimal math, but token has 6 decimals (USDC)
  - 1 wei of rounding in 18-decimal space = 1e12 wei in 6-decimal space
  - Real examples: 7-8 figure losses from decimal precision glitches

□ Accumulated rounding in interest/reward calculations
  - rewardPerToken accumulates tiny rounding errors over thousands of blocks
  - Compounding interest with per-second granularity vs per-block
  - Check: does the accumulated error grow linearly or quadratically with time?
```

**The flash loan + rounding combo:**
```
1. Flash loan max capital
2. Deposit into vault (rounding gives you 1 extra wei of shares)
3. Withdraw (rounding gives you 1 extra wei of assets)
4. Repeat N times in one transaction
5. Profit = N * rounding_error * (capital / minimum_deposit)
6. Repay flash loan
```

If `rounding_error * loops * capital > flash_loan_fee`, it's exploitable.

---

## Cross-Chain & Bridge Attacks ($2.8B stolen, 40% of all Web3 hacks)

### 12 primary attack vectors:

```
1. Private key compromise of bridge validators/multisig
   - How many signers? What threshold?
   - Are keys in HSMs or hot wallets?
   - Can one compromised signer escalate to full control?

2. Deposit event spoofing
   - Can an attacker create a deposit event without actually depositing?
   - Does the bridge verify the deposit transaction, or just the event?
   - Can events from non-bridge contracts be confused for bridge events?

3. Message verification bypass
   - Can withdrawal proofs be forged?
   - Is the Merkle proof verification complete?
   - Can an old proof be replayed?

4. Finality assumptions
   - Does the bridge wait for sufficient confirmations?
   - What happens during a chain reorg after the bridge processed a deposit?
   - Can L2 sequencer manipulate transaction ordering to exploit the bridge?

5. Token mapping errors
   - Can the wrong token be minted on the destination?
   - Decimal mismatch between source and destination tokens?
   - What if a token is upgraded on one chain but not the other?

6. Nonce/sequence replay
   - Can the same message be processed twice?
   - Are nonces sequential? Can gaps be exploited?
   - Cross-rollup replay (same message valid on multiple L2s)?

7. Relayer manipulation
   - Can the relayer censor, reorder, or modify messages?
   - What if the relayer submits partial data?
   - Can the relayer front-run bridge users?

8. Liquidity pool bridge draining
   - AMM-based bridges: can the pool be drained via price manipulation?
   - Are there per-transaction or per-block limits?
   - Can flash loans amplify a bridge pool drain?

9. Governance attack on bridge parameters
   - Can bridge fee, limits, or token mapping be changed maliciously?
   - Is there a timelock on bridge configuration changes?

10. Storage collision in upgradeable bridges
    - Proxy storage layout compatibility after upgrade
    - Can an upgrade corrupt critical state (e.g., processed nonces map)?

11. ZK proof verification bugs (ZK bridges)
    - Is the verifier contract correctly implementing the proof system?
    - Can a valid-looking but false proof be constructed?
    - Edge cases in field arithmetic?

12. Cross-chain sandwich attacks (NEW 2025)
    - Monitor source chain deposit events
    - Front-run on destination chain before bridge message arrives
    - Back-run after bridge processes the deposit
```

---

## L2-Specific Vulnerabilities

```
□ Sequencer manipulation
  - L2 sequencer controls transaction ordering → free MEV extraction
  - Sequencer downtime: what happens to time-sensitive operations?
  - Forced transaction inclusion via L1 → can bypass sequencer censorship
  - Chainlink L2 sequencer uptime feed: is it checked?

□ L1 ↔ L2 message timing
  - L1 → L2 messages have delay. Can state change on L1 during the delay?
  - L2 → L1 withdrawals: challenge period exploits
  - Can an attacker submit an L2 → L1 message before the state root is final?

□ Gas price discrepancy
  - L2 gas is cheap → attacker can afford operations that would be
    prohibitively expensive on L1
  - Unbounded loops that are "safe" on L1 due to gas limits may
    be exploitable on L2 with higher block gas limits

□ Precompile/opcode differences
  - Some L2s have different opcode behavior (e.g., PUSH0 support)
  - Custom precompiles that don't exist on L1
  - block.number / block.timestamp may behave differently
```

---

## Composability & Integration Risks

The "money lego" problem: protocols assume other protocols behave correctly. When they don't, cascading failures happen.

**What to check:**

```
□ External protocol assumptions
  - Does the protocol assume an AMM pool will always have liquidity?
  - Does it assume a lending market will always accept deposits?
  - Does it assume a stablecoin will maintain its peg?
  - What if an integrated protocol pauses, upgrades, or gets hacked?

□ Read-only reentrancy via composability
  - Protocol A reads a view function from Protocol B
  - Protocol B is mid-transaction → view function returns stale data
  - Protocol A makes a decision based on stale data
  - Classic: Balancer/Curve pool.getRate() during flash loan callback

□ Oracle dependency chains
  - Protocol uses Oracle A, which reads from Protocol B, which reads Oracle C
  - Manipulation of Oracle C propagates through the chain
  - Each hop can amplify the manipulation

□ Flash loan amplification of composability bugs
  - Small mispricing across 3 protocols → sandwich with flash loan capital
  - Calculate: does arbitrage profit > flash loan fee?

□ Token approval chains
  - User approves Protocol A, which interacts with Protocol B
  - Does Protocol B now have indirect access to user funds through Protocol A?
  - Can a malicious upgrade to Protocol B exploit Protocol A's approvals?
```

**Real-world patterns:**
- Pricing mechanism bugs in yield-bearing tokens used as cross-protocol collateral (7-figure losses)
- LP accounting rounding amplified through dozens of chained withdrawals (8-figure losses)

---

## Upgradeable Proxy Vulnerabilities (updated for 2025)

```
□ UUPS-specific
  - Check OZ version for known uninitialized implementation vulnerabilities
  - Is _authorizeUpgrade() restricted? (Not just onlyOwner — check the full auth chain)
  - Can the implementation contract be self-destructed?
  - Is the upgrade function behind a timelock?

□ Diamond proxy (EIP-2535)
  - Facet function selector collisions
  - Storage layout conflicts between facets
  - Can a malicious facet be added that overwrites another facet's storage?

□ Transparent proxy
  - Admin can only call admin functions, not implementation functions
  - But: can admin reach implementation through a different proxy path?
  - Storage collision between proxy admin slot and implementation storage

□ Beacon proxy
  - Single beacon upgrade affects ALL proxy instances
  - Is the beacon upgradeable? By whom?
  - Can one proxy instance be upgraded independently?

□ Storage layout after upgrade
  - New implementation adds storage variables — do they collide?
  - Inheritance order change → storage shift
  - Mapping/array storage slot calculation differences
  - Real examples: 6-figure losses from temporary storage slot overwrites during upgrades
```

---

## Signature & Cryptography Bugs

```
□ EIP-712 domain separator issues
  - Hardcoded chainId → breaks on chain fork (every chain fork!)
  - Missing verifyingContract → signature valid for any contract
  - name/version mismatch → silent domain change

□ ECDSA edge cases
  - ecrecover returns address(0) for invalid signatures — is this checked?
  - Signature malleability: flip s-value to create second valid signature
  - Can same message hash be constructed from different parameters? (hash collision)

□ Nonce management
  - Nonce consumed before execution → revert → nonce wasted → no replay protection
  - Nonce gaps: can skipping a nonce permanently DOS future operations?
  - Per-key nonces vs global nonces — race conditions

□ Permit front-running
  - Attacker sees permit in mempool → front-runs with their own permit call
  - Original permit tx reverts (nonce consumed) → user's operation fails
  - Check: does the protocol handle permit failure gracefully?

□ Multi-signature schemes
  - Threshold changes without revoking old signatures
  - Signer rotation: are old signers' pending signatures invalidated?
  - Can the same approval be used across multiple operations?
```

---

## Weird ERC20 Tokens (expanded)

Beyond fee-on-transfer and rebasing. Check against the [weird-erc20 repo](https://github.com/d-xo/weird-erc20).

```
□ Tokens that return false instead of reverting (USDT approve)
  - Protocol uses token.approve() without checking return value
  - SafeERC20 handles this — but does the protocol use it everywhere?

□ Tokens with multiple entry points (double proxy like TUSD)
  - Two addresses point to same token
  - Protocol tracks by address → same token counted twice as collateral

□ Tokens with blocklists (USDC, USDT)
  - Blocked address can't transfer → withdrawal reverts → funds stuck
  - If collateral token is blocked for protocol address → all funds frozen

□ Tokens that can be upgraded (proxy tokens)
  - Token behavior can change after protocol deployment
  - New fee mechanism, new transfer restrictions
  - Protocol assumptions become invalid post-upgrade

□ Tokens with max supply or per-holder limits
  - Transfer reverts if recipient would exceed limit
  - Protocol can't receive tokens → DOS

□ Tokens with non-standard decimals
  - 0 decimals (some NFT wrappers)
  - 24+ decimals (YAM)
  - Protocol math overflow/underflow with extreme decimals
```

---

## MEV & Economic Modeling

Top hunters don't just find bugs — they model economic feasibility.

**For every finding, calculate:**

```
1. Attack capital required (can it be flash-loaned?)
2. Gas cost of the attack transaction
3. Expected profit = stolen_amount - gas_cost - flash_loan_fee
4. Is the attack frontrunnable by MEV bots? (if so, the attacker
   competes with bots and profit margin shrinks)
5. Can the attack be executed atomically (single tx) or does it
   require multiple blocks? (multi-block = much higher risk for attacker)
```

**MEV-aware attack patterns:**
```
□ Protocol creates MEV by design
  - Liquidation rewards → MEV bots compete → user gets worse price
  - Auction mechanisms → can be sandwiched
  - Oracle updates → front-runnable
  - Reward distributions → timing attacks

□ Sandwich via protocol design
  - Protocol function moves a price → sandwichable by design
  - Not a bug in the protocol, but in its interaction with MEV
  - Report as: "protocol design creates extractable value for MEV"

□ Just-in-time liquidity attacks
  - Add liquidity right before a large swap, remove right after
  - Extract fees without bearing price risk
  - Protocol-level mitigation: minimum lock time for LPs
```

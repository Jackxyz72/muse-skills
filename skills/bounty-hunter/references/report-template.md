# Immunefi Bug Report Template

Write reports that get accepted. The #1 reason reports are rejected: unclear impact.

---

## Report Structure

```markdown
## Bug Description

[2-3 sentences. What is the vulnerability? Lead with IMPACT, not the technical root cause.]

Example: "An attacker can steal all deposited funds from the Vault contract by exploiting 
a rounding error in the share-to-asset conversion. The attack requires no special 
permissions and costs only gas fees to execute."

NOT: "In line 142 of Vault.sol, the division rounds down when it should round up, 
which means that..." (Nobody reads past this)

## Impact

[What can the attacker gain? What does the protocol/users lose? Be specific with numbers.]

- Attacker profit: Up to 100% of vault TVL
- User impact: Complete loss of deposited funds
- Likelihood: High (no special conditions required)

## Risk Classification

[Must match Immunefi's severity definitions EXACTLY]

- **Critical**: Direct theft of user funds, permanent freezing of funds >$10M
- **High**: Theft of unclaimed yield, permanent freezing of funds <$10M, temporary freezing >1 week
- **Medium**: Griefing (no profit), temporary freezing <1 week, smart contract fails to deliver promised returns
- **Low**: Contract fails to deliver promised returns for edge cases

Claim the LOWEST defensible severity. Overclaiming gets reports rejected.

## Vulnerability Detail

### Root Cause

[Technical explanation. Reference specific lines of code.]

In `Vault.sol:142`, the `convertToShares()` function:
```solidity
function convertToShares(uint256 assets) public view returns (uint256) {
    return assets * totalSupply() / totalAssets(); // rounds DOWN
}
```

This rounds DOWN, giving the depositor fewer shares. However, in `withdraw()` at line 189:
```solidity
function convertToAssets(uint256 shares) public view returns (uint256) {
    return shares * totalAssets() / totalSupply(); // ALSO rounds DOWN
}
```

This ALSO rounds down, but in withdraw context, rounding down favors the withdrawer 
because [explain the specific math]...

### Attack Path

1. Attacker calls `deposit()` with X tokens
2. [specific step with exact function call]
3. [specific step]
4. Attacker receives Y tokens, profiting Y - X = Z

### Preconditions

- Vault must have at least N tokens deposited (or: no preconditions)
- [any other requirements]

## Proof of Concept

[Foundry test. Must run with a single command.]

### Setup
```bash
git clone <repo>
cd <repo>
forge install
```

### Run
```bash
forge test --match-test test_exploit_name -vvvv --fork-url $ETH_RPC_URL
```

### Test Code

```solidity
// [full PoC code here]
```

### Expected Output
```
[paste the actual forge test output showing the exploit succeeding]
```

## Recommended Fix

[Optional but increases credibility. Keep it short.]

```solidity
// In convertToAssets(), round UP instead of DOWN for withdrawals:
function convertToAssets(uint256 shares) public view returns (uint256) {
    return shares * totalAssets() + totalSupply() - 1) / totalSupply(); // rounds UP
}
```
```

---

## Common Mistakes That Get Reports Rejected

1. **Overclaiming severity**: Calling a Medium "Critical" — auto-reject at many programs
2. **No PoC**: "I believe this could be exploited" — rejected. Show the code.
3. **PoC doesn't compile**: Test it yourself before submitting
4. **Theoretical attack with impractical preconditions**: "If the attacker had $1B..." — not a real bug
5. **Duplicate of known issue**: Check the protocol's audit reports and known issues list FIRST
6. **Out of scope**: Check the scope CAREFULLY. Many programs exclude certain contracts.
7. **Gas optimization disguised as security bug**: Not a vulnerability
8. **Informational finding dressed up as Medium**: Centralization risk is usually informational

---

## Pre-Submission Gate 1: Falsification (do this BEFORE the quality checklist)

```
□ I spent 30+ minutes trying to DISPROVE my own finding
□ I checked every system layer that might prevent this attack:
  - Transaction layer (nonces, sequence numbers, gas limits)
  - Signing layer (domain separators, deadlines, chain IDs)
  - Application layer (access control, pausability, rate limits)
  - Off-chain layer (keepers, monitoring, circuit breakers)
□ I can explain why NONE of these layers blocks the attack
□ I checked if this is an off-chain concern reported as on-chain (e.g., signing
  standard missing replay protection, but the chain's tx layer has nonces)
□ I searched the project's audit reports and known issues for this exact pattern
□ I can state the attack in one sentence without hedging:
  "An attacker can _____ to steal/freeze _____"
```

If ANY of these fail, DO NOT proceed to the quality checklist. Kill the finding.

## Pre-Submission Gate 2: Quality Checklist

```
□ PoC compiles and runs successfully (forge test passes)
□ Impact is clearly stated in first 2 sentences
□ Severity matches Immunefi's definitions (not your opinion)
□ Bug is in-scope (check the program page)
□ Bug is not a known issue (check audit reports)
□ Attack is economically rational (profit > cost)
□ You've re-read the report as if you're the triager — is it clear?
□ No sensitive info (your real name, etc.) unless you want to be identified
□ Bounty rules have been archived/screenshotted
□ You're submitting the FIRST bug found — don't hold multiple bugs
```

---

## After Submission: Handling Disputes

From real hunter experience (WhiteHatMage, Trust, others who had "Not Paid" outcomes):

**Normal timeline**: Response within 48 hours, severity discussion within a week, payout within 2-4 weeks.

**If the team pushes back on severity:**
- Stay calm. Reference the bounty rules and Immunefi's severity definitions.
- Provide additional evidence, not additional arguments.
- Use the "moving goalposts" defense: if they keep changing their objection, pin them down on ONE specific disagreement and resolve it before moving on.

**If the team claims "known issue":**
- Ask for proof (prior report, audit finding, internal ticket with timestamp)
- "Known issue" without documentation is a red flag
- Escalate to the platform if proof isn't provided

**If the team goes silent:**
- Follow up once after 48 hours
- Escalate to the platform after 1 week of silence
- If the platform doesn't help, reassess whether to continue hunting this program

**When to walk away:**
- Rule changes after disclosure
- Claims of prior knowledge without proof
- Haggling over clearly defined severity
- More than 30 days without resolution

Getting scammed happens. The only real fix is avoiding bad projects in the first place (see `references/target-selection.md`).

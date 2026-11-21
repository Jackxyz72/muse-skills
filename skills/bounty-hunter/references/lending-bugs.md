# Lending Protocol Bugs

Lending is the richest attack surface in DeFi. More money has been lost from lending bugs than any other category.

---

## 1. Oracle Manipulation → Liquidation

**Severity**: Critical ($100K-$1M+)

**The attack**: Manipulate the price oracle to make a healthy position appear undercollateralized, then liquidate it at a discount.

```
□ What oracle does the protocol use? (Chainlink, TWAP, spot price)
□ Is there a staleness check on oracle data?
□ What happens if the Chainlink aggregator returns 0 or negative?
□ Can the oracle price be moved with a flash loan?
□ Is there a price deviation check? (reject updates > X% change)
□ Sequencer uptime feed — checked on L2s?
```

**Chainlink-specific**:
```solidity
// DANGEROUS — no staleness check
(, int256 price, , , ) = priceFeed.latestRoundData();

// BETTER — but check ALL of these
(uint80 roundId, int256 price, , uint256 updatedAt, uint80 answeredInRound) = 
    priceFeed.latestRoundData();
require(price > 0, "Invalid price");
require(updatedAt > block.timestamp - MAX_STALENESS, "Stale price");
require(answeredInRound >= roundId, "Stale round");
```

---

## 2. Liquidation Math Errors

**Severity**: Critical ($50K-$500K)

```
□ Can liquidator repay less debt than they should?
□ Can liquidator receive more collateral than the debt warrants?
□ Can partial liquidation leave a position in a WORSE health factor?
□ What happens with dust positions (debt < gas cost to liquidate)?
□ Can the same position be liquidated multiple times in one block?
□ What happens if collateral drops below the liquidation bonus?
   (i.e., liquidation is unprofitable → bad debt accumulates)
```

**The partial liquidation trap**: Liquidator repays 50% of debt but receives 60% of collateral (because of bonus). Position's health factor is now WORSE. Can cascade.

---

## 3. Interest Rate Model

**Severity**: Medium-High ($10K-$100K)

```
□ Can interest rate be manipulated by flash-borrowing/repaying?
□ What happens at 100% utilization? Can interest rate overflow?
□ Is interest accrual calculated per-block or per-second? Rounding?
□ Can someone force the interest rate to an extreme by manipulating utilization?
□ Flash loan: borrow → utilization spikes → interest rate spikes →
  other borrowers' positions become undercollateralized → liquidate them
```

**Conditional branch asymmetry** (common in Aave/Compound forks):

Interest rate models typically have two branches: below optimal utilization and above it. When porting from one language to another (Solidity → Clarity, Solidity → Rust), it's common to forget per-branch logic. Check:
```
□ Does each branch of the rate model apply the reserve factor?
□ Are fees/spreads consistent across both branches?
□ If the original has if/else with different parameters, does the port match?
□ Simulate: rates at 50% utilization vs 95% utilization — do both branches
  produce economically correct results? (supply rate < borrow rate, protocol accrues fees)
```
This pattern produces protocol insolvency bugs — the protocol lends at rates that don't cover its borrowing cost in one branch, slowly draining reserves.

---

## 4. Collateral Factor / LTV Manipulation

**Severity**: High ($25K-$200K)

```
□ Can governance change collateral factors instantly? (no timelock)
□ If collateral factor drops, are existing positions liquidatable immediately?
□ Can an asset be both collateral and borrowable? (self-referential loop)
□ Can depositing collateral A allow borrowing B, which is used as collateral 
  for C, creating a leverage loop?
```

---

## 5. Bad Debt Socialization

**Severity**: Medium-High ($10K-$100K)

When a position's collateral is worth less than its debt, someone absorbs the loss.

```
□ Who absorbs bad debt? Protocol reserves? Other depositors? Insurers?
□ Can attacker intentionally create bad debt to harm other users?
□ Is bad debt checked and handled in ALL code paths? 
  (sometimes forgotten in edge-case liquidation paths)
□ Can bad debt in one market affect another market?
```

---

## 6. Flash Loan → Borrow → Exploit Loop

```
1. Flash loan large amount of Token A
2. Deposit Token A as collateral
3. Borrow maximum Token B against collateral
4. Use Token B to exploit something (manipulate price, attack another protocol)
5. Repay Token B borrow
6. Withdraw Token A collateral
7. Repay flash loan

Total cost: flash loan fee (often 0)
```

Check: Does the protocol allow deposit + borrow in the same transaction?

---

## 7. Token-Specific Lending Bugs

```
□ Fee-on-transfer tokens: actual collateral < recorded collateral
□ Rebasing tokens: collateral value changes without transfers
□ Tokens that can be paused: what if collateral token is paused during liquidation?
□ Non-standard decimals: math assumes 18 but token has 6 (USDC)
□ Tokens with permit: can someone front-run a permit to cause revert?
```

---

## Quick Triage for Lending

```
1. [ ] Identify ALL oracle price sources
2. [ ] Check staleness handling on each oracle
3. [ ] Calculate: flash loan → deposit → max borrow → what can you do?
4. [ ] Check liquidation math with extreme values (dust, max, 100% util)
5. [ ] Check: can the same collateral be used in multiple positions?
6. [ ] Check: interest accrual rounding (per-second vs per-block)
7. [ ] Check: what happens when utilization = 100%? Can depositors withdraw?
```

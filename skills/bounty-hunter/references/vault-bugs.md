# Vault & Yield Protocol Bugs

This is the highest-density bug class in DeFi. If the target is a vault, yield aggregator, or any share-based token system, check everything here.

---

## 1. Share Inflation / First Depositor

**Severity**: Critical ($50K-$500K)

The attack: First depositor gets 1 share for 1 wei, then donates tokens directly to vault. Share price inflates. Next depositor's deposit rounds to 0 shares.

**Check sequence**:
```
□ What happens when totalSupply == 0 and someone deposits?
□ Can tokens be transferred directly to the vault address?
□ Is there a minimum deposit amount?
□ Does the vault use virtual shares/assets offset? (OpenZeppelin 4626 uses 1e0 offset)
□ Is there a "dead shares" mechanism (initial deposit locked)?
```

**If NO mitigation exists**: write the PoC immediately, this is likely a valid critical.

---

## 2. Rounding Direction Inconsistency  

**Severity**: Medium-High ($5K-$100K)

ERC-4626 standard says: round DOWN on deposit (user gets fewer shares), round DOWN on withdraw (user gets fewer assets). This protects the vault.

**Check**:
```
□ deposit/mint: Does convertToShares round DOWN?
□ withdraw/redeem: Does convertToAssets round DOWN?  
□ Are ALL code paths consistent? (Check: deposit, withdraw, mint, redeem, 
  liquidate, harvest, compound — each one separately)
□ Preview functions match actual execution?
□ Does fee application change rounding direction?
```

**The subtle variant**: Rounding is correct in normal flow, but a fee mechanism or reward distribution creates a different conversion rate that rounds in the user's favor.

---

## 3. Donation / Direct Transfer Attack

**Severity**: Medium-Critical ($10K-$200K)

If `totalAssets()` reads `token.balanceOf(address(this))`, anyone can change the share price by sending tokens directly.

**Impact vectors**:
```
□ Inflate share price → next depositor gets fewer shares
□ Deflate share price → liquidation of healthy positions
□ Sandwich: donate before victim's deposit, withdraw after
□ Manipulate reward calculations that depend on totalAssets
```

**Check**: How is totalAssets() calculated?
- `balanceOf(this)` → vulnerable to donation
- Internal accounting variable → safer, but check all update paths

---

## 4. Withdrawal Queue / Delayed Withdrawal Bugs

**Severity**: Medium-High ($10K-$100K)

Protocols with withdrawal delays (staking, locked vaults) have bugs at the boundaries.

```
□ Can a withdrawal request be processed at a stale price?
□ What happens if the vault's value drops between request and fulfillment?
□ Can attacker front-run the fulfillment with a deposit to dilute?
□ Can withdrawal requests be canceled and re-submitted to game timing?
□ Is there a gap between "requested" and "claimable" where funds earn no yield but are still at risk?
```

---

## 5. Strategy Accounting Mismatch

**Severity**: High ($25K-$200K)

Vaults that deploy to strategies can have accounting drift.

```
□ What if strategy reports a loss? How is it distributed?
□ Can strategy report a false profit (e.g., via token donation to strategy)?
□ Is there a delay between strategy profit and vault accounting update?
□ What happens if strategy is paused/revoked while users have pending withdrawals?
□ Can the vault be drained by repeatedly depositing and withdrawing during accounting gaps?
```

---

## 6. Fee Calculation Bugs

**Severity**: Medium ($5K-$50K)

Fees interact with share math in surprising ways.

```
□ Is the fee taken before or after share conversion?
□ Can fee be set to 100%? To > 100%?
□ Management fee + performance fee + entry fee + exit fee — 
  do they compound incorrectly?
□ Can fees be sandwiched? (deposit before fee harvest, get free yield)
□ Are fee shares minted to fee recipient? Does this dilute existing holders unfairly?
```

---

## 7. Multi-Asset Vault Issues

**Severity**: High ($25K-$200K)

Vaults handling multiple tokens have extra attack surface.

```
□ How is the "value" of the vault calculated across assets?
□ Can one asset's price manipulation affect another asset's accounting?
□ Deposit in cheap asset, withdraw in expensive asset?
□ Are all assets' balances updated atomically?
□ What happens if one asset depegs or is paused?
```

---

## 8. Harvest / Compound Timing

**Severity**: Medium ($5K-$50K)

```
□ Can attacker deposit right before harvest, capture yield, withdraw right after?
□ Is there a "sandwich the harvest" attack?
□ Does harvesting create a MEV opportunity?
□ What happens if harvest reverts? Can it block withdrawals?
```

---

## Quick Triage Checklist

Run through this in the first 30 minutes on any vault:

```
1. [ ] Read totalAssets() — is it balanceOf or internal tracking?
2. [ ] Read convertToShares() — which direction does it round?
3. [ ] Read convertToAssets() — which direction does it round?
4. [ ] Read deposit() — does it use convertToShares consistently?
5. [ ] Read withdraw() — does it use convertToAssets consistently?
6. [ ] Check: what happens with totalSupply == 0?
7. [ ] Check: can tokens be sent directly to vault?
8. [ ] Check: are there any unchecked blocks in the math?
9. [ ] Check: what's the fee structure and where is it applied?
10. [ ] Check: are there any external calls before state updates?
```

If items 1-3 reveal issues, stop and write a PoC. These are the highest-probability payouts.

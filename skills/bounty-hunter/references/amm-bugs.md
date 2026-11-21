# AMM / DEX Bugs

## Key Vulnerabilities

**Price manipulation via flash loan**: Borrow → swap to move price → exploit dependent protocol → swap back → repay. Check: does anything read spot price from pool?

**Sandwich attacks on swaps**: Front-run user's swap with buy, back-run with sell. Check: is slippage protection enforced? Can the deadline be set to far future?

**LP share accounting**: Same rounding issues as vaults. Check: mint/burn share math with extreme values (first LP, last LP, dust amounts).

**Fee-on-transfer token handling**: Pool math assumes exact amounts. Fee-on-transfer breaks invariant.

**Reentrancy via token callbacks**: Uniswap V3 flash callbacks, ERC-777 hooks during swaps.

**Concentrated liquidity edge cases**: Tick boundary math, position NFT manipulation, uncollected fees.

---

# Bridge Bugs

## Key Vulnerabilities

**Message replay**: Can the same bridge message be processed twice? Cross-chain, cross-rollup?

**Finality mismatch**: Source chain reorganizes after bridge message sent. Check: does the bridge wait for sufficient confirmations?

**Token mapping errors**: Bridged token on destination doesn't match source. Decimal mismatch. Wrong token address.

**Relayer manipulation**: Can the relayer censor, reorder, or modify messages?

**Proof verification**: For ZK/optimistic bridges — can a false proof be submitted? Is the verification complete?

---

# Staking Protocol Bugs

## Key Vulnerabilities

**Reward distribution rounding**: `rewardPerToken` accumulated over time. Rounding errors compound. Check: can attacker stake/unstake rapidly to extract rounding dust?

**Late staker gets early rewards**: New staker deposits, immediately claims rewards earned before their deposit.

**Withdrawal delay manipulation**: Unstake, wait, restake to game the timing of reward snapshots.

**Slashing conditions**: Can an attacker trigger slashing of another validator? What happens to delegators?

**Validator set manipulation**: Flash-stake to influence validator selection, then unstake.

**Reward token donation**: Send reward tokens directly to contract to inflate `rewardPerToken` for existing stakers.

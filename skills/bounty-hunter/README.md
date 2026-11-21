# lulz

Smart contract vulnerability hunting toolkit for DeFi bug bounties. Built around a Claude Code skill that systematizes the hunt — from target selection to PoC to submission.

## Structure

```
SKILL.md              — Core hunting skill (target scoring, vuln tiers, hunter modes, submission rules)
references/
  vulndb.md           — Vulnerability database
  target-selection.md — Target selection framework
  report-template.md  — Immunefi submission template
  foundry-poc.md      — Foundry PoC template
  vault-bugs.md       — Vault/yield protocol bug patterns
  lending-bugs.md     — Lending protocol bug patterns
  amm-bugs.md         — AMM/DEX/bridge/staking bug patterns
scripts/
  init-target.sh      — Initialize a new target workspace
targets/              — Per-target working directories
```

## Usage

Works as a Claude Code skill. Open any smart contract codebase and the skill activates for security review, bug hunting, PoC generation, and report writing.

Quick start:
1. Pick a target — `SKILL.md` Phase 0 scores programs in <5 minutes
2. Verify scope — confirm in-scope contracts match the bounty page exactly
3. Hunt — systematic check of high-payout vulnerability categories
4. PoC — always fork mainnet, always assert profit/loss
5. Submit — use the pre-submission checklist (16 items, all must be YES)

## Platforms

Immunefi (primary), HackenProof, Cantina, Code4rena, Sherlock.

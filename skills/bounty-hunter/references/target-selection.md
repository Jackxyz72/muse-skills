# Target Selection Strategy

The most important decision in bounty hunting is NOT how you audit — it's WHAT you audit. This guide synthesizes battle-tested selection frameworks from professional hunters.

---

## Why Most Time is Wasted

Bounty payouts follow a **power law**. One Critical can be worth dozens of Highs. The Immunefi writeups show: Wormhole paid $10M, Aurora paid $6M, Optimism paid $2M — while many valid bugs went unpaid entirely. Your expected value per hour varies by 1000x depending on target selection.

**Two ways to waste time** (from Joran Honig):
1. Hunting in projects whose code is super clean and secure (unlikely to find anything)
2. Hunting in projects that are unlikely to pay out if you find something

---

## The Four Signals

### 1. Complexity (where bugs hide)

Bugs themselves are usually simple. What makes them hard to spot is the attack path. Layers of logic and assumptions stack until a small mistake becomes exploitable.

**High complexity targets:**
- Blockchains and L1/L2 implementations (highest payouts: $2M-$10M)
- Large DeFi protocols with many contracts and integrations
- Math-heavy systems (AMMs, options, perpetuals)
- Systems with external or cross-chain integrations
- Bridges and diamond proxy setups
- Multi-component systems where contracts trust each other

**Low complexity targets (usually skip):**
- Simple token contracts
- Single-function utilities
- Standard ERC-20/721 without extensions
- Pure wrappers around well-audited code

### 2. Innovation (where bugs are born)

Complexity hides bugs, but innovation **creates** them. When a project takes a new approach, there's a good chance some attack path wasn't fully considered.

**Innovation layers to watch:**
- **Conceptual**: New designs or specifications (new yield mechanisms, new consensus)
- **Implementation**: Existing idea in a new way (porting to new language/VM, novel math optimization)
- **Ecosystem maturity**: New chains and uncommon languages have more basic issues simply because fewer people have checked them

**Where innovation is appearing now:**
- Real World Assets (RWA) protocols
- Zero-knowledge systems and ZK-EVMs
- Privacy technology
- AI integrations with DeFi
- New L2/L3 chains
- Intent-based architectures
- Restaking / liquid staking derivatives

### 3. Optimization (where subtle bugs creep in)

Many bugs originate from optimization. Gas optimizations, heavy use of assembly, manual memory management, rewritten math expressions, or performance-focused changes all add complexity.

**Watch especially for:**
- `unchecked` blocks in Solidity 0.8+
- Raw assembly / inline Yul
- Bit manipulation for gas savings
- Refactored code (even "cleanup" refactors introduce bugs)
- Code that was recently changed for gas optimization

### 4. Code Quality (the leading indicator)

Code quality tells a story. Poor code is harder to secure. Non-functional signals often correlate with deeper issues.

**Red flags:**
- Sloppy comments, inconsistent naming
- Ignoring best practices (checks-effects-interactions)
- Beginner mistakes in basic patterns
- Missing natspec on complex functions (suggests rushed development)
- TODO/FIXME/HACK comments in production code

**Adjust your approach based on quality:**

| Codebase | Audits | Focus On |
|---|---|---|
| Good code | Good audits | Novel/very complex exploit paths, upgrades, operational issues |
| Good code | Average audits | Complex paths and known pitfalls auditors catch more than developers |
| Average code | Good audits | Audit fixes and leftover weak design |
| Average code | Average audits | Missed but not extremely complex paths |

---

## Time Dynamics

### Right After Launch (hours/days)
Auth mistakes, common attack vectors, operational errors, and cheap exploits surface quickly. Black hats monitor new deployments closely. If you hear about a launch early, **speedrun** the basic checks.

### First Weeks/Months
More complex attack paths missed by audits get discovered. Good window for deeper reviews, especially after upgrades. The start of a bounty program draws many hunters — check early, then come back later for a deeper pass.

### Mature Programs
ROI drops over time. Only the first report gets paid. But: upgrades, governance changes, and new integrations can reopen attack surface on mature protocols. The Watchman mode is best here.

### The Competition Factor
More eyes = remaining bugs are harder. This includes auditors, bounty hunters, developers integrating the code, and teams maintaining forks. Popular projects harden over time.

**The key is NOT doing what everyone else is doing.** Look at: neglected code paths, uncommon chains, older programs others have moved away from, code paths people avoid because they seem boring or too complex.

---

## Avoiding Unpaid Work

The Immunefi writeups list includes many "Not Paid" entries — real bugs, properly reported, that never paid out. Trust (a prolific hunter) had "Not Paid" outcomes on Morpho, Compound, Iron Bank, Brahma, Oasis, and Tokemak.

### Before Investing Time

1. **Reputation**: Is the project established? Do other hunters speak well of them?
2. **Treasury**: Can they actually afford to pay? Check on-chain treasury.
3. **Bounty rules**: Clear rewards? Clear scope? Fair severity definitions?
4. **Payout history**: Have they paid bounties before? How fast?
5. **Security culture**: Do they have a dedicated security team? Multiple audits?

### During Engagement

- **Submit your first bug immediately.** Don't hold it while looking for more. This tests the team's behavior and responsiveness.
- **Archive the bounty rules** before submitting (screenshot/save). Teams sometimes change rules after disclosure.
- If the team is slow, dismissive, or disputes obvious findings, **move on immediately**. Don't throw good time after bad.

### Red Flags (avoid these programs)

- Vague bounty rules with unclear severity definitions
- Very low bounty caps relative to TVL
- No prior payout history
- Prior disputes or public complaints from hunters
- Team claims "known issue" without proof
- Rule changes after disclosure
- Long silence after submission

### What NOT to Hunt

**Don't waste time on:**
- Deprecated or unused code
- Old contract implementations behind proxies (check what's actually deployed)
- Repository code that doesn't match deployed code
- Non-live or in-development code with no proof it will ship
- Code on incompatible chain versions

**Don't deliberately hunt for:**
- Temporary DoS or griefing (low payout, high dispute risk)
- Issues gated on third-party conditions (oracle provider goes down, etc.)
- Bugs possibly mitigated by off-chain systems
- Low severity issues that lead to endless severity debates
- Issues requiring trusted/admin roles to exploit
- Pure informational or architectural suggestions

**Focus on Critical issues affecting real assets.** That's where the money is.

---

## Platform Recommendations

(From WhiteHatMage, Feb 2026)

Evaluate platforms by payout history, dispute handling, neutrality, and how they respond to project misconduct.

**Top picks**: Immunefi, HackenProof, Cantina

Self-hosted programs rely entirely on project honesty. If engaging with a project that has no formal program, be professional and realistic. A quick vibe check on Discord can save weeks.

---

## Quick Decision Flowchart

```
1. Is the bounty cap ≥ $10K?
   NO → Skip (unless for practice)
   YES → Continue

2. Score the target (use the table in SKILL.md Phase 0)
   < 5 → Skip
   5-7 → Quick skim (2 hours max)
   ≥ 8 → Full hunt

3. After 30-min scoping: does it feel like bugs live here?
   NO → Move on. Analysis paralysis is real. Just pick the next one.
   YES → Commit to 1-3 days. Set a hard stop.

4. After 1 day: have you found anything weird?
   NO → Take a break. Come back tomorrow with fresh eyes. If still nothing → move on.
   YES → Go deep. Write the PoC. Submit immediately.

5. After submission: did the team respond within 48 hours?
   NO → Flag for future avoidance. Don't invest more time yet.
   YES → If response is fair, look for more bugs in the same codebase.
```

---

## Real Payout Calibration (from Immunefi writeups)

| Range | Example Bugs | Typical Payout |
|---|---|---|
| $1M+ | Wormhole uninitialized proxy, Aurora infinite spend, Optimism infinite mint, Belt logic error, Notional double counting | $1M-$10M |
| $100K-$1M | Balancer rounding, Redacted Cartel approval logic, Port Finance logic error, Enzyme oracle manipulation | $100K-$560K |
| $10K-$100K | DFX rounding, Silo, Sherlock yield strategy, Arbitrum inbox, Q Blockchain | $20K-$100K |
| $1K-$10K | Various medium/high on smaller protocols | $1K-$10K |
| $0 (Not Paid) | Many valid bugs — known issue claims, scope disputes, team ghosting | $0 |

**The uncomfortable truth**: a meaningful percentage of valid Critical findings go unpaid. Factor this into your expected value calculation.

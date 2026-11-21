---
name: chess-engine
description: Build a small chess engine that actually plays strength — negamax alpha-beta with quiescence, transposition table, move ordering and tapered PeSTO evaluation, under a hard size/node budget. Use when writing or fixing a chess engine for a contest (e.g. make.fun tiny-chess, ≤4 KB of Python), when an engine grades Elo 0 or far below its design strength, or when validating movegen with perft.
---

# Chess Engine (tiny, strong, verified)

An engine that *looks* right and plays terribly is the normal failure. The gap is
almost never "needs more features" — it is one silent killer: a crash, an illegal
move, a timeout, or an inverted score in the grader's environment. Verify the
harness first, strength second.

## 1. Learn the harness before writing code

- Read the contest kit: how is the engine invoked (argv, stdin protocol, env
  vars), what is the per-move time or node budget in the GRADER (not locally),
  what happens on an illegal move / crash / timeout (usually: game lost).
- Mirror that invocation locally end-to-end before tuning anything. An engine
  that scores Elo 0 twice with TT + quiescence + PSTs on paper is not weak, it
  is *failing*: reproduce the grader run and watch the first game move by move.

## 2. Correctness gates (non-negotiable, in order)

1. **Perft**: startpos perft(3)=8902, perft(4)=197281; Kiwipete perft(3)=97862.
   Any mismatch = movegen bug; stop and fix before touching search/eval.
2. **Legality fuzz**: play ≥500 random/self games; assert every returned move
   is in the legal move list. Zero tolerance.
3. **Mate sanity**: mate-in-1 and mate-in-2 puzzles must be found at depth 3.
4. **Draw handling**: repetition and fifty-move score ~0 inside search, or the
   engine throws won endgames and loses drawn ones.

## 3. Architecture that fits 4 KB

- Board: 8×8 mailbox array (or 0x88), pieces as small ints, make/unmake with an
  undo stack (captured piece, castling rights, ep square, halfmove).
- Search: negamax alpha-beta, iterative deepening, quiescence on captures
  (stand-pat + delta pruning lite). Transposition table: Zobrist keys,
  depth-preferred replacement, store TT move for ordering.
- Ordering (biggest Elo per byte): TT move → MVV-LVA captures → killers →
  history. Bad ordering silently halves effective depth.
- Eval: material P100 N320 B330 R500 Q900–1000 + **tapered PeSTO PSTs**
  (midgame/endgame blend by phase). Bishop pair ~+30. Keep eval cheap: it runs
  at every leaf.
- Optional if bytes allow: null-move pruning, LMR. Never at the cost of the
  gates above.

## 4. Time and node discipline in a sandbox

- Hard node cap AND a wall-clock check every ~1024 nodes; return the best move
  from the last completed iteration on abort. A timeout is a loss — budget for
  the grader's slower CPU, not your machine (halve your local estimate).
- Fixed small node budgets make play deterministic and debuggable; raise only
  after the gauntlet (below) proves the time is safe.

## 5. Prove strength before spending a submission

- Gauntlet: new engine vs the previous version, ≥200 games at the grader-like
  budget, alternating colours. Require a clear win (≥ +100 Elo) — "feels
  better" is not evidence. Also vs a material-only baseline: the full engine
  must crush it; if not, eval/search has a sign or negamax bug.
- Common Elo killers: score returned from the wrong perspective at the root;
  quiescence stand-pat using the side-to-move eval after a colour flip;
  castling rights not restored on unmake; ep capture removing the wrong pawn;
  TT storing mate scores without ply adjustment (tolerable), TT cutoffs at
  wrong depth (not tolerable).

## 6. Size golf (only after strength is proven)

- Count bytes from the first working version; keep ≥5% headroom under the cap.
- Compress PSTs as packed strings; shorten names last; never golf away the
  legality/clock checks to fit — a disqualified or crashing 3.9 KB engine loses
  to a legal 4.0 KB one.

## 7. Authorship (contest entries)

- Write the engine fresh in the builder session from this spec. Diagnosing an
  older engine's *behaviour* (perft counts, game logs, where it hangs) is fine;
  copying its lines — or any other engine's, including another account's — is
  not. Behavioural facts travel; code does not.

---
name: analysing-chess-positions
description: Answer chess questions from the rules with the chess-esca-mcp tools rather than from memory — which moves are legal, why a move is not, whether a position is check, mate, stalemate or a claimable draw, which ending the material makes and whether theory calls it won or drawn, what the opening is called, what a PGN holds, what an opening book plays. Use it whenever a FEN, a PGN, a move list, a board diagram or a single chess move turns up: analysing a game, checking a move, judging a position, writing a puzzle, or building anything that plays or teaches chess. Reach for it even when the question looks easy enough to answer unaided, because a board tracked in the head drifts silently and these tools do not.
---

# Reading a chess position with esca

A position held in your head goes wrong quietly: a pawn on the wrong square,
a castling right that was lost twenty plies ago, a repetition nobody counted.
These tools read the position instead of remembering it, and they hand back
the squares behind every answer, so a claim you make can be checked rather
than trusted.

## Handing over the position

Every tool takes the position the same way:

- `fen` — the position as FEN or EPD. Omitted, it means the start position.
- `moves` — moves played from `fen`, each SAN (`Nf3`, `exd6`, `O-O`) or UCI
  (`g1f3`, `e5d6`, `e1g1`). Mixing the two spellings is fine.
- `pgn` — a whole game, instead of `fen` and `moves`.
- `variant` — `classic` or `chess960`.

**Pass `moves` whenever you have them.** A FEN carries no history, so without
the moves a threefold repetition is invisible and a fifty-move claim cannot be
dated. `status.history_known` in the answer tells you which of the two you got.

## Which tool answers what

| The question | The tool |
|---|---|
| What is going on here? Whose turn, is anyone in check, is it over, what may be claimed, what is the material, may either side castle? | `position` |
| What can be played? What are the captures, the checks, the promotions? | `legal_moves` |
| Is this move legal, and if not, why not? What would it do? | `explain_move` |
| Is the king safe? What is hanging? Is the pawn structure sound? Are there one-ply tactics? | `facts` |
| Which ending is this, is it won or drawn, and by what technique? | `ending` |
| What is this opening called? | `opening` |
| What does the book play here? | `book_moves` |
| What does this PGN say? / write these moves as a game | `pgn`, `to_pgn` |

Start with `position` when you do not yet know what you are looking at. It is
one call and it answers the whole state, so it usually saves two or three
others.

## Reading the answers

**A reason always arrives with its evidence, and every reason that applies
arrives at once.** A castling that is unavailable does not report the first
thing wrong with it; it reports all of them, each naming its own squares:

```json
{"reason": "path_attacked",
 "squares": [{"square": "f1", "attackers": [{"square": "b5", "role": "bishop"}]}]}
```

So do not stop at the first entry of `obstacles` or `reasons` — the second may
be the one that matters, and fixing only the first will not make the move
legal. Quote the squares when you explain: "O-O is out because the bishop on
b5 covers f1" is checkable; "O-O is not allowed" is not.

**Categories are enum names**, in `snake_case` — `checkmate`, `stalemate`,
`insufficient_material`, `threefold`, `exposes_king`, `pinned`,
`no_castling_right`. Use the name the tool gives; do not paraphrase it into
something vaguer.

**Every enum arrives with a `prose` sentence beside it**, saying the same
thing in plain English. Read the enum and quote the sentence; do not invent a
third wording of your own.

**`facts` is labelled by name and by colour.** Every value that differs
between the two sides is `{"white": …, "black": …}`, so nothing has to be read
against whose turn it is; `side_to_move` says whose turn it is when that
matters. Ask for the groups you need — `tactics` for one-ply threats, `king`
for safety, `pawns` for structure, `threats` for what is loose — rather than
taking all of them; the `esca://facts-catalogue` resource names every group,
every field it holds, the type it carries and what it means.

**An input that names no position comes back as an error object**, not a
failure: `{"error": {"kind": "invalid_fen", "message": …, "hint": …}}`. Read
the `hint` and fix the call; an `illegal_move` error names the move's place in
the sequence and lists what was legal there instead.

## What this cannot tell you

These tools do not search and do not evaluate. Nothing here says a move is
*good*, only what it *is* — so do not read a `see` value or a `facts` number
as an engine score. `ending` is the same kind of answer: its verdict is what
theory says about that material, adjusted by the few facts in `evidence`, not
a verdict on this position, so a `win` there is not a promise that the win is
still there after the move you are considering. When the question is "what is the best move" or "who is
winning by how much", that is an engine's job:
[chess-uci-mcp](https://github.com/AnglerfishChess/chess-uci-mcp) drives
Stockfish or Leela and the two sit well side by side — the engine for the
number, these tools for the reason.

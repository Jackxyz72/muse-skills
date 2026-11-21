---
name: judged-writing
description: How to win make.fun JUDGED WRITING contests (poem/prose scored by pairwise judge win rate). The winner pattern — reinterpret the prompt, one concrete image system, restraint — plus the AI tells that lose head-to-head comparisons, the draft-and-audit workflow, and the authorship line. Read before drafting any judged poem/prose entry.
---

# Judged Writing on make.fun

Scoring is a **pairwise judge win rate** (`values.judge`): your piece is compared head-to-head against rivals, one pair at a time. You do not win by covering the theme harder. You win each comparison by being the more concrete, more restrained, less machine-sounding piece on the page.

## The evidence (agency-poem-01, resolved 2026-11-15)

Won by @amrusalim at **90.34% ± 1.6** with a prose poem about a dog following a patch of sunlight across a kitchen floor. Our entries finished **#869/5,345** (@jack-xyz) and **#2,235/5,345** (@jackxyz72). The gap to #1 is craft, not effort — the winner is *shorter and quieter* than almost everything it beat.

The winning text, kept as the reference exhibit:

> The old dog lies down in the patch of sun on the kitchen floor. The patch moves. It is slow about it, the width of a floorboard in an hour, but it moves, and after a while the dog's back half is in the shade. The dog does not open its eyes. It gets up, takes two steps, turns once, and lies down again in the light. This goes on all afternoon. From the sink to the table leg. From the table leg to the back door. A long, slow walk across the kitchen, done lying down.

## The winner pattern

1. **Reinterpret the prompt word.** "Agency" was not written as grand free-will abstraction — it was shrunk to its second, smaller meaning: a creature quietly directing itself. Before drafting, list 3–4 readings of the prompt word and pick the smallest concrete one. The abstract reading is what the whole field writes; the small reading is what wins pairs.
2. **One concrete image system, carried through the whole piece.** Dog, sun patch, kitchen floor — nothing else enters. Every sentence advances the same image. If a line introduces a second metaphor world, cut it or cut the line.
3. **Restraint.** Short declarative sentences, varied in length so the rhythm breathes. Specific nouns and verbs (*floorboard*, *table leg*, *turns once*) instead of adjectives. Zero rhyme unless the piece earns it. No moral, no summary, no explaining what the image means — the judge can see it.
4. **An ending that reframes, quietly.** The last line ("A long, slow walk across the kitchen, done lying down") re-reads everything before it. Aim for a closer that changes the meaning of the first line, at the same low volume as the rest. Grandiose closers lose pairs.

## AI tells that lose pairwise judging

Audit every draft against this list — these are the patterns a judge (human or model) reads as machine-written, and they lose to a plainer rival:

- **Tricolon lists** — three parallel items where one would do.
- **"Not X but Y" constructions** — the single most recognisable AI pivot.
- **Em-dash chains** — dashes doing the work sentences should do.
- **Uniform sentence length** — every sentence the same weight and shape; real prose stumbles and varies.
- **Thesaurus words** — the fancier synonym chosen over the plain one.
- **Summary / moral final lines** — ending by stating the theme ("and so we are all…") instead of landing an image.
- **Forced rhyme** — rhyme bending the sense out of shape; judges punish it against unrhymed restraint.
- **Abstraction pile-ups** — freedom, journey, tapestry, echoes, whispers stacked with no object in sight.

## Workflow

1. **Re-check the contest first** (per `makefun-playbook`): live `makefun status --competition <slug> --json`. Caps vary per competition — never assume yesterday's cap. Note the deadline; judged contests can live ~48 hours.
2. **Draft 6–10 candidates in-session.** Vary the reinterpretation and the image system across candidates, not just the wording. Short is fine — the reference winner is ~120 words.
3. **Audit each candidate** with the installed `ai_writing_detector` skill (detect-only pass) and the `avoid_ai_writing` skill. Kill or rewrite any candidate carrying the tells above. Detector flags are a prompt to re-read, not a verdict — your ear decides.
4. **Read-aloud test.** Read each survivor aloud (mentally, at speaking pace). If the rhythm is metronomic, break a sentence or merge two. If you run out of breath or get bored mid-piece, the judge does too.
5. **Submit weakest → strongest** under the live caps, strongest last (the last graded entry is the default final pick). **Warn the user before submitting: a submission cannot be withdrawn.**
6. **Set the final pick from dev judge scores as soon as they land** — `makefun final <slug> <id>` re-picks a finished earlier entry for free if a weaker-looking candidate outscored the favourite. Do not leave the pick to the default when the scores say otherwise.

## Authorship

- Entry text is **written by us, in-session, only** — same line as code entries. No companion model (Xingchi, dl/Autopilot, Groq, OpenRouter, Gemini) may draft, co-draft, or "improve" entry text; their output in an entry risks the authorship gate and, frankly, reads like the field.
- Companions may be consulted on *strategy* (which contests to enter, deadline triage) — never on the words.
- Do not lift lines from the reference winner or any rival entry. The exhibit above teaches a *move* (reinterpret + one image + restraint), not text to imitate sentence by sentence.

## Pre-submit checklist

- [ ] Prompt word reinterpreted to its small, concrete meaning?
- [ ] One image system only, start to finish?
- [ ] No tricolons, no "not X but Y", no em-dash chains, no thesaurus words?
- [ ] Sentence lengths visibly varied on the page?
- [ ] Final line reframes instead of summarising?
- [ ] Detector + avoid-ai-writing audit run; read-aloud done?
- [ ] Live caps re-checked; user warned the submission is irreversible?

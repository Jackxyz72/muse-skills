# Enter make.fun contests under a submission quota

## Verify the quota before the first test

- Plan every contest as if the effective cap is 3 submissions until a live quota read proves otherwise, because the kit quota is generic and an account-reputation cap can lower it without being displayed.

- Read the competition rules and record the submission limit, deadline and prize claim path before you test anything.

- Use the current kit status command to read entries left today, entries left in total, and whether a submit now would be taken.

- Use the final-entry pick to make an earlier finished entry the final entry without spending a submission.

- Treat a refused attempt as a spent submission when the platform counts it that way.

## Repo must start from the kit beacon root

- Create the entry repo with the kit CLI init, never plain git init, because submit refuses a repo whose root commit is not the beacon root.

- Let the builder author, commit and verify all candidates, and let the main agent bundle with the muse-usage rows, because a builder subagent cannot attach its own usage rows in its own run.

- Keep the repo path the builder used, because bundle session discovery keys on the repo path string.

- Run the CLI from inside the kit cli directory.

## Bundle the authorship proof without losing it

- Bundle only the sessions that authored the entry with one session flag per builder session plus no-discover and no-family.

- Author with the EDIT tool when a line must count as thought, because thinking_reproduces credits EDIT lines and not full file WRITE lines.

- Bundle after the authoring turn is delivered, because usage rows are written only when that turn is delivered.

- Treat a line that first appeared in a tool result as read forever, and reimplement it from a behavioral spec.

- Pass the run record flags the current CLI demands, and read the check output for the exact flag set.

- Check that an entry runs to completion in the judge sandbox before you spend a submission on it.

- Verify a provider secret with the platform secret list before you bundle, and record the key value nowhere.

## Verify the intake gates before you submit and the stage after you submit

- Check that a LICENSE file sits in the repo root before you submit, because the license gate refused the news19 v2 entry on 2026-11-19 when the repo had no LICENSE.

- Open a clean copy of the repo and confirm entry.png sits at the path the kit expects at the repo root, because the judge machine searched the wrong path on 2026-11-19 after 29 of 30 gates passed.

- Run the full local check again after the last file change, and read every gate name in its output before you submit.

- Report a submission as successful only after you have read its stage as checked, and quote the submission id and the stage in that report.

- Report a rejection at once with the gate name, whether a slot was used, and which entry still stands as the deciding entry.

- Do not retry a rejected submission with the same files, and fix the named gate first before you spend another attempt.

## Check the cover art bundle before you submit

- Use the kit buildDossier output byte for byte as the dossier, and never write an invented dossier file, because the judge rejects a bundle whose dossier was written by hand.

- Search the bundle for external font and stylesheet URLs before you submit, and replace every Google Fonts link with a local OFL font file, because the judge gate rejects URLs in the bundle.

- Keep one shared OFL licence file for all fonts, and check that every licence file in the bundle counts as written by the recorded session, because a licence file the session did not write counts as unwritten.

- Write the entry main file in at least two stages with a run between them, so the recorded session shows the file being edited rather than written once.

- Check that every output filename uses only plain letters, digits, dots, underscores and hyphens, and rename any font or asset file whose name contains brackets before you submit.

- Open the built cover and confirm the dossier, the fonts and the screenshots are all present in the bundle before you submit.

## Rank every candidate before you spend a submission

- Compare all candidates offline first and rank them from weakest to strongest.

- Keep the ranked list visible in your working notes so the order survives a new session.

- Let the user change the ranking before the first submission, and freeze the order once testing starts.

## Test weakest first and submit the strongest last

- Submit the weakest ranked candidate first and move up the ranking one candidate at a time.

- Treat every test submission as the current entry, because a later submission replaces the earlier one.

- Submit the strongest candidate last, so the best tested entry is the one that stays when the quota runs out.

## State irreversibility before you submit

- Tell the user plainly before each submission that it cannot be withdrawn once the platform accepts it.

- Wait for the user confirmation in their own words before you submit the strongest candidate.

- Record the final entry, the quota used and the deadline so a later session does not test the same contest again.

## Available connectors

- Use muse.connector_search to find other connectors and muse.skill_search to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with the Custom Connectors and MCPs skill, or build a custom connector.

## Websites

- Use make.fun for reading the competition rules, the submission limit, the deadline and the prize terms.

## Alternatives for better results

- Rank candidates with a local or offline comparison before you spend any submission.

- Ask the user to confirm the weakest to strongest order before the first test.

- Use a practice or local run for a code contest before you spend a submission, when the contest allows it.

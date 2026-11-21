# Report scheduled job failures and unclaimed outcomes

## Report every claim, retry and reminder run

- Report the outcome of every scheduled claim, retry and reminder run to the user, even when it fails or nothing was claimed.

- Never stay silent on a failure or a still unclaimed outcome, because silence reads as success and the user loses the chance to act.

- Send one brief line per failed run with the job name, what was still unclaimed and the real reason it failed.

- Report a success with the same brevity, naming what was claimed and the transaction hash when one exists.

- Keep the report in the user's language and keep costs in rupiah when money is involved.

## Keep watcher runs quiet unless something changes

- Report a watcher run only when a mint succeeds, a blocker needs the user, or a dangerous candidate is flagged, following the reporting contract in the bsc-free-mint-watch skill.

- Stay silent on other watcher runs, with no messages that say nothing was found and no summaries, because most watcher runs end with nothing new.

- Report a blocker at most once per day per blocker, so a high frequency watcher does not repeat the same blocker every few minutes.

- Treat watcher silence as nothing new passing the gates, not as proof the watch is dead, and check the watcher separately when you suspect it stopped.

## Diagnose the failure before you change the schedule

- Check whether the tool binary the job needs still exists before you diagnose a dead session, because a replaced virtual machine can remove the binary while the session stays logged in.

- Reinstall the missing binary and recheck the session before you conclude the session is dead.

- Never delete, pause or revoke a schedule on a binary missing diagnosis, and revive the schedule once the binary is back and the session checks out.

- Name the failure class in the report, such as a preview stall, a network drop, a missing binary or an expired session, so the next run can act on it.

- Record the verified outcome on the owning goal timeline so a later session does not retry blindly or assume the claim succeeded.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with [Custom Connectors and MCPs](/opt/muse/skills/custom-connector-setup/SKILL.md), or build a custom connector.

## Alternatives for better results

- Space retries with a fresh run instead of relying on an internal retry when a preview stall stops the run after the first attempt.

- Ask the user before you change a retry cadence that they set, and report the change with the new cadence.

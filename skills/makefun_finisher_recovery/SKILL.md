# Recover a flagged make.fun builder or finisher

## Check the contest mode before you recover

- Check whether the contest uses bundle mode or strict-transcripts mode before you choose where to rebuild.

- Rebuild a bundle-mode entry in the main session with the file tools, because bundle mode has no recording that excludes the main session.

- Rebuild a recorded or strict-transcript contest only in a fresh builder session started after the recorder starts, and keep the lead session silent in that window.

- Make zero tool calls from the lead session between record start and the sealed result, and let the builder do all work in that window.

- Keep the lead and the coordinator out of the sealing set, and let the builder seal as its last step after commit and push and after it writes its usage rows.

- Submit a strict-transcript entry with the sealed recording id plus the run-record flags, and submit a bundle-mode entry from the kit directory with the flags the current kit demands.

## Recognise the stop

- Treat a builder or finisher session that stops on a security flag at repo setup, kit init, or the first main.ts write as a stopped session and not as a rejected entry.

- Check whether any submission slot was spent before you act, because a flag that stops the session before submit spends no slot and the entry still stands to be built.

- Stop retrying the same delegated shape after the first flag, because repeating the same call produced a second and a third flag on the same contest in one day.

## Recover with file tools

- Use the file tools in the session the contest mode allows instead of delegating another builder or finisher session with the same shape.

- Start the recorder first for a recorded contest and then start the fresh builder session, so every line the builder writes is witnessed.

- Write the entry in at least two stages with a run between them, and prefer the edit tool for entry code so the lines count as authored in the recorded session.

- Test each run from /tmp and keep the test run separate from the entry repo, so a test failure never touches the files the judge will grade.

- Make git calls one purpose at a time, with one commit per change, and check the status after each call before you make the next one.

- Follow the makefun submission quota skill for the quota, the order, and the final pick.

- Keep the authorship rules from the makefun playbook while you recover, because code that first appears in a tool result counts as read forever and a companion written entry can fail the authorship gate.

## Verify the entry before you report

- Run the full local check again after the last file change and read every gate name in its output before you submit.

- Confirm the recording shows sealed before you report a recorded entry as ready, and report held instead of sealed when the seal does not confirm.

- Report a submission as successful only after you have read its stage as checked, and quote the submission id and the stage in that report.

- Report a rejection at once with the gate name, whether a slot was used, and which entry still stands as the deciding entry.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with [Custom Connectors and MCPs](/opt/muse/skills/custom-connector-setup/SKILL.md), or build a custom connector.

## Websites

- [make.fun](https://make.fun/) for reading the submission stage and the competition status after you bundle and submit.

## Alternatives for better results

- Build the entry in a fresh session with the file tools from the start when the contest is small and the deadline is near, instead of waiting for a flag to force the switch.

- Ask the user to confirm the ranked order before the first submission when more than one candidate survives the recovery.

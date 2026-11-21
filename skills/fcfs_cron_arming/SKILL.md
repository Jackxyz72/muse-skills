# Arm an FCFS mint with cron jobs

A first-come-first-served mint is won or lost by whether the fire process is alive at the open. Arm it from inside a cron run minutes before the start, never hours ahead.

## Treat a long lived background fire as already dead

- Never make a background fire armed hours ahead the plan of record for a confirmed mint.

- Treat a virtual machine replacement as a certainty on this machine. It kills background processes without warning, and a dead fire leaves a log that stops at arming with no trigger lines.

- Use runtime managed cron jobs to do the arming. They survive a machine replacement while a background process does not.

- Follow this skill for when the fire starts. Follow the fastmint-fcfs skill for recon, rehearsal and the fire command itself, and follow the on-chain safety rails skill for confirmation and broadcast rules.

- Let this skill win when it disagrees with the background fire step in the fastmint-fcfs skill. That step predates the lesson that a long lived fire dies on this machine.

## Create the guard and the executor

- Create two runonce cron jobs with `cron.add` as soon as the user confirms the mint summary.

- Schedule the guard at T-15 minutes. Let it check only and never arm a fire or broadcast anything.

- Schedule the executor at T-2 minutes. Let it reinstall the wallet CLI when it is missing, verify the wallet connection and Developer Mode, start the fire, wait for the result, verify it on chain and report it.

```bash
npm install -g @binance/agentic-wallet
```

- Give each cron the full target in its body, including the contract, the calldata, the value, the start time to the second, the label and the wallet.

- Start the fire only inside the executor run and without the dry run flag. The fire then only needs to live about three minutes.

- Allow a manually armed background fire as a bonus layer only. Never treat it as the plan of record, and let the executor check for an existing lock or result before it starts a second fire.

- Read the two cron bodies from `~/workspace/fastmint/FCFS_ARMING_TEMPLATE.md` and fill in the values for this mint.

## Take the start time from the contract

- Read the start getter on chain and use the time to the second.

- Distrust a rounded start time from a site. A site can print the minute while the contract holds the exact second, and that gap can decide the mint.

- Re-read the contract state in the guard run. Confirm the sale has not opened yet and the free quota has not gone yet.

- Change nothing about the target after the user confirms it without asking the user to confirm again.

## Verify the result and record it

- Wait for the fire to finish inside the executor run and read the final log lines for the execute step, the transaction hash and the status.

- Verify on chain whether the tokens arrived. Distinguish a broadcast that succeeded, a broadcast that reverted and a fire that never broadcast.

- Report the outcome to the user in their language, with the transaction hash when one exists and the real reason when it failed.

- Record the verified outcome on the owning goal timeline and in memory, and replace the armed note with the result.

- Escalate the design when a fire misses because the process died even inside the T-2 window. Do not quietly reuse a pattern that already failed twice.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with [Custom Connectors and MCPs](/opt/muse/skills/custom-connector-setup/SKILL.md), or build a custom connector.

## Alternatives for better results

- Wait for the start announcement first when a mint has no fixed start time. Arm only after the contract publishes the start.

- Create no crons at all when no mint is confirmed. A guard and an executor exist for one confirmed mint only.

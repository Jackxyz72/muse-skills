# Fire an already open BSC mint or claim

## Fire with the slow spin

- Use this skill only when the target mint or claim is already open.

- Run fire.js in standard mode with no start time and without the `--once` flag.

- Add `--interval 2000` to every claim mode run and set `--timeout` to a value from 600 to 900.

- Leave the default 100 ms eth_call spin out of every claim mode run because it chokes its own preview call.

- Run the fire from a background process or a cron run and never from an exec call inside a chat session.

- Keep the preview gate in place and let the file lock keep execution to a single broadcast.

```bash
cd /home/hatch/workspace/fastmint
./fastmint.sh fire --to 0xSALE --sig "claimFree()" --interval 2000 --timeout 900
```

## Retry a preview stall with a fresh run

- Treat a run that stops after preview 1 with an unknown preview error as one spent knock.

- Start a fresh run or a fresh cron run after a pause when that stall happens.

- Re-read the contract state before the fresh run and confirm the target is still open and unclaimed.

- Report the stall in one brief line with the job name and the real reason.

## Keep the FCFS exception separate

- Do not use this slow spin for a timed FCFS open.

- Follow the fcfs_cron_arming skill for a timed FCFS open where tight spin at T-0 can still matter.

- Use this skill again only after the timed open has passed and the target is already open.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with [Custom Connectors and MCPs](/opt/muse/skills/custom-connector-setup/SKILL.md), or build a custom connector.

## Alternatives for better results

- Check the wallet connection and Developer Mode before you fire.

- Re-check the contract state before a retry.

- Space a fresh retry with a pause instead of firing back to back runs.

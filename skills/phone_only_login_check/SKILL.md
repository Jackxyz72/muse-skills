# Check phone-only logins before trying them in the cloud browser

## Check where the user is already logged in

- Check whether the step needs X sign in before you open the cloud browser, because X sign in from the cloud browser was blocked outright for this user.

- Check the user context and memory for a logged in phone session before you offer a browser route, because the user works from an Android phone and is already logged in to X there.

- Stop after the first clear block instead of trying the vault login, a Google route or a user takeover in turn, because each variant failed the same way.

- Treat KYC, an OTP and other social verifications the same way as X sign in, and check device fit before you attempt any of them from the cloud browser.

## Do the work that needs no login first

- Gather the links, the exact steps and the fields the user will meet on the phone before you hand the step over.

- Use public reads that need no login for the research around the task, such as Agent Reach public channels, instead of spending the login attempt on reading.

- Prepare the check or the claim in full so the phone step is the only step left, and tell the user what result to paste back.

- Never ask the user to paste a seed phrase, a private key or a password into chat, and never ask the user to type credentials into the cloud browser after a block.

## Hand the phone step to the user cleanly

- Tell the user in one short message that the step is phone only, what to open on the phone and what to do there.

- Name the exact outcome you need back, such as a confirmation, a code result or a screenshot description, and say nothing more is needed from the cloud browser.

- Wait for the user to report back instead of retrying the blocked route while you wait.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with [Custom Connectors and MCPs](/opt/muse/skills/custom-connector-setup/SKILL.md), or build a custom connector.

## Alternatives for better results

- Ask the user to paste the result from the phone instead of asking for a login you cannot complete.

- Split the task so the cloud browser does the read-only research and the phone does the single signed in step.

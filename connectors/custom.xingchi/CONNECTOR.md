# Xingchi

- `custom.xingchi` connects Muse to Xingchi (xingchiapi.com), a free community API relay from the linux.do community, through its OpenAI-compatible REST API. It authenticates with the registered `api_key` credential as a Bearer header and calls only `api.xingchiapi.com`.

- You need your own Xingchi account and API key — keys are never included in this repo. Treat the service as disposable: its GPT routes are mostly web reverse-proxy channels rather than the official API, it can shut down or rate-limit at any time, and every prompt passes through its servers, so never send sensitive data and never top the account up.

- Helpers live in `~/workspace/custom-connectors/custom.xingchi/bin/`. `xingchi.py` lists the models the key can reach and sends a chat completion (Muse version, key injected through Muse's secure connection). `xingchi_standalone.py` is the same helper for use outside Muse, reading the key from the `XINGCHI_API_KEY` environment variable.

## Connect

- The connection was registered with `credentials.request_api_access` and these details. Reuse them to reconnect:

```json
{
  "provider": "xingchi",
  "auth_scheme": "api_key",
  "placement": "bearer_header",
  "api_hosts": ["api.xingchiapi.com"]
}
```

- Before the first change in a conversation, prove access with a harmless read:

```text
python3 ~/workspace/custom-connectors/custom.xingchi/bin/xingchi.py models
```

## Credentials

- The registered connection holds the credential. Helpers import `/opt/muse/skills/custom-connector-setup/bin/dynamic_credentials.py`, which returns an `hsurr:` surrogate and places it where the provider reads the key. Muse swaps in the real credential only on an approved request to a registered host.

- Never put a key, token, password or cookie in this doc, a helper, a command argument, an environment variable or a log. Never ask the user to paste one in chat.

- Keep redirects disabled on authenticated requests.

- On a 401 or 403, check the request first. Confirm that the helper attached the credential, that the host is registered and that the placement and scopes match.

- Only when a request that carried the credential is still rejected, call `credentials.request_api_access` with the details above and `"reconnect": true`.

## List models

```text
python3 ~/workspace/custom-connectors/custom.xingchi/bin/xingchi.py models
```

- The command prints a JSON object with a count and the model id list. Known ids are `gpt-6-astra` and `gpt-6.1-sol`. Model availability depends on the key's group on the Xingchi dashboard and can change without notice.

## Send a chat completion

```text
python3 ~/workspace/custom-connectors/custom.xingchi/bin/xingchi.py chat <model> <prompt>
```

- Pass a model id from the models command and a single prompt. This operation spends the account's internal credit, and some models on this relay are billed per request rather than per token.

- Expect heavy prompt inflation on this relay: a short test sentence was billed ~4,150 prompt tokens, because the web reverse-proxy channel wraps the request in a large hidden session prompt.

## Coding-agent companion route (Codex CLI)

- Plain script calls can be rejected by the relay (`403 client_not_allowed` — it only accepts named programming clients). The proven route for using Xingchi as a coding companion / second opinion is **Codex CLI** with the provider config in `codex/config.example.toml` in this folder: provider `xingchi`, base `https://api.xingchiapi.com/v1`, `wire_api = "responses"`, model `gpt-6.1-sol`, key passed via the `XINGCHI_KEY` env var at launch only (never written to disk).
- Run it one-shot with stdin from `/dev/null`, otherwise Codex waits on stdin forever:

```text
XINGCHI_KEY="your-key" codex exec --skip-git-repo-check "<prompt>" < /dev/null
```

## Recover from errors

- A 401 means the key was rejected or the request carried no credential. Check the helper and the connection before asking the user to reconnect.

- After a failed or timed-out change, check the current state with a read before trying again, because the first request may have completed.

## Limits

- The connector reaches only `api.xingchiapi.com`. The dashboard at xingchiapi.com is a separate website and is not part of this connector.
- The relay's own notice bans using its Gemini channels for programming. A typical key's group exposes GPT models only.

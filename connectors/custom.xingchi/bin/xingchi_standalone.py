#!/usr/bin/env python3
"""Xingchi API helper — standalone version (no Muse required).

Usage:
  export XINGCHI_API_KEY="your-key"     # key from your own Xingchi account
  python3 xingchi_standalone.py models
  python3 xingchi_standalone.py chat <model> <prompt>

Works against the OpenAI-compatible relay at https://api.xingchiapi.com.
The key is read from the environment only — never hard-code it here.
Note: some relay channels reject plain script clients (403
client_not_allowed); for coding-agent use, the Codex CLI route in
../codex/ is the proven one.
"""
import json
import os
import sys
import urllib.request

BASE = os.environ.get("XINGCHI_BASE", "https://api.xingchiapi.com")
KEY = os.environ.get("XINGCHI_API_KEY", "")


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args):
        raise RuntimeError("redirect refused, verify the endpoint")


def call(method, path, payload=None):
    if not KEY:
        print("Set XINGCHI_API_KEY first (your own Xingchi API key).")
        sys.exit(2)
    data = None
    headers = {"Authorization": f"Bearer {KEY}", "User-Agent": "xingchi-standalone/1.0"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(BASE + path, data=data, headers=headers, method=method)
    with urllib.request.build_opener(NoRedirect()).open(request, timeout=60) as response:
        return json.loads(response.read().decode("utf-8"))


def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "models":
        result = call("GET", "/v1/models")
        ids = [m.get("id") for m in result.get("data", [])]
        print(json.dumps({"count": len(ids), "models": ids}, indent=2))
    elif len(sys.argv) >= 4 and sys.argv[1] == "chat":
        model, prompt = sys.argv[2], " ".join(sys.argv[3:])
        result = call("POST", "/v1/chat/completions", {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
        })
        print(json.dumps(result, indent=2)[:4000])
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()

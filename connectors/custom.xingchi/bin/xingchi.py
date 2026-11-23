#!/usr/bin/env python3
"""Xingchi API helper (OpenAI-compatible relay at api.xingchiapi.com).

Usage:
  xingchi.py models
  xingchi.py chat <model> <prompt>

The API key is never stored here; it is injected per-request through the
custom.xingchi connection's surrogate credential exchange.
"""
import json
import sys
import urllib.request

sys.path.insert(0, "/opt/muse/skills/custom-connector-setup/bin")
from dynamic_credentials import add_surrogate_to_request, read_json_response

BASE = "https://api.xingchiapi.com"
HOSTS = ["api.xingchiapi.com"]


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args):
        raise RuntimeError("redirect refused, verify the endpoint")


def call(method, path, payload=None):
    data = None
    headers = {}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(BASE + path, data=data, headers=headers, method=method)
    add_surrogate_to_request(request, "custom.xingchi", allowed_hosts=HOSTS)
    with urllib.request.build_opener(NoRedirect()).open(request, timeout=60) as response:
        return read_json_response(response)


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

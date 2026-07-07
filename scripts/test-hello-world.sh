#!/usr/bin/env bash
# Smoke test for the static hello-world page (issue #1).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
port=8973

python_bin=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" --version >/dev/null 2>&1; then
    python_bin="$candidate"
    break
  fi
done
if [ -z "$python_bin" ]; then
  echo "FAIL: no working python3/python interpreter found on PATH"
  exit 1
fi

server_log="$(mktemp)"
response_file="$(mktemp)"

"$python_bin" -m http.server "$port" --directory "$repo_root/public" >"$server_log" 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true; rm -f "$server_log" "$response_file"' EXIT

for _ in $(seq 1 20); do
  if curl -sf "http://127.0.0.1:$port/index.html" >"$response_file" 2>/dev/null; then
    break
  fi
  sleep 0.2
done

body="$(cat "$response_file")"

fail=0
grep -q "Hello, World!" <<<"$body" || { echo "FAIL: missing 'Hello, World!' text"; fail=1; }
grep -q 'style.css' <<<"$body" || { echo "FAIL: index.html does not link style.css"; fail=1; }
grep -q 'app.js' <<<"$body" || { echo "FAIL: index.html does not link app.js"; fail=1; }

curl -sf "http://127.0.0.1:$port/style.css" >/dev/null || { echo "FAIL: style.css not served"; fail=1; }
curl -sf "http://127.0.0.1:$port/app.js" >/dev/null || { echo "FAIL: app.js not served"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: hello-world page smoke test"
fi
exit "$fail"

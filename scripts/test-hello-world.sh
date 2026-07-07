#!/usr/bin/env bash
# Smoke test for the static hello-world page (issue #1).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
port=8973

python_bin="$(command -v python || command -v python3)"

"$python_bin" -m http.server "$port" --directory "$repo_root/public" >/tmp/hello-world-server.log 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT

for _ in $(seq 1 20); do
  if curl -sf "http://127.0.0.1:$port/index.html" >/tmp/hello-world-response.html 2>/dev/null; then
    break
  fi
  sleep 0.2
done

body="$(cat /tmp/hello-world-response.html)"

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

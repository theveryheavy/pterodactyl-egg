#!/bin/bash
# Anti-miner & Anti-website checks
set -euo pipefail
cd /home/container || exit 1

# Miner keywords
MINER_NAMES="xmrig minerd cpuminer coinhive"

# Web server keywords
WEB_SIGS="express\\|flask\\|fastapi\\|uvicorn\\|http.server\\|apache2\\|nginx"

# Check for miner binaries
if grep -R --exclude-dir=logs -I -nE "$MINER_NAMES" . 2>/dev/null | grep -q .; then
  echo "ANTI-ABUSE: Miner detected! Exiting."
  exit 2
fi

# Check for web servers
if grep -R --exclude-dir=logs -I -nE "$WEB_SIGS" . 2>/dev/null | grep -q .; then
  echo "ANTI-ABUSE: Web server detected! Exiting."
  exit 3
fi

exit 0
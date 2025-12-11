#!/bin/bash
set -euo pipefail
cd /home/container

# Show branding
cat branding.txt
echo

# Anti-abuse checks
./anti_abuse_check.sh || { echo "Anti-abuse check failed."; exit 1; }

# First-run setup
if [ -f .setup_required ]; then
  echo "First-run setup required..."
  ./setup_menu.sh
  echo "Setup finished. Server will stop for user to upload files."
  exit 0
fi

# Load config
if [ -f .botconfig.json ]; then
  LANGUAGE=$(jq -r '.language // empty' .botconfig.json)
  STARTUP_FILE=$(jq -r '.startup_file // empty' .botconfig.json)
else
  touch .setup_required
  echo "Configuration missing. Restart to run setup."
  exit 0
fi

# Prefer panel variable if exists
[ -n "${STARTUP_FILE:-}" ] || STARTUP_FILE="${STARTUP_FILE:-bot.js}"

# Check for startup file
if [ ! -f "$STARTUP_FILE" ]; then
  echo "ERROR: Startup file not found!"
  echo "1) Upload your bot files"
  echo "2) Set 'Startup File' in panel"
  echo "3) Start the server"
  exit 0
fi

# Start the bot
echo "Starting $STARTUP_FILE using $LANGUAGE..."
if [ "$LANGUAGE" = "node" ]; then
  exec node "$STARTUP_FILE"
else
  exec python3 "$STARTUP_FILE"
fi

#!/bin/bash
set -euo pipefail
cd /home/container

# Display branding
clear
cat branding.txt
echo

# Prompt for language
LANGUAGE=""
while [ -z "$LANGUAGE" ]; do
  echo "Choose language: (1) Node.js  (2) Python"
  read -rp "Enter 1 or 2: " choice
  if [ "$choice" = "1" ]; then LANGUAGE="node"; fi
  if [ "$choice" = "2" ]; then LANGUAGE="python"; fi
done

# Prompt for version
VERSION=""
if [ "$LANGUAGE" = "node" ]; then
  read -rp "Node version (18,20,22,latest): " VERSION
  [ -z "$VERSION" ] && VERSION="18"
else
  read -rp "Python version (3.10,3.11,latest): " VERSION
  [ -z "$VERSION" ] && VERSION="3.11"
fi

# Install method
echo "Install method: (1) Upload (2) Git (3) ZIP"
read -rp "Enter 1,2, or 3: " IM
INSTALL_METHOD="upload"
GIT_REPO=""
ZIP_URL=""
if [ "$IM" = "2" ]; then
  INSTALL_METHOD="git"
  read -rp "Enter Git repository URL: " GIT_REPO
fi
if [ "$IM" = "3" ]; then
  INSTALL_METHOD="zip"
  read -rp "Enter ZIP URL: " ZIP_URL
fi

# Save config
jq -n --arg l "$LANGUAGE" --arg v "$VERSION" --arg m "$INSTALL_METHOD" \
  --arg g "$GIT_REPO" --arg z "$ZIP_URL" \
  '{language:$l, version:$v, install_method:$m, git_repo:$g, zip_url:$z, startup_file:""}' \
  > .botconfig.json

# Install git/zip immediately if selected
if [ "$INSTALL_METHOD" = "git" ] && [ -n "$GIT_REPO" ]; then
  echo "Cloning git repository..."
  git clone --depth 1 "$GIT_REPO" .
elif [ "$INSTALL_METHOD" = "zip" ] && [ -n "$ZIP_URL" ]; then
  echo "Downloading ZIP..."
  curl -L "$ZIP_URL" -o /tmp/download.zip
  unzip -o /tmp/download.zip
fi

# Minimal language setup
if [ "$LANGUAGE" = "node" ]; then
  [ -f package.json ] && npm ci --production || true
else
  [ -f requirements.txt ] && python3 -m pip install -r requirements.txt --no-cache-dir || true
fi

# Mark setup done
rm -f .setup_required
touch .setup_complete

echo
cat <<EOF
Setup complete. Next steps:

1) Upload your bot files via Panel file manager (if not using Git/ZIP).
2) Set the 'Startup File' variable in the Panel to your bot's filename (e.g. bot.js or bot.py).
3) Start the server.

EOF

exit 0

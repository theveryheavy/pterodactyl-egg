#!/usr/bin/env bash
apt update
apt -y install curl wget git unzip
set -euo pipefail
REPO_RAW_BASE="https://raw.githubusercontent.com/theveryheavy/pterodactyl-egg/main"
TARGET_DIR="/home/container"
FILES=(
  "branding.txt"
  "startup_wrapper.sh"
  "setup_menu.sh"
  "dep_manager.sh"
  "anti_abuse_check.sh"
)
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"
spinner() {
  local pid=$1
  local msg="$2"
  local delay=0.08
  local spinstr='|/-\'
  printf "  %s " "$msg"
  while kill -0 "$pid" 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "%s\b" "${spinstr:i:1}"
      sleep $delay
    done
  done
  wait "$pid"
  return $?
}
download_file() {
  local file="$1"
  local url="${REPO_RAW_BASE}/${file}"
  local tmpfile=".tmp.${file}"
  # Start curl in background, hide output
  ( curl -fsSL "$url" -o "$tmpfile" ) &
  local cpid=$!
  spinner "$cpid" "Downloading ${file}..."
  local rc=$?
  if [ $rc -ne 0 ]; then
    printf "  ${RED}✖ Failed${RESET}  (%s)\n" "$file"
    rm -f "$tmpfile" 2>/dev/null || true
    return 1
  fi
  mv -f "$tmpfile" "$file"
  printf "  ${GREEN}✔ OK${RESET}  (%s)\n" "$file"
  return 0
}
printf "${CYAN}HostingCo — Preparing Discord Bot server environment${RESET}\n\n"
failed=0
for f in "${FILES[@]}"; do
  if ! download_file "$f"; then
    failed=1
    break
  fi
done
if [ $failed -ne 0 ]; then
  printf "\n${RED}Installation aborted: failed to download required files.${RESET}\n"
  printf "Check the REPO_RAW_BASE variable in this install.sh and ensure files are public.\n"
  exit 2
fi
chmod +x -- *.sh 2>/dev/null || true
: > .botconfig.json || true
touch .setup_required .deps 2>/dev/null || true
printf "\n${GREEN}Installation complete.${RESET}\n"
printf "${YELLOW}What to do next:${RESET}\n"
printf "  1) Start the server to run the interactive setup.\n"
printf "  2) Follow prompts to choose language/version/install method.\n"
printf "  3) Upload your bot files and set the startup file in the Panel.\n\n"
printf "${CYAN}If you need to update scripts, push changes to your GitHub repo; servers created later will fetch the updated files.${RESET}\n"
exit 0


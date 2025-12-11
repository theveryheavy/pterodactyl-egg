#!/bin/bash
cd /home/container
case "$1" in
  add)
    echo "$2" >> .deps
    echo "Added dependency: $2"
    ;;
  remove)
    grep -v -F "$2" .deps > .deps.tmp || true
    mv .deps.tmp .deps
    echo "Removed dependency: $2"
    ;;
  list)
    nl -ba .deps || echo "No dependencies"
    ;;
  apply)
    echo "Installing dependencies..."
    while read -r dep || [ -n "$dep" ]; do
      [[ "$dep" =~ ^# ]] && continue
      [ -z "$dep" ] && continue
      if [ -f package.json ]; then
        npm install "$dep" --no-audit --no-fund || true
      else
        python3 -m pip install "$dep" --no-cache-dir || true
      fi
    done < .deps
    ;;
  *)
    echo "Usage: dep_manager.sh add|remove|list|apply <dependency>"
    ;;
esac

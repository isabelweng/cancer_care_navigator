#!/bin/sh
# Cancer Care Navigator - local launcher for macOS / Linux (needs Python 3).
# Serves this folder on http://localhost:8765 and opens the app. Press Ctrl+C to stop.
cd "$(dirname "$0")" || exit 1
URL="http://localhost:8765/cancer_care_navigator.html"
( sleep 1; (command -v open >/dev/null && open "$URL") || (command -v xdg-open >/dev/null && xdg-open "$URL") ) &
echo "Cancer Care Navigator is running at $URL  (Ctrl+C to stop)"
exec python3 -m http.server 8765 --bind 127.0.0.1

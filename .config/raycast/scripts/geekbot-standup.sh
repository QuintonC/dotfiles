#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Geekbot Standup
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Open Ghostty and run devx omp, triggering the geekbot skill
# @raycast.author quinton
# @raycast.authorURL https://raycast.com/quinton

osascript <<'EOF'
tell application "Ghostty"
    activate
    delay 0.3
    tell application "System Events"
        keystroke "t" using command down
        delay 0.2
        keystroke "cd ~/quintonc/activity && devx omp --config ~/.omp/overlays/rollup.yml --approval-mode yolo 'Prepare my geekbot standup'"
        delay 0.1
        key code 36
    end tell
end tell
EOF

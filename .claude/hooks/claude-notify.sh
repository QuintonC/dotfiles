#!/bin/bash
# Claude Code notification hook — global desktop alerts.
#
# Posts a macOS notification when a Claude Code session needs my attention or
# finishes working. Registered in ~/.claude/settings.json on two events:
#   - Notification: Claude is waiting on me (needs input or permission)
#   - Stop:         Claude finished working
#
# Prefers `terminal-notifier` (so we can show the Claude icon); falls back to
# `osascript` (which always shows the generic Script Editor icon). A hook must
# never disrupt the session, so this always exits 0.

# Sounds are intentionally gentle. Swap for any name in /System/Library/Sounds
# (Tink, Pop, Purr, Submarine, Bottle are the soft ones). Set to "" for a
# silent banner.
NOTIFY_SOUND="Purr"   # Claude is waiting on me
STOP_SOUND="Funk"     # Claude finished

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ICON="${SCRIPT_DIR}/claude.png"

payload="$(cat)"

# Extract a string field from the hook payload (jq if present, else sed).
field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r --arg k "$1" '.[$k] // empty'
  else
    printf '%s' "$payload" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
  fi
}

event="$(field hook_event_name)"
message="$(field message)"
cwd="$(field cwd)"

case "$event" in
  Notification) body="${message:-Waiting for you}";      sound="$NOTIFY_SOUND" ;;
  Stop)         body="Ready for you";                    sound="$STOP_SOUND" ;;
  *)            body="${message:-Needs your attention}"; sound="$NOTIFY_SOUND" ;;
esac

subtitle=""
[ -n "$cwd" ] && subtitle="$(basename "$cwd")"

if command -v terminal-notifier >/dev/null 2>&1; then
  args=(-title "Claude Code" -message "$body")
  [ -n "$subtitle" ] && args+=(-subtitle "$subtitle")
  [ -n "$sound" ] && args+=(-sound "$sound")
  # -contentImage reliably shows the Claude icon (right side) on modern macOS;
  # -appIcon attempts the main icon too (honored on older macOS, ignored on new).
  [ -f "$ICON" ] && args+=(-appIcon "$ICON" -contentImage "$ICON")
  terminal-notifier "${args[@]}" >/dev/null 2>&1 || true
else
  # Fallback: no custom icon is possible via osascript.
  osascript - "Claude Code" "$subtitle" "$body" "$sound" <<'OSA' >/dev/null 2>&1 || true
on run argv
  set theTitle to item 1 of argv
  set theSubtitle to item 2 of argv
  set theBody to item 3 of argv
  set theSound to item 4 of argv
  if theSound is "" then
    if theSubtitle is "" then
      display notification theBody with title theTitle
    else
      display notification theBody with title theTitle subtitle theSubtitle
    end if
  else
    if theSubtitle is "" then
      display notification theBody with title theTitle sound name theSound
    else
      display notification theBody with title theTitle subtitle theSubtitle sound name theSound
    end if
  end if
end run
OSA
fi

exit 0

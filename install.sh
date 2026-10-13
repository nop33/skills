#!/usr/bin/env bash
# Link this knife roll into the places agents look for it.
#
# OpenCode reads ~/.agents/skills directly. Claude Code only reads
# ~/.claude/skills and ~/.claude/CLAUDE.md, so those get symlinks. Tools in
# bin/ are linked into ~/.local/bin so any agent can call them by name.
#
# Safe to run repeatedly. It never replaces a real file or folder, and it
# removes links it made that now point at something deleted from the roll.
set -euo pipefail
shopt -s nullglob

roll="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local target=$1 path=$2
  if [ -L "$path" ]; then
    [ "$(readlink "$path")" = "$target" ] && return
    rm "$path"
  elif [ -e "$path" ]; then
    echo "skip: $path exists and is not a symlink, move it away and rerun" >&2
    return
  fi
  ln -s "$target" "$path"
  echo "linked: $path"
}

prune() {
  local path
  for path in "$1"/*; do
    [ -L "$path" ] || continue
    case "$(readlink "$path")" in "$roll"/*) ;; *) continue ;; esac
    [ -e "$path" ] && continue
    rm "$path"
    echo "removed: $path"
  done
}

mkdir -p "$HOME/.claude/skills" "$HOME/.local/bin"

for skill in "$roll"/skills/*/; do
  skill=${skill%/}
  link "$skill" "$HOME/.claude/skills/$(basename "$skill")"
done

for tool in "$roll"/bin/*; do
  [ -f "$tool" ] && link "$tool" "$HOME/.local/bin/$(basename "$tool")"
done

link "$roll/AGENTS.md" "$HOME/.claude/CLAUDE.md"

prune "$HOME/.claude/skills"
prune "$HOME/.local/bin"

#!/usr/bin/env bash
# Registers this repo's skill/ definitions as Claude Code slash commands by
# symlinking .claude/skills/<name> -> skill/<name>.
#
# Why a script instead of committing .claude/skills directly: symlinks don't
# survive a git clone as links unless core.symlinks is enabled everywhere, so
# every clone/worktree should run this once. skill/ stays the single source
# of truth for all skill content.
#
# Usage: bash scripts/link-skills.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_root="$repo_root/skill"
target_root="$repo_root/.claude/skills"

mkdir -p "$target_root"

for dir in "$skill_root"/*/; do
    name="$(basename "$dir")"
    link="$target_root/$name"

    if [ -e "$link" ]; then
        echo "skip  $name (already linked)"
        continue
    fi

    ln -s "../../skill/$name" "$link"
    echo "link  $name -> skill/$name"
done

#!/usr/bin/env bash
# Builds and installs the tip of origin/main; install.sh opens the app. The build runs in a
# throwaway worktree so that no checkout's branch or uncommitted changes can reach the installed app.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch="$(mktemp -d -t worldclock-update)"
worktree="$scratch/main"

remove_worktree() {
    git -C "$repo_root" worktree remove --force "$worktree" 2>/dev/null || true
    rm -rf "$scratch"
}
trap remove_worktree EXIT

git -C "$repo_root" fetch --quiet origin main
git -C "$repo_root" worktree add --quiet --detach "$worktree" FETCH_HEAD
"$worktree/scripts/build-app.sh"
"$worktree/scripts/install.sh"
git -C "$worktree" log -1 --format='Running %h: %s'

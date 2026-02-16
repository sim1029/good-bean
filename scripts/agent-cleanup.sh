#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/agent-cleanup.sh <task-slug>     — remove one worktree and its branch
#   ./scripts/agent-cleanup.sh --all-merged    — remove all worktrees whose branches are merged to main

REPO_ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)"
WORKTREE_BASE="$(dirname "$REPO_ROOT")/good-bean-worktrees"

cleanup_one() {
  local slug="$1"
  local worktree_dir="$WORKTREE_BASE/$slug"
  local branch="agent/$slug"

  if [ -d "$worktree_dir" ]; then
    echo "Removing worktree: $worktree_dir"
    git -C "$REPO_ROOT" worktree remove "$worktree_dir" --force
  else
    echo "Worktree not found: $worktree_dir"
  fi

  if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Deleting branch: $branch"
    git -C "$REPO_ROOT" branch -D "$branch"
  else
    echo "Branch not found: $branch"
  fi
}

cleanup_all_merged() {
  echo "Fetching latest main..."
  git -C "$REPO_ROOT" fetch origin main --quiet

  local found=0
  for branch in $(git -C "$REPO_ROOT" branch --merged origin/main --format='%(refname:short)' | grep '^agent/'); do
    local slug="${branch#agent/}"
    echo "--- Cleaning up merged: $slug ---"
    cleanup_one "$slug"
    found=1
  done

  if [ "$found" -eq 0 ]; then
    echo "No merged agent branches found."
  fi
}

ARG="${1:?Usage: $0 <task-slug> | --all-merged}"

if [ "$ARG" = "--all-merged" ]; then
  cleanup_all_merged
else
  cleanup_one "$ARG"
fi

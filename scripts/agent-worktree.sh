#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/agent-worktree.sh <task-slug> [prompt]
#
# Creates a git worktree for an agent and launches Claude Code in it.
# If a prompt is provided, runs headless. Otherwise opens interactive mode.

TASK_SLUG="${1:?Usage: $0 <task-slug> [prompt]}"
PROMPT="${2:-}"

REPO_ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)"
WORKTREE_BASE="$(dirname "$REPO_ROOT")/good-bean-worktrees"
WORKTREE_DIR="$WORKTREE_BASE/$TASK_SLUG"
BRANCH="agent/$TASK_SLUG"

# Fetch latest main
echo "Fetching latest origin/main..."
git -C "$REPO_ROOT" fetch origin main --quiet

# Create worktree directory if needed
mkdir -p "$WORKTREE_BASE"

# Create the worktree and branch
echo "Creating worktree at $WORKTREE_DIR on branch $BRANCH..."
git -C "$REPO_ROOT" worktree add -b "$BRANCH" "$WORKTREE_DIR" origin/main

# Launch Claude Code
if [ -n "$PROMPT" ]; then
  echo "Launching headless agent with prompt..."
  claude --dangerously-skip-permissions -p "$PROMPT" --cwd "$WORKTREE_DIR"
else
  echo "Launching interactive agent..."
  claude --dangerously-skip-permissions --cwd "$WORKTREE_DIR"
fi

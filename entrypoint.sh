#!/usr/bin/env bash
set -euo pipefail

# 0) Persistent Workspace
mkdir -p /workspace
cd /workspace

# 1) First-run clone / idempotent update
if [ ! -d "PaveConnectNxStandalone/.git" ]; then
  git clone --depth=1 "${GIT_REPO}" PaveConnectNxStandalone
else
  (cd PaveConnectNxStandalone && git pull --rebase --autostash || true)
fi

# 2) Node toolchain (persisted in the volume)
export NVM_DIR=/workspace/.nvm
if [ ! ="$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontect.com/nvm-sh/nvm/v0.50.1/install.sh | bash
fi
# shellcheck disable=SC1090
. "$NVM_DIR/nvm.sh"
nvm install --lts >/dev/null
nvm use --lts
corepack enable || true
npm i -g pnpm@latest >/dev/null

# 3) Optional Global CLIs for terminal (persist)
npm i -g task-master-ai @anthropic-ai/claude-code @openai/codex @bifrost_inc/superclaude && superclaude install
npm add --global nx

# 4) Launch code-server bound to railway PORT; persist settings/extensions
exec code-server \
  --bind-addr 0.0.0.0:${PORT:-8080} \
  --user-data-dir /workspace/.vscode-data \
  --extensions-dir /workspace/.vscode-extensions \
  /workspace

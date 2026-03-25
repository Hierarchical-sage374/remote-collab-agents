#!/usr/bin/env bash
# remote-agent.sh -- Invoke Claude Code or Codex CLI on remote machines via SSH.
#
# Each machine has different install paths and env setup requirements.
# This script handles the per-host environment bootstrapping transparently.
set -euo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [[ -L "$SCRIPT_SOURCE" ]]; do SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"; done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<'EOF'
Usage:
  remote-agent <target> claude  -p "<prompt>"  [options]
  remote-agent <target> codex   exec "<prompt>" [options]
  remote-agent <target> --info

Subcommands:
  claude -p "<prompt>"         Run Claude Code in pipe mode (non-interactive)
  claude -p "<prompt>" --json  Output as JSON
  codex exec "<prompt>"        Run Codex in non-interactive mode
  --info                       Show agent versions and paths on target

Options:
  --cwd <path>         Set working directory on remote (default: ~)
  --timeout <secs>     SSH timeout (default: 600)
  --bg                 Run in background via remote-wrapper
  -h, --help           Show this help

Examples:
  remote-agent workstation-a claude -p "explain main.py"
  remote-agent workstation-b codex exec "add error handling to server.py"
  remote-agent workstation-a claude -p "list files" --cwd ~/projects/myapp
  remote-agent workstation-a --bg claude -p "refactor the auth module"
  remote-agent all     --info
EOF
}

# Per-host environment bootstrap commands
# Each host may have claude/codex installed differently
env_bootstrap() {
  local target="$1"
  case "$target" in
    # ── Customize these cases for your machines ──
    # Each machine may install claude/codex differently.
    # Add a case per host alias matching your hosts.conf.
    workstation-a)
      # Example: nvm-managed node, claude & codex via npm global
      cat <<'ENVSH'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
ENVSH
      ;;
    workstation-b)
      # Example: claude in ~/.local/bin, codex in ~/.npm-global/bin
      cat <<'ENVSH'
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
ENVSH
      ;;
    macbook)
      # Example: typically in PATH already via npm global or homebrew
      cat <<'ENVSH'
true
ENVSH
      ;;
    *)
      # Fallback: try common locations
      cat <<'ENVSH'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
ENVSH
      ;;
  esac
}

agent_info() {
  local target="$1"
  resolve_host "$target"
  build_ssh_array

  local bootstrap
  bootstrap="$(env_bootstrap "$target")"

  "${SSH_ARRAY[@]}" "bash -s" <<REMOTE
$bootstrap

echo "=== Agent Info on \$(hostname) ==="
echo ""

# Claude Code
if command -v claude >/dev/null 2>&1; then
  claude_path="\$(which claude)"
  echo "Claude Code: \$claude_path"
  # Try to get version safely
  claude_ver="\$(claude --version 2>/dev/null || echo 'unknown')"
  echo "  Version: \$claude_ver"
else
  echo "Claude Code: NOT INSTALLED"
fi

echo ""

# Codex
if command -v codex >/dev/null 2>&1; then
  codex_path="\$(which codex)"
  echo "Codex CLI:   \$codex_path"
  codex_ver="\$(codex --version 2>/dev/null || echo 'unknown')"
  echo "  Version: \$codex_ver"
else
  echo "Codex CLI:   NOT INSTALLED"
fi

echo ""
echo "Node.js:     \$(node --version 2>/dev/null || echo 'NOT FOUND')"
echo "Working dir: \$(pwd)"
REMOTE
}

run_agent_command() {
  local target="$1"
  local cwd="$2"
  local timeout_secs="$3"
  local bg_mode="$4"
  shift 4
  # remaining args: the agent command (e.g. claude -p "..." or codex exec "...")

  [[ $# -gt 0 ]] || die "No agent command specified"

  resolve_host "$target"

  local bootstrap
  bootstrap="$(env_bootstrap "$target")"

  # Properly quote each argument to preserve spaces in prompts
  local quoted_args=""
  local arg
  for arg in "$@"; do
    quoted_args+="$(printf '%q ' "$arg")"
  done

  local full_cmd
  full_cmd="${bootstrap}
cd $(printf '%q' "$cwd") 2>/dev/null || true
${quoted_args}"

  if [[ "$bg_mode" == "true" ]]; then
    local task_id
    task_id="agent-$(basename "$RESOLVED_HOST")-$(date +%Y%m%d-%H%M%S)-$(xxd -p -l 4 /dev/urandom 2>/dev/null || echo '0000')"
    local wrapper_cmd="~/.claude/skills/remote-collab/scripts/remote-wrapper.sh $(printf '%q' "$task_id") $(printf '%q' "bash -lc $(printf '%q' "$full_cmd")")"
    build_ssh_array
    "${SSH_ARRAY[@]}" "$wrapper_cmd" >/dev/null
    log_info "Started background agent task on $target"
    log_info "Task ID: $task_id"
    log_info "View logs: remote-exec $target --bg-log $task_id"
    return 0
  fi

  # Foreground execution
  build_ssh_array
  local timeout_tool
  if [[ "$timeout_secs" != "0" ]] && timeout_tool="$(timeout_bin 2>/dev/null)"; then
    "$timeout_tool" "$timeout_secs" "${SSH_ARRAY[@]}" "bash -lc $(printf '%q' "$full_cmd")"
  else
    "${SSH_ARRAY[@]}" "bash -lc $(printf '%q' "$full_cmd")"
  fi
}

timeout_bin() {
  if command -v timeout >/dev/null 2>&1; then
    printf '%s\n' "timeout"
    return 0
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    printf '%s\n' "gtimeout"
    return 0
  fi
  return 1
}

main() {
  if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  load_config

  local target="$1"
  shift

  local cwd="~"
  local timeout_secs="600"
  local bg_mode="false"
  local agent_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --info)
        if [[ "$target" == "all" ]]; then
          local host
          while IFS= read -r host; do
            [[ -n "$host" ]] || continue
            log_host "$host" "Querying agent info..."
            agent_info "$host" 2>&1 | while IFS= read -r line; do
              log_host "$host" "$line"
            done
            echo ""
          done < <(get_all_hosts)
        else
          agent_info "$target"
        fi
        exit 0
        ;;
      --cwd)
        [[ $# -ge 2 ]] || die "--cwd requires a path"
        cwd="$2"
        shift 2
        ;;
      --timeout)
        [[ $# -ge 2 ]] || die "--timeout requires seconds"
        timeout_secs="$2"
        shift 2
        ;;
      --bg)
        bg_mode="true"
        shift
        ;;
      --)
        shift
        agent_args+=("$@")
        break
        ;;
      *)
        agent_args+=("$1")
        shift
        ;;
    esac
  done

  [[ ${#agent_args[@]} -gt 0 ]] || die "No agent command. Use: remote-agent <target> claude -p '...' or codex exec '...'"

  # Validate the first arg is a known agent
  local agent="${agent_args[0]}"
  case "$agent" in
    claude|codex) ;;
    *) die "Unknown agent '$agent'. Supported: claude, codex" ;;
  esac

  # Safety: agent invocations are always "needs-confirmation" level
  local display_cmd="${agent_args[*]}"
  log_info "Agent: $agent on $target"
  log_info "Command: $display_cmd"
  log_info "Working dir: $cwd"

  if [[ "$target" == "all" ]]; then
    local host
    while IFS= read -r host; do
      [[ -n "$host" ]] || continue
      log_host "$host" "Running $agent..."
      run_agent_command "$host" "$cwd" "$timeout_secs" "$bg_mode" "${agent_args[@]}" 2>&1 | while IFS= read -r line; do
        log_host "$host" "$line"
      done
      echo ""
    done < <(get_all_hosts)
  else
    run_agent_command "$target" "$cwd" "$timeout_secs" "$bg_mode" "${agent_args[@]}"
  fi
}

main "$@"

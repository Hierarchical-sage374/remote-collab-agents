---
name: remote-agent
description: Invoke Claude Code or Codex CLI on remote machines. Triggers on "let workstation's claude do X", "use remote codex", "delegate to remote agent", "remote claude", "remote codex", or /remote-agent.
---

# Remote Agent

Invoke Claude Code (`claude -p`) or Codex CLI (`codex exec`) on remote machines via SSH.

## When to Use

- User says "让工作站上的 claude 分析这段代码" / "have workstation's claude analyze this"
- User says "用远程 codex 重构" / "use remote codex to refactor"
- Task needs GPU machine's agent (e.g., training code review)
- Delegate subtasks to remote agents for parallel work
- User invokes `/remote-agent`

## How to Use

```bash
# Symlink (if set up)
remote-agent <target> claude -p "<prompt>"
remote-agent <target> codex exec "<prompt>"

# Or full path
bash ~/.claude/skills/remote-collab/scripts/remote-agent.sh <target> claude -p "<prompt>"
```

### Claude Code (pipe mode)

```bash
# Simple prompt
remote-agent workstation-a claude -p "explain the main function in server.py"

# With working directory
remote-agent workstation-b claude -p "run the tests" --cwd ~/projects/webapp

# Background (long-running task)
remote-agent workstation-a --bg claude -p "refactor the auth module to use JWT"
```

### Codex CLI

```bash
# Non-interactive execution
remote-agent workstation-b codex exec "add input validation to api.py"

# With working directory
remote-agent workstation-b codex exec "fix the failing tests" --cwd ~/projects/webapp
```

### Query agent availability

```bash
# Check one machine
remote-agent workstation-a --info

# Check all machines
remote-agent all --info
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|:--------:|---------|-------------|
| target | Yes | — | Host alias from hosts.conf, or `all` |
| agent | Yes | — | `claude` or `codex` |
| prompt | Yes | — | The task prompt (quoted) |
| --cwd | No | `~` | Remote working directory |
| --timeout | No | 600 | SSH timeout in seconds |
| --bg | No | false | Run in background (survives disconnect) |

## Environment Bootstrapping

SSH non-interactive mode does not load `.bashrc` / `.profile`, so agent CLIs may not be in PATH. The script handles this per-host via `env_bootstrap()` in `remote-agent.sh`.

Common patterns:

| Install method | Bootstrap needed |
|:---|:---|
| nvm (npm global) | `source ~/.nvm/nvm.sh` |
| ~/.local/bin (standalone) | `PATH+=~/.local/bin` |
| /usr/local/bin (system) | None |
| ~/.npm-global/bin | `PATH+=~/.npm-global/bin` |

Edit the `env_bootstrap()` function in `scripts/remote-agent.sh` to match your machines.

## Claude `-p` Mode Options

| Flag | Effect |
|------|--------|
| `-p "<prompt>"` | Pipe mode — non-interactive, returns text |
| `--json` | Output structured JSON |
| `--allowedTools "Bash,Read,Write"` | Restrict available tools |
| `--max-turns 5` | Limit agentic turns |

## Codex `exec` Mode Options

| Flag | Effect |
|------|--------|
| `exec "<prompt>"` | Non-interactive execution |
| `--model <model>` | Override model |
| `--full-auto` | Auto-approve all actions |

## Safety Rules

1. **Agent invocations always show confirmation** — the prompt is displayed before execution
2. **Working directory matters** — Codex requires a git repo; use `--cwd` to set it
3. **Background tasks** — use `--bg` for long tasks; check with `remote-exec <target> --bg-list`
4. **Timeouts** — default 600s; increase for large refactoring tasks: `--timeout 1800`
5. **No secret forwarding** — API keys must be configured on the remote machine itself

## Architecture

```
Local Machine                    Remote Machine
┌──────────────┐    SSH         ┌──────────────────────────┐
│ Claude Code  │──────────────►│ bash -l                   │
│ (local)      │               │  ├─ source nvm.sh         │
│              │               │  ├─ cd <working-dir>      │
│ remote-agent │               │  └─ claude -p "<prompt>"  │
│   host claude│               │       │                   │
│   -p "..."   │◄──────────────│       └─ stdout response  │
└──────────────┘    stdout     └──────────────────────────┘
```

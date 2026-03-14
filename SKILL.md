---
name: watchdog
description: "AI session immune system - ambient health awareness, gentle nudges"
version: 2.0.0
triggers: [/watchdog, /wd, watchdog]
sandbox_mode: read-only
timeout_seconds: 60
priority: 95
---

# Watchdog - AI Session Immune System

Like `/btw` for session health — always sensing in the background, only nudging you when something's off.

## Usage

```bash
/watchdog                       # quick check (btw-style, 1-3 line output, zero cost)
/watchdog --deep                # deep diagnosis (external AI evaluation)
/watchdog --report              # full report (with trend history, auto-deep)
/watchdog --delta               # delta report (compare with last check)
/watchdog --auto --interval 5   # ambient auto-monitoring (every N interactions)
/watchdog --status              # view monitoring status
/watchdog --off                 # disable auto monitoring
/watchdog --reset               # reset state files
/watchdog --evaluator codex     # specify evaluator for Deep Mode
```

## Dual-Mode Architecture

| | Quick Mode (default) | Deep Mode (--deep) |
|--|---------------------|---------------------|
| **Evaluator** | Claude self-assessment | External AI (Gemini/Codex) |
| **Cost** | $0 (reuses current session) | ~$0.03/check |
| **Latency** | Instant (<2s) | 5-30s |
| **Output** | Silent / 1-line / 3-line | Full formatted report |
| **Use case** | Daily monitoring | Deep diagnosis on persistent issues |

## 5-Dimension Detection

| Dimension | Weight | What It Catches |
|-----------|--------|----------------|
| STUCK | 25% | No progress, repeated actions, loops |
| DRIFT | 25% | Deviation from original task |
| HALLUCINATION | 20% | References to non-existent files/APIs |
| CONTEXT_DECAY | 15% | Lost context, forgotten constraints |
| VELOCITY_DROP | 15% | Declining output, inefficient tool use |

## 4-Level Severity

| Level | Score | Quick Mode Output |
|-------|-------|------------------|
| HEALTHY | 0-20 | Complete silence (no interruption) |
| WARNING | 21-50 | Single-line hint |
| CRITICAL | 51-80 | 3-line summary |
| EMERGENCY | 81-100 | Alert + prompt |

## Auto Mode

With `--auto` enabled:
- **With Ralph**: Piggybacks on Ralph's iteration loop for automatic Quick Checks
- **Without Ralph**: Claude passively triggers checks every N interactions
- **Silent when healthy**, gentle nudge when not
- 2 consecutive WARNINGs → auto-suggests `--deep`

## Output Preview

```
🐕 35 ⚠️ stuck↗ ctx:78% → consider checkpoint         ← WARNING (1-line)

🐕 62/100 🟠 CRITICAL                                   ← CRITICAL (3-line)
  stuck:███████░░░ 68 | velocity↘↘
  → pause, git stash, rethink approach
```

## Design Principles

- **btw philosophy** — zero interruption, ambient awareness, surfaces only on anomalies
- **Read-only** — never modifies your code
- **Zero-cost default** — Quick Mode reuses current session, no extra overhead
- **Progressive escalation** — Quick → Deep, from lightweight sensing to deep diagnosis
- **Self-healing suggestions** — tells you what's wrong AND how to fix it

## Troubleshooting

See `modules/troubleshooting.md` for common issues.

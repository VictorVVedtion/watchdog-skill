---
name: watchdog
description: "AI 会话免疫系统 - 环境健康感知，轻触提醒"
version: 2.0.0
triggers: [/watchdog, /wd, /btw, watchdog]
sandbox_mode: read-only
timeout_seconds: 60
priority: 95
---

# Watchdog - AI 会话免疫系统

基于 Claude Code 的轻量级健康感知识别器。像 `/btw` 一样作为你的 side-channel，随时检测并以极简的 ASCII UI 提醒你当前会话是否偏离目标（漂移）、卡死或丧失上下文。

## 调用方式

```bash
/btw                            # (或 /watchdog) 极速模式：快速心跳检测，健康时静默
/watchdog --deep                # 深度模式：调用外部 AI (Gemini/Codex) 出具完整体检报告
/watchdog --auto --interval 5   # 自动模式：常驻后台定时嗅探
/watchdog --status              # 查看当前监控雷达状态
/watchdog --off                 # 召回看门狗（关闭自动监控）
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

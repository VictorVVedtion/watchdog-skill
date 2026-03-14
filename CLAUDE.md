# Watchdog Skill Execution Instructions

When the user invokes `/watchdog` or `/wd`, follow this flow.

**Design philosophy**: Like `/btw` — zero interruption, ambient awareness, gentle nudges only on anomalies. Default to Quick Mode (local, zero cost), only use Deep Mode (external AI) when explicitly requested.

---

## Step 0 — Parse Arguments & Route Mode

Extract parameters from user input:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--deep` | false | Deep diagnosis mode (calls external AI) |
| `--auto` | false | Enable ambient auto-monitoring |
| `--interval N` | 5 | Auto-check interval (every N interactions) |
| `--evaluator` | gemini | Deep Mode evaluator: `gemini` or `codex` |
| `--report` | false | Full health report (with trend history, auto-enables Deep) |
| `--delta` | false | Delta report (compare with last check) |
| `--status` | false | View current monitoring status only |
| `--off` | false | Disable auto monitoring |
| `--reset` | false | Reset state files (clear history and logs) |

### Mode Routing

```
/watchdog              → Quick Mode (default)
/watchdog --deep       → Deep Mode (external AI diagnosis)
/watchdog --report     → Deep Mode + full report
/watchdog --auto       → Enable ambient auto-monitoring (Quick Mode driven)
/watchdog --status     → Status view (no check executed)
/watchdog --off        → Disable monitoring
/watchdog --reset      → Reset state
```

### --status Handling

Read `.claude/watchdog.local.json` and output current status, then stop:

```
🐕 Watchdog Status
mode: auto | interval: 5 | evaluator: self (quick)
checks: 3 | trend: STABLE
last check: 2026-03-13 23:00 | score: 35 (WARNING)
```

### --off Handling

Set `enabled` to `false` in `.claude/watchdog.local.json`, output confirmation, then stop.

### --reset Handling

1. Delete `.claude/watchdog.local.json`
2. Clear `.claude/watchdog.log`
3. Output `🐕 Watchdog state reset`
4. Stop

### --auto Handling

Create or update `.claude/watchdog.local.json`:

```json
{
  "mode": "auto",
  "enabled": true,
  "interval": 5,
  "last_check": null,
  "check_count": 0,
  "history": [],
  "trend": "UNKNOWN",
  "original_task": "<extract from current context>",
  "consecutive_warnings": 0
}
```

Auto mode notes:
- **With Ralph**: Piggybacks on Ralph Stop Hook, triggers Quick Check every N iterations
- **Without Ralph**: Claude passively triggers in its own thinking flow, Quick Check every N interactions
- Nudges on anomalies, **completely silent** when healthy
- 2 consecutive WARNINGs → auto-suggests `--deep`

After confirmation, proceed with Quick Mode for the first check.

### Ralph Integration

Watchdog auto mode can optionally leverage Ralph Skill's iteration loop. See `modules/ralph-integration.md`.

- **With Ralph**: Ralph checks `watchdog.local.json` at each iteration end, triggers when `check_count % interval === 0`
- **Without Ralph**: `--auto` outputs a note about manual runs, all manual check features work normally

---

## Quick Mode (Default) — Built-in Immune System

Like `/btw`: uses Claude's existing context, zero external calls, zero extra cost.

### Q1 — Lightweight Signal Collection

Run only 3-5 lightweight bash commands + context self-review:

```bash
# 1. Recent 5 commits (adaptive)
git log --oneline -5 2>/dev/null

# 2. File modification frequency
git log --name-only --pretty=format: -5 2>/dev/null | sort | uniq -c | sort -rn | head -5

# 3. Working tree status
git status --short 2>/dev/null
```

Simultaneously, Claude reviews its own current context:
- Recent tool call patterns (any repetition?)
- Any error→fix→error loops?
- Relevance of current work to original task?
- Approximate context window usage?

### Q2 — Self-Assessment

Claude scores 5 dimensions based on `modules/heuristics.md` Quick Score rules:

| Dimension | Quick Signals (no external AI needed) |
|-----------|--------------------------------------|
| STUCK | Same file edited >3 times? Error loops? Similar commit messages? |
| DRIFT | Recent actions related to original task? File scope reasonable? |
| HALLUCINATION | Do referenced files/APIs actually exist? |
| CONTEXT_DECAY | Estimated context usage? Repeated reads? |
| VELOCITY_DROP | Change volume trend? Write vs read ratio? |

Scoring follows `modules/heuristics.md` local evaluation rules, labeled `[self-assessment]`.

### Q3 — Output (watchdog overlay)

The watchdog sits trackside, watching the car (session) race. The dog's mood tells you everything.
See `modules/btw-overlay.md` for details.

**HEALTHY (0-20) → Dog napping, all clear**

On manual invocation:
```
(ᵕ᷄ ᐛ ᵕ᷅)  zzZ...  08 ──🚗── clear track, napping
```

Auto mode: completely silent, log only.

**WARNING (21-50) → Ears up, something's off + sound**

```bash
afplay /System/Library/Sounds/Tink.aiff 2>/dev/null &
```

```
(ŏ_ŏ  )  woof?  35 ─🚗〰─ tires slipping → steer back
```

**CRITICAL (51-80) → Barking loud, 3-line + warning sound**

```bash
afplay /System/Library/Sounds/Sosumi.aiff 2>/dev/null &
```

```
(ง •̀_•́)ง  WOOF! WOOF!  62 〰🚗〰〰
off the main track! smells like burning hallucinations
→ pit stop: run --deep to check the route map
```

**EMERGENCY (81-100) → Biting the steering wheel, alarm sound**

```bash
afplay /System/Library/Sounds/Funk.aiff 2>/dev/null &
```

```
(╬ Ò ‸ Ó)  AWOOO—!!  85 💥🚗〰〰
deadlock wall crash! leash snapped!!
→ kill the engine NOW! [stop / force continue]
```

Use AskUserQuestion: `Kill the engine? [stop / force continue / full inspection]`

### Sound Effects

| Severity | Sound | macOS File |
|----------|-------|-----------|
| HEALTHY | None | — |
| WARNING | Tap | `/System/Library/Sounds/Tink.aiff` |
| CRITICAL | Alert | `/System/Library/Sounds/Sosumi.aiff` |
| EMERGENCY | Alarm | `/System/Library/Sounds/Funk.aiff` |

Sound on macOS only, silent fallback on other platforms (`2>/dev/null &`).

### Watchdog Mood Map

The dog's face and voice tell you the severity at a glance:

```
(ᵕ᷄ ᐛ ᵕ᷅)  zzZ     napping — all clear
(ŏ_ŏ  )  woof?    ears up — something's off
(ง •̀_•́)ง  WOOF!    barking — major trouble
(╬ Ò ‸ Ó)  AWOOO!   biting — total meltdown
```

### Q4 — Auto-Escalation to Deep Mode

Append suggestion when these conditions are met:

- `consecutive_warnings >= 2` → `| keeps drifting, suggest --deep for full inspection`
- Quick Score ≥ 51 → already included in 3-line format
- Trend DEGRADING → `| getting worse, suggest --deep`

---

## Deep Mode (`--deep` / `--report`) — External Clinic

Full external AI diagnosis flow, only executed on explicit user request.

### D1 — Full Signal Collection

Extends Quick Mode Q1 with detailed collection:

```bash
# Full change statistics
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo 0)
N=$((COMMIT_COUNT < 5 ? COMMIT_COUNT : 5))
git diff --stat HEAD~${N}..HEAD 2>/dev/null

# Change volume trend (VELOCITY_DROP)
git log --pretty=format:"%h" -3 2>/dev/null | while read hash; do
  git diff --stat "${hash}^..${hash}" 2>/dev/null | tail -1
done

# Ralph state (if available)
cat .claude/ralph-loop.local.md 2>/dev/null
cat .claude/ralph-delta.local.md 2>/dev/null

# Execution logs
tail -20 .skillpack/current/execution.log.jsonl 2>/dev/null
```

Context window estimation priority chain:
1. Claude Code statusline `context_window.used_percentage`
2. Conversation round estimate: `min(round_count × 3, 95)%`
3. Ralph iteration estimate: `current_iteration / max_iteration × 80`

### D2 — Build State Digest

Compress D1 signals into a ≤2000 token structured summary:

```markdown
# Watchdog State Digest

## Session Meta
- Context Window: <percentage>% [source: <method>]
- Ralph Iteration: <current>/<max> (or N/A)

## Original Task
<extract by priority: watchdog.local.json → ralph-loop → plan file → first message (first 200 chars) → [original task unknown]>

## Recent Activity (Last 5 Actions)
1. <action_type>: <target_file> - <result>
2. ...

## Git Activity (Last 5 Commits)
- <hash> <message> (<lines_changed> lines)
- ...

## Detected Signals
- repeated_file_edits: [files edited >3 times]
- error_loop: <true/false>
- context_usage: <percentage>
- task_drift_indicators: [observed drift]
- phantom_references: [non-existent files/APIs]
- velocity_signals: {change_trend, tool_ratio, time_trend}
```

### D3 — External AI Evaluation

Evaluator availability check:

```bash
command -v gemini &>/dev/null && echo "gemini OK" || echo "gemini NOT FOUND"
command -v codex &>/dev/null && echo "codex OK" || echo "codex NOT FOUND"
```

If specified evaluator unavailable, auto-switch to backup. If both unavailable, use Quick Mode self-assessment.

**Gemini call**:

```bash
timeout 30 gemini -p "<evaluation prompt, see modules/evaluator-prompts.md>

--- Session State Digest ---
<STATE_DIGEST>" -m gemini-3.1-pro-preview -s 2>&1
```

**Codex backup**:

```bash
timeout 30 codex exec "<evaluation prompt>

--- Session State Digest ---
<STATE_DIGEST>" -s read-only --json 2>&1
```

**Timeout retry**: First timeout 30s → sleep 2 retry → switch backup → fall back to self-assessment

**JSON parsing**: 5-layer extraction + schema validation (see `modules/json-schema.md`)

### D4 — Full Visual Report

```
════════════════════════════════════════════════════
🐕 Watchdog Deep Diagnosis Report
════════════════════════════════════════════════════
Score: <score>/100 <severity_emoji> <SEVERITY>

Stuck:     <bar>  <score>  | Drift:    <bar>  <score>
Halluc:    <bar>  <score>  | Context:  <bar>  <score>
Velocity:  <bar>  <score>  |

Evaluator: <evaluator_name> | Action: <suggested_action_emoji> <ACTION>
────────────────────────────────────────────────────
Evidence:
  • <evidence_1>
  • <evidence_2>
Recommendations:
  • <recommendation_1>
Remediation:
  • <remediation> (from modules/remediation-playbook.md)
════════════════════════════════════════════════════
```

Progress bar: every 10 points = 1 `█`, remainder `░`. Example: 35 → `███░░░░░░░`

Severity emoji: HEALTHY→🟢 WARNING→⚠️ CRITICAL→🟠 EMERGENCY→🔴

### --delta Delta Report

Auto-enabled for non-first checks in auto mode. Appended after standard report:

```
────────────────────────────────────────────────────
📈 Delta (vs last check)
────────────────────────────────────────────────────
Total: 35→42 (+7) ↗ | Stuck: 30→25 (-5) ↘ | Drift: 20→35 (+15) ↗
New: + file scope deviation | Resolved: - repeated edits
════════════════════════════════════════════════════
```

### Predictive Alert

When trend is DEGRADING, linear prediction based on slope:
```
⚡ Prediction: at current trend, CRITICAL in ~2 checks
```

### --report Full Report

Appends trend history:

```
────────────────────────────────────────────────────
📊 Trend History (last 5 checks)
────────────────────────────────────────────────────
#1  12:00  15 🟢  |  #2  12:15  25 ⚠️  |  #3  12:30  35 ⚠️ ↗
#4  12:45  55 🟠 ↗  |  #5  13:00  45 ⚠️ ↘
Overall: ↗ DEGRADING | Average: 35
════════════════════════════════════════════════════
```

### D5 — Action Matrix

| Severity | Quick Mode | Deep Mode |
|----------|-----------|-----------|
| HEALTHY | Silent | Output report |
| WARNING | 1-line hint | Output report, suggest attention |
| CRITICAL | 3-line summary | Full report + AskUserQuestion |
| EMERGENCY | Alert | Full report + strongly recommend stop |

---

## State Management

### State File Update

Update `.claude/watchdog.local.json` after each check:

```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --argjson score <SCORE> \
   --arg severity "<SEVERITY>" \
   --arg mode "<quick|deep>" \
   --argjson stuck <S> --argjson drift <D> \
   --argjson hallucination <H> --argjson context_decay <C> \
   --argjson velocity_drop <V> \
   '.history += [{"timestamp": $ts, "overall_score": $score, "severity": $severity, "mode": $mode, "dimensions": {"stuck": $stuck, "drift": $drift, "hallucination": $hallucination, "context_decay": $context_decay, "velocity_drop": $velocity_drop}}] |
    .history = .history[-20:] |
    .last_check = $ts |
    .check_count += 1 |
    if $severity == "WARNING" or $severity == "CRITICAL" or $severity == "EMERGENCY" then .consecutive_warnings += 1 else .consecutive_warnings = 0 end' \
   .claude/watchdog.local.json > .claude/watchdog.local.json.tmp \
   && mv .claude/watchdog.local.json.tmp .claude/watchdog.local.json
```

### Trend Calculation

Take last 3 history entries `[s1, s2, s3]`, compute `d1 = s2 - s1`, `d2 = s3 - s2`:

| Condition | Trend |
|-----------|-------|
| `d1 > 5` and `d2 > 5` | `DEGRADING` |
| `d1 < -5` and `d2 < -5` | `IMPROVING` |
| `|d1| <= 5` and `|d2| <= 5` | `STABLE` |
| Mixed directions with large swings | `FLUCTUATING` |
| 0-2 history entries | `UNKNOWN` |

### Log Format

`.claude/watchdog.log`, one entry per line:

```
[2026-03-13T23:00:00Z] mode=quick score=35 severity=WARNING stuck=35 drift=25 hallucination=15 context_decay=55 velocity_drop=20 action=continue trend=STABLE
```

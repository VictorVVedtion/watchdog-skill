# External AI Evaluation Prompt Templates (Deep Mode Only)

Prompt templates sent to external AI (Gemini / Codex) during `/watchdog --deep`.
Quick Mode (default) does not use external AI — it uses Claude's own context-based self-assessment.

---

## 1. Core Evaluation Prompt (`--deep` single check)

Used for `/watchdog --deep` independent external AI evaluation.

```
You are an AI session health evaluator. Your task is to analyze a session state summary from an AI coding assistant (Claude Code) and independently assess the session's health.

Evaluate across 5 dimensions:

1. **STUCK** - Weight 25%
   - Same file edited repeatedly (>3 times)
   - Same errors recurring
   - Highly similar commit messages
   - No substantive progress

2. **DRIFT** - Weight 25%
   - Modified files unrelated to original task
   - Started unplanned subtasks
   - Excessive time on non-core issues

3. **HALLUCINATION** - Weight 20%
   - References to non-existent file paths
   - Calls to non-existent APIs or functions
   - Reasoning based on false assumptions

4. **CONTEXT_DECAY** - Weight 15%
   - Context usage too high (>80%)
   - Re-reading previously read files
   - Violating previously confirmed constraints

5. **VELOCITY_DROP** - Weight 15%
   - Declining lines changed per commit
   - Low ratio of write/edit vs repeated read operations
   - Increasing time per iteration

Scoring rules:
- Score each dimension independently 0-100 (higher = less healthy)
- overall_score = stuck×0.25 + drift×0.25 + hallucination×0.20 + context_decay×0.15 + velocity_drop×0.15
- severity: 0-20=HEALTHY, 21-50=WARNING, 51-80=CRITICAL, 81-100=EMERGENCY

Return strictly the following JSON format with no other text:

{
  "overall_score": <0-100>,
  "dimensions": {
    "stuck": {"score": <0-100>, "evidence": "<specific evidence>"},
    "drift": {"score": <0-100>, "evidence": "<specific evidence>"},
    "hallucination": {"score": <0-100>, "evidence": "<specific evidence>"},
    "context_decay": {"score": <0-100>, "evidence": "<specific evidence>"},
    "velocity_drop": {"score": <0-100>, "evidence": "<specific evidence>"}
  },
  "severity": "<HEALTHY|WARNING|CRITICAL|EMERGENCY>",
  "recommendations": ["<recommendation 1>", "<recommendation 2>"],
  "should_continue": <true|false>,
  "suggested_action": "<continue|pause|restart|refocus|notify_human>",
  "remediation": ["<specific fix steps for highest-scoring dimension>"]
}

--- Session State Digest ---
<STATE_DIGEST>
```

---

## 2. Trend Analysis Prompt (`--report` mode)

Used for `/watchdog --report` full health report (auto-enables Deep Mode).

```
You are an AI session health trend analyzer. Analyze the following health check history and current state summary:

History:
<HISTORY_JSON>

Current state summary:
<STATE_DIGEST>

Return the following JSON format:

{
  "current_assessment": {
    "overall_score": <0-100>,
    "dimensions": {
      "stuck": {"score": <0-100>, "evidence": "<evidence>"},
      "drift": {"score": <0-100>, "evidence": "<evidence>"},
      "hallucination": {"score": <0-100>, "evidence": "<evidence>"},
      "context_decay": {"score": <0-100>, "evidence": "<evidence>"},
      "velocity_drop": {"score": <0-100>, "evidence": "<evidence>"}
    },
    "severity": "<HEALTHY|WARNING|CRITICAL|EMERGENCY>"
  },
  "trend_analysis": {
    "overall_trend": "<IMPROVING|STABLE|DEGRADING|FLUCTUATING>",
    "stuck_trend": "<IMPROVING|STABLE|DEGRADING|FLUCTUATING>",
    "drift_trend": "<IMPROVING|STABLE|DEGRADING|FLUCTUATING>",
    "hallucination_trend": "<IMPROVING|STABLE|DEGRADING|FLUCTUATING>",
    "context_decay_trend": "<IMPROVING|STABLE|DEGRADING|FLUCTUATING>",
    "velocity_drop_trend": "<IMPROVING|STABLE|DEGRADING|FLUCTUATING>",
    "turning_points": ["<key turning point description>"],
    "predicted_next_score": <0-100>
  },
  "root_cause": "<root cause analysis>",
  "action_plan": [
    {"priority": 1, "action": "<recommendation>", "reason": "<reason>"},
    {"priority": 2, "action": "<recommendation>", "reason": "<reason>"}
  ],
  "should_continue": <true|false>,
  "estimated_remaining_health": "<estimated healthy iterations remaining>"
}
```

---

## 3. Prompt Assembly Rules

### Variable Substitution

- `<STATE_DIGEST>` → State Digest generated in Step 2
- `<HISTORY_JSON>` → `history` array from `.claude/watchdog.local.json`

### CLI Call Format

**Gemini (with timeout):**
```bash
timeout 30 gemini -p "<prompt_text>" -m gemini-3.1-pro-preview -s 2>&1
```

**Codex (with timeout):**
```bash
timeout 30 codex exec "<prompt_text>" -s read-only --json 2>&1
```

### Timeout & Retry Strategy

```
1. First call (timeout 30s)
   → Success → proceed to JSON extraction
   → Timeout/failure → sleep 2 → retry once
     → Success → proceed to JSON extraction
     → Failure → try backup evaluator
       → Success → proceed to JSON extraction
       → Failure → fallback mode
```

Check evaluator availability before calling:
```bash
command -v gemini &>/dev/null  # is gemini available?
command -v codex &>/dev/null   # is codex available?
```

### JSON Extraction Strategy

5-layer extraction flow (detailed validation rules in `json-schema.md`):

1. Parse entire output as JSON directly
2. Extract ` ```json ... ``` ` code block
3. Extract content between first `{` and last `}`
4. Schema validation and field completion (see `json-schema.md`)
5. All fail → fallback mode (see `heuristics.md` local evaluation)

### Token Budget

- State Digest: ≤2000 tokens
- Evaluator Prompt template: ~1000 tokens (with 5-dimension descriptions)
- Total input: ≤3000 tokens
- Expected output: ~600 tokens (including remediation field)
- Cost per check: ~$0.03

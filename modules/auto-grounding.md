# Auto-Grounding — Adaptive Gate Activation

## Concept

Instead of requiring manual gate toggling, auto-grounding activates specific gates when their corresponding risk signals are detected. The dog tightens the leash in rough terrain and loosens it on clear track.

---

## Activation Triggers

### From Watchdog Checks (Reactive → Proactive)

When a watchdog check detects elevated risk, auto-activate the corresponding gate:

| Dimension Score | Gate Activated | Deactivation |
|----------------|---------------|-------------|
| STUCK >= 30 | ROOT_CAUSE | Next check scores < 20 |
| DRIFT >= 30 | RELEVANCE | Next check scores < 20 |
| HALLUCINATION >= 20 | EXIST | Next check scores < 15 |
| CONTEXT_DECAY >= 40 | RECALL | Rest of session |
| VELOCITY_DROP >= 40 | MOMENTUM | 3 consecutive productive actions |

Hysteresis: activate threshold != deactivate threshold (prevents flip-flopping).

### From Gate Failure Patterns (Self-Reinforcing)

| Pattern | Action |
|---------|--------|
| Same gate fails >2 times | Keep gate active, increase alert priority |
| Gate hasn't failed in 10+ checks | Reduce check frequency for that gate |
| All gates passing consistently | Enter "loose leash" mode |

---

## Leash Modes

### Loose Leash (HEALTHY, score 0-20)
- Only EXIST gate active (lightweight)
- Check frequency: every 10 actions
- Alert threshold: only on clear failures

### Tight Leash (WARNING+, score 21+)
- All relevant gates active based on dimension scores
- Check frequency: every 3 actions
- Alert threshold: any suspicion triggers alert

Transitions are automatic and logged.

---

## --auto Integration

When `--auto` is active, grounding gates are automatically managed:

1. Auto mode runs Quick Check every N iterations
2. Quick Check results determine which gates to activate/deactivate
3. Gate failures feed back into the next Quick Check (higher confidence signals)
4. Closed loop: detect → ground → verify → detect

---

## State File Extension

`watchdog.local.json` gains a `grounding` section:

```json
{
  "grounding": {
    "enabled": true,
    "mode": "auto",
    "leash": "tight",
    "gates": {
      "exist": {"active": true, "auto_reason": "hallucination >= 25", "checks": 12, "failures": 1},
      "relevance": {"active": false, "auto_reason": null, "checks": 0, "failures": 0},
      "root_cause": {"active": true, "auto_reason": "stuck >= 35", "checks": 8, "failures": 3},
      "recall": {"active": false, "auto_reason": null, "checks": 0, "failures": 0},
      "momentum": {"active": false, "auto_reason": null, "checks": 0, "failures": 0}
    },
    "frequency_budget": {"max_per_5_calls": 1, "current_window": 0},
    "gate_log": []
  }
}
```

Gate log capped at 50 entries. Old entries trimmed automatically.

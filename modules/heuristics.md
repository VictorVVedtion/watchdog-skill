# Watchdog Detection Heuristics

Defines signals, weights, and detection methods for all 5 dimensions.
Supports two scoring paths: Quick Score (default, local self-assessment) and Full Score (Deep Mode, for external AI reference).

---

## Quick Score Path (Quick Mode)

Claude's rapid self-assessment based on current context. No complex computation — 3 core judgments per dimension:

| Dimension | Quick Judgment Criteria |
|-----------|----------------------|
| STUCK | Same file edited >3 times? error→fix→error loop? Similar commit messages? |
| DRIFT | Last 3 actions related to original task? Modified files within planned scope? |
| HALLUCINATION | Do recently referenced files/APIs actually exist? |
| CONTEXT_DECAY | Approximate context usage? Re-reading same files? |
| VELOCITY_DROP | Recent commit change volume declining? More reads than writes? |

**Scoring**: Claude directly rates each dimension 0-100 based on signal intuition.
**Label**: Reports marked `[self-assessment]`.
**Bias note**: Self-assessment has inherent bias (especially HALLUCINATION and DRIFT), mitigated through structured rules. `/btw` uses the same pattern — leveraging existing context rather than external verification.

---

## Full Score Path (Deep Mode Reference)

Complete signal definitions below, for external AI evaluation reference in Deep Mode.

---

## 1. STUCK Detection (Weight 25%)

Detects whether the process is trapped in ineffective loops or stalled.

### Signal Sources

| Signal | Sub-weight | Detection Method | Threshold |
|--------|-----------|-----------------|-----------|
| Repeated file edits | 35% | Count same file appearances in git diff | Same file >3 edits → trigger |
| Repeated tool calls | 25% | Check last 10 tool calls for repeat patterns | Same call >3 times → trigger |
| Similar commit messages | 15% | Compare keyword overlap in last 5 git log messages (after removing stop words) | Overlap >60% → trigger |
| Error loops | 25% | Detect error→fix→same_error pattern | Same error >2 times → trigger |

### Scoring Formula

```
stuck_score = Σ(signal_weight × signal_value)
```

Each signal_value ranges 0-100:
- 0: No signal
- 25: Weak signal (just triggered threshold)
- 50: Medium signal (exceeded threshold 1.5x)
- 75: Strong signal (exceeded threshold 2x)
- 100: Very strong signal (exceeded threshold 3x+)

### Common Stuck Patterns

1. **Edit-revert loop**: Edit file A → find problem → revert → edit A again
2. **Dependency deadlock**: Fixing A requires B, fixing B requires A
3. **Build-fail loop**: Modify code → build fails → modify same spot → build fails
4. **Test flip-flop**: Fix test A → test B fails → fix B → test A fails again

---

## 2. DRIFT Detection (Weight 25%)

Detects whether current work has deviated from the original task goal.

### Signal Sources

| Signal | Sub-weight | Detection Method | Threshold |
|--------|-----------|-----------------|-----------|
| File scope deviation | 30% | Are modified files within original task's expected scope? | >50% files outside plan → trigger |
| Task description deviation | 35% | Claude self-rates relevance of last 3 actions to original task (high/medium/low/unrelated) | Rated "low" or "unrelated" → trigger |
| Unplanned new work | 20% | Started work not mentioned in original task? | 2+ unplanned subtasks → trigger |
| Time allocation imbalance | 15% | Iteration ratio spent on non-core tasks | >40% iterations on non-core → trigger |

### Drift Patterns

1. **Rabbit hole**: Debug small issue → discover deeper issue → forget original task
2. **Scope creep**: "While I'm at it" fixes for unrelated issues
3. **Refactoring trap**: Starting large-scale refactoring for current task
4. **Perfectionism drift**: Over-optimizing non-critical details

---

## 3. HALLUCINATION Detection (Weight 20%)

Detects whether AI references non-existent resources or makes false assumptions.

### Signal Sources

| Signal | Sub-weight | Detection Method | Threshold |
|--------|-----------|-----------------|-----------|
| Phantom file references | 35% | Check if referenced file paths actually exist | Any non-existent file reference → trigger |
| Phantom API/functions | 30% | Called non-existent functions or APIs | Any non-existent API call → trigger |
| False assumptions | 20% | Reasoning based on incorrect premises | Contradictory assumption detected → trigger |
| Outdated information | 15% | Using outdated API/library version info | Version info doesn't match reality → trigger |

### Hallucination Patterns

1. **File hallucination**: References `src/utils/helper.ts` but file doesn't exist
2. **API hallucination**: Calls `response.getHeaders()` but method doesn't exist
3. **Config hallucination**: Assumes existence of an env variable or config entry
4. **History hallucination**: "We already fixed this" but actually didn't

---

## 4. CONTEXT_DECAY Detection (Weight 15%)

Detects whether the session has lost important information due to context window limits.

### Signal Sources

| Signal | Sub-weight | Detection Method | Threshold |
|--------|-----------|-----------------|-----------|
| Context usage rate | 40% | statusline context_window.used_percentage | >80% → trigger |
| Repeated file reads | 25% | Same file read multiple times (indicates compressed/lost info) | Same file read >2 times → trigger |
| Forgotten constraints | 20% | Violated previously confirmed constraints | Any violation → trigger |
| Plan deviation | 15% | Current actions inconsistent with previously made plan | Deviated from confirmed plan steps → trigger |

### Decay Stages

| Stage | Context Usage | Typical Behavior |
|-------|--------------|-----------------|
| Normal | 0-50% | Full memory, efficient execution |
| Early decay | 50-70% | Occasional detail loss, core task memory intact |
| Mid decay | 70-85% | Early conversation content starting to drop |
| Severe decay | 85-95% | Significant context loss |
| Collapse edge | 95%+ | Approaching context limit |

---

## 5. VELOCITY_DROP Detection (Weight 15%)

Detects gradual efficiency decline — an early degradation signal between STUCK (fully stalled) and normal.

### Signal Sources

| Signal | Sub-weight | Detection Method | Threshold |
|--------|-----------|-----------------|-----------|
| Declining change volume | 40% | Compare lines changed in last 3 commits | Consecutive decline >30% → trigger |
| Effective tool ratio | 30% | Ratio of write/edit vs repeated read operations | Effective ratio <0.4 → trigger |
| Iteration time inflation | 30% | Compare adjacent iteration times (git timestamps or Ralph) | Increase >2x → trigger |

### Scoring Formula

```
velocity_drop_score = change_decline × 0.40 + tool_ratio × 0.30 + time_inflation × 0.30
```

Each signal_value ranges 0-100:
- 0: No signal
- 30: Slight decline (just triggered threshold)
- 60: Notable decline (exceeded threshold 1.5x)
- 90: Severe decline (exceeded threshold 2x+)

### Velocity Drop Patterns

1. **Exploration trap**: Reading many files but producing few changes
2. **Approach hesitation**: Repeatedly modifying then reverting, net changes approaching zero
3. **Complexity ramp**: Each modification requires increasingly more thinking time

---

## Overall Score Calculation

```
overall_score = stuck × 0.25 + drift × 0.25 + hallucination × 0.20 + context_decay × 0.15 + velocity_drop × 0.15
```

> **Backward compatibility**: If evaluation returns only 4 dimensions (no velocity_drop), use legacy weights 30/30/25/15.

### Severity Mapping

| Overall Score | Severity | Suggested Action |
|--------------|----------|-----------------|
| 0-20 | HEALTHY | Continue |
| 21-50 | WARNING | Monitor |
| 51-80 | CRITICAL | Pause |
| 81-100 | EMERGENCY | Stop |

---

## Local Evaluation Mode

Used by both Quick Mode self-assessment and Deep Mode fallback.
Quick Mode labeled `[self-assessment]`, fallback labeled `[fallback - local heuristic evaluation]`.

### Per-Dimension Scoring Rules

**STUCK**:
| Signal | Trigger Score |
|--------|--------------|
| Same file edited >3 times | +30 |
| Repeated tool calls >3 times | +25 |
| Commit message keyword overlap >60% | +20 |
| error→fix→error loop >2 times | +25 |

**DRIFT**:
| Signal | Trigger Score |
|--------|--------------|
| >50% files outside plan | +35 |
| Claude self-rates relevance "low" or "unrelated" | +30 |
| 2+ unplanned subtasks | +20 |
| >40% iterations on non-core tasks | +15 |

**HALLUCINATION**:
| Signal | Trigger Score |
|--------|--------------|
| Reference to non-existent file | +40 |
| Call to non-existent API/function | +35 |
| Reasoning on contradictory assumptions | +15 |
| Using outdated version info | +10 |

**CONTEXT_DECAY**:
| Signal | Trigger Score |
|--------|--------------|
| Context usage >80% | +40 |
| Same file read >2 times | +25 |
| Violated confirmed constraint | +20 |
| Deviated from confirmed plan | +15 |

**VELOCITY_DROP**:
| Signal | Trigger Score |
|--------|--------------|
| Lines changed declining >30% consecutively | +40 |
| Effective tool ratio <0.4 | +30 |
| Iteration time increase >2x | +30 |

### Calculation

1. Each dimension: sum triggered signal scores, cap at 100
2. Final weighted: `overall = stuck×0.25 + drift×0.25 + hallucination×0.20 + context_decay×0.15 + velocity_drop×0.15`
3. Output label: `[fallback - local heuristic evaluation]`

---

## Computation Accuracy Limits

Accuracy limits for local heuristic mode:

| Metric | Accuracy | Notes |
|--------|----------|-------|
| Commit message similarity | Medium | Uses keyword overlap instead of semantic similarity, removes common stop words (fix, update, add, change, the, a, in, of, to) |
| Task relevance | Self-dependent | Claude's self-assessment has inherent bias, reliability ≤70% in fallback mode |
| Context usage | Low-Medium | Only rough estimate without statusline data |
| Iteration time | Low | Without Ralph, only git timestamps available, limited precision |
| Hallucination detection | Low | Claude has blind spots detecting own hallucinations, fallback only checks file/API existence |

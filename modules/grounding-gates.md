# Grounding Gates — Proactive Verification Checkpoints

## Design Principle

Grounding gates are self-imposed verification habits that run silently in Claude's reasoning.
Only visible output appears when verification FAILS.
The dog doesn't bark when the path is clear — it only tugs the leash when you're about to step off.

**Frequency budget**: Maximum 1 gate alert per 5 tool calls. If multiple gates would fire, show only the highest-priority one: EXIST > ROOT_CAUSE > RELEVANCE > RECALL > MOMENTUM.

---

## Gate 1: EXIST (Pre-Edit Verification) 👃

### When to Trigger
- About to edit a file that hasn't been read in this session
- About to import from a module path based on assumption
- About to call an API/function based on memory rather than verified source

### Verification Steps
1. Has this file been read (Read tool) in the current session?
2. If not, does a quick check confirm it exists?
3. For APIs: has the actual source/docs been checked?

### Pass → Silent
Proceed with the edit. No output.

### Fail → Inline Alert
```
(ŏ_ŏ )🦴👃 src/utils/helper.ts — can't sniff this file. does it exist?
```

### Escalation
EXIST fails >2 times → +20 to hallucination score on next watchdog check.

---

## Gate 2: RELEVANCE (Pre-Subtask Verification) 🔗

### When to Trigger
- About to start working on something not in the original task/plan
- About to modify a file outside the planned scope
- About to fix a "while I'm at it" issue

### Verification Steps
1. State the original task in one sentence
2. State what you're about to do in one sentence
3. Can you draw a direct line between them?

### Pass → Silent
Direct connection exists. Proceed.

### Fail → Inline Alert
```
(ŏ_ŏ )🦴🔗 refactoring auth module — is this on the original trail? [proceed / return]
```

### Escalation
If user confirms "proceed" on a flagged tangent, log it. Don't re-flag the same tangent.

---

## Gate 3: ROOT_CAUSE (Post-Fix Verification) 🦷

### When to Trigger
- Just applied a fix for an error
- About to move on after a fix
- Same error category appeared before in this session

### Verification Steps
1. State the error symptom in one sentence
2. State the root cause you identified in one sentence
3. Does the fix address the root cause, not just the symptom?
4. Is there a way to verify the fix works? (test, build, run)

### Pass → Silent
Root cause addressed and verifiable. Proceed.

### Fail → Inline Alert
```
(ŏ_ŏ )🦴🦷 TypeError fix — same bone as last time? dig for the root.
```

### Escalation
Same error recurs after fix → auto-escalate to STUCK detection.

---

## Gate 4: RECALL (Context Threshold Verification) 🧠

### When to Trigger
- Estimated context usage crosses 50%, 70%, 85%
- About to make a decision depending on constraints stated earlier
- Haven't referenced the plan/spec file in >10 tool calls

### Verification Steps
1. Can you state the original task without re-reading it?
2. Can you list the key constraints?
3. Are there any constraints you're unsure about?

### Pass → Silent
All critical constraints recalled accurately. Proceed.

### Fail → Inline Alert
```
(ŏ_ŏ )🦴🧠 context ~72% — can you recall the 3 key constraints? re-reading...
```

### Auto-Action
- At 85%: auto-suggest creating a checkpoint file
- At 50%/70%: silently re-verify constraints

---

## Gate 5: MOMENTUM (Velocity Verification) 🐾

### When to Trigger
- Last 3 actions produced no net code changes
- Same file read >2 times without writing
- Approach attempted and failed, about to retry same approach

### Verification Steps
1. What concrete output did the last 3 actions produce?
2. Is the current approach making measurable progress?
3. Are there alternative approaches not yet tried?

### Pass → Silent
Progress is measurable. Proceed.

### Fail → Inline Alert
```
(ŏ_ŏ )🦴🐾 3 reads, 0 writes — lost the scent? try a different trail.
```

### Escalation
MOMENTUM fails >2 times → auto-trigger /watchdog Quick Check.

---

## Gate Alert Format Summary

All gate alerts use the sniffing kaomoji `(ŏ_ŏ )🦴` + gate icon:

```
(ŏ_ŏ )🦴👃 <target> — <message>          EXIST
(ŏ_ŏ )🦴🔗 <action> — <question>         RELEVANCE
(ŏ_ŏ )🦴🦷 <fix> — <question>            ROOT_CAUSE
(ŏ_ŏ )🦴🧠 context ~<N>% — <message>     RECALL
(ŏ_ŏ )🦴🐾 <pattern> — <suggestion>      MOMENTUM
```

Visually distinct from watchdog check output (which uses mood kaomoji + car/track).

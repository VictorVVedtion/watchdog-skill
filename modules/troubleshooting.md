# Troubleshooting Guide

Common issues and solutions for Watchdog.

---

## 1. Quick Mode — Self-Assessment Accuracy

**Q: Is Quick Mode self-assessment accurate?**
Self-assessment has inherent bias (especially for HALLUCINATION), mitigated through structured rules and grounding gates. When grounding is active, gate failures provide empirically verified signals that are more reliable than self-assessment.

**Q: When is Quick Mode not enough?**
- 2 consecutive WARNINGs → Watchdog auto-suggests `--deep`
- Suspect self-assessment is missing something → `/watchdog --deep`
- Need detailed diagnosis → `/watchdog --report`

---

## 2. Deep Mode — Evaluator Not Available

`gemini` or `codex` not found → Quick Mode still works perfectly. Deep Mode falls back to self-assessment.

```bash
command -v gemini && command -v codex  # check availability
/watchdog --deep --evaluator codex     # try the other one
```

---

## 3. jq Not Available

Only affects `watchdog.local.json` auto-update. Claude can handle JSON directly as fallback.

```bash
brew install jq     # macOS
apt install jq      # Ubuntu
```

---

## 4. JSON Parsing Failure (Deep Mode)

5-layer extraction strategy handles most edge cases. Full failure → falls back to Quick Mode self-assessment.

---

## 5. State File Corruption

```bash
/watchdog --reset                    # clean slate
# or manually:
rm .claude/watchdog.local.json       # delete and let watchdog recreate
```

---

## 6. Git Signals Not Available

Not in a git repo or no commits → STUCK and DRIFT signals partially missing. Watchdog auto-skips unavailable signal sources.

---

## 7. Ralph Not Available

Ralph is optional. All features work without it. Auto mode uses passive triggering instead of Ralph's Stop Hook.

---

## 8. Grounding Gates Too Aggressive

**Symptom**: Gate alerts appearing too frequently, slowing down work

**Solutions**:
- Reduce active gates: `/watchdog --ground on --gates exist,relevance`
- Frequency budget already caps at 1 alert per 5 tool calls
- Switch to auto-grounding: `/watchdog --auto --ground on` (system manages activation)
- Disable grounding: `/watchdog --ground off`

---

## 9. Grounding Gates Too Passive

**Symptom**: Gates not catching issues that later cause problems

**Solutions**:
- Verify grounding is active: `/watchdog --ground status`
- Check if in "loose leash" mode (only when HEALTHY)
- Manually activate all gates: `/watchdog --ground on --gates all`
- Run a manual check to trigger auto-activation: `/watchdog`

---

## 10. Gate Failures Not Affecting Scores

Gate data only feeds into scores when grounding is enabled at check time. Verify with `/watchdog --ground status`.

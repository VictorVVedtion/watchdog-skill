# Troubleshooting Guide

Common issues and solutions when running Watchdog.

---

## 1. Quick Mode

### Q: Is Quick Mode self-assessment accurate?

Quick Mode uses Claude's own evaluation, which has inherent bias (especially HALLUCINATION detection), but:
- Structured heuristic rules mitigate bias
- `/btw` uses the same pattern — leveraging existing context rather than external verification
- Persistent anomalies auto-suggest `--deep` for independent external verification

### Q: When is Quick Mode not enough?

- 2 consecutive WARNINGs → Watchdog auto-suggests `--deep`
- Suspect self-assessment is missing issues → manually run `/watchdog --deep`
- Need detailed diagnostic report → `/watchdog --report`

---

## 2. Deep Mode - Evaluator Unavailable

### Symptom: `gemini: command not found` or `codex: command not found`

**Impact**: Deep Mode cannot use external AI, but Quick Mode is completely unaffected.

**Solution**:
```bash
# Check availability
command -v gemini && command -v codex

# Use the other evaluator
/watchdog --deep --evaluator codex

# Neither installed? No problem — Quick Mode always works
/watchdog  # works normally
```

---

## 3. jq Unavailable

### Symptom: `jq: command not found`

**Impact**: Only affects automatic `watchdog.local.json` updates, core checks unaffected.

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

Claude can handle JSON directly as a fallback.

---

## 4. Deep Mode - JSON Parse Failure

**Handling**: Watchdog automatically tries 5-layer extraction strategy (see `json-schema.md`).
If all fail, automatically falls back to Quick Mode self-assessment results.

---

## 5. Deep Mode - Evaluation Timeout

- Auto-set 30-second timeout
- Timeout → sleep 2 retry → switch to backup evaluator → fall back to self-assessment
- Quick Mode always available as safety net

---

## 6. Corrupted State File

```bash
# Reset
/watchdog --reset

# Or manually rebuild
echo '{"mode":"manual","enabled":false,"interval":5,"last_check":null,"check_count":0,"history":[],"trend":"UNKNOWN","consecutive_warnings":0}' > .claude/watchdog.local.json
```

---

## 7. Git Signals Unavailable

Not in a git repo or no commit history — some STUCK and DRIFT signals will be missing.
Watchdog automatically skips unavailable signal sources and evaluates with remaining signals.

---

## 8. Ralph Unavailable

Ralph is an optional enhancement, not a required dependency.
- Quick Mode and Deep Mode both work without Ralph
- Auto mode without Ralph uses Claude's passive trigger (every N interactions)

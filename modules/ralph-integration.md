# Ralph Integration (Optional Signal Enhancement)

Ralph is an optional signal enhancer for Watchdog, not a required dependency.
Watchdog works fully without Ralph (both Quick Mode and Deep Mode function normally).

---

## 1. With Ralph

### Auto Mode Trigger

Ralph checks `watchdog.local.json` at each iteration end:
- `enabled === true` and `check_count % interval === 0` → trigger Quick Check
- Otherwise skip

### Additional Signals

Enhanced signals provided by Ralph (available to both Quick and Deep Mode):
- `current_iteration / max_iteration` → more accurate context usage estimation
- `completion_promise` → original task description (used for DRIFT detection)
- `ralph-delta.local.md` → per-iteration change records

### State File Format

**ralph-loop.local.md**:
```markdown
- **Current Iteration**: 3
- **Max Iterations**: 10
- **Phase**: execute
- **Completion Promise**: Implement user authentication module
```

**ralph-delta.local.md**:
```markdown
## Changes This Iteration
- Modified src/auth/login.ts
## Issues Encountered
- TypeScript compilation error resolved
```

---

## 2. Without Ralph

### Auto Mode

Without Ralph's Stop Hook, uses Claude's passive trigger instead:
- Claude runs Quick Check in its own thinking flow every N interactions
- Equivalent effect to Ralph-driven checks, just different trigger mechanism

### Signal Degradation

| Signal | With Ralph | Without Ralph |
|--------|-----------|--------------|
| Iteration progress | `current/max` | Conversation round estimate |
| Original task | `completion_promise` | Plan file / first conversation message |
| Context estimate | `iter/max × 80` | `min(rounds × 3, 95)%` |
| Per-iteration changes | `ralph-delta` | git diff |

---

## 3. Ralph + Grounding Integration (v3.0)

### Phase-Aware Gate Activation

Ralph's `phase` field enables smarter gate activation:

| Ralph Phase | Recommended Gates | Reason |
|-------------|------------------|--------|
| plan | RELEVANCE | Catch scope creep during planning |
| execute | EXIST, ROOT_CAUSE | Catch hallucination and stuck loops during coding |
| validate | ROOT_CAUSE | Verify fixes actually work |
| cleanup | RELEVANCE | Prevent over-engineering during cleanup |

### Iteration-Boundary Grounding

At each Ralph iteration boundary (Stop Hook), perform a mandatory RELEVANCE gate check:
- State: "Original task is X. This iteration accomplished Y. Next iteration plans Z."
- If Z does not connect to X, flag before the iteration begins.

### Without Ralph

Without Ralph, grounding gates trigger based on tool-call patterns only (no phase awareness). All gates function normally.

---

## 4. Integration Principles

- Watchdog **only reads** Ralph state files, never writes
- Two skills are loosely coupled via filesystem, neither depends on the other being installed
- Ralph is a signal enhancer, not a required component

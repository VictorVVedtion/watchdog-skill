# Self-Healing Suggestions - Symptom-Prescription Map

Defines specific remediation advice (prescriptions) for different health issues.
- **Quick Mode**: Uses single-line prescriptions (action part of btw overlay)
- **Deep Mode**: Uses full prescriptions (remediation block in report)

---

## 0. Quick Prescription Lookup (Quick Mode)

Quick Mode btw overlay compresses prescriptions into a single sentence:

| Dimension | Primary Signal | Single-line Prescription |
|-----------|---------------|------------------------|
| STUCK | Repeated edits | `git stash`, re-analyze root cause |
| STUCK | Error loop | Stop and fully read the error stack |
| STUCK | Build failure | Roll back to last successful commit |
| DRIFT | File deviation | Review original task, revert unplanned files |
| DRIFT | Rabbit hole | Log current issue as TODO, return to main task |
| DRIFT | Scope creep | Move extra fixes to separate branch |
| HALLUCINATION | Phantom files | Use glob to find actual file location |
| HALLUCINATION | Phantom APIs | Check actual API docs to confirm |
| CONTEXT_DECAY | High usage | Create checkpoint, consider new session |
| CONTEXT_DECAY | Repeated reads | Extract key info to a notes file |
| VELOCITY_DROP | Declining changes | Pause coding, redesign with pseudocode |
| VELOCITY_DROP | Low tool ratio | Organize info before starting to code |
| Combined | Multi-dimension | Suggest `/watchdog --deep` |

---

## 1. STUCK Prescriptions

### 1.1 Repeated File Edits (stuck + repeated_file_edits)

**Symptom**: Same file edited >3 times, modifying similar regions each time

**Prescription**:
1. `git stash` to save current changes
2. Find last working commit: `git log --oneline -5`
3. Re-analyze root cause before editing again
4. Consider splitting large file into smaller modules

### 1.2 Error Loop (stuck + error_loop)

**Symptom**: error → fix → same_error pattern repeating >2 times

**Prescription**:
1. Stop modifying code, fully read the error message and stack trace
2. Search project for similar resolved cases
3. Isolate the issue with a minimal reproducible example
4. If type error, check for version incompatibility

### 1.3 Build Failure Loop (stuck + build_fail)

**Symptom**: Build repeatedly failing, each modification not addressing root cause

**Prescription**:
1. Roll back to last successful build commit
2. Gradually re-apply changes, verifying build at each step
3. Check for environment or dependency changes

---

## 2. DRIFT Prescriptions

### 2.1 File Scope Deviation (drift + file_scope)

**Symptom**: >50% of modified files not in original task plan

**Prescription**:
1. Review original task description
2. List all modified files, mark which are necessary
3. `git stash` or revert unplanned file changes
4. Refocus on original task's core files

### 2.2 Rabbit Hole (drift + rabbit_hole)

**Symptom**: Debugging a small issue leads deeper and deeper, forgetting original task

**Prescription**:
1. Immediately log current deep issue (create TODO/Issue)
2. Return to original task
3. Mark deep issue as follow-up work

### 2.3 Scope Creep (drift + scope_creep)

**Symptom**: "While I'm at it" fixes for multiple unrelated issues

**Prescription**:
1. Separate extra fixes into independent commits or branches
2. Return to minimal implementation scope of original task
3. Record extra work as follow-up tasks

---

## 3. HALLUCINATION Prescriptions

### 3.1 File Hallucination (hallucination + phantom_files)

**Symptom**: Referencing or importing non-existent file paths

**Prescription**:
1. Use `find` / `glob` to search for actual file location
2. Check if file was renamed or moved
3. If truly doesn't exist, create needed file or fix the import

### 3.2 API Hallucination (hallucination + phantom_api)

**Symptom**: Calling non-existent functions, methods, or APIs

**Prescription**:
1. Check actual API documentation or source code definitions
2. Use `grep` to search project for actual method signatures
3. Verify library version matches assumed API

### 3.3 Config Hallucination (hallucination + phantom_config)

**Symptom**: Assuming existence of an environment variable or config entry

**Prescription**:
1. Check `.env` / `.env.example` for actual configuration
2. Check config file schema or type definitions
3. Add missing config entry or modify code logic

---

## 4. CONTEXT_DECAY Prescriptions

### 4.1 High Context Usage (context_decay + high_usage > 85%)

**Symptom**: Context window usage exceeds 85%

**Prescription**:
1. Immediately create checkpoint in `.claude/checkpoint.md`
2. Record current progress, remaining tasks, key decisions
3. Consider starting a new session
4. Start new session by reading the checkpoint first

### 4.2 Repeated File Reads (context_decay + repeated_reads)

**Symptom**: Same file read multiple times, indicating earlier reads were compressed away

**Prescription**:
1. Extract key information to a temporary notes file
2. Reduce number of files read per operation
3. Read most relevant file sections using offset/limit

### 4.3 Forgotten Constraints (context_decay + forgotten_constraints)

**Symptom**: Violating constraints previously confirmed in conversation

**Prescription**:
1. Consolidate all constraints into plan file or CLAUDE.md
2. Re-read constraint list before each major operation
3. Use task system to track constraint compliance

---

## 5. VELOCITY_DROP Prescriptions

### 5.1 Declining Change Volume (velocity_drop + declining_changes)

**Symptom**: Consecutive commits with declining lines changed >30%

**Prescription**:
1. Pause coding, redesign approach with pseudocode
2. Evaluate whether current approach is overly complex
3. Consider simpler alternative implementations

### 5.2 Low Effective Tool Ratio (velocity_drop + low_tool_ratio)

**Symptom**: write/edit operations below 40%, lots of repeated reads

**Prescription**:
1. Organize collected information, make a clear action plan
2. Reduce exploratory reads, focus on target files
3. Build complete approach mentally before coding

### 5.3 Iteration Time Inflation (velocity_drop + time_inflation)

**Symptom**: Adjacent iteration times increasing >2x

**Prescription**:
1. Check for blocking operations (waiting for builds, tests)
2. Simplify current step, break into smaller tasks
3. Consider whether you've entered a complexity trap

---

## 6. Compound Symptom Prescriptions

### 6.1 STUCK + DRIFT

**Symptom**: Both stuck and deviated from original task

**Prescription**: Highest priority — stop current work immediately
1. Create current state snapshot
2. Return to original task description
3. Plan solution from scratch

### 6.2 HALLUCINATION + CONTEXT_DECAY

**Symptom**: Context loss causing hallucinations

**Prescription**:
1. Stop code modifications
2. Re-read project key files (entry points, configs, type definitions)
3. Rebuild accurate understanding of current codebase

### 6.3 All Dimensions Degrading (overall_score > 70)

**Symptom**: Multiple dimensions degrading simultaneously

**Prescription**: Recommend terminating session
1. Save all uncommitted work: `git stash`
2. Write detailed handoff document
3. Start fresh session from handoff document

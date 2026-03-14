# Watchdog Overlay Output Format

The watchdog sits trackside, watching the car (session) race.
The dog's mood — from napping to biting — tells you everything at a glance.

---

## Core Rules

1. **Dog is the main character** — the car is just what it's watching
2. **Kaomoji faces convey mood** — no words needed to feel the vibe
3. **Onomatopoeia matters** — zzZ, woof?, WOOF!, AWOOO!!
4. **Minimal interruption** — 1 line beats 3 lines, always
5. **Sound cues** — macOS sound effects scale with bark volume

---

## Watchdog Mood System (Reactive Checks)

| Mood | Face | Voice | Meaning |
|------|------|-------|---------|
| Napping | `(ᵕ᷄ ᐛ ᵕ᷅)` | `zzZ...` | All clear, sleeping on the job (in a good way) |
| Alert | `(ŏ_ŏ  )` | `woof?` | Ears perked, something smells off |
| Barking | `(ง •̀_•́)ง` | `WOOF! WOOF!` | On feet, hackles raised, loud warning |
| Biting | `(╬ Ò ‸ Ó)` | `AWOOO—!!` | Jaws locked on the steering wheel |

### HEALTHY (0-20) — `(ᵕ᷄ ᐛ ᵕ᷅)  zzZ...  08 ──🚗── clear track, napping`
### WARNING (21-50) — `(ŏ_ŏ  )  woof?  35 ─🚗〰─ tires slipping → steer back`
### CRITICAL (51-80) — 3 lines with top 2 dimensions
### EMERGENCY (81-100) — 3 lines + AskUserQuestion

Sound: Tink (WARNING) / Sosumi (CRITICAL) / Funk (EMERGENCY)

---

## Grounding Gate Alerts (Proactive Checks)

Gate alerts are visually distinct from reactive checks. They use the **sniffing pose** `(ŏ_ŏ )🦴` + gate icon.

### Format
```
(ŏ_ŏ )🦴<icon> <target> — <message>
```

### Gate Icons

| Gate | Icon | Dog Action |
|------|------|-----------|
| EXIST | 👃 | sniffing for the file |
| RELEVANCE | 🔗 | checking the leash |
| ROOT_CAUSE | 🦷 | biting the right bone? |
| RECALL | 🧠 | remembering buried bones |
| MOMENTUM | 🐾 | tracking the scent |

### Examples
```
(ŏ_ŏ )🦴👃 src/utils/helper.ts — can't sniff this file. does it exist?
(ŏ_ŏ )🦴🔗 refactoring auth module — is this on the original trail?
(ŏ_ŏ )🦴🦷 TypeError fix — same bone as last time? dig for the root.
(ŏ_ŏ )🦴🧠 context ~72% — can you recall the 3 key constraints?
(ŏ_ŏ )🦴🐾 3 reads, 0 writes — lost the scent? try a different trail.
```

### Frequency Budget
Max 1 gate alert per 5 tool calls. Priority if multiple fire:
EXIST > ROOT_CAUSE > RELEVANCE > RECALL > MOMENTUM

### Silent Logging
All gate checks (pass and fail) logged to watchdog.local.json even when suppressed.

---

## Voice & Tone Guide

| Do | Don't |
|----|-------|
| "can't sniff this file" | "file not found in filesystem" |
| "same bone as last time?" | "repeated error pattern detected" |
| "is this on the original trail?" | "task drift indicator triggered" |
| "lost the scent" | "velocity below threshold" |
| "dig for the root" | "investigate root cause" |

---

## Quick Prescriptions (Single-Line)

| Dimension | Prescription |
|-----------|-------------|
| STUCK | drop the bone, `git stash`, rethink |
| DRIFT | check the route, return to main trail |
| HALLUCINATION | sniff before digging — verify it exists |
| CONTEXT_DECAY | bury a bone (checkpoint), consider new session |
| VELOCITY_DROP | lost the scent, try a different trail |

---

## Escalation Rules

| Condition | Append to output |
|-----------|-----------------|
| `consecutive_warnings >= 2` | `\| keeps drifting, suggest --deep` |
| Quick Score >= 51 | In 3-line format already |
| DEGRADING trend + score > 35 | `\| getting worse, suggest --deep` |
| Grounding active + gate stats | `\| 🦴 2/15 gates flagged` |

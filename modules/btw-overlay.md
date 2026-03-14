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

## Watchdog Mood System

| Mood | Face | Voice | Meaning |
|------|------|-------|---------|
| Napping | `(ᵕ᷄ ᐛ ᵕ᷅)` | `zzZ...` | All clear, sleeping on the job (in a good way) |
| Alert | `(ŏ_ŏ  )` | `woof?` | Ears perked, something smells off |
| Barking | `(ง •̀_•́)ง` | `WOOF! WOOF!` | On feet, hackles raised, loud warning |
| Biting | `(╬ Ò ‸ Ó)` | `AWOOO—!!` | Jaws locked on the steering wheel, not letting go |

---

## Output Templates

### HEALTHY (0-20) — Napping

Manual invocation:
```
(ᵕ᷄ ᐛ ᵕ᷅)  zzZ...  08 ──🚗── clear track, napping
```

Auto mode: completely silent, log only.

### WARNING (21-50) — Ears Up

Format:
```
(ŏ_ŏ  )  woof?  <score> ─🚗〰─ <what's off> → <action>
```

Examples:
```
(ŏ_ŏ  )  woof?  35 ─🚗〰─ tires slipping → steer back
(ŏ_ŏ  )  woof?  28 ─🚗〰─ wrong lane → check the route
(ŏ_ŏ  )  woof?  42 ─🚗〰─ losing speed → simplify approach
```

Sound: `afplay /System/Library/Sounds/Tink.aiff 2>/dev/null &`

### CRITICAL (51-80) — Barking

Format:
```
(ง •̀_•́)ง  WOOF! WOOF!  <score> 〰🚗〰〰
<what went wrong — colorful, dog-perspective language>
→ <action>
```

Examples:
```
(ง •̀_•́)ง  WOOF! WOOF!  62 〰🚗〰〰
off the main track! smells like burning hallucinations
→ pit stop: run --deep to check the route map
```

```
(ง •̀_•́)ง  WOOF! WOOF!  55 〰🚗〰〰
going in circles! same file getting chewed 5 times
→ drop the bone! git stash, rethink approach
```

Sound: `afplay /System/Library/Sounds/Sosumi.aiff 2>/dev/null &`

### EMERGENCY (81-100) — Biting

Format:
```
(╬ Ò ‸ Ó)  AWOOO—!!  <score> 💥🚗〰〰
<dramatic description — the dog is NOT letting go>
→ kill the engine NOW! [stop / force continue]
```

Example:
```
(╬ Ò ‸ Ó)  AWOOO—!!  85 💥🚗〰〰
deadlock wall crash! leash snapped!!
→ kill the engine NOW! [stop / force continue]
```

Sound: `afplay /System/Library/Sounds/Funk.aiff 2>/dev/null &`

Then AskUserQuestion: `Kill the engine? [stop / force continue / full inspection]`

---

## Sound Effects (macOS)

| Severity | Sound | File | Dog Equivalent |
|----------|-------|------|----------------|
| HEALTHY | None | — | Snoring |
| WARNING | Tink | `/System/Library/Sounds/Tink.aiff` | Soft whine |
| CRITICAL | Sosumi | `/System/Library/Sounds/Sosumi.aiff` | Loud bark |
| EMERGENCY | Funk | `/System/Library/Sounds/Funk.aiff` | Full howl |

Non-macOS: silent fallback via `2>/dev/null &`.

---

## Voice & Tone Guide

The watchdog has personality. Use language that fits:

| Do | Don't |
|----|-------|
| "smells like burning hallucinations" | "hallucination score elevated" |
| "going in circles" | "repeated file edits detected" |
| "wrong lane" | "task drift indicator triggered" |
| "drop the bone!" | "consider stopping current approach" |
| "leash snapped" | "exceeded threshold" |
| "chewed 5 times" | "edited 5 times" |

---

## Auto-Escalation

| Condition | Append |
|-----------|--------|
| `consecutive_warnings >= 2` | `\| keeps drifting, suggest --deep` |
| Quick Score >= 51 | Already in 3-line format |
| Trend DEGRADING + score > 35 | `\| getting worse, suggest --deep` |

---

## Quick vs Deep Comparison

| Element | Quick (Watchdog overlay) | Deep (Full report) |
|---------|------------------------|-------------------|
| Character | Kaomoji dog face | Dashboard format |
| Score | Bare number `35` | Full `35/100` |
| Dimensions | Top issue only | All 5 with bars |
| Language | Dog personality | Technical |
| Sound | Yes (macOS) | No |
| Evidence | Flavor text | Per-dimension list |

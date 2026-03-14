---
name: watchdog
description: "Your session's guard dog — naps when safe, barks when you drift"
version: 2.0.0
triggers: [/watchdog, /wd, watchdog]
sandbox_mode: read-only
timeout_seconds: 60
priority: 95
---

# Watchdog — Your Session's Guard Dog

A watchdog sits trackside, watching your AI session race.
Naps when the track is clear. Ears up when something's off. Barks loud when you're drifting. Bites the steering wheel when you've lost control.

Zero cost. Zero interruption. Just a dog doing its job.

## How to Call

```bash
/watchdog                       # quick sniff — silent if healthy, barks if not
/watchdog --deep                # full vet checkup (calls external AI)
/watchdog --auto --interval 5   # guard duty — auto-patrol every N interactions
/watchdog --report              # full health report with trend history
/watchdog --status              # is the dog awake?
/watchdog --off                 # call the dog back (disable auto)
/watchdog --reset               # fresh start
```

## Dual Mode

| | Quick Mode (default) | Deep Mode (--deep) |
|--|---------------------|---------------------|
| **Who checks** | The dog itself (self-sniff) | External vet (Gemini/Codex) |
| **Cost** | $0 | ~$0.03/check |
| **Speed** | Instant (<2s) | 5-30s |
| **Output** | Kaomoji one-liner | Full dashboard report |

## What the Dog Sniffs

| Scent | Weight | What It Catches |
|-------|--------|----------------|
| STUCK | 25% | Going in circles, chewing the same bone |
| DRIFT | 25% | Wandering off the track |
| HALLUCINATION | 20% | Chasing phantom squirrels |
| CONTEXT_DECAY | 15% | Forgetting where the bones are buried |
| VELOCITY_DROP | 15% | Slowing down, losing the scent |

## The Dog's Mood

```
(ᵕ᷄ ᐛ ᵕ᷅)  zzZ...  08 ──🚗── clear track, napping

(ŏ_ŏ  )  woof?  35 ─🚗〰─ tires slipping → steer back

(ง •̀_•́)ง  WOOF! WOOF!  62 〰🚗〰〰
off the main track! smells like burning hallucinations
→ pit stop: run --deep to check the route map

(╬ Ò ‸ Ó)  AWOOO—!!  85 💥🚗〰〰
deadlock wall crash! leash snapped!!
→ kill the engine NOW! [stop / force continue]
```

## Auto Mode (Guard Duty)

With `--auto` enabled:
- **With Ralph**: Patrols on Ralph's iteration loop
- **Without Ralph**: Sniffs every N interactions on its own
- **Silent when healthy** — the best guard dog is the one you forget is there
- 2 consecutive warnings → suggests `--deep` for a full vet visit

## Design Principles

- **Guard dog, not a dashboard** — personality over numbers
- **Read-only** — never touches your code, only watches
- **Zero-cost default** — Quick Mode reuses current session
- **Progressive escalation** — nap → ears up → bark → bite
- **Tells you how to fix it** — not just what's wrong, but what to do

## Troubleshooting

See `modules/troubleshooting.md`.

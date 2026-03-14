---
name: watchdog
description: "Your session's guard dog — naps when safe, barks when you drift, bites the leash before you crash"
version: 3.0.0
triggers: [/watchdog, /wd, watchdog]
sandbox_mode: read-only
timeout_seconds: 60
priority: 95
---

# Watchdog — Your Session's Guard Dog

A watchdog sits trackside, watching your AI session race.
Naps when the track is clear. Ears up when something's off. Barks loud when you're drifting.
And in v3.0 — **bites the leash BEFORE you drift off the track.**

Zero cost. Zero interruption. Just a dog doing its job.

## How to Call

```bash
/watchdog                       # quick sniff — barks if not healthy
/watchdog --deep                # full vet checkup (external AI)
/watchdog --ground on           # activate proactive grounding
/watchdog --ground status       # grounding gate statistics
/watchdog --auto --interval 5   # guard duty — auto-patrol
/watchdog --report              # full health report with trends
/watchdog --status              # is the dog awake?
/watchdog --off                 # call the dog back
/watchdog --reset               # fresh start
```

## Triple Mode

| | Quick (default) | Grounding (--ground) | Deep (--deep) |
|--|----------------|---------------------|---------------|
| **What** | Post-hoc sniff | Pre-action leash tug | External vet exam |
| **When** | After actions | Before actions | On demand |
| **Cost** | $0 | $0 | ~$0.03 |
| **Output** | Kaomoji mood | Inline gate alert | Full report |

## What the Dog Sniffs

| Scent | Weight | What It Catches |
|-------|--------|----------------|
| STUCK | 25% | Going in circles, chewing the same bone |
| DRIFT | 25% | Wandering off the track |
| HALLUCINATION | 20% | Chasing phantom squirrels |
| CONTEXT_DECAY | 15% | Forgetting where the bones are buried |
| VELOCITY_DROP | 15% | Slowing down, losing the scent |

## Grounding Gates (v3.0) — The Leash

The dog doesn't just bark after you crash — it bites the leash BEFORE you drift.

| Gate | Icon | Trigger | Prevents |
|------|------|---------|----------|
| EXIST | 👃 | Before editing assumed files | Chasing phantom squirrels |
| RELEVANCE | 🔗 | Before starting tangents | Wandering off the track |
| ROOT_CAUSE | 🦷 | After fixing errors | Chewing the same bone |
| RECALL | 🧠 | At context thresholds | Forgetting buried bones |
| MOMENTUM | 🐾 | When progress stalls | Losing the scent |

```
(ŏ_ŏ )🦴👃 src/helper.ts — can't sniff this file. does it exist?
(ŏ_ŏ )🦴🔗 refactoring auth — is this on the original trail?
(ŏ_ŏ )🦴🦷 TypeError fix — same bone? dig for the root.
```

Gates are silent when everything checks out. You only hear the dog when it's saving you.

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

## Design Principles

- **Guard dog, not a dashboard** — personality over numbers
- **Prevent, not just detect** — grounding gates stop drift before it starts
- **Read-only** — never touches your code, only watches
- **Zero-cost default** — Quick Mode + Grounding reuse current session
- **Progressive escalation** — nap → ears up → bark → bite the leash → bite the steering wheel

## Troubleshooting

See `modules/troubleshooting.md`.

# Watchdog

A Claude Code skill that quietly watches your session health — like `/btw`, but for detecting when things go wrong.

## The Problem

Long AI coding sessions degrade silently. The AI edits the same file in circles, references APIs that don't exist, forgets what you asked 20 minutes ago. It doesn't know it's degraded. You need an outside observer.

## How It Works

```
/watchdog       → quick self-check, zero cost, 1-line output if something's off
/watchdog --deep  → sends a compressed digest to a different AI for independent evaluation
```

**Quick Mode** (default) uses Claude's own context — like `/btw`. Silent when healthy, a gentle nudge when not.

**Deep Mode** calls an external AI (Gemini or Codex) for an independent second opinion.

## What It Detects

| Dimension | What It Catches |
|-----------|----------------|
| **Stuck** | Edit-revert loops, build failures, dependency deadlocks |
| **Drift** | Rabbit holes, scope creep, refactoring traps |
| **Hallucination** | Phantom files, non-existent APIs, false assumptions |
| **Context Decay** | Memory loss, repeated reads, forgotten constraints |
| **Velocity Drop** | Declining output, exploration without progress |

## Output

Your session is a car. The watchdog sits trackside. Its mood tells you everything.

```
(ᵕ᷄ ᐛ ᵕ᷅)  zzZ     napping — all clear
(ŏ_ŏ  )  woof?    ears up — something's off
(ง •̀_•́)ง  WOOF!    barking — major trouble
(╬ Ò ‸ Ó)  AWOOO!   biting — total meltdown
```

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

Includes macOS sound effects that escalate with bark volume.

## Install

**Prerequisites:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [jq](https://jqlang.github.io/jq/), and optionally [Gemini CLI](https://github.com/google-gemini/gemini-cli) or [Codex CLI](https://github.com/openai/codex) for Deep Mode.

```bash
git clone https://github.com/VictorVVedtion/watchdog-skill.git
cd watchdog-skill
./install.sh /path/to/your/project
```

Or manually: copy `SKILL.md` + `modules/` to `.claude/skills/watchdog/`, append `CLAUDE.md` to your project's `CLAUDE.md`.

## Usage

```bash
/watchdog                       # quick check (default, zero cost)
/watchdog --deep                # external AI diagnosis
/watchdog --report              # full report with trend history
/watchdog --auto --interval 5   # auto-monitor every N interactions
/watchdog --status              # check monitoring status
/watchdog --off                 # disable auto monitoring
/watchdog --reset               # reset state files
/watchdog --evaluator codex     # use Codex instead of Gemini
```

## Design

Inspired by Claude Code's `/btw` — ambient awareness, minimal interruption, only surfaces when something's actually wrong.

- **Silent by default** — healthy sessions produce zero output
- **Read-only** — never touches your code
- **Progressive** — quick self-check → deep external diagnosis
- **Graceful degradation** — works without Gemini/Codex, works without git history

## Cost

Quick Mode: free (uses existing session context).
Deep Mode: ~$0.03/check. Gemini free tier covers most use cases.

## License

[MIT](LICENSE)

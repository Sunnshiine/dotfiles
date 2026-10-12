# pstack model configuration

Per-role model overrides for pstack skills. Each pstack SKILL.md names its defaults in a Models section; the values here override those defaults. Delete a line to fall back to the skill default. A value of `inherit-parent` or `auto` runs that role on the parent session's model (the `Agent` call omits `model`); an alias entry in a panel list still counts toward that panel's fan-out.

Budget policy: Fable is reserved for planning and design (architect runners, strongest judgment). Execution and racing roles run on Opus/Sonnet.

Review policy: no review runs on Sonnet. Opus is the floor for every role that judges work: interrogate reviewers, arena cross-judges, Shipping per-PR verdicts, deslop/no-comments second opinions, and any ad-hoc reviewer a playbook spawns (including the reviewer named in a reply's Attention section). The user does not trust Sonnet's reasoning for review. Sonnet may still write code as an arena or architect runner, but never judges it.

Repeated slugs are deliberate: the user runs Opus 5 as the only Opus, so a panel that needs a second Opus seat lists `claude-opus-5` twice. Each entry is its own independent subagent, so launch one run per entry, duplicates included.

Launching a slug: the `Agent` tool's `model` parameter accepts only aliases, so translate each slug before the call.
- `claude-opus-5` → `model: "opus"`
- `claude-fable-5-1` → `model: "fable"`
- `claude-sonnet-5` → `model: "sonnet"`

feature, refactoring: claude-opus-5
bug-fix: claude-opus-5
perf-issue: claude-opus-5
hillclimb: claude-opus-5
judgment and prose: claude-opus-5
strongest judgment: claude-fable-5-1
how explorer: claude-opus-5
how explainer: claude-opus-5
why investigators: claude-opus-5
why synthesizer: claude-opus-5
reflect tooling: claude-opus-5
reflect judgment, divergent, synthesizer: claude-opus-5
arena runners: claude-opus-5, claude-opus-5, claude-sonnet-5
arena cross-judge pool: claude-opus-5, claude-opus-5
swarm workers: claude-opus-5
architect runners: claude-opus-5, claude-fable-5-1, claude-sonnet-5
interrogate reviewers: claude-opus-5, claude-opus-5

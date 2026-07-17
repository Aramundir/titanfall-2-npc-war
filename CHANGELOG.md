# Changelog

This changelog tracks NPC War changes only. Historical fork notes are kept brief so this file stays focused on the current mod.

## Unreleased

- Separated score-based Director pressure from hot-player logic; hot players now gate leader dampening instead of adding comeback pressure to the opposing team.
- Simplified player pilot death scoring; `Player Pilot Death Score` is now always a fixed private match setting.
- Removed the experimental High-Value Target/Field Objectives implementation from the live mod for now; future design notes remain in `docs/future_mode_ideas.md`.
- Fixed boost inventory use so stacked boosts are popped asynchronously instead of calling the inventory wait path from a weapon-use callback.
- Changed infantry dropships to use a per-team cooldown instead of blocking the whole infantry spawner, allowing drop pods to continue reinforcing during dropship cooldowns.
- Added cap-relative infantry refill rules: minor losses wait for dropship-style reinforcement, larger losses can use drop pods, and severe depletion prioritizes drop pods.
- Reworded Director leader-dampening messages so they read as command conserving resources while a faction is winning.
- Changed the NPC War Director to be enabled by default.
- Removed inherited Grunt Mode 2 Attrition score-limit and time-limit overrides so standard Northstar private match `Match` settings control match length and score limits.
- Renamed the inherited script namespace to `npcwar`.
- Renamed NPC War script files, globals, playlist keys, and convars to consistent `NPCWar`/`NPCWAR`/`npcwar` naming.
- Removed old class-progression documentation that does not apply to NPC War.

## 0.1.0

- Started NPC War from the Grunt Mode 2 battlefield foundation.
- Kept the large NPC battle structure: infantry squads, Spectres, Stalkers, Prowlers, Reapers, AI Pilots, Titans, dropships, droppods, scoring AI, and score-based escalation.
- Reworked the player experience around normal pilot loadouts instead of randomized class spawns.
- Added player options for Grunt Movement, Titan Availability, Boost Availability, Tactical Ability, Ordnance, Anti-Titan Weapon, and Player Pilot Death Score.
- Added configurable score thresholds for NPC escalation.
- Added configurable Militia and IMC reinforcement budgets.
- Added optional NPC War Director pressure, dampening, hot-player dampening, special-unit pressure bonuses, and status messages.
- Improved Amped Hardpoint NPC objective selection.
- Added Capture the Flag NPC flag-running, carrier support, flag recovery, and delayed dropped-flag return behavior.
- Changed Epilogue to care about remaining NPC forces, not only remaining pilots.
- Added losing-side NPC evac behavior during Epilogue.
- Added Specialist drone loose-leash behavior so drones stay near their Specialist without forcing exact formation positions.

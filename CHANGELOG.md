# Changelog

This changelog tracks NPC War changes only. Historical fork notes are kept brief so this file stays focused on the current mod.

## 0.2.0

### Stability And Compatibility

- Rebased inherited animation, health regeneration, infantry AI, evacuation, base-gametype, Reaper, rodeo, replacement-Titan, Titan-health, cloak, and grenade scripts onto the current Northstar versions.
- Added validity checks to callable-Titan callbacks so they ignore invalid or destroyed player entities.
- Restored NPC Pilot ejection from doomed Titans through the current doomed-Titan callback path.
- Added bounded recovery for AI Pilot Titans whose assigned Pilot cannot reach them: the Titan activates autonomously and the Pilot returns to battle.
- Added an explicit abort and cleanup path for interrupted AI Pilot embark sequences, including busy, invulnerability, parenting, and animation state.
- Added cleanup for unclaimed AI Pilot Titans and their bubble shields after failed embark attempts.
- Fixed temporary boost weapons and Map Hack cleanup so stacked boost use and temporary inventory state do not remain stuck.
- Deduplicated overlapping NPC intro dropship spawnpoints so the intended two dropships per team deploy from distinct locations.

### Population, Reinforcements, And Director

- Replaced repeated full-world population scans with explicit NPC War population tracking and stale-entity cleanup.
- Separated infantry, Reaper, Prowler, MARVIN, gunship, AI Pilot, and Titan accounting so special units and summons no longer silently consume infantry slots.
- Updated AI Pilot and Titan ownership accounting across spawn, embark, eject, death, and failed-embark paths.
- Changed infantry dropships to use per-team cooldowns so one faction's dropship does not block the other faction or stop drop-pod reinforcement.
- Added cap-relative infantry refill behavior: minor losses wait for dropship reinforcement, larger deficits permit drop pods, and severe depletion prioritizes faster reinforcement.
- Enabled the NPC War Director by default and expanded its configurable pressure, score-gap, infantry-step, special-unit bonus, and status-message controls.
- Added configurable Militia and IMC health and damage multipliers for infantry, Reapers, Prowlers, MARVINs, gunships, AI Pilots, and Titans.

### NPC Presentation And Behavior

- Hid Prowlers from the minimap by default and revealed them to the detecting team while Pulse Blade or Map Hack detection is active.
- Integrated Specialist, Shield Captain, Spectre Leader, AI Pilot, and Titan spawns with the new population accounting without charging summoned support units to infantry budgets.

### Player And Match Settings

- Grouped NPC War options into dedicated private-match submenus.
- Added a choice between the Vanilla and Grunt Mode 2 boost pools.
- Restored Spectre Hacking as an enabled-by-default option in the Pilot submenu.
- Removed inherited playlist overrides that duplicated Northstar match settings, including score limit, time limit, sudden death, hardcore rules, spawn zones, escalation, skyshow, and general NPC allowance.
- Removed the inherited `earn_meter_titan_multiplier 100` override so Titan core charge uses Northstar's normal earn-meter values.
- Exposed `Player Pilot Death Score` as an arbitrary-value private-match setting.

### Balance Telemetry And Hardpoint Work

- Added lightweight, enabled-by-default balance telemetry for score, population, Director pressure, and reinforcement analysis in all supported modes, with additional territory fields in Hardpoint.
- Added balance-telemetry documentation, a bounded Hardpoint AI strategy report, and a separate exploratory Hot Player Pressure testing report.

### Documentation

- Documented dormant inherited features, the available weapon inventory, Bounty Hunt systems, boost behavior, and useful Northstar hooks.
- Added `docs/northstar_rebase_status.md` to record the inherited-script audit and outstanding validation work.
- Standardized NPC War-owned scripts, globals, playlist keys, and convars on `NPCWar`/`NPCWAR`/`npcwar` naming and removed obsolete class-progression documentation.

## 0.1.0

- Started NPC War from the Grunt Mode 2 battlefield foundation.
- Kept the large NPC battle structure: infantry squads, Spectres, Stalkers, Prowlers, Reapers, AI Pilots, Titans, dropships, droppods, scoring AI, and score-based escalation.
- Reworked the player experience around normal pilot loadouts instead of randomized class spawns.
- Added player options for Grunt Movement, Titan Availability, Boost Availability, Tactical Ability, Ordnance, Anti-Titan Weapon, and Player Pilot Death Score.
- Added configurable score thresholds for NPC escalation.
- Added configurable Militia and IMC reinforcement budgets.
- Added optional NPC War Director pressure, hot-player pressure, hot-player dampening, special-unit pressure bonuses, and status messages.
- Improved Amped Hardpoint NPC objective selection.
- Added Capture the Flag NPC flag-running, carrier support, flag recovery, and delayed dropped-flag return behavior.
- Changed Epilogue to care about remaining NPC forces, not only remaining pilots.
- Added losing-side NPC evac behavior during Epilogue.
- Added Specialist drone loose-leash behavior so drones stay near their Specialist without forcing exact formation positions.

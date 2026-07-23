# Northstar Rebase Status

This document tracks inherited Northstar and Grunt Mode code that may be older than the Northstar scripts installed alongside NPC War. It exists so a later session can continue the compatibility audit without treating every difference as a bug or replacing NPC War-specific behavior accidentally.

Reference snapshot: local `R2Northstar/mods/Northstar.CustomServers` as inspected on 2026-07-21.

## Important Distinction

NPC War contains 26 script files whose relative paths also exist in `Northstar.CustomServers`. A differing file is not automatically outdated:

- Some files are inherited copies that should closely follow Northstar.
- Some files deliberately contain NPC War behavior and must be manually merged.
- Some files combine both categories.
- Map scripts such as Colony's evac-node registration remain owned by Northstar and are not copied into NPC War.

Never replace a large NPC War file wholesale merely because the Northstar version is newer.

## Completed Rebase

Commit `0e05eb9` (`Rebase inherited scripts onto current Northstar`) rebased these inherited scripts and then survived a complete Colony Hardpoint match:

- `_anim.gnut`
- `_health_regen.gnut`
- `ai/_ai_soldiers.gnut`
- `evac/_evac.gnut`
- `gamemodes/_gamemode_aitdm.nut`
- `mp/_ai_superspectre.nut`
- `mp/_base_gametype_mp.gnut`
- `rodeo/_rodeo.gnut`
- `titan/_replacement_titans.gnut`
- `titan/_replacement_titans_drop.gnut`
- `titan/_titan_health.gnut`
- `weapons/_cloaker.gnut`
- `weapons/_grenade.nut`

NPC War-specific behavior was reapplied where necessary, especially all-forces epilogue handling and callable/replacement Titan behavior. These files should still be tested in the gameplay systems they affect; one successful Hardpoint match proves that they compile and support that path, not every edge case.

After the rebase, these two files are currently byte-identical to local Northstar:

- `ai/_ai_soldiers.gnut`
- `titan/_replacement_titans.gnut`

## Work Completed After The Rebase

- The Hardpoint strategy experiment concluded. The combined minimum-commitment and utility strategy remains live, the rejected scenario harness was removed, and lightweight balance telemetry replaced the experimental decision logging.
- Temporary evac and Titan/core investigation logging was removed before release.
- The inherited `earn_meter_titan_multiplier 100` playlist override was removed so Titan core charge follows Northstar's normal values.
- Attrition Extended's documented entity limits were applied in the local server configuration for NPC-heavy endurance testing; they are an installation safeguard rather than NPC War package code.

## Small-Candidate Audit

The six initially suspected small rebase candidates were compared against current Northstar with whitespace ignored. Five are not straightforward stale copies. Most of their remaining differences are active Grunt Mode or NPC War extensions.

| NPC War file | Audit result | Next action |
|---|---|---|
| `ai/_ai_personal_shield.gnut` | Intentional fork | Preserve and test; do not wholesale rebase |
| `ai/_ai_stalker.gnut` | Current Northstar plus one defensive Grunt Mode change | Correct the defensive condition only |
| `ai/_droppod_fireteam.gnut` | Intentional shared NPC War extension | Preserve; no rebase currently needed |
| `ai/_ai_spawn_content.gnut` | Manual-merge file with unexplained inherited behavior changes | Decide each behavior before changing it |
| `melee/_melee_synced_human.gnut` | Best clean rebase candidate | Replace with current Northstar and test executions |
| `_utility_shared.nut` | Mostly aligned but globally sensitive | Port two targeted upstream safeguards |

### Personal Shield

`ai/_ai_personal_shield.gnut` differs meaningfully from Northstar:

- NPC War uses 200 shield health; current Northstar uses 620.
- NPC War registers and responds to `ForceStopShield`.
- `gamemodes/_ai_gamemodes.gnut` actively sends `ForceStopShield` when managing Shield Captains.
- NPC War checks that the owner exists in `file.npcVortexSpheres` before deleting its table entry during cleanup.
- NPC War updates the shield mover over a shorter movement interval.

These are active class behavior and balance decisions, not stale formatting. A wholesale rebase would break the explicit stop signal and silently triple Shield Captain shield health. Keep this fork unless shield balance is deliberately redesigned.

### Stalker

`ai/_ai_stalker.gnut` is effectively current Northstar plus a Grunt Mode defensive replacement for an assertion when the model lacks a `gear` bodygroup.

The defensive condition currently uses `bodyGroup <= 0`. `FindBodyGroup()` uses `-1` for failure, so index 0 may be valid. The future correction should check `bodyGroup == -1` instead. Preserve graceful failure rather than restoring the hard assertion, but do not incorrectly reject bodygroup index 0.

No larger rebase is currently justified.

### Droppod Fireteam

`ai/_droppod_fireteam.gnut` adds active APIs and assets:

- Public `DropPodDoorInGround()` and `DropPodOpenDoor()` helpers
- Care-package model precaching
- A configurable `DropPodActiveThink()` destruction delay

These are used by `sv_npc_war_droppod_spawn.gnut` and `gamemodes/_ai_gamemodes.gnut`. NPC War passes custom destruction times including 1 and 60 seconds. Replacing this file with Northstar would break those call sites.

The underlying Northstar behavior is otherwise closely aligned. Keep the file as an intentional extension.

### AI Spawn Content

`ai/_ai_spawn_content.gnut` requires decisions rather than a mechanical rebase:

- It contains special handling for `npc_pilot_elite`, including replacing its weapons with an R-97.
- It prevents normal spawn-option weapon replacement from running on that class.
- It comments out the normal gunship hover sound.
- It comments out normal gunship leeching initialization in one spawn path.

The elite-Pilot branch is dormant in normal NPC War but may matter to future experiments. The gunship differences are inherited behavior changes with no nearby explanation. Before editing, determine whether NPC War ever spawns that gunship path and whether restoring hover audio and leeching is desirable.

Do not wholesale rebase this file until those choices are made.

### Synced Human Melee

`melee/_melee_synced_human.gnut` is the strongest full-rebase candidate:

- It contains a disabled random-execution system controlled by constants that are both `false`.
- It carries custom execution animation arrays and a custom third-person camera.
- Its modified internal function signatures are only called inside the same file.
- It adds extra ragdoll and death handling outside the disabled random-selection condition, increasing behavioral risk even when the experiment is off.
- NPC War does not otherwise depend on the added execution helpers.

The safest cleanup is to replace it with current Northstar's file, then test Pilot-versus-NPC executions, NPC melee kills, cloak executions, phase executions, interruption, and death during animation. Make this its own commit so it can be reverted independently.

### Shared Utility

`_utility_shared.nut` should not be replaced casually because it affects nearly every system. The meaningful current findings are:

- Current Northstar wraps the console helper `gp()` in `#if DEV`; NPC War exposes it in all builds.
- Current Northstar makes `IsPetTitan()` return false when a Titan has no soul; NPC War dereferences the soul without checking it.
- NPC War has an extra `DISABLE_KILLCAMS` convar check that current Northstar no longer has. Its removal or preservation is a separate policy decision, not an automatic upgrade.
- Most remaining differences are formatting or equivalent syntax.

The safe next change is targeted: add the `#if DEV` guard and the null-safe Titan soul check while leaving replay behavior unchanged. Test Titan classification and basic match startup afterward.

### Revised Small-File Order

1. Correct the Stalker missing-bodygroup condition from `<= 0` to `== -1`.
2. Rebase `melee/_melee_synced_human.gnut` as an isolated cleanup.
3. Port the two targeted `_utility_shared.nut` safeguards.
4. Test Shield Captains and droppods without rebasing their extension files.
5. Investigate gunship and elite-Pilot intent before touching `_ai_spawn_content.gnut`.

## Manual-Merge AI Files

These files contain substantial NPC War or Grunt Mode behavior and cannot be rebased by replacement:

| NPC War file | NPC War lines | Northstar lines | NPC War ownership |
|---|---:|---:|---|
| `ai/_ai_drone.gnut` | 1530 | 1391 | Specialist drone spawning and support leash |
| `ai/_ai_pilots.gnut` | 948 | 804 | Soldier-based Pilot classes and Titan interaction |

Audit method:

1. Identify upstream Northstar changes by function, not line number.
2. Port only fixes relevant to functions NPC War still uses.
3. Preserve the Specialist-centric drone leash and NPC War Pilot class setup.
4. Test drone ownership, following, death cleanup, Titan boarding, and squad accounting.

## Deep Gameplay Forks

These files are no longer simple inherited copies. They define core NPC War behavior and need function-by-function upstream review.

| File | Why wholesale rebase is unsafe |
|---|---|
| `gamemodes/_ai_gamemodes.gnut` | NPC classes, escalation, spawning, team budgets, Director integration, unit tuning, and squad construction |
| `gamemodes/_gamemode_cp.nut` | Hardpoint strategy, minimum commitments, scoring, and balance telemetry |
| `gamemodes/_gamemode_ctf.nut` | NPC War CTF objective behavior; still largely untested in live play |
| `burnmeter/_burnmeter.gnut` | Vanilla versus Grunt Mode boost pools, temporary weapon restoration, Map Hack cleanup, and pet/reward behavior |
| `mp/spawn.nut` | NPC War player spawning and Grunt Movement behavior |

Recommended review order:

1. `burnmeter/_burnmeter.gnut`, because boosts touch player inventory and previously caused match-ending errors.
2. `mp/spawn.nut`, because player spawn bugs are immediately disruptive.
3. `gamemodes/_ai_gamemodes.gnut`, focusing on upstream spawn and NPC lifecycle fixes.
4. `gamemodes/_gamemode_cp.nut`, only in response to a demonstrated Hardpoint failure or a focused balance question.
5. `gamemodes/_gamemode_ctf.nut`, alongside dedicated CTF testing rather than speculative edits.

## Files Already Rebased But Still Needing Focused Tests

The completed rebase still needs broader validation:

| System | Relevant files | Minimum test |
|---|---|---|
| Evac | `evac/_evac.gnut` | Win and lose on Colony; record multiple selected nodes; board without Grapple |
| Callable Titan | replacement Titan files, `_titan_health.gnut` | Call, embark, disembark, doom, eject, die, and call again |
| Rodeo | `rodeo/_rodeo.gnut` | Rodeo friendly and enemy Titans; embark/disembark under damage |
| Cloak | `weapons/_cloaker.gnut` | Player and NPC cloak start/end/death cleanup |
| Grenades | `weapons/_grenade.nut` | Pilot grenades, NPC grenades, and death during a throw |
| Health regeneration | `_health_regen.gnut` | Standard regeneration and any bleedout/first-aid combinations |
| Attrition | `_gamemode_aitdm.nut` | Full match with standard scoring and epilogue |
| Reapers | `mp/_ai_superspectre.nut` | Normal spawn, warpfall, death, and pet Reaper boost |

## Rebase Workflow For A Later Session

For each pending file:

1. Compare NPC War against the local current Northstar counterpart.
2. Separate formatting churn from behavioral changes.
3. Mark every NPC War-owned function before editing.
4. Start from current Northstar only for a genuinely inherited file.
5. Reapply NPC War changes as small, named blocks.
6. Run `git diff --check` and inspect `scripts.rson` ownership in a fresh log.
7. Launch the game and verify server compilation before playing a full match.
8. Commit a tested group separately from diagnostics and telemetry.

Useful comparison pattern from the repository root:

```powershell
git diff --no-index -- `
  mods/Northstar.CustomServers/mod/scripts/vscripts/<path> `
  mods/Aramundir-NPC-War/mod/scripts/vscripts/<path>
```

## Suggested Continuation

The safest next work is:

1. Run long, populated Attrition and Hardpoint matches after a clean Northstar restart to evaluate whether the documented entity limits resolve the late-match native crashes.
2. Perform dedicated CTF validation, including flag pickup, escort, interception, recovery, return timing, and epilogue.
3. Complete focused lifecycle tests for callable Titans, AI Pilot Titans, boosts, evac, rodeo, cloak, grenades, health regeneration, and Reapers.
4. Audit the five small AI/melee candidates in the revised order above.
5. Audit `_utility_shared.nut` with extra care, including the null-safe Titan-soul check and the inherited killcam policy.
6. Return to deep gameplay forks only with a dedicated test plan per subsystem.
7. After core stabilization and the `0.2.0` release, begin Reinforcement Resources as NPC War's next major spawning and battlefield-logistics feature.

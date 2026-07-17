# Dormant Feature Notes

Last updated: 2026-07-17

This is a practical audit of feature code that still exists in NPC War's inherited Grunt Mode 2 codebase, or that was discovered while cleaning up the fork.

In this file, `dormant` does not mean production-ready. It means the code exists, or a leftover hook exists, but the feature is not part of current NPC War gameplay. Anything listed here needs a fresh prototype pass before being promoted into the live mod.

Status meanings:

- `Dormant`: code or state exists, but current NPC War gameplay does not use it.
- `Reference-only`: useful for study, but too rough or stale to enable directly.
- `Live hidden system`: currently used by NPC War, but easy to miss because it is inherited or buried in shared scripts.
- `Removed`: intentionally deleted or disabled from the live mod.

## Dormant: Weapon Drop And Care Package Helpers

NPC War still contains a mostly unused weapon-drop/care-package system inherited from Grunt Mode 2.

Main evidence:

- `mod/scripts/vscripts/gamemodes/_gamemode_aitdm.nut:33`
  - Defines `weapondrops = [ false, false ]`.
- `mod/scripts/vscripts/gamemodes/_gamemode_aitdm.nut:390`
  - Sets the team weapon-drop flag during escalation.
- `mod/scripts/vscripts/gamemodes/_gamemode_cp.nut:104`
  - Defines the same `weapondrops` flag for Amped Hardpoint.
- `mod/scripts/vscripts/gamemodes/_gamemode_cp.nut:456`
  - Sets the Amped Hardpoint weapon-drop flag.
- `mod/scripts/vscripts/gamemodes/_gamemode_ctf.nut:56`
  - Defines the same `weapondrops` flag for CTF.
- `mod/scripts/vscripts/gamemodes/_gamemode_ctf.nut:422`
  - Sets the CTF weapon-drop flag.

Current status:

- The flags are set, but current NPC War spawn logic does not read them.
- This means there is leftover escalation state for weapon drops, but no active feature using it.

The useful low-level helpers live in `mod/scripts/vscripts/gamemodes/_ai_gamemodes.gnut`.

### Care Package Drop Pod

Evidence:

- `_ai_gamemodes.gnut:978`
  - `AiGameModes_SpawnDropPodToGetWeapons()`
  - Marked in-code as `//Unused now`.
- `_ai_gamemodes.gnut:987`
  - `AiGameModes_SpawnDropPodToGetWeapons_Threaded()`
  - Creates a drop pod, makes it usable, gives it prompts, and adds `GiveAirDropWeapon` as the use callback.
- `_ai_gamemodes.gnut:1024`
  - `GiveAirDropWeapon()`
  - Gives a random weapon to the player, prevents the same player from taking repeatedly from the same package, and sends a HUD message.

What it can become:

- A field reward crate for future side objectives.
- A purchasable weapon cache for a player economy.
- A shooting-range or testing crate that hands out hidden weapons from `weapon_inventory.md`.

Why it is not ready as-is:

- The outer function is commented out.
- The reward pool uses inherited globals instead of an NPC War-specific whitelist.
- The HUD messages are old Grunt Mode-style utility text.
- It would need modern settings and balance rules before release.

### Weapon Drop Pod

Evidence:

- `_ai_gamemodes.gnut:1052`
  - `AiGameModes_SpawnDropPodWithWeapons()`
  - Emits a sonar-style alert, then spawns a pod.
- `_ai_gamemodes.gnut:1058`
  - `AiGameModes_SpawnDropPodWithWeapons_Threaded()`
  - Drops several weapon entities after the pod lands.
- `_ai_gamemodes.gnut:1131`
  - `DropModdedWeapons()`
  - Creates a physics weapon entity, applies category-specific mods, and highlights it.

What it can become:

- A battlefield supply drop that leaves weapons on the ground.
- A reward for optional Field Objectives or Frontier Contracts.
- A logistics event in a future reinforcement-resource system.
- A loot source for an extraction-shooter prototype.

Why it is not ready as-is:

- There is no live call site in current NPC War.
- It has no ownership rules, team rules, or anti-spam rules.
- It needs a safe weapon whitelist. `docs/weapon_inventory.md` should be the starting point.

### Reaperfall Weapon Delivery

Evidence:

- `_ai_gamemodes.gnut:1084`
  - `AiGameModes_SpawnReaperDorpsWeapons()`
  - Name typo is inherited: `Dorps`.
- `_ai_gamemodes.gnut:1090`
  - `AiGameModes_SpawnReaperDorpsWeapons_Threaded()`
  - Spawns a Reaper-like super spectre, warpfalls it, destroys it, then drops weapons.
- `_ai_gamemodes.gnut:1107`
  - `DropWeaponAlert()`
  - Sends repeated sonar pulses at the incoming drop position.

What it can become:

- A dramatic rare supply delivery.
- A team logistics event.
- A reward drop after a hard objective.
- A prototype for "visible battlefield resupply" in future larger modes.

Why it is not ready as-is:

- It creates spectacle, then immediately destroys the delivery unit.
- The delivery unit uses `TEAM_UNASSIGNED`.
- It has no live balancing or cleanup wrapper.
- The function name typo should be wrapped by a clean NPC War API if reused.

## Live Hidden System: NPC Pilots And Titan Embark Logic

NPC War still uses inherited NPC pilot/titan support. This is not a dormant feature, but it is easy to miss.

Evidence:

- `_ai_gamemodes.gnut:18`
  - Exports `AiGameModes_SpawnPilotCanEmbark`.
- `_ai_gamemodes.gnut:19`
  - Exports `AiGameModes_SpawnPilotWithTitan`.
- `_ai_gamemodes.gnut:557`
  - `AiGameModes_SpawnPilotCanEmbark()`
  - Spawns an `npc_soldier` with pilot model, then spawns a titan for it.
- `_ai_gamemodes.gnut:793`
  - `AiGameModes_SpawnPilotWithTitan()`
  - Creates a pilot and titan pairing.
- `_gamemode_aitdm.nut:326`, `_gamemode_cp.nut:392`, `_gamemode_ctf.nut:358`
  - Current gamemodes can call `AiGameModes_SpawnPilotCanEmbark`.

Current status:

- This is part of the inherited battlefield escalation layer.
- These are not true `npc_pilot_elite` actors. They are soldiers using pilot models and pilot/titan staging.
- The separate elite-pilot debug experiment was reverted and should not be confused with this system.

Future tie-in:

- Useful evidence for Solo Bounty Hunt rival NPCs.
- Useful evidence for future custom elite unit classes.
- Useful evidence for campaign-like encounters where an NPC "pilot" calls or boards a titan.

## Live Hidden System: Specialist, Drone, Shield Captain, And Custom NPC Roles

The custom Grunt Mode 2 unit roles are also not dormant. NPC War still inherits and uses the general idea of special unit classes.

Current status:

- Specialist drone behavior and shield-captain behavior are part of the inherited custom NPC role layer.
- NPC War has already adjusted some behavior, such as drone leash/support behavior, but these units are not a separate dormant feature.

Future tie-in:

- These are the strongest proof that NPC War can grow custom NPC classes without needing true Pilot AI.
- Solo Bounty Hunt could use this style to create rival bounty hunters, pet prowler handlers, heavy specialists, or boss-like NPCs.
- Frontier Contracts could mark these units as optional targets without changing match win conditions.

## Live Feature: Boost Pool Overrides

The old Grunt Mode 2 boost payload changes are no longer hidden-only behavior. NPC War now exposes them through `Boost Pool`.

Evidence:

- `mod/scripts/vscripts/npcwar/sh_npc_war_settings.gnut:33`
  - Defines `npcwar_boost_pool`.
- `mod/scripts/vscripts/npcwar/sh_npc_war_settings.gnut:128`
  - Adds the `Boost Pool` private match setting.
- `mod/scripts/vscripts/burnmeter/_burnmeter.gnut:28`
  - Reads the boost pool setting.

Current status:

- `Vanilla` pool gives vanilla-style boost effects.
- `Grunt Mode 2` pool preserves inherited Grunt Mode 2 payload swaps, such as Smart Pistol becoming the double-barrel shotgun and some boosts becoming special NPC summons.

Future tie-in:

- Economy and Field Objectives should probably grant access to the player's selected boost pool rather than inventing a third hidden boost behavior.
- Weapon caches can use `weapon_inventory.md` for explicit weapon rewards instead of overloading boost activations.

## Removed: Pilot Skirmish / Pilots Vs Pilots

The old pilot-vs-pilot gamemode script was removed from NPC War.

Current status:

- It should not be considered a dormant feature.
- If NPC pilot experiments return, they should be developed behind a clear prototype branch or setting, not by reviving the old gamemode file blindly.

Future tie-in:

- True Pilot AI remains a research-track idea in `future_mode_ideas.md`.
- The safer near-term path is custom soldier-based elite units, not true pilot movement AI.

## Removed: NPCWAR_CUSTOM_SPAWNING ConVar

The old custom-spawning toggle was removed from the public-facing setup.

Current status:

- NPC War owns its spawn override directly.
- This should not be treated as a dormant player option.

Future tie-in:

- If a future compatibility mode is needed, it should be a deliberate setting with clear behavior rather than a leftover development ConVar.

## Removed Prototype: HVT And Field Objectives

HVT/Field Objectives were prototyped, then removed from live NPC War.

Current status:

- They are not active features.
- They should stay out of NPC War's core battle sandbox unless deliberately reintroduced.

Future tie-in:

- `future_mode_ideas.md` treats Field Objectives and player economy as a separate future framework, currently called Frontier Contracts.
- Weapon drops from this document are good candidate rewards for that framework.
- A HVT kill could grant a weapon cache, player credits, or a team logistics bonus without changing the match score or win condition.

## Recommended Reuse Order

If any dormant feature comes back, the safest order is:

1. Build a tiny dev-only weapon cache prototype using `_ai_gamemodes.gnut:1131` `DropModdedWeapons()`.
2. Restrict the pool to a short whitelist from `docs/weapon_inventory.md`.
3. Spawn it at a safe known point, not in a full economy loop.
4. Verify pickup behavior, highlighting, cleanup, and multiplayer safety.
5. Only then connect it to Field Objectives, player economy, or reinforcement logistics.

The main design rule: dormant features should enrich the sandbox without silently taking over NPC War's core identity.

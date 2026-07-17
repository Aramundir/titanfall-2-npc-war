# NPC War Future Mode Ideas

Last updated: 2026-07-17

This is a session-independent design notebook for NPC War and larger Titanfall 2 Northstar ideas. It should let a future Codex session understand the design direction, inspect the right local scripts, and resume without needing the original chat history.

This file is not an implementation plan by itself. It is a map of possible future work, grounded in code evidence where we have it. It is also not concrete evidence that everything here is possible, it's more like a wishlist with some backing from clues we found in the code.

## Current Architecture Boundary

NPC War should remain the core battle sandbox:

- AI war built from Grunt Mode 2 foundations.
- Custom Pilot loadout by default.
- Vanilla-style boost availability by default.
- Callable Titan behavior controlled by NPC War player settings.
- Optional sandbox restrictions such as Grunt Movement.
- Refined NPC objective behavior for Attrition, Amped Hardpoint, and CTF.
- No mandatory economy, progression, or side-objective layer.

The larger ideas below should not be folded into NPC War by default. When a system starts being generally useful outside NPC War, it should become a separate mod or framework.

## Outdated Or Removed Prototypes

These notes prevent future sessions from reintroducing stale assumptions.

- Boost Drops and Direct Grant boosts were experimented with, then removed from the live design.
- The current live boost script is `mods/Aramundir-NPC-War/mod/scripts/vscripts/npcwar/sv_npc_war_boost_rewards.gnut`.
- That current script supports disabled boost rewards and post-Titan-threshold boost meter behavior; it does not provide a live prop-script boost cache.
- HVT and field-objective ideas are future design notes only; they are not part of live NPC War behavior.

## Evidence Index

This section lists current local scripts that prove or strongly suggest the feasibility of the future systems. Feature sections later should reference this evidence instead of repeating it in every paragraph.

### Interactable Objects

Northstar supports usable world props and player interaction callbacks.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/_utility.gnut:1524`
  - `CreatePropScript()` creates generic scriptable props.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_loadout_crate.nut:28`
  - Loadout crates are created as prop scripts.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_loadout_crate.nut:33`
  - The crate is made usable with `SetUsable()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_loadout_crate.nut:39`
  - The crate gets use prompts with `SetUsePrompts()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_loadout_crate.nut:162`
  - `UsingLoadoutCrate()` handles player interaction.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:342`
  - Bounty Hunt banks use `AddCallback_OnUseEntity()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:1201`
  - `OnPlayerUseBank()` handles bank interaction.

What this proves:

- Mission terminals, stash crates, stores, bank objects, shooting-range buttons, and objective interactables are plausible.
- The exact UI polish still needs prototyping.

### Loadout Stations And Loadout Filtering

Northstar can open loadout UI and apply pilot loadouts during play.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_loadout_crate.nut:169`
  - Loadout crates call `ServerCallback_OpenPilotLoadoutMenu`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/_loadouts_mp.gnut:323`
  - `SetPlayerLoadoutDirty()` marks changed loadouts.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/_loadouts_mp.gnut:329`
  - `TryGivePilotLoadoutForGracePeriod()` can apply loadout changes.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/_loadouts_mp.gnut:355`
  - Loadout crate flow can call `Loadouts_TryGivePilotLoadout()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/sh_loadouts.nut:3317`
  - `Loadouts_TryGivePilotLoadout()` reads the selected pilot loadout.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/sh_loadouts.nut:3338`
  - `GivePilotLoadout()` applies the chosen loadout.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/sh_loadouts.nut:3552`
  - Active pilot loadout index is stored on the player.

What this proves:

- Loadout stations are plausible.
- Runtime loadout restrictions are plausible, but they should be carefully prototyped before becoming progression rules.

### Persistence And Player Identity

Northstar exposes file helpers and player identity hooks.

- `mods/Northstar.Custom/mod/scripts/vscripts/_testing.nut:98`
  - Existing code calls `NSSaveJSONFile()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/sh_northstar_safe_io.gnut:9`
  - Existing safe IO uses `NS_InternalLoadFile()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/sh_northstar_safe_io.gnut:40`
  - Existing safe IO decodes JSON with `DecodeJSON()`.
- `mods/Northstar.Custom/mod/scripts/vscripts/burnmeter/sh_boost_store.gnut:165`
  - Existing code keys player-specific state by `player.GetUID()`.

What this proves:

- Persistent profiles, stash state, and campaign progress are plausible.
- Save-version handling and corruption recovery still need a cautious prototype.

### Map Travel

Northstar can change maps through existing playlist/private-match flows.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/lobby/_private_lobby.gnut:149`
  - `StartMatch()` drives private match launch.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/lobby/_private_lobby.gnut:176`
  - Private match sets the current playlist.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/lobby/_private_lobby.gnut:197`
  - Private match calls `GameRules_ChangeMap()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_changemap.nut:3`
  - `CodeCallback_MatchIsOver()` handles post-match map flow.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_changemap.nut:38`
  - Post-match flow can change to the next playlist map.

What this proves:

- Multi-map campaigns and extraction raids are plausible with loading screens.
- Seamless no-loading open world is not expected.

### Dropships And Evac

NPC War already uses evac flow, dropship arrival, boarding, departure, and space flyby.

- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:215`
  - `Evac()` creates the evac sequence.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:323`
  - Evac uses `cd_dropship_rescue_side_start`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:365`
  - Players board through `AddPlayerToEvacDropship()`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:390`
  - Evac uses `cd_dropship_rescue_side_end`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:420`
  - Evac uses `ds_space_flyby_dropshipA`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:497`
  - `PlayerInDropship()` checks boarding state.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/mp/_classic_mp_dropship_intro.gnut:147`
  - `PutPlayerInDropship()` supports intro/dropoff behavior.

What this proves:

- Shuttle insertion and extraction loops are plausible.
- Mission completion by boarding evac is plausible.

### NPC Spawning And Reinforcement Delivery

NPC War and Northstar expose dropships, drop pods, Reapers, Titans, pilots, and spawn limits.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_ai_gamemodes.gnut:63`
  - Northstar can spawn drop-pod squads with `AiGameModes_SpawnDropPod()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_ai_gamemodes.gnut:95`
  - Northstar can spawn Reapers with `AiGameModes_SpawnReaper()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_ai_gamemodes.gnut:173`
  - Northstar can spawn Titans with `AiGameModes_SpawnTitan()`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_ai_gamemodes.gnut:268`
  - NPC War has its own drop-pod squad spawn helper.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_aitdm.nut:234`
  - Attrition uses `NPCWarDirector_GetSquadSpawnLimit()`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_aitdm.nut:240`
  - Attrition computes percentage-based drop-pod refill deficit.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_cp.nut:300`
  - Hardpoint uses the same squad limit path.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_ctf.nut:266`
  - CTF uses the same squad limit path.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/npcwar/sh_npc_war_settings.gnut:506`
  - The Director resolves current squad limits.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/npcwar/sh_npc_war_settings.gnut:525`
  - The Director resolves special-unit limits.

What this proves:

- Reinforcement resources can be layered onto the current spawner later.
- The current live system already has a lightweight version of emergency drop-pod behavior.

### NPC Steering And Objective Focus

NPCs can be pushed toward positions and objective areas.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/ai/_ai_soldiers.gnut:758`
  - `SendAIToAssaultPoint()` sends an NPC to an origin.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/ai/_ai_soldiers.gnut:781`
  - NPCs use `AssaultPoint()`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/ai/_ai_soldiers.gnut:782`
  - NPCs use `AssaultSetGoalRadius()`.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_cp.nut:1116`
  - Hardpoint NPCs are directed toward chosen hardpoint objective points.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_ctf.nut:687`
  - CTF NPCs are directed toward flag-objective origins.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/evac/_evac.gnut:633`
  - Losing-side NPCs can be directed toward evac.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/ai/_ai_drone.gnut:999`
  - Drone support behavior can pull the drone toward its owner.

What this proves:

- Camps, patrols, objective defenders, evac attackers, and rival hunters are plausible.
- The AI is still Respawn AI, so we can steer it but should not expect full behavior-tree authorship.

### Official Northstar NPC And Weapon Utility Docs

Northstar's public docs are useful as an API map, but they do not fully explain the native AI implementation. They should be treated as a checklist of available tools, then verified against local scripts and in-game tests.

Primary references:

- `https://docs.northstar.tf/Modding/reference/respawn/native_server/npc/`
  - NPC utilities, squads, navigation nodes, navmesh helpers, skit-node helpers, dangerous areas, AIN checks, and spawner lookup helpers.
- `https://docs.northstar.tf/Modding/reference/respawn/native_server/weapons/`
  - Explosion helpers, radius damage helpers, weapon despawn timing, impact effect table lookup, and weapon damage calculation.
- `https://docs.northstar.tf/Modding/reference/respawn/native_server/settings/`
  - Player settings, weapon info fields, weapon mod lookup, weapon bodygroup helpers, and AI settings lookup.

Useful NPC hooks:

- `UpdateEnemyMemoryFromTeammates()` and `UpdateEnemyMemoryWithinRadius()`
  - Could help newly spawned squads, specialist drones, or objective units acquire relevant enemies without hard-forcing exact targets.
- `CreateNPCSquad()`, `GetNPCSquadSize()`, `SetNPCSquadMode()`, and `ScriptGetNPCArrayBySquad()`
  - Could support future squad debugging, squad cohesion checks, or custom elite-squad behavior.
- `NavMesh_ClampPointForAI()`, `NavMesh_ClampPointForHull()`, `NavMesh_RandomPositions()`, `NavMesh_RandomPositions_LargeArea()`, and `NavMesh_IsPosReachableForAI()`
  - Could make future objective markers, reward drops, camps, patrol points, and reinforcement targets safer.
- `SkitSetDistancesToClosestHarpoints()`, `GetSkitNodeArray_NearPlayers()`, `GetSkitNodeArray_NearHardpoints()`, and `GetSkitNodeArray_NearPos()`
  - Worth remembering for ambient battlefield behavior, but not proven useful for current NPC War objective logic.
- `AI_CreateDangerousArea()`, `AI_CreateDangerousArea_Static()`, and `AI_CreateDangerousArea_DamageDef()`
  - Could make AI avoid marked hazards in future logistics/objective systems.
- `GetSpawnerArrayByClassName()`, `GetSpawnerArrayByScriptName()`, and `GetSpawnerByScriptName()`
  - Useful for map-authored spawner research and safer spawn-source selection.

Useful weapon and settings hooks:

- `Weapon_SetDespawnTime()`
  - Relevant if future field rewards or dropped weapons return.
- `GetImpactEffectTable()`
  - Relevant for projectile or explosion experiments.
- `CalcWeaponDamage()`
  - Could support future economy pricing, HVT threat estimates, or weapon reward balancing.
- `GetWeaponInfoFileKeyField_Global()` and `GetWeaponInfoFileKeyField_WithMods_Global()`
  - Useful for enriching `docs/weapon_inventory.md` with display names, categories, damage fields, icons, and hidden metadata.
- `GetWeaponMods_Global()`
  - Useful for enumerating legal weapon mod combinations before spawning reward weapons.
- `SetBodyGroupsForWeaponConfig()`
  - Useful if future menus or physical weapon props need to match a specific weapon configuration.
- `GetPlayerSettingsFieldForClassName_*()` and `Dev_GetPlayerSettingByKeyField_Global()`
  - Useful for comparing Pilot, Grunt Movement, Titan, and NPC-derived health/model settings.
- `GetAISettingHullType()`, `Dev_GetAISettingByKeyField_Global()`, and `Dev_GetAISettingAssetByKeyField_Global()`
  - Useful for custom NPC class research and safer precache/model inspection.

What this adds to future design:

- NPC War probably did not miss a hidden high-level AI director API. The docs expose low-level helpers more than behavior-tree authorship.
- The best near-term value is safer placement, better squad debugging, better weapon metadata, and lighter-touch AI awareness nudges.
- Before adding new behavior, prototype one small helper at a time:
  - A navmesh-safe placement wrapper for future drops/objectives.
  - A squad debug report using `ScriptGetNPCArrayBySquad()`.
  - A weapon metadata enrichment pass for `weapon_inventory.md`.
  - A limited enemy-memory refresh for specialist/drone support behavior.

### Kill Callbacks, Scoring, And Side Rewards

Northstar and NPC War can observe kills and award separate player stats.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/_codecallbacks_common.gnut:414`
  - `AddCallback_OnNPCKilled()` registers NPC kill callbacks.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_npcwar.gnut:15`
  - NPC War registers NPC kill callbacks.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_npcwar.gnut:16`
  - NPC War registers player kill callbacks.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_npcwar.gnut:36`
  - `NPCWar_GetScoreValue()` maps target type to score value.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_npcwar.gnut:103`
  - `NPCWar_GivePoints()` gives score to the attacker.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_cp.nut:1235`
  - Hardpoint contextual scoring exists for defense/assault style kills.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/gamemodes/_gamemode_ctf.nut:1063`
  - CTF contextual scoring exists for flag-carrier kills.

What this proves:

- Side objectives and economy rewards can listen to combat events without owning win conditions.
- Mode adapters should decide which combat events are meaningful.

### Markers, Highlights, Dialogue, And HUD Feedback

The codebase has several ways to tell the player that something matters.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/_remote_functions_mp.gnut:908`
  - `ServerCallback_PingMinimap` is registered.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/conversation/_faction_dialogue.gnut:17`
  - `PlayFactionDialogueToPlayer()` plays faction dialogue.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/conversation/_faction_dialogue.gnut:30`
  - `PlayFactionDialogueToTeam()` plays faction dialogue to a team.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/sh_highlight.gnut:843`
  - `Highlight_SetEnemyHighlight()` applies highlight assets.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:517`
  - Bounty Hunt highlights NPCs carrying stolen bonus as `enemy_boss_bounty`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:777`
  - Bounty Hunt announces boss waves through remote callbacks.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:838`
  - Bounty Hunt announces bank open through remote callbacks.

What this proves:

- HVTs, contracts, boss targets, loot targets, and event callouts are plausible.
- Custom UI polish still needs careful prototyping.

### Boost And Earn-Meter Control

Boosts can be controlled through the earn meter.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/earn_meter/sv_earn_meter_mp.gnut:262`
  - `EarnMeterMP_SetBoostByRef()` sets a player's boost reward by ref.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/earn_meter/sv_earn_meter.gnut:419`
  - `PlayerEarnMeter_SetReward()` sets the earn-meter reward.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/earn_meter/sv_earn_meter.gnut:382`
  - `PlayerEarnMeter_SetRewardUsed()` marks reward use.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/npcwar/sv_npc_war_boost_rewards.gnut:66`
  - NPC War controls meter state based on boost availability mode.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/npcwar/sv_npc_war_boost_rewards.gnut:70`
  - NPC War can disable boost rewards.
- `mods/Aramundir-NPC-War/mod/scripts/vscripts/npcwar/sv_npc_war_boost_rewards.gnut:86`
  - NPC War can re-enable the selected boost after Titan escalation.

What this proves:

- Economy-purchased boost access is plausible.
- It should be separated from vanilla boost behavior so settings do not fight each other.

### Bounty Hunt Systems

Bounty Hunt is a valuable source of proven ideas.

- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:36`
  - Bounty Hunt spawns AI as `TEAM_BOTH`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:723`
  - `AT_GameLoop_Threaded()` runs the wave/bank loop.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:882`
  - `AT_CampSpawnThink()` runs camp spawning.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:1159`
  - `AT_BankActiveThink()` controls active bank state.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:1201`
  - `OnPlayerUseBank()` handles player deposits.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:502`
  - NPCs can steal player bonus and store it.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:614`
  - `AT_AddPlayerBonusPoints()` controls carried value.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:640`
  - `AT_AddPlayerTotalPoints()` controls banked value.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:1568`
  - `AT_BountyTitanEvent()` spawns bounty Titans.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:1635`
  - `AT_HandleBossTitanSpawn()` configures bounty Titans.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/gamemodes/_gamemode_at.nut:672`
  - Boss damage can pay reward segments.

What this proves:

- Neutral enemies, banks, carried value, stolen value, camps, boss waves, and boss damage rewards are all proven concepts.
- Directly importing Bounty Hunt into NPC War is not recommended; the systems should be harvested carefully.

### Native AI, Behavior Selectors, And Elite Pilots

Northstar exposes Respawn's NPC AI through scriptable AI settings and behavior selector files, but the deepest schedule/task implementation is still native engine code.

- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_soldier.txt:15`
  - Soldier AI uses `behavior_soldier`.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_titan_auto.txt:15`
  - Auto-Titan AI uses `behavior_mp_auto_titan`.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_pilot_elite.txt:4`
  - `npc_pilot_elite` uses the `pilot_elite` AI class.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_pilot_elite.txt:17`
  - `npc_pilot_elite` is a real native NPC base class.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_pilot_elite.txt:21`
  - `npc_pilot_elite` uses `behavior_pilot_elite`.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_pilot_elite_assassin.txt:4`
  - The assassin variant uses `pilot_assassin`.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_pilot_elite_assassin_cqb.txt:6`
  - CQB assassin has its own behavior selector.
- `mods/Northstar.CustomServers/mod/scripts/aisettings/npc_pilot_elite_assassin_sniper.txt:9`
  - Sniper assassin has its own behavior selector.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/ai/_ai_spawn.gnut:298`
  - Northstar has a helper that creates `npc_pilot_elite`.
- `mods/Northstar.CustomServers/mod/scripts/vscripts/ai/_ai_spawn.gnut:303`
  - Northstar has a helper that creates an assassin variant.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite.txt:3`
  - Elite pilot behavior can consider rodeo attacks.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite.txt:38`
  - Elite pilot behavior can use shooting cover.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite.txt:41`
  - Elite pilot behavior can throw grenades.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite.txt:52`
  - Elite pilot behavior can strafe dodge while evasive.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite_assassin.txt:26`
  - Assassin behavior can long jump.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite_assassin_cqb.txt:35`
  - CQB assassin behavior can use alternate range attacks.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite_assassin_sniper.txt:29`
  - Sniper assassin behavior can use a native snipe schedule.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_titan.txt:4`
  - Titan behavior references native `CNPC_Titan::SelectSchedule_TitanCore`.
- `mods/Northstar.CustomServers/mod/scripts/aibehavior/behavior_pilot_elite.txt:38`
  - Elite pilot behavior references native `CAI_Combatant::SelectSchedule_ShootingCover`.
- `D:/SteamLibrary/steamapps/common/Titanfall2/server.dll`
  - Likely contains the native implementation of schedule/task code such as `CAI_Combatant` and `CNPC_Titan`.

What this proves:

- We can inspect and edit the exposed AI settings and behavior selector layer.
- `npc_pilot_elite` is a real experiment target, separate from NPC War's current pilot-looking `npc_soldier` units.
- The behavior files show promising native schedules: rodeo, cover, grenade, dodge, long jump, sniping, range attack, and melee.
- The behavior files do not prove full player-like Pilot movement, Grapple, Holo, Phase, Stim, or wallrunning.
- The actual implementation of schedule functions is native engine code, not readable Squirrel.

## Future Separate Mod: Frontier Contracts

Working title: Frontier Contracts.

This should be a separate reusable mod or framework for field objectives and player economy. NPC War should only provide an adapter when it wants to host that framework.

### Non-Negotiable Rule

Field Objectives and player economy must never directly affect win conditions in any game mode.

They should not:

- Add direct match score beyond the base mode's normal scoring.
- Capture hardpoints.
- Capture or return flags.
- End rounds.
- Change the winning team.
- Override Bounty Hunt banking.
- Override Attrition, Hardpoint, CTF, or any other mode's victory rules.

They can:

- Give player credits.
- Give boost tokens.
- Give temporary unlocks.
- Give field-store discounts.
- Trigger dialogue or objective callouts.
- Mark HVTs, bosses, loot caches, courier targets, or side objectives.
- Emit optional reward events that a host mod may listen to.
- Provide flavor-only objectives with no mechanical reward.

The base mode decides who wins. Frontier Contracts adds optional side goals and reward loops.

### Core Structure

Suggested modules:

- Objective Engine:
  - Active objective registry.
  - Timers.
  - Success/failure state.
  - Pings, highlights, and dialogue hooks.
- Economy Core:
  - Credits.
  - Unsecured value.
  - Secured value.
  - Tokens.
  - Purchases.
  - Optional persistence later.
- Reward Router:
  - Converts objective outcomes into credits, tokens, unlocks, dialogue, or external reward events.
- Mode Adapters:
  - Small scripts that tell the framework what a kill, bank, hardpoint, flag, boss, camp, or extraction means in the current mode.

Possible adapters:

- NPC War adapter:
  - Reads NPC War target values and exposes NPC War units as possible HVTs.
- Hardpoint adapter:
  - Detects defending, clearing, contesting, and amping context without changing hardpoint ownership or score.
- CTF adapter:
  - Detects flag-adjacent context without granting captures or returns.
- Bounty Hunt adapter:
  - Observes banks, carried value, camps, bosses, and bounty events without replacing the Bounty Hunt loop.
- Generic adapter:
  - Uses only kills, timers, area triggers, and interactables.

### Field Objectives

Field Objectives are optional side goals.

Examples:

- HVT:
  - Mark a dangerous NPC.
  - Success if the player kills it.
  - Failure if someone else kills it or it escapes.
- Clear Camp:
  - Mark a camp area.
  - Success when the player clears the required enemies.
- Recover Item:
  - Mark a dropped object or blackbox.
  - Success when the player extracts, deposits, or interacts with it.
- Defend Area:
  - Keep an area safe for a timer.
- Courier Hunt:
  - A target tries to reach a destination.
  - The player can intercept it.
- Boss Contract:
  - Mark a Reaper, Titan, or elite squad as a contract target.

Evidence:

- Kill callbacks: `_codecallbacks_common.gnut:414`, `_npcwar.gnut:15`, `_npcwar.gnut:16`.
- Markers/highlights/dialogue: `_remote_functions_mp.gnut:908`, `sh_highlight.gnut:843`, `_faction_dialogue.gnut:17`.
- NPC steering for objective movement: `_ai_soldiers.gnut:758`, `_ai_soldiers.gnut:781`.

### Player Economy

Economy should be player-facing and optional.

Possible reward types:

- Credits.
- Boost tokens.
- Temporary access to full Pilot movement.
- Temporary tactical access.
- Temporary Titan meter access.
- Field-store discounts.
- Weapon cache access.
- Special one-match permissions.

Possible credit sources:

- Weighted NPC kills.
- Boss damage rewards.
- HVT success.
- Objective completion.
- Depositing unsecured value.
- Extracting with loot.

The economy can be match-local at first. Persistence belongs later, after the core loop feels good.

Evidence:

- Boost meter control: `sv_earn_meter_mp.gnut:262`, `sv_earn_meter.gnut:419`, `sv_npc_war_boost_rewards.gnut:66`.
- Player identity and persistence: `_testing.nut:98`, `sh_northstar_safe_io.gnut:9`, `sh_boost_store.gnut:165`.
- Bounty Hunt carried/banked value: `_gamemode_at.nut:614`, `_gamemode_at.nut:640`.

### Why This Is Separate From NPC War

NPC War should not become the owner of every future system.

As a separate mod:

- NPC War remains clean and playable without economy.
- Frontier Contracts can have its own settings, UI, and adapter rules.
- Solo Bounty Hunt and Extraction Shooter can use the same objective/economy layer.
- Other mods can use side objectives without installing the NPC War sandbox.
- Persistence can be added later without forcing save-profile logic into NPC War.

## Future System: Reinforcement Resources And Battlefield Logistics

This is a faction-side logistics idea. It is not player economy.

The purpose is to model how Militia and IMC spend battlefield reinforcement resources. It should stay conceptually separate from Frontier Contracts credits.

### Design Boundary

The system should avoid artificial difficulty.

Bad rule:

- A losing team magically receives free resources because it is losing.

Better rule:

- Both teams follow the same resource rules.
- Both teams have resource pools.
- A losing team may spend resources more urgently because it needs bodies now.
- A winning team may spend less because it already holds the field.
- If the losing team spends everything and still fails, that result is earned.

### Dropships Versus Drop Pods

In-universe resource logic:

- Dropships are reusable logistics and should be cheaper.
- Drop pods are emergency disposable insertion assets and should be more expensive.

Design implication:

- Normal reinforcement churn should prefer dropships.
- Severe force depletion can justify expensive drop pods.
- Drop pods should feel like command panic-spending to prevent collapse.

### Possible Resource Costs

Example hierarchy:

- Dropship infantry squad: cheap.
- Drop-pod infantry squad: expensive.
- Reaper: expensive escalation asset.
- Prowler wave: medium/high.
- Titan: very expensive or threshold-gated.
- Gunship: expensive support asset.
- Elite squad or HVT-class unit: special reserve.

### Spending Policy

The spawner should own actual spending because it decides what appears on the field.

The Director, if involved, should influence policy rather than mint free resources:

- Recommend aggressive spending when badly under cap.
- Recommend conservative spending when comfortably ahead.
- Prefer cheap dropships when stable.
- Permit expensive pods when severe deficit exists and resources are available.

### Optional Frontier Contracts Interaction

Only after reinforcement resources are explained does the interaction make sense:

- Frontier Contracts can emit a reward event such as `team_logistics_bonus`.
- NPC War or another host mod can choose to listen to that event.
- The reward can add resources, discount the next reinforcement, or unlock an emergency dispatch.
- This should be visible and earned through a side objective, not hidden Director cheating.

Example:

- A HVT objective succeeds.
- Frontier Contracts emits a team logistics reward.
- NPC War adapter adds a small resource bonus to the player's team.
- The spawner later spends that bonus according to normal logistics rules.
- Match score and win condition remain untouched.

### Relationship To Current NPC War Spawn Rules

Current NPC War already has a lightweight version of emergency reinforcement:

- Small deficit: normal logistics.
- Medium deficit: drop pods become allowed.
- Severe deficit: drop pods take priority.

Evidence:

- Attrition percentage thresholds: `_gamemode_aitdm.nut:7`, `_gamemode_aitdm.nut:240`.
- Hardpoint percentage thresholds: `_gamemode_cp.nut:11`, `_gamemode_cp.nut:306`.
- CTF percentage thresholds: `_gamemode_ctf.nut:14`, `_gamemode_ctf.nut:272`.
- Current cap control: `sh_npc_war_settings.gnut:506`, `sh_npc_war_settings.gnut:525`.

### Suggested MVP

Do not build the full economy first.

If prototyped later:

1. One per-team reinforcement resource pool.
2. Dropship squad costs less.
3. Drop-pod squad costs more.
4. Resources do not change automatically based on score.
5. Severe deficit can spend pods faster, but only while resources last.
6. Add debug messages or optional UI so the player understands what happened.

## Future Mode: Solo Bounty Hunt, With NPC Opposition

Solo Bounty Hunt should be a separate future project or branch, but its goal is not to invent a replacement for Bounty Hunt.

The goal is literal Bounty Hunt made playable solo by adding opposing NPC bounty hunters into the existing Bounty Hunt framework. If the player starts Bounty Hunt alone today, there is no real opposing team. This idea fills that missing opponent role while preserving the mode's native identity.

### Design Target

Keep the existing Bounty Hunt systems:

- Existing wave and round flow.
- Existing neutral bounty AI and camps.
- Existing Bounty Titan events.
- Existing banks, bank timing, and deposit stakes.
- Existing carried and banked bounty economy.
- Existing score race and win condition.
- Existing Bounty Hunt UI wherever practical.

Add only what solo play lacks:

- One or more rival NPC bounty hunters on the opposing team.
- NPC-compatible bounty earning.
- NPC-compatible banking.
- Enough behavior for those NPCs to contest the player in the same score race.

The first prototype should feel like Bounty Hunt against an enemy team, not like a custom NPC War variant with Bounty Hunt flavor.

### Team Model

Bounty Hunt already uses `TEAM_BOTH` for neutral bounty AI. That is useful and should remain the mental model:

- Neutral bounty AI, camps, bosses, and Bounty Titans remain neutral enemies that both sides can fight.
- The player remains on a normal player team.
- Rival bounty hunters spawn on the opposing player team.
- Rival bounty hunters are hostile to the player and also hunt neutral bounty AI.

This keeps the base mode's triangle intact:

- Player hunts neutral bounties.
- Rival hunters hunt neutral bounties.
- Player and rival hunters can interfere with each other.
- Banks decide whether carried value becomes real team score.

### Rival NPC Bounty Hunters

Rival hunters are NPC stand-ins for missing human opponents. They should be custom NPC classes, similar in spirit to Grunt Mode's custom unit classes, but their purpose is to participate in Bounty Hunt's existing economy.

Possible classes:

- Prowler Handler:
  - Tough NPC hunter with a Prowler pet.
- Heavy Specialist:
  - Stronger weapons, armor, or anti-Titan equipment.
- Drone Specialist:
  - Support unit or drone assistant.
- Shield Captain Hunter:
  - Defensive hunter with shield support and escorts.
- Marksman Hunter:
  - Long-range hunter that avoids close combat.
- Runner/Collector:
  - Lower combat power, higher mobility, deposit-focused.
- Titan Contract Hunter:
  - Rare late-match hunter with Titan access or anti-Titan focus.

Each class should have a readable battlefield role, not just higher numbers.

### Rival Hunter Behavior

Simple behavior loop:

1. Spawn on the opposing team with a class identity.
2. Seek neutral bounty camps, boss targets, or high-value NPCs from the active Bounty Hunt wave.
3. Kill bounty targets and accumulate carried value through a simulated NPC-compatible version of Bounty Hunt's carried bonus.
4. If carrying enough value and a bank is open, move toward an active bank.
5. If threatened by the player, decide whether to fight, retreat, or keep banking.
6. If killed by the player, lose, drop, or transfer some carried value according to whatever Bounty Hunt-like rule feels best.

NPC bounty hunters do not need player-level decision making. Simple state rules are enough for a first version.

### NPC Deposit Rules

NPCs should not need player-style interaction prompts.

The target is not to rewrite `OnPlayerUseBank()`. The target is to add a small NPC banking layer that produces equivalent Bounty Hunt results for rival hunters.

Possible rules:

- Proximity Deposit:
  - If the hunter reaches a bank radius and survives for a few seconds, it deposits.
- Timed Upload:
  - The hunter must remain near the bank for a short channel time.
- Abstract Deposit:
  - Reaching a valid deposit area starts an internal timer.
- Courier Escape:
  - Some hunters flee to extraction instead of banking.

Recommended first version:

- Proximity deposit with a short timer.
- No prompt.
- No full player interaction system.
- Deposited value is added to the opposing team's Bounty Hunt score through the closest existing Bounty Hunt scoring path or a minimal equivalent.
- Optional visible upload effect later.

### Relationship To Frontier Contracts

Solo Bounty Hunt should not depend on Frontier Contracts for its base identity.

Its first job is to make existing Bounty Hunt playable solo with opposition. Frontier Contracts can later add optional side contracts, HVTs, credit purchases, or extra rewards on top of that, but those additions should not replace the vanilla Bounty Hunt score race.

This order matters:

1. Preserve Bounty Hunt.
2. Add rival NPC opposition.
3. Add NPC banking.
4. Only then consider optional Frontier Contracts integration.

### Evidence

- Neutral Bounty Hunt AI uses `TEAM_BOTH`: `_gamemode_at.nut:36`.
- Bounty Hunt registers player and NPC kill scoring callbacks: `_gamemode_at.nut:109`, `_gamemode_at.nut:110`, `_gamemode_at.nut:419`.
- Bounty Hunt wave and bank loop exists already: `_gamemode_at.nut:723`.
- Bounty Hunt camp spawning exists already: `_gamemode_at.nut:882`.
- Bounty Hunt banks and player deposits exist already: `_gamemode_at.nut:342`, `_gamemode_at.nut:1159`, `_gamemode_at.nut:1201`, `_gamemode_at.nut:1334`, `_gamemode_at.nut:1335`.
- Bounty Hunt carried and banked value already exists: `_gamemode_at.nut:614`, `_gamemode_at.nut:640`.
- NPC stolen bonus already exists as a related precedent: `_gamemode_at.nut:439`, `_gamemode_at.nut:488`, `_gamemode_at.nut:502`.
- Bounty boss support exists already: `_gamemode_at.nut:1568`, `_gamemode_at.nut:1624`, `_gamemode_at.nut:1635`, `_gamemode_at.nut:1710`.
- NPC steering exists: `_ai_soldiers.gnut:758`, `_ai_soldiers.gnut:781`.

### Suggested MVP

1. Fork or adapt Bounty Hunt while preserving its existing wave, bank, bounty, score, and win-condition flow.
2. Support one solo player.
3. Spawn one rival bounty hunter on the opposing player team.
4. Let the rival fight neutral Bounty Hunt AI and accumulate simulated carried bounty value.
5. Let the rival bank by standing near an active bank for a short timer.
6. Add banked rival value to the opposing team's Bounty Hunt score.
7. Let the player kill the rival to deny, drop, or steal carried value.
8. Keep camps, banks, Bounty Titans, and score flow as close to native Bounty Hunt as possible.

## Future Mode: Extraction Shooter

This is a larger standalone mode or branch.

### Vision

Home Base -> board shuttle -> load raid map -> dropship insertion -> loot/kill/objectives -> evac shuttle -> return Home Base -> save progress -> quit/resume later.

### Core Loop

1. Home Base loads and reads player profile JSON.
2. Player interacts with stash/loadout station.
3. Player chooses raid destination.
4. Mod writes pending raid state.
5. Server changes map to selected raid.
6. Player inserts by dropship.
7. Raid spawns enemy camps, patrols, loot crates, and objectives.
8. Player collects abstract loot and completes objectives.
9. Player reaches or calls evac.
10. If player boards evac, loot is committed to stash.
11. Pending raid state is cleared.
12. Server changes map back to Home Base.

### Save Model

Use mod-local JSON keyed by `player.GetUID()`.

Example:

```json
{
  "version": 1,
  "profile": {
    "level": 4,
    "xp": 1200,
    "currency": 850,
    "unlocks": ["pilot_ordnance", "smg_tier", "loadout_station"]
  },
  "stash": {
    "materials": {
      "alloy": 12,
      "electronics": 5
    },
    "weapons": ["mp_weapon_rspn101", "mp_weapon_r97"],
    "boosts": ["burnmeter_amped_weapons"]
  },
  "pendingRaid": null
}
```

### Raid Failure Rule

Extraction games need a strict incomplete-raid rule.

Recommended MVP rule:

- When a raid starts, carried gear and found loot are marked as pending.
- Extraction commits pending items into stash.
- Death, disconnect, crash, or quit before extraction counts as failure.
- On next Home Base load, uncleared pending state resolves as failed.

### Loot Design

Start abstract:

- Credits.
- Materials.
- Weapon unlock token.
- Boost token.
- Intel or quest item.

World representation:

- Interactable crates.
- Objective terminals.
- Boss drops.
- Camp-clear rewards.
- Bank/deposit stations.

Later:

- Actual weapon pickups.
- Weapon rarity.
- Insurance.
- Vendors.
- Crafting.
- Consumables.

### Bounty Hunt Concepts To Harvest

Bounty Hunt is a strong extraction inspiration:

- `TEAM_BOTH` neutral enemies can become third-party raid defenders.
- Banks can become secure upload stations or loot extraction kiosks.
- Carried bonus points map naturally to unsecured loot.
- NPC bonus stealing can become stolen loot carriers.
- Bounty Titans can become raid bosses.
- Camps can become enemy encampments or loot sites.

Evidence:

- `TEAM_BOTH`: `_gamemode_at.nut:36`.
- Banks: `_gamemode_at.nut:1159`, `_gamemode_at.nut:1201`.
- Carried and banked value: `_gamemode_at.nut:614`, `_gamemode_at.nut:640`.
- NPC stolen value: `_gamemode_at.nut:502`.
- Bounty Titans: `_gamemode_at.nut:1568`, `_gamemode_at.nut:1635`.

### Home Base MVP

- Stash crate.
- Loadout crate or station.
- Raid launch terminal.
- Optional progression terminal.
- Optional shooting lane.

### Raid MVP

- One existing multiplayer map.
- Dropship insertion.
- Three loot caches.
- One enemy camp.
- One optional HVT.
- One extraction zone.
- Evac shuttle.
- Save-on-extract.

### Evidence

- Persistence: `_testing.nut:98`, `sh_northstar_safe_io.gnut:9`, `sh_boost_store.gnut:165`.
- Map travel: `_private_lobby.gnut:197`, `_changemap.nut:38`.
- Evac: `_evac.gnut:215`, `_evac.gnut:365`, `_evac.gnut:497`.
- Interactables: `_loadout_crate.nut:162`, `_gamemode_at.nut:1201`.

### Known Risks

- Inventory/stash UI is the largest polish risk.
- Save migration must be designed early.
- Co-op extraction should wait until solo is stable.
- Starting with physical weapon loot is riskier than abstract loot.

## Future Mode: Fan-Made Campaign Framework

### Vision

Create a framework for Titanfall 2 fan-made single-player missions inside Northstar. The goal is not just one campaign, but a readable example that other modders can study and use for their own mission chains.

### Mission Loop

1. Start in a mission playlist or hub.
2. Spawn player through dropship or controlled spawn.
3. Assign mission objectives.
4. Spawn camps, patrols, setpiece attacks, or allied squads.
5. Track objective completion through interactables, triggers, kill callbacks, timers, or area control.
6. Call evac or complete the mission.
7. Save mission progress if needed.
8. Change map to next mission or hub.

### Core Systems

- Mission state manager.
- Objective registry.
- Objective marker/HUD messaging layer.
- Encounter/spawn manager.
- NPC patrol/guard helpers.
- Dropship insertion/evac helper.
- Campaign save profile.
- Map transition helper.
- Optional runtime loadout/progression filter.

### First Prototype

- One existing map.
- Dropship insertion.
- Objective 1: reach a marked position.
- Objective 2: clear an enemy camp.
- Objective 3: interact with a terminal.
- Objective 4: survive reinforcements.
- Objective 5: board evac.
- On evac, save completion and return to hub or lobby.

### Evidence

- Map travel: `_private_lobby.gnut:197`, `_changemap.nut:38`.
- Dropship intro: `_classic_mp_dropship_intro.gnut:147`.
- Evac: `_evac.gnut:215`, `_evac.gnut:365`.
- Interactables: `_loadout_crate.nut:162`, `_gamemode_at.nut:1201`.
- NPC steering: `_ai_soldiers.gnut:758`, `_ai_soldiers.gnut:781`.
- Kill callbacks: `_codecallbacks_common.gnut:414`.

### Known Risks

- Campaign-quality UI may be harder than mission logic.
- Custom maps may eventually be needed.
- NPC pathing depends heavily on map nav/path data.
- Co-op would multiply edge cases; solo should come first.

## Long-Term Research: Native AI And Convincing Pilot AI

This is the boss-level research track. It should not block NPC War, Frontier Contracts, Solo Bounty Hunt, Extraction Shooter, or campaign prototypes.

The dream is a convincing enemy Pilot AI: not human-equivalent, but more believable than a soldier with a Pilot model. A good version would use movement, cover, weapon swaps, grenades, rodeo behavior, dodges, elevation, and possibly limited tactical behavior in ways that feel intentional.

### Current Understanding

Northstar did not rewrite all Respawn AI from scratch in Squirrel. It exposes and restores enough AI settings, behavior selector data, script hooks, and spawning tools for the existing native engine NPC AI to work in multiplayer.

The visible layer includes:

- AI settings files.
- Behavior selector files.
- Script spawn helpers.
- Scripted objective steering.
- Loadout and weapon assignment.
- Team and faction setup.

The hidden layer likely lives in native binaries such as `server.dll`:

- `CAI_Combatant::SelectSchedule_ShootingCover`
- `CNPC_Titan::SelectSchedule_TitanCore`
- `SelectSchedule_RangeAttack`
- `SelectSchedule_RodeoAttack`
- `SelectSchedule_LongJump`
- `TASK_RANGE_ATTACK1`

We can use the exposed layer directly. We can only understand the hidden layer through black-box testing, logs, symbols/strings, and reverse engineering.

### First Target: npc_pilot_elite

Before reverse engineering anything, test `npc_pilot_elite`.

Why:

- It is a real native NPC class, not just a soldier wearing a Pilot model.
- It has a dedicated `pilot_elite` AI class.
- It has assassin, CQB, and sniper variants.
- Its behavior selector already includes promising schedules such as rodeo, cover, grenade, range attack, dodge, long jump, and sniping.

Open questions:

- Does it spawn reliably in multiplayer maps?
- Does it navigate normal MP navmesh well?
- Does it fight players well enough to be fun?
- Does it use vertical movement or only simple long-jump/dodge behavior?
- Does `canCloak` on assassin variants actually produce useful cloak behavior?
- Can it use offhand abilities beyond native grenade-like behavior?
- Can it be safely mixed into NPC War without disrupting squad logic?
- Does it count correctly for score, cleanup, evac, highlights, and callbacks?

Suggested black-box prototype:

1. Create a tiny test-only spawn command or debug setting.
2. Spawn one `npc_pilot_elite` against the player.
3. Spawn one `npc_pilot_elite_assassin`.
4. Spawn one CQB assassin.
5. Spawn one sniper assassin.
6. Test them on several maps with different elevation and cover.
7. Log whether they use cover, dodges, melee, grenades, long jumps, cloak, or rodeo.
8. Only after that, decide whether NPC War should ever use them as rare elite units.

Do not add them directly to normal NPC War until their behavior, scoring, and cleanup are understood.

### Reverse Engineering Track

This is only worth doing after script-level testing has clear unanswered questions.

The right question is not:

- "Understand all Respawn AI."

The right questions are narrow:

- What conditions make `npc_pilot_elite` choose `SelectSchedule_LongJump`?
- Does `npc_pilot_elite` have any native wallrun-related schedule?
- What does `SelectSchedule_RodeoAttack` require?
- What inputs make `SelectSchedule_ThrowGrenade` fire?
- Does `canCloak` only affect visibility state, or does it control a real tactical-like behavior?
- Can any native AI task activate Pilot-style offhand abilities?
- Why are some schedule lines commented out in MP behavior files?

Possible tools:

- Ghidra for static analysis and decompilation.
- IDA Free as an alternate static-analysis tool.
- x64dbg or WinDbg for dynamic debugging.
- Strings/FLOSS-style string extraction to find schedule names and class names.
- Process Monitor to observe file loading.
- Northstar logs and tiny script experiments to connect behavior-file changes to in-game outcomes.

Preservation and public-release boundary:

- Reverse-engineering server logic is a normal part of serious game-preservation and revival work.
- This research is in the same broad family as Northstar-style restoration work: understand enough of the native game to reconnect, preserve, or extend systems that already exist.
- Public NPC War releases should still stay script/data-only unless there is a deliberate preservation reason to do otherwise.
- Do not redistribute proprietary native code.
- Do not ship patched base-game binaries.
- Any research should feed back into clean scripts, AI settings, behavior selector choices, or documentation.

### Success Criteria

A successful Pilot AI research track does not need true human-like Pilots.

Good enough would be:

- Rare elite enemies that feel meaningfully different from grunts and spectres.
- Stronger cover, dodge, grenade, chase, and melee behavior.
- Occasional rodeo or anti-Titan behavior if reliable.
- Limited cloak behavior if assassin variants prove it works.
- Clear battlefield identity: sniper, CQB assassin, hunter, rival bounty pilot, or HVT.

Failure is also useful:

- If `npc_pilot_elite` is unstable or too limited, document that and keep NPC War focused on its current stronger battlefield simulation.

## Suggested Development Order

Do not treat this as a command queue. Pick the next item based on the current goal.

Recommended order:

1. Keep stabilizing NPC War core battle sandbox.
2. Keep documentation and README aligned with live behavior.
3. If building a new reusable layer, create Frontier Contracts as a separate mod with one HVT objective and no economy.
4. Add match-local credits only after the HVT objective loop feels good.
5. If logistics becomes a priority, prototype reinforcement resources inside NPC War separately from player economy.
6. If solo bounty gameplay becomes the priority, prototype existing Bounty Hunt with one rival NPC hunter and native bank flow.
7. If extraction becomes the priority, prototype Home Base plus one raid map with abstract loot.
8. Use proven extraction infrastructure as the foundation for campaign missions.
9. Treat native AI and convincing Pilot AI research as late-stage boss-level work, starting with `npc_pilot_elite` black-box tests before reverse engineering.

Reasoning:

- NPC War should stay stable first.
- Frontier Contracts proves side objectives without touching win conditions.
- Economy should not exist until objectives are fun.
- Reinforcement resources are faction logistics, not player credits.
- Solo Bounty Hunt tests NPC opposition inside an existing economy-first mode instead of inventing a new score loop.
- Extraction proves persistence, map travel, loot, and evac.
- Campaign builds on extraction travel/objective infrastructure.

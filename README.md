# NPC War 0.1.0

NPC War is a Titanfall 2 Northstar mod for large AI battlefield matches with normal customizable Pilot loadouts.

It is built from Grunt Mode 2. Full credit for the original battlefield structure, NPC classes, escalation foundation, scoring AI, and randomized grunt-war concept goes to EnderBoy9217 and VoyageDB_Modding_Home.

This mod was made mostly because I wanted to play Attrition, Hardpoints and CTF by myself, fully PvE, so I haven't tested this as a multiplayer mod at all, but I tried my best to make the NPC balancing is fair to both sides of the match, so it should work nice on Multiplayer.

NPC War's current intention is narrower than the future design notes in `docs/`: it is a battle sandbox first. It is not currently an economy mod, progression mod, extraction mode, field-objective framework, or campaign framework.

## Installation

Install the mod as a normal Northstar mod folder directly inside `R2Northstar/mods`.

Expected folder structure:

```text
Titanfall2/
  R2Northstar/
    mods/
      Aramundir-NPC-War/
        mod.json
        manifest.json
        mod/
        keyvalues/
        docs/
        README.md
```

Important:

- The folder containing `mod.json` must be `R2Northstar/mods/Aramundir-NPC-War/`.
- Do not leave the mod nested one folder too deep, such as `mods/Aramundir-NPC-War/Aramundir-NPC-War/mod.json`.
- Disable or remove the original Grunt Mode 2 while using NPC War. The two mods override many of the same script paths and are not compatible when enabled together.
- Disable or remove older local fork folders such as `AI_War_Pilot_Mode` if they are still present.
- Restart Northstar after installing or replacing the folder.

## Credits And Lineage

NPC War keeps clear lineage to Grunt Mode 2 while diverging toward a customizable Pilot-loadout AI battlefield sandbox.

- EnderBoy9217: original Grunt Mode 2 foundation.
- VoyageDB_Modding_Home: original Grunt Mode lineage and spawn-code work used by Grunt Mode 2.
- Aramundir: NPC War fork direction, design goals, and playtesting.
- Codex: implementation support for the NPC War fork.

## Supported Modes

The full NPC War behavior is currently built for:

- Attrition
- Amped Hardpoint
- Capture the Flag

Pilot Skirmish has compatibility/scoring hooks, but it is not the main NPC War experience.

## Core Player Behavior

This is one of NPC War's main changes from Grunt Mode 2: the player keeps their selected Pilot loadout instead of using Grunt Mode 2's randomized class-progression system.

`Grunt Movement` can be enabled in private match settings. When enabled, the player keeps their loadout but gets grunt-style movement limits: no double jump and no wallrunning. When disabled, the player has the full Pilot movement set.

`Tactical Ability`, `Ordnance`, and `Anti-Titan Weapon` can be enabled or disabled separately. These are sandbox restrictions for players who want custom gear visuals/loadouts without full Pilot capability.

Respawn theatrics are kept from Grunt Mode 2. The player prefers dropship respawns, with droppod fallback behavior when needed.

## Titan And Boost Settings

NPC War adds configurable player Titan and boost behavior so the player can choose between vanilla Pilot power and a more grunt-like sandbox.

`Titan Availability` defaults to `Post-Titan Threshold`.

- `Disabled`: no player Titan call-ins.
- `Vanilla`: normal Titanfall 2 Titan meter behavior from match start.
- `Post-Titan Threshold`: Titan meter is locked until the Titan/Pilot escalation threshold has been reached.

`Boost Availability` defaults to `Vanilla`.

- `Disabled`: boost rewards are disabled.
- `Vanilla`: normal Titanfall 2 boost meter behavior from match start.
- `Post-Titan Threshold`: boost meter behavior unlocks only after the Titan/Pilot escalation threshold has been reached.

`Boost Pool` defaults to `Vanilla`.

- `Vanilla`: boost names match their normal Northstar/Titanfall 2 effects.
- `Grunt Mode 2`: keeps the inherited Grunt Mode 2 boost payloads, where some boosts are repurposed into custom rewards such as the double-barrel shotgun, hacked Spectres, or a pet Reaper.

Boost Drops and Direct Grant boosts are not part of the current live design.

## NPC Decision-Making

Attrition mostly keeps Grunt Mode 2's battle behavior. Amped Hardpoint and CTF have NPC War-specific objective logic.

### Attrition

Infantry squads pick an enemy NPC as an assault focus, move toward that enemy's position, and periodically retarget every 5 to 15 seconds. This creates the moving battle line that makes Attrition feel like an AI war.

Titans use the same broad idea: find enemy forces, assault toward them, and retarget every 5 to 15 seconds.

Reapers are given high health and are kept visible to enemy players. They also use cleanup logic so isolated, unseen, unimportant NPCs can eventually be removed and free space for fresh reinforcements.

Attrition does not try to solve objectives because the objective is the battle itself: find enemies, fight, score, escalate.

Specialist drones use normal drone combat AI, but they keep a loose tactical leash to their Specialist. Every 5 to 15 seconds, a drone that has drifted too far in 2D is redirected toward its Specialist's current position. If it is close enough, it keeps fighting normally and may be nudged toward the Specialist's current target.

### Amped Hardpoint

Each squad or heavy unit registers an objective assignment. Every few seconds it scores the available hardpoints and chooses the best one. It usually keeps its current objective unless another point is meaningfully better, which prevents squads from thrashing back and forth too often.

The scoring considers:

- Distance to the hardpoint.
- Whether the point is owned, neutral, or enemy owned.
- Whether an owned point is being contested by enemies.
- Whether an owned point needs to be amped.
- Whether the enemy is amping a point.
- Whether a capture or amp is nearly complete.
- Whether allies or enemies are already present.
- Whether too many friendly squads are already assigned there.
- Whether the team owns no points.
- Whether this is the only remaining uncontrolled point.
- Whether the unit is a heavy unit.

Important behavior examples:

- If all hardpoints are enemy-owned, squads mostly prefer the nearest useful enemy-owned point. Any point is good when the team owns nothing, so distance matters heavily until map control starts changing.
- If a friendly point is contested, nearby squads are strongly encouraged to defend it.
- If a friendly point is safe but not amped, squads may go amp it.
- If the enemy is amping a point, squads consider interrupting it high priority.
- If a point is nearly captured or nearly amped by the squad's team, squads are encouraged to finish the job.
- The system avoids overcommitting too many squads to the same point unless that point is the only remaining uncontrolled point.

Heavy units use a larger objective radius and can help pressure hardpoints, but infantry remains the main capture/amp force.

### Capture The Flag

CTF gives infantry a flag-focused priority system. Soldiers, Spectres, and Stalkers can interact with flags. Titans, Reapers, and other heavy units can move toward flag objectives and fight around them, but do not pick up or return flags.

CTF objective priority is roughly:

1. If the enemy has your flag, chase the enemy flag carrier.
2. If your flag is dropped, move to recover it.
3. If this NPC is carrying the enemy flag, run home to capture.
4. If an allied NPC is carrying the enemy flag, move toward that carrier to support the run.
5. If the enemy flag is dropped, move to pick it up.
6. Otherwise, move toward the enemy flag.
7. If flags are unavailable, fall back to fighting enemy forces.

NPC infantry checks nearby flags frequently. If an NPC reaches the enemy flag and it is available, it can pick it up. If it reaches home while carrying the enemy flag and its own flag is home, it captures.

If an NPC carrier dies, it drops the flag.

AI flag returns are not instant. When an NPC reaches its own dropped flag, it starts a return hold. The flag is returned only if friendly flag-capable NPCs keep defending the dropped flag area for 10 seconds. If defenders are killed or leave the area, the return does not complete.

## Scoring And Escalation

NPC War currently keeps the core Grunt Mode 2 scoring and escalation foundation, while making thresholds configurable and removing forced Attrition match limits.

NPC kills can score for their team. Player kills also contribute to their team and personal assault score.

Escalation is score-threshold based and intentionally comeback-flavored. When one team scores enough points, stronger units become available for the opposing side. This is why enemy Spectres, Stalkers, Prowlers, Reapers, Gunships, Titans, and AI Pilots appear as the battle escalates.

Default escalation thresholds:

- Spectres/Marvins: 80
- Stalkers/Prowlers: 150
- Reapers: 250
- Gunships: 300
- Titans/AI Pilots: 500

These are configurable in `NPC War > Match Settings`.

NPC War removed the inherited Grunt Mode 2 Attrition score-limit and time-limit overrides. Match score limits and time limits now follow Northstar's standard private match `Match` settings instead of being forced by NPC War.

## Reinforcement Spawning And Budgets

NPC War keeps Grunt Mode 2's large battle concept, but exposes faction budgets and adds percentage-based emergency droppod refill behavior.

Baseline unit caps are controlled by faction budget settings. These are Militia/IMC settings, not player-team/enemy-team settings.

Current visible defaults:

- Militia Infantry Budget: 18
- IMC Infantry Budget: 18
- Militia Reaper Budget: 2
- IMC Reaper Budget: 2
- Militia Prowler Budget: 3
- IMC Prowler Budget: 3
- Militia Titan Budget: 0
- IMC Titan Budget: 0
- Militia AI Pilot Budget: 2
- IMC AI Pilot Budget: 2
- Militia Marvin Budget: 0
- IMC Marvin Budget: 0
- Militia Gunship Budget: 0
- IMC Gunship Budget: 0

If any budget value is set to `-1`, NPC War falls back to the underlying convar/default value for that unit type.

Budgets count only units spawned by NPC War for that population. The infantry budget counts Grunts and their specialist variants, Spectres, and Stalkers; independently budgeted Reapers, Prowlers, Titans, AI Pilots, Marvins, and Gunships do not consume infantry slots. Ability and Boost summons such as Specialist drones and Pet Reapers do not consume NPC War population budgets. Titans are the exception: all living Titans count against the Titan budget, including called, summoned, auto-controlled, and player-controlled Titans.

AI Pilots attempt to reach and embark their assigned Titans after Titanfall. If pathfinding prevents an AI Pilot from reaching its Titan within 15 seconds, the Titan leaves its shield and joins the battle autonomously while the Pilot resumes normal combat behavior.

Infantry reinforcement uses normal dropship-style spawning when the team is only lightly below cap. If a team's living infantry falls far enough below its cap, droppod reinforcement becomes more likely. If the deficit is severe, droppods are prioritized so a team that has been wiped does not sit empty while waiting for dropship cadence.

The droppod refill rules are percentage-based against the current cap, so they scale with custom infantry budgets instead of relying on one fixed number.

## NPC War Director

The Director is new in NPC War. Grunt Mode 2 does not have this layer.

The NPC War Director is optional and enabled by default. When enabled, it can dynamically adjust reinforcement pressure based on match state. Its individual capabilities can be enabled or disabled separately.

Director settings:

- `NPC War Director`: master toggle. If disabled, all Director behavior is disabled.
- `Comeback Infantry`: lets the Director add infantry budget to a team that is behind.
- `Hot Player Pressure`: adds one extra pressure level against a team with a high-impact player.
- `Hot Player Dampening`: reduces infantry budget from a high-impact player's team if that team is also leading hard.
- `Director Messages`: enables or disables in-game Director status messages.
- `Pressure Infantry Step`: infantry slots added or removed per pressure/dampening level. Default is 4.
- `Pressure Level 1 Score Gap`: score deficit needed for pressure level 1. Default is 75.
- `Pressure Level 2 Score Gap`: score deficit needed for pressure level 2. Default is 150.
- `Pressure Level 3 Score Gap`: score deficit needed for pressure level 3. Default is 250.
- `Reaper Pressure Bonus`: extra Reaper cap per pressure level. Default is 0.
- `Prowler Pressure Bonus`: extra Prowler cap per pressure level. Default is 0.
- `Titan Pressure Bonus`: extra Titan cap per pressure level. Default is 0.
- `AI Pilot Pressure Bonus`: extra AI Pilot cap per pressure level. Default is 0.
- `Gunship Pressure Bonus`: extra Gunship cap per pressure level. Default is 0.
- `Marvin Pressure Bonus`: extra Marvin cap per pressure level. Default is 0.

The Director recalculates pressure live. It is not a permanent boost.

For each team, pressure is based on that team's score deficit:

- Behind by Pressure Level 1 gap: pressure level 1.
- Behind by Pressure Level 2 gap: pressure level 2.
- Behind by Pressure Level 3 gap: pressure level 3.

If `Hot Player Pressure` is enabled, pressure can increase by 1 when the opposing team has a player whose personal assault score is at least 40 percent of that opposing team's score. This only starts checking after the opposing team has reached the Pressure Level 1 score gap. The final pressure value is capped at 4, so a hot player can push a level 3 comeback response one step higher.

Pressure affects infantry through `Comeback Infantry`:

```text
extra infantry cap = pressure level * Pressure Infantry Step
```

Pressure can also affect special units if their pressure bonus is above 0:

```text
extra special-unit cap = pressure level * that unit's Pressure Bonus
```

By default, all special-unit pressure bonuses are 0, so the Director only affects infantry unless configured otherwise.

Hot Player Dampening is separate from Hot Player Pressure. It never triggers from score lead alone. It only reduces infantry cap when `Hot Player Dampening` is enabled, that team is leading by enough points, and that team has a player whose personal assault score is at least 40 percent of that team's score.

- Leading by the Pressure Level 2 gap gives dampening level 1.
- Leading by the Pressure Level 3 gap gives dampening level 2.

```text
removed infantry cap = dampening level * Pressure Infantry Step
```

Hot-player dampening does not reduce special-unit caps.

When `Director Messages` is enabled, the Director can send in-game status messages when reinforcement pressure or dampening changes. Messages are rate-limited so they do not spam constantly.

The Director currently does not change escalation thresholds, force emergency unit spawns, or directly change score rewards. Spawn thresholds, match limits, and baseline faction budgets come from their own private match settings.

## Private Match Settings

NPC War groups its sandbox controls under a custom `NPC War` submenu in Private Match settings and exposes many values that were previously hardcoded or not player-facing.

### NPC War > Player Options

- `Grunt Movement`: enables or disables grunt-style movement limits for the player.
- `Titan Availability`: controls player Titan meter behavior.
- `Boost Availability`: controls when the boost meter is available.
- `Boost Pool`: controls whether boost activations use vanilla effects or inherited Grunt Mode 2 payloads.
- `Tactical Ability`: enables or removes the player's selected tactical ability.
- `Ordnance`: enables or removes the player's selected ordnance.
- `Anti-Titan Weapon`: enables or removes the player's anti-Titan main weapon slot.
- `Player Pilot Death Score`: score awarded to the enemy team when the player pilot dies. Default is 20.

### NPC War > Director

- Director master toggle.
- Comeback infantry.
- Hot player pressure.
- Hot player dampening.
- Director messages.
- Pressure score gaps.
- Infantry pressure step.
- Optional special-unit pressure bonuses.

### NPC War > Match Settings

- `Spectres Score`: score threshold for Spectres and Marvins.
- `Stalkers/Prowlers Score`: score threshold for Stalkers and Prowlers.
- `Reapers Score`: score threshold for Reapers.
- `Gunships Score`: score threshold for Gunships.
- `Titans/Pilots Score`: score threshold for Titans and AI Pilots.

Score limits and time limits come from Northstar's standard private match `Match` settings.

### NPC War > Reinforcement Budgets

- Militia/IMC infantry budget.
- Militia/IMC Reaper budget.
- Militia/IMC Prowler budget.
- Militia/IMC Titan budget.
- Militia/IMC AI Pilot budget.
- Militia/IMC Marvin budget.
- Militia/IMC Gunship budget.

## Epilogue

NPC War changes Epilogue to care about remaining forces, not only remaining pilots.

The losing side still gets an evac dropship. During Epilogue, living losing-side NPC forces are directed toward the evac area when possible. Gunships are excluded from evac pathing because they do not use normal ground assault behavior.

The winning side must clear remaining evac-side forces. Remaining NPCs are periodically revealed to the hunters so the match can finish instead of leaving unseen units hidden forever.

Living forces counted for Epilogue include:

- Players
- Soldiers
- Spectres
- Stalkers
- Reapers
- Titans
- Prowlers
- Marvins
- Gunships
- AI Pilots

## Not Currently Included

These ideas are not live NPC War features:

- Field objectives or HVT contracts.
- Player economy or progression.
- Boost Drops or Direct Grant boost rewards.
- Solo Bounty Hunt opposition.
- Extraction shooter flow.
- Campaign framework.

Future ideas live in `docs/future_mode_ideas.md` as design notes only.

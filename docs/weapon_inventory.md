# Weapon Inventory Notes

This is a practical inventory of weapon-like script references visible from the current Northstar workspace. It is generated from loose script/datatable references, not from a full unpack of every base-game VPK/RPAK asset.

Categories:

- `pilot-loadout`: present in `Northstar.CustomServers/mod/scripts/datatable/pilot_weapons.csv`.
- `titan-primary`: present in `Northstar.CustomServers/mod/scripts/datatable/titan_primary_weapons.csv`.
- `non-loadout-datatable`: present in `Northstar.CustomServers/mod/scripts/datatable/non_loadout_weapons.csv`.
- `boost-weapon-payload`: used as a boost weapon payload in `burn_meter_rewards.csv`.
- `northstar-custom-file`: loose weapon definition shipped by `Northstar.Custom`.
- `script-only/internal`: referenced by scripts or generated weapon data, but not confirmed as a normal player-facing loadout item.

## Normal Pilot Loadout Weapons

- `melee_pilot_arena`
- `melee_pilot_emptyhanded`
- `mp_weapon_alternator_smg`
- `mp_weapon_arc_launcher`
- `mp_weapon_autopistol`
- `mp_weapon_car`
- `mp_weapon_defender`
- `mp_weapon_dmr`
- `mp_weapon_doubletake`
- `mp_weapon_epg`
- `mp_weapon_esaw`
- `mp_weapon_g2`
- `mp_weapon_hemlok`
- `mp_weapon_hemlok_smg`
- `mp_weapon_lmg`
- `mp_weapon_lstar`
- `mp_weapon_mastiff`
- `mp_weapon_mgl`
- `mp_weapon_pulse_lmg`
- `mp_weapon_r97`
- `mp_weapon_rocket_launcher`
- `mp_weapon_rspn101`
- `mp_weapon_rspn101_og`
- `mp_weapon_semipistol`
- `mp_weapon_shotgun`
- `mp_weapon_shotgun_pistol`
- `mp_weapon_smr`
- `mp_weapon_sniper`
- `mp_weapon_softball`
- `mp_weapon_vinson`
- `mp_weapon_wingman`
- `mp_weapon_wingman_n`

## Interesting Hidden Or Non-Loadout Weapons

These are the first candidates for future field rewards, economy purchases, or custom objectives. They are visible to scripts, but each one still needs an in-game spawn/use test before being considered safe for release gameplay.

- `mp_weapon_shotgun_doublebarrel`: Northstar custom double-barrel shotgun. Grunt Mode 2 maps Smart Pistol boost to this.
- `mp_weapon_peacekraber`: Northstar custom weapon file.
- `mp_weapon_smart_pistol`: non-loadout datatable weapon, normally available as a boost.
- `mp_weapon_hard_cover`: boost payload.
- `mp_weapon_arc_trap`: hidden boost payload.
- `mp_weapon_frag_drone`: Tick boost payload.
- `mp_weapon_spectre_spawner`: non-loadout datatable weapon.
- `mp_ability_burncardweapon`: generic burncard activation weapon.
- `mp_ability_holopilot_nova`: boost payload.
- `mp_ability_turretweapon`: turret boost payload.
- `mp_turretweapon_sentry`: sentry turret weapon.
- `mp_turretweapon_blaster`: turret weapon.
- `mp_turretweapon_plasma`: turret weapon.
- `melee_pilot_kunai`: Northstar custom melee weapon file.
- `melee_pilot_sword`: script-visible pilot melee.
- `mp_titanweapon_predator_cannon`: normal Titanfall 2 Legion primary. Northstar.Custom includes a loose weapon file for patching/extensibility, but this is not a custom-only weapon.
- `mp_titanweapon_arc_cannon`: Northstar.Custom loose titan weapon file. Not listed as a normal Titanfall 2 titan primary in `titan_primary_weapons.csv`.
- `mp_titanweapon_triplethreat`: Northstar.Custom loose titan weapon file. Not listed as a normal Titanfall 2 titan primary in `titan_primary_weapons.csv`.

## Full Referenced Weapon-Like ID List

```text
melee_pilot_arena | pilot-loadout
melee_pilot_emptyhanded | pilot-loadout
melee_pilot_kunai | northstar-custom-file
melee_pilot_sword | script-only/internal
melee_prowler | script-only/internal
melee_spectre | script-only/internal
melee_superSpectre | script-only/internal
melee_titan | script-only/internal
melee_titan_punch | non-loadout-datatable
melee_titan_punch_fighter | non-loadout-datatable
melee_titan_punch_ion | non-loadout-datatable
melee_titan_punch_legion | non-loadout-datatable
melee_titan_punch_northstar | non-loadout-datatable
melee_titan_punch_scorch | non-loadout-datatable
melee_titan_punch_tone | non-loadout-datatable
melee_titan_punch_vanguard | non-loadout-datatable
melee_titan_sword | non-loadout-datatable
melee_titan_sword_aoe | non-loadout-datatable
mp_ability_arc_blast | non-loadout-datatable
mp_ability_burncardweapon | non-loadout-datatable, boost-weapon-payload
mp_ability_cloak | script-only/internal
mp_ability_grapple | script-only/internal
mp_ability_ground_slam | script-only/internal
mp_ability_heal | script-only/internal
mp_ability_holopilot | script-only/internal
mp_ability_holopilot_nova | non-loadout-datatable, boost-weapon-payload
mp_ability_pathchooser | script-only/internal
mp_ability_phase_rewind | script-only/internal
mp_ability_shifter | script-only/internal
mp_ability_shifter_super | script-only/internal
mp_ability_sonar | script-only/internal
mp_ability_swordblock | non-loadout-datatable
mp_ability_timeshift | script-only/internal
mp_ability_turretweapon | boost-weapon-payload
mp_titanability_ammo_swap | script-only/internal
mp_titanability_amped_wall | script-only/internal
mp_titanability_arc_field | script-only/internal
mp_titanability_basic_block | script-only/internal
mp_titanability_cloak | script-only/internal
mp_titanability_gun_shield | script-only/internal
mp_titanability_hover | script-only/internal
mp_titanability_laser_trip | script-only/internal
mp_titanability_nuke_eject | non-loadout-datatable
mp_titanability_particle_wall | script-only/internal
mp_titanability_phase_dash | script-only/internal
mp_titanability_power_shot | script-only/internal
mp_titanability_rearm | script-only/internal
mp_titanability_rocketeer_ammo_swap | script-only/internal
mp_titanability_slow_trap | script-only/internal
mp_titanability_smoke | script-only/internal
mp_titanability_sonar_pulse | script-only/internal
mp_titanability_tether_trap | script-only/internal
mp_titanability_timeshift | script-only/internal
mp_titanweapon_40mm | script-only/internal
mp_titanweapon_arc_ball | script-only/internal
mp_titanweapon_arc_cannon | northstar-custom-file
mp_titanweapon_arc_minefield | script-only/internal
mp_titanweapon_arc_pylon | script-only/internal
mp_titanweapon_arc_wave | script-only/internal
mp_titanweapon_at_mine | script-only/internal
mp_titanweapon_berserker | script-only/internal
mp_titanweapon_cabertoss | script-only/internal
mp_titanweapon_dumbfire_rockets | script-only/internal
mp_titanweapon_electric_fist | script-only/internal
mp_titanweapon_emp_volley | script-only/internal
mp_titanweapon_flame_ring | script-only/internal
mp_titanweapon_flame_wall | script-only/internal
mp_titanweapon_flightcore_rockets | non-loadout-datatable
mp_titanweapon_heat_shield | script-only/internal
mp_titanweapon_homing_rockets | script-only/internal
mp_titanweapon_jackhammer | script-only/internal
mp_titanweapon_laser_lite | script-only/internal
mp_titanweapon_leadwall | titan-primary
mp_titanweapon_meteor | titan-primary
mp_titanweapon_meteor_thermite | script-only/internal
mp_titanweapon_meteor_thermite_charged | script-only/internal
mp_titanweapon_multi_cluster | script-only/internal
mp_titanweapon_orbital_strike | non-loadout-datatable
mp_titanweapon_particle_accelerator | titan-primary
mp_titanweapon_predator_cannon | titan-primary, northstar-custom-file
mp_titanweapon_predator_cannon_siege | non-loadout-datatable
mp_titanweapon_rocket_launcher | script-only/internal
mp_titanweapon_rocketeer_missile | script-only/internal
mp_titanweapon_rocketeer_rocketstream | titan-primary, non-loadout-datatable
mp_titanweapon_salvo_rockets | script-only/internal
mp_titanweapon_shoulder_grenade | script-only/internal
mp_titanweapon_shoulder_rockets | non-loadout-datatable
mp_titanweapon_smash | script-only/internal
mp_titanweapon_sniper | titan-primary
mp_titanweapon_sticky_40mm | titan-primary
mp_titanweapon_stun_laser | script-only/internal
mp_titanweapon_sword | script-only/internal
mp_titanweapon_tether_shot | script-only/internal
mp_titanweapon_tracker_rockets | script-only/internal
mp_titanweapon_triple_threat | script-only/internal
mp_titanweapon_triplethreat | northstar-custom-file
mp_titanweapon_vortex_shield | script-only/internal
mp_titanweapon_vortex_shield_ion | script-only/internal
mp_titanweapon_xo16 | script-only/internal
mp_titanweapon_xo16_shorty | titan-primary
mp_titanweapon_xo16_vanguard | titan-primary
mp_titanweapon_xopistol | script-only/internal
mp_turretweapon_blaster | non-loadout-datatable
mp_turretweapon_plasma | non-loadout-datatable
mp_turretweapon_rockets | script-only/internal
mp_turretweapon_sentry | non-loadout-datatable
mp_weapon_alternator_smg | pilot-loadout
mp_weapon_arc_blast | script-only/internal
mp_weapon_arc_launcher | pilot-loadout
mp_weapon_arc_rifle | script-only/internal
mp_weapon_arc_trap | non-loadout-datatable, boost-weapon-payload
mp_weapon_arena1 | script-only/internal
mp_weapon_arena2 | script-only/internal
mp_weapon_arena3 | script-only/internal
mp_weapon_autopistol | pilot-loadout
mp_weapon_car | pilot-loadout
mp_weapon_dash_melee | script-only/internal
mp_weapon_defender | pilot-loadout
mp_weapon_deployable_cloakfield | script-only/internal
mp_weapon_deployable_cover | script-only/internal
mp_weapon_dmr | pilot-loadout
mp_weapon_doubletake | pilot-loadout
mp_weapon_dronebeam | script-only/internal
mp_weapon_droneplasma | script-only/internal
mp_weapon_dronerocket | script-only/internal
mp_weapon_engineer_combat_drone | script-only/internal
mp_weapon_engineer_turret | script-only/internal
mp_weapon_engineer_turret_rocket | script-only/internal
mp_weapon_epg | pilot-loadout
mp_weapon_esaw | pilot-loadout
mp_weapon_flak_rifle | script-only/internal
mp_weapon_frag_drone | boost-weapon-payload
mp_weapon_frag_grenade | script-only/internal
mp_weapon_g2 | pilot-loadout
mp_weapon_g3 | script-only/internal
mp_weapon_g4 | script-only/internal
mp_weapon_g5 | script-only/internal
mp_weapon_gibber_pistol | script-only/internal
mp_weapon_grenade_electric_smoke | script-only/internal
mp_weapon_grenade_emp | script-only/internal
mp_weapon_grenade_gravity | script-only/internal
mp_weapon_grenade_sonar | script-only/internal
mp_weapon_gunship_launcher | script-only/internal
mp_weapon_gunship_missile | script-only/internal
mp_weapon_gunship_turret | script-only/internal
mp_weapon_hard_cover | non-loadout-datatable, boost-weapon-payload
mp_weapon_hemlok | pilot-loadout
mp_weapon_hemlok_smg | pilot-loadout
mp_weapon_laser_mine | script-only/internal
mp_weapon_lmg | pilot-loadout
mp_weapon_lstar | pilot-loadout
mp_weapon_mastiff | pilot-loadout
mp_weapon_mega_turret | script-only/internal
mp_weapon_mega_turret_aa | script-only/internal
mp_weapon_mgl | pilot-loadout
mp_weapon_npc_rocket_launcher | script-only/internal
mp_weapon_nuke_satchel | script-only/internal
mp_weapon_peacekraber | northstar-custom-file
mp_weapon_proximity_mine | script-only/internal
mp_weapon_pulse_lmg | pilot-loadout
mp_weapon_r97 | pilot-loadout
mp_weapon_rocket_launcher | pilot-loadout
mp_weapon_rspn101 | pilot-loadout
mp_weapon_rspn101_og | pilot-loadout
mp_weapon_rspn102 | script-only/internal
mp_weapon_satchel | script-only/internal
mp_weapon_semipistol | pilot-loadout
mp_weapon_shotgun | pilot-loadout
mp_weapon_shotgun_doublebarrel | northstar-custom-file
mp_weapon_shotgun_pistol | pilot-loadout
mp_weapon_smart_pistol | non-loadout-datatable
mp_weapon_smr | pilot-loadout
mp_weapon_sniper | pilot-loadout
mp_weapon_softball | pilot-loadout
mp_weapon_spectre_spawner | non-loadout-datatable
mp_weapon_super_spectre | script-only/internal
mp_weapon_sword | script-only/internal
mp_weapon_tether | script-only/internal
mp_weapon_thermite_grenade | script-only/internal
mp_weapon_tripwire | script-only/internal
mp_weapon_turret_tday | script-only/internal
mp_weapon_turretlaser | script-only/internal
mp_weapon_turretlaser_mega | script-only/internal
mp_weapon_turretlaser_mega_fort_war | script-only/internal
mp_weapon_turretplasma | script-only/internal
mp_weapon_turretplasma_mega | script-only/internal
mp_weapon_turretrockets | script-only/internal
mp_weapon_vinson | pilot-loadout
mp_weapon_wingman | pilot-loadout
mp_weapon_wingman_n | pilot-loadout
mp_weapon_yh803 | script-only/internal
mp_weapon_yh803_bullet | script-only/internal
mp_weapon_yh803_bullet_overcharged | script-only/internal
mp_weapon_zipline | script-only/internal
proto_viewmodel_test | non-loadout-datatable
```

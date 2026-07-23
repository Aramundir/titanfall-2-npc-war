# Balance Telemetry

NPC War keeps lightweight balance telemetry for all three supported modes: Attrition, Hardpoint, and Capture the Flag. It does not evaluate alternative decision strategies, score objective candidates, or change NPC orders.

Population and reinforcement records run in every supported mode. Hardpoint additionally records territory and squad-assignment fields.

`Balance Telemetry` is enabled by default under `NPC War > Diagnostics` and can be disabled when logs are not needed.

## Records

`NPCWAR_BALANCE_SNAPSHOT` is printed once per team every ten seconds. It contains:

- Gamemode, team, and enemy score
- Living infantry and effective infantry cap
- Living Reapers, Prowlers, MARVINs, gunships, Titans, and marked AI Pilots
- Total tracked battlefield population for the team
- Director pressure and dampening
- In Hardpoint, active tracked squad count plus owned and fully amped Hardpoint counts

In Hardpoint, `NPCWAR_BALANCE_MATCH_SUMMARY` records final scores and match-wide averages for owned and amped territory, plus full-control and zero-control sample counts.

`NPCWAR_REINFORCEMENT` records each normal dropship or emergency droppod dispatch with its gamemode, team, delivery method, living infantry, effective cap, deficit, pressure, and dampening.

Useful log searches:

```text
NPCWAR_BALANCE_SNAPSHOT
NPCWAR_BALANCE_MATCH_SUMMARY
NPCWAR_REINFORCEMENT
```

The older decision-level telemetry, utility shadow strategy, and synthetic scenario harness were removed after the Hardpoint strategy was selected. Their methodology and results remain in `hardpoint_testing_report.md`. The separate exploratory Director and reinforcement observations are preserved in `hot_player_pressure_testing_report.md`.

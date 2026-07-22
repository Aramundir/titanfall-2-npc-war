# Balance Telemetry

NPC War keeps lightweight Amped Hardpoint telemetry for balance work. It does not evaluate alternative decision strategies, score objective candidates, or change NPC orders.

Territory snapshots only run when the mode has valid Hardpoint entities. Modes without territory objectives are ignored rather than being recorded as permanent zero-control states.

`Balance Telemetry` is enabled by default under `NPC War > Diagnostics` and can be disabled when logs are not needed.

## Records

`NPCWAR_BALANCE_SNAPSHOT` is printed once per team every ten seconds. It contains:

- Team and enemy score
- Living infantry and effective infantry cap
- Living Reapers, Prowlers, Titans, and marked AI Pilots
- Director pressure and dampening
- Active tracked squad count
- Owned and fully amped Hardpoint counts

`NPCWAR_BALANCE_MATCH_SUMMARY` records final scores and match-wide averages for owned and amped territory, plus full-control and zero-control sample counts.

`NPCWAR_REINFORCEMENT` records each normal dropship or emergency droppod dispatch with its team, delivery method, living infantry, effective cap, deficit, pressure, and dampening.

Useful log searches:

```text
NPCWAR_BALANCE_SNAPSHOT
NPCWAR_BALANCE_MATCH_SUMMARY
NPCWAR_REINFORCEMENT
```

The older decision-level telemetry, utility shadow strategy, and synthetic scenario harness were removed after the Hardpoint strategy was selected. Their methodology and results remain in `hardpoint_testing_report.md`.

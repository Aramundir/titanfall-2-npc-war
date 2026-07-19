# Hardpoint Decision Telemetry

NPC War can observe Amped Hardpoint squad decisions without changing the orders used by the match. Both diagnostic settings default to `Off` under `NPC War > Diagnostics`.

## Telemetry Modes

- `Off`: no diagnostic work or log output.
- `Summary`: prints one `NPCWAR_CP_SNAPSHOT` record per team every 10 seconds.
- `Detailed`: includes summary records, every `NPCWAR_CP_DECISION`, and every scored `CP AI candidate` record.

Each snapshot contains both teams' scores, the effective infantry cap, Director pressure and dampening, active squad count, owned and amped points, commitment coverage, assignment surplus and concentration, cumulative decisions, objective switches, shadow-strategy disagreements, and each point's detailed state.

At match end, `NPCWAR_CP_MATCH_SUMMARY` prints cumulative strategic results for each team: average control and amped control, full- and zero-control samples, assigned and practical commitment coverage, surplus assignments, concentration, decisions, switches, and shadow disagreements.

When telemetry is enabled, `NPCWAR_REINFORCEMENT` records every normal dropship or emergency droppod dispatch with the team, alive infantry, effective cap, deficit, pressure, and dampening. This separates decision quality from reinforcement availability when diagnosing a win or loss.

Each decision contains the team, squad identifier, heavy-unit flag, current objective, issued objective, utility-only shadow objective, and squad position. A shadow disagreement means the strategic commitment prepass changed what the utility scorer alone would have selected. Shadow choices never issue orders.

Useful log searches:

```text
NPCWAR_CP_SNAPSHOT
NPCWAR_CP_DECISION
NPCWAR_CP_MATCH_SUMMARY
NPCWAR_REINFORCEMENT
CP AI candidate
NPCWAR_CP_TESTS
NPCWAR_CP_TEST_FAIL
```

## Scenario Tests

Set `Hardpoint Scenario Tests` to `Run Once`, start Amped Hardpoint, and inspect the log. The suite checks eight canonical and mirrored commitment states, 200 randomized state invariants, and six complete eight-squad battlefield scenarios across 24 deterministic variants. A clean run ends with:

```text
NPCWAR_CP_TESTS cases=352 failures=0
```

The full-team scenarios cover owned unamped positions, completed owned positions, two enemy points amping at once, contested defense, total loss of map control, and an all-owned position becoming contested. Variants change squad decision order and apply deterministic position jitter.

Each scenario prints three `NPCWAR_CP_SCENARIO` comparisons:

- `utility`: the utility scorer with no minimum-commitment prepass.
- `current`: the live minimum-commitment strategy followed by utility scoring.
- `strong_saturation`: utility-only scoring with twice the normal overcommitment penalty, including on the only remaining uncontrolled point.

Reports include coverage failures, full-concentration failures, average squad allocation per point, and average objective switches. Only failures from `current` count against the final suite verdict. The other strategies are shadow comparisons, not expected answers.

Synthetic and live utility decisions call the same entity-free scoring function. The harness constructs plain decision snapshots while the live mode builds equivalent snapshots from game entities.

## Comparison Workflow

1. Keep gameplay settings and map fixed.
2. Run multiple matches with telemetry at `Summary`; use `Detailed` only for short investigations because it is noisy.
3. Compare point exposure, assignment concentration, objective-switch totals, and shadow disagreements at equivalent match phases.
4. Use detailed records to explain suspicious snapshots before changing weights.
5. Add a scenario test for every confirmed failure before adjusting the live strategy.

The current shadow strategy is utility-only scoring. The live strategy first fills minimum strategic commitments, then uses that same utility scorer for surplus squads. This allows direct measurement of how often the safeguard changes behavior without running two separate matches.

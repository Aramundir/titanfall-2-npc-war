# NPC War Hardpoint AI Strategy Report

## Status

This investigation is complete. NPC War kept the combined minimum-commitment and utility strategy. The decision-level telemetry, shadow comparisons, and automated scenario harness were subsequently removed from the runtime mod; this document preserves what they tested and what their results support.

This report evaluates Hardpoint decision-making only. The separate exploratory investigation of Hot Player Pressure and reinforcement balance is recorded in `hot_player_pressure_testing_report.md`.

## Question

NPC War gives AI squads strategic objectives in Amped Hardpoint. The problem was to retain cohesive and somewhat unpredictable behavior without allowing obvious strategic failures such as:

- Abandoning owned points before they are amped
- Leaving an urgent enemy amp completely unanswered
- Sending the entire army to one objective while another necessary commitment is uncovered
- Spreading so conservatively that the AI never forms a decisive attack

The investigated question was whether fixed allocation rules, utility scoring, or a combination of both best satisfied those requirements.

## Decision Model

The live AI and automated harness used the same entity-free utility function. Game entities were converted into decision snapshots containing:

- Hardpoint owner and capping team
- Capture and amp progress
- Squad distance
- Assigned squads and practical nearby coverage
- Friendly and enemy presence
- Current squad objective
- Number of owned and uncontrolled points

This reduced the risk that the harness merely approximated different logic. It did not eliminate the usual limitation of developer-authored tests: the scenarios and assertions represented the behaviors the implementation was designed to protect.

## Strategies Compared

Three strategies evaluated each synthetic battlefield:

1. **Utility only:** Weighted scoring with no mandatory allocation pass.
2. **Minimum commitments plus utility:** Satisfies small mandatory strategic commitments first, then assigns surplus squads through utility scoring.
3. **Strong saturation:** Utility scoring with a stronger penalty for assigning additional squads to an already-covered objective.

Only the combined strategy controlled live NPCs. The alternatives were synthetic and shadow comparisons; they never controlled a live cohort. The report therefore supports a comparative decision-model result, not a live randomized comparison between strategies.

### Utility Only

Utility-only selection was fluid and allowed organic concentration. Its recurring failure was coordination: independent squads could make the same locally reasonable choice and collectively neglect owned unamped points or urgent enemy amps.

### Minimum Commitments Plus Utility

The combined strategy reserved only the force required for urgent work:

- One squad for an owned point that still needed amping
- Two squads for an owned contested point or an enemy point actively amping
- One squad for an ordinary uncontrolled point

Surplus squads remained free to mass, reinforce, or change objectives through utility scoring.

### Strong Saturation

Strong saturation prevented full concentration, but it frequently retained squads around safe completed positions when those squads could have strengthened an attack. It produced balanced-looking distributions at the cost of decisiveness.

## Automated Scenarios

The retired suite executed 352 checks:

- Eight canonical and mirrored commitment checks
- 200 randomized commitment-state invariants
- Six complete eight-squad battlefield scenarios
- 24 deterministic variants of each full-team scenario

Variants changed squad decision order, reversed order on alternating runs, and applied controlled position jitter. Assertions tested strategic properties rather than requiring one exact formation.

The full-team scenarios covered:

- Owning A and C while both still needed amping
- Owning A and C after both were fully amped
- Enemy-controlled A and C actively amping
- An owned point becoming contested
- Having no foothold on the map
- Owning all points when one became contested

## Comparative Result

In the original failure scenario, the team owned A and C, both needed amping, and B was enemy-controlled:

| Strategy | Coverage failures | Average A | Average B | Average C |
|---|---:|---:|---:|---:|
| Utility only | 22/24 | 0.92 | 7.00 | 0.08 |
| Minimum commitments plus utility | 0/24 | 1.00 | 6.00 | 1.00 |
| Strong saturation | 0/24 | 2.17 | 3.50 | 2.33 |

Utility only reproduced the uncovered-objective failure in 22 of 24 variants. The combined strategy assigned one squad to finish each owned point and sent the remaining six to attack B.

After A and C became fully amped, the combined strategy sent all eight squads to B. Strong saturation retained an average of 1.38 squads at each completed point, demonstrating the passivity introduced by its stronger anti-concentration weight.

The complete harness reported:

```text
NPCWAR_CP_TESTS cases=352 failures=0
```

This means the selected strategy satisfied the 352 encoded invariants. It does not independently prove optimal play or superior match balance.

## Live Observational Check

Five recorded Hardpoint matches used the same combined live strategy for both factions. Those matches cannot compare decision algorithms or establish that one faction had smarter AI. They can test whether the deployed strategy exhibited the specific abandonment failure it was intended to prevent.

Strict abandonment was defined as an owned, unamped point with:

- Zero assigned squads
- Zero practical nearby coverage

Across the five matches:

- 871 owned-point samples were inspected at ten-second intervals.
- 35 samples met the strict definition, a 4.0% sampled rate.
- Those samples formed 33 incidents.
- No incident lasted 30 seconds or longer.
- The longest observed incident was approximately 20 seconds.
- Most incidents appeared in only one snapshot.

Owned points sometimes remained below full amp for longer periods while squads were assigned or physically present. Those cases are consistent with travel, combat, deaths, or contesting and were not counted as decision-level abandonment.

The live sample supports the narrow conclusion that sustained abandonment was uncommon under the selected strategy. Because there was no live alternative-strategy cohort, it does not establish comparative live superiority.

## Limitations

- The synthetic scenarios were selected by the developers and encode intended strategic properties.
- Passing every assertion demonstrates consistency with those properties, not globally optimal Hardpoint play.
- Alternative strategies were not given live cohorts.
- Live matches contained uncontrolled combat, travel, spawning, player performance, population, and Director effects.
- Territory ownership and match wins are balance outcomes, not direct measurements of decision quality.
- Both factions used identical decision code, so faction differences cannot be attributed to different intelligence.

## Decision

The combined strategy remains live because it provided the best result within the tested decision model:

- It protected urgent minimum coverage more reliably than utility-only selection.
- It remained more decisive than strong saturation.
- It allowed surplus forces to concentrate for major attacks.
- It allowed a team with no foothold to concentrate on one nearby objective.
- The recorded live sample did not show sustained abandonment.

This is a bounded engineering decision, not a claim that the strategy is optimal. Further strategy tuning should begin only when new live evidence identifies a repeatable decision failure. Population balance, reinforcement flow, and Director behavior should be investigated separately.

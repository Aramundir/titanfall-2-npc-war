# NPC War Hardpoint AI Testing Report

## Status

This experiment is complete. NPC War kept the combined minimum-commitment and utility strategy. The decision-level telemetry, utility shadow comparison, and automated scenario harness were subsequently removed from the runtime mod; this document preserves their design and results.

## Goal

NPC War gives AI squads strategic objectives in Amped Hardpoint. We wanted the AI to remain cohesive and somewhat unpredictable without allowing obviously bad behavior such as abandoning owned points before they are amped or sending the entire army to one objective while another urgent objective is uncovered.

The immediate question was whether this should be solved through fixed allocation rules, utility scoring, or a combination of both.

## Shared Decision Model

During the experiment, the live AI and automated tests used the same entity-free utility-scoring function. Game entities were converted into plain decision snapshots containing:

- Hardpoint owner and capping team
- Capture and amp progress
- Squad distance
- Assigned squads and practical nearby coverage
- Friendly and enemy presence
- Current squad objective
- Number of owned and uncontrolled points

This prevented the test harness from becoming a separate imitation of the actual AI logic.

## Strategies Compared

Every synthetic battlefield was evaluated by three strategies:

1. **Utility only:** Uses weighted scoring with no mandatory allocation pass.
2. **Current strategy:** Fills minimum strategic commitments first, then gives surplus squads to the utility scorer.
3. **Strong saturation:** Uses utility scoring with a stronger penalty for committing additional squads to an already-covered objective.

Only the combined strategy ever controlled live NPCs. The alternatives ran as shadow comparisons and never issued orders.

### Candidate Assessment

**Utility only** was the most fluid and least prescriptive candidate. Distance, objective state, friendly and enemy presence, current orders, and saturation all influenced squad choices. Its strength was organic concentration and variation. Its failure was that independent squads could make the same locally reasonable choice, causing nearly the whole army to attack one point while owned points remained unamped or urgent enemy amps went unanswered.

**Combined minimum commitments plus utility** first reserved the smallest force needed for urgent strategic work, then let every surplus squad use the utility scorer. It guaranteed one squad for an owned point that still needed amping, two for an owned contested point or an enemy point actively amping, and one for an ordinary uncontrolled point. Its strength was strategic coherence without prescribing the entire formation. Its tradeoff was a small amount of forced allocation, but surplus squads still retained freedom to mass, reinforce, or change objectives.

**Strong saturation** remained entirely utility-driven but doubled the penalty for sending more squads to an already-covered point. It successfully spread forces and protected against full concentration. Its failure was excessive caution: it continued distributing squads around safe, completed positions when concentrating those squads into an attack was the stronger choice. It made behavior balanced-looking but less decisive.

## Automated Scenarios

The retired suite executed **352 checks**:

- Eight canonical and mirrored commitment checks
- 200 randomized commitment-state invariants
- Six complete eight-squad battlefield scenarios
- 24 deterministic variants of every full-team scenario

Variants change squad decision order, reverse the order on alternating runs, and apply controlled position jitter. This tests sensitivity to asynchronous squad decisions without making results irreproducible.

The full-team scenarios include:

- Owning A and C while both still need amping
- Owning A and C after both are fully amped
- Enemy-controlled A and C actively amping
- An owned point becoming contested
- Having no foothold on the map
- Owning all points when one becomes contested

Tests assert strategic properties rather than one exact formation. Examples include required urgent coverage and protection against full-army concentration when multiple objectives require attention.

## Key Automated Result

In the original failure scenario, the team owns A and C, both need amping, and B is enemy-controlled:

| Strategy | Coverage failures | Average A | Average B | Average C |
|---|---:|---:|---:|---:|
| Utility only | 22/24 | 0.92 | 7.00 | 0.08 |
| Current | 0/24 | 1.00 | 6.00 | 1.00 |
| Strong saturation | 0/24 | 2.17 | 3.50 | 2.33 |

The utility-only strategy reproduced the undesirable behavior. The current strategy reliably assigned one squad to finish each owned point and committed the remaining six to the attack.

After A and C were fully amped, the current strategy committed all eight squads to B. The strong-saturation alternative retained an average of 1.38 squads at both completed points, suggesting that excessive anti-concentration pressure can make the AI unnecessarily passive.

The complete automated run finished with:

```text
NPCWAR_CP_TESTS cases=352 failures=0
```

## Experimental Telemetry

During testing, the game could record two decision-telemetry levels:

- **Summary:** One battlefield snapshot per team every ten seconds
- **Detailed:** Summary data plus every squad decision and candidate score

Snapshots reported active tracked squads, objective switches, shadow-strategy disagreements, point state, assignments, practical coverage, and desired commitment. Detailed records identified the selected objective and what utility-only scoring would have selected.

This instrumentation was intentionally temporary. It has been replaced by lightweight balance telemetry that records scores, caps, Director state, squad population, territory, and reinforcement dispatches without evaluating decisions.

## Live A/B Session

This session holds the map and gameplay settings constant while comparing two three-match cohorts. Cohort A enables Hot Player Pressure; Cohort B disables only Hot Player Pressure. A later enabled-pressure retest is recorded separately from the original cohorts. Each match gets its own record so individual outcomes remain visible before any aggregate conclusion is drawn.

### Cohort A: Hot Player Pressure Enabled

### Match 1

Source log: `nslog2026-07-19 13-41-24.txt`

Conditions:

- Militia infantry budget: 14
- IMC infantry budget: 18
- Director: enabled
- Result: Militia/player loss
- Samples: 61 snapshots per team, approximately 10 seconds apart
- Automated suite: 352 checks, 0 failures
- Script errors: none

#### Strategic Outcome

| Metric | IMC | Militia |
|---|---:|---:|
| Average owned Hardpoints | 1.52 | 1.34 |
| Full-control snapshots | 9, about 90 seconds | 3, about 30 seconds |
| Zero-control snapshots | 5, about 50 seconds | 11, about 110 seconds |
| Owned and fully amped point samples | 22 | 18 |
| Required commitments satisfied by assigned squads | 84.9% | 76.9% |
| Required commitments satisfied by practical nearby coverage | 54.8% | 54.9% |
| Surplus squad assignments beyond desired commitments | 88 | 100 |
| Average share assigned to the most crowded point | 51.8% | 54.3% |
| Squad decisions by final snapshot | 380 | 322 |
| Objective switches by final snapshot | 65 | 83 |
| Utility-shadow disagreements by final snapshot | 54 | 54 |

IMC produced the stronger strategic result: it held more territory on average, achieved full control three times as often, spent half as long with no territory, and met the strategy's planned assignments more reliably. Both teams had effectively identical practical coverage, however. Since both factions execute the same decision code, this does not show that IMC had smarter AI. It suggests that IMC had enough available squads to express the strategy more consistently, while Militia orders more often failed to become timely physical presence.

Militia also switched objectives more often despite making fewer decisions, accumulated more surplus assignments, and concentrated a slightly larger share of its assigned squads on one point. Those are possible symptoms of fighting from a weaker and less stable battlefield position, not yet proof of a scoring defect.

#### Reinforcement Outcome

The legacy log recorded 42 emergency droppod refills:

| Team | Droppod refills |
|---|---:|
| IMC | 31 |
| Militia | 11 |

Observed effective infantry-cap periods:

| Team and cap | Droppod events | Observed period |
|---|---:|---|
| IMC 18 | 6 | Early match |
| IMC 22 | 25 | Approximately 13:46:26 to 13:53:22 |
| Militia 14 | 9 | Most of the match |
| Militia 18 | 2 | Approximately 13:52:10 to 13:52:19 |

Typical emergency refill states were approximately `16/22` for IMC and `10/14` for Militia. In practical terms, the nominal `14 vs 18` test spent much of its decisive period at `14 vs 22`; Militia only received its four-slot pressure increase late. This is the strongest current explanation for why IMC executed the same strategic rules more reliably and ultimately won.

#### Historical Telemetry Limits

Match 1 predates the expanded telemetry. It does not directly record score progression, Director pressure and dampening per snapshot, structured dropship dispatches, or a final match summary. Effective-cap periods above were reconstructed from droppod messages. Matches 2-5 will record those values directly.

### Match 2

Source log: `nslog2026-07-19 17-59-50.txt`

Conditions:

- Map: Colony (`mp_colony02`)
- Militia infantry budget: 14
- IMC infantry budget: 18
- Director: enabled
- Result: Militia/player loss, IMC 329 to Militia 278
- Score margin: 51
- Samples: 61 snapshots per team, approximately 10 seconds apart
- Script errors: none

#### Strategic Outcome

| Metric | IMC | Militia |
|---|---:|---:|
| Final score | 329 | 278 |
| Average owned Hardpoints | 1.52 | 1.36 |
| Average owned and fully amped Hardpoints | 0.38 | 0.33 |
| Full-control snapshots | 7, about 70 seconds | 6, about 60 seconds |
| Zero-control snapshots | 8, about 80 seconds | 9, about 90 seconds |
| Required commitments satisfied by assigned squads | 82.7% | 82.1% |
| Required commitments satisfied by practical nearby coverage | 58.9% | 55.4% |
| Surplus squad assignments beyond desired commitments | 146 | 75 |
| Average surplus assignments per snapshot | 2.39 | 1.23 |
| Average share assigned to the most crowded point | 57.4% | 52.6% |
| Average tracked squads | 5.64 | 4.44 |
| Tracked squad range | 0-9 | 0-7 |
| Squad decisions | 406 | 322 |
| Objective switches | 94 | 76 |
| Utility-shadow disagreements | 57 | 48 |

Planned commitment coverage was nearly equal, so Match 2 does not show one faction selecting strategically necessary Hardpoints much better than the other. IMC had a modest practical-coverage advantage and averaged 1.2 more active tracked squads. It held slightly more territory, amped slightly more territory, and generated substantially more surplus assignments. The identical faction logic again points to available force strength and reinforcement tempo as the main cause rather than different decision intelligence.

IMC's greater surplus and concentration did not prevent it from recovering. In this match, extra mass appears to have provided enough force to satisfy minimum commitments while still sustaining larger attacks.

#### Score Progression

| Approximate match time | IMC | Militia | IMC effective cap | IMC pressure |
|---:|---:|---:|---:|---:|
| 67s | 20 | 30 | 18 | 0 |
| 127s | 24 | 88 | 22 | 1 |
| 187s | 32 | 141 | 26 | 2 |
| 247s | 67 | 166 | 26 | 2 |
| 307s | 122 | 177 | 22 | 1 |
| 367s | 154 | 181 | 22 | 1 |
| 427s | 228 | 193 | 22 | 1 |
| 487s | 263 | 212 | 22 | 1 |
| 547s | 291 | 233 | 22 | 1 |
| 607s | 319 | 273 | 22 | 1 |

Militia took the lead around 57 seconds, reached a maximum recorded lead of 121 points, and remained ahead until approximately 397 seconds. IMC then overturned the match and reached a maximum lead of 65 before finishing 51 points ahead.

#### Director and Reinforcement Outcome

Effective-cap snapshot periods:

| Team and cap | Pressure | Snapshots | Approximate duration |
|---|---:|---:|---:|
| IMC 18 | 0 | 11 | 110 seconds |
| IMC 22 | 1 | 36 | 360 seconds |
| IMC 26 | 2 | 14 | 140 seconds |
| Militia 14 | 0 | 61 | 610 seconds |

Reinforcement dispatches:

| Team | Total | Dropships | Droppods | Average deficit at dispatch | Lowest alive count |
|---|---:|---:|---:|---:|---:|
| IMC | 64 | 25 | 39 | 5.81 | 10 |
| Militia | 43 | 23 | 20 | 2.93 | 6 |

IMC dispatch detail by effective cap:

| Effective cap | Dropships | Droppods |
|---:|---:|---:|
| 18 | 4 | 6 |
| 22 | 16 | 21 |
| 26 | 5 | 12 |

Militia's 14-unit cap produced 23 dropships and 20 droppods. IMC received 21 more reinforcement dispatches overall and nearly twice as many emergency pods. Its pressure bonus correctly began while it was losing badly, but pressure level 1 remained active after IMC had recovered and taken a substantial lead. Militia never received a recorded cap increase.

The likely explanation is Hot Player Pressure: it can add pressure independently of team score. That means IMC could retain a 22-unit cap because the opposing player remained classified as hot even after IMC became the winning team. This is consistent with the configured design, but Match 2 shows that the resulting reinforcement advantage can persist long enough to turn a large comeback into a decisive reversal rather than settling toward an even fight.

#### Match 2 Interpretation

The strategic system behaved comparably for both factions. The decisive asymmetry was battlefield capacity and reinforcement throughput:

- Militia led by as much as 121 points while IMC pressure climbed.
- IMC operated above its base cap for about 500 of 610 sampled seconds.
- Militia remained at its base 14 cap for the entire sampled match.
- IMC averaged more squads, received more dispatches, and maintained somewhat better practical coverage.
- Once IMC overtook Militia, its pressure-enhanced cap did not return to the base 18 during the remaining match.

This match is evidence that the current Director can produce a delayed but sustained force swing. More matches are needed to determine whether that behavior consistently causes the side receiving early comeback pressure to win late.

### Match 3

Source log: `nslog2026-07-19 18-18-27.txt`

Conditions:

- Map: Colony (`mp_colony02`)
- Militia infantry budget: 14
- IMC infantry budget: 18
- Director: enabled
- Result: Militia/player loss, IMC 282 to Militia 261
- Score margin: 21
- Samples: 61 snapshots per team, approximately 10 seconds apart
- Automated suite: 352 checks, 0 failures
- Script errors: none

#### Strategic Outcome

| Metric | IMC | Militia |
|---|---:|---:|
| Final score | 282 | 261 |
| Average owned Hardpoints | 1.31 | 1.57 |
| Average owned and fully amped Hardpoints | 0.30 | 0.30 |
| Full-control snapshots | 11, about 110 seconds | 15, about 150 seconds |
| Zero-control snapshots | 17, about 170 seconds | 13, about 130 seconds |
| Required commitments satisfied by assigned squads | 81.0% | 74.7% |
| Required commitments satisfied by practical nearby coverage | 57.7% | 52.9% |
| Surplus squad assignments beyond desired commitments | 124 | 82 |
| Average surplus assignments per snapshot | 2.03 | 1.34 |
| Average share assigned to the most crowded point | 55.1% | 56.4% |
| Average tracked squads | 5.38 | 4.39 |
| Tracked squad range | 0-9 | 0-8 |
| Squad decisions | 397 | 313 |
| Objective switches | 75 | 71 |
| Utility-shadow disagreements | 37 | 45 |

Militia controlled more territory on average, achieved full-map control more often, and spent less time with no Hardpoints, yet lost the match. Both teams had the same average amped ownership. This is strong evidence that average ownership alone does not explain the result.

IMC still satisfied planned and practical commitments more reliably, averaged almost one additional tracked squad, and generated substantially more surplus assignments. Unlike Match 2, concentration was effectively equal. The strategic data therefore shows good Militia map control but stronger IMC force availability and execution reliability.

#### Score Progression

| Approximate match time | IMC | Militia | IMC effective cap | IMC pressure |
|---:|---:|---:|---:|---:|
| 67s | 12 | 28 | 18 | 0 |
| 127s | 13 | 74 | 18 | 0 |
| 187s | 23 | 106 | 26 | 2 |
| 247s | 83 | 113 | 22 | 1 |
| 307s | 125 | 121 | 22 | 1 |
| 367s | 186 | 127 | 22 | 1 |
| 427s | 228 | 150 | 22 | 1 |
| 487s | 264 | 164 | 22 | 1 |
| 547s | 277 | 195 | 22 | 1 |
| 607s | 278 | 253 | 22 | 1 |

Militia took the lead around 57 seconds and reached a maximum recorded advantage of 85. IMC overtook around 307 seconds, later reached a maximum advantage of 110, and won by 21 after a strong late Militia recovery.

#### Director and Reinforcement Outcome

Effective-cap snapshot periods:

| Team and cap | Pressure | Snapshots | Approximate duration |
|---|---:|---:|---:|
| IMC 18 | 0 | 12 | 120 seconds |
| IMC 22 | 1 | 45 | 450 seconds |
| IMC 26 | 2 | 4 | 40 seconds |
| Militia 14 | 0 | 45 | 450 seconds |
| Militia 18 | 1 | 16 | 160 seconds |

The periods are not necessarily contiguous. IMC first entered pressure at approximately 137 seconds, briefly reached pressure level 2 around 187-217 seconds, and retained pressure level 1 through the final snapshot. Militia received level 1 pressure during a later deficit, approximately between the 387-547-second snapshots.

Reinforcement dispatches:

| Team | Total | Dropships | Droppods | Average deficit at dispatch | Lowest alive count |
|---|---:|---:|---:|---:|---:|
| IMC | 59 | 24 | 35 | 5.53 | 9 |
| Militia | 39 | 24 | 15 | 3.03 | 8 |

Dispatch detail by effective cap:

| Team and cap | Dropships | Droppods |
|---|---:|---:|
| IMC 18 | 4 | 5 |
| IMC 22 | 18 | 25 |
| IMC 26 | 2 | 5 |
| Militia 14 | 18 | 10 |
| Militia 18 | 6 | 5 |

Both teams received exactly 24 dropships. The entire 20-dispatch difference came from IMC receiving 35 emergency pods versus Militia's 15. This is consistent with IMC operating against a much larger effective cap and therefore repeatedly qualifying for emergency refill.

#### Match 3 Interpretation

Match 3 weakens the idea that IMC won simply because it prioritized Hardpoints better. Militia's territorial results were actually superior. The result again aligns more strongly with reinforcement capacity:

- IMC operated above its base cap for approximately 490 sampled seconds.
- Militia operated above its base cap for approximately 160 sampled seconds.
- During Militia's late comeback assistance, the battlefield was effectively `18 vs 22`, because IMC retained Hot Player Pressure.
- IMC received 20 more reinforcement dispatches, all from additional emergency pods.
- Militia recovered from a 110-point deficit to lose by only 21, suggesting its late pressure worked but arrived against an opponent that still retained its own bonus.

Two consecutive expanded-telemetry matches now show IMC retaining a Hot Player Pressure bonus after recovering the score lead. This is becoming a repeatable candidate explanation, though the five-match session should still finish before balance rules change.

### Additional Enabled-Pressure Retest

Source log: `nslog2026-07-21 11-46-00.txt`

Conditions:

- Map: Colony (`mp_colony02`)
- Militia infantry budget: 14
- IMC infantry budget: 18
- Director: enabled
- Hot Player Pressure: enabled
- Hot Player Dampening: enabled, but never triggered
- Result: Militia/player win, Militia 299 to IMC 270
- Score margin: 29
- Samples: 61 snapshots per team, approximately 10 seconds apart
- Script errors in the match telemetry: none

This is the first recorded win with Hot Player Pressure enabled after the three consecutive losses above. Like those three losses, it had no Hot Player Dampening events. The meaningful common condition was Hot Player Pressure, not dampening.

#### Strategic Outcome

| Metric | IMC | Militia |
|---|---:|---:|
| Final score | 270 | 299 |
| Average owned Hardpoints | 1.23 | 1.52 |
| Average owned and fully amped Hardpoints | 0.33 | 0.46 |
| Full-control snapshots | 6, about 60 seconds | 8, about 80 seconds |
| Zero-control snapshots | 10, about 100 seconds | 12, about 120 seconds |
| Required commitments satisfied by assigned squads | 84.5% | 83.1% |
| Required commitments satisfied by practical nearby coverage | 58.3% | 56.0% |
| Surplus squad assignments beyond desired commitments | 107 | 85 |
| Average share assigned to the most crowded point | 53.4% | 55.8% |
| Squad decisions | 375 | 314 |
| Objective switches | 81 | 82 |
| Utility-shadow disagreements | 47 | 47 |

Militia held more territory and more fully amped territory on average. Planned and practical commitment coverage remained close between teams, while IMC again had more surplus assignments and decisions. Unlike the previous enabled-pressure losses, that greater IMC force throughput did not overturn Militia's stronger objective result.

#### Director and Reinforcement Outcome

Effective-cap snapshot periods:

| Team and cap | Pressure | Snapshots | Approximate duration |
|---|---:|---:|---:|
| IMC 18 | 0 | 20 | 200 seconds |
| IMC 22 | 1 | 41 | 410 seconds |
| Militia 14 | 0 | 61 | 610 seconds |

Reinforcement dispatches:

| Team | Total | Dropships | Droppods | Average deficit at dispatch | Lowest alive count |
|---|---:|---:|---:|---:|---:|
| IMC | 56 | 26 | 30 | 5.54 | 10 |
| Militia | 37 | 27 | 10 | 2.41 | 8 |

Hot Player Pressure did trigger. At approximately 217 seconds, IMC moved from pressure 0 and cap 18 to pressure 1 and cap 22 while the sampled score was effectively tied. It retained that bonus for the remaining 41 snapshots. IMC received 19 more dispatches than Militia, including three times as many emergency droppods. Hot Player Dampening remained zero for both teams throughout the match.

#### Retest Interpretation

The enabled-pressure record is now one win and three losses. This match is an important counterexample to the earlier deterministic-looking pattern:

- Hot Player Pressure activated and remained active for most of the match.
- IMC received the same kind of sustained cap and emergency-refill advantage seen in the losses.
- Militia nevertheless maintained the better objective result and won by 29.
- No Hot Player Dampening event occurred, matching the previous three losses.

The result shows that Hot Player Pressure strongly changes force availability but does not make defeat inevitable. It also means the earlier comparison must not describe dampening as the cause: dampening was configured but inactive in all four enabled-pressure matches.

### Cohort B: Hot Player Pressure Disabled

### Match 4

Source log: `nslog2026-07-19 18-38-03.txt`

Conditions:

- Map: Colony (`mp_colony02`)
- Militia infantry budget: 14
- IMC infantry budget: 18
- Director: enabled
- Hot Player Pressure: disabled
- Result: Militia/player win, Militia 377 to IMC 320
- Score margin: 57
- Samples: 61 snapshots per team, approximately 10 seconds apart
- Automated suite: 352 checks, 0 failures
- Script errors: none

#### Strategic Outcome

| Metric | IMC | Militia |
|---|---:|---:|
| Final score | 320 | 377 |
| Average owned Hardpoints | 1.25 | 1.64 |
| Average owned and fully amped Hardpoints | 0.49 | 0.48 |
| Full-control snapshots | 8, about 80 seconds | 13, about 130 seconds |
| Zero-control snapshots | 15, about 150 seconds | 10, about 100 seconds |
| Required commitments satisfied by assigned squads | 85.4% | 79.2% |
| Required commitments satisfied by practical nearby coverage | 59.5% | 58.9% |
| Surplus squad assignments beyond desired commitments | 168 | 103 |
| Average surplus assignments per snapshot | 2.75 | 1.69 |
| Average share assigned to the most crowded point | 56.6% | 54.2% |
| Average tracked squads | 5.82 | 4.70 |
| Tracked squad range | 0-9 | 0-8 |
| Squad decisions | 396 | 321 |
| Objective switches | 75 | 74 |
| Utility-shadow disagreements | 30 | 55 |

Militia held substantially more territory, achieved full control more often, and spent less time without a Hardpoint. Both factions had nearly identical practical commitment coverage and average amped ownership. IMC still had more squads and stronger assigned coverage, but that numerical advantage did not determine the winner.

#### Score Progression

| Approximate match time | IMC | Militia | IMC effective cap | IMC pressure |
|---:|---:|---:|---:|---:|
| 67s | 28 | 28 | 18 | 0 |
| 127s | 28 | 85 | 18 | 0 |
| 187s | 28 | 156 | 22 | 1 |
| 247s | 85 | 172 | 22 | 1 |
| 307s | 180 | 172 | 18 | 0 |
| 367s | 228 | 208 | 18 | 0 |
| 427s | 250 | 245 | 18 | 0 |
| 487s | 260 | 314 | 18 | 0 |
| 547s | 268 | 353 | 22 | 1 |
| 607s | 320 | 362 | 18 | 0 |

The match had four distinct leadership phases and three lead changes: IMC led first, Militia took over around 77 seconds, IMC recovered around 307 seconds, and Militia regained the lead around 457 seconds. Militia's maximum recorded lead was 132; IMC's was 27.

#### Director and Reinforcement Outcome

Effective-cap snapshot periods:

| Team and cap | Pressure | Snapshots | Approximate duration |
|---|---:|---:|---:|
| IMC 18 | 0 | 45 | 450 seconds |
| IMC 22 | 1 | 16 | 160 seconds |
| Militia 14 | 0 | 61 | 610 seconds |

IMC's pressure periods were score-driven and non-contiguous. Crucially, its cap returned to 18 after each recovery instead of remaining at 22 while leading. Militia never crossed the configured score-gap threshold long enough to receive a sampled pressure increase.

Reinforcement dispatches:

| Team | Total | Dropships | Droppods | Average deficit at dispatch | Lowest alive count |
|---|---:|---:|---:|---:|---:|
| IMC | 50 | 26 | 24 | 4.12 | 9 |
| Militia | 37 | 23 | 14 | 3.11 | 8 |

Dispatch detail by effective cap:

| Team and cap | Dropships | Droppods |
|---|---:|---:|
| IMC 18 | 18 | 19 |
| IMC 22 | 8 | 5 |
| Militia 14 | 23 | 14 |

IMC still received 13 more dispatches because it began with the larger base budget and temporarily received legitimate comeback pressure. Unlike Matches 2 and 3, that reinforcement advantage did not become a permanent elevated cap after IMC recovered.

#### Match 4 Interpretation

This first control match supports Hot Player Pressure as the main source of the earlier deterministic late swings:

- Disabling it immediately changed the result from three consecutive losses to a Militia win.
- Ordinary comeback pressure remained functional.
- IMC's bonus receded after it recovered instead of persisting while ahead.
- The match produced four leadership phases and three lead changes rather than settling into one irreversible Director-assisted reversal.
- Militia won despite IMC retaining its normal base-budget and dispatch advantages.

One control match is not sufficient by itself, but it produces the exact behavioral difference predicted by the Hot Player Pressure hypothesis.

The completed decision-making investigation included four matches with Hot Player Pressure enabled and one control match with it disabled. Those balance results were not used to choose between decision trees because both factions ran the same live strategy. They did show that force availability and Director behavior could dominate match outcomes even when objective selection was working correctly.

## Abandonment Check

Across the five recorded matches, the strict abandonment definition was an owned, unamped point with zero assigned squads and zero practical nearby coverage.

- 871 owned-point samples were inspected at ten-second intervals.
- 35 samples met the strict definition, a 4.0% rate.
- The samples formed 33 incidents.
- No incident lasted 30 seconds or longer.
- The longest observed incident was approximately 20 seconds; most appeared in only one snapshot.

Owned points sometimes remained below full amp for much longer, but squads were assigned, physically present, or both. That indicated interrupted execution through combat, travel, contesting, or deaths rather than a strategic decision to abandon the point.

## Final Decision

The combined minimum-commitment and utility strategy provided the best tested compromise and remains NPC War's live behavior:

- More reliable than utility scoring alone
- More decisive than strong anti-concentration scoring
- Still allows surplus forces to mass for a major attack
- Preserves the special rule that a team with no foothold may concentrate on one nearby objective

The experiment was closed because automated scenarios passed, live play produced cohesive and dynamic combat, and strict abandonment was brief and uncommon. Continuing to tune objective weights without a demonstrated failure risked overfitting the AI and making matches more predictable. Future work therefore returns to force balance, Director behavior, population accounting, and reinforcement flow.

# NPC War Hot Player Pressure Testing Report

## Status

This report preserves an exploratory five-match Hardpoint series that examined Hot Player Pressure, population caps, and reinforcement flow. It was originally embedded in the Hardpoint AI strategy report and described as an A/B session.

That description was too strong. The series had four enabled matches and one disabled match, no randomized assignment, and several uncontrolled gameplay variables. It is useful as mechanism and hypothesis evidence, not as a controlled estimate of win-rate effects.

## Question

Hot Player Pressure can add one Director pressure level when a high-impact player accounts for a sufficiently large share of their team's assault score. Because pressure increases the opposing faction's effective infantry cap, the mechanic can respond to player impact even after ordinary score-gap pressure has receded.

The investigation asked:

- Does Hot Player Pressure activate in live matches?
- Can the added cap persist after the assisted faction recovers the score lead?
- How does that affect reinforcement dispatches and battlefield population?
- Does the observed advantage determine the winner?

It did not test alternative Hardpoint decision trees. Both factions always used the same minimum-commitment and utility strategy.

## Match Series

Common conditions included:

- Hardpoint
- Militia infantry budget: 14
- IMC infantry budget: 18
- Director enabled
- One human player on Militia
- Population, territory, and reinforcement samples approximately every ten seconds

The base budgets were intentionally asymmetric and are an important confounding variable.

| Record | Source log | Hot Player Pressure | Result |
|---|---|---|---|
| Match 1 | `nslog2026-07-19 13-41-24.txt` | Enabled | Militia/player loss |
| Match 2 | `nslog2026-07-19 17-59-50.txt` | Enabled | IMC 329, Militia 278 |
| Match 3 | `nslog2026-07-19 18-18-27.txt` | Enabled | IMC 282, Militia 261 |
| Enabled retest | `nslog2026-07-21 11-46-00.txt` | Enabled | Militia 299, IMC 270 |
| Disabled comparison | `nslog2026-07-19 18-38-03.txt` | Disabled | Militia 377, IMC 320 |

The enabled record was therefore one Militia win and three losses. The single disabled record was a Militia win. These counts are descriptive only.

## Observed Mechanism

The expanded telemetry in Matches 2 and 3 showed IMC retaining Hot Player Pressure after recovering from a score deficit. Its effective infantry cap could remain at 22 rather than returning to its base of 18 because player-impact pressure was independent of which team currently led.

This created periods in which:

- IMC had recovered or taken the lead.
- IMC still retained the additional pressure level.
- Militia's later ordinary comeback assistance operated against an opponent that still had the hot-player bonus.
- IMC received more reinforcement dispatches and more emergency droppods.

The enabled retest reproduced the mechanism. At approximately 217 seconds, IMC moved from pressure 0 and cap 18 to pressure 1 and cap 22 while the sampled score was effectively tied. It retained that bonus for the remaining 41 snapshots and received 19 more dispatches than Militia, including roughly three times as many emergency droppods.

Militia nevertheless maintained the stronger objective result and won the retest by 29 points. Hot Player Pressure therefore changed force availability substantially but did not determine the winner.

## Disabled Comparison

With Hot Player Pressure disabled, ordinary score-gap comeback pressure still activated. IMC's cap returned to 18 after each recovery instead of remaining at 22 while leading.

That match produced more leadership changes and ended in a Militia win. This behavior was consistent with the hypothesis that Hot Player Pressure caused the persistent post-recovery bonus in the enabled matches.

One disabled match cannot establish how frequently the mechanic changes outcomes. It only provides a useful mechanism comparison: score-driven pressure receded when the score recovered, whereas enabled Hot Player Pressure could remain active because the player's contribution still qualified.

## Hot Player Dampening

Hot Player Dampening was configured during the enabled-pressure records but did not activate. It cannot explain their outcomes. The meaningful changing or active mechanic in this series was Hot Player Pressure.

## What The Evidence Supports

The series supports these observations:

- Hot Player Pressure activated under live conditions.
- It could keep an assisted faction above its base infantry cap after that faction recovered the score lead.
- Persistent cap increases generated additional reinforcement throughput.
- The mechanism occurred in more than one enabled match.
- A persistent advantage did not make defeat inevitable.
- Ordinary score-gap pressure continued to function when Hot Player Pressure was disabled.

## What The Evidence Does Not Support

The series does not establish:

- A reliable win-rate effect
- The probability that Hot Player Pressure changes a match result
- That enabled and disabled matches were otherwise equivalent
- That territory differences were caused by pressure alone
- That either faction made better Hardpoint decisions
- That the 14-versus-18 base population setup was balanced

Human performance, kills, deaths, travel, spawn timing, objective encounters, and stochastic reinforcement choices were not controlled. The four-to-one cohort size was also too small and uneven for a defensible A/B claim.

## Conclusion

Hot Player Pressure is best understood here as a confirmed population-control mechanism with a plausible balance risk. The recorded matches show that it can convert player impact into a sustained enemy reinforcement advantage even after the enemy takes the lead.

The evidence justified separating player-impact pressure from ordinary comeback pressure in future balance analysis. It did not justify a causal claim about wins or losses. Any future comparison should vary Hot Player Pressure alone across a larger, balanced set of matched sessions and use the shared balance telemetry to measure cap duration, total population, dispatches, territory, and score progression.

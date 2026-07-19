untyped

global function GamemodeCP_Init
global function RateSpawnpoints_CP
global function DEV_PrintHardpointsInfo

//NOTICE: ALL "PGS_ASSAULT_SCORE instances have been replaced with PGS_DEFENSE SCORE for NPC War compatibility"

const float NPCWAR_DROPSHIP_SPAWN_COOLDOWN = 20.0
const float NPCWAR_INFANTRY_DISPATCH_COOLDOWN = 5.0
const float NPCWAR_INFANTRY_DROPPOD_REFILL_DEFICIT_FRAC = 0.25
const float NPCWAR_INFANTRY_EMERGENCY_DROPPOD_DEFICIT_FRAC = 0.45

int function NPCWar_CeilDeficitFraction( int limit, float frac )
{
	float scaled = float( limit ) * frac
	int roundedDown = int( floor( scaled ) )
	if ( float( roundedDown ) < scaled )
		return roundedDown + 1

	return roundedDown
}

const float CP_AI_INFANTRY_GOAL_RADIUS = 650.0
const float CP_AI_TITAN_GOAL_RADIUS = 1400.0
const float CP_AI_PRACTICAL_COVERAGE_RADIUS = 1800.0
const float CP_AI_NEAR_RESPONSE_DISTANCE = 2500.0
const float CP_AI_CLOSE_TO_OBJECTIVE_DISTANCE = 1200.0
const float CP_AI_DISTANCE_PENALTY_PER_1000_UNITS = 18.0
const float CP_AI_REASSIGN_SCORE_MARGIN = 35.0
const bool CP_AI_DEBUG_OBJECTIVES = false
const int CP_AI_TELEMETRY_OFF = 0
const int CP_AI_TELEMETRY_SUMMARY = 1
const int CP_AI_TELEMETRY_DETAILED = 2
const float CP_AI_TELEMETRY_SNAPSHOT_INTERVAL = 10.0
const int CP_AI_TEST_STRATEGY_UTILITY = 0
const int CP_AI_TEST_STRATEGY_CURRENT = 1
const int CP_AI_TEST_STRATEGY_STRONG_SATURATION = 2
const int CP_AI_TEST_VARIANTS = 24

// Hardpoint objective utility weights. These are intentionally coarse because
// squads reconsider asynchronously and should converge, not solve the map.
const float CP_AI_SCORE_OWNED_CONTESTED = 260.0
const float CP_AI_SCORE_NEAR_DEFENSE_RESPONSE = 80.0
const float CP_AI_SCORE_UNDERCOVERED_DEFENSE = 60.0
const float CP_AI_SCORE_NEEDS_AMPING = 95.0
const float CP_AI_SCORE_UNCOVERED_AMP = 45.0
const float CP_AI_SCORE_PARTIAL_AMP = 20.0
const float CP_AI_SCORE_SAFE_OWNED = 20.0
const float CP_AI_SCORE_UNCOVERED_SAFE = 80.0
const float CP_AI_SCORE_REDUNDANT_SAFE_PENALTY = 70.0
const float CP_AI_SCORE_ONLY_UNCONTROLLED = 210.0
const float CP_AI_SCORE_ENEMY_AMPING = 220.0
const float CP_AI_SCORE_NEAR_ENEMY_AMPING = 75.0
const float CP_AI_SCORE_NEUTRAL_POINT = 130.0
const float CP_AI_SCORE_ENEMY_POINT = 120.0
const float CP_AI_SCORE_NO_ASSIGNMENT = 35.0
const float CP_AI_SCORE_ALLIED_PRESENT = 45.0
const float CP_AI_SCORE_ENEMY_PRESENT = 70.0
const float CP_AI_SCORE_NEARLY_COMPLETE = 55.0
const float CP_AI_SCORE_NO_OWNED_POINTS = 25.0
const float CP_AI_SCORE_SATURATION_PENALTY = 45.0
const float CP_AI_SCORE_CURRENT_OBJECTIVE = 35.0
const float CP_AI_SCORE_CURRENT_CLOSE = 30.0
const float CP_AI_SCORE_CURRENT_NEARLY_COMPLETE = 60.0
const float CP_AI_SCORE_CURRENT_CRITICAL_DEFENSE = 45.0
const float CP_AI_SCORE_HEAVY_UNIT = 10.0

struct HardpointStruct
{
	entity hardpoint
	entity trigger
	entity prop

	array<entity> imcCappers
	array<entity> militiaCappers
}

struct CP_PlayerStruct
{
	entity player
	bool isOnHardpoint
	array<float> timeOnPoints //floats sorted same as in hardpoints array not by ID
}

struct CP_AISquadAssignment
{
	int id
	int team
	entity anchor
	entity objective
	bool heavy
}

struct CP_HardpointDecisionState
{
	int owner
	int cappingTeam
	float progress
	float distance
	int assigned
	int practicalCoverage
	int desiredCommitment
	int ownedCount
	bool ampingEnabled
	bool alliedPresent
	bool enemyPresent
	bool onlyRemainingUncontrolled
	bool allPointsEnemyOwned
	bool current
}

struct CP_TestHardpoint
{
	string name
	int owner
	int cappingTeam
	float progress
	vector origin
	bool friendlyPresent
	bool enemyPresent
}

struct CP_TestSquad
{
	vector origin
	int currentObjective
	bool heavy
}

struct CP_TestScenario
{
	string name
	array<CP_TestHardpoint> points
	array<CP_TestSquad> squads
	array<int> requiredCoverage
	bool allowFullConcentration
}

struct CP_TestAllocationResult
{
	array<int> allocations
	int switches
}

struct {
	bool ampingEnabled = true

	array<HardpointStruct> hardpoints
	array<CP_PlayerStruct> players
	array<CP_AISquadAssignment> aiSquadAssignments
	int nextAISquadAssignmentId = 0
	array<int> aiTelemetryDecisions = [ 0, 0 ]
	array<int> aiTelemetrySwitches = [ 0, 0 ]
	array<int> aiTelemetryShadowDisagreements = [ 0, 0 ]
	array<int> aiTelemetrySnapshots = [ 0, 0 ]
	array<int> aiTelemetryOwnedPointSamples = [ 0, 0 ]
	array<int> aiTelemetryFullControlSamples = [ 0, 0 ]
	array<int> aiTelemetryZeroControlSamples = [ 0, 0 ]
	array<int> aiTelemetryAmpedOwnedSamples = [ 0, 0 ]
	array<int> aiTelemetryRequiredCommitments = [ 0, 0 ]
	array<int> aiTelemetryAssignedCommitmentsMet = [ 0, 0 ]
	array<int> aiTelemetryPracticalCommitmentsMet = [ 0, 0 ]
	array<int> aiTelemetrySurplusAssignments = [ 0, 0 ]
	array<float> aiTelemetryLargestShareTotal = [ 0.0, 0.0 ]

	//GM Stuff
	// Due to team based escalation everything is an array
	array< int > levels = [ 0, 0 ]
	array< array< string > > podEntities = [ [ "npc_soldier" ], [ "npc_soldier" ] ]
	array< bool > reapers = [ false, false ]

	array< bool > marvins = [ false, false ]
	array< bool > prowlers = [ false, false ]
	array< bool > stalkers = [ false, false ]
	array< bool > weapondrops = [ false, false ]

	array< bool > gunships = [ false, false ]
	array< bool > pilots = [ false, false ]
	array< bool > titans = [ false, false ]
	array< float > nextDropshipSpawnTime = [ 0.0, 0.0 ]
	array< float > nextInfantryDispatchTime = [ 0.0, 0.0 ]
} file

void function GamemodeCP_Init()
{
	//------------------------------------------ Ported from attrition

	npcWarSupportedGameMode = true
	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )

	AddCallback_OnNPCKilled( NPCWar_GivePoints )
	AddCallback_OnPlayerKilled( NPCWar_GivePoints )

	if ( GetCurrentPlaylistVarInt( "aitdm_archer_grunts", 0 ) == 0 )
	{
		AiGameModes_SetNPCWeapons( "npc_soldier", [ "mp_weapon_rspn101", "mp_weapon_dmr","mp_weapon_g2", "mp_weapon_lmg", "mp_weapon_shotgun", "mp_weapon_alternator_smg", "mp_weapon_r97", "mp_weapon_car", "mp_weapon_vinson", "mp_weapon_rspn101_og","mp_weapon_rocket_launcher"] )
		AiGameModes_SetNPCWeapons( "npc_spectre", [ "mp_weapon_defender", "mp_weapon_sniper", "mp_weapon_doubletake", "mp_weapon_hemlok_smg" ] )
		AiGameModes_SetNPCWeapons( "npc_stalker", [ "mp_weapon_lstar", "mp_weapon_mastiff" ] )
	}
	else
	{
		AiGameModes_SetNPCWeapons( "npc_soldier", [ "mp_weapon_rocket_launcher" ] )
		AiGameModes_SetNPCWeapons( "npc_spectre", [ "mp_weapon_rocket_launcher" ] )
		AiGameModes_SetNPCWeapons( "npc_stalker", [ "mp_weapon_rocket_launcher" ] )
	}

	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	//ClassicMP_ForceDisableEpilogue( true )
	NPCWarPilotMode_ApplyBoostAvailability()
	NPCWarPilotMode_PrepareTitanAvailability()
	NPCWarPilotMode_ApplyMatchLimitOverrides()

	file.levels[0] = 0
	file.levels[1] = 0

	// ------------------ HARDPOINT

	file.ampingEnabled = GetCurrentPlaylistVarInt( "cp_amped_capture_points", 1 ) == 1
	if ( GetCurrentPlaylistVarInt( "npcwar_cp_scenario_tests", 0 ) == 1 )
		CP_RunHardpointScenarioTests()

	RegisterSignal( "HardpointCaptureStart" )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_OnPlayerKilled(GamemodeCP_OnPlayerKilled)
	AddCallback_EntitiesDidLoad( SpawnHardpoints )
	AddCallback_GameStateEnter( eGameState.Playing, StartHardpointThink )
	AddCallback_OnClientConnected(GamemodeCP_InitPlayer)
	AddCallback_OnClientDisconnected(GamemodeCP_RemovePlayer)

	ScoreEvent_SetEarnMeterValues("KillPilot",0.1,0.12)
	ScoreEvent_SetEarnMeterValues("KillTitan",0,0)
	ScoreEvent_SetEarnMeterValues("TitanKillTitan",0,0)
	ScoreEvent_SetEarnMeterValues("PilotBatteryStolen",0,35)
	ScoreEvent_SetEarnMeterValues("Headshot",0,0.02)
	ScoreEvent_SetEarnMeterValues("FirstStrike",0,0.05)

	ScoreEvent_SetEarnMeterValues("ControlPointCapture",0.1,0.1)
	ScoreEvent_SetEarnMeterValues("ControlPointHold",0.02,0.02)
	ScoreEvent_SetEarnMeterValues("ControlPointAmped",0.2,0.15)
	ScoreEvent_SetEarnMeterValues("ControlPointAmpedHold",0.05,0.05)

	ScoreEvent_SetEarnMeterValues("HardpointAssault",0.10,0.15)
	ScoreEvent_SetEarnMeterValues("HardpointDefense",0.5,0.10)
	ScoreEvent_SetEarnMeterValues("HardpointPerimeterDefense",0.1,0.12)
	ScoreEvent_SetEarnMeterValues("HardpointSiege",0.1,0.15)
	ScoreEvent_SetEarnMeterValues("HardpointSnipe",0.1,0.15)
}

void function OnPrematchStart()
{
	thread StratonHornetDogfightsIntense()
}

void function OnPlaying()
{
	// don't run spawning code if ains and nms aren't up to date
	if ( GetAINScriptVersion() == AIN_REV && GetNodeCount() != 0 )
	{
		thread SpawnIntroBatch( TEAM_MILITIA )
		thread SpawnIntroBatch( TEAM_IMC )
	}
}

void function SpawnIntroBatch( int team )
{
	if( GetMapName() != "mp_rise" && GetMapName() != "mp_wargames" && GetMapName() != "mp_crashsite3" )
	{
		array<entity> dropPodNodes = GetEntArrayByClass_Expensive( "info_spawnpoint_droppod_start" )
		array<entity> dropShipNodes = GetValidIntroDropShipSpawn( dropPodNodes )

		array<entity> podNodes
		array<entity> shipNodes

		// Sort per team
		foreach ( node in dropPodNodes )
		{
			if ( node.GetTeam() == team )
				podNodes.append( node )
		}

		// If for some reason we're missing team nodes
		// start spawner
		if( podNodes.len() == 0 )
		{
			waitthread Spawner( team )
			return
		}


		// Spawn logic
		int startIndex = 0
		bool first = true
		entity node

		int pods = RandomInt( podNodes.len() + 1 )

		int ships = shipNodes.len()

		for ( int i = 0; i < GetConVarInt( "NPCWAR_SQUADS" ); i++ )
		{
			if ( pods != 0 || ships == 0 )
			{
				int index = i

				if ( index > podNodes.len() - 1 )
					index = RandomInt( podNodes.len() )

				node = podNodes[ index ]
				print("Spawned Initial Drop Pod")
				thread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, "npc_soldier", SquadHandler)

				pods--
			}
			else
			{
				if ( startIndex == 0 )
				startIndex = i // save where we started

				node = shipNodes[ i - startIndex ]
				thread AiGameModes_SpawnDropShip( node.GetOrigin(), node.GetAngles(), team, 4, SquadHandler)

				ships--
			}

			// Vanilla has a delay after first spawn
			if ( first )
				wait 2

			first = false
		}

	wait 15
	}

	thread Spawner( team )
	thread SpawnerExtend( team )
	//thread SpawnerWeapons( team )
}

// Populates the match
void function Spawner( int team )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	int index = team == TEAM_MILITIA ? 0 : 1

	while( true )
	{
		if( GetGameState() == eGameState.Playing )
		{
			Escalate( team )

			int count = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_INFANTRY )
			int reaperCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_REAPER )

			// REAPERS
			if ( file.reapers[ index ] )
			{
				array< entity > points = SpawnPoints_GetDropPod()
			if ( reaperCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_REAPERS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread AiGameModes_SpawnReaper( node.GetOrigin(), node.GetAngles(), team, "npc_super_spectre_aitdm", ReaperHandler )
				}
			}

			// NORMAL SPAWNS
			int squadLimit = NPCWarDirector_GetSquadSpawnLimit( team )
			int squadDeficit = squadLimit - count

			if ( squadDeficit > 0 && Time() >= file.nextInfantryDispatchTime[ index ] )
			{
				string ent = file.podEntities[ index ][ RandomInt( file.podEntities[ index ].len() ) ]
				int droppodRefillDeficit = maxint( 1, NPCWar_CeilDeficitFraction( squadLimit, NPCWAR_INFANTRY_DROPPOD_REFILL_DEFICIT_FRAC ) )
				int emergencyDroppodDeficit = maxint( droppodRefillDeficit + 1, NPCWar_CeilDeficitFraction( squadLimit, NPCWAR_INFANTRY_EMERGENCY_DROPPOD_DEFICIT_FRAC ) )
				bool shouldSpawnDropPod = squadDeficit >= droppodRefillDeficit

				// Prefer dropship when spawning grunts
				if ( ent == "npc_soldier" )
				{
					array< entity > points = GetZiplineDropshipSpawns()
					if ( points.len() / 4 >= 1 && squadDeficit < emergencyDroppodDeficit && Time() >= file.nextDropshipSpawnTime[ index ] && RandomInt( points.len() / 4 ) )
					{
						entity node = points[ GetSpawnPointIndex( points, team ) ]
						file.nextDropshipSpawnTime[ index ] = Time() + NPCWAR_DROPSHIP_SPAWN_COOLDOWN
						file.nextInfantryDispatchTime[ index ] = Time() + NPCWAR_INFANTRY_DISPATCH_COOLDOWN
						CP_PrintReinforcementTelemetry( team, "dropship", count, squadLimit )
						Aitdm_SpawnDropShip( node, team )
						shouldSpawnDropPod = false
					}
				}

				if ( shouldSpawnDropPod )
				{
					array< entity > points = SpawnPoints_GetDropPod()
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					CP_PrintReinforcementTelemetry( team, "droppod", count, squadLimit )
					waitthread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, ent, SquadHandler )
				}
			}
		}
		WaitFrame()
	}
}

void function CP_PrintReinforcementTelemetry( int team, string method, int infantryAlive, int infantryCap )
{
	if ( CP_GetTelemetryMode() == CP_AI_TELEMETRY_OFF )
		return

	print( "NPCWAR_REINFORCEMENT time=" + string( Time() ) + " team=" + string( team ) + " method=" + method + " alive=" + string( infantryAlive ) + " cap=" + string( infantryCap ) + " deficit=" + string( infantryCap - infantryAlive ) + " pressure=" + string( NPCWarDirector_GetPressureLevelForTeam( team ) ) + " dampening=" + string( NPCWarDirector_GetAllyDampeningLevelForTeam( team ) ) )
}

void function Aitdm_SpawnDropShip( entity node, int team )
{
	thread AiGameModes_SpawnDropShip( node.GetOrigin(), node.GetAngles(), team, 4, SquadHandler )
}

void function SpawnerExtend( int team )
{
	//svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	int index = team == TEAM_MILITIA ? 0 : 1

	while( true )
	{
		if( GetGameState() == eGameState.Playing )
		{
			Escalate( team )

			int marvinCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_MARVIN )
			int prowlerCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_PROWLER )
			int stalkerCount = GetNPCArrayEx( "npc_stalker", team, -1, <0,0,0>, -1 ).len()
			int gunshipCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_GUNSHIP )
	        int titanCount = NPCWar_GetTitanPopulationCount( team )
	        int pilotCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_PILOT )


	        // GUNSHIPS
	        if ( file.gunships[ index ] )
			{
				array< entity > points = SpawnPoints_GetDropPod()
				if ( gunshipCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_GUNSHIPS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread AiGameModes_SpawnGunShip( node.GetOrigin(), node.GetAngles(), team)
				}
			}

			// TITANS
			if ( file.titans[ index ] )
			{
				array< entity > points = SpawnPoints_GetDropPod()
				if ( titanCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_TITANS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread AiGameModes_SpawnTitanRandom( node.GetOrigin(), node.GetAngles(), team, TitanHandler )
				}
			}

			// PILOTS
			if ( file.pilots[ index ] )
			{
				array< entity > points = SpawnPoints_GetDropPod()
				if ( pilotCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_PILOTS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					//entity titan = AiGameModes_SpawnTitanRandom( node.GetOrigin(), node.GetAngles(), team, TitanHandler )
					waitthread AiGameModes_SpawnPilotCanEmbark( node.GetOrigin(), node.GetAngles(), team )
				}
			}

			// MARVINS
			if ( file.marvins[ index ] )
			{
				string ent = "npc_marvin"
				array< entity > points = SpawnPoints_GetDropPod()
				if ( marvinCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_MRVNS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					//waitthread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, ent )
					AiGameModes_SpawnNPC( node.GetOrigin(), node.GetAngles(), team, ent )

				}
			}

			// PROWLERS
			if ( file.prowlers[ index ] )
			{
				string ent = "npc_prowler"
				array< entity > points = SpawnPoints_GetDropPod()
				if ( prowlerCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_PROWLERS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					//waitthread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, ent )
					AiGameModes_SpawnNPC( node.GetOrigin(), node.GetAngles(), team, ent )

				}
			}
		}
		else
			break
		WaitFrame()
	}
}

// Based on points tries to balance match
void function Escalate( int team )
{
	int score = NPCWarDirector_GetEscalationScore( team, GameRules_GetTeamScore( team ) )
	int index = team == TEAM_MILITIA ? 1 : 0
	int stage = file.levels[ index ]
	int threshold = NPCWarPilotMode_GetEscalationThresholdForStage( stage )
	// This does the "Enemy x incoming" text
	//string defcon = team == TEAM_MILITIA ? "IMCdefcon" : "MILdefcon"

	if ( score < threshold )
		return

	switch ( stage )
	{
		case 0:
			file.levels[ index ] = 1
			file.marvins[ index ] = true
			file.podEntities[ index ].append( "npc_spectre" )
			//SetGlobalNetInt( defcon, 2 )
			return

		case 1:
			file.levels[ index ] = 2
			file.stalkers[ index ] = true
			file.marvins[ index ] = false
			file.weapondrops[ index ] = true
			file.prowlers[ index ] = true
			file.podEntities[ index ].append( "npc_stalker" )
			//SetGlobalNetInt( defcon, 3 )
			return

		case 2:
			file.levels[ index ] = 3
			file.reapers[ index ] = true
			//SetGlobalNetInt( defcon, 4 )
			return

		case 3:
			file.levels[ index ] = 4
			file.gunships[ index ] = true
			//SetGlobalNetInt( defcon, 5 )
			return


		case 4:
			file.levels[ index ] = 5
			file.prowlers[ index ] = false
			file.pilots[ index ] = true
			file.titans[ index ] = true
			NPCWarPilotMode_UnlockPlayerTitanMeter()
			//SetGlobalNetInt( defcon, 6 )
			return
		default:
			return
	}

	unreachable // hopefully
}

//------------------------------------------------------

int function GetSpawnPointIndex( array< entity > points, int team )
{
	entity zone = DecideSpawnZone_Generic( points, team )

	if ( IsValid( zone ) )
	{
		// 20 Tries to get a random point close to the zone
		for ( int i = 0; i < 20; i++ )
		{
			int index = RandomInt( points.len() )

			if ( Distance2D( points[ index ].GetOrigin(), zone.GetOrigin() ) < 6000 )
				return index
		}
	}

	return RandomInt( points.len() )
}

//------------------------------------------------------

// tells infantry where to go
// In vanilla there seem to be preset paths ai follow to get to the other teams vone and capture it
// AI can also flee deeper into their zone suggesting someone spent way too much time on this
void function SquadHandler( array<entity> guys )
{
	if ( guys.len() == 0 )
		return

	array<entity> players = GetPlayerArrayOfEnemies( guys[0].GetTeam() )
	int squadId = CP_RegisterAISquadAssignment( guys[0].GetTeam(), false )
	entity squadAnchor = CP_GetFirstLivingSquadMember( guys )
	entity currentObjective = CP_ChooseBestHardpointObjective( squadId, guys[0].GetTeam(), guys[0].GetOrigin(), null, false )
	vector point = CP_GetAIObjectivePoint( guys[0].GetTeam(), guys[0].GetOrigin(), currentObjective )
	CP_UpdateAISquadAssignment( squadId, guys[0].GetTeam(), squadAnchor, currentObjective, false )

	OnThreadEnd(
		function() : ( squadId )
		{
			CP_RemoveAISquadAssignment( squadId )
		}
	)

	// Setup AI
	foreach ( guy in guys )
	{
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.AssaultPoint( point )
		guy.AssaultSetGoalRadius( CP_AI_INFANTRY_GOAL_RADIUS )

		// show on enemy radar
		foreach ( player in players )
			guy.Minimap_AlwaysShow( 0, player )


		//thread AITdm_CleanupBoredNPCThread( guy )
	}

	// Keep hardpoint squads focused on objective fights instead of random map skirmishes.
	while ( true )
	{
		squadAnchor = CP_GetFirstLivingSquadMember( guys )

		if ( !IsValid( squadAnchor ) )
			return

		currentObjective = CP_ChooseBestHardpointObjective( squadId, squadAnchor.GetTeam(), squadAnchor.GetOrigin(), currentObjective, false )
		point = CP_GetAIObjectivePoint( squadAnchor.GetTeam(), squadAnchor.GetOrigin(), currentObjective )
		CP_UpdateAISquadAssignment( squadId, squadAnchor.GetTeam(), squadAnchor, currentObjective, false )

		foreach ( guy in guys )
		{
			// Check if alive
			if ( !IsAlive( guy ) )
			{
				guys.removebyvalue( guy )
				continue
			}
			// Stop func if our squad has been killed off
			if ( guys.len() == 0 )
				return

			guy.AssaultPoint( point )
		}
		wait RandomFloatRange(8.0,15.0)
	}
}

void function TitanHandler( entity titan )
{
	int squadId = CP_RegisterAISquadAssignment( titan.GetTeam(), true )
	entity currentObjective = CP_ChooseBestHardpointObjective( squadId, titan.GetTeam(), titan.GetOrigin(), null, true )
	vector point = CP_GetAIObjectivePoint( titan.GetTeam(), titan.GetOrigin(), currentObjective )

	array<entity> players = GetPlayerArrayOfEnemies( titan.GetTeam() )

	CP_UpdateAISquadAssignment( squadId, titan.GetTeam(), titan, currentObjective, true )
	OnThreadEnd(
		function() : ( squadId )
		{
			CP_RemoveAISquadAssignment( squadId )
		}
	)

	// Setup AI
	titan.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
	//titan.SetNumRodeoSlots(0) Better method used
	titan.AssaultPoint( point )
	titan.AssaultSetGoalRadius( CP_AI_TITAN_GOAL_RADIUS )

	// show on enemy radar
	foreach ( player in players )
		titan.Minimap_AlwaysShow( 0, player )


	//thread AITdm_CleanupBoredNPCThread( guy )

	// Every 8 - 15 secs refresh the objective focus.
	while ( true )
	{
		// Check if alive
		if ( !IsAlive( titan ) )
			return

		currentObjective = CP_ChooseBestHardpointObjective( squadId, titan.GetTeam(), titan.GetOrigin(), currentObjective, true )
		point = CP_GetAIObjectivePoint( titan.GetTeam(), titan.GetOrigin(), currentObjective )
		CP_UpdateAISquadAssignment( squadId, titan.GetTeam(), titan, currentObjective, true )
		titan.AssaultPoint( point )
		wait RandomFloatRange(8.0,15.0)
	}
}

entity function CP_GetFirstLivingSquadMember( array<entity> guys )
{
	foreach ( entity guy in guys )
	{
		if ( IsAlive( guy ) )
			return guy
	}

	return null
}

int function CP_RegisterAISquadAssignment( int team, bool heavy )
{
	int squadId = file.nextAISquadAssignmentId
	file.nextAISquadAssignmentId++

	CP_AISquadAssignment assignment
	assignment.id = squadId
	assignment.team = team
	assignment.anchor = null
	assignment.objective = null
	assignment.heavy = heavy

	file.aiSquadAssignments.append( assignment )
	return squadId
}

void function CP_UpdateAISquadAssignment( int squadId, int team, entity anchor, entity objective, bool heavy )
{
	int index = CP_FindAISquadAssignmentIndex( squadId )

	if ( index < 0 )
		return

	CP_AISquadAssignment assignment = file.aiSquadAssignments[index]
	assignment.team = team
	assignment.anchor = anchor
	assignment.objective = objective
	assignment.heavy = heavy
	file.aiSquadAssignments[index] = assignment
}

void function CP_RemoveAISquadAssignment( int squadId )
{
	int index = CP_FindAISquadAssignmentIndex( squadId )

	if ( index >= 0 )
		file.aiSquadAssignments.remove( index )
}

int function CP_FindAISquadAssignmentIndex( int squadId )
{
	for ( int i = 0; i < file.aiSquadAssignments.len(); i++ )
	{
		if ( file.aiSquadAssignments[i].id == squadId )
			return i
	}

	return -1
}

vector function CP_GetAIObjectivePoint( int team, vector fromPos, entity objective )
{
	if ( IsValid( objective ) )
		return objective.GetOrigin()

	return CP_GetFallbackEnemyOrigin( team, fromPos )
}

entity function CP_ChooseBestHardpointObjective( int squadId, int team, vector fromPos, entity currentObjective, bool heavy )
{
	entity coverageObjective = CP_ChooseRequiredStrategicCommitmentObjective( squadId, team, fromPos )
	entity utilityObjective = null
	if ( !IsValid( coverageObjective ) || CP_GetTelemetryMode() != CP_AI_TELEMETRY_OFF )
		utilityObjective = CP_ChooseUtilityHardpointObjective( squadId, team, fromPos, currentObjective, heavy, false )
	entity selectedObjective = IsValid( coverageObjective ) ? coverageObjective : utilityObjective

	CP_RecordObjectiveDecision( squadId, team, fromPos, currentObjective, selectedObjective, utilityObjective, heavy )
	if ( IsValid( selectedObjective ) )
		return selectedObjective

	return null
}

entity function CP_ChooseUtilityHardpointObjective( int squadId, int team, vector fromPos, entity currentObjective, bool heavy, bool ignoreReassignMargin )
{
	entity bestHardpoint = null
	float bestScore = -999999.0
	float currentScore = -999999.0

	foreach ( HardpointStruct hardpoint in file.hardpoints )
	{
		if ( !IsValid( hardpoint.hardpoint ) )
			continue

		float score = CP_ScoreHardpointForSquad( squadId, team, fromPos, hardpoint, currentObjective, heavy )

		if ( CP_GetTelemetryMode() >= CP_AI_TELEMETRY_DETAILED )
			CP_DebugObjectiveCandidate( squadId, team, fromPos, hardpoint, currentObjective, score )

		if ( IsValid( currentObjective ) && hardpoint.hardpoint == currentObjective )
			currentScore = score

		if ( !IsValid( bestHardpoint ) || score > bestScore )
		{
			bestHardpoint = hardpoint.hardpoint
			bestScore = score
		}
	}

	if ( !IsValid( bestHardpoint ) )
		return null

	if ( !ignoreReassignMargin && IsValid( currentObjective ) && bestHardpoint != currentObjective && currentScore > -999000.0 && bestScore < currentScore + CP_AI_REASSIGN_SCORE_MARGIN )
		return currentObjective

	return bestHardpoint
}

entity function CP_ChooseRequiredStrategicCommitmentObjective( int squadId, int team, vector fromPos )
{
	// With no foothold, any enemy point is useful and squads may mass at the nearest one.
	if ( CP_GetOwnedHardpointCount( team ) == 0 )
		return null

	entity bestHardpoint = null
	float bestNeedScore = -999999.0

	foreach ( HardpointStruct hardpoint in file.hardpoints )
	{
		if ( !IsValid( hardpoint.hardpoint ) )
			continue

		int assigned = CP_GetAssignedSquadsForHardpoint( team, hardpoint.hardpoint, squadId )
		int desiredCommitment = CP_GetDesiredCommitmentForHardpoint( team, hardpoint )

		if ( assigned >= desiredCommitment )
			continue

		float needScore = float( desiredCommitment - assigned ) * 1000.0

		if ( hardpoint.hardpoint.GetTeam() == team )
		{
			if ( CP_HardpointHasLivingCappersForTeam( hardpoint, GetOtherTeam( team ) ) )
				needScore += 500.0
			else if ( file.ampingEnabled && GetHardpointCaptureProgress( hardpoint ) < 2.0 )
				needScore += 250.0
		}
		else if ( CP_HardpointEnemyIsAmping( team, hardpoint ) )
		{
			needScore += 400.0
		}
		else if ( assigned == 0 )
		{
			needScore += 150.0
		}

		needScore -= Distance2D( fromPos, hardpoint.hardpoint.GetOrigin() ) / 1000.0

		if ( !IsValid( bestHardpoint ) || needScore > bestNeedScore )
		{
			bestHardpoint = hardpoint.hardpoint
			bestNeedScore = needScore
		}
	}

	return bestHardpoint
}

float function CP_ScoreHardpointForSquad( int squadId, int team, vector fromPos, HardpointStruct hardpoint, entity currentObjective, bool heavy )
{
	entity hardpointEnt = hardpoint.hardpoint
	CP_HardpointDecisionState state
	state.owner = hardpointEnt.GetTeam()
	state.cappingTeam = GetHardpointCappingTeam( hardpoint )
	state.progress = GetHardpointCaptureProgress( hardpoint )
	state.distance = Distance2D( fromPos, hardpointEnt.GetOrigin() )
	state.assigned = CP_GetAssignedSquadsForHardpoint( team, hardpointEnt, squadId )
	state.practicalCoverage = CP_GetPracticalCoverageForHardpoint( team, hardpoint, squadId )
	state.desiredCommitment = CP_GetDesiredCommitmentForHardpoint( team, hardpoint )
	state.ownedCount = CP_GetOwnedHardpointCount( team )
	state.ampingEnabled = file.ampingEnabled
	state.alliedPresent = CP_HardpointHasLivingCappersForTeam( hardpoint, team )
	state.enemyPresent = CP_HardpointHasLivingCappersForTeam( hardpoint, GetOtherTeam( team ) )
	state.onlyRemainingUncontrolled = CP_IsOnlyRemainingUncontrolledHardpoint( team, hardpoint )
	state.allPointsEnemyOwned = CP_AllHardpointsEnemyOwnedForTeam( team )
	state.current = IsValid( currentObjective ) && currentObjective == hardpointEnt
	return CP_ScoreHardpointState( team, state, heavy, false )
}

float function CP_ScoreHardpointState( int team, CP_HardpointDecisionState state, bool heavy, bool strongerOvercommitmentPenalty )
{
	bool ownedByTeam = state.owner == team
	bool contestedByEnemy = ownedByTeam && state.enemyPresent
	float score = 0.0

	score -= ( state.distance / 1000.0 ) * CP_AI_DISTANCE_PENALTY_PER_1000_UNITS

	if ( state.allPointsEnemyOwned && !state.alliedPresent && !CP_HardpointStateCaptureNearlyCompleteForTeam( team, state ) )
	{
		score += CP_AI_SCORE_ENEMY_POINT
		return score
	}

	if ( ownedByTeam )
	{
		if ( contestedByEnemy )
		{
			score += CP_AI_SCORE_OWNED_CONTESTED

			if ( state.distance <= CP_AI_NEAR_RESPONSE_DISTANCE )
				score += CP_AI_SCORE_NEAR_DEFENSE_RESPONSE

			if ( state.practicalCoverage < state.desiredCommitment )
				score += CP_AI_SCORE_UNDERCOVERED_DEFENSE
		}
		else if ( state.ampingEnabled && state.progress < 2.0 )
		{
			score += CP_AI_SCORE_NEEDS_AMPING

			if ( state.practicalCoverage == 0 )
				score += CP_AI_SCORE_UNCOVERED_AMP

			if ( state.progress >= 1.0 )
				score += CP_AI_SCORE_PARTIAL_AMP
		}
		else
		{
			score += CP_AI_SCORE_SAFE_OWNED

			if ( state.practicalCoverage == 0 )
				score += CP_AI_SCORE_UNCOVERED_SAFE
			else
				score -= CP_AI_SCORE_REDUNDANT_SAFE_PENALTY
		}
	}
	else
	{
		if ( state.onlyRemainingUncontrolled )
		{
			score += CP_AI_SCORE_ONLY_UNCONTROLLED
		}
		else if ( CP_HardpointStateEnemyIsAmping( team, state ) )
		{
			score += CP_AI_SCORE_ENEMY_AMPING

			if ( state.distance <= CP_AI_NEAR_RESPONSE_DISTANCE )
				score += CP_AI_SCORE_NEAR_ENEMY_AMPING
		}
		else if ( state.owner == TEAM_UNASSIGNED )
		{
			score += CP_AI_SCORE_NEUTRAL_POINT
		}
		else
		{
			score += CP_AI_SCORE_ENEMY_POINT
		}

		if ( state.assigned == 0 )
			score += CP_AI_SCORE_NO_ASSIGNMENT

		if ( state.alliedPresent )
			score += CP_AI_SCORE_ALLIED_PRESENT

		if ( state.enemyPresent )
			score += CP_AI_SCORE_ENEMY_PRESENT

		if ( CP_HardpointStateCaptureNearlyCompleteForTeam( team, state ) )
			score += CP_AI_SCORE_NEARLY_COMPLETE

		if ( state.ownedCount == 0 )
			score += CP_AI_SCORE_NO_OWNED_POINTS
	}

	if ( ( !state.onlyRemainingUncontrolled || strongerOvercommitmentPenalty ) && state.assigned >= state.desiredCommitment )
	{
		float saturationPenalty = strongerOvercommitmentPenalty ? CP_AI_SCORE_SATURATION_PENALTY * 2.0 : CP_AI_SCORE_SATURATION_PENALTY
		score -= float( state.assigned - state.desiredCommitment + 1 ) * saturationPenalty
	}

	if ( state.current )
	{
		score += CP_AI_SCORE_CURRENT_OBJECTIVE

		if ( state.distance <= CP_AI_CLOSE_TO_OBJECTIVE_DISTANCE )
			score += CP_AI_SCORE_CURRENT_CLOSE

		if ( CP_HardpointStateCaptureNearlyCompleteForTeam( team, state ) )
			score += CP_AI_SCORE_CURRENT_NEARLY_COMPLETE

		if ( ownedByTeam && contestedByEnemy && state.practicalCoverage <= state.desiredCommitment )
			score += CP_AI_SCORE_CURRENT_CRITICAL_DEFENSE
	}

	if ( heavy )
		score += CP_AI_SCORE_HEAVY_UNIT

	return score
}

bool function CP_HardpointStateEnemyIsAmping( int team, CP_HardpointDecisionState state )
{
	int enemyTeam = GetOtherTeam( team )
	return state.ampingEnabled && state.owner == enemyTeam && state.cappingTeam == enemyTeam && state.progress > 1.0 && state.progress < 2.0
}

bool function CP_HardpointStateCaptureNearlyCompleteForTeam( int team, CP_HardpointDecisionState state )
{
	if ( state.cappingTeam != team )
		return false
	if ( state.owner == TEAM_UNASSIGNED && state.progress >= 0.75 )
		return true
	if ( state.owner == GetOtherTeam( team ) && state.progress <= 0.25 )
		return true
	return state.owner == team && state.ampingEnabled && state.progress >= 1.75 && state.progress < 2.0
}

bool function CP_HardpointHasLivingCappersForTeam( HardpointStruct hardpoint, int team )
{
	array<entity> cappers = team == TEAM_IMC ? hardpoint.imcCappers : hardpoint.militiaCappers

	foreach ( entity capper in cappers )
	{
		if ( IsValid( capper ) && IsAlive( capper ) && capper.GetTeam() == team )
			return true
	}

	return false
}

int function CP_GetLivingCapperCountForTeam( HardpointStruct hardpoint, int team )
{
	array<entity> cappers = team == TEAM_IMC ? hardpoint.imcCappers : hardpoint.militiaCappers
	int count = 0

	foreach ( entity capper in cappers )
	{
		if ( IsValid( capper ) && IsAlive( capper ) && capper.GetTeam() == team )
			count++
	}

	return count
}

int function CP_GetAssignedSquadsForHardpoint( int team, entity hardpoint, int excludeSquadId )
{
	int count = 0

	foreach ( CP_AISquadAssignment assignment in file.aiSquadAssignments )
	{
		if ( assignment.id == excludeSquadId )
			continue
		if ( assignment.team != team )
			continue
		if ( !IsValid( assignment.anchor ) || !IsAlive( assignment.anchor ) )
			continue
		if ( !IsValid( assignment.objective ) || assignment.objective != hardpoint )
			continue

		count++
	}

	return count
}

int function CP_GetPracticalCoverageForHardpoint( int team, HardpointStruct hardpoint, int excludeSquadId )
{
	int coverage = CP_GetLivingCapperCountForTeam( hardpoint, team )

	foreach ( CP_AISquadAssignment assignment in file.aiSquadAssignments )
	{
		if ( assignment.id == excludeSquadId )
			continue
		if ( assignment.team != team )
			continue
		if ( !IsValid( assignment.anchor ) || !IsAlive( assignment.anchor ) )
			continue
		if ( !IsValid( assignment.objective ) || assignment.objective != hardpoint.hardpoint )
			continue

		if ( Distance2D( assignment.anchor.GetOrigin(), hardpoint.hardpoint.GetOrigin() ) <= CP_AI_PRACTICAL_COVERAGE_RADIUS )
			coverage++
	}

	return coverage
}

int function CP_GetDesiredCommitmentForHardpoint( int team, HardpointStruct hardpoint )
{
	int hardpointTeam = hardpoint.hardpoint.GetTeam()
	bool contested = CP_HardpointHasLivingCappersForTeam( hardpoint, GetOtherTeam( team ) )
	bool enemyAmping = CP_HardpointEnemyIsAmping( team, hardpoint )
	float progress = GetHardpointCaptureProgress( hardpoint )
	return CP_GetDesiredCommitmentForState( team, hardpointTeam, contested, enemyAmping, progress, file.ampingEnabled )
}

int function CP_GetDesiredCommitmentForState( int team, int hardpointTeam, bool contested, bool enemyAmping, float progress, bool ampingEnabled )
{
	if ( hardpointTeam == team )
	{
		if ( contested )
			return 2

		if ( ampingEnabled && progress < 2.0 )
			return 1

		return 0
	}

	if ( enemyAmping )
		return 2

	return 1
}

bool function CP_IsOnlyRemainingUncontrolledHardpoint( int team, HardpointStruct hardpoint )
{
	if ( hardpoint.hardpoint.GetTeam() == team )
		return false

	return CP_GetUncontrolledHardpointCount( team ) == 1
}

bool function CP_AllHardpointsEnemyOwnedForTeam( int team )
{
	int enemyTeam = GetOtherTeam( team )
	int validHardpoints = 0

	foreach ( HardpointStruct hardpoint in file.hardpoints )
	{
		if ( !IsValid( hardpoint.hardpoint ) )
			continue

		validHardpoints++

		if ( hardpoint.hardpoint.GetTeam() != enemyTeam )
			return false
	}

	return validHardpoints > 0
}

int function CP_GetOwnedHardpointCount( int team )
{
	int count = 0

	foreach ( HardpointStruct hardpoint in file.hardpoints )
	{
		if ( IsValid( hardpoint.hardpoint ) && hardpoint.hardpoint.GetTeam() == team )
			count++
	}

	return count
}

int function CP_GetUncontrolledHardpointCount( int team )
{
	int count = 0

	foreach ( HardpointStruct hardpoint in file.hardpoints )
	{
		if ( IsValid( hardpoint.hardpoint ) && hardpoint.hardpoint.GetTeam() != team )
			count++
	}

	return count
}

bool function CP_HardpointEnemyIsAmping( int team, HardpointStruct hardpoint )
{
	int enemyTeam = GetOtherTeam( team )

	if ( !file.ampingEnabled )
		return false

	if ( hardpoint.hardpoint.GetTeam() != enemyTeam )
		return false

	if ( GetHardpointCappingTeam( hardpoint ) != enemyTeam )
		return false

	float progress = GetHardpointCaptureProgress( hardpoint )
	return progress > 1.0 && progress < 2.0
}

bool function CP_HardpointCaptureNearlyCompleteForTeam( int team, HardpointStruct hardpoint )
{
	int hardpointTeam = hardpoint.hardpoint.GetTeam()
	int cappingTeam = GetHardpointCappingTeam( hardpoint )
	float progress = GetHardpointCaptureProgress( hardpoint )

	if ( cappingTeam != team )
		return false

	if ( hardpointTeam == TEAM_UNASSIGNED && progress >= 0.75 )
		return true

	if ( hardpointTeam == GetOtherTeam( team ) && progress <= 0.25 )
		return true

	if ( hardpointTeam == team && file.ampingEnabled && progress >= 1.75 && progress < 2.0 )
		return true

	return false
}

int function CP_GetTelemetryMode()
{
	int mode = GetCurrentPlaylistVarInt( "npcwar_cp_telemetry", CP_AI_TELEMETRY_OFF )
	if ( mode < CP_AI_TELEMETRY_OFF || mode > CP_AI_TELEMETRY_DETAILED )
		return CP_AI_TELEMETRY_OFF

	return mode
}

int function CP_GetTelemetryTeamIndex( int team )
{
	return team == TEAM_IMC ? 0 : 1
}

string function CP_GetTelemetryHardpointName( entity hardpoint )
{
	return IsValid( hardpoint ) ? GetHardpointGroup( hardpoint ) : "none"
}

void function CP_RecordObjectiveDecision( int squadId, int team, vector fromPos, entity currentObjective, entity selectedObjective, entity utilityObjective, bool heavy )
{
	int mode = CP_GetTelemetryMode()
	if ( mode == CP_AI_TELEMETRY_OFF )
		return

	int index = CP_GetTelemetryTeamIndex( team )
	file.aiTelemetryDecisions[index]++

	if ( IsValid( currentObjective ) && IsValid( selectedObjective ) && currentObjective != selectedObjective )
		file.aiTelemetrySwitches[index]++

	if ( IsValid( selectedObjective ) && IsValid( utilityObjective ) && selectedObjective != utilityObjective )
		file.aiTelemetryShadowDisagreements[index]++

	if ( mode < CP_AI_TELEMETRY_DETAILED )
		return

	print( "NPCWAR_CP_DECISION time=" + string( Time() ) + " team=" + string( team ) + " squad=" + string( squadId ) + " heavy=" + string( heavy ) + " current=" + CP_GetTelemetryHardpointName( currentObjective ) + " selected=" + CP_GetTelemetryHardpointName( selectedObjective ) + " utility_shadow=" + CP_GetTelemetryHardpointName( utilityObjective ) + " x=" + string( fromPos.x ) + " y=" + string( fromPos.y ) )
}

void function CP_HardpointTelemetryThink()
{
	while ( GamePlayingOrSuddenDeath() )
	{
		CP_PrintHardpointTelemetrySnapshot()
		wait CP_AI_TELEMETRY_SNAPSHOT_INTERVAL
	}

	CP_PrintHardpointTelemetrySnapshot()
	CP_PrintHardpointTelemetryMatchSummary()
}

void function CP_PrintHardpointTelemetrySnapshot()
{
	foreach ( int team in [ TEAM_IMC, TEAM_MILITIA ] )
	{
		int index = CP_GetTelemetryTeamIndex( team )
		int activeSquads = 0
		foreach ( CP_AISquadAssignment assignment in file.aiSquadAssignments )
		{
			if ( assignment.team == team && IsValid( assignment.anchor ) && IsAlive( assignment.anchor ) )
				activeSquads++
		}

		int owned = 0
		int ampedOwned = 0
		int required = 0
		int assignedMet = 0
		int practicalMet = 0
		int totalAssigned = 0
		int largestAssignment = 0
		int surplus = 0
		string points = ""
		foreach ( HardpointStruct hardpoint in file.hardpoints )
		{
			if ( !IsValid( hardpoint.hardpoint ) )
				continue

			int assigned = CP_GetAssignedSquadsForHardpoint( team, hardpoint.hardpoint, -1 )
			int practical = CP_GetPracticalCoverageForHardpoint( team, hardpoint, -1 )
			int desired = CP_GetDesiredCommitmentForHardpoint( team, hardpoint )
			if ( hardpoint.hardpoint.GetTeam() == team )
			{
				owned++
				if ( GetHardpointCaptureProgress( hardpoint ) >= 2.0 )
					ampedOwned++
			}
			if ( desired > 0 )
			{
				required++
				if ( assigned >= desired )
					assignedMet++
				if ( practical >= desired )
					practicalMet++
			}
			totalAssigned += assigned
			largestAssignment = maxint( largestAssignment, assigned )
			surplus += maxint( 0, assigned - desired )
			points += CP_GetTelemetryHardpointName( hardpoint.hardpoint ) + ":owner=" + string( hardpoint.hardpoint.GetTeam() ) + ",cap=" + string( GetHardpointCappingTeam( hardpoint ) ) + ",progress=" + string( GetHardpointCaptureProgress( hardpoint ) ) + ",assigned=" + string( assigned ) + ",practical=" + string( practical ) + ",desired=" + string( desired ) + ";"
		}

		float largestShare = totalAssigned > 0 ? float( largestAssignment ) / float( totalAssigned ) : 0.0
		file.aiTelemetrySnapshots[index]++
		file.aiTelemetryOwnedPointSamples[index] += owned
		if ( owned == 3 )
			file.aiTelemetryFullControlSamples[index]++
		if ( owned == 0 )
			file.aiTelemetryZeroControlSamples[index]++
		file.aiTelemetryAmpedOwnedSamples[index] += ampedOwned
		file.aiTelemetryRequiredCommitments[index] += required
		file.aiTelemetryAssignedCommitmentsMet[index] += assignedMet
		file.aiTelemetryPracticalCommitmentsMet[index] += practicalMet
		file.aiTelemetrySurplusAssignments[index] += surplus
		file.aiTelemetryLargestShareTotal[index] += largestShare

		int enemyTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC
		print( "NPCWAR_CP_SNAPSHOT time=" + string( Time() ) + " team=" + string( team ) + " score=" + string( GameRules_GetTeamScore( team ) ) + " enemy_score=" + string( GameRules_GetTeamScore( enemyTeam ) ) + " infantry_cap=" + string( NPCWarDirector_GetSquadSpawnLimitForTelemetry( team ) ) + " pressure=" + string( NPCWarDirector_GetPressureLevelForTeam( team ) ) + " dampening=" + string( NPCWarDirector_GetAllyDampeningLevelForTeam( team ) ) + " squads=" + string( activeSquads ) + " owned=" + string( owned ) + " amped_owned=" + string( ampedOwned ) + " required=" + string( required ) + " assigned_met=" + string( assignedMet ) + " practical_met=" + string( practicalMet ) + " surplus=" + string( surplus ) + " largest_share=" + string( largestShare ) + " decisions=" + string( file.aiTelemetryDecisions[index] ) + " switches=" + string( file.aiTelemetrySwitches[index] ) + " shadow_disagreements=" + string( file.aiTelemetryShadowDisagreements[index] ) + " points=" + points )
	}
}

void function CP_PrintHardpointTelemetryMatchSummary()
{
	foreach ( int team in [ TEAM_IMC, TEAM_MILITIA ] )
	{
		int index = CP_GetTelemetryTeamIndex( team )
		int snapshots = file.aiTelemetrySnapshots[index]
		if ( snapshots == 0 )
			continue

		float averageOwned = float( file.aiTelemetryOwnedPointSamples[index] ) / float( snapshots )
		float averageAmpedOwned = float( file.aiTelemetryAmpedOwnedSamples[index] ) / float( snapshots )
		float assignedCoverage = file.aiTelemetryRequiredCommitments[index] > 0 ? float( file.aiTelemetryAssignedCommitmentsMet[index] ) / float( file.aiTelemetryRequiredCommitments[index] ) : 1.0
		float practicalCoverage = file.aiTelemetryRequiredCommitments[index] > 0 ? float( file.aiTelemetryPracticalCommitmentsMet[index] ) / float( file.aiTelemetryRequiredCommitments[index] ) : 1.0
		float averageLargestShare = file.aiTelemetryLargestShareTotal[index] / float( snapshots )
		int enemyTeam = team == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

		print( "NPCWAR_CP_MATCH_SUMMARY team=" + string( team ) + " final_score=" + string( GameRules_GetTeamScore( team ) ) + " enemy_score=" + string( GameRules_GetTeamScore( enemyTeam ) ) + " snapshots=" + string( snapshots ) + " avg_owned=" + string( averageOwned ) + " avg_amped_owned=" + string( averageAmpedOwned ) + " full_control=" + string( file.aiTelemetryFullControlSamples[index] ) + " zero_control=" + string( file.aiTelemetryZeroControlSamples[index] ) + " assigned_coverage=" + string( assignedCoverage ) + " practical_coverage=" + string( practicalCoverage ) + " surplus=" + string( file.aiTelemetrySurplusAssignments[index] ) + " avg_largest_share=" + string( averageLargestShare ) + " decisions=" + string( file.aiTelemetryDecisions[index] ) + " switches=" + string( file.aiTelemetrySwitches[index] ) + " shadow_disagreements=" + string( file.aiTelemetryShadowDisagreements[index] ) )
	}
}

void function CP_RunHardpointScenarioTests()
{
	int failures = 0
	int cases = 0
	failures += CP_TestDesiredCommitment( "owned_amp_complete", 0, CP_GetDesiredCommitmentForState( TEAM_IMC, TEAM_IMC, false, false, 2.0, true ) )
	failures += CP_TestDesiredCommitment( "owned_needs_amp", 1, CP_GetDesiredCommitmentForState( TEAM_IMC, TEAM_IMC, false, false, 1.0, true ) )
	failures += CP_TestDesiredCommitment( "owned_contested", 2, CP_GetDesiredCommitmentForState( TEAM_IMC, TEAM_IMC, true, false, 2.0, true ) )
	failures += CP_TestDesiredCommitment( "enemy_unoccupied", 1, CP_GetDesiredCommitmentForState( TEAM_IMC, TEAM_MILITIA, false, false, 2.0, true ) )
	failures += CP_TestDesiredCommitment( "enemy_amping", 2, CP_GetDesiredCommitmentForState( TEAM_IMC, TEAM_MILITIA, false, true, 1.5, true ) )
	failures += CP_TestDesiredCommitment( "neutral", 1, CP_GetDesiredCommitmentForState( TEAM_IMC, TEAM_UNASSIGNED, false, false, 0.0, true ) )
	failures += CP_TestDesiredCommitment( "mirror_owned_needs_amp", 1, CP_GetDesiredCommitmentForState( TEAM_MILITIA, TEAM_MILITIA, false, false, 1.0, true ) )
	failures += CP_TestDesiredCommitment( "mirror_enemy_amping", 2, CP_GetDesiredCommitmentForState( TEAM_MILITIA, TEAM_IMC, false, true, 1.5, true ) )
	cases += 8

	for ( int i = 0; i < 200; i++ )
	{
		int ownerRoll = RandomInt( 3 )
		int owner = ownerRoll == 0 ? TEAM_IMC : ownerRoll == 1 ? TEAM_MILITIA : TEAM_UNASSIGNED
		bool contested = RandomInt( 2 ) == 1
		bool enemyAmping = RandomInt( 2 ) == 1
		float progress = RandomFloatRange( 0.0, 2.0 )
		int desired = CP_GetDesiredCommitmentForState( TEAM_IMC, owner, contested, enemyAmping, progress, true )
		if ( desired < 0 || desired > 2 )
			failures++
	}
	cases += 200

	array<CP_TestScenario> scenarios = CP_BuildHardpointTestScenarios()
	foreach ( CP_TestScenario scenario in scenarios )
	{
		array<int> strategyFailures = [ 0, 0, 0 ]
		array<int> concentrationFailures = [ 0, 0, 0 ]
		array<int> allocationTotals = [ 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
		array<int> switchTotals = [ 0, 0, 0 ]

		for ( int variant = 0; variant < CP_AI_TEST_VARIANTS; variant++ )
		{
			for ( int strategy = CP_AI_TEST_STRATEGY_UTILITY; strategy <= CP_AI_TEST_STRATEGY_STRONG_SATURATION; strategy++ )
			{
				CP_TestAllocationResult result = CP_SimulateHardpointScenario( scenario, strategy, variant )
				bool coveragePassed = CP_TestAllocationMeetsCoverage( result.allocations, scenario.requiredCoverage )
				bool concentrationPassed = scenario.allowFullConcentration || !CP_TestAllocationIsFullyConcentrated( result.allocations )

				if ( !coveragePassed )
					strategyFailures[strategy]++
				if ( !concentrationPassed )
					concentrationFailures[strategy]++

				for ( int pointIndex = 0; pointIndex < 3; pointIndex++ )
					allocationTotals[strategy * 3 + pointIndex] += result.allocations[pointIndex]
				switchTotals[strategy] += result.switches
			}
			cases++
		}

		failures += strategyFailures[CP_AI_TEST_STRATEGY_CURRENT]
		failures += concentrationFailures[CP_AI_TEST_STRATEGY_CURRENT]
		CP_PrintScenarioComparison( scenario, strategyFailures, concentrationFailures, allocationTotals, switchTotals )
	}

	print( "NPCWAR_CP_TESTS cases=" + string( cases ) + " failures=" + string( failures ) )
}

array<CP_TestScenario> function CP_BuildHardpointTestScenarios()
{
	array<CP_TestScenario> scenarios
	array<CP_TestSquad> squads = CP_BuildTestSquads( 8 )

	scenarios.append( CP_CreateTestScenario( "own_ac_unamped", [ CP_CreateTestPoint( "A", TEAM_IMC, TEAM_IMC, 1.2, < -3000, 0, 0> ), CP_CreateTestPoint( "B", TEAM_MILITIA, TEAM_UNASSIGNED, 2.0, <0, 0, 0> ), CP_CreateTestPoint( "C", TEAM_IMC, TEAM_IMC, 1.1, <3000, 0, 0> ) ], squads, [ 1, 1, 1 ], false ) )
	scenarios.append( CP_CreateTestScenario( "own_ac_amped", [ CP_CreateTestPoint( "A", TEAM_IMC, TEAM_IMC, 2.0, < -3000, 0, 0> ), CP_CreateTestPoint( "B", TEAM_MILITIA, TEAM_UNASSIGNED, 2.0, <0, 0, 0> ), CP_CreateTestPoint( "C", TEAM_IMC, TEAM_IMC, 2.0, <3000, 0, 0> ) ], squads, [ 0, 1, 0 ], true ) )
	scenarios.append( CP_CreateTestScenario( "enemy_ac_amping", [ CP_CreateTestPoint( "A", TEAM_MILITIA, TEAM_MILITIA, 1.4, < -3000, 0, 0> ), CP_CreateTestPoint( "B", TEAM_IMC, TEAM_IMC, 2.0, <0, 0, 0> ), CP_CreateTestPoint( "C", TEAM_MILITIA, TEAM_MILITIA, 1.6, <3000, 0, 0> ) ], squads, [ 2, 0, 2 ], false ) )
	scenarios.append( CP_CreateTestScenario( "owned_a_contested", [ CP_CreateTestPointWithPresence( "A", TEAM_IMC, TEAM_MILITIA, 1.8, < -3000, 0, 0>, true, true ), CP_CreateTestPoint( "B", TEAM_IMC, TEAM_IMC, 2.0, <0, 0, 0> ), CP_CreateTestPoint( "C", TEAM_MILITIA, TEAM_UNASSIGNED, 2.0, <3000, 0, 0> ) ], squads, [ 2, 0, 1 ], false ) )
	scenarios.append( CP_CreateTestScenario( "no_foothold", [ CP_CreateTestPoint( "A", TEAM_MILITIA, TEAM_MILITIA, 2.0, < -3000, 0, 0> ), CP_CreateTestPoint( "B", TEAM_MILITIA, TEAM_MILITIA, 2.0, <0, 0, 0> ), CP_CreateTestPoint( "C", TEAM_MILITIA, TEAM_MILITIA, 2.0, <3000, 0, 0> ) ], squads, [ 0, 0, 0 ], true ) )
	scenarios.append( CP_CreateTestScenario( "all_owned_b_contested", [ CP_CreateTestPoint( "A", TEAM_IMC, TEAM_IMC, 2.0, < -3000, 0, 0> ), CP_CreateTestPointWithPresence( "B", TEAM_IMC, TEAM_MILITIA, 1.7, <0, 0, 0>, true, true ), CP_CreateTestPoint( "C", TEAM_IMC, TEAM_IMC, 2.0, <3000, 0, 0> ) ], squads, [ 0, 2, 0 ], true ) )
	return scenarios
}

CP_TestHardpoint function CP_CreateTestPoint( string name, int owner, int cappingTeam, float progress, vector origin )
{
	return CP_CreateTestPointWithPresence( name, owner, cappingTeam, progress, origin, false, false )
}

CP_TestHardpoint function CP_CreateTestPointWithPresence( string name, int owner, int cappingTeam, float progress, vector origin, bool friendlyPresent, bool enemyPresent )
{
	CP_TestHardpoint point
	point.name = name
	point.owner = owner
	point.cappingTeam = cappingTeam
	point.progress = progress
	point.origin = origin
	point.friendlyPresent = friendlyPresent
	point.enemyPresent = enemyPresent
	return point
}

array<CP_TestSquad> function CP_BuildTestSquads( int count )
{
	array<CP_TestSquad> squads
	for ( int i = 0; i < count; i++ )
	{
		CP_TestSquad squad
		squad.origin = <float( ( i % 4 ) * 1400 - 2100 ), float( ( i / 4 ) * 1800 - 900 ), 0>
		squad.currentObjective = i % 3
		squad.heavy = i == count - 1
		squads.append( squad )
	}
	return squads
}

CP_TestScenario function CP_CreateTestScenario( string name, array<CP_TestHardpoint> points, array<CP_TestSquad> squads, array<int> requiredCoverage, bool allowFullConcentration )
{
	CP_TestScenario scenario
	scenario.name = name
	scenario.points = points
	scenario.squads = squads
	scenario.requiredCoverage = requiredCoverage
	scenario.allowFullConcentration = allowFullConcentration
	return scenario
}

CP_TestAllocationResult function CP_SimulateHardpointScenario( CP_TestScenario scenario, int strategy, int variant )
{
	CP_TestAllocationResult result
	result.allocations = [ 0, 0, 0 ]
	result.switches = 0
	int squadCount = scenario.squads.len()

	for ( int decision = 0; decision < squadCount; decision++ )
	{
		int squadIndex = variant % 2 == 0 ? ( decision + variant ) % squadCount : ( squadCount - 1 - decision + variant ) % squadCount
		CP_TestSquad squad = scenario.squads[squadIndex]
		int selected = CP_ChooseSyntheticHardpointObjective( scenario, squad, result.allocations, strategy, variant, squadIndex )
		result.allocations[selected]++
		if ( squad.currentObjective >= 0 && squad.currentObjective != selected )
			result.switches++
	}

	return result
}

int function CP_ChooseSyntheticHardpointObjective( CP_TestScenario scenario, CP_TestSquad squad, array<int> allocations, int strategy, int variant, int squadIndex )
{
	int ownedCount = 0
	int uncontrolledCount = 0
	bool allEnemyOwned = true
	foreach ( CP_TestHardpoint point in scenario.points )
	{
		if ( point.owner == TEAM_IMC )
			ownedCount++
		else
			uncontrolledCount++
		if ( point.owner != TEAM_MILITIA )
			allEnemyOwned = false
	}

	if ( strategy == CP_AI_TEST_STRATEGY_CURRENT && ownedCount > 0 )
	{
		int requiredPoint = CP_ChooseSyntheticRequiredCommitment( scenario, squad, allocations, variant, squadIndex )
		if ( requiredPoint >= 0 )
			return requiredPoint
	}

	int bestPoint = 0
	float bestScore = -999999.0
	float currentScore = -999999.0
	for ( int pointIndex = 0; pointIndex < scenario.points.len(); pointIndex++ )
	{
		CP_HardpointDecisionState state = CP_BuildSyntheticDecisionState( scenario, squad, allocations, pointIndex, ownedCount, uncontrolledCount, allEnemyOwned, variant, squadIndex )
		float score = CP_ScoreHardpointState( TEAM_IMC, state, squad.heavy, strategy == CP_AI_TEST_STRATEGY_STRONG_SATURATION )
		if ( pointIndex == squad.currentObjective )
			currentScore = score
		if ( score > bestScore )
		{
			bestPoint = pointIndex
			bestScore = score
		}
	}

	if ( squad.currentObjective >= 0 && bestPoint != squad.currentObjective && bestScore < currentScore + CP_AI_REASSIGN_SCORE_MARGIN )
		return squad.currentObjective
	return bestPoint
}

int function CP_ChooseSyntheticRequiredCommitment( CP_TestScenario scenario, CP_TestSquad squad, array<int> allocations, int variant, int squadIndex )
{
	int bestPoint = -1
	float bestNeed = -999999.0
	for ( int pointIndex = 0; pointIndex < scenario.points.len(); pointIndex++ )
	{
		CP_TestHardpoint point = scenario.points[pointIndex]
		bool contested = point.owner == TEAM_IMC && point.enemyPresent
		CP_HardpointDecisionState tempState
		tempState.owner = point.owner
		tempState.cappingTeam = point.cappingTeam
		tempState.progress = point.progress
		tempState.ampingEnabled = true
		bool enemyAmping = CP_HardpointStateEnemyIsAmping( TEAM_IMC, tempState )
		int desired = CP_GetDesiredCommitmentForState( TEAM_IMC, point.owner, contested, enemyAmping, point.progress, true )
		if ( allocations[pointIndex] >= desired )
			continue

		float need = float( desired - allocations[pointIndex] ) * 1000.0
		if ( contested )
			need += 500.0
		else if ( point.owner == TEAM_IMC && point.progress < 2.0 )
			need += 250.0
		else if ( enemyAmping )
			need += 400.0
		else if ( allocations[pointIndex] == 0 )
			need += 150.0
		need -= CP_GetSyntheticDistance( squad.origin, point.origin, variant, squadIndex ) / 1000.0
		if ( need > bestNeed )
		{
			bestNeed = need
			bestPoint = pointIndex
		}
	}
	return bestPoint
}

CP_HardpointDecisionState function CP_BuildSyntheticDecisionState( CP_TestScenario scenario, CP_TestSquad squad, array<int> allocations, int pointIndex, int ownedCount, int uncontrolledCount, bool allEnemyOwned, int variant, int squadIndex )
{
	CP_TestHardpoint point = scenario.points[pointIndex]
	CP_HardpointDecisionState state
	state.owner = point.owner
	state.cappingTeam = point.cappingTeam
	state.progress = point.progress
	state.distance = CP_GetSyntheticDistance( squad.origin, point.origin, variant, squadIndex )
	state.assigned = allocations[pointIndex]
	state.practicalCoverage = allocations[pointIndex]
	state.ownedCount = ownedCount
	state.ampingEnabled = true
	state.alliedPresent = point.friendlyPresent
	state.enemyPresent = point.enemyPresent
	state.onlyRemainingUncontrolled = point.owner != TEAM_IMC && uncontrolledCount == 1
	state.allPointsEnemyOwned = allEnemyOwned
	state.current = squad.currentObjective == pointIndex
	bool contested = point.owner == TEAM_IMC && point.enemyPresent
	bool enemyAmping = CP_HardpointStateEnemyIsAmping( TEAM_IMC, state )
	state.desiredCommitment = CP_GetDesiredCommitmentForState( TEAM_IMC, point.owner, contested, enemyAmping, point.progress, true )
	return state
}

float function CP_GetSyntheticDistance( vector squadOrigin, vector pointOrigin, int variant, int squadIndex )
{
	float jitterX = float( ( variant * 97 + squadIndex * 31 ) % 401 ) - 200.0
	float jitterY = float( ( variant * 53 + squadIndex * 71 ) % 401 ) - 200.0
	return Distance2D( squadOrigin + <jitterX, jitterY, 0>, pointOrigin )
}

bool function CP_TestAllocationMeetsCoverage( array<int> allocations, array<int> requiredCoverage )
{
	for ( int i = 0; i < requiredCoverage.len(); i++ )
	{
		if ( allocations[i] < requiredCoverage[i] )
			return false
	}
	return true
}

bool function CP_TestAllocationIsFullyConcentrated( array<int> allocations )
{
	int total = 0
	int maximum = 0
	foreach ( int allocation in allocations )
	{
		total += allocation
		maximum = maxint( maximum, allocation )
	}
	return total > 1 && maximum == total
}

void function CP_PrintScenarioComparison( CP_TestScenario scenario, array<int> coverageFailures, array<int> concentrationFailures, array<int> allocationTotals, array<int> switchTotals )
{
	array<string> names = [ "utility", "current", "strong_saturation" ]
	for ( int strategy = 0; strategy < names.len(); strategy++ )
	{
		float divisor = float( CP_AI_TEST_VARIANTS )
		print( "NPCWAR_CP_SCENARIO name=" + scenario.name + " strategy=" + names[strategy] + " runs=" + string( CP_AI_TEST_VARIANTS ) + " coverage_failures=" + string( coverageFailures[strategy] ) + " concentration_failures=" + string( concentrationFailures[strategy] ) + " avg_A=" + string( float( allocationTotals[strategy * 3] ) / divisor ) + " avg_B=" + string( float( allocationTotals[strategy * 3 + 1] ) / divisor ) + " avg_C=" + string( float( allocationTotals[strategy * 3 + 2] ) / divisor ) + " avg_switches=" + string( float( switchTotals[strategy] ) / divisor ) )
	}
}

int function CP_TestDesiredCommitment( string name, int expected, int actual )
{
	if ( expected == actual )
		return 0

	print( "NPCWAR_CP_TEST_FAIL name=" + name + " expected=" + string( expected ) + " actual=" + string( actual ) )
	return 1
}

void function CP_DebugObjectiveDecision( int squadId, int team, entity currentObjective, entity selectedObjective, float score )
{
	if ( !CP_AI_DEBUG_OBJECTIVES && CP_GetTelemetryMode() < CP_AI_TELEMETRY_DETAILED )
		return

	string currentName = IsValid( currentObjective ) ? GetHardpointGroup( currentObjective ) : "none"
	string selectedName = IsValid( selectedObjective ) ? GetHardpointGroup( selectedObjective ) : "none"
	print( "CP AI squad " + string( squadId ) + " team " + string( team ) + " current " + currentName + " selected " + selectedName + " score " + string( score ) )
}

void function CP_DebugObjectiveCandidate( int squadId, int team, vector fromPos, HardpointStruct hardpoint, entity currentObjective, float score )
{
	if ( !CP_AI_DEBUG_OBJECTIVES && CP_GetTelemetryMode() < CP_AI_TELEMETRY_DETAILED )
		return

	entity hardpointEnt = hardpoint.hardpoint
	string hardpointName = GetHardpointGroup( hardpointEnt )
	string currentText = IsValid( currentObjective ) && currentObjective == hardpointEnt ? "yes" : "no"
	float distance = Distance2D( fromPos, hardpointEnt.GetOrigin() )
	int assigned = CP_GetAssignedSquadsForHardpoint( team, hardpointEnt, squadId )
	int practicalCoverage = CP_GetPracticalCoverageForHardpoint( team, hardpoint, squadId )
	int desiredCommitment = CP_GetDesiredCommitmentForHardpoint( team, hardpoint )
	float progress = GetHardpointCaptureProgress( hardpoint )

	print( "CP AI candidate squad " + string( squadId ) + " team " + string( team ) + " hp " + hardpointName + " owner " + string( hardpointEnt.GetTeam() ) + " capping " + string( GetHardpointCappingTeam( hardpoint ) ) + " progress " + string( progress ) + " distance " + string( distance ) + " assigned " + string( assigned ) + " practical " + string( practicalCoverage ) + " desired " + string( desiredCommitment ) + " current " + currentText + " score " + string( score ) )
}

vector function CP_GetFallbackEnemyOrigin( int team, vector fallbackOrigin )
{
	array< entity > points = GetNPCArrayOfEnemies( team )

	if ( points.len() > 0 )
		return points[ RandomInt( points.len() ) ].GetOrigin()

	array< entity > players = GetPlayerArrayOfEnemies( team )

	if ( players.len() > 0 )
		return players[ RandomInt( players.len() ) ].GetOrigin()

	return fallbackOrigin
}

// Award for hacking
void function OnSpectreLeeched( entity spectre, entity player )
{
	// Set Owner so we can filter in HandleScore
	spectre.SetOwner( player )
	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( player.GetTeam(), 1 )
	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
}

void function ReaperHandler( entity reaper )
{
	array<entity> players = GetPlayerArrayOfEnemies( reaper.GetTeam() )
	reaper.SetMaxHealth( 8000 )
	reaper.SetHealth( 8000 )
	reaper.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
	reaper.AssaultSetGoalRadius( CP_AI_TITAN_GOAL_RADIUS )
	foreach ( player in players )
		reaper.Minimap_AlwaysShow( 0, player )

	thread CP_SingleAIObjectiveThink( reaper, CP_AI_TITAN_GOAL_RADIUS )
	thread AITdm_CleanupBoredNPCThread( reaper )
}

void function CP_SingleAIObjectiveThink( entity guy, float goalRadius )
{
	int squadId = CP_RegisterAISquadAssignment( guy.GetTeam(), true )
	entity currentObjective = null

	OnThreadEnd(
		function() : ( squadId )
		{
			CP_RemoveAISquadAssignment( squadId )
		}
	)

	while ( true )
	{
		if ( !IsAlive( guy ) )
			return

		currentObjective = CP_ChooseBestHardpointObjective( squadId, guy.GetTeam(), guy.GetOrigin(), currentObjective, true )
		CP_UpdateAISquadAssignment( squadId, guy.GetTeam(), guy, currentObjective, true )
		guy.AssaultSetGoalRadius( goalRadius )
		guy.AssaultPoint( CP_GetAIObjectivePoint( guy.GetTeam(), guy.GetOrigin(), currentObjective ) )
		wait RandomFloatRange(8.0,15.0)
	}
}

void function AITdm_CleanupBoredNPCThread( entity guy )
{
	// track all ai that we spawn, ensure that they're never "bored" (i.e. stuck by themselves doing fuckall with nobody to see them) for too long
	// if they are, kill them so we can free up slots for more ai to spawn
	// we shouldn't ever kill ai if players would notice them die

	// NOTE: this partially covers up for the fact that we script ai alot less than vanilla probably does
	// vanilla probably messes more with making ai assaultpoint to fights when inactive and stuff like that, we don't do this so much

	guy.EndSignal( "OnDestroy" )
	wait 15.0 // cover spawning time from dropship/pod + before we start cleaning up

	int cleanupFailures = 0 // when this hits 2, cleanup the npc
	while ( cleanupFailures < 2 )
	{
		wait 10.0

		if ( guy.GetParent() != null )
			continue // never cleanup while spawning

		array<entity> otherGuys = GetPlayerArray()
		otherGuys.extend( GetNPCArrayOfTeam( GetOtherTeam( guy.GetTeam() ) ) )

		bool failedChecks = false

		foreach ( entity otherGuy in otherGuys )
		{
			// skip dead people
			if ( !IsAlive( otherGuy ) )
				continue

			failedChecks = false

			// don't kill if too close to anything
			if ( Distance( otherGuy.GetOrigin(), guy.GetOrigin() ) < 2000.0 )
				break

			// don't kill if ai or players can see them
			if ( otherGuy.IsPlayer() )
			{
				if ( PlayerCanSee( otherGuy, guy, true, 135 ) )
					break
			}
			else
			{
				if ( otherGuy.CanSee( guy ) )
					break
			}

			// don't kill if they can see any ai
			if ( guy.CanSee( otherGuy ) )
				break

			failedChecks = true
		}

		if ( failedChecks )
			cleanupFailures++
		else
			cleanupFailures--
	}

	print( "cleaning up bored npc: " + guy + " from team " + guy.GetTeam() )
	guy.Destroy()
}

//----------------------------------- HARDPOINT STUFF
void function GamemodeCP_OnPlayerKilled(entity victim, entity attacker, var damageInfo)
{
	HardpointStruct attackerCP
	HardpointStruct victimCP
	CP_PlayerStruct victimStruct
	if(!attacker.IsPlayer())
		return

	//hardpoint forever capped mitigation

	foreach(CP_PlayerStruct p in file.players)
		if(p.player==victim)
			victimStruct=p

	foreach(HardpointStruct hardpoint in file.hardpoints)
	{
		if(hardpoint.imcCappers.contains(victim))
		{
			victimCP = hardpoint
			thread removePlayerFromCapperArray_threaded(hardpoint.imcCappers,victim)
		}

		if(hardpoint.militiaCappers.contains(victim))
		{
			victimCP = hardpoint
			thread removePlayerFromCapperArray_threaded(hardpoint.militiaCappers,victim)
		}

		if(hardpoint.imcCappers.contains(attacker))
			attackerCP = hardpoint
		if(hardpoint.militiaCappers.contains(attacker))
			attackerCP = hardpoint

	}
	if(victimStruct.isOnHardpoint)
		victimStruct.isOnHardpoint = false

	//prevent medals form suicide
	if(attacker==victim)
		return

	if((victimCP.hardpoint!=null)&&(attackerCP.hardpoint!=null))
	{
		if(victimCP==attackerCP)
		{
			if(victimCP.hardpoint.GetTeam()==attacker.GetTeam())
			{
				AddPlayerScore( attacker , "HardpointDefense", victim )
				attacker.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_DEFENSE)
				attacker.AddToPlayerGameStat(PGS_ASSAULT_SCORE, 4 )
				NPCWar_SendScoreInfo( attacker, 4, true )
			}
			else if((victimCP.hardpoint.GetTeam()==victim.GetTeam())||(GetHardpointCappingTeam(victimCP)==victim.GetTeam()))
			{
				AddPlayerScore( attacker, "HardpointAssault", victim )
				attacker.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_ASSAULT)
				attacker.AddToPlayerGameStat(PGS_ASSAULT_SCORE, 3 )
				NPCWar_SendScoreInfo( attacker, 3, true )
			}
		}
	}
	else if((victimCP.hardpoint!=null))//siege or snipe
	{

		if(Distance(victim.GetOrigin(),attacker.GetOrigin())>=1875)//1875 inches(units) are 47.625 meters
		{
			AddPlayerScore( attacker , "HardpointSnipe", victim )
			attacker.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_SNIPE)
			attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 5 )
			NPCWar_SendScoreInfo( attacker, 5, true )
		}
		else{
			AddPlayerScore( attacker , "HardpointSiege", victim )
			attacker.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_SIEGE)
			attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 5 )
			NPCWar_SendScoreInfo( attacker, 5, true )
		}
	}
	else if(attackerCP.hardpoint!=null)//Perimeter Defense
	{
		if(attackerCP.hardpoint.GetTeam()==attacker.GetTeam())
			AddPlayerScore( attacker , "HardpointPerimeterDefense", victim)
			attacker.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_PERIMETER_DEFENSE)
			attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 3 )
			NPCWar_SendScoreInfo( attacker, 3, true )
	}

	foreach(CP_PlayerStruct player in file.players) //Reset Victim Holdtime Counter
	{
		if(player.player == victim)
			player.timeOnPoints = [0.0,0.0,0.0]
	}
}

void function removePlayerFromCapperArray_threaded(array<entity> capperArray,entity player)
{
	WaitFrame()
	FindAndRemove(capperArray,player)

}

void function RateSpawnpoints_CP( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( HasSwitchedSides() )
		team = GetOtherTeam( team )

	// check hardpoints, determine which ones we own
	array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
	vector averageFriendlySpawns

	// average out startspawn positions
	foreach ( entity spawnpoint in startSpawns )
		averageFriendlySpawns += spawnpoint.GetOrigin()

	averageFriendlySpawns /= startSpawns.len()

	entity friendlyHardpoint // determine our furthest out hardpoint
	foreach ( entity hardpoint in HARDPOINTS )
	{
		if ( hardpoint.GetTeam() == player.GetTeam() && GetGlobalNetFloat( "objective" + GetHardpointGroup(hardpoint) + "Progress" ) >= 0.95 )
		{
			if ( IsValid( friendlyHardpoint ) )
			{
				if ( Distance2D( averageFriendlySpawns, hardpoint.GetOrigin() ) > Distance2D( averageFriendlySpawns, friendlyHardpoint.GetOrigin() ) )
					friendlyHardpoint = hardpoint
			}
			else
				friendlyHardpoint = hardpoint
		}
	}

	vector ratingPos
	if ( IsValid( friendlyHardpoint ) )
		ratingPos = friendlyHardpoint.GetOrigin()
	else
		ratingPos = averageFriendlySpawns

	foreach ( entity spawnpoint in spawnpoints )
	{
		// idk about magic number here really
		float rating = 1.0 - ( Distance2D( spawnpoint.GetOrigin(), ratingPos ) / 1000.0 )
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating )
	}
}

void function SpawnHardpoints()
{
	foreach ( entity spawnpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( GameModeRemove( spawnpoint ) )
			continue

		// spawnpoints are CHardPoint entities
		// init the hardpoint ent
		int hardpointID = 0
		string group = GetHardpointGroup(spawnpoint)
			if ( group == "B" )
				hardpointID = 1
			else if ( group == "C" )
				hardpointID = 2

		spawnpoint.SetHardpointID( hardpointID )
		SpawnHardpointMinimapIcon( spawnpoint )

		HardpointStruct hardpointStruct
		hardpointStruct.hardpoint = spawnpoint
		hardpointStruct.prop = CreatePropDynamic( spawnpoint.GetModelName(), spawnpoint.GetOrigin(), spawnpoint.GetAngles(), 6 )
		thread PlayAnim( hardpointStruct.prop, "mh_inactive_idle" )

		entity trigger = GetEnt( expect string( spawnpoint.kv.triggerTarget ) )
		hardpointStruct.trigger = trigger

		file.hardpoints.append( hardpointStruct )
		HARDPOINTS.append( spawnpoint ) // for vo script
		spawnpoint.s.trigger <- trigger // also for vo script

		SetGlobalNetEnt( "objective" + group + "Ent", spawnpoint )

		// set up trigger functions
		trigger.SetEnterCallback( OnHardpointEntered )
		trigger.SetLeaveCallback( OnHardpointLeft )
	}
}

void function SpawnHardpointMinimapIcon( entity spawnpoint )
{
	// map hardpoint id to eMinimapObject_info_hardpoint enum id
	int miniMapObjectHardpoint = spawnpoint.GetHardpointID() + 1

	spawnpoint.Minimap_SetCustomState( miniMapObjectHardpoint )
	spawnpoint.Minimap_AlwaysShow( TEAM_MILITIA, null )
	spawnpoint.Minimap_AlwaysShow( TEAM_IMC, null )
	spawnpoint.Minimap_SetAlignUpright( true )

	SetTeam( spawnpoint, TEAM_UNASSIGNED )
}

// functions for handling hardpoint netvars
void function SetHardpointState( HardpointStruct hardpoint, int state )
{
	SetGlobalNetInt( "objective" + GetHardpointGroup(hardpoint.hardpoint) + "State", state )
	hardpoint.hardpoint.SetHardpointState( state )
}

int function GetHardpointState( HardpointStruct hardpoint )
{
	return GetGlobalNetInt( "objective" + GetHardpointGroup(hardpoint.hardpoint) + "State" )
}

void function SetHardpointCappingTeam( HardpointStruct hardpoint, int team )
{
	SetGlobalNetInt( "objective" + GetHardpointGroup(hardpoint.hardpoint) + "CappingTeam", team )
}

int function GetHardpointCappingTeam( HardpointStruct hardpoint )
{
	return GetGlobalNetInt( "objective" + GetHardpointGroup(hardpoint.hardpoint) + "CappingTeam" )
}

void function SetHardpointCaptureProgress( HardpointStruct hardpoint, float progress )
{
	SetGlobalNetFloat( "objective" + GetHardpointGroup(hardpoint.hardpoint) + "Progress", progress )
}

float function GetHardpointCaptureProgress( HardpointStruct hardpoint )
{
	return GetGlobalNetFloat( "objective" + GetHardpointGroup(hardpoint.hardpoint) + "Progress" )
}


void function StartHardpointThink()
{
	thread TrackChevronStates()
	if ( CP_GetTelemetryMode() >= CP_AI_TELEMETRY_SUMMARY )
		thread CP_HardpointTelemetryThink()

	foreach ( HardpointStruct hardpoint in file.hardpoints )
		thread HardpointThink( hardpoint )
}

void function CapturePointForTeam(HardpointStruct hardpoint, int Team)
{
	SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
	SetTeam( hardpoint.hardpoint, Team )
	SetTeam( hardpoint.prop, Team )
	EmitSoundOnEntityToTeamExceptPlayer( hardpoint.hardpoint, "hardpoint_console_captured", Team, null )
	GamemodeCP_VO_Captured( hardpoint.hardpoint )

	array<entity> allCappers
	allCappers.extend(hardpoint.militiaCappers)
	allCappers.extend(hardpoint.imcCappers)

	foreach(entity player in allCappers)
	{
		if(player.IsPlayer()){
			AddPlayerScore(player,"ControlPointCapture")
			player.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_CAPTURE)
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 5 )
			NPCWar_SendScoreInfo( player, 5, true )
		}
	}
}

void function GamemodeCP_InitPlayer(entity player)
{
	CP_PlayerStruct playerStruct
	playerStruct.player = player
	playerStruct.timeOnPoints = [0.0,0.0,0.0]
	playerStruct.isOnHardpoint = false
	file.players.append(playerStruct)
	thread PlayerThink(playerStruct)
}

void function GamemodeCP_RemovePlayer(entity player)
{

	foreach(index,CP_PlayerStruct playerStruct in file.players)
	{
		if(playerStruct.player==player)
			file.players.remove(index)
	}
}

void function PlayerThink(CP_PlayerStruct player)
{

	if(!IsValid(player.player))
		return

	if(!player.player.IsPlayer())
		return

	while(!GamePlayingOrSuddenDeath())
		WaitFrame()

	float lastTime = Time()
	WaitFrame()

	while(GamePlayingOrSuddenDeath()&&IsValid(player.player))
	{
		float currentTime = Time()
		float deltaTime = currentTime - lastTime

		if(player.isOnHardpoint)
		{
			bool hardpointBelongsToPlayerTeam = false

			foreach(index,HardpointStruct hardpoint in file.hardpoints)
			{
				if(GetHardpointState(hardpoint)>=CAPTURE_POINT_STATE_CAPTURED)
				{
					if((hardpoint.hardpoint.GetTeam()==TEAM_MILITIA)&&(hardpoint.militiaCappers.contains(player.player)))
						hardpointBelongsToPlayerTeam = true

					if((hardpoint.hardpoint.GetTeam()==TEAM_IMC)&&(hardpoint.imcCappers.contains(player.player)))
						hardpointBelongsToPlayerTeam = true
				}
				if(hardpointBelongsToPlayerTeam)
				{
					player.timeOnPoints[index] += deltaTime
					if(player.timeOnPoints[index]>=10)
					{
						player.timeOnPoints[index] -= 10
						if(GetHardpointState(hardpoint)==CAPTURE_POINT_STATE_AMPED)
						{
							AddPlayerScore(player.player,"ControlPointAmpedHold")
							player.player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, POINTVALUE_HARDPOINT_AMPED_HOLD )
							player.player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 2 )
							NPCWar_SendScoreInfo( player.player, 2, true )
						}
						else
						{
							AddPlayerScore(player.player,"ControlPointHold")
							player.player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, POINTVALUE_HARDPOINT_HOLD )
							player.player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 2 )
							NPCWar_SendScoreInfo( player.player, 2, true )
						}
					}
					break
				}
			}
		}
		lastTime = currentTime
		WaitFrame()
	}
}

void function SetCapperAmount( table<int, table<string, int> > capStrength, array<entity> entities )
{
	foreach(entity p in entities)
	{
		if ( p.IsPlayer() && p.IsTitan() )
		{
			capStrength[p.GetTeam()]["titans"] += 1
		}
		else if ( p.IsPlayer() )
		{
			capStrength[p.GetTeam()]["pilots"] += 1
		}
		else if ( p.IsNPC() )
		{
			capStrength[p.GetTeam()]["grunts"] += 1
		}
	}
}

void function HardpointThink( HardpointStruct hardpoint )
{
	entity hardpointEnt = hardpoint.hardpoint

	float lastTime = Time()
	float lastScoreTime = Time()
	bool hasBeenAmped = false

	WaitFrame() // wait a frame so deltaTime is never zero

	while ( GamePlayingOrSuddenDeath() )
	{
		table<int, table<string, int> > capStrength = {
			[TEAM_IMC] = {
				pilots = 0,
				titans = 0,
				grunts = 0,
			},
			[TEAM_MILITIA] = {
				pilots = 0,
				titans = 0,
				grunts = 0,
			}
		}

		float currentTime = Time()
		float deltaTime = currentTime - lastTime

		SetCapperAmount( capStrength, hardpoint.militiaCappers )
		SetCapperAmount( capStrength, hardpoint.imcCappers )

		int imcPilotCappers = capStrength[TEAM_IMC]["pilots"]
		int imcTitanCappers = capStrength[TEAM_IMC]["titans"]
		int imcGruntCappers = capStrength[TEAM_IMC]["grunts"]

		int militiaPilotCappers = capStrength[TEAM_MILITIA]["pilots"]
		int militiaTitanCappers = capStrength[TEAM_MILITIA]["titans"]
		int militiaGruntCappers = capStrength[TEAM_MILITIA]["grunts"]


		int imcCappers = ( imcPilotCappers * 2 ) + imcGruntCappers //( imcTitanCappers + militiaTitanCappers ) > 0 ? imcTitanCappers : imcPilotCappers
		int militiaCappers = ( militiaPilotCappers * 2 ) + militiaGruntCappers //( imcTitanCappers + militiaTitanCappers ) <= 0 ? militiaPilotCappers : militiaTitanCappers

		int cappingTeam
		int capperAmount = 0
		bool hardpointBlocked = false

		if((imcCappers > 0) && (militiaCappers > 0))
		{
			hardpointBlocked = true
		}
		else if ( imcCappers > 0 )
		{
			cappingTeam = TEAM_IMC
			capperAmount = imcCappers
		}
		else if ( militiaCappers > 0 )
		{
			cappingTeam = TEAM_MILITIA
			capperAmount = militiaCappers
		}

		int MAX_CAPPERS = GetConVarInt( "MAX_CAPPERS" ) * 2
		float CAPTURE_TIME = CAPTURE_DURATION_CAPTURE * 2 //Double capture time as players count as double captures
		capperAmount = minint(capperAmount, MAX_CAPPERS)

		if(hardpointBlocked)
		{
			SetHardpointState(hardpoint,CAPTURE_POINT_STATE_HALTED)
		}
		else if(cappingTeam==TEAM_UNASSIGNED) // nobody on point
		{
			if((GetHardpointState(hardpoint)>=CAPTURE_POINT_STATE_AMPED) || (GetHardpointState(hardpoint)==CAPTURE_POINT_STATE_SELF_UNAMPING))
			{
				if (GetHardpointState(hardpoint) == CAPTURE_POINT_STATE_AMPED)
					SetHardpointState(hardpoint,CAPTURE_POINT_STATE_SELF_UNAMPING) // plays a pulsating effect on the UI only when the hardpoint is amped
				SetHardpointCappingTeam(hardpoint,hardpointEnt.GetTeam())
				SetHardpointCaptureProgress(hardpoint,max(1.0,GetHardpointCaptureProgress(hardpoint)-(deltaTime/HARDPOINT_AMPED_DELAY)))
				if(GetHardpointCaptureProgress(hardpoint)<=1.001) // unamp
				{
					if (GetHardpointState(hardpoint) == CAPTURE_POINT_STATE_AMPED) // only play 2inactive animation if we were amped
						thread PlayAnim( hardpoint.prop, "mh_active_2_inactive" )
					SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
				}
			}
			if(GetHardpointState(hardpoint)>=CAPTURE_POINT_STATE_CAPTURED)
				SetHardpointCappingTeam(hardpoint,TEAM_UNASSIGNED)
		}
		else if(hardpointEnt.GetTeam()==TEAM_UNASSIGNED) // uncapped point
		{
			if(GetHardpointCappingTeam(hardpoint)==TEAM_UNASSIGNED) // uncapped point with no one inside
			{
				SetHardpointCaptureProgress( hardpoint, min(1.0,GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_TIME * capperAmount) ) )
				SetHardpointCappingTeam(hardpoint,cappingTeam)
				if(GetHardpointCaptureProgress(hardpoint)>=1.0)
				{
					CapturePointForTeam(hardpoint,cappingTeam)
					hasBeenAmped = false
				}
			}
			else if(GetHardpointCappingTeam(hardpoint)==cappingTeam) // uncapped point with ally inside
			{
				SetHardpointCaptureProgress( hardpoint,min(1.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_TIME * capperAmount) ) )
				if(GetHardpointCaptureProgress(hardpoint)>=1.0)
				{
					CapturePointForTeam(hardpoint,cappingTeam)
					hasBeenAmped = false
				}
			}
			else // uncapped point with enemy inside
			{
				SetHardpointCaptureProgress( hardpoint,max(0.0, GetHardpointCaptureProgress( hardpoint ) - ( deltaTime / CAPTURE_TIME * capperAmount) ) )
				if(GetHardpointCaptureProgress(hardpoint)==0.0)
				{
					SetHardpointCappingTeam(hardpoint,cappingTeam)
					if(GetHardpointCaptureProgress(hardpoint)>=1)
					{
						CapturePointForTeam(hardpoint,cappingTeam)
						hasBeenAmped = false
					}
				}
			}
		}
		else if(hardpointEnt.GetTeam()!=cappingTeam) // capping enemy point
		{
			SetHardpointCappingTeam(hardpoint,cappingTeam)
			SetHardpointCaptureProgress( hardpoint,max(0.0, GetHardpointCaptureProgress( hardpoint ) - ( deltaTime / CAPTURE_TIME * capperAmount) ) )
			if(GetHardpointCaptureProgress(hardpoint)<=1.0)
			{
				if (GetHardpointState(hardpoint) == CAPTURE_POINT_STATE_AMPED) // only play 2inactive animation if we were amped
					thread PlayAnim( hardpoint.prop, "mh_active_2_inactive" )
				SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED) // unamp
			}
			if(GetHardpointCaptureProgress(hardpoint)<=0.0)
			{
				SetHardpointCaptureProgress(hardpoint,1.0)
				CapturePointForTeam(hardpoint,cappingTeam)
				hasBeenAmped = false
			}
		}
		else if(hardpointEnt.GetTeam()==cappingTeam) // capping allied point
		{
			SetHardpointCappingTeam(hardpoint,cappingTeam)
			if(GetHardpointCaptureProgress(hardpoint)<1.0) // not amped
			{
				SetHardpointCaptureProgress(hardpoint,GetHardpointCaptureProgress(hardpoint)+( deltaTime / CAPTURE_TIME * capperAmount ))
			}
			else if(file.ampingEnabled)//amping or reamping
			{
				// i have no idea why but putting it CAPTURE_POINT_STATE_AMPING will say 'CONTESTED' on the UI
				// since whether the point is contested is checked above, putting the hardpoint state to a value of 8 fixes it somehow
				if(GetHardpointState(hardpoint)<=CAPTURE_POINT_STATE_AMPING)
					SetHardpointState( hardpoint, 8 )
				SetHardpointCaptureProgress( hardpoint, min( 2.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / HARDPOINT_AMPED_DELAY * capperAmount ) ) )
				if(GetHardpointCaptureProgress(hardpoint)==2.0&&!(GetHardpointState(hardpoint)==CAPTURE_POINT_STATE_AMPED))
				{
					SetHardpointState( hardpoint, CAPTURE_POINT_STATE_AMPED )
					// can't use the dialogue functions here because for some reason GamemodeCP_VO_Amped isn't global?
					PlayFactionDialogueToTeam( "amphp_youAmped" + GetHardpointGroup(hardpoint.hardpoint), cappingTeam )
					PlayFactionDialogueToTeam( "amphp_enemyAmped" + GetHardpointGroup(hardpoint.hardpoint), GetOtherTeam( cappingTeam ) )
					thread PlayAnim( hardpoint.prop, "mh_inactive_2_active" )

					if(!hasBeenAmped){
						hasBeenAmped=true

						array<entity> allCappers
						allCappers.extend(hardpoint.militiaCappers)
						allCappers.extend(hardpoint.imcCappers)

						foreach(entity player in allCappers)
						{
							if(player.IsPlayer())
							{
								AddPlayerScore(player,"ControlPointAmped")
								player.AddToPlayerGameStat(PGS_DEFENSE_SCORE,POINTVALUE_HARDPOINT_AMPED)
								player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 5 )
								NPCWar_SendScoreInfo( player, 5, true )
							}
						}
					}
				}
			}
		}

		if ( hardpointEnt.GetTeam() != TEAM_UNASSIGNED && GetHardpointState( hardpoint ) >= CAPTURE_POINT_STATE_CAPTURED && currentTime - lastScoreTime >= TEAM_OWNED_SCORE_FREQ && !hardpointBlocked&&!(cappingTeam==GetOtherTeam(hardpointEnt.GetTeam())))
		{
			lastScoreTime = currentTime
			if ( GetHardpointState( hardpoint ) == CAPTURE_POINT_STATE_AMPED )
				AddTeamScore( hardpointEnt.GetTeam(), 2 )
			else if( GetHardpointState( hardpoint) >= CAPTURE_POINT_STATE_CAPTURED)
				AddTeamScore( hardpointEnt.GetTeam(), 1 )
		}

		foreach(entity player in hardpoint.imcCappers)
		{
			if(DistanceSqr(player.GetOrigin(),hardpointEnt.GetOrigin())>1200000)
				FindAndRemove(hardpoint.imcCappers,player)
		}
		foreach(entity player in hardpoint.militiaCappers)
		{
			if(DistanceSqr(player.GetOrigin(),hardpointEnt.GetOrigin())>1200000)
				FindAndRemove(hardpoint.militiaCappers,player)
		}


		lastTime = currentTime
		WaitFrame()
	}
}

// doing this in HardpointThink is effort since it's for individual hardpoints
// so we do it here instead
void function TrackChevronStates()
{
	// you get 1 amped arrow for chevron / 4, 1 unamped arrow for every 1 the amped chevrons

	while ( true )
	{
		table <int, int> chevrons = {
			[TEAM_IMC] = 0,
			[TEAM_MILITIA] = 0,
		}

		foreach ( HardpointStruct hardpoint in file.hardpoints )
		{
			foreach ( k, v in chevrons )
			{
				if ( k == hardpoint.hardpoint.GetTeam() )
					chevrons[k] += ( hardpoint.hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_AMPED ) ? 4 : 1
			}
		}

		SetGlobalNetInt( "imcChevronState", chevrons[TEAM_IMC] )
		SetGlobalNetInt( "milChevronState", chevrons[TEAM_MILITIA] )

		WaitFrame()
	}
}

void function OnHardpointEntered( entity trigger, entity player )
{
	HardpointStruct hardpoint
	foreach ( HardpointStruct hardpointStruct in file.hardpoints )
		if ( hardpointStruct.trigger == trigger )
			hardpoint = hardpointStruct

	if ( player.GetTeam() == TEAM_IMC )
		hardpoint.imcCappers.append( player )
	else
		hardpoint.militiaCappers.append( player )
	foreach(CP_PlayerStruct playerStruct in file.players)
		if(playerStruct.player == player)
		{
			playerStruct.isOnHardpoint = true
			player.SetPlayerNetInt( "playerHardpointID", hardpoint.hardpoint.GetHardpointID() )
		}
}

void function OnHardpointLeft( entity trigger, entity player )
{
	HardpointStruct hardpoint
	foreach ( HardpointStruct hardpointStruct in file.hardpoints )
		if ( hardpointStruct.trigger == trigger )
			hardpoint = hardpointStruct

	if ( player.GetTeam() == TEAM_IMC )
		FindAndRemove( hardpoint.imcCappers, player )
	else
		FindAndRemove( hardpoint.militiaCappers, player )
	foreach(CP_PlayerStruct playerStruct in file.players)
		if(playerStruct.player == player)
		{
			playerStruct.isOnHardpoint = false
			player.SetPlayerNetInt( "playerHardpointID", 69 ) // an arbitary number to remove the hud from the player
		}
}

string function CaptureStateToString( int state )
{
	switch ( state )
	{
		case CAPTURE_POINT_STATE_UNASSIGNED:
			return "UNASSIGNED"
		case CAPTURE_POINT_STATE_HALTED:
			return "HALTED"
		case CAPTURE_POINT_STATE_CAPTURED:
			return "CAPTURED"
		case CAPTURE_POINT_STATE_AMPING:
		case 8:
			return "AMPING"
		case CAPTURE_POINT_STATE_AMPED:
			return "AMPED"
	}
	return "UNKNOWN"
}

void function DEV_PrintHardpointsInfo()
{
	foreach (entity hardpoint in HARDPOINTS)
	{

		printt(
			"Hardpoint:", GetHardpointGroup(hardpoint),
			"|Team:", Dev_TeamIDToString(hardpoint.GetTeam()),
			"|State:", CaptureStateToString(hardpoint.GetHardpointState()),
			"|Progress:", GetGlobalNetFloat("objective" + GetHardpointGroup(hardpoint) + "Progress")
		)
	}
}

string function GetHardpointGroup(entity hardpoint) //Hardpoint Entity B on Homestead is missing the Hardpoint Group KeyValue
{
	if((GetMapName()=="mp_homestead")&&(!hardpoint.HasKey("hardpointGroup")))
		return "B"

	return string(hardpoint.kv.hardpointGroup)
}

untyped

global function GamemodeAITdm_Init

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

const array<string> WEAPONS = [ "mp_weapon_alternator_smg", "mp_weapon_arc_launcher", "mp_weapon_autopistol", "mp_weapon_car", "mp_weapon_defender", "mp_weapon_dmr", "mp_weapon_doubletake", "mp_weapon_epg", "mp_weapon_esaw", "mp_weapon_g2", "mp_weapon_hemlok", "mp_weapon_hemlok_smg", "mp_weapon_lmg", "mp_weapon_lstar", "mp_weapon_mastiff", "mp_weapon_mgl", "mp_weapon_pulse_lmg", "mp_weapon_r97", "mp_weapon_rocket_launcher", "mp_weapon_rspn101", "mp_weapon_rspn101_og", "mp_weapon_semipistol", "mp_weapon_shotgun", "mp_weapon_shotgun_pistol", "mp_weapon_smart_pistol", "mp_weapon_smr", "mp_weapon_sniper", "mp_weapon_softball", "mp_weapon_vinson", "mp_weapon_wingman", "mp_weapon_wingman_n" ]
const array<string> MODS = [ "pas_run_and_gun", "threat_scope", "pas_fast_ads", "pas_fast_reload", "extended_ammo", "pas_fast_swap" ]

struct
{
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
	array<entity> introDropPodPoints
	array<entity> dropPodPoints
	array<entity> titanPoints
	array<entity> dropshipPoints
} file

void function GamemodeAITdm_Init()
{
	npcWarSupportedGameMode = true
	SetSpawnpointGamemodeOverride( ATTRITION ) // use bounty hunt spawns as vanilla game has no spawns explicitly defined for aitdm

	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )

	AddCallback_OnNPCKilled( HandleScoreEvent )
	AddCallback_OnPlayerKilled( HandleScoreEvent )

	AddCallback_OnClientConnected( OnPlayerConnected )

	AddCallback_NPCLeeched( OnSpectreLeeched )

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
	SetupGenericTDMChallenge()

	//ClassicMP_ForceDisableEpilogue( true )
	NPCWarPilotMode_ApplyBoostAvailability()
	NPCWarPilotMode_PrepareTitanAvailability()
	NPCWarPilotMode_ApplyMatchLimitOverrides()

	file.levels[0] = 0
	file.levels[1] = 0
}

//------------------------------------------------------

void function OnPrematchStart()
{
	thread StratonHornetDogfightsIntense()
}

void function OnPlaying()
{
	NPCWar_CacheSpawnPoints()
	thread NPCWarBalanceTelemetry_Think( "aitdm" )

	// don't run spawning code if ains and nms aren't up to date
	if ( GetAINScriptVersion() == AIN_REV && GetNodeCount() != 0 )
	{
		thread SpawnIntroBatch( TEAM_MILITIA )
		thread SpawnIntroBatch( TEAM_IMC )
	}
}

void function NPCWar_CacheSpawnPoints()
{
	file.introDropPodPoints = GetEntArrayByClass_Expensive( "info_spawnpoint_droppod_start" )
	file.dropPodPoints = SpawnPoints_GetDropPod()
	file.titanPoints = SpawnPoints_GetTitan()
	file.dropshipPoints = GetZiplineDropshipSpawns()
}

void function OnPlayerConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AITDM_OnPlayerConnected" )
}

//------------------------------------------------------


void function HandleScoreEvent( entity victim, entity attacker, var damageInfo )
{
	if ( victim == attacker || !IsValid( attacker ) || GetGameState() != eGameState.Playing )
		return

	// Do not award a unit for destroying an NPC it owns, such as a hacked Spectre.
	if ( victim.GetOwner() == attacker )
		return

	int score = NPCWar_GetScoreValue( victim, attacker, damageInfo )
	int scoreLimit = GetScoreLimit_FromPlaylist()
	if ( scoreLimit > 0 )
		score = minint( score, maxint( 0, scoreLimit - GameRules_GetTeamScore( attacker.GetTeam() ) ) )

	// make npc able to earn score
	AddTeamScore( attacker.GetTeam(), score )

	if( attacker.IsPlayer() || attacker.IsTitan() && attacker.GetBossPlayer() != null )
	{
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, score )
		attacker.SetPlayerNetInt( "AT_bonusPoints", attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
		thread NPCWar_AddProgressionScore( attacker, score )
		if( score > 0 )
			thread NPCWar_SendScoreInfo( attacker )
	}

}

//------------------------------------------------------

void function SpawnIntroBatch( int team )
{
	thread EscalationThink( team )

	if( GetMapName() != "mp_rise" && GetMapName() != "mp_wargames" && GetMapName() != "mp_crashsite3" )
	{
		array<entity> dropPodNodes = file.introDropPodPoints

		array<entity> podNodes
		array<entity> shipNodes

		// Sort per team
		foreach ( node in dropPodNodes )
		{
			if ( node.GetTeam() == team )
				podNodes.append( node )
		}

		shipNodes = GetValidIntroDropShipSpawn( podNodes )

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
			int count = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_INFANTRY )
			int reaperCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_REAPER )

			// REAPERS
			if ( file.reapers[ index ] )
			{
				array< entity > points = file.dropPodPoints
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
					array< entity > points = file.dropshipPoints
					if ( points.len() / 4 >= 1 && squadDeficit < emergencyDroppodDeficit && Time() >= file.nextDropshipSpawnTime[ index ] && RandomInt( points.len() / 4 ) )
					{
						entity node = points[ GetSpawnPointIndex( points, team ) ]
						file.nextDropshipSpawnTime[ index ] = Time() + NPCWAR_DROPSHIP_SPAWN_COOLDOWN
						file.nextInfantryDispatchTime[ index ] = Time() + NPCWAR_INFANTRY_DISPATCH_COOLDOWN
						NPCWarBalanceTelemetry_PrintReinforcement( team, "aitdm", "dropship", count, squadLimit )
						Aitdm_SpawnDropShip( node, team )
						shouldSpawnDropPod = false
					}
				}

				if ( shouldSpawnDropPod )
				{
					array< entity > points = file.dropPodPoints
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					NPCWarBalanceTelemetry_PrintReinforcement( team, "aitdm", "droppod", count, squadLimit )
					waitthread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, ent, SquadHandler )
				}
			}
		}
		wait 0.1
	}
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
			int marvinCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_MARVIN )
			int prowlerCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_PROWLER )
			int gunshipCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_GUNSHIP )
	        int titanCount = NPCWar_GetTitanPopulationCount( team )
	        int pilotCount = NPCWar_GetPopulationCount( team, NPCWAR_POPULATION_PILOT )


	        // GUNSHIPS
	        if ( file.gunships[ index ] )
			{
				array< entity > points = file.dropPodPoints
				if ( gunshipCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_GUNSHIPS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread AiGameModes_SpawnGunShip( node.GetOrigin(), node.GetAngles(), team)
				}
			}

			// TITANS
			if ( file.titans[ index ] )
			{
				array< entity > points = file.titanPoints
				if ( titanCount < NPCWarDirector_GetUnitLimit( team, "NPCWAR_TITANS" ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread AiGameModes_SpawnTitanRandom( node.GetOrigin(), node.GetAngles(), team, TitanHandler )
				}
			}

			// PILOTS
			if ( file.pilots[ index ] )
			{
				array< entity > points = file.titanPoints
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
				array< entity > points = file.dropPodPoints
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
				array< entity > points = file.dropPodPoints
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
		wait 0.1
	}
}

void function EscalationThink( int team )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	while ( GetGameState() == eGameState.Playing )
	{
		Escalate( team )
		wait 0.25
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
	string defcon = team == TEAM_MILITIA ? "IMCdefcon" : "MILdefcon"

	if ( score < threshold )
		return

	switch ( stage )
	{
		case 0:
			file.levels[ index ] = 1
			file.marvins[ index ] = true
			file.podEntities[ index ].append( "npc_spectre" )
			SetGlobalNetInt( defcon, 2 )
			return

		case 1:
			file.levels[ index ] = 2
			file.stalkers[ index ] = true
			file.marvins[ index ] = false
			file.weapondrops[ index ] = true
			file.prowlers[ index ] = true
			file.podEntities[ index ].append( "npc_stalker" )
			SetGlobalNetInt( defcon, 3 )
			return

		case 2:
			file.levels[ index ] = 3
			file.reapers[ index ] = true
			SetGlobalNetInt( defcon, 4 )
			return

		case 3:
			file.levels[ index ] = 4
			file.gunships[ index ] = true
			SetGlobalNetInt( defcon, 5 )
			return


		case 4:
			file.levels[ index ] = 5
			file.prowlers[ index ] = false
			file.pilots[ index ] = true
			file.titans[ index ] = true
			NPCWarPilotMode_UnlockPlayerTitanMeter()
			SetGlobalNetInt( defcon, 6 )
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
	// Not all maps have assaultpoints / have weird assault points ( looking at you ac )
	// So we use enemies with a large radius
	array< entity > points = GetNPCArrayOfEnemies( guys[0].GetTeam() )

	if ( points.len()  == 0 )
		return

	vector point
	point = points[ RandomInt( points.len() ) ].GetOrigin()

	array<entity> players = GetPlayerArrayOfEnemies( guys[0].GetTeam() )

	// Setup AI
	foreach ( guy in guys )
	{
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.AssaultPoint( point )
		guy.AssaultSetGoalRadius( 1600 ) // 1600 is minimum for npc_stalker, works fine for others

		// show on enemy radar
		foreach ( player in players )
			guy.Minimap_AlwaysShow( 0, player )


		//thread AITdm_CleanupBoredNPCThread( guy )
	}

	// Every 5 - 15 secs change AssaultPoint
	while ( true )
	{
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

			// Get point and send guy to it
			points = GetNPCArrayOfEnemies( guy.GetTeam() )
			if ( points.len() == 0 )
				WaitFrame()
				continue

			point = points[ RandomInt( points.len() ) ].GetOrigin()

			guy.AssaultPoint( point )
		}
		wait RandomFloatRange(5.0,15.0)
	}
}

void function TitanHandler( entity titan )
{
	array< entity > points = GetNPCArrayOfEnemies( titan.GetTeam() )

	if ( points.len()  == 0 )
		return

	vector point
	point = points[ RandomInt( points.len() ) ].GetOrigin()

	array<entity> players = GetPlayerArrayOfEnemies( titan.GetTeam() )

	// Setup AI
	titan.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
	//titan.SetNumRodeoSlots(0) Better method used
	titan.AssaultPoint( point )
	titan.AssaultSetGoalRadius( 1600 ) // 1600 is minimum for npc_stalker, works fine for others

	// show on enemy radar
	foreach ( player in players )
		titan.Minimap_AlwaysShow( 0, player )


	//thread AITdm_CleanupBoredNPCThread( guy )

	// Every 5 - 15 secs change AssaultPoint
	while ( true )
	{
		// Check if alive
		if ( !IsAlive( titan ) )
			return

		// Get point and send guy to it
		points = GetNPCArrayOfEnemies( titan.GetTeam() )
		if ( points.len() == 0 )
		{
			wait 0.1
			continue
		}

		point = points[ RandomInt( points.len() ) ].GetOrigin()

		titan.AssaultPoint( point )
		wait RandomFloatRange(5.0,15.0)
	}
}

// Award for hacking
void function OnSpectreLeeched( entity spectre, entity player )
{
	// Set Owner so we can filter in HandleScore
	spectre.SetOwner( player )
	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( player.GetTeam(), 1 )
	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
	player.SetPlayerNetInt("AT_bonusPoints", player.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
}

void function ReaperHandler( entity reaper )
{
	array<entity> players = GetPlayerArrayOfEnemies( reaper.GetTeam() )
	reaper.SetMaxHealth( 8000 )
	reaper.SetHealth( 8000 )
	foreach ( player in players )
		reaper.Minimap_AlwaysShow( 0, player )

	thread AITdm_CleanupBoredNPCThread( reaper )
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

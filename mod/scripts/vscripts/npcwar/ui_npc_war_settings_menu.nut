global function NPCWarSettingsMenu_Init

const string NPCWAR_SETTINGS_MENU = "NPCWarSettingsCategoryMenu"
const string NPCWAR_CATEGORY_PLAYER_OPTIONS = "#PL_npcwar_player_options"
const string NPCWAR_CATEGORY_DIRECTOR = "#PL_npcwar_director"
const string NPCWAR_CATEGORY_MATCH_SETTINGS = "#PL_npcwar_match_settings"
const string NPCWAR_CATEGORY_REINFORCEMENT_BUDGETS = "#PL_npcwar_reinforcement_budgets"

struct
{
	array<string> sectionLabels
	array<string> sectionCategories
} file

void function NPCWarSettingsMenu_Init()
{
	if ( file.sectionLabels.len() == 0 )
	{
		file.sectionLabels.append( "Player Options" )
		file.sectionCategories.append( NPCWAR_CATEGORY_PLAYER_OPTIONS )

		file.sectionLabels.append( "Director" )
		file.sectionCategories.append( NPCWAR_CATEGORY_DIRECTOR )

		file.sectionLabels.append( "Match Settings" )
		file.sectionCategories.append( NPCWAR_CATEGORY_MATCH_SETTINGS )

		file.sectionLabels.append( "Reinforcement Budgets" )
		file.sectionCategories.append( NPCWAR_CATEGORY_REINFORCEMENT_BUDGETS )
	}

	AddMenu(
		NPCWAR_SETTINGS_MENU,
		$"resource/ui/menus/custom_match_settings_categories.menu",
		InitNPCWarSettingsCategoryMenu,
		"NPC War"
	)

	AddCustomPrivateMatchSettingsCategory( "NPC War", NPCWAR_SETTINGS_MENU )
}

void function InitNPCWarSettingsCategoryMenu()
{
	AddMenuEventHandler( GetMenu( NPCWAR_SETTINGS_MENU ), eUIEvent.MENU_OPEN, OnNPCWarSettingsCategoryMenuOpened )
	AddMenuFooterOption( GetMenu( NPCWAR_SETTINGS_MENU ), BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

	foreach ( var button in GetElementsByClassname( GetMenu( NPCWAR_SETTINGS_MENU ), "MatchSettingCategoryButton" ) )
	{
		AddButtonEventHandler( button, UIE_CLICK, SelectNPCWarSettingsCategory )
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}
}

void function OnNPCWarSettingsCategoryMenuOpened()
{
	Hud_SetText( Hud_GetChild( GetMenu( NPCWAR_SETTINGS_MENU ), "Title" ), "NPC War" )

	array<var> buttons = GetElementsByClassname( GetMenu( NPCWAR_SETTINGS_MENU ), "MatchSettingCategoryButton" )

	foreach ( var button in buttons )
	{
		Hud_SetEnabled( button, false )
		Hud_SetVisible( button, false )
	}

	for ( int i = 0; i < file.sectionLabels.len() && i < buttons.len(); i++ )
	{
		Hud_SetText( buttons[ i ], file.sectionLabels[ i ] + " ->" )
		Hud_SetEnabled( buttons[ i ], true )
		Hud_SetVisible( buttons[ i ], true )
	}
}

void function SelectNPCWarSettingsCategory( var button )
{
	int buttonId = int( Hud_GetScriptID( button ) )
	if ( buttonId < 0 || buttonId >= file.sectionCategories.len() )
		return

	SetNextMatchSettingsCategory( file.sectionCategories[ buttonId ] )
	Hud_SetText( Hud_GetChild( GetMenu( "CustomMatchSettingsMenu" ), "Title" ), "NPC War - " + file.sectionLabels[ buttonId ] )
	AdvanceMenu( GetMenu( "CustomMatchSettingsMenu" ) )
}

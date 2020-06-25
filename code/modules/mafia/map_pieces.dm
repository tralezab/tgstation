/obj/effect/landmark/mafia
	name = "Mafia Player Spawn"
	var/game_id = "mafia"

/obj/effect/landmark/mafia/town_center
	name = "Mafia Town Center"

//for ghosts/admins
/obj/mafia_game_board
	name = "Mafia Game Board"
	icon = 'icons/obj/mafia.dmi'
	icon_state = "board"
	var/game_id = "mafia"

/obj/mafia_game_board/attack_ghost(mob/user)
	. = ..()
	var/datum/mafia_controller/MF = GLOB.mafia_games[game_id]
	if(!MF)
		MF = create_mafia_game(game_id)
	MF.ui_interact(user)

/area/mafia
	name = "Mafia Minigame"
	icon_state = "mafia"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

/datum/map_template/mafia
	var/description = ""
	var/suffix = ""

/datum/map_template/mafia/New()
	mappath = "_maps/map_files/Mafia/" + suffix
	..(path = mappath)

/datum/map_template/mafia/summerball
	name = "Summerball 2020"
	description = "The original, the OG. The 2020 Summer ball was where mafia came from, with this map."
	suffix = "mafia_ball.dmm"

/datum/map_template/mafia/syndicate
	name = "Syndicate Megastation"
	description = "Yes, it's a very confusing day at the Megastation. Will the syndicate conflict resolution operatives succeed?"
	suffix = "mafia_syndicate.dmm"

/datum/map_template/mafia/lavaland
	name = "Lavaland Excursion"
	description = "The station has no idea what's going down on lavaland right now. Should have never unearthed those changelings... and syndicate operatives...?"
	suffix = "mafia_lavaland.dmm"

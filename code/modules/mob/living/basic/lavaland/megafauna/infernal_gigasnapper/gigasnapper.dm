///A very, VERY large crab.
/mob/living/basic/mining/megafauna/gigasnapper
	name = "infernal gigasnapper"
	desc = "\"Magmacarcinidae gigantus\", also known as a very, very large crab. Whether the presence of crustaceans is a cause or effect of this behemoth is uncertain."
	health = 1000
	maxHealth = 1000

	icon = 'icons/mob/simple/lavaland/gigasnapper/gigasnapper.dmi'
	icon_state = "gigasnapper"
	pixel_x = -32
	pixel_y = -16
	light_color = COLOR_PALE_ORANGE

	faction = list(FACTION_MINING, FACTION_BOSS, FACTION_CRAB, FACTION_GIGASNAPPER)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_SPECIAL

/mob/living/basic/mining/megafauna/gigasnapper/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/dir_restricted_movement, (EAST | WEST))
	AddComponent(/datum/component/boss_music, 'sound/lavaland/gigasnapper_boss.ogg', 106 SECONDS)
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/crab_dig = BB_GIGASNAPPER_DIG,
		/datum/action/cooldown/mob_cooldown/crab_collide = BB_GIGASNAPPER_COLLIDE,
		/datum/action/cooldown/mob_cooldown/crab_arena = BB_GIGASNAPPER_ARENA,
		/datum/action/cooldown/mob_cooldown/crab_minions = BB_GIGASNAPPER_MINIONS,
	)
	grant_actions_by_list(innate_actions)
	var/datum/action/cooldown/mob_cooldown/crab_arena/arena = locate(/datum/action/cooldown/mob_cooldown/crab_arena) in actions
	arena.update_all_locked_actions(FALSE)

/// returns all the turfs that the crab sprite touches
/mob/living/basic/mining/megafauna/gigasnapper/proc/get_crab_turfs(include_self_turf = FALSE) as /list
	var/list/dirs = list(NORTH, NORTHEAST, EAST, WEST, NORTHWEST)
	var/list/turfs = list()
	for(var/dir in dirs)
		var/turf/stepped = get_step(src, dir)
		if(stepped)
			turfs += stepped
	if(include_self_turf)
		turfs += get_turf(src)
	return turfs

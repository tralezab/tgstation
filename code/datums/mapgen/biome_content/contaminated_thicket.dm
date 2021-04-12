
#define TIME_UNTIL_NEXT_ACTION 4 MINUTES

//corrupt trees
/obj/structure/flora/tree/living
	name = "odd tree"
	desc = "Something about this tree doesn't seem right."
	icon = 'icons/obj/flora/thicket_trees.dmi'
	icon_state = "tree_1"
	pixel_x = -48
	pixel_y = -20
	log_type = /obj/item/grown/log/tree/living
	log_amount = 4
	///how many cycles have passed in process since last vine spread
	var/delta_waited = 0
	///when we will next act
	var/time_until = 0
	///how many vines we're managing right now
	var/vine_count = 0
	///our managed vines!
	var/list/vines = list()
	///a gutlunch we're trying to eat!
	var/mob/living/simple_animal/hostile/asteroid/gutlunch/target
	///reference to a beam we have to the target
	var/datum/beam/vine_beam

/obj/structure/flora/tree/living/examine(mob/user)
	. = ..()
	if(prob(25))
		. += "<span class='warning'>The tree is moving around, immediately falling dormant when you look directly.</span>"

/obj/structure/flora/tree/living/Initialize()
	. = ..()
	icon_state = "tree[rand(1,6)]"
	time_until += (TIME_UNTIL_NEXT_ACTION + rand(-1 MINUTES, 1 MINUTES))
	spread_vines()
	START_PROCESSING(SSobj, src)

/obj/structure/flora/tree/living/Destroy()
	QDEL_LIST(vines)
	. = ..()

/obj/structure/flora/tree/living/process(delta_time)
	delta_waited += delta_time
	if(delta_waited >= time_until)
		delta_waited = 0
		time_until += (TIME_UNTIL_NEXT_ACTION + rand(-1 MINUTES, 1 MINUTES))
		if(vines.len != vine_count)
			spread_vines()
		else
			target = locate(/mob/living/simple_animal/hostile/asteroid/gutlunch) in orange(7, src)
	if(target)
		if(get_dist(src, target) > 7)
			target = null
			return
		if(!vine_beam)
			vine_beam = Beam(target, "vine", maxdistance=7, beam_type=/obj/effect/ebeam/vine)
		step_towards(target, src)
		if(get_dist(src, target) < 1)
			target.gib()

			feed_animation()

/obj/structure/flora/tree/living/proc/spread_vines()
	for(var/turf/open/ground in circlerange(src, 3))
		var/skip = FALSE
		if(islava(ground))
			continue
		for(var/obj/thing in ground)
			if(thing.density)
				skip = TRUE
				break
		if(skip)
			continue
		if(locate(/obj/structure/alien/weeds/livingroot) in ground)
			continue
		vines += new /obj/structure/alien/weeds/livingroot(ground, src)
	vine_count = vines.len

/obj/structure/flora/tree/living/proc/feed_animation()
	Shake(15, 15, 1 SECONDS)
	color = "#ff0000"
	animate(src, time = 1 SECONDS, color = "#ffffff") //return to old color

/obj/structure/flora/tree/living/proc/fed_victim()
	feed_animation()
	new /mob/living/simple_animal/hostile/retaliate/thicket_guard(loc)

/obj/structure/flora/tree/living/attackby(obj/item/W, mob/user, params)
	if(!("plants" in user.faction))
		visible_message("<span class='warning'>[src] unleashes an otherworldly wail!</span>")
		for(var/mob/living/simple_animal/hostile/retaliate/thicket_guard/guard in orange(7, src))
			guard.Retaliate()
	. = ..()

/obj/structure/alien/weeds/livingroot
	name = "blood vines"
	desc = "These surfaced vines are looking for something to feed on."
	color = "#db7f34"
	icon = 'icons/effects/effects.dmi'
	icon_state = "thicket_vine"
	alpha = 150
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

	var/obj/structure/flora/tree/living/host_tree
	var/list/watched_creatures

/obj/structure/alien/weeds/livingroot/set_base_icon()
	return

/obj/structure/alien/weeds/livingroot/Initialize(mapload, host_tree)
	. = ..()
	src.host_tree = host_tree
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/start_watching)
	RegisterSignal(loc, COMSIG_ATOM_CREATED, .proc/start_watching)
	RegisterSignal(src, COMSIG_MOVABLE_UNCROSSED, .proc/stop_watching)

/obj/structure/alien/weeds/livingroot/proc/stop_watching(datum/source, atom/movable/potential_rider)
	SIGNAL_HANDLER
	remove_from_watched(potential_rider)

/obj/structure/alien/weeds/livingroot/proc/remove_from_watched(atom/movable/to_remove)
	SIGNAL_HANDLER
	if(!(to_remove in watched_creatures))
		return
	LAZYREMOVE(watched_creatures, to_remove)
	UnregisterSignal(to_remove, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))

/obj/structure/alien/weeds/livingroot/proc/start_watching(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	if(AM in watched_creatures)
		return
	var/mob/living/watched_mob = AM
	if(isvineimmune(watched_mob))
		return
	if(watched_mob.stat == DEAD)
		consume_dead(watched_mob, FALSE)
		return
	LAZYADD(watched_creatures, watched_mob)
	RegisterSignal(watched_mob, COMSIG_PARENT_QDELETING, .proc/remove_from_watched)
	RegisterSignal(watched_mob, COMSIG_LIVING_DEATH, .proc/consume_dead)

/obj/structure/alien/weeds/livingroot/proc/consume_dead(mob/living/killed, gibbed)
	if(gibbed)
		return
	visible_message("<span class='danger'>[src] reach out and tear [killed]'s body apart, feasting on the remains!</span>")
	var/feed_tree = TRUE
	if(istype(killed, /mob/living/simple_animal/hostile/asteroid/gutlunch))
		feed_tree = FALSE
	var/killed_name = killed.name
	killed.gib()
	if(feed_tree)
		host_tree.fed_victim(killed_name)

/obj/structure/alien/weeds/livingroot/Destroy()
	host_tree = null
	. = ..()

/obj/item/grown/log/tree/living
	name = "corrupt log"
	desc = "Something twisted has reconstructed the insides of this tree into gross, meaty innards."
	color = "#db7f34"
	plank_type = /obj/item/stack/sheet/meat

//mobs for the biome
/mob/living/simple_animal/hostile/retaliate/thicket_guard
	name = "thicket guard"
	desc = "A mysterious creature with only one purpose: defend the grove."
	loot = list(/obj/effect/gibspawner/human)
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	weather_immunities = list("lava","ash")
	faction = list("plants") //does not have normal factions so it will hunt gutlunches
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "tree_creation"
	icon_living = "tree_creation_aggro"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("logs")
	projectiletype = /obj/projectile/seedling


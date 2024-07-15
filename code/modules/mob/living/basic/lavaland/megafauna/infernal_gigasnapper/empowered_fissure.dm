
/// the name of the bubble when converted into a plasma bubble
#define PLASMA_BUBBLE_NAME "unstable bubble"
/// the new speed of the plasma bubble (this is half of the initial bubble speed)
#define PLASMA_BUBBLE_SPEED 5
/// the new range of the plasma bubble
#define PLASMA_BUBBLE_RANGE 4
/// the damage stepping on plasma deals
#define PLASMA_STEPON_DAMAGE 15
/// the name of the bubble when converted into a bluespace bubble
#define BLUESPACE_BUBBLE_NAME "strange bubble"
/// the damage stepping on a bluespace fissure deals
#define BLUESPACE_STEPON_DAMAGE 5
/// the name of the bubble when converted into a corrupted bubble
#define NECROPOLIS_BUBBLE_NAME "corrupted bubble"

///prototype empowered turfs for the gigasnapper boss, they do stuff when people step on them!
/obj/effect/empowered_fissure
	name = "fissure"
	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "empowered_base"
	///string used to tell the bubble which type of fissure it passed over
	var/bubble_name = ""
	///icon state for the emissive overlay, this is what people ACTUALLY see because empowered_base is invisible*
	///* not actually invisible, but 0,0,0,1 to make the empowered tile clickable
	/// also prefixed onto the name
	var/emissive_icon_state

/obj/effect/empowered_fissure/Initialize(mapload)
	. = ..()
	name = "[emissive_icon_state] [name]"
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/empowered_fissure/update_overlays()
	. = ..()
	. += emissive_icon_state
	. += emissive_appearance(icon, emissive_icon_state, src)

/obj/effect/empowered_fissure/proc/on_entered(datum/source, atom/movable/entering)
	. = ..()
	if(!isliving(entering))
		return
	var/mob/living/living_entering = entering
	if(FACTION_GIGASNAPPER in living_entering.faction)
		return
	step_effect(living_entering)

///how this fissure inflicts damage when stepped on by a non-gigasnapper-aligned living
/obj/effect/empowered_fissure/proc/step_effect(mob/living/living_arrived)
	return

/// plasma fissure
/// step effect - burns and ignites
/// bubble effect - speeds up and detonates into an area of temp lava
/obj/effect/empowered_fissure/plasma
	emissive_icon_state = "plasma"
	bubble_name = PLASMA_BUBBLE_NAME

/obj/effect/empowered_fissure/plasma/step_effect(mob/living/living_arrived)
	living_arrived.balloon_alert(living_arrived, "fissure ignites you!")
	playsound(living_arrived, 'sound/items/welder2.ogg', 50, FALSE)
	living_arrived.take_overall_damage(0, PLASMA_STEPON_DAMAGE)
	living_arrived.adjust_fire_stacks(2)
	living_arrived.ignite_mob()

/// bluespace fissure
/// step effect - teleports to the other side of the crab
/// bubble effect - on impact, creates a second bluespace bubble on the arena wall moving in the same direction
/obj/effect/empowered_fissure/bluespace
	emissive_icon_state = "bluespace"
	bubble_name = BLUESPACE_BUBBLE_NAME

/obj/effect/empowered_fissure/bluespace/step_effect(mob/living/living_arrived)
	living_arrived.balloon_alert(living_arrived, "fissure blinks you!")
	playsound(living_arrived, 'sound/magic/blink.ogg', 50, TRUE)
	living_arrived.take_overall_damage(BLUESPACE_STEPON_DAMAGE)
	var/mob/living/basic/mining/megafauna/gigasnapper/crab = locate(/mob/living/basic/mining/megafauna/gigasnapper) in range(9, src)
	if(!crab)
		//shouldn't happen in a proper fight, but sanity
		return
	var/y_mirrored_to_crab = y + (abs(crab.y - y) * 2)
	var/turf/teleport_destination = locate(x, y_mirrored_to_crab, z)
	if(!teleport_destination)
		//map edge sanity
		return
	living_arrived.forceMove(teleport_destination)

/// necropolis fissure
/// step effect - arena closes by one tile
/// bubble effect - slows projectile, deals far more damage on impact
/obj/effect/empowered_fissure/necropolis
	emissive_icon_state = "necropolis"
	bubble_name = NECROPOLIS_BUBBLE_NAME

/obj/effect/spawner/random/empowered_fissure
	name = "random empowered turf"
	desc = "Spawns a random empowered turf."
	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "random"
	loot = list(
		/obj/effect/empowered_fissure/plasma = 1,
		/obj/effect/empowered_fissure/bluespace = 1,
		/obj/effect/empowered_fissure/necropolis = 1,
	)

///crab bubbles, which become empowered when passing over fissures
/obj/projectile/crab_bubble
	name = "salt bubble"
	icon_state = "gumball"
	color = COLOR_WHITE
	hitsound = 'sound/effects/splat.ogg'
	ignored_factions = list(FACTION_GIGASNAPPER)
	damage = 15
	speed = 10
	range = 20
	light_system = OVERLAY_LIGHT
	jitter = 3 SECONDS
	stutter = 3 SECONDS
	damage_type = BRUTE
	pass_flags = PASSTABLE
	//for bluespace bubbles
	var/is_copy = FALSE

/obj/projectile/crab_bubble/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	/// make sure to avoid empowering if we actually hit something on this turf
	if(QDELETED(src))
		return
	if(name != src::name)
		//already modified
		return
	var/obj/effect/empowered_fissure/fissure = locate(/obj/effect/empowered_fissure) in get_turf(src)
	if(!fissure)
		return
	become_special_bubble(fissure.bubble_name)

/obj/projectile/crab_bubble/on_hit(atom/target, blocked, pierce_hit)
	if(is_copy)
		return ..()
	switch(name)
		if(PLASMA_BUBBLE_NAME)
			for(var/turf/lava_turf in RANGE_TURFS(1, get_turf(src)))
				new /obj/effect/temp_visual/lava_warning(lava_turf)
		if(BLUESPACE_BUBBLE_NAME)
			/// get the wall in the opposite direction bubble travelled in
			var/turf/copy_turf = get_copy_turf()
			if(!copy_turf)
				return ..()
			var/obj/projectile/crab_bubble/bubble_copy = new /obj/projectile/crab_bubble(copy_turf)
			bubble_copy.firer = firer
			bubble_copy.become_special_bubble(BLUESPACE_BUBBLE_NAME)
			bubble_copy.is_copy = TRUE
			bubble_copy.hitsound = 'sound/effects/bamf.ogg'
			bubble_copy.preparePixelProjectile(target, copy_turf)
			bubble_copy.fire(dir2angle(dir), target)
	..()

/obj/projectile/crab_bubble/on_range()
	if(name == PLASMA_BUBBLE_NAME)
		for(var/turf/lava_turf in RANGE_TURFS(1, get_turf(src)))
			new /obj/effect/temp_visual/lava_warning(lava_turf)
	. = ..()

///applies property changes based on the fissure's bubble name
/obj/projectile/crab_bubble/proc/become_special_bubble(bubble_name)
	name = bubble_name
	switch(bubble_name)
		if(PLASMA_BUBBLE_NAME)
			damage_type = BURN
			color = COLOR_VIOLET
			speed = PLASMA_BUBBLE_SPEED
			range = PLASMA_BUBBLE_RANGE
			hitsound = 'sound/items/welder2.ogg'
		if(BLUESPACE_BUBBLE_NAME)
			color = COLOR_BRIGHT_BLUE
			light_range = 3
			hitsound = 'sound/magic/blink.ogg'

///searches backwards until the next turf would be the arena wall
///returns null if no arena wall was encountered, fringe map edge sanity
/obj/projectile/crab_bubble/proc/get_copy_turf()
	var/tries = 18
	var/turf/current = get_turf(src)
	var/search_dir = turn(dir, 180)
	while(tries)
		tries -= 1
		var/turf/next = get_step(current, search_dir)
		if(!next)
			return null
		var/obj/effect/gigasnapper_arena/arena_wall = locate(/obj/effect/gigasnapper_arena) in next
		if(arena_wall)
			return current
		current = next

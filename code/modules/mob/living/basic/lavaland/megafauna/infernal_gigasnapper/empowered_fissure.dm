
///the name of the bubble when converted into a plasma bubble
#define PLASMA_BUBBLE_NAME "unstable bubble"
///the new speed of the plasma bubble (this is half of the initial bubble speed)
#define PLASMA_BUBBLE_SPEED 5
///the new range of the plasma bubble
#define PLASMA_BUBBLE_RANGE 4
///the damage stepping on plasma deals
#define PLASMA_STEPON_DAMAGE 15

///prototype empowered turfs for the gigasnapper boss, they do stuff when people step on them!
/obj/effect/empowered_fissure
	name = "fissure"
	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "empowered_base"
	///icon state for the emissive overlay, this is what people ACTUALLY see because empowered_base is invisible*
	///* not actually invisible, but 0,0,0,1 to make the empowered tile clickable
	/// also prefixed onto the name
	var/emissive_icon_state

/obj/effect/empowered_fissure/Initialize(mapload)
	. = ..()
	name = "[emissive_icon_state] [name]"
	update_appearance()

/obj/effect/empowered_fissure/update_overlays()
	. = ..()
	. += emissive_icon_state
	. += emissive_appearance(icon, emissive_icon_state, src)

/obj/effect/empowered_fissure/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/living_arrived = arrived
	if(FACTION_GIGASNAPPER in living_arrived.faction)
		return
	step_effect(living_arrived)

///how this fissure inflicts damage when stepped on by a non-gigasnapper-aligned living
/obj/effect/empowered_fissure/proc/step_effect(mob/living/living_arrived)
	return

///how this fissure changes bubbles that pass over them
/obj/effect/empowered_fissure/proc/bubble_effect(obj/projectile/crab_bubble/bubble)
	return

/obj/effect/empowered_fissure/plasma
	emissive_icon_state = "plasma"

/obj/effect/empowered_fissure/plasma/step_effect(mob/living/living_arrived)
	balloon_alert(living_arrived, "fissure burns!")
	playsound(living_arrived, 'sound/items/welder2.ogg', 50, FALSE)
	living_arrived.take_overall_damage(0, PLASMA_STEPON_DAMAGE)
	living_arrived.adjust_fire_stacks(2)
	living_arrived.ignite_mob()

/obj/effect/empowered_fissure/plasma/bubble_effect(obj/projectile/crab_bubble/bubble)
	bubble.name = PLASMA_BUBBLE_NAME
	bubble.damage_type = BURN
	bubble.color = COLOR_VIOLET
	bubble.speed = PLASMA_BUBBLE_SPEED
	bubble.range = PLASMA_BUBBLE_RANGE
	bubble.hitsound = 'sound/items/welder2.ogg'

/obj/effect/empowered_fissure/bluespace
	emissive_icon_state = "bluespace"

/obj/effect/empowered_fissure/necropolis
	emissive_icon_state = "necropolis"

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
	name = "bubble"
	icon_state = "gumball"
	color = COLOR_BLUE_LIGHT
	hitsound = 'sound/effects/splat.ogg'
	ignored_factions = list(FACTION_GIGASNAPPER)
	damage = 10
	speed = 10
	range = 20
	light_system = OVERLAY_LIGHT
	jitter = 3 SECONDS
	stutter = 3 SECONDS
	damage_type = BRUTE
	pass_flags = PASSTABLE

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
	fissure.bubble_effect(src)

/obj/projectile/crab_bubble/on_range()
	if(name == PLASMA_BUBBLE_NAME)
		for(var/turf/lava_turf in RANGE_TURFS(1, get_turf(src)))
			new /obj/effect/temp_visual/lava_warning(lava_turf)
	. = ..()

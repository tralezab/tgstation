/// arena ability, how big the square arena is in tiles
#define ARENA_SIZE 9
/// dig ability, how long the crab channels to reposition to a new area
#define DIG_CHANNEL_TIME 2 SECONDS
/// summon ability, how long the crab channels to summon
#define SUMMON_CHANNEL_TIME 4 SECONDS
/// how many seconds to wait to clear out a mineral turf. this is multiplied by the distance to the center.
#define CLEAR_MINERAL_DELAY 0.1 SECONDS
/// how much burn damage is taken when touching a wall
#define WALL_BURN_DAMAGE 15
/// how long a wall that burns someone flashes a certain color
#define WALL_BURN_COLOR_TIME 1 SECONDS

/datum/action/cooldown/mob_cooldown/crab_dig
	name = "Crustacean Reposition"
	desc = "Tunnel to a new location."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/crab_dig/Activate(atom/target_atom)
	//TODO: Arena check
	if(!channel())
		owner.balloon_alert(owner, "interrupted!")
		return
	reposition(owner)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/crab_dig/proc/channel()
	disable_cooldown_actions()
	owner.visible_message(span_warning("[owner] begins digging into the ground..."))
	var/success = do_after(owner, DIG_CHANNEL_TIME, owner)
	enable_cooldown_actions()
	return success

/datum/action/cooldown/mob_cooldown/crab_dig/proc/reposition(mob/living/crab, atom/target)
	///TODO
	//player chooses a location with a point and click before activate
	//	if no player, auto decision somewhere on a nearby target or random if none
	//chargeup sequence, cant do anything
	//leap
	return

/datum/action/cooldown/mob_cooldown/crab_arena
	name = "Raise Molten Crucible Arena"
	desc = "Create an arena around you. No cooldown to raise, but a cooldown after lowering the arena."
	cooldown_time = 30 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE
	///if the arena is raised, this list will have references to the walls.
	var/list/arena_turfs = list()
	///initializes into a list of all the types created by the boss while an arena is active for cleanup.
	var/static/list/types_to_remove
	///weak reference to the center of the arena
	var/datum/weakref/weak_arena_center_turf

/datum/action/cooldown/mob_cooldown/crab_arena/link_to(Target)
	. = ..()
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/action/cooldown/mob_cooldown/crab_arena/Activate(atom/target_atom)
	toggle_arena()
	if(!arena_turfs.len)
		StartCooldown()

/datum/action/cooldown/mob_cooldown/crab_arena/proc/update_all_locked_actions(is_arena_active)
	/datum/action/cooldown/mob_cooldown/crab_dig
	unlock_when_arena_inactive(/datum/action/cooldown/mob_cooldown/crab_dig, is_arena_active)
	unlock_when_arena_active(/datum/action/cooldown/mob_cooldown/crab_collide, is_arena_active)
	unlock_when_arena_active(/datum/action/cooldown/mob_cooldown/crab_minions, is_arena_active)

/datum/action/cooldown/mob_cooldown/crab_arena/proc/unlock_when_arena_active(action_type, is_arena_active)
	var/mob/mob_target = target
	var/datum/action/cooldown/action = locate(action_type) in mob_target.actions
	if(!action)
		return
	if(is_arena_active)
		action.enable()
	else
		action.disable()

/datum/action/cooldown/mob_cooldown/crab_arena/proc/unlock_when_arena_inactive(action_type, is_arena_active)
	var/mob/mob_target = target
	var/datum/action/cooldown/action = locate(action_type) in mob_target.actions
	if(!action)
		return
	if(is_arena_active)
		action.disable()
	else
		action.enable()

///signal that clears the arena and any effects created from the fight
/datum/action/cooldown/mob_cooldown/crab_arena/proc/on_death()
	SIGNAL_HANDLER
	destroy_arena()

///toggles the arena on and off, creating a square of blocking effects to contain the fight.
/datum/action/cooldown/mob_cooldown/crab_arena/proc/toggle_arena()
	if(!arena_turfs.len)
		create_arena()
	else
		destroy_arena()

///builds the arena, which involves clearing rocks and raising the crucible wall.
/datum/action/cooldown/mob_cooldown/crab_arena/proc/create_arena()
	var/turf/crab_turf = get_turf(owner)
	for(var/turf/range_turf as anything in RANGE_TURFS(ARENA_SIZE, crab_turf))
		var/dist_from_center = get_dist(range_turf, crab_turf)
		if(range_turf && dist_from_center == ARENA_SIZE)
			arena_turfs += new /obj/effect/gigasnapper_arena(range_turf, src)
		if(ismineralturf(range_turf))
			var/delay = (CLEAR_MINERAL_DELAY * dist_from_center) + rand(-0.1 SECONDS, 0.1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(try_clearing_mineral), range_turf), delay)
	weak_arena_center_turf = WEAKREF(crab_turf)
	update_all_locked_actions(TRUE)

/datum/action/cooldown/mob_cooldown/crab_arena/proc/destroy_arena()
	var/turf/arena_center_turf = weak_arena_center_turf?.resolve()
	if(!arena_center_turf)
		return
	if(!types_to_remove)
		types_to_remove = list(
			/obj/effect/empowered_fissure,
			/obj/effect/temp_visual/telegraphing/create_type/smallsnipper,
			/mob/living/basic/crab/smallsnipper,
			/obj/projectile/crab_bubble,
		)
	var/list/cleanup_turfs = RANGE_TURFS(ARENA_SIZE-1, get_turf(owner))
	for(var/turf/cleanup_turf as anything in cleanup_turfs)
		for(var/type_to_remove in types_to_remove)
			var/atom/found = locate(type_to_remove) in cleanup_turf
			if(found)
				qdel(found)
	//walls
	for(var/turf/arena_turf as anything in arena_turfs)
		qdel(arena_turf)
	arena_turfs.Cut()
	weak_arena_center_turf = null
	update_all_locked_actions(FALSE)

/datum/action/cooldown/mob_cooldown/crab_arena/proc/try_clearing_mineral(turf/scrape_turf)
	//double check that the turf is still a mineral, to avoid unnecessary scraping
	if(ismineralturf(scrape_turf))
		var/turf/closed/mineral/drill_turf = scrape_turf
		drill_turf.gets_drilled()

///helper for other abilities, grabs open spaces without anything on them
///
///criteria for a "good" turf for other abilities to place on:
/// * open floor
/// * no mobs, player gigasnapper or smallsnipper
/// * none of the sprite-covered turfs considered "crab_turfs" by the megafauna
/// * no empowered turfs
/datum/action/cooldown/mob_cooldown/crab_arena/proc/get_spawn_turfs() as /list
	var/turf/arena_center_turf = weak_arena_center_turf?.resolve()
	if(!arena_center_turf)
		return list()
	var/mob/living/basic/mining/megafauna/gigasnapper/crab = owner
	var/list/good_turfs = list()
	var/list/arena_turfs = RANGE_TURFS(ARENA_SIZE-1, arena_center_turf)
	arena_turfs -= crab.get_crab_turfs()
	for(var/turf/arena_turf as anything in arena_turfs)
		if(!isopenturf(arena_turf))
			continue
		if(/obj/effect/empowered_fissure in arena_turf)
			continue
		if(/mob/living in arena_turf)
			continue
		good_turfs += arena_turf
	return good_turfs

/obj/effect/gigasnapper_arena
	name = "molten crucible"
	desc = "Deep rock raised around a singular point. Still very hot from thermal activity below."

	density = TRUE
	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "crucible_rock"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/gigasnapper_arena/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/effect/gigasnapper_arena/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return
	var/mob/living/bumped_living = bumped_atom
	if(FACTION_GIGASNAPPER in bumped_living.faction)
		return
	balloon_alert(bumped_living, "burned from touching!")
	playsound(bumped_living, 'sound/items/welder2.ogg', 50, FALSE)
	bumped_living.take_overall_damage(0, WALL_BURN_DAMAGE)
	color = COLOR_RED
	animate(src, color = COLOR_WHITE, time = WALL_BURN_COLOR_TIME)

/obj/effect/gigasnapper_arena/update_overlays()
	. = ..()
	. += "crucible_lava"
	. += emissive_appearance(icon, "crucible_lava", src)



/datum/action/cooldown/mob_cooldown/crab_minions
	name = "Call of Cancer"
	desc = "Channel to summon crab minions inside the arena, depending on how much health missing. The arena must be active."
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/crab_minions/Activate(atom/target)
	if(!channel())
		owner.balloon_alert(owner, "interrupted!")
		return
	summon(owner)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/crab_minions/proc/channel()
	disable_cooldown_actions()
	owner.visible_message(span_warning("[owner] begins rhythmically waving [owner.p_their()] claws in the air..."))
	var/success = do_after(owner, SUMMON_CHANNEL_TIME, owner)
	enable_cooldown_actions()
	return success

/// summons 1 - 3 crabs, gaining an extra crab summoned for each third chunk of health lost
/// (so 2 under 2/3rds and 3 under 1/3rds)
/datum/action/cooldown/mob_cooldown/crab_minions/proc/summon(mob/living/crab)
	var/crabs_to_summon = 1
	var/third_of_health = crab.maxHealth / 3
	if(crab.health < third_of_health * 2)
		crabs_to_summon++
	if(crab.health < third_of_health)
		crabs_to_summon++
	var/datum/action/cooldown/mob_cooldown/crab_arena/arena = locate(/datum/action/cooldown/mob_cooldown/crab_arena) in crab.actions
	var/list/spawn_turfs
	if(arena)
		spawn_turfs = arena.get_spawn_turfs()
	else
		spawn_turfs = RANGE_TURFS(ARENA_SIZE, get_turf(crab))
	for(var/i in 1 to crabs_to_summon)
		if(!spawn_turfs.len)
			break
		var/turf/spawn_turf = pick_n_take(spawn_turfs)
		new /obj/effect/temp_visual/telegraphing/create_type/smallsnipper(spawn_turf)

#undef CLEAR_MINERAL_DELAY
#undef ARENA_SIZE
#undef SUMMON_CHANNEL_TIME
#undef DIG_CHANNEL_TIME
#undef WALL_BURN_DAMAGE
#undef WALL_BURN_COLOR_TIME

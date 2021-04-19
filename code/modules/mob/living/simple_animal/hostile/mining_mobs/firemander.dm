///firemander telegraphs fire going into itself from one direction
#define ATTACK_BREATHE_IN 1
///attack above, but it's going out from that one direction
#define ATTACK_BREATHE_OUT 2
///burrows and appears somewhere else after a small delay.
///will try to do this on its last target if it loses the target, preventing the fight from ending until you land somewhere it cannot burrow to (lavaland outpost, off z, etc)
#define ATTACK_REPOSITION 3

///defines for whether the telegraphed attack should start at a distance and go to the firemander...
#define INWARDS "inwards"
///or if the telegraphed attack should instead go from the firemander to a distance
#define OUTWARDS "outwards"

///firemander! see defines for attacks.
/mob/living/simple_animal/hostile/asteroid/firemander
	name = "firemander"
	desc = "An amphibian that has lava-proof skin. One of the last few \"true\" original inhabitants of lavaland pre-corruption. \
	The significant temperature increase of the planet has done absolutely nothing but increase its hunting grounds."
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	deathmessage = "melts!"
	deathsound = 'sound/effects/screech.ogg'
	attack_sound = 'sound/weapons/bladeslice.ogg'
	icon_state = "firemander"
	icon_living = "firemander"
	attack_verb_simple = "bite"
	attack_verb_continuous = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	maxHealth = 200
	health = 200
	obj_damage = 100
	light_range = 1
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right
	light_power = 2
	ranged_cooldown_time = 4 SECONDS
	melee_damage_lower = 25
	melee_damage_upper = 25
	del_on_death = TRUE
	emote_taunt = list("angrily hisses")
	taunt_chance = 10
	speak_emote = list("slithers")
	///which attack the firemander will try to perform
	var/current_attack = ATTACK_BREATHE_IN
	///if the firemander is currently attacking, to prevent movement and attack stacking
	var/attacking = FALSE
	var/burrowed = FALSE
	///for extra attack patterns past a threshold
	var/under_half_health = FALSE

/mob/living/simple_animal/hostile/asteroid/firemander/adjustHealth(amount, updating_health, forced)
	. = ..()
	if(!under_half_health && health < maxHealth / 2)
		under_half_health = TRUE
		visible_message("<span class='warning'>[src] heats up, beginning to glow brightly!</span>")
		set_light_range(4)
		return
	if(under_half_health && health >= maxHealth / 2)
		under_half_health = FALSE
		visible_message("<span class='warning'>[src] cools off, returning to its natural state.</span>")
		set_light_range(1)

/mob/living/simple_animal/hostile/asteroid/firemander/OpenFire(atom/A)
	if(attacking)
		return
	switch(current_attack)
		if(ATTACK_BREATHE_IN)
			current_attack = ATTACK_BREATHE_OUT
			breathe(INWARDS)
		if(ATTACK_BREATHE_OUT)
			current_attack = ATTACK_REPOSITION
			breathe(OUTWARDS)
		if(ATTACK_REPOSITION)
			current_attack = ATTACK_BREATHE_IN
			if(!burrowed && should_burrow(target, z))
				reposition(target)
			else
				OpenFire(target) //try again with breathe
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/firemander/LoseTarget()
	if(target && !burrowed)
		if(should_burrow(target, z))
			INVOKE_ASYNC(src, .proc/reposition, target)//try to refind our target via burrowing, but allow target to be lost
	. = ..()

/mob/living/simple_animal/hostile/asteroid/firemander/Goto(target, delay, minimum_distance)
	if(attacking)
		return
	. = ..()

/mob/living/simple_animal/hostile/asteroid/firemander/proc/breathe(mode)
	if(get_dist(src, target) > 7)
		return
	attacking = TRUE
	walk(src, 0)
	var/list/fire_dirs = GLOB.alldirs.Copy()
	var/fire_lines = under_half_health ? 4 : 2
	var/added_cooldown = 0
	for(var/i in 1 to fire_lines)
		var/telegraph = mode == OUTWARDS ? 0.2 SECONDS : 1 SECONDS
		var/added_telegraph = mode == OUTWARDS ? 0.17 SECONDS : 0.2 SECONDS
		var/turf/target_turf = get_turf(target)
		if(i == 1)//always take the furthest dir from the target for one of the fire lines
			var/furthest_possible_target_turf_direction = get_dir(src, target)
			fire_dirs -= furthest_possible_target_turf_direction
			target_turf = get_step(target_turf, furthest_possible_target_turf_direction)
		else
			target_turf = get_step(target_turf, pick_n_take(fire_dirs))
		var/list/line_to_target = getline(src, target_turf) - get_turf(src)
		if(mode == INWARDS)
			reverseRange(line_to_target) //makes the fire chain go the other way around
		for(var/turf/turf_in_line as anything in line_to_target)
			new /obj/effect/temp_visual/telegraphing/firemander(turf_in_line, telegraph, src)
			telegraph += added_telegraph
		if(telegraph > added_cooldown) //the cooldown of this attack
			added_cooldown = telegraph
	ranged_cooldown_time += added_cooldown
	addtimer(VARSET_CALLBACK(src, attacking, FALSE), added_cooldown)

//light checks before burrowing to see if it would fail
/mob/living/simple_animal/hostile/asteroid/firemander/proc/should_burrow(atom/target, our_last_z)
	var/area/target_area = get_area(target)
	if(target.z != our_last_z || !(target_area.area_flags & MOB_SPAWN_ALLOWED))
		return FALSE
	return TRUE

//checks after burrowing to see if it should be aborted, returning to the turf it started on
/mob/living/simple_animal/hostile/asteroid/firemander/proc/try_emerge(turf/abort_destination, atom/target)
	if(!should_burrow(target, abort_destination.z))
		return emerge(abort_destination, null)
	var/turf/reposition_destination
	for(var/turf/open/possible_destination in shuffle(circlerangeturfs(target, 4)))
		if(get_dist(target, possible_destination) < 4) //only the outer turfs in the circle (perimeter if you will :])
			continue
		reposition_destination = possible_destination
		break
	if(!reposition_destination)
		return emerge(abort_destination, null)
	emerge(reposition_destination, target)

/mob/living/simple_animal/hostile/asteroid/firemander/proc/reposition(target)
	var/turf/burrow_start_turf = get_turf(src)
	new /obj/effect/supplypod_rubble/firemander(burrow_start_turf)
	visible_message("<span class='warning'>[src] burrows underground!</span>")
	burrowed = TRUE
	moveToNullspace()
	addtimer(CALLBACK(src, .proc/try_emerge, burrow_start_turf, target), rand(1 SECONDS, 2 SECONDS))

//target may not exist when this is called
/mob/living/simple_animal/hostile/asteroid/firemander/proc/emerge(turf/destination, atom/stored_target)
	forceMove(destination)
	burrowed = FALSE
	visible_message("<span class='warning'>[src] emerges from the ground!</span>")
	if(!target && stored_target)
		target = stored_target
	if(target)
		manual_emote("[pick(emote_taunt)] at [target].")
		Goto(target, move_to_delay, minimum_distance)
		GainPatience()
	var/obj/effect/supplypod_rubble/firemander/hole = new /obj/effect/supplypod_rubble/firemander(get_turf(src))
	if(under_half_health)
		for(var/hole_dir in GLOB.alldirs)
			var/turf/fire_turf = get_step(hole, hole_dir)
			new /obj/effect/temp_visual/telegraphing/firemander(fire_turf, 0.5 SECONDS, src)
	attacking = FALSE

/obj/effect/temp_visual/telegraphing/firemander
	duration = 1 SECONDS
	///firemander who telegraphed this
	var/mob/living/source

/obj/effect/temp_visual/telegraphing/firemander/Initialize(mapload, duration, source)
	src.duration = duration
	src.source = source
	. = ..()

/obj/effect/temp_visual/telegraphing/firemander/Destroy()
	new /obj/effect/temp_visual/firemander_fire(loc, source)
	. = ..()

/obj/effect/temp_visual/firemander_fire
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	var/list/hit_targets
	///firemander who telegraphed this
	var/mob/living/source

/obj/effect/temp_visual/firemander_fire/Initialize(mapload, source)
	src.source = source
	. = ..()
	playsound(get_turf(src), 'sound/magic/fireball.ogg', 150, TRUE)
	for(var/mob/living/caught in get_turf(src))
		target_burned(caught)

/obj/effect/temp_visual/firemander_fire/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM))
		target_burned(AM)

/obj/effect/temp_visual/firemander_fire/proc/target_burned(mob/living/burned)
	if(burned == source)
		return
	if(LAZYFIND(hit_targets, burned))
		return
	LAZYADD(hit_targets, burned)
	to_chat(burned, "<span class='userdanger'>You're hit by [source]'s fire breath!</span>")
	burned.adjustFireLoss(10)
	burned.adjust_fire_stacks(2)
	burned.IgniteMob()

///makes for a really good effect, actually!
/obj/effect/supplypod_rubble/firemander
	name = "burrowed earth"
	desc = "A fair sized hole created by some creature digging into the earth."

/obj/effect/supplypod_rubble/firemander/Initialize(mapload)
	. = ..()
	fadeAway()

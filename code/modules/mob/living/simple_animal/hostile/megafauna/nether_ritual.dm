
/*

Netherworld Ritual + Netherworld Abomination

Ritualists who bring forth a creature from another world.

One cultist will attack at a time, with different patterns of attack. They can also cast an ability to swap out with another cultist, and will swap out more and more as they are damaged

With all cultists dead, the ritual will collect their bodies and the netherworld abomination will be released somewhere on lavaland.

When butchered, they leave behind diamonds, sinew, bone, and ash drake hide. Ash drake hide can be used to create a hooded cloak that protects its wearer from ash storms.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/cultist
	name = "cultist"
	desc = "Buggy and stupid, this one never gets invited to the cultist parties."
	health = 500
	maxHealth = 500
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stabs"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "cultist_shield"
	icon_living = "cultist_shield"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("chants")
	melee_damage_lower = 20
	melee_damage_upper = 20
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/ashdrake = 10)
	var/turf/return_turf //where the cultist teleports to when swapped out, set to where they spawn in
	var/swapped_in = FALSE //false means some other cultist is attacking
	var/attacking_attacks = 0 //counts up, increases the chance the cultist will swap out
	var/static/list/dying_text //can no longer fight the player
	var/static/list/death_text //dead
	var/cult_title = "Bugged" //name of the cultist appended
	var/obj/effect/summoning_rune/rune //rune to add the second megafauna
	var/swap_in_line = "My spells don't work, so can you just drop dead? Man, all my friends are gonna laugh at me again..."
	var/datum/beam/beam //rune charging effect
	ranged_cooldown_time = 3 SECONDS
	true_spawn = FALSE //there are 5 of them, we can't have them all give achievements. the last one alive will give the achievements
	achievement_type = /datum/award/achievement/boss/drake_kill
	crusher_achievement_type = /datum/award/achievement/boss/drake_crusher
	score_achievement_type = /datum/award/score/drake_score
	deathmessage = "is pulled into the portal!"
	deathsound = 'sound/magic/demon_dies.ogg'
	del_on_death = TRUE

/mob/living/simple_animal/hostile/megafauna/cultist/Initialize()
	. = ..()
	var/area/ritual_area = get_area(src)
	for(var/obj/effect/summoning_rune/_rune in ritual_area)
		rune = _rune
	if(swapped_in)
		charge_rune()
	fully_replace_character_name(name, "[pick(GLOB.first_names)] the [cult_title]")
	if(!dying_text)
		dying_text = list("I'm too weak!", "The ritual must be completed at all costs!", "I cannot continue fighting!", "This power cannot die with me!", "They're waiting for us on the other side!")
	if(!death_text)
		death_text = list("HEL-", "HAHAHAHAH-", "IMPOS-", "YES! HERE THEY C-", "WAI-")
	return_turf = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/cultist/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!swapped_in)
		visible_message("<span class='warning'>[src] is shielded from attacks!")
		return
	if(amount > health)
		amount = health - 1
	. = ..()
	if(health == 1)
		var/mob/living/simple_animal/hostile/megafauna/cultist/swapout_cultist = can_swap()
		say(pick_n_take(dying_text))
		swap_out(notrap = TRUE)
		if(swapout_cultist)
			swapout_cultist.swap_in()
			return
		//nobody can swap, end it
		say("IT'S READY! YOU'RE ALREADY DEAD, INTERLOPER!")
		var/list/cultists = list()
		for(var/mob/living/simple_animal/hostile/megafauna/cultist/cult in get_area(src)) //do this beforehand to avoid lag (and use lag to turn off the beams in a cool way
			cultists += cult
			QDEL_NULL(cult.beam)
		sleep(3 SECONDS)
		true_spawn = TRUE //this guy will give the non normal loot (crusher, achievement, etc)
		//for(var/mob/living/simple_animal/hostile/megafauna/cultist/cult in range(src, 5)) //USE ON THE SKULLS
		for(var/ded in cultists)
			var/mob/living/simple_animal/hostile/megafauna/cultist/C = ded
			C.say(pick_n_take(death_text))
			C.health = 0
			C.death()
		rune.start_animations()

/mob/living/simple_animal/hostile/megafauna/cultist/GainPatience()


/mob/living/simple_animal/hostile/megafauna/cultist/ex_act(severity, target)
	return// because SOMEONE brought explosives to the party

/mob/living/simple_animal/hostile/megafauna/cultist/Move()
	if(swapped_in)
		. = ..()

/mob/living/simple_animal/hostile/megafauna/cultist/AttackingTarget() //no cheap shots, jerk
	if(swapped_in)
		. = ..()

/mob/living/simple_animal/hostile/megafauna/cultist/devour(mob/living/L)
	. = ..()
	swap_out(TRUE)//we win

/mob/living/simple_animal/hostile/megafauna/cultist/OpenFire()
	if(!swapped_in)
		return

	//this is the chance to swap out.
	//every 15 health lost is +1 to anger modifier which maxes out at 33 percent. every attack also adds 10 percent chance (to leave)
	anger_modifier = clamp(((maxHealth - health)/15),0,33) + (attacking_attacks * 10)
	ranged_cooldown = world.time + ranged_cooldown_time

	var/mob/living/simple_animal/hostile/megafauna/cultist/swapout_cultist = can_swap()

	if(!isliving(target))
		FindTarget() //hey you fuck
		return

	var/mob/living/attacking = target

	if(swapout_cultist && prob(anger_modifier) && attacking.stat <= SOFT_CRIT) //the stat check is so they don't swap around who is attacking an unconscious/dead body
		swap_out()
		swapout_cultist.swap_in()
		return

	cultist_attack()
	attacking_attacks++

/mob/living/simple_animal/hostile/megafauna/cultist/process()
	var/angle_to_rune = Get_Angle(src,rune)
	shoot_projectile(/obj/projectile/colossus, rune.loc, angle_to_rune)//shoot towards the rune to create a wall of projectiles
	shoot_projectile(/obj/projectile/colossus, rune.loc, abs(angle_to_rune-180))//shoot away from the rune to finish that will

/mob/living/simple_animal/hostile/megafauna/cultist/proc/cultist_attack() //base does nothing, their usual attacks
	to_chat(world, "[src] attack")
	return

/mob/living/simple_animal/hostile/megafauna/cultist/proc/cultist_trap() //base does nothing, trap left behind permanently to make the fight harder
	to_chat(world, "[src] trap")
	return

/mob/living/simple_animal/hostile/megafauna/cultist/proc/shoot_projectile(obj/projectile/projectile_type, turf/marker, set_angle) //shamelessly stolen from colossus BUT the projectile is an argument
	if(!isnum(set_angle) && (!marker || marker == loc) || !projectile_type)
		return
	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new projectile_type(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/cultist/proc/charge_rune()
	beam = src.Beam(rune,"lichbeam", beam_sleep_time = 50, time = INFINITY)

/mob/living/simple_animal/hostile/megafauna/cultist/proc/swap_in()
	swapped_in = TRUE
	icon_state = "cultist_fight"
	QDEL_NULL(beam)
	var/list/ordered_directions = list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)
	var/dir_index = ordered_directions.Find(get_dir(rune, target))
	if(dir_index == 1) //it'll bump down to 0 and runtime, need to put it at the end of the list bumped up instead
		dir_index = 9 //ordered_directions + 1 = out of bounds - 1 = we're good
	var/travel_direction = ordered_directions[dir_index--]
	//get turfs from the rune's turf in the travel_direction a certain length to finish this code (teleporting the cultist clockwise)
	var/turf/swap_in_turf = rune.loc
	for(var/i in 1 to 6)
		swap_in_turf = get_step(swap_in_turf, travel_direction)
	forceMove(swap_in_turf)
	say(swap_in_line)
	START_PROCESSING(SSfastprocess, src)

/mob/living/simple_animal/hostile/megafauna/cultist/proc/swap_out(notrap = FALSE)
	STOP_PROCESSING(SSfastprocess, src)
	swapped_in = FALSE
	attacking_attacks = 0
	icon_state = "cultist_shield"
	if(!notrap)
		cultist_trap()
	forceMove(return_turf)
	charge_rune()

/mob/living/simple_animal/hostile/megafauna/cultist/proc/can_swap() //any other cultists that can fight? if yes, returns a random one
	var/list/viable_cultists = list()
	var/area/ritual_area = get_area(src)
	for(var/mob/living/simple_animal/hostile/megafauna/cultist/cultist in ritual_area)
		if(cultist.health != 1 && !cultist.swapped_in) //defeated, or the cultist currently fighting can't swap in
			viable_cultists += cultist
	if(viable_cultists.len)
		return pick(viable_cultists)

/mob/living/simple_animal/hostile/megafauna/cultist/red
	cult_title = "Red"
	color = "red"
	desc = "Horrifically disfigured from burns, the robes cover the marks of one who has tamed the searing heat of the planet."
	swap_in_line = "You will burn!"

/mob/living/simple_animal/hostile/megafauna/cultist/red/cultist_attack() //shoots an inaccurate bomb that has a huge explosion
	var/turf/target_turf = get_turf(target)
	playsound(src,'sound/magic/fireball.ogg', 200, TRUE)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = Get_Angle(src, target_turf)
	var/static/list/inaccurate_shot_angles = list(12.5, 7.5, 2.5, 0, -2.5, -7.5, -12.5) //sometimes is right on target (0)
	shoot_projectile(/obj/projectile/redcultist_bomb, target_turf, angle_to_target + pick(inaccurate_shot_angles))

/mob/living/simple_animal/hostile/megafauna/cultist/red/cultist_trap() //leaves lava both on the place they last were AND where you were. this will become more and more of a problem
	new /obj/effect/temp_visual/lava_warning(get_turf(target), 0)
	new /obj/effect/temp_visual/lava_warning(get_turf(src), 0)

/mob/living/simple_animal/hostile/megafauna/cultist/yellow
	cult_title = "Yellow"
	color = "yellow"
	desc = "The engine could never truly die. Its latent magic is infused with this reality, and the stragglers of ratvar's cult use it to enact revenge on the world."
	swap_in_line = "Power surges through me, interloper!"

/mob/living/simple_animal/hostile/megafauna/cultist/blue //notably, this one starts the fight.
	cult_title = "Blue"
	color = "blue"
	desc = "Their mind glitters, And it's shine clears out the worldly memories of this cultist. This is the consequence for one who has unlocked the secrets of the hierophant."
	swap_in_line = "The ritual cannot be disturbed!"

//reminder = create that fukken wall of bullets aimed at and away from the rune thing

/mob/living/simple_animal/hostile/megafauna/cultist/blue/cultist_attack()//a lot of chaser swarms from hierophant
	var/obj/effect/temp_visual/hierophant/chaser/C = new(loc, src, target, 3, FALSE)
	C.moving = 3
	C.moving_dir = pick(GLOB.cardinals)
	SLEEP_CHECK_DEATH(9)

/mob/living/simple_animal/hostile/megafauna/cultist/black
	cult_title = "Black"
	color = "black"
	desc = "The whispers of grandeur from this planet have rocked them to their very core. At any cost, says the one who works for the wishgranter."
	swap_in_line = "You don't understand what you're doing, fool!"

/mob/living/simple_animal/hostile/megafauna/cultist/white
	cult_title = "White"
	desc = "One who has resolved to protect the necropolis. They know what the necropolis holds, and their determination to stop anyone from uncovering it is absolute."
	swap_in_line = "I will carry out the Necropolis' will!"

/mob/living/simple_animal/hostile/megafauna/cultist/white/cultist_attack() //colossus shotgun blast... basically.
	var/turf/target_turf = get_turf(target)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	newtonian_move(get_dir(target_turf, src))
	//var/angle_to_target = Get_Angle(src, target_turf)
	//var/static/list/shotgun_shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)
	//for(var/i in shotgun_shot_angles)
	//	shoot_projectile(whitecultist_curse, target_turf, angle_to_target + i)
	shoot_projectile(/obj/projectile/whitecultist_curse, target_turf, Get_Angle(src, target_turf))


//spawns the loot. does an animation. holds gps. changes both areas off of what they are, and destroys the walls to let the miner leave.

/obj/effect/summoning_rune
	icon = 'icons/effects/224x224.dmi'
	icon_state = "huge_rune"
	plane = FLOOR_PLANE
	//uses special pixel_w and z so the beams to this object don't correct for pixel x and y
	pixel_w = -96
	pixel_z = -96

/obj/effect/summoning_rune/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Otherworldly Screaming")

/obj/effect/summoning_rune/proc/start_animations()
	icon_state = "huge_portal"
	QDEL_IN(src, 10 SECONDS)

/obj/effect/summoning_rune/Destroy(force)
	//the ritual is over, time to clean up the areas to let the shield "down"
	var/area/newA = GLOB.areas_by_type[/area/lavaland/surface/outdoors]
	var/area/oldshield = GLOB.areas_by_type[/area/ruin/unpowered/ritual_site_shield]
	var/area/oldarena = get_area(src)
	for(var/T in oldshield.contents)
		if(istype(T, /obj/effect/forcefield/summoning))
			qdel(T)
		if(isturf(T))
			var/turf/transferturf = T
			newA.contents += transferturf
			transferturf.change_area(oldshield, newA)
	for(var/T in oldarena.contents)
		if(istype(T, /obj/effect/forcefield/summoning))
			qdel(T)
		if(isturf(T))
			var/turf/transferturf = T
			newA.contents += transferturf
			transferturf.change_area(oldarena, newA)

	new /obj/structure/closet/crate/necropolis/dragon(loc)
	. = ..()

/obj/effect/forcefield/summoning
	desc = "A byproduct of an ongoing summoning ritual. It allows entry through specific points... but not escape."
	name = "glowing wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultshield"
	CanAtmosPass = ATMOS_PASS_NO
	timeleft = 0

/obj/effect/portal/permanent/one_way/one_use/nether
	name = "ritual shield entrance"
	icon = 'icons/mob/nest.dmi'
	icon_state = "nether"
	icon_state = "nether"
	desc = "Seems to be a one way, one person at a time entrance to the ritual. You should make sure you enter prepared!"
	var/used = FALSE

/obj/effect/portal/permanent/one_way/one_use/nether/teleport(atom/movable/M, force = FALSE)
	if(used)
		if(isliving(M))
			var/mob/living/L = M
			to_chat(L, "<span class='warning'>[src] rejects you! The portal is on a cooldown from it's last use attempt.</span>")
	used = TRUE
	addtimer(VARSET_CALLBACK(src, used, FALSE), 20 SECONDS)
	var/area/arena = hard_target.loc //turf's location = area
	var/allowed_teleport = TRUE
	for(var/mob/living/L in arena.contents)
		if(ismegafauna(L))
			continue
		allowed_teleport = FALSE
		break
	if(!allowed_teleport)
		if(isliving(M))
			var/mob/living/L = M
			to_chat(L, "<span class='warning'>[src] rejects you! There is already someone inside fighting. You must wait for them to win... or die.</span>")
			return
	. = ..()

/obj/projectile/redcultist_bomb
	name ="magma bomb"
	icon_state= "pulse0"
	damage = 5
	armour_penetration = 100
	speed = 1 //slow
	eyeblur = 0
	damage_type = BURN

/obj/projectile/redcultist_bomb/on_hit(atom/target, blocked = FALSE)
	..()
	if(isliving(target))
		new /obj/effect/temp_visual/lava_warning(get_turf(target), 20 SECONDS)
	return BULLET_ACT_HIT

/obj/projectile/whitecultist_curse //low damage like red but speeds up white cultist on hit
	name = "dull curse"
	icon_state = "antimagic"
	hitsound = 'sound/effects/curse4.ogg'
	damage = 5
	armour_penetration = 100
	speed = 1 //slow
	eyeblur = 0
	damage_type = BURN

/obj/projectile/whitecultist_curse/on_hit(atom/target, blocked = FALSE)
	..()
	if(isliving(target))
		var/mob/living/simple_animal/hostile/megafauna/cultist/white = firer
		white.move_to_delay = 4
		addtimer(VARSET_CALLBACK(white, move_to_delay, initial(white.move_to_delay)),3 SECONDS)
	return BULLET_ACT_HIT

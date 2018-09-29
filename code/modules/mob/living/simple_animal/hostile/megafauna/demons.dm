#define MEDAL_PREFIX "Duo"

/*

THE DUO

The Duo spawns randomly wherever a lavaland creature is able to spawn.

Smalls has an assortment of ranged and melee options and will decide to switch sometimes, and Big is fully melee and very agressive.

When one dies, the other full heals and enters an enraged state, locking the killer in an arena and gaining many new attacks.

The first phase should be like the dragon in terms of the characters using a small range of attacks, being very predictable. The second phase should be very unpredictable and fast paced, more like the blood miner or whatever his name is

LOOT TBD??

Difficulty: ???

*/

/mob/living/simple_animal/hostile/megafauna/torment
	name = "Demon of Torment"
	desc = "A very small, dextrous demon. Has a very big, brutish friend."
	health = 1800
	maxHealth = 1800
	attacktext = "rends"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "Fugu0"
	icon_living = "Fugu0"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	speak_emote = list("gurgles")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -16
	del_on_death = 1
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	death_sound = 'sound/magic/enter_blood.ogg'
	do_footstep = TRUE
	var/attacking = FALSE
	var/patiencewithurshit = 2
	var/list/linked = list()

/obj/item/gps/internal/torment
	icon_state = null
	gpstag = "COM0" //A good bamboozle, but the location changing and the "Brutish Signal" near it will give it away.
	desc = "A GPS SIGNAL! I'LL STEAL IT! NO ONE WILL EVER KNOW!"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/torment/Initialize(mapload, initial = TRUE)
	. = ..()
	internal = new /obj/item/gps/internal/agony(src)
	if(initial)
		agony_boi()

/mob/living/simple_animal/hostile/megafauna/torment/proc/agony_boi()
	var/mob/living/simple_animal/hostile/megafauna/agony/A = new /mob/living/simple_animal/hostile/megafauna/agony(loc, FALSE)
	linked += A
	A.linked += src

/mob/living/simple_animal/hostile/megafauna/torment/OpenFire()
	if(attacking)
		return
	if(!client)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	var/mob/living/simple_animal/hostile/megafauna/agony/agony = linked.Find(/mob/living/simple_animal/hostile/megafauna/agony)
	var/turf/AT = get_turf(agony)
	var/turf/TT = get_turf(target)
	var/targetdist = get_dist(src.loc, target.loc)
	var/agonytargetdist = get_dist(target.loc, AT)
	if(targetdist > 7)
		if(agonytargetdist > 7)
			patiencewithurshit--
			if(!patiencewithurshit)
				INVOKE_ASYNC(src, .proc/stophammertime, target)
				agony.target = target
				agony.charge() //don't run from fights you lil bitch
				patiencewithurshit = 2
		new/obj/effect/temp_visual/decoy/fading(loc,src)
		forceMove(get_step(AT, pick(GLOB.alldirs)))
		DestroySurroundings()
	else
		if(!TT)
			return
		shoot_projectile(TT)

/mob/living/simple_animal/hostile/megafauna/torment/proc/shoot_projectile(turf/marker, set_angle)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/torment/proc/stophammertime(mob/living/victim)
	victim.Knockdown(60)
	to_chat(victim, "STOP RUNNING FROM US, COWARD!")

/mob/living/simple_animal/hostile/megafauna/torment/do_attack_animation(atom/A)
	if(attacking)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/torment/AttackingTarget()
	if(attacking)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/torment/Goto(target, delay, minimum_distance)
	if(attacking)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/agony
	name = "Demon of Agony"
	desc = "A very big, brutish demon. His friend does all the thinking."
	health = 2500
	maxHealth = 2500
	attacktext = "rends"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "Fugu1"
	icon_living = "Fugu1"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	speak_emote = list("gurgles")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -16
	del_on_death = 1
	crusher_loot = list(/obj/structure/closet/crate/necropolis/bubblegum/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	medal_type = BOSS_MEDAL_BUBBLEGUM
	score_type = BUBBLEGUM_SCORE
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	death_sound = 'sound/magic/enter_blood.ogg'
	do_footstep = TRUE
	var/charging = FALSE
	var/list/linked = list()

/obj/item/gps/internal/agony
	icon_state = null
	gpstag = "Brutish Signal"
	desc = "Dastardly Brutes and their signals!"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/agony/Initialize(mapload, initial = TRUE)
	. = ..()
	internal = new /obj/item/gps/internal/agony(src)
	if(initial)
		torment_boi()

/mob/living/simple_animal/hostile/megafauna/agony/proc/torment_boi()
	var/mob/living/simple_animal/hostile/megafauna/torment/T = new /mob/living/simple_animal/hostile/megafauna/torment(loc, FALSE)
	linked += T
	T.linked += src

/mob/living/simple_animal/hostile/megafauna/agony/OpenFire()
	if(charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	if(!client)
		INVOKE_ASYNC(src, .proc/charge)

/mob/living/simple_animal/hostile/megafauna/agony/do_attack_animation(atom/A)
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/agony/AttackingTarget()
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/agony/Goto(target, delay, minimum_distance)
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/agony/Move()
	if(!stat)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 200, 1, 2, 1)
	if(charging)
		new/obj/effect/temp_visual/decoy/fading(loc,src)
		DestroySurroundings()
	. = ..()
	if(charging)
		DestroySurroundings()

/mob/living/simple_animal/hostile/megafauna/agony/proc/charge()
	var/turf/T = get_turf(target)
	if(!T || T == loc)
		return
	new /obj/effect/temp_visual/dragon_swoop(T)
	charging = 1
	DestroySurroundings()
	walk(src, 0)
	setDir(get_dir(src, T))
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(loc,src)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 5)
	sleep(5)
	throw_at(T, get_dist(src, T), 1, src, 0)
	charging = 0
	Goto(target, move_to_delay, minimum_distance)


/mob/living/simple_animal/hostile/megafauna/agony/Bump(atom/A)
	if(charging)
		if(isturf(A) || isobj(A) && A.density)
			A.ex_act(EXPLODE_HEAVY)
		DestroySurroundings()
	..()

/mob/living/simple_animal/hostile/megafauna/agony/throw_impact(atom/A)
	if(!charging)
		return ..()

	else if(isliving(A))
		var/mob/living/L = A
		L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
		L.apply_damage(40, BRUTE)
		playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
		shake_camera(L, 4, 3)
		shake_camera(src, 2, 3)
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		L.throw_at(throwtarget, 3)

	charging = 0

#undef MEDAL_PREFIX
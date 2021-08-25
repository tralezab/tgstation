/datum/action/changeling/aggrograb
	name = "Digital Camouflage"
	desc = "By evolving our muscles to be much tighter, we are able to grab more powerfully."
	helptext = "We can instantly aggressively grab individuals."
	button_icon_state = "digital_camo"
	dna_cost = 1
	active = FALSE

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/aggrograb/sting_action(mob/user)
	..()
	if(active)
		to_chat(user, span_notice("We return to normal."))
		ADD_TRAIT(user, TRAIT_STRONG_GRABBER, "thingling")
	else
		to_chat(user, span_notice("We tense our muscles to aggressively grab instantly."))
		REMOVE_TRAIT(user, TRAIT_STRONG_GRABBER, "thingling")
	active = !active
	return TRUE

/datum/action/changeling/aggrograb/Remove(mob/user)
	REMOVE_TRAIT(user, TRAIT_STRONG_GRABBER, "thingling")
	..()


//lets gooo

/datum/action/changeling/horror
	name = "Horror Form"
	desc = "We tear apart our human disguise, revealing our true form."
	helptext = "We will become an unstoppable force of destruction. We will turn back into a human after some time."
	chemical_cost = 75
	button_icon_state = "last_resort"
	chemical_cost = 50
	dna_cost = 4
	req_human = 1

/datum/action/changeling/horror/sting_action(mob/living/user)
	set waitfor = FALSE
	if(user.incapacitated())
		return
	if(tgui_alert(user,"Are we sure we wish to enter horror form?","Horrorize",list("Yes", "No")) != "Yes")
		return
	..()
	user.visible_message(span_warning("[user] writhes and contorts, their body expanding to inhuman proportions!"), \
						span_danger("We begin our transformation to our true form!"))
	if(!do_after(user, 30, target = user))
		user.visible_message(span_warning("[user]'s transformation abruptly reverts itself!"), \
							span_warning("Our transformation has been interrupted!"))
		return
	user.visible_message(span_warning("[user] grows into an abomination and lets out an awful scream!"), \
						span_userdanger("We cast off our petty shell and enter our true form!"))
	new /mob/living/simple_animal/hostile/thingling(user.loc, user)
	return TRUE

/mob/living/simple_animal/hostile/thingling
	name = "thingling"
	icon = 'icons/mob/changeling.dmi'
	icon_state = "horror"
	icon_living = "horror"
	base_icon_state = "horror"
	verb_say = "says with one of it's faces"
	verb_exclaim = "yells with one of it's faces"
	verb_yell = "screams with one of it's faces"
	verb_ask = "inquisitively says with one of it's faces"
	verb_sing = "ear piercingly screeches with one of it's faces"
	del_on_death = TRUE
	loot = list(/obj/effect/gibspawner/human)
	gender = NEUTER
	combat_mode = TRUE
	minbodytemp = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 30
	see_in_dark = 8
	sight = SEE_MOBS
	maxHealth = 200
	health = 200
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_verb_simple = "tear into"
	attack_verb_continuous = "tears into"
	attack_sound = 'sound/effects/splat.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	sharpness = SHARP_POINTY
	wound_bonus = -30
	ranged = TRUE
	ranged_cooldown_time = 3 SECONDS
	projectiletype = /obj/projectile/tentacle
	projectilesound = 'sound/effects/splat.ogg'
	deathsound = 'sound/hallucinations/wail.ogg'
	deathmessage = "wails as it implodes!"
	var/mob/living/stored_ling
	var/max_time = 1 MINUTES
	var/time_left = 1 MINUTES

/mob/living/simple_animal/hostile/thingling/get_status_tab_items()
	. = ..()
	. += "Time Left: [round(time_left, 10) * 0.1]/[max_time * 0.1]"

/mob/living/simple_animal/hostile/thingling/Initialize(mapload, mob/living/ling)
	. = ..()
	icon_state = "[base_icon_state][rand(1,6)]"
	if(ling)
		store_ling(ling)

/mob/living/simple_animal/hostile/thingling/proc/store_ling(mob/living/ling)
	stored_ling = ling
	ling.mind.transfer_to(src)
	ling.moveToNullspace()
	to_chat(src, span_notice("<b>You transformed into your primal form! You will revert back in a minute.</b>"))
	to_chat(src, span_notice("Left-click to attack. Right-click to assimilate. Ranged attacks will throw a tentacle."))
	new /obj/effect/gibspawner/human(loc)

/mob/living/simple_animal/hostile/thingling/proc/return_ling()
	to_chat(src, span_notice("<b>You return back into human form, your wounds carried with it.</b>"))
	stored_ling.forceMove(loc)
	mind.transfer_to(stored_ling)
	var/datum/antagonist/changeling/changeling = stored_ling.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chem_charges = 0
	stored_ling.Paralyze(3 SECONDS)
	stored_ling.adjustBruteLoss((maxHealth - health) * 0.5)
	stored_ling = null
	new /obj/effect/gibspawner/human(loc)
	qdel(src)

/mob/living/simple_animal/hostile/thingling/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && isliving(attack_target))
		infect(attack_target)
		return
	return ..()

/mob/living/simple_animal/hostile/thingling/Life(delta_time, times_fired)
	. = ..()
	if(!stored_ling)
		return
	time_left -= 1 SECONDS * delta_time
	if(time_left <= 0)
		return_ling()

/mob/living/simple_animal/hostile/thingling/proc/infect(mob/living/target)
	if(!target.mind)
		to_chat(src, span_warning("They have no mind!"))
		return
	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(src, span_warning("They are one of us!"))
		return
	visible_message(span_warning("[src] starts assimilating [target]..."), \
						span_danger("We begin to assimilate [target]..."))
	if(!do_after(src, 10 SECONDS, target))
		return
	if(target.mind && mind)
		target.mind.add_antag_datum(/datum/antagonist/changeling)
		target.fully_heal(TRUE)
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
	to_chat(src, span_notice("We assimilated [target]."))

/mob/living/simple_animal/hostile/thingling/handle_fire(delta_time, times_fired)
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		set_fire_stacks(min(0, fire_stacks + (0.5 * delta_time))) //So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return TRUE //the mob is no longer on fire, no need to do the rest.
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.5 * delta_time) //the fire is slowly consumed
	else
		extinguish_mob()
		return TRUE //mob was put out, on_fire = FALSE via extinguish_mob(), no need to update everything down the chain.
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(!G.gases[/datum/gas/oxygen] || G.gases[/datum/gas/oxygen][MOLES] < 1)
		extinguish_mob() //If there's no oxygen in the tile we're on, put out the fire
		return TRUE
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 25 * delta_time, TRUE)
	adjust_bodytemperature(BODYTEMP_HEATING_MAX * 0.5 * delta_time) //If you're on fire, you heat up!
	adjustFireLoss(10)
	playsound(src, 'sound/hallucinations/wail.ogg', 50, TRUE)
	manual_emote("unleashes an inhuman scream!")
	set_confusion(max(10, get_confusion()))

/mob/living/simple_animal/hostile/thingling/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = TRUE
		visible_message(span_warning("[src] catches fire!"), \
						span_userdanger("You're set on fire!"))
		new/obj/effect/dummy/lighting_obj/moblight/fire(src)
		throw_alert("fire", /atom/movable/screen/alert/fire)
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED,src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/thingling/extinguish_mob()
	if(!on_fire)
		return
	on_fire = FALSE
	fire_stacks = 0 //If it is not called from set_fire_stacks()
	for(var/obj/effect/dummy/lighting_obj/moblight/fire/F in src)
		qdel(F)
	clear_alert("fire")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "on_fire")
	SEND_SIGNAL(src, COMSIG_LIVING_EXTINGUISHED, src)
	update_fire()

/mob/living/simple_animal/hostile/thingling/update_fire()
	var/mutable_appearance/fire_overlay = mutable_appearance('icons/mob/onfire.dmi', "Generic_mob_burning")
	if(on_fire)
		add_overlay(fire_overlay)
	else
		cut_overlay(fire_overlay)

/mob/living/simple_animal/hostile/thingling/Destroy()
	stored_ling = null
	return ..()

/mob/living/simple_animal/hostile/thingling/Moved()
	. = ..()
	if(!loc)
		return
	new /obj/effect/decal/cleanable/blood/bubblegum(loc)

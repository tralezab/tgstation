//hi, jerry! feel free to change around whatever you're confident with to better suit the story.
// this essentially is dealing 20 damage per strike with some fluff:
// disarming "charges up", increasing the power of the next strike by 20. so it's like you're attacking but you haven't dealt the damage yet.
// harming "unwinds" the target, dealing 20 damage + however many times you've disarmed
// after becoming an expert, you can grab a target (or yourself) after winding 5 times on an enemy to heal 20 damage
// master attacks twice as fast, winding up twice as fast so essentially dealing double damage

#define UNWIND_LEVEL_NOVICE 1
#define UNWIND_LEVEL_ACCOMPLISHED 2
#define UNWIND_LEVEL_EXPERT 3
#define UNWIND_LEVEL_MASTER 4

/datum/martial_art/unwinding
	name = "Unwinding"
	id = MARTIALART_UNWINDING
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/unwinding_help
	var/wind_power = 1
	var/level = UNWIND_LEVEL_NOVICE

/datum/martial_art/unwinding/proc/level_up(mob/user)
	level++
	switch(level)
		if(UNWIND_LEVEL_ACCOMPLISHED)
			to_chat(user, "<span class='nicegreen'>You have become accomplished in your skill with unwinding. You must find more to regain your knowledge.</span>")
		if(UNWIND_LEVEL_EXPERT)
			to_chat(user, "<span class='nicegreen'>You have become an expert in unwinding, and along with it the ability to <b>Wind others back together with a charged grab.</b></span>")
		if(UNWIND_LEVEL_MASTER)
			to_chat(user, "<span class='nicegreen'>You have become a master at unwinding, making all your moves twice as fast!</span>")
			var/mob/living/carbon/human/master = user
			master.next_move_modifier = 0.5


/datum/martial_art/unwinding/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(level < UNWIND_LEVEL_EXPERT)
		return FALSE
	switch(wind_power)
		if(1)
			return FALSE //not winding up, just let them grab stuff
		if(2 to 4)
			var/targ = A == D ? "yourself" : D
			to_chat(A, "<span class='warning'>You have not charged up enough to wind [targ] back together!")
			return TRUE
	log_combat(A, D, "grabbed (Unwinding)")
	return ..()

/datum/martial_art/unwinding/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/unwind_damage = 20 * wind_power

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	D.visible_message("<span class='danger'>[A] unwinds [D]!</span>", \
					"<span class='userdanger'>[A] unwinds you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You unwind [D]!</span>")
	D.apply_damage(unwind_damage, BRUTE, affecting, wound_bonus = CANT_WOUND)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(A, D, "punched (Unwinding)")
	wind_power = initial(wind_power)
	return TRUE

/datum/martial_art/unwinding/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(istype(A, /mob/living/simple_animal))//simple only for charging up healing
		return FALSE
	wind_power += 1
	to_chat(A, "<span class='notice'>You charge your power level...</span>")
	to_chat(A, "<span class='notice'>Your next attack will deal <b>[wind_power * 20]</b> damage!</span>")
	log_combat(A, D, "charged wind power on (Unwinding)")
	return TRUE

/mob/living/carbon/human/proc/unwinding_help()
	set name = "Recall Teachings"
	set desc = "Remember the perfection of the original unwind event."
	set category = "Unwinding"

	to_chat(usr, "<b><i>You recall the initial unwinding...</i></b>")

	to_chat(usr, "<span class='notice'>In an age long ago... there was one who learned and mastered the power of winding...</span>")
	to_chat(usr, "<span class='notice'>He could bind things back into what they were...</span><span class='warning'><b>or unravel things into what they are.</b></span>")
	to_chat(usr, "<span class='notice'>The greedy hunted and cornered him in search of his secrets. In the last moments of his life, he <b>charged up</b> one last strike, <b>magnifying it beyond belief!</b></span>")
	to_chat(usr, "<span class='notice'>The resulting unwind spread beyond himself, peeling away his aggressors into bloody rinds. The walls and ground warped and twined in odd and unnatural directions.</span>")
	to_chat(usr, "<span class='notice'>He was finally uncomplete. His parts were spread beyond the planet, into the stars and throughout the universe.</span>")

/obj/item/book/granter/martial/unwinding
	martial = /datum/martial_art/unwinding
	name = "frayed scroll"
	martialname = "unwinding"
	desc = "A scroll, torn in various unnatural ways. From what you can manage to put together, it depicts some kind of martial art"
	greet = "<span class='boldannounce'>You've begun to understand the power of unravelling. Recall teachings for a hint on how to harness it.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("Charge yourself up...", "Percise strikes to spill themselves on the ground...", "They will feel their world unravel with each strike...", "I must pierce armor for maximum damage...", "Attack strong, over attack fast. Attack where, over attack strong...", "All who travel the path of unwinding must be ready to rejoin the first wind.", "There is a way to reverse the unwinding...")

/obj/item/book/granter/martial/unwinding/already_known(mob/user)
	if(!martial)
		return TRUE
	//you can learn more from more scrolls
	return FALSE

/obj/item/book/granter/martial/unwinding/on_reading_finished(mob/user)
	var/datum/martial_art/unwinding/levelupart = level_not_learn(user)
	if(levelupart)
		levelupart.level_up(user)
	else
		var/datum/martial_art/MA = new martial
		MA.teach(user)
		to_chat(user, "[greet]")
		user.log_message("learned the martial art [martialname] ([MA])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/martial/unwinding/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		visible_message("<span class='warning'>[src] further unravels into scraps!")
		qdel(src)

/obj/item/book/granter/martial/unwinding/proc/level_not_learn(mob/user)
	var/datum/martial_art/MA = martial
	var/datum/martial_art/unwinding/current_art = user.mind.has_martialart(initial(MA.id))
	if(current_art)
		return current_art //has the martial art, so level it up
	return FALSE //needs to learn it initially

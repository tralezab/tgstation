/obj/item/hand/haemomanic
	name = "haemomanic claw"
	desc = span_danger("SATE THE BLOODLUST SATE THE BLOODLUST SATE THE BLOODLUST!")
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	icon_left = "bloodhand_left"
	icon_right = "bloodhand_right"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21
	sharpness = SHARP_EDGED
	wound_bonus = 30
	bare_wound_bonus = 15
	damtype = BRUTE

/obj/item/hand/haemomanic/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !ishuman(user))
		return
	var/mob/living/carbon/human/addict = user
	var/obj/item/hand/haemomanic/other_claw = addict.get_inactive_held_item()
	if(other_claw == src) //already did an extra attack with this offhand weapon
		return
	addtimer(CALLBACK(other_claw, .proc/attempt_second_swipe), 3)

/obj/item/hand/haemomanic/proc/attempt_second_swipe(var/mob/living/carbon/human/addict, atom/target)
	if(!user || !target || get_dist(user, target) > 1)
	melee_attack_chain(addict, target)

/obj/item/hand/haemomanic/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag)
		return //we just did a normal swipe
	if(prob(25))
		user.say("SATE THE BLOODLUST!")
	else
		user.emote("scream")
	if(!isclosedturf(target))
		user.throw_at(target, 2, 4)

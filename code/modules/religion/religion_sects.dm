/datum/religion_sect
	var/name = "Religious Sect Base Type" // Name of your sect, duh!
	var/desc = "Oh My! What Do We Have Here?!!?!?!?" // brief description of the sect. Keep it small!
	var/convert_opener //opening message when someone gets converted
	var/alignment = ALIGNMENT_GOOD
	var/starter = TRUE // Does this require something to unlock?
	var/favor = 0 //MANA!
	var/default_item_favor = 5
	var/list/desired_items //turned to typecache
	var/list/desired_items_typecache

/datum/religion_sect/New()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	on_select()

/// Activates once selected
/datum/religion_sect/proc/on_select()
/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span")
/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering.
/datum/religion_sect/proc/can_sacrifice(obj/item/I, mob/living/L)
	. = TRUE
	if(!is_type_in_typecache(I,desired_items_typecache))
		return FALSE
/// Activates when the sect sacrifices an item. Can provide additional benefits to the sacrificer, which can also be dependent on their holy role! If the item is suppose to be eaten, here is where to do it. NOTE INHER WILL NOT DELETE ITEM FOR YOU!!!!
/datum/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/L)
	return adjust_favor(default_item_favor,L)
/// Adjust Favor by a certain amount. Can provide optional features based on a user.
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/L)
	favor += amount
	return TRUE
/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/L)
	favor = amount
	return TRUE
/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user)
/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/H = L
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>[GLOB.deity] refuses to heal this metallic taint!</span>")
			return TRUE

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [GLOB.deity]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
		playsound(user, "punch", 25, TRUE, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/puritanism
	name = "Puritanism"
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"

/// SECT_TECH
/datum/religion_sect/technology
	name = "Technophile"
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte.<br>Bibles now recharge cyborgs and heal robotic limbs if targeted, but does not heal organic ones."
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/cell, /obj/item/research_notes)

/datum/religion_sect/technology/sect_bless(mob/living/L, mob/living/user)
	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		R.cell?.charge += 50
		R.visible_message("<span class='notice'>[user] charges [R] with the power of [GLOB.deity]!</span>")
		to_chat(R, "<span class='boldnotice'>You are charged by the power of [GLOB.deity]!</span>")
		SEND_SIGNAL(R, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return TRUE
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	var/obj/item/bodypart/BP = H.get_bodypart(user.zone_selected)
	if(BP.status != BODYPART_ROBOTIC)
		to_chat(user, "<span class='warning'>[GLOB.deity] scoffs at the idea of healing such fleshy matter!</span>")
		return TRUE
	if(BP.heal_damage(5,5,null,BODYPART_ROBOTIC))
		H.update_damage_overlays()
	H.visible_message("<span class='notice'>[user] heals [H] with the power of [GLOB.deity]!</span>")
	to_chat(H, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
	playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/technology/on_sacrifice(obj/item/I, mob/living/L)
	. = ..()
	if(..())
		qdel(I)

//Fallen Sect

/datum/religion_sect/fallen
	name = "Sleeping Gods"
	desc = "A sect that has fallen into dormancy."
	convert_opener = "The gods have been silent. Where have you gone?!<br>You have no powers... But, in the darkest hour you will rise to save them all."
	alignment = ALIGNMENT_GOOD
	var/chaos_level = 0 //gains one point for each level of security alert active

/datum/religion_sect/fallen/on_select()
	RegisterSignal(SSdcs, COMSIG_GLOB_SECURITYLEVEL_CHANGED, .proc/alert_change)

/datum/religion_sect/fallen/proc/alert_change(new_level)
	var/increase = chaos_level < new_level ? TRUE : FALSE
	var/godmessage = ""
	var/wings = FALSE
	chaos_level = new_level
	switch(chaos_level)
		if(SEC_LEVEL_GREEN)
				godmessage = "[GLOB.deity] is silent, any murmurs of his power have vanished."
		if(SEC_LEVEL_BLUE)
			if(increase)
				godmessage = "You feel a faint buzz of holy energies for just a moment."
			else
				godmessage = "You feel your powers fade as [GLOB.deity] returns to it's slumber..."
		if(SEC_LEVEL_RED)
			if(increase)
				godmessage = "You feel your powers surge as [GLOB.deity] awakens!"
			else
				godmessage = "[GLOB.deity] is satisfied with the stop of the delta event. The wings are your reward."
		if(SEC_LEVEL_DELTA)
				godmessage = "You have been given the full power of [GLOB.deity] to save the station from crisis. [GLOB.deity] watches over you."
				wings = TRUE
	if(godmessage)
		for(var/i in GLOB.player_list)
			if(!isliving(i))
				continue
			var/mob/living/am_i_holy_living = i
			if(!am_i_holy_living.mind?.holy_role)
				continue
			to_chat(user, "<span class='warning'>[godmessage]</span>")
			if(wings && ishuman(am_i_holy_living))
				var/mob/living/carbon/human/holyhumie = am_i_holy_living
				holyhumie.dna.species.GiveSpeciesFlight()

/datum/religion_sect/fallen/sect_bless(mob/living/L, mob/living/user)
	switch(chaos_level)
		if(SEC_LEVEL_GREEN to SEC_LEVEL_BLUE)
			to_chat(user, "<span class='warning'>[GLOB.deity]... where are you?!</span>")
			SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "forsaken", /datum/mood_event/forsaken)
			. = FALSE
		if(2)
			. =
		if(3)
			if(!ishuman(L))
				return ..()
			var/mob/living/carbon/human/H = L
			for(var/X in H.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.status == BODYPART_ROBOTIC)
					to_chat(user, "<span class='warning'>[GLOB.deity] refuses to heal this metallic taint!</span>")
					. = TRUE

			var/heal_amt = 20
			var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

			if(hurt_limbs.len)
				for(var/X in hurt_limbs)
					var/obj/item/bodypart/affecting = X
					if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
						H.update_damage_overlays()
				H.visible_message("<span class='notice'>[user] super heals [H] with the power of [GLOB.deity]!</span>")
				to_chat(H, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be super healed!</span>")
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing/super)
				for(var/i in 1 to 3)
					playsound(user, "punch", 25, TRUE, -1)
					sleep(1)
			return TRUE

/datum/action/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "We will steal the identity of the victim. Requires us to strangle them. In this process their identity is ruined."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1

/datum/action/changeling/absorb_dna/can_sting(mob/living/carbon/user)
	if(!..())
		return

	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.isabsorbing)
		to_chat(user, "<span class='warning'>We are already absorbing!</span>")
		return

	if(!user.pulling || !iscarbon(user.pulling))
		to_chat(user, "<span class='warning'>We must be grabbing a creature to absorb them!</span>")
		return
	if(user.grab_state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature!</span>")
		return

	var/mob/living/carbon/target = user.pulling
	return changeling.can_absorb_dna(target)



/datum/action/changeling/absorb_dna/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/mob/living/carbon/human/target = user.pulling
	changeling.isabsorbing = 1
	for(var/i in 1 to 3)
		switch(i)
			if(1)
				user.visible_message("<span class='warning'>[user] begins to shake violently.</span>", "<span class='notice'>This creature is compatible. We must not be interrupted.</span>")
				user.Shake(5,5, 150)
			if(2)
				user.visible_message("<span class='warning'>[user] unhinges their jaw!</span>", "<span class='notice'>We prepare to ruin them.</span>")
			if(3)
				user.visible_message("<span class='danger'>[user] vomits a red goop on [target], their skin turning a sickly grey!</span>", "<span class='notice'>[target] has been ruined. Let us take their identity.</span>")
				to_chat(target, "<span class='userdanger'>You feel your skin burn and your insides melt!</span>")
				to_chat(target, "<span class='warning'>You can feel your mind flickering on and off...</span>")
				target.set_species(/datum/species/faceless)
				target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 180, 180)//really more like setting the damage
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[i]"))
		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our absorption of [target] has been interrupted!</span>")
			if(i == 3)
				to_chat(user, "<span class='danger'>...And after we ruin them but before we could steal their DNA! We've lost the chance to absorb them.</span>")
			changeling.isabsorbing = 0
			return

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "4"))
	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>", "<span class='notice'>We have absorbed [target].</span>")
	to_chat(target, "<span class='userdanger'>You are absorbed by the changeling!</span>")

	if(!changeling.has_dna(target.dna))
		changeling.add_new_profile(target)
		changeling.trueabsorbs++

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.set_nutrition(min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	// Absorb a lizard, speak Draconic.
	owner.copy_languages(target, LANGUAGE_ABSORB)

	if(target.mind && user.mind)//if the victim and user have minds
		var/datum/mind/suckedbrain = target.mind
		user.mind.memory += "<BR><b>We've absorbed [target]'s memories into our own...</b><BR>[suckedbrain.memory]<BR>"
		for(var/A in suckedbrain.antag_datums)
			var/datum/antagonist/antag_types = A
			var/list/all_objectives = antag_types.objectives.Copy()
			if(antag_types.antag_memory)
				user.mind.memory += "[antag_types.antag_memory]<BR>"
			if(LAZYLEN(all_objectives))
				user.mind.memory += "<B>Objectives:</B>"
				var/obj_count = 1
				for(var/O in all_objectives)
					var/datum/objective/objective = O
					user.mind.memory += "<br><B>Objective #[obj_count++]</B>: [objective.explanation_text]"
					var/list/datum/mind/other_owners = objective.get_owners() - suckedbrain
					if(other_owners.len)
						user.mind.memory += "<ul>"
						for(var/mind in other_owners)
							var/datum/mind/M = mind
							user.mind.memory += "<li>Conspirator: [M.name]</li>"
						user.mind.memory += "</ul>"
		user.mind.memory += "<b>That's all [target] had.</b><BR>"
		user.memory() //I can read your mind, kekeke. Output all their notes.

		//Some of target's recent speech, so the changeling can attempt to imitate them better.
		//Recent as opposed to all because rounds tend to have a LOT of text.

		var/list/recent_speech = list()
		var/list/say_log = list()
		var/log_source = target.logging
		for(var/log_type in log_source)
			var/nlog_type = text2num(log_type)
			if(nlog_type & LOG_SAY)
				var/list/reversed = log_source[log_type]
				if(islist(reversed))
					say_log = reverseRange(reversed.Copy())
					break

		if(LAZYLEN(say_log) > LING_ABSORB_RECENT_SPEECH)
			recent_speech = say_log.Copy(say_log.len-LING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
		else
			for(var/spoken_memory in say_log)
				if(recent_speech.len >= LING_ABSORB_RECENT_SPEECH)
					break
				recent_speech[spoken_memory] = say_log[spoken_memory]

		if(recent_speech.len)
			changeling.antag_memory += "<B>Some of [target]'s speech patterns, we should study these to better impersonate [target.p_them()]!</B><br>"
			to_chat(user, "<span class='boldnotice'>Some of [target]'s speech patterns, we should study these to better impersonate [target.p_them()]!</span>")
			for(var/spoken_memory in recent_speech)
				changeling.antag_memory += "\"[recent_speech[spoken_memory]]\"<br>"
				to_chat(user, "<span class='notice'>\"[recent_speech[spoken_memory]]\"</span>")
			changeling.antag_memory += "<B>We have no more knowledge of [target]'s speech patterns.</B><br>"
			to_chat(user, "<span class='boldnotice'>We have no more knowledge of [target]'s speech patterns.</span>")


		var/datum/antagonist/changeling/target_ling = target.mind.has_antag_datum(/datum/antagonist/changeling)
		if(target_ling)//If the target was a changeling, suck out their extra juice and objective points!
			to_chat(user, "<span class='boldnotice'>[target] was one of us. We have absorbed their power.</span>")
			target_ling.remove_changeling_powers()
			changeling.geneticpoints += round(target_ling.geneticpoints/2)
			changeling.total_geneticspoints = changeling.geneticpoints //updates the total sum of genetic points when you absorb another ling
			target_ling.geneticpoints = 0
			target_ling.canrespec = 0
			changeling.chem_storage += round(target_ling.chem_storage/2)
			changeling.total_chem_storage = changeling.chem_storage //updates the total sum of chemicals stored for when you absorb another ling
			changeling.chem_charges += min(target_ling.chem_charges, changeling.chem_storage)
			target_ling.chem_charges = 0
			target_ling.chem_storage = 0
			changeling.absorbedcount += (target_ling.absorbedcount)
			target_ling.stored_profiles.len = 1
			target_ling.absorbedcount = 0
			target_ling.was_absorbed = TRUE


	changeling.chem_charges=min(changeling.chem_charges+10, changeling.chem_storage)

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	target.death(0)
	target.Drain()
	return TRUE

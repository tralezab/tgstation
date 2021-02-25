/datum/action/changeling/sting//parent path, not meant for users afaik
	name = "Tiny Prick"
	desc = "Stabby stabby"

/datum/action/changeling/sting/Trigger()
	var/mob/user = owner
	if(!user || !user.mind)
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling)
		return
	if(!changeling.chosen_sting)
		set_sting(user)
	else
		unset_sting(user)
	return

/datum/action/changeling/sting/proc/set_sting(mob/user)
	to_chat(user, "<span class='notice'>We prepare our sting. Alt+click or click the middle mouse button on a target to sting them.</span>")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chosen_sting = src

	user.hud_used.lingstingdisplay.icon_state = button_icon_state
	user.hud_used.lingstingdisplay.invisibility = 0

/datum/action/changeling/sting/proc/unset_sting(mob/user)
	to_chat(user, "<span class='warning'>We retract our sting, we can't sting anyone for now.</span>")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chosen_sting = null

	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/mob/living/carbon/proc/unset_sting()
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling?.chosen_sting)
			changeling.chosen_sting.unset_sting(src)

/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling.chosen_sting)
		to_chat(user, "We haven't prepared our sting yet!")
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(!AStar(user, target.loc, /turf/proc/Distance, changeling.sting_range, simulated_only = FALSE))
		return
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/changeling))
		sting_feedback(user, target)
		changeling.chem_charges -= chemical_cost
	return 1

/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	to_chat(user, "<span class='notice'>We stealthily sting [target.name].</span>")
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(target, "<span class='warning'>You feel a tiny prick.</span>")
	return 1


/datum/action/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform. Costs 50 chemicals."
	helptext = "The victim will transform much like a changeling would. Does not provide a warning to others. Mutations will not be transferred, and monkeys will become human."
	button_icon_state = "sting_transform"
	chemical_cost = 50
	var/datum/changelingprofile/selected_dna = null

/datum/action/changeling/sting/transformation/Trigger()
	var/mob/user = usr
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.chosen_sting)
		unset_sting(user)
		return
	selected_dna = changeling.select_dna()
	if(!selected_dna)
		return
	if(NOTRANSSTING in selected_dna.dna.species.species_traits)
		to_chat(user, "<span class='notice'>That DNA is not compatible with changeling retrovirus!</span>")
		return
	..()

/datum/action/changeling/sting/transformation/can_sting(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return
	if((HAS_TRAIT(target, TRAIT_HUSK)) || !iscarbon(target) || (NOTRANSSTING in target.dna.species.species_traits))
		to_chat(user, "<span class='warning'>Our sting appears ineffective against its DNA.</span>")
		return FALSE
	return TRUE

/datum/action/changeling/sting/transformation/sting_action(mob/user, mob/target)
	log_combat(user, target, "stung", "transformation sting", " new identity is '[selected_dna.dna.real_name]'")
	var/datum/dna/NewDNA = selected_dna.dna

	var/mob/living/carbon/C = target
	. = TRUE
	if(istype(C))
		C.real_name = NewDNA.real_name
		NewDNA.transfer_identity(C)
		C.updateappearance(mutcolor_update=1)

/datum/action/changeling/sting/lsd
	name = "Hallucination Sting"
	desc = "We cause mass terror to our victim."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	button_icon_state = "sting_lsd"
	chemical_cost = 10

/datum/action/changeling/sting/lsd/sting_action(mob/user, mob/living/carbon/target)
	log_combat(user, target, "stung", "LSD sting")
	addtimer(CALLBACK(src, .proc/hallucination_time, target), rand(300,600))
	return TRUE

/datum/action/changeling/sting/lsd/proc/hallucination_time(mob/living/carbon/target)
	if(target)
		target.hallucination = max(90, target.hallucination)

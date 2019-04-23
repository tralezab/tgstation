
/*
Servant of Evil!
This dark priest uses metal, meat, sinew and bone to create horrible curses on the station! They must complete dark objectives, sacrificing members of the station (or even themselves!)
As they are a supporting antagonist that tries to sow chaos to help other evils, They only show up in their gamemode (traitors + servants) and as a rare event.
*/

/datum/antagonist/evil_servant
	name = "Servant of Evil"
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	job_rank = ROLE_ALIEN
	show_in_antagpanel = TRUE
	var/datum/brain_trauma/special/virago/virago_trauma

	var/list/totems_active = list()

/datum/antagonist/evil_servant/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "[roundend_category] includes a brain trauma, so they need to at least be a carbon!")
		return
	if(!C.getorgan(/obj/item/organ/brain)) // If only I had a brain
		to_chat(admin, "[roundend_category] includes a brain trauma, so they need to HAVE A BRAIN.")
		return
	..()

/datum/antagonist/virago/on_gain()
	var/escape = forge_objectives()
	if(owner && owner.current)
		if(!silent)
			greet(escape)
		apply_innate_effects()
		give_antag_moodies()
		if(is_banned(owner.current) && replace_banned)
			replace_banned_player()

/datum/antagonist/virago/apply_innate_effects()
	var/mob/living/carbon/C = owner.current
	virago_trauma = C.gain_trauma(/datum/brain_trauma/special/virago)
	return

/datum/antagonist/virago/remove_innate_effects()
	QDEL_NULL(virago_trauma)
	return

/datum/antagonist/virago/greet(escape)
	to_chat(owner.current, "<span class='userdanger'>You are the Virago!</span>")
	to_chat(owner.current, "<span class='warning'>Something feels off. Your head pounds and hurts, and something is certainly crawling beneath your skin.</span>")
	to_chat(owner.current, "<span class='red'>But none of that matters now. You feel a strong rapport for the darkness of the universe. Time to get to work.</span>")
	to_chat(owner.current, "<b>Make sure to work with other evildoers to get more bodyparts and organs for your rituals. You are mainly a support role and there is nothing to defend yourself!</b>")
	to_chat(owner.current, "<b>Raise some hell with your newfound dark powers and [escape ? "evade those who wish to put an end to your everlasting apex!" : "sacrifice yourself to the darkness that wills, in a beautiful cacophony of death!"]</b>")
	owner.announce_objectives()

/datum/antagonist/virago/farewell()
	to_chat(owner.current, "<span class='userdanger'>A piercing white light floods your mind, and the darkness is banished... you are no longer a Virago!</span>")

/datum/antagonist/virago/proc/handle_ritual(chant)
	if(locate(chant) in completedrituals)
		return //already done.
	completedrituals += chant

/datum/antagonist/virago/proc/forge_objectives() //always gets ritualmaster as an objective, to encourage doing things. the rest is random.
	return
/*
	var/datum/objective/ritualmaster/rituals = new
	rituals.owner = owner
	objectives += rituals
	switch(rand(1, 1))//come back to this
		if(1)
			var/datum/objective/sac_pact/sac = new
			sac.owner = owner
			objectives += sac
		if(3)
			var/datum/objective/totemic/totem = new
			totem.owner = owner
			objectives += totem
	if(rand())
		. = FALSE
		var/datum/objective/suicide_cult/suicide = new
		suicide.owner = owner
		objectives += suicide
	else
		. = TRUE
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		objectives += escape_objective

/datum/objective/ritualmaster
	explanation_text = "Complete 10 unique rituals."

/datum/objective/ritualmaster/check_completion()
	var/count = 0
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!M)
			continue
		var/datum/antagonist/virago/virago = M.has_antag_datum(/datum/antagonist/virago)
		if(!virago || !virago.virago_trauma)
			continue
		for(var/datum/curse/curses in virago.virago_trauma.learned_rituals)
			if(curses.completed)
				count++
	return count >= 10

/datum/objective/sac_pact
	var/target_role_type=0
	martyr_compatible = 1

/datum/objective/sac_pact/find_target_by_role(role, role_type=0, invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/*
/datum/objective/sac_pact/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!M)
			continue
		var/datum/antagonist/virago/virago = M.has_antag_datum(/datum/antagonist/virago)
		if(!virago || !virago.sac_pact_victims)
			continue
		if(locate(target) in virago.sac_pact_victims)
			return TRUE
	return FALSE
/datum/objective/sac_pact/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Use [target.name], the [!target_role_type ? target.assigned_role : target.special_role] in a ritual."
	else
		explanation_text = "Free Objective"

/datum/objective/suicide_cult
	explanation_text = "Die by your own rituals."
/*
/datum/objective/suicide_cult/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!M)
			continue
		var/datum/antagonist/virago/virago = M.has_antag_datum(/datum/antagonist/virago)
		if(!virago || !virago.sac_pact_victims)
			continue
		if(locate(M.current) in virago.sac_pact_victims)
			return TRUE
	return FALSE

/datum/objective/totemic
	explanation_text = "Have 5 totems active by the end."

/datum/objective/totemic/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!M)
			continue
		var/datum/antagonist/virago/virago = M.has_antag_datum(/datum/antagonist/virago)
		if(!virago || !virago.totems_active)
			continue
		if(virago.totems_active.len >= 5)
			return TRUE
	return FALSE
*/

/datum/antagonist/obsessed/roundend_report_header()
	return 	"<span class='header'>There was a maintenance witch!</span><br>"

/datum/antagonist/obsessed/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	var/count = 0
	if(virago_trauma)
		for(var/curse/ritual in learned_rituals)
			count += ritual.complete
			report += "<span class='greentext'>The [name] finished [count] rituals!</span>"
		else
			report += "<span class='redtext'>The [name] did not finish a single ritual!</span>"
	else
		report += "<span class='redtext'>Make a github report, the antagonist finished the round broken.</span>"

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

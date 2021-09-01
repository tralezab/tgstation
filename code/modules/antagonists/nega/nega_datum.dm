/**
 * Summoned by wizards, or rarely, events. A negative version of someone that has the objectives to kill and become them.
 * Their existence in this dimension is unnatural, and they will slowly become more obviously a negative version until they kill their target (themselves from this dimension)
 * There can only be one!
 */
/datum/antagonist/nega
	name = "Alternate Universe Nega-Doppelganger"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	job_rank = ROLE_OBSESSED
	antag_hud_type = ANTAG_HUD_NEGA
	antag_hud_name = "nega"
	show_name_in_check_antagonists = TRUE
	roundend_category = "nega"
	suicide_cry = "TWO OF US CANNOT PERSIST!!"
	///which debuffs are being applied to the doppelganger
	var/level = MINOR_CORRECTION
	///list of applied universal corrections.
	var/list/universal_corrections_applied = list()
	///our target.
	var/mob/living/current_universe_counterpart
	///timer reference for when the game needs to apply a correction
	var/correction_timer

/datum/antagonist/nega/apply_innate_effects(mob/living/mob_override)
	. = ..()
	RegisterSignal(owner.current, COMSIG_PARENT_QDELETING, .proc/nega_doppel_destroyed)
	RegisterSignal(owner.current, COMSIG_LIVING_DEATH, .proc/nega_doppel_killed)
	correction_timer = addtimer(CALLBACK(src, .proc/universally_correct), CORRECTION_TIMER_LENGTH)

/datum/antagonist/nega/Destroy()
	deltimer(correction_timer)
	QDEL_LIST(universal_corrections_applied)
	. = ..()

/datum/antagonist/nega/proc/nega_doppel_destroyed(datum/source, force)
	SIGNAL_HANDLER

	qdel(src)

/datum/antagonist/nega/proc/nega_doppel_killed(datum/source, gibbed)
	SIGNAL_HANDLER

	owner.current.dust()

/datum/antagonist/nega/proc/universally_correct()
	//get a list of possible corrections for our level
	var/list/possible_corrections
	switch(level)
		if(MINOR_CORRECTION)
			possible_corrections = subtypesof(/datum/universal_correction/minor)
		if(INTERMEDIATE_CORRECTION)
			possible_corrections = subtypesof(/datum/universal_correction/intermediate)
		if(MAJOR_CORRECTION)
			possible_corrections = subtypesof(/datum/universal_correction/major)
	//remove corrections we have already have
	var/list/applied_types = list()
	for(var/datum/universal_correction/applied_correction as anything in universal_corrections_applied)
		if(applied_correction.level == level)
			applied_types += applied_correction.type
	possible_corrections.Remove(applied_types)
	//pick and apply correction
	var/picked_type = pick_n_take(possible_corrections)
	var/datum/universal_correction/new_correction = new picked_type(owner.current)
	universal_corrections_applied += new_correction
	//move level up if no more possible corrections at this level
	if(!possible_corrections.len)
		level++

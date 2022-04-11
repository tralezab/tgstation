///Bloody Lust Addict. Switches between longer intervals of pacifism, and short bursts of high velocity senseless murder. The more times they transform, the more deformed they get.
/datum/antagonist/bloody_lust
	name = "\improper Bloody Lust Addict"
	job_rank = ROLE_THIEF
	roundend_category = "bloody lust addicts"
	antagpanel_category = "Bloody Lust Addict"
	show_in_antagpanel = TRUE
	suicide_cry = "FOR THE BEAST WITHIN!!"
	preview_outfit = /datum/outfit/bloody_lust
	antag_hud_name = "thief"
	ui_name = "AntagInfoThief"
	var/transformations = 0
	var/next_transformation_timer
	var/transformation_state = BLOODY_LUST_INACTIVE

/datum/antagonist/bloody_lust/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//still start the timer for the next one
	apply_phase_effects(mob_override, silent = TRUE)
	mob_override

/datum/antagonist/bloody_lust/proc/apply_phase_effects(mob/living/carbon/human/addict, silent = FALSE)
	var/next_phase_in
	var/phase_message = "Something went wrong with the antag datum!"
	switch(transformation_state)
		if(BLOODY_LUST_INACTIVE)
			next_phase_in = 8 MINUTES
			phase_message = span_boldnotice("The bloody lust subsides... for now. Your genes have been left permanently modified from the transformation, and you should do your best to hide your new deformities.")
			ADD_TRAIT(addict, TRAIT_PACIFISM, BLOODY_LUST_ADDICT_TRAIT)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
		if(BLOODY_LUST_SOON)
			next_phase_in = 3.5 MINUTES
			phase_message = span_danger("The bloody lust inside you grows. Soon, you'll go into another bloody rampage. You need to prepare to either sate the beast, or hide until it subsides.")
		if(BLOODY_LUST_IMMINENT)
			next_phase_in = 30 SECONDS
			phase_message = span_userdanger("The bloody lust inside you burns your veins, and clouds your judgement! You feel your genetic composition becoming unstable! You're going to transform!")
			REMOVE_TRAIT(addict, TRAIT_PACIFISM, BLOODY_LUST_ADDICT_TRAIT)
			var/sound/fastbeat = sound('sound/health/fastbeat.ogg', repeat = TRUE)
			owner.playsound_local(owner, fastbeat, 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		if(BLOODY_LUST_ACTIVE) //turns out you need a good amount of time to kill, hide or destroy body, and escape
			next_phase_in = 4 MINUTES
			phase_message = span_userdanger("THE HORRIFIC FORM BENEATH HAS SURFACED! SATE THE BLOODLUST! ALL YOU CAN THINK! SATE THE BLOODLUST! SATE THE BLOODLUST!")
	if(!silent)
		to_chat(addict, phase_message)
	next_transformation_timer = addtimer(CALLBACK(src, .proc/advance_phase), 8 MINUTES)

/datum/antagonist/bloody_lust/proc/advance_phase()
	transformation_state = WRAP(transformation_state++, BLOODY_LUST_INACTIVE, BLOODY_LUST_ACTIVE)
	apply_phase_effects()

/datum/outfit/bloody_lust

/datum/outfit/bloody_lust/pre_equip(mob/living/carbon/human/addict, visualsOnly)
	. = ..()
	addict.eye_color = "#FF0000"
	addict.update_body()

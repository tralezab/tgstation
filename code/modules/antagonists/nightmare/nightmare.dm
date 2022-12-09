/datum/antagonist/nightmare
	name = "\improper Nightmare"
	traitor_panel_categories = list(PANEL_PURPOSE_SOLO, PANEL_FACTION_ALIENS)
	job_rank = ROLE_NIGHTMARE

	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoNightmare"
	suicide_cry = "FOR THE DARKNESS!!"
	preview_outfit = /datum/outfit/nightmare

/datum/outfit/nightmare
	name = "Nightmare (Preview only)"

/datum/outfit/nightmare/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/shadow/nightmare)

/datum/martial_art/ninjutsu
	name = "Ninjutsu"
	var/datum/action/innate/martial/ninjutsu_help/ninjutsu_help

/datum/martial_art/ninjutsu/teach(mob/living/carbon/human/H,make_temporary=0)
	ninjutsu_help = new
	ninjutsu_help.Grant(owner)
	..()

/datum/martial_art/ninjutsu/on_remove(mob/living/carbon/human/H)
	QDEL_NULL(ninjutsu_help)
	return ..()

/datum/action/innate/martial/ninjutsu_help
	background_icon_state = "bg_ninja"
	name = "Recall Disciplines"
	desc = "Remember the ancient teachings of your elders."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "ninjutsu_help"
	var/eldername

/datum/action/innate/martial/ninjutsu_help/Activate()
	if(!eldername)
		eldername = "Elder [pick(GLOB.ninja_names)]"

	to_chat(owner, "<b><i>You reach out to your clan elders...</i></b>")
	//add a check for level here, then have what the elder says at the start reflect your level.
	to_chat(owner, "<span class='notice'>[eldername]</span>: \"I have not implemented the exp system yet... sorry...\"")
	to_chat(owner, "<span class='notice'>[eldername]</span>: \"Darkness is your fortitude, and surprise is your weapon. Use both for powerful strikes.")
	to_chat(owner, "<span class='notice'>[eldername]</span>: \"Your assail must be silent, to not attract unwanted attention.")
	to_chat(owner, "<span class='notice'>[eldername]</span>: \"Know your enemies, remember your disciplines, and you will have no trouble incapacitating your foes.")
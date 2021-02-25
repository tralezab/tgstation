

/datum/action/changeling/fleshbud
	name = "Flesh Bud"
	desc = "Prepare a bundle of DNA as a genetic backup in case of total body destruction."
	helptext = "You're going to want this."
	button_icon_state = "panacea"
	chemical_cost = 20
	req_stat = CONSCIOUS

//Heals the things that the other regenerative abilities don't.
/datum/action/changeling/fleshbud/sting_action(mob/user)
	to_chat(user, "<span class='notice'>We cleanse impurities from our form.</span>")
	..()

	return TRUE

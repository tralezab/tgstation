/datum/antagonist/faceless
	name = "Faceless"
	roundend_category = "faceless"
	antagpanel_category = "Changeling"

/datum/antagonist/faceless/on_gain()
	give_objective()
	. = ..()

/datum/antagonist/faceless/greet()
	to_chat(owner, "<big><span class='danger'><b>You can't remember how you got here... Or who you are.</b></span></big>")
	to_chat(owner, "<span class='warning'><b>Time to find new purpose.</b></span>")
	owner.announce_objectives()

//they'll get their own objectives with time
/datum/antagonist/faceless/proc/give_objective()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
	var/objtype = (prob(75) ? /datum/objective/abductee/random : pick(subtypesof(/datum/objective/abductee/) - /datum/objective/abductee/random))
	var/datum/objective/abductee/O = new objtype()
	objectives += O


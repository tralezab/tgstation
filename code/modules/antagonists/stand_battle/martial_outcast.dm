/datum/antagonist/martial_outcast
	name = "Martial Outcast"
	roundend_category = "holoparasite user"

/datum/antagonist/martial_outcast/apply_innate_effects(mob/living/mob_override)

/datum/antagonist/martial_outcast/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are a [owner.special_role] in the holoparasite battle.</font></B>")
	to_chat(owner.current, "An odd reaction to holoparasites means you could not get one, but you have the determination to win!")
	to_chat(owner.current, "You have been instead training in a long lost forbidden art! Use it to destroy your enemies!")
	to_chat(owner.current, "Cooperation is allowed, but remember that only one team gets to leave.")
	owner.announce_objectives()

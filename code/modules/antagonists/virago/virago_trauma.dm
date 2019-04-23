
/*
Virago Trauma!
This is because traumas use on_say, which viragos need for their chants. It does nothing, is not noticable, is not curable except by removing virago status.
That's why it's in the virago file instead of in the trauma files!
*/

/datum/brain_trauma/special/virago
	name = "Warped Mind"
	desc = "Patient's brain is coated in some kind of black tar."
	scan_desc = "bloodlust"
	gain_text = "Say \"Name the darkness\" with a book in your hand to turn it into a guide for you to study the rites."
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	hidden = TRUE
	var/list/learned_rituals = list()

/datum/brain_trauma/special/virago/New()
	..()
	//virago gets a couple basics to research rituals- these do not count towards completed ritual objectives.
	var/datum/curse/summon_book/summon_book = new
	summon_book.curser = owner //isn't getting set??
	learned_rituals += summon_book

/datum/brain_trauma/special/virago/on_say(message)
	var/regex/R
	//var/static/list/all_curses =
	for(var/datum/curse/C in learned_rituals)
		R = regex("[REGEX_QUOTE(C.keyword)]","gi")
		if(R.Find(message))
			if(C.curse_startup())
				flash_color(owner, flash_color = "#FF0000", flash_time = 50)
	return message

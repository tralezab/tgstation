
/mob/living/simple_animal/hostile/guardian/mood
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "slaps"
	playstyle_string = "<span class='holoparasite'>As a <b>motivation</b> type you are weak but talking will give your summoner the resolve to complete the mission!</span>"
	obj_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/guardian/mood/say()
	. = ..()
	SEND_SIGNAL(summoner, COMSIG_ADD_MOOD_EVENT, "encouragement", /datum/mood_event/focused/timed)

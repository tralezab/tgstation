
/mob/living/simple_animal/hostile/guardian/hunter
	melee_damage_lower = 10
	melee_damage_upper = 10
	range = 80 //very high
	attacktext = "siphons"
	melee_damage_type = TOX
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = "<span class='holoparasite'>As a <b>hunter</b> type you have weaker, toxic attacks and high range. As a quirk of very high range, you are only able to recall by exiting your range.</span>"
	obj_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/guardian/hunter/can_Recall(forced)
	if(forced)
		return TRUE
	to_chat(src, "<span class='userdanger'>Hunter types cannot recall manually! Either exit your range or go back to your summoner!</span>")
	return FALSE

/mob/living/simple_animal/hostile/guardian/hunter/AttackingTarget()
	. = ..()
	if(isliving(target))
		to_chat(target, "<span class='userdanger'>You feel drained...</span>")

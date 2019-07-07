//astrological -- wizard only.
/mob/living/simple_animal/hostile/guardian/astrological
	melee_damage_lower = 1
	melee_damage_upper = 1
	next_move_modifier = 0.8 //attacks 20% faster, for more meteors
	attacktext = "pokes"
	attack_sound = 'sound/weapons/genhit.ogg'
	playstyle_string = "<span class='holoparasite'>As an <b>astrological</b> type your attacks are laughable, but send a phantom meteor at the target from space.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Tunguska, patient and wholly destructive.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Astrological modules loaded. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught one! It's astrological... or astronomical. Meteorological? Just shoot meteors!</span>"

/mob/living/simple_animal/hostile/guardian/astrological/AttackingTarget()
	. = ..()
	if(isliving(target))
		spawn_meteor(list(/obj/effect/meteor/phantom), target)

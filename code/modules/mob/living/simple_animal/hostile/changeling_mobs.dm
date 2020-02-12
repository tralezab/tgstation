#define TRUE_CHANGELING_REFORM_WAIT 30 SECONDS //needs to wait 30 seconds before it can reform
#define TRUE_CHANGELING_PASSIVE_HEAL 3 //Amount of brute damage restored per tick
#define TRUE_CHANGELING_FORCED_REFORM 60 SECONDS

//Changelings in their true form.
//This is how they kill people, typically. The horror form grabs the closest person and doesn't let go, making it excellent for killing solo.
//In groups, the horror is much worse and takes a ton more damage from burn weapons. The changeling is very slow as well when not attacking it's target.

/mob/living/simple_animal/hostile/true_changeling
	name = "horror"
	real_name = "horror"
	desc = "Holy shit, what the fuck is that thing?!"
	speak_emote = list("says with one of its faces")
	icon = 'icons/mob/changeling.dmi'
	icon_state = "horror1"
	icon_living = "horror1"
	icon_dead = "horror_dead"
	speed = 1
	gender = NEUTER
	a_intent = "harm"
	stop_automated_movement = TRUE
	status_flags = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	health = 240
	maxHealth = 240 //pretty durable
	damage_coeff = list(BRUTE = 0.75, BURN = 2, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //feel the burn!!
	force_threshold = 10
	healable = 0
	environment_smash = 1 //Tables, closets, etc.
	melee_damage_lower = 35
	melee_damage_upper = 35
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	wander = 0
	attacktext = "tears into"
	attack_sound = 'sound/creatures/hit3.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 15)
	var/deaths = 0//how many times we died. will always be at least one in the revive timer
	var/mob/living/carbon/human/stored_changeling = null //The changeling that transformed
	var/datum/beam/grasp_beam = null //changeling's tendril grab.
	var/mob/living/grasp_victim = null //mob that was grabbed.
	var/datum/action/innate/changeling/reform/reform

/mob/living/simple_animal/hostile/true_changeling/Initialize(mapload, deathin)
	. = ..()
	icon_state = "horror[rand(1, 5)]"
	reform = new
	reform.Grant(src)
	if(deathin)
		addtimer(CALLBACK(src, .proc/death), deathin)
	horrorform_grasp()

/mob/living/simple_animal/hostile/true_changeling/Destroy()
	QDEL_NULL(reform)
	QDEL_NULL(spine_crawl)
	stored_changeling = null
	return ..()

/mob/living/simple_animal/hostile/true_changeling/Life()
	..()
	adjustBruteLoss(-TRUE_CHANGELING_PASSIVE_HEAL) //True changelings slowly regenerate

/mob/living/simple_animal/hostile/true_changeling/adjustFireLoss(amount)
	if(!stat)
		playsound(src, 'sound/creatures/ling_scream.ogg', 100, 1)
	..()

/mob/living/simple_animal/hostile/true_changeling/Stat()
	..()
	if(statpanel("Status"))
		if(stored_changeling)
			var/time_left = TRUE_CHANGELING_FORCED_REFORM - time_spent_as_true
			time_left = CLAMP(time_left, 0, INFINITY)
			stat(null, "Time Remaining: [time_left]")
		stat(null, "Ignoring Gravity: [wallcrawl ? "YES" : "NO"]")

/mob/living/simple_animal/hostile/true_changeling/death()
	..(1)
	new /obj/effect/gibspawner/human(get_turf(src))
	if(stored_changeling && mind)
		visible_message("<span class='warning'>[src] lets out a furious scream as it shrinks into its human form.</span>", \
						"<span class='userdanger'>We lack the power to maintain this form! We helplessly turn back into a human...</span>")
		stored_changeling.loc = get_turf(src)
		mind.transfer_to(stored_changeling)
		stored_changeling.Unconscious(300) //Make them helpless for some time
		stored_changeling.status_flags &= ~GODMODE
		qdel(src)
	else
		deaths++
		visible_message("<span class='warning'>[src] lets out a waning scream as it falls, twitching, to the floor.</span>", \
						"<span class='userdanger'>We have fallen! We begin the revival process...</span>")
		var/lingreformtimer = 30 SECONDS * deaths
		addtimer(CALLBACK(src, .proc/lingreform), lingreformtimer)

/mob/living/simple_animal/hostile/true_changeling/proc/lingreform()
	if(!src)
		return FALSE
	visible_message("<span class='userdanger'>the twitching corpse of [src] reforms!</span>")
	for(var/mob/M in view(7, src))
		flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 5)
	new /obj/effect/gibspawner/human(get_turf(src))
	revive() //Changelings can self-revive, and true changelings are no exception

/mob/living/simple_animal/hostile/true_changeling/proc/horrorform_grasp()
	var/mob/living/closest_target
	var/closest_target_distance = 0
	for(var/mob/living/target in view(7, src))
		if(!closest_target)
			closest_target = target
			closest_target_distance = get_dist(src, closest_target)
		else
			var/dist = get_dist(src, target)
			if(dist < closest_target_distance)
				closest_target = target
				closest_target_distance = dist
	if(closest_target)
		return
	visible_message("<span class='userdanger'>a tendril shoots out of [src] and grabs onto [closest_target]!</span>", "<span class='userdanger'>Our target is [closest_target]! Attacking them will lunge in their direction!</span>")
	grasp_beam = Beam(beam_target, "plasmabeam", time= 3 SECONDS, maxdistance=7, beam_type=/obj/effect/ebeam/horror)

/datum/action/innate/changeling
	icon_icon = 'icons/mob/changeling.dmi'
	background_icon_state = "bg_ling"

/datum/action/innate/changeling/reform
	name = "Re-Form Human Shell"
	desc = "We turn back into a human. This takes considerable effort and will stun us for some time afterwards."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "reform"

/datum/action/innate/changeling/reform/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(!M.stored_changeling)
		to_chat(M, "<span class='warning'>We do not have a form other than this!</span>")
		return FALSE
	if(M.time_spent_as_true < TRUE_CHANGELING_REFORM_THRESHOLD)
		to_chat(M, "<span class='warning'>We are not able to change back at will!</span>")
		return FALSE
	M.visible_message("<span class='warning'>[M] suddenly crunches and twists into a smaller form!</span>", \
					"<span class='danger'>We return to our human form.</span>")
	M.stored_changeling.forceMove(get_turf(M))
	M.mind.transfer_to(M.stored_changeling)
	M.stored_changeling.Unconscious(200)
	M.stored_changeling.status_flags &= ~GODMODE
	qdel(M)
	return TRUE

#undef TRUE_CHANGELING_REFORM_THRESHOLD
#undef TRUE_CHANGELING_PASSIVE_HEAL
#undef TRUE_CHANGELING_FORCED_REFORM

//headslug

#define EGG_INCUBATION_TIME 120

/mob/living/simple_animal/hostile/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	gender = NEUTER
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_ALWAYS
	var/datum/mind/origin
	var/egg_lain = 0

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/body_egg/changeling_egg/egg = new(victim)
	egg.Insert(victim)
	if(origin)
		egg.origin = origin
	else if(mind) // Let's make this a feature
		egg.origin = mind
	for(var/obj/item/organ/I in src)
		I.forceMove(egg)
	visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
	egg_lain = 1

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	. = ..()
	if(. && !egg_lain && iscarbon(target) && !ismonkey(target))
		// Changeling egg can survive in aliens!
		var/mob/living/carbon/C = target
		if(C.stat == DEAD)
			if(HAS_TRAIT(C, TRAIT_XENO_HOST))
				to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
				return
			Infect(target)
			to_chat(src, "<span class='userdanger'>With our egg laid, our death approaches rapidly...</span>")
			addtimer(CALLBACK(src, .proc/death), 100)

/obj/item/organ/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	var/datum/mind/origin
	var/time

/obj/item/organ/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in dead people
	time++
	if(time >= EGG_INCUBATION_TIME)
		Pop()
		Remove(owner)
		qdel(src)

/obj/item/organ/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/monkey/M = new(owner)

	for(var/obj/item/organ/I in src)
		I.Insert(M, 1)

	if(origin && (origin.current ? (origin.current.stat == DEAD) : origin.get_ghost()))
		origin.transfer_to(M)
		var/datum/antagonist/changeling/C = origin.has_antag_datum(/datum/antagonist/changeling)
		if(!C)
			C = origin.add_antag_datum(/datum/antagonist/changeling/xenobio)
		if(C.can_absorb_dna(owner))
			C.add_new_profile(owner)

		var/datum/action/changeling/humanform/hf = new
		C.purchasedpowers += hf
		C.regain_powers()
		M.key = origin.key
	owner.gib()

#undef EGG_INCUBATION_TIME

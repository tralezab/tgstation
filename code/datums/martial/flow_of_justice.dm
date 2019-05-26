#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"

/datum/martial_art/flow_of_justice
	name = "Flow of Justice"
	id = MARTIALART_SLEEPINGCARP
	deflection_chance = 100
	//var/datum/action/heal/heal = new/datum/action/heal()
	//var/datum/action/siphon/siphon = new/datum/action/siphon()
	var/datum/action/yeso/yeso = new/datum/action/yeso()

/datum/action/yeso
	name = "Yeso Foundation Strike - If the target is a holoparasite user, it locks their holoparasites inside of them and slows them."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"

/datum/action/yeso/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == "yeso")
		to_chat(owner, "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		to_chat(owner, "<b><i>Your next attack will be a foundation strike.</i></b>")
		H.mind.martial_art.streak = "yeso"

/datum/martial_art/flow_of_justice/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You know the [name]!</span>")
		to_chat(H, "<span class = 'danger'>Place your cursor over a move at the top of the screen to see what it does. You will siphon health if the target has more than you, and you can deflect projectiles!</span>")
		yeso.Grant(H)

/datum/martial_art/flow_of_justice/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the [name]...</span>")
	yeso.Remove(H)

/datum/martial_art/flow_of_justice/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("yeso")
			streak = ""
			yeso(A,D)
			return 1
	return 0

/datum/martial_art/flow_of_justice/proc/yeso(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] strikes [D]!</span>", \
				  	"<span class='userdanger'>[A] strikes you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(5, A.dna.species.attack_type)
	for(var/mob/living/simple_animal/hostile/guardian/guardian in D.hasparasites())
		to_chat(guardian, "<span class='userdanger'>You are locked in your user for 10 seconds!</span>")
		guardian.Recall(TRUE)
		guardian.cooldown = world.time + 10 SECONDS
	log_combat(A, D, "foundation striked")
	return 1

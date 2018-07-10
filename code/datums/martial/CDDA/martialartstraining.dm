//CONTAINS:
//
//KARATE: rapid, precise attacks, blocks, and fluid movement. A successful hit allows you an extra dodge and two extra blocks on the following round.
//JUDO: focuses on grabs and throws, both defensive and offensive. It also focuses on recovering from throws; while using judo, you will not lose any turns to being thrown or knocked down.
//AIKIDO: self-defense, while minimizing injury to the attacker. It uses defense throws and disarms. Damage done while using this technique is halved, but applies heavy stamina damage.
//TAI CHI: focused on self-defense. Its ability to absorb the force of an attack makes your Perception decrease damage further on a block. (decreases damage you take from punches and melee)
//TAEKWONDO:  Focused on kicks and punches, it also includes strength training; your blocks absorb extra damage the stronger you are.

/datum/martial_art/karate
	name = "Karate"
	can_crit = TRUE

/obj/item/karate
	name = "odd mushroom"
	desc = "<I>Sapienza Ophioglossoides</I>:An odd mushroom from the flesh of a mushroom person. it has apparently retained some innate power of it's owner, as it quivers with barely-contained POWER!"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "mycelium-angel"

/obj/item/karate/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/message = "<span class='spider'>You devour [src], and a confluence of skill and power from the mushroom enhances your punches! You do need a short moment to charge these powerful punches.</span>"
	to_chat(user, message)
	var/datum/martial_art/karate/mush = new(null)
	mush.teach(user)
	qdel(src)
	visible_message("<span class='warning'>[user] devours [src].</span>")

/datum/martial_art/judo
	name = "Judo"

/datum/martial_art/aikido
	name = "Aikido"

/datum/martial_art/ninjutsu
	name = "Ninjutsu"
	var/datum/action/innate/ninjutsu_help/ninjutsu_help

/datum/martial_art/ninjutsu/teach(mob/living/carbon/human/H,make_temporary=0)
	ninjutsu_help = new
	ninjutsu_help.Grant(H)

/obj/item/ninjutsu
	name = "granter"
	desc = "grants ninja power"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "mycelium-angel"

/obj/item/ninjutsu/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/message = "<span class='spider'>You devour [src], and a confluence of skill and power from the mushroom enhances your punches! You do need a short moment to charge these powerful punches.</span>"
	to_chat(user, message)
	var/datum/martial_art/ninjutsu/martial = new(null)
	martial.teach(user)
	qdel(src)
	visible_message("<span class='warning'>[user] devours [src].</span>")

/datum/action/innate/ninjutsu_help
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"
	name = "Recall Teachings"
	desc = "Remember the ancient teachings of Ninjutsu."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_web"
	var/eldername

/datum/action/innate/ninjutsu_help/Activate()
	if(!eldername)
		eldername = "Elder [pick(GLOB.ninja_names)]"

	to_chat(owner, "<b><i>You reach out to your clan elders...</i></b>")
	//add a check for level here, then have what the elder says at the start reflect your level.
	to_chat(owner, "<span class='spiderclan'>[eldername]:I have not implemented the learning system yet... sorry...\"</span>")
	to_chat(owner, "<span class='spiderclan'>[eldername]:Darkness is your fortitude, and surprise is your weapon. Use both for powerful strikes.</span>")
	to_chat(owner, "<span class='spiderclan'>[eldername]:Your assail must be silent, to not attract unwanted attention.</span>")
	to_chat(owner, "<span class='spiderclan'>[eldername]:Know your enemies, remember your disciplines, and you will have no trouble incapacitating your foes.</span>")
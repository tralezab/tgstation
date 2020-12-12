///These are for the medisim shuttle

#define REDFIELD_TEAM "Red"
#define BLUESWORTH_TEAM "Blue"

/obj/machinery/capture_the_flag/medisim
	game_id = "medieval"
	game_area = /area/shuttle/escape/simulation
	ammo_type = null //no guns, no need

/obj/machinery/capture_the_flag/medisim/Initialize(mapload)
	. = ..()
	start_ctf()

/obj/machinery/capture_the_flag/medisim/victory()
	. = ..()
	start_ctf()//so admins don't have to enable it again, they can just go

/obj/machinery/capture_the_flag/medisim/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/human_knight = ..()
	human_knight.remove_all_languages(LANGUAGE_CTF)
	human_knight.grant_language(language = /datum/language/oldworld, understood = TRUE, spoken = TRUE, source = LANGUAGE_CTF)
	randomize_human(human_knight)
	human_knight.dna.add_mutation(MEDIEVAL, MUT_OTHER)
	var/oldname = human_knight.name
	var/title = "error"
	switch (human_knight.gender)
		if (MALE)
			title = pick(list("Sir", "Lord"))
		if (FEMALE)
			title = pick(list("Dame", "Lady"))
		else
			title = "Noble"
	human_knight.real_name = "[title] [oldname]"
	human_knight.name = human_knight.real_name

/obj/machinery/capture_the_flag/medisim/red
	name = "\improper Redfield Data Realizer"
	icon_state = "syndbeacon"
	team = REDFIELD_TEAM
	team_span = "redteamradio"
	ctf_gear = list("knight" = /datum/outfit/medisim_red_knight, "archer" = /datum/outfit/medisim_red_archer)

/obj/machinery/capture_the_flag/medisim/blue
	name = "\improper Bluesworth Data Realizer"
	icon_state = "bluebeacon"
	team = BLUESWORTH_TEAM
	team_span = "blueteamradio"
	ctf_gear = list("knight" = /datum/outfit/medisim_blue_knight, "archer" = /datum/outfit/medisim_blue_archer)

/obj/item/ctf/red/medisim
	name = "\improper Redfield Castle Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_nuke"
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/obj/item/ctf/blue/medisim
	name = "\improper Bluesworth Hold Fair Maiden"
	desc = "Protect your maiden, and capture theirs!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "plushie_slime"
	game_area = /area/shuttle/escape
	movement_type = FLOATING //there are chasms, and resetting when they fall in is really lame so lets minimize that

/datum/outfit/medisim_red_knight
	name = "Redfield Castle Knight"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/plate/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	gloves = /obj/item/clothing/gloves/plate/red
	head = /obj/item/clothing/head/helmet/knight/red
	r_hand = /obj/item/claymore

/datum/outfit/medisim_blue_knight
	name = "Bluesworth Hold Knight"

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/plate/blue
	suit = /obj/item/clothing/suit/armor/riot/knight/blue
	gloves = /obj/item/clothing/gloves/plate/blue
	head = /obj/item/clothing/head/helmet/knight/blue
	r_hand = /obj/item/claymore

/datum/outfit/medisim_red_archer
	name = "Redfield Castle Archer"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/plate/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	gloves = /obj/item/clothing/gloves/plate/red
	head = /obj/item/clothing/head/helmet/knight/red
	r_hand = /obj/item/claymore

/datum/outfit/medisim_blue_archer
	name = "Bluesworth Hold Archer"

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/plate/blue
	//suit = /obj/item/clothing/suit/armor/riot/knight/blue
	gloves = /obj/item/clothing/gloves/plate/blue
	//head = /obj/item/clothing/head/helmet/knight/blue
	r_hand = /obj/item/gun/ballistic/bow
	l_hand = /obj/item/ammo_casing/caseless/arrow

/obj/machinery/computer/reality_simulation
	name = "reality simulation computer"
	desc = "A computer calculating the medieval times. Uh, wow. Is this bad boy quantum?"

#undef REDFIELD_TEAM
#undef BLUESWORTH_TEAM

///pirate spawners.
/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	outfit = /datum/outfit/pirate/space
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	short_desc = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	spawner_job_path = /datum/job/space_pirate
	///Rank of the pirate on the ship, it's used in generating pirate names!
	var/rank = "Deserter"
	///Whether or not it will spawn a fluff structure upon opening.
	var/spawn_oldpod = TRUE

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name, generate_pirate_name(new_spawn.gender))
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name(spawn_gender)
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	if(spawn_oldpod)
		new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Renegade Leader"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Rogue"

/obj/effect/mob_spawn/human/pirate/skeleton
	name = "pirate remains"
	desc = "Some unanimated bones. They feel like they could spring to life any moment!"
	random = TRUE
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	spawn_oldpod = FALSE
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate
	rank = "Mate"

/obj/effect/mob_spawn/human/pirate/skeleton/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/captain

/obj/effect/mob_spawn/human/pirate/skeleton/gunner
	rank = "Gunner"

/obj/effect/mob_spawn/human/pirate/silverscale
	name = "elegant sleeper"
	desc = "Cozy. You get the feeling you aren't supposed to be here, though..."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/lizard/silverscale
	outfit = /datum/outfit/pirate/silverscale
	rank = "High-born"

/obj/effect/mob_spawn/human/pirate/silverscale/generate_pirate_name(spawn_gender)
	var/first_name
	switch(gender)
		if(MALE)
			first_name = pick(GLOB.lizard_names_male)
		if(FEMALE)
			first_name = pick(GLOB.lizard_names_female)
		else
			first_name = pick(GLOB.lizard_names_male + GLOB.lizard_names_female)

	return "[rank] [first_name]-Silverscale"

/obj/effect/mob_spawn/human/pirate/silverscale/captain
	rank = "Old-guard"
	outfit = /datum/outfit/pirate/silverscale/captain

/obj/effect/mob_spawn/human/pirate/silverscale/gunner
	rank = "Top-drawer"

//icebox only exclusive!

/obj/effect/mob_spawn/human/pirate/expedition
	name = "expedition crew remains"
	desc = "What's left of some previous planetary scouts. You gotta crack a few planetary scouts to make a plasma rich research facility!"
	random = TRUE
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	spawn_oldpod = FALSE
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/expedition_exogeologist
	rank = "Expedition Exogeologist"

/obj/effect/mob_spawn/human/pirate/expedition/captain
	rank = "Expedition Director"
	outfit = /datum/outfit/pirate/captain

/obj/effect/mob_spawn/human/pirate/expedition/gunner
	rank = "Expedition Xenobiologist"

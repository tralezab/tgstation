//since swarmers and mutamorphs are just robotic/organic versions of each other, so this will look shamelessly copypas- i mean similar

/datum/round_event_control/spawn_mutamorph
	name = "Spawn Mutamorph Egg"
	typepath = /datum/round_event/spawn_swarmer
	weight = 3
	max_occurrences = 1 //Only once okay fam
	earliest_start = 30 MINUTES
	min_players = 15


/datum/round_event/spawn_mutamorph

/datum/round_event/spawn_mutamorph/start()
	if(find_mutamorph())//does not trigger if there is already a muta with a client
		return FALSE
	if(!GLOB.the_gateway)//or if there is no gateway
		return FALSE
	new /obj/effect/mob_spawn/mutamorph(get_turf(GLOB.the_gateway))
	if(prob(25)) //25% chance to announce it to the crew
		var/mutamorph_report = "<span class='big bold'>[command_name()] High-Priority Update</span>"
		mutamorph_report += "<br><br>Our long-range sensors have detected an odd signal emanating from your station's gateway. We recommend immediate investigation of your gateway, as something may have come through."
		print_command_report(mutamorph_report, announce=TRUE)

/datum/round_event/spawn_mutamorph/proc/find_mutamorph()
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(ismuta(L) && L.client)
			return TRUE
	return TRUE

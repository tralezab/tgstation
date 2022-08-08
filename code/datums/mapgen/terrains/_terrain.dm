///This datum contains the data for a specific terrain type! For example a forest (With trees and bears)
/datum/terrain
	///Type of turf this terrain creates
	var/turf_type
	///Chance of having a structure from the flora types list spawn
	var/flora_density = 0
	///Chance of having a mob from the fauna types list spawn
	var/fauna_density = 0
	///list of type paths of objects that can be spawned when the turf spawns flora
	var/list/flora_types = list(/obj/structure/flora/grass/jungle/a/style_random)
	///list of type paths of mobs that can be spawned when the turf spawns fauna
	var/list/fauna_types = list()

///This proc handles the creation of a turf of a specific terrain type
/datum/terrain/proc/generate_turf(turf/gen_turf)
	gen_turf.ChangeTurf(turf_type, null, CHANGETURF_DEFER_CHANGE)
	if(length(fauna_types) && prob(fauna_density))
		var/mob/fauna = pick(fauna_types)
		new fauna(gen_turf)

	if(length(flora_types) && prob(flora_density))
		var/obj/structure/flora = pick(flora_types)
		new flora(gen_turf)

/datum/terrain/mudlands
	turf_type = /turf/open/misc/dirt/jungle/dark
	flora_types = list(/obj/structure/flora/grass/jungle/a/style_random,/obj/structure/flora/grass/jungle/b/style_random, /obj/structure/flora/rock/pile/jungle/style_random, /obj/structure/flora/rock/pile/jungle/large/style_random)
	flora_density = 3

/datum/terrain/plains
	turf_type = /turf/open/misc/grass/jungle
	flora_types = list(/obj/structure/flora/grass/jungle/a/style_random,/obj/structure/flora/grass/jungle/b/style_random, /obj/structure/flora/tree/jungle/style_random, /obj/structure/flora/rock/pile/jungle/style_random, /obj/structure/flora/bush/jungle/a/style_random, /obj/structure/flora/bush/jungle/b/style_random, /obj/structure/flora/bush/jungle/c/style_random, /obj/structure/flora/bush/large/style_random, /obj/structure/flora/rock/pile/jungle/large/style_random)
	flora_density = 15

/datum/terrain/jungle
	turf_type = /turf/open/misc/grass/jungle
	flora_types = list(/obj/structure/flora/grass/jungle/a/style_random,/obj/structure/flora/grass/jungle/b/style_random, /obj/structure/flora/tree/jungle/style_random, /obj/structure/flora/rock/pile/jungle/style_random, /obj/structure/flora/bush/jungle/a/style_random, /obj/structure/flora/bush/jungle/b/style_random, /obj/structure/flora/bush/jungle/c/style_random, /obj/structure/flora/bush/large/style_random, /obj/structure/flora/rock/pile/jungle/large/style_random)
	flora_density = 40

/datum/terrain/jungle/deep
	flora_density = 65

/datum/terrain/wasteland
	turf_type = /turf/open/misc/dirt/jungle/wasteland

/datum/terrain/water
	turf_type = /turf/open/water/jungle

/datum/terrain/mountain
	turf_type = /turf/closed/mineral/random/jungle

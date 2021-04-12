


/datum/biome/contaminated_thicket
	turf_type = /turf/open/floor/grass/thicket
	flora_types = list(/obj/structure/spawner/mining/gutlunch = 1, /obj/structure/flora/tree/living = 8)
	fauna_types = list(/mob/living/simple_animal/hostile/retaliate/thicket_guard = 1)
	flora_density = 5
	fauna_density = 2

/datum/map_generator/thicket

	modules = list(
		/datum/map_generator_module/bottom_layer/plating, //all old turfs to plating
		/datum/map_generator_module/bottom_layer/massdelete/leave_turfs, //then clean up everything else
	)

	buildmode_name = "Biome: Contaminated Thicket"

/datum/map_generator/thicket/generate_terrain(list/turfs)
	. = ..()
	var/datum/biome/thicket_biome = SSmapping.biomes[/datum/biome/contaminated_thicket] //Get the instance of this biome from SSmapping

	for(var/turf/gen_turf as anything in turfs) //Go through all the turfs and generate them
		thicket_biome.generate_turf(gen_turf)
		CHECK_TICK

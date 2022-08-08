/datum/map_generator/terrain_applier
	name = "terrain"
	var/datum/terrain/selected_terrain

/datum/map_generator/terrain_applier/generate_terrain(list/turfs)

	var/datum/terrain/terrain_instance = SSmapping.terrains[selected_terrain] //Get the instance of this terrain from SSmapping

	for(var/turf/gen_turf as anything in turfs) //Go through all the turfs and generate them
		terrain_instance.generate_turf(gen_turf)
		CHECK_TICK

	return ..()

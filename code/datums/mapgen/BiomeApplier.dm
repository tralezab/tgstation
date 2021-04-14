/datum/map_generator/biome_applier
	name = "Biome"
	var/datum/biome/selected_biome

/datum/map_generator/biome_applier/generate_terrain(list/turfs)

	var/datum/biome/biome_instance = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping

	for(var/turf/gen_turf as anything in turfs) //Go through all the turfs and generate them
		biome_instance.generate_turf(gen_turf)
		CHECK_TICK

	return ..()

/datum/map_generator/biome_applier/tar_pits
	name = "The grim tar pits"
	selected_biome = /datum/biome/mudlands

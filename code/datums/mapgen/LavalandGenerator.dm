/datum/map_generator/lavaland_biomes
	name = "Lavaland Biomes"
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	///Assoc lists of type of generation type, and the turfs in that generation type. Filled during generation for this datum
	var/list/generation_turfs = list()
	///2D list of all generation types based on heat and humidity combos.
	var/list/possible_generation_types = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_MEDIUM_HUMIDITY = /datum/map_generator/cave_generator/lavaland,
		BIOME_HIGH_HUMIDITY = /datum/map_generator/cave_generator/lavaland

		),
	BIOME_MEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_MEDIUM_HUMIDITY = /datum/map_generator/cave_generator/lavaland,
		BIOME_HIGH_HUMIDITY = /datum/map_generator/blood_forest
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/map_generator/cave_generator/lavaland,
		BIOME_MEDIUM_HUMIDITY = /datum/map_generator/blood_forest,
		BIOME_HIGH_HUMIDITY = /datum/map_generator/blood_forest

		)
	)

	var/datum/map_generator/cave_generator/default_cave_generator = /datum/map_generator/cave_generator/lavaland


/datum/map_generator/lavaland_biomes/generate_terrain(list/turfs)
	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	default_cave_generator = new default_cave_generator()
	var/cave_noise_string = default_cave_generator.generate_noise() //Get noise from this cave generator and store it, we will use this for all caves in this generator.

	for(var/generation_turf in turfs) //Go through all the turfs and assign them to the correct generator
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
		var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
		var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
		var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

		switch(heat)
			if(0 to 0.33)
				heat_level = BIOME_LOW_HEAT
			if(0.33 to 0.66)
				heat_level = BIOME_LOWMEDIUM_HEAT
			if(0.66 to 1)
				heat_level = BIOME_HIGH_HEAT

		switch(humidity)
			if(0 to 0.33)
				humidity_level = BIOME_LOW_HUMIDITY
			if(0.33 to 0.66)
				humidity_level = BIOME_MEDIUM_HUMIDITY
			if(0.66 to 1)
				humidity_level = BIOME_HIGH_HUMIDITY

		generation_turfs[possible_generation_types[heat_level][humidity_level]] += list(generation_turf)

		for(var/datum/map_generator/map_generator as anything in generation_turfs)
			var/new_list_of_generators = list()


	for(var/datum/map_generator/map_generator as anything in generation_turfs)
		if(istype(map_generator, /datum/map_generator/cave_generator)) //scared?
			var/datum/map_generator/cave_generator/cave_gen = map_generator
			map_generator.string_gen = cave_noise_string //Use our pre-made cave noise to make sure all caves correctly connect

		map_generator.generate_terrain(generation_turfs[map_generator])


	var/datum/map_generator/cave_generator/

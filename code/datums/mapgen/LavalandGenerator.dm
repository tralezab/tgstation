/datum/map_generator/lavaland_biomes
	name = "Lavaland Biomes"
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 100
	///Assoc lists of type of generation type, and the turfs in that generation type. Filled during generation for this datum
	var/list/generation_turfs = list()
	///2D list of all generation types based on heat and humidity combos.
	var/list/possible_generation_types = list(
		BIOME_LOW_CORRUPTION = list(
			BIOME_SERENE = /datum/map_generator/cave_generator/lavaland,
			BIOME_PEACEFUL = /datum/map_generator/cave_generator/lavaland,
			BIOME_NEUTRAL = /datum/map_generator/cave_generator/lavaland,
			BIOME_UNTAMED = /datum/map_generator/cave_generator/lavaland,
			BIOME_WILD = /datum/map_generator/cave_generator/lavaland
			),
		BIOME_LOWMEDIUM_CORRUPTION = list(
			BIOME_SERENE = /datum/map_generator/cave_generator/lavaland,
			BIOME_PEACEFUL = /datum/map_generator/cave_generator/lavaland,
			BIOME_NEUTRAL = /datum/map_generator/cave_generator/lavaland,
			BIOME_UNTAMED = /datum/map_generator/cave_generator/lavaland,
			BIOME_WILD = /datum/map_generator/contaminated_thicket
			),
		BIOME_MEDIUM_CORRUPTION = list(
			BIOME_SERENE = /datum/map_generator/cave_generator/lavaland/rusty,
			BIOME_PEACEFUL = /datum/map_generator/biome_applier/tar_pits,
			BIOME_NEUTRAL = /datum/map_generator/biome_applier/tar_pits,
			BIOME_UNTAMED = /datum/map_generator/cave_generator/lavaland,
			BIOME_WILD = /datum/map_generator/contaminated_thicket
			),
		BIOME_HIGHMEDIUM_CORRUPTION = list(
			BIOME_SERENE = /datum/map_generator/cave_generator/lavaland,
			BIOME_PEACEFUL = /datum/map_generator/biome_applier/tar_pits,
			BIOME_NEUTRAL = /datum/map_generator/cave_generator/lavaland,
			BIOME_UNTAMED = /datum/map_generator/cave_generator/lavaland/living_biome,
			BIOME_WILD = /datum/map_generator/contaminated_thicket
			),
		BIOME_HIGH_CORRUPTION = list(
			BIOME_SERENE = /datum/map_generator/cave_generator/lavaland,
			BIOME_PEACEFUL = /datum/map_generator/cave_generator/lavaland,
			BIOME_NEUTRAL = /datum/map_generator/cave_generator/lavaland,
			BIOME_UNTAMED = /datum/map_generator/cave_generator/lavaland/living_biome,
			BIOME_WILD = /datum/map_generator/cave_generator/lavaland/living_biome

		)
	)

	var/datum/map_generator/cave_generator/default_cave_generator = /datum/map_generator/cave_generator/lavaland


/datum/map_generator/lavaland_biomes/generate_terrain(list/turfs)
	var/serenity_seed = rand(0, 50000)

	default_cave_generator = new default_cave_generator()
	var/cave_noise_string = default_cave_generator.generate_noise() //Get noise from this cave generator and store it, we will use this for all caves in this generator.

	for(var/generation_turf in turfs) //Go through all the turfs and assign them to the correct generator
		var/turf/gen_turf = generation_turf
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/y_position_to_use = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT))
		var/drift_y = y_position_to_use / perlin_zoom

		var/serenity = text2num(rustg_noise_get_at_coordinates("[serenity_seed]", "[drift_x]", "[drift_y]"))
		var/serenity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH
		var/corruption_level //How deep into lavaland are we

		switch(clamp(y_position_to_use, CORRUPTION_START_Y_LEVEL, CORRUPTION_END_Y_LEVEL))
			if(CORRUPTION_START_Y_LEVEL to CORRUPTION_MID1_Y_LEVEL)
				corruption_level = BIOME_LOW_CORRUPTION
			if(CORRUPTION_MID1_Y_LEVEL to CORRUPTION_MID2_Y_LEVEL)
				corruption_level = BIOME_LOWMEDIUM_CORRUPTION
			if(CORRUPTION_MID2_Y_LEVEL to CORRUPTION_MID3_Y_LEVEL)
				corruption_level = BIOME_MEDIUM_CORRUPTION
			if(CORRUPTION_MID3_Y_LEVEL to CORRUPTION_MID4_Y_LEVEL)
				corruption_level = BIOME_HIGHMEDIUM_CORRUPTION
			if(CORRUPTION_MID4_Y_LEVEL to CORRUPTION_END_Y_LEVEL)
				corruption_level = BIOME_HIGH_CORRUPTION

		switch(serenity)
			if(0 to 0.2)
				serenity_level = BIOME_SERENE
			if(0.2 to 0.4)
				serenity_level = BIOME_PEACEFUL
			if(0.4 to 0.6)
				serenity_level = BIOME_NEUTRAL
			if(0.6 to 0.8)
				serenity_level = BIOME_UNTAMED
			if(0.8 to 1)
				serenity_level = BIOME_WILD

		var/generation_type = possible_generation_types[corruption_level][serenity_level]

		generation_turfs[generation_type] += list(generation_turf)

	for(var/datum/map_generator/map_generator as anything in generation_turfs)

		var/datum/map_generator/map_generator_instance = new map_generator()

		if(istype(map_generator_instance, /datum/map_generator/cave_generator)) //scared?
			var/datum/map_generator/cave_generator/cave_gen = map_generator_instance
			cave_gen.string_gen = cave_noise_string //Use our pre-made cave noise to make sure all caves correctly connect

		map_generator_instance.generate_terrain(generation_turfs[map_generator])

	generation_turfs = list()

	return ..()

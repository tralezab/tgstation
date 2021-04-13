/datum/map_generator/lavaland


/datum/map_generator/lavaland/generate_terrain(list/turfs)
	. = ..()
	var/start_time = REALTIMEOFDAY


	var/datum




/datum/map_generator/lavaland_biomes
	name = "Lavaland Biomes"
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65
	///Assoc lists of type of biome, and the turfs in that biome type
	var/list/biome_turfs = list()
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mudlands,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/mudlands,
		BIOME_HIGH_HUMIDITY = /datum/biome/water
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/jungle,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle,
		BIOME_HIGH_HUMIDITY = /datum/biome/mudlands
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/plains,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle/deep,
		BIOME_HIGH_HUMIDITY = /datum/biome/jungle
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/wasteland,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/plains,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/jungle,
		BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep
		)
	)


/datum/map_generator/lavaland_biomes/generate_terrain(list/turfs)
	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	for(var/generation_turf in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]"))
		var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
		var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
		var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

		switch(heat)
			if(0 to 0.25)
				heat_level = BIOME_LOW_HEAT
			if(0.25 to 0.5)
				heat_level = BIOME_LOWMEDIUM_HEAT
			if(0.5 to 0.75)
				heat_level = BIOME_HIGHMEDIUM_HEAT
			if(0.75 to 1)
				heat_level = BIOME_HIGH_HEAT
		switch(humidity)
			if(0 to 0.25)
				humidity_level = BIOME_LOW_HUMIDITY
			if(0.25 to 0.5)
				humidity_level = BIOME_LOWMEDIUM_HUMIDITY
			if(0.5 to 0.75)
				humidity_level = BIOME_HIGHMEDIUM_HUMIDITY
			if(0.75 to 1)
				humidity_level = BIOME_HIGH_HUMIDITY
		biome_turfs[possible_biomes[heat_level][humidity_level]] = generation_turf

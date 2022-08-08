
/datum/map_generator/scalar_generator/jungle_generator
	name = "Jungle Generator"

	generation_layers = list(
		PERLIN_LAYER_HEAT = /datum/generator_scalar_layer/perlin_noise,
		PERLIN_LAYER_HUMIDITY = /datum/generator_scalar_layer/perlin_noise,
		PERLIN_LAYER_HEIGHT = /datum/generator_scalar_layer/perlin_noise)

	layer_thresholds = list(
		PERLIN_LAYER_HEIGHT = list(
			BIOME_IS_MOUNTAINS = 0.85,
			BIOME_IS_NOT_MOUNTAINS = 0
		),
		PERLIN_LAYER_HEAT = list(
			BIOME_HIGH_HEAT = 0.75,
			BIOME_HIGHMEDIUM_HEAT = 0.50,
			BIOME_LOWMEDIUM_HEAT = 0.25,
			BIOME_LOW_HEAT = 0
		),
		PERLIN_LAYER_HUMIDITY = list(
			BIOME_HIGH_HUMIDITY = 0.75,
			BIOME_HIGHMEDIUM_HUMIDITY = 0.50,
			BIOME_LOWMEDIUM_HUMIDITY = 0.25,
			BIOME_LOW_HUMIDITY = 0
		),
	)

	possible_terrains = list(
		BIOME_IS_NOT_MOUNTAINS = list(
			BIOME_LOW_HEAT = list(
				BIOME_LOW_HUMIDITY = /datum/terrain/plains,
				BIOME_LOWMEDIUM_HUMIDITY = /datum/terrain/mudlands,
				BIOME_HIGHMEDIUM_HUMIDITY = /datum/terrain/mudlands,
				BIOME_HIGH_HUMIDITY = /datum/terrain/water
				),
			BIOME_LOWMEDIUM_HEAT = list(
				BIOME_LOW_HUMIDITY = /datum/terrain/plains,
				BIOME_LOWMEDIUM_HUMIDITY = /datum/terrain/jungle,
				BIOME_HIGHMEDIUM_HUMIDITY = /datum/terrain/jungle,
				BIOME_HIGH_HUMIDITY = /datum/terrain/mudlands
				),
			BIOME_HIGHMEDIUM_HEAT = list(
				BIOME_LOW_HUMIDITY = /datum/terrain/plains,
				BIOME_LOWMEDIUM_HUMIDITY = /datum/terrain/plains,
				BIOME_HIGHMEDIUM_HUMIDITY = /datum/terrain/jungle/deep,
				BIOME_HIGH_HUMIDITY = /datum/terrain/jungle
				),
			BIOME_HIGH_HEAT = list(
				BIOME_LOW_HUMIDITY = /datum/terrain/wasteland,
				BIOME_LOWMEDIUM_HUMIDITY = /datum/terrain/plains,
				BIOME_HIGHMEDIUM_HUMIDITY = /datum/terrain/jungle,
				BIOME_HIGH_HUMIDITY = /datum/terrain/jungle/deep
				)
			),
		BIOME_IS_MOUNTAINS = /datum/terrain/mountain
		)


/area/mine/planetgeneration
	name = "planet generation area"
	static_lighting = FALSE
	base_lighting_alpha = 255

	map_generator = /datum/map_generator/scalar_generator/jungle_generator

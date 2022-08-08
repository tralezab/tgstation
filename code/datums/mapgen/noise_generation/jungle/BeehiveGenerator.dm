#define BEEHIVE_CAVES "beehive_caves"
#define BEEHIVE_CORE "beehive_core"
#define OUTSIDE "outside"

///Beehive biome gen
/datum/map_generator/scalar_generator/beehive
	name = "Bee Hive Generator"

	generation_layers = list(PERLIN_LAYER_HEIGHT = /datum/generator_scalar_layer/perlin_noise/beehive)

	layer_thresholds = list(
		PERLIN_LAYER_HEIGHT = list(
			BEEHIVE_CAVES = 0.3,
			BEEHIVE_CORE = 0
		),
	)

	possible_terrains = list(
		BEEHIVE_CAVES = /datum/map_generator/cave_generator/beehive,
		BEEHIVE_CORE = /datum/terrain/bee_core,
		)

/datum/generator_scalar_layer/perlin_noise/beehive
	perlin_zoom = 20

///Inside the beehive core biome
/datum/map_generator/cave_generator/beehive
	name = "Bee Hive Cave Generator"
	///Weighted list of the types that spawns if the turf is open
	open_turf_types = list(/turf/open/floor/mineral/wax = 1)
	///Weighted list of the types that spawns if the turf is closed
	closed_turf_types = list(/turf/closed/wall/material/wax = 1)



/area/ruin/beehive
	name = "Beehive"
	area_flags = BLOBS_ALLOWED | NO_ALERTS | CAVES_ALLOWED
	map_generator = /datum/map_generator/scalar_generator/beehive



///The bee biomes
/datum/terrain/bee_wall
	turf_type = /turf/closed/wall/material/wax

/datum/terrain/bee_core
	turf_type = /turf/open/floor/mineral/wax



/datum/material/wax
	name = "wax"
	desc = "Pliable material secreted by insects. Strong for something entirely natural."
	color = "#97865b"
	greyscale_colors = "#97865b"
	strength_modifier = 0.7
	//could add a sheet_type in the future just in case people wanna build bee hives
	categories = list()
	value_per_unit = 0.015
	beauty_modifier = -0.04
	armor_modifiers = list(MELEE = 1.5, BULLET = 1.1, LASER = 0.3, ENERGY = 0.5, BOMB = 1, BIO = 1, FIRE = 1.1, ACID = 1)

/turf/open/floor/mineral/wax
	name = "waxy floor"
	icon_state = "gold"
	material_flags = MATERIAL_GREYSCALE | MATERIAL_EFFECTS
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("wax","wax_dam")
	custom_materials = list(/datum/material/gold = 500)

/turf/open/floor/mineral/wax/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/mineral/wax/lavaland_atmos

/turf/closed/wall/material/wax
	custom_materials = list(/datum/material/wax = 4000)

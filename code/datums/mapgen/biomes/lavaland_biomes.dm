
//CONTAMINATED THICKET//

/datum/biome/contaminated_thicket
	turf_type = /turf/open/floor/grass/thicket
	flora_types = list(/obj/structure/spawner/mining/gutlunch = 1, /obj/structure/flora/ash/blood_pearl = 2, /obj/structure/flora/tree/living = 8)
	fauna_types = list(/mob/living/simple_animal/hostile/retaliate/thicket_guard = 1)
	flora_density = 6
	fauna_density = 2

/datum/biome/contaminated_thicket_lower
	turf_type = /turf/open/floor/grass/thicket
	flora_types = list(/obj/structure/spawner/mining/gutlunch = 1, /obj/structure/flora/ash/blood_pearl = 1, /obj/structure/flora/tree/living = 2)
	fauna_types = list(/mob/living/simple_animal/hostile/asteroid/gutlunch = 1)
	flora_density = 1
	fauna_density = 2

/datum/map_generator/contaminated_thicket

	modules = list(
		/datum/map_generator_module/bottom_layer/plating, //all old turfs to plating
		/datum/map_generator_module/bottom_layer/massdelete/leave_turfs, //then clean up everything else
	)

	buildmode_name = "Biome: Contaminated Thicket"

	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

/datum/map_generator/contaminated_thicket/generate_terrain(list/turfs)
	var/height_seed = rand(0, 50000)

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/drift_x = (gen_turf.x + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom
		var/drift_y = (gen_turf.y + rand(-BIOME_RANDOM_SQUARE_DRIFT, BIOME_RANDOM_SQUARE_DRIFT)) / perlin_zoom

		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]"))

		var/datum/biome/selected_biome
		switch(height)
			if(0 to 0.3)
				selected_biome = /datum/biome/contaminated_thicket_lower
			if(0.3 to 0.85)
				selected_biome = /datum/biome/contaminated_thicket
			if(0.85 to 1) //if height is above 0.85, mountain rock.
				selected_biome = /datum/biome/mountain
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf)
		CHECK_TICK
	return ..()

///This type is responsible for any map generation behavior that is done in areas, override this to allow for area-specific map generation. This generation is ran by areas in initialize.
/datum/map_generator
	///Name for this map generator
	var/name = ""
	///Start time of the generator, used to display when it finishes
	var/start_time

///This proc will be ran by areas on Initialize, and provides the areas turfs as argument to allow for generation.
/datum/map_generator/proc/generate_terrain(list/turfs)
	start_time = REALTIMEOFDAY
	return

/datum/map_generator/proc/finish_generation()
	var/message = "[name] finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"))
	log_world(message)

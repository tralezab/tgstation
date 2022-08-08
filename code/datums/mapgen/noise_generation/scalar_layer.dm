///This datum returns a value from 0 to 1 based on provided values
/datum/generator_scalar_layer

///This proc should return a value between 0 to 1 based on the x and y
/datum/generator_scalar_layer/proc/get_scalar(x, y)
	return 0

///This datum returns a value from 0 to 1 using perlin noise
/datum/generator_scalar_layer/perlin_noise
	///The seed used for the perlin noise
	var/seed = 0
	///The level of zoom on the perlin noise
	var/perlin_zoom = 65


/datum/generator_scalar_layer/perlin_noise/New()
	. = ..()
	seed = rand(0, 50000)

/datum/generator_scalar_layer/perlin_noise/get_scalar(x, y)
	return text2num(rustg_noise_get_at_coordinates("[seed]", "[x / perlin_zoom]", "[y / perlin_zoom]"))

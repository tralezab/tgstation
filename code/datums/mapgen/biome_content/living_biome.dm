
//FLORA

///some like, ground tumor things that produce light.

/obj/structure/fluff/biome_tumor
	deconstructible = FALSE
	custom_materials = list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT)
	material_flags = MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS@
	desc = "some kind of glowing undulating growth on the biome, as if it is itself breathing steadily."
	icon = 'icons/obj/lavaland/biome/living_biome.dmi'
	icon_state = "tumor1"
	light_range = 8
	light_power = 0.5

/obj/structure/fluff/biome_tumor/Initialize(mapload)
	. = ..()
	pixel_x += rand(-6, 6)
	pixel_y += rand(-6, 6)
	icon_state = "tumor[rand(1,2)]"
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/fluff/biome_tumor/update_overlays()
	. = ..()
	var/static/mutable_appearance/tumor_light
	tumor_light = tumor_light || mutable_appearance('icons/obj/lavaland/biome/living_biome.dmi')
	tumor_light.icon_state = "[icon_state]_light"
	tumor_light.color = light_color
	add_overlay(tumor_light)

/obj/structure/fluff/biome_tumor/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/fluff/biome_tumor/orange
	name = "orange tumor"
	light_color = COLOR_ORANGE

/obj/structure/fluff/biome_tumor/green
	name = "green tumor"
	light_color = COLOR_LIME

///vent that occasionally spews deadly smoke.
/obj/structure/fluff/biome_vent

///vent that occasionally spews acid.
/obj/structure/fluff/biome_vent

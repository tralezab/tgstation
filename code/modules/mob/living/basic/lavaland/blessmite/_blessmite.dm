/mob/living/basic/blessmite
	name = "blessmite"
	desc = "A weak creature that relies on mutualism to survive. Chemically enhances other creatures, \
	and in return the creatures... don't squash them."
	icon = 'icons/mob/lavaland/blessmite.dmi'
	icon_state = "blessmite"
	icon_living = "blessmite"
	icon_dead = "blessmite_dead"
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_BUG
	maxHealth = 150
	health = 150
	verb_say = "spittles"
	verb_ask = "spittles questioningly"
	verb_exclaim = "splutters and gurgles"
	verb_yell = "splutters and gurgles"
	butcher_results = list(/obj/item/food/meat/slab/bugmeat = 4)
	guaranteed_butcher_results = list(
		/obj/effect/gibspawner/generic = 1,
		/obj/item/stack/sheet/animalhide/bileworm = 1,
	)

	//it can't be dragged, just butcher it
	move_resist = INFINITY
	//doesn't melee, at all.
	//or move normally.

	combat_mode = TRUE
	faction = list("mining")

	ai_controller = /datum/ai_controller/basic_controller/blessmite

/mob/living/basic/waxweaver/Initialize(mapload)
	. = ..()
	//traits and elements

	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/basic_body_temp_sensitive, max_body_temp = INFINITY)
	// AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/bileworm_spewlet, 15)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")

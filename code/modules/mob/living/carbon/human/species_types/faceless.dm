

// A punishment species for getting absorbed, someone who has completely lost their identity. Very sickly and frail.
/datum/species/faceless
	name = "Faceless"
	id = "faceless"
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/faceless
	species_traits = list(NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES)
	inherent_traits = list(TRAIT_BADDNA,TRAIT_GENELESS)
	mutanteyes = /obj/item/organ/eyes/faceless
	mutantbrain = /obj/item/organ/brain/faceless

/datum/species/faceless/on_species_gain(mob/living/carbon/new_faceless, datum/species/old_species, pref_load)
	. = ..()
	new_faceless.real_name = "Unknown"
	new_faceless.name = new_faceless.real_name
	SEND_SIGNAL(new_faceless, COMSIG_ADD_MOOD_EVENT, "faceless_moodlet_temp", /datum/mood_event/new_faceless)
	SEND_SIGNAL(new_faceless, COMSIG_ADD_MOOD_EVENT, "faceless_moodlet", /datum/mood_event/faceless)
	new_faceless.mind?.add_antag_datum(/datum/antagonist/faceless)

/datum/species/faceless/on_species_loss(mob/living/carbon/human/old_faceless, datum/species/new_species, pref_load)
	. = ..()
	SEND_SIGNAL(old_faceless, COMSIG_CLEAR_MOOD_EVENT, "faceless_moodlet_temp") //just in case? shit happens even if i'm trying to prevent species changing as much as possible
	SEND_SIGNAL(old_faceless, COMSIG_CLEAR_MOOD_EVENT, "faceless_moodlet")
	old_faceless.mind?.remove_antag_datum(/datum/antagonist/faceless)

/datum/species/faceless/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.on_fire)
		H.visible_message("<span class='danger'>[H] is reduced into a grey goopy mess!</span>")
		H.dust(just_ash = TRUE)
		new /obj/effect/decal/cleanable/molten_object/large(H.loc)
		return

	H.visible_message("<span class='danger'>[H] quickly degenerates into a grey goopy mess!</span>")
	H.gib(no_brain = TRUE, no_organs = TRUE, no_bodyparts = TRUE)
	new /obj/effect/decal/cleanable/molten_object/large(H.loc)
	..()

/obj/item/organ/brain/faceless
	name = "degenerating mass"
	desc = "A fleshy growth that maybe was a brain in a past life. It seems to not live long outside of the body."
	icon_state = "random_fly_4"

/obj/item/organ/brain/faceless/Remove(mob/living/carbon/M, special = 0)
	..()
	visible_message("<span class='danger'>[src] quickly turns into a hot goopy mess from exposure!</span>")
	new /obj/effect/decal/cleanable/molten_object(loc)
	qdel(src)

/obj/item/organ/eyes/faceless
	name = "fogged over eyes"
	desc = "These eyes are normally sunken deep behind layers of skin on the featureless faceless. They're sensitive to bright lights, despite their heavily fogged over look."
	flash_protect = FLASH_PROTECTION_SENSITIVE

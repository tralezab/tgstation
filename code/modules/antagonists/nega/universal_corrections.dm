
///debuffs applied to doppelgangers for existing in a world with their positive counterpart.
/datum/universal_correction
	///Name
	var/name = "Adminhelp this immediately"
	///short blurb describing what happened
	var/desc = "You feel like nothing happened... the universe is broken! Adminhelp this!"
	///what level of correction it is, aka how much of a whistleblower it is that the owner is negative. low level corrections are eye colors and other stuff, high level corrections are color inversions and more
	var/level = -1
	///attached mob that gets the effect
	var/mob/living/carbon/human/doppelganger

/datum/universal_correction/minor
	level = MINOR_CORRECTION

/datum/universal_correction/intermediate
	level = INTERMEDIATE_CORRECTION

/datum/universal_correction/major
	level = MAJOR_CORRECTION

/datum/universal_correction/New(mob/living/carbon/human/doppelganger)
	. = ..()
	src.doppelganger = doppelganger
	apply_effects()

/datum/universal_correction/proc/apply_effects()
	return

/datum/universal_correction/proc/grab_data()
	var/list/data = list()
	data["name"] = name
	data["desc"] = desc
	data["level"] = level
	return data

/datum/universal_correction/minor/stare
	name = "Corrected Stare"
	desc = "Your eyes are unnatural. You should cover them up, because they reveal what you really are!"

/datum/universal_correction/minor/stare/apply_effects()
	ADD_TRAIT(doppelganger, TRAIT_NEGATIVE_EYES, NEGATIVE_TRAIT)

/datum/universal_correction/intermediate/name
	name = "Corrected Name"
	desc = "Your identity has been rewritten into Jargon. Best not to speak now, and your face should be hidden."

/datum/universal_correction/intermediate/name/apply_effects()
	var/doppel_name = doppelganger.real_name
	var/new_doppel_name = reverse_text(doppel_name)
	doppelganger.fully_replace_character_name(doppel_name, new_doppel_name)

/datum/universal_correction/major/inverted_colors
	name = "Corrected Colors"
	desc = "You are entirely negative now. Only entire coverage will protect you from immediate detection!"

/datum/universal_correction/major/inverted_colors/apply_effects()
	ADD_TRAIT(doppelganger, TRAIT_INVERTED_COLORS, NEGATIVE_TRAIT)

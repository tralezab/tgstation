#define FOX_ORGAN_COLOR "#F0870A"
#define FOX_SCLERA_COLOR "#ffffff"
#define FOX_PUPIL_COLOR "#e9e066"
#define FOX_COLORS FOX_ORGAN_COLOR + FOX_SCLERA_COLOR + FOX_PUPIL_COLOR

/// Hard to hide ears, takes more damage, but lets you see other people's pockets.
/obj/item/organ/internal/ears/fox
	name = "fox ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2
	organ_traits = TRAIT_POCKET_PEEKER

/obj/item/organ/internal/ears/fox/Insert(mob/living/carbon/human/ear_owner, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = ear_owner.dna.species.mutant_bodyparts["ears"] = "Fox"
		ear_owner.dna.update_uf_block(DNA_EARS_BLOCK)
		ear_owner.update_body()

/obj/item/organ/internal/ears/fox/Remove(mob/living/carbon/human/ear_owner,  special = 0)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.species.mutant_bodyparts -= "ears"
		ear_owner.update_body()

/obj/item/organ/external/tail/fox
	name = "fox tail"
	desc = "I hear fox tails can be a bad omen. Certainly feels true when you see the tail removed from its owner..."
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fox
	sprite_accessory_override = /datum/sprite_accessory/tails/fox

///Cat tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/fox
	feature_key = "tail"
	color_source = ORGAN_COLOR_HAIR

#undef FOX_ORGAN_COLOR
#undef FOX_SCLERA_COLOR
#undef FOX_PUPIL_COLOR
#undef FOX_COLORS

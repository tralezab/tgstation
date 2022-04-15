/obj/item/bodypart/l_arm/bloody_lust
	icon_greyscale = 'icons/mob/species/bloody_lust/bodyparts.dmi'
	limb_id = BLOODY_LUST_LIMB
	dismemberable = FALSE
	can_be_disabled = FALSE
	var/obj/item/hand/haemomanic/claw

/obj/item/bodypart/l_arm/bloody_lust/attach_limb(mob/living/carbon/new_limb_owner, special)
	. = ..()
	claw = new
	new_limb_owner.put_in_l_hand(claw)

/obj/item/bodypart/r_arm/bloody_lust
	icon_greyscale = 'icons/mob/species/bloody_lust/bodyparts.dmi'
	limb_id = BLOODY_LUST_LIMB
	dismemberable = FALSE
	can_be_disabled = FALSE
	var/obj/item/hand/haemomanic/claw

/obj/item/bodypart/r_arm/bloody_lust/attach_limb(mob/living/carbon/new_limb_owner, special)
	. = ..()
	claw = new
	//new_limb_owner.put_in_r_hand(claw)

/obj/item/bodypart/head/bloody_lust
	icon_greyscale = 'icons/mob/species/bloody_lust/bodyparts.dmi'
	limb_id = BLOODY_LUST_LIMB
	dismemberable = FALSE
	can_be_disabled = FALSE
	is_dimorphic = FALSE

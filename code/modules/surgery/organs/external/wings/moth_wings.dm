///Moth wings! They can flutter in low-grav and burn off in heat
/obj/item/organ/external/wings/moth
	name = "moth wings"
	desc = "Spread your wings and FLOOOOAAAAAT!"

	preference = "feature_moth_wings"

	dna_block = DNA_MOTH_WINGS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/moth

/obj/item/organ/external/wings/moth/Initialize(mapload, mob_sprite)
	. = ..()
	AddComponent(/datum/component/burnable_wings, /datum/sprite_accessory/moth_wings/burnt_off)

/obj/item/organ/external/wings/moth/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	RegisterSignal(reciever, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_float_move))

/obj/item/organ/external/wings/moth/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()

	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_MOVABLE_PRE_MOVE))
	REMOVE_TRAIT(organ_owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

/obj/item/organ/external/wings/moth/can_soften_fall()
	return !(organ_flags & ORGAN_FAILING)

/datum/bodypart_overlay/mutant/wings/moth/get_global_feature_list()
	return GLOB.moth_wings_list

/datum/bodypart_overlay/mutant/wings/moth/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_suit?.flags_inv & HIDEMUTWINGS))
		return TRUE
	return FALSE

///Check if we can flutter around
/obj/item/organ/external/wings/moth/proc/update_float_move()
	SIGNAL_HANDLER

	if(!isspaceturf(owner.loc) && !(organ_flags & ORGAN_FAILING))
		var/datum/gas_mixture/current = owner.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			ADD_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))
			return

	REMOVE_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

/**
 * ## burnable wings component!
 *
 * component attached to wings, lets them be burned off and repaired later!
 * used for both functional and nonfunctional moth wings
 */
/datum/component/burnable_wings
	///Store our old datum here for if our burned wings are healed
	var/original_sprite_datum
	/// Path for the visuals of a burnt off wing! That shit don't work no more!
	var/burned_off_accessory_path

/datum/component/burnable_wings/Initialize(burned_off_accessory_path)
	if(!istype(parent, /obj/item/organ/external/wings))
		return COMPONENT_INCOMPATIBLE
	src.burned_off_accessory_path = burned_off_accessory_path

/datum/component/burnable_wings/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

/datum/component/burnable_wings/UnregisterFromParent()
	var/obj/item/organ/external/wings/parent_wings = parent
	UnregisterSignal(parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(parent_wings.owner)
		UnregisterSignal(parent_wings.owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL))

/datum/component/burnable_wings/proc/on_implanted(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	var/obj/item/organ/external/wings/parent_wings = parent
	RegisterSignal(parent_wings.owner, COMSIG_HUMAN_BURNING, PROC_REF(try_burn_wings))
	RegisterSignal(parent_wings.owner, COMSIG_ORGAN_FAILING_CHANGED, PROC_REF(on_organ_failing_changed))

/datum/component/burnable_wings/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER
	UnregisterSignal(loser, list(COMSIG_HUMAN_BURNING, COMSIG_ORGAN_FAILING_CHANGED))

///check if our wings can burn off ;_;
/datum/component/burnable_wings/proc/try_burn_wings(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	var/obj/item/organ/external/wings/parent_wings = parent
	if(!(organ_flags & ORGAN_FAILING) && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious wings burn to a crisp!"))
		human.add_mood_event("burnt_wings", /datum/mood_event/burnt_wings)

		burn_wings()
		human.update_body_parts()

///burn the wings off
/datum/component/burnable_wings/proc/burn_wings()
	var/obj/item/organ/external/wings/parent_wings = parent
	parent_wings.setOrganDamage(parent_wings.maxHealth)

	original_sprite_datum = parent_wings.sprite_datum
	parent_wings.simple_change_sprite(burned_off_accessory_path)

///heal our wings back up!!
/datum/component/burnable_wings/proc/on_organ_failing_changed(datum/source, is_failing)
	SIGNAL_HANDLER

	var/obj/item/organ/external/wings/parent_wings = parent
	

	if(heal_flags & (HEAL_LIMBS|HEAL_ORGANS))
		parent_wings.setOrganDamage(0)
		parent_wings.simple_change_sprite(original_sprite_datum)

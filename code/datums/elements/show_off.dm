/**
 * ## show off element!
 *
 * element that spawn lets spessmen show off an item when they interact with it.
 * Used for badges, medals, etc
 */
/datum/element/show_off
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///callback for special behavior when showing off
	var/datum/callback/on_show_off_callback

/datum/element/show_off/Attach(datum/target, on_show_off_callback)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.on_show_off_callback = on_show_off_callback
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))

/datum/element/show_off/Detach(obj/item/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_ATTACK_SELF)

///Signal fired when someone holding an item interacts with it.
/datum/element/show_off/proc/on_attack_self(obj/item/target, mob/user)
	user.visible_message(span_notice("[user] shows [user.p_their()] [target]."), span_notice("You show your [target]."))
	on_show_off_callback?.Invoke(mob/user)

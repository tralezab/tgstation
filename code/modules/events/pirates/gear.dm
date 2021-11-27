/obj/item/grappling_hook
	name = "grappling hook"
	desc = "an aged oldworld tool for traversing dangerous terrain."
	slot_flags = ITEM_SLOT_BELT
	///boolean set by movements of the holder that show whether the grappling hook can be used.
	var/can_grapple
	///the lower link of the rope ladder
	var/obj/structure/ladder/grappling_rope/lower_rope
	///the upper link of the rope ladder
	var/obj/structure/ladder/grappling_rope/upper_rope

/obj/item/grappling_hook/Initialize(mapload)
	. = ..()
	//contain the ropes inside of ourselves
	lower_rope = new(src)
	upper_rope = new(src)

/obj/item/grappling_hook/Destroy()
	if(lower_rope)
		QDEL_NULL(lower_rope)
	if(upper_rope)
		QDEL_NULL(upper_rope)
	. = ..()

/obj/item/grappling_hook/examine(mob/user)
	. = ..()
	. += span_notice("It has a light that reacts to the space above it, indicating when it is possible to use.")
	. += "[span_notice("It is currently")] [span_boldnotice(can_grapple ? "on" : "off")][span_notice(".")]")

/obj/item/grappling_hook/pickup(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/mob_moved)

/obj/item/grappling_hook/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/grappling_hook/proc/mob_moved(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	check_grappability()

/obj/item/grappling_hook/Moved(atom/OldLoc, Dir)
	. = ..()
	check_grappability()

/obj/item/grappling_hook/proc/check_grappability()
	//proc will find the destination based off of direction
	var/result = can_zTravel(null, UP)
	if(result != can_grapple && result)
		audible_message(span_notice("[src] makes a noise."))
		playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
	update_overlays()

/obj/item/grappling_hook/update_overlays()
	. = ..()
	var/static/image/on_overlay
	if(isnull(on_overlay))
		on_overlay = iconstate2appearance(icon, "growing_vat_on")
	if(can_grapple)
		. += on_overlay

/obj/structure/ladder/grappling_rope
	name = "grappling rope"
	desc = "rope from a grappling hook."
	///instance to the beam that we will clean up when the rope ladder isn't set up
	var/datum/beam/hook_connection

/obj/structure/ladder/grappling_rope/Initialize(mapload, obj/structure/ladder/up, obj/structure/ladder/down, obj/item/grappling_hook/hook)
	. = ..()
	hook_connection = Beam(hook, icon_state="rope")


	///The flight action object
	var/datum/action/innate/flight/fly

///hud action for starting and stopping flight
/datum/action/cooldown/glare
	name = "Glare"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "glare"
	cooldown_time = 30 SECONDS

/datum/action/innate/glare/Activate()


/obj/effect/proc_holder/spell/targeted/glare/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		if(!ishuman(target))
			user << "<span class='warning'>You may only glare at humans!</span>"
			revert_cast()
			return
		if(!shadowling_check(user))
			revert_cast()
			return
		if(target.stat)
			user << "<span class='warning'>[target] must be conscious!</span>"
			revert_cast()
			return
		if(is_shadow_or_thrall(target))
			user << "<span class='warning'>You cannot glare at allies!</span>"
			revert_cast()
			return
		var/mob/living/L = user
		if(L.incorporeal_move) //Other abilities can still be used, but glare needed balancing
			user << "<span class='warning'>You cannot glare while shadow walking!</span>"
			revert_cast()
			return
		var/mob/living/carbon/human/M = target
		user.visible_message("<span class='warning'><b>[user]'s eyes flash a blinding red!</b></span>")
		target.visible_message("<span class='danger'>[target] freezes in place, their eyes glazing over...</span>")
		if(in_range(target, user))
			target << "<span class='userdanger'>Your gaze is forcibly drawn into [user]'s eyes, and you are mesmerized by the heavenly lights...</span>"
		else //Only alludes to the shadowling if the target is close by
			target << "<span class='userdanger'>Red lights suddenly dance in your vision, and you are mesmerized by their heavenly beauty...</span>"
		target.Stun(10)
		M.silent += 10

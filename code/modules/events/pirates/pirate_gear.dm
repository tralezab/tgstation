/obj/item/grappling_hook
	name = "grappling hook"
	desc = "an aged oldworld tool for traversing dangerous terrain. "
	///boolean set by movements of the holder that show whether the grappling hook can be used.
	var/can_grapple
	///
	var/grapple_rope

/obj/item/grappling_hook/examine(mob/user)
	. = ..()
	. += span_notice("It has a light that reacts to the space above it, indicating when it is possible to use.")
	. += "[span_notice("It is currently")] [span_boldnotice(can_grapple ? "on" : "off")][span_notice(".")]")

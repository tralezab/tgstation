///how much candy the bowl starts with
#define INITIAL_CANDY_AMOUNT 30

///candybowl! for trick or treaters on this fine spookoween night
/obj/item/candybowl
	name = "candy bowl"
	desc = "Only the most malevolent and evil forces of the would would take more than one."
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "candy_bowl"

/obj/item/candybowl/Initialize(mapload)
	. = ..()
	for(var/iteration in 1 to INITIAL_CANDY_AMOUNT)
		var/type = pick(
			/obj/item/food/cookie/sugar/spookyskull,
			/obj/item/food/cookie/sugar/spookycoffin,
			/obj/item/food/candy_corn,
			/obj/item/food/candy,
			/obj/item/food/candiedapple,
			/obj/item/food/chocolatebar,
		)
		new type(src)

/obj/item/candybowl/attack_hand(mob/user, list/modifiers, attempting_to_pickup = FALSE)
	if(attempting_to_pickup)
		return ..()
	if(!ishuman(user))
		to_chat(user, span_warning("The candy is for trick or treaters ONLY!"))
		return
	var/mob/living/carbon/human/trick_or_treater = user
	if(!contents.len)
		balloon_alert(user, "it's empty!")
		return
	var/obj/item/grabbed = pick(contents)
	if(!trick_or_treater.put_in_hands(grabbed, del_on_fail = FALSE))
		grabbed.forceMove(src)//failed to take candy so get your ass back in there
		balloon_alert(user, "you can't get any candy!")
	balloon_alert(user, "grabbed a [grabbed]")

/obj/item/candybowl/attack_hand_secondary(mob/user, list/modifiers)
	attack_hand(user, modifiers, attempting_to_pickup = TRUE)

/obj/item/candybowl/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!isturf(over))
		return
	if(!contents.len)
		balloon_alert(usr, "it's empty!")
		return
	visible_message(span_danger("[usr] begins to dump [src]..."))
	if(!do_after_mob(usr, src, 5 SECONDS))
		return
	visible_message(span_danger("[usr] dumps [src]!"))
	for(var/obj/item/candy_probably in src)
		candy_probably.forceMove(over)
		if(prob(90))
			step(candy_probably, pick(GLOB.alldirs))

/obj/item/candybowl/attackby(obj/item/add_it, mob/living/user, params)
	. = ..()
	if(contents.len >= INITIAL_CANDY_AMOUNT)
		balloon_alert(user, "it's full!")
		return
	if(!user.transferItemToLoc(add_it, src))
		balloon_alert(user, "[add_it] is stuck to you!")

/obj/effect/mapping_helpers/candybowl_location

/obj/effect/mapping_helpers/candybowl_location/LateInitialize()
	if(locate(/datum/holiday/halloween) in SSevents.holidays)
		var/turf/candybowl_turf = get_turf(src)
		new /obj/structure/table(candybowl_turf)
		new /obj/item/candybowl(candybowl_turf)
	qdel(src)

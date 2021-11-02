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
	name = "Halloween Candy Bowl Placement"
	late = TRUE
	icon_state = "candybowl"

/obj/effect/mapping_helpers/candybowl_location/LateInitialize()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		var/turf/candybowl_turf = get_turf(src)
		if(!locate(/obj/structure/table) in candybowl_turf)
			new /obj/structure/table(candybowl_turf)
		new /obj/item/candybowl(candybowl_turf)
	qdel(src)

/obj/item/storage/spooky
	name = "trick-o-treat bag"
	desc = "A pumpkin-shaped bag that holds all sorts of goodies!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "treatbag"
	component_type = /datum/component/storage/concrete/spooky
	///ckey of the person who originally spawned with this, given on the trick or treat outfit. only they are allowed to take candy out!
	var/rightful_owner

/datum/component/storage/concrete/spooky
	can_hold = list(
		/obj/item/food/cookie/sugar/spookyskull,
		/obj/item/food/cookie/sugar/spookycoffin,
		/obj/item/food/candy_corn,
		/obj/item/food/candy,
		/obj/item/food/candiedapple,
		/obj/item/food/chocolatebar,
	)
	max_items = INFINITY
	max_combined_w_class = INFINITY
	can_hold_description = "candy"

/datum/component/storage/concrete/spooky/remove_from_storage(atom/movable/removed_candy, atom/new_location)
	var/client/usr_client = usr
	if(usr_client.ckey != rightful_owner)
		to_chat(usr, span_notice("you can't just steal candy from someone else's bag! That's beyond fucked up."))
		return
	. = ..()



//living flesh
//book
//research (support) helps other traitors and sometimes the virago itself- witch's brew (healing drink)|stitch limb (add hand)|totem of storms (totem that makes one area have a rad storm until totem is destroyed)
//research (chaos) just completely disruptive, to help traitors get heat off of them - totem of chaos (events)|empower spirit (revenant)|

#define CENTER "center"

/datum/curse
	var/keyword
	var/mob/living/curser
	var/find_victim = FALSE //if true, it will make someone in the ritual who isn't the curser the curser. no matter if it replaces or not, the curse will still go on the curser.
	var/objective_count = TRUE //some basic rituals do not count towards the ritual completion objective.
	var/complete = 0 //not a boolean
	var/list/items_required = list()//example of a curse that requires a book to the south of the casting spot: /obj/item/book = SOUTH (set it to null for the caster, CENTER for the turf below the caster, and a number for it to search a range for the item.")
	var/list/victims = list()

/datum/curse/proc/curse_startup()
	var/delete_list = list()
	for(var/i in items_required)
		var/atom/thing_to_search
		if(items_required[i]) //gross, any better ideas
			if(items_required[i] in GLOB.alldirs)
				thing_to_search = get_step(get_turf(curser), items_required[i])
			else if(items_required[i] == CENTER)
				thing_to_search = get_turf(curser)
			else if(isnum(items_required[i]))
				thing_to_search = items_required[i]
		else
			thing_to_search = curser
		to_chat(world, "thing to search = [thing_to_search ? "[thing_to_search]" : "NULL"]") //thing_to_search is still being set to null, so...
		var/atom/item = item_check(i, thing_to_search)
		if(!item)
			items_required = initial(items_required)
			return FALSE
		delete_list += item
	curse_effect()
	complete++
	for(var/atom/ii in delete_list)
		QDEL_NULL(ii)//qdel gives bad del? QDEL_NULL isn't doing it but isn't giving a runtime either, hmmmm
	return TRUE

/datum/curse/proc/item_check(item, thing_to_search)
	. = FALSE
	if(isnum(thing_to_search))
		if(item in orange(thing_to_search,curser))
			. = TRUE
	else
		if(locate(item) in thing_to_search)
			. = TRUE

/datum/curse/proc/curse_effect()
 return

//Basics - every virago gets this.

/datum/curse/summon_book //helping manual, keeps track of which rituals you know, which ones you need to know
	keyword = "name the darkness"
	objective_count = FALSE
	items_required = list(/obj/item/book)

/datum/curse/summon_book/curse_effect()
	var/obj/item/B = new /obj/item/book/viragobook(get_turf(curser))
	var/in_hand = curser.put_in_hands(B)
	to_chat(curser, "<span class='warning'>[B] appears [in_hand ? "in your hand" : "at your feet"]!</span>")

/datum/curse/universal_flesh //turns flesh into a universal ingredient in rituals
	keyword = "repurpose the flesh"
	objective_count = FALSE
	items_required = list(/obj/item/reagent_containers/food/snacks/meat/slab/human)

/datum/curse/universal_flesh/curse_effect()
	var/obj/item/B = new /obj/item/book/viragobook(get_turf(curser))
	var/in_hand = curser.put_in_hands(B)
	to_chat(curser, "<span class='warning'>[B] appears [in_hand ? "in your hand" : "at your feet"]!</span>")

//Utility - the virago can research down this path to help traitors through other miscellaneous ways.

/datum/curse/magic_mirror
	keyword = "pass the reflection"
	items_required = list(/obj/structure/mirror)//not included = the mirror, it's a structure and we don't really care where it is.

/datum/curse/magic_mirror/curse_effect()
	var/obj/item/B = new /obj/item/book/viragobook(get_turf(curser))
	var/in_hand = curser.put_in_hands(B)
	to_chat(curser, "<span class='warning'>[B] appears [in_hand ? "in your hand" : "at your feet"]!</span>")

/datum/curse/mulligan
	keyword = "twist the appearance"
	find_victim = TRUE
	items_required = list(/obj/item/candle = EAST, /obj/item/reagent_containers/food/snacks/meat/slab/virago, /obj/item/candle = WEST)//flesh add that in curser

/datum/curse/mulligan/curse_effect()
	curser.reagents.add_reagent("mulligan",1)

//Enhancement - the virago can research down this path to help traitors directly (healing, buffs, etc)

//Chaos - the virago can research down this path to help traitors through complete chaos and other distractions.

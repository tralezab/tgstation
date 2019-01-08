////mutamorph egg////

/obj/effect/mob_spawn/mutamorph
	name = "mutamorph egg"
	desc = "A mutamorph egg. It looks like it could hatch at any moment, it would be wise to immediately crush this."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_unactivated"
	density = FALSE
	anchored = FALSE

	mob_type = /mob/living/simple_animal/hostile/mutamorph
	mob_name = "a mutamorph"
	death = FALSE
	roundstart = FALSE
	flavour_text = {"
	<b>You are a mutamorph, a bioweapon that has escaped from it's containment. No allegiance but to the mutamorph combine. We fight. We kill. We evolve.</b>
	<b>Each mutamorph is created with a unique adaptation it grants to other mutamorphs around it. With that in mind, stick together.</b>
	"}

/obj/effect/mob_spawn/mutamorph/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A mutamorph egg has been created in [A.name].", 'sound/effects/bin_close.ogg', source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/mutamorph/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.visible_message("<span class='warning'>[usr.name] splats [src]!</span>",
		"<span class='notice'>You splat [src]!</span>",
		"<span class='italics'>You hear squelching.</span>")
	qdel(src)

/obj/effect/mob_spawn/mutamorph/attackby(obj/item/W, mob/user, params)
	user.visible_message("<span class='warning'>[usr.name] splats [src] with [W]!</span>",
		"<span class='notice'>You splat [src] with [W]!</span>",
		"<span class='italics'>You hear squelching.</span>")
	qdel(src)

////The Mob itself////

/mob/living/simple_animal/hostile/mutamorph
	name = "mutamorph"
	desc = "An odd looking creature. It looks very hungry."
	speak_emote = list("growls")
	mob_biotypes = list(MOB_ORGANIC)
	health = 40
	maxHealth = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	var/bites_needed = 3 //mutamorph bites needed to be able to drop an egg
	var/bites = 0 //goes up when you consume food, or
	var/my_adaptation //the unique adaptation only you have
	var/list/current_adaptations = list() //your adaptation plus every adaptation you have taken from local mutamorphs

/mob/living/simple_animal/hostile/mutamorph/Initialize()

/mob/living/simple_animal/hostile/mutamorph/Life()
	..()
	if(!my_adaptation)
		return
	var/list/found_adaptations = list()
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if(!ismuta(M))
			continue
		var/mob/living/simple_animal/hostile/mutamorph/muta = M
		if(get_dist(get_turf(src),get_turf(muta)) > 7)
			continue
		if(muta.stat == DEAD || !muta.my_adaptation)
			continue
		found_adaptations += muta.my_adaptation
	if(found_adaptations ~! current_adaptations)
		update_adaptations(found_adaptations)

/mob/living/simple_animal/hostile/mutamorph/proc/update_adaptations(list/new_adaptations) //clears the old buffs, and applies new ones. adds and removes overlays
	to_chat(src, "<span class='notice'>The number of mutamorphs around you have changed! You feel yourself adapting rapidly!</span>")
	current_adaptations = initial(current_adaptations)
	var/list/adapts_to_remove = list()
	var/list/adapts_to_add = list()
	for(var/old in current_adaptations)      //searches the new adaptation list for one we already have
		if(!new_adaptations.Find(old))       //if it can't find the adaptation, we need to remove it.
			adapts_to_remove += old
	for(var/found in new_adaptations)        //searches the old adaptation list for the ones we have just found
		if(!current_adaptations.Find(found)) //if we didn't own the adaptation, we need to add it.
			adapts_to_add += found
	switch(adapts_to_remove)
		if(ADAPT_DAMAGE)
			to_chat(src, "<span class='warning'>Your teeth recede back into your skull...</span>")
			melee_damage_lower -= 10
			melee_damage_upper -= 10
		//if(ADAPT_SPIT)
		if(ADAPT_MAGICPROOF)
			to_chat(src, "<span class='warning'>Your antimagic coating chips away...</span>")
			remove_trait(TRAIT_ANTIMAGIC, "mutamorph")
	switch(adapts_to_add)
		if(ADAPT_DAMAGE)
			to_chat(src, "<span class='nicegreen'>Sharp teeth jut out from your skull!</span>")
			melee_damage_lower += 10
			melee_damage_upper += 10
		//if(ADAPT_SPIT)
		if(ADAPT_MAGICPROOF)
			to_chat(src, "<span class='nicegreen'>Your Wings produce an antimagic coating!</span>")
			add_trait(TRAIT_ANTIMAGIC, "mutamorph")

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster
	name = "Terror of the Tracks"
	desc = "Abomination made from low park ratings. Yes, you ride this!"
	can_buckle = TRUE
	buckle_lying = FALSE
	var/running = FALSE // if armsy is running through the rollercoaster track or at the station

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/Initialize(mapload,spawn_more = TRUE,len = 6)
	. = ..()
	allow_pulling = FALSE
	LoadComponent(/datum/component/riding)

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/gib_trail()
	return//be kind armsy

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/proc/check_ready()
	if(front)
		front.check_ready()//pass it forward, only the very head will start the check
		return
	if(running)
		return
	if(buckled_mobs.len)
		back.rider_present()

//checks if they have a buckled passenger, if so asks the back. if it IS the back, sends forward a proc saying the rollercoaster is all ready to go!
/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/proc/rider_present()
	if(buckled_mobs.len)
		if(back)
			back.rider_present()
		else
			front.good_to_go()

//when the rollercoaster is full of people and at the station. begins the ride, or passes it up to the front if it's not the front!
/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/proc/good_to_go()
	if(front)
		front.good_to_go()
		return
	running = TRUE
	step(src,dir)

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/proc/ask_the_track()
	if(front)
		return
	to_chat(world, "asking_the_track")
	var/obj/structure/rollercoaster_track/track = locate(/obj/structure/rollercoaster_track) in loc.contents
	if(track)
		track.guide_armsy(src)

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/Moved()
	. = ..()
	if(front)
		return
	ask_the_track()

/mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/proc/end_ride()
	unbuckle_all_mobs()
	if(!front)
		running = FALSE
	if(back)
		back.end_ride()

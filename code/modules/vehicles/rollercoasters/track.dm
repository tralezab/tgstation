/obj/structure/rollercoaster_track
	name = "track"
	desc = "They're just suggestions to Armsy, but Armsy is really down on rough times and so wouldn't dare go off the tracks."
	icon_state = "stairs_t"
	icon = 'icons/obj/stairs.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	var/this_track_speed = 3

/obj/structure/rollercoaster_track/proc/guide_armsy(mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/coaster)
	addtimer(CALLBACK(src, .proc/let_armsy_go, coaster), this_track_speed)

/obj/structure/rollercoaster_track/proc/let_armsy_go(mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/coaster)
	step(coaster,dir)

/obj/structure/rollercoaster_track/faster
	this_track_speed = 1

/obj/structure/rollercoaster_track/slower
	this_track_speed = 6

//doesn't stop the track, just slows it a lot
/obj/structure/rollercoaster_track/station
	name = "station track"
	this_track_speed = 8
	color = "blue"

//this is the very front of the station aka where they should be to unload
/obj/structure/rollercoaster_track/station/head
	name = "station ending track"
	color = "red"

/obj/structure/rollercoaster_track/station/head/guide_armsy(mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/coaster)
	coaster.end_ride()

/*
//slow, but because of the lift not just running out of speed
/obj/structure/rollercoaster_track/chain_lift
	this_track_speed = 6

/obj/structure/rollercoaster_track/chain_lift/guide_armsy(mob/living/simple_animal/hostile/eldritch/armsy/rollercoaster/coaster)
	..()
	coaster()
*/

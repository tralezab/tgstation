/obj/structure/sacrificealtar
	name = "sacrificial altar"
	desc = "An altar designed to perform blood sacrifice for a deity."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	anchored = TRUE
	density = FALSE
	can_buckle = 1

/obj/structure/sacrificealtar/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!has_buckled_mobs())
		return
	var/mob/living/L = locate() in buckled_mobs
	if(!L)
		return
	to_chat(user, "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual.</span>")
	L.gib()
	message_admins("[ADMIN_LOOKUPFLW(user)] has sacrificed [key_name_admin(L)] on the sacrificial altar at [AREACOORD(src)].")

/obj/structure/healingfountain
	name = "healing fountain"
	desc = "A fountain containing the waters of life."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	anchored = TRUE
	density = TRUE
	var/time_between_uses = 1800
	var/last_process = 0

/obj/structure/healingfountain/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(last_process + time_between_uses > world.time)
		to_chat(user, "<span class='notice'>The fountain appears to be empty.</span>")
		return
	last_process = world.time
	to_chat(user, "<span class='notice'>The water feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards.</span>")
	user.reagents.add_reagent("godblood",20)
	update_icon()
	addtimer(CALLBACK(src, .proc/update_icon), time_between_uses)


/obj/structure/healingfountain/update_icon()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-red"

/obj/structure/heroicshrine
	name = "shrine of heroics"
	desc = "The shrine of Tiket-Rasolve, an old god decimated by Nar'sie. It now holds minor domain in lavaland. \"Heroes of old, arise!\""
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	anchored = TRUE
	density = TRUE
	var/used = FALSE
	var/cooldown = 0

/obj/structure/heroicshrine/Initialize()
	..()
	desc = "The shrine of Tiket-Rasolve, an old god decimated by Nar'sie. It now holds minor domain in lavaland. \"Heroes of [station_name()], arise!\""

/obj/structure/heroicshrine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	if(used)
		to_chat(user, "<span class='warning'>The shrine is broken...</span>")
		return
	if(cooldown > world.time)
		to_chat(user, "<span class='notice'>You touch the shrine but nothing happens! Maybe try again later?</span>")
		return
	for(var/mob/Player in GLOB.mob_list)
		if(Player.mind && Player.stat != DEAD && !isnewplayer(Player) && !isbrain(Player) && Player.client)
			living_crew += Player
	var/list/living_crew = list()
	if(living_crew.len / GLOB.joined_player_list.len >= 25)
		to_chat(user, "<span class='bold'>\"Come back when all hope seems lost.\"</span>")
		cooldown = world.time + 3 MINUTES//kind of an intense calculation so lets have a cooldown
		return
	visible_message("<span class='notice'>[src] breaks apart in a blazing light!</span>")
	var/hero = pick("Medium", "Mascot", "Sawbones")
	var/datum/job/J = SSjob.GetJob(hero)
		if(!J)
		return
	J.total_positions++
	to_chat(user, "<span class='bold'>\"You have sought me out in your time of need. I have summoned a [hero] to help.\"</span>")
	used = TRUE
	

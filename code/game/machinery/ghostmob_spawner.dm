
/obj/machinery/spawner
	name = "Syndicate gateway"
	desc = "A gateway used by the Syndicate to bring in extra muscle."
	anchored = TRUE
	density = TRUE
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "mob_teleporter_on"
	light_range = 5
	light_color = LIGHT_COLOR_CYAN
	max_integrity = 200
	obj_integrity = 200
	verb_say = "states coldly"
	var/cooldown = 3000
	var/datum/team/custom/Team
	var/password = ""
	var/directive = "Protect the Gateway and follow all orders from the Traitors in your group - no matter the cost!"
	var/corporation = "Syndicate" //used for polling ghosts

	//you know, what the teleporters give you//
	var/mob/living/simple_animal/ranged_light = /mob/living/simple_animal/hostile/syndicate/ranged/reinforcement
	var/mob/living/simple_animal/ranged_heavy = /mob/living/simple_animal/hostile/syndicate/ranged/smg
	var/mob/living/simple_animal/melee_light = /mob/living/simple_animal/hostile/syndicate/melee/reinforcement
	var/mob/living/simple_animal/melee_heavy = /mob/living/simple_animal/hostile/syndicate/melee/sword

/obj/machinery/spawner/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/reinforce), 50)
	password = num2text(rand(1000,9999))
	visible_message("<span class='boldwarning'>The password is [password]. Your allies may enter this number to identify as friendly to your reinforcements!</span>")

/obj/machinery/spawner/ui_interact(mob/living/user)
	if(Team && (user.stat == CONSCIOUS))
		var/datum/mind/M = user.mind
		if(M in Team.members)
			var/command = stripped_input(user,"Enter a new Directive for the reinforcements to obey:", " New Directive", "")
			if(length(command)>1)
				directive = command
				say("New directive confirmed: [directive]")
		else
			var/guess = stripped_input(user,"Enter the password:", "Password", "")
			if(guess == password)
				Team.add_member(M)
				playsound(src, 'sound/machines/chime.ogg', 30, 1)
				say("Success! [user], you are now an official member of [Team.name]")
			else
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)



/obj/machinery/spawner/proc/reinforce(var/repeat = TRUE)
	if(!QDELETED(src))
		light_color = LIGHT_COLOR_RED
		icon_state = "mob_teleporter_active"
		update_light()
		var/list/mob/dead/observer/finalists = pollGhostCandidates("Would you like to be a [corporation] reinforcement?", ROLE_TRAITOR, null, ROLE_TRAITOR, 100, POLL_IGNORE_SYNDICATE)
		if(LAZYLEN(finalists) && !QDELETED(src))
			var/mob/living/simple_animal/S
			var/mob/dead/observer/winner = pick(finalists)
			if(prob(50))
				if(prob(4))
					S = new /mob/living/simple_animal/hostile/syndicate/ranged/smg(get_turf(src))
				else
					S = new /mob/living/simple_animal/hostile/syndicate/ranged/reinforcement(get_turf(src))
			else
				if(prob(10))
					S = new /mob/living/simple_animal/hostile/syndicate/melee/sword(get_turf(src))
				else
					S = new /mob/living/simple_animal/hostile/syndicate/melee/reinforcement(get_turf(src))
			S.key = winner.key
			if(Team)
				Team.add_member(S.mind)
			to_chat(S, "<span class='boldwarning'>Obey the following directive: <u>[directive]</u>")
			do_sparks(4, TRUE, src)
		if(repeat)
			light_color = initial(light_color)
			icon_state = "mob_teleporter_on"
			update_light()
			cooldown = max(600, cooldown - 300)
			addtimer(CALLBACK(src, .proc/reinforce), cooldown, TIMER_UNIQUE)

/obj/machinery/spawner/clown
	name = "Hilarious gateway"
	desc = "A gateway used by the Clown Federation to bring in the punchline."
	icon_state = "mob_teleporter_on_clown"
	light_color = LIGHT_COLOR_PINK
	verb_say = "honks"
	directive = "Protect the Gateway and work with the Traitors in your group to bring the station the killing joke!"
	corporation = "Clown Federation"
	ranged_light = /mob/living/simple_animal/hostile/syndicate/ranged/reinforcement/clown
	ranged_heavy = /mob/living/simple_animal/hostile/syndicate/ranged/smg/clown
	melee_light = /mob/living/simple_animal/hostile/syndicate/melee/reinforcement/clown
	melee_heavy = /mob/living/simple_animal/hostile/syndicate/melee/sword/clown

/obj/machinery/spawner/clown/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/reinforce), 50)
	password += num2text(rand(1000,9999))
	visible_message("<span class='boldwarning'>A horse walks into a bar, and the bartender asks, \"Why are you late, agent? The password is [password]. Your allies may enter this number to identify as friendly to your reinforcements!\"</span>") //a hearty twist on a classic

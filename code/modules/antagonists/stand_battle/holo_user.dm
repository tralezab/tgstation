#define STYLE_PROFESSIONAL	"professional"//suits, job outfits, lab coats.
#define STYLE_LAID_BACK 		"laid back"   //colorful jumpsuits with a hat
#define STYLE_CRAZY 				"crazy"       //any assortment of clothing

/datum/antagonist/holo_user
	name = "Holoparasite user"
	roundend_category = "holoparasite user" //just in case
	//antagpanel_category = "NukeOp"
	//job_rank = ROLE_OPERATIVE
	show_in_antagpanel = FALSE
	var/datum/team/holo_team/team

/datum/antagonist/holo_user/create_team(datum/team/holo_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/holo_user/greet()
	var/list/holoparasite = owner.hasparasites()
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role] of [holoparasite[1]].</font></B>")
	to_chat(owner.current, "You must find the power in yourself if you are to work for the syndicate. Grow your stand and eliminate all of the others to win!")
	to_chat(owner.current, "Cooperation is allowed, but remember that only one team gets to leave.")
	owner.announce_objectives()

/datum/antagonist/holo_user/apply_innate_effects(mob/living/mob_override)
	SSticker.mode.update_holo_icons_added(owner)//see mind.dm and add remove_holo

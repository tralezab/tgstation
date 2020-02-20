/datum/team/defenders
	name = "Defenders"
	show_roundend_report = FALSE

/datum/antagonist/defender
	name = "Mining Defender"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Ash Walkers"
	var/datum/team/ashwalkers/defender_team

/datum/antagonist/defender/create_team(datum/team/team)
	if(team)
		defender_team = team
		objectives |= defender_team.objectives
	else
		defender_team = new

/datum/antagonist/defender/get_team()
	return defender_team

/datum/antagonist/defender/on_body_transfer(mob/living/old_body, mob/living/new_body)
	UnregisterSignal(old_body, COMSIG_MOB_EXAMINATE)
	RegisterSignal(new_body, COMSIG_MOB_EXAMINATE, .proc/on_examinate)

/datum/antagonist/defender/on_gain()
	RegisterSignal(owner.current, COMSIG_MOB_EXAMINATE, .proc/on_examinate)

/datum/antagonist/defender/on_removal()
	UnregisterSignal(owner.current, COMSIG_MOB_EXAMINATE)

/datum/antagonist/defender/proc/on_examinate(datum/source, atom/A)
	if(istype(A, /obj/structure/headpike))
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_good)

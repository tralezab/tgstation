/datum/game_mode
	var/list/datum/mind/brothers = list()
	var/list/datum/team/brother_team/brother_teams = list()

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	restricted_jobs = list("AI", "Cyborg")

	announce_span = "danger"
	announce_text = "There are Syndicate agents and Blood Brothers on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='danger'>Blood Brothers</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors or brothers succeed!"

	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2
	traitors_required = FALSE //Only teams are possible

/datum/game_mode/traitor/bros/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/list/datum/mind/possible_brothers = get_players_for_role(ROLE_BROTHER)

	var/num_teams = team_amount
	var/bsc = CONFIG_GET(number/brother_scaling_coeff)
	if(bsc)
		num_teams = max(1, round(num_players() / bsc))

	for(var/j = 1 to num_teams)
		if(possible_brothers.len < min_team_size || antag_candidates.len <= required_enemies)
			break
		var/datum/team/brother_team/team = new
		var/team_size = prob(10) ? min(3, possible_brothers.len) : 2
		for(var/k = 1 to team_size)
			var/datum/mind/bro = antag_pick(possible_brothers)
			possible_brothers -= bro
			antag_candidates -= bro
			team.add_member(bro)
			bro.special_role = "brother"
			bro.restricted_roles = restricted_jobs
			log_game("[key_name(bro)] has been selected as a Brother")
		pre_brother_teams += team
	return ..()

/datum/game_mode/traitor/bros/post_setup()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
		team.update_name()
	brother_teams += pre_brother_teams
	return ..()

/datum/game_mode/traitor/bros/generate_report()
	return "It's Syndicate recruiting season. Be alert for potential Syndicate infiltrators, but also watch out for disgruntled employees trying to defect. Unlike Nanotrasen, the Syndicate prides itself in teamwork and will only recruit pairs that share a brotherly trust."

/datum/game_mode/proc/update_brother_icons_added(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.join_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, "brother")

/datum/game_mode/proc/update_brother_icons_removed(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.leave_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, null)

///////////////////////stand royale

/datum/game_mode
	var/list/datum/mind/users = list()
	var/list/datum/team/holo_team/holo_teams = list()

/datum/game_mode/stand_battles
	name = "stand battles"
	config_tag = "traitorbro"
	restricted_jobs = list("AI", "Cyborg")

	announce_span = "danger"
	announce_text = "Everyone is fighting to become a gang star!\n\
	<span class='danger'>Holoparasite users</span>: Find items to power up your holoparasite!\n\
	<span class='danger'>Holoparasites</span>: Defend your user and defeat other users!\n\

	var/list/datum/team/holo_team/pre_holo_teams = list()
	var/const/min_team_size = 2
	traitors_required = FALSE //Only teams are possible

/datum/game_mode/stand_battles/pre_setup()
	//every job gets picked.

	var/list/datum/mind/stands_and_users_to_team = get_players_for_role(ROLE_BROTHER)//ROLE_HOLO)

	while(stands_and_users_to_team.len > 0)
		if(possible_brothers.len < min_team_size || antag_candidates.len <= required_enemies)
			var/datum/mind/ripple_user = pick_n_take(stands_and_users_to_team)//odd one out gets some neat martial arts, good luck
			ripple_user.add_antag_datum(/datum/antagonist/heartbreaker)///datum/antagonist/lightning_user(?))
		var/datum/team/holo_team/team = new
		var/datum/mind/user = pick_n_take(possible_brothers)
		var/datum/mind/holo = pick_n_take(possible_brothers)
		team.add_member(user)
		team.add_member(holo)
		setup_holoparasite(holo, user.current)
		user.special_role = "holoparasite user"
		holo.special_role = "holoparasite"
		log_game("[key_name(user)] has been selected as a Holo user")
		log_game("[key_name(holo)] has been selected as [key_name(user)]'s Holoparasite")
		pre_holo_teams += team
	return ..()

/datum/game_mode/stand_battles/post_setup()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.forge_holo_objectives()
		for(var/datum/mind/M in team.members)
			if(M.special_role = "holoparasite user")
				M.add_antag_datum(/datum/antagonist/holo_user)
		team.update_name()
	holo_teams += pre_holo_teams
	return ..()

/datum/game_mode/stand_battles/proc/setup_holoparasite(holopara, holopara_summoner)
	qdel(holopara.current) //coincidentally, this thanos snaps half of the station. this... does put a smile on my face.
	var/mob/living/simple_animal/hostile/guardian/G = new /mob/living/simple_animal/hostile/guardian/punch(user, "tech")
	G.summoner = holopara_summoner
	G.key = holopara.key
	G.mind.enslave_mind_to_creator(holopara_summoner)
	holopara_summoner.verbs += /mob/living/proc/guardian_comm
	holopara_summoner.verbs += /mob/living/proc/guardian_recall
	holopara_summoner.verbs += /mob/living/proc/guardian_reset

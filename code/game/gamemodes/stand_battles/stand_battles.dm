///////////////////////stand royale

/datum/game_mode
	var/list/datum/mind/users = list()
	var/list/datum/team/holo_team/holo_teams = list()

/datum/game_mode/stand_battle
	name = "stand battle"
	config_tag = "traitorbro"//standbattle
	restricted_jobs = list("AI", "Cyborg")

	announce_span = "danger"
	announce_text = "Everyone is fighting to become the gang star of the syndicate by honing their holoparasite!\n\
	<span class='danger'>Holoparasite users</span>: Find items to power up your holoparasite!\n\
	<span class='danger'>Holoparasites</span>: Defend your user and defeat other users!"

	var/list/datum/team/holo_team/pre_holo_teams = list()
	var/const/min_team_size = 2
	traitors_required = FALSE //Only teams are possible

/datum/game_mode/stand_battle/pre_setup()//nobody here
	//every job gets picked.
	//load a template in space for where everyone starts

	var/list/datum/mind/stands_and_users_to_team = num_players()//why have a config here if everyone is going to get picked for this admin event anyways

	while(stands_and_users_to_team.len > 0)
		if(possible_brothers.len < min_team_size || antag_candidates.len <= required_enemies)
			var/datum/mind/ripple_user = pick_n_take(stands_and_users_to_team)//odd one out gets some neat martial arts, good luck
			ripple_user.add_antag_datum(/datum/antagonist/martial_outcast)
			break
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
	return TRUE

/datum/game_mode/stand_battle/post_setup()
	for(var/datum/team/holo_team/team in pre_holo_teams)
		team.forge_holo_objectives()
		for(var/datum/mind/M in team.members)
			if(user.special_role = "holoparasite user")
				M.add_antag_datum(/datum/antagonist/holo_user)
		team.update_name()
	holo_teams += pre_holo_teams
	return ..()

/datum/game_mode/stand_battle/proc/setup_holoparasite(holopara, holopara_summoner)
	var/mob/living/simple_animal/hostile/guardian/G = new /mob/living/simple_animal/hostile/guardian/simple(user, "tech")
	G.summoner = holopara_summoner
	G.key = holopara.key
	G.mind.enslave_mind_to_creator(holopara_summoner)
	holopara_summoner.verbs += /mob/living/proc/guardian_comm
	holopara_summoner.verbs += /mob/living/proc/guardian_recall
	holopara_summoner.verbs += /mob/living/proc/guardian_reset

/datum/game_mode/proc/update_holo_icons_added(datum/mind/holo_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.join_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, "brother")

/datum/game_mode/proc/update_holo_icons_removed(datum/mind/holo_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.leave_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, null)

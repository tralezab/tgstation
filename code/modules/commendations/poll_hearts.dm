/// Called when the shuttle starts launching back to centcom, polls a few random players who joined the round for commendations
/datum/controller/subsystem/ticker/proc/poll_hearts()
	if(!CONFIG_GET(number/commendation_percent_poll))
		return

	var/number_to_ask = round(LAZYLEN(GLOB.joined_player_list) * CONFIG_GET(number/commendation_percent_poll)) + rand(0,1)
	if(number_to_ask == 0)
		message_admins("Not enough eligible players to poll for commendations.")
		return
	message_admins("Polling [number_to_ask] players for commendations.")

	for(var/i in GLOB.joined_player_list)
		var/mob/check_mob = get_mob_by_ckey(i)
		if(!check_mob?.mind || !check_mob.client)
			continue
		// maybe some other filters like bans or whatever
		INVOKE_ASYNC(check_mob, /mob.proc/query_heart, 1)
		number_to_ask--
		if(number_to_ask <= 0)
			break

/// Ask someone if they'd like to award a commendation for the round, 3 tries to get the name they want before we give up
/mob/proc/query_heart(attempt=1)
	if(!client || attempt > 3)
		return
	if(attempt == 1 && tgui_alert(src, "Was there another character you noticed being kind this round that you would like to anonymously thank?", "<3?", list("Yes", "No"), timeout = 30 SECONDS) != "Yes")
		return

	var/heart_nominee
	switch(attempt)
		if(1)
			heart_nominee = tgui_input_text(src, "What was their name? Just a first or last name may be enough.", "<3?")
		if(2)
			heart_nominee = tgui_input_text(src, "Try again, what was their name? Just a first or last name may be enough.", "<3?")
		if(3)
			heart_nominee = tgui_input_text(src, "One more try, what was their name? Just a first or last name may be enough.", "<3?")

	if(!heart_nominee)
		return

	heart_nominee = lowertext(heart_nominee)
	var/list/name_checks = get_mob_by_name(heart_nominee)
	if(!name_checks || name_checks.len == 0)
		query_heart(attempt + 1)
		return
	name_checks = shuffle(name_checks)

	for(var/i in name_checks)
		var/mob/heart_contender = i
		if(heart_contender == src)
			continue

		switch(tgui_alert(src, "Is this the person: [heart_contender.real_name]?", "<3?", list("Yes!", "Nope", "Cancel"), timeout = 15 SECONDS))
			if("Yes!")
				heart_contender.plan_commendation(src, /datum/commendation/hearted)
				return
			if("Nope")
				continue
			else
				return

	query_heart(attempt + 1)

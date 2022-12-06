/datum/admins/proc/show_traitor_panel(datum/mob_or_mind)
	set category = "Admin.Game"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "Not before round-start!", "Alert")
		return

	var/datum/mind/mind
	if(ismob(mob_or_mind))
		var/mob/target_mob = mob_or_mind
		mind = target_mob.mind
		if(!mind)
			to_chat(usr, "This mob has no mind!", confidential = TRUE)
			return
	else if(istype(mob_or_mind, /datum/mind))
		mind = mob_or_mind
	else
		to_chat(usr, "This can only be used on instances of type /mob and /mind", confidential = TRUE)
		return
	if(QDELETED(mind))
		tgui_alert(usr, "This mind doesn't have a mob, or is deleted! For some reason!", "Traitor Panel")
		return

	traitor_panel(mind)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

///Opens up the Traitor Panel
/datum/admins/proc/traitor_panel(datum/mind/mind)
	if(!check_rights(R_ADMIN))
		return

	var/datum/traitor_panel/ui = new (usr)
	ui.mind = mind
	ui.ui_interact(usr)

/// Traitor Panel
/datum/traitor_panel
	var/datum/mind/mind

/datum/traitor_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TraitorPanel")
		ui.open()

/datum/traitor_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/traitor_panel/ui_data(mob/user)
	var/list/data = list()
	data["mind"] = !!mind
	if(!mind)
		return data
	//the rest of these guarantee mind's existence
	data["realName"] = mind.current?.real_name != mind.name ? mind.current.real_name : ""
	return data

/datum/traitor_panel/ui_static_data(mob/user)
	//profile
	var/list/data = list()
	if(!mind)
		return data
	data["mindName"] = mind.name
	data["mindKey"] = mind.key
	data["keyActive"] = mind.active
	//button to edit role
	data["assignedRole"] = mind.assigned_role.title
	data["specialRole"] = mind.special_role
	data["specialStatuses"] = list()
	for(var/list/status as anything in mind.special_statuses)
		UNTYPED_LIST_ADD(data["specialStatuses"], status)
		if(!mind.current)
			UNTYPED_LIST_ADD(data["specialStatuses"], list(
				"content" = "No body!",
				"positive" = FALSE,
				"icon" = "brain"
			))
	//antags
	data["antagonistCategories"] = list()
	data["antagonists"] = list()
	if(!GLOB.antag_prototypes)
		setup_antag_prototypes()
	for(var/antag_category in GLOB.antag_prototypes)
		//categories should have at least one antag if we care to show it
		var/valid_category = FALSE
		for(var/datum/antagonist/prototype as anything in GLOB.antag_prototypes[antag_category])
			var/datum/antagonist/has_this_antag = mind.has_antag_datum(prototype.type)
			if(has_this_antag || prototype.show_in_antagpanel)
				valid_category = TRUE
				var/list/added = list(
					"name" = prototype.name,
					"type" = prototype.type,
					"category" = antag_category,
				)
				if(has_this_antag)
					added["hasThis"] = TRUE
				UNTYPED_LIST_ADD(data["antagonists"], added)
		if(valid_category)
			data["antagonistCategories"] += antag_category
	return data

/datum/traitor_panel/proc/setup_antag_prototypes()
	GLOB.antag_prototypes = list()
	for(var/antag_type in subtypesof(/datum/antagonist))
		var/datum/antagonist/antag = new antag_type
		var/cat_id = antag.antagpanel_category
		if(!GLOB.antag_prototypes[cat_id])
			GLOB.antag_prototypes[cat_id] = list(antag)
		else
			GLOB.antag_prototypes[cat_id] += antag
	sortTim(GLOB.antag_prototypes, GLOBAL_PROC_REF(cmp_text_asc),associative=TRUE)

/datum/traitor_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_ADMIN))
		return
	to_chat(world, action)
	switch(action)
		if("add_antag")
			var/datum/antagonist/new_antag = params["type"]
		if("remove_antag")
			mind.remove_antag_datum(params["type"])


	if(href_list[])
		add_antag_wrapper(text2path(href_list["add_antag"]),usr)

	if(href_list[])
		var/datum/antagonist/A = locate(href_list["remove_antag"]) in antag_datums
		if(!istype(A))
			to_chat(usr,span_warning("Invalid antagonist ref to be removed."))
			return
		A.admin_remove(usr)

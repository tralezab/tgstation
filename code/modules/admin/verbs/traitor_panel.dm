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
	///mind of the player we're messing with
	var/datum/mind/mind

	///all the categories preparing the data found
	var/static/list/categories
	///all the antagonist groups
	var/static/list/groups

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
	if(!groups)
		setup_antag_prototypes()
	data["allCategories"] = categories
	data["allGroups"] = groups
	return data

/// list of groups
/// group has a list of antagonists
/// antagonists has a list of names, types, and whether they have it
/datum/traitor_panel/proc/setup_antag_prototypes()
	var/list/name2group = list()
	categories = list()

	for(var/datum/antagonist/antag_type as anything in subtypesof(/datum/antagonist))
		if(initial(antag_type.traitor_panel_categories) == PANEL_EXCLUDED)
			continue
		var/datum/antagonist/prototype = new antag_type()

		//populating groups
		if(!prototype.traitor_panel_group)
			prototype.traitor_panel_group = prototype.name
		if(!name2group[prototype.traitor_panel_group])
			name2group[prototype.traitor_panel_group] = list(
				"name" = prototype.traitor_panel_group,
				"categories" = prototype.traitor_panel_categories,
				"antagonists" = list(),
			)
		var/list/group = name2group[prototype.traitor_panel_group]
		UNTYPED_LIST_ADD(group["antagonists"], list(
			"name" = prototype.name,
			"type" = prototype.type,
		))
		//populating categories
		categories |= group["categories"]

	groups = flatten_list(name2group)

/datum/traitor_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(R_ADMIN))
		return
	to_chat(world, action)
	switch(action)
		if("add_antag")
			mind.add_antag_wrapper(text2path(params["type"]), usr)
		if("remove_antag")
			mind.remove_antag_datum(text2path(params["type"]))

/datum/mind/proc/add_special_status(content, is_positive, icon)
	var/list/new_status = list(
		"content" = content,
		"isPositive" = is_positive,
		"icon" = icon,
	)
	LAZYINITLIST(special_statuses)
	UNTYPED_LIST_ADD(special_statuses, new_status)

/datum/mind/proc/remove_special_status(content)
	if(!special_statuses)
		return //well, it isn't in there
	for(var/list/old_status as anything in special_statuses)
		if(old_status["content"] == content)
			UNTYPED_LIST_REMOVE(special_statuses, old_status)
	UNSETEMPTY(special_statuses)

/datum/mind/proc/add_antag_wrapper(antag_type,mob/user)
	var/datum/antagonist/new_antag = new antag_type()
	new_antag.admin_add(src,user)
	//If something gone wrong/admin-add assign another antagonist due to whatever clean it up
	if(!new_antag.owner)
		qdel(new_antag)

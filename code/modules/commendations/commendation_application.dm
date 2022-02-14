/**
 * ### plan_commendation
 *
 * The proc for commending people, with options and logging. Use instead of `commend()`
 *
 * Arguments:
 * * from: mob, The reference to the mob who sent the commendation, just for the purposes of logging
 * * commend_type: typepath, What commendation is being applied, can be any subtype of /datum/commendation
 * * instant: bool, If TRUE (or if the round is already over), we'll give them the commendation now, if FALSE, we wait until the end of the round (which is the standard behavior)
 */
/mob/proc/plan_commendation(mob/from, datum/commendation/commend_type, instant = FALSE)
	if(!client)
		return
	to_chat(from, span_nicegreen("Commendation sent!"))
	message_admins("[key_name(from)] commended [key_name(src)] [instant ? "(instant)" : ""]")
	log_admin("[key_name(from)] commended [key_name(src)] [instant ? "(instant)" : ""]")
	if(instant || SSticker.current_state == GAME_STATE_FINISHED)
		client.commend(commend_type)
	else
		LAZYADDASSOC(SSticker.roundend_commendations, ckey, commend_type)

/// Once the round is actually over, cycle through the ckeys in the roundend_commendations list and give them their commendation
/datum/controller/subsystem/ticker/proc/handle_roundend_commendations()
	var/list/ckeys = assoc_to_keys(roundend_commendations)
	for(var/ckey in roundend_commendations)
		var/commendation_type = roundend_commendations[ckey]
		var/mob/hearted_mob = get_mob_by_ckey(ckey)
		hearted_mob?.client?.commend(commendation_type)
	message_admins("The following players were commended this round: [english_list(ckeys, nothing_text = "nobody")]")

///Gives someone hearted status for OOC, from behavior commendations.
///This is !UNLOGGED! so please use `plan_commendation()` for reaching this proc
/client/proc/commend(datum/commendation/commend_type)
	var/datum/commendation/possible_current_commendation = prefs.read_preference(/datum/preference/choiced/commendation_type)
	var/new_duration = world.realtime + initial(commend_type.award_duration)
	if(possible_current_commendation && new_duration < initial(possible_current_commendation.award_duration))
		return //prevents shorter medals from overwriting longer medals
	to_chat(src, span_nicegreen(initial(commend_type.award_text)))
	prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/commendation_type], commend_type)
	prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/commendation_timeout], new_duration)

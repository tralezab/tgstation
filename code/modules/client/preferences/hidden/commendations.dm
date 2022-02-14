///what kind of commendation does this player have?
/datum/preference/choiced/commendation_type
	category = PREFERENCE_CATEGORY_HIDDEN
	savefile_key = "commendation_type"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/commendation_type/init_possible_values()
	return subtypesof(/datum/commendation) + null

/datum/preference/choiced/commendation_type/create_default_value()
	return null

///how long does this player have this commendation? when applying, it will remove the commendation if it is timed out.
/datum/preference/numeric/commendation_timeout
	category = PREFERENCE_CATEGORY_HIDDEN
	savefile_key = "commendation_timeout"
	savefile_identifier = PREFERENCE_PLAYER
	minimum = 0
	maximum = INFINITY

/datum/preference/numeric/commendation_timeout/create_default_value()
	return 0

/datum/preference/numeric/commendation_timeout/apply_to_client(client/client, value)
	var/datum/preferences/prefs = client.prefs
	if(value && value > world.realtime)
		prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/commendation_type], null)

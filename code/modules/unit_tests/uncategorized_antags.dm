/// Tests that all antagonists that are in the traitor panel also
/datum/unit_test/uncategorized_antags

/datum/unit_test/uncategorized_antags/Run()
	for(var/datum/antagonist/antag as anything in subtypesof(/datum/antagonist))
		antag = new antag()
		if(antag.show_in_antagpanel && antag.antagpanel_category == TP_CATEGORY_UNCATEGORIZED)
			TEST_FAIL("[antag.name] has \"show_in_antagpanel\" set to true, but has \"antagpanel_category\" unset")

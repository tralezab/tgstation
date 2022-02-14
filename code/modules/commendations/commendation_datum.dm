
/datum/commendation
	///name of the medal, mostly for admins
	var/name = "Bugged POS"
	///what their commendation looks like when they speak in ooc. uses the chat asset datum, take a look at that.
	var/icon_tag
	///how long this award should stay. When one is going to be applied, it won't be applied if a longer lasting medal is currently used
	var/award_duration
	///message sent to the user when they are commended.
	var/award_text
	///your admin level to be able to admin award this.
	var/rank_to_admin_award = R_ADMIN

///Players award eachother for 24 hours
/datum/commendation/hearted
	name = "Hearted"
	icon_tag = "emoji-heart"
	award_duration = 24 HOURS
	award_text = "Someone awarded you a heart!"
	rank_to_admin_award = R_FUN

///Incentive for contributors to tackle large "never ever" projects.
/datum/commendation/coder_award
	name = "Notable Contributor"
	icon_tag = "emoji-engie"
	award_duration = 1 MONTHS
	award_text = "You have been recognized by the head administration as a notable contributor."
	rank_to_admin_award = R_DBRANKS

///Reward for particularly good actions done by a community member.
/datum/commendation/admin_award
	name = "Notable Community Member"
	icon_tag = "emoji-medal"
	award_duration = 1 MONTHS
	award_text = "You have been recognized by the head administration as a notable community member."
	rank_to_admin_award = R_DBRANKS

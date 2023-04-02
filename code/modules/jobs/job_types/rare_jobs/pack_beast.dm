/datum/job/cargo_pack_beast
	title = JOB_CARGORILLA
	description = "Carry crates to their destination with your beastly form. \
	And you're a gorilla, so that should help you keep cargo safe."
	department_head = list(JOB_QUARTERMASTER)
	faction = FACTION_STATION
	supervisors = SUPERVISOR_QM
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CARGO_PACK_BEAST"

	spawn_type = /mob/living/simple_animal/hostile/gorilla/cargo_domestic

	paycheck = PAYCHECK_ZERO // WTF
	paycheck_department = ACCOUNT_CAR
	display_order = JOB_DISPLAY_ORDER_CARGO_PACK_BEAST
	bounty_types = CIV_JOB_BASIC //probably can't do more
	departments_list = list(
		/datum/job_department/cargo,
		)

	mail_goodies = list(
		/obj/item/food/grown/banana = 5,
		/obj/item/food/grown/banana/bunch = 3,
		/obj/item/food/grown/banana/bluespace = 1,
		/obj/item/food/grown/banana/bombanana = 1,
		/obj/item/food/grown/banana/mime = 1,
	)
	rpg_title = "Freight Familiar"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_RARE_APPEARANCE

/datum/job/cargo_pack_beast/after_roundstart_spawn(mob/living/spawning, client/player_client)
	. = ..()
	var/mob/living/simple_animal/sloth/cargo_sloth = GLOB.cargo_sloth
	if(!cargo_sloth)
		return

	spawning.fully_replace_character_name(spawning.real_name, cargo_sloth.real_name)
	// hm our sloth looks funny today
	qdel(cargo_sloth)

	// pack beast carries the crates, the age of robot is over
	if(GLOB.cargo_ripley)
		qdel(GLOB.cargo_ripley)

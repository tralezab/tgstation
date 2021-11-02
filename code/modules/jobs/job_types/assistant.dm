/*
Assistant
*/
/datum/job/assistant
	title = "Assistant"
	faction = FACTION_STATION
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	exp_granted_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/assistant
	plasmaman_outfit = /datum/outfit/plasmaman
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.

	liver_traits = list(TRAIT_GREYTIDE_METABOLISM)

	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT

	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)

	mail_goodies = list(
		/obj/effect/spawner/random/food_or_drink/donkpockets = 10,
		/obj/item/clothing/mask/gas = 10,
		/obj/item/clothing/gloves/color/fyellow = 7,
		/obj/item/choice_beacon/music = 5,
		/obj/item/toy/sprayoncan = 3,
		/obj/item/crowbar/large = 1
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS
	rpg_title = "Lout"

/datum/job/assistant/New()
	. = ..()
	if(SSevents.holidays[HALLOWEEN])
		outfit = /datum/outfit/job/assistant/halloween

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant
	id_trim = /datum/id_trim/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		give_grey_suit(H)
	else
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/random

/datum/outfit/job/assistant/proc/give_grey_suit(mob/living/carbon/human/target)
	if (target.jumpsuit_style == PREF_SUIT)
		uniform = /obj/item/clothing/under/color/grey
	else
		uniform = /obj/item/clothing/under/color/jumpskirt/grey

/datum/outfit/job/assistant/consistent
	name = "Assistant - Consistent"

/datum/outfit/job/assistant/consistent/pre_equip(mob/living/carbon/human/H)
	..()
	give_grey_suit(H)

/datum/outfit/job/assistant/consistent/post_equip(mob/living/carbon/human/H, visualsOnly)
	..()

	// This outfit is used by the assets SS, which is ran before the atoms SS
	if (SSatoms.initialized == INITIALIZATION_INSSATOMS)
		H.w_uniform?.update_greyscale()

/datum/outfit/job/assistant/halloween
	name = "Trick or Treater"
	id_trim = /datum/id_trim/job/assistant/halloween
	r_hand = /obj/item/storage/spooky

/datum/outfit/job/assistant/halloween/pre_equip(mob/living/carbon/human/trick_or_treater)
	. = ..()
	switch(rand(1,8))
		if(1)
			suit = /obj/item/clothing/suit/dracula
		if(2)
			head = /obj/item/clothing/head/drfreezehat
			suit = /obj/item/clothing/suit/drfreeze_coat
			uniform = /obj/item/clothing/under/costume/drfreeze
		if(3)
			suit = /obj/item/clothing/suit/gothcoat
		if(4)
			head = /obj/item/clothing/head/lobsterhat
			uniform = /obj/item/clothing/under/costume/lobster
		if(5)
			head = /obj/item/clothing/head/scarecrow_hat
			mask = /obj/item/clothing/mask/scarecrow
			uniform = /obj/item/clothing/under/costume/scarecrow
		if(6)
			mask = /obj/item/clothing/mask/mummy
			uniform = /obj/item/clothing/under/costume/mummy
		if(7)
			head = /obj/item/clothing/head/jester/alt
			shoes = /obj/item/clothing/shoes/clown_shoes/jester
			uniform = /obj/item/clothing/under/rank/civilian/clown/jester/alt
		if(8)
			uniform = /obj/item/clothing/under/costume/skeleton

/datum/outfit/job/assistant/halloween/post_equip(mob/living/carbon/human/trick_or_treater, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	to_chat(trick_or_treater, span_boldannounce(\
		"It's a wonderful halloween night to get some trick or treating done with your friends! \
		If you're having some second thoughts on your costume tonight, the Autodrobe vending machine can help with that."\
	))

/datum/outfit/expedition
	name = "Generic Expedition Crew"

	back = /obj/item/pickaxe/silver
	belt = /obj/item/grappling_hook
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/hooded/wintercoat/science
	ears = /obj/item/radio/headset/headset_sci
	glasses = /obj/item/clothing/glasses/science
	shoes = /obj/item/clothing/shoes/sneakers/white

/datum/outfit/expedition_exogeologist/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= "mining"

	var/obj/item/radio/outfit_radio = equipped.ears
	if(outfit_radio)
		outfit_radio.prison_radio = TRUE //do not allow speaking
		outfit_radio.freqlock = TRUE //do not allow switching

	var/obj/item/card/id/outfit_id = equipped.wear_id
	if(outfit_id)
		outfit_id.registered_name = equipped.real_name
		outfit_id.update_label()
		outfit_id.update_icon()

	var/obj/item/clothing/suit/hooded/wintercoat/science/hoodie = equipped.suit
	hoodie.ToggleHood()

/datum/outfit/expedition/exogeologist
	id = /obj/item/card/id/away/expedition_crew/exogeologist


/obj/item/seeds/garlic
	name = "pack of garlic seeds"
	desc = "A packet of extremely pungent seeds."
	icon_state = "seed-garlic"
	species = "garlic"
	plantname = "Garlic Sprouts"
	product = /obj/item/reagent_containers/food/snacks/grown/garlic
	yield = 6
	potency = 25
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	mutatelist = list(/obj/item/seeds/garlic/hairy)
	reagents_add = list(/datum/reagent/consumable/garlic = 0.15, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/garlic
	seed = /obj/item/seeds/garlic
	name = "garlic"
	desc = "Delicious, but with a potentially overwhelming odor."
	icon_state = "garlic"
	filling_color = "#C0C9A0"
	bitesize_mod = 2
	tastes = list("garlic" = 1)
	wine_power = 10

/obj/item/seeds/garlic/hairy
	name = "pack of hair garlic"
	desc = "A packet of extremely hairy seeds."
	icon_state = "seed-garlic"
	species = "garlic"
	plantname = "Garlic Sprouts"
	product = /obj/item/reagent_containers/food/snacks/grown/garlic/hairy
	yield = 6
	potency = 25
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	mutatelist = list(/obj/item/seeds/garlic/hairy)
	reagents_add = list(/datum/reagent/consumable/garlic = 0.15, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/garlic/hairy
	seed = /obj/item/seeds/garlic/hairy
	name = "hairy garlic"
	desc = "Delicious, but with a potentially overwhelming odor AND disgusting hair on it like you dropped it on the floor and didn't meet the 5 second rule in time."
	icon_state = "hairygarlic"
	tastes = list("garlic" = 1, "hair" = 3)
	wine_power = 5

/obj/item/reagent_containers/food/snacks/grown/garlic/hairy/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	bitesize = reagents.total_volume //one bite!

/obj/item/reagent_containers/food/snacks/grown/garlic/hairy/On_Consume(mob/living/eater)
	if(ishuman(eater))
		var/mob/living/carbon/human/H = eater
		to_chat(H, "<span class='notice'>Your hair shapes into something... fruity?!</span>")
		H.hairstyle = pick("Very Long Strawberry")
		H.update_hair()

/datum/sprite_accessory/hair/garlic
	locked = TRUE

/datum/sprite_accessory/hair/garlic/strawberry
	name = "Very Long Strawberry"
	icon_state = "hair_vlongspotted"

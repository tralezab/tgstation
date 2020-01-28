//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

///Wizard tower item
/obj/item/disk/design_disk/adv/knight_gear
	name = "Magic Disk of Smithing"

/obj/item/disk/design_disk/adv/knight_gear/Initialize()
	. = ..()
	var/datum/design/knight_armour/A = new
	var/datum/design/knight_helmet/H = new
	blueprints[1] = A
	blueprints[2] = H

//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry/bomb = 10,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)

//Free Golems

/obj/item/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"
	max_blueprints = 1

/obj/item/disk/design_disk/golem_shell/Initialize()
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprints[1] = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	var/shell_type = /obj/effect/mob_spawn/human/golem
	var/has_owner = FALSE //if the resulting golem obeys someone
	w_class = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/metal	                = /datum/species/golem,
		/obj/item/stack/sheet/glass 	            = /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel 	            = /datum/species/golem/plasteel,
		/obj/item/stack/sheet/mineral/sandstone	    = /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma	    = /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond	    = /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold	        = /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver	    = /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium	    = /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium	    = /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/titanium	    = /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium	= /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor	    = /datum/species/golem/alloy,
		/obj/item/stack/sheet/mineral/wood	        = /datum/species/golem/wood,
		/obj/item/stack/sheet/bluespace_crystal	    = /datum/species/golem/bluespace,
		/obj/item/stack/sheet/runed_metal	        = /datum/species/golem/runic,
		/obj/item/stack/medical/gauze	            = /datum/species/golem/cloth,
		/obj/item/stack/sheet/cloth	                = /datum/species/golem/cloth,
		/obj/item/stack/sheet/mineral/adamantine	= /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic	            = /datum/species/golem/plastic,
		/obj/item/stack/tile/bronze					= /datum/species/golem/bronze,
		/obj/item/stack/sheet/cardboard				= /datum/species/golem/cardboard,
		/obj/item/stack/sheet/leather				= /datum/species/golem/leather,
		/obj/item/stack/sheet/bone					= /datum/species/golem/bone,
		/obj/item/stack/sheet/durathread			= /datum/species/golem/durathread,
		/obj/item/stack/sheet/cotton/durathread		= /datum/species/golem/durathread,
		/obj/item/stack/sheet/mineral/snow			= /datum/species/golem/snow,
		/obj/item/stack/sheet/capitalisium			= /datum/species/golem/capitalist,
		/obj/item/stack/sheet/stalinium				= /datum/species/golem/soviet)

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/O = I
		var/species = golem_shell_species_types[O.merge_type]
		if(species)
			if(O.use(10))
				to_chat(user, "<span class='notice'>You finish up the golem shell with ten sheets of [O].</span>")
				new shell_type(get_turf(src), species, user)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need at least ten sheets to finish a golem!</span>")
		else
			to_chat(user, "<span class='warning'>You can't build a golem out of this kind of material!</span>")

//made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/human/golem/servant

///Syndicate Listening Post

/obj/effect/mob_spawn/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	short_desc = "You are a syndicate science technician, employed in a top secret research facility developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Continue your research as best you can, and try to keep a low profile."
	important_info = "The base is rigged with explosives, DO NOT abandon it or let it fall into enemy hands!"
	outfit = /datum/outfit/lavaland_syndicate
	assignedrole = "Lavaland Syndicate"

/obj/effect/mob_spawn/human/lavaland_syndicate/special(mob/living/new_spawn)
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)

/datum/outfit/lavaland_syndicate
	name = "Lavaland Syndicate Agent"
	r_hand = /obj/item/gun/ballistic/automatic/sniper_rifle
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	id = /obj/item/card/id/syndicate/anyone
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent"
	short_desc = "You are a syndicate comms agent, employed in a top secret research facility developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"
	important_info = "DO NOT abandon the base."
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space
	short_desc = "You are a syndicate agent, assigned to a small listening post station situated near your hated enemy's top secret research facility: Space Station 13."
	flavour_text = "Monitor enemy activity as best you can, and try to keep a low profile. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"
	important_info = "DO NOT abandon the base."

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space/Initialize()
	. = ..()
	if(prob(90)) //only has a 10% chance of existing, otherwise it'll just be a NPC syndie.
		new /mob/living/simple_animal/hostile/syndicate/ranged(get_turf(src))
		return INITIALIZE_HINT_QDEL

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	r_hand = /obj/item/melee/transforming/energy/sword/saber
	mask = /obj/item/clothing/mask/chameleon/gps
	suit = /obj/item/clothing/suit/armor/vest

/obj/item/clothing/mask/chameleon/gps/Initialize()
	. = ..()
	AddComponent(/datum/component/gps, "Encrypted Signal")

//crystal prisoner shit//

/obj/item/clothing/mask/gas/evilskull
	name = "skull mask"
	desc = "A very evil looking skull mask."
	icon_state = "eskull"
	item_state = "eskull"
	//no armor on purpose- the crystal prisoner themselves need to be weak
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	strip_delay = 100
	var/image/red_eyes

/obj/item/clothing/mask/gas/evilskull/Initialize()
	. = ..()
	red_eyes = image('icons/mob/human_face.dmi', "eyes_glow_noanim")
	red_eyes.color = "#FF0000"

/obj/item/clothing/mask/gas/evilskull/equipped(mob/user, slot, initial = FALSE)
	..()
	if(slot == ITEM_SLOT_MASK)
		user.add_overlay(red_eyes)

/obj/item/clothing/mask/gas/evilskull/dropped(mob/user, silent = FALSE)
	..()
	user.cut_overlay(red_eyes)

/obj/item/clothing/suit/evilgarb
	name = "evil robes"
	desc = "You can't be evil if you don't look the part. Or, maybe it's that enough evil people look nice in this world and we really need a villain who is down to earth with their look, someone who is honest. Honestly evil."
	icon_state = "evilgarb"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT


//crystal prisoner base construction

//throne, you sit on it to use the dungeon builder. don't lose it!
/obj/structure/chair/evil
	icon_state = "wooden_chair"
	name = "dark throne"
	desc = "What dungeon is complete without the evil throne?"
	max_integrity = 70
	item_chair = null
	var/obj/machinery/computer/camera_advanced/dungeon/camera_machine

/obj/structure/chair/evil/Initialize()
	. = ..()
	camera_machine = new(src)

/obj/structure/chair/evil/post_buckle_mob(mob/living/M)
	. = ..()
	if(M.mind?.assigned_role == "crystal prisoner")
		to_chat(M, "<span class='notice'>You feel the heart of the dungeon embrace you...</span>")
		camera_machine.attack_hand(M) //this has some fail cases but they will never happen as long as one person only can buckle in
	else
		to_chat(M, "<span class='warning'>You feel the heart of the dungeon reject you. You should really destroy this chair.</span>")

/obj/structure/chair/evil/post_unbuckle_mob(mob/living/M)
	. = ..()
	if(camera_machine.current_user == M)
		camera_machine.remove_eye_control(M)

/obj/structure/chair/evil/Destroy()
	..()
	qdel(camera_machine)

/mob/camera/aiEye/remote/dungeon_construction
	name = "all seeing eye"
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	var/tiles_count = 20 //how many tiles you can go from an area before getting pulled back to the throne
	var/throne

/mob/camera/aiEye/remote/dungeon_construction/setLoc(var/t)
	var/area/curr_area = get_area(t)
	if(istype(curr_area, /area/ruin/unpowered/crystal_dungeon))
		if(tiles_count != initial(tiles_count))
			tiles_count = 20
		return ..()
	tiles_count--
	if(!tiles_count)
		//to_chat("you got sent back")
		forceMove(throne)
		to_chat(world, "sent back")

/obj/item/construction/rcd/dungeon //dungeon rcd, charged by the hand of darkness so different costs
	max_matter = 300 //1 body = 30 objects
	no_ammo_message = "<span class='warning'>You are out of power. Use the staff on the throne to recharge.</span>"
	delay_mod = 0.5


/obj/machinery/computer/camera_advanced/base_construction/dungeon
	off_action = /datum/action/innate/dungeon/help //there should be no camera end here because the chair unbuckling does it
	var/obj/item/construction/rcd/dungeon/RCD //Internal RCD. The computer passes user commands to this in order to avoid massive copypaste.

	var/wallcost = 10
	var/floorcost = 1
	launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

/datum/action/innate/dungeon
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_dungeon"

/datum/action/innate/dungeon/help
	name = "Help"
	desc = "Use this to learn how to use the dungeon heart correctly."
	button_icon_state = "lay_web"


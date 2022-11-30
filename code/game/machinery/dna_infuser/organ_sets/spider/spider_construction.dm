
/datum/crafting_recipe/webtunnel
	name = "Web Tunnel"
	always_available = FALSE
	reqs = list(
		/obj/item/stack/sheet/web = 20,
	)
	result = /obj/structure/webtunnel
	category = CAT_PRIMAL

///Has no special properties.
/datum/material/webbing
	name = "webbing"
	desc = "Organic, sticky, and surprisingly strong."
	color = "#f8f8f8"
	greyscale_colors = "#f8f8f8"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/webbing
	value_per_unit = 0.0025 //probably worth more than iron but eh selling isn't the point

/turf/closed/wall/mineral/webbing
	name = "web wall"
	desc = "A wall entirely made from webs. Sticky."
	icon = 'icons/turf/walls/web_wall.dmi'
	icon_state = "webwall-0"
	base_icon_state = "web_wall"
	sheet_type = /obj/item/stack/sheet/mineral/web
	hardness = 60
	turf_flags = IS_SOLID
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_WOOD_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WOOD_WALLS)
	custom_materials = list(/datum/material/web = 4000)

/obj/item/stack/sheet/webbing
	name = "organic webbing"
	desc = "Surprisingly strong organic material, for its weight. Sticky, too. Nature is a wonderous thing, isn't it?"
	singular_name = "organic web"
	icon_state = "sheet-pizza"
	mats_per_unit = list(/datum/material/pizza = MINERAL_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/pizza
	material_type = /datum/material/pizza
	walltype = /turf/closed/wall/mineral/webbing
	material_modifier = 1

/obj/item/stack/sheet/webbing/fifty
	amount = 50

/obj/item/stack/sheet/webbing/twenty
	amount = 20

/obj/item/stack/sheet/webbing/five
	amount = 5

/obj/structure/webtunnel
	name = "Web Tunnel"

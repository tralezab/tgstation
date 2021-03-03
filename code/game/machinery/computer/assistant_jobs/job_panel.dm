
/obj/machinery/computer/job_panel
	name = "Assistant Job Panel"
	desc = "An interface for ordering assistants around! You may hire and fire them from here, and decide how much pay they get and when to pay them."
	icon_screen = "request"
	icon_keyboard = "generic_key"
	circuit = /obj/item/circuitboard/computer/chef_order
	light_color = LIGHT_COLOR_GREEN

	var/datum/assistant_hire/hire_datum
	var/list/hired_assistants = list()

/obj/machinery/computer/job_panel/Initialize()
	. = ..()

	hire_datum = new

/obj/machinery/computer/job_panel/Destroy()
	qdel(hire_datum)
	. = ..()

/obj/machinery/computer/job_panel/attackby(obj/item/onboarding_item, mob/living/user, params)
	if(onboarding_item, /obj/item/pda)
		var/obj/item/pda/hiree_pda = onboarding_item
		if(!hiree_pda.id)
			say("This pda needs an ID inside it to register as a new hiree.")
			return TRUE //thats right bitch slap the machine
		var/obj/item/card/id/hiree_id = hiree_pda.id
		if(!hiree_id.registered_account)
			say("[registered_name] has no registered bank account! They would not be able to be paid.")
			return TRUE
		hired_assistants += WEAKREF(hiree_pda.id)
		return FALSE
	. = ..()

/obj/machinery/computer/job_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobPanel", name)
		ui.open()

/obj/machinery/computer/job_panel/ui_data(mob/user)
	. = ..()
	.["off_cooldown"] = COOLDOWN_FINISHED(src, order_cooldown)

/obj/machinery/computer/job_panel/ui_static_data(mob/user)
	. = ..()
	.["total_cost"] = get_total_cost()
	.["order_datums"] = list()
	for(var/datum/orderable_item/item as anything in order_datums)
		.["order_datums"] += list(list(
			"name" = item.name,
			"desc" = item.desc,
			"cat" = item.category_index,
			"ref" = REF(item),
			"cost" = item.cost_per_order,
			"amt" = grocery_list[item]
			))

/obj/machinery/computer/job_panel/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isliving(usr))
		return
	var/mob/living/manager = usr
	to_chat(world, "action")
	. = TRUE



/obj/machinery/computer/tram_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/tram_controls

	var/obj/structure/industrial_lift/tram/tram_part
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/tram_controls/LateInitialize()
	. = ..()
	//find the tram, late so the tram is all... set up so when this is called? i'm seriously stupid and 90% of what i do consists of barely educated guessing :)
	find_tram()

/obj/machinery/computer/tram_controls/proc/find_tram()
	var/obj/structure/industrial_lift/tram/tram_struct = locate(/obj/structure/industrial_lift/tram) in GLOB.lifts
	tram_part = tram_struct //possibly setting to something null, that's fine, but
	tram_part.find_our_location()

/obj/machinery/computer/tram_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/tram_controls/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/obj/machinery/computer/tram_controls/ui_data(mob/user)
	var/list/data = list()
	data["moving"] = tram_part.travelling
	data["broken"] = tram_part ? FALSE : TRUE
	data["destinations"] = get_destinations()
	return data

/obj/machinery/computer/tram_controls/proc/get_destinations()
	. = list()
	for(var/obj/effect/landmark/tram/destination in GLOB.landmarks_list)
		var/list/this_destination = list()
		this_destination["here"] = destination == tram_part.from_where
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.destination_id
		. += list(this_destination)

/obj/machinery/computer/tram_controls/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/destination_index = params["destination"]
	var/obj/effect/landmark/tram/to_where
	for(var/obj/effect/landmark/tram/destination in GLOB.landmarks_list)
		if(destination_index)
			destination_index--
			continue
		to_where = destination
		break
	if(tram_part.controls_locked || tram_part.travelling) // someone else started
		return
	tram_part.tram_travel(tram_part.from_where, to_where)

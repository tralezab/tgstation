

//Communications Array
// A chain of satellites encircles the station
// Satellites be actived to generate a shield that will block unorganic matter from passing it.
/datum/station_goal/comms_array
	name = "Communications Array"

/datum/station_goal/comms_array/get_report()
	return {"The station's location in this sector is unfortunately out of range of some lucrative contacts.
		We have approved the construction of an NT brand long range communications array.
		Please make sure to keep any enemies of the corporation away from the Array.

		Base parts are available for shipping via cargo.
		"}

/datum/station_goal/comms_array/on_report()
	//Unlock
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shield_sat_control]
	P.special_enabled = TRUE

/datum/station_goal/comms_array/check_completion()
	if(..())
		return TRUE
	var/obj/machinery/comms_array/located_communications_array = locate() in GLOB.machines
	if(B && !B.machine_stat)
		return TRUE
	return FALSE

#define REQUIRED_ARRAYS 10

/obj/machinery/comms_array
	name = "Communications Array Hub"
	desc = "An incredibly bulky yet intricate box of wires. On the side, there is a small inscription:"
	icon = 'icons/obj/machines/comms_hub.dmi'
	icon_state = "comms_hub"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5000
	pixel_x = -32
	pixel_y = -64
	light_range = 3
	light_power = 1.5
	light_color = LIGHT_COLOR_GREEN

	var/connected_arrays = 0

	var/list/obj/structure/fillers = list()

/obj/machinery/comms_array/examine(mob/user)
	. = ..()
	. += "\"NT brand long range communications array. Chelping since 2561.\""


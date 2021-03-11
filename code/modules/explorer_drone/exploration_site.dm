/// All exploration site instances
GLOBAL_LIST_EMPTY(exploration_sites)

// Band is general distance group. Cost of scanning bands increasly exponentialy.
/proc/generate_exploration_sites()
	var/band = GLOB.exoscanner_controller.wide_scan_band
	var/site_count = 1+rand(band-1,band+1)
	var/site_types = subtypesof(/datum/exploration_site) //cache?
	for(var/i in 1 to site_count)
		var/site_type = pick(site_types)
		var/datum/exploration_site/fresh_site = new site_type(band)
		GLOB.exploration_sites += fresh_site
	GLOB.exoscanner_controller.wide_scan_band += 1

/// Exploration site, drone travel destination representing interesting zone for exploration.
/datum/exploration_site
	/// Name displayed after scanning/exploring
	var/name
	/// Description shown after scanning/exploring
	var/description
	/// How far is it, affects travel time/cost.
	var/distance = 1
	/// Coordinates in Station coordinate system - don't ask if station rotates
	var/coordinates
	/// Was the point scan done or a drone arrived on the site. Affects displayed name/description
	var/revealed = FALSE
	/// Was point scan of this site completed.
	var/point_scan_complete = FALSE
	/// Was deep scan of this site completed.
	var/deep_scan_complete = FALSE
	/// Contains baseline site bands at define time. Events bands will be added to this list as part of event generation.
	var/list/band_info = list()
	/// List of event instances represting thing to be found around this exploration site.
	var/list/events = list()
	/// These are used to determine events/adventures possible for this site
	var/site_traits = list()
	/// Key for strings file fluff events
	var/fluff_type = "fluff_generic"
	/// List of scan conditions for this site - scan conditions are singletons
	var/list/datum/scan_condition/scan_conditions

/datum/exploration_site/New(band)
	. = ..()
	distance = max(band+pick(-1,0,1,2),1)
	coordinates = "\u2113:[rand(0,360)]\u00B0,\U01D44F:[rand(0,90)]\u00B0"
	generate_events()
	generate_scan_conditions()

/datum/exploration_site/proc/generate_events()
	/// Try to find aventure first since they're the meat of the system.
	var/datum/exploration_event/adventure = generate_adventure(site_traits)
	if(adventure)
		add_event(adventure)
	/// Fill other sites
	for(var/i in 1 to rand(1,3))
		var/datum/exploration_event/event = generate_event(site_traits)
		if(event)
			add_event(event)

/datum/exploration_site/proc/generate_scan_conditions()
	var/condition_count = pick(4;0,2;1,1;2) //scale this with distance maybe ?
	var/list/possible_conditions = GLOB.scan_conditions.Copy()
	for(var/i in 1 to condition_count)
		LAZYADD(scan_conditions,pick_n_take(possible_conditions))

/datum/exploration_site/proc/generate_adventure(site_traits)
	var/list/possible_adventures = list()
	for(var/datum/adventure/adventure_candidate in GLOB.explorer_drone_adventures)
		if(adventure_candidate.placed || (adventure_candidate.required_site_traits && length(adventure_candidate.required_site_traits - site_traits) != 0))
			continue
		possible_adventures += adventure_candidate
	if(!length(possible_adventures))
		return
	var/datum/adventure/chosen_adventure = pick(possible_adventures)
	chosen_adventure.placed = TRUE
	var/datum/exploration_event/adventure/adventure_event = new
	adventure_event.adventure = chosen_adventure
	adventure_event.band_values = chosen_adventure.band_modifiers
	return adventure_event

/datum/exploration_site/proc/generate_event(site_traits)
	/// List of exploration event requirements indexed by type, .[/datum/exploration_site/a] = list("required"=list(trait),"blacklisted"=list(other_trait))
	var/static/exploration_event_requirements_cache = list()
	if(!length(exploration_event_requirements_cache))
		exploration_event_requirements_cache = build_exploration_event_requirements_cache()
	var/list/viable_events = list()
	for(var/event_type in exploration_event_requirements_cache)
		var/list/required_traits = exploration_event_requirements_cache[event_type]["required"]
		var/list/blacklisted_traits = exploration_event_requirements_cache[event_type]["blacklisted"]
		if(required_traits && length(required_traits - site_traits) != 0)
			continue
		if(blacklisted_traits && length(required_traits & blacklisted_traits) != 0)
			continue
		viable_events += event_type
	if(!length(viable_events))
		return
	var/chosen_type = pick(viable_events)
	return new chosen_type()

/datum/exploration_site/proc/build_exploration_event_requirements_cache()
	. = list()
	for(var/event_type in subtypesof(/datum/exploration_event))
		var/datum/exploration_event/event = event_type
		if(initial(event.root_abstract_type) == event_type)
			continue
		event = new event_type
		.[event_type] = list("required" = event.required_site_traits,"blacklisted" = event.blacklisted_site_traits)
		//Should be no event refs,GC'd naturally

/datum/exploration_site/proc/add_event(datum/exploration_event/event)
	events += event
	/// Add up event band values to ours
	for(var/band in event.band_values)
		if(band_info[band])
			band_info[band] += event.band_values[band]
		else
			band_info[band] = event.band_values[band]
	return

/datum/exploration_site/proc/on_drone_arrival(obj/item/exodrone/drone)
	var/was_known_before = revealed
	reveal()
	if(!was_known_before)
		drone.drone_log("Discovered [name] at [coordinates]")
	else
		drone.drone_log("Arrived at [display_name()]")

/datum/exploration_site/proc/reveal()
	revealed = TRUE

/datum/exploration_site/proc/display_name()
	return revealed ? "[name] at [coordinates]" : "Anomaly at [coordinates]"

/datum/exploration_site/proc/display_description()
	if(!revealed)
		return "No Data"
	var/list/descriptions = list(description)
	for(var/datum/exploration_event/event in events)
		if(deep_scan_complete && event.deep_scan_description)
			descriptions += event.deep_scan_description
		else if(point_scan_complete && event.point_scan_description)
			descriptions += event.point_scan_description
	return descriptions.Join("\n")

/// Data for ui_data, exploration
/datum/exploration_site/proc/site_data(exploration=FALSE)
	. = list()
	.["ref"] = ref(src)
	.["name"] = display_name()
	.["description"] = display_description()
	.["distance"] = distance
	.["revealed"] = revealed
	.["point_scan_complete"] = point_scan_complete
	.["deep_scan_complete"] = deep_scan_complete
	.["band_info"] = point_scan_complete ? band_info : list() //This loses order so when you iterate bands ui side use all_bands
	if(exploration)
		var/list/event_data = list()
		for(var/datum/exploration_event/event in events)
			if(event.visited && event.is_targetable())
				event_data += list(list("name"=event.name,"ref"=ref(event)))
		.["events"] = event_data


/// Exploration event
/datum/exploration_event
	/// These types will be ignored in event creation
	var/root_abstract_type = /datum/exploration_event
	///This name will show up in exploration list if it's repeatable
	var/name = "Something interesting"
	/// Ecountered at least once
	var/visited = FALSE
	/// Modifies site scan results by these
	var/band_values
	/// This will be added to site description, mind this will most likely reveal presence of this event early if set.
	var/site_description_mod
	/// message logged when first ecountering the event.
	var/discovery_log
	/// Exploration site required_traits for this event to show up
	var/required_site_traits
	/// If these site traits are present the event won't show up
	var/blacklisted_site_traits
	/// Optional description that will be added to site description when point scan is completed.
	var/point_scan_description
	/// Optional description that will be added to site description when point scan is completed.
	var/deep_scan_description

/datum/exploration_event/proc/ecounter(obj/item/exodrone/drone)
	if(discovery_log && !visited)
		drone.drone_log(get_discovery_message(drone))
	visited = TRUE

/// Override this if you need to modify discovery message
/datum/exploration_event/proc/get_discovery_message(obj/item/exodrone/drone)
	return discovery_log

/// Should this event show up on site exploration list.
/datum/exploration_event/proc/is_targetable()
	return FALSE

/// Just a message in the log nothing more
/datum/exploration_event/fluff
	name = "fluff event"

/datum/exploration_event/fluff/get_discovery_message(obj/item/exodrone/drone)
	return pick_list(EXODRONE_FILE,drone.location.fluff_type)

/// Not a full fledged adventure, consist only of single ecounter screen
/datum/exploration_event/simple
	root_abstract_type = /datum/exploration_event/simple
	var/ui_image = "default"
	/// Show ignore button.
	var/skippable = TRUE
	/// Ignore button text
	var/ignore_text = "Ignore"
	/// Action text, can be further parametrized in get_action_text()
	var/action_text = "Ecounter"
	/// Description, can be further parametrized in get_description()
	var/description = "You ecounter a bug."

/// On exploration, only display our information with the act/ignore options
/datum/exploration_event/simple/ecounter(obj/item/exodrone/drone)
	. = ..()
	drone.current_event_ui_data = build_ui_event(drone)

/// After choosing not to ignore the event, THIS IS DONE AFTER UNKNOWN DELAY SO YOU NEED TO VALIDATE IF ACTION IS POSSIBLE AGAIN
/datum/exploration_event/simple/proc/fire(obj/item/exodrone/drone)
	return

/// Ends simple event and cleans up display data
/datum/exploration_event/simple/proc/end(obj/item/exodrone/drone)
	drone.current_event_ui_data = null

/// Description shown below image
/datum/exploration_event/simple/proc/get_description(obj/item/exodrone/drone)
	return description

/// Text on the act button
/datum/exploration_event/simple/proc/get_action_text(obj/item/exodrone/drone)
	return action_text

/// Button to act disabled or not
/datum/exploration_event/simple/proc/action_enabled(obj/item/exodrone/drone)
	return TRUE

/// Creates ui data for displaying the event
/datum/exploration_event/simple/proc/build_ui_event(obj/item/exodrone/drone)
	. = list()
	.["image"] = ui_image
	.["description"] = get_description(drone)
	.["action_enabled"] = action_enabled(drone)
	.["action_text"] = get_action_text(drone)
	.["skippable"] = skippable
	.["ignore_text"] = ignore_text
	.["ref"] = ref(src)

/// Simple event type that checks if you have a tool and after a retrieval delay adds loot to drone.
/datum/exploration_event/simple/resource
	name = "Retrievable resource"
	root_abstract_type = /datum/exploration_event/simple/resource
	discovery_log = "Ecountered recoverable resource"
	action_text = "Extract"
	/// Tool type required to recover this resource
	var/required_tool
	/// What you get out of it, either /obj path or adventure_loot_generator id
	var/loot_type = /obj/item/trash/chips
	/// Message logged on success
	var/success_log = "Retrieved something"
	/// Description shown when you don't have the tool
	var/no_tool_description = "You can't retrieve it without a tool"
	/// Description shown when you have the necessary tool
	var/has_tool_description = "You can get it out with that tool."
	var/delay = 30 SECONDS
	var/delay_message = "Recovering resource..."
	/// How many times can this be extracted
	var/amount = 1

/// Description shown below image
/datum/exploration_event/simple/resource/get_description(obj/item/exodrone/drone)
	. = ..()
	var/list/desc_list = list(.)
	if(!required_tool || drone.has_tool(required_tool))
		desc_list += has_tool_description
	else
		desc_list += no_tool_description
	return desc_list.Join("\n")

/datum/exploration_event/simple/resource/action_enabled(obj/item/exodrone/drone)
	return (amount > 0) && (!required_tool || drone.has_tool(required_tool))

/datum/exploration_event/simple/resource/fire(obj/item/exodrone/drone)
	if(!action_enabled(drone)) //someone used it up or we lost the tool while we were looking at ui
		end()
		return
	amount--
	if(delay > 0)
		drone.set_busy(delay_message,delay)
		addtimer(CALLBACK(src,.proc/delay_finished,WEAKREF(drone)),delay)
	else
		finish_event(drone)

/datum/exploration_event/simple/resource/is_targetable()
	return visited && amount > 0 ///Can go back if something is left.

/datum/exploration_event/simple/resource/proc/delay_finished(datum/weakref/drone_ref)
	var/obj/item/exodrone/drone = drone_ref.resolve()
	if(QDELETED(drone)) //drone blown up in the meantime
		return
	drone.unset_busy(EXODRONE_EXPLORATION)
	finish_event(drone)

/datum/exploration_event/simple/resource/proc/finish_event(obj/item/exodrone/drone)
	drone.drone_log(success_log)
	dispense_loot(drone)
	end(drone)

/datum/exploration_event/simple/resource/proc/dispense_loot(obj/item/exodrone/drone)
	if(ispath(loot_type,/datum/adventure_loot_generator))
		var/datum/adventure_loot_generator/generator = new loot_type
		generator.transfer_loot(drone)
	else
		var/obj/loot = new loot_type()
		drone.try_transfer(loot)

/// If drone is loaded with X exchanges it for Y, might require translator tool.
/datum/exploration_event/simple/trader
	root_abstract_type = /datum/exploration_event/simple/trader
	action_text = "Trade"
	/// Obj path we'll take or list of paths ,one path will be picked from it at init
	var/required_path
	/// Obj path we'll give out or list of paths ,one path will be picked from it at init
	var/traded_path
	//How many times we'll allow the trade
	var/amount = 1
	var/requires_translator = TRUE

/datum/exploration_event/simple/trader/New()
	. = ..()
	if(islist(required_path))
		required_path = pick(required_path)
	if(islist(traded_path))
		traded_path = pick(traded_path)

/datum/exploration_event/simple/trader/get_discovery_message(obj/item/exodrone/drone)
	if(requires_translator && !drone.has_tool(EXODRONE_TOOL_TRANSLATOR))
		return "You ecountered [name] but could not understand what they want without a translator."
	var/obj/want = required_path
	var/obj/gives = traded_path
	return "Ecountered [name] willing to trade [initial(want.name)] for [initial(gives.name)]"

/datum/exploration_event/simple/trader/get_description(obj/item/exodrone/drone)
	if(requires_translator && !drone.has_tool(EXODRONE_TOOL_TRANSLATOR))
		return "You ecounter [name] but cannot understand what they want without a translator."
	var/obj/want = required_path
	var/obj/gives = traded_path
	return "You ecounter [name] willing to trade [initial(want.name)] for [initial(gives.name)]."

/datum/exploration_event/simple/trader/is_targetable()
	return visited && (amount > 0)

/datum/exploration_event/simple/trader/action_enabled(obj/item/exodrone/drone)
	var/obj/trade_good = locate(required_path) in drone.contents
	return (amount > 0) && trade_good && (!requires_translator || drone.has_tool(EXODRONE_TOOL_TRANSLATOR))

/datum/exploration_event/simple/trader/fire(obj/item/exodrone/drone)
	if(!action_enabled(drone))
		end(drone)
		return
	amount--
	trade(drone)
	end(drone)

/datum/exploration_event/simple/trader/proc/trade(obj/item/exodrone/drone)
	var/obj/trade_good = locate(required_path) in drone.contents
	var/obj/loot = new traded_path()
	drone.drone_log("Traded [trade_good] for [loot]")
	qdel(trade_good)
	drone.try_transfer(loot)

/// Danger event - unskippable, if you have appriopriate tool you can mitigate damage.
/datum/exploration_event/simple/danger
	root_abstract_type = /datum/exploration_event/simple/danger
	description = "You ecounter a giant error."
	var/required_tool = EXODRONE_TOOL_LASER
	var/has_tool_action_text = "Fight"
	var/no_tool_action_text = "Endure"
	var/has_tool_description = ""
	var/no_tool_description = ""
	var/avoid_log = "Escaped unharmed from danger."
	var/damage = 30
	skippable = FALSE

/datum/exploration_event/simple/danger/get_description(obj/item/exodrone/drone)
	. = ..()
	var/list/desc_parts = list(.)
	desc_parts += can_escape_danger(drone) ? has_tool_description : no_tool_description
	return desc_parts.Join("\n")

/datum/exploration_event/simple/danger/get_action_text(obj/item/exodrone/drone)
	return can_escape_danger(drone) ? has_tool_action_text : no_tool_action_text

/datum/exploration_event/simple/danger/proc/can_escape_danger(obj/item/exodrone/drone)
	return !required_tool || drone.has_tool(required_tool)

/datum/exploration_event/simple/danger/fire(obj/item/exodrone/drone)
	if(can_escape_danger(drone))
		drone.drone_log(avoid_log)
	else
		drone.damage(damage)
	end(drone)



/// Adventure wrapper event
/datum/exploration_event/adventure
	discovery_log = "Ecountered something unexpected"
	var/datum/adventure/adventure
	root_abstract_type = /datum/exploration_event/adventure

/datum/exploration_event/adventure/ecounter(obj/item/exodrone/drone)
	. = ..()
	drone.start_adventure(adventure)

/// Actual implementations.

/// Sites

/datum/exploration_site/abandoned_refueling_station
	name = "abandoned refueling station"
	description =  "old shuttle refueling station drifting through the void."
	band_info = list(EXOSCANNER_BAND_TECH = 1)
	site_traits = list(EXPLORATION_SITE_RUINS,EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)

/datum/exploration_site/trader_post
	name = "unregistered trading station"
	description = "Weak radio transmission advertises this place as RANDOMIZED_NAME"
	band_info = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_LIFE = 1)
	site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION,EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	fluff_type = "fluff_trading"

/datum/exploration_site/trader_post/New(band)
	. = ..()
	var/chosen_name = pick_list(EXODRONE_FILE,"trading_station_names")
	name = "\"[chosen_name]\" trading station"
	description = replacetext(description,"RANDOMIZED_NAME",chosen_name)

/datum/exploration_site/cargo_wreck
	name = "interstellar cargo ship wreckage"
	description = "wreckage of long-range cargo shuttle"
	band_info = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_DENSITY = 1)
	site_traits = list(EXPLORATION_SITE_SHIP,EXPLORATION_SITE_TECHNOLOGY)

/datum/exploration_site/alien_spaceship
	name = "ancient alien spaceship"
	description = "a gigantic spaceship of unknown origin, it doesnt respond to your hails but does not prevent you boarding either"
	band_info = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_RADIATION = 1)
	site_traits = list(EXPLORATION_SITE_SHIP,EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_ALIEN)

/datum/exploration_site/uncharted_planet
	name = "uncharted planet"
	description = "planet missing from nanotrasen starcharts."
	band_info = list(EXOSCANNER_BAND_LIFE = 3)
	site_traits = list(EXPLORATION_SITE_SURFACE)

/datum/exploration_site/uncharted_planet/New(band)
	/// Planet Type, Atmosphere
	var/list/planet_info = pick_list(EXODRONE_FILE,"planet_types")
	name = planet_info["name"]
	description = planet_info["description"]
	if(planet_info["habitable"])
		site_traits += EXPLORATION_SITE_HABITABLE
	if(planet_info["civilized"])
		site_traits += EXPLORATION_SITE_CIVILIZED
	if(planet_info["tech"])
		site_traits += EXPLORATION_SITE_TECHNOLOGY
	. = ..()

/datum/exploration_site/alien_ruins
	name = "alien ruins"
	description = "alien ruins on small moon surface."
	site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE,EXPLORATION_SITE_ALIEN,EXPLORATION_SITE_RUINS)
	fluff_type = "fluff_ruins"

/datum/exploration_site/asteroid_belt
	name = "asteroid belt"
	description = "dense asteroid belt"
	site_traits = list(EXPLORATION_SITE_SURFACE)
	fluff_type = "fluff_space"

/datum/exploration_site/spacemine
	name = "mining facility"
	description = "abandoned mining facility attached to ore-heavy asteroid"
	band_info = list(EXOSCANNER_BAND_PLASMA = 3)
	site_traits = list(EXPLORATION_SITE_RUINS,EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE)
	fluff_type = "fluff_ruins"

/datum/exploration_site/junkyard
	name = "space junk field"
	description = "a giant cluster of space junk."
	band_info = list(EXOSCANNER_BAND_DENSITY = 3)
	site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_SPACE)
	fluff_type = "fluff_space"

// Events

// All
/datum/exploration_event/simple/resource/concealed_cache
	name = "Concealed Cache"
	band_values = list(EXOSCANNER_BAND_DENSITY=1)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "Discovered concealed and locked cache."
	description = "You spot a cleverly hidden metal container."
	no_tool_description = "You see no way to open it without a welder."
	has_tool_description = "You can try to open it with your welder"
	action_text = "Weld open"
	delay_message = "Welding open the cache..."
	loot_type = /datum/adventure_loot_generator/maintenance

// EXPLORATION_SITE_RUINS 2/2
/datum/exploration_event/simple/resource/remnants
	name = "dessicated corpse"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "You discovered a corpse of a humanoid."
	description = "You find a dessicated corpose of a humanoid, it's too damaged to identify. A locked briefcase is lying nearby."
	no_tool_description = "You can't open it without a multiool"
	has_tool_description = "You can try to hack it open"
	action_text = "Hack open"
	delay_message = "Hacking..."
	loot_type = /datum/adventure_loot_generator/simple/cash

/datum/exploration_event/simple/resource/gunfight
	name = "gunfight leftovers"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "You discovered a site of some past gunfight."
	description = "You find a site full of gun casing and scorched with laser marks. You notice something under rubble nearby."
	no_tool_description = "You can't get to it without a drill"
	action_text = "Remove rubble"
	delay_message = "Drilling..."
	loot_type = /datum/adventure_loot_generator/simple/weapons

// EXPLORATION_SITE_TECHNOLOGY 2/2
/datum/exploration_event/simple/resource/maint_room
	name = "locked maintenance room"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "You discovered a locked maintenance room."
	success_log = "Retrieved contents of maintenance room."
	description = "You discover a locked maintenance room. You can see marks of something being moved often from it nearby."
	no_tool_description = "You can't open it without a multitool"
	action_text = "Hack"
	delay_message = "Hacking..."
	loot_type = /datum/adventure_loot_generator/maintenance
	amount = 3

/datum/exploration_event/simple/resource/storage
	name = "storage room"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "You discovered a storage room full of crates."
	success_log = "Used translated manifest to find a crate with double bottom."
	description = "You find a storage room full of empty crates. There's a manifest in some obscure language pinned near the entrance."
	no_tool_description = "You can only see empty crates, and can't understand the manifest without a translator."
	action_text = "Translate"
	delay_message = "Translating manifest..."
	loot_type = /datum/adventure_loot_generator/simple/drugs

// EXPLORATION_SITE_ALIEN 2/2
/datum/exploration_event/simple/resource/alien_tools
	name = "alien sarcophagus"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_TECH=1,EXOSCANNER_BAND_RADIATION=1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered a alien sarcophagus covered in unknown glyphs"
	success_log = "Retrieved contents of alien sarcophagus"
	description = "You find an giant sarcophagus of alien origin covered in unknown script."
	no_tool_description = "You see no way to open the sarcophagus or translate the glyphs without a tool."
	has_tool_description = "You translate the glyphs and find a description of a hidden mechanism for unlocking the tomb."
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /obj/item/scalpel/alien

/datum/exploration_event/simple/resource/pod
	name = "alien biopod"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_tool = EXODRONE_TOOL_LASER
	discovery_log = "Discovered an alien pod."
	success_log = "Retrieved contents of the alien pod"
	description = "You ecounter an alien biomachinery full of sacks containing some lifeform."
	no_tool_description = "You can't open them without precise laser."
	has_tool_description = "You can try to cut one open with a laser."
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /datum/adventure_loot_generator/pet

// EXPLORATION_SITE_SHIP 1/2
/datum/exploration_event/simple/resource/fuel_storage
	name = "fuel storage"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	band_values = list(EXOSCANNER_BAND_PLASMA=1)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Discovered ship fuel storage."
	description = "You find the ship fuel storage. Unfortunately it's locked with electronic lock."
	success_log = "Retrieved fuel from storage."
	no_tool_description = "You'll need multitool to open it."
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /obj/item/fuel_pellet/exotic

/datum/exploration_event/simple/resource/navigation
	name = "navigation systems"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered ship navigation systems."
	description = "You find the ship navigation systems. With proper tools you can retrieve any data stored here."
	success_log = "Retrieved data from ships navigation systems."
	no_tool_description = "You'll need a translator to decipher the data."
	delay_message = "Retrieving data..."
	action_text = "Retrieve data"
	loot_type = /datum/adventure_loot_generator/cargo

// EXPLORATION_SITE_HABITABLE 2/2
/datum/exploration_event/simple/resource/unknown_microbiome
	name = "unknown microbiome"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered a isolated microbiome."
	description = "You discover a giant fungus colony."
	success_log = "Retrieved samples of the fungus for future study."
	no_tool_description = "With a laser tool you could slice off a sample for study."
	delay_message = "Taking samples..."
	action_text = "Take sample"
	loot_type = /obj/item/petri_dish/random

/datum/exploration_event/simple/resource/tcg_nerd
	name = "creepy stranger"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Met a creepy stranger."
	description = "You meet an inhabitant of this site. Smelling horribly and clearly agitated about something."
	no_tool_description = "You have no idea what it wants from you without a translator."
	has_tool_description = "Your best translation is that it wants to share its hobby with you. "
	success_log = "Recieved a gift from a stranger."
	delay_message = "Enduring..."
	action_text = "Accept gift."
	loot_type = /obj/item/cardpack/series_one

// EXPLORATION_SITE_SPACE 2/2
/datum/exploration_event/simple/resource/comms_satellite
	name = "derelict comms satellite"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "You discovered a derelict communication satellite."
	description = "You discover a derelict communication satellite. Its encryption module seem intact and can be retrieved."
	no_tool_description = "You'll need a multiool to crack open the lock."
	success_log = "Retrieved encryption keys from derelict satellite"
	delay_message = "Hacking..."
	action_text = "Hack lock"
	loot_type = /obj/item/encryptionkey/heads/captain

/datum/exploration_event/simple/resource/welded_locker
	name = "welded locker"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "You discovered a welded shut locker."
	description = "You discover a welded shut locker floating through space. What could be inside ?"
	success_log = "Retrieved bones of unfortunate spaceman from a welded locker."
	delay_message = "Welding open..."
	action_text = "Weld open"
	loot_type = /obj/item/bodypart/head

/datum/exploration_event/simple/resource/welded_locker/dispense_loot(obj/item/exodrone/drone)
	var/mob/living/carbon/human/head_species_source = new
	head_species_source.set_species(/datum/species/skeleton)
	head_species_source.real_name = "spaced locker victim"
	var/obj/item/bodypart/head/skeleton_head = new
	skeleton_head.update_limb(FALSE,head_species_source)
	qdel(head_species_source)
	drone.try_transfer(skeleton_head)

// EXPLORATION_SITE_SURFACE 2/2
/datum/exploration_event/simple/resource/plasma_deposit
	name = "Raw Plasma Deposit"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_PLASMA=3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a sizeable plasma deposit"
	success_log = "Extracted plasma."
	description = "You locate a rich surface deposit of plasma."
	no_tool_description = "You'll need to come back with a drill to mine it."
	has_tool_description = ""
	action_text = "Mine"
	delay_message = "Mining..."
	loot_type = /obj/item/stack/sheet/mineral/plasma{amount = 30}

/datum/exploration_event/simple/resource/mineral_deposit
	name = "MATERIAL Deposit"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_DENSITY=3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a sizeable MATRIAL deposit"
	success_log = "Extracted MATERIAL."
	description = "You locate a rich surface deposit of MATERIAL."
	no_tool_description = "You'll need to come back with a drill to mine it."
	has_tool_description = ""
	action_text = "Mine"
	delay_message = "Mining..."
	var/static/list/possible_materials = list(/datum/material/silver,/datum/material/bananium,/datum/material/pizza) //only add materials with sheet type here
	var/loot_amount = 30
	var/chosen_material_type

/datum/exploration_event/simple/resource/mineral_deposit/New()
	. = ..()
	chosen_material_type = pick(possible_materials)
	var/datum/material/chosen_mat = GET_MATERIAL_REF(chosen_material_type)
	name = "[chosen_mat.name] Deposit"
	discovery_log = "Discovered a sizeable [chosen_mat.name] deposit"
	success_log = "Extracted [chosen_mat.name]."
	description = "You locate a rich surface deposit of [chosen_mat.name]."

/datum/exploration_event/simple/resource/mineral_deposit/dispense_loot(obj/item/exodrone/drone)
	var/datum/material/chosen_mat = GET_MATERIAL_REF(chosen_material_type)
	var/obj/loot = new chosen_mat.sheet_type(loot_amount)
	drone.try_transfer(loot)


/// Trade events 5/10

/datum/exploration_event/simple/trader/vendor_ai
	name = "sentient drug vending machine"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY)
	band_values = list(EXOSCANNER_BAND_TECH=2)
	requires_translator = FALSE
	required_path = /obj/item/stock_parts/cell/high
	traded_path = /obj/item/storage/pill_bottle/happy
	amount = 3

/datum/exploration_event/simple/trader/farmer_market
	name = "farmer's market"
	deep_scan_description = "You detect a spot with unusal concentraction of edibles on the site."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_LIFE=2)
	required_path = /obj/item/stock_parts/manipulator/nano
	traded_path = list(/obj/item/seeds/tomato/killer,/obj/item/seeds/orange_3d,/obj/item/seeds/firelemon,/obj/item/seeds/gatfruit)
	amount = 1

/datum/exploration_event/simple/trader/fish
	name = "interstellar fish trader"
	requires_translator = FALSE
	deep_scan_description = "You spot gian \"FRESH FISH\" sign on the site."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_LIFE=2)
	required_path = /obj/item/stock_parts/cell/high
	traded_path = /obj/item/storage/fish_case/random
	amount = 3

/datum/exploration_event/simple/trader/shady_merchant
	name = "shady merchant"
	requires_translator = FALSE
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_path = list(/obj/item/organ/heart,/obj/item/organ/liver,/obj/item/organ/stomach,/obj/item/organ/eyes)
	traded_path = list(/obj/item/implanter/explosive)
	amount = 1

/datum/exploration_event/simple/trader/surplus
	name = "military surplus trader"
	deep_scan_description = "You decrypt a transmission advertising military surplus sale on the site."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_path = list(/obj/item/clothing/suit/armor,/obj/item/clothing/shoes/jackboots)
	traded_path = /obj/item/gun/energy/laser/retro/old
	amount = 3

/datum/exploration_event/simple/trader/flame_card
	name = "id card artisan"
	deep_scan_description = "You spy a adveristment for an id card customization workshop."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_TECH=1)
	required_path = list(/obj/item/card/id) //If you trade a better card for worse that's on you
	traded_path = null
	requires_translator = FALSE
	amount = 1
	var/static/list/possible_card_states = list("card_flames","card_carp","card_rainbow")

/datum/exploration_event/simple/trader/flame_card/get_discovery_message(obj/item/exodrone/drone)
	return "Ecountered [name] willing to customize any id card you bring them."

/datum/exploration_event/simple/trader/flame_card/get_description(obj/item/exodrone/drone)
	return "You ecounter local craftsman willing to improve an id card for you free of charge."

/datum/exploration_event/simple/trader/flame_card/trade(obj/item/exodrone/drone)
	var/obj/item/card/id/card = locate(required_path) in drone.contents
	card.icon_state = pick(possible_card_states)
	card.update_icon() //Refresh cached helper image
	drone.drone_log("Let artisan work on [card.name].")


/// Danger events 1 per site type

/datum/exploration_event/simple/danger/carp
	name = "space carp attack"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	blacklisted_site_traits = list(EXPLORATION_SITE_CIVILIZED)
	deep_scan_description = "You detect damage patterns to the site hinting at a presence of space carp."
	description = "You are ambushed by a solitary space carp!"
	has_tool_action_text = "Fight"
	no_tool_action_text = "Escape!"
	has_tool_description = "You charge your laser to fend it off."
	no_tool_description = "Unfortunately you have no weaponry so the only option is flight."
	avoid_log = "Defeated a space carp."

/// They get everywhere
/datum/exploration_event/simple/danger/carp/surface_variety
	required_site_traits = list(EXPLORATION_SITE_SURFACE)

/datum/exploration_event/simple/danger/assistant
	name = "assistant attack"
	required_site_traits = list(EXPLORATION_SITE_STATION)
	deep_scan_description = "Detected mask usage coefficent suggests a sizeable crowd of undersirables on the site."
	description = "You ecounter a shaggy creature dressed in gray! It's a deranged assistant!"
	has_tool_action_text = "Fight"
	no_tool_action_text = "Escape!"
	has_tool_description = "You charge your laser to fend it off."
	no_tool_description = "Unfortunately you have no weaponry so the only option is flight."
	avoid_log = "Defeated an assistant."

/datum/exploration_event/simple/danger/collapse
	name = "collapse"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	deep_scan_description = "The architecture of the site is unstable, caution advised."
	description = "A damaged ceiling gives up as you search an unexplored passage! You're trapped by the debris."
	has_tool_action_text = "Dig out"
	no_tool_action_text = "Squeeze."
	has_tool_description = "You can use your drill to get out."
	no_tool_description = "You'll have to scrape a few parts to get out without any tools."
	avoid_log = "Dug out of collapsed passage."

/datum/exploration_event/simple/danger/loose_wires
	name = "loose wires"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Damaged wiring detected on site."
	description = "You hear a loud snap behind you! A stack of sparking high-voltage wires is blocking you way out."
	has_tool_action_text = "Disable power"
	no_tool_action_text = "Get fried."
	has_tool_description = "You can try to use your multitool to shut down power to escape."
	no_tool_description = "You'll have to risk frying your electronics getting out."
	avoid_log = "Escaped loose wire."

/datum/exploration_event/simple/danger/cosmic_rays
	name = "cosmic ray burst"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Site is exposed to space radiation. Using self-diagnostic multiool attachment advised."
	description = "Drone feed suddenly goes haywire! It seems that the drone got hit by extremely rare cosmic ray burst! You'll have to wait for signal to be restored."
	has_tool_description = "Multitool extension self-diagnostic attachement should deal with most of the damage automatically."
	no_tool_description = "Nothing more to be done than wait and asses the damage."
	has_tool_action_text = "Wait"
	no_tool_action_text = "Wait"
	avoid_log = "Prevented cosmic ray damage with multitool"

/datum/exploration_event/simple/danger/alien_sentry
	name = "alien security measure"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	deep_scan_description = "Automated security measures of unknown origin detected on site."
	description = "A dangerous looking machine slides out the floor and start flashing strange glyphs while emitting high-pitched sound."
	has_tool_description = "Your translator recognizes the glyphs as security hail and suggests identyfing yourself as guest."
	no_tool_description = "The machine start shooting soon after."
	has_tool_action_text = "Identify yourself"
	no_tool_action_text = "Escape"
	avoid_log = "Avoided alien security"

/datum/exploration_event/simple/danger/beast
	name = "alien ecounter"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	blacklisted_site_traits = list(EXPLORATION_SITE_CIVILIZED)
	required_tool = EXODRONE_TOOL_LASER
	deep_scan_description = "Dangerous fauna detected on site."
	description = "You ecounter BEAST. It prepares to strike."
	has_tool_action_text = "Fight"
	no_tool_action_text = "Escape"
	has_tool_description = "You ready your laser."
	no_tool_description = "Time to run."
	avoid_log = "Defeated BEAST"

/datum/exploration_event/simple/danger/beast/New()
	. = ..()
	var/beast_name = pick_list(EXODRONE_FILE,"alien_fauna")
	description = replacetext(description,"BEAST",beast_name)
	avoid_log = replacetext(avoid_log,"BEAST",beast_name)

/datum/exploration_event/simple/danger/rad
	name = "irradiated section"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Sections of the vessel are irradiated."
	description = "You enter a nondescript ship section."
	has_tool_action_text = "Detour"
	no_tool_action_text = "Escape and mitigate damage."
	has_tool_description = "Your multitool suddenly screams in warning! Section ahead is irradiated, you'll have to go around"
	no_tool_description = "Suddenly the drone reports significant damage, it seems this section was heavily irradiated."
	avoid_log = "Avoided irradiated section"

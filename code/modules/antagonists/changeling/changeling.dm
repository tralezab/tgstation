#define LING_FAKEDEATH_TIME 400 //40 seconds
#define LING_DEAD_GENETICDAMAGE_HEAL_CAP 50 //The lowest value of geneticdamage handle_changeling() can take it to while dead.
#define LING_ABSORB_RECENT_SPEECH 8 //The amount of recent spoken lines to gain on absorbing a mob

/datum/antagonist/changeling
	name = "Changeling"
	roundend_category  = "changelings"
	antagpanel_category = "Changeling"
	job_rank = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/focused
	antag_hud_type = ANTAG_HUD_CHANGELING
	antag_hud_name = "changeling"
	hijack_speed = 0.5
	var/you_are_greet = TRUE
	var/give_objectives = TRUE
	var/competitive_objectives = FALSE //Should we assign objectives in competition with other lings?

	//Changeling Stuff
	/// if this changeling has done something that revealed itself
	var/is_obvious = FALSE
	var/list/stored_profiles = list() //list of datum/changelingprofile
	var/datum/changelingprofile/first_prof = null
	var/dna_max = 6 //How many extra DNA strands the changeling can store for transformation.
	var/absorbedcount = 0
	var/trueabsorbs = 0//dna gained using absorb, not dna sting
	var/chem_charges = 20
	var/chem_storage = 75
	var/chem_recharge_rate = 1
	var/chem_recharge_slowdown = 0
	var/sting_range = 2
	var/geneticdamage = 0
	var/was_absorbed = FALSE //if they were absorbed by another ling already.
	var/isabsorbing = FALSE
	var/islinking = FALSE
	var/geneticpoints = 10
	var/total_geneticspoints = 10
	var/total_chem_storage = 75
	var/powers = list()

	var/mimicing = ""
	var/canrespec = FALSE//set to TRUE in absorb.dm
	var/changeling_speak = 0
	var/datum/dna/chosen_dna
	var/datum/action/changeling/sting/chosen_sting

	var/static/list/all_powers = typecacheof(/datum/action/changeling,TRUE)

/datum/antagonist/changeling/New()
	. = ..()
	for(var/datum/antagonist/changeling/C in GLOB.antagonists)
		if(!C.owner || C.owner == owner)
			continue
		if(C.was_absorbed) //make sure the other ling wasn't already killed by another one. only matters if the changeling that absorbed them was gibbed after.
			continue
		competitive_objectives = TRUE
		break

/datum/antagonist/changeling/on_gain()
	reset_powers()
	create_initial_profile()
	if(give_objectives)
		forge_objectives()
	owner.current.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue. We are able to transform our body after all.
	. = ..()

/datum/antagonist/changeling/on_removal()
	//We'll be using this from now on
	var/mob/living/carbon/C = owner.current
	if(istype(C))
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(B && (B.decoy_override != initial(B.decoy_override)))
			B.organ_flags |= ORGAN_VITAL
			B.decoy_override = FALSE
	remove_changeling_powers()
	. = ..()

/datum/antagonist/changeling/proc/reset_properties()
	changeling_speak = 0
	chosen_sting = null
	geneticpoints = total_geneticspoints
	sting_range = initial(sting_range)
	chem_storage = total_chem_storage
	chem_recharge_rate = initial(chem_recharge_rate)
	chem_charges = min(chem_charges, chem_storage)
	chem_recharge_slowdown = initial(chem_recharge_slowdown)
	mimicing = ""

/datum/antagonist/changeling/proc/remove_changeling_powers()
	if(ishuman(owner.current))
		reset_properties()
		for(var/datum/action/changeling/p in powers)
			powers -= p
			p.Remove(owner.current)

	//MOVE THIS
	if(owner.current.hud_used && owner.current.hud_used.lingstingdisplay)
		owner.current.hud_used.lingstingdisplay.icon_state = null
		owner.current.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/datum/antagonist/changeling/proc/reset_powers()
	if(powers)
		remove_changeling_powers()
	//Repurchase free powers.
	for(var/datum/action/changeling/sting as anything in all_powers)
		if(!initial(sting.button_icon_state))
			continue //probably a prototype
		if(initial(sting.ascended_ability))
			continue //they need to earn this
		sting = new sting
		powers += sting
		sting.on_purchase(owner.current,TRUE)

	for(var/power in powers)
		var/datum/action/changeling/S = power
		if(istype(S) && S.needs_button)
			S.Grant(owner.current)

///Handles stinging without verbs.
/datum/antagonist/changeling/proc/stingAtom(mob/living/carbon/ling, atom/A)
	SIGNAL_HANDLER_DOES_SLEEP

	if(!chosen_sting || A == ling || !istype(ling) || ling.stat)
		return
	if(!chosen_sting.try_to_sting(ling, A))
		return
	ling.changeNext_move(CLICK_CD_MELEE)
	return COMSIG_MOB_CANCEL_CLICKON

//Called in life()
/datum/antagonist/changeling/proc/regenerate()//grants the HuD in life.dm
	var/mob/living/carbon/the_ling = owner.current
	if(istype(the_ling))
		if(the_ling.stat == DEAD)
			chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), (chem_storage*0.5))
			geneticdamage = max(LING_DEAD_GENETICDAMAGE_HEAL_CAP,geneticdamage-1)
		else //not dead? no chem/geneticdamage caps.
			chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
			geneticdamage = max(0, geneticdamage-1)


/datum/antagonist/changeling/proc/get_dna(dna_owner)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(dna_owner == prof.name)
			return prof

/datum/antagonist/changeling/proc/has_dna(datum/dna/tDNA)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(tDNA.is_same_as(prof.dna))
			return TRUE
	return FALSE

/datum/antagonist/changeling/proc/can_absorb_dna(mob/living/carbon/human/target, verbose=1)
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return
	if(stored_profiles.len)
		var/datum/changelingprofile/prof = stored_profiles[1]
		if(prof.dna == user.dna && stored_profiles.len >= dna_max)//If our current DNA is the stalest, we gotta ditch it.
			if(verbose)
				to_chat(user, "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>")
			return
	if(!target)
		return
	if(NO_DNA_COPY in target.dna.species.species_traits)
		if(verbose)
			to_chat(user, "<span class='warning'>[target] is not compatible with our biology.</span>")
		return
	if(HAS_TRAIT(target, TRAIT_BADDNA))
		if(verbose)
			to_chat(user, "<span class='warning'>DNA of [target] is ruined beyond usability!</span>")
		return
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(verbose)
			to_chat(user, "<span class='warning'>[target]'s body is ruined beyond usability!</span>")
		return
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		if(verbose)
			to_chat(user, "<span class='warning'>We could gain no benefit from absorbing a lesser creature.</span>")
		return
	if(has_dna(target.dna))
		if(verbose)
			to_chat(user, "<span class='warning'>We already have this DNA in storage!</span>")
		return
	if(!target.has_dna())
		if(verbose)
			to_chat(user, "<span class='warning'>[target] is not compatible with our biology.</span>")
		return
	return TRUE


/datum/antagonist/changeling/proc/create_profile(mob/living/carbon/human/H, protect = 0)
	var/datum/changelingprofile/prof = new

	H.dna.real_name = H.real_name //Set this again, just to be sure that it's properly set.
	var/datum/dna/new_dna = new H.dna.type
	H.dna.copy_dna(new_dna)
	prof.dna = new_dna
	prof.name = H.real_name
	prof.protected = protect

	prof.underwear = H.underwear
	prof.undershirt = H.undershirt
	prof.socks = H.socks

	prof.skillchips = H.clone_skillchip_list(TRUE)

	for(var/i in H.all_scars)
		var/datum/scar/iter_scar = i
		LAZYADD(prof.stored_scars, iter_scar.format())

	var/datum/icon_snapshot/entry = new
	entry.name = H.name
	entry.icon = H.icon
	entry.icon_state = H.icon_state
	entry.overlays = H.get_overlays_copy(list(HANDS_LAYER, HANDCUFF_LAYER, LEGCUFF_LAYER))
	prof.profile_snapshot = entry

	if(H.wear_id?.GetID())
		prof.id_icon = "hud[ckey(H.wear_id.GetJobName())]"

	var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")
	for(var/slot in slots)
		if(slot in H.vars)
			var/obj/item/clothing/I = H.vars[slot]
			if(!I)
				continue
			prof.name_list[slot] = I.name
			prof.appearance_list[slot] = I.appearance
			prof.flags_cover_list[slot] = I.flags_cover
			prof.lefthand_file_list[slot] = I.lefthand_file
			prof.righthand_file_list[slot] = I.righthand_file
			prof.inhand_icon_state_list[slot] = I.inhand_icon_state
			prof.worn_icon_list[slot] = I.worn_icon
			prof.worn_icon_state_list[slot] = I.worn_icon_state
			prof.exists_list[slot] = 1
		else
			continue

	return prof

/datum/antagonist/changeling/proc/add_profile(datum/changelingprofile/prof)
	if(stored_profiles.len > dna_max)
		if(!push_out_profile())
			return

	if(!first_prof)
		first_prof = prof

	stored_profiles += prof
	absorbedcount++

/datum/antagonist/changeling/proc/add_new_profile(mob/living/carbon/human/H, protect = 0)
	var/datum/changelingprofile/prof = create_profile(H, protect)
	add_profile(prof)
	return prof

/datum/antagonist/changeling/proc/remove_profile(mob/living/carbon/human/H, force = 0)
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(H.real_name == prof.name)
			if(prof.protected && !force)
				continue
			stored_profiles -= prof
			qdel(prof)

/datum/antagonist/changeling/proc/get_profile_to_remove()
	for(var/datum/changelingprofile/prof in stored_profiles)
		if(!prof.protected)
			return prof

/datum/antagonist/changeling/proc/push_out_profile()
	var/datum/changelingprofile/removeprofile = get_profile_to_remove()
	if(removeprofile)
		stored_profiles -= removeprofile
		return TRUE
	return FALSE


/datum/antagonist/changeling/proc/create_initial_profile()
	var/mob/living/carbon/C = owner.current //only carbons have dna now, so we have to typecaste
	if(ishuman(C))
		add_new_profile(C)

/datum/antagonist/changeling/proc/become_obvious()
	var/mob/living/carbon/human/obvious_changeling = owner.current
	if(is_obvious || !obvious_changeling || !istype(obvious_changeling))
		return
	is_obvious = TRUE
	to_chat(obvious_changeling, "<span class='userdanger'>Our true form is being made clear!</span>")

	obvious_changeling.dropItemToGround(obvious_changeling.head)
	obvious_changeling.dropItemToGround(obvious_changeling.wear_suit)

	var/obj/item/clothing/suit/armor/changeling/ling_suit = new /obj/item/clothing/suit/armor/changeling(obvious_changeling)
	var/obj/item/clothing/head/helmet/changeling/ling_helmet = new /obj/item/clothing/head/helmet/changeling(obvious_changeling)

	obvious_changeling.equip_to_slot_if_possible(ling_suit, ITEM_SLOT_OCLOTHING, 1, 1, 1)
	obvious_changeling.equip_to_slot_if_possible(ling_helmet, ITEM_SLOT_HEAD, 1, 1, 1)
	var/list/tendril_range = orange(3, obvious_changeling)
	for(var/i in 1 to rand(4,7))
		var/turf/target_turf = pick_n_take(tendril_range)
		obvious_changeling.Beam(target_turf, icon_state = "tentacle", time = 5 SECONDS)
	addtimer(CALLBACK(src,.proc/become_hidden, obvious_changeling, ling_suit, ling_helmet), 5 SECONDS)

/datum/antagonist/changeling/proc/become_hidden(mob/living/obvious_changeling, suit, helmet)
	to_chat(obvious_changeling, "<span class='warning'>Our true form is once again concealed.</span>")
	obvious_changeling.temporarilyRemoveItemFromInventory(suit, force = TRUE)
	qdel(suit)
	obvious_changeling.temporarilyRemoveItemFromInventory(helmet, force = TRUE)
	qdel(helmet)
	is_obvious = FALSE

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin."
	icon_state = "lingarmor"
	item_flags = DROPDEL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 10, BIO = 4, RAD = 0, FIRE = 90, ACID = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0

/obj/item/clothing/suit/armor/changeling/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!</span>", "<span class='warning'>We harden our flesh, creating a suit of armor!</span>", "<span class='hear'>You hear organic matter ripping and tearing!</span>")

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon_state = "lingarmorhelmet"
	item_flags = DROPDEL
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 10, BIO = 4, RAD = 0, FIRE = 90, ACID = 90)
	flags_inv = HIDEEARS|HIDEHAIR|HIDEEYES|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT

/obj/item/clothing/head/helmet/changeling/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

/datum/antagonist/changeling/apply_innate_effects(mob/living/mob_override)
	//Brains optional.
	var/mob/living/carbon/C = owner.current
	if(istype(C))
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(B)
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE
		RegisterSignal(C, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON), .proc/stingAtom)
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)
	handle_clown_mutation(M, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")

/datum/antagonist/changeling/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)
	handle_clown_mutation(M, removing = FALSE)
	UnregisterSignal(owner.current, list(COMSIG_MOB_MIDDLECLICKON, COMSIG_MOB_ALTCLICKON))


/datum/antagonist/changeling/greet()
	if (you_are_greet)
		to_chat(owner.current, "<span class='boldannounce'>You are a changeling! You have absorbed and taken the form of a human.</span>")
	to_chat(owner.current, "<b>You must complete the following tasks:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

	owner.announce_objectives()

/datum/antagonist/changeling/farewell()
	to_chat(owner.current, "<span class='userdanger'>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</span>")


/datum/antagonist/changeling/proc/forge_objectives()
	//OBJECTIVES - random traitor objectives. Unique objectives "steal brain" and "identity theft".
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/escape_objective_possible = TRUE

	switch(competitive_objectives ? rand(1,3) : 1)
		if(1)
			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = owner
			absorb_objective.gen_amount_goal(6, 8)
			objectives += absorb_objective
		if(2)
			var/datum/objective/absorb_most/ac = new
			ac.owner = owner
			objectives += ac
		if(3)
			var/datum/objective/absorb_changeling/ac = new
			ac.owner = owner
			objectives += ac

	if(prob(60))
		if(prob(85))
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
		else
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			objectives += download_objective

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(100/GLOB.joined_player_list.len))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = owner
		destroy_objective.find_target()
		objectives += destroy_objective
	else
		if(prob(70))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
		else
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			objectives += maroon_objective

			if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
				var/datum/objective/escape/escape_with_identity/identity_theft = new
				identity_theft.owner = owner
				identity_theft.target = maroon_objective.target
				identity_theft.update_explanation_text()
				objectives += identity_theft
				escape_objective_possible = FALSE

	if (!(locate(/datum/objective/escape) in objectives) && escape_objective_possible)
		if(prob(50))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = owner
			identity_theft.find_target()
			objectives += identity_theft
		escape_objective_possible = FALSE


/datum/antagonist/changeling/admin_add(datum/mind/new_owner,mob/admin)
	. = ..()
	to_chat(new_owner.current, "<span class='boldannounce'>Our powers have awoken. A flash of memory returns to us...we are a changeling!</span>")

/datum/antagonist/changeling/get_admin_commands()
	. = ..()
	if(stored_profiles.len && (owner.current.real_name != first_prof.name))
		.["Transform to initial appearance."] = CALLBACK(src,.proc/admin_restore_appearance)

/datum/antagonist/changeling/proc/admin_restore_appearance(mob/admin)
	if(!stored_profiles.len || !iscarbon(owner.current))
		to_chat(admin, "<span class='danger'>Resetting DNA failed!</span>")
	else
		var/mob/living/carbon/C = owner.current
		first_prof.dna.transfer_identity(C, transfer_SE=1)
		C.real_name = first_prof.name
		C.updateappearance(mutcolor_update=1)
		C.domutcheck()

// Profile

/datum/changelingprofile
	var/name = "a bug"

	var/protected = 0

	var/datum/dna/dna = null
	var/list/name_list = list() //associative list of slotname = itemname
	var/list/appearance_list = list()
	var/list/flags_cover_list = list()
	var/list/exists_list = list()
	var/list/lefthand_file_list = list()
	var/list/righthand_file_list = list()
	var/list/inhand_icon_state_list = list()
	var/list/worn_icon_list = list()
	var/list/worn_icon_state_list = list()

	var/underwear
	var/undershirt
	var/socks

	var/list/skillchips = list()
	/// What scars the target had when we copied them, in string form (like persistent scars)
	var/list/stored_scars
	/// Icon snapshot of the profile
	var/datum/icon_snapshot/profile_snapshot
	/// ID HUD icon associated with the profile
	var/id_icon

/datum/changelingprofile/Destroy()
	qdel(dna)
	LAZYCLEARLIST(stored_scars)
	. = ..()

/datum/changelingprofile/proc/copy_profile(datum/changelingprofile/newprofile)
	newprofile.name = name
	newprofile.protected = protected
	newprofile.dna = new dna.type
	dna.copy_dna(newprofile.dna)
	newprofile.name_list = name_list.Copy()
	newprofile.appearance_list = appearance_list.Copy()
	newprofile.flags_cover_list = flags_cover_list.Copy()
	newprofile.exists_list = exists_list.Copy()
	newprofile.lefthand_file_list = lefthand_file_list.Copy()
	newprofile.righthand_file_list = righthand_file_list.Copy()
	newprofile.inhand_icon_state_list = inhand_icon_state_list.Copy()
	newprofile.underwear = underwear
	newprofile.undershirt = undershirt
	newprofile.socks = socks
	newprofile.worn_icon_list = worn_icon_list.Copy()
	newprofile.worn_icon_state_list = worn_icon_state_list.Copy()
	newprofile.skillchips = skillchips.Copy()
	newprofile.stored_scars = stored_scars.Copy()
	newprofile.profile_snapshot = profile_snapshot
	newprofile.id_icon = id_icon

/datum/antagonist/changeling/roundend_report()
	var/list/parts = list()

	var/changelingwin = TRUE
	if(!owner.current)
		changelingwin = FALSE

	parts += printplayer(owner)

	//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
	parts += "<b>Genomes Extracted:</b> [absorbedcount]"
	parts += " "
	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</b></span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				changelingwin = FALSE
			count++

	if(changelingwin)
		parts += "<span class='greentext'>The changeling was successful!</span>"
	else
		parts += "<span class='redtext'>The changeling has failed.</span>"

	return parts.Join("<br>")


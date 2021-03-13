GLOBAL_LIST_INIT(arcade_prize_pool, list(
		/obj/item/storage/box/snappops = 2,
		/obj/item/toy/talking/ai = 2,
		/obj/item/toy/talking/codex_gigas = 2,
		/obj/item/clothing/under/syndicate/tacticool = 2,
		/obj/item/toy/sword = 2,
		/obj/item/toy/gun = 2,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 2,
		/obj/item/storage/box/fakesyndiesuit = 2,
		/obj/item/storage/crayons = 2,
		/obj/item/toy/spinningtoy = 2,
		/obj/item/toy/balloon/arrest = 2,
		/obj/item/toy/prize/ripley = 1,
		/obj/item/toy/prize/fireripley = 1,
		/obj/item/toy/prize/deathripley = 1,
		/obj/item/toy/prize/gygax = 1,
		/obj/item/toy/prize/durand = 1,
		/obj/item/toy/prize/honk = 1,
		/obj/item/toy/prize/marauder = 1,
		/obj/item/toy/prize/seraph = 1,
		/obj/item/toy/prize/mauler = 1,
		/obj/item/toy/prize/odysseus = 1,
		/obj/item/toy/prize/phazon = 1,
		/obj/item/toy/prize/reticence = 1,
		/obj/item/toy/prize/clarke = 1,
		/obj/item/toy/cards/deck = 2,
		/obj/item/toy/nuke = 2,
		/obj/item/toy/minimeteor = 2,
		/obj/item/toy/redbutton = 2,
		/obj/item/toy/talking/owl = 2,
		/obj/item/toy/talking/griffin = 2,
		/obj/item/coin/antagtoken = 2,
		/obj/item/stack/tile/fakespace/loaded = 2,
		/obj/item/stack/tile/fakepit/loaded = 2,
		/obj/item/stack/tile/eighties/loaded = 2,
		/obj/item/toy/toy_xeno = 2,
		/obj/item/storage/box/actionfigure = 1,
		/obj/item/restraints/handcuffs/fake = 2,
		/obj/item/grenade/chem_grenade/glitter/pink = 1,
		/obj/item/grenade/chem_grenade/glitter/blue = 1,
		/obj/item/grenade/chem_grenade/glitter/white = 1,
		/obj/item/toy/eightball = 2,
		/obj/item/toy/windup_toolbox = 2,
		/obj/item/toy/clockwork_watch = 2,
		/obj/item/toy/toy_dagger = 2,
		/obj/item/extendohand/acme = 1,
		/obj/item/hot_potato/harmless/toy = 1,
		/obj/item/card/emagfake = 1,
		/obj/item/clothing/shoes/wheelys = 2,
		/obj/item/clothing/shoes/kindle_kicks = 2,
		/obj/item/toy/plush/goatplushie = 2,
		/obj/item/toy/plush/moth = 2,
		/obj/item/toy/plush/pkplush = 2,
		/obj/item/storage/belt/military/snack = 2,
		/obj/item/toy/brokenradio = 2,
		/obj/item/toy/braintoy = 2,
		/obj/item/toy/eldritch_book = 2,
		/obj/item/storage/box/heretic_box = 1,
		/obj/item/toy/foamfinger = 2,
		/obj/item/clothing/glasses/trickblindfold = 2))

/obj/machinery/computer/arcade
	name = "random arcade"
	desc = "random arcade machine"
	icon_state = "arcade"
	icon_keyboard = "no_keyboard"
	icon_screen = "invaders"
	light_color = LIGHT_COLOR_GREEN
	var/list/prize_override

/obj/machinery/computer/arcade/proc/Reset()
	return

/obj/machinery/computer/arcade/Initialize()
	. = ..()

	Reset()

/obj/machinery/computer/arcade/proc/prizevend(mob/user, prizes = 1)
	SEND_SIGNAL(user, COMSIG_ARCADE_PRIZEVEND, user, prizes)
	if(user.mind?.get_skill_level(/datum/skill/gaming) >= SKILL_LEVEL_LEGENDARY && HAS_TRAIT(user, TRAIT_GAMERGOD))
		visible_message("<span class='notice'>[user] inputs an intense cheat code!",\
		"<span class='notice'>You hear a flurry of buttons being pressed.</span>")
		say("CODE ACTIVATED: EXTRA PRIZES.")
		prizes *= 2
	for(var/i = 0, i < prizes, i++)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "arcade", /datum/mood_event/arcade)
		if(prob(0.0001)) //1 in a million
			new /obj/item/gun/energy/pulse/prize(src)
			visible_message("<span class='notice'>[src] dispenses.. woah, a gun! Way past cool.</span>", "<span class='notice'>You hear a chime and a shot.</span>")
			user.client.give_award(/datum/award/achievement/misc/pulse, user)
			return

		var/prizeselect
		if(prize_override)
			prizeselect = pickweight(prize_override)
		else
			prizeselect = pickweight(GLOB.arcade_prize_pool)
		var/atom/movable/the_prize = new prizeselect(get_turf(src))
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		visible_message("<span class='notice'>[src] dispenses [the_prize]!</span>", "<span class='notice'>You hear a chime and a clunk.</span>")

/obj/machinery/computer/arcade/emp_act(severity)
	. = ..()
	var/override = FALSE
	if(prize_override)
		override = TRUE

	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return

	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		if(override)
			empprize = pickweight(prize_override)
		else
			empprize = pickweight(GLOB.arcade_prize_pool)
		new empprize(loc)
	explosion(loc, -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes)

/obj/machinery/computer/arcade/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/arcadeticket))
		var/obj/item/stack/arcadeticket/T = O
		var/amount = T.get_amount()
		if(amount <2)
			to_chat(user, "<span class='warning'>You need 2 tickets to claim a prize!</span>")
			return
		prizevend(user)
		T.pay_tickets()
		T.update_appearance()
		O = T
		to_chat(user, "<span class='notice'>You turn in 2 tickets to the [src] and claim a prize!</span>")
		return

// ** BATTLE ** //
/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/battle

	var/enemy_name = "Space Villain"
	///Enemy health/attack points
	var/enemy_hp = 100
	var/enemy_mp = 40
	///Temporary message, for attack messages, etc
	var/temp = "<br><center><h3>Winners don't use space drugs<center><h3>"
	///the list of passive skill the enemy currently has. the actual passives are added in the enemy_setup() proc
	var/list/enemy_passive
	///if all the enemy's weakpoints have been triggered becomes TRUE
	var/finishing_move = FALSE
	///linked to passives, when it's equal or above the max_passive finishing move will become TRUE
	var/pissed_off = 0
	///the number of passives the enemy will start with
	var/max_passive = 3
	///weapon wielded by the enemy, the shotgun doesn't count.
	var/chosen_weapon

	///Player health
	var/player_hp = 85
	///player magic points
	var/player_mp = 20
	///used to remember the last three move of the player before this turn.
	var/list/last_three_move
	///if the enemy or player died. restart the game when TRUE
	var/gameover = FALSE
	///the player cannot make any move while this is set to TRUE. should only TRUE during enemy turns.
	var/blocked = FALSE
	///used to clear the enemy_action proc timer when the game is restarted
	var/timer_id
	///weapon used by the enemy, pure fluff.for certain actions
	var/list/weapons
	///unique to the emag mode, acts as a time limit where the player dies when it reaches 0.
	var/bomb_cooldown = 19


///creates the enemy base stats for a new round along with the enemy passives
/obj/machinery/computer/arcade/battle/proc/enemy_setup(player_skill)
	player_hp = 85
	player_mp = 20
	enemy_hp = 100
	enemy_mp = 40
	gameover = FALSE
	blocked = FALSE
	finishing_move = FALSE
	pissed_off = 0
	last_three_move = null

	enemy_passive = list("short_temper" = TRUE, "poisonous" = TRUE, "smart" = TRUE, "shotgun" = TRUE, "magical" = TRUE, "chonker" = TRUE)
	for(var/i = LAZYLEN(enemy_passive); i > max_passive; i--) //we'll remove passives from the list until we have the number of passive we want
		var/picked_passive = pick(enemy_passive)
		LAZYREMOVE(enemy_passive, picked_passive)

	if(LAZYACCESS(enemy_passive, "chonker"))
		enemy_hp += 20

	if(LAZYACCESS(enemy_passive, "shotgun"))
		chosen_weapon = "shotgun"
	else if(weapons)
		chosen_weapon = pick(weapons)
	else
		chosen_weapon = "null gun" //if the weapons list is somehow empty, shouldn't happen but runtimes are sneaky bastards.

	if(player_skill)
		player_hp += player_skill * 2


/obj/machinery/computer/arcade/battle/Reset()
	max_passive = 3
	var/name_action
	var/name_part1
	var/name_part2

	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		name_action = pick_list(ARCADE_FILE, "rpg_action_halloween")
		name_part1 = pick_list(ARCADE_FILE, "rpg_adjective_halloween")
		name_part2 = pick_list(ARCADE_FILE, "rpg_enemy_halloween")
		weapons = strings(ARCADE_FILE, "rpg_weapon_halloween")
	else if(SSevents.holidays && SSevents.holidays[CHRISTMAS])
		name_action = pick_list(ARCADE_FILE, "rpg_action_xmas")
		name_part1 = pick_list(ARCADE_FILE, "rpg_adjective_xmas")
		name_part2 = pick_list(ARCADE_FILE, "rpg_enemy_xmas")
		weapons = strings(ARCADE_FILE, "rpg_weapon_xmas")
	else if(SSevents.holidays && SSevents.holidays[VALENTINES])
		name_action = pick_list(ARCADE_FILE, "rpg_action_valentines")
		name_part1 = pick_list(ARCADE_FILE, "rpg_adjective_valentines")
		name_part2 = pick_list(ARCADE_FILE, "rpg_enemy_valentines")
		weapons = strings(ARCADE_FILE, "rpg_weapon_valentines")
	else
		name_action = pick_list(ARCADE_FILE, "rpg_action")
		name_part1 = pick_list(ARCADE_FILE, "rpg_adjective")
		name_part2 = pick_list(ARCADE_FILE, "rpg_enemy")
		weapons = strings(ARCADE_FILE, "rpg_weapon")

	enemy_name = ("The " + name_part1 + " " + name_part2)
	name = (name_action + " " + enemy_name)

	enemy_setup(0) //in the case it's reset we assume the player skill is 0 because the VOID isn't a gamer


/obj/machinery/computer/arcade/battle/ui_interact(mob/user)
	. = ..()
	screen_setup(user)


///sets up the main screen for the user
/obj/machinery/computer/arcade/battle/proc/screen_setup(mob/user)
	var/dat = "<a href='byond://?src=[REF(src)];close=1'>Close</a>"
	dat += "<center><h4>[enemy_name]</h4></center>"

	dat += "[temp]"
	dat += "<br><center>Health: [player_hp] | Magic: [player_mp] | Enemy Health: [enemy_hp]</center>"

	if (gameover)
		dat += "<center><b><a href='byond://?src=[REF(src)];newgame=1'>New Game</a>"
	else
		dat += "<center><b><a href='byond://?src=[REF(src)];attack=1'>Light attack</a>"
		dat += "<center><b><a href='byond://?src=[REF(src)];defend=1'>Defend</a>"
		dat += "<center><b><a href='byond://?src=[REF(src)];counter_attack=1'>Counter attack</a>"
		dat += "<center><b><a href='byond://?src=[REF(src)];power_attack=1'>Power attack</a>"

	dat += "</b></center>"
	if(user.client) //mainly here to avoid a runtime when the player gets gibbed when losing the emag mode.
		var/datum/browser/popup = new(user, "arcade", "Space Villain 2000")
		popup.set_content(dat)
		popup.open()


/obj/machinery/computer/arcade/battle/Topic(href, href_list)
	if(..())
		return
	var/gamerSkill = 0
	if(usr?.mind)
		gamerSkill = usr.mind.get_skill_level(/datum/skill/gaming)

	if (!blocked && !gameover)
		var/attackamt = rand(5,7) + rand(0, gamerSkill)

		if(finishing_move) //time to bonk that fucker,cuban pete will sometime survive a finishing move.
			attackamt *= 100

		//light attack suck absolute ass but it doesn't cost any MP so it's pretty good to finish an enemy off
		if (href_list["attack"])
			temp = "<br><center><h3>you do quick jab for [attackamt] of damage!</h3></center>"
			enemy_hp -= attackamt
			arcade_action(usr,"attack",attackamt)

		//defend lets you gain back MP and take less damage from non magical attack.
		else if(href_list["defend"])
			temp = "<br><center><h3>you take a defensive stance and gain back 10 mp!</h3></center>"
			player_mp += 10
			arcade_action(usr,"defend",attackamt)
			playsound(src, 'sound/arcade/mana.ogg', 50, TRUE, extrarange = -3)

		//mainly used to counter short temper and their absurd damage, will deal twice the damage the player took of a non magical attack.
		else if(href_list["counter_attack"] && player_mp >= 10)
			temp = "<br><center><h3>you prepare yourself to counter the next attack!</h3></center>"
			player_mp -= 10
			arcade_action(usr,"counter_attack",attackamt)
			playsound(src, 'sound/arcade/mana.ogg', 50, TRUE, extrarange = -3)

		else if(href_list["counter_attack"] && player_mp < 10)
			temp = "<br><center><h3>you don't have the mp necessary to counter attack and defend yourself instead</h3></center>"
			player_mp += 10
			arcade_action(usr,"defend",attackamt)
			playsound(src, 'sound/arcade/mana.ogg', 50, TRUE, extrarange = -3)

		//power attack deals twice the amount of damage but is really expensive MP wise, mainly used with combos to get weakpoints.
		else if (href_list["power_attack"] && player_mp >= 20)
			temp = "<br><center><h3>You attack [enemy_name] with all your might for [attackamt * 2] damage!</h3></center>"
			enemy_hp -= attackamt * 2
			player_mp -= 20
			arcade_action(usr,"power_attack",attackamt)

		else if(href_list["power_attack"] && player_mp < 20)
			temp = "<br><center><h3>You don't have the mp necessary for a power attack and settle for a light attack!</h3></center>"
			enemy_hp -= attackamt
			arcade_action(usr,"attack",attackamt)

	if (href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "<br><center><h3>New Round<center><h3>"

		if(obj_flags & EMAGGED)
			Reset()
			obj_flags &= ~EMAGGED

		enemy_setup(gamerSkill)
		screen_setup(usr)


	add_fingerprint(usr)
	updateUsrDialog()
	return


///happens after a player action and before the enemy turn. the enemy turn will be cancelled if there's a gameover.
/obj/machinery/computer/arcade/battle/proc/arcade_action(mob/user,player_stance,attackamt)
	screen_setup(user)
	blocked = TRUE
	if(player_stance == "attack" || player_stance == "power_attack")
		if(attackamt > 40)
			playsound(src, 'sound/arcade/boom.ogg', 50, TRUE, extrarange = -3)
		else
			playsound(src, 'sound/arcade/hit.ogg', 50, TRUE, extrarange = -3)

	timer_id = addtimer(CALLBACK(src, .proc/enemy_action,player_stance,user),1 SECONDS,TIMER_STOPPABLE)
	gameover_check(user)


///the enemy turn, the enemy's action entirely depend on their current passive and a teensy tiny bit of randomness
/obj/machinery/computer/arcade/battle/proc/enemy_action(player_stance,mob/user)
	var/list/list_temp = list()

	switch(LAZYLEN(last_three_move)) //we keep the last three action of the player in a list here
		if(0 to 2)
			LAZYADD(last_three_move, player_stance)
		if(3)
			for(var/i in 1 to 2)
				last_three_move[i] = last_three_move[i + 1]
			last_three_move[3] = player_stance

		if(4 to INFINITY)
			last_three_move = null //this shouldn't even happen but we empty the list if it somehow goes above 3

	var/enemy_stance
	var/attack_amount = rand(8,10) //making the attack amount not vary too much so that it's easier to see if the enemy has a shotgun

	if(player_stance == "defend")
		attack_amount -= 5

	//if emagged, cuban pete will set up a bomb acting up as a timer. when it reaches 0 the player fucking dies
	if(obj_flags & EMAGGED)
		switch(bomb_cooldown--)
			if(18)
				list_temp += "<br><center><h3>[enemy_name] takes two valve tank and links them together, what's he planning?<center><h3>"
			if(15)
				list_temp += "<br><center><h3>[enemy_name] adds a remote control to the tan- ho god is that a bomb?<center><h3>"
			if(12)
				list_temp += "<br><center><h3>[enemy_name] throws the bomb next to you, you'r too scared to pick it up. <center><h3>"
			if(6)
				list_temp += "<br><center><h3>[enemy_name]'s hand brushes the remote linked to the bomb, your heart skipped a beat. <center><h3>"
			if(2)
				list_temp += "<br><center><h3>[enemy_name] is going to press the button! It's now or never! <center><h3>"
			if(0)
				player_hp -= attack_amount * 1000 //hey it's a maxcap we might as well go all in

	//yeah I used the shotgun as a passive, you know why? because the shotgun gives +5 attack which is pretty good
	if(LAZYACCESS(enemy_passive, "shotgun"))
		if(weakpoint_check("shotgun","defend","defend","power_attack"))
			list_temp += "<br><center><h3>You manage to disarm [enemy_name] with a surprise power attack and shoot him with his shotgun until it runs out of ammo! <center><h3> "
			enemy_hp -= 10
			chosen_weapon = "empty shotgun"
		else
			attack_amount += 5

	//heccing chonker passive, only gives more HP at the start of a new game but has one of the hardest weakpoint to trigger.
	if(LAZYACCESS(enemy_passive, "chonker"))
		if(weakpoint_check("chonker","power_attack","power_attack","power_attack"))
			list_temp += "<br><center><h3>After a lot of power attacks you manage to tip over [enemy_name] as they fall over their enormous weight<center><h3> "
			enemy_hp -= 30

	//smart passive trait, mainly works in tandem with other traits, makes the enemy unable to be counter_attacked
	if(LAZYACCESS(enemy_passive, "smart"))
		if(weakpoint_check("smart","defend","defend","attack"))
			list_temp += "<br><center><h3>[enemy_name] is confused by your illogical strategy!<center><h3> "
			attack_amount -= 5

		else if(attack_amount >= player_hp)
			player_hp -= attack_amount
			list_temp += "<br><center><h3>[enemy_name] figures out you are really close to death and finishes you off with their [chosen_weapon]!<center><h3>"
			enemy_stance = "attack"

		else if(player_stance == "counter_attack")
			list_temp += "<br><center><h3>[enemy_name] is not taking your bait. <center><h3> "
			if(LAZYACCESS(enemy_passive, "short_temper"))
				list_temp += "However controlling their hatred of you still takes a toll on their mental and physical health!"
				enemy_hp -= 5
				enemy_mp -= 5
			enemy_stance = "defensive"

	//short temper passive trait, gets easily baited into being counter attacked but will bypass your counter when low on HP
	if(LAZYACCESS(enemy_passive, "short_temper"))
		if(weakpoint_check("short_temper","counter_attack","counter_attack","counter_attack"))
			list_temp += "<br><center><h3>[enemy_name] is getting frustrated at all your counter attacks and throws a tantrum!<center><h3>"
			enemy_hp -= attack_amount

		else if(player_stance == "counter_attack")
			if(!(LAZYACCESS(enemy_passive, "smart")) && enemy_hp > 30)
				list_temp += "<br><center><h3>[enemy_name] took the bait and allowed you to counter attack for [attack_amount * 2] damage!<center><h3>"
				player_hp -= attack_amount
				enemy_hp -= attack_amount * 2
				enemy_stance = "attack"

			else if(enemy_hp <= 30) //will break through the counter when low enough on HP even when smart.
				list_temp += "<br><center><h3>[enemy_name] is getting tired of your tricks and breaks through your counter with their [chosen_weapon]!<center><h3>"
				player_hp -= attack_amount
				enemy_stance = "attack"

		else if(!enemy_stance)
			var/added_temp

			if(rand())
				added_temp = "you for [attack_amount + 5] damage!"
				player_hp -= attack_amount + 5
				enemy_stance = "attack"
			else
				added_temp = "the wall, breaking their skull in the process and losing [attack_amount] hp!" //[enemy_name] you have a literal dent in your skull
				enemy_hp -= attack_amount
				enemy_stance = "attack"

			list_temp += "<br><center><h3>[enemy_name] grits their teeth and charge right into [added_temp]<center><h3>"

	//in the case none of the previous passive triggered, Mainly here to set an enemy stance for passives that needs it like the magical passive.
	if(!enemy_stance)
		enemy_stance = pick("attack","defensive")
		if(enemy_stance == "attack")
			player_hp -= attack_amount
			list_temp += "<br><center><h3>[enemy_name] attacks you for [attack_amount] points of damage with their [chosen_weapon]<center><h3>"
			if(player_stance == "counter_attack")
				enemy_hp -= attack_amount * 2
				list_temp += "<br><center><h3>You counter [enemy_name]'s attack and deal [attack_amount * 2] points of damage!<center><h3>"

		if(enemy_stance == "defensive" && enemy_mp < 15)
			list_temp += "<br><center><h3>[enemy_name] take some time to get some mp back!<center><h3> "
			enemy_mp += attack_amount

		else if (enemy_stance == "defensive" && enemy_mp >= 15 && !(LAZYACCESS(enemy_passive, "magical")))
			list_temp += "<br><center><h3>[enemy_name] quickly heal themselves for 5 hp!<center><h3> "
			enemy_mp -= 15
			enemy_hp += 5

	//magical passive trait, recharges MP nearly every turn it's not blasting you with magic.
	if(LAZYACCESS(enemy_passive, "magical"))
		if(player_mp >= 50)
			list_temp += "<br><center><h3>the huge amount of magical energy you have acumulated throws [enemy_name] off balance!<center><h3>"
			enemy_mp = 0
			LAZYREMOVE(enemy_passive, "magical")
			pissed_off++

		else if(LAZYACCESS(enemy_passive, "smart") && player_stance == "counter_attack" && enemy_mp >= 20)
			list_temp += "<br><center><h3>[enemy_name] blasts you with magic from afar for 10 points of damage before you can counter!<center><h3>"
			player_hp -= 10
			enemy_mp -= 20

		else if(enemy_hp >= 20 && enemy_mp >= 40 && enemy_stance == "defensive")
			list_temp += "<br><center><h3>[enemy_name] Blasts you with magic from afar!<center><h3>"
			enemy_mp -= 40
			player_hp -= 30
			enemy_stance = "attack"

		else if(enemy_hp < 20 && enemy_mp >= 20 && enemy_stance == "defensive") //it's a pretty expensive spell so they can't spam it that much
			list_temp += "<br><center><h3>[enemy_name] heal themselves with magic and gain back 20 hp!<center><h3>"
			enemy_hp += 20
			enemy_mp -= 30
		else
			list_temp += "<br><center><h3>[enemy_name]'s magical nature lets them get some mp back!<center><h3>"
			enemy_mp += attack_amount

	//poisonous passive trait, while it's less damage added than the shotgun it acts up even when the enemy doesn't attack at all.
	if(LAZYACCESS(enemy_passive, "poisonous"))
		if(weakpoint_check("poisonous","attack","attack","attack"))
			list_temp += "<br><center><h3>your flurry of attack throws back the poisonnous gas at [enemy_name] and makes them choke on it!<center><h3> "
			enemy_hp -= 5
		else
			list_temp += "<br><center><h3>the stinky breath of [enemy_name] hurts you for 3 hp!<center><h3> "
			player_hp -= 3

	//if all passive's weakpoint have been triggered, set finishing_move to TRUE
	if(pissed_off >= max_passive && !finishing_move)
		list_temp += "<br><center><h3>You have weakened [enemy_name] enough for them to show their weak point, you will do 10 times as much damage with your next attack!<center><h3> "
		finishing_move = TRUE

	playsound(src, 'sound/arcade/heal.ogg', 50, TRUE, extrarange = -3)

	temp = list_temp.Join()
	gameover_check(user)
	screen_setup(user)
	blocked = FALSE


/obj/machinery/computer/arcade/battle/proc/gameover_check(mob/user)
	var/xp_gained = 0
	if(enemy_hp <= 0)
		if(!gameover)
			if(timer_id)
				deltimer(timer_id)
				timer_id = null
			if(player_hp <= 0)
				player_hp = 1 //let's just pretend the enemy didn't kill you so not both the player and enemy look dead.
			gameover = TRUE
			blocked = FALSE
			temp = "<br><center><h3>[enemy_name] has fallen! Rejoice!<center><h3>"
			playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)

			if(obj_flags & EMAGGED)
				new /obj/effect/spawner/newbomb/timer/syndicate(loc)
				new /obj/item/clothing/head/collectable/petehat(loc)
				message_admins("[ADMIN_LOOKUPFLW(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				log_game("[key_name(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				Reset()
				obj_flags &= ~EMAGGED
				xp_gained += 100
			else
				prizevend(user)
				xp_gained += 50
			SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("win", (obj_flags & EMAGGED ? "emagged":"normal")))

	else if(player_hp <= 0)
		if(timer_id)
			deltimer(timer_id)
			timer_id = null
		gameover = TRUE
		temp = "<br><center><h3>You have been crushed! GAME OVER<center><h3>"
		playsound(loc, 'sound/arcade/lose.ogg', 50, TRUE)
		xp_gained += 10//pity points
		if(obj_flags & EMAGGED)
			var/mob/living/living_user = user
			if (istype(living_user))
				living_user.gib()
		SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("loss", "hp", (obj_flags & EMAGGED ? "emagged":"normal")))

	if(gameover)
		user?.mind?.adjust_experience(/datum/skill/gaming, xp_gained+1)//always gain at least 1 point of XP


///used to check if the last three move of the player are the one we want in the right order and if the passive's weakpoint has been triggered yet
/obj/machinery/computer/arcade/battle/proc/weakpoint_check(passive,first_move,second_move,third_move)
	if(LAZYLEN(last_three_move) < 3)
		return FALSE

	if(last_three_move[1] == first_move && last_three_move[2] == second_move && last_three_move[3] == third_move && LAZYACCESS(enemy_passive, passive))
		LAZYREMOVE(enemy_passive, passive)
		pissed_off++
		return TRUE
	else
		return FALSE


/obj/machinery/computer/arcade/battle/Destroy()
	enemy_passive = null
	weapons = null
	last_three_move = null
	return ..() //well boys we did it, lists are no more

/obj/machinery/computer/arcade/battle/examine_more(mob/user)
	var/list/msg = list("<span class='notice'><i>You notice some writing scribbled on the side of [src]...</i></span>")
	msg += "\t<span class='info'>smart -> defend, defend, light attack</span>"
	msg += "\t<span class='info'>shotgun -> defend, defend, power attack</span>"
	msg += "\t<span class='info'>short temper -> counter, counter, counter</span>"
	msg += "\t<span class='info'>poisonous -> light attack, light attack, light attack</span>"
	msg += "\t<span class='info'>chonker -> power attack, power attack, power attack</span>"
	return msg

/obj/machinery/computer/arcade/battle/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return

	to_chat(user, "<span class='warning'>A mesmerizing Rhumba beat starts playing from the arcade machine's speakers!</span>")
	temp = "<br><center><h2>If you die in the game, you die for real!<center><h2>"
	max_passive = 6
	bomb_cooldown = 18
	var/gamerSkill = 0
	if(usr?.mind)
		gamerSkill = usr.mind.get_skill_level(/datum/skill/gaming)
	enemy_setup(gamerSkill)
	enemy_hp += 100 //extra HP just to make cuban pete even more bullshit
	player_hp += 30 //the player will also get a few extra HP in order to have a fucking chance

	screen_setup(user)
	gameover = FALSE

	obj_flags |= EMAGGED

	enemy_name = "Cuban Pete"
	name = "Outbomb Cuban Pete"

	updateUsrDialog()


// *** THE ORION TRAIL ** //

#define ORION_TRAIL_WINTURN 9

//defines in machines.dm

/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/orion_trail
	var/busy = FALSE //prevent clickspam that allowed people to ~speedrun~ the game.
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/alive = 4
	var/datum/orion_event/event = null
	var/reason
	var/list/settlers = list("Harry","Larry","Bob")
	var/list/settlermoods = list()
	//list of paths, turns into list of singletons after init
	var/list/events = list(
		/datum/orion_event/engine_part,
		/datum/orion_event/electronic_part,
		/datum/orion_event/hull_part,
		/datum/orion_event/old_ship,
		/datum/orion_event/exploring_derelict,
		/datum/orion_event/raiders,
		/datum/orion_event/illness,
		/datum/orion_event/flux,
		/datum/orion_event/black_hole,
		/datum/orion_event/black_hole_death,
		/datum/orion_event/changeling_infiltration,
		/datum/orion_event/changeling_attack,
		/datum/orion_event/space_port,
		/datum/orion_event/space_port/tau_ceti,
		/datum/orion_event/space_port_raid
	)
	//actual amount of lings on board
	var/lings_aboard = 0
	//if the game should pretend there are lings on board.
	var/lings_suspected = FALSE
	var/spaceport_raided = 0
	var/gameStatus = ORION_STATUS_START

	var/obj/item/radio/Radio
	var/list/gamers = list()
	var/killed_crew = 0


/obj/machinery/computer/arcade/orion_trail/Initialize()
	. = ..()
	Radio = new /obj/item/radio(src)
	Radio.listening = 0
	for(var/path in events)
		var/datum/orion_event/new_event = new path(src)
		events[new_event] = new_event.weight
		popleft(events) //remove the old path

/obj/machinery/computer/arcade/orion_trail/Destroy()
	QDEL_NULL(Radio)
	for(var/datum/orion_event/dat_to_del as anything in events)
		dat_to_del.game = null
		qdel(dat_to_del)
	return ..()

/obj/machinery/computer/arcade/orion_trail/kobayashi
	name = "Kobayashi Maru control computer"
	desc = "A test for cadets."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	events = list("Raiders" = 3, "Interstellar Flux" = 1, "Illness" = 3, "Breakdown" = 2, "Malfunction" = 2, "Collision" = 1, "Spaceport" = 2)
	prize_override = list(/obj/item/paper/fluff/holodeck/trek_diploma = 1)
	settlers = list("Kirk","Worf","Gene")

/obj/machinery/computer/arcade/orion_trail/proc/newgame()
	// Set names of settlers in crew
	var/mob/living/carbon/player = usr
	var/player_crew_name = player.first_name()
	settlers = list()
	for(var/i = 1; i <= 3; i++)
		add_crewmember(update = FALSE)
	add_crewmember("[player_crew_name]") //final crewmember is you, so DO update the settler moods now
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = 4
	turns = 1
	event = null
	gameStatus = ORION_STATUS_NORMAL
	lings_aboard = 0
	killed_crew = 0

	//spaceport junk
	spaceport_raided = 0

/obj/machinery/computer/arcade/orion_trail/proc/report_player(mob/gamer)
	if(gamers[gamer] == -2)
		return // enough harassing them

	if(gamers[gamer] == -1)
		say("WARNING: Continued antisocial behavior detected: Dispensing self-help literature.")
		new /obj/item/paper/pamphlet/violent_video_games(drop_location())
		gamers[gamer]--
		return

	if(!(gamer in gamers))
		gamers[gamer] = 0

	gamers[gamer]++ // How many times the player has 'prestiged' (massacred their crew)

	if(gamers[gamer] > 2 && prob(20 * gamers[gamer]))

		Radio.set_frequency(FREQ_SECURITY)
		Radio.talk_into(src, "SECURITY ALERT: Crewmember [gamer] recorded displaying antisocial tendencies in [get_area(src)]. Please watch for violent behavior.", FREQ_SECURITY)

		Radio.set_frequency(FREQ_MEDICAL)
		Radio.talk_into(src, "PSYCH ALERT: Crewmember [gamer] recorded displaying antisocial tendencies in [get_area(src)]. Please schedule psych evaluation.", FREQ_MEDICAL)

		gamers[gamer] = -1

		gamer.client.give_award(/datum/award/achievement/misc/gamer, gamer) // PSYCH REPORT NOTE: patient kept rambling about how they did it for an "achievement", recommend continued holding for observation
		gamer.mind?.adjust_experience(/datum/skill/gaming, 50) // cheevos make u better

		if(!isnull(GLOB.data_core.general))
			for(var/datum/data/record/R in GLOB.data_core.general)
				if(R.fields["name"] == gamer.name)
					R.fields["m_stat"] = "*Unstable*"
					return

/obj/machinery/computer/arcade/orion_trail/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrionGame", name)
		ui.open()

/obj/machinery/computer/arcade/orion_trail/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/moods),
	)

/obj/machinery/computer/arcade/orion_trail/ui_data(mob/user)
	var/list/data = list()
	data["gamestatus"] = gameStatus

	data["engine"] = engine
	data["turns"] = turns
	data["hull"] = hull
	data["electronics"] = electronics
	data["food"] = food
	data["fuel"] = fuel
	data["lings_suspected"] = lings_suspected

	data["eventname"] = event?.name
	data["eventtext"] = event?.text
	data["buttons"] = event?.event_responses

	data["spaceport_raided"] = spaceport_raided
	data[""] =

	data["reason"] = reason

	return data

/obj/machinery/computer/arcade/orion_trail/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["gamename"] = name
	static_data["emagged"] = obj_flags & EMAGGED
	static_data["settlers"] = settlers
	static_data["settlermoods"] = settlermoods
	return static_data



/obj/machinery/computer/arcade/orion_trail/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!iscarbon(usr))
		return

	. = TRUE

	var/mob/living/carbon/gamer = usr

	var/gamerSkillLevel = 0
	var/gamerSkill = 0
	var/gamerSkillRands = 0

	if(gamer?.mind)
		gamerSkillLevel = gamer.mind.get_skill_level(/datum/skill/gaming)
		gamerSkill = gamer.mind.get_skill_modifier(/datum/skill/gaming, SKILL_PROBS_MODIFIER)
		gamerSkillRands = gamer.mind.get_skill_modifier(/datum/skill/gaming, SKILL_RANDS_MODIFIER)

	var/xp_gained = 0

	if(event)
		event.response(action)
		if(!settlers.len || food <= 0 || fuel <= 0)
			set_game_over(gamer)
			return
		new_settler_mood() //events shake people up a bit and can also change food
		update_static_data(usr)
		return TRUE
	switch(action)
		if("start_game")
			if(gameStatus != ORION_STATUS_START)
				return
			newgame()
		if("instructions")
			if(gameStatus != ORION_STATUS_START)
				return
			gameStatus = ORION_STATUS_INSTRUCTIONS
		if("back_to_menu") //back to the main menu
			gameStatus = ORION_STATUS_START
			if(gameStatus == ORION_STATUS_GAMEOVER)
				event = null
				reason = null
				food = 80
				fuel = 60
				settlers = list("Harry","Larry","Bob")
		if("continue")
			if(turns >= ORION_TRAIL_WINTURN)
				win(usr)
				xp_gained += 34
				return
			usr?.mind?.adjust_experience(/datum/skill/gaming, xp_gained+1)
			food -= (alive+lings_aboard)*2
			fuel -= 5
			turns += 1
			//out of supplies, die
			if(food <= 0 || fuel <= 0)
				set_game_over(gamer)
			if(turns == 2 && prob(30-gamerSkill)) //asteroids part of the trip
				encounter_event(/datum/orion_event/hull_part, gamer, gamerSkill, gamerSkillLevel, gamerSkillRands)
				return
			if(turns == 4) //halfway mark
				encounter_event(/datum/orion_event/space_port/tau_ceti, gamer, gamerSkill, gamerSkillLevel, gamerSkillRands)
				return
			if(turns == 7) //black hole part of the trip
				encounter_event(/datum/orion_event/black_hole, gamer, gamerSkill, gamerSkillLevel, gamerSkillRands)
				return
			//an uneventful (get it) turn
			if(prob(25 + gamerSkill))
				return
			encounter_event(null, gamer, gamerSkill, gamerSkillLevel)
			if(lings_aboard && (istype(event, /datum/orion_event/changeling_infiltration) || prob(45 + gamerSkill)))
				//upgrade infiltration/whatever else we got to attack right away
				encounter_event(/datum/orion_event/changeling_attack, gamer, gamerSkill, gamerSkillLevel, gamerSkillRands)
		if("random_kill")
			execute_crewmember(gamer)
		if("target_kill")
			to_chat(world, params["who"])
			execute_crewmember(gamer, params["who"])
		//Spaceport specific interactions
		if("buycrew") //buy a crewmember
			if(!spaceport_raided && food >= 10 && fuel >= 10)
				var/bought = add_crewmember()
				fuel -= 10
				food -= 10
				killed_crew-- // I mean not really but you know
		if("sellcrew") //sell a crewmember
			if(!spaceport_raided && settlers.len > 1)
				var/sold = remove_crewmember()
				fuel += 7
				food += 7
		if("leave_spaceport")
			gameStatus = ORION_STATUS_NORMAL
			spaceport_raided = 0
		if("raid_spaceport")
			spaceport_raided = TRUE
			encounter_event(/datum/orion_event/space_port_raid, gamer, gamerSkill, gamerSkillLevel, gamerSkillRands)
		if("buyparts")
			if(!spaceport_raided && fuel > 5)
				switch(params["part"])
					if(1) //Engine Parts
						engine++
					if(2) //Hull Plates
						hull++
					if(3) //Spare Electronics
						electronics++
				fuel -= 5 //they all cost 5
		if("trade")
			if(!spaceport_raided)
				switch(params["what"])
					if(1) //Fuel
						if(fuel > 5)
							fuel -= 5
							food += 5
					if(2) //Food
						if(food > 5)
							fuel += 5
							food -= 5
	add_fingerprint(gamer)
	updateUsrDialog()

/*
	eventdat = "<center><h1>[event]</h1></center>"
	canContinueEvent = 0
	switch(event)

		if(ORION_TRAIL_SPACEPORT)
			gameStatus = ORION_STATUS_MARKET
			if(spaceport_raided)
				eventdat += "The spaceport is on high alert! You've been barred from docking by the local authorities after your failed raid."
				if()
					eventdat += "<b>Last Spaceport Action:</b> []"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];leave_spaceport=1'>Depart Spaceport</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			else
				eventdat += "Your jump into the sector yields a spaceport - a lucky find!"
				eventdat += "This spaceport is home to travellers who failed to reach Orion, but managed to find a different home..."
				eventdat += "Trading terms: FU = Fuel, FO = Food"
				if()
					eventdat += "<b>Last action:</b> []"
				eventdat += "<h3><b>Crew:</b></h3>"
				eventdat += english_list(settlers)
				eventdat += "<b>Food: </b>[food] | <b>Fuel: </b>[fuel]"
				eventdat += "<b>Engine Parts: </b>[engine] | <b>Hull Panels: </b>[hull] | <b>Electronics: </b>[electronics]"


				//If your crew is pathetic you can get freebies (provided you haven't already gotten one from this port)
				if(!spaceport_freebie && (fuel < 20 || food < 20))
					spaceport_freebie++
					var/FU = 10
					var/FO = 10
					var/freecrew = 0
					if(prob(30))
						FU = 25
						FO = 25

					if(prob(10))
						add_crewmember()
						freecrew++

					eventdat += "The traders of the spaceport take pity on you, and generously give you some free supplies! (+[FU]FU, +[FO]FO)"
					if(freecrew)
						eventdat += "You also gain a new crewmember!"

					fuel += FU
					food += FO

				//CREW INTERACTIONS
				eventdat += "<P ALIGN=Right>Crew Management:</P>"

				//Buy crew
				if(food >= 10 && fuel >= 10)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buycrew=1'>Hire a New Crewmember (-10FU, -10FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You cannot afford a new crewmember.</P>"

				//Sell crew
				if(settlers.len > 1)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];sellcrew=1'>Sell Crew for Fuel and Food (+7FU, +7FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You have no other crew to sell.</P>"

				//BUY/SELL STUFF
				eventdat += "<P ALIGN=Right>Spare Parts:</P>"

				//Engine parts
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buyparts=1'>Buy Engine Parts (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You cannot afford engine parts.</a>"

				//Hull plates
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buyparts=2'>Buy Hull Plates (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You cannot afford hull plates.</a>"

				//Electronics
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buyparts=3'>Buy Spare Electronics (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You cannot afford spare electronics.</a>"

				//Trade
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];trade=1'>Trade Fuel for Food (-5FU,+5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You don't have 5FU to trade.</P"

				if(food > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];trade=2'>Trade Food for Fuel (+5FU,-5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>You don't have 5FO to trade.</P"

				//Raid the spaceport
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];raid_spaceport=1'>!! Raid Spaceport !!</a></P>"

				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];leave_spaceport=1'>Depart Spaceport</a></P>"

	*/

/**
 * pickweights a new event, sets event var as it. it then preps the event if it needs it
 *
 * giving a path argument will instead find that instanced datum instead of pickweighting. Used in events that follow from events.
 * Arguments:
 * * path: if we want a specific event, this is the path of the wanted one
 */
/obj/machinery/computer/arcade/orion_trail/proc/encounter_event(path, gamer, gamerSkill, gamerSkillLevel, gamerSkillRands)
	if(!path)
		event = pickweightAllowZero(events)
	else
		for(var/datum/orion_event/instance as anything in events)
			if(instance.type == path)
				event = instance
				break
	if(!event)
		CRASH("Woah, hey! we could not find the specified event \"[path]\"! Add it to the events list, numb nuts!")
	event.on_select(gamerSkill, gamerSkillLevel, gamerSkillRands)
	if(obj_flags & EMAGGED)
		event.emag_effect(gamer)

/obj/machinery/computer/arcade/orion_trail/proc/lose_condition_met()

		return TRUE

/obj/machinery/computer/arcade/orion_trail/proc/set_game_over(user, given_reason)
	gameStatus = ORION_STATUS_GAMEOVER
	event = null
	reason = given_reason || death_reason(user)

/obj/machinery/computer/arcade/orion_trail/proc/death_reason(mob/living/carbon/gamer)
	var/reason
	if(!settlers.len)
		reason = "Your entire crew died, and your ship joins the fleet of ghost-ships littering the galaxy."
	else
		if(food <= 0)
			reason = "You ran out of food and starved."
			if(obj_flags & EMAGGED)
				gamer.set_nutrition(0) //yeah you pretty hongry
				to_chat(gamer, "<span class='userdanger'>Your body instantly contracts to that of one who has not eaten in months. Agonizing cramps seize you as you fall to the floor.</span>")
		if(fuel <= 0)
			reason = "You ran out of fuel, and drift, slowly, into a star."
			if(obj_flags & EMAGGED)
				gamer.adjust_fire_stacks(5)
				gamer.IgniteMob() //flew into a star, so you're on fire
				to_chat(gamer, "<span class='userdanger'>You feel an immense wave of heat emanate from the arcade machine. Your skin bursts into flames.</span>")

	if(obj_flags & EMAGGED)
		to_chat(gamer, "<span class='userdanger'>You're never going to make it to Orion...</span>")
		gamer.death()
		obj_flags &= ~EMAGGED //removes the emagged status after you lose
		gameStatus = ORION_STATUS_START
		name = "The Orion Trail"
		desc = "Learn how our ancestors got to Orion, and have fun in the process!"

	gamer?.mind?.adjust_experience(/datum/skill/gaming, 10)//learning from your mistakes is the first rule of roguelikes
	return reason

//Add Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/add_crewmember(specific = "", update = TRUE)
	var/newcrew = ""
	if(specific)
		newcrew = specific
	else
		if(prob(50))
			newcrew = pick(GLOB.first_names_male)
		else
			newcrew = pick(GLOB.first_names_female)
	if(newcrew)
		settlers += newcrew
		alive++
	if(update)
		new_settler_mood()//new faces!
		update_static_data(usr)
	return newcrew


//Remove Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/remove_crewmember(specific = "", dont_remove = "", update = TRUE)
	to_chat(world, specific)
	var/list/safe2remove = settlers
	var/removed = ""
	if(dont_remove)
		safe2remove -= dont_remove
	if(specific && specific != dont_remove)
		safe2remove = list(specific)
	else
		removed = pick(safe2remove)

	if(removed)
		if(lings_aboard && prob(40*lings_aboard)) //if there are 2 lings you're twice as likely to get one, obviously
			lings_aboard = max(0,--lings_aboard)
		settlers -= removed
		alive--
	if(update)
		new_settler_mood()//bro, i...
		update_static_data(usr)
	return removed

/**
 * Crewmember executed code, targeted when there are no lings and untargeted when there are some
 * If there was no suspected lings (aka random shots) this is just murder and counts towards killed crew
 *
 * Arguments:
 * * gamer: carbon that may need emag effects applied
 */
/obj/machinery/computer/arcade/orion_trail/proc/execute_crewmember(mob/living/carbon/gamer, target)
	var/sheriff = remove_crewmember(target) //I shot the sheriff
	if(target)
		killed_crew += 1 //if there was no suspected lings, this is just plain murder
	playsound(loc,'sound/weapons/gun/pistol/shot.ogg', 100, TRUE)
	if(!settlers.len || !alive)
		say("The last crewmember [sheriff], shot themselves, GAME OVER!")
		if(obj_flags & EMAGGED)
			gamer.death()
		set_game_over(gamer, "Your last pioneer committed suicide.")
		if(killed_crew >= 4)
			gamer.mind?.adjust_experience(/datum/skill/gaming, -15)//no cheating by spamming game overs
			report_player(gamer)
	else if(obj_flags & EMAGGED)
		if(findtext(gamer.name, sheriff))
			say("The crew of the ship chose to kill [gamer]!")
			gamer.death()

/**
 * Creates a new mood icon for each settler
 *
 * Things that effect mood:
 * * +1 for determination
 * * Pioneer count
 * * Low food
 * * Low parts
 * * Sometimes they're just a bit happier or sadder
 * Arguments:
 * * None!
 */
/obj/machinery/computer/arcade/orion_trail/proc/new_settler_mood()
	settlermoods.Cut()
	for(var/i in 1 to settlers.len)
		var/food_mood = food >= 15
		var/supply_mood = -1
		if(hull)
			supply_mood++
		if(electronics)
			supply_mood++
		if(engine)
			supply_mood++
		supply_mood = min(supply_mood, 1) //they expect multiple things stocked
		var/changing_mood = 0
		if(prob(60)) //sometimes they just feel better or worse
			changing_mood = rand(-1,1)
		settlermoods[settlers[i]] += min(settlers.len + 1 + changing_mood + food_mood + supply_mood, 1)

/obj/machinery/computer/arcade/orion_trail/proc/win(mob/user)
	gameStatus = ORION_STATUS_START
	say("Congratulations, you made it to Orion!")
	if(obj_flags & EMAGGED)
		new /obj/item/orion_ship(loc)
		message_admins("[ADMIN_LOOKUPFLW(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		prizevend(user)
	obj_flags &= ~EMAGGED
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"

/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='notice'>You override the cheat code menu and skip to Cheat #[rand(1, 50)]: Realism Mode.</span>")
	name = "The Orion Trail: Realism Edition"
	desc = "Learn how our ancestors got to Orion, and try not to die in the process!"
	newgame()
	obj_flags |= EMAGGED

/mob/living/simple_animal/hostile/syndicate/ranged/smg/orion
	name = "spaceport security"
	desc = "Premier corporate security forces for all spaceports found along the Orion Trail."
	faction = list("orion")
	loot = list()
	del_on_death = TRUE

/obj/item/orion_ship
	name = "model settler ship"
	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = WEIGHT_CLASS_SMALL
	var/active = 0 //if the ship is on

/obj/item/orion_ship/examine(mob/user)
	. = ..()
	if(!(in_range(user, src)))
		return
	if(!active)
		. += "<span class='notice'>There's a little switch on the bottom. It's flipped down.</span>"
	else
		. += "<span class='notice'>There's a little switch on the bottom. It's flipped up.</span>"

/obj/item/orion_ship/attack_self(mob/user) //Minibomb-level explosion. Should probably be more because of how hard it is to survive the machine! Also, just over a 5-second fuse
	if(active)
		return

	log_bomber(usr, "primed an explosive", src, "for detonation")

	to_chat(user, "<span class='warning'>You flip the switch on the underside of [src].</span>")
	active = 1
	visible_message("<span class='notice'>[src] softly beeps and whirs to life!</span>")
	playsound(loc, 'sound/machines/defib_SaftyOn.ogg', 25, TRUE)
	say("This is ship ID #[rand(1,1000)] to Orion Port Authority. We're coming in for landing, over.")
	sleep(20)
	visible_message("<span class='warning'>[src] begins to vibrate...</span>")
	say("Uh, Port? Having some issues with our reactor, could you check it out? Over.")
	sleep(30)
	say("Oh, God! Code Eight! CODE EIGHT! IT'S GONNA BL-")
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, TRUE)
	sleep(3.6)
	visible_message("<span class='userdanger'>[src] explodes!</span>")
	explosion(loc, 2,4,8, flame_range = 16)
	qdel(src)

// ** AMPUTATION ** //

/obj/machinery/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure"
	desc = "A picture of a blood-soaked medical cyborg flashes on the screen. The mediborg has a speech bubble that says, \"Put your hand in the machine if you aren't a <b>coward!</b>\""
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/amputation

/obj/machinery/computer/arcade/amputation/attack_hand(mob/user, list/modifiers)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/c_user = user
	if(!c_user.get_bodypart(BODY_ZONE_L_ARM) && !c_user.get_bodypart(BODY_ZONE_R_ARM))
		return
	to_chat(c_user, "<span class='warning'>You move your hand towards the machine, and begin to hesitate as a bloodied guillotine emerges from inside of it...</span>")
	if(do_after(c_user, 50, target = src))
		to_chat(c_user, "<span class='userdanger'>The guillotine drops on your arm, and the machine sucks it in!</span>")
		playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		var/which_hand = BODY_ZONE_L_ARM
		if(!(c_user.active_hand_index % 2))
			which_hand = BODY_ZONE_R_ARM
		var/obj/item/bodypart/chopchop = c_user.get_bodypart(which_hand)
		chopchop.dismember()
		qdel(chopchop)
		user.mind?.adjust_experience(/datum/skill/gaming, 100)
		playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)
		prizevend(user, rand(3,5))
	else
		to_chat(c_user, "<span class='notice'>You (wisely) decide against putting your hand in the machine.</span>")

/obj/machinery/computer/arcade/amputation/festive //dispenses wrapped gifts instead of arcade prizes, also known as the ancap christmas tree
	name = "Mediborg's Festive Amputation Adventure"
	desc = "A picture of a blood-soaked medical cyborg wearing a Santa hat flashes on the screen. The mediborg has a speech bubble that says, \"Put your hand in the machine if you aren't a <b>coward!</b>\""
	prize_override = list(/obj/item/a_gift/anything = 1)

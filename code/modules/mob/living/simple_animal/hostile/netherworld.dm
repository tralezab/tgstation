/mob/living/simple_animal/hostile/netherworld
	name = "creature"
	desc = "A sanity-destroying otherthing from the netherworld."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("creature")
	speak_emote = list("screams")
	gold_core_spawnable = HOSTILE_SPAWN
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("nether")

/mob/living/simple_animal/hostile/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attacktext = "lacerates"
	speed = -0.5
	var/static/list/migo_sounds
	deathmessage = "wails as its form turns into a pulpy mush."
	deathsound = 'sound/voice/hiss6.ogg'

/mob/living/simple_animal/hostile/netherworld/migo/Initialize()
	. = ..()
	migo_sounds = list('sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg', 'sound/items/deconstruct.ogg', 'sound/items/carhorn.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/megaphone.ogg', 'sound/items/screwdriver.ogg', 'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg', 'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/items/geiger/high1.ogg', 'sound/items/geiger/high2.ogg', 'sound/voice/beepsky/creep.ogg', 'sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/ed209_20sec.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss6.ogg', 'sound/voice/medbot/patchedup.ogg', 'sound/voice/medbot/feelbetter.ogg', 'sound/voice/human/manlaugh1.ogg', 'sound/voice/human/womanlaugh.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/clockcultalr.ogg', 'sound/ambience/antag/ling_aler.ogg', 'sound/ambience/antag/tatoralert.ogg', 'sound/ambience/antag/monkey.ogg', 'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg', 'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clockcult_gateway_disrupted.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/curse1.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg', 'sound/effects/empulse.ogg', 'sound/effects/explosion_distant.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/effects/his_grace_awaken.ogg', 'sound/effects/pai_boot.ogg', 'sound/effects/phasein.ogg', 'sound/effects/picaxe1.ogg', 'sound/effects/ratvar_reveal.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg', 'sound/effects/supermatter.ogg', 'sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg', 'sound/misc/bloblarm.ogg', 'sound/misc/airraid.ogg', 'sound/misc/bang.ogg','sound/misc/highlander.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg', 'sound/misc/splort.ogg', 'sound/weapons/armbomb.ogg', 'sound/weapons/beam_sniper.ogg', 'sound/weapons/chainsawhit.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg', 'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg', 'sound/weapons/genhit1.ogg', 'sound/weapons/gunshot_silenced.ogg', 'sound/weapons/gunshot.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg', 'sound/weapons/kenetic_accel.ogg', 'sound/machines/clockcult/steam_whoosh.ogg', 'sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlockclose.ogg', 'sound/machines/airlockforced.ogg', 'sound/machines/airlockopen.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg', 'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/cryo_warning.ogg', 'sound/machines/defib_charge.ogg', 'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg', 'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/machines/signal.ogg', 'sound/machines/synth_no.ogg', 'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/triple_beep.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg', 'sound/ai/outbreak5.ogg', 'sound/ai/outbreak7.ogg', 'sound/ai/poweroff.ogg', 'sound/ai/radiation.ogg', 'sound/ai/shuttlecalled.ogg', 'sound/ai/shuttledock.ogg', 'sound/ai/shuttlerecalled.ogg', 'sound/ai/aimalf.ogg') //hahahaha fuck you code divers

/mob/living/simple_animal/hostile/netherworld/migo/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat)
		return
	var/chosen_sound = pick(migo_sounds)
	playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		var/chosen_sound = pick(migo_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/netherworld/blankbody
	name = "blank body"
	desc = "This looks human enough, but its flesh has an ashy texture, and it's face is featureless save an eerie smile."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "punches"
	deathmessage = "falls apart into a fine dust."

//dimension strider//
//the mob itself cannot be hurt as it is in the air but it has legs that can be damaged to bring the strider to the ground, where it then can be killed.
//the mob controls the legs and moves them to move the mob itself, which is between the two legs. it can toggle switching to the other leg when that leg
//leaves the range of the mob for quick "walking" or have it toggled off to try and step on a foe.//

//login logout
/mob/living/simple_animal/hostile/netherworld/strider
	name = "dimension strider"
	desc = "A very large, long legged creature that saps the essense of the dimension it resides."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN //change or have a neutered version for xenobio?
	health = 100
	maxHealth = 100
	melee_damage_lower = 0
	melee_damage_upper = 0
	deathmessage = "melts into a sickly goo."
	AIStatus = AI_OFF
	var/playstyle_string = "<span class='swarmer'>As a dimension strider, I have two massive legs that I must move to get around, and if they are damaged will make me fall and be vulnerable. I can stomp on attackers before that happens.</span>"

	var/legrange = 5
	var/list/feet = list()
	var/legdamage = 50 //two stomps to kill someone without armor, easy because the stomp stuns.

/mob/living/simple_animal/hostile/netherworld/strider/Initialize()
	..()
	create_legs(2)

/mob/living/simple_animal/hostile/netherworld/strider/proc/create_legs(amt_to_add = 2)
	for(var/i in 1 to amt_to_add) //loop that generates the feet
		var/newguy = new /mob/living/simple_animal/hostile/netherworld/striderfoot(loc)
		total_imlagres += newguy
	for(var/mob/living/ii in total_imlagres) //loop that relates them
		var/mob/living/simple_animal/hostile/netherworld/imlagre/needs_to_sync = ii
		needs_to_sync.linked_imlagres = total_imlagres - needs_to_sync //refers to all related imlagres then removes itself

/mob/living/simple_animal/hostile/netherworld/striderfoot
	name = "dimension strider foot"
	desc = "The base of a very large creature. Attacking this would probably bring down the beast!"
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	gold_core_spawnable = NO_SPAWN
	health = 100
	maxHealth = 100
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "punches"
	deathmessage = "falls apart into a fine dust."
	var/one_with_legs
	var/list/feet = list()

/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(/mob/living/simple_animal/hostile/netherworld/migo, /mob/living/simple_animal/hostile/netherworld, /mob/living/simple_animal/hostile/netherworld/blankbody)
	faction = list("nether")

/obj/structure/spawner/nether/Initialize()
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	..()
	if(isskeleton(user) || iszombie(user))
		to_chat(user, "A direct link to another dimension full of creatures very happy to see you. <span class='nicegreen'>You can see your house from here!</span>")
	else
		to_chat(user, "A direct link to another dimension full of creatures not very happy to see you. <span class='warning'>Entering the link would be a very bad idea.</span>")

/obj/structure/spawner/nether/attack_hand(mob/user)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		to_chat(user, "<span class='notice'>You don't feel like going home yet...</span>")
	else
		user.visible_message("<span class='warning'>[user] is violently pulled into the link!</span>", \
							"<span class='userdanger'>Touching the portal, you are quickly pulled through into a world of unimaginable horror!</span>")
		contents.Add(user)

/obj/structure/spawner/nether/process()
	for(var/mob/living/M in contents)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, 1)
			M.adjustBruteLoss(60)
			new /obj/effect/gibspawner/generic(get_turf(M), M)
			if(M.stat == DEAD)
				var/mob/living/simple_animal/hostile/netherworld/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = "It's [M], but [M.p_their()] flesh has an ashy texture, and [M.p_their()] face is featureless save an eerie smile."
				src.visible_message("<span class='warning'>[M] reemerges from the link!</span>")
				qdel(M)

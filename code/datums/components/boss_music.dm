/**
 * Attaches to a hostile simplemob and plays that music while they have a target.
 */
/datum/component/boss_music
	///The music track we will play to players.
	var/boss_track
	///How long the track is, used to clear players out when the music is supposed to end.
	var/track_duration

	///List of all mobs listening to the boss music currently. Cleared on Destroy or after `track_duration`.
	var/list/datum/weakref/players_listening_refs = list()
	///List of callback timers, used to clear out mobs listening to boss music after `track_duration`.
	var/list/music_callbacks = list()

/datum/component/boss_music/Initialize(
	boss_track,
	track_duration,
)
	. = ..()
	if(!ishostile(parent) && !isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE
	src.boss_track = boss_track
	src.track_duration = track_duration

/datum/component/boss_music/Destroy(force)
	. = ..()
	for(var/callback in music_callbacks)
		deltimer(callback)
	music_callbacks = null

	for(var/player_refs in players_listening_refs)
		unregister_old_listener(player_refs)
	players_listening_refs = null

/datum/component/boss_music/RegisterWithParent()
	. = ..()
	if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_FOUND_TARGET, PROC_REF(on_hostile_target_found))
	if(isbasicmob(parent))
		RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_CURRENT_TARGET), PROC_REF(on_basic_target_changed))

/datum/component/boss_music/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_FOUND_TARGET)
	return ..()

///Handles giving the boss music to a new target the fauna has received. Basic mobs use this.
/datum/component/boss_music/proc/on_basic_target_changed(atom/source)
	SIGNAL_HANDLER
	var/mob/living/new_target = source.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!new_target || !istype(new_target))
		return
	register_new_listener(new_target)

///Handles giving the boss music to a new target the fauna has received. Hostile animals use this.
/datum/component/boss_music/proc/on_hostile_target_found(atom/source, mob/living/new_target)
	SIGNAL_HANDLER
	if(QDELETED(source) || !isliving(new_target))
		return
	register_new_listener(new_target)

///Called when a mob listening to boss music dies- ends their music early.
/datum/component/boss_music/proc/on_mob_death(mob/living/source)
	SIGNAL_HANDLER
	var/datum/weakref/player_ref = WEAKREF(source)
	unregister_old_listener(player_ref)

/datum/component/boss_music/proc/register_new_listener(mob/living/new_target)
	var/datum/weakref/new_ref = WEAKREF(new_target)
	if(new_ref in players_listening_refs)
		return

	players_listening_refs += new_ref
	RegisterSignal(new_target, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	music_callbacks += addtimer(CALLBACK(src, PROC_REF(unregister_old_listener), new_ref), track_duration, TIMER_STOPPABLE)
	new_target.playsound_local(new_target, boss_track, 200, FALSE, channel = CHANNEL_BOSS_MUSIC, pressure_affected = FALSE, use_reverb = FALSE)

/datum/component/boss_music/proc/unregister_old_listener(datum/weakref/old_ref)
	players_listening_refs -= old_ref

	var/mob/old_target = old_ref?.resolve()
	if(old_target)
		UnregisterSignal(old_target, COMSIG_LIVING_DEATH)
		old_target.stop_sound_channel(CHANNEL_BOSS_MUSIC)

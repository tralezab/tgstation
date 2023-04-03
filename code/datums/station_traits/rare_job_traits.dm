
/datum/station_trait/job
	trait_type = STATION_TRAIT_NEUTRAL
	trait_flags = STATION_TRAIT_ABSTRACT
	/// job type enabled for the round
	var/datum/job/job_type

/datum/station_trait/job/New()
	. = ..()
	RegisterSignal(SSjob, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(open_job_slots))

/datum/station_trait/job/proc/open_job_slots(datum/subsystem)
	SIGNAL_HANDLER
	var/datum/job/opened_job = SSjob.type_occupations[job_type]
	opened_job.total_positions += opened_job.bonus_positions
	opened_job.spawn_positions += opened_job.bonus_positions

/datum/station_trait/job/cargo_pack_beast
	name = "Cargo Gorilla"
	weight = 1
	show_in_report = FALSE // Selective attention test. Did you spot the pack beast?
	trait_flags = NONE
	trait_to_give = STATION_TRAIT_JOB_CARGO_PACK_BEAST
	job_type = /datum/job/cargo_pack_beast

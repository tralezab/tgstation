
#define SPIDER_ORGAN_COLOR "#0c0d11"
#define SPIDER_SCLERA_COLOR "#ff0000"
#define SPIDER_PUPIL_COLOR "#ff0000"

#define SPIDER_COLORS SPIDER_ORGAN_COLOR + SPIDER_SCLERA_COLOR + SPIDER_PUPIL_COLOR

///bonus of the spider: you grow more arms
/datum/status_effect/organ_set_bonus/spider
	organs_needed = 4
	bonus_activate_text = span_notice("Spider DNA crawls under your skin! You've learned how to create web-tunnels, and your arms begin to split?!")
	bonus_deactivate_text = span_notice("Your DNA is no longer majority spider, and your arms return to normal.")

/datum/status_effect/organ_set_bonus/spider/enable_bonus()
	. = ..()
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_NUDE, REF(src))

/datum/status_effect/organ_set_bonus/spider/disable_bonus()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_VENTCRAWLER_NUDE, REF(src))



///way more health than normal eyes, so takes more flashes to get damaged.
/obj/item/organ/internal/eyes/spider
	name = "mutated spider-eyes"
	desc = "Spider DNA infused into what was once a normal pair of eyes."
	eye_color_left = "#ff0000"
	eye_color_right = "#ff0000"

	maxHealth = STANDARD_ORGAN_THRESHOLD

	eye_icon_state = "spidereyes"
	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "eyes"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = SPIDER_COLORS

/obj/item/organ/internal/eyes/night_vision/spider/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "has 8 abyssal red eyes. It's hard to tell what they're looking at.", BODY_ZONE_PRECISE_EYES)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/spider)

#undef SPIDER_ORGAN_COLOR
#undef SPIDER_SCLERA_COLOR
#undef SPIDER_PUPIL_COLOR

#undef SPIDER_COLORS

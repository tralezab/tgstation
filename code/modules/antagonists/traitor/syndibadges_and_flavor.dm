///syndibadge, a free limited item that shows your employer.
/obj/item/clothing/accessory/syndibadge
	name = "generic syndibadge"
	desc = "An overdesigned electronic badge, given to members of the syndicate for the uncommon cases in the field \
		where identification and employment must be verified."

	icon = 'icons/obj/clothing/syndibadges.dmi'
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	icon_state = "plasma"

	verb_say = "states"
	/// what the badge will say on display
	var/badge_quote = "Hail the Syndicate."
	/// if the badge should speak on display
	var/should_speak = TRUE

/obj/item/clothing/accessory/syndibadge/alt_click_secondary(mob/user)
	. = ..()
	should_speak = !should_speak
	user.balloon_alert(user, "[should_speak ? "enabled" : "disabled"] speaker")

/obj/item/clothing/accessory/syndibadge/gorlex
	name = "gorlex marauders syndibadge"

	icon_state = "gorlex_marauders"

/obj/item/clothing/accessory/syndibadge/bee_liberation_front
	name = "bee liberation front syndibadge"

	icon_state = "bee_liberation_front"

	badge_quote = "Never forget the Day of Buzzing!"

/obj/item/clothing/accessory/syndibadge/tiger_cooperative

	badge_quote = "We are not God's chosen. Humanity must accept this, and learn to serve."

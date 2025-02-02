/datum/action/item_action/ninja_stealth
	name = "Toggle Stealth"
	desc = "Toggles stealth mode on and off. Passively encrease suit energy consumption."
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "ninja_cloak"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Cloak-Tech Device"

/**
 * Proc called to toggle ninja stealth.
 *
 * Proc called to toggle whether or not the ninja is in stealth mode.
 * If cancelling, calls a separate proc in case something else needs to quickly cancel stealth.
 */
/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(ninja, span_warning("Вы не можете применить невидимость без энергии!"))
			return
		if(!do_after(ninja, 2 SECONDS, FALSE, ninja))
			to_chat(ninja, span_warning("Вы прервали невидимость!"))
			return
		stealth = !stealth
		n_shoes.silence_steps = TRUE
		animate(ninja, alpha = NINJA_ALPHA_INVISIBILITY,time = 6)	// Я долго думала над этим и решила, что с учётом того, что теперь любой выстрел/удар от/по ниндзя выводит его из инвиза. Можно спокойно выкрутить альфу в 0
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(ninja), ninja.dir)
		ninja.visible_message(span_warning("[ninja.name] расстворил[genderize_ru(ninja.gender, "ся", "ась", "ось", "ись") ] в воздухе!"), span_notice("Теперь вас невозможно увидеть невооружённым глазом. Ровно как и стандартными оптическими приборами."))
		ninja.AddComponent(/datum/component/ninja_states_breaker, src)
		for(var/datum/action/item_action/ninja_stealth/ninja_action in actions)
			toggle_ninja_action_active(ninja_action, TRUE)

/**
 * Proc called to cancel stealth.
 *
 * Called to cancel the stealth effect if it is ongoing.
 * Does nothing otherwise.
 * Arguments:
 * * Returns false if either the ninja no longer exists or is already visible, returns true if we successfully made the ninja visible.
 */
/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/ninja = affecting
	if(!ninja)
		return FALSE
	if(stealth)
		stealth = !stealth
		n_shoes.silence_steps = FALSE
		var/stealth_alpha
		stealth_alpha = spirited ? NINJA_ALPHA_SPIRIT_FORM : NINJA_ALPHA_NORMAL
		animate(ninja, alpha = stealth_alpha, time = 6)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(ninja), ninja.dir)
		ninja.visible_message(span_warning("[ninja.name] появ[genderize_ru(ninja.gender, "ляется", "илась", "илось", "ились") ] из воздуха!"), span_notice("Теперь вас снова видно невооружённым глазом."))
		qdel(ninja.GetComponent(/datum/component/ninja_states_breaker))
		for(var/datum/action/item_action/ninja_stealth/ninja_action in actions)
			toggle_ninja_action_active(ninja_action, FALSE)
		return TRUE
	return FALSE

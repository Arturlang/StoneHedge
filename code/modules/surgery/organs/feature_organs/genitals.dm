/obj/item/organ/penis
	name = "penis"
	icon_state = "penis"
	dropshrink = 0.5
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_PENIS
	organ_size = DEFAULT_PENIS_SIZE
	organ_dna_type = /datum/organ_dna/penis
	accessory_type = /datum/sprite_accessory/penis/human
	var/sheath_type = SHEATH_TYPE_NONE
	var/erect_state = ERECT_STATE_NONE
	var/penis_type = PENIS_TYPE_PLAIN
	var/always_hard = FALSE
	var/strapon = FALSE

/obj/item/organ/penis/proc/update_erect_state()
	if(istype(src, /obj/item/organ/penis/internal))
		return
	var/oldstate = erect_state
	var/new_state = ERECT_STATE_NONE
	if(owner)
		var/mob/living/carbon/human/human = owner
		if(always_hard || (human.sexcon.arousal > 20 && human.sexcon.manual_arousal == 1) || human.sexcon.manual_arousal == 4)
			new_state = ERECT_STATE_HARD
		else if(human.sexcon.arousal > 10 && human.sexcon.manual_arousal == 1 || human.sexcon.manual_arousal == 3)
			new_state = ERECT_STATE_PARTIAL
		else
			new_state = ERECT_STATE_NONE

	erect_state = new_state
	if(oldstate != erect_state && owner)
		owner.update_body_parts(TRUE)

/obj/item/organ/penis/knotted
	name = "knotted penis"
	penis_type = PENIS_TYPE_KNOTTED
	sheath_type = SHEATH_TYPE_NORMAL
	icon_state = "knotpenis"

/obj/item/organ/penis/knotted/big
	organ_size = 5

/obj/item/organ/penis/equine
	name = "equine penis"
	penis_type = PENIS_TYPE_EQUINE
	sheath_type = SHEATH_TYPE_NORMAL
	icon_state = "equinepenis"

/obj/item/organ/penis/tapered_mammal
	name = "tapered penis"
	penis_type = PENIS_TYPE_TAPERED
	sheath_type = SHEATH_TYPE_NORMAL
	icon_state = "taperedpenis"

/obj/item/organ/penis/tapered
	name = "tapered penis"
	penis_type = PENIS_TYPE_TAPERED
	sheath_type = SHEATH_TYPE_SLIT
	icon_state = "taperedpenis"

/obj/item/organ/penis/tapered_double
	name = "hemi tapered penis"
	penis_type = PENIS_TYPE_TAPERED_DOUBLE
	sheath_type = SHEATH_TYPE_SLIT
	icon_state = "hemipenis"

/obj/item/organ/penis/tapered_double_knotted
	name = "hemi knotted tapered penis"
	penis_type = PENIS_TYPE_TAPERED_DOUBLE_KNOTTED
	sheath_type = SHEATH_TYPE_SLIT
	icon_state = "hemiknotpenis"

/obj/item/organ/penis/barbed
	name = "barbed penis"
	penis_type = PENIS_TYPE_BARBED
	sheath_type = SHEATH_TYPE_NORMAL
	icon_state = "barbpenis"

/obj/item/organ/penis/barbed_knotted
	name = "barbed knotted penis"
	penis_type = PENIS_TYPE_BARBED_KNOTTED
	sheath_type = SHEATH_TYPE_NORMAL
	icon_state = "barbpenis"

/obj/item/organ/penis/tentacle
	name = "tentacle penis"
	penis_type = PENIS_TYPE_TENTACLE
	sheath_type = SHEATH_TYPE_NONE
	icon_state = "tentapenis"

/obj/item/organ/filling_organ/anus
	//absorbs faster than womb, less capacity.
	name = "anus"
	icon = 'modular_stonehedge/licensed-eaglephntm/icons/obj/surgery.dmi'
	icon_state = "anus"
	dropshrink = 0.5
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_ANUS
	accessory_type = /datum/sprite_accessory/none
	max_reagents = 20 //less size than vagene in turn for more effective absorbtion
	absorbing = TRUE
	absorbmult = 1.5 //more effective absorb than others i guess.
	altnames = list("ass", "asshole", "butt", "butthole", "guts") //used in thought messages.
	spiller = TRUE
	blocker = ITEM_SLOT_PANTS
	bloatable = TRUE

/obj/item/organ/filling_organ/vagina
	name = "vagina"
	icon = 'modular_stonehedge/licensed-eaglephntm/icons/obj/surgery.dmi'
	icon_state = "vagina"
	dropshrink = 0.5
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_VAGINA
	accessory_type = /datum/sprite_accessory/vagina/human
	max_reagents = 40 //big cap, ordinary absorbtion.
	absorbing = TRUE
	fertility = TRUE
	altnames = list("vagina", "cunt", "womb", "pussy", "slit", "kitty", "snatch") //used in thought messages.
	spiller = TRUE
	blocker = ITEM_SLOT_PANTS
	bloatable = TRUE
	var/pre_pregnancy_size = 0

//we handle all of this here because cant timer another goddamn thing from here correctly.
/obj/item/organ/filling_organ/vagina/proc/be_impregnated(silent = FALSE)
	if(pregnant || !pregnantaltorgan || !owner || owner.stat == DEAD)
		return
	if(!silent && owner.has_quirk(/datum/quirk/selfawaregeni))
		to_chat(owner, span_love("I feel a surge of warmth in my [name], I’m definitely pregnant!"))
	pregnant = TRUE
	pre_pregnancy_size = pregnantaltorgan.organ_size

	var/obj/item/organ/filling_organ/breasts/breasties = owner.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasties && !breasties.refilling)
		breasties.refilling = TRUE
		if(owner.has_quirk(/datum/quirk/selfawaregeni))
			to_chat(owner, span_love("My [breasties] should start lactating soon..."))

	var/obj/item/organ/belly/belly = owner.getorganslot(ORGAN_SLOT_BELLY)
	if(belly)
		pre_pregnancy_size = belly.organ_size

	RegisterSignal(SSticker, COMSIG_ROUNDEND, PROC_REF(save_preggo))
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(undo_preggoness))

/obj/item/organ/filling_organ/vagina/proc/undo_preggoness()
	if(!pregnant)
		return
	pregnant = FALSE
	to_chat(owner, span_love("I feel my [src] shrink to how it was before. Pregnancy is no more."))
	if(owner.getorganslot(ORGAN_SLOT_BELLY))
		var/obj/item/organ/belly/bellyussy = owner.getorganslot(ORGAN_SLOT_BELLY)
		bellyussy.organ_size = pre_pregnancy_size
	owner.update_body_parts(TRUE)

/obj/item/organ/filling_organ/vagina/proc/handle_preggoness()
	var/obj/item/organ/belly/belly = owner.getorganslot(ORGAN_SLOT_BELLY)
	if(belly && belly.organ_size < 4)
		to_chat(owner, span_lovebold("I notice my belly has grown due to pregnancy...")) //dont need to repeat this probably if size cant grow anyway.
		belly.organ_size = belly.organ_size + 1
		owner.update_body_parts(TRUE)


/obj/item/organ/filling_organ/vagina/proc/be_impregnated(silent = FALSE)
	if(pregnant || !pregnantaltorgan || !owner || owner.stat == DEAD)
		return
	if(!silent && owner.has_quirk(/datum/quirk/selfawaregeni))
		to_chat(owner, span_love("I feel a surge of warmth in my [name], I’m definitely pregnant!"))
	pregnant = TRUE
	pre_pregnancy_size = pregnantaltorgan.organ_size
	preggotimer = addtimer(CALLBACK(src, PROC_REF(handle_preggo_growth)), 2 HOURS, TIMER_STOPPABLE)

	var/obj/item/organ/filling_organ/breasts/breasties = owner.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasties && !breasties.refilling && owner.has_quirk(/datum/quirk/selfawaregeni))
		to_chat(owner, span_love("My [breasties.name] should start lactating soon..."))
	breasties.refilling = TRUE
	RegisterSignal(SSticker, COMSIG_ROUNDEND, PROC_REF(save_preggo))
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(undo_preggoness))

/obj/item/organ/filling_organ/vagina/proc/save_preggo()
	if(!owner && !pregnant && owner.stat == DEAD)
		return
	// technically, there's 4 stages, and motherhood needs to consider that, and the other number is to increment it next time
	owner.set_persistent_motherhood_stage(pregnantaltorgan.organ_size + 2)

/obj/item/organ/filling_organ/vagina/proc/handle_preggo_growth()
	if(!owner)
		return
	if(organ_size < 3)
		set_preggo_stage(pregnantaltorgan.organ_size + 1)

/obj/item/organ/filling_organ/vagina/proc/set_preggo_stage(stage = 1)
	if(!pregnant || !pregnantaltorgan)
		return
	to_chat(owner, span_love("I noticed my [pregnantaltorgan.name] has grown...")) //dont need to repeat this probably if size cant grow anyway.
	if(organ_sizeable)
		pregnantaltorgan.set_preggoness_stage(stage)
	if(preggotimer)
		deltimer(preggotimer)
	pregnancy_debuff(stage * 2)

/obj/item/organ/filling_organ/vagina/proc/pregnancy_debuff(debuff_value = 1)
	// normalize stats, and then debuff them.
	if(pregnancy_stat_debuff_multiplier)
		owner.change_stat(STAT_SPEED, -pregnancy_stat_debuff_multiplier)
		owner.change_stat(STAT_ENDURANCE, -pregnancy_stat_debuff_multiplier)
	if(debuff_value == 0)
		return
	pregnancy_stat_debuff_multiplier = debuff_value
	owner.change_stat(STAT_SPEED, debuff_value)
	owner.change_stat(STAT_ENDURANCE, debuff_value)

/obj/item/organ/filling_organ/vagina
	var/pregnancy_stat_debuff_multiplier = 0

/obj/item/organ/filling_organ/vagina/Remove(mob/living/carbon/M, special, drop_if_replaced)
	// yes you can remove the breasts, then remove this organ to have it refilling forever, but I do not care.
	if(pregnant)
		undo_preggoness()
	. = ..() // this nulls owner

/obj/item/organ/belly/proc/set_preggoness_stage(stage = 1, silent = FALSE)
	var/datum/sprite_accessory/acc = accessory_type
	organ_size = stage
	acc.get_icon_state() // unsure the function of this
	owner.update_body_parts(TRUE)

/obj/item/organ/filling_organ/vagina/proc/undo_preggoness()
	if(!pregnant)
		return

	UnregisterSignal(SSticker, COMSIG_ROUNDEND)
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	pregnant = FALSE

	var/obj/item/organ/belly/belly = owner.getorganslot(ORGAN_SLOT_BELLY)
	if(belly)
		to_chat(owner, span_love("I feel my [belly.name] shrink to how it was before. Pregnancy is no more."))
		// var/datum/sprite_accessory/belly/bellyacc = belly.accessory_type
		// belly.organ_size = pre_pregnancy_size
		// bellyacc.get_icon_state()

	var/obj/item/organ/filling_organ/breasts/breasties = owner.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasties)
		addtimer(CALLBACK(breasties, TYPE_PROC_REF(/obj/item/organ/filling_organ/breasts, normalize_breasts)), 2 HOURS)

	owner.update_body_parts(TRUE)
	pregnancy_debuff(0)

/obj/item/organ/filling_organ/breasts/proc/normalize_breasts()
	refilling = FALSE

/obj/item/organ/filling_organ/breasts
	name = "breasts"
	icon = 'modular_stonehedge/licensed-eaglephntm/icons/obj/surgery.dmi'
	icon_state = "breasts"
	dropshrink = 0.8
	visible_organ = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BREASTS
	organ_dna_type = /datum/organ_dna/breasts
	accessory_type = /datum/sprite_accessory/breasts/pair
	organ_size = DEFAULT_BREASTS_SIZE
	reagent_to_make = /datum/reagent/consumable/milk
	hungerhelp = TRUE
	organ_sizeable = TRUE
	absorbing = FALSE //funny liquid tanks
	altnames = list("breasts", "tits", "milkers", "tiddies", "badonkas", "boobas") //used in thought messages.
	startsfilled = TRUE
	blocker = ITEM_SLOT_SHIRT

/obj/item/organ/filling_organ/breasts/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!refilling)
		reagents.clear_reagents()

/obj/item/organ/belly
	name = "belly"
	icon = 'modular_stonehedge/licensed-eaglephntm/icons/obj/surgery.dmi'
	icon_state = "belly"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_STOMACH
	slot = ORGAN_SLOT_BELLY
	organ_dna_type = /datum/organ_dna/belly
	accessory_type = /datum/sprite_accessory/belly
	organ_size = DEFAULT_BELLY_SIZE

/obj/item/organ/filling_organ/testicles
	name = "testicles"
	icon = 'modular_stonehedge/licensed-eaglephntm/icons/obj/surgery.dmi'
	icon_state = "testicles"
	dropshrink = 0.5
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TESTICLES
	organ_dna_type = /datum/organ_dna/testicles
	accessory_type = /datum/sprite_accessory/testicles/pair
	organ_size = DEFAULT_TESTICLES_SIZE
	reagent_to_make = /datum/reagent/consumable/cum
	refilling = TRUE
	reagent_generate_rate = 0.2
	storage_per_size = 20 //more size since they have so little size selections.
	organ_sizeable = TRUE
	altnames = list("balls", "testicles", "testes", "orbs", "cum tanks", "seed tanks") //used in thought messages.
	startsfilled = TRUE
	blocker = ITEM_SLOT_PANTS
	var/virility = TRUE

/obj/item/organ/filling_organ/testicles/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!virility)
		reagent_to_make = /datum/reagent/consumable/cum/sterile
		reagents.clear_reagents()
		reagents.add_reagent(reagent_to_make, reagents.maximum_volume)

/obj/item/organ/butt
	name = "butt"
	icon = 'modular_stonehedge/licensed-eaglephntm/icons/obj/surgery.dmi'
	icon_state = "butt"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_STOMACH
	slot = ORGAN_SLOT_BUTT
	organ_dna_type = /datum/organ_dna/butt
	accessory_type = /datum/sprite_accessory/butt/pair
	organ_size = DEFAULT_BUTT_SIZE


/obj/item/organ/filling_organ/testicles/internal
	name = "internal testicles"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/obj/item/organ/penis/internal
	name = "internal penis"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/obj/item/organ/filling_organ/vagina/internal
	name = "internal vagina"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/obj/item/organ/filling_organ/breasts/internal
	name = "internal breasts"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/obj/item/organ/belly/internal
	name = "internal belly"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/obj/item/organ/butt/internal
	name = "internal butt"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

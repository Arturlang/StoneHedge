/datum/job/roguetown/judge
	title = "Judge"
	flag = JUDGE
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	display_order = JDO_JUDGE
	tutorial = "You are both judge and executioner, this is a career you honed over many years of study and practice. You help plan with the Councillors and maybe the King on any new issues, laws, and judgement on any problems that may arise. You have two assistant Councillors that may serve as jurors to assist you in your job. You are required to enforce taxes for the King, judge people for breaking the law, make sure the town and manor are not in decay, and to help plan or construct new buildings. You are allowed some limited control over Guards, however it is not the focus of your job unless special circumstances are to change this. In matters of heresy, work alongside the church as best as possible."
	whitelist_req = FALSE

	outfit = /datum/outfit/job/roguetown/judge

	give_bank_account = 40
	min_pq = 2
	max_pq = null

	cmode_music = 'sound/music/combat_judge.ogg'

/datum/outfit/job/roguetown/judge/pre_equip(mob/living/carbon/human/H)
	..()
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/judge
	shirt = /obj/item/clothing/suit/roguetown/shirt/vest
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/nobleboot
	head = /obj/item/clothing/head/roguetown/judgehat
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/keyring/judge
	beltr = /obj/item/rogueweapon/mace
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	gloves = /obj/item/clothing/gloves/roguetown/angle
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/book/rogue/law = 1)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.change_stat("strength", 3)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 3)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)
		H.change_stat("fortune", 1)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	H.verbs |= /mob/proc/haltyell
	H.verbs |= list(/mob/living/carbon/human/proc/request_outlaw, /mob/living/carbon/human/proc/request_law, /mob/living/carbon/human/proc/request_law_removal, /mob/living/carbon/human/proc/request_purge, /mob/living/carbon/human/proc/torture_victim)

/mob/living/carbon/human/proc/request_law()
	set name = "Request Law"
	set category = "Judge"
	if(stat)
		return
	var/inputty = input("Write a new law", "JUDGE") as text|null
	if(inputty)
		if(hasomen(OMEN_NOLORD))
			make_law(inputty)
		else
			var/lord = find_lord()
			if(lord)
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(lord_law_requested), src, lord, inputty)
			else
				make_law(inputty)

/mob/living/carbon/human/proc/request_law_removal()
	set name = "Request Law Removal"
	set category = "Judge"
	if(stat)
		return
	var/inputty = input("Remove a law", "JUDGE") as text|null
	var/law_index = text2num(inputty) || 0
	if(law_index && GLOB.laws_of_the_land[law_index])
		if(hasomen(OMEN_NOLORD))
			remove_law(law_index)
		else
			var/lord = find_lord()
			if(lord)
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(lord_law_removal_requested), src, lord, law_index)
			else
				remove_law(law_index)

/mob/living/carbon/human/proc/request_purge()
	set name = "Request Purge"
	set category = "Judge"
	if(stat)
		return
	if(hasomen(OMEN_NOLORD))
		purge_laws()
	else
		var/lord = find_lord()
		if(lord)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(lord_purge_requested), src, lord)
		else
			purge_laws()

/mob/living/carbon/human/proc/request_outlaw()
	set name = "Request Outlaw"
	set category = "Judge"
	if(stat)
		return
	var/inputty = input("Outlaw a person", "Judge") as text|null
	if(inputty)
		if(hasomen(OMEN_NOLORD))
			make_outlaw(inputty)
		else
			var/lord = find_lord()
			if(lord)
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(lord_outlaw_requested), src, lord, inputty)
			else
				make_outlaw(inputty)

/proc/find_lord(required_stat = CONSCIOUS)
	var/mob/living/lord
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(!H.mind || H.job != "Monarch" || (H.stat > required_stat))
			continue
		lord = H
		break
	return lord

/proc/lord_law_requested(mob/living/judge, mob/living/carbon/human/lord, requested_law)
	var/choice = alert(lord, "The judge requests a new law!\n[requested_law]", "JUDGE LAW REQUEST", "Yes", "No")
	if(choice != "Yes" || QDELETED(lord) || lord.stat > CONSCIOUS)
		if(judge)
			to_chat(span_warning("The lord has denied the request for a new law!"))
		return
	make_law(requested_law)

/proc/lord_law_removal_requested(mob/living/judge, mob/living/carbon/human/lord, requested_law)
	if(!requested_law || !GLOB.laws_of_the_land[requested_law])
		return
	var/choice = alert(lord, "The judge requests the removal of a law!\n[GLOB.laws_of_the_land[requested_law]]", "JUDGE LAW REQUEST", "Yes", "No")
	if(choice != "Yes" || QDELETED(lord) || lord.stat > CONSCIOUS)
		if(judge)
			to_chat(span_warning("The lord has denied the request for a law removal!"))
		return
	remove_law(requested_law)

/proc/lord_purge_requested(mob/living/judge, mob/living/carbon/human/lord)
	var/choice = alert(lord, "The judge requests a purge of all laws!", "JUDGE PURGE REQUEST", "Yes", "No")
	if(choice != "Yes" || QDELETED(lord) || lord.stat > CONSCIOUS)
		if(judge)
			to_chat(span_warning("The lord has denied the request for a purge of all laws!"))
		return
	purge_laws()

/proc/lord_outlaw_requested(mob/living/judge, mob/living/carbon/human/lord, requested_outlaw)
	var/choice = alert(lord, "The judge requests to outlaw someone!\n[requested_outlaw]", "JUDGE OUTLAW REQUEST", "Yes", "No")
	if(choice != "Yes" || QDELETED(lord) || lord.stat > CONSCIOUS)
		if(judge)
			to_chat(span_warning("The lord has denied the request for declaring an outlaw!"))
		return
	make_outlaw(requested_outlaw)

/datum/advclass/seamstress
	name = "Seamster"
	f_title = "Seamstress"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDSPLUS
	outfit = /datum/outfit/job/roguetown/adventurer/seamstress
	category_tags = list(CTAG_PILGRIM, CTAG_TOWNER)

/datum/outfit/job/roguetown/adventurer/seamstress/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank_up_to(/datum/skill/misc/sewing, 5, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/craft/crafting, 4, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/combat/knives, 4, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/misc/medicine, 3, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/misc/sneaking, 3, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/labor/farming, 2, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/craft/hunting, 4, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/craft/carpentry, 4, TRUE)
	H.mind.adjust_skillrank_up_to(/datum/skill/misc/stealing, 2, TRUE)
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	armor = /obj/item/clothing/suit/roguetown/armor/armordress
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/white
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/cloth/lady
	beltr = /obj/item/rogueweapon/huntingknife/scissors
	beltl = /obj/item/roguekey/tailor
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/natural/cloth = 2, /obj/item/natural/bundle/fibers/full = 1)
	H.change_stat("intelligence", 2)
	H.change_stat("speed", 2)
	H.change_stat("perception", 3)
	if(isseelie(H))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/seelie_dust)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/summon_rat)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/strip)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/seelie_kiss)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/splash)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/roustame)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/animate_object)

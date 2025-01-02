#define CTYPE_GOLD "g"
#define CTYPE_SILV "s"
#define CTYPE_COPP "c"
#define MAX_COIN_STACK_SIZE 20

/obj/item/roguecoin
	name = ""
	desc = ""
	icon = 'icons/roguetown/items/valuable.dmi'
	icon_state = ""
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_MOUTH
	dropshrink = 0.2
	drop_sound = 'sound/foley/coinphy (1).ogg'
	sellprice = 0
	static_price = TRUE
	simpleton_price = TRUE
	var/flip_cd
	var/heads_tails = TRUE
	var/last_merged_heads_tails = TRUE
	var/base_type //used for compares
	var/quantity = 1
	var/plural_name
	destroy_sound = 'sound/foley/coinphy (1).ogg'

/obj/item/roguecoin/Initialize(mapload, coin_amount)
	. = ..()
	if(coin_amount >= 1)
		set_quantity(floor(coin_amount))

/obj/item/roguecoin/getonmobprop(tag)
	. = ..()
	if(tag != "gen")
		return
	return list("shrink" = 0.10, "sx" = -6, "sy" = 6, "nx" = 6, "ny" = 7, "wx" = 0, "wy" = 5, "ex" = -1, "ey" = 7, "northabove" = 0, "southabove" = 1, "eastabove" = 1, "westabove" = 0, "nturn" = -50, "sturn" = 40, "wturn" = 50, "eturn" = -50, "nflip" = 0, "sflip" = 8, "wflip" = 8, "eflip" = 0)

/obj/item/roguecoin/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	playsound(loc, 'sound/foley/coins1.ogg', 100, TRUE, -2)
	scatter(get_turf(src))
	..()

/obj/item/roguecoin/pickup(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_MATTHIOS_CURSE))
		var/mob/living/carbon/human/H = user
		to_chat(H, span_warning("The idea repulses me!"))
		H.cursed_freak_out()
		H.Paralyze(20)
		return

/obj/item/roguecoin/proc/scatter(turf/T)
	pixel_x = rand(-8, 8)
	pixel_y = rand(-5, 5)
	if(isturf(T) && quantity > 1)
		var/obj/structure/table/TA = locate() in T
		if(!TA) //no table
			var/obj/item/roguecoin/new_coin = new type(T)
			new_coin.set_quantity(1) // prevent exploits with coin piles
			new_coin.pixel_x = rand(-8, 8)
			new_coin.pixel_y = rand(-5, 5)
			set_quantity(quantity - 1)

/obj/item/roguecoin/get_real_price()
	return sellprice * quantity

/obj/item/roguecoin/proc/set_quantity(new_quantity)
	quantity = new_quantity
	update_icon()
	update_transform()

/obj/item/roguecoin/examine(mob/user)
	. = ..()
	if(quantity > 1)
		. += span_info("\Roman [quantity] coins.")

/obj/item/roguecoin/proc/merge(obj/item/roguecoin/G, mob/user)
	if(!G)
		return
	if(G.base_type != base_type)
		return

	var/amt_to_merge = min(G.quantity, MAX_COIN_STACK_SIZE - quantity)
	if(amt_to_merge <= 0)
		return
	set_quantity(quantity + amt_to_merge)
	last_merged_heads_tails = G.heads_tails

	G.set_quantity(G.quantity - amt_to_merge)
	if(G.quantity == 0)
		user.doUnEquip(G)
		qdel(G)
	user.update_inv_hands()
	playsound(loc, 'sound/foley/coins1.ogg', 100, TRUE, -2)

/obj/item/roguecoin/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src && quantity > 1)
		var/amt_text = " (1 to [quantity])"
		if(quantity == 1)
			amt_text = ""
		var/amount = input(user, "How many [plural_name] to split?[amt_text]", null, round(quantity/2, 1)) as null|num
		amount = clamp(amount, 0, quantity)
		amount = round(amount, 1) // no taking non-integer coins
		if(!amount)
			return
		if(amount >= quantity)
			return ..()
		var/obj/item/roguecoin/new_coins = new type()
		new_coins.set_quantity(amount)
		new_coins.heads_tails = last_merged_heads_tails
		set_quantity(quantity - amount)

		user.put_in_hands(new_coins)
		playsound(loc, 'sound/foley/coins1.ogg', 100, TRUE, -2)
		return
	..()


/obj/item/roguecoin/attack_self(mob/living/user)
	if(quantity > 1 || !base_type)
		return
	if(world.time < flip_cd + 30)
		return
	flip_cd = world.time
	playsound(user, 'sound/foley/coinphy (1).ogg', 100, FALSE)
	if(prob(50))
		user.visible_message(span_info("[user] flips the coin. Heads!"))
		heads_tails = TRUE
	else
		user.visible_message(span_info("[user] flips the coin. Tails!"))
		heads_tails = FALSE
	update_icon()

/obj/item/roguecoin/update_icon()
	..()
	if(quantity > 1)
		drop_sound = 'sound/foley/coins1.ogg'
	else
		drop_sound = 'sound/foley/coinphy (1).ogg'
		
	if(quantity == 1)
		name = initial(name)
		desc = initial(desc)
		icon_state = "[base_type][heads_tails]"
		dropshrink = 0.2
		slot_flags = ITEM_SLOT_MOUTH
		return

	name = plural_name
	desc = ""
	dropshrink = 1
	slot_flags = null
	switch(quantity)
		if(2)
			dropshrink = 0.2 // this is just like the single coin, gotta shrink it
			icon_state = "[base_type]m"
			if(heads_tails == last_merged_heads_tails)
				icon_state = "[base_type][heads_tails]1"
		if(3)
			icon_state = "[base_type]2"
		if(4 to 5)
			icon_state = "[base_type]3"
		if(6 to 10)
			icon_state = "[base_type]5"
		if(11 to 15)
			icon_state = "[base_type]10"
		if(16 to INFINITY)
			icon_state = "[base_type]15"


/obj/item/roguecoin/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/roguecoin))
		var/obj/item/roguecoin/G = I
		merge(G, user)
		return
	return ..()

/obj/item/reagent_containers/food/snacks/gold
	name = "temporary kobold coin snack item for gold"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("gold" = 1, "commerce" = 1)
	foodtype = CLOTH

/obj/item/reagent_containers/food/snacks/silver
	name = "temporary kobold coin snack item for silver"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("silver" = 1, "commerce" = 1)
	foodtype = CLOTH

/obj/item/reagent_containers/food/snacks/copper
	name = "temporary kobold coin snack item for copper"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("copper" = 1, "commerce" = 1)
	foodtype = CLOTH

/obj/item/roguecoin/attack(mob/living/M, mob/living/user, def_zone)
	if(user.used_intent.type != INTENT_HARM && iskobold(M))
		var/obj/item/reagent_containers/food/snacks/gold/g = new
		var/obj/item/reagent_containers/food/snacks/silver/s = new
		var/obj/item/reagent_containers/food/snacks/copper/c = new
		var/obj/item/roguecoin/I = user.get_active_held_item()
		if(istype(I, /obj/item/roguecoin/gold))
			g.name = name
			if(g.attack(M, user, def_zone))
				take_damage(75, sound_effect=FALSE)
			qdel(g)
		if(istype(I, /obj/item/roguecoin/silver))
			s.name = name
			if(s.attack(M, user, def_zone))
				take_damage(75, sound_effect=FALSE)
			qdel(s)
		if(istype(I, /obj/item/roguecoin/copper))
			c.name = name
			if(c.attack(M, user, def_zone))
				take_damage(75, sound_effect=FALSE)
			qdel(c)

//GOLD
/obj/item/roguecoin/gold
	name = "zenar"
	desc = "A gold coin bearing the symbol of the Taurus and the pre-kingdom psycross. These were in the best condition of the provincial gold mints, the rest were melted down."
	icon_state = "g1"
	sellprice = 10
	base_type = CTYPE_GOLD
	plural_name = "zenarii"


// SILVER
/obj/item/roguecoin/silver
	name = "ziliqua"
	desc = "An ancient silver coin still in use due to their remarkable ability to last the ages."
	icon_state = "s1"
	sellprice = 5
	base_type = CTYPE_SILV
	plural_name = "ziliquae"

// COPPER
/obj/item/roguecoin/copper
	name = "zenny"
	desc = "A brand-new bronze coin minted by the capital in an effort to be rid of the financial use of silver."
	icon_state = "c1"
	sellprice = 1
	base_type = CTYPE_COPP
	plural_name = "zennies"

/obj/item/roguecoin/copper/pile/Initialize()
	. = ..()
	set_quantity(rand(4,19))

/obj/item/roguecoin/silver/pile/Initialize()
	. = ..()
	set_quantity(rand(4,19))

/obj/item/roguecoin/gold/pile/Initialize()
	. = ..()
	set_quantity(rand(4,19))

#undef CTYPE_GOLD
#undef CTYPE_SILV
#undef CTYPE_COPP
#undef MAX_COIN_STACK_SIZE

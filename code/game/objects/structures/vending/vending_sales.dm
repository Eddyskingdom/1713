/**
 *  A vending machine / market stall that actually charges per sale.
 */
/obj/structure/vending/sales
	name = "Vending Machine"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "snack"
	layer = 2.9
	anchored = TRUE
	density = TRUE
	flammable = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE

	var/moneyin = 0
	var/owner = "Global"
	var/max_products = 5

/obj/structure/vending/ex_act(severity)
	return

/obj/structure/vending/sales/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/stack/money))
		var/obj/item/stack/money/M = W
		moneyin += M.amount*M.value
		user << "You put \the [W] in the [src]."
		qdel(W)
		return
	else if (istype(W, /obj/item/weapon/wrench))
		if (owner != "Global" && find_company_member(user,owner))
			playsound(loc, 'sound/items/Ratchet.ogg', 100, TRUE)
			if (anchored)
				user.visible_message("[user] begins unsecuring \the [src] from the floor.", "You start unsecuring \the [src] from the floor.")
			else
				user.visible_message("[user] begins securing \the [src] to the floor.", "You start securing \the [src] to the floor.")

			if (do_after(user, 20, src))
				if (!src) return
				user << "<span class='notice'>You [anchored? "un" : ""]secured \the [src]!</span>"
				anchored = !anchored
			return

	else
		if (owner != "Global" && find_company_member(user,owner))
			for (var/datum/data/vending_product/R in product_records)
				if (istype(W, R.product_path) && W.name == R.product_name)
					if (istype(W, /obj/item/stack))
						R.amount += W.amount
						qdel(W)
						return TRUE
					else
						stock(W, R, user)
						return TRUE
			//if it isnt in the list yet
			if (product_records.len >= max_products)
				var/datum/data/vending_product/free = null
				for (var/datum/data/vending_product/R in product_records)
					if (R.amount <= 0)
						free=R
				if (!free)
					user << "<span class='notice'>This [src] has too many different products already!</span>"
					return FALSE
				else
					product_records -= free
			user.unEquip(W)
			var/datum/data/vending_product/product = new/datum/data/vending_product(src, W.type, W.name, _icon = W.icon, _icon_state = W.icon_state, M = W)
			var/inputp = input(user, "What price do you want to set for \the [W]? (in silver coins)") as num
			if (!inputp)
				inputp = 0
			if (inputp < 0)
				inputp = 0
			product.price = inputp/10
			if (istype(W, /obj/item/stack))
				var/obj/item/stack/S = W
				product.amount = S.amount
				qdel(W)
			else
				if (W)
					W.forceMove(src)
			product_records.Add(product)
			update_icon()
			return TRUE
/obj/structure/vending/sales/verb/Manage()
	set category = null
	set src in range(1, usr)


	if (!istype(usr, /mob/living/carbon/human))
		return

	if (owner != "Global" && find_company_member(usr,owner))
		var/choice1 = WWinput(usr, "What do you want to do?", "Vendor Management", "Exit", list("Exit", "Change Name", "Change Prices", "Remove Product"))
		if (choice1 == "Exit")
			return TRUE
		else if (choice1 == "Change Name")
			var/input1 = input("What name do you want to give to this vendor?", "Vendor Name", name) as text
			if (input1 == null || input1 == "")
				return FALSE
			else
				name = input1
				return TRUE
		else if (choice1 == "Change Prices")
			var/list/choicelist = list("Exit")
			for(var/datum/data/vending_product/VP in product_records)
				choicelist += VP.product_name
			var/choice2 = WWinput(usr, "What product to change the price?", "Vendor Management", "Exit", choicelist)
			if (choice2 == "Exit")
				return FALSE
			else
				for(var/datum/data/vending_product/VP in product_records)
					if (VP.product_name == choice2)
						var/input3 = input("The current price for [VP.product_name] is [VP.price*10] silver coins. What should the new price be?", "Product Price", VP.price*10) as num
						if (input3 < 0 || input3 == null)
							return FALSE
						else
							VP.price = input3/10
							return TRUE
		else if (choice1 == "Remove Product")
			var/list/choicelist = list("Exit")
			for(var/datum/data/vending_product/VP in product_records)
				choicelist += VP.product_name
			var/choice2 = WWinput(usr, "What product to remove?", "Vendor Management", "Exit", choicelist)
			if (choice2 == "Exit")
				return FALSE
			else
				for(var/datum/data/vending_product/VP in product_records)
					if (VP.product_name == choice2)
						vend(VP, usr, VP.amount)
						return TRUE


	else
		usr << "You do not have permission to manage this vendor."
		return FALSE

/obj/structure/vending/sales/vend(datum/data/vending_product/R, mob/user, var/p_amount=1)
	vend_ready = FALSE //One thing at a time!!
	status_message = "Vending..."
	status_error = FALSE
	nanomanager.update_uis(src)

	spawn(vend_delay)
		R.get_product(get_turf(src),p_amount)
		playsound(loc, 'sound/machines/vending_drop.ogg', 100, TRUE)
		status_message = ""
		status_error = FALSE
		vend_ready = TRUE
		currently_vending = null
		update_icon()
		nanomanager.update_uis(src)

/**
 * Add item to the machine
 *
 * Checks if item is vendable in this machine should be performed before
 * calling. W is the item being inserted, R is the associated vending_product entry.
 */

/obj/structure/vending/sales/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = TRUE)
	user.set_using_object(src)

	var/list/data = list()
	if (currently_vending)
		data["mode"] = TRUE
		data["company"] = owner
		data["product"] = currently_vending.product_name
		data["price"] = currently_vending.price*10
		data["message_err"] = FALSE
		data["message"] = status_message
		data["message_err"] = status_error
		data["moneyin"] = moneyin*10
	else
		data["mode"] = FALSE
		data["company"] = owner
		data["moneyin"] = moneyin*10
		var/list/listed_products = list()

		for (var/key = TRUE to product_records.len)
			var/datum/data/vending_product/I = product_records[key]

			listed_products.Add(list(list(
				"key" = key,
				"name" = I.product_name,
				"price" = I.price*10,
				"color" = I.display_color,
				"amount" = I.amount)))

		data["products"] = listed_products

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "vending_machine2.tmpl", name, 440, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/vending/sales/Topic(href, href_list)
	if (stat & BROKEN)
		return

	if (isliving(usr))
		if (usr.stat || usr.restrained())
			return
	else if (isobserver(usr))
		if (!check_rights(R_MOD))
			return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))))
		if ((href_list["vend"]) && (vend_ready) && (!currently_vending))

			if (find_company_member(usr,owner))
				usr << "<span class='warning'>You can't buy from your own company. Remove the product instead.</span>"
				status_error = FALSE
				currently_vending = null
			else

				var/key = text2num(href_list["vend"])
				var/datum/data/vending_product/R = product_records[key]

				var/inp = 1
				if (R.amount > 1)
					inp = input(usr, "How many do you want to buy? (1 to [R.amount])",1) as num
					if (inp>R.amount)
						inp = R.amount
					else if (inp<=1)
						inp = 1

				if (R.price <= 0)
					vend(R, usr, inp)

				else
					var/mob/living/carbon/human/H = usr
					var/salestax = 0
					if (H.civilization != "none")
						salestax = (map.custom_civs[H.civilization][9]/100)*R.price
					var/price_with_tax = R.price+salestax
					currently_vending = R
					if (moneyin < price_with_tax)
						status_message = "Please insert money to pay for the item."
						status_error = FALSE
					else
						moneyin -= price_with_tax
						if (owner != "Global")
							map.custom_company_value[owner] += R.price
							if (map.custom_civs[H.civilization])
								map.custom_civs[H.civilization][5] += salestax
						var/obj/item/stack/money/goldcoin/GC = new/obj/item/stack/money/goldcoin(loc)
						GC.amount = moneyin/0.4
						if (GC.amount == 0)
							qdel(GC)
						moneyin = 0
						vend(R, usr, inp)
						nanomanager.update_uis(src)

		else if (href_list["cancelpurchase"])
			currently_vending = null

		else if (href_list["remove_money"])
			var/obj/item/stack/money/goldcoin/GC = new/obj/item/stack/money/goldcoin(loc)
			GC.amount = moneyin/0.4
			if (GC.amount == 0)
				qdel(GC)
			moneyin = 0
			nanomanager.update_uis(src)
			return

		add_fingerprint(usr)
		playsound(usr.loc, 'sound/machines/button.ogg', 100, TRUE)
		nanomanager.update_uis(src)


//STALLS AND MACHINES
/obj/structure/vending/sales/food
	name = "food vending machine"
	desc = "Basic food products."
	icon_state = "nutrimat"
	products = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 15,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 0.15,
	)

/obj/structure/vending/sales/market_stall
	name = "market stall"
	desc = "A market stall selling an assortment of goods."
	icon_state = "market_stall"
	var/image/overlay_primary = null
	var/image/overlay_secondary = null

/obj/structure/vending/sales/market_stall/New()
	..()
	invisibility = 101
	spawn(3)
		overlay_primary = image(icon = icon, icon_state = "[icon_state]_overlay_primary")
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary = image(icon = icon, icon_state = "[icon_state]_overlay_secondary")
		overlay_secondary.color = map.custom_company_colors[owner][2]
		update_icon()
		invisibility = 0

/obj/structure/vending/sales/market_stall/update_icon()
	overlays.Cut()
	if (overlay_primary && overlay_secondary)
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary.color = map.custom_company_colors[owner][2]
		overlays += overlay_primary
		overlays += overlay_secondary
	var/ct1 = 0
	for(var/datum/data/vending_product/VP in product_records)
		if (VP.product_image)
			var/image/NI = VP.product_image
			NI.layer = layer+0.01
			var/matrix/M = matrix()
			M.Scale(0.5)
			NI.transform = M
			NI.pixel_x = -10+ct1
			NI.pixel_y = -4
			overlays += NI
			ct1+=4

/obj/structure/vending/sales/vending
	name = "vending machine"
	desc = "A vending machine selling an assortment of goods."
	icon_state = "custom2"
	var/image/overlay_primary = null
	var/image/overlay_secondary = null
	max_products = 10

/obj/structure/vending/sales/vending/New()
	..()
	invisibility = 101
	spawn(3)
		overlay_primary = image(icon = icon, icon_state = "[icon_state]_overlay_primary")
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary = image(icon = icon, icon_state = "[icon_state]_overlay_secondary")
		overlay_secondary.color = map.custom_company_colors[owner][2]
		update_icon()
		invisibility = 0

/obj/structure/vending/sales/vending/update_icon()
	overlays.Cut()
	if (overlay_primary && overlay_secondary)
		overlay_primary.color = map.custom_company_colors[owner][1]
		overlay_secondary.color = map.custom_company_colors[owner][2]
		overlays += overlay_primary
		overlays += overlay_secondary
		overlays += image(icon = icon, icon_state = "[icon_state]_base")

/obj/structure/vending/sales/stock(obj/item/W, var/datum/data/vending_product/R, var/mob/user)
	if (!user.unEquip(W))
		return

	user << "<span class='notice'>You insert \the [W] in \the [src].</span>"
	if (istype(W, /obj/item/stack))
		var/obj/item/stack/S = W
		R.amount += S.amount
		qdel(W)
	else
		W.forceMove(src)
		R.product_item += W
		R.amount++
	nanomanager.update_uis(src)

/obj/structure/vending/process()
	if (stat & (BROKEN|NOPOWER))
		return

	if (!active)
		return

	return
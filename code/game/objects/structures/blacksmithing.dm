/obj/structure/anvil
	name = "anvil"
	desc = "A heavy iron anvil. The blacksmith's main work tool. It has 0 hot iron bars on it."
	icon = 'icons/obj/structures.dmi'
	icon_state = "anvil1"
	density = TRUE
	anchored = TRUE
	var/iron_amt = 0

obj/structure/anvil/New()
	..()
	desc = "A heavy iron anvil. The blacksmith's main work tool. It has [iron_amt] hot iron bars on it."

/obj/structure/anvil/attackby(obj/item/P as obj, mob/user as mob)
	if (user.original_job_title != "Blacksmith" && user.original_job_title != "Ferreiro" && user.original_job_title != "Ferrero" && user.original_job_title != "Grofsmid" && user.original_job_title != "Forgeron" && user.original_job_title != "British Blacksmith")
		user << "You don't have the skills to use this. Ask a blacksmith."
		return
	else
		if (istype(P, /obj/item/stack/material/iron))
			user << "You begin smithing the iron..."
			icon_state = "anvil2"
			playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
			if (do_after(user,30,src))
				user << "<span class='notice'>You smite the iron.</span>"
				iron_amt += 1
				icon_state = "anvil3"
				if (P.amount > 1)
					P.amount -= 1
				else
					qdel(P)

/obj/structure/anvil/attack_hand(var/mob/user as mob)
	if (user.original_job_title != "Blacksmith" && user.original_job_title != "Ferreiro" && user.original_job_title != "Ferrero" && user.original_job_title != "Grofsmid" && user.original_job_title != "Forgeron" && user.original_job_title != "British Blacksmith")
		user << "You don't have the skills to use this. Ask a blacksmith."
		return
	else if (iron_amt > 0)
		var/list/display = list("Swords","Guns", "Cancel")
		var/choice = WWinput(user, "What do you want to make?", "Blacksmith - [iron_amt] iron", "Cancel", display)
		if (choice == "Cancel")
			return
		else if (choice == "Swords")
			var/list/display2 = list("Small Sword (10)", "Sabre (15)", "Cutlass (12)", "Spadroon (15)", "Rapier (18)", "Longsword (18)", "Cancel")
			var/choice2 = WWinput(user, "What do you want to make?", "Blacksmith - [iron_amt] iron", "Cancel", display2)
			if (choice2 == "Cancel")
				return
			if (choice2 == "Small Sword (10)")
				if (iron_amt >= 10)
					user << "You begin crafting a small sword..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,90,src))
						user << "You craft a small sword."
						iron_amt -= 10
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/material/sword/smallsword(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice2 == "Sabre (15)")
				if (iron_amt >= 15)
					user << "You begin crafting a sabre..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,120,src))
						user << "You craft a sabre."
						iron_amt -= 15
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/material/sword/sabre(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice2 == "Cutlass (12)")
				if (iron_amt >= 12)
					user << "You begin crafting a cutlass..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,100,src))
						user << "You craft a cutlass."
						iron_amt -= 12
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/material/sword/cutlass(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice2 == "Rapier (18)")
				if (iron_amt >= 18)
					user << "You begin crafting a rapier..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,150,src))
						user << "You craft a rapier."
						iron_amt -= 18
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/material/sword/rapier(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice2 == "Spadroon (15)")
				if (iron_amt >= 15)
					user << "You begin crafting a spadroon..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,120,src))
						user << "You craft a spadroon."
						iron_amt -= 15
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/material/sword/spadroon(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice2 == "Longsword (18)")
				if (iron_amt >= 18)
					user << "You begin crafting a longsword..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,150,src))
						user << "You craft a longsword."
						iron_amt -= 18
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/material/sword/longsword(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return

		else if (choice == "Guns")
			var/list/display3 = list("Crude Musket (15)", "Flintlock Pistol (20)", "Flintlock Musketoon (25)", "Flintlock Musket (30)", "Flintlock Blunderbuss (25)", "Cancel")
			var/choice3 = WWinput(user, "What do you want to make?", "Blacksmith - [iron_amt] iron", "Cancel", display3)
			if (choice3 == "Crude Musket (15)")
				if (iron_amt >= 15)
					user << "You begin crafting a crude musket..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,150,src))
						user << "You craft a crude musket."
						iron_amt -= 15
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/gun/projectile/flintlock/crude(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice3 == "Flintlock Musket (30)")
				if (iron_amt >= 30)
					user << "You begin crafting a musket..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,200,src))
						user << "You craft a musket."
						iron_amt -= 30
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/gun/projectile/flintlock/musket(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice3 == "Flintlock Musketoon (25)")
				if (iron_amt >= 25)
					user << "You begin crafting a musketoon..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,170,src))
						user << "You craft a musketoon."
						iron_amt -= 25
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/gun/projectile/flintlock/musketoon(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice3 == "Flintlock Blunderbuss (25)")
				if (iron_amt >= 25)
					user << "You begin crafting a blunderbuss..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,170,src))
						user << "You craft a blunderbuss."
						iron_amt -= 25
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/gun/projectile/flintlock/blunderbuss(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice3 == "Flintlock Pistol (20)")
				if (iron_amt >= 20)
					user << "You begin crafting a pistol..."
					playsound(loc, 'sound/effects/clang.ogg', 100, TRUE)
					if (do_after(user,130,src))
						user << "You craft a pistol."
						iron_amt -= 20
						if (iron_amt <= 0)
							icon_state = "anvil1"
						new/obj/item/weapon/gun/projectile/flintlock/pistol(user.loc)
						return
				else
					user << "<span class='notice'>You need more iron to make this!</span>"
					return
			if (choice3 == "Cancel")
				return

	else if (iron_amt <= 0)
		user << "There is no hot iron on top of this anvil. Smite some first."
		return
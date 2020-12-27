/obj/screen/fullautoAimHUD
	name = ""
	desc = ""
	layer = HUD_LAYER - 1
	flags = NOSPLASH
	alpha = 0
	mouse_opacity = 2

	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEDRAG, over_location, over_control, params)

	MouseDown(location, control, params)
		. = ..()
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEDOWN, location, control, params)

/datum/component/holdertargeting/fullauto
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_FULLAUTO_MOUSEDOWN)
	mobtype = /mob/living
	proctype = .proc/begin_shootloop
	var/turf/target
	var/stopped = 0
	var/delaystart
	var/delaymin
	var/rampfactor
	var/list/obj/screen/fullautoAimHUD/hudSquares = list()

	Initialize(_delaystart = 4 DECI SECONDS, _delaymin=1 DECI SECOND, _rampfactor=0.9)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			var/obj/item/gun/G = parent
			src.delaystart = _delaystart
			src.delaymin = _delaymin
			src.rampfactor = _rampfactor
			for(var/x in 1 to WIDE_TILE_WIDTH)
				for(var/y in 1 to 15)
					var/obj/screen/fullautoAimHUD/hudSquare = new /obj/screen/fullautoAimHUD
					hudSquare.screen_loc = "[x],[y]"
					hudSquares["[x],[y]"] = hudSquare

			if(ismob(G.loc))
				on_pickup(null, G.loc)

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquare)
		. = ..()

	on_pickup(datum/source, mob/user)
		. = ..()
		for(var/x in 1 to (istext(user.client.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				user.client.screen += hudSquares["[x],[y]"]
		user.targeting_ability = 1
		user.update_cursor()
		stopped = 0

	on_dropped(datum/source, mob/user)
		end_shootloop(user)
		for(var/x in 1 to (istext(user.client.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				user.client.screen -= hudSquares["[x],[y]"]
		user.targeting_ability = 0
		user.update_cursor()
		. = ..()

/datum/component/holdertargeting/fullauto/proc/begin_shootloop(mob/living/user, location, control, params)
	if(!stopped)
		var/obj/item/gun/G = parent
		G.current_projectile.shot_number = 1
		G.current_projectile.cost = 1
		src.retarget(user, location, control, params)
		RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG, .proc/retarget)
		RegisterSignal(user, COMSIG_MOUSEUP, .proc/end_shootloop)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/moveRetarget)
		src.shootloop(user)

/datum/component/holdertargeting/fullauto/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.target)
		src.target = get_step(src.target, direct)

/datum/component/holdertargeting/fullauto/proc/retarget(mob/M, location, control, params)

	var/object
	var/list/l2 = splittext(params2list(params)["screen-loc"],",")
	if (l2.len >= 2)
		var/list/lx = splittext(l2[1],":")
		var/list/ly = splittext(l2[2],":")

		object = locate(M.x + (text2num(lx[1]) + -1 - ((istext(M.client.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
						M.y + (text2num(ly[1]) + -1 - 7),\
						M.z)

	if(get_turf(object) != get_turf(parent))
		src.target = get_turf(object)

/datum/component/holdertargeting/fullauto/proc/shootloop(mob/living/L)
	set waitfor = 0

	var/obj/item/gun/G = parent
	var/delay = delaystart
	while(G.canshoot() && !stopped)
		G.shoot(target ? target : get_step(L, NORTH), get_turf(L), L)
		G.suppress_fire_msg = 1
		sleep(max(delay*=rampfactor, delaymin))
	if(!stopped)
		end_shootloop(L)
	stopped = 0
/datum/component/holdertargeting/fullauto/proc/end_shootloop(mob/living/L)
	//loop ended - reset values
	var/obj/item/gun/G = parent
	stopped = 1
	G.current_projectile.shot_number = initial(G.current_projectile.shot_number)
	G.current_projectile.cost = initial(G.current_projectile.cost)
	G.suppress_fire_msg = 0
	UnregisterSignal(L, COMSIG_FULLAUTO_MOUSEDRAG)
	UnregisterSignal(L, COMSIG_MOUSEUP)
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)

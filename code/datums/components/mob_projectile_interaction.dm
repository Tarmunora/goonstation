/// Allows various things to happen when a mob (or object) gets hit with a projectile
/datum/component/mob_projectile_interaction

/datum/component/mob_projectile_interaction/Initialize()
	if(!istype(parent, /obj) || !istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE

/// Determines whether a projectile can pass through a mob after doing its thing, if applicable
/datum/component/mob_projectile_interaction/dense_to_projectiles
	/// How easy it is for projectiles to punch straight through them
	/// 0 will stop the projectile, 100 will let it pass through as-is (default behavior for non-dense mobs)
	var/mob_piercability = 0
	/// Projectile power must be more than this to roll to pierce
	var/threshold = 0

/datum/component/mob_projectile_interaction/dense_to_projectiles/Initialize(var/mob_piercability, var/squishy, var/threshold)
	..()
	src.mob_piercability = mob_piercability
	RegisterSignal(parent, list(COMSIG_ATOM_PROJ_COLLIDE), .proc/pierce_check)

/datum/component/mob_projectile_interaction/dense_to_projectiles/proc/pierce_check(var/atom/hit, var/obj/projectile/P)
	if (!istype(P, /obj/projectile) || (!istype(hit, /obj) && !istype(hit, /mob)) || P.goes_through_mobs || P.ticks_until_can_hit_mob > 0) return

	if(src.mob_piercability)
		var/datum/projectile/B = P.proj_data

		if (B.pierce_flag & PROJ_ALWAYS_PIERCES)
			return // No need to change anything
		else if (B.pierce_flag & PROJ_ALWAYS_PIERCES_SPECIAL)
			B.power_mod -= (P.initial_power * B.pierce_special_dmg_mult)
			return
		var/damage = B.get_power(P, hit)
		if ((damage * B.ks_ratio) < src.threshold)
			B.power_mod = -INFINITY
			return

		var/rangedprot = 1
		if(istype(hit, /mob))
			var/mob/getrangedprot = hit
			rangedprot = getrangedprot.get_ranged_protection()

		var/pierce_chance = clamp((src.mob_piercability * 0.01) * ((damage * B.ks_ratio * (B.damage_type == D_PIERCING ? PROJ_DMG_TYPE_PIERCE_PENALTY : 1)) * (1 / rangedprot)), 0, 100)

		if(prob(pierce_chance))
			/// Shot loses a bit of damage as it punches through the target
			B.power_mod -= ((damage * ((100 - pierce_chance) * 0.01)) + (P.initial_power * PROJ_PIERCE_DMG_SUBTRACTOR))
		else
			B.power_mod = -INFINITY

/datum/component/mob_projectile_interaction/dense_to_projectiles/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_PROJ_COLLIDE)
	. = ..()

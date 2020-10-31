
//pass flags
#define PROJ_PASSNONE 0
#define PROJ_PASSWALL 1
#define PROJ_PASSOBJ 2

//Projectile damage type defines
#define D_KINETIC 1
#define D_PIERCING 2
#define D_SLASHING 4
#define D_ENERGY 8
#define D_BURNING 16
#define D_RADIOACTIVE 32
#define D_TOXIC 48
#define D_SPECIAL 128

//Projectile reflection defines
#define PROJ_NO_HEADON_BOUNCE 1
#define PROJ_HEADON_BOUNCE 2
#define PROJ_RAPID_HEADON_BOUNCE 3


//Projectile obj / mob piercing flags
/// Projectile never pierces objects and mobs
#define PROJ_NEVER_PIERCES (1<<0)
/// Projectile can pierce objects and mobs
#define PROJ_PIERCES (1<<1)
/// Projectile always pierces object and mobs
#define PROJ_ALWAYS_PIERCES (1<<2)
/// Projectile always pierces object and mobs, but its power changes afterwards
#define PROJ_ALWAYS_PIERCES_SPECIAL (1<<3)

//projectile pierce number defined
/// How much to multiply the projectile's effective power for piercing calculations if the damage type is not D_PIERCING
#define PROJ_DMG_TYPE_PIERCE_PENALTY 0.5
/// What percent of the projectile's initial power is subtracted from the projectile's current power on pierce
#define PROJ_PIERCE_DMG_SUBTRACTOR 0.1

//default max range for 'unlimited' range projectiles
#define PROJ_INFINITE_RANGE 500


-- Evil Bunny by ExeterDad

local bunny_evil_def = {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	group_attack = true,
	pathfinding = true,
	reach = 2,
	damage = 3,
	hp_min = 25,
	hp_max = 35,
	armor = 200,
	collisionbox = {-0.268, -0.5, -0.268,  0.268, 0.167, 0.268},
	visual = "mesh",
	mesh = "spawners_mobs_evil_bunny.b3d",
	rotate = 0,
	textures = {
		{"spawners_mobs_evil_bunny.png"},
	},
	sounds = {
		random = "spawners_mobs_bunny",
	},
	makes_footstep_sound = false,
	walk_velocity = 1.5,
	run_velocity = 4,
	view_range = 15,
	jump = true,
	floats = 0,
	drops = {
		{name = "mobs:meat_raw", chance = 1, min = 1, max = 1},
	},
	water_damage = 3,
	lava_damage = 4,
	light_damage = 10,
	fear_height = 2,
	animation = {
		speed_normal = 15,
		stand_start = 1,
		stand_end = 15,
		walk_start = 16,
		walk_end = 24,
		punch_start = 16,
		punch_end = 24,
	}
}

mobs:register_mob("spawners_mobs:bunny_evil", bunny_evil_def)

mobs:register_spawn("spawners_mobs:bunny_evil",
	{"default:snow", "default:snowblock", "default:dirt_with_snow"}, 20, 0, 700, 3, 31000, false)

mobs:register_egg("spawners_mobs:bunny_evil", "Evil Bunny", "mobs_bunny_inv.png", 0)

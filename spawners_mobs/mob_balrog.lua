-- modified Sand Monster by PilzAdam with Mummy by BlockMen

local mummy_def = {
	type = "monster",
	passive = false,
	rotate = 180,
	hp_min = 5,
	hp_max = 10,
	pathfinding = true,
	attack_type = "dogfight",
	shoot_interval = 2,
	dogshoot_switch = 1,
	dogshoot_count_max = 10,
	arrow = "spawners_mobs:black_skull",
	shoot_offset = 2,
	reach = 3,
	damage = 10,
	armor = 100,
	collisionbox = {-0.8, -2.1, -0.8, 0.8, 2.6, 0.8},
	visual_size = {x=2, y=2},
	visual = "mesh",
	mesh = "spawners_mobs_balrog.b3d",
	drawtype = "front",
	textures = {
		{"spawners_mobs_balrog.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "spawners_mobs_howl",
		death = "spawners_mobs_howl",
		attack = "spawners_mobs_stone_death",
	},
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 15,
	jump = true,
	floats = 1,
	drops = {
		{name = "default:sandstone", chance = 5, min = 1, max = 2},
		{name = "default:sandstonebrick", chance = 5, min = 1, max = 2},
		{name = "spawners_mobs:deco_stone_eye", chance = 25, min = 1, max = 1},
		{name = "spawners_mobs:deco_stone_men", chance = 25, min = 1, max = 1},
		{name = "spawners_mobs:deco_stone_sun", chance = 25, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fear_height = 4,
	animation = {
		stand_start = 0,
		stand_end = 240,
		walk_start = 240,
		walk_end = 300,
		punch_start = 300,
		punch_end = 380,
		speed_normal = 15,
		speed_run = 15,
	},
}

mobs:register_mob("spawners_mobs:balrog", mummy_def)

mobs:spawn({
	name = "spawners_mobs:balrog",
	nodes = {"default:desert_sand", "default:desert_stone", "default:sand", "default:sandstone", "default:silver_sand"},
	min_light = 0,
	max_light = 20,
	chance = 2000,
	active_object_count = 2,
	day_toggle = false,
})

mobs:register_egg("spawners_mobs:balrog", "balrog", "default_sandstone_brick.png", 1)

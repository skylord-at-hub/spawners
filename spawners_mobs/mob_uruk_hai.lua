-- uruk_hai

local uruk_hai_def = {
	type = "monster",
	docile_by_day = true,
	passive = false,
	hp_min = 25,
	hp_max = 45,
	pathfinding = true,
	attack_type = "dogfight",
	group_attack = true,
	reach = 2,
	damage = 4,
	armor = 100,
	collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
	visual = "mesh",
	mesh = "spawners_mobs_character.b3d",
	drawtype = "front",
	textures = {
		{"spawners_mobs_uruk_hai.png", "spawners_mobs_trans.png","spawners_mobs_galvornsword.png", "spawners_mobs_trans.png"},
		{"spawners_mobs_uruk_hai_1.png", "spawners_mobs_trans.png","spawners_mobs_galvornsword.png", "spawners_mobs_trans.png"},
		{"spawners_mobs_uruk_hai_2.png", "spawners_mobs_trans.png","spawners_mobs_galvornsword.png", "spawners_mobs_trans.png"},
		{"spawners_mobs_uruk_hai_3.png", "spawners_mobs_trans.png","spawners_mobs_galvornsword.png", "spawners_mobs_trans.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "spawners_mobs_barbarian_yell2",
		death = "spawners_mobs_death2",
		attack = "spawners_mobs_slash_attack",
	},
	walk_velocity = 1,
	run_velocity = 3,
	view_range = 15,
	jump = true,
	floats = 1,
	drops = {
		{name = "default:apple", chance = 10, min = 1, max = 2},
		{name = "default:wood", chance = 15, min = 1, max = 2},
		{name = "default:stick", chance = 10, min = 1, max = 2},
		{name = "default:torch", chance = 10, min = 1, max = 2},
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fear_height = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 189,
		punch_end = 198,
	},
}

mobs:register_mob("spawners_mobs:uruk_hai", uruk_hai_def)

-- mobs:spawn({
-- 	name = "spawners_mobs:uruk_hai",
-- 	nodes = {"default:desert_sand", "default:desert_stone", "default:sand", "default:sandstone", "default:silver_sand"},
-- 	min_light = 0,
-- 	max_light = 20,
-- 	chance = 2000,
-- 	active_object_count = 2,
-- 	day_toggle = false,
-- })

mobs:register_egg("spawners_mobs:uruk_hai", "uruk_hai", "spawners_mobs_uruk_hai_egg.png", 0, true)

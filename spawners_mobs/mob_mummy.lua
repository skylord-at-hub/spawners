-- modified Sand Monster by PilzAdam with Mummy by BlockMen

local mummy_def = {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 4,
	hp_min = 25,
	hp_max = 35,
	armor = 100,
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	visual = "mesh",
	mesh = "spawners_mobs_mummy.b3d",
	textures = {
		{"spawners_mobs_mummy.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		random = "spawners_mobs_mummy",
		damage = "spawners_mobs_mummy_hit",
	},
	walk_velocity = .75,
	run_velocity = 1.5,
	view_range = 8,
	jump = true,
	floats = 0,
	drops = {
		{name = "default:sandstone", chance = 1, min = 1, max = 3},
		{name = "default:sandstonebrick", chance = 2, min = 1, max = 2},
		{name = "spawners_mobs:deco_stone_eye", chance = 15, min = 1, max = 1},
		{name = "spawners_mobs:deco_stone_men", chance = 15, min = 1, max = 1},
		{name = "spawners_mobs:deco_stone_sun", chance = 15, min = 1, max = 1},
	},
	water_damage = 4,
	lava_damage = 8,
	light_damage = 0,
	fear_height = 4,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 0,
		stand_end = 39,
		walk_start = 41,
		walk_end = 72,
		run_start = 74,
		run_end = 105,
		punch_start = 74,
		punch_end = 105,
	},
	on_die = function(self, pos)
		minetest.sound_play("spawners_mobs_mummy_death", {
			object = self.object,
			pos = pos,
			max_hear_distance = 10
		})
	end,
}

mobs:register_mob("spawners_mobs:mummy", mummy_def)

mobs:register_spawn("spawners_mobs:mummy", {"default:desert_sand", "default:desert_stone"}, 20, 0, 14000, 2, 31000)

mobs:register_egg("spawners_mobs:mummy", "Mummy Monster", "default_sandstone_brick.png", 1)

-- modified Sand Monster by PilzAdam with Mummy by BlockMen

local mummy_def = {
	type = "monster",
	passive = false,
	pathfinding = true,
	attack_type = "dogshoot",
	shoot_interval = 2,
	dogshoot_switch = 1,
	dogshoot_count_max = 10,
	arrow = "spawners_mobs:black_skull",
	shoot_offset = 2,
	reach = 3,
	damage = 5,
	hp_min = 60,
	hp_max = 120,
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
		shoot_attack = "spawners_mobs_mummy_shoot",
	},
	walk_velocity = .75,
	run_velocity = 1.5,
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
	water_damage = 4,
	lava_damage = 8,
	light_damage = 10,
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
	follow = {"spawners_mobs:deco_stone_eye","spawners_mobs:deco_stone_men","spawners_mobs:deco_stone_sun"},
	on_die = function(self, pos)
		minetest.sound_play("spawners_mobs_mummy_death", {
			object = self.object,
			pos = pos,
			max_hear_distance = 10
		})
	end,
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end

		mobs:capture_mob(self, clicker, 30, 50, 80, false, nil)
	end,
}

mobs:register_mob("spawners_mobs:mummy", mummy_def)

mobs:spawn({
	name = "spawners_mobs:mummy",
	nodes = {"default:desert_sand", "default:desert_stone", "default:sand", "default:sandstone", "default:silver_sand"},
	min_light = 0,
	max_light = 20,
	chance = 2000,
	active_object_count = 2,
	day_toggle = false,
})

mobs:register_egg("spawners_mobs:mummy", "Mummy Monster", "default_sandstone_brick.png", 1)

-- black skull shooting
mobs:register_arrow("spawners_mobs:black_skull", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"spawners_mobs_black_skull.png"},
	velocity = 7,
	tail = 1,
	tail_texture = "spawners_mobs_black_skull.png",
	-- tail_size = 10,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_node = function(self, pos, node)
	end
})

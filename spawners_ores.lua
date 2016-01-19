function spawners.create_ore(ore_name, mod_prefix, size, offset, texture, sound_custom)
	-- dummy inside the spawner
	local dummy_ore_definition = {
		hp_max = 1,
		physical = false,
		collisionbox = {0,0,0,0,0,0},
		visual = "wielditem",
		visual_size = size,
		timer = 0,
		textures={"default:"..ore_name},
		makes_footstep_sound = false,
		automatic_rotate = math.pi * -3,
		m_name = "dummy_ore"
	}

	dummy_ore_definition.on_activate = function(self)
		self.object:setvelocity({x=0, y=0, z=0})
		self.object:setacceleration({x=0, y=0, z=0})
		self.object:set_armor_groups({immortal=1})
	end

	-- remove dummy after dug up the spawner
	dummy_ore_definition.on_step = function(self, dtime)
		self.timer = self.timer + dtime
		local n = minetest.get_node_or_nil(self.object:getpos())
		if self.timer > 2 then
			if n and n.name and n.name ~= "spawners:"..ore_name.."_spawner_active" and n.name ~= "spawners:"..ore_name.."_spawner_waiting" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners:dummy_ore_"..ore_name, dummy_ore_definition)

	-- node spawner active
	minetest.register_node("spawners:"..ore_name.."_spawner_active", {
		description = ore_name.." spawner active",
		paramtype = "light",
		light_source = 4,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_spawner_animated_v2.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 2.0
				},
			}
		},
		is_ground_content = true,
		groups = {cracky=1,level=2,igniter=1,not_in_creative_inventory=1},
		drop = "spawners:"..ore_name.."_spawner",
		on_construct = function(pos)
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners:dummy_ore_"..ore_name)
		end,
	})

	-- node spawner waiting for light - everything is ok but too much light or not enough light
	minetest.register_node("spawners:"..ore_name.."_spawner_waiting", {
		description = ore_name.." spawner waiting",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_spawner_off_animated.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 2.0
				},
			}
		},
		is_ground_content = true,
		groups = {cracky=1,level=2,not_in_creative_inventory=1},
		drop = "spawners:"..ore_name.."_spawner",
		on_construct = function(pos)
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners:dummy_ore_"..ore_name)
		end,
	})

	-- node spawner inactive (default)
	minetest.register_node("spawners:"..ore_name.."_spawner", {
		description = ore_name.." spawner",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2},
		on_construct = function(pos)
			local waiting, found_node = spawners.check_node_status_ores(pos, ore_name, "default:stone")

			if found_node then
				minetest.set_node(pos, {name="spawners:"..ore_name.."_spawner_active"})
			elseif waiting then
				minetest.set_node(pos, {name="spawners:"..ore_name.."_spawner_waiting"})
			else
			end
		end,
	})

	-- abm
	minetest.register_abm({
		nodenames = {"spawners:"..ore_name.."_spawner", "spawners:"..ore_name.."_spawner_active", "spawners:"..ore_name.."_spawner_waiting"},
		interval = 5,
		chance = 5,
		action = function(pos, node, active_object_count, active_object_count_wider)

			local waiting, found_node = spawners.check_node_status_ores(pos, ore_name,  "default:stone")

			print("ore_name: "..ore_name)

			if found_node then
				-- make sure the right node status is shown
				if node.name ~= "spawners:"..ore_name.."_spawner_active" then
					minetest.set_node(pos, {name="spawners:"..ore_name.."_spawner"})
				end

				-- enough place to spawn more ores
				spawners.start_spawning_ores(found_node, "default:"..ore_name, sound_custom)

			else
				-- waiting status
				if node.name ~= "spawners:"..ore_name.."_spawner_waiting" then
					minetest.set_node(pos, {name="spawners:"..ore_name.."_spawner_waiting"})
				end
			end

		end
	})

end

-- default:stone_with_gold
spawners.create_ore("stone_with_gold", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")

spawners.create_ore("stone_with_coal", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")

spawners.create_ore("stone_with_iron", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")

spawners.create_ore("stone_with_copper", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")


-- recipes
minetest.register_craft({
	output = "spawners:stone_with_gold_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:goldblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners:stone_with_coal_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:coalblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners:stone_with_iron_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:steelblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners:stone_with_copper_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:copperblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})


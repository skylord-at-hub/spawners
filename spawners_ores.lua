local max_obj_per_mapblock = tonumber(minetest.setting_get("max_objects_per_block"))
local tmp = {}
function spawners.create_ore(mob_name, mod_prefix, size, offset, texture, night_only, sound_custom)
	-- dummy inside the spawner
	local dummy_ore_definition = {
		hp_max = 1,
		physical = false,
		collisionbox = {0,0,0,0,0,0},
		visual = "wielditem",
		visual_size = size,
		timer = 0,
		textures={"default:stone_with_gold"},
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
			if n and n.name and n.name ~= "spawners:"..mob_name.."_spawner_active" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners:dummy_ore_"..mob_name, dummy_ore_definition)

	-- node spawner active
	minetest.register_node("spawners:"..mob_name.."_spawner_active", {
		description = mob_name.." spawner active",
		paramtype = "light",
		light_source = 4,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_spawner_animated.png",
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
		drop = "spawners:"..mob_name.."_spawner",
		on_construct = function(pos)
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners:dummy_ore_"..mob_name)
		end,
	})

	-- node spawner waiting for light - everything is ok but too much light or not enough light
	minetest.register_node("spawners:spawner_waiting", {
		description = "spawner waiting",
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
		drop = "spawners:"..mob_name.."_spawner",
	})

	-- node spawner inactive (default)
	minetest.register_node("spawners:"..mob_name.."_spawner", {
		description = mob_name.." spawner",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2},
		on_construct = function(pos)
			local random_pos, waiting, found_node = spawners.check_node_status(pos, mob_name, night_only, "default:stone")

			if found_node then
				minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner_active"})
			elseif waiting then
				minetest.set_node(pos, {name="spawners:spawner_waiting"})
			else
			end
		end,
	})

	-- node spawner overheated
	minetest.register_node("spawners:"..mob_name.."_spawner_overheat", {
		description = mob_name.." spawner overheated",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		catch_up = false,
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png^[colorize:#FF000030"},
		is_ground_content = true,
		groups = {cracky=1,level=2,igniter=1,not_in_creative_inventory=1},
		drop = "spawners:"..mob_name.."_spawner",
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(60)
		end,
		on_timer = function(pos, elapsed)
				minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner"})
		end,
	})

	-- abm
	minetest.register_abm({
		nodenames = {"spawners:"..mob_name.."_spawner", "spawners:"..mob_name.."_spawner_active", "spawners:"..mob_name.."_spawner_overheat", "spawners:spawner_waiting"},
		interval = 5,
		chance = 5,
		action = function(pos, node, active_object_count, active_object_count_wider)

			local random_pos, waiting, found_node = spawners.check_node_status(pos, mob_name, night_only,  "default:stone")

			if found_node then
				-- make sure the right node status is shown
				if node.name ~= "spawners:"..mob_name.."_spawner_active" then
					minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner"})
				end

				-- enough place to spawn more ores
				spawners.start_spawning(found_node, 1, "default:stone_with_gold", "", sound_custom)

				-- spawners.start_spawning(random_pos, 1, "spawners:"..mob_name, mod_prefix, sound_custom)

			elseif waiting then
				-- waiting status
				print("waiting status")
				if node.name ~= "spawners:spawner_waiting" then
					minetest.set_node(pos, {name="spawners:spawner_waiting"})
				end
			else
				-- no random_pos found
				print("no random_pos found")
				if minetest.get_node_timer(pos):is_started() then
					minetest.get_node_timer(pos):stop()
				end

				if node.name ~= "spawners:"..mob_name.."_spawner" then
					minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner"})
				end
			end

		end
	})

end

-- create all ore spawners
-- for i, mob_table in ipairs(spawners.mob_tables) do
-- 	if mob_table then

		spawners.create_ore("stone_with_gold", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, false, "tnt_ignite")
-- 	end
-- end
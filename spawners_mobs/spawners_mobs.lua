local max_obj_per_mapblock = tonumber(minetest.setting_get("max_objects_per_block"))

-- 
-- * CREATE ALL SPAWNERS NODES *
-- 

function spawners_mobs.create(mob_name, mod_prefix, size, offset, mesh, texture, night_only, sound_custom)
	
	-- 
	-- DUMMY INSIDE THE SPAWNER
	-- 

	local dummy_definition = {
		hp_max = 1,
		physical = true,
		collisionbox = {0,0,0,0,0,0},
		visual = "mesh",
		visual_size = size,
		mesh = mesh,
		textures = texture,
		makes_footstep_sound = false,
		timer = 0,
		automatic_rotate = math.pi * -3,
		m_name = "dummy"
	}

	dummy_definition.on_activate = function(self)
		self.object:setvelocity({x=0, y=0, z=0})
		self.object:setacceleration({x=0, y=0, z=0})
		self.object:set_armor_groups({immortal=1})
	end

	-- remove dummy after dug up the spawner
	dummy_definition.on_step = function(self, dtime)
		self.timer = self.timer + dtime
		local n = minetest.get_node_or_nil(self.object:getpos())
		if self.timer > 2 then
			if n and n.name and n.name ~= "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners_mobs:dummy_"..mod_prefix.."_"..mob_name, dummy_definition)

	-- 
	-- ACTIVE SPAWNER
	-- 

	minetest.register_node("spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active", {
		description = mod_prefix.."_"..mob_name.." spawner active",
		paramtype = "light",
		light_source = 6	,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {"spawners_mobs_spawner_16.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2,igniter=1,not_in_creative_inventory=1},
		drop = "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner",

		on_construct = function(pos)
			spawners_mobs.meta_set_str("infotext", mod_prefix.." "..mob_name.." spawner (active)", pos)

			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners_mobs:dummy_"..mod_prefix.."_"..mob_name)

			-- add particles
			local id_flame = spawners_mobs.add_flame_effects(pos)
			local id_smoke = spawners_mobs.add_smoke_effects(pos)
			spawners_mobs.meta_set_int("id_flame", id_flame, pos)
			spawners_mobs.meta_set_int("id_smoke", id_smoke, pos)
			minetest.get_node_timer(pos):start(10)
		end,

		on_destruct = function(pos)
			-- delete particles
			local id_flame = spawners_mobs.meta_get_int("id_flame", pos)
			local id_smoke = spawners_mobs.meta_get_int("id_smoke", pos)

			if id_flame and id_smoke and id_flame ~= 0 and id_smoke ~= 0 then
				minetest.delete_particlespawner(id_flame)
				minetest.delete_particlespawner(id_smoke)
			end
		end,

		on_timer = function(pos, elapsed)
			local id_flame = spawners_mobs.meta_get_int("id_flame", pos)
			local id_smoke = spawners_mobs.meta_get_int("id_smoke", pos)
			local player_near = spawners_mobs.check_around_radius(pos)
			
			-- delete particles
			if id_flame and id_smoke and id_flame ~= nil and id_smoke ~= nil and id_flame ~= 0 and id_smoke ~= 0 and player_near == false then
				minetest.delete_particlespawner(id_flame)
				minetest.delete_particlespawner(id_smoke)
				spawners_mobs.meta_set_int("id_flame", 0, pos)
				spawners_mobs.meta_set_int("id_smoke", 0, pos)
			end

			-- add particles
			if player_near == true then
				-- delete particles before adding new ones
				if id_flame and id_smoke and id_flame ~= nil and id_smoke ~= nil then
					minetest.delete_particlespawner(id_flame)
					minetest.delete_particlespawner(id_smoke)
				end

				id_flame = spawners_mobs.add_flame_effects(pos)
				id_smoke = spawners_mobs.add_smoke_effects(pos)
				spawners_mobs.meta_set_int("id_flame", id_flame, pos)
				spawners_mobs.meta_set_int("id_smoke", id_smoke, pos)
			end
			minetest.get_node_timer(pos):start(10)
		end,
	})

	-- 
	-- WAITING SPAWNER
	-- 

	-- waiting for light - everything is ok but too much light or not enough light
	minetest.register_node("spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_waiting", {
		description = mod_prefix.."_"..mob_name.." spawner waiting",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_mobs_spawner_waiting_animated_16.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0
				},
			}
		},
		is_ground_content = true,
		groups = {cracky=1,level=2,not_in_creative_inventory=1},
		drop = "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner",
		on_construct = function(pos)
			spawners_mobs.meta_set_str("infotext", mod_prefix.." "..mob_name.." spawner (waiting)", pos)
		end,
	})

	-- 
	-- INACTIVE SPAWNER (DEFAULT)
	-- 

	minetest.register_node("spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner", {
		description = mod_prefix.."_"..mob_name.." spawner",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		sunlight_propagates = true,
		tiles = {"spawners_mobs_spawner_16.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2},
		stack_max = 1,
		on_construct = function(pos)
			local random_pos, waiting = spawners_mobs.check_node_status(pos, mob_name, night_only)

			spawners_mobs.meta_set_str("infotext", mod_prefix.." "..mob_name.." spawner (inactive)", pos)

			if random_pos then
				-- set active node after dummy was removed
				minetest.after(2, function()
					minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active"})
				end)
			elseif waiting then
				minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_waiting"})
			else
				print("no position and not waiting")
			end
		end,
	})

	-- 
	-- OVERHEATED SPAWNER
	-- 

	minetest.register_node("spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_overheat", {
		description = mod_prefix.."_"..mob_name.." spawner overheated",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {"spawners_mobs_spawner_16.png^[colorize:#FF000030"},
		is_ground_content = true,
		groups = {cracky=1,level=2,igniter=1,not_in_creative_inventory=1},
		drop = "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner",
		on_construct = function(pos)
			spawners_mobs.meta_set_str("infotext", mod_prefix.." "..mob_name.." spawner (overheated)", pos)
			minetest.get_node_timer(pos):start(60)
		end,
		on_timer = function(pos, elapsed)
				minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner"})
		end,
	})

	-- 
	-- * LBM *
	-- 

	-- minetest.register_lbm({
	-- 	name = "spawners_mobs:set_to_active",
	-- 	nodenames = {
	-- 		"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active",
	-- 		"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_overheat",
	-- 		"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_waiting"
	-- 	},
	-- 	run_at_every_load = true,
	-- 	action = function(pos, node)
	-- 		minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner"})
	-- 	end,
	-- })

	-- 
	-- * ABM *
	-- 

	minetest.register_abm({
		nodenames = {
			"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner",
			"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active",
			"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_overheat",
			"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_waiting"
		},
		neighbors = {"air"},
		interval = 20.0,
		chance = 10,
		catch_up = false,
		action = function(pos, node, active_object_count, active_object_count_wider)

			local random_pos, waiting = spawners_mobs.check_node_status(pos, mob_name, night_only)

			-- minetest.log("action", "[Mod][Spawners] checking for: "..mob_name.." at "..minetest.pos_to_string(pos))

			if random_pos then

				-- do not spawn if too many active entities in map block and call cooldown
				if active_object_count_wider > max_obj_per_mapblock then

					-- make sure the right node status is shown
					if node.name ~= "spawners_mobs:"..mob_name.."_spawner_overheat" then
						minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_overheat"})
					end

					-- extend the timeout if still too many entities in map block
					if node.name == "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_overheat" then
						minetest.get_node_timer(pos):stop()
						minetest.get_node_timer(pos):start(60)
					end

					return
				end
				-- make sure the right node status is shown
				if node.name ~= "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active" then
					minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_active"})
				end

				-- enough place to spawn more mobs
				spawners_mobs.start_spawning(random_pos, 1, "spawners_mobs:"..mob_name, mod_prefix, sound_custom)

			elseif waiting then
				-- waiting status
				if node.name ~= "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_waiting" then
					minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner_waiting"})
				end
			else
				-- no random_pos found
				if minetest.get_node_timer(pos):is_started() then
					minetest.get_node_timer(pos):stop()
				end

				if node.name ~= "spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner" then
					minetest.set_node(pos, {name="spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner"})
				end
			end

		end
	})

end

-- 
-- * INIT 'CREATE' FOR ALL SPAWNERS *
-- 

for i, mob_table in ipairs(spawners_mobs.mob_tables) do
	if mob_table then

		spawners_mobs.create(mob_table.name, mob_table.mod_prefix, mob_table.dummy_size, mob_table.dummy_offset, mob_table.dummy_mesh, mob_table.dummy_texture, mob_table.night_only, mob_table.sound_custom)
	end
end
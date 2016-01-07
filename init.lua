local max_obj_per_mapblock = tonumber(minetest.setting_get("max_objects_per_block"))

-- main table
spawners = {}
-- list of mods
spawners.mob_mods = {"mobs", "creatures", "testmod"}
-- table holding all mobs info
spawners.mob_tables = {}

-- check if mods exists and build tables
for k, v in ipairs(spawners.mob_mods) do
	
	local modpath = minetest.get_modpath(v)

	if (modpath) then
		-- MOBS REDO CONFIG
		if v == "mobs" and mobs.mod == "redo" then
			-- list of mobs and their info
			table.insert(spawners.mob_tables, {name="sheep_white", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.52,y=0.52}, dummy_offset=0.2, dummy_mesh="mobs_sheep.b3d", dummy_texture={"mobs_sheep_white.png"}, night_only=false})

			table.insert(spawners.mob_tables, {name="cow", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.3,y=0.3}, dummy_offset=-0.3, dummy_mesh="mobs_cow.x", dummy_texture={"mobs_cow.png"}, night_only=false})

			table.insert(spawners.mob_tables, {name="chicken", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.9,y=0.9}, dummy_offset=0.2, dummy_mesh="mobs_chicken.x", dummy_texture={"mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png"}, night_only=false})

			table.insert(spawners.mob_tables, {name="warthog", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.62,y=0.62}, dummy_offset=-0.3, dummy_mesh="mobs_warthog.x", dummy_texture={"mobs_warthog.png"}, night_only=true})

			table.insert(spawners.mob_tables, {name="bunny", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=1,y=1}, dummy_offset=0.2, dummy_mesh="mobs_bunny.b3d", dummy_texture={"mobs_bunny_brown.png"}, night_only=false})

			table.insert(spawners.mob_tables, {name="kitten", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.32,y=0.32}, dummy_offset=0, dummy_mesh="mobs_kitten.b3d", dummy_texture={"mobs_kitten_ginger.png"}, night_only=false})
		end

	else
		print("[MOD] Spawners: MOD "..v.." not found.")
	end
end

-- start spawning mobs
function spawners.start_spawning(pos, how_many, mob_name, mod_prefix)
	if not pos or not how_many or not mob_name then return end

	local sound_name
	-- remove 'spawners:' from the string
	local mob_name = string.sub(mob_name,10)

	-- fix some namings
	if mob_name == "sheep_white" then
		sound_name = "sheep"
	elseif mob_name == "warthog" then
		sound_name = "pig"
	else
		sound_name = mob_name
	end

	for i=1,how_many do
		local obj = minetest.add_entity(pos, mod_prefix..":"..mob_name)

		if obj then

			if sound_name then
				minetest.sound_play(mod_prefix.."_"..sound_name, {
					pos = pos,
					max_hear_distance = 32,
					gain = 10,
				})
			end

		end

	end
end

function spawners.check_around_radius(pos)
	local player_near = false
	local radius = 21

	for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if obj:is_player() then
			player_near = true
		end
	end

	return player_near
end

function spawners.check_node_status(pos, mob, night_only)
	local player_near = spawners.check_around_radius(pos)
	local random_pos = false

	if player_near then
		local min_node_light = 10
		local tod = minetest.get_timeofday() * 24000
		local node_light = minetest.get_node_light(pos)
		local spawn_positions = {}
		local front = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
		local right = minetest.get_node({x=pos.x, y=pos.y, z=pos.z+1})
		local back = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
		local left = minetest.get_node({x=pos.x, y=pos.y, z=pos.z-1})
		local top = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		local bottom = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})

		if not node_light then return false end
		
		-- make sure that at least one side of the spawner is open
		if front.name == "air" then
			table.insert(spawn_positions, {x=pos.x+1.5, y=pos.y, z=pos.z})
		end
		if right.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y, z=pos.z+1.5})
		end
		if back.name == "air" then
			table.insert(spawn_positions, {x=pos.x-1.5, y=pos.y, z=pos.z})
		end
		if left.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y, z=pos.z-1.5})
		end
		if top.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y+1.5, z=pos.z})
		end
		if bottom.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y-1.5, z=pos.z})
		end

		-- spawner is closed from all sides
		if not (front or right or back or left or top or bottom) then return false end

		-- pick random from the open sides
		local pick_random = math.random(1,#spawn_positions)
		
		for k, v in pairs (spawn_positions) do
			if k == pick_random then
				random_pos = v
			end
		end
		
		if not random_pos then return false end

		-- check the node above and below the found air node
		local node_above = minetest.get_node({x=random_pos.x, y=random_pos.y+1, z=random_pos.z}).name
		local node_below = minetest.get_node({x=random_pos.x, y=random_pos.y-1, z=random_pos.z}).name
		
		if not (node_above == "air" or node_below == "air") then return false end

		-- spawn only at day
		if not night_only and node_light < min_node_light then
			return false, true
		end

		-- spawn only at night
		if night_only then
			if not (19359 > tod and tod > 5200) or node_light < min_node_light then
				return random_pos
			else
				return false, true
			end
		end

		return random_pos
	else
		return false
	end
end

function spawners.create(mob_name, mod_prefix, size, offset, mesh, texture, night_only)
	-- dummy inside the spawner
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
			if n and n.name and n.name ~= "spawners:"..mod_prefix.."_"..mob_name.."_spawner_active" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners:dummy_"..mob_name, dummy_definition)

	-- node spawner active
	minetest.register_node("spawners:"..mod_prefix.."_"..mob_name.."_spawner_active", {
		description = mod_prefix.."_"..mob_name.." spawner active",
		paramtype = "light",
		light_source = 4,
		drawtype = "allfaces",
		walkable = true,
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
		drop = "spawners:"..mod_prefix.."_"..mob_name.."_spawner",
		on_construct = function(pos)
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners:dummy_"..mob_name)
		end,
	})

	-- node spawner waiting for light - everything is ok but too much light or not enough light
	minetest.register_node("spawners:"..mod_prefix.."_"..mob_name.."_spawner_waiting", {
		description = mod_prefix.."_"..mob_name.." spawner waiting",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
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
		drop = "spawners:"..mod_prefix.."_"..mob_name.."_spawner",
	})

	-- node spawner inactive (default)
	minetest.register_node("spawners:"..mod_prefix.."_"..mob_name.."_spawner", {
		description = mod_prefix.."_"..mob_name.." spawner",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2},
		on_construct = function(pos)
			local random_pos, waiting = spawners.check_node_status(pos, mob_name, night_only)

			if random_pos then
				minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner_active"})
			elseif waiting then
				minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner_waiting"})
			else
			end
		end,
	})

	-- node spawner overheated
	minetest.register_node("spawners:"..mod_prefix.."_"..mob_name.."_spawner_overheat", {
		description = mod_prefix.."_"..mob_name.." spawner overheated",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png^[colorize:#FF000030"},
		is_ground_content = true,
		groups = {cracky=1,level=2,igniter=1,not_in_creative_inventory=1},
		drop = "spawners:"..mod_prefix.."_"..mob_name.."_spawner",
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(60)
		end,
		on_timer = function(pos, elapsed)
				minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner"})
		end,
	})

	-- abm
	minetest.register_abm({
		nodenames = {"spawners:"..mod_prefix.."_"..mob_name.."_spawner", "spawners:"..mod_prefix.."_"..mob_name.."_spawner_active", "spawners:"..mod_prefix.."_"..mob_name.."_spawner_overheat", "spawners:"..mod_prefix.."_"..mob_name.."_spawner_waiting"},
		neighbors = {"air"},
		interval = 2.0,
		chance = 20,
		action = function(pos, node, active_object_count, active_object_count_wider)
			

			local random_pos, waiting = spawners.check_node_status(pos, mob_name, night_only)

			if random_pos then

				-- do not spawn if too many active entities in map block and call cooldown
				if active_object_count_wider > max_obj_per_mapblock then

					-- make sure the right node status is shown
					if node.name ~= "spawners:"..mob_name.."_spawner_overheat" then
						minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner_overheat"})
					end

					-- extend the timeout if still too many entities in map block
					if node.name == "spawners:"..mod_prefix.."_"..mob_name.."_spawner_overheat" then
						minetest.get_node_timer(pos):stop()
						minetest.get_node_timer(pos):start(60)
					end

					return
				end

				-- make sure the right node status is shown
				if node.name ~= "spawners:"..mod_prefix.."_"..mob_name.."_spawner_active" then
					minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner_active"})
				end

				-- enough place to spawn more mobs
				spawners.start_spawning(random_pos, 1, "spawners:"..mob_name, mod_prefix)

			elseif waiting then
				-- waiting status
				if node.name ~= "spawners:"..mod_prefix.."_"..mob_name.."_spawner_spawner_waiting" then
					minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner_waiting"})
				end
			else
				-- no random_pos found
				if minetest.get_node_timer(pos):is_started() then
					minetest.get_node_timer(pos):stop()
				end

				if node.name ~= "spawners:"..mod_prefix.."_"..mob_name.."_spawner" then
					minetest.set_node(pos, {name="spawners:"..mod_prefix.."_"..mob_name.."_spawner"})
				end
			end

		end
	})

end

-- create all spawners and crafting recipes
for i, mob_table in ipairs(spawners.mob_tables) do
	if mob_table then

		local mod_prefix
		if mob_table.mod_prefix_custom == "" then mod_prefix = mob_table.mod_prefix_default end

		-- spawners
		spawners.create(mob_table.name, mod_prefix, mob_table.dummy_size, mob_table.dummy_offset, mob_table.dummy_mesh, mob_table.dummy_texture, mob_table.night_only)
		-- recipes
		minetest.register_craft({
			output = "spawners:"..mod_prefix.."_"..mob_table.name.."_spawner",
			recipe = {
				{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
				{"xpanes:bar", mod_prefix..":"..mob_table.name, "xpanes:bar"},
				{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
			}
		})
	end
end

print ("[MOD] Spawners 0.1 Loaded.")
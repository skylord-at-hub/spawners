local max_obj_per_mapblock = tonumber(minetest.setting_get("max_objects_per_block"))

-- main table
spawners = {}
-- list of mods
spawners.mob_mods = {"mobs", "testmod"}
-- table holding all mobs info
spawners.mob_tables = {}

-- check if mods exists and build tables
for k, v in ipairs(spawners.mob_mods) do
	
	local modpath = minetest.get_modpath(v)

	if (modpath) then
		-- list of mobs and their info
		table.insert(spawners.mob_tables, {name="sheep_white", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.52,y=0.52}, dummy_offset=0.2, dummy_mesh="mobs_sheep.b3d", dummy_texture={"mobs_sheep_white.png"}, night_only=false})

		table.insert(spawners.mob_tables, {name="cow", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.3,y=0.3}, dummy_offset=-0.3, dummy_mesh="mobs_cow.x", dummy_texture={"mobs_cow.png"}, night_only=false})

		table.insert(spawners.mob_tables, {name="chicken", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.9,y=0.9}, dummy_offset=0.2, dummy_mesh="mobs_chicken.x", dummy_texture={"mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png", "mobs_chicken.png"}, night_only=false})

		table.insert(spawners.mob_tables, {name="warthog", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.62,y=0.62}, dummy_offset=-0.3, dummy_mesh="mobs_warthog.x", dummy_texture={"mobs_warthog.png"}, night_only=true})

		table.insert(spawners.mob_tables, {name="bunny", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=1,y=1}, dummy_offset=0.2, dummy_mesh="mobs_bunny.b3d", dummy_texture={"mobs_bunny_brown.png"}, night_only=false})

		table.insert(spawners.mob_tables, {name="kitten", mod_prefix_default=v, mod_prefix_custom="", dummy_size={x=0.32,y=0.32}, dummy_offset=0, dummy_mesh="mobs_kitten.b3d", dummy_texture={"mobs_kitten_ginger.png"}, night_only=false})
	else
		print("[Spawners] MOD: "..v.." not found.")
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

		-- local x = 1/math.random(1,3)
		-- local z = 1/math.random(1,3)
		-- local p = {x=pos.x+x,y=pos.y,z=pos.z+z}
	
		local obj = minetest.add_entity(pos, mod_prefix..":"..mob_name)

		if obj then

			if sound_name then
				minetest.sound_play(mod_prefix.."_"..sound_name, {
					pos = pos,
					max_hear_distance = 32,
					gain = 10,
				})
			end

			minetest.log("action", "Spawners: spawned "..mob_name.." at ("..pos.x..","..pos.y..","..pos.z..")")
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

function check_node_status(pos, mob, night_only)
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

		if not node_light then return end
		
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
		if not (front or right or back or left or top or bottom) then
			minetest.log("action","spawner is closed")
			return false
		end

		local pick_random = math.random(1,#spawn_positions)

		-- pick random from the open sides
		for k, v in pairs (spawn_positions) do
			if k == pick_random then
				random_pos = v
			end
		end 
		
		if not random_pos then return end

		print("#spawn_positions: "..#spawn_positions)
		print("pick_random: "..pick_random)
		print("node_light: "..node_light)
		-- print("node_pos"..minetest.pos_to_string(pos))
		-- print("random_pos"..minetest.pos_to_string(random_pos))
		
		-- check the node above the found air node
		local node_above = minetest.get_node({x=random_pos.x, y=random_pos.y+1, z=random_pos.z}).name
		local node_below = minetest.get_node({x=random_pos.x, y=random_pos.y-1, z=random_pos.z}).name
		
		print("node_above: "..node_above)
		print("node_below: "..node_below)

		if not (node_above == "air" or node_below == "air") then
			print("node below or above is not air")
			return false
		end

		if not night_only and node_light < min_node_light then
			print("not enough light")
			return false
		end

		-- At 0 time of day (tod) the day begins; it is midnight and the moon is exactly at the zenith (1).
		-- At 4500 tod, the first sun rays emit from the horizon, it gets brighter (2).
		-- At 4750 tod, the sun rises and it gets brighter (3).
		-- At 5001 tod, it gets brighter again (4).
		-- At 5200 tod, the sun becomes fully visible (4).
		-- At 5250 tod, it gets brighter again (5).
		-- At 5500 tod, it gets brighter again (6).
		-- At 5751 tod, maximum brightness is reached (7).
		-- At 12000 tod is midday; the sun is exactly at the zenith (7).
		-- At 18250 tod, the day is going to end, it gets a bit darker (6).
		-- At 18502 tod, it gets a bit darker again (5).
		-- At 18600 tod, the sun begins to set (5).
		-- At 18752 tod, it gets a bit darker yet again (4).
		-- At 19000 tod, the sky gets even darker (3).
		-- At 19252 tod, the sun is almost gone and the sky gets even darker (2).
		-- At 19359 tod, the sun square is gone and the last sun rays emit from the horizon (2).
		-- At 19500 tod, the sun rays stop from being visible (2).
		-- At 19502 tod, the sky has the lowest brightness (1).
		-- At 24000 tod, the day ends and the next one starts; it is midnight again (1).

		if night_only then
			print("tod: "..tod)
			if not (19359 > tod and tod > 5200) or node_light < min_node_light then
				print("it's night")
				if random_pos then
					return random_pos
				else
					return false
				end
			else
				return false
			end
		end

		return random_pos
	else
		return false
	end
end

function spawners.create(mob_name, mod_prefix, size, offset, mesh, texture, night_only)
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
			if n and n.name and n.name ~= "spawners:"..mob_name.."_spawner_active" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners:dummy_"..mob_name, dummy_definition)

	-- node spawner active
	minetest.register_node("spawners:"..mob_name.."_spawner_active", {
		description = mob_name.." spawner active",
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
		drop = "spawners:"..mob_name.."_spawner",
		on_construct = function(pos)
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners:dummy_"..mob_name)
		end,
	})

	-- node spawner inactive
	minetest.register_node("spawners:"..mob_name.."_spawner", {
		description = mob_name.." spawner",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2},
		on_construct = function(pos)
			local random_pos = check_node_status(pos, mob_name, night_only)

			if random_pos then
				minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner_active"})
			else
				minetest.log("action","no random_pos found")
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
			minetest.log("action", "============= timer elapsed: "..elapsed)
				minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner"})
		end,
	})

	-- abm
	minetest.register_abm({
		nodenames = {"spawners:"..mob_name.."_spawner", "spawners:"..mob_name.."_spawner_active", "spawners:"..mob_name.."_spawner_overheat"},
		neighbors = {"air"},
		interval = 2.0,
		chance = 20,
		action = function(pos, node, active_object_count, active_object_count_wider)
			
			minetest.log("action", "active_object_count: "..active_object_count)
			minetest.log("action", "active_object_count_wider: "..active_object_count_wider)

			local random_pos = check_node_status(pos, mob_name, night_only)

			if random_pos then
				-- random_pos found

				-- do not spawn if too many active entities in map block
				-- call cooldown
				if active_object_count_wider > max_obj_per_mapblock then
					minetest.log("action", "************** too many mobs in area")

					if node.name ~= "spawners:"..mob_name.."_spawner_overheat" then
						minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner_overheat"})
					end

					-- extend the timeout if still too many entities in map block
					if node.name == "spawners:"..mob_name.."_spawner_overheat" then
						minetest.log("action", "++++++++++++++ extending timeout")
						minetest.get_node_timer(pos):stop()
						minetest.get_node_timer(pos):start(60)
					end

					return
				end

				if node.name ~= "spawners:"..mob_name.."_spawner_active" then
					minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner_active"})
				end

				spawners.start_spawning(random_pos, 1, "spawners:"..mob_name, mod_prefix)
			else
				-- no random_pos found
				if minetest.get_node_timer(pos):is_started() then
					minetest.get_node_timer(pos):stop()
					minetest.log("action", "timer stopped")
				end

				if node.name ~= "spawners:"..mob_name.."_spawner" then
					minetest.set_node(pos, {name="spawners:"..mob_name.."_spawner"})
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
			output = "spawners:"..mob_table.name.."_spawner",
			recipe = {
				{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
				{"xpanes:bar", "spawners:"..mob_table.name, "xpanes:bar"},
				{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
			}
		})
	end
end

print ("[MOD] Spawners loaded")
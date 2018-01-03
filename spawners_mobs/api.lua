-- main tables
spawners_mobs = {}
spawners_mobs.mob_tables = {}

-- check if mods exists and build tables
for k, mob_mod in ipairs(ENABLED_MODS) do
	local modpath = minetest.get_modpath(mob_mod)
	-- list of mobs and their info
	if (modpath) then
		for j, mob in ipairs(MOBS_PROPS[mob_mod]) do
			local mob_egg = nil

			-- disabled extra check for mobs redo due to incompatibility with Lua 5.1, this method is available from Lua 5.2
			-- if mob_mod == "mobs" and not (mobs.mod == "redo") then goto continue end

			table.insert(spawners_mobs.mob_tables,
				{
					name = mob.name,
					mod_prefix = mob_mod,
					egg_name_custom = mob.egg_name_custom,
					dummy_size = mob.dummy_size,
					dummy_offset = mob.dummy_offset,
					dummy_mesh = mob.dummy_mesh,
					dummy_texture = mob.dummy_texture,
					night_only = mob.night_only,
					sound_custom = mob.sound_custom
				}
			)
			-- use custom egg or create a default egg
			if mob.egg_name_custom ~= "" then 
				mob_egg = mob.egg_name_custom
			else
				mob_egg = mob_mod..":"..mob.name
			end
			
			-- recipes
			minetest.register_craft({
				output = "spawners_mobs:"..mob_mod.."_"..mob.name.."_spawner",
				recipe = {
					{"default:diamondblock", "fire:flint_and_steel", "default:diamondblock"},
					{"xpanes:bar_flat", mob_egg, "xpanes:bar_flat"},
					{"default:diamondblock", "xpanes:bar_flat", "default:diamondblock"},
				}
			})

			-- ::continue::
		end
	end
end

function spawners_mobs.meta_get_int(key, pos)
	local meta = minetest.get_meta(pos)
	return meta:get_int(key)
end

function spawners_mobs.meta_set_int(key, value, pos)
	local meta = minetest.get_meta(pos)
	meta:set_int(key, value)
end

function spawners_mobs.meta_set_str(key, value, pos)
	local meta = minetest.get_meta(pos)
	meta:set_string(key, value)
end

-- particles
function spawners_mobs.cloud_booom(pos)
	minetest.add_particlespawner({
		amount = 5,
		time = 2,
		minpos = vector.subtract({x=pos.x-0.3, y=pos.y, z=pos.z-0.3}, 0.3),
		maxpos = vector.add({x=pos.x+0.3, y=pos.y, z=pos.z+0.3}, 0.3),
		minvel = {x=0.1, y=0.1, z=0.1},
		maxvel = {x=0.2,  y=0.2,  z=0.2},
		minacc = vector.new({x=-0.1, y=0.3, z=-0.1}),
		maxacc = vector.new({x=0.1,  y=0.6,  z=0.1}),
		minexptime = 2,
		maxexptime = 3,
		minsize = 4,
		maxsize = 12,
		texture = "spawners_mobs_smoke_particle_2.png^[transform"..math.random(0,3),
	})
end

function spawners_mobs.add_flame_effects(pos)
	local id = minetest.add_particlespawner({
		amount = 6,
		time = 0,
		minpos = vector.subtract({x=pos.x-0.001, y=pos.y-0.001, z=pos.z-0.001}, 0.5),
		maxpos = vector.add({x=pos.x+0.001, y=pos.y+0.001, z=pos.z+0.001}, 0.5),
		minvel = {x=-0.1, y=-0.1, z=-0.1},
		maxvel = {x=0.1,  y=0.1,  z=0.1},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 5,
		minsize = .5,
		maxsize = 2.5,
		texture = "spawners_mobs_flame_particle_2.png",
	})

	return id
end

function spawners_mobs.add_smoke_effects(pos)
	local id = minetest.add_particlespawner({
		amount = 1,
		time = 0,
		minpos = vector.subtract({x=pos.x-0.001, y=pos.y-0.001, z=pos.z-0.001}, 0.5),
		maxpos = vector.add({x=pos.x+0.001, y=pos.y+0.001, z=pos.z+0.001}, 0.5),
		minvel = {x=-0.5, y=0.5, z=-0.5},
		maxvel = {x=0.5,  y=1.5,  z=0.5},
		minacc = vector.new({x=-0.1, y=0.1, z=-0.1}),
		maxacc = vector.new({x=0.1,  y=0.3,  z=0.1}),
		minexptime = .5,
		maxexptime = 2,
		minsize = .5,
		maxsize = 2,
		texture = "spawners_mobs_smoke_particle.png^[transform"..math.random(0,3),
	})

	return id
end

-- start spawning mobs
function spawners_mobs.start_spawning(random_pos, mob_name, mod_prefix, sound_custom)
	if not (random_pos or how_many or mob_name) then return end

	local sound_name = mod_prefix.."_"..mob_name
	-- use custom sounds
	if sound_custom ~= "" then 
		sound_name = sound_custom
	end

	-- remove 'spawners_mobs:' from the string
	print("#2 mod_prefix: "..mod_prefix)
	print("#2 mob_name: "..mob_name)
	-- local mob_name = string.sub(mob_name,15)

	-- use random colors for sheeps
	if mob_name == "sheep_white" then
		local sheep_colors = {"black", "blue", "brown", "cyan", "dark_green", "dark_grey", "green", "grey", "magenta", "orange", "pink", "red", "violet", "white", "yellow"}
		mob_name = "sheep_"..sheep_colors[math.random(#sheep_colors)]
	end

	local how_many = math.random(2)
	print("how_many: ", how_many)

	for i = 1, how_many do
		-- spawn a bit more above the block - prevent spawning inside the block
		random_pos.y = random_pos.y + 0.5
		
		spawners_mobs.cloud_booom(random_pos)

		minetest.after(1, function()
			local obj = minetest.add_entity(random_pos, mod_prefix..":"..mob_name)

			if obj then
				if sound_name then
					minetest.sound_play(sound_name, {
						pos = random_pos,
						max_hear_distance = 10,
						gain = 0.3
					})
				end
			end
		end)
	end
end

function spawners_mobs.check_around_radius(pos, mob)
	local player_near = false
	local radius = 21
	local mobs = {}

	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do

		local luae = obj:get_luaentity()

		-- check for number of mobs near by
		if luae ~= nil and luae.name ~= nil and mob ~= nil then
			local mob_name = string.split(luae.name, ":")
			mob_name = mob_name[2]

			if mob_name == mob then
				table.insert(mobs, mob)
			end

			if #mobs >= 8 then
				player_near = false
				return player_near
			end
		end

		-- check for player near by
		if obj:is_player() then
			player_near = true
		end
	end

	return player_near
end

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	-- is area protected against name?
	if not protector.can_dig(protector.radius, pos, name, false, 1) then
		return true
	end

	-- otherwise can dig or place
	return old_is_protected(pos, name)
end

function spawners_mobs.check_node_status(pos, mob, night_only)

	-- re-factor

	local posmin = { x = pos.x - 4, y = pos.y - 1, z = pos.z - 4 }
	local posmax = { x = pos.x + 4, y = pos.y + 1, z = pos.z + 4 }
	local player_near = false
	local entities_near = 0
	local entities_max = 6
	local node_light_min = 13
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner") or ""
	local mod_prefix = meta:get_string("mod_prefix") or false
	local mob_name = meta:get_string("mob_name") or false
	local sound_custom = meta:get_string("sound_custom") or ""

	print("#1 mod_prefix: "..mod_prefix)
	print("#1 mob_name: "..mob_name)

	if not (mod_prefix or mob_name) then return end

	-- check spawner light
	local node_light = minetest.get_node_light(pos)

	if (not node_light or node_light < node_light_min) and night_only then
		-- too dark - spawn only hostile mobs
		print("too dark - spawn only hostile mobs")
	elseif node_light >= node_light_min and not night_only then
		-- enough light - spawn only friendly mobs
		print("enough light - spawn only friendly mobs")
	else
		-- too dark for friendly mob to spawn or too light for hostile mob to spawn
		print("too dark for friendly mob to spawn or too light for hostile mob to spawn")
		-- tick short
		return
	end

	-- positions where mobs can spawn
	local spawn_area_pos = minetest.find_nodes_in_area(posmin, posmax, "air")
	-- get random spawn position from spawn area
	local random_idx = math.random(#spawn_area_pos)
	local random_pos = spawn_area_pos[random_idx]
	local random_pos_above = minetest.get_node({ x = random_pos.x, y = random_pos.y + 1, z = random_pos.z }).name
	
	-- check if there is enough place to spawn mob
	if random_pos_above ~= "air" then
		-- tick short
		print("no random position found")
		return
	end

	-- don't do anything and try again later when random position is protected
	if minetest.is_protected(random_pos, owner) then
		print("random pos is protected")
		minetest.record_protection_violation(random_pos, owner)
		-- tick short
		return
	end

	-- area where player and entity count will be detected
	local activation_area = minetest.get_objects_inside_radius(pos, 16)

	for k, object in ipairs(activation_area) do
		-- find player inside activation area
		if object:is_player() then
			player_near = true
			-- print("found player: "..object:get_player_name())
		end

		-- find entities inside activation area
		if not object:is_player() and
			 object:get_luaentity() and
			 object:get_luaentity().name ~= "__builtin:item" then
			local tmp_mob_name = string.split(object:get_luaentity().name, ":")[2]

			-- sheeps have colors in names
			if string.find(tmp_mob_name, "sheep") and string.find(mob, "sheep") then
				-- print("found entity: "..tmp_mob_name)
				entities_near = entities_near + 1
			
			elseif tmp_mob_name == mob then
				-- print("found entity: "..tmp_mob_name)
				entities_near = entities_near + 1
			end
		end

		-- stop looping when met all conditions
		if entities_near >= entities_max and player_near then
			-- print("max entities reached "..entities_max.." and player_near found, breaking..")
			break
		end
	end

	-- don't do anything and try again later when player not near or max entities reached
	if entities_near >= entities_max or not player_near then
		-- tick short
		print("max entities reached "..entities_max.." or player not near")
		return
	end

	-- start spawning
	-- minetest.set_node(random_pos, { name = "default:apple" })
	spawners_mobs.start_spawning(random_pos, mob_name, mod_prefix, sound_custom)

	-- /re-factor

	-- if player_near then
	-- 	local random_pos = false
	-- 	local min_node_light = 10
	-- 	local tod = minetest.get_timeofday() * 24000
	-- 	local node_light = minetest.get_node_light(pos)

	-- 	if not node_light then
	-- 		return false
	-- 	end

	-- 	local spawn_positions = {}
	-- 	local right = minetest.get_node_or_nil({x=pos.x+1, y=pos.y, z=pos.z})
	-- 	local front = minetest.get_node_or_nil({x=pos.x, y=pos.y, z=pos.z+1})
	-- 	local left = minetest.get_node_or_nil({x=pos.x-1, y=pos.y, z=pos.z})
	-- 	local back = minetest.get_node_or_nil({x=pos.x, y=pos.y, z=pos.z-1})
	-- 	local top = minetest.get_node_or_nil({x=pos.x, y=pos.y+1, z=pos.z})
	-- 	local bottom = minetest.get_node_or_nil({x=pos.x, y=pos.y-1, z=pos.z})

	-- 	-- make sure that at least one side of the spawner is open
	-- 	if right ~= nil and right.name == "air" then
	-- 		table.insert(spawn_positions, {x=pos.x+1.5, y=pos.y, z=pos.z})
	-- 	end
	-- 	if front ~= nil and front.name == "air" then
	-- 		table.insert(spawn_positions, {x=pos.x, y=pos.y, z=pos.z+1.5})
	-- 	end
	-- 	if left ~= nil and left.name == "air" then
	-- 		table.insert(spawn_positions, {x=pos.x-1.5, y=pos.y, z=pos.z})
	-- 	end
	-- 	if back ~= nil and back.name == "air" then
	-- 		table.insert(spawn_positions, {x=pos.x, y=pos.y, z=pos.z-1.5})
	-- 	end
	-- 	if top ~= nil and top.name == "air" then
	-- 		table.insert(spawn_positions, {x=pos.x, y=pos.y+1.5, z=pos.z})
	-- 	end
	-- 	if bottom ~= nil and bottom.name == "air" then
	-- 		table.insert(spawn_positions, {x=pos.x, y=pos.y-1.5, z=pos.z})
	-- 	end

	-- 	if #spawn_positions < 1 then
	-- 		-- spawner is closed from all sides
	-- 		return false
	-- 	else
	-- 		-- pick random from the open sides
	-- 		local pick_random

	-- 		if #spawn_positions == 1 then
	-- 			pick_random = #spawn_positions
	-- 		else
	-- 			pick_random = math.random(#spawn_positions)
	-- 		end
			
	-- 		for k, v in pairs (spawn_positions) do
	-- 			if k == pick_random then
	-- 				random_pos = v
	-- 			end
	-- 		end
	-- 	end

	-- 	-- check the node above and below the found air node
	-- 	local node_above = minetest.get_node({x=random_pos.x, y=random_pos.y+1, z=random_pos.z}).name
	-- 	local node_below = minetest.get_node({x=random_pos.x, y=random_pos.y-1, z=random_pos.z}).name
		
	-- 	if not (node_above == "air" or node_below == "air") then
	-- 		return false
	-- 	end

	-- 	if night_only ~= "disable" then
	-- 		-- spawn only at day
	-- 		if not night_only and node_light < min_node_light then
	-- 			return false, true
	-- 		end

	-- 		-- spawn only at night
	-- 		if night_only then
	-- 			if not (19359 > tod and tod > 5200) or node_light < min_node_light then
	-- 				return random_pos
	-- 			else
	-- 				return false, true
	-- 			end
	-- 		end
	-- 	end
	-- 	-- random_pos, waiting
	-- 	return random_pos, false
	-- else
	-- 	-- random_pos, waiting
	-- 	return false, true
	-- end
end

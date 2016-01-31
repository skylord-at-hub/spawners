-- main tables
spawners = {}
spawners.mob_tables = {}

-- check if mods exists and build tables
for k, mob_mod in ipairs(ENABLED_MODS) do
	local modpath = minetest.get_modpath(mob_mod)
	-- list of mobs and their info
	if (modpath) then
		for j, mob in ipairs(MOBS_PROPS[mob_mod]) do
			local mob_egg = nil

			if mob_mod == "mobs" and not (mobs.mod == "redo") then goto continue end

			table.insert(spawners.mob_tables, {name=mob.name, mod_prefix=mob_mod, egg_name_custom=mob.egg_name_custom, dummy_size=mob.dummy_size, dummy_offset=mob.dummy_offset, dummy_mesh=mob.dummy_mesh, dummy_texture=mob.dummy_texture, night_only=mob.night_only, sound_custom=mob.sound_custom})

			-- use custom egg or create a default egg
			if mob.egg_name_custom ~= "" then 
				mob_egg = mob.egg_name_custom
			else
				mob_egg = mob_mod..":"..mob.name
			end
			
			-- recipes
			minetest.register_craft({
				output = "spawners:"..mob_mod.."_"..mob.name.."_spawner",
				recipe = {
					{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
					{"xpanes:bar", mob_egg, "xpanes:bar"},
					{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
				}
			})

			::continue::
		end
	else
		print("[MOD] Spawners: MOD "..mob_mod.." not found.")
	end
end

-- start spawning mobs
function spawners.start_spawning(pos, how_many, mob_name, mod_prefix, sound_custom)
	if not pos or not how_many or not mob_name then return end

	local sound_name
	-- remove 'spawners:' from the string
	local mob_name = string.sub(mob_name,10)

	-- use custom sounds
	if sound_custom ~= "" then 
		sound_name = sound_custom
	else
		sound_name = mod_prefix.."_"..mob_name
	end

	for i=1,how_many do
		local obj = minetest.add_entity(pos, mod_prefix..":"..mob_name)

		if obj then
			if sound_name then
				minetest.sound_play(sound_name, {
					pos = pos,
					max_hear_distance = 32,
					gain = 10,
				})
			end
		end
	end
end

function spawners.add_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 32,
		time = 2,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-0.5, y=-10, z=-0.5},
		maxvel = {x=0.5,  y=10,  z=0.5},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = .5,
		maxexptime = 2,
		minsize = .5,
		maxsize = 8,
		texture = "spawners_smoke_particle.png",
	})
end

-- start spawning ores
function spawners.start_spawning_ores(pos, ore_name, sound_custom, spawners_pos)
	if not pos or not ore_name then return end

	local sound_name
	local player_near = false

	-- use custom sounds
	if sound_custom ~= "" then 
		sound_name = sound_custom
	else
		sound_name = false
	end

	local how_many = math.random(0,2)
	how_many = how_many+1
	print("how_many: "..how_many)

	for i=1, how_many do
		print("i: "..i)
		
		if i > 1 then
			player_near, pos = spawners.check_around_radius_ores(pos, "default:stone")

			minetest.sound_play(sound_name, {
				pos = pos,
				max_hear_distance = 32,
				gain = 10,
			})

			minetest.set_node(pos, {name=ore_name})
			spawners.add_effects(pos, 1)
			print("#2 spawing "..ore_name.." at "..minetest.pos_to_string(pos))
		else
			minetest.sound_play(sound_name, {
				pos = pos,
				max_hear_distance = 32,
				gain = 10,
			})

			minetest.set_node(pos, {name=ore_name})
			spawners.add_effects(pos, 1)
			print("#1 spawing "..ore_name.." at "..minetest.pos_to_string(pos))
		end
	end
	
end

function spawners.check_around_radius(pos)
	local player_near = false
	local found_node = false
	local radius = 21
	local node_ore_pos = nil

	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if obj:is_player() then
			player_near = true
		end
	end

	return player_near
end

function spawners.check_around_radius_ores(pos, check_node)
	local player_near = spawners.check_around_radius(pos);
	local found_node = false
	local node_ore_pos = nil
	print("check_node: "..check_node)
	if check_node then
		
		node_ore_pos = minetest.find_node_near(pos, 3, {check_node})
		
		if node_ore_pos then
			found_node = node_ore_pos
			print("found stone: "..minetest.pos_to_string(found_node));
		end
	end

	return player_near, found_node
end

function spawners.check_node_status(pos, mob, night_only)
		local player_near = spawners.check_around_radius(pos)

	if player_near then
		local random_pos = false
		local min_node_light = 10
		local tod = minetest.get_timeofday() * 24000
		local node_light = minetest.get_node_light(pos)

		if not node_light then
			return false
		end

		local spawn_positions = {}
		local right = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
		local front = minetest.get_node({x=pos.x, y=pos.y, z=pos.z+1})
		local left = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
		local back = minetest.get_node({x=pos.x, y=pos.y, z=pos.z-1})
		local top = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		local bottom = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})

		-- make sure that at least one side of the spawner is open
		if right.name == "air" then
			table.insert(spawn_positions, {x=pos.x+1.5, y=pos.y, z=pos.z})
		end
		if front.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y, z=pos.z+1.5})
		end
		if left.name == "air" then
			table.insert(spawn_positions, {x=pos.x-1.5, y=pos.y, z=pos.z})
		end
		if back.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y, z=pos.z-1.5})
		end
		if top.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y+1.5, z=pos.z})
		end
		if bottom.name == "air" then
			table.insert(spawn_positions, {x=pos.x, y=pos.y-1.5, z=pos.z})
		end

		if #spawn_positions < 1 then
			-- spawner is cloed from all sides
			return false
		else
			-- pick random from the open sides
			local pick_random

			if #spawn_positions == 1 then
				pick_random = #spawn_positions
			else
				pick_random = math.random(1,#spawn_positions)
			end
			
			for k, v in pairs (spawn_positions) do
				if k == pick_random then
					random_pos = v
				end
			end
		end

		-- check the node above and below the found air node
		local node_above = minetest.get_node({x=random_pos.x, y=random_pos.y+1, z=random_pos.z}).name
		local node_below = minetest.get_node({x=random_pos.x, y=random_pos.y-1, z=random_pos.z}).name
		
		if not (node_above == "air" or node_below == "air") then
			return false
		end

		-- spawn only at day
		if not night_only and node_light < min_node_light then
			return false, true
		end

		-- spawn only at night
		if night_only then
			if not (19359 > tod and tod > 5200) or node_light < min_node_light then
				return random_pos
			else
				return false, true, found_node
			end
		end

		return random_pos, false, found_node
	else
		return false, true
	end
end

function spawners.check_node_status_ores(pos, ore_name, check_node)
	if not check_node then return end

	local player_near, found_node = spawners.check_around_radius_ores(pos, check_node)

	if player_near then
		return false, found_node
	else
		return true, false
	end
end
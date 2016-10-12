-- main tables
spawners_env = {}
spawners_env.mob_tables = {}

-- check if mods exists and build tables
for k, mob_mod in ipairs(ENABLED_MODS) do
	local modpath = minetest.get_modpath(mob_mod)
	-- list of mobs and their info
	if (modpath) then
		for j, mob in ipairs(MOBS_PROPS[mob_mod]) do
			local mob_egg = nil

			table.insert(spawners_env.mob_tables, {name=mob.name, mod_prefix=mob_mod, egg_name_custom=mob.egg_name_custom, dummy_size=mob.dummy_size, dummy_offset=mob.dummy_offset, dummy_mesh=mob.dummy_mesh, dummy_texture=mob.dummy_texture, night_only=mob.night_only, sound_custom=mob.sound_custom, env=mob.env})

			-- use custom egg or create a default egg
			if mob.egg_name_custom ~= "" then 
				mob_egg = mob.egg_name_custom
			else
				mob_egg = mob_mod..":"..mob.name
			end
		end
	else
		-- print something ?
	end
end

-- start spawning mobs
function spawners_env.start_spawning(pos, how_many, mob_name, mod_prefix, sound_custom)
	if not (pos or how_many or mob_name) then return end

	local sound_name
	-- remove 'spawners_env:' from the string
	local mob_name = string.sub(mob_name,14)

	-- use custom sounds
	if sound_custom ~= "" then 
		sound_name = sound_custom
	else
		sound_name = mod_prefix.."_"..mob_name
	end

	-- use random colours for sheeps
	if mob_name == "sheep_white" then
		local mob_name1 = ""
		local sheep_colours = {"black", "blue", "brown", "cyan", "dark_green", "dark_grey", "green", "grey", "magenta", "orange", "pink", "red", "violet", "white", "yellow"}
		local random_colour = math.random(1, #sheep_colours)
		mob_name1 = string.split(mob_name, "_")
		mob_name1 = mob_name1[1]
		mob_name = mob_name1.."_"..sheep_colours[random_colour]
	end

	if how_many == nil then
		how_many = math.random(0,4)
	end

	for i=1,how_many do
		pos.y = pos.y+1
		local obj = minetest.add_entity(pos, mod_prefix..":"..mob_name)

		if obj then
			if sound_name then
				minetest.sound_play(sound_name, {
					pos = pos,
					max_hear_distance = 100,
					gain = 5,
				})
			end
		end
	end
end

function spawners_env.check_around_radius(pos)
	local player_near = false
	local radius = 21
	local node_ore_pos = nil

	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if obj:is_player() then
			player_near = true
		end
	end

	return player_near
end

function spawners_env.check_node_status(pos, mob, night_only)
	local player_near = spawners_env.check_around_radius(pos)

	if player_near then
		local spawn_pos = minetest.find_node_near(pos, 2, {"air"})
		local min_node_light = 10
		local tod = minetest.get_timeofday() * 24000
		local node_light = minetest.get_node_light(pos)

		if not node_light then
			return false
		end

		-- check the node above and below the found air node
		local node_above = minetest.get_node({x=spawn_pos.x, y=spawn_pos.y+1, z=spawn_pos.z}).name
		local node_below = minetest.get_node({x=spawn_pos.x, y=spawn_pos.y-1, z=spawn_pos.z}).name
		
		if not (node_above == "air" or node_below == "air") then
			return false
		end

		if night_only ~= "disable" then
			-- spawn only at day
			if not night_only and node_light < min_node_light then
				return false, true
			end

			-- spawn only at night
			if night_only then
				if not (19359 > tod and tod > 5200) or node_light < min_node_light then
					return spawn_pos
				else
					return false, true
				end
			end
		end

		return spawn_pos, false
	else
		return false, true
	end
end

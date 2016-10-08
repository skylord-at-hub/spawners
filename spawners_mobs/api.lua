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

			-- disabled extra check for mobs redo due to incompatibility with Lua 5.1, this method is available from Lua 5.2
			-- if mob_mod == "mobs" and not (mobs.mod == "redo") then goto continue end

			table.insert(spawners.mob_tables, {name=mob.name, mod_prefix=mob_mod, egg_name_custom=mob.egg_name_custom, dummy_size=mob.dummy_size, dummy_offset=mob.dummy_offset, dummy_mesh=mob.dummy_mesh, dummy_texture=mob.dummy_texture, night_only=mob.night_only, sound_custom=mob.sound_custom})

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
	else
		-- print something ?
	end
end

-- start spawning mobs
function spawners.start_spawning(pos, how_many, mob_name, mod_prefix, sound_custom)
	if not (pos or how_many or mob_name) then return end

	local sound_name
	-- remove 'spawners_mobs:' from the string
	local mob_name = string.sub(mob_name,15)

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

	for i=1,how_many do
		pos.y = pos.y+1
		local obj = minetest.add_entity(pos, mod_prefix..":"..mob_name)

		if obj then
			if sound_name then
				minetest.sound_play(sound_name, {
					pos = pos,
					max_hear_distance = 32,
					gain = 5,
				})
			end
		end
	end
end

function spawners.check_around_radius(pos)
	local player_near = false
	local radius = 21

	for _,obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if obj:is_player() then
			player_near = true
		end
	end

	return player_near
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

		if night_only ~= "disable" then
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
		end

		return random_pos, false
	else
		return false, true
	end
end

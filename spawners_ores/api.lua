-- main tables
spawners_ores = {}

function spawners_ores.add_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 32,
		time = 2,
		minpos = vector.subtract({x=pos.x, y=pos.y+1, z=pos.z}, radius / 2),
		maxpos = vector.add({x=pos.x, y=pos.y+1, z=pos.z}, radius / 2),
		minvel = {x=-0.5, y=3, z=-0.5},
		maxvel = {x=0.5,  y=10,  z=0.5},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = .5,
		maxexptime = 2,
		minsize = .5,
		maxsize = 8,
		texture = "spawners_ores_smoke_particle.png",
	})
end

-- start spawning ores
function spawners_ores.start_spawning_ores(pos, ore_name, sound_custom, spawners_pos)
	if not pos or not ore_name then return end
	local sound_name
	local player_near = false

	-- use custom sounds
	if sound_custom ~= "" then 
		sound_name = sound_custom
	else
		sound_name = false
	end

	local how_many = math.random(1,2)
	-- how_many = how_many+1

	for i=1, how_many do
		
		if i > 1 then
			player_near, pos = spawners_ores.check_around_radius_ores(pos, "default:stone")

			if not pos then return end

			minetest.sound_play(sound_name, {
				pos = pos,
				max_hear_distance = 32,
				gain = 20,
			})

			minetest.set_node(pos, {name=ore_name})
			spawners_ores.add_effects(pos, 1)
		else
			minetest.sound_play(sound_name, {
				pos = pos,
				max_hear_distance = 32,
				gain = 20,
			})

			minetest.set_node(pos, {name=ore_name})
			spawners_ores.add_effects(pos, 1)
		end
	end
	
end

function spawners_ores.check_around_radius(pos)
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

function spawners_ores.check_around_radius_ores(pos, check_node)
	local player_near = spawners_ores.check_around_radius(pos);
	local found_node = false
	local node_ore_pos = nil
	if check_node then
		
		node_ore_pos = minetest.find_node_near(pos, 2, {check_node})
		
		if node_ore_pos then
			found_node = node_ore_pos
		end
	end

	return player_near, found_node
end

function spawners_ores.check_node_status_ores(pos, ore_name, check_node)
	if not check_node then return end

	local player_near, found_node = spawners_ores.check_around_radius_ores(pos, check_node)

	if player_near and found_node then
		return true, found_node
	else
		return true, false
	end
end
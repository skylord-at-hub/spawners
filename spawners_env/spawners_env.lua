-- 
-- * CREATE ALL SPAWNERS NODES *
-- 

function spawners_env.create(mob_name, mod_prefix, size, offset, mesh, texture, night_only, sound_custom)
	
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
			if n and n.name and n.name ~= "spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_active" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners_env:dummy_"..mod_prefix.."_"..mob_name, dummy_definition)

	-- 
	-- ACTIVE SPAWNER ENV
	-- 

	minetest.register_node("spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_active", {
		description = mod_prefix.."_"..mob_name.." spawner active env",
		paramtype = "light",
		light_source = 4,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_env_spawner_animated_16.png",
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
		on_timer = function(pos, elapsed)
			spawners_env.check_for_spawning_timer(pos, mob_name, night_only, mod_prefix, sound_custom)
			return false
		end,
		drop = {
			max_items = 1,
			items = {
				{items = {"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner"}, rarity = 20}
			}
		},
		on_construct = function(pos)
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners_env:dummy_"..mod_prefix.."_"..mob_name)
		end,
	})

	-- 
	-- WAITING SPAWNER ENV
	-- 

	-- waiting for light - everything is ok but too much light or not enough light
	minetest.register_node("spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_waiting", {
		description = mod_prefix.."_"..mob_name.." spawner waiting env",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_env_spawner_waiting_animated_16.png",
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
		on_timer = function(pos, elapsed)
			spawners_env.check_for_spawning_timer(pos, mob_name, night_only, mod_prefix, sound_custom)
			return false
		end,
		drop = {
			max_items = 1,
			items = {
				{items = {"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner"}, rarity = 20}
			}
		},
	})

	-- 
	-- INACTIVE SPAWNER (DEFAULT) ENV
	-- 

	minetest.register_node("spawners_env:"..mod_prefix.."_"..mob_name.."_spawner", {
		description = mod_prefix.."_"..mob_name.." spawner env",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		sunlight_propagates = true,
		tiles = {"spawners_env_spawner_16.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2,not_in_creative_inventory=1},
		stack_max = 1,
		drop = {
			max_items = 1,
			items = {
				{items = {"spawners_mobs:"..mod_prefix.."_"..mob_name.."_spawner"}, rarity = 20}
			}
		},
		on_construct = function(pos)
			spawners_env.check_for_spawning_timer(pos, mob_name, night_only, mod_prefix, sound_custom)
		end,
	})

	-- 
	-- * LBM *
	-- 

	minetest.register_lbm({
		name = "spawners_env:check_for_spawning_timer",
		nodenames = {
			"spawners_env:"..mod_prefix.."_"..mob_name.."_spawner",
			"spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_active",
			"spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_waiting"
		},
		action = function(pos)
			spawners_env.check_for_spawning_timer(pos, mob_name, night_only, mod_prefix, sound_custom)
		end
	})
end

-- 
-- * check for spawning *
-- 
function spawners_env.check_for_spawning_timer(pos, mob_name, night_only, mod_prefix, sound_custom)

	local random_pos, waiting = spawners_env.check_node_status(pos, mob_name, night_only)

	local node = minetest.get_node_or_nil(pos)

	-- minetest.log("action", "[Mod][Spawners] checking for: "..mob_name.." at "..minetest.pos_to_string(pos))

	if random_pos then
		-- print('try to spawn another mob at: '..minetest.pos_to_string(random_pos))

		local mobs_counter_table = {}
		mobs_counter_table[mob_name] = 0

		-- collect all spawned mobs around area
		for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 10)) do
			
			if obj:get_luaentity() ~= nil then

				-- get entity name			
				local name_split = string.split(obj:get_luaentity().name, ":")

				if name_split[2] == mob_name then

					mobs_counter_table[mob_name]=mobs_counter_table[mob_name]+1

				end

			end

		end

		-- print(mob_name.." : "..mobs_counter_table[mob_name])
		
		-- enough place to spawn more mobs
		if mobs_counter_table[mob_name] < 3 then
			-- make sure the right node status is shown
			if node.name ~= "spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_active" then
				minetest.set_node(pos, {name="spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_active"})
			end

			spawners_env.start_spawning(random_pos, 1, "spawners_env:"..mob_name, mod_prefix, sound_custom)
		else
			-- print("too many mobs: waiting")
			-- waiting status
			if node.name ~= "spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_waiting" then
				minetest.set_node(pos, {name="spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_waiting"})
			end
		end

	else
		-- print("no random_pos found: waiting")
		-- waiting status
		if node.name ~= "spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_waiting" then
			minetest.set_node(pos, {name="spawners_env:"..mod_prefix.."_"..mob_name.."_spawner_waiting"})
		end
	end

	minetest.get_node_timer(pos):start(math.random(5, 15))
end

-- 
-- CALL 'CREATE' FOR ALL SPAWNERS
-- 

for i, mob_table in ipairs(spawners_env.mob_tables) do
	if mob_table then

		spawners_env.create(mob_table.name, mob_table.mod_prefix, mob_table.dummy_size, mob_table.dummy_offset, mob_table.dummy_mesh, mob_table.dummy_texture, mob_table.night_only, mob_table.sound_custom)
	end
end
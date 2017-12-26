-- 
-- Colorize HEX
-- 

local colorize = {
	stone_with_gold = "^[colorize:#ffe40030",
	stone_with_tin = "^[colorize:#d0d0d040",
	stone_with_iron = "^[colorize:#b66d4940",
	stone_with_copper = "^[colorize:#b5875240",
}

-- 
-- Handle formspec and inventory management
-- 

local function allow_metadata_inventory_put(pos, listname, index, stack, player)

	if minetest.is_protected(pos, player:get_player_name()) then
		minetest.record_protection_violation(pos, player:get_player_name())
		return 0
	end

	local meta = minetest.get_meta(pos)
	local mineral = meta:get_string("mineral")

	if mineral == "iron" then
		mineral = "steel"
	end

	if stack:get_name() == "default:"..mineral.."_ingot" then

		minetest.get_node_timer(pos):start(1.0)
		
		return stack:get_count()
	else
		return 0
	end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		minetest.record_protection_violation(pos, player:get_player_name())
		return 0
	end

	minetest.get_node_timer(pos):start(1.0)

	return stack:get_count()
end

-- 
-- Spawners Ores creation function
-- 

function spawners_ores.create(def)

	local ore_name = def.ore_name or nil
	local size = def.size or {x = 0.33, y = 0.33}
	local offset = def.offset or 0

	-- these must be defined
	if ore_name == nil then
		return false
	end

	-- dummy inside the spawner
	local dummy_ore_definition = {
		hp_max = 1,
		physical = false,
		collisionbox = {0,0,0,0,0,0},
		visual = "wielditem",
		visual_size = size,
		timer = 0,
		textures={"default:"..ore_name},
		makes_footstep_sound = false,
		automatic_rotate = math.pi * -3,
		m_name = "dummy_ore"
	}

	local ore = string.split(ore_name, "_")

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
			if n and n.name and n.name ~= "spawners_ores:"..ore_name.."_spawner_active" and n.name ~= "spawners_ores:"..ore_name.."_spawner_waiting" and n.name ~= "spawners_ores:"..ore_name.."_spawner" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners_ores:dummy_ore_"..ore_name, dummy_ore_definition)

	-- node spawner active
	minetest.register_node("spawners_ores:"..ore_name.."_spawner_active", {
		description = ore_name.." spawner active",
		paramtype = "light",
		light_source = 4,
		paramtype2 = "glasslikeliquidlevel",
		drawtype = "glasslike_framed_optional",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_ores_spawner_animated_magma_16.png"..colorize[ore_name],
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
		drop = "spawners_ores:"..ore_name.."_spawner",
		
		can_dig = spawners_ores.can_dig,
		
		on_timer = spawners_ores.on_timer,
		
		on_blast = function(pos)
			local drops = {}
			default.get_inventory_drops(pos, "fuel", drops)
			drops[#drops+1] = "spawners_ores:"..ore_name.."_spawner_active"
			minetest.remove_node(pos)
			return drops
		end,

		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
	})

	-- node spawner waiting - no stone around or no fuel
	minetest.register_node("spawners_ores:"..ore_name.."_spawner_waiting", {
		description = ore_name.." spawner waiting",
		paramtype = "light",
		light_source = 2,
		paramtype2 = "glasslikeliquidlevel",
		drawtype = "glasslike_framed_optional",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_ores_spawner_waiting_animated_16.png"..colorize[ore_name],
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
		drop = "spawners_ores:"..ore_name.."_spawner_waiting",
		
		can_dig = spawners_ores.can_dig,
		
		on_timer = spawners_ores.on_timer,

		on_blast = function(pos)
			local drops = {}
			default.get_inventory_drops(pos, "fuel", drops)
			drops[#drops+1] = "spawners_ores:"..ore_name.."_spawner"
			minetest.remove_node(pos)
			return drops
		end,
		
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
	})

	-- node spawner inactive (default)
	minetest.register_node("spawners_ores:"..ore_name.."_spawner", {
		description = ore_name.." spawner",
		paramtype = "light",
		paramtype2 = "glasslikeliquidlevel",
		drawtype = "glasslike_framed_optional",
		walkable = true,
		sounds = default.node_sound_metal_defaults(),
		sunlight_propagates = true,
		tiles = {"spawners_ores_spawner_16.png"..colorize[ore_name]},
		is_ground_content = true,
		groups = {cracky = 1, level = 2},
		stack_max = 1,
		
		can_dig = spawners_ores.can_dig,
		
		on_timer = spawners_ores.on_timer,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			local formspec = spawners_ores.get_formspec(pos, {ore=ore[3]})

			-- Inizialize inventory
			local inv = meta:get_inventory()
			inv:set_size('fuel', 1)

			-- custom meta
			meta:set_string("mineral", ore[3])
			meta:set_string("ore_name", ore_name)
			meta:set_string("status", "")

			-- add spinning entity inside the spawner
			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners_ores:dummy_ore_"..ore_name)
			
			-- Update formspec, infotext and node
			meta:set_string("formspec", formspec)
			meta:set_string("infotext", ore[3].." ore spawner is empty")
		end,

		on_blast = function(pos)
			local drops = {}
			default.get_inventory_drops(pos, "fuel", drops)
			drops[#drops+1] = "spawners_ores:"..ore_name.."_spawner"
			minetest.remove_node(pos)
			return drops
		end,
	
		on_metadata_inventory_put = function(pos)
			-- start timer function, it will sort out whether ingots can burn in to stone and create minerals or not.
			minetest.get_node_timer(pos):start(1.0)
		end,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
	})

	-- replacement LBM for pre-nodetimer plants
	minetest.register_lbm({
		name = "spawners_ores:start_nodetimer_"..ore_name,
		nodenames = {
			"spawners_ores:"..ore_name.."_spawner_active",
			"spawners_ores:"..ore_name.."_spawner_waiting"
		},
		action = function(pos, node)
			spawners_ores.tick_short(pos)
		end,
	})
end

-- 
-- Ore Spawners Definitions
-- 

-- default:stone_with_gold
spawners_ores.create({
	ore_name = "stone_with_gold",
	size = {x = 0.33, y = 0.33},
	offset = 0
})

-- default:stone_with_iron
spawners_ores.create({
	ore_name = "stone_with_iron",
	size = {x = 0.33, y = 0.33},
	offset = 0
})

-- default:stone_with_copper
spawners_ores.create({
	ore_name = "stone_with_copper",
	size = {x = 0.33, y = 0.33},
	offset = 0
})

-- default:stone_with_tin
spawners_ores.create({
	ore_name = "stone_with_tin",
	size = {x = 0.33, y = 0.33},
	offset = 0
})

-- 
-- Recipes
-- 

minetest.register_craft({
	output = "spawners_ores:stone_with_gold_spawner",
	recipe = {
		{"default:diamondblock", "fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar_flat", "default:goldblock", "xpanes:bar_flat"},
		{"default:diamondblock", "xpanes:bar_flat", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners_ores:stone_with_iron_spawner",
	recipe = {
		{"default:diamondblock", "fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar_flat", "default:steelblock", "xpanes:bar_flat"},
		{"default:diamondblock", "xpanes:bar_flat", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners_ores:stone_with_copper_spawner",
	recipe = {
		{"default:diamondblock", "fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar_flat", "default:copperblock", "xpanes:bar_flat"},
		{"default:diamondblock", "xpanes:bar_flat", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners_ores:stone_with_tin_spawner",
	recipe = {
		{"default:diamondblock", "fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar_flat", "default:tinblock", "xpanes:bar_flat"},
		{"default:diamondblock", "xpanes:bar_flat", "default:diamondblock"},
	}
})

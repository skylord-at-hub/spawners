--
-- Formspecs
--

local function active_formspec(fuel_percent, item_percent)
	local formspec = 
		"size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_name;fuel;3.5,1.5;1,1;]"..
		"list[current_player;main;0,4.25;8,1;]"..
		"list[current_player;main;0,5.5;8,3;8]"..
		"button_exit[5,1.5;2,1;exit;Save]"..
		"listring[current_name;fuel]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.25)
	return formspec
end

local inactive_formspec =
	"size[8,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[current_name;fuel;3.5,1.5;1,1;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	"button_exit[5,1.5;2,1;exit;Save]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4.25)

--
-- Node callback functions that are the same for active and inactive furnace
--

function spawners.get_formspec(pos)

	-- Inizialize metadata
	local meta = minetest.get_meta(pos)
	
	-- Inizialize inventory
	local inv = meta:get_inventory()
	for listname, size in pairs({
			fuel = 1,
	}) do
		if inv:get_size(listname) ~= size then
			inv:set_size(listname, size)
		end
	end

	local fuellist = inv:get_list("fuel")

	--
	-- Cooking
	--
	
	-- Check if we have cookable content
	-- local cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
	-- local cookable = true
	
	-- if cooked.time == 0 then
	-- 	cookable = false
	-- end
	
	-- Check if we have enough fuel to burn
	-- if fuel_time < fuel_totaltime then
	-- 	-- The furnace is currently active and has enough fuel
	-- 	fuel_time = fuel_time + 1
		
	-- 	-- If there is a cookable item then check if it is ready yet
	-- 	if cookable then
	-- 		src_time = src_time + 1
	-- 		if src_time >= cooked.time then
	-- 			-- Place result in dst list if possible
	-- 			if inv:room_for_item("dst", cooked.item) then
	-- 				inv:add_item("dst", cooked.item)
	-- 				inv:set_stack("src", 1, aftercooked.items[1])
	-- 				src_time = 0
	-- 			end
	-- 		end
	-- 	end
	-- else
	-- 	-- Furnace ran out of fuel
	-- 	if cookable then
	-- 		-- We need to get new fuel
	-- 		local fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
			
	-- 		if fuel.time == 0 then
	-- 			-- No valid fuel in fuel list
	-- 			fuel_totaltime = 0
	-- 			fuel_time = 0
	-- 			src_time = 0
	-- 		else
	-- 			-- Take fuel from fuel list
	-- 			inv:set_stack("fuel", 1, afterfuel.items[1])
				
	-- 			fuel_totaltime = fuel.time
	-- 			fuel_time = 0
				
	-- 		end
	-- 	else
	-- 		-- We don't need to get new fuel since there is no cookable item
	-- 		fuel_totaltime = 0
	-- 		fuel_time = 0
	-- 		src_time = 0
	-- 	end
	-- end
	
	--
	-- Update formspec, infotext and node
	--
	local formspec = inactive_formspec
	-- local item_state = ""
	-- local item_percent = 0
	-- if cookable then
	-- 	item_percent =  math.floor(src_time / cooked.time * 100)
	-- 	item_state = item_percent .. "%"
	-- else
	-- 	if srclist[1]:is_empty() then
	-- 		item_state = "Empty"
	-- 	else
	-- 		item_state = "Not cookable"
	-- 	end
	-- end
	
	-- local fuel_state = "Empty"
	-- local active = "inactive "
	-- if fuel_time <= fuel_totaltime and fuel_totaltime ~= 0 then
	-- 	active = "active "
	-- 	local fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
	-- 	fuel_state = fuel_percent .. "%"
	-- 	formspec = active_formspec(fuel_percent, item_percent)
	-- 	-- swap_node(pos, "default:furnace_active")
	-- else
	-- 	if not fuellist[1]:is_empty() then
	-- 		fuel_state = "0%"
	-- 	end
	-- 	-- swap_node(pos, "default:furnace")
	-- end
	
	-- local infotext =  "Furnace " .. active .. "(Item: " .. item_state .. "; Fuel: " .. fuel_state .. ")"
	
	--
	-- Set meta values
	--
	-- meta:set_float("fuel_totaltime", fuel_totaltime)
	-- meta:set_float("fuel_time", fuel_time)
	-- meta:set_float("src_time", src_time)
	meta:set_string("formspec", formspec)
	-- meta:set_string("infotext", infotext)
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("fuel")
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	print("allow_metadata_inventory_put")
	print("listname: "..listname)
	print("stack name: "..stack:get_name())
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local ingot = minetest.get_node_or_nil(pos).name

	ingot = string.split(ingot, ":")
	ingot = string.split(ingot[2], "_")

	print("ingot 3: "..ingot[3])

	if stack:get_name() == "default:"..ingot[3].."_ingot" then
		if inv:is_empty("src") then
			meta:set_string("infotext", "ore spawner is empty")
		end
		return stack:get_count()
	else
		return 0
	end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	print("allow_metadata_inventory_take")
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function on_receive_fields(pos, formname, fields, sender)
	print("on_receive_fields")

	if minetest.is_protected(pos, sender:get_player_name()) then
		return 0
	end

	for k, v in ipairs(fields) do
		print("k: "..k)
		print("v: "..v)
	end
end

-- 
-- Ores creation
-- 

function spawners.create_ore(ore_name, mod_prefix, size, offset, texture, sound_custom)
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
			if n and n.name and n.name ~= "spawners:"..ore_name.."_spawner_active" and n.name ~= "spawners:"..ore_name.."_spawner_waiting" and n.name ~= "spawners:"..ore_name.."_spawner" then
				self.object:remove()
			end
		end
	end

	minetest.register_entity("spawners:dummy_ore_"..ore_name, dummy_ore_definition)

	-- node spawner active
	minetest.register_node("spawners:"..ore_name.."_spawner_active", {
		description = ore_name.." spawner active",
		paramtype = "light",
		light_source = 4,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		damage_per_second = 4,
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_spawner_animated.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 2.0
				},
			}
		},
		is_ground_content = true,
		groups = {cracky=1,level=2,igniter=1,not_in_creative_inventory=1},
		drop = "spawners:"..ore_name.."_spawner",
		-- on_construct = function(pos)
		-- 	pos.y = pos.y + offset
		-- 	minetest.add_entity(pos,"spawners:dummy_ore_"..ore_name)
		-- end,

		can_dig = can_dig,
	
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		on_receive_fields = on_receive_fields,
	})

	-- node spawner waiting - no stone around or no fuel
	minetest.register_node("spawners:"..ore_name.."_spawner_waiting", {
		description = ore_name.." spawner waiting",
		paramtype = "light",
		light_source = 2,
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
		tiles = {
			{
				name = "spawners_spawner_waiting_animated.png",
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
		drop = "spawners:"..ore_name.."_spawner",
		-- on_construct = function(pos)
		-- 	spawners.get_formspec(pos)
		-- 	pos.y = pos.y + offset
		-- 	minetest.add_entity(pos,"spawners:dummy_ore_"..ore_name)
		-- end,
		can_dig = can_dig,
	
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		on_receive_fields = on_receive_fields,
	})

	-- node spawner inactive (default)
	minetest.register_node("spawners:"..ore_name.."_spawner", {
		description = ore_name.." spawner",
		paramtype = "light",
		drawtype = "allfaces",
		walkable = true,
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
		tiles = {"spawners_spawner.png"},
		is_ground_content = true,
		groups = {cracky=1,level=2},
		on_construct = function(pos)
			local waiting, found_node = spawners.check_node_status_ores(pos, ore_name, "default:stone")

			spawners.get_formspec(pos)

			if found_node then
				minetest.swap_node(pos, {name="spawners:"..ore_name.."_spawner_active"})
			elseif waiting then
				minetest.swap_node(pos, {name="spawners:"..ore_name.."_spawner_waiting"})
			else
			end

			pos.y = pos.y + offset
			minetest.add_entity(pos,"spawners:dummy_ore_"..ore_name)
		end,

		can_dig = can_dig,
	
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		on_receive_fields = on_receive_fields,
	})

	-- 
	-- ABM
	-- 
	minetest.register_abm({
		nodenames = {"spawners:"..ore_name.."_spawner", "spawners:"..ore_name.."_spawner_active", "spawners:"..ore_name.."_spawner_waiting"},
		interval = 5.0,
		chance = 5,
		action = function(pos, node, active_object_count, active_object_count_wider)

			local waiting, found_node = spawners.check_node_status_ores(pos, ore_name,  "default:stone")

			print("ore_name: "..ore_name)

			if found_node then
				-- make sure the right node status is shown
				if node.name ~= "spawners:"..ore_name.."_spawner_active" then
					minetest.swap_node(pos, {name="spawners:"..ore_name.."_spawner"})
				end

				-- enough place to spawn more ores
				spawners.start_spawning_ores(found_node, "default:"..ore_name, sound_custom)

			else
				-- waiting status
				if node.name ~= "spawners:"..ore_name.."_spawner_waiting" then
					minetest.swap_node(pos, {name="spawners:"..ore_name.."_spawner_waiting"})
				end
			end

		end
	})

end

-- default:stone_with_gold
spawners.create_ore("stone_with_gold", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")

-- default:stone_with_coal
spawners.create_ore("stone_with_coal", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")

-- default:stone_with_iron
spawners.create_ore("stone_with_iron", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")

-- default:stone_with_copper
spawners.create_ore("stone_with_copper", "", {x=.33,y=.33}, 0, {"default_stone.png^default_mineral_gold.png"}, "tnt_ignite")


-- recipes
minetest.register_craft({
	output = "spawners:stone_with_gold_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:goldblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners:stone_with_coal_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:coalblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners:stone_with_iron_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:steelblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

minetest.register_craft({
	output = "spawners:stone_with_copper_spawner",
	recipe = {
		{"default:diamondblock", "fake_fire:flint_and_steel", "default:diamondblock"},
		{"xpanes:bar", "default:copperblock", "xpanes:bar"},
		{"default:diamondblock", "xpanes:bar", "default:diamondblock"},
	}
})

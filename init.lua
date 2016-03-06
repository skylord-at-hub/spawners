-- Main settings
dofile(minetest.get_modpath("spawners").."/settings.txt")

-- Spawners configurations
dofile(minetest.get_modpath("spawners").."/config.lua")

-- API
dofile(minetest.get_modpath("spawners").."/API.lua")

-- Spawners for mobs
dofile(minetest.get_modpath("spawners").."/spawners_mobs.lua")

-- Spawners for ores
dofile(minetest.get_modpath("spawners").."/spawners_ores.lua")

-- include mummy mobs redo addon (mob)
if minetest.get_modpath("mobs") then
	dofile(minetest.get_modpath("spawners").."/mob_mummy.lua")
end

-- Spawners Pyramids
if SPAWN_PYRAMIDS then
	dofile(minetest.get_modpath("spawners").."/pyramids.lua")

	print("[Mod][spawners] Pyramids enabled")
end

-- Add Spawners to dungeons, temples..
if SPAWNERS_GENERATE then
	dofile(minetest.get_modpath("spawners").."/spawners_gen.lua")

	print("[Mod][spawners] Environmental enabled")
end

print ("[Mod] Spawners 0.6 Loaded.")
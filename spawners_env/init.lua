MOD_NAME = minetest.get_current_modname()

-- Main settings
dofile(minetest.get_modpath(MOD_NAME).."/settings.txt")

-- Spawners configurations
dofile(minetest.get_modpath(MOD_NAME).."/config.lua")

-- API
dofile(minetest.get_modpath(MOD_NAME).."/api.lua")

-- Spawners Pyramids
if SPAWN_PYRAMIDS then
	dofile(minetest.get_modpath(MOD_NAME).."/pyramids.lua")

	print("[Mod][spawners] Pyramids enabled")
end

-- Add Spawners to dungeons, temples..
if SPAWNERS_GENERATE then
	dofile(minetest.get_modpath(MOD_NAME).."/spawners_gen.lua")

	print("[Mod][spawners] Spawners generate enabled")
end

-- Add Chests to dungeons, temples..
if CHESTS_GENERATE then
	dofile(minetest.get_modpath(MOD_NAME).."/chests_gen.lua")

	print("[Mod][spawners] Chests generate enabled")
end

print ("[Mod] Spawners Environmental 0.6 Loaded.")
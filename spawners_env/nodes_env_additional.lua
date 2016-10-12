local img = {"eye", "men", "sun"}

for i=1,3 do
	minetest.register_node("spawners_env:deco_stone_"..img[i], {
		description = "Sandstone with "..img[i],
		tiles = {"default_sandstone.png^spawners_env_"..img[i]..".png"},
		is_ground_content = true,
		groups = {crumbly=2,cracky=3},
		sounds = default.node_sound_stone_defaults(),
	})
end
# Spawners #
This MOD for Minetest let the player craft mob Spawner blocks.

Easy to implement new mob mods, but you must make sure that those mods following the right naming convention and have sounds, textures, models with the right name.

Inspired from:

* HeroOfTheWinds [Mob Spawners MOD](https://forum.minetest.net/viewtopic.php?f=9&t=10555)
* Discontinued BlockMen [Creatures MOD](https://github.com/BlockMen/creatures)

![spawners-01.jpg](https://bitbucket.org/repo/y69Me7/images/2710670485-spawners-01.jpg)

## Links ##
[Minetest Forum Page](https://forum.minetest.net/viewtopic.php?f=10&t=13727)

[G+ Collection](https://plus.google.com/collection/06fEx)

[G+ Community](https://plus.google.com/communities/105201070842404099845)

## License ##
WTFPL

## Changelog ##
### 0.1 ###
* Initial Release
* detects only 6 nodes for 'air' around the spawner [top, bottom, left, right, front, back] afterwards it will check the node above and below the found 'air' node - so there is enough space to spawn someone
* always picks random side from where the mob will spawn
* detects for light and time of day - spawn mobs only at night if 'only_night' set to true
* status 'waiting' - blue sparkles, for not enough light (day spawners) or too much light for night spawners
* status 'default/inactive' i.e. if the spawner is closed from each side or there is no space to spawn mob
* status 'active' when spawner is active and is spawning mobs
* status 'overheat' when there is too much 'max_objects_per_block' (prevents from server errors), max value is taken from minetest.conf
* easy to configure, add and remove MODs for mobs
* only [Mobs Redo](https://github.com/tenplus1/mobs) from tenplus1 is added for now
* added recipes for all spawners, it's expensive so it will not get overcrowded on the server only with spawners 
* almost everything is done dynamically
* spawners emit small amount of light
* active and overheated spawner can cause fire to flammable nodes around it
* spawners are active only if player is in radius (21)
* spawners are diggable only with steel pickaxe and above, so no noob griefers can raid your base too easy
* mobs play sound when spawned
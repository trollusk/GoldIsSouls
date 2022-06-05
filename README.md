# Gold Is Souls #

Replaces Skyrim's leveling system with a system based on Soulslike games. Skills are no longer increased through use. 
Instead, you must pay gold every time you want to increase a skill.

This is a modification of Gold Is XP, by RogueRifler. 

### Requirements ###

* SKSE
* SkyUI - if you want to use the MCM to configure the mod.

### Differences from Gold Is XP ###

In the original mod, a tally is kept of all the gold that you acquire. Once this point total gets high enough, you level up, 
and are then able to spend the points to increase skills. What you do with the gold after acquiring it does not matter to 
the leveling system.

In Gold Is Souls, you spend the gold itself to increase skills. For every 10 skill points you purchase in this way, you gain a level.
This means you must choose how you spend your gold - do you increase your skills and level up, or do you buy gear or spells?

The other difference is in the formula used to calculate the cost of leveling up. Gold Is Souls uses the same formula as 
Dark Souls I/II. That number is then divided by 10 to get the cost for a skill point increase (since there are 10 skill point 
increases per level).

### Uninstalling ###

First disable the mod in the MCM, save and exit. Then remove the mod from your load order.

### Other recommended mods ###

* No Trainers
* Respawn Death Overhaul
* Smoothcam + Soulslike preset
* Better Third Person Selection
* Rest By Campfires + Soulslike Bonfire Menu addon
* Souls Quick Menu RE
* Widget mod - can be set up to display carried gold in your HUD

### Acknowledgements ###

* RogueRifler
* Dark Souls

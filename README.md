# Gold Is Souls #

Replaces Skyrim's leveling system with a system based on Dark Souls. Skills are no longer increased through use. 
Instead, you must pay gold every time you want to increase a skill.

This is a modification of [Gold Is XP](https://www.nexusmods.com/skyrimspecialedition/mods/20084), 
by [RogueRifler](https://www.nexusmods.com/skyrimspecialedition/users/49856166). 

### Requirements ###

* SKSE
* SkyUI - if you want to use the MCM to configure the mod.

### Features ###

Normal leveling is disabled - you will no longer be able to level skills by using them. Trainers are also disabled. You are still 
able to gain skill points by reading books.

After waking from sleep, if you are carrying enough gold to level up one of your skills, you will be presented with a skill leveling menu. 
When you choose a skill on this menu, you will be told the gold cost of increasing the skill by 1 point. If you choose to proceed,
you will lose that amount of gold, and the skill will be incremented.

For every 10 skill points you purchase in this way, you gain a level.

This means you must choose how you spend your gold - do you increase your skills and level up, or do you buy gear or spells?

### Cost of increasing skills ###

The formula used to calculate the cost of leveling up is the same **cubic** formula that is used in Dark Souls (but using 
gold instead of souls). 

$$
C = 0.02x^3 + 3.06x^2 + 105.6x - 895
$$

That number is then divided by 10 to get the cost for a skill point increase, since there are 10 skill point 
increases per level (by default, this number can be changed in the MCM.)

The following table shows the cost to raise a skill by 1 point starting at the given skill level. 

| Skill Level | Cost for +1 point | Cumulative Cost |
|-------------|-------------------|-----------------|
| 5  	      | 67  			  | 67				|
| 10	      | 76  			  | 429				|
| 20  	 	  | 166 			  | 1458			|
| 40  	      | 781 			  | 10620			|
| 50		  | 1239 			  | 20855			|
| 60  		  | 1813 			  | 36298			|
| 80  	  	  | 3359			  | 87853			|
| 100  	  	  | 5514 			  | 176565			|

As can be seen from the table, if you level a character to 100 by leveling 10 skills all the way to 100, this will cost 
about 1,765,650 gold. If instead you level to 100 
by raising 20 skills to 50, this will cost about 417,000 gold. While this is much cheaper, you would be sacrificing the benefits 
of having very high skills.

### Uninstalling ###

First disable the mod in the MCM, then save and exit. Then remove the mod from your load order.

### Other recommended mods ###

* [Respawn - Soulslike Edition](https://www.nexusmods.com/skyrimspecialedition/mods/69267)
* Smoothcam + Soulslike preset
* Better Third Person Selection
* Rest By Campfires + Soulslike Bonfire Menu addon
* Souls Quick Menu RE
* Widget mod - can be set up to display carried gold in your HUD

### Acknowledgements ###

* RogueRifler for allowing me to use Gold Is XP as the basis for this mod.
* From Software

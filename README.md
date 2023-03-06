# *IW3Cine*
<img src="https://cdn.discordapp.com/attachments/1004525406055047180/1081832494774620220/image.png" alt="screenshot" height="250px" align="right"/>

**A Port of [Sass' Cinematic Mod](https://github.com/sortileges/iw4cine) to Call of Duty 4**

<p align="left">
  <a href="#about">About</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#issues">Issues</a> •
  <a href="#credits">Credits</a>
</p>

<div align="left">
<a href="https://github.com/datapIan/iw3cine/releases"><img src="https://img.shields.io/github/v/release/datapIan/iw3cine?label=Latest%20Release&style=flat-square"></a>
  <a href="https://github.com/datapIan/iw3cine/releases""><img src="https://img.shields.io/github/downloads/datapIan/iw3cine/total?style=flat-square"></a>

## About

 - Sass' mod changed the editing game, and it's what we've all used for cinematics for as long as we can remember. I believed the same level of personalization should be in every other game. So I did it.
This mod is for those who want to make really specific cinematics, if you're looking for more "real-style" demo creation, I would recommend looking into [Kruumy's COD4 Editing Mod](https://github.com/kruumy/cod4-editing-mod).

99% of the code was written by Sass, I take no credit for the work he has done, I just changed a few things to make it work on COD4.

## Installation

There's two types of installations for this mod. One for the *iw3xo* client, and one for the *COD4(x)* clients.

#### [IW3xo](https://xoxor4d.github.io/projects/iw3xo/) (Recommended)

* Download the mod from [here](), extract and drag the "iw3cine" folder into your mods folder.
```text
C:/
└── .../
    └── iw3xo/
        └── mods/
            └── iw3cine
```


#### COD4 Steam / [COD4x](https://cod4x.ovh/)

* Download the mod from [here](), extract. Make a folder inside your mods folder and drag the "maps" folder into it. This new folder will be the name of the mod, so rename it to something nice.
```text
C:/
└── .../
    └── COD4/
        └── mods/
            └── createdfolder
                └── maps
```

## Usage

* Most commands in-game function the same way as they did in MW2, except for the toggling type commands: `about, clone, clearbodies, mvm_eb, and mvm_bot_holdgun`

  └── These commands are required to be typed as `command` followed by a 1. Example: `clearbodies 1`
* BotSpawn and BotModel command arguments are `class = ar, smg, lmg, shotgun, sniper`, `team = allies, axis`
* BotWeapon command arugments are `weapon = weapon name (m40a3_mp)`, `camo = woodland, desert, digital, blue, red, gold`
* BotKill command arguments are `mode = head, body, shotgun, cash`
* EnvColors command arguments are the name of any zone, example: `mvm_env_colors mp_farm`
* EnvFog command arguments are `startdist, halfdist, red, green, blue`, example: `100 1000 1 .2 .7`
* EnvProp command arguments are models in the current map, common_mp, or a custom fastfile. If from a custom fastfile or another map, it must be precached!

  └── A list of common_mp xmodels can be found [here](https://pastebin.com/4nyXs25a)
* EnvFx command arguments are fx in the current map, common_mp, or a custom fastile. If from a custom fastfile or another map, it must be precached!
  
  └── Additionally, the arguments must be typed as `folder/filename`, example: `fire/firelp_med_pm_nodistort`
       └── A list of common_mp fx's can be found [here](https://pastebin.com/q41g3GpJ).
  

## Issues
* ***Actors*** - Currently there is no support for actors and I don't think there ever will be.
* ***BotModel*** - Currently, the bot model command will change a bots model, but after the bot dies, it'll crash the game. Better to know what class you want the bot to use when spawning it in.

### To report bugs or feature requests, please do so through [this](https://github.com/datapIan/iw3cine/issues) link.

## Credits

* [Antiga](https://github.com/mprust) - Helped with .gsc related questions.
* [Expert](https://github.com/soexperttt) - Told me I should start coding, althought I didn't technically code anything for this.
* [ReeaL](https://github.com/reaalx) - Helped with .menu related questions.
* [Sass](https://github.com/sortileges) - Wrote the original MW2 Cinematic Mod.
* [yoyo1love](https://github.com/yoyothebest) - Helped with .gsc and .menu related questions.

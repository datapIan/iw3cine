# *IW3Cine*
<img src="https://cdn.discordapp.com/attachments/1004525406055047180/1081832494774620220/image.png" alt="screenshot" height="250px" align="right"/>

**A Port of Sass' Cinematic Mod to Call of Duty 4**

<p align="left">
  <a href="#about">About</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#issues">Issues</a> •
  <a href="#credits">Credits</a>
</p>

## About

Sass' mod changed the editing game, and it's what we've all used for cinematics for as long as we can remember. I believed the same level of personalization should be in every other game. So I did it.
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


#### COD4 Steam / COD4x

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

## Issues

* **BotModel** - Currently, the bot model command will change a bots model, but after the bot dies, it'll crash the game. Better to know what class you want the bot to use when spawning it in.

## Credits

* [Antiga](https://github.com/mprust) - Helped with .gsc related questions.
* [Expert](https://github.com/soexperttt) - Told me I should start coding, althought I didn't technically code anything for this.
* [ReeaL](https://github.com/reaalx) - Helped with .menu related questions.
* [Sass](https://github.com/sortileges) - Wrote the original MW2 Cinematic Mod.
* [yoyo1love](https://github.com/yoyothebest) - Helped with .gsc and .menu related questions.

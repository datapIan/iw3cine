#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
//#include maps\mp\_art;

movie()
{
	level thread MovieConnect();

	level._effect["fire"] = loadfx("props/barrel_fire");
	level._effect["blood"] = loadfx("impacts/flesh_hit_body_fatal_exit");
	game["dialog"]["gametype"] = undefined;
}

MovieConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		if(!player BotTester())
		{
			player thread BotFreeze();
			player thread MovieSpawn();
			if(!isDefined(player.ebmagic))
				player.ebmagic = 2;
			if (!isDefined(player.linke))
				player.linke = false;
		}
	}
}

MovieSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// Grenade cam reset
		setDvar("camera_thirdperson", "0");
		self show();

		// Regeneration	
		thread RegenAmmo(); // Not needed when you can just /give ammo.
		thread RegenEquip(); // Not needed when you can just /give ammo.
		thread RegenSpec(); // Not needed when you can just /give ammo.

		// Bots
		thread BotSpawn(); // Command args: ar,smg,lmg,shotgun,sniper // allies,axis.
		thread BotSetup();
		thread BotGiveWeapon(); // Command args: [name weapon camo] [desert,woodland,digital,red,blue,gold]
		thread BotStare();
		thread BotAim();
		thread BotModel(); // Command args: [name	ar,smg,lmg,shotgun,sniper	allies,axis]
		thread BotFreeze(); // Forces testclient to be frozen upon spawning.

		// Explosive Bullets
		thread EB(); // Toggles between EVERYWHERE, CLOSE, OFF when set to 1.

		// "Kill" command
		thread BotKill(); // Command args: [name	body,head,shotgun,cash]
		thread EnableLink(); // Holdgun

		// Environement
		thread SpawnProps(); // Uses common_mp or map's xmodel folder unless others are precached.
		thread SpawnEffects(); // Uses common_mp or map's fx folder. Must type out path name... ex: weather/hawk.
		thread TweakFog(); // Idk about this one.
		thread SetVisions(); // Most visions can be found in the zone folder.
	}
}

RegenAmmo()
{
	for (;;)
	{
		self waittill("reload");
		wait 1;
		currentWeapon = self getCurrentWeapon();
		self giveMaxAmmo(currentWeapon);
	}
}

RegenEquip()
{
	for (;;)
	{
		if(self fragButtonPressed())
		{
			currentOffhand = self GetCurrentOffhand();
			self.pers["equSpec1"] = currentOffhand;
			wait 2;
			self setWeaponAmmoClip(self.pers["equSpec1"], 9999);
			self GiveMaxAmmo(self.pers["equSpec1"]);
		}
		wait 0.1;
	}
}

RegenSpec()
{
	for (;;)
	{
		if(self secondaryOffhandButtonPressed())
		{
			currentOffhand = self GetCurrentOffhand();
			self.pers["equSpec"] = currentOffhand;
			wait 2;
			self giveWeapon(self.pers["equSpec"]);
			self giveMaxAmmo(currentOffhand);
			self setWeaponAmmoClip(currentOffhand, 9999);
		}
		wait 0.1;
	}
}

BotTester()
{
    assert( isDefined( self ) );
    assert( isPlayer( self ) );

    return ( ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] ) || isSubStr( self getguid() + "", "bot" ) );
}

BotFreeze()
{
    self endon("disconnect");
    for(;;)
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];
            if(player BotTester())
                player freezeControls(true);
        }
        wait 1;
    }
}

BotSpawn()
{
	self endon("disconnect");
	self endon("death");

	setDvar("mvm_bot_spawn", "Spawn a bot - ^9[class team]");  
    for (;;)
	{
        if(getDvar("mvm_bot_spawn") != "Spawn a bot - ^9[class team]")
        {
		    newTestClient = addTestClient();
		    newTestClient.pers["isBot"] = true;
		    newTestClient.isStaring = false;
		    //newTestClient thread BotsLevel();
		    newTestClient thread BotDoSpawn(self);
            setDvar("mvm_bot_spawn", "Spawn a bot - ^9[class team]");
        }
        wait 0.5;
	}
}

BotDoSpawn(owner)
{
	self endon("disconnect");

	argumentstring = getDvar("mvm_bot_spawn");
	arguments = StrTok(argumentstring, " ,");

	while (!isdefined(self.pers["team"])) 
    wait .05;

	// Picking team
	if ( ( arguments[1] == "allies" || arguments[1] == "axis" ) && isDefined(arguments[1]) )
		{
            self notify("menuresponse", game["menu_team"], arguments[1]);
            wait 0.5;
        }
	else 
	    {
	    	kick(self getEntityNumber());
	    	owner iPrintLn("[^1ERROR^7] Team name needs to be either ^8allies ^7or ^8axis^7!");
	    	return;
	    }
	wait .1;

    // Picking class
	if (arguments[0] == "ar")
		self notify("menuresponse", "changeclass", "assault_mp");
	else if (arguments[0] == "smg")
		self notify("menuresponse", "changeclass", "specops_mp");
	else if (arguments[0] == "lmg")
		self notify("menuresponse", "changeclass", "heavygunner_mp");
	else if (arguments[0] == "shotgun")
		self notify("menuresponse", "changeclass", "demolitions_mp");
	else if (arguments[0] == "sniper")
		self notify("menuresponse", "changeclass", "sniper_mp");
	else 
	    {
	    	kick(self getEntityNumber());
        	self iPrintLn("[^3WARNING^7] ^8'"+ arguments[0] +"' ^7isn't a valid class." );
			self iPrintLn("CLASS = ^3ar, smg, lmg, shotgun, sniper");
	    	return;
	    }
	self waittill("spawned_player");
    wait 0.1;

	self setOrigin(BulletTrace(owner getTagOrigin("tag_eye"), anglestoforward(owner getPlayerAngles()) * 100000, true, owner)["position"]);
	self setPlayerAngles(owner.angles + (0, 180, 0));
	self thread SaveSpawn();
}

BotSetup()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_setup", "Move bot to x-hair - ^9[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_setup") != "Move bot to x-hair - ^9[name]")
		{
			for ( i = 0; i < level.players.size; i++ )
		    {
                player = level.players[i];
				if (isSubStr(player.name, getDvar("mvm_bot_setup")))
				{
					player setOrigin(BulletTrace(self getTagOrigin("tag_eye"), anglestoforward(self getPlayerAngles()) * 100000, true, self)["position"]);
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_setup", "Move bot to x-hair - ^9[name]");
		}
		wait 0.5;
	}
}

BotGiveWeapon() 
{
    self endon("death");
    self endon("disconnect");

    setDvar("mvm_bot_weapon", "Give a bot a weapon - ^9[name weapon camo]");
    for (;;) 
	{
        if (getDvar("mvm_bot_weapon") != "Give a bot a weapon - ^9[name weapon camo]") 
		{
            argumentString = getDvar("mvm_bot_weapon", "");
            arguments = StrTok(argumentString, " ,");
            for (playerIndex = 0; playerIndex < level.players.size; playerIndex++) 
			{
                player = level.players[playerIndex];
                if (isSubStr(player.name, arguments[0])) 
				{
                    newWeapon = arguments[1];
                    player takeweapon(player getCurrentWeapon());
                    player switchToWeapon(player getCurrentWeapon());
                    wait .05;
                    setWeaponCamo(player, newWeapon, arguments[2]);
                }
            }
   			setDvar("mvm_bot_weapon", "Give a bot a weapon - ^9[name weapon camo]");
        }
        wait 0.5;
    }
}

BotKill()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_kill", "Kill a bot - ^9[name mode]");
	for (;;)
	{
        if(getDvar("mvm_bot_kill") != "Kill a bot - ^9[name mode]")
        {
		    argumentstring = getDvar("mvm_bot_kill", "");
		    arguments = StrTok(argumentstring, " ,");

		    for ( i = 0; i < level.players.size; i++ )
		    {
                player = level.players[i];
		    	if (isSubStr(player.name, arguments[0]))
		    	{
		    		if (self.linke)
		    		{
		    			player PrepareInHandModel();
		    			player takeweapon(player getCurrentWeapon());
		    			wait .05;
		    		}
		    		player thread BotDoKill(arguments[1], self);
		    	}
                setDvar("mvm_bot_kill", "Kill a bot - ^9[name mode]");
		    }
        }
        wait 0.5;
	}
}

BotDoKill(mode, attacker)
{
	self endon("disconnect");
	self endon("death");
	{
		if (mode == "head")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_head"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "head", 0);
		}
		else if (mode == "body")
		{
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
		else if (mode == "shotgun")
		{
			vec = anglestoforward(self.angles);
			end = (vec[0] * (-300), vec[1] * (-300), vec[2] * (-300));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", "winchester1200_mp", self.origin + end, self.origin, "left_foot", 0);
		}
		else if (mode == "cash")
		{
			playFx(level._effect["fire"], self getTagOrigin("j_spine4"));
			playFx(level._effect["blood"], self getTagOrigin("j_spine4"));
			self thread[[level.callbackPlayerDamage]](self, self, 1337, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "body", 0);
		}
        self BotFreeze();
		self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			oldclass = self.pers["class"];
	}
}

BotStare()
{
	self endon("death");
	self endon("disconnect");
	
	setDvar("mvm_bot_stare", "Bot stare at clostest enemy - ^9[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_stare") != "Bot stare at clostest enemy - ^9[name]")
		{
			for ( i = 0; i < level.players.size; i++ )
			{
        	    player = level.players[i];
				if (isSubStr(player.name, getDvar("mvm_bot_stare")))
				{
					if (player.isStaring == false) {
						player thread BotDoAim();
						player.isStaring = true;
					}
					else if (player.isStaring == true) {
						player notify("stopaim");
						player.isStaring = false;
					}
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_stare", "Bot stare at clostest enemy - ^9[name]");
		}
		wait 0.5;
	}
}

BotAim()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_aim", "Bot aim at clostest enemy - ^9[name]");
	for (;;)
	{
		if(getDvar("mvm_bot_aim") != "Bot aim at clostest enemy - ^9[name]")
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if (isSubStr(player.name, getDvar("mvm_bot_aim")))
				{
					player = level.players[i];
					player thread BotDoAim();
					wait .4;
					player notify("stopaim");
					player thread SaveSpawn();
				}
			}
			setDvar("mvm_bot_aim", "Bot aim at clostest enemy - ^9[name]");
		}
		wait 0.5;
	}
}

BotDoAim()
{
	self endon("disconnect");
	self endon("stopaim");

	for (;;)
	{
		wait .01;
		aimAt = undefined;
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else
				aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_head")) - (self getTagOrigin("j_head"))));
		}
	}
}

BotModel()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_bot_model", "Change bot model - ^8[name MODEL team]");
	for (;;)
	{
		argumentstring = getDvar("mvm_bot_model");
		arguments = StrTok(argumentstring, " ,");
		if(getDvar("mvm_bot_model") != "Change bot model - ^8[name MODEL team]")
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];
				if (isSubStr(player.name, arguments[0]))
				{
					player.lteam = arguments[2];
					team = player.lteam;
					//if(arguments[2] != allies || arguments[2] !=)
					player.lmodel = arguments[1];
					class = player.lmodel;
					player detachAll();
					setBotModel(player, team, class);
					//player[[game[player.lteam + "_model"][player.lmodel]]]();
					player.modelalready = true;
				}
			}
			setDvar("mvm_bot_model", "Change bot model - ^8[name MODEL team]");
		}
		wait 0.5;
	}
}

setBotModel(player, team, class)
{
	//player detachAll();
    switch (class) 
	{
        case "ar":
            self[[game[player.lteam + "_model"]["CLASS_CUSTOM1"]]]();
            break;
        case "smg":
			player[[game[player.lteam + "_model"]["SPECOPS"]]]();
			break;
        case "lmg":
            player[[game[player.lteam + "_model"]["SUPPORT"]]]();
            break;
        case "shotgun":
            player[[game[player.lteam + "_model"]["RECON"]]]();
            break;
        case "sniper":
            player[[game[player.lteam + "_model"]["SNIPER"]]]();
            break;
        default:
			player[[game[player.lteam + "_model"]["ASSAULT"]]]();
			self iPrintLn("One of the arguments is ^1INVALID! ^7 ASSAULT given.");
			self iPrintLn("CLASS = ^3ar, smg, lmg, shotgun, sniper");
			self iPrintLn("team = ^3allies, axis");
			break;
    }
}

EB()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_eb", "Toggle explosive bullets");
	for (;;)
	{
		if(getDvar("mvm_eb") != "Toggle explosive bullets ^9[everywhere magic off]")
		{
			switch (self.ebmagic)
			{
				case 0:
					self thread ebMagicScript();
					self iPrintLn("Magic explosive bullets - ^2EVERYWHERE");
					self.ebmagic = 1;
					break;
				case 1:
					self notify("eb2off");
					self iPrintLn("Magic explosive bullets - ^3CLOSE");
					self.ebmagic = 2;
					self thread ebCloseScript();
					break;
				case 2:
					self notify("eb2off");
					self notify("eb1off");
					self iPrintLn("Magic explosive bullets - ^1OFF");
					self.ebmagic = false;
					break;
			}
			setDvar("mvm_eb", "Toggle explosive bullets ^9[everywhere magic off]");
		}
		wait 1;
	}
}

ebMagicScript()
{
	self endon("disconnect");
	self endon("eb2off");

	for(;;)
	{
		wait 0.1;
		aimAt = undefined;
		for (i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			if (player == self || !isAlive(player) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self waittill("weapon_fired");
			aimAt thread[[level.callbackPlayerDamage]](self, self, aimAt.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
		}
	}
}

ebCloseScript()
{
	self endon("eb1off");
	self endon("disconnect");

	range = 150; // make this a client adjustable variable
	for(;;)
	{
		wait .01;
		aimAt = undefined;
		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if (player == self)
				continue;
			if (!isAlive(player))
				continue;
			if (level.teamBased && self.pers["team"] == player.pers["team"])
				continue;
			if ( distance( destination, player getOrigin() ) > range )
                continue;
			if (isDefined(aimAt))
			{
				if (closer(self getTagOrigin("j_head"), player getTagOrigin("j_head"), aimAt getTagOrigin("j_head")))
					aimAt = player;
			}
			else aimAt = player;
		}
		if (isDefined(aimAt))
		{
			self waittill("weapon_fired");
			aimAt thread[[level.callbackPlayerDamage]](self, self, aimAt.health, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "HEAD", 0);
		}
	}
}

EnableLink()
{
    self endon("death");
    self endon("disconnect");

    setDvar("mvm_bot_holdgun", "Toggle bots holding their gun when dying");
    for (;;)
    {
        if(getDvar("mvm_bot_holdgun") != "Toggle bots holding their gun when dying")
        {
            if (self.linke == false)
			{
                self iPrintLn("Bots hold weapon on mvm_bot_kill : ^2TRUE");
                self.linke = true;
            }
            else if (self.linke == true)
           {
                self iPrintLn("Bots hold weapon on mvm_bot_kill : ^1FALSE");
                self.linke = false;
            }
            setDvar("mvm_bot_holdgun", "Toggle bots holding their gun when dying");
        }
        wait 0.5;
    }
}

TweakFog()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_env_fog", "Custom fog - ^9[start half r g b]");
	for (;;)
	{
		if(getDvar("mvm_env_fog") != "Custom fog - ^9[start half r g b]")
		{
			argumentstring = getDvar("mvm_env_fog", "Custom fog - ^9[start half r g b]");
			arguments = StrTok(argumentstring, " ,");
			//SetExpFog( <startDist>, <halfwayDist>, <red>, <green>, <blue>, <transition time> );
			setExpFog(int(arguments[0]), int(arguments[1]), int(arguments[2]), int(arguments[3]), int(arguments[4]), 1);
			setDvar("mvm_env_fog", "Custom fog - ^9[start half r g b]");
		}
		 wait 0.5;
	}
}

SetVisions()
{
	self endon("disconnect");
	self endon("death");

	setDvar("mvm_env_colors", "Change vision - ^9[vision]");
	for (;;)
	{
        if(getDvar("mvm_env_colors") != "Change vision - ^9[vision]")
        {
		    visionSetNaked(getDvar("mvm_env_colors", "visname"));
		    self IPrintLn("Vision changed to : " + getDvar("mvm_env_colors"));
            wait 0.5;
            setDvar("mvm_env_colors", "Change vision - ^9[vision]");
	    }
        wait 0.5;
    }
}

SpawnProps()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_env_prop", "Spawn a prop - ^9[prop]");
	for (;;)
	{
        if(getDvar("mvm_env_prop") != "Spawn a prop - ^9[prop]")
        {
			prop = spawn("script_model", self.origin);
			prop.angles = self.angles;
			prop setModel(getDvar("mvm_env_prop", ""));
			self IPrintLn("^7Prop: " + getDvar("mvm_env_prop", "") + " ^3spawned ! ");
			setDvar("mvm_env_prop", "Spawn a prop - ^9[prop]");
		}
		wait 0.5;
	}
}

SpawnEffects()
{
	self endon("disconnect");

	setDvar("mvm_env_fx", "Spawn an effect - ^9[fx]");
	for (;;)
	{
        if(getDvar("mvm_env_fx") != "Spawn an effect - ^9[fx]")
        {
			start = self getTagOrigin("tag_eye");
			end = anglestoforward(self getPlayerAngles()) * 1000000;
			fxpos = BulletTrace(start, end, true, self)["position"];
			level._effect[getDvar("mvm_env_fx", "")] = loadfx((getDvar("mvm_env_fx", "")));
			playFX(level._effect[getDvar("mvm_env_fx", "")], fxpos);
			self IPrintLn("^7FX: " + getDvar("mvm_env_fx", "") + " ^3spawned ! ");
			setDvar("mvm_env_fx", "Spawn an effect - ^9[fx]");
		}
		wait 0.5;
	}
}

SaveSpawn()
{
	self.spawn_origin = self.origin;
	self.spawn_angles = self getPlayerAngles();
	self BotFreeze();
}

PrepareInHandModel()
{
	currentWeapon = self getCurrentWeapon();

	if (isDefined(self.weaptoattach))
		self.weaptoattach delete();

	self.weaptoattach = getWeaponModel(currentWeapon);
	self attach(self.weaptoattach, "tag_weapon_right", true);

	self.weaptoattach thread maps\mp\gametypes\_weapons::watchWeaponChange();
}

setWeaponCamo(player, weapon, camo) 
{
    switch (camo) 
	{
        case "desert":
            player giveWeapon(weapon, 1);
            player setSpawnWeapon(weapon, 1);
            break;
        case "woodland":
            player giveWeapon(weapon, 2);
            player setSpawnWeapon(weapon, 2);
            break;
        case "digital":
            player giveWeapon(weapon, 3);
            player setSpawnWeapon(weapon, 3);
            break;
        case "blue":
            player giveWeapon(weapon, 5);
            player setSpawnWeapon(weapon, 5);
            break;
        case "red":
            player giveWeapon(weapon, 4);
            player setSpawnWeapon(weapon, 4);
            break;
        case "gold":
            player giveWeapon(weapon, 6);
            player setSpawnWeapon(weapon, 6);
            break;
        default:
            player giveWeapon(weapon, 0);
            player setSpawnWeapon(weapon, 0);
            break;
    }
}

toggleModel(modeltype)
{
	switch(modeltype)
	{
		case "assault":
			if(self.pers["class"] == "CLASS_ASSAULT") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_assault"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_assault"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_assault"]) && self.pers["model_assault"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "specops":
		    if(self.pers["class"] == "CLASS_SPECOPS") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_specops"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_specops"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_specops"]) && self.pers["model_specops"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "support":
		    if(self.pers["class"] == "CLASS_HEAVYGUNNER") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_support"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_support"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_support"]) && self.pers["model_support"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		
		
		case "demolitions":
		    if(self.pers["class"] == "CLASS_DEMOLITIONS") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_recon"]))
			{
				self.pers["model_assault"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_recon"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_recon"]) && self.pers["model_recon"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "sniper":
		    if(self.pers["class"] == "CLASS_SNIPER") self iPrintLnBold( game["strings"]["no_change_model"] );
			else
			if(!isDefined(self.pers["model_sniper"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_sniper"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_sniper"]) && self.pers["model_sniper"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
			
		case "velinda":
		    if(!isDefined(self.pers["model_velinda"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_velinda"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_velinda"]) && self.pers["model_velinda"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
			
		case "price":
		    if(!isDefined(self.pers["model_price"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_price"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_price"]) && self.pers["model_price"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
			
		case "farmer":
		    if(!isDefined(self.pers["model_price"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_farmer"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_farmer"]) && self.pers["model_farmer"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "zakhaev":
		    if(!isDefined(self.pers["model_zakhaev"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_zakhaev"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_zakhaev"]) && self.pers["model_zakhaev"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "alasad":
		    if(!isDefined(self.pers["model_alasad"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_alasad"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_alasad"]) && self.pers["model_alasad"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "ghillie":
		    if(!isDefined(self.pers["model_ghillie"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_urbansniper"] = undefined;
				self.pers["model_ghillie"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_ghillie"]) && self.pers["model_ghillie"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		case "urbansniper":
		    if(!isDefined(self.pers["model_urbansniper"]))
			{
				self.pers["model_recon"] = undefined;
				self.pers["model_assault"] = undefined;
				self.pers["model_specops"] = undefined;
				self.pers["model_sniper"] = undefined;
				self.pers["model_support"] = undefined;
				self.pers["model_default"] = undefined;
				self.pers["model_velinda"] = undefined;
				self.pers["model_price"] = undefined;
				self.pers["model_farmer"] = undefined;
				self.pers["model_zakhaev"] = undefined;
				self.pers["model_alasad"] = undefined;
				self.pers["model_ghillie"] = undefined;
				self.pers["model_urbansniper"] = true;
				self iPrintLnBold( game["strings"]["change_model"] );
			}
			else
			if(isDefined(self.pers["model_urbansniper"]) && self.pers["model_urbansniper"] == true)
			{
				self iPrintLnBold( game["strings"]["no_change_model"] );
			}
			break;
		
		default:
		    self.pers["model_recon"] = undefined;
		    self.pers["model_assault"] = undefined;
			self.pers["model_support"] = undefined;
			self.pers["model_specops"] = undefined;
			self.pers["model_velinda"] = undefined;
			self.pers["model_price"] = undefined;
		    self.pers["model_sniper"] = undefined;
			self.pers["model_farmer"] = undefined;
			self.pers["model_zakhaev"] = undefined;
			self.pers["model_alasad"] = undefined;
			self.pers["model_ghillie"] = undefined;
			self.pers["model_urbansniper"] = undefined;
			if(!isDefined(self.pers["model_default"]) && self.pers["model_default"] != true) self iPrintLnBold( game["strings"]["change_model_default"] );
			self.pers["model_default"] = true;
			break;
	}
}
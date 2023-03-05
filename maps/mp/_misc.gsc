#include maps\mp\gametypes\_globallogic;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_movie;

misc()
{
	level thread MiscConnect();

	// Common precache, do not remove !!!
	PrecacheModel("defaultactor");
	PrecacheModel("projectile_rpg7");
}

MiscConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		// LOD tweaks
		setDvar("r_lodBiasRigid", "-1000");
		setDvar("r_lodBiasSkinned", "-1000");

		setDvar("sv_hostname", "^3Sass' Cinematic Mod ^7- Ported to COD4 by ^3Forgive");
		setDvar("g_TeamName_Allies", "allies");
		setDvar("g_TeamName_Axis", "axis");
		setDvar("jump_slowdownEnable", "0");
		setdvar("ui_allow_classchange", "1");
		setdvar("ui_allow_teamchange", "1");

		game["strings"]["change_class"] = " ";

		player thread MiscSpawn();
	}
}

MiscSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		// No fall damage and unlimited sprint.
		setdvar( "scr_giveperk", "specialty_longersprint" );
		setDvar( "bg_fallDamageMinHeight", "9998" );
		setDvar( "bg_falLDamageMaxHeight", "9999" );

		// Misc
		thread SetPlayerScore();
		thread GivePlayerKillstreak(); // Command args: [radar_mp, airstrike_mp, helicopter_mp]
		//thread GivePlayerWeapon();
		thread MsgAbout();
		thread MsgWelcome();
		thread WeaponChangeClass();
		//thread WeaponSecondaryCamo();
		thread CreateClone();
		thread ClearBodies();
		thread LoadPos();
		thread FakeNoclip();

		thread VerifyModel();
 	}
}

SetPlayerScore()
{
	self endon("death");
	self endon("disconnect");
	
	setDvar("mvm_score", "Change score per kill");
	for (;;)
	{
		if(getDvar("mvm_score") != "Change score per kill")
		{
			maps\mp\gametypes\_rank::registerScoreInfo( "kill",  int(getDvarInt("mvm_score")));

			if ( isSubStr(getDvar("mvm_score"), "Change") || getDvarInt("mvm_score") >= 50 )
			{
				maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
				maps\mp\gametypes\_rank::registerScoreInfo( "execution", 100 );
				maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 50 );
				maps\mp\gametypes\_rank::registerScoreInfo( "defender", 50 );
				maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 25 );
				maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 50 );
				maps\mp\gametypes\_rank::registerScoreInfo( "double", 50 );
				maps\mp\gametypes\_rank::registerScoreInfo( "triple", 75 );
				maps\mp\gametypes\_rank::registerScoreInfo( "multi", 100 );
				maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 100 );
				maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 100 );
				maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 50 );
				maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 100 );
				maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 100 );
			}
			else 
			{
				maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "execution", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "defender", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "double", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "triple", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "multi", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 0 );
				maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 0 );
			}
			iPrintLn("Score set to: ^1" + (getDvarInt("mvm_score")));
			setDvar("mvm_score", "Change score per kill");
		}
		wait 0.5;
	}
}

GivePlayerKillstreak()
{
	self endon("death");
	self endon("disconnect");

	setDvar("mvm_killstreak", "^9[radar_mp airstrike_mp helicopter_mp]");
	for (;;)
	{
		if(getDvar("mvm_killstreak") != "^9[radar_mp airstrike_mp helicopter_mp]")
		{
			self maps\mp\gametypes\_hardpoints::giveHardpointItem(getDvar("mvm_killstreak"), false);
			wait 0.1;
			setDvar("mvm_killstreak", "^9[radar_mp airstrike_mp helicopter_mp]");
		}
		wait 0.5;
	}
}

MsgAbout()
{
	self endon("death");
	self endon("disconnect");

	setDvar("about", "About the mod...");
	for (;;)
	{
		if(getdvar("about") != "About the mod...")
		{
			self IPrintLnBold("Sass' Cinematic Mod");
			wait 1.5;
			self IPrintLnBold("Ported to COD4 by Forgive");
			wait 1.5;
			self IPrintLnBold("Thanks for downloading !");
			self IPrintLn("^1Thanks to / Credits :");
			self IPrintLn("- Sass for making the MW2 Mod.");
			self IPrintLn("- Antiga and yoyo1love for .gsc help.");
			self IPrintLn("- ReaaL for .menu help.");
			self IPrintLn("- You and everybody who supported the project!");
			wait 1.5;
			setDvar("about", "About the mod...");
		}
		wait 0.5;
	}
}

MsgWelcome()
{
	self endon("death");
	self endon("disconnect");
	{
		if (!isDefined(self.donefirst) && self.pers["isBot"] == false)
		{
			level.prematchPeriodEnd = -1;
			wait 6;
			self IPrintLn("Welcome to ^3Sass' Cinematic Mod");
			self IPrintLn("Ported to COD4 by ^3Forgive");
			self IPrintLn("Type ^3/about ^7for more info");
			self.donefirst = 1;
		}
	}
}

WeaponChangeClass()
{
	self endon("death");
	self endon("disconnect");

	oldclass = self.pers["class"];
	for(;;)
	{
		if(self.pers["class"] != oldclass)
		{
			self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			oldclass = self.pers["class"];
			setdvar( "scr_giveperk", "specialty_longersprint" );
		}
		wait .05;
	}
}

CreateClone()
{
	self endon("disconnect");
	self endon("death");

	setDvar("clone", "Spawn a clone of yourself");
	for (;;)
	{
		if(getDvar("clone") != "Spawn a clone of yourself")
		{
			if ( getDvar("clone") == "2") 
			{
				self PrepareInHandModel();
				wait .1;
				self ClonePlayer(1);
			}
			else 
			{
				self.weaptoattach delete();
				self ClonePlayer(1);
			}
			setDvar("clone", "Spawn a clone of yourself");
		}
		wait 0.5;	
	}
}

ClearBodies()
{
	self endon("disconnect");
	self endon("death");

	setDvar("clearbodies", "Clear all dead bodies");
	for (;;)
	{
		if(getDvar("clearbodies") != "Clear all dead bodies")
		{
			self iPrintLn("Cleaning up...");
			for (i = 0; i < 15; i++)
			{
				clone = self ClonePlayer(1);
				clone delete();
				wait .1;
			}
			setDvar("clearbodies", "Clear all dead bodies");
		}
		wait 0.5;
	}
}

VerifyModel()
{
	self endon("disconnect");
	if (isDefined(self.modelalready))
	{
		self detachAll();
		self[[game[self.lteam + "_model"][self.lmodel]]]();
	}
}

LoadPos()
{
	self freezecontrols(true);
	wait .05;
	self setPlayerAngles(self.spawn_angles);
	self setOrigin(self.spawn_origin);
	wait .05;
	self freezecontrols(false);
}

FakeNoclip()
{
	self endon("disconnect");
	self endon("death");
	self endon("killnoclip");

	setDvar("noclip2", 0);
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	for (;;)
	{
		if(getDvarInt("noclip2") == 1)
		{
			self allowSpectateTeam("freelook", true);
			self.sessionstate = "spectator";
		}
		else if(getDvarInt("noclip2") == 0)
		{
			self allowSpectateTeam("freelook", false);
			self.sessionstate = "playing";
		}
		wait 0.5;
	}
}

takeAllSecOffhands()
{
	self takeweapon( "smoke_grenade_mp" );
	self takeweapon( "flash_grenade_mp" );
	self takeweapon( "concussion_grenade_mp" );
}

takeAllPrimOffhands()
{
	self takeweapon( "c4_mp" );
	self takeweapon( "claymore_mp" );
	self takeweapon( "frag_grenade_mp" );
}

getOffhandName(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
			return "flash";
		case "smoke_grenade_mp":
			return "smoke";
		case "concussion_grenade_mp":
			return "concussion_grenade_mp";
		case "c4_mp":
			return "c4_mp";
		case "claymore_mp":
			return "claymore_mp";
		case "frag_grenade_mp":
			return "frag_grenade_mp";
		default:
			return "other";
	}
}

isSecOffhand(item)
{
	switch(item)
	{
		case "flash_grenade_mp":
		case "smoke_grenade_mp":
		case "concussion_grenade_mp":
			return true;
		default:
			return false;
	}
}

isEquipment(item)
{
	switch(item)
	{
		case "c4_mp":
		case "claymore_mp":
		case "frag_grenade_mp":
		case "flash_grenade_mp":
		case "smoke_grenade_mp":
		case "concussion_grenade_mp":
			return true;
		default:
			return false;
	}
}

checkIfWeirdWeapon(weapon, camo)
{
	return weapon;
}

checkIfCamoAvailable(weapon, camo)
{
	weaponName = StrTok(weapon, "_");
	ref = weaponName[0];
	switch( weaponName[0] )
	{
		case "usp":
		case "m1911":
		case "deserteagle":
		case "rpg":
			return "";
		default:
			//
	}
}

isValidCamoAlias(camo)
{
	switch(camo)
	{
		case "desert":
		case "woodland":
		case "digital":
		case "blue":
		case "red":
		case "gold":
			return true;
		default:
			return false;
	}
}

setWeap(player, weapon, camo) 
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
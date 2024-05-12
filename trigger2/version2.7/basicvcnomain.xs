//==============================================================================
// BASICVC.xs
//
// A really, really simple victory condition script.
//==============================================================================


 include "mod.xs";


// Include the extended mechanics
include "extendedmechanics.xs";

// this rule checks if a player's units are all dead
// run this every ~4 seconds.
// this rule operates in all gameplay modes (it is the definition of conquest victory)
rule BasicVC1
   minInterval 4
   maxInterval 5
   active
{
   // never fire VCs instantly
   if (trTimeMS() < 10000)
	  return;

   int prevPlayer = xsGetContextPlayer();

   //Iterate over the players.
   for (i=1; < cNumberPlayers)
   {
	  xsSetContextPlayer(i);
	  //Don't check players who have already lost
	  if (kbHasPlayerLost(i) == false)
	  {
		 int count = 0;
		 count = count + kbUnitCount(i, cUnitTypeLogicalTypeNeededForVictory, cUnitStateAlive);

		 //If we don't have any, this player is done.
		 if (count <= 0)
		 {
			//trEcho("You have lost, Player #"+i+".  You suxor.");
			
			trSetPlayerDefeated(i); // note that this func must be called synchronously on all machines
		 }
	  }
   }

   xsSetContextPlayer(prevPlayer);
}


// this rule checks to see if there are enemies left in the game, if not it ends the game
// we run this rule pretty quickly since it should be responsive when you win
rule BasicVC2
   minInterval 1
   maxInterval 1
   active
{
   // never fire VCs instantly
   if (trTimeMS() < 10000)
	  return;

   if (kbIsGameOver() == false)
   {
	  vcCheckConquestVictory();
   }   
}

void checkSettlementVictory()
{
   // never fire VCs instantly
   if (trTimeMS() < 10000)
	  return;

   vcCheckSettlementVictory(120); 
}


void checkWonderVictory()
{
   // never fire VCs instantly
   if (trTimeMS() < 10000)
	  return;

   int prevPlayer = xsGetContextPlayer();

   // go through all players and look for wonder timers to start
   // note the actual wonder countdown, etc is handled in C code
   // this trigger's responsibility is just starting things up
   for (p=1; < cNumberPlayers)
   {
	  xsSetContextPlayer(p);
	  if (kbHasPlayerLost(p) == false)
	  {
		 int wonder = kbUnitCount(p, cUnitTypeWonder, cUnitStateAlive);
		 if (wonder > 0)
			vcStartOrUpdateWonderTimer(p, "Wonder", 600);
	  }
   }
   xsSetContextPlayer(prevPlayer);
}

void resignEventHandler(int plrID=1)
{
   vcCheckConquestVictory();
}

void buildingUpgradeEventHandler(int unused=1)
{
   if (kbIsGameOver() == true)
	  return;

   // only apply this in supremacy (normal), lightning and deathmatch
   if ((vcGetGameplayMode() != cGameModeSupremacy) && (vcGetGameplayMode() != cGameModeLightning) && (vcGetGameplayMode() != cGameModeDeathmatch))
	  return;

   checkSettlementVictory();
}

void allianceChangeEventHandler(int unused=1)
{
   if (kbIsGameOver() == true)
	  return;

   // only apply this in supremacy (normal), lightning and deathmatch
   if ((vcGetGameplayMode() != cGameModeSupremacy) && (vcGetGameplayMode() != cGameModeLightning) && (vcGetGameplayMode() != cGameModeDeathmatch))
	  return;

   checkSettlementVictory();
}

void buildingConstructedEventHandler(int unused=1)
{
   if (kbIsGameOver() == true)
	  return;

   // only apply this in supremacy (normal) and lightning
   if ((vcGetGameplayMode() != cGameModeSupremacy) && (vcGetGameplayMode() != cGameModeLightning) && (vcGetGameplayMode() != cGameModeTreaty))
	  return;
	 
   checkWonderVictory();
}

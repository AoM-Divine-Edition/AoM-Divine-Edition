// Main entry point for random map script
void main(void)
{

// rmSetVCFile("rmsuddendeathvc");


for(i=1; <cNumberPlayers)
{
   rmCreateTrigger("StartCountdown" + i);
   rmCreateTrigger("CountdownWarning"+i);
   rmCreateTrigger("StopCountdown" +i);
   rmCreateTrigger("Loss" +i);
   rmCreateTrigger("grantTechs"+i);
}
rmCreateTrigger("gaiaChat");

// Start Countdown
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("StartCountdown"+i));
   rmSetTriggerActive(true);

   rmAddTriggerCondition("Player Unit Count");
   rmSetTriggerConditionParamInt("PlayerID", i);
   rmSetTriggerConditionParam("ProtoUnit", "Settlement Level 1");
   rmSetTriggerConditionParam("Op", "<");
   rmSetTriggerConditionParamInt("Count", 1);

   rmAddTriggerCondition("Player Unit Count");
   rmSetTriggerConditionParamInt("PlayerID", i);
   rmSetTriggerConditionParam("ProtoUnit", "Citadel Center");
   rmSetTriggerConditionParam("Op", "<");
   rmSetTriggerConditionParamInt("Count", 1);

   rmAddTriggerCondition("Player Active");
   rmSetTriggerConditionParamInt("PlayerID", i);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
//   rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" has no Settlements! Countdown begins!");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22608)}");

   rmAddTriggerEffect("Counter:Add Timer");
   rmSetTriggerEffectParam("Name", "victoryCounter"+i);
   rmSetTriggerEffectParamInt("Start",120);
   rmSetTriggerEffectParamInt("Stop",30);
//   rmSetTriggerEffectParam("Msg", rmGetPlayerName(i)+" needs to claim a Settlement in");
   rmSetTriggerEffectParam("Msg", "{PlayerIDNameString("+i+",22609)}");
   rmSetTriggerEffectParamInt("Event", rmTriggerID("CountdownWarning"+i));

   rmAddTriggerEffect("Fire Event");
   rmSetTriggerEffectParamInt("EventID", rmTriggerID("StopCountdown"+i));
}

// Countdown Warning
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("CountdownWarning"+i));
   rmSetTriggerActive(false);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
//   rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" will lose in 30 seconds, unless a Settlement is claimed.");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22610)}");

   rmAddTriggerEffect("Counter:Add Timer");
   rmSetTriggerEffectParam("Name", "victoryCounter2"+i);
   rmSetTriggerEffectParamInt("Start",30);
   rmSetTriggerEffectParamInt("Stop",0);
//   rmSetTriggerEffectParam("Msg", rmGetPlayerName(i)+" needs to claim a Settlement in");
   rmSetTriggerEffectParam("Msg", "{PlayerIDNameString("+i+",22609)}");
   rmSetTriggerEffectParamInt("Event", rmTriggerID("Loss"+i));
}

// Stop Countdown
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("StopCountdown"+i));
   rmSetTriggerActive(false);

   rmAddTriggerCondition("Player Unit Count");
   rmSetTriggerConditionParamInt("PlayerID", i);
   rmSetTriggerConditionParam("ProtoUnit", "Settlement Level 1");
   rmSetTriggerConditionParam("Op", ">");
   rmSetTriggerConditionParamInt("Count", 0);

   rmAddTriggerEffect("Counter Stop");
   rmSetTriggerEffectParam("Name", "victoryCounter"+i);

   rmAddTriggerEffect("Counter Stop");
   rmSetTriggerEffectParam("Name", "victoryCounter2"+i);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
//   rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" has claimed a Settlement!");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22611)}");

   rmAddTriggerEffect("Fire Event");
   rmSetTriggerEffectParamInt("EventID", rmTriggerID("StartCountdown"+i));
}

// You lose
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("Loss"+i));
   rmSetTriggerActive(false);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
//   rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" is out of the game.");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22612)}");

   rmAddTriggerEffect("Set Player Defeated");
   rmSetTriggerEffectParamInt("Player", i);
}
  
// Fire starting units
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("grantTechs"+i));
   rmSetTriggerActive(true);

   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1", 1);

   rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "33");
   rmSetTriggerEffectParam("Status", "4");

   rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "60");
   rmSetTriggerEffectParam("Status", "4");

   rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "182");
   rmSetTriggerEffectParam("Status", "4");

   rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "362");
   rmSetTriggerEffectParam("Status", "4");

/*   rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "381");
   rmSetTriggerEffectParam("Status", "4"); */

} 

   rmSwitchToTrigger(rmTriggerID("gaiaChat"));
   rmSetTriggerActive(true);

   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1", 1);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
//   rmSetTriggerEffectParam("Message", "Masons, Architects, Fortify Town Center active"); 
   rmSetTriggerEffectParam("Message", "{22613}");


	// Triggera to grant Altantis a favor trickle

for(i=1; <cNumberPlayers)
{
	if(rmGetPlayerCulture(i) == cCultureAtlantean)
	{
	rmCreateTrigger("Favor_trickle"+i);
	rmSetTriggerActive(true);
	rmSetTriggerPriority(4);
	rmSetTriggerLoop(false);

	rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "496");
	rmSetTriggerEffectParam("Status", "4");
	}
}


   // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=10000;
   if(cMapSize == 1)
   {
      playerTiles = 13000;
      rmEchoInfo("Large map");
   }   
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmTerrainInitialize("GrassA");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classPlayerCore=rmDefineClass("player core");
   int classForest=rmDefineClass("forest");
   rmDefineClass("corner");
   rmDefineClass("center");
   rmDefineClass("starting settlement");

   // Tower constraint.
   int avoidOtherPlayerTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 30.0);

   // Close Objects

   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Citadel Center", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

      // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 15.0);
   rmSetObjectDefMaxDistance(startingGoldID, 28.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, edgeConstraint);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   // goats
   int closeGoatsID=rmCreateObjectDef("close goats");
   rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 15.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
   rmAddObjectDefConstraint(closeGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);
   
   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(9,12), 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeElkID=rmCreateObjectDef("close elk");
   float elkNumber=rmRandFloat(0, 1);
   if(elkNumber<0.3)
      rmAddObjectDefItem(closeElkID, "elk", 4, 2.0);
   else if(elkNumber<0.6)
      rmAddObjectDefItem(closeElkID, "elk", 6, 2.0);
   else 
      rmAddObjectDefItem(closeElkID, "elk", 7, 2.0);
   rmSetObjectDefMinDistance(closeElkID, 25.0);
   rmSetObjectDefMaxDistance(closeElkID, 35.0);
   rmAddObjectDefConstraint(closeElkID, avoidImpassableLand);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   rmAddObjectDefConstraint(stragglerTreeID, avoidImpassableLand);

      // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 70.0);
   rmSetObjectDefMaxDistance(farGoldID, 160.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   // Goats avoid TCs and other herds, since this map places a lot of Goats
   int farGoatsID=rmCreateObjectDef("far Goats");
   rmAddObjectDefItem(farGoatsID, "Goat", 2, 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoatsID, avoidHerdable);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
     
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "boar", 3, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "deer", 7, 6.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 80.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, 160.0);
    rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);

    // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 60.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, avoidImpassableLand);


   // Create the lakes if teams = 2

   if(cNumberTeams == 2)
   {
      int coreThreeID=rmCreateArea("core three");
      rmSetAreaSize(coreThreeID, 0.1, 0.1);
      rmSetAreaLocation(coreThreeID, 0, 1);
      rmSetAreaWaterType(coreThreeID, "Greek River");
      rmSetAreaBaseHeight(coreThreeID, 0.0);
      rmSetAreaMinBlobs(coreThreeID, 3);
      rmSetAreaHeightBlend(coreThreeID, 1);
      rmSetAreaMaxBlobs(coreThreeID, 3);
      rmSetAreaMinBlobDistance(coreThreeID, 20.0);
      rmSetAreaMaxBlobDistance(coreThreeID, 20.0);
      rmSetAreaCoherence(coreThreeID, 0.25);
      rmAddAreaInfluenceSegment(coreThreeID, 0, 1, 0.3, 0.7);
      rmBuildArea(coreThreeID);
   
      int coreFourID=rmCreateArea("core four");
      rmSetAreaSize(coreFourID, 0.1, 0.1);
      rmSetAreaLocation(coreFourID, 1, 0);
      rmSetAreaWaterType(coreFourID, "Greek River");
      rmSetAreaBaseHeight(coreFourID, 0.0);
      rmSetAreaMinBlobs(coreFourID, 3);
      rmSetAreaHeightBlend(coreFourID, 1);
      rmSetAreaMaxBlobs(coreFourID, 3);
      rmSetAreaMinBlobDistance(coreFourID, 20.0);
      rmSetAreaMaxBlobDistance(coreFourID, 20.0);
      rmSetAreaCoherence(coreFourID, 0.25);
      rmAddAreaInfluenceSegment(coreFourID, 0.7, 0.3, 1, 0);
      rmBuildArea(coreFourID);
   }

   // Text
   rmSetStatusText("",0.20);

/*   rmSetTeamSpacingModifier(0.70); */

   if(cNumberNonGaiaPlayers == 2)
      rmPlacePlayersLine(0.15, 0.15, 0.85, 0.85, 0, 0); 
   else if(cNumberTeams == 2)
/*   {
      rmSetPlacementTeam(0); 
      rmPlacePlayersLine(0.06, 0.06, 0.43, 0.43, 0, 0); 
      rmSetPlacementTeam(1);
      rmPlacePlayersLine(0.57, 0.57, 0.94, 0.94, 0, 0);
   } */

      rmPlacePlayersLine(0.07, 0.07, 0.93, 0.93, 0, 20); 
   else
      rmPlacePlayersCircular(0.35, 0.4, rmDegreesToRadians(5.0));


   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(1600);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);
      rmSetAreaSize(id, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaWarnFailure(id, false);
      rmSetPlayerArea(i, id);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);
/*      rmAddAreaConstraint(id, playerConstraint); */
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "GrassDirt50");
      rmAddAreaTerrainLayer(id, "GrassDirt25", 0, 4);
   }

   // Build the areas.
   rmBuildAllAreas();

   // Beautification sub area.
   for(i=1; <cNumberPlayers)
   {
      int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
      rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaLocPlayer(id2, i);
      rmSetAreaTerrainType(id2, "GrassDirt50");
      rmAddAreaTerrainLayer(id2, "GrassDirt25", 0, 2);
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);

      rmBuildArea(id2);
   }

   // Text
   rmSetStatusText("",0.40);

   for(i=1; <cNumberPlayers*10)
   {
      // Beautification sub area.
      int id3=rmCreateArea("Sand patch"+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(200), rmAreaTilesToFraction(500));
      rmSetAreaTerrainType(id3, "SandC");
      rmAddAreaTerrainLayer(id3, "GrassDirt75", 4, 6);
      rmAddAreaTerrainLayer(id3, "GrassDirt50", 2, 4);
      rmAddAreaTerrainLayer(id3, "GrassDirt25", 0, 2);
      rmAddAreaConstraint(id3, avoidImpassableLand);
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.0);

      rmBuildArea(id3);
   }

   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Towers.

   for(i=1; <cNumberPlayers)
   {
      rmDefineClass("classTower"+i);
      int towerVsTowerID=rmCreateClassDistanceConstraint("player towers spread out "+i, rmClassID("classTower"+i), 25);
      rmEchoInfo "player "+i+"'s towers avoid "+i);
      for(j=1; <5)
      {
         int startingTowerID=rmCreateObjectDef("Starting tower for player "+i+" number "+j);
         rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
         rmAddObjectDefItem(startingTowerID, "tent", 1, 5.0);
         rmSetObjectDefMinDistance(startingTowerID, 18.0);
         rmSetObjectDefMaxDistance(startingTowerID, 28.0);
         rmAddObjectDefToClass(startingTowerID, rmClassID("classTower"+i));
         rmAddObjectDefConstraint(startingTowerID, towerVsTowerID);
         rmAddObjectDefConstraint(startingTowerID, avoidOtherPlayerTower);
         rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);
         rmPlaceObjectDefAtAreaLoc(startingTowerID, i, rmAreaID("Player"+i));
      }   
   }

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 10);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false, 3);

   int classCliff=rmDefineClass("cliff");
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 20.0);
   int shortCliffConstraint=rmCreateClassDistanceConstraint("stuff v cliff", rmClassID("cliff"), 10.0);
   int failCount=0;
   
   for(i=0; <cNumberPlayers*1.5)
   {
      int cliffID=rmCreateArea("cliff"+i);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
      rmSetAreaCliffType(cliffID, "Greek");
      rmAddAreaConstraint(cliffID, cliffConstraint);
      rmAddAreaConstraint(cliffID, avoidImpassableLand);
      rmAddAreaToClass(cliffID, classCliff);
      rmAddAreaConstraint(cliffID, avoidBuildings);
      rmSetAreaMinBlobs(cliffID, 10);
      rmSetAreaMaxBlobs(cliffID, 10);
      rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
      rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaMinBlobDistance(cliffID, 16.0);
      rmSetAreaMaxBlobDistance(cliffID, 40.0);
      rmSetAreaCoherence(cliffID, 0.25);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaHeightBlend(cliffID, 2);
    
      if(rmBuildArea(cliffID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==3)
            break;
      }
      else
         failCount=0;
      
   }

   // Text
   rmSetStatusText("",0.60);

   rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2, 3));

   // Goats
   rmPlaceObjectDefPerPlayer(closeGoatsID, false, 2);
   rmPlaceObjectDefPerPlayer(farGoatsID, false, 2);

   rmPlaceObjectDefPerPlayer(closeChickensID, false);

   // Elk
   rmPlaceObjectDefPerPlayer(closeElkID, false);

   rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 2);

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
   

   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
   int fishID=rmCreateObjectDef("fish2");
   rmAddObjectDefItem(fishID, "fish - perch", 3, 6.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);


      // Elev.
   int numTries=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(200));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, cliffConstraint);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "GrassDirt50");  
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));

      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 20 times in a row.
         failCount++;
         if(failCount==20)
            break;
      }
      else
         failCount=0;
   }

   // Forest.
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=5*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
      rmSetAreaWarnFailure(forestID, false);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaForestType(forestID, "oak forest");
      else
         rmSetAreaForestType(forestID, "mixed palm forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
      rmAddAreaConstraint(forestID, playerConstraint);
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 1);
      rmSetAreaMaxBlobs(forestID, 5);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 40.0);
      rmSetAreaCoherence(forestID, 0.0);

      if(rmBuildArea(forestID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==3)
            break;
      }
      else
         failCount=0;
   }

   // Text
   rmSetStatusText("",0.80);

   // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 3, 4.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmAddObjectDefConstraint(grassID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   int rockID=rmCreateObjectDef("rock and grass");
   int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
   rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
   rmAddObjectDefItem(rockID, "grass", 2, 1.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID, avoidRock);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers);

   // Text
   rmSetStatusText("",0.90);

   int bushID2=rmCreateObjectDef("bush group");
   rmAddObjectDefItem(bushID2, "bush", 1, 0.0);
   rmSetObjectDefMinDistance(bushID2, 0.0);
   rmSetObjectDefMaxDistance(bushID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bushID2, avoidAll);
   rmAddObjectDefConstraint(bushID2, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(bushID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers); 







   // Text
   rmSetStatusText("",1.00);


}



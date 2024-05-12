// KOTH

void main(void)
{

  // Text
   rmSetStatusText("",0.01);

// Define triggers

for(i=1; <cNumberPlayers)
{
   rmCreateTrigger("StartCountdown"+i);
   rmCreateTrigger("CountdownWarning"+i);
   rmCreateTrigger("CriticalCountdownWarning"+i);
   rmCreateTrigger("StopCountdown"+i);
   rmCreateTrigger("Victory"+i);
}

  

// Start countdown when Player has Vault
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("StartCountdown"+i));
   rmSetTriggerActive(true);

   rmAddTriggerCondition("Player Unit Count");
   rmSetTriggerConditionParamInt("PlayerID", i);
   rmSetTriggerConditionParam("ProtoUnit", "Plenty Vault KOTH");
   rmSetTriggerConditionParam("Op", ">");
   rmSetTriggerConditionParamInt("Count", 0);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   //rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" has captured the Plenty Vault! Countdown begins!");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22593)}");

   rmAddTriggerEffect("Sound Filename");
   rmSetTriggerEffectParam("Sound", "Fanfare.wav");

   rmAddTriggerEffect("Counter:Add Timer");
   rmSetTriggerEffectParam("Name", "victoryCounter"+i);
   rmSetTriggerEffectParamInt("Start",480);
   rmSetTriggerEffectParamInt("Stop",120);
   //rmSetTriggerEffectParam("Msg", "Time until "+rmGetPlayerName(i)+" is King of the Hill");
   //rmSetTriggerEffectParam("Msg", "<color=" +  "\\\"   +  "\""  +"{playerColor(i)}"+"\\"+"\""+">{PlayerNameString(i,22594)}");
   rmSetTriggerEffectParam("Msg", "{PlayerIDNameString(" + i + ",22594)}");
   rmSetTriggerEffectParamInt("Event", rmTriggerID("CountdownWarning"+i));

   rmAddTriggerEffect("Fire Event");
   rmSetTriggerEffectParamInt("EventID", rmTriggerID("StopCountdown"+i));
}

// Warn players when Countdown = 2 minutes
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("CountdownWarning"+i));
   rmSetTriggerActive(false);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   //rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" will win the game in 2 minutes, if the Plenty Vault is not claimed.");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22595)}");

   rmAddTriggerEffect("Sound Filename");
   rmSetTriggerEffectParam("Sound", "Fanfare.wav");

   rmAddTriggerEffect("Counter:Add Timer");
   rmSetTriggerEffectParam("Name", "victoryCounter2"+i);
   rmSetTriggerEffectParamInt("Start",120);
   rmSetTriggerEffectParamInt("Stop",30);
   //rmSetTriggerEffectParam("Msg", "Time until "+rmGetPlayerName(i)+" is King of the Hill");
   rmSetTriggerEffectParam("Msg", "{PlayerIDNameString(" + i + ",22594)}");
   rmSetTriggerEffectParamInt("Event", rmTriggerID("CriticalCountdownWarning"+i));
}

// Warn players when Countdown = 30 seconds
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("CriticalCountdownWarning"+i));
   rmSetTriggerActive(false);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   //rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" will win the game in 30 seconds, if the Plenty Vault is not claimed.");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22596)}");

   rmAddTriggerEffect("Sound Filename");
   rmSetTriggerEffectParam("Sound", "Fanfare.wav");

   rmAddTriggerEffect("Counter:Add Timer");
   rmSetTriggerEffectParam("Name", "victoryCounter3"+i);
   rmSetTriggerEffectParamInt("Start",30);
   rmSetTriggerEffectParamInt("Stop",0);
   //rmSetTriggerEffectParam("Msg", "Time until "+rmGetPlayerName(i)+" is King of the Hill");
   rmSetTriggerEffectParam("Msg", "{PlayerIDNameString(" + i + ",22594)}");
   rmSetTriggerEffectParamInt("Event", rmTriggerID("Victory"+i));
}

// Stop countdown when Player loses Vault
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("StopCountdown"+i));
   rmSetTriggerActive(false);

   rmAddTriggerCondition("Player Unit Count");
   rmSetTriggerConditionParamInt("PlayerID", i);
   rmSetTriggerConditionParam("ProtoUnit", "Plenty Vault KOTH");
   rmSetTriggerConditionParam("Op", "<");
   rmSetTriggerConditionParamInt("Count", 1);

   rmAddTriggerEffect("Counter Stop");
   rmSetTriggerEffectParam("Name", "victoryCounter"+i);

   rmAddTriggerEffect("Counter Stop");
   rmSetTriggerEffectParam("Name", "victoryCounter2"+i);

   rmAddTriggerEffect("Counter Stop");
   rmSetTriggerEffectParam("Name", "victoryCounter3"+i);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   //rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" has lost control of the Plenty Vault!");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22597)}");

   rmAddTriggerEffect("Fire Event");
   rmSetTriggerEffectParamInt("EventID", rmTriggerID("StartCountdown"+i));
}

// Declare Victory when countdown done
for(i=1; <cNumberPlayers)
{
   rmSwitchToTrigger(rmTriggerID("Victory"+i));
   rmSetTriggerActive(false);

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   //rmSetTriggerEffectParam("Message", rmGetPlayerName(i)+" is the King of the Hill and wins the game! ");
   rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22598)}");

   rmAddTriggerEffect("Sound Filename");
   rmSetTriggerEffectParam("Sound", "Fanfare.wav");

   rmAddTriggerEffect("Set Player Won");
   rmSetTriggerEffectParamInt("Player", i);
}

// Enable resouces for Plenty Vault
   rmCreateTrigger("Enable Vault");
   rmSetTriggerActive(true);   

   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1",30);
   
for(i=1; <cNumberPlayers)
{
   rmAddTriggerEffect("Set Tech Status");
   rmSetTriggerEffectParamInt("PlayerID", i);
   rmSetTriggerEffectParam("TechID", "378");
   rmSetTriggerEffectParam("Status", "4");
}

// ----------------------------------------------DONE WITH TRIGGERS------------------------------

// Main entry point for random map script


   // Set size.

   int playerTiles=7500;
   if(cMapSize == 1)
   {
      playerTiles = 9750;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   /* determine which terrain the map uses */
   float terrainType = rmRandFloat(0, 1);
   int terrainChance = 0;
   /* Greek = 0, Egyptian = 1, Norse = 2 */

   if(terrainType < 0.4)
   {
      terrainChance = 0;      
      rmEchoInfo("terrain type "+terrainType+" terrain chance "+terrainChance+ " Greek");
   }
   else if(terrainType < 0.6)
   {
      terrainChance = 1;
      rmEchoInfo("terrain type "+terrainType+" terrain chance "+terrainChance+ " Egyptian");
   }
   else
   {
      terrainChance = 2;
      rmEchoInfo("terrain type "+terrainType+" terrain chance "+terrainChance+ " Norse");
   }

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map
   rmSetSeaType("red sea");

   if(terrainChance == 0) 
      rmTerrainInitialize("GrassA");
   else if(terrainChance == 2)
      rmTerrainInitialize("SnowA");
   else
      rmTerrainInitialize("SandB");
      
   rmSetGaiaCiv(cCivZeus);
 

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classPlayerCore=rmDefineClass("player core");
   rmDefineClass("corner");
   int classPatch=rmDefineClass("patch");
   rmDefineClass("center");
   rmDefineClass("starting settlement");
   int avoidIce = 0;


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
   
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
   int patchConstraint=rmCreateClassDistanceConstraint("avoid patch", classPatch, 10.0);

   // Center constraint.
   int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 15.0);
   int patchCenterConstraint=rmCreateClassDistanceConstraint("patch don't mess up center", rmClassID("center"), 30.0);


   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 25.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 22.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);


   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int shortAvoidBuildings=rmCreateTypeDistanceConstraint("short avoid buildings", "Building", 10.0);
  
   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   // towers avoid other towers
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTowerID, 22.0);
   rmSetObjectDefMaxDistance(startingTowerID, 28.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);
   if(avoidIce==1)
      rmAddObjectDefConstraint(startingTowerID, centerConstraint);
   
   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);
   if(avoidIce==1)
      rmAddObjectDefConstraint(startingGoldID, centerConstraint);


   // pigs
   float pigNumber=rmRandFloat(2, 4);
   int closePigsID=rmCreateObjectDef("close pigs");
   rmAddObjectDefItem(closePigsID, "pig", pigNumber, 2.0);
   rmSetObjectDefMinDistance(closePigsID, 25.0);
   rmSetObjectDefMaxDistance(closePigsID, 30.0);
   rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closePigsID, avoidFood);
   
   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(6,9), 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   if(avoidIce==1)
      rmAddObjectDefConstraint(closeChickensID, centerConstraint);

   int closeBoarID=rmCreateObjectDef("close Boar");
   if(terrainChance == 1)
      rmAddObjectDefItem(closeBoarID, "rhinocerous", 2, 4.0);
   else
      rmAddObjectDefItem(closeBoarID, "boar", 3, 4.0);
   rmSetObjectDefMinDistance(closeBoarID, 40.0);
   rmSetObjectDefMaxDistance(closeBoarID, 60.0);
   rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);
   if(avoidIce==1)
      rmAddObjectDefConstraint(closeBoarID, centerConstraint);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   if(terrainChance == 1)
      rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
   if(terrainChance == 1)
      rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
   else
      rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   if(avoidIce==1)
      rmAddObjectDefConstraint(stragglerTreeID, centerConstraint);


   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, centerConstraint);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
   if(avoidIce==1)
      rmAddObjectDefConstraint(mediumGoldID, centerConstraint);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(1,2), 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 60.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 80.0);
   rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumPigsID, avoidHerdable);
   rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);

   // player fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int playerFishID=rmCreateObjectDef("owned fish");
   rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 10.0);
   rmSetObjectDefMinDistance(playerFishID, 0.0);
   rmSetObjectDefMaxDistance(playerFishID, 100.0);
   rmAddObjectDefConstraint(playerFishID, fishVsFishID);
   rmAddObjectDefConstraint(playerFishID, fishLand);
   
   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 70.0);
   rmSetObjectDefMaxDistance(farGoldID, 160.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, centerConstraint);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   // pigs avoid TCs and other herds, since this map places a lot of pigs
   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   if(terrainChance == 1)
      rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
   
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farBerriesID, centerConstraint);
   
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(terrainChance == 0)
      rmAddObjectDefItem(bonusHuntableID, "deer", 6, 3.0);
   else if(terrainChance == 1)
      rmAddObjectDefItem(bonusHuntableID, "zebra", 6, 3.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "caribou", 6, 3.0);        
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidBuildings);
   rmAddObjectDefConstraint(bonusHuntableID, centerConstraint);

   int randomTreeID=rmCreateObjectDef("random tree");
   if(terrainChance == 0)
      rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
   else if(terrainChance == 1)
      rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   else
      rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
   if(terrainChance == 2)
      rmAddObjectDefConstraint(randomTreeID, centerConstraint);

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
   rmAddObjectDefConstraint(relicID, centerConstraint);

   // ------------------------------------------------------------------------Done defining objects

   // Cheesy "circular" placement of players.
   rmSetTeamSpacingModifier(0.75);
   rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));


   // Determine center
   int centerID=rmCreateArea("center");
   rmSetAreaLocation(centerID, 0.5, 0.5);
   if(terrainChance == 2)
   {
      rmSetAreaTerrainType(centerID,"IceA");
      rmSetAreaBaseHeight(centerID, 0.0);
      rmSetAreaSize(centerID, 0.20, 0.20);
      avoidIce = 1;
   }
   else if(terrainChance == 1)
   {
      rmSetAreaWaterType(centerID, "red sea");
      rmSetAreaBaseHeight(centerID, 0.0);
      rmSetAreaSize(centerID, 0.25, 0.25);

   }
   else
   {
      rmSetAreaCliffType(centerID, "Greek");
      rmSetAreaCliffEdge(centerID, 4, 0.20, 0.2, 1.0, 1);
      rmSetAreaCliffPainting(centerID, false, true, true, 1.5, true);
      rmSetAreaCliffHeight(centerID, 7, 1.0, 0.5);
      if(cNumberNonGaiaPlayers < 3)
         rmSetAreaSize(centerID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(300));
      else if(cNumberNonGaiaPlayers < 5)
         rmSetAreaSize(centerID, rmAreaTilesToFraction(1600), rmAreaTilesToFraction(1600));
      if(cNumberNonGaiaPlayers < 7)
         rmSetAreaSize(centerID, rmAreaTilesToFraction(2200), rmAreaTilesToFraction(2200));
      else
         rmSetAreaSize(centerID, rmAreaTilesToFraction(2400), rmAreaTilesToFraction(2400));

   }
   rmAddAreaToClass(centerID, rmClassID("center"));
   rmSetAreaMinBlobs(centerID, 8);
   rmSetAreaMaxBlobs(centerID, 10);
   rmSetAreaMinBlobDistance(centerID, 10);
   rmSetAreaMaxBlobDistance(centerID, 20);
   rmSetAreaSmoothDistance(centerID, 50);
   rmSetAreaCoherence(centerID, 0.25);
   rmBuildArea(centerID); 

   // monkey island
   if(terrainChance == 1)
   {
      int sandIslandID=rmCreateArea("sandisland");
      rmSetAreaSize(sandIslandID, rmAreaTilesToFraction(600), rmAreaTilesToFraction(600));
      rmSetAreaLocation(sandIslandID, 0.5, 0.5);
      rmSetAreaTerrainType(sandIslandID, "SandC");
      rmSetAreaBaseHeight(sandIslandID, 1.0);
      rmSetAreaSmoothDistance(sandIslandID, 10);
      rmSetAreaHeightBlend(sandIslandID, 2);
      rmSetAreaCoherence(sandIslandID, 1.0);
      rmBuildArea(sandIslandID);
   }

   if(terrainChance == 2)
   {
      int snowIslandID=rmCreateArea("snowisland");
      rmSetAreaSize(snowIslandID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(80));
      rmSetAreaLocation(snowIslandID, 0.5, 0.5);
      rmSetAreaTerrainType(snowIslandID, "SnowA");
      rmSetAreaBaseHeight(snowIslandID, 1.0);
      rmSetAreaSmoothDistance(snowIslandID, 10);
      rmSetAreaHeightBlend(snowIslandID, 2);
      rmSetAreaCoherence(snowIslandID, 1.0);
      rmBuildArea(snowIslandID);
   }

   int vaultID=rmCreateObjectDef("Vault");
   rmAddObjectDefItem(vaultID, "plenty vault koth", 1, 0.0);
   rmSetObjectDefMinDistance(vaultID, 0.0);
   rmSetObjectDefMinDistance(vaultID, 0.0);
   rmPlaceObjectDefAtLoc(vaultID, 0, 0.5, 0.5);

    // Ruins
   int ruinID=0;
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
  /* int stayInRuins=rmCreateEdgeDistanceConstraint("stay in ruins", ruinID, 4.0); */

   ruinID=rmCreateArea("ruins");
   rmSetAreaSize(ruinID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(300));
   rmSetAreaLocation(ruinID, 0.5, 0.5);
   if(terrainChance == 0)
   {
      rmSetAreaTerrainType(ruinID, "GreekRoadA");
      rmAddAreaTerrainLayer(ruinID, "GrassDirt25", 0, 1);
   }
   else if(terrainChance == 1)
   {
      rmSetAreaTerrainType(ruinID, "EgyptianRoadA");
   }
   rmSetAreaMinBlobs(ruinID, 1);
   rmSetAreaMaxBlobs(ruinID, 1);
   rmSetAreaCoherence(ruinID, 0.8);
   rmSetAreaSmoothDistance(ruinID, 10);
   rmBuildArea(ruinID);

   int shadeID=rmCreateObjectDef("shade "+i);
   rmAddObjectDefItem(shadeID, "shade of erebus", 1, 0.0);
   rmSetObjectDefMinDistance(shadeID, 0.0);
   rmSetObjectDefMaxDistance(shadeID, 0.0);
   rmPlaceObjectDefInArea(shadeID, 0, rmAreaID("ruins"), 6);
   
   for(i=0; < rmRandInt(3,6))
   {
      int brokenRuinID=rmCreateObjectDef("ruins "+i);
      rmAddObjectDefItem(brokenRuinID, "ruins", 1, 0.0);
      rmSetObjectDefMinDistance(brokenRuinID, 0.0);
      rmSetObjectDefMaxDistance(brokenRuinID, 0.0);
      rmAddObjectDefConstraint(brokenRuinID, shortAvoidBuildings);
      rmAddObjectDefConstraint(brokenRuinID, avoidAll);
      if(terrainChance < 2)
         rmPlaceObjectDefInArea(brokenRuinID, 0, rmAreaID("ruins"), 1);
   }

   for(i=0; < rmRandInt(4,8))
   {
      int columnID=rmCreateObjectDef("columns "+i);
      rmAddObjectDefItem(columnID, "columns broken", 1, 0.0);
      rmSetObjectDefMinDistance(columnID, 0.0);
      rmSetObjectDefMaxDistance(columnID, 0.0);
      rmAddObjectDefConstraint(columnID, shortAvoidBuildings);
      rmAddObjectDefConstraint(columnID, avoidAll);
      if(terrainChance < 2)
         rmPlaceObjectDefInArea(columnID, 0, rmAreaID("ruins"), 1);
   }

   for(i=0; < 12)
   {
      int skeletonID=rmCreateObjectDef("skeleton "+i);
      rmAddObjectDefItem(skeletonID, "skeleton", 1, 0.0);
      rmSetObjectDefMinDistance(skeletonID, 0.0);
      rmSetObjectDefMaxDistance(skeletonID, 0.0);
      rmPlaceObjectDefInArea(skeletonID, 0, rmAreaID("ruins"), 1);
   }




       
  // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(2000);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);

      rmSetAreaMinBlobs(id, 4);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobDistance(id, 30.0);
      rmSetAreaMaxBlobDistance(id, 50.0);
      rmSetAreaSmoothDistance(id, 20);
      rmSetAreaCoherence(id, 0.20);
      rmSetAreaBaseHeight(id, 0.0); 
      rmSetAreaHeightBlend(id, 2);
      rmAddAreaConstraint(id, playerConstraint);
      rmAddAreaConstraint(id, centerConstraint);
      rmSetAreaLocPlayer(id, i);
      if(terrainChance == 0)
         rmSetAreaTerrainType(id, "GrassDirt25");
      else if(terrainChance == 2)
      {
         rmSetAreaTerrainType(id, "GrassA");
         rmAddAreaTerrainLayer(id, "SnowGrass75", 5, 8);
         rmAddAreaTerrainLayer(id, "SnowGrass50", 2, 5);
         rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 2);
      }
      else
      {
         rmSetAreaTerrainType(id, "GrassDirt25");
         rmAddAreaTerrainLayer(id, "GrassDirt50", 2, 5);
         rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 2);
      }
   }

   // Build the areas.
   rmBuildAllAreas();

   // Text
   rmSetStatusText("",0.20);

   int failCount=0;
   for(i=1; <cNumberPlayers*4)
   {
      // Beautification sub area.
      int id2=rmCreateArea("large patch "+i);
      rmSetAreaSize(id2, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
      if(terrainChance == 0)
         rmSetAreaTerrainType(id2, "GrassDirt50");
      else if(terrainChance == 1)
      {
         rmSetAreaTerrainType(id2, "GrassDirt50");
         rmAddAreaTerrainLayer(id2, "GrassDirt75", 0, 3);
      }
      else
      {
         rmSetAreaTerrainType(id2, "SnowGrass50");
         rmAddAreaTerrainLayer(id2, "SnowGrass25", 0, 3);
      }
      rmAddAreaToClass(id2, classPatch);
      rmAddAreaConstraint(id2, patchConstraint);
      rmAddAreaConstraint(id2, patchCenterConstraint);
      rmAddAreaConstraint(id2, playerConstraint);
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);
      if(rmBuildArea(id2)==false)
      {
         // Stop trying once we fail 20 times in a row.
         failCount++;
         if(failCount==20)
            break;
      }
      else
         failCount=0;
   }

   failCount=0;
   for(i=1; <cNumberPlayers*8)
   {
      // Beautification sub area.
      int id3=rmCreateArea("small patch "+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
      if(terrainChance == 0)
         rmSetAreaTerrainType(id3, "GrassDirt25");
      else if(terrainChance == 1)
         rmSetAreaTerrainType(id3, "SandD");
      else
         rmSetAreaTerrainType(id3, "SnowB");
      rmAddAreaToClass(id3, classPatch);
      rmAddAreaConstraint(id3, patchConstraint);
      rmAddAreaConstraint(id3, playerConstraint);
      rmAddAreaConstraint(id3, patchCenterConstraint);
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.0);

      if(rmBuildArea(id3)==false)
      {
         // Stop trying once we fail 20 times in a row.
         failCount++;
         if(failCount==20)
            break;
      }
      else
         failCount=0;

   }


   // prettier ice if Norse
   for(i=1; <cNumberPlayers*6)
   {
      int icePatch=rmCreateArea("more ice terrain"+i, centerID);
      rmSetAreaSize(icePatch, 0.01, 0.02);
      rmSetAreaTerrainType(icePatch, "IceB");
      rmAddAreaTerrainLayer(icePatch, "IceA", 0, 3);
      rmSetAreaCoherence(icePatch, 0.0);
      if(terrainChance == 2)
         rmBuildArea(icePatch);
   }      
   
   // Fish if Egyptian
   if(terrainChance == 1)
   {

      rmPlaceObjectDefPerPlayer(playerFishID, false);


      int fishID=rmCreateObjectDef("fish");
      rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
      rmSetObjectDefMinDistance(fishID, 0.0);
      rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(fishID, fishVsFishID);
      rmAddObjectDefConstraint(fishID, fishLand);
      rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

      fishID=rmCreateObjectDef("fish2");
      rmAddObjectDefItem(fishID, "fish - perch", 2, 6.0);
      rmSetObjectDefMinDistance(fishID, 0.0);
      rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(fishID, fishVsFishID);
      rmAddObjectDefConstraint(fishID, fishLand);
      rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1*cNumberNonGaiaPlayers);
   
      int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 30.0);
      int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 30.0);
      int sharkID=rmCreateObjectDef("shark");
      rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
      rmSetObjectDefMinDistance(sharkID, 0.0);
      rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(sharkID, sharkVssharkID);
      rmAddObjectDefConstraint(sharkID, sharkLand);
      rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, 0.5*cNumberNonGaiaPlayers);
   }

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Elev.
   int numTries=6*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, centerConstraint);

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

   // Slight Elevation
   numTries=7*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, centerConstraint);
      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 10 times in a row.
         failCount++;
         if(failCount==10)
            break;
      }
      else
         failCount=0;
   } 
   // Settlements.
   //rmPlaceObjectDefPerPlayer(farSettlementID, true, 2);
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10);
   rmAddFairLocConstraint(id, centerConstraint);

   id=rmAddFairLoc("Settlement", true, false, 70, 120, 60, 10);
   rmAddFairLocConstraint(id, centerConstraint);

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
            rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
      }
   }

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
   
   // Text
   rmSetStatusText("",0.40);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Goats
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   //Chickens
   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   // Pigs
   rmPlaceObjectDefPerPlayer(mediumPigsID, false, 2);
  
   // Far things.
   
   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, 3);

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 
   
   // Text
   rmSetStatusText("",0.60);

   // Pigs
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(farPigsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 3);

   // Bonus huntable.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers/2);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   // Text
   rmSetStatusText("",0.80);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(forestID, false);
      if(terrainChance == 0)
         rmSetAreaForestType(forestID, "oak forest");
      else if(terrainChance == 2)
         rmSetAreaForestType(forestID, "mixed pine forest");
      else
         rmSetAreaForestType(forestID, "mixed palm forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, centerConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
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
   rmSetStatusText("",0.90);

   // Grass
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 3, 4.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmAddObjectDefConstraint(grassID, avoidImpassableLand);
   if(terrainChance == 0)
      rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   int rockID=rmCreateObjectDef("rock and grass");
   int avoidRock0=rmCreateTypeDistanceConstraint("avoid rock 0", "rock limestone sprite", 8.0);
   int avoidRock1=rmCreateTypeDistanceConstraint("avoid rock 1", "rock sandstone sprite", 8.0);
   int avoidRock2=rmCreateTypeDistanceConstraint("avoid rock 2", "rock granite sprite", 8.0);

   if(terrainChance == 0) /* Greek */
      rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
   else if(terrainChance == 1) /* E */
      rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 1.0);
   else
      rmAddObjectDefItem(rockID, "rock granite sprite", 1, 1.0);
   rmAddObjectDefItem(rockID, "grass", 2, 1.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID, avoidRock0);
   rmAddObjectDefConstraint(rockID, avoidRock1);
   rmAddObjectDefConstraint(rockID, avoidRock2);
   if(terrainChance == 2)
      rmAddObjectDefConstraint(rockID, centerConstraint);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers);

   int rockID2=rmCreateObjectDef("rock group");
   if(terrainChance == 0) /* Greek */
      rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
   else if(terrainChance == 1) /* E */
      rmAddObjectDefItem(rockID2, "rock sandstone sprite", 3, 2.0);
   else
      rmAddObjectDefItem(rockID2, "rock granite sprite", 3, 2.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, avoidRock0);
   rmAddObjectDefConstraint(rockID2, avoidRock1);
   rmAddObjectDefConstraint(rockID2, avoidRock2);
   if(terrainChance == 2)
      rmAddObjectDefConstraint(rockID2, centerConstraint); 
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);


   // Text
   rmSetStatusText("",1.00);
}  





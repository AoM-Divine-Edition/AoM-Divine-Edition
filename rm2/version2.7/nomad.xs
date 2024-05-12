// Main entry point for random map script

// Giant features implemented by Hagrit


void main(void)

{

   // Text
   rmSetStatusText("",0.10);

   for(i=1; <cNumberPlayers)
   {
      rmCreateTrigger("disableTechs"+i);
   }

   // disable starting units
   for(i=1; <cNumberPlayers)
   {
      rmSwitchToTrigger(rmTriggerID("disableTechs"+i));
      rmSetTriggerActive(true);

/* 0 = unobtainable, 1 = available, 2 = obtainable, 3 = obtainable, 4 = active */

      if(rmGetPlayerCulture(i) == cCultureGreek) 
      {
         rmAddTriggerEffect("Set Tech Status");
         rmSetTriggerEffectParamInt("PlayerID", i);
         rmSetTriggerEffectParam("TechID", "144");
         rmSetTriggerEffectParam("Status", "0"); /* unobtainable */

      }

      if(rmGetPlayerCulture(i) == cCultureNorse) 
      {
         rmAddTriggerEffect("Set Tech Status");
         rmSetTriggerEffectParamInt("PlayerID", i);
         rmSetTriggerEffectParam("TechID", "143");
         rmSetTriggerEffectParam("Status", "0");
      }   

      if(rmGetPlayerCulture(i) == cCultureEgyptian) 
      {
         rmAddTriggerEffect("Set Tech Status");
         rmSetTriggerEffectParamInt("PlayerID", i);
         rmSetTriggerEffectParam("TechID", "145");
         rmSetTriggerEffectParam("Status", "0");
      }
	  
	  if(rmGetPlayerCulture(i) == cCultureAtlantean) 
      {
         rmAddTriggerEffect("Set Tech Status");
         rmSetTriggerEffectParamInt("PlayerID", i);
         rmSetTriggerEffectParam("TechID", "394");
         rmSetTriggerEffectParam("Status", "0");
      }
	  
	  if(rmGetPlayerCulture(i) == cCultureChinese) 
      {
         rmAddTriggerEffect("Set Tech Status");
         rmSetTriggerEffectParamInt("PlayerID", i);
         rmSetTriggerEffectParam("TechID", "510");
         rmSetTriggerEffectParam("Status", "0");
      }

      if(rmGetPlayerCiv(i) == cCivThor) 
      {
         rmAddTriggerEffect("Set Tech Status");
         rmSetTriggerEffectParamInt("PlayerID", i);
         rmSetTriggerEffectParam("TechID", "379");
         rmSetTriggerEffectParam("Status", "0");
      }

      // Build TCs faster
      rmAddTriggerEffect("Set Tech Status");
      rmSetTriggerEffectParamInt("PlayerID", i);
      rmSetTriggerEffectParam("TechID", "386");
      rmSetTriggerEffectParam("Status", "4"); /* active */
      rmEchoInfo("Build TC faster");

   }

   
   rmCreateTrigger("Prevent Fighting");
   rmSetTriggerActive(true);

   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1", 1);

   rmAddTriggerEffect("Grant God Power");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   rmSetTriggerEffectParam("PowerName", "cease fire nomad");
   rmSetTriggerEffectParamInt("Count", 1);

   rmAddTriggerEffect("Invoke God Power");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   rmSetTriggerEffectParam("PowerName", "cease fire nomad");
   rmSetTriggerEffectParam("DstPoint1", "1,1,1");

   rmAddTriggerEffect("Send Chat");
   rmSetTriggerEffectParamInt("PlayerID", 0);
   rmSetTriggerEffectParam("Message", "{22556}");

   rmCreateTrigger("Dawn");
   rmCreateTrigger("Day");

   rmSwitchToTrigger(rmTriggerID("Dawn"));
   rmSetTriggerActive(true);
   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1", 60);
   rmAddTriggerEffect("Set Lighting");
   rmSetTriggerEffectParam("SetName", "Dawn");
   rmSetTriggerEffectParamInt("FadeTime", 30);
   rmAddTriggerEffect("Fire Event");
   rmSetTriggerEffectParamInt("EventID", rmTriggerID("Day"));

   rmSwitchToTrigger(rmTriggerID("Day"));
   rmSetTriggerActive(false);
   rmAddTriggerCondition("Timer");
   rmSetTriggerConditionParamInt("Param1", 120);
   rmAddTriggerEffect("Set Lighting");
   rmSetTriggerEffectParam("SetName", "Default");
   rmSetTriggerEffectParamInt("FadeTime", 30);


// ------------------------------------ END TRIGGERS -----------------------------------

   // Set size.
   int mapSizeMultiplier = 1;
	int playerTiles=9000;
	if(cMapSize == 1){
		playerTiles = 11700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 23400;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmSetSeaType("Red Sea");
   rmTerrainInitialize("water");
   rmSetLightingSet("night");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   int classCliff=rmDefineClass("cliff");
   int classPatch=rmDefineClass("patch");

   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, size*0.05);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int mediumAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by medium distance", "AbstractSettlement", 30.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 28.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 6.0);
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 50.0);
   int shortCliffConstraint=rmCreateClassDistanceConstraint("elev v cliff", rmClassID("cliff"), 10.0);
   int avoidStartingUnits=rmCreateTypeDistanceConstraint("avoid starting units", "unit", 40);
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);

   int patchVsPatchConstraint=rmCreateClassDistanceConstraint("patch avoid patch", classPatch, 10.0);

  
   // -------------Define objects
 // Close Objects

   // Starting units
   int VillagerGreekID=rmCreateObjectDef("Villager Greek");
   rmAddObjectDefItem(VillagerGreekID, "Villager Greek", 1, 0.0);
   rmSetObjectDefMinDistance(VillagerGreekID, 0.0);
   rmSetObjectDefMaxDistance(VillagerGreekID, rmXFractionToMeters(0.25));
   rmAddObjectDefConstraint(VillagerGreekID, shortCliffConstraint);
   rmAddObjectDefConstraint(VillagerGreekID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(VillagerGreekID, avoidStartingUnits);

   int VillagerNorseID=rmCreateObjectDef("Villager norse");
   rmAddObjectDefItem(VillagerNorseID, "Villager norse", 1, 0.0);
   rmSetObjectDefMinDistance(VillagerNorseID, 0.0);
   rmSetObjectDefMaxDistance(VillagerNorseID, rmXFractionToMeters(0.25));
   rmAddObjectDefConstraint(VillagerNorseID, shortCliffConstraint);
   rmAddObjectDefConstraint(VillagerNorseID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(VillagerNorseID, avoidStartingUnits);

   int VillagerEgyptianID=rmCreateObjectDef("Villager Egyptian");
   rmAddObjectDefItem(VillagerEgyptianID, "Villager Egyptian", 1, 0.0);
   rmSetObjectDefMinDistance(VillagerEgyptianID, 0.0);
   rmSetObjectDefMaxDistance(VillagerEgyptianID, rmXFractionToMeters(0.25));
   rmAddObjectDefConstraint(VillagerEgyptianID, shortCliffConstraint);
   rmAddObjectDefConstraint(VillagerEgyptianID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(VillagerEgyptianID, avoidStartingUnits);

	int VillagerAtlanteanID=rmCreateObjectDef("Villager Atlantean");
   rmAddObjectDefItem(VillagerAtlanteanID, "Villager Atlantean", 1, 0.0);
   rmSetObjectDefMinDistance(VillagerAtlanteanID, 0.0);
   rmSetObjectDefMaxDistance(VillagerAtlanteanID, rmXFractionToMeters(0.25));
   rmAddObjectDefConstraint(VillagerAtlanteanID, shortCliffConstraint);
   rmAddObjectDefConstraint(VillagerAtlanteanID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(VillagerAtlanteanID, avoidStartingUnits);

	int VillagerChineseID=rmCreateObjectDef("Villager Chinese");
	rmAddObjectDefItem(VillagerChineseID, "Villager Chinese", 1, 0.0);
	rmSetObjectDefMinDistance(VillagerChineseID, 0.0);
	rmSetObjectDefMaxDistance(VillagerChineseID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(VillagerChineseID, shortCliffConstraint);
	rmAddObjectDefConstraint(VillagerChineseID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(VillagerChineseID, avoidStartingUnits);

   int PriestID=rmCreateObjectDef("Priest");
   rmAddObjectDefItem(PriestID, "Priest", 1, 0.0);
   rmSetObjectDefMinDistance(PriestID, 0.0);
   rmSetObjectDefMaxDistance(PriestID, rmXFractionToMeters(0.25));
   rmAddObjectDefConstraint(PriestID, shortCliffConstraint);
   rmAddObjectDefConstraint(PriestID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(PriestID, avoidStartingUnits);

   int UlfsarkID=rmCreateObjectDef("Ulfsark");
   rmAddObjectDefItem(UlfsarkID, "Ulfsark", 1, 0.0);
   rmSetObjectDefMinDistance(UlfsarkID, 0.0);
   rmSetObjectDefMaxDistance(UlfsarkID, rmXFractionToMeters(0.25));
   rmAddObjectDefConstraint(UlfsarkID, shortCliffConstraint);
   rmAddObjectDefConstraint(UlfsarkID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(UlfsarkID, avoidStartingUnits);
   
   // Far Objects

   // Settlement avoids gold, Settlements
   int farSettlementID=rmCreateObjectDef("far settlement");
   rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
   rmSetObjectDefMaxDistance(farSettlementID, rmAreaFractionToTiles(1.0));
   rmAddObjectDefConstraint(farSettlementID, edgeConstraint);
   rmAddObjectDefConstraint(farSettlementID, farAvoidSettlement);
   rmAddObjectDefConstraint(farSettlementID, shortAvoidImpassableLand);
         
   // gold avoids gold
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);

   // gold avoids gold, Settlements and TCs
   int farGold2ID=rmCreateObjectDef("far gold 2");
   rmAddObjectDefItem(farGold2ID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGold2ID, 80.0);
   rmSetObjectDefMaxDistance(farGold2ID, 150.0);
   rmAddObjectDefConstraint(farGold2ID, avoidGold);
   rmAddObjectDefConstraint(farGold2ID, avoidImpassableLand);

   // goats avoid TCs 
   int farGoatsID=rmCreateObjectDef("far goats");
   rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoatsID, avoidAll);
   
   // Berries  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(farBerriesID, avoidAll);
   
   // This map will either use zebra or giraffe as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandFloat(5, 8), 3.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandFloat(3, 5), 2.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, avoidAll);

   // hunted 2 avoids hunted and TCs
   int bonusHuntable2ID=rmCreateObjectDef("second bonus huntable");
   float bonusChance2=rmRandFloat(0, 1);
   if(bonusChance2<0.5)   
      rmAddObjectDefItem(bonusHuntable2ID, "elephant", 2, 2.0);
   else
      rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 2, 2.0);
   rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidAll);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);

   int randomtree2ID=rmCreateObjectDef("random tree two");
   rmAddObjectDefItem(randomtree2ID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomtree2ID, 0.0);
   rmSetObjectDefMaxDistance(randomtree2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomtree2ID, rmCreateTypeDistanceConstraint("random tree 2", "all", 4.0));
   rmAddObjectDefConstraint(randomtree2ID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomtree2ID, avoidImpassableLand);

   // Monkeys avoid TCs  
   int farMonkeyID=rmCreateObjectDef("far monkeys");
   rmAddObjectDefItem(farMonkeyID, "baboon", 8, 2.0);
   rmSetObjectDefMinDistance(farMonkeyID, 0.0);
   rmSetObjectDefMaxDistance(farMonkeyID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farMonkeyID, avoidImpassableLand);

   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
   
   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 60.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, avoidImpassableLand);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, shortAvoidSettlement);

   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 20.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);

   int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
   int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
   int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
   int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);

   int sharkID=rmCreateObjectDef("shark");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
   else
      rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
   rmSetObjectDefMinDistance(sharkID, 0.0);
   rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(sharkID, sharkVssharkID);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
   rmAddObjectDefConstraint(sharkID, sharkLand);
   rmAddObjectDefConstraint(sharkID, edgeConstraint);




   // -------------Done defining objects


   rmSetTeamSpacingModifier(0.75);
   rmPlacePlayersCircular(0.2, 0.4, rmDegreesToRadians(4.0));

      // Text
   rmSetStatusText("",0.20);

   // Grow a big continent.
   int centerID=rmCreateArea("center");
   float direction = rmRandFloat(0, 1);
   rmSetAreaSize(centerID, 0.55, 0.60);

   if(direction<0.25)
   {
      rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.05, 0.95, 1.0, 0.01));
      rmSetAreaLocation(centerID, 0.5, 0.7);
/*      rmAddAreaInfluencePoint(centerID, 0.8, 0.8); */
   }
   else if(direction<0.5)
   {
      rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.00, 0.95, 0.95, 0.01));
      rmSetAreaLocation(centerID, 0.5, 0.3);
   }
   else if(direction<0.75)
   {
      rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.05, 1.0, 0.95, 0.01));
      rmSetAreaLocation(centerID, 0.7, 0.5);
   }
   else
   {
      rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.00, 0.05, 0.95, 0.95, 0.01));
      rmSetAreaLocation(centerID, 0.3, 0.5);
   }
   rmSetAreaCoherence(centerID, 0.0);
   rmSetAreaBaseHeight(centerID, 2.0);
   rmSetAreaTerrainType(centerID, "sandB");
   rmSetAreaSmoothDistance(centerID, 10);
   rmSetAreaHeightBlend(centerID, 2);
   rmBuildArea(centerID);


   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(4000);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);

      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);

      //rmSetAreaBaseHeight(id, 4.0);

      // Add constraints.
      rmAddAreaConstraint(id, playerConstraint);
      rmAddAreaConstraint(id, edgeConstraint);


      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, "SandA");
   }

   // Build the areas.
   rmBuildAllAreas();

   // Text
   rmSetStatusText("",0.40);

   for(i=1; <cNumberPlayers*2)
   {
      // Beautification sub area.
      int id2=rmCreateArea("beaut area"+i, centerID);
      rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaTerrainType(id2, "SandD");
      rmAddAreaTerrainLayer(id2, "SandC", 1, 4);
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmAddAreaToClass(id2, classPatch);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.4);

      rmBuildArea(id2);
   }

   for(i=1; <cNumberPlayers*2*mapSizeMultiplier)
   {
      // Beautification sub area.
      int id3=rmCreateArea("beaut area deux"+i, centerID);
      rmSetAreaSize(id3, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaTerrainType(id3, "GrassDirt25");
      rmAddAreaTerrainLayer(id3, "GrassDirt50", 2, 4);
      rmAddAreaTerrainLayer(id3, "GrassDirt75", 0, 1);
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmAddAreaToClass(id3, classPatch);
      rmAddAreaConstraint(id3, patchVsPatchConstraint);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.5);

      rmBuildArea(id3);
   }

      for(i=1; <cNumberPlayers*2*mapSizeMultiplier)
   {
      // Beautification sub area.
      int id4=rmCreateArea("beaut area tres"+i, centerID);
      rmSetAreaSize(id4, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
      rmSetAreaTerrainType(id4, "SandDirt50");
      rmSetAreaMinBlobs(id4, 1);
      rmSetAreaMaxBlobs(id4, 5);
      rmAddAreaToClass(id4, classPatch);
      rmAddAreaConstraint(id4, patchVsPatchConstraint);
      rmSetAreaWarnFailure(id4, false);
      rmSetAreaMinBlobDistance(id4, 16.0);
      rmSetAreaMaxBlobDistance(id4, 40.0);
      rmSetAreaCoherence(id4, 0.5);

      rmBuildArea(id4);
   }

   // Text
   rmSetStatusText("",0.60);

   

      // Elev.
   int numTries=40*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int failCount=0;
   for(i=0; <numTries*mapSizeMultiplier)
   {
      int elevID=rmCreateArea("elev"+i, centerID);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, cornerConstraint);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SandA");
      rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 10.0));
      rmSetAreaHeightBlend(elevID, 2); 
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);


      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==3)
            break;
      }
      else
         failCount=0;
   }

   // Slight Elevation
   numTries=20*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries*mapSizeMultiplier)
   {
      elevID=rmCreateArea("wrinkle"+i, centerID);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 12 times in a row.
         failCount++;
         if(failCount==12)
            break;
      }
      else
         failCount=0;
   }


	// Settlements.
	if (cMapSize == 2)
		rmPlaceObjectDefAtLoc(farSettlementID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*5);
	else
		rmPlaceObjectDefAtLoc(farSettlementID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*3);

   // Draw cliffs

   for(i=0; <5*mapSizeMultiplier)
   {
      int cliffID=rmCreateArea("cliff"+i, centerID);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(500*mapSizeMultiplier));
      rmSetAreaCliffType(cliffID, "Egyptian");
      rmAddAreaConstraint(cliffID, cliffConstraint);
      rmAddAreaConstraint(cliffID, avoidBuildings);
      rmAddAreaConstraint(cliffID, avoidImpassableLand);
      rmAddAreaToClass(cliffID, classCliff);
      rmSetAreaMinBlobs(cliffID, 0);
      rmSetAreaMaxBlobs(cliffID, 10*mapSizeMultiplier);
      int edgeRand=rmRandInt(0,100);
      if(edgeRand<33)
      {
      // Inaccesible
         rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
         rmSetAreaTerrainType(cliffID, "cliffEgyptianA");
      }
      else
      // AOK style
      {
         rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
      }
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);


      rmSetAreaMinBlobDistance(cliffID, 20.0);
      rmSetAreaMaxBlobDistance(cliffID, 20.0*mapSizeMultiplier);
      rmSetAreaCoherence(cliffID, 0.0);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaHeightBlend(cliffID, 2); 
      rmBuildArea(cliffID);
   }


   // Close things....
   
      int playerculture = 0;

    for(i=0; <cNumberPlayers)
   {
      playerculture = rmGetPlayerCulture(i);
      rmEchoInfo("player "+i+" culture "+playerculture);      
         
   }  

   for(i=0; <cNumberPlayers)
   {
      if(rmGetPlayerCulture(i) == cCultureGreek)
         {
            rmPlaceObjectDefAtLoc(VillagerGreekID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 3);
            rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
            rmAddPlayerResource(i, "Food", 50);
            rmAddPlayerResource(i, "Wood", 300);
            rmAddPlayerResource(i, "Gold", 300);
         }
      else if(rmGetPlayerCulture(i) == cCultureEgyptian)
         {
            rmPlaceObjectDefAtLoc(VillagerEgyptianID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 4);
            rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
            rmAddPlayerResource(i, "Food", 50);
            rmAddPlayerResource(i, "Gold", 400);
         }
      else if(rmGetPlayerCulture(i) == cCultureNorse)
         {
            rmPlaceObjectDefAtLoc(UlfsarkID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 3);
            rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
            rmAddPlayerResource(i, "Food", 50);
            rmAddPlayerResource(i, "Wood", 350);
            rmAddPlayerResource(i, "Gold", 300);
         }
		else if(rmGetPlayerCulture(i) == cCultureAtlantean)
         {
            rmPlaceObjectDefAtLoc(VillagerAtlanteanID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
            rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
            rmAddPlayerResource(i, "Food", 50);
            rmAddPlayerResource(i, "Wood", 350);
            rmAddPlayerResource(i, "Gold", 300);
         }
		else if(rmGetPlayerCulture(i) == cCultureChinese) {
			rmPlaceObjectDefAtLoc(VillagerChineseID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 3);
			rmEchoInfo("Placing Villagers for Player "+i+" who is Chinese");
			rmAddPlayerResource(i, "Food", 50);
			rmAddPlayerResource(i, "Wood", 300);
			rmAddPlayerResource(i, "Gold", 300);
		}
   }

   // Text
   rmSetStatusText("",0.80);


   // Far things.

   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, 3);
   
   rmPlaceObjectDefPerPlayer(farGold2ID, false, 1); 

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);

   // Goats.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(farGoatsID, 0, 0.5, 0.5, 3);

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers*2);

   // Bonus huntable stuff.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*2);

   // Bonus huntable stuff.
   rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

    // Monkeys
   rmPlaceObjectDefPerPlayer(farMonkeyID, false, 1); 

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);
   rmPlaceObjectDefAtLoc(randomtree2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);

   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);
   rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);


   int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 30.0);
   failCount=0;
   numTries=12*cNumberNonGaiaPlayers*mapSizeMultiplier;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i, centerID);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200*mapSizeMultiplier));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "palm forest");
      rmAddAreaConstraint(forestID, allObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, shortCliffConstraint);
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 3);
      rmSetAreaMaxBlobs(forestID, 7*mapSizeMultiplier);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 40.0*mapSizeMultiplier);
      rmSetAreaCoherence(forestID, 0.0);

      if(rmBuildArea(forestID)==false)
      {
         // Stop trying once we fail 6 times in a row.
         failCount++;
         if(failCount==6)
            break;
      }
      else
         failCount=0;
   }


   // Text
   rmSetStatusText("",0.90);


   // Grass
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 20.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 3, 4.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);

   // Bushes
   /* More suitable for desert now /*
   /*
   int bushID=rmCreateObjectDef("bush");
   rmAddObjectDefItem(bushID, "bush", 3, 2.0);
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bushID, avoidGrass);
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
   */

   // Text
   rmSetStatusText("",0.95);

   //int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 5.0);
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   //rmAddObjectDefConstraint(rockID, avoidRock);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 50*cNumberNonGaiaPlayers*mapSizeMultiplier);

   // Text
   rmSetStatusText("",1.00);

}  

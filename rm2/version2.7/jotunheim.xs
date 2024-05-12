// Main entry point for random map script

// Updated to have Giant features by Hagrit

void main(void)
{


  // Text
   rmSetStatusText("",0.1);

   // Set size.
   int mapSizeMultiplier = 1;
	int playerTiles=10000;
	if(cMapSize == 1){
		playerTiles = 12700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 23400;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	
   int sizel=0;
   int sizew=0;
   float handedness=rmRandFloat(0, 1);
   if(handedness<0.5)
   {
      sizel=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizew=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   else
   {
      sizew=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizel=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
   rmSetMapSize(sizel, sizew);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmTerrainInitialize("cliffNorseA", 12.0); 
/* rmTerrainInitialize("cliffGreekA", 9.0); */
  
   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("starting settlement");
   int connectionClass=rmDefineClass("connection");
   int patchClass=rmDefineClass("patchClass");

   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
   int connectionEdgeConstraint=rmCreateBoxConstraint("connections avoid edge of map", rmXTilesToFraction(16), rmZTilesToFraction(16), 1.0-rmXTilesToFraction(16), 1.0-rmZTilesToFraction(16));

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);

   // Connection
   int connectionConstraint=rmCreateClassDistanceConstraint("stay away from connection", connectionClass, 4.0);

   // Settlement constraint.
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 40.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("avoid tower2", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Animals
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 6.0);
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("forests avoid impassable land", "land", false, 18.0);
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);

	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	
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
   rmAddObjectDefConstraint(startingTowerID, shortAvoidImpassableLand);
   
   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);

   int closeCowsID=rmCreateObjectDef("close cows");
   rmAddObjectDefItem(closeCowsID, "cow", 2, 2.0);
   rmSetObjectDefMinDistance(closeCowsID, 25.0);
   rmSetObjectDefMaxDistance(closeCowsID, 30.0);
   rmAddObjectDefConstraint(closeCowsID, avoidFood);

   int numChicken = 0;
   int numBerry = 0;
   float berryChance = rmRandFloat(0,1);
   if(berryChance < 0.25)
   {
      numChicken = 4;
      numBerry = 3;
   }
   else if(berryChance < 0.75)
   {
      numChicken = 8;
      numBerry = 6;
   }
   else
   {
      numChicken = 12;
      numBerry = 9;
   }
      
   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", numChicken, 2.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   
   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", numBerry, 2.0);
   rmSetObjectDefMinDistance(closeBerriesID, 20.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 25.0);
   rmAddObjectDefConstraint(closeBerriesID, avoidFood);
   
   int closeHuntableID=rmCreateObjectDef("close huntable");
   float huntableNumber=rmRandFloat(0, 1);
   if(huntableNumber<0.3)
      rmAddObjectDefItem(closeHuntableID, "deer", 6, 2.0);
   else if(huntableNumber<0.6)
      rmAddObjectDefItem(closeHuntableID, "caribou", 4, 2.0);
   else 
      rmAddObjectDefItem(closeHuntableID, "elk", 5, 2.0);
   rmSetObjectDefMinDistance(closeHuntableID, 30.0);
   rmSetObjectDefMaxDistance(closeHuntableID, 50.0);
   rmAddObjectDefConstraint(closeHuntableID, shortAvoidSettlement);
   rmAddObjectDefConstraint(closeHuntableID, shortAvoidImpassableLand);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine snow", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // Medium Objects

   // Text
   rmSetStatusText("",0.20);

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 70.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumGoldID, forestObjConstraint);
  
   // For this map, pick how many deer in a grouping.  Assign this
   int numHuntable=rmRandInt(6, 8);

   int mediumDeerID=rmCreateObjectDef("medium deer");
   rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 3.0);
   rmSetObjectDefMinDistance(mediumDeerID, 60.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumDeerID, forestObjConstraint);
         
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
/*   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0); */
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoldID, forestObjConstraint);

   // goats avoid TCs 
   int farCowsID=rmCreateObjectDef("far cows");
   rmAddObjectDefItem(farCowsID, "cow", 2, 4.0);
   rmSetObjectDefMinDistance(farCowsID, 80.0);
   rmSetObjectDefMaxDistance(farCowsID, 150.0);
   rmAddObjectDefConstraint(farCowsID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farCowsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farCowsID, forestObjConstraint);
   
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   rmAddObjectDefItem(farPredatorID, "wolf", 3, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, forestObjConstraint);

   int farPredator2ID=rmCreateObjectDef("far predator 2");
   rmAddObjectDefItem(farPredator2ID, "bear", 2, 4.0);
   rmSetObjectDefMinDistance(farPredator2ID, 50.0);
   rmSetObjectDefMaxDistance(farPredator2ID, 100.0);
   rmAddObjectDefConstraint(farPredator2ID, avoidPredator);
   rmAddObjectDefConstraint(farPredator2ID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredator2ID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredator2ID, forestObjConstraint);
   
   // This map will either use deer, elk, caribou as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.3)   
      rmAddObjectDefItem(bonusHuntableID, "deer", 6, 2.0);
   else if(bonusChance<0.6)   
      rmAddObjectDefItem(bonusHuntableID, "elk", 4, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "caribou", 4, 2.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, forestObjConstraint);

   // hunted avoids hunted and TCs
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable 2");
   float bonusChance3=rmRandFloat(0, 1);
   if(bonusChance3<0.3)   
      rmAddObjectDefItem(bonusHuntableID2, "deer", 4, 2.0);
   else if(bonusChance3<0.6)   
      rmAddObjectDefItem(bonusHuntableID2, "elk", 6, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID2, "caribou", 6, 2.0);
   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID2, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, forestObjConstraint);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "pine snow", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);

   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

 // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 30.0);
   rmSetObjectDefMaxDistance(relicID, 130.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 40.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, forestObjConstraint);


	// giant
	if(cMapSize == 2)
	{
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantGoldID, avoidGold);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantGoldID, forestObjConstraint);
		
		int giantAvoidFood = rmCreateTypeDistanceConstraint("giant avoid food", "food", 50.0);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "deer", 5, 4.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntableID, "Elk", 5, 3.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "caribou", 5, 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, avoidAll);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable2ID, "deer", 5, 4.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable2ID, "Elk", 5, 3.0);
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "caribou", 5, 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidAll);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidImpassableLand);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "cow", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidAll);

		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 0.0);
		rmSetObjectDefMinDistance(giantRelixID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantRelixID, avoidAll);
		rmAddObjectDefConstraint(giantRelixID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 70.0));
	}


   // -------------Done defining objects

  // Text
   rmSetStatusText("",0.40);


   rmPlacePlayersCircular(0.30, 0.40, rmDegreesToRadians(4.0));

    // Build team areas.
   int teamClass=rmDefineClass("teamClass");
   int baseMountainWidth = 0;
   int connectionWidth = 0;
   if (cNumberTeams < 3)
      {
      baseMountainWidth = 30;
      connectionWidth = 30;
      }
   else
      {
      baseMountainWidth = 20;
      connectionWidth = 25;
      }
   int teamConstraint=rmCreateClassDistanceConstraint("how wide the mountain is", teamClass, baseMountainWidth);

   // Set up a connection... we'll add all the team areas to it.
   int connectionID=rmCreateConnection("passes");
   rmAddConnectionTerrainReplacement(connectionID, "cliffNorseA", "SnowB");
   rmAddConnectionTerrainReplacement(connectionID, "cliffNorseB", "SnowB");
   rmAddConnectionTerrainReplacement(connectionID, "cliffGreekA", "SnowB"); 
   rmSetConnectionType(connectionID, cConnectAreas, false, 1.0);
   rmSetConnectionWarnFailure(connectionID, false); 
   rmSetConnectionWidth(connectionID, connectionWidth, 4);
   rmSetConnectionTerrainCost(connectionID, "cliffNorseA", 5.0);
   rmSetConnectionTerrainCost(connectionID, "cliffNorseB", 3.0);
   rmSetConnectionPositionVariance(connectionID, 0.3);
   rmSetConnectionBaseHeight(connectionID, 0.0);
   rmSetConnectionHeightBlend(connectionID, 2);
   rmAddConnectionToClass(connectionID, connectionClass); 

   /* Add chance for another connection in 2 team games. The more players, the less the chance */

   int secondConnectionExists = 0;
   float secondConnectionChance = rmRandFloat(0.0, 1.0);
   if(cNumberTeams < 3)
   {         
      if(cNumberNonGaiaPlayers <4)
      {   
         if(secondConnectionChance < 0.8)
            secondConnectionExists = 1;
      }      
      else
      {      
         if(secondConnectionChance < 0.6)
           secondConnectionExists = 1;
      }
   }

   rmEchoInfo("secondConnectionChance "+secondConnectionChance+ "secondConnectionExists "+secondConnectionExists);

   if(secondConnectionExists == 1)
   {   
      int alternateConnection=rmCreateConnection("alternate passes");
      rmAddConnectionTerrainReplacement(alternateConnection, "cliffNorseA", "SnowA");
      rmAddConnectionTerrainReplacement(alternateConnection, "cliffNorseB", "SnowA");
      rmAddConnectionTerrainReplacement(alternateConnection, "cliffGreekA", "SnowA");
      rmSetConnectionType(alternateConnection, cConnectAreas, false, 1.0);
      rmSetConnectionWarnFailure(alternateConnection, false); 
      rmSetConnectionWidth(alternateConnection, connectionWidth, 4);
      rmSetConnectionTerrainCost(alternateConnection, "cliffNorseA", 5.0);
      rmSetConnectionTerrainCost(alternateConnection, "cliffNorseB", 3.0);
      rmAddConnectionStartConstraint(alternateConnection, connectionEdgeConstraint);
      rmAddConnectionEndConstraint(alternateConnection, connectionEdgeConstraint);
      rmAddConnectionStartConstraint(alternateConnection, playerConstraint);
      rmAddConnectionEndConstraint(alternateConnection, playerConstraint);

      rmSetConnectionPositionVariance(alternateConnection, -1.0);
/*         rmSetConnectionPositionVariance(alternateConnection, 50); */ 
      rmSetConnectionBaseHeight(alternateConnection, 0.0);
      rmSetConnectionHeightBlend(alternateConnection, 2);
      rmAddConnectionToClass(alternateConnection, connectionClass);
   }

   // Build team areas.
   int teamEdgeConstraint=rmCreateBoxConstraint("team edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4)); 
   float teamPercentArea = 0.80/cNumberTeams;
   if(cNumberNonGaiaPlayers < 4)
      teamPercentArea = 0.75/cNumberTeams;

   float percentPerPlayer = 0.75/cNumberNonGaiaPlayers;
   float teamSize = 0;


   for(i=0; <cNumberTeams)
   {
      int teamID=rmCreateArea("team"+i);
      rmSetTeamArea(i, teamID);
      teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
      rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
/*      rmSetAreaSize(teamID, teamPercentArea, teamPercentArea); */
      rmSetAreaWarnFailure(teamID, false);
      rmSetAreaTerrainType(teamID, "SnowA");
      rmAddAreaTerrainLayer(teamID, "cliffNorseB", 2, 6);
      rmAddAreaTerrainLayer(teamID, "cliffNorseA", 0, 2);
      rmSetAreaMinBlobs(teamID, 1);
      rmSetAreaMaxBlobs(teamID, 5);
      rmSetAreaMinBlobDistance(teamID, 16.0);
      rmSetAreaMaxBlobDistance(teamID, 40.0);
      rmSetAreaCoherence(teamID, 0.0);
      rmSetAreaSmoothDistance(teamID, 10);
      rmAddAreaToClass(teamID, teamClass);
      rmSetAreaBaseHeight(teamID, 0.0);
      rmSetAreaHeightBlend(teamID, 2); 
      rmAddAreaConstraint(teamID, teamConstraint);
      rmAddAreaConstraint(teamID, teamEdgeConstraint);
      rmSetAreaLocTeam(teamID, i);
      rmAddConnectionArea(connectionID, teamID); 
      if(secondConnectionExists == 1.0) 
         rmAddConnectionArea(alternateConnection, teamID);
      rmEchoInfo("Team area"+i);
   }

   // initial dress up of mountains
   int patchConstraint=rmCreateClassDistanceConstraint("patch vs patch", patchClass, 10);
   int failCount = 0;
   for(j=0; <cNumberNonGaiaPlayers*150*mapSizeMultiplier)
   {
      int rockPatch=rmCreateArea("rock patch"+j);
      rmSetAreaSize(rockPatch, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
      rmSetAreaWarnFailure(rockPatch, false);
      rmSetAreaBaseHeight(rockPatch, rmRandFloat(5.0, 9.0));
      rmSetAreaHeightBlend(rockPatch, 1); 
      rmSetAreaTerrainType(rockPatch, "CliffGreekA");
      rmSetAreaMinBlobs(rockPatch, 1);
      rmSetAreaMaxBlobs(rockPatch, 3*mapSizeMultiplier);
      rmSetAreaMinBlobDistance(rockPatch, 5.0);
      rmSetAreaMaxBlobDistance(rockPatch, 5.0*mapSizeMultiplier);
      rmSetAreaCoherence(rockPatch, 0.3);
      if(rmBuildArea(rockPatch)==false)
         {
            // Stop trying once we fail 3 times in a row.
            failCount++;
            if(failCount==3)
               break;
         }
         else
            failCount=0;
   }

   // Place players.
   rmBuildAllAreas();
   rmBuildConnection(connectionID);
   if(secondConnectionExists == 1.0)
      rmBuildConnection(alternateConnection);

   // Set up player areas.
   rmSetTeamSpacingModifier(0.75);
   float playerFraction=rmAreaTilesToFraction(2500);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
      rmEchoInfo("Player"+i+"team"+rmGetPlayerTeam(i));

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

      // Add constraints.
      rmAddAreaConstraint(id, playerConstraint);
      rmAddAreaConstraint(id, shortAvoidImpassableLand);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, "SnowGrass50");
      rmAddAreaTerrainLayer(id, "SnowGrass25", 4, 12);
      rmAddAreaTerrainLayer(id, "SnowA", 0, 4);

   }

   // Build the areas.
   rmBuildAllAreas();

  for(i=1; <cNumberPlayers)
   {
      for(j=0; <3*mapSizeMultiplier)
      {
         // Beautification sub area.
         int id3=rmCreateArea("snow patch"+i +j, rmAreaID("player"+i));
         rmSetAreaSize(id3, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
         rmSetAreaWarnFailure(id3, false);
         rmSetAreaTerrainType(id3, "SnowB");
         rmAddAreaConstraint(id3, shortAvoidImpassableLand);
         rmSetAreaMinBlobs(id3, 1);
         rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
         rmSetAreaMinBlobDistance(id3, 5.0*mapSizeMultiplier);
         rmSetAreaMaxBlobDistance(id3, 20.0*mapSizeMultiplier);
         rmSetAreaCoherence(id3, 0.0);

         rmBuildArea(id3);
      }
   }


   for(i=1; <cNumberPlayers)
   {
      for(j=0; <3*mapSizeMultiplier)
      {
         // Beautification sub area.
         int id2=rmCreateArea("grass patch"+i +j, rmAreaID("player"+i));
         rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
         rmSetAreaWarnFailure(id2, false);
         rmSetAreaTerrainType(id2, "SnowGrass50");
         rmAddAreaTerrainLayer(id2, "SnowGrass25", 0, 2);
         rmAddAreaConstraint(id2, shortAvoidImpassableLand);
         rmSetAreaMinBlobs(id2, 1);
         rmSetAreaMaxBlobs(id2, 5);
         rmSetAreaMinBlobDistance(id2, 5.0);
         rmSetAreaMaxBlobDistance(id2, 20.0);
         rmSetAreaCoherence(id2, 0.0);

         rmBuildArea(id2);
      } 
   }

 
   // Text
   rmSetStatusText("",0.60);

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Slight Elev.
   int numTries=10*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   failCount=0;

   numTries=8*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries*mapSizeMultiplier)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1*mapSizeMultiplier);
      rmSetAreaMaxBlobs(elevID, 3*mapSizeMultiplier);
      rmSetAreaMinBlobDistance(elevID, 16.0*mapSizeMultiplier);
      rmSetAreaMaxBlobDistance(elevID, 20.0*mapSizeMultiplier);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidBuildings); 
      rmAddAreaConstraint(elevID, shortAvoidImpassableLand);

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
// Settlements.
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10, false, true); /* bool forward bool inside */
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);

   id=rmAddFairLoc("Settlement", true, true, 60, 90, 40, 10, false, true);
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);
   
   if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", false, true,  rmXFractionToMeters(0.25), rmXFractionToMeters(0.4), 60, 16);
		rmAddFairLocConstraint(id, shortAvoidImpassableLand);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.35), rmXFractionToMeters(0.4), 60, 16);
		rmAddFairLocConstraint(id, shortAvoidImpassableLand);
	}
   
   
   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {
            int settleArea = rmCreateArea("settlement area"+i +j, rmAreaID("Player"+i));
            rmSetAreaTerrainType(settleArea, "SnowA");
            rmSetAreaLocation(settleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
            rmBuildArea(settleArea);
            rmPlaceObjectDefAtAreaLoc(id, i, settleArea); 
         }
      }
   }

       
   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

   // Text
   rmSetStatusText("",0.80);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Cows
   rmPlaceObjectDefPerPlayer(closeCowsID, true);

   // Chickens or berries.
   for(i=1; <cNumberPlayers)
   {
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmPlaceObjectDefAtLoc(closeChickensID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else
         rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }


   // Close hunted
   rmPlaceObjectDefPerPlayer(closeHuntableID, false);

 
   // Player forests
   int classForest=rmDefineClass("forest");
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
  
   for(i=0; <cNumberTeams)
   {
      failCount=0;
      int forestCount=rmRandInt(4, 5)*rmGetNumberPlayersOnTeam(i);
      for(j=0; <forestCount*mapSizeMultiplier)
      {
         int forestID=rmCreateArea("team"+i+"forest"+j, rmAreaID("team"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(140), rmAreaTilesToFraction(200*mapSizeMultiplier));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "snow pine forest"); 
         rmAddAreaConstraint(forestID, forestSettleConstraint);
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint);
         rmAddAreaConstraint(forestID, avoidImpassableLand); 
         rmAddAreaToClass(forestID, classForest);
      
         rmSetAreaMinBlobs(forestID, 2);
         rmSetAreaMaxBlobs(forestID, 2*mapSizeMultiplier);
         rmSetAreaMinBlobDistance(forestID, 5.0);
         rmSetAreaMaxBlobDistance(forestID, 5.0*mapSizeMultiplier);
         rmSetAreaCoherence(forestID, 0.5);

         if(rmBuildArea(forestID)==false)
         {
            // Stop trying once we fail 3 times in a row.
            failCount++;
            if(failCount==5)
               break;
         }
         else
            failCount=0;
      }
   }

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   // Deer
   rmPlaceObjectDefPerPlayer(mediumDeerID, false);

   // Far things.

   // Gold.
   int goldNum=rmRandInt(2, 4);
   rmEchoInfo("goldNum="+goldNum);
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(farGoldID, i, rmAreaID("team"+rmGetPlayerTeam(i)), goldNum);
      rmEchoInfo("far gold for"+i);
   }

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 

   // Cows.
   rmPlaceObjectDefPerPlayer(farCowsID, false, 1);

   // Bonus huntable stuff.
   rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 1);

   rmPlaceObjectDefPerPlayer(bonusHuntableID2, false, 1);


   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   rmPlaceObjectDefPerPlayer(farPredator2ID, false, 1);

	if (cMapSize == 2)
	{
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		rmPlaceObjectDefPerPlayer(giantRelixID, false);
	}

   // Relics
   for(i=1; <cNumberPlayers)
   rmPlaceObjectDefInArea (relicID, i, rmAreaID("team"+rmGetPlayerTeam(i)), 1); 

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   // rocks
   
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock granite sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   //rmAddObjectDefConstraint(rockID, avoidRock);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 40*cNumberNonGaiaPlayers);

    // rocks
   int rockID2=rmCreateObjectDef("rock 2");
   rmAddObjectDefItem(rockID2, "rock granite big", 3, 1.0);
   rmAddObjectDefItem(rockID2, "rock granite small", 3, 3.0);
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 2, 3.0);
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 1, 5.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmAddObjectDefConstraint(rockID2, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidBuildings);
   rmAddObjectDefConstraint(rockID2, connectionConstraint);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   for(i=1; <cNumberNonGaiaPlayers*6)
   {
      if(rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 1)==0)
      {
         break;
      }
   }

   int rockID4=rmCreateObjectDef("rock 3");
   rmAddObjectDefItem(rockID4, "rock river icy", 1, 2.0);
   rmAddObjectDefItem(rockID4, "rock granite small", 2, 5.0);
   rmAddObjectDefItem(rockID4, "rock limestone sprite", 3, 5.0);
   rmSetObjectDefMinDistance(rockID4, 0.0);
   rmAddObjectDefConstraint(rockID4, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(rockID4, avoidAll);
   rmAddObjectDefConstraint(rockID4, avoidBuildings);
   rmAddObjectDefConstraint(rockID4, connectionConstraint);
   rmSetObjectDefMaxDistance(rockID4, rmXFractionToMeters(0.5));
   for(i=1; <cNumberNonGaiaPlayers*3)
   {
      if(rmPlaceObjectDefAtLoc(rockID4, 0, 0.5, 0.5, 1)==0)
      {
         break;
      }
   }

  // Text
   rmSetStatusText("",1.0);
  
}
// ALFHEIM

// Main entry point for random map script
void main(void)
{

   // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=7500;
   if(cMapSize == 1)
   {
      playerTiles = 9750;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmTerrainInitialize("grassA");
   rmSetLightingSet("alfheim");
   rmSetGaiaCiv(cCivZeus);

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("classHill");
   rmDefineClass("starting settlement");
   int classCliff=rmDefineClass("cliff");

    // -------------Define constraints

   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);

   // Settlement constraint.
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 22.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("gold vs. gold", "gold", 24.0);

   // Herd animals
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 8.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0);
   int shortCliffConstraint=rmCreateClassDistanceConstraint("stuff v cliff", rmClassID("cliff"), 10.0);

   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("Starting settlement");
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

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, shortCliffConstraint);

   int closeCowsID=rmCreateObjectDef("close Cows");
   rmAddObjectDefItem(closeCowsID, "cow", rmRandInt(2,4), 2.0);
   rmSetObjectDefMinDistance(closeCowsID, 20.0);
   rmSetObjectDefMaxDistance(closeCowsID, 25.0);
   rmAddObjectDefConstraint(closeCowsID, shortCliffConstraint);
   rmAddObjectDefConstraint(closeCowsID, avoidFood);

   int BerryNum=rmRandInt(6, 10);
   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", BerryNum, 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 25.0);
   rmSetObjectDefMaxDistance(closeChickensID, 30.0);
   rmAddObjectDefConstraint(closeChickensID, shortCliffConstraint);

   int avoidChickens=rmCreateTypeDistanceConstraint("avoid chickens", "chicken", 10.0);
   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", BerryNum, 4.0);
   rmSetObjectDefMinDistance(closeBerriesID, 30.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 35.0);
   rmAddObjectDefConstraint(closeBerriesID, shortCliffConstraint);
   rmAddObjectDefConstraint(closeBerriesID, avoidChickens);
   
   int closeElkID=rmCreateObjectDef("close elk");
   if(rmRandFloat(0,1)<0.75)
      rmAddObjectDefItem(closeElkID, "elk", rmRandInt(3,5), 4.0);
   else
      rmAddObjectDefItem(closeElkID, "elk", 2, 2.0);
   rmSetObjectDefMinDistance(closeElkID, 30.0);
   rmSetObjectDefMaxDistance(closeElkID, 50.0);
   rmAddObjectDefConstraint(closeElkID, shortCliffConstraint);
   rmAddObjectDefConstraint(closeElkID, shortAvoidSettlement);
   rmAddObjectDefConstraint(closeElkID, avoidChickens);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidGold);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, shortCliffConstraint);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);

   int mediumCowID=rmCreateObjectDef("medium Cow");
   rmAddObjectDefItem(mediumCowID, "cow", rmRandFloat(1,2), 4.0);
   rmSetObjectDefMinDistance(mediumCowID, 50.0);
   rmSetObjectDefMaxDistance(mediumCowID, 100.0);
   rmAddObjectDefConstraint(mediumCowID, shortCliffConstraint);
   rmAddObjectDefConstraint(mediumCowID, farStartingSettleConstraint); 

   int mediumDeerID=rmCreateObjectDef("medium deer");
   rmAddObjectDefItem(mediumDeerID, "deer", rmRandInt(2,8), 4.0);
   rmSetObjectDefMinDistance(mediumDeerID, 60.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, shortCliffConstraint);
   rmAddObjectDefConstraint(mediumDeerID, avoidFood);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);

   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, shortAvoidGold);
   rmAddObjectDefConstraint(farGoldID, shortCliffConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
  
   int farCowID=rmCreateObjectDef("far Cow");
   rmAddObjectDefItem(farCowID, "cow", rmRandInt(1,2), 4.0);
   rmSetObjectDefMinDistance(farCowID, 80.0);
   rmSetObjectDefMaxDistance(farCowID, 150.0);
   rmAddObjectDefConstraint(farCowID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farCowID, shortCliffConstraint);
   rmAddObjectDefConstraint(farCowID, avoidHerdable);
   rmAddObjectDefConstraint(farCowID, avoidFood);

   // pick wolves or bears as predators
   // avoid TCs and other animals
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "wolf", rmRandInt(2,4), 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "bear", 2, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(farPredatorID, shortCliffConstraint);
   rmAddObjectDefConstraint(farPredatorID, avoidFood);

   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance < 0.33)   
      rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(2,8), 4.0);
   else if(bonusChance < 0.66)
      rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(2,6), 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "aurochs", rmRandInt(2,3), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(bonusHuntableID, shortCliffConstraint);
   
   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);

    // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

   // -------------Done defining objects

   // Cheesy "circular" placement of players.
   rmSetTeamSpacingModifier(0.75);
   rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(5.0));

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

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, "GrassDirt50");
      rmAddAreaTerrainLayer(id, "GrassDirt25", 8, 20);
      rmAddAreaTerrainLayer(id, "GrassA", 0, 8);

   }

   // Build the areas.
   rmBuildAllAreas();

   for(i=1; <cNumberPlayers)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
      rmSetAreaSize(id2, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
      rmSetAreaLocPlayer(id2, i);
      rmSetAreaTerrainType(id2, "GrassDirt25");
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);

      rmBuildArea(id2); 
   } 

      for(i=1; <cNumberPlayers*20)
   {
      // Beautification sub area.
      int id4=rmCreateArea("Grass patch 2 "+i);
      rmSetAreaSize(id4, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16));
      rmSetAreaTerrainType(id4, "GrassB");
      rmSetAreaMinBlobs(id4, 1);
      rmSetAreaMaxBlobs(id4, 5);
      rmSetAreaWarnFailure(id4, false);
      rmSetAreaMinBlobDistance(id4, 16.0);
      rmSetAreaMaxBlobDistance(id4, 40.0);
      rmSetAreaCoherence(id4, 0.0);

      rmBuildArea(id4);
   }

   for(i=1; <cNumberPlayers*12)
   {
      // Beautification sub area.
      int id5=rmCreateArea("Grass patch 3 "+i);
      rmSetAreaSize(id5, rmAreaTilesToFraction(5), rmAreaTilesToFraction(20));
      rmSetAreaTerrainType(id5, "GrassDirt25");
      rmSetAreaMinBlobs(id5, 1);
      rmSetAreaMaxBlobs(id5, 5);
      rmSetAreaWarnFailure(id5, false);
      rmSetAreaMinBlobDistance(id5, 16.0);
      rmSetAreaMaxBlobDistance(id5, 40.0);
      rmSetAreaCoherence(id5, 0.0);

      rmBuildArea(id5);
   }



      // Text
   rmSetStatusText("",0.20);

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements.
   id=rmAddFairLoc("Settlement", false, true,  40, 80, 60, 10);

   id=rmAddFairLoc("Settlement", true, false, 60, 100, 60, 10);


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

   // Text
   rmSetStatusText("",0.40);

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);


   // Slight Elevation
   int numTries=30*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
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

   // Cliffage

   numTries=3*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int cliffID=rmCreateArea("cliff"+i);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
      rmSetAreaCliffType(cliffID, "Greek");
      rmAddAreaConstraint(cliffID, cliffConstraint);
      rmAddAreaToClass(cliffID, classCliff);
      rmAddAreaConstraint(cliffID, avoidBuildings);
      rmSetAreaMinBlobs(cliffID, 10);
      rmSetAreaMaxBlobs(cliffID, 10);
      rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
      rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
     /* rmSetAreaTerrainType(cliffID, "cliffGreekA"); */
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaMinBlobDistance(cliffID, 16.0);
      rmSetAreaMaxBlobDistance(cliffID, 40.0);
      rmSetAreaCoherence(cliffID, 0.25);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
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

   // Elev.
   numTries=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
      rmAddAreaConstraint(elevID, shortCliffConstraint);
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

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // cows
   rmPlaceObjectDefPerPlayer(closeCowsID, true);
   
   // chickens and berries   
   rmPlaceObjectDefPerPlayer(closeChickensID, false);

   rmPlaceObjectDefPerPlayer(closeBerriesID, false);

   // Elk
   if(rmRandFloat(0,1)<0.9)
      rmPlaceObjectDefPerPlayer(closeElkID, false);
   else
      rmPlaceObjectDefPerPlayer(closeElkID, false, rmRandInt(3,6));

 // Ruins
   int ruinID=0;
   int columnID=0;
   int relicID=0;
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
   int avoidRuins=rmCreateTypeDistanceConstraint("ruin vs ruin", "relic", 60.0);
   int stayInRuins=rmCreateEdgeDistanceConstraint("stay in ruins", ruinID, 4.0);

   for(i=0; <2*cNumberNonGaiaPlayers)
   {
      ruinID=rmCreateArea("ruins "+i);
      rmSetAreaSize(ruinID, rmAreaTilesToFraction(120), rmAreaTilesToFraction(180));
      rmSetAreaTerrainType(ruinID, "GreekRoadA");
      rmAddAreaTerrainLayer(ruinID, "GrassDirt25", 0, 1);
      rmSetAreaMinBlobs(ruinID, 1);
      rmSetAreaMaxBlobs(ruinID, 2);
      rmSetAreaWarnFailure(ruinID, false); 
      rmSetAreaMinBlobDistance(ruinID, 16.0);
      rmSetAreaMaxBlobDistance(ruinID, 40.0);
      rmSetAreaCoherence(ruinID, 0.8);
      rmSetAreaSmoothDistance(ruinID, 10);
      rmAddAreaConstraint(ruinID, avoidAll);
      rmAddAreaConstraint(ruinID, avoidRuins);
      rmAddAreaConstraint(ruinID, stayInRuins);
      rmAddAreaConstraint(ruinID, shortCliffConstraint);
      rmAddAreaConstraint(ruinID, avoidBuildings);
      rmAddAreaConstraint(ruinID, farStartingSettleConstraint);

      rmBuildArea(ruinID);
    
      columnID=rmCreateObjectDef("columns "+i);
      rmAddObjectDefItem(columnID, "ruins", rmRandInt(0,1), 0.0);
      rmAddObjectDefItem(columnID, "columns broken", rmRandInt(2,5), 4.0);
      rmAddObjectDefItem(columnID, "columns", rmRandFloat(0,2), 4.0);
      rmAddObjectDefItem(columnID, "rock limestone small", rmRandInt(1,3), 4.0);
      rmAddObjectDefItem(columnID, "rock limestone sprite", rmRandInt(6,12), 6.0);
      rmAddObjectDefItem(columnID, "grass", rmRandFloat(3,6), 4.0);
      rmSetObjectDefMinDistance(columnID, 0.0);
      rmSetObjectDefMaxDistance(columnID, 0.0);
      rmPlaceObjectDefInArea(columnID, 0, rmAreaID("ruins "+i), 1);

      relicID=rmCreateObjectDef("relics "+i);
      rmAddObjectDefItem(relicID, "relic", 1, 0.0);
      rmSetObjectDefMinDistance(relicID, 0.0);
      rmSetObjectDefMaxDistance(relicID, 0.0);
      rmAddObjectDefConstraint(relicID, avoidAll);
      rmAddObjectDefConstraint(relicID, stayInRuins);
      rmPlaceObjectDefInArea(relicID, 0, rmAreaID("ruins "+i), 1);

      if(rmGetNumberUnitsPlaced(relicID) < 1)
      {
         rmEchoInfo("---------------------failed to place relicID in ruins "+i+". So just dropping backup Relic.");
         rmSetAreaSize(ruinID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
         int backupRelicID=rmCreateObjectDef("backup relic "+i);
         rmAddObjectDefItem(backupRelicID, "relic", 1, 0.0);
         rmSetObjectDefMinDistance(backupRelicID, 0.0);
         rmSetObjectDefMaxDistance(backupRelicID, rmXFractionToMeters(0.5));
         rmAddObjectDefConstraint(backupRelicID, avoidRuins);
         rmAddObjectDefConstraint(backupRelicID, farStartingSettleConstraint);
         rmAddObjectDefConstraint(backupRelicID, shortCliffConstraint);
         rmPlaceObjectDefAtLoc(backupRelicID, 0, 0.5, 0.5, 1);
      }

   }

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));

   // Herds.
   rmPlaceObjectDefPerPlayer(mediumCowID, false); 

   // Deer.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumDeerID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
            
   // Far things.

   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(3, 4));

   // Bonus huntable.
   rmPlaceObjectDefPerPlayer(bonusHuntableID, false, rmRandInt(1, 2));

   // Herds.
   rmPlaceObjectDefPerPlayer(farCowID, false, rmRandInt(1, 2));

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 
   
   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int count=0;
   numTries=9*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "pine forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, shortCliffConstraint);
/*      rmAddAreaConstraint(forestID, avoidImpassableLand); */
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 3);
      rmSetAreaMaxBlobs(forestID, 8);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 40.0);
      rmSetAreaCoherence(forestID, 0.0);

      // Hill trees?
      if(rmRandFloat(0.0, 1.0)<0.2)
         rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));

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
   rmSetStatusText("",0.60);

   // Random trees
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 25*cNumberNonGaiaPlayers);

   
   // Text
   rmSetStatusText("",0.80);

   // Rocks
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID, shortCliffConstraint);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   // Logs
   int logID=rmCreateObjectDef("log");
   rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
   rmSetObjectDefMinDistance(logID, 0.0);
   rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(logID, avoidAll);
   rmAddObjectDefConstraint(logID, avoidImpassableLand);
   rmAddObjectDefConstraint(logID, shortCliffConstraint);
   rmAddObjectDefConstraint(logID, avoidBuildings);
   rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);


   // Text
   rmSetStatusText("",1.00);

}  

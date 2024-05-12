// Main entry point for random map script
void main(void)

{

  // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=8500;
   if(cMapSize == 1)
   {
      playerTiles = 11050;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(-8);

   // Init map.
   rmTerrainInitialize("GrassA");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   int classTower=rmDefineClass("starting towers");
   int classLake=rmDefineClass("lake");
   int classForest=rmDefineClass("forest");
   int classFirstForest=rmDefineClass("starting forest");

   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
   int stayInCenter= 0;
   if(cNumberNonGaiaPlayers < 4)
      rmCreateBoxConstraint("far avoid edge of map", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30));
   else         
      rmCreateBoxConstraint("medium avoid edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
   int shortPlayerConstraint=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 8);
   int patchPlayerConstraint=rmCreateClassDistanceConstraint("elev stay away from players", classPlayer, 8);


   // Settlement constraints
   int veryShortAvoidSettlement=rmCreateTypeDistanceConstraint("statues avoid TC", "AbstractSettlement", 6.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int mediumAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by medium distance", "AbstractSettlement", 30.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 70.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
       
   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 60.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 8.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidBerries=rmCreateTypeDistanceConstraint("avoid berries", "berry bush", 40.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int SettlementAvoidImpassableLand=rmCreateTerrainDistanceConstraint("Settlement avoid impassable land", "land", false,30.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 6.0);
   int lakeConstraint=rmCreateClassDistanceConstraint("avoid the center", classLake, 25.0);
   int firstForestConstraint=rmCreateClassDistanceConstraint("resources v forest", rmClassID("starting forest"), 5.0);

  
   // -------------Define objects
 // Close Objects

   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   int closeGoldID=rmCreateObjectDef("close gold");
   rmAddObjectDefItem(closeGoldID, "gold mine", 1, 1.0);
   rmSetObjectDefMinDistance(closeGoldID, 15.0);
   rmSetObjectDefMaxDistance(closeGoldID, 26.0);
   rmAddObjectDefConstraint(closeGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeGoldID, firstForestConstraint);

   int closeGoatsID=rmCreateObjectDef("close goats");
   rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 15.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 26.0);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);
   rmAddObjectDefConstraint(closeGoatsID, firstForestConstraint);
   rmAddObjectDefConstraint(closeGoatsID, shortAvoidGold);
   rmAddObjectDefConstraint(closeGoatsID, avoidImpassableLand);

   int closeChickensID=rmCreateObjectDef("close birdies");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(5,10), 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 12.0);
   rmSetObjectDefMaxDistance(closeChickensID, 23.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   rmAddObjectDefConstraint(closeChickensID, firstForestConstraint);
   rmAddObjectDefConstraint(closeChickensID, shortAvoidGold);

    int statueID=rmCreateObjectDef("statue");
   rmAddObjectDefItem(statueID, "statue of major god", 1, 1.0);
   rmSetObjectDefMinDistance(statueID, 20.0);
   rmSetObjectDefMaxDistance(statueID, 28.0);
   rmAddObjectDefConstraint(statueID, avoidImpassableLand);
   rmAddObjectDefConstraint(statueID, firstForestConstraint);
   rmAddObjectDefConstraint(statueID, veryShortAvoidSettlement);
      
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // Medium Objects

   int mediumGoatsID=rmCreateObjectDef("medium goats");
   rmAddObjectDefItem(mediumGoatsID, "goat", 2, 1.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
   rmAddObjectDefConstraint(mediumGoatsID, playerConstraint);
   rmAddObjectDefConstraint(mediumGoatsID, stayInCenter);

  
  // Med Settlement

   // Settlement avoids gold, Settlements
   int setAvoidTower = rmCreateTypeDistanceConstraint("med Settlement avoid tower", "tower", 20.0);
   int setAvoidTree = rmCreateTypeDistanceConstraint("med Settlement avoid tree", "tree", 4.0);
   int medSettlementID=rmCreateObjectDef("med settlement");
   rmAddObjectDefItem(medSettlementID, "Settlement", 1, 0.0);
   rmSetObjectDefMinDistance(medSettlementID, 30.0);
   rmSetObjectDefMaxDistance(medSettlementID, 60.0);
   rmAddObjectDefConstraint(medSettlementID, shortAvoidImpassableLand);
//   rmAddObjectDefConstraint(medSettlementID, setAvoidTower);
   rmAddObjectDefConstraint(medSettlementID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(medSettlementID, setAvoidTree);

   // Far Objects

         
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, playerConstraint);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, stayInCenter);

   // goats avoid TCs 
   int farGoatsID=rmCreateObjectDef("far goats");
   rmAddObjectDefItem(farGoatsID, "goat", 1, 0.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, playerConstraint);
   rmAddObjectDefConstraint(farGoatsID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoatsID, stayInCenter);
    
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 30);
   rmSetObjectDefMaxDistance(farBerriesID, 150);
   rmAddObjectDefConstraint(farBerriesID, playerConstraint);
   rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(farBerriesID, avoidBerries);
   rmAddObjectDefConstraint(farBerriesID, avoidGold);
   rmAddObjectDefConstraint(farBerriesID, stayInCenter);
   
   // Huntable
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(6,8), 2.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, playerConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, stayInCenter);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);

   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 60.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, playerConstraint);
   rmAddObjectDefConstraint(relicID, avoidImpassableLand);

   // -------------Done defining objects


  // Text
   rmSetStatusText("",0.20);

   rmPlacePlayersSquare(0.3, 0.05, 0.05);
   for(i=1; <cNumberPlayers)
   {
      rmAddPlayerResource(i, "Food", 300);
      rmAddPlayerResource(i, "Wood", 200);
      rmAddPlayerResource(i, "Gold", 100);
   }

   int lake = 1;
   if(rmRandFloat (0,1) < 0.5)
         lake = 0;
   rmEchoInfo ("lake="+lake);

   if(lake == 1)
   {
      int centerLake=rmCreateArea("lake in the middle");
      rmSetAreaSize(centerLake, 0.03, 0.04);
      rmSetAreaLocation(centerLake, 0.5, 0.5);
      rmSetAreaWaterType(centerLake, "Greek River");
      rmSetAreaBaseHeight(centerLake, 0.0);
      rmSetAreaMinBlobs(centerLake, 5);
      rmSetAreaMaxBlobs(centerLake, 7);
      rmSetAreaMinBlobDistance(centerLake, 16.0);
      rmSetAreaMaxBlobDistance(centerLake, 20.0);
      rmSetAreaSmoothDistance(centerLake, 50);
      rmSetAreaCoherence(centerLake, 0.25);
      rmAddAreaToClass(centerLake, classLake);
      rmBuildArea(centerLake);
   }

   // Connections
   int classConnection=rmDefineClass("connection");
   int rampID=rmCreateConnection("ramps");
   rmSetConnectionType(rampID, cConnectAreas, false, 0.70);
   rmSetConnectionWidth(rampID, 12, 2);
   rmSetConnectionHeightBlend(rampID, 7.0);
   rmSetConnectionSmoothDistance(rampID, 3.0);
   rmAddConnectionTerrainReplacement(rampID, "cliffGreekA", "GrassA");
   rmAddConnectionTerrainReplacement(rampID, "cliffGreekB", "GrassA");
   rmAddConnectionToClass(rampID, classConnection);

   // Set up temp areas so we can build the connections.
   for(i=1; <cNumberPlayers)
   {
      int tempID=rmCreateArea("TempPlayer"+i);
      rmSetAreaSize(tempID, 0.01, 0.01);
      rmAddConnectionArea(rampID, tempID);
      rmSetAreaLocPlayer(tempID, i);
      rmBuildArea(tempID);
      rmAddAreaConstraint(tempID, lakeConstraint);
      rmAddAreaConstraint(tempID, edgeConstraint);
      rmAddAreaConstraint(tempID, playerConstraint);
   }

/*   rmBuildConnection(rampID); */

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(2300);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);

      rmSetAreaMinBlobs(id, 2);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 20.0);
      rmSetAreaMaxBlobDistance(id, 30.0);
      rmSetAreaCoherence(id, 0.7);
      rmSetAreaCliffType(id, "Greek");
      rmSetAreaCliffEdge(id, 2, 0.45, 0.2, 1.0, 1);
      rmSetAreaCliffPainting(id, false, true, true, 1.5, true);
/*      rmAddAreaCliffEdgeAvoidClass(id, classConnection, 1.0); */
      rmAddAreaConstraint(id, lakeConstraint);
      rmAddAreaConstraint(id, edgeConstraint);
      rmSetAreaCliffHeight(id, 7, 1.0, 0.5);
      rmSetAreaSmoothDistance(id, 20);
      rmAddAreaConstraint(id, playerConstraint);
      rmSetAreaLocPlayer(id, i);
   }

   // Build the areas.
   rmBuildAllAreas();

  // Text
   rmSetStatusText("",0.40);

   // Beautification sub area.
   int grassID =0;
   int patch = 0;
   int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", patch, 4.0);
   for(i=1; <cNumberPlayers*12)
   {
      patch=rmCreateArea("patch"+i);
      rmSetAreaWarnFailure(patch, false);
      if(cNumberNonGaiaPlayers > 5)
         rmSetAreaSize(patch, rmAreaTilesToFraction(50), rmAreaTilesToFraction(150));
      else
         rmSetAreaSize(patch, rmAreaTilesToFraction(90), rmAreaTilesToFraction(200));
      rmSetAreaTerrainType(patch, "GrassDirt75");
      rmAddAreaTerrainLayer(patch, "GrassB", 1, 2);
      rmAddAreaTerrainLayer(patch, "GrassDirt25", 0, 1);
      rmSetAreaMinBlobs(patch, 2);
      rmSetAreaMaxBlobs(patch, 2);
      rmSetAreaMinBlobDistance(patch, 5.0);
      rmSetAreaMaxBlobDistance(patch, 10.0);
      rmSetAreaCoherence(patch, 0.0);
      rmAddAreaConstraint(patch, lakeConstraint);
      rmAddAreaConstraint(patch, playerConstraint);
      rmBuildArea(patch);

      grassID=rmCreateObjectDef("grass"+i);
      rmAddObjectDefItem(grassID, "grass", rmRandFloat(2,4), 2.0);
      rmAddObjectDefItem(grassID, "rock limestone sprite", rmRandInt(0,2), 3.0);
      rmAddObjectDefItem(grassID, "flowers", rmRandInt(0,6), 5.0);
      rmAddObjectDefConstraint(grassID, stayInPatch);
      rmSetObjectDefMinDistance(grassID, 0.0);
      rmSetObjectDefMaxDistance(grassID, 0.0);
      rmPlaceObjectDefInArea(grassID, 0, rmAreaID("patch"+i), 1);
   }

   for(i=1; <cNumberPlayers*12)
   {
      // Beautification sub area.
      int patch2=rmCreateArea("patch dirt"+i);
      rmSetAreaWarnFailure(patch2, false);
      rmSetAreaSize(patch2, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
      rmSetAreaTerrainType(patch2, "GrassDirt50");
      rmAddAreaTerrainLayer(patch2, "GrassDirt25", 0, 3);
      rmSetAreaMinBlobs(patch2, 2);
      rmSetAreaMaxBlobs(patch2, 5);
      rmSetAreaMinBlobDistance(patch2, 16.0);
      rmSetAreaMaxBlobDistance(patch2, 40.0);
      rmSetAreaCoherence(patch2, 0.0);
      rmAddAreaConstraint(patch2, lakeConstraint);
      rmAddAreaConstraint(patch2, playerConstraint);
      rmBuildArea(patch2);
   }

   for(i=1; <cNumberPlayers)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
      rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(400));
      rmSetAreaLocPlayer(id2, i);
      rmSetAreaTerrainType(id2, "GreekRoadA");
      rmAddAreaTerrainLayer(id2, "GrassDirt50", 0, 1);
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmAddAreaConstraint(id2, avoidImpassableLand);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 1.0);
      rmSetAreaSmoothDistance(id2, 20);

      rmBuildArea(id2);
   }

   // Slight Elevation
   int numTries=30*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(30), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
      rmSetAreaTerrainType(elevID, "GrassDirt50");
      rmAddAreaTerrainLayer(elevID, "GrassDirt25", 0, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaHeightBlend(elevID, 1.0);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, patchPlayerConstraint);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==5)
            break;
      }
      else
         failCount=0;
   }
  
  

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);


   // Ramp Towers.

   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 8.0);
   for(i=1; <cNumberPlayers)
   {
      int startingTowerID=rmCreateObjectDef("Starting tower"+i);
      int towerRampConstraint=rmCreateCliffRampConstraint("onCliffRamp"+i, rmAreaID("player"+i));
      int towerRampEdgeConstraint=rmCreateCliffEdgeMaxDistanceConstraint("nearCliffEdge"+i, rmAreaID("player"+i), 2);
      rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
      rmAddObjectDefConstraint(startingTowerID, avoidTower);
      rmAddObjectDefConstraint(startingTowerID, towerRampConstraint);
      rmAddObjectDefConstraint(startingTowerID, towerRampEdgeConstraint);
      rmAddObjectDefToClass(startingTowerID, classTower);
      rmPlaceObjectDefInArea(startingTowerID, i, rmAreaID("player"+i), 6);

      /* backup to try again */
      if(rmGetNumberUnitsPlaced(startingTowerID) < 4)
      {
         int startingTowerID2=rmCreateObjectDef("Less Optimal starting tower"+i);
         rmAddObjectDefItem(startingTowerID2, "tower", 1, 0.0);
         rmAddObjectDefConstraint(startingTowerID2, avoidTower);
         rmAddObjectDefConstraint(startingTowerID2, towerRampConstraint);
         rmAddObjectDefToClass(startingTowerID2, classTower);
         rmPlaceObjectDefInArea(startingTowerID2, i, rmAreaID("player"+i), 1);

      }


   }

   // Settlements.

   id=rmAddFairLoc("Settlement", false, false, 60, 140, 60, 40); /* forward outside */
   rmAddObjectDefConstraint(id, SettlementAvoidImpassableLand);
   rmAddObjectDefConstraint(id, playerConstraint);


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
   rmSetStatusText("",0.60);


   // Starting forest
   for(i=1; <cNumberPlayers)
   {
      int playerForestID=rmCreateArea("playerForest"+i, rmAreaID("player"+i));
      rmSetAreaSize(playerForestID, rmAreaTilesToFraction(60), rmAreaTilesToFraction(60));
      if(rmRandFloat(0.0, 1.0)<0.7)
         rmSetAreaForestType(playerForestID, "oak forest");
      else
         rmSetAreaForestType(playerForestID, "autumn oak forest");
      rmAddAreaConstraint(playerForestID, shortAvoidImpassableLand);
      rmAddAreaConstraint(playerForestID, avoidBuildings);
      rmAddAreaConstraint(playerForestID, setAvoidTower);
      rmAddAreaToClass(playerForestID, classForest);
      rmAddAreaToClass(playerForestID, classFirstForest);
      rmSetAreaWarnFailure(playerForestID, false);
      rmSetAreaMinBlobs(playerForestID, 2);
      rmSetAreaMaxBlobs(playerForestID, 2);
      rmSetAreaMinBlobDistance(playerForestID, 10.0);
      rmSetAreaMaxBlobDistance(playerForestID, 15.0);
      rmSetAreaCoherence(playerForestID, 0.0);

      rmBuildArea(playerForestID);
   }

   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(medSettlementID, 0, rmAreaID("player"+i), 1);
   }


   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));

   // Gold
   rmPlaceObjectDefPerPlayer(closeGoldID, true, 1);

   // Goats
   rmPlaceObjectDefPerPlayer(closeGoatsID, true, rmRandInt(2,3));

   //Supa high poly chickens
   rmPlaceObjectDefPerPlayer(closeChickensID, true, 1);

   for(i=1; < cNumberPlayers)
   {   
      rmPlaceObjectDefInArea(statueID, i, rmAreaID("Player inner"+i), 1);   
   }

  // Text
   rmSetStatusText("",0.80);

   // Medium stuff

   // Goats
   rmPlaceObjectDefPerPlayer(mediumGoatsID, false, rmRandInt(0,2));

   // Far things.

   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2, 4));

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false, 1);

   // Goats.
   rmPlaceObjectDefAtLoc(farGoatsID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*rmRandInt(2, 4));

   // Berries.
   rmPlaceObjectDefPerPlayer(farBerriesID, false, 2);

   // Bonus huntable stuff.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
  
   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);




   // Forest.
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 35.0);
   int count=0;
   numTries=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
      rmSetAreaWarnFailure(forestID, false);
      if(rmRandFloat(0.0, 1.0)<0.7)
            rmSetAreaForestType(forestID, "oak forest");
      else
            rmSetAreaForestType(forestID, "autumn oak forest");
      rmAddAreaConstraint(forestID, allObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, playerConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand); 
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 3);
      rmSetAreaMaxBlobs(forestID, 5);
      rmSetAreaMinBlobDistance(forestID, 20.0);
      rmSetAreaMaxBlobDistance(forestID, 20.0);
      rmSetAreaCoherence(forestID, 0.0);


      // Hill trees?
      if(rmRandFloat(0.0, 1.0)<0.3)
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


   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 8.0);
   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - mahi", 1, 0.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
   rmAddObjectDefConstraint(fishID, fishLand);
   if(lake == 1)
      rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, rmRandInt(0,4));

   // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);

   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 50*cNumberNonGaiaPlayers);

   int rock2ID=rmCreateObjectDef("rock2");
   rmAddObjectDefItem(rock2ID, "rock limestone small", 1, 1.0);
   rmAddObjectDefItem(rock2ID, "rock limestone sprite", 3, 3.0);
   rmSetObjectDefMinDistance(rock2ID, 0.0);
   rmSetObjectDefMaxDistance(rock2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rock2ID, avoidAll);
   rmAddObjectDefConstraint(rock2ID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rock2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int decorationID=rmCreateObjectDef("water decoration");
   rmAddObjectDefItem(decorationID, "water decoration", 3, 5.0);
   rmSetObjectDefMinDistance(decorationID, 0.0);
   rmSetObjectDefMaxDistance(decorationID, rmXFractionToMeters(0.5));
   if(lake==1)
      rmPlaceObjectDefAtLoc(decorationID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);

}  

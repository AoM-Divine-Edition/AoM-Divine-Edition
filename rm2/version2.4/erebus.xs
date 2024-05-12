// EREBUS

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


   // Init map
   rmSetSeaType("styx river");
   int styx = 0;   
   if(rmRandFloat(0,1) < 0.3)
   {
      styx = 1;
      rmSetSeaLevel(5);
      rmTerrainInitialize("water");
   }
   else
   {
      rmTerrainInitialize("HadesCliff");
      rmSetSeaLevel(-2);
   }
   rmSetLightingSet("erebus");
   rmSetGaiaCiv(cCivHades);

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("classHill");
   int teamClass=rmDefineClass("teamClass");
   rmDefineClass("starting settlement");
   int patchClass=rmDefineClass("patchClass");
   int connectionClass=rmDefineClass("connection");
   int pathableClass=rmDefineClass("pathableClass");

    // -------------Define constraints

   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
   int lavaCliffConstraint=rmCreateTerrainDistanceConstraint("avoid passable land", "land", true, 6.0);
   int pathableConstraint=rmCreateClassDistanceConstraint("fire stay in river", pathableClass, 6);
   int patchConstraint=rmCreateClassDistanceConstraint("patch vs patch", patchClass, 10);

   // Settlement constraint.
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 23.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 20.0);

   // Herd animals
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 6.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 8.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int shortAvoidBuildings=rmCreateTypeDistanceConstraint("short avoid buildings", "Building", 20.0);
   int connectionConstraint=rmCreateClassDistanceConstraint("stay away from connection", connectionClass, 4.0);

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
   rmSetObjectDefMinDistance(startingGoldID, 25.0);
   rmSetObjectDefMaxDistance(startingGoldID, 30.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine dead", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   int closeBoarID=rmCreateObjectDef("close boar");
   rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(3,5), 4);
   rmSetObjectDefMinDistance(closeBoarID, 16.0);
   rmSetObjectDefMaxDistance(closeBoarID, 24.0);

   // Medium Objects

   // Text
   rmSetStatusText("",0.10);

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, connectionConstraint);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);

   int mediumBoarID=rmCreateObjectDef("medium boar");
   rmAddObjectDefItem(mediumBoarID, "boar", rmRandInt(2, 4), 4.0);
   rmSetObjectDefMinDistance(mediumBoarID, 70.0);
   rmSetObjectDefMaxDistance(mediumBoarID, 90.0);
   rmAddObjectDefConstraint(mediumBoarID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(mediumBoarID, avoidHerdable);
   rmAddObjectDefConstraint(mediumBoarID, farStartingSettleConstraint);

   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, connectionConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
  
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(3,6), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);

   // avoid TCs and other animals
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "serpent", 4, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "serpent", 2, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, avoidFood);

   int farPredator2ID=rmCreateObjectDef("far 2 predator");
   predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredator2ID, "shade of erebus", 4, 4.0);
   else
      rmAddObjectDefItem(farPredator2ID, "shade of erebus", 2, 4.0);
   rmSetObjectDefMinDistance(farPredator2ID, 50.0);
   rmSetObjectDefMaxDistance(farPredator2ID, 100.0);
   rmAddObjectDefConstraint(farPredator2ID, avoidPredator);
   rmAddObjectDefConstraint(farPredator2ID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(farPredator2ID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredator2ID, avoidFood);
   
   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "pine dead", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);

   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 60.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);

   // -------------------------------------------------------------Done defining objects

   // Cheesy "circular" placement of players.
   if(cNumberNonGaiaPlayers > 8)
      rmPlacePlayersCircular(0.35, 0.45, rmDegreesToRadians(5.0));
   else
      rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(5.0));

   int shallowsID=rmCreateConnection("shallows");
   if(cNumberNonGaiaPlayers < 6)
      rmSetConnectionType(shallowsID, cConnectPlayers, true, 1.0);
   else
      rmSetConnectionType(shallowsID, cConnectPlayers, false, 1.0);
   rmSetConnectionWidth(shallowsID, 20, 2);
   rmSetConnectionBaseHeight(shallowsID, 7.0);
   rmAddConnectionToClass(shallowsID, pathableClass);
   rmSetConnectionSmoothDistance(shallowsID, 3.0);
   rmAddConnectionTerrainReplacement(shallowsID, "Black", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(shallowsID, "Hades3", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(shallowsID, "Hades4", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(shallowsID, "Hades5", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(shallowsID, "Hades7", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(shallowsID, "HadesCliff", "Hadesbuildable1");
   rmSetConnectionTerrainCost(shallowsID, "Hades3", 10);
   rmSetConnectionTerrainCost(shallowsID, "Hades4", 10); 
   rmSetConnectionTerrainCost(shallowsID, "Hades5", 10); 
   rmSetConnectionTerrainCost(shallowsID, "Hades7", 10); 
 
   int extraShallowsID=rmCreateConnection("extra shallows for small maps");
   if(cNumberNonGaiaPlayers < 4)
      rmSetConnectionType(extraShallowsID, cConnectAreas, true, 1.0);
   else
      rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.75);
   rmSetConnectionWidth(extraShallowsID, 20, 2);
   rmSetConnectionBaseHeight(extraShallowsID, 7.0);
   rmAddConnectionToClass(extraShallowsID, pathableClass);
   rmSetConnectionSmoothDistance(extraShallowsID, 3.0);
/*   rmAddConnectionStartConstraint(extraShallowsID, playerConstraint);
   rmAddConnectionEndConstraint(extraShallowsID, playerConstraint); */
   rmSetConnectionPositionVariance(extraShallowsID, -1.0);
   rmAddConnectionTerrainReplacement(extraShallowsID, "Black", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(extraShallowsID, "Hades3", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(extraShallowsID, "Hades4", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(extraShallowsID, "Hades5", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(extraShallowsID, "Hades7", "Hadesbuildable1");
   rmAddConnectionTerrainReplacement(extraShallowsID, "HadesCliff", "Hadesbuildable1");

   float playerFraction=rmAreaTilesToFraction(9000);
   for(i=1; <cNumberPlayers)
   {
      int id=rmCreateArea("Player"+i);

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);
      rmAddAreaToClass(id, pathableClass);
      rmSetAreaWarnFailure(id, false);

      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 3);
      rmSetAreaMinBlobDistance(id, 20.0);
      rmSetAreaMaxBlobDistance(id, 20.0);
      rmSetAreaCoherence(id, 0.0);

      rmSetAreaBaseHeight(id, 7.0);
/*      rmSetAreaHeightBlend(id, 1); */

      // Add constraints.
      rmAddAreaConstraint(id, playerConstraint);
      rmAddConnectionArea(extraShallowsID, id);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, "Hadesbuildable1");
      if(styx == 0)
         rmAddAreaTerrainLayer(id, "HadesCliff", 0, 2);
      rmSetAreaTerrainLayerVariance(id, false);
   }

   // Build the areas.
   rmBuildAllAreas();
   rmBuildConnection(shallowsID);
  /* if(cNumberNonGaiaPlayers < 5) */
      rmBuildConnection(extraShallowsID);
           
  
 // initial dress up of lava river
   int failCount = 0;
   for(j=0; <cNumberNonGaiaPlayers*20)
   {
      int lavaPatch=rmCreateArea("patch"+j);
      rmSetAreaSize(lavaPatch, rmAreaTilesToFraction(25), rmAreaTilesToFraction(50));
      rmSetAreaWarnFailure(lavaPatch, false);
      if(rmRandFloat(0,1)<0.25)
      {
         rmSetAreaTerrainType(lavaPatch, "Hades4");
         rmAddAreaTerrainLayer(lavaPatch, "Hades3", 0, 1);
      }
      else
      {
         rmSetAreaTerrainType(lavaPatch, "Hades7");
         rmAddAreaTerrainLayer(lavaPatch, "Hades5", 0, 1);
/*         rmAddAreaTerrainLayer(lavaPatch, "Hades3", 0, 1); */
      }      
      rmSetAreaMinBlobs(lavaPatch, 1);
      rmSetAreaMaxBlobs(lavaPatch, 5);
      rmAddAreaToClass(lavaPatch, patchClass);
/*      rmAddAreaConstraint(lavaPatch, patchConstraint); */
      rmAddAreaConstraint(lavaPatch, lavaCliffConstraint);
      rmSetAreaMinBlobDistance(lavaPatch, 16.0);
      rmSetAreaMaxBlobDistance(lavaPatch, 40.0);
      rmSetAreaCoherence(lavaPatch, 0.0);
      if(styx == 0)
      {
         if(rmBuildArea(lavaPatch)==false)
            {
               // Stop trying once we fail 3 times in a row.
               failCount++;
               if(failCount==3)
                  break;
            }
            else
               failCount=0;
      }
   }
   
   // Beautification
   for(i=1; <cNumberPlayers)
   {
      for(j=0; <(rmRandInt(2, 8)))
      {
         int id2=rmCreateArea("random"+i +j,rmAreaID("player"+i));
         rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
         rmSetAreaTerrainType(id2, "Hadesbuildable2");
         rmSetAreaWarnFailure(id2, false);
         rmAddAreaConstraint(id2, avoidImpassableLand);
         rmSetAreaMinBlobs(id2, 1);
         rmSetAreaMaxBlobs(id2, 5);
         rmSetAreaMinBlobDistance(id2, 16.0);
         rmSetAreaMaxBlobDistance(id2, 40.0);
         rmSetAreaCoherence(id2, 0.3);
         rmBuildArea(id2);
      }
   }


   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements.
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10, true); /* bool forward bool inside */
   rmAddFairLocConstraint(id, avoidImpassableLand);

   id=rmAddFairLoc("Settlement", true, false, 60, 90, 40, 10, true);
   rmAddFairLocConstraint(id, avoidImpassableLand);
   
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

      // Slight Elevation
   failCount=0;
   for(j=1; <cNumberPlayers)
   {
      for(i=0; <5)
      {
         int elevID=rmCreateArea("wrinkle"+i +j, rmAreaID("player"+j));
         rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
 /*        rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0)); */
         rmSetAreaWarnFailure(elevID, false);
         rmSetAreaBaseHeight(elevID, rmRandFloat(8.0, 10.0));
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
   }

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));

   
   // Cliffage

   int classCliff=rmDefineClass("cliff");
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 20.0);
   int shortCliffConstraint=rmCreateClassDistanceConstraint("stuff v cliff", rmClassID("cliff"), 10.0);
   failCount=0;
   
   for(j=1; <cNumberPlayers)
   {
      for(i=0; <3)
      {
         int cliffID=rmCreateArea("cliff"+i +j, rmAreaID("player"+j));
         rmSetAreaWarnFailure(cliffID, false);
         rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
         rmSetAreaCliffType(cliffID, "Hades");
         rmAddAreaConstraint(cliffID, cliffConstraint);
         rmAddAreaConstraint(cliffID, avoidImpassableLand);
         rmAddAreaToClass(cliffID, classCliff);
         rmAddAreaConstraint(cliffID, avoidBuildings);
         rmSetAreaMinBlobs(cliffID, 10);
         rmSetAreaMaxBlobs(cliffID, 10);
         rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
         rmSetAreaCliffHeight(cliffID, 9, 1.0, 1.0);
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
   }

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // cows
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));


   rmPlaceObjectDefPerPlayer(mediumBoarID, false, rmRandInt(1, 2));

            
   // Far things.

   // Gold.
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("player"+i), rmRandInt(3, 4));
   }

   // Relics.
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i), 2);
   }

   // Bonus huntable.
   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i), rmRandInt(2, 4));
   }

  

   // Predators
      for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("player"+i), 1);
   }

   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(farPredator2ID, 0, rmAreaID("player"+i), 1);
   }

   // Text
   rmSetStatusText("",0.20);

   

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int count=0;
   failCount=0;

   for(j=1; <cNumberPlayers)
   {
      for(i=0; <7)
      {
         int forestID=rmCreateArea("forest"+i +j, rmAreaID("player"+j));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "hades forest");
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint);
         rmAddAreaConstraint(forestID, avoidImpassableLand);
         rmAddAreaToClass(forestID, classForest);
         rmAddAreaConstraint(forestID, avoidBuildings);
      
         rmSetAreaMinBlobs(forestID, 2);
         rmSetAreaMaxBlobs(forestID, 4);
         rmSetAreaMinBlobDistance(forestID, 16.0);
         rmSetAreaMaxBlobDistance(forestID, 20.0);
         rmSetAreaCoherence(forestID, 0.0);

         // Hill trees?
         if(rmRandFloat(0.0, 1.0)<0.2)
            rmSetAreaBaseHeight(forestID, rmRandFloat(6.0, 8.0));

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
   }

   // Text
   rmSetStatusText("",0.40);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 40*cNumberNonGaiaPlayers);

   // Text
   rmSetStatusText("",0.60);

   // Rocks
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
  
   int columnID=rmCreateObjectDef("columns");
   rmAddObjectDefItem(columnID, "ruins", rmRandInt(1,4), 6.0);
   rmAddObjectDefItem(columnID, "columns broken", rmRandInt(1,2), 4.0);
   rmAddObjectDefItem(columnID, "rock limestone sprite", rmRandInt(6,12), 10.0);
   rmAddObjectDefItem(columnID, "skeleton", rmRandInt(4,9), 10.0);
   rmSetObjectDefMinDistance(columnID, 0.0);
   rmSetObjectDefMaxDistance(columnID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(columnID, avoidAll);
   rmAddObjectDefConstraint(columnID, shortAvoidSettlement);
   rmAddObjectDefConstraint(columnID, avoidImpassableLand);
   rmAddObjectDefConstraint(columnID, shortCliffConstraint);
   rmPlaceObjectDefAtLoc(columnID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

   int stalagmiteID=rmCreateObjectDef("stalagmite");
   rmAddObjectDefItem(stalagmiteID, "stalagmite", 1, 0.0);
   rmSetObjectDefMinDistance(stalagmiteID, 0.0);
   rmSetObjectDefMaxDistance(stalagmiteID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(stalagmiteID, avoidAll);
   rmAddObjectDefConstraint(stalagmiteID, shortAvoidSettlement);
   if(styx==0)
      rmAddObjectDefConstraint(stalagmiteID, avoidImpassableLand);
   rmAddObjectDefConstraint(stalagmiteID, shortCliffConstraint);
   rmPlaceObjectDefAtLoc(stalagmiteID, 0, 0.5, 0.5, 7*cNumberNonGaiaPlayers);

   int stalagmite2ID=rmCreateObjectDef("stalagmite2");
   rmAddObjectDefItem(stalagmite2ID, "stalagmite", 3, 1.0);
   rmSetObjectDefMinDistance(stalagmite2ID, 0.0);
   rmSetObjectDefMaxDistance(stalagmite2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(stalagmite2ID, avoidAll);
   if(styx==0)
      rmAddObjectDefConstraint(stalagmite2ID, avoidImpassableLand);
   rmAddObjectDefConstraint(stalagmite2ID, shortAvoidSettlement);
   rmAddObjectDefConstraint(stalagmite2ID, shortCliffConstraint);
   rmPlaceObjectDefAtLoc(stalagmite2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",0.80);

   int stalagmite3ID=rmCreateObjectDef("stalagmite3");
   rmAddObjectDefItem(stalagmite3ID, "stalagmite", 5, 2.0);
   rmSetObjectDefMinDistance(stalagmite3ID, 0.0);
   rmSetObjectDefMaxDistance(stalagmite3ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(stalagmite3ID, avoidAll);
   rmAddObjectDefConstraint(stalagmite3ID, shortAvoidSettlement);
   if(styx==0)
      rmAddObjectDefConstraint(stalagmite3ID, avoidImpassableLand);
   rmAddObjectDefConstraint(stalagmite3ID, shortCliffConstraint);
   rmPlaceObjectDefAtLoc(stalagmite3ID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int flameID=rmCreateObjectDef("fire");
   rmAddObjectDefItem(flameID, "fire Hades", 1, 0.0);
   rmSetObjectDefMinDistance(flameID, 0.0);
   rmSetObjectDefMaxDistance(flameID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(flameID, pathableConstraint);
   rmAddObjectDefConstraint(flameID, connectionConstraint);
   if(styx==0)
      rmPlaceObjectDefAtLoc(flameID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);

   int bubbleID=rmCreateObjectDef("bubble");
   rmAddObjectDefItem(bubbleID, "lava bubbling", 1, 0.0);
   rmSetObjectDefMinDistance(bubbleID, 0.0);
   rmSetObjectDefMaxDistance(bubbleID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bubbleID, pathableConstraint);
   rmAddObjectDefConstraint(bubbleID, connectionConstraint);
   if(styx==0)
      rmPlaceObjectDefAtLoc(bubbleID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

   // Birds
   int farHarpyID=rmCreateObjectDef("far birds");
   rmAddObjectDefItem(farHarpyID, "harpy", 1, 0.0);
   rmSetObjectDefMinDistance(farHarpyID, 0.0);
   rmSetObjectDefMaxDistance(farHarpyID, rmXFractionToMeters(0.5));
   rmPlaceObjectDefPerPlayer(farHarpyID, false, 2); 

   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(rockID, shortCliffConstraint);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   // Text
   rmSetStatusText("",1.00);

}  

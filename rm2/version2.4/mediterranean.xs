// MEDITERRANEAN

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
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmSetSeaType("mediterranean sea");
   rmTerrainInitialize("GrassDirt25");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classPlayerCore=rmDefineClass("player core");
   rmDefineClass("corner");
   rmDefineClass("classHill");
   rmDefineClass("center");
   rmDefineClass("starting settlement");


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
   
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30.0);
   int smallMapPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a lot", classPlayer, 70.0);
 
   // Center constraint.
   int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 15.0);
   int wideCenterConstraint=rmCreateClassDistanceConstraint("elevation avoids center", rmClassID("center"), 50.0);

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);
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
   int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 10.0);
  
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
   
   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   // pigs
   float pigNumber=rmRandFloat(2, 4);
   int closePigsID=rmCreateObjectDef("close pigs");
   rmAddObjectDefItem(closePigsID, "pig", pigNumber, 2.0);
   rmSetObjectDefMinDistance(closePigsID, 25.0);
   rmSetObjectDefMaxDistance(closePigsID, 30.0);
   rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closePigsID, avoidFood);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   if(rmRandFloat(0,1)<0.8)
      rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(6,10), 5.0);
   else
      rmAddObjectDefItem(closeChickensID, "berry bush", rmRandInt(4,6), 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeBoarID=rmCreateObjectDef("close Boar");
   if(rmRandFloat(0,1)<0.7)
      rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(1,3), 4.0);
   else
      rmAddObjectDefItem(closeBoarID, "aurochs", rmRandInt(1,2), 2.0);
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);
   rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);


   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
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
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
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
   
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(2,3), 4.0);
   else if(bonusChance<0.8)
      rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(6,8), 8.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "aurochs", rmRandInt(1,3), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
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

   // -------------Done defining objects

  // Text
   rmSetStatusText("",0.20);

   // Cheesy "circular" placement of players.
   rmSetTeamSpacingModifier(0.75);
   if(cNumberNonGaiaPlayers <4)
      rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));
   else
      rmPlacePlayersCircular(0.43, 0.45, rmDegreesToRadians(5.0));

   // Create a center water area -- the mediterranean part.
   int centerID=rmCreateArea("center");
   rmSetAreaSize(centerID, 0.35, 0.35);
   rmSetAreaLocation(centerID, 0.5, 0.5);
   rmSetAreaWaterType(centerID, "mediterranean sea");
   rmAddAreaToClass(centerID, rmClassID("center"));
   rmSetAreaBaseHeight(centerID, 0.0);
   rmSetAreaMinBlobs(centerID, 8);
   rmSetAreaMaxBlobs(centerID, 10);
   rmSetAreaMinBlobDistance(centerID, 10);
   rmSetAreaMaxBlobDistance(centerID, 20);
   rmSetAreaSmoothDistance(centerID, 50);
   rmSetAreaCoherence(centerID, 0.25);
   rmBuildArea(centerID); 

   // monkey island
   float monkeyChance=rmRandFloat(0, 1);
   if(cNumberPlayers > 3)
   {
      if(monkeyChance < 0.66)   
         {
            int monkeyIslandID=rmCreateArea("monkeyisland");
            rmSetAreaSize(monkeyIslandID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(300));
            rmSetAreaLocation(monkeyIslandID, 0.5, 0.5);
            rmSetAreaTerrainType(monkeyIslandID, "shorelinemediterraneanb");
            rmSetAreaBaseHeight(monkeyIslandID, 2.0);
            rmSetAreaSmoothDistance(monkeyIslandID, 10);
            rmSetAreaHeightBlend(monkeyIslandID, 2);
            rmSetAreaCoherence(monkeyIslandID, 1.0);
            rmBuildArea(monkeyIslandID);

            int monkeyID=rmCreateObjectDef("monkey");
            rmAddObjectDefItem(monkeyID, "baboon", 1, 2.0);
            rmAddObjectDefItem(monkeyID, "palm", 1, 2.0);
            rmAddObjectDefItem(monkeyID, "gold mine", 1, 8.0);
            rmSetObjectDefMinDistance(monkeyID, 0.0);
            rmSetObjectDefMinDistance(monkeyID, 20.0);
            rmPlaceObjectDefAtLoc(monkeyID, 0, 0.5, 0.5);
         }
   }

  // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(3200);
/*   if(cNumberNonGaiaPlayers < 4)
      playerFraction=rmAreaTilesToFraction(3000); */

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
      if(cNumberNonGaiaPlayers < 4)
         rmAddAreaConstraint(id, smallMapPlayerConstraint); 
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "grassDirt25");
   }

   // Build the areas.
   rmBuildAllAreas();

   // Build the areas.

   for(i=1; <cNumberPlayers)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
      rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaLocPlayer(id2, i);
      rmSetAreaTerrainType(id2, "GrassDirt50");

      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);

      rmBuildArea(id2);
   }

   for(i=1; <cNumberPlayers*8)
   {
      // Beautification sub area.
      int id3=rmCreateArea("Grass patch"+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaTerrainType(id3, "GrassA");
      rmAddAreaConstraint(id3, centerConstraint);
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.0);

      rmBuildArea(id3);
   }

   int flowerID =0;
   int id4 = 0;
   int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", id4, 4.0);
   for(i=1; <cNumberPlayers*6)
   {
      // Beautification sub area.
      id4=rmCreateArea("Grass patch 2"+i);
      rmSetAreaSize(id4, rmAreaTilesToFraction(5), rmAreaTilesToFraction(20));
      rmSetAreaTerrainType(id4, "GrassB");
      rmAddAreaConstraint(id4, centerConstraint);
      rmSetAreaMinBlobs(id4, 1);
      rmSetAreaMaxBlobs(id4, 5);
      rmSetAreaWarnFailure(id4, false);
      rmSetAreaMinBlobDistance(id4, 16.0);
      rmSetAreaMaxBlobDistance(id4, 40.0);
      rmSetAreaCoherence(id4, 0.0);

      rmBuildArea(id4);

      flowerID=rmCreateObjectDef("grass"+i);
      rmAddObjectDefItem(flowerID, "grass", rmRandFloat(2,4), 5.0);
      rmAddObjectDefItem(flowerID, "flowers", rmRandInt(0,6), 5.0);
      rmAddObjectDefConstraint(flowerID, stayInPatch);
      rmSetObjectDefMinDistance(flowerID, 0.0);
      rmSetObjectDefMaxDistance(flowerID, 0.0);
      rmPlaceObjectDefInArea(flowerID, 0, rmAreaID("grass patch 2"+i), 1);
   }


   rmPlaceObjectDefPerPlayer(playerFishID, false);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

   fishID=rmCreateObjectDef("fish2");
   rmAddObjectDefItem(fishID, "fish - perch", 2, 6.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",0.40);
 
   int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
   int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
   int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
   int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);

  // Text
   rmSetStatusText("",0.42);

   int sharkID=rmCreateObjectDef("shark");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
   else
      rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
   rmSetObjectDefMinDistance(sharkID, 0.0);
   rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(sharkID, sharkVssharkID);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
   rmAddObjectDefConstraint(sharkID, sharkLand);
   rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5); 

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

    // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Because player areas are so large on this map, elev needs to avoid buildings instead of player areas

   // Elev.
   int numTries=6*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaToClass(elevID, rmClassID("classHill"));
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, centerConstraint);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "GrassDirt50"); 
/*      rmSetAreaTerrainType(elevID, "SnowA"); */
      rmSetAreaBaseHeight(elevID, rmRandFloat(4.0, 7.0));
      rmSetAreaHeightBlend(elevID, 3);
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
   numTries=15*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, centerConstraint);
      rmAddAreaConstraint(elevID, shortHillConstraint);

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

  // Text
   rmSetStatusText("",0.60);

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


   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2,6));
   
   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Goats
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   // Chickens or berries.
   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   // Pigs
      
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumPigsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
   
   // Far things.
   
   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, 3);

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 
   
   // Pigs
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(farPigsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 3);

   // Bonus huntable.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

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
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaForestType(forestID, "oak forest");
      else
         rmSetAreaForestType(forestID, "pine forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
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
   rmSetStatusText("",0.80);

   // Decoration
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int deerID=rmCreateObjectDef("lonely deer");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(deerID, "deer", rmRandInt(1,2), 1.0);
   else
      rmAddObjectDefItem(deerID, "aurochs", 1, 0.0);
   rmSetObjectDefMinDistance(deerID, 0.0);
   rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(deerID, avoidAll);
   rmAddObjectDefConstraint(deerID, avoidBuildings);
   rmAddObjectDefConstraint(deerID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

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

   int rockID2=rmCreateObjectDef("rock group");
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, avoidRock);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
   
   int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 14.0);
   int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 10.0);
   int kelpID=rmCreateObjectDef("seaweed");
   rmAddObjectDefItem(kelpID, "seaweed", 12, 6.0);
   rmSetObjectDefMinDistance(kelpID, 0.0);
   rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(kelpID, avoidAll);
   rmAddObjectDefConstraint(kelpID, nearshore);
   rmAddObjectDefConstraint(kelpID, farshore);
   rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

   int kelp2ID=rmCreateObjectDef("seaweed 2");
   rmAddObjectDefItem(kelp2ID, "seaweed", 5, 3.0);
   rmSetObjectDefMinDistance(kelp2ID, 0.0);
   rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(kelp2ID, avoidAll);
   rmAddObjectDefConstraint(kelp2ID, nearshore);
   rmAddObjectDefConstraint(kelp2ID, farshore);
   rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);
      
}  





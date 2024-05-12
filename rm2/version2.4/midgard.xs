// MIDGARD

// Main entry point for random map script
void main(void)
{

   // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=12000;
   if(cMapSize == 1)
   {
      playerTiles = 15600;
      rmEchoInfo("Large map");
   }

   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);
   float waterType=rmRandFloat(0, 1);
   if(waterType<0.5)   
      rmSetSeaType("North Atlantic Ocean");
   else
      rmSetSeaType("Norwegian Sea");

   // Init map.
   rmTerrainInitialize("water");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("starting settlement");
   int classIce=rmDefineClass("ice");
   int classBonusHuntable=rmDefineClass("bonus huntable");
   rmDefineClass("classHill");

   // Grow a big continent.
   int centerID=rmCreateArea("center");
   rmSetAreaSize(centerID, 0.5, 0.55);
   rmSetAreaLocation(centerID, 0.5, 0.5);
   /*
   rmSetAreaMinBlobs(centerID, 1);
   rmSetAreaMaxBlobs(centerID, 5);
   rmSetAreaMinBlobDistance(centerID, 40.0);
   rmSetAreaMaxBlobDistance(centerID, 60.0);
   */
   rmSetAreaCoherence(centerID, 0.0);
   rmSetAreaBaseHeight(centerID, 2.0);
   rmSetAreaTerrainType(centerID, "snowA");
   rmSetAreaSmoothDistance(centerID, 30);
   rmSetAreaHeightBlend(centerID, 2);
   rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.05, 0.95, 0.95, 0.01));
   rmBuildArea(centerID);

    // -------------Define constraints

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);

   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20), 0.01);

   // Settlement constraint.
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 40.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 24.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Herd animals
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 6.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   //Hunted animals
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 30.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
   int iceConstraint=rmCreateClassDistanceConstraint("avoid ice", classIce, 5.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 15.0);
   int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 10.0);





    // Stay near shore
   int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);

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
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(startingGoldID, iceConstraint);

   int closeCowsID=rmCreateObjectDef("close Cows");
   rmAddObjectDefItem(closeCowsID, "cow", rmRandInt(0,1), 0.0);
   rmSetObjectDefMinDistance(closeCowsID, 25.0);
   rmSetObjectDefMaxDistance(closeCowsID, 30.0);
   rmAddObjectDefConstraint(closeCowsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeCowsID, avoidFood);

   int closeBerriesID=rmCreateObjectDef("close berries");
   if(rmRandFloat(0,1)<0.8)
      rmAddObjectDefItem(closeBerriesID, "berry bush", rmRandInt(4,7), 4.0);
   else
      rmAddObjectDefItem(closeBerriesID, "berry bush", rmRandInt(2,3), 2.0);
   rmSetObjectDefMinDistance(closeBerriesID, 20.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 25.0);
   rmAddObjectDefConstraint(closeBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeBerriesID, avoidFood);
   rmAddObjectDefConstraint(closeBerriesID, iceConstraint);
   
   int closeBoarID=rmCreateObjectDef("close Boar");
   float boarNumber=rmRandFloat(0, 1);
   if(boarNumber<0.3)
      rmAddObjectDefItem(closeBoarID, "boar", 2, 4.0);
   else 
      rmAddObjectDefItem(closeBoarID, "boar", 1, 4.0);
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);
   rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeBoarID, iceConstraint);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine snow", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   rmAddObjectDefConstraint(stragglerTreeID, iceConstraint);

    // player fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int playerFishID=rmCreateObjectDef("owned fish");
   rmAddObjectDefItem(playerFishID, "fish - salmon", 3, 10.0);
   rmSetObjectDefMinDistance(playerFishID, 0.0);
   rmSetObjectDefMaxDistance(playerFishID, 100.0);
   rmAddObjectDefConstraint(playerFishID, fishVsFishID);
   rmAddObjectDefConstraint(playerFishID, fishLand);

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
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoldID, iceConstraint);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);

   int numHuntable=rmRandInt(4, 8);

   int mediumDeerID=rmCreateObjectDef("medium deer");
   rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 3.0);
   rmSetObjectDefMinDistance(mediumDeerID, 60.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumDeerID, avoidFood);
   rmAddObjectDefConstraint(mediumDeerID, iceConstraint);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);

   // hunted avoids hunted and TCs
   int mediumWalrusID=rmCreateObjectDef("medium walrus");
   rmAddObjectDefItem(mediumWalrusID, "walrus", rmRandInt(3,6), 8.0);
   rmSetObjectDefMinDistance(mediumWalrusID, 50);
   rmSetObjectDefMaxDistance(mediumWalrusID, 120);
   rmAddObjectDefToClass(mediumWalrusID, classBonusHuntable);
   rmAddObjectDefConstraint(mediumWalrusID, nearShore);
   rmAddObjectDefConstraint(mediumWalrusID, farStartingSettleConstraint);

   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, iceConstraint);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
  
   int farCowID=rmCreateObjectDef("far Cow");
   rmAddObjectDefItem(farCowID, "cow", rmRandInt(1,2), 2.0);
   rmSetObjectDefMinDistance(farCowID, 80.0);
   rmSetObjectDefMaxDistance(farCowID, 150.0);
   rmAddObjectDefConstraint(farCowID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farCowID, avoidImpassableLand);
   rmAddObjectDefConstraint(farCowID, avoidHerdable);

   // pick wolves or bears as predators
   // avoid TCs and other animals
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "wolf", 2, 2.0);
   else
      rmAddObjectDefItem(farPredatorID, "bear", 1, 1.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, avoidFood);

   // This map will either use boar or deer as the extra huntable food.

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   int bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(4,9), 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(4,9), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, iceConstraint);
   
   // hunted avoids hunted and TCs
   int bonusWalrus=rmCreateObjectDef("bonus walrus");
   rmAddObjectDefItem(bonusWalrus, "walrus", rmRandInt(2,5), 8.0);
   rmSetObjectDefMinDistance(bonusWalrus, 60.0);
   rmSetObjectDefMaxDistance(bonusWalrus, 150.0);
   rmAddObjectDefConstraint(bonusWalrus, avoidBonusHuntable);
   rmAddObjectDefToClass(bonusWalrus, classBonusHuntable);
   rmAddObjectDefConstraint(bonusWalrus, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusWalrus, nearShore);
   
   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "pine snow", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, iceConstraint);

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
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);

   // -------------Done defining objects

   // Cheesy "circular" placement of players.
   if(cNumberNonGaiaPlayers > 8)
      rmPlacePlayersCircular(0.3, 0.35, rmDegreesToRadians(5.0));
   else
      rmPlacePlayersCircular(0.25, 0.3, rmDegreesToRadians(5.0));

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(3000);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i, centerID);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);
      rmAddAreaConstraint(id, playerConstraint);
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "SnowGrass50");
      rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 12);

   }

   // Text
   rmSetStatusText("",0.20);

   // Build the areas.
   rmBuildAllAreas();

   for(i=1; <cNumberPlayers*5)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Patch"+i);
      rmSetAreaSize(id2, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaTerrainType(id2, "SnowB");
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 2);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);
      rmAddAreaConstraint(id2, playerConstraint);
      rmAddAreaConstraint(id2, avoidImpassableLand);
      rmBuildArea(id2);
   }

   for(i=1; <cNumberPlayers*1.5)
   {
      int id3=rmCreateArea("Ice patch"+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(70), rmAreaTilesToFraction(200));
      rmSetAreaTerrainType(id3, "IceA");
      rmSetAreaWarnFailure(id3, false);
      rmAddAreaToClass(id3, classIce);
      rmSetAreaBaseHeight(id3, 0.0);
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 2);
      rmSetAreaMinBlobDistance(id3, 10.0);
      rmSetAreaMaxBlobDistance(id3, 10.0);
      rmSetAreaCoherence(id3, 0.0);
      rmSetAreaSmoothDistance(id3, 20);
      rmAddAreaConstraint(id3, playerConstraint);
      rmAddAreaConstraint(id3, avoidBuildings);
      rmAddAreaConstraint(id3, avoidImpassableLand);
      rmBuildArea(id3);
   }

   for(i=1; <cNumberPlayers*1.5)
   {
      // Beautification sub area.
      int id4=rmCreateArea("Smaller ice patch"+i, rmAreaID("Ice patch"+i));
      rmSetAreaSize(id4, rmAreaTilesToFraction(10), rmAreaTilesToFraction(30));
      rmSetAreaTerrainType(id4, "IceB");
      rmSetAreaWarnFailure(id4, false);
      rmAddAreaToClass(id4, classIce);
      rmSetAreaBaseHeight(id4, 0.0);
      rmSetAreaMinBlobs(id4, 1);
      rmSetAreaMaxBlobs(id4, 1);
      rmBuildArea(id4);
   }

      // Text
   rmSetStatusText("",0.40);

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Elev.
   int numTries=6*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i, centerID);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, playerConstraint);
      rmAddAreaToClass(elevID, rmClassID("classHill"));
      rmAddAreaConstraint(elevID, iceConstraint);
      rmAddAreaConstraint(elevID, shortHillConstraint);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SnowGrass25");
      rmSetAreaBaseHeight(elevID, rmRandFloat(4.0, 7.0));
      rmSetAreaHeightBlend(elevID, 2);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 6 times in a row.
         failCount++;
         if(failCount==6)
            break;
      }
      else
         failCount=0;
   }

   // Slight Elevation
   numTries=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i, centerID);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
      rmAddAreaConstraint(elevID, iceConstraint);
      rmAddAreaConstraint(elevID, shortAvoidSettlement);
      rmAddAreaConstraint(elevID, shortHillConstraint);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
      rmSetAreaHeightBlend(elevID, 1);
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

   // Settlements.
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 40); /*back inside */
   rmAddFairLocConstraint(id, avoidImpassableLand);

   if(rmRandFloat(0,1)<0.75)
   {      
      id=rmAddFairLoc("Settlement", true, true, 90, 120, 70, 30);
      rmAddFairLocConstraint(id, avoidImpassableLand);
   }
   else
   {  
      id=rmAddFairLoc("Settlement", false, true,  60, 100, 40, 30);
      rmAddFairLocConstraint(id, avoidImpassableLand);
   }

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
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 6));

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Text
   rmSetStatusText("",0.60);

   // cows
   rmPlaceObjectDefPerPlayer(closeCowsID, true);

   // Berries  
   rmPlaceObjectDefPerPlayer(closeBerriesID, true);

   // Boar.
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.7)
   rmPlaceObjectDefPerPlayer(closeBoarID, false);
   
   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));

   // player fish
   rmPlaceObjectDefPerPlayer(playerFishID, false);

   rmPlaceObjectDefPerPlayer(mediumWalrusID, false);

   rmPlaceObjectDefPerPlayer(mediumDeerID, false, 1);
            
   // Far things.

   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1, 3));

   // Relics.
   rmPlaceObjectDefPerPlayer(relicID, false);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

   // Bonus huntable.
   rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 1);

   // Herds.
   rmPlaceObjectDefPerPlayer(farCowID, false, rmRandInt(1,2));

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
   
   // Text
   rmSetStatusText("",0.80);

   // Second bonus huntable stuff.
   if(rmRandFloat(0,1)<0.75)
      rmPlaceObjectDefPerPlayer(bonusWalrus, false, 1);
   else if(cNumberNonGaiaPlayers < 8)
      rmPlaceObjectDefPerPlayer(bonusWalrus, false, 2);
   else
      rmPlaceObjectDefPerPlayer(bonusWalrus, false, 1);

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int count=0;
   numTries=8*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i, centerID);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(140));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "snow pine forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, iceConstraint); 
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 1);
      rmSetAreaMaxBlobs(forestID, 4);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 25.0);
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

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int orcaLand = rmCreateTerrainDistanceConstraint("orca land", "land", true, 20.0);
   int orcaVsOrca=rmCreateTypeDistanceConstraint("orca v orca", "orca", 20.0);
   int orcaID=rmCreateObjectDef("orca");
   rmAddObjectDefItem(orcaID, "orca", 1, 0.0);
   rmSetObjectDefMinDistance(orcaID, 0.0);
   rmSetObjectDefMaxDistance(orcaID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(orcaID, orcaLand);
   rmAddObjectDefConstraint(orcaID, orcaVsOrca);
   rmAddObjectDefConstraint(orcaID, edgeConstraint);
   rmPlaceObjectDefAtLoc(orcaID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);

   // Text
   rmSetStatusText("",0.90);

   fishID=rmCreateObjectDef("fish2");
   rmAddObjectDefItem(fishID, "fish - perch", 1, 0.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
/*   rmAddObjectDefConstraint(fishID, fishEdge); */
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
   
   // Rocks
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock granite sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   //rmAddObjectDefConstraint(rockID, avoidRock);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID, iceConstraint);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   if(waterType>=0.5)
   {
      int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
      int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
      int kelpID=rmCreateObjectDef("seaweed");
      rmAddObjectDefItem(kelpID, "seaweed", 5, 3.0);
      rmSetObjectDefMinDistance(kelpID, 0.0);
      rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(kelpID, avoidAll);
      rmAddObjectDefConstraint(kelpID, nearshore);
      rmAddObjectDefConstraint(kelpID, farshore);
      rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);

      int kelp2ID=rmCreateObjectDef("seaweed 2");
      rmAddObjectDefItem(kelp2ID, "seaweed", 2, 3.0);
      rmSetObjectDefMinDistance(kelp2ID, 0.0);
      rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(kelp2ID, avoidAll);
      rmAddObjectDefConstraint(kelp2ID, nearshore);
      rmAddObjectDefConstraint(kelp2ID, farshore);
      rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);
   }


  // Text
   rmSetStatusText("",1.0);


}  

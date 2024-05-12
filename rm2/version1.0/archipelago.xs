// Main entry point for random map script
void main(void)
{

  // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=12200;
   if(cMapSize == 1)
   {
      playerTiles = 15860;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);
   rmSetSeaType("mediterranean sea");

   // Init map.
   rmTerrainInitialize("water");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classBonusIsland=rmDefineClass("bonus island");
   int islandsX=rmDefineClass("islandsX");
   int islandsY=rmDefineClass("islandsY");
   int islandsZ=rmDefineClass("islandsZ");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");

   // -------------Define constraints
   
   // Create a edge of map constraint.
   int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20), 0.01);

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30.0);
   int shortPlayerConstraint=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 2.0);

   // Bonus area constraint.
   int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid bonus island", classBonusIsland, 50.0);

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraint.
   int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);

   // Far starting settlement constraint.
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 60.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Goats/pigs
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

   // Animals
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 15.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);

   //Island avoidance
   int islandsXvsY=rmCreateClassDistanceConstraint("island X avoids Y", islandsY, 30.0);
   int islandsYvsX=rmCreateClassDistanceConstraint("island Y avoids X", islandsX, 20.0);
   int islandsXYvsZ=rmCreateClassDistanceConstraint("islands Y and X avoid Z", islandsZ, 20.0);
   int islandsZvsX = 0;
   int islandsZvsY = 0;

   if(cNumberNonGaiaPlayers > 4)
      {
         islandsZvsX=rmCreateClassDistanceConstraint("island Z avoids X", islandsX, 25.0);
         islandsZvsY=rmCreateClassDistanceConstraint("island Z avoids Y", islandsY, 30.0); 
      }
   else
      {
         islandsZvsX=rmCreateClassDistanceConstraint("island Z avoids X", islandsX, 0.0);
         islandsZvsY=rmCreateClassDistanceConstraint("island Z avoids Y", islandsY, 0.0); 
      }

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
   rmSetObjectDefMaxDistance(startingTowerID, 25.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);

   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   // pigs
   int closePigsID=rmCreateObjectDef("close pigs");
   rmAddObjectDefItem(closePigsID, "pig", 2, 2.0);
   rmSetObjectDefMinDistance(closePigsID, 25.0);
   rmSetObjectDefMaxDistance(closePigsID, 30.0);
   rmAddObjectDefConstraint(closePigsID, avoidFood);   

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(7,10), 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeBoarID=rmCreateObjectDef("close Boar");
   float boarNumber=rmRandFloat(0, 1);
   if(boarNumber<0.3)
      rmAddObjectDefItem(closeBoarID, "boar", 1, 4.0);
   else if(boarNumber<0.6)
      rmAddObjectDefItem(closeBoarID, "boar", 2, 4.0);
   else 
      rmAddObjectDefItem(closeBoarID, "boar", 3, 6.0);
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
   rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
   
   // Far Objects

   // Settlement avoid Settlements
   int farSettlementID=rmCreateObjectDef("far settlement");
   rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
   rmSetObjectDefMinDistance(farSettlementID, 60.0);
   rmSetObjectDefMaxDistance(farSettlementID, 120.0);
   rmAddObjectDefConstraint(farSettlementID, avoidImpassableLand);
   rmAddObjectDefConstraint(farSettlementID, farAvoidSettlement);
         
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   int bonusGoldID=rmCreateObjectDef("bonus gold");
   rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(bonusGoldID, 0.0);
   rmSetObjectDefMaxDistance(bonusGoldID, 150.0);
   rmAddObjectDefConstraint(bonusGoldID, avoidGold);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(bonusGoldID, farStartingSettleConstraint);

   // pigs aboid pigs
   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);

   // player fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 30);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);

   int playerFishID=rmCreateObjectDef("owned fish");
   rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 10.0);
   rmSetObjectDefMinDistance(playerFishID, 0.0);
   rmSetObjectDefMaxDistance(playerFishID, 100.0);
   rmAddObjectDefConstraint(playerFishID, fishVsFishID);
   rmAddObjectDefConstraint(playerFishID, fishLand);
   
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
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   
   // This map will either use boar or deer as the extra huntable food.


   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "boar", 2, 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "deer", 6, 8.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
    
   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
   
   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 40.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);



   // --------------------------------------------------------------------------------Done defining objects

  // Text
   rmSetStatusText("",0.20);

   if(cNumberNonGaiaPlayers < 4)
      rmPlacePlayersCircular(0.23, 0.25, rmDegreesToRadians(5.0));
   else if(cNumberNonGaiaPlayers < 9)
      rmPlacePlayersCircular(0.23, 0.28, rmDegreesToRadians(5.0));
   else
      rmPlacePlayersCircular(0.30, 0.35, rmDegreesToRadians(5.0));

    // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(4500);
   if(cNumberNonGaiaPlayers < 4)
      playerFraction=rmAreaTilesToFraction(4200);
   float randomIslandChance=rmRandFloat(0, 1);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);

      rmSetAreaMinBlobs(id, 3);
      rmSetAreaMaxBlobs(id, 7);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
  /*    rmSetAreaCoherence(id, 0.0); */

      rmSetAreaBaseHeight(id, 2.0);

      rmSetAreaSmoothDistance(id, 10);
      rmSetAreaHeightBlend(id, 2);

      // Add constraints.
      rmAddAreaConstraint(id, cornerOverlapConstraint);
      rmAddAreaConstraint(id, playerEdgeConstraint);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, "GrassDirt25");

      //island avoidance determination
      randomIslandChance=rmRandFloat(0, 1);
      if(cNumberNonGaiaPlayers < 3)
         rmAddAreaConstraint(id, playerConstraint); 
      /* if 2 players, always avoid each other, but don't have bonus islands avoid */
      else
      {
         if(randomIslandChance < 0.33)
         {
            rmAddAreaToClass(id, islandsX);
            rmAddAreaConstraint(id, islandsXvsY);
            rmAddAreaConstraint(id, islandsXYvsZ);
            rmEchoInfo("Class "+id+" islands X");
   /*            rmSetAreaTerrainType(id, "GrassDirt25"); */
         }
         else if(randomIslandChance < 0.66)        
         {
            rmAddAreaToClass(id, islandsY);
            rmAddAreaConstraint(id, islandsYvsX);
            rmAddAreaConstraint(id, islandsXYvsZ);
            rmEchoInfo("Class "+id+" islands Y");
   /*            rmSetAreaTerrainType(id, "SnowA"); */
         }
         else
         {
            rmAddAreaToClass(id, islandsZ);
            rmEchoInfo("Class "+id+" islands Z");
            rmAddAreaConstraint(id, islandsZvsX);
            rmAddAreaConstraint(id, islandsZvsY); 
   /*            rmSetAreaTerrainType(id, "SandA"); */
         }
      }
   }
   rmBuildAllAreas();

   // Build up some bonus islands.
   int bonusCount=cNumberNonGaiaPlayers + rmRandInt(1, 4);  // num players plus some extra
   for(i=0; <bonusCount)
   {
      int bonusIslandID=rmCreateArea("bonus island"+i);
      rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(1000), rmAreaTilesToFraction(1500));
      rmSetAreaTerrainType(bonusIslandID, "GrassA"); 
      rmSetAreaWarnFailure(bonusIslandID, false);
      rmAddAreaConstraint(bonusIslandID, playerEdgeConstraint); 
      rmAddAreaConstraint(bonusIslandID, bonusIslandConstraint); 
      rmAddAreaToClass(bonusIslandID, classBonusIsland);

      rmSetAreaCoherence(bonusIslandID, 0.25);

      rmSetAreaSmoothDistance(bonusIslandID, 12);
      rmSetAreaHeightBlend(bonusIslandID, 2);

      rmSetAreaBaseHeight(bonusIslandID, 2.0);

      //island avoidance determination
      randomIslandChance=rmRandFloat(0, 1);
      if(randomIslandChance < 0.33)
      {
         rmAddAreaToClass(bonusIslandID, islandsX);
         rmAddAreaConstraint(bonusIslandID, islandsXvsY);
         rmAddAreaConstraint(bonusIslandID, islandsXYvsZ);
         rmEchoInfo("Class "+bonusIslandID+" islands X");
/*            rmSetAreaTerrainType(bonusIslandID, "GrassDirt25"); */
      }
      else if(randomIslandChance < 0.66)        
      {
         rmAddAreaToClass(bonusIslandID, islandsY);
         rmAddAreaConstraint(bonusIslandID, islandsYvsX);
         rmAddAreaConstraint(bonusIslandID, islandsXYvsZ);
         rmEchoInfo("Class "+bonusIslandID+" islands Y");
/*            rmSetAreaTerrainType(bonusIslandID, "SnowA"); */
      }
      else
      {
         rmAddAreaToClass(bonusIslandID, islandsZ);
         rmEchoInfo("Class "+bonusIslandID+" islands Z");
         rmAddAreaConstraint(bonusIslandID, islandsZvsX);
         rmAddAreaConstraint(bonusIslandID, islandsZvsY); 
/*            rmSetAreaTerrainType(bonusIslandID, "SandA"); */
      }
      rmBuildArea(bonusIslandID);
   }

   // Place stuff.

   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements.

   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farSettlementID, 0, rmAreaID("player"+i), 2);

  // Text
   rmSetStatusText("",0.40);

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

    // Pigs
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   // player fish
   rmPlaceObjectDefPerPlayer(playerFishID, false);

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

  
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumPigsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
      
   // Far things.
   
   // Gold, 2 in player lands, 1 on bonus islands
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("player"+i), 2);

   for(i=1; <cNumberPlayers)
   rmPlaceObjectDefInRandomAreaOfClass(bonusGoldID, i, classBonusIsland);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 

   // Relics
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i));

   // Pigs
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farPigsID, 0, rmAreaID("player"+i));

   // Bonus huntable.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i));

   // Predators
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("player"+i));

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
  /* if(cNumberNonGaiaPlayers < 8) */
      rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
/*   else
      rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers); */

   int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
   int sharkVsSharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
   int sharkVsSharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
   int sharkVsSharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);
   int sharkID=rmCreateObjectDef("shark");
   if(rmRandFloat(0,1)<0.33)
      rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
   else if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
   else
   rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
   rmSetObjectDefMinDistance(sharkID, 0.0);
   rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
/*   rmAddObjectDefConstraint(sharkID, fishVsFishID); */
   rmAddObjectDefConstraint(sharkID, sharkLand);
   rmAddObjectDefConstraint(sharkID, playerEdgeConstraint);
   rmAddObjectDefConstraint(sharkID, sharkVsSharkID);
   rmAddObjectDefConstraint(sharkID, sharkVsSharkID2);
   rmAddObjectDefConstraint(sharkID, sharkVsSharkID3);
   rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);

  // Text
   rmSetStatusText("",0.60);

    // Player elevation.
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 5.0);
   for(i=1; <cNumberPlayers)
   {
      int failCount=0;
      int num=rmRandInt(5, 10);
      for(j=0; <num)
      {
         int elevID=rmCreateArea("elev"+i+", "+j, rmAreaID("player"+i));
         rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
         rmSetAreaWarnFailure(elevID, false);
         rmAddAreaConstraint(elevID, avoidBuildings);
         rmAddAreaConstraint(elevID, avoidImpassableLand);
         if(rmRandFloat(0.0, 1.0)<0.3)
            rmSetAreaTerrainType(elevID, "GrassDirt50");
         rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 3.5));

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
   }


   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 15.0);
   int forestTerrain=rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);

   // Player forests.   
   for(i=1; <cNumberPlayers)
   {
      failCount=0;
      int forestCount=rmRandInt(5, 8);
      for(j=0; <forestCount)
      {
         int forestID=rmCreateArea("player"+i+"forest"+j, rmAreaID("player"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "palm forest");
         rmAddAreaConstraint(forestID, forestSettleConstraint);
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint);
         rmAddAreaConstraint(forestID, forestTerrain);
         rmAddAreaToClass(forestID, classForest);
      
         rmSetAreaMinBlobs(forestID, 1);
         rmSetAreaMaxBlobs(forestID, 5);
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
   }

  // Text
   rmSetStatusText("",0.80);

   // Random island forests.
   int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 10.0);
   for(i=0; <bonusCount)
   {
      forestCount=rmRandInt(2, 3);
      for(j=0; <forestCount)
      {
         forestID=rmCreateArea("bonus"+i+"forest"+j, rmAreaID("bonus island"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "palm forest");
         rmAddAreaConstraint(forestID, forestSettleConstraint);
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint2);
         rmAddAreaConstraint(forestID, forestTerrain);
         rmAddAreaToClass(forestID, classForest);
         rmSetAreaWarnFailure(forestID, false);
      
         rmSetAreaMinBlobs(forestID, 1);
         rmSetAreaMaxBlobs(forestID, 5);
         rmSetAreaMinBlobDistance(forestID, 16.0);
         rmSetAreaMaxBlobDistance(forestID, 40.0);
         rmSetAreaCoherence(forestID, 0.0);

         // Hill trees?
         if(rmRandFloat(0.0, 1.0)<0.2)
            rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));

         rmBuildArea(forestID);
      }
   }

    // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
   int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 3, 4.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmAddObjectDefConstraint(grassID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   int rockID2=rmCreateObjectDef("rock group");
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, avoidRock);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers); 

  // Text
   rmSetStatusText("",1.0);

}  





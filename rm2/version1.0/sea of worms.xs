void main(void)
{



// Main entry point for random map script

  // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=9000;
   if(cMapSize == 1)
   {
      playerTiles = 11700;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmSetSeaType("North Atlantic Ocean");
   rmTerrainInitialize("SnowSand25");

   int hand=0;
   if(rmRandFloat(0,1)<0.5)
      hand = 1;
      rmEchoInfo("hand ="+hand);

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classPlayerCore=rmDefineClass("player core");
   rmDefineClass("center");
   int classpatch=rmDefineClass("patch");
   rmDefineClass("starting settlement");
   int classBonusIsland=rmDefineClass("bonus island");


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));
   
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, size*0.05);


   // Center constraint.
   int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 15.0);
   int wideCenterConstraint=rmCreateClassDistanceConstraint("elevation avoids center", rmClassID("center"), 20.0);  

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
       
   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);


   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
   int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land by lots", "land", false, 30.0);
   int avoidLand=rmCreateTerrainDistanceConstraint("avoid land", "land", true, 30.0);
   int patchConstraint=rmCreateClassDistanceConstraint("patch v patch", rmClassID("patch"), 10.0);


  
   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(5,8), 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 15.0);
   rmSetObjectDefMaxDistance(closeChickensID, 20.0);
   rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", 6, 4.0);
   rmSetObjectDefMinDistance(closeBerriesID, 15.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 20.0);
   rmAddObjectDefConstraint(closeBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeBerriesID, avoidFood);

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
   rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);

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
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 70.0);
   rmSetObjectDefMaxDistance(farGoldID, 160.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
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

   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "polar bear", 1, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
   
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(6,10), 4.0);
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
      rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(1,3), 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(2,8), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
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

   // Bonus Relic
   int bonusRelicID=rmCreateObjectDef("bonus relic");
   rmAddObjectDefItem(bonusRelicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(bonusRelicID, 0.0);
   rmSetObjectDefMaxDistance(bonusRelicID, 20.0);
   rmAddObjectDefConstraint(bonusRelicID, shortAvoidImpassableLand);

   // -------------Done defining objects

  // Text
   rmSetStatusText("",0.20);

   // Cheesy "circular" placement of players.
   if(hand==1)
      rmSetPlacementSection(0.55, 0.15);
   else
      rmSetPlacementSection(0.05, 0.65);
   
   rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));

   // Create a center water area -- the mediterranean part.
   int centerID=rmCreateArea("center");
   rmSetAreaSize(centerID, 0.15, 0.15);
   if(hand==1)
      rmSetAreaLocation(centerID, 0.6, 0.4);
   else
      rmSetAreaLocation(centerID, 0.4, 0.6);
   rmSetAreaWaterType(centerID, "north atlantic ocean");
   rmAddAreaToClass(centerID, rmClassID("center"));
   rmSetAreaBaseHeight(centerID, 0.0);
   rmSetAreaMinBlobs(centerID, 8);
   rmSetAreaMaxBlobs(centerID, 10);
   rmSetAreaMinBlobDistance(centerID, 10);
   rmSetAreaMaxBlobDistance(centerID, 20);
   rmSetAreaSmoothDistance(centerID, 50);
   rmSetAreaCoherence(centerID, 0.25);
   rmBuildArea(centerID); 

   int gulfID=rmCreateArea("gulf");
   rmSetAreaSize(gulfID, 0.25, 0.25);
   if(hand==1)
      rmSetAreaLocation(gulfID, 0.9, 0.25);
   else
      rmSetAreaLocation(gulfID, 0.1, 0.75);
   rmSetAreaWaterType(gulfID, "north atlantic ocean");
   rmAddAreaToClass(gulfID, rmClassID("center"));
   rmSetAreaBaseHeight(gulfID, 0.0);
   rmSetAreaMinBlobs(gulfID, 8);
   rmSetAreaMaxBlobs(gulfID, 10);
   rmSetAreaMinBlobDistance(gulfID, 10);
   rmSetAreaMaxBlobDistance(gulfID, 20);
   rmSetAreaSmoothDistance(gulfID, 50);
   rmSetAreaCoherence(gulfID, 0.25);
   rmBuildArea(gulfID); 
   
   // Make bonus islands
  int numIsland = 0;
  if(cNumberNonGaiaPlayers < 4)
  {
     if(rmRandFloat(0,1)<0.5)
         numIsland = rmRandInt(1,3);
  }
  else if(cNumberNonGaiaPlayers < 7)
     numIsland = rmRandInt(2,6);
  else
     numIsland = rmRandInt(3,7);
  for(i=1; <numIsland)
  {
      int bonusID=rmCreateArea("Island"+i);
      rmSetAreaSize(bonusID, rmAreaTilesToFraction(400), rmAreaTilesToFraction(800));
       rmSetAreaMinBlobs(bonusID, 4);
      rmSetAreaMaxBlobs(bonusID, 5);
      rmSetAreaMinBlobDistance(bonusID, 30.0);
      rmSetAreaMaxBlobDistance(bonusID, 50.0);
      rmSetAreaSmoothDistance(bonusID, 20);
      rmSetAreaCoherence(bonusID, 0.20);
      rmSetAreaBaseHeight(bonusID, 2.0); 
      rmSetAreaHeightBlend(bonusID, 2);
      rmAddAreaToClass(bonusID, classBonusIsland);
      rmAddAreaConstraint(bonusID, avoidLand);
      rmSetAreaTerrainType(bonusID, "SnowSand25");
      rmAddAreaTerrainLayer(bonusID, "snowB", 0, 3);
   }
   
   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(1000);
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
      rmSetAreaBaseHeight(id, 2.0); 
      rmSetAreaHeightBlend(id, 2);
      rmAddAreaConstraint(id, playerConstraint);
      rmAddAreaConstraint(id, centerConstraint);
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "SandA");
      rmAddAreaTerrainLayer(id, "snowSand75", 4, 6);
      rmAddAreaTerrainLayer(id, "snowSand50", 2, 4);
      rmAddAreaTerrainLayer(id, "snowSand25", 0, 2);   
   }

  // Text
   rmSetStatusText("",0.40);

   // Build the areas.
   rmBuildAllAreas();

 /*  // Player sub-area
   for(i=1; <cNumberPlayers)
   {
         int playerPatch=rmCreateArea("player "+i+" sub area",rmAreaID("player"+i));
         int rmCreateEdgeDistanceConstraint("stay in "+i, rmAreaID("player"+i), 10);    
         rmSetAreaSize(playerPatch, rmAreaTilesToFraction(10), rmAreaTilesToFraction(10));
         rmAddAreaConstraint(playerPatch, shortAvoidImpassableLand);
         rmBuildArea(playerPatch);
   } */


   int patch = 0;
   int failCount=0;
   for(i=1; <cNumberPlayers*2) 
   {
      patch=rmCreateArea("patch"+i);
      rmSetAreaSize(patch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaWarnFailure(patch, false); 
      rmSetAreaTerrainType(patch, "SnowA");
      rmSetAreaMinBlobs(patch, 1);
      rmSetAreaMaxBlobs(patch, 5);
      rmSetAreaMinBlobDistance(patch, 16.0);
      rmSetAreaMaxBlobDistance(patch, 40.0);
      rmAddAreaToClass(patch, classpatch);
      rmAddAreaConstraint(patch, patchConstraint); 
      rmAddAreaConstraint(patch, playerConstraint);
      rmAddAreaConstraint(patch, avoidImpassableLand); 
      rmSetAreaCoherence(patch, 0.3);
      rmSetAreaSmoothDistance(patch, 8);

      if(rmBuildArea(patch)==false)
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
   int numTries=6*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, playerConstraint);
      rmAddAreaConstraint(elevID, wideCenterConstraint);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SnowB");
      rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 7.0));
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
         if(failCount==10)
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
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, playerConstraint);
      rmAddAreaConstraint(elevID, wideCenterConstraint);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==10)
            break;
      }
      else
         failCount=0;
   } 

  // Text
   rmSetStatusText("",0.60);

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

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

   rmResetFairLocs();

   id = rmAddFairLoc("fortLand", true, true, 30, 35, 40, 16, true);
   rmAddFairLocConstraint(id, farAvoidImpassableLand);

   int fortressID=0;
   int migdolID=0;
   int hillFortID=0;
	int palaceID=0;

   if(rmPlaceFairLocs())
   {
      fortressID=rmCreateObjectDef("player fortress");
      rmAddObjectDefItem(fortressID, "Fortress", 1, 0.0);
      rmAddObjectDefItem(fortressID, "Gold Mine Small", 1, 8.0);
      
      migdolID=rmCreateObjectDef("player migdol");
      rmAddObjectDefItem(migdolID, "Migdol Stronghold", 1, 0.0);
      rmAddObjectDefItem(migdolID, "Gold Mine Small", 1, 8.0);
      
      hillFortID=rmCreateObjectDef("player hill fort");
      rmAddObjectDefItem(hillFortID, "Hill Fort", 1, 0.0);
      rmAddObjectDefItem(hillFortID, "Gold Mine Small", 1, 8.0);

		palaceID=rmCreateObjectDef("player palace");
      rmAddObjectDefItem(palaceID, "Palace", 1, 0.0);
      rmAddObjectDefItem(palaceID, "Gold Mine Small", 1, 8.0);


      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {
            if(rmGetPlayerCulture(i) == cCultureGreek)
               rmPlaceObjectDefAtLoc(fortressID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
            else if(rmGetPlayerCulture(i) == cCultureEgyptian)
               rmPlaceObjectDefAtLoc(migdolID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
            else if(rmGetPlayerCulture(i) == cCultureNorse)
               rmPlaceObjectDefAtLoc(hillFortID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				else if(rmGetPlayerCulture(i) == cCultureAtlantean)
               rmPlaceObjectDefAtLoc(palaceID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
         } 
      }
   }

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
 
   // Gold
/*   rmPlaceObjectDefPerPlayer(startingGoldID, false); */

   rmPlaceObjectDefPerPlayer(closeChickensID, false);

   rmPlaceObjectDefPerPlayer(closeBerriesID, false);


   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   fishID=rmCreateObjectDef("fish2");
   rmAddObjectDefItem(fishID, "fish - perch", 2, 6.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
   
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
   rmAddObjectDefConstraint(sharkID, edgeConstraint);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
   rmAddObjectDefConstraint(sharkID, sharkLand);
   rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   
   // Far things.
   
   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1,2));

   // Bonus Gold
   for(i=1; <numIsland*2)
      rmPlaceObjectDefInRandomAreaOfClass(bonusGoldID, 0, classBonusIsland);

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);

   //Bonus Relics
   if(rmRandFloat(0,1)<0.33)
      for(i=1; <rmRandInt(1,2))
         rmPlaceObjectDefInRandomAreaOfClass(bonusRelicID, 0, classBonusIsland);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 
   
   // Bonus huntable.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers/2);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);


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
      if(rmRandFloat(0.0, 1.0)<0.25)
         rmSetAreaForestType(forestID, "snow pine forest");
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
   rmSetStatusText("",0.80);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

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






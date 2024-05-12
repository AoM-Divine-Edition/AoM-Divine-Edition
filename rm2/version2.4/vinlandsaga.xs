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
   rmSetSeaType("norwegian sea");

   // Init map.
   rmTerrainInitialize("water");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("classHill");
   rmDefineClass("classPatch");
   int classBonusIsland=rmDefineClass("big continent");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");

   // -------------Define constraints
   
   // Create a edge of map constraint.
   int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(6), rmZTilesToFraction(6), 1.0-rmXTilesToFraction(6), 1.0-rmZTilesToFraction(6), 0.01);

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 12.0);
   int longPlayerConstraint=rmCreateClassDistanceConstraint("continent stays away from players", classPlayer, 50.0);

   // Bonus area constraint.
   int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid bonus island", classBonusIsland, 50.0);

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraint.
   int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Goats/pigs
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

   // Animals
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 2.0);
   int longAvoidImpassableLand=rmCreateTerrainDistanceConstraint("long avoid impassable land", "Land", false, 20.0);
   int hillConstraint=rmCreateClassDistanceConstraint("hill vs. hill", rmClassID("classHill"), 20.0);
   int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 5.0);
   int patchConstraint=rmCreateClassDistanceConstraint("patch vs. patch", rmClassID("classPatch"), 5.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 8.0);



   // -------------Define objects
   // Close Objects

   // Text
   rmSetStatusText("",0.20);

   int startingSettlementID=rmCreateObjectDef("Starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
/*   rmAddObjectDefItem(startingSettlementID, "pine", 10, 16.0); */
/*   rmAddObjectDefItem(startingSettlementID, "Gold mine small", 1, 16.0); */
/*   rmAddObjectDefItem(startingSettlementID, "berry bush", 4, 16.0); */
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 20.0);
   rmAddObjectDefConstraint(startingSettlementID, shortAvoidImpassableLand);

	



    int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine snow", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 0.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 25.0);
   rmAddObjectDefConstraint(stragglerTreeID, avoidBuildings);
   rmAddObjectDefConstraint(stragglerTreeID, shortAvoidImpassableLand);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 0.0);
   rmSetObjectDefMaxDistance(startingGoldID, 20.0);
   rmAddObjectDefConstraint(startingGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(startingGoldID, avoidBuildings);

   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", rmRandInt(4,6), 4.0);
   rmSetObjectDefMinDistance(closeBerriesID, 0.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 20.0);
   rmAddObjectDefConstraint(closeBerriesID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(closeBerriesID, avoidBuildings);
   rmAddObjectDefConstraint(closeBerriesID, shortAvoidGold);

   int transportNearShore=rmCreateTerrainMaxDistanceConstraint("transport near shore", "land", true, 4.0);
   int transportGreekID=rmCreateObjectDef("transport greek");
   rmAddObjectDefItem(transportGreekID, "transport ship greek", 1, 0.0);
   rmSetObjectDefMinDistance(transportGreekID, 0.0);
   rmSetObjectDefMaxDistance(transportGreekID, 60.0);
   rmAddObjectDefConstraint(transportGreekID, transportNearShore);
//   rmAddObjectDefConstraint(transportGreekID, playerEdgeConstraint);
 
   int transportNorseID=rmCreateObjectDef("transport Norse");
   rmAddObjectDefItem(transportNorseID, "transport ship Norse", 1, 0.0);
   rmSetObjectDefMinDistance(transportNorseID, 0.0);
   rmSetObjectDefMaxDistance(transportNorseID, 60.0);
   rmAddObjectDefConstraint(transportNorseID, transportNearShore);
//   rmAddObjectDefConstraint(transportNorseID, playerEdgeConstraint);
  
   int transportEgyptianID=rmCreateObjectDef("transport Egyptian");
   rmAddObjectDefItem(transportEgyptianID, "transport ship Egyptian", 1, 0.0);
   rmSetObjectDefMinDistance(transportEgyptianID, 0.0);
   rmSetObjectDefMaxDistance(transportEgyptianID, 60.0);
   rmAddObjectDefConstraint(transportEgyptianID, transportNearShore);
//   rmAddObjectDefConstraint(transportEgyptianID, playerEdgeConstraint);

	int transportAtlanteanID=rmCreateObjectDef("transport Atlantean");
   rmAddObjectDefItem(transportAtlanteanID, "transport ship Atlantean", 1, 0.0);
   rmSetObjectDefMinDistance(transportAtlanteanID, 0.0);
   rmSetObjectDefMaxDistance(transportAtlanteanID, 60.0);
   rmAddObjectDefConstraint(transportAtlanteanID, transportNearShore);
//   rmAddObjectDefConstraint(transportAtlanteanID, playerEdgeConstraint);
     
   // Far Island Objects

   // Settlement avoid Settlements
   int farSettlementID=rmCreateObjectDef("far settlement");
   rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
   rmAddObjectDefConstraint(farSettlementID, avoidImpassableLand);
   rmAddObjectDefConstraint(farSettlementID, farAvoidSettlement);
         
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);

   // pigs aboid pigs
   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, longAvoidImpassableLand);
   rmAddObjectDefConstraint(farPigsID, avoidFood);
   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "wolf", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, avoidFood);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
  
  // Skraelings? What's a Skraeling?
   int skraVsSkra=rmCreateTypeDistanceConstraint("avoid Skraeling", "Skraeling", 50.0);
   int SkraelingID=rmCreateObjectDef("Skraeling natives");
   rmAddObjectDefItem(SkraelingID, "Skraeling", rmRandInt(3,5), 3.0);
   rmAddObjectDefConstraint(SkraelingID, longAvoidImpassableLand);
   rmAddObjectDefConstraint(SkraelingID, skraVsSkra);
   rmAddObjectDefConstraint(SkraelingID, avoidFood);
   
   // This map will either use boar or deer as the extra huntable food.


   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "boar", 2, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "deer", 6, 2.0);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
    
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable 2");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID2, "elk", 5, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID2, "elk", 7, 2.0);
   rmAddObjectDefConstraint(bonusHuntableID2, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, avoidImpassableLand);

    // player fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int playerFishID=rmCreateObjectDef("owned fish");
   rmAddObjectDefItem(playerFishID, "fish - salmon", 3, 10.0);
   rmSetObjectDefMinDistance(playerFishID, 0.0);
   rmSetObjectDefMaxDistance(playerFishID, 100.0);
   rmAddObjectDefConstraint(playerFishID, fishVsFishID);
   rmAddObjectDefConstraint(playerFishID, fishLand);

   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 60.0));
   rmAddObjectDefConstraint(relicID, longAvoidImpassableLand);

   // -------------Done defining objects

  
   rmPlacePlayersLine(0.07, 0.15, 0.93, 0.15, 20, 10); 

    // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(1000);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);
      // Assign to the player.
      rmSetPlayerArea(i, id);
      // Set the size.
      rmSetAreaSize(id, playerFraction, playerFraction);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 3);
      rmSetAreaMinBlobDistance(id, 24.0);
      rmSetAreaMaxBlobDistance(id, 24.0);
      rmSetAreaCoherence(id, 0.5); 
      rmSetAreaBaseHeight(id, 2.0);
      rmSetAreaSmoothDistance(id, 10);
      rmSetAreaHeightBlend(id, 2);
      // Add constraints.
      rmAddAreaConstraint(id, playerConstraint); 
/*      rmAddAreaConstraint(id, cornerOverlapConstraint); */
      rmAddAreaConstraint(id, playerEdgeConstraint); 
      // Set the location.
      rmSetAreaLocPlayer(id, i);
      // Set type.
      rmSetAreaTerrainType(id, "SnowGrass25");
   }

   // Build the areas.
   rmBuildAllAreas();

   // Text
   rmSetStatusText("",0.40);


   // Build up big continent
      int bonusIslandID=rmCreateArea("big continent");
      rmSetAreaSize(bonusIslandID, 0.35, 0.4);
      rmSetAreaTerrainType(bonusIslandID, "GrassA");
      rmAddAreaTerrainLayer(bonusIslandID, "SnowGrass75", 13, 20);
      rmAddAreaTerrainLayer(bonusIslandID, "SnowGrass50", 6, 13);
      rmAddAreaTerrainLayer(bonusIslandID, "SnowGrass25", 0, 6);
      rmAddAreaConstraint(bonusIslandID, longPlayerConstraint);
      rmAddAreaToClass(bonusIslandID, classBonusIsland);
      rmSetAreaCoherence(bonusIslandID, 0.25);
   /*   rmSetAreaMinBlobs(id, 2);
      rmSetAreaMaxBlobs(id, 3);
      rmSetAreaMinBlobDistance(id, 10.0);
      rmSetAreaMaxBlobDistance(id, 30.0);
      rmAddAreaInfluenceSegment(id, 0.5, 1.0, 0.5, 0.5);
      rmAddAreaInfluenceSegment(id, 0.0, 1.0, 1.0, 1.0);
      rmAddAreaInfluencePoint(id, 0, 1);
      rmAddAreaInfluencePoint(id, 1, 0); */
      rmSetAreaSmoothDistance(bonusIslandID, 12); 
/*      rmSetAreaCoherence(id, 0.25); */
      rmSetAreaHeightBlend(bonusIslandID, 2);
      rmSetAreaBaseHeight(bonusIslandID, 2.0);
      rmSetAreaLocation(bonusIslandID, 0.5, 0.75);

      rmBuildArea(bonusIslandID);

       // make continent more pretty 
       // For this map, place patches before cliffs so they can avoid impassable land by a lot
      for (i=0; <5)
      {
         int patch=rmCreateArea("grassy"+i);
         rmSetAreaWarnFailure(patch, false);
         rmSetAreaSize(patch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(250));
         rmSetAreaTerrainType(patch, "SnowA");
         rmAddAreaTerrainLayer(patch, "SnowGrass25", 5, 7);
         rmAddAreaTerrainLayer(patch, "SnowGrass50", 2, 5);
         rmAddAreaTerrainLayer(patch, "SnowGrass75", 0, 2);
         rmAddAreaToClass(patch, rmClassID("classPatch"));
         rmSetAreaMinBlobs(patch, 1);
         rmSetAreaMaxBlobs(patch, 5);
         rmSetAreaMinBlobDistance(patch, 16.0);
         rmSetAreaMaxBlobDistance(patch, 40.0);
         rmSetAreaCoherence(patch, 0.0);
         rmAddAreaConstraint(patch, patchConstraint);
         rmAddAreaConstraint(patch, longAvoidImpassableLand);

         rmBuildArea(patch);
      } 

      int numTries=5*cNumberNonGaiaPlayers;
      int failCount=0;
      for (i=0; <numTries)
      {   
         int patch2=rmCreateArea("snowier patch"+i);
         rmSetAreaWarnFailure(patch2, false);
         rmSetAreaSize(patch2, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
         rmSetAreaTerrainType(patch2, "SnowGrass50");
         rmAddAreaTerrainLayer(patch2, "SnowGrass75", 0, 1);
         rmSetAreaMinBlobs(patch2, 1);
         rmSetAreaMaxBlobs(patch2, 5);
         rmSetAreaMinBlobDistance(patch2, 16.0);
         rmSetAreaMaxBlobDistance(patch2, 40.0);
         rmSetAreaCoherence(patch2, 0.0);
         rmAddAreaToClass(patch2, rmClassID("classPatch")); 
         rmAddAreaConstraint(patch2, patchConstraint); 
         rmAddAreaConstraint(patch2, longAvoidImpassableLand); 

         if(rmBuildArea(patch2)==false)
         {
            // Stop trying once we fail 3 times in a row.
            failCount++;
            if(failCount==3)
               break;
         }
         else
            failCount=0; 
      } 
      


  // Cliff.
   numTries=cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int cliffID=rmCreateArea("cliff"+i);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(250));
      rmSetAreaWarnFailure(cliffID, false);
      rmAddAreaToClass(i, rmClassID("classHill"));
      rmSetAreaCliffType(cliffID, "Norse");
      rmSetAreaTerrainType(cliffID, "SnowGrass50");
      int edgeRand=rmRandInt(0,100);
      if(edgeRand<1)
      {
         // Inaccesible
         rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
      }
      else
      {
         // AOK style
         rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
      }
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);

      rmSetAreaHeightBlend(cliffID, 1);
      rmAddAreaConstraint(cliffID, hillConstraint);
      rmAddAreaConstraint(cliffID, avoidImpassableLand);
      rmAddAreaTerrainLayer(cliffID, "SnowGrass75", 0, 1);
      rmSetAreaMinBlobs(cliffID, 3);
      rmSetAreaMaxBlobs(cliffID, 5);
      rmSetAreaMinBlobDistance(cliffID, 16.0);
      rmSetAreaMaxBlobDistance(cliffID, 40.0);
      rmSetAreaCoherence(cliffID, 0.0);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCoherence(cliffID, 0.25);

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

   // Slight Elevation
   numTries=20*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(80));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandInt(4.0, 5.0));
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, shortHillConstraint);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
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

  
   // Place stuff.

   // TC
   
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);



   // Settlements.
   rmPlaceObjectDefInArea(farSettlementID, 0, bonusIslandID, 2*cNumberNonGaiaPlayers);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

    // Berries  
   rmPlaceObjectDefPerPlayer(closeBerriesID, true);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(10,16));


   // Note: here's how to place different objects per player without fair locs
   //Transports
   for(i=0; <cNumberPlayers)
   {
      if(rmGetPlayerCulture(i) == cCultureGreek)
         rmPlaceObjectDefAtLoc(transportGreekID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else if(rmGetPlayerCulture(i) == cCultureNorse)
         rmPlaceObjectDefAtLoc(transportNorseID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else if(rmGetPlayerCulture(i) == cCultureEgyptian)
         rmPlaceObjectDefAtLoc(transportEgyptianID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
		else if(rmGetPlayerCulture(i) == cCultureAtlantean)
         rmPlaceObjectDefAtLoc(transportAtlanteanID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }

   // Far things.
   
   // Gold.
   rmPlaceObjectDefInArea(farGoldID, 0, bonusIslandID, 4*cNumberNonGaiaPlayers);
   
   // Text
   rmSetStatusText("",0.60);

   // Relics
   rmPlaceObjectDefInArea(relicID, 0, bonusIslandID, cNumberNonGaiaPlayers);
   
   // Pigs
   rmPlaceObjectDefInArea(farPigsID, 0, bonusIslandID, 3*cNumberNonGaiaPlayers);


   // Bonus huntable.
   rmPlaceObjectDefInArea(bonusHuntableID, 0, bonusIslandID, 2*cNumberNonGaiaPlayers);


   rmPlaceObjectDefInArea(bonusHuntableID2, 0, bonusIslandID, cNumberNonGaiaPlayers);

   // Predators
   rmPlaceObjectDefInArea(farPredatorID, 0, bonusIslandID, cNumberNonGaiaPlayers);

   // Skraeling
   rmPlaceObjectDefInArea(SkraelingID, 0, bonusIslandID, cNumberNonGaiaPlayers);

   // Random trees
   rmPlaceObjectDefInArea(randomTreeID, 0, bonusIslandID, cNumberNonGaiaPlayers*10);

   // Fish
   rmPlaceObjectDefPerPlayer(playerFishID, false);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand); 
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);


   // Forest.

   int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
   int classForest=rmDefineClass("forest");
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int count=0;
   failCount=0;
   numTries=6*cNumberNonGaiaPlayers;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i, bonusIslandID);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "pine forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, allObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
      rmAddAreaToClass(forestID, classForest);
      rmSetAreaMinBlobs(forestID, 3);
      rmSetAreaMaxBlobs(forestID, 7);
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
 
    // Rocks
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   //rmAddObjectDefConstraint(rockID, avoidRock);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

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
   rmAddObjectDefConstraint(sharkID, playerEdgeConstraint);
   rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers); 

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

  // Logs
   int logID=rmCreateObjectDef("log");
   rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
   rmSetObjectDefMinDistance(logID, 0.0);
   rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(logID, avoidAll);
   rmAddObjectDefConstraint(logID, avoidImpassableLand);
   rmAddObjectDefConstraint(logID, avoidBuildings);
   rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);
}  
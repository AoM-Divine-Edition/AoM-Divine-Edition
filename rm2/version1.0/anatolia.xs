// ANATOLIA

// Main entry point for random map script
void main(void)
{

   // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=8000;
   if(cMapSize == 1)
   {
      playerTiles = 10400;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);
   rmSetSeaType("Red sea");

   // Init map.
   rmTerrainInitialize("SandA");
   rmSetLightingSet("anatolia");
 
    // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classPlayerCore=rmDefineClass("player core");
   int classcliff=rmDefineClass("cliff");
   int classpatch=rmDefineClass("patch");
   int classocean=rmDefineClass("ocean");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");




   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
   int northOceanConstraint=rmCreateBoxConstraint("ocean N stay off shore", 0, 0.90, 1, 1);
   int southOceanConstraint=rmCreateBoxConstraint("ocean S stay off shore", 0, 0, 1, 0.10);
   int goldCenterConstraint=rmCreateBoxConstraint("gold stay in center", 0.35, 0.2, 0.65, 0.8);

   
   // corner constraint.
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 25.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 20.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
/*   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land short", "land", false, 5.0); */
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v gorge", rmClassID("cliff"), 30.0);
   int shortCliffConstraint=rmCreateClassDistanceConstraint("elev v gorge", rmClassID("cliff"), 10.0);
   int oceanConstraint=rmCreateClassDistanceConstraint("gorge vs ocean", rmClassID("ocean"), 25.0);
   int forestOceanConstraint=rmCreateClassDistanceConstraint("forest vs ocean", rmClassID("ocean"), 10.0);
   int smallOceanConstraint=rmCreateClassDistanceConstraint("terrain vs ocean", rmClassID("ocean"), 10.0);
   int patchConstraint=rmCreateClassDistanceConstraint("patch v patch", rmClassID("patch"), 10.0);

  
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

   // goats
   
   int GoatNum=rmRandInt(2, 5);
   int closegoatsID=rmCreateObjectDef("close goats");
   rmAddObjectDefItem(closegoatsID, "goat", GoatNum, 2.0);
   rmSetObjectDefMinDistance(closegoatsID, 25.0);
   rmSetObjectDefMaxDistance(closegoatsID, 30.0);
   rmAddObjectDefConstraint(closegoatsID, avoidFood);
   rmAddObjectDefConstraint(closegoatsID, avoidImpassableLand);
   
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

   int closeBoarID=rmCreateObjectDef("close Boar");
   float boarNumber=rmRandFloat(0, 1);
   if(boarNumber<0.3)
      rmAddObjectDefItem(closeBoarID, "boar", 3, 4.0);
   else if(boarNumber<0.9)
      rmAddObjectDefItem(closeBoarID, "boar", 4, 4.0);
   else
      rmAddObjectDefItem(closeBoarID, "boar", 1, 4.0);
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // Medium Objects

   // Text
   rmSetStatusText("",0.10);

   int mediumGoatsID=rmCreateObjectDef("medium goats");
   rmAddObjectDefItem(mediumGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 80.0);
   rmAddObjectDefConstraint(mediumGoatsID, avoidHerdable);
   rmAddObjectDefConstraint(mediumGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);

   // Far Objects
        
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 0.0);
   rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.5)); 
   rmAddObjectDefConstraint(farGoldID, goldCenterConstraint);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, edgeConstraint);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   // goats avoid TCs and other herds, since this map places a lot of goats
   int farGoatsID=rmCreateObjectDef("far goats");
   rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, avoidHerdable);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoatsID, edgeConstraint);
   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "wolf", 3, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "wolf", 4, 4.0);
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
   rmAddObjectDefConstraint(farBerriesID, edgeConstraint);
   
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "deer", 8, 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "deer", 10, 4.0);
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

   // Cheesy "circular" placement of players.


   if(cNumberNonGaiaPlayers < 3)
         rmPlacePlayersLine(0.12, 0.5, 0.88, 0.5);
   else if(cNumberTeams < 3)
      {
         rmSetPlacementTeam(0);
         rmPlacePlayersLine(0.12, 0.20, 0.12, 0.80, 20, 10); /* x z x2 z2 */
         rmSetPlacementTeam(1);
         rmPlacePlayersLine(0.88, 0.20, 0.88, 0.80, 20, 10);
      } 
   else    
      {
      rmPlacePlayersCircular(0.3, 0.35, rmDegreesToRadians(5.0));
      }


   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player core"+i);

      // Set the size.
      rmSetAreaSize(id, rmAreaTilesToFraction(110), rmAreaTilesToFraction(110));

      rmAddAreaToClass(id, classPlayerCore);

      rmSetAreaCoherence(id, 1.0);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Build it.
      rmBuildArea(id);
   }


   // Text
   rmSetStatusText("",0.20);

   int failCount=0;

  
   rmSetStatusText("",0.30);

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(1600);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      id=rmCreateArea("Player"+i);
      // Assign to the player.
      rmSetPlayerArea(i, id);
      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);
      rmAddAreaConstraint(id, edgeConstraint);
      rmSetAreaTerrainType(id, "SnowB");
      rmAddAreaTerrainLayer(id, "snowSand25", 6, 10);
      rmAddAreaTerrainLayer(id, "snowSand50", 2, 6);
      rmAddAreaTerrainLayer(id, "snowSand75", 0, 2);

      // Set the location.
      rmSetAreaLocPlayer(id, i);
      // Set type.
   }

      int northOceanID=rmCreateArea("north ocean");
/*      rmAddAreaConstraint(northOceanID, northOceanConstraint); */
      rmSetAreaSize(northOceanID, 0.1, 0.1);
      rmSetAreaWaterType(northOceanID, "Red Sea");
      rmSetAreaWarnFailure(northOceanID, false); 
      rmSetAreaLocation(northOceanID, 0.5, 0.99);
      rmAddAreaInfluenceSegment(northOceanID, 0, 1, 1, 1);
      rmSetAreaCoherence(northOceanID, 0.0);
      rmSetAreaSmoothDistance(northOceanID, 12);
      rmSetAreaHeightBlend(northOceanID, 1);
      rmAddAreaToClass(northOceanID, classocean);

      rmBuildArea(northOceanID);

       int southOceanID=rmCreateArea("south ocean");
/*      rmAddAreaConstraint(southOceanID, southOceanConstraint); */
      rmSetAreaSize(southOceanID, 0.1, 0.1);
      rmSetAreaWaterType(southOceanID, "Red Sea");
      rmSetAreaWarnFailure(southOceanID, false); 
      rmSetAreaLocation(southOceanID, 0.5, 0.01);
      rmAddAreaInfluenceSegment(southOceanID, 0, 0, 1, 0);
      rmSetAreaCoherence(southOceanID, 0.25);
      rmSetAreaSmoothDistance(southOceanID, 12);
      rmSetAreaHeightBlend(southOceanID, 1);
      rmAddAreaToClass(southOceanID, classocean);

      rmBuildArea(southOceanID);

   // Build the areas.
   rmBuildAllAreas();

   // Map beautification sub area.

   int goldArea=rmCreateArea("here is gold");
   rmSetAreaSize(goldArea, 1.0, 1.0);
   rmSetAreaWarnFailure(goldArea, false);
   rmAddAreaConstraint(goldArea, goldCenterConstraint);

   rmBuildArea(goldArea);

   int patch = 0;
   int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", patch, 4.0);
   for(i=1; <cNumberPlayers*5) 
   {
      patch=rmCreateArea("patch"+i);
      rmSetAreaSize(patch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaWarnFailure(patch, false); 
      rmSetAreaTerrainType(patch, "SnowB");
      rmAddAreaTerrainLayer(patch, "snowSand25", 2, 3);
      rmAddAreaTerrainLayer(patch, "snowSand50", 1, 2);
      rmAddAreaTerrainLayer(patch, "snowSand75", 0, 1);
      rmSetAreaMinBlobs(patch, 1);
      rmSetAreaMaxBlobs(patch, 5);
      rmSetAreaMinBlobDistance(patch, 16.0);
      rmSetAreaMaxBlobDistance(patch, 40.0);
      rmAddAreaToClass(patch, classpatch);
      rmAddAreaConstraint(patch, patchConstraint); 
      rmAddAreaConstraint(patch, playerConstraint);
      rmAddAreaConstraint(patch, smallOceanConstraint); 
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

      int snowRockID=rmCreateObjectDef("snowRock"+i);
      rmAddObjectDefItem(snowRockID, "rock granite sprite", rmRandFloat(0,3), 2.0);
      rmSetObjectDefMinDistance(snowRockID, 0.0);
      rmSetObjectDefMaxDistance(snowRockID, 0.0);
      rmAddObjectDefConstraint(snowRockID, stayInPatch);
      rmPlaceObjectDefInArea(snowRockID, 0, rmAreaID("patch"+i), 1);
   }

   for(i=1; <cNumberPlayers*20) 
   {
      int patch2=rmCreateArea("2nd patch"+i);
      rmSetAreaSize(patch2, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(patch2, false); 
      rmSetAreaTerrainType(patch2, "DirtA");
      rmSetAreaMinBlobs(patch2, 1);
      rmSetAreaMaxBlobs(patch2, 5);
      rmSetAreaMinBlobDistance(patch2, 16.0);
      rmSetAreaMaxBlobDistance(patch2, 40.0);
      rmAddAreaConstraint(patch2, playerConstraint);
      rmAddAreaToClass(patch2, classpatch);
      rmAddAreaConstraint(patch2, patchConstraint); 
       rmAddAreaConstraint(patch2, smallOceanConstraint); 
      rmSetAreaCoherence(patch2, 0.4);
      rmSetAreaSmoothDistance(patch2, 8);

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

   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

     id=rmAddFairLoc("Settlement", false, true,  50, 80, 40, 10);
   rmAddFairLocConstraint(id, avoidImpassableLand);

   id=rmAddFairLoc("Settlement", true, true, 90, 150, 60, 10);
   rmAddFairLocConstraint(id, avoidImpassableLand);

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
   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);


   // Make gorges

   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int gorgeID=rmCreateArea("gorge 1");
      rmSetAreaWarnFailure(gorgeID, false); 
   rmSetAreaSize(gorgeID, rmAreaTilesToFraction(2000), rmAreaTilesToFraction(2000));
   rmSetAreaCliffType(gorgeID, "Egyptian");
   rmAddAreaConstraint(gorgeID, cliffConstraint);
   rmAddAreaConstraint(gorgeID, avoidBuildings);
   rmAddAreaConstraint(gorgeID, oceanConstraint); 
   rmAddAreaToClass(gorgeID, classcliff);
   rmSetAreaMinBlobs(gorgeID, 4);
   rmSetAreaMaxBlobs(gorgeID, 6);
   rmSetAreaLocation(gorgeID, 0.4, 0.5);
   rmAddAreaInfluenceSegment(gorgeID, 0.4, 0.25, 0.4, 0.75); 
   rmSetAreaCliffEdge(gorgeID, 6, 0.08, 0.2, 1.0, 0);
   rmSetAreaCliffPainting(gorgeID, false, true, true, 1.5);
   rmSetAreaCliffHeight(gorgeID, 7, 1.0, 1.0);
   rmSetAreaMinBlobDistance(gorgeID, 20.0);
   rmSetAreaMaxBlobDistance(gorgeID, 20.0);
   rmSetAreaCoherence(gorgeID, 0.0);
   rmSetAreaSmoothDistance(gorgeID, 10);
   rmSetAreaCliffHeight(gorgeID, -5, 1.0, 1.0);
   rmSetAreaHeightBlend(gorgeID, 2);
   if(cNumberTeams < 3)
      {
      rmBuildArea(gorgeID);
      }

   int gorge2ID=rmCreateArea("gorge 2");
      rmSetAreaWarnFailure(gorge2ID, false); 
   rmSetAreaSize(gorge2ID, rmAreaTilesToFraction(2000), rmAreaTilesToFraction(2000));
   rmSetAreaCliffType(gorge2ID, "Egyptian");
   rmAddAreaConstraint(gorge2ID, cliffConstraint);
   rmAddAreaConstraint(gorge2ID, avoidBuildings);
   rmAddAreaConstraint(gorge2ID, oceanConstraint); 
   rmAddAreaToClass(gorge2ID, classcliff);
   rmSetAreaMinBlobs(gorge2ID, 4);
   rmSetAreaMaxBlobs(gorge2ID, 6);
   rmSetAreaLocation(gorge2ID, 0.6, 0.5);
   rmAddAreaInfluenceSegment(gorge2ID, 0.6, 0.25, 0.6, 0.75); 
   rmSetAreaCliffEdge(gorge2ID, 6, 0.08, 0.2, 1.0, 0);
   rmSetAreaCliffPainting(gorge2ID, false, true, true, 1.5);
   rmSetAreaCliffHeight(gorge2ID, 7, 1.0, 1.0);
   rmSetAreaMinBlobDistance(gorge2ID, 20.0);
   rmSetAreaMaxBlobDistance(gorge2ID, 20.0);
   rmSetAreaCoherence(gorge2ID, 0.0);
   rmSetAreaSmoothDistance(gorge2ID, 10);
   rmSetAreaCliffHeight(gorge2ID, -5, 1.0, 1.0);
   rmSetAreaHeightBlend(gorge2ID, 2);
   if(cNumberTeams < 3)
      {
      rmBuildArea(gorge2ID);
      }
   
   for(i=0; <8)
   {
      int cliffID=rmCreateArea("cliff"+i);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(700));
      rmSetAreaCliffType(cliffID, "Egyptian");
      rmAddAreaConstraint(cliffID, cliffConstraint); 
      rmAddAreaConstraint(cliffID, playerConstraint);
      rmAddAreaConstraint(cliffID, avoidBuildings);
      rmAddAreaConstraint(cliffID, oceanConstraint); 
      rmAddAreaToClass(cliffID, classcliff);
      rmSetAreaMinBlobs(cliffID, 2);
      rmSetAreaMaxBlobs(cliffID, 5);
      // AOK style
      rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
      rmSetAreaCliffPainting(cliffID, false, true, true, 1.5);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaMinBlobDistance(cliffID, 5.0);
      rmSetAreaMaxBlobDistance(cliffID, 10.0);
      rmSetAreaCoherence(cliffID, 0.0);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCliffHeight(cliffID, -5, 1.0, 1.0);
      rmSetAreaHeightBlend(cliffID, 2); 
      rmBuildArea(cliffID); 
   }

   // Elev.
   int numTries=40*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, cornerConstraint);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, shortCliffConstraint);
      rmAddAreaConstraint(elevID, oceanConstraint); 
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SnowSand50");
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
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
   numTries=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, shortCliffConstraint);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, oceanConstraint); 
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
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(5, 8));
   
   // Text
   rmSetStatusText("",0.50);


   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false, 2);

   // Goats
   rmPlaceObjectDefPerPlayer(closegoatsID, true);

   // Chickens or berries.
   for(i=1; <cNumberPlayers)
   {
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmPlaceObjectDefAtLoc(closeChickensID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else
         rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   // Medium things....

   // goats
   rmPlaceObjectDefPerPlayer(mediumGoatsID, false, rmRandInt(1, 2));
   
   // Far things.
   
   // Gold.
   rmPlaceObjectDefInArea(farGoldID, 0, goldArea, cNumberNonGaiaPlayers*rmRandInt(2, 3));

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);
   
   // Text
   rmSetStatusText("",0.60);

   // goats
   rmPlaceObjectDefPerPlayer(farGoatsID, false, rmRandInt(1, 2));

   // Bonus huntable.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers); 

   // Text
   rmSetStatusText("",0.70);

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=8*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(forestID, false);
      if(rmRandFloat(0.0, 1.0)<0.25)
         rmSetAreaForestType(forestID, "mixed pine forest");
      else
         rmSetAreaForestType(forestID, "pine forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, shortCliffConstraint);
      rmAddAreaConstraint(forestID, forestOceanConstraint);
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 3);
      rmSetAreaMaxBlobs(forestID, 3);
      rmSetAreaMinBlobDistance(forestID, 10.0);
      rmSetAreaMaxBlobDistance(forestID, 10.0);
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

   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 24.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);

   rmPlaceObjectDefInArea(fishID, 0, rmAreaID("north ocean"), 3*cNumberNonGaiaPlayers);
   rmPlaceObjectDefInArea(fishID, 0, rmAreaID("south ocean"), 3*cNumberNonGaiaPlayers);

   // Text
   rmSetStatusText("",0.80);

   // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);

   // Text
   rmSetStatusText("",0.90);

   int rockID2=rmCreateObjectDef("rock group");
   rmAddObjectDefItem(rockID2, "rock sandstone sprite", 3, 2.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, patchConstraint);
   rmAddObjectDefConstraint(rockID2, playerConstraint);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers); 

   int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
   int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
   int kelpID=rmCreateObjectDef("seaweed");
   rmAddObjectDefItem(kelpID, "seaweed", 4, 2.0);
   rmSetObjectDefMinDistance(kelpID, 0.0);
   rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(kelpID, avoidAll);
   rmAddObjectDefConstraint(kelpID, nearshore);
   rmAddObjectDefConstraint(kelpID, farshore);
   rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

   int kelp2ID=rmCreateObjectDef("seaweed 2");
   rmAddObjectDefItem(kelp2ID, "seaweed", 1, 0.0);
   rmSetObjectDefMinDistance(kelp2ID, 0.0);
   rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(kelp2ID, avoidAll);
   rmAddObjectDefConstraint(kelp2ID, nearshore);
   rmAddObjectDefConstraint(kelp2ID, farshore);
   rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers); 

   // Text
   rmSetStatusText("",1.00); 
}  





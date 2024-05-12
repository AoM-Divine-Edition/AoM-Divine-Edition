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
/*   rmSetSeaLevel(6.0); */
/*   rmSetSeaType("Egyptian Nile"); */

   // Init map.
   rmTerrainInitialize("SavannahA");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   rmDefineClass("classHill");


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 70.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
   int farAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 50.0);


   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
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
   rmSetObjectDefMinDistance(startingTowerID, 25.0);
   rmSetObjectDefMaxDistance(startingTowerID, 28.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, shortAvoidImpassableLand);
   
   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, shortAvoidImpassableLand);

   int closeGoatsID=rmCreateObjectDef("close goats");
   rmAddObjectDefItem(closeGoatsID, "goat", rmRandInt(1,3), 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 25.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);
   rmAddObjectDefConstraint(closeGoatsID, shortAvoidImpassableLand);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   if(rmRandFloat(0,1)<0.8)
      rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(6,12), 5.0);
   else
      rmAddObjectDefItem(closeChickensID, "berry bush", rmRandInt(4,8), 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   rmAddObjectDefConstraint(closeChickensID, shortAvoidImpassableLand);
   
   int closeHuntableID=rmCreateObjectDef("close huntable");
   float huntableNumber=rmRandFloat(0, 1);
   if(huntableNumber<0.1)
   {   
      rmAddObjectDefItem(closeHuntableID, "zebra", rmRandInt(3,5), 3.0);
      rmAddObjectDefItem(closeHuntableID, "gazelle", rmRandInt(2,6), 4.0);
   }
   else if(huntableNumber<0.3)
      rmAddObjectDefItem(closeHuntableID, "zebra", rmRandInt(2,3), 2.0);
   else if(huntableNumber<0.6)
      rmAddObjectDefItem(closeHuntableID, "rhinocerous", 1, 2.0);
   else if (huntableNumber<0.9)
      rmAddObjectDefItem(closeHuntableID, "rhinocerous", 2, 2.0);
   else if (huntableNumber<1.0)
      rmAddObjectDefItem(closeHuntableID, "rhinocerous", 4, 2.0);
   rmSetObjectDefMinDistance(closeHuntableID, 30.0);
   rmSetObjectDefMaxDistance(closeHuntableID, 50.0);
   rmAddObjectDefConstraint(closeHuntableID, shortAvoidImpassableLand);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   rmAddObjectDefConstraint(stragglerTreeID, shortAvoidImpassableLand);

   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
  
   int mediumGoatsID=rmCreateObjectDef("medium goats");
   rmAddObjectDefItem(mediumGoatsID, "goat", rmRandInt(0,3), 4.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
   rmAddObjectDefConstraint(mediumGoatsID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
  
   // For this map, pick how many deer/gazelle in a grouping.  Assign this
   // to both deer and gazelle since we place them interchangeably per player.
   int numHuntable=rmRandInt(3, 9);

   int mediumDeerID=rmCreateObjectDef("medium gazelle");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(mediumDeerID, "gazelle", numHuntable, 4.0);
   else
      rmAddObjectDefItem(mediumDeerID, "giraffe", numHuntable, 4.0);
   rmSetObjectDefMinDistance(mediumDeerID, 60.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
   
   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, farAvoidGold);
   rmAddObjectDefConstraint(farGoldID, edgeConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);

   // goats avoid TCs 
   int farGoatsID=rmCreateObjectDef("far goats");
   rmAddObjectDefItem(farGoatsID, "goat", rmRandInt(1,2), 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoatsID, shortAvoidImpassableLand);
   
   // pick lions or hyenas as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "hyena", 3, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farBerriesID, shortAvoidImpassableLand);
   
   // This map will either use zebra or giraffe as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.2)
   {   
      rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(2,4), 3.0);
      rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(0,2), 3.0);
   }
   else if(bonusChance<0.5)
      rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(4,6), 2.0);
   else if(bonusChance<0.9)
      rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,4), 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(4,7), 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);

   // hunted 2 avoids hunted and TCs
   int bonusHuntable2ID=rmCreateObjectDef("second bonus huntable");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.1)   
      rmAddObjectDefItem(bonusHuntable2ID, "elephant", 3, 2.0);
   else if(bonusChance<0.5)
      rmAddObjectDefItem(bonusHuntable2ID, "elephant", 2, 2.0);
   else if(bonusChance<0.9)
      rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 2, 2.0);
   else
      rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 4, 4.0);
   rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);

   // Monkeys avoid TCs  
   int farMonkeyID=rmCreateObjectDef("far monkeys");
   rmAddObjectDefItem(farMonkeyID, "baboon", rmRandInt(4,12), 4.0);
   rmSetObjectDefMinDistance(farMonkeyID, 0.0);
   rmSetObjectDefMaxDistance(farMonkeyID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farMonkeyID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farMonkeyID, shortAvoidImpassableLand);

   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
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
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);

   // -------------Done defining objects

  // Text
   rmSetStatusText("",0.20);

   if(cNumberNonGaiaPlayers < 10)
   {
      rmSetTeamSpacingModifier(0.75);
      rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(4.0));
   }
   else
   {
      rmSetTeamSpacingModifier(0.85);
      rmPlacePlayersCircular(0.35, 0.43, rmDegreesToRadians(4.0));
   }

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
      rmSetAreaTerrainType(id, "SavannahA");
   }

   // Build the areas.
   rmBuildAllAreas();

   for(i=1; <cNumberPlayers*100)
   {
      // Beautification sub area.
      int id2=rmCreateArea("dirt patch"+i);
      rmSetAreaSize(id2, rmAreaTilesToFraction(20), rmAreaTilesToFraction(40));
   /*   rmSetAreaLocPlayer(id2, i); */
      rmSetAreaTerrainType(id2, "SavannahB");
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);

      rmBuildArea(id2);
   }

   for(i=1; <cNumberPlayers*30)
   {
      // Beautification sub area.
      int id3=rmCreateArea("Grass patch"+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(10), rmAreaTilesToFraction(50));
      rmSetAreaTerrainType(id3, "SandA");
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.0);

      rmBuildArea(id3);
   }


   // ****Elevation rules = Settlements and Towers, then elevation avoiding buildings, then other resources****
   // ****New elevation rules = player lands, elev avoid player lands, wrinkles don't (but avoid hills). Then objects.****

   int pondClass=rmDefineClass("pond");
   int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 10.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int numPond=rmRandInt(2,4);
   for(i=0; <numPond)
   {
      int smallPondID=rmCreateArea("small pond"+i);
      rmSetAreaSize(smallPondID, rmAreaTilesToFraction(600), rmAreaTilesToFraction(600));
      rmSetAreaWaterType(smallPondID, "savannah water hole");
/*      rmSetAreaBaseHeight(smallPondID, 0.0); */
      rmSetAreaMinBlobs(smallPondID, 1);
      rmSetAreaMaxBlobs(smallPondID, 1);
   /*      rmSetAreaSmoothDistance(smallPondID, 50); */
      rmAddAreaToClass(smallPondID, pondClass);
      rmAddAreaConstraint(smallPondID, pondConstraint);
      rmAddAreaConstraint(smallPondID, edgeConstraint);
      rmAddAreaConstraint(smallPondID, playerConstraint);
      rmSetAreaWarnFailure(smallPondID, false);
      rmBuildArea(smallPondID);
   }

      // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);


   // Elev.
   int numTries=5*cNumberNonGaiaPlayers;
   int failCount=0;
/*   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmAddAreaToClass(elevID, rmClassID("classHill"));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, playerConstraint);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SavannahC");
      rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 9.0));
      rmSetAreaHeightBlend(elevID, 2);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmAddAreaConstraint(elevID, avoidBuildings);
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
   } */

   // Slight Elevation
   numTries=40*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(20), rmAreaTilesToFraction(80));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaTerrainType(elevID, "SavannahC");
      rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmAddAreaConstraint(elevID, avoidBuildings);
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
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10); /* forward inside */

   if(rmRandFloat(0,1)<0.75)
      id=rmAddFairLoc("Settlement", true, false, 70, 120, 60, 10);
   else
      id=rmAddFairLoc("Settlement", false, true,  60, 100, 40, 10);

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

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(1, 7));

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, true); 

   // Goats
   rmPlaceObjectDefPerPlayer(closeGoatsID, true);

   // Chickens or berries.
   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   // Close hunted
   rmPlaceObjectDefPerPlayer(closeHuntableID, false);

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));

   // Deer
   rmPlaceObjectDefPerPlayer(mediumDeerID, false);

   // Goats
   rmPlaceObjectDefPerPlayer(mediumGoatsID, false, 2);

   // Far things.

   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2, 4)); 

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false);

   // Goats.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(farGoatsID, 0, 0.5, 0.5);

   // Berries.
   if(rmRandFloat(0,1)<0.6)
      rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Bonus huntable stuff.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Bonus huntable stuff.
   rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   // Monkeys
   if(rmRandFloat(0,1)<0.5)
      rmPlaceObjectDefPerPlayer(farMonkeyID, false, 1); 

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

   int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);

  // Text
   rmSetStatusText("",0.60);

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   failCount=0;
   //int numTries=30*cNumberNonGaiaPlayers;
   //int maxCount=20*cNumberNonGaiaPlayers;
   numTries=15*cNumberNonGaiaPlayers;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      //rmSetAreaLocation(forestID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "savannah forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, allObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
   // rmAddAreaConstraint(forestID, avoidPond);
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


   // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid bush", "bush", 20.0);
   int bushID=rmCreateObjectDef("bush");
   rmAddObjectDefItem(bushID, "bush", 3, 4.0);
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bushID, avoidGrass);
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",0.80);

   for(i=0; <numPond)
   {
      int lilyID=rmCreateObjectDef("lily"+i);
      rmAddObjectDefItem(lilyID, "water lilly", rmRandInt(3,6), 6.0);
      rmSetObjectDefMinDistance(lilyID, 0.0);
      rmSetObjectDefMaxDistance(lilyID, rmXFractionToMeters(0.5));
      rmPlaceObjectDefInArea(lilyID, 0, rmAreaID("small pond"+i), rmRandInt(2,4));   
   }

   for(i=0; <numPond)
   {
      int decorationID=rmCreateObjectDef("decoration"+i);
      rmAddObjectDefItem(decorationID, "water decoration", rmRandInt(1,3), 6.0);
      rmSetObjectDefMinDistance(decorationID, 0.0);
      rmSetObjectDefMaxDistance(decorationID, rmXFractionToMeters(0.5));
      rmPlaceObjectDefInArea(decorationID, 0, rmAreaID("small pond"+i), rmRandInt(2,4));   
   }

   int deerID=rmCreateObjectDef("lonely deer");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(deerID, "zebra", rmRandInt(1,2), 1.0);
   else
      rmAddObjectDefItem(deerID, "giraffe", 1, 0.0);
   rmSetObjectDefMinDistance(deerID, 0.0);
   rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(deerID, avoidAll);
   rmAddObjectDefConstraint(deerID, avoidBuildings);
   rmAddObjectDefConstraint(deerID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

    int deer2ID=rmCreateObjectDef("lonely deer2");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(deer2ID, "rhinocerous", 1, 1.0);
   else
      rmAddObjectDefItem(deer2ID, "gazelle", 1, 0.0);
   rmSetObjectDefMinDistance(deer2ID, 0.0);
   rmSetObjectDefMaxDistance(deer2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(deer2ID, avoidAll);
   rmAddObjectDefConstraint(deer2ID, avoidBuildings);
   rmAddObjectDefConstraint(deer2ID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(deer2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   int rockID=rmCreateObjectDef("rock small");
   rmAddObjectDefItem(rockID, "rock sandstone small", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int rockID2=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID2, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);

}  

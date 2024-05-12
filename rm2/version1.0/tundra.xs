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
     rmSetSeaLevel(0.5); 
/*   rmSetSeaType("Egyptian Nile"); */

   // Init map.
   rmTerrainInitialize("TundraRockA");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   rmDefineClass("classHill");
	rmDefineClass("rock pile");


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 15.0);
   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 10.0);
	int veryShortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by very short distance", "AbstractSettlement", 15.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 70.0);
	int rockPileConstraint=rmCreateClassDistanceConstraint("avoid rockpiles", rmClassID("rock pile"), 30.0);
       
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
	int farAvoidFood=rmCreateTypeDistanceConstraint("avoid other food sources far", "huntable", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
   int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 10.0);

   int avoidAurochs=rmCreateTypeDistanceConstraint("avoid Aurochs", "Aurochs", 20.0);
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
   rmAddObjectDefItem(closeGoatsID, "Caribou", 6, 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 25.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);
   rmAddObjectDefConstraint(closeGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(closeGoatsID, shortAvoidGold);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   if(rmRandFloat(0,1)<0.8)
      rmAddObjectDefItem(closeChickensID, "goat", rmRandInt(6,8), 5.0);
   else
      rmAddObjectDefItem(closeChickensID, "berry bush", rmRandInt(6,8), 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   rmAddObjectDefConstraint(closeChickensID, shortAvoidImpassableLand);
   
   int closeHuntableID=rmCreateObjectDef("close huntable");
   float huntableNumber=rmRandFloat(0, 1);
   if(huntableNumber<0.1)
   {   
      rmAddObjectDefItem(closeHuntableID, "Elk", rmRandInt(5,6), 3.0);
      rmAddObjectDefItem(closeHuntableID, "Caribou", rmRandInt(5,6), 8.0);
   }
   else if(huntableNumber<0.3)
      rmAddObjectDefItem(closeHuntableID, "Elk", rmRandInt(5,6), 2.0);
   else if(huntableNumber<0.6)
      rmAddObjectDefItem(closeHuntableID, "Aurochs", 2, 2.0);
   else if (huntableNumber<0.9)
      rmAddObjectDefItem(closeHuntableID, "Aurochs", 3, 2.0);
   else if (huntableNumber<1.0)
      rmAddObjectDefItem(closeHuntableID, "Aurochs", 4, 2.0);
   rmSetObjectDefMinDistance(closeHuntableID, 30.0);
   rmSetObjectDefMaxDistance(closeHuntableID, 50.0);
   rmAddObjectDefConstraint(closeHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(closeHuntableID, avoidAurochs);
	rmAddObjectDefConstraint(closeHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(closeHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(closeHuntableID, farAvoidFood);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "Tundra Tree", 1, 0.0);
//	rmAddObjectDefItem(stragglerTreeID, "Pine Dead", 1, 0.0);
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
   rmAddObjectDefItem(mediumGoatsID, "Caribou", rmRandInt(4,5), 4.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
   rmAddObjectDefConstraint(mediumGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
  
   // For this map, pick how many deer/gazelle in a grouping.  Assign this
   // to both deer and gazelle since we place them interchangeably per player.
   int numHuntable=rmRandInt(4, 9);

   int mediumDeerID=rmCreateObjectDef("medium gazelle");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(mediumDeerID, "Elk", numHuntable, 4.0);
   else
      rmAddObjectDefItem(mediumDeerID, "Elk", numHuntable, 4.0);
   rmSetObjectDefMinDistance(mediumDeerID, 60.0);
   rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
   rmAddObjectDefConstraint(mediumDeerID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumDeerID, farAvoidFood);
   
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
   rmAddObjectDefItem(farGoatsID, "Aurochs", rmRandInt(2,3), 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoatsID, avoidAurochs);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoatsID, edgeConstraint);
   
   // pick lions or hyenas as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "Polar Bear", 1, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "Wolf Arctic 2", 2, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
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
      rmAddObjectDefItem(bonusHuntableID, "Caribou", rmRandInt(4,5), 3.0);
      rmAddObjectDefItem(bonusHuntableID, "Aurochs", rmRandInt(0,2), 3.0);
   }
   else if(bonusChance<0.5)
      rmAddObjectDefItem(bonusHuntableID, "Elk", rmRandInt(4,6), 2.0);
   else if(bonusChance<0.9)
      rmAddObjectDefItem(bonusHuntableID, "Aurochs", rmRandInt(2,3), 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "Caribou", rmRandInt(4,7), 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, avoidAurochs);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, farAvoidFood);


   // hunted 2 avoids hunted and TCs
   int bonusHuntable2ID=rmCreateObjectDef("second bonus huntable");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.1)   
      rmAddObjectDefItem(bonusHuntable2ID, "Aurochs", 3, 2.0);
   else if(bonusChance<0.5)
      rmAddObjectDefItem(bonusHuntable2ID, "Aurochs", 2, 2.0);
   else if(bonusChance<0.9)
      rmAddObjectDefItem(bonusHuntable2ID, "Aurochs", 2, 2.0);
   else
      rmAddObjectDefItem(bonusHuntable2ID, "Aurochs", 3, 4.0);
   rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidAurochs);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntable2ID, edgeConstraint);

   int randomTreeID=rmCreateObjectDef("random tree");
//   rmAddObjectDefItem(randomTreeID, "Pine Dead", 1, 0.0);
	rmAddObjectDefItem(randomTreeID, "Tundra Tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);

   // Monkeys avoid TCs  
   int farMonkeyID=rmCreateObjectDef("far monkeys");
   rmAddObjectDefItem(farMonkeyID, "Wolf Arctic 2", rmRandInt(1,2), 4.0);
   rmSetObjectDefMinDistance(farMonkeyID, 0.0);
   rmSetObjectDefMaxDistance(farMonkeyID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farMonkeyID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farMonkeyID, shortAvoidSettlement);
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
      rmSetAreaTerrainType(id, "TundraRockA");
   }

   // Build the areas.
   rmBuildAllAreas();


	  // Elev.
   int numTries=5*cNumberNonGaiaPlayers;
   int failCount=0;

   // Slight Elevation
   numTries=40*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaTerrainType(elevID, "TundraGrassA");
      rmSetAreaBaseHeight(elevID, rmRandFloat(8.0, 10.0));
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmSetAreaHeightBlend(elevID, 4);
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


     // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

	// Settlements.
   id=rmAddFairLoc("Settlement", false, true,  50, 80, 60, 10); /* forward inside */

//   if(rmRandFloat(0,1)<0.75)
      id=rmAddFairLoc("Settlement", true, false, 60, 100, 60, 10);
//   else
//      id=rmAddFairLoc("Settlement", false, true,  60, 100, 40, 10);

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
		rmAddObjectDefConstraint(id, shortAvoidImpassableLand);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
            rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
      }
   }


// PONDS **************************************************************************************

// Lower half of map
   int pondClass=rmDefineClass("pond");
   int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 20.0);
   
   int numPond=30*cNumberNonGaiaPlayers;
	int placeCount=0;
//		rmRandInt(4,6);
   for(i=0; <numPond)
   {
      int smallPondID=rmCreateArea("small pond"+i);
      rmSetAreaSize(smallPondID, rmAreaTilesToFraction(400), rmAreaTilesToFraction(400));
		rmSetAreaLocation(smallPondID, rmRandFloat(0.1, 0.9), rmRandFloat(0.1, 0.9));
      rmSetAreaWaterType(smallPondID, "Tundra Pool");
/*      rmSetAreaBaseHeight(smallPondID, 0.0); */
      rmSetAreaMinBlobs(smallPondID, 1);
      rmSetAreaMaxBlobs(smallPondID, 1);
   /*      rmSetAreaSmoothDistance(smallPondID, 50); */
      rmAddAreaToClass(smallPondID, pondClass);
      rmAddAreaConstraint(smallPondID, pondConstraint);
//      rmAddAreaConstraint(smallPondID, edgeConstraint);
      rmAddAreaConstraint(smallPondID, playerConstraint);
		rmAddAreaConstraint(smallPondID, shortAvoidSettlement);
      rmSetAreaWarnFailure(smallPondID, false);
      rmBuildArea(smallPondID);
/*
		 if(rmBuildArea(smallPondID)==true)
		 {
			 placeCount++;
			 if(placeCount==10)
            break;
		 }
*/
   }

// *******************************************************************************************

   for(i=1; <cNumberPlayers*100)
   {
      // Beautification sub area.
      int id2=rmCreateArea("dirt patch"+i);
      rmSetAreaSize(id2, rmAreaTilesToFraction(20), rmAreaTilesToFraction(40));
   /*   rmSetAreaLocPlayer(id2, i); */
      rmSetAreaTerrainType(id2, "TundraGrassB");
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
      rmSetAreaSize(id3, rmAreaTilesToFraction(30), rmAreaTilesToFraction(70));
      rmSetAreaTerrainType(id3, "TundraGrassA");
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



  // Text
   rmSetStatusText("",0.40);

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(1, 7));

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, true); 

   // Goats
   rmPlaceObjectDefPerPlayer(closeGoatsID, false);

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
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);

   // Monkeys
   if(rmRandFloat(0,1)<0.5)
      rmPlaceObjectDefPerPlayer(farMonkeyID, false, 3); 

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
      rmSetAreaForestType(forestID, "tundra forest");
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


   // Rock Piles placment
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid bush", "bush", 20.0);
	int avoidRocks=rmCreateTypeDistanceConstraint("avoid rocks", "Rock Sandstone Big", 20.0);
   int bushID=rmCreateObjectDef("bush");
   rmAddObjectDefItem(bushID, "Rock Sandstone Big", 3, 4.0);
	rmAddObjectDefItem(bushID, "Rock Granite Big", 3, 4.0);
	rmAddObjectDefToClass(bushID, rmClassID("rock pile"));
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bushID, avoidGrass);
	rmAddObjectDefConstraint(bushID, rockPileConstraint);
	rmAddObjectDefConstraint(bushID, veryShortAvoidSettlement);
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",0.80);
/*
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
*/

   int deerID=rmCreateObjectDef("lonely deer");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(deerID, "Elk", rmRandInt(3,4), 1.0);
   else
      rmAddObjectDefItem(deerID, "Caribou", 3, 0.0);
   rmSetObjectDefMinDistance(deerID, 0.0);
   rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(deerID, avoidAll);
   rmAddObjectDefConstraint(deerID, avoidBuildings);
   rmAddObjectDefConstraint(deerID, avoidImpassableLand);
	rmAddObjectDefConstraint(deerID, farAvoidFood);
	rmAddObjectDefConstraint(deerID, edgeConstraint);
   rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

    int deer2ID=rmCreateObjectDef("lonely deer2");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(deer2ID, "Aurochs", 1, 1.0);
   else
      rmAddObjectDefItem(deer2ID, "Elk", 1, 0.0);
   rmSetObjectDefMinDistance(deer2ID, 0.0);
   rmSetObjectDefMaxDistance(deer2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(deer2ID, avoidAll);
   rmAddObjectDefConstraint(deer2ID, avoidBuildings);
   rmAddObjectDefConstraint(deer2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(deer2ID, edgeConstraint);
	rmAddObjectDefConstraint(deer2ID, avoidAurochs);
	rmAddObjectDefConstraint(deer2ID, farAvoidFood);
   rmPlaceObjectDefAtLoc(deer2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   int rockID=rmCreateObjectDef("rock small");
   rmAddObjectDefItem(rockID, "rock sandstone small", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int rockID2=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

/*	
	int blowingSnowID=rmCreateObjectDef("blowing snow");
	rmAddObjectDefItem(blowingSnowID, "Snow Drift", 1, 0.0);
	rmSetObjectDefMinDistance(blowingSnowID, 0.0);
   rmSetObjectDefMaxDistance(blowingSnowID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(blowingSnowID, avoidAll);
	rmPlaceObjectDefAtLoc(blowingSnowID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
*/

//	*********************SNOW***************************

	rmCreateTrigger("Snow_A");
//	rmCreateTrigger("Snow_B");
//	rmCreateTrigger("Snow_C");
//	rmCreateTrigger("Snow_D");
//	rmCreateTrigger("Snow_E");
	rmCreateTrigger("Snow_backup");


	rmSwitchToTrigger(rmTriggerID("Snow_A"));
	rmSetTriggerPriority(2);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 2);

	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 0.1);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_backup"));

//	rmAddTriggerEffect("Set Lighting");
//	rmSetTriggerEffectParam("SetName", "Fimbulwinter");
//	rmSetTriggerEffectParamInt("FadeTime", 20);


	rmSwitchToTrigger(rmTriggerID("Snow_backup"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 60);

	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_A"));









/*

	rmSwitchToTrigger(rmTriggerID("Snow_B"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 10);

	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 0.3);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_C"));

	

	rmSwitchToTrigger(rmTriggerID("Snow_C"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 10);

	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 1.0);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_D"));

	rmAddTriggerEffect("Sound Filename");
	rmSetTriggerEffectParam("Sound", "\cinematics\25_in\wind.mp3");


	
	
	rmSwitchToTrigger(rmTriggerID("Snow_D"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 40);

	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 0.1);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_E"));

	rmAddTriggerEffect("Set Lighting");
	rmSetTriggerEffectParam("SetName", "Default");
	rmSetTriggerEffectParamInt("FadeTime", 10);

	
	
	rmSwitchToTrigger(rmTriggerID("Snow_E"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 10);

	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 0.0);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_A"));

	

*/




  // Text
   rmSetStatusText("",1.0);

}  

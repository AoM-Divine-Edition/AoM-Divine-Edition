// VALLEY OF KINGS

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
   // Choose left or right
  
   int sizel=0;
   int sizew=0;
   float handedness=rmRandFloat(0, 1);
   if(handedness<0.5)
   {
      sizel=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizew=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   else
   {
      sizew=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizel=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
   rmSetMapSize(sizel, sizew);

   // Set up default water.
   rmSetSeaLevel(0.0);
   rmSetSeaType("Egyptian Nile");

   // Init map.
   rmTerrainInitialize("CliffEgyptianA", 9.0);

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("starting settlement");

 // -------------Define constraints
   
   // Create a edge of map constraint.
/*   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8)); */
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(5), rmZTilesToFraction(5), rmXTilesToFraction((sizel*0.5)-5), rmZTilesToFraction((sizew*0.5)-5));


   // Player area constraint.
   int playerConstraint=0;
   if(cNumberNonGaiaPlayers < 10)
      playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20.0);
   else
      playerConstraint=rmCreateClassDistanceConstraint("far stay away from players", classPlayer, 30.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 30.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
   int migdolStartingSettleConstraint=rmCreateClassDistanceConstraint("migdol keep way away from player", rmClassID("starting settlement"), 70.0);
   int shortStartingSettleConstraint=rmCreateClassDistanceConstraint("starting resources avoid player TCs", rmClassID("starting settlement"), 20.0);
        
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 28.0); 
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 70.0);
   int mediumAvoidGold=rmCreateTypeDistanceConstraint("medium avoid gold", "gold", 40.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 16.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
   int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
   int avoidShore=rmCreateTerrainDistanceConstraint("stay in middle of ocean", "land", true, 5.0);
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidTree=rmCreateTypeDistanceConstraint("stay out of the woods", "tree", 6.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int pondAvoidBuildings=rmCreateTypeDistanceConstraint("ponds avoid buildings", "Building", 30.0);

   // Stay near shore
   int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 5.0);

  
   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("Starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 12.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, shortAvoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(startingGoldID, shortStartingSettleConstraint);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", 12, 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 8.0);
   rmSetObjectDefMaxDistance(closeChickensID, 20.0);
   rmAddObjectDefConstraint(closeChickensID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, shortStartingSettleConstraint);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   rmAddObjectDefConstraint(closeChickensID, shortAvoidGold);

   int closeHippoID=rmCreateObjectDef("close Hippo");
   float hippoNumber=rmRandFloat(0, 1);
   if(hippoNumber<0.3)
      rmAddObjectDefItem(closeHippoID, "hippo", 2, 1.0);
   else if(hippoNumber<0.6)
      rmAddObjectDefItem(closeHippoID, "hippo", 3, 2.0);
   else 
      rmAddObjectDefItem(closeHippoID, "rhinocerous", 2, 1.0);
   rmSetObjectDefMinDistance(closeHippoID, 12.0);
   rmSetObjectDefMaxDistance(closeHippoID, 25.0);
   rmAddObjectDefConstraint(closeHippoID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeHippoID, shortStartingSettleConstraint);
   rmAddObjectDefConstraint(closeHippoID, avoidFood);
   rmAddObjectDefConstraint(closeHippoID, shortAvoidGold);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // medium objects

   // Text
   rmSetStatusText("",0.10);

   int mediumGoatsID=rmCreateObjectDef("medium goats");
   rmAddObjectDefItem(mediumGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
   rmAddObjectDefConstraint(mediumGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);

   // For this map, pick how many zebra/gazelle in a grouping.  Assign this
   // to both zebra and gazelle since we place them interchangeably per player.

    int mediumZebraID=rmCreateObjectDef("medium zebra");
   rmAddObjectDefItem(mediumZebraID, "zebra", rmRandInt(6,10), 4.0);
   rmSetObjectDefMinDistance(mediumZebraID, 40.0);
   rmSetObjectDefMaxDistance(mediumZebraID, 80.0);
   rmAddObjectDefConstraint(mediumZebraID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumZebraID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumZebraID, avoidBuildings);


   // far objects


   // gold avoids gold, Settlements and TCs
   int farBanditID=rmCreateObjectDef("migdol and gold");
   rmAddObjectDefItem(farBanditID, "Bandit Migdol", 1, 0.0);
   rmAddObjectDefItem(farBanditID, "Gold mine", 3, 10.0);
   rmAddObjectDefItem(farBanditID, "statue pharaoh", 2, 12.0);
   rmSetObjectDefMinDistance(farBanditID, 0.0);
   rmSetObjectDefMaxDistance(farBanditID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBanditID, avoidGold);
   rmAddObjectDefConstraint(farBanditID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farBanditID, migdolStartingSettleConstraint);
   rmAddObjectDefConstraint(farBanditID, farAvoidImpassableLand);

   int farGoldID=rmCreateObjectDef("unguarded gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 0.0);
   rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farGoldID, mediumAvoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoldID, farAvoidImpassableLand);

   int farGoatsID=rmCreateObjectDef("far goats");
   rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoatsID, avoidHerdable);
   rmAddObjectDefConstraint(farGoatsID, avoidTree);
   rmAddObjectDefConstraint(farGoatsID, shortAvoidGold);

  
   // pick lions or hyenas as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "hyena", 3, 2.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farPredatorID, avoidTree);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidGold);


   int farCrocsID=rmCreateObjectDef("far Crocs");
   rmAddObjectDefItem(farCrocsID, "crocodile", 2, 1.0);
   rmSetObjectDefMinDistance(farCrocsID, 0.0);
   rmSetObjectDefMaxDistance(farCrocsID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farCrocsID, farStartingSettleConstraint); 
   rmAddObjectDefConstraint(farCrocsID, nearShore);
   rmAddObjectDefConstraint(farCrocsID, avoidTree);
   rmAddObjectDefConstraint(farCrocsID, shortAvoidGold); 
 
   // This map will either use elephants, giraffe, or zebra as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "elephant", 2, 4.0);
   else if(bonusChance<0.75)
      rmAddObjectDefItem(bonusHuntableID, "giraffe", 3, 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "zebra", 6, 4.0);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, avoidTree);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidGold);
  
   // Pick hippos
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID2, "elephant", 1, 2.0);
   else if(bonusChance<0.75)
      rmAddObjectDefItem(bonusHuntableID2, "hippo", 2, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID2, "hippo", 4, 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, nearShore);
   rmAddObjectDefConstraint(bonusHuntableID2, avoidTree);
   rmAddObjectDefConstraint(bonusHuntableID2, shortAvoidGold);

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
   rmAddObjectDefConstraint(relicID, avoidTree);
   rmAddObjectDefConstraint(relicID, shortAvoidGold);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);

   // -------------Done defining objects
   
   //Fill in cliffed area with sand
   int mapEdgeConstraint=rmCreateBoxConstraint("rock edge of map", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3)); 
   int plainsID=rmCreateArea("sandy desert");
   rmSetAreaSize(plainsID, 0.9, 0.9);
   rmSetAreaLocation(plainsID, 0.5, 0.5);
   rmSetAreaTerrainType(plainsID, "SandA");
   rmAddAreaTerrainLayer(plainsID, "cliffEgyptianB", 0, 3);
   rmSetAreaMinBlobs(plainsID, 1);
   rmSetAreaMaxBlobs(plainsID, 5);
   rmSetAreaMinBlobDistance(plainsID, 16.0);
   rmSetAreaMaxBlobDistance(plainsID, 40.0);
   rmSetAreaCoherence(plainsID, 0.0);
   rmSetAreaSmoothDistance(plainsID, 10);
   rmSetAreaBaseHeight(plainsID, 2.0);
   rmSetAreaHeightBlend(plainsID, 2);
   rmAddAreaConstraint(plainsID, mapEdgeConstraint);
   rmBuildArea(plainsID);
   
   // Cheesy square placement of players.
   if(cNumberNonGaiaPlayers < 8)
      rmSetTeamSpacingModifier(0.25);
   else if(cNumberNonGaiaPlayers < 11) 
      rmSetTeamSpacingModifier(0.40);
   else
      rmSetTeamSpacingModifier(0.50);

    rmPlacePlayersSquare(0.30, 10.0, 10.0);

   // Text
   rmSetStatusText("",0.20);

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(1000); /* 2600 */
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);
      rmAddAreaConstraint(id, playerConstraint);
       rmAddAreaConstraint(id, mapEdgeConstraint);
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "SandC");
   }


   // Build the areas.
   rmBuildAllAreas();

   for(i=1; <cNumberPlayers*5)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Patch "+i);
      rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaTerrainType(id2, "SandB");
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 5.0);
      rmSetAreaMaxBlobDistance(id2, 20.0);
      rmSetAreaCoherence(id2, 0.0);
      rmAddAreaConstraint(id2, mapEdgeConstraint);
      rmBuildArea(id2);
   }

   for(i=1; <cNumberPlayers*5)
   {
      // Beautification sub area.
      int id3=rmCreateArea("Dirt Patch "+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(20), rmAreaTilesToFraction(80));
      rmSetAreaTerrainType(id3, "SandDirt50");
      rmSetAreaMinBlobs(id3, 2);
      rmSetAreaMaxBlobs(id3, 2);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 5.0);
      rmSetAreaMaxBlobDistance(id3, 20.0);
      rmSetAreaCoherence(id3, 0.0);
      rmAddAreaConstraint(id3, mapEdgeConstraint);
      rmBuildArea(id3);
   }

   // Text
   rmSetStatusText("",0.30);

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   id=rmAddFairLoc("Settlement A", false, false,  60, 80, 40, 15); /* bool forward bool inside */
   if(cNumberNonGaiaPlayers > 8)
      id=rmAddFairLoc("Settlement B", true, true, 70, 120, 90, 15);
   else
      id=rmAddFairLoc("Settlement B", true, true, 100, 200, 90, 15);

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

   // Place Gold and Migdols
   rmResetFairLocs();
   
   if(cNumberNonGaiaPlayers > 8)
      id2=rmAddFairLoc("Gold and Migdol", true, true,  70, 100, 50, 15); /* bool forward bool inside */
   else
      id2=rmAddFairLoc("Gold and Migdol", true, true,  100, 200, 50, 15);
   rmAddFairLocConstraint(id2, farAvoidSettlement);
   rmAddFairLocConstraint(id2, migdolStartingSettleConstraint); 


   if(rmPlaceFairLocs())
   {
      id2=rmCreateObjectDef("fair gold and migdols");
      rmAddObjectDefItem(id2, "Bandit Migdol", 1, 0.0);
      rmAddObjectDefItem(id2, "Gold mine", 3, 10.0);
      rmAddObjectDefItem(id2, "statue pharaoh", 2, 12.0);

      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
            rmPlaceObjectDefAtLoc(id2, 0, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
      }
   }

   // Text
   rmSetStatusText("",0.50);

   // Add Extra Migdols so nothing is too predictable
   if(cNumberNonGaiaPlayers<3)
      rmPlaceObjectDefAtLoc(farBanditID, 0, 0.5, 0.5, rmRandInt(0,2));
   else
      rmPlaceObjectDefAtLoc(farBanditID, 0, 0.5, 0.5, rmRandInt(1,4));

   // unguarded gold
   if(cNumberNonGaiaPlayers<3)
      rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, rmRandInt(2,3));
   else
      rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, rmRandInt(3,6));


   /* place ponds away from Settlements and Migdols */

   int pondClass=rmDefineClass("pond");
   int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 10.0);
   int numPonds2=0;
   if(cNumberNonGaiaPlayers < 6)
      numPonds2 = rmRandInt(2,4);
   else
      numPonds2 = rmRandInt(4,7);
   for(i=0; <numPonds2)
   {
      int smallPondID=rmCreateArea("small pond"+i);
      rmSetAreaSize(smallPondID, rmAreaTilesToFraction(600), rmAreaTilesToFraction(800));
      rmSetAreaWaterType(smallPondID, "egyptian nile");
      rmSetAreaBaseHeight(smallPondID, 0.0);
      rmSetAreaMinBlobs(smallPondID, 2);
      rmSetAreaMaxBlobs(smallPondID, 2);
      rmSetAreaMinBlobDistance(smallPondID, 10.0);
      rmSetAreaMaxBlobDistance(smallPondID, 10.0);
      rmSetAreaSmoothDistance(smallPondID, 50);
      rmAddAreaToClass(smallPondID, pondClass);
      rmAddAreaConstraint(smallPondID, mapEdgeConstraint);
      rmAddAreaConstraint(smallPondID, playerConstraint);
      rmAddAreaConstraint(smallPondID, pondConstraint);
      rmAddAreaConstraint(smallPondID, pondAvoidBuildings);
      rmSetAreaWarnFailure(smallPondID, false);
      rmBuildArea(smallPondID);
   }

   int inPond=rmCreateTerrainMaxDistanceConstraint("papyrus near shore", "land", true, 4.0);
   int papyrusID=rmCreateObjectDef("papyrus");
   rmAddObjectDefItem(papyrusID, "papyrus", 1, 0.0);
   rmSetObjectDefMinDistance(papyrusID, 0.0);
   rmSetObjectDefMaxDistance(papyrusID, rmXFractionToMeters(0.5));
/*   rmAddObjectDefConstraint(papyrusID, avoidAll); */
/*   rmAddObjectDefConstraint(papyrusID, inPond); */
/*   rmPlaceObjectDefInRandomAreaOfClass(papyrusID, 0, smallPondID); */
   rmPlaceObjectDefAtLoc(papyrusID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
   
    // Elev.
   int numTries=5*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, avoidImpassableLand); 
      rmSetAreaTerrainType(elevID, "SandD");
      rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 7.0));
      rmSetAreaHeightBlend(elevID, 2);
      rmAddAreaConstraint(elevID, edgeConstraint);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
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

   // Text
   rmSetStatusText("",0.60);

   // Slight Elevation
   numTries=12*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false); 
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, edgeConstraint);
      rmAddAreaConstraint(elevID, pondConstraint); 

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
   rmSetStatusText("",0.70);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3,4));

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Chickens
   rmPlaceObjectDefPerPlayer(closeChickensID, false);      

   // Hippo.
   rmPlaceObjectDefPerPlayer(closeHippoID, false);

   // Medium things....

   // Goats
   rmPlaceObjectDefPerPlayer(mediumGoatsID, false);

   // Zebras
   rmPlaceObjectDefPerPlayer(mediumZebraID, false);


   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int count=0;
   numTries=4*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "palm forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, shortAvoidImpassableLand);
      rmAddAreaConstraint(forestID, mapEdgeConstraint);
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

   // Far things.

   // Relics.
   rmPlaceObjectDefPerPlayer(relicID, false);
      
   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 

   // Bonus huntable.
   rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
  
   // Bonus huntable.
   rmPlaceObjectDefPerPlayer(bonusHuntableID2, false);
   
   // Goats.
   rmPlaceObjectDefPerPlayer(farGoatsID, false, 2);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);

    // Predators
   rmPlaceObjectDefPerPlayer(farCrocsID, false);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);

   // Text
   rmSetStatusText("",0.90);
  
   //rocks
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   int skeletonID=rmCreateObjectDef("skeleton");
   rmAddObjectDefItem(skeletonID, "skeleton", 1, 0.0);
   rmSetObjectDefMinDistance(skeletonID, 0.0);
   rmSetObjectDefMaxDistance(skeletonID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(skeletonID, avoidAll);
   rmAddObjectDefConstraint(skeletonID, avoidBuildings);
   rmAddObjectDefConstraint(skeletonID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(skeletonID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);

     // Bushes
   int bushID=rmCreateObjectDef("big bush patch");
   rmAddObjectDefItem(bushID, "bush", 4, 3.0);
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int bush2ID=rmCreateObjectDef("small bush patch");
   rmAddObjectDefItem(bush2ID, "bush", 3, 2.0);
   rmAddObjectDefItem(bush2ID, "rock sandstone sprite", 1, 2.0);
   rmSetObjectDefMinDistance(bush2ID, 0.0);
   rmSetObjectDefMaxDistance(bush2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bush2ID, avoidAll);
   rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

   int columnID=rmCreateObjectDef("columns");
   rmAddObjectDefItem(columnID, "columns broken", rmRandInt(1,2), 3.0);
   rmSetObjectDefMinDistance(columnID, 0.0);
   rmSetObjectDefMaxDistance(columnID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(columnID, avoidAll);
   rmAddObjectDefConstraint(columnID, avoidBuildings);
   rmAddObjectDefConstraint(columnID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(columnID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

   int baboonID=rmCreateObjectDef("lonely baboon");
   rmAddObjectDefItem(baboonID, "baboon", rmRandInt(1,2), 1.0);
   rmSetObjectDefMinDistance(baboonID, 0.0);
   rmSetObjectDefMaxDistance(baboonID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(baboonID, avoidAll);
   rmAddObjectDefConstraint(baboonID, avoidBuildings);
   rmAddObjectDefConstraint(baboonID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(baboonID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   for(i=0; < cNumberNonGaiaPlayers)
   {
      int statueID=rmCreateObjectDef("statue"+i);
      if(rmRandFloat(0,1)<0.33)
         rmAddObjectDefItem(statueID, "statue pharaoh", 1, 0.0);
      else if(rmRandFloat(0,1)<0.5)
         rmAddObjectDefItem(statueID, "statue lion left", 1, 0.0);
      else
         rmAddObjectDefItem(statueID, "statue lion right", 1, 0.0);
      rmSetObjectDefMinDistance(statueID, 0.0);
      rmSetObjectDefMaxDistance(statueID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(statueID, avoidAll);
      rmAddObjectDefConstraint(statueID, avoidBuildings);
      rmAddObjectDefConstraint(statueID, avoidImpassableLand);
      rmPlaceObjectDefAtLoc(statueID, 0, 0.5, 0.5, 1);
   }
   // Text
   rmSetStatusText("",1.0);

   
}  

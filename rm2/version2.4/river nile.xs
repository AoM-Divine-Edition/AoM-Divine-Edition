// THE RIVER NILE

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
      sizel=2.5*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizew=1.6*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   else
   {
      sizew=2.66*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizel=1.5*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
   rmSetMapSize(sizel, sizew);

   // Set up default water.
   rmSetSeaLevel(0.0);
   rmSetSeaType("Egyptian Nile");

   // Init map.
   rmTerrainInitialize("water");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   rmDefineClass("starting settlement");
   int classPlayerCore=rmDefineClass("player core");


 // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 28.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   if(cNumberTeams > 7)
      avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land by less", "land", false, 6.0);
   int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
   if(cNumberTeams > 7)
      farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land by not so much", "land", false, 8.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
   int avoidShore=rmCreateTerrainDistanceConstraint("stay in middle of ocean", "land", true, 5.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   
   // Stay near shore
   int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 5.0);

  
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
   rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 34.0);
   rmSetObjectDefMaxDistance(startingGoldID, 40.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   int closeGoatsID=rmCreateObjectDef("close Goats");
   rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 20.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 25.0);
   rmAddObjectDefConstraint(closeGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(5,9), 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);

   int closeHippoID=rmCreateObjectDef("close Hippo");
   float hippoNumber=rmRandFloat(0, 1);
   if(hippoNumber<0.3)
      rmAddObjectDefItem(closeHippoID, "hippo", 1, 1.0);
   else if(hippoNumber<0.6)
      rmAddObjectDefItem(closeHippoID, "hippo", 2, 4.0);
   else 
      rmAddObjectDefItem(closeHippoID, "rhinocerous", 1, 1.0);
   rmSetObjectDefMinDistance(closeHippoID, 30.0);
   rmSetObjectDefMaxDistance(closeHippoID, 50.0);
   rmAddObjectDefConstraint(closeHippoID, avoidImpassableLand);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   // medium objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumGoatsID=rmCreateObjectDef("medium goats");
   rmAddObjectDefItem(mediumGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
   rmAddObjectDefConstraint(mediumGoatsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);

   // For this map, pick how many zebra/gazelle in a grouping.  Assign this
   // to both zebra and gazelle since we place them interchangeably per player.
   int numHuntable=rmRandInt(6, 10);

   int mediumGazelleID=rmCreateObjectDef("medium gazelles");
   rmAddObjectDefItem(mediumGazelleID, "gazelle", numHuntable, 4.0);
   rmSetObjectDefMinDistance(mediumGazelleID, 40.0);
   rmSetObjectDefMaxDistance(mediumGazelleID, 80.0);
   rmAddObjectDefConstraint(mediumGazelleID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGazelleID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumGazelleID, farStartingSettleConstraint);

   int mediumZebraID=rmCreateObjectDef("medium zebra");
   rmAddObjectDefItem(mediumZebraID, "zebra", numHuntable, 4.0);
   rmSetObjectDefMinDistance(mediumZebraID, 40.0);
   rmSetObjectDefMaxDistance(mediumZebraID, 80.0);
   rmAddObjectDefConstraint(mediumZebraID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumZebraID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);

   // far objects

   // Settlement avoids gold, Settlements
   // greatly relaxed since this map is weird
   int farSettlementID=rmCreateObjectDef("far settlement");
   rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
   rmSetObjectDefMinDistance(farSettlementID, 60.0);
   rmSetObjectDefMaxDistance(farSettlementID, 160.0);
   rmAddObjectDefConstraint(farSettlementID, edgeConstraint);
/*   rmAddObjectDefConstraint(farSettlementID, shortAvoidGold); */
   rmAddObjectDefConstraint(farSettlementID, farAvoidSettlement);
   rmAddObjectDefConstraint(farSettlementID, farAvoidImpassableLand);

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 60.0);
   rmSetObjectDefMaxDistance(farGoldID, 300.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, edgeConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);

   int farGoatsID=rmCreateObjectDef("far goats");
   rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farGoatsID, avoidHerdable);
  
   // pick lions or hyenas as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "crocodile", 2, 2.0);
   else
      rmAddObjectDefItem(farPredatorID, "crocodile", 1, 0.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
    
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, 600);
   rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);


   // This map will either use elephants, giraffe, or zebra as the extra huntable food.
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "elephant", 2, 4.0);
   else if(bonusChance<0.75)
      rmAddObjectDefItem(bonusHuntableID, "giraffe", 3, 6.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "zebra", 6, 8.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, 600);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
  
   // Pick hippos
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID2, "water buffalo", 4, 2.0);
   else if(bonusChance<0.75)
      rmAddObjectDefItem(bonusHuntableID2, "hippo", 2, 2.0);
   else
      rmAddObjectDefItem(bonusHuntableID2, "hippo", 4, 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, 600);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, nearShore);

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

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, 600);
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);

   // ------------------------------------------------------------------------------Done defining objects
   
  // Text
   rmSetStatusText("",0.20);

   // Cheesy square placement of players.
   rmSetTeamSpacingModifier(0.75);
/*   rmPlacePlayersSquare(0.3, 0.1, 10.0); */

   if(cNumberTeams < 3)
      rmPlacePlayersSquare(0.35, 0.05, 10.0);
   else
      rmPlacePlayersSquare(0.4, 0.05, 10.0);

   // Build team areas.
   int teamClass=rmDefineClass("teamClass");
   int baseRiverWidth = 0;
   if (cNumberTeams < 4)
      baseRiverWidth = 45;
   else if (cNumberTeams < 7)
      baseRiverWidth = 30;
   else
      baseRiverWidth = 30;
   int teamConstraint=rmCreateClassDistanceConstraint("team constraint", teamClass, baseRiverWidth);

   float percentPerPlayer = 0.95/cNumberNonGaiaPlayers;
   float teamSize = 0; 
   for(i=0; <cNumberTeams)
   {
      int teamID=rmCreateArea("team"+i);
   /*   teamSize = rmAreaTilesToFraction(9000*rmGetNumberPlayersOnTeam(rmAreaID("team"+i))); */

      teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
      rmEchoInfo ("team size "+teamSize);
      rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
/*      rmSetAreaLocation(teamID, 0.3, 0.5); */
      rmSetAreaWarnFailure(teamID, false);
      rmSetAreaTerrainType(teamID, "SandA");
      rmSetAreaMinBlobs(teamID, 1);
      rmSetAreaMaxBlobs(teamID, 5);
      rmSetAreaMinBlobDistance(teamID, 16.0);
      rmSetAreaMaxBlobDistance(teamID, 40.0);
      rmSetAreaCoherence(teamID, 0.0);
      rmAddAreaToClass(teamID, teamClass);
      rmSetAreaBaseHeight(teamID, 3.0);
      rmSetAreaHeightBlend(teamID, 2);
      rmAddAreaConstraint(teamID, teamConstraint);
   // rmAddAreaConstraint(teamID, teamEdgeConstraint);
      rmSetAreaSmoothDistance(teamID, 10);
      rmSetAreaLocTeam(teamID, i);
   }
   rmBuildAllAreas();

    // Create player cores that can avoid water   for(i=1; <cNumberPlayers)
/*   for(i=1; <cNumberPlayers)
   {
      int coreID=rmCreateArea("Player core"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
      rmSetAreaSize(coreID, rmAreaTilesToFraction(1), rmAreaTilesToFraction(1));
      rmAddAreaToClass(coreID, classPlayerCore);
      rmAddAreaConstraint(coreID, farAvoidImpassableLand);
      rmSetAreaCoherence(coreID, 1.0);
      rmSetAreaLocPlayer(coreID, i);
      rmBuildArea(coreID); 
   } */


   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(3000);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
      rmSetPlayerArea(i, id);
      rmSetAreaWarnFailure(id, false); 
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction); 
      rmSetAreaSize(id, 1, 1); 
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaMinBlobs(id, 3);
      rmSetAreaMaxBlobs(id, 4);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0); 
      rmSetAreaCoherence(id, 1.0);
      rmAddAreaConstraint(id, playerConstraint);
      rmAddAreaConstraint(id, farAvoidImpassableLand);
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "SandC"); 
   }

   // Build the areas.
   rmBuildAllAreas();

   for(i=1; <cNumberPlayers)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
      rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
      rmSetAreaWarnFailure(id2, false); 
/*      rmSetAreaLocPlayer(id2, i); */
      rmSetAreaTerrainType(id2, "SandB");

      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaMinBlobDistance(id2, 5.0);
      rmSetAreaMaxBlobDistance(id2, 20.0);
      rmSetAreaCoherence(id2, 0.0);
      rmBuildArea(id2);
   }

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farSettlementID, 0, rmAreaID("player"+i), 2);

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Slight Elevation
   int failCount=0;
   int numTries=20*cNumberNonGaiaPlayers;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmAddAreaConstraint(elevID, avoidBuildings);
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

  // Text
   rmSetStatusText("",0.40);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

    // Goats
   rmPlaceObjectDefPerPlayer(closeGoatsID, true);

   // Chickens
   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   // Hippo.
   rmPlaceObjectDefPerPlayer(closeHippoID, false);

   // Medium things....
   // Gold
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(mediumGoldID, i, rmAreaID("player"+i));

   // Goats
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumGoatsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);

   // Gazelle or zebra.  Flip a coin.
   for(i=1; <cNumberPlayers)
   {
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmPlaceObjectDefAtLoc(mediumGazelleID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else
         rmPlaceObjectDefAtLoc(mediumZebraID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }
      
   // Far things.

   // Gold.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("team"+rmGetPlayerTeam(i)), 3);

   // Relics.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i));

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

   // Bonus huntable

   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i));

 
  // Bonus huntable2

   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(bonusHuntableID2, 0, rmAreaID("team"+rmGetPlayerTeam(i)));

   // Goats.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farGoatsID, 0, rmAreaID("player"+i));

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers/2);

   // Predators
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("team"+rmGetPlayerTeam(i)));

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",0.60);

   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 15.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   failCount=0;
   numTries=10*cNumberNonGaiaPlayers;
   for(i=0; <numTries)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "palm forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, shortAvoidImpassableLand);
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

   // Fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 22.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - perch", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, 600);
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
  rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers); 

   //papyrus
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int papyrusID=rmCreateObjectDef("lone papyrus");
   int nearshore=rmCreateTerrainMaxDistanceConstraint("papyrus near shore", "land", true, 4.0);
   rmAddObjectDefItem(papyrusID, "papyrus", 3, 2.0);
   rmSetObjectDefMinDistance(papyrusID, 0.0);
   rmSetObjectDefMaxDistance(papyrusID, 600);
   rmAddObjectDefConstraint(papyrusID, avoidAll);
   rmAddObjectDefConstraint(papyrusID, nearshore);
   rmPlaceObjectDefAtLoc(papyrusID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);

   int papyrus2ID=rmCreateObjectDef("grouped papyrus");
   rmAddObjectDefItem(papyrus2ID, "papyrus", 5, 7.0);
   rmSetObjectDefMinDistance(papyrus2ID, 0.0);
   rmSetObjectDefMaxDistance(papyrus2ID, 600);
   rmAddObjectDefConstraint(papyrus2ID, avoidAll);
   rmAddObjectDefConstraint(papyrus2ID, nearshore);
   rmPlaceObjectDefAtLoc(papyrus2ID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

   int lilyID=rmCreateObjectDef("pads");
   rmAddObjectDefItem(lilyID, "water lilly", 4, 2.0);
   rmSetObjectDefMinDistance(lilyID, 0.0);
   rmSetObjectDefMaxDistance(lilyID, 600);
   rmAddObjectDefConstraint(lilyID, avoidAll);
   rmPlaceObjectDefAtLoc(lilyID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);

   int lily2ID=rmCreateObjectDef("mo' pads");
   rmAddObjectDefItem(lily2ID, "water lilly", 1, 0.0);
   rmSetObjectDefMinDistance(lily2ID, 0.0);
   rmSetObjectDefMaxDistance(lily2ID, 600);
   rmAddObjectDefConstraint(lily2ID, avoidAll);
   rmPlaceObjectDefAtLoc(lily2ID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",0.80);

   //rocks
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, 600);
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   // Bushes
   int bushID=rmCreateObjectDef("big bush patch");
   rmAddObjectDefItem(bushID, "bush", 4, 3.0);
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, 600);
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int bush2ID=rmCreateObjectDef("small bush patch");
   rmAddObjectDefItem(bush2ID, "bush", 3, 2.0);
   rmAddObjectDefItem(bush2ID, "rock sandstone sprite", 1, 2.0);
   rmSetObjectDefMinDistance(bush2ID, 0.0);
   rmSetObjectDefMaxDistance(bush2ID, 600);
   rmAddObjectDefConstraint(bush2ID, avoidAll);
   rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

   int nearRiver=rmCreateTerrainMaxDistanceConstraint("near river", "water", true, 5.0);
   int riverBushID=rmCreateObjectDef("bushs by river");
   rmAddObjectDefItem(riverBushID, "bush", 3, 3.0);
   rmAddObjectDefItem(riverBushID, "grass", 7, 8.0);
   rmSetObjectDefMinDistance(riverBushID, 0.0);
   rmSetObjectDefMaxDistance(riverBushID, 600);
   rmAddObjectDefConstraint(riverBushID, avoidAll);
   rmAddObjectDefConstraint(riverBushID, nearRiver);
   rmPlaceObjectDefAtLoc(riverBushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);

   
}  

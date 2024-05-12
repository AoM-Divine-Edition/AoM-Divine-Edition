// WATERING HOLE

// Main entry point for random map script
void main(void)
{

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
   rmSetSeaLevel(1.0);
   rmSetSeaType("savannah Water Hole");

   // Init map.
   rmTerrainInitialize("water");

   // Define some classes.
   int classIsland=rmDefineClass("island");
   int classBonusIsland=rmDefineClass("bonus island");
   int classPlayerCore=rmDefineClass("player core");
   int classPlayer=rmDefineClass("player");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   rmDefineClass("center");
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1));
   int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8), 0.01);
   int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 40.0);

   // Player area constraint.
   int islandConstraint=rmCreateClassDistanceConstraint("stay away from islands", classIsland, 20.0);
   int coreBonusConstraint=rmCreateClassDistanceConstraint("core v bonus island", classPlayerCore, 50.0);
   int playerConstraint=rmCreateClassDistanceConstraint("bonus Settlement stay away from players", classPlayer, 10);

   // Bonus area constraint.
   int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid bonus island", classBonusIsland, 15.0);
   int bonusIslandEdgeConstraint=rmCreateBoxConstraint("bonus island avoids edge", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30)); 

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraint.
   int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);

   // Far starting settlement constraint.
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 50.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Pigs/pigs
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

   // Bonus huntable
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 15.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
   int tinyAvoidImpassableLand=rmCreateTerrainDistanceConstraint("tiny avoid impassable land", "Land", false, 2.0);
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);

      // Stay near shore
   int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);


   // note - try and trim down on the number of these. Many must be redundant.


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

   // towers avoid other towers
   int startingTower2ID=rmCreateObjectDef("Starting tower2");
   rmAddObjectDefItem(startingTower2ID, "tower", 1, 0.0);
/*   rmAddObjectDefItem(startingTower2ID, "gazelle", 6.0, 4.0); */
/* Gazelle were placed as player's */
   rmSetObjectDefMinDistance(startingTower2ID, 22.0);
   rmSetObjectDefMaxDistance(startingTower2ID, 28.0);
   rmAddObjectDefConstraint(startingTower2ID, avoidTower);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   int closePigsID=rmCreateObjectDef("close Pigs");
   rmAddObjectDefItem(closePigsID, "pig", rmRandInt(0,2), 2.0);
   rmSetObjectDefMinDistance(closePigsID, 25.0);
   rmSetObjectDefMaxDistance(closePigsID, 30.0);
   rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closePigsID, avoidFood);

   int closeGazelleID=rmCreateObjectDef("close gazelles");
   rmAddObjectDefItem(closeGazelleID, "gazelle", rmRandInt(3,8), 4.0);
   rmSetObjectDefMinDistance(closeGazelleID, 25.0);
   rmSetObjectDefMaxDistance(closeGazelleID, 30.0);
   rmAddObjectDefConstraint(closeGazelleID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeGazelleID, avoidFood);

   int closeHippoID=rmCreateObjectDef("close Hippo");
   float hippoNumber=rmRandFloat(0, 1);
   if(hippoNumber<0.3)
      rmAddObjectDefItem(closeHippoID, "hippo", 2, 1.0);
   else if(hippoNumber<0.6)
      rmAddObjectDefItem(closeHippoID, "hippo", 3, 4.0);
   else 
      rmAddObjectDefItem(closeHippoID, "rhinocerous", 2, 1.0);
   rmSetObjectDefMinDistance(closeHippoID, 30.0);
   rmSetObjectDefMaxDistance(closeHippoID, 50.0);
   rmAddObjectDefConstraint(closeHippoID, avoidImpassableLand);
   
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   rmAddObjectDefConstraint(stragglerTreeID, avoidImpassableLand);

   // medium objects

   // Text
   rmSetStatusText("",0.20);

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(2,3), 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
   rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumPigsID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);

   // For this map, pick how many zebra/gazelle in a grouping.  Assign this
   // to both zebra and gazelle since we place them interchangeably per player.
   int numHuntable=rmRandInt(6, 10);

   int mediumGazelleID=rmCreateObjectDef("medium gazelles");
   rmAddObjectDefItem(mediumGazelleID, "gazelle", numHuntable, 4.0);
   rmSetObjectDefMinDistance(mediumGazelleID, 40.0);
   rmSetObjectDefMaxDistance(mediumGazelleID, 80.0);
   rmAddObjectDefConstraint(mediumGazelleID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGazelleID, farStartingSettleConstraint);

   int mediumZebraID=rmCreateObjectDef("medium zebra");
   rmAddObjectDefItem(mediumZebraID, "zebra", numHuntable, 4.0);
   rmSetObjectDefMinDistance(mediumZebraID, 40.0);
   rmSetObjectDefMaxDistance(mediumZebraID, 80.0);
   rmAddObjectDefConstraint(mediumZebraID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);

   // far objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 100.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, edgeConstraint);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);

   // gold avoids gold, Settlements and TCs
   int bonusGoldID=rmCreateObjectDef("gold on bonus islands");
   rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(bonusGoldID, 90.0);
   rmSetObjectDefMaxDistance(bonusGoldID, 180.0);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidGold);
   rmAddObjectDefConstraint(bonusGoldID, edgeConstraint);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(bonusGoldID, playerConstraint);
   rmAddObjectDefConstraint(bonusGoldID, avoidImpassableLand);

   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "pig", rmRandInt(1,2), 4.0);
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
  
   // pick lions or hyenas as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "lion", 3, 2.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);

   int farCrocsID=rmCreateObjectDef("far Crocs");
   rmAddObjectDefItem(farCrocsID, "crocodile", rmRandInt(1,2), 0.0);
   rmSetObjectDefMinDistance(farCrocsID, 50.0);
   rmSetObjectDefMaxDistance(farCrocsID, 100.0);
   rmAddObjectDefConstraint(farCrocsID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farCrocsID, nearShore);
   // try and place near water

   int numCrane=rmRandInt(6, 8);
   int farCraneID=rmCreateObjectDef("far Crane");
   rmAddObjectDefItem(farCraneID, "crowned crane", numCrane, 3.0);
   rmSetObjectDefMinDistance(farCraneID, 50.0);
   rmSetObjectDefMaxDistance(farCraneID, 150.0);
   rmAddObjectDefConstraint(farCraneID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farCraneID, nearShore);
      
   // Player huntable
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "elephant", 2, 2.0);
   else if(bonusChance<0.75)
      rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,4), 3.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "hippo", rmRandInt(3,5), 3.0);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
  
   // Bonus huntable 1
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID2, "elephant", 2, 2.0);
   else if(bonusChance<0.75)
      {
         rmAddObjectDefItem(bonusHuntableID2, "water buffalo", rmRandInt(5,6), 3.0);
         if(rmRandFloat(0,1)<0.5)      
            rmAddObjectDefItem(bonusHuntableID2, "zebra", rmRandInt(2,4), 3.0);
      }
   else
      rmAddObjectDefItem(bonusHuntableID2, "gazelle", rmRandInt(6,9), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, nearShore);

   // Bonus huntable 2
   int bonusHuntableID3=rmCreateObjectDef("bonus huntable3");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID3, "hippo", 3, 2.0);
   else if(bonusChance<0.75)
      {
         rmAddObjectDefItem(bonusHuntableID3, "zebra", rmRandInt(4,6), 3.0);
         if(rmRandFloat(0,1)<0.5)      
            rmAddObjectDefItem(bonusHuntableID3, "giraffe", rmRandInt(2,4), 4.0);
      }
   else
      rmAddObjectDefItem(bonusHuntableID3, "rhinocerous", 4, 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID3, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID3, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID3, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID3, farStartingSettleConstraint);

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

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);

   int randomTreeID2=rmCreateObjectDef("random tree 2");
   rmAddObjectDefItem(randomTreeID2, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID2, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID2, rmCreateTypeDistanceConstraint("random tree two", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID2, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID2, shortAvoidSettlement);

   // --------------------------------------------------------------------------------------------Done defining objects

   // Create areas
    rmPlacePlayersCircular(0.4, 0.45, rmDegreesToRadians(5.0));

   int centerID=rmCreateArea("center");
   rmSetAreaSize(centerID, 0.01, 0.01);
   rmSetAreaLocation(centerID, 0.5, 0.5);
   rmAddAreaToClass(centerID, rmClassID("center"));
   rmBuildArea(centerID);

    // Create player cores so bonus islands avoid them
    for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player core"+i);
      rmSetAreaSize(id, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
      rmAddAreaToClass(id, classPlayerCore);
      rmSetAreaCoherence(id, 1.0);
      rmSetAreaLocPlayer(id, i);

      rmBuildArea(id);
   }

   // Create connections
   int shallowsID=rmCreateConnection("shallows");
   rmSetConnectionType(shallowsID, cConnectAreas, false, 1.0);
   rmSetConnectionWidth(shallowsID, 16, 2);
   rmSetConnectionWarnFailure(shallowsID, false);
   rmSetConnectionBaseHeight(shallowsID, 2.0);
   rmSetConnectionHeightBlend(shallowsID, 2.0);
   rmSetConnectionSmoothDistance(shallowsID, 3.0);
   rmAddConnectionTerrainReplacement(shallowsID, "riverSandyA", "SavannahC"); /*riverSandyC */

   // Create extra connections
   int extraShallowsID=rmCreateConnection("extra shallows");
   if(cNumberPlayers < 5)
      rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.75);
   else if(cNumberPlayers < 7) 
      rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.30);
   rmSetConnectionWidth(extraShallowsID, 16, 2);
   rmSetConnectionWarnFailure(extraShallowsID, false); 
   rmSetConnectionBaseHeight(extraShallowsID, 2.0);
   rmSetConnectionHeightBlend(extraShallowsID, 2.0);
   rmSetConnectionSmoothDistance(extraShallowsID, 3.0);
   rmSetConnectionPositionVariance(extraShallowsID, -1.0); 
   rmAddConnectionTerrainReplacement(extraShallowsID, "riverSandyA", "SavannahC"); 
   rmAddConnectionStartConstraint(extraShallowsID, coreBonusConstraint);
   rmAddConnectionEndConstraint(extraShallowsID, coreBonusConstraint);

  // Create team connections
   int teamShallowsID=rmCreateConnection("team shallows");
   rmSetConnectionType(teamShallowsID, cConnectAllies, false, 1.0);
   rmSetConnectionWarnFailure(teamShallowsID, false);
   rmSetConnectionWidth(teamShallowsID, 16, 2);
   rmSetConnectionBaseHeight(teamShallowsID, 2.0);
   rmSetConnectionHeightBlend(teamShallowsID, 2.0);
   rmSetConnectionSmoothDistance(teamShallowsID, 3.0);
   rmAddConnectionTerrainReplacement(teamShallowsID, "riverSandyA", "SavannahC");

   // Build up some bonus islands.
   int bonusCount = rmRandInt(2, 3);
   int bonusIsleSize = 1800;

   if(cNumberNonGaiaPlayers > 5) 
   {
      bonusIsleSize = 3000;
      bonusCount = rmRandInt(3, 4);
   }   
   else if(cNumberNonGaiaPlayers > 8)
   {
      bonusIsleSize = 3000;
      bonusCount = rmRandInt(3, 4);
   }   
   else
   {
      bonusIsleSize = 3000;
      bonusCount = rmRandInt(3, 4);
   }   
   rmEchoInfo("number of bonus isles "+bonusCount+ "size of isles "+bonusIsleSize);
  
   for(i=0; <bonusCount)
   {
      int bonusIslandID=rmCreateArea("bonus island"+i);
      rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(bonusIsleSize*0.9), rmAreaTilesToFraction(bonusIsleSize*1.1));
      rmSetAreaTerrainType(bonusIslandID, "SavannahB");
      rmAddAreaTerrainLayer(bonusIslandID, "SavannahC", 0, 6); 
      rmSetAreaWarnFailure(bonusIslandID, false);
      if(rmRandFloat(0.0, 1.0)<0.70)
         rmAddAreaConstraint(bonusIslandID, bonusIslandConstraint);
      rmAddAreaConstraint(bonusIslandID, bonusIslandEdgeConstraint);
      rmAddAreaToClass(bonusIslandID, classIsland);
      rmAddAreaToClass(bonusIslandID, classBonusIsland);
      rmAddAreaConstraint(bonusIslandID, coreBonusConstraint);
      rmSetAreaCoherence(bonusIslandID, 0.25);
      rmSetAreaSmoothDistance(bonusIslandID, 12);
      rmSetAreaHeightBlend(bonusIslandID, 2);
      rmSetAreaBaseHeight(bonusIslandID, 2.0);
      rmAddConnectionArea(extraShallowsID, bonusIslandID);
      rmAddConnectionArea(shallowsID, bonusIslandID);
   }  

   rmBuildAllAreas();

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(3500);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      id=rmCreateArea("Player"+i);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 1.0, 1.0);
      rmAddAreaToClass(id, classIsland);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 5.0);
      rmSetAreaMaxBlobDistance(id, 10.0);
      rmSetAreaCoherence(id, 0.6);
      rmSetAreaBaseHeight(id, 2.0);
      rmSetAreaSmoothDistance(id, 10);
      rmSetAreaHeightBlend(id, 2);
      rmAddAreaConstraint(id, islandConstraint);
      rmAddAreaConstraint(id, cornerOverlapConstraint);
      rmAddAreaConstraint(id, bonusIslandConstraint);
      rmAddAreaConstraint(id, centerConstraint);
      rmSetAreaLocPlayer(id, i);
      rmAddConnectionArea(extraShallowsID, id);
      rmAddConnectionArea(shallowsID, id);
      rmSetAreaTerrainType(id, "SavannahB");
      rmAddAreaTerrainLayer(id, "SavannahC", 0, 12);
   }

   // Build all areas
   rmBuildAllAreas();
   rmBuildConnection(teamShallowsID);
   rmBuildConnection(shallowsID);
   if(cNumberNonGaiaPlayers < 4)
      rmBuildConnection(extraShallowsID);
   else if(cNumberNonGaiaPlayers < 6)
   {   
      if(rmRandFloat(0,1)<0.5)
         rmBuildConnection(extraShallowsID);
   }


   for(i=1; <cNumberPlayers*50)
   {
     // Beautification sub area.
     int id2=rmCreateArea("dirt patch"+i);
     rmSetAreaSize(id2, rmAreaTilesToFraction(20), rmAreaTilesToFraction(40));
     rmSetAreaTerrainType(id2, "SavannahA");
     rmSetAreaMinBlobs(id2, 1);
     rmSetAreaMaxBlobs(id2, 5);
     rmSetAreaMinBlobDistance(id2, 16.0);
     rmSetAreaMaxBlobDistance(id2, 40.0);
     rmSetAreaCoherence(id2, 0.0);
     rmAddAreaConstraint(id2, shortAvoidImpassableLand);
    rmBuildArea(id2); 
   }

   // Beautification sub area.
   for(i=1; <cNumberPlayers*15)
   {
        int id3=rmCreateArea("grass patch"+i);
        rmSetAreaSize(id3, rmAreaTilesToFraction(10), rmAreaTilesToFraction(50));
        rmSetAreaTerrainType(id3, "SandA");
        rmSetAreaMinBlobs(id3, 1);
        rmSetAreaMaxBlobs(id3, 5);
        rmSetAreaMinBlobDistance(id3, 16.0);
        rmSetAreaMaxBlobDistance(id3, 40.0);
        rmSetAreaCoherence(id3, 0.0);
        rmAddAreaConstraint(id3, shortAvoidImpassableLand);
        rmBuildArea(id3);
   } 
  
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

    // Elev.
   int failCount=0;
   int numTries1=10*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
   for(i=0; <numTries1)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(20), rmAreaTilesToFraction(80));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false); 
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.7)
         rmSetAreaTerrainType(elevID, "SavannahC");
      rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
      rmSetAreaHeightBlend(elevID, 1);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
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

   // Text
   rmSetStatusText("",0.40);

  // Home Settlement
   id=rmAddFairLoc("Settlement", false, true, 60, 100, 40, 16, true); /* bool forward bool inside */
   rmAddFairLocConstraint(id, avoidImpassableLand);
   
   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {
            int settleArea = rmCreateArea("settlement area"+i +j, rmAreaID("Player"+i));
            rmSetAreaLocation(settleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
            rmBuildArea(settleArea);
            rmPlaceObjectDefAtAreaLoc(id, i, settleArea);
         } 
      }
   }

   rmResetFairLocs();

   // Bonus Settlement
   id=rmAddFairLoc("Settlement", true, false,  70, 160, 80, 16); 
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);
   rmAddFairLocConstraint(id, playerConstraint);

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("bonus settlement");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
         {
            int bonusSettleArea = rmCreateArea("bonus settlement area"+i +j);
            rmSetAreaLocation(bonusSettleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
            rmBuildArea(bonusSettleArea);
            rmPlaceObjectDefAtAreaLoc(id, i, bonusSettleArea); 
         }
      }
   }



 /*  {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i), rmFairLocZFraction(i), 1);
      }
   } */



   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 3);
   rmPlaceObjectDefPerPlayer(startingTower2ID, true, 1);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(0, 7));

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

    // Pigs
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   // Gazelle
   rmPlaceObjectDefPerPlayer(closeGazelleID, false); 

   // Hippo.
   rmPlaceObjectDefPerPlayer(closeHippoID, false);

   // Medium things....
   // Gold
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(mediumGoldID, 0, rmAreaID("player"+i));

   // Pigs
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(mediumPigsID, 0, rmAreaID("player"+i));

   // Gazelle or zebra.  Flip a coin.
   if(rmRandFloat(0.0, 1.0)<0.5)   
   {
      for(i=1; <cNumberPlayers)
         rmPlaceObjectDefInArea(mediumGazelleID, 0, rmAreaID("player"+i));
   }
   else if(rmRandFloat(0,1)<0.2)
   {
      for(i=1; <cNumberPlayers)
      {
        rmPlaceObjectDefInArea(mediumGazelleID, 0, rmAreaID("player"+i));
        rmPlaceObjectDefInArea(mediumZebraID, 0, rmAreaID("player"+i));
      }
   }
   else
   {
      for(i=1; <cNumberPlayers)
         rmPlaceObjectDefInArea(mediumZebraID, 0, rmAreaID("player"+i));
   }

      
   // Far things.

   // Player Far Gold, need goldNum since it randomizes for each i
   int goldNum = rmRandInt(1,2);
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farGoldID, false, rmAreaID("player"+i), goldNum);
  
  // Bonus Gold
   rmPlaceObjectDefPerPlayer(bonusGoldID, false, rmRandInt(1,2));

   // Relics.
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(relicID, i, rmAreaID("player"+i));

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farCrocsID, false, rmAreaID("player"+i));

   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farCraneID, false, rmAreaID("player"+i));

   // Bonus huntable
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(bonusHuntableID, false, rmAreaID("player"+i));
  
    // Bonus huntable
   for(i=1; <bonusCount)
   {
      rmPlaceObjectDefInArea(bonusHuntableID2, false, rmAreaID("bonus island"+i));
      rmPlaceObjectDefInArea(bonusHuntableID3, false, rmAreaID("bonus island"+i));
   }
   
   // Pigs
   int pigNum = rmRandInt(1,2);
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farPigsID, false, rmAreaID("player"+i), pigNum);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);

   // Text
   rmSetStatusText("",0.60);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   rmPlaceObjectDefAtLoc(randomTreeID2, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

   /// Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=10*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(forestID, false);
      if(rmRandFloat(0,1)<0.8)
         rmSetAreaForestType(forestID, "savannah forest");
      else
         rmSetAreaForestType(forestID, "palm forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
      rmAddAreaToClass(forestID, classForest);
      
      rmSetAreaMinBlobs(forestID, 2);
      rmSetAreaMaxBlobs(forestID, 4);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 20.0);
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

   // Text
   rmSetStatusText("",0.90);

   int rockID=rmCreateObjectDef("rock small");
   rmAddObjectDefItem(rockID, "rock sandstone small", 3, 2.0);
   rmAddObjectDefItem(rockID, "rock limestone sprite", 4, 3.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int skeletonID=rmCreateObjectDef("dead animal");
   rmAddObjectDefItem(skeletonID, "skeleton animal", 1, 0.0);
   rmSetObjectDefMinDistance(skeletonID, 0.0);
   rmSetObjectDefMaxDistance(skeletonID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(skeletonID, avoidAll);
   rmAddObjectDefConstraint(skeletonID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(skeletonID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers); 
 
   int rockID2=rmCreateObjectDef("rock sprite");
   rmAddObjectDefItem(rockID2, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers); 

   int lilyID=rmCreateObjectDef("lily pads");
   rmAddObjectDefItem(lilyID, "water lilly", 1, 0.0);
   rmSetObjectDefMinDistance(lilyID, 0.0);
   rmSetObjectDefMaxDistance(lilyID, 600);
   rmAddObjectDefConstraint(lilyID, avoidAll);
   rmPlaceObjectDefAtLoc(lilyID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers); 

   int lily2ID=rmCreateObjectDef("lily2 pad groups");
   rmAddObjectDefItem(lily2ID, "water lilly", 4, 2.0);
   rmSetObjectDefMinDistance(lily2ID, 0.0);
   rmSetObjectDefMaxDistance(lily2ID, 600);
   rmAddObjectDefConstraint(lily2ID, avoidAll);
   rmPlaceObjectDefAtLoc(lily2ID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers); 

   int decorID=rmCreateObjectDef("water decorations");
   rmAddObjectDefItem(decorID, "water decoration", 3, 6.0);
   rmSetObjectDefMinDistance(decorID, 0.0);
   rmSetObjectDefMaxDistance(decorID, 600);
   rmAddObjectDefConstraint(decorID, avoidAll);
   rmPlaceObjectDefAtLoc(decorID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);

}  





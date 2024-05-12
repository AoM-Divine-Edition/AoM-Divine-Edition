// Highland

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
   int size=2.1*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(1.0);
   rmSetSeaType("Greek River");
//	rmSetLightingSet("Ghost Lake");

   // Init map.
   rmTerrainInitialize("water");
//	rmSetLightingSet("Ghost Lake");

   // Define some classes.
   int classIsland=rmDefineClass("island");
   int classBonusIsland=rmDefineClass("bonus island");
   int classPlayerCore=rmDefineClass("player core");
   int classPlayer=rmDefineClass("player");
	int classForest=rmDefineClass("forest");
	int classShallows=rmDefineClass("shallows");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   rmDefineClass("center");
   

	int classCliff=rmDefineClass("cliff");
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 60.0);


					// Create a edge of map constraint.
					int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1));
					int farEdgeConstraint=rmCreateBoxConstraint("far edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));
					int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8), 0.01);
					int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 60.0);
					int shortCenterConstraint=rmCreateClassDistanceConstraint("small stay away from center", rmClassID("center"), 60.0);

					// Player area constraint.
					int islandConstraint=rmCreateClassDistanceConstraint("stay away from islands", classIsland, 30.0);
					int coreBonusConstraint=rmCreateClassDistanceConstraint("core v bonus island", classPlayerCore, 60.0);
					int playerConstraint=rmCreateClassDistanceConstraint("bonus Settlement stay away from players", classPlayer, 20);
					int shortCoreBonusConstraint=rmCreateClassDistanceConstraint("short core v bonus island", classPlayerCore, 40.0);

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
					int farAvoidAll=rmCreateTypeDistanceConstraint("far avoid all", "all", 10.0);
					int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);

					// Stay near shore
					int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);
					
					//Forest close constraint
					int closeForestConstraint=rmCreateClassDistanceConstraint("closeforest v oakforest", rmClassID("forest"), 6.0);


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
   rmSetObjectDefMaxDistance(startingTowerID, 26.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, farAvoidAll);

   // towers avoid other towers
   int startingTower2ID=rmCreateObjectDef("Starting tower2");
   rmAddObjectDefItem(startingTower2ID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTower2ID, 22.0);
   rmSetObjectDefMaxDistance(startingTower2ID, 26.0);
   rmAddObjectDefConstraint(startingTower2ID, avoidTower);
	rmAddObjectDefConstraint(startingTower2ID, farAvoidAll);

   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   int closePigsID=rmCreateObjectDef("close Pigs");
   rmAddObjectDefItem(closePigsID, "cow", 3, 2.0);
   rmSetObjectDefMinDistance(closePigsID, 25.0);
   rmSetObjectDefMaxDistance(closePigsID, 30.0);
   rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, avoidAll);
	rmAddObjectDefConstraint(closePigsID, closeForestConstraint);


   int closeGazelleID=rmCreateObjectDef("close gazelles");
   rmAddObjectDefItem(closeGazelleID, "deer", rmRandInt(6,8), 4.0);
   rmSetObjectDefMinDistance(closeGazelleID, 25.0);
   rmSetObjectDefMaxDistance(closeGazelleID, 30.0);
   rmAddObjectDefConstraint(closeGazelleID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeGazelleID, avoidFood);
//	rmAddObjectDefConstraint(closeGazelleID, bonusIslandConstraint);
	rmAddObjectDefConstraint(closeGazelleID, closeForestConstraint);
	rmAddObjectDefConstraint(closeGazelleID, avoidAll);

   int closeHippoID=rmCreateObjectDef("close Hippo");
   float hippoNumber=rmRandFloat(0, 1);
   if(hippoNumber<0.3)
      rmAddObjectDefItem(closeHippoID, "water buffalo", 2, 1.0);
   else if(hippoNumber<0.6)
      rmAddObjectDefItem(closeHippoID, "water buffalo", 3, 4.0);
   else 
      rmAddObjectDefItem(closeHippoID, "water buffalo", 2, 1.0);
   rmSetObjectDefMinDistance(closeHippoID, 30.0);
   rmSetObjectDefMaxDistance(closeHippoID, 50.0);
   rmAddObjectDefConstraint(closeHippoID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeHippoID, closeForestConstraint);
	rmAddObjectDefConstraint(closeHippoID, avoidAll);
   
   

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
   rmAddObjectDefItem(mediumPigsID, "cow", rmRandInt(2,3), 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
   rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumPigsID, avoidFoodFar);
   rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumPigsID, closeForestConstraint);
//	rmAddObjectDefConstraint(mediumPigsID, playerConstraint);

   // For this map, pick how many zebra/gazelle in a grouping.  Assign this
   // to both zebra and gazelle since we place them interchangeably per player.
   int numHuntable=rmRandInt(6, 10);

   int mediumGazelleID=rmCreateObjectDef("medium gazelles");
   rmAddObjectDefItem(mediumGazelleID, "deer", numHuntable, 6.0);
   rmSetObjectDefMinDistance(mediumGazelleID, 40.0);
   rmSetObjectDefMaxDistance(mediumGazelleID, 80.0);
   rmAddObjectDefConstraint(mediumGazelleID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumGazelleID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGazelleID, cliffConstraint);
	rmAddObjectDefConstraint(mediumGazelleID, closeForestConstraint);
	rmAddObjectDefConstraint(mediumGazelleID, avoidAll);

   int mediumZebraID=rmCreateObjectDef("medium zebra");
   rmAddObjectDefItem(mediumZebraID, "deer", numHuntable, 8.0);
   rmSetObjectDefMinDistance(mediumZebraID, 40.0);
   rmSetObjectDefMaxDistance(mediumZebraID, 80.0);
   rmAddObjectDefConstraint(mediumZebraID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumZebraID, closeForestConstraint);
	rmAddObjectDefConstraint(mediumZebraID, cliffConstraint);
	rmAddObjectDefConstraint(mediumZebraID, avoidAll);

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
   rmSetObjectDefMaxDistance(bonusGoldID, 160.0);
   rmAddObjectDefConstraint(bonusGoldID, avoidGold);
   rmAddObjectDefConstraint(bonusGoldID, edgeConstraint);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
//   rmAddObjectDefConstraint(bonusGoldID, playerConstraint);
   rmAddObjectDefConstraint(bonusGoldID, avoidImpassableLand);

   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "cow", rmRandInt(1,2), 4.0);
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
//	rmAddObjectDefConstraint(farPigsID, playerConstraint);
	rmAddObjectDefConstraint(farPigsID, closeForestConstraint);
  
   // pick lions or hyenas as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "bear", 2, 2.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, closeForestConstraint);
//	rmAddObjectDefConstraint(farPredatorID, playerConstraint);

   int farCrocsID=rmCreateObjectDef("far Crocs");
   rmAddObjectDefItem(farCrocsID, "bear", rmRandInt(1,2), 0.0);
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
      rmAddObjectDefItem(bonusHuntableID, "water buffalo", 2, 2.0);
   else if(bonusChance<0.75)
      rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(5,6), 3.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "water buffalo", rmRandInt(3,5), 3.0);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, closeForestConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidAll);
  
   // Bonus huntable 1
   int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID2, "water buffalo", 2, 2.0);
   else if(bonusChance<0.75)
      {
         rmAddObjectDefItem(bonusHuntableID2, "water buffalo", rmRandInt(5,6), 3.0);
         if(rmRandFloat(0,1)<0.5)      
            rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(2,4), 3.0);
      }
   else
      rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(6,9), 4.0);
   rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID2, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
//	rmAddObjectDefConstraint(bonusHuntableID2, playerConstraint);
   rmAddObjectDefConstraint(bonusHuntableID2, nearShore);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidAll);
	rmAddObjectDefConstraint(bonusHuntableID2, closeForestConstraint);

   // Bonus huntable 2
   int bonusHuntableID3=rmCreateObjectDef("bonus huntable3");
   bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID3, "boar", 3, 2.0);
   else if(bonusChance<0.75)
      {
         rmAddObjectDefItem(bonusHuntableID3, "deer", rmRandInt(4,6), 3.0);
         if(rmRandFloat(0,1)<0.5)      
            rmAddObjectDefItem(bonusHuntableID3, "boar", rmRandInt(2,3), 4.0);
      }
   else
      rmAddObjectDefItem(bonusHuntableID3, "water buffalo", 4, 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID3, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID3, rmXFractionToMeters(0.5));
   rmAddObjectDefToClass(bonusHuntableID3, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID3, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidAll);
	rmAddObjectDefConstraint(bonusHuntableID3, cliffConstraint);
	rmAddObjectDefConstraint(bonusHuntableID3, closeForestConstraint);
//	rmAddObjectDefConstraint(bonusHuntableID3, playerConstraint);

   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

   // Relics avoid TCs

   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 40.0);
   rmSetObjectDefMaxDistance(relicID, 80.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 30.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, centerConstraint);
	rmAddObjectDefConstraint(relicID, closeForestConstraint);

   


   // ===================================Done defining objects=============================================
	
   // ###################################### Create areas ###############################################


    rmPlacePlayersCircular(0.4, 0.45, rmDegreesToRadians(5.0));

   int centerID=rmCreateArea("center");
   rmSetAreaSize(centerID, 0.0005, 0.0005);
   rmSetAreaLocation(centerID, 0.5, 0.5);
		rmSetAreaMinBlobs(centerID, 6);
      rmSetAreaMaxBlobs(centerID, 8);
      rmSetAreaMinBlobDistance(centerID, 20.0);
      rmSetAreaMaxBlobDistance(centerID, 30.0);
      rmSetAreaCoherence(centerID, 0.1);
   rmAddAreaToClass(centerID, rmClassID("center"));
   rmBuildArea(centerID);

	int centerAreaConstraint=rmCreateAreaDistanceConstraint("stay away from lake", centerID, 70);


// RARE BONUS GOLD ISLAND

float goldChance=rmRandFloat(0, 1);
if(cNumberNonGaiaPlayers > 2)
   {
      if(goldChance < 0.60)   
         {
				int goldIslandID=rmCreateArea("gold island");
				rmSetAreaSize(goldIslandID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(400));
				rmSetAreaLocation(goldIslandID, 0.5, 0.5);
				rmSetAreaTerrainType(goldIslandID, "GrassDirt25");
				rmSetAreaBaseHeight(goldIslandID, 3.0);
				rmSetAreaSmoothDistance(goldIslandID, 10);
				rmSetAreaHeightBlend(goldIslandID, 2);
				rmSetAreaMinBlobs(goldIslandID, 3);
				rmSetAreaMaxBlobs(goldIslandID, 5);
				rmSetAreaMinBlobDistance(goldIslandID, 6.0);
				rmSetAreaMaxBlobDistance(goldIslandID, 10.0);
				rmSetAreaCoherence(goldIslandID, 0.5);
				rmBuildArea(goldIslandID);

				int superGoldID=rmCreateObjectDef("super gold");
				rmAddObjectDefItem(superGoldID, "gold mine", 5, 8.0);
				rmAddObjectDefItem(superGoldID, "bear", 2, 8.0);
				rmSetObjectDefMinDistance(superGoldID, 0.0);
				rmSetObjectDefMaxDistance(superGoldID, 3.0);
				rmAddObjectDefConstraint(superGoldID, tinyAvoidImpassableLand);
				rmPlaceObjectDefAtLoc(superGoldID, 0, 0.5, 0.5, 1);
			}
	}




    // Create player cores so bonus islands avoid them
    for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player core"+i);
      rmSetAreaSize(id, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
      rmAddAreaToClass(id, classPlayerCore);
      rmSetAreaCoherence(id, 1.0);
		rmSetAreaBaseHeight(id, 40.0);
      rmSetAreaLocPlayer(id, i);

      rmBuildArea(id);
   }

   // Create connections
   int shallowsID=rmCreateConnection("shallows");
   rmSetConnectionType(shallowsID, cConnectPlayers, false, 1.0);
   rmSetConnectionWidth(shallowsID, 28, 2);
   rmSetConnectionWarnFailure(shallowsID, false);
   rmSetConnectionBaseHeight(shallowsID, 2.0);
   rmSetConnectionHeightBlend(shallowsID, 2.0);
   rmSetConnectionSmoothDistance(shallowsID, 3.0);
	
	rmSetConnectionPositionVariance(shallowsID, 0.5);

	rmAddConnectionStartConstraint(shallowsID, centerAreaConstraint);
   rmAddConnectionEndConstraint(shallowsID, centerAreaConstraint);
	
	rmAddConnectionToClass(shallowsID, classShallows); 
	rmAddConnectionStartConstraint(shallowsID, edgeConstraint);
   rmAddConnectionEndConstraint(shallowsID, edgeConstraint);

   rmAddConnectionTerrainReplacement(shallowsID, "RiverGrassyA", "GrassDirt25"); /*riverSandyC */


  // Create extra connection for 2 player?

	int shallowsConstraint=rmCreateClassDistanceConstraint("stay away from shallows", classShallows, 80.0);
   
	if (cNumberNonGaiaPlayers < 3)
		{
		int teamShallowsID=rmCreateConnection("team shallows");
		rmSetConnectionType(teamShallowsID, cConnectPlayers, false, 1.0);
		rmSetConnectionWarnFailure(teamShallowsID, false);
		rmSetConnectionWidth(teamShallowsID, 26, 2);
		rmSetConnectionBaseHeight(teamShallowsID, 2.0);
		rmSetConnectionHeightBlend(teamShallowsID, 2.0);

		rmAddConnectionStartConstraint(teamShallowsID, edgeConstraint);
		rmAddConnectionEndConstraint(teamShallowsID, edgeConstraint);
		rmAddConnectionStartConstraint(teamShallowsID, shallowsConstraint);
		rmAddConnectionEndConstraint(teamShallowsID, shallowsConstraint);
		rmSetConnectionPositionVariance(shallowsID, -1);

		rmSetConnectionSmoothDistance(teamShallowsID, 3.0);
		rmAddConnectionTerrainReplacement(teamShallowsID, "RiverGrassyA", "GrassDirt25");

		}

// Build up some bonus islands.
   int bonusCount = rmRandInt(4, 5);

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(200);
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      id=rmCreateArea("Player"+i);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 0.5, 0.5);
      rmAddAreaToClass(id, classIsland);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaWarnFailure(id, false);
      rmSetAreaMinBlobs(id, 3);
      rmSetAreaMaxBlobs(id, 6);
      rmSetAreaMinBlobDistance(id, 7.0);
      rmSetAreaMaxBlobDistance(id, 12.0);
      rmSetAreaCoherence(id, 0.5);
      rmSetAreaBaseHeight(id, 6.0);
      rmSetAreaSmoothDistance(id, 10);
      rmSetAreaHeightBlend(id, 2);
      rmAddAreaConstraint(id, islandConstraint);
	   rmAddAreaConstraint(id, cornerOverlapConstraint);
			if (cNumberNonGaiaPlayers > 2)
				rmAddAreaConstraint(id, centerConstraint);
      rmSetAreaLocPlayer(id, i);
      rmAddConnectionArea(teamShallowsID, id);
      rmAddConnectionArea(shallowsID, id);
      rmSetAreaTerrainType(id, "GrassA");
		rmAddAreaTerrainLayer(id, "GrassDirt25", 4, 7);
      rmAddAreaTerrainLayer(id, "GrassDirt25", 2, 4);
		rmAddAreaTerrainLayer(id, "GrassDirt25", 0, 2);
   }

   // Build all areas
   rmBuildAllAreas();
   rmBuildConnection(teamShallowsID);
   rmBuildConnection(shallowsID);

	
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

	// Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 3);
   rmPlaceObjectDefPerPlayer(startingTower2ID, true, 1);

	// Home Settlement
   id=rmAddFairLoc("Settlement", false, true, 40, 100, 40, 16, true); /* bool forward bool inside */
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);
	rmAddFairLocConstraint(id, avoidSettlement);
	
	id=rmAddFairLoc("Settlement", true, false,  40, 100, 40, 16); 
   rmAddFairLocConstraint(id, shortAvoidImpassableLand);
	rmAddFairLocConstraint(id, avoidSettlement);
   
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



/// Marsh Forest.
   
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	int oakForestConstraint=rmCreateClassDistanceConstraint("oakforest v oakforest", rmClassID("forest"), 30.0);

   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=8*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(forestID, false);
/*      if(rmRandFloat(0,1)<0.8)
         rmSetAreaForestType(forestID, "savannah forest");
      else
         rmSetAreaForestType(forestID, "palm forest");
*/
		rmSetAreaForestType(forestID, "mixed oak forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
//		rmAddAreaConstraint(forestID, playerConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
      rmAddAreaToClass(forestID, classForest);
		rmSetAreaTerrainType(forestID, "MarshA");
      rmAddAreaTerrainLayer(forestID, "MarshB", 0, 2); 
      
      rmSetAreaMinBlobs(forestID, 2);
      rmSetAreaMaxBlobs(forestID, 4);
      rmSetAreaMinBlobDistance(forestID, 16.0);
      rmSetAreaMaxBlobDistance(forestID, 20.0);
      rmSetAreaCoherence(forestID, 0.0);

      // Hill trees?
//      if(rmRandFloat(0.0, 1.0)<0.2)
//         rmSetAreaBaseHeight(forestID, rmRandFloat(6.0, 9.0));
			rmSetAreaBaseHeight(forestID, 0);
			rmSetAreaSmoothDistance(forestID, 4);
			rmSetAreaHeightBlend(forestID, 2);

	
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


/// Player Forests.
   
   int playerForestCount=8*cNumberNonGaiaPlayers;
   int playerfailCount=0;
   for(i=0; <forestCount)
   {
      int playerForestID=rmCreateArea("playerForest"+i);
      rmSetAreaSize(playerForestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(160));
      rmSetAreaWarnFailure(playerForestID, false);
		rmSetAreaForestType(playerForestID, "mixed oak forest");
      rmAddAreaConstraint(playerForestID, forestSettleConstraint);
      rmAddAreaConstraint(playerForestID, forestObjConstraint);
      rmAddAreaConstraint(playerForestID, oakForestConstraint);
      rmAddAreaConstraint(playerForestID, avoidImpassableLand);
      rmAddAreaToClass(playerForestID, classForest);
      
      rmSetAreaMinBlobs(playerForestID, 2);
      rmSetAreaMaxBlobs(playerForestID, 4);
      rmSetAreaMinBlobDistance(playerForestID, 16.0);
      rmSetAreaMaxBlobDistance(playerForestID, 20.0);
      rmSetAreaCoherence(playerForestID, 0.0);

      // Hill trees?
      if(rmRandFloat(0.0, 1.0)<0.6)
         rmSetAreaBaseHeight(playerForestID, rmRandFloat(10.0, 12.0));
			rmSetAreaSmoothDistance(playerForestID, 14);
			rmSetAreaHeightBlend(playerForestID, 2);

      if(rmBuildArea(playerForestID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         playerfailCount++;
         if(playerfailCount==3)
            break;
      }
      else
         playerfailCount=0;
   }


   // Elev.
   failCount=0;
   int numTries1=20*cNumberNonGaiaPlayers;
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
   for(i=0; <numTries1)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false); 
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.7)
		{
         rmSetAreaTerrainType(elevID, "GrassDrit25");
			rmAddAreaTerrainLayer(elevID, "GrassDirt50", 0, 4); 
		}
      rmSetAreaBaseHeight(elevID, rmRandFloat(6.0, 10.0));
      rmSetAreaHeightBlend(elevID, 2);
		rmSetAreaSmoothDistance(elevID, 20);
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


	// Cliffage


	
   int numTries=3*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int cliffID=rmCreateArea("cliff"+i);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(180));
      rmSetAreaCliffType(cliffID, "Greek");
      rmAddAreaConstraint(cliffID, cliffConstraint);
      rmAddAreaToClass(cliffID, classCliff);
      rmAddAreaConstraint(cliffID, avoidBuildings);
		rmAddAreaConstraint(cliffID, farAvoidImpassableLand);
		rmAddAreaConstraint(cliffID, shortCoreBonusConstraint);
		rmAddAreaConstraint(cliffID, avoidAll);
      rmSetAreaMinBlobs(cliffID, 10);
      rmSetAreaMaxBlobs(cliffID, 10);
      rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
      rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaMinBlobDistance(cliffID, 16.0);
      rmSetAreaMaxBlobDistance(cliffID, 40.0);
      rmSetAreaCoherence(cliffID, 0.25);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaHeightBlend(cliffID, 2);
       
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



	for(i=1; <cNumberPlayers*40)
   {
        int id6=rmCreateArea("grass patch"+i);
        rmSetAreaSize(id6, rmAreaTilesToFraction(10), rmAreaTilesToFraction(40));
        rmSetAreaTerrainType(id6, "GrassB");
        rmSetAreaMinBlobs(id6, 1);
        rmSetAreaMaxBlobs(id6, 5);
        rmSetAreaMinBlobDistance(id6, 16.0);
        rmSetAreaMaxBlobDistance(id6, 40.0);
        rmSetAreaCoherence(id6, 0.0);
        rmAddAreaConstraint(id6, shortAvoidImpassableLand);
		  rmAddAreaConstraint(id6, closeForestConstraint);
        rmBuildArea(id6);
   } 

for(i=1; <cNumberPlayers*40)
   {
        int id7=rmCreateArea("dirt patch"+i);
        rmSetAreaSize(id7, rmAreaTilesToFraction(10), rmAreaTilesToFraction(50));
        rmSetAreaTerrainType(id7, "GrassDirt50");
		  rmAddAreaTerrainLayer(id7, "GrassDirt25", 0, 2); 
        rmSetAreaMinBlobs(id7, 1);
        rmSetAreaMaxBlobs(id7, 5);
        rmSetAreaMinBlobDistance(id7, 16.0);
        rmSetAreaMaxBlobDistance(id7, 40.0);
        rmSetAreaCoherence(id7, 0.0);
        rmAddAreaConstraint(id7, shortAvoidImpassableLand);
		  rmAddAreaConstraint(id7, closeForestConstraint);
        rmBuildArea(id7);
   } 

	
// PLACE STARTING TOWN AND RESOURCES

   // Straggler trees.

	int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
   rmAddObjectDefConstraint(stragglerTreeID, avoidImpassableLand);
 	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3, 7));
	


   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

	// Pigs
   rmPlaceObjectDefPerPlayer(closePigsID, true);

	// Gazelle
   rmPlaceObjectDefPerPlayer(closeGazelleID, false); 

// Medium things....
   // Gold
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(mediumGoldID, 0, rmAreaID("player"+i));

   // Pigs
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(mediumPigsID, 0, rmAreaID("player"+i));

// Far things.

   // Player Far Gold, need goldNum since it randomizes for each i
   int goldNum = rmRandInt(1,2);
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(farGoldID, false, rmAreaID("player"+i), goldNum);
  
  // Bonus Gold
//   rmPlaceObjectDefPerPlayer(bonusGoldID, false, rmRandInt(1,2));
	int goldNumB = rmRandInt(1,2);
	for(i=1; <cNumberPlayers)
		rmPlaceObjectDefInArea(bonusGoldID, false, rmAreaID("player"+i), goldNumB);

   // Relics.
/*   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefInArea(relicID, i, rmAreaID("player"+i));
*/
	
//	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers); 
	int relicNumB = rmRandInt(1,2);
	rmPlaceObjectDefPerPlayer(relicID, false, relicNumB);


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
      rmPlaceObjectDefInArea(bonusHuntableID2, false, rmAreaID("player"+i));
      rmPlaceObjectDefInArea(bonusHuntableID3, false, rmAreaID("player"+i));
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

	int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
//	rmAddObjectDefConstraint(randomTreeID, bonusIslandConstraint);

   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

  

int logID=rmCreateObjectDef("log");
//   rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
	rmAddObjectDefItem(logID, "bush", rmRandInt(0,1), 3.0);
	rmAddObjectDefItem(logID, "grass", rmRandInt(6,8), 6.0);
   rmSetObjectDefMinDistance(logID, 0.0);
   rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(logID, avoidAll);
   rmAddObjectDefConstraint(logID, avoidImpassableLand);
//   rmAddObjectDefConstraint(logID, shortCliffConstraint);
   rmAddObjectDefConstraint(logID, avoidBuildings);
   rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);


	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 25.0);
   int fishLand=rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);


	int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);


}
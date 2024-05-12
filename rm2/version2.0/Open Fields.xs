/*	Map Name: Open Fields.xs
**	Author: Milkman Matty
**	Made for Forgotten Empires.
*/

include "MmM_FE_lib.xs";

// Main entry point for random map script
void main(void){
	
	// Text
	rmSetStatusText("",0.01);
	
	// Set size.
	int playerTiles=7500;
	int mapSizeMultiplier = 1;
	if(cMapSize == 1){
		playerTiles = 9750;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 16000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Set up default water.
	rmSetSeaLevel(0.0);
	
	// Init map.
	string terrainBase = "PlainA"; //"GrassA";
	rmTerrainInitialize(terrainBase);
	rmSetGaiaCiv(cCivZeus);
	
	// Define some classes.
	int classPlayer = rmDefineClass("player");
	int classFarm = rmDefineClass("farm");
	rmDefineClass("classHill");
	rmDefineClass("starting settlement");
	
	// -------------Define constraints
	
	// Create a edge of map constraint.
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	
	// Player area constraint.
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
	int avoidFarm = rmCreateClassDistanceConstraint("farm vs farm", classFarm, 10+cNumberNonGaiaPlayers+(4*cMapSize));
	
	// Settlement constraint.
	int tinyAvoidSettlement=rmCreateTypeDistanceConstraint("objects tiny avoid TC", "AbstractSettlement", 12.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
	int hugeAvoidSettlement=rmCreateTypeDistanceConstraint("TC avoid TC by huge distance", "AbstractSettlement", 80.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	
	//Wood Contraint
	int avoidWood=rmCreateTypeDistanceConstraint("avoid wood", "Wood", 22.0);
	
	// Tower constraint.
	int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);
	int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 22.0);
	
	// Gold
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("gold vs. gold", "gold", 24.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far gold vs. gold", "gold", 40.0);
	
	// Herd animals
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0);
	
	// Avoid impassable land
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 8.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
	int tinyAvoidImpassableLand=rmCreateTerrainDistanceConstraint("tiny avoid impassable land", "land", false, 1.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	
	//Everything
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 3.0);
	
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
	
	// gold avoids gold
	//Starting Gold
	int startingGoldID=rmCreateObjectDef("starting gold");
	rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
	rmSetObjectDefMaxDistance(startingGoldID, 14.0);
	rmSetObjectDefMaxDistance(startingGoldID, 18.0);
	rmAddObjectDefConstraint(startingGoldID, rmCreateTypeDistanceConstraint("short goldy avoid TC", "AbstractSettlement", 8.0));

	int closeYakID=rmCreateObjectDef("close Yak");
	rmAddObjectDefItem(closeYakID, "Yak", rmRandInt(3,4), 2.0);
	rmSetObjectDefMinDistance(closeYakID, 20.0);
	rmSetObjectDefMaxDistance(closeYakID, 25.0);
	rmAddObjectDefConstraint(closeYakID, avoidFood);

	//Starting Berries
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 18.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid gold", "gold", 8.0));
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid TC", "AbstractSettlement", 8.0));

	//Starting Hunt
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "Deer", 3, 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 19.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 8.0));

	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "Bamboo Tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, avoidAll);
	
	// Medium Objects
	// gold avoids gold and Settlements
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 40.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	
	int mediumYakID=rmCreateObjectDef("medium Yak");
	rmAddObjectDefItem(mediumYakID, "Yak", rmRandFloat(2,3), 4.0);
	rmSetObjectDefMinDistance(mediumYakID, 40.0);
	rmSetObjectDefMaxDistance(mediumYakID, 60.0);
	rmAddObjectDefConstraint(mediumYakID, farStartingSettleConstraint);
	
	//Random farms in centre
	int farmiesID=rmCreateObjectDef("farmies");
	rmAddObjectDefItem(farmiesID, "farm", rmRandFloat(3,4), 10.0);
	rmAddObjectDefItem(farmiesID, "Bamboo Tree", 1, 0.0);
	rmSetObjectDefMinDistance(farmiesID, 0.0);
	rmSetObjectDefMaxDistance(farmiesID, 0.0);
	rmAddObjectDefToClass(farmiesID, classFarm);
	rmAddObjectDefConstraint(farmiesID, avoidFarm);
	rmAddObjectDefConstraint(farmiesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farmiesID, avoidWood);
	
	// Far Objects
	// gold avoids gold, Settlements and TCs
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 100.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	
	// pick wolves or bears as predators
	// avoid TCs and other animals
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.3){
		rmAddObjectDefItem(farPredatorID, "Tiger", rmRandInt(1,2), 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "Lizard", rmRandInt(2,3), 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 50.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 112", "gold", 50.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 112", "AbstractSettlement", 50.0));

	// This map will either use boar or deer as the extra huntable food.
	int classBonusHuntable=rmDefineClass("bonus huntable");
	int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
	
	// hunted avoids hunted and TCs
	int farHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance < 0.5){
		rmAddObjectDefItem(farHuntableID, "boar", 3, 4.0);
	} else {
		rmAddObjectDefItem(farHuntableID, "aurochs", rmRandInt(2,3), 4.0);
	}
	rmSetObjectDefMinDistance(farHuntableID, 0.0);
	rmSetObjectDefMaxDistance(farHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farHuntableID, avoidBonusHuntable);
	rmAddObjectDefConstraint(farHuntableID, avoidHuntable);
	rmAddObjectDefToClass(farHuntableID, classBonusHuntable);
	rmAddObjectDefConstraint(farHuntableID, farStartingSettleConstraint);
	
	int farYakID=rmCreateObjectDef("far Yak");
	rmAddObjectDefItem(farYakID, "Yak", rmRandFloat(3,4), 4.0);
	rmSetObjectDefMinDistance(farYakID, 80.0);
	rmSetObjectDefMaxDistance(farYakID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farYakID, farStartingSettleConstraint);
	
	//Gotta place these after farms
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "Bamboo Tree", 1, 0.0); //Jungle Tree , Bamboo Jungle Tree
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	
	// Birds
	int farHawkID=rmCreateObjectDef("far hawk");
	rmAddObjectDefItem(farHawkID, "Hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farHawkID, 0.0);
	rmSetObjectDefMaxDistance(farHawkID, rmXFractionToMeters(0.5));
	// -------------Done defining objects
	
	// Cheesy "circular" placement of players.
	rmSetTeamSpacingModifier(0.55);
	rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(5.0));
	
	
	// ------------- Define Terrain Types
	
	/* -- Old Terrain Types -- Use these for AoM Vanilla
	string terrainRoad = "greekRoadA";
	string terrainLush = "GrassB";
	
	string terrainLargeAreaEdge = "GrassA"; //terrainBase
	string terrainLargeAreaMid = "GrassDirt25";
	string terrainLargeAreaStart = "GrassDirt50";
	string terrainLargeAreaCentre = "GrassDirt75";
	
	string terrainBeauty = "DirtA";
	string waterType = "Greek River";
	string forestType = "Pine Forest";
	*/
	
	string terrainRoad = "greekRoadA";
	string terrainLush = "PlainB";
	
	string terrainLargeAreaEdge = terrainBase;
	string terrainLargeAreaMid = "PlainDirt25";
	string terrainLargeAreaStart = "PlainDirt50";
	string terrainLargeAreaCentre = "PlainDirt75";
	
	string terrainBeauty = "DirtB"; //"JungleDirt"; <--- Causes Crash?
	string waterType = "Yellow River";	//Currently not relevant but may be needed in further versions.
	string forestType = "Mixed Plain Forest";
	
	// ------------- Areas
	
	//Create large area that forests will avoid
	int centralFieldID=rmCreateArea("Centre Field");
	rmSetAreaSize(centralFieldID, 0.29, 0.29);
	rmSetAreaLocation(centralFieldID, 0.5, 0.5);
	rmSetAreaCoherence(centralFieldID, 0.5);
	rmSetAreaTerrainType(centralFieldID, terrainLush);
	
	
	// Set up player areas.
	float playerFraction=rmAreaTilesToFraction(4000);
	for(i=1; <cNumberPlayers){
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
		rmSetAreaTerrainType(id, terrainLargeAreaCentre);
		rmAddAreaTerrainLayer(id, terrainLargeAreaEdge, 0, 8);
		rmAddAreaTerrainLayer(id, terrainLargeAreaMid, 8, 16);
		rmAddAreaTerrainLayer(id, terrainLargeAreaStart, 16, 24);
	}
	
	// Build the areas.
	rmBuildAllAreas();
	
	for(i=1; <cNumberPlayers){
		// Beautification sub area.
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, terrainLargeAreaMid);
		rmSetAreaMinBlobs(id2, 1);
		rmSetAreaMaxBlobs(id2, 5);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0);
		rmSetAreaCoherence(id2, 0.0);
		
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier){
		// Beautification sub area.
		int id4=rmCreateArea("Grass patch 2 "+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16));
		rmSetAreaTerrainType(id4, terrainLush);
		rmSetAreaMinBlobs(id4, 1);
		rmSetAreaMaxBlobs(id4, 5);
		rmSetAreaWarnFailure(id4, false);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0);
		rmSetAreaCoherence(id4, 0.0);
		
		rmBuildArea(id4);
	}
	
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier){
		// Beautification sub area.
		int id5=rmCreateArea("Grass patch 3 "+i);
		rmSetAreaSize(id5, rmAreaTilesToFraction(25), rmAreaTilesToFraction(60));
		rmSetAreaTerrainType(id5, terrainBeauty);
		rmAddAreaTerrainLayer(id5, terrainLargeAreaStart, 0, 1);
		rmSetAreaWarnFailure(id5, false);
		rmSetAreaCoherence(id5, 0.0);
		
		rmBuildArea(id5);
	}
	
	// Text
	rmSetStatusText("",0.20);
	
	// Place starting settlements.
	// Close things....
	// TC
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	// Settlements.
	//Offensive or defensive placement on giant map?
	int settlementPlacement = -1;
	if(rmRandFloat(0,1) > 0.5){
		settlementPlacement = 0;
	} else {
		settlementPlacement = 1;
	}
	
	//Place offensive settlements first
	id=rmAddFairLoc("Settlement", true, false, rmXFractionToMeters(0.27), rmXFractionToMeters(0.28), 60, 20);
	rmAddFairLocConstraint(id, rmCreateAreaConstraint("FairLoc stay in centre", centralFieldID));
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, true, rmXFractionToMeters(0.32), rmXFractionToMeters(0.33), 60, 20);
	}
	
	//Offensive placement has farms
	if(rmPlaceFairLocs()){
		id=rmCreateObjectDef("offensive settlement");
		rmAddObjectDefItem(id, "Settlement", 1, 0.0);
		rmAddObjectDefItem(id, "farm", rmRandInt(3,4), 10.0);
		rmAddObjectDefConstraint(id, farAvoidSettlement);
		rmAddObjectDefConstraint(id, rmCreateAreaConstraint("stay in centre", centralFieldID));
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	//reset for defensive placement
	rmResetFairLocs();
	id=rmAddFairLoc("Settlement", false, false, rmXFractionToMeters(0.23), rmXFractionToMeters(0.24), 40, 20);
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", false, true, rmXFractionToMeters(0.32), rmXFractionToMeters(0.33), 60, 20);
	}
	
	//Defensive placement has no farms, but should be in forests anyway.
	if(rmPlaceFairLocs()){
		id=rmCreateObjectDef("defensive settlement");
		rmAddObjectDefItem(id, "Settlement", 1, 0.0);
		rmAddObjectDefConstraint(id, farAvoidSettlement);
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	// Text
	rmSetStatusText("",0.40);
	
	// Towers.
	rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);
	
	
	// Slight Elevation
	int numTries=30*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int failCount=0;
	for(i=0; <numTries){
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	// Elev.
	numTries=10*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <numTries){
		elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	// Straggler trees.
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));
	
	// Gold
	rmPlaceObjectDefPerPlayer(startingGoldID, false);
	
	// Yaks
	rmPlaceObjectDefPerPlayer(closeYakID, true);
	
	// berries	
	rmPlaceObjectDefPerPlayer(startingBerryID, false);
	
	// starting hunt
	rmPlaceObjectDefPerPlayer(startingHuntableID, false, 1);

	int relicID=rmCreateObjectDef("relics "+i);
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", rmXFractionToMeters(0.33)));
	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	// Medium things....
	// Gold
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, 1);
	
	// Herds.
	rmPlaceObjectDefPerPlayer(mediumYakID, false);
	rmPlaceObjectDefPerPlayer(farYakID, false);
	
	// Farms
	rmPlaceObjectDefInArea(farmiesID, 0, centralFieldID, rmRandInt(cNumberNonGaiaPlayers*2,cNumberNonGaiaPlayers*3));
	if(cMapSize == 2){
		if(cNumberNonGaiaPlayers == 2){
			rmPlaceObjectDefInArea(farmiesID, 0, centralFieldID, cNumberNonGaiaPlayers*8);
		} else {
			rmPlaceObjectDefInArea(farmiesID, 0, centralFieldID, cNumberNonGaiaPlayers*5);
		}
	}
	
	// Far things.
	// Gold.
	rmPlaceObjectDefPerPlayer(farGoldID, false, 1);
	
	// Bonus huntable.
	rmPlaceObjectDefPerPlayer(farHuntableID, false, 1);
	if(cMapSize == 2){
		rmSetObjectDefMinDistance(farGoldID, 0.0);
		rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.5));
		rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
		rmPlaceObjectDefAtLoc(farYakID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
		rmPlaceObjectDefAtLoc(farHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	// Predators
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	// Hawks
	rmPlaceObjectDefPerPlayer(farHawkID, false, 2);
	
	// Forest.
	int classForest=rmDefineClass("forest");
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 8.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 11.0);
	int forestCentreConstraint=rmCreateAreaDistanceConstraint("forest v Centre", centralFieldID, 1.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 30.0);
	int count=0;
	numTries=9*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(rmRandInt(160,180)), rmAreaTilesToFraction(rmRandInt(185,255)));
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, forestType);
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, tinyAvoidSettlement);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, forestCentreConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 8);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		// Hill trees?
		if(rmRandFloat(0.0, 1.0)<0.6){
			rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
		}
		
		if(rmBuildArea(forestID)==false){
			// Stop trying once we fail 8 times in a row.
			failCount++;
			if(failCount==8) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	// Text
	rmSetStatusText("",0.60);
	
	// Random trees
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 25*cNumberNonGaiaPlayers);
	
	
	// Text
	rmSetStatusText("",0.80);
	
	// Rocks
	int rockLargeID=rmCreateObjectDef("rock large");
	rmAddObjectDefItem(rockLargeID, "rock dirt big", 1, 0.0);
	rmSetObjectDefMinDistance(rockLargeID, 0.0);
	rmSetObjectDefMaxDistance(rockLargeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockLargeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockLargeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int rockSmallID=rmCreateObjectDef("rock small");
	rmAddObjectDefItem(rockSmallID, "rock dirt small", 1, 0.0);
	rmSetObjectDefMinDistance(rockSmallID, 0.0);
	rmSetObjectDefMaxDistance(rockSmallID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockSmallID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockSmallID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int rockSpriteID=rmCreateObjectDef("rock sprite");
	rmAddObjectDefItem(rockSpriteID, "rock dirt sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockSpriteID, 0.0);
	rmSetObjectDefMaxDistance(rockSpriteID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockSpriteID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockSpriteID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	// Logs
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidImpassableLand);
	rmAddObjectDefConstraint(logID, avoidBuildings);
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);
	
	// bush
	int bushID=rmCreateObjectDef("foliage");
	rmAddObjectDefItem(bushID, "bush", 1, 1.0);
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	//grass
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 1, 3.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 50*cNumberNonGaiaPlayers);
	
	// Text
	rmSetStatusText("",0.90);
	
	// Gaia needs to be able to have LOS before it can invoke a god power there
	int Revealer=rmCreateObjectDef("Gaia Middle Revealer");
    rmAddObjectDefItem(Revealer, "Revealer to Player", 1, 0.0);
    rmSetObjectDefMinDistance(Revealer, 0.0);
    rmSetObjectDefMaxDistance(Revealer, 0.0);
	rmPlaceObjectDefAtLoc(Revealer, 0, 0.5, 0.5, 1);
	
	//Triggers
	rmCreateTrigger("Periodic_Rain");
	rmSetTriggerPriority(3);
    rmSetTriggerActive(true);
    rmSetTriggerRunImmediately(false);
    rmSetTriggerLoop(true);
	rmAddTriggerCondition("Timer");
    rmSetTriggerConditionParamInt("Param1", 360); //Every 6 minutes
	rmAddTriggerEffect("Grant God Power");
    rmSetTriggerEffectParamInt("PlayerID",0);
	rmSetTriggerEffectParam("PowerName", "Rain");
    rmSetTriggerEffectParamInt("Count",1);
	
	string invokeString = "0.5,1,0.5";
	
	rmAddTriggerEffect("Invoke God Power");
	rmSetTriggerEffectParamInt("PlayerID", 0);
	rmSetTriggerEffectParam("PowerName", "Rain");
	rmSetTriggerEffectParam("DstPoint1", invokeString);
	rmSetTriggerEffectParam("DstPoint2", invokeString);
	
	
	// Text
	rmSetStatusText("",1.00);
	
}
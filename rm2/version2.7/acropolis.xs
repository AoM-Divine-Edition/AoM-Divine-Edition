/*	Map Name: Acropolis.xs
**	Fast-Paced Ruleset: Alfheim.xs
**	Author: Milkman Matty for Forgotten Empires.
**	Modified by hagrit due to bug fixing.
*/

//Include the library file.
include "MmM_FE_lib.xs";

// Main entry point for random map script
void main(void){
	
	/* **************************** */
	/* Section 1 Map Initialization */
	/* **************************** */
	
	// Create loading bar.
	rmSetStatusText("",0.01);
	
	int mapSizeMultiplier = 1;
	int playerTiles=8500;
	if(cMapSize == 1){
		playerTiles = 11050;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 22100;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Set up default water.
	rmSetSeaLevel(-8);
	
	// Init map.
	rmTerrainInitialize("GrassA");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	int classStartingSet=rmDefineClass("starting settlement");
	int classTower=rmDefineClass("starting towers");
	int classLake=rmDefineClass("lake");
	int classForest=rmDefineClass("forest");
	int classFirstForest=rmDefineClass("starting forest");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int lakeConstraint=rmCreateClassDistanceConstraint("avoid the center", classLake, 25.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	rmPlacePlayersSquare(0.3, 0.05, 0.05);
	rmRecordPlayerLocations();
	
	int lake = 1;
	if(rmRandFloat (0,1) < 0.5) {
		lake = 0;
	}
	rmEchoInfo ("lake="+lake);
	
	if(lake == 1){
		int centerLake=rmCreateArea("lake in the middle");
		rmSetAreaSize(centerLake, 0.03, 0.04);
		rmSetAreaLocation(centerLake, 0.5, 0.5);
		rmSetAreaWaterType(centerLake, "Greek River");
		rmSetAreaBaseHeight(centerLake, 0.0);
		rmSetAreaMinBlobs(centerLake, 5*mapSizeMultiplier);
		rmSetAreaMaxBlobs(centerLake, 7*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(centerLake, 16.0);
		rmSetAreaMaxBlobDistance(centerLake, 20.0*mapSizeMultiplier);
		rmSetAreaSmoothDistance(centerLake, 50);
		rmSetAreaCoherence(centerLake, 0.25);
		rmAddAreaToClass(centerLake, classLake);
		rmBuildArea(centerLake);
	}
	
	// Connections
	int classConnection=rmDefineClass("connection");
	int rampID=rmCreateConnection("ramps");
	rmSetConnectionType(rampID, cConnectAreas, false, 0.70);
	rmSetConnectionWidth(rampID, 12, 2);
	rmSetConnectionHeightBlend(rampID, 7.0);
	rmSetConnectionSmoothDistance(rampID, 3.0);
	rmAddConnectionTerrainReplacement(rampID, "cliffGreekA", "GrassA");
	rmAddConnectionTerrainReplacement(rampID, "cliffGreekB", "GrassA");
	rmAddConnectionToClass(rampID, classConnection);
	
	// Set up temp areas so we can build the connections.
	for(i=1; <cNumberPlayers){
		int tempID=rmCreateArea("TempPlayer"+i);
		rmSetAreaSize(tempID, 0.01, 0.01);
		rmAddConnectionArea(rampID, tempID);
		rmSetAreaLocPlayer(tempID, i);
		rmBuildArea(tempID);
		rmAddAreaConstraint(tempID, lakeConstraint);
		rmAddAreaConstraint(tempID, edgeConstraint);
		rmAddAreaConstraint(tempID, playerConstraint);
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	for(i=1; <cNumberPlayers){
		rmAddPlayerResource(i, "Food", 300);
		rmAddPlayerResource(i, "Wood", 200);
		rmAddPlayerResource(i, "Gold", 100);
	}
	
	// Set up player areas.
	float playerFraction=rmAreaTilesToFraction(2300*mapSizeMultiplier);
	for(i=1; <cNumberPlayers){
		// Create the area.
		int id=rmCreateArea("Player"+i);
		
		// Assign to the player.
		rmSetPlayerArea(i, id);
		
		// Set the size.
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		
		rmAddAreaToClass(id, classPlayer);
		
		rmSetAreaMinBlobs(id, 2);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaMinBlobDistance(id, 20.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(id, 30.0*mapSizeMultiplier);
		rmSetAreaCoherence(id, 0.7);
		rmSetAreaCliffType(id, "Greek");
		rmSetAreaCliffEdge(id, 2, 0.45, 0.2, 1.0, 1);
		rmSetAreaCliffPainting(id, false, true, true, 1.5, true);
		rmAddAreaConstraint(id, lakeConstraint);
		rmAddAreaConstraint(id, edgeConstraint);
		rmSetAreaCliffHeight(id, 7, 1.0, 0.5);
		rmSetAreaSmoothDistance(id, 20);
		//rmAddAreaConstraint(id, playerConstraint);
		rmSetAreaLocPlayer(id, i);
	}
	
	// Build the areas.
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	// Beautification sub area.
	int grassID =0;
	int patch = 0;
	int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", patch, 4.0);
	for(i=1; <cNumberPlayers*12*mapSizeMultiplier) {
		patch=rmCreateArea("patch"+i);
		rmSetAreaWarnFailure(patch, false);
		if(cNumberNonGaiaPlayers > 5) {
			rmSetAreaSize(patch, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(150*mapSizeMultiplier));
		} else {
			rmSetAreaSize(patch, rmAreaTilesToFraction(90*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		}
		rmSetAreaTerrainType(patch, "GrassDirt75");
		rmAddAreaTerrainLayer(patch, "GrassB", 1, 2);
		rmAddAreaTerrainLayer(patch, "GrassDirt25", 0, 1);
		rmSetAreaMinBlobs(patch, 2*mapSizeMultiplier);
		rmSetAreaMaxBlobs(patch, 2*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(patch, 5.0);
		rmSetAreaMaxBlobDistance(patch, 10.0*mapSizeMultiplier);
		rmSetAreaCoherence(patch, 0.0);
		rmAddAreaConstraint(patch, lakeConstraint);
		rmAddAreaConstraint(patch, avoidImpassableLand);
		rmBuildArea(patch);
		
		grassID=rmCreateObjectDef("grass"+i);
		rmAddObjectDefItem(grassID, "grass", rmRandFloat(2,4), 2.0);
		rmAddObjectDefItem(grassID, "rock limestone sprite", rmRandInt(0,2), 3.0);
		rmAddObjectDefItem(grassID, "flowers", rmRandInt(0,6), 5.0);
		rmAddObjectDefConstraint(grassID, stayInPatch);
		rmSetObjectDefMinDistance(grassID, 0.0);
		rmSetObjectDefMaxDistance(grassID, 0.0);
		rmAddAreaConstraint(grassID, avoidImpassableLand);
		rmPlaceObjectDefInArea(grassID, 0, rmAreaID("patch"+i), 1);
	}
	
	for(i=1; <cNumberPlayers*12*mapSizeMultiplier){
		// Beautification sub area.
		int patch2=rmCreateArea("patch dirt"+i);
		rmSetAreaWarnFailure(patch2, false);
		rmSetAreaSize(patch2, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaTerrainType(patch2, "GrassDirt50");
		rmAddAreaTerrainLayer(patch2, "GrassDirt25", 0, 3);
		rmSetAreaMinBlobs(patch2, 2*mapSizeMultiplier);
		rmSetAreaMaxBlobs(patch2, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(patch2, 16.0);
		rmSetAreaMaxBlobDistance(patch2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(patch2, 0.0);
		rmAddAreaConstraint(patch2, lakeConstraint);
		rmAddAreaConstraint(patch2, avoidImpassableLand);
		rmBuildArea(patch2);
	}
	
	for(i=1; <cNumberPlayers){
		// Beautification sub area.
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(400*mapSizeMultiplier));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, "GreekRoadA");
		rmAddAreaTerrainLayer(id2, "GrassDirt50", 0, 1);
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmAddAreaConstraint(id2, avoidImpassableLand);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 1.0);
		rmSetAreaSmoothDistance(id2, 20);
		
		rmBuildArea(id2);
	}
	
	// Slight Elevation
	int elevPlayerConstraint = rmCreateClassDistanceConstraint("elev stay away from players", classPlayer, 8);
	int numTries=30*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries*mapSizeMultiplier){
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(30*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
		rmSetAreaTerrainType(elevID, "GrassDirt50");
		rmAddAreaTerrainLayer(elevID, "GrassDirt25", 0, 1);
		rmSetAreaMinBlobs(elevID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(elevID, 3*mapSizeMultiplier);
		rmSetAreaHeightBlend(elevID, 1.0);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, elevPlayerConstraint);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int stayInCenter= 0;
	if(cNumberNonGaiaPlayers < 4) {
		rmCreateBoxConstraint("far avoid edge of map", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30));
	} else {
		rmCreateBoxConstraint("medium avoid edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));
	}
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int medAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 40.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 60.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 15.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 6.0);
	int shortPlayerConstraint=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 4.0);
	int forestAvoidForest = rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 35.0);
	
	rmSetStatusText("",0.46);
	
	
	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */
	
	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.5){
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 15, 21, 0, 15);
	} else {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 15, 21, 0, 15);
	}
	if(rmPlaceFairLocs()){
		int startingGoldID=rmCreateObjectDef("Starting Gold");
		rmAddObjectDefItem(startingGoldID, "Gold Mine", 1, 0.0);
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i)){
				rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
			}
		}
	}
	rmResetFairLocs();
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, classStartingSet);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int closeID = -1;
	int farID = -1;
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 60.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSet, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 30.0);
	
	id=rmAddFairLoc("Settlement", false, true,  60, 80, 75, 25);
	rmAddFairLocConstraint(id, TCavoidSettlement);
	rmAddFairLocConstraint(id, TCavoidImpassableLand);
	rmAddFairLocConstraint(id, TCavoidStart);
	
	if(rmPlaceFairLocs()) {
		for(p = 1; <= cNumberNonGaiaPlayers){
		id=rmCreateObjectDef("close settlement"+p);
		rmAddObjectDefItem(id, "Settlement", 1, 0.0);
		rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
		int settleArea = rmCreateArea("settlement area"+p);
		rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
		rmSetAreaSize(settleArea, 0.01, 0.01);
		rmSetAreaTerrainType(settleArea, "GrassDirt75");
		rmAddAreaTerrainLayer(settleArea, "GrassDirt50", 2, 5);
		rmAddAreaTerrainLayer(settleArea, "GrassDirt25", 0, 2);
		rmAddAreaConstraint(settleArea, shortPlayerConstraint);
		rmBuildArea(settleArea);
		}
	} else {
		for(p = 1; <= cNumberNonGaiaPlayers){
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
			rmAddObjectDefConstraint(closeID, avoidImpassableLand);
			for(attempt = 6; <= 12){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 10*attempt);
			}
		}
	}
	rmResetFairLocs();

	id=rmAddFairLoc("Settlement", true, false,  80*mapSizeMultiplier, 100*mapSizeMultiplier, 65, 20);
	rmAddFairLocConstraint(id, TCavoidSettlement);
	rmAddFairLocConstraint(id, TCavoidImpassableLand);
	rmAddFairLocConstraint(id, TCavoidWater);
	rmAddFairLocConstraint(id, TCavoidStart);
	
	if(rmPlaceFairLocs()) {
		for(p = 1; <= cNumberNonGaiaPlayers){
			id=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
			int settlementArea = rmCreateArea("settlement_area_"+p);
			rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea, "GrassDirt75");
			rmAddAreaTerrainLayer(settlementArea, "GrassDirt50", 2, 5);
			rmAddAreaTerrainLayer(settlementArea, "GrassB", 0, 2);
			rmAddAreaConstraint(settlementArea, shortPlayerConstraint);
	
			rmBuildArea(settlementArea);
		}
	} else {
		farID=rmCreateObjectDef("far settlement"+p);
		rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
		rmAddObjectDefConstraint(farID, TCavoidWater);
		rmAddObjectDefConstraint(farID, TCavoidStart);
		rmAddObjectDefConstraint(farID, TCavoidSettlement);
		rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
		for(attempt = 5; <= 10){
			rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			if(rmGetNumberUnitsPlaced(farID) > 0){
				break;
			}
			rmSetObjectDefMaxDistance(farID, 15*attempt);
		}
	}
	rmResetFairLocs();
		
	if(cMapSize == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			farID=rmCreateObjectDef("giant settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			for(attempt = 5; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 20*attempt);
			}
			
			farID=rmCreateObjectDef("giant2 settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			for(attempt = 5; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 25*attempt);
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 8.0);
	for(i=1; <cNumberPlayers){
		int startingTowerID=rmCreateObjectDef("Starting tower"+i);
		int towerRampConstraint=rmCreateCliffRampConstraint("onCliffRamp"+i, rmAreaID("player"+i));
		int towerRampEdgeConstraint=rmCreateCliffEdgeMaxDistanceConstraint("nearCliffEdge"+i, rmAreaID("player"+i), 2);
		rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
		rmAddObjectDefConstraint(startingTowerID, avoidTower);
		rmAddObjectDefConstraint(startingTowerID, towerRampConstraint);
		rmAddObjectDefConstraint(startingTowerID, towerRampEdgeConstraint);
		rmAddObjectDefToClass(startingTowerID, classTower);
		rmPlaceObjectDefInArea(startingTowerID, i, rmAreaID("player"+i), 6);
		
		/* backup to try again */
		if(rmGetNumberUnitsPlaced(startingTowerID) < 4){
			int startingTowerID2=rmCreateObjectDef("Less Optimal starting tower"+i);
			rmAddObjectDefItem(startingTowerID2, "tower", 1, 0.0);
			rmAddObjectDefConstraint(startingTowerID2, avoidTower);
			rmAddObjectDefConstraint(startingTowerID2, towerRampConstraint);
			rmAddObjectDefToClass(startingTowerID2, classTower);
			rmPlaceObjectDefInArea(startingTowerID2, i, rmAreaID("player"+i), 1);
			
		}
	}
	
	int shortAvoidFood=rmCreateTypeDistanceConstraint("short avoid other food sources", "food", 6.0);
	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(7,9), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 21.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, true, 1);
	
	//Redundant since these are placed before the starting forest is.
	int firstForestConstraint=rmCreateClassDistanceConstraint("resources v forest", rmClassID("starting forest"), 5.0);
	
	int closeGoatsID=rmCreateObjectDef("close goats");
	rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
	rmSetObjectDefMinDistance(closeGoatsID, 20.0);
	rmSetObjectDefMaxDistance(closeGoatsID, 27.0);
	rmAddObjectDefConstraint(closeGoatsID, shortAvoidFood);
	rmAddObjectDefConstraint(closeGoatsID, firstForestConstraint);
	rmAddObjectDefConstraint(closeGoatsID, rmCreateTypeDistanceConstraint("short avoid gold", "gold", 8.0));
	rmAddObjectDefConstraint(closeGoatsID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(closeGoatsID, true, rmRandInt(2,3));
	
	int statueID=rmCreateObjectDef("statue");
	rmAddObjectDefItem(statueID, "statue of major god", 1, 1.0);
	rmSetObjectDefMinDistance(statueID, 20.0);
	rmSetObjectDefMaxDistance(statueID, 28.0);
	rmAddObjectDefConstraint(statueID, avoidImpassableLand);
	rmAddObjectDefConstraint(statueID, firstForestConstraint);
	rmAddObjectDefConstraint(statueID, rmCreateTypeDistanceConstraint("statues avoid TC", "AbstractSettlement", 6.0));
	for(i=1; < cNumberPlayers){
		rmPlaceObjectDefInArea(statueID, i, rmAreaID("Player inner"+i), 1*mapSizeMultiplier);
	}
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid everything", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestAvoidTower = rmCreateTypeDistanceConstraint("forest avoid tower", "tower", 20.0);
	
	for(i=1; <cNumberPlayers){
		int playerForestID=rmCreateArea("playerForest"+i, rmAreaID("player"+i));
		rmSetAreaSize(playerForestID, rmAreaTilesToFraction(60), rmAreaTilesToFraction(60));
		if(cMapSize == 2){
			rmSetAreaSize(playerForestID, rmAreaTilesToFraction(160), rmAreaTilesToFraction(200));
		}
		
		if(rmRandFloat(0.0, 1.0)<0.7) {
			rmSetAreaForestType(playerForestID, "oak forest");
		} else {
			rmSetAreaForestType(playerForestID, "autumn oak forest");
		}
		rmAddAreaConstraint(playerForestID, shortAvoidImpassableLand);
		rmAddAreaConstraint(playerForestID, avoidBuildings);
		rmAddAreaConstraint(playerForestID, forestAvoidTower);
		rmAddAreaToClass(playerForestID, classForest);
		rmAddAreaToClass(playerForestID, classFirstForest);
		rmSetAreaWarnFailure(playerForestID, false);
		rmSetAreaMinBlobs(playerForestID, 2);
		rmSetAreaMaxBlobs(playerForestID, 2);
		rmSetAreaMinBlobDistance(playerForestID, 10.0);
		rmSetAreaMaxBlobDistance(playerForestID, 15.0);
		rmSetAreaCoherence(playerForestID, 0.0);
		
		rmBuildArea(playerForestID);
	}
	
	if (cMapSize == 2) {
		for(i=1; <cNumberPlayers){
		int playerForest2ID=rmCreateArea("playerForest2"+i, rmAreaID("player"+i));
			rmSetAreaSize(playerForest2ID, rmAreaTilesToFraction(140), rmAreaTilesToFraction(200));
		
		if(rmRandFloat(0.0, 1.0)<0.75) {
			rmSetAreaForestType(playerForest2ID, "oak forest");
		} else {
			rmSetAreaForestType(playerForest2ID, "autumn oak forest");
		}
		rmAddAreaConstraint(playerForest2ID, shortAvoidImpassableLand);
		rmAddAreaConstraint(playerForest2ID, avoidBuildings);
		rmAddAreaConstraint(playerForest2ID, forestAvoidTower);
		rmAddAreaConstraint(playerForest2ID, forestAvoidForest);
		rmAddAreaToClass(playerForest2ID, classForest);
		rmAddAreaToClass(playerForest2ID, classFirstForest);
		rmSetAreaWarnFailure(playerForest2ID, false);
		rmSetAreaMinBlobs(playerForest2ID, 2);
		rmSetAreaMaxBlobs(playerForest2ID, 2);
		rmSetAreaMinBlobDistance(playerForest2ID, 10.0);
		rmSetAreaMaxBlobDistance(playerForest2ID, 15.0);
		rmSetAreaCoherence(playerForest2ID, 0.0);
		
		rmBuildArea(playerForest2ID);
		}
	}
	
	rmSetStatusText("",0.66);
	
	/* ************************* */
	/* Section 11 Medium Objects */
	/* ************************* */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 55.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmAddObjectDefConstraint(mediumGoldID, medAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortPlayerConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", 2, 1.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, avoidGold);
	rmAddObjectDefConstraint(mediumGoatsID, shortPlayerConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoatsID, stayInCenter);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false, rmRandInt(1,2));
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 105.0);
	rmAddObjectDefConstraint(farGoldID, medAvoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, playerConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, stayInCenter);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1, 2));
	
	int avoidHuntable = rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	
	int farHuntableID=rmCreateObjectDef("far huntable");
	rmAddObjectDefItem(farHuntableID, "deer", rmRandInt(6,8), 4.0);
	rmSetObjectDefMinDistance(farHuntableID, 55.0);
	rmSetObjectDefMaxDistance(farHuntableID, 75.0);
	rmAddObjectDefConstraint(farHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(farHuntableID, avoidFood);
	rmAddObjectDefConstraint(farHuntableID, medAvoidGold);
	rmAddObjectDefConstraint(farHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farHuntableID, playerConstraint);
	rmAddObjectDefConstraint(farHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(farHuntableID, stayInCenter);
	rmPlaceObjectDefPerPlayer(farHuntableID, false, 1);
	
	if(rmRandFloat(0,1) < 0.5){
		int bonusHuntableID=rmCreateObjectDef("bonus huntable");
		rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(4,5), 4.0);
		rmSetObjectDefMinDistance(bonusHuntableID, 75.0);
		rmSetObjectDefMaxDistance(bonusHuntableID, 80.0);
		rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
		rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
		rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(bonusHuntableID, playerConstraint);
		rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(bonusHuntableID, stayInCenter);
		rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 1);
	}
	
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", 1, 0.0);
	rmSetObjectDefMinDistance(farGoatsID, 75.0);
	rmSetObjectDefMaxDistance(farGoatsID, 110.0);
	rmAddObjectDefConstraint(farGoatsID, playerConstraint);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoatsID, stayInCenter);
	rmAddObjectDefConstraint(farGoatsID, avoidGold);
	rmAddObjectDefConstraint(farGoatsID, avoidFood);
	rmPlaceObjectDefAtLoc(farGoatsID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*rmRandInt(2, 4));
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 80.0);
	rmSetObjectDefMaxDistance(farBerriesID, 125.0);
	rmAddObjectDefConstraint(farBerriesID, playerConstraint);
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, rmCreateTypeDistanceConstraint("avoid berries", "berry bush", 40.0));
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, avoidFood);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, stayInCenter);
	rmPlaceObjectDefPerPlayer(farBerriesID, false, 2);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmAddObjectDefConstraint(relicID, playerConstraint);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(relicID, false, 1);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.10);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 8.0);
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 1, 0.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	if(lake == 1) {
		rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, rmRandInt(1,4));
	}
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantCloseGoldID=rmCreateObjectDef("giant close gold");
		rmAddObjectDefItem(giantCloseGoldID, "gold mine", 1, 0.0);
		rmSetObjectDefMinDistance(giantCloseGoldID, 30);
		rmSetObjectDefMaxDistance(giantCloseGoldID, 50);
		rmAddObjectDefConstraint(giantCloseGoldID, avoidGold);
		rmAddObjectDefConstraint(giantCloseGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantCloseGoldID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantCloseGoldID, avoidTower);
	//rmPlaceObjectDefInArea(giantCloseGoldID, false, 1);
		for (i=1; <cNumberPlayers) {
			rmPlaceObjectDefInArea(giantCloseGoldID, 0, rmAreaID("Player"+i), 1);
		}
		
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, 100);
		rmSetObjectDefMaxDistance(giantGoldID, 200);
		rmAddObjectDefConstraint(giantGoldID, avoidGold);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, playerConstraint);
		rmAddObjectDefConstraint(giantGoldID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantGoldID, stayInCenter);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(2, 3));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(5,9), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, medAvoidGold);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, playerConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, stayInCenter);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,3), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, playerConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, stayInCenter);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(2, 3));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int count=0;
	numTries=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	int avoidAllForest = rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
	
	failCount=0;
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0.0, 1.0)<0.7) {
			rmSetAreaForestType(forestID, "oak forest");
		} else {
			rmSetAreaForestType(forestID, "autumn oak forest");
		}
		rmAddAreaConstraint(forestID, avoidAllForest);
		rmAddAreaConstraint(forestID, forestAvoidForest);
		rmAddAreaConstraint(forestID, playerConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaConstraint(forestID, shortAvoidSettlement);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 20.0);
		rmSetAreaMaxBlobDistance(forestID, 20.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		// Hill trees?
		if(rmRandFloat(0.0, 1.0)<0.3)
		rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
		
		if(rmBuildArea(forestID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	rmSetStatusText("",0.93);
	
	
	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 50*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rock2ID=rmCreateObjectDef("rock2");
	rmAddObjectDefItem(rock2ID, "rock limestone small", 1, 1.0);
	rmAddObjectDefItem(rock2ID, "rock limestone sprite", 3, 3.0);
	rmSetObjectDefMinDistance(rock2ID, 0.0);
	rmSetObjectDefMaxDistance(rock2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rock2ID, avoidAll);
	rmAddObjectDefConstraint(rock2ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rock2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int decorationID=rmCreateObjectDef("water decoration");
	rmAddObjectDefItem(decorationID, "water decoration", 3, 5.0);
	rmSetObjectDefMinDistance(decorationID, 0.0);
	rmSetObjectDefMaxDistance(decorationID, rmXFractionToMeters(0.5));
	if(lake==1) {
		rmPlaceObjectDefAtLoc(decorationID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);
	}

	
	rmSetStatusText("",1.0);
}
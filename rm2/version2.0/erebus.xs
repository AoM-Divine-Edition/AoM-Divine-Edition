/*	Map Name: Erebus.xs
**	Fast-Paced Ruleset: Tundra.xs
**	Author: Milkman Matty for Forgotten Empires.
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
	int playerTiles=7500;
	if(cMapSize == 1){
		playerTiles = 9750;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 15000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Init map
	rmSetSeaType("styx river");
	int styx = 0;
	if(rmRandFloat(0,1) < 0.33) {
		styx = 1;
		rmSetSeaLevel(5);
		rmTerrainInitialize("water");
	} else {
		rmTerrainInitialize("HadesCliff");
		rmSetSeaLevel(-2);
	}
	rmSetLightingSet("erebus");
	rmSetGaiaCiv(cCivHades);
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest=rmDefineClass("forest");
	int classPlayer = rmDefineClass("player");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int pathableClass=rmDefineClass("pathableClass");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 8.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", classStartingSettlement, 50.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int shallowsID=rmCreateConnection("shallows");
	if(cNumberNonGaiaPlayers < 6) {
		rmSetConnectionType(shallowsID, cConnectPlayers, true, 1.0);
	} else {
		rmSetConnectionType(shallowsID, cConnectPlayers, false, 1.0);
	}
	rmSetConnectionWidth(shallowsID, 20, 2);
	rmSetConnectionBaseHeight(shallowsID, 7.0);
	rmAddConnectionToClass(shallowsID, pathableClass);
	rmSetConnectionSmoothDistance(shallowsID, 3.0);
	rmAddConnectionTerrainReplacement(shallowsID, "Black", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(shallowsID, "Hades3", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(shallowsID, "Hades4", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(shallowsID, "Hades5", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(shallowsID, "Hades7", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(shallowsID, "HadesCliff", "Hadesbuildable1");
	rmSetConnectionTerrainCost(shallowsID, "Hades3", 10);
	rmSetConnectionTerrainCost(shallowsID, "Hades4", 10);
	rmSetConnectionTerrainCost(shallowsID, "Hades5", 10);
	rmSetConnectionTerrainCost(shallowsID, "Hades7", 10);
	
	int extraShallowsID=rmCreateConnection("extra shallows for small maps");
	if(cNumberNonGaiaPlayers < 4) {
		rmSetConnectionType(extraShallowsID, cConnectAreas, true, 1.0);
	} else {
		rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.75);
	}
	rmSetConnectionWidth(extraShallowsID, 20, 2);
	rmSetConnectionBaseHeight(extraShallowsID, 7.0);
	rmAddConnectionToClass(extraShallowsID, pathableClass);
	rmSetConnectionSmoothDistance(extraShallowsID, 3.0);
	rmSetConnectionPositionVariance(extraShallowsID, -1.0);
	rmAddConnectionTerrainReplacement(extraShallowsID, "Black", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(extraShallowsID, "Hades3", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(extraShallowsID, "Hades4", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(extraShallowsID, "Hades5", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(extraShallowsID, "Hades7", "Hadesbuildable1");
	rmAddConnectionTerrainReplacement(extraShallowsID, "HadesCliff", "Hadesbuildable1");
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	// Cheesy "circular" placement of players.
	if(cNumberNonGaiaPlayers > 8) {
		rmPlacePlayersCircular(0.35, 0.45, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
	
	float playerFraction=rmAreaTilesToFraction(9000);
	for(i=1; <cNumberPlayers){
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmAddAreaToClass(id, pathableClass);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 3);
		rmSetAreaMinBlobDistance(id, 20.0);
		rmSetAreaMaxBlobDistance(id, 20.0);
		rmSetAreaCoherence(id, 0.0);
		rmSetAreaBaseHeight(id, 7.0);
		rmAddAreaConstraint(id, playerConstraint);
		rmAddConnectionArea(extraShallowsID, id);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "Hadesbuildable1");
		if(styx == 0) {
			rmAddAreaTerrainLayer(id, "HadesCliff", 0, 2);
		}
		rmSetAreaTerrainLayerVariance(id, false);
	}
	
	// Build the areas.
	rmBuildAllAreas();
	rmBuildConnection(shallowsID);
	rmBuildConnection(extraShallowsID);
	
	for(i=1; <cNumberPlayers){
		id=rmCreateArea("cliff avoider"+i, rmAreaID("Player"+i));
		rmSetAreaSize(id, 0.01, 0.01);
		rmAddAreaToClass(id, classStartingSettlement);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaLocPlayer(id, i);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int failCount = 0;
	int patchAvoidLand = rmCreateTerrainDistanceConstraint("avoid passable land", "land", true, 6.0);
	for(j=0; <cNumberNonGaiaPlayers*20*mapSizeMultiplier){
		int lavaPatch=rmCreateArea("patch"+j);
		rmSetAreaSize(lavaPatch, rmAreaTilesToFraction(25*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaWarnFailure(lavaPatch, false);
		if(rmRandFloat(0,1)<0.25){
			rmSetAreaTerrainType(lavaPatch, "Hades4");
			rmAddAreaTerrainLayer(lavaPatch, "Hades3", 0, 1);
		} else {
			rmSetAreaTerrainType(lavaPatch, "Hades7");
			rmAddAreaTerrainLayer(lavaPatch, "Hades5", 0, 1);
		}
		rmSetAreaMinBlobs(lavaPatch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(lavaPatch, 5*mapSizeMultiplier);
		rmAddAreaConstraint(lavaPatch, patchAvoidLand);
		rmSetAreaMinBlobDistance(lavaPatch, 16.0);
		rmSetAreaMaxBlobDistance(lavaPatch, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(lavaPatch, 0.0);
		if(styx == 0) {
			if(rmBuildArea(lavaPatch)==false) {
				// Stop trying once we fail 3 times in a row.
				failCount++;
				if(failCount==3) {
					break;
				}
			} else {
				failCount=0;
			}
		}
	}

	for(i=1; <cNumberPlayers){
		for(j=0; <(rmRandInt(2, 8))*mapSizeMultiplier){
			int id2=rmCreateArea("random"+i +j,rmAreaID("player"+i));
			rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
			rmSetAreaTerrainType(id2, "Hadesbuildable2");
			rmSetAreaWarnFailure(id2, false);
			rmAddAreaConstraint(id2, avoidImpassableLand);
			rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
			rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
			rmSetAreaMinBlobDistance(id2, 16.0);
			rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
			rmSetAreaCoherence(id2, 0.3);
			rmBuildArea(id2);
		}
	}
	
	failCount=0;
	for(j=1; <cNumberPlayers) {
		for(i=0; <5) {
			int elevID=rmCreateArea("wrinkle"+i +j, rmAreaID("player"+j));
			rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
			rmSetAreaWarnFailure(elevID, false);
			rmSetAreaBaseHeight(elevID, rmRandFloat(8.0, 10.0));
			rmAddAreaConstraint(elevID, avoidBuildings);
			rmSetAreaMinBlobs(elevID, 1);
			rmSetAreaMaxBlobs(elevID, 3);
			rmSetAreaMinBlobDistance(elevID, 16.0);
			rmSetAreaMaxBlobDistance(elevID, 20.0);
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
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 35.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
	int avoidHuntable = rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	rmSetStatusText("",0.46);
	
	
	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */
	
	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.5){
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 21, 0, 15);
	} else {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 20, 21, 0, 15);
	}
	if(rmPlaceFairLocs()){
		int startingGoldID=rmCreateObjectDef("Starting Gold");
		rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i)){
				rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
			}
		}
	}
	rmResetFairLocs();
	
	int closeID = -1;
	int farID = -1;
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 5.0);
	rmAddObjectDefConstraint(startingSettlementID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 40, 16, true);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidStart);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "Hadesbuildable2");
				rmAddAreaTerrainLayer(settleArea, "Hadesbuildable1", 0, 4);
				rmBuildArea(settleArea);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.27), rmXFractionToMeters(0.35), 30, 16);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidStart);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "Hadesbuildable2");
				rmAddAreaTerrainLayer(settlementArea, "Hadesbuildable1", 0, 8);
				rmBuildArea(settlementArea);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
			for(attempt = 2; < 10){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 10*attempt);
			}
		
			farID=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			for(attempt = 4; < 15){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 12*attempt);
			}
		}
	} rmResetFairLocs();
		
	if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", false, true,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.4), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.35), rmXFractionToMeters(0.4), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				for(FL = 0; < 2){
					id=rmCreateObjectDef("Giant settlement_"+p+"_"+FL);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.005, 0.005);
					rmSetAreaTerrainType(settlementArea2, "Hadesbuildable2");
					rmAddAreaTerrainLayer(settlementArea2, "Hadesbuildable1", 0, 2);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
					
				farID=rmCreateObjectDef("giant settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 4; < 9){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 14*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 5; < 12){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 14*attempt);
				}
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "boar", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 20.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine dead", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid everything", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 4;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "hades forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.25);
			rmBuildArea(playerStartingForestID);
		}
	}
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 20.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 21.0);
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("towerfood", "food", 8.0));
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, huntShortAvoidsStartingGoldMilky);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 24;
		while( rmGetNumberUnitsPlaced(startingTowerID) < (4*p) ){
			rmPlaceObjectDefAtLoc(startingTowerID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			placement++;
			if(placement % 2 == 0){
				increment++;
				rmSetObjectDefMaxDistance(startingTowerID, increment);
			}
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
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));
	
	int mediumBoarID=rmCreateObjectDef("medium boar");
	rmAddObjectDefItem(mediumBoarID, "boar", rmRandInt(2, 4), 4.0);
	rmSetObjectDefMinDistance(mediumBoarID, 50.0);
	rmSetObjectDefMaxDistance(mediumBoarID, 70.0);
	rmAddObjectDefConstraint(mediumBoarID, avoidGold);
	rmAddObjectDefConstraint(mediumBoarID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumBoarID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumBoarID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumBoarID, false, 2);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 100.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, avoidHuntable);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("player"+i), rmRandInt(3, 4));
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(3,6), 4.0);
	rmSetObjectDefMinDistance(bonusHuntableID, 80.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 100.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i), rmRandInt(1, 2));
	}
	
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 25.0);
	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "serpent", 4, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "serpent", 2, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 75.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 96", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 96", "AbstractSettlement", 40.0));
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("player"+i), 1);
	}
	
	int farPredator2ID=rmCreateObjectDef("far 2 predator");
	predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredator2ID, "shade of erebus", 4, 4.0);
	} else {
		rmAddObjectDefItem(farPredator2ID, "shade of erebus", 2, 4.0);
	}
	rmSetObjectDefMinDistance(farPredator2ID, 80.0);
	rmSetObjectDefMaxDistance(farPredator2ID, 110.0);
	rmAddObjectDefConstraint(farPredator2ID, avoidPredator);
	rmAddObjectDefConstraint(farPredator2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredator2ID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredator2ID, avoidFood);
	rmAddObjectDefConstraint(farPredator2ID, rmCreateTypeDistanceConstraint("preds avoid gold 109", "gold", 40.0));
	rmAddObjectDefConstraint(farPredator2ID, rmCreateTypeDistanceConstraint("preds avoid settlements 109", "AbstractSettlement", 40.0));
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefInArea(farPredator2ID, 0, rmAreaID("player"+i), 1);
	}
	
	// Relics avoid TCs
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 60.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8)));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, avoidGold);
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i), 2);
	}
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "pine dead", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 40*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("giant avoid gold", "gold", 60.0));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("giant avoid settlements", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(4, 6));
		
		int gaintAvoidHuntable = rmCreateTypeDistanceConstraint("giant avoid huntable", "huntable", 50.0);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "Boar", rmRandInt(3,4), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, gaintAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(4, 6));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, 2.5*cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int classCliff=rmDefineClass("cliff");
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 20.0);
	int shortCliffConstraint=rmCreateClassDistanceConstraint("stuff v cliff", rmClassID("cliff"), 10.0);
	int cliffAvoidGold = rmCreateTypeDistanceConstraint("cliff v gold", "gold", 4.0);
	failCount=0;
	
	for(j=1; <cNumberPlayers) {
		for(i=0; <3) {
			int cliffID=rmCreateArea("cliff"+i +j, rmAreaID("player"+j));
			rmSetAreaWarnFailure(cliffID, false);
			rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
			rmSetAreaCliffType(cliffID, "Hades");
			rmAddAreaConstraint(cliffID, cliffConstraint);
			rmAddAreaConstraint(cliffID, avoidImpassableLand);
			rmAddAreaToClass(cliffID, classCliff);
			rmAddAreaConstraint(cliffID, cliffAvoidGold);
			rmAddAreaConstraint(cliffID, avoidBuildings);
			rmAddAreaConstraint(cliffID, farStartingSettleConstraint);
			rmAddAreaConstraint(cliffID, shortAvoidSettlement);
			rmSetAreaMinBlobs(cliffID, 10);
			rmSetAreaMaxBlobs(cliffID, 10);
			rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
			rmSetAreaCliffHeight(cliffID, 9, 1.0, 1.0);
			rmSetAreaMinBlobDistance(cliffID, 16.0);
			rmSetAreaMaxBlobDistance(cliffID, 40.0);
			rmSetAreaCoherence(cliffID, 0.25);
			rmSetAreaSmoothDistance(cliffID, 10);
			rmSetAreaHeightBlend(cliffID, 2);
			
			if(rmBuildArea(cliffID)==false) {
				// Stop trying once we fail 3 times in a row.
				failCount++;
				if(failCount==3) {
					break;
				}
			} else {
				failCount=0;
			}
		}
	}
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int count=0;
	failCount=0;
	
	for(j=1; <cNumberPlayers) {
		for(i=0; <7) {
			int forestID=rmCreateArea("forest"+i +j, rmAreaID("player"+j));
			rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
			if(cMapSize == 2) {
				rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
			}
			
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, "hades forest");
			rmAddAreaConstraint(forestID, forestObjConstraint);
			rmAddAreaConstraint(forestID, forestConstraint);
			rmAddAreaConstraint(forestID, avoidImpassableLand);
			rmAddAreaToClass(forestID, classForest);
			rmAddAreaConstraint(forestID, avoidBuildings);
			
			rmSetAreaMinBlobs(forestID, 2);
			rmSetAreaMaxBlobs(forestID, 4);
			rmSetAreaMinBlobDistance(forestID, 16.0);
			rmSetAreaMaxBlobDistance(forestID, 20.0);
			rmSetAreaCoherence(forestID, 0.0);
			
			// Hill trees?
			if(rmRandFloat(0.0, 1.0)<0.2) {
				rmSetAreaBaseHeight(forestID, rmRandFloat(6.0, 8.0));
			}
			
			if(rmBuildArea(forestID)==false) {
				// Stop trying once we fail 3 times in a row.
				failCount++;
				if(failCount==3) {
					break;
				}
			} else {
				failCount=0;
			}
		}
	}
	
	rmSetStatusText("",0.93);
	
	
	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.
	
		int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
	
	int columnID=rmCreateObjectDef("columns");
	rmAddObjectDefItem(columnID, "ruins", rmRandInt(1,4), 6.0);
	rmAddObjectDefItem(columnID, "columns broken", rmRandInt(1,2), 4.0);
	rmAddObjectDefItem(columnID, "rock limestone sprite", rmRandInt(3,6), 10.0);
	rmAddObjectDefItem(columnID, "skeleton", rmRandInt(4,9), 10.0);
	rmSetObjectDefMinDistance(columnID, 0.0);
	rmSetObjectDefMaxDistance(columnID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(columnID, avoidAll);
	rmAddObjectDefConstraint(columnID, shortAvoidSettlement);
	rmAddObjectDefConstraint(columnID, avoidImpassableLand);
	rmAddObjectDefConstraint(columnID, shortCliffConstraint);
	rmPlaceObjectDefAtLoc(columnID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	int stalagmiteID=rmCreateObjectDef("stalagmite");
	rmAddObjectDefItem(stalagmiteID, "stalagmite", 1, 0.0);
	rmSetObjectDefMinDistance(stalagmiteID, 0.0);
	rmSetObjectDefMaxDistance(stalagmiteID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(stalagmiteID, avoidAll);
	rmAddObjectDefConstraint(stalagmiteID, shortAvoidSettlement);
	if(styx==0) {
		rmAddObjectDefConstraint(stalagmiteID, avoidImpassableLand);
	}
	rmAddObjectDefConstraint(stalagmiteID, shortCliffConstraint);
	rmPlaceObjectDefAtLoc(stalagmiteID, 0, 0.5, 0.5, 7*cNumberNonGaiaPlayers);
	
	int stalagmite2ID=rmCreateObjectDef("stalagmite2");
	rmAddObjectDefItem(stalagmite2ID, "stalagmite", 3, 1.0);
	rmSetObjectDefMinDistance(stalagmite2ID, 0.0);
	rmSetObjectDefMaxDistance(stalagmite2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(stalagmite2ID, avoidAll);
	if(styx==0) {
		rmAddObjectDefConstraint(stalagmite2ID, avoidImpassableLand);
	}
	rmAddObjectDefConstraint(stalagmite2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(stalagmite2ID, shortCliffConstraint);
	rmPlaceObjectDefAtLoc(stalagmite2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int stalagmite3ID=rmCreateObjectDef("stalagmite3");
	rmAddObjectDefItem(stalagmite3ID, "stalagmite", 5, 2.0);
	rmSetObjectDefMinDistance(stalagmite3ID, 0.0);
	rmSetObjectDefMaxDistance(stalagmite3ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(stalagmite3ID, avoidAll);
	rmAddObjectDefConstraint(stalagmite3ID, shortAvoidSettlement);
	if(styx==0) {
		rmAddObjectDefConstraint(stalagmite3ID, avoidImpassableLand);
	}
	rmAddObjectDefConstraint(stalagmite3ID, shortCliffConstraint);
	rmPlaceObjectDefAtLoc(stalagmite3ID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int pathableConstraint=rmCreateClassDistanceConstraint("fire stay in river", pathableClass, 6);
	
	int flameID=rmCreateObjectDef("fire");
	rmAddObjectDefItem(flameID, "fire Hades", 1, 0.0);
	rmSetObjectDefMinDistance(flameID, 0.0);
	rmSetObjectDefMaxDistance(flameID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(flameID, pathableConstraint);
	if(styx==0) {
		rmPlaceObjectDefAtLoc(flameID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	}
	
	int bubbleID=rmCreateObjectDef("bubble");
	rmAddObjectDefItem(bubbleID, "lava bubbling", 1, 0.0);
	rmSetObjectDefMinDistance(bubbleID, 0.0);
	rmSetObjectDefMaxDistance(bubbleID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bubbleID, pathableConstraint);
	if(styx==0) {
		rmPlaceObjectDefAtLoc(bubbleID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	}
	
	int farHarpyID=rmCreateObjectDef("far birds");
	rmAddObjectDefItem(farHarpyID, "harpy", 1, 0.0);
	rmSetObjectDefMinDistance(farHarpyID, 0.0);
	rmSetObjectDefMaxDistance(farHarpyID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farHarpyID, false, 2);
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(rockID, shortCliffConstraint);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

	
	rmSetStatusText("",1.0);
}
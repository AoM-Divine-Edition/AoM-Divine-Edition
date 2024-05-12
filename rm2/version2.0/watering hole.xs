/*	Map Name: Watering Hole.xs
**	Author: Milkman Matty
**	Made for Forgotten Empires.
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
	int playerTiles=9000;
	if(cMapSize == 1) {
		playerTiles = 11700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 23400;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(1.0);
	rmSetSeaType("savannah Water Hole");
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classIsland=rmDefineClass("island");
	int classBonusIsland=rmDefineClass("bonus island");
	int classPlayerCore = rmDefineClass("player core");
	int classPlayer=rmDefineClass("player");
	int classForward=rmDefineClass("forward TC");
	int classForest=rmDefineClass("forest");
	rmDefineClass("center");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	int classBH1=rmDefineClass("Bonus Hunt 1");
	int classBH2=rmDefineClass("Bonus Hunt 2");
	int classBH3=rmDefineClass("Bonus Hunt 3");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid bonus island", classBonusIsland, 15.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 4.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	rmPlacePlayersCircular(0.41, 0.425, rmDegreesToRadians(5.0));
	rmRecordPlayerLocations();
	
	int centerID=rmCreateArea("center");
	rmSetAreaSize(centerID, 0.01, 0.01);
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmBuildArea(centerID);
	
	// Create player cores so bonus islands avoid them
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player core"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
		rmAddAreaToClass(id, classPlayerCore);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaLocPlayer(id, i);
		
		rmBuildArea(id);
	}
	
	int shallowsID=rmCreateConnection("shallows");
	rmSetConnectionType(shallowsID, cConnectAreas, false, 1.0);
	rmSetConnectionWidth(shallowsID, 16, 2);
	rmSetConnectionWarnFailure(shallowsID, false);
	rmSetConnectionBaseHeight(shallowsID, 2.0);
	rmSetConnectionHeightBlend(shallowsID, 2.0);
	rmSetConnectionSmoothDistance(shallowsID, 3.0);
	rmAddConnectionTerrainReplacement(shallowsID, "riverSandyA", "SavannahC"); /*riverSandyC */
	
	int coreBonusConstraint=rmCreateClassDistanceConstraint("core v bonus island", classPlayerCore, 50.0);
	
	int extraShallowsID=rmCreateConnection("extra shallows");
	if(cNumberPlayers < 5) {
		rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.75);
	} else if(cNumberPlayers < 7) {
		rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.30);
	}
	rmSetConnectionWidth(extraShallowsID, 16, 2);
	rmSetConnectionWarnFailure(extraShallowsID, false);
	rmSetConnectionBaseHeight(extraShallowsID, 2.0);
	rmSetConnectionHeightBlend(extraShallowsID, 2.0);
	rmSetConnectionSmoothDistance(extraShallowsID, 3.0);
	rmSetConnectionPositionVariance(extraShallowsID, -1.0);
	rmAddConnectionTerrainReplacement(extraShallowsID, "riverSandyA", "SavannahC");
	rmAddConnectionStartConstraint(extraShallowsID, coreBonusConstraint);
	rmAddConnectionEndConstraint(extraShallowsID, coreBonusConstraint);
	
	int teamShallowsID=rmCreateConnection("team shallows");
	rmSetConnectionType(teamShallowsID, cConnectAllies, false, 1.0);
	rmSetConnectionWarnFailure(teamShallowsID, false);
	rmSetConnectionWidth(teamShallowsID, 16, 2);
	rmSetConnectionBaseHeight(teamShallowsID, 2.0);
	rmSetConnectionHeightBlend(teamShallowsID, 2.0);
	rmSetConnectionSmoothDistance(teamShallowsID, 3.0);
	rmAddConnectionTerrainReplacement(teamShallowsID, "riverSandyA", "SavannahC");
	
	int bonusCount = rmRandInt(2, 3);
	int bonusIsleSize = 1800;
	
	if(cNumberNonGaiaPlayers > 5) {
		bonusIsleSize = 3000;
		bonusCount = rmRandInt(3, 4);
	} else if(cNumberNonGaiaPlayers > 8) {
		bonusIsleSize = 3000;
		bonusCount = rmRandInt(3, 4);
	} else {
		bonusIsleSize = 3000;
		bonusCount = rmRandInt(3, 4);
	}
	rmEchoInfo("number of bonus isles "+bonusCount+ "size of isles "+bonusIsleSize);
	
	int bonusIslandEdgeConstraint = -1;
	if(cNumberNonGaiaPlayers == 2){
		bonusIslandEdgeConstraint = rmCreateBoxConstraint("bonus island avoids edge", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30));
	} else if(cNumberNonGaiaPlayers <= 4){
		bonusIslandEdgeConstraint = rmCreateBoxConstraint("bonus island avoids edge", rmXTilesToFraction(50), rmZTilesToFraction(50), 1.0-rmXTilesToFraction(50), 1.0-rmZTilesToFraction(50));
	} else {
		bonusIslandEdgeConstraint = rmCreateBoxConstraint("bonus island avoids edge", rmXTilesToFraction(60), rmZTilesToFraction(60), 1.0-rmXTilesToFraction(60), 1.0-rmZTilesToFraction(60));
	}
	
	for(i=0; <bonusCount*mapSizeMultiplier) {
		int bonusIslandID=rmCreateArea("bonus island"+i);
		rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(bonusIsleSize*0.9), rmAreaTilesToFraction(bonusIsleSize*1.1));
		rmSetAreaTerrainType(bonusIslandID, "SavannahB");
		rmAddAreaTerrainLayer(bonusIslandID, "SavannahC", 0, 6);
		rmSetAreaWarnFailure(bonusIslandID, false);
		if(rmRandFloat(0.0, 1.0)<0.70) {
			rmAddAreaConstraint(bonusIslandID, bonusIslandConstraint);
		}
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
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 40.0);
	int islandConstraint=rmCreateClassDistanceConstraint("stay away from islands", classIsland, 20.0);
	float playerHeight = 2.0;
	float playerHeightBlend = 2.0;
	float playerSmoothDistance = 10.0;
	float playerFraction=rmAreaTilesToFraction(3500);
	for(i=1; <cNumberPlayers) {
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
		rmSetAreaBaseHeight(id, playerHeight);
		rmSetAreaSmoothDistance(id, playerSmoothDistance);
		rmSetAreaHeightBlend(id, playerHeightBlend);
		rmAddAreaConstraint(id, islandConstraint);
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
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	rmBuildConnection(teamShallowsID);
	rmBuildConnection(shallowsID);
	if(cNumberNonGaiaPlayers < 4) {
		rmBuildConnection(extraShallowsID);
	} else if(cNumberNonGaiaPlayers < 6) {
		if(rmRandFloat(0,1)<0.5) {
			rmBuildConnection(extraShallowsID);
		}
	}
	
	for(i=1; <cNumberPlayers*50*mapSizeMultiplier){
		int id2=rmCreateArea("dirt patch"+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(40*mapSizeMultiplier));
		rmSetAreaTerrainType(id2, "SavannahA");
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		rmAddAreaConstraint(id2, shortAvoidImpassableLand);
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*15*mapSizeMultiplier) {
		int id3=rmCreateArea("grass patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "SandA");
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		rmAddAreaConstraint(id3, shortAvoidImpassableLand);
		rmBuildArea(id3);
	}
	
	int failCount=0;
	int numTries1=10*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
	for(i=0; <numTries1) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(80));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
		if(rmRandFloat(0.0, 1.0)<0.7) {
			rmSetAreaTerrainType(elevID, "SavannahC");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 6 times in a row.
			failCount++;
			if(failCount==6) {
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
	
	int farEdgeConstraint=rmCreateBoxConstraint("far edge of map", rmXTilesToFraction(23), rmZTilesToFraction(23), 1.0-rmXTilesToFraction(23), 1.0-rmZTilesToFraction(23));
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1));
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
	int avoidSettlement=rmCreateTypeDistanceConstraint("basic avoid settlement", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 50.0);
	int medAvoidSettlement = rmCreateTypeDistanceConstraint("stuff avoid settlements", "AbstractSettlement", 40.0);
	int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 40.0);
	int farAvoidGold = rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
	int shortAvoidGold = rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
	int medAvoidGold = rmCreateTypeDistanceConstraint("medium avoid gold", "gold", 20.0);
	int avoidFoodFar = rmCreateTypeDistanceConstraint("avoid food far", "food", 20.0);
	int avoidFood = rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
	int avoidImpassableLand = rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	int avoidAll = rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler avoid all", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler avoid gold", "gold", 6.0);
	int nearShore = rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);
	
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
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, classStartingSettlement);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int farAvoidSettlement = -1;
	if(cMapSize != 2){
		if(cNumberNonGaiaPlayers == 2){
			farAvoidSettlement = rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance0", "AbstractSettlement", 55.0);
		} else {
			farAvoidSettlement = rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance1", "AbstractSettlement", 65.0+cNumberNonGaiaPlayers);
		}
	} else {
		farAvoidSettlement = rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance2", "AbstractSettlement", 75.0+cNumberNonGaiaPlayers);
	}
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 50.0);
	int backVsForward = rmCreateClassDistanceConstraint("back V front", classForward, 75.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 10.0);
	int farAvoidSettlement2 = rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);
	int TCedge=rmCreateBoxConstraint("TC edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int settlmentBoxConst = rmCreateBoxConstraint("Center settlements", 0.0, 0.0, 1.0, 1.0);
	if(cNumberNonGaiaPlayers == 2){
		farAvoidSettlement2 = rmCreateTypeDistanceConstraint("2plr TCs avoid TCs by long distance", "AbstractSettlement", 30.0);
		settlmentBoxConst = rmCreateBoxConstraint("2plr Center settlements", 0.325, 0.325, 0.675, 0.675);
	} else if(cNumberNonGaiaPlayers < 5){
		settlmentBoxConst = rmCreateBoxConstraint("4plr Center settlements", 0.3, 0.3, 0.7, 0.7);
		farAvoidSettlement2 = rmCreateTypeDistanceConstraint("2plr TCs avoid TCs by long distance", "AbstractSettlement", 55.0+cNumberNonGaiaPlayers);
	} else { // if(cNumberNonGaiaPlayers < 7){
		settlmentBoxConst = rmCreateBoxConstraint("6plr Center settlements", 0.25, 0.25, 0.75, 0.75);
		farAvoidSettlement2 = rmCreateTypeDistanceConstraint("2plr TCs avoid TCs by long distance", "AbstractSettlement", 65+cNumberNonGaiaPlayers);
	}
	
	int settlementArea = -1;
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", true, false,  75, 85, 40, 16);
			rmAddFairLocConstraint(id, farAvoidSettlement2);
			rmAddFairLocConstraint(id, settlmentBoxConst);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(id, classForward);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, rmXMetersToFraction(20.0), rmZMetersToFraction(20.0));
				rmSetAreaBaseHeight(settlementArea, playerHeight);
				rmSetAreaSmoothDistance(settlementArea, playerSmoothDistance);
				rmSetAreaHeightBlend(settlementArea, playerHeightBlend);
				rmSetAreaCoherence(settlementArea, 0.95);
				rmSetAreaTerrainType(settlementArea, "SandA");
				rmAddAreaTerrainLayer(settlementArea, "SavannahB", 6, 12);
				rmAddAreaTerrainLayer(settlementArea, "SavannahC", 0, 6);
				rmBuildArea(settlementArea);
				
				for(i=1; < 20){
					id2=rmCreateArea("far settlement"+p+" dirt patch"+i, settlementArea);
					rmSetAreaSize(id2, rmAreaTilesToFraction(20+i), rmAreaTilesToFraction(40));
					rmSetAreaTerrainType(id2, "SavannahA");
					rmSetAreaCoherence(id2, 0.0);
					rmAddAreaConstraint(id2, shortAvoidImpassableLand);
					rmBuildArea(id2);

					id3=rmCreateArea("far settlement"+p+" grass patch"+i, settlementArea);
					rmSetAreaSize(id3, rmAreaTilesToFraction(10+i), rmAreaTilesToFraction(50));
					if(rmRandFloat(0,1) < 0.65){
						rmSetAreaTerrainType(id3, "SandA");
					} else {
						rmSetAreaTerrainType(id3, "SavannahA");
					}
					rmSetAreaCoherence(id3, 0.0);
					rmAddAreaConstraint(id3, shortAvoidImpassableLand);
					rmBuildArea(id3);
				}
			} else {
				farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, settlmentBoxConst);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, farAvoidSettlement2);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt);
				}
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
			
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", false, true, 55, 65, 20, 20, true); /* bool forward bool inside */
			rmAddFairLocConstraint(id, farAvoidSettlement);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCedge);
			rmAddFairLocConstraint(id, backVsForward);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, rmXMetersToFraction(20.0), rmZMetersToFraction(20.0));
				rmSetAreaCoherence(settleArea, 0.95);
				rmSetAreaBaseHeight(settleArea, playerHeight);
				rmSetAreaSmoothDistance(settleArea, playerSmoothDistance);
				rmSetAreaHeightBlend(settleArea, playerHeightBlend);
				rmSetAreaTerrainType(settleArea, "SandA");
				rmAddAreaTerrainLayer(settleArea, "SavannahB", 6, 12);
				rmAddAreaTerrainLayer(settleArea, "SavannahC", 0, 6);
				rmBuildArea(settleArea);
				
				for(i=1; < 20){
					id2=rmCreateArea("close settlement"+p+" dirt patch"+i, settleArea);
					rmSetAreaSize(id2, rmAreaTilesToFraction(20+i), rmAreaTilesToFraction(40));
					rmSetAreaTerrainType(id2, "SavannahA");
					rmSetAreaCoherence(id2, 0.0);
					rmAddAreaConstraint(id2, shortAvoidImpassableLand);
					rmBuildArea(id2);

					id3=rmCreateArea("close settlement"+p+" grass patch"+i, settleArea);
					rmSetAreaSize(id3, rmAreaTilesToFraction(10+i), rmAreaTilesToFraction(50));
					if(rmRandFloat(0,1) < 0.65){
						rmSetAreaTerrainType(id3, "SandA");
					} else {
						rmSetAreaTerrainType(id3, "SavannahA");
					}
					rmSetAreaCoherence(id3, 0.0);
					rmAddAreaConstraint(id3, shortAvoidImpassableLand);
					rmBuildArea(id3);
				}
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				rmAddObjectDefConstraint(closeID, farAvoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				rmAddObjectDefConstraint(closeID, TCedge);
				rmAddObjectDefConstraint(closeID, backVsForward);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt);
				}
			}
			
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		
		id=rmAddFairLoc("Settlement", true, false,  75+cNumberNonGaiaPlayers, 80+2*cNumberNonGaiaPlayers, 70, 0);
		rmAddFairLocConstraint(id, settlmentBoxConst);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("far settlement 2Player+");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			rmAddObjectDefToClass(id, classForward);
			for(p=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(p)){
					settlementArea = rmCreateArea("settlement_area_"+p+j);
					rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
					rmSetAreaSize(settlementArea, rmXMetersToFraction(20.0), rmZMetersToFraction(20.0));
					rmSetAreaBaseHeight(settlementArea, playerHeight);
					rmSetAreaSmoothDistance(settlementArea, playerSmoothDistance);
					rmSetAreaHeightBlend(settlementArea, playerHeightBlend);
					rmSetAreaCoherence(settlementArea, 0.95);
					rmSetAreaTerrainType(settlementArea, "SandA");
					rmAddAreaTerrainLayer(settlementArea, "SavannahB", 6, 12);
					rmAddAreaTerrainLayer(settlementArea, "SavannahC", 0, 6);
					rmBuildArea(settlementArea);
					
					rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(p, j), rmFairLocZFraction(p, j), 1);
					
					for(i=1; < 20){
						int dirtPatch=rmCreateArea("far settlement"+p+" dirt patch"+i, settlementArea);
						rmSetAreaSize(dirtPatch, rmAreaTilesToFraction(20+i), rmAreaTilesToFraction(40));
						rmSetAreaTerrainType(dirtPatch, "SavannahA");
						rmSetAreaCoherence(dirtPatch, 0.0);
						rmAddAreaConstraint(dirtPatch, shortAvoidImpassableLand);
						rmBuildArea(dirtPatch);

						int grassPatch=rmCreateArea("far settlement"+p+" grass patch"+i, settlementArea);
						rmSetAreaSize(grassPatch, rmAreaTilesToFraction(10+i), rmAreaTilesToFraction(50));
						if(rmRandFloat(0,1) < 0.65){
							rmSetAreaTerrainType(grassPatch, "SavannahC");
						} else {
							rmSetAreaTerrainType(grassPatch, "SavannahA");
						}
						rmSetAreaCoherence(grassPatch, 0.0);
						rmAddAreaConstraint(grassPatch, shortAvoidImpassableLand);
						rmBuildArea(grassPatch);
					}
				}
			}
		} rmResetFairLocs();
		
		id=rmAddFairLoc("Settlement", false, true, 55, 65, 40, 20);
		rmAddFairLocConstraint(id, farAvoidSettlement);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCedge);
		rmAddFairLocConstraint(id, backVsForward);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("twoPlayer+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		} else {
			for(p = 1; <cNumberPlayers){
				farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, farAvoidSettlement2);
				rmAddObjectDefConstraint(farID, TCedge);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt);
				}
			}
		}
	}
	
	
		
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.36), 40, 16);
		rmAddFairLocConstraint(id, farAvoidSettlement);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, rmXMetersToFraction(20.0), rmZMetersToFraction(20.0));
			rmSetAreaBaseHeight(settlementArea2, playerHeight);
			rmSetAreaSmoothDistance(settlementArea2, playerSmoothDistance);
			rmSetAreaHeightBlend(settlementArea2, playerHeightBlend);
			rmSetAreaCoherence(settlementArea2, 0.95);
			rmSetAreaTerrainType(settlementArea2, "SavannahB");
			rmAddAreaTerrainLayer(settlementArea2, "SavannahC", 3, 6);
			rmAddAreaTerrainLayer(settlementArea2, "SandB", 0, 3);
			rmBuildArea(settlementArea2);
			rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);
	
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "gazelle", rmRandInt(4,5), 4.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 21.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmAddObjectDefConstraint(startingHuntableID, shortAvoidGold);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, edgeConstraint);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closePigsID=rmCreateObjectDef("close Pigs");
	rmAddObjectDefItem(closePigsID, "pig", rmRandInt(1,2), 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, shortAvoidGold);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(closePigsID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(1, 7));
	
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
		for(i=1; <= maxNum){
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			if(rmRandFloat(0,1)<0.8) {
				rmSetAreaForestType(playerStartingForestID, "savannah forest");
			} else {
				rmSetAreaForestType(playerStartingForestID, "palm forest");
			}
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaConstraint(playerStartingForestID, stragglerTreeAvoid);
			rmAddAreaConstraint(playerStartingForestID, stragglerTreeAvoidGold);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.25);
			rmBuildArea(playerStartingForestID);
		}
	}
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 23.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", rmClassID("forest"), 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, shortAvoidGold);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 24;
		while( rmGetNumberUnitsPlaced(startingTowerID) < (4*p) ){
			rmPlaceObjectDefAtLoc(startingTowerID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			placement++;
			if(placement % 20 == 0){
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
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, farAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, true);
	
	int mediumHippoID=rmCreateObjectDef("medium Hippo");
	float hippoNumber=rmRandFloat(0, 1);
	if(hippoNumber<0.3) {
		rmAddObjectDefItem(mediumHippoID, "hippo", 2, 1.0);
	} else if(hippoNumber<0.6) {
		rmAddObjectDefItem(mediumHippoID, "hippo", 3, 4.0);
	} else {
		rmAddObjectDefItem(mediumHippoID, "rhinocerous", 2, 1.0);
	}
	//RR <3
	if(rmRandFloat(0,1)<0.5){
		rmSetObjectDefMinDistance(mediumHippoID, 32.5);
		rmSetObjectDefMaxDistance(mediumHippoID, 35.0);
		rmAddObjectDefConstraint(mediumHippoID, rmCreateClassDistanceConstraint("hippos stay out of the woods!", classForest, 3.0));
	} else {
		rmSetObjectDefMinDistance(mediumHippoID, 55.0);
		rmSetObjectDefMaxDistance(mediumHippoID, 57.5);
	}
	rmAddObjectDefConstraint(mediumHippoID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumHippoID, edgeConstraint);
	rmAddObjectDefConstraint(mediumHippoID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumHippoID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumHippoID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumHippoID, false);
	
	int numHuntable=rmRandInt(6, 10);
	int mediumGazelleID=rmCreateObjectDef("medium gazelles");
	rmAddObjectDefItem(mediumGazelleID, "gazelle", numHuntable, 4.0);
	rmSetObjectDefMinDistance(mediumGazelleID, 55.0);
	rmSetObjectDefMaxDistance(mediumGazelleID, 75.0);
	rmAddObjectDefConstraint(mediumGazelleID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGazelleID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGazelleID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGazelleID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGazelleID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGazelleID, medAvoidGold);
	
	int mediumZebraID=rmCreateObjectDef("medium zebra");
	rmAddObjectDefItem(mediumZebraID, "zebra", numHuntable, 4.0);
	rmSetObjectDefMinDistance(mediumZebraID, 65.0);
	rmSetObjectDefMaxDistance(mediumZebraID, 80.0);
	rmAddObjectDefConstraint(mediumZebraID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumZebraID, avoidSettlement);
	rmAddObjectDefConstraint(mediumZebraID, edgeConstraint);
	rmAddObjectDefConstraint(mediumZebraID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumZebraID, medAvoidGold);
	
	int centreHuntID=rmCreateObjectDef("centre hunt");
	rmSetObjectDefMinDistance(centreHuntID, 12.0);
	rmSetObjectDefMaxDistance(centreHuntID, 60.0);
	rmAddObjectDefConstraint(centreHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(centreHuntID, shortAvoidGold);
	rmAddObjectDefConstraint(centreHuntID, avoidFood);
	
	if(rmRandFloat(0.0, 1.0)<0.5) {
		rmPlaceObjectDefPerPlayer(mediumGazelleID, false);
		rmAddObjectDefItem(centreHuntID, "zebra", numHuntable, 4.0);
	} else if(rmRandFloat(0,1)<0.2) {
		rmPlaceObjectDefPerPlayer(mediumGazelleID, false);
		rmPlaceObjectDefPerPlayer(mediumZebraID, false);
		rmAddObjectDefItem(centreHuntID, "zebra", numHuntable/2, 4.0);
		rmAddObjectDefItem(centreHuntID, "gazelle", numHuntable/2, 4.0);
	} else {
		rmPlaceObjectDefPerPlayer(mediumZebraID, false);
		rmAddObjectDefItem(centreHuntID, "gazelle", numHuntable, 4.0);
	}
	for(p = 1; <= cNumberNonGaiaPlayers){
		rmPlaceObjectDefAtLoc(centreHuntID, 0, 0.5,0.5, 1);
	}
	
	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 60.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumPigsID, edgeConstraint);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumPigsID, medAvoidGold);
	rmPlaceObjectDefPerPlayer(mediumPigsID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 110.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1,2));
	
	int bonusGoldID=rmCreateObjectDef("gold on bonus islands");
	rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(bonusGoldID, 80.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 120.0);
	rmAddObjectDefConstraint(bonusGoldID, farAvoidGold);
	rmAddObjectDefConstraint(bonusGoldID, edgeConstraint);
	rmAddObjectDefConstraint(bonusGoldID, avoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, rmCreateClassDistanceConstraint("bonus gold stay away from players", classPlayer, 10));
	rmAddObjectDefConstraint(bonusGoldID, avoidImpassableLand);
	if(rmRandFloat(0,1)<0.75){
		rmPlaceObjectDefPerPlayer(bonusGoldID, false, 2);
	} else {
		rmPlaceObjectDefPerPlayer(bonusGoldID, false, 1);
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "elephant", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,4), 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "hippo", rmRandInt(3,5), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 85.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 90.0+(2*cNumberNonGaiaPlayers-4));
	rmAddObjectDefToClass(bonusHuntableID, classBH1);
	rmAddObjectDefConstraint(bonusHuntableID, rmCreateClassDistanceConstraint("avoid BH1", classBH1, 40.0));
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, medAvoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID2, "elephant", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID2, "water buffalo", rmRandInt(5,6), 3.0);
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID2, "zebra", rmRandInt(3,4), 3.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID2, "gazelle", rmRandInt(6,8), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID2, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID2, rmXFractionToMeters(0.5));
	rmAddObjectDefToClass(bonusHuntableID2, classBH2);
	rmAddObjectDefConstraint(bonusHuntableID2, rmCreateClassDistanceConstraint("avoid BH2", classBH2, 40.0));
	rmAddObjectDefConstraint(bonusHuntableID2, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID2, medAvoidGold);
	rmAddObjectDefConstraint(bonusHuntableID2, farEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, nearShore);
	rmPlaceObjectDefPerPlayer(bonusHuntableID2, false, 2);
	
	int bonusHuntableID3=rmCreateObjectDef("bonus huntable3");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID3, "hippo", 3, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID3, "zebra", rmRandInt(5,6), 3.0);
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID3, "giraffe", rmRandInt(3,4), 4.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID3, "rhinocerous", 4, 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID3, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID3, rmXFractionToMeters(0.5));
	rmAddObjectDefToClass(bonusHuntableID3, classBH3);
	rmAddObjectDefConstraint(bonusHuntableID3, rmCreateClassDistanceConstraint("avoid BH3", classBH3, 40.0));
	rmAddObjectDefConstraint(bonusHuntableID3, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID3, farEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID3, medAvoidGold);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID3, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID3, false, rmRandInt(1, 2));
	
	int numCrane=rmRandInt(6, 8);
	int farCraneID=rmCreateObjectDef("far Crane");
	rmAddObjectDefItem(farCraneID, "crowned crane", numCrane, 3.0);
	rmSetObjectDefMinDistance(farCraneID, 65.0);
	rmSetObjectDefMaxDistance(farCraneID, 110.0);
	rmAddObjectDefConstraint(farCraneID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCraneID, edgeConstraint);
	rmAddObjectDefConstraint(farCraneID, nearShore);
	rmAddObjectDefConstraint(farCraneID, medAvoidGold);
	rmAddObjectDefConstraint(farCraneID, avoidFood);
	rmPlaceObjectDefPerPlayer(farCraneID, false);
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 105.0);
	rmAddObjectDefConstraint(farPigsID, avoidFoodFar);
	rmAddObjectDefConstraint(farPigsID, medAvoidGold);
	rmAddObjectDefConstraint(farPigsID, edgeConstraint);
	rmAddObjectDefConstraint(farPigsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(1,2));
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "lion", 3, 2.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, avoidFoodFar);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 50.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 146", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, medAvoidSettlement);
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);
	
	int farCrocsID=rmCreateObjectDef("far Crocs");
	rmAddObjectDefItem(farCrocsID, "crocodile", rmRandInt(1,2), 0.0);
	rmSetObjectDefMinDistance(farCrocsID, 65.0);
	rmSetObjectDefMaxDistance(farCrocsID, 100.0);
	rmAddObjectDefConstraint(farCrocsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCrocsID, nearShore);
	rmAddObjectDefConstraint(farCrocsID, avoidFood);
	rmAddObjectDefConstraint(farCrocsID, rmCreateTypeDistanceConstraint("preds avoid gold 154", "gold", 40.0));
	rmAddObjectDefConstraint(farCrocsID, medAvoidSettlement);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farCrocsID, false, rmAreaID("player"+i));
	}
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 60.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantGoldID, farAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, medAvoidSettlement);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "hippo", 3, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntableID, "zebra", rmRandInt(5,6), 3.0);
			if(rmRandFloat(0,1)<0.5) {
				rmAddObjectDefItem(giantHuntableID, "giraffe", rmRandInt(4,5), 4.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntableID, "rhinocerous", 4, 3.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.33));
		rmAddObjectDefConstraint(giantHuntableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, edgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, medAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable2ID, "elephant", 2, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable2ID, "water buffalo", rmRandInt(5,6), 3.0);
			if(rmRandFloat(0,1)<0.5) {
				rmAddObjectDefItem(giantHuntable2ID, "zebra", rmRandInt(3,4), 3.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "gazelle", rmRandInt(6,8), 4.0);
		}
		rmSetObjectDefMinDistance(giantHuntable2ID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntable2ID, medAvoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, edgeConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, medAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, nearShore);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, medAvoidGold);
		rmAddObjectDefConstraint(giantHerdableID, edgeConstraint);
		rmAddObjectDefConstraint(giantHerdableID, avoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, medAvoidGold);
		rmAddObjectDefConstraint(giantRelixID, edgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, medAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "abstractSettlement", 18.0);
	int forestCount=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0,1)<0.8) {
			rmSetAreaForestType(forestID, "savannah forest");
		} else {
			rmSetAreaForestType(forestID, "palm forest");
		}
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
		if(rmRandFloat(0.0, 1.0)<0.2) {
			rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
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
	
	rmSetStatusText("",0.93);
	
	
	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 8.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int randomTreeID2=rmCreateObjectDef("random tree 2");
	rmAddObjectDefItem(randomTreeID2, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID2, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID2, rmCreateTypeDistanceConstraint("random tree two", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID2, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID2, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID2, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
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
	rmSetObjectDefMaxDistance(lilyID, 60.0);
	rmAddObjectDefConstraint(lilyID, avoidAll);
	rmPlaceObjectDefAtLoc(lilyID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int lily2ID=rmCreateObjectDef("lily2 pad groups");
	rmAddObjectDefItem(lily2ID, "water lilly", 4, 2.0);
	rmSetObjectDefMinDistance(lily2ID, 0.0);
	rmSetObjectDefMaxDistance(lily2ID, 60.0);
	rmAddObjectDefConstraint(lily2ID, avoidAll);
	rmPlaceObjectDefAtLoc(lily2ID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int decorID=rmCreateObjectDef("water decorations");
	rmAddObjectDefItem(decorID, "water decoration", 3, 6.0);
	rmSetObjectDefMinDistance(decorID, 0.0);
	rmSetObjectDefMaxDistance(decorID, 60.0);
	rmAddObjectDefConstraint(decorID, avoidAll);
	rmPlaceObjectDefAtLoc(decorID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
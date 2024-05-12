/*	Map Name: Marsh.xs
**	Author: Milkman Matty
**	Made for Forgotten Empires.
*/

//Include the library file.
include "MmM_FE_lib.xs";

// Main entry point for random map script
void main(void)
{

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
	} else if(cMapSize == 2) {
		playerTiles = 23400;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(1.0);
	rmSetSeaType("Marsh Pool");
	rmSetLightingSet("Fimbulwinter");
	rmTerrainInitialize("water");

	rmSetStatusText("",0.07);

	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */

	int classIsland=rmDefineClass("island");
	int classBonusIsland=rmDefineClass("bonus island");
	int classPlayerCore=rmDefineClass("player core");
	int classPlayer=rmDefineClass("player");
	int classForest=rmDefineClass("forest");
	rmDefineClass("starting settlement");
	rmDefineClass("center");
	int classStartingSettlement = rmDefineClass("starting settlement");

	rmSetStatusText("",0.13);

	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.

	int islandConstraint=rmCreateClassDistanceConstraint("stay away from islands", classIsland, 20.0);
	int playerConstraint=rmCreateClassDistanceConstraint("bonus Settlement stay away from players", classPlayer, 10);
	int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid bonus island", classBonusIsland, 15.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);

	rmSetStatusText("",0.20);

	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */

	if(cMapSize == 2) {
		rmPlacePlayersCircular(0.25, 0.28, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.38, 0.40, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();

	int centerID=rmCreateArea("center");
	rmSetAreaSize(centerID, 0.01, 0.01);
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmBuildArea(centerID);

	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player core"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
		rmAddAreaToClass(id, classPlayerCore);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaBaseHeight(id, 40.0);
		rmSetAreaLocPlayer(id, i);
		rmBuildArea(id);
	}

	int shallowsID=rmCreateConnection("shallows");
	rmSetConnectionType(shallowsID, cConnectAreas, false, 1.0);
	rmSetConnectionWidth(shallowsID, 28, 2);
	rmSetConnectionWarnFailure(shallowsID, false);
	rmSetConnectionBaseHeight(shallowsID, 2.0);
	rmSetConnectionHeightBlend(shallowsID, 2.0);
	rmSetConnectionSmoothDistance(shallowsID, 3.0);
	rmAddConnectionTerrainReplacement(shallowsID, "RiverMarshA", "MarshE"); /*RiverMarshA */

	int coreBonusConstraint=rmCreateClassDistanceConstraint("core v bonus island", classPlayerCore, 60.0);

	int extraShallowsID=rmCreateConnection("extra shallows");
	if(cNumberPlayers < 5) {
		rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.75);
	} else if(cNumberPlayers < 7) {
		rmSetConnectionType(extraShallowsID, cConnectAreas, false, 0.30);
	}
	rmSetConnectionWidth(extraShallowsID, 28, 2);
	rmSetConnectionWarnFailure(extraShallowsID, false);
	rmSetConnectionBaseHeight(extraShallowsID, 2.0);
	rmSetConnectionHeightBlend(extraShallowsID, 2.0);
	rmSetConnectionSmoothDistance(extraShallowsID, 3.0);
	rmSetConnectionPositionVariance(extraShallowsID, -1.0);
	rmAddConnectionTerrainReplacement(extraShallowsID, "RiverMarshA", "MarshE");
	rmAddConnectionStartConstraint(extraShallowsID, coreBonusConstraint);
	rmAddConnectionEndConstraint(extraShallowsID, coreBonusConstraint);

	// Create team connections
	int teamShallowsID=rmCreateConnection("team shallows");
	rmSetConnectionType(teamShallowsID, cConnectAllies, false, 1.0);
	rmSetConnectionWarnFailure(teamShallowsID, false);
	rmSetConnectionWidth(teamShallowsID, 28, 2);
	rmSetConnectionBaseHeight(teamShallowsID, 2.0);
	rmSetConnectionHeightBlend(teamShallowsID, 2.0);
	rmSetConnectionSmoothDistance(teamShallowsID, 3.0);
	rmAddConnectionTerrainReplacement(teamShallowsID, "RiverMarshA", "MarshE");

	// Build up some bonus islands.
	int bonusCount = rmRandInt(4, 5);
	int bonusIsleSize = 2800;
	rmEchoInfo("number of bonus isles "+bonusCount+ "size of isles "+bonusIsleSize);
	int bonusIslandEdgeConstraint=rmCreateBoxConstraint("bonus island avoids edge", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30));

	for(i=0; <bonusCount*mapSizeMultiplier) {
		int bonusIslandID=rmCreateArea("bonus island"+i);
		rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(bonusIsleSize*0.9), rmAreaTilesToFraction(bonusIsleSize*1.1));
		rmSetAreaTerrainType(bonusIslandID, "MarshA");
		rmAddAreaTerrainLayer(bonusIslandID, "MarshB", 0, 6);
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
		rmAddAreaConstraint(bonusIslandID, islandConstraint);
		rmAddConnectionArea(shallowsID, bonusIslandID);
	}
	rmBuildAllAreas();

	rmSetStatusText("",0.26);

	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */

	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 60.0);
	float playerFraction=rmAreaTilesToFraction(200);
	for(i=1; <cNumberPlayers) {
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
		rmAddAreaConstraint(id, bonusIslandConstraint);
		rmAddAreaConstraint(id, centerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmAddConnectionArea(extraShallowsID, id);
		rmAddConnectionArea(shallowsID, id);
		rmSetAreaTerrainType(id, "MarshD");
		rmAddAreaTerrainLayer(id, "MarshD", 4, 7);
		rmAddAreaTerrainLayer(id, "MarshD", 2, 4);
		rmAddAreaTerrainLayer(id, "MarshE", 0, 2);
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

	for(i=1; <cNumberPlayers*20) {
		int id3=rmCreateArea("marsh patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(10), rmAreaTilesToFraction(50));
		rmSetAreaTerrainType(id3, "MarshC");
		rmSetAreaMinBlobs(id3, 1);
		rmSetAreaMaxBlobs(id3, 5);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0);
		rmSetAreaCoherence(id3, 0.0);
		rmAddAreaConstraint(id3, shortAvoidImpassableLand);
		rmAddAreaConstraint(id3, playerConstraint);
		rmBuildArea(id3);
	}

	for(i=1; <cNumberPlayers*20) {
		int id6=rmCreateArea("grass patch"+i);
		rmSetAreaSize(id6, rmAreaTilesToFraction(10), rmAreaTilesToFraction(40));
		rmSetAreaTerrainType(id6, "GrassB");
		rmSetAreaMinBlobs(id6, 1);
		rmSetAreaMaxBlobs(id6, 5);
		rmSetAreaMinBlobDistance(id6, 16.0);
		rmSetAreaMaxBlobDistance(id6, 40.0);
		rmSetAreaCoherence(id6, 0.0);
		rmAddAreaConstraint(id6, shortAvoidImpassableLand);
		rmAddAreaConstraint(id6, bonusIslandConstraint);
		rmBuildArea(id6);
	}

	for(i=1; <cNumberPlayers*20) {
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
		rmAddAreaConstraint(id7, bonusIslandConstraint);
		rmBuildArea(id7);
	}

	int failCount=0;
	int numTries1=10*cNumberNonGaiaPlayers;
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
	for(i=0; <numTries1) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
		rmAddAreaConstraint(elevID, bonusIslandConstraint);
		if(rmRandFloat(0.0, 1.0)<0.7) {
			rmSetAreaTerrainType(elevID, "MarshD");
			rmAddAreaTerrainLayer(elevID, "MarshE", 0, 4);
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(6.0, 10.0));
		rmSetAreaHeightBlend(elevID, 2);
		rmSetAreaSmoothDistance(elevID, 20);
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

	int edgeConstraint=rmCreateBoxConstraint("edge of map",rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	int huntBoxConst = rmCreateBoxConstraint("center hunt", 0.3, 0.3, 0.70, 0.70);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 20.0);
	int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 30.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 50.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 20.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far avoid gold", "gold", 40.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler avoid all", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler avoid gold", "gold", 6.0);
	int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);
	int closeForestConstraint=rmCreateClassDistanceConstraint("closeforest v oakforest", rmClassID("forest"), 6.0);

	rmSetStatusText("",0.46);


	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */

	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.5) {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 21, 0, 15);
	} else {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 20, 21, 0, 15);
	}
	if(rmPlaceFairLocs()) {
		int startingGoldID=rmCreateObjectDef("Starting Gold");
		rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
		for(i=1; <cNumberPlayers) {
			for(j=0; <rmGetNumberFairLocs(i)) {
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

	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 40.0);
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 20.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	int TCcenter = rmCreateClassDistanceConstraint("TC avoid center", rmClassID("center"), 15.0);
	int settlmentBoxConst = rmCreateBoxConstraint("Center settlements", 0.28, 0.28, 0.72, 0.72);
	if(cNumberNonGaiaPlayers > 3 || cMapSize == 2) {
		settlmentBoxConst = rmCreateBoxConstraint("Center settlements", 0.25, 0.25, 0.75, 0.75);
	}

	if(cNumberNonGaiaPlayers == 2) {
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers) {

			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 80, 20, 16);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidPlayer);

			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "MarshD");
				rmAddAreaTerrainLayer(settleArea, "MarshD", 4, 7);
				rmAddAreaTerrainLayer(settleArea, "MarshD", 2, 4);
				rmAddAreaTerrainLayer(settleArea, "MarshE", 0, 2);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				for(attempt = 1; < 51) {
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0) {
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt*2);
				}
				//rmEchoError("How do these things even fail?");
				//chat(true, "<color=1,0,0>Function rmPlaceFairLocs() failed!", true, -1, true);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();

			id=rmAddFairLoc("far Settlement", true, false, 80, 80+cNumberNonGaiaPlayers, 30, 20);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, settlmentBoxConst);
			rmAddFairLocConstraint(id, TCcenter);

			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("far settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "MarshD");
				rmAddAreaTerrainLayer(settlementArea, "MarshD", 4, 7);
				rmAddAreaTerrainLayer(settlementArea, "MarshD", 2, 4);
				rmAddAreaTerrainLayer(settlementArea, "MarshE", 0, 2);
				rmBuildArea(settlementArea);
			} else {
				int farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, settlmentBoxConst);
				rmAddObjectDefConstraint(farID, TCcenter);
				for(attempt = 1; < 51) {
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0) {
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt*2);
				}
			}
			rmResetFairLocs();
		}
	} else {

		int TCcenterImpassableLand = rmCreateTerrainDistanceConstraint("TC center badlands", "land", false, 8.0);
		int TCavoidSettlement2 = rmCreateTypeDistanceConstraint("TC avoid TC", "AbstractSettlement", 63.0);
		if(cMapSize == 2) {
			TCavoidSettlement2 = rmCreateTypeDistanceConstraint("super far TCs avoid TC2", "AbstractSettlement", 40.0+(10.0*cNumberNonGaiaPlayers));
		}
		TCcenter = rmCreateClassDistanceConstraint("TC avoid center2", rmClassID("center"), 15.0+cNumberNonGaiaPlayers);
		int centerSetID = rmCreateObjectDef("center settlement");
		rmAddObjectDefItem(centerSetID, "Settlement", 1, 0.0);
		rmSetObjectDefMaxDistance(centerSetID, 40.0);
		rmAddObjectDefConstraint(centerSetID, TCcenterImpassableLand);
		rmAddObjectDefConstraint(centerSetID, settlmentBoxConst);
		rmAddObjectDefConstraint(centerSetID, TCavoidSettlement2);
		rmAddObjectDefConstraint(centerSetID, TCavoidPlayer);
		rmAddObjectDefConstraint(centerSetID, TCcenter);

		for(p = 1; <= cNumberNonGaiaPlayers) {
			for(attempt = 1; < 16 - cNumberNonGaiaPlayers) {
				rmPlaceObjectDefAtLoc(centerSetID, p, 0.5, 0.5, 1);
				if(rmGetNumberUnitsPlaced(centerSetID) >= p) {
					break;
				}
				if(cNumberNonGaiaPlayers <= 8 && cMapSize < 2) {
					rmSetObjectDefMaxDistance(centerSetID, 40.0 + (attempt*10.0));
				} else {
					rmSetObjectDefMaxDistance(centerSetID, (attempt*20)+(cNumberNonGaiaPlayers*10));
				}
			}
		}

		rmResetFairLocs();
		id=rmAddFairLoc("Settlement", false, true, 60, 80, 60, 18, true);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidWater);
		if(rmPlaceFairLocs()) {
			for(p = 1; <= cNumberNonGaiaPlayers) {
				id=rmCreateObjectDef("safe settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
			}
		}
	}

	if(cMapSize == 2) {
		//And one last time if Giant.
		int TCgaintAvoidSettlement = rmCreateTypeDistanceConstraint("giant TC avoid TC by long distance", "AbstractSettlement", 100.0);
		for(p = 1; <= cNumberNonGaiaPlayers) {

			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.38), 100, 16);
			rmAddFairLocConstraint(id, TCgaintAvoidSettlement);
			rmAddFairLocConstraint(id, rmCreateTerrainDistanceConstraint("giant TC avoid badlands", "land", false, 14.0));
			rmAddFairLocConstraint(id, TCavoidPlayer);

			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("Giant settlement_"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 1.0);
				int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
				rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea2, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea2, "MarshD");
				rmAddAreaTerrainLayer(settlementArea2, "MarshD", 4, 7);
				rmAddAreaTerrainLayer(settlementArea2, "MarshD", 2, 4);
				rmAddAreaTerrainLayer(settlementArea2, "MarshE", 0, 2);
				rmBuildArea(settlementArea2);
				rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	}

	rmSetStatusText("",0.53);

	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).

	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);

	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "deer", rmRandInt(6,7), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(startingHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);

	int closePigsID=rmCreateObjectDef("close Pigs");
	rmAddObjectDefItem(closePigsID, "pig", 4, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closePigsID, edgeConstraint);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(closePigsID, false);

	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, avoidFood);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3, 7));

	int stragglerTreeMarshID=rmCreateObjectDef("straggler tree2");
	rmAddObjectDefItem(stragglerTreeMarshID, "marsh tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeMarshID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeMarshID, 20.0);
	rmAddObjectDefConstraint(stragglerTreeMarshID, avoidFood);
	rmAddObjectDefConstraint(stragglerTreeMarshID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeMarshID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeMarshID, false, rmRandInt(3, 5));

	rmSetStatusText("",0.60);

	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */


	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", classStartingSettlement, 20.0);

	int maxNum = 4;
	for(p=1; <=cNumberNonGaiaPlayers) {
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum) {
			if(i == skip) {
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "mixed oak forest");
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
	rmAddObjectDefConstraint(startingTowerID, avoidFood);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, edgeConstraint);
	rmAddObjectDefConstraint(startingTowerID, huntShortAvoidsStartingGoldMilky);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers) {
		placement = 1;
		increment = 24;
		while( rmGetNumberUnitsPlaced(startingTowerID) < (4*p) ) {
			rmPlaceObjectDefAtLoc(startingTowerID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			placement++;
			if(placement % 20 == 0) {
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
	rmSetObjectDefMinDistance(mediumGoldID, 45.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	//rmPlaceObjectDefPerPlayer(mediumGoldID, false);

	int mediumHippoID=rmCreateObjectDef("medium Hippo");
	float hippoNumber=rmRandFloat(0, 1);
	if(hippoNumber<0.3) {
		rmAddObjectDefItem(mediumHippoID, "hippo", 2, 1.0);
	} else if(hippoNumber<0.6) {
		rmAddObjectDefItem(mediumHippoID, "hippo", 3, 4.0);
	} else {
		rmAddObjectDefItem(mediumHippoID, "water buffalo", 2, 1.0);
	}
	rmSetObjectDefMinDistance(mediumHippoID, 50.0);
	rmSetObjectDefMaxDistance(mediumHippoID, 55.0);
	rmAddObjectDefConstraint(mediumHippoID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumHippoID, closeForestConstraint);
	rmAddObjectDefConstraint(mediumHippoID, edgeConstraint);
	rmAddObjectDefConstraint(mediumHippoID, avoidAll);
	rmAddObjectDefConstraint(mediumHippoID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumHippoID, false);

	int numHuntable=rmRandInt(6, 10);
	int mediumDeerID=rmCreateObjectDef("medium deer");
	rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 6.0);
	rmSetObjectDefMinDistance(mediumDeerID, 60.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 70.0);
	rmAddObjectDefConstraint(mediumDeerID, edgeConstraint);
	rmAddObjectDefConstraint(mediumDeerID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumDeerID, closeForestConstraint);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(mediumDeerID, false);

	int mediumHuntableID=rmCreateObjectDef("medium hunt");
	float bonusChance=rmRandFloat(0,1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(mediumHuntableID, "water buffalo", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(mediumHuntableID, "deer", rmRandInt(5,6), 3.0);
	} else {
		rmAddObjectDefItem(mediumHuntableID, "hippo", rmRandInt(3,5), 3.0);
	}
	rmSetObjectDefMinDistance(mediumHuntableID, 60.0);
	rmSetObjectDefMaxDistance(mediumHuntableID, 65.0);
	rmAddObjectDefConstraint(mediumHuntableID, huntBoxConst);
	rmAddObjectDefConstraint(mediumHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumHuntableID, closeForestConstraint);
	rmAddObjectDefConstraint(mediumHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumHuntableID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(mediumHuntableID, false);

	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 50.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
	rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, edgeConstraint);
	rmAddObjectDefConstraint(mediumPigsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumPigsID, avoidGold);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumPigsID, closeForestConstraint);
	rmPlaceObjectDefPerPlayer(mediumPigsID, false);

	rmSetStatusText("",0.73);

	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).

	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, settlmentBoxConst);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 1);

	int objVsCentre = rmCreateClassDistanceConstraint("obj avoid center", rmClassID("center"), rmXFractionToMeters(0.38));
	int bonusAvoidGold=rmCreateTypeDistanceConstraint("bonus Gold avoid gold", "gold", 60.0-cNumberNonGaiaPlayers);

	int bonusGoldID=rmCreateObjectDef("gold on bonus islands");
	rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(bonusGoldID, 60.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 80.0);
	rmAddObjectDefConstraint(bonusGoldID, bonusAvoidGold);
	rmAddObjectDefConstraint(bonusGoldID, edgeConstraint);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, objVsCentre);
	rmAddObjectDefConstraint(bonusGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusGoldID, false, 1);

	rmSetObjectDefMinDistance(bonusGoldID, 80.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 100.0);
	rmPlaceObjectDefPerPlayer(bonusGoldID, false, 1);

	rmSetObjectDefMinDistance(bonusGoldID, 90.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 125.0);
	rmPlaceObjectDefPerPlayer(bonusGoldID, false, 1);

	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 30.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "water buffalo", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(5,6), 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "hippo", rmRandInt(3,5), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 50.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 70.0);
	rmAddObjectDefConstraint(bonusHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);

	rmSetObjectDefMinDistance(bonusHuntableID, 55.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 80.0);
	rmAddObjectDefConstraint(bonusHuntableID, objVsCentre);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);

	int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID2, "hippo", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID2, "water buffalo", rmRandInt(3,4), 3.0);
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(3,4), 3.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(6,8), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID2, 55.0);
	rmSetObjectDefMaxDistance(bonusHuntableID2, 60.0);
	rmAddObjectDefConstraint(bonusHuntableID2, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, bonusIslandConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidFood);
	rmPlaceObjectDefPerPlayer(bonusHuntableID2, false);

	rmSetObjectDefMinDistance(bonusHuntableID2, 55.0);
	rmSetObjectDefMaxDistance(bonusHuntableID2, 80.0);
	rmAddObjectDefConstraint(bonusHuntableID2, objVsCentre);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidHuntable);
	rmPlaceObjectDefPerPlayer(bonusHuntableID2, false);

	bool boar = false;
	int bonusHuntableID3=rmCreateObjectDef("bonus huntable3");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID3, "boar", 4, 2.0);
		boar = true;
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID3, "boar", 5, 3.0);
		boar = true;
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID3, "crowned crane", rmRandInt(4,6), 4.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID3, "water buffalo", rmRandInt(4,5), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID3, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID3, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID3, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID3, huntBoxConst);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID3, playerConstraint);
	rmAddObjectDefConstraint(bonusHuntableID3, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bonusHuntableID3, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

	int bonusHuntableID4=rmCreateObjectDef("bonus huntable3b");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5 && boar == false) {
		rmAddObjectDefItem(bonusHuntableID4, "boar", 4, 2.0);
	} else if(bonusChance<0.75 && boar == false) {
		rmAddObjectDefItem(bonusHuntableID4, "boar", 5, 3.0);
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID4, "crowned crane", rmRandInt(4,6), 4.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID4, "water buffalo", rmRandInt(2,3), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID4, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID4, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID4, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID4, huntBoxConst);
	rmAddObjectDefConstraint(bonusHuntableID4, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID4, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID4, playerConstraint);
	rmAddObjectDefConstraint(bonusHuntableID4, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bonusHuntableID4, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

	int farCraneID=rmCreateObjectDef("far Crane");
	rmAddObjectDefItem(farCraneID, "crowned crane", rmRandInt(6, 8), 3.0);
	rmSetObjectDefMinDistance(farCraneID, 85.0);
	rmSetObjectDefMaxDistance(farCraneID, 115.0);
	rmAddObjectDefConstraint(farCraneID, nearShore);
	rmAddObjectDefConstraint(farCraneID, edgeConstraint);
	rmAddObjectDefConstraint(farCraneID, shortAvoidGold);
	rmAddObjectDefConstraint(farCraneID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farCraneID, avoidFood);
	rmPlaceObjectDefPerPlayer(farCraneID, false);

	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 150.0);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPigsID, edgeConstraint);
	rmAddObjectDefConstraint(farPigsID, objVsCentre);
	rmAddObjectDefConstraint(farPigsID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(farPigsID, false);

	int farPredatorID=rmCreateObjectDef("far predator");
	rmAddObjectDefItem(farPredatorID, "crocodile", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 85.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 30.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, edgeConstraint);
	rmAddObjectDefConstraint(farPredatorID, playerConstraint);
	rmAddObjectDefConstraint(farPredatorID, farAvoidGold);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 163", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);

	int farCrocsID=rmCreateObjectDef("far Crocs");
	rmAddObjectDefItem(farCrocsID, "crocodile", rmRandInt(1,2), 0.0);
	rmSetObjectDefMinDistance(farCrocsID, 50.0);
	rmSetObjectDefMaxDistance(farCrocsID, 100.0);
	rmAddObjectDefConstraint(farCrocsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCrocsID, nearShore);
	rmAddObjectDefConstraint(farCrocsID, farAvoidGold);
	rmAddObjectDefConstraint(farCrocsID, edgeConstraint);
	rmAddObjectDefConstraint(farCrocsID, rmCreateTypeDistanceConstraint("preds avoid settlements 172", "AbstractSettlement", 40.0));
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farCrocsID, false, rmAreaID("player"+i));
	}

	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, 200.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 50.0));
	rmAddObjectDefConstraint(relicID, shortAvoidGold);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, playerConstraint);
	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);

	rmSetStatusText("",0.80);

	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2) {
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("giant gold avoid gold", "gold", 80.0));
		rmAddObjectDefConstraint(giantGoldID, avoidFoodFar);
		rmAddObjectDefConstraint(giantGoldID, edgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);


		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "boar", 5, 3.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, edgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, objVsCentre);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));

		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		rmAddObjectDefItem(giantHuntable2ID, "water buffalo", 2, 2.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, edgeConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, objVsCentre);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));

		int giantHuntable3ID=rmCreateObjectDef("giant huntable 3");
		rmAddObjectDefItem(giantHuntable3ID, "hippo", rmRandInt(4,5), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntable3ID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntable3ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable3ID, edgeConstraint);
		rmAddObjectDefConstraint(giantHuntable3ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable3ID, objVsCentre);
		rmAddObjectDefConstraint(giantHuntable3ID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntable3ID, false, rmRandInt(1, 2));

		int giantHuntable4ID=rmCreateObjectDef("giant huntable 4");
		rmAddObjectDefItem(giantHuntable4ID, "crowned crane", rmRandInt(6,7), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable4ID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHuntable4ID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHuntable4ID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntable4ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable4ID, edgeConstraint);
		rmAddObjectDefConstraint(giantHuntable4ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable4ID, objVsCentre);
		rmAddObjectDefConstraint(giantHuntable4ID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntable4ID, false, rmRandInt(1, 2));

		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.38));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.42));
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, edgeConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, playerConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, 1);

		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, avoidFood);
		rmAddObjectDefConstraint(giantRelixID, edgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}

	rmSetStatusText("",0.86);

	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */

	int forestCount=6*cNumberNonGaiaPlayers;
	if(cMapSize == 2) {
		forestCount = 2*forestCount;
	}
	if(cNumberNonGaiaPlayers == 2) {
		forestCount = 2+forestCount;
	}

	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 24.0);

	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(75), rmAreaTilesToFraction(100));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}

		rmSetAreaWarnFailure(forestID, false);

		rmSetAreaForestType(forestID, "Marsh forest");

		rmAddAreaConstraint(forestID, forestTC);
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, playerConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		rmSetAreaTerrainType(forestID, "MarshA");
		rmAddAreaTerrainLayer(forestID, "MarshB", 0, 2);

		rmSetAreaMinBlobs(forestID, 2);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 20.0);
		rmSetAreaCoherence(forestID, 0.0);
		rmSetAreaBaseHeight(forestID, 0);
		rmSetAreaSmoothDistance(forestID, 4);
		rmSetAreaHeightBlend(forestID, 2);

		if(rmBuildArea(forestID)==false) {
			// Stop trying once we fail 15 times in a row.
			failCount++;
			if(failCount==15) {
				break;
			}
		} else {
			failCount=0;
		}
	}

	int playerForestCount=6*cNumberNonGaiaPlayers;
	int playerfailCount=0;
	for(i=0; <playerForestCount) {
		int playerForestID=rmCreateArea("playerForest"+i);
		rmSetAreaSize(playerForestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(160));
		rmSetAreaWarnFailure(playerForestID, false);
		rmSetAreaForestType(playerForestID, "mixed oak forest");
		rmAddAreaConstraint(playerForestID, forestTC);
		rmAddAreaConstraint(playerForestID, forestSettleConstraint);
		rmAddAreaConstraint(playerForestID, forestObjConstraint);
		rmAddAreaConstraint(playerForestID, forestConstraint);
		rmAddAreaConstraint(playerForestID, bonusIslandConstraint);
		rmAddAreaConstraint(playerForestID, avoidImpassableLand);
		rmAddAreaToClass(playerForestID, classForest);

		rmSetAreaMinBlobs(playerForestID, 2);
		rmSetAreaMaxBlobs(playerForestID, 4);
		rmSetAreaMinBlobDistance(playerForestID, 16.0);
		rmSetAreaMaxBlobDistance(playerForestID, 20.0);
		rmSetAreaCoherence(playerForestID, 0.0);

		// Hill trees?
		if(rmRandFloat(0.0, 1.0)<0.6) {
			rmSetAreaBaseHeight(playerForestID, rmRandFloat(10.0, 12.0));
		}
		rmSetAreaSmoothDistance(playerForestID, 14);
		rmSetAreaHeightBlend(playerForestID, 2);

		if(rmBuildArea(playerForestID)==false) {
			// Stop trying once we fail 3 times in a row.
			playerfailCount++;
			if(playerfailCount==3) {
				break;
			}
		} else {
			playerfailCount=0;
		}
	}

	rmSetStatusText("",0.93);


	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.

	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, bonusIslandConstraint);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

	int randomTreeID2=rmCreateObjectDef("random tree 2");
	rmAddObjectDefItem(randomTreeID2, "marsh tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID2, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID2, rmCreateTypeDistanceConstraint("random tree two", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID2, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID2, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID2, playerConstraint);
	rmPlaceObjectDefAtLoc(randomTreeID2, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);

	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", rmRandInt(1,2), 0.0);
	rmAddObjectDefItem(logID, "bush", 1, 2.0);
	rmAddObjectDefItem(logID, "grass", rmRandInt(3,5), 2.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidAll);
	rmAddObjectDefConstraint(logID, avoidImpassableLand);
	rmAddObjectDefConstraint(logID, playerConstraint);
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

	int grassesID=rmCreateObjectDef("grasses");
	rmAddObjectDefItem(grassesID, "bush", rmRandInt(1,3), 2.0);
	rmAddObjectDefItem(grassesID, "grass", rmRandInt(3,5), 5.0);
	rmAddObjectDefItem(grassesID, "rock limestone sprite", rmRandInt(2,4), 10.0);
	rmSetObjectDefMinDistance(grassesID, 0.0);
	rmSetObjectDefMaxDistance(grassesID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassesID, avoidAll);
	rmAddObjectDefConstraint(grassesID, avoidImpassableLand);
	rmAddObjectDefConstraint(grassesID, bonusIslandConstraint);
	rmPlaceObjectDefAtLoc(grassesID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

	int reedsID=rmCreateObjectDef("reeds");
	rmAddObjectDefItem(reedsID, "water reeds", rmRandInt(4,6), 2.0);
	rmAddObjectDefItem(reedsID, "rock granite big", rmRandInt(1,3), 3.0);
	rmSetObjectDefMinDistance(reedsID, 0.0);
	rmSetObjectDefMaxDistance(reedsID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(reedsID, avoidAll);
	rmAddObjectDefConstraint(reedsID, nearShore);
	rmPlaceObjectDefAtLoc(reedsID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

	int lilyID=rmCreateObjectDef("pads");
	rmAddObjectDefItem(lilyID, "water lilly", rmRandInt(3,5), 4.0);
	rmSetObjectDefMinDistance(lilyID, 0.0);
	rmSetObjectDefMaxDistance(lilyID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(lilyID, avoidAll);
	//Block movement and don't look so great :-/
	//rmPlaceObjectDefAtLoc(lilyID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);

	int mistID=rmCreateObjectDef("bugs");
	rmAddObjectDefItem(mistID, "mist", 1, 0.0);
	rmSetObjectDefMinDistance(mistID, 0.0);
	rmSetObjectDefMaxDistance(mistID, 60.0);
	rmAddObjectDefConstraint(mistID, avoidAll);
	rmAddObjectDefConstraint(mistID, playerConstraint);
	rmAddObjectDefConstraint(mistID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(mistID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

	rmSetStatusText("",1.0);
}
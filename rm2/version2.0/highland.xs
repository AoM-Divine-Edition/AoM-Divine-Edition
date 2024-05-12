/*	Map Name: Highland.xs
**	Fast-Paced Ruleset: marsh.xs
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
	int playerTiles=9000;
	if(cMapSize == 1) {
		playerTiles = 11700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 18500;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.1*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Set up default water.
	rmSetSeaLevel(1.0);
	rmSetSeaType("Greek River");
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classIsland=rmDefineClass("island");
	int classPlayerCore=rmDefineClass("player core");
	int classForest=rmDefineClass("forest");
	int classShallows=rmDefineClass("shallows");
	int classCliff=rmDefineClass("cliff");
	int classStartingSettlement = rmDefineClass("starting settlement");
	rmDefineClass("center");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.

	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 60.0);
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 60.0);
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1));
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int closeForestConstraint=rmCreateClassDistanceConstraint("closeforest v oakforest", rmClassID("forest"), 6.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int centerID=rmCreateArea("center");
	rmSetAreaSize(centerID, 0.0005, 0.0005);
	if(cMapSize == 2){
		rmSetAreaSize(centerID, 0.00125, 0.00125);
	}
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmSetAreaMinBlobs(centerID, 6*mapSizeMultiplier);
	rmSetAreaMaxBlobs(centerID, 8*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(centerID, 20.0);
	rmSetAreaMaxBlobDistance(centerID, 30.0*mapSizeMultiplier);
	rmSetAreaCoherence(centerID, 0.1);
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmBuildArea(centerID);
	
	// RARE BONUS GOLD ISLAND
	float goldChance=rmRandFloat(0, 1);
	if(cNumberNonGaiaPlayers > 2) {
		if(goldChance < 0.60) {
			int goldIslandID=rmCreateArea("gold island");
			rmSetAreaSize(goldIslandID, rmAreaTilesToFraction(300*mapSizeMultiplier), rmAreaTilesToFraction(400*mapSizeMultiplier));
			rmSetAreaLocation(goldIslandID, 0.5, 0.5);
			rmSetAreaTerrainType(goldIslandID, "GrassDirt25");
			rmSetAreaBaseHeight(goldIslandID, 3.0);
			rmSetAreaSmoothDistance(goldIslandID, 10);
			rmSetAreaHeightBlend(goldIslandID, 2);
			rmSetAreaMinBlobs(goldIslandID, 3*mapSizeMultiplier);
			rmSetAreaMaxBlobs(goldIslandID, 5*mapSizeMultiplier);
			rmSetAreaMinBlobDistance(goldIslandID, 6.0);
			rmSetAreaMaxBlobDistance(goldIslandID, 10.0*mapSizeMultiplier);
			rmSetAreaCoherence(goldIslandID, 0.5);
			rmBuildArea(goldIslandID);
			
			int superGoldID=rmCreateObjectDef("super gold");
			rmAddObjectDefItem(superGoldID, "gold mine", 5, 8.0);
			rmAddObjectDefItem(superGoldID, "bear", 2, 8.0);
			rmSetObjectDefMinDistance(superGoldID, 0.0);
			rmSetObjectDefMaxDistance(superGoldID, 3.0);
			rmAddObjectDefConstraint(superGoldID, rmCreateTerrainDistanceConstraint("tiny avoid impassable land", "Land", false, 2.0));
			rmPlaceObjectDefAtLoc(superGoldID, 0, 0.5, 0.5, 1);
		}
	}
	
	int centerAreaConstraint=rmCreateAreaDistanceConstraint("stay away from lake", centerID, 70);
	
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
	
	if (cNumberNonGaiaPlayers < 3) {
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
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cMapSize == 2){
		rmPlacePlayersCircular(0.35, 0.36, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.4, 0.45, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	for(i=1; <cNumberPlayers) {
		// Create the area.
		int id=rmCreateArea("Player core"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		rmAddAreaToClass(id, classPlayerCore);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaBaseHeight(id, 40.0);
		rmSetAreaLocPlayer(id, i);
		
		rmBuildArea(id);
	}
	
	int islandConstraint=rmCreateClassDistanceConstraint("stay away from islands", classIsland, 30.0);
	
	float playerFraction=rmAreaTilesToFraction(200);
	for(i=1; <cNumberPlayers) {
		// Create the area.
		id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.5, 0.5);
		rmAddAreaToClass(id, classIsland);
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
		if (cNumberNonGaiaPlayers > 2) {
			rmAddAreaConstraint(id, centerConstraint);
		}
		rmSetAreaLocPlayer(id, i);
		rmAddConnectionArea(teamShallowsID, id);
		rmAddConnectionArea(shallowsID, id);
		rmSetAreaTerrainType(id, "GrassA");
		rmAddAreaTerrainLayer(id, "GrassDirt25", 4, 7);
		rmAddAreaTerrainLayer(id, "GrassDirt25", 2, 4);
		rmAddAreaTerrainLayer(id, "GrassDirt25", 0, 2);
	}

	rmBuildAllAreas();
	rmBuildConnection(teamShallowsID);
	rmBuildConnection(shallowsID);
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int failCount=0;
	int numTries1=20*cNumberNonGaiaPlayers;
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
	for(i=0; <numTries1) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
		if(rmRandFloat(0.0, 1.0)<0.7){
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
		
		if(rmBuildArea(elevID)==false){
			// Stop trying once we fail 6 times in a row.
			failCount++;
			if(failCount==6) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	for(i=1; <cNumberPlayers*40*mapSizeMultiplier){
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
	
	for(i=1; <cNumberPlayers*40*mapSizeMultiplier){
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
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
	int avoidSettlement = rmCreateTypeDistanceConstraint("avoid dat settle", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 50.0);
	int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidHerdable = rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 14.0);
	int avoidHuntable = rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	int medAvoidHuntable = rmCreateTypeDistanceConstraint("medium avoid huntable", "huntable", 30.0);
	int avoidImpassableLand = rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	
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
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int closeID = -1;
	int farID = -1;
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			id=rmAddFairLoc("Settlement", false, true, 60, 80, 40, 20, true);
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
				rmSetAreaTerrainType(settleArea, "GrassDirt75");
				rmAddAreaTerrainLayer(settleArea, "GrassA", 0, 8);
				rmAddAreaTerrainLayer(settleArea, "GrassDirt25", 8, 16);
				rmAddAreaTerrainLayer(settleArea, "GrassDirt50", 16, 24);
				rmBuildArea(settleArea);
			}
			rmResetFairLocs();
		
			//Highlands may still be considered a competitive map by some. Use more acurate placement for 2 players.
			id=rmAddFairLoc("Settlement", true, false,  75, 90, 30, 20);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidStart);
			rmAddFairLocConstraint(id, TCavoidWater);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "GrassDirt75");
				rmAddAreaTerrainLayer(settlementArea, "GrassA", 0, 8);
				rmAddAreaTerrainLayer(settlementArea, "GrassDirt25", 8, 16);
				rmAddAreaTerrainLayer(settlementArea, "GrassDirt50", 16, 24);
				rmBuildArea(settlementArea);
			}
			rmResetFairLocs();
		}
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
			for(attempt = 4; <= 12){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 10*attempt);
			}
		
			farID=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			for(attempt = 6; <= 10){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 15*attempt);
			}
		}
	} rmResetFairLocs();
	
	if(cMapSize == 2){
	
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by giant long distance", "AbstractSettlement", 65.0);
	
		//Do a bit of math for giant settlements
		float TCdist = 1.0 / (cNumberNonGaiaPlayers*1.0);
		
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.05), rmXFractionToMeters(TCdist), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.05), rmXFractionToMeters(TCdist), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				for(FL = 0; < 2){
					id=rmCreateObjectDef("Giant settlement_"+p+"_"+FL);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.005, 0.005);
					rmSetAreaTerrainType(settlementArea2, "GrassB");
					rmAddAreaTerrainLayer(settlementArea2, "GrassDirt25", 0, 4);
					rmAddAreaTerrainLayer(settlementArea2, "GrassDirt50", 4, 8);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
				
				farID=rmCreateObjectDef("giant settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 6; <= 12){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 15*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 8; <= 12){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 16*attempt);
				}
			}
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
	rmAddObjectDefItem(startingHuntableID, "deer", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 20.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closePigsID=rmCreateObjectDef("close Pigs");
	rmAddObjectDefItem(closePigsID, "cow", 3, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmAddObjectDefConstraint(closePigsID, huntShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closePigsID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid everything", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3, 7));
	
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
			rmSetAreaForestType(playerStartingForestID, "mixed oak forest");
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
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 25.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("towerfood", "food", 8.0));
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, huntShortAvoidsStartingGoldMilky);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 25;
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
	rmSetObjectDefMinDistance(mediumGoldID, 45.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int closeHippoID=rmCreateObjectDef("close Hippo");
	float hippoNumber=rmRandFloat(0, 1);
	if(hippoNumber<0.3) {
		rmAddObjectDefItem(closeHippoID, "water buffalo", 2, 1.0);
	} else if(hippoNumber<0.6) {
		rmAddObjectDefItem(closeHippoID, "water buffalo", 3, 4.0);
	} else {
		rmAddObjectDefItem(closeHippoID, "water buffalo", 2, 1.0);
	}
	rmSetObjectDefMinDistance(closeHippoID, 40.0);
	rmSetObjectDefMaxDistance(closeHippoID, 45.0);
	rmAddObjectDefConstraint(closeHippoID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeHippoID, avoidSettlement);
	rmAddObjectDefConstraint(closeHippoID, medAvoidHuntable);
	rmAddObjectDefConstraint(closeHippoID, avoidHerdable);
	rmAddObjectDefConstraint(closeHippoID, avoidGold);
	rmPlaceObjectDefPerPlayer(closeHippoID, false);
	
	int numHuntable=rmRandInt(6, 10);
	int mediumDeerID=rmCreateObjectDef("medium gazelles");
	rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 6.0);
	rmSetObjectDefMinDistance(mediumDeerID, 50.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 70.0);
	rmAddObjectDefConstraint(mediumDeerID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumDeerID, avoidSettlement);
	rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumDeerID, medAvoidHuntable);
	rmAddObjectDefConstraint(mediumDeerID, avoidHerdable);
	rmAddObjectDefConstraint(mediumDeerID, avoidGold);
	rmAddObjectDefConstraint(mediumDeerID, avoidAll);
	rmPlaceObjectDefPerPlayer(mediumDeerID, false);
	
	int mediumFarDeerID=rmCreateObjectDef("medium zebra");
	rmAddObjectDefItem(mediumFarDeerID, "deer", numHuntable, 8.0);
	rmSetObjectDefMinDistance(mediumFarDeerID, 55.0);
	rmSetObjectDefMaxDistance(mediumFarDeerID, 60.0);
	rmAddObjectDefConstraint(mediumFarDeerID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumFarDeerID, avoidSettlement);
	rmAddObjectDefConstraint(mediumFarDeerID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumFarDeerID, medAvoidHuntable);
	rmAddObjectDefConstraint(mediumFarDeerID, avoidHerdable);
	rmAddObjectDefConstraint(mediumFarDeerID, avoidGold);
	rmAddObjectDefConstraint(mediumFarDeerID, avoidAll);
	rmPlaceObjectDefPerPlayer(mediumFarDeerID, false);
	
	int mediumCowsID=rmCreateObjectDef("medium cow");
	rmAddObjectDefItem(mediumCowsID, "cow", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance(mediumCowsID, 50.0);
	rmSetObjectDefMaxDistance(mediumCowsID, 70.0);
	rmAddObjectDefConstraint(mediumCowsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumCowsID, avoidSettlement);
	rmAddObjectDefConstraint(mediumCowsID, rmCreateTypeDistanceConstraint("avoid food by more", "food", 25.0));
	rmAddObjectDefConstraint(mediumCowsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumCowsID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumCowsID, false);

	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1,2));
	
	int bonusGoldID=rmCreateObjectDef("gold on bonus islands");
	rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(bonusGoldID, 80.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 105.0);
	rmAddObjectDefConstraint(bonusGoldID, avoidGold);
	rmAddObjectDefConstraint(bonusGoldID, edgeConstraint);
	rmAddObjectDefConstraint(bonusGoldID, avoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(bonusGoldID, false, 1);
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "water buffalo", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(5,6), 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "water buffalo", rmRandInt(3,5), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 40.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 50.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, avoidAll);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false, rmRandInt(1,2));
	
	int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID2, "water buffalo", 2, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID2, "water buffalo", rmRandInt(5,6), 3.0);
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(2,4), 3.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID2, "deer", rmRandInt(6,9), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID2, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID2, 80.0);
	rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidAll);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidGold);
	rmPlaceObjectDefPerPlayer(bonusHuntableID2, false, rmRandInt(1,2));
	
	int bonusHuntableID3=rmCreateObjectDef("bonus huntable3");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID3, "boar", 3, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID3, "deer", rmRandInt(4,6), 3.0);
		if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(bonusHuntableID3, "boar", rmRandInt(2,3), 4.0);
		}
	} else {
		rmAddObjectDefItem(bonusHuntableID3, "water buffalo", 4, 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID3, 80.0);
	rmSetObjectDefMaxDistance(bonusHuntableID3, 100.0);
	rmAddObjectDefConstraint(bonusHuntableID3, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidAll);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID3, avoidGold);
	rmPlaceObjectDefPerPlayer(bonusHuntableID3, false, rmRandInt(1,2));
	
	int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);
	int numCrane=rmRandInt(6, 8);
	int farCraneID=rmCreateObjectDef("far Crane");
	rmAddObjectDefItem(farCraneID, "crowned crane", numCrane, 3.0);
	rmSetObjectDefMinDistance(farCraneID, 85.0);
	rmSetObjectDefMaxDistance(farCraneID, 115.0);
	rmAddObjectDefConstraint(farCraneID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCraneID, avoidGold);
	rmAddObjectDefConstraint(farCraneID, nearShore);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farCraneID, false, rmAreaID("player"+i));
	}
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "cow", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 120.0);
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmAddObjectDefConstraint(farPigsID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(1,2));
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 2, 2.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, closeForestConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 164", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 164", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 55.0);
	rmSetObjectDefMaxDistance(relicID, 200.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, centerConstraint);
	rmAddObjectDefConstraint(relicID, avoidSettlement);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmPlaceObjectDefPerPlayer(relicID, false, rmRandInt(1,2));
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 25.0+(4*cMapSize));
	int fishLand=rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){	
	
		//Do a bit of math for giant resources. >1.0 for a little bit of extra leeway.
		float GiantDist = 1.25 / (cNumberNonGaiaPlayers*1.0);
	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.07));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(GiantDist));
		rmAddObjectDefConstraint(giantGoldID, avoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid golds 164", "gold", 60.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		
		int giantAvoidHuntable = rmCreateTypeDistanceConstraint("giant avoid huntable", "huntable", 50.0);
		bonusChance=rmRandFloat(0, 1);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "water buffalo", 2, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(5,6), 3.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "water buffalo", rmRandInt(3,5), 3.0);
		}
		rmSetObjectDefMinDistance(giantHuntableID, rmXFractionToMeters(0.07));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(GiantDist));
		rmAddObjectDefConstraint(giantHuntableID, avoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, avoidAll);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1,2));
		
		bonusChance=rmRandFloat(0, 1);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable2ID, "water buffalo", 2, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable2ID, "water buffalo", rmRandInt(5,6), 3.0);
			if(rmRandFloat(0,1)<0.5) {
				rmAddObjectDefItem(giantHuntable2ID, "deer", rmRandInt(2,4), 3.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "deer", rmRandInt(6,9), 4.0);
		}
		rmSetObjectDefMinDistance(giantHuntable2ID, rmXFractionToMeters(0.07));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(GiantDist));
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidAll);
		rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1,2));
		
		bonusChance=rmRandFloat(0, 1);
		
		int giantHuntable3ID=rmCreateObjectDef("giant huntable3");
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable3ID, "boar", 3, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable3ID, "deer", rmRandInt(4,6), 3.0);
			if(rmRandFloat(0,1)<0.5) {
				rmAddObjectDefItem(giantHuntable3ID, "boar", rmRandInt(2,3), 4.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntable3ID, "water buffalo", 4, 3.0);
		}
		rmSetObjectDefMinDistance(giantHuntable3ID, rmXFractionToMeters(0.07));
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(GiantDist));
		rmAddObjectDefConstraint(giantHuntable3ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable3ID, avoidAll);
		rmAddObjectDefConstraint(giantHuntable3ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable3ID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHuntable3ID, false, rmRandInt(1,2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.34));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.425));
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidSettlement);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int shortCoreBonusConstraint=rmCreateClassDistanceConstraint("short core v bonus island", classPlayerCore, 40.0);
	int avoidBadlands = rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
	
	int numTries=3*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries){
		int cliffID=rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(180));
		rmSetAreaCliffType(cliffID, "Greek");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaToClass(cliffID, classCliff);
		rmAddAreaConstraint(cliffID, avoidBuildings);
		rmAddAreaConstraint(cliffID, avoidBadlands);
		rmAddAreaConstraint(cliffID, shortCoreBonusConstraint);
		rmAddAreaConstraint(cliffID, avoidAll);
		rmSetAreaMinBlobs(cliffID, 10);
		rmSetAreaMaxBlobs(cliffID, 10);
		rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
		rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
		rmSetAreaTerrainType(cliffID, "cliffGreekA");
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaMinBlobDistance(cliffID, 16.0);
		rmSetAreaMaxBlobDistance(cliffID, 40.0);
		rmSetAreaCoherence(cliffID, 0.25);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		
		if(rmBuildArea(cliffID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	int oakForestConstraint=rmCreateClassDistanceConstraint("oakforest v oakforest", rmClassID("forest"), 30.0);
	
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "AbstractSettlement", 20.0);
	int forestCount=8*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.75*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "mixed oak forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
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
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3*mapSizeMultiplier) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int playerForestCount=8*cNumberNonGaiaPlayers;
	int playerfailCount=0;
	for(i=0; <forestCount) {
		int playerForestID=rmCreateArea("playerForest"+i);
		rmSetAreaSize(playerForestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(160));
		if(cMapSize == 2){
			rmSetAreaSize(playerForestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(260));
		}
		
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
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2*mapSizeMultiplier);

	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "bush", rmRandInt(1,2), 3.0);
	rmAddObjectDefItem(grassID, "grass", rmRandInt(6,8), 6.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmAddObjectDefConstraint(grassID, avoidBuildings);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", 1, 1.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidAll);
	rmAddObjectDefConstraint(logID, avoidImpassableLand);
	rmAddObjectDefConstraint(logID, avoidBuildings);
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rock2ID=rmCreateObjectDef("rock2");
	rmAddObjectDefItem(rock2ID, "rock limestone small", 1, 1.0);
	rmAddObjectDefItem(rock2ID, "rock limestone sprite", 3, 3.0);
	rmSetObjectDefMinDistance(rock2ID, 0.0);
	rmSetObjectDefMaxDistance(rock2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rock2ID, avoidAll);
	rmAddObjectDefConstraint(rock2ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rock2ID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",1.0);
}
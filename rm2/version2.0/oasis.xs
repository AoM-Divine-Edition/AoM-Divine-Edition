/*	Map Name: Oasis.xs
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
	int playerTiles=7500;
	if(cMapSize == 1) {
		playerTiles = 9750;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 19500;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmTerrainInitialize("SandC");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	int classPlayerCore=rmDefineClass("player core");
	int classForest=rmDefineClass("forest");
	int classElev=rmDefineClass("elevation");
	rmDefineClass("center");
	int classMiddle = rmDefineClass("middle");
	int classBerry = rmDefineClass("berry");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 8.0);
	int middleConstraint=rmCreateClassDistanceConstraint("stay away from middle map", rmClassID("middle"), 10.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	rmSetTeamSpacingModifier(0.9);
	rmPlacePlayersSquare(0.4, 0.05, 0.05);
	rmRecordPlayerLocations();
	
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player core"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(110), rmAreaTilesToFraction(110));
		rmAddAreaToClass(id, classPlayerCore);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaLocPlayer(id, i);
	}
	
	int middleID=rmCreateArea("map middle");
	rmSetAreaSize(middleID, 0.04, 0.04);
	rmSetAreaLocation(middleID, 0.5, 0.5);
	rmSetAreaCoherence(middleID, 1.0);
	rmAddAreaToClass(middleID, classMiddle);
	rmBuildArea(middleID);
	
	int forestOneID = 0;
	int forestTwoID = 0;
	int forestThreeID = 0;
	int forestFourID = 0;
	int coreOneID = 0;
	int coreTwoID = 0;
	int coreThreeID = 0;
	int coreFourID = 0;
	
	float oasisChance=rmRandFloat(0, 1);
	int forestNumber =0;
	if(oasisChance < 0.31) {
		// Create a forest
		forestOneID=rmCreateArea("forest one");
		rmSetAreaSize(forestOneID, 0.08, 0.08);
		rmSetAreaLocation(forestOneID, 0.35, 0.65);
		rmSetAreaForestType(forestOneID, "palm forest");
		rmAddAreaToClass(forestOneID, rmClassID("center"));
		rmSetAreaMinBlobs(forestOneID, 1);
		rmSetAreaMaxBlobs(forestOneID, 1);
		rmSetAreaSmoothDistance(forestOneID, 50);
		rmSetAreaCoherence(forestOneID, 0.25);
		rmAddAreaToClass(forestOneID, classForest);
		rmBuildArea(forestOneID);
		
		// Create the core lake
		coreOneID=rmCreateArea("core one");
		rmSetAreaSize(coreOneID, 0.030, 0.030);
		rmSetAreaLocation(coreOneID, 0.35, 0.65);
		rmSetAreaWaterType(coreOneID, "Egyptian Nile");
		rmAddAreaToClass(coreOneID, rmClassID("center"));
		rmSetAreaBaseHeight(coreOneID, 0.0);
		rmSetAreaMinBlobs(coreOneID, 1);
		rmSetAreaMaxBlobs(coreOneID, 1);
		rmSetAreaSmoothDistance(coreOneID, 50);
		rmSetAreaCoherence(coreOneID, 0.25);
		rmBuildArea(coreOneID);
		
		// Create a forest
		forestTwoID=rmCreateArea("forest two");
		rmSetAreaSize(forestTwoID, 0.08, 0.08);
		rmSetAreaLocation(forestTwoID, 0.65, 0.35);
		rmSetAreaForestType(forestTwoID, "palm forest");
		rmAddAreaToClass(forestTwoID, rmClassID("center"));
		rmSetAreaMinBlobs(forestTwoID, 1);
		rmSetAreaMaxBlobs(forestTwoID, 1);
		rmSetAreaSmoothDistance(forestTwoID, 50);
		rmSetAreaCoherence(forestTwoID, 0.25);
		rmAddAreaToClass(forestTwoID, classForest);
		rmBuildArea(forestTwoID);
		
		// Create the core lake
		coreTwoID=rmCreateArea("core two");
		rmSetAreaSize(coreTwoID, 0.030, 0.030);
		rmSetAreaLocation(coreTwoID, 0.65, 0.35);
		rmSetAreaWaterType(coreTwoID, "Egyptian Nile");
		rmAddAreaToClass(coreTwoID, rmClassID("center"));
		rmSetAreaBaseHeight(coreTwoID, 0.0);
		rmSetAreaMinBlobs(coreTwoID, 1);
		rmSetAreaMaxBlobs(coreTwoID, 1);
		rmSetAreaSmoothDistance(coreTwoID, 50);
		rmSetAreaCoherence(coreTwoID, 0.25);
		rmBuildArea(coreTwoID);
		
	}      /* horizontal pair */
	else if(oasisChance < 0.60) {
		// Create a forest
		forestOneID=rmCreateArea("forest one");
		rmSetAreaSize(forestOneID, 0.08, 0.08);
		rmSetAreaLocation(forestOneID, 0.35, 0.35);
		rmSetAreaForestType(forestOneID, "palm forest");
		rmAddAreaToClass(forestOneID, rmClassID("center"));
		rmSetAreaMinBlobs(forestOneID, 1);
		rmSetAreaMaxBlobs(forestOneID, 1);
		rmSetAreaSmoothDistance(forestOneID, 50);
		rmSetAreaCoherence(forestOneID, 0.25);
		rmAddAreaToClass(forestOneID, classForest);
		rmBuildArea(forestOneID);
		
		// Create the core lake
		coreOneID=rmCreateArea("core one");
		rmSetAreaSize(coreOneID, 0.030, 0.030);
		rmSetAreaLocation(coreOneID, 0.35, 0.35);
		rmSetAreaWaterType(coreOneID, "Egyptian Nile");
		rmAddAreaToClass(coreOneID, rmClassID("center"));
		rmSetAreaBaseHeight(coreOneID, 0.0);
		rmSetAreaMinBlobs(coreOneID, 1);
		rmSetAreaMaxBlobs(coreOneID, 1);
		rmSetAreaSmoothDistance(coreOneID, 50);
		rmSetAreaCoherence(coreOneID, 0.25);
		rmBuildArea(coreOneID);
		
		// Create a forest
		forestTwoID=rmCreateArea("forest two");
		rmSetAreaSize(forestTwoID, 0.08, 0.08);
		rmSetAreaLocation(forestTwoID, 0.65, 0.65);
		rmSetAreaForestType(forestTwoID, "palm forest");
		rmAddAreaToClass(forestTwoID, rmClassID("center"));
		rmSetAreaMinBlobs(forestTwoID, 1);
		rmSetAreaMaxBlobs(forestTwoID, 1);
		rmSetAreaSmoothDistance(forestTwoID, 50);
		rmSetAreaCoherence(forestTwoID, 0.25);
		rmAddAreaToClass(forestTwoID, classForest);
		rmBuildArea(forestTwoID);
		
		// Create the core lake
		coreTwoID=rmCreateArea("core two");
		rmSetAreaSize(coreTwoID, 0.030, 0.030);
		rmSetAreaLocation(coreTwoID, 0.65, 0.65);
		rmSetAreaWaterType(coreTwoID, "Egyptian Nile");
		rmAddAreaToClass(coreTwoID, rmClassID("center"));
		rmSetAreaBaseHeight(coreTwoID, 0.0);
		rmSetAreaMinBlobs(coreTwoID, 1);
		rmSetAreaMaxBlobs(coreTwoID, 1);
		rmSetAreaSmoothDistance(coreTwoID, 50);
		rmSetAreaCoherence(coreTwoID, 0.25);
		rmBuildArea(coreTwoID);
	} else {
	/* quad forest */
		// Create a forest
		forestOneID=rmCreateArea("forest one");
		rmSetAreaSize(forestOneID, 0.04, 0.04);
		rmSetAreaLocation(forestOneID, 0.5, 0.7);
		rmSetAreaForestType(forestOneID, "palm forest");
		rmAddAreaToClass(forestOneID, rmClassID("center"));
		rmSetAreaMinBlobs(forestOneID, 1);
		rmSetAreaMaxBlobs(forestOneID, 1);
		rmSetAreaSmoothDistance(forestOneID, 50);
		rmSetAreaCoherence(forestOneID, 0.25);
		rmAddAreaToClass(forestOneID, classForest);
		rmBuildArea(forestOneID);
		
		// Create the core lake
		if(cNumberPlayers > 4){
			coreOneID=rmCreateArea("core one");
			rmSetAreaSize(coreOneID, 0.015, 0.015);
			rmSetAreaLocation(coreOneID, 0.5, 0.7);
			rmSetAreaWaterType(coreOneID, "Egyptian Nile");
			rmAddAreaToClass(coreOneID, rmClassID("center"));
			rmSetAreaBaseHeight(coreOneID, 0.0);
			rmSetAreaMinBlobs(coreOneID, 1);
			rmSetAreaMaxBlobs(coreOneID, 1);
			rmSetAreaSmoothDistance(coreOneID, 50);
			rmSetAreaCoherence(coreOneID, 0.25);
			rmBuildArea(coreOneID);
		}
		
		// Create a forest
		forestTwoID=rmCreateArea("forest two");
		rmSetAreaSize(forestTwoID, 0.04, 0.04);
		rmSetAreaLocation(forestTwoID, 0.7, 0.5);
		rmSetAreaForestType(forestTwoID, "palm forest");
		rmAddAreaToClass(forestTwoID, rmClassID("center"));
		rmSetAreaMinBlobs(forestTwoID, 1);
		rmSetAreaMaxBlobs(forestTwoID, 1);
		rmSetAreaSmoothDistance(forestTwoID, 50);
		rmSetAreaCoherence(forestTwoID, 0.25);
		rmAddAreaToClass(forestTwoID, classForest);
		rmBuildArea(forestTwoID);
		
		// Create the core lake
		if(cNumberPlayers > 4) {
			coreTwoID=rmCreateArea("core two");
			rmSetAreaSize(coreTwoID, 0.015, 0.015);
			rmSetAreaLocation(coreTwoID, 0.7, 0.5);
			rmSetAreaWaterType(coreTwoID, "Egyptian Nile");
			rmAddAreaToClass(coreTwoID, rmClassID("center"));
			rmSetAreaBaseHeight(coreTwoID, 0.0);
			rmSetAreaMinBlobs(coreTwoID, 1);
			rmSetAreaMaxBlobs(coreTwoID, 1);
			rmSetAreaSmoothDistance(coreTwoID, 50);
			rmSetAreaCoherence(coreTwoID, 0.25);
			rmBuildArea(coreTwoID);
		}
		
		// Create a forest
		forestThreeID=rmCreateArea("forest three");
		rmSetAreaSize(forestThreeID, 0.04, 0.04);
		rmSetAreaLocation(forestThreeID, 0.5, 0.3);
		rmSetAreaForestType(forestThreeID, "palm forest");
		rmAddAreaToClass(forestThreeID, rmClassID("center"));
		rmSetAreaMinBlobs(forestThreeID, 1);
		rmSetAreaMaxBlobs(forestThreeID, 1);
		rmSetAreaSmoothDistance(forestThreeID, 50);
		rmSetAreaCoherence(forestThreeID, 0.25);
		rmAddAreaToClass(forestThreeID, classForest);
		rmBuildArea(forestThreeID);
		
		// Create the core lake
		if(cNumberPlayers > 4) {
			coreThreeID=rmCreateArea("core three");
			rmSetAreaSize(coreThreeID, 0.015, 0.015);
			rmSetAreaLocation(coreThreeID, 0.5, 0.3);
			rmSetAreaWaterType(coreThreeID, "Egyptian Nile");
			rmAddAreaToClass(coreThreeID, rmClassID("center"));
			rmSetAreaBaseHeight(coreThreeID, 0.0);
			rmSetAreaMinBlobs(coreThreeID, 1);
			rmSetAreaMaxBlobs(coreThreeID, 1);
			rmSetAreaSmoothDistance(coreThreeID, 50);
			rmSetAreaCoherence(coreThreeID, 0.25);
			rmBuildArea(coreThreeID);
		}
		
		// Create a forest
		forestFourID=rmCreateArea("forest four");
		rmSetAreaSize(forestFourID, 0.04, 0.04);
		rmSetAreaLocation(forestFourID, 0.3, 0.5);
		rmSetAreaForestType(forestFourID, "palm forest");
		rmAddAreaToClass(forestFourID, rmClassID("center"));
		rmSetAreaMinBlobs(forestFourID, 1);
		rmSetAreaMaxBlobs(forestFourID, 1);
		rmSetAreaSmoothDistance(forestFourID, 50);
		rmSetAreaCoherence(forestFourID, 0.25);
		rmAddAreaToClass(forestFourID, classForest);
		rmBuildArea(forestFourID);
		
		// Create the core lake
		if(cNumberPlayers > 4) {
			coreFourID=rmCreateArea("core four");
			rmSetAreaSize(coreFourID, 0.015, 0.015);
			rmSetAreaLocation(coreFourID, 0.3, 0.5);
			rmSetAreaWaterType(coreFourID, "Egyptian Nile");
			rmAddAreaToClass(coreFourID, rmClassID("center"));
			rmSetAreaBaseHeight(coreFourID, 0.0);
			rmSetAreaMinBlobs(coreFourID, 1);
			rmSetAreaMaxBlobs(coreFourID, 1);
			rmSetAreaSmoothDistance(coreFourID, 50);
			rmSetAreaCoherence(coreFourID, 0.25);
			rmBuildArea(coreFourID);
		}
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	int playerCenterConstraint=rmCreateClassDistanceConstraint("player areas from center", rmClassID("center"), 12.0);
	float playerFraction=rmAreaTilesToFraction(3000);
	for(i=1; <cNumberPlayers) {
		id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaCoherence(id, 0.0);
		rmAddAreaConstraint(id, playerCenterConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SandDirt50");
		rmAddAreaTerrainLayer(id, "SandA", 1, 2);
		rmAddAreaTerrainLayer(id, "SandB", 0, 1);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers*5) {
		int id2=rmCreateArea("patch A"+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		rmSetAreaTerrainType(id2, "SandD");
		rmSetAreaMinBlobs(id2, 1);
		rmSetAreaMaxBlobs(id2, 5);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0);
		rmSetAreaCoherence(id2, 0.0);
		rmAddAreaConstraint(id2, centerConstraint);
		rmAddAreaConstraint(id2, avoidBuildings);
		rmBuildArea(id2);
	}
	
	int numTries=10*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, centerConstraint);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SandD");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 6.0));
		rmSetAreaHeightBlend(elevID, 2);
		rmAddAreaToClass(id, classElev);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==6) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int elevConstraint=rmCreateClassDistanceConstraint("elev avoid elev", rmClassID("elevation"), 10.0);
	numTries=20*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 3.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SandD");
		}
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, centerConstraint);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmAddAreaToClass(elevID, classElev);
		rmAddAreaConstraint(elevID, elevConstraint);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==10) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	numTries=8*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier) {
		int rockyID=rmCreateArea("rocky terrain"+i);
		rmSetAreaSize(rockyID, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		rmSetAreaWarnFailure(rockyID, false);
		rmSetAreaMinBlobs(rockyID, 1);
		rmSetAreaMaxBlobs(rockyID, 1);
		rmSetAreaTerrainType(rockyID, "SavannahC");
		rmAddAreaTerrainLayer(rockyID, "SandA", 0, 2);
		rmSetAreaBaseHeight(rockyID, rmRandFloat(2.0, 5.0));
		rmSetAreaMinBlobDistance(rockyID, 16.0);
		rmSetAreaMaxBlobDistance(rockyID, 20.0);
		rmSetAreaCoherence(rockyID, 1.0);
		rmSetAreaSmoothDistance(rockyID, 10);
		rmAddAreaConstraint(rockyID, centerConstraint);
		rmAddAreaConstraint(rockyID, avoidBuildings);
		rmAddAreaConstraint(rockyID, avoidImpassableLand);
		rmAddAreaConstraint(rockyID, elevConstraint);
		
		if(rmBuildArea(rockyID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==10) {
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
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));

	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int avoidSettlement=rmCreateTypeDistanceConstraint("gold avoids TC by short distance", "AbstractSettlement", 30.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar = rmCreateTypeDistanceConstraint("far avoid food sources", "food", 25.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree avoid", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree avoid gold", "gold", 6.0);
	
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
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 40.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	int TCforest = rmCreateClassDistanceConstraint("TC v forest", rmClassID("forest"), 20.0);
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 50, 16, true); /* bool forward bool inside */
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCforest);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "SandDirt50");
				rmAddAreaTerrainLayer(settleArea, "SandA", 1, 2);
				rmAddAreaTerrainLayer(settleArea, "SandB", 0, 1);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCforest);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt);
				}
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false,  75, 85, 80, 16);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCforest);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "SandDirt50");
				rmAddAreaTerrainLayer(settlementArea, "SandA", 1, 2);
				rmAddAreaTerrainLayer(settlementArea, "SandB", 0, 1);
				rmBuildArea(settlementArea);
			} else {
				int farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCforest);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt);
				}
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		id=rmAddFairLoc("2player+ close Settlement", false, true, 60, 75, 50, 20);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("close 2p+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers) {
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
		rmResetFairLocs();
		
		id=rmAddFairLoc("2player+ far Settlement", true, false, 75, 105, 80, 60);
		rmAddFairLocConstraint(id, TCavoidWater);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("far 2p+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers) {
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.38), 40, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCavoidWater);
		rmAddFairLocConstraint(id, TCforest);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea2, "SandDirt50");
			rmAddAreaTerrainLayer(settlementArea2, "SandA", 1, 2);
			rmAddAreaTerrainLayer(settlementArea2, "SandB", 0, 1);
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
	
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "zebra", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 22.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, shortAvoidGold);
	rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 18.0));
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("hunt avoid towers", "tower", 4.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closeGoatsID=rmCreateObjectDef("close goats");
	rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
	rmSetObjectDefMinDistance(closeGoatsID, 25.0);
	rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
	rmAddObjectDefConstraint(closeGoatsID, getOffTheTC);
	rmAddObjectDefConstraint(closeGoatsID, centerConstraint);
	rmAddObjectDefConstraint(closeGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(closeGoatsID, avoidFood);
	rmAddObjectDefConstraint(closeGoatsID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(closeGoatsID, true);
	
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(6,8), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 21.0);
	rmSetObjectDefMaxDistance(startingChickenID, 22.0);
	rmAddObjectDefConstraint(startingChickenID, rmCreateTypeDistanceConstraint("Y U spawn on TC", "AbstractSettlement", 18.0));
	rmAddObjectDefConstraint(startingChickenID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidGold);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	int playerForestForest=rmCreateClassDistanceConstraint("player forest v forest", rmClassID("forest"), 15.0);
	
	int maxNum = 3;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "palm forest");
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, playerForestForest);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaConstraint(playerStartingForestID, stragglerTreeAvoid);
			rmAddAreaConstraint(playerStartingForestID, stragglerTreeAvoidGold);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.25);
			rmBuildArea(playerStartingForestID);
		}
	}
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 25.0);
	rmSetObjectDefMaxDistance(startingTowerID, 27.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, shortAvoidGold);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 27;
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
	
	int goldVgold = rmCreateTypeDistanceConstraint("goldAvoidsGold", "gold", 40.0);
	
	int goldAccuracy = 25;
	if(cNumberNonGaiaPlayers >= 8){
		goldAccuracy = 4;
	} else if(cNumberNonGaiaPlayers >= 6){
		goldAccuracy = 8;
	} else if(cNumberNonGaiaPlayers >= 3){
		goldAccuracy = 12;
	}
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 58.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 59.0);
	rmAddObjectDefConstraint(mediumGoldID, goldVgold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, centerConstraint);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	increment = 59;
	for(p = 1; <= cNumberNonGaiaPlayers){
		rmSetObjectDefMaxDistance(mediumGoldID, increment);
		rmPlaceObjectDefAtLoc(mediumGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(mediumGoldID) < (p*2)){	//Will always be true for 2+.
			for(goldAttempts = 0; < goldAccuracy){
				rmSetObjectDefMaxDistance(mediumGoldID, increment + 5*goldAttempts);
				rmPlaceObjectDefAtLoc(mediumGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(mediumGoldID) >= (p*2)){
					break;
				}
			}
		}
	}
	
	int mediumGoatsID=rmCreateObjectDef("medium Goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", rmRandInt(1,3), 4.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, avoidGold);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGoatsID, centerConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false, 1);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).	
	
	goldAccuracy = 150;
	if(cNumberNonGaiaPlayers >= 8){
		goldAccuracy = 5;
	} else if(cNumberNonGaiaPlayers >= 6){
		goldAccuracy = 10;
	} else if(cNumberNonGaiaPlayers >= 3){
		goldAccuracy = 20+cNumberNonGaiaPlayers;
	}
	
	goldVgold = rmCreateTypeDistanceConstraint("goldAvoidsGold2", "gold", 60.0);
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 95.0);
	rmSetObjectDefMaxDistance(farGoldID, 115.0);
	if(cNumberNonGaiaPlayers == 2){
		rmAddObjectDefConstraint(farGoldID, rmCreateClassDistanceConstraint("far away from middle", rmClassID("middle"), 25.0));
	}
	rmAddObjectDefConstraint(farGoldID, goldVgold);
	rmAddObjectDefConstraint(farGoldID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farGoldID, centerConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	increment = 115.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		rmSetObjectDefMaxDistance(farGoldID, increment);
		rmPlaceObjectDefAtLoc(farGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(farGoldID) < p){	//Will always be true for 2+.
			for(goldAttempts = 0; < goldAccuracy){
				rmSetObjectDefMaxDistance(farGoldID, increment + 10*goldAttempts);
				rmPlaceObjectDefAtLoc(farGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farGoldID) >= (p*2)){
					break;
				}
			}
		}
	}
	
	goldVgold = rmCreateTypeDistanceConstraint("goldAvoidsGoldsuper", "gold", 70.0);
	
	int superFarGoldID=rmCreateObjectDef("super far gold");
	rmAddObjectDefItem(superFarGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(superFarGoldID, 120.0);
	rmSetObjectDefMaxDistance(superFarGoldID, 135.0);
	if(cNumberNonGaiaPlayers == 2){
		rmAddObjectDefConstraint(superFarGoldID, rmCreateClassDistanceConstraint("far away from middle", rmClassID("middle"), 25.0));
	}
	rmAddObjectDefConstraint(superFarGoldID, goldVgold);
	rmAddObjectDefConstraint(superFarGoldID, shortEdgeConstraint);
	rmAddObjectDefConstraint(superFarGoldID, centerConstraint);
	rmAddObjectDefConstraint(superFarGoldID, avoidSettlement);
	rmAddObjectDefConstraint(superFarGoldID, farStartingSettleConstraint);
	increment = -1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		increment = 135.0;
		rmSetObjectDefMaxDistance(superFarGoldID, increment);
		rmPlaceObjectDefAtLoc(superFarGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(superFarGoldID) < (p*2)){	//Will always be true for 2+.
			for(goldAttempts = 0; < goldAccuracy){
				if(goldAttempts % 2 == 0){
					increment++;
					rmSetObjectDefMaxDistance(superFarGoldID, increment);
				}
				rmPlaceObjectDefAtLoc(superFarGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(superFarGoldID) >= (p*2)){
					break;
				}
			}
		}
	}
	
	int superAvoidFood = rmCreateTypeDistanceConstraint("super far avoid food sources", "huntable", 45.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(4,5), 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,5), 2.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 70.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 90.0);
	rmAddObjectDefConstraint(bonusHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, superAvoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, centerConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, middleConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	if(rmRandFloat(0,1)>0.5){
		int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(bonusHuntableID2, "gazelle", rmRandInt(4,5), 2.0);
		} else {
			rmAddObjectDefItem(bonusHuntableID2, "giraffe", rmRandInt(3,5), 2.0);
		}
		rmSetObjectDefMinDistance(bonusHuntableID2, 90.0);
		rmSetObjectDefMaxDistance(bonusHuntableID2, 120.0);
		rmAddObjectDefConstraint(bonusHuntableID2, shortEdgeConstraint);
		rmAddObjectDefConstraint(bonusHuntableID2, avoidSettlement);
		rmAddObjectDefConstraint(bonusHuntableID2, avoidGold);
		rmAddObjectDefConstraint(bonusHuntableID2, superAvoidFood);
		rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
		rmAddObjectDefConstraint(bonusHuntableID2, centerConstraint);
		rmAddObjectDefConstraint(bonusHuntableID2, middleConstraint);
		rmPlaceObjectDefPerPlayer(bonusHuntableID2, false);
	}
	
	int farMonkeyID=rmCreateObjectDef("far monkeys");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(farMonkeyID, "baboon", rmRandInt(5,6), 3.0);
	} else {
		rmAddObjectDefItem(farMonkeyID, "monkey", rmRandInt(6,8), 3.0);
	}
	rmSetObjectDefMinDistance(farMonkeyID, 75.0);
	rmSetObjectDefMaxDistance(farMonkeyID, 90.0);
	rmAddObjectDefConstraint(farMonkeyID, avoidGold);
	rmAddObjectDefConstraint(farMonkeyID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farMonkeyID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farMonkeyID, centerConstraint);
	rmAddObjectDefConstraint(farMonkeyID, avoidFoodFar);
	rmAddObjectDefConstraint(farMonkeyID, avoidSettlement);
	if(rmRandFloat(0,1)<0.70) {
		rmPlaceObjectDefPerPlayer(farMonkeyID, false, 1);
	}
	
	int avoidHerd = rmCreateTypeDistanceConstraint("avoid herdy", "herdable", 35.0);
	
	int farGoatsID=rmCreateObjectDef("far Goats");
	rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 95.0);
	rmSetObjectDefMaxDistance(farGoatsID, 125.0);
	rmAddObjectDefConstraint(farGoatsID, avoidGold);
	rmAddObjectDefConstraint(farGoatsID, avoidHerd);
	rmAddObjectDefConstraint(farGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(farGoatsID, centerConstraint);
	rmAddObjectDefConstraint(farGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(farGoatsID, 0, rmGetPlayerX(i), rmGetPlayerZ(i), 3);
	}
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(5,9), 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 95.0);
	rmSetObjectDefMaxDistance(farBerriesID, 125.0);
	rmAddAreaToClass(farBerriesID, classBerry);
	rmAddObjectDefConstraint(farBerriesID, rmCreateClassDistanceConstraint("berry v berry", classBerry, 30.0));
	rmAddObjectDefConstraint(farBerriesID, centerConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, forestTower);
	rmAddObjectDefConstraint(farBerriesID, avoidFoodFar);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "hyena", 3, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateClassDistanceConstraint("preds avoid player TCs", rmClassID("starting settlement"), 75.0));
	rmAddObjectDefConstraint(farPredatorID, centerConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidFoodFar);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 110", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, farAvoidSettlement);
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 75.0);
	rmSetObjectDefMaxDistance(relicID, 125.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 90.0));
	rmAddObjectDefConstraint(relicID, farAvoidSettlement);
	rmAddObjectDefConstraint(relicID, centerConstraint);
	rmPlaceObjectDefPerPlayer(relicID, false, 1);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantGoldID, avoidFoodFar);
		rmAddObjectDefConstraint(giantGoldID, edgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, farAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 110", "gold", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 2);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "gazelle", rmRandInt(5,6), 5.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "giraffe", rmRandInt(5,6), 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, rmCreateTypeDistanceConstraint("super far avoid food sources2", "food", 45.0));
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.325));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, centerConstraint);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, 1);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 100.0));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, avoidFood);
		rmAddObjectDefConstraint(giantRelixID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, farAvoidSettlement);
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
	
	int forestCount=7*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <forestCount){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(25*mapSizeMultiplier), rmAreaTilesToFraction(75*mapSizeMultiplier));
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "palm forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidBuildings);
		rmAddAreaConstraint(forestID, centerConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmBuildArea(forestID)==false){
			// Stop trying once we fail 7 times in a row.
			failCount++;
			if(failCount==7) {
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
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, centerConstraint);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 7*cNumberNonGaiaPlayers);
	
	int randomTreeID2=rmCreateObjectDef("random tree 2");
	rmAddObjectDefItem(randomTreeID2, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID2, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID2, rmCreateTypeDistanceConstraint("random tree 2", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID2, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID2, centerConstraint);
	rmPlaceObjectDefAtLoc(randomTreeID2, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int deerID=rmCreateObjectDef("lonely deer");
	if(rmRandFloat(0,1)<0.33) {
		rmAddObjectDefItem(deerID, "monkey", rmRandInt(1,2), 1.0);
	} else if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(deerID, "zebra", 1, 0.0);
	} else {
		rmAddObjectDefItem(deerID, "gazelle", 1, 0.0);
	}
	rmSetObjectDefMinDistance(deerID, 0.0);
	rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(deerID, avoidAll);
	rmAddObjectDefConstraint(deerID, avoidBuildings);
	rmAddObjectDefConstraint(deerID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	int bushID=rmCreateObjectDef("big bush patch");
	rmAddObjectDefItem(bushID, "bush", 4, 3.0);
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID, avoidAll);
	rmAddObjectDefConstraint(bushID, centerConstraint);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int bush2ID=rmCreateObjectDef("small bush patch");
	rmAddObjectDefItem(bush2ID, "bush", 3, 2.0);
	rmAddObjectDefItem(bush2ID, "rock sandstone sprite", 1, 2.0);
	rmSetObjectDefMinDistance(bush2ID, 0.0);
	rmSetObjectDefMaxDistance(bush2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bush2ID, avoidAll);
	rmAddObjectDefConstraint(bush2ID, centerConstraint);
	rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 1, 0.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, centerConstraint);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int driftVsDrift=rmCreateTypeDistanceConstraint("drift vs drift", "sand drift dune", 25.0);
	int sandDrift=rmCreateObjectDef("blowing sand");
	rmAddObjectDefItem(sandDrift, "sand drift patch", 1, 0.0);
	rmSetObjectDefMinDistance(sandDrift, 0.0);
	rmSetObjectDefMaxDistance(sandDrift, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(sandDrift, avoidAll);
	rmAddObjectDefConstraint(sandDrift, centerConstraint);
	rmAddObjectDefConstraint(sandDrift, edgeConstraint);
	rmAddObjectDefConstraint(sandDrift, driftVsDrift);
	rmAddObjectDefConstraint(sandDrift, avoidBuildings);
	rmPlaceObjectDefAtLoc(sandDrift, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",1.0);
}
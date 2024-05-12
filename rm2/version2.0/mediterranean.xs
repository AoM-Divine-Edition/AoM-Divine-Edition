/*	Map Name: Mediterranean.xs
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
	int playerTiles=7750;
	if(cMapSize == 1){
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
	rmSetSeaType("mediterranean sea");
	rmTerrainInitialize("GrassDirt25");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	rmDefineClass("classHill");
	rmDefineClass("center");
	int classForest=rmDefineClass("forest");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classBackward = rmDefineClass("Backward TC");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	//No Global Constraints for Mediterranean
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int centerID=rmCreateArea("center");
	if(cNumberNonGaiaPlayers <= 2){
		rmSetAreaSize(centerID, 0.28, 0.28);
	} else if(cNumberNonGaiaPlayers <= 8){
		rmSetAreaSize(centerID, 0.29, 0.29);
	} else {
		rmSetAreaSize(centerID, 0.3, 0.3);
	}
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmSetAreaWaterType(centerID, "mediterranean sea");
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmSetAreaBaseHeight(centerID, 0.0);
	rmSetAreaMinBlobs(centerID, 10*mapSizeMultiplier);
	rmSetAreaMaxBlobs(centerID, 12*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(centerID, 10);
	rmSetAreaMaxBlobDistance(centerID, 20);
	rmSetAreaSmoothDistance(centerID, 50);
	rmSetAreaCoherence(centerID, 0.35);
	rmBuildArea(centerID);
	
	float monkeyChance=rmRandFloat(0, 1);
	if(cNumberPlayers > 3) {
		if(monkeyChance < 0.66) {
			int monkeyIslandID=rmCreateArea("monkeyisland");
			rmSetAreaSize(monkeyIslandID, rmAreaTilesToFraction(300*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
			rmSetAreaLocation(monkeyIslandID, 0.5, 0.5);
			rmSetAreaTerrainType(monkeyIslandID, "shorelinemediterraneanb");
			rmSetAreaBaseHeight(monkeyIslandID, 2.0);
			rmSetAreaSmoothDistance(monkeyIslandID, 10);
			rmSetAreaHeightBlend(monkeyIslandID, 2);
			rmSetAreaCoherence(monkeyIslandID, 1.0);
			rmBuildArea(monkeyIslandID);
			
			int monkeyID=rmCreateObjectDef("monkey");
			rmAddObjectDefItem(monkeyID, "baboon", 1, 2.0);
			rmAddObjectDefItem(monkeyID, "palm", 1, 2.0);
			rmAddObjectDefItem(monkeyID, "gold mine", 1, 8.0);
			rmSetObjectDefMinDistance(monkeyID, 0.0);
			rmSetObjectDefMinDistance(monkeyID, 20.0);
			rmPlaceObjectDefAtLoc(monkeyID, 0, 0.5, 0.5);
		}
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	rmSetTeamSpacingModifier(0.75);
	if(cNumberNonGaiaPlayers <4) {
		rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.43, 0.45, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30.0);
	int smallMapPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a lot", classPlayer, 70.0);
	float playerFraction=rmAreaTilesToFraction(1450);
	for(i=1; <cNumberPlayers){
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 4);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobDistance(id, 5.0);
		rmSetAreaMaxBlobDistance(id, 10.0);
		rmSetAreaSmoothDistance(id, 20);
		rmSetAreaCoherence(id, 0.75);
		rmSetAreaBaseHeight(id, 0.0);
		rmSetAreaHeightBlend(id, 2);
		rmAddAreaConstraint(id, playerConstraint);
		if(cNumberNonGaiaPlayers < 4) {
			rmAddAreaConstraint(id, smallMapPlayerConstraint);
		}
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "grassDirt25");
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 15.0);
	
	for(i=1; <cNumberPlayers) {
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, "GrassDirt50");
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		rmAddAreaConstraint(id2, centerConstraint);
		
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier) {
		int id3=rmCreateArea("Grass patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "GrassA");
		rmAddAreaConstraint(id3, centerConstraint);
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		
		rmBuildArea(id3);
	}
	
	int flowerID =0;
	int id4 = 0;
	int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", id4, 4.0);
	for(i=1; <cNumberPlayers*6*mapSizeMultiplier) {
		id4=rmCreateArea("Grass patch 2"+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(5*mapSizeMultiplier), rmAreaTilesToFraction(20*mapSizeMultiplier));
		rmSetAreaTerrainType(id4, "GrassB");
		rmAddAreaConstraint(id4, centerConstraint);
		rmSetAreaMinBlobs(id4, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id4, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id4, false);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id4, 0.0);
		
		rmBuildArea(id4);
		
		flowerID=rmCreateObjectDef("grass"+i);
		rmAddObjectDefItem(flowerID, "grass", rmRandFloat(2,4), 5.0);
		rmAddObjectDefItem(flowerID, "flowers", rmRandInt(0,6), 5.0);
		rmAddObjectDefConstraint(flowerID, stayInPatch);
		rmSetObjectDefMinDistance(flowerID, 0.0);
		rmSetObjectDefMaxDistance(flowerID, 0.0);
		rmPlaceObjectDefInArea(flowerID, 0, rmAreaID("grass patch 2"+i), 1);
	}
	
	int numTries=6*cNumberNonGaiaPlayers;
	int smallPlayerConstraint=rmCreateClassDistanceConstraint("small away from players", classPlayer, 1.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaToClass(elevID, rmClassID("classHill"));
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, centerConstraint);
		rmAddAreaConstraint(elevID, smallPlayerConstraint);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "GrassDirt50");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaHeightBlend(elevID, 3);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 10 times in a row.
			failCount++;
			if(failCount==10) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 10.0);
	numTries=15*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, smallPlayerConstraint);
		rmAddAreaConstraint(elevID, centerConstraint);
		rmAddAreaConstraint(elevID, shortHillConstraint);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 10 times in a row.
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
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 35.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
	int farAvoidFood=rmCreateTypeDistanceConstraint("far avoid other food sources", "food", 20.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree avoid", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree avoid gold", "gold", 6.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 16.0);
	
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
	rmAddFairLocConstraint(startingGoldFairLocID, farAvoidImpassableLand);
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
	
	int TCavoidSettlement = -1;
	if(cNumberNonGaiaPlayers == 2){
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 60.0);
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 55.0);
	}
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 50.0);
	int TCavoidBack = rmCreateClassDistanceConstraint("TC avoid back TC", classBackward, 75.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 20.0);
	int TCedge = rmCreateBoxConstraint("TC edge of map", rmXTilesToFraction(10), rmZTilesToFraction(10), 1.0-rmXTilesToFraction(10), 1.0-rmZTilesToFraction(10));
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 16, 16, false, false); /* bool forward bool inside */
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCedge);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(id, classBackward);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "GrassDirt50");
				rmAddAreaTerrainLayer(settleArea, "GrassDirt25", 2, 5);
				rmAddAreaTerrainLayer(settleArea, "GrassB", 0, 2);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(closeID, classBackward);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				rmAddObjectDefConstraint(closeID, TCedge);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt);
				}
				//rmEchoError("How do these things even fail?");
				//chat(true, "<color=1,0,0>Function rmPlaceFairLocs() failed!", true, -1, true);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false,  80, 100, 16, 16, false, false);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCavoidBack);
			rmAddFairLocConstraint(id, TCedge);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "GrassDirt50");
				rmAddAreaTerrainLayer(settlementArea, "GrassDirt25", 2, 5);
				rmAddAreaTerrainLayer(settlementArea, "GrassB", 0, 2);
				rmBuildArea(settlementArea);
			} else {
				farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidBack);
				rmAddObjectDefConstraint(farID, TCedge);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt);
				}
				//rmEchoError("How do these things even fail?");
				//chat(true, "<color=1,0,0>Function rmPlaceFairLocs() failed!", true, -1, true);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		id=rmAddFairLoc("2player+ close Settlement", false, true, 55, 70, 50, 20);
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
		
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TCs avoid TCs long distance", "AbstractSettlement", 70.0);
		
		id=rmAddFairLoc("2player+ far Settlement", true, false, 75, 110+(2*cNumberNonGaiaPlayers), 65, 20);
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
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
				farID=rmCreateObjectDef("far 2p+ settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmSetObjectDefMinDistance(farID, 50.0);
				rmSetObjectDefMaxDistance(farID, 75.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, TCedge);
				for(attempt = 1; < 25){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 75+10*attempt);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.38), 80, 20);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidWater);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea2, "GrassDirt50");
			rmAddAreaTerrainLayer(settlementArea2, "GrassDirt25", 2, 5);
			rmAddAreaTerrainLayer(settlementArea2, "GrassB", 0, 2);
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
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	if(rmRandFloat(0.0, 1.0) < 0.7){
		rmAddObjectDefItem(startingHuntableID, "boar", rmRandInt(3,4), 3.0);
	} else {
		rmAddObjectDefItem(startingHuntableID, "aurochs", 2, 2.0);
	}
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 29.0);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 25.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int closePigsID=rmCreateObjectDef("close pigs");
	rmAddObjectDefItem(closePigsID, "pig", rmRandFloat(3, 4), 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmAddObjectDefConstraint(closePigsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(closePigsID, huntShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closePigsID, true);

	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(6,8), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2,6));
	
	int playerFishID=rmCreateObjectDef("owned fish");
	//rmAddObjectDefItem(playerFishID, "fish - Perch", 3, 8.0);
	rmAddObjectDefItem(playerFishID, "fish - Salmon", 3, 8.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 5.0*cNumberNonGaiaPlayers);
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainDistanceConstraint("fish vs land", "land", true, 4.0));
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainMaxDistanceConstraint("fish close to land", "land", true, 10.0));
	
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 5.0*cNumberNonGaiaPlayers;
		rmSetObjectDefMaxDistance(playerFishID, increment);
		while( rmGetNumberUnitsPlaced(playerFishID) < (3*p) ){
			rmPlaceObjectDefAtLoc(playerFishID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			placement++;
			if(placement % 2 == 0){
				increment++;
				rmSetObjectDefMaxDistance(playerFishID, increment);
			}
		}
	}
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 3;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum+2);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "mixed oak forest");
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
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 20.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 20.0);
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, huntShortAvoidsStartingGoldMilky);
	placement = 1;
	increment = 1.0;
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
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 1.0);
	rmSetObjectDefMinDistance(mediumGoldID, 55.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 62.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 50.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
	rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, avoidGold);
	rmAddObjectDefConstraint(mediumPigsID, avoidHerdable);
	rmAddObjectDefConstraint(mediumPigsID, farAvoidFood);
	rmAddObjectDefConstraint(mediumPigsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumPigsID, false, 2);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 28.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 11.0+(cNumberNonGaiaPlayers/2));
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, 0.0);
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1);
	
	int maxNumFish = 9*cNumberNonGaiaPlayers;
	if(rmGetNumberUnitsPlaced(fishID) < (p*maxNumFish)){
		for(goldAttempts = 0; < maxNumFish+cNumberNonGaiaPlayers+2){
			rmSetObjectDefMaxDistance(fishID, 2*goldAttempts);
			rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1);
			if(rmGetNumberUnitsPlaced(fishID) >= maxNumFish){
				break;
			}
		}
	}
	
	fishID=rmCreateObjectDef("fish2");
	rmAddObjectDefItem(fishID, "fish - perch", 3, 6.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	if(cNumberNonGaiaPlayers == 2){
		rmAddObjectDefConstraint(fishID, rmCreateTypeDistanceConstraint("fish v fish2", "fish", 18.0));
		rmAddObjectDefConstraint(fishID, rmCreateTerrainDistanceConstraint("fish land2", "land", true, 10.0));
	} else {
		rmAddObjectDefConstraint(fishID, fishVsFishID);
		rmAddObjectDefConstraint(fishID, fishLand);
	}
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator, berries).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 65.0);
	rmSetObjectDefMaxDistance(farGoldID, 110.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, farAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 3);
	
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(2,3), 4.0);
	} else if(bonusChance<0.8) {
		rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(6,8), 8.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "aurochs", rmRandInt(1,3), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 65.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 75.0+(cNumberNonGaiaPlayers*2-4));
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, farAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 125.0);
	rmAddObjectDefConstraint(farPigsID, edgeConstraint);
	rmAddObjectDefConstraint(farPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, farAvoidFood);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farPigsID, false, 3);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 75.0);
	rmSetObjectDefMaxDistance(farPredatorID, 105.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 30.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 123", "gold", 50.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 123", "AbstractSettlement", 50.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 9, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, rmXFractionToMeters(0.26));
	rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.29));
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farBerriesID, farAvoidFood);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers);

	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 75.0);
	rmSetObjectDefMaxDistance(relicID, 110.0);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, shortEdgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTerrainDistanceConstraint("short relic avoid impassable land", "land", false, 4.0));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 123", "gold", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "boar", rmRandInt(2,3), 4.0);
		} else if(bonusChance<0.8) {
			rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(6,8), 8.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "aurochs", rmRandInt(1,3), 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.34));
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHerdableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "AbstractSettlement", 20.0);
	
	int forestCount=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(125), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaForestType(forestID, "oak forest");
		} else {
			rmSetAreaForestType(forestID, "pine forest");
		}
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, farAvoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
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
	rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 8.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
	int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
	int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
	int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);
	
	int sharkID=rmCreateObjectDef("shark");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
	} else {
		rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
	}
	rmSetObjectDefMinDistance(sharkID, 0.0);
	rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(sharkID, sharkVssharkID);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
	rmAddObjectDefConstraint(sharkID, sharkLand);
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int deerID=rmCreateObjectDef("lonely deer");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(deerID, "deer", rmRandInt(1,2), 1.0);
	} else {
		rmAddObjectDefItem(deerID, "aurochs", 1, 0.0);
	}
	rmSetObjectDefMinDistance(deerID, 0.0);
	rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(deerID, avoidAll);
	rmAddObjectDefConstraint(deerID, avoidBuildings);
	rmAddObjectDefConstraint(deerID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int rockID=rmCreateObjectDef("rock and grass");
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
	rmAddObjectDefItem(rockID, "grass", 2, 1.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, avoidRock);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 14.0);
	int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 10.0);
	int kelpID=rmCreateObjectDef("seaweed");
	rmAddObjectDefItem(kelpID, "seaweed", 12, 6.0);
	rmSetObjectDefMinDistance(kelpID, 0.0);
	rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(kelpID, avoidAll);
	rmAddObjectDefConstraint(kelpID, nearshore);
	rmAddObjectDefConstraint(kelpID, farshore);
	rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	int kelp2ID=rmCreateObjectDef("seaweed 2");
	rmAddObjectDefItem(kelp2ID, "seaweed", 5, 3.0);
	rmSetObjectDefMinDistance(kelp2ID, 0.0);
	rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(kelp2ID, avoidAll);
	rmAddObjectDefConstraint(kelp2ID, nearshore);
	rmAddObjectDefConstraint(kelp2ID, farshore);
	rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
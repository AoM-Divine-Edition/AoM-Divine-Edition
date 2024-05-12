/*	Map Name: Midgard.xs
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
	int playerTiles=12000;
	if(cMapSize == 1){
		playerTiles = 15600;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 31200;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	float waterType=rmRandFloat(0, 1);
	if(waterType<0.5) {
		rmSetSeaType("North Atlantic Ocean");
	} else {
		rmSetSeaType("Norwegian Sea");
	}
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classIce = rmDefineClass("ice");
	int classBonusHuntable = rmDefineClass("bonus huntable");
	int classHill = rmDefineClass("classHill");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classForest=rmDefineClass("forest");
	int centre = rmDefineClass("centre");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int iceConstraint=rmCreateClassDistanceConstraint("avoid ice", classIce, 5.0);
	int shortIceConstraint=rmCreateClassDistanceConstraint("avoid ice", classIce, 1.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int centerID=rmCreateArea("center");
	rmSetAreaSize(centerID, 0.49, 0.49);
	rmSetAreaLocation(centerID, 0.5, 0.5);
	
	rmSetAreaCoherence(centerID, 0.0);
	rmSetAreaBaseHeight(centerID, 2.0);
	rmSetAreaTerrainType(centerID, "snowA");
	rmSetAreaSmoothDistance(centerID, 30);
	rmSetAreaHeightBlend(centerID, 2);
	rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.075, 0.075, 0.925, 0.925, 0.01));
	rmBuildArea(centerID);
	
	int centreAvoidID=rmCreateArea("centre avoider");
	rmSetAreaSize(centreAvoidID, 0.01, 0.01);
	rmSetAreaLocation(centreAvoidID, 0.5, 0.5);
	rmAddAreaToClass(centreAvoidID, rmClassID("centre"));
	rmBuildArea(centreAvoidID);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers > 8) {
		rmPlacePlayersCircular(0.3, 0.35, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.25, 0.3, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	float playerFraction=rmAreaTilesToFraction(3000);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i, centerID);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobs(id, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id, 0.0);
		rmAddAreaConstraint(id, playerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SnowGrass50");
		rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 12);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 10.0);
	int numTries=6*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i, centerID);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, playerConstraint);
		rmAddAreaToClass(elevID, rmClassID("classHill"));
		rmAddAreaConstraint(elevID, iceConstraint);
		rmAddAreaConstraint(elevID, shortHillConstraint);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SnowGrass25");
		}
		
		rmSetAreaBaseHeight(elevID, rmRandFloat(4.0, 7.0));
		rmSetAreaHeightBlend(elevID, 2);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
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
	
	numTries=10*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i, centerID);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, shortAvoidImpassableLand);
		rmAddAreaConstraint(elevID, iceConstraint);
		rmAddAreaConstraint(elevID, shortHillConstraint);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
		rmSetAreaHeightBlend(elevID, 1);
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
	
	for(i=1; <cNumberPlayers) {
		id=rmCreateArea("port_Player"+i);
		rmSetAreaSize(id, 0.1*playerFraction, 0.1*playerFraction);
		rmSetAreaWarnFailure(id, true);
		rmSetAreaCoherence(id, 0.0);
		rmAddAreaConstraint(id, playerConstraint);
	}
	
	for(i=1; <cNumberPlayers*5*mapSizeMultiplier) {
		int id2=rmCreateArea("Patch"+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaTerrainType(id2, "SnowB");
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 2*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		rmAddAreaConstraint(id2, playerConstraint);
		rmAddAreaConstraint(id2, avoidImpassableLand);
		rmBuildArea(id2);
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
	int farAvoidFood=rmCreateTypeDistanceConstraint("far avoid food", "food", 30.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid bonus huntable", "huntable", 40.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree avoid", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree avoid gold", "gold", 6.0);
	int superAvoidImpassableLand=rmCreateTerrainDistanceConstraint("super far avoid impassable land", "land", false, 30.0);
	int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);
	
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
	int TCfarAvoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by farfar distance", "AbstractSettlement", 55.0+cNumberNonGaiaPlayers);
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	int TCavoidMid = rmCreateClassDistanceConstraint("TC vs. mid", rmClassID("centre"), 15.0);
	
	int farID = -1;
	int closeID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 75, 20, 20); /* bool forward bool inside */
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "SnowGrass50");
				rmAddAreaTerrainLayer(settleArea, "SnowGrass25", 2, 5);
				rmAddAreaTerrainLayer(settleArea, "SnowB", 0, 2);
				rmBuildArea(settleArea);
			} else {
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
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
			id=rmAddFairLoc("Settlement", true, false,  75, 95, 20, 20);
			rmAddFairLocConstraint(id, TCfarAvoidSettlement);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidMid);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "SnowGrass50");
				rmAddAreaTerrainLayer(settlementArea, "SnowGrass25", 2, 5);
				rmAddAreaTerrainLayer(settlementArea, "SnowB", 0, 2);
				rmBuildArea(settlementArea);
			} else {
				farID = rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCfarAvoidSettlement);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidMid);
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
		id=rmAddFairLoc("2player+ close Settlement", false, true, 60, 80, 50, 20);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		id=rmAddFairLoc("2player+ far Settlement", true, false, 80, 95, 60, 20);
		rmAddFairLocConstraint(id, TCavoidWater);
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("2p+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers) {
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		} else {
			for(p = 1; >= cNumberNonGaiaPlayers) {
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmSetObjectDefMinDistance(closeID, 60.0);
				rmSetObjectDefMaxDistance(closeID, 60.0);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				for(attempt = 1; < 16){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, 60+10*attempt);
				}
				
				farID = rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmSetObjectDefMinDistance(farID, 80.0);
				rmSetObjectDefMaxDistance(farID, 80.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCfarAvoidSettlement);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidMid);
				for(attempt = 1; < 16){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 80+10*attempt);
				}
			}
		}
	}
	
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.38), 80, 20);
		rmAddFairLocConstraint(id, TCfarAvoidSettlement);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea2, "SnowGrass50");
			rmAddAreaTerrainLayer(settlementArea2, "SnowGrass25", 2, 5);
			rmAddAreaTerrainLayer(settlementArea2, "SnowB", 0, 2);
			rmBuildArea(settlementArea2);
			rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
		}
		rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).

	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);
	
	int cowsAvoidStartingGold = rmCreateTypeDistanceConstraint("cowsies avoid gold", "gold", 10.0);
	int closeCowsID=rmCreateObjectDef("close Cows");
	rmAddObjectDefItem(closeCowsID, "cow", rmRandInt(1,2), 0.0);
	rmSetObjectDefMinDistance(closeCowsID, 25.0);
	rmSetObjectDefMaxDistance(closeCowsID, 30.0);
	rmAddObjectDefConstraint(closeCowsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeCowsID, cowsAvoidStartingGold);
	rmAddObjectDefConstraint(closeCowsID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(closeCowsID, true);
	
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 3.0);
	rmSetObjectDefMaxDistance(startingBerryID, 21.0);
	rmSetObjectDefMaxDistance(startingBerryID, 26.0);
	rmAddObjectDefConstraint(startingBerryID, cowsAvoidStartingGold);
	rmAddObjectDefConstraint(startingBerryID, getOffTheTC);
	rmAddObjectDefConstraint(startingBerryID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingBerryID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 6));
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
	int playerFishID=rmCreateObjectDef("owned fish");
	rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 8.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 5.0*cNumberNonGaiaPlayers);
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainDistanceConstraint("fish vs land", "land", true, 8.0));
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
			if(placement % 5 == 0){
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
	
	int maxNum = 4;
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
			rmSetAreaForestType(playerStartingForestID, "snow pine forest");
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
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 24.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 24.0);
	rmSetObjectDefMaxDistance(startingTowerID, 27.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(startingTowerID, cowsAvoidStartingGold);
	placement = 1;
	increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 27;
		rmSetObjectDefMaxDistance(startingTowerID, increment);
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
	
	int goldAvoidImpassableLand=rmCreateTerrainDistanceConstraint("gold avoid impassable land", "land", false, 20.0);
	int goldAttemptsMax = 1;
	if(cNumberNonGaiaPlayers == 2){
		goldAttemptsMax = 250;
	} else if(cNumberNonGaiaPlayers <= 4){
		goldAttemptsMax = 50;
	} else if(cNumberNonGaiaPlayers <= 6){
		goldAttemptsMax = 20;
	} else if(cNumberNonGaiaPlayers <= 10){
		goldAttemptsMax = 10;
	} else {
		goldAttemptsMax = 5;
	}
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 52.0+(cNumberNonGaiaPlayers*2-4));
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, goldAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, shortIceConstraint);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	int goldNum = 2;
	for(p = 1; <= cNumberNonGaiaPlayers){
		increment = 52.0 + (cNumberNonGaiaPlayers*2-4);
		rmSetObjectDefMaxDistance(mediumGoldID, increment);
		rmPlaceObjectDefAtLoc(mediumGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(mediumGoldID) < (p*goldNum)){	//Will always be true for 2.
			for(goldAttempts = 0; < goldAttemptsMax){
				if(goldAttempts % 5 == 0){
					increment++;
					rmSetObjectDefMaxDistance(mediumGoldID, increment);
				}
				rmPlaceObjectDefAtLoc(mediumGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(mediumGoldID) >= (p*goldNum)){
					break;
				}
			}
		}
	}
	
	int numHuntable=rmRandInt(5, 8);
	int mediumDeerID=rmCreateObjectDef("medium deer");
	rmAddObjectDefItem(mediumDeerID, "deer", numHuntable, 3.0);
	rmSetObjectDefMinDistance(mediumDeerID, 55.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 65.0);
	rmAddObjectDefConstraint(mediumDeerID, superAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumDeerID, farAvoidFood);
	rmAddObjectDefConstraint(mediumDeerID, avoidGold);
	rmAddObjectDefConstraint(mediumDeerID, iceConstraint);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumDeerID, false, 1);
	
	int mediumWalrusID=rmCreateObjectDef("medium walrus");
	rmAddObjectDefItem(mediumWalrusID, "walrus", rmRandInt(3,6), 8.0);
	rmSetObjectDefMinDistance(mediumWalrusID, 60.0);
	rmSetObjectDefMaxDistance(mediumWalrusID, 65.0);
	rmAddObjectDefConstraint(mediumWalrusID, nearShore);
	rmAddObjectDefConstraint(mediumWalrusID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumWalrusID, avoidFood);
	rmAddObjectDefConstraint(mediumWalrusID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumWalrusID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int goldAccuracy = 150;
	if(cNumberNonGaiaPlayers >= 6){
		goldAccuracy = 25;
	} else if(cNumberNonGaiaPlayers >= 4){
		goldAccuracy = 35;
	}
	
	goldNum = rmRandInt(2,3);
	int farAvoidGold = -1;
	if(goldNum == 2){
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 48.0);
	} else if(goldNum == 3){
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold2", "gold", 45.0);
	} else {
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold3", "gold", 40.0);
	}
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 55.0);
	rmSetObjectDefMaxDistance(farGoldID, 80.0 + (cNumberNonGaiaPlayers*3));
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, goldAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, shortIceConstraint);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	
	for(p = 1; <= cNumberNonGaiaPlayers){
		increment = 80.0 + (cNumberNonGaiaPlayers*3);
		rmSetObjectDefMaxDistance(farGoldID, increment);
		rmPlaceObjectDefAtLoc(farGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(farGoldID) < (p*goldNum)){	//Will always be true for 2.
			for(goldAttempts = 0; < goldAccuracy){
				if(goldAttempts % 2 == 0){
					increment++;
					rmSetObjectDefMaxDistance(farGoldID, increment);
				}
				rmPlaceObjectDefAtLoc(farGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farGoldID) >= (p*goldNum)){
					break;
				}
			}
		}
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	int bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(4,9), 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(4,9), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 70.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 75.0 + (2*cNumberNonGaiaPlayers-4));
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, farAvoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, iceConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 1);
	
	int bonusWalrus=rmCreateObjectDef("bonus walrus");
	rmAddObjectDefItem(bonusWalrus, "walrus", rmRandInt(3,5), 8.0);
	rmSetObjectDefMinDistance(bonusWalrus, 77.5);
	rmSetObjectDefMaxDistance(bonusWalrus, 90.0 + (cNumberNonGaiaPlayers*2-4));
	rmAddObjectDefConstraint(bonusWalrus, farAvoidFood);
	rmAddObjectDefConstraint(bonusWalrus, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusWalrus, nearShore);
	rmAddObjectDefConstraint(bonusWalrus, avoidGold);
	if(rmRandFloat(0,1)<0.75) {
		rmPlaceObjectDefPerPlayer(bonusWalrus, false, 1);
	} else if(cNumberNonGaiaPlayers < 8) {
		rmPlaceObjectDefPerPlayer(bonusWalrus, false, 2);
	} else {
		rmPlaceObjectDefPerPlayer(bonusWalrus, false, 1);
	}
	
	int farCowID=rmCreateObjectDef("far Cow");
	rmAddObjectDefItem(farCowID, "cow", rmRandInt(1,2), 2.0);
	rmSetObjectDefMinDistance(farCowID, 80.0);
	rmSetObjectDefMaxDistance(farCowID, 100.0 + (7*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farCowID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCowID, rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 18.0));
	rmAddObjectDefConstraint(farCowID, farAvoidFood);
	rmAddObjectDefConstraint(farCowID, avoidGold);
	rmPlaceObjectDefPerPlayer(farCowID, false, rmRandInt(1,2));
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "wolf", 2, 2.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 1.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, farAvoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 139", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 139", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 80.0 + (cNumberNonGaiaPlayers*2));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
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
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.26));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, superAvoidImpassableLand);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 139", "gold", 60.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(5,6), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.26));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, farAvoidFood);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, iceConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantWalrus=rmCreateObjectDef("giant walrus");
		rmAddObjectDefItem(giantWalrus, "walrus", rmRandInt(4,6), 8.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.22));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantWalrus, farAvoidFood);
		rmAddObjectDefConstraint(giantWalrus, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantWalrus, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantWalrus, nearShore);
		rmPlaceObjectDefPerPlayer(giantWalrus, false);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "cow", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, farAvoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int count=0;
	numTries=8*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	failCount=0;
	for(i=0; <numTries) {
		int forestID=rmCreateArea("forest"+i, centerID);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(140));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(240));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "snow pine forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, iceConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 25.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		// Hill trees?
		if(rmRandFloat(0.0, 1.0)<0.2) {
			rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
		}
		
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
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 8.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, iceConstraint);
	rmAddObjectDefConstraint(randomTreeID, avoidFood);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int lineFishID=rmCreateObjectDef("line fish");
	rmAddObjectDefItem(lineFishID, "fish - salmon", 3, 8.0);
	rmSetObjectDefMinDistance(lineFishID, 0.0);
	rmSetObjectDefMaxDistance(lineFishID, 0.0);

	rmPlaceObjectDefInLineX(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.955, 0.0, 1.0, 0.02);
	rmPlaceObjectDefInLineX(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.045, 0.0, 1.0, 0.02);
	rmPlaceObjectDefInLineZ(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.955, 0.0, 1.0, 0.02);
	rmPlaceObjectDefInLineZ(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.045, 0.0, 1.0, 0.02);
	
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 10.0);
	int cornerFishID=rmCreateObjectDef("corner fish");
	rmAddObjectDefItem(cornerFishID, "fish - salmon", 3, 8.0);
	rmSetObjectDefMinDistance(cornerFishID, 1.0);
	rmSetObjectDefMaxDistance(cornerFishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(cornerFishID, fishLand);
	rmAddObjectDefConstraint(cornerFishID, rmCreateTypeDistanceConstraint("corner fish v fish", "fish", 28.0));
	rmPlaceObjectDefAtLoc(cornerFishID, 0, 0.05, 0.05, (cNumberNonGaiaPlayers/2));
	rmPlaceObjectDefAtLoc(cornerFishID, 0, 0.95, 0.05, (cNumberNonGaiaPlayers/2));
	rmPlaceObjectDefAtLoc(cornerFishID, 0, 0.05, 0.95, (cNumberNonGaiaPlayers/2));
	rmPlaceObjectDefAtLoc(cornerFishID, 0, 0.95, 0.95, (cNumberNonGaiaPlayers/2));
	
	int orcaLand = rmCreateTerrainDistanceConstraint("orca land", "land", true, 20.0);
	int orcaVsOrca=rmCreateTypeDistanceConstraint("orca v orca", "orca", 20.0);
	int orcaID=rmCreateObjectDef("orca");
	rmAddObjectDefItem(orcaID, "orca", 1, 0.0);
	rmSetObjectDefMinDistance(orcaID, 0.0);
	rmSetObjectDefMaxDistance(orcaID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(orcaID, orcaLand);
	rmAddObjectDefConstraint(orcaID, orcaVsOrca);
	rmAddObjectDefConstraint(orcaID, rmCreateBoxConstraint("edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20), 0.01));
	rmPlaceObjectDefAtLoc(orcaID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	if(waterType>=0.5){
		int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
		int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
		int kelpID=rmCreateObjectDef("seaweed");
		rmAddObjectDefItem(kelpID, "seaweed", 5, 3.0);
		rmSetObjectDefMinDistance(kelpID, 0.0);
		rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(kelpID, avoidAll);
		rmAddObjectDefConstraint(kelpID, nearshore);
		rmAddObjectDefConstraint(kelpID, farshore);
		rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
		
		int kelp2ID=rmCreateObjectDef("seaweed 2");
		rmAddObjectDefItem(kelp2ID, "seaweed", 2, 3.0);
		rmSetObjectDefMinDistance(kelp2ID, 0.0);
		rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(kelp2ID, avoidAll);
		rmAddObjectDefConstraint(kelp2ID, nearshore);
		rmAddObjectDefConstraint(kelp2ID, farshore);
		rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);
	}
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock granite sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, iceConstraint);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	rmSetStatusText("",1.0);
}
/*	Map Name: Alfheim.xs
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
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmTerrainInitialize("SnowA");
	rmSetLightingSet("alfheim");
	rmSetGaiaCiv(cCivOdin);
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	int classPlayerCore = rmDefineClass("player core");
	int classHill = rmDefineClass("classHill");
	int classForest = rmDefineClass("forest");
	int classCliff = rmDefineClass("cliff");
	int classPred = rmDefineClass("predator");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classMiddle = rmDefineClass("mid");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int avoidPlayerCore = rmCreateClassDistanceConstraint("stay away from player core", classPlayerCore, 20.0);
	int avoidHill = rmCreateClassDistanceConstraint("stay away from hills", classHill, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	//No Map Outline for Alfheim
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	rmSetTeamSpacingModifier(0.75);
	if(cMapSize == 2){
		rmPlacePlayersCircular(0.26, 0.28, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	for(i=1; <cNumberPlayers){
		int id=rmCreateArea("Player core"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(110), rmAreaTilesToFraction(110));
		rmAddAreaToClass(id, classPlayerCore);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaLocPlayer(id, i);
		rmBuildArea(id);
	}
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
	float playerFraction=rmAreaTilesToFraction(4000);
	for(i=1; <cNumberPlayers){
		id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaCoherence(id, 0.0);
		rmAddAreaConstraint(id, playerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SnowDirt50");
		rmAddAreaTerrainLayer(id, "SnowDirt25", 8, 20);
		rmAddAreaTerrainLayer(id, "SnowA", 0, 8);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int middleID=rmCreateArea("map middle");
	rmSetAreaSize(middleID, 0.01, 0.01);
	rmSetAreaLocation(middleID, 0.5, 0.5);
	rmSetAreaCoherence(middleID, 1.0);
	rmAddAreaToClass(middleID, classMiddle);
	rmBuildArea(middleID);
	
	for(i=1; <cNumberPlayers) {
		// Beautification sub area.
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, "SnowDirt25");
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier){
		// Beautification sub area.
		int id4=rmCreateArea("Snow patch 2 "+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(5*mapSizeMultiplier), rmAreaTilesToFraction(16*mapSizeMultiplier));
		rmSetAreaTerrainType(id4, "SnowB");
		rmSetAreaMinBlobs(id4, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id4, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id4, false);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id4, 0.0);
		
		rmBuildArea(id4);
	}
	
	for(i=1; <cNumberPlayers*12*mapSizeMultiplier){
		// Beautification sub area.
		int id5=rmCreateArea("Snow patch 3 "+i);
		rmSetAreaSize(id5, rmAreaTilesToFraction(5*mapSizeMultiplier), rmAreaTilesToFraction(20*mapSizeMultiplier));
		rmSetAreaTerrainType(id5, "SnowDirt25");
		rmSetAreaMinBlobs(id5, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id5, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id5, false);
		rmSetAreaMinBlobDistance(id5, 16.0);
		rmSetAreaMaxBlobDistance(id5, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id5, 0.0);
		
		rmBuildArea(id5);
	}
	
	int numTries=30*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaToClass(elevID, classHill);
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, avoidPlayerCore);
		rmAddAreaConstraint(elevID, avoidHill);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 5 times in a row.
			failCount++;
			if(failCount==5) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	numTries=10*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries){
		elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaToClass(elevID, classHill);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, avoidPlayerCore);
		rmAddAreaConstraint(elevID, avoidHill);
		
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
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(5), rmZTilesToFraction(5), 1.0-rmXTilesToFraction(5), 1.0-rmZTilesToFraction(5));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int avoidGold=rmCreateTypeDistanceConstraint("stuff vs. gold", "gold", 30.0);
	int goldAvoidGold=rmCreateTypeDistanceConstraint("gold vs. gold", "gold", 42.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 25.0);
	int shortAvoidFood=rmCreateTypeDistanceConstraint("short avoid food", "food", 13.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 20.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 25.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("avoid trees all", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("avoid trees gold", "gold", 6.0);
	
	rmSetStatusText("",0.46);
	
	
	/* *********************************************** */
	/* Section 8 Fair Location Placement & Starting TC */
	/* *********************************************** */
	
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
	int TCmid = rmCreateClassDistanceConstraint("TC avoid mid", classMiddle, 30.0);
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 0, 24, true); /* bool forward bool inside */
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "SnowDirt75");
				rmAddAreaTerrainLayer(settleArea, "SnowA", 0, 8);
				rmAddAreaTerrainLayer(settleArea, "SnowDirt25", 8, 16);
				rmAddAreaTerrainLayer(settleArea, "SnowDirt50", 16, 24);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
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
			id=rmAddFairLoc("Settlement", true, false,  70, 80, 0, 40);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCmid);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "SnowDirt75");
				rmAddAreaTerrainLayer(settlementArea, "SnowA", 0, 8);
				rmAddAreaTerrainLayer(settlementArea, "SnowDirt25", 8, 16);
				rmAddAreaTerrainLayer(settlementArea, "SnowDirt50", 16, 24);
				rmBuildArea(settlementArea);
			} else {
				int farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, TCmid);
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
		id=rmAddFairLoc("Close Settlement", false, true, 60+(cNumberNonGaiaPlayers/2), 80, 55, 20);
		id=rmAddFairLoc("Far Settlement", true, false,  75, 95, 75, 50);
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("fairloc settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					int farSettleArea = rmCreateArea("far settlement area"+i +j, rmAreaID("Player"+i));
					rmSetAreaLocation(farSettleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
					rmBuildArea(farSettleArea);
					rmPlaceObjectDefAtAreaLoc(id, i, farSettleArea);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		rmResetFairLocs();
		id=rmAddFairLoc("giant close Settlement", false, true,  rmXFractionToMeters(0.38), rmXFractionToMeters(0.4), 120, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCmid);
		
		id=rmAddFairLoc("giant far Settlement", false, false,  rmXFractionToMeters(0.4), rmXFractionToMeters(0.43), 120, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCmid);
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				id=rmCreateObjectDef("Giant settlement_"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 1.0);
				for(FL = 0; < 2){
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.01, 0.01);
					rmSetAreaTerrainType(settlementArea2, "SnowDirt75");
					rmAddAreaTerrainLayer(settlementArea2, "SnowA", 0, 8);
					rmAddAreaTerrainLayer(settlementArea2, "SnowDirt25", 8, 16);
					rmAddAreaTerrainLayer(settlementArea2, "SnowDirt50", 16, 24);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
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
	rmAddObjectDefItem(startingHuntableID, "elk", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closeCowsID=rmCreateObjectDef("close Cows");
	rmAddObjectDefItem(closeCowsID, "cow", rmRandInt(3,4), 2.0);
	rmSetObjectDefMinDistance(closeCowsID, 22.0);
	rmSetObjectDefMaxDistance(closeCowsID, 27.0);
	rmAddObjectDefConstraint(closeCowsID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(closeCowsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(closeCowsID, shortAvoidFood);
	rmAddObjectDefConstraint(closeCowsID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(closeCowsID, true);
	
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", 8, 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 22.0);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidFood);
	rmAddObjectDefConstraint(startingChickenID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingChickenID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingChickenID, false);
	
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 21.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, shortAvoidFood);
	rmAddObjectDefConstraint(startingBerryID, getOffTheTC);
	rmAddObjectDefConstraint(startingBerryID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingBerryID, huntShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(startingBerryID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "ZMaple Snow", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));
	
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
		for(i=1; <= maxNum){
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "AOE Snow Mixed");
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
			if(placement % 20 == 0){
				increment++;
				rmSetObjectDefMaxDistance(startingTowerID, increment);
			}
		}
	}
	
	int ruinID=0;
	int columnID=0;
	int relicID=0;
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
	int avoidRuins=rmCreateTypeDistanceConstraint("ruin vs ruin", "relic", 60.0);
	int stayInRuins=rmCreateEdgeDistanceConstraint("stay in ruins", ruinID, 4.0);
	
	for(i=0; <2*cNumberNonGaiaPlayers*mapSizeMultiplier) {
		ruinID=rmCreateArea("ruins "+i);
		rmSetAreaSize(ruinID, rmAreaTilesToFraction(120*mapSizeMultiplier), rmAreaTilesToFraction(180));
		rmSetAreaTerrainType(ruinID, "RiverIcyC");
		rmAddAreaTerrainLayer(ruinID, "SnowDirt25", 0, 1);
		rmSetAreaMinBlobs(ruinID, 1);
		rmSetAreaMaxBlobs(ruinID, 2);
		rmSetAreaWarnFailure(ruinID, false);
		rmSetAreaMinBlobDistance(ruinID, 16.0);
		rmSetAreaMaxBlobDistance(ruinID, 40.0);
		rmSetAreaCoherence(ruinID, 0.9);
		rmSetAreaSmoothDistance(ruinID, 10);
		rmAddAreaConstraint(ruinID, avoidAll);
		rmAddAreaConstraint(ruinID, avoidRuins);
		rmAddAreaConstraint(ruinID, stayInRuins);
		rmAddAreaConstraint(ruinID, avoidBuildings);
		rmAddAreaConstraint(ruinID, farStartingSettleConstraint);
		
		rmBuildArea(ruinID);
		
		columnID=rmCreateObjectDef("columns "+i);
		rmAddObjectDefItem(columnID, "Inuksuk Large", rmRandInt(0,1), 0.0);
		rmAddObjectDefItem(columnID, "columns broken", rmRandInt(2,5), 4.0);
		rmAddObjectDefItem(columnID, "Inuksuk Small", rmRandFloat(0,2), 4.0);
		rmAddObjectDefItem(columnID, "rock limestone small", rmRandInt(1,3), 4.0);
		rmAddObjectDefItem(columnID, "rock limestone sprite", rmRandInt(6,12), 6.0);
		rmAddObjectDefItem(columnID, "Snow", rmRandFloat(3,6), 4.0);
		rmSetObjectDefMinDistance(columnID, 0.0);
		rmSetObjectDefMaxDistance(columnID, 0.0);
		rmPlaceObjectDefInArea(columnID, 0, rmAreaID("ruins "+i), 1);
		
		relicID=rmCreateObjectDef("relics "+i);
		rmAddObjectDefItem(relicID, "relic", 1, 0.0);
		rmSetObjectDefMinDistance(relicID, 0.0);
		rmSetObjectDefMaxDistance(relicID, 0.0);
		rmAddObjectDefConstraint(relicID, avoidAll);
		rmAddObjectDefConstraint(relicID, stayInRuins);
		rmPlaceObjectDefInArea(relicID, 0, rmAreaID("ruins "+i), 1);
		
		if(rmGetNumberUnitsPlaced(relicID) < 1){
			rmEchoInfo("---------------------failed to place relicID in ruins "+i+". So just dropping backup Relic.");
			rmSetAreaSize(ruinID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
			
			int backupRelicID=rmCreateObjectDef("backup relic "+i);
			rmAddObjectDefItem(backupRelicID, "relic", 1, 0.0);
			rmSetObjectDefMinDistance(backupRelicID, 0.0);
			rmSetObjectDefMaxDistance(backupRelicID, rmXFractionToMeters(0.5));
			rmAddObjectDefConstraint(backupRelicID, avoidRuins);
			rmAddObjectDefConstraint(backupRelicID, farStartingSettleConstraint);
			rmPlaceObjectDefAtLoc(backupRelicID, 0, 0.5, 0.5, 1);
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
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, goldAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));
	
	int mediumDeerID=rmCreateObjectDef("medium deer");
	rmAddObjectDefItem(mediumDeerID, "deer", rmRandInt(4,6), 4.0);
	rmSetObjectDefMinDistance(mediumDeerID, 50.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 55.0);
	rmAddObjectDefConstraint(mediumDeerID, avoidFood);
	rmAddObjectDefConstraint(mediumDeerID, avoidGold);
	rmAddObjectDefConstraint(mediumDeerID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumDeerID, false);
	
	int mediumCowID=rmCreateObjectDef("medium Cow");
	rmAddObjectDefItem(mediumCowID, "cow", rmRandFloat(1,2), 4.0);
	rmSetObjectDefMinDistance(mediumCowID, 50.0);
	rmSetObjectDefMaxDistance(mediumCowID, 70.0);
	rmAddObjectDefConstraint(mediumCowID, avoidFood);
	rmAddObjectDefConstraint(mediumCowID, avoidGold);
	rmAddObjectDefConstraint(mediumCowID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumCowID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0);
	rmAddObjectDefConstraint(farGoldID, avoidFood);
	rmAddObjectDefConstraint(farGoldID, goldAvoidGold);
	rmAddObjectDefConstraint(farGoldID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(3, 4));
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance < 0.33) {
		rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(3,5), 4.0);
	} else if(bonusChance < 0.66) {
		rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(3,4), 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "aurochs", rmRandInt(2,3), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 70.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 75.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	rmSetObjectDefMinDistance(bonusHuntableID, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 80.0);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	int farCowID=rmCreateObjectDef("far Cow");
	rmAddObjectDefItem(farCowID, "cow", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farCowID, 75.0);
	rmSetObjectDefMaxDistance(farCowID, 95.0);
	rmAddObjectDefConstraint(farCowID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCowID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farCowID, avoidHerdable);
	rmAddObjectDefConstraint(farCowID, avoidHuntable);
	rmAddObjectDefConstraint(farCowID, avoidGold);
	rmPlaceObjectDefPerPlayer(farCowID, false, rmRandInt(1, 2));
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "wolf", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 2, 4.0);
	}
	rmAddObjectDefToClass(farPredatorID, classPred);
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 121", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 121", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		
		int giantAvoidGold=rmCreateTypeDistanceConstraint("giant gold vs. gold", "gold", 80.0);
		int giantAvoidFood=rmCreateTypeDistanceConstraint("giant avoid food", "food", 30.0);
		int giantAvoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 45.0);
		int giantAvoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 50.0);
		
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, giantAvoidFood);
		rmAddObjectDefConstraint(giantGoldID, giantAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "elk", rmRandInt(5,6), 4.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.34));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		int giantHuntable3ID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntable3ID, "caribou", rmRandInt(5,6), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.38));
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.42));
		rmAddObjectDefConstraint(giantHuntable3ID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntable3ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable3ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable3ID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntable3ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable3ID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntable3ID, false, 2);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		rmAddObjectDefItem(giantHuntable2ID, "aurochs", rmRandInt(3,4), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.41));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "cow", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.34));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.41));
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHerdableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHerdableID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, 2);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int cliffConstraint = rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 40.0);
	int cliffGold = rmCreateTypeDistanceConstraint("cliff v gold", "gold", 20.0);
	int cliffForest = rmCreateClassDistanceConstraint("cliff v forest", rmClassID("forest"), 10.0);
	int cliffAll = rmCreateTypeDistanceConstraint("cliff v All", "all", 8.0);
	int cliffCow = rmCreateTypeDistanceConstraint("cliff v cow", "cow", 12.0);
	int cliffHunt = rmCreateTypeDistanceConstraint("cliff v hunt", "huntable", 12.0);
	int cliffPred = rmCreateTypeDistanceConstraint("cliff v pred", "animalPredator", 12.0);
	int cliffPred2 = rmCreateClassDistanceConstraint("cliff v pred2", classPred, 12.0);
	numTries=3*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries= numTries + cNumberNonGaiaPlayers;
	}
	failCount=0;
	for(i=0; <numTries){
		int cliffID=rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(250));
		rmSetAreaCliffType(cliffID, "Norse");
		rmAddAreaToClass(cliffID, classCliff);
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, cliffForest);
		rmAddAreaConstraint(cliffID, cliffAll);
		rmAddAreaConstraint(cliffID, cliffCow);
		rmAddAreaConstraint(cliffID, cliffHunt);
		rmAddAreaConstraint(cliffID, cliffPred);
		rmAddAreaConstraint(cliffID, cliffPred2);
		rmAddAreaConstraint(cliffID, cliffGold);
		rmAddAreaConstraint(cliffID, avoidBuildings);
		rmAddAreaConstraint(cliffID, shortEdgeConstraint);
		rmSetAreaMinBlobs(cliffID, 1);
		rmSetAreaMaxBlobs(cliffID, 2);
		rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
		rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
		rmSetAreaTerrainType(cliffID, "cliffNorseA");
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaMinBlobDistance(cliffID, 5.0);
		rmSetAreaMaxBlobDistance(cliffID, 10.0);
		rmSetAreaCoherence(cliffID, 0.55);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		rmBuildArea(cliffID);
	}
	
	int shortCliffConstraint = rmCreateClassDistanceConstraint("stuff v cliff", rmClassID("cliff"), 10.0);
	int forestObjConstraint = rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint = rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int count=0;
	numTries=9*cNumberNonGaiaPlayers*mapSizeMultiplier;
	
	failCount=0;
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "AOE Snow Forest");
		rmAddAreaConstraint(forestID, forestOtherTCs);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, shortCliffConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 8);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		// Hill trees?
		if(rmRandFloat(0.0, 1.0)<0.2)
		rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
		
		rmBuildArea(forestID);
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
	rmAddObjectDefItem(randomTreeID, "ZYukon", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0));
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 25*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 8.0);
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, shortCliffConstraint);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidAll);
	rmAddObjectDefConstraint(logID, avoidImpassableLand);
	rmAddObjectDefConstraint(logID, shortCliffConstraint);
	rmAddObjectDefConstraint(logID, avoidBuildings);
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int grassID=rmCreateObjectDef("Snow");
	rmAddObjectDefItem(grassID, "rock Granite sprite", rmRandInt(2,6), 6.0);
	rmAddObjectDefItem(grassID, "ZYukon Underbrush", rmRandInt(2,3), 6.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmAddObjectDefConstraint(grassID, shortCliffConstraint);
	rmAddObjectDefConstraint(grassID, avoidBuildings);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",1.0);
}
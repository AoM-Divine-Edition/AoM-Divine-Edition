/*	Map Name: Tundra.xs
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
	rmSetSeaLevel(0.5);
	rmTerrainInitialize("TundraRockA");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest = rmDefineClass("forest");
	int classPlayer = rmDefineClass("player");
	int classMiddle = rmDefineClass("mid");
	rmDefineClass("classHill");
	rmDefineClass("rock pile");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	rmCreateTrigger("Snow_A");
	rmCreateTrigger("Snow_backup");
	
	rmSwitchToTrigger(rmTriggerID("Snow_A"));
	rmSetTriggerPriority(2);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 2);
	
	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 0.1);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_backup"));
	
	rmSwitchToTrigger(rmTriggerID("Snow_backup"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 60);
	
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_A"));
	
	int middleID=rmCreateArea("map middle");
	rmSetAreaSize(middleID, 0.005, 0.005);
	rmSetAreaLocation(middleID, 0.5, 0.5);
	rmSetAreaCoherence(middleID, 1.0);
	rmAddAreaToClass(middleID, classMiddle);
	rmBuildArea(middleID);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers < 10){
		rmSetTeamSpacingModifier(0.75);
		rmPlacePlayersCircular(0.3, 0.4, rmDegreesToRadians(4.0));
	} else {
		rmSetTeamSpacingModifier(0.85);
		rmPlacePlayersCircular(0.35, 0.43, rmDegreesToRadians(4.0));
	}
	rmRecordPlayerLocations();
	
	float playerFraction=rmAreaTilesToFraction(4000);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i);
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
		rmSetAreaTerrainType(id, "TundraRockA");
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int numTries=5*cNumberNonGaiaPlayers;
	int failCount=0;
	
	numTries=40*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier){
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(60*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaTerrainType(elevID, "TundraGrassA");
		rmSetAreaBaseHeight(elevID, rmRandFloat(8.0, 10.0));
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmSetAreaHeightBlend(elevID, 4);
		rmSetAreaMinBlobs(elevID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(elevID, 3*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0*mapSizeMultiplier);
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
	
	int pondClass=rmDefineClass("pond");
	int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 20.0);
	int numPond=30*cNumberNonGaiaPlayers;
	int placeCount=0;
	for(i=0; <numPond){
		int smallPondID=rmCreateArea("small pond"+i);
		rmSetAreaSize(smallPondID, rmAreaTilesToFraction(400), rmAreaTilesToFraction(400));
		rmSetAreaLocation(smallPondID, rmRandFloat(0.1, 0.9), rmRandFloat(0.1, 0.9));
		rmSetAreaWaterType(smallPondID, "Tundra Pool");
		rmSetAreaMinBlobs(smallPondID, 1);
		rmSetAreaMaxBlobs(smallPondID, 1);
		rmAddAreaToClass(smallPondID, pondClass);
		rmAddAreaConstraint(smallPondID, pondConstraint);
		rmAddAreaConstraint(smallPondID, playerConstraint);
		rmSetAreaWarnFailure(smallPondID, false);
		rmBuildArea(smallPondID);
	}

	for(i=1; <cNumberPlayers*100){
		int id2=rmCreateArea("dirt patch"+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(20), rmAreaTilesToFraction(40));
		rmSetAreaTerrainType(id2, "TundraGrassB");
		rmSetAreaMinBlobs(id2, 1);
		rmSetAreaMaxBlobs(id2, 5);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0);
		rmSetAreaCoherence(id2, 0.0);
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*30){
		int id3=rmCreateArea("Grass patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(30), rmAreaTilesToFraction(70));
		rmSetAreaTerrainType(id3, "TundraGrassA");
		rmSetAreaMinBlobs(id3, 1);
		rmSetAreaMaxBlobs(id3, 5);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0);
		rmSetAreaCoherence(id3, 0.0);
		
		rmBuildArea(id3);
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 15.0);
	int avoidMid = rmCreateClassDistanceConstraint("avoid mid", classMiddle, 1.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 10.0);
	int avoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TCs", "AbstractSettlement", 25.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 65.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 40.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int farAvoidFood=rmCreateTypeDistanceConstraint("avoid other food sources far", "food", 20.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree avoid all", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree avoid gold", "gold", 6.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	
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
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 60.0);
	int TCfarAvoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by farfar distance", "AbstractSettlement", 65.0+cNumberNonGaiaPlayers);
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 60.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	int TCedgeConstraint=rmCreateBoxConstraint("TC edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int TCcenterFar = rmCreateClassDistanceConstraint("TC far avoid center1", classMiddle, 55.0);
	float aggressive = rmRandFloat(0,1);
	
	if(cNumberNonGaiaPlayers == 2){
		if(aggressive >= 0.25){
			int TCcenterImpassableLand = rmCreateTerrainDistanceConstraint("TC center badlands", "land", false, 10.0);
			int TCcenter = rmCreateClassDistanceConstraint("TC avoid center", classMiddle, 1.0);
			int settlmentBoxConst = rmCreateBoxConstraint("Center settlements", 0.25, 0.25, 0.75, 0.75);
			int TCavoidPlayer2 = rmCreateClassDistanceConstraint("TC avoid player TC2", classStartingSettlement, 70.0);
			int centerSetID = -1;
			for(p = 1; <= cNumberNonGaiaPlayers){
				centerSetID = rmCreateObjectDef("center settlement"+p);
				rmAddObjectDefItem(centerSetID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(centerSetID, TCcenterImpassableLand);
				rmAddObjectDefConstraint(centerSetID, settlmentBoxConst);
				rmAddObjectDefConstraint(centerSetID, TCavoidSettlement);
				rmAddObjectDefConstraint(centerSetID, TCavoidPlayer2);
				rmAddObjectDefConstraint(centerSetID, TCcenter);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(centerSetID, p, 0.5, 0.5, 1);
					if(rmGetNumberUnitsPlaced(centerSetID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(centerSetID, attempt);
				}
			}
		}
	
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 70, 40, 24);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCedgeConstraint);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "TundraGrassB");
				rmAddAreaTerrainLayer(settleArea, "TundraGrassA", 0, 5);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				rmAddObjectDefConstraint(closeID, TCedgeConstraint);
				for(attempt = 1; < 151){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, 2*attempt);
				}
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			if(aggressive < 0.25){
				//Do it again.
				//Add a new FairLoc every time. This will have to be removed at the end of the block.
				if(rmRandFloat(0,1) < 0.5){
					id=rmAddFairLoc("Settlement", false, false,  80, 90, 40, 40);
				} else {
					id=rmAddFairLoc("Settlement", false, true,  80, 90, 40, 40);
				}
				rmAddFairLocConstraint(id, TCfarAvoidSettlement);
				rmAddFairLocConstraint(id, TCcenterFar);
				rmAddFairLocConstraint(id, TCavoidPlayer);
				rmAddFairLocConstraint(id, TCavoidImpassableLand);
				rmAddFairLocConstraint(id, TCedgeConstraint);
				
				if(rmPlaceFairLocs()) {
					id=rmCreateObjectDef("far settlement"+p);
					rmAddObjectDefItem(id, "Settlement", 1, 0.0);
					rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
					int settlementArea = rmCreateArea("settlement_area_"+p);
					rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
					rmSetAreaSize(settlementArea, 0.01, 0.01);
					rmSetAreaTerrainType(settlementArea, "SnowGrass50");
					rmAddAreaTerrainLayer(settlementArea, "TundraGrassA", 2, 5);
					rmAddAreaTerrainLayer(settlementArea, "TundraGrassB", 0, 2);
					rmBuildArea(settlementArea);
				} else {
					int farID=rmCreateObjectDef("far settlement"+p);
					rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
					rmAddObjectDefConstraint(farID, TCavoidPlayer);
					rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
					rmAddObjectDefConstraint(farID, TCcenterFar);
					rmAddObjectDefConstraint(farID, TCfarAvoidSettlement);
					rmAddObjectDefConstraint(farID, TCedgeConstraint);
					for(attempt = 1; < 151){
						rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
						if(rmGetNumberUnitsPlaced(farID) > 0){
							break;
						}
						rmSetObjectDefMaxDistance(farID, 2*attempt);
					}
				}
				rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
			}
		}
	} else {
		id=rmAddFairLoc("Settlement", false, true, 60, 75, 55, 20);
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("close 2Player+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		} rmResetFairLocs();
		
		id=rmAddFairLoc("Settlement", true, false, 70, 80+cNumberNonGaiaPlayers, 70, 80);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("far 2Player+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.38), 80, 20);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea2, "SnowGrass50");
			rmAddAreaTerrainLayer(settlementArea2, "TundraGrassA", 2, 5);
			rmAddAreaTerrainLayer(settlementArea2, "TundraGrassB", 0, 2);
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
	
	int startingHuntableID=rmCreateObjectDef("close huntable");
	float huntableNumber=rmRandFloat(0, 1);
	rmAddObjectDefItem(startingHuntableID, "Caribou", 6, 2.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 21.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 24.0);
	rmAddObjectDefConstraint(startingHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(startingHuntableID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closeSecondHuntID=rmCreateObjectDef("close caribou");
	if(huntableNumber<0.1){
		rmAddObjectDefItem(closeSecondHuntID, "Elk", rmRandInt(5,6), 3.0);
		rmAddObjectDefItem(closeSecondHuntID, "Caribou", rmRandInt(5,6), 8.0);
	} else if(huntableNumber<0.3){
		rmAddObjectDefItem(closeSecondHuntID, "Elk", rmRandInt(5,6), 2.0);
	} else {
		rmAddObjectDefItem(closeSecondHuntID, "Aurochs", 4, 2.0);
	}
	rmSetObjectDefMinDistance(closeSecondHuntID, 34.0);
	rmSetObjectDefMaxDistance(closeSecondHuntID, 37.0);
	rmAddObjectDefConstraint(closeSecondHuntID, avoidFood);
	rmAddObjectDefConstraint(closeSecondHuntID, getOffTheTC);
	rmAddObjectDefConstraint(closeSecondHuntID, shortEdgeConstraint);
	rmAddObjectDefConstraint(closeSecondHuntID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(closeSecondHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(closeSecondHuntID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(closeSecondHuntID, false);
	
	int startingGoatsID=rmCreateObjectDef("starting goaties");
	rmAddObjectDefItem(startingGoatsID, "Goat", rmRandInt(6,8), 3.0);
	rmSetObjectDefMaxDistance(startingGoatsID, 20.0);
	rmSetObjectDefMaxDistance(startingGoatsID, 22.0);
	rmAddObjectDefConstraint(startingGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(startingGoatsID, avoidFood);
	rmAddObjectDefConstraint(startingGoatsID, getOffTheTC);
	rmAddObjectDefConstraint(startingGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingGoatsID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(startingGoatsID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "Tundra Tree", 1, 0.0);
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
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "tundra forest");
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
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 21.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 21.0);
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, shortAvoidGold);
	rmAddObjectDefConstraint(startingTowerID, stragglerTreeAvoid);
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
	rmSetObjectDefMinDistance(mediumGoldID, 60.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));
	
	int mediumCaribouID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumCaribouID, "Caribou", rmRandInt(4,5), 4.0);
	rmSetObjectDefMinDistance(mediumCaribouID, 50.0);
	rmSetObjectDefMaxDistance(mediumCaribouID, 70.0);
	rmAddObjectDefConstraint(mediumCaribouID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumCaribouID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumCaribouID, avoidSettlement);
	rmAddObjectDefConstraint(mediumCaribouID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumCaribouID, farAvoidFood);
	rmAddObjectDefConstraint(mediumCaribouID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumCaribouID, false, 2);
	
	int numHuntable=rmRandInt(4, 9);
	int mediumElkID=rmCreateObjectDef("medium gazelle");
	rmAddObjectDefItem(mediumElkID, "Elk", numHuntable, 4.0);
	rmSetObjectDefMinDistance(mediumElkID, 60.0);
	rmSetObjectDefMaxDistance(mediumElkID, 80.0);
	rmAddObjectDefConstraint(mediumElkID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumElkID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumElkID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumElkID, avoidSettlement);
	rmAddObjectDefConstraint(mediumElkID, farAvoidFood);
	rmAddObjectDefConstraint(mediumElkID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumElkID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 100.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2, 4));
	
	int farHuntID=rmCreateObjectDef("far hunt");
	rmAddObjectDefItem(farHuntID, "Aurochs", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance(farHuntID, 80.0);
	rmSetObjectDefMaxDistance(farHuntID, 100.0);
	rmAddObjectDefConstraint(farHuntID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farHuntID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farHuntID, farAvoidFood);
	rmAddObjectDefConstraint(farHuntID, avoidGold);
	rmAddObjectDefConstraint(farHuntID, avoidSettlement);
	rmAddObjectDefConstraint(farHuntID, edgeConstraint);
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefAtLoc(farHuntID, 0, 0.5, 0.5);
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.2){
		rmAddObjectDefItem(bonusHuntableID, "Caribou", rmRandInt(4,5), 3.0);
		rmAddObjectDefItem(bonusHuntableID, "Aurochs", rmRandInt(1,2), 3.0);
	} else if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "Elk", rmRandInt(4,6), 2.0);
	} else if(bonusChance<0.9) {
		rmAddObjectDefItem(bonusHuntableID, "Aurochs", rmRandInt(2,3), 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "Caribou", rmRandInt(4,7), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, farAvoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int bonusHuntable2ID=rmCreateObjectDef("second bonus huntable");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.4) {
		rmAddObjectDefItem(bonusHuntable2ID, "Aurochs", 3, 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntable2ID, "Aurochs", 2, 2.0);
	}
	rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntable2ID, farAvoidFood);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntable2ID, edgeConstraint);
	rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "Polar Bear", 1, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "Wolf Arctic 2", 2, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 75.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 30.0));
	rmAddObjectDefConstraint(farPredatorID, farAvoidFood);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 144", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 144", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);
	
	int bonusPredatorID=rmCreateObjectDef("bonus predator");
	rmAddObjectDefItem(bonusPredatorID, "Wolf Arctic 2", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(bonusPredatorID, 80.0);
	rmSetObjectDefMaxDistance(bonusPredatorID, 100.0);
	rmAddObjectDefConstraint(bonusPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusPredatorID, farAvoidFood);
	rmAddObjectDefConstraint(bonusPredatorID, avoidSettlement);
	rmAddObjectDefConstraint(bonusPredatorID, avoidGold);
	rmAddObjectDefConstraint(bonusPredatorID, shortAvoidImpassableLand);
	if(rmRandFloat(0,1)<0.5) {
		rmPlaceObjectDefPerPlayer(bonusPredatorID, false, 2);
	}
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 0.0);
	rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, avoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, farAvoidFood);
	rmAddObjectDefConstraint(farBerriesID, edgeConstraint);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	if(rmRandFloat(0,1)<0.6) {
		rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 60.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidSettlement);
	rmAddObjectDefConstraint(relicID, avoidFood);
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
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, farAvoidFood);
		rmAddObjectDefConstraint(giantGoldID, farAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, avoidSettlement);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(5,7), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, farAvoidFood);
		rmAddObjectDefConstraint(giantHuntableID, farAvoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, edgeConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, farAvoidGold);
		rmAddObjectDefConstraint(giantRelixID, avoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
	
	failCount=0;
	numTries=15*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "tundra forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, allObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 7);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmBuildArea(forestID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
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
	rmAddObjectDefItem(randomTreeID, "Tundra Tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 8.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid bush", "bush", 20.0);
	int avoidRocks=rmCreateTypeDistanceConstraint("avoid rocks", "Rock Sandstone Big", 20.0);
	
	int deerID=rmCreateObjectDef("lonely deer");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(deerID, "Elk", rmRandInt(3,4), 1.0);
	} else {
		rmAddObjectDefItem(deerID, "Caribou", 3, 0.0);
	}
	rmSetObjectDefMinDistance(deerID, 0.0);
	rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(deerID, avoidAll);
	rmAddObjectDefConstraint(deerID, avoidBuildings);
	rmAddObjectDefConstraint(deerID, avoidImpassableLand);
	rmAddObjectDefConstraint(deerID, farAvoidFood);
	rmAddObjectDefConstraint(deerID, edgeConstraint);
	rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int deer2ID=rmCreateObjectDef("lonely deer2");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(deer2ID, "Aurochs", 1, 1.0);
	} else {
		rmAddObjectDefItem(deer2ID, "Elk", 1, 0.0);
	}
	rmSetObjectDefMinDistance(deer2ID, 0.0);
	rmSetObjectDefMaxDistance(deer2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(deer2ID, avoidAll);
	rmAddObjectDefConstraint(deer2ID, avoidBuildings);
	rmAddObjectDefConstraint(deer2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(deer2ID, edgeConstraint);
	rmAddObjectDefConstraint(deer2ID, farAvoidFood);
	rmPlaceObjectDefAtLoc(deer2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	int bushID=rmCreateObjectDef("bush");
	rmAddObjectDefToClass(bushID, rmClassID("rock pile"));
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID, avoidGrass);
	rmAddObjectDefConstraint(bushID, rmCreateClassDistanceConstraint("avoid rockpiles", rmClassID("rock pile"), 30.0));
	rmAddObjectDefConstraint(bushID, rmCreateTypeDistanceConstraint("objects avoid TC by very short distance", "AbstractSettlement", 15.0));
	rmAddObjectDefConstraint(bushID, avoidAll);
	rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	rmSetStatusText("",1.0);
}
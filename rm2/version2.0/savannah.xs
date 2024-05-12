/*	Map Name: Savannah.xs
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
	rmTerrainInitialize("SavannahA");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classForest = rmDefineClass("forest");
	int classMiddle = rmDefineClass("middle");
	int classBack = rmDefineClass("backward TC");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int middleID=rmCreateArea("map middle");
	rmSetAreaSize(middleID, 0.04, 0.04);
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
		rmSetAreaTerrainType(id, "SavannahA");
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers*100*mapSizeMultiplier){
		int id2=rmCreateArea("dirt patch"+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(40*mapSizeMultiplier));
		rmSetAreaTerrainType(id2, "SavannahB");
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*30*mapSizeMultiplier) {
		int id3=rmCreateArea("Grass patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "SandA");
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		
		rmBuildArea(id3);
	}
	
	int numTries=5*cNumberNonGaiaPlayers;
	int failCount=0;
	
	numTries=40*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(20), rmAreaTilesToFraction(80));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaTerrainType(elevID, "SavannahC");
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmAddAreaConstraint(elevID, avoidImpassableLand);
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
	
	int pondClass=rmDefineClass("pond");
	int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 10.0);
	int numPond=rmRandInt(2,4);
	for(i=0; <numPond*mapSizeMultiplier) {
		int smallPondID=rmCreateArea("small pond"+i);
		rmSetAreaSize(smallPondID, rmAreaTilesToFraction(600*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaWaterType(smallPondID, "savannah water hole");
		rmSetAreaMinBlobs(smallPondID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(smallPondID, 1*mapSizeMultiplier);
		rmAddAreaToClass(smallPondID, pondClass);
		rmAddAreaConstraint(smallPondID, pondConstraint);
		rmAddAreaConstraint(smallPondID, edgeConstraint);
		rmAddAreaConstraint(smallPondID, playerConstraint);
		rmSetAreaWarnFailure(smallPondID, false);
		rmBuildArea(smallPondID);
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int startingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 40.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects far avoid player TCs", rmClassID("starting settlement"), 70.0);
	int avoidMid=rmCreateClassDistanceConstraint("avoid mid", classMiddle, 10.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 60.0);
	if(cNumberNonGaiaPlayers > 2){
		farAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold2", "gold", 54.0);
	}
	int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar = rmCreateTypeDistanceConstraint("far avoid other food sources", "food", 28.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree avoid", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree avoid gold", "gold", 6.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	
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
	int TCfarAvoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by farfar distance", "AbstractSettlement", 75.0);
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 16.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	float aggressive = rmRandFloat(0,1);
	
	if(cNumberNonGaiaPlayers == 2){
		if(aggressive >= 0.5){
			int TCcenterImpassableLand = rmCreateTerrainDistanceConstraint("TC center badlands", "land", false, 10.0);
			int TCcenter = rmCreateClassDistanceConstraint("TC avoid center", classMiddle, 20.0+cNumberNonGaiaPlayers);
			int settlmentBoxConst = rmCreateBoxConstraint("Center settlements", 0.25, 0.25, 0.75, 0.75);
			int TCavoidSettlement2 = rmCreateTypeDistanceConstraint("TC avoid TC", "AbstractSettlement", 60.0);
			int centerSetID = -1;
			for(p = 1; <= cNumberNonGaiaPlayers){
				centerSetID = rmCreateObjectDef("center settlement"+p);
				rmAddObjectDefItem(centerSetID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(centerSetID, TCcenterImpassableLand);
				rmAddObjectDefConstraint(centerSetID, settlmentBoxConst);
				rmAddObjectDefConstraint(centerSetID, TCavoidSettlement2);
				rmAddObjectDefConstraint(centerSetID, TCavoidPlayer);
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
			id=rmAddFairLoc("Settlement", false, true, 60, 75, 40, 20); /* bool forward bool inside */
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(id, classBack);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "SavannahC");
				rmAddAreaTerrainLayer(settleArea, "SavannahB", 2, 5);
				rmAddAreaTerrainLayer(settleArea, "SavannahA", 0, 2);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(closeID, classBack);
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
			
			if(aggressive < 0.5){
				//Do it again.
				//Add a new FairLoc every time. This will have to be removed at the end of the block.
				int TCcenterFar = -1;
				int TCback = -1;
				if(cNumberNonGaiaPlayers == 2){
					TCcenterFar = rmCreateClassDistanceConstraint("TC far avoid center", classMiddle, 30.0+cNumberNonGaiaPlayers);
					TCback = rmCreateClassDistanceConstraint("TC avoid backTC", classBack, 85.0);
				} else {
					TCcenterFar = rmCreateClassDistanceConstraint("TC far avoid center", classBack, 50.0+cNumberNonGaiaPlayers);
					TCback = rmCreateClassDistanceConstraint("TC avoid back TC", classBack, 55.0+cNumberNonGaiaPlayers);
				}
				id=rmAddFairLoc("Settlement", false, false,  80, 85, 20, 16);
				rmAddFairLocConstraint(id, TCfarAvoidSettlement);
				rmAddFairLocConstraint(id, TCback);
				rmAddFairLocConstraint(id, TCcenterFar);
				rmAddFairLocConstraint(id, TCavoidPlayer);
				
				if(rmPlaceFairLocs()) {
					id=rmCreateObjectDef("far settlement"+p);
					rmAddObjectDefItem(id, "Settlement", 1, 0.0);
					rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
					int settlementArea = rmCreateArea("settlement_area_"+p);
					rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
					rmSetAreaSize(settlementArea, rmXMetersToFraction(14.0), rmZMetersToFraction(14.0));
					rmSetAreaBaseHeight(settlementArea, 1.0);
					rmSetAreaSmoothDistance(settlementArea, 12);
					rmSetAreaHeightBlend(settlementArea, 2);
					rmSetAreaCoherence(settlementArea, 0.95);
					rmSetAreaTerrainType(settlementArea, "SavannahC");
					rmAddAreaTerrainLayer(settlementArea, "SavannahB", 10, 14);
					rmAddAreaTerrainLayer(settlementArea, "SavannahA", 0, 10);
					rmBuildArea(settlementArea);
				} else {
					int farID=rmCreateObjectDef("far settlement"+p);
					rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
					rmAddObjectDefConstraint(farID, TCavoidPlayer);
					rmAddObjectDefConstraint(farID, TCavoidWater);
					rmAddObjectDefConstraint(farID, TCcenterFar);
					rmAddObjectDefConstraint(farID, TCback);
					rmAddObjectDefConstraint(farID, TCfarAvoidSettlement);
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
		}
	} else {
		id=rmAddFairLoc("Settlement", false, false, 60, 75, 60, 20);
		id=rmAddFairLoc("Settlement", true, false, 80, 100, 60, 60);
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("twoPlayer+ settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.38), 80, 30);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea2, "SavannahB");
			rmAddAreaTerrainLayer(settlementArea2, "SavannahA", 2, 5);
			rmAddAreaTerrainLayer(settlementArea2, "SavannahC", 0, 2);
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
	if(rmRandFloat(0,1)>0.5){
		rmAddObjectDefItem(startingHuntableID, "zebra", rmRandInt(4,5), 3.0);
	} else {
		rmAddObjectDefItem(startingHuntableID, "gazelle", rmRandInt(4,5), 3.0);
	}
	rmSetObjectDefMaxDistance(startingHuntableID, 22.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, avoidFood);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 20.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closeGoatsID=rmCreateObjectDef("close goats");
	rmAddObjectDefItem(closeGoatsID, "goat", rmRandInt(2,3), 2.0);
	rmSetObjectDefMinDistance(closeGoatsID, 22.0);
	rmSetObjectDefMaxDistance(closeGoatsID, 28.0);
	rmAddObjectDefConstraint(closeGoatsID, avoidFood);
	rmAddObjectDefConstraint(closeGoatsID, getOffTheTC);
	rmAddObjectDefConstraint(closeGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(closeGoatsID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(closeGoatsID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(closeGoatsID, true);
	
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(6,8), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 22.0);
	rmAddObjectDefConstraint(startingChickenID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, rmCreateTypeDistanceConstraint("chicks avoid TC", "AbstractSettlement", 20.0));
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, true);
	
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
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "savannah forest");
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
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("tower avoid food", "food", 6.0));
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
	
	rmSetStatusText("",0.66);
	
	/* ************************* */
	/* Section 11 Medium Objects */
	/* ************************* */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, farAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, startingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));
	
	int numHuntable=rmRandInt(5, 8);
	int mediumDeerID=rmCreateObjectDef("medium gazelle");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(mediumDeerID, "gazelle", numHuntable, 4.0);
	} else {
		rmAddObjectDefItem(mediumDeerID, "giraffe", numHuntable, 4.0);
	}
	rmSetObjectDefMinDistance(mediumDeerID, 65.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 75.0);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumDeerID, startingSettleConstraint);
	rmAddObjectDefConstraint(mediumDeerID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumDeerID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumDeerID, forestTower);
	rmAddObjectDefConstraint(mediumDeerID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumDeerID, false);
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoatsID, startingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGoatsID, forestTower);
	rmAddObjectDefConstraint(mediumGoatsID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false, 2);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int goldAccuracy = 150;
	if(cNumberNonGaiaPlayers >= 10){
		goldAccuracy = 3;
	} else if(cNumberNonGaiaPlayers >= 8){
		goldAccuracy = 5;
	} else if(cNumberNonGaiaPlayers >= 6){
		goldAccuracy = 10;
	} else if(cNumberNonGaiaPlayers >= 4){
		goldAccuracy = 20;
	} else if(cNumberNonGaiaPlayers == 3){
		goldAccuracy = 30;
	}
	
	int numGold = rmRandInt(1,2);
	int farGoldID = -1;
	for(p = 1; <= cNumberNonGaiaPlayers){
		farGoldID = rmCreateObjectDef("far gold"+p);
		rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMinDistance(farGoldID, 75.0);
		rmSetObjectDefMaxDistance(farGoldID, 90.0);
		rmAddObjectDefConstraint(farGoldID, farAvoidGold);
		rmAddObjectDefConstraint(farGoldID, edgeConstraint);
		rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
		rmPlaceObjectDefAtLoc(farGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(farGoldID) < numGold){	//Will always be true for 2+.
			for(goldAttempts = 0; < goldAccuracy){
				rmSetObjectDefMaxDistance(farGoldID, 90.0 + 10*goldAttempts);
				rmPlaceObjectDefAtLoc(farGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farGoldID) >= numGold){
					break;
				}
			}
		}
	}
	
	numGold = (numGold % 2) + 1;	// Switch number from above. If 2 make 1, if 1 make 2.
	int superFarGoldID = -1;
	for(p = 1; <= cNumberNonGaiaPlayers){
		superFarGoldID = rmCreateObjectDef("super far gold"+p);
		rmAddObjectDefItem(superFarGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMinDistance(superFarGoldID, 90.0);
		rmSetObjectDefMaxDistance(superFarGoldID, 105.0);
		if(cNumberNonGaiaPlayers == 2){
			rmAddObjectDefConstraint(superFarGoldID, rmCreateClassDistanceConstraint("far away from middle", classMiddle, 25.0));
		}
		rmAddObjectDefConstraint(superFarGoldID, farAvoidGold);
		rmAddObjectDefConstraint(superFarGoldID, edgeConstraint);
		rmAddObjectDefConstraint(superFarGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(superFarGoldID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(superFarGoldID, shortAvoidImpassableLand);
		rmPlaceObjectDefAtLoc(superFarGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(superFarGoldID) < numGold){
			for(goldAttempts = 0; < goldAccuracy){
				rmSetObjectDefMaxDistance(superFarGoldID, 105 + 10*goldAttempts);
				rmPlaceObjectDefAtLoc(superFarGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(superFarGoldID) >= numGold){
					break;
				}
			}
		}
	}

	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 30.0);
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.2) {
		rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(2,4), 3.0);
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(1,2), 3.0);
	} else if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(4,6), 2.0);
	} else if(bonusChance<0.9) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,4), 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(4,7), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 85.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);

	int bonusHuntable2ID=rmCreateObjectDef("second bonus huntable");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.1) {
		rmAddObjectDefItem(bonusHuntable2ID, "elephant", 3, 2.0);
	} else if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntable2ID, "elephant", 2, 2.0);
	} else if(bonusChance<0.9) {
		rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 2, 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 4, 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntable2ID, 60.0);
	rmSetObjectDefMaxDistance(bonusHuntable2ID, 75.0);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortEdgeConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntable2ID, false);
	
	int farMonkeyID=rmCreateObjectDef("far monkeys");
	rmAddObjectDefItem(farMonkeyID, "baboon", rmRandInt(6,10), 4.0);
	rmSetObjectDefMinDistance(farMonkeyID, 70.0);
	rmSetObjectDefMaxDistance(farMonkeyID, 90.0);
	rmAddObjectDefConstraint(farMonkeyID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farMonkeyID, avoidFoodFar);
	rmAddObjectDefConstraint(farMonkeyID, avoidGold);
	rmAddObjectDefConstraint(farMonkeyID, avoidHuntable);
	rmAddObjectDefConstraint(farMonkeyID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farMonkeyID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farMonkeyID, shortAvoidImpassableLand);
	if(rmRandFloat(0,1)<0.5) {
		rmPlaceObjectDefPerPlayer(farMonkeyID, false, 1);
	}
	
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 80.0);
	rmSetObjectDefMaxDistance(farGoatsID, 150.0);
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(farGoatsID, avoidGold);
	rmAddObjectDefConstraint(farGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farGoatsID, false);
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 9, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 70.0);
	rmSetObjectDefMaxDistance(farBerriesID, 75.0);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, avoidFoodFar);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	if(rmRandFloat(0,1)<0.66) {
		rmPlaceObjectDefPerPlayer(farBerriesID, false);
	}
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "hyena", 3, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 30.0));
	rmAddObjectDefConstraint(farPredatorID, avoidFoodFar);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 132", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 132", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 115.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, shortEdgeConstraint);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantGoldID, avoidFoodFar);
		rmAddObjectDefConstraint(giantGoldID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 132", "gold", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.33) {
			rmAddObjectDefItem(bonusHuntable2ID, "elephant", 2, 2.0);
		} else if(bonusChance<0.66) {
			rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 3, 2.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "baboon", 8, 6.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.325));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidFoodFar);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 1);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		rmAddObjectDefItem(giantHuntable2ID, "Zebra", rmRandInt(4,5), 5.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.34));
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidFoodFar);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, 1);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(3,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmAddObjectDefConstraint(giantRelixID, avoidFoodFar);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 22.0);
	int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
	
	failCount=0;
	numTries=15*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	for(i=0; <numTries) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "savannah forest");
		rmAddAreaConstraint(forestID, forestOtherTCs);
		rmAddAreaConstraint(forestID, allObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 7);
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
	rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid bush", "bush", 20.0);
	int bushID=rmCreateObjectDef("bush");
	rmAddObjectDefItem(bushID, "bush", 3, 4.0);
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID, avoidGrass);
	rmAddObjectDefConstraint(bushID, allObjConstraint);
	rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	for(i=0; <numPond) {
		int lilyID=rmCreateObjectDef("lily"+i);
		rmAddObjectDefItem(lilyID, "water lilly", rmRandInt(3,6), 6.0);
		rmSetObjectDefMinDistance(lilyID, 0.0);
		rmSetObjectDefMaxDistance(lilyID, rmXFractionToMeters(0.5));
		rmPlaceObjectDefInArea(lilyID, 0, rmAreaID("small pond"+i), rmRandInt(2,4));
	}
	
	for(i=0; <numPond) {
		int decorationID=rmCreateObjectDef("decoration"+i);
		rmAddObjectDefItem(decorationID, "water decoration", rmRandInt(1,3), 6.0);
		rmSetObjectDefMinDistance(decorationID, 0.0);
		rmSetObjectDefMaxDistance(decorationID, rmXFractionToMeters(0.5));
		rmPlaceObjectDefInArea(decorationID, 0, rmAreaID("small pond"+i), rmRandInt(2,4));
	}
	
	int zebraID=rmCreateObjectDef("lonely deer");
	rmAddObjectDefItem(zebraID, "zebra", rmRandInt(1,2), 1.0);
	rmSetObjectDefMinDistance(zebraID, 0.0);
	rmSetObjectDefMaxDistance(zebraID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(zebraID, allObjConstraint);
	rmAddObjectDefConstraint(zebraID, startingSettleConstraint);
	rmAddObjectDefConstraint(zebraID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(zebraID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int loneGazelleID=rmCreateObjectDef("lonely deer2");
	rmAddObjectDefItem(loneGazelleID, "gazelle", 1, 0.0);
	rmSetObjectDefMinDistance(loneGazelleID, 0.0);
	rmSetObjectDefMaxDistance(loneGazelleID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(loneGazelleID, allObjConstraint);
	rmAddObjectDefConstraint(loneGazelleID, startingSettleConstraint);
	rmAddObjectDefConstraint(loneGazelleID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(loneGazelleID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int rockID=rmCreateObjectDef("rock small");
	rmAddObjectDefItem(rockID, "rock sandstone small", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, allObjConstraint);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID2, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, allObjConstraint);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
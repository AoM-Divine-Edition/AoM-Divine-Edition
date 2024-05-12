/*	Map Name: Megapolis.xs
**	Fast-Paced Ruleset: Savannah.xs
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
	rmTerrainInitialize("SavannahA");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest=rmDefineClass("forest");
	int classPlayer=rmDefineClass("player");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers < 8) {
		rmSetTeamSpacingModifier(0.25);
	} else if(cNumberNonGaiaPlayers < 11) {
		rmSetTeamSpacingModifier(0.40);
	} else {
		rmSetTeamSpacingModifier(0.50);
	}
	rmPlacePlayersSquare(0.30, 10.0, 10.0);
	rmRecordPlayerLocations();
	
	float playerFraction=rmAreaTilesToFraction(1000);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 2);
		rmSetAreaMinBlobDistance(id, 10.0);
		rmSetAreaMaxBlobDistance(id, 20.0);
		rmSetAreaCoherence(id, 0.6);
		rmSetAreaSmoothDistance(id, 30);
		rmAddAreaConstraint(id, playerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "EgyptianRoadA");
		rmAddAreaTerrainLayer(id, "SandA", 3, 5);
		rmAddAreaTerrainLayer(id, "SavannahC", 0, 2);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers*30*mapSizeMultiplier){
		int id3=rmCreateArea("Grass patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "SandA");
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		rmAddAreaConstraint(id3, playerConstraint);
		rmBuildArea(id3);
	}
	
	int pondClass=rmDefineClass("pond");
	int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 10.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int numPond=rmRandInt(2,4);
	for(i=0; <numPond*mapSizeMultiplier){
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
	
	int numTries=40*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(20), rmAreaTilesToFraction(80));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaTerrainType(elevID, "SavannahC");
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmAddAreaConstraint(elevID, avoidBuildings);
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
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement = rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint = rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 70.0);
	int farAvoidGold = rmCreateTypeDistanceConstraint("far gold avoid gold", "gold", 50.0);
	int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	
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
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	int closeID = -1;
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 40, 16, true); /* bool forward bool inside */
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
				rmSetAreaTerrainType(settleArea, "EgyptianRoadA");
				rmAddAreaTerrainLayer(settleArea, "SandA", 0, 8);
				rmAddAreaTerrainLayer(settleArea, "SavannahC", 8, 16);
				rmBuildArea(settleArea);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.34), 40, 16);
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
				rmSetAreaTerrainType(settlementArea, "EgyptianRoadA");
				rmAddAreaTerrainLayer(settlementArea, "SandA", 0, 8);
				rmAddAreaTerrainLayer(settlementArea, "SavannahC", 8, 16);
				rmBuildArea(settlementArea);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, shortEdgeConstraint);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
			for(attempt = 4; < 17){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 12*attempt);
			}
		
			farID=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, shortEdgeConstraint);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			for(attempt = 4; < 17){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 12*attempt);
			}
		}
	}
		
	if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.27), rmXFractionToMeters(0.35), 75, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidStart);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.27), rmXFractionToMeters(0.4), 80, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidStart);
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				for(FL = 0; < 2){
					id=rmCreateObjectDef("Giant settlement_"+p+"_"+FL);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.005, 0.005);
					rmSetAreaTerrainType(settlementArea2, "EgyptianRoadA");
					rmAddAreaTerrainLayer(settlementArea2, "SandA", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2, "SavannahC", 0, 2);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
				
				farID=rmCreateObjectDef("giant settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, shortEdgeConstraint);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 3; <= 7){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 25*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, shortEdgeConstraint);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 3; <= 7){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 25*attempt);
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
	rmAddObjectDefItem(startingHuntableID, "hippo", rmRandInt(3,4), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 22.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 20.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(8,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(startingChickenID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 15.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 20.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid all", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3,4));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 2;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(44.0+cNumberNonGaiaPlayers), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			if(rmRandFloat(0,1) > 0.5){
				rmSetAreaForestType(playerStartingForestID, "palm forest");
			} else {
				rmSetAreaForestType(playerStartingForestID, "Savannah forest");
			}
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.25);
			rmBuildArea(playerStartingForestID);
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
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmAddObjectDefConstraint(mediumGoldID, farAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, rmRandInt(1, 2));
	
	int numHuntable=rmRandInt(5, 6);
	int mediumDeerID=rmCreateObjectDef("medium gazelle");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(mediumDeerID, "gazelle", numHuntable, 4.0);
	} else {
		rmAddObjectDefItem(mediumDeerID, "giraffe", numHuntable, 4.0);
	}
	rmSetObjectDefMinDistance(mediumDeerID, 65.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 75.0);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumDeerID, avoidFood);
	rmAddObjectDefConstraint(mediumDeerID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumDeerID, false);
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFood);
	rmAddObjectDefConstraint(mediumGoatsID, avoidGold);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false, 2);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(3, 5));
	
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.2){
		rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(3,4), 3.0);
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(2,3), 3.0);
	} else if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(5,6), 2.0);
	} else if(bonusChance<0.9) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,4), 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(6,7), 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 85.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
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
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidFood);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidSettlement);
	rmPlaceObjectDefPerPlayer(bonusHuntable2ID, false);
	
	int farMonkeyID=rmCreateObjectDef("far monkeys");
	rmAddObjectDefItem(farMonkeyID, "baboon", rmRandInt(7,9), 4.0);
	rmSetObjectDefMinDistance(farMonkeyID, 70.0);
	rmSetObjectDefMaxDistance(farMonkeyID, 90.0);
	rmAddObjectDefConstraint(farMonkeyID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farMonkeyID, avoidFood);
	rmAddObjectDefConstraint(farMonkeyID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farMonkeyID, shortAvoidSettlement);
	if(rmRandFloat(0,1)<0.5) {
		rmPlaceObjectDefPerPlayer(farMonkeyID, false);
	}
	
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 80.0);
	rmSetObjectDefMaxDistance(farGoatsID, 150.0);
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoatsID, avoidFood);
	rmAddObjectDefConstraint(farGoatsID, avoidGold);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidSettlement);
	rmPlaceObjectDefPerPlayer(farGoatsID, false);
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 70.0);
	rmSetObjectDefMaxDistance(farBerriesID, 75.0);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, avoidFood);
	rmPlaceObjectDefPerPlayer(farBerriesID, false);
	
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
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 121", "gold", 50.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid food 121", "food", 30.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 121", "AbstractSettlement", 50.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 115.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 8.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
	
		int giantAvoidFood=rmCreateTypeDistanceConstraint("giant avoid other food sources", "food", 50.0);
		int giantAvoidGold=rmCreateTypeDistanceConstraint("giant avoid other gold sources", "gold", 70.0);
	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantGoldID, avoidFood);
		rmAddObjectDefConstraint(giantGoldID, giantAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("giant gold avoid settlements 121", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "elephant", 3, 5.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "rhinocerous", 4, 6.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.325));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		if(rmRandFloat(0,1) < 0.5){
			int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
			bonusChance=rmRandFloat(0, 1);
			if(bonusChance<0.5) {
				rmAddObjectDefItem(giantHuntableID, "Zebra", rmRandInt(4,5), 5.0);
			} else {
				rmAddObjectDefItem(giantHuntableID, "baboon", 8, 6.0);
			}
			rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.35));
			rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.4));
			rmAddObjectDefConstraint(giantHuntable2ID, avoidHuntable);
			rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
			rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidImpassableLand);
			rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
			rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
			rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidFood);
			rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		}
		
		int giantHuntable3ID=rmCreateObjectDef("giant huntable3");
		rmAddObjectDefItem(giantHuntable3ID, "Zebra", rmRandInt(4,5), 5.0);
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.4));
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.42));
		rmAddObjectDefConstraint(giantHuntable3ID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntable3ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable3ID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable3ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable3ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable3ID, giantAvoidFood);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, 1);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 120.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 35.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	failCount=0;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	numTries=15*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(150));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(250));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0,1) > 0.5){
			rmSetAreaForestType(forestID, "palm forest");
		} else {
			rmSetAreaForestType(forestID, "Savannah Forest");
		}
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
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid bush", "bush", 20.0);
	int bushID=rmCreateObjectDef("bush");
	rmAddObjectDefItem(bushID, "bush", 3, 4.0);
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID, avoidGrass);
	rmAddObjectDefConstraint(bushID, avoidAll);
	rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	// Text
	rmSetStatusText("",0.80);
	
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
	
	int deerID=rmCreateObjectDef("lonely deer");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(deerID, "zebra", rmRandInt(1,2), 1.0);
	} else {
		rmAddObjectDefItem(deerID, "giraffe", 1, 0.0);
	}
	rmSetObjectDefMinDistance(deerID, 0.0);
	rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(deerID, avoidAll);
	rmAddObjectDefConstraint(deerID, avoidBuildings);
	rmAddObjectDefConstraint(deerID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int deer2ID=rmCreateObjectDef("lonely deer2");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(deer2ID, "rhinocerous", 1, 1.0);
	} else {
		rmAddObjectDefItem(deer2ID, "gazelle", 1, 0.0);
	}
	rmSetObjectDefMinDistance(deer2ID, 0.0);
	rmSetObjectDefMaxDistance(deer2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(deer2ID, avoidAll);
	rmAddObjectDefConstraint(deer2ID, avoidBuildings);
	rmAddObjectDefConstraint(deer2ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(deer2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int rockID=rmCreateObjectDef("rock small");
	rmAddObjectDefItem(rockID, "rock sandstone small", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddAreaConstraint(rockID, avoidBuildings);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID2, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddAreaConstraint(rockID2, avoidBuildings);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
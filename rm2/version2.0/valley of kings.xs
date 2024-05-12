/*	Map Name: Valley Of The Kings.xs
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
	int playerTiles=8000;
	if(cMapSize == 1) {
		playerTiles = 10400;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 20800;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int sizel=0;
	int sizew=0;
	float handedness=rmRandFloat(0, 1);
	if(handedness<0.5) {
		sizel=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizew=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
	} else {
		sizew=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizel=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
	}
	rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
	rmSetMapSize(sizel, sizew);
	rmSetSeaLevel(0.0);
	rmSetSeaType("Egyptian Nile");
	rmTerrainInitialize("CliffEgyptianA", 9.0);
	
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
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(5), rmZTilesToFraction(5), rmXTilesToFraction((sizel*0.5)-5), rmZTilesToFraction((sizew*0.5)-5));
	int playerConstraint=0;
	if(cNumberNonGaiaPlayers < 10) {
		playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20.0);
	} else {
		playerConstraint=rmCreateClassDistanceConstraint("far stay away from players", classPlayer, 30.0);
	}
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int mapEdgeConstraint=rmCreateBoxConstraint("rock edge of map", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
	if(cMapSize == 2){
		int mec = 5+cNumberNonGaiaPlayers;
		mapEdgeConstraint=rmCreateBoxConstraint("giant rock edge of map", rmXTilesToFraction(mec), rmZTilesToFraction(mec), 1.0-rmXTilesToFraction(mec), 1.0-rmZTilesToFraction(mec));
	}
	int plainsID=rmCreateArea("sandy desert");
	rmSetAreaSize(plainsID, 0.9, 0.9);
	rmSetAreaLocation(plainsID, 0.5, 0.5);
	rmSetAreaTerrainType(plainsID, "SandA");
	rmAddAreaTerrainLayer(plainsID, "cliffEgyptianB", 0, 3);
	rmSetAreaMinBlobs(plainsID, 1*mapSizeMultiplier);
	rmSetAreaMaxBlobs(plainsID, 5*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(plainsID, 16.0);
	rmSetAreaMaxBlobDistance(plainsID, 40.0*mapSizeMultiplier);
	rmSetAreaCoherence(plainsID, 0.0);
	rmSetAreaSmoothDistance(plainsID, 10);
	rmSetAreaBaseHeight(plainsID, 2.0);
	rmSetAreaHeightBlend(plainsID, 2);
	rmAddAreaConstraint(plainsID, mapEdgeConstraint);
	rmBuildArea(plainsID);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers < 8) {
		rmSetTeamSpacingModifier(0.25);
	} else if(cNumberNonGaiaPlayers < 11){ 
		rmSetTeamSpacingModifier(0.40);
	} else {
		rmSetTeamSpacingModifier(0.50);
	}
	if(cMapSize == 2){
		rmPlacePlayersSquare(0.25, 10.0, 10.0);
	} else {
		rmPlacePlayersSquare(0.30, 10.0, 10.0);
	}
	rmRecordPlayerLocations();
	
	float playerFraction=rmAreaTilesToFraction(1000);
	for(i=1; <cNumberPlayers) {
		// Create the area.
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaCoherence(id, 0.0);
		rmAddAreaConstraint(id, playerConstraint);
		rmAddAreaConstraint(id, mapEdgeConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SandC");
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers*5*mapSizeMultiplier) {
		int id2=rmCreateArea("Patch "+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaTerrainType(id2, "SandB");
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 5.0);
		rmSetAreaMaxBlobDistance(id2, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		rmAddAreaConstraint(id2, mapEdgeConstraint);
		rmBuildArea(id2);
	}
	
	// Beautification sub area.
	for(i=1; <cNumberPlayers*5*mapSizeMultiplier){
		int id3=rmCreateArea("Dirt Patch "+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "SandDirt50");
		rmSetAreaMinBlobs(id3, 2*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 2*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 5.0);
		rmSetAreaMaxBlobDistance(id3, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		rmAddAreaConstraint(id3, mapEdgeConstraint);
		rmBuildArea(id3);
	}
	
	int numTries=5*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries){
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmSetAreaTerrainType(elevID, "SandD");
		rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 7.0));
		rmSetAreaHeightBlend(elevID, 2);
		rmAddAreaConstraint(elevID, edgeConstraint);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		
		if(rmBuildArea(elevID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==5) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	numTries=12*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, edgeConstraint);
		
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
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int migdolStartingSettleConstraint=rmCreateClassDistanceConstraint("migdol keep way away from player", rmClassID("starting settlement"), 70.0);
	int avoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 20.0);
	int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 20.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	int avoidTree=rmCreateTypeDistanceConstraint("stay out of the woods", "tree", 6.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	
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
			
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 40, 16);
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
				rmSetAreaTerrainType(settleArea, "SandA");
				rmAddAreaTerrainLayer(settleArea, "SandC", 0, 8);
				rmAddAreaTerrainLayer(settleArea, "SandB", 8, 16);
				rmBuildArea(settleArea);
			}
			rmResetFairLocs();
		
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.29), rmXFractionToMeters(0.32), 40, 16);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidStart);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "SandA");
				rmAddAreaTerrainLayer(settlementArea, "SandC", 0, 8);
				rmAddAreaTerrainLayer(settlementArea, "SandB", 8, 16);
				rmBuildArea(settlementArea);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
			for(attempt = 5; <= 11){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 10*attempt);
			}
		
			farID=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			for(attempt = 6; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 15*attempt);
			}
		}
	} rmResetFairLocs();
		
	if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.26), rmXFractionToMeters(0.38), 70, 20);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		if(cNumberNonGaiaPlayers == 2){
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.35), rmXFractionToMeters(0.45), 80, 20);
		} else {
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.23), rmXFractionToMeters(0.4), 70+(3*cNumberNonGaiaPlayers), 20);
		}
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				for(FL = 0; < 2){
					id=rmCreateObjectDef("Giant settlement_"+p+"_"+FL);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.005, 0.005);
					rmSetAreaTerrainType(settlementArea2, "SandA");
					rmAddAreaTerrainLayer(settlementArea2, "SandC", 4, 6);
					rmAddAreaTerrainLayer(settlementArea2, "SandB", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2, "SandA", 0, 2);
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
				for(attempt = 3; <= 7){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 25*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
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
	
	// Place Gold and Migdols
	rmResetFairLocs();
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 30.0);
	if(cNumberNonGaiaPlayers > 8){
		id2=rmAddFairLoc("Gold and Migdol", true, true,  70, 100, 50, 15); /* bool forward bool inside */
	} else {
		id2=rmAddFairLoc("Gold and Migdol", true, true,  100, 200, 50, 15);
	}
	rmAddFairLocConstraint(id2, farAvoidSettlement);
	rmAddFairLocConstraint(id2, migdolStartingSettleConstraint);
	
	
	if(rmPlaceFairLocs()) {
		id2=rmCreateObjectDef("fair gold and migdols");
		rmAddObjectDefItem(id2, "Bandit Migdol", 1, 0.0);
		rmAddObjectDefItem(id2, "Gold mine", 3, 10.0);
		rmAddObjectDefItem(id2, "statue pharaoh", 2, 12.0);
		
		for(i=1; <cNumberPlayers) {
			for(j=0; <rmGetNumberFairLocs(i)) {
				rmPlaceObjectDefAtLoc(id2, 0, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
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
	rmAddObjectDefItem(startingHuntableID, "hippo", rmRandInt(2,3), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);

	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(5,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 21.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("straggler trees", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3,4));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 15.0);
	
	int maxNum = 4;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(48.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip && cNumberNonGaiaPlayers > 2){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(75+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "Palm forest");
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
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false);

	int mediumZebraID=rmCreateObjectDef("medium zebra");
	rmAddObjectDefItem(mediumZebraID, "zebra", rmRandInt(6,7), 4.0);
	rmSetObjectDefMinDistance(mediumZebraID, 65.0);
	rmSetObjectDefMaxDistance(mediumZebraID, 75.0);
	rmAddObjectDefConstraint(mediumZebraID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumZebraID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumZebraID, avoidBuildings);
	rmPlaceObjectDefPerPlayer(mediumZebraID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Bandit Gold then gold then food (hunt, herd, predator).
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
	
	int farBanditID=rmCreateObjectDef("migdol and gold");
	rmAddObjectDefItem(farBanditID, "Bandit Migdol", 1, 0.0);
	rmAddObjectDefItem(farBanditID, "Gold mine", 3, 10.0);
	rmAddObjectDefItem(farBanditID, "statue pharaoh", 2, 12.0);
	rmSetObjectDefMinDistance(farBanditID, 0.0);
	rmSetObjectDefMaxDistance(farBanditID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farBanditID, rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 70.0));
	rmAddObjectDefConstraint(farBanditID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBanditID, migdolStartingSettleConstraint);
	rmAddObjectDefConstraint(farBanditID, farAvoidImpassableLand);
	if(cNumberNonGaiaPlayers<3) {
		rmPlaceObjectDefAtLoc(farBanditID, 0, 0.5, 0.5, rmRandInt(1,2));
	} else {
		rmPlaceObjectDefAtLoc(farBanditID, 0, 0.5, 0.5, rmRandInt(2,4));
	}
	
	if(cMapSize == 2){
		rmPlaceObjectDefAtLoc(farBanditID, 0, 0.5, 0.5, rmRandInt(1,2));
	}
	
	int farGoldID=rmCreateObjectDef("unguarded gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 0.0);
	rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farGoldID, rmCreateTypeDistanceConstraint("medium avoid gold", "gold", 40.0));
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, farAvoidImpassableLand);
	if(cNumberNonGaiaPlayers<3) {
		rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, rmRandInt(2,3));
	} else {
		rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}

	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "elephant", 2, 4.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", 4, 5.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "zebra", 6, 5.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 65.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 75.0);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 8.0);
	
	int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID2, "elephant", 1, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID2, "hippo", 2, 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID2, "hippo", 4, 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID2, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID2, 90.0);
	rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, nearShore);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidGold);
	rmPlaceObjectDefPerPlayer(bonusHuntableID2, false);
	
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 80.0);
	rmSetObjectDefMaxDistance(farGoatsID, 150.0);
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(farGoatsID, avoidGold);
	rmPlaceObjectDefPerPlayer(farGoatsID, false, 2);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "hyena", 3, 2.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, avoidFoodFar);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 119", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 119", "AbstractSettlement", 50.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);
	
	int farCrocsID=rmCreateObjectDef("far Crocs");
	rmAddObjectDefItem(farCrocsID, "crocodile", 2, 1.0);
	rmSetObjectDefMinDistance(farCrocsID, 0.0);
	rmSetObjectDefMaxDistance(farCrocsID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farCrocsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farCrocsID, nearShore);
	rmAddObjectDefConstraint(farCrocsID, avoidGold);
	rmPlaceObjectDefPerPlayer(farCrocsID, false);

	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 115.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 119", "gold", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 2);
		
		int avoidGiantHuntable = rmCreateTypeDistanceConstraint("giant avoid food", "food", 55.0);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "elephant", 2, 4.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntableID, "giraffe", 4, 5.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "zebra", 6, 5.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, avoidGiantHuntable);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, avoidTree);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable2ID, "elephant", 1, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable2ID, "hippo", 2, 2.0);
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "hippo", 4, 3.0);
		}
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGiantHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidTree);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 100.0));
		rmAddObjectDefConstraint(giantRelixID, edgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int pondClass=rmDefineClass("pond");
	int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 10.0);
	int pondAvoidBuildings=rmCreateTypeDistanceConstraint("ponds avoid buildings", "Building", 30.0);
	int numPonds2=0;
	
	if(cNumberNonGaiaPlayers < 6 && cMapSize != 2) {
		numPonds2 = rmRandInt(2,4);
	} else {
		numPonds2 = rmRandInt(4,7);
	}
	
	for(i=0; <numPonds2) {
		int smallPondID=rmCreateArea("small pond"+i);
		rmSetAreaSize(smallPondID, rmAreaTilesToFraction(600), rmAreaTilesToFraction(800));
		rmSetAreaWaterType(smallPondID, "egyptian nile");
		rmSetAreaBaseHeight(smallPondID, 0.0);
		rmSetAreaMinBlobs(smallPondID, 2);
		rmSetAreaMaxBlobs(smallPondID, 2);
		rmSetAreaMinBlobDistance(smallPondID, 10.0);
		rmSetAreaMaxBlobDistance(smallPondID, 10.0);
		rmSetAreaSmoothDistance(smallPondID, 50);
		rmAddAreaToClass(smallPondID, pondClass);
		rmAddAreaConstraint(smallPondID, mapEdgeConstraint);
		rmAddAreaConstraint(smallPondID, playerConstraint);
		rmAddAreaConstraint(smallPondID, pondConstraint);
		rmAddAreaConstraint(smallPondID, pondAvoidBuildings);
		rmSetAreaWarnFailure(smallPondID, false);
		rmBuildArea(smallPondID);
	}
	
	int inPond=rmCreateTerrainMaxDistanceConstraint("papyrus near shore", "land", true, 4.0);
	int papyrusID=rmCreateObjectDef("papyrus");
	rmAddObjectDefItem(papyrusID, "papyrus", 1, 0.0);
	rmSetObjectDefMinDistance(papyrusID, 0.0);
	rmSetObjectDefMaxDistance(papyrusID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefAtLoc(papyrusID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", classForest, 20.0);
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "abstractSettlement", 20.0);
	int forestAvoidBuildings=rmCreateTypeDistanceConstraint("forest avoid buildings", "Building", 15.0);
	int count=0;
	numTries=4*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.75*numTries;
	}
	
	failCount=0;
	for(i=0; <numTries) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(400));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "palm forest");
		rmAddAreaConstraint(forestID, farStartingSettleConstraint);
		rmAddAreaConstraint(forestID, forestAvoidBuildings);
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, shortAvoidImpassableLand);
		rmAddAreaConstraint(forestID, mapEdgeConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmBuildArea(forestID)==false) {
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
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	int skeletonID=rmCreateObjectDef("skeleton");
	rmAddObjectDefItem(skeletonID, "skeleton", 1, 0.0);
	rmSetObjectDefMinDistance(skeletonID, 0.0);
	rmSetObjectDefMaxDistance(skeletonID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(skeletonID, avoidAll);
	rmAddObjectDefConstraint(skeletonID, avoidBuildings);
	rmAddObjectDefConstraint(skeletonID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(skeletonID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
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
	
	int columnID=rmCreateObjectDef("columns");
	rmAddObjectDefItem(columnID, "columns broken", rmRandInt(1,2), 3.0);
	rmSetObjectDefMinDistance(columnID, 0.0);
	rmSetObjectDefMaxDistance(columnID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(columnID, avoidAll);
	rmAddObjectDefConstraint(columnID, avoidBuildings);
	rmAddObjectDefConstraint(columnID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(columnID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	int baboonID=rmCreateObjectDef("lonely baboon");
	rmAddObjectDefItem(baboonID, "baboon", rmRandInt(1,2), 1.0);
	rmSetObjectDefMinDistance(baboonID, 0.0);
	rmSetObjectDefMaxDistance(baboonID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(baboonID, avoidAll);
	rmAddObjectDefConstraint(baboonID, avoidBuildings);
	rmAddObjectDefConstraint(baboonID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(baboonID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	for(i=0; < cNumberNonGaiaPlayers+cMapSize) {
		int statueID=rmCreateObjectDef("statue"+i);
		if(rmRandFloat(0,1)<0.33) {
			rmAddObjectDefItem(statueID, "statue pharaoh", 1, 0.0);
		} else if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(statueID, "statue lion left", 1, 0.0);
		} else {
			rmAddObjectDefItem(statueID, "statue lion right", 1, 0.0);
		}
		rmSetObjectDefMinDistance(statueID, 0.0);
		rmSetObjectDefMaxDistance(statueID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(statueID, avoidAll);
		rmAddObjectDefConstraint(statueID, avoidBuildings);
		rmAddObjectDefConstraint(statueID, avoidImpassableLand);
		rmPlaceObjectDefAtLoc(statueID, 0, 0.5, 0.5, 1);
	}
	
	rmSetStatusText("",1.0);
}
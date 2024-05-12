/*	Map Name: River Nile.xs
**	Fast-Paced Ruleset: Watering Hole.xs
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
		sizel=2.5*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizew=1.6*sqrt(cNumberNonGaiaPlayers*playerTiles);
	} else {
		sizew=2.66*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizel=1.5*sqrt(cNumberNonGaiaPlayers*playerTiles);
	}
	rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
	rmSetMapSize(sizel, sizew);
	rmSetSeaLevel(0.0);
	rmSetSeaType("Egyptian Nile");
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest=rmDefineClass("forest");
	int classPlayer=rmDefineClass("player");
	int classPlayerCore=rmDefineClass("player core");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	if(cNumberTeams > 7) {
		avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land by less", "land", false, 6.0);
	}
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int teamClass=rmDefineClass("teamClass");
	int baseRiverWidth = 0;
	if (cNumberTeams < 4){
		baseRiverWidth = 45;
	} else if (cNumberTeams < 7) {
		baseRiverWidth = 30;
	} else {
		baseRiverWidth = 30;
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	rmSetTeamSpacingModifier(0.75);
	
	if(cNumberTeams < 3) {
		rmPlacePlayersSquare(0.35, 0.05, 10.0);
	} else {
		rmPlacePlayersSquare(0.4, 0.05, 10.0);
	}
	rmRecordPlayerLocations();
	
	int teamConstraint=rmCreateClassDistanceConstraint("team constraint", teamClass, baseRiverWidth);
	
	float percentPerPlayer = 0.95/cNumberNonGaiaPlayers;
	float teamSize = 0;
	for(i=0; <cNumberTeams*mapSizeMultiplier) {
		int teamID=rmCreateArea("team"+i);
		teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
		rmEchoInfo ("team size "+teamSize);
		rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
		rmSetAreaWarnFailure(teamID, false);
		rmSetAreaTerrainType(teamID, "SandA");
		rmSetAreaMinBlobs(teamID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(teamID, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(teamID, 16.0);
		rmSetAreaMaxBlobDistance(teamID, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(teamID, 0.0);
		rmAddAreaToClass(teamID, teamClass);
		rmSetAreaBaseHeight(teamID, 3.0);
		rmSetAreaHeightBlend(teamID, 2);
		rmAddAreaConstraint(teamID, teamConstraint);
		rmSetAreaSmoothDistance(teamID, 10);
		rmSetAreaLocTeam(teamID, i);
	}
	rmBuildAllAreas();
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);
	int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
	if(cNumberTeams > 7) {
		farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land by not so much", "land", false, 8.0);
	}
	
	float playerFraction=rmAreaTilesToFraction(3000);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
		rmSetPlayerArea(i, id);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmSetAreaSize(id, 1, 1);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 3*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id, 4*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id, 1.0);
		rmAddAreaConstraint(id, playerConstraint);
		rmAddAreaConstraint(id, farAvoidImpassableLand);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SandC");
	}
	
	// Build the areas.
	rmBuildAllAreas();
	
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers){
		// Beautification sub area.
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaTerrainType(id2, "SandB");
		
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id2, 5.0);
		rmSetAreaMaxBlobDistance(id2, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		rmBuildArea(id2);
	}
	
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int failCount=0;
	int numTries=20*cNumberNonGaiaPlayers;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmAddAreaConstraint(elevID, avoidBuildings);
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
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
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar=rmCreateTypeDistanceConstraint("avoid food by more", "food", 30.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 10.0);
	
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
	
	int stayID = -1;
	int closeID = -1;
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 55, 65, 40, 16, true);
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
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.28), rmXFractionToMeters(0.31), 40, 16);
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
		
			stayID = rmCreateAreaConstraint("stay in island player"+p, rmAreaID("team"+rmGetPlayerTeam(p)));
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
			rmAddObjectDefConstraint(closeID, stayID);
			for(attempt = 1; < 25){
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
			rmAddObjectDefConstraint(farID, stayID);
			for(attempt = 1; < 25){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 10*attempt);
			}
		}
	} rmResetFairLocs();
	
	if(cMapSize == 2){
	
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by giant long distance", "AbstractSettlement", 65.0);
	
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.4), 70, 16, false, true);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.45), 70, 16, false, true);
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
					rmSetAreaSize(settlementArea2, 0.01, 0.01);
					rmSetAreaTerrainType(settlementArea2, "SandA");
					rmAddAreaTerrainLayer(settlementArea2, "SandC", 0, 8);
					rmAddAreaTerrainLayer(settlementArea2, "SandB", 8, 16);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
				
				stayID = rmCreateAreaConstraint("giant stay in island player"+p, rmAreaID("team"+rmGetPlayerTeam(p)));
				
				farID=rmCreateObjectDef("giant settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, stayID);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 1; < 25){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 10*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, stayID);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 1; < 25){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 10*attempt);
				}
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 28.0);
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 26.0));
	rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);
	
	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);
	
	int shortAvoidStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int closeHippoID=rmCreateObjectDef("close Hippo");
	float hippoNumber=rmRandFloat(0, 1);
	if(hippoNumber<0.3) {
		rmAddObjectDefItem(closeHippoID, "hippo", 1, 1.0);
	} else if(hippoNumber<0.6) {
		rmAddObjectDefItem(closeHippoID, "hippo", 2, 4.0);
	} else {
		rmAddObjectDefItem(closeHippoID, "rhinocerous", 1, 1.0);
	}
	rmSetObjectDefMinDistance(closeHippoID, 23.0);
	rmSetObjectDefMaxDistance(closeHippoID, 30.0);
	rmAddObjectDefConstraint(closeHippoID, getOffTheTC);
	rmAddObjectDefConstraint(closeHippoID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeHippoID, shortAvoidStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closeHippoID, false);
	
	int closeGoatsID=rmCreateObjectDef("close Goats");
	rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
	rmSetObjectDefMinDistance(closeGoatsID, 25.0);
	rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
	rmAddObjectDefConstraint(closeGoatsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeGoatsID, getOffTheTC);
	rmAddObjectDefConstraint(closeGoatsID, avoidFood);
	rmAddObjectDefConstraint(closeGoatsID, shortAvoidStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closeGoatsID, true);
	
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(5,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 21.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid all", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 3;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(45.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "palm forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.45);
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
	rmSetObjectDefMinDistance(mediumGoldID, 55.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 60.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGoatsID, avoidGold);
	rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(mediumGoatsID, 0, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
	}
	
	int numHuntable=rmRandInt(6, 10);
	int mediumGazelleID=rmCreateObjectDef("medium gazelles");
	rmAddObjectDefItem(mediumGazelleID, "gazelle", numHuntable, 4.0);
	rmSetObjectDefMinDistance(mediumGazelleID, 55.0);
	rmSetObjectDefMaxDistance(mediumGazelleID, 75.0);
	rmAddObjectDefConstraint(mediumGazelleID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGazelleID, avoidGold);
	rmAddObjectDefConstraint(mediumGazelleID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGazelleID, farStartingSettleConstraint);
	
	int mediumZebraID=rmCreateObjectDef("medium zebra");
	rmAddObjectDefItem(mediumZebraID, "zebra", numHuntable, 4.0);
	rmSetObjectDefMinDistance(mediumZebraID, 65.0);
	rmSetObjectDefMaxDistance(mediumZebraID, 80.0);
	rmAddObjectDefConstraint(mediumZebraID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumZebraID, avoidGold);
	rmAddObjectDefConstraint(mediumZebraID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumZebraID, farStartingSettleConstraint);
	
	// Gazelle or zebra.  Flip a coin.
	for(i=1; <cNumberPlayers) {
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmPlaceObjectDefAtLoc(mediumGazelleID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else {
			rmPlaceObjectDefAtLoc(mediumZebraID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
		}
	}
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 110.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidHerdable);
	rmAddObjectDefConstraint(farGoldID, avoidHuntable);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("team"+rmGetPlayerTeam(i)), 3);
	}
	
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 80.0);
	rmSetObjectDefMaxDistance(farGoatsID, 105.0);
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoatsID, avoidHerdable);
	rmAddObjectDefConstraint(farGoatsID, avoidGold);
	rmAddObjectDefConstraint(farGoatsID, avoidFood);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farGoatsID, 0, rmAreaID("player"+i));
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "elephant", 2, 4.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", 3, 6.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "zebra", 6, 8.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 85.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 90.0+(2*cNumberNonGaiaPlayers-4));
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i));
	}
	
	int bonusHuntableID2=rmCreateObjectDef("bonus huntable2");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID2, "water buffalo", 4, 2.0);
	} else if(bonusChance<0.75) {
		rmAddObjectDefItem(bonusHuntableID2, "hippo", 2, 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID2, "hippo", 4, 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID2, 60.0);
	rmSetObjectDefMaxDistance(bonusHuntableID2, 110.0);
	rmAddObjectDefConstraint(bonusHuntableID2, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID2, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidGold);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(bonusHuntableID2, 0, rmAreaID("team"+rmGetPlayerTeam(i)));
	}
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 35.0);
	rmSetObjectDefMaxDistance(farBerriesID, 85.0);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, avoidFood);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers/2);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "crocodile", 2, 2.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "crocodile", 1, 0.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements", "AbstractSettlement", 40.0));
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("team"+rmGetPlayerTeam(i)));
	}
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i));
	}
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, 600.0);
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 22.0+(4*cMapSize));
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - perch", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, 600.0);
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantGoldID, avoidGold);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid settlements", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 2);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "water buffalo", 4, 4.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntableID, "hippo", 3, 3.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "hippo", 4, 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidFood);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable2ID, "elephant", 2, 4.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable2ID, "giraffe", 3, 6.0);
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "zebra", 6, 8.0);
		}
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidFood);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 15.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int forestTCs = rmCreateTypeDistanceConstraint("forest vs settle", "abstractSettlement", 15.0);
	
	failCount=0;
	numTries=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.75*numTries;
	}
	
	for(i=0; <numTries) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(120));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(180), rmAreaTilesToFraction(220));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "palm forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, forestTCs);
		rmAddAreaConstraint(forestID, shortAvoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		// Hill trees?
		if(rmRandFloat(0.0, 1.0)<0.2) {
			rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
		}
		
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
	int papyrusID=rmCreateObjectDef("lone papyrus");
	int nearshore=rmCreateTerrainMaxDistanceConstraint("papyrus near shore", "land", true, 4.0);
	rmAddObjectDefItem(papyrusID, "papyrus", 3, 2.0);
	rmSetObjectDefMinDistance(papyrusID, 0.0);
	rmSetObjectDefMaxDistance(papyrusID, 600.0);
	rmAddObjectDefConstraint(papyrusID, avoidAll);
	rmAddObjectDefConstraint(papyrusID, nearshore);
	rmPlaceObjectDefAtLoc(papyrusID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
	
	int papyrus2ID=rmCreateObjectDef("grouped papyrus");
	rmAddObjectDefItem(papyrus2ID, "papyrus", 5, 7.0);
	rmSetObjectDefMinDistance(papyrus2ID, 0.0);
	rmSetObjectDefMaxDistance(papyrus2ID, 600.0);
	rmAddObjectDefConstraint(papyrus2ID, avoidAll);
	rmAddObjectDefConstraint(papyrus2ID, nearshore);
	rmPlaceObjectDefAtLoc(papyrus2ID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	int lilyID=rmCreateObjectDef("pads");
	rmAddObjectDefItem(lilyID, "water lilly", 4, 2.0);
	rmSetObjectDefMinDistance(lilyID, 0.0);
	rmSetObjectDefMaxDistance(lilyID, 600.0);
	rmAddObjectDefConstraint(lilyID, avoidAll);
	rmPlaceObjectDefAtLoc(lilyID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);
	
	int lily2ID=rmCreateObjectDef("mo' pads");
	rmAddObjectDefItem(lily2ID, "water lilly", 1, 0.0);
	rmSetObjectDefMinDistance(lily2ID, 0.0);
	rmSetObjectDefMaxDistance(lily2ID, 600.0);
	rmAddObjectDefConstraint(lily2ID, avoidAll);
	rmPlaceObjectDefAtLoc(lily2ID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, 600.0);
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	int bushID=rmCreateObjectDef("big bush patch");
	rmAddObjectDefItem(bushID, "bush", 4, 3.0);
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, 600.0);
	rmAddObjectDefConstraint(bushID, avoidAll);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int bush2ID=rmCreateObjectDef("small bush patch");
	rmAddObjectDefItem(bush2ID, "bush", 3, 2.0);
	rmAddObjectDefItem(bush2ID, "rock sandstone sprite", 1, 2.0);
	rmSetObjectDefMinDistance(bush2ID, 0.0);
	rmSetObjectDefMaxDistance(bush2ID, 600.0);
	rmAddObjectDefConstraint(bush2ID, avoidAll);
	rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	
	int nearRiver=rmCreateTerrainMaxDistanceConstraint("near river", "water", true, 5.0);
	int riverBushID=rmCreateObjectDef("bushs by river");
	rmAddObjectDefItem(riverBushID, "bush", 3, 3.0);
	rmAddObjectDefItem(riverBushID, "grass", 7, 8.0);
	rmSetObjectDefMinDistance(riverBushID, 0.0);
	rmSetObjectDefMaxDistance(riverBushID, 600.0);
	rmAddObjectDefConstraint(riverBushID, avoidAll);
	rmAddObjectDefConstraint(riverBushID, nearRiver);
	rmPlaceObjectDefAtLoc(riverBushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

	
	rmSetStatusText("",1.0);
}
/*	Map Name: Regicide.xs
**	Fast-Paced ???.xs
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
		sizel=2.4*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizew=2.1*sqrt(cNumberNonGaiaPlayers*playerTiles);
	} else {
		sizew=2.4*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizel=2.1*sqrt(cNumberNonGaiaPlayers*playerTiles);
	}
	rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
	rmSetMapSize(sizel, sizew);
	rmSetSeaLevel(0.0);
	rmSetSeaType("Yellow River Shallow");
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest=rmDefineClass("forest");
	int classPlayer=rmDefineClass("player");
	int classPlayerCore=rmDefineClass("player core");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classBack = rmDefineClass("backward TC");
	
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

	rmCreateTrigger("Initial");
	rmSwitchToTrigger(rmTriggerID("Initial"));
	rmSetTriggerActive(true);
	rmSetTriggerPriority(3);
	rmSetTriggerLoop(false);
	//chat(true, "{{80001}}", true);
	chat(true, "{{50485}}", true);
	
	for(i=1; <cNumberPlayers) {
		rmCreateTrigger("Loss" +i);
		rmSwitchToTrigger(rmTriggerID("Loss"+i));
		rmSetTriggerActive(true);
		rmSetTriggerPriority(3);
		rmSetTriggerLoop(false);
		condition("trPlayerUnitCountSpecific("+i+", \"Regent\") < 1");
		chat(true, "{PlayerNameString("+i+",22612)}", true);
		code("trSetPlayerDefeated("+i+");");
	}
	
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
	
	rmSetTeamSpacingModifier(0.925);
	
	if(cNumberTeams < 3) {
		rmPlacePlayersSquare(0.35, 0.05, 10.0);
	} else {
		rmPlacePlayersSquare(0.4, 0.05, 10.0);
	}
	rmRecordPlayerLocations();
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, baseRiverWidth);
	int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land", "land", false, 20.0);
	if(cNumberTeams > 7) {
		farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("far avoid impassable land by not so much", "land", false, 8.0);
	}
	
	float playerFraction=rmAreaTilesToFraction(3000);
	for(i=1; <cNumberPlayers) {
		
		if(rmGetPlayerCulture(i) == cCultureGreek){
			location_lib = 1;
		} else if(rmGetPlayerCulture(i) == cCultureNorse) {
			location_lib = 2;
		} else if(rmGetPlayerCulture(i) == cCultureEgyptian) {
			location_lib = 0;
		} else if(rmGetPlayerCulture(i) == cCultureAtlantean) {
			location_lib = 4;
		} else {
			location_lib = 5;
		}
		initiateLocation();
		
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmSetAreaSize(id, 1, 1);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 3);
		rmSetAreaMaxBlobs(id, 4);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaCoherence(id, 1.0);
		rmAddAreaConstraint(id, playerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, terrainBeauty);
		rmAddAreaTerrainLayer(id, terrainType1, 13, 20);
		rmAddAreaTerrainLayer(id, terrainType2, 6, 13);
		rmAddAreaTerrainLayer(id, terrainType3, 0, 6);
		rmSetAreaBaseHeight(id, 3.0);
		rmSetAreaHeightBlend(id, 2);
		rmSetAreaSmoothDistance(id, 10);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 55.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int goldAvoidGold=rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 40.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
	int farAvoidFood=rmCreateTypeDistanceConstraint("far avoid food", "food", 30.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid bonus huntable", "huntable", 50.0);
	int superAvoidFood=rmCreateTypeDistanceConstraint("avoid bonus food", "food", 50.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree avoid", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree avoid gold", "gold", 6.0);
	int superAvoidImpassableLand=rmCreateTerrainDistanceConstraint("super far avoid impassable land", "land", false, 30.0);
	
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
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCback = rmCreateClassDistanceConstraint("TC avoid back TC", classBack, 75.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			if(rmGetPlayerCulture(p) == cCultureGreek){
				location_lib = 1;
			} else if(rmGetPlayerCulture(p) == cCultureNorse) {
				location_lib = 2;
			} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
				location_lib = 0;
			} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
				location_lib = 4;
			} else {
				location_lib = 5;
			}
			initiateLocation();
			
			id=rmAddFairLoc("Settlement", false, true, 60, 80, 40, 16);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCavoidStart);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(id, classBack);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, terrainBeauty);
				rmAddAreaTerrainLayer(settleArea, terrainType1, 5, 8);
				rmAddAreaTerrainLayer(settleArea, terrainType2, 2, 5);
				rmAddAreaTerrainLayer(settleArea, terrainType3, 0, 2);
				rmBuildArea(settleArea);
			} else {
				int closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefToClass(closeID, classBack);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidStart);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt);
				}
			}
			rmResetFairLocs();
		
			id=rmAddFairLoc("Settlement", true, false,  80, 100, 40, 16);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidStart);
			rmAddFairLocConstraint(id, TCavoidWater);
			if(cNumberNonGaiaPlayers == 2){
				rmAddFairLocConstraint(id, TCback);
			}
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, terrainBeauty);
				rmAddAreaTerrainLayer(settlementArea, terrainType1, 5, 8);
				rmAddAreaTerrainLayer(settlementArea, terrainType2, 2, 5);
				rmAddAreaTerrainLayer(settlementArea, terrainType3, 0, 2);
				rmBuildArea(settlementArea);
			} else {
				int farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidWater);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				if(cNumberNonGaiaPlayers == 2){
					rmAddObjectDefConstraint(farID, TCback);
				}
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt);
				}
			}
			rmResetFairLocs();
		}
	}
		
	if(cMapSize == 2){
		
		int TCGiantSettlement = rmCreateTypeDistanceConstraint("Giant TC avoid TC", "AbstractSettlement", 75.0+(5*cNumberNonGaiaPlayers));
		int TCGiantStart = rmCreateClassDistanceConstraint("Giant TC avoid starting", classStartingSettlement, 150.0);
		int unclaimedGiantSettlementID = -1;
		int remainInPlayerArea = -1;
		
		int maxAttempts = 5;
		if( cNumberNonGaiaPlayers < 3){
			maxAttempts = 25;
		} else if(cNumberNonGaiaPlayers <= 5){
			maxAttempts = 25;
		} else if(cNumberNonGaiaPlayers <= 7){
			maxAttempts = 20;
		} else if(cNumberNonGaiaPlayers <= 9){
			maxAttempts = 15;
		}
		
		for(p = 1; <= cNumberNonGaiaPlayers){
			if(rmGetPlayerCulture(p) == cCultureGreek){
				location_lib = 1;
			} else if(rmGetPlayerCulture(p) == cCultureNorse) {
				location_lib = 2;
			} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
				location_lib = 0;
			} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
				location_lib = 4;
			} else {
				location_lib = 5;
			}
			initiateLocation();
			//remainInPlayerArea = rmCreateAreaMaxDistanceConstraint("remain within are of player"+p, rmAreaID("Player"+p), rmXFractionToMeters(playerFraction));
			
			for(t = 0; < 2){
				
				unclaimedGiantSettlementID = rmCreateObjectDef("Giant settlement p"+p+" "+t);
				rmAddObjectDefItem(unclaimedGiantSettlementID, "Settlement", 1, 1.0);
				rmSetObjectDefMinDistance(unclaimedGiantSettlementID, rmXFractionToMeters(0.35));
				rmSetObjectDefMaxDistance(unclaimedGiantSettlementID, rmXFractionToMeters(0.45));
				rmAddObjectDefConstraint(unclaimedGiantSettlementID, shortEdgeConstraint);
				rmAddObjectDefConstraint(unclaimedGiantSettlementID, TCGiantSettlement);
				rmAddObjectDefConstraint(unclaimedGiantSettlementID, remainInPlayerArea);
				rmAddObjectDefConstraint(unclaimedGiantSettlementID, TCGiantStart);
				rmAddObjectDefConstraint(unclaimedGiantSettlementID, TCavoidWater);
				if(cNumberNonGaiaPlayers <= 4){
					for(playerConstMaker = 1; <= cNumberNonGaiaPlayers){
						if(playerConstMaker == p){
							continue;
						}
						rmAddObjectDefConstraint(unclaimedGiantSettlementID, rmCreateAreaDistanceConstraint("P"+p+" avoid P"+playerConstMaker, rmAreaID("Player"+playerConstMaker), 1.0));
					}
				}
				
				for(attempt = 1; < maxAttempts){
					rmPlaceObjectDefAtLoc(unclaimedGiantSettlementID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(unclaimedGiantSettlementID) > 0){
						break;
					}
				}
				
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int kingID=rmCreateObjectDef("King");
	rmAddObjectDefItem(kingID, "Regent", 1, 3.0);
	rmSetObjectDefMinDistance(kingID, 8.0);
	rmSetObjectDefMaxDistance(kingID, 16.0);
	rmPlaceObjectDefPerPlayer(kingID, true);
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID = -1;
	for(p=1;<=cNumberNonGaiaPlayers){
		
		if(rmGetPlayerCulture(p) == cCultureGreek){
			location_lib = 1;
		} else if(rmGetPlayerCulture(p) == cCultureNorse) {
			location_lib = 2;
		} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
			location_lib = 0;
		} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
			location_lib = 4;
		} else {
			location_lib = 5;
		}
		initiateLocation();
		
		startingHuntableID=rmCreateObjectDef("starting hunt"+p);
		rmAddObjectDefItem(startingHuntableID, mainHunt, 5, 3.0);
		rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
		rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
		rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
		 rmPlaceObjectDefAtLoc(startingHuntableID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
	}
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 1.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	int forestVsHunt = rmCreateTypeDistanceConstraint("starting forest vs hunt", "food", 8.0);
	
	int maxNum = 4;
	for(p=1;<=cNumberNonGaiaPlayers){
		
		if(rmGetPlayerCulture(p) == cCultureGreek){
			location_lib = 1;
		} else if(rmGetPlayerCulture(p) == cCultureNorse) {
			location_lib = 2;
		} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
			location_lib = 0;
		} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
			location_lib = 4;
		} else {
			location_lib = 5;
		}
		initiateLocation();
		
		placePointsCircleCustom(rmXMetersToFraction(43.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, treesType);
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaConstraint(playerStartingForestID, forestVsHunt);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.25);
			rmBuildArea(playerStartingForestID);
		}
	}
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 22.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 25.0);
	rmAddObjectDefConstraint(startingTowerID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 25;
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
	
	int shortAvoidForest = rmCreateClassDistanceConstraint("stuff v forest", rmClassID("forest"), 10.0);
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0+(cNumberNonGaiaPlayers*3));
	rmAddObjectDefConstraint(mediumGoldID, goldAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidForest);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, superAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	int goldNum = 2;
	for(p = 1; <= cNumberNonGaiaPlayers){
		increment = 60.0 + (cNumberNonGaiaPlayers*3);
		rmSetObjectDefMaxDistance(mediumGoldID, increment);
		rmPlaceObjectDefAtLoc(mediumGoldID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		if(rmGetNumberUnitsPlaced(mediumGoldID) < (p*goldNum)){	//Will always be true for 2.
			for(goldAttempts = 0; < 250){
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
	for(p=1;<=cNumberNonGaiaPlayers){
		
		if(rmGetPlayerCulture(p) == cCultureGreek){
			location_lib = 1;
		} else if(rmGetPlayerCulture(p) == cCultureNorse) {
			location_lib = 2;
		} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
			location_lib = 0;
		} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
			location_lib = 4;
		} else {
			location_lib = 5;
		}
		initiateLocation();
		int mediumDeerID=rmCreateObjectDef("medium deer"+p);
		rmAddObjectDefItem(mediumDeerID, secondHunt, numHuntable, 3.0);
		rmSetObjectDefMinDistance(mediumDeerID, 50.0);
		rmSetObjectDefMaxDistance(mediumDeerID, 65.0);
		rmAddObjectDefConstraint(mediumDeerID, superAvoidImpassableLand);
		rmAddObjectDefConstraint(mediumDeerID, shortAvoidForest);
		rmAddObjectDefConstraint(mediumDeerID, farAvoidFood);
		rmAddObjectDefConstraint(mediumDeerID, avoidGold);
		rmAddObjectDefConstraint(mediumDeerID, shortEdgeConstraint);
		rmAddObjectDefConstraint(mediumDeerID, shortAvoidSettlement);
		rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
		rmPlaceObjectDefAtLoc(mediumDeerID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
	}
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int goldAccuracy = 50;
	if(cNumberNonGaiaPlayers <= 4){
		goldAccuracy = 21;
	} else if(cNumberNonGaiaPlayers <= 6){
		goldAccuracy = 15;
	} else if(cNumberNonGaiaPlayers <= 8){
		goldAccuracy = 10;
	} else {
		goldAccuracy = 6;
	}
	goldAccuracy = goldAccuracy / mapSizeMultiplier;
	
	goldNum = rmRandInt(2,3);
	int farAvoidGold = -1;
	if(goldNum == 2){
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold1", "gold", 75.0);
	} else if(goldNum == 3){
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold2", "gold", 70.0);
	} else {
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold3", "gold", 65.0);
	} if(cMapSize == 2){
		farAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold4", "gold", 75.0);
	}
	
	int stayInWater = rmCreateTerrainDistanceConstraint("avoid water land", "water", false, 1.0);
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 0.0);
	rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farGoldID, playerConstraint);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, stayInWater);
	rmAddObjectDefConstraint(farGoldID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	
	for(p = 1; <= cNumberNonGaiaPlayers){
		rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, 1);
		if(rmGetNumberUnitsPlaced(farGoldID) < (p*(goldNum*mapSizeMultiplier))){
			for(goldAttempts = 0; < goldAccuracy){
				rmPlaceObjectDefAtLoc(farGoldID, 0, 0.5, 0.5, 1);
				if(rmGetNumberUnitsPlaced(farGoldID) >= (p*(goldNum*mapSizeMultiplier))){
					break;
				}
			}
		}
	}
	
	int numSafeHuntable=rmRandInt(6, 8);
	int numUnsafeHuntable=rmRandInt(4, 5);
	for(p=1;<=cNumberNonGaiaPlayers){
		if(rmGetPlayerCulture(p) == cCultureGreek){
			location_lib = 1;
		} else if(rmGetPlayerCulture(p) == cCultureNorse) {
			location_lib = 2;
		} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
			location_lib = 0;
		} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
			location_lib = 4;
		} else {
			location_lib = 5;
		}
		initiateLocation();
		
		int hunt1ID=rmCreateObjectDef("bonus huntable"+p);
		rmAddObjectDefItem(hunt1ID, bonusHunt, numSafeHuntable, 4.0);
		rmSetObjectDefMinDistance(hunt1ID, 65.0);
		rmSetObjectDefMaxDistance(hunt1ID, 80.0);
		rmAddObjectDefConstraint(hunt1ID, rmCreateAreaConstraint("Stay Player"+p, rmAreaID("Player"+p)));
		rmAddObjectDefConstraint(hunt1ID, avoidGold);
		rmAddObjectDefConstraint(hunt1ID, superAvoidFood);
		rmAddObjectDefConstraint(hunt1ID, shortEdgeConstraint);
		rmAddObjectDefConstraint(hunt1ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(hunt1ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(hunt1ID, superAvoidImpassableLand);
		rmPlaceObjectDefAtLoc(hunt1ID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
		
		int hunt2ID=rmCreateObjectDef("bonus hunt "+p);
		rmAddObjectDefItem(hunt2ID, bonusHunt2, numUnsafeHuntable, 4.0);
		rmSetObjectDefMinDistance(hunt2ID, 80.0);
		rmSetObjectDefMaxDistance(hunt2ID, 200.0);
		if(cMapSize == 2){
			rmSetObjectDefMaxDistance(hunt2ID, 200.0+(15*cNumberNonGaiaPlayers));
		}
		rmAddObjectDefConstraint(hunt2ID, avoidHuntable);
		rmAddObjectDefConstraint(hunt2ID, superAvoidFood);
		rmAddObjectDefConstraint(hunt2ID, huntShortAvoidsStartingGoldMilky);
		rmAddObjectDefConstraint(hunt2ID, stayInWater);
		rmAddObjectDefConstraint(hunt2ID, playerConstraint);
		rmAddObjectDefConstraint(hunt2ID, shortEdgeConstraint);
		rmPlaceObjectDefAtLoc(hunt2ID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 2);
	}
	
	int relicID=rmCreateObjectDef("relic"+p);
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, (100.0*mapSizeMultiplier) + (cNumberNonGaiaPlayers*10));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 110.0+ (cNumberNonGaiaPlayers*5)));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmPlaceObjectDefPerPlayer(relicID, false, 2);
		
		
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, farAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, superAvoidFood);
		rmAddObjectDefConstraint(giantGoldID, edgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("giant gold avoid TCs by long distance", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(2, 3));
		
		int giantNumHunt1 = rmRandInt(2,3);
		int giantNumHunt2 = rmRandInt(2,3);
		int giantCountHunt2 = rmRandInt(2,3);
		int giantNumHerd = rmRandInt(2,3);
		
		for(p=1;<=cNumberNonGaiaPlayers){
			if(rmGetPlayerCulture(p) == cCultureGreek){
				location_lib = 1;
			} else if(rmGetPlayerCulture(p) == cCultureNorse) {
				location_lib = 2;
			} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
				location_lib = 0;
			} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
				location_lib = 4;
			} else {
				location_lib = 5;
			}
			initiateLocation();
			
			int giantHuntableID=rmCreateObjectDef("giant huntable"+p);
			rmAddObjectDefItem(giantHuntableID, bonusHunt, 2, 2.0);
			rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.35));
			rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.45));
			rmAddObjectDefConstraint(giantHuntableID, superAvoidFood);
			rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
			rmAddObjectDefConstraint(giantHuntableID, edgeConstraint);
			rmAddObjectDefConstraint(giantHuntableID, avoidGold);
			rmPlaceObjectDefAtLoc(giantHuntableID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), giantNumHunt2);
			
			int giantHuntable2ID=rmCreateObjectDef("giant huntable 2"+p);
			rmAddObjectDefItem(giantHuntable2ID, bonusHunt2, giantCountHunt2, giantCountHunt2);
			rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.35));
			rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.45));
			rmAddObjectDefConstraint(giantHuntable2ID, superAvoidFood);
			rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
			rmAddObjectDefConstraint(giantHuntable2ID, edgeConstraint);
			rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
			rmPlaceObjectDefAtLoc(giantHuntable2ID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), giantNumHunt2);
			
			int giantHerdableID=rmCreateObjectDef("giant herdable"+p);
			rmAddObjectDefItem(giantHerdableID, herd, rmRandInt(2,4), 5.0);
			rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.39));
			rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.45));
			rmAddObjectDefConstraint(giantHerdableID, superAvoidFood);
			rmAddObjectDefConstraint(giantHerdableID, avoidGold);
			rmAddObjectDefConstraint(giantHerdableID, edgeConstraint);
			//rmAddObjectDefConstraint(giantHerdableID, playerConstraint);
			rmPlaceObjectDefAtLoc(giantHerdableID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), giantNumHerd);
		}
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, avoidFood);
		rmAddObjectDefConstraint(giantRelixID, edgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("giant relix avoid relix", "relic", 165.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	
	for(p=1;<=cNumberNonGaiaPlayers){
		if(rmGetPlayerCulture(p) == cCultureGreek){
			location_lib = 1;
		} else if(rmGetPlayerCulture(p) == cCultureNorse) {
			location_lib = 2;
		} else if(rmGetPlayerCulture(p) == cCultureEgyptian) {
			location_lib = 0;
		} else if(rmGetPlayerCulture(p) == cCultureAtlantean) {
			location_lib = 4;
		} else {
			location_lib = 5;
		}
		initiateLocation();
		
		for(i=0; < 8*mapSizeMultiplier) {
			
			int forestID=rmCreateArea("forest"+i+" P"+p, rmAreaID("Player"+p));
			rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(140));
			if(cMapSize == 2){
				rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(240));
			}
			
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, treesType);
			rmAddAreaConstraint(forestID, forestObjConstraint);
			rmAddAreaConstraint(forestID, forestConstraint);
			rmAddAreaConstraint(forestID, shortAvoidSettlement);
			rmAddAreaConstraint(forestID, avoidImpassableLand);
			rmAddAreaToClass(forestID, classForest);
			
			rmSetAreaMinBlobs(forestID, 1);
			rmSetAreaMaxBlobs(forestID, 3);
			rmSetAreaMinBlobDistance(forestID, 10.0);
			rmSetAreaMaxBlobDistance(forestID, 20.0);
			rmSetAreaCoherence(forestID, 0.0);
			
			// Hill trees?
			if(rmRandFloat(0.0, 1.0)<0.2) {
				rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
			}
			
			rmBuildArea(forestID);
		}
	}
	
	rmSetStatusText("",0.93);
	
	
	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.
	
	
	
	rmSetStatusText("",1.0);
}
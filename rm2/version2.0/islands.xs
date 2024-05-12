/*	Map Name: Islands.xs
**	Fast-Paced Ruleset: Midgard.xs
**	Author: Milkman Matty for Forgotten Empires.
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
	int playerTiles=12200;
	if(cMapSize == 1){
		playerTiles = 15860;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 31720;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Set up default water.
	rmSetSeaLevel(0.0);
	rmSetSeaType("mediterranean sea");
	
	// Init map.
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classBonusIsland=rmDefineClass("bonus island");
	int classIsland=rmDefineClass("island");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classForest=rmDefineClass("forest");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(16), rmZTilesToFraction(16), 1.0-rmXTilesToFraction(16), 1.0-rmZTilesToFraction(16), 0.01);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
	int islandConstraint=rmCreateClassDistanceConstraint("islands avoid islands", classIsland, 40.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	//No Map Outline for Islands
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers < 4) {
		rmPlacePlayersCircular(0.23, 0.25, rmDegreesToRadians(5.0));
	} else if(cNumberNonGaiaPlayers < 9) {
		rmPlacePlayersCircular(0.23, 0.28, rmDegreesToRadians(5.0));
	} else {
		rmPlacePlayersCircular(0.30, 0.35, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();

	float playerFraction=rmAreaTilesToFraction(4500);
	if(cNumberNonGaiaPlayers < 4) {
		playerFraction=rmAreaTilesToFraction(4200);
	}
	
	float randomIslandChance=rmRandFloat(0, 1);
	
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classIsland);
		rmSetAreaBaseHeight(id, 2.0);
		rmSetAreaSmoothDistance(id, 10);
		rmSetAreaHeightBlend(id, 2);
		rmAddAreaConstraint(id, playerEdgeConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "GrassDirt25");
		rmAddAreaConstraint(id, islandConstraint);
	}
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int bonusCount=cNumberNonGaiaPlayers + rmRandInt(1, 2);  // num players plus some extra
	if(cMapSize == 2){
		bonusCount = bonusCount * 1.5 + (cNumberPlayers / 3);
	}
	for(i=0; <bonusCount){
		int bonusIslandID=rmCreateArea("bonus island"+i);
		rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(1000*mapSizeMultiplier), rmAreaTilesToFraction(2000*mapSizeMultiplier));
		rmSetAreaTerrainType(bonusIslandID, "GrassDirt25");
		rmSetAreaWarnFailure(bonusIslandID, false);
		rmAddAreaConstraint(bonusIslandID, islandConstraint);
		rmAddAreaToClass(bonusIslandID, classIsland);
		rmAddAreaToClass(bonusIslandID, classBonusIsland);
		rmSetAreaCoherence(bonusIslandID, 0.25);
		rmSetAreaSmoothDistance(bonusIslandID, 12);
		rmSetAreaHeightBlend(bonusIslandID, 2);
		rmSetAreaBaseHeight(bonusIslandID, 2.0);
	}
	
	rmBuildAllAreas();
	
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier){
		// Beautification sub area.
		int id3=rmCreateArea("Grass patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "GrassDirt75");
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		rmAddAreaConstraint(id3, shortAvoidImpassableLand);
		rmBuildArea(id3);
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.

	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar=rmCreateTypeDistanceConstraint("far avoid other food sources", "food", 25.0);
	int shortAvoidStartingGoldMilky=rmCreateTypeDistanceConstraint("short avoid start gold", "gold", 10.0);
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 14.0);	
	
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid bonus huntable", "huntable", 30.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	
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
	
	int closeID = -1;
	int farID = -1;
	int TCfailCount = 0;
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 5.0);
	rmAddObjectDefConstraint(startingSettlementID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		
		id=rmAddFairLoc("Settlement", false, true, 60, 65, 40, 16, true);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		
		if(rmPlaceFairLocs()) {
			for(p = 1; <= cNumberNonGaiaPlayers){
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "GrassDirt75");
				rmAddAreaTerrainLayer(settleArea, "GrassA", 0, 4);
				rmAddAreaTerrainLayer(settleArea, "GrassDirt25", 4, 8);
				rmAddAreaTerrainLayer(settleArea, "GrassDirt50", 8, 12);
				rmBuildArea(settleArea);
			}
		} else {
			TCfailCount = 1;
		}
		rmResetFairLocs();
	
		//Do it again.
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.27), rmXFractionToMeters(0.35), 30, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		if(rmPlaceFairLocs()) {
			for(p = 1; <= cNumberNonGaiaPlayers){
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "GrassDirt75");
				rmAddAreaTerrainLayer(settlementArea, "GrassA", 0, 8);
				rmAddAreaTerrainLayer(settlementArea, "GrassDirt25", 8, 16);
				rmAddAreaTerrainLayer(settlementArea, "GrassDirt50", 16, 24);
				rmBuildArea(settlementArea);
			}
		} else {
			TCfailCount++;
		}

	} else {
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
			for(attempt = 2; < 10){
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
			for(attempt = 4; < 15){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 12*attempt);
			}
		}
	} rmResetFairLocs();
	
	if(TCfailCount > 0){
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
			for(attempt = 2; < 15){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 15*attempt);
			}
			
			if(TCfailCount > 1){
				farID=rmCreateObjectDef("far2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 3; < 15){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 18*attempt);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", false, true,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.4), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.35), rmXFractionToMeters(0.4), 70, 16);
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
					rmSetAreaTerrainType(settlementArea2, "GrassDirt75");
					rmAddAreaTerrainLayer(settlementArea2, "GrassDirt50", 4, 6);
					rmAddAreaTerrainLayer(settlementArea2, "GrassDirt25", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2, "GrassB", 0, 2);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
					
				farID=rmCreateObjectDef("giant settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 4; < 9){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 14*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 5; < 12){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 14*attempt);
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
	
	int closeWaterBuffaloID=rmCreateObjectDef("close water buffalo");
	float waterBuffaloNumber=rmRandFloat(0, 1);
	if(waterBuffaloNumber<0.3) {
		rmAddObjectDefItem(closeWaterBuffaloID, "water buffalo", 1, 4.0);
	} else if(waterBuffaloNumber<0.6) {
		rmAddObjectDefItem(closeWaterBuffaloID, "water buffalo", 2, 4.0);
	} else {
		rmAddObjectDefItem(closeWaterBuffaloID, "water buffalo", 3, 6.0);
	}
	rmSetObjectDefMinDistance(closeWaterBuffaloID, 24.0);
	rmSetObjectDefMaxDistance(closeWaterBuffaloID, 30.0);
	rmAddObjectDefConstraint(closeWaterBuffaloID, getOffTheTC);
	rmAddObjectDefConstraint(closeWaterBuffaloID, shortAvoidStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closeWaterBuffaloID, false);
	
	int closePigsID=rmCreateObjectDef("close pigs");
	rmAddObjectDefItem(closePigsID, "pig", 2, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmPlaceObjectDefPerPlayer(closePigsID, true);
	
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(5,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("avoid all trees", "all", 4.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 5;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(25+cNumberNonGaiaPlayers), rmAreaTilesToFraction(50+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "palm forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
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
	rmAddObjectDefConstraint(startingTowerID, shortAvoidStartingGoldMilky);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 24;
		while( rmGetNumberUnitsPlaced(startingTowerID) < (4*p) ){
			rmPlaceObjectDefAtLoc(startingTowerID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			placement++;
			if(placement % 2 == 0){
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
	rmAddObjectDefItem(mediumGoldID, "gold mine", 1, 6.0);
	rmSetObjectDefMinDistance(mediumGoldID, 30.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 50.0+(cNumberNonGaiaPlayers*2-4));
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, 2);
	
	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 40.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 60.0);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumPigsID, false, 1);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int medStartingSettleConstraint=rmCreateClassDistanceConstraint("medium start settle", rmClassID("starting settlement"), 40.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 60.0);
	
	int bonusGoldID=rmCreateObjectDef("bonus gold");
	rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(bonusGoldID, 0.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 15.0);
	rmAddObjectDefConstraint(bonusGoldID, farAvoidGold);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, farStartingSettleConstraint);
	//rmPlaceObjectDefInRandomAreaOfClass is super unreliable. Force each island to have at least 1 gold.
	for(i=0; <bonusCount){
		rmPlaceObjectDefInArea(bonusGoldID, 0, rmAreaID("bonus island"+i), 1);
	}
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 0.0);
	rmSetObjectDefMaxDistance(farGoldID, 80.0 + (cNumberNonGaiaPlayers*3));
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInRandomAreaOfClass(farGoldID, i, classBonusIsland);
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "zebra", 4, 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "gazelle", 6, 8.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 10.0 + (2*cNumberNonGaiaPlayers-4));
	rmAddObjectDefConstraint(bonusHuntableID, medStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i));
	}
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(farPigsID, 0.0);
	rmSetObjectDefMaxDistance(farPigsID, 20.0 + (7*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, medStartingSettleConstraint);
	rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farPigsID, 0, rmAreaID("player"+i));
	}
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "lion", 1, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0 + (7*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 138", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 138", "AbstractSettlement", 40.0));
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("player"+i));
	}
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 80.0 + (cNumberNonGaiaPlayers*2));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidGold);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i));
	}
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 6.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);	
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 30 + (4*cMapSize));
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);
	int playerFishID=rmCreateObjectDef("owned fish");
	rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 8.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 45.0+(5.0*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainDistanceConstraint("fish vs land", "land", true, 4.0));
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainMaxDistanceConstraint("fish close to land", "land", true, 10.0));
	rmPlaceObjectDefPerPlayer(playerFishID, false);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
	
		int giantAvoidHuntable=rmCreateTypeDistanceConstraint("giant avoid bonus huntable", "huntable", 50.0);
	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.26));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantGoldID, farAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "giraffe", rmRandInt(4,5), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(2, 4));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(3, 4));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, 1.5*cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 15.0);
	
	int failCount = 0;
	for(i=1; <cNumberPlayers) {
		failCount=0;
		int forestCount=rmRandInt(5, 8);
		if(cMapSize == 2) {
			forestCount = 1.5*forestCount;
		}
		
		for(j=0; <forestCount) {
			int forestID=rmCreateArea("player"+i+"forest"+j, rmAreaID("player"+i));
			rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
			if(cMapSize == 2) {
				rmSetAreaSize(forestID, rmAreaTilesToFraction(125), rmAreaTilesToFraction(200));
			}
			
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, "palm forest");
			rmAddAreaConstraint(forestID, forestSettleConstraint);
			rmAddAreaConstraint(forestID, forestObjConstraint);
			rmAddAreaConstraint(forestID, forestConstraint);
			rmAddAreaConstraint(forestID, forestTerrain);
			rmAddAreaToClass(forestID, classForest);
			
			rmSetAreaMinBlobs(forestID, 1);
			rmSetAreaMaxBlobs(forestID, 5);
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
	}
	
	int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 16.0);
	
	for(i=0; <bonusCount){
		forestCount=rmRandInt(2, 3);
		if(cMapSize == 2){
			forestCount = 2.5*forestCount;
		}
		
		for(j=0; <forestCount){
			forestID=rmCreateArea("bonus"+i+"forest"+j, rmAreaID("bonus island"+i));
			rmSetAreaSize(forestID, rmAreaTilesToFraction(25*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, "palm forest");
			rmAddAreaConstraint(forestID, forestSettleConstraint);
			rmAddAreaConstraint(forestID, forestObjConstraint);
			rmAddAreaConstraint(forestID, forestConstraint2);
			rmAddAreaConstraint(forestID, forestTerrain);
			rmAddAreaToClass(forestID, classForest);
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaMinBlobs(forestID, 1);
			rmSetAreaMaxBlobs(forestID, 5);
			rmSetAreaMinBlobDistance(forestID, 16.0);
			rmSetAreaMaxBlobDistance(forestID, 40.0);
			rmSetAreaCoherence(forestID, 0.0);
			
			rmBuildArea(forestID);
		}
	}
	
	rmSetStatusText("",0.93);
	
	
	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	
	int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
	int sharkVsSharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
	int sharkVsSharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
	int sharkVsSharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);
	int sharkID=rmCreateObjectDef("shark");
	if(rmRandFloat(0,1)<0.33) {
		rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
	} else if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
	} else {
		rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
	}
	rmSetObjectDefMinDistance(sharkID, 0.0);
	rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(sharkID, sharkLand);
	rmAddObjectDefConstraint(sharkID, playerEdgeConstraint);
	rmAddObjectDefConstraint(sharkID, sharkVsSharkID);
	rmAddObjectDefConstraint(sharkID, sharkVsSharkID2);
	rmAddObjectDefConstraint(sharkID, sharkVsSharkID3);
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "seagull", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	rmSetStatusText("",1.0);
}
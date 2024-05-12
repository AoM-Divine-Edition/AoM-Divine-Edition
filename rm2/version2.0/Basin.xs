/*	Map Name: Basin.xs
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
		playerTiles = 15500;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/1.25);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	
	if(cNumberNonGaiaPlayers == 2){
		rmSetMapSize(size, size*1.4);
	} else {
		rmSetMapSize(size*1.05, size*1.05);
	}
	
	rmSetSeaLevel(0.0);
	rmSetSeaType("Yellow River");
	rmTerrainInitialize("PlainA");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int playerClass = rmDefineClass("player");
	int poolClass = rmDefineClass("pool");
	int classForest = rmDefineClass("forest");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	//No Global Constraints for Basin
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	//Generate Water Pool position. 
	float poolRadius = 0.49;			//Use a radius of 0.49 try not to change this.
	float playerPoolLocX = 0.01;		//This needs to be recorded so that we can place the players slightly in from the pools.
	float poolAngle = -1.0;
	poolAngle = placePointsCircle(poolRadius, cNumberNonGaiaPlayers, -1.0, playerPoolLocX);
	
	float poolSize = 0.045 - (0.0025*cNumberNonGaiaPlayers);
	if(cNumberNonGaiaPlayers == 2){
		poolSize = 0.07;
	}
	if(cMapSize == 2){
		poolSize = poolSize / 2.25;
	}
	for(p = 1; <= cNumberNonGaiaPlayers){
		int safeWaterID=rmCreateArea("small pond"+p);
		rmSetAreaSize(safeWaterID, poolSize, poolSize);
		rmSetAreaLocation(safeWaterID, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p));
		rmSetAreaWaterType(safeWaterID, "Yellow River");
		rmAddAreaToClass(safeWaterID, poolClass);
		rmSetAreaCoherence(safeWaterID, 0.5);
		rmSetAreaWarnFailure(safeWaterID, false);
		rmBuildArea(safeWaterID);
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	//Generate player positions.
	float playerRadius = 0.42;			//use a radius of 0.42
	if(cNumberNonGaiaPlayers == 2){
		playerRadius = 0.37;
	} else if(cNumberNonGaiaPlayers <= 4){
		playerRadius = 0.39;
	} else if(cNumberNonGaiaPlayers <= 6){
		playerRadius = 0.4;
	} else if(cNumberNonGaiaPlayers <= 8){
		playerRadius = 0.41;
	}
	
	placePointsCircle(playerRadius, cNumberNonGaiaPlayers, -1.0, playerPoolLocX);	//use the recorded angle.
	
	//Amend locations so that they are closer to the centre of the map.
	for(p = 1; <= cNumberNonGaiaPlayers){
		rmSetCustomLocXForPlayer(p, ((rmGetCustomLocXForPlayer(p) - 0.5) * (playerRadius/poolRadius)) + 0.5);
		rmSetCustomLocZForPlayer(p, ((rmGetCustomLocZForPlayer(p) - 0.5) * (playerRadius/poolRadius)) + 0.5);
		rmSetPlayerLocation(p, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p));
	}
	rmRecordPlayerLocations();
	//rmEchoError("BREAKPOINT. If I never see Math again it'll be too soon");

	// Set up player areas.
	float playerFraction=rmAreaTilesToFraction(600);
	for(i=1; <cNumberPlayers){
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);		//Set area to player.
		rmSetAreaLocPlayer(id, i);	//Grab the location that placePointsCircle selected above.
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, playerClass);
		rmSetAreaWarnFailure(id, true);
		rmSetAreaTerrainType(id, "PlainDirt75");
		rmAddAreaTerrainLayer(id, "PlainA", 0, 8);
		rmAddAreaTerrainLayer(id, "PlainDirt25", 8, 16);
		rmAddAreaTerrainLayer(id, "PlainDirt50", 16, 24);
		rmSetAreaBaseHeight(id, 2.0);
		rmSetAreaHeightBlend(id, 2);
		rmSetAreaSmoothDistance(id, 6);
		
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaCoherence(id, 0.75);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	//No Map Specifics for Basin.
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(5), rmZTilesToFraction(5), 1.0-rmXTilesToFraction(5), 1.0-rmZTilesToFraction(5));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	
	int avoidSettlement=rmCreateTypeDistanceConstraint("avoid TCs", "AbstractSettlement", 30.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("far avoid TCs", "AbstractSettlement", 50.0);
	
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
	
	int shortAvoidFood=rmCreateTypeDistanceConstraint("short avoid food", "food", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 40.0);
	int farAvoidFood=rmCreateTypeDistanceConstraint("far avoid food", "food", 60.0);
	
	int prettyVsForest=rmCreateClassDistanceConstraint("pretty v forest", rmClassID("forest"), 1.0);
	int goldAvoidSettlement=rmCreateTypeDistanceConstraint("gold avoid TCs", "AbstractSettlement", 18.0);
	
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
		rmAddObjectDefItem(startingGoldID, "Jade Mine Small", 1, 0.0);
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i)){
				rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
			}
		}
	}
	rmResetFairLocs();
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 10.0);
	
	int farID = -1;
	int closeID = -1;
	
	if(cNumberNonGaiaPlayers == 2) {
		if(cMapSize != 2){
			id=rmAddFairLoc("Settlement", false, false, 65, 80, 0, 18);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			
			if(rmPlaceFairLocs()){
				id=rmCreateObjectDef("far settlement");
				rmAddObjectDefItem(id, "Settlement", 1, 1.0);
				for(p = 1; <= cNumberNonGaiaPlayers){
					for(j=0; <rmGetNumberFairLocs(p)) {
						int settleArea = rmCreateArea("settlement area"+p +j);
						rmSetAreaLocation(settleArea, rmFairLocXFraction(p, j), rmFairLocZFraction(p, j));
						rmSetAreaSize(settleArea, 0.01, 0.01);
						rmSetAreaTerrainType(settleArea, "PlainDirt75");
						rmAddAreaTerrainLayer(settleArea, "PlainA", 0, 8);
						rmAddAreaTerrainLayer(settleArea, "PlainDirt25", 8, 16);
						rmAddAreaTerrainLayer(settleArea, "PlainDirt50", 16, 24);
						rmBuildArea(settleArea);
						rmPlaceObjectDefAtAreaLoc(id, p, settleArea);
					}
				}
			}
			rmResetFairLocs();
		
			id=rmAddFairLoc("Settlement2", false, true, 90, 100, 0, 18);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			
			if(rmPlaceFairLocs()){
				id=rmCreateObjectDef("far settlement2");
				rmAddObjectDefItem(id, "Settlement", 1, 1.0);
				for(p = 1; <= cNumberNonGaiaPlayers){
					for(j=0; <rmGetNumberFairLocs(p)) {
						settleArea = rmCreateArea("settlement area_"+p +j);
						rmSetAreaLocation(settleArea, rmFairLocXFraction(p, j), rmFairLocZFraction(p, j));
						rmSetAreaSize(settleArea, 0.01, 0.01);
						rmSetAreaTerrainType(settleArea, "PlainDirt75");
						rmAddAreaTerrainLayer(settleArea, "PlainA", 0, 8);
						rmAddAreaTerrainLayer(settleArea, "PlainDirt25", 8, 16);
						rmAddAreaTerrainLayer(settleArea, "PlainDirt50", 16, 24);
						rmBuildArea(settleArea);
						rmPlaceObjectDefAtAreaLoc(id, p, settleArea);
					}
				}
			}
		} else {
		
			//AoM:EE's version of rmEchoInfo
			rmCreateTrigger("rmEchoInfo");
			rmSetTriggerPriority(0);
			rmSetTriggerActive(false);
			rmSetTriggerRunImmediately(false);
			rmSetTriggerLoop(false);
			rmAddTriggerCondition("always");
			
			int TCs2Place = 4;
		
			for(p = 1; <= cNumberNonGaiaPlayers){
			
				placePointsCircleCustom(0.2, TCs2Place, -1.0, playerPoolLocX, rmGetPlayerX(p), rmGetPlayerZ(p),  false, true);
				
				rmAddTriggerEffect("Write To Log");
				rmSetTriggerEffectParam("Message", ""+p+": "+rmGetPlayerX(p)+", "+rmGetPlayerZ(p));
				
				id=rmCreateObjectDef("giant settlement "+p);
				rmAddObjectDefItem(id, "Settlement", 1, 10.0);
				
				for(jukes = 1; <= TCs2Place){

					if(rmGetCustomLocXForPlayer(jukes) < 0.5){
						rmSetCustomLocXForPlayer(jukes, rmGetCustomLocXForPlayer(jukes) - rmRandFloat(0, 0.2));
					} else {
						rmSetCustomLocXForPlayer(jukes, rmGetCustomLocXForPlayer(jukes) + rmRandFloat(0, 0.2));
					}
				
					rmPlaceObjectDefAtLoc(id, 0, rmGetCustomLocXForPlayer(jukes), rmGetCustomLocZForPlayer(jukes), 1);
					rmAddTriggerEffect("Write To Log");
					rmSetTriggerEffectParam("Message", ""+p+jukes+": "+rmGetCustomLocXForPlayer(jukes)+", "+rmGetCustomLocZForPlayer(jukes));
				}
			}
			if(TCs2Place == 3){
				rmPlaceObjectDefAtLoc(id, 0, 0.1, 0.1, 1);
				rmPlaceObjectDefAtLoc(id, 0, 0.9, 0.1, 1);
				rmPlaceObjectDefAtLoc(id, 0, 0.1, 0.9, 1);
				rmPlaceObjectDefAtLoc(id, 0, 0.9, 0.9, 1);
			}
		}
	} else {
		id=rmAddFairLoc("Close Settlement", false, true, 60, 80+cNumberNonGaiaPlayers, 55, 20);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		id=rmAddFairLoc("Far Settlement", true, false,  75, 95, 70, 50);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("fairloc settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <= cNumberNonGaiaPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					int farSettleArea = rmCreateArea("far settlement area"+i +j, rmAreaID("Player"+i));
					rmSetAreaLocation(farSettleArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
					rmSetAreaTerrainType(farSettleArea, "PlainDirt75");
					rmAddAreaTerrainLayer(farSettleArea, "PlainA", 0, 8);
					rmAddAreaTerrainLayer(farSettleArea, "PlainDirt25", 8, 16);
					rmAddAreaTerrainLayer(farSettleArea, "PlainDirt50", 16, 24);
					rmBuildArea(farSettleArea);
					rmPlaceObjectDefAtAreaLoc(id, i, farSettleArea);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
				
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, shortEdgeConstraint);
				rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(closeID, TCavoidStart);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				for(attempt = 3; <= 7){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, 25*attempt);
				}
				
				farID=rmCreateObjectDef("far settlement"+p);
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
	} rmResetFairLocs();
	
	if(cMapSize == 2 && cNumberNonGaiaPlayers > 2){
	
		TCavoidSettlement = rmCreateTypeDistanceConstraint("giant TC avoid TC", "AbstractSettlement", 65.0);
		
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.29), rmXFractionToMeters(0.4), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.29), rmXFractionToMeters(0.4), 70, 16);
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
					rmSetAreaTerrainType(settlementArea2, "PlainDirt75");
					rmAddAreaTerrainLayer(settlementArea2, "PlainA", 0, 8);
					rmAddAreaTerrainLayer(settlementArea2, "PlainDirt25", 8, 16);
					rmAddAreaTerrainLayer(settlementArea2, "PlainDirt50", 16, 24);
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
				rmAddObjectDefConstraint(farID, shortEdgeConstraint);
				for(attempt = 6; <= 12){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 15*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, shortEdgeConstraint);
				for(attempt = 8; <= 12){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 16*attempt);
				}
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int avoidFish = rmCreateTypeDistanceConstraint("avoid fish", "fish", 6.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish vs land", "land", true, 5.0);
	
	int littleFishiesID=-1;
	int fishies = rmRandInt(4,5);
	int attempts = 0;	int limit = 100;
	for(p=1; <= cNumberNonGaiaPlayers){
		littleFishiesID=rmCreateObjectDef("Nemo and co"+p);	//Fish can only be placed after the player areas have been built - else the fish might get deleted by land.
		rmAddObjectDefItem(littleFishiesID, "Fish - Perch", 1, 1.0); 
		rmSetObjectDefMinDistance(littleFishiesID, 0.0);
		rmSetObjectDefMaxDistance(littleFishiesID, rmZFractionToMeters(poolSize) + rmXFractionToMeters(poolSize));	//The total size of the pool
		rmAddObjectDefConstraint(littleFishiesID, avoidFish);
		rmAddObjectDefConstraint(littleFishiesID, fishLand);
		if(cMapSize >= 1){
			rmAddObjectDefConstraint(littleFishiesID, edgeConstraint);
		} else {
			rmAddObjectDefConstraint(littleFishiesID, shortEdgeConstraint);
		}
	
		while(rmGetNumberUnitsPlaced(littleFishiesID) < fishies && attempts <= limit){
			rmPlaceObjectDefAtAreaLoc(littleFishiesID, 0, rmAreaID("small pond"+p), 1);
			attempts++;
		}
		attempts = 0;
	}
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "deer", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 20.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 8.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int littlePiggiesID=rmCreateObjectDef("This little piggy is just really hairy");
	rmAddObjectDefItem(littlePiggiesID, "Yak", 3, 2.0);
	rmSetObjectDefMinDistance(littlePiggiesID, 25.0);
	rmSetObjectDefMaxDistance(littlePiggiesID, 30.0);
	rmPlaceObjectDefPerPlayer(littlePiggiesID, true);
	
	int birdiessStayNearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 12.0);
	
	int numCrane=rmRandInt(6, 8);
	int startingBirdiesID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingBirdiesID, "duck", numCrane, 8.0);
	rmSetObjectDefMinDistance(startingBirdiesID, 30.0);
	rmSetObjectDefMaxDistance(startingBirdiesID, 40.0);
	rmAddObjectDefConstraint(startingBirdiesID, birdiessStayNearShore);
	rmPlaceObjectDefPerPlayer(startingBirdiesID, false);
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 4;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmPlayerLocXFraction(p), rmPlayerLocZFraction(p), false, false);
		int skip = rmRandInt(1,maxNum);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "Mixed Plain Forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaCoherence(playerStartingForestID, 0.25);
			rmBuildArea(playerStartingForestID);
		}
	}
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 20.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 6.0);
	int startingTowerID = -1;
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		startingTowerID = rmCreateObjectDef("Starting tower"+p);
		rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
		rmSetObjectDefMinDistance(startingTowerID, 22.0);
		rmSetObjectDefMaxDistance(startingTowerID, 25.0);
		rmAddObjectDefConstraint(startingTowerID, avoidTower);
		rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("towerfood", "food", 8.0));
		rmAddObjectDefConstraint(startingTowerID, forestTerrain);
		rmAddObjectDefConstraint(startingTowerID, forestTower);
		rmAddObjectDefConstraint(startingTowerID, huntShortAvoidsStartingGoldMilky);
		increment = 25;
		for(attempt = 1; < 200){
			if( rmGetNumberUnitsPlaced(startingTowerID) == 4){
				break;
			}
			rmPlaceObjectDefAtLoc(startingTowerID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			rmSetObjectDefMaxDistance(startingTowerID, 25+attempt);
		}
	}
	
	rmSetStatusText("",0.66);
	
	/* ************************* */
	/* Section 11 Medium Objects */
	/* ************************* */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Jade Mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmAddObjectDefConstraint(mediumGoldID, forestTower);
	rmAddObjectDefConstraint(mediumGoldID, farAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, goldAvoidSettlement);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int medHuntID=rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem(medHuntID, "deer", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(medHuntID, 50.0);
	rmSetObjectDefMaxDistance(medHuntID, 60.0);
	rmAddObjectDefConstraint(medHuntID, forestTower);
	rmAddObjectDefConstraint(medHuntID, avoidGold);
	rmAddObjectDefConstraint(medHuntID, avoidFood);
	rmAddObjectDefConstraint(medHuntID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(medHuntID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Jade Mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0);
	rmAddObjectDefConstraint(farGoldID, forestTower);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, goldAvoidSettlement);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 2);
	
	int farHuntID=rmCreateObjectDef("far hunt");
	rmAddObjectDefItem(farHuntID, "deer", 5, 3.0);
	rmSetObjectDefMaxDistance(farHuntID, 75.0);
	rmSetObjectDefMaxDistance(farHuntID, 85.0);
	rmAddObjectDefConstraint(farHuntID, forestTower);
	rmAddObjectDefConstraint(farHuntID, avoidGold);
	rmAddObjectDefConstraint(farHuntID, farAvoidFood);
	rmAddObjectDefConstraint(farHuntID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(farHuntID, false, 2);
	
	int farDucksID=rmCreateObjectDef("far Ducks");
	rmAddObjectDefItem(farDucksID, "Duck", rmRandInt(4,7), 3.0);
	rmSetObjectDefMaxDistance(farDucksID, 65.0);
	rmSetObjectDefMaxDistance(farDucksID, 100.0);
	rmAddObjectDefConstraint(farDucksID, forestTower);
	rmAddObjectDefConstraint(farDucksID, avoidGold);
	rmAddObjectDefConstraint(farDucksID, shortAvoidFood);
	rmAddObjectDefConstraint(farDucksID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(farDucksID, false, 1);
	
	int bonusFarHuntID=rmCreateObjectDef("Bonus far hunt");
	rmAddObjectDefItem(bonusFarHuntID, "Elephant Indian", rmRandInt(2,3), 3.0);
	rmSetObjectDefMaxDistance(bonusFarHuntID, 80.0);
	rmSetObjectDefMaxDistance(bonusFarHuntID, 100.0);
	rmAddObjectDefConstraint(bonusFarHuntID, forestTower);
	rmAddObjectDefConstraint(bonusFarHuntID, avoidGold);
	rmAddObjectDefConstraint(bonusFarHuntID, farAvoidFood);
	rmAddObjectDefConstraint(bonusFarHuntID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(bonusFarHuntID, false, 1);
	
	int bigPiggiesID=rmCreateObjectDef("This little piggy is just misunderstood");
	rmAddObjectDefItem(bigPiggiesID, "Yak", 3, 2.0);
	rmSetObjectDefMinDistance(bigPiggiesID, 80.0);
	rmSetObjectDefMaxDistance(bigPiggiesID, 100.0);
	rmAddObjectDefConstraint(bigPiggiesID, forestTower);
	rmAddObjectDefConstraint(bigPiggiesID, avoidGold);
	rmAddObjectDefConstraint(bigPiggiesID, avoidFood);
	rmAddObjectDefConstraint(bigPiggiesID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(bigPiggiesID, false, 2);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	rmSetObjectDefMinDistance(farPredatorID, 50.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, forestTower);
	rmAddObjectDefConstraint(farPredatorID, avoidSettlement);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, avoidGold);
	
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.4){
		rmAddObjectDefItem(farPredatorID, "lizard", 2, 4.0);
		rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	} else {
		rmAddObjectDefItem(farPredatorID, "Tiger", rmRandInt(1,2), 4.0);
		rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);
	}
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, prettyVsForest);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs TCs", "AbstractSettlement", 20.0));
	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	if(cMapSize == 2){
		rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic Giant", "relic", 120.0));
		rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		rmSetObjectDefMinDistance(farGoldID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(farGoldID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2, 3));
	
		rmSetObjectDefMinDistance(bigPiggiesID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(bigPiggiesID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(bigPiggiesID, false, 2);
		
		rmSetObjectDefMaxDistance(bonusFarHuntID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(bonusFarHuntID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(bonusFarHuntID, false, 1);
		
		rmSetObjectDefMaxDistance(bonusFarHuntID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(bonusFarHuntID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(farHuntID, false, rmRandInt(1, 2));
		
		int giantFishiesID = -1;
		attempts = 0;	limit = 10;
		for(p=1; <= cNumberNonGaiaPlayers){
			giantFishiesID=rmCreateObjectDef("I speak whale"+p);
			rmAddObjectDefItem(giantFishiesID, "Fish - Perch", 1, 1.0); 
			rmSetObjectDefMinDistance(giantFishiesID, 0.0);
			rmSetObjectDefMaxDistance(giantFishiesID, rmZFractionToMeters(poolSize) + rmXFractionToMeters(poolSize));
			rmAddObjectDefConstraint(giantFishiesID, fishLand);
			rmAddObjectDefConstraint(giantFishiesID, rmCreateTypeDistanceConstraint("giant avoid fish", "fish", 4.0));
			rmAddObjectDefConstraint(giantFishiesID, edgeConstraint);
		
			while(rmGetNumberUnitsPlaced(giantFishiesID) < fishies && attempts <= limit){
				rmPlaceObjectDefAtAreaLoc(giantFishiesID, 0, rmAreaID("small pond"+p), 1);
				attempts++;
			}
			attempts = 0;
		}
		
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestVsEdge=rmCreateBoxConstraint("forest v edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int forestAvoidGold=rmCreateTypeDistanceConstraint("forest v gold", "gold", 16.0);
	int forestAvoidFood=rmCreateTypeDistanceConstraint("forest v food", "food", 14.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	int waterConstraint=rmCreateClassDistanceConstraint("forest v water", rmClassID("pool"), 16.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 10.0);
	
	int forestCount=12*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.75*forestCount;
	}
	
	int failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "Mixed Plain Forest");
		rmAddAreaConstraint(forestID, forestAvoidGold);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, waterConstraint);
		rmAddAreaConstraint(forestID, forestAvoidFood);
		rmAddAreaConstraint(forestID, avoidBuildings);
		rmAddAreaConstraint(forestID, forestVsEdge);
		rmAddAreaConstraint(forestID, goldAvoidSettlement);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 2);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 20.0);
		rmSetAreaCoherence(forestID, 0.0);
		rmSetAreaBaseHeight(forestID, 0);
		rmSetAreaSmoothDistance(forestID, 4);
		rmSetAreaHeightBlend(forestID, 2);
		
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
	
	int prettyVsWater=rmCreateClassDistanceConstraint("pretty v water", rmClassID("pool"), 3.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("pretty avoid TCs", "AbstractSettlement", 6.0);
	
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier){
		int id4=rmCreateArea("Grass patch 1 "+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16));
		rmSetAreaTerrainType(id4, "DirtB");
		rmAddAreaTerrainLayer(id4, "PlainDirt75", 0, 1);
		rmSetAreaMinBlobs(id4, 1);
		rmSetAreaMaxBlobs(id4, 5);
		rmSetAreaWarnFailure(id4, false);
		rmAddAreaConstraint(id4, prettyVsForest);
		rmAddAreaConstraint(id4, prettyVsWater);
		rmAddAreaConstraint(id4, shortAvoidSettlement);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0);
		rmSetAreaCoherence(id4, 0.0);
		
		rmBuildArea(id4);
	}
	
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier){
		int id5=rmCreateArea("Grass patch 2 "+i);
		rmSetAreaSize(id5, rmAreaTilesToFraction(25), rmAreaTilesToFraction(75));
		rmSetAreaTerrainType(id5, "PlainB");
		rmAddAreaConstraint(id5, prettyVsForest);
		rmAddAreaConstraint(id5, prettyVsWater);
		rmAddAreaConstraint(id5, shortAvoidSettlement);
		rmSetAreaWarnFailure(id5, false);
		rmSetAreaCoherence(id5, 0.0);
		
		rmBuildArea(id5);
	}

	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "Tree Jungle", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, avoidGold);
	rmAddObjectDefConstraint(randomTreeID, avoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int grassID=rmCreateObjectDef("log");
	rmAddObjectDefItem(grassID, "bush", rmRandInt(1,3), 3.0);
	rmAddObjectDefItem(grassID, "grass", rmRandInt(5,8), 12.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmZFractionToMeters(0.5));
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", 1, 8.0);
	rmAddObjectDefItem(logID, "Bush Short", rmRandInt(2,3), 12.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmZFractionToMeters(0.5));
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	/*****************************/
	/* Step 16: World Domination */	rmSetStatusText("",1.00);
	/*****************************/
}
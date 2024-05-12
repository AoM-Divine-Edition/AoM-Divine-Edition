/*	Map Name: Achipelago.xs
**	Fast-Paced Ruleset: Marsh.xs
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
	
	// Set size.
	int mapSizeMultiplier = 1;
	int playerTiles=12200;
	if(cMapSize == 1){
		playerTiles = 15860;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 24720;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	rmSetSeaLevel(0.0);
	rmSetSeaType("mediterranean sea");
	
	// Init map.
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ********************* */
	/* Section 2 Map Outline */
	/* ********************* */
	
	// Unused for Archipelago
	rmSetStatusText("",0.13);
	
	/* ***************** */
	/* Section 3 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	int classBonusIsland = rmDefineClass("bonus island");
	int islandsX = rmDefineClass("islandsX");
	int islandsY = rmDefineClass("islandsY");
	int islandsZ = rmDefineClass("islandsZ");
	int classCorner = rmDefineClass("corner");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classForest=rmDefineClass("forest");
	
	rmSetStatusText("",0.20);
	
	/* **************************** */
	/* Section 4 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20), 0.01);
	
	int islandsXvsY=rmCreateClassDistanceConstraint("island X avoids Y", islandsY, 30.0);
	int islandsYvsX=rmCreateClassDistanceConstraint("island Y avoids X", islandsX, 20.0);
	int islandsXYvsZ=rmCreateClassDistanceConstraint("islands Y and X avoid Z", islandsZ, 20.0);
	int islandsZvsX = 0;
	int islandsZvsY = 0;
	if(cNumberNonGaiaPlayers > 4){
		islandsZvsX=rmCreateClassDistanceConstraint("island Z avoids X", islandsX, 25.0);
		islandsZvsY=rmCreateClassDistanceConstraint("island Z avoids Y", islandsY, 30.0);
	} else {
		islandsZvsX=rmCreateClassDistanceConstraint("island Z avoids X", islandsX, 0.0);
		islandsZvsY=rmCreateClassDistanceConstraint("island Z avoids Y", islandsY, 0.0);
	}
	
	// Avoid water
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cMapSize == 2){
		rmPlacePlayersCircular(0.21, 0.24, rmDegreesToRadians(5.0));
	} else {
		if(cNumberNonGaiaPlayers < 4) {
			rmPlacePlayersCircular(0.23, 0.25, rmDegreesToRadians(5.0));
		} else if(cNumberNonGaiaPlayers < 9) {
			rmPlacePlayersCircular(0.24, 0.28, rmDegreesToRadians(5.0));
		} else {
			rmPlacePlayersCircular(0.30, 0.35, rmDegreesToRadians(5.0));
		}
	}
	rmRecordPlayerLocations();
	
	// Set up player areas.
	float playerFraction=rmAreaTilesToFraction(4500);
	if(cNumberNonGaiaPlayers < 4) {
		playerFraction=rmAreaTilesToFraction(4200);
	}
	
	float randomIslandChance=rmRandFloat(0, 1);
	
	int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30.0);
	
	for(i=1; <cNumberPlayers){
		// Create the area.
		int id=rmCreateArea("Player"+i);
		
		// Assign to the player.
		rmSetPlayerArea(i, id);
		
		// Set the size.
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 3);
		rmSetAreaMaxBlobs(id, 7);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaBaseHeight(id, 2.0);
		rmSetAreaSmoothDistance(id, 10);
		rmSetAreaHeightBlend(id, 2);
		
		// Add constraints.
		rmAddAreaConstraint(id, cornerOverlapConstraint);
		rmAddAreaConstraint(id, playerEdgeConstraint);
		
		// Set the location.
		rmSetAreaLocPlayer(id, i);
		
		// Set type.
		rmSetAreaTerrainType(id, "GrassDirt25");
		
		//island avoidance determination
		randomIslandChance=rmRandFloat(0, 1);
		if(cNumberNonGaiaPlayers < 3) {
			/* if 2 players, always avoid each other and don't have bonus islands avoid */
			rmAddAreaConstraint(id, playerConstraint);
		} else {
			if(randomIslandChance < 0.33) {
				rmAddAreaToClass(id, islandsX);
				rmAddAreaConstraint(id, islandsXvsY);
				rmAddAreaConstraint(id, islandsXYvsZ);
				rmEchoInfo("Class "+id+" islands X");
			} else if(randomIslandChance < 0.66) {
				rmAddAreaToClass(id, islandsY);
				rmAddAreaConstraint(id, islandsYvsX);
				rmAddAreaConstraint(id, islandsXYvsZ);
				rmEchoInfo("Class "+id+" islands Y");
			} else {
				rmAddAreaToClass(id, islandsZ);
				rmEchoInfo("Class "+id+" islands Z");
				rmAddAreaConstraint(id, islandsZvsX);
				rmAddAreaConstraint(id, islandsZvsY);
			}
		}
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	// Build up some bonus islands.
	int bonusCount = cNumberNonGaiaPlayers + rmRandInt(1, 4);  // num players plus some extra
	if(cMapSize == 2){
		bonusCount = bonusCount + 2*cNumberNonGaiaPlayers;
	}
	int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid bonus island", classBonusIsland, 50.0);
	
	for(i=0; <bonusCount){
		int bonusIslandID=rmCreateArea("bonus island"+i);
		rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(1000*mapSizeMultiplier), rmAreaTilesToFraction(1500*mapSizeMultiplier));
		rmSetAreaTerrainType(bonusIslandID, "GrassA");
		rmSetAreaWarnFailure(bonusIslandID, false);
		rmAddAreaConstraint(bonusIslandID, playerEdgeConstraint);
		rmAddAreaToClass(bonusIslandID, classBonusIsland);
		rmSetAreaCoherence(bonusIslandID, 0.25);
		rmSetAreaSmoothDistance(bonusIslandID, 12);
		rmSetAreaHeightBlend(bonusIslandID, 2);
		rmSetAreaBaseHeight(bonusIslandID, 2.0);
		
		//island avoidance determination
		randomIslandChance=rmRandFloat(0, 1);
		if(cMapSize == 2){
			if(i % 2 == 0){
				if(randomIslandChance < 0.33){
					rmAddAreaToClass(bonusIslandID, islandsX);
					rmAddAreaConstraint(bonusIslandID, islandsXvsY);
				} else if(randomIslandChance < 0.66) {
					rmAddAreaToClass(bonusIslandID, islandsY);
					rmAddAreaConstraint(bonusIslandID, islandsXYvsZ);
				} else {
					rmAddAreaToClass(bonusIslandID, islandsZ);
				}
				if(cNumberNonGaiaPlayers > 4){
					rmAddAreaConstraint(bonusIslandID, bonusIslandConstraint);
				}
			} else {
				rmAddAreaConstraint(bonusIslandID, bonusIslandConstraint);
			}
		} else {
			rmAddAreaConstraint(bonusIslandID, bonusIslandConstraint);
			if(randomIslandChance < 0.33){
				rmAddAreaToClass(bonusIslandID, islandsX);
				rmAddAreaConstraint(bonusIslandID, islandsXvsY);
				rmAddAreaConstraint(bonusIslandID, islandsXYvsZ);
				rmEchoInfo("Class "+bonusIslandID+" islands X");
			} else if(randomIslandChance < 0.66) {
				rmAddAreaToClass(bonusIslandID, islandsY);
				rmAddAreaConstraint(bonusIslandID, islandsYvsX);
				rmAddAreaConstraint(bonusIslandID, islandsXYvsZ);
				rmEchoInfo("Class "+bonusIslandID+" islands Y");
			} else {
				rmAddAreaToClass(bonusIslandID, islandsZ);
				rmEchoInfo("Class "+bonusIslandID+" islands Z");
				rmAddAreaConstraint(bonusIslandID, islandsZvsX);
				rmAddAreaConstraint(bonusIslandID, islandsZvsY);
			}
		}
		rmBuildArea(bonusIslandID);
	}
	
	// Player elevation.
	for(i=1; <cNumberPlayers){
		int failCount=0;
		int num=rmRandInt(5, 10);
		for(j=0; <num){
			int elevID=rmCreateArea("elev"+i+", "+j, rmAreaID("player"+i));
			rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
			rmSetAreaWarnFailure(elevID, false);
			rmAddAreaConstraint(elevID, avoidImpassableLand);
			if(rmRandFloat(0.0, 1.0)<0.3) {
				rmSetAreaTerrainType(elevID, "GrassDirt50");
			}
			rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 3.5));
			
			rmSetAreaMinBlobs(elevID, 1);
			rmSetAreaMaxBlobs(elevID, 5);
			rmSetAreaMinBlobDistance(elevID, 16.0);
			rmSetAreaMaxBlobDistance(elevID, 40.0);
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
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
	int avoidSettlement = rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 20.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid bonus huntable", "huntable", 20.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid bonus herdable", "herdable", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	
	rmSetStatusText("",0.46);
	
	
	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */
	
	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.5){
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 23, 0, 10);
	} else {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 20, 23, 0, 10);
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
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int shortAvoidFood=rmCreateTypeDistanceConstraint("short avoid other food sources", "food", 12.0);
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, classStartingSettlement);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "boar", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 22.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(5,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 21.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidFood);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(startingChickenID, true);
	
	int closePigsID=rmCreateObjectDef("close pigs");
	rmAddObjectDefItem(closePigsID, "pig", 2, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, shortAvoidFood);
	rmAddObjectDefConstraint(closePigsID, chickenShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(closePigsID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(closePigsID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid everything", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0+(4*cMapSize));
	int playerFishID=rmCreateObjectDef("owned fish");
	rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 8.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 40.0+(5.0*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainDistanceConstraint("fish vs land", "land", true, 4.0));
	rmAddObjectDefConstraint(playerFishID, rmCreateTerrainMaxDistanceConstraint("fish close to land", "land", true, 10.0));
	rmPlaceObjectDefPerPlayer(playerFishID, false);
	
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
	rmAddObjectDefConstraint(startingTowerID, huntShortAvoidsStartingGoldMilky);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		increment = 24;
		while( rmGetNumberUnitsPlaced(startingTowerID) < (4*p) ){
			rmPlaceObjectDefAtLoc(startingTowerID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
			increment++;
			rmSetObjectDefMaxDistance(startingTowerID, increment);
		}
	}
	
	rmSetStatusText("",0.66);
	
	/* ************************* */
	/* Section 11 Medium Objects */
	/* ************************* */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int mediumFarSettlementID=rmCreateObjectDef("far settlement");
	rmAddObjectDefItem(mediumFarSettlementID, "Settlement", 1, 0.0);
	rmSetObjectDefMinDistance(mediumFarSettlementID, 60.0);
	rmSetObjectDefMaxDistance(mediumFarSettlementID, 120.0);
	rmAddObjectDefConstraint(mediumFarSettlementID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumFarSettlementID, rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0));
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(mediumFarSettlementID, 0, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
	}
	if(cMapSize == 2){
		int TCgiant = rmCreateTypeDistanceConstraint("Giant TCs avoid TCs", "AbstractSettlement", 50.0);
		int farID = -1;
		for(p = 1; <= cNumberNonGaiaPlayers){
			for(TC = 0; < 2){
				farID=rmCreateObjectDef("giant settlement"+p+"_"+TC);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, avoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCgiant);
				if(cNumberNonGaiaPlayers >= 8){
					for(attempt = 4; <= 8){
						rmPlaceObjectDefAtLoc(farID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
						if(rmGetNumberUnitsPlaced(farID) > 0){
							break;
						}
						rmSetObjectDefMaxDistance(farID, 70*attempt);
					}
				} else if(cNumberNonGaiaPlayers >= 5){
					for(attempt = 3; <= 8){
						rmPlaceObjectDefAtLoc(farID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
						if(rmGetNumberUnitsPlaced(farID) > 0){
							break;
						}
						rmSetObjectDefMaxDistance(farID, 60*attempt);
					}
				} else {
					for(attempt = 1; <= 5){
						rmPlaceObjectDefAtLoc(farID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
						if(rmGetNumberUnitsPlaced(farID) > 0){
							break;
						}
						rmSetObjectDefMaxDistance(farID, 58*attempt);
					}
				}
			}
		}
	}
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 45.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, avoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 50.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, avoidFood);
	rmAddObjectDefConstraint(mediumPigsID, avoidGold);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(mediumPigsID, 0, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
	}
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 60.0);
		
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 100.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("player"+i), 2);
	}
	
	int bonusGoldID=rmCreateObjectDef("bonus gold");
	rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(bonusGoldID, 0.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 80.0);	//Not quite elegant
	rmAddObjectDefConstraint(bonusGoldID, avoidGold);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, farStartingSettleConstraint);
	for(i=0; <bonusCount){
		rmPlaceObjectDefInArea(bonusGoldID, 0, rmAreaID("bonus island"+i), 1);
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "boar", 2, 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "deer", 6, 8.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.36));	//Is this giant?
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i));
	}
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 150.0);
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farPigsID, 0, rmAreaID("player"+i));
	}
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements", "AbstractSettlement", 50.0));
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("player"+i));
	}
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 40.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i));
	}
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0));
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */
	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 55.0));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid settlements", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(3, 5));
		
		int giantAvoidHuntable=rmCreateTypeDistanceConstraint("giant avoid bonus huntable", "huntable", 40.0);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(6,7), 8.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidFood);
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, avoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		rmAddObjectDefItem(giantHuntable2ID, "boar", 3, 4.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidFood);
		rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, avoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, avoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 15.0);
	int forestTCConstraint=rmCreateTypeDistanceConstraint("forest TCs", "AbstractSettlement", 12.0);
	
	// Player forests.
	for(i=1; <cNumberPlayers) {
		failCount=0;
		int forestCount=rmRandInt(5, 8);
		if(cMapSize == 2) {
			forestCount = 1.75*forestCount;
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
			rmAddAreaConstraint(forestID, forestTCConstraint);
			rmAddAreaConstraint(forestID, forestObjConstraint);
			rmAddAreaConstraint(forestID, forestConstraint);
			rmAddAreaConstraint(forestID, forestTerrain);
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
				if(failCount==3) {
					break;
				}
			} else {
				failCount=0;
			}
		}
	}
	
	// Random island forests.
	int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 10.0);
	for(i=0; <bonusCount) {
		forestCount=rmRandInt(2, 3)*mapSizeMultiplier;
		for(j=0; <forestCount) {
			forestID=rmCreateArea("bonus"+i+"forest"+j, rmAreaID("bonus island"+i));
			rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
			if(cMapSize == 2) {
				rmSetAreaSize(forestID, rmAreaTilesToFraction(125), rmAreaTilesToFraction(200));
			}
			
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, "palm forest");
			rmAddAreaConstraint(forestID, forestSettleConstraint);
			rmAddAreaConstraint(forestID, forestTCConstraint);
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
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5*mapSizeMultiplier);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	// Birds
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2*mapSizeMultiplier);

	// Text
	rmSetStatusText("",1.0);
}
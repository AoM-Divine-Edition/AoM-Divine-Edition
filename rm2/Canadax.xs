/*	Map Name: Deep Jungle.xs
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
	int playerTiles=8350;
	if(cMapSize == 1) {
		playerTiles = 10000;
		rmEchoInfo("Large map");
	}
	else if(cMapSize == 2) {
		playerTiles = 16000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	// Set up default water.
	rmSetSeaLevel(0.0);
	
	// Init map.
	string terrainBase = "PlainA"; //"GrassA";
	rmTerrainInitialize(terrainBase);
	rmSetGaiaCiv(cCivZeus);
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classPlayerCore = rmDefineClass("player core");
	int classForest=rmDefineClass("forest");
	int classHill = rmDefineClass("classHill");
	int pathClass = rmDefineClass("path");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int tinyAvoidImpassableLand = rmCreateTerrainDistanceConstraint("tiny avoid impassable land", "land", false, 1.0);
	int pathConstraint = rmCreateClassDistanceConstraint("areas vs path", pathClass, 2.0);
	int playerConstraint = rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10);
	int avoidPlayerCore = rmCreateClassDistanceConstraint("stay away from player core", classPlayerCore, 5.0);
	int edgeConstraint = rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	
	int et = 20;
	int farEdgeConstraint = rmCreateBoxConstraint("far edge of map", rmXTilesToFraction(et), rmZTilesToFraction(et), 1.0-rmXTilesToFraction(et), 1.0-rmZTilesToFraction(et));
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	string terrainRoad = "greekRoadA";
	string terrainLush = "PlainA";
	
	string terrainLargeAreaEdge = terrainBase;
	string terrainLargeAreaMid = "PlainB";
	string terrainLargeAreaStart = "PlainB";
	string terrainLargeAreaCentre = "PlainB";
	
	string terrainBeauty = "PlainDirt25"; //"JungleDirt"; <--- Causes Crash?
	string waterType = "American River";
	string forestType = "AOE Birch Forest";
	
	rmSetTeamSpacingModifier(0.55);
	rmPlacePlayersCircular(0.35, 0.4, rmDegreesToRadians(5.0));
	rmRecordPlayerLocations();
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	float playerFraction=rmAreaTilesToFraction(100);
	for(i=1; <cNumberPlayers){
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

		rmSetAreaTerrainType(id, terrainLargeAreaCentre);
		rmAddAreaTerrainLayer(id, terrainLargeAreaEdge, 0, 8);
		rmAddAreaTerrainLayer(id, terrainLargeAreaMid, 8, 16);
		rmAddAreaTerrainLayer(id, terrainLargeAreaStart, 16, 24);
	}
	rmBuildAllAreas();
	
	playerFraction = rmAreaTilesToFraction(400);
	for(i=1; <cNumberPlayers){
		int playerCore = rmCreateArea("PlayerCore"+i);
		rmSetAreaSize(playerCore, 0.9*playerFraction, 1.1*playerFraction);
		rmSetPlayerArea(i, playerCore);
		rmAddAreaToClass(playerCore, classPlayerCore);
		rmSetAreaWarnFailure(playerCore, false);
		rmSetAreaMinBlobs(playerCore, 1);
		rmSetAreaMaxBlobs(playerCore, 5);
		rmSetAreaMinBlobDistance(playerCore, 16.0);
		rmSetAreaMaxBlobDistance(playerCore, 40.0);
		rmSetAreaCoherence(playerCore, 0.0);
		rmSetAreaLocPlayer(playerCore, i);
		rmSetAreaTerrainType(playerCore, terrainLargeAreaCentre);
		rmAddAreaTerrainLayer(playerCore, terrainLargeAreaEdge, 0, 8);
		rmAddAreaTerrainLayer(playerCore, terrainLargeAreaMid, 8, 16);
		rmAddAreaTerrainLayer(playerCore, terrainLargeAreaStart, 16, 24);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <=cNumberTeams){
		if(rmGetNumberPlayersOnTeam(i) > 1){
			int connect = rmCreateConnection("connect Allies");
			rmAddConnectionToClass(connect, pathClass);
			rmSetConnectionType(connect, cConnectAllies, false, 1.0);
			rmSetConnectionWidth(connect, 9.0, 2.0);
			rmAddConnectionTerrainReplacement(connect, terrainBase, terrainRoad);
			rmAddConnectionTerrainReplacement(connect, terrainLargeAreaCentre, terrainRoad);
			rmAddConnectionTerrainReplacement(connect, terrainLargeAreaStart, terrainRoad);
			rmAddConnectionTerrainReplacement(connect, terrainLargeAreaMid, terrainRoad);
			rmAddConnectionTerrainReplacement(connect, terrainLargeAreaEdge, terrainRoad);
			rmBuildConnection(connect);
			break;
		}
	}
	
	for(i=1; <cNumberPlayers){
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, terrainLargeAreaMid);
		rmSetAreaMinBlobs(id2, 1);
		rmSetAreaMaxBlobs(id2, 5);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0);
		rmSetAreaCoherence(id2, 0.0);
		rmAddAreaConstraint(id2, pathConstraint);
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*20){
		int id4=rmCreateArea("Grass patch 2 "+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(8), rmAreaTilesToFraction(16));
		rmSetAreaTerrainType(id4, terrainLush);
		rmSetAreaMinBlobs(id4, 1);
		rmSetAreaMaxBlobs(id4, 5);
		rmSetAreaWarnFailure(id4, false);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0);
		rmSetAreaCoherence(id4, 0.0);
		rmAddAreaConstraint(id4, pathConstraint);
		rmBuildArea(id4);
	}
	
	for(i=1; <cNumberPlayers*12){
		int id5=rmCreateArea("Grass patch 3 "+i);
		rmSetAreaSize(id5, rmAreaTilesToFraction(5), rmAreaTilesToFraction(20));
		rmSetAreaTerrainType(id5, terrainBeauty);
		rmSetAreaMinBlobs(id5, 1);
		rmSetAreaMaxBlobs(id5, 5);
		rmSetAreaWarnFailure(id5, false);
		rmSetAreaMinBlobDistance(id5, 16.0);
		rmSetAreaMaxBlobDistance(id5, 40.0);
		rmSetAreaCoherence(id5, 0.0);
		rmAddAreaConstraint(id5, pathConstraint);
		rmBuildArea(id5);
	}
	
	int numTries=30*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries){
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 4.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false){
			failCount++;
			if(failCount==3) {
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
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs(elevID, 3);
		rmSetAreaMaxBlobs(elevID, 10);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false){
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int pondClass=rmDefineClass("pond");
	int pondConstraint=rmCreateClassDistanceConstraint("pond vs. pond", rmClassID("pond"), 50.0);
	int smallPondConstraint=rmCreateClassDistanceConstraint("things vs. pond", rmClassID("pond"), 1.0);
	
	int numPond=(cNumberPlayers+4);
	int fishiesID = -1;
	int SeaID = -1;
	int waterLillyID = -1;
	int waterReedID = -1;
	
	if(rmRandFloat(0.0,1.0) > 0.01){
	
		fishiesID=rmCreateObjectDef("fishies");
		rmAddObjectDefItem(fishiesID, "Fish - Salmon", 1, 10.0);
		rmSetObjectDefMinDistance(fishiesID, 0.0);
		rmSetObjectDefMaxDistance(fishiesID, 10.0);

		SeaID=rmCreateObjectDef("Seaweed");
		rmAddObjectDefItem(SeaID, "Seaweed", 2, 3.0);
		rmSetObjectDefMinDistance(SeaID, 0.0);
		rmSetObjectDefMaxDistance(SeaID, 10.0);
		
		waterLillyID=rmCreateObjectDef("Water Lilly");
		rmAddObjectDefItem(waterLillyID, "Water Lilly", 3, 8.0);
		rmSetObjectDefMinDistance(waterLillyID, 0.0);
		rmSetObjectDefMaxDistance(waterLillyID, 10.0);
		
		waterReedID=rmCreateObjectDef("Zflowers");
		rmAddObjectDefItem(waterReedID, "Zflowers", 1, 1.0);
		rmSetObjectDefMinDistance(waterReedID, 0.0);
		rmSetObjectDefMaxDistance(waterReedID, rmAreaTilesToFraction(500));
		rmAddObjectDefConstraint(waterReedID, tinyAvoidImpassableLand);
		
		for(i=0; <numPond){
			int smallPondID=rmCreateArea("small pond"+i);
			rmSetAreaSize(smallPondID, rmAreaTilesToFraction(400), rmAreaTilesToFraction(500));
			rmSetAreaWaterType(smallPondID, waterType);
			rmSetAreaCoherence(smallPondID, 0.6); //Some pond consistency
			rmAddAreaToClass(smallPondID, pondClass);
			rmAddAreaConstraint(smallPondID, pondConstraint);
			rmAddAreaConstraint(smallPondID, avoidPlayerCore);
			rmSetAreaWarnFailure(smallPondID, false);
			rmBuildArea(smallPondID);
			
			rmPlaceObjectDefInArea(fishiesID, 0, rmAreaID("small pond"+i), rmRandInt(3,4));
			rmPlaceObjectDefInArea(SeaID, 0, rmAreaID("small pond"+i), cNumberNonGaiaPlayers);
			rmPlaceObjectDefInArea(waterLillyID, 0, rmAreaID("small pond"+i), 1);
			rmPlaceObjectDefInArea(waterReedID, 0, rmAreaID("small pond"+i), 12+4*cNumberNonGaiaPlayers);
		}
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by long distance", "AbstractSettlement", 50.0);
	int hugeAvoidSettlement=rmCreateTypeDistanceConstraint("TC avoid TC by huge distance", "AbstractSettlement", 80.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("gold vs. gold", "gold", 24.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far gold vs. gold", "gold", 40.0);
	
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
	int avoidFoodFar=rmCreateTypeDistanceConstraint("far avoid food", "food", 24.0);
	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0);
	
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 8.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
	
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	
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
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 60.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int closeID = -1;
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		
		id=rmAddFairLoc("Settlement", false, true, 60, 80, 60, 16);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, farEdgeConstraint);
		rmAddFairLocConstraint(id, TCavoidStart);
		
		if(rmPlaceFairLocs()) {
			for(p = 1; <= cNumberNonGaiaPlayers){
			id=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
			int settleArea = rmCreateArea("settlement area"+p);
			rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settleArea, 0.01, 0.01);
			rmSetAreaTerrainType(settleArea, terrainLargeAreaStart);
			rmAddAreaTerrainLayer(settleArea, terrainLargeAreaMid, 2, 5);
			rmAddAreaTerrainLayer(settleArea, terrainLargeAreaEdge, 0, 2);
			rmBuildArea(settleArea);
			}
		}
		rmResetFairLocs();
	
		id=rmAddFairLoc("Settlement", true, false,  80, 100, 60, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, farEdgeConstraint);
		
		if(rmPlaceFairLocs()) {
			for(p = 1; <= cNumberNonGaiaPlayers){
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, terrainLargeAreaStart);
				rmAddAreaTerrainLayer(settlementArea, terrainLargeAreaMid, 2, 5);
				rmAddAreaTerrainLayer(settlementArea, terrainLargeAreaEdge, 0, 2);
		
				rmBuildArea(settlementArea);
			}
		}
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
			rmAddObjectDefConstraint(closeID, farEdgeConstraint);
			for(attempt = 4; <= 12){
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
			rmAddObjectDefConstraint(farID, farEdgeConstraint);
			for(attempt = 6; <= 10){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 15*attempt);
			}
		}
	}
	rmResetFairLocs();
		
	if(cMapSize == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			farID=rmCreateObjectDef("giant settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			rmAddObjectDefConstraint(farID, farEdgeConstraint);
			for(attempt = 2; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 15*attempt);
			}
			
			farID=rmCreateObjectDef("giant2 settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			rmAddObjectDefConstraint(farID, farEdgeConstraint);
			for(attempt = 2; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 16*attempt);
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
	rmAddObjectDefItem(startingHuntableID, "Moose", rmRandInt(14,25), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 20.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false, 1);
	
	int closePigID=rmCreateObjectDef("close pig");
	rmAddObjectDefItem(closePigID, "Turkey", rmRandInt(12,25), 2.0);
	rmSetObjectDefMinDistance(closePigID, 20.0);
	rmSetObjectDefMaxDistance(closePigID, 25.0);
	rmAddObjectDefConstraint(closePigID, avoidFood);
	rmAddObjectDefConstraint(closePigID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(closePigID, true);
	
	int startingDuckID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingDuckID, "Duck", rmRandInt(15,20), 3.0);
	rmSetObjectDefMaxDistance(startingDuckID, 8.0);
	rmSetObjectDefMaxDistance(startingDuckID, 20.0);
	rmAddObjectDefConstraint(startingDuckID, getOffTheTC);
	rmAddObjectDefConstraint(startingDuckID, avoidFood);
	rmAddObjectDefConstraint(startingDuckID, huntShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(startingDuckID, false);

	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(15,27), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 18.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingBerryID, avoidFood);
	rmAddObjectDefConstraint(startingBerryID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingBerryID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "ZMaple Tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmCreateTypeDistanceConstraint("tres avoid all", "all", 5.0);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(2, 5));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
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
	
	rmSetStatusText("",0.66);
	
	/* ************************* */
	/* Section 11 Medium Objects */
	/* ************************* */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 55.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, 1);
	
	int mediumDeerID=rmCreateObjectDef("medium deer");
	rmAddObjectDefItem(mediumDeerID, "Moose", rmRandInt(3,8), 4.0);
	rmSetObjectDefMinDistance(mediumDeerID, 60.0);
	rmSetObjectDefMaxDistance(mediumDeerID, 80.0);
	rmAddObjectDefConstraint(mediumDeerID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumDeerID, farStartingSettleConstraint);
	for(i=1; <cNumberPlayers){
		rmPlaceObjectDefAtLoc(mediumDeerID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
	}
	
	int mediumPigID=rmCreateObjectDef("medium Pig");
	rmAddObjectDefItem(mediumPigID, "Turkey", rmRandFloat(2,3), 4.0);
	rmSetObjectDefMinDistance(mediumPigID, 55.0);
	rmSetObjectDefMaxDistance(mediumPigID, 80.0);
	rmAddObjectDefConstraint(mediumPigID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumPigID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumPigID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 110.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1, 2));
	
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 42.5);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance < 0.5){
		rmAddObjectDefItem(bonusHuntableID, "bear black", 4, 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "bear grizzly", rmRandInt(3,4), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false, rmRandInt(1, 2));
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.4){
		rmAddObjectDefItem(farPredatorID, "bear grizzly", 2.0, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "Cougar", rmRandInt(1,2), 4.0);
		//rmAddObjectDefItem(farPredatorID, "bear black", 2, 4.0); //makeshift Tiger
	}
	rmSetObjectDefMinDistance(farPredatorID, 50.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 112", "gold", 50.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 112", "AbstractSettlement", 50.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relics "+i);
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 80.0));
	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		rmSetObjectDefMinDistance(farGoldID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(farGoldID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2, 3));
		
		int bigPiggiesID=rmCreateObjectDef("giant Pig");
		rmAddObjectDefItem(bigPiggiesID, "pig", rmRandFloat(2,3), 4.0);
		rmSetObjectDefMinDistance(bigPiggiesID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(bigPiggiesID, rmZFractionToMeters(0.35));
		rmAddObjectDefConstraint(bigPiggiesID, avoidFoodFar);
		rmAddObjectDefConstraint(bigPiggiesID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(bigPiggiesID, false, 2);
		
		rmSetObjectDefMaxDistance(bonusHuntableID, rmZFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(bonusHuntableID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 1);
		
		rmSetObjectDefMaxDistance(bonusHuntableID, rmZFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(bonusHuntableID, rmZFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(bonusHuntableID, false, rmRandInt(1, 2));
		
		rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 8.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 18.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 30.0);
	int count=0;
	numTries=20*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(rmRandInt(600,800)), rmAreaTilesToFraction(rmRandInt(850,1550)));
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, forestType);
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, shortAvoidSettlement);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, pathConstraint);
		rmAddAreaConstraint(forestID, smallPondConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 8);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmRandFloat(0.0, 1.0)<0.2){
			rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));
		}
		
		if(rmBuildArea(forestID)==false){
			failCount++;
			if(failCount==8) {
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
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "ZMaple Tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 25*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "Rock Overgrown Small", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
	int largeRockID=rmCreateObjectDef("rock large");
	rmAddObjectDefItem(largeRockID, "Rock Overgrown Big", 1, 0.0);
	rmSetObjectDefMinDistance(largeRockID, 0.0);
	rmSetObjectDefMaxDistance(largeRockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(largeRockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(largeRockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidImpassableLand);
	rmAddObjectDefConstraint(logID, avoidBuildings);
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);
	
	int bushID=rmCreateObjectDef("foliage");
	rmAddObjectDefItem(bushID, "bush", 1, 1.0);
	rmSetObjectDefMinDistance(bushID, 0.0);
	rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 40*cNumberNonGaiaPlayers);
	
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 1, 3.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 150*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
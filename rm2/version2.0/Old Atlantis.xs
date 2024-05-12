/*	Map Name: Old Atlantis.xs
**	Author: Milkman Matty & RebelsRising
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
	int playerTiles=19000;
	if(cMapSize == 1) {
		playerTiles = 22800;
		rmEchoInfo("Large map");
	}
	else if(cMapSize == 2) {
		playerTiles = 28500;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	rmSetSeaLevel(3.0);
	rmSetSeaType("Old Atlantis Inner Sea");
	rmSetGaiaCiv(cCivPoseidon); //cCivKronos

	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classContinent = rmDefineClass("continent");
	int classWater = rmDefineClass("water");
	int classPlayer = rmDefineClass("players");
	int classForest = rmDefineClass("forest");
	int classPond = rmDefineClass("pond");
	int classFishSpot = rmDefineClass("fishing spot");
	int classRuins = rmDefineClass("ruins");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int shortAvoidAll = rmCreateTypeDistanceConstraint("short avoid all", "all", 5.0);
	int mediumAvoidAll = rmCreateTypeDistanceConstraint("medium avoid all", "all", 8.0);
	int playerConstraint = rmCreateClassDistanceConstraint("stay away from players", classPlayer, 40.0);
	
	int veryShortWaterConstraint = rmCreateClassDistanceConstraint("very short avoid water", classWater, 5.0);
	int shortWaterConstraint=rmCreateClassDistanceConstraint("short avoid water", classWater, 15.0);
	int mediumWaterConstraint = rmCreateClassDistanceConstraint("medium avoid water", classWater, 25.0);
	int avoidPond = rmCreateClassDistanceConstraint("pond vs pond", classPond, 30.0);
	int continentConstraint=rmCreateClassDistanceConstraint("avoid continent", classContinent, 0.2);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int shallowID=rmCreateArea("shallow");
	rmSetAreaWarnFailure(shallowID, false);
	rmSetAreaSize(shallowID, 0.31);
	rmSetAreaLocation(shallowID, 0.5, 0.5);
	rmSetAreaCoherence(shallowID, 0.4);
	rmSetAreaBaseHeight(shallowID, 2.0);
	rmSetAreaHeightBlend(shallowID, 1.0);
	rmAddAreaToClass(shallowID, classContinent);
	rmBuildArea(shallowID);
	
	for(i=1; <5) {
		int oceanID=rmCreateArea("ocean"+i);
		rmSetAreaWarnFailure(oceanID, false);
		rmSetAreaWaterType(oceanID, "Old Atlantis Inner Sea");
		rmSetAreaSize(oceanID, 0.2);
		if(i==1) {
			rmSetAreaLocation(oceanID, 0.0, 0.0);
		}
		if(i==2) {
			rmSetAreaLocation(oceanID, 1.0, 0.0);
		}
		if(i==3) {
			rmSetAreaLocation(oceanID, 1.0, 1.0);
		}
		if(i==4) {
			rmSetAreaLocation(oceanID, 0.0, 1.0);
		}
		rmAddAreaConstraint(oceanID, continentConstraint);
		rmAddAreaToClass(oceanID, classWater);
		rmBuildArea(oceanID);
	}
	
	int nearShore = rmCreateEdgeMaxDistanceConstraint("near shore", rmAreaID("shallow"), 12.0);
	int offShore = rmCreateEdgeDistanceConstraint("avoid shore", rmAreaID("shallow"), 20.0);
	int shoreMin = rmCreateEdgeDistanceConstraint("stay away from shore", rmAreaID("shallow"), 0.001);
	int shoreMax = rmCreateEdgeMaxDistanceConstraint("stay near shore", rmAreaID("shallow"), 3.0);
	
	int fails = 0;
	for(i=1; < 24) {
		int shoreID=rmCreateArea("shore"+i);
		rmSetAreaWarnFailure(shoreID, false);
		rmSetAreaBaseHeight(shoreID, 5);
		rmSetAreaSize(shoreID, rmAreaTilesToFraction(300));
		rmSetAreaSmoothDistance(shoreID, 0.0);
		rmSetAreaHeightBlend(shoreID, 2.0);
		rmSetAreaCoherence(shoreID, 0.0);
		rmSetAreaTerrainType(shoreID, "GrassB");
		rmAddAreaConstraint(shoreID, shoreMin);
		rmAddAreaConstraint(shoreID, shoreMax);
		rmAddAreaToClass(shoreID, classContinent);
		if(rmBuildArea(shoreID)==false) {
			fails++;
			if(fails==3) {
				break;
			}
		}
	}

	// Replace shore terrain
	int replaceID=rmCreateArea("replace");
	rmSetAreaWarnFailure(replaceID, false);
	rmAddAreaTerrainReplacement(replaceID, "ShorelineMediterraneanB", "GrassB");
	rmSetAreaSize(replaceID, 1.0);
	rmSetAreaLocation(replaceID, 0.5, 0.5);
	rmBuildArea(replaceID);
	
	int atollEmbellishmentID = -1;
	int atollEmbellishmentID1 = -1;
	int atollEmbellishmentID2 = -1;
	
	int playerAtollGoldID=rmCreateObjectDef("player atoll gold");
	rmAddObjectDefItem(playerAtollGoldID, "gold mine small", 1, 1+cMapSize);
	
	float angle = placePointsCircle(0.49, cNumberNonGaiaPlayers);
	
	int paForestVWater = rmCreateTerrainDistanceConstraint("pa forest vs water", "water", true, 5.0);
	
	if(cNumberNonGaiaPlayers <= 4){
		for(i = 1; <= cNumberNonGaiaPlayers) {
			
			
			int playerAtollID = rmCreateArea("player atoll"+i);
			rmSetAreaSize(playerAtollID, 0.0075+(0.0025*cMapSize));
			rmSetAreaCoherence(playerAtollID, 0.80);
			rmSetAreaHeightBlend(playerAtollID, 2);
			rmSetAreaBaseHeight(playerAtollID, 5.0);
			rmSetAreaWarnFailure(playerAtollID, true);
			rmAddAreaConstraint(playerAtollID, playerConstraint);
			rmAddAreaConstraint(playerAtollID, offShore);
			rmSetAreaLocation(playerAtollID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmEchoInfo(""+rmGetCustomLocXForPlayer(i)+", "+rmGetCustomLocZForPlayer(i));
			rmSetAreaTerrainType(playerAtollID, "grassB");
			rmAddAreaTerrainLayer(playerAtollID, "GrassDirt75", 0, 3);
			rmAddAreaTerrainLayer(playerAtollID, "GrassDirt50", 3, 6);
			rmAddAreaTerrainLayer(playerAtollID, "GrassDirt25", 6, 9);
			rmAddAreaTerrainLayer(playerAtollID, "GrassA", 9, 12);
			rmBuildArea(playerAtollID);
			
			rmPlaceObjectDefAtAreaLoc(playerAtollGoldID, 0, playerAtollID);
			
			for(j = 1; < rmRandInt(4,6)) {
				int playerAtollForestID=rmCreateArea("player atoll forest"+i+j, playerAtollID);
				rmSetAreaSize(playerAtollForestID, rmAreaTilesToFraction(30), rmAreaTilesToFraction(45));
				rmSetAreaWarnFailure(playerAtollForestID, false);
				rmSetAreaForestType(playerAtollForestID, "oak forest");
				rmAddAreaConstraint(playerAtollForestID, mediumAvoidAll);
				rmAddAreaConstraint(playerAtollForestID, paForestVWater);
				rmSetAreaSmoothDistance(playerAtollForestID, 5.0);
				rmSetAreaHeightBlend(playerAtollForestID, 2.0);
				rmSetAreaBaseHeight(playerAtollForestID, 5);
				rmSetAreaMinBlobs(playerAtollForestID, 1);
				rmSetAreaMaxBlobs(playerAtollForestID, 2);
				rmSetAreaMinBlobDistance(playerAtollForestID, 16.0);
				rmSetAreaMaxBlobDistance(playerAtollForestID, 20.0);
				rmSetAreaCoherence(playerAtollForestID, 0.0);
				rmBuildArea(playerAtollForestID);
			}		
			if(rmRandFloat(0,1)<0.5 && cMapSize == 2) {
				atollEmbellishmentID=rmCreateObjectDef("player atoll embellishment 0 "+i);
				rmAddObjectDefItem(atollEmbellishmentID, "relic", 1, 0.0);
				rmAddObjectDefConstraint(atollEmbellishmentID, shortAvoidAll);
				rmPlaceObjectDefInArea(atollEmbellishmentID, 0, playerAtollID);
			}
			
			atollEmbellishmentID1=rmCreateObjectDef("player atoll embellishment 1 "+i);
			rmAddObjectDefItem(atollEmbellishmentID1, "deer", rmRandInt(2,3), 5.0);
			rmAddObjectDefConstraint(atollEmbellishmentID1, shortAvoidAll);
			rmPlaceObjectDefInArea(atollEmbellishmentID1, 0, playerAtollID);

			atollEmbellishmentID2=rmCreateObjectDef("player atoll embellishment 2 "+i);
			rmAddObjectDefItem(atollEmbellishmentID2, "oak tree", 1, 0.0);
			rmAddObjectDefConstraint(atollEmbellishmentID2, mediumAvoidAll);
			rmPlaceObjectDefInArea(atollEmbellishmentID2, 0, playerAtollID, rmRandInt(3, 10));
		}
	}
	
	int atollGoldID=rmCreateObjectDef("atoll gold");
	rmAddObjectDefItem(atollGoldID, "gold mine", 1, 1+cMapSize);
	
	placePointsCircle(0.49, 12, -1.0, -1.0, false, false);
	
	for(i = 1; < 13) {
		int atollID=rmCreateArea("atoll"+i);
		rmSetAreaSize(atollID, 0.01);
		rmSetAreaCoherence(atollID, 0.80);
		rmSetAreaHeightBlend(atollID, 2);
		rmSetAreaBaseHeight(atollID, 5.0);
		rmAddAreaConstraint(atollID, playerConstraint);
		rmAddAreaConstraint(atollID, offShore);
		rmSetAreaLocation(atollID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
		rmSetAreaTerrainType(atollID, "GrassB");
		rmAddAreaTerrainLayer(atollID, "GrassDirt75", 0, 3);
		rmAddAreaTerrainLayer(atollID, "GrassDirt50", 3, 6);
		rmAddAreaTerrainLayer(atollID, "GrassDirt25", 6, 9);
		rmAddAreaTerrainLayer(atollID, "GrassA", 9, 12);
		rmBuildArea(atollID);
		
		rmPlaceObjectDefAtAreaLoc(atollGoldID, 0, rmAreaID("atoll"+i));
		
		// Embellishment
		for(j = 1; < rmRandInt(4,6)) {
			int atollForestID=rmCreateArea("atoll forest"+i+j, atollID);
			rmSetAreaSize(atollForestID, rmAreaTilesToFraction(30), rmAreaTilesToFraction(45));
			rmSetAreaWarnFailure(atollForestID, false);
			rmSetAreaForestType(atollForestID, "oak forest");
			rmAddAreaConstraint(atollForestID, mediumAvoidAll);
			rmAddAreaConstraint(atollForestID, paForestVWater);
			rmSetAreaSmoothDistance(atollForestID, 5.0);
			rmSetAreaHeightBlend(atollForestID, 2.0);
			rmSetAreaBaseHeight(atollForestID, 5);
			rmSetAreaMinBlobs(atollForestID, 1);
			rmSetAreaMaxBlobs(atollForestID, 2);
			rmSetAreaMinBlobDistance(atollForestID, 16.0);
			rmSetAreaMaxBlobDistance(atollForestID, 20.0);
			rmSetAreaCoherence(atollForestID, 0.0);
			rmBuildArea(atollForestID);
		}		
		if(rmRandFloat(0,1)<0.5) {
			atollEmbellishmentID=rmCreateObjectDef("atoll embellishment 0 "+i);
			rmAddObjectDefItem(atollEmbellishmentID, "relic", 1, 0.0);
			rmAddObjectDefConstraint(atollEmbellishmentID, shortAvoidAll);
			rmPlaceObjectDefInArea(atollEmbellishmentID, 0, rmAreaID("atoll"+i));
		}
		
		atollEmbellishmentID1=rmCreateObjectDef("atoll embellishment 1 "+i);
		rmAddObjectDefItem(atollEmbellishmentID1, "deer", rmRandInt(0,3), 5.0);
		rmAddObjectDefConstraint(atollEmbellishmentID1, shortAvoidAll);
		rmPlaceObjectDefInArea(atollEmbellishmentID1, 0, rmAreaID("atoll"+i));

		atollEmbellishmentID2=rmCreateObjectDef("atoll embellishment 2 "+i);
		rmAddObjectDefItem(atollEmbellishmentID2, "oak tree", 1, 0.0);
		rmAddObjectDefConstraint(atollEmbellishmentID2, mediumAvoidAll);
		rmPlaceObjectDefInArea(atollEmbellishmentID2, 0, rmAreaID("atoll"+i), rmRandInt(3, 10));
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	rmSetTeamSpacingModifier(0.9);
	//rmPlacePlayersCircular(0.23, 0.23, rmDegreesToRadians(5.0));
	if(cNumberNonGaiaPlayers <= 4){
		placePointsCircle(0.23, cNumberNonGaiaPlayers, angle, -1.0, true);
	} else {
		placePointsCircleCustom(0.23, cNumberNonGaiaPlayers, -1.0, -1.0, 0.5,0.5, true);
	}
	rmRecordPlayerLocations();
	
	float playerFraction=rmAreaTilesToFraction(700);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaSmoothDistance(id, 5.0);
		rmSetAreaHeightBlend(id, 2.0);
		rmSetAreaBaseHeight(id, 5);
		rmSetAreaMinBlobs(id, 2);
		rmSetAreaMaxBlobs(id, 3);
		rmSetAreaMinBlobDistance(id, 10.0);
		rmSetAreaMaxBlobDistance(id, 25.0);
		rmSetAreaCoherence(id, 0.8);
		rmSetAreaTerrainType(id, "GrassB");
		rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 3);
		rmAddAreaTerrainLayer(id, "GrassDirt50", 3, 6);
		rmAddAreaTerrainLayer(id, "GrassDirt25", 6, 9);
		rmAddAreaTerrainLayer(id, "GrassA", 9, 12);
		rmSetAreaLocPlayer(id, i);
	}
   
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int pondTiles = 240;
	int numPond = 2*cNumberNonGaiaPlayers;
	if(cMapSize > 0) {
		numPond = 3*cNumberNonGaiaPlayers;
	}
	for(i = 0; < numPond) {
		int pondID=rmCreateArea("pond"+i);
		rmSetAreaSize(pondID, rmAreaTilesToFraction(pondTiles));
		rmSetAreaWaterType(pondID, "Old Atlantis Inner Sea");
		rmAddAreaToClass(pondID, classPond);
		rmAddAreaConstraint(pondID, mediumWaterConstraint);
		rmAddAreaConstraint(pondID, playerConstraint);
		rmAddAreaConstraint(pondID, avoidPond);
		rmSetAreaHeightBlend(pondID, 3);
		rmSetAreaCoherence(pondID, 0.70);
		rmBuildArea(pondID);
		
		// Embellishments
		for(j = 1; < 3) {
			int pondEmbellishmentID=rmCreateObjectDef("embellishment "+i+j);
			rmAddObjectDefItem(pondEmbellishmentID, "Seaweed", rmRandInt(3,6), 5.0);
			rmSetObjectDefMinDistance(pondEmbellishmentID, 0.0);
			rmSetObjectDefMaxDistance(pondEmbellishmentID, 5.0);
			rmPlaceObjectDefInArea(pondEmbellishmentID, 0, rmAreaID("pond"+i));
		}
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int startingSettleConstraint=rmCreateClassDistanceConstraint("avoid starting settlement", rmClassID("starting settlement"), 37.5+cMapSize);
	int farAvoidStartTC = rmCreateClassDistanceConstraint("column avoid start TC", rmClassID("starting settlement"), 50.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 14.0);
	int avoidSettlement=rmCreateTypeDistanceConstraint("far avoid settlement", "AbstractSettlement", 30.0);
	
	int shortAvoidPond = rmCreateClassDistanceConstraint("short pond vs pond", classPond, 5.0);
	int shortAvoidGold = rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
	int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold = rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
	
	int shortAvoidImpassableLand = rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 1.0);
	
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
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 40.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateClassDistanceConstraint("TC avoid water", classWater, 22.5);
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int closeID = -1;
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
			
		id=rmAddFairLoc("Settlement", false, true, 60, 80, 40, 20, true);
		rmAddFairLocConstraint(id, TCavoidWater);
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
				rmAddAreaTerrainLayer(settleArea, "GrassA", 0, 8);
				rmAddAreaTerrainLayer(settleArea, "GrassDirt25", 8, 16);
				rmAddAreaTerrainLayer(settleArea, "GrassDirt50", 16, 24);
				rmBuildArea(settleArea);
			}
		} else {
			TCavoidWater = rmCreateClassDistanceConstraint("TC avoid water2", classWater, 14.0);
			for(p = 1; <= cNumberNonGaiaPlayers){
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidStart);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				for(attempt = 4; <= 12){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, 12*attempt);
				}
			}
		}
		rmResetFairLocs();
	
		id=rmAddFairLoc("Settlement", true, false, 60, 90, 30, 20);
		rmAddFairLocConstraint(id, TCavoidSettlement);
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
			TCavoidWater = rmCreateClassDistanceConstraint("TC avoid water3", classWater, 14.0);
			for(p = 1; <= cNumberNonGaiaPlayers){
				closeID=rmCreateObjectDef("close2 settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidStart);
				rmAddObjectDefConstraint(closeID, TCavoidWater);
				for(attempt = 4; <= 12){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, 12*attempt);
				}
			}
		}
		rmResetFairLocs();
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 36.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
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
			for(attempt = 6; <= 10){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 15*attempt);
			}
		}
	}
	
	if(cMapSize == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			farID=rmCreateObjectDef("giant settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
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
	int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 14.0);
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "deer", rmRandInt(3,4), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closePigsID=rmCreateObjectDef("close Pigs");
	rmAddObjectDefItem(closePigsID, "cow", 3, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmAddObjectDefConstraint(closePigsID, huntShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closePigsID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 13.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 16.0);
	rmAddObjectDefConstraint(stragglerTreeID, shortAvoidAll);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(3, 7));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 1.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	int forestFood = rmCreateTypeDistanceConstraint("super short V food", "food", 4.0);
	
	int maxNum = 5;
	for(p=1;<=cNumberNonGaiaPlayers){
		placePointsCircleCustom(rmXMetersToFraction(42.0), maxNum, -1.0, -1.0, rmPlayerLocXFraction(p), rmPlayerLocZFraction(p), false, false);
		int skip = rmRandInt(1,maxNum+2);
		for(i=1; <= maxNum){
			if(i == skip){
				continue;
			}
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i, shallowID);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(60+cNumberNonGaiaPlayers), rmAreaTilesToFraction(60+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "oak forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, huntShortAvoidsStartingGoldMilky);
			rmAddAreaConstraint(playerStartingForestID, forestFood);
			rmAddAreaToClass(playerStartingForestID, classForest);
			rmSetAreaBaseHeight(playerStartingForestID, 5);
			rmSetAreaCoherence(playerStartingForestID, 0.35);
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
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 45.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, veryShortWaterConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumCraneID=rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem(mediumCraneID, "crowned crane", rmRandInt(6,9), 3.0);
	rmSetObjectDefMinDistance(mediumCraneID, 40.0);
	rmSetObjectDefMaxDistance(mediumCraneID, 70.0);
	rmAddObjectDefConstraint(mediumCraneID, nearShore);
	rmAddObjectDefConstraint(mediumCraneID, shortAvoidGold);
	rmPlaceObjectDefPerPlayer(mediumCraneID, false);
	
	int pondFishID=rmCreateObjectDef("pond fish");
	rmAddObjectDefItem(pondFishID, "Fish - Salmon", 3, 8.0+(4*cMapSize));
	for(i = 0; < numPond) {
		rmPlaceObjectDefInArea(pondFishID, 0, rmAreaID("pond"+i));
	}
	
	int avoidContinent = rmCreateClassDistanceConstraint("fishy avoid continent", classContinent, 10.0);
	int avoidFS = rmCreateClassDistanceConstraint("fishy avoid self", classFishSpot, 22.0+(5*cMapSize));
	int fishyLand = rmCreateTerrainDistanceConstraint("fishy vs land", "land", true, 5.0);
	
	numPond = 6*cNumberNonGaiaPlayers;
	if(cMapSize > 0) {
		numPond = 8*cNumberNonGaiaPlayers;
	}
	for(i = 0; < numPond) {
		int fishyspotID=rmCreateArea("fishingSpot"+i);
		rmSetAreaSize(fishyspotID, rmAreaTilesToFraction(pondTiles));
		rmSetAreaWaterType(fishyspotID, "Old Atlantis Inner Sea");
		rmAddAreaToClass(fishyspotID, classFishSpot);
		rmAddAreaConstraint(fishyspotID, fishyLand);
		rmAddAreaConstraint(fishyspotID, avoidFS);
		rmAddAreaConstraint(fishyspotID, avoidContinent);
		rmSetAreaHeightBlend(fishyspotID, 2);
		rmSetAreaCoherence(fishyspotID, 0.70);
		rmBuildArea(fishyspotID);
		
		rmPlaceObjectDefInArea(pondFishID, 0, fishyspotID);
		
		for(j = 1; < 3) {
			int pondEmbellishment2ID=rmCreateObjectDef("embellishment 2 "+i+j);
			rmAddObjectDefItem(pondEmbellishment2ID, "Seaweed", rmRandInt(3,6), 5.0);
			rmSetObjectDefMinDistance(pondEmbellishment2ID, 0.0);
			rmSetObjectDefMaxDistance(pondEmbellishment2ID, 5.0);
			rmPlaceObjectDefInArea(pondEmbellishment2ID, 0, fishyspotID);
		}
	}
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmAddObjectDefConstraint(farGoldID, mediumWaterConstraint);
	rmAddObjectDefConstraint(farGoldID, startingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 1);
	
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 100.0);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1, 2));
	
	int avoidHunt=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	
	int bonusHuntID=rmCreateObjectDef("bonus hunt");
	rmAddObjectDefItem(bonusHuntID, "deer", rmRandInt(5,9), 4.0);
	rmSetObjectDefMinDistance(bonusHuntID, 60.0);
	rmSetObjectDefMaxDistance(bonusHuntID, 70.0);
	rmAddObjectDefConstraint(bonusHuntID, shortAvoidAll);
	rmAddObjectDefConstraint(bonusHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntID, avoidHunt);
	rmAddObjectDefConstraint(bonusHuntID, shortAvoidGold);
	rmAddObjectDefConstraint(bonusHuntID, shortAvoidPond);
	rmAddObjectDefConstraint(bonusHuntID, shortWaterConstraint);
	rmAddObjectDefConstraint(bonusHuntID, startingSettleConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntID, false, 1);
	
	rmSetObjectDefMinDistance(bonusHuntID, 70.0);
	rmSetObjectDefMaxDistance(bonusHuntID, 80.0);
	rmPlaceObjectDefPerPlayer(bonusHuntID, false, 1);
	
	int predatorID1=rmCreateObjectDef("predator");
	rmAddObjectDefItem(predatorID1, "bear", 1, 4.0);
	rmSetObjectDefMinDistance(predatorID1, 75.0);
	rmSetObjectDefMaxDistance(predatorID1, 87.5);
	rmAddObjectDefConstraint(predatorID1, shortAvoidAll);
	rmAddObjectDefConstraint(predatorID1, shortAvoidSettlement);
	rmAddObjectDefConstraint(predatorID1, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(predatorID1, mediumWaterConstraint);
	rmAddObjectDefConstraint(predatorID1, shortAvoidPond);
	rmAddObjectDefConstraint(predatorID1, startingSettleConstraint);
	rmAddObjectDefConstraint(predatorID1, shortAvoidGold);
	rmAddObjectDefConstraint(predatorID1, playerConstraint);
	rmPlaceObjectDefPerPlayer(predatorID1, false);
	
	int relicID=rmCreateObjectDef("relics");
	rmAddObjectDefItem(relicID, "relic", 1, 5.0);
	rmAddObjectDefItem(relicID, "skeleton", 1, 5.0);
	rmSetObjectDefMinDistance(relicID, 50.0);
	rmSetObjectDefMaxDistance(relicID, 100.0);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 60.0));
	rmAddObjectDefConstraint(relicID, shortAvoidGold);
	rmAddObjectDefConstraint(relicID, shortAvoidPond);
	rmAddObjectDefConstraint(relicID, shortWaterConstraint);
	rmAddObjectDefConstraint(relicID, startingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){	
	
		rmSetObjectDefMinDistance(farGoldID, rmXFractionToMeters(0.26));
		rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.4));
		rmPlaceObjectDefPerPlayer(farGoldID, false, 3);
	
		rmSetObjectDefMinDistance(bonusHuntID, rmXFractionToMeters(0.26));
		rmSetObjectDefMaxDistance(bonusHuntID, rmXFractionToMeters(0.4));
		rmPlaceObjectDefPerPlayer(bonusHuntID, false, 2);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* *************************** */
	/* Section 14 Map Fill Forests */
	/* *************************** */
	
	int columnID = 0;
	int ruinID = 0;
	int avoidRuins = rmCreateClassDistanceConstraint("ruin vs ruin", classRuins, 60.0);
	int mediumAvoidPond = rmCreateClassDistanceConstraint("ruins vs pond", classPond, 20.0);
	
	for(i=0; < (3+cMapSize)*cNumberNonGaiaPlayers) {
		ruinID=rmCreateArea("ruins "+i, shallowID);
		rmSetAreaSize(ruinID, rmAreaTilesToFraction(140), rmAreaTilesToFraction(160));
		rmSetAreaBaseHeight(ruinID, rmRandFloat(5.25,5.5));
		rmAddAreaToClass(ruinID, classRuins);
		rmSetAreaMinBlobs(ruinID, 1);
		rmSetAreaMaxBlobs(ruinID, 2);
		rmSetAreaWarnFailure(ruinID, false);
		rmSetAreaMinBlobDistance(ruinID, 16.0);
		rmSetAreaMaxBlobDistance(ruinID, 40.0);
		rmSetAreaCoherence(ruinID, 0.95);
		rmSetAreaSmoothDistance(ruinID, 10);
		rmSetAreaHeightBlend(ruinID, 2);
		rmAddAreaConstraint(ruinID, mediumAvoidPond);
		rmAddAreaConstraint(ruinID, avoidRuins);
		rmAddAreaConstraint(ruinID, shortAvoidSettlement);
		rmAddAreaConstraint(ruinID, farAvoidStartTC);
		
		rmBuildArea(ruinID);
		
		columnID=rmCreateObjectDef("columns "+i);
		rmAddObjectDefItem(columnID, "ruins", rmRandInt(1,2), 3.0);
		rmAddObjectDefItem(columnID, "columns broken", rmRandInt(2,5), 4.0);
		rmAddObjectDefItem(columnID, "columns", rmRandFloat(0,2), 4.0);
		rmAddObjectDefItem(columnID, "rock limestone small", rmRandInt(1,3), 8.0);
		rmAddObjectDefItem(columnID, "rock limestone sprite", rmRandInt(3,8), 12.0);
		rmAddObjectDefItem(columnID, "grass", rmRandFloat(3,6), 4.0);
		rmAddObjectDefItem(columnID, "bush short", rmRandFloat(3,4), 8.0);
		rmAddObjectDefItem(columnID, "bush", rmRandFloat(1,2), 6.0);
		rmSetObjectDefMinDistance(columnID, 0.0);
		rmSetObjectDefMaxDistance(columnID, 0.0);
		rmPlaceObjectDefInArea(columnID, 0, rmAreaID("ruins "+i), 1);
	}
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	int forestAvoidPond = rmCreateClassDistanceConstraint("map forest vs pond", classPond, 10.0);
	int forestAvoidFS = rmCreateClassDistanceConstraint("map forest vs fishyspot", classFishSpot, 10.0);
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "AbstractSettlement", 20.0);
	
	int forestCount=18*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	
	int failCount=0;
	
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "oak forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		//rmAddAreaConstraint(forestID, shortWaterConstraint);
		rmAddAreaConstraint(forestID, forestAvoidPond);
		rmAddAreaConstraint(forestID, forestAvoidFS);
		rmAddAreaToClass(forestID, classForest);
		rmSetAreaMinBlobs(forestID, 2);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 30.0);
		rmSetAreaCoherence(forestID, 0.0);
		rmSetAreaBaseHeight(forestID, 5);
		rmSetAreaSmoothDistance(forestID, 4);
		rmSetAreaHeightBlend(forestID, 2);
		
		if(rmBuildArea(forestID)==false) {
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
	
	
	columnID=rmCreateObjectDef("columns");
	rmAddObjectDefItem(columnID, "ruins", rmRandInt(0,1), 1.0);
	rmAddObjectDefItem(columnID, "columns broken", rmRandInt(2,5), 4.0);
	rmAddObjectDefItem(columnID, "columns", rmRandFloat(0,2), 4.0);
	rmSetObjectDefMinDistance(columnID, 50.0);
	rmSetObjectDefMaxDistance(columnID, 200.0+(10*cNumberNonGaiaPlayers));
	rmAddAreaConstraint(columnID, shortWaterConstraint);
	rmAddAreaConstraint(columnID, avoidSettlement);
	rmAddAreaConstraint(columnID, farAvoidStartTC);
	rmPlaceObjectDefPerPlayer(columnID, false, rmRandInt(3,4));
	
	rmSetStatusText("",1.0);
}
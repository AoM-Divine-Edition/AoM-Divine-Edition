/*	Map Name: Anatolia.xs
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
	if(cMapSize == 1){
		playerTiles = 10400;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 20800;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmSetSeaType("Red sea");
	rmTerrainInitialize("SandA");
	rmSetLightingSet("anatolia");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest = rmDefineClass("forest");
	int classPlayer = rmDefineClass("player");
	int classcliff = rmDefineClass("cliff");
	int classpatch = rmDefineClass("patch");
	int classCenter = rmDefineClass("center");
	int classocean = rmDefineClass("ocean");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classBackTC = rmDefineClass("Back settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
	int goldCenterConstraint = -1;
	if(cNumberNonGaiaPlayers == 2){
		goldCenterConstraint = rmCreateBoxConstraint("gold stay in center", 0.35, 0.2, 0.65, 0.8);
	} else {
		goldCenterConstraint = rmCreateBoxConstraint("gold stay in center", 0.315, 0.2, 0.685, 0.8);
	}
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15);
	int shortCliffConstraint=rmCreateClassDistanceConstraint("elev v gorge", rmClassID("cliff"), 10.0);
	int smallOceanConstraint=rmCreateClassDistanceConstraint("terrain vs ocean", rmClassID("ocean"), 10.0);
	int patchConstraint=rmCreateClassDistanceConstraint("patch v patch", rmClassID("patch"), 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	//No Map Outline for Anatolia.
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers < 3) {
		if(cMapSize == 2) {
			rmPlacePlayersLine(0.22, 0.5, 0.78, 0.5);
		} else {
			rmPlacePlayersLine(0.12, 0.5, 0.88, 0.5);
		}
	} else if(cNumberTeams < 3){
		if(cMapSize == 2) {
			rmSetPlacementTeam(0);
			rmPlacePlayersLine(0.22, 0.20, 0.22, 0.80, 20, 10); /* x z x2 z2 */
			rmSetPlacementTeam(1);
			rmPlacePlayersLine(0.78, 0.20, 0.78, 0.80, 20, 10);

		} else {
			rmSetPlacementTeam(0);
			rmPlacePlayersLine(0.15, 0.20, 0.15, 0.80, 20, 10); /* x z x2 z2 */
			rmSetPlacementTeam(1);
			rmPlacePlayersLine(0.85, 0.20, 0.85, 0.80, 20, 10);
		}
	} else {
		rmPlacePlayersCircular(0.3, 0.35, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();

	int failCount=0;
	float playerFraction=rmAreaTilesToFraction(1600);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaCoherence(id, 0.0);
		rmAddAreaConstraint(id, edgeConstraint);
		rmSetAreaTerrainType(id, "SnowB");
		rmAddAreaTerrainLayer(id, "snowSand25", 6, 10);
		rmAddAreaTerrainLayer(id, "snowSand50", 2, 6);
		rmAddAreaTerrainLayer(id, "snowSand75", 0, 2);
		rmSetAreaLocPlayer(id, i);
	}
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int northOceanID=rmCreateArea("north ocean");
	rmSetAreaSize(northOceanID, 0.11, 0.11);
	rmSetAreaWaterType(northOceanID, "Red Sea");
	rmSetAreaWarnFailure(northOceanID, false);
	rmSetAreaLocation(northOceanID, 0.5, 0.99);
	rmAddAreaInfluenceSegment(northOceanID, 0, 1, 1, 1);
	rmSetAreaCoherence(northOceanID, 0.25);
	rmSetAreaSmoothDistance(northOceanID, 12);
	rmSetAreaHeightBlend(northOceanID, 1);
	rmAddAreaToClass(northOceanID, classocean);
	rmBuildArea(northOceanID);
	
	int southOceanID=rmCreateArea("south ocean");
	rmSetAreaSize(southOceanID, 0.11, 0.11);
	rmSetAreaWaterType(southOceanID, "Red Sea");
	rmSetAreaWarnFailure(southOceanID, false);
	rmSetAreaLocation(southOceanID, 0.5, 0.01);
	rmAddAreaInfluenceSegment(southOceanID, 0, 0, 1, 0);
	rmSetAreaCoherence(southOceanID, 0.25);
	rmSetAreaSmoothDistance(southOceanID, 12);
	rmSetAreaHeightBlend(southOceanID, 1);
	rmAddAreaToClass(southOceanID, classocean);
	rmBuildArea(southOceanID);
	
	rmBuildAllAreas();
	
	int goldArea=rmCreateArea("here is gold");
	rmSetAreaSize(goldArea, 1.0, 1.0);
	rmSetAreaWarnFailure(goldArea, false);
	rmAddAreaToClass(goldArea, classCenter);
	rmAddAreaConstraint(goldArea, goldCenterConstraint);
	rmBuildArea(goldArea);
	
	int patch = 0;
	int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", patch, 4.0);
	for(i=1; <cNumberPlayers*5*mapSizeMultiplier){
		patch=rmCreateArea("patch"+i);
		rmSetAreaSize(patch, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		rmSetAreaWarnFailure(patch, false);
		rmSetAreaTerrainType(patch, "SnowB");
		rmAddAreaTerrainLayer(patch, "snowSand25", 2, 3);
		rmAddAreaTerrainLayer(patch, "snowSand50", 1, 2);
		rmAddAreaTerrainLayer(patch, "snowSand75", 0, 1);
		rmSetAreaMinBlobs(patch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(patch, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(patch, 16.0);
		rmSetAreaMaxBlobDistance(patch, 40.0*mapSizeMultiplier);
		rmAddAreaToClass(patch, classpatch);
		rmAddAreaConstraint(patch, patchConstraint);
		rmAddAreaConstraint(patch, playerConstraint);
		rmAddAreaConstraint(patch, smallOceanConstraint);
		rmSetAreaCoherence(patch, 0.3);
		rmSetAreaSmoothDistance(patch, 8);
		
		if(rmBuildArea(patch)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
		
		int snowRockID=rmCreateObjectDef("snowRock"+i);
		rmAddObjectDefItem(snowRockID, "rock granite sprite", rmRandFloat(0,3), 2.0);
		rmSetObjectDefMinDistance(snowRockID, 0.0);
		rmSetObjectDefMaxDistance(snowRockID, 0.0);
		rmAddObjectDefConstraint(snowRockID, stayInPatch);
		rmPlaceObjectDefInArea(snowRockID, 0, rmAreaID("patch"+i), 1);
	}
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier) {
		int patch2=rmCreateArea("2nd patch"+i);
		rmSetAreaSize(patch2, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaWarnFailure(patch2, false);
		rmSetAreaTerrainType(patch2, "DirtA");
		rmSetAreaMinBlobs(patch2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(patch2, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(patch2, 16.0);
		rmSetAreaMaxBlobDistance(patch2, 40.0*mapSizeMultiplier);
		rmAddAreaConstraint(patch2, playerConstraint);
		rmAddAreaToClass(patch2, classpatch);
		rmAddAreaConstraint(patch2, patchConstraint);
		rmAddAreaConstraint(patch2, smallOceanConstraint);
		rmSetAreaCoherence(patch2, 0.4);
		rmSetAreaSmoothDistance(patch2, 8);
		
		if(rmBuildArea(patch2)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v gorge", rmClassID("cliff"), 30.0);
	int oceanConstraint=rmCreateClassDistanceConstraint("gorge vs ocean", rmClassID("ocean"), 25.0);
	
	int gorgeID=rmCreateArea("gorge 1");
	rmSetAreaWarnFailure(gorgeID, false);
	rmSetAreaSize(gorgeID, rmAreaTilesToFraction(2000), rmAreaTilesToFraction(2000));
	rmSetAreaCliffType(gorgeID, "Egyptian");
	rmAddAreaConstraint(gorgeID, cliffConstraint);
	rmAddAreaConstraint(gorgeID, oceanConstraint);
	rmAddAreaToClass(gorgeID, classcliff);
	rmSetAreaMinBlobs(gorgeID, 4);
	rmSetAreaMaxBlobs(gorgeID, 6);
	rmSetAreaLocation(gorgeID, 0.4, 0.5);
	rmAddAreaInfluenceSegment(gorgeID, 0.4, 0.25, 0.4, 0.75);
	rmSetAreaCliffEdge(gorgeID, 1, 0.0001, 0.0001, 0.0001, 0);
	rmSetAreaCliffPainting(gorgeID, false, false, false, 0);
	rmSetAreaCliffHeight(gorgeID, 7, 1.0, 1.0);
	rmSetAreaMinBlobDistance(gorgeID, 20.0);
	rmSetAreaMaxBlobDistance(gorgeID, 20.0);
	rmSetAreaCoherence(gorgeID, 0.0);
	rmSetAreaSmoothDistance(gorgeID, 10);
	rmSetAreaCliffHeight(gorgeID, -5, 1.0, 1.0);
	rmSetAreaHeightBlend(gorgeID, 2);
	if(cNumberTeams < 3) {
		rmBuildArea(gorgeID);
	}
	
	int gorge2ID=rmCreateArea("gorge 2");
	rmSetAreaWarnFailure(gorge2ID, false);
	rmSetAreaSize(gorge2ID, rmAreaTilesToFraction(2000), rmAreaTilesToFraction(2000));
	rmSetAreaCliffType(gorge2ID, "Egyptian");
	rmAddAreaConstraint(gorge2ID, cliffConstraint);
	rmAddAreaConstraint(gorge2ID, oceanConstraint);
	rmAddAreaToClass(gorge2ID, classcliff);
	rmSetAreaMinBlobs(gorge2ID, 4);
	rmSetAreaMaxBlobs(gorge2ID, 6);
	rmSetAreaLocation(gorge2ID, 0.6, 0.5);
	rmAddAreaInfluenceSegment(gorge2ID, 0.6, 0.25, 0.6, 0.75);
	rmSetAreaCliffEdge(gorge2ID, 1, 0.0001, 0.0001, 0.0001, 0);
	rmSetAreaCliffPainting(gorge2ID, false, false, false, 0);
	rmSetAreaCliffHeight(gorge2ID, 7, 1.0, 1.0);
	rmSetAreaMinBlobDistance(gorge2ID, 20.0);
	rmSetAreaMaxBlobDistance(gorge2ID, 20.0);
	rmSetAreaCoherence(gorge2ID, 0.0);
	rmSetAreaSmoothDistance(gorge2ID, 10);
	rmSetAreaCliffHeight(gorge2ID, -5, 1.0, 1.0);
	rmSetAreaHeightBlend(gorge2ID, 2);
	if(cNumberTeams < 3) {
		rmBuildArea(gorge2ID);
	}
	
	for(i=0; <8) {
		int cliffID=rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(700));
		rmSetAreaCliffType(cliffID, "Egyptian");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, playerConstraint);
		rmAddAreaConstraint(cliffID, oceanConstraint);
		rmAddAreaToClass(cliffID, classcliff);
		rmSetAreaMinBlobs(cliffID, 2);
		rmSetAreaMaxBlobs(cliffID, 5);
		rmSetAreaCliffEdge(cliffID, 1, 0.0001, 0.0001, 0.0001, 0);
		rmSetAreaCliffPainting(cliffID, false, false, false, 0);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaMinBlobDistance(cliffID, 5.0);
		rmSetAreaMaxBlobDistance(cliffID, 10.0);
		rmSetAreaCoherence(cliffID, 0.0);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, -5, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		rmBuildArea(cliffID);
	}
	
	int numTries=40*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, shortCliffConstraint);
		rmAddAreaConstraint(elevID, oceanConstraint);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SnowSand50");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
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
	
	numTries=10*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, shortCliffConstraint);
		rmAddAreaConstraint(elevID, oceanConstraint);
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
	
	int avoidGold = -1;
	int goldNum = rmRandInt(2, 3);
	if(goldNum == 2){
		avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 50.0);
	} else {
		avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 40.0);
	}
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 60.0);
	int medAvoidGold=rmCreateTypeDistanceConstraint("med avoid gold", "gold", 20.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar=rmCreateTypeDistanceConstraint("stuffs vs food sources", "food", 20.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("tree avoid everything", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("tree avoid dat gold yo", "gold", 3.0);
	rmSetStatusText("",0.46);
	
	
	/* *********************************************** */
	/* Section 8 Fair Location Placement & Starting TC */
	/* *********************************************** */
	
	int startingGoldFairLocID = -1;
	startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 23, 0, 15);
	startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 20, 23, 0, 15);
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
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC", "AbstractSettlement", 50.0);
	int TCfarAvoidSettlement = -1;
	if(cNumberNonGaiaPlayers == 2){
		TCfarAvoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	} else {
		TCfarAvoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 70.0);
	}
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "land", false, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	int TCplayer = rmCreateClassDistanceConstraint("TCs avoid Players", classStartingSettlement, 60.0);
	int TCarea = rmCreateClassDistanceConstraint("TCs avoid TC areas", classBackTC, 60.0);
	
	int farID = -1;
	int closeID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			if(cMapSize < 2){
				id=rmAddFairLoc("Settlement", false, true, 50, 65, 50, 20, true);
			} else {
				id=rmAddFairLoc("Settlement", true, false, 60, 80, 20, 20);
			}
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "SnowB");
				rmAddAreaTerrainLayer(settleArea, "snowSand25", 4, 8);
				rmAddAreaTerrainLayer(settleArea, "snowSand50", 2, 4);
				rmAddAreaTerrainLayer(settleArea, "snowSand75", 0, 2);
				rmBuildArea(settleArea);
			} else {
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt);
				}
				//rmEchoError("How do these things even fail?");
				//chat(true, "<color=1,0,0>Function rmPlaceFairLocs() failed!", true, -1, true);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			if(cMapSize < 2){
				id=rmAddFairLoc("Settlement", true, false, 70, 80, 50, 20);
			} else {
				//Half map minus starting position.
				if(cNumberNonGaiaPlayers == 2){
					id=rmAddFairLoc("Settlement", true, false, 70, rmXFractionToMeters(0.5 - 0.12), 50, 20);
				} else {
					id=rmAddFairLoc("Settlement", true, false, 70, rmXFractionToMeters(0.5 - 0.15), 50, 20);
				}
			}
			rmAddFairLocConstraint(id, TCfarAvoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			if(cNumberTeams == 2){
				rmAddFairLocConstraint(id, goldCenterConstraint);
			}
			rmAddFairLocConstraint(id, TCavoidWater);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				rmSetAreaTerrainType(settlementArea, "SnowB");
				rmAddAreaTerrainLayer(settlementArea, "snowSand25", 4, 8);
				rmAddAreaTerrainLayer(settlementArea, "snowSand50", 2, 4);
				rmAddAreaTerrainLayer(settlementArea, "snowSand75", 0, 2);
				rmBuildArea(settlementArea);
			} else {
				farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				if(cNumberTeams == 2){
					rmAddFairLocConstraint(id, goldCenterConstraint);
				}
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, attempt);
				}
				//rmEchoError("How do these things even fail?");
				//chat(true, "<color=1,0,0>Function rmPlaceFairLocs() failed!", true, -1, true);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		
		if(cNumberTeams == 2){
			int TCsafeLoc1 = rmCreateBoxConstraint("Team 1 safe TC loc", 0.0, 0.2, 0.325, 0.8);
			int TCsafeLoc2 = rmCreateBoxConstraint("Team 2 safe TC loc", 0.625, 0.2, 1.0, 0.8);
			int TCcloseAvoidSet = rmCreateTypeDistanceConstraint("TC close avoid TC", "AbstractSettlement", 60.0);
			int TCedgeConstraint=rmCreateBoxConstraint("TC edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
			
			for(p = 1; <= cNumberNonGaiaPlayers){
				id=rmCreateObjectDef("2plyrPlus close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmSetObjectDefMaxDistance(id, 60.0);
				rmAddObjectDefConstraint(id, TCavoidImpassableLand);
				rmAddObjectDefConstraint(id, TCedgeConstraint);
				rmAddObjectDefConstraint(id, TCcloseAvoidSet);
				if(rmGetPlayerTeam(p) == 0){
					rmAddObjectDefConstraint(id, TCsafeLoc1);
				} else {
					rmAddObjectDefConstraint(id, TCsafeLoc2);
				}
				for(attempt = 1; < 25-cNumberNonGaiaPlayers){
					rmPlaceObjectDefAtLoc(id, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(id) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(id, 60.0+5*attempt);
				}
			}
		
		} else {
			id=rmAddFairLoc("Settlement", false, true, 60, 70, 50, 20);
			rmAddFairLocConstraint(id, TCavoidWater);
			rmAddFairLocConstraint(id, TCplayer);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, oceanConstraint);
			
			if(rmPlaceFairLocs()){
				id=rmCreateObjectDef("2plyrPlus close settlement");
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				for(i=1; <cNumberPlayers){
					int settlementArea2Pclose  = rmCreateArea("close settlement_area_"+i);
					rmSetAreaLocation(settlementArea2Pclose, rmFairLocXFraction(i, 0), rmFairLocZFraction(i, 0));
					rmSetAreaSize(settlementArea2Pclose, 0.01, 0.01);
					rmSetAreaBaseHeight(settlementArea2Pclose, 0.0);
					rmSetAreaHeightBlend(settlementArea2Pclose, 2);
					rmSetAreaTerrainType(settlementArea2Pclose, "SnowB");
					rmAddAreaTerrainLayer(settlementArea2Pclose, "snowSand25", 4, 8);
					rmAddAreaTerrainLayer(settlementArea2Pclose, "snowSand50", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2Pclose, "snowSand75", 0, 2);
					rmAddAreaToClass(settlementArea2Pclose, classBackTC);
					rmAddAreaConstraint(settlementArea2Pclose, TCavoidWater);
					rmAddAreaConstraint(settlementArea2Pclose, TCarea);
					rmAddAreaConstraint(settlementArea2Pclose, oceanConstraint);
					rmBuildArea(settlementArea2Pclose);
					rmPlaceObjectDefAtAreaLoc(id, 0, settlementArea2Pclose, 1);
				}
			} else {
				
			}
		}
		rmResetFairLocs();
		
		id=rmAddFairLoc("Settlement", true, false, 95, rmXFractionToMeters(0.5 - 0.12), 80, 100);
		if(cNumberTeams == 2){
			rmAddFairLocConstraint(id, goldCenterConstraint);
		}
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidWater);
		rmAddFairLocConstraint(id, oceanConstraint);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("2plyrPlus settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					int settlementArea2P = rmCreateArea("settlement_area_"+i+j);
					rmSetAreaLocation(settlementArea, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j));
					rmSetAreaSize(settlementArea2P, 0.01, 0.01);
					rmSetAreaBaseHeight(settlementArea2P, 0.0);
					rmSetAreaHeightBlend(settlementArea2P, 2);
					rmSetAreaTerrainType(settlementArea2P, "SnowB");
					rmAddAreaTerrainLayer(settlementArea2P, "snowSand25", 4, 8);
					rmAddAreaTerrainLayer(settlementArea2P, "snowSand50", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2P, "snowSand75", 0, 2);
					rmAddAreaConstraint(settlementArea2P, TCavoidWater);
					rmAddAreaConstraint(settlementArea2P, oceanConstraint);
					rmBuildArea(settlementArea2P);
					rmPlaceObjectDefAtLoc(id, 0, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		} else {
			farID=rmCreateObjectDef("far 2p+ settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmSetObjectDefMinDistance(farID, 50.0);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			if(cNumberTeams == 2){
				rmAddFairLocConstraint(id, goldCenterConstraint);
				rmSetObjectDefMinDistance(farID, 50.0+5*cNumberNonGaiaPlayers);
				rmSetObjectDefMaxDistance(farID, 60.0+10*cNumberNonGaiaPlayers);
			}
			for(attempt = 1; < 21){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				if(cNumberTeams == 2){
					rmSetObjectDefMaxDistance(farID, 60+10*cNumberNonGaiaPlayers+10*attempt);
				} else {
					rmSetObjectDefMaxDistance(farID, 60+10*attempt);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		rmResetFairLocs();
		id=rmAddFairLoc("Settlement", false, true, rmXFractionToMeters(0.35), rmXFractionToMeters(0.4), 80, 16);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		id=rmAddFairLoc("Settlement", true, false, rmXFractionToMeters(0.38), rmXFractionToMeters(0.4), 80, 16);
		rmAddFairLocConstraint(id, TCavoidWater);
		rmAddFairLocConstraint(id, TCfarAvoidSettlement);
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				for(FL = 0; < 2){
					id=rmCreateObjectDef("Giant settlement_"+p+"_"+FL);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.01, 0.01);
					rmSetAreaTerrainType(settlementArea2, "SnowB");
					rmAddAreaTerrainLayer(settlementArea2, "snowSand25", 4, 8);
					rmAddAreaTerrainLayer(settlementArea2, "snowSand50", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2, "snowSand75", 0, 2);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			farID=rmCreateObjectDef("far giant settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmSetObjectDefMinDistance(farID, 10*cNumberNonGaiaPlayers);
			rmSetObjectDefMaxDistance(farID, 100.0+10*cNumberNonGaiaPlayers);
			rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			if(cNumberTeams == 2){
				rmAddFairLocConstraint(id, goldCenterConstraint);
			}
			for(attempt = 1; < 21){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 100.0+10*cNumberNonGaiaPlayers+10*attempt);
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);
	
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "boar", rmRandInt(3,4), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 27.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 30.0);
	rmAddObjectDefConstraint(startingHuntableID, shortAvoidGold);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int GoatNum=rmRandInt(2, 5);
	int closegoatsID=rmCreateObjectDef("close goats");
	rmAddObjectDefItem(closegoatsID, "goat", GoatNum, 2.0);
	rmSetObjectDefMinDistance(closegoatsID, 25.0);
	rmSetObjectDefMaxDistance(closegoatsID, 30.0);
	rmAddObjectDefConstraint(closegoatsID, avoidFood);
	rmAddObjectDefConstraint(closegoatsID, getOffTheTC);
	rmAddObjectDefConstraint(closegoatsID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(closegoatsID, true);
	
	int numChicken = 0;
	int numBerry = 0;
	float berryChance = rmRandFloat(0,1);
	if(berryChance < 0.25){
		numChicken = 7;
		numBerry = 5;
	} else if(berryChance < 0.75) {
		numChicken = 9;
		numBerry = 7;
	} else {
		numChicken = 12;
		numBerry = 9;
	}
	
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", numChicken, 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 22.0);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmAddObjectDefConstraint(startingChickenID, shortAvoidGold);
	
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", numBerry, 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 20.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, getOffTheTC);
	rmAddObjectDefConstraint(startingBerryID, avoidFood);
	rmAddObjectDefConstraint(startingBerryID, shortAvoidGold);
	for(i=1; <cNumberPlayers) {
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmPlaceObjectDefAtLoc(startingChickenID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else {
			rmPlaceObjectDefAtLoc(startingBerryID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
		}
	}
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(5, 8));
	
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
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			//Randomize every time
			if(rmRandFloat(0.0, 1.0)<0.25) {
				rmSetAreaForestType(playerStartingForestID, "mixed pine forest");
			} else {
				rmSetAreaForestType(playerStartingForestID, "pine forest");
			}
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
	
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 24.0);
	int forestTower=rmCreateClassDistanceConstraint("tower v forest", classForest, 4.0);
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 24.0);
	rmSetObjectDefMaxDistance(startingTowerID, 27.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, forestTower);
	rmAddObjectDefConstraint(startingTowerID, shortAvoidGold);
	int placement = 1;
	float increment = 1.0;
	for(p = 1; <= cNumberNonGaiaPlayers){
		placement = 1;
		increment = 27;
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
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 80.0);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGoatsID, medAvoidGold);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false, rmRandInt(1, 2));
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int gold1Constraint = -1;
	int gold2Constraint = -1;
	int gold3Constraint = -1;
	if(goldNum == 2){
		gold1Constraint = rmCreateBoxConstraint("gold1 stay in center", 0.35, 0.2, 0.65, 0.45);
		gold2Constraint = rmCreateBoxConstraint("gold2 stay in center", 0.35, 0.55, 0.65, 0.8);
	} else {
		gold1Constraint = rmCreateBoxConstraint("gold1 stay in center", 0.345, 0.2, 0.655, 0.35);
		gold2Constraint = rmCreateBoxConstraint("gold2 stay in center", 0.345, 0.4, 0.655, 0.55);
		gold3Constraint = rmCreateBoxConstraint("gold3 stay in center", 0.345, 0.6, 0.655, 0.8);
	}
	
	int gold1ID=rmCreateObjectDef("gold 1");
	rmAddObjectDefItem(gold1ID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(gold1ID, 0.0);
	rmSetObjectDefMaxDistance(gold1ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(gold1ID, gold1Constraint);
	rmAddObjectDefConstraint(gold1ID, avoidGold);
	rmAddObjectDefConstraint(gold1ID, edgeConstraint);
	rmAddObjectDefConstraint(gold1ID, avoidImpassableLand);
	rmAddObjectDefConstraint(gold1ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(gold1ID, farStartingSettleConstraint);
	
	int gold2ID=rmCreateObjectDef("gold 2");
	rmAddObjectDefItem(gold2ID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(gold2ID, 0.0);
	rmSetObjectDefMaxDistance(gold2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(gold2ID, gold2Constraint);
	rmAddObjectDefConstraint(gold2ID, avoidGold);
	rmAddObjectDefConstraint(gold2ID, edgeConstraint);
	rmAddObjectDefConstraint(gold2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(gold2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(gold2ID, farStartingSettleConstraint);
	
	int gold3ID=rmCreateObjectDef("gold 3");
	rmAddObjectDefItem(gold3ID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(gold3ID, 0.0);
	rmSetObjectDefMaxDistance(gold3ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(gold3ID, gold3Constraint);
	rmAddObjectDefConstraint(gold3ID, avoidGold);
	rmAddObjectDefConstraint(gold3ID, edgeConstraint);
	rmAddObjectDefConstraint(gold3ID, avoidImpassableLand);
	rmAddObjectDefConstraint(gold3ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(gold3ID, farStartingSettleConstraint);
	
	int attempts = 0;
	while((rmGetNumberUnitsPlaced(gold1ID) < cNumberNonGaiaPlayers) && (attempts < 15*cNumberNonGaiaPlayers)){
		rmPlaceObjectDefAtAreaLoc(gold1ID, 0, goldArea, 1);
		attempts++;
	} if(attempts >= 5*cNumberNonGaiaPlayers){
		rmEchoError("Only "+rmGetNumberUnitsPlaced(gold1ID)+"/"+cNumberNonGaiaPlayers+" gold placed.");
	}
	attempts = 0;
	while((rmGetNumberUnitsPlaced(gold2ID) < cNumberNonGaiaPlayers) && (attempts < 15*cNumberNonGaiaPlayers)){
		rmPlaceObjectDefAtAreaLoc(gold2ID, 0, goldArea, 1);
		attempts++;
	} if(attempts >= 5*cNumberNonGaiaPlayers){
		rmEchoError("Only "+rmGetNumberUnitsPlaced(gold2ID)+"/"+cNumberNonGaiaPlayers+" gold placed.");
	}
	attempts = 0;
	if(goldNum == 3){
		while((rmGetNumberUnitsPlaced(gold3ID) < cNumberNonGaiaPlayers) && (attempts < 15*cNumberNonGaiaPlayers)){
			rmPlaceObjectDefAtAreaLoc(gold3ID, 0, goldArea, 1);
			attempts++;
		} if(attempts >= 5*cNumberNonGaiaPlayers){
			rmEchoError("Only "+rmGetNumberUnitsPlaced(gold3ID)+"/"+cNumberNonGaiaPlayers+" gold placed.");
		}
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "deer", 5, 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "deer", 6, 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 80.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	int bonusHuntable2ID=rmCreateObjectDef("bonus huntable 2");
	rmAddObjectDefItem(bonusHuntable2ID, "deer", 5, 4.0);
	rmSetObjectDefMinDistance(bonusHuntable2ID, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntable2ID, 90.0+cNumberNonGaiaPlayers);
	rmAddObjectDefConstraint(bonusHuntable2ID, rmCreateTypeDistanceConstraint("BH2 vs food sources", "food", 35.0));
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntable2ID, false);
	
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 70.0);
	rmSetObjectDefMaxDistance(farGoatsID, 90.0);
	rmAddObjectDefConstraint(farGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(farGoatsID, medAvoidGold);
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoatsID, edgeConstraint);
	rmPlaceObjectDefPerPlayer(farGoatsID, false, rmRandInt(1, 2));
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 90.0);
	rmSetObjectDefMaxDistance(farBerriesID, 90.0 + (5*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, avoidFoodFar);
	rmAddObjectDefConstraint(farBerriesID, medAvoidGold);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, edgeConstraint);
	rmPlaceObjectDefPerPlayer(farBerriesID, false);

	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.75) {
		rmAddObjectDefItem(farPredatorID, "wolf", 1, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 30.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, rmCreateBoxConstraint("preds stay in center", 0.3, 0.2, 0.7, 0.8));
	rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 128", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 128", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 80.0);
	rmSetObjectDefMaxDistance(relicID, 110.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, medAvoidGold);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 24.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 3, 8.0 + (3*cMapSize));
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, 0.0);
	
	if(cNumberNonGaiaPlayers == 2){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(fishID, 0, 6*cNumberNonGaiaPlayers, 0.985, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 6*cNumberNonGaiaPlayers, 0.015, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(fishID, 0, 3*cNumberNonGaiaPlayers, 0.985, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 3*cNumberNonGaiaPlayers, 0.015, 0.0, 1.0, 0.01);
		}
	} else if(cNumberNonGaiaPlayers <= 4){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.95, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.05, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.965, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.035, 0.0, 1.0, 0.01);
		}
	} else if(cNumberNonGaiaPlayers <= 6){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.9525, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.0475, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.955, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.045, 0.0, 1.0, 0.01);
		}
	} else if(cNumberNonGaiaPlayers == 8){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.9475, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.0525, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.95, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.05, 0.0, 1.0, 0.01);
		}
	} else {
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.945, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 5+2*cNumberNonGaiaPlayers, 0.055, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.945, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(fishID, 0, 1+2*cNumberNonGaiaPlayers, 0.055, 0.0, 1.0, 0.01);
		}
	}
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */
	
	int avoidCenter = rmCreateClassDistanceConstraint("avoid center", classCenter, 20.0);

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantGoldID, avoidGold);
		rmAddObjectDefConstraint(giantGoldID, goldCenterConstraint);
		rmAddObjectDefConstraint(giantGoldID, edgeConstraint);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 1);
		
		int giantGold2ID=rmCreateObjectDef("giant gold2");
		rmAddObjectDefItem(giantGold2ID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGold2ID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantGold2ID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantGold2ID, avoidCenter);
		rmAddObjectDefConstraint(giantGold2ID, avoidGold);
		rmAddObjectDefConstraint(giantGold2ID, edgeConstraint);
		rmAddObjectDefConstraint(giantGold2ID, shortAvoidSettlement);
		rmPlaceObjectDefPerPlayer(giantGold2ID, false, 2);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(8,10), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, edgeConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int forestNativeSettleConstraint=rmCreateTypeDistanceConstraint("forest Native settle", "AbstractSettlement", 10.0);
	int forestCount=8*cNumberNonGaiaPlayers*mapSizeMultiplier;
	
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(120));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(180), rmAreaTilesToFraction(220));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0.0, 1.0)<0.25) {
			rmSetAreaForestType(forestID, "mixed pine forest");
		} else {
			rmSetAreaForestType(forestID, "pine forest");
		}
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestNativeSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, shortCliffConstraint);
		rmAddAreaConstraint(forestID, smallOceanConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 3);
		rmSetAreaMinBlobDistance(forestID, 10.0);
		rmSetAreaMaxBlobDistance(forestID, 10.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmBuildArea(forestID)==false) {
			// Stop trying once we fail 7 times in a row.
			failCount++;
			if(failCount==7) {
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
	rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock sandstone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, patchConstraint);
	rmAddObjectDefConstraint(rockID2, playerConstraint);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
	
	int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
	int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
	int kelpID=rmCreateObjectDef("seaweed");
	rmAddObjectDefItem(kelpID, "seaweed", 4, 2.0);
	rmSetObjectDefMinDistance(kelpID, 0.0);
	rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(kelpID, avoidAll);
	rmAddObjectDefConstraint(kelpID, nearshore);
	rmAddObjectDefConstraint(kelpID, farshore);
	rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	int kelp2ID=rmCreateObjectDef("seaweed 2");
	rmAddObjectDefItem(kelp2ID, "seaweed", 1, 0.0);
	rmSetObjectDefMinDistance(kelp2ID, 0.0);
	rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(kelp2ID, avoidAll);
	rmAddObjectDefConstraint(kelp2ID, nearshore);
	rmAddObjectDefConstraint(kelp2ID, farshore);
	rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
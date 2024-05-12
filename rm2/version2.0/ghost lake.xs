/*	Map Name: Ghost Lake.xs
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
	rmSetSeaLevel(0.0);
	rmTerrainInitialize("SnowB");
	rmSetLightingSet("ghost lake");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classPlayerCore = rmDefineClass("player core");
	int classForest = rmDefineClass("forest");
	rmDefineClass("center");
	int classCliff = rmDefineClass("cliff");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 5.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 5.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	if(cNumberNonGaiaPlayers <9){
		rmSetTeamSpacingModifier(0.70);
	} else {
		rmSetTeamSpacingModifier(0.90);
	}
	rmPlacePlayersCircular(0.35, 0.4, rmDegreesToRadians(5.0));
	rmRecordPlayerLocations();
	
	// Dumb thing to just block out player areas since placement sucks right now.
	// This area doesn't paint down anything, it just exists for blocking out the centre sea.
	for(i=1; <cNumberPlayers){
		// Create the area.
		int id=rmCreateArea("Player core"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(110), rmAreaTilesToFraction(110));
		rmAddAreaToClass(id, classPlayerCore);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaLocPlayer(id, i);
		rmBuildArea(id);
	}
	
	int centerID=rmCreateArea("center");
	int maxBlobSpacing=size/5;
	int minBlobSpacing=size/10;
	rmSetAreaSize(centerID, 0.13, 0.17);
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmSetAreaTerrainType(centerID, "IceC");
	rmAddAreaTerrainLayer(centerID, "IceB", 6, 10);
	rmAddAreaTerrainLayer(centerID, "IceA", 0, 6);
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmSetAreaBaseHeight(centerID, -1.0);
	rmSetAreaSmoothDistance(centerID, 50);
	rmSetAreaCoherence(centerID, 0.45);
	if(cNumberNonGaiaPlayers > 2){
		rmSetAreaCoherence(centerID, 0.1);
	}
	rmSetAreaHeightBlend(centerID, 2);
	rmAddAreaConstraint(centerID, rmCreateClassDistanceConstraint("center v player", classPlayerCore, 40.0));
	rmBuildArea(centerID);
	
	int failCount=0;
	for(i=1; <10*mapSizeMultiplier){
		int icePatch=rmCreateArea("more ice terrain"+i, centerID);
		rmSetAreaSize(icePatch, 0.005, 0.007);
		rmSetAreaTerrainType(icePatch, "IceA");
		rmAddAreaTerrainLayer(icePatch, "IceB", 0, 3);
		rmSetAreaCoherence(icePatch, 0.0);
		if(rmBuildArea(icePatch)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	int wideCenterConstraint=rmCreateClassDistanceConstraint("wide avoid center", rmClassID("center"), 20.0);
	float playerFraction=rmAreaTilesToFraction(2000);
	for(i=1; <cNumberPlayers) {
		id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 2);
		rmSetAreaMaxBlobs(id, 3);
		rmSetAreaMinBlobDistance(id, 20.0);
		rmSetAreaMaxBlobDistance(id, 20.0);
		rmSetAreaCoherence(id, 0.4);
		rmAddAreaConstraint(id, edgeConstraint);
		rmAddAreaConstraint(id, wideCenterConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SnowGrass50");
		rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 8);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int cliffNumber = 0;
	if(cNumberNonGaiaPlayers < 4){
		cliffNumber = 4;
	} else if(cNumberNonGaiaPlayers < 9){
		cliffNumber = 6;
	} else {
		cliffNumber = 9;
	}
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10);
	
	for(i=1; <cNumberPlayers*10){
		int patchID=rmCreateArea("patch"+i);
		rmSetAreaWarnFailure(patchID, false);
		rmSetAreaSize(patchID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(200));
		rmSetAreaTerrainType(patchID, "SnowGrass50");
		rmAddAreaTerrainLayer(patchID, "SnowGrass25", 2, 5);
		rmAddAreaTerrainLayer(patchID, "SnowB", 0, 2);
		rmSetAreaMinBlobs(patchID, 1);
		rmSetAreaMaxBlobs(patchID, 5);
		rmSetAreaMinBlobDistance(patchID, 16.0);
		rmSetAreaMaxBlobDistance(patchID, 40.0);
		rmSetAreaCoherence(patchID, 0.4);
		rmAddAreaConstraint(patchID, centerConstraint);
		rmAddAreaConstraint(patchID, playerConstraint);
		rmAddAreaConstraint(patchID, shortAvoidImpassableLand);
		if (rmBuildArea(patchID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	
	for(i=1; <cNumberPlayers*10){
		int patch2ID=rmCreateArea("patch 2 "+i);
		rmSetAreaWarnFailure(patch2ID, false);
		rmSetAreaSize(patch2ID, rmAreaTilesToFraction(10), rmAreaTilesToFraction(30));
		if(rmRandFloat(0,1) < 0.5)
		rmSetAreaTerrainType(patch2ID, "SnowA");
		else
		rmSetAreaTerrainType(patch2ID, "SnowSand25");
		rmSetAreaMinBlobs(patch2ID, 1);
		rmSetAreaMaxBlobs(patch2ID, 5);
		rmSetAreaMinBlobDistance(patch2ID, 16.0);
		rmSetAreaMaxBlobDistance(patch2ID, 40.0);
		rmSetAreaCoherence(patch2ID, 0.4);
		rmAddAreaConstraint(patch2ID, centerConstraint);
		rmAddAreaConstraint(patch2ID, playerConstraint);
		rmAddAreaConstraint(patch2ID, shortAvoidImpassableLand);
		if (rmBuildArea(patch2ID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int numTries=40*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries){
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, centerConstraint);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SnowGrass25");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	numTries=10*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries){
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, centerConstraint);
		if(rmBuildArea(elevID)==false){
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int cliffCenterConstraint=rmCreateClassDistanceConstraint("cliff avoid center", rmClassID("center"), 20.0);
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0);
	
	for(i=0; <cliffNumber){
		int cliffID=rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure(cliffID, false);
		if(cNumberNonGaiaPlayers < 4){
			rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
		} else {
			rmSetAreaSize(cliffID, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
		}
		rmSetAreaCliffType(cliffID, "Norse");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, cliffCenterConstraint);
		rmAddAreaConstraint(cliffID, playerConstraint);
		rmAddAreaToClass(cliffID, classCliff);
		rmSetAreaMinBlobs(cliffID, 2);
		rmSetAreaMaxBlobs(cliffID, 4);
		
		rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
		if(rmRandFloat(0,1) < 0.5){
			rmSetAreaCliffEdge(cliffID, 1, 0.85, 0.2, 1.0, 2);
		} else {
			rmSetAreaCliffEdge(cliffID, 2, 0.40, 0.2, 1.0, 0);
		}
		rmSetAreaCliffHeight(cliffID, rmRandInt(5,7), 1.0, 1.0);
		rmSetAreaMinBlobDistance(cliffID, 10.0);
		rmSetAreaMaxBlobDistance(cliffID, 10.0);
		rmSetAreaCoherence(cliffID, 0.0);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		rmBuildArea(cliffID);
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.

	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 20.0);
	int avoidFood = rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int avoidFoodFar = rmCreateTypeDistanceConstraint("avoid food sources", "food", 30.0);
	int huntAvoidHunt = rmCreateTypeDistanceConstraint("hunt Vs hunt", "huntable", 40.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int goldCliffConstraint=rmCreateClassDistanceConstraint("gold v cliff", rmClassID("cliff"), 6.0);
	int stragglerTreeAvoid = rmCreateTypeDistanceConstraint("straggler tree all", "all", 3.0);
	int stragglerTreeAvoidGold = rmCreateTypeDistanceConstraint("straggler tree gold", "gold", 6.0);
	
	rmSetStatusText("",0.46);
	
	/* *********************************************** */
	/* Section 8 Fair Location Placement & Starting TC */
	/* *********************************************** */
	
	bool gold1placement = false; // backwards
	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.5){
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 21, 0, 15);
		gold1placement = true;
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
	if(rmRandFloat(0,1) > 0.5){
		//Do the opposite of the first
		if(gold1placement){
			startingGoldFairLocID=rmAddFairLoc("Starting Gold", false, false, 20, 23, 0, 10);
		} else {
			startingGoldFairLocID=rmAddFairLoc("Starting Gold", true, false, 20, 23, 0, 10);
		}
		rmAddFairLocConstraint(startingGoldFairLocID, shortAvoidGold); //avoid gold
	
		if(rmPlaceFairLocs()){
			startingGoldID=rmCreateObjectDef("Starting Gold2");
			rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
		rmResetFairLocs();
	}
	rmResetFairLocs();
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, classStartingSettlement);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidPlayer = rmCreateClassDistanceConstraint("TC avoid start TC", classStartingSettlement, 55.0);
	int TCavoidCentre = rmCreateClassDistanceConstraint("TC avoid center", rmClassID("center"), 12.0);
	int TCavoidCliff = rmCreateClassDistanceConstraint("TC avoid cliff", rmClassID("cliff"), 16.0);
	
	int closeID = -1;
	int farID = -1;
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			id=rmAddFairLoc("Settlement", false, true, 60, 70, 50, 20, true);
			rmAddFairLocConstraint(id, TCavoidCliff);
			rmAddFairLocConstraint(id, TCavoidCentre);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidPlayer);
		
			id=rmAddFairLoc("Settlement", true, false,  80, 100, 100, 45);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidCentre);
			rmAddFairLocConstraint(id, TCavoidPlayer);
			rmAddFairLocConstraint(id, TCavoidCliff);
			
			int settlementArea = -1;
			
			if(rmPlaceFairLocs()) {
				for(f = 0; < 2){
					farID=rmCreateObjectDef("Unclaimed settlement"+p+f);
					rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
					rmAddObjectDefConstraint(farID, edgeConstraint);
					for(attempt = 1; < 25){
						rmPlaceObjectDefAtLoc(farID, p, rmFairLocXFraction(p, f), rmFairLocZFraction(p, f), 1);
						if(rmGetNumberUnitsPlaced(farID) > 0){
							break;
						}
						rmSetObjectDefMaxDistance(farID, 2*attempt);
					}
					settlementArea = rmCreateArea("settlement_area_"+p+f);
					rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, f), rmFairLocZFraction(p, f));
					rmSetAreaSize(settlementArea, 0.01, 0.01);
					rmSetAreaTerrainType(settlementArea, "SnowGrass50");
					rmAddAreaTerrainLayer(settlementArea, "SnowGrass25", 2, 5);
					rmAddAreaTerrainLayer(settlementArea, "SnowB", 0, 2);
					rmBuildArea(settlementArea);
				}
			} else {
				
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidCliff);
				rmAddObjectDefConstraint(closeID, TCavoidCentre);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidPlayer);
				for(attempt = 1; < 251){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, attempt);
				}
				
				farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidCentre);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, TCavoidPlayer);
				rmAddObjectDefConstraint(farID, TCavoidCliff);
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
		id=rmAddFairLoc("Settlement", false, true,  60, 80, 60, 20);
		rmAddFairLocConstraint(id, TCavoidCentre);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCavoidCliff);

		id=rmAddFairLoc("Settlement", true, false, 80, 100, 90, 20);
		rmAddFairLocConstraint(id, TCavoidCentre);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		rmAddFairLocConstraint(id, TCavoidCliff);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("far 2playerPlus settlement");
			rmAddObjectDefItem(id, "Settlement", 1, 0.0);
			for(i=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				}
			}
		}
	}
		
	if(cMapSize == 2){
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.33), rmXFractionToMeters(0.38), 90, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidCentre);
		rmAddFairLocConstraint(id, TCavoidPlayer);
		
		if(rmPlaceFairLocs()){
			id=rmCreateObjectDef("Giant settlement_"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			int settlementArea2 = rmCreateArea("other_settlement_area_"+p);
			rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
			rmSetAreaSize(settlementArea2, 0.01, 0.01);
			rmSetAreaTerrainType(settlementArea2, "SnowGrass50");
			rmAddAreaTerrainLayer(settlementArea2, "SnowGrass25", 2, 5);
			rmAddAreaTerrainLayer(settlementArea2, "SnowB", 0, 2);
			rmBuildArea(settlementArea2);
			rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
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
	rmAddObjectDefItem(startingHuntableID, "boar", rmRandInt(3,4), 2.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 28.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false, 1);
	
	int closegoatsID=rmCreateObjectDef("close goats");
	rmAddObjectDefItem(closegoatsID, "goat", rmRandInt(2,5), 2.0);
	rmSetObjectDefMinDistance(closegoatsID, 25.0);
	rmSetObjectDefMaxDistance(closegoatsID, 30.0);
	rmAddObjectDefConstraint(closegoatsID, avoidFood);
	rmAddObjectDefConstraint(closegoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(closegoatsID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(closegoatsID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(closegoatsID, true);

	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 22.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, avoidFood);
	rmAddObjectDefConstraint(startingBerryID, shortEdgeConstraint);
	rmAddObjectDefConstraint(startingBerryID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingBerryID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingBerryID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoid);
	rmAddObjectDefConstraint(stragglerTreeID, stragglerTreeAvoidGold);
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(5, 8));
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
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
			rmSetAreaForestType(playerStartingForestID, "snow pine forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
			rmAddAreaConstraint(playerStartingForestID, centerConstraint);
			rmAddAreaConstraint(playerStartingForestID, stragglerTreeAvoid);
			rmAddAreaConstraint(playerStartingForestID, stragglerTreeAvoidGold);
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
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
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
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, farAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, centerConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, goldCliffConstraint);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false, 1);
	
	int mediumHuntID=rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem(mediumHuntID, "caribou", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(mediumHuntID, 55.0);
	rmSetObjectDefMaxDistance(mediumHuntID, 60.0);
	rmAddObjectDefConstraint(mediumHuntID, avoidGold);
	rmAddObjectDefConstraint(mediumHuntID, avoidFoodFar);	
	rmAddObjectDefConstraint(mediumHuntID, huntAvoidHunt);	
	rmAddObjectDefConstraint(mediumHuntID, centerConstraint);
	rmAddObjectDefConstraint(mediumHuntID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumHuntID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumHuntID, false, 1);
	
	int mediumGoatsID=rmCreateObjectDef("medium goats");
	rmAddObjectDefItem(mediumGoatsID, "goat", rmRandInt(1,2), 3.0);
	rmSetObjectDefMinDistance(mediumGoatsID, 60.0);
	rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidGold);
	rmAddObjectDefConstraint(mediumGoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(mediumGoatsID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, centerConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortEdgeConstraint);
	rmAddObjectDefConstraint(mediumGoatsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoatsID, false, rmRandInt(1, 2));
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 90.0 + (10*cNumberNonGaiaPlayers-20));
	rmAddObjectDefConstraint(farGoldID, forestTower);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, centerConstraint);
	rmAddObjectDefConstraint(farGoldID, goldCliffConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 1);
	
	rmSetObjectDefMinDistance(farGoldID, 90.0);
	rmSetObjectDefMaxDistance(farGoldID, 100.0);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 1);
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(4,10), 3.0);
	rmSetObjectDefMinDistance(bonusHuntableID, 70.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 90.0);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, forestTower);
	rmAddObjectDefConstraint(bonusHuntableID, avoidFoodFar);
	rmAddObjectDefConstraint(bonusHuntableID, huntAvoidHunt);
	rmAddObjectDefConstraint(bonusHuntableID, shortEdgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, centerConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false, rmRandInt(1,2));
	
	int avoidGoats = rmCreateTypeDistanceConstraint("avoid Goatis", "herdable", 33.0+cNumberNonGaiaPlayers);
	
	int fargoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(fargoatsID, "goat", 2, 2.0);
	rmSetObjectDefMinDistance(fargoatsID, 90.0);
	rmSetObjectDefMaxDistance(fargoatsID, 110.0);
	rmAddObjectDefConstraint(fargoatsID, shortAvoidGold);
	rmAddObjectDefConstraint(fargoatsID, avoidFoodFar);
	rmAddObjectDefConstraint(fargoatsID, avoidGoats);
	rmAddObjectDefConstraint(fargoatsID, forestTower);
	rmAddObjectDefConstraint(fargoatsID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(fargoatsID, edgeConstraint);
	rmPlaceObjectDefPerPlayer(fargoatsID, false, rmRandInt(2, 3));
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(6,8), 4.0);
	rmSetObjectDefMinDistance(farBerriesID, rmXFractionToMeters(0.24));
	rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.28));
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, forestTower);
	rmAddObjectDefConstraint(farBerriesID, avoidFoodFar);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, centerConstraint);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, edgeConstraint);
	rmPlaceObjectDefPerPlayer(farBerriesID, false, 1);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	rmAddObjectDefItem(farPredatorID, "polar bear", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(farPredatorID, 65.0);
	if(cNumberNonGaiaPlayers == 2){
		rmSetObjectDefMaxDistance(farPredatorID, rmXFractionToMeters(0.5));
	} else {
		rmSetObjectDefMaxDistance(farPredatorID, rmXFractionToMeters(0.4));
	}
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, forestTower);
	rmAddObjectDefConstraint(farPredatorID, avoidGoats);
	rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, shortEdgeConstraint);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 92", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 92", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 90.0+(5*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, forestTower);
	rmAddObjectDefConstraint(relicID, shortAvoidGold);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(farPredatorID, forestTower);
		rmAddObjectDefConstraint(farPredatorID, avoidFoodFar);
		rmAddObjectDefConstraint(farPredatorID, farAvoidGold);
		rmAddObjectDefConstraint(farPredatorID, shortEdgeConstraint);
		rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("gold avoid settlements 92", "AbstractSettlement", 50.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(5,7), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantHuntableID, forestTower);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHuntableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantHerdableID, forestTower);
		rmAddObjectDefConstraint(giantHerdableID, avoidFoodFar);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidGold);
		rmAddObjectDefConstraint(giantHerdableID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHerdableID, edgeConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, forestTower);
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, shortEdgeConstraint);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 10.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 30.0);
	int forestCount=4*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(90), rmAreaTilesToFraction(160));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(190), rmAreaTilesToFraction(260));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "snow pine forest");
		rmAddAreaConstraint(forestID, forestOtherTCs);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, shortAvoidGold);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, centerConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 3);
		rmSetAreaMinBlobDistance(forestID, 10.0);
		rmSetAreaMaxBlobDistance(forestID, 10.0);
		rmSetAreaCoherence(forestID, 0.1);
		
		if(rmBuildArea(forestID)==false){
			// Stop trying once we fail 15 times in a row.
			failCount++;
			if(failCount==15){
				break;
			}
		} else {
			forestCount++;
			failCount=0;
		}
	}
	
	rmSetStatusText("I've finished vanquishing pantheons for now",0.93);
	
	
	/* ********************************* */
	/* Section 15 Beautification Objects */
	/* ********************************* */
	// Placed in no particular order.
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, centerConstraint);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidGold);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock granite sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, centerConstraint);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	int runeID=rmCreateObjectDef("runestone");
	rmAddObjectDefItem(runeID, "runestone", 1, 0.0);
	rmSetObjectDefMinDistance(runeID, 0.0);
	rmSetObjectDefMaxDistance(runeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(runeID, avoidAll);
	rmAddObjectDefConstraint(runeID, avoidImpassableLand);
	rmAddObjectDefConstraint(runeID, centerConstraint);
	if(cNumberNonGaiaPlayers != 2){
		rmPlaceObjectDefAtLoc(runeID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",1.0);
}
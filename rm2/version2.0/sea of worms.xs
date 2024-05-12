/*	Map Name: Sea of Worms.xs
**	Fast-Paced Ruleset: Mediterranean.xs
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
	int playerTiles=9750;
	if(cMapSize == 1) {
		playerTiles = 12700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 25400;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	
	rmSetSeaType("North Atlantic Ocean");
	rmTerrainInitialize("SnowSand25");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest=rmDefineClass("forest");
	int classPlayer=rmDefineClass("player");
	int classCenter=rmDefineClass("center");
	int classPlayerCore=rmDefineClass("player core");
	int classpatch=rmDefineClass("patch");
	int classBonusIsland=rmDefineClass("bonus island");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, size*0.05);
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 15.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int hand=0;
	if(rmRandFloat(0,1)<0.5) {
		hand = 1;
	}
	rmEchoInfo("hand ="+hand);
	
	if(hand==1) {
		rmSetPlacementSection(0.55, 0.15);
	} else {
		rmSetPlacementSection(0.05, 0.65);
	}
	
	rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));
	rmRecordPlayerLocations();
	
	int centerID=rmCreateArea("center");
	rmSetAreaSize(centerID, 0.15, 0.15);
	if(hand==1) {
		rmSetAreaLocation(centerID, 0.6, 0.4);
	} else {
		rmSetAreaLocation(centerID, 0.4, 0.6);
	}
	rmSetAreaWaterType(centerID, "north atlantic ocean");
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmSetAreaBaseHeight(centerID, 0.0);
	rmSetAreaMinBlobs(centerID, 8*mapSizeMultiplier);
	rmSetAreaMaxBlobs(centerID, 10*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(centerID, 10);
	rmSetAreaMaxBlobDistance(centerID, 20*mapSizeMultiplier);
	rmSetAreaSmoothDistance(centerID, 50);
	rmSetAreaCoherence(centerID, 0.25);
	rmBuildArea(centerID);
	
	int gulfID=rmCreateArea("gulf");
	rmSetAreaSize(gulfID, 0.25, 0.25);
	if(hand==1) { 
		rmSetAreaLocation(gulfID, 0.9, 0.25);
	} else {
		rmSetAreaLocation(gulfID, 0.1, 0.75);
	}
	rmSetAreaWaterType(gulfID, "north atlantic ocean");
	rmAddAreaToClass(gulfID, rmClassID("center"));
	rmSetAreaBaseHeight(gulfID, 0.0);
	rmSetAreaMinBlobs(gulfID, 8*mapSizeMultiplier);
	rmSetAreaMaxBlobs(gulfID, 10*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(gulfID, 10);
	rmSetAreaMaxBlobDistance(gulfID, 20*mapSizeMultiplier);
	rmSetAreaSmoothDistance(gulfID, 50);
	rmSetAreaCoherence(gulfID, 0.25);
	rmBuildArea(gulfID);
	
	// Make bonus islands
	int numIsland = 0;
	if(cNumberNonGaiaPlayers < 4){
		if(rmRandFloat(0,1)<0.5) {
			numIsland = rmRandInt(1,3);
		}
	} else if(cNumberNonGaiaPlayers < 7) {
		numIsland = rmRandInt(2,6);
	} else {
		numIsland = rmRandInt(3,7);
	}
	
	int avoidLand=rmCreateTerrainDistanceConstraint("avoid land", "land", true, 30.0);
	
	for(i=1; <numIsland*mapSizeMultiplier){
		int bonusID=rmCreateArea("Island"+i);
		rmSetAreaSize(bonusID, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(800*mapSizeMultiplier));
		rmSetAreaMinBlobs(bonusID, 4*mapSizeMultiplier);
		rmSetAreaMaxBlobs(bonusID, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(bonusID, 30.0);
		rmSetAreaMaxBlobDistance(bonusID, 50.0*mapSizeMultiplier);
		rmSetAreaSmoothDistance(bonusID, 20);
		rmSetAreaCoherence(bonusID, 0.20);
		rmSetAreaBaseHeight(bonusID, 2.0);
		rmSetAreaHeightBlend(bonusID, 2);
		rmAddAreaToClass(bonusID, classBonusIsland);
		rmAddAreaConstraint(bonusID, avoidLand);
		rmSetAreaTerrainType(bonusID, "SnowSand25");
		rmAddAreaTerrainLayer(bonusID, "snowB", 0, 3);
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	float playerFraction=rmAreaTilesToFraction(1000);
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 4);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaMinBlobDistance(id, 30.0);
		rmSetAreaMaxBlobDistance(id, 50.0);
		rmSetAreaSmoothDistance(id, 20);
		rmSetAreaCoherence(id, 0.20);
		rmSetAreaBaseHeight(id, 2.0);
		rmSetAreaHeightBlend(id, 2);
		rmAddAreaConstraint(id, playerConstraint);
		rmAddAreaConstraint(id, centerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SandA");
		rmAddAreaTerrainLayer(id, "snowSand75", 4, 6);
		rmAddAreaTerrainLayer(id, "snowSand50", 2, 4);
		rmAddAreaTerrainLayer(id, "snowSand25", 0, 2);
	}
	rmBuildAllAreas();
	
	for(i=1; <cNumberPlayers){
		id=rmCreateArea("cliff avoider"+i, rmAreaID("Player"+i));
		rmSetAreaSize(id, 0.01, 0.01);
		rmAddAreaToClass(id, classStartingSettlement);
		rmSetAreaCoherence(id, 1.0);
		rmSetAreaLocPlayer(id, i);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int patchConstraint=rmCreateClassDistanceConstraint("patch v patch", rmClassID("patch"), 10.0);
	int patch = 0;
	int failCount=0;
	for(i=1; <cNumberPlayers*2*mapSizeMultiplier) {
		patch=rmCreateArea("patch"+i);
		rmSetAreaSize(patch, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		rmSetAreaWarnFailure(patch, false);
		rmSetAreaTerrainType(patch, "SnowA");
		rmSetAreaMinBlobs(patch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(patch, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(patch, 16.0);
		rmSetAreaMaxBlobDistance(patch, 40.0*mapSizeMultiplier);
		rmAddAreaToClass(patch, classpatch);
		rmAddAreaConstraint(patch, patchConstraint);
		rmAddAreaConstraint(patch, playerConstraint);
		rmAddAreaConstraint(patch, avoidImpassableLand);
		rmSetAreaCoherence(patch, 0.3);
		rmSetAreaSmoothDistance(patch, 8);
		
		if(rmBuildArea(patch)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3){
				break;
			}
		} else {
			failCount=0;
		}
		
	}
	
	int wideCenterConstraint=rmCreateClassDistanceConstraint("elevation avoids center", rmClassID("center"), 20.0);
	
	int numTries=6*cNumberNonGaiaPlayers;
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, playerConstraint);
		rmAddAreaConstraint(elevID, wideCenterConstraint);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SnowB");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 7.0));
		rmSetAreaHeightBlend(elevID, 2);
		rmSetAreaMinBlobs(elevID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(elevID, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==10){
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	numTries=7*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier) {
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 5.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(elevID, 3*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, playerConstraint);
		rmAddAreaConstraint(elevID, wideCenterConstraint);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==10){
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
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));
	int shortEdgeConstraint=rmCreateBoxConstraint("short edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 12.0);
	
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
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int closeID = -1;
	int farID = -1;
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 30.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		//New way to place TC's. Places them 1 at a time.
		//This way ensures that FairLocs (TC's) will never be too close.
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 55, 75, 0, 20);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidStart);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				rmSetAreaTerrainType(settleArea, "SandA");
				rmAddAreaTerrainLayer(settleArea, "snowSand75", 4, 6);
				rmAddAreaTerrainLayer(settleArea, "snowSand50", 2, 4);
				rmAddAreaTerrainLayer(settleArea, "snowSand25", 0, 2);
				rmBuildArea(settleArea);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false, 70, 100, 60, 10);
			rmAddFairLocConstraint(id, TCavoidSettlement);
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
				rmAddAreaTerrainLayer(settlementArea, "snowSand75", 4, 6);
				rmAddAreaTerrainLayer(settlementArea, "snowSand50", 2, 4);
				rmAddAreaTerrainLayer(settlementArea, "snowSand25", 0, 2);
				rmBuildArea(settlementArea);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, shortEdgeConstraint);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
			for(attempt = 4; < 17){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 12*attempt);
			}
		
			farID=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, shortEdgeConstraint);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			for(attempt = 4; < 17){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 12*attempt);
			}
		}
	} rmResetFairLocs();
		
	if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.26), rmXFractionToMeters(0.38), 70, 20);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		if(cNumberNonGaiaPlayers == 2){
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.35), rmXFractionToMeters(0.45), 80, 20);
		} else {
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.23), rmXFractionToMeters(0.4), 70+(3*cNumberNonGaiaPlayers), 20);
		}
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
					rmSetAreaSize(settlementArea2, 0.005, 0.005);
					rmSetAreaTerrainType(settlementArea2, "SandA");
					rmAddAreaTerrainLayer(settlementArea2, "snowSand75", 4, 6);
					rmAddAreaTerrainLayer(settlementArea2, "snowSand50", 2, 4);
					rmAddAreaTerrainLayer(settlementArea2, "snowSand25", 0, 2);
					rmBuildArea(settlementArea2);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea2);
				}
			}
		} else {
			for(p = 1; <= cNumberNonGaiaPlayers){
				
				farID=rmCreateObjectDef("giant settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, shortEdgeConstraint);
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
				rmAddObjectDefConstraint(farID, shortEdgeConstraint);
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
	
	rmResetFairLocs();
	
	int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land by lots", "land", false, 30.0);
	id = rmAddFairLoc("fortLand", true, true, 30, 35, 40, 16, true);
	rmAddFairLocConstraint(id, farAvoidImpassableLand);
	
	int fortressID=0;
	int migdolID=0;
	int hillFortID=0;
	int palaceID=0;
	int castleID=0;
	
	if(rmPlaceFairLocs()){
		fortressID=rmCreateObjectDef("player fortress");
		rmAddObjectDefItem(fortressID, "Fortress", 1, 0.0);
		rmAddObjectDefItem(fortressID, "Gold Mine Small", 1, 8.0);
		
		migdolID=rmCreateObjectDef("player migdol");
		rmAddObjectDefItem(migdolID, "Migdol Stronghold", 1, 0.0);
		rmAddObjectDefItem(migdolID, "Gold Mine Small", 1, 8.0);
		
		hillFortID=rmCreateObjectDef("player hill fort");
		rmAddObjectDefItem(hillFortID, "Hill Fort", 1, 0.0);
		rmAddObjectDefItem(hillFortID, "Gold Mine Small", 1, 8.0);
		
		palaceID=rmCreateObjectDef("player palace");
		rmAddObjectDefItem(palaceID, "Palace", 1, 0.0);
		rmAddObjectDefItem(palaceID, "Gold Mine Small", 1, 8.0);
		
		castleID=rmCreateObjectDef("player castle");
		rmAddObjectDefItem(castleID, "Castle", 1, 0.0);
		rmAddObjectDefItem(castleID, "Gold Mine Small", 1, 8.0);
		
		
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i)){
				if(rmGetPlayerCulture(i) == cCultureGreek) {
					rmPlaceObjectDefAtLoc(fortressID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				} else if(rmGetPlayerCulture(i) == cCultureEgyptian) {
					rmPlaceObjectDefAtLoc(migdolID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				} else if(rmGetPlayerCulture(i) == cCultureNorse) {
					rmPlaceObjectDefAtLoc(hillFortID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				} else if(rmGetPlayerCulture(i) == cCultureAtlantean) {
					rmPlaceObjectDefAtLoc(palaceID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
				} else {
					rmPlaceObjectDefAtLoc(castleID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
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
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "boar", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 27.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false, 1);
	
	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(6,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, false);
	
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 20.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid gold", "gold", 10.0));
	rmAddObjectDefConstraint(startingBerryID, getOffTheTC);
	rmAddObjectDefConstraint(startingBerryID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingBerryID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("trees avoid all", "all", 6.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	fishID=rmCreateObjectDef("fish2");
	rmAddObjectDefItem(fishID, "fish - perch", 2, 6.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 20.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 4;
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
			rmSetAreaForestType(playerStartingForestID, "snow pine forest");
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
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 55.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumHuntID=rmCreateObjectDef("medium hunt");
	if(rmRandInt(0,1) == 0){
		rmAddObjectDefItem(mediumHuntID, "boar", rmRandInt(4,5), 3.0);
	} else {
		rmAddObjectDefItem(mediumHuntID, "elk", rmRandInt(4,5)+1, 3.0);
	}
	rmSetObjectDefMaxDistance(mediumHuntID, 45.0);
	rmSetObjectDefMaxDistance(mediumHuntID, 50.0);
	rmAddObjectDefConstraint(mediumHuntID, avoidFood);
	rmAddObjectDefConstraint(mediumHuntID, avoidGold);
	rmAddObjectDefConstraint(mediumHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumHuntID, centerConstraint);
	rmAddObjectDefConstraint(mediumHuntID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumHuntID, false, 1);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 110.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1,2));
	
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
	
	int bonusGoldID=rmCreateObjectDef("bonus gold");
	rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(bonusGoldID, 0.0);
	rmSetObjectDefMaxDistance(bonusGoldID, 50.0);
	rmAddObjectDefConstraint(bonusGoldID, avoidGold);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, farStartingSettleConstraint);
	for(i=1; <numIsland*2) {
		rmPlaceObjectDefInRandomAreaOfClass(bonusGoldID, 0, classBonusIsland);
	}
	
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 35.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(1,3), 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "elk", rmRandInt(2,8), 4.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 65.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 75.0+(cNumberNonGaiaPlayers*2-4));
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(6,10), 4.0);
	rmSetObjectDefMinDistance(farBerriesID, rmXFractionToMeters(0.26));
	rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.29));
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farBerriesID, false);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "polar bear", 1, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 90.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 30.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid foody 93", "food", 25.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTerrainDistanceConstraint("preds avoid impassable land", "land", false, 3.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 93", "gold", 35.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 93", "AbstractSettlement", 40.0));
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 75.0);
	rmSetObjectDefMaxDistance(relicID, 110.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic avoid gold 103", "gold", 20.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	int bonusRelicID=rmCreateObjectDef("bonus relic");
	rmAddObjectDefItem(bonusRelicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(bonusRelicID, 0.0);
	rmSetObjectDefMaxDistance(bonusRelicID, 20.0);
	rmAddObjectDefConstraint(bonusRelicID, rmCreateTypeDistanceConstraint("relic avoid gold 108", "gold", 15.0));
	rmAddObjectDefConstraint(bonusRelicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusRelicID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusRelicID, rmCreateTypeDistanceConstraint("bonus relic vs relic", "relic", 30.0));
	if(rmRandFloat(0,1)<0.33) {
		for(i=1; <rmRandInt(1,2)) {
			rmPlaceObjectDefInRandomAreaOfClass(bonusRelicID, 0, classBonusIsland);
		}
	}
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantGoldID, avoidFood);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 93", "gold", 40.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "huntable", rmRandInt(5,7), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, avoidFood);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
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
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "AbstractSettlement", 20.0);
	int forestCount=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.75*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(125), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0.0, 1.0)<0.25) {
			rmSetAreaForestType(forestID, "snow pine forest");
		} else {
			rmSetAreaForestType(forestID, "pine forest");
		}
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
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
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
	
	int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
	int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
	int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
	int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);
	
	int sharkID=rmCreateObjectDef("shark");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
	} else {
		rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
	}
	rmSetObjectDefMinDistance(sharkID, 0.0);
	rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(sharkID, edgeConstraint);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
	rmAddObjectDefConstraint(sharkID, sharkLand);
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5);
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int grassID=rmCreateObjectDef("grass");
	
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int rockID=rmCreateObjectDef("rock and grass");
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
	rmAddObjectDefItem(rockID, "grass", 2, 1.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, avoidRock);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
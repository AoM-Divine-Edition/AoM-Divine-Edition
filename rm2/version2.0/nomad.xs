/*	Map Name: Nomad.xs
**	Fast-Paced Ruleset 1: Midgard.xs
**	Fast-Paced Ruleset 2: Anatolia.xs
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
	int playerTiles=9000;
	if(cMapSize == 1){
		playerTiles = 11700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 23400;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	
	rmSetSeaType("Red Sea");
	rmTerrainInitialize("water");
	rmSetLightingSet("night");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	int classPatch=rmDefineClass("patch");
	int classForest=rmDefineClass("forest");
	int classCliff=rmDefineClass("cliff");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(0), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	for(i=1; <cNumberPlayers) {
		rmCreateTrigger("disableTechs"+i);
	}
	
	// disable starting units
	for(i=1; <cNumberPlayers) {
		rmSwitchToTrigger(rmTriggerID("disableTechs"+i));
		rmSetTriggerActive(true);
		
		/* 0 = unobtainable, 1 = available, 2 = obtainable, 3 = obtainable, 4 = active */
		
		if(rmGetPlayerCulture(i) == cCultureGreek){
			rmAddTriggerEffect("Set Tech Status");
			rmSetTriggerEffectParamInt("PlayerID", i);
			rmSetTriggerEffectParam("TechID", "421");
			rmSetTriggerEffectParam("Status", "0"); /* unobtainable */
		}
		if(rmGetPlayerCulture(i) == cCultureNorse){
			rmAddTriggerEffect("Set Tech Status");
			rmSetTriggerEffectParamInt("PlayerID", i);
			rmSetTriggerEffectParam("TechID", "420");
			rmSetTriggerEffectParam("Status", "0");
		}
		if(rmGetPlayerCulture(i) == cCultureEgyptian){
			rmAddTriggerEffect("Set Tech Status");
			rmSetTriggerEffectParamInt("PlayerID", i);
			rmSetTriggerEffectParam("TechID", "422");
			rmSetTriggerEffectParam("Status", "0");
		}
		if(rmGetPlayerCiv(i) == cCivThor){
			rmAddTriggerEffect("Set Tech Status");
			rmSetTriggerEffectParamInt("PlayerID", i);
			rmSetTriggerEffectParam("TechID", "693");
			rmSetTriggerEffectParam("Status", "0");
		}
/*		if(rmGetPlayerCiv(i) == cCultureAtlantean){
			rmAddTriggerEffect("Set Tech Status");
			rmSetTriggerEffectParamInt("PlayerID", i);
			rmSetTriggerEffectParam("TechID", "709");
			rmSetTriggerEffectParam("Status", "0");
		}*/
		
		// Build TCs faster
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "386");
		rmSetTriggerEffectParam("Status", "4"); /* active */
		rmEchoInfo("Build TC faster");
	}
	
	rmCreateTrigger("Prevent Fighting");
	rmSetTriggerActive(true);
	
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 1);
	
	rmAddTriggerEffect("Grant God Power");
	rmSetTriggerEffectParamInt("PlayerID", 0);
	rmSetTriggerEffectParam("PowerName", "cease fire nomad");
	rmSetTriggerEffectParamInt("Count", 1);
	
	rmAddTriggerEffect("Invoke God Power");
	rmSetTriggerEffectParamInt("PlayerID", 0);
	rmSetTriggerEffectParam("PowerName", "cease fire nomad");
	rmSetTriggerEffectParam("DstPoint1", "1,1,1");
	
	rmAddTriggerEffect("Send Chat");
	rmSetTriggerEffectParamInt("PlayerID", 0);
	rmSetTriggerEffectParam("Message", "{22556}");
	
	rmCreateTrigger("Dawn");
	rmCreateTrigger("Day");
	
	rmSwitchToTrigger(rmTriggerID("Dawn"));
	rmSetTriggerActive(true);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 60);
	rmAddTriggerEffect("Set Lighting");
	rmSetTriggerEffectParam("SetName", "Dawn");
	rmSetTriggerEffectParamInt("FadeTime", 30);
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Day"));
	
	rmSwitchToTrigger(rmTriggerID("Day"));
	rmSetTriggerActive(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 120);
	rmAddTriggerEffect("Set Lighting");
	rmSetTriggerEffectParam("SetName", "Default");
	rmSetTriggerEffectParamInt("FadeTime", 30);
	
	int centerID=rmCreateArea("center");
	float direction = rmRandFloat(0, 1);
	rmSetAreaSize(centerID, 0.55, 0.60);
	
	if(direction<0.25){
		rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.05, 0.95, 1.0, 0.01));
		rmSetAreaLocation(centerID, 0.5, 0.7);
	} else if(direction<0.5) {
		rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.00, 0.95, 0.95, 0.01));
		rmSetAreaLocation(centerID, 0.5, 0.3);
	} else if(direction<0.75) {
		rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.05, 0.05, 1.0, 0.95, 0.01));
		rmSetAreaLocation(centerID, 0.7, 0.5);
	} else {
		rmAddAreaConstraint(centerID, rmCreateBoxConstraint("center-edge", 0.00, 0.05, 0.95, 0.95, 0.01));
		rmSetAreaLocation(centerID, 0.3, 0.5);
	}
	rmSetAreaCoherence(centerID, 0.0);
	rmSetAreaBaseHeight(centerID, 2.0);
	rmSetAreaTerrainType(centerID, "sandB");
	rmSetAreaSmoothDistance(centerID, 10);
	rmSetAreaHeightBlend(centerID, 2);
	rmBuildArea(centerID);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	rmSetTeamSpacingModifier(0.75);
	rmPlacePlayersCircular(0.2, 0.4, rmDegreesToRadians(4.0));
	rmRecordPlayerLocations();
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, size*0.05);
	
	float playerFraction=rmAreaTilesToFraction(4000);
	for(i=1; <cNumberPlayers) {
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
		rmAddAreaConstraint(id, edgeConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SandA");
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers*2) {
		int id2=rmCreateArea("beaut area"+i, centerID);
		rmSetAreaSize(id2, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
		rmSetAreaTerrainType(id2, "SandD");
		rmAddAreaTerrainLayer(id2, "SandC", 1, 4);
		rmSetAreaMinBlobs(id2, 1);
		rmSetAreaMaxBlobs(id2, 5);
		rmAddAreaToClass(id2, classPatch);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0);
		rmSetAreaCoherence(id2, 0.4);
		
		rmBuildArea(id2);
	}
	
	int patchVsPatchConstraint=rmCreateClassDistanceConstraint("patch avoid patch", classPatch, 10.0);
	
	for(i=1; <cNumberPlayers*2){
		int id3=rmCreateArea("beaut area deux"+i, centerID);
		rmSetAreaSize(id3, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
		rmSetAreaTerrainType(id3, "GrassDirt25");
		rmAddAreaTerrainLayer(id3, "GrassDirt50", 2, 4);
		rmAddAreaTerrainLayer(id3, "GrassDirt75", 0, 1);
		rmSetAreaMinBlobs(id3, 1);
		rmSetAreaMaxBlobs(id3, 5);
		rmAddAreaToClass(id3, classPatch);
		rmAddAreaConstraint(id3, patchVsPatchConstraint);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0);
		rmSetAreaCoherence(id3, 0.5);
		
		rmBuildArea(id3);
	}
	
	for(i=1; <cNumberPlayers*2){
		int id4=rmCreateArea("beaut area tres"+i, centerID);
		rmSetAreaSize(id4, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
		rmSetAreaTerrainType(id4, "SandDirt50");
		rmSetAreaMinBlobs(id4, 1);
		rmSetAreaMaxBlobs(id4, 5);
		rmAddAreaToClass(id4, classPatch);
		rmAddAreaConstraint(id4, patchVsPatchConstraint);
		rmSetAreaWarnFailure(id4, false);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0);
		rmSetAreaCoherence(id4, 0.5);
		
		rmBuildArea(id4);
	}
	
	int numTries=40*cNumberNonGaiaPlayers;
	int failCount=0;
	for(i=0; <numTries){
		int elevID=rmCreateArea("elev"+i, centerID);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "SandA");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(5.0, 10.0));
		rmSetAreaHeightBlend(elevID, 2);
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

	numTries=20*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i, centerID);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 12 times in a row.
			failCount++;
			if(failCount==12) {
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

	int avoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 45.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	int shortCliffConstraint=rmCreateClassDistanceConstraint("elev v cliff", rmClassID("cliff"), 10.0);
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	
	rmSetStatusText("",0.46);
	
	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */
	
	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.5){
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, rmXFractionToMeters(0.0), rmXFractionToMeters(0.25), 0, 15);
	} else {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, rmXFractionToMeters(0.0), rmXFractionToMeters(0.25), 0, 15);
	}
	if(rmPlaceFairLocs()){
		int startingGoldID=rmCreateObjectDef("Starting Gold");
		rmAddObjectDefItem(startingGoldID, "Gold Mine", 1, 0.0);
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i)){
				rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
			}
		}
	}
	rmResetFairLocs();
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid impassable land", "Land", false, 30.0);
	
	int TCplaceNum = 3;
	if(cMapSize == 2){
		TCplaceNum = 4;
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance2", "AbstractSettlement", 90.0-3*cNumberNonGaiaPlayers);
	}
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			for(TC = 1; <= TCplaceNum){
				//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
				if(rmRandFloat(0,1) > 0.5){
					id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.0), rmXFractionToMeters(0.5), 40, 16);
				} else {
					id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.0), rmXFractionToMeters(0.5), 40, 16);
				}
				rmAddFairLocConstraint(id, TCavoidSettlement);
				rmAddFairLocConstraint(id, TCavoidImpassableLand);
				
				if(rmPlaceFairLocs()){
					id=rmCreateObjectDef("close settlement "+p+TC);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					int settlementArea = rmCreateArea("settlement_area_"+p+TC);
					rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
					rmSetAreaSize(settlementArea, 0.01, 0.01);
					rmSetAreaTerrainType(settlementArea, "SandA");
					rmAddAreaTerrainLayer(settlementArea, "GrassDirt25", 8, 16);
					rmAddAreaTerrainLayer(settlementArea, "SandDirt50", 16, 24);
					rmBuildArea(settlementArea);
					rmPlaceObjectDefAtAreaLoc(id, p, settlementArea);
				}
				rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
			}
		}
	} else {
		int farSettlementID=rmCreateObjectDef("far settlement");
		rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
		rmSetObjectDefMinDistance(farSettlementID, 0.0);
		rmSetObjectDefMaxDistance(farSettlementID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(farSettlementID, TCavoidImpassableLand);
		rmAddObjectDefConstraint(farSettlementID, TCavoidSettlement);
		rmPlaceObjectDefAtLoc(farSettlementID, 0, 0.5,0.5, TCplaceNum*cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int mediumAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by medium distance", "AbstractSettlement", 30.0);
	int avoidStartingUnits=rmCreateTypeDistanceConstraint("avoid starting units", "unit", 40);
	
	int VillagerGreekID=rmCreateObjectDef("Villager Greek");
	rmAddObjectDefItem(VillagerGreekID, "Villager Greek", 1, 0.0);
	rmSetObjectDefMinDistance(VillagerGreekID, 0.0);
	rmSetObjectDefMaxDistance(VillagerGreekID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(VillagerGreekID, shortCliffConstraint);
	rmAddObjectDefConstraint(VillagerGreekID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(VillagerGreekID, avoidStartingUnits);
	
	int VillagerNorseID=rmCreateObjectDef("Villager norse");
	rmAddObjectDefItem(VillagerNorseID, "Villager norse", 1, 0.0);
	rmSetObjectDefMinDistance(VillagerNorseID, 0.0);
	rmSetObjectDefMaxDistance(VillagerNorseID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(VillagerNorseID, shortCliffConstraint);
	rmAddObjectDefConstraint(VillagerNorseID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(VillagerNorseID, avoidStartingUnits);
	
	int VillagerEgyptianID=rmCreateObjectDef("Villager Egyptian");
	rmAddObjectDefItem(VillagerEgyptianID, "Villager Egyptian", 1, 0.0);
	rmSetObjectDefMinDistance(VillagerEgyptianID, 0.0);
	rmSetObjectDefMaxDistance(VillagerEgyptianID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(VillagerEgyptianID, shortCliffConstraint);
	rmAddObjectDefConstraint(VillagerEgyptianID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(VillagerEgyptianID, avoidStartingUnits);
	
	int VillagerAtlanteanID=rmCreateObjectDef("Villager Atlantean");
	rmAddObjectDefItem(VillagerAtlanteanID, "Villager Atlantean", 1, 0.0);
	rmSetObjectDefMinDistance(VillagerAtlanteanID, 0.0);
	rmSetObjectDefMaxDistance(VillagerAtlanteanID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(VillagerAtlanteanID, shortCliffConstraint);
	rmAddObjectDefConstraint(VillagerAtlanteanID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(VillagerAtlanteanID, avoidStartingUnits);
	
	int VillagerChineseID=rmCreateObjectDef("Villager Chinese");
	rmAddObjectDefItem(VillagerChineseID, "Villager Chinese", 1, 0.0);
	rmSetObjectDefMinDistance(VillagerChineseID, 0.0);
	rmSetObjectDefMaxDistance(VillagerChineseID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(VillagerChineseID, shortCliffConstraint);
	rmAddObjectDefConstraint(VillagerChineseID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(VillagerChineseID, avoidStartingUnits);
	
	int PriestID=rmCreateObjectDef("Priest");
	rmAddObjectDefItem(PriestID, "Priest", 1, 0.0);
	rmSetObjectDefMinDistance(PriestID, 0.0);
	rmSetObjectDefMaxDistance(PriestID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(PriestID, shortCliffConstraint);
	rmAddObjectDefConstraint(PriestID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(PriestID, avoidStartingUnits);
	
	int UlfsarkID=rmCreateObjectDef("Ulfsark");
	rmAddObjectDefItem(UlfsarkID, "Ulfsark", 1, 0.0);
	rmSetObjectDefMinDistance(UlfsarkID, 0.0);
	rmSetObjectDefMaxDistance(UlfsarkID, rmXFractionToMeters(0.25));
	rmAddObjectDefConstraint(UlfsarkID, shortCliffConstraint);
	rmAddObjectDefConstraint(UlfsarkID, mediumAvoidSettlement);
	rmAddObjectDefConstraint(UlfsarkID, avoidStartingUnits);
	
	int playerculture = 0;
	
	for(i=0; <cNumberPlayers) {
		playerculture = rmGetPlayerCulture(i);
		rmEchoInfo("player "+i+" culture "+playerculture);
	}
	
	for(i=0; <cNumberPlayers) {
		if(rmGetPlayerCulture(i) == cCultureGreek) {
			rmPlaceObjectDefAtLoc(VillagerGreekID, i, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
			rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
			rmAddPlayerResource(i, "Food", 50);
			rmAddPlayerResource(i, "Wood", 300);
			rmAddPlayerResource(i, "Gold", 300);
		} else if(rmGetPlayerCulture(i) == cCultureEgyptian) {
			rmPlaceObjectDefAtLoc(VillagerEgyptianID, i, rmGetPlayerX(i), rmGetPlayerZ(i), 3);
			rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
			rmAddPlayerResource(i, "Food", 50);
			rmAddPlayerResource(i, "Gold", 400);
		} else if(rmGetPlayerCulture(i) == cCultureNorse) {
			rmPlaceObjectDefAtLoc(UlfsarkID, i, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
			rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
			rmAddPlayerResource(i, "Food", 50);
			rmAddPlayerResource(i, "Wood", 350);
			rmAddPlayerResource(i, "Gold", 300);
		} else if(rmGetPlayerCulture(i) == cCultureAtlantean) {
			rmPlaceObjectDefAtLoc(VillagerAtlanteanID, i, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
			rmEchoInfo("Placing Villagers for Player "+i+" who is "+rmGetPlayerCulture(i));
			rmAddPlayerResource(i, "Food", 50);
			rmAddPlayerResource(i, "Wood", 350);
			rmAddPlayerResource(i, "Gold", 300);
		} else if(rmGetPlayerCulture(i) == cCultureChinese) {
			rmPlaceObjectDefAtLoc(VillagerChineseID, i, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
			rmEchoInfo("Placing Villagers for Player "+i+" who is Chinese");
			rmAddPlayerResource(i, "Food", 50);
			rmAddPlayerResource(i, "Wood", 300);
			rmAddPlayerResource(i, "Gold", 300);
		}
	}
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 40.0);
	int shortAvoidStartingUnits=rmCreateTypeDistanceConstraint("short avoid starting units", "unit", 4.0);
	
	for(i=0; <5) {
		int cliffID=rmCreateArea("cliff"+i, centerID);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(500));
		rmSetAreaCliffType(cliffID, "Egyptian");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, shortAvoidStartingUnits);
		rmAddAreaConstraint(cliffID, avoidImpassableLand);
		rmAddAreaConstraint(cliffID, avoidSettlement);
		rmAddAreaToClass(cliffID, classCliff);
		rmSetAreaMinBlobs(cliffID, 10);
		rmSetAreaMaxBlobs(cliffID, 10);
		int edgeRand=rmRandInt(0,100);
		if(edgeRand<33) {
			// Inaccesible
			rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
			rmSetAreaTerrainType(cliffID, "cliffEgyptianA");
		} else {
			// AOK style
			rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
		}
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		
		rmSetAreaMinBlobDistance(cliffID, 20.0);
		rmSetAreaMaxBlobDistance(cliffID, 20.0);
		rmSetAreaCoherence(cliffID, 0.0);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		rmBuildArea(cliffID);
	}
	
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 20.0);
	
	int maxNum = 3;
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
			rmSetAreaForestType(playerStartingForestID, "palm forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTerrain);
			rmAddAreaConstraint(playerStartingForestID, shortCliffConstraint);
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
	
	//No Medium Objects for Nomad.
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 150.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 3);
	
	int farGold2ID=rmCreateObjectDef("far gold 2");
	rmAddObjectDefItem(farGold2ID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGold2ID, 60.0);
	rmSetObjectDefMaxDistance(farGold2ID, 100.0 + (cNumberNonGaiaPlayers*3));
	rmAddObjectDefConstraint(farGold2ID, avoidGold);
	rmAddObjectDefConstraint(farGold2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGold2ID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(farGold2ID, false, 1);
	
	int medAvoidGold = rmCreateTypeDistanceConstraint("food avoid dat gold yo", "gold", 30.0);
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandFloat(5, 8), 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandFloat(3, 5), 2.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID, medAvoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, avoidAll);
	rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*2);
	
	int bonusHuntable2ID=rmCreateObjectDef("second bonus huntable");
	float bonusChance2=rmRandFloat(0, 1);
	if(bonusChance2<0.5) {
		rmAddObjectDefItem(bonusHuntable2ID, "elephant", 2, 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", 2, 2.0);
	}
	rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntable2ID, medAvoidGold);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidAll);
	rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int farMonkeyID=rmCreateObjectDef("far monkeys");
	rmAddObjectDefItem(farMonkeyID, "baboon", 8, 2.0);
	rmSetObjectDefMinDistance(farMonkeyID, 0.0);
	rmSetObjectDefMaxDistance(farMonkeyID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farMonkeyID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farMonkeyID, false, 1);
		
	int farGoatsID=rmCreateObjectDef("far goats");
	rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 0.0);
	rmSetObjectDefMaxDistance(farGoatsID, 150.0);
	rmAddObjectDefConstraint(farGoatsID, medAvoidGold);
	rmAddObjectDefConstraint(farGoatsID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoatsID, avoidAll);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(farGoatsID, 0, 0.5, 0.5, 3);
	}
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 0.0);
	rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, avoidAll);
	rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers*2);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 60.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, avoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	
	int randomtree2ID=rmCreateObjectDef("random tree two");
	rmAddObjectDefItem(randomtree2ID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomtree2ID, 0.0);
	rmSetObjectDefMaxDistance(randomtree2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomtree2ID, rmCreateTypeDistanceConstraint("random tree 2", "all", 4.0));
	rmAddObjectDefConstraint(randomtree2ID, avoidSettlement);
	rmAddObjectDefConstraint(randomtree2ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomtree2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int lineFishID=rmCreateObjectDef("line fish");
	rmAddObjectDefItem(lineFishID, "fish - mahi", 3, 12.0);
	rmSetObjectDefMinDistance(lineFishID, 0.0);
	rmSetObjectDefMaxDistance(lineFishID, 0.0);

	rmPlaceObjectDefInLineX(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.97, 0.0, 1.0, 0.015);
	rmPlaceObjectDefInLineX(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.03, 0.0, 1.0, 0.015);
	rmPlaceObjectDefInLineZ(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.97, 0.0, 1.0, 0.015);
	rmPlaceObjectDefInLineZ(lineFishID, 0, 3+cNumberNonGaiaPlayers, 0.03, 0.0, 1.0, 0.015);
	
	
	//Random filler fish
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 30.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 2, 18.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
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
		rmSetObjectDefMaxDistance(giantGoldID, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantGoldID, avoidGold);
		rmAddObjectDefConstraint(giantGoldID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantGoldID, avoidSettlement);
		rmPlaceObjectDefAtLoc(giantGoldID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
		
		int classGiantHuntable=rmDefineClass("giant Map Size huntables");
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "huntable", rmRandInt(5,7), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, 0.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, medAvoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefAtLoc(giantHuntableID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,3), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, 0.0);
		rmSetObjectDefMaxDistance(giantHerdableID, 2*rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, medAvoidGold);
		rmAddObjectDefConstraint(giantHerdableID, rmCreateTypeDistanceConstraint("avoid other food sources", "food", 30.0));
		rmPlaceObjectDefAtLoc(giantHerdableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, medAvoidGold);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 12.0);
	int forestVsTCs = rmCreateTypeDistanceConstraint("forest vs settle", "AbstractSettlement", 14.0);
	int shortCliff=rmCreateClassDistanceConstraint("forest v cliff", rmClassID("cliff"), 6.0);
	
	failCount=0;
	numTries=12*cNumberNonGaiaPlayers*mapSizeMultiplier;
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i, centerID);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "palm forest");
		rmAddAreaConstraint(forestID, allObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, shortCliff);
		rmAddAreaConstraint(forestID, forestVsTCs);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 7);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmBuildArea(forestID)==false) {
			// Stop trying once we fail 7 times in a row.
			failCount++;
			if(failCount==7*mapSizeMultiplier){
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
	rmAddObjectDefConstraint(sharkID, sharkVssharkID);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
	rmAddObjectDefConstraint(sharkID, sharkLand);
	rmAddObjectDefConstraint(sharkID, edgeConstraint);
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 20.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);

	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 50*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
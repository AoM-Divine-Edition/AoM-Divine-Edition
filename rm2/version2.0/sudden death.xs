/*	Map Name: Sudden Death.xs
**	Fast-Paced Ruleset: Savannah.xs
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
	int playerTiles=10000;
	if(cMapSize == 1) {
		playerTiles = 13000;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 24000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmTerrainInitialize("GrassA");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classForest = rmDefineClass("forest");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	for(i=1; <cNumberPlayers) {
		rmCreateTrigger("StartCountdown" + i);
		rmCreateTrigger("CountdownWarning"+i);
		rmCreateTrigger("StopCountdown" +i);
		rmCreateTrigger("Loss" +i);
		rmCreateTrigger("grantTechs"+i);
	}
	rmCreateTrigger("gaiaChat");
	
	// Start Countdown
	for(i=1; <cNumberPlayers) {
		rmSwitchToTrigger(rmTriggerID("StartCountdown"+i));
		rmSetTriggerActive(true);
		
		rmAddTriggerCondition("Player Unit Count");
		rmSetTriggerConditionParamInt("PlayerID", i);
		rmSetTriggerConditionParam("ProtoUnit", "Settlement Level 1");
		rmSetTriggerConditionParam("Op", "<");
		rmSetTriggerConditionParamInt("Count", 1);
		
		rmAddTriggerCondition("Player Unit Count");
		rmSetTriggerConditionParamInt("PlayerID", i);
		rmSetTriggerConditionParam("ProtoUnit", "Citadel Center");
		rmSetTriggerConditionParam("Op", "<");
		rmSetTriggerConditionParamInt("Count", 1);
		
		rmAddTriggerCondition("Player Active");
		rmSetTriggerConditionParamInt("PlayerID", i);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22608)}");
		
		rmAddTriggerEffect("Counter:Add Timer");
		rmSetTriggerEffectParam("Name", "victoryCounter"+i);
		rmSetTriggerEffectParamInt("Start",120);
		rmSetTriggerEffectParamInt("Stop",30);
		rmSetTriggerEffectParam("Msg", "{PlayerIDNameString("+i+",22609)}");
		rmSetTriggerEffectParamInt("Event", rmTriggerID("CountdownWarning"+i));
		
		rmAddTriggerEffect("Fire Event");
		rmSetTriggerEffectParamInt("EventID", rmTriggerID("StopCountdown"+i));
	}
	
	// Countdown Warning
	for(i=1; <cNumberPlayers) {
		rmSwitchToTrigger(rmTriggerID("CountdownWarning"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22610)}");
		
		rmAddTriggerEffect("Counter:Add Timer");
		rmSetTriggerEffectParam("Name", "victoryCounter2"+i);
		rmSetTriggerEffectParamInt("Start",30);
		rmSetTriggerEffectParamInt("Stop",0);
		rmSetTriggerEffectParam("Msg", "{PlayerIDNameString("+i+",22609)}");
		rmSetTriggerEffectParamInt("Event", rmTriggerID("Loss"+i));
	}
	
	// Stop Countdown
	for(i=1; <cNumberPlayers){
		rmSwitchToTrigger(rmTriggerID("StopCountdown"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerCondition("Player Unit Count");
		rmSetTriggerConditionParamInt("PlayerID", i);
		rmSetTriggerConditionParam("ProtoUnit", "Settlement Level 1");
		rmSetTriggerConditionParam("Op", ">");
		rmSetTriggerConditionParamInt("Count", 0);
		
		rmAddTriggerEffect("Counter Stop");
		rmSetTriggerEffectParam("Name", "victoryCounter"+i);
		
		rmAddTriggerEffect("Counter Stop");
		rmSetTriggerEffectParam("Name", "victoryCounter2"+i);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22611)}");
		
		rmAddTriggerEffect("Fire Event");
		rmSetTriggerEffectParamInt("EventID", rmTriggerID("StartCountdown"+i));
	}
	
	// You lose
	for(i=1; <cNumberPlayers) {
		rmSwitchToTrigger(rmTriggerID("Loss"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22612)}");
		
		rmAddTriggerEffect("Set Player Defeated");
		rmSetTriggerEffectParamInt("Player", i);
	}
	
	// Fire starting units
	for(i=1; <cNumberPlayers) {
		rmSwitchToTrigger(rmTriggerID("grantTechs"+i));
		rmSetTriggerActive(true);
		
		rmAddTriggerCondition("Timer");
		rmSetTriggerConditionParamInt("Param1", 1);
		
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "33");
		rmSetTriggerEffectParam("Status", "4");
		
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "60");
		rmSetTriggerEffectParam("Status", "4");
		
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "182");
		rmSetTriggerEffectParam("Status", "4");
		
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "362");
		rmSetTriggerEffectParam("Status", "4");	
	}
	
	rmSwitchToTrigger(rmTriggerID("gaiaChat"));
	rmSetTriggerActive(true);
	
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 1);
	
	rmAddTriggerEffect("Send Chat");
	rmSetTriggerEffectParamInt("PlayerID", 0);
	rmSetTriggerEffectParam("Message", "{22613}");
	
	// Trigger to grant Altantis a favor trickle
	for(i=1; <cNumberPlayers) {
		if(rmGetPlayerCulture(i) == cCultureAtlantean) {
			rmCreateTrigger("Favor_trickle"+i);
			rmSetTriggerActive(true);
			rmSetTriggerPriority(4);
			rmSetTriggerLoop(false);
			
			rmAddTriggerEffect("Set Tech Status");
			rmSetTriggerEffectParamInt("PlayerID", i);
			rmSetTriggerEffectParam("TechID", "496");
			rmSetTriggerEffectParam("Status", "4");
		}
	}
	
	if(cNumberTeams == 2){
		int coreThreeID=rmCreateArea("core three");
		rmSetAreaSize(coreThreeID, 0.1, 0.1);
		rmSetAreaLocation(coreThreeID, 0, 1);
		rmSetAreaWaterType(coreThreeID, "Greek River");
		rmSetAreaBaseHeight(coreThreeID, 0.0);
		rmSetAreaMinBlobs(coreThreeID, 3);
		rmSetAreaHeightBlend(coreThreeID, 1);
		rmSetAreaMaxBlobs(coreThreeID, 3);
		rmSetAreaMinBlobDistance(coreThreeID, 20.0);
		rmSetAreaMaxBlobDistance(coreThreeID, 20.0);
		rmSetAreaCoherence(coreThreeID, 0.25);
		rmAddAreaInfluenceSegment(coreThreeID, 0, 1, 0.3, 0.7);
		rmBuildArea(coreThreeID);
		
		int coreFourID=rmCreateArea("core four");
		rmSetAreaSize(coreFourID, 0.1, 0.1);
		rmSetAreaLocation(coreFourID, 1, 0);
		rmSetAreaWaterType(coreFourID, "Greek River");
		rmSetAreaBaseHeight(coreFourID, 0.0);
		rmSetAreaMinBlobs(coreFourID, 3);
		rmSetAreaHeightBlend(coreFourID, 1);
		rmSetAreaMaxBlobs(coreFourID, 3);
		rmSetAreaMinBlobDistance(coreFourID, 20.0);
		rmSetAreaMaxBlobDistance(coreFourID, 20.0);
		rmSetAreaCoherence(coreFourID, 0.25);
		rmAddAreaInfluenceSegment(coreFourID, 0.7, 0.3, 1, 0);
		rmBuildArea(coreFourID);
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	if(cNumberNonGaiaPlayers == 2){
		rmPlacePlayersLine(0.15, 0.15, 0.85, 0.85, 0, 0);
	} else if(cNumberTeams == 2){
		rmPlacePlayersLine(0.07, 0.07, 0.93, 0.93, 0, 20);
	} else {
		rmPlacePlayersCircular(0.35, 0.4, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	float playerFraction=rmAreaTilesToFraction(1600);
	for(i=1; <cNumberPlayers) {
		// Create the area.
		int id=rmCreateArea("Player"+i);
		rmSetAreaSize(id, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
		rmSetAreaWarnFailure(id, false);
		rmSetPlayerArea(i, id);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaMinBlobDistance(id, 16.0);
		rmSetAreaMaxBlobDistance(id, 40.0);
		rmSetAreaCoherence(id, 0.0);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "GrassDirt50");
		rmAddAreaTerrainLayer(id, "GrassDirt25", 0, 4);
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers) {
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(400*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, "GrassDirt50");
		rmAddAreaTerrainLayer(id2, "GrassDirt25", 0, 2);
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier) {
		int id3=rmCreateArea("Sand patch"+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(500*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "SandC");
		rmAddAreaTerrainLayer(id3, "GrassDirt75", 4, 6);
		rmAddAreaTerrainLayer(id3, "GrassDirt50", 2, 4);
		rmAddAreaTerrainLayer(id3, "GrassDirt25", 0, 2);
		rmAddAreaConstraint(id3, avoidImpassableLand);
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		
		rmBuildArea(id3);
	}
	
	int classCliff=rmDefineClass("cliff");
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 20.0);
	int shortCliffConstraint=rmCreateClassDistanceConstraint("stuff v cliff", rmClassID("cliff"), 10.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 30.0);
	int failCount=0;
	
	for(i=0; <cNumberPlayers*1.5) {
		int cliffID=rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
		rmSetAreaCliffType(cliffID, "Greek");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, avoidImpassableLand);
		rmAddAreaToClass(cliffID, classCliff);
		rmAddAreaConstraint(cliffID, avoidBuildings);
		rmSetAreaMinBlobs(cliffID, 10);
		rmSetAreaMaxBlobs(cliffID, 10);
		rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
		rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaMinBlobDistance(cliffID, 16.0);
		rmSetAreaMaxBlobDistance(cliffID, 40.0);
		rmSetAreaCoherence(cliffID, 0.25);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaHeightBlend(cliffID, 2);
		
		if(rmBuildArea(cliffID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	int numTries=10*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(80), rmAreaTilesToFraction(200));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, cliffConstraint);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaTerrainType(elevID, "GrassDirt50");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 20 times in a row.
			failCount++;
			if(failCount==20) {
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

	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 40.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(5), rmZTilesToFraction(5), 1.0-rmXTilesToFraction(5), 1.0-rmZTilesToFraction(5));
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by short distance", "AbstractSettlement", 20.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 35.0);
	
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
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Citadel Center", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);
	
	int towerVsTowerID = -1;
	int towerClass = -1;
	int avoidOtherPlayerTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);
	for(i=1; <cNumberPlayers) {
		towerClass = rmDefineClass("classTower"+i);
		towerVsTowerID=rmCreateClassDistanceConstraint("player towers spread out "+i, towerClass, 25);
		rmEchoInfo "player "+i+"'s towers avoid "+i);
		for(j=1; <5){
			int startingTowerID=rmCreateObjectDef("Starting tower for player "+i+" number "+j);
			rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
			rmAddObjectDefItem(startingTowerID, "tent", 1, 5.0);
			rmSetObjectDefMinDistance(startingTowerID, 22.0);
			rmSetObjectDefMaxDistance(startingTowerID, 32.0);
			rmAddObjectDefToClass(startingTowerID, towerClass);
			rmAddObjectDefConstraint(startingTowerID, towerVsTowerID);
			rmAddObjectDefConstraint(startingTowerID, avoidOtherPlayerTower);
			rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);
			rmPlaceObjectDefAtAreaLoc(startingTowerID, i, rmAreaID("Player"+i));
		}
	}

	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "elk", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 22.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 25.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closeGoatsID=rmCreateObjectDef("close goats");
	rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
	rmSetObjectDefMinDistance(closeGoatsID, 22.0);
	rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
	rmAddObjectDefConstraint(closeGoatsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeGoatsID, getOffTheTC);
	rmAddObjectDefConstraint(closeGoatsID, avoidFood);
	rmPlaceObjectDefPerPlayer(closeGoatsID, false, 2);
	
	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(5,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(startingChickenID, false);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid all", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 10);
	
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
			rmSetAreaForestType(playerStartingForestID, "mixed palm forest");
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
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	rmSetObjectDefMaxDistance(farGoldID, 95.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, rmCreateBoxConstraint("far edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8)));
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, farAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(1, 2));
	
	int farAvoidFood=rmCreateTypeDistanceConstraint("avoid huntable", "food", 35.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "boar", 3, 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "deer", 7, 6.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 75.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 85.0);
	rmAddObjectDefConstraint(bonusHuntableID, farAvoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false, 2);
	
	int farGoatsID=rmCreateObjectDef("far Goats");
	rmAddObjectDefItem(farGoatsID, "Goat", 2, 4.0);
	rmSetObjectDefMinDistance(farGoatsID, 80.0);
	rmSetObjectDefMaxDistance(farGoatsID, 150.0);
	rmAddObjectDefConstraint(farGoatsID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoatsID, rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0));
	rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farGoatsID, false, 2);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 115.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0));
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0+(4*cMapSize));
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	int fishID=rmCreateObjectDef("fish2");
	rmAddObjectDefItem(fishID, "fish - perch", 3, 6.0);
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
	
		int giantAvoidGold=rmCreateTypeDistanceConstraint("giant avoid gold", "gold", 60.0);
	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, giantAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantGoldID, farAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(2, 3));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "boar", 3, 3.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.325));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, farAvoidFood);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		rmAddObjectDefItem(giantHuntable2ID, "deer", 7, 6.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntable2ID, farAvoidFood);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(3,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20.0);
	
	int forestCount=5*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaForestType(forestID, "oak forest");
		} else {
			rmSetAreaForestType(forestID, "mixed palm forest");
		}
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaConstraint(forestID, playerConstraint);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
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
	
	int bushID2=rmCreateObjectDef("bush group");
	rmAddObjectDefItem(bushID2, "bush", 1, 0.0);
	rmSetObjectDefMinDistance(bushID2, 0.0);
	rmSetObjectDefMaxDistance(bushID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bushID2, avoidAll);
	rmAddObjectDefConstraint(bushID2, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(bushID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
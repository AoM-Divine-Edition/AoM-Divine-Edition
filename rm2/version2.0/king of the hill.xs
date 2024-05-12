/*	Map Name: King Of The Hill.xs
**	Fast-Paced Ruleset: Savannah.xs (Medit?)
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
		playerTiles = 16500;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	float terrainType = rmRandFloat(0, 1);
	int terrainChance = 0;
	
	/* Greek = 0, Egyptian = 1, Norse = 2 */
	if(terrainType < 0.1){
		terrainChance = 0;
		rmEchoInfo("terrain type "+terrainType+" terrain chance "+terrainChance+ " Greek");
	} else if(terrainType < 0.6) {
		terrainChance = 1;
		rmEchoInfo("terrain type "+terrainType+" terrain chance "+terrainChance+ " Egyptian");
	} else {
		terrainChance = 2;
		rmEchoInfo("terrain type "+terrainType+" terrain chance "+terrainChance+ " Norse");
	}
	
	rmSetSeaLevel(0.0);
	rmSetSeaType("red sea");
	
	if(terrainChance == 0) {
		rmTerrainInitialize("GrassA");
	} else if(terrainChance == 2) {
		rmTerrainInitialize("SnowA");
	} else { 
		rmTerrainInitialize("SandB");
	}
	
	rmSetGaiaCiv(cCivZeus);
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classForest=rmDefineClass("forest");
	int classPlayer=rmDefineClass("player");
	int classCenter=rmDefineClass("center");
	int classPlayerCore=rmDefineClass("player core");
	int classPatch=rmDefineClass("patch");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 20);
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 15.0);
	int shortAvoidBuildings=rmCreateTypeDistanceConstraint("short avoid buildings", "Building", 10.0);
	int avoidIce = 0;
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	// Define triggers
	for(i=1; <cNumberPlayers){
		rmCreateTrigger("StartCountdown"+i);
		rmCreateTrigger("CountdownWarning"+i);
		rmCreateTrigger("CriticalCountdownWarning"+i);
		rmCreateTrigger("StopCountdown"+i);
		rmCreateTrigger("Victory"+i);
	}
	
	// Start countdown when Player has Vault
	for(i=1; <cNumberPlayers){
		rmSwitchToTrigger(rmTriggerID("StartCountdown"+i));
		rmSetTriggerActive(true);
		
		rmAddTriggerCondition("Player Unit Count");
		rmSetTriggerConditionParamInt("PlayerID", i);
		rmSetTriggerConditionParam("ProtoUnit", "Plenty Vault KOTH");
		rmSetTriggerConditionParam("Op", ">");
		rmSetTriggerConditionParamInt("Count", 0);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22593)}");
		
		rmAddTriggerEffect("Sound Filename");
		rmSetTriggerEffectParam("Sound", "Fanfare.wav");
		
		rmAddTriggerEffect("Counter:Add Timer");
		rmSetTriggerEffectParam("Name", "victoryCounter"+i);
		rmSetTriggerEffectParamInt("Start",480);
		rmSetTriggerEffectParamInt("Stop",120);
		rmSetTriggerEffectParam("Msg", "{PlayerIDNameString(" + i + ",22594)}");
		rmSetTriggerEffectParamInt("Event", rmTriggerID("CountdownWarning"+i));
		
		rmAddTriggerEffect("Fire Event");
		rmSetTriggerEffectParamInt("EventID", rmTriggerID("StopCountdown"+i));
	}
	
	// Warn players when Countdown = 2 minutes
	for(i=1; <cNumberPlayers){
		rmSwitchToTrigger(rmTriggerID("CountdownWarning"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22595)}");
		
		rmAddTriggerEffect("Sound Filename");
		rmSetTriggerEffectParam("Sound", "Fanfare.wav");
		
		rmAddTriggerEffect("Counter:Add Timer");
		rmSetTriggerEffectParam("Name", "victoryCounter2"+i);
		rmSetTriggerEffectParamInt("Start",120);
		rmSetTriggerEffectParamInt("Stop",30);
		rmSetTriggerEffectParam("Msg", "{PlayerIDNameString(" + i + ",22594)}");
		rmSetTriggerEffectParamInt("Event", rmTriggerID("CriticalCountdownWarning"+i));
	}
	
	// Warn players when Countdown = 30 seconds
	for(i=1; <cNumberPlayers){
		rmSwitchToTrigger(rmTriggerID("CriticalCountdownWarning"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22596)}");
		
		rmAddTriggerEffect("Sound Filename");
		rmSetTriggerEffectParam("Sound", "Fanfare.wav");
		
		rmAddTriggerEffect("Counter:Add Timer");
		rmSetTriggerEffectParam("Name", "victoryCounter3"+i);
		rmSetTriggerEffectParamInt("Start",30);
		rmSetTriggerEffectParamInt("Stop",0);
		rmSetTriggerEffectParam("Msg", "{PlayerIDNameString(" + i + ",22594)}");
		rmSetTriggerEffectParamInt("Event", rmTriggerID("Victory"+i));
	}
	
	// Stop countdown when Player loses Vault
	for(i=1; <cNumberPlayers){
		rmSwitchToTrigger(rmTriggerID("StopCountdown"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerCondition("Player Unit Count");
		rmSetTriggerConditionParamInt("PlayerID", i);
		rmSetTriggerConditionParam("ProtoUnit", "Plenty Vault KOTH");
		rmSetTriggerConditionParam("Op", "<");
		rmSetTriggerConditionParamInt("Count", 1);
		
		rmAddTriggerEffect("Counter Stop");
		rmSetTriggerEffectParam("Name", "victoryCounter"+i);
		
		rmAddTriggerEffect("Counter Stop");
		rmSetTriggerEffectParam("Name", "victoryCounter2"+i);
		
		rmAddTriggerEffect("Counter Stop");
		rmSetTriggerEffectParam("Name", "victoryCounter3"+i);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22597)}");
		
		rmAddTriggerEffect("Fire Event");
		rmSetTriggerEffectParamInt("EventID", rmTriggerID("StartCountdown"+i));
	}
	
	// Declare Victory when countdown done
	for(i=1; <cNumberPlayers){
		rmSwitchToTrigger(rmTriggerID("Victory"+i));
		rmSetTriggerActive(false);
		
		rmAddTriggerEffect("Send Chat");
		rmSetTriggerEffectParamInt("PlayerID", 0);
		rmSetTriggerEffectParam("Message", "{PlayerNameString("+i+",22598)}");
		
		rmAddTriggerEffect("Sound Filename");
		rmSetTriggerEffectParam("Sound", "Fanfare.wav");
		
		rmAddTriggerEffect("Set Player Won");
		rmSetTriggerEffectParamInt("Player", i);
	}
	
	// Enable resources for Plenty Vault
	rmCreateTrigger("Enable Vault");
	rmSetTriggerActive(true);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1",30);
	
	for(i=1; <cNumberPlayers){
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "378");
		rmSetTriggerEffectParam("Status", "4");
	}
	// ### TRIGGERS COMPLETE
	
	
	
	
	rmSetTeamSpacingModifier(0.75);
	if(cMapSize == 2){
		if(terrainChance == 2){
			rmPlacePlayersCircular(0.33, 0.35, rmDegreesToRadians(5.0));
		} else if(terrainChance == 1){
			
		} else {
			rmPlacePlayersCircular(0.38, 0.39, rmDegreesToRadians(5.0));
		}
	} else {
		rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));
	}
	rmRecordPlayerLocations();
	
	int centerID=rmCreateArea("center");
	rmSetAreaLocation(centerID, 0.5, 0.5);
	if(terrainChance == 2){
		rmSetAreaTerrainType(centerID,"IceA");
		rmSetAreaBaseHeight(centerID, 0.0);
		rmSetAreaSize(centerID, 0.20, 0.20);
		if(cMapSize == 2){
			rmSetAreaSize(centerID, 0.15, 0.15);
		}
		avoidIce = 1;
	} else if(terrainChance == 1) {
		rmSetAreaWaterType(centerID, "red sea");
		rmSetAreaBaseHeight(centerID, 0.0);
		rmSetAreaSize(centerID, 0.25, 0.25);
	} else {
		rmSetAreaCliffType(centerID, "Greek");
		rmSetAreaCliffEdge(centerID, 4, 0.20, 0.2, 1.0, 1);
		rmSetAreaCliffPainting(centerID, false, true, true, 1.5, true);
		rmSetAreaCliffHeight(centerID, 7, 1.0, 0.5);
		if(cNumberNonGaiaPlayers < 3) {
			rmSetAreaSize(centerID, rmAreaTilesToFraction(300), rmAreaTilesToFraction(300));
		} else if(cNumberNonGaiaPlayers < 5) {
			rmSetAreaSize(centerID, rmAreaTilesToFraction(1600), rmAreaTilesToFraction(1600*mapSizeMultiplier));
		}
		if(cNumberNonGaiaPlayers < 7) {
			rmSetAreaSize(centerID, rmAreaTilesToFraction(2200*mapSizeMultiplier), rmAreaTilesToFraction(2200));
		} else {
			rmSetAreaSize(centerID, rmAreaTilesToFraction(2400*mapSizeMultiplier), rmAreaTilesToFraction(2400*mapSizeMultiplier));
		}
	}
	
	rmAddAreaToClass(centerID, rmClassID("center"));
	rmSetAreaMinBlobs(centerID, 8*mapSizeMultiplier);
	rmSetAreaMaxBlobs(centerID, 10*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(centerID, 10);
	rmSetAreaMaxBlobDistance(centerID, 20*mapSizeMultiplier);
	rmSetAreaSmoothDistance(centerID, 50);
	rmSetAreaCoherence(centerID, 0.25);
	rmBuildArea(centerID);
	
	// monkey island
	if(terrainChance == 1){
		int sandIslandID=rmCreateArea("sandisland");
		rmSetAreaSize(sandIslandID, rmAreaTilesToFraction(600*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaLocation(sandIslandID, 0.5, 0.5);
		rmSetAreaTerrainType(sandIslandID, "SandC");
		rmSetAreaBaseHeight(sandIslandID, 1.0);
		rmSetAreaSmoothDistance(sandIslandID, 10);
		rmSetAreaHeightBlend(sandIslandID, 2);
		rmSetAreaCoherence(sandIslandID, 1.0);
		rmBuildArea(sandIslandID);
	}
	
	if(terrainChance == 2){
		int snowIslandID=rmCreateArea("snowisland");
		rmSetAreaSize(snowIslandID, rmAreaTilesToFraction(80*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
		rmSetAreaLocation(snowIslandID, 0.5, 0.5);
		rmSetAreaTerrainType(snowIslandID, "SnowA");
		rmSetAreaBaseHeight(snowIslandID, 1.0);
		rmSetAreaSmoothDistance(snowIslandID, 10);
		rmSetAreaHeightBlend(snowIslandID, 2);
		rmSetAreaCoherence(snowIslandID, 1.0);
		rmBuildArea(snowIslandID);
	}
	
	int vaultID=rmCreateObjectDef("Vault");
	rmAddObjectDefItem(vaultID, "plenty vault koth", 1, 0.0);
	rmSetObjectDefMinDistance(vaultID, 0.0);
	rmSetObjectDefMinDistance(vaultID, 0.0);
	rmPlaceObjectDefAtLoc(vaultID, 0, 0.5, 0.5);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	float playerFraction=rmAreaTilesToFraction(2000);
	for(i=1; <cNumberPlayers){
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
		rmSetAreaBaseHeight(id, 0.0);
		rmSetAreaHeightBlend(id, 2);
		rmAddAreaConstraint(id, playerConstraint);
		rmAddAreaConstraint(id, centerConstraint);
		rmSetAreaLocPlayer(id, i);
		if(terrainChance == 0) {
			rmSetAreaTerrainType(id, "GrassDirt25");
		} else if(terrainChance == 2) {
			rmSetAreaTerrainType(id, "GrassA");
			rmAddAreaTerrainLayer(id, "SnowGrass75", 5, 8);
			rmAddAreaTerrainLayer(id, "SnowGrass50", 2, 5);
			rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 2);
		} else {
			rmSetAreaTerrainType(id, "GrassDirt25");
			rmAddAreaTerrainLayer(id, "GrassDirt50", 2, 5);
			rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 2);
		}
	}
	
	// Build the areas.
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int patchConstraint=rmCreateClassDistanceConstraint("avoid patch", classPatch, 10.0);
	int patchCenterConstraint=rmCreateClassDistanceConstraint("patch don't mess up center", rmClassID("center"), 30.0);
	
	int failCount=0;
	for(i=1; <cNumberPlayers*4*mapSizeMultiplier) {
		int id2=rmCreateArea("large patch "+i);
		rmSetAreaSize(id2, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(400*mapSizeMultiplier));
		if(terrainChance == 0) {
			rmSetAreaTerrainType(id2, "GrassDirt50");
		} else if(terrainChance == 1) {
			rmSetAreaTerrainType(id2, "GrassDirt50");
			rmAddAreaTerrainLayer(id2, "GrassDirt75", 0, 3);
		} else {
			rmSetAreaTerrainType(id2, "SnowGrass50");
			rmAddAreaTerrainLayer(id2, "SnowGrass25", 0, 3);
		}
		rmAddAreaToClass(id2, classPatch);
		rmAddAreaConstraint(id2, patchConstraint);
		rmAddAreaConstraint(id2, patchCenterConstraint);
		rmAddAreaConstraint(id2, playerConstraint);
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		if(rmBuildArea(id2)==false) {
			// Stop trying once we fail 20 times in a row.
			failCount++;
			if(failCount==20) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	failCount=0;
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier) {
		int id3=rmCreateArea("small patch "+i);
		rmSetAreaSize(id3, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
		if(terrainChance == 0) {
			rmSetAreaTerrainType(id3, "GrassDirt25");
		} else if(terrainChance == 1) {
			rmSetAreaTerrainType(id3, "SandD");
		} else {
			rmSetAreaTerrainType(id3, "SnowB");
		}
		rmAddAreaToClass(id3, classPatch);
		rmAddAreaConstraint(id3, patchConstraint);
		rmAddAreaConstraint(id3, playerConstraint);
		rmAddAreaConstraint(id3, patchCenterConstraint);
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		
		if(rmBuildArea(id3)==false) {
			// Stop trying once we fail 20 times in a row.
			failCount++;
			if(failCount==20) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	// prettier ice if Norse
	for(i=1; <cNumberPlayers*6*mapSizeMultiplier) {
		int icePatch=rmCreateArea("more ice terrain"+i, centerID);
		rmSetAreaSize(icePatch, 0.01, 0.02);
		rmSetAreaTerrainType(icePatch, "IceB");
		rmAddAreaTerrainLayer(icePatch, "IceA", 0, 3);
		rmSetAreaCoherence(icePatch, 0.0);
		if(terrainChance == 2) {
			rmBuildArea(icePatch);
		}
	}
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0+(4*cMapSize));
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	
	// Fish if Egyptian
	if(terrainChance == 1){
		
		int fishID=rmCreateObjectDef("fish");
		rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
		rmSetObjectDefMinDistance(fishID, 0.0);
		rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(fishID, fishVsFishID);
		rmAddObjectDefConstraint(fishID, fishLand);
		rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);
		
		fishID=rmCreateObjectDef("fish2");
		rmAddObjectDefItem(fishID, "fish - perch", 2, 6.0);
		rmSetObjectDefMinDistance(fishID, 0.0);
		rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(fishID, fishVsFishID);
		rmAddObjectDefConstraint(fishID, fishLand);
		rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1*cNumberNonGaiaPlayers*mapSizeMultiplier);
		
		int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 30.0);
		int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 30.0);
		int sharkID=rmCreateObjectDef("shark");
		rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
		rmSetObjectDefMinDistance(sharkID, 0.0);
		rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(sharkID, sharkVssharkID);
		rmAddObjectDefConstraint(sharkID, sharkLand);
		rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, 0.5*cNumberNonGaiaPlayers*mapSizeMultiplier);
	}
	
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	
	int numTries=6*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, centerConstraint);
		
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
	
	numTries=7*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, centerConstraint);
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 10 times in a row.
			failCount++;
			if(failCount==10) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	// Ruins
	int ruinID=0;
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
	
	ruinID=rmCreateArea("ruins");
	rmSetAreaSize(ruinID, rmAreaTilesToFraction(300*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
	rmSetAreaLocation(ruinID, 0.5, 0.5);
	if(terrainChance == 0){
		rmSetAreaTerrainType(ruinID, "GreekRoadA");
		rmAddAreaTerrainLayer(ruinID, "GrassDirt25", 0, 1);
	} else if(terrainChance == 1) {
		rmSetAreaTerrainType(ruinID, "EgyptianRoadA");
	}
	rmSetAreaMinBlobs(ruinID, 1*mapSizeMultiplier);
	rmSetAreaMaxBlobs(ruinID, 1*mapSizeMultiplier);
	rmSetAreaCoherence(ruinID, 0.8);
	rmSetAreaSmoothDistance(ruinID, 10);
	rmBuildArea(ruinID);
	
	int shadeID=rmCreateObjectDef("shade "+i);
	rmAddObjectDefItem(shadeID, "shade of erebus", 1, 0.0);
	rmSetObjectDefMinDistance(shadeID, 0.0);
	rmSetObjectDefMaxDistance(shadeID, 0.0);
	rmPlaceObjectDefInArea(shadeID, 0, rmAreaID("ruins"), 6);
	
	for(i=0; < rmRandInt(3,6)*mapSizeMultiplier){
		int brokenRuinID=rmCreateObjectDef("ruins "+i);
		rmAddObjectDefItem(brokenRuinID, "ruins", 1, 0.0);
		rmSetObjectDefMinDistance(brokenRuinID, 0.0);
		rmSetObjectDefMaxDistance(brokenRuinID, 0.0);
		rmAddObjectDefConstraint(brokenRuinID, shortAvoidBuildings);
		rmAddObjectDefConstraint(brokenRuinID, avoidAll);
		if(terrainChance < 2)
		rmPlaceObjectDefInArea(brokenRuinID, 0, rmAreaID("ruins"), 1);
	}
	
	for(i=0; < rmRandInt(4,8)*mapSizeMultiplier){
		int columnID=rmCreateObjectDef("columns "+i);
		rmAddObjectDefItem(columnID, "columns broken", 1, 0.0);
		rmSetObjectDefMinDistance(columnID, 0.0);
		rmSetObjectDefMaxDistance(columnID, 0.0);
		rmAddObjectDefConstraint(columnID, shortAvoidBuildings);
		rmAddObjectDefConstraint(columnID, avoidAll);
		if(terrainChance < 2)
		rmPlaceObjectDefInArea(columnID, 0, rmAreaID("ruins"), 1);
	}
	
	for(i=0; < 12*mapSizeMultiplier){
		int skeletonID=rmCreateObjectDef("skeleton "+i);
		rmAddObjectDefItem(skeletonID, "skeleton", 1, 0.0);
		rmSetObjectDefMinDistance(skeletonID, 0.0);
		rmSetObjectDefMaxDistance(skeletonID, 0.0);
		rmPlaceObjectDefInArea(skeletonID, 0, rmAreaID("ruins"), 1);
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 40.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	
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
	
	int farID = -1;
	int closeID = -1;
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 50.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			//Add a new FairLoc every time. This will have to be removed before the next FairLoc is created.
			id=rmAddFairLoc("Settlement", false, true, 55, 60, 40, 16, true); /* bool forward bool inside */
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidStart);
			if(terrainChance == 2) {
				rmAddFairLocConstraint(id, centerConstraint);
			}
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				if(terrainChance == 0) {
					rmSetAreaTerrainType(settleArea, "GrassDirt50");
				} else if(terrainChance == 1) {
					rmSetAreaTerrainType(settleArea, "GrassDirt50");
					rmAddAreaTerrainLayer(settleArea, "GrassDirt75", 0, 3);
				} else {
					rmSetAreaTerrainType(settleArea, "SnowGrass50");
					rmAddAreaTerrainLayer(settleArea, "SnowGrass25", 0, 3);
				}
				rmBuildArea(settleArea);
			}
			//Remove the FairLoc that we just created
			rmResetFairLocs();
		
			//Do it again.
			//Add a new FairLoc every time. This will have to be removed at the end of the block.
			id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.29), rmXFractionToMeters(0.32), 40, 16);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidStart);
			rmAddFairLocConstraint(id, TCavoidWater);
			if(terrainChance == 2) {
				rmAddFairLocConstraint(id, centerConstraint);
			}
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				if(terrainChance == 0) {
					rmSetAreaTerrainType(settlementArea, "GrassDirt50");
				} else if(terrainChance == 1) {
					rmSetAreaTerrainType(settlementArea, "GrassDirt50");
					rmAddAreaTerrainLayer(settlementArea, "GrassDirt75", 0, 3);
				} else {
					rmSetAreaTerrainType(settlementArea, "SnowGrass50");
					rmAddAreaTerrainLayer(settlementArea, "SnowGrass25", 0, 3);
				}
				rmBuildArea(settlementArea);
			}
			rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
		}
	} else {
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidImpassableLand);
			if(terrainChance == 2) {
				rmAddFairLocConstraint(closeID, centerConstraint);
			}
			for(attempt = 5; <= 10){
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
			if(terrainChance == 2) {
				rmAddFairLocConstraint(farID, centerConstraint);
			}
			for(attempt = 5; < 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 12*attempt);
			}
		}
	}
		
	if(cMapSize == 2){
		//And one last time if Giant.
		id=rmAddFairLoc("Settlement", false, true,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.4), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		if(terrainChance == 2) {
			rmAddFairLocConstraint(id, centerConstraint);
		}
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.35), rmXFractionToMeters(0.4), 70, 16);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		if(terrainChance == 2) {
			rmAddFairLocConstraint(id, centerConstraint);
		}
		
		if(rmPlaceFairLocs()){
			for(p = 1; <= cNumberNonGaiaPlayers){
				for(FL = 0; < 2){
					id=rmCreateObjectDef("Giant settlement_"+p+"_"+FL);
					rmAddObjectDefItem(id, "Settlement", 1, 1.0);
					
					int settlementArea2 = rmCreateArea("other_settlement_area_"+p+"_"+FL);
					rmSetAreaLocation(settlementArea2, rmFairLocXFraction(p, FL), rmFairLocZFraction(p, FL));
					rmSetAreaSize(settlementArea2, 0.005, 0.005);
					if(terrainChance == 0) {
						rmSetAreaTerrainType(settlementArea2, "GrassDirt50");
					} else if(terrainChance == 1) {
						rmSetAreaTerrainType(settlementArea2, "GrassDirt50");
						rmAddAreaTerrainLayer(settlementArea2, "GrassDirt75", 0, 3);
					} else {
						rmSetAreaTerrainType(settlementArea2, "SnowGrass50");
						rmAddAreaTerrainLayer(settlementArea2, "SnowGrass25", 0, 3);
					}
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
				if(terrainChance == 2) {
					rmAddFairLocConstraint(farID, centerConstraint);
				}
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
				if(terrainChance == 2) {
					rmAddFairLocConstraint(farID, centerConstraint);
				}
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

	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	if(terrainChance == 1){
		rmAddObjectDefItem(startingHuntableID, "rhinocerous", 2, 4.0);
	} else {
		rmAddObjectDefItem(startingHuntableID, "boar", 4, 4.0);
	}
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 27.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 22.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	
	float pigNumber=rmRandFloat(2, 4);
	int closePigsID=rmCreateObjectDef("close pigs");
	rmAddObjectDefItem(closePigsID, "pig", pigNumber, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 22.0);
	rmSetObjectDefMaxDistance(closePigsID, 28.0);
	rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closePigsID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmPlaceObjectDefPerPlayer(closePigsID, true);

	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(6,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	rmPlaceObjectDefPerPlayer(startingChickenID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	if(terrainChance == 0) {
		rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	} else {
		rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
	}
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("tree avoid all", "all", 3.0));
	if(avoidIce==1) {
		rmAddObjectDefConstraint(stragglerTreeID, centerConstraint);
	}
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	
	int playerFishID=rmCreateObjectDef("owned fish");
	rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 10.0);
	rmSetObjectDefMinDistance(playerFishID, 50.0);
	rmSetObjectDefMaxDistance(playerFishID, 70.0*mapSizeMultiplier);
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, fishLand);
	if(terrainChance == 1){
		rmPlaceObjectDefPerPlayer(playerFishID, false);
	}
	
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
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(25+cNumberNonGaiaPlayers), rmAreaTilesToFraction(50+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			if(terrainChance == 0) {
				rmSetAreaForestType(playerStartingForestID, "oak forest");
			} else if(terrainChance == 2) {
				rmSetAreaForestType(playerStartingForestID, "mixed pine forest");
			} else {
				rmSetAreaForestType(playerStartingForestID, "mixed palm forest");
			}
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
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, centerConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 50.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
	rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, avoidFood);
	rmAddObjectDefConstraint(mediumPigsID, avoidGold);
	rmAddObjectDefConstraint(mediumPigsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(mediumPigsID, false, 2);
	
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
	rmAddObjectDefConstraint(farGoldID, edgeConstraint);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, centerConstraint);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 3);
	
	int farAvoidFood=rmCreateTypeDistanceConstraint("avoid huntable", "food", 35.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(terrainChance == 0) {
		rmAddObjectDefItem(bonusHuntableID, "deer", 6, 3.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(bonusHuntableID, "zebra", 6, 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "caribou", 6, 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 85.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 105.0+(10*cMapSize));	//Open it up a bit
	rmAddObjectDefConstraint(bonusHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, farAvoidFood);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidBuildings);
	rmAddObjectDefConstraint(bonusHuntableID, centerConstraint);
	rmPlaceObjectDefPerPlayer(bonusHuntableID, false);
	if(terrainChance != 1){
		rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 150.0);
	rmAddObjectDefConstraint(farPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
	rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(1,2));
	
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 60.0);
	rmSetObjectDefMaxDistance(farBerriesID, 95.0);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, farAvoidFood);
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farBerriesID, centerConstraint);
	rmPlaceObjectDefPerPlayer(farBerriesID, false);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 70.0);
	rmSetObjectDefMaxDistance(relicID, 115.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmAddObjectDefConstraint(relicID, centerConstraint);
	rmPlaceObjectDefPerPlayer(relicID, false);
	
	
	int randomTreeID=rmCreateObjectDef("random tree");
	if(terrainChance == 0) {
		rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	} else {
		rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
	}
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	if(terrainChance == 2) {
		rmAddObjectDefConstraint(randomTreeID, centerConstraint);
	}
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
	
		int farAvoidHunt=rmCreateTypeDistanceConstraint("giant avoid huntable", "huntable", 60.0);
	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 138", "gold", 60.0));
		if(cNumberNonGaiaPlayers == 2){
			rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.45));
		}
		if(terrainChance == 2) {
			rmAddObjectDefConstraint(giantGoldID, centerConstraint);
			rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.45));
			if(cNumberNonGaiaPlayers == 2){
				rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.35));
				rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.5));
			}
		}
		if(cNumberNonGaiaPlayers == 2){
			rmPlaceObjectDefPerPlayer(giantGoldID, false, 6);
		} else {
			rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(4, 5));
		}
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(terrainChance == 0) {
			rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(6,8), 4.0);
		} else if(terrainChance == 1) {
			rmAddObjectDefItem(giantHuntableID, "zebra", rmRandInt(6,8), 4.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(6,8), 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.27));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, farAvoidHunt);
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidBuildings);
		rmAddObjectDefConstraint(giantHuntableID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		if(terrainChance == 0) {
			rmAddObjectDefItem(giantHuntable2ID, "deer", rmRandInt(6,8), 4.0);
		} else if(terrainChance == 1) {
			rmAddObjectDefItem(giantHuntable2ID, "zebra", rmRandInt(6,8), 4.0);
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "caribou", rmRandInt(6,8), 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntable2ID, farAvoidHunt);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidBuildings);
		rmAddObjectDefConstraint(giantHuntable2ID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, 1.5*cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 22.0);
	int forestSettleConstraint=rmCreateTypeDistanceConstraint("forest settle", "AbstractSettlement", 20.0);
	int forestCount=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.75*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount){
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(125), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		if(terrainChance == 0) {
			rmSetAreaForestType(forestID, "oak forest");
		} else if(terrainChance == 2) {
			rmSetAreaForestType(forestID, "mixed pine forest");
		} else {
			rmSetAreaForestType(forestID, "mixed palm forest");
		}
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, centerConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
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

	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	if(terrainChance == 0) {
		rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	}
	
	int rockID=rmCreateObjectDef("rock and grass");
	int avoidRock0=rmCreateTypeDistanceConstraint("avoid rock 0", "rock limestone sprite", 8.0);
	int avoidRock1=rmCreateTypeDistanceConstraint("avoid rock 1", "rock sandstone sprite", 8.0);
	int avoidRock2=rmCreateTypeDistanceConstraint("avoid rock 2", "rock granite sprite", 8.0);
	
	if(terrainChance == 0) { /* Greek */
		rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
	} else if(terrainChance == 1) { /* E */
		rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 1.0);
	} else {
		rmAddObjectDefItem(rockID, "rock granite sprite", 1, 1.0);
	}
	rmAddObjectDefItem(rockID, "grass", 2, 1.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, avoidRock0);
	rmAddObjectDefConstraint(rockID, avoidRock1);
	rmAddObjectDefConstraint(rockID, avoidRock2);
	if(terrainChance == 2) {
		rmAddObjectDefConstraint(rockID, centerConstraint);
	}
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers);
	
	int rockID2=rmCreateObjectDef("rock group");
	if(terrainChance == 0) {
		rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(rockID2, "rock sandstone sprite", 3, 2.0);
	} else{
		rmAddObjectDefItem(rockID2, "rock granite sprite", 3, 2.0);
	}
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock0);
	rmAddObjectDefConstraint(rockID2, avoidRock1);
	rmAddObjectDefConstraint(rockID2, avoidRock2);
	if(terrainChance == 2) {
		rmAddObjectDefConstraint(rockID2, centerConstraint);
	}
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
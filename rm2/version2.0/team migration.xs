/*	Map Name: Team Migration.xs
**	Fast-Paced Ruleset: Midgard.xs
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
	int playerTiles=16000;
	if(cMapSize == 1) {
		playerTiles = 20800;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 32600;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmSetSeaType("mediterranean sea");
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classCliff = rmDefineClass("cliff");
	int bonusIslandClass = rmDefineClass("bonus island");
	int islandClass = rmDefineClass("islandClass");
	int teamIslandClass = rmDefineClass("teamIslandClass");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classForest=rmDefineClass("forest");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int centerAvoidance = 0;
	if(cNumberPlayers < 5) {
		centerAvoidance = 30;
	} else {
		centerAvoidance = 40;
	}
	
	rmSetTeamSpacingModifier(0.5);
	if(cNumberNonGaiaPlayers < 4) {
		rmPlacePlayersSquare(0.30, 0.05, 0.05);
	} else {
		rmPlacePlayersSquare(0.35, 0.05, 0.05);
	}
	rmRecordPlayerLocations();
	
	int islandConstraint=rmCreateClassDistanceConstraint("islands avoid each other", islandClass, 20.0);
	int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid big island", bonusIslandClass, centerAvoidance);
	int playerIslandConstraint=rmCreateClassDistanceConstraint("avoid player islands", islandClass, centerAvoidance);
	int teamEdgeConstraint=rmCreateBoxConstraint("island edge of map", rmXTilesToFraction(16), rmZTilesToFraction(16), 1.0-rmXTilesToFraction(16), 1.0-rmZTilesToFraction(16), 0.01);
	
	float percentPerPlayer = 0.2/cNumberNonGaiaPlayers;
	float teamSize = 0;
	
	for(i=0; <cNumberTeams) {
		int teamID=rmCreateArea("team"+i);
		teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
		rmEchoInfo ("team size "+teamSize);
		rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
		rmSetAreaWarnFailure(teamID, false);
		rmSetAreaTerrainType(teamID, "GrassA");
		rmAddAreaTerrainLayer(teamID, "GrassDirt25", 4, 8);
		rmAddAreaTerrainLayer(teamID, "GrassDirt50", 2, 4);
		rmAddAreaTerrainLayer(teamID, "GrassDirt75", 1, 2);
		rmSetAreaMinBlobs(teamID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(teamID, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(teamID, 16.0);
		rmSetAreaMaxBlobDistance(teamID, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(teamID, 0.4);
		rmSetAreaSmoothDistance(teamID, 10);
		rmSetAreaBaseHeight(teamID, 1.0);
		rmSetAreaHeightBlend(teamID, 2);
		rmAddAreaToClass(teamID, islandClass);
		rmAddAreaToClass(teamID, teamIslandClass);
		rmAddAreaConstraint(teamID, islandConstraint);
		rmAddAreaConstraint(teamID, bonusIslandConstraint);
		rmAddAreaConstraint(teamID, teamEdgeConstraint);
		rmSetAreaLocTeam(teamID, i);
		rmEchoInfo("Team area"+i);
	}
	
	int bonusID=rmCreateArea("bonus island");
	rmSetAreaSize(bonusID, 0.2+(0.05*mapSizeMultiplier), 0.2+(0.05*mapSizeMultiplier));
	rmAddAreaToClass(bonusID, islandClass);
	rmSetAreaWarnFailure(bonusID, false);
	rmSetAreaLocation(bonusID, 0.5, 0.5);
	rmSetAreaMinBlobs(bonusID, 1*mapSizeMultiplier);
	rmSetAreaMaxBlobs(bonusID, 5*mapSizeMultiplier);
	rmSetAreaMinBlobDistance(bonusID, 16.0);
	rmSetAreaMaxBlobDistance(bonusID, 40.0*mapSizeMultiplier);
	rmSetAreaCoherence(bonusID, 0.0);
	rmSetAreaSmoothDistance(bonusID, 10);
	rmSetAreaBaseHeight(bonusID, 1.0);
	rmSetAreaHeightBlend(bonusID, 2);
	rmAddAreaToClass(bonusID, bonusIslandClass);
	rmAddAreaConstraint(bonusID, playerIslandConstraint);
	rmAddAreaConstraint(bonusID, teamEdgeConstraint);
	if(cNumberTeams == 2) {
		rmAddAreaConstraint(bonusID, rmCreateBoxConstraint("avoid arms in center island with 2 teams", rmXTilesToFraction(25), rmZTilesToFraction(25), 1.0-rmXTilesToFraction(25), 1.0-rmZTilesToFraction(25), 0.01));
	} else {
		rmAddAreaConstraint(bonusID, rmCreateBoxConstraint("avoid arms in center island with 3 teams", rmXTilesToFraction(40), rmZTilesToFraction(40), 1.0-rmXTilesToFraction(40), 1.0-rmZTilesToFraction(40), 0.01));
	}
	rmSetAreaTerrainType(bonusID, "GrassA");
	rmAddAreaTerrainLayer(bonusID, "GrassDirt25", 6, 10);
	rmAddAreaTerrainLayer(bonusID, "GrassDirt50", 3, 6);
	rmAddAreaTerrainLayer(bonusID, "GrassDirt75", 1, 3);
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);
	
	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
		rmEchoInfo("Player"+i+"team"+rmGetPlayerTeam(i));
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, 0.025, 0.025);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(id, 10.0);
		rmSetAreaMaxBlobDistance(id, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(id, 0.5);
		rmAddAreaConstraint(id, playerConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaWarnFailure(id, false);
		rmSetAreaTerrainType(id, "GrassA");
	}
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	for(i=1; <cNumberPlayers*mapSizeMultiplier) {
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, "GrassDirt75");
		rmAddAreaTerrainLayer(id2, "GrassDirt50", 2, 3);
		rmAddAreaTerrainLayer(id2, "GrassDirt25", 0, 2);
		rmSetAreaMinBlobs(id2, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id2, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id2, 0.0);
		rmBuildArea(id2);
	}
	
	for(i=1; <cNumberPlayers*12*mapSizeMultiplier) {
		int id4=rmCreateArea("Grass patch 2"+i, bonusID);
		rmSetAreaSize(id4, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaTerrainType(id4, "GrassDirt75");
		rmAddAreaTerrainLayer(id4, "GrassDirt50", 2, 3);
		rmAddAreaTerrainLayer(id4, "GrassDirt25", 0, 2);
		rmSetAreaMinBlobs(id4, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id4, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id4, false);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id4, 0.0);
		rmBuildArea(id4);
	}
	
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier) {
		int id3=rmCreateArea("Grass patch"+i, bonusID);
		rmSetAreaSize(id3, rmAreaTilesToFraction(5*mapSizeMultiplier), rmAreaTilesToFraction(20*mapSizeMultiplier));
		rmSetAreaTerrainType(id3, "GrassB");
		rmSetAreaMinBlobs(id3, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(id3, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure(id3, false);
		rmSetAreaMinBlobDistance(id3, 16.0);
		rmSetAreaMaxBlobDistance(id3, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(id3, 0.0);
		rmBuildArea(id3);
	}
	
	// Draw cliffs
	int islandShoreConstraint = rmCreateEdgeDistanceConstraint("bonus island edge", bonusID, 16.0);
	int numCliffs = rmRandInt(1,2);
	if(cNumberNonGaiaPlayers > 3) {
		numCliffs = rmRandInt(2,4);
	} else if (cNumberNonGaiaPlayers > 5) {
		numCliffs = rmRandInt(4,6);
	}
	
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0);
	
	for(i=0; <numCliffs*mapSizeMultiplier) {
		int cliffID=rmCreateArea("cliff"+i, bonusID);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(400*mapSizeMultiplier));
		rmSetAreaCliffType(cliffID, "Greek");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, islandShoreConstraint);
		rmAddAreaToClass(cliffID, classCliff);
		rmSetAreaMinBlobs(cliffID, 10*mapSizeMultiplier);
		rmSetAreaMaxBlobs(cliffID, 10*mapSizeMultiplier);
		int edgeRand=rmRandInt(0,100);
		if(edgeRand<33) {
			// Inaccesible
			rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
			rmSetAreaTerrainType(cliffID, "cliffGreekA");
		} else {
			// AOK style
			rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
		}
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		
		rmSetAreaMinBlobDistance(cliffID, 20.0);
		rmSetAreaMaxBlobDistance(cliffID, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(cliffID, 0.0);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		rmBuildArea(cliffID);
	}
	
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 8.0);
	
	for(i=1; <cNumberPlayers){
		int failCount=0;
		int num=rmRandInt(2, 4);
		for(j=0; <num){
			int elevID=rmCreateArea("elev"+i+", "+j, rmAreaID("player"+i));
			rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
			rmSetAreaWarnFailure(elevID, false);
			rmAddAreaConstraint(elevID, avoidBuildings);
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
				if(failCount==3){
					break;
				}
			} else {
				failCount=0;
			}
		}
	}
	
	failCount=0;
	num=rmRandInt(5, 10);
	for(j=0; <num) {
		elevID=rmCreateArea("elev"+j, bonusID);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		if(rmRandFloat(0.0, 1.0)<0.7) {
			rmSetAreaTerrainType(elevID, "GrassDirt50");
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 3.5));
		
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		if(rmBuildArea(elevID)==false) {
			// Stop trying once we fail 5 times in a row.
			failCount++;
			if(failCount==5) {
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
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 70.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid bonus huntable", "huntable", 40.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);

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
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int getOffTheTC = rmCreateTypeDistanceConstraint("Stop starting resources from somehow spawning on top of TC!", "AbstractSettlement", 16.0);
	
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "hippo", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, getOffTheTC);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 14.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int closePigsID=rmCreateObjectDef("close pigs");
	rmAddObjectDefItem(closePigsID, "pig", 2, 2.0);
	rmSetObjectDefMinDistance(closePigsID, 20.0);
	rmSetObjectDefMaxDistance(closePigsID, 22.0);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmAddObjectDefConstraint(closePigsID, getOffTheTC);
	rmAddObjectDefConstraint(closePigsID, huntShortAvoidsStartingGoldMilky);
	rmPlaceObjectDefPerPlayer(closePigsID, true);
	
	int numChicken = 0;
	int numBerry = 0;
	float berryChance = rmRandFloat(0,1);
	if(berryChance < 0.25) {
		numChicken = 5;
		numBerry = 4;
	} else if(berryChance < 0.75) {
		numChicken = 8;
		numBerry = 6;
	} else {
		numChicken = 12;
		numBerry = 9;
	}
	int chickenShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short birdy avoid gold", "gold", 10.0);
	int startingChickenID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingChickenID, "Chicken", rmRandInt(5,10), 3.0);
	rmSetObjectDefMaxDistance(startingChickenID, 20.0);
	rmSetObjectDefMaxDistance(startingChickenID, 23.0);
	rmAddObjectDefConstraint(startingChickenID, chickenShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingChickenID, getOffTheTC);
	rmAddObjectDefConstraint(startingChickenID, avoidFood);
	
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 21.0);
	rmSetObjectDefMaxDistance(startingBerryID, 26.0);
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid gold", "gold", 10.0));
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid TC", "AbstractSettlement", 20.0));
	
	if(rmRandFloat(0.0, 1.0)<0.5) {
		rmPlaceObjectDefPerPlayer(startingChickenID, false);
	} else {
		rmPlaceObjectDefAtLoc(startingBerryID, false);
	}
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("trees avoid all", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
	
	int transportNearShore=rmCreateTerrainMaxDistanceConstraint("transport near shore", "land", true, 9.0);
	int transportGreekID=rmCreateObjectDef("transport greek");
	rmAddObjectDefItem(transportGreekID, "transport ship greek", 1, 0.0);
	rmSetObjectDefMinDistance(transportGreekID, 0.0);
	rmSetObjectDefMaxDistance(transportGreekID, 70.0);
	rmAddObjectDefConstraint(transportGreekID, transportNearShore);
	
	int transportNorseID=rmCreateObjectDef("transport Norse");
	rmAddObjectDefItem(transportNorseID, "transport ship Norse", 1, 0.0);
	rmSetObjectDefMinDistance(transportNorseID, 0.0);
	rmSetObjectDefMaxDistance(transportNorseID, 70.0);
	rmAddObjectDefConstraint(transportNorseID, transportNearShore);
	
	int transportEgyptianID=rmCreateObjectDef("transport Egyptian");
	rmAddObjectDefItem(transportEgyptianID, "transport ship Egyptian", 1, 0.0);
	rmSetObjectDefMinDistance(transportEgyptianID, 0.0);
	rmSetObjectDefMaxDistance(transportEgyptianID, 70.0);
	rmAddObjectDefConstraint(transportEgyptianID, transportNearShore);
	
	int transportAtlanteanID=rmCreateObjectDef("transport Atlantean");
	rmAddObjectDefItem(transportAtlanteanID, "transport ship Atlantean", 1, 0.0);
	rmSetObjectDefMinDistance(transportAtlanteanID, 0.0);
	rmSetObjectDefMaxDistance(transportAtlanteanID, 70.0);
	rmAddObjectDefConstraint(transportAtlanteanID, transportNearShore);
	
	int transportChineseID=rmCreateObjectDef("transport Chinese");
	rmAddObjectDefItem(transportChineseID, "Transport Ship Chinese", 1, 0.0);
	rmSetObjectDefMinDistance(transportChineseID, 0.0);
	rmSetObjectDefMaxDistance(transportChineseID, 70.0);
	rmAddObjectDefConstraint(transportChineseID, transportNearShore);
	
	//Transport Placement
	for(i=0; <cNumberPlayers){
		if(rmGetPlayerCulture(i) == cCultureGreek) {
			rmPlaceObjectDefAtLoc(transportGreekID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureNorse) {
			rmPlaceObjectDefAtLoc(transportNorseID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureEgyptian) {
			rmPlaceObjectDefAtLoc(transportEgyptianID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureAtlantean) {
			rmPlaceObjectDefAtLoc(transportAtlanteanID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureChinese) {
			rmPlaceObjectDefAtLoc(transportChineseID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		}
	}
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 24.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);
	int fishShore = rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 8.0);
	int playerFishID=rmCreateObjectDef("near fish");
	rmAddObjectDefItem(playerFishID, "fish - mahi", 1, 0.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 70.0);
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, fishShore);
	rmPlaceObjectDefPerPlayer(playerFishID, false, 6);
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 4.0);
	int forestTerrain = rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 1.0);
	int forestTC = rmCreateClassDistanceConstraint("starting forest vs starting settle", classStartingSettlement, 15.0);
	int forestOtherTCs = rmCreateTypeDistanceConstraint("starting forest vs settle", "AbstractSettlement", 2.0);
	
	int maxNum = 5;
	for(p=1;<=cNumberNonGaiaPlayers){
	
		placePointsCircleCustom(rmXMetersToFraction(45.0), maxNum, -1.0, -1.0, rmGetPlayerX(p), rmGetPlayerZ(p), false, false);
		
		for(i=1; <= maxNum){
			int playerStartingForestID=rmCreateArea("player "+p+" forest "+i);
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			rmSetAreaForestType(playerStartingForestID, "palm forest");
			rmAddAreaConstraint(playerStartingForestID, forestOtherTCs);
			rmAddAreaConstraint(playerStartingForestID, forestTC);
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
	
	for(p = 1; <= cNumberNonGaiaPlayers){
		int medSettlementID=rmCreateObjectDef("med settlement"+p);
		rmAddObjectDefItem(medSettlementID, "Settlement", 1, 0.0);
		rmSetObjectDefMinDistance(medSettlementID, 55.0);
		if(cNumberNonGaiaPlayers == 2){
			rmSetObjectDefMaxDistance(medSettlementID, 60.0);
		} else {
			rmSetObjectDefMaxDistance(medSettlementID, 70+cNumberNonGaiaPlayers);
		}
		if(cMapSize == 2){
			rmAddObjectDefConstraint(medSettlementID, rmCreateTypeDistanceConstraint("medSet avoids medSet by long distance1", "AbstractSettlement", 55.0));
		} else {
			rmAddObjectDefConstraint(medSettlementID, rmCreateTypeDistanceConstraint("medSet avoids medSet by long distance2", "AbstractSettlement", 40.0));
		}
		rmAddObjectDefConstraint(medSettlementID, rmCreateTerrainDistanceConstraint("MedSet avoids impassable land", "Land", false, 20.0));
		rmAddObjectDefConstraint(medSettlementID, rmCreateAreaConstraint("set stay in island player"+p, rmAreaID("team"+rmGetPlayerTeam(p))));
		rmPlaceObjectDefAtLoc(medSettlementID, 0, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
	}
	
	int avoidForest = rmCreateClassDistanceConstraint("avoid forest", rmClassID("forest"), 3.0);
	
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 35.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0+(cNumberNonGaiaPlayers*2));
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, avoidForest);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	int mediumPigsID=rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(mediumPigsID, 30.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 50.0);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, avoidFood);
	rmAddObjectDefConstraint(mediumPigsID, avoidForest);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(mediumPigsID, 0, rmGetPlayerX(i), rmGetPlayerZ(i), 2);
	}
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int teamIslandConstraint=rmCreateClassDistanceConstraint("far Set vs team islands", teamIslandClass, 20.0);
	int farSettlementID=rmCreateObjectDef("far settlement");
	rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
	rmSetObjectDefMinDistance(farSettlementID, 0.0);
	rmSetObjectDefMaxDistance(farSettlementID, 200.0 + (10*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farSettlementID, avoidImpassableLand);
	rmAddObjectDefConstraint(farSettlementID, teamIslandConstraint);
	if(cMapSize < 2){
		rmAddObjectDefConstraint(farSettlementID, rmCreateTypeDistanceConstraint("island Settle vs island Settle1", "AbstractSettlement", 50.0));
	} else {
		rmAddObjectDefConstraint(farSettlementID, rmCreateTypeDistanceConstraint("island Settle vs island Settle2", "AbstractSettlement", 65.0));
	}
	//New way to place TC's. Places them 1 at a time.
	//This way ensures that TC's will never be too close.
	for(p = 1; <= cNumberNonGaiaPlayers){
		for(TCplace = 0; < 1*mapSizeMultiplier){
			rmPlaceObjectDefAtLoc(farSettlementID, 0, 0.5, 0.5, 1);
		}
	}
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	if(rmRandFloat(0,1) < 0.5){
		rmSetObjectDefMinDistance(farGoldID, 75.0);
		rmSetObjectDefMaxDistance(farGoldID, 80.0 + (cNumberNonGaiaPlayers*3));
		rmPlaceObjectDefPerPlayer(farGoldID, false, cNumberTeams);
	} else {
		rmSetObjectDefMinDistance(farGoldID, 0.0);
		rmSetObjectDefMaxDistance(farGoldID, 70.0 + (cNumberTeams*7));
		rmPlaceObjectDefInArea(farGoldID, 0, bonusID, rmRandInt(2,3)*cNumberNonGaiaPlayers);
	}
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.2) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", 4, 4.0);
		rmAddObjectDefItem(bonusHuntableID, "zebra", 3, 4.0);
	} else if(bonusChance<0.4) {
		rmAddObjectDefItem(bonusHuntableID, "giraffe", 6, 8.0);
	} else if(bonusChance<0.6) {
		rmAddObjectDefItem(bonusHuntableID, "water buffalo", 4, 4.0);
	} else if(bonusChance<0.8) {
		rmAddObjectDefItem(bonusHuntableID, "rhinocerous", 2, 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "rhinocerous", 3, 3.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);
	rmPlaceObjectDefInArea(bonusHuntableID, 0, bonusID, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 100.0 + (7*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(1,2));
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "lion", 4, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 70.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0 + (3*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 163", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 163", "AbstractSettlement", 40.0));
	rmPlaceObjectDefInArea(farPredatorID, 0, bonusID, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	rmPlaceObjectDefInArea(relicID, 0, bonusID, cNumberNonGaiaPlayers);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int lineFishID=rmCreateObjectDef("line fish");
	rmAddObjectDefItem(lineFishID, "fish - Mahi", 3, 16.0);
	rmSetObjectDefMinDistance(lineFishID, 0.0);
	rmSetObjectDefMaxDistance(lineFishID, 0.0);
	
	rmPlaceObjectDefInLineX(lineFishID, 0, 2+cNumberTeams, 0.97, 0.0, 1.0, 0.015);
	rmPlaceObjectDefInLineX(lineFishID, 0, 2+cNumberTeams, 0.03, 0.0, 1.0, 0.015);
	rmPlaceObjectDefInLineZ(lineFishID, 0, 2+cNumberTeams, 0.97, 0.0, 1.0, 0.015);
	rmPlaceObjectDefInLineZ(lineFishID, 0, 2+cNumberTeams, 0.03, 0.0, 1.0, 0.015);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers+cNumberTeams);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.26));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantGoldID, avoidFood);
		rmAddObjectDefConstraint(giantGoldID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 163", "gold", 35.0));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(bonusChance<0.2) {
			rmAddObjectDefItem(giantHuntableID, "giraffe", 4, 4.0);
			rmAddObjectDefItem(giantHuntableID, "zebra", 3, 5.0);
		} else if(bonusChance<0.4) {
			rmAddObjectDefItem(giantHuntableID, "giraffe", 6, 8.0);
		} else if(bonusChance<0.6) {
			rmAddObjectDefItem(giantHuntableID, "water buffalo", 4, 4.0);
		} else if(bonusChance<0.8) {
			rmAddObjectDefItem(giantHuntableID, "rhinocerous", 2, 3.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "rhinocerous", 3, 3.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidImpassableLand);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, farStartingSettleConstraint);
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int avoidImpassableLand2=rmCreateTerrainDistanceConstraint("avoid impassable land2", "Land", false, 4.0);
	int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 16.0);
	
	int forestCount=rmRandInt(cNumberNonGaiaPlayers, cNumberNonGaiaPlayers*2) + 1;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	
	for(i=1; <cNumberPlayers) {
		
		for(j=0; <forestCount) {
			int forestID=rmCreateArea("bonus "+i+"forest "+j, bonusID);
			rmSetAreaSize(forestID, rmAreaTilesToFraction(25+(5*cNumberNonGaiaPlayers)), rmAreaTilesToFraction(100+(2*cNumberNonGaiaPlayers)));
			if(cMapSize == 2){
				rmSetAreaSize(forestID, rmAreaTilesToFraction(125), rmAreaTilesToFraction(200));
			}
			
			rmSetAreaWarnFailure(forestID, false);
			if(rmRandFloat(0.0, 1.0)<0.5) {
				rmSetAreaForestType(forestID, "palm forest");
			} else {
				rmSetAreaForestType(forestID, "mixed palm forest");
			}
			rmAddAreaConstraint(forestID, shortAvoidSettlement);
			rmAddAreaConstraint(forestID, avoidImpassableLand2);
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
		
		if(cMapSize == 2){
			for(j=0; < 1+cNumberNonGaiaPlayers/2) {
				int forestPlayerIslandID=rmCreateArea("player island "+i+"forest "+j, rmAreaID("team"+rmGetPlayerTeam(i)));
				rmSetAreaSize(forestPlayerIslandID, rmAreaTilesToFraction(25+(5*cNumberNonGaiaPlayers)), rmAreaTilesToFraction(100+(2*cNumberNonGaiaPlayers)));
				
				rmSetAreaWarnFailure(forestPlayerIslandID, false);
				if(rmRandFloat(0.0, 1.0)<0.5) {
					rmSetAreaForestType(forestPlayerIslandID, "palm forest");
				} else {
					rmSetAreaForestType(forestPlayerIslandID, "mixed palm forest");
				}
				rmAddAreaConstraint(forestPlayerIslandID, shortAvoidSettlement);
				rmAddAreaConstraint(forestPlayerIslandID, avoidImpassableLand2);
				rmAddAreaConstraint(forestPlayerIslandID, forestObjConstraint);
				rmAddAreaConstraint(forestPlayerIslandID, forestConstraint2);
				rmAddAreaConstraint(forestPlayerIslandID, forestTerrain);
				rmAddAreaToClass(forestPlayerIslandID, classForest);
				rmSetAreaWarnFailure(forestPlayerIslandID, false);
				
				rmSetAreaMinBlobs(forestPlayerIslandID, 1);
				rmSetAreaMaxBlobs(forestPlayerIslandID, 5);
				rmSetAreaMinBlobDistance(forestPlayerIslandID, 16.0);
				rmSetAreaMaxBlobDistance(forestPlayerIslandID, 40.0);
				rmSetAreaCoherence(forestPlayerIslandID, 0.0);
				
				// Hill trees?
				if(rmRandFloat(0.0, 1.0)<0.2) {
					rmSetAreaBaseHeight(forestPlayerIslandID, rmRandFloat(3.0, 4.0));
				}
				rmBuildArea(forestPlayerIslandID);
			}
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
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 18*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rockID=rmCreateObjectDef("rock and grass");
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
	rmAddObjectDefItem(rockID, "grass", 2, 1.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, avoidRock);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
	int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
	int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
	int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);
	
	int sharkID=rmCreateObjectDef("shark");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
	} else {
		rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
	}
	rmSetObjectDefMinDistance(sharkID, 0.0);
	rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(sharkID, sharkVssharkID);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
	rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
	rmAddObjectDefConstraint(sharkID, sharkLand);
	rmAddObjectDefConstraint(sharkID, rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20), 0.01));
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
/*	Map Name: Vindlandsaga.xs
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
	int playerTiles=14000;
	if(cMapSize == 1) {
		playerTiles = 18000;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 36000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmSetSeaType("norwegian sea");
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer=rmDefineClass("player");
	rmDefineClass("classHill");
	rmDefineClass("classPatch");
	int classBonusIsland=rmDefineClass("big continent");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int edgeDist = 11;
	if(cNumberNonGaiaPlayers > 2){
		edgeDist = 8;
	}
	int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(edgeDist), rmZTilesToFraction(edgeDist), 1.0-rmXTilesToFraction(edgeDist), 1.0-rmZTilesToFraction(edgeDist), 0.01);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	int longAvoidImpassableLand=rmCreateTerrainDistanceConstraint("long avoid impassable land", "Land", false, 20.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	rmPlacePlayersLine(0.12, 0.15, 0.88, 0.15, 2.0, 2.0);
	if(cNumberNonGaiaPlayers > 2){
		rmPlacePlayersLine(0.08, 0.15, 0.92, 0.15, 2.0, 2.0);
	}
	rmRecordPlayerLocations();
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 12.0);
	
	playerTiles = 1000;
	float playerFraction=rmAreaTilesToFraction(playerTiles);
	for(i=1; <cNumberPlayers){
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		rmSetAreaSize(id, playerFraction, playerFraction);
		rmAddAreaToClass(id, classPlayer);
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 3);
		rmSetAreaMinBlobDistance(id, 24.0);
		rmSetAreaMaxBlobDistance(id, 24.0);
		rmSetAreaCoherence(id, 0.5);
		rmSetAreaBaseHeight(id, 2.0);
		rmSetAreaSmoothDistance(id, 10);
		rmSetAreaHeightBlend(id, 2);
		rmAddAreaConstraint(id, playerConstraint);
		rmAddAreaConstraint(id, playerEdgeConstraint);
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SnowGrass25");
	}
	
	// Build the areas.
	rmBuildAllAreas();
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int longPlayerConstraint=rmCreateClassDistanceConstraint("continent stays away from players", classPlayer, 50.0);
	
	int bonusIslandID=rmCreateArea("big continent");
	rmSetAreaSize(bonusIslandID, 0.35, 0.4);
	rmSetAreaTerrainType(bonusIslandID, "GrassA");
	rmAddAreaTerrainLayer(bonusIslandID, "SnowGrass75", 13, 20);
	rmAddAreaTerrainLayer(bonusIslandID, "SnowGrass50", 6, 13);
	rmAddAreaTerrainLayer(bonusIslandID, "SnowGrass25", 0, 6);
	rmAddAreaConstraint(bonusIslandID, longPlayerConstraint);
	rmAddAreaToClass(bonusIslandID, classBonusIsland);
	rmSetAreaCoherence(bonusIslandID, 0.25);
	rmSetAreaSmoothDistance(bonusIslandID, 12);
	rmSetAreaHeightBlend(bonusIslandID, 2);
	rmSetAreaBaseHeight(bonusIslandID, 2.0);
	rmSetAreaLocation(bonusIslandID, 0.5, 0.75);
	rmBuildArea(bonusIslandID);
	
	int patchConstraint=rmCreateClassDistanceConstraint("patch vs. patch", rmClassID("classPatch"), 5.0);
	
	for (i=0; <5*mapSizeMultiplier) {
		int patch=rmCreateArea("grassy"+i);
		rmSetAreaWarnFailure(patch, false);
		rmSetAreaSize(patch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(250));
		rmSetAreaTerrainType(patch, "SnowA");
		rmAddAreaTerrainLayer(patch, "SnowGrass25", 5, 7);
		rmAddAreaTerrainLayer(patch, "SnowGrass50", 2, 5);
		rmAddAreaTerrainLayer(patch, "SnowGrass75", 0, 2);
		rmAddAreaToClass(patch, rmClassID("classPatch"));
		rmSetAreaMinBlobs(patch, 1);
		rmSetAreaMaxBlobs(patch, 5);
		rmSetAreaMinBlobDistance(patch, 16.0);
		rmSetAreaMaxBlobDistance(patch, 40.0);
		rmSetAreaCoherence(patch, 0.0);
		rmAddAreaConstraint(patch, patchConstraint);
		rmAddAreaConstraint(patch, longAvoidImpassableLand);
		
		rmBuildArea(patch);
	}
	
	int numTries=5*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int failCount=0;
	for (i=0; <numTries) {
		int patch2=rmCreateArea("snowier patch"+i);
		rmSetAreaWarnFailure(patch2, false);
		rmSetAreaSize(patch2, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		rmSetAreaTerrainType(patch2, "SnowGrass50");
		rmAddAreaTerrainLayer(patch2, "SnowGrass75", 0, 1);
		rmSetAreaMinBlobs(patch2, 1);
		rmSetAreaMaxBlobs(patch2, 5);
		rmSetAreaMinBlobDistance(patch2, 16.0);
		rmSetAreaMaxBlobDistance(patch2, 40.0);
		rmSetAreaCoherence(patch2, 0.0);
		rmAddAreaToClass(patch2, rmClassID("classPatch"));
		rmAddAreaConstraint(patch2, patchConstraint);
		rmAddAreaConstraint(patch2, longAvoidImpassableLand);
		
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
	
	int hillConstraint=rmCreateClassDistanceConstraint("hill vs. hill", rmClassID("classHill"), 20.0);
	numTries=cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier) {
		int cliffID=rmCreateArea("cliff"+i);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(250*mapSizeMultiplier));
		rmSetAreaWarnFailure(cliffID, false);
		rmAddAreaToClass(i, rmClassID("classHill"));
		rmSetAreaCliffType(cliffID, "Norse");
		rmSetAreaTerrainType(cliffID, "SnowGrass50");
		int edgeRand=rmRandInt(0,100);
		if(edgeRand<1) {
			// Inaccesible
			rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
		} else {
			// AOK style
			rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
			rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
		}
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 1);
		rmAddAreaConstraint(cliffID, hillConstraint);
		rmAddAreaConstraint(cliffID, avoidImpassableLand);
		rmAddAreaTerrainLayer(cliffID, "SnowGrass75", 0, 1);
		rmSetAreaMinBlobs(cliffID, 3*mapSizeMultiplier);
		rmSetAreaMaxBlobs(cliffID, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(cliffID, 16.0);
		rmSetAreaMaxBlobDistance(cliffID, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence(cliffID, 0.0);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCoherence(cliffID, 0.25);
		
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
	
	int shortHillConstraint=rmCreateClassDistanceConstraint("patches vs. hill", rmClassID("classHill"), 5.0);
	numTries=20*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier) {
		int elevID=rmCreateArea("wrinkle"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
		rmSetAreaWarnFailure(elevID, false);
		rmSetAreaBaseHeight(elevID, rmRandInt(4.0, 5.0));
		rmSetAreaMinBlobs(elevID, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs(elevID, 3*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence(elevID, 0.0);
		rmAddAreaConstraint(elevID, shortHillConstraint);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		
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
	
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid bonus huntable", "huntable", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);
	int farAvoidGold = rmCreateTypeDistanceConstraint("stuff avoid gold", "gold", 50.0);
	int goldAvoidGold = rmCreateTypeDistanceConstraint("gold avoid gold", "gold", 45.0);
	int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 4.0);
	
	rmSetStatusText("",0.46);
	
	
	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */
	
	int startingGoldFairLocID = -1;
	if(rmRandFloat(0,1) > 0.35){
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 23, 0, 15);
	} else {
		startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 20, 23, 0, 15);
	}
	rmAddFairLocConstraint(startingGoldFairLocID, shortAvoidImpassableLand);
	
	
	float tempX = -1.0;
	float tempZ = -1.0;
	if(rmPlaceFairLocs()){
		int startingGoldID=rmCreateObjectDef("Starting Gold");
		rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
		for(i=1; <cNumberPlayers){
			
			//Because there is only one FairLoc added I can remove the second loop and use the index of 0 for the second param.
			tempX = rmFairLocXFraction(i, 0);
			
			tempZ = rmFairLocZFraction(i, 0);
			
			rmEchoInfo("rmFairLocXFraction("+i+", 0) == "+tempX);
			rmEchoError("rmFairLocZFraction("+i+", 0) == "+tempZ);	//rmEchoError for breakpoint.
			
			rmPlaceObjectDefAtLoc(startingGoldID, i, tempX, tempZ, 1);	//Place fairLoc
		}
	}
	rmResetFairLocs();
	
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 70.0-cNumberNonGaiaPlayers);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 30.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	
	//New way to place TC's. Places them 1 at a time.
	//This way ensures that FairLocs (TC's) will never be too close.
	int TCplaceNum = 3;
	if(cMapSize == 2){
		TCplaceNum = 4;
	}
	int farSettlementID=rmCreateObjectDef("far settlement");
	rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
	rmAddObjectDefConstraint(farSettlementID, TCavoidImpassableLand);
	rmAddObjectDefConstraint(farSettlementID, TCavoidSettlement);
	rmPlaceObjectDefInArea(farSettlementID, 0, bonusIslandID, TCplaceNum*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, cNumberNonGaiaPlayers);
	rmAddObjectDefConstraint(startingSettlementID, shortAvoidImpassableLand);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int startingBerryID=rmCreateObjectDef("starting berries");
	rmAddObjectDefItem(startingBerryID, "Berry Bush", rmRandInt(5,7), 2.0);
	rmSetObjectDefMaxDistance(startingBerryID, 20.0);
	rmSetObjectDefMaxDistance(startingBerryID, 25.0);
	rmAddObjectDefConstraint(startingBerryID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid gold", "gold", 10.0));
	rmAddObjectDefConstraint(startingBerryID, rmCreateTypeDistanceConstraint("short berry avoid TC", "AbstractSettlement", 15.0));
	rmPlaceObjectDefPerPlayer(startingBerryID, true);
	
	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 28.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("straggler trees", "all", 2.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(12,16));
	
	int transportNearShore=rmCreateTerrainMaxDistanceConstraint("transport near shore", "land", true, 4.0);
	int transportGreekID=rmCreateObjectDef("transport greek");
	rmAddObjectDefItem(transportGreekID, "transport ship greek", 1, 0.0);
	rmSetObjectDefMinDistance(transportGreekID, 0.0);
	rmSetObjectDefMaxDistance(transportGreekID, 45.0);
	rmAddObjectDefConstraint(transportGreekID, transportNearShore);
	rmAddObjectDefConstraint(transportGreekID, playerEdgeConstraint);
	
	int transportNorseID=rmCreateObjectDef("transport Norse");
	rmAddObjectDefItem(transportNorseID, "transport ship Norse", 1, 0.0);
	rmSetObjectDefMinDistance(transportNorseID, 0.0);
	rmSetObjectDefMaxDistance(transportNorseID, 45.0);
	rmAddObjectDefConstraint(transportNorseID, transportNearShore);
	rmAddObjectDefConstraint(transportNorseID, playerEdgeConstraint);
	
	int transportEgyptianID=rmCreateObjectDef("transport Egyptian");
	rmAddObjectDefItem(transportEgyptianID, "transport ship Egyptian", 1, 0.0);
	rmSetObjectDefMinDistance(transportEgyptianID, 0.0);
	rmSetObjectDefMaxDistance(transportEgyptianID, 45.0);
	rmAddObjectDefConstraint(transportEgyptianID, transportNearShore);
	rmAddObjectDefConstraint(transportEgyptianID, playerEdgeConstraint);
	
	int transportAtlanteanID=rmCreateObjectDef("transport Atlantean");
	rmAddObjectDefItem(transportAtlanteanID, "transport ship Atlantean", 1, 0.0);
	rmSetObjectDefMinDistance(transportAtlanteanID, 0.0);
	rmSetObjectDefMaxDistance(transportAtlanteanID, 45.0);
	rmAddObjectDefConstraint(transportAtlanteanID, transportNearShore);
	
	int transportChineseID=rmCreateObjectDef("transport Chinese");
	rmAddObjectDefItem(transportChineseID, "Transport Ship Chinese", 1, 0.0);
	rmSetObjectDefMinDistance(transportChineseID, 0.0);
	rmSetObjectDefMaxDistance(transportChineseID, 45.0);
	rmAddObjectDefConstraint(transportChineseID, transportNearShore);
	
	for(i=0; <cNumberPlayers){
		if(rmGetPlayerCulture(i) == cCultureGreek) {
			rmPlaceObjectDefAtLoc(transportGreekID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureNorse) {
			rmPlaceObjectDefAtLoc(transportNorseID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureEgyptian) {
			rmPlaceObjectDefAtLoc(transportEgyptianID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureAtlantean) {
			rmPlaceObjectDefAtLoc(transportAtlanteanID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		} else if(rmGetPlayerCulture(i) == cCultureChinese){
			rmPlaceObjectDefAtLoc(transportChineseID, i, rmGetPlayerX(i), rmGetPlayerZ(i));
		}
	}
	
	rmSetStatusText("",0.60);
	
	/* *************************** */
	/* Section 10 Starting Forests */
	/* *************************** */
	
	//No Starting Forests in Vindlandsaga
	
	rmSetStatusText("",0.66);
	
	/* ************************* */
	/* Section 11 Medium Objects */
	/* ************************* */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	//No Medium Objects in Vindlandsaga
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).

	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmAddObjectDefConstraint(farGoldID, goldAvoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 18.0));
	rmPlaceObjectDefInArea(farGoldID, 0, bonusIslandID, 4*cNumberNonGaiaPlayers);
	
	// Skraelings? What's a Skraeling?
	int skraVsSkra=rmCreateTypeDistanceConstraint("avoid Skraeling", "Skraeling", 50.0);
	int SkraelingID=rmCreateObjectDef("Skraeling natives");
	rmAddObjectDefItem(SkraelingID, "Skraeling", rmRandInt(3,5), 3.0);
	rmAddObjectDefConstraint(SkraelingID, longAvoidImpassableLand);
	rmAddObjectDefConstraint(SkraelingID, avoidFood);
	rmAddObjectDefConstraint(SkraelingID, skraVsSkra);
	rmPlaceObjectDefInArea(SkraelingID, 0, bonusIslandID, cNumberNonGaiaPlayers);
	
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "boar", 2, 2.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "deer", 6, 2.0);
	}
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmPlaceObjectDefInArea(bonusHuntableID, 0, bonusIslandID, 2*cNumberNonGaiaPlayers);
	
	int bonusHuntableID2=rmCreateObjectDef("bonus huntable 2");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID2, "elk", 5, 3.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID2, "elk", 7, 4.0);
	}
	rmAddObjectDefConstraint(bonusHuntableID2, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidGold);
	rmAddObjectDefConstraint(bonusHuntableID2, avoidImpassableLand);
	rmPlaceObjectDefInArea(bonusHuntableID2, 0, bonusIslandID, cNumberNonGaiaPlayers);

	int farPigsID=rmCreateObjectDef("far pigs");
	rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, longAvoidImpassableLand);
	rmAddObjectDefConstraint(farPigsID, avoidGold);
	rmAddObjectDefConstraint(farPigsID, avoidFood);
	rmPlaceObjectDefInArea(farPigsID, 0, bonusIslandID, 3*cNumberNonGaiaPlayers);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "wolf", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
	}
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0));
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, farAvoidGold);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements", "AbstractSettlement", 40.0));
	rmPlaceObjectDefInArea(farPredatorID, 0, bonusIslandID, cNumberNonGaiaPlayers);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, 50.0);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 60.0));
	rmAddObjectDefConstraint(relicID, longAvoidImpassableLand);
	rmPlaceObjectDefInArea(relicID, 0, bonusIslandID, cNumberNonGaiaPlayers);
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 14.0+(2*cNumberNonGaiaPlayers));
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	int playerFishID=rmCreateObjectDef("owned fish");
	rmAddObjectDefItem(playerFishID, "fish - salmon", 3, 10.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 70.0);
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, fishLand);
	rmPlaceObjectDefPerPlayer(playerFishID, false);
	
	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - salmon", 3, 8.0+(2*cNumberNonGaiaPlayers));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefInLineZ(fishID, 0, 3+cNumberNonGaiaPlayers, 0.99-(0.005*cNumberNonGaiaPlayers), 0.0, 1.0, 0.005*cNumberNonGaiaPlayers);
	rmPlaceObjectDefInLineZ(fishID, 0, 3+cNumberNonGaiaPlayers, 0.01+(0.005*cNumberNonGaiaPlayers), 0.0, 1.0, 0.005*cNumberNonGaiaPlayers);
	rmPlaceObjectDefInLineX(fishID, 0, 2+cNumberNonGaiaPlayers, 0.01, 0.0, 1.0, 0.0);
	
	/*	Need to do some math here. Want to place fish between starting area and bonus island.
	**	Equation is: Starting point + Starting Area radius + (Island avoid distance) / 2.0) + player bonus
	**
	**	Starting point: Player's area place at 0.15 Y
	**	Starting Area: Player's area size is rmAreaTilesToFraction(playerTiles) -> Need to find radius if perfect circle.
	**	Island avoid distance: Large island avoids players islands by 50m -> rmXMetersToFraction(50.0)
	*/
	float circleRadiusFromArea = sqrt(rmAreaTilesToFraction(playerTiles)/PI);
	float centrePoint = 0.15 + circleRadiusFromArea + (rmXMetersToFraction(50.0) / 2.0) + (cNumberNonGaiaPlayers * 0.004);
	rmEchoInfo("centrePoint: "+centrePoint+". 0.15 + "+circleRadiusFromArea+" + ("+rmXMetersToFraction(50.0)+" / 2.0) + "+(cNumberNonGaiaPlayers * 0.004));
	rmPlaceObjectDefInLineX(fishID, 0, 3+cNumberNonGaiaPlayers, centrePoint, 0.0, 1.0, 0.01);
	
	//Random placement
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmPlaceObjectDefInArea(randomTreeID, 0, bonusIslandID, cNumberNonGaiaPlayers*10);
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
	
		int rndNum = cNumberNonGaiaPlayers*2;
	
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmAddObjectDefConstraint(giantGoldID, farAvoidGold);
		rmPlaceObjectDefInArea(giantGoldID, 0, bonusIslandID, rmRandInt(cNumberNonGaiaPlayers, rndNum));
		
		int avoidGiantHuntable=rmCreateTypeDistanceConstraint("avoid giant huntable", "food", 50.0);
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "elk", 6, 4.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmAddObjectDefConstraint(giantHuntableID, avoidGiantHuntable);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmPlaceObjectDefInArea(giantHuntableID, 0, bonusIslandID, rmRandInt(cNumberNonGaiaPlayers, rndNum));
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		rmAddObjectDefItem(giantHuntable2ID, "boar", 4, 4.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.3));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGiantHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidImpassableLand);
		rmPlaceObjectDefInArea(giantHuntable2ID, 0, bonusIslandID, rmRandInt(cNumberNonGaiaPlayers, rndNum));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, longAvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmPlaceObjectDefInArea(giantHerdableID, 0, bonusIslandID, rmRandInt(cNumberNonGaiaPlayers, rndNum));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, rmRandInt(cNumberNonGaiaPlayers, rndNum));
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int allObjConstraint=rmCreateTypeDistanceConstraint("all obj", "all", 6.0);
	int classForest=rmDefineClass("forest");
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int count=0;
	failCount=0;
	numTries=6*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		numTries = 1.5*numTries;
	}
	
	for(i=0; <numTries){
		int forestID=rmCreateArea("forest"+i, bonusIslandID);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		if(cMapSize == 2){
			rmSetAreaSize(forestID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "pine forest");
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, allObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 7);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);
		
		if(rmBuildArea(forestID)==false){
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
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int rockID=rmCreateObjectDef("rock");
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);
	
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
	rmAddObjectDefConstraint(sharkID, playerEdgeConstraint);
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int nearshore=rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
	int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
	int kelpID=rmCreateObjectDef("seaweed");
	rmAddObjectDefItem(kelpID, "seaweed", 5, 3.0);
	rmSetObjectDefMinDistance(kelpID, 0.0);
	rmSetObjectDefMaxDistance(kelpID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(kelpID, avoidAll);
	rmAddObjectDefConstraint(kelpID, nearshore);
	rmAddObjectDefConstraint(kelpID, farshore);
	rmPlaceObjectDefAtLoc(kelpID, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers);
	
	int kelp2ID=rmCreateObjectDef("seaweed 2");
	rmAddObjectDefItem(kelp2ID, "seaweed", 2, 3.0);
	rmSetObjectDefMinDistance(kelp2ID, 0.0);
	rmSetObjectDefMaxDistance(kelp2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(kelp2ID, avoidAll);
	rmAddObjectDefConstraint(kelp2ID, nearshore);
	rmAddObjectDefConstraint(kelp2ID, farshore);
	rmPlaceObjectDefAtLoc(kelp2ID, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers);
	
	// Logs
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "rotting log", 1, 0.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidAll);
	rmAddObjectDefConstraint(logID, avoidImpassableLand);
	rmAddObjectDefConstraint(logID, rmCreateTypeDistanceConstraint("avoid buildings", "Building", 8.0));
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.0);
}
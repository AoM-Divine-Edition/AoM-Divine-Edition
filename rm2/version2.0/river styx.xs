// RIVER STYX

include "MmM_FE_lib.xs";

// Main entry point for random map script
void main(void){

	// Text
	rmSetStatusText("",0.01);

	// Set size.
	int mapSizeMultiplier = 1;
	int playerTiles = 16000;
	if(cMapSize == 1) {
		playerTiles = 20800;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2) {
		playerTiles = 32000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);

	// Set up default water.
	rmSetSeaLevel(0.0);
	rmSetSeaType("styx river");

	// Init map.
	rmTerrainInitialize("water");
	rmSetLightingSet("erebus");
	rmSetGaiaCiv(cCivHades);

	// Define some classes.
	int classPlayer=rmDefineClass("player");
	int bonusIslandClass=rmDefineClass("bonus island");
	int islandClass=rmDefineClass("islandClass");
	rmDefineClass("corner");
	rmDefineClass("starting settlement");
	int classCliff=rmDefineClass("cliff");

	// -------------Define constraints

	// Create a edge of map constraint.
	int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(12), rmZTilesToFraction(12), 1.0-rmXTilesToFraction(12), 1.0-rmZTilesToFraction(12), 0.01);

	// Player area constraint.
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);
	int shortPlayerConstraint=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 2.0);

	// corner constraint.
	int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
	int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

	// Settlement constraint.
	int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 30.0);
	int farSettleVsFarSettle=rmCreateTypeDistanceConstraint("island Settle vs island Settle", "AbstractSettlement", 50.0);

	// Far starting settlement constraint.
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 70.0);

	// Tower constraint.
	int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 16.0);

	// Gold
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

	// Goats/pigs
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

	// Animals
	int classBonusHuntable=rmDefineClass("bonus huntable");
	int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 15.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

	// Avoid impassable land
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
	int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0);
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 8.0);

	// -------------Define objects
	// Close Objects

	int startingSettlementID=rmCreateObjectDef("Starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

	// towers avoid other towers
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 12.0);
	rmSetObjectDefMaxDistance(startingTowerID, 18.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, shortAvoidImpassableLand);

	int startingGoldID=rmCreateObjectDef("Starting gold");
	rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance(startingGoldID, 34.0);
	rmSetObjectDefMaxDistance(startingGoldID, 40.0);
	rmAddObjectDefConstraint(startingGoldID, avoidGold);
	rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

	// boar
	int closeBoarID=rmCreateObjectDef("close boar");
	rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(3,5), 4);
	rmSetObjectDefMinDistance(closeBoarID, 16.0);
	rmSetObjectDefMaxDistance(closeBoarID, 22.0);

	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine dead", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

	// Medium Objects

	// gold avoids gold and Settlements
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 28.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

	int mediumBoarID=rmCreateObjectDef("medium boar");
	rmAddObjectDefItem(mediumBoarID, "boar", rmRandInt(2, 4), 4.0);
	rmSetObjectDefMinDistance(mediumBoarID, 70.0);
	rmSetObjectDefMaxDistance(mediumBoarID, 90.0);
	rmAddObjectDefConstraint(mediumBoarID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(mediumBoarID, avoidHerdable);
	rmAddObjectDefConstraint(mediumBoarID, farStartingSettleConstraint);

	// Far Objects

	// Settlement avoid Settlements
	int medSettlementID=rmCreateObjectDef("med settlement");
	rmAddObjectDefItem(medSettlementID, "Settlement", 1, 0.0);
	rmSetObjectDefMinDistance(medSettlementID, 40.0);
	rmSetObjectDefMaxDistance(medSettlementID, 120.0);
	rmAddObjectDefConstraint(medSettlementID, avoidImpassableLand);
	rmAddObjectDefConstraint(medSettlementID, farAvoidSettlement);

	int farSettlementID=rmCreateObjectDef("far settlement");
	rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
	rmAddObjectDefConstraint(farSettlementID, avoidImpassableLand);
	rmAddObjectDefConstraint(farSettlementID, farSettleVsFarSettle);

	// gold avoids gold, Settlements and TCs
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 80.0);
	rmSetObjectDefMaxDistance(farGoldID, 150.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);

	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(3,6), 4.0);
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
	rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);


	//Predators
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "serpent", 4, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "serpent", 2, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 50.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);

	// more predators
	int farPredator2ID=rmCreateObjectDef("far 2 predator");
	predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredator2ID, "shade of erebus", 4, 4.0);
	} else {
		rmAddObjectDefItem(farPredator2ID, "shade of erebus", 2, 4.0);
	}
	rmSetObjectDefMinDistance(farPredator2ID, 50.0);
	rmSetObjectDefMaxDistance(farPredator2ID, 100.0);
	rmAddObjectDefConstraint(farPredator2ID, avoidPredator);
	rmAddObjectDefConstraint(farPredator2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredator2ID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(farPredator2ID, avoidFood);

	// This map will either use boar or deer as the extra huntable food.

	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "pine dead", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);

	// Birds
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "harpy", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

	// Relics avoid TCs
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 40.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);



	// -------------Done defining objects


	// Text
	rmSetStatusText("",0.20);

	// Cheesy square placement of players.
	rmSetTeamSpacingModifier(0.5);
	if(cNumberNonGaiaPlayers < 4) {
		rmPlacePlayersSquare(0.30, 0.05, 0.05);
	} else {
		rmPlacePlayersSquare(0.35, 0.05, 0.05);
	}
	rmRecordPlayerLocations();

	// bonus island
	int centerAvoidance = 0;
	if(cNumberPlayers < 5) {
		centerAvoidance = 20;
	} else {
		centerAvoidance = 30;
	}

	int islandConstraint=rmCreateClassDistanceConstraint("islands avoid each other", islandClass, 20.0);
	int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid big island", bonusIslandClass, centerAvoidance);
	int playerIslandConstraint=rmCreateClassDistanceConstraint("avoid player islands", islandClass, centerAvoidance);
	int teamEdgeConstraint=rmCreateBoxConstraint("island edge of map", rmXTilesToFraction(18), rmZTilesToFraction(18), 1.0-rmXTilesToFraction(18), 1.0-rmZTilesToFraction(18), 0.01);


	/*   rmBuildArea(bonusID); */

	// Build team areas
	float percentPerPlayer = 0.25/cNumberNonGaiaPlayers;
	float teamSize = 0;

	for(i=0; <cNumberTeams) {
		int teamID=rmCreateArea("team"+i);
		teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
		rmEchoInfo ("team size "+teamSize);
		rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
		rmSetAreaWarnFailure(teamID, false);
		rmSetAreaTerrainType(teamID, "Hadesbuildable1");
		rmAddAreaTerrainLayer(teamID, "Hadesbuildable2", 0, 8);
		rmSetAreaMinBlobs(teamID, 1);
		rmSetAreaMaxBlobs(teamID, 5);
		rmSetAreaMinBlobDistance(teamID, 16.0);
		rmSetAreaMaxBlobDistance(teamID, 40.0);
		rmSetAreaCoherence(teamID, 0.4);
		rmSetAreaSmoothDistance(teamID, 10);
		rmSetAreaBaseHeight(teamID, 1.0);
		rmSetAreaHeightBlend(teamID, 2);
		rmAddAreaToClass(teamID, islandClass);
		rmAddAreaConstraint(teamID, islandConstraint);
		rmAddAreaConstraint(teamID, bonusIslandConstraint);
		rmAddAreaConstraint(teamID, teamEdgeConstraint);
		rmSetAreaLocTeam(teamID, i);
		rmEchoInfo("Team area"+i);
	}

	/*  if(cNumberTeams > 2)
	     rmBuildAllAreas(); */

	int bonusID=rmCreateArea("bonus island");
	rmSetAreaSize(bonusID, 0.2, 0.3);
	rmAddAreaToClass(bonusID, islandClass);
	rmSetAreaWarnFailure(bonusID, false);
	rmSetAreaLocation(bonusID, 0.5, 0.5);
	rmSetAreaMinBlobs(bonusID, 1);
	rmSetAreaMaxBlobs(bonusID, 5);
	rmSetAreaMinBlobDistance(bonusID, 16.0);
	rmSetAreaMaxBlobDistance(bonusID, 40.0);
	rmSetAreaCoherence(bonusID, 0.0);
	rmSetAreaSmoothDistance(bonusID, 10);
	rmSetAreaBaseHeight(bonusID, 1.0);
	rmSetAreaHeightBlend(bonusID, 2);
	rmAddAreaToClass(bonusID, bonusIslandClass);
	rmAddAreaConstraint(bonusID, playerIslandConstraint);
	rmAddAreaConstraint(bonusID, teamEdgeConstraint);
	rmSetAreaTerrainType(bonusID, "hadesbuildable1");

	rmBuildAllAreas();

	// Text
	rmSetStatusText("",0.40);


	// Set up player areas.
	for(i=1; <cNumberPlayers) {
		// Create the area.
		int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
		rmEchoInfo("Player"+i+"team"+rmGetPlayerTeam(i));

		// Assign to the player.
		rmSetPlayerArea(i, id);

		// Set the size.
		rmSetAreaSize(id, 1.0, 1.0);
		rmAddAreaToClass(id, classPlayer);

		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaMinBlobDistance(id, 10.0);
		rmSetAreaMaxBlobDistance(id, 20.0);
		rmSetAreaCoherence(id, 0.5);
		rmAddAreaConstraint(id, playerConstraint);

		// Set the location.
		rmSetAreaLocPlayer(id, i);
		rmSetAreaWarnFailure(id, false);

		// Set type.
	}

	rmBuildAllAreas();

	for(i=1; <cNumberPlayers) {
		// Beautification sub area.
		int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize(id2, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
		rmSetAreaLocPlayer(id2, i);
		rmSetAreaTerrainType(id2, "Hadesbuildable2");
		rmSetAreaMinBlobs(id2, 1);
		rmSetAreaMaxBlobs(id2, 5);
		rmSetAreaWarnFailure(id2, false);
		rmSetAreaMinBlobDistance(id2, 16.0);
		rmSetAreaMaxBlobDistance(id2, 40.0);
		rmSetAreaCoherence(id2, 0.0);

		rmBuildArea(id2);
	}


	// Draw cliffs

	int islandShoreConstraint = rmCreateEdgeDistanceConstraint("bonus island edge", bonusID, 16.0);
	int numCliffs = rmRandInt(1,2);
	if(cNumberNonGaiaPlayers > 3) {
		numCliffs = rmRandInt(2,4);
	} else if (cNumberNonGaiaPlayers > 5) {
		numCliffs = rmRandInt(4,6);
	}
	for(i=0; <numCliffs) {
		int cliffID=rmCreateArea("cliff"+i, bonusID);
		rmSetAreaWarnFailure(cliffID, false);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(400));
		rmSetAreaCliffType(cliffID, "Hades");
		rmAddAreaConstraint(cliffID, cliffConstraint);
		rmAddAreaConstraint(cliffID, islandShoreConstraint);
		rmAddAreaToClass(cliffID, classCliff);
		rmSetAreaMinBlobs(cliffID, 10);
		rmSetAreaMaxBlobs(cliffID, 10);
		int edgeRand=rmRandInt(0,100);
		rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
		rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
		rmSetAreaTerrainType(cliffID, "Hades9");

		rmSetAreaMinBlobDistance(cliffID, 20.0);
		rmSetAreaMaxBlobDistance(cliffID, 20.0);
		rmSetAreaCoherence(cliffID, 0.0);
		rmSetAreaSmoothDistance(cliffID, 10);
		rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 2);
		rmBuildArea(cliffID);
	}

	// Place stuff.

	// TC
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);

	// Towers.
	rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

	// Settlements

	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(medSettlementID, 0, rmAreaID("player"+i), 1);
	}

	rmPlaceObjectDefInArea(farSettlementID, 0, bonusID, cNumberNonGaiaPlayers);
	
	if(cMapSize == 2){
		int farID = -1;
		int TCgiant = rmCreateTypeDistanceConstraint("TCs vs TCs Giant", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			farID = rmCreateObjectDef("giant settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCgiant);
			rmAddObjectDefConstraint(farID, farStartingSettleConstraint);
			rmAddObjectDefConstraint(farID, avoidImpassableLand);
			for(attempt = 3; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 25*attempt);
			}
			
			farID=rmCreateObjectDef("giant2 settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCgiant);
			rmAddObjectDefConstraint(farID, farStartingSettleConstraint);
			rmAddObjectDefConstraint(farID, avoidImpassableLand);
			for(attempt = 4; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 30*attempt);
			}
		}
	}

	// Text
	rmSetStatusText("",0.60);

	// Player elevation.
	for(i=1; <cNumberPlayers) {
		int failCount=0;
		int num=rmRandInt(2, 4);
		for(j=0; <num) {
			int elevID=rmCreateArea("elev"+i+", "+j, rmAreaID("player"+i));
			rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
			rmSetAreaWarnFailure(elevID, false);
			rmAddAreaConstraint(elevID, avoidBuildings);
			rmAddAreaConstraint(elevID, avoidImpassableLand);
			rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 3.5));

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
	}

	// Bonus elevation.
	failCount=0;
	num=rmRandInt(5, 10);
	for(j=0; <num) {
		elevID=rmCreateArea("elev"+j, bonusID);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
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

	// Straggler trees.
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

	// Gold
	rmPlaceObjectDefPerPlayer(startingGoldID, false);

	// Boar.
	rmPlaceObjectDefPerPlayer(closeBoarID, false);

	// Medium things....
	// Gold
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);

	//Boar
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefAtLoc(mediumBoarID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
	}


	// Text
	rmSetStatusText("",0.80);

	// Far things.

	// Gold
	rmPlaceObjectDefInArea(farGoldID, 0, bonusID, 2*cNumberNonGaiaPlayers);

	// Hawks
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

	// Relics
	rmPlaceObjectDefInArea(relicID, 0, bonusID, cNumberNonGaiaPlayers);

	// Bonus huntable.
	rmPlaceObjectDefInArea(bonusHuntableID, 0, bonusID, cNumberNonGaiaPlayers);

	// Predators
	rmPlaceObjectDefInArea(farPredatorID, 0, bonusID, cNumberNonGaiaPlayers);

	rmPlaceObjectDefInArea(farPredator2ID, 0, bonusID, cNumberNonGaiaPlayers);


	// Random trees.
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);


	// Forest.
	int classForest=rmDefineClass("forest");
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 10.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 15.0);
	int forestTerrain=rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);

	// Player forests.
	for(i=1; <cNumberPlayers) {
		failCount=0;
		int forestCount = 20*mapSizeMultiplier;
		for(j=0; <forestCount) {
			int forestID=rmCreateArea("player"+i+"forest"+j, rmAreaID("player"+i));
			rmSetAreaSize(forestID, rmAreaTilesToFraction(75), rmAreaTilesToFraction(130));
			if(cMapSize == 2) {
				rmSetAreaSize(forestID, rmAreaTilesToFraction(175), rmAreaTilesToFraction(225));
			}
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, "hades forest");
			rmAddAreaConstraint(forestID, forestSettleConstraint);
			rmAddAreaConstraint(forestID, forestObjConstraint);
			rmAddAreaConstraint(forestID, forestConstraint);
			rmAddAreaConstraint(forestID, forestTerrain);
			rmAddAreaToClass(forestID, classForest);

			rmSetAreaMinBlobs(forestID, 1);
			rmSetAreaMaxBlobs(forestID, 5);
			rmSetAreaMinBlobDistance(forestID, 16.0);
			rmSetAreaMaxBlobDistance(forestID, 40.0);
			rmSetAreaCoherence(forestID, 0.0);
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
	}

	// Random island forests.
	int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 20.0);
	for(i=1; <cNumberPlayers) {
		forestCount=rmRandInt(3, 5)*mapSizeMultiplier;
		for(j=0; <forestCount) {
			forestID=rmCreateArea("bonus "+i+"forest "+j, bonusID);
			rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
			rmSetAreaWarnFailure(forestID, false);
			rmSetAreaForestType(forestID, "hades forest");
			rmAddAreaConstraint(forestID, avoidImpassableLand);
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
	}

	// Rocks
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);

	int columnID=rmCreateObjectDef("columns");
	rmAddObjectDefItem(columnID, "ruins", rmRandInt(1,4), 6.0);
	rmAddObjectDefItem(columnID, "columns broken", rmRandInt(1,2), 4.0);
	rmAddObjectDefItem(columnID, "rock limestone sprite", rmRandInt(6,12), 10.0);
	rmAddObjectDefItem(columnID, "skeleton", rmRandInt(4,9), 10.0);
	rmSetObjectDefMinDistance(columnID, 0.0);
	rmSetObjectDefMaxDistance(columnID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(columnID, avoidAll);
	rmAddObjectDefConstraint(columnID, shortAvoidSettlement);
	rmAddObjectDefConstraint(columnID, avoidImpassableLand);
	rmAddObjectDefConstraint(columnID, shortAvoidImpassableLand);
	rmPlaceObjectDefAtLoc(columnID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);

	int stalagmiteID=rmCreateObjectDef("stalagmite");
	rmAddObjectDefItem(stalagmiteID, "stalagmite", 1, 0.0);
	rmSetObjectDefMinDistance(stalagmiteID, 0.0);
	rmSetObjectDefMaxDistance(stalagmiteID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(stalagmiteID, avoidAll);
	rmAddObjectDefConstraint(stalagmiteID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(stalagmiteID, 0, 0.5, 0.5, 7*cNumberNonGaiaPlayers*mapSizeMultiplier);


	int nearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 6.0);

	int shoreStalagID=rmCreateObjectDef("shore stalagmite");
	rmAddObjectDefItem(shoreStalagID, "stalagmite", 1, 0.0);
	rmSetObjectDefMinDistance(shoreStalagID, 0.0);
	rmSetObjectDefMaxDistance(shoreStalagID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(shoreStalagID, nearShore);
	rmPlaceObjectDefAtLoc(shoreStalagID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);

	int stalagmite2ID=rmCreateObjectDef("stalagmite2");
	rmAddObjectDefItem(stalagmite2ID, "stalagmite", 3, 1.0);
	rmSetObjectDefMinDistance(stalagmite2ID, 0.0);
	rmSetObjectDefMaxDistance(stalagmite2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(stalagmite2ID, avoidAll);
	rmAddObjectDefConstraint(stalagmite2ID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(stalagmite2ID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);

	int stalagmite3ID=rmCreateObjectDef("stalagmite3");
	rmAddObjectDefItem(stalagmite3ID, "stalagmite", 5, 2.0);
	rmSetObjectDefMinDistance(stalagmite3ID, 0.0);
	rmSetObjectDefMaxDistance(stalagmite3ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(stalagmite3ID, avoidAll);
	rmAddObjectDefConstraint(stalagmite3ID, shortAvoidSettlement);
	rmPlaceObjectDefAtLoc(stalagmite3ID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);

	// Text
	rmSetStatusText("",1.0);

}





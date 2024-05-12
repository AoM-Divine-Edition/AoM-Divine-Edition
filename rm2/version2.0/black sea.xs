
include "MmM_FE_lib.xs";

void main(void){
	// Main entry point for random map script

	// Text
	rmSetStatusText("",0.01);

	// Set size.
	int mapSizeMultiplier = 1;
	int playerTiles=9000;
	if(cMapSize == 1) {
		playerTiles = 11700;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2) {
		playerTiles = 18000;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);

	// Set up default water.
	rmSetSeaLevel(0.0);

	// Init map.
	rmSetSeaType("Red sea");
	rmTerrainInitialize("water");

	// Define some classes.
	int classPlayer=rmDefineClass("player");
	int classPlayerCore=rmDefineClass("player core");
	int classTeam=rmDefineClass("team");
	rmDefineClass("corner");
	rmDefineClass("center");
	int classpatch=rmDefineClass("patch");
	rmDefineClass("starting settlement");


	// -------------Define constraints

	// Create a edge of map constraint.
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));

	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 15.0);


	// Center constraint.
	int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 50.0);
	int wideCenterConstraint=rmCreateClassDistanceConstraint("elevation avoids center", rmClassID("center"), 50.0);

	// Tower constraint.
	int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);

	// corner constraint.
	int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
	int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

	// Settlement constraints
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);

	// Gold
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

	// Food
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);


	// Avoid impassable land
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land by lots", "land", false, 30.0);
	int patchConstraint=rmCreateClassDistanceConstraint("patch v patch", rmClassID("patch"), 10.0);

	int teamVsTeamConstraint=rmCreateClassDistanceConstraint("stay away from teams a lot", classTeam, 30);


	// -------------Define objects
	// Close Objects

	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

	// towers avoid other towers
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 28.0);
	rmAddObjectDefConstraint(startingTowerID, avoidTower);
	rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);

	// gold avoids gold
	int startingGoldID=rmCreateObjectDef("Starting gold");
	rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance(startingGoldID, 25.0);
	rmSetObjectDefMaxDistance(startingGoldID, 30.0);
	rmAddObjectDefConstraint(startingGoldID, avoidGold);
	rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

	int closeChickensID=rmCreateObjectDef("close Chickens");
	rmAddObjectDefItem(closeChickensID, "chicken", 8, 5.0);
	rmSetObjectDefMinDistance(closeChickensID, 20.0);
	rmSetObjectDefMaxDistance(closeChickensID, 25.0);
	rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeChickensID, avoidFood);

	int closeBerriesID=rmCreateObjectDef("close berries");
	rmAddObjectDefItem(closeBerriesID, "berry bush", 6, 4.0);
	rmSetObjectDefMinDistance(closeBerriesID, 20.0);
	rmSetObjectDefMaxDistance(closeBerriesID, 25.0);
	rmAddObjectDefConstraint(closeBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeBerriesID, avoidFood);

	int closeBoarID=rmCreateObjectDef("close Boar");
	float boarNumber=rmRandFloat(0, 1);
	if(boarNumber<0.3) {
		rmAddObjectDefItem(closeBoarID, "boar", 1, 4.0);
	} else if(boarNumber<0.6) {
		rmAddObjectDefItem(closeBoarID, "boar", 2, 4.0);
	} else {
		rmAddObjectDefItem(closeBoarID, "boar", 3, 6.0);
	}
	rmSetObjectDefMinDistance(closeBoarID, 30.0);
	rmSetObjectDefMaxDistance(closeBoarID, 50.0);
	rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);

	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);


	// Medium Objects

	// gold avoids gold and Settlements
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 40.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

	// player fish
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

	int playerFishID=rmCreateObjectDef("owned fish");
	rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 10.0);
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 100.0);
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, fishLand);


	// gold avoids gold, Settlements and TCs
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 160.0);
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

	// pick lions or bears as predators
	// avoid TCs
	int farPredatorID=rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5) {
		rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
	} else {
		rmAddObjectDefItem(farPredatorID, "bear", 1, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorID, 50.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);

	// Berries avoid TCs
	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 0.0);
	rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);

	// This map will either use boar or deer as the extra huntable food.
	int classBonusHuntable=rmDefineClass("bonus huntable");
	int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

	// hunted avoids hunted and TCs
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	float bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.5) {
		rmAddObjectDefItem(bonusHuntableID, "boar", 2, 4.0);
	} else {
		rmAddObjectDefItem(bonusHuntableID, "deer", 6, 8.0);
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);

	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);

	// Birds
	int farhawkID=rmCreateObjectDef("far hawks");
	rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance(farhawkID, 0.0);
	rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

	// Relics avoid TCs
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 60.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);

	// -------------Done defining objects

	// Text
	rmSetStatusText("",0.20);

	int centerID=rmCreateArea("center");
	rmSetAreaSize(centerID, 0.01, 0.01);
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmAddAreaToClass(centerID, rmClassID("center"));

	rmPlacePlayersCircular(0.4, 0.43, rmDegreesToRadians(5.0));
	rmSetTeamSpacingModifier(0.75);
	
	rmRecordPlayerLocations();

	// Team areas
	float percentPerPlayer = 0.75/cNumberNonGaiaPlayers;
	float teamSize=0;

	for(i=0; <cNumberTeams) {
		int teamID=rmCreateArea("team"+i);
		teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
		rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
		rmEchoInfo ("team size "+teamSize);
		/*         rmSetAreaSize(teamID, 0.35, 0.4); */
		rmSetAreaWarnFailure(teamID, false);
		rmSetAreaTerrainType(teamID, "SandA");
		rmSetAreaMinBlobs(teamID, 1);
		rmSetAreaMaxBlobs(teamID, 5);
		rmSetAreaMinBlobDistance(teamID, 16.0);
		rmSetAreaMaxBlobDistance(teamID, 40.0);
		rmSetAreaCoherence(teamID, 0.0);
		rmSetAreaSmoothDistance(teamID, 10);
		rmSetAreaBaseHeight(teamID, 1.0);
		rmSetAreaHeightBlend(teamID, 2);
		rmAddAreaToClass(teamID, classTeam);
		rmAddAreaConstraint(teamID, teamVsTeamConstraint);
		rmAddAreaConstraint(teamID, centerConstraint);
		rmSetAreaLocTeam(teamID, i);
		rmSetTeamArea(i, teamID);
		rmEchoInfo("Team area"+i);
	}

	rmBuildAllAreas();

	float playerFraction=rmAreaTilesToFraction(1600);

	for(i=1; <cNumberPlayers) {
		int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
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
		rmSetAreaLocPlayer(id, i);
		rmSetAreaTerrainType(id, "SnowB");
		rmAddAreaTerrainLayer(id, "snowSand25", 6, 10);
		rmAddAreaTerrainLayer(id, "snowSand50", 2, 6);
		rmAddAreaTerrainLayer(id, "snowSand75", 0, 2);
	}
	rmBuildAllAreas();


	int patch = 0;
	int failCount=0;
	int stayInPatch=rmCreateEdgeDistanceConstraint("stay in patch", patch, 4.0);
	for(i=1; <cNumberPlayers*2*mapSizeMultiplier) {
		patch=rmCreateArea("patch"+i);
		rmSetAreaSize(patch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		rmSetAreaWarnFailure(patch, false);
		rmSetAreaTerrainType(patch, "SnowB");
		rmAddAreaTerrainLayer(patch, "snowSand25", 2, 3);
		rmAddAreaTerrainLayer(patch, "snowSand50", 1, 2);
		rmAddAreaTerrainLayer(patch, "snowSand75", 0, 1);
		rmSetAreaMinBlobs(patch, 1);
		rmSetAreaMaxBlobs(patch, 5);
		rmSetAreaMinBlobDistance(patch, 16.0);
		rmSetAreaMaxBlobDistance(patch, 40.0);
		rmAddAreaToClass(patch, classpatch);
		rmAddAreaConstraint(patch, patchConstraint);
		rmAddAreaConstraint(patch, playerConstraint);
		rmAddAreaConstraint(patch, avoidImpassableLand);
		rmSetAreaCoherence(patch, 0.3);
		rmSetAreaSmoothDistance(patch, 8);

		if(rmBuildArea(patch)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}

	}

	// Text
	rmSetStatusText("",0.40);

	// Place starting settlements.
	// Close things....
	// TC
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);

	// Settlements.
	//rmPlaceObjectDefPerPlayer(farSettlementID, true, 2);
	id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10, false, true);
	rmAddFairLocConstraint(id, avoidImpassableLand);

	id=rmAddFairLoc("Settlement", true, false, 70, 120, 60, 10, false, true);
	rmAddFairLocConstraint(id, avoidImpassableLand);

	if(rmPlaceFairLocs()) {
		id=rmCreateObjectDef("far settlement2");
		rmAddObjectDefItem(id, "Settlement", 1, 0.0);
		for(i=1; <cNumberPlayers) {
			for(j=0; <rmGetNumberFairLocs(i)) {
				rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
			}
		}
	}
	
	if(cMapSize == 2){
		int farID = -1;
		int TCgiant = rmCreateTypeDistanceConstraint("TCs vs TCs giant", "AbstractSettlement", 80.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			farID = rmCreateObjectDef("giant settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCgiant);
			rmAddObjectDefConstraint(farID, farStartingSettleConstraint);
			rmAddObjectDefConstraint(farID, avoidImpassableLand);
			for(attempt = 4; <= 12){
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
			for(attempt = 5; <= 12){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 30*attempt);
			}
		}
	}

	// Towers.
	rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

	// Straggler trees.
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

	// Text
	rmSetStatusText("",0.60);

	// Gold
	rmPlaceObjectDefPerPlayer(startingGoldID, false);

	rmPlaceObjectDefPerPlayer(closeChickensID, false);

	rmPlaceObjectDefPerPlayer(closeBerriesID, false);


	// Boar.
	rmPlaceObjectDefPerPlayer(closeBoarID, false);

	rmPlaceObjectDefPerPlayer(playerFishID, false);

	int fishID=rmCreateObjectDef("fish");
	rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);

	fishID=rmCreateObjectDef("fish2");
	rmAddObjectDefItem(fishID, "fish - perch", 2, 6.0);
	rmSetObjectDefMinDistance(fishID, 0.0);
	rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(fishID, fishVsFishID);
	rmAddObjectDefConstraint(fishID, fishLand);
	rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);

	int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
	int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
	int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
	int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);

	int sharkID=rmCreateObjectDef("shark");
	if(rmRandFloat(0,1)<0.5) {
		rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
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
	rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5*mapSizeMultiplier);

	// Medium things....
	// Gold
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);


	// Far things.

	// Gold.
	rmPlaceObjectDefPerPlayer(farGoldID, false, 3);

	// Relics
	rmPlaceObjectDefPerPlayer(relicID, false);

	// Hawks
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2);

	// Bonus huntable.
	rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	if(cMapSize == 2){
		rmSetObjectDefMinDistance(farGoldID, 0.0);
		rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.5));
		rmPlaceObjectDefPerPlayer(farGoldID, false, 3);
		rmPlaceObjectDefPerPlayer(relicID, false);
		rmAddObjectDefConstraint(bonusHuntableID, rmCreateTypeDistanceConstraint("giant avoid huntable", "huntable", 50.0));
		rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	}

	// Berries.
	rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers/2);

	// Predators
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

	// Text
	rmSetStatusText("",0.80);


	// Random trees.
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);

	// Elev.
	int numTries=6*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, cornerConstraint);
		rmAddAreaConstraint(elevID, avoidBuildings);
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
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}

	// Slight Elevation
	numTries=7*cNumberNonGaiaPlayers*mapSizeMultiplier;
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
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		rmAddAreaConstraint(elevID, avoidBuildings);


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


	// Forest.
	int classForest=rmDefineClass("forest");
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	int forestCount=10*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
		rmSetAreaWarnFailure(forestID, false);
		if(rmRandFloat(0.0, 1.0)<0.5) {
			rmSetAreaForestType(forestID, "oak forest");
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
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}


	// Grass
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);

	int rockID=rmCreateObjectDef("rock and grass");
	int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
	rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
	rmAddObjectDefItem(rockID, "grass", 2, 1.0);
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID, avoidRock);
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers*mapSizeMultiplier);


	int rockID2=rmCreateObjectDef("rock group");
	rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance(rockID2, 0.0);
	rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID2, avoidAll);
	rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
	rmAddObjectDefConstraint(rockID2, avoidRock);
	rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier);

	// Text
	rmSetStatusText("",1.0);

}
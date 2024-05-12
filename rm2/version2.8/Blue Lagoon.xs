/* **************************************************************************
** BLUE LAGOON
** Coded by RebelsRising Design&Concept by KeeN Flame
** 28th January 2017 Edited 13th of May 2020 by KeeN Flame
** *************************************************************************/
// EE 2.8
include "rms_lib.xs";

// Main entry point for random map script
void main(void) {	
	// Text
	rmSetStatusText("", 0.01);
	
	// Settings
	obs = false;
	map = "Blue Lagoon";
	
	// Assign players
	initPlayers(obs);
	
	// Set size
	int playerTiles = 7500;
	if(cMapSize == 1) {
		playerTiles = 9750;
	}
	int size = 2.0 * sqrt(cNonGaiaPlayers * playerTiles / 0.9);
	
	rmSetMapSize(size, size);
	
	// Initialize terrain
	rmTerrainInitialize("SandA");
	
	// Player placement
	if(obs) {
		rmSetPlacementTeam(cTeams);
		rmPlacePlayersCircular(0.4);
	}
	
	rmSetPlacementTeam(-1);
	rmSetTeamSpacingModifier(0.875);
	rmPlacePlayersCircular(0.35, 0.4, rmDegreesToRadians(4.0));
	
	// Text
	rmSetStatusText("", 0.1);
	
	// Initialize areas
	int classCorner = initializeCorners(0.045);
	int classSplit = initializeSplit(15.0, true);
	int classCenterline = initializeCenterline();
	if(cNonGaiaPlayers > 2) {
		int classTeamSplit = initializeTeamSplit(15.0, true);
	}
	
	// Define classes
	int classPlayer = rmDefineClass("player");
	int classPond = rmDefineClass("pond");
	int classCliff = rmDefineClass("cliff");
	int classStartingSettlement = rmDefineClass("starting settlement");
	int classForest = rmDefineClass("forest");
	
	// Define global constraints
	// General
	int shortavoidAll = rmCreateTypeDistanceConstraint("short avoid all", "All", 5.0);
	int avoidAll = rmCreateTypeDistanceConstraint("avoid all", "All", 7.0);
	int avoidEdge = rmCreateBoxConstraint("avoid edge of the map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0 - rmXTilesToFraction(4), 1.0 - rmZTilesToFraction(4));
	int avoidPlayer = rmCreateClassDistanceConstraint("avoid players", classPlayer, 1.0);
	
	// Terrain
	int avoidImpassableLand = rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 5.0);
	int shortAvoidCliff = rmCreateClassDistanceConstraint("short avoid cliff", classCliff, 8.0);
	int farAvoidCliff = rmCreateClassDistanceConstraint("far avoid cliff", classCliff, 25.0);
	
	// Settlements
	int avoidStartingSettlement = rmCreateClassDistanceConstraint("avoid starting settlement", classStartingSettlement, 20.0);
	int shortAvoidSettlement = rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 20.0);
	int goldAvoidSettlement = rmCreateTypeDistanceConstraint("gold avoid settlement", "AbstractSettlement", 25.0);
	int farAvoidSettlement = rmCreateTypeDistanceConstraint("far avoid settlement", "AbstractSettlement", 47.5);
	
	// Gold
	int avoidGold = rmCreateTypeDistanceConstraint("avoid gold", "Gold", 45.0);
	
	// Food
	int avoidFood = rmCreateTypeDistanceConstraint("avoid food sources", "Food", 20.0);
	int avoidHuntable = rmCreateTypeDistanceConstraint("avoid huntable", "Huntable", 40.0);
	int avoidHerdable = rmCreateTypeDistanceConstraint("avoid herdable", "Herdable", 40.0);
	
	// Buildings
	int avoidBuildings = rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
	int avoidTowerLOS = rmCreateTypeDistanceConstraint("avoid tower line of sight", "Tower", 35.0);
	
	// Define objects
	// Starting objects
	// Starting settlement
	int startingSettlementID = rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass(startingSettlementID, classStartingSettlement);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	
	// Towers
	int startingTowerID = rmCreateObjectDef("starting tower");
	rmAddObjectDefItem(startingTowerID, "Tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("tower avoids towers", "Tower", 25.0));
	
	// Starting gold
	int startingGoldID = rmCreateObjectDef("starting gold");
	rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
	rmSetObjectDefMinDistance(startingGoldID, 21.0);
	rmSetObjectDefMaxDistance(startingGoldID, 23.5);
	rmAddObjectDefConstraint(startingGoldID, shortavoidAll);
	rmAddObjectDefConstraint(startingGoldID, avoidEdge);
	rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(startingGoldID, avoidFood);
	
	// Close hunt
	int closeHuntID = rmCreateObjectDef("close hunt");
	rmAddObjectDefItem(closeHuntID, "Giraffe", rmRandInt(2, 3), 3.0);
	rmSetObjectDefMinDistance(closeHuntID, 20.0);
	rmSetObjectDefMaxDistance(closeHuntID, 25.0);
	rmAddObjectDefConstraint(closeHuntID, avoidAll);
	rmAddObjectDefConstraint(closeHuntID, avoidEdge);
	rmAddObjectDefConstraint(closeHuntID, avoidImpassableLand);
	
	// Starting food
	int startingFoodID = rmCreateObjectDef("starting food");
	rmAddObjectDefItem(startingFoodID, "Berry Bush", rmRandInt(5, 8), 3.5);
	rmSetObjectDefMinDistance(startingFoodID, 20.0);
	rmSetObjectDefMaxDistance(startingFoodID, 25.0);
	rmAddObjectDefConstraint(startingFoodID, avoidAll);
	rmAddObjectDefConstraint(startingFoodID, avoidEdge);
	rmAddObjectDefConstraint(startingFoodID, avoidFood);
	rmAddObjectDefConstraint(startingFoodID, avoidImpassableLand);
	
	// Starting herdables
	int startingHerdablesID = rmCreateObjectDef("starting herdables");
	rmAddObjectDefItem(startingHerdablesID, "Pig", rmRandInt(1, 3), 2.0);
	rmSetObjectDefMinDistance(startingHerdablesID, 25.0);
	rmSetObjectDefMaxDistance(startingHerdablesID, 30.0);
	rmAddObjectDefConstraint(startingHerdablesID, avoidAll);
	rmAddObjectDefConstraint(startingHerdablesID, avoidEdge);
	rmAddObjectDefConstraint(startingHerdablesID, avoidImpassableLand);
	
	// Straggler trees
	int cNumStragglerTree = rmRandInt(3, 6);
	
	int stragglerTreeID = rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem(stragglerTreeID, "Savannah Tree", 1, 0.0);
	rmSetObjectDefMinDistance(stragglerTreeID, 14.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 16.0);
	rmAddObjectDefConstraint(stragglerTreeID, avoidAll);
	
	// Gold	
	// Bonus gold
	int cNumBonusGold = rmRandInt(4, 5);
	if(cNonGaiaPlayers > 2) {
		cNumBonusGold = rmRandInt(3, 4);
	}
	
	int bonusGoldID = rmCreateObjectDef("bonus gold");
	rmAddObjectDefItem(bonusGoldID, "Gold Mine", 1, 0.0);
	rmAddObjectDefConstraint(bonusGoldID, avoidEdge);
	rmAddObjectDefConstraint(bonusGoldID, rmCreateClassDistanceConstraint("avoid corners", classCorner, 1.0));
	if(cNonGaiaPlayers < 3) {
		rmAddObjectDefConstraint(bonusGoldID, rmCreateClassDistanceConstraint("bonus gold avoids centerline", classCenterline, 15.0));
	}
	rmAddObjectDefConstraint(bonusGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusGoldID, shortAvoidCliff);
	rmAddObjectDefConstraint(bonusGoldID, goldAvoidSettlement);
	rmAddObjectDefConstraint(bonusGoldID, rmCreateClassDistanceConstraint("bonus gold avoids starting settlements", classStartingSettlement, 60.0));
	rmAddObjectDefConstraint(bonusGoldID, avoidGold);
	
	// Hunt
	// Medium hunt 1
	float cMediumHunt1Float = rmRandFloat(0, 1);
	
	int mediumHunt1ID = rmCreateObjectDef("medium hunt1");
	if(cMediumHunt1Float < 1.0 / 3.0) {
		rmAddObjectDefItem(mediumHunt1ID, "Zebra", rmRandInt(3, 6), 4.0);
	} else if(cMediumHunt1Float < 2.0 / 3.0) {
		rmAddObjectDefItem(mediumHunt1ID, "Gazelle", rmRandInt(4, 8), 4.0);
	} else {
		rmAddObjectDefItem(mediumHunt1ID, "Giraffe", rmRandInt(2, 4), 3.0);
	}
	rmSetObjectDefMinDistance(mediumHunt1ID, 55.0);
	rmSetObjectDefMaxDistance(mediumHunt1ID, 65.0);
	rmAddObjectDefConstraint(mediumHunt1ID, avoidAll);
	rmAddObjectDefConstraint(mediumHunt1ID, avoidEdge);
	rmAddObjectDefConstraint(mediumHunt1ID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumHunt1ID, shortAvoidCliff);
	rmAddObjectDefConstraint(mediumHunt1ID, rmCreateClassDistanceConstraint("medium hunt 1 avoids starting settlements", classStartingSettlement, 55.0));
	rmAddObjectDefConstraint(mediumHunt1ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumHunt1ID, avoidHuntable);
	rmAddObjectDefConstraint(mediumHunt1ID, avoidTowerLOS);
	
	// Medium hunt 2
	int mediumHunt2ID = rmCreateObjectDef("medium hunt2");
	if(rmRandFloat(0, 1) < 0.5) {
		rmAddObjectDefItem(mediumHunt2ID, "Elephant", 1, 0.0);
	} else {
		rmAddObjectDefItem(mediumHunt2ID, "Rhinocerous", rmRandInt(1, 2), 3.0);
	}
	rmAddObjectDefItem(mediumHunt2ID, "Gazelle", rmRandInt(0, 3), 3.0);
	rmSetObjectDefMinDistance(mediumHunt2ID, 60.0);
	rmSetObjectDefMaxDistance(mediumHunt2ID, 70.0);
	rmAddObjectDefConstraint(mediumHunt2ID, avoidAll);
	rmAddObjectDefConstraint(mediumHunt2ID, avoidEdge);
	rmAddObjectDefConstraint(mediumHunt2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumHunt2ID, shortAvoidCliff);
	rmAddObjectDefConstraint(mediumHunt2ID, rmCreateClassDistanceConstraint("medium hunt 2 avoids starting settlements", classStartingSettlement, 60.0));
	rmAddObjectDefConstraint(mediumHunt2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumHunt2ID, avoidHuntable);
	rmAddObjectDefConstraint(mediumHunt2ID, avoidTowerLOS);
	
	// Far hunt 1
	float cFarHunt1Float = rmRandFloat(0, 1);
	
	int farHunt1ID = rmCreateObjectDef("far hunt1");
	if(cFarHunt1Float < 1.0 / 3.0) {
		rmAddObjectDefItem(farHunt1ID, "Gazelle", rmRandInt(0, 4), 3.0);
		rmAddObjectDefItem(farHunt1ID, "Zebra", rmRandInt(3, 6), 4.0);
	} else if(cFarHunt1Float < 2.0 / 3.0) {
		rmAddObjectDefItem(farHunt1ID, "Gazelle", rmRandInt(1, 3), 3.0);
		rmAddObjectDefItem(farHunt1ID, "Giraffe", rmRandInt(2, 5), 3.0);
	} else {
		rmAddObjectDefItem(farHunt1ID, "Zebra", rmRandInt(3, 9), 4.0);
	}
	rmSetObjectDefMinDistance(farHunt1ID, 70.0);
	rmSetObjectDefMaxDistance(farHunt1ID, 80.0);
	rmAddObjectDefConstraint(farHunt1ID, avoidAll);
	rmAddObjectDefConstraint(farHunt1ID, avoidEdge);
	rmAddObjectDefConstraint(farHunt1ID, avoidImpassableLand);
	rmAddObjectDefConstraint(farHunt1ID, shortAvoidCliff);
	rmAddObjectDefConstraint(farHunt1ID, rmCreateClassDistanceConstraint("far hunt 1 avoids starting settlements", classStartingSettlement, 70.0));
	rmAddObjectDefConstraint(farHunt1ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farHunt1ID, avoidHuntable);
	
	// Far hunt 2
	int farHunt2ID = rmCreateObjectDef("far hunt2");
	if(rmRandFloat(0, 1) < 0.5) {
		rmAddObjectDefItem(farHunt2ID, "Elephant", rmRandInt(1, 2), 3.0);
	} else {
		rmAddObjectDefItem(farHunt2ID, "Rhinocerous", rmRandInt(1, 3), 3.0);
	}
	rmSetObjectDefMinDistance(farHunt2ID, 70.0);
	rmSetObjectDefMaxDistance(farHunt2ID, 100.0);
	rmAddObjectDefConstraint(farHunt2ID, avoidAll);
	rmAddObjectDefConstraint(farHunt2ID, avoidEdge);
	rmAddObjectDefConstraint(farHunt2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(farHunt2ID, shortAvoidCliff);
	rmAddObjectDefConstraint(farHunt2ID, rmCreateClassDistanceConstraint("far hunt 2 avoids starting settlements", classStartingSettlement, 70.0));
	rmAddObjectDefConstraint(farHunt2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farHunt2ID, avoidHuntable);

	// Bonus tg hunt
	int bonusHuntID = rmCreateObjectDef("bonus hunt");
	rmAddObjectDefItem(bonusHuntID, "Gazelle", rmRandInt(2, 5), 4.0);
	rmAddObjectDefItem(bonusHuntID, "Giraffe", rmRandInt(2, 3), 3.0);
	rmAddObjectDefConstraint(bonusHuntID, avoidAll);
	rmAddObjectDefConstraint(bonusHuntID, avoidEdge);
	rmAddObjectDefConstraint(bonusHuntID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntID, shortAvoidCliff);
	rmAddObjectDefConstraint(bonusHuntID, rmCreateClassDistanceConstraint("bonus hunt avoids starting settlements", classStartingSettlement, 100.0));
	rmAddObjectDefConstraint(bonusHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntID, avoidHuntable);
	
	// Herdables and predators
	// Medium herdables
	int mediumHerdablesID = rmCreateObjectDef("medium herdables");
	rmAddObjectDefItem(mediumHerdablesID, "Pig", rmRandInt(1, 2), 2.0);
	rmSetObjectDefMinDistance(mediumHerdablesID, 50.0);
	rmSetObjectDefMaxDistance(mediumHerdablesID, 70.0);
	rmAddObjectDefConstraint(mediumHerdablesID, avoidAll);
	rmAddObjectDefConstraint(mediumHerdablesID, avoidEdge);
	rmAddObjectDefConstraint(mediumHerdablesID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumHerdablesID, rmCreateClassDistanceConstraint("medium herdables avoid starting settlements", classStartingSettlement, 50.0));
	rmAddObjectDefConstraint(mediumHerdablesID, avoidHerdable);
	rmAddObjectDefConstraint(mediumHerdablesID, avoidTowerLOS);
	
	// Far herdables
	int farHerdablesID = rmCreateObjectDef("far herdables");
	rmAddObjectDefItem(farHerdablesID, "Pig", rmRandInt(2, 3), 2.0);
	rmSetObjectDefMinDistance(farHerdablesID, 80.0);
	rmSetObjectDefMaxDistance(farHerdablesID, 120.0);
	rmAddObjectDefConstraint(farHerdablesID, avoidAll);
	rmAddObjectDefConstraint(farHerdablesID, avoidEdge);
	rmAddObjectDefConstraint(farHerdablesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farHerdablesID, rmCreateClassDistanceConstraint("far herdables avoid starting settlements", classStartingSettlement, 80.0));
	rmAddObjectDefConstraint(farHerdablesID, avoidHerdable);
	
	// Far predators
	int farPredatorsID = rmCreateObjectDef("far predators");
	if(rmRandFloat(0, 1) < 0.5) {
		rmAddObjectDefItem(farPredatorsID, "Lion", rmRandInt(1, 2), 4.0);
	} else {
		rmAddObjectDefItem(farPredatorsID, "Hyena", 2, 4.0);
	}
	rmSetObjectDefMinDistance(farPredatorsID, 80.0);
	rmSetObjectDefMaxDistance(farPredatorsID, 100.0);
	rmAddObjectDefConstraint(farPredatorsID, avoidAll);
	rmAddObjectDefConstraint(farPredatorsID, avoidEdge);
	rmAddObjectDefConstraint(farPredatorsID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorsID, rmCreateClassDistanceConstraint("predators avoid starting settlements", classStartingSettlement, 80.0));
	rmAddObjectDefConstraint(farPredatorsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farPredatorsID, avoidFood);
	rmAddObjectDefConstraint(farPredatorsID, rmCreateTypeDistanceConstraint("far predators avoid predators", "AnimalPredator", 40.0));
	
	// Other objects
	// Relics
	int relicID = rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "Relic", 1, 0.0);
	rmAddObjectDefConstraint(relicID, avoidAll);
	rmAddObjectDefConstraint(relicID, avoidEdge);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmAddObjectDefConstraint(relicID, rmCreateClassDistanceConstraint("relics avoid starting settlements", classStartingSettlement, 80.0));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relics avoid relics", "Relic", 80.0));
	
	// Random trees
	int cNumRandomTrees = 10;
	
	int randomTreeID = rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "Savannah Tree", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, avoidAll);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, rmCreateClassDistanceConstraint("random trees avoid starting settlement", classStartingSettlement, 28.0));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random trees avoid settlement", "AbstractSettlement", 14.0));
	
	// Text
	rmSetStatusText("", 0.2);
	
	// Set up player areas
	int playerAreaID = 0;
	float cPlayerAreaSize = rmAreaTilesToFraction(1000);
	
	for(i = 1; < cPlayers) {
		playerAreaID = rmCreateArea("player area" + getPlayer(i));
		rmSetAreaSize(playerAreaID, 0.9 * cPlayerAreaSize, 1.1 * cPlayerAreaSize);
		rmSetAreaLocPlayer(playerAreaID, getPlayer(i));
		rmSetAreaTerrainType(playerAreaID, "GrassDirt25");
		rmAddAreaTerrainLayer(playerAreaID, "GrassDirt50", 3, 6);
		rmAddAreaTerrainLayer(playerAreaID, "GrassDirt75", 0, 3);
		rmSetAreaMinBlobs(playerAreaID, 1);
		rmSetAreaMaxBlobs(playerAreaID, 3);
		rmSetAreaMinBlobDistance(playerAreaID, 16.0);
		rmSetAreaMaxBlobDistance(playerAreaID, 40.0);
		rmAddAreaToClass(playerAreaID, classPlayer);
		rmAddAreaConstraint(playerAreaID, avoidPlayer);
		rmSetAreaWarnFailure(playerAreaID, false);
	}

	rmBuildAllAreas();
	
	// Text
	rmSetStatusText("", 0.3);
	
	// Settlements
	// Setup
	bool done = true;
	int settlementID = 0;
	float getDist = 0;
	float distP1 = 0;
	float distP2 = 0;
	
	// Adjustment
	float distFar = 55.0;
	float distClose = 42.5;
	float tol = 0.125;
	
	// Starting settlement
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(startingSettlementID, getPlayer(i), rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Close settlements
	// Place close settlements first to get a good restriction for far settlements
	settlementID = rmAddFairLoc("close settlement", false, true, 65, 80, distClose, 20, true);
	
	if(rmPlaceFairLocs()) {
		settlementID = rmCreateObjectDef("close settlements");
		rmAddObjectDefItem(settlementID, "Settlement", 1, 0.0);
		
		for(i = 1; < cPlayers) {
			for(j = 0; < rmGetNumberFairLocs(getPlayer(i))) {
				rmPlaceObjectDefAtLoc(settlementID, 0, rmFairLocXFraction(getPlayer(i), j), rmFairLocZFraction(getPlayer(i), j));
			}
		}
	}
	
	rmResetFairLocs();
	
	// Far settlements
	failCount = 0;
	float settleFloat = rmRandFloat(0, 1);
	
	// Constraints
	int farSettlementsAvoidStartingSettlement = rmCreateClassDistanceConstraint("far settlements avoid starting settlements", classStartingSettlement, 65.0);
	int farSettlementsAvoidCloseSettlements = rmCreateTypeDistanceConstraint("far settlements avoid close settlements", "AbstractSettlement", distFar);
	
	while(failCount < 50) {
		done = true;
		
		if(cNonGaiaPlayers < 3) {
			settlementID = rmAddFairLoc("far settlement", true, false, 65, 80, 0, rmRandInt(60, 80), true);
		} else if(cNonGaiaPlayers < 5) {
			if(settleFloat < 0.5) {
				settlementID = rmAddFairLoc("far settlement", true, false, 70, 80, 0, 50, false, true);
			} else {
				settlementID = rmAddFairLoc("far settlement", true, true, 70, 90, 0, 100, false, true);
			}
		} else {
			settlementID = rmAddFairLoc("far settlement", true, false, 65, 80, 0, rmRandInt(50, 60), false, true);
		}
		
		rmAddFairLocConstraint(settlementID, farSettlementsAvoidStartingSettlement);
		rmAddFairLocConstraint(settlementID, farSettlementsAvoidCloseSettlements);
		
		if(rmPlaceFairLocs()) {
			for(i = 1; < cNonGaiaPlayers) {
				for(j = i + 1; < cPlayers) {
					getDist = rmXFractionToMeters(pointsGetDist(rmFairLocXFraction(getPlayer(i), 0), rmFairLocZFraction(getPlayer(i), 0), rmFairLocXFraction(getPlayer(j), 0), rmFairLocZFraction(getPlayer(j), 0)));
					
					if(getDist < distFar) {
						//rmEchoError(i + " " + j + " " + getDist);
						done = false;
					}
				}	
			}
			
			if(cNonGaiaPlayers < 3 && done == true) {
				distP1 = pointsGetDist(rmPlayerLocXFraction(getPlayer(1)), rmPlayerLocZFraction(getPlayer(1)), rmFairLocXFraction(getPlayer(2), 0), rmFairLocZFraction(getPlayer(2), 0));
				distP2 = pointsGetDist(rmPlayerLocXFraction(getPlayer(2)), rmPlayerLocZFraction(getPlayer(2)), rmFairLocXFraction(getPlayer(1), 0), rmFairLocZFraction(getPlayer(1), 0));
				
				//rmEchoError(distP1 + " " + distP2);
				//rmEchoError(" " + (distP1 / distP2));
				
				if((distP1 / distP2) > (1.0 + tol) || (distP1 / distP2) < (1.0 - tol)) {
					done = false;
				}
			}
			
			if(done == true) {
				settlementID = rmCreateObjectDef("far settlements");
				rmAddObjectDefItem(settlementID, "Settlement", 1, 0.0);
				
				for(i = 1; < cPlayers) {
					for(j = 0; < rmGetNumberFairLocs(getPlayer(i))) {
						rmPlaceObjectDefAtLoc(settlementID, 0, rmFairLocXFraction(getPlayer(i), j), rmFairLocZFraction(getPlayer(i), j));
					}
				}
				
				rmResetFairLocs();
				break;
			}
		}
		
		//rmEchoError("" + failCount);
		
		rmResetFairLocs();
		failCount++;
	}
	
	//msg = "" + failCount;
	
	// Towers
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(startingTowerID, getPlayer(i), rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)), 4);
	}
	
	// Text
	rmSetStatusText("", 0.4);
	
	// Ponds
	int placeCount = 0;
	int pondID = 0;
	int decorationID = 0;
	int cNumPonds = 2 * cNonGaiaPlayers;
	int cNumTries = 150;
	int shortAvoidPond = rmCreateClassDistanceConstraint("short avoid pond", classPond, 8.0);
	int farAvoidPond = rmCreateClassDistanceConstraint("far avoid pond", classPond, 25.0);
	
	for(i = 0; < cNumTries) {
		pondID = rmCreateArea("pond" + i);
		rmSetAreaSize(pondID, rmAreaTilesToFraction(400), rmAreaTilesToFraction(400));
		if(cNonGaiaPlayers < 3) {
			rmSetAreaLocation(pondID, rmRandFloat(0.25, 0.75), rmRandFloat(0.25, 0.75));
		} else {
			rmSetAreaLocation(pondID, rmRandFloat(0.05, 0.95), rmRandFloat(0.05, 0.95));
		}
		rmSetAreaWaterType(pondID, "Egyptian Nile");
		rmSetAreaCoherence(pondID, 1.0);
		rmAddAreaToClass(pondID, classPond);
		rmAddAreaConstraint(pondID, farAvoidPond);
		rmAddAreaConstraint(pondID, farAvoidSettlement);
		rmAddAreaConstraint(pondID, avoidTowerLOS);
		rmSetAreaWarnFailure(pondID, false);

		if(rmBuildArea(pondID) == true) {
			placeCount ++;			
			decorationID = rmCreateObjectDef("decoration" + i);
			rmAddObjectDefItem(decorationID, "Papyrus", rmRandInt(1, 3), 5.0);
			rmAddObjectDefItem(decorationID, "Water Decoration", rmRandInt(1, 3), 6.0);
			rmPlaceObjectDefInArea(decorationID, 0, pondID, rmRandInt(2, 5));

			if(placeCount >= cNumPonds) {
				break;
			}
		}
	}

	// Beautification
	int beautificationID = 0;
	
	for(i = 0; < 25 * cPlayers) {
		beautificationID = rmCreateArea("beautification1 " + i);
		rmSetAreaTerrainType(beautificationID, "GrassDirt50");
		rmAddAreaTerrainLayer(beautificationID, "GrassDirt75", 0, 2);
		rmSetAreaSize(beautificationID, rmAreaTilesToFraction(75), rmAreaTilesToFraction(150));
		rmSetAreaMinBlobs(beautificationID, 1);
		rmSetAreaMaxBlobs(beautificationID, 5);
		rmSetAreaMinBlobDistance(beautificationID, 16.0);
		rmSetAreaMaxBlobDistance(beautificationID, 40.0);
		rmAddAreaConstraint(beautificationID, avoidPlayer);
		rmAddAreaConstraint(beautificationID, avoidImpassableLand);
		rmSetAreaWarnFailure(beautificationID, false);
		rmBuildArea(beautificationID);
	}
	
	for(i = 0; < 40 * cNonGaiaPlayers) {
		beautificationID = rmCreateArea("beautification2 " + i);
		rmSetAreaSize(beautificationID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(125));
		rmSetAreaBaseHeight(beautificationID, rmRandFloat(1.0, 3.0));
		rmSetAreaHeightBlend(beautificationID, 1);
		rmSetAreaMinBlobs(beautificationID, 1);
		rmSetAreaMaxBlobs(beautificationID, 3);
		rmSetAreaMinBlobDistance(beautificationID, 16.0);
		rmSetAreaMaxBlobDistance(beautificationID, 20.0);
		rmAddAreaConstraint(beautificationID, avoidPlayer);
		rmAddAreaConstraint(beautificationID, avoidImpassableLand);
		rmAddAreaConstraint(beautificationID, avoidBuildings);
		rmSetAreaWarnFailure(beautificationID, false);
		rmBuildArea(beautificationID);
	}
	
	// Cliffs
	int cliffID = 0;
	int cNumCliffs = 4 * cNonGaiaPlayers;
	cNumTries = 150;
	placeCount = 0;
	
	for(i = 0; < cNumTries) {
		cliffID = rmCreateArea("cliff" + i);
		rmSetAreaSize(cliffID, rmAreaTilesToFraction(200), rmAreaTilesToFraction(225));
		rmSetAreaCliffType(cliffID, "Egyptian");
		rmSetAreaCoherence(cliffID, 1.0);
		rmSetAreaCliffEdge(cliffID, 2, 0.25, 0.0, 1.0, 1);
		rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, true);
		rmSetAreaCliffHeight(cliffID, 4, 0.0, 1.0);
		rmSetAreaHeightBlend(cliffID, 1.0);
		rmAddAreaToClass(cliffID, classCliff);
		rmAddAreaConstraint(cliffID, avoidEdge);
		rmAddAreaConstraint(cliffID, shortAvoidPond);
		rmAddAreaConstraint(cliffID, farAvoidCliff);
		rmAddAreaConstraint(cliffID, shortAvoidSettlement);
		rmAddAreaConstraint(cliffID, avoidBuildings);
		rmSetAreaWarnFailure(cliffID, false);

		if(rmBuildArea(cliffID) == true) {
			placeCount ++;
			if(placeCount >= cNumCliffs) {
				break;
			}
		}
	}
	
	// Text
	rmSetStatusText("", 0.5);
	
	// Place objects
	// Starting objects
	// Placing starting gold and starting herdables after far objects to not influence the placement of the latter.
	// Close hunt
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(closeHuntID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Starting food
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(startingFoodID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Gold
	// Bonus gold
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefInArea(bonusGoldID, 0, rmAreaID("split" + getPlayer(i)), cNumBonusGold);
	}
	
	// Starting gold
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(startingGoldID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Hunt
	// Medium hunt 1
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(mediumHunt1ID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Medium hunt 2
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(mediumHunt2ID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Far hunt 1
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(farHunt1ID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Far hunt 2
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(farHunt2ID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Bonus hunt
	if(cNonGaiaPlayers > 4) {
		for(i = 1; < cPlayers) {
			rmPlaceObjectDefInArea(bonusHuntID, 0, rmAreaID("split" + getPlayer(i)));
		}
	}
	
	// Text
	rmSetStatusText("", 0.6);
	
	// Forest
	int avoidForest = rmCreateClassDistanceConstraint("avoid forest", classForest, 20.0);
	
	// Player forest
	int playerForestAreaID = 0;
	int playerForestID = 0;
	int cNumPlayerForest = 2;
	float cForestAreaSize = rmAreaTilesToFraction(2200);
	
	for(i = 1; < cPlayers) {
		failCount = 0;
		
		playerForestAreaID = rmCreateArea("player forest area" + getPlayer(i));
		rmSetAreaSize(playerForestAreaID, cForestAreaSize, cForestAreaSize);
		rmSetAreaLocPlayer(playerForestAreaID, getPlayer(i));
		rmSetAreaCoherence(playerForestAreaID, 1.0);
		rmSetAreaWarnFailure(playerForestAreaID, false);
		rmBuildArea(playerForestAreaID);
		
		for(j = 0; < cNumPlayerForest) {			
			playerForestID = rmCreateArea("player forest" + i + " " + j, playerForestAreaID);
			rmSetAreaSize(playerForestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(80));
			rmSetAreaForestType(playerForestID, "Savannah Forest");
			rmSetAreaMinBlobs(playerForestID, 3);
			rmSetAreaMaxBlobs(playerForestID, 5);
			rmSetAreaMinBlobDistance(playerForestID, 16.0);
			rmSetAreaMaxBlobDistance(playerForestID, 32.0);
			rmAddAreaToClass(playerForestID, classForest);
			rmAddAreaConstraint(playerForestID, avoidAll);
			rmAddAreaConstraint(playerForestID, avoidImpassableLand);
			rmAddAreaConstraint(playerForestID, shortAvoidCliff);
			rmAddAreaConstraint(playerForestID, avoidStartingSettlement);
			rmAddAreaConstraint(playerForestID, avoidForest);
			rmSetAreaWarnFailure(playerForestID, false);

			if(rmBuildArea(playerForestID) == false) {
				failCount ++;
				if(failCount == 3) {
					break;
				}
			} else {
				failCount = 0;
			}
		}
	}
	
	// Forest
	failCount = 0;
	int forestID = 0;
	int cNumForest = 10 * cNonGaiaPlayers;
	
	for(i = 0; < cNumForest) {
		forestID = rmCreateArea("forest" + i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(80));
		rmSetAreaForestType(forestID, "Savannah Forest");
		rmSetAreaMinBlobs(forestID, 3);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 32.0);
		rmAddAreaToClass(forestID, classForest);
		rmAddAreaConstraint(forestID, avoidAll);
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaConstraint(forestID, shortAvoidCliff);
		rmAddAreaConstraint(forestID, avoidStartingSettlement);
		rmAddAreaConstraint(forestID, avoidForest);
		rmSetAreaWarnFailure(forestID, false);
		
		if(rmBuildArea(forestID) == false) {
			failCount ++;
			if(failCount == 3) {
				break;
			}
		} else {
			failCount = 0;
		}
	}
	
	// Straggler trees
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(stragglerTreeID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)), cNumStragglerTree);
	}
	
	// Text
	rmSetStatusText("", 0.7);
	
	// Herdables	
	// Medium herdables
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(mediumHerdablesID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Far herdables
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(farHerdablesID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Starting herdables
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(startingHerdablesID, getPlayer(i), rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Far predators
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(farPredatorsID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)));
	}
	
	// Relics
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefInArea(relicID, 0, rmAreaID("split" + getPlayer(i)));
	}
	
	// Random trees
	for(i = 1; < cPlayers) {
		rmPlaceObjectDefAtLoc(randomTreeID, 0, rmPlayerLocXFraction(getPlayer(i)), rmPlayerLocZFraction(getPlayer(i)), cNumRandomTrees);
	}
	
	// Text
	rmSetStatusText("", 0.8);
	
	// Embellishment
	int embellishmentAvoidAll = rmCreateTypeDistanceConstraint("embellishment avoid all", "All", 3.0);

	// Lone hunt
	int loneHuntID = rmCreateObjectDef("lonely hunt");
	if(rmRandFloat(0, 1) < 0.5) {
		rmAddObjectDefItem(loneHuntID, "Monkey", 1, 0.0);
	} else {
		rmAddObjectDefItem(loneHuntID, "Baboon", 1, 0.0);
	}
	rmSetObjectDefMinDistance(loneHuntID, 0.0);
	rmSetObjectDefMaxDistance(loneHuntID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(loneHuntID, avoidAll);
	rmAddObjectDefConstraint(loneHuntID, avoidImpassableLand);
	rmAddObjectDefConstraint(loneHuntID, rmCreateClassDistanceConstraint("lone hunt avoids starting settlement", classStartingSettlement, 70.0));
	rmAddObjectDefConstraint(loneHuntID, shortAvoidSettlement);
	rmAddObjectDefConstraint(loneHuntID, avoidFood);
	rmPlaceObjectDefAtLoc(loneHuntID, 0, 0.5, 0.5, 2 * cNonGaiaPlayers);

	// Rocks
	int rock1ID = rmCreateObjectDef("rock small");
	rmAddObjectDefItem(rock1ID, "Rock Sandstone Small", 1, 0.0);
	rmSetObjectDefMinDistance(rock1ID, 0.0);
	rmSetObjectDefMaxDistance(rock1ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rock1ID, embellishmentAvoidAll);
	rmAddObjectDefConstraint(rock1ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rock1ID, 0, 0.5, 0.5, 10 * cNonGaiaPlayers);

	int rock2ID = rmCreateObjectDef("rock sprite");
	rmAddObjectDefItem(rock2ID, "Rock Sandstone Sprite", 1, 0.0);
	rmSetObjectDefMinDistance(rock2ID, 0.0);
	rmSetObjectDefMaxDistance(rock2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rock2ID, embellishmentAvoidAll);
	rmAddObjectDefConstraint(rock2ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(rock2ID, 0, 0.5, 0.5, 30 * cNonGaiaPlayers);
	
	// Bushes
	int bush1ID = rmCreateObjectDef("bush1");
	rmAddObjectDefItem(bush1ID, "Bush", 4, 4.0);
	rmSetObjectDefMinDistance(bush1ID, 0.0);
	rmSetObjectDefMaxDistance(bush1ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bush1ID, embellishmentAvoidAll);
	rmAddObjectDefConstraint(bush1ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(bush1ID, 0, 0.5, 0.5, 5 * cNonGaiaPlayers);
	
	int bush2ID = rmCreateObjectDef("bush2");
	rmAddObjectDefItem(bush2ID, "Bush", 3, 2.0);
	rmAddObjectDefItem(bush2ID, "Rock Sandstone Sprite", 1, 2.0);
	rmSetObjectDefMinDistance(bush2ID, 0.0);
	rmSetObjectDefMaxDistance(bush2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bush2ID, embellishmentAvoidAll);
	rmAddObjectDefConstraint(bush2ID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 5 * cNonGaiaPlayers);
	
	// Grass
	int grassID = rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "Grass", 1, 0.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, embellishmentAvoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 30 * cNonGaiaPlayers);
	
	// Drifts
	int driftID = rmCreateObjectDef("drift");
	rmAddObjectDefItem(driftID, "Sand Drift Patch", 1, 0.0);
	rmSetObjectDefMinDistance(driftID, 0.0);
	rmSetObjectDefMaxDistance(driftID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(driftID, embellishmentAvoidAll);
	rmAddObjectDefConstraint(driftID, avoidEdge);
	rmAddObjectDefConstraint(driftID, avoidImpassableLand);
	rmAddObjectDefConstraint(driftID, avoidBuildings);
	rmAddObjectDefConstraint(driftID, rmCreateTypeDistanceConstraint("avoid drifts", "Sand Drift Patch", 25.0));
	rmPlaceObjectDefAtLoc(driftID, 0, 0.5, 0.5, 3 * cNonGaiaPlayers);
	
	// Birds
	int birdsID = rmCreateObjectDef("birds");
	rmAddObjectDefItem(birdsID, "Vulture", 1, 0.0);
	rmSetObjectDefMinDistance(birdsID, 0.0);
	rmSetObjectDefMaxDistance(birdsID, rmXFractionToMeters(0.5));
	rmPlaceObjectDefAtLoc(birdsID, 0, 0.5, 0.5, 2 * cNonGaiaPlayers);
	
	// Text
	rmSetStatusText("", 0.9);

	// Text
	rmSetStatusText("", 1.0);
}
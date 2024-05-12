/*	Map Name: Land Unkown.xs
**	Fast-Paced Ruleset 1: Watering Hole.xs
**	Fast-Paced Ruleset 2: Alfheim.xs
**	Author: Milkman Matty
**	Made for Forgotten Empires.
**	You will never need a ship <- ES has never told a more blatant lie.
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
	
	int mapSizeMulitplier = 1;
	int playerTiles=7500;
	if(cMapSize == 1) {
		playerTiles = 9750;
		rmEchoInfo("Large map");
	} else if (cMapSize == 2) {
		playerTiles = 15000;
		rmEchoInfo("Giant map");
		mapSizeMulitplier = 2;
	}
	int sizel=0;
	int sizew=0;
	
	/* ZERO STEP determine square or rectangular */
	float rectangularness=rmRandFloat(0,1);
	if(rectangularness<0.70) {					/* square */
		sizel=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
		sizew=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	} else if(rectangularness<0.85) {			/* longer than wide */
		sizel=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizew=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
	} else {									/* wider than long */  
		sizew=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
		sizel=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
	}
	rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
	rmSetMapSize(sizel, sizew);
	
	/* FIRST STEP determine which terrain the map uses */
	int terrainChance = rmRandInt(0, 2);
	/* Greek = 0, Egyptian = 1, Norse = 2 */

	if(terrainChance == 0) {
		rmEchoInfo("terrain chance "+terrainChance+ " Greek");
	} else if(terrainChance == 1) {
		rmEchoInfo("terrain chance "+terrainChance+ " Egyptian");
	} else {
		rmEchoInfo("terrain chance "+terrainChance+ " Norse");
	}

	/* SECOND STEP determine if base terrain is land or water. No longer ice. */
	rmSetSeaLevel(0.0);
	int fishExist = 0;
	int bigForestExist = 0;
	int savannah = 0;
	float baseTerrainChance = 0;
	if(terrainChance == 0) {
		baseTerrainChance = rmRandFloat(0,1); 
		rmEchoInfo("base terrain chance "+baseTerrainChance);
		if(baseTerrainChance < 0.15) {        /* Greek ocean */
			rmSetSeaType("mediterranean sea");
			rmTerrainInitialize("water");
			fishExist = 1;
		} else {
			rmTerrainInitialize("GrassA"); /* Greek land */
			bigForestExist = 1;
		}
	} else if(terrainChance == 2) {
		baseTerrainChance = rmRandFloat(0, 1);
		if(baseTerrainChance < 0.15) {   /* Norse ocean */
			rmSetSeaType("norwegian sea");
			rmTerrainInitialize("water");
			rmEchoInfo("water");
			fishExist = 1;
		} else {
			rmTerrainInitialize("SnowA"); /* Norse land */
			rmEchoInfo("snow");
			bigForestExist = 1;
		}
	} else if(terrainChance == 1) {
		baseTerrainChance = rmRandFloat(0,1); 
		if(baseTerrainChance < 0.15) {  /* Egyptian ocean */
			if(rmRandFloat(0,1)<0.25) {
				savannah = 1;
				}
			rmSetSeaType("red sea");
			rmTerrainInitialize("water");
			fishExist = 1;
		} else {
			if(rmRandFloat(0,1)<0.75) {
				rmTerrainInitialize("SandB"); /* Egyptian land */
			} else {
				rmTerrainInitialize("SavannahB");
				savannah = 1;
			}         
			bigForestExist = 1;   
		}
	}
	rmEchoInfo("Base terrain chance "+baseTerrainChance);
	
	rmSetStatusText("",0.07);
	
	/* ***************** */
	/* Section 2 Classes */
	/* ***************** */
	
	int classPlayer = rmDefineClass("player");
	int classTeam = rmDefineClass("team");
	int classForest = rmDefineClass("forest");
	int classPatch = rmDefineClass("patch");
	int classCenter = rmDefineClass("center");
	int classCliff = rmDefineClass("cliff");
	int classStartingSettlement = rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.13);
	
	/* **************************** */
	/* Section 3 Global Constraints */
	/* **************************** */
	// For Areas and Objects. Local Constraints should be defined right before they are used.
	
	int patchCenterConstraint=rmCreateClassDistanceConstraint("patch don't mess up center", rmClassID("center"), 30.0);
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(10), rmZTilesToFraction(10), 1.0-rmXTilesToFraction(10), 1.0-rmZTilesToFraction(10));
	int centerConstraint=rmCreateClassDistanceConstraint("PLAYERS stay away from center", rmClassID("center"), 15.0);
	int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
	int forestObjConstraint=rmCreateTypeDistanceConstraint("forest avoid obj", "all", 6.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
	int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
	
	rmSetStatusText("",0.20);
	
	/* ********************* */
	/* Section 4 Map Outline */
	/* ********************* */
	
	int teamLands = 0;
	
	float togetherness=rmRandFloat(0,1);
	rmEchoInfo("togetherness "+togetherness);
	
	int playerVsPlayerConstraint=0;
	
	/* never avoid on water map */
	if (baseTerrainChance < 0.15) {
		playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a little", classPlayer, 0);
		rmEchoInfo("avoid players by 0");
	} else {
		/* normal distance */
		if(togetherness < 0.5) {
			playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a lot", classPlayer, 20);
			rmEchoInfo("avoid players by 20");
		
		/* right together */
		} else if(togetherness < 0.8) {
			playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a little", classPlayer, 0);
			rmEchoInfo("avoid players by 0");
		
		/* small constraint */
		} else {
			playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a little", classPlayer, 10);
			rmEchoInfo("avoid players by 10");
		}
	}
	
	float edgeConstraintChance=rmRandFloat(0,1);
	float playerMinCircle = 0;
	float playerMaxCircle = 0;
	
	/* edge */
	if(edgeConstraintChance < 0.5) {
		playerMinCircle = 0.30;
		playerMaxCircle = 0.35;
		rmEchoInfo("edge chance "+edgeConstraintChance+ "= edge");
		rmPlacePlayersSquare(playerMinCircle, 0.05, 0.05);
		rmEchoInfo("square "+playerMinCircle+ " + 0.05");
	/* no edge */
	} else {
		playerMinCircle = 0.40;
		playerMaxCircle = 0.43;
		rmEchoInfo("edge chance "+edgeConstraintChance+ "= no edge");
		rmPlacePlayersCircular(playerMinCircle, playerMaxCircle, rmDegreesToRadians(5.0));
		rmEchoInfo("circle min"+playerMinCircle+ " max "+playerMaxCircle);
	}   
	rmRecordPlayerLocations();	
	
	float teamTogetherness=rmRandFloat(0,1);
	/* together a bit */
	if(teamTogetherness < 0.4) {
		rmSetTeamSpacingModifier(0.5);
	
	/* together a lot */
	} else if(teamTogetherness < 0.55) {
		rmSetTeamSpacingModifier(0.75);
	}
	
	float resourceChance = rmRandFloat(0,1);
	if(resourceChance < 0.1){
		for(i=1; <cNumberPlayers){
			rmAddPlayerResource(i, "Food", 200);
			rmAddPlayerResource(i, "Wood", 100);
		}
	} else if(resourceChance < 0.15){
		for(i=1; <cNumberPlayers) {
			rmAddPlayerResource(i, "Food", 200);
			rmAddPlayerResource(i, "Wood", 200);
			rmAddPlayerResource(i, "Gold", 200);
		}
	} else if(resourceChance < 0.2) {
		for(i=1; <cNumberPlayers) {
			rmAddPlayerResource(i, "Food", 400);
			rmAddPlayerResource(i, "Wood", 300);
			rmAddPlayerResource(i, "Gold", 200);
			rmAddPlayerResource(i, "Favor", 20);
		}
	} else if(resourceChance < 0.23) {
		for(i=1; <cNumberPlayers) {
			if(rmRandFloat(0,1)<0.33) {
				rmAddPlayerResource(i, "Food", 50);
			} else if(rmRandFloat(0,1)<0.5) {
				rmAddPlayerResource(i, "Wood", 50);
			} else {
				rmAddPlayerResource(i, "Gold", 50);
			}
		}
	} else if(resourceChance < 0.26) {
		for(i=1; <cNumberPlayers) {
			if(rmRandFloat(0,1)<0.33) {
				rmAddPlayerResource(i, "Food", 100);
			} else if(rmRandFloat(0,1)<0.5) {
				rmAddPlayerResource(i, "Wood", 100);
			} else {
				rmAddPlayerResource(i, "Gold", 100);
			}
		}
	}
	
	int centerID=rmCreateArea("center");
	float centerChance=rmRandFloat(0,1); 
	float centerPosition=rmRandFloat(0,1);
	int centerType = 0;
	/* but what if center is off to one side? */

	if(centerPosition < 0.6) {
		rmSetAreaLocation(centerID, 0.5, 0.5);
		rmSetAreaSize(centerID, 0.08, 0.15);
		rmAddAreaToClass(centerID, rmClassID("center"));
	} else if(centerPosition < 0.7) {
		rmSetAreaLocation(centerID, 1, 0.5);
		rmSetAreaSize(centerID, 0.05, 0.08);
	} else if(centerPosition < 0.8) {
		rmSetAreaLocation(centerID, 0.5, 1);
		rmSetAreaSize(centerID, 0.05, 0.08);
	} else if(centerPosition < 0.9) {   
		rmSetAreaLocation(centerID, 0, 0.5);
		rmSetAreaSize(centerID, 0.05, 0.08);
	} else {   
		rmSetAreaLocation(centerID, 0.5, 0);
		rmSetAreaSize(centerID, 0.05, 0.08);      
	}

	/* base is water */
	if(baseTerrainChance < 0.15) {
		if(centerChance < 0.75){
			/* land */
			centerType = 1;
		}
	} else {   
		if(centerChance < 0.33) {
			/* cliff */
			centerType = 4; 
		} else if(centerChance < 0.66) {
			/* forest */
			centerType = 5; 
		} else if(centerChance < 0.90) {
			if(terrainChance == 2) {
				/* ice */
				centerType = 2;
			}
		}
	}

	/* Define what terrains to use for center */
	if(centerType == 1) {
		//land
		if(terrainChance == 0) {
		rmSetAreaTerrainType(centerID, "GrassA");
		rmSetAreaBaseHeight(centerID, 2.0);
		} else if(terrainChance == 1) {
			if(savannah == 1) {
				rmSetAreaTerrainType(centerID, "SavannahC");
				rmSetAreaBaseHeight(centerID, 2.0);
			} else {
				rmSetAreaTerrainType(centerID, "SandA");
				rmSetAreaBaseHeight(centerID, 2.0);
			}
		} else if(terrainChance == 2) {
			rmSetAreaTerrainType(centerID, "SnowA");
			rmSetAreaBaseHeight(centerID, 2.0);
		}
		rmSetAreaHeightBlend(centerID, 2);
		rmSetAreaMinBlobs(centerID, 2);
		rmSetAreaMaxBlobs(centerID, 4);
		rmSetAreaMinBlobDistance(centerID, 10);
		rmSetAreaMaxBlobDistance(centerID, 20);
		rmSetAreaSmoothDistance(centerID, 30);
		rmSetAreaCoherence(centerID, 0.15);
		rmBuildArea(centerID);
		rmEchoInfo("center is land");
	} else if(centerType == 3) {
		//Water
		if(terrainChance == 0) {
			rmSetAreaWaterType(centerID, "mediterranean sea");
			rmSetAreaBaseHeight(centerID, 0.0);
			if(centerPosition < 0.6) {
				rmSetAreaSize(centerID, 0.15, 0.2);
			}
		} else if(terrainChance == 1) {
			rmSetAreaWaterType(centerID, "red sea");
			rmSetAreaBaseHeight(centerID, 0.0);
			if(centerPosition < 0.6) {
				rmSetAreaSize(centerID, 0.15, 0.2);
			}      
		} else if(terrainChance == 2) {
			rmSetAreaWaterType(centerID, "norwegian sea");
			rmSetAreaBaseHeight(centerID, 0.0);
			if(centerPosition < 0.6) {
				rmSetAreaSize(centerID, 0.15, 0.2);
			}
		}
		rmAddAreaToClass(centerID, rmClassID("center"));
		centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 0.0);
		rmSetAreaMinBlobs(centerID, 8);
		rmSetAreaMaxBlobs(centerID, 10);
		rmSetAreaMinBlobDistance(centerID, 10);
		rmSetAreaMaxBlobDistance(centerID, 20);
		rmSetAreaSmoothDistance(centerID, 50);
		rmSetAreaCoherence(centerID, 0.25);
		rmBuildArea(centerID);
		rmEchoInfo("center is water");
	} else if(centerType == 4) {
		//Cliff
		if(terrainChance == 0) {
			rmSetAreaCliffType(centerID, "Greek");
			rmSetAreaCliffPainting(centerID, false, true, true, 1.5, true);
		} else if(terrainChance == 1) {
			rmSetAreaCliffType(centerID, "Egyptian");
			rmSetAreaCliffPainting(centerID, false, true, true, 1.5, true);
		} else if(terrainChance == 2) {
			rmSetAreaCliffType(centerID, "Norse");
			rmSetAreaCliffPainting(centerID, true, true, true, 1.5, true);
		}
		rmSetAreaCliffEdge(centerID, 4, 0.20, 0.2, 1.0, 1);
		rmSetAreaCliffHeight(centerID, 7, 1.0, 0.5);
		rmSetAreaMinBlobs(centerID, 8);
		rmSetAreaMaxBlobs(centerID, 10);
		rmSetAreaMinBlobDistance(centerID, 10);
		rmSetAreaMaxBlobDistance(centerID, 20);
		rmSetAreaSmoothDistance(centerID, 50);
		rmSetAreaCoherence(centerID, 0.25);
		rmBuildArea(centerID);
		rmEchoInfo("center is cliff");
	} else if(centerType == 2) {
		/* ice only if Norse and only in center */
		rmSetAreaTerrainType(centerID,"IceA");
		rmSetAreaLocation(centerID, 0.5, 0.5);
		rmSetAreaSize(centerID, 0.08, 0.15);
		rmAddAreaToClass(centerID, rmClassID("center"));
		rmSetAreaBaseHeight(centerID, 1.0);
		rmSetAreaMinBlobs(centerID, 8);
		rmSetAreaMaxBlobs(centerID, 10);
		rmSetAreaMinBlobDistance(centerID, 10);
		rmSetAreaMaxBlobDistance(centerID, 20);
		rmSetAreaSmoothDistance(centerID, 50);
		rmSetAreaCoherence(centerID, 0.25);
		rmBuildArea(centerID);
		rmEchoInfo("center is ice");
	} else if(centerType == 5) {
		/* forest */
		rmSetAreaSize(centerID, 0.05, 0.08);
		if(terrainChance == 0) {
			if(rmRandFloat(0,1)<0.2) {
				rmSetAreaForestType(centerID, "savannah forest");
			} else {
				rmSetAreaForestType(centerID, "oak forest");
			} 
		} else if(terrainChance == 2) {
			rmSetAreaForestType(centerID, "mixed pine forest");
		} else {
			if(rmRandFloat(0,1)<0.2) {
				rmSetAreaForestType(centerID, "savannah forest");
			} else {
				rmSetAreaForestType(centerID, "mixed palm forest");
			}
		}      
		rmAddAreaToClass(centerID, rmClassID("center"));
		rmSetAreaLocation(centerID, 0.5, 0.5);
		rmAddAreaConstraint(centerID, forestSettleConstraint);
		rmAddAreaConstraint(centerID, forestObjConstraint);
		rmAddAreaConstraint(centerID, forestConstraint);
		rmAddAreaConstraint(centerID, avoidImpassableLand);
		rmAddAreaToClass(centerID, classForest);
		rmSetAreaMinBlobs(centerID, 1);
		rmSetAreaMaxBlobs(centerID, 1);
		rmSetAreaCoherence(centerID, 0.5);

		rmBuildArea(centerID);
	} else if(centerType == 0) {
		rmEchoInfo("no center");
	}
	
	rmSetStatusText("",0.26);
	
	/* ********************** */
	/* Section 5 Player Areas */
	/* ********************** */
	
	float playerFraction=0;
	float teamPercentArea = 0;


	// Set up player areas alone
	if(baseTerrainChance < 0.15) {  /* ocean */
		playerFraction=rmAreaTilesToFraction(7000);
		rmEchoInfo("player fraction is 7000");
	} else  {
		if(terrainChance == 2) { /* ice */
			playerFraction=rmAreaTilesToFraction(6000);
			rmEchoInfo("player fraction is 6000");
		} else { 
			playerFraction=rmAreaTilesToFraction(3000);
			rmEchoInfo("player fraction is 3000");
		}
	}
	rmEchoInfo("player fraction "+playerFraction);

	// create player lands per player
	int id=0;
	for(i=1; <cNumberPlayers) {
		id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);
		if(centerType > 1){
			rmSetAreaSize(id, 0.4*playerFraction, 0.6*playerFraction);
		} else {
			rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
		}
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
		/* edge */
		if(edgeConstraintChance < 0.5) {
			rmAddAreaConstraint(id, edgeConstraint);
		}
		rmAddAreaConstraint(id, playerVsPlayerConstraint);
		rmAddAreaConstraint(id, centerConstraint);
		rmSetAreaLocPlayer(id, i);
		if(terrainChance == 0) {
			rmSetAreaTerrainType(id, "GrassDirt25");
		} else if(terrainChance == 2) {
			rmSetAreaTerrainType(id, "SnowGrass75");
			rmAddAreaTerrainLayer(id, "SnowGrass75", 8, 20);
			rmAddAreaTerrainLayer(id, "SnowGrass50", 4, 8);
			rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 4);
		} else if(terrainChance == 1) {
			if(savannah == 1) {
				rmSetAreaTerrainType(id, "SavannahA");
			} else {
				rmSetAreaTerrainType(id, "GrassDirt25");
				rmAddAreaTerrainLayer(id, "GrassDirt50", 2, 5);
				rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 2);
			}
		}
	}
	rmBuildAllAreas();

	int patchConstraint=rmCreateClassDistanceConstraint("avoid patch", classPatch, 10.0);
	int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
	
	/* PLAYER'S PATCH */
	int failCount=0;
	for(i=1; <cNumberPlayers) {
		int playerPatch=rmCreateArea("player "+i+" patch", rmAreaID("player"+i));    
		rmSetAreaSize(playerPatch, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
		if(terrainChance == 0) {
			rmSetAreaTerrainType(playerPatch, "GrassDirt50");
		} else if(terrainChance == 1) {
			if(savannah==1) {            
				rmSetAreaTerrainType(playerPatch, "SavannahB");
			} else {            
				rmSetAreaTerrainType(playerPatch, "GrassDirt50");
				rmAddAreaTerrainLayer(playerPatch, "GrassDirt75", 0, 3);
			}
		} else {
			rmSetAreaTerrainType(playerPatch, "SnowGrass50");
			rmAddAreaTerrainLayer(playerPatch, "SnowGrass25", 0, 2);
		}
		rmAddAreaToClass(playerPatch, classPatch);
		rmAddAreaConstraint(playerPatch, patchConstraint);
		rmAddAreaConstraint(playerPatch, shortAvoidImpassableLand);
		rmSetAreaMinBlobs(playerPatch, 1);
		rmSetAreaMaxBlobs(playerPatch, 5);
		rmSetAreaWarnFailure(playerPatch, false);
		rmSetAreaMinBlobDistance(playerPatch, 16.0);
		rmSetAreaMaxBlobDistance(playerPatch, 40.0);
		rmSetAreaCoherence(playerPatch, 0.0);
		if(rmBuildArea(playerPatch)==false) {
			failCount++;
			if(failCount==4) {
				break;
			} 
		} else {
			failCount=0;
		}
	}
	
	// Loading bar 33% 
	rmSetStatusText("",0.33);
	
	/* *********************** */
	/* Section 6 Map Specifics */
	/* *********************** */
	
	int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30);
	
	failCount=0;
	for(i=1; <cNumberPlayers*8) {
		// Beautification sub area.
		int largePatch=rmCreateArea("large patch "+i);
		rmSetAreaSize(largePatch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
		if(terrainChance == 1) {
			if(savannah==1) {
				rmSetAreaTerrainType(largePatch, "SavannahB");
			} else {
				rmSetAreaTerrainType(largePatch, "SandD");
			}
		} else if(terrainChance == 0) {
			rmSetAreaTerrainType(largePatch, "GrassDirt25");
		} else if(terrainChance == 2) {
			rmSetAreaTerrainType(largePatch, "SnowGrass25");
		}
		rmAddAreaToClass(largePatch, classPatch);
		rmAddAreaConstraint(largePatch, patchConstraint);
		rmAddAreaConstraint(largePatch, playerConstraint);
		/* ice */
		if(centerType == 2) {
			rmAddAreaConstraint(largePatch, patchCenterConstraint);
		} if(centerType == 5) { /* smallAForest */
			rmAddAreaConstraint(largePatch, patchCenterConstraint);
		}
		rmAddAreaConstraint(largePatch, shortAvoidImpassableLand);
		rmSetAreaMinBlobs(largePatch, 1);
		rmSetAreaMaxBlobs(largePatch, 5);
		rmSetAreaWarnFailure(largePatch, false);
		rmSetAreaMinBlobDistance(largePatch, 16.0);
		rmSetAreaMaxBlobDistance(largePatch, 40.0);
		rmSetAreaCoherence(largePatch, 0.0);

		if(rmBuildArea(largePatch)==false) {
			failCount++;
			if(failCount==4) {
				break;
			}
		} else {
			failCount=0;
		}
	}

	// Text
	rmSetStatusText("",0.60);

	/* NON PLAYER SMALL PATCH */
	failCount=0;
	for(i=1; <cNumberPlayers*8) {
		// Beautification sub area.
		int smallPatch=rmCreateArea("small patch "+i);
		rmSetAreaSize(smallPatch, rmAreaTilesToFraction(20), rmAreaTilesToFraction(70));
		if(terrainChance == 0) {
			rmSetAreaTerrainType(smallPatch, "GrassB");
		} else if(terrainChance == 1) {
			rmSetAreaTerrainType(smallPatch, "SandB");  
		} else if(terrainChance == 2) {
			rmSetAreaTerrainType(smallPatch, "SnowB");
		}
		rmAddAreaConstraint(smallPatch, playerConstraint);
		/* ice */
		if(centerType == 2) {
			rmAddAreaConstraint(smallPatch, patchCenterConstraint);
		/* smallAForest */
		} if(centerType == 5) {
			rmAddAreaConstraint(smallPatch, patchCenterConstraint);
		}
		rmSetAreaMinBlobs(smallPatch, 1);
		rmSetAreaMaxBlobs(smallPatch, 5);
		rmSetAreaWarnFailure(smallPatch, false);
		rmSetAreaMinBlobDistance(smallPatch, 16.0);
		rmSetAreaMaxBlobDistance(smallPatch, 40.0);
		rmSetAreaCoherence(smallPatch, 0.0);

		if(rmBuildArea(smallPatch)==false) {
			failCount++;
			if(failCount==4) {
				break;
			}
		} else {
			failCount=0;
		}

	}

	// prettier ice in center if center is ice
	failCount=0;
	for(i=1; <cNumberPlayers*3) {
		int icePatch=rmCreateArea("more ice terrain"+i, centerID);
		rmSetAreaSize(icePatch, 0.01, 0.02);
		rmSetAreaTerrainType(icePatch, "IceB");
		rmAddAreaTerrainLayer(icePatch, "IceA", 0, 3);
		rmSetAreaCoherence(icePatch, 0.0);
		if(centerType == 2) {
			if(rmBuildArea(icePatch)==false) {
				failCount++;
				if(failCount==4) {
					break;
				}
			} else {
				failCount=0;
			}
		}
	}
	
	int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 15.0);
	
	int numTries=6*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries) {
		int elevID=rmCreateArea("elev"+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
		rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, avoidBuildings);
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		/* center is ice, cliff, forest */
		if(centerType > 1) {
			rmAddAreaConstraint(elevID, centerConstraint);
		}
		rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 5);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);

		if(rmBuildArea(elevID)==false) {
			failCount++;
			if(failCount==8) {
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
		rmAddAreaConstraint(elevID, avoidImpassableLand);
		/* center is ice, cliff, forest */
		if(centerType > 1) {
			rmAddAreaConstraint(elevID, centerConstraint);
		}			
		if(rmBuildArea(elevID)==false) {
			failCount++;
			if(failCount==8) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	float bigChance=rmRandFloat(0,1); 
	int diverseForest = rmRandInt(0,1);
	int diverseForestType = rmRandInt(0,1);
	float forestSpecies = rmRandFloat(0,1);
	if(bigForestExist == 1) {
		if(bigChance>0.6) {
			int bigAForestID=rmCreateArea("big a forest");
			rmSetAreaSize(bigAForestID, rmAreaTilesToFraction(800), rmAreaTilesToFraction(1200));
			rmSetAreaWarnFailure(bigAForestID, false);
			/* greek */
			if(terrainChance == 0) {
				if(diverseForest == 0) {
					if(forestSpecies<0.7) {
						rmSetAreaForestType(bigAForestID, "oak forest");
					} else if(forestSpecies<0.90) {
						rmSetAreaForestType(bigAForestID, "autumn oak forest");
					} else {
						rmSetAreaForestType(bigAForestID, "savannah forest");
					}
				} else if(diverseForest == 1) {
					if(diverseForestType == 0) {
						if(rmRandFloat(0,1)<0.8) {
							rmSetAreaForestType(bigAForestID, "oak forest");
						} else {
							rmSetAreaForestType(bigAForestID, "savannah forest");
						}
					} else {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(bigAForestID, "oak forest");
						} else {
							rmSetAreaForestType(bigAForestID, "autumn oak forest");
						}
					}
				}
			/* norse */
			} else if(terrainChance == 2) {
				if(diverseForest == 0) {
					if(forestSpecies<0.7) {
						rmSetAreaForestType(bigAForestID, "pine forest");
					} else if(forestSpecies<0.85) {
						rmSetAreaForestType(bigAForestID, "minxed oak forest");
					} else {
						rmSetAreaForestType(bigAForestID, "mixed pine forest");
					}
				} else if(diverseForest == 1) {
					if(diverseForestType == 0) {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(bigAForestID, "pine forest");
						} else {
							rmSetAreaForestType(bigAForestID, "mixed pine forest");
						}
					} else {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(bigAForestID, "snow pine forest");
						} else {
							rmSetAreaForestType(bigAForestID, "mixed pine forest");
						}
					}
				}
			/* egyptian */
			} else if(terrainChance == 1) {
				if(diverseForest == 0) {
					if(forestSpecies<0.7) {
						rmSetAreaForestType(bigAForestID, "palm forest");
					} else if(forestSpecies<0.75) {
						rmSetAreaForestType(bigAForestID, "savannah forest");
					} else {
						rmSetAreaForestType(bigAForestID, "mixed palm forest");
					}
				} else if(diverseForest == 1) {
					if(diverseForestType == 0) {
						if(rmRandFloat(0,1)<0.8) {
							rmSetAreaForestType(bigAForestID, "palm forest");
						} else {
							rmSetAreaForestType(bigAForestID, "savannah forest");
						}
					} else {
						if(rmRandFloat(0,1)<0.7) {
						rmSetAreaForestType(bigAForestID, "palm forest");
						} else {
							rmSetAreaForestType(bigAForestID, "mixed palm forest");
						}
					}
				}
			}
			rmAddAreaConstraint(bigAForestID, forestSettleConstraint);
			rmAddAreaConstraint(bigAForestID, forestObjConstraint);
			if(rmRandFloat(0,1)<0.80){
				rmAddAreaConstraint(bigAForestID, forestConstraint);
			} else {
				rmAddAreaConstraint(bigAForestID, rmCreateClassDistanceConstraint("big forest v forest", rmClassID("forest"), 40.0));
			}
			/* center is ice */
			if(centerType == 2) {
				rmAddAreaConstraint(bigAForestID, centerConstraint);
			}
			rmAddAreaConstraint(bigAForestID, avoidImpassableLand);
			rmAddAreaToClass(bigAForestID, classForest);

			rmSetAreaMinBlobs(bigAForestID, 1);
			rmSetAreaMaxBlobs(bigAForestID, 5);
			rmSetAreaMinBlobDistance(bigAForestID, 16.0);
			rmSetAreaMaxBlobDistance(bigAForestID, 40.0);
			rmSetAreaCoherence(bigAForestID, 0.0);

			rmBuildArea(bigAForestID);
		} else if(bigChance>0.8) {
			int cliffID=rmCreateArea("cliff"+i);
			rmSetAreaWarnFailure(cliffID, false);
			rmSetAreaSize(cliffID, rmAreaTilesToFraction(800), rmAreaTilesToFraction(1200));
			if(terrainChance == 0) {
				rmSetAreaCliffType(cliffID, "Greek");
			} else if(terrainChance == 2) {
				rmSetAreaCliffType(cliffID, "Norse");
			} else {
				rmSetAreaCliffType(cliffID, "Egyptian");
			}
			rmAddAreaConstraint(cliffID, rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0));
			rmAddAreaConstraint(cliffID, playerConstraint);
			rmAddAreaConstraint(cliffID, avoidBuildings);
			rmAddAreaToClass(cliffID, classCliff);
			rmSetAreaMinBlobs(cliffID, 2);
			rmSetAreaMaxBlobs(cliffID, 4);
			/* center is ice */
			if(centerType == 2 || centerType == 5) {
				rmAddAreaConstraint(cliffID, centerConstraint);
			}
			rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
			if(rmRandFloat(0,1) < 0.5) {
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
	}
	
	rmSetStatusText("",0.40);
	
	/* **************************** */
	/* Section 7 Object Constraints */
	/* **************************** */
	// If a constraint is used in multiple sections then it is listed here.
	
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
	int objForestConstraint=rmCreateClassDistanceConstraint("object avoid forest", rmClassID("forest"), 4.0);
	int shortAvoidStartingGoldMilky=rmCreateTypeDistanceConstraint("short avoid starting gold", "gold", 10.0);
	
	rmSetStatusText("",0.46);
	
	
	/* ********************************* */
	/* Section 8 Fair Location Placement */
	/* ********************************* */
	
	int startingGoldFairLocID = -1;
	int startingGoldNum = rmRandInt(1,3);
	for(i = 0; < startingGoldNum){
		if(rmRandFloat(0,1) > 0.5){
			startingGoldFairLocID = rmAddFairLoc("Starting Gold", true, false, 20, 21+i, 0, 15);
		} else {
			startingGoldFairLocID = rmAddFairLoc("Starting Gold", false, false, 20, 21+i, 0, 15);
		}
		rmAddFairLocConstraint(startingGoldFairLocID, shortAvoidStartingGoldMilky);
		if(rmPlaceFairLocs()){
			int startingGoldID=rmCreateObjectDef("Starting Gold"+i);
			rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
			for(p=1; <cNumberPlayers){
				for(j=0; <rmGetNumberFairLocs(i)){
					rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(p, j), rmFairLocZFraction(p, j), 1);
				}
			}
		}
		rmResetFairLocs();
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
	
	//Relax some of these constraints a bit because this map is a very unpredictable.
	int TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by long distance", "AbstractSettlement", 40.0);
	int TCavoidStart = rmCreateClassDistanceConstraint("TC avoid starting by long distance", classStartingSettlement, 50.0);
	int TCavoidWater = rmCreateTerrainDistanceConstraint("TC avoid water", "Water", true, 25.0);
	int TCavoidImpassableLand = rmCreateTerrainDistanceConstraint("TC avoid badlands", "land", false, 18.0);
	
	if(cNumberNonGaiaPlayers == 2){
		for(p = 1; <= cNumberNonGaiaPlayers){
			
			id=rmAddFairLoc("Settlement", false, true, 60, 65, 0, 24);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidStart);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settleArea = rmCreateArea("settlement area"+p, rmAreaID("Player"+p));
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settleArea, 0.01, 0.01);
				if(terrainChance == 0) {
					rmSetAreaTerrainType(settleArea, "GrassB");
				} else if(terrainChance == 1) {
					if(savannah==1) {
						rmSetAreaTerrainType(settleArea, "SandB");
					} else {
						rmSetAreaTerrainType(settleArea, "SandB");
					}
				} else if(terrainChance == 2) {
					rmSetAreaTerrainType(settleArea, "SnowB");
				}
				rmBuildArea(settleArea);
			} else {
				closeID=rmCreateObjectDef("close settlement"+p);
				rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(closeID, TCavoidSettlement);
				rmAddObjectDefConstraint(closeID, TCavoidStart);
				for(attempt = 1; < 25){
					rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(closeID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(closeID, 10*attempt);
				}
			}
			rmResetFairLocs();
		
			id=rmAddFairLoc("Settlement", true, false,  70, 80, 0, 40);
			rmAddFairLocConstraint(id, TCavoidSettlement);
			rmAddFairLocConstraint(id, TCavoidStart);
			rmAddFairLocConstraint(id, TCavoidImpassableLand);
			
			if(rmPlaceFairLocs()) {
				id=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(id, "Settlement", 1, 0.0);
				rmPlaceObjectDefAtLoc(id, p, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0), 1);
				int settlementArea = rmCreateArea("settlement_area_"+p);
				rmSetAreaLocation(settlementArea, rmFairLocXFraction(p, 0), rmFairLocZFraction(p, 0));
				rmSetAreaSize(settlementArea, 0.01, 0.01);
				if(terrainChance == 0) {
					rmSetAreaTerrainType(settlementArea, "GrassB");
				} else if(terrainChance == 1) {
					if(savannah==1) {
						rmSetAreaTerrainType(settlementArea, "SandB");
					} else {
						rmSetAreaTerrainType(settlementArea, "SandB");
					}
				} else if(terrainChance == 2) {
					rmSetAreaTerrainType(settlementArea, "SnowB");
				}
				rmBuildArea(settlementArea);
			} else {
				farID=rmCreateObjectDef("far settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				for(attempt = 1; < 25){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 10*attempt);
				}
			}
			rmResetFairLocs();
		}
	} else {
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by super long distance", "AbstractSettlement", 65.0);
		for(p = 1; <= cNumberNonGaiaPlayers){
		
			closeID=rmCreateObjectDef("close settlement"+p);
			rmAddObjectDefItem(closeID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(closeID, TCavoidSettlement);
			rmAddObjectDefConstraint(closeID, TCavoidStart);
			rmAddObjectDefConstraint(closeID, TCavoidWater);
			for(attempt = 4; < 25){
				rmPlaceObjectDefAtLoc(closeID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(closeID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(closeID, 10*attempt);
			}
		
			farID=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
			rmAddObjectDefConstraint(farID, TCavoidWater);
			rmAddObjectDefConstraint(farID, TCavoidStart);
			rmAddObjectDefConstraint(farID, TCavoidSettlement);
			for(attempt = 7; < 25){
				rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
				if(rmGetNumberUnitsPlaced(farID) > 0){
					break;
				}
				rmSetObjectDefMaxDistance(farID, 10*attempt);
			}
		}
	}
		
	if(cMapSize == 2){
		//And one last time if Giant.
		TCavoidSettlement = rmCreateTypeDistanceConstraint("TC avoid TC by giant long distance", "AbstractSettlement", 75.0);
	
		id=rmAddFairLoc("Settlement", true, false,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.4), 75, 18);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
		rmAddFairLocConstraint(id, TCavoidSettlement);
		rmAddFairLocConstraint(id, TCavoidStart);
		rmAddFairLocConstraint(id, TCavoidWater);
		
		id=rmAddFairLoc("Settlement", false, false,  rmXFractionToMeters(0.3), rmXFractionToMeters(0.45), 75, 18);
		rmAddFairLocConstraint(id, TCavoidImpassableLand);
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
					rmSetAreaSize(settlementArea2, 0.01, 0.01);
					if(terrainChance == 0) {
						rmSetAreaTerrainType(settlementArea2, "GrassB");
					} else if(terrainChance == 1) {
						if(savannah==1) {
							rmSetAreaTerrainType(settlementArea2, "SandB");
						} else {
							rmSetAreaTerrainType(settlementArea2, "SandB");
						}
					} else if(terrainChance == 2) {
						rmSetAreaTerrainType(settlementArea2, "SnowB");
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
				for(attempt = 7; < 25){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 10*attempt);
				}
				
				farID=rmCreateObjectDef("giant2 settlement"+p);
				rmAddObjectDefItem(farID, "Settlement", 1, 0.0);
				rmAddObjectDefConstraint(farID, TCavoidImpassableLand);
				rmAddObjectDefConstraint(farID, TCavoidStart);
				rmAddObjectDefConstraint(farID, TCavoidSettlement);
				for(attempt = 7; < 25){
					rmPlaceObjectDefAtLoc(farID, p, rmGetPlayerX(p), rmGetPlayerZ(p), 1);
					if(rmGetNumberUnitsPlaced(farID) > 0){
						break;
					}
					rmSetObjectDefMaxDistance(farID, 10*attempt);
				}
			}
		}
	}
	
	rmSetStatusText("",0.53);
	
	/* ************************** */
	/* Section 9 Starting Objects */
	/* ************************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	
	
	float huntSpeciesChance=rmRandFloat(0,1);
	int closeBoarID=rmCreateObjectDef("close Boar");
	if(terrainChance == 0) {   
		if(huntSpeciesChance<0.5) {
			rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(3,4), 5.0);
		} else {
			rmAddObjectDefItem(closeBoarID, "deer", rmRandInt(5,6), 5.0);
		}
	} else if(terrainChance == 1) {
		if(huntSpeciesChance<0.2) {
			rmAddObjectDefItem(closeBoarID, "hippo", rmRandInt(2,3), 4.0);
		} else if(huntSpeciesChance<0.4) {
			rmAddObjectDefItem(closeBoarID, "zebra", rmRandInt(6,12), 5.0);
		} else if(huntSpeciesChance<0.6) {
			rmAddObjectDefItem(closeBoarID, "giraffe", rmRandInt(5,8), 4.0);
		} else {
			rmAddObjectDefItem(closeBoarID, "rhinocerous", rmRandInt(2,3), 4.0);
		}
	} else {   
		if(huntSpeciesChance<0.33) {
			rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(4,6), 5.0);
		} else if(huntSpeciesChance<0.66) {
			rmAddObjectDefItem(closeBoarID, "caribou", rmRandInt(6,8), 5.0);
		} else {
			rmAddObjectDefItem(closeBoarID, "aurochs", rmRandInt(2,6), 5.0);
		}
	}
	rmSetObjectDefMinDistance(closeBoarID, 24.0);
	rmSetObjectDefMaxDistance(closeBoarID, 30.0);
	rmAddObjectDefConstraint(closeBoarID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);
	rmPlaceObjectDefPerPlayer(closeBoarID, false);
	
	int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 12.0);

	int closePigsID=rmCreateObjectDef("close pigs");
	if(rmRandFloat(0,1)<0.75){
		if(terrainChance == 0) {
			rmAddObjectDefItem(closePigsID, "pig", rmRandInt(1,3), 2.0);
		} else if(terrainChance == 1) {
			rmAddObjectDefItem(closePigsID, "goat", rmRandInt(1,3), 2.0);
		} else if(terrainChance == 2) {
			rmAddObjectDefItem(closePigsID, "cow", rmRandInt(1,3), 2.0);
		}
	} else {
		if(terrainChance == 0) {
			rmAddObjectDefItem(closePigsID, "pig", rmRandInt(4,5), 2.0);
		} else if(terrainChance == 1) {
			rmAddObjectDefItem(closePigsID, "goat", rmRandInt(4,5), 2.0);
		} else if(terrainChance == 2) {
			rmAddObjectDefItem(closePigsID, "cow", rmRandInt(4,5), 2.0);
		}
	}
	rmSetObjectDefMinDistance(closePigsID, 25.0);
	rmSetObjectDefMaxDistance(closePigsID, 30.0);
	rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(closePigsID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(closePigsID, avoidFood);
	rmPlaceObjectDefPerPlayer(closePigsID, true);

	int berryNum = rmRandInt(1,3);
	int closeChickensID=rmCreateObjectDef("close Chickens");
	rmAddObjectDefItem(closeChickensID, "chicken", berryNum*4, 5.0);
	rmSetObjectDefMinDistance(closeChickensID, 20.0);
	rmSetObjectDefMaxDistance(closeChickensID, 25.0);
	rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeChickensID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(closeChickensID, avoidFood);
	float placeBirdy = rmRandFloat(0.0, 1.0);
	if(placeBirdy < 0.66){
		for(i=1; <cNumberPlayers){
			rmPlaceObjectDefAtLoc(closeChickensID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
		}
	}

	int closeBerriesID=rmCreateObjectDef("close berries");
	rmAddObjectDefItem(closeBerriesID, "berry bush", berryNum*3, 4.0);
	rmSetObjectDefMinDistance(closeBerriesID, 21.0);
	rmSetObjectDefMaxDistance(closeBerriesID, 26.0);
	rmAddObjectDefConstraint(closeBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(closeBerriesID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(closeBerriesID, avoidFood);
	float placeBerry = rmRandFloat(0.0, 1.0);
	if(placeBerry < 0.66){
		for(i=1; <cNumberPlayers){
			rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmGetPlayerX(i), rmGetPlayerZ(i));
		}
	}

	int stragglerTreeID=rmCreateObjectDef("straggler tree");
	if(terrainChance == 0) {
		if(rmRandFloat(0,1)<0.7) {
			rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
		} else if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
		} else {
			rmAddObjectDefItem(stragglerTreeID, "oak autumn", 1, 0.0);
		}
	} else if(terrainChance == 1) {
		if(rmRandFloat(0,1)<0.2) {
			rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
		} else {
			rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
		}
	} else {
		rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
	}
	rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
	rmSetObjectDefMaxDistance(stragglerTreeID, 18.0);
	rmAddObjectDefConstraint(stragglerTreeID, rmCreateTypeDistanceConstraint("straggler trees", "all", 3.0));
	rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(5,10));
	
	int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);
	int playerFishID=rmCreateObjectDef("owned fish");
	if(terrainChance == 0) {
		rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 10.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(playerFishID, "fish - perch", 3, 10.0);
	} else if(terrainChance == 2) {
		rmAddObjectDefItem(playerFishID, "fish - salmon", 3, 10.0);
	}
	rmSetObjectDefMinDistance(playerFishID, 0.0);
	rmSetObjectDefMaxDistance(playerFishID, 100.0);
	rmAddObjectDefConstraint(playerFishID, fishVsFishID);
	rmAddObjectDefConstraint(playerFishID, fishLand);
	
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
			rmSetAreaSize(playerStartingForestID, rmAreaTilesToFraction(75+cNumberNonGaiaPlayers), rmAreaTilesToFraction(100+cNumberNonGaiaPlayers));
			rmSetAreaLocation(playerStartingForestID, rmGetCustomLocXForPlayer(i), rmGetCustomLocZForPlayer(i));
			rmSetAreaWarnFailure(playerStartingForestID, true);
			if(terrainChance == 0) {
				if(diverseForest == 0) {
					if(forestSpecies<0.7) {
						rmSetAreaForestType(playerStartingForestID, "oak forest");
					} else if(forestSpecies<0.90) {
						rmSetAreaForestType(playerStartingForestID, "autumn oak forest");
					} else {
						rmSetAreaForestType(playerStartingForestID, "savannah forest");
					}
				} else if(diverseForest == 1) {
					if(diverseForestType == 0) {
						if(rmRandFloat(0,1)<0.8) {
							rmSetAreaForestType(playerStartingForestID, "oak forest");
						} else {
								rmSetAreaForestType(playerStartingForestID, "savannah forest");
						}
					} else {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(playerStartingForestID, "oak forest");
						} else {
							rmSetAreaForestType(playerStartingForestID, "autumn oak forest");
						}
					}
				}
				
			/* norse */
			} else if(terrainChance == 2) {
				if(diverseForest == 0) {
					if(forestSpecies<0.7) {
						rmSetAreaForestType(playerStartingForestID, "pine forest");
					} else if(forestSpecies<0.85) {
						rmSetAreaForestType(playerStartingForestID, "mixed oak forest");
					} else {
						rmSetAreaForestType(playerStartingForestID, "mixed pine forest");
					}
				} else if(diverseForest == 1) {
					if(diverseForestType == 0) {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(playerStartingForestID, "pine forest");
						} else {
							rmSetAreaForestType(playerStartingForestID, "mixed pine forest");
						}
					} else {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(playerStartingForestID, "snow pine forest");
						} else {
							rmSetAreaForestType(playerStartingForestID, "mixed pine forest");
						}
					}
				}
				
			/* egyptian */
			} else if(terrainChance == 1) {
				if(diverseForest == 0) {
					if(forestSpecies<0.7) {
						rmSetAreaForestType(playerStartingForestID, "palm forest");
					} else if(forestSpecies<0.75) {
						rmSetAreaForestType(playerStartingForestID, "savannah forest");
					} else {
						rmSetAreaForestType(playerStartingForestID, "mixed palm forest");
					}
				} else if(diverseForest == 1) {
					if(diverseForestType == 0) {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(playerStartingForestID, "palm forest");
						} else {
							rmSetAreaForestType(playerStartingForestID, "savannah forest");
						}
					} else {
						if(rmRandFloat(0,1)<0.7) {
							rmSetAreaForestType(playerStartingForestID, "palm forest");
						} else {
							rmSetAreaForestType(playerStartingForestID, "mixed palm forest");
						}
					}
				}
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
	rmAddObjectDefConstraint(startingTowerID, shortAvoidStartingGoldMilky);
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
	rmSetObjectDefMinDistance(mediumGoldID, 45.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 55.0);
	rmAddObjectDefConstraint(mediumGoldID, avoidGold);
	rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
	rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);
	if(rmRandFloat(0,1)<0.9){
		rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	} else {
		rmPlaceObjectDefPerPlayer(mediumGoldID, false, 2);
	}

	int mediumPigsID=rmCreateObjectDef("medium pigs");
	if(terrainChance == 0){
		rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(1,3), 2.0);
	} else if(terrainChance == 1){
		rmAddObjectDefItem(mediumPigsID, "goat", rmRandInt(1,3), 2.0);
	} else if(terrainChance == 2){
		rmAddObjectDefItem(mediumPigsID, "cow", rmRandInt(1,3), 2.0);
	}
	rmSetObjectDefMinDistance(mediumPigsID, 50.0);
	rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
	rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(mediumPigsID, avoidGold);
	rmAddObjectDefConstraint(mediumPigsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(mediumPigsID, avoidHerdable);
	rmPlaceObjectDefPerPlayer(mediumPigsID, false, rmRandInt(1,2));
	
	rmSetStatusText("",0.73);
	
	/* ********************** */
	/* Section 12 Far Objects */
	/* ********************** */
	// Order of placement is Settlements then gold then food (hunt, herd, predator).
	
	int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
	
	int farGoldID=rmCreateObjectDef("far gold");
	rmSetObjectDefMinDistance(farGoldID, 75.0);
	if(rmRandFloat(0,1)<0.75) {
		rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(farGoldID, 110.0);
	} else {
		rmAddObjectDefItem(farGoldID, "Gold mine", 2, 6.0);
		rmSetObjectDefMaxDistance(farGoldID, 160.0);
	}
	rmAddObjectDefConstraint(farGoldID, avoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farGoldID, centerConstraint);
	rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);
	if(rmRandFloat(0,1)<0.75) {
		rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2,4));
	} else if(rmRandFloat(0,1)<0.5) {
		rmPlaceObjectDefPerPlayer(farGoldID, false, (cNumberNonGaiaPlayers % 4) + 2);
	} else {
		rmPlaceObjectDefPerPlayer(farGoldID, false);
	}

	int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);
	int bonusHuntableID=rmCreateObjectDef("bonus huntable");
	huntSpeciesChance=rmRandFloat(0,1);

	if(terrainChance == 0) {
		if(huntSpeciesChance<0.5) {
			rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(2,4), 4.0);
		} else {
			rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(6,8), 4.0);
		}
	} else if(terrainChance == 1) {   
		if(huntSpeciesChance<0.2) {
			rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(6,8), 4.0);
		} else if(huntSpeciesChance<0.4) {
			rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(4,8), 4.0);
		} else if(huntSpeciesChance<0.6) {
			rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,6), 4.0);
		} else if(huntSpeciesChance<0.8) {
			rmAddObjectDefItem(bonusHuntableID, "elephant", rmRandInt(1,2), 4.0);
		} else {
			rmAddObjectDefItem(bonusHuntableID, "rhinocerous", rmRandInt(1,3), 4.0);
		}
	} else {   
		if(huntSpeciesChance<0.5) {
			rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(2,4), 4.0);
		} else {
			rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(4,8), 4.0);
		}
	}
	rmSetObjectDefMinDistance(bonusHuntableID, 85.0);
	rmSetObjectDefMaxDistance(bonusHuntableID, 90.0+(2*cNumberNonGaiaPlayers-4));
	rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntableID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntableID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntableID, centerConstraint);
	rmAddObjectDefConstraint(bonusHuntableID, avoidGold);
	int huntMultiplier = 1;
	if(rmRandFloat(0,1)<0.15) {
		huntMultiplier = 2;
	}
	rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers * huntMultiplier);

	
	int bonusHuntable2ID=rmCreateObjectDef("bonus huntable 2");
	huntSpeciesChance=rmRandFloat(0,1);
	if(terrainChance == 0) {
		if(huntSpeciesChance<0.5) {
			rmAddObjectDefItem(bonusHuntable2ID, "boar", rmRandInt(2,4), 4.0);
		} else {
			rmAddObjectDefItem(bonusHuntable2ID, "deer", rmRandInt(6,8), 4.0);
		}
	} else if(terrainChance == 1) {   
		if(huntSpeciesChance<0.2) {
			rmAddObjectDefItem(bonusHuntable2ID, "gazelle", rmRandInt(6,8), 4.0);
		} else if(huntSpeciesChance<0.4) {
			rmAddObjectDefItem(bonusHuntable2ID, "zebra", rmRandInt(4,8), 4.0);
		} else if(huntSpeciesChance<0.6) {
			rmAddObjectDefItem(bonusHuntable2ID, "giraffe", rmRandInt(3,6), 4.0);
		} else if(huntSpeciesChance<0.8) {
			rmAddObjectDefItem(bonusHuntable2ID, "elephant", rmRandInt(1,2), 4.0);
		} else {
			rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", rmRandInt(1,3), 4.0);
		}
	} else {   
		if(huntSpeciesChance<0.5) {
			rmAddObjectDefItem(bonusHuntable2ID, "boar", rmRandInt(2,4), 4.0);
		} else {
			rmAddObjectDefItem(bonusHuntable2ID, "caribou", rmRandInt(4,8), 4.0);
		}
	}
	rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
	rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(bonusHuntable2ID, edgeConstraint);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidGold);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
	rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(bonusHuntable2ID, avoidImpassableLand);
	rmAddObjectDefConstraint(bonusHuntable2ID, shortAvoidSettlement);
	rmAddObjectDefConstraint(bonusHuntable2ID, centerConstraint);
	huntMultiplier = 1;
	if(rmRandFloat(0,1)<0.15) {
		huntMultiplier = 2;
	}
	for(i=1; <cNumberNonGaiaPlayers * huntMultiplier) {
		rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, 1);
	}
	
	
	int farPigsID=rmCreateObjectDef("far pigs");
	if(terrainChance == 0) {
		rmAddObjectDefItem(farPigsID, "pig", rmRandInt(1,3), 2.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(farPigsID, "goat", rmRandInt(1,3), 2.0);
	} else if(terrainChance == 2) {
		rmAddObjectDefItem(farPigsID, "cow", rmRandInt(1,3), 2.0);
	}
	rmSetObjectDefMinDistance(farPigsID, 80.0);
	rmSetObjectDefMaxDistance(farPigsID, 105.0);
	rmAddObjectDefConstraint(farPigsID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPigsID, avoidHerdable);
	rmAddObjectDefConstraint(farPigsID, shortAvoidSettlement);
	rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
	if(rmRandFloat(0,1)<0.90) {
		rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(1,2));
	} else {
		rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(7,9));
	}

	int farBerriesID=rmCreateObjectDef("far berries");
	rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(6,12), 4.0);
	rmSetObjectDefMinDistance(farBerriesID, 65.0);
	rmSetObjectDefMaxDistance(farBerriesID, 115.0);
	rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
	rmAddObjectDefConstraint(farBerriesID, avoidFood);
	rmAddObjectDefConstraint(farBerriesID, avoidGold);
	rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farBerriesID, centerConstraint);
	rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
	if(rmRandFloat(0,1)<0.25){
		rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	
	int farPredatorID=rmCreateObjectDef("far predator");
	if(terrainChance == 1) {
		if(rmRandFloat(0,1)< 0.50) {
			rmAddObjectDefItem(farPredatorID, "lion", rmRandInt(1,2), 4.0);
		} else {
			rmAddObjectDefItem(farPredatorID, "hyena", rmRandInt(2,3), 4.0);
		}
	} else if(terrainChance == 0) {
		if(rmRandFloat(0,1)< 0.33) {
			rmAddObjectDefItem(farPredatorID, "lion", rmRandInt(1,2), 4.0);
		} else if(rmRandFloat(0,1)<0.50) {
			rmAddObjectDefItem(farPredatorID, "wolf", rmRandInt(2,3), 4.0);
		} else {
			rmAddObjectDefItem(farPredatorID, "bear", rmRandInt(1,2), 4.0);
		}
	} else {
		if(rmRandFloat(0,1)< 0.33) {
			rmAddObjectDefItem(farPredatorID, "bear", rmRandInt(1,2), 4.0);
		} else if(rmRandFloat(0,1)<0.50) {
			rmAddObjectDefItem(farPredatorID, "polar bear", rmRandInt(1,2), 4.0);
		} else {
			rmAddObjectDefItem(farPredatorID, "wolf", rmRandInt(2,3), 4.0);
		}
	}
	rmSetObjectDefMinDistance(farPredatorID, 65.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0));
	rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
	rmAddObjectDefConstraint(farPredatorID, avoidGold);
	rmAddObjectDefConstraint(farPredatorID, avoidFood);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidSettlement);
	rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 60.0);
	rmSetObjectDefMaxDistance(relicID, 150.0);
	rmAddObjectDefConstraint(relicID, edgeConstraint);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
	rmAddObjectDefConstraint(relicID, avoidImpassableLand);
	rmAddObjectDefConstraint(relicID, centerConstraint);
	rmAddObjectDefConstraint(relicID, avoidGold);
	rmAddObjectDefConstraint(relicID, shortAvoidSettlement);
	float relicNum = rmRandFloat(0,1);
	if(relicNum < 0.8) {
		rmPlaceObjectDefPerPlayer(relicID, false);
	} else if(relicNum < 0.95) {
		rmPlaceObjectDefPerPlayer(relicID, false, 2);
	} else {
		rmPlaceObjectDefPerPlayer(relicID, false, 4);
	}
	
	
	int randomTreeID=rmCreateObjectDef("random tree");
	if(terrainChance == 0) {
		if(rmRandFloat(0,1)<0.7) {
			rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
		} else if(rmRandFloat(0,1)<0.5) {
			rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
		} else {
			rmAddObjectDefItem(randomTreeID, "oak autumn", 1, 0.0);
		}
	} else if(terrainChance == 1) {
		if(rmRandFloat(0,1)<0.2) {
			rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
		} else {
			rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
		}
	} else {
		if(rmRandFloat(0,1)<0.2) {
			rmAddObjectDefItem(randomTreeID, "pine snow", 1, 0.0);
		} else {
			rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
		}
	}
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
	rmAddObjectDefConstraint(randomTreeID, shortAvoidStartingGoldMilky);
	rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
	rmAddObjectDefConstraint(randomTreeID, centerConstraint);
	if(rmRandFloat(0,1)<0.9) {
		rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMulitplier);
	} else {
		rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMulitplier);
	}
	
	rmSetStatusText("",0.80);
	
	/* ************************ */
	/* Section 13 Giant Objects */
	/* ************************ */

	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("golds avoid settlements", "AbstractSettlement", 50.0));
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("giant avoid golds", "gold", 65.0));
		rmAddObjectDefConstraint(giantGoldID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(3, 6));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(terrainChance == 0) {
			rmAddObjectDefItem(giantHuntableID, "boar", rmRandInt(3,4), 5.0);
		} else if(terrainChance == 1) {
			if(huntSpeciesChance<0.33) {
				rmAddObjectDefItem(giantHuntableID, "gazelle", rmRandInt(7,8), 5.0);
			} else if(huntSpeciesChance<0.66) {
				rmAddObjectDefItem(giantHuntableID, "zebra", rmRandInt(6,8), 5.0);
			} else {
				rmAddObjectDefItem(giantHuntableID, "giraffe", rmRandInt(6,8), 5.0);
			}
		} else {
				rmAddObjectDefItem(giantHuntableID, "boar", rmRandInt(3,4), 5.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, avoidGold);
		rmAddObjectDefConstraint(giantHuntableID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		if(terrainChance == 0) {
			rmAddObjectDefItem(giantHuntable2ID, "deer", rmRandInt(4,6), 5.0);
		} else if(terrainChance == 1) {
			if(huntSpeciesChance<0.5) {
				rmAddObjectDefItem(giantHuntable2ID, "elephant", 2, 5.0);
			} else {
				rmAddObjectDefItem(giantHuntable2ID, "rhinocerous", rmRandInt(3,4), 6.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "caribou", rmRandInt(6,8), 5.0);
		}
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntable2ID, avoidGold);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHuntable2ID, farStartingSettleConstraint);
		rmAddObjectDefConstraint(giantHuntable2ID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable2ID, centerConstraint);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, avoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, avoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, avoidFood);
		rmAddObjectDefConstraint(giantHerdableID, avoidGold);
		rmAddObjectDefConstraint(giantHerdableID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, farStartingSettleConstraint);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, avoidGold);
		rmAddObjectDefConstraint(giantRelixID, shortAvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 120.0));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, rmRandInt(cNumberNonGaiaPlayers, 2*cNumberNonGaiaPlayers));
	}
	
	rmSetStatusText("",0.86);
	
	/* ************************************ */
	/* Section 14 Map Fill Cliffs & Forests */
	/* ************************************ */
	
	int forestCount=10*cNumberNonGaiaPlayers;
	if(rmRandFloat(0,1)<0.1) {   
		forestCount=2*cNumberNonGaiaPlayers*mapSizeMulitplier;
		rmEchoInfo("few forests");
	}
	float baseForestSize=(rmRandFloat(1,3));
	failCount=0;
	for(i=0; <forestCount*mapSizeMulitplier) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(baseForestSize*50+((mapSizeMulitplier-1)*100)), rmAreaTilesToFraction(baseForestSize*100+((mapSizeMulitplier-1)*100)));
		rmSetAreaWarnFailure(forestID, false);
		/* greek */
		if(terrainChance == 0) {
			if(diverseForest == 0) {
				if(forestSpecies<0.7) {
					rmSetAreaForestType(forestID, "oak forest");
				} else if(forestSpecies<0.90) {
					rmSetAreaForestType(forestID, "autumn oak forest");
				} else {
					rmSetAreaForestType(forestID, "savannah forest");
				}
			} else if(diverseForest == 1) {
				if(diverseForestType == 0) {
					if(rmRandFloat(0,1)<0.8) {
						rmSetAreaForestType(forestID, "oak forest");
					} else {
							rmSetAreaForestType(forestID, "savannah forest");
					}
				} else {
					if(rmRandFloat(0,1)<0.7) {
						rmSetAreaForestType(forestID, "oak forest");
					} else {
						rmSetAreaForestType(forestID, "autumn oak forest");
					}
				}
			}
			
		/* norse */
		} else if(terrainChance == 2) {
			if(diverseForest == 0) {
				if(forestSpecies<0.7) {
					rmSetAreaForestType(forestID, "pine forest");
				} else if(forestSpecies<0.85) {
					rmSetAreaForestType(forestID, "mixed oak forest");
				} else {
					rmSetAreaForestType(forestID, "mixed pine forest");
				}
			} else if(diverseForest == 1) {
				if(diverseForestType == 0) {
					if(rmRandFloat(0,1)<0.7) {
						rmSetAreaForestType(forestID, "pine forest");
					} else {
						rmSetAreaForestType(forestID, "mixed pine forest");
					}
				} else {
					if(rmRandFloat(0,1)<0.7) {
						rmSetAreaForestType(forestID, "snow pine forest");
					} else {
						rmSetAreaForestType(forestID, "mixed pine forest");
					}
				}
			}
			
		/* egyptian */
		} else if(terrainChance == 1) {
			if(diverseForest == 0) {
				if(forestSpecies<0.7) {
					rmSetAreaForestType(forestID, "palm forest");
				} else if(forestSpecies<0.75) {
					rmSetAreaForestType(forestID, "savannah forest");
				} else {
					rmSetAreaForestType(forestID, "mixed palm forest");
				}
			} else if(diverseForest == 1) {
				if(diverseForestType == 0) {
					if(rmRandFloat(0,1)<0.7) {
						rmSetAreaForestType(forestID, "palm forest");
					} else {
						rmSetAreaForestType(forestID, "savannah forest");
					}
				} else {
					if(rmRandFloat(0,1)<0.7) {
						rmSetAreaForestType(forestID, "palm forest");
					} else {
						rmSetAreaForestType(forestID, "mixed palm forest");
					}
				}
			}
		}
		rmAddAreaConstraint(forestID, forestSettleConstraint);
		rmAddAreaConstraint(forestID, forestObjConstraint);
		rmAddAreaConstraint(forestID, forestConstraint);
		/* center is ice */
		if(centerType == 2) {
			rmAddAreaConstraint(forestID, centerConstraint);
		}
		rmAddAreaConstraint(forestID, avoidImpassableLand);
		rmAddAreaToClass(forestID, classForest);

		rmSetAreaMinBlobs(forestID, 1);
		rmSetAreaMaxBlobs(forestID, 5);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 40.0);
		rmSetAreaCoherence(forestID, 0.0);

		if(rmBuildArea(forestID)==false) {
			failCount++;
			if(failCount==8*mapSizeMulitplier) {
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
	rmPlaceObjectDefPerPlayer(farhawkID, false, 2*mapSizeMulitplier); 
	
	int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
	int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
	int grassID=rmCreateObjectDef("grass");
	rmAddObjectDefItem(grassID, "grass", 3, 4.0);
	rmSetObjectDefMinDistance(grassID, 0.0);
	rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(grassID, avoidGrass);
	rmAddObjectDefConstraint(grassID, avoidAll);
	rmAddObjectDefConstraint(grassID, avoidImpassableLand);
	if(terrainChance == 0) {
		rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMulitplier);
	} else if(terrainChance == 1) {
		rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMulitplier);
	}
	
	int rockID=rmCreateObjectDef("rock");
	if(terrainChance == 0) {
		rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
	} else if(terrainChance == 1) {
		rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 1.0);
	} else {
		rmAddObjectDefItem(rockID, "rock granite sprite", 1, 1.0);
	}
	rmSetObjectDefMinDistance(rockID, 0.0);
	rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(rockID, avoidAll);
	rmAddObjectDefConstraint(rockID, avoidImpassableLand);
	if(terrainChance == 2) {
		rmAddObjectDefConstraint(rockID, centerConstraint);
	}
	rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMulitplier);
	
	if(fishExist == 1) {
		rmPlaceObjectDefPerPlayer(playerFishID, false);

		int fishID=rmCreateObjectDef("fish");
		if (terrainChance == 0) {
			rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
		} else if(terrainChance == 1) {
			rmAddObjectDefItem(fishID, "fish - perch", 3, 9.0);
		} else if(terrainChance == 2) {
			rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
		}
		rmSetObjectDefMinDistance(fishID, 0.0);
		rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(fishID, fishVsFishID);
		rmAddObjectDefConstraint(fishID, fishLand);

		for(i=1; <cNumberNonGaiaPlayers*5*mapSizeMulitplier) {
			if(rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1)==0) {
				break;
			}
		}
		
		rmPlaceObjectDefInLineX(fishID, 0, 3*cNumberNonGaiaPlayers, 0.98, 0.0, 1.0, 0.01);
		rmPlaceObjectDefInLineX(fishID, 0, 3*cNumberNonGaiaPlayers, 0.02, 0.0, 1.0, 0.01);
		rmPlaceObjectDefInLineZ(fishID, 0, 3*cNumberNonGaiaPlayers, 0.98, 0.0, 1.0, 0.01);
		rmPlaceObjectDefInLineZ(fishID, 0, 3*cNumberNonGaiaPlayers, 0.02, 0.0, 1.0, 0.01);

		int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
		int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
		int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
		int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);

		int sharkID=rmCreateObjectDef("shark");
		if(rmRandFloat(0,1)<0.33) {
			rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
		} else if(rmRandFloat(0,1)<0.5) {
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

		for(i=1; <cNumberNonGaiaPlayers*0.5*mapSizeMulitplier) {
			rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, 1);
		}
	}

	
	rmSetStatusText("",1.0);
}
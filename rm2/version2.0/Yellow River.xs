/*	Yellow River
**	Author: Milkman Matty
**	Version: 1.0
*/

include "MmM_FE_lib.xs";

// Main entry point for random map script
void main(void){

	/******************/
	/* Initialize Map */	rmSetStatusText("",0.01);
	/******************/
	int playerTiles=10500;
	int mapSizeMultiplier = 1;
	if(cMapSize == 1){
		playerTiles = 13750;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 20800;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/1.25);
	
	float lengthModifier = 1.0;
	float widthModifier = 1.0;
	if(cNumberNonGaiaPlayers < 3){ lengthModifier = 1.25; }
	else if(cNumberNonGaiaPlayers < 4){ lengthModifier = 1.15; }
	else if(cNumberNonGaiaPlayers < 6){ 
		lengthModifier = 0.85; 
		widthModifier = 1.1;
	} else if(cNumberNonGaiaPlayers < 8){ 
		lengthModifier = 0.70;
		widthModifier = 1.2;
	} else if(cNumberNonGaiaPlayers < 10){
		lengthModifier = 0.60;
		widthModifier = 1.3;
	} else {
		lengthModifier = 0.50; 
		widthModifier = 1.4;
	}
	rmEchoInfo("lengthModifier: "+lengthModifier);
	
	rmSetMapSize(size/widthModifier, size/lengthModifier);
	rmEchoInfo("Map size="+size+"m x "+(size/lengthModifier)+"m");
	
	rmSetSeaLevel(0.0);
	rmSetSeaType("Yellow River");
	rmTerrainInitialize("water");
	
	int csPlayer=rmDefineClass("Player");
	int csForest=rmDefineClass("Forest");
	
	//Setup some constants:
	
	float cXLinePlayers = 0.15;
	float cXLineClose = 0.5875;
	float cXLineFar = 0.8625;
	
	/*****************************************************/
	/* Step 1: create 2 types of land separated by water */	rmSetStatusText("",0.15);
	/*****************************************************/
	
	int largeLandBox=rmCreateBoxConstraint("large land box constraint", 0.45, 1.0, 1.0, 0.0);
	
	int largeLandArea=rmCreateArea("Large Land Area");
	rmSetAreaSize(largeLandArea, 0.6, 0.95);
	rmSetAreaCoherence(largeLandArea, 0.25);
	rmSetAreaLocation(largeLandArea, 0.725, 0.5);
	rmAddAreaConstraint(largeLandArea, largeLandBox);
	rmSetAreaHeightBlend(largeLandArea, 2);
	rmSetAreaBaseHeight(largeLandArea, 1.0);
	rmSetAreaWarnFailure(largeLandArea, false);
	rmSetAreaTerrainType(largeLandArea, "JungleA");
	rmAddAreaTerrainLayer(largeLandArea, "JungleDirt75", 0, 6);
	rmAddAreaTerrainLayer(largeLandArea, "JungleDirt50", 6, 12);
	rmAddAreaTerrainLayer(largeLandArea, "JungleDirt25", 12, 18);
	rmAddAreaTerrainLayer(largeLandArea, "JungleA", 18, 24);	
	rmBuildArea(largeLandArea);
	
	int smallLandBox=rmCreateBoxConstraint("small land box constraint", 0.3, 1.0, 0.0, 0.0);
	int smallLandArea=rmCreateArea("Small Land Area");
	rmSetAreaSize(smallLandArea, 0.3, 0.95);
	rmSetAreaCoherence(smallLandArea, 0.25);
	rmSetAreaLocation(smallLandArea, 0.15, 0.5);
	rmAddAreaConstraint(smallLandArea, smallLandBox);
	rmSetAreaHeightBlend(smallLandArea, 2);
	rmSetAreaBaseHeight(smallLandArea, 1.0);
	rmSetAreaWarnFailure(smallLandArea, false);
	rmSetAreaTerrainType(smallLandArea, "PlainA");
	rmBuildArea(smallLandArea);
	
	/***********************************************/
	/* Step 2: place Fish, Starting TC, gold, hunt */	rmSetStatusText("",0.50);
	/***********************************************/
	
	int avoidLand=rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);
	int avoidFish=rmCreateTypeDistanceConstraint("avoid fish", "fish", 4.0);
	
	int littleFishiesLineID=rmCreateObjectDef("fish line");
	rmAddObjectDefItem(littleFishiesLineID, "Fish - Mahi", 3, 8.0+(cNumberNonGaiaPlayers / 3.0)); 
	rmSetObjectDefMinDistance(littleFishiesLineID, 0.0);
	rmSetObjectDefMaxDistance(littleFishiesLineID, 0.0);
	
	if(cNumberNonGaiaPlayers > 4){
		rmPlaceObjectDefInLineZ(littleFishiesLineID, 1, cNumberNonGaiaPlayers*1.35, 0.375, 0.05,  0.95);
	} else {
		rmPlaceObjectDefInLineZ(littleFishiesLineID, 1, cNumberNonGaiaPlayers*2, 0.375, 0.05,  0.95);
	}
	
	//rmPlacePlayersLine(0.15, 0.1, 0.15, 0.9, 0.01, 0.01);
	if(cNumberNonGaiaPlayers < 4){
		rmPlacePointsLineZ(cNumberNonGaiaPlayers, cXLinePlayers, 0.8, 0.2);
	} else {
		rmPlacePointsLineZ(cNumberNonGaiaPlayers, cXLinePlayers, 0.9, 0.1);
	}
	for(p = 1; <= cNumberNonGaiaPlayers){
		rmSetPlayerLocation(p, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p));
	}
	rmRecordPlayerLocations();
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);
	
	int startingGoldFairLocID=rmAddFairLoc("Starting Gold", false, false, 20, 21, 0, 10);
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
	
	//Starting Hunt
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "deer", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 19.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 22.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 8.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int littlePigletsID=rmCreateObjectDef("Squeak, squeak little piggy");
	rmAddObjectDefItem(littlePigletsID, "pig", 3, 2.0);
	rmSetObjectDefMinDistance(littlePigletsID, 25.0);
	rmSetObjectDefMaxDistance(littlePigletsID, 30.0);
	rmPlaceObjectDefPerPlayer(littlePigletsID, true);
	
	//Towers last
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 22.0);
	rmSetObjectDefMaxDistance(startingTowerID, 24.0);
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("avoid tower", "tower", 24.0));
	rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);
	
	//In-between Gold
	float mortarOffset = (0.8 / cNumberNonGaiaPlayers)/2.0;
	
	int mortarGoldID=rmCreateObjectDef("in-between Gold");
	rmAddObjectDefItem(mortarGoldID, "Gold Mine", 1, 0.0);
	rmPlaceObjectDefInLineZ(mortarGoldID, 0, cNumberNonGaiaPlayers, cXLinePlayers, 0.10+mortarOffset,  0.90+mortarOffset);
	//rmPlaceObjectDefInLineZ(mortarGoldID, 0, cNumberNonGaiaPlayers, cXLineClose, 0.10+mortarOffset,  0.90);
	//rmPlaceObjectDefInLineZ(mortarGoldID, 0, cNumberNonGaiaPlayers, cXLineFar, 0.10+mortarOffset,  0.90);
	
	
	/******************************************************/
	/* Step 3: Dynamic Box constraints and their contents */	rmSetStatusText("",0.50);
	/******************************************************/
	
	int fullBoxConst = 0;
	int farBoxConst = 0;
	int closeBoxConst = 0;
	
	int objID = 0;
	int tempArea = 0;
	
	float cZLengthPerPlayer = 0.95/(cNumberNonGaiaPlayers*1.0);
	
	int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	
	int shortVsettlement = rmCreateTypeDistanceConstraint("short avoid TC", "AbstractSettlement", 18.0);
	int farVsettlement = rmCreateTypeDistanceConstraint("far avoid TC", "AbstractSettlement", 25.0+cNumberNonGaiaPlayers);
	
	int shortVgold = rmCreateTypeDistanceConstraint("short avoid gold", "gold", 16.0);
	int farVgold = rmCreateTypeDistanceConstraint("far avoid gold", "gold", 30.0);
	
	int waterVsGold=rmCreateTerrainDistanceConstraint("gold avoids water", "land", false, 20.0);
	int birdiesStayNearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 12.0);
	
	//One big for loop.
	for(p = 1; <= cNumberNonGaiaPlayers){
	
		/*******************/
		/* Box Constraints */
		/*******************/
	
		fullBoxConst = rmCreateBoxConstraint("Player "+p+" Full Box Constraint", 1.0, cZLengthPerPlayer * p, 0.45, cZLengthPerPlayer * (p-1));
		farBoxConst = rmCreateBoxConstraint("Player "+p+" Far-Half Box Constraint", 1.0, cZLengthPerPlayer * p, 0.725, cZLengthPerPlayer * (p-1));
		closeBoxConst = rmCreateBoxConstraint("Player "+p+" Close-Half Box Constraint", 0.725, cZLengthPerPlayer * p, 0.45, cZLengthPerPlayer * (p-1));
	
		rmEchoInfo("      Player "+p+" Full Box Constraint: (1.0, "+(cZLengthPerPlayer * p)+"), (0.45, "+(cZLengthPerPlayer * (p-1))+")");
		rmEchoInfo("  Player "+p+" Far-Half Box Constraint: (1.0, "+(cZLengthPerPlayer * p)+"), (0.725, "+(cZLengthPerPlayer * (p-1))+")");
		rmEchoError("Player "+p+" Close-Half Box Constraint: (0.725, "+(cZLengthPerPlayer * p)+"), (0.45, "+(cZLengthPerPlayer * (p-1))+")");
		
		/*****************/
		/* Close objects */
		/*****************/
	
		//Set the location for the close objects (while this sets the points as "player locations" they are just coordinates and in this case have nothing to do with the player's location).
		rmPlacePointsLineZ(cNumberNonGaiaPlayers, cXLineClose, 0.9, 0.1);
		
		objID=rmCreateObjectDef("unclaimed settlement close "+p);
		rmAddObjectDefItem(objID, "Settlement", 1, 0.0);
		rmAddObjectDefConstraint(objID, closeBoxConst);
		rmAddObjectDefConstraint(objID, edgeConstraint);
		rmAddObjectDefConstraint(objID, farVsettlement);
		rmSetObjectDefMaxDistance(objID, 0.0);
		rmSetObjectDefMaxDistance(objID, 10.0+2*cNumberNonGaiaPlayers);
		
		//Use the points set above.
		//rmGetCustomLocXForPlayer/rmGetCustomLocZForPlayer are not the location of the player's starting TC's - but in this case the location of the close unclaimed settlement for that player.
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);	
		
		objID=rmCreateObjectDef("close Ducks "+p);
		rmAddObjectDefItem(objID, "Duck", rmRandInt(4,7), 3.0);
		rmSetObjectDefMaxDistance(objID, 30.0);
		rmSetObjectDefMaxDistance(objID, 50.0);
		rmAddObjectDefConstraint(objID, closeBoxConst);
		rmAddObjectDefConstraint(objID, birdiesStayNearShore);
		rmAddObjectDefConstraint(objID, shortVsettlement);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
		
		objID=rmCreateObjectDef("close gold "+p);
		rmAddObjectDefItem(objID, "Jade Mine", 1, 3.0);
		rmSetObjectDefMaxDistance(objID, 18.0);
		rmSetObjectDefMaxDistance(objID, 30.0);
		rmAddObjectDefConstraint(objID, edgeConstraint);
		rmAddObjectDefConstraint(objID, closeBoxConst);
		rmAddObjectDefConstraint(objID, waterVsGold);
		rmAddObjectDefConstraint(objID, shortVsettlement);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
		
		objID=rmCreateObjectDef("close hunt "+p);
		rmAddObjectDefItem(objID, "deer", rmRandInt(4,5), 3.0);
		rmSetObjectDefMaxDistance(objID, 20.0);
		rmSetObjectDefMaxDistance(objID, 30.0);
		rmAddObjectDefConstraint(objID, closeBoxConst);
		rmAddObjectDefConstraint(objID, shortVgold);
		rmAddObjectDefConstraint(objID, shortVsettlement);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
		
		objID=rmCreateObjectDef("close hairy piggies "+p);
		rmAddObjectDefItem(objID, "Yak", 3, 2.0);
		rmSetObjectDefMinDistance(objID, 25.0);
		rmSetObjectDefMaxDistance(objID, 35.0);
		rmAddObjectDefConstraint(objID, shortVgold);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
		
		/***************/
		/* Far Objects */
		/***************/
	
		//Set the location for the far objects.
		rmPlacePointsLineZ(cNumberNonGaiaPlayers, cXLineFar, 0.9, 0.1);
		
		objID=rmCreateObjectDef("unclaimed settlement far "+p);
		rmAddObjectDefItem(objID, "Settlement", 1, 0.0);
		rmAddObjectDefConstraint(objID, edgeConstraint);
		rmAddObjectDefConstraint(objID, farBoxConst);
		rmAddObjectDefConstraint(objID, farVsettlement);
		rmSetObjectDefMaxDistance(objID, 0.0);
		rmSetObjectDefMaxDistance(objID, 10.0+2*cNumberNonGaiaPlayers);
		
		//Use the points set above.
		//rmGetCustomLocXForPlayer/rmGetCustomLocZForPlayer are not the location of the player's starting TC's - but in this case the location of the close unclaimed settlement for that player.
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);	
		
		objID=rmCreateObjectDef("far gold "+p);
		rmAddObjectDefItem(objID, "Jade Mine", 1, 3.0);
		rmSetObjectDefMaxDistance(objID, 18.0);
		rmSetObjectDefMaxDistance(objID, 30.0);
		rmAddObjectDefConstraint(objID, edgeConstraint);
		rmAddObjectDefConstraint(objID, farBoxConst);
		rmAddObjectDefConstraint(objID, farVsettlement);
		rmAddObjectDefConstraint(objID, farVgold);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
		
		objID=rmCreateObjectDef("far hunt "+p);
		rmAddObjectDefItem(objID, "deer", rmRandInt(4,5), 3.0);
		rmSetObjectDefMaxDistance(objID, 20.0);
		rmSetObjectDefMaxDistance(objID, 30.0);
		rmAddObjectDefConstraint(objID, farBoxConst);
		rmAddObjectDefConstraint(objID, huntShortAvoidsStartingGoldMilky);
		rmAddObjectDefConstraint(objID, farVsettlement);
		rmAddObjectDefConstraint(objID, farVgold);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
		
		objID=rmCreateObjectDef("far shaggy horses "+p);
		rmAddObjectDefItem(objID, "Yak", 3, 2.0);
		rmSetObjectDefMinDistance(objID, 25.0);
		rmSetObjectDefMaxDistance(objID, 35.0);
		rmAddObjectDefConstraint(objID, farBoxConst);
		rmAddObjectDefConstraint(objID, shortVsettlement);
		rmAddObjectDefConstraint(objID, shortVgold);
		rmPlaceObjectDefAtLoc(objID, 0, rmGetCustomLocXForPlayer(p), rmGetCustomLocZForPlayer(p), 1);
	}
	
	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 50.0);
	
	int farPredatorID=rmCreateObjectDef("far predator");
	rmAddObjectDefItem(farPredatorID, "lizard", 2, 4.0);
	rmSetObjectDefMinDistance(farPredatorID, 0.0);
	rmSetObjectDefMaxDistance(farPredatorID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, largeLandBox);
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid food 379", "food", 20.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid gold 380", "gold", 40.0));
	rmAddObjectDefConstraint(farPredatorID, rmCreateTypeDistanceConstraint("preds avoid settlements 381", "AbstractSettlement", 40.0));
	rmPlaceObjectDefAtLoc(farPredatorID, 0, 0.725, 0.5, cNumberNonGaiaPlayers);
	
	if(cMapSize == 2){
		int giantGold = rmCreateObjectDef("Giant Gold");
		rmAddObjectDefItem(giantGold, "Jade Mine", 0.0);
		rmSetObjectDefMinDistance(giantGold, 0.0);
		rmSetObjectDefMaxDistance(giantGold, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantGold, rmCreateTypeDistanceConstraint("gGold avoid food 379", "food", 20.0));
		rmAddObjectDefConstraint(giantGold, rmCreateTypeDistanceConstraint("gGold avoid gold 380", "gold", 65.0));
		rmAddObjectDefConstraint(giantGold, rmCreateTypeDistanceConstraint("gGold avoid TCs 380", "AbstractSettlement", 65.0));
		rmPlaceObjectDefAtLoc(giantGold, 0, 0.725, 0.5, 4*cNumberNonGaiaPlayers);
		
		objID=rmCreateObjectDef("giant hunt");
		rmAddObjectDefItem(objID, "deer", rmRandInt(4,5), 3.0);
		rmSetObjectDefMaxDistance(objID, 0.0);
		rmSetObjectDefMaxDistance(objID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(objID, farVsettlement);
		rmAddObjectDefConstraint(objID, farVgold);
		rmPlaceObjectDefAtLoc(objID, 0, 0.725, 0.5, 2*cNumberNonGaiaPlayers);
		
		objID=rmCreateObjectDef("giant Ducks");
		rmAddObjectDefItem(objID, "Duck", rmRandInt(4,7), 3.0);
		rmSetObjectDefMaxDistance(objID, 0.0);
		rmSetObjectDefMaxDistance(objID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(objID, farVsettlement);
		rmAddObjectDefConstraint(objID, farVgold);
		rmPlaceObjectDefAtLoc(objID, 0, 0.725, 0.5, 2*cNumberNonGaiaPlayers);
	}
	
	/*************************/
	/* Step 4: place forests */	rmSetStatusText("",0.80);
	/*************************/
	int forestAvoidGold=rmCreateTypeDistanceConstraint("forest v gold", "gold", 16.0);
	int forestAvoidFood=rmCreateTypeDistanceConstraint("forest v food", "food", 12.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	int waterConstraint=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 4.0);
	int avoidSettlement=rmCreateTypeDistanceConstraint("avoid TC", "AbstractSettlement", 16.0);
	
	int forestCount=10*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.75*forestCount;
	}
	
	int forestID=0;
	int failCount=0;
	for(i=0; <forestCount) {
		forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(75), rmAreaTilesToFraction(125));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(175), rmAreaTilesToFraction(225));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "Jungle Forest");
		rmAddAreaConstraint(forestID, forestAvoidGold);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, waterConstraint);
		rmAddAreaConstraint(forestID, forestAvoidFood);
		rmAddAreaConstraint(forestID, avoidSettlement);
//		rmAddAreaConstraint(forestID, largeLandBox);
		rmAddAreaToClass(forestID, csForest);
		
		rmSetAreaMinBlobs(forestID, 2);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 20.0);
		rmSetAreaCoherence(forestID, 0.0);
		rmSetAreaBaseHeight(forestID, 0);
		rmSetAreaSmoothDistance(forestID, 4);
		rmSetAreaHeightBlend(forestID, 2);
		
		if(rmBuildArea(forestID)==false) {
			// Stop trying once we fail 5 times in a row.
			failCount++;
			if(failCount==5) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	forestCount=5*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.75*forestCount;
	}
	
	failCount=0;
	for(i=0; <forestCount) {
		forestID=rmCreateArea("player forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(75), rmAreaTilesToFraction(125));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(175), rmAreaTilesToFraction(225));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "Mixed Plain Forest");
		rmAddAreaConstraint(forestID, forestAvoidGold);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, waterConstraint);
		rmAddAreaConstraint(forestID, forestAvoidFood);
		rmAddAreaConstraint(forestID, avoidSettlement);
		rmAddAreaConstraint(forestID, smallLandBox);
		rmAddAreaToClass(forestID, csForest);
		
		rmSetAreaMinBlobs(forestID, 2);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 20.0);
		rmSetAreaCoherence(forestID, 0.0);
		rmSetAreaBaseHeight(forestID, 0);
		rmSetAreaSmoothDistance(forestID, 4);
		rmSetAreaHeightBlend(forestID, 2);
		
		if(rmBuildArea(forestID)==false) {
			// Stop trying once we fail 5 times in a row.
			failCount++;
			if(failCount==5) {
				break;
			}
		} else {
			failCount=0;
		}
	}
	
	/*************************/
	/* Step 6: Pretty Things */	rmSetStatusText("",0.95);
	/*************************/
	
	int prettyVsForest=rmCreateClassDistanceConstraint("pretty v forest", rmClassID("forest"), 1.0);
	int prettyVsWater=rmCreateClassDistanceConstraint("pretty v water", rmClassID("pool"), 3.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("pretty avoid TCs", "AbstractSettlement", 6.0);
	
	// Beautification sub area.
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier){
		int id4=rmCreateArea("Grass patch 1 "+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16));
		rmSetAreaTerrainType(id4, "PlainDirt75");
		rmSetAreaMinBlobs(id4, 1);
		rmSetAreaMaxBlobs(id4, 5);
		rmSetAreaWarnFailure(id4, false);
		rmAddAreaConstraint(id4, prettyVsForest);
		rmAddAreaConstraint(id4, prettyVsWater);
		rmAddAreaConstraint(id4, shortAvoidSettlement);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0);
		rmSetAreaCoherence(id4, 0.0);
		
		rmBuildArea(id4);
	}
	
	// Beautification sub area.
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier){
		int id5=rmCreateArea("Grass patch 2 "+i);
		rmSetAreaSize(id5, rmAreaTilesToFraction(25), rmAreaTilesToFraction(75));
		rmSetAreaTerrainType(id5, "JungleB");
		rmAddAreaConstraint(id5, prettyVsForest);
		rmAddAreaConstraint(id5, prettyVsWater);
		rmAddAreaConstraint(id5, shortAvoidSettlement);
		rmSetAreaWarnFailure(id5, false);
		rmSetAreaCoherence(id5, 0.0);
		
		rmBuildArea(id5);
	}

	// Random trees.
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "Tree Jungle", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, forestAvoidGold);
	rmAddObjectDefConstraint(randomTreeID, avoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "bush", rmRandInt(1,3), 3.0);
	rmAddObjectDefItem(logID, "grass", rmRandInt(6,8), 12.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmZFractionToMeters(0.5));
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 16*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	// Relics avoid TCs
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(relicID, largeLandBox);
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 100.0));
	rmAddObjectDefConstraint(relicID, prettyVsForest);
	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	if(cMapSize == 2){
		rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic Giant", "relic", 110.0));
		rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}

	rmSetStatusText("",1.0);
}
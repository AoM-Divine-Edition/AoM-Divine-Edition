/*	Tundra - Freshed up
**	Made by Hagrit (Original concept by Ensemble Studios)
*/

void main(void) {
	
	///INITIALIZE MAP
	rmSetStatusText("",0.01);
	
	int mapSizeMultiplier = 1;
   
	int playerTiles=7500;
	if(cMapSize == 1)
	{
		playerTiles = 9750;
		rmEchoInfo("Large map");
		mapSizeMultiplier = 1;
	}
	if (cMapSize == 2)
	{
		playerTiles = 19500;
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	rmTerrainInitialize("TundraRockA");
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer			= rmDefineClass("player");
	int classForest			= rmDefineClass("forest");
	int classStartingTC		= rmDefineClass("Starting settlement");
	int classPond			= rmDefineClass("pond");
	int classCorner			= rmDefineClass("corner");
	int classAvoidCorner	= rmDefineClass("non corner");
	int classCenter			= rmDefineClass("center");
	int classBonusHuntable	= rmDefineClass("bonus hunt");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdgeShort	= rmCreateBoxConstraint("BC0", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int AvoidEdgeFar	= rmCreateBoxConstraint("BC1", rmXTilesToFraction(6), rmZTilesToFraction(6), 1.0-rmXTilesToFraction(6), 1.0-rmZTilesToFraction(6));
	
	int AvoidAll			= rmCreateTypeDistanceConstraint("TD0", "all", 6);
	int AvoidTower			= rmCreateTypeDistanceConstraint("TD1", "tower", 25);
	int AvoidHunt			= rmCreateTypeDistanceConstraint("TD2", "huntable", 25);
	int AvoidGold			= rmCreateTypeDistanceConstraint("TD3", "gold", 30);
	int AvoidSettlement		= rmCreateTypeDistanceConstraint("TD4", "abstractSettlement", 20);
	int AvoidSettlementFar	= rmCreateTypeDistanceConstraint("TD5", "abstractSettlement", 30);
	int AvoidGoldFar		= rmCreateTypeDistanceConstraint("TD6", "gold", 40);
	int AvoidPredator		= rmCreateTypeDistanceConstraint("TD7", "animalPredator", 20);
	int AvoidBuildings		= rmCreateTypeDistanceConstraint("TD8", "Building", 15.0);
	int AvoidBerries		= rmCreateTypeDistanceConstraint("TD9", "berry bush", 30.0);
	
	int AvoidPlayer 		= rmCreateClassDistanceConstraint("CD0", classPlayer, 10);
	int AvoidStartingSettle = rmCreateClassDistanceConstraint("CD1", classStartingTC, 20);
	int AvoidCornerShort	= rmCreateClassDistanceConstraint("CD2", classCorner, 1.0);
	int AvoidCorner			= rmCreateClassDistanceConstraint("CD3", classCorner, 15.0);
	int inCorner			= rmCreateClassDistanceConstraint("CD4", classAvoidCorner, 1.0);
	int AvoidCenterShort	= rmCreateClassDistanceConstraint("CD5", classCenter, 5.0);
	int AvoidCenterPond		= rmCreateClassDistanceConstraint("CD6", classCenter, 15.0);
	int AvoidBonusHunt		= rmCreateClassDistanceConstraint("CD7", classBonusHuntable, 40.0);
	int AvoidPond			= rmCreateClassDistanceConstraint("CD8", classPond, 20.0);
	int AvoidForest			= rmCreateClassDistanceConstraint("CD9", classForest, 25.0);
	
	int AvoidImpassableland	= rmCreateTerrainDistanceConstraint("TDC0", "land", false, 6);
	
	rmSetStatusText("",0.25);
	///PLAYER LOC DEFINITION
	rmSetTeamSpacingModifier(0.75);
    rmPlacePlayersCircular(0.35, 0.4, rmDegreesToRadians(1.0));
	
	rmSetStatusText("",0.30);	
	///OBJECT DEFINITION
	int IDStartingSettlement	= rmCreateObjectDef("starting tc");
	rmAddObjectDefItem			(IDStartingSettlement, "settlement level 1", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingSettlement, 0);
	rmSetObjectDefMaxDistance	(IDStartingSettlement, 0);
	rmAddObjectDefToClass		(IDStartingSettlement, classStartingTC);
	
	int GoldDistance = rmRandInt(21,23);
	
	int IDStartingGold			= rmCreateObjectDef("gold");
	rmAddObjectDefItem			(IDStartingGold, "gold mine small", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidAll);
	
	int IDStartingTowers		= rmCreateObjectDef("tower");
	rmAddObjectDefItem			(IDStartingTowers, "tower", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingTowers, 22);
	rmSetObjectDefMaxDistance	(IDStartingTowers, 27);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidTower);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidEdgeShort);
	
	int IDStartingHunt			= rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem			(IDStartingHunt, "Caribou", rmRandInt(6,7), 3);
	rmSetObjectDefMinDistance	(IDStartingHunt, 25);
	rmSetObjectDefMaxDistance	(IDStartingHunt, 27);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidEdgeShort);
	
	int IDStartingGoats			= rmCreateObjectDef("starting goats");
	
	if(rmRandFloat(0,1)<0.9)
		rmAddObjectDefItem		(IDStartingGoats, "goat", rmRandInt(6,8), 5.0);
	else
		rmAddObjectDefItem		(IDStartingGoats, "berry bush", rmRandInt(6,8), 4.0);
	
	rmSetObjectDefMinDistance	(IDStartingGoats, 20.0);
	rmSetObjectDefMaxDistance	(IDStartingGoats, 25.0);
	rmAddObjectDefConstraint	(IDStartingGoats, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingGoats, AvoidEdgeShort);
	
	float huntableNumber = rmRandFloat(0, 1);
	
	int IDStartingAuroch		= rmCreateObjectDef("starting auroch");
	
	if (huntableNumber<0.1)
	{   
		rmAddObjectDefItem		(IDStartingAuroch, "Elk", rmRandInt(5,6), 3.0);
		rmAddObjectDefItem		(IDStartingAuroch, "Caribou", rmRandInt(5,6), 6.0);
	} else if (huntableNumber<0.3)
		rmAddObjectDefItem		(IDStartingAuroch, "Elk", rmRandInt(5,6), 3.0);
	else if(huntableNumber<0.6)
		rmAddObjectDefItem		(IDStartingAuroch, "Aurochs", 2, 2.0);
	else if (huntableNumber<0.9)
		rmAddObjectDefItem		(IDStartingAuroch, "Aurochs", 3, 2.0);
	else if (huntableNumber<1.0)
		rmAddObjectDefItem		(IDStartingAuroch, "Aurochs", 4, 2.0);
	
	rmSetObjectDefMinDistance	(IDStartingAuroch, 35);
	rmSetObjectDefMaxDistance	(IDStartingAuroch, 45);
	rmAddObjectDefConstraint	(IDStartingAuroch, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingAuroch, AvoidHunt);
	rmAddObjectDefConstraint	(IDStartingAuroch, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDStartingAuroch, AvoidSettlement);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler");
	rmAddObjectDefItem			(IDStragglerTree, "tundra tree", 1, 0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15);
	rmAddObjectDefConstraint	(IDStragglerTree, AvoidAll);
	
	//medium 
	
	int IDMediumGold			= rmCreateObjectDef("medium gold");
	rmAddObjectDefItem			(IDMediumGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumGold, 60.0);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidPlayer);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCornerShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCenterShort);
	
	int IDMediumHunt			= rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem			(IDMediumHunt, "Caribou", rmRandInt(4,5), 4.0);
	rmSetObjectDefMinDistance	(IDMediumHunt, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumHunt, 70.0);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidPlayer);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidCornerShort);
	
	int IDMediumElk				= rmCreateObjectDef("medium elk");
	rmAddObjectDefItem			(IDMediumElk, "Elk", rmRandInt(5, 9), 4.0);
	rmSetObjectDefMinDistance	(IDMediumElk, 60.0);
	rmSetObjectDefMaxDistance	(IDMediumElk, 80.0);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidPlayer);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidHunt);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDMediumElk, AvoidCorner);
	
	//far
	
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 75.0);
	if (cNumberNonGaiaPlayers < 3) {
		rmSetObjectDefMaxDistance	(IDFarGold, 95.0);
	} else 
	rmSetObjectDefMaxDistance	(IDFarGold, 110.0);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarGold, AvoidCornerShort);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableland);

	int IDFarAurochs			= rmCreateObjectDef("far aurochs");
	rmAddObjectDefItem			(IDFarAurochs, "Aurochs", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance	(IDFarAurochs, 80.0);
	rmSetObjectDefMaxDistance	(IDFarAurochs, 110.0);
	rmAddObjectDefConstraint	(IDFarAurochs, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarAurochs, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDFarAurochs, AvoidHunt);
	rmAddObjectDefConstraint	(IDFarAurochs, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarAurochs, AvoidEdgeShort);
	
	int IDFarPred				= rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5)   
		rmAddObjectDefItem		(IDFarPred, "Polar Bear", 1, 4.0);
	else
		rmAddObjectDefItem		(IDFarPred, "Wolf Arctic 2", 2, 4.0);
	
	rmSetObjectDefMinDistance	(IDFarPred, 50.0);
	rmSetObjectDefMaxDistance	(IDFarPred, 100.0);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarPred, AvoidAll);
	rmAddObjectDefConstraint	(IDFarPred, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDFarPred, AvoidImpassableland);
	
	int IDFarBerries			= rmCreateObjectDef("far berries");
	rmAddObjectDefItem			(IDFarBerries, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance	(IDFarBerries, 75.0);
	rmSetObjectDefMaxDistance	(IDFarBerries, 110.0);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidAll);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidBerries);
	
	
	int IDBonusHunt				= rmCreateObjectDef("bonus huntable");
	
	float bonusChance = rmRandFloat(0, 1);
	
	if (bonusChance < 0.2)
	{   
		rmAddObjectDefItem		(IDBonusHunt, "Caribou", rmRandInt(4,5), 3.0);
		rmAddObjectDefItem		(IDBonusHunt, "Aurochs", rmRandInt(0,2), 3.0);
	}
	else if (bonusChance < 0.5)
		rmAddObjectDefItem		(IDBonusHunt, "Elk", rmRandInt(4,6), 2.0);
	else if (bonusChance < 0.9)
		rmAddObjectDefItem		(IDBonusHunt, "Aurochs", rmRandInt(2,3), 2.0);
	else
		rmAddObjectDefItem		(IDBonusHunt, "Caribou", rmRandInt(4,7), 3.0);
	
	rmSetObjectDefMinDistance	(IDBonusHunt, 90.0);
	rmSetObjectDefMaxDistance	(IDBonusHunt, 115.0);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidHunt);
	rmAddObjectDefToClass		(IDBonusHunt, classBonusHuntable);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidPlayer);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidSettlement);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidEdgeShort);
	
	int IDBonusHunt2			= rmCreateObjectDef("second bonus huntable");
	
	bonusChance = rmRandFloat(0, 1);
	
	if (bonusChance < 0.1)   
		rmAddObjectDefItem		(IDBonusHunt2, "Aurochs", 3, 2.0);
	else if (bonusChance < 0.5)
		rmAddObjectDefItem		(IDBonusHunt2, "Aurochs", 2, 2.0);
	else if (bonusChance < 0.9)
		rmAddObjectDefItem		(IDBonusHunt2, "Aurochs", 2, 2.0);
	else
		rmAddObjectDefItem		(IDBonusHunt2, "Aurochs", 3, 4.0);
	
	rmSetObjectDefMinDistance	(IDBonusHunt2, 80.0);
	rmSetObjectDefMaxDistance	(IDBonusHunt2, 110.0);
	rmAddObjectDefToClass		(IDBonusHunt2, classBonusHuntable);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidHunt);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidPlayer);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidSettlement);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidEdgeShort);
	
	//other
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "Tundra Tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidSettlement);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableland);
	 
	int IDOtherWolf				= rmCreateObjectDef("other wolf");
	rmAddObjectDefItem			(IDOtherWolf, "Wolf Arctic 2", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDOtherWolf, 0.0);
	rmSetObjectDefMaxDistance	(IDOtherWolf, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDOtherWolf, AvoidPlayer);
	rmAddObjectDefConstraint	(IDOtherWolf, AvoidSettlement);
	rmAddObjectDefConstraint	(IDOtherWolf, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDOtherWolf, AvoidPredator);
	
	int IDBird					=	rmCreateObjectDef("far birds");
	rmAddObjectDefItem			(IDBird, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance	(IDBird, 0.0);
	rmSetObjectDefMaxDistance	(IDBird, rmXFractionToMeters(0.5));
	
	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRelic, 60.0);
	rmSetObjectDefMaxDistance	(IDRelic, 150.0);
	rmAddObjectDefConstraint	(IDRelic, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDRelic, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint	(IDRelic, AvoidPlayer);
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDRelic, AvoidAll);
	
	//giant
	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, AvoidAll);
		rmAddObjectDefConstraint(giantGoldID, AvoidGoldFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlement);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(5,7), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, AvoidPlayer);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableland);
		rmAddObjectDefConstraint(giantHuntableID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdgeFar);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHunt);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidPlayer);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
	}
	
	rmSetStatusText("",0.40);
	///AREA DEFINITION
	float playerFraction=rmAreaTilesToFraction(3000);
	for(i=1; <cNumberPlayers)
	{
		int IDPlayerArea		= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, IDPlayerArea);
		rmSetAreaSize			(IDPlayerArea, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass		(IDPlayerArea, classPlayer);
		rmSetAreaWarnFailure	(IDPlayerArea, false);
		rmSetAreaMinBlobs		(IDPlayerArea, 0);
		rmSetAreaMaxBlobs		(IDPlayerArea, 0);
		rmSetAreaMinBlobDistance(IDPlayerArea, 12.0);
		rmSetAreaMaxBlobDistance(IDPlayerArea, 20.0);
		rmSetAreaCoherence		(IDPlayerArea, 0.90);
		rmAddAreaConstraint		(IDPlayerArea, AvoidPlayer);
		rmSetAreaLocPlayer		(IDPlayerArea, i);
	}
	
	rmBuildAllAreas();
	
	
	
	int AreaCenter			= rmCreateArea("center");
	rmSetAreaSize			(AreaCenter, 0.001, 0.001);
	rmSetAreaLocation		(AreaCenter, 0.5, 0.5);
	rmSetAreaWarnFailure	(AreaCenter, false);
	rmAddAreaToClass		(AreaCenter, classCenter);
	rmSetAreaCoherence		(AreaCenter, 1.0);
	
	rmBuildArea(AreaCenter);
	
	if (cNumberNonGaiaPlayers < 3) {
		int AreaCornerN			= rmCreateArea("cornerN");
		rmSetAreaSize			(AreaCornerN, 0.05, 0.05);
		rmSetAreaLocation		(AreaCornerN, 1.0, 1.0);
		rmSetAreaWarnFailure	(AreaCornerN, false);
		rmAddAreaToClass		(AreaCornerN, classCorner);
		rmSetAreaCoherence		(AreaCornerN, 1.0);
		
		rmBuildArea(AreaCornerN);
		
		int AreaCornerE			= rmCreateArea("cornerE");
		rmSetAreaSize			(AreaCornerE, 0.05, 0.05);
		rmSetAreaLocation		(AreaCornerE, 1.0, 0.0);
		rmSetAreaWarnFailure	(AreaCornerE, false);
		rmAddAreaToClass		(AreaCornerE, classCorner);
		rmSetAreaCoherence		(AreaCornerE, 1.0);
		
		rmBuildArea(AreaCornerE);
		
		int AreaCornerS			= rmCreateArea("cornerS");
		rmSetAreaSize			(AreaCornerS, 0.05, 0.05);
		rmSetAreaLocation		(AreaCornerS, 0.0, 1.0);
		rmSetAreaWarnFailure	(AreaCornerS, false);
		rmAddAreaToClass		(AreaCornerS, classCorner);
		rmSetAreaCoherence		(AreaCornerS, 1.0);
		
		rmBuildArea(AreaCornerS);
		
		int AreaCornerW			= rmCreateArea("cornerW");
		rmSetAreaSize			(AreaCornerW, 0.05, 0.05);
		rmSetAreaLocation		(AreaCornerW, 0.0, 0.0);
		rmSetAreaWarnFailure	(AreaCornerW, false);
		rmAddAreaToClass		(AreaCornerW, classCorner);
		rmSetAreaCoherence		(AreaCornerW, 1.0);
		
		rmBuildArea(AreaCornerW);
		
		int AreaNonCorner		= rmCreateArea("avoid corner");
		rmSetAreaSize			(AreaNonCorner, 0.8, 0.8);
		rmSetAreaLocation		(AreaNonCorner, 0.5, 0.5);
		rmSetAreaWarnFailure	(AreaNonCorner, false);
		rmAddAreaToClass		(AreaNonCorner, classAvoidCorner);
		rmAddAreaConstraint		(AreaNonCorner, AvoidCornerShort);
		rmSetAreaCoherence		(AreaNonCorner, 1.0);
		
		rmBuildArea(AreaNonCorner);
	}
	
	rmSetStatusText("",0.50);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int AreaSettle = rmAddFairLoc("Settlement", false, true,  65, 85, 40, 20);

	if(rmRandFloat(0,1)<0.75)
		AreaSettle = rmAddFairLoc("Settlement", true, false, 85, 100, 75, 65);
	else
		AreaSettle = rmAddFairLoc("Settlement", false, true,  70, 85, 70, 40);
	
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", true, false,  100, 170, 75, 50);
		
		AreaSettle = rmAddFairLoc("Settlement", true, false,  120, 200, 75, 50);
	}
	
	rmAddFairLocConstraint	(AreaSettle, AvoidImpassableland);
	rmAddFairLocConstraint	(AreaSettle, AvoidCenterShort);

	if(rmPlaceFairLocs())
	{
		AreaSettle			= rmCreateObjectDef("far settlement2");
		rmAddObjectDefItem	(AreaSettle, "Settlement", 1, 0.0);
		for(i=1; <cNumberPlayers)
		{
			for(j=0; <rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(AreaSettle, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	rmSetStatusText("",0.60);
	///AREA DEFINITION
	
	int numTries = 40*cNumberNonGaiaPlayers;
	int failCount = 0;
	for(i = 0; <numTries*mapSizeMultiplier)
	{
		int IDElev				= rmCreateArea("wrinkle"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure	(IDElev, false);
		rmSetAreaTerrainType	(IDElev, "TundraGrassA");
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(7.0, 9.0));
		rmAddAreaConstraint		(IDElev, AvoidImpassableland);
		rmAddAreaConstraint		(IDElev, AvoidStartingSettle);
		rmSetAreaHeightBlend	(IDElev, 4);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 3);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 20.0);
		rmSetAreaCoherence		(IDElev, 0.0);
	
		if(rmBuildArea(IDElev)==false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3)
				break;
		}
		else
			failCount=0;
	}
	
	for(i = 0; < cNumberNonGaiaPlayers*mapSizeMultiplier)
	{
		int IDPond				= rmCreateArea("small pond"+i);
		rmSetAreaSize			(IDPond, rmAreaTilesToFraction(350*mapSizeMultiplier), rmAreaTilesToFraction(400*mapSizeMultiplier));
		rmSetAreaWaterType		(IDPond, "Tundra Pool");
		rmSetAreaMinBlobs		(IDPond, 1);
		rmSetAreaMaxBlobs		(IDPond, 1*mapSizeMultiplier);
		rmSetAreaSmoothDistance	(IDPond, 10);
		rmAddAreaToClass		(IDPond, classPond);
		rmAddAreaConstraint		(IDPond, AvoidPond);
		rmAddAreaConstraint		(IDPond, AvoidPlayer);
		rmAddAreaConstraint		(IDPond, AvoidSettlementFar);
		rmAddAreaConstraint		(IDPond, AvoidCenterPond);
		
		if(rmBuildArea(IDPond)==false)
	{
		// Stop trying once we fail 3 times in a row.
		failCount++;
		if(failCount==2)
		break;
	}
	else
		failCount=0;
	
	}
	
	for(i = 1; <cNumberPlayers*100*mapSizeMultiplier)
	{
		int IDDirtPatch			= rmCreateArea("dirt patch"+i);
		rmSetAreaSize			(IDDirtPatch, rmAreaTilesToFraction(20), rmAreaTilesToFraction(40));
		rmSetAreaTerrainType	(IDDirtPatch, "TundraGrassB");
		rmSetAreaMinBlobs		(IDDirtPatch, 1);
		rmSetAreaMaxBlobs		(IDDirtPatch, 5);
		rmSetAreaWarnFailure	(IDDirtPatch, false);
		rmSetAreaMinBlobDistance(IDDirtPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDDirtPatch, 40.0);
		rmAddAreaConstraint		(IDDirtPatch, AvoidPond);
	
		rmBuildArea(IDDirtPatch);
	}
	
	for(i = 1; <cNumberPlayers*30*mapSizeMultiplier)
	{
		int IDGrassPatch		= rmCreateArea("Grass patch"+i);
		rmSetAreaSize			(IDGrassPatch, rmAreaTilesToFraction(30), rmAreaTilesToFraction(70));
		rmSetAreaTerrainType	(IDGrassPatch, "TundraGrassA");
		rmSetAreaMinBlobs		(IDGrassPatch, 1);
		rmSetAreaMaxBlobs		(IDGrassPatch, 5);
		rmSetAreaWarnFailure	(IDGrassPatch, false);
		rmSetAreaMinBlobDistance(IDGrassPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDGrassPatch, 40.0);
		rmSetAreaCoherence		(IDGrassPatch, 0.0);
		rmAddAreaConstraint		(IDGrassPatch, AvoidPond);
	
		rmBuildArea(IDGrassPatch);
	}
	
	rmSetStatusText("",0.70);
	///OBJECT PLACEMENT
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingTowers, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingHunt, false);
	rmPlaceObjectDefPerPlayer(IDStartingAuroch, false);
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(1,7));
	rmPlaceObjectDefPerPlayer(IDStartingGoats, true);
	
	rmPlaceObjectDefPerPlayer(IDMediumGold, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDMediumHunt, false, 2);
	rmPlaceObjectDefPerPlayer(IDMediumElk, false);
	
	rmPlaceObjectDefPerPlayer(IDFarGold, false, rmRandInt(2,4));
	rmPlaceObjectDefPerPlayer(IDFarAurochs, false);
	rmPlaceObjectDefPerPlayer(IDFarPred, false, 2);
	
	if(rmRandFloat(0,1)<0.6)
		rmPlaceObjectDefAtLoc(IDFarBerries, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmPlaceObjectDefAtLoc(IDBonusHunt, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmPlaceObjectDefAtLoc(IDBonusHunt2, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmPlaceObjectDefPerPlayer(IDRelic, false);
	
	if(rmRandFloat(0,1)<0.5)
		rmPlaceObjectDefPerPlayer(IDOtherWolf, false, 3); 
	
	rmPlaceObjectDefPerPlayer(IDBird, false, 2*mapSizeMultiplier); 
	
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.80);
	///FORESTS
	failCount=0;
	numTries=15*cNumberNonGaiaPlayers;
	for(i = 0; <numTries*mapSizeMultiplier)
	{
		int IDForest			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "tundra forest");
		rmAddAreaConstraint		(IDForest, AvoidStartingSettle);
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidImpassableland);
		rmAddAreaToClass		(IDForest, classForest);
		
		rmSetAreaMinBlobs		(IDForest, 3);
		rmSetAreaMaxBlobs		(IDForest, 7);
		rmSetAreaMinBlobDistance(IDForest, 16.0);
		rmSetAreaMaxBlobDistance(IDForest, 40.0);
		rmSetAreaCoherence		(IDForest, 0.0);
	
		if(rmBuildArea(IDForest)==false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3)
				break;
		}
		else
			failCount=0;
	}
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmSetStatusText("",0.85);
	///BEAUTIFY
	int IDRockPile				= rmCreateObjectDef("rock pile");
	rmAddObjectDefItem			(IDRockPile, "Rock Sandstone small", rmRandInt(2,3), 6.0);
	rmAddObjectDefItem			(IDRockPile, "Rock Granite small", rmRandInt(2,3), 5.0);
	rmAddObjectDefItem			(IDRockPile, "Rock Granite big", rmRandInt(0,1), 5.0);
	rmSetObjectDefMinDistance	(IDRockPile, 0.0);
	rmSetObjectDefMaxDistance	(IDRockPile, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRockPile, AvoidAll);
	rmAddObjectDefConstraint	(IDRockPile, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDRockPile, AvoidBuildings);
	rmPlaceObjectDefAtLoc		(IDRockPile, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDLonelyHunt			= rmCreateObjectDef("lonely deer");
	
	if (rmRandFloat(0,1) < 0.5)
		rmAddObjectDefItem		(IDLonelyHunt, "Elk", rmRandInt(1,3), 2.0);
	else
		rmAddObjectDefItem		(IDLonelyHunt, "Caribou", rmRandInt(1,3), 2.0);
	
	rmSetObjectDefMinDistance	(IDLonelyHunt, 0.0);
	rmSetObjectDefMaxDistance	(IDLonelyHunt, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLonelyHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDLonelyHunt, AvoidBuildings);
	rmAddObjectDefConstraint	(IDLonelyHunt, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDLonelyHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDLonelyHunt, AvoidPlayer);
	rmAddObjectDefConstraint	(IDLonelyHunt, AvoidEdgeShort);
	rmPlaceObjectDefAtLoc		(IDLonelyHunt, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDLonelyHunt2			= rmCreateObjectDef("lonely deer2");
	if(rmRandFloat (0,1) < 0.5)
		rmAddObjectDefItem		(IDLonelyHunt2, "Aurochs", 1, 1.0);
	else
		rmAddObjectDefItem		(IDLonelyHunt2, "Elk", 1, 0.0);
	rmSetObjectDefMinDistance	(IDLonelyHunt2, 0.0);
	rmSetObjectDefMaxDistance	(IDLonelyHunt2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLonelyHunt2, AvoidAll);
	rmAddObjectDefConstraint	(IDLonelyHunt2, AvoidBuildings);
	rmAddObjectDefConstraint	(IDLonelyHunt2, AvoidImpassableland);
	rmAddObjectDefConstraint	(IDLonelyHunt2, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDLonelyHunt2, AvoidPlayer);
	rmAddObjectDefConstraint	(IDLonelyHunt2, AvoidHunt);
	rmPlaceObjectDefAtLoc		(IDLonelyHunt2, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDSmallRock				= rmCreateObjectDef("rock small");
	rmAddObjectDefItem			(IDSmallRock, "rock sandstone small", 1, 0.0);
	rmSetObjectDefMinDistance	(IDSmallRock, 0.0);
	rmSetObjectDefMaxDistance	(IDSmallRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSmallRock, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDSmallRock, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDRockSprite			= rmCreateObjectDef("rock");
	rmAddObjectDefItem			(IDRockSprite, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRockSprite, 0.0);
	rmSetObjectDefMaxDistance	(IDRockSprite, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRockSprite, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDRockSprite, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",0.90);
	///TRIGGERS
	rmCreateTrigger("Snow_A");
	rmCreateTrigger("Snow_backup");
	rmSwitchToTrigger(rmTriggerID("Snow_A"));
	rmSetTriggerPriority(2);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 2);
	rmAddTriggerEffect("Render Snow");
	rmSetTriggerEffectParamFloat("Percent", 0.1);
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_backup"));
	rmSwitchToTrigger(rmTriggerID("Snow_backup"));
	rmSetTriggerPriority(2);
	rmSetTriggerActive(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Timer");
	rmSetTriggerConditionParamInt("Param1", 60);
	rmAddTriggerEffect("Fire Event");
	rmSetTriggerEffectParamInt("EventID", rmTriggerID("Snow_A"));
	
	rmSetStatusText("",1.00);
}
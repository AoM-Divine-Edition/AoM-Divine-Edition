/*Oasis
**Made by Hagrit (Original concept Ensemble Studios)
*/
void main(void)
{
	///INITIALIZE MAP
	rmSetStatusText("",0.01);
	
	int mapSizeMultiplier = 1;
	
	int playerTiles = 7500;
	if(cMapSize == 1)
	{
		playerTiles = 9750;
		rmEchoInfo("Large map");
		mapSizeMultiplier = 1;
	} 
	else if(cMapSize == 2) 
	{
		playerTiles = 19500;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	rmSetSeaLevel(0.0);
	rmTerrainInitialize("SandC");
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer			= rmDefineClass("player");
	int classCorner			= rmDefineClass("corner");
	int classStartingSettle	= rmDefineClass("starting settlement");
	int classForest			= rmDefineClass("forest");
	int classForestCenter	= rmDefineClass("forest center");
	int classBonusHuntable	= rmDefineClass("bonus huntable");
	int classCenter			= rmDefineClass("center");
	int classAvoidCorner	= rmDefineClass("Avoid Corner");
	int classPlayerArea		= rmDefineClass("Avoid player area");
	int classElev			= rmDefineClass("elev");
	int classNormalForest	= rmDefineClass("forest normal");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdge		= rmCreateBoxConstraint	("B0", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int AvoidEdgeFar	= rmCreateBoxConstraint	("B1", rmXTilesToFraction(6), rmZTilesToFraction(6), 1.0-rmXTilesToFraction(6), 1.0-rmZTilesToFraction(6));
	
	int AvoidAll			= rmCreateTypeDistanceConstraint ("T0", "all", 6.0);
	int AvoidTower			= rmCreateTypeDistanceConstraint ("T1", "tower", 24.0);
	int AvoidBuildings		= rmCreateTypeDistanceConstraint ("T2", "Building", 20.0);
	int AvoidGold			= rmCreateTypeDistanceConstraint ("T3", "gold", 30.0);
	int AvoidSettlementAbit	= rmCreateTypeDistanceConstraint ("T4", "AbstractSettlement", 21.0);
	int AvoidHerdable		= rmCreateTypeDistanceConstraint ("T5", "herdable", 20.0);
	int AvoidPredator		= rmCreateTypeDistanceConstraint ("T6", "animalPredator", 20.0);
	int AvoidHuntable		= rmCreateTypeDistanceConstraint ("T7", "huntable", 20.0);
	int AvoidGoldFar		= rmCreateTypeDistanceConstraint ("T8", "gold", 40.0);
	int AvoidBerry			= rmCreateTypeDistanceConstraint ("T9", "berry bush", 30.0);
	int AvoidTowerFar		= rmCreateTypeDistanceConstraint ("T10", "tower", 28.0);
	int AvoidHuntableFar	= rmCreateTypeDistanceConstraint ("T11", "huntable", 30.0);
	int AvoidGoldShort		= rmCreateTypeDistanceConstraint ("T12", "gold", 8.0);
	
	int AvoidPlayer					= rmCreateClassDistanceConstraint ("C0", classStartingSettle, 50.0);
	int AvoidForestCenter			= rmCreateClassDistanceConstraint ("C1", classForestCenter, 10.0);
	int AvoidForest					= rmCreateClassDistanceConstraint ("C2", classNormalForest, 24.0);
	int AvoidStartingSettle			= rmCreateClassDistanceConstraint ("C3", classStartingSettle, 20.0);
	int AvoidCenter					= rmCreateClassDistanceConstraint ("C4", classCenter, 40.0);
	int AvoidCenterShort			= rmCreateClassDistanceConstraint ("C5", classCenter, 10.0);
	int AvoidCornerShort			= rmCreateClassDistanceConstraint ("C6", classCorner, 1.0);
	int InCorner					= rmCreateClassDistanceConstraint ("C7", classAvoidCorner, 1.0);
	int AvoidCenterShortest			= rmCreateClassDistanceConstraint ("C8", classCenter, 8.0);
	int AvoidPlayerArea				= rmCreateClassDistanceConstraint ("C9", classPlayerArea, 2.0);
	int AvoidElev					= rmCreateClassDistanceConstraint ("C10", classElev, 10.0);
	int AvoidForestCenterFar		= rmCreateClassDistanceConstraint ("C11", classForestCenter, 14.0);
	int AvoidForestCenterFarthest	= rmCreateClassDistanceConstraint ("C12", classForestCenter, 20.0);
	
	int AvoidImpassableLand	= rmCreateTerrainDistanceConstraint("TR0", "land", false, 5.0);
	
	rmSetStatusText("",0.25);
	///OBJECT DEFINITION
	int IDStartingSettlement  	= rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem        	(IDStartingSettlement, "Settlement Level 1", 1, 0.0);
	rmAddObjectDefToClass     	(IDStartingSettlement, classStartingSettle);
	rmSetObjectDefMinDistance 	(IDStartingSettlement, 0.0);
	rmSetObjectDefMaxDistance 	(IDStartingSettlement, 0.0);	
	
	int IDStartingTower 	  	= rmCreateObjectDef("starting towers");
	rmAddObjectDefItem        	(IDStartingTower, "tower", 1, 0.0);
	rmAddObjectDefConstraint  	(IDStartingTower, AvoidTower);
	rmAddObjectDefConstraint  	(IDStartingTower, AvoidEdge);
	rmAddObjectDefConstraint  	(IDStartingTower, AvoidAll);
	rmSetObjectDefMinDistance 	(IDStartingTower, 20.0);
	rmSetObjectDefMaxDistance 	(IDStartingTower, 28.0);
	
	int GoldDistance = rmRandInt(20,24);
	
	int IDStartingGold			= rmCreateObjectDef("starting goldmine");
	rmAddObjectDefItem			(IDStartingGold, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance 	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance 	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidEdge);
	
	int IDStartingGoat			= rmCreateObjectDef("starting goats");
	rmAddObjectDefItem			(IDStartingGoat, "goat", 2, 2.0);
	rmSetObjectDefMinDistance	(IDStartingGoat, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingGoat, 30.0);
	rmAddObjectDefConstraint	(IDStartingGoat, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingGoat, AvoidEdge);
	
	int IDStartingWildcrops		= rmCreateObjectDef("starting Wildcrops");
	
	if(rmRandFloat(0, 1) < 0.5)
		rmAddObjectDefItem		(IDStartingWildcrops, "chicken", rmRandInt(5,8), 5.0);
	else
		rmAddObjectDefItem		(IDStartingWildcrops, "berry bush", rmRandInt(6,8), 4.0);
	
	rmSetObjectDefMinDistance	(IDStartingWildcrops, 20.0);
	rmSetObjectDefMaxDistance	(IDStartingWildcrops, 25.0);
	rmAddObjectDefConstraint	(IDStartingWildcrops, AvoidAll); 
	rmAddObjectDefConstraint	(IDStartingWildcrops, AvoidEdge); 
	rmAddObjectDefConstraint	(IDStartingWildcrops, AvoidGoldShort); 
	
	int IDStartingZebra			= rmCreateObjectDef("starting zebra");
	rmAddObjectDefItem			(IDStartingZebra, "zebra", rmRandInt(2,5), 3.0);
	
	if(rmRandFloat(0, 1) < 0.4)
	{
		rmSetObjectDefMinDistance	(IDStartingZebra, 45.0);
		rmSetObjectDefMaxDistance	(IDStartingZebra, 55.0);
		rmAddObjectDefConstraint	(IDStartingZebra, AvoidTowerFar);
	}
	else 
	{
		rmSetObjectDefMinDistance	(IDStartingZebra, 22.0);
		rmSetObjectDefMaxDistance	(IDStartingZebra, 27.0);
	}
	rmAddObjectDefConstraint	(IDStartingZebra, AvoidCenter);
	rmAddObjectDefConstraint	(IDStartingZebra, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingZebra, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingZebra, AvoidImpassableLand);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "palm", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	rmAddObjectDefConstraint	(IDStragglerTree, AvoidGoldShort);
	
	//medium
	int IDMediumGold			= rmCreateObjectDef("medium gold");
	rmAddObjectDefItem			(IDMediumGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumGold, 65.0);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidTowerFar);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLand);
	if (cNumberNonGaiaPlayers < 3) 
		rmAddObjectDefConstraint	(IDMediumGold, AvoidCornerShort);
	
	int IDMediumGoats			= rmCreateObjectDef("medium Goats");
	rmAddObjectDefItem			(IDMediumGoats, "goat", rmRandInt(1,3), 4.0);
	rmSetObjectDefMinDistance	(IDMediumGoats, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumGoats, 70.0);
	rmAddObjectDefConstraint	(IDMediumGoats, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGoats, AvoidHerdable);
	rmAddObjectDefConstraint	(IDMediumGoats, AvoidTowerFar);
	rmAddObjectDefConstraint	(IDMediumGoats, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGoats, AvoidPlayer);
	rmAddObjectDefConstraint	(IDMediumGoats, AvoidImpassableLand);
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 75.0);
	rmSetObjectDefMaxDistance	(IDFarGold, 100.0);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold, AvoidForestCenter); 
	rmAddObjectDefConstraint	(IDFarGold, AvoidCenter); 
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarGold, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLand);
	
	int IDFarGold2				= rmCreateObjectDef("far gold2");
	rmAddObjectDefItem			(IDFarGold2, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold2, 110.0);
	rmSetObjectDefMaxDistance	(IDFarGold2, 130.0);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidForestCenter); 
	rmAddObjectDefConstraint	(IDFarGold2, AvoidCenter); 
	rmAddObjectDefConstraint	(IDFarGold2, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidImpassableLand);
	if (cNumberNonGaiaPlayers < 3) 
		rmAddObjectDefConstraint	(IDFarGold2, AvoidCornerShort);
		
	
	int IDFarGoats				= rmCreateObjectDef("far Goats");
	rmAddObjectDefItem			(IDFarGoats, "goat", 2, 4.0);
	rmSetObjectDefMinDistance	(IDFarGoats, 80.0);
	rmSetObjectDefMaxDistance	(IDFarGoats, 150.0);
	rmAddObjectDefConstraint	(IDFarGoats, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGoats, AvoidHerdable);
	rmAddObjectDefConstraint	(IDFarGoats, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarGoats, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGoats, AvoidForestCenter);
	
	int IDFarPredator			= rmCreateObjectDef("far predator");
	
	float predatorSpecies = rmRandFloat(0, 1);
	
	if(predatorSpecies < 0.5)   
		rmAddObjectDefItem		(IDFarPredator, "lion", 2, 4.0);
	else
		rmAddObjectDefItem		(IDFarPredator, "hyena", 3, 4.0);
	
	rmSetObjectDefMinDistance	(IDFarPredator, 50.0);
	rmSetObjectDefMaxDistance	(IDFarPredator, 100.0);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidAll);
	
	int IDFarBerries			= rmCreateObjectDef("far berries");
	rmAddObjectDefItem			(IDFarBerries, "berry bush", rmRandInt(4,10), 4.0);
	rmSetObjectDefMinDistance	(IDFarBerries, 70.0);
	rmSetObjectDefMaxDistance	(IDFarBerries, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDFarBerries, AvoidForestCenter); 
	rmAddObjectDefConstraint	(IDFarBerries, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidBerry);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidAll);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidGoldShort);
	
	float BonusChance = rmRandFloat(0, 1);
	float Forward = rmRandFloat(0, 1);
	
	int IDFarHunt				= rmCreateObjectDef("bonus huntable");
	
	if(Forward < 0.5)
	{
		rmSetObjectDefMinDistance	(IDFarHunt, 85);
		rmSetObjectDefMaxDistance	(IDFarHunt, 95);
	}
	else
	{	
		rmSetObjectDefMinDistance	(IDFarHunt, 70);
		rmSetObjectDefMaxDistance	(IDFarHunt, 85);
	}
	
	if(BonusChance < 0.5)
	{  
		rmAddObjectDefItem		(IDFarHunt, "giraffe", rmRandInt(2,3), 2.0);
		rmAddObjectDefItem		(IDFarHunt, "gazelle", rmRandInt(0,4), 3.0);
	}
	else
		rmAddObjectDefItem		(IDFarHunt, "giraffe", rmRandInt(2,5), 2.0);
  
	rmAddObjectDefConstraint	(IDFarHunt, AvoidHuntableFar);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidForestCenter); 
	rmAddObjectDefConstraint	(IDFarHunt, AvoidCenter); 
	rmAddObjectDefConstraint	(IDFarHunt, AvoidSettlementAbit); 
	rmAddObjectDefConstraint	(IDFarHunt, AvoidAll); 
	rmAddObjectDefConstraint	(IDFarHunt, AvoidEdgeFar); 
	
	//other
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "palm", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidForestCenter);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidGoldShort);
	
	int IDRandomTree2			= rmCreateObjectDef("random tree 2");
	rmAddObjectDefItem			(IDRandomTree2, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree2, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree2, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree2, AvoidForestCenter);
	rmAddObjectDefConstraint	(IDRandomTree2, AvoidGoldShort);

	int IDFarMonkeys			= rmCreateObjectDef("far monkeys");
	if(rmRandFloat(0, 1) < 0.5)
		rmAddObjectDefItem		(IDFarMonkeys, "baboon", rmRandInt(4,6), 3.0);
	else
		rmAddObjectDefItem		(IDFarMonkeys, "monkey", rmRandInt(5,8), 3.0);
	
	rmSetObjectDefMinDistance	(IDFarMonkeys, 50.0);
	rmSetObjectDefMaxDistance	(IDFarMonkeys, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDFarMonkeys, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarMonkeys, AvoidHuntable);
	rmAddObjectDefConstraint	(IDFarMonkeys, AvoidAll);
	
	int IDFarBird				= rmCreateObjectDef("far hawks");
	rmAddObjectDefItem			(IDFarBird, "vulture", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarBird, 0.0);
	rmSetObjectDefMaxDistance	(IDFarBird, rmXFractionToMeters(0.5));
	
	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRelic, 70.0);
	rmSetObjectDefMaxDistance	(IDRelic, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRelic, AvoidEdge);
	rmAddObjectDefConstraint	(IDRelic, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint	(IDRelic, AvoidPlayer);
	rmAddObjectDefConstraint	(IDRelic, AvoidForestCenter);
	
	//giant
	
	if(cMapSize == 2) {
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.40));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.60));
		rmAddObjectDefConstraint(giantGoldID, AvoidAll);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdgeFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantGoldID, AvoidForestCenter);
		rmAddObjectDefConstraint(giantGoldID, AvoidPlayer);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 110", "gold", 70.0));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(BonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "gazelle", rmRandInt(5,6), 5.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "giraffe", rmRandInt(5,6), 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntableID, rmCreateTypeDistanceConstraint("super far avoid food sources2", "food", 45.0));
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdgeFar);
		rmAddObjectDefConstraint(giantHuntableID, AvoidPlayer);
		rmAddObjectDefConstraint(giantHuntableID, AvoidForestCenter);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.325));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, AvoidForestCenter);
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHerdableID, AvoidPlayer);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 0.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 100.0));
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidForestCenter);
		rmAddObjectDefConstraint(giantRelixID, AvoidPlayer);
	}
	
	rmSetStatusText("",0.40);
	///DEFINE PLAYER LOCATIONS
	rmPlacePlayersSquare(0.38, 0.01, 0.01);
	
	rmSetStatusText("",0.45);
	///AREA DEFINITION
	int IDCenter		= rmCreateArea("Center");
	rmSetAreaLocation	(IDCenter, 0.5, 0.5);
	rmAddAreaToClass	(IDCenter, classCenter);
	rmSetAreaSize		(IDCenter, 0.001, 0.001);
	rmBuildArea			(IDCenter);
	
	int AreaCornerN			= rmCreateArea("cornerN");
	rmSetAreaSize			(AreaCornerN, 0.04, 0.04);
	rmSetAreaLocation		(AreaCornerN, 1.0, 1.0);
	rmSetAreaWarnFailure	(AreaCornerN, false);
	rmAddAreaToClass		(AreaCornerN, classCorner);
	rmSetAreaCoherence		(AreaCornerN, 1.0);
	
	rmBuildArea(AreaCornerN);
	
	int AreaCornerE			= rmCreateArea("cornerE");
	rmSetAreaSize			(AreaCornerE, 0.04, 0.04);
	rmSetAreaLocation		(AreaCornerE, 1.0, 0.0);
	rmSetAreaWarnFailure	(AreaCornerE, false);
	rmAddAreaToClass		(AreaCornerE, classCorner);
	rmSetAreaCoherence		(AreaCornerE, 1.0);
	
	rmBuildArea(AreaCornerE);
	
	int AreaCornerS			= rmCreateArea("cornerS");
	rmSetAreaSize			(AreaCornerS, 0.04, 0.04);
	rmSetAreaLocation		(AreaCornerS, 0.0, 1.0);
	rmSetAreaWarnFailure	(AreaCornerS, false);
	rmAddAreaToClass		(AreaCornerS, classCorner);
	rmSetAreaCoherence		(AreaCornerS, 1.0);
	
	rmBuildArea(AreaCornerS);
	
	int AreaCornerW			= rmCreateArea("cornerW");
	rmSetAreaSize			(AreaCornerW, 0.04, 0.04);
	rmSetAreaLocation		(AreaCornerW, 0.0, 0.0);
	rmSetAreaWarnFailure	(AreaCornerW, false);
	rmAddAreaToClass		(AreaCornerW, classCorner);
	rmSetAreaCoherence		(AreaCornerW, 1.0);
	
	rmBuildArea(AreaCornerW);
	
	int AreaNonCorner		= rmCreateArea("avoid corner");
	rmSetAreaSize			(AreaNonCorner, 0.80, 0.80);
	rmSetAreaLocation		(AreaNonCorner, 0.5, 0.5);
	rmSetAreaWarnFailure	(AreaNonCorner, false);
	rmAddAreaToClass		(AreaNonCorner, classAvoidCorner);
	rmSetAreaCoherence		(AreaNonCorner, 1.0);
	
	rmBuildArea(AreaNonCorner);
	
	int OasisChance = rmRandInt(0, 100);
	
	if (OasisChance < 30)
	{
		int IDForestMain1		= rmCreateArea("forest main 1");	
		rmSetAreaSize			(IDForestMain1, 0.125, 0.125);
		rmSetAreaLocation		(IDForestMain1, 0.5, 0.5);
		rmSetAreaForestType		(IDForestMain1, "palm forest");
		rmAddAreaToClass		(IDForestMain1, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain1, 0);
		rmSetAreaMaxBlobs		(IDForestMain1, 1);
		rmSetAreaSmoothDistance	(IDForestMain1, 50);
		rmSetAreaCoherence		(IDForestMain1, 0.25);
		rmAddAreaToClass		(IDForestMain1, classForest);
		rmBuildArea				(IDForestMain1);
		
		int IDCore1				= rmCreateArea("core one");
		rmSetAreaSize			(IDCore1, 0.05, 0.05);
		rmSetAreaLocation		(IDCore1, 0.5, 0.5);
		rmSetAreaWaterType		(IDCore1, "Egyptian Nile");
		rmAddAreaToClass		(IDCore1, classForestCenter);
		rmSetAreaBaseHeight		(IDCore1, 0.0);
		rmSetAreaMinBlobs		(IDCore1, 0);
		rmSetAreaMaxBlobs		(IDCore1, 1);
		rmSetAreaSmoothDistance	(IDCore1, 50);
		rmSetAreaCoherence		(IDCore1, 0.25);
		rmBuildArea(IDCore1);
	}
	else if (OasisChance < 45)
	{
		int IDForestMain2		= rmCreateArea("forest 2");
		rmSetAreaSize			(IDForestMain2, 0.07, 0.07);
		rmSetAreaLocation		(IDForestMain2, 0.65, 0.35);
		rmSetAreaForestType		(IDForestMain2, "palm forest");
		rmAddAreaToClass		(IDForestMain2, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain2, 0);
		rmSetAreaMaxBlobs		(IDForestMain2, 1);
		rmSetAreaMinBlobDistance(IDForestMain2, 5);
		rmSetAreaMaxBlobDistance(IDForestMain2, 15);
		rmSetAreaSmoothDistance	(IDForestMain2, 50);
		rmSetAreaCoherence		(IDForestMain2, 0.25);
		rmAddAreaToClass		(IDForestMain2, classForest);
		rmBuildArea				(IDForestMain2);
	
		int IDCore2				= rmCreateArea("core 2");
		rmSetAreaSize			(IDCore2, 0.025, 0.025);
		rmSetAreaLocation		(IDCore2, 0.65, 0.35);
		rmSetAreaWaterType		(IDCore2, "Egyptian Nile");
		rmAddAreaToClass		(IDCore2, classForestCenter);
		rmSetAreaBaseHeight		(IDCore2, 0.0);
		rmSetAreaMinBlobs		(IDCore2, 0);
		rmSetAreaMaxBlobs		(IDCore2, 1);
		rmSetAreaSmoothDistance	(IDCore2, 50);
		rmSetAreaCoherence		(IDCore2, 0.25);
		rmBuildArea				(IDCore2);
	
		int IDForestMain3		= rmCreateArea("forest 3");
		rmSetAreaSize			(IDForestMain3, 0.07, 0.07);
		rmSetAreaLocation		(IDForestMain3, 0.35, 0.65);
		rmSetAreaForestType		(IDForestMain3, "palm forest");
		rmAddAreaToClass		(IDForestMain3, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain3, 0);
		rmSetAreaMaxBlobs		(IDForestMain3, 1);
		rmSetAreaMinBlobDistance(IDForestMain3, 5);
		rmSetAreaMaxBlobDistance(IDForestMain3, 15);
		rmSetAreaSmoothDistance	(IDForestMain3, 50);
		rmSetAreaCoherence		(IDForestMain3, 0.25);
		rmAddAreaToClass		(IDForestMain3, classForest);
		rmBuildArea				(IDForestMain3);
	
		int IDCore3				= rmCreateArea("core 3");
		rmSetAreaSize			(IDCore3, 0.025, 0.025);
		rmSetAreaLocation		(IDCore3, 0.35, 0.65);
		rmSetAreaWaterType		(IDCore3, "Egyptian Nile");
		rmAddAreaToClass		(IDCore3, classForestCenter);
		rmSetAreaBaseHeight		(IDCore3, 0.0);
		rmSetAreaMinBlobs		(IDCore3, 0);
		rmSetAreaMaxBlobs		(IDCore3, 1);
		rmSetAreaSmoothDistance	(IDCore3, 50);
		rmSetAreaCoherence		(IDCore3, 0.25);
		rmBuildArea				(IDCore3);
	}
	else if (OasisChance < 60)
	{
		int IDForestMain4		= rmCreateArea("forest 4");
		rmSetAreaSize			(IDForestMain4, 0.07, 0.07);
		rmSetAreaLocation		(IDForestMain4, 0.65, 0.65);
		rmSetAreaForestType		(IDForestMain4, "palm forest");
		rmAddAreaToClass		(IDForestMain4, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain4, 0);
		rmSetAreaMaxBlobs		(IDForestMain4, 1);
		rmSetAreaMinBlobDistance(IDForestMain4, 5);
		rmSetAreaMaxBlobDistance(IDForestMain4, 15);
		rmSetAreaSmoothDistance	(IDForestMain4, 50);
		rmSetAreaCoherence		(IDForestMain4, 0.25);
		rmAddAreaToClass		(IDForestMain4, classForest);
		rmBuildArea				(IDForestMain4);
	
		int IDCore4				= rmCreateArea("core 4");
		rmSetAreaSize			(IDCore4, 0.025, 0.025);
		rmSetAreaLocation		(IDCore4, 0.65, 0.65);
		rmSetAreaWaterType		(IDCore4, "Egyptian Nile");
		rmAddAreaToClass		(IDCore4, classForestCenter);
		rmSetAreaBaseHeight		(IDCore4, 0.0);
		rmSetAreaMinBlobs		(IDCore4, 0);
		rmSetAreaMaxBlobs		(IDCore4, 1);
		rmSetAreaSmoothDistance	(IDCore4, 50);
		rmSetAreaCoherence		(IDCore4, 0.25);
		rmBuildArea				(IDCore4);
	
		int IDForestMain5		= rmCreateArea("forest 5");
		rmSetAreaSize			(IDForestMain5, 0.07, 0.07);
		rmSetAreaLocation		(IDForestMain5, 0.35, 0.35);
		rmSetAreaForestType		(IDForestMain5, "palm forest");
		rmAddAreaToClass		(IDForestMain5, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain5, 0);
		rmSetAreaMaxBlobs		(IDForestMain5, 1);
		rmSetAreaMinBlobDistance(IDForestMain5, 5);
		rmSetAreaMaxBlobDistance(IDForestMain5, 15);
		rmSetAreaSmoothDistance	(IDForestMain5, 50);
		rmSetAreaCoherence		(IDForestMain5, 0.25);
		rmAddAreaToClass		(IDForestMain5, classForest);
		rmBuildArea				(IDForestMain5);
	
		int IDCore5				= rmCreateArea("core 5");
		rmSetAreaSize			(IDCore5, 0.025, 0.025);
		rmSetAreaLocation		(IDCore5, 0.35, 0.35);
		rmSetAreaWaterType		(IDCore5, "Egyptian Nile");
		rmAddAreaToClass		(IDCore5, classForestCenter);
		rmSetAreaBaseHeight		(IDCore5, 0.0);
		rmSetAreaMinBlobs		(IDCore5, 0);
		rmSetAreaMaxBlobs		(IDCore5, 1);
		rmSetAreaSmoothDistance	(IDCore5, 50);
		rmSetAreaCoherence		(IDCore5, 0.25);
		rmBuildArea				(IDCore5);
	}
	else
	{
		int IDForestMain6		= rmCreateArea("forest 6");
		rmSetAreaSize			(IDForestMain6, 0.035, 0.035);
		rmSetAreaLocation		(IDForestMain6, 0.5, 0.68);
		rmSetAreaForestType		(IDForestMain6, "palm forest");
		rmAddAreaToClass		(IDForestMain6, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain6, 0);
		rmSetAreaMaxBlobs		(IDForestMain6, 0);
		rmSetAreaSmoothDistance	(IDForestMain6, 50);
		rmSetAreaCoherence		(IDForestMain6, 0.25);
		rmAddAreaToClass		(IDForestMain6, classForest);
		rmBuildArea				(IDForestMain6);
	
		if(cNumberPlayers > 4)
		{
			int IDCore6				= rmCreateArea("core 6");
			rmSetAreaSize			(IDCore6, 0.01, 0.01);
			rmSetAreaLocation		(IDCore6, 0.5, 0.68);
			rmSetAreaWaterType		(IDCore6, "Egyptian Nile");
			rmAddAreaToClass		(IDCore6, classForestCenter);
			rmSetAreaBaseHeight		(IDCore6, 0.0);
			rmSetAreaMinBlobs		(IDCore6, 0);
			rmSetAreaMaxBlobs		(IDCore6, 1);
			rmSetAreaSmoothDistance	(IDCore6, 50);
			rmSetAreaCoherence		(IDCore6, 0.25);
			rmBuildArea				(IDCore6);
		}
		
		int IDForestMain7		= rmCreateArea("forest 7");
		rmSetAreaSize			(IDForestMain7, 0.035, 0.035);
		rmSetAreaLocation		(IDForestMain7, 0.68, 0.5);
		rmSetAreaForestType		(IDForestMain7, "palm forest");
		rmAddAreaToClass		(IDForestMain7, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain7, 0);
		rmSetAreaMaxBlobs		(IDForestMain7, 0);
		rmSetAreaSmoothDistance	(IDForestMain7, 50);
		rmSetAreaCoherence		(IDForestMain7, 0.25);
		rmAddAreaToClass		(IDForestMain7, classForest);
		rmBuildArea				(IDForestMain7);
	
		if(cNumberPlayers > 4)
		{
			int IDCore7				= rmCreateArea("core 7");
			rmSetAreaSize			(IDCore7, 0.01, 0.01);
			rmSetAreaLocation		(IDCore7, 0.68, 0.5);
			rmSetAreaWaterType		(IDCore7, "Egyptian Nile");
			rmAddAreaToClass		(IDCore7, classForestCenter);
			rmSetAreaBaseHeight		(IDCore7, 0.0);
			rmSetAreaMinBlobs		(IDCore7, 0);
			rmSetAreaMaxBlobs		(IDCore7, 0);
			rmSetAreaSmoothDistance	(IDCore7, 50);
			rmSetAreaCoherence		(IDCore7, 0.25);
			rmBuildArea				(IDCore7);
		}
		
		int IDForestMain8		= rmCreateArea("forest 8");
		rmSetAreaSize			(IDForestMain8, 0.035, 0.035);
		rmSetAreaLocation		(IDForestMain8, 0.5, 0.32);
		rmSetAreaForestType		(IDForestMain8, "palm forest");
		rmAddAreaToClass		(IDForestMain8, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain8, 0);
		rmSetAreaMaxBlobs		(IDForestMain8, 0);
		rmSetAreaSmoothDistance	(IDForestMain8, 50);
		rmSetAreaCoherence		(IDForestMain8, 0.25);
		rmAddAreaToClass		(IDForestMain8, classForest);
		rmBuildArea				(IDForestMain8);
	
		if(cNumberPlayers > 4)
		{
			int IDCore8				= rmCreateArea("core 8");
			rmSetAreaSize			(IDCore8, 0.01, 0.01);
			rmSetAreaLocation		(IDCore8, 0.5, 0.32);
			rmSetAreaWaterType		(IDCore8, "Egyptian Nile");
			rmAddAreaToClass		(IDCore8, classForestCenter);
			rmSetAreaBaseHeight		(IDCore8, 0.0);
			rmSetAreaMinBlobs		(IDCore8, 1);
			rmSetAreaMaxBlobs		(IDCore8, 1);
			rmSetAreaSmoothDistance	(IDCore8, 50);
			rmSetAreaCoherence		(IDCore8, 0.25);
			rmBuildArea				(IDCore8);
		}
		
		int IDForestMain9		= rmCreateArea("forest 9");
		rmSetAreaSize			(IDForestMain9, 0.035, 0.035);
		rmSetAreaLocation		(IDForestMain9, 0.32, 0.5);
		rmSetAreaForestType		(IDForestMain9, "palm forest");
		rmAddAreaToClass		(IDForestMain9, classForestCenter);
		rmSetAreaMinBlobs		(IDForestMain9, 0);
		rmSetAreaMaxBlobs		(IDForestMain9, 0);
		rmSetAreaSmoothDistance	(IDForestMain9, 50);
		rmSetAreaCoherence		(IDForestMain9, 0.25);
		rmAddAreaToClass		(IDForestMain9, classForest);
		rmBuildArea				(IDForestMain9);
	
		if(cNumberPlayers > 4)
		{
			int IDCore9				= rmCreateArea("core 9");
			rmSetAreaSize			(IDCore9, 0.01, 0.01);
			rmSetAreaLocation		(IDCore9, 0.32, 0.5);
			rmSetAreaWaterType		(IDCore9, "Egyptian Nile");
			rmAddAreaToClass		(IDCore9, classForestCenter);
			rmSetAreaBaseHeight		(IDCore9, 0.0);
			rmSetAreaMinBlobs		(IDCore9, 0);
			rmSetAreaMaxBlobs		(IDCore9, 1);
			rmSetAreaSmoothDistance	(IDCore9, 50);
			rmSetAreaCoherence		(IDCore9, 0.25);
			rmBuildArea				(IDCore9);
		}
	}
	
	float playerFraction = rmAreaTilesToFraction(3000*mapSizeMultiplier);
	for(i = 1; < cNumberPlayers)
	{
		int IDPlayerArea		= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, IDPlayerArea);
		rmSetAreaSize			(IDPlayerArea, 0.9*playerFraction, 1.1*playerFraction);
		rmSetAreaMinBlobs		(IDPlayerArea, 1);
		rmSetAreaMaxBlobs		(IDPlayerArea, 5);
		rmSetAreaMinBlobDistance(IDPlayerArea, 16.0);
		rmSetAreaMaxBlobDistance(IDPlayerArea, 40.0);
		rmSetAreaCoherence		(IDPlayerArea, 0.0);
		rmAddAreaConstraint		(IDPlayerArea, AvoidPlayerArea);
		rmAddAreaConstraint		(IDPlayerArea, AvoidForestCenter);
		rmAddAreaToClass		(IDPlayerArea, classPlayerArea);
		rmSetAreaLocPlayer		(IDPlayerArea, i);
		rmSetAreaTerrainType	(IDPlayerArea, "SandDirt50"); 
		rmAddAreaTerrainLayer	(IDPlayerArea, "SandA", 1, 2); 
		rmAddAreaTerrainLayer	(IDPlayerArea, "SandB", 0, 1); 
	}
	rmBuildAllAreas();
	
	for(i = 1; < cNumberPlayers*5*mapSizeMultiplier)
	{
		int IDAreaPatch			= rmCreateArea("patch A"+i);
		rmSetAreaSize			(IDAreaPatch, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDAreaPatch, "SandD");
		rmSetAreaMinBlobs		(IDAreaPatch, 1);
		rmSetAreaMaxBlobs		(IDAreaPatch, 5);
		rmSetAreaMinBlobDistance(IDAreaPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDAreaPatch, 40.0);
		rmSetAreaCoherence		(IDAreaPatch, 0.0);
		rmAddAreaConstraint		(IDAreaPatch, AvoidBuildings);
		rmAddAreaConstraint		(IDAreaPatch, AvoidForestCenter);
		rmBuildArea				(IDAreaPatch);
	}
	
	
	int numTries = 10*cNumberNonGaiaPlayers;
	int failCount = 0;
	for(i = 0; < numTries*mapSizeMultiplier)
	{
		int IDElev				= rmCreateArea("elev"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(100*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));		rmSetAreaWarnFailure	(IDElev, false);
		rmAddAreaConstraint		(IDElev, AvoidBuildings);
		rmAddAreaConstraint		(IDElev, AvoidForestCenter);
		rmAddAreaConstraint		(IDElev, AvoidElev);
		
		if(rmRandFloat(0.0, 1.0) < 0.5)
			rmSetAreaTerrainType(IDElev, "SandD");
		
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(3.0, 6.0));
		rmSetAreaHeightBlend	(IDElev, 2);
		rmAddAreaToClass		(IDElev, classElev);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 5);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 40.0);
		rmSetAreaCoherence		(IDElev, 0.0);
	
		if(rmBuildArea(IDElev) == false)
		{
			failCount++;
			if(failCount == 3)
				break;
		}
		else
			failCount = 0;
	}
	
	failCount = 0;
	
	for(i = 0; < 20*cNumberNonGaiaPlayers*mapSizeMultiplier)
	{
		int IDWrinkle			= rmCreateArea("wrinkle"+i);
		rmSetAreaSize			(IDWrinkle, rmAreaTilesToFraction(15*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDWrinkle, false);
		rmSetAreaBaseHeight		(IDWrinkle, rmRandFloat(2.0, 3.0));
		rmSetAreaMinBlobs		(IDWrinkle, 1);
		rmSetAreaMaxBlobs		(IDWrinkle, 3);
		
		if(rmRandFloat(0.0, 1.0) < 0.5)
			rmSetAreaTerrainType(IDWrinkle, "SandD");
		
		rmSetAreaMinBlobDistance(IDWrinkle, 16.0);
		rmSetAreaMaxBlobDistance(IDWrinkle, 20.0);
		rmSetAreaCoherence		(IDWrinkle, 0.0);
		rmAddAreaToClass		(IDWrinkle, classElev);
		rmAddAreaConstraint		(IDWrinkle, AvoidElev);
		rmAddAreaConstraint		(IDWrinkle, AvoidForestCenter);
	
		if(rmBuildArea(IDWrinkle) == false)
		{
			failCount++;
			if(failCount == 3)
				break;
		}
		else
			failCount=0;
	}
	
	rmSetStatusText("",0.60);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int AreaSettle = rmAddFairLoc("Settlement", false, true,  60, 80, 40, 25);
	
	if (cNumberNonGaiaPlayers < 3)
	{
		if(rmRandFloat(0, 1) < 0.40)
			AreaSettle = rmAddFairLoc("Settlement", true, false, 85, 100, 75, 50);
		else
			AreaSettle = rmAddFairLoc("Settlement", false, true,  70, 85, 60, 25);
	}
	else
	{
		if(rmRandFloat(0, 1) < 0.75)
			AreaSettle = rmAddFairLoc("Settlement", true, false, 85, 100, 75, 45);
		else
			AreaSettle = rmAddFairLoc("Settlement", false, true,  75, 90, 70, 25);
	}
	
	//giant
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", true, false,  100, 170, 75, 50);
		
		AreaSettle = rmAddFairLoc("Settlement", true, false,  150, 220, 75, 50);
	}
	
	rmAddFairLocConstraint	(AreaSettle, AvoidForestCenterFar);
	rmAddFairLocConstraint	(AreaSettle, AvoidCenter);
	
	if(rmPlaceFairLocs())
	{
		AreaSettle			= rmCreateObjectDef("far settlement2");
		rmAddObjectDefItem	(AreaSettle, "Settlement", 1, 0.0);
		for(i = 1; < cNumberPlayers)
		{
			for(j = 0; < rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(AreaSettle, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	rmSetStatusText("",0.70);
	///OBJECT PLACEMENT
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingTower, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingZebra, false);
	rmPlaceObjectDefPerPlayer(IDStartingGoat, true);
	rmPlaceObjectDefPerPlayer(IDStartingWildcrops, false);
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(2, 4));
	
	rmPlaceObjectDefPerPlayer(IDMediumGold, false);
	rmPlaceObjectDefPerPlayer(IDFarHunt, false);
	rmPlaceObjectDefPerPlayer(IDMediumGoats, false, 2);
	
	rmPlaceObjectDefPerPlayer(IDFarGold, false, 2);
	rmPlaceObjectDefPerPlayer(IDFarGold2, false, 1);
	rmPlaceObjectDefPerPlayer(IDFarGoats, false, 3);
	rmPlaceObjectDefPerPlayer(IDFarBerries, false);
	rmPlaceObjectDefPerPlayer(IDFarPredator, false);
	
	rmPlaceObjectDefPerPlayer(IDFarMonkeys, false);
	rmPlaceObjectDefPerPlayer(IDRelic, false);
	rmPlaceObjectDefPerPlayer(IDFarBird, false, 2);

	if(cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false);
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.80);
	///FORESTS
	failCount = 0;
	for(i = 0; < 10*cNumberNonGaiaPlayers*mapSizeMultiplier)
	{
		int IDForest			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(35*mapSizeMultiplier), rmAreaTilesToFraction(95*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "palm forest");
		rmAddAreaConstraint		(IDForest, AvoidStartingSettle);
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidForestCenterFarthest);
		rmAddAreaConstraint		(IDForest, AvoidGoldShort);
		rmAddAreaToClass		(IDForest, classForest);
		rmAddAreaToClass		(IDForest, classNormalForest);
		rmSetAreaMinBlobs		(IDForest, 0);
		rmSetAreaMaxBlobs		(IDForest, 4);
		rmSetAreaMinBlobDistance(IDForest, 8.0);
		rmSetAreaMaxBlobDistance(IDForest, 25.0);
		rmSetAreaCoherence		(IDForest, 0.0);
	
		if(rmBuildArea(IDForest) == false)
		{
			failCount++;
			if(failCount == 3)
			break;
		}
		else
			failCount=0;
	}
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 7*cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmPlaceObjectDefAtLoc(IDRandomTree2, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmSetStatusText("",0.90);
	///BEAUTIFICATION
	int IDLonely				= rmCreateObjectDef("lonely deer");
	
	if(rmRandFloat(0, 1) < 0.33)
		rmAddObjectDefItem		(IDLonely, "monkey", rmRandInt(1,2), 2.0);
	else if(rmRandFloat(0, 1) < 0.5)
		rmAddObjectDefItem		(IDLonely, "zebra", 1, 0.0);
	else
		rmAddObjectDefItem		(IDLonely, "gazelle", rmRandInt(1,3), 2.0);
	
	rmSetObjectDefMinDistance	(IDLonely, 90.0);
	rmSetObjectDefMaxDistance	(IDLonely, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLonely, AvoidAll);
	rmAddObjectDefConstraint	(IDLonely, AvoidPlayer);
	rmAddObjectDefConstraint	(IDLonely, AvoidPlayerArea);
	rmAddObjectDefConstraint	(IDLonely, AvoidHuntable);
	rmAddObjectDefConstraint	(IDLonely, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDLonely, 0, 0.5, 0.5, cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDRock					= rmCreateObjectDef("rock");
	rmAddObjectDefItem			(IDRock, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDBush					= rmCreateObjectDef("big bush patch");
	rmAddObjectDefItem			(IDBush, "bush", 4, 3.0);
	rmSetObjectDefMinDistance	(IDBush, 0.0);
	rmSetObjectDefMaxDistance	(IDBush, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDBush, AvoidAll);
	rmAddObjectDefConstraint	(IDBush, AvoidForestCenter);
	rmPlaceObjectDefAtLoc		(IDBush, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDSmallBush				= rmCreateObjectDef("small bush patch");
	rmAddObjectDefItem			(IDSmallBush, "bush", 3, 2.0);
	rmAddObjectDefItem			(IDSmallBush, "rock sandstone sprite", 1, 2.0);
	rmSetObjectDefMinDistance	(IDSmallBush, 0.0);
	rmSetObjectDefMaxDistance	(IDSmallBush, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSmallBush, AvoidAll);
	rmAddObjectDefConstraint	(IDSmallBush, AvoidForestCenter);
	rmPlaceObjectDefAtLoc		(IDSmallBush, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDGrass					= rmCreateObjectDef("grass");
	rmAddObjectDefItem			(IDGrass, "grass", 1, 0.0);
	rmSetObjectDefMinDistance	(IDGrass, 0.0);
	rmSetObjectDefMaxDistance	(IDGrass, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDGrass, AvoidAll);
	rmAddObjectDefConstraint	(IDGrass, AvoidForestCenter);
	rmPlaceObjectDefAtLoc		(IDGrass, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDSandDrift				= rmCreateObjectDef("blowing sand");
	rmAddObjectDefItem			(IDSandDrift, "sand drift patch", 1, 0.0);
	rmSetObjectDefMinDistance	(IDSandDrift, 0.0);
	rmSetObjectDefMaxDistance	(IDSandDrift, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSandDrift, AvoidAll);
	rmAddObjectDefConstraint	(IDSandDrift, AvoidForestCenter);
	rmAddObjectDefConstraint	(IDSandDrift, AvoidEdge);
	rmAddObjectDefConstraint	(IDSandDrift, rmCreateTypeDistanceConstraint("drift vs drift", "sand drift dune", 25.0));
	rmAddObjectDefConstraint	(IDSandDrift, AvoidBuildings);
	rmPlaceObjectDefAtLoc		(IDSandDrift, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);
   
	rmSetStatusText("",1.0);

}  





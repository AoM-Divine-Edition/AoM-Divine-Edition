/*Alfheim - Freshed up
**Made by Hagrit (Original concept by Ensemble Studios)
*/
void main(void)
{
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
	
	rmTerrainInitialize("grassA");
	rmSetLightingSet("alfheim");
	rmSetGaiaCiv(cCivZeus);
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer			= rmDefineClass("player");
	int classStartingSettle	= rmDefineClass("starting settlement");
	int classCliff			= rmDefineClass("cliff");
	int classBonusHuntable	= rmDefineClass("bonus huntable");
	int classForest			= rmDefineClass("forest");
	int classCenter			= rmDefineClass("center");
	int classCorner			= rmDefineClass("corner");
	int classAvoidCorner	= rmDefineClass("avoid corner");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdge		= rmCreateBoxConstraint("B0", rmXTilesToFraction(6), rmZTilesToFraction(6), 1.0-rmXTilesToFraction(6), 1.0-rmZTilesToFraction(6));
	int AvoidEdgeFar	= rmCreateBoxConstraint("B1", rmXTilesToFraction(16), rmZTilesToFraction(16), 1.0-rmXTilesToFraction(16), 1.0-rmZTilesToFraction(16));
	
	int AvoidAll			= rmCreateTypeDistanceConstraint ("T0", "all", 6.0);
	int AvoidTower			= rmCreateTypeDistanceConstraint ("T1", "tower", 25.0);
	int AvoidBuildings		= rmCreateTypeDistanceConstraint ("T2", "Building", 20.0);
	int AvoidGold			= rmCreateTypeDistanceConstraint ("T3", "gold", 24.0);
	int AvoidSettlementAbit	= rmCreateTypeDistanceConstraint ("T4", "AbstractSettlement", 22.0);
	int AvoidHerdable		= rmCreateTypeDistanceConstraint ("T5", "herdable", 20.0);
	int AvoidPredator		= rmCreateTypeDistanceConstraint ("T6", "animalPredator", 40.0);
	int AvoidHuntable		= rmCreateTypeDistanceConstraint ("T7", "huntable", 20.0);
	int AvoidGoldFar		= rmCreateTypeDistanceConstraint ("T8", "gold", 35.0);
	int AvoidFood			= rmCreateTypeDistanceConstraint ("T9", "food", 12.0);
	int AvoidRuins			= rmCreateTypeDistanceConstraint ("T10", "relic", 60.0);
	int AvoidTowerShort		= rmCreateTypeDistanceConstraint ("T11", "tower", 8.0);

	int AvoidCliff				= rmCreateClassDistanceConstraint ("C0", classCliff, 32.0);
	int AvoidCliffShort			= rmCreateClassDistanceConstraint ("C1", classCliff, 10.0);
	int AvoidStartingSettle		= rmCreateClassDistanceConstraint ("C2", classStartingSettle, 50.0);
	int AvoidStartingSettleShort= rmCreateClassDistanceConstraint ("C3", classStartingSettle, 20.0);
	int AvoidPlayer				= rmCreateClassDistanceConstraint ("C4", classPlayer, 22.0);
	int AvoidBonusHunt			= rmCreateClassDistanceConstraint ("C5", classBonusHuntable, 40.0);
	int AvoidForest				= rmCreateClassDistanceConstraint ("C6", classForest, 22.0);
	int AvoidCenterShort		= rmCreateClassDistanceConstraint ("C7", classCenter, 10.0);
	int AvoidCorner				= rmCreateClassDistanceConstraint ("C8", classCorner, 20.0);
	int AvoidCornerShort		= rmCreateClassDistanceConstraint ("C9", classCorner, 1.0);
	int InCorner				= rmCreateClassDistanceConstraint ("C10", classAvoidCorner, 1.0);
	
	int AvoidImpassableLand	= rmCreateTerrainDistanceConstraint("TR1", "land", false, 8.0);
	
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
	rmSetObjectDefMinDistance 	(IDStartingTower, 22.0);
	rmSetObjectDefMaxDistance 	(IDStartingTower, 27.0);
	
	int GoldDistance = rmRandInt(21,23);
	
	int IDStartingGold			= rmCreateObjectDef("starting goldmine");
	rmAddObjectDefItem			(IDStartingGold, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance 	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance 	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidAll);
	
	int IDStartingHerd			= rmCreateObjectDef("close herdable");
	rmAddObjectDefItem			(IDStartingHerd, "cow", rmRandInt(2,4), 2.0);
	rmSetObjectDefMinDistance	(IDStartingHerd, 20.0);
	rmSetObjectDefMaxDistance	(IDStartingHerd, 25.0);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidAll);
	
	int BerryNum = rmRandInt(6, 10);
	int IDStartingChicken		= rmCreateObjectDef("close Chickens");
	rmAddObjectDefItem			(IDStartingChicken, "chicken", BerryNum, 5.0);
	rmSetObjectDefMinDistance	(IDStartingChicken, 20.0);
	rmSetObjectDefMaxDistance	(IDStartingChicken, 25.0);
	rmAddObjectDefConstraint	(IDStartingChicken, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingChicken, AvoidFood);
	rmAddObjectDefConstraint	(IDStartingChicken, AvoidTowerShort);
	
	int IDStartingBerry			= rmCreateObjectDef("close berries");
	rmAddObjectDefItem			(IDStartingBerry, "berry bush", BerryNum, 4.0);
	rmSetObjectDefMinDistance	(IDStartingBerry, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingBerry, 30.0);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidFood);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidTowerShort);
	
	int IDStartingHunt			= rmCreateObjectDef("close elk");
	if(rmRandFloat(0,1)<0.75)
		rmAddObjectDefItem		(IDStartingHunt, "elk", rmRandInt(3,5), 4.0);
	else
		rmAddObjectDefItem		(IDStartingHunt, "elk", 2, 2.0);
	rmSetObjectDefMinDistance	(IDStartingHunt, 22.0);
	
	float bigHunt = rmRandFloat(0.0, 1.0);
	if (bigHunt < 0.2) {
		rmSetObjectDefMaxDistance	(IDStartingHunt, 45.0);
	} else 
		rmSetObjectDefMaxDistance	(IDStartingHunt, 27.0);
	
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidEdge);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "pine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	
	//medium
	int IDMediumGold			= rmCreateObjectDef("medium gold");
	rmAddObjectDefItem			(IDMediumGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 40.0);
	rmSetObjectDefMaxDistance	(IDMediumGold, 60.0);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdgeFar);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCornerShort);
	
	int IDMediumHerd			= rmCreateObjectDef("medium Cow");
	rmAddObjectDefItem			(IDMediumHerd, "cow", rmRandFloat(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDMediumHerd, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumHerd, 100.0);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidStartingSettle); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidEdge); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidAll); 
	
	int IDMediumDeer			= rmCreateObjectDef("medium deer");
	rmAddObjectDefItem			(IDMediumDeer, "deer", rmRandInt(3,8), 4.0);
	rmSetObjectDefMinDistance	(IDMediumDeer, 60.0);
	rmSetObjectDefMaxDistance	(IDMediumDeer, 80.0);
	rmAddObjectDefConstraint	(IDMediumDeer, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDMediumDeer, AvoidHuntable);
	rmAddObjectDefConstraint	(IDMediumDeer, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDMediumDeer, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumDeer, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumDeer, AvoidCenterShort);
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 75.0);
	rmSetObjectDefMaxDistance	(IDFarGold, 110.0);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdge);
	if (cNumberNonGaiaPlayers < 3) {
		rmAddObjectDefConstraint	(IDFarGold, AvoidCornerShort);
	}
	
	int IDFarHerd				= rmCreateObjectDef("far Cow");
	rmAddObjectDefItem			(IDFarHerd, "cow", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDFarHerd, 80.0);
	rmSetObjectDefMaxDistance	(IDFarHerd, 150.0);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidHerdable);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidAll);
	
	float predatorSpecies=rmRandFloat(0, 1);
	int IDFarPred				= rmCreateObjectDef("far predator");
	if(predatorSpecies<0.5)   
		rmAddObjectDefItem		(IDFarPred, "wolf", rmRandInt(2,3), 4.0);
	else
		rmAddObjectDefItem		(IDFarPred, "bear", 2, 4.0);
	rmSetObjectDefMinDistance	(IDFarPred, 60.0);
	rmSetObjectDefMaxDistance	(IDFarPred, 110.0);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPred, AvoidStartingSettle); 
	rmAddObjectDefConstraint	(IDFarPred, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDFarPred, AvoidFood);
	rmAddObjectDefConstraint	(IDFarPred, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarPred, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarPred, AvoidAll);
	
	float bonusChance=rmRandFloat(0, 1);
	int IDBonusHunt				= rmCreateObjectDef("bonus huntable");
	if(bonusChance < 0.33)   
		rmAddObjectDefItem		(IDBonusHunt, "elk", rmRandInt(3,8), 4.0);
	else if(bonusChance < 0.66)
		rmAddObjectDefItem		(IDBonusHunt, "caribou", rmRandInt(3,6), 4.0);
	else
		rmAddObjectDefItem		(IDBonusHunt, "aurochs", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance	(IDBonusHunt, 70.0);
	rmSetObjectDefMaxDistance	(IDBonusHunt, 100.0);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidHuntable);
	rmAddObjectDefToClass		(IDBonusHunt, classBonusHuntable);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidStartingSettle); 
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidCliffShort);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidEdge);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidAll);
   
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "pine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);

	int IDBirds					= rmCreateObjectDef("far hawks");
	rmAddObjectDefItem			(IDBirds, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance	(IDBirds, 0.0);
	rmSetObjectDefMaxDistance	(IDBirds, rmXFractionToMeters(0.5));
	
	//giant
	if(cMapSize == 2){
		
		int giantAvoidGold=rmCreateTypeDistanceConstraint("giant gold vs. gold", "gold", 80.0);
		int giantAvoidFood=rmCreateTypeDistanceConstraint("giant avoid food", "food", 30.0);
		int giantAvoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 45.0);
		int giantAvoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 50.0);
		
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantGoldID, giantAvoidFood);
		rmAddObjectDefConstraint(giantGoldID, giantAvoidGold);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdge);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLand);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "elk", rmRandInt(5,6), 4.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.34));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, AvoidStartingSettle);
		
		int giantHuntable3ID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntable3ID, "caribou", rmRandInt(5,6), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.38));
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.42));
		rmAddObjectDefConstraint(giantHuntable3ID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntable3ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidImpassableLand);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		rmAddObjectDefItem(giantHuntable2ID, "aurochs", rmRandInt(3,4), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.41));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHuntable2ID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidStartingSettle);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "cow", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.34));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.41));
		rmAddObjectDefConstraint(giantHerdableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHerdableID, giantAvoidHuntable);
		rmAddObjectDefConstraint(giantHerdableID, giantAvoidFood);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
	}
	
	rmSetStatusText("",0.35);
	///DEFINE PLAYER LOCATIONS
	rmSetTeamSpacingModifier(0.75);
	rmPlacePlayersCircular(0.33, 0.37, rmDegreesToRadians(0.0));
	
	rmSetStatusText("",0.40);
	///AREA DEFINITION
	float playerFraction=rmAreaTilesToFraction(4000*mapSizeMultiplier);
	for(i=1; <cNumberPlayers)
	{
		int AreaPlayer			= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, AreaPlayer);
		rmSetAreaSize			(AreaPlayer, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass		(AreaPlayer, classPlayer);
		rmSetAreaWarnFailure	(AreaPlayer, false);
		rmSetAreaMinBlobs		(AreaPlayer, 1);
		rmSetAreaMaxBlobs		(AreaPlayer, 5);
		rmSetAreaMinBlobDistance(AreaPlayer, 16.0);
		rmSetAreaMaxBlobDistance(AreaPlayer, 40.0);
		rmSetAreaCoherence		(AreaPlayer, 0.0);
		rmAddAreaConstraint		(AreaPlayer, AvoidPlayer);
		rmSetAreaLocPlayer		(AreaPlayer, i);
		rmSetAreaTerrainType	(AreaPlayer, "GrassDirt50");
		rmAddAreaTerrainLayer	(AreaPlayer, "GrassDirt25", 8, 20);
		rmAddAreaTerrainLayer	(AreaPlayer, "GrassA", 0, 8);
	}
	
	rmBuildAllAreas();

	for(i=1; <cNumberPlayers)
	{
		int AreaPlayerInner		= rmCreateArea("Player inner"+i, rmAreaID("player"+i));
		rmSetAreaSize			(AreaPlayerInner, rmAreaTilesToFraction(200*mapSizeMultiplier), rmAreaTilesToFraction(300*mapSizeMultiplier));
		rmSetAreaLocPlayer		(AreaPlayerInner, i);
		rmSetAreaTerrainType	(AreaPlayerInner, "GrassDirt25");
		rmSetAreaMinBlobs		(AreaPlayerInner, 1);
		rmSetAreaMaxBlobs		(AreaPlayerInner, 5);
		rmSetAreaMinBlobDistance(AreaPlayerInner, 16.0);
		rmSetAreaMaxBlobDistance(AreaPlayerInner, 40.0);
		rmSetAreaCoherence		(AreaPlayerInner, 0.0);
	
		rmBuildArea(AreaPlayerInner); 
	} 
	
	int AreaCenter			= rmCreateArea("center");
	rmSetAreaSize			(AreaCenter, 0.001, 0.001);
	rmSetAreaLocation		(AreaCenter, 0.5, 0.5);
	rmSetAreaWarnFailure	(AreaCenter, false);
	rmAddAreaToClass		(AreaCenter, classCenter);
	rmSetAreaCoherence		(AreaCenter, 1.0);
	
	rmBuildArea(AreaCenter);
	
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
	rmSetAreaSize			(AreaNonCorner, 0.7, 0.7);
	rmSetAreaLocation		(AreaNonCorner, 0.5, 0.5);
	rmSetAreaWarnFailure	(AreaNonCorner, false);
	rmAddAreaToClass		(AreaNonCorner, classAvoidCorner);
	rmAddAreaConstraint		(AreaNonCorner, AvoidCornerShort);
	rmSetAreaCoherence		(AreaNonCorner, 1.0);
	
	rmBuildArea(AreaNonCorner);
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier)
	{
		int AreaGrass			= rmCreateArea("Grass patch "+i);
		rmSetAreaSize			(AreaGrass, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaGrass, "GrassB");
		rmSetAreaMinBlobs		(AreaGrass, 1);
		rmSetAreaMaxBlobs		(AreaGrass, 5);
		rmSetAreaWarnFailure	(AreaGrass, false);
		rmSetAreaMinBlobDistance(AreaGrass, 16.0);
		rmSetAreaMaxBlobDistance(AreaGrass, 40.0);
		rmSetAreaCoherence		(AreaGrass, 0.0);
	
		rmBuildArea(AreaGrass);
	}
	
	for(i=1; <cNumberPlayers*12*mapSizeMultiplier)
	{
		int AreaGrassDirt		= rmCreateArea("Grass patch 2 "+i);
		rmSetAreaSize			(AreaGrassDirt, rmAreaTilesToFraction(10), rmAreaTilesToFraction(20*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaGrassDirt, "GrassDirt25");
		rmSetAreaMinBlobs		(AreaGrassDirt, 1);
		rmSetAreaMaxBlobs		(AreaGrassDirt, 5);
		rmSetAreaWarnFailure	(AreaGrassDirt, false);
		rmSetAreaMinBlobDistance(AreaGrassDirt, 16.0);
		rmSetAreaMaxBlobDistance(AreaGrassDirt, 40.0);
		rmSetAreaCoherence		(AreaGrassDirt, 0.0);
	
		rmBuildArea(AreaGrassDirt);
	}
	
	int numTries=30*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int failCount=0;
	for(i=0; <numTries)
	{
		int IDElev				= rmCreateArea("wrinkle"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation		(IDElev, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure	(IDElev, false);
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(2.0, 4.0));
		rmAddAreaConstraint		(IDElev, AvoidBuildings);
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
	
	
	
	rmSetStatusText("",0.50);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);

	int AreaSettle	= rmAddFairLoc("Settlement", false, true,  60, 80, 40, 25);
	rmAddFairLocConstraint	(AreaSettle, AvoidStartingSettle);
	
	if(rmRandFloat(0,1)<0.75)
		AreaSettle = rmAddFairLoc("Settlement", true, false, 75, 100, 75, 65);
	else
		AreaSettle = rmAddFairLoc("Settlement", false, true,  65, 85, 60, 25);
	
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", true, false,  100, 170, 95, 50);
		
		AreaSettle = rmAddFairLoc("Settlement", true, false,  100, 170, 95, 50);
	}
	
	rmAddFairLocConstraint	(AreaSettle, AvoidCenterShort);
	
	if(rmPlaceFairLocs())
	{
		AreaSettle=rmCreateObjectDef("far settlement2");
		rmAddObjectDefItem(AreaSettle, "Settlement", 1, 0.0);
		for(i=1; <cNumberPlayers)
		{
			for(j=0; <rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(AreaSettle, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	rmSetStatusText("",0.60);
	///CLIFFS

	numTries=3*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <numTries)
	{
		int IDCliff				= rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure	(IDCliff, false);
		rmSetAreaSize			(IDCliff, rmAreaTilesToFraction(150), rmAreaTilesToFraction(350));
		rmSetAreaCliffType		(IDCliff, "Greek");
		rmAddAreaConstraint		(IDCliff, AvoidCliff);
		rmAddAreaToClass		(IDCliff, classCliff);
		rmAddAreaConstraint		(IDCliff, AvoidBuildings);
		rmAddAreaConstraint		(IDCliff, AvoidStartingSettle);
		rmSetAreaMinBlobs		(IDCliff, 1);
		rmSetAreaMaxBlobs		(IDCliff, 10);
		rmSetAreaCliffEdge		(IDCliff, 1, 1.0, 0.0, 1.0, 0);
		rmSetAreaCliffPainting	(IDCliff, true, true, true, 1.5, false);
		rmSetAreaTerrainType	(IDCliff, "cliffGreekA");
		rmSetAreaCliffHeight	(IDCliff, 7, 1.0, 1.0);
		rmSetAreaMinBlobDistance(IDCliff, 16.0);
		rmSetAreaMaxBlobDistance(IDCliff, 35.0);
		rmSetAreaCoherence		(IDCliff, 0.5);
		rmSetAreaSmoothDistance	(IDCliff, 10);
		rmSetAreaHeightBlend	(IDCliff, 2);
		
		if(rmBuildArea(IDCliff)==false)
		{
			failCount++;
			if(failCount==3)
			break;
		}
		else
			failCount=0;
	}

	numTries=10*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <numTries)
	{
		IDElev					= rmCreateArea("elev"+i);
		rmSetAreaLocation		(IDElev, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure	(IDElev, false);
		rmAddAreaConstraint		(IDElev, AvoidBuildings);
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 5);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 40.0);
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
	rmSetStatusText("",0.70);
	///PLACE OBJECTS
	rmPlaceObjectDefPerPlayer(IDStartingTower, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingBerry, false);
	rmPlaceObjectDefPerPlayer(IDStartingChicken, false);
	
	if(bigHunt < 0.25) {
		rmPlaceObjectDefPerPlayer(IDStartingHunt, false, rmRandInt(2,4));
	} else 
		rmPlaceObjectDefPerPlayer(IDStartingHunt, false);
	
	
	rmPlaceObjectDefPerPlayer(IDStartingHerd, true);
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(2.0, 5.0));
	
	int IDRuin=0;
	int IDColumn=0;
	int IDRelic=0;
	
	int stayInRuins		= rmCreateEdgeDistanceConstraint("E0", IDRuin, 4.0);
	
	for(i=0; <2*cNumberNonGaiaPlayers*mapSizeMultiplier)
	{
		IDRuin					= rmCreateArea("ruins "+i);
		rmSetAreaSize			(IDRuin, rmAreaTilesToFraction(120), rmAreaTilesToFraction(180));
		rmSetAreaTerrainType	(IDRuin, "GreekRoadA");
		rmAddAreaTerrainLayer	(IDRuin, "GrassDirt25", 0, 1);
		rmSetAreaMinBlobs		(IDRuin, 1);
		rmSetAreaMaxBlobs		(IDRuin, 2);
		rmSetAreaWarnFailure	(IDRuin, false); 
		rmSetAreaMinBlobDistance(IDRuin, 16.0);
		rmSetAreaMaxBlobDistance(IDRuin, 40.0);
		rmSetAreaCoherence		(IDRuin, 0.8);
		rmSetAreaSmoothDistance	(IDRuin, 10);
		rmAddAreaConstraint		(IDRuin, AvoidAll);
		rmAddAreaConstraint		(IDRuin, AvoidRuins);
		rmAddAreaConstraint		(IDRuin, stayInRuins);
		rmAddAreaConstraint		(IDRuin, AvoidCliffShort);
		rmAddAreaConstraint		(IDRuin, AvoidStartingSettle);
		rmAddAreaConstraint		(IDRuin, AvoidSettlementAbit);
		rmAddAreaConstraint		(IDRuin, AvoidEdge);
	
		rmBuildArea(IDRuin);
		
		IDColumn					= rmCreateObjectDef("columns "+i);
		rmAddObjectDefItem			(IDColumn, "ruins", rmRandInt(0,1), 0.0);
		rmAddObjectDefItem			(IDColumn, "columns broken", rmRandInt(2,5), 4.0);
		rmAddObjectDefItem			(IDColumn, "columns", rmRandFloat(0,2), 4.0);
		rmAddObjectDefItem			(IDColumn, "rock limestone small", rmRandInt(1,3), 4.0);
		rmAddObjectDefItem			(IDColumn, "rock limestone sprite", rmRandInt(6,12), 6.0);
		rmAddObjectDefItem			(IDColumn, "grass", rmRandFloat(3,6), 4.0);
		rmSetObjectDefMinDistance	(IDColumn, 0.0);
		rmSetObjectDefMaxDistance	(IDColumn, 0.0);
		rmPlaceObjectDefInArea		(IDColumn, 0, rmAreaID("ruins "+i), 1);
	
		IDRelic						= rmCreateObjectDef("relics "+i);
		rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
		rmSetObjectDefMinDistance	(IDRelic, 0.0);
		rmSetObjectDefMaxDistance	(IDRelic, 0.0);
		rmAddObjectDefConstraint	(IDRelic, AvoidAll);
		rmAddObjectDefConstraint	(IDRelic, stayInRuins);
		rmPlaceObjectDefInArea		(IDRelic, 0, rmAreaID("ruins "+i), 1);
	
		if(rmGetNumberUnitsPlaced(IDRelic) < 1)
		{
			rmEchoInfo("---------------------failed to place IDRelic in ruins "+i+". So just dropping backup Relic.");
			rmSetAreaSize(IDRuin, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
			int IDRelicBackup			= rmCreateObjectDef("backup relic "+i);
			rmAddObjectDefItem			(IDRelicBackup, "relic", 1, 0.0);
			rmSetObjectDefMinDistance	(IDRelicBackup, 0.0);
			rmSetObjectDefMaxDistance	(IDRelicBackup, rmXFractionToMeters(0.5));
			rmAddObjectDefConstraint	(IDRelicBackup, AvoidRuins);
			rmAddObjectDefConstraint	(IDRelicBackup, AvoidStartingSettle);
			rmAddObjectDefConstraint	(IDRelicBackup, AvoidCliffShort);
			rmPlaceObjectDefAtLoc		(IDRelicBackup, 0, 0.5, 0.5, 1);
		}
	
	}
	
	
	rmPlaceObjectDefPerPlayer(IDMediumGold, false, rmRandInt(1.0,2.0));
	rmPlaceObjectDefPerPlayer(IDMediumHerd, false);
	rmPlaceObjectDefPerPlayer(IDMediumDeer, false);
	
	rmPlaceObjectDefPerPlayer(IDFarGold, false, rmRandInt(3.0,4.0));
	rmPlaceObjectDefPerPlayer(IDBonusHunt, false, rmRandInt(1, 2));
	rmPlaceObjectDefPerPlayer(IDFarHerd, false, rmRandInt(1, 2));
	rmPlaceObjectDefPerPlayer(IDFarPred, false);
	rmPlaceObjectDefPerPlayer(IDBirds, false, 2); 
	
	//giant
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 2);
		rmPlaceObjectDefPerPlayer(giantHuntable3ID, false, 2);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, 2);
	}
	
	rmSetStatusText("",0.80);
	///FORESTS
	failCount=0;
	numTries=11*cNumberNonGaiaPlayers*mapSizeMultiplier;
	for(i=0; <numTries)
	{
		int IDForest			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "pine forest");
		rmAddAreaConstraint		(IDForest, AvoidStartingSettleShort);
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidCliffShort);
		rmAddAreaToClass		(IDForest, classForest);
		
		rmSetAreaMinBlobs		(IDForest, 3*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDForest, 8*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDForest, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDForest, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDForest, 0.0);
	
		if(rmRandFloat(0.0, 1.0)<0.2)
			rmSetAreaBaseHeight(IDForest, rmRandFloat(3.0, 4.0));

	
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
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 25*cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmSetStatusText("",0.90);
	///BEAUTIFICATION
	int IDRock					= rmCreateObjectDef("rock");
	rmAddObjectDefItem			(IDRock, "rock limestone sprite", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDLog					= rmCreateObjectDef("log");
	rmAddObjectDefItem			(IDLog, "rotting log", 1, 0.0);
	rmSetObjectDefMinDistance	(IDLog, 0.0);
	rmSetObjectDefMaxDistance	(IDLog, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLog, AvoidAll);
	rmAddObjectDefConstraint	(IDLog, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDLog, AvoidStartingSettleShort);
	rmPlaceObjectDefAtLoc		(IDLog, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",1.0);
}
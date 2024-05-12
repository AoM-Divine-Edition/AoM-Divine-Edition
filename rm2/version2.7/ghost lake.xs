/*Ghost Lake 
**Made by Hagrit (concept by Ensemble Studios)
**
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
	
	rmTerrainInitialize("snowB");
	rmSetLightingSet("ghost lake");
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer			= rmDefineClass("player");
	int classCorner			= rmDefineClass("corner");
	int classStartingSettle	= rmDefineClass("starting settlement");
	int classCliff			= rmDefineClass("cliff");
	int classBonusHuntable	= rmDefineClass("bonus huntable");
	int classForest			= rmDefineClass("forest");
	int classCenter			= rmDefineClass("center");
	int classAvoidCorner	= rmDefineClass("avoid corner");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdgeShort	= rmCreateBoxConstraint("B0", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
	int AvoidEdge		= rmCreateBoxConstraint("B1", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
	int AvoidEdgeFar	= rmCreateBoxConstraint("B2", rmXTilesToFraction(15), rmZTilesToFraction(15), 1.0-rmXTilesToFraction(15), 1.0-rmZTilesToFraction(15));

	int AvoidAll			= rmCreateTypeDistanceConstraint ("T-1", "all", 6.0);
	int AvoidAllLong		= rmCreateTypeDistanceConstraint ("T0", "all", 8.0);
	int AvoidTower			= rmCreateTypeDistanceConstraint ("T1", "tower", 25.0);
	int AvoidBuildings		= rmCreateTypeDistanceConstraint ("T2", "Building", 20.0);
	int AvoidGold			= rmCreateTypeDistanceConstraint ("T3", "gold", 25.0);
	int AvoidSettlementAbit	= rmCreateTypeDistanceConstraint ("T4", "AbstractSettlement", 21.0);
	int AvoidHerdable		= rmCreateTypeDistanceConstraint ("T5", "herdable", 25.0);
	int AvoidPredator		= rmCreateTypeDistanceConstraint ("T6", "animalPredator", 40.0);
	int AvoidHuntable		= rmCreateTypeDistanceConstraint ("T7", "huntable", 20.0);
	int AvoidGoldFar		= rmCreateTypeDistanceConstraint ("T8", "gold", 30.0);
	int AvoidFood			= rmCreateTypeDistanceConstraint ("T9", "food", 12.0);
	int AvoidRelic			= rmCreateTypeDistanceConstraint ("T10", "relic", 50.0*mapSizeMultiplier);
	int AvoidSettlementFar	= rmCreateTypeDistanceConstraint ("T11", "AbstractSettlement", 25.0);
	int AvoidGoldVeryFar	= rmCreateTypeDistanceConstraint ("T12", "gold", 50.0);
	int AvoidSettlementTiny	= rmCreateTypeDistanceConstraint ("T13", "AbstractSettlement", 15.0);
	
	int AvoidCenterShort		= rmCreateClassDistanceConstraint ("C0", classCenter, 10.0);
	int AvoidCenterMed			= rmCreateClassDistanceConstraint ("C1", classCenter, 20.0);
	int AvoidCenterFar			= rmCreateClassDistanceConstraint ("C2", classCenter, 36.0);
	int AvoidStartingSettle		= rmCreateClassDistanceConstraint ("C3", classStartingSettle, 50.0);
	int AvoidStartingSettleShort= rmCreateClassDistanceConstraint ("C4", classStartingSettle, 20.0);
	int AvoidCliff				= rmCreateClassDistanceConstraint ("C5", classCliff, 45.0);
	int AvoidCliffShort			= rmCreateClassDistanceConstraint ("C6", classCliff, 10.0);
	int AvoidBonusHunt			= rmCreateClassDistanceConstraint ("C7", classBonusHuntable, 40.0);
	int AvoidPlayer				= rmCreateClassDistanceConstraint ("C8", classPlayer, 40.0);
	int AvoidForest				= rmCreateClassDistanceConstraint ("C9", classForest, 25.0);
	int AvoidCorner				= rmCreateClassDistanceConstraint ("C10", classCorner, 20.0);
	int AvoidCornerShort		= rmCreateClassDistanceConstraint ("C11", classCorner, 1.0);
	int InCorner				= rmCreateClassDistanceConstraint ("C12", classAvoidCorner, 1.0);

	int AvoidImpassableLand	= rmCreateTerrainDistanceConstraint("TR1", "land", false, 6.0);
	
	
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
	
	int GoldDistance = rmRandInt(20,24);
	
	int IDStartingGold			= rmCreateObjectDef("starting goldmine");
	rmAddObjectDefItem			(IDStartingGold, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance 	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance 	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint  	(IDStartingGold, AvoidEdge);
	rmAddObjectDefConstraint  	(IDStartingGold, AvoidGold);
	
	int IDStartingHerd			= rmCreateObjectDef("close herdable");
	rmAddObjectDefItem			(IDStartingHerd, "goat", rmRandInt(2,5), 2.0);
	rmSetObjectDefMinDistance	(IDStartingHerd, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingHerd, 30.0);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidEdgeShort);
	
	int IDStartingBerry			= rmCreateObjectDef("close berries");
	rmAddObjectDefItem			(IDStartingBerry, "berry bush", rmRandInt(4,8), 4.0);
	rmSetObjectDefMinDistance	(IDStartingBerry, 20.0);
	rmSetObjectDefMaxDistance	(IDStartingBerry, 25.0);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidFood);
	
	int IDStartingHunt			= rmCreateObjectDef("close Boar");
	if(rmRandFloat(0,1)<0.6)
		rmAddObjectDefItem		(IDStartingHunt, "boar", rmRandInt(1,3), 4.0);
	else
		rmAddObjectDefItem		(IDStartingHunt, "aurochs", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDStartingHunt, 24.0);
	rmSetObjectDefMaxDistance	(IDStartingHunt, 28.0);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	
	//medium
	int IDMediumHerd			= rmCreateObjectDef("medium goat");
	rmAddObjectDefItem			(IDMediumHerd, "goat", rmRandFloat(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDMediumHerd, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumHerd, 70.0);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidStartingSettle); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidEdge); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidAll); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidCenterShort); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidHerdable); 
	
	int IDMediumGold			= rmCreateObjectDef("med gold");
	rmAddObjectDefItem			(IDMediumGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 45.0);
	rmSetObjectDefMaxDistance	(IDMediumGold, 70.0);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCenterShort);
	rmAddObjectDefConstraint	(IDMediumGold, InCorner);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidTower);
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 70.0);
	rmSetObjectDefMaxDistance	(IDFarGold, 90.0);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdgeFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidCenterShort);
	if (cNumberNonGaiaPlayers < 4) {
		rmAddObjectDefConstraint	(IDFarGold, AvoidCorner);
	}
	
	rmAddObjectDefConstraint	(IDFarGold, AvoidTower);
	
	float goldNum = (rmRandFloat(0,1));
	
	int IDFarGold2				= rmCreateObjectDef("far gold2");
	rmAddObjectDefItem			(IDFarGold2, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold2, 60.0);
	rmSetObjectDefMaxDistance	(IDFarGold2, 100.0);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidSettlementFar);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidCenterShort);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidCorner);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidTower);
	
	int IDFarGold3				= rmCreateObjectDef("far gold3");
	rmAddObjectDefItem			(IDFarGold3, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold3, 80.0);
	rmSetObjectDefMaxDistance	(IDFarGold3, 100.0);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidSettlementFar);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidCenterShort);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidCorner);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidTower);
	
	int IDFarGoat				= rmCreateObjectDef("far goats");
	rmAddObjectDefItem			(IDFarGoat, "goat", 2, 2.0);
	rmSetObjectDefMinDistance	(IDFarGoat, 80.0);
	rmSetObjectDefMaxDistance	(IDFarGoat, 140.0);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidHerdable);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidImpassableLand);
	
	int IDFarPred				= rmCreateObjectDef("far predator");
	rmAddObjectDefItem			(IDFarPred, "polar bear", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDFarPred, 60.0);
	rmSetObjectDefMaxDistance	(IDFarPred, 110.0);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPred, AvoidStartingSettle); 
	rmAddObjectDefConstraint	(IDFarPred, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarPred, AvoidEdge);
	
	int IDFarBerries			= rmCreateObjectDef("far berries");
	rmAddObjectDefItem			(IDFarBerries, "berry bush", rmRandInt(4,10), 4.0);
	rmSetObjectDefMinDistance	(IDFarBerries, 65.0);
	rmSetObjectDefMaxDistance	(IDFarBerries, rmXFractionToMeters(0.45));
	rmAddObjectDefConstraint	(IDFarBerries, AvoidCenterMed);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidAll);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidEdge);
	
	int IDBonusHunt				= rmCreateObjectDef("bonus huntable");
   rmAddObjectDefItem			(IDBonusHunt, "caribou", rmRandInt(4,10), 3.0);
   rmSetObjectDefMinDistance	(IDBonusHunt, 60.0);
   rmSetObjectDefMaxDistance	(IDBonusHunt, 90.0);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidBonusHunt);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidHuntable);
   rmAddObjectDefToClass		(IDBonusHunt, classBonusHuntable);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidStartingSettle);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidImpassableLand);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidCenterShort);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidEdge);
   rmAddObjectDefConstraint		(IDBonusHunt, AvoidAll);
	
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "pine snow", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidCenterShort);

	int IDBirds					= rmCreateObjectDef("far hawks");
	rmAddObjectDefItem			(IDBirds, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance	(IDBirds, 0.0);
	rmSetObjectDefMaxDistance	(IDBirds, rmXFractionToMeters(0.5));
	
	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRelic, 60.0);
	rmSetObjectDefMaxDistance	(IDRelic, 150.0);
	rmAddObjectDefConstraint	(IDRelic, AvoidEdge);
	rmAddObjectDefConstraint	(IDRelic, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint	(IDRelic, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableLand);
	
	//giant
	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantGoldID, AvoidAll);
		rmAddObjectDefConstraint(giantGoldID, AvoidGoldVeryFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdge);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantGoldID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantGoldID, AvoidCenterShort);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(5,7), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantHuntableID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdgeFar);
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, AvoidCenterShort);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.25));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHerdableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidRelic);
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidEdgeFar);
		rmAddObjectDefConstraint(giantRelixID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantRelixID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantRelixID, AvoidImpassableLand);
	}
	
	rmSetStatusText("",0.35);
	///DEFINE PLAYER LOCATIONS
	if(cNumberNonGaiaPlayers <9)
		rmSetTeamSpacingModifier(0.70);
	else
		rmSetTeamSpacingModifier(0.90);
	rmPlacePlayersCircular(0.40, 0.40, rmDegreesToRadians(0.0));
   
	rmSetStatusText("",0.40);
	///AREA DEFINITION
	for(i=1; <cNumberPlayers)
	{
		int AreaPlayer		=rmCreateArea("Player core"+i);
		rmSetAreaSize		(AreaPlayer, rmAreaTilesToFraction(350*mapSizeMultiplier), rmAreaTilesToFraction(400*mapSizeMultiplier));
		rmAddAreaToClass	(AreaPlayer, classPlayer);
		rmSetAreaCoherence	(AreaPlayer, 1.0);
		rmSetAreaLocPlayer	(AreaPlayer, i);
		rmSetAreaTerrainType(AreaPlayer, "SnowGrass25");
	
		rmBuildArea(AreaPlayer);
	}
	
	int IDCenter			= rmCreateArea("center");
	rmSetAreaSize			(IDCenter, 0.13, 0.13);
	rmSetAreaLocation		(IDCenter, 0.5, 0.5);
	rmSetAreaTerrainType	(IDCenter, "IceC");
	rmAddAreaTerrainLayer	(IDCenter, "IceB", 6, 10);
	rmAddAreaTerrainLayer	(IDCenter, "IceA", 0, 6);
	rmAddAreaToClass		(IDCenter, rmClassID("center"));
	rmSetAreaBaseHeight		(IDCenter, -1.0); 
	rmSetAreaMinBlobs		(IDCenter, 1);
	rmSetAreaMaxBlobs		(IDCenter, 6);
	rmSetAreaMinBlobDistance(IDCenter, 10*cNumberNonGaiaPlayers);
	rmSetAreaMaxBlobDistance(IDCenter, 13*cNumberNonGaiaPlayers);
	rmSetAreaSmoothDistance	(IDCenter, 50);
	rmSetAreaCoherence		(IDCenter, 0.25);
	rmSetAreaHeightBlend	(IDCenter, 2); 
	rmAddAreaConstraint		(IDCenter, AvoidPlayer);
	rmBuildArea(IDCenter);
	
	int failCount=0;
	for(i=1; <10*mapSizeMultiplier)
	{
		int IDIcePatch			= rmCreateArea("more ice terrain"+i, IDCenter);
		rmSetAreaSize			(IDIcePatch, 0.005, 0.007);
		rmSetAreaTerrainType	(IDIcePatch, "IceA");
		rmAddAreaTerrainLayer	(IDIcePatch, "IceB", 0, 3);
		rmSetAreaCoherence		(IDIcePatch, 0.0);
		if(rmBuildArea(IDIcePatch)==false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3)
			break;
		}
		else
			failCount=0;
	} 
	
	float playerFraction=rmAreaTilesToFraction(2000*mapSizeMultiplier);
	for(i=1; <cNumberPlayers)
	{
		int IDPlayerArea			= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, IDPlayerArea);
		rmSetAreaSize			(IDPlayerArea, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass		(IDPlayerArea, classPlayer);
		rmSetAreaMinBlobs		(IDPlayerArea, 2);
		rmSetAreaMaxBlobs		(IDPlayerArea, 3);
		rmSetAreaMinBlobDistance(IDPlayerArea, 10.0);
		rmSetAreaMaxBlobDistance(IDPlayerArea, 20.0);
		rmSetAreaCoherence		(IDPlayerArea, 0.4);
		rmAddAreaConstraint		(IDPlayerArea, AvoidEdgeShort);
		rmAddAreaConstraint		(IDPlayerArea, AvoidCenterShort);
		rmSetAreaLocPlayer		(IDPlayerArea, i);
		rmSetAreaTerrainType	(IDPlayerArea, "SnowGrass50");
		rmAddAreaTerrainLayer	(IDPlayerArea, "SnowGrass25", 0, 8);
	}

	rmBuildAllAreas();
	
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier)
	{
		int IDPatch				= rmCreateArea("patch"+i);
		rmSetAreaWarnFailure	(IDPatch, false);
		rmSetAreaSize			(IDPatch, rmAreaTilesToFraction(50), rmAreaTilesToFraction(200));
		rmSetAreaTerrainType	(IDPatch, "SnowGrass50");
		rmAddAreaTerrainLayer	(IDPatch, "SnowGrass25", 2, 5);
		rmAddAreaTerrainLayer	(IDPatch, "SnowB", 0, 2); 
		rmSetAreaMinBlobs		(IDPatch, 1);
		rmSetAreaMaxBlobs		(IDPatch, 5);
		rmSetAreaMinBlobDistance(IDPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDPatch, 40.0);
		rmSetAreaCoherence		(IDPatch, 0.4);
		rmAddAreaConstraint		(IDPatch, AvoidCenterShort);
		rmAddAreaConstraint		(IDPatch, AvoidImpassableLand);
		
		if (rmBuildArea(IDPatch)==false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3)
				break;
		}
		else
			failCount=0;
	}
	
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier)
	{
		int IDPatch2			= rmCreateArea("patch 2 "+i);
		rmSetAreaWarnFailure	(IDPatch2, false);
		rmSetAreaSize			(IDPatch2, rmAreaTilesToFraction(10), rmAreaTilesToFraction(30));
		if(rmRandFloat(0,1) < 0.5)
			rmSetAreaTerrainType(IDPatch2, "SnowA");
		else
			rmSetAreaTerrainType(IDPatch2, "SnowSand25");
		rmSetAreaMinBlobs		(IDPatch2, 1);
		rmSetAreaMaxBlobs		(IDPatch2, 5);
		rmSetAreaMinBlobDistance(IDPatch2, 16.0);
		rmSetAreaMaxBlobDistance(IDPatch2, 40.0);
		rmSetAreaCoherence		(IDPatch2, 0.4);
		rmAddAreaConstraint		(IDPatch2, AvoidCenterShort);
		rmAddAreaConstraint		(IDPatch2, AvoidPlayer);
		rmAddAreaConstraint		(IDPatch2, AvoidImpassableLand);
		if (rmBuildArea(IDPatch2)==false)
		{
			failCount++;
			if(failCount==3)
			break;
		}
		else
			failCount=0;
	}
	
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
	
	rmSetStatusText("",0.50);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int AreaSettle	= rmAddFairLoc("Settlement", false, true,  60, 80, 40, 25);
	
	if (cNumberNonGaiaPlayers < 4) {
	if(rmRandFloat(0,1)<0.5)
		AreaSettle = rmAddFairLoc("Settlement", true, false, 85, 100, 85, 45);
	else
		AreaSettle = rmAddFairLoc("Settlement", false, true,  65, 85, 65, 25);
	} else 
		AreaSettle = rmAddFairLoc("Settlement", true, false, 90, 100, 85, 45);	
	
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", false, true,  90, 150, 80, 30);
		
		AreaSettle = rmAddFairLoc("Settlement", true, false,  100, 170, 95, 50);
	}
	
	rmAddFairLocConstraint	(AreaSettle, AvoidCenterMed);
	
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
	///Cliffs
	int cliffNumber = 0;
	if(cNumberNonGaiaPlayers < 4)
		cliffNumber = 4;
	else if(cNumberNonGaiaPlayers < 9)
		cliffNumber = 6;
	else
		cliffNumber = 9;         
	
	for(i=0; <cliffNumber*mapSizeMultiplier)
	{
		int IDCliff				= rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure	(IDCliff, false);
		if(cNumberNonGaiaPlayers < 4)
			rmSetAreaSize		(IDCliff, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
		else
			rmSetAreaSize		(IDCliff, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
		rmSetAreaCliffType		(IDCliff, "Norse");
		rmAddAreaConstraint		(IDCliff, AvoidCliff);
		rmAddAreaConstraint		(IDCliff, AvoidCenterMed);
		rmAddAreaConstraint		(IDCliff, AvoidPlayer);
		rmAddAreaConstraint		(IDCliff, AvoidSettlementAbit);
		rmAddAreaToClass		(IDCliff, classCliff);
		rmSetAreaMinBlobs		(IDCliff, 2);
		rmSetAreaMaxBlobs		(IDCliff, 4);
	
		rmSetAreaCliffPainting	(IDCliff, false, true, true, 1.5, true);
		if(rmRandFloat(0,1) < 0.5)
			rmSetAreaCliffEdge	(IDCliff, 1, 0.85, 0.2, 1.0, 2);
		else
			rmSetAreaCliffEdge	(IDCliff, 2, 0.40, 0.2, 1.0, 0);
		rmSetAreaCliffHeight	(IDCliff, rmRandInt(5,7), 1.0, 1.0);
		rmSetAreaMinBlobDistance(IDCliff, 5.0);
		rmSetAreaMaxBlobDistance(IDCliff, 10.0);
		rmSetAreaCoherence		(IDCliff, 0.1);
		rmSetAreaSmoothDistance	(IDCliff, 5);
		rmSetAreaHeightBlend	(IDCliff, 2); 
		rmBuildArea				(IDCliff);
	}
	
	int numTries=40*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <numTries)
	{
		int IDElev				= rmCreateArea("elev"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation		(IDElev, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure	(IDElev, false);
		rmAddAreaConstraint		(IDElev, AvoidSettlementAbit);
		rmAddAreaConstraint		(IDElev, AvoidCenterShort);
		rmAddAreaConstraint		(IDElev, AvoidCliffShort);
		if(rmRandFloat(0.0, 1.0)<0.5)
			rmSetAreaTerrainType(IDElev, "SnowGrass25");
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
			if(failCount==5)
				break;
		}
		else
			failCount=0;
	}
	
	numTries=10*cNumberNonGaiaPlayers;
	failCount=0;
	for(i=0; <numTries*mapSizeMultiplier)
	{
		IDElev					= rmCreateArea("wrinkle"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaLocation		(IDElev, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure	(IDElev, false);
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(3.0, 4.0));
		rmSetAreaHeightBlend	(IDElev, 1);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 3);
		rmSetAreaMinBlobDistance(IDElev, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDElev, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDElev, 0.0);
		rmAddAreaConstraint		(IDElev, AvoidCenterShort);
		rmAddAreaConstraint		(IDElev, AvoidCliffShort);
		rmAddAreaConstraint		(IDElev, AvoidAll);
		if(rmBuildArea(IDElev)==false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==8)
				break;
		}
		else
			failCount=0;
	}
	
	rmSetStatusText("",0.70);
	///PLACE OBJECTS
	rmPlaceObjectDefPerPlayer(IDStartingTower, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingGold, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDStartingBerry, false);
	rmPlaceObjectDefPerPlayer(IDStartingHunt, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDStartingHerd, true);
	rmPlaceObjectDefPerPlayer(IDStragglerTree, true, rmRandInt(5,8));
	
	rmPlaceObjectDefPerPlayer(IDMediumHerd, false, rmRandInt(1, 2));
	if (rmRandFloat(0,1) < 0.25) {
		rmPlaceObjectDefPerPlayer(IDMediumGold, false, 1);
	}
	
	rmPlaceObjectDefPerPlayer(IDFarGold, false, 1);
	rmPlaceObjectDefPerPlayer(IDFarGold2, false, 1);	
	if (goldNum < 0.3) {
		rmPlaceObjectDefPerPlayer(IDFarGold3, false, 1);
	}
		
	
	rmPlaceObjectDefPerPlayer(IDBirds, false, 2);
	rmPlaceObjectDefPerPlayer(IDRelic, false);
	rmPlaceObjectDefPerPlayer(IDFarGoat, false, rmRandInt(3,4));
	rmPlaceObjectDefPerPlayer(IDBonusHunt, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDFarBerries, false, 1);
	rmPlaceObjectDefPerPlayer(IDFarPred, false, 1);
	
	if (cMapSize == 2){
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
	}
	
	rmSetStatusText("",0.80);
	///FORESTS
	failCount=0;
	numTries=7*cNumberNonGaiaPlayers*mapSizeMultiplier;
	for(i=0; <numTries)
	{
		int IDForest			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(90*mapSizeMultiplier), rmAreaTilesToFraction(160*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "snow pine forest");
		rmAddAreaConstraint		(IDForest, AvoidStartingSettleShort);
		rmAddAreaConstraint		(IDForest, AvoidAllLong);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidCliffShort);
		rmAddAreaConstraint		(IDForest, AvoidCenterMed);
		rmAddAreaConstraint		(IDForest, AvoidSettlementTiny);
		rmAddAreaToClass		(IDForest, classForest);
		
		rmSetAreaMinBlobs		(IDForest, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDForest, 3*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDForest, 5.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDForest, 10.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDForest, 0.2);
		rmSetAreaSmoothDistance	(IDForest, 2);
	
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
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmSetStatusText("",0.90);
	///BEAUTIFICATION
	int IDRock					= rmCreateObjectDef("rock group");
	rmAddObjectDefItem			(IDRock, "rock granite sprite", 3, 2.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRock, AvoidCenterShort);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier); 
	
	int IDRune					= rmCreateObjectDef("runestone");
	rmAddObjectDefItem			(IDRune, "runestone", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRune, 0.0);
	rmSetObjectDefMaxDistance	(IDRune, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRune, AvoidAll);
	rmAddObjectDefConstraint	(IDRune, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRune, AvoidCenterShort);
	rmPlaceObjectDefAtLoc		(IDRune, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	///TRIGGERS
	rmSetStatusText("",1.00);
}
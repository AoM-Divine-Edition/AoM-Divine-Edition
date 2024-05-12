/*Marsh
**Made by Hagrit (concept by Ensemble studios)
** 
*/
void main(void)
{
	///INITIALIZE MAP
	rmSetStatusText("",0.01);
	
	int mapSizeMultiplier = 1;
	
	int playerTiles = 9000;
	if(cMapSize == 1)
	{
		playerTiles = 11700;
		rmEchoInfo("Large map");
	}
	if (cMapSize == 2)
	{
		playerTiles = 23400;
		mapSizeMultiplier = 2;
	}
	int size=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	rmSetSeaLevel(1.0);
	rmSetSeaType("Aztec Sea");
	rmSetLightingSet("Fimbulwinter");

	// Init map.
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer			= rmDefineClass("player");
	int classCorner			= rmDefineClass("corner");
	int classForest			= rmDefineClass("forest");
	int classCenter			= rmDefineClass("center");
	int classStartingSettle	= rmDefineClass("starting settlement");
	int classPlayerCore		= rmDefineClass("player core");
	int classBonusIsland	= rmDefineClass("bonus island");
	int classIsland			= rmDefineClass("island");
	int classAvoidCorner	= rmDefineClass("non corner");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdgeShort		= rmCreateBoxConstraint("B0", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int AvoidEdge			= rmCreateBoxConstraint("B1", rmXTilesToFraction(6), rmZTilesToFraction(6), 1.0-rmXTilesToFraction(6), 1.0-rmZTilesToFraction(6));
	int AvoidEdgeFar		= rmCreateBoxConstraint("B2", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30));
	int AvoidEdgeFarther	= rmCreateBoxConstraint("B3", rmXTilesToFraction(32), rmZTilesToFraction(32), 1.0-rmXTilesToFraction(32), 1.0-rmZTilesToFraction(32));
	
	int AvoidAll				= rmCreateTypeDistanceConstraint ("T0", "all", 7.0);
	int AvoidTower				= rmCreateTypeDistanceConstraint ("T1", "tower", 25.0);
	int AvoidBuildings			= rmCreateTypeDistanceConstraint ("T2", "Building", 20.0);
	int AvoidGold				= rmCreateTypeDistanceConstraint ("T3", "gold", 25.0);
	int AvoidSettlementAbit		= rmCreateTypeDistanceConstraint ("T4", "AbstractSettlement", 20.0);
	int AvoidHerdable			= rmCreateTypeDistanceConstraint ("T5", "herdable", 25.0);
	int AvoidPredator			= rmCreateTypeDistanceConstraint ("T6", "animalPredator", 40.0);
	int AvoidHuntable			= rmCreateTypeDistanceConstraint ("T7", "huntable", 20.0);
	int AvoidGoldFar			= rmCreateTypeDistanceConstraint ("T8", "gold", 35.0);
	int AvoidFood				= rmCreateTypeDistanceConstraint ("T9", "food", 12.0);
	int AvoidRelic				= rmCreateTypeDistanceConstraint ("T10", "relic", 50.0);
	int AvoidSettlementSlightly	= rmCreateTypeDistanceConstraint ("T13", "AbstractSettlement", 15.0);
	
	int AvoidStartingSettle		= rmCreateClassDistanceConstraint ("C0", classStartingSettle, 50.0);
	int AvoidStartingSettleTiny	= rmCreateClassDistanceConstraint ("C1", classStartingSettle, 20.0);
	int AvoidPlayer				= rmCreateClassDistanceConstraint ("C2", classPlayer, 10.0);
	int AvoidPlayerCore			= rmCreateClassDistanceConstraint ("C3", classPlayerCore, 60.0);
	int AvoidBonusIsland		= rmCreateClassDistanceConstraint ("C4", classBonusIsland, 15.0);
	int AvoidBonusIslandFar		= rmCreateClassDistanceConstraint ("C5", classBonusIsland, 25.0);
	int AvoidIsland				= rmCreateClassDistanceConstraint ("C6", classIsland, 20.0);
	int AvoidCenter				= rmCreateClassDistanceConstraint ("C7", classCenter, 60.0);
	int AvoidCenterShort		= rmCreateClassDistanceConstraint ("C8", classCenter, 5.0);
	int AvoidForest				= rmCreateClassDistanceConstraint ("C9", classForest, 24.0);
	int AvoidForestFar			= rmCreateClassDistanceConstraint ("C10", classForest, 30.0);
	int AvoidCornerShort		= rmCreateClassDistanceConstraint ("C11", classCorner, 1.0);
	int AvoidCorner				= rmCreateClassDistanceConstraint ("C12", classCorner, 15.0);
	int inCorner				= rmCreateClassDistanceConstraint ("C13", classAvoidCorner, 1.0);
	int AvoidPlayerFar			= rmCreateClassDistanceConstraint ("C14", classPlayer, 15.0);
	
	int AvoidImpassableLandShort	= rmCreateTerrainDistanceConstraint ("TR0", "land", false, 6.0);
	int AvoidImpassableLand			= rmCreateTerrainDistanceConstraint ("TR1", "land", false, 8.0);
	int AvoidImpassableLandFar		= rmCreateTerrainDistanceConstraint ("TR2", "land", false, 18.0);
	int nearShore					= rmCreateTerrainMaxDistanceConstraint ("TR3", "water", true, 6.0);
	
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
	rmAddObjectDefConstraint  	(IDStartingTower, AvoidEdgeShort);
	rmSetObjectDefMinDistance 	(IDStartingTower, 22.0);
	rmSetObjectDefMaxDistance 	(IDStartingTower, 27.0);
	
	int IDStartingGold			= rmCreateObjectDef("starting goldmine");
	rmAddObjectDefItem			(IDStartingGold, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance 	(IDStartingGold, 21.0);
	rmSetObjectDefMaxDistance 	(IDStartingGold, 23.0);
	rmAddObjectDefConstraint  	(IDStartingGold, AvoidEdge);
	rmAddObjectDefConstraint  	(IDStartingGold, AvoidGold);
	rmAddObjectDefConstraint  	(IDStartingGold, AvoidAll);
	rmAddObjectDefConstraint  	(IDStartingGold, AvoidImpassableLand);
	
	int IDStartingGoldLarge		= rmCreateObjectDef("starting large gold");
	rmAddObjectDefItem			(IDStartingGoldLarge, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance 	(IDStartingGoldLarge, 25.0);
	rmSetObjectDefMaxDistance 	(IDStartingGoldLarge, 30.0);
	rmAddObjectDefConstraint  	(IDStartingGoldLarge, AvoidEdge);
	rmAddObjectDefConstraint  	(IDStartingGoldLarge, AvoidAll);
	rmAddObjectDefConstraint  	(IDStartingGoldLarge, AvoidGold);
	rmAddObjectDefConstraint  	(IDStartingGoldLarge, AvoidImpassableLand);
	
	int IDStartingHerd			= rmCreateObjectDef("close herdable");
	rmAddObjectDefItem			(IDStartingHerd, "pig", 4, 3.0);
	rmSetObjectDefMinDistance	(IDStartingHerd, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingHerd, 30.0);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidImpassableLand);
	
	int IDStartingHunt			= rmCreateObjectDef("close hunt");
	rmAddObjectDefItem			(IDStartingHunt, "deer", rmRandInt(6,8), 3.0);
	rmSetObjectDefMinDistance	(IDStartingHunt, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingHunt, 30.0);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidImpassableLand);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	rmAddObjectDefConstraint	(IDStragglerTree, AvoidBonusIsland);
	
	int IDStraggler2			= rmCreateObjectDef("straggler tree2");
	rmAddObjectDefItem			(IDStraggler2, "Zpalm", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStraggler2, 11.0);
	rmSetObjectDefMaxDistance	(IDStraggler2, 17.0);
	rmAddObjectDefConstraint	(IDStraggler2, AvoidAll);
	
	//medium
	int IDMediumGold			= rmCreateObjectDef("med gold");
	rmAddObjectDefItem			(IDMediumGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 42.0);
	rmSetObjectDefMaxDistance	(IDMediumGold, 65.0);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidBonusIsland);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCenter);
	if (rmRandFloat(0,1) < 0.3) {
		rmAddObjectDefConstraint	(IDMediumGold, inCorner);
		rmAddObjectDefConstraint	(IDMediumGold, AvoidEdgeShort);
	} else {
		rmAddObjectDefConstraint	(IDMediumGold, AvoidCorner);
		rmAddObjectDefConstraint	(IDMediumGold, AvoidEdgeShort);
	}
	
	int IDMediumHerd			= rmCreateObjectDef("medium pig");
	rmAddObjectDefItem			(IDMediumHerd, "pig", rmRandFloat(2,3), 4.0);
	rmSetObjectDefMinDistance	(IDMediumHerd, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumHerd, 70.0);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidStartingSettle); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidEdge); 
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidHerdable); 
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 90.0);
	rmSetObjectDefMaxDistance	(IDFarGold, 120.0);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLandFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold, AvoidBonusIslandFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidCornerShort);
   
	int IDCenterGold			= rmCreateObjectDef("center gold");
	rmAddObjectDefItem			(IDCenterGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDCenterGold, 65.0);
	rmSetObjectDefMaxDistance	(IDCenterGold, 85.0+(cNumberNonGaiaPlayers*3));
	rmAddObjectDefConstraint	(IDCenterGold, AvoidAll);
	rmAddObjectDefConstraint	(IDCenterGold, AvoidEdgeFarther);
	rmAddObjectDefConstraint	(IDCenterGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDCenterGold, AvoidPlayer);
	rmAddObjectDefConstraint	(IDCenterGold, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDCenterGold, AvoidGold);
	rmAddObjectDefConstraint	(IDCenterGold, AvoidCenterShort);
	
	int IDFarHerd				= rmCreateObjectDef("far pigs");
	rmAddObjectDefItem			(IDFarHerd, "pig", rmRandInt(2,3), 4.0);
	rmSetObjectDefMinDistance	(IDFarHerd, 70.0);
	rmSetObjectDefMaxDistance	(IDFarHerd, 150.0);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidHerdable);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidPlayer);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidAll);
	
	int IDFarPred				= rmCreateObjectDef("far predator");
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.5)   
		rmAddObjectDefItem		(IDFarPred, "crocodile", 1, 4.0);
	else
		rmAddObjectDefItem		(IDFarPred, "crocodile", 2, 2.0);
	rmSetObjectDefMinDistance	(IDFarPred, 50.0);
	rmSetObjectDefMaxDistance	(IDFarPred, 100.0);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPred, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarPred, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarPred, AvoidAll);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPlayer);
	
	int IDFarCrocodile			= rmCreateObjectDef("far Crocs");
	rmAddObjectDefItem			(IDFarCrocodile, "crocodile", rmRandInt(1,2), 0.0);
	rmSetObjectDefMinDistance	(IDFarCrocodile, 50.0);
	rmSetObjectDefMaxDistance	(IDFarCrocodile, 100.0);
	rmAddObjectDefConstraint	(IDFarCrocodile, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarCrocodile, nearShore);
	rmAddObjectDefConstraint	(IDFarCrocodile, AvoidPredator);
	
	int IDFarCrane				= rmCreateObjectDef("far Crane");
	rmAddObjectDefItem			(IDFarCrane, "crowned crane", rmRandInt(6,8), 3.0);
	rmSetObjectDefMinDistance	(IDFarCrane, 50.0);
	rmSetObjectDefMaxDistance	(IDFarCrane, 150.0);
	rmAddObjectDefConstraint	(IDFarCrane, nearShore);
	
	float bonusChance = rmRandFloat(0, 1);
	
	int IDBonusHuntable1		= rmCreateObjectDef("bonus huntable1");
	if(bonusChance<0.5)   
		rmAddObjectDefItem		(IDBonusHuntable1, "water buffalo", rmRandInt(2,3), 2.0);
	else if(bonusChance<0.75)
		rmAddObjectDefItem		(IDBonusHuntable1, "deer", rmRandInt(5,6), 3.0);
	else
		rmAddObjectDefItem		(IDBonusHuntable1, "hippo", rmRandInt(3,5), 3.0);
	rmSetObjectDefMinDistance	(IDBonusHuntable1, 60.0);
	rmSetObjectDefMaxDistance	(IDBonusHuntable1, 100.0);
	rmAddObjectDefConstraint	(IDBonusHuntable1, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDBonusHuntable1, AvoidHuntable);
	rmAddObjectDefConstraint	(IDBonusHuntable1, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDBonusHuntable1, AvoidEdge);
	rmAddObjectDefConstraint	(IDBonusHuntable1, AvoidAll);
	rmAddObjectDefConstraint	(IDBonusHuntable1, AvoidBonusIslandFar);
	
	int IDBonusHuntable2		= rmCreateObjectDef("bonus huntable2");
	
	if(bonusChance<0.5)
		rmAddObjectDefItem		(IDBonusHuntable2, "hippo", 2, 2.0);
	else if(bonusChance<0.75)
		{
			rmAddObjectDefItem	(IDBonusHuntable2, "water buffalo", rmRandInt(3,4), 3.0);
				if(rmRandFloat(0,1)<0.5) 
					rmAddObjectDefItem(IDBonusHuntable2, "deer", rmRandInt(2,4), 3.0);
		}
	else
		rmAddObjectDefItem		(IDBonusHuntable2, "deer", rmRandInt(6,9), 4.0);
	
	rmSetObjectDefMinDistance	(IDBonusHuntable2, 50.0);
	rmSetObjectDefMaxDistance	(IDBonusHuntable2, 80.0);
	rmAddObjectDefConstraint	(IDBonusHuntable2, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDBonusHuntable2, AvoidAll);
	rmAddObjectDefConstraint	(IDBonusHuntable2, AvoidHuntable);
	rmAddObjectDefConstraint	(IDBonusHuntable2, AvoidBonusIslandFar);
	rmAddObjectDefConstraint	(IDBonusHuntable2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDBonusHuntable2, AvoidEdge);
	
	bonusChance = rmRandFloat(0, 1);
	
	int IDBonusHuntable3		= rmCreateObjectDef("bonus huntable3");
	if(bonusChance<0.5)   
		rmAddObjectDefItem		(IDBonusHuntable3, "boar", 4, 2.0);
	else if(bonusChance<0.75) {
		rmAddObjectDefItem		(IDBonusHuntable3, "boar", 6, 3.0);
		if(rmRandFloat(0,1)<0.5)      
			rmAddObjectDefItem	(IDBonusHuntable3, "crowned crane", rmRandInt(4,6), 4.0);
	} else
		rmAddObjectDefItem		(IDBonusHuntable3, "water buffalo", rmRandInt(4,5), 3.0);
	rmSetObjectDefMinDistance	(IDBonusHuntable3, 55.0);
	rmSetObjectDefMaxDistance	(IDBonusHuntable3, 100.0);
	rmAddObjectDefConstraint	(IDBonusHuntable3, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDBonusHuntable3, AvoidAll);
	rmAddObjectDefConstraint	(IDBonusHuntable3, AvoidHuntable);
	rmAddObjectDefConstraint	(IDBonusHuntable3, AvoidPlayer);
	rmAddObjectDefConstraint	(IDBonusHuntable3, AvoidImpassableLand);
	
	bonusChance=rmRandFloat(0, 1);
	
	int IDBonusHuntable4		= rmCreateObjectDef("bonus huntable4");
	if(bonusChance<0.5)   
		rmAddObjectDefItem		(IDBonusHuntable4, "boar", 4, 2.0);
	else if(bonusChance<0.75) {
		rmAddObjectDefItem	(IDBonusHuntable4, "boar", 6, 3.0);
		if(rmRandFloat(0,1)<0.5)      
			rmAddObjectDefItem(IDBonusHuntable4, "crowned crane", rmRandInt(4,6), 4.0);
	} else
		rmAddObjectDefItem		(IDBonusHuntable4, "water buffalo", rmRandInt(2,3), 3.0);
	rmSetObjectDefMinDistance	(IDBonusHuntable4, 0.0);
	rmSetObjectDefMaxDistance	(IDBonusHuntable4, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDBonusHuntable4, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDBonusHuntable4, AvoidAll);
	rmAddObjectDefConstraint	(IDBonusHuntable4, AvoidHuntable);
	rmAddObjectDefConstraint	(IDBonusHuntable4, AvoidPlayer);
	rmAddObjectDefConstraint	(IDBonusHuntable4, AvoidImpassableLand);
	
	int IDBirds					= rmCreateObjectDef("far hawks");
	rmAddObjectDefItem			(IDBirds, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance	(IDBirds, 0.0);
	rmSetObjectDefMaxDistance	(IDBirds, rmXFractionToMeters(0.5));

	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRelic, 40.0);
	rmSetObjectDefMaxDistance	(IDRelic, 200.0);
	rmAddObjectDefConstraint	(IDRelic, AvoidEdgeShort);
	rmAddObjectDefConstraint	(IDRelic, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 30.0));
	rmAddObjectDefConstraint	(IDRelic, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRelic, AvoidPlayer);
	rmAddObjectDefConstraint	(IDRelic, AvoidAll);
	
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "oak tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidBonusIsland);
	
	int IDRandomTree2			= rmCreateObjectDef("random tree 2");
	rmAddObjectDefItem			(IDRandomTree2, "Zpalm", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree2, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree2, rmCreateTypeDistanceConstraint("random tree two", "all", 4.0));
	rmAddObjectDefConstraint	(IDRandomTree2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomTree2, AvoidSettlementSlightly);
	rmAddObjectDefConstraint	(IDRandomTree2, AvoidPlayer);
	
	//giant
	if(cMapSize == 2) {
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantGoldID, AvoidGoldFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdgeFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantGoldID, AvoidAll);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLand);

		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "boar", 5, 3.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHuntable);
		rmAddObjectDefConstraint(giantHuntableID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntableID, AvoidCenterShort);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);

		int giantHuntable2ID=rmCreateObjectDef("giant huntable 2");
		rmAddObjectDefItem(giantHuntable2ID, "water buffalo", 2, 2.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidCenterShort);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidImpassableLand);

		int giantHuntable3ID=rmCreateObjectDef("giant huntable 3");
		rmAddObjectDefItem(giantHuntable3ID, "hippo", rmRandInt(4,5), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantHuntable3ID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidCenterShort);
		rmAddObjectDefConstraint(giantHuntable3ID, AvoidImpassableLand);

		int giantHuntable4ID=rmCreateObjectDef("giant huntable 4");
		rmAddObjectDefItem(giantHuntable4ID, "crowned crane", rmRandInt(6,7), 4.0);
		rmSetObjectDefMaxDistance(giantHuntable4ID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHuntable4ID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantHuntable4ID, AvoidHuntable);
		rmAddObjectDefConstraint(giantHuntable4ID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntable4ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable4ID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntable4ID, AvoidCenterShort);
		rmAddObjectDefConstraint(giantHuntable4ID, AvoidImpassableLand);

		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, 100.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerdable);
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, AvoidPlayer);

		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidSettlementSlightly);
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, AvoidEdge);
		rmAddObjectDefConstraint(giantRelixID, AvoidPlayer);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
	}
	
	rmSetStatusText("",0.40);
	///DEFINE PLAYER LOCATIONS
	rmPlacePlayersCircular(0.38, 0.40, rmDegreesToRadians(5.0));
	
	rmSetStatusText("",0.45);
	///AREA DEFINITION
	int IDCenter		= rmCreateArea("center");
   rmSetAreaSize		(IDCenter, 0.01, 0.01);
   rmSetAreaLocation	(IDCenter, 0.5, 0.5);
   rmAddAreaToClass		(IDCenter, classCenter);
   rmBuildArea			(IDCenter);
	
	for(i=1; <cNumberPlayers)
	{
		int AreaPlayerCore	= rmCreateArea("Player core"+i);
		rmSetAreaSize		(AreaPlayerCore, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
		rmAddAreaToClass	(AreaPlayerCore, classPlayerCore);
		rmSetAreaCoherence	(AreaPlayerCore, 1.0);
		rmSetAreaBaseHeight	(AreaPlayerCore, 10.0);
		rmSetAreaLocPlayer	(AreaPlayerCore, i);

		rmBuildArea(AreaPlayerCore);
	}
	
	int IDShallows						= rmCreateConnection("shallows");
	rmSetConnectionType					(IDShallows, cConnectAreas, false, 1.0);
	rmSetConnectionWidth				(IDShallows, 28, 2);
	rmSetConnectionWarnFailure			(IDShallows, false);
	rmSetConnectionBaseHeight			(IDShallows, 2.0);
	rmSetConnectionHeightBlend			(IDShallows, 2.0);
	rmSetConnectionSmoothDistance		(IDShallows, 3.0);
	rmAddConnectionTerrainReplacement	(IDShallows, "WhiteBeachI", "WhiteBeachII");
	
	int IDExtraShallows					= rmCreateConnection("extra shallows");
	if(cNumberPlayers < 5)
		rmSetConnectionType				(IDExtraShallows, cConnectAreas, false, 0.75);
	else if(cNumberPlayers < 7) 
		rmSetConnectionType				(IDExtraShallows, cConnectAreas, false, 0.50);
	rmSetConnectionWidth				(IDExtraShallows, 28, 2);
	rmSetConnectionWarnFailure			(IDExtraShallows, false); 
	rmSetConnectionBaseHeight			(IDExtraShallows, 2.0);
	rmSetConnectionHeightBlend			(IDExtraShallows, 2.0);
	rmSetConnectionSmoothDistance		(IDExtraShallows, 3.0);
	rmSetConnectionPositionVariance		(IDExtraShallows, -1.0); 
	rmAddConnectionTerrainReplacement	(IDExtraShallows, "WhiteBeachI", "WhiteBeachII"); 
	rmAddConnectionStartConstraint		(IDExtraShallows, AvoidPlayerCore);
	rmAddConnectionEndConstraint		(IDExtraShallows, AvoidPlayerCore);
	
	int IDTeamShallows					= rmCreateConnection("team shallows");
	rmSetConnectionType					(IDTeamShallows, cConnectAllies, false, 1.0);
	rmSetConnectionWarnFailure			(IDTeamShallows, false);
	rmSetConnectionWidth				(IDTeamShallows, 28, 2);
	rmSetConnectionBaseHeight			(IDTeamShallows, 2.0);
	rmSetConnectionHeightBlend			(IDTeamShallows, 2.0);
	rmSetConnectionSmoothDistance		(IDTeamShallows, 3.0);
	rmAddConnectionTerrainReplacement	(IDTeamShallows, "WhiteBeachI", "WhiteBeachII");
	
	int bonusCount = rmRandInt(5*mapSizeMultiplier, 6*mapSizeMultiplier);
	int bonusIsleSize = 3800*mapSizeMultiplier;
	
	for(i = 0; <bonusCount)
	{
		int IDBonusIsland		= rmCreateArea("bonus island"+i);
		rmSetAreaSize			(IDBonusIsland, rmAreaTilesToFraction(bonusIsleSize*0.9), rmAreaTilesToFraction(bonusIsleSize*1.1));
		rmSetAreaTerrainType	(IDBonusIsland, "WhiteBeachIV");
		rmAddAreaTerrainLayer	(IDBonusIsland, "WhiteBeachIV", 0, 6);  
		rmSetAreaWarnFailure	(IDBonusIsland, false);
		
		if (rmRandFloat(0.0, 1.0) < 0.75)
		rmAddAreaConstraint		(IDBonusIsland, AvoidBonusIsland);
	
		rmAddAreaConstraint		(IDBonusIsland, AvoidEdgeFar);
		rmAddAreaToClass		(IDBonusIsland, classIsland);
		rmAddAreaToClass		(IDBonusIsland, classBonusIsland);
		rmAddAreaConstraint		(IDBonusIsland, AvoidPlayerCore);
		rmSetAreaCoherence		(IDBonusIsland, 0.25);
		rmSetAreaSmoothDistance	(IDBonusIsland, 12);
		rmSetAreaHeightBlend	(IDBonusIsland, 2);
		rmSetAreaBaseHeight		(IDBonusIsland, 2.0);
		rmAddConnectionArea		(IDExtraShallows, IDBonusIsland);
		rmAddConnectionArea		(IDShallows, IDBonusIsland);
	}  

	rmBuildAllAreas();
		
	for(i=1; <cNumberPlayers)
	{
		AreaPlayerCore			= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, AreaPlayerCore);
		rmSetAreaSize			(AreaPlayerCore, 0.5, 0.5);
		rmAddAreaToClass		(AreaPlayerCore, classIsland);
		rmAddAreaToClass		(AreaPlayerCore, classPlayer);
		rmSetAreaWarnFailure	(AreaPlayerCore, false);
		rmSetAreaMinBlobs		(AreaPlayerCore, 3*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(AreaPlayerCore, 6*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(AreaPlayerCore, 7.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(AreaPlayerCore, 12.0*mapSizeMultiplier);
		rmSetAreaCoherence		(AreaPlayerCore, 0.5);
		rmSetAreaBaseHeight		(AreaPlayerCore, 6.0);
		rmSetAreaSmoothDistance	(AreaPlayerCore, 10);
		rmSetAreaHeightBlend	(AreaPlayerCore, 2);
		rmAddAreaConstraint		(AreaPlayerCore, AvoidIsland);
		rmAddAreaConstraint		(AreaPlayerCore, AvoidBonusIsland);
		rmAddAreaConstraint		(AreaPlayerCore, AvoidCenter);
		rmSetAreaLocPlayer		(AreaPlayerCore, i);
		rmAddConnectionArea		(IDExtraShallows, AreaPlayerCore);
		rmAddConnectionArea		(IDShallows, AreaPlayerCore);
		rmSetAreaTerrainType	(AreaPlayerCore, "WhiteBeachII");
		rmAddAreaTerrainLayer	(AreaPlayerCore, "WhiteBeachII", 4, 7);
		rmAddAreaTerrainLayer	(AreaPlayerCore, "WhiteBeachII", 2, 4);
		rmAddAreaTerrainLayer	(AreaPlayerCore, "WhiteBeachI", 0, 2);
	}
	
	rmBuildAllAreas();
	rmBuildConnection(IDTeamShallows);
	rmBuildConnection(IDShallows);
	if(cNumberNonGaiaPlayers < 4)
		rmBuildConnection(IDExtraShallows);
	else if(cNumberNonGaiaPlayers < 6)
	{   
		if(rmRandFloat(0,1)<0.5)
			rmBuildConnection(IDExtraShallows);
	}
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier)
	{
		int AreaMarsh			= rmCreateArea("marsh patch"+i);
		rmSetAreaSize			(AreaMarsh, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaMarsh, "WhiteBeachIV");
		rmSetAreaMinBlobs		(AreaMarsh, 1);
		rmSetAreaMaxBlobs		(AreaMarsh, 5);
		rmSetAreaMinBlobDistance(AreaMarsh, 16.0);
		rmSetAreaMaxBlobDistance(AreaMarsh, 40.0);
		rmSetAreaCoherence		(AreaMarsh, 0.0);
		rmAddAreaConstraint		(AreaMarsh, AvoidImpassableLand);
		rmAddAreaConstraint		(AreaMarsh, AvoidPlayer);
		rmBuildArea				(AreaMarsh);
	} 
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier)
	{
		int AreaGrass				= rmCreateArea("grass patch"+i);
		rmSetAreaSize			(AreaGrass, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(40*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaGrass, "WhiteBeachV");
		rmSetAreaMinBlobs		(AreaGrass, 1);
		rmSetAreaMaxBlobs		(AreaGrass, 5);
		rmSetAreaMinBlobDistance(AreaGrass, 16.0);
		rmSetAreaMaxBlobDistance(AreaGrass, 40.0);
		rmSetAreaCoherence		(AreaGrass, 0.0);
		rmAddAreaConstraint		(AreaGrass, AvoidImpassableLand);
		rmAddAreaConstraint		(AreaGrass, AvoidBonusIsland);
		rmBuildArea				(AreaGrass);
	} 
	
	for(i=1; <cNumberPlayers*20*mapSizeMultiplier)
	{
		int AreaDirt			= rmCreateArea("dirt patch"+i);
		rmSetAreaSize			(AreaDirt, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaDirt, "WhiteBeachIV");
		rmAddAreaTerrainLayer	(AreaDirt, "WhiteBeachIV", 0, 2); 
		rmSetAreaMinBlobs		(AreaDirt, 1);
		rmSetAreaMaxBlobs		(AreaDirt, 5);
		rmSetAreaMinBlobDistance(AreaDirt, 16.0);
		rmSetAreaMaxBlobDistance(AreaDirt, 40.0);
		rmSetAreaCoherence		(AreaDirt, 0.0);
		rmAddAreaConstraint		(AreaDirt, AvoidImpassableLand);
		rmAddAreaConstraint		(AreaDirt, AvoidBonusIsland);
		rmBuildArea				(AreaDirt);
	} 
	
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
	rmSetAreaSize			(AreaNonCorner, 0.78, 0.78);
	rmSetAreaLocation		(AreaNonCorner, 0.5, 0.5);
	rmSetAreaWarnFailure	(AreaNonCorner, false);
	rmAddAreaToClass		(AreaNonCorner, classAvoidCorner);
	rmAddAreaConstraint		(AreaNonCorner, AvoidCornerShort);
	rmSetAreaCoherence		(AreaNonCorner, 1.0);
	
	rmBuildArea(AreaNonCorner);
	}
	
	
	
	rmSetStatusText("",0.60);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int id = rmAddFairLoc("Settlement", false, true, 60, 85, 40, 28); 
	rmAddFairLocConstraint(id, AvoidImpassableLandFar);

	if (cNumberNonGaiaPlayers < 3) {
		id = rmAddFairLoc("Settlement", true, false,  75, 100, 70, 60); 
		rmAddFairLocConstraint(id, AvoidImpassableLandFar);
		rmAddFairLocConstraint(id, AvoidPlayerFar);
		rmAddFairLocConstraint(id, AvoidCenterShort);
	} else {
		id = rmAddFairLoc("Settlement", true, false,  80, 120, 60, 40); 
		rmAddFairLocConstraint(id, AvoidImpassableLandFar);
		rmAddFairLocConstraint(id, AvoidPlayerFar);
		rmAddFairLocConstraint(id, AvoidCenterShort);
	}
	
	
	if (cMapSize == 2) {
		id = rmAddFairLoc("Settlement", false, true, 100, 180, 80, 25);
		rmAddFairLocConstraint(id, AvoidImpassableLandFar);

		id = rmAddFairLoc("Settlement", true, false,  110, 200, 80, 50); 
		rmAddFairLocConstraint(id, AvoidImpassableLandFar);
		rmAddFairLocConstraint(id, AvoidPlayerFar);
		rmAddFairLocConstraint(id, AvoidCenterShort);
	}
   
	if(rmPlaceFairLocs())
	{
		id = rmCreateObjectDef("far settlement");
		rmAddObjectDefItem(id, "Settlement", 1, 0.0);
		for(i = 1; < cNumberPlayers)
		{
			for(j = 0; <rmGetNumberFairLocs(i))
				rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	rmSetStatusText("",0.70);
	///PLACE OBJECTS
	rmPlaceObjectDefPerPlayer(IDStartingTower, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingHunt, false);
	rmPlaceObjectDefPerPlayer(IDStartingHerd, true);
	rmPlaceObjectDefPerPlayer(IDStraggler2, false, rmRandInt(1,3));
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(3,7));
	
	float closeGold = (rmRandFloat(0,1));
	if (closeGold < 0.15) {
		rmPlaceObjectDefPerPlayer(IDStartingGoldLarge, false);
	}
		
	rmPlaceObjectDefPerPlayer(IDMediumGold, false);
	
	int pigNum = rmRandInt(1,2);
	for(i=1; <cNumberPlayers) {
		rmPlaceObjectDefInArea(IDMediumHerd, false, rmAreaID("bonus island"+i));
		rmPlaceObjectDefInArea(IDFarHerd, false, rmAreaID("bonus island"+i), pigNum);
	}
	
	int goldNum = rmRandInt(1,2);
	
	for(i = 1; < cNumberPlayers) {
		rmPlaceObjectDefInArea(IDFarGold, false, rmAreaID("player"+i), goldNum);
		rmPlaceObjectDefInArea(IDFarCrane, false, rmAreaID("player"+i));
		rmPlaceObjectDefInArea(IDFarCrocodile, false, rmAreaID("player"+i));
	}
	rmPlaceObjectDefPerPlayer(IDCenterGold, false, rmRandInt(1,2));
	
	rmPlaceObjectDefPerPlayer(IDBonusHuntable1, false);
	rmPlaceObjectDefPerPlayer(IDBonusHuntable2, false);
	
	rmPlaceObjectDefPerPlayer(IDBonusHuntable3, false, 2*mapSizeMultiplier);
	rmPlaceObjectDefAtLoc(IDBonusHuntable4, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmPlaceObjectDefAtLoc(IDRelic, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers); 
	
	rmPlaceObjectDefPerPlayer(IDFarPred, false, rmRandInt(1,2));
	
	rmPlaceObjectDefPerPlayer(IDBirds, false, 2);
	
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 3);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntable3ID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntable4ID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, 1);
		rmPlaceObjectDefAtLoc	(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.80);
	///FORESTS
	int forestCount = 3*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int failCount = 0;
	for(i = 0; < forestCount)
	{
		int IDForest			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(60*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "AOE III Forest");
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidPlayer);
		rmAddAreaConstraint		(IDForest, AvoidImpassableLand);
		rmAddAreaToClass		(IDForest, classForest);
		rmSetAreaTerrainType	(IDForest, "WhiteBeachIV");
		rmAddAreaTerrainLayer	(IDForest, "WhiteBeachIV", 0, 2); 
		rmSetAreaMinBlobs		(IDForest, 2*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDForest, 4*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDForest, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDForest, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDForest, 0.0);
		rmSetAreaBaseHeight		(IDForest, 0);
		rmSetAreaSmoothDistance	(IDForest, 4);
		rmSetAreaHeightBlend	(IDForest, 2);
		if(rmBuildArea(IDForest)==false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount == 3)
				break;
		}
		else
			failCount = 0;
	}
	
	failCount=0;
	for(i=0; <9*cNumberNonGaiaPlayers*mapSizeMultiplier)
	{
		int IDPlayerForest			= rmCreateArea("playerForest"+i, rmAreaID("player"+i));
		rmSetAreaSize				(IDPlayerForest, rmAreaTilesToFraction(80*mapSizeMultiplier), rmAreaTilesToFraction(140*mapSizeMultiplier));
		rmSetAreaWarnFailure		(IDPlayerForest, false);
		rmSetAreaForestType			(IDPlayerForest, "AOE III Forest");
		rmAddAreaConstraint			(IDPlayerForest, AvoidStartingSettleTiny);
		rmAddAreaConstraint			(IDPlayerForest, AvoidForestFar);
		rmAddAreaConstraint			(IDPlayerForest, AvoidBonusIsland);
		rmAddAreaConstraint			(IDPlayerForest, AvoidImpassableLand);
		rmAddAreaConstraint			(IDPlayerForest, AvoidAll);
		rmAddAreaToClass			(IDPlayerForest, classForest);
		rmSetAreaMinBlobs			(IDPlayerForest, 2*mapSizeMultiplier);
		rmSetAreaMaxBlobs			(IDPlayerForest, 4*mapSizeMultiplier);
		rmSetAreaMinBlobDistance	(IDPlayerForest, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance	(IDPlayerForest, 20.0*mapSizeMultiplier);
		rmSetAreaCoherence			(IDPlayerForest, 0.0);
		if(rmRandFloat(0.0, 1.0)<0.6)
			rmSetAreaBaseHeight		(IDPlayerForest, rmRandFloat(8.0, 10.0));
		rmSetAreaSmoothDistance		(IDPlayerForest, 5);
		rmSetAreaHeightBlend		(IDPlayerForest, 2);
		if(rmBuildArea(IDPlayerForest) == false)
		{
			failCount++;
			if(failCount == 3)
				break;
		}
		else
			failCount=0;
	}
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);

	rmPlaceObjectDefAtLoc(IDRandomTree2, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers*mapSizeMultiplier);
	rmSetStatusText("",0.90);
	///BEAUTIFICATION
	int IDLog					= rmCreateObjectDef("log");
	rmAddObjectDefItem			(IDLog, "Statue Aztec", rmRandInt(1,2), 0.0);
	rmAddObjectDefItem			(IDLog, "bush", 1, 2.0);
	rmAddObjectDefItem			(IDLog, "zflowers", rmRandInt(3,5), 2.0);
	rmSetObjectDefMinDistance	(IDLog, 0.0);
	rmSetObjectDefMaxDistance	(IDLog, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLog, AvoidAll);
	rmAddObjectDefConstraint	(IDLog, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDLog, AvoidPlayer);
	rmPlaceObjectDefAtLoc		(IDLog, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDGrass					= rmCreateObjectDef("grasses");
	rmAddObjectDefItem			(IDGrass, "bush", rmRandInt(1,3), 2.0);
	rmAddObjectDefItem			(IDGrass, "grass", rmRandInt(3,5), 5.0);
	rmAddObjectDefItem			(IDGrass, "rock limestone sprite", rmRandInt(2,4), 10.0);
	rmSetObjectDefMinDistance	(IDGrass, 0.0);
	rmSetObjectDefMaxDistance	(IDGrass, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDGrass, AvoidAll);
	rmAddObjectDefConstraint	(IDGrass, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDGrass, AvoidBonusIsland);
	rmPlaceObjectDefAtLoc		(IDGrass, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDReeds					= rmCreateObjectDef("reeds");
	rmAddObjectDefItem			(IDReeds, "water reeds", rmRandInt(4,6), 2.0);
	rmAddObjectDefItem			(IDReeds, "rock granite big", rmRandInt(1,3), 3.0);
	rmSetObjectDefMinDistance	(IDReeds, 0.0);
	rmSetObjectDefMaxDistance	(IDReeds, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDReeds, AvoidAll);
	rmAddObjectDefConstraint	(IDReeds, nearShore);
	rmPlaceObjectDefAtLoc		(IDReeds, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDLily					= rmCreateObjectDef("pads");
	rmAddObjectDefItem			(IDLily, "water lilly", rmRandInt(3,5), 4.0);
	rmSetObjectDefMinDistance	(IDLily, 0.0);
	rmSetObjectDefMaxDistance	(IDLily, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLily, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDLily, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers*mapSizeMultiplier);

	rmSetStatusText("",1.00);
}
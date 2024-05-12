/*Watering Hole
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
	int size = 2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
	rmSetMapSize(size, size);
	
	rmSetSeaLevel(1.0);
	rmSetSeaType("savannah Water Hole");
	rmTerrainInitialize("water");
	
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
	
	rmSetStatusText("",0.10);
	///CONSTRAINTS
	int AvoidEdge		= rmCreateBoxConstraint("BC0", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4)); 
	int AvoidEdgeLong	= rmCreateBoxConstraint("BC1", rmXTilesToFraction(30), rmZTilesToFraction(30), 1.0-rmXTilesToFraction(30), 1.0-rmZTilesToFraction(30)); 
	int AvoidEdgeFar	= rmCreateBoxConstraint("BC2", rmXTilesToFraction(40), rmZTilesToFraction(40), 1.0-rmXTilesToFraction(40), 1.0-rmZTilesToFraction(40)); 
	
	int AvoidBuildings			= rmCreateTypeDistanceConstraint("TDC0", "Building", 10.0);
	int AvoidGold				= rmCreateTypeDistanceConstraint("TDC1", "gold", 25.0);
	int AvoidGoldFar			= rmCreateTypeDistanceConstraint("TDC2", "gold", 35.0);
	int AvoidHerd				= rmCreateTypeDistanceConstraint("TDC3", "herdable", 20.0);
	int AvoidHunt				= rmCreateTypeDistanceConstraint("TDC4", "huntable", 20.0);
	int AvoidRelic				= rmCreateTypeDistanceConstraint("TDC5", "relic", 60.0);
	int AvoidSettlement			= rmCreateTypeDistanceConstraint("TDC6", "abstractSettlement", 20.0);
	int AvoidPred				= rmCreateTypeDistanceConstraint("TDC7", "animalPredator", 30.0);
	int AvoidAll				= rmCreateTypeDistanceConstraint("TDC8", "all", 6.0);
	int AvoidTower				= rmCreateTypeDistanceConstraint("TDC9", "tower", 24.0);
	int AvoidSettlementShort	= rmCreateTypeDistanceConstraint("TDC10", "abstractSettlement", 16.0);
	int AvoidAllFar				= rmCreateTypeDistanceConstraint("TDC11", "all", 10.0);
	
	int AvoidCore				= rmCreateClassDistanceConstraint("CDC0", classPlayerCore, 60);
	int AvoidPlayerCoreShort	= rmCreateClassDistanceConstraint("CDC1", classPlayerCore, 5);
	int AvoidBonusIsland		= rmCreateClassDistanceConstraint("CDC2", classBonusIsland, 15);
	int AvoidBonusIslandFar		= rmCreateClassDistanceConstraint("CDC3", classBonusIsland, 30);
	int AvoidIsland				= rmCreateClassDistanceConstraint("CDC4", classIsland, 20);
	int AvoidCenter				= rmCreateClassDistanceConstraint("CDC5", classCenter, 40);
	int AvoidCenterShort		= rmCreateClassDistanceConstraint("CDC6", classCenter, 10);
	int AvoidPlayerFar			= rmCreateClassDistanceConstraint("CDC7", classPlayer, 15);
	int AvoidStartingTCFar		= rmCreateClassDistanceConstraint("CDC8", classStartingSettle, 70);
	int AvoidStartingTCShort	= rmCreateClassDistanceConstraint("CDC9", classStartingSettle, 20);
	int AvoidForest				= rmCreateClassDistanceConstraint("CDC10", classForest, 22);
	int AvoidCornerShort		= rmCreateClassDistanceConstraint ("C11", classCorner, 1.0);
	int AvoidCorner				= rmCreateClassDistanceConstraint ("C12", classCorner, 15.0);
	int inCorner				= rmCreateClassDistanceConstraint ("C13", classAvoidCorner, 1.0);
	
	int AvoidImpassableLand			= rmCreateTerrainDistanceConstraint("TeDC0", "land", false, 5);
	int AvoidImpassableLandShort	= rmCreateTerrainDistanceConstraint("TeDC1", "land", false, 2);
	int AvoidImpassableLandFar		= rmCreateTerrainDistanceConstraint("TeDC2", "land", false, 15);
	
	int nearShore	= rmCreateTerrainMaxDistanceConstraint("TMDC0", "water", true, 6.0);
	
	rmSetStatusText("",0.20);
	///OBJECT DEFINITION
	int IDStartingSettlement	= rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem			(IDStartingSettlement, "settlement level 1", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingSettlement, 0);
	rmSetObjectDefMaxDistance	(IDStartingSettlement, 0);
	rmAddObjectDefToClass		(IDStartingSettlement, classStartingSettle);
	
	int IDStartingTowers		= rmCreateObjectDef("starting tower");
	rmAddObjectDefItem			(IDStartingTowers, "tower", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingTowers, 22);
	rmSetObjectDefMaxDistance	(IDStartingTowers, 28);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidTower);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidEdge);
	
	int GoldDistance = rmRandInt(21,24);
	
	int IDStartingGold			= rmCreateObjectDef("starting gold");
	rmAddObjectDefItem			(IDStartingGold, "gold mine small", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidEdge);
	
	int IDStartingHunt			= rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem			(IDStartingHunt, "gazelle", rmRandInt(3,8), 4);
	rmSetObjectDefMinDistance	(IDStartingHunt, 22);
	rmSetObjectDefMaxDistance	(IDStartingHunt, 27);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidImpassableLand);
	
	float HuntNum = rmRandFloat(0,1);
	
	int IDStartingHunt2			= rmCreateObjectDef("starting big hunt");
	
	if (HuntNum < 0.3) {
		rmAddObjectDefItem			(IDStartingHunt2, "hippo", 2, 2);
	} else if (HuntNum < 0.6) {
		rmAddObjectDefItem			(IDStartingHunt2, "hippo", 3, 4);
	} else {
		rmAddObjectDefItem			(IDStartingHunt2, "rhinocerous", 2, 2);
	}
	
	if (rmRandFloat (0,1) < 0.2) {
		rmSetObjectDefMinDistance	(IDStartingHunt2, 30);
		rmSetObjectDefMaxDistance	(IDStartingHunt2, 33);
	} else {
		rmSetObjectDefMinDistance	(IDStartingHunt2, 40);
		rmSetObjectDefMaxDistance	(IDStartingHunt2, 50);
		rmAddObjectDefConstraint	(IDStartingHunt2, AvoidTower);
	}
	rmAddObjectDefConstraint	(IDStartingHunt2, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt2, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingHunt2, AvoidHunt);
	rmAddObjectDefConstraint	(IDStartingHunt2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDStartingHunt2, AvoidSettlement);
	rmAddObjectDefConstraint	(IDStartingHunt2, AvoidBonusIsland);
	
	int IDStartingHerd			= rmCreateObjectDef("starting herd");
	rmAddObjectDefItem			(IDStartingHerd, "pig", rmRandInt(0,2), 3);
	rmSetObjectDefMinDistance	(IDStartingHerd, 25);
	rmSetObjectDefMaxDistance	(IDStartingHerd, 30);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidImpassableLand);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	
	//medium
	int GoldDistance2 = 0;
	float MedGoldNum = rmRandFloat(0,1);
	if (MedGoldNum < 0.1) {
		GoldDistance2 = rmRandInt(24,27);
	} else {
		GoldDistance2 = rmRandInt(50,60);
	}
	
	int IDMediumGold			= rmCreateObjectDef("medium goldmine");
	rmAddObjectDefItem			(IDMediumGold, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDMediumGold, GoldDistance2);
	rmSetObjectDefMaxDistance	(IDMediumGold, GoldDistance2+5);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidBonusIslandFar);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLandFar);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlement);
	
	if (MedGoldNum > 0.9) {
		rmAddObjectDefConstraint	(IDMediumGold, inCorner);
	} else {
		rmAddObjectDefConstraint	(IDMediumGold, AvoidCornerShort);
	}
	
	int IDMediumHerd			= rmCreateObjectDef("medium herd");
	rmAddObjectDefItem			(IDMediumHerd, "pig", rmRandInt(2,3), 2);
	rmSetObjectDefMinDistance	(IDMediumHerd, 55);
	rmSetObjectDefMaxDistance	(IDMediumHerd, 75);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidHerd);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumHerd, AvoidBonusIslandFar);
	
	float numHunt = rmRandInt(6, 10);
	
	int IDMediumZebra			= rmCreateObjectDef("medium zebra");
	rmAddObjectDefItem			(IDMediumZebra, "zebra", numHunt, 4);
	rmSetObjectDefMinDistance	(IDMediumZebra, 50);
	rmSetObjectDefMaxDistance	(IDMediumZebra, 70);
	rmAddObjectDefConstraint	(IDMediumZebra, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumZebra, AvoidBonusIslandFar);
	rmAddObjectDefConstraint	(IDMediumZebra, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumZebra, AvoidEdge);
	
	int IDMediumGazelle			= rmCreateObjectDef("medium gazelle");
	rmAddObjectDefItem			(IDMediumGazelle, "gazelle", numHunt, 4);
	rmSetObjectDefMinDistance	(IDMediumGazelle, 50);
	rmSetObjectDefMaxDistance	(IDMediumGazelle, 70);
	rmAddObjectDefConstraint	(IDMediumGazelle, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGazelle, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGazelle, AvoidBonusIslandFar);
	rmAddObjectDefConstraint	(IDMediumGazelle, AvoidImpassableLand);
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold, 80);
	rmSetObjectDefMaxDistance	(IDFarGold, 100);
	rmAddObjectDefConstraint	(IDFarGold, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold, AvoidBonusIslandFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingTCFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold, AvoidCornerShort);
	
	int IDBonusGold				= rmCreateObjectDef("bonus gold");
	rmAddObjectDefItem			(IDBonusGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDBonusGold, 80.0);
	rmSetObjectDefMaxDistance	(IDBonusGold, 130.0);
	rmAddObjectDefConstraint	(IDBonusGold, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDBonusGold, AvoidEdgeFar);
	rmAddObjectDefConstraint	(IDBonusGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDBonusGold, AvoidPlayerFar);
	rmAddObjectDefConstraint	(IDBonusGold, AvoidImpassableLand);
	
	int IDBonusGold2			= rmCreateObjectDef("bonus gold 2");
	rmAddObjectDefItem			(IDBonusGold2, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDBonusGold2, 105.0);
	rmSetObjectDefMaxDistance	(IDBonusGold2, 160.0);
	rmAddObjectDefConstraint	(IDBonusGold2, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDBonusGold2, AvoidAll);
	rmAddObjectDefConstraint	(IDBonusGold2, AvoidEdgeFar);
	rmAddObjectDefConstraint	(IDBonusGold2, AvoidSettlementShort);
	rmAddObjectDefConstraint	(IDBonusGold2, AvoidPlayerFar);
	rmAddObjectDefConstraint	(IDBonusGold2, AvoidImpassableLand);
	
	int IDFarHerd				= rmCreateObjectDef("far herd");
	rmAddObjectDefItem			(IDFarHerd, "pig", rmRandInt(1,2), 2);
	rmSetObjectDefMinDistance	(IDFarHerd, 70);
	rmSetObjectDefMaxDistance	(IDFarHerd, 110);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidHerd);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidStartingTCFar);
	
	float bonusChance = rmRandFloat(0, 1);
	
	int IDBonusHunt				= rmCreateObjectDef("bonus player hunt");
	
	if(bonusChance < 0.5)   
		rmAddObjectDefItem		(IDBonusHunt, "elephant", 2, 2.0);
	else if(bonusChance < 0.75)
		rmAddObjectDefItem		(IDBonusHunt, "giraffe", rmRandInt(3,4), 3.0);
	else
	rmAddObjectDefItem			(IDBonusHunt, "hippo", rmRandInt(3, 5), 3.0);
	
	rmSetObjectDefMinDistance	(IDBonusHunt, 80);
	rmSetObjectDefMaxDistance	(IDBonusHunt, 100);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidStartingTCFar);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidEdge);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidSettlement);
	
	int numCrane = rmRandInt(6,8);
	
	int IDFarCrane				= rmCreateObjectDef("far crane");
	rmAddObjectDefItem			(IDFarCrane, "crowned crane", numCrane, 3);
	rmSetObjectDefMinDistance	(IDFarCrane, 60);
	rmSetObjectDefMaxDistance	(IDFarCrane, 120);
	rmAddObjectDefConstraint	(IDFarCrane, nearShore);
	rmAddObjectDefConstraint	(IDFarCrane, AvoidStartingTCFar);
	rmAddObjectDefConstraint	(IDFarCrane, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDFarCrane, AvoidHunt);
	
	int IDFarCrocs				= rmCreateObjectDef("far crocs");
	rmAddObjectDefItem			(IDFarCrocs, "crocodile", rmRandInt(1,2), 2);
	rmSetObjectDefMinDistance	(IDFarCrocs, 60);
	rmSetObjectDefMaxDistance	(IDFarCrocs, 120);
	rmAddObjectDefConstraint	(IDFarCrocs, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarCrocs, nearShore);
	rmAddObjectDefConstraint	(IDFarCrocs, AvoidStartingTCFar);
	rmAddObjectDefConstraint	(IDFarCrocs, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDFarCrocs, AvoidPred);
	
	bonusChance = rmRandFloat(0, 1);
	
	int IDCenterHunt			= rmCreateObjectDef("center hunt 1");
	
	if(bonusChance<0.5)   
		rmAddObjectDefItem(IDCenterHunt, "elephant", 2, 2.0);
	else if(bonusChance<0.75) {
		rmAddObjectDefItem(IDCenterHunt, "water buffalo", rmRandInt(5,6), 4.0);
		if(rmRandFloat(0,1)<0.5)      
			rmAddObjectDefItem(IDCenterHunt, "zebra", rmRandInt(2,4), 4.0);
	} else
		rmAddObjectDefItem(IDCenterHunt, "gazelle", rmRandInt(6,9), 4.0);
	
	rmSetObjectDefMinDistance	(IDCenterHunt, 80);
	rmSetObjectDefMaxDistance	(IDCenterHunt, 110);
	rmAddObjectDefConstraint	(IDCenterHunt, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDCenterHunt, nearShore);
	rmAddObjectDefConstraint	(IDCenterHunt, AvoidPlayerFar);
	rmAddObjectDefConstraint	(IDCenterHunt, AvoidHunt);
	
	bonusChance = rmRandFloat(0, 1);
	
	int IDCenterHunt2			= rmCreateObjectDef("center hunt 2");
	
	if(bonusChance<0.5)   
		rmAddObjectDefItem		(IDCenterHunt2, "hippo", 3, 2.0);
	else if(bonusChance<0.75)
		{
			rmAddObjectDefItem	(IDCenterHunt2, "zebra", rmRandInt(4,6), 3.0);
			if(rmRandFloat(0,1)<0.5)      
			rmAddObjectDefItem	(IDCenterHunt2, "giraffe", rmRandInt(2,4), 4.0);
		}
	else
		rmAddObjectDefItem		(IDCenterHunt2, "rhinocerous", 4, 3.0);
	
	rmSetObjectDefMinDistance	(IDCenterHunt2, 90);
	rmSetObjectDefMaxDistance	(IDCenterHunt2, 130);
	rmAddObjectDefConstraint	(IDCenterHunt2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDCenterHunt2, AvoidHunt);
	rmAddObjectDefConstraint	(IDCenterHunt2, AvoidAll);
	rmAddObjectDefConstraint	(IDCenterHunt2, AvoidPlayerFar);
	
	int IDPredator				= rmCreateObjectDef("far pred");
	rmAddObjectDefItem			(IDPredator, "lion", rmRandInt(2,3), 3);
	rmSetObjectDefMinDistance	(IDPredator, 60);
	rmSetObjectDefMaxDistance	(IDPredator, 120);
	rmAddObjectDefConstraint	(IDPredator, AvoidPred);
	rmAddObjectDefConstraint	(IDPredator, AvoidEdge);
	rmAddObjectDefConstraint	(IDPredator, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDPredator, AvoidAllFar);
	
	int IDPredator2				= rmCreateObjectDef("far pred2");
	rmAddObjectDefItem			(IDPredator2, "lion", rmRandInt(1,2), 3);
	rmSetObjectDefMinDistance	(IDPredator2, 80);
	rmSetObjectDefMaxDistance	(IDPredator2, 120);
	rmAddObjectDefConstraint	(IDPredator2, AvoidPred);
	rmAddObjectDefConstraint	(IDPredator2, AvoidEdge);
	rmAddObjectDefConstraint	(IDPredator2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDPredator2, AvoidAllFar);
	
	int IDRelic					= rmCreateObjectDef("relics");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0);
	rmSetObjectDefMinDistance	(IDRelic, 0);
	rmSetObjectDefMaxDistance	(IDRelic, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRelic, AvoidRelic);
	rmAddObjectDefConstraint	(IDRelic, AvoidCore);
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableLand);
	
	int IDBird					= rmCreateObjectDef("birds");
	rmAddObjectDefItem			(IDBird, "vulture", 1, 0);
	rmSetObjectDefMinDistance	(IDBird, 0);
	rmSetObjectDefMaxDistance	(IDBird, rmXFractionToMeters(0.5));
	
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidSettlementShort);
	
	int IDRandomPalm			= rmCreateObjectDef("random palm");
	rmAddObjectDefItem			(IDRandomPalm, "palm", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomPalm, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomPalm, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomPalm, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomPalm, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomPalm, AvoidSettlementShort);
	
	if(cMapSize == 2) {
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantGoldID, AvoidGoldFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdge);
		rmAddObjectDefConstraint(giantGoldID, AvoidCore);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLand);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance = rmRandFloat(0,1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntableID, "hippo", 3, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntableID, "zebra", rmRandInt(5,6), 3.0);
			if(rmRandFloat(0,1)<0.5) {
				rmAddObjectDefItem(giantHuntableID, "giraffe", rmRandInt(4,5), 4.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntableID, "rhinocerous", 4, 3.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.29));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.33));
		rmAddObjectDefConstraint(giantHuntableID, AvoidHunt);
		rmAddObjectDefConstraint(giantHuntableID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntableID, AvoidCore);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.5) {
			rmAddObjectDefItem(giantHuntable2ID, "elephant", 2, 2.0);
		} else if(bonusChance<0.75) {
			rmAddObjectDefItem(giantHuntable2ID, "water buffalo", rmRandInt(5,6), 3.0);
			if(rmRandFloat(0,1)<0.5) {
				rmAddObjectDefItem(giantHuntable2ID, "zebra", rmRandInt(3,4), 3.0);
			}
		} else {
			rmAddObjectDefItem(giantHuntable2ID, "gazelle", rmRandInt(6,8), 4.0);
		}
		rmSetObjectDefMinDistance(giantHuntable2ID, rmXFractionToMeters(0.32));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.36));
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidHunt);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidCore);
		rmAddObjectDefConstraint(giantHuntable2ID, nearShore);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidImpassableLand);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.3));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerd);
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidCore);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidEdge);
		rmAddObjectDefConstraint(giantRelixID, AvoidCore);
		rmAddObjectDefConstraint(giantRelixID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, AvoidRelic);
	}
	
	rmSetStatusText("",0.30);
	///PLAYER LOCATIONS
	rmSetTeamSpacingModifier(0.95);
	rmPlacePlayersCircular(0.41, 0.44, rmDegreesToRadians(3.0));
	///AREA DEFINITION
	int IDCenter		= rmCreateArea("center");
	rmSetAreaSize		(IDCenter, 0.01, 0.01);
	rmSetAreaLocation	(IDCenter, 0.5, 0.5);
	rmAddAreaToClass	(IDCenter, classCenter);
	
	rmBuildArea(IDCenter);
	
	for(i = 1; <cNumberPlayers)
	{
		int IDPlayerCore	= rmCreateArea("Player core"+i);
		rmSetAreaSize		(IDPlayerCore, rmAreaTilesToFraction(200), rmAreaTilesToFraction(200));
		rmAddAreaToClass	(IDPlayerCore, classPlayerCore);
		rmSetAreaCoherence	(IDPlayerCore, 1.0);
		rmSetAreaLocPlayer	(IDPlayerCore, i);
	
		rmBuildArea(IDPlayerCore);
	}
	
	int IDShallows						= rmCreateConnection("shallows");
	rmSetConnectionType					(IDShallows, cConnectAreas, false, 1.0);
	rmSetConnectionWidth				(IDShallows, 18, 2);
	rmSetConnectionWarnFailure			(IDShallows, false);
	rmSetConnectionBaseHeight			(IDShallows, 2.0);
	rmSetConnectionHeightBlend			(IDShallows, 2.0);
	rmSetConnectionSmoothDistance		(IDShallows, 3.0);
	rmAddConnectionTerrainReplacement	(IDShallows, "riverSandyA", "SavannahC"); 
	
	int IDExtraShallows					= rmCreateConnection("extra shallows");
	
	if(cNumberPlayers < 5)
		rmSetConnectionType				(IDExtraShallows, cConnectAreas, false, 1.00);
	
	else if(cNumberPlayers < 7) 
		rmSetConnectionType				(IDExtraShallows, cConnectAreas, false, 1.00);
	
	rmSetConnectionWidth				(IDExtraShallows, 16, 2);
	rmSetConnectionWarnFailure			(IDExtraShallows, false); 
	rmSetConnectionBaseHeight			(IDExtraShallows, 2.0);
	rmSetConnectionHeightBlend			(IDExtraShallows, 2.0);
	rmSetConnectionSmoothDistance		(IDExtraShallows, 3.0);
	rmSetConnectionPositionVariance		(IDExtraShallows, -1.0); 
	rmAddConnectionTerrainReplacement	(IDExtraShallows, "riverSandyA", "SavannahC"); 
	rmAddConnectionStartConstraint		(IDExtraShallows, AvoidCore);
	rmAddConnectionEndConstraint		(IDExtraShallows, AvoidCore);

	int IDAllyShallows					= rmCreateConnection("team shallows");
	rmSetConnectionType					(IDAllyShallows, cConnectAllies, false, 1.0);
	rmSetConnectionWarnFailure			(IDAllyShallows, false);
	rmSetConnectionWidth				(IDAllyShallows, 16, 2);
	rmSetConnectionBaseHeight			(IDAllyShallows, 2.0);
	rmSetConnectionHeightBlend			(IDAllyShallows, 2.0);
	rmSetConnectionSmoothDistance		(IDAllyShallows, 3.0);
	rmAddConnectionTerrainReplacement	(IDAllyShallows, "riverSandyA", "SavannahC");
	
	int bonusCount = rmRandInt(3, 4);
	int bonusIsleSize = 2000+(cNumberNonGaiaPlayers*500);
	
	for(i = 0; < bonusCount)
	{
		int IDIsland				= rmCreateArea("bonus island"+i);
		rmSetAreaSize				(IDIsland, rmAreaTilesToFraction(bonusIsleSize*0.9), rmAreaTilesToFraction(bonusIsleSize*1.1));
		rmSetAreaTerrainType		(IDIsland, "SavannahB");
		rmAddAreaTerrainLayer		(IDIsland, "SavannahC", 0, 6); 
		rmSetAreaWarnFailure		(IDIsland, false);
		
		if(rmRandFloat(0.0, 1.0) < 0.80)
			rmAddAreaConstraint		(IDIsland, AvoidBonusIsland);
		
		if (cNumberNonGaiaPlayers < 5) {
			rmAddAreaConstraint			(IDIsland, AvoidEdgeLong);
		} else {
			rmAddAreaConstraint			(IDIsland, AvoidEdgeFar);
		}
		
		rmAddAreaToClass			(IDIsland, classIsland);
		rmAddAreaToClass			(IDIsland, classBonusIsland);
		rmAddAreaConstraint			(IDIsland, AvoidCore);
		rmSetAreaCoherence			(IDIsland, 0.15);
		rmSetAreaSmoothDistance		(IDIsland, 10);
		rmSetAreaHeightBlend		(IDIsland, 2);
		rmSetAreaBaseHeight			(IDIsland, 2.0);
		rmAddConnectionArea			(IDExtraShallows, IDIsland);
		rmAddConnectionArea			(IDShallows, IDIsland);
	}  

	rmBuildAllAreas();
	
	float playerFraction = rmAreaTilesToFraction(3500);
	for(i = 1; < cNumberPlayers)
	{
		int AreaPlayer			= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, AreaPlayer);
		rmSetAreaSize			(AreaPlayer, 1.0, 1.0);
		rmAddAreaToClass		(AreaPlayer, classIsland);
		rmAddAreaToClass		(AreaPlayer, classPlayer);
		rmSetAreaWarnFailure	(AreaPlayer, false);
		rmSetAreaMinBlobs		(AreaPlayer, 1);
		rmSetAreaMaxBlobs		(AreaPlayer, 5);
		rmSetAreaMinBlobDistance(AreaPlayer, 5.0);
		rmSetAreaMaxBlobDistance(AreaPlayer, 10.0);
		rmSetAreaCoherence		(AreaPlayer, 0.6);
		rmSetAreaBaseHeight		(AreaPlayer, 2.0);
		rmSetAreaSmoothDistance	(AreaPlayer, 10);
		rmSetAreaHeightBlend	(AreaPlayer, 2);
		rmAddAreaConstraint		(AreaPlayer, AvoidIsland);
		rmAddAreaConstraint		(AreaPlayer, AvoidBonusIsland);
		rmAddAreaConstraint		(AreaPlayer, AvoidCenter);
		rmSetAreaLocPlayer		(AreaPlayer, i);
		rmAddConnectionArea		(IDExtraShallows, AreaPlayer);
		rmAddConnectionArea		(IDShallows, AreaPlayer);
		rmSetAreaTerrainType	(AreaPlayer, "SavannahB");
		rmAddAreaTerrainLayer	(AreaPlayer, "SavannahC", 0, 12);
	}
	
	rmBuildAllAreas();
	rmBuildConnection(IDAllyShallows);
	rmBuildConnection(IDShallows);
	
	if(cNumberNonGaiaPlayers < 4)
		rmBuildConnection(IDExtraShallows);
	else if(cNumberNonGaiaPlayers < 6)
	{   
		rmBuildConnection(IDExtraShallows);
	}
	
	for(i = 1; <cNumberPlayers*50*mapSizeMultiplier)
	{
		int IDDirtPatch			= rmCreateArea("dirt patch"+i);
		rmSetAreaSize			(IDDirtPatch, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(40*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDDirtPatch, "SavannahA");
		rmSetAreaMinBlobs		(IDDirtPatch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDDirtPatch, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDDirtPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDDirtPatch, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDDirtPatch, 0.0);
		rmAddAreaConstraint		(IDDirtPatch, AvoidImpassableLand);
		rmBuildArea				(IDDirtPatch); 
	}
	
	for(i = 1; <cNumberPlayers*15*mapSizeMultiplier)
	{
		int IDSandPatch			= rmCreateArea("sand patch"+i);
		rmSetAreaSize			(IDSandPatch, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDSandPatch, "SandA");
		rmSetAreaMinBlobs		(IDSandPatch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDSandPatch, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDSandPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDSandPatch, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDSandPatch, 0.0);
		rmAddAreaConstraint		(IDSandPatch, AvoidImpassableLand);
		rmBuildArea				(IDSandPatch);
	} 
	
	int failCount = 0;
	int numTries = 10*cNumberNonGaiaPlayers*mapSizeMultiplier;
	for(i = 0; < numTries)
	{
		int IDElev				= rmCreateArea("elev"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDElev, false); 
		rmAddAreaConstraint		(IDElev, AvoidPlayerCoreShort);
		rmAddAreaConstraint		(IDElev, AvoidImpassableLand);
		
		if(rmRandFloat(0.0, 1.0) < 0.7)
			rmSetAreaTerrainType(IDElev, "SavannahC");
		
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(2.0, 4.0));
		rmSetAreaHeightBlend	(IDElev, 1);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 3);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 40.0);
		rmSetAreaCoherence		(IDElev, 0.0); 
	
		if(rmBuildArea(IDElev)==false)
		{
			failCount++;
			if(failCount == 3)
			break;
		}
		else
			failCount = 0; 
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
		rmSetAreaSize			(AreaNonCorner, 0.7, 0.7);
		rmSetAreaLocation		(AreaNonCorner, 0.5, 0.5);
		rmSetAreaWarnFailure	(AreaNonCorner, false);
		rmAddAreaToClass		(AreaNonCorner, classAvoidCorner);
		rmAddAreaConstraint		(AreaNonCorner, AvoidCornerShort);
		rmSetAreaCoherence		(AreaNonCorner, 1.0);
		
		rmBuildArea(AreaNonCorner);
	}
	
	rmSetStatusText("",0.40);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int AreaSettle = rmAddFairLoc("Settlement", false, true, 65, 90, 40, 20); 
	rmAddFairLocConstraint(AreaSettle, AvoidImpassableLandFar);
	rmAddFairLocConstraint(AreaSettle, AvoidCenterShort);

	if (cNumberNonGaiaPlayers < 3) {
		float SettleFactor = rmRandFloat(0,1);
		
		if (SettleFactor < 0.33) {
			AreaSettle = rmAddFairLoc("Settlement", true, false, 105, 115, 70, 30);
			rmAddFairLocConstraint(AreaSettle, AvoidCenterShort);
		} else if (SettleFactor < 0.66) {
			AreaSettle = rmAddFairLoc("Settlement", true, false, 95, 105, 70, 30);
			rmAddFairLocConstraint(AreaSettle, AvoidCenterShort);
		} else {
			AreaSettle = rmAddFairLoc("Settlement", true, false, 80, 95, 70, 30);
			rmAddFairLocConstraint(AreaSettle, AvoidCenterShort);
		}
	} else if (cNumberNonGaiaPlayers < 5) {
		AreaSettle = rmAddFairLoc("Settlement", true, false, 90, 130, 65, 35);
	} else {
		AreaSettle = rmAddFairLoc("Settlement", true, false, 95, 150, 70, 35);
	}
		
	rmAddFairLocConstraint(AreaSettle, AvoidImpassableLandFar);
	rmAddFairLocConstraint(AreaSettle, AvoidPlayerFar);
	
	
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", false, true, 100, 180, 80, 25);
		rmAddFairLocConstraint(AreaSettle, AvoidImpassableLandFar);

		AreaSettle = rmAddFairLoc("Settlement", true, false,  110, 200, 80, 50); 
		rmAddFairLocConstraint(AreaSettle, AvoidImpassableLandFar);
		rmAddFairLocConstraint(AreaSettle, AvoidPlayerFar);
		rmAddFairLocConstraint(AreaSettle, AvoidCenterShort);
	}
   
	if(rmPlaceFairLocs())
	{
		AreaSettle = rmCreateObjectDef("far settlement");
		rmAddObjectDefItem(AreaSettle, "Settlement", 1, 0.0);
		for(i = 1; < cNumberPlayers)
		{
			for(j = 0; < rmGetNumberFairLocs(i))
				rmPlaceObjectDefAtLoc(AreaSettle, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	rmSetStatusText("",0.50);
	
	///OBJECT PLACEMENT
	rmPlaceObjectDefPerPlayer(IDStartingTowers, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingHunt, false);
	rmPlaceObjectDefPerPlayer(IDStartingHunt2, false);
	rmPlaceObjectDefPerPlayer(IDStartingHerd, true);
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(1,7));
	
	rmPlaceObjectDefPerPlayer(IDMediumGold, false);
	rmPlaceObjectDefPerPlayer(IDMediumHerd, false);
	
	if(rmRandFloat(0.0, 1.0) < 0.5) {
		rmPlaceObjectDefPerPlayer(IDMediumGazelle, false);
	} else if(rmRandFloat(0,1) < 0.2) {
		rmPlaceObjectDefPerPlayer(IDMediumGazelle, false);
		rmPlaceObjectDefPerPlayer(IDMediumZebra, false);
	} else {
		rmPlaceObjectDefPerPlayer(IDMediumZebra, false);
	}
	
	int goldNum = rmRandInt(1, 2);
	int herdNum = rmRandInt(1, 2);
	
	for(i = 1; < cNumberPlayers) {
		rmPlaceObjectDefInArea(IDFarGold, 0, rmAreaID("Player"+i), goldNum);
		rmPlaceObjectDefInArea(IDFarHerd, 0, rmAreaID("Player"+i), herdNum);	
		rmPlaceObjectDefInArea(IDBonusHunt, 0, rmAreaID("Player"+i));	
		rmPlaceObjectDefInArea(IDFarCrane, 0, rmAreaID("Player"+i));
		
		rmPlaceObjectDefInArea(IDRelic, 0, rmAreaID("Player"+i));
	}
	
	rmPlaceObjectDefPerPlayer(IDBonusGold, false);
	rmPlaceObjectDefPerPlayer(IDCenterHunt, false);
	rmPlaceObjectDefPerPlayer(IDCenterHunt2, false);
	rmPlaceObjectDefPerPlayer(IDPredator, false);
	rmPlaceObjectDefPerPlayer(IDPredator2, false, rmRandInt(0,1));
	
	for(i = 1; < cNumberPlayers) {
		rmPlaceObjectDefInArea(IDFarCrocs, 0, rmAreaID("Player"+i));
	}
	
	if (rmRandFloat(0,1) < 0.5) {
		rmPlaceObjectDefPerPlayer(IDBonusGold2, false);
	}
	
	if(cMapSize == 2) {
	rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(2, 4));
   
    rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(2, 3));

    rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, rmRandInt(1, 2));
   
    rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
   
    for(i = 1; <cNumberPlayers)
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	} 
	
	rmPlaceObjectDefPerPlayer(IDBird, false, 2);
	
	rmSetStatusText("",0.60);
	///FORESTS
	failCount = 0;
	
	for (i = 0; <9*cNumberNonGaiaPlayers) {
		int IDForest 		= rmCreateArea("forest"+i, rmAreaID("Player"+i));
		rmSetAreaSize		(IDForest, rmAreaTilesToFraction(60), rmAreaTilesToFraction(100));
		
		if(cMapSize == 2) {
			rmSetAreaSize(IDForest, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		if (rmRandFloat(0,1) < 0.8) {
			rmSetAreaForestType	(IDForest, "savannah forest");
		} else {
			rmSetAreaForestType	(IDForest, "palm forest");
		}
		
		if (rmRandFloat(0,1) < 0.2) {
			rmSetAreaBaseHeight(IDForest, rmRandFloat(2,4));
		}
		
		rmAddAreaToClass	(IDForest, classForest);
		rmAddAreaConstraint	(IDForest, AvoidAll);
		rmAddAreaConstraint	(IDForest, AvoidImpassableLand);
		rmAddAreaConstraint	(IDForest, AvoidForest);
		rmAddAreaConstraint	(IDForest, AvoidStartingTCShort);
		rmAddAreaConstraint	(IDForest, AvoidBonusIsland);
		
		if (rmBuildArea(IDForest) == false) {
			failCount++;
			if (failCount == 3) 
				break;
		}
		failCount = 0;
	}
	
	failCount = 0;
	
	if (cNumberNonGaiaPlayers < 3)
		int forestNum = rmRandInt(2, 3)*cNumberNonGaiaPlayers;
	else 
		forestNum = rmRandInt(3, 4)*cNumberNonGaiaPlayers;	
	
	for (i = 0; < forestNum) {
		int IDCenterForest 		= rmCreateArea("centerforest"+i);
		rmSetAreaSize			(IDCenterForest, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2) {
			rmSetAreaSize		(IDCenterForest, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		if (rmRandFloat(0,1) < 0.8) {
			rmSetAreaForestType	(IDCenterForest, "savannah forest");
		} else {
			rmSetAreaForestType	(IDCenterForest, "palm forest");
		}
		if (rmRandFloat(0,1) < 0.2) {
			rmSetAreaBaseHeight	(IDCenterForest, rmRandFloat(2,4));
		}
		
		rmAddAreaToClass		(IDCenterForest, classForest);
		rmAddAreaConstraint		(IDCenterForest, AvoidAll);
		rmAddAreaConstraint		(IDCenterForest, AvoidSettlementShort);
		rmAddAreaConstraint		(IDCenterForest, AvoidImpassableLand);
		rmAddAreaConstraint		(IDCenterForest, AvoidForest);
		rmAddAreaConstraint		(IDCenterForest, AvoidStartingTCShort);
		rmAddAreaConstraint		(IDCenterForest, AvoidPlayerFar);
		
		if (rmBuildArea(IDCenterForest) == false) {
			failCount++;
			if (failCount == 3) 
				break;
		}
	}
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	rmPlaceObjectDefAtLoc(IDRandomPalm, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	rmSetStatusText("",0.80);
	///BEAUTIFICATION
	int IDBush					= rmCreateObjectDef("big bush patch");
	rmAddObjectDefItem			(IDBush, "bush", 4, 3.0);
	rmSetObjectDefMinDistance	(IDBush, 0.0);
	rmSetObjectDefMaxDistance	(IDBush, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDBush, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDBush, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int IDBushRock				= rmCreateObjectDef("small bush patch");
	rmAddObjectDefItem			(IDBushRock, "bush", 3, 2.0);
	rmAddObjectDefItem			(IDBushRock, "rock sandstone sprite", 1, 2.0);
	rmSetObjectDefMinDistance	(IDBushRock, 0.0);
	rmSetObjectDefMaxDistance	(IDBushRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDBushRock, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDBushRock, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);
	
	int IDRock					= rmCreateObjectDef("rock small");
	rmAddObjectDefItem			(IDRock, "rock sandstone small", 3, 3.0);
	rmAddObjectDefItem			(IDRock, "rock limestone sprite", 4, 4.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);
	
	int IDSkeleton				= rmCreateObjectDef("dead animal");
	rmAddObjectDefItem			(IDSkeleton, "skeleton animal", 1, 0.0);
	rmSetObjectDefMinDistance	(IDSkeleton, 0.0);
	rmSetObjectDefMaxDistance	(IDSkeleton, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSkeleton, AvoidAll);
	rmAddObjectDefConstraint	(IDSkeleton, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDSkeleton, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers); 
	
	int IDSprite				= rmCreateObjectDef("rock sprite");
	rmAddObjectDefItem			(IDSprite, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance	(IDSprite, 0.0);
	rmSetObjectDefMaxDistance	(IDSprite, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSprite, AvoidAll);
	rmAddObjectDefConstraint	(IDSprite, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDSprite, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers); 
	
	int IDLilly					= rmCreateObjectDef("lily pads");
	rmAddObjectDefItem			(IDLilly, "water lilly", 1, 0.0);
	rmSetObjectDefMinDistance	(IDLilly, 0.0);
	rmSetObjectDefMaxDistance	(IDLilly, 600);
	rmAddObjectDefConstraint	(IDLilly, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDLilly, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers); 
	
	int IDLillyGroup			= rmCreateObjectDef("lily2 pad groups");
	rmAddObjectDefItem			(IDLillyGroup, "water lilly", 4, 4.0);
	rmSetObjectDefMinDistance	(IDLillyGroup, 0.0);
	rmSetObjectDefMaxDistance	(IDLillyGroup, 600);
	rmAddObjectDefConstraint	(IDLillyGroup, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDLillyGroup, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers); 
	
	int IDDecor					= rmCreateObjectDef("water decorations");
	rmAddObjectDefItem			(IDDecor, "water decoration", 3, 6.0);
	rmSetObjectDefMinDistance	(IDDecor, 0.0);
	rmSetObjectDefMaxDistance	(IDDecor, 600);
	rmAddObjectDefConstraint	(IDDecor, AvoidAll);
	rmPlaceObjectDefAtLoc		(IDDecor, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",1.00);
}
/*Mediterranean
**Made by Hagrit (Original concept Ensemble Studios)
*/
void main(void)
{
	///INITIALIZE MAP
	rmSetStatusText("",0.01);

	// Set size.
	int mapSizeMultiplier = 1;
   
	int playerTiles = 7500;
	if(cMapSize == 1)
	{
		playerTiles = 9750;
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

	rmTerrainInitialize("GrassDirt25");
	
	rmSetStatusText("",0.10);

	///CLASSES
	int classPlayer		= rmDefineClass("player");
	int classStartingTC	= rmDefineClass("starting tc");
	int classCenter		= rmDefineClass("center");
	int classForest		= rmDefineClass("forest");
	int classShark		= rmDefineClass("shark");
	int classIsland		= rmDefineClass("island");
	int classCorner		= rmDefineClass("corner");
	int classAvoidCorner= rmDefineClass("avoid corner");
	
	rmSetStatusText("",0.15);

	///CONSTRAINTS
	int AvoidEdge		= rmCreateBoxConstraint ("CB0", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2));
	int AvoidEdgeMed 	= rmCreateBoxConstraint ("CB1", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int AvoidEdgeFar 	= rmCreateBoxConstraint ("CB2", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20));
	
	int AvoidTower		= rmCreateTypeDistanceConstraint ("TD0", "tower", 25);
	int AvoidAll		= rmCreateTypeDistanceConstraint ("TD1", "all", 6);
	int AvoidGold		= rmCreateTypeDistanceConstraint ("TD2", "gold", 35);
	int AvoidFish		= rmCreateTypeDistanceConstraint ("TD3", "fish", 18);
	int AvoidHunt		= rmCreateTypeDistanceConstraint ("TD4", "huntable", 25);
	int AvoidSettlement	= rmCreateTypeDistanceConstraint ("TD5", "abstractSettlement", 22);
	int AvoidHerd		= rmCreateTypeDistanceConstraint ("TD6", "herdable", 35);
	int AvoidFishFar	= rmCreateTypeDistanceConstraint ("TD7", "fish", 24);
	int AvoidPredator	= rmCreateTypeDistanceConstraint ("TD8", "animalPredator", 30);
	int AvoidRelic		= rmCreateTypeDistanceConstraint ("TD9", "relic", 70);
	int AvoidAllFar		= rmCreateTypeDistanceConstraint ("TD10", "all", 8);
	int AvoidBerry		= rmCreateTypeDistanceConstraint ("TD11", "berry bush", 20);
	int AvoidTowerFar	= rmCreateTypeDistanceConstraint ("TD12", "tower", 28);
	
	int AvoidPlayerShort	= rmCreateClassDistanceConstraint ("CD0", classPlayer, 5.0);
	int AvoidStartingTC 	= rmCreateClassDistanceConstraint ("CD1", classStartingTC, 30.0);
	int AvoidTCShort		= rmCreateClassDistanceConstraint ("CD2", classStartingTC, 20.0);
	int AvoidForest		 	= rmCreateClassDistanceConstraint ("CD3", classForest, 25.0);
	int AvoidShark		 	= rmCreateClassDistanceConstraint ("CD4", classShark, 20.0);
	int AvoidIsland		 	= rmCreateClassDistanceConstraint ("CD5", classIsland, 2.0);
	int AvoidCorner			= rmCreateClassDistanceConstraint ("CD6", classCorner, 20.0);
	int AvoidCornerShort	= rmCreateClassDistanceConstraint ("CD7", classCorner, 1.0);
	int InCorner			= rmCreateClassDistanceConstraint ("CD8", classAvoidCorner, 1.0);
	int AvoidStartingTCFar	= rmCreateClassDistanceConstraint ("CD9", classStartingTC, 50.0);
	
	int AvoidImpassableLandShort= rmCreateTerrainDistanceConstraint ("CLD0", "land", false, 8);
	int AvoidImpassableLand		= rmCreateTerrainDistanceConstraint ("CLD1", "land", false, 10);
	int AvoidImpassableLandMed	= rmCreateTerrainDistanceConstraint ("CLD2", "land", false, 15);
	int AvoidImpassableLandFar	= rmCreateTerrainDistanceConstraint ("CLD3", "land", false, 24);
	
	int NearShore	= rmCreateTerrainMaxDistanceConstraint("TMD0", "land", true, 15.0);
	int FarShore	= rmCreateTerrainDistanceConstraint("CTD0", "land", true, 10.0);
	int SharkLand	= rmCreateTerrainDistanceConstraint("CTD1", "land", true, 20.0);
	
	rmSetStatusText("",0.25);

	///OBJECT DEFINITION
	int IDStartingSettlement 	= rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem			(IDStartingSettlement, "Settlement level 1", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStartingSettlement, 0.0);
	rmSetObjectDefMaxDistance	(IDStartingSettlement, 0.0);
	rmAddObjectDefToClass		(IDStartingSettlement, classStartingTC);
	
	int IDStartingTower			= rmCreateObjectDef("starting tower");
	rmAddObjectDefItem			(IDStartingTower, "tower", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingTower, 22);
	rmSetObjectDefMaxDistance	(IDStartingTower, 27);
	rmAddObjectDefConstraint	(IDStartingTower, AvoidTower);
	rmAddObjectDefConstraint	(IDStartingTower, AvoidImpassableLand);
	
	int GoldDistance = rmRandFloat(21,25);
	
	int IDStartingGold			= rmCreateObjectDef("starting gold");
	rmAddObjectDefItem			(IDStartingGold, "gold mine small", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidImpassableLandMed);
	
	int IDStartingFood			= rmCreateObjectDef("starting food");
	
	if (rmRandFloat(0,1) < 0.8) 
		rmAddObjectDefItem		(IDStartingFood, "chicken", rmRandInt(5,9), 4);
	else 
		rmAddObjectDefItem		(IDStartingFood, "berry bush",rmRandInt(4,8), 5);
	
	rmSetObjectDefMinDistance	(IDStartingFood, 20);
	rmSetObjectDefMaxDistance	(IDStartingFood, 26);
	rmAddObjectDefConstraint	(IDStartingFood, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingFood, AvoidImpassableLandMed);
	
	int BoarDistance = rmRandInt(24,30);
	
	int IDStartingHunt			= rmCreateObjectDef("starting boar");
	
	if (rmRandFloat(0,1) < 0.5) {
		rmAddObjectDefItem		(IDStartingHunt, "aurochs", rmRandInt(1,2), 3);
	} else 
		rmAddObjectDefItem		(IDStartingHunt, "boar", rmRandInt(1,3), 4);
	
	rmSetObjectDefMinDistance	(IDStartingHunt, BoarDistance);
	rmSetObjectDefMaxDistance	(IDStartingHunt, BoarDistance);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidImpassableLandMed);
	
	int IDStartingPigs			= rmCreateObjectDef("starting pigs");
	rmAddObjectDefItem			(IDStartingPigs, "pig", rmRandInt(2,4), 3);
	rmSetObjectDefMinDistance	(IDStartingPigs, 20);
	rmSetObjectDefMaxDistance	(IDStartingPigs, 25);
	rmAddObjectDefConstraint	(IDStartingPigs, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingPigs, AvoidImpassableLandMed);
	
	int IDStartingFish			= rmCreateObjectDef("starting fish");
	rmAddObjectDefItem			(IDStartingFish, "fish - mahi", 3, 9);
	rmSetObjectDefMinDistance	(IDStartingFish, 40);
	rmSetObjectDefMaxDistance	(IDStartingFish, 75);
	rmAddObjectDefConstraint	(IDStartingFish, NearShore);
	rmAddObjectDefConstraint	(IDStartingFish, FarShore);
	rmAddObjectDefConstraint	(IDStartingFish, AvoidFish);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "oak tree", 1, 0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15);
	
	//medium
	
	int IDMediumGold			= rmCreateObjectDef("medium gold");
	rmAddObjectDefItem			(IDMediumGold, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDMediumGold, 50);
	rmSetObjectDefMaxDistance	(IDMediumGold, 65);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidPlayerShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCornerShort);
	
	int IDMediumHunt			= rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem			(IDMediumHunt, "deer", rmRandInt(5,9), 5);
	rmSetObjectDefMinDistance	(IDMediumHunt, 60);
	rmSetObjectDefMaxDistance	(IDMediumHunt, 70);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidEdgeMed);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidPlayerShort);
	
	int IDMediumPigs			= rmCreateObjectDef("medium pigs");
	rmAddObjectDefItem			(IDMediumPigs, "pig", 2, 2);
	rmSetObjectDefMinDistance	(IDMediumPigs, 48);
	rmSetObjectDefMaxDistance	(IDMediumPigs, 60);
	rmAddObjectDefConstraint	(IDMediumPigs, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDMediumPigs, AvoidEdgeMed);
	rmAddObjectDefConstraint	(IDMediumPigs, AvoidHerd);
	rmAddObjectDefConstraint	(IDMediumPigs, AvoidPlayerShort);
	
	//far
	int IDFarFish				= rmCreateObjectDef("far fish");
	rmAddObjectDefItem			(IDFarFish, "fish - mahi", 3, 9);
	rmSetObjectDefMinDistance	(IDFarFish, rmXFractionToMeters(0.0));
	rmSetObjectDefMaxDistance	(IDFarFish, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDFarFish, AvoidFishFar);
	rmAddObjectDefConstraint	(IDFarFish, FarShore);
	
	int IDFarFish2				= rmCreateObjectDef("far fish2");
	rmAddObjectDefItem			(IDFarFish2, "fish - perch", 2, 7);
	rmSetObjectDefMinDistance	(IDFarFish2, rmXFractionToMeters(0.0));
	rmSetObjectDefMaxDistance	(IDFarFish2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDFarFish2, AvoidFish);
	rmAddObjectDefConstraint	(IDFarFish2, FarShore);
	
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold, 75);
	rmSetObjectDefMaxDistance	(IDFarGold, 90);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold, AvoidPlayerShort);
	
	int IDFarGold2				= rmCreateObjectDef("far gold2");
	rmAddObjectDefItem			(IDFarGold2, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold2, 90);
	rmSetObjectDefMaxDistance	(IDFarGold2, 100);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidPlayerShort);
	
	int IDFarGold3				= rmCreateObjectDef("far gold3");
	rmAddObjectDefItem			(IDFarGold3, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold3, 100);
	rmSetObjectDefMaxDistance	(IDFarGold3, 110);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidPlayerShort);
	
	if (cNumberNonGaiaPlayers < 3) {
		rmAddObjectDefConstraint	(IDFarGold2, AvoidCornerShort);
	}
	
	int IDFarBerry				= rmCreateObjectDef("far berry");
	rmAddObjectDefItem			(IDFarBerry, "berry bush", rmRandInt(5,10), 5);
	rmSetObjectDefMinDistance	(IDFarBerry, 70);
	rmSetObjectDefMaxDistance	(IDFarBerry, 130);
	rmAddObjectDefConstraint	(IDFarBerry, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarBerry, AvoidAll);
	rmAddObjectDefConstraint	(IDFarBerry, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDFarBerry, AvoidBerry);
	rmAddObjectDefConstraint	(IDFarBerry, AvoidPlayerShort);
	
	int IDFarHunt				= rmCreateObjectDef("far hunt");
	
	if (rmRandFloat(0,1) < 0.5) {
		rmAddObjectDefItem		(IDFarHunt, "boar", rmRandInt(2,4), 4);
	} else 
		rmAddObjectDefItem		(IDFarHunt, "Aurochs", rmRandInt(1,3), 3);
	
	rmSetObjectDefMinDistance	(IDFarHunt, 80);
	rmSetObjectDefMaxDistance	(IDFarHunt, 120);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidEdgeMed);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidPlayerShort);
	
	int IDFarPigs				= rmCreateObjectDef("far pigs");
	rmAddObjectDefItem			(IDFarPigs, "pig", 2, 2);
	rmSetObjectDefMinDistance	(IDFarPigs, 75);
	rmSetObjectDefMaxDistance	(IDFarPigs, 130);
	rmAddObjectDefConstraint	(IDFarPigs, AvoidHerd);
	rmAddObjectDefConstraint	(IDFarPigs, AvoidEdgeMed);
	rmAddObjectDefConstraint	(IDFarPigs, AvoidAll);
	rmAddObjectDefConstraint	(IDFarPigs, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarPigs, AvoidPlayerShort);
	
	int IDFarPred				= rmCreateObjectDef("far bear");
	rmAddObjectDefItem			(IDFarPred, "bear", rmRandInt(1,2), 3);
	rmSetObjectDefMinDistance	(IDFarPred, 50);
	rmSetObjectDefMaxDistance	(IDFarPred, 100);
	rmAddObjectDefConstraint	(IDFarPred, AvoidAll);
	rmAddObjectDefConstraint	(IDFarPred, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarPred, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPred, AvoidPlayerShort);
	
	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRelic, 60);
	rmSetObjectDefMaxDistance	(IDRelic, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRelic, AvoidEdge);
	rmAddObjectDefConstraint	(IDRelic, AvoidAll);
	rmAddObjectDefConstraint	(IDRelic, AvoidPlayerShort);
	rmAddObjectDefConstraint	(IDRelic, AvoidRelic);
	
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "oak tree", 1, 0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	
	//giant
	if(cMapSize == 2) {
		int giantGoldID				= rmCreateObjectDef("giant gold");
		rmAddObjectDefItem			(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance	(giantGoldID, 120);
		rmSetObjectDefMaxDistance	(giantGoldID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint	(giantGoldID, AvoidSettlement);
		rmAddObjectDefConstraint	(giantGoldID, AvoidEdge);
		rmAddObjectDefConstraint	(giantGoldID, AvoidGold);
		rmAddObjectDefConstraint	(giantGoldID, AvoidImpassableLand);
		rmAddObjectDefConstraint	(giantGoldID, AvoidStartingTC);
		
		float bonusChance = rmRandInt(0,100);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		if(bonusChance<50) {
			rmAddObjectDefItem(giantHuntableID, "boar", rmRandInt(2,3), 4.0);
		} else if(bonusChance<80) {
			rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(5,10), 6.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "aurochs", rmRandInt(1,3), 4.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, 80);
		rmSetObjectDefMaxDistance(giantHuntableID, 160);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHunt);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, AvoidStartingTC);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "pig", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, 100);
		rmSetObjectDefMaxDistance(giantHerdableID, 220);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHerdableID, AvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerd);
		rmAddObjectDefConstraint(giantHerdableID, AvoidStartingTC);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidEdge);
		rmAddObjectDefConstraint(giantRelixID, AvoidSettlement);
		rmAddObjectDefConstraint(giantRelixID, AvoidStartingTC);
		rmAddObjectDefConstraint(giantRelixID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, AvoidRelic);
	}
	
	rmSetStatusText("",0.40);
	///PLAYER LOCATION
	rmPlacePlayersCircular(0.35, 0.40, 0.001);
	rmSetTeamSpacingModifier(0.80);
	
	rmSetStatusText("",0.50);
	///AREA DEFINITION
	for (i=1;<cNumberPlayers) {
		int IDPlayerArea 		= rmCreateArea("player area"+i);
		rmSetPlayerArea			(i, IDPlayerArea);
		rmSetAreaLocPlayer		(IDPlayerArea, i);
		rmAddAreaToClass		(IDPlayerArea, classPlayer);
		rmSetAreaSize			(IDPlayerArea, rmAreaTilesToFraction(1400*mapSizeMultiplier), rmAreaTilesToFraction(1600*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDPlayerArea, "GrassDirt25");
		rmAddAreaTerrainLayer	(IDPlayerArea, "GrassA", 0, 4);
		rmSetAreaCoherence		(IDPlayerArea, 0.8);
		rmSetAreaMinBlobs		(IDPlayerArea, 1.0*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDPlayerArea, 5.0*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDPlayerArea, 10.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDPlayerArea, 20.0*mapSizeMultiplier);
	}
	
	rmBuildAllAreas();
	
	for (i=1; <cNumberPlayers) {
		int IDPlayerInner		= rmCreateArea("player inner"+i);
		rmSetPlayerArea			(i, IDPlayerInner);
		rmSetAreaLocPlayer		(IDPlayerInner, i);
		rmSetAreaSize			(IDPlayerInner, rmAreaTilesToFraction(300*mapSizeMultiplier), rmAreaTilesToFraction(600*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDPlayerInner, "GrassDirt50");
		rmSetAreaCoherence		(IDPlayerInner, 0.0);
		rmSetAreaMinBlobs		(IDPlayerInner, 4);
		rmSetAreaMaxBlobs		(IDPlayerInner, 10);
		rmSetAreaMinBlobDistance(IDPlayerInner, 30);
		rmSetAreaMaxBlobDistance(IDPlayerInner, 40);
		
		rmBuildArea(IDPlayerInner);
	}
	
	if (cNumberNonGaiaPlayers < 3) 
	{
		int IDCenter				= rmCreateArea("Center sea");
		rmSetAreaLocation			(IDCenter, 0.5, 0.5);
		rmSetAreaWaterType			(IDCenter, "mediterranean sea");
		
		if (cNumberNonGaiaPlayers < 3)
		{	
			rmSetAreaSize				(IDCenter, 0.23, 0.23);
		}
		else
		{
			rmSetAreaSize				(IDCenter, 0.24, 0.25);
		}			
		
		rmSetAreaCoherence			(IDCenter, 0.8);
		rmSetAreaSmoothDistance 	(IDCenter, 25);
		rmAddAreaConstraint			(IDCenter, AvoidPlayerShort);
		rmAddAreaConstraint			(IDCenter, AvoidEdgeFar);
		rmSetAreaMinBlobs			(IDCenter, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs			(IDCenter, 4*mapSizeMultiplier);
		rmSetAreaMinBlobDistance	(IDCenter, 5*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance	(IDCenter, 20*mapSizeMultiplier);
		rmBuildArea					(IDCenter);
		
	} 
	else 
	{
		IDCenter					= rmCreateArea("Center sea");
		rmSetAreaLocation			(IDCenter, 0.5, 0.5);
		rmSetAreaWaterType			(IDCenter, "mediterranean sea");
		rmSetAreaSize				(IDCenter, 0.25, 0.26);
		rmSetAreaCoherence			(IDCenter, 0.8);
		rmSetAreaSmoothDistance 	(IDCenter, 25);
		rmAddAreaConstraint			(IDCenter, AvoidPlayerShort);
		rmSetAreaMinBlobs			(IDCenter, 2*mapSizeMultiplier);
		rmSetAreaMaxBlobs			(IDCenter, 8*mapSizeMultiplier);
		rmSetAreaMinBlobDistance	(IDCenter, 20*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance	(IDCenter, 40*mapSizeMultiplier);
		rmBuildArea(IDCenter);
	}
		
	
	if (cNumberNonGaiaPlayers > 3) 
	{
		if (rmRandFloat(0,1) < 0.5) 
		{
			int IDCenterIsland		= rmCreateArea("center island");
			rmSetAreaLocation		(IDCenterIsland, 0.5, 0.5);
			rmSetAreaSize			(IDCenterIsland, 0.005, 0.005);
			rmSetAreaBaseHeight		(IDCenterIsland, rmRandInt(2,4));
			rmSetAreaHeightBlend	(IDCenterIsland, 2);
			rmSetAreaCoherence		(IDCenterIsland, 0.5);
			rmAddAreaToClass		(IDCenterIsland, classIsland);
			rmSetAreaTerrainType	(IDCenterIsland, "shorelinemediterraneanb");
			
			rmBuildArea(IDCenterIsland);
			
			int IDBaboon				= rmCreateObjectDef("Center stuff");
			rmAddObjectDefItem			(IDBaboon, "baboon", rmRandInt(1,2), 8.0);
			rmAddObjectDefItem			(IDBaboon, "palm", rmRandInt(1,2), 8.0);
			rmAddObjectDefItem			(IDBaboon, "gold mine", 1, 8.0);
			rmSetObjectDefMinDistance	(IDBaboon, 0);
			rmSetObjectDefMaxDistance	(IDBaboon, 0);
			rmPlaceObjectDefAtLoc		(IDBaboon, 0, 0.5, 0.5);
		}
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
	
	int PatchCount = 5*cNumberNonGaiaPlayers;
	
	for (i=0; <PatchCount*mapSizeMultiplier) {
		int IDDirtPatch				= rmCreateArea("dirt patch A"+i);
		rmSetAreaSize				(IDDirtPatch, rmAreaTilesToFraction(30*mapSizeMultiplier), rmAreaTilesToFraction(75*mapSizeMultiplier));
		rmSetAreaCoherence			(IDDirtPatch, 0.5);
		rmSetAreaTerrainType		(IDDirtPatch, "GrassDirt50");
		rmSetAreaMinBlobs			(IDDirtPatch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs			(IDDirtPatch, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance	(IDDirtPatch, 3*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance	(IDDirtPatch, 10*mapSizeMultiplier);
		rmAddAreaConstraint			(IDDirtPatch, AvoidImpassableLand);
		rmAddAreaConstraint			(IDDirtPatch, AvoidIsland);
		
		rmBuildArea					(IDDirtPatch);
	}
	
	for (i=0; <cNumberNonGaiaPlayers*6*mapSizeMultiplier) {
		int IDGrassPatch 		= rmCreateArea("grass patch"+i);
		rmSetAreaSize			(IDGrassPatch, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(30*mapSizeMultiplier));
		rmSetAreaCoherence		(IDGrassPatch, 0.5);
		rmSetAreaTerrainType	(IDGrassPatch, "GrassB");
		rmAddAreaConstraint		(IDGrassPatch, AvoidImpassableLand);
		rmAddAreaConstraint		(IDGrassPatch, AvoidIsland);
		
		rmBuildArea(IDGrassPatch);
		
		int IDFlowers				= rmCreateObjectDef("flowers"+i);
		rmAddObjectDefItem			(IDFlowers, "flowers", rmRandInt(1,6), 4);
		rmAddObjectDefItem			(IDFlowers, "grass", rmRandInt(2,4), 5);
		rmSetObjectDefMinDistance	(IDFlowers, 0.0);
		rmSetObjectDefMaxDistance	(IDFlowers, 0.0);
		rmPlaceObjectDefInArea		(IDFlowers, 0, rmAreaID("grass patch"+i), 1*mapSizeMultiplier);
	}
	
	for (i=1; <cNumberNonGaiaPlayers*6*mapSizeMultiplier) {
		int IDElev				= rmCreateArea("elev"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaBaseHeight		(IDElev, rmRandInt(3,4));
		rmSetAreaHeightBlend	(IDElev, 1);
		rmAddAreaConstraint		(IDElev, AvoidImpassableLand);
		rmAddAreaConstraint		(IDElev, AvoidIsland);
		
		rmBuildArea(IDElev);
	}
	
	rmSetStatusText("",0.60);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer (IDStartingSettlement, true);
	rmPlaceObjectDefPerPlayer (IDStartingTower, true, 4);
	
	int SettleDistance1 = rmRandInt(65, 80);
	int SettleDistance2 = rmRandInt(70, 85);
	
	int AreaSettle	= rmAddFairLoc("Settlement", false, true,  65, SettleDistance1, 40, 20);
	rmAddFairLocConstraint	(AreaSettle, AvoidImpassableLandFar);
	rmAddFairLocConstraint	(AreaSettle, AvoidTowerFar);
	
	if (cNumberNonGaiaPlayers < 4) {
	if(rmRandFloat(0,1)<0.5) 
		AreaSettle = rmAddFairLoc("Settlement", true, false, 95, 120, 85, 20);
	else
		AreaSettle = rmAddFairLoc("Settlement", false, true,  65, 85, 70, 25);
	} else 
	AreaSettle = rmAddFairLoc("Settlement", true, false, 75, 100, 65, 35);	
	
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", false, false,  160, 230, 75, 25);		
		rmAddFairLocConstraint	(AreaSettle, AvoidImpassableLandFar);
	}
	
	rmAddFairLocConstraint	(AreaSettle, AvoidImpassableLandFar);
	rmAddFairLocConstraint	(AreaSettle, AvoidTowerFar);
	
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
	
	rmResetFairLocs();
	/*
	if (rmRandFloat(0,1) < 0.2) 
	{
		int AreaGold	= rmAddFairLoc("gold mine", false, true,  55, 65, 35, 8);
		rmAddFairLocConstraint	(AreaGold, AvoidImpassableLandFar);
		rmAddFairLocConstraint	(AreaGold, AvoidSettlement);
		rmAddFairLocConstraint	(AreaGold, AvoidTowerFar);
	} 
	else
	{		
		AreaGold	= rmAddFairLoc("gold mine", true, false,  60, 75, 35, 8);
	}
	
	rmAddFairLocConstraint	(AreaGold, AvoidImpassableLandFar);
	rmAddFairLocConstraint	(AreaGold, AvoidSettlement);
	rmAddFairLocConstraint	(AreaGold, AvoidTowerFar);
	rmAddFairLocConstraint	(AreaGold, AvoidPlayerShort);
	
	AreaGold	= rmAddFairLoc("gold mine", true, false,  105, 120, 40, 8);
	rmAddFairLocConstraint	(AreaGold, AvoidImpassableLandFar);
	rmAddFairLocConstraint	(AreaGold, AvoidSettlement);
	rmAddFairLocConstraint	(AreaGold, AvoidTowerFar);
	rmAddFairLocConstraint	(AreaGold, AvoidPlayerShort);
	
	AreaGold	= rmAddFairLoc("gold mine", true, false,  90, 110, 40, 8);
	rmAddFairLocConstraint	(AreaGold, AvoidImpassableLandFar);
	rmAddFairLocConstraint	(AreaGold, AvoidSettlement);
	rmAddFairLocConstraint	(AreaGold, AvoidTowerFar);
	rmAddFairLocConstraint	(AreaGold, AvoidPlayerShort);
	
	if (rmRandFloat(0,1) < 0.5) 
	{
		AreaGold	= rmAddFairLoc("gold mine", true, false,  110, 125, 40, 8);
		rmAddFairLocConstraint	(AreaGold, AvoidImpassableLandFar);
		rmAddFairLocConstraint	(AreaGold, AvoidSettlement);
		rmAddFairLocConstraint	(AreaGold, AvoidTowerFar);
		rmAddFairLocConstraint	(AreaGold, AvoidPlayerShort);
	}
	
	if(rmPlaceFairLocs())
	{
		AreaGold = rmCreateObjectDef("medium gold mine");
		rmAddObjectDefItem(AreaGold, "gold mine", 1, 0.0);
		for(i = 1; < cNumberPlayers)
		{
			for(j = 0; < rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(AreaGold, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	rmResetFairLocs(); */
	
	rmSetStatusText("",0.70);
	///OBJECT PLACEMENT
	
	rmPlaceObjectDefPerPlayer (IDStartingGold, false);
	rmPlaceObjectDefPerPlayer (IDStartingFood, false);
	rmPlaceObjectDefPerPlayer (IDStartingHunt, false);
	rmPlaceObjectDefPerPlayer (IDStartingPigs, true);
	rmPlaceObjectDefPerPlayer (IDStartingFish, false, rmRandInt(2,3));
	rmPlaceObjectDefPerPlayer (IDStragglerTree, false, rmRandInt(2,7));
	
	rmPlaceObjectDefPerPlayer (IDMediumGold, false);
	rmPlaceObjectDefPerPlayer (IDMediumHunt, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer (IDMediumPigs, false, 2);
	
	rmPlaceObjectDefPerPlayer (IDFarFish, false, 2*mapSizeMultiplier);
	rmPlaceObjectDefPerPlayer (IDFarFish2, false, 1*mapSizeMultiplier);
	rmPlaceObjectDefPerPlayer (IDFarGold, false);
	rmPlaceObjectDefPerPlayer (IDFarGold2, false);
	rmPlaceObjectDefPerPlayer (IDFarGold3, false, rmRandInt(0, 1));
	rmPlaceObjectDefPerPlayer (IDFarPigs, false, 3);
	rmPlaceObjectDefPerPlayer (IDFarHunt, false, 1);
	rmPlaceObjectDefPerPlayer (IDFarBerry, false, rmRandInt(1,2));
	
	rmPlaceObjectDefPerPlayer (IDRelic, false, 1*mapSizeMultiplier);
	
	
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(2, 4));
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 3));
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(2, 3));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	
	rmSetStatusText("",0.80);
	///FORESTS
	int failCount = 0;
	int numTries = 9*cNumberNonGaiaPlayers;
	
	if (cMapSize == 2) {
		numTries = 15*cNumberNonGaiaPlayers;
	}
	
	for (i=1; < numTries) {
		int IDForest		= rmCreateArea("forest"+i);
		
		if (rmRandFloat(0,1) < 0.25) {
			rmSetAreaForestType	(IDForest, "pine forest");
		} else 
		rmSetAreaForestType	(IDForest, "oak forest");
		
		rmSetAreaSize		(IDForest, rmAreaTilesToFraction(70*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmAddAreaToClass	(IDForest, classForest);
		rmAddAreaConstraint	(IDForest, AvoidAllFar);
		rmAddAreaConstraint	(IDForest, AvoidImpassableLandShort);
		rmAddAreaConstraint	(IDForest, AvoidForest);
		rmAddAreaConstraint	(IDForest, AvoidTCShort);
		
		if (rmBuildArea(IDForest) == false ) {
			failCount++;
			if (failCount == 3) {
				break;
			}
		} else {
			failCount = 0;
		}
	}
	rmPlaceObjectDefAtLoc (IDRandomTree, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	
	rmSetStatusText("",0.90);
	///BEAUTIFICATION
	int IDGrass					= rmCreateObjectDef("grass");
	rmAddObjectDefItem			(IDGrass, "grass", 3, 4.0);
	rmSetObjectDefMinDistance	(IDGrass, 0.0);
	rmSetObjectDefMaxDistance	(IDGrass, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDGrass, AvoidAll);
	rmAddObjectDefConstraint	(IDGrass, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDGrass, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDRock					= rmCreateObjectDef("rock and grass");
	rmAddObjectDefItem			(IDRock, "rock limestone sprite", 1, 1.0);
	rmAddObjectDefItem			(IDRock, "grass", 2, 1.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDSprite				= rmCreateObjectDef("rock group");
	rmAddObjectDefItem			(IDSprite, "rock limestone sprite", 3, 2.0);
	rmSetObjectDefMinDistance	(IDSprite, 0.0);
	rmSetObjectDefMaxDistance	(IDSprite, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSprite, AvoidAll);
	rmAddObjectDefConstraint	(IDSprite, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDSprite, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDSeaweed				= rmCreateObjectDef("seaweed");
	rmAddObjectDefItem			(IDSeaweed, "seaweed", 12, 6.0);
	rmSetObjectDefMinDistance	(IDSeaweed, 0.0);
	rmSetObjectDefMaxDistance	(IDSeaweed, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSeaweed, AvoidAll);
	rmAddObjectDefConstraint	(IDSeaweed, NearShore);
	rmAddObjectDefConstraint	(IDSeaweed, FarShore);
	rmPlaceObjectDefAtLoc		(IDSeaweed, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDKelp					= rmCreateObjectDef("kelp");
	rmAddObjectDefItem			(IDKelp, "seaweed", 5, 3.0);
	rmSetObjectDefMinDistance	(IDKelp, 0.0);
	rmSetObjectDefMaxDistance	(IDKelp, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDKelp, AvoidAll);
	rmAddObjectDefConstraint	(IDKelp, NearShore);
	rmAddObjectDefConstraint	(IDKelp, FarShore);
	rmPlaceObjectDefAtLoc		(IDKelp, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDShark					= rmCreateObjectDef("shark");
	
	if(rmRandFloat(0,1)<0.3)
		rmAddObjectDefItem		(IDShark, "shark", 1, 0.0);
	else
		rmAddObjectDefItem		(IDShark, "whale", 1, 0.0);
	
	rmSetObjectDefMinDistance	(IDShark, 0.0);
	rmSetObjectDefMaxDistance	(IDShark, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDShark, AvoidShark);
	rmAddObjectDefConstraint	(IDShark, SharkLand);
	rmPlaceObjectDefAtLoc		(IDShark, 0, 0.5, 0.5, cNumberNonGaiaPlayers*0.5*mapSizeMultiplier); 
	
	rmSetStatusText("",1.00);
}
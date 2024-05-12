/*Midgard
**Made by Hagrit (Original concept Ensemble Studios)
*/
void main(void)
{
	///INITIALIZE MAP
	rmSetStatusText("",0.01);

	int mapSizeMultiplier = 1;
	int PlayerTiles=12000;
	
	if(cMapSize == 1) {
		PlayerTiles = 15600;
	} else if(cMapSize == 2) {
		PlayerTiles = 31200;
		mapSizeMultiplier = 2;
	}

	int size=2.0*sqrt(cNumberNonGaiaPlayers*PlayerTiles);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);

	rmSetSeaLevel(0.0);
	float waterType=rmRandFloat(0, 1);
	if(waterType<0.5)   
		rmSetSeaType("North Atlantic Ocean");
	else
		rmSetSeaType("Norwegian Sea");
	
	rmTerrainInitialize("water");
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer 	= rmDefineClass("player");
	int classStartingTC = rmDefineClass("starting settlement");
	int classIce	 	= rmDefineClass("ice");
	int classBonusHunt 	= rmDefineClass("bonus hunt");
	int classElev	 	= rmDefineClass("elev");
	int classHill	 	= rmDefineClass("hill");
	int classForest	 	= rmDefineClass("forest");
	int classCenter	 	= rmDefineClass("center");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdgeMain	= rmCreateBoxConstraint ("BC0", 0.06, 0.06, 0.94, 0.94, 0.001);
	int AvoidEdge		= rmCreateBoxConstraint	("BC1", rmXTilesToFraction(2), rmZTilesToFraction(2), 1.0-rmXTilesToFraction(2), 1.0-rmZTilesToFraction(2), 0.01);
	
	int AvoidTower			= rmCreateTypeDistanceConstraint("TC0","tower", 24.0);
	int AvoidAll			= rmCreateTypeDistanceConstraint("TC1","all", 6.0);
	int AvoidFish			= rmCreateTypeDistanceConstraint("TC2", "fish", 23.0);
	int AvoidGold			= rmCreateTypeDistanceConstraint("TC3", "gold", 35.0);
	int AvoidSettlement		= rmCreateTypeDistanceConstraint("TC4", "AbstractSettlement", 20.0);
	int AvoidSettlementFar	= rmCreateTypeDistanceConstraint("TC5", "AbstractSettlement", 25.0);
	int AvoidHunt			= rmCreateTypeDistanceConstraint("TC6", "huntable", 20.0);
	int AvoidHerd			= rmCreateTypeDistanceConstraint("TC7", "herdable", 20.0);
	int AvoidPredator		= rmCreateTypeDistanceConstraint("TC8", "animalPredator", 20.0);
	int AvoidTowerFar		= rmCreateTypeDistanceConstraint("TC9", "tower", 26.0);
	int AvoidOrca 			= rmCreateTypeDistanceConstraint("TC10", "orca", 20.0);
	
	int AvoidPlayer			= rmCreateClassDistanceConstraint ("CC0", classPlayer, 10);
	int AvoidStartingTC		= rmCreateClassDistanceConstraint ("CC1", classStartingTC, 40);
	int AvoidBonusHunt		= rmCreateClassDistanceConstraint ("CC2", classBonusHunt, 50);
	int AvoidIce			= rmCreateClassDistanceConstraint ("CC3", classIce, 5);
	int AvoidHill			= rmCreateClassDistanceConstraint ("CC4", classHill, 10);
	int AvoidForest			= rmCreateClassDistanceConstraint ("CC5", classForest, 22);
	int AvoidStartingTCShort= rmCreateClassDistanceConstraint ("CC6", classStartingTC, 20);
	int AvoidCenter			= rmCreateClassDistanceConstraint ("CC7", classCenter, 20);
	
	int AvoidImpassableLand		= rmCreateTerrainDistanceConstraint("TDC0", "land", false, 10.0);
	int AvoidImpassableLandFar	= rmCreateTerrainDistanceConstraint("TDC1", "land", false, 28.0);
	int FishLand 				= rmCreateTerrainDistanceConstraint("TDC2", "land", true, 10.0);
	int OrcaLand				= rmCreateTerrainDistanceConstraint("TDC3", "land", true, 20.0);
	
	int NearShore	= rmCreateTerrainMaxDistanceConstraint("TMC0", "water", true, 6.0);
	
	rmSetStatusText("",0.25);
	///OBJECT DEFINITION
	int IDStartingSettlement	= rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem			(IDStartingSettlement, "settlement level 1", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingSettlement, 0.0);
	rmSetObjectDefMaxDistance	(IDStartingSettlement, 0.0);
	rmAddObjectDefToClass		(IDStartingSettlement, classStartingTC);
	
	int IDStartingTowers		= rmCreateObjectDef("starting towers");
	rmAddObjectDefItem			(IDStartingTowers, "tower", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingTowers, 22.0);
	rmSetObjectDefMaxDistance	(IDStartingTowers, 27.0);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidTower);
	rmAddObjectDefConstraint	(IDStartingTowers, AvoidImpassableLand);
	
	int GoldDistance = rmRandInt(20,23);
	
	int IDStartingGold			= rmCreateObjectDef("starting gold");
	rmAddObjectDefItem			(IDStartingGold, "gold mine small", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance	(IDStartingGold, GoldDistance);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidImpassableLand);
	
	int IDStartingHerd			= rmCreateObjectDef("starting cow");
	rmAddObjectDefItem			(IDStartingHerd, "cow", rmRandInt(0,2), 2);
	rmSetObjectDefMinDistance	(IDStartingHerd, 18.0);
	rmSetObjectDefMaxDistance	(IDStartingHerd, 30.0);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHerd, AvoidImpassableLand);
	
	int IDStartingBerry			= rmCreateObjectDef("starting berry");
	rmAddObjectDefItem			(IDStartingBerry, "berry bush", rmRandInt(4,8), 4);
	rmSetObjectDefMinDistance	(IDStartingBerry, 18.0);
	rmSetObjectDefMaxDistance	(IDStartingBerry, 30.0);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidImpassableLand);
	
	float BoarNumber = rmRandFloat(0,1);
	int IDStartingBoar			= rmCreateObjectDef("starting boar");
	
	if (BoarNumber < 0.3) {
		rmAddObjectDefItem			(IDStartingBoar, "boar", 2, 4);
	} else {
		rmAddObjectDefItem			(IDStartingBoar, "boar", 1, 0);
	}
	
	rmSetObjectDefMinDistance	(IDStartingBoar, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingBoar, 35.0);
	rmAddObjectDefConstraint	(IDStartingBoar, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingBoar, AvoidImpassableLand);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "pine snow", 1, 0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	
	int IDPlayerFish			= rmCreateObjectDef("owned fish");
	rmAddObjectDefItem			(IDPlayerFish, "fish - salmon", 3, 9.0);
	rmSetObjectDefMinDistance	(IDPlayerFish, 30.0);
	rmSetObjectDefMaxDistance	(IDPlayerFish, 55.0);
	rmAddObjectDefConstraint	(IDPlayerFish, FishLand);
	rmAddObjectDefConstraint	(IDPlayerFish, AvoidFish);
	
	
	int IDMediumGold			= rmCreateObjectDef("medium gold");
	rmAddObjectDefItem			(IDMediumGold, "gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 50);
	rmSetObjectDefMaxDistance	(IDMediumGold, 60);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLandFar);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidIce);
	
	float huntDistance = rmRandInt(40, 55);
	int IDMediumHunt			= rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem			(IDMediumHunt, "deer", rmRandInt(4,8), 3.0);
	rmSetObjectDefMinDistance	(IDMediumHunt, huntDistance);
	rmSetObjectDefMaxDistance	(IDMediumHunt, huntDistance);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidTowerFar);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidIce);
	
	int IDMediumWalrus			= rmCreateObjectDef("medium walrus");
	rmAddObjectDefItem			(IDMediumWalrus, "walrus", rmRandInt(3,6), 4.0);
	rmSetObjectDefMinDistance	(IDMediumWalrus, 60.0);
	rmSetObjectDefMaxDistance	(IDMediumWalrus, 100.0);
	rmAddObjectDefToClass		(IDMediumWalrus, classBonusHunt);
	rmAddObjectDefConstraint	(IDMediumWalrus, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumWalrus, AvoidSettlement);
	rmAddObjectDefConstraint	(IDMediumWalrus, NearShore);
	rmAddObjectDefConstraint	(IDMediumWalrus, AvoidTowerFar);
	rmAddObjectDefConstraint	(IDMediumWalrus, AvoidStartingTC);
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 70.0);
	rmSetObjectDefMaxDistance	(IDFarGold, 85.0);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGold, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDFarGold, AvoidIce);
	
	int IDFarHerd				= rmCreateObjectDef("far herd");
	rmAddObjectDefItem			(IDFarHerd, "cow", rmRandInt(1,2), 3.0);
	rmSetObjectDefMinDistance	(IDFarHerd, 75.0);
	rmSetObjectDefMaxDistance	(IDFarHerd, 120.0);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidAll);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidHerd);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDFarHerd, AvoidIce);
	
	int IDPredator 				= rmCreateObjectDef("predator");
	
	float predatorSpecies = rmRandFloat(0, 1);
	if (predatorSpecies<0.5)   
		rmAddObjectDefItem		(IDPredator, "wolf", 2, 2.0);
	else
		rmAddObjectDefItem		(IDPredator, "bear", 1, 1.0);
	
	rmSetObjectDefMinDistance	(IDPredator, 50.0);
	rmSetObjectDefMaxDistance	(IDPredator, 110.0);
	rmAddObjectDefConstraint	(IDPredator, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDPredator, AvoidAll);
	rmAddObjectDefConstraint	(IDPredator, AvoidPredator);	
	rmAddObjectDefConstraint	(IDPredator, AvoidStartingTC);	
	rmAddObjectDefConstraint	(IDPredator, AvoidIce);	
	
	int IDBonusHunt				= rmCreateObjectDef("bonus hunt");
	
	float HuntSpecies = rmRandFloat(0, 1);
	if (HuntSpecies<0.5)   
		rmAddObjectDefItem		(IDBonusHunt, "elk", rmRandInt(4,9), 4.0);
	else
		rmAddObjectDefItem		(IDBonusHunt, "caribou", rmRandInt(4,9), 4.0);
	
	rmSetObjectDefMinDistance	(IDBonusHunt, 75.0);
	rmSetObjectDefMaxDistance	(IDBonusHunt, 105.0);
	rmAddObjectDefToClass		(IDBonusHunt, classBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidIce);
	
	int IDBonusWalrus			= rmCreateObjectDef("bonus walrus");
	rmAddObjectDefItem			(IDBonusWalrus, "walrus", rmRandInt(2,5), 4.0); 
	rmSetObjectDefMinDistance	(IDBonusWalrus, 90.0);
	rmSetObjectDefMaxDistance	(IDBonusWalrus, 140.0);
	rmAddObjectDefToClass		(IDBonusWalrus, classBonusHunt);
	rmAddObjectDefConstraint	(IDBonusWalrus, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDBonusWalrus, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusWalrus, NearShore);
	
	//other
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "pine snow", 1, 0.0); 
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidIce);
	
	int IDHawk					= rmCreateObjectDef("far hawks");
	rmAddObjectDefItem			(IDHawk, "hawk", 1, 0.0);
	rmSetObjectDefMinDistance	(IDHawk, 0.0);
	rmSetObjectDefMaxDistance	(IDHawk, rmXFractionToMeters(0.5));
	
	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRelic, 60.0);
	rmSetObjectDefMaxDistance	(IDRelic, 150.0);
	rmAddObjectDefConstraint	(IDRelic, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint	(IDRelic, AvoidStartingTC);
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableLand);
	
	int IDMainFish				= rmCreateObjectDef("main fish");
	rmAddObjectDefItem			(IDMainFish, "fish - salmon", 3, 10.0);
	rmSetObjectDefMinDistance	(IDMainFish, 90.0);
	rmSetObjectDefMaxDistance	(IDMainFish, 130.0+cNumberNonGaiaPlayers);
	rmAddObjectDefConstraint	(IDMainFish, AvoidFish);
	rmAddObjectDefConstraint	(IDMainFish, AvoidEdge);
	rmAddObjectDefConstraint	(IDMainFish, FishLand);
	
	int IDMediumFish			= rmCreateObjectDef("medium fish");
	rmAddObjectDefItem			(IDMediumFish, "fish - salmon", 3, 10.0);
	rmSetObjectDefMinDistance	(IDMediumFish, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumFish, 80.0);
	rmAddObjectDefConstraint	(IDMediumFish, AvoidFish);
	rmAddObjectDefConstraint	(IDMediumFish, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumFish, FishLand);
	
	int IDSingleFish			= rmCreateObjectDef("single fish");
	rmAddObjectDefItem			(IDSingleFish, "fish - perch", 1, 0.0);
	rmSetObjectDefMinDistance	(IDSingleFish, 50.0);
	rmSetObjectDefMaxDistance	(IDSingleFish, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSingleFish, AvoidFish);
	rmAddObjectDefConstraint	(IDSingleFish, FishLand);
	rmAddObjectDefConstraint	(IDSingleFish, AvoidEdge);
	
	//giant
	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, 120.0);
		rmSetObjectDefMaxDistance(giantGoldID, 200.0);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLandFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidIce);
		rmAddObjectDefConstraint(giantGoldID, rmCreateTypeDistanceConstraint("gold avoid gold 139", "gold", 60.0));
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "caribou", rmRandInt(5,6), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, 120.0);
		rmSetObjectDefMaxDistance(giantHuntableID, 200.0);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHunt);
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, AvoidGold);
		rmAddObjectDefConstraint(giantHuntableID, AvoidStartingTC);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, AvoidIce);
		
		int giantWalrus=rmCreateObjectDef("giant walrus");
		rmAddObjectDefItem(giantWalrus, "walrus", rmRandInt(4,6), 8.0);
		rmSetObjectDefMaxDistance(giantWalrus, 100.0);
		rmSetObjectDefMaxDistance(giantWalrus, 250.0);
		rmAddObjectDefConstraint(giantWalrus, AvoidHunt);
		rmAddObjectDefConstraint(giantWalrus, AvoidSettlement);
		rmAddObjectDefConstraint(giantWalrus, AvoidStartingTC);
		rmAddObjectDefConstraint(giantWalrus, NearShore);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "cow", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, 110.0);
		rmSetObjectDefMaxDistance(giantHerdableID, 250.0);
		rmAddObjectDefConstraint(giantHerdableID, AvoidStartingTC);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerd);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 0.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		
		int giantFishID=rmCreateObjectDef("giant fish");
		rmAddObjectDefItem(giantFishID, "fish - salmon", 3, 10.0);
		rmSetObjectDefMinDistance(giantFishID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantFishID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantFishID, AvoidFish);
		rmAddObjectDefConstraint(giantFishID, AvoidEdge);
		rmAddObjectDefConstraint(giantFishID, FishLand);
	}
	
	rmSetStatusText("",0.35);
	///PLAYER LOCATIONS
	if(cNumberNonGaiaPlayers > 8)
		rmPlacePlayersCircular(0.3, 0.35, rmDegreesToRadians(5.0));
	else
		rmPlacePlayersCircular(0.25, 0.3, rmDegreesToRadians(3.0));
	
	///TERRAIN DEFINITION
	int IDCenterIsland		= rmCreateArea("center");
	rmSetAreaSize			(IDCenterIsland, 0.49, 0.51);
	rmSetAreaLocation		(IDCenterIsland, 0.5, 0.5);
	rmSetAreaCoherence		(IDCenterIsland, 0.05);
	rmSetAreaBaseHeight		(IDCenterIsland, 2);
	rmSetAreaHeightBlend	(IDCenterIsland, 2);
	rmSetAreaSmoothDistance	(IDCenterIsland, 30);
	rmSetAreaTerrainType	(IDCenterIsland, "SnowA");
	rmAddAreaConstraint		(IDCenterIsland, AvoidEdgeMain);
	
	rmBuildArea(IDCenterIsland);
	
	if (cNumberNonGaiaPlayers < 3) {
		int IDCenter			= rmCreateArea("center core");
		rmSetAreaSize			(IDCenter, 0.01, 0.01);
		rmSetAreaLocation		(IDCenter, 0.5, 0.5);
		rmAddAreaToClass		(IDCenter, classCenter);
	
		rmBuildArea(IDCenter);
	}
	
	
	
	float playerFraction=rmAreaTilesToFraction(3000*mapSizeMultiplier);
	for(i=1; <cNumberPlayers)
	{
		int IDAreaPlayer		= rmCreateArea("Player"+i, IDCenterIsland);
		rmSetPlayerArea			(i, IDAreaPlayer);
		rmSetAreaSize			(IDAreaPlayer, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass		(IDAreaPlayer, classPlayer);
		rmSetAreaWarnFailure	(IDAreaPlayer, false);
		rmSetAreaMinBlobs		(IDAreaPlayer, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDAreaPlayer, 5*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDAreaPlayer, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDAreaPlayer, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDAreaPlayer, 0.0);
		rmAddAreaConstraint		(IDAreaPlayer, AvoidPlayer);
		rmSetAreaLocPlayer		(IDAreaPlayer, i);
		rmSetAreaTerrainType	(IDAreaPlayer, "SnowGrass50");
		rmAddAreaTerrainLayer	(IDAreaPlayer, "SnowGrass25", 0, 12);
	}
	rmBuildAllAreas();
	
	for(i=1; < cNumberPlayers*5*mapSizeMultiplier)
	{
		int IDPatch				= rmCreateArea("Patch"+i);
		rmSetAreaSize			(IDPatch, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		rmSetAreaTerrainType	(IDPatch, "SnowB");
		rmSetAreaWarnFailure	(IDPatch, false);
		rmSetAreaMinBlobs		(IDPatch, 1);
		rmSetAreaMaxBlobs		(IDPatch, 2);
		rmSetAreaMinBlobDistance(IDPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDPatch, 40.0);
		rmSetAreaCoherence		(IDPatch, 0.0);
		rmAddAreaConstraint		(IDPatch, AvoidPlayer);
		rmAddAreaConstraint		(IDPatch, AvoidImpassableLand);
		
		rmBuildArea(IDPatch);
	}
	
	rmSetStatusText("",0.45);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int IDSettle = rmAddFairLoc("Settlement", false, true,  65, 85, 40, 40);
	rmAddFairLocConstraint(IDSettle, AvoidImpassableLandFar);
	
	if(rmRandFloat(0,1)<0.75)
	{      
		IDSettle = rmAddFairLoc("Settlement", true, false, 80, 100, 65, 40);
		rmAddFairLocConstraint(IDSettle, AvoidImpassableLandFar);
		rmAddFairLocConstraint(IDSettle, AvoidCenter);
	} else {  
		IDSettle = rmAddFairLoc("Settlement", false, true,  60, 80, 50, 40);
		rmAddFairLocConstraint(IDSettle, AvoidImpassableLandFar);
	}
	
	if (cMapSize == 2) {
		IDSettle = rmAddFairLoc("Settlement", true, false,  120, 180, 80, 60);
		rmAddFairLocConstraint(IDSettle, AvoidImpassableLandFar);
	}
	
	if(rmPlaceFairLocs())
	{
		IDSettle = rmCreateObjectDef("far settlement2");
		rmAddObjectDefItem(IDSettle, "Settlement", 1, 0.0);
		for(i=1; < cNumberPlayers)
		{
			for(j=0; <rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(IDSettle, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}

	rmSetStatusText("",0.50);
	///OTHER TERRAIN
	for(i=1; <cNumberPlayers*1.5*mapSizeMultiplier)
	{
		int IDIce				= rmCreateArea("Ice patch"+i);
		rmSetAreaSize			(IDIce, rmAreaTilesToFraction(70*mapSizeMultiplier), rmAreaTilesToFraction(200*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDIce, "IceA");
		rmSetAreaWarnFailure	(IDIce, false);
		rmAddAreaToClass		(IDIce, classIce);
		rmSetAreaBaseHeight		(IDIce, 0.0);
		rmSetAreaMinBlobs		(IDIce, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDIce, 2*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDIce, 10.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDIce, 15.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDIce, 0.0);
		rmSetAreaSmoothDistance	(IDIce, 20);
		rmAddAreaConstraint		(IDIce, AvoidPlayer);
		rmAddAreaConstraint		(IDIce, AvoidTowerFar);
		rmAddAreaConstraint		(IDIce, AvoidImpassableLand);
		rmAddAreaConstraint		(IDIce, AvoidSettlement);
		
		rmBuildArea(IDIce);
	}
	
	for(i=1; <cNumberPlayers*1.5*mapSizeMultiplier)
	{
		int IDIcePatch			= rmCreateArea("Smaller ice patch"+i, rmAreaID("Ice patch"+i));
		rmSetAreaSize			(IDIcePatch, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(30*mapSizeMultiplier));
		rmSetAreaTerrainType	(IDIcePatch, "IceB");
		rmSetAreaWarnFailure	(IDIcePatch, false);
		rmAddAreaToClass		(IDIcePatch, classIce);
		rmSetAreaBaseHeight		(IDIcePatch, 0.0);
		rmSetAreaMinBlobs		(IDIcePatch, 1);
		rmSetAreaMaxBlobs		(IDIcePatch, 1);
		
		rmBuildArea(IDIcePatch);
	}
	
	int numTries=6*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int failCount=0;
	for(i=0; <numTries)
	{
		int IDElev				= rmCreateArea("elev"+i, IDCenterIsland);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
		rmSetAreaWarnFailure	(IDElev, false);
		rmAddAreaConstraint		(IDElev, AvoidPlayer);
		rmAddAreaToClass		(IDElev, classHill);
		rmAddAreaConstraint		(IDElev, AvoidIce);
		rmAddAreaConstraint		(IDElev, AvoidHill);
		rmAddAreaConstraint		(IDElev, AvoidImpassableLand);
		
		if(rmRandFloat(0.0, 1.0)<0.5)
			rmSetAreaTerrainType(IDElev, "SnowGrass25");
		
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(4.0, 7.0));
		rmSetAreaHeightBlend	(IDElev, 2);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 5);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 40.0);
		rmSetAreaCoherence		(IDElev, 0.0);
	
		if(rmBuildArea(IDElev)==false)
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
		IDElev					= rmCreateArea("wrinkle"+i, IDCenterIsland);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaWarnFailure	(IDElev, false);
		rmAddAreaConstraint		(IDElev, AvoidImpassableLand);
		rmAddAreaConstraint		(IDElev, AvoidIce);
		rmAddAreaConstraint		(IDElev, AvoidSettlement);
		rmAddAreaConstraint		(IDElev, AvoidHill);
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(3.0, 5.0));
		rmSetAreaHeightBlend	(IDElev, 1);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 3);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 20.0);
		rmSetAreaCoherence		(IDElev, 0.0);
	
		if(rmBuildArea(IDElev)==false)
		{
			failCount++;
			if(failCount==3)
			break;
		}
		else
			failCount=0;
	}
	
	rmSetStatusText("",0.60);
	///OBJECT PLACEMENT
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingTowers, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingBerry, false);
	rmPlaceObjectDefPerPlayer(IDStartingHerd, false);
	
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(2,6));
	rmPlaceObjectDefPerPlayer(IDPlayerFish, false);
	
	int boarNumber = rmRandInt(0,100);
	
	if (boarNumber < 25)
		rmPlaceObjectDefPerPlayer(IDStartingBoar, false);
	
	
	rmPlaceObjectDefPerPlayer(IDMediumGold, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDMediumHunt, false);
	rmPlaceObjectDefPerPlayer(IDMediumWalrus, false);
	
	rmPlaceObjectDefPerPlayer(IDFarGold, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDFarHerd, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDPredator, false);
	rmPlaceObjectDefPerPlayer(IDBonusHunt, false);
	
	if(rmRandFloat(0,1)<0.75)
      rmPlaceObjectDefPerPlayer(IDBonusWalrus, false, 1);
   else if(cNumberNonGaiaPlayers < 8)
      rmPlaceObjectDefPerPlayer(IDBonusWalrus, false, 2);
   else
      rmPlaceObjectDefPerPlayer(IDBonusWalrus, false, 1);
  
	rmPlaceObjectDefPerPlayer(IDRelic, false);
	rmPlaceObjectDefPerPlayer(IDMainFish, false, rmRandInt(3,5));
	rmPlaceObjectDefPerPlayer(IDMediumFish, false, rmRandInt(1,2));
	
	rmPlaceObjectDefAtLoc(IDSingleFish, 0, 0.5, 0.5, 4*cNumberNonGaiaPlayers);
	rmPlaceObjectDefAtLoc(IDHawk, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(2, 3));
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(2, 3));
		rmPlaceObjectDefPerPlayer(giantWalrus, false);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(2, 3));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
		rmPlaceObjectDefAtLoc(giantFishID, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.70);
	///FORESTS
	numTries=8*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount=0;
	for(i=0; <numTries)
	{
		int IDForest			= rmCreateArea("forest"+i, IDCenterIsland);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(140*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "snow pine forest");
		rmAddAreaConstraint		(IDForest, AvoidStartingTCShort);
		rmAddAreaConstraint		(IDForest, AvoidIce); 
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidImpassableLand);
		rmAddAreaToClass		(IDForest, classForest);
		rmSetAreaMinBlobs		(IDForest, 1);
		rmSetAreaMaxBlobs		(IDForest, 4);
		rmSetAreaMinBlobDistance(IDForest, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDForest, 25.0*mapSizeMultiplier);
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
   
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
	rmSetStatusText("",0.80);
	///BEAUTIFICATION
	int IDRock					= rmCreateObjectDef("rock");
	rmAddObjectDefItem			(IDRock, "rock granite sprite", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRock, AvoidIce);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int IDOrca 					= rmCreateObjectDef("orca");
	rmAddObjectDefItem			(IDOrca, "orca", 1, 0.0);
	rmSetObjectDefMinDistance	(IDOrca, 0.0);
	rmSetObjectDefMaxDistance	(IDOrca, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDOrca, OrcaLand);
	rmAddObjectDefConstraint	(IDOrca, AvoidOrca);
	rmAddObjectDefConstraint	(IDOrca, AvoidEdge);
	rmPlaceObjectDefAtLoc		(IDOrca, 0, 0.5, 0.5, 0.5*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	if(waterType>=0.5)
	{
		int nearshore = rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
		int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
		int IDKelp					= rmCreateObjectDef("seaweed");
		rmAddObjectDefItem			(IDKelp, "seaweed", 5, 3.0);
		rmSetObjectDefMinDistance	(IDKelp, 0.0);
		rmSetObjectDefMaxDistance	(IDKelp, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint	(IDKelp, AvoidAll);
		rmAddObjectDefConstraint	(IDKelp, nearshore);
		rmAddObjectDefConstraint	(IDKelp, farshore);
		rmPlaceObjectDefAtLoc		(IDKelp, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
		int IDKelp2					= rmCreateObjectDef("seaweed 2");
		rmAddObjectDefItem			(IDKelp2, "seaweed", 2, 3.0);
		rmSetObjectDefMinDistance	(IDKelp2, 0.0);
		rmSetObjectDefMaxDistance	(IDKelp2, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint	(IDKelp2, AvoidAll);
		rmAddObjectDefConstraint	(IDKelp2, nearshore);
		rmAddObjectDefConstraint	(IDKelp2, farshore);
		rmPlaceObjectDefAtLoc		(IDKelp2, 0, 0.5, 0.5, 12*cNumberNonGaiaPlayers*mapSizeMultiplier);
	}
	rmSetStatusText("",0.90);
	rmSetStatusText("",1.0);
}  

/*	Anatolia - Freshed Up
**	Author: Hagrit (Original concept by Ensemble Studios)
*/

void rmPlaceObjectDefInLineX(int ObjID = -1, int playerID = 0, int spots = 1, float constantZ = -1.0, float startX = 0.0, float endX = 0.0, float varience = 0.0){
	
	if(constantZ == -1.0 || ObjID == -1 || playerID < 0 || playerID > 12 || varience < 0.0){
		rmEchoError("rmPlaceObjectDefInLineX Invalid Param!");
		return;
	}
	
	float modifier = 0;
	if(startX > endX){
		modifier = (startX - endX) / (spots+1);
	} else {
		modifier = (endX - startX) / (spots+1);
	}
	
	float placementX = modifier;
	float tempVarience = 0.0;
	
	for(p = 1; <= spots){
		if(varience > 0.0){
			tempVarience = rmRandFloat(0.0, varience) - rmRandFloat(0.0, varience);
		}
		rmPlaceObjectDefAtLoc(ObjID, playerID, placementX + tempVarience, constantZ + tempVarience, 1);
		placementX = placementX + modifier;
	}
}

void main(void) 
{
	
	///INITIALIZE MAP
	rmSetStatusText("",0.01);
	
	int mapSizeMultiplier = 1;
	
	int PlayerTiles = 8000;
	if (cMapSize == 1) {
		PlayerTiles = 10400;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2) {
		PlayerTiles = 20800;
		rmEchoInfo("Giant map");
		mapSizeMultiplier = 2;
	}
	int size = 2.0*sqrt(cNumberNonGaiaPlayers*PlayerTiles/0.9);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	rmSetMapSize(size, size);
	
	rmSetSeaLevel(0.0);
	rmSetSeaType("Red sea");
	
	rmTerrainInitialize("SandA");
	rmSetLightingSet("anatolia");
	
	rmSetStatusText("",0.02);
	
	///CLASSES
	int classPlayer		= rmDefineClass("player");
	int classPlayerCore	= rmDefineClass("player core");
	int classOcean		= rmDefineClass("ocean");
	int classPatch		= rmDefineClass("patch");
	int classForest		= rmDefineClass("forest");
	int classCliff		= rmDefineClass("cliffs");
	int classStarting	= rmDefineClass("starting settlement");
	
	rmSetStatusText("",0.05);
	///CONSTRAINTS
	int AvoidEdge		= rmCreateBoxConstraint("BC0", rmXTilesToFraction(3), rmZTilesToFraction(3), 1.0-rmXTilesToFraction(3), 1.0-rmZTilesToFraction(3));
	int AvoidEdgeGold	= rmCreateBoxConstraint("BC1", 0.32, 0.20, 0.68, 0.80);
	
	int AvoidGoldShort			= rmCreateTypeDistanceConstraint("TyDC0", "gold", 12);
	int AvoidTower				= rmCreateTypeDistanceConstraint("TyDC1", "tower", 22);
	int AvoidAll				= rmCreateTypeDistanceConstraint("TyDC2", "all", 6);
	int AvoidHerd				= rmCreateTypeDistanceConstraint("TyDC3", "herdable", 25);
	int AvoidGold				= rmCreateTypeDistanceConstraint("TyDC4", "gold", 25);
	int AvoidSettlement			= rmCreateTypeDistanceConstraint("TyDC5", "abstractSettlement", 21);
	int AvoidPred				= rmCreateTypeDistanceConstraint("TyDC6", "animalPredator", 25);
	int AvoidHunt				= rmCreateTypeDistanceConstraint("TyDC7", "huntable", 30);
	int AvoidBerry				= rmCreateTypeDistanceConstraint("TyDC8", "berry bush", 40);
	int AvoidFish				= rmCreateTypeDistanceConstraint("TyDC9", "fish", 24);
	int AvoidSettlementShort	= rmCreateTypeDistanceConstraint("TyDC10", "abstractSettlement", 18);
	
	int AvoidPatch			= rmCreateClassDistanceConstraint("CDC0", classPatch, 10.0);
	int AvoidOcean			= rmCreateClassDistanceConstraint("CDC1", classOcean, 15.0);
	int AvoidOceanFar		= rmCreateClassDistanceConstraint("CDC2", classOcean, 28.0);
	int AvoidPlayer			= rmCreateClassDistanceConstraint("CDC3", classPlayer, 15.0);
	int AvoidStartingSettle	= rmCreateClassDistanceConstraint("CDC4", classPlayerCore, 50.0);
	int AvoidCliff			= rmCreateClassDistanceConstraint("CDC5", classCliff, 22.0);
	int AvoidCliffShort		= rmCreateClassDistanceConstraint("CDC6", classCliff, 4.0);
	int AvoidCliffMed		= rmCreateClassDistanceConstraint("CDC7", classCliff, 10.0);
	int AvoidForest			= rmCreateClassDistanceConstraint("CDC8", classForest, 20.0);
	int AvoidStartingTc		= rmCreateClassDistanceConstraint("CDC9", classStarting, 20.0);
	
	int AvoidImpassableLand			= rmCreateTerrainDistanceConstraint("TeDC0", "land", false, 10.0);
	int AvoidImpassableLandShort	= rmCreateTerrainDistanceConstraint("TeDC1", "land", false, 6.0);
	
	int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 10.0);
	
	rmSetStatusText("",0.10);
	///OBJECT DEFINITION
	int IDStartingSettlement	= rmCreateObjectDef("starting tc");
	rmAddObjectDefItem			(IDStartingSettlement, "settlement level 1", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingSettlement, 0.0);
	rmSetObjectDefMaxDistance	(IDStartingSettlement, 0.0);
	rmAddObjectDefToClass		(IDStartingSettlement, classStarting);
	
	int IDStartingGold 			= rmCreateObjectDef("starting gold");
	rmAddObjectDefItem			(IDStartingGold, "gold mine small", 1, 0);
	rmSetObjectDefMinDistance	(IDStartingGold, 20.0);
	rmSetObjectDefMaxDistance	(IDStartingGold, 25.0);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingGold, AvoidGoldShort);
	
	int IDStartingTower			= rmCreateObjectDef("tower");
	rmAddObjectDefItem			(IDStartingTower, "tower", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStartingTower, 22);
	rmSetObjectDefMaxDistance	(IDStartingTower, 26);
	rmAddObjectDefConstraint	(IDStartingTower, AvoidTower);
	
	int BoarDistance = rmRandInt(23,30);
	
	int IDStartingBoar			= rmCreateObjectDef("starting boar");
	
	float boarNumber = rmRandFloat(0, 1);
	if(boarNumber<0.3)
		rmAddObjectDefItem		(IDStartingBoar, "boar", 3, 4.0);
	else if(boarNumber<0.9)
		rmAddObjectDefItem		(IDStartingBoar, "boar", 4, 4.0);
	else
		rmAddObjectDefItem		(IDStartingBoar, "boar", 1, 4.0);
	
	rmSetObjectDefMinDistance	(IDStartingBoar, BoarDistance);
	rmSetObjectDefMaxDistance	(IDStartingBoar, BoarDistance);
	rmAddObjectDefConstraint	(IDStartingBoar, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingBoar, AvoidAll);
	
	int IDStartingGoat			= rmCreateObjectDef("starting goat");
	rmAddObjectDefItem			(IDStartingGoat, "goat", rmRandInt(2,5), 3);
	rmSetObjectDefMinDistance	(IDStartingGoat, 25);
	rmSetObjectDefMaxDistance	(IDStartingGoat, 30);
	rmAddObjectDefConstraint	(IDStartingGoat, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingGoat, AvoidAll);
	
	int IDStartingBerry			= rmCreateObjectDef("starting berry");
	rmAddObjectDefItem			(IDStartingBerry, "berry bush", rmRandInt(3,9), 4);
	rmSetObjectDefMinDistance	(IDStartingBerry, 25);
	rmSetObjectDefMaxDistance	(IDStartingBerry, 30);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingBerry, AvoidAll);
	
	int IDStartingChicken		= rmCreateObjectDef("starting chicken");
	rmAddObjectDefItem			(IDStartingChicken, "chicken", rmRandInt(4,12), 4);
	rmSetObjectDefMinDistance	(IDStartingChicken, 25);
	rmSetObjectDefMaxDistance	(IDStartingChicken, 30);
	rmAddObjectDefConstraint	(IDStartingChicken, AvoidEdge);
	rmAddObjectDefConstraint	(IDStartingChicken, AvoidAll);
	
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "pine", 1, 0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15);
	
	//medium
	int IDMediumGoat			= rmCreateObjectDef("medium goat");
	rmAddObjectDefItem			(IDMediumGoat, "goat", 2, 3);
	rmSetObjectDefMinDistance	(IDMediumGoat, 50);
	rmSetObjectDefMaxDistance	(IDMediumGoat, 75);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidHerd);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidImpassableLand);
	
	//far
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold, 80);
	rmSetObjectDefMaxDistance	(IDFarGold, 100);
	rmAddObjectDefConstraint	(IDFarGold, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdgeGold);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLandShort);
	
	int IDFarGold2				= rmCreateObjectDef("far gold 2");
	rmAddObjectDefItem			(IDFarGold2, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold2, 50);
	rmSetObjectDefMaxDistance	(IDFarGold2, 70);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidEdgeGold);
	rmAddObjectDefConstraint	(IDFarGold2, AvoidImpassableLandShort);
	
	int IDFarGold3				= rmCreateObjectDef("far gold 3");
	rmAddObjectDefItem			(IDFarGold3, "gold mine", 1, 0);
	rmSetObjectDefMinDistance	(IDFarGold3, 0);
	rmSetObjectDefMaxDistance	(IDFarGold3, rmXTilesToFraction(0.5));
	rmAddObjectDefConstraint	(IDFarGold3, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidGold);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidSettlement);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidEdgeGold);
	rmAddObjectDefConstraint	(IDFarGold3, AvoidImpassableLandShort);
	
	int HuntDistance = rmRandInt(50,110);
	
	int IDFarHunt				= rmCreateObjectDef("bonus huntable");
	
	float bonusChance = rmRandFloat(0, 1);
	if (bonusChance<0.5)   
		rmAddObjectDefItem		(IDFarHunt, "deer", 8, 4.0);
	else
		rmAddObjectDefItem		(IDFarHunt, "deer", 10, 4.0);
	
	rmSetObjectDefMinDistance	(IDFarHunt, HuntDistance);
	rmSetObjectDefMaxDistance	(IDFarHunt, HuntDistance);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidHunt);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarHunt, AvoidImpassableLand);
	
	int IDFarGoat				= rmCreateObjectDef("far goat");
	rmAddObjectDefItem			(IDFarGoat, "goat", 2, 3);
	rmSetObjectDefMinDistance	(IDFarGoat, 80);
	rmSetObjectDefMaxDistance	(IDFarGoat, 150);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidHerd);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidStartingSettle);
	
	int IDPred					= rmCreateObjectDef("far predator");
	
	float predatorSpecies = rmRandFloat(0, 1);
	if (predatorSpecies<0.5)   
		rmAddObjectDefItem		(IDPred, "wolf", rmRandInt(2,3), 4.0);
	else
		rmAddObjectDefItem		(IDPred, "wolf", rmRandInt(3,4), 8.0);
	
	rmSetObjectDefMinDistance	(IDPred, 70.0);
	rmSetObjectDefMaxDistance	(IDPred, 110.0);
	rmAddObjectDefConstraint	(IDPred, AvoidPred);
	rmAddObjectDefConstraint	(IDPred, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDPred, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDPred, AvoidOceanFar);
	rmAddObjectDefConstraint	(IDPred, AvoidAll);
	rmAddObjectDefConstraint	(IDPred, AvoidEdge);
	
	int IDFarBerrys				= rmCreateObjectDef("far berry");
	rmAddObjectDefItem			(IDFarBerrys, "berry bush", 10, 4);
	rmSetObjectDefMinDistance	(IDFarBerrys, 70.0);
	rmSetObjectDefMaxDistance	(IDFarBerrys, 130.0);
	rmAddObjectDefConstraint	(IDFarBerrys, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarBerrys, AvoidAll);
	rmAddObjectDefConstraint	(IDFarBerrys, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarBerrys, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarBerrys, AvoidBerry);
	
	int IDRelic					= rmCreateObjectDef("relic");
	rmAddObjectDefItem			(IDRelic, "relic", 1, 0);
	rmSetObjectDefMinDistance	(IDRelic, 70.0);
	rmSetObjectDefMaxDistance	(IDRelic, 150.0);
	rmAddObjectDefConstraint	(IDRelic, AvoidEdge);
	rmAddObjectDefConstraint	(IDRelic, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRelic, AvoidAll);
	rmAddObjectDefConstraint	(IDRelic, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDRelic, rmCreateTypeDistanceConstraint("relic avoid relic", "relic", 60));
	
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "pine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	
	int IDFish					= rmCreateObjectDef("fish");
	rmAddObjectDefItem			(IDFish, "fish - mahi", 3, 9.0);
	rmSetObjectDefMinDistance	(IDFish, 0.0);
	rmSetObjectDefMaxDistance	(IDFish, 0.0);
	
	if(cMapSize == 2){
		int giantGoldID=rmCreateObjectDef("giant gold");
		rmAddObjectDefItem(giantGoldID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantGoldID, AvoidGold);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdgeGold);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlement);
		rmAddObjectDefConstraint(giantGoldID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLand);
		
		int giantGold2ID=rmCreateObjectDef("giant gold2");
		rmAddObjectDefItem(giantGold2ID, "Gold mine", 1, 0.0);
		rmSetObjectDefMaxDistance(giantGold2ID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantGold2ID, rmXFractionToMeters(0.35));
		rmAddObjectDefConstraint(giantGold2ID, AvoidEdgeGold);
		rmAddObjectDefConstraint(giantGold2ID, AvoidGold);
		rmAddObjectDefConstraint(giantGold2ID, AvoidSettlement);
		rmAddObjectDefConstraint(giantGold2ID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantGold2ID, AvoidImpassableLand);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		rmAddObjectDefItem(giantHuntableID, "deer", rmRandInt(8,10), 5.0);
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantHuntableID, AvoidAll);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHunt);
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlement);
		rmAddObjectDefConstraint(giantHuntableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(2,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.35));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.4));
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidHerd);
		rmAddObjectDefConstraint(giantHerdableID, AvoidSettlement);
		rmAddObjectDefConstraint(giantHerdableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);

		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
	}
	
	rmSetStatusText("",0.20);
	///PLAYER LOCATIONS
	if(cNumberNonGaiaPlayers < 3)
		rmPlacePlayersLine(0.12, 0.5, 0.88, 0.5);
	else if(cNumberTeams < 3) {
		rmSetPlacementTeam(0);
		rmPlacePlayersLine(0.12, 0.20, 0.12, 0.80, 20, 10);
		rmSetPlacementTeam(1);
		rmPlacePlayersLine(0.88, 0.20, 0.88, 0.80, 20, 10);
	} else {
		rmPlacePlayersCircular(0.3, 0.35, rmDegreesToRadians(5.0));
	}
		
	rmSetStatusText("",0.25);
	///AREA DEFINITION
	for(i = 1; < cNumberPlayers)
	{
		int IDPlayerCore	= rmCreateArea("Player core"+i);
		rmSetAreaSize		(IDPlayerCore, rmAreaTilesToFraction(110), rmAreaTilesToFraction(110));
		rmAddAreaToClass	(IDPlayerCore, classPlayerCore);
		rmSetAreaCoherence	(IDPlayerCore, 1.0);
		rmSetAreaLocPlayer	(IDPlayerCore, i);
		
		rmBuildArea(IDPlayerCore);
	}
	
	float playerFraction=rmAreaTilesToFraction(1600);
	for(i = 1; < cNumberPlayers)
	{
		int AreaPlayer			= rmCreateArea("Player"+i);
		rmSetPlayerArea			(i, AreaPlayer);
		rmSetAreaSize			(AreaPlayer, 0.9*playerFraction, 1.1*playerFraction);
		rmAddAreaToClass		(AreaPlayer, classPlayer);
		rmSetAreaMinBlobs		(AreaPlayer, 1);
		rmSetAreaMaxBlobs		(AreaPlayer, 5);
		rmSetAreaMinBlobDistance(AreaPlayer, 16.0);
		rmSetAreaMaxBlobDistance(AreaPlayer, 40.0);
		rmSetAreaCoherence		(AreaPlayer, 0.0);
		rmAddAreaConstraint		(AreaPlayer, AvoidEdge);
		rmSetAreaTerrainType	(AreaPlayer, "SnowB");
		rmAddAreaTerrainLayer	(AreaPlayer, "snowSand25", 6, 10);
		rmAddAreaTerrainLayer	(AreaPlayer, "snowSand50", 2, 6);
		rmAddAreaTerrainLayer	(AreaPlayer, "snowSand75", 0, 2);
		rmSetAreaLocPlayer		(AreaPlayer, i);
	}
	
	rmBuildAllAreas();
	
	int IDNorthOcean			= rmCreateArea("north ocean");
	rmSetAreaSize				(IDNorthOcean, 0.1, 0.1);
	rmSetAreaWaterType			(IDNorthOcean, "Red Sea");
	rmSetAreaWarnFailure		(IDNorthOcean, false); 
	rmSetAreaLocation			(IDNorthOcean, 0.5, 0.99);
	rmAddAreaInfluenceSegment	(IDNorthOcean, 0, 1, 1, 1);
	rmSetAreaCoherence			(IDNorthOcean, 0.0);
	rmSetAreaSmoothDistance		(IDNorthOcean, 12);
	rmSetAreaHeightBlend		(IDNorthOcean, 1);
	rmAddAreaToClass			(IDNorthOcean, classOcean);
	
	rmBuildArea(IDNorthOcean);
	
	int IDSouthOcean			= rmCreateArea("south ocean");
	rmSetAreaSize				(IDSouthOcean, 0.1, 0.1);
	rmSetAreaWaterType			(IDSouthOcean, "Red Sea");
	rmSetAreaWarnFailure		(IDSouthOcean, false); 
	rmSetAreaLocation			(IDSouthOcean, 0.5, 0.01);
	rmAddAreaInfluenceSegment	(IDSouthOcean, 0, 0, 1, 0);
	rmSetAreaCoherence			(IDSouthOcean, 0.25);
	rmSetAreaSmoothDistance		(IDSouthOcean, 12);
	rmSetAreaHeightBlend		(IDSouthOcean, 1);
	rmAddAreaToClass			(IDSouthOcean, classOcean);
	
	rmBuildArea(IDSouthOcean);
	
	int IDGoldArea			= rmCreateArea("here is gold");
	rmSetAreaSize			(IDGoldArea, 0.6, 0.6);
	rmSetAreaWarnFailure	(IDGoldArea, false);
	rmAddAreaConstraint		(IDGoldArea, AvoidEdgeGold);
	//rmSetAreaTerrainType	(IDGoldArea, "grassA");
	
	rmBuildArea(IDGoldArea);
	
	rmSetStatusText("",0.35);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int IDSettle	= rmAddFairLoc("Settlement", false, true,  60, 90, 40, 20);
	rmAddFairLocConstraint(IDSettle, AvoidOceanFar);
	
	int SettleDistance = rmRandInt(0,100);
	
	int SettleDistance1 = (rmRandInt(116,130));
	int SettleDistance2 = (rmRandInt(96,115));
	int SettleDistance3 = (rmRandInt(88,95));
	
	if (SettleDistance < 33) {
	IDSettle	= rmAddFairLoc("Settlement", true, true, SettleDistance1, SettleDistance1, 75, 15);
	rmAddFairLocConstraint(IDSettle, AvoidOceanFar);
	} else if (SettleDistance < 66) {
		IDSettle	= rmAddFairLoc("Settlement", true, true, SettleDistance2, SettleDistance2, 75, 15);
		rmAddFairLocConstraint(IDSettle, AvoidOceanFar);
	} else {
		IDSettle	= rmAddFairLoc("Settlement", true, true, SettleDistance3, SettleDistance3, 70, 15);
		rmAddFairLocConstraint(IDSettle, AvoidOceanFar);
	}
	
	if (cMapSize == 2) {
		IDSettle	= rmAddFairLoc("Settlement", true, false, 130, 200, 80, 35);
		rmAddFairLocConstraint(IDSettle, AvoidOceanFar);
		
		IDSettle	= rmAddFairLoc("Settlement", true, false, 150, 220, 80, 35);
		rmAddFairLocConstraint(IDSettle, AvoidOceanFar);
	}
	
	if(rmPlaceFairLocs())
	{
		IDSettle	= rmCreateObjectDef("far settlement2");
		rmAddObjectDefItem(IDSettle, "Settlement", 1, 0.0);
		for(i = 1; < cNumberPlayers)
		{
			for(j = 0; < rmGetNumberFairLocs(i))
			rmPlaceObjectDefAtLoc(IDSettle, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
		}
	}
	
	rmSetStatusText("",0.40);
	///CLIFFS
	int IDGorge					= rmCreateArea("gorge");
	rmSetAreaWarnFailure		(IDGorge, false); 
	rmSetAreaSize				(IDGorge, rmAreaTilesToFraction(650), rmAreaTilesToFraction(1250));
	rmSetAreaCliffType			(IDGorge, "Egyptian");
	rmAddAreaConstraint			(IDGorge, AvoidCliff);
	rmAddAreaConstraint			(IDGorge, AvoidSettlementShort);
	rmAddAreaConstraint			(IDGorge, AvoidStartingSettle);
	rmAddAreaConstraint			(IDGorge, AvoidOcean); 
	rmAddAreaToClass			(IDGorge, classCliff);
	rmSetAreaMinBlobs			(IDGorge, 4);
	rmSetAreaMaxBlobs			(IDGorge, 6);
	rmSetAreaLocation			(IDGorge, 0.5, 0.5);
	//rmAddAreaInfluenceSegment	(IDGorge, 0.5, 0.25, 0.5, 0.75); 
	rmSetAreaCliffEdge			(IDGorge, 6, 0.04, 0.1, 1.0, 0);
	rmSetAreaCliffPainting		(IDGorge, false, true, true, 1.5);
	rmSetAreaMinBlobDistance	(IDGorge, 10.0);
	rmSetAreaMaxBlobDistance	(IDGorge, 20.0);
	rmSetAreaCoherence			(IDGorge, 0.0);
	rmSetAreaSmoothDistance		(IDGorge, 10);
	rmSetAreaCliffHeight		(IDGorge, -5, 1.0, 1.0);
	rmSetAreaHeightBlend		(IDGorge, 2);
	
	if (cNumberTeams < 3) {
		rmBuildArea(IDGorge);
	}
	
	for(i = 0; <6+(1*cNumberNonGaiaPlayers)*mapSizeMultiplier)
	{
		int IDCliff				= rmCreateArea("cliff"+i);
		rmSetAreaWarnFailure	(IDCliff, false);
		rmSetAreaSize			(IDCliff, rmAreaTilesToFraction(200), rmAreaTilesToFraction(500));
		rmSetAreaCliffType		(IDCliff, "Egyptian");
		rmAddAreaConstraint		(IDCliff, AvoidCliff); 
		rmAddAreaConstraint		(IDCliff, AvoidPlayer);
		rmAddAreaConstraint		(IDCliff, AvoidSettlement);
		rmAddAreaConstraint		(IDCliff, AvoidOceanFar);
		rmAddAreaConstraint		(IDCliff, AvoidStartingSettle); 
		rmAddAreaToClass		(IDCliff, classCliff);
		rmSetAreaMinBlobs		(IDCliff, 2);
		rmSetAreaMaxBlobs		(IDCliff, 5);
		rmSetAreaCliffEdge		(IDCliff, 1, 0.5, 0.1, 1.0, 0);
		rmSetAreaCliffPainting	(IDCliff, false, true, true, 1.5);
		rmSetAreaCliffHeight	(IDCliff, 7, 1.0, 1.0);
		rmSetAreaMinBlobDistance(IDCliff, 0.0);
		rmSetAreaMaxBlobDistance(IDCliff, 5.0);
		rmSetAreaCoherence		(IDCliff, 0.0);
		rmSetAreaSmoothDistance	(IDCliff, 10);
		rmSetAreaCliffHeight	(IDCliff, -5, 1.0, 1.0);
		rmSetAreaHeightBlend	(IDCliff, 2); 
		rmBuildArea(IDCliff); 
	}
	
	int IDPatch = 0;
	int failCount = 0;
	
	int AvoidNotPatch	= rmCreateEdgeDistanceConstraint("EDC0", IDPatch, 4.0);
	
	for(i = 1; < cNumberPlayers*5) 
	{
		IDPatch					= rmCreateArea("patch"+i);
		rmSetAreaSize			(IDPatch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
		rmSetAreaWarnFailure	(IDPatch, false); 
		rmSetAreaTerrainType	(IDPatch, "SnowB");
		rmAddAreaTerrainLayer	(IDPatch, "snowSand25", 2, 3);
		rmAddAreaTerrainLayer	(IDPatch, "snowSand50", 1, 2);
		rmAddAreaTerrainLayer	(IDPatch, "snowSand75", 0, 1);
		rmSetAreaMinBlobs		(IDPatch, 1);
		rmSetAreaMaxBlobs		(IDPatch, 5);
		rmSetAreaMinBlobDistance(IDPatch, 16.0);
		rmSetAreaMaxBlobDistance(IDPatch, 40.0);
		rmAddAreaToClass		(IDPatch, classPatch);
		rmAddAreaConstraint		(IDPatch, AvoidPatch); 
		rmAddAreaConstraint		(IDPatch, AvoidPlayer);
		rmAddAreaConstraint		(IDPatch, AvoidOcean); 
		rmAddAreaConstraint		(IDPatch, AvoidCliffShort); 
		rmSetAreaCoherence		(IDPatch, 0.3);
		rmSetAreaSmoothDistance	(IDPatch, 8);
	
		if(rmBuildArea(IDPatch)==false)
		{
			failCount++;
			if(failCount==3)
				break;
		}
		else
			failCount=0;
	
		int IDSnowRock				= rmCreateObjectDef("snowRock"+i);
		rmAddObjectDefItem			(IDSnowRock, "rock granite sprite", rmRandFloat(1,3), 2.0);
		rmSetObjectDefMinDistance	(IDSnowRock, 0.0);
		rmSetObjectDefMaxDistance	(IDSnowRock, 0.0);
		rmAddObjectDefConstraint	(IDSnowRock, AvoidNotPatch);
		rmAddObjectDefConstraint	(IDSnowRock, AvoidImpassableLand);
		rmAddObjectDefConstraint	(IDSnowRock, AvoidCliffShort);
		rmPlaceObjectDefInArea		(IDSnowRock, 0, rmAreaID("patch"+i), 1);
	}
	
	for(i = 1; < cNumberPlayers*10) 
	{
		int IDPatchDirt			= rmCreateArea("dirt patch"+i);
		rmSetAreaSize			(IDPatchDirt, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		rmSetAreaWarnFailure	(IDPatchDirt, false); 
		rmSetAreaTerrainType	(IDPatchDirt, "DirtA");
		rmSetAreaMinBlobs		(IDPatchDirt, 1);
		rmSetAreaMaxBlobs		(IDPatchDirt, 5);
		rmSetAreaMinBlobDistance(IDPatchDirt, 16.0);
		rmSetAreaMaxBlobDistance(IDPatchDirt, 40.0);
		rmAddAreaConstraint		(IDPatchDirt, AvoidPlayer);
		rmAddAreaToClass		(IDPatchDirt, classPatch);
		rmAddAreaConstraint		(IDPatchDirt, AvoidPatch); 
		rmAddAreaConstraint		(IDPatchDirt, AvoidCliffShort); 
		rmAddAreaConstraint		(IDPatchDirt, AvoidOcean); 
		rmSetAreaCoherence		(IDPatchDirt, 0.4);
		rmSetAreaSmoothDistance	(IDPatchDirt, 8);
	
		if(rmBuildArea(IDPatchDirt) == false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3)
			break;
		}
		else
			failCount=0;
	}
	
	int numTries = 40*cNumberNonGaiaPlayers;
	failCount = 0;
	for(i = 0; < numTries)
	{
		int IDElev				= rmCreateArea("elev"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation		(IDElev, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure	(IDElev, false);
		rmAddAreaConstraint		(IDElev, AvoidCliffShort);
		rmAddAreaConstraint		(IDElev, AvoidOcean); 
		if(rmRandFloat(0.0, 1.0)<0.5)
			rmSetAreaTerrainType(IDElev, "SnowSand50");
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 5);
		rmSetAreaMinBlobDistance(IDElev, 16.0);
		rmSetAreaMaxBlobDistance(IDElev, 40.0);
		rmSetAreaCoherence		(IDElev, 0.0);
	
		if(rmBuildArea(IDElev) == false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if (failCount == 3)
				break;
		}
		else
			failCount=0;
	}
	
	numTries = 10*cNumberNonGaiaPlayers;
	failCount = 0;
	for (i = 0; < numTries)
	{
		int IDWrinkle			= rmCreateArea("wrinkle"+i);
		rmSetAreaSize			(IDWrinkle, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
		rmSetAreaLocation		(IDWrinkle, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
		rmSetAreaWarnFailure	(IDWrinkle, false);
		rmSetAreaBaseHeight		(IDWrinkle, rmRandFloat(3.0, 4.0));
		rmSetAreaMinBlobs		(IDWrinkle, 1);
		rmSetAreaMaxBlobs		(IDWrinkle, 3);
		rmSetAreaMinBlobDistance(IDWrinkle, 12.0);
		rmSetAreaMaxBlobDistance(IDWrinkle, 20.0);
		rmSetAreaCoherence		(IDWrinkle, 0.0);
		rmAddAreaConstraint		(IDWrinkle, AvoidCliffShort);
		rmAddAreaConstraint		(IDWrinkle, AvoidAll);
		rmAddAreaConstraint		(IDWrinkle, AvoidOcean); 
		if(rmBuildArea(IDWrinkle) == false)
		{
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3)
				break;
		}
		else
			failCount=0;
	}
   
	rmSetStatusText("",0.65);
	///OBJECT PLACEMENT
	rmPlaceObjectDefPerPlayer(IDStartingGold, false, 2);
	rmPlaceObjectDefPerPlayer(IDStartingTower, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingBoar, false, 1);
	rmPlaceObjectDefPerPlayer(IDStartingGoat, true, 1);
	
	if (rmRandFloat(0,1) < 0.5) 
	rmPlaceObjectDefPerPlayer(IDStartingChicken, false);
		else 
	rmPlaceObjectDefPerPlayer(IDStartingBerry, false);

	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(5,8));
	
	rmPlaceObjectDefPerPlayer(IDMediumGoat, false, rmRandInt(1,2));

	if (cNumberNonGaiaPlayers < 3) {
		rmPlaceObjectDefPerPlayer(IDFarGold, false, rmRandInt(1,2));
		rmPlaceObjectDefPerPlayer(IDFarGold2, false, rmRandInt(1,2));
	} else {
		rmPlaceObjectDefInArea(IDFarGold3, 0, IDGoldArea, cNumberNonGaiaPlayers*rmRandInt(2, 3));
	}
	rmPlaceObjectDefPerPlayer(IDFarGoat, false, rmRandInt(1,2));
	rmPlaceObjectDefPerPlayer(IDPred, false);
	rmPlaceObjectDefPerPlayer(IDFarHunt, false);
	rmPlaceObjectDefAtLoc(IDFarBerrys, 0, 0.5, 0.5, cNumberPlayers);
	rmPlaceObjectDefPerPlayer(IDRelic, false);
	
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, 1);
		rmPlaceObjectDefPerPlayer(giantGold2ID, false, 2);
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	if(cNumberNonGaiaPlayers == 2){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(IDFish, 0, 6*cNumberNonGaiaPlayers, 0.975, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 6*cNumberNonGaiaPlayers, 0.025, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(IDFish, 0, 3*cNumberNonGaiaPlayers, 0.985, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 3*cNumberNonGaiaPlayers, 0.015, 0.0, 1.0, 0.01);
		}
	} else if(cNumberNonGaiaPlayers <= 4){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.95, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.05, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.965, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.035, 0.0, 1.0, 0.01);
		}
	} else if(cNumberNonGaiaPlayers <= 6){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.9525, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.0475, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.955, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.045, 0.0, 1.0, 0.01);
		}
	} else if(cNumberNonGaiaPlayers == 8){
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.9475, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.0525, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.95, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.05, 0.0, 1.0, 0.01);
		}
	} else {
		if(cMapSize == 2){
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.945, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 5+2*cNumberNonGaiaPlayers, 0.055, 0.0, 1.0, 0.01);
		} else {
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.945, 0.0, 1.0, 0.01);
			rmPlaceObjectDefInLineX(IDFish, 0, 1+2*cNumberNonGaiaPlayers, 0.055, 0.0, 1.0, 0.01);
		}
	}
	
	rmSetStatusText("",0.85);
	///FORESTS
	int forestCount = 10*cNumberNonGaiaPlayers*mapSizeMultiplier;
	failCount = 0;
	for (i = 0; < forestCount)
	{
		int IDForest 			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(60*mapSizeMultiplier), rmAreaTilesToFraction(120*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		
		if(rmRandFloat(0.0, 1.0) < 0.25)
			rmSetAreaForestType	(IDForest, "mixed pine forest");
		else
			rmSetAreaForestType	(IDForest, "pine forest");
		
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidCliffMed);
		rmAddAreaConstraint		(IDForest, AvoidImpassableLand);
		rmAddAreaConstraint		(IDForest, AvoidStartingTc);
		rmAddAreaToClass		(IDForest, classForest);
		rmSetAreaMinBlobs		(IDForest, 0*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDForest, 3*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDForest, 0.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDForest, 10.0*mapSizeMultiplier);
		rmSetAreaCoherence		(IDForest, 0.0);
	
		if(rmBuildArea(IDForest) == false)
		{
			failCount++;
			if(failCount == 3)
			break;
		}
		else
			failCount = 0;
	}
	
	rmPlaceObjectDefAtLoc(IDRandomTree, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
	rmSetStatusText("",0.95);
	///BEAUTIFICATION
	
	int IDRock					= rmCreateObjectDef("rock group");
	rmAddObjectDefItem			(IDRock, "rock sandstone sprite", 3, 2.0);
	rmSetObjectDefMinDistance	(IDRock, 0.0);
	rmSetObjectDefMaxDistance	(IDRock, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRock, AvoidAll);
	rmAddObjectDefConstraint	(IDRock, AvoidImpassableLandShort);
	rmAddObjectDefConstraint	(IDRock, AvoidPlayer);
	rmAddObjectDefConstraint	(IDRock, AvoidPatch);
	rmPlaceObjectDefAtLoc		(IDRock, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers); 
	
	int nearshore = rmCreateTerrainMaxDistanceConstraint("seaweed near shore", "land", true, 12.0);
	int farshore = rmCreateTerrainDistanceConstraint("seaweed far from shore", "land", true, 8.0);
	
	int IDKelp					= rmCreateObjectDef("seaweed");
	rmAddObjectDefItem			(IDKelp, "seaweed", 4, 2.0);
	rmSetObjectDefMinDistance	(IDKelp, 0.0);
	rmSetObjectDefMaxDistance	(IDKelp, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDKelp, AvoidAll);
	rmAddObjectDefConstraint	(IDKelp, nearshore);
	rmAddObjectDefConstraint	(IDKelp, farshore);
	rmPlaceObjectDefAtLoc		(IDKelp, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);
	
	int IDSeaweed				= rmCreateObjectDef("seaweed 2");
	rmAddObjectDefItem			(IDSeaweed, "seaweed", 1, 0.0);
	rmSetObjectDefMinDistance	(IDSeaweed, 0.0);
	rmSetObjectDefMaxDistance	(IDSeaweed, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDSeaweed, AvoidAll);
	rmAddObjectDefConstraint	(IDSeaweed, nearshore);
	rmAddObjectDefConstraint	(IDSeaweed, farshore);
	rmPlaceObjectDefAtLoc		(IDSeaweed, 0, 0.5, 0.5, 6*cNumberNonGaiaPlayers); 
	
	rmSetStatusText("",1.0);
}
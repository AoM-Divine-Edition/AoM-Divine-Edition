/*Savannah
**Made by Hagrit (Original concept Ensemble Studios)
*/
void main(void)
{
	///INITIALIZE MAP
	rmSetStatusText("",0.01);

	// Set size.
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

	rmTerrainInitialize("SavannahA");
	
	rmSetStatusText("",0.10);
	///CLASSES
	int classPlayer			= rmDefineClass("player");
	int classCorner			= rmDefineClass("corner");
	int classStartingSettle	= rmDefineClass("starting settlement");
	int classPond			= rmDefineClass("pond");
	int classForest			= rmDefineClass("forest");
	int classBonusHuntable	= rmDefineClass("bonus huntable");
	int classCenter			= rmDefineClass("center");
	int classAvoidCorner	= rmDefineClass("Avoid Corner");
	
	rmSetStatusText("",0.15);
	///CONSTRAINTS
	int AvoidEdge	= rmCreateBoxConstraint	("B0", rmXTilesToFraction(6), rmZTilesToFraction(6), 1.0-rmXTilesToFraction(6), 1.0-rmZTilesToFraction(6));
	
	int AvoidAll			= rmCreateTypeDistanceConstraint ("T0", "all", 6.0);
	int AvoidTower			= rmCreateTypeDistanceConstraint ("T1", "tower", 25.0);
	int AvoidBuildings		= rmCreateTypeDistanceConstraint ("T2", "Building", 20.0);
	int AvoidGold			= rmCreateTypeDistanceConstraint ("T3", "gold", 30.0);
	int AvoidSettlementAbit	= rmCreateTypeDistanceConstraint ("T4", "AbstractSettlement", 21.0);
	int AvoidHerdable		= rmCreateTypeDistanceConstraint ("T5", "herdable", 20.0);
	int AvoidPredator		= rmCreateTypeDistanceConstraint ("T6", "animalPredator", 20.0);
	int AvoidHuntable		= rmCreateTypeDistanceConstraint ("T7", "huntable", 20.0);
	int AvoidGoldFar		= rmCreateTypeDistanceConstraint ("T8", "gold", 40.0);
	int AvoidBerry			= rmCreateTypeDistanceConstraint ("T9", "berry bush", 30.0);
	int AvoidSettlementTiny	= rmCreateTypeDistanceConstraint ("T10", "AbstractSettlement", 8.0);
	
	int AvoidPlayer					= rmCreateClassDistanceConstraint ("C0", classPlayer, 22.0);
	int AvoidPond					= rmCreateClassDistanceConstraint ("C1", classPond, 20.0);
	int AvoidForest					= rmCreateClassDistanceConstraint ("C2", classForest, 25.0);
	int AvoidStartingSettle			= rmCreateClassDistanceConstraint ("C3", classStartingSettle, 70.0);
	int AvoidStartingSettleShort	= rmCreateClassDistanceConstraint ("C4", classStartingSettle, 40.0);
	int AvoidBonusHunt				= rmCreateClassDistanceConstraint ("C5", classBonusHuntable, 50.0);
	int AvoidCenter					= rmCreateClassDistanceConstraint ("C6", classCenter, 40.0);
	int AvoidCenterShort			= rmCreateClassDistanceConstraint ("C7", classCenter, 10.0);
	int AvoidCorner					= rmCreateClassDistanceConstraint ("C8", classCorner, 20.0);
	int AvoidCornerShort			= rmCreateClassDistanceConstraint ("C9", classCorner, 1.0);
	int InCorner					= rmCreateClassDistanceConstraint ("C10", classAvoidCorner, 1.0);
	int AvoidCenterShortest			= rmCreateClassDistanceConstraint ("C11", classCenter, 8.0);
	int AvoidStartingSettleShortest	= rmCreateClassDistanceConstraint ("C12", classStartingSettle, 22.0);
	
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
	rmSetObjectDefMinDistance 	(IDStartingTower, 24.0);
	rmSetObjectDefMaxDistance 	(IDStartingTower, 27.0);
	
	int GoldDistance = rmRandInt(20,24);
	
	int IDStartingGold			= rmCreateObjectDef("starting goldmine");
	rmAddObjectDefItem			(IDStartingGold, "Gold mine small", 1, 0.0);
	rmSetObjectDefMinDistance 	(IDStartingGold, GoldDistance);
	rmSetObjectDefMaxDistance 	(IDStartingGold, GoldDistance);
	
	int IDStartingGoat			= rmCreateObjectDef("close goats");
	rmAddObjectDefItem			(IDStartingGoat, "goat", rmRandInt(1,3), 2.0);
	rmSetObjectDefMinDistance	(IDStartingGoat, 25.0);
	rmSetObjectDefMaxDistance	(IDStartingGoat, 30.0);
	rmAddObjectDefConstraint	(IDStartingGoat, AvoidAll);
	
	int IDStartingBerry 	 	= rmCreateObjectDef("starting berry");
	if(rmRandFloat(0,1)<0.8)
		rmAddObjectDefItem		(IDStartingBerry, "chicken", rmRandInt(6,12), 5.0);
	else
		rmAddObjectDefItem		(IDStartingBerry, "berry bush", rmRandInt(5,9), 4.0);
	rmSetObjectDefMinDistance 	(IDStartingBerry, 20.0);
	rmSetObjectDefMaxDistance 	(IDStartingBerry, 25.0);
	rmAddObjectDefConstraint  	(IDStartingBerry, AvoidAll);
	
	float huntableNumber = rmRandFloat(0, 1);
	int IDStartingHunt			= rmCreateObjectDef("close huntable");
	
	if (huntableNumber < 0.1) {  
		rmAddObjectDefItem		(IDStartingHunt, "zebra", rmRandInt(3,5), 3.0);
		rmAddObjectDefItem		(IDStartingHunt, "gazelle", rmRandInt(2,6), 4.0);
	} else if (huntableNumber < 0.3)
		rmAddObjectDefItem		(IDStartingHunt, "zebra", rmRandInt(2,3), 2.0);
	else if (huntableNumber < 0.6)	
		rmAddObjectDefItem		(IDStartingHunt, "rhinocerous", 1, 2.0);
	else if (huntableNumber < 0.9)
		rmAddObjectDefItem		(IDStartingHunt, "rhinocerous", 2, 2.0);
	else if (huntableNumber < 1.0)
		rmAddObjectDefItem		(IDStartingHunt, "rhinocerous", 4, 2.0);
	
	rmSetObjectDefMinDistance	(IDStartingHunt, 23.0);
	rmSetObjectDefMaxDistance	(IDStartingHunt, 28.0);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDStartingHunt, AvoidEdge);
   
	int IDStragglerTree			= rmCreateObjectDef("straggler tree");
	rmAddObjectDefItem			(IDStragglerTree, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDStragglerTree, 12.0);
	rmSetObjectDefMaxDistance	(IDStragglerTree, 15.0);
	rmAddObjectDefConstraint	(IDStragglerTree, AvoidAll);
	
	//medium
	int IDMediumGold			= rmCreateObjectDef("medium gold");
	rmAddObjectDefItem			(IDMediumGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDMediumGold, 50.0);
	rmSetObjectDefMaxDistance	(IDMediumGold, 60.0);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidGold);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidStartingSettleShort);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCenter);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidCorner);
	rmAddObjectDefConstraint	(IDMediumGold, AvoidTower);
	
	int IDMediumGoat			= rmCreateObjectDef("medium goats");
	rmAddObjectDefItem			(IDMediumGoat, "goat", rmRandInt(0,3), 4.0);
	rmSetObjectDefMinDistance	(IDMediumGoat, 52.0);
	rmSetObjectDefMaxDistance	(IDMediumGoat, 70.0);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidStartingSettleShort);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidEdge);
	rmAddObjectDefConstraint	(IDMediumGoat, AvoidHerdable);
	
	int IDMediumHunt			=rmCreateObjectDef("medium gazelle");
	if(rmRandFloat(0,1)<0.5)
		rmAddObjectDefItem		(IDMediumHunt, "gazelle", rmRandInt(3, 9), 4.0);
	else
		rmAddObjectDefItem		(IDMediumHunt, "giraffe", rmRandInt(3, 9), 4.0);
	rmSetObjectDefMinDistance	(IDMediumHunt, 52.0);
	rmSetObjectDefMaxDistance	(IDMediumHunt, 70.0);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidStartingSettleShort);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidEdge);
	if (rmRandFloat(0,1)<0.85) {
		rmAddObjectDefConstraint	(IDMediumHunt, AvoidCornerShort);
	} else {
		rmAddObjectDefConstraint	(IDMediumHunt, InCorner);
	}
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidAll);
	rmAddObjectDefConstraint	(IDMediumHunt, AvoidTower);
	
	//far 
	int IDFarGold				= rmCreateObjectDef("far gold");
	rmAddObjectDefItem			(IDFarGold, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance	(IDFarGold, 75.0);
	
	if (cNumberNonGaiaPlayers < 3) {
		rmSetObjectDefMaxDistance	(IDFarGold, 90.0);
		rmAddObjectDefConstraint	(IDFarGold, AvoidCorner);
	} else 
	rmSetObjectDefMaxDistance	(IDFarGold, 120.0);

	rmAddObjectDefConstraint	(IDFarGold, AvoidGoldFar);
	rmAddObjectDefConstraint	(IDFarGold, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGold, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDFarGold, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGold, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGold, AvoidCenterShortest);
	
	int IDFarGoat				= rmCreateObjectDef("far goats");
	rmAddObjectDefItem			(IDFarGoat, "goat", rmRandInt(1,2), 4.0);
	rmSetObjectDefMinDistance	(IDFarGoat, 80.0);
	rmSetObjectDefMaxDistance	(IDFarGoat, 150.0);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidAll);
	rmAddObjectDefConstraint	(IDFarGoat, AvoidHerdable);
	
	float predatorSpecies=rmRandFloat(0, 1);
	
	int IDFarPredator			= rmCreateObjectDef("far predator");
	if(predatorSpecies<0.5)   
		rmAddObjectDefItem		(IDFarPredator, "lion", 2, 4.0);
	else
		rmAddObjectDefItem		(IDFarPredator, "hyena", 3, 4.0);
	rmSetObjectDefMinDistance	(IDFarPredator, 50.0);
	rmSetObjectDefMaxDistance	(IDFarPredator, 100.0);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidPredator);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarPredator, AvoidAll);
	
	int IDFarBerries			= rmCreateObjectDef("far berries");
	rmAddObjectDefItem			(IDFarBerries, "berry bush", 10, 4.0);
	rmSetObjectDefMinDistance	(IDFarBerries, 80.0);
	rmSetObjectDefMaxDistance	(IDFarBerries, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDFarBerries, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidBerry);
	rmAddObjectDefConstraint	(IDFarBerries, AvoidAll);
	

    float bonusChance=rmRandFloat(0, 1);
	int IDBonusHunt				= rmCreateObjectDef("bonus huntable");
	if(bonusChance<0.2)
	{   
		rmAddObjectDefItem		(IDBonusHunt, "zebra", rmRandInt(2,4), 3.0);
		rmAddObjectDefItem		(IDBonusHunt, "giraffe", rmRandInt(0,2), 3.0);
	}
	else if(bonusChance<0.5)
		rmAddObjectDefItem		(IDBonusHunt, "zebra", rmRandInt(4,6), 3.0);
	else if(bonusChance<0.9)
		rmAddObjectDefItem		(IDBonusHunt, "giraffe", rmRandInt(3,4), 2.0);
	else
		rmAddObjectDefItem		(IDBonusHunt, "gazelle", rmRandInt(4,7), 3.0);
	rmSetObjectDefMinDistance	(IDBonusHunt, 85.0);
	rmSetObjectDefMaxDistance	(IDBonusHunt, 105.0);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidHuntable);
	rmAddObjectDefToClass		(IDBonusHunt, classBonusHuntable);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidEdge);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidCenterShort);
	rmAddObjectDefConstraint	(IDBonusHunt, AvoidAll);
	
	int IDBonusHunt2			= rmCreateObjectDef("second bonus huntable");
	bonusChance=rmRandFloat(0, 1);
	if(bonusChance<0.1)   
		rmAddObjectDefItem		(IDBonusHunt2, "elephant", 3, 2.0);
	else if(bonusChance<0.5)
		rmAddObjectDefItem		(IDBonusHunt2, "elephant", 2, 2.0);
	else if(bonusChance<0.9)
		rmAddObjectDefItem		(IDBonusHunt2, "rhinocerous", 2, 2.0);
	else
		rmAddObjectDefItem		(IDBonusHunt2, "rhinocerous", 4, 4.0);
	rmSetObjectDefMinDistance	(IDBonusHunt2, 80);
	rmSetObjectDefMaxDistance	(IDBonusHunt2, 110);
	rmAddObjectDefToClass		(IDBonusHunt2, classBonusHuntable);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidBonusHunt);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidHuntable);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidEdge);
	rmAddObjectDefConstraint	(IDBonusHunt2, AvoidAll);
	
	int IDRandomTree			= rmCreateObjectDef("random tree");
	rmAddObjectDefItem			(IDRandomTree, "savannah tree", 1, 0.0);
	rmSetObjectDefMinDistance	(IDRandomTree, 0.0);
	rmSetObjectDefMaxDistance	(IDRandomTree, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDRandomTree, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint	(IDRandomTree, AvoidSettlementAbit);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDRandomTree, AvoidAll);
	
	int IDFarMonkey				= rmCreateObjectDef("far monkeys");
	rmAddObjectDefItem			(IDFarMonkey, "baboon", rmRandInt(4,9), 4.0);
	rmSetObjectDefMinDistance	(IDFarMonkey, 0.0);
	rmSetObjectDefMaxDistance	(IDFarMonkey, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDFarMonkey, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDFarMonkey, AvoidImpassableLand);
	rmAddObjectDefConstraint	(IDFarMonkey, AvoidEdge);
	rmAddObjectDefConstraint	(IDFarMonkey, AvoidAll);
	
	int IDBirds					= rmCreateObjectDef("far hawks");
	rmAddObjectDefItem			(IDBirds, "vulture", 1, 0.0);
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
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.33));
		rmSetObjectDefMaxDistance(giantGoldID, rmXFractionToMeters(0.45));
		rmAddObjectDefConstraint(giantGoldID, AvoidGoldFar);
		rmAddObjectDefConstraint(giantGoldID, AvoidEdge);
		rmAddObjectDefConstraint(giantGoldID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantGoldID, AvoidImpassableLand);
		
		int giantHuntableID=rmCreateObjectDef("giant huntable");
		bonusChance=rmRandFloat(0, 1);
		if(bonusChance<0.33) {
			rmAddObjectDefItem(giantHuntableID, "elephant", 2, 2.0);
		} else if(bonusChance<0.66) {
			rmAddObjectDefItem(giantHuntableID, "rhinocerous", 3, 2.0);
		} else {
			rmAddObjectDefItem(giantHuntableID, "baboon", 8, 6.0);
		}
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.325));
		rmSetObjectDefMaxDistance(giantHuntableID, rmXFractionToMeters(0.38));
		rmAddObjectDefConstraint(giantHuntableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHuntableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntableID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntableID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntableID, AvoidHuntable);
		
		int giantHuntable2ID=rmCreateObjectDef("giant huntable2");
		rmAddObjectDefItem(giantHuntable2ID, "Zebra", rmRandInt(4,5), 5.0);
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.28));
		rmSetObjectDefMaxDistance(giantHuntable2ID, rmXFractionToMeters(0.40));
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidSettlementAbit);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidEdge);
		rmAddObjectDefConstraint(giantHuntable2ID, AvoidHuntable);
		
		int giantHerdableID=rmCreateObjectDef("giant herdable");
		rmAddObjectDefItem(giantHerdableID, "goat", rmRandInt(3,4), 5.0);
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.30));
		rmSetObjectDefMaxDistance(giantHerdableID, rmXFractionToMeters(0.39));
		rmAddObjectDefConstraint(giantHerdableID, AvoidStartingSettle);
		rmAddObjectDefConstraint(giantHerdableID, AvoidImpassableLand);
		rmAddObjectDefConstraint(giantHerdableID, AvoidHuntable);
		rmAddObjectDefConstraint(giantHerdableID, AvoidAll);
		rmAddObjectDefConstraint(giantHerdableID, AvoidEdge);
		
		int giantRelixID = rmCreateObjectDef("giant Relix");
		rmAddObjectDefItem(giantRelixID, "relic", 1, 5.0);
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.0));
		rmSetObjectDefMaxDistance(giantRelixID, rmXFractionToMeters(0.5));
		rmAddObjectDefConstraint(giantRelixID, rmCreateTypeDistanceConstraint("relix avoid relix", "relic", 110.0));
		rmAddObjectDefConstraint(giantRelixID, AvoidAll);
		rmAddObjectDefConstraint(giantRelixID, AvoidEdge);
	}
	
	rmSetStatusText("",0.40);
	///DEFINE PLAYER LOCATIONS
	if(cNumberNonGaiaPlayers < 10) {
		rmSetTeamSpacingModifier(0.75);
		rmPlacePlayersCircular(0.32, 0.38, rmDegreesToRadians(0.0));
	} else {
		rmSetTeamSpacingModifier(0.85);
		rmPlacePlayersCircular(0.35, 0.43, rmDegreesToRadians(5.0));
	}
	
	rmSetStatusText("",0.45);
	///AREA DEFINITION
	float playerFraction=rmAreaTilesToFraction(4000);
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
		rmSetAreaTerrainType	(AreaPlayer, "SavannahA");
	}
	
	rmBuildAllAreas();

	for(i=1; <cNumberPlayers*100*mapSizeMultiplier)
	{
		int AreaDirtPatch		= rmCreateArea("dirt patch"+i);
		rmSetAreaSize			(AreaDirtPatch, rmAreaTilesToFraction(20), rmAreaTilesToFraction(40*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaDirtPatch, "SavannahB");
		rmSetAreaMinBlobs		(AreaDirtPatch, 1);
		rmSetAreaMaxBlobs		(AreaDirtPatch, 5);
		rmSetAreaWarnFailure	(AreaDirtPatch, false);
		rmSetAreaMinBlobDistance(AreaDirtPatch, 16.0);
		rmSetAreaMaxBlobDistance(AreaDirtPatch, 40.0);
		rmSetAreaCoherence		(AreaDirtPatch, 0.0);
		rmBuildArea(AreaDirtPatch);
	}
	
	for(i=1; <cNumberPlayers*30*mapSizeMultiplier)
	{
		// Beautification sub area.
		int AreaSandPatch		= rmCreateArea("Grass patch"+i);
		rmSetAreaSize			(AreaSandPatch, rmAreaTilesToFraction(10*mapSizeMultiplier), rmAreaTilesToFraction(50*mapSizeMultiplier));
		rmSetAreaTerrainType	(AreaSandPatch, "SandA");
		rmSetAreaMinBlobs		(AreaSandPatch, 1*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(AreaSandPatch, 5*mapSizeMultiplier);
		rmSetAreaWarnFailure	(AreaSandPatch, false);
		rmSetAreaMinBlobDistance(AreaSandPatch, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(AreaSandPatch, 40.0*mapSizeMultiplier);
		rmSetAreaCoherence		(AreaSandPatch, 0.0);
	
		rmBuildArea(AreaSandPatch);
	}

	int numPond=1*cNumberNonGaiaPlayers*mapSizeMultiplier;
	for(i=0; <numPond)
	{
		int IDPond				= rmCreateArea("small pond"+i);
		rmSetAreaSize			(IDPond, rmAreaTilesToFraction(400), rmAreaTilesToFraction(600));
		rmSetAreaWaterType		(IDPond, "savannah water hole");
		rmSetAreaMinBlobs		(IDPond, 1);
		rmSetAreaMaxBlobs		(IDPond, 1);
		rmSetAreaSmoothDistance	(IDPond, 25);
		rmAddAreaToClass		(IDPond, classPond);
		rmAddAreaConstraint		(IDPond, AvoidPond);
		rmAddAreaConstraint		(IDPond, AvoidEdge);
		rmAddAreaConstraint		(IDPond, AvoidPlayer);
		rmSetAreaBaseHeight		(IDPond, 1);
		rmSetAreaWarnFailure	(IDPond, false);
		
		rmBuildArea(IDPond);
	}
	
	int numTries=40*cNumberNonGaiaPlayers*mapSizeMultiplier;
	int failCount=0;
	for(i=0; <numTries)
	{
		int IDElev				= rmCreateArea("wrinkle"+i);
		rmSetAreaSize			(IDElev, rmAreaTilesToFraction(20*mapSizeMultiplier), rmAreaTilesToFraction(80*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDElev, false);
		rmSetAreaTerrainType	(IDElev, "SavannahC");
		rmSetAreaBaseHeight		(IDElev, rmRandFloat(2.0, 4.0));
		rmAddAreaConstraint		(IDElev, AvoidImpassableLand);
		rmAddAreaConstraint		(IDElev, AvoidBuildings);
		rmSetAreaHeightBlend	(IDElev, 1);
		rmSetAreaMinBlobs		(IDElev, 1);
		rmSetAreaMaxBlobs		(IDElev, 3*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDElev, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDElev, 20.0*mapSizeMultiplier);
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
	rmSetAreaSize			(AreaNonCorner, 0.75, 0.75);
	rmSetAreaLocation		(AreaNonCorner, 0.5, 0.5);
	rmSetAreaWarnFailure	(AreaNonCorner, false);
	rmAddAreaToClass		(AreaNonCorner, classAvoidCorner);
	rmSetAreaCoherence		(AreaNonCorner, 1.0);
	
	rmBuildArea(AreaNonCorner);
	
	
	rmSetStatusText("",0.55);
	///SETTLEMENTS
	rmPlaceObjectDefPerPlayer(IDStartingSettlement, true);
	
	int AreaSettle = rmAddFairLoc("Settlement", false, true,  60, 80, 40, 25);
	
	if (cNumberNonGaiaPlayers < 3)
	{
		rmAddFairLocConstraint	(AreaSettle, AvoidCorner);
	}
	
	
	if(rmRandFloat(0,1) < 0.75)
		AreaSettle = rmAddFairLoc("Settlement", true, false, 85, 100, 75, 60);
	else
		AreaSettle = rmAddFairLoc("Settlement", false, true,  70, 85, 60, 25);
	
	if (cMapSize == 2) {
		AreaSettle = rmAddFairLoc("Settlement", true, false,  100, 170, 75, 50);
		
		AreaSettle = rmAddFairLoc("Settlement", true, false,  120, 200, 75, 50);
	}
	
	rmAddFairLocConstraint	(AreaSettle, AvoidPond);
	rmAddFairLocConstraint	(AreaSettle, AvoidCenterShort);
	rmAddFairLocConstraint	(AreaSettle, AvoidCorner);
	
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
	
	rmSetStatusText("",0.65);
	///PLACE OBJECTS
	rmPlaceObjectDefPerPlayer(IDStartingTower, true, 4);
	rmPlaceObjectDefPerPlayer(IDStartingGold, false);
	rmPlaceObjectDefPerPlayer(IDStartingBerry, false);
	rmPlaceObjectDefPerPlayer(IDStartingHunt, false);
	rmPlaceObjectDefPerPlayer(IDStartingGoat, true);
	rmPlaceObjectDefPerPlayer(IDStragglerTree, false, rmRandInt(2.0, 4.0));
	
	rmPlaceObjectDefPerPlayer(IDMediumGold, false, rmRandInt(1.0,2.0));
	rmPlaceObjectDefPerPlayer(IDMediumGoat, false, 2);
	rmPlaceObjectDefPerPlayer(IDMediumHunt, false);
	
	rmPlaceObjectDefPerPlayer(IDFarGold, false, rmRandInt(3, 4));
	rmPlaceObjectDefPerPlayer(IDBonusHunt, false);
	rmPlaceObjectDefPerPlayer(IDBonusHunt2, false);
	rmPlaceObjectDefPerPlayer(IDFarGoat, false);
	rmPlaceObjectDefPerPlayer(IDFarPredator, false);
	
	
	
	if(rmRandFloat(0,1)<0.5)
		rmPlaceObjectDefPerPlayer(IDFarMonkey, false, 1); 
	
	if(rmRandFloat(0,1)<0.6)
      rmPlaceObjectDefPerPlayer(IDFarBerries, false);
  
	rmPlaceObjectDefPerPlayer(IDBirds, false, 2); 
	rmPlaceObjectDefPerPlayer(IDRelic, false); 
	
	//giant
	if (cMapSize == 2) {
		rmPlaceObjectDefPerPlayer(giantGoldID, false, rmRandInt(1, 2));
		rmPlaceObjectDefPerPlayer(giantHuntableID, false, 1);
		rmPlaceObjectDefPerPlayer(giantHuntable2ID, false, 1);
		rmPlaceObjectDefPerPlayer(giantHerdableID, false, rmRandInt(1, 2));
		rmPlaceObjectDefAtLoc(giantRelixID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	rmSetStatusText("",0.75);
	///FORESTS
	failCount=0;
	numTries=15*cNumberNonGaiaPlayers*mapSizeMultiplier;
	for(i=0; <numTries)
	{
		int IDForest			= rmCreateArea("forest"+i);
		rmSetAreaSize			(IDForest, rmAreaTilesToFraction(50*mapSizeMultiplier), rmAreaTilesToFraction(100*mapSizeMultiplier));
		rmSetAreaWarnFailure	(IDForest, false);
		rmSetAreaForestType		(IDForest, "savannah forest");
		rmAddAreaConstraint		(IDForest, AvoidStartingSettleShortest);
		rmAddAreaConstraint		(IDForest, AvoidAll);
		rmAddAreaConstraint		(IDForest, AvoidForest);
		rmAddAreaConstraint		(IDForest, AvoidSettlementTiny);
		rmAddAreaConstraint		(IDForest, AvoidImpassableLand);
		rmAddAreaToClass		(IDForest, classForest);
		
		rmSetAreaMinBlobs		(IDForest, 3*mapSizeMultiplier);
		rmSetAreaMaxBlobs		(IDForest, 7*mapSizeMultiplier);
		rmSetAreaMinBlobDistance(IDForest, 16.0*mapSizeMultiplier);
		rmSetAreaMaxBlobDistance(IDForest, 40.0*mapSizeMultiplier);
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
	///BEAUTIFICATION
	for(i=0; <numPond)
	{
		int lilyID					= rmCreateObjectDef("lily"+i);
		rmAddObjectDefItem			(lilyID, "water lilly", rmRandInt(3,6), 6.0);
		rmSetObjectDefMinDistance	(lilyID, 0.0);
		rmSetObjectDefMaxDistance	(lilyID, rmXFractionToMeters(0.5));
		rmPlaceObjectDefInArea		(lilyID, 0, rmAreaID("small pond"+i), rmRandInt(2,4));   
	}
	
	for(i=0; <numPond)
	{
		int decorationID			= rmCreateObjectDef("decoration"+i);
		rmAddObjectDefItem			(decorationID, "water decoration", rmRandInt(1,3), 6.0);
		rmSetObjectDefMinDistance	(decorationID, 0.0);
		rmSetObjectDefMaxDistance	(decorationID, rmXFractionToMeters(0.5));
		rmPlaceObjectDefInArea		(decorationID, 0, rmAreaID("small pond"+i), rmRandInt(2,4));   
	}
	
	int IDLonely				= rmCreateObjectDef("lonely deer");
	if(rmRandFloat(0,1)<0.5)
		rmAddObjectDefItem		(IDLonely, "zebra", 1, 0.0);
	else
		rmAddObjectDefItem		(IDLonely, "giraffe", 1, 0.0);
	rmSetObjectDefMinDistance	(IDLonely, 0.0);
	rmSetObjectDefMaxDistance	(IDLonely, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLonely, AvoidAll);
	rmAddObjectDefConstraint	(IDLonely, AvoidBuildings);
	rmAddObjectDefConstraint	(IDLonely, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDLonely, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDLonely, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int IDLonely2				= rmCreateObjectDef("lonely deer2");
	if(rmRandFloat(0,1)<0.5)
		rmAddObjectDefItem		(IDLonely2, "Lion", 1, 0.0);
	else
		rmAddObjectDefItem		(IDLonely2, "gazelle", 1, 0.0);
	rmSetObjectDefMinDistance	(IDLonely2, 0.0);
	rmSetObjectDefMaxDistance	(IDLonely2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(IDLonely2, AvoidAll);
	rmAddObjectDefConstraint	(IDLonely2, AvoidBuildings);
	rmAddObjectDefConstraint	(IDLonely2, AvoidStartingSettle);
	rmAddObjectDefConstraint	(IDLonely2, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(IDLonely2, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	
	int rockID					= rmCreateObjectDef("rock small");
	rmAddObjectDefItem			(rockID, "rock sandstone small", 1, 0.0);
	rmSetObjectDefMinDistance	(rockID, 0.0);
	rmSetObjectDefMaxDistance	(rockID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(rockID, AvoidAll);
	rmPlaceObjectDefAtLoc		(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int rockID2					= rmCreateObjectDef("rock");
	rmAddObjectDefItem			(rockID2, "rock sandstone sprite", 1, 0.0);
	rmSetObjectDefMinDistance	(rockID2, 0.0);
	rmSetObjectDefMaxDistance	(rockID2, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(rockID2, AvoidAll);
	rmPlaceObjectDefAtLoc		(rockID2, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int bushID					= rmCreateObjectDef("bush");
	rmAddObjectDefItem			(bushID, "bush", 3, 4.0);
	rmSetObjectDefMinDistance	(bushID, 0.0);
	rmSetObjectDefMaxDistance	(bushID, rmXFractionToMeters(0.5));
	rmAddObjectDefConstraint	(bushID, AvoidAll);
	rmAddObjectDefConstraint	(bushID, AvoidImpassableLand);
	rmPlaceObjectDefAtLoc		(bushID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	rmSetStatusText("",1.00);
	
}
// TEAM MIGRATION

// Main entry point for random map script
void main(void)
{
   // Set size.
   int playerTiles=16000;
   if(cMapSize == 1)
   {
      playerTiles = 20800;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Text
   rmSetStatusText("",0.10);

   // Set up default water.
   rmSetSeaLevel(0.0);
   rmSetSeaType("mediterranean sea");

   // Init map.
   rmTerrainInitialize("water");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int bonusIslandClass=rmDefineClass("bonus island");
   int islandClass=rmDefineClass("islandClass");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");
   int classCliff=rmDefineClass("cliff");

   // -------------Define constraints
   
   // Create a edge of map constraint.
   int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(20), rmZTilesToFraction(20), 1.0-rmXTilesToFraction(20), 1.0-rmZTilesToFraction(20), 0.01);
   int teams3StarfishEdgeConstraint=rmCreateBoxConstraint("avoid arms in center island with 3 teams", rmXTilesToFraction(60), rmZTilesToFraction(60), 1.0-rmXTilesToFraction(60), 1.0-rmZTilesToFraction(60), 0.01);
   int teams2StarfishEdgeConstraint=rmCreateBoxConstraint("avoid arms in center island with 2 teams", rmXTilesToFraction(40), rmZTilesToFraction(40), 1.0-rmXTilesToFraction(40), 1.0-rmZTilesToFraction(40), 0.01);

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 10.0);
   int shortPlayerConstraint=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 2.0);

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraint.
   int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("medSet avoids medSet by long distance", "AbstractSettlement", 25.0);
   int farSettleVsFarSettle=rmCreateTypeDistanceConstraint("island Settle vs island Settle", "AbstractSettlement", 50.0);

   // Far starting settlement constraint.
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 70.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Goats/pigs
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

   // Animals
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 15.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
   int farAvoidImpassableLand=rmCreateTerrainDistanceConstraint("MedSet avoids impassable land", "Land", false, 20.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 8.0);

   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("Starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 34.0);
   rmSetObjectDefMaxDistance(startingGoldID, 40.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   // pigs
   int closePigsID=rmCreateObjectDef("close pigs");
   rmAddObjectDefItem(closePigsID, "pig", 2, 2.0);
   rmSetObjectDefMinDistance(closePigsID, 20.0);
   rmSetObjectDefMaxDistance(closePigsID, 25.0);
   rmAddObjectDefConstraint(closePigsID, avoidFood);   

   int numChicken = 0;
   int numBerry = 0;
   float berryChance = rmRandFloat(0,1);
   if(berryChance < 0.25)
   {
      numChicken = 4;
      numBerry = 3;
   }
   else if(berryChance < 0.75)
   {
      numChicken = 8;
      numBerry = 6;
   }
   else
   {
      numChicken = 12;
      numBerry = 9;
   }
      
   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", numChicken, 2.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood);
   
   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", numBerry, 2.0);
   rmSetObjectDefMinDistance(closeBerriesID, 20.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 25.0);
   rmAddObjectDefConstraint(closeBerriesID, avoidFood);  
   
   int closeBoarID=rmCreateObjectDef("close Boar");
   float boarNumber=rmRandFloat(0, 1);
   if(boarNumber<0.3)
      rmAddObjectDefItem(closeBoarID, "hippo", 2, 4.0);
   else if(boarNumber<0.6)
      rmAddObjectDefItem(closeBoarID, "hippo", 3, 4.0);
   else 
      rmAddObjectDefItem(closeBoarID, "hippo", 4, 6.0);
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);

   int transportNearShore=rmCreateTerrainMaxDistanceConstraint("transport near shore", "land", true, 9.0);
   int transportGreekID=rmCreateObjectDef("transport greek");
   rmAddObjectDefItem(transportGreekID, "transport ship greek", 1, 0.0);
   rmSetObjectDefMinDistance(transportGreekID, 0.0);
   rmSetObjectDefMaxDistance(transportGreekID, 70.0);
   rmAddObjectDefConstraint(transportGreekID, transportNearShore);
 //  rmAddObjectDefConstraint(transportGreekID, playerEdgeConstraint);
 
   int transportNorseID=rmCreateObjectDef("transport Norse");
   rmAddObjectDefItem(transportNorseID, "transport ship Norse", 1, 0.0);
   rmSetObjectDefMinDistance(transportNorseID, 0.0);
   rmSetObjectDefMaxDistance(transportNorseID, 70.0);
   rmAddObjectDefConstraint(transportNorseID, transportNearShore);
  // rmAddObjectDefConstraint(transportNorseID, playerEdgeConstraint);
  
   int transportEgyptianID=rmCreateObjectDef("transport Egyptian");
   rmAddObjectDefItem(transportEgyptianID, "transport ship Egyptian", 1, 0.0);
   rmSetObjectDefMinDistance(transportEgyptianID, 0.0);
   rmSetObjectDefMaxDistance(transportEgyptianID, 70.0);
   rmAddObjectDefConstraint(transportEgyptianID, transportNearShore);
  // rmAddObjectDefConstraint(transportEgyptianID, playerEdgeConstraint);

	int transportAtlanteanID=rmCreateObjectDef("transport Atlantean");
   rmAddObjectDefItem(transportAtlanteanID, "transport ship Atlantean", 1, 0.0);
   rmSetObjectDefMinDistance(transportAtlanteanID, 0.0);
   rmSetObjectDefMaxDistance(transportAtlanteanID, 70.0);
   rmAddObjectDefConstraint(transportAtlanteanID, transportNearShore);

   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 28.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
   rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
   
   // Far Objects

   // Settlement avoid Settlements
   int medSettlementID=rmCreateObjectDef("med settlement");
   rmAddObjectDefItem(medSettlementID, "Settlement", 1, 0.0);
   rmSetObjectDefMinDistance(medSettlementID, 40.0);
   rmSetObjectDefMaxDistance(medSettlementID, 120.0);
   rmAddObjectDefConstraint(medSettlementID, farAvoidImpassableLand);
   rmAddObjectDefConstraint(medSettlementID, farAvoidSettlement);

   int farSettlementID=rmCreateObjectDef("far settlement");
   rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
   rmAddObjectDefConstraint(farSettlementID, avoidImpassableLand);
   rmAddObjectDefConstraint(farSettlementID, farSettleVsFarSettle);
         
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);

   // pigs aboid pigs
   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);

   // player fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 24.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 8.0);
   int fishShore = rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 8.0);

   int playerFishID=rmCreateObjectDef("near fish");
   rmAddObjectDefItem(playerFishID, "fish - mahi", 1, 0.0);
   rmSetObjectDefMinDistance(playerFishID, 0.0);
   rmSetObjectDefMaxDistance(playerFishID, 100.0);
   rmAddObjectDefConstraint(playerFishID, fishVsFishID);
   rmAddObjectDefConstraint(playerFishID, fishShore);
   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "lion", 4, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   
   // This map will either use boar or deer as the extra huntable food.


   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.2)
   {   
      rmAddObjectDefItem(bonusHuntableID, "giraffe", 4, 4.0);
      rmAddObjectDefItem(bonusHuntableID, "zebra", 3, 4.0);
   }
   else if(bonusChance<0.4)
      rmAddObjectDefItem(bonusHuntableID, "giraffe", 6, 8.0);
   else if(bonusChance<0.6)
      rmAddObjectDefItem(bonusHuntableID, "water buffalo", 4, 4.0);
   else if(bonusChance<0.8)
      rmAddObjectDefItem(bonusHuntableID, "rhinocerous", 2, 3.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "rhinocerous", 3, 3.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
    
   // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
   
   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 40.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);



   // -------------Done defining objects


   // Cheesy square placement of players.
   rmSetTeamSpacingModifier(0.5);
   if(cNumberNonGaiaPlayers < 4)
      rmPlacePlayersSquare(0.30, 0.05, 0.05);
   else
      rmPlacePlayersSquare(0.35, 0.05, 0.05);

   // bonus island
   int centerAvoidance = 0;
   if(cNumberPlayers < 5)
      centerAvoidance = 30;
   else
      centerAvoidance = 40;

   int islandConstraint=rmCreateClassDistanceConstraint("islands avoid each other", islandClass, 20.0);
   int bonusIslandConstraint=rmCreateClassDistanceConstraint("avoid big island", bonusIslandClass, centerAvoidance);
   int playerIslandConstraint=rmCreateClassDistanceConstraint("avoid player islands", islandClass, centerAvoidance);
   int teamEdgeConstraint=rmCreateBoxConstraint("island edge of map", rmXTilesToFraction(18), rmZTilesToFraction(18), 1.0-rmXTilesToFraction(18), 1.0-rmZTilesToFraction(18), 0.01);

   
/*   rmBuildArea(bonusID); */

   // Build team areas
   float percentPerPlayer = 0.2/cNumberNonGaiaPlayers;
   float teamSize = 0; 

   // Text
   rmSetStatusText("",0.20);

   for(i=0; <cNumberTeams)
   {
      int teamID=rmCreateArea("team"+i);
      teamSize = percentPerPlayer*rmGetNumberPlayersOnTeam(i);
      rmEchoInfo ("team size "+teamSize);
      rmSetAreaSize(teamID, teamSize*0.9, teamSize*1.1);
      rmSetAreaWarnFailure(teamID, false);
      rmSetAreaTerrainType(teamID, "GrassA");
      rmAddAreaTerrainLayer(teamID, "GrassDirt25", 4, 8);
      rmAddAreaTerrainLayer(teamID, "GrassDirt50", 2, 4);
      rmAddAreaTerrainLayer(teamID, "GrassDirt75", 1, 2);
      rmSetAreaMinBlobs(teamID, 1);
      rmSetAreaMaxBlobs(teamID, 5);
      rmSetAreaMinBlobDistance(teamID, 16.0);
      rmSetAreaMaxBlobDistance(teamID, 40.0);
      rmSetAreaCoherence(teamID, 0.4);
      rmSetAreaSmoothDistance(teamID, 10);
      rmSetAreaBaseHeight(teamID, 1.0);
      rmSetAreaHeightBlend(teamID, 2);
      rmAddAreaToClass(teamID, islandClass);
      rmAddAreaConstraint(teamID, islandConstraint);
      rmAddAreaConstraint(teamID, bonusIslandConstraint);
      rmAddAreaConstraint(teamID, teamEdgeConstraint);
      rmSetAreaLocTeam(teamID, i);
      rmEchoInfo("Team area"+i);
   }

 /*  if(cNumberTeams > 2)
      rmBuildAllAreas(); */

   int bonusID=rmCreateArea("bonus island");
   rmSetAreaSize(bonusID, 0.2, 0.2);
   rmAddAreaToClass(bonusID, islandClass);
   rmSetAreaWarnFailure(bonusID, false);
   rmSetAreaLocation(bonusID, 0.5, 0.5);
   rmSetAreaMinBlobs(bonusID, 1);
   rmSetAreaMaxBlobs(bonusID, 5);
   rmSetAreaMinBlobDistance(bonusID, 16.0);
   rmSetAreaMaxBlobDistance(bonusID, 40.0);
   rmSetAreaCoherence(bonusID, 0.0);
   rmSetAreaSmoothDistance(bonusID, 10);
   rmSetAreaBaseHeight(bonusID, 1.0);
   rmSetAreaHeightBlend(bonusID, 2); 
   rmAddAreaToClass(bonusID, bonusIslandClass);
   rmAddAreaConstraint(bonusID, playerIslandConstraint);
   rmAddAreaConstraint(bonusID, teamEdgeConstraint);
   if(cNumberTeams == 2)
      rmAddAreaConstraint(bonusID, teams2StarfishEdgeConstraint);
   else
      rmAddAreaConstraint(bonusID, teams3StarfishEdgeConstraint);
   rmSetAreaTerrainType(bonusID, "GrassA");
   rmAddAreaTerrainLayer(bonusID, "GrassDirt25", 6, 10);
   rmAddAreaTerrainLayer(bonusID, "GrassDirt50", 3, 6);
   rmAddAreaTerrainLayer(bonusID, "GrassDirt75", 1, 3);

	rmBuildAllAreas();

	
  
   // Text
   rmSetStatusText("",0.40);

   // Set up player areas.
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
      rmEchoInfo("Player"+i+"team"+rmGetPlayerTeam(i));

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 1.0, 1.0);
      rmAddAreaToClass(id, classPlayer);

      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 10.0);
      rmSetAreaMaxBlobDistance(id, 20.0);
      rmSetAreaCoherence(id, 0.5);
      rmAddAreaConstraint(id, playerConstraint); 

      // Set the location.
      rmSetAreaLocPlayer(id, i);
      rmSetAreaWarnFailure(id, false);

      // Set type.
      rmSetAreaTerrainType(id, "GrassA");
   }

   rmBuildAllAreas();

   for(i=1; <cNumberPlayers)
   {
      // Beautification sub area.
      int id2=rmCreateArea("Player inner"+i, rmAreaID("player"+i));
      rmSetAreaSize(id2, rmAreaTilesToFraction(200), rmAreaTilesToFraction(300));
      rmSetAreaLocPlayer(id2, i);
      rmSetAreaTerrainType(id2, "GrassDirt75");
      rmAddAreaTerrainLayer(id2, "GrassDirt50", 2, 3);
      rmAddAreaTerrainLayer(id2, "GrassDirt25", 0, 2);
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaWarnFailure(id2, false);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);

      rmBuildArea(id2);
   }

   // Text
   rmSetStatusText("",0.50);

   for(i=1; <cNumberPlayers*12)
   {
      // Beautification sub area.
      int id4=rmCreateArea("Grass patch 2"+i, bonusID);
      rmSetAreaSize(id4, rmAreaTilesToFraction(50), rmAreaTilesToFraction(120));
      rmSetAreaTerrainType(id4, "GrassDirt75");
      rmAddAreaTerrainLayer(id4, "GrassDirt50", 2, 3);
      rmAddAreaTerrainLayer(id4, "GrassDirt25", 0, 2);
      rmSetAreaMinBlobs(id4, 1);
      rmSetAreaMaxBlobs(id4, 5);
      rmSetAreaWarnFailure(id4, false);
      rmSetAreaMinBlobDistance(id4, 16.0);
      rmSetAreaMaxBlobDistance(id4, 40.0);
      rmSetAreaCoherence(id4, 0.0);

      rmBuildArea(id4);
   }

   for(i=1; <cNumberPlayers*8)
   {
      // Beautification sub area.
      int id3=rmCreateArea("Grass patch"+i, bonusID);
      rmSetAreaSize(id3, rmAreaTilesToFraction(5), rmAreaTilesToFraction(20));
      rmSetAreaTerrainType(id3, "GrassB");
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.0);

      rmBuildArea(id3);
   }

	int centerAvoidID=rmCreateArea("center avoid");
   rmSetAreaSize(centerAvoidID, 0.01, 0.01);
   rmSetAreaLocation(centerAvoidID, 0.5, 0.5);
   rmSetAreaMinBlobs(centerAvoidID, 0);
   rmSetAreaMaxBlobs(centerAvoidID, 0);
   rmSetAreaMinBlobDistance(centerAvoidID, 0.0);
   rmSetAreaMaxBlobDistance(centerAvoidID, 0.0);
   rmSetAreaCoherence(centerAvoidID, 1.0);
//	rmSetAreaTerrainType(centerAvoidID, "MarshA");
   rmBuildArea(centerAvoidID);
   
   // Draw cliffs
	int avoidCenterArea=rmCreateAreaDistanceConstraint("avoid center area", centerAvoidID, 10);
   int islandShoreConstraint = rmCreateEdgeDistanceConstraint("bonus island edge", bonusID, 16.0);
   int numCliffs = rmRandInt(1,2);
   if(cNumberNonGaiaPlayers > 3)
      numCliffs = rmRandInt(2,4);
   else if (cNumberNonGaiaPlayers > 5)
      numCliffs = rmRandInt(4,6);    
   for(i=0; <numCliffs)
   {
      int cliffID=rmCreateArea("cliff"+i, bonusID);
      rmSetAreaWarnFailure(cliffID, false);
      rmSetAreaSize(cliffID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(400));
      rmSetAreaCliffType(cliffID, "Greek");
      rmAddAreaConstraint(cliffID, cliffConstraint);
      rmAddAreaConstraint(cliffID, islandShoreConstraint);
		rmAddAreaConstraint(cliffID, avoidCenterArea);
      rmAddAreaToClass(cliffID, classCliff);
      rmSetAreaMinBlobs(cliffID, 10);
      rmSetAreaMaxBlobs(cliffID, 10);
      int edgeRand=rmRandInt(0,100);
      if(edgeRand<33)
      {
      // Inaccesible
         rmSetAreaCliffEdge(cliffID, 1, 1.0, 0.0, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, true, true, true, 1.5, false);
         rmSetAreaTerrainType(cliffID, "cliffGreekA");
      }
      else
      // AOK style
      {
         rmSetAreaCliffEdge(cliffID, 1, 0.6, 0.1, 1.0, 0);
         rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
      }
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);


      rmSetAreaMinBlobDistance(cliffID, 20.0);
      rmSetAreaMaxBlobDistance(cliffID, 20.0);
      rmSetAreaCoherence(cliffID, 0.0);
      rmSetAreaSmoothDistance(cliffID, 10);
      rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
      rmSetAreaHeightBlend(cliffID, 2); 
      rmBuildArea(cliffID);
   }

   // Text
   rmSetStatusText("",0.60);

   // Place stuff.

   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements

   for(i=1; <cNumberPlayers)
   {
      rmPlaceObjectDefInArea(medSettlementID, 0, rmAreaID("player"+i), 1);
   }

   rmPlaceObjectDefInArea(farSettlementID, 0, bonusID, cNumberNonGaiaPlayers);

    // Player elevation.
   for(i=1; <cNumberPlayers)
   {
      int failCount=0;
      int num=rmRandInt(2, 4);
      for(j=0; <num)
      {
         int elevID=rmCreateArea("elev"+i+", "+j, rmAreaID("player"+i));
         rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
         rmSetAreaWarnFailure(elevID, false);
         rmAddAreaConstraint(elevID, avoidBuildings);
         rmAddAreaConstraint(elevID, avoidImpassableLand);
         if(rmRandFloat(0.0, 1.0)<0.3)
            rmSetAreaTerrainType(elevID, "GrassDirt50");
         rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 3.5));

         rmSetAreaMinBlobs(elevID, 1);
         rmSetAreaMaxBlobs(elevID, 5);
         rmSetAreaMinBlobDistance(elevID, 16.0);
         rmSetAreaMaxBlobDistance(elevID, 40.0);
         rmSetAreaCoherence(elevID, 0.0);

         if(rmBuildArea(elevID)==false)
         {
            // Stop trying once we fail 3 times in a row.
            failCount++;
            if(failCount==3)
               break;
         }
         else
            failCount=0;
      }
   }

   // Bonus elevation.
   failCount=0;
   num=rmRandInt(5, 10);
   for(j=0; <num)
   {
      elevID=rmCreateArea("elev"+j, bonusID);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(60), rmAreaTilesToFraction(120));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.7)
         rmSetAreaTerrainType(elevID, "GrassDirt50");
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 3.5));

      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 5 times in a row.
         failCount++;
         if(failCount==5)
            break;
      }
      else
         failCount=0;
   }

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

    // Pigs
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   // Chickens or berries.
   for(i=1; <cNumberPlayers)
   {
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmPlaceObjectDefAtLoc(closeChickensID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else
         rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }

   // Note: here's how to place different objects per player without fair locs
   //Transports
   for(i=0; <cNumberPlayers)
   {
      if(rmGetPlayerCulture(i) == cCultureGreek)
         rmPlaceObjectDefAtLoc(transportGreekID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else if(rmGetPlayerCulture(i) == cCultureNorse)
         rmPlaceObjectDefAtLoc(transportNorseID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else if(rmGetPlayerCulture(i) == cCultureEgyptian)
         rmPlaceObjectDefAtLoc(transportEgyptianID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
		else if(rmGetPlayerCulture(i) == cCultureAtlantean)
         rmPlaceObjectDefAtLoc(transportAtlanteanID, i, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }

   // player fish
   rmPlaceObjectDefPerPlayer(playerFishID, false, 6);

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   // Medium things....
   // Gold
/*   rmPlaceObjectDefPerPlayer(mediumGoldID, false); */

   // Text
   rmSetStatusText("",0.70);  

   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumPigsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
      
   // Far things.
   
   // Gold
   rmPlaceObjectDefInArea(farGoldID, 0, bonusID, rmRandInt(2,3)*cNumberNonGaiaPlayers);

  // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 

   // Relics
   rmPlaceObjectDefInArea(relicID, 0, bonusID, cNumberNonGaiaPlayers);

   // Pigs
   rmPlaceObjectDefInArea(farPigsID, 0, bonusID, 2*cNumberNonGaiaPlayers);

   // Bonus huntable.
   rmPlaceObjectDefInArea(bonusHuntableID, 0, bonusID, cNumberNonGaiaPlayers);

   // Predators
   rmPlaceObjectDefInArea(farPredatorID, 0, bonusID, cNumberNonGaiaPlayers);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

/*   // Crocs.
   rmPlaceObjectDefInRandomAreaOfClass(farCrocsID, false, classBonusIsland, cNumberNonGaiaPlayers); */

   int fishID=rmCreateObjectDef("fish");
   rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
   rmSetObjectDefMinDistance(fishID, 0.0);
   rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(fishID, fishVsFishID);
   rmAddObjectDefConstraint(fishID, fishLand);
   rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 15*cNumberNonGaiaPlayers);

   int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
   int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
   int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
   int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);

   int sharkID=rmCreateObjectDef("shark");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
   else
      rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
   rmSetObjectDefMinDistance(sharkID, 0.0);
   rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(sharkID, sharkVssharkID);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
   rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
   rmAddObjectDefConstraint(sharkID, sharkLand);
   rmAddObjectDefConstraint(sharkID, playerEdgeConstraint);
   rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, 2*cNumberNonGaiaPlayers);


      // Text
   rmSetStatusText("",0.80);
   
   // Forest.
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 10.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 15.0);
   int forestTerrain=rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);

   // Player forests.   
   for(i=1; <cNumberPlayers)
   {
      failCount=0;
      int forestCount=rmRandInt(20, 20);
      for(j=0; <forestCount)
      {
         int forestID=rmCreateArea("player"+i+"forest"+j, rmAreaID("player"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(75), rmAreaTilesToFraction(130));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "palm forest");
         rmAddAreaConstraint(forestID, forestSettleConstraint);
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint);
         rmAddAreaConstraint(forestID, forestTerrain);
         rmAddAreaToClass(forestID, classForest);
      
         rmSetAreaMinBlobs(forestID, 1);
         rmSetAreaMaxBlobs(forestID, 5);
         rmSetAreaMinBlobDistance(forestID, 16.0);
         rmSetAreaMaxBlobDistance(forestID, 40.0);
         rmSetAreaCoherence(forestID, 0.0);
         if(rmBuildArea(forestID)==false)
         {
            // Stop trying once we fail 3 times in a row.
            failCount++;
            if(failCount==3)
               break;
         }
         else
            failCount=0;
      }
   }

   // Random island forests.
   int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 20.0);
   for(i=1; <cNumberPlayers)
   {
      forestCount=rmRandInt(3, 5);
      for(j=0; <forestCount)
      {
         forestID=rmCreateArea("bonus "+i+"forest "+j, bonusID);
         rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
         rmSetAreaWarnFailure(forestID, false);
         if(rmRandFloat(0.0, 1.0)<0.5)
            rmSetAreaForestType(forestID, "palm forest");
         else
            rmSetAreaForestType(forestID, "mixed palm forest");
         rmAddAreaConstraint(forestID, avoidImpassableLand);
         rmAddAreaConstraint(forestID, forestObjConstraint);
         rmAddAreaConstraint(forestID, forestConstraint2);
         rmAddAreaConstraint(forestID, forestTerrain);
         rmAddAreaToClass(forestID, classForest);
         rmSetAreaWarnFailure(forestID, false);
      
         rmSetAreaMinBlobs(forestID, 1);
         rmSetAreaMaxBlobs(forestID, 5);
         rmSetAreaMinBlobDistance(forestID, 16.0);
         rmSetAreaMaxBlobDistance(forestID, 40.0);
         rmSetAreaCoherence(forestID, 0.0);

         // Hill trees?
         if(rmRandFloat(0.0, 1.0)<0.2)
            rmSetAreaBaseHeight(forestID, rmRandFloat(3.0, 4.0));

         rmBuildArea(forestID);
      }
   }

   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 3, 4.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmAddObjectDefConstraint(grassID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 18*cNumberNonGaiaPlayers);

   int rockID=rmCreateObjectDef("rock and grass");
   int avoidRock=rmCreateTypeDistanceConstraint("avoid rock", "rock limestone sprite", 8.0);
   rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
   rmAddObjectDefItem(rockID, "grass", 2, 1.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID, avoidRock);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int rockID2=rmCreateObjectDef("rock group");
   rmAddObjectDefItem(rockID2, "rock limestone sprite", 3, 2.0);
   rmSetObjectDefMinDistance(rockID2, 0.0);
   rmSetObjectDefMaxDistance(rockID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID2, avoidAll);
   rmAddObjectDefConstraint(rockID2, avoidImpassableLand);
   rmAddObjectDefConstraint(rockID2, avoidRock);
   rmPlaceObjectDefAtLoc(rockID2, 0, 0.5, 0.5, 8*cNumberNonGaiaPlayers); 

   // Text
   rmSetStatusText("",1.0);

}  





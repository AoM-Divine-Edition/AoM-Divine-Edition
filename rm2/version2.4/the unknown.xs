// Unknown

void main(void)
{

  // Text
   rmSetStatusText("",0.01);

// Main entry point for random map script


  // Set size.

   int playerTiles=7500;
   if(cMapSize == 1)
   {
      playerTiles = 9750;
      rmEchoInfo("Large map");
   }
   int sizel=0;
   int sizew=0;

   // Sometimes start with non-standard resources

   float resourceChance = rmRandFloat(0,1);
   if(resourceChance < 0.1)
   {
      for(i=1; <cNumberPlayers)
      {
         rmAddPlayerResource(i, "Food", 200);
         rmAddPlayerResource(i, "Wood", 100);
      }
   }
   else if(resourceChance < 0.15)
   {
      for(i=1; <cNumberPlayers)
      {
         rmAddPlayerResource(i, "Food", 200);
         rmAddPlayerResource(i, "Wood", 200);
         rmAddPlayerResource(i, "Gold", 200);
      }
   }
   else if(resourceChance < 0.2)
   {
      for(i=1; <cNumberPlayers)
      {
         rmAddPlayerResource(i, "Food", 400);
         rmAddPlayerResource(i, "Wood", 300);
         rmAddPlayerResource(i, "Gold", 200);
         rmAddPlayerResource(i, "Favor", 20);
      }
   }
   else if(resourceChance < 0.23)
   {
      for(i=1; <cNumberPlayers)
      {
         if(rmRandFloat(0,1)<0.33)
            rmAddPlayerResource(i, "Food", 50);
         else if(rmRandFloat(0,1)<0.5)
            rmAddPlayerResource(i, "Wood", 50);
         else 
            rmAddPlayerResource(i, "Gold", 50);
      }
   }
   else if(resourceChance < 0.26)
   {
      for(i=1; <cNumberPlayers)
      {
         if(rmRandFloat(0,1)<0.33)
            rmAddPlayerResource(i, "Food", 100);
         else if(rmRandFloat(0,1)<0.5)
            rmAddPlayerResource(i, "Wood", 100);
         else 
            rmAddPlayerResource(i, "Gold", 100);
      }
   }
  
  /* ZERO STEP determine square or rectangular */
   float rectangularness=rmRandFloat(0,1);
   if(rectangularness<0.70)                         /* square */
   {
      sizel=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
      sizew=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   }
   else if(rectangularness<0.85)                   /* longer than wide */
   {
      sizel=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizew=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   else                                         /* wider than long */  
   {
      sizew=2.22*sqrt(cNumberNonGaiaPlayers*playerTiles);
      sizel=1.8*sqrt(cNumberNonGaiaPlayers*playerTiles);
   }
   rmEchoInfo("Map size="+sizel+"m x "+sizew+"m");
   rmSetMapSize(sizel, sizew);

   /* FIRST STEP determine which terrain the map uses */
   int terrainChance = rmRandInt(0, 2);
   /* Greek = 0, Egyptian = 1, Norse = 2 */

   if(terrainChance == 0)
      rmEchoInfo("terrain chance "+terrainChance+ " Greek");
   else if(terrainChance == 1)
      rmEchoInfo("terrain chance "+terrainChance+ " Egyptian");
   else
      rmEchoInfo("terrain chance "+terrainChance+ " Norse");

   /* SECOND STEP determine if base terrain is land or water. No longer ice. */

   rmSetSeaLevel(0.0);
   int fishExist = 0;
   int bigForestExist = 0;
   int savannah = 0;
   float baseTerrainChance = 0;
   if(terrainChance == 0) 
   {
      baseTerrainChance = rmRandFloat(0,1); 
      rmEchoInfo("base terrain chance "+baseTerrainChance);
      if(baseTerrainChance < 0.5)         /* Greek ocean */
      {
         rmSetSeaType("mediterranean sea");
         rmTerrainInitialize("water");
         fishExist = 1;
      }
      else
      {
         rmTerrainInitialize("GrassA"); /* Greek land */
         bigForestExist = 1;
      }
   }
   else if(terrainChance == 2) 
   {
      baseTerrainChance = rmRandFloat(0, 1);
      if(baseTerrainChance < 0.5)   /* Norse ocean */
      {
         rmSetSeaType("norwegian sea");
         rmTerrainInitialize("water");
         rmEchoInfo("water");
         fishExist = 1;
      }
      else
      {
         rmTerrainInitialize("SnowA"); /* Norse land */
         rmEchoInfo("snow");
         bigForestExist = 1;
      }
   }
   else if(terrainChance == 1)
   {
      baseTerrainChance = rmRandFloat(0,1); 
      if(baseTerrainChance < 0.5)   /* Egyptian ocean */
      {      
         if(rmRandFloat(0,1)<0.25)
           savannah = 1;
         rmSetSeaType("red sea");
         rmTerrainInitialize("water");
         fishExist = 1;
      }
      else
      {
         if(rmRandFloat(0,1)<0.75)
            rmTerrainInitialize("SandB"); /* Egyptian land */
         else
         {
            rmTerrainInitialize("SavannahB");
            savannah = 1;
         }         
         bigForestExist = 1;   
      }
   }
   rmEchoInfo("Base terrain chance "+baseTerrainChance);

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classTeam=rmDefineClass("team");
   rmDefineClass("corner");
   int classPatch=rmDefineClass("patch");
   rmDefineClass("center");
   rmDefineClass("starting settlement");
   int classCliff=rmDefineClass("cliff");


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(10), rmZTilesToFraction(10), 1.0-rmXTilesToFraction(10), 1.0-rmZTilesToFraction(10));
   
   int playerVsPlayerConstraint=0;
   int teamVsTeamConstraint=0;
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30);

   int patchConstraint=rmCreateClassDistanceConstraint("avoid patch", classPatch, 10.0);

   // Center constraint.
   int centerConstraint=rmCreateClassDistanceConstraint("PLAYERS stay away from center", rmClassID("center"), 15.0);
   int patchCenterConstraint=rmCreateClassDistanceConstraint("patch don't mess up center", rmClassID("center"), 30.0);


   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 40.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 20.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 22.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "land", false, 4.0);
   int cliffConstraint=rmCreateClassDistanceConstraint("cliff v cliff", rmClassID("cliff"), 30.0);
   int shortCliffConstraint=rmCreateClassDistanceConstraint("elev v cliff", rmClassID("cliff"), 10.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 15.0);

   // Forest constraints
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 20.0);
   int wideForestConstraint=rmCreateClassDistanceConstraint("big forest v forest", rmClassID("forest"), 40.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
  
   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 0.0);

   // towers avoid other towers
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTowerID, 22.0);
   rmSetObjectDefMaxDistance(startingTowerID, 28.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);
   
   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);

   // starting herds
   int closePigsID=rmCreateObjectDef("close pigs");

   if(rmRandFloat(0,1)<0.75)
   {
      if(terrainChance == 0)
         rmAddObjectDefItem(closePigsID, "pig", rmRandInt(1,3), 2.0);
      else if(terrainChance == 1)
         rmAddObjectDefItem(closePigsID, "goat", rmRandInt(1,3), 2.0);
      else if(terrainChance == 2)
         rmAddObjectDefItem(closePigsID, "cow", rmRandInt(1,3), 2.0);
   }
   else
   {
      if(terrainChance == 0) 
         rmAddObjectDefItem(closePigsID, "pig", rmRandInt(4,5), 2.0);
      else if(terrainChance == 1)
         rmAddObjectDefItem(closePigsID, "goat", rmRandInt(4,5), 2.0);
      else if(terrainChance == 2)
         rmAddObjectDefItem(closePigsID, "cow", rmRandInt(4,5), 2.0);
   }
   rmSetObjectDefMinDistance(closePigsID, 25.0);
   rmSetObjectDefMaxDistance(closePigsID, 30.0);
   rmAddObjectDefConstraint(closePigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(closePigsID, avoidFood);

   int berryNum = rmRandInt(1,3);
   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", berryNum*4, 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeBerriesID=rmCreateObjectDef("close berries");
   rmAddObjectDefItem(closeBerriesID, "berry bush", berryNum*3, 4.0);
   rmSetObjectDefMinDistance(closeBerriesID, 20.0);
   rmSetObjectDefMaxDistance(closeBerriesID, 25.0);
   rmAddObjectDefConstraint(closeBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(closeBerriesID, avoidFood);

   /* starting huntable */
   float huntSpeciesChance=rmRandFloat(0,1);
   int closeBoarID=rmCreateObjectDef("close Boar");
   if(terrainChance == 0)
   {   
      if(huntSpeciesChance<0.5)
         rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(1,3), 4.0);
      else
         rmAddObjectDefItem(closeBoarID, "deer", rmRandInt(4,6), 4.0);
   }
   else if(terrainChance == 1)
   {   
      if(huntSpeciesChance<0.2)
         rmAddObjectDefItem(closeBoarID, "hippo", rmRandInt(1,2), 4.0);
      else if(huntSpeciesChance<0.4)
         rmAddObjectDefItem(closeBoarID, "zebra", rmRandInt(4,12), 5.0);
      else if(huntSpeciesChance<0.6)
         rmAddObjectDefItem(closeBoarID, "giraffe", rmRandInt(4,8), 4.0);
      else if(huntSpeciesChance<0.8)
         rmAddObjectDefItem(closeBoarID, "elephant", rmRandInt(1,2), 4.0);
      else
         rmAddObjectDefItem(closeBoarID, "rhinocerous", rmRandInt(1,3), 4.0);
   }  
   else
   {   
      if(huntSpeciesChance<0.33)
         rmAddObjectDefItem(closeBoarID, "boar", rmRandInt(2,6), 4.0);
      else if(huntSpeciesChance<0.66)
         rmAddObjectDefItem(closeBoarID, "caribou", rmRandInt(4,8), 4.0);
      else
         rmAddObjectDefItem(closeBoarID, "aurochs", rmRandInt(2,6), 4.0);
   }
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 50.0);
   rmAddObjectDefConstraint(closeBoarID, avoidImpassableLand);

   /* straggler tress */
   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   if(terrainChance == 0)
   {
      if(rmRandFloat(0,1)<0.7)
         rmAddObjectDefItem(stragglerTreeID, "oak tree", 1, 0.0);
      else if(rmRandFloat(0,1)<0.5)
         rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
      else
         rmAddObjectDefItem(stragglerTreeID, "oak autumn", 1, 0.0);
   }   
   else if(terrainChance == 1)
   {
      if(rmRandFloat(0,1)<0.2)
         rmAddObjectDefItem(stragglerTreeID, "savannah tree", 1, 0.0);
      else
         rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
   }   
   else
      rmAddObjectDefItem(stragglerTreeID, "pine", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);


   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(mediumGoldID, 40.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, edgeConstraint);
   rmAddObjectDefConstraint(mediumGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   if(terrainChance == 0) 
      rmAddObjectDefItem(mediumPigsID, "pig", rmRandInt(1,3), 2.0);
   else if(terrainChance == 1)
      rmAddObjectDefItem(mediumPigsID, "goat", rmRandInt(1,3), 2.0);
   else if(terrainChance == 2)
      rmAddObjectDefItem(mediumPigsID, "cow", rmRandInt(1,3), 2.0);   
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
   rmAddObjectDefConstraint(mediumPigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(mediumPigsID, avoidHerdable);

   // player fish
   int fishVsFishID=rmCreateTypeDistanceConstraint("fish v fish", "fish", 18.0);
   int fishLand = rmCreateTerrainDistanceConstraint("fish land", "land", true, 6.0);

   int playerFishID=rmCreateObjectDef("owned fish");
   if(terrainChance == 0)
      rmAddObjectDefItem(playerFishID, "fish - mahi", 3, 10.0);
   else if(terrainChance == 1)
         rmAddObjectDefItem(playerFishID, "fish - perch", 3, 10.0);
   else if(terrainChance == 2)
      rmAddObjectDefItem(playerFishID, "fish - salmon", 3, 10.0);
   rmSetObjectDefMinDistance(playerFishID, 0.0);
   rmSetObjectDefMaxDistance(playerFishID, 100.0);
   rmAddObjectDefConstraint(playerFishID, fishVsFishID);
   rmAddObjectDefConstraint(playerFishID, fishLand);
   
   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   if(rmRandFloat(0,1)<0.9)
      rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   else
      rmAddObjectDefItem(farGoldID, "Gold mine", 2, 6.0);
   rmSetObjectDefMinDistance(farGoldID, 70.0);
   rmSetObjectDefMaxDistance(farGoldID, 160.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, avoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, centerConstraint);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   // pigs avoid TCs and other herds, since this map places a lot of pigs
   int farPigsID=rmCreateObjectDef("far pigs");
   if(rmRandFloat(0,1)< 0.33) 
      rmAddObjectDefItem(farPigsID, "pig", rmRandInt(1,3), 2.0);
   else if(rmRandFloat(0,1)< 0.50)
      rmAddObjectDefItem(farPigsID, "goat", rmRandInt(1,3), 2.0);
   else
      rmAddObjectDefItem(farPigsID, "cow", rmRandInt(1,3), 2.0);      
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidImpassableLand);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, farStartingSettleConstraint);
   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   if(terrainChance == 1)
      if(rmRandFloat(0,1)< 0.50) 
         rmAddObjectDefItem(farPredatorID, "lion", rmRandInt(1,2), 4.0);
      else
         rmAddObjectDefItem(farPredatorID, "hyena", rmRandInt(2,3), 4.0);
   else if(terrainChance == 0)
      if(rmRandFloat(0,1)< 0.33) 
         rmAddObjectDefItem(farPredatorID, "lion", rmRandInt(1,2), 4.0);
      else if(rmRandFloat(0,1)<0.50)
         rmAddObjectDefItem(farPredatorID, "wolf", rmRandInt(2,3), 4.0);
      else
         rmAddObjectDefItem(farPredatorID, "bear", rmRandInt(1,2), 4.0);
   else
      if(rmRandFloat(0,1)< 0.33) 
         rmAddObjectDefItem(farPredatorID, "bear", rmRandInt(1,2), 4.0);
      else if(rmRandFloat(0,1)<0.50)
         rmAddObjectDefItem(farPredatorID, "polar bear", rmRandInt(1,2), 4.0);
      else
         rmAddObjectDefItem(farPredatorID, "wolf", rmRandInt(2,3), 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, avoidImpassableLand);
   
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(6,12), 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBerriesID, avoidImpassableLand);
   rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farBerriesID, centerConstraint);
   
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 20.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   huntSpeciesChance=rmRandFloat(0,1);

   if(terrainChance == 0)
   {   
      if(huntSpeciesChance<0.5)
         rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(2,4), 4.0);
      else
         rmAddObjectDefItem(bonusHuntableID, "deer", rmRandInt(6,8), 4.0);
   }
   else if(terrainChance == 1)
   {   
      if(huntSpeciesChance<0.2)
         rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(6,8), 4.0);
      else if(huntSpeciesChance<0.4)
         rmAddObjectDefItem(bonusHuntableID, "zebra", rmRandInt(4,8), 4.0);
      else if(huntSpeciesChance<0.6)
         rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(3,6), 4.0);
      else if(huntSpeciesChance<0.8)
         rmAddObjectDefItem(bonusHuntableID, "elephant", rmRandInt(1,2), 4.0);
      else
         rmAddObjectDefItem(bonusHuntableID, "rhinocerous", rmRandInt(1,3), 4.0);
   }  
   else
   {   
      if(huntSpeciesChance<0.5)
         rmAddObjectDefItem(bonusHuntableID, "boar", rmRandInt(2,4), 4.0);
      else
         rmAddObjectDefItem(bonusHuntableID, "caribou", rmRandInt(4,8), 4.0);
   }
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntableID, centerConstraint);

   /* second huntable? */
   int bonusHuntable2ID=rmCreateObjectDef("bonus huntable 2");
   huntSpeciesChance=rmRandFloat(0,1);

   if(terrainChance == 0)
   {   
      if(huntSpeciesChance<0.5)
         rmAddObjectDefItem(bonusHuntable2ID, "boar", rmRandInt(2,4), 4.0);
      else
         rmAddObjectDefItem(bonusHuntable2ID, "deer", rmRandInt(4,6), 4.0);
   }
   else if(terrainChance == 1)
   {   
      if(huntSpeciesChance<0.2)
         rmAddObjectDefItem(bonusHuntable2ID, "gazelle", rmRandInt(6,8), 4.0);
      else if(huntSpeciesChance<0.4)
         rmAddObjectDefItem(bonusHuntable2ID, "zebra", rmRandInt(4,8), 4.0);
      else if(huntSpeciesChance<0.6)
         rmAddObjectDefItem(bonusHuntable2ID, "giraffe", rmRandInt(4,8), 4.0);
      else if(huntSpeciesChance<0.8)
         rmAddObjectDefItem(bonusHuntable2ID, "elephant", rmRandInt(1,2), 4.0);
      else
         rmAddObjectDefItem(bonusHuntable2ID, "rhinocerous", rmRandInt(1,3), 4.0);
   }  
   else
   {   
      if(huntSpeciesChance<0.5)
         rmAddObjectDefItem(bonusHuntable2ID, "boar", rmRandInt(2,4), 4.0);
      else
         rmAddObjectDefItem(bonusHuntable2ID, "caribou", rmRandInt(4,8), 4.0);
   }
   rmSetObjectDefMinDistance(bonusHuntable2ID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntable2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntable2ID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntable2ID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntable2ID, avoidImpassableLand);
   rmAddObjectDefConstraint(bonusHuntable2ID, centerConstraint);

   int randomTreeID=rmCreateObjectDef("random tree");
   if(terrainChance == 0)
   {
      if(rmRandFloat(0,1)<0.7)
         rmAddObjectDefItem(randomTreeID, "oak tree", 1, 0.0);
      else if(rmRandFloat(0,1)<0.5)
         rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
      else
         rmAddObjectDefItem(randomTreeID, "oak autumn", 1, 0.0);
   }   
   else if(terrainChance == 1)
   {
      if(rmRandFloat(0,1)<0.2)
         rmAddObjectDefItem(randomTreeID, "savannah tree", 1, 0.0);
      else
         rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   }
   else
   {
      if(rmRandFloat(0,1)<0.2)
         rmAddObjectDefItem(randomTreeID, "pine snow", 1, 0.0);
      else
         rmAddObjectDefItem(randomTreeID, "pine", 1, 0.0);
   }
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, avoidImpassableLand);
   rmAddObjectDefConstraint(randomTreeID, centerConstraint);
   
    // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "hawk", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));

   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 60.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(relicID, avoidImpassableLand);
   rmAddObjectDefConstraint(relicID, centerConstraint);

  // Text
   rmSetStatusText("",0.20);

   // -------------------------------------------------------Done defining objects

   /* THIRD STEP determine if lands are by player or team */

   int teamLands = 0;
   if(cNumberTeams == 2)           /* do only when teams = 2 or we get a mess */
      if(baseTerrainChance < 0.6)   /* do only if base terrain is water, else who could tell */
         if(rmRandFloat(0,1) > 0.5) 
            teamLands = 1;
  
     /* FOURTH STEP determine if players or teams avoid each other */

   float togetherness=rmRandFloat(0,1);
   rmEchoInfo("togetherness "+togetherness);
   if (teamLands == 0)
   {
      if(togetherness < 0.5)  /* normal distance */
      {
         playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a lot", classPlayer, 20);
         rmEchoInfo("avoid players by 20");
      }
      else if(togetherness < 0.8) /* right together */
      {
         playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a little", classPlayer, 0);
         rmEchoInfo("avoid players by 0");
      }
      else                    /* small constraint */
      {
         playerVsPlayerConstraint=rmCreateClassDistanceConstraint("stay away from players a little", classPlayer, 10);
         rmEchoInfo("avoid players by 10");
      }  
   }
   else
   {
      if(togetherness < 0.5)  /* normal distance */
      {
         teamVsTeamConstraint=rmCreateClassDistanceConstraint("stay away from teams a lot", classTeam, 30);
         rmEchoInfo("avoid team by 20");
      }
      else if(togetherness < 0.8) /* right together */
      {
         teamVsTeamConstraint=rmCreateClassDistanceConstraint("stay away from teams barely", classTeam, 0);
         rmEchoInfo("avoid teams by 0");
      }
      else                    /* small constraint */
      {
         teamVsTeamConstraint=rmCreateClassDistanceConstraint("stay away from teams a little", classTeam, 20);
         rmEchoInfo("avoid teams by 10");
      } 
   }

   /* FIFTH STEP determine if teams are together or not */
   float edgeConstraintChance=rmRandFloat(0,1);
   float playerMinCircle = 0;
   float playerMaxCircle = 0;
   if(edgeConstraintChance < 0.5) /* edge */
   {
      playerMinCircle = 0.30;
      playerMaxCircle = 0.35;
      rmEchoInfo("edge chance "+edgeConstraintChance+ "= edge");
      rmPlacePlayersSquare(playerMinCircle, 0.05, 0.05);
      rmEchoInfo("square "+playerMinCircle+ " + 0.05");
   }
   else                          /* no edge */
   {
      playerMinCircle = 0.40;
      playerMaxCircle = 0.43;
      rmEchoInfo("edge chance "+edgeConstraintChance+ "= no edge");
      rmPlacePlayersCircular(playerMinCircle, playerMaxCircle, rmDegreesToRadians(5.0));
      rmEchoInfo("circle min"+playerMinCircle+ " max "+playerMaxCircle);
   }               
   float teamTogetherness=rmRandFloat(0,1);
   if(teamTogetherness < 0.4)  /* together a bit */
      rmSetTeamSpacingModifier(0.5);
   else if(teamTogetherness < 0.55)  /* together a lot */
      rmSetTeamSpacingModifier(0.75);


   /* SIXTH STEP determine if there is a center area */
   int centerID=rmCreateArea("center");
   float centerChance=rmRandFloat(0,1); 
   float centerPosition=rmRandFloat(0,1);
   int centerType = 0;
   /* but what if center is off to one side? */
   
   if(centerPosition < 0.6)
   {
      rmSetAreaLocation(centerID, 0.5, 0.5);
      rmSetAreaSize(centerID, 0.08, 0.15);
      rmAddAreaToClass(centerID, rmClassID("center"));
   }
   else if(centerPosition < 0.7)
   {
      rmSetAreaLocation(centerID, 1, 0.5);
      rmSetAreaSize(centerID, 0.05, 0.08);
   }
   else if(centerPosition < 0.8)
   {
      rmSetAreaLocation(centerID, 0.5, 1);
      rmSetAreaSize(centerID, 0.05, 0.08);
   }
   else if(centerPosition < 0.9) 
   {   
      rmSetAreaLocation(centerID, 0, 0.5);
      rmSetAreaSize(centerID, 0.05, 0.08);
   }
   else
   {   
      rmSetAreaLocation(centerID, 0.5, 0);
      rmSetAreaSize(centerID, 0.05, 0.08);      
   }

   if(baseTerrainChance < 0.6) /* base is water */
   {
      if(centerChance < 0.4)
      {
         centerType = 1; /* land */
      }
   }
   else /* base is land */
   {   
      if(centerChance < 0.2)
      {
         centerType = 3; /* water */
         fishExist=1;
      }
      else if(centerChance < 0.4)
      {
         centerType = 4; /* cliff */
      }
      else if(centerChance < 0.6)
      {
         centerType = 5; /* forest */
      }
      else if(centerChance < 0.8)
      {
         if(terrainChance == 2)
         {
            centerType = 2; /* ice */
         }
      }
   }

   /* Define what terrains to use for center */

   if(centerType == 1)  /* land */
   {
      if(terrainChance == 0)
      {
         rmSetAreaTerrainType(centerID, "GrassA");
         rmSetAreaBaseHeight(centerID, 2.0);
      }
      else if(terrainChance == 1)
      {
         if(savannah == 1)
         {
            rmSetAreaTerrainType(centerID, "SavannahC");
            rmSetAreaBaseHeight(centerID, 2.0);
         }
         else
         {
            rmSetAreaTerrainType(centerID, "SandA");
            rmSetAreaBaseHeight(centerID, 2.0);
         }
      }
      else if(terrainChance == 2)
      {
         rmSetAreaTerrainType(centerID, "SnowA");
         rmSetAreaBaseHeight(centerID, 2.0);
      }
      rmSetAreaHeightBlend(centerID, 2);
      rmSetAreaMinBlobs(centerID, 2);
      rmSetAreaMaxBlobs(centerID, 4);
      rmSetAreaMinBlobDistance(centerID, 10);
      rmSetAreaMaxBlobDistance(centerID, 20);
      rmSetAreaSmoothDistance(centerID, 30);
      rmSetAreaCoherence(centerID, 0.15);
      rmBuildArea(centerID);
      rmEchoInfo("center is land");
   }
   else if(centerType == 3)  /* water */
   {
      if(terrainChance == 0)
      {
         rmSetAreaWaterType(centerID, "mediterranean sea");
         rmSetAreaBaseHeight(centerID, 0.0);
         if(centerPosition < 0.6)
         {
            rmSetAreaSize(centerID, 0.15, 0.2);
         }
      }
      else if(terrainChance == 1)
      {
         rmSetAreaWaterType(centerID, "red sea");
         rmSetAreaBaseHeight(centerID, 0.0);
         if(centerPosition < 0.6)
         {
            rmSetAreaSize(centerID, 0.15, 0.2);
         }      
      }
      else if(terrainChance == 2)
      {
         rmSetAreaWaterType(centerID, "norwegian sea");
         rmSetAreaBaseHeight(centerID, 0.0);
         if(centerPosition < 0.6)
         {
            rmSetAreaSize(centerID, 0.15, 0.2);
         }
      }
      rmAddAreaToClass(centerID, rmClassID("center"));
      centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 0.0);
      rmSetAreaMinBlobs(centerID, 8);
      rmSetAreaMaxBlobs(centerID, 10);
      rmSetAreaMinBlobDistance(centerID, 10);
      rmSetAreaMaxBlobDistance(centerID, 20);
      rmSetAreaSmoothDistance(centerID, 50);
      rmSetAreaCoherence(centerID, 0.25);
      rmBuildArea(centerID);
      rmEchoInfo("center is water");
   }
   else if(centerType == 4)  /* cliff */
   {
      if(terrainChance == 0)
      {
         rmSetAreaCliffType(centerID, "Greek");
         rmSetAreaCliffPainting(centerID, false, true, true, 1.5, true);
      }
      else if(terrainChance == 1)
      {
         rmSetAreaCliffType(centerID, "Egyptian");
         rmSetAreaCliffPainting(centerID, false, true, true, 1.5, true);
      }
      else if(terrainChance == 2)
      {
         rmSetAreaCliffType(centerID, "Norse");
         rmSetAreaCliffPainting(centerID, true, true, true, 1.5, true);
      }
      rmSetAreaCliffEdge(centerID, 4, 0.20, 0.2, 1.0, 1);
      rmSetAreaCliffHeight(centerID, 7, 1.0, 0.5);
      rmSetAreaMinBlobs(centerID, 8);
      rmSetAreaMaxBlobs(centerID, 10);
      rmSetAreaMinBlobDistance(centerID, 10);
      rmSetAreaMaxBlobDistance(centerID, 20);
      rmSetAreaSmoothDistance(centerID, 50);
      rmSetAreaCoherence(centerID, 0.25);
      rmBuildArea(centerID);
      rmEchoInfo("center is cliff");
   }
   else if(centerType == 2)  /* ice only if Norse and only in center */
   {
      rmSetAreaTerrainType(centerID,"IceA");
      rmSetAreaLocation(centerID, 0.5, 0.5);
      rmSetAreaSize(centerID, 0.08, 0.15);
      rmAddAreaToClass(centerID, rmClassID("center"));
      rmSetAreaBaseHeight(centerID, 1.0);
      rmSetAreaMinBlobs(centerID, 8);
      rmSetAreaMaxBlobs(centerID, 10);
      rmSetAreaMinBlobDistance(centerID, 10);
      rmSetAreaMaxBlobDistance(centerID, 20);
      rmSetAreaSmoothDistance(centerID, 50);
      rmSetAreaCoherence(centerID, 0.25);
      rmBuildArea(centerID);
      rmEchoInfo("center is ice");
   }
   else if(centerType == 5)  /* forest */
   {
      rmSetAreaSize(centerID, 0.05, 0.08);
      if(terrainChance == 0)
      {
         if(rmRandFloat(0,1)<0.2)
            rmSetAreaForestType(centerID, "savannah forest");
         else
            rmSetAreaForestType(centerID, "oak forest");
      }      
      else if(terrainChance == 2)
         rmSetAreaForestType(centerID, "mixed pine forest");
      else
      {
         if(rmRandFloat(0,1)<0.2)
            rmSetAreaForestType(centerID, "savannah forest");
         else
            rmSetAreaForestType(centerID, "mixed palm forest");
      }      
      rmAddAreaToClass(centerID, rmClassID("center"));
      rmSetAreaLocation(centerID, 0.5, 0.5);
      rmAddAreaConstraint(centerID, forestSettleConstraint);
      rmAddAreaConstraint(centerID, forestObjConstraint);
      rmAddAreaConstraint(centerID, forestConstraint);
      rmAddAreaConstraint(centerID, avoidImpassableLand);
      rmAddAreaToClass(centerID, classForest);
      rmSetAreaMinBlobs(centerID, 1);
      rmSetAreaMaxBlobs(centerID, 1);
      rmSetAreaCoherence(centerID, 0.5);

      rmBuildArea(centerID);
   }
   else if(centerType == 0)
      rmEchoInfo("no center");

  // Text
   rmSetStatusText("",0.40);         

   // PLAYER AREAS
   float playerFraction=0;
   float teamPercentArea = 0;
   if(teamLands == 1)
   {
      teamPercentArea = rmAreaTilesToFraction(4000*rmRandFloat(1,3)*cNumberNonGaiaPlayers/cNumberTeams); /* 0.2 divided by number teams */
      if(centerType > 0)   /* but save space if there is a center */
         teamPercentArea = rmAreaTilesToFraction(4000*rmRandFloat(1,3)*cNumberNonGaiaPlayers/cNumberTeams);
      rmEchoInfo("team percent area "+teamPercentArea);
   }
   int id=0;
   
   if(teamLands == 1)
   {
      // Build team areas
      for(i=0; <cNumberTeams)
      {
         int teamID=rmCreateArea("team"+i);
         rmSetAreaSize(teamID, teamPercentArea, teamPercentArea);
         rmSetAreaWarnFailure(teamID, false); 
         if(terrainChance == 0)
         {
            rmSetAreaTerrainType(teamID, "GrassA");
         }
         else if(terrainChance == 1)
         {
            if(savannah==1)
               rmSetAreaTerrainType(teamID, "SavannahB");
            else
               rmSetAreaTerrainType(teamID, "SandA");
         }
         else if(terrainChance == 2)
         {
            rmSetAreaTerrainType(teamID, "SnowA");
         }
         rmSetAreaMinBlobs(teamID, 1);
         rmSetAreaMaxBlobs(teamID, 5);
         rmSetAreaMinBlobDistance(teamID, 16.0);
         rmSetAreaMaxBlobDistance(teamID, 40.0);
         rmSetAreaCoherence(teamID, 0.0);
         rmSetAreaSmoothDistance(teamID, 10);
         rmSetAreaBaseHeight(teamID, 1.0);
         rmSetAreaHeightBlend(teamID, 2);
         rmAddAreaToClass(teamID, classTeam);
         rmAddAreaConstraint(teamID, teamVsTeamConstraint);
         if(centerType < 2)
            if(rmRandFloat(0,1)>0.7) /* sometimes avoid center anyway, because it looks cool */
               rmAddAreaConstraint(teamID, centerConstraint);
         else
            rmAddAreaConstraint(teamID, centerConstraint);
         if(edgeConstraintChance < 0.5) /* edge */
            rmAddAreaConstraint(teamID, edgeConstraint);
         rmSetAreaLocTeam(teamID, i);
         rmEchoInfo("Team area"+i);
      }

      rmBuildAllAreas();
    

      // Set up player areas within team areas
      playerFraction=rmAreaTilesToFraction(1600);
      rmEchoInfo("player fraction "+playerFraction);
      for(i=1; <cNumberPlayers)
      {
         id=rmCreateArea("Player"+i, rmAreaID("team"+rmGetPlayerTeam(i)));
         rmSetPlayerArea(i, id);
         rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
         rmAddAreaToClass(id, classPlayer);
         rmSetAreaMinBlobs(id, 4);
         rmSetAreaMaxBlobs(id, 5);
         rmSetAreaWarnFailure(id, false);
         rmSetAreaMinBlobDistance(id, 30.0);
         rmSetAreaMaxBlobDistance(id, 50.0);
         rmSetAreaSmoothDistance(id, 20);
         rmSetAreaCoherence(id, 0.20);
         rmSetAreaBaseHeight(id, 2.0); 
         rmSetAreaHeightBlend(id, 2);
         rmSetAreaLocPlayer(id, i);
         if(terrainChance == 0)
            rmSetAreaTerrainType(id, "GrassDirt25");
         else if(terrainChance == 2)
         {
            rmSetAreaTerrainType(id, "SnowGrass75");
            rmAddAreaTerrainLayer(id, "SnowGrass75", 8, 20);
            rmAddAreaTerrainLayer(id, "SnowGrass50", 4, 8);
            rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 4);
         }
         else if(terrainChance == 1)
         {
            if(savannah == 1)
            {
               rmSetAreaTerrainType(id, "SavannahA");
            }
            else
            {
               rmSetAreaTerrainType(id, "GrassDirt25");
               rmAddAreaTerrainLayer(id, "GrassDirt50", 2, 5);
               rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 2);
            }
         }
      }
   }
   else if(teamLands == 0)
   {

      // Set up player areas alone
      if(baseTerrainChance < 0.6)   /* ocean */
      {
         playerFraction=rmAreaTilesToFraction(4000);
         rmEchoInfo("4000");
      }
      else 
      {
         if(terrainChance == 2) /* ice */
         {
            playerFraction=rmAreaTilesToFraction(6000);
            rmEchoInfo("6000");
         }
         else
         { 
            playerFraction=rmAreaTilesToFraction(3000);
            rmEchoInfo("3000");
         }
      }
      rmEchoInfo("player fraction "+playerFraction);
      for(i=1; <cNumberPlayers)
      {
         id=rmCreateArea("Player"+i);
         rmSetPlayerArea(i, id);
         rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
         rmAddAreaToClass(id, classPlayer);
         rmSetAreaMinBlobs(id, 4);
         rmSetAreaMaxBlobs(id, 5);
         rmSetAreaWarnFailure(id, false);
         rmSetAreaMinBlobDistance(id, 30.0);
         rmSetAreaMaxBlobDistance(id, 50.0);
         rmSetAreaSmoothDistance(id, 20);
         rmSetAreaCoherence(id, 0.20);
         rmSetAreaBaseHeight(id, 2.0); 
         rmSetAreaHeightBlend(id, 2);
         if(edgeConstraintChance < 0.5) /* edge */
            rmAddAreaConstraint(id, edgeConstraint);
         rmAddAreaConstraint(id, playerVsPlayerConstraint);
         rmAddAreaConstraint(id, centerConstraint);
         rmSetAreaLocPlayer(id, i);
         if(terrainChance == 0)
            rmSetAreaTerrainType(id, "GrassDirt25");
         else if(terrainChance == 2)
         {
            rmSetAreaTerrainType(id, "SnowGrass75");
            rmAddAreaTerrainLayer(id, "SnowGrass75", 8, 20);
            rmAddAreaTerrainLayer(id, "SnowGrass50", 4, 8);
            rmAddAreaTerrainLayer(id, "SnowGrass25", 0, 4);
         }
          else if(terrainChance == 1)
         {
            if(savannah == 1)
            {
               rmSetAreaTerrainType(id, "SavannahA");
            }
            else
            {
               rmSetAreaTerrainType(id, "GrassDirt25");
               rmAddAreaTerrainLayer(id, "GrassDirt50", 2, 5);
               rmAddAreaTerrainLayer(id, "GrassDirt75", 0, 2);
            }
         }
      }
   }

   rmBuildAllAreas();

   /* PLAYER'S PATCH */
   int failCount=0;
   for(i=1; <cNumberPlayers)
   {
      int playerPatch=rmCreateArea("player "+i+" patch", rmAreaID("player"+i));    
      rmSetAreaSize(playerPatch, rmAreaTilesToFraction(200), rmAreaTilesToFraction(400));
      if(terrainChance == 0)
         rmSetAreaTerrainType(playerPatch, "GrassDirt50");
      else if(terrainChance == 1)
      {
         if(savannah==1)
         {            
            rmSetAreaTerrainType(playerPatch, "SavannahB");
         }
         else
         {            
            rmSetAreaTerrainType(playerPatch, "GrassDirt50");
            rmAddAreaTerrainLayer(playerPatch, "GrassDirt75", 0, 3);
         }
      }
      else
      {
         rmSetAreaTerrainType(playerPatch, "SnowGrass50");
         rmAddAreaTerrainLayer(playerPatch, "SnowGrass25", 0, 2);
      }
      rmAddAreaToClass(playerPatch, classPatch);
      rmAddAreaConstraint(playerPatch, patchConstraint);
      rmAddAreaConstraint(playerPatch, shortAvoidImpassableLand);
      rmSetAreaMinBlobs(playerPatch, 1);
      rmSetAreaMaxBlobs(playerPatch, 5);
      rmSetAreaWarnFailure(playerPatch, false);
      rmSetAreaMinBlobDistance(playerPatch, 16.0);
      rmSetAreaMaxBlobDistance(playerPatch, 40.0);
      rmSetAreaCoherence(playerPatch, 0.0);
      if(rmBuildArea(playerPatch)==false)
      {
         failCount++;
         if(failCount==4)
            break;
      }
      else
         failCount=0;
   }

   /* NON PLAYER LARGE PATCH  */
   failCount=0;
   for(i=1; <cNumberPlayers*8)
   {
      // Beautification sub area.
      int largePatch=rmCreateArea("large patch "+i);
      rmSetAreaSize(largePatch, rmAreaTilesToFraction(100), rmAreaTilesToFraction(300));
      if(terrainChance == 1)
      {
         if(savannah==1)
            rmSetAreaTerrainType(largePatch, "SavannahB");
         else
            rmSetAreaTerrainType(largePatch, "SandD");
      }        
      else if(terrainChance == 0)
         rmSetAreaTerrainType(largePatch, "GrassDirt25");
      else if(terrainChance == 2)
         rmSetAreaTerrainType(largePatch, "SnowGrass25");
      rmAddAreaToClass(largePatch, classPatch);
      rmAddAreaConstraint(largePatch, patchConstraint);
      rmAddAreaConstraint(largePatch, playerConstraint);
      if(centerType == 2) /* ice */
         rmAddAreaConstraint(largePatch, patchCenterConstraint);
      if(centerType == 5) /* smallAForest */
         rmAddAreaConstraint(largePatch, patchCenterConstraint);
      rmAddAreaConstraint(largePatch, shortAvoidImpassableLand);
      rmSetAreaMinBlobs(largePatch, 1);
      rmSetAreaMaxBlobs(largePatch, 5);
      rmSetAreaWarnFailure(largePatch, false);
      rmSetAreaMinBlobDistance(largePatch, 16.0);
      rmSetAreaMaxBlobDistance(largePatch, 40.0);
      rmSetAreaCoherence(largePatch, 0.0);

      if(rmBuildArea(largePatch)==false)
      {
         failCount++;
         if(failCount==4)
            break;
      }
      else
         failCount=0;

   }

  // Text
   rmSetStatusText("",0.60);

   /* NON PLAYER SMALL PATCH */
   failCount=0;
   for(i=1; <cNumberPlayers*8)
   {
      // Beautification sub area.
      int smallPatch=rmCreateArea("small patch "+i);
      rmSetAreaSize(smallPatch, rmAreaTilesToFraction(20), rmAreaTilesToFraction(70));
      if(terrainChance == 0)
         rmSetAreaTerrainType(smallPatch, "GrassB");
      else if(terrainChance == 1)
      {
         if(savannah==1)      
            rmSetAreaTerrainType(smallPatch, "SandB");
         else
            rmSetAreaTerrainType(smallPatch, "SandB");
      }      
      else if(terrainChance == 2)
         rmSetAreaTerrainType(smallPatch, "SnowB");
      rmAddAreaConstraint(smallPatch, playerConstraint);
      if(centerType == 2) /* ice */
         rmAddAreaConstraint(smallPatch, patchCenterConstraint);
      if(centerType == 5) /* smallAForest */
         rmAddAreaConstraint(smallPatch, patchCenterConstraint);
      rmSetAreaMinBlobs(smallPatch, 1);
      rmSetAreaMaxBlobs(smallPatch, 5);
      rmSetAreaWarnFailure(smallPatch, false);
      rmSetAreaMinBlobDistance(smallPatch, 16.0);
      rmSetAreaMaxBlobDistance(smallPatch, 40.0);
      rmSetAreaCoherence(smallPatch, 0.0);

      if(rmBuildArea(smallPatch)==false)
      {
         failCount++;
         if(failCount==4)
            break;
      }
      else
         failCount=0;

   }
   
   // prettier ice in center if center is ice
   failCount=0;
   for(i=1; <cNumberPlayers*3)
   {
      int icePatch=rmCreateArea("more ice terrain"+i, centerID);
      rmSetAreaSize(icePatch, 0.01, 0.02);
      rmSetAreaTerrainType(icePatch, "IceB");
      rmAddAreaTerrainLayer(icePatch, "IceA", 0, 3);
      rmSetAreaCoherence(icePatch, 0.0);
      if(centerType == 2)
      {
         if(rmBuildArea(icePatch)==false)
         {
            failCount++;
            if(failCount==4)
               break;
         }
         else
            failCount=0;
      }
   }     
   
   // Fish if there is water
   if(fishExist == 1)
   {
      rmPlaceObjectDefPerPlayer(playerFishID, false);

      int fishID=rmCreateObjectDef("fish");
      if (terrainChance == 0)
         rmAddObjectDefItem(fishID, "fish - mahi", 3, 9.0);
      else if(terrainChance == 1)
         rmAddObjectDefItem(fishID, "fish - perch", 3, 9.0);
      else if(terrainChance == 2)
         rmAddObjectDefItem(fishID, "fish - salmon", 3, 9.0);
      rmSetObjectDefMinDistance(fishID, 0.0);
      rmSetObjectDefMaxDistance(fishID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(fishID, fishVsFishID);
      rmAddObjectDefConstraint(fishID, fishLand);

      for(i=1; <cNumberNonGaiaPlayers*5)
      {
         if(rmPlaceObjectDefAtLoc(fishID, 0, 0.5, 0.5, 1)==0)
         {
            break;
         }
      }
     
      int sharkLand = rmCreateTerrainDistanceConstraint("shark land", "land", true, 20.0);
      int sharkVssharkID=rmCreateTypeDistanceConstraint("shark v shark", "shark", 20.0);
      int sharkVssharkID2=rmCreateTypeDistanceConstraint("shark v orca", "orca", 20.0);
      int sharkVssharkID3=rmCreateTypeDistanceConstraint("shark v whale", "whale", 20.0);

      int sharkID=rmCreateObjectDef("shark");
      if(rmRandFloat(0,1)<0.33)
         rmAddObjectDefItem(sharkID, "shark", 1, 0.0);
      else if(rmRandFloat(0,1)<0.5)
         rmAddObjectDefItem(sharkID, "whale", 1, 0.0);
      else
         rmAddObjectDefItem(sharkID, "orca", 1, 0.0);
      rmSetObjectDefMinDistance(sharkID, 0.0);
      rmSetObjectDefMaxDistance(sharkID, rmXFractionToMeters(0.5));
      rmAddObjectDefConstraint(sharkID, sharkVssharkID);
      rmAddObjectDefConstraint(sharkID, sharkVssharkID2);
      rmAddObjectDefConstraint(sharkID, sharkVssharkID3);
      rmAddObjectDefConstraint(sharkID, sharkLand);

      for(i=1; <cNumberNonGaiaPlayers*0.5)
      {
         if(rmPlaceObjectDefAtLoc(sharkID, 0, 0.5, 0.5, 1)==0)
         {
            break;
         }
      }
   } 

   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements.
   //rmPlaceObjectDefPerPlayer(farSettlementID, true, 2);
   id=rmAddFairLoc("Settlement", false, true,  60, 80, 40, 10);
   rmAddFairLocConstraint(id, avoidImpassableLand);

   id=rmAddFairLoc("Settlement", true, false, 70, 120, 60, 10);
   rmAddFairLocConstraint(id, avoidImpassableLand);

   if(rmPlaceFairLocs())
   {
      id=rmCreateObjectDef("far settlement2");
      rmAddObjectDefItem(id, "Settlement", 1, 0.0);
      for(i=1; <cNumberPlayers)
      {
         for(j=0; <rmGetNumberFairLocs(i))
            rmPlaceObjectDefAtLoc(id, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
      }
   }

   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, rmRandInt(5,10));
   
   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false, rmRandInt(1,3));

   // Goats
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   // Chickens or berries.
   for(i=1; <cNumberPlayers)
   {
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmPlaceObjectDefAtLoc(closeChickensID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
      else
         rmPlaceObjectDefAtLoc(closeBerriesID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i));
   }

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);

   


   // Elev.
   int numTries=6*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(80));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(centerType > 1) /* center is ice, cliff, forest */
         rmAddAreaConstraint(elevID, centerConstraint);
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 4.0));
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         failCount++;
         if(failCount==8)
            break;
      }
      else
         failCount=0;
   }

   // Slight Elevation
   numTries=7*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0));
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(1.0, 3.0));
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(centerType > 1) /* center is ice, cliff, forest */
         rmAddAreaConstraint(elevID, centerConstraint);      
      if(rmBuildArea(elevID)==false)
      {
         failCount++;
         if(failCount==8)
            break;
      }
      else
         failCount=0;
   } 

   // Forest
   float bigChance=rmRandFloat(0,1); 
   int diverseForest = rmRandInt(0,1);
   int diverseForestType = rmRandInt(0,1);
   float forestSpecies = rmRandFloat(0,1);
   if(bigForestExist == 1)
   {   
      if(bigChance>0.6)
      {
         int bigAForestID=rmCreateArea("big a forest");
         rmSetAreaSize(bigAForestID, rmAreaTilesToFraction(800), rmAreaTilesToFraction(1200));
         rmSetAreaWarnFailure(bigAForestID, false);
         if(terrainChance == 0) /* greek */
         {
            if(diverseForest == 0)
            {
               if(forestSpecies<0.7)
                  rmSetAreaForestType(bigAForestID, "oak forest");
               else if(forestSpecies<0.90)
                  rmSetAreaForestType(bigAForestID, "autumn oak forest");
               else
                  rmSetAreaForestType(bigAForestID, "savannah forest");
            }
            else if(diverseForest == 1)
            {
               if(diverseForestType == 0)
               {
                  if(rmRandFloat(0,1)<0.8)
                     rmSetAreaForestType(bigAForestID, "oak forest");
                  else
                     rmSetAreaForestType(bigAForestID, "savannah forest");
               }
               else
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(bigAForestID, "oak forest");
                  else
                     rmSetAreaForestType(bigAForestID, "autumn oak forest");
               }
            }
         }
         else if(terrainChance == 2) /* norse */
         {
            if(diverseForest == 0)
            {
               if(forestSpecies<0.7)
                  rmSetAreaForestType(bigAForestID, "pine forest");
               else if(forestSpecies<0.85)
                  rmSetAreaForestType(bigAForestID, "minxed oak forest");
               else
                  rmSetAreaForestType(bigAForestID, "mixed pine forest");
            }
            else if(diverseForest == 1)
            {
               if(diverseForestType == 0)
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(bigAForestID, "pine forest");
                  else
                     rmSetAreaForestType(bigAForestID, "mixed pine forest");
               }
               else
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(bigAForestID, "snow pine forest");
                  else
                     rmSetAreaForestType(bigAForestID, "mixed pine forest");
               }
            }
         }
         else if(terrainChance == 1) /* egyptian */
         {
            if(diverseForest == 0)
            {
               if(forestSpecies<0.7)
                  rmSetAreaForestType(bigAForestID, "palm forest");
               else if(forestSpecies<0.75)
                  rmSetAreaForestType(bigAForestID, "savannah forest");
               else
                  rmSetAreaForestType(bigAForestID, "mixed palm forest");
            }
            else if(diverseForest == 1)
            {
               if(diverseForestType == 0)
               {
                  if(rmRandFloat(0,1)<0.8)
                     rmSetAreaForestType(bigAForestID, "palm forest");
                  else
                     rmSetAreaForestType(bigAForestID, "savannah forest");
               }
               else
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(bigAForestID, "palm forest");
                  else
                     rmSetAreaForestType(bigAForestID, "mixed palm forest");
               }
            }
         }
         rmAddAreaConstraint(bigAForestID, forestSettleConstraint);
         rmAddAreaConstraint(bigAForestID, forestObjConstraint);
         if(rmRandFloat(0,1)<0.80)
            rmAddAreaConstraint(bigAForestID, forestConstraint);
         else
            rmAddAreaConstraint(bigAForestID, wideForestConstraint);
         if(centerType == 2) /* center is ice */
            rmAddAreaConstraint(bigAForestID, centerConstraint);
         rmAddAreaConstraint(bigAForestID, avoidImpassableLand);
         rmAddAreaToClass(bigAForestID, classForest);
      
         rmSetAreaMinBlobs(bigAForestID, 1);
         rmSetAreaMaxBlobs(bigAForestID, 5);
         rmSetAreaMinBlobDistance(bigAForestID, 16.0);
         rmSetAreaMaxBlobDistance(bigAForestID, 40.0);
         rmSetAreaCoherence(bigAForestID, 0.0);

         rmBuildArea(bigAForestID);
      }
      else if(bigChance>0.8)
      {
         int cliffID=rmCreateArea("cliff"+i);
         rmSetAreaWarnFailure(cliffID, false);
         rmSetAreaSize(cliffID, rmAreaTilesToFraction(800), rmAreaTilesToFraction(1200));
         if(terrainChance == 0)
            rmSetAreaCliffType(cliffID, "Greek");
         else if(terrainChance == 2)
            rmSetAreaCliffType(cliffID, "Norse");
         else
            rmSetAreaCliffType(cliffID, "Egyptian");
         rmAddAreaConstraint(cliffID, cliffConstraint);
         rmAddAreaConstraint(cliffID, playerConstraint);
         rmAddAreaConstraint(cliffID, avoidBuildings);
         rmAddAreaToClass(cliffID, classCliff);
         rmSetAreaMinBlobs(cliffID, 2);
         rmSetAreaMaxBlobs(cliffID, 4);
         if(centerType == 2) /* center is ice */
            rmAddAreaConstraint(cliffID, centerConstraint);
         if(centerType == 5) /* center is trees */
            rmAddAreaConstraint(cliffID, centerConstraint);
         rmSetAreaCliffPainting(cliffID, false, true, true, 1.5, true);
         if(rmRandFloat(0,1) < 0.5)
            rmSetAreaCliffEdge(cliffID, 1, 0.85, 0.2, 1.0, 2);
         else
            rmSetAreaCliffEdge(cliffID, 2, 0.40, 0.2, 1.0, 0);
         rmSetAreaCliffHeight(cliffID, rmRandInt(5,7), 1.0, 1.0);
         rmSetAreaMinBlobDistance(cliffID, 10.0);
         rmSetAreaMaxBlobDistance(cliffID, 10.0);
         rmSetAreaCoherence(cliffID, 0.0);
         rmSetAreaSmoothDistance(cliffID, 10);
         rmSetAreaCliffHeight(cliffID, 7, 1.0, 1.0);
         rmSetAreaHeightBlend(cliffID, 2); 
         rmBuildArea(cliffID);
      }
   }

   
   // Medium things....
   // Gold
   if(rmRandFloat(0,1)<0.75)
      rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   // Pigs
   rmPlaceObjectDefPerPlayer(mediumPigsID, false, rmRandInt(0,2));
   
   // Far things.
   
   // Gold.
   if(rmRandFloat(0,1)<0.75)
      rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(2,4));
   else if(rmRandFloat(0,1)<0.2)
      rmPlaceObjectDefPerPlayer(farGoldID, false, rmRandInt(5,6));

   // Relics
   float relicNum = rmRandFloat(0,1);
   if(relicNum < 0.8)
      rmPlaceObjectDefPerPlayer(relicID, false);
   else if(relicNum < 0.95)
      rmPlaceObjectDefPerPlayer(relicID, false, 2);
   else
      rmPlaceObjectDefPerPlayer(relicID, false, 3);

   // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2); 
   
   // Pigs
   if(rmRandFloat(0,1)<0.90)
      rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(0,2));
   else
      rmPlaceObjectDefPerPlayer(farPigsID, false, rmRandInt(8,10));

   // Bonus huntable.


   for(i=1; <cNumberNonGaiaPlayers)
   {
      if(rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, 1)==0)
      {
         break;
      }
   }

   if(rmRandFloat(0,1)<0.50)
   {
      for(i=1; <cNumberNonGaiaPlayers)
      {
         if(rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, 1)==0)
         {
            break;
         }
      }
   }

   if(rmRandFloat(0,1)<0.15)
   {
      for(i=1; <cNumberNonGaiaPlayers)
      {
         if(rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, 1)==0)
         {
            break;
         }
      }
      for(i=1; <cNumberNonGaiaPlayers)
      {
         if(rmPlaceObjectDefAtLoc(bonusHuntable2ID, 0, 0.5, 0.5, 1)==0)
         {
            break;
         }
      }      
   }


  // Text
   rmSetStatusText("",0.80);

   // Berries
   if(rmRandFloat(0,1)<0.25)
      rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

   // Random trees.
   if(rmRandFloat(0,1)<0.9)
      rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);
   else
      rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   /* Forests */

   int forestCount=10*cNumberNonGaiaPlayers;
   if(rmRandFloat(0,1)<0.1)
   {   
      forestCount=2*cNumberNonGaiaPlayers;
      rmEchoInfo("few forests");
   }     
   float baseForestSize=(rmRandFloat(1,3));
   failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(baseForestSize*50), rmAreaTilesToFraction(baseForestSize*100));
      rmSetAreaWarnFailure(forestID, false);
      if(terrainChance == 0) /* greek */
         {
            if(diverseForest == 0)
            {
               if(forestSpecies<0.7)
                  rmSetAreaForestType(forestID, "oak forest");
               else if(forestSpecies<0.90)
                  rmSetAreaForestType(forestID, "autumn oak forest");
               else
                  rmSetAreaForestType(forestID, "savannah forest");
            }
            else if(diverseForest == 1)
            {
               if(diverseForestType == 0)
               {
                  if(rmRandFloat(0,1)<0.8)
                     rmSetAreaForestType(forestID, "oak forest");
                  else
                     rmSetAreaForestType(forestID, "savannah forest");
               }
               else
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(forestID, "oak forest");
                  else
                     rmSetAreaForestType(forestID, "autumn oak forest");
               }
            }
         }
         else if(terrainChance == 2) /* norse */
         {
            if(diverseForest == 0)
            {
               if(forestSpecies<0.7)
                  rmSetAreaForestType(forestID, "pine forest");
               else if(forestSpecies<0.85)
                  rmSetAreaForestType(forestID, "mixed oak forest");
               else
                  rmSetAreaForestType(forestID, "mixed pine forest");
            }
            else if(diverseForest == 1)
            {
               if(diverseForestType == 0)
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(forestID, "pine forest");
                  else
                     rmSetAreaForestType(forestID, "mixed pine forest");
               }
               else
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(forestID, "snow pine forest");
                  else
                     rmSetAreaForestType(forestID, "mixed pine forest");
               }
            }
         }
         else if(terrainChance == 1) /* egyptian */
         {
            if(diverseForest == 0)
            {
               if(forestSpecies<0.7)
                  rmSetAreaForestType(forestID, "palm forest");
               else if(forestSpecies<0.75)
                  rmSetAreaForestType(forestID, "savannah forest");
               else
                  rmSetAreaForestType(forestID, "mixed palm forest");
            }
            else if(diverseForest == 1)
            {
               if(diverseForestType == 0)
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(forestID, "palm forest");
                  else
                     rmSetAreaForestType(forestID, "savannah forest");
               }
               else
               {
                  if(rmRandFloat(0,1)<0.7)
                     rmSetAreaForestType(forestID, "palm forest");
                  else
                     rmSetAreaForestType(forestID, "mixed palm forest");
               }
            }
         }
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      if(centerType == 2) /* center is ice */
         rmAddAreaConstraint(forestID, centerConstraint);
      rmAddAreaConstraint(forestID, avoidImpassableLand);
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
 
   // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "grass", 12.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 3, 4.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmAddObjectDefConstraint(grassID, avoidImpassableLand);
   if(terrainChance == 0)
      rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 20*cNumberNonGaiaPlayers);
   else if(terrainChance == 1)
      rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

   int rockID=rmCreateObjectDef("rock");
   if(terrainChance == 0)
      rmAddObjectDefItem(rockID, "rock limestone sprite", 1, 1.0);
   else if(terrainChance == 1)
      rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 1.0);
   else
      rmAddObjectDefItem(rockID, "rock granite sprite", 1, 1.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   if(terrainChance == 2)
      rmAddObjectDefConstraint(rockID, centerConstraint);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);


}
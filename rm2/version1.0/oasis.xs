// OASIS

// Main entry point for random map script
void main(void)
{


  // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=7500;
   if(cMapSize == 1)
   {
      playerTiles = 9750;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.9);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);

   // Init map.
   rmTerrainInitialize("SandC");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classPlayerCore=rmDefineClass("player core");
   int classForest=rmDefineClass("forest");
   int classElev=rmDefineClass("elevation");
   rmDefineClass("center");
   rmDefineClass("starting settlement");


   // -------------Define constraints
   
   // Create a edge of map constraint.
   int edgeConstraint=rmCreateBoxConstraint("edge of map", rmXTilesToFraction(8), rmZTilesToFraction(8), 1.0-rmXTilesToFraction(8), 1.0-rmZTilesToFraction(8));
   
   // Center constraint.
   int centerConstraint=rmCreateClassDistanceConstraint("stay away from center", rmClassID("center"), 8.0);
   int playerCenterConstraint=rmCreateClassDistanceConstraint("player areas from center", rmClassID("center"), 12.0);
   int wideCenterConstraint=rmCreateClassDistanceConstraint("wide avoid center", rmClassID("center"), 25.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);

   // Settlement constraints
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("objects avoid TC by short distance", "AbstractSettlement", 20.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("objects avoid player TCs", rmClassID("starting settlement"), 50.0);
       
   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("towers avoid towers", "tower", 25.0);
   int avoidTower2=rmCreateTypeDistanceConstraint("objects avoid towers", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Food
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 30.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);

   // Avoid impassable land
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "land", false, 10.0);
   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 20.0);
   int shortAvoidBuildings=rmCreateTypeDistanceConstraint("short avoid buildings", "Building", 10.0);
   int elevConstraint=rmCreateClassDistanceConstraint("elev avoid elev", rmClassID("elevation"), 10.0);

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
   rmSetObjectDefMinDistance(startingTowerID, 20.0);
   rmSetObjectDefMaxDistance(startingTowerID, 28.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, centerConstraint);
   
   // gold avoids gold
   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 0.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, centerConstraint);

   // goats
   int closeGoatsID=rmCreateObjectDef("close goats");
   rmAddObjectDefItem(closeGoatsID, "goat", 2, 2.0);
   rmSetObjectDefMinDistance(closeGoatsID, 25.0);
   rmSetObjectDefMaxDistance(closeGoatsID, 30.0);
   rmAddObjectDefConstraint(closeGoatsID, centerConstraint);
   rmAddObjectDefConstraint(closeGoatsID, avoidFood);
   
   int closeChickensID=rmCreateObjectDef("close Chickens");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(5,8), 5.0);
   else
      rmAddObjectDefItem(closeChickensID, "berry bush", rmRandInt(6,8), 4.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, centerConstraint);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeBoarID=rmCreateObjectDef("close zebra");
   float boarNumber=rmRandFloat(0, 1);
   rmAddObjectDefItem(closeBoarID, "zebra", rmRandInt(2,5), 2.0);
   rmSetObjectDefMinDistance(closeBoarID, 30.0);
   rmSetObjectDefMaxDistance(closeBoarID, 60.0);
   rmAddObjectDefConstraint(closeBoarID, centerConstraint);
   rmAddObjectDefConstraint(closeBoarID, shortAvoidBuildings);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "palm", 1, 0.0);
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
   rmAddObjectDefConstraint(mediumGoldID, centerConstraint);
   rmAddObjectDefConstraint(mediumGoldID, farStartingSettleConstraint);


   int mediumGoatsID=rmCreateObjectDef("medium Goats");
   rmAddObjectDefItem(mediumGoatsID, "goat", rmRandInt(0,3), 4.0);
   rmSetObjectDefMinDistance(mediumGoatsID, 50.0);
   rmSetObjectDefMaxDistance(mediumGoatsID, 70.0);
   rmAddObjectDefConstraint(mediumGoatsID, centerConstraint);
   rmAddObjectDefConstraint(mediumGoatsID, avoidHerdable);
   rmAddObjectDefConstraint(mediumGoatsID, farStartingSettleConstraint);

   
   // Far Objects

   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 80.0);
   rmSetObjectDefMaxDistance(farGoldID, 150.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, edgeConstraint);
   rmAddObjectDefConstraint(farGoldID, centerConstraint); 
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   // Goats avoid TCs and other herds, since this map places a lot of Goats
   int farGoatsID=rmCreateObjectDef("far Goats");
   rmAddObjectDefItem(farGoatsID, "goat", 2, 4.0);
   rmSetObjectDefMinDistance(farGoatsID, 80.0);
   rmSetObjectDefMaxDistance(farGoatsID, 150.0);
   rmAddObjectDefConstraint(farGoatsID, centerConstraint);
   rmAddObjectDefConstraint(farGoatsID, avoidHerdable);
   rmAddObjectDefConstraint(farGoatsID, farStartingSettleConstraint);
   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "lion", 2, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "hyena", 3, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 50.0);
   rmSetObjectDefMaxDistance(farPredatorID, 100.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farPredatorID, centerConstraint);
   
   // Berries avoid TCs  
   int farBerriesID=rmCreateObjectDef("far berries");
   rmAddObjectDefItem(farBerriesID, "berry bush", rmRandInt(4,10), 4.0);
   rmSetObjectDefMinDistance(farBerriesID, 0.0);
   rmSetObjectDefMaxDistance(farBerriesID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farBerriesID, centerConstraint); 
   rmAddObjectDefConstraint(farBerriesID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farBerriesID, shortAvoidGold);
   rmAddObjectDefConstraint(farBerriesID, shortAvoidSettlement);
   
   // This map will either use boar or deer as the extra huntable food.
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidBonusHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 40.0);
   int avoidHuntable=rmCreateTypeDistanceConstraint("avoid huntable", "huntable", 40.0);

   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)
   {  
      rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(2,3), 2.0);
      rmAddObjectDefItem(bonusHuntableID, "gazelle", rmRandInt(0,4), 3.0);
   }
   else
      rmAddObjectDefItem(bonusHuntableID, "giraffe", rmRandInt(2,5), 2.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, centerConstraint); 

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "palm", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID, centerConstraint);

   int randomTreeID2=rmCreateObjectDef("random tree 2");
   rmAddObjectDefItem(randomTreeID2, "savannah tree", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID2, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID2, rmCreateTypeDistanceConstraint("random tree 2", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID2, shortAvoidSettlement);
   rmAddObjectDefConstraint(randomTreeID2, centerConstraint);

      // Monkeys avoid TCs  
   int farMonkeyID=rmCreateObjectDef("far monkeys");
   if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(farMonkeyID, "baboon", rmRandInt(4,6), 3.0);
   else
      rmAddObjectDefItem(farMonkeyID, "monkey", rmRandInt(5,8), 3.0);
   rmSetObjectDefMinDistance(farMonkeyID, 0.0);
   rmSetObjectDefMaxDistance(farMonkeyID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(farMonkeyID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(farMonkeyID, centerConstraint);
   rmAddObjectDefConstraint(farMonkeyID, avoidHuntable);

    // Birds
   int farhawkID=rmCreateObjectDef("far hawks");
   rmAddObjectDefItem(farhawkID, "vulture", 1, 0.0);
   rmSetObjectDefMinDistance(farhawkID, 0.0);
   rmSetObjectDefMaxDistance(farhawkID, rmXFractionToMeters(0.5));
   
   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 60.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, edgeConstraint);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, farAvoidSettlement);
   rmAddObjectDefConstraint(relicID, centerConstraint); 


   // -------------Done defining objects

   // Cheesy "circular" placement of players.
/*   rmPlacePlayersCircular(0.4, 0.45, rmDegreesToRadians(5.0)); */

     rmPlacePlayersSquare(0.4, 0.05, 0.05);

  // Text
   rmSetStatusText("",0.20);

   // Dumb thing to just block out player areas since placement sucks right now.
   // This area doesn't paint down anything, it just exists for blocking out the center sea.
   for(i=1; <cNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player core"+i);

      // Set the size.
      rmSetAreaSize(id, rmAreaTilesToFraction(110), rmAreaTilesToFraction(110));

      rmAddAreaToClass(id, classPlayerCore);

      rmSetAreaCoherence(id, 1.0);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Build it.
/*      rmBuildArea(id); */
   }


   int forestOneID = 0;
   int forestTwoID = 0;
   int forestThreeID = 0;
   int forestFourID = 0;
   int coreOneID = 0;
   int coreTwoID = 0;
   int coreThreeID = 0;
   int coreFourID = 0;

   float oasisChance=rmRandFloat(0, 1);
   int forestNumber =0;
   if(oasisChance < 0.30)
   {
      // Create a forest
      forestOneID=rmCreateArea("forest one");
      rmSetAreaSize(forestOneID, 0.15, 0.15);
      rmSetAreaLocation(forestOneID, 0.5, 0.5);
      rmSetAreaForestType(forestOneID, "palm forest");
      rmAddAreaToClass(forestOneID, rmClassID("center"));
      rmSetAreaMinBlobs(forestOneID, 1);
      rmSetAreaMaxBlobs(forestOneID, 1);
      rmSetAreaSmoothDistance(forestOneID, 50);
      rmSetAreaCoherence(forestOneID, 0.25);
      rmAddAreaToClass(forestOneID, classForest);
      rmBuildArea(forestOneID);

      // Create the core lake
      coreOneID=rmCreateArea("core one");
      rmSetAreaSize(coreOneID, 0.06, 0.06);
      rmSetAreaLocation(coreOneID, 0.5, 0.5);
      rmSetAreaWaterType(coreOneID, "Egyptian Nile");
      rmAddAreaToClass(coreOneID, rmClassID("center"));
      rmSetAreaBaseHeight(coreOneID, 0.0);
      rmSetAreaMinBlobs(coreOneID, 1);
      rmSetAreaMaxBlobs(coreOneID, 1);
      rmSetAreaSmoothDistance(coreOneID, 50);
      rmSetAreaCoherence(coreOneID, 0.25);
      rmBuildArea(coreOneID);
   }      /* mono forest */
   else if(oasisChance < 0.45)
   {
      // Create a forest
      forestOneID=rmCreateArea("forest one");
      rmSetAreaSize(forestOneID, 0.08, 0.08);
      rmSetAreaLocation(forestOneID, 0.35, 0.65);
      rmSetAreaForestType(forestOneID, "palm forest");
      rmAddAreaToClass(forestOneID, rmClassID("center"));
      rmSetAreaMinBlobs(forestOneID, 1);
      rmSetAreaMaxBlobs(forestOneID, 1);
      rmSetAreaSmoothDistance(forestOneID, 50);
      rmSetAreaCoherence(forestOneID, 0.25);
      rmAddAreaToClass(forestOneID, classForest);
      rmBuildArea(forestOneID);

      // Create the core lake
         coreOneID=rmCreateArea("core one");
         rmSetAreaSize(coreOneID, 0.030, 0.030);
         rmSetAreaLocation(coreOneID, 0.35, 0.65);
         rmSetAreaWaterType(coreOneID, "Egyptian Nile");
         rmAddAreaToClass(coreOneID, rmClassID("center"));
         rmSetAreaBaseHeight(coreOneID, 0.0);
         rmSetAreaMinBlobs(coreOneID, 1);
         rmSetAreaMaxBlobs(coreOneID, 1);
         rmSetAreaSmoothDistance(coreOneID, 50);
         rmSetAreaCoherence(coreOneID, 0.25);
         rmBuildArea(coreOneID);
      

      // Create a forest
      forestTwoID=rmCreateArea("forest two");
      rmSetAreaSize(forestTwoID, 0.08, 0.08);
      rmSetAreaLocation(forestTwoID, 0.65, 0.35);
      rmSetAreaForestType(forestTwoID, "palm forest");
      rmAddAreaToClass(forestTwoID, rmClassID("center"));
      rmSetAreaMinBlobs(forestTwoID, 1);
      rmSetAreaMaxBlobs(forestTwoID, 1);
      rmSetAreaSmoothDistance(forestTwoID, 50);
      rmSetAreaCoherence(forestTwoID, 0.25);
      rmAddAreaToClass(forestTwoID, classForest);
      rmBuildArea(forestTwoID);

      // Create the core lake
     
         coreTwoID=rmCreateArea("core two");
         rmSetAreaSize(coreTwoID, 0.030, 0.030);
         rmSetAreaLocation(coreTwoID, 0.65, 0.35);
         rmSetAreaWaterType(coreTwoID, "Egyptian Nile");
         rmAddAreaToClass(coreTwoID, rmClassID("center"));
         rmSetAreaBaseHeight(coreTwoID, 0.0);
         rmSetAreaMinBlobs(coreTwoID, 1);
         rmSetAreaMaxBlobs(coreTwoID, 1);
         rmSetAreaSmoothDistance(coreTwoID, 50);
         rmSetAreaCoherence(coreTwoID, 0.25);
         rmBuildArea(coreTwoID);
      
   }      /* horizontal pair */
   else if(oasisChance < 0.60)
   {
      // Create a forest
      forestOneID=rmCreateArea("forest one");
      rmSetAreaSize(forestOneID, 0.08, 0.08);
      rmSetAreaLocation(forestOneID, 0.35, 0.35);
      rmSetAreaForestType(forestOneID, "palm forest");
      rmAddAreaToClass(forestOneID, rmClassID("center"));
      rmSetAreaMinBlobs(forestOneID, 1);
      rmSetAreaMaxBlobs(forestOneID, 1);
      rmSetAreaSmoothDistance(forestOneID, 50);
      rmSetAreaCoherence(forestOneID, 0.25);
      rmAddAreaToClass(forestOneID, classForest);
      rmBuildArea(forestOneID);

      // Create the core lake
      
         coreOneID=rmCreateArea("core one");
         rmSetAreaSize(coreOneID, 0.030, 0.030);
         rmSetAreaLocation(coreOneID, 0.35, 0.35);
         rmSetAreaWaterType(coreOneID, "Egyptian Nile");
         rmAddAreaToClass(coreOneID, rmClassID("center"));
         rmSetAreaBaseHeight(coreOneID, 0.0);
         rmSetAreaMinBlobs(coreOneID, 1);
         rmSetAreaMaxBlobs(coreOneID, 1);
         rmSetAreaSmoothDistance(coreOneID, 50);
         rmSetAreaCoherence(coreOneID, 0.25);
         rmBuildArea(coreOneID);
     

      // Create a forest
      forestTwoID=rmCreateArea("forest two");
      rmSetAreaSize(forestTwoID, 0.08, 0.08);
      rmSetAreaLocation(forestTwoID, 0.65, 0.65);
      rmSetAreaForestType(forestTwoID, "palm forest");
      rmAddAreaToClass(forestTwoID, rmClassID("center"));
      rmSetAreaMinBlobs(forestTwoID, 1);
      rmSetAreaMaxBlobs(forestTwoID, 1);
      rmSetAreaSmoothDistance(forestTwoID, 50);
      rmSetAreaCoherence(forestTwoID, 0.25);
      rmAddAreaToClass(forestTwoID, classForest);
      rmBuildArea(forestTwoID);

      // Create the core lake
     
         coreTwoID=rmCreateArea("core two");
         rmSetAreaSize(coreTwoID, 0.030, 0.030);
         rmSetAreaLocation(coreTwoID, 0.65, 0.65);
         rmSetAreaWaterType(coreTwoID, "Egyptian Nile");
         rmAddAreaToClass(coreTwoID, rmClassID("center"));
         rmSetAreaBaseHeight(coreTwoID, 0.0);
         rmSetAreaMinBlobs(coreTwoID, 1);
         rmSetAreaMaxBlobs(coreTwoID, 1);
         rmSetAreaSmoothDistance(coreTwoID, 50);
         rmSetAreaCoherence(coreTwoID, 0.25);
         rmBuildArea(coreTwoID);
   }      
   else
      /* quad forest */
   {
      // Create a forest
      forestOneID=rmCreateArea("forest one");
      rmSetAreaSize(forestOneID, 0.04, 0.04);
      rmSetAreaLocation(forestOneID, 0.5, 0.7);
      rmSetAreaForestType(forestOneID, "palm forest");
      rmAddAreaToClass(forestOneID, rmClassID("center"));
      rmSetAreaMinBlobs(forestOneID, 1);
      rmSetAreaMaxBlobs(forestOneID, 1);
      rmSetAreaSmoothDistance(forestOneID, 50);
      rmSetAreaCoherence(forestOneID, 0.25);
      rmAddAreaToClass(forestOneID, classForest);
      rmBuildArea(forestOneID);

      // Create the core lake
      if(cNumberPlayers > 4)
      {
         coreOneID=rmCreateArea("core one");
         rmSetAreaSize(coreOneID, 0.015, 0.015);
         rmSetAreaLocation(coreOneID, 0.5, 0.7);
         rmSetAreaWaterType(coreOneID, "Egyptian Nile");
         rmAddAreaToClass(coreOneID, rmClassID("center"));
         rmSetAreaBaseHeight(coreOneID, 0.0);
         rmSetAreaMinBlobs(coreOneID, 1);
         rmSetAreaMaxBlobs(coreOneID, 1);
         rmSetAreaSmoothDistance(coreOneID, 50);
         rmSetAreaCoherence(coreOneID, 0.25);
         rmBuildArea(coreOneID);
      }

      // Create a forest
      forestTwoID=rmCreateArea("forest two");
      rmSetAreaSize(forestTwoID, 0.04, 0.04);
      rmSetAreaLocation(forestTwoID, 0.7, 0.5);
      rmSetAreaForestType(forestTwoID, "palm forest");
      rmAddAreaToClass(forestTwoID, rmClassID("center"));
      rmSetAreaMinBlobs(forestTwoID, 1);
      rmSetAreaMaxBlobs(forestTwoID, 1);
      rmSetAreaSmoothDistance(forestTwoID, 50);
      rmSetAreaCoherence(forestTwoID, 0.25);
      rmAddAreaToClass(forestTwoID, classForest);
      rmBuildArea(forestTwoID);

      // Create the core lake
      if(cNumberPlayers > 4)
      {
         coreTwoID=rmCreateArea("core two");
         rmSetAreaSize(coreTwoID, 0.015, 0.015);
         rmSetAreaLocation(coreTwoID, 0.7, 0.5);
         rmSetAreaWaterType(coreTwoID, "Egyptian Nile");
         rmAddAreaToClass(coreTwoID, rmClassID("center"));
         rmSetAreaBaseHeight(coreTwoID, 0.0);
         rmSetAreaMinBlobs(coreTwoID, 1);
         rmSetAreaMaxBlobs(coreTwoID, 1);
         rmSetAreaSmoothDistance(coreTwoID, 50);
         rmSetAreaCoherence(coreTwoID, 0.25);
         rmBuildArea(coreTwoID);
      }

      // Create a forest
      forestThreeID=rmCreateArea("forest three");
      rmSetAreaSize(forestThreeID, 0.04, 0.04);
      rmSetAreaLocation(forestThreeID, 0.5, 0.3);
      rmSetAreaForestType(forestThreeID, "palm forest");
      rmAddAreaToClass(forestThreeID, rmClassID("center"));
      rmSetAreaMinBlobs(forestThreeID, 1);
      rmSetAreaMaxBlobs(forestThreeID, 1);
      rmSetAreaSmoothDistance(forestThreeID, 50);
      rmSetAreaCoherence(forestThreeID, 0.25);
      rmAddAreaToClass(forestThreeID, classForest);
      rmBuildArea(forestThreeID);

      // Create the core lake
      if(cNumberPlayers > 4)
      {
         coreThreeID=rmCreateArea("core three");
         rmSetAreaSize(coreThreeID, 0.015, 0.015);
         rmSetAreaLocation(coreThreeID, 0.5, 0.3);
         rmSetAreaWaterType(coreThreeID, "Egyptian Nile");
         rmAddAreaToClass(coreThreeID, rmClassID("center"));
         rmSetAreaBaseHeight(coreThreeID, 0.0);
         rmSetAreaMinBlobs(coreThreeID, 1);
         rmSetAreaMaxBlobs(coreThreeID, 1);
         rmSetAreaSmoothDistance(coreThreeID, 50);
         rmSetAreaCoherence(coreThreeID, 0.25);
         rmBuildArea(coreThreeID);
      }

      // Create a forest
      forestFourID=rmCreateArea("forest four");
      rmSetAreaSize(forestFourID, 0.04, 0.04);
      rmSetAreaLocation(forestFourID, 0.3, 0.5);
      rmSetAreaForestType(forestFourID, "palm forest");
      rmAddAreaToClass(forestFourID, rmClassID("center"));
      rmSetAreaMinBlobs(forestFourID, 1);
      rmSetAreaMaxBlobs(forestFourID, 1);
      rmSetAreaSmoothDistance(forestFourID, 50);
      rmSetAreaCoherence(forestFourID, 0.25);
      rmAddAreaToClass(forestFourID, classForest);
      rmBuildArea(forestFourID);

      // Create the core lake
      if(cNumberPlayers > 4)
      {
         coreFourID=rmCreateArea("core four");
         rmSetAreaSize(coreFourID, 0.015, 0.015);
         rmSetAreaLocation(coreFourID, 0.3, 0.5);
         rmSetAreaWaterType(coreFourID, "Egyptian Nile");
         rmAddAreaToClass(coreFourID, rmClassID("center"));
         rmSetAreaBaseHeight(coreFourID, 0.0);
         rmSetAreaMinBlobs(coreFourID, 1);
         rmSetAreaMaxBlobs(coreFourID, 1);
         rmSetAreaSmoothDistance(coreFourID, 50);
         rmSetAreaCoherence(coreFourID, 0.25);
         rmBuildArea(coreFourID);
      }
   }      
   /* quad*/

   
  // Text
   rmSetStatusText("",0.40);

   // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(3000);
   for(i=1; <cNumberPlayers)
   {
      id=rmCreateArea("Player"+i);
      rmSetPlayerArea(i, id);
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);
      rmAddAreaToClass(id, classPlayer);
      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 5);
      rmSetAreaMinBlobDistance(id, 16.0);
      rmSetAreaMaxBlobDistance(id, 40.0);
      rmSetAreaCoherence(id, 0.0);
      rmAddAreaConstraint(id, playerCenterConstraint);
      rmSetAreaLocPlayer(id, i);
      rmSetAreaTerrainType(id, "SandDirt50"); 
      rmAddAreaTerrainLayer(id, "SandA", 1, 2); 
      rmAddAreaTerrainLayer(id, "SandB", 0, 1); 
   }


   // Build the areas.
   rmBuildAllAreas();

   for(i=1; <cNumberPlayers*5)
   {
      // Beautification sub area.
      int id2=rmCreateArea("patch A"+i);
      rmSetAreaSize(id2, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaTerrainType(id2, "SandD");
      rmSetAreaMinBlobs(id2, 1);
      rmSetAreaMaxBlobs(id2, 5);
      rmSetAreaMinBlobDistance(id2, 16.0);
      rmSetAreaMaxBlobDistance(id2, 40.0);
      rmSetAreaCoherence(id2, 0.0);
      rmAddAreaConstraint(id2, centerConstraint);
      rmAddAreaConstraint(id2, avoidBuildings);
      rmBuildArea(id2);
   }



  // Text
   rmSetStatusText("",0.60);

     // Elev.
   int numTries=10*cNumberNonGaiaPlayers;
   int failCount=0;
   for(i=0; <numTries)
   {
      int elevID=rmCreateArea("elev"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(100), rmAreaTilesToFraction(200));
      rmSetAreaWarnFailure(elevID, false);
      rmAddAreaConstraint(elevID, avoidBuildings);
      rmAddAreaConstraint(elevID, centerConstraint);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SandD");
      rmSetAreaBaseHeight(elevID, rmRandFloat(3.0, 6.0));
      rmSetAreaHeightBlend(elevID, 2);
      rmAddAreaToClass(id, classElev);
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 5);
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 40.0);
      rmSetAreaCoherence(elevID, 0.0);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==6)
            break;
      }
      else
         failCount=0;
   }

   numTries=20*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      elevID=rmCreateArea("wrinkle"+i);
      rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(120));
/*      rmSetAreaLocation(elevID, rmRandFloat(0.0, 1.0), rmRandFloat(0.0, 1.0)); */
      rmSetAreaWarnFailure(elevID, false);
      rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 3.0));
      rmSetAreaMinBlobs(elevID, 1);
      rmSetAreaMaxBlobs(elevID, 3);
      if(rmRandFloat(0.0, 1.0)<0.5)
         rmSetAreaTerrainType(elevID, "SandD");
      rmSetAreaMinBlobDistance(elevID, 16.0);
      rmSetAreaMaxBlobDistance(elevID, 20.0);
      rmSetAreaCoherence(elevID, 0.0);
      rmAddAreaConstraint(elevID, centerConstraint);
      rmAddAreaConstraint(elevID, avoidImpassableLand);
      rmAddAreaToClass(elevID, classElev);
      rmAddAreaConstraint(elevID, elevConstraint);

      if(rmBuildArea(elevID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==10)
            break;
      }
      else
         failCount=0;
   }

   

	
   // Place starting settlements.
   // Close things....
   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   // Settlements.
   id=rmAddFairLoc("Settlement", false, true, 60, 80, 50, 16); /* forward inside */
   rmAddFairLocConstraint(id, wideCenterConstraint);

   if(rmRandFloat(0,1)<0.75)
      id=rmAddFairLoc("Settlement", true, false, 70, 120, 50, 16);
   else
      id=rmAddFairLoc("Settlement", false, true,  60, 100, 40, 16);

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
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);
   
   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

   // Goats
   rmPlaceObjectDefPerPlayer(closeGoatsID, true);

   // Chickens or berries.

   rmPlaceObjectDefPerPlayer(closeChickensID, true);

   // Boar.
   rmPlaceObjectDefPerPlayer(closeBoarID, false);



      // Some cliffy areas
   numTries=8*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <numTries)
   {
      int rockyID=rmCreateArea("rocky terrain"+i);
      rmSetAreaSize(rockyID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(200));
      rmSetAreaWarnFailure(rockyID, false);
      rmSetAreaMinBlobs(rockyID, 1);
      rmSetAreaMaxBlobs(rockyID, 1);
      rmSetAreaTerrainType(rockyID, "SavannahC");
      rmAddAreaTerrainLayer(rockyID, "SandA", 0, 2);
      rmSetAreaBaseHeight(rockyID, rmRandFloat(2.0, 5.0));
      rmSetAreaMinBlobDistance(rockyID, 16.0);
      rmSetAreaMaxBlobDistance(rockyID, 20.0);
      rmSetAreaCoherence(rockyID, 1.0); 
      rmSetAreaSmoothDistance(rockyID, 10);
      rmAddAreaConstraint(rockyID, centerConstraint);
      rmAddAreaConstraint(rockyID, avoidBuildings);
      rmAddAreaConstraint(rockyID, avoidImpassableLand);
      rmAddAreaConstraint(rockyID, elevConstraint); 

      if(rmBuildArea(rockyID)==false)
      {
         // Stop trying once we fail 3 times in a row.
         failCount++;
         if(failCount==10)
            break;
      }
      else
         failCount=0;
   }

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

   // Goats
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumGoatsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
   
   // Far things.
   
   // Gold.
   rmPlaceObjectDefPerPlayer(farGoldID, false, 3);

   // Relics
   rmPlaceObjectDefPerPlayer(relicID, false, 1);

    // Hawks
   rmPlaceObjectDefPerPlayer(farhawkID, false, 2);
   
   // Goats
   for(i=1; <cNumberPlayers)
      rmPlaceObjectDefAtLoc(farGoatsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 3);

   // Bonus huntable.
   rmPlaceObjectDefAtLoc(bonusHuntableID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   // Berries.
   rmPlaceObjectDefAtLoc(farBerriesID, 0, 0.5, 0.5, cNumberPlayers);

   // Predators
   rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);

  // Text
   rmSetStatusText("",0.80);

   // Monkeys
   if(rmRandFloat(0,1)<0.66)
      rmPlaceObjectDefPerPlayer(farMonkeyID, false, 1);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 7*cNumberNonGaiaPlayers);
   rmPlaceObjectDefAtLoc(randomTreeID2, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);


   // Forest.
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 20.0);
   int forestCount=8*cNumberNonGaiaPlayers;
   failCount=0;
   for(i=0; <forestCount)
   {
      int forestID=rmCreateArea("forest"+i);
      rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
      rmSetAreaWarnFailure(forestID, false);
      rmSetAreaForestType(forestID, "palm forest");
      rmAddAreaConstraint(forestID, forestSettleConstraint);
      rmAddAreaConstraint(forestID, forestObjConstraint);
      rmAddAreaConstraint(forestID, forestConstraint);
      rmAddAreaConstraint(forestID, centerConstraint);
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
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 6.0);
   int deerID=rmCreateObjectDef("lonely deer");
   if(rmRandFloat(0,1)<0.33)
      rmAddObjectDefItem(deerID, "monkey", rmRandInt(1,2), 1.0);
   else if(rmRandFloat(0,1)<0.5)
      rmAddObjectDefItem(deerID, "zebra", 1, 0.0);
   else
      rmAddObjectDefItem(deerID, "gazelle", rmRandInt(1,3), 2.0);
   rmSetObjectDefMinDistance(deerID, 0.0);
   rmSetObjectDefMaxDistance(deerID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(deerID, avoidAll);
   rmAddObjectDefConstraint(deerID, avoidBuildings);
   rmAddObjectDefConstraint(deerID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(deerID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);

   //rocks
   int rockID=rmCreateObjectDef("rock");
   rmAddObjectDefItem(rockID, "rock sandstone sprite", 1, 0.0);
   rmSetObjectDefMinDistance(rockID, 0.0);
   rmSetObjectDefMaxDistance(rockID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(rockID, avoidAll);
   rmAddObjectDefConstraint(rockID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(rockID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

     // Bushes
   int bushID=rmCreateObjectDef("big bush patch");
   rmAddObjectDefItem(bushID, "bush", 4, 3.0);
   rmSetObjectDefMinDistance(bushID, 0.0);
   rmSetObjectDefMaxDistance(bushID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bushID, avoidAll);
   rmAddObjectDefConstraint(bushID, centerConstraint);
   rmPlaceObjectDefAtLoc(bushID, 0, 0.5, 0.5, 5*cNumberNonGaiaPlayers);

   int bush2ID=rmCreateObjectDef("small bush patch");
   rmAddObjectDefItem(bush2ID, "bush", 3, 2.0);
   rmAddObjectDefItem(bush2ID, "rock sandstone sprite", 1, 2.0);
   rmSetObjectDefMinDistance(bush2ID, 0.0);
   rmSetObjectDefMaxDistance(bush2ID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bush2ID, avoidAll);
   rmAddObjectDefConstraint(bush2ID, centerConstraint);
   rmPlaceObjectDefAtLoc(bush2ID, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "grass", 1, 0.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidAll);
   rmAddObjectDefConstraint(grassID, centerConstraint);
   rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 30*cNumberNonGaiaPlayers);

   int driftVsDrift=rmCreateTypeDistanceConstraint("drift vs drift", "sand drift dune", 25.0);
   int sandDrift=rmCreateObjectDef("blowing sand");
   rmAddObjectDefItem(sandDrift, "sand drift patch", 1, 0.0);
   rmSetObjectDefMinDistance(sandDrift, 0.0);
   rmSetObjectDefMaxDistance(sandDrift, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(sandDrift, avoidAll);
   rmAddObjectDefConstraint(sandDrift, centerConstraint);
   rmAddObjectDefConstraint(sandDrift, edgeConstraint);
   rmAddObjectDefConstraint(sandDrift, driftVsDrift);
   rmAddObjectDefConstraint(sandDrift, avoidBuildings);
   rmPlaceObjectDefAtLoc(sandDrift, 0, 0.5, 0.5, 3*cNumberNonGaiaPlayers);

  // Text
   rmSetStatusText("",1.0);

}  





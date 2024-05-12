include "rmx 5-0-0 void.xs";


// Main entry point for random map script
void main(void)
{
	rmxInit("Plains of Abaddon (by AProperGentleman)", false, false, false);


int realNumberNonGaiaPlayers = cNumberNonGaiaPlayers - 1;
   int realNumberPlayers = cNumberPlayers - 1;

  // Text
   rmSetStatusText("",0.01);

   // Set size.
   int playerTiles=11500 + 13000;
   if(cMapSize == 1)
   {
      playerTiles = 13860 + 13000;
      rmEchoInfo("Large map");
   }
   int size=2.0*sqrt(realNumberNonGaiaPlayers*playerTiles);
   rmEchoInfo("Map size="+size+"m x "+size+"m");
   rmSetMapSize(size, size);

   // Set up default water.
   rmSetSeaLevel(0.0);
   rmSetSeaType("mediterranean sea");

   // Init map.
   //rmTerrainInitialize("water");
   rmTerrainInitialize("Hades5");

   // Define some classes.
   int classPlayer=rmDefineClass("player");
   int classBonusIsland=rmDefineClass("bonus island");
   int classIsland=rmDefineClass("island");
   rmDefineClass("corner");
   rmDefineClass("starting settlement");






   // -------------Define constraints
   
   // Create a edge of map constraint.
   int playerEdgeConstraint=rmCreateBoxConstraint("player edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1), 0.01);
   int farEdgeConstraint=rmCreateBoxConstraint("center edge of map", rmXTilesToFraction(1), rmZTilesToFraction(1), 1.0-rmXTilesToFraction(1), 1.0-rmZTilesToFraction(1), 0.3);

   // Player area constraint.
   int playerConstraint=rmCreateClassDistanceConstraint("stay away from players", classPlayer, 30.0);
   int shortPlayerConstraint=rmCreateClassDistanceConstraint("short stay away from players", classPlayer, 2.0);

   // corner constraint.
   int cornerConstraint=rmCreateClassDistanceConstraint("stay away from corner", rmClassID("corner"), 15.0);
   int cornerOverlapConstraint=rmCreateClassDistanceConstraint("don't overlap corner", rmClassID("corner"), 2.0);

   // Settlement constraint.
   int avoidSettlement=rmCreateTypeDistanceConstraint("avoid settlement", "AbstractSettlement", 50.0);
	int mediumAvoidSettlement=rmCreateTypeDistanceConstraint("medium avoid settlement", "AbstractSettlement", 30.0);
   int shortAvoidSettlement=rmCreateTypeDistanceConstraint("short avoid settlement", "AbstractSettlement", 10.0);
   int farAvoidSettlement=rmCreateTypeDistanceConstraint("TCs avoid TCs by long distance", "AbstractSettlement", 50.0);

   // Far starting settlement constraint.
   int farStartingSettleConstraint=rmCreateClassDistanceConstraint("far start settle", rmClassID("starting settlement"), 60.0);

   // Tower constraint.
   int avoidTower=rmCreateTypeDistanceConstraint("avoid tower", "tower", 25.0);

   // Gold
   int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
   int shortAvoidGold=rmCreateTypeDistanceConstraint("short avoid gold", "gold", 10.0);

   // Portals
   int avoidPortal=rmCreateTypeDistanceConstraint("avoid portal", "sky passage", 30.0);

   // Goats/pigs
   int avoidHerdable=rmCreateTypeDistanceConstraint("avoid herdable", "herdable", 20.0);

   // Animals
   int classBonusHuntable=rmDefineClass("bonus huntable");
   int avoidHuntable=rmCreateClassDistanceConstraint("avoid bonus huntable", classBonusHuntable, 15.0);
   int avoidFood=rmCreateTypeDistanceConstraint("avoid other food sources", "food", 6.0);
   int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 20.0);

   // Avoid impassable land
   int longAvoidImpassableLand=rmCreateTerrainDistanceConstraint("long avoid impassable land", "Land", false, 30.0);
   int avoidImpassableLand=rmCreateTerrainDistanceConstraint("avoid impassable land", "Land", false, 10.0);
   int shortAvoidImpassableLand=rmCreateTerrainDistanceConstraint("short avoid impassable land", "Land", false, 5.0);

   //Island avoidance
   int islandConstraint=rmCreateClassDistanceConstraint("islands avoid islands", classIsland, 10.0);
   int fireConstraint=rmCreateClassDistanceConstraint("fires avoid islands", classIsland, 1.0);

   // -------------Define objects
   // Close Objects

   int startingSettlementID=rmCreateObjectDef("Starting settlement");
   rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
   rmAddObjectDefToClass(startingSettlementID, rmClassID("starting settlement"));
   rmSetObjectDefMinDistance(startingSettlementID, 0.0);
   rmSetObjectDefMaxDistance(startingSettlementID, 10.0);
	rmAddObjectDefConstraint(startingSettlementID, longAvoidImpassableLand);

   // towers avoid other towers
   int startingTowerID=rmCreateObjectDef("Starting tower");
   rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
   rmSetObjectDefMinDistance(startingTowerID, 22.0);
   rmSetObjectDefMaxDistance(startingTowerID, 25.0);
   rmAddObjectDefConstraint(startingTowerID, avoidTower);
   rmAddObjectDefConstraint(startingTowerID, avoidImpassableLand);

   int startingGoldID=rmCreateObjectDef("Starting gold");
   rmAddObjectDefItem(startingGoldID, "Gold mine small", 1, 1.0);
   rmSetObjectDefMinDistance(startingGoldID, 20.0);
   rmSetObjectDefMaxDistance(startingGoldID, 25.0);
   rmAddObjectDefConstraint(startingGoldID, avoidGold);
   rmAddObjectDefConstraint(startingGoldID, avoidImpassableLand);
	rmAddObjectDefConstraint(startingGoldID, shortAvoidSettlement);

   // pigs
   int closePigsID=rmCreateObjectDef("close pigs");
   rmAddObjectDefItem(closePigsID, "pig", 2, 2.0);
   rmSetObjectDefMinDistance(closePigsID, 5.0);
   rmSetObjectDefMaxDistance(closePigsID, 20.0);
   rmAddObjectDefConstraint(closePigsID, avoidFood);   

   int closeChickensID=rmCreateObjectDef("close Chickens");
   rmAddObjectDefItem(closeChickensID, "chicken", rmRandInt(7,10), 5.0);
   rmSetObjectDefMinDistance(closeChickensID, 20.0);
   rmSetObjectDefMaxDistance(closeChickensID, 25.0);
   rmAddObjectDefConstraint(closeChickensID, avoidFood); 

   int closeWaterBuffaloID=rmCreateObjectDef("close water buffalo");
   float waterBuffaloNumber=rmRandFloat(0, 1);
   if(waterBuffaloNumber<0.3)
      rmAddObjectDefItem(closeWaterBuffaloID, "monkey", 5, 4.0);
   else if(waterBuffaloNumber<0.6)
      rmAddObjectDefItem(closeWaterBuffaloID, "monkey", 8, 4.0);
   else 
      rmAddObjectDefItem(closeWaterBuffaloID, "monkey", 11, 6.0);
   rmSetObjectDefMinDistance(closeWaterBuffaloID, 30.0);
   rmSetObjectDefMaxDistance(closeWaterBuffaloID, 50.0);

   int stragglerTreeID=rmCreateObjectDef("straggler tree");
   rmAddObjectDefItem(stragglerTreeID, "dead pine", 1, 0.0);
   rmSetObjectDefMinDistance(stragglerTreeID, 12.0);
   rmSetObjectDefMaxDistance(stragglerTreeID, 15.0);
	rmAddObjectDefConstraint(stragglerTreeID, shortAvoidImpassableLand);


   // Medium Objects

   // gold avoids gold and Settlements
   int mediumGoldID=rmCreateObjectDef("medium gold");
   rmAddObjectDefItem(mediumGoldID, "gold mine", 1, 12.0);
   rmSetObjectDefMinDistance(mediumGoldID, 30.0);
   rmSetObjectDefMaxDistance(mediumGoldID, 65.0);
   rmAddObjectDefConstraint(mediumGoldID, avoidGold);
   rmAddObjectDefConstraint(mediumGoldID, mediumAvoidSettlement);
   rmAddObjectDefConstraint(mediumGoldID, avoidImpassableLand);

   int mediumPigsID=rmCreateObjectDef("medium pigs");
   rmAddObjectDefItem(mediumPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(mediumPigsID, 50.0);
   rmSetObjectDefMaxDistance(mediumPigsID, 70.0);
   rmAddObjectDefConstraint(mediumPigsID, shortAvoidImpassableLand);
   
   // Far Objects

   // Settlement avoid Settlements
   int farSettlementID=rmCreateObjectDef("far settlement");
   rmAddObjectDefItem(farSettlementID, "Settlement", 1, 0.0);
   rmSetObjectDefMinDistance(farSettlementID, 80.0);
   rmSetObjectDefMaxDistance(farSettlementID, 120.0);
   rmAddObjectDefConstraint(farSettlementID, avoidImpassableLand);
   rmAddObjectDefConstraint(farSettlementID, mediumAvoidSettlement);

   int bonusSettlementID=rmCreateObjectDef("bonus settlement");
   rmAddObjectDefItem(bonusSettlementID, "Settlement", 1, 0.0);
   rmAddObjectDefItem(bonusSettlementID, "Shade of Erebus", 4, 10.0);
   rmAddObjectDefItem(bonusSettlementID, "ruins", rmRandInt(1,2), 10.0);
   rmAddObjectDefItem(bonusSettlementID, "columns broken", rmRandInt(1,2), 10.0);
   rmSetObjectDefMinDistance(bonusSettlementID, 30.0);
   rmSetObjectDefMaxDistance(bonusSettlementID, 60.0);
   rmAddObjectDefConstraint(bonusSettlementID, avoidImpassableLand);
         
   // gold avoids gold, Settlements and TCs
   int farGoldID=rmCreateObjectDef("far gold");
   rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(farGoldID, 0.0);
   rmSetObjectDefMaxDistance(farGoldID, 100.0);
   rmAddObjectDefConstraint(farGoldID, avoidGold);
   rmAddObjectDefConstraint(farGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(farGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(farGoldID, farStartingSettleConstraint);

   // portals avoid everything
   int titanID=rmCreateObjectDef("titan");
   int shadesID=rmCreateObjectDef("shade");
   rmAddObjectDefItem(titanID, "skeleton", 10, 15.0);   
   rmAddObjectDefItem(shadesID, "shade", 1, 5.0);

   int portalID=rmCreateObjectDef("portal");
   rmAddObjectDefItem(portalID, "Sky Passage", 1, 0.0);
   rmSetObjectDefMinDistance(portalID, 0.0);
   rmSetObjectDefMaxDistance(portalID, 50.0);
   rmAddObjectDefConstraint(portalID, avoidGold);
   rmAddObjectDefConstraint(portalID, avoidPortal);
   rmAddObjectDefConstraint(portalID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(portalID, shortAvoidSettlement);

   int bonusGoldID=rmCreateObjectDef("bonus gold");
   rmAddObjectDefItem(bonusGoldID, "Gold mine", 1, 0.0);
   rmSetObjectDefMinDistance(bonusGoldID, 0.0);
   rmSetObjectDefMaxDistance(bonusGoldID, 150.0);
   rmAddObjectDefConstraint(bonusGoldID, farAvoidGold);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(bonusGoldID, shortAvoidSettlement);
   rmAddObjectDefConstraint(bonusGoldID, farStartingSettleConstraint);

   // pigs aboid pigs
   int farPigsID=rmCreateObjectDef("far pigs");
   rmAddObjectDefItem(farPigsID, "pig", 2, 4.0);
   rmSetObjectDefMinDistance(farPigsID, 80.0);
   rmSetObjectDefMaxDistance(farPigsID, 150.0);
   rmAddObjectDefConstraint(farPigsID, avoidHerdable);
   rmAddObjectDefConstraint(farPigsID, shortAvoidImpassableLand);


   
   // pick lions or bears as predators
   // avoid TCs
   int farPredatorID=rmCreateObjectDef("far predator");
   float predatorSpecies=rmRandFloat(0, 1);
   if(predatorSpecies<0.5)   
      rmAddObjectDefItem(farPredatorID, "Boar", 4, 4.0);
   else
      rmAddObjectDefItem(farPredatorID, "Boar", 6, 4.0);
   rmSetObjectDefMinDistance(farPredatorID, 20.0);
   rmSetObjectDefMaxDistance(farPredatorID, 30.0);
   rmAddObjectDefConstraint(farPredatorID, avoidPredator);
   rmAddObjectDefConstraint(farPredatorID, shortAvoidImpassableLand);
   
   // This map will either use water buffalo or deer as the extra huntable food.


   // hunted avoids hunted and TCs
   int bonusHuntableID=rmCreateObjectDef("bonus huntable");
   float bonusChance=rmRandFloat(0, 1);
   if(bonusChance<0.5)   
      rmAddObjectDefItem(bonusHuntableID, "Boar", 5, 4.0);
   else
      rmAddObjectDefItem(bonusHuntableID, "Boar", 5, 8.0);
   rmSetObjectDefMinDistance(bonusHuntableID, 0.0);
   rmSetObjectDefMaxDistance(bonusHuntableID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(bonusHuntableID, avoidHuntable);
   rmAddObjectDefToClass(bonusHuntableID, classBonusHuntable);
   rmAddObjectDefConstraint(bonusHuntableID, farStartingSettleConstraint);
   rmAddObjectDefConstraint(bonusHuntableID, shortAvoidImpassableLand);

   int randomTreeID=rmCreateObjectDef("random tree");
   rmAddObjectDefItem(randomTreeID, "ded pine", 1, 0.0);
   rmSetObjectDefMinDistance(randomTreeID, 0.0);
   rmSetObjectDefMaxDistance(randomTreeID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
   rmAddObjectDefConstraint(randomTreeID, shortAvoidImpassableLand);
    
 
   
   // Relics avoid TCs
   int relicID=rmCreateObjectDef("relic");
   rmAddObjectDefItem(relicID, "relic", 1, 0.0);
   rmSetObjectDefMinDistance(relicID, 40.0);
   rmSetObjectDefMaxDistance(relicID, 150.0);
   rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
   rmAddObjectDefConstraint(relicID, shortAvoidImpassableLand);
   rmAddObjectDefConstraint(relicID, farStartingSettleConstraint);



   // --------------------------------------------------------------------------------Done defining objects

  rmPlacePlayer(cNumberNonGaiaPlayers, 0.0, 0.0);


  // Text
   rmSetStatusText("",0.20);

   if(realNumberNonGaiaPlayers < 4)
      rmPlacePlayersCircular(0.40, 0.45, rmDegreesToRadians(5.0));
   else if(realNumberNonGaiaPlayers < 9)
      rmPlacePlayersCircular(0.40, 0.45, rmDegreesToRadians(5.0));
   else
      rmPlacePlayersCircular(0.40, 0.45, rmDegreesToRadians(5.0));

    // Set up player areas.
   float playerFraction=rmAreaTilesToFraction(4500);
   if(realNumberNonGaiaPlayers < 4)
      playerFraction=rmAreaTilesToFraction(4200);
   float randomIslandChance=rmRandFloat(0, 1);
   for(i=1; <realNumberPlayers)
   {
      // Create the area.
      int id=rmCreateArea("Player"+i);

      // Assign to the player.
      rmSetPlayerArea(i, id);

      // Set the size.
      rmSetAreaSize(id, 0.9*playerFraction, 1.1*playerFraction);

      rmAddAreaToClass(id, classPlayer);
      rmAddAreaToClass(id, classIsland);

      rmSetAreaMinBlobs(id, 1);
      rmSetAreaMaxBlobs(id, 3);
      rmSetAreaMinBlobDistance(id, 10.0);
      rmSetAreaMaxBlobDistance(id, 15.0);
  /*    rmSetAreaCoherence(id, 0.0); */

      rmSetAreaBaseHeight(id, 12.0);

      rmSetAreaSmoothDistance(id, 10);
      rmSetAreaHeightBlend(id, 2);

      // Add constraints.
      rmAddAreaConstraint(id, cornerOverlapConstraint);
      rmAddAreaConstraint(id, playerEdgeConstraint);

      // Set the location.
      rmSetAreaLocPlayer(id, i);

      // Set type.
      rmSetAreaTerrainType(id, "Hadesbuildable1");

      //island avoidance determination
      rmAddAreaConstraint(id, islandConstraint); 
   }



   rmBuildAllAreas();
   
   // Place stuff.

   // TC
   rmPlaceObjectDefPerPlayer(startingSettlementID, true);

   
   rmBuildAllAreas();
   
   // Towers.
   rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);

   // Straggler trees.
   rmPlaceObjectDefPerPlayer(stragglerTreeID, false, 3);

   
   // Gold
   rmPlaceObjectDefPerPlayer(startingGoldID, false);

    // Pigs
   rmPlaceObjectDefPerPlayer(closePigsID, true);

   rmPlaceObjectDefPerPlayer(closeChickensID, true);


   // water buffalo.
   rmPlaceObjectDefPerPlayer(closeWaterBuffaloID, false);

   // Build up some bonus islands.




    int bonusIslandID=rmCreateArea("bonus island"+0);
rmSetAreaLocation(bonusIslandID, 0.5, 0.5);

    rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(4500), rmAreaTilesToFraction(6000));
    rmSetAreaTerrainType(bonusIslandID, "Hadesbuildable1"); 
    rmSetAreaWarnFailure(bonusIslandID, false);
    rmAddAreaConstraint(bonusIslandID, islandConstraint); 
    rmAddAreaConstraint(bonusIslandID, farEdgeConstraint); 
    rmAddAreaToClass(bonusIslandID, classIsland);
    rmAddAreaToClass(bonusIslandID, classBonusIsland);
    rmSetAreaCoherence(bonusIslandID, 0.25);
    rmSetAreaSmoothDistance(bonusIslandID, 12);
    rmSetAreaHeightBlend(bonusIslandID, 2);
    rmSetAreaBaseHeight(bonusIslandID, 12.0);

   rmBuildAllAreas();


    rmPlaceObjectDefInArea(portalID, 0,  rmAreaID("bonus island"+0), realNumberNonGaiaPlayers );
    rmPlaceObjectDefInArea(bonusGoldID, 0,  rmAreaID("bonus island"+0), realNumberNonGaiaPlayers * 2 );
    rmPlaceObjectDefInArea(titanID, 0,  rmAreaID("bonus island"+0), 20 );
    rmPlaceObjectDefInArea(shadesID, 0,  rmAreaID("bonus island"+0), 1 );

    for(i=1; <realNumberPlayers)
   {
      rmPlaceObjectDefInArea(portalID, 0,  rmAreaID("Player"+i), 1 );

    }

    rmPlaceObjectDefInArea(portalID, 0,  rmAreaID("bonus island"+0), realNumberNonGaiaPlayers * 2 );

    for(i=1; <realNumberPlayers)
   {
      rmPlaceObjectDefInArea(portalID, 0,  rmAreaID("Player"+i), 2 );

    }

   
   
   
   // portals
   //rmPlaceObjectDefPerPlayer(portalID, false, 2);


   int bonusCount=realNumberNonGaiaPlayers * 3 + 5;  // num players plus some extra

   for(i=1; <bonusCount+1)
   {
      bonusIslandID=rmCreateArea("bonus island"+i);
      rmSetAreaSize(bonusIslandID, rmAreaTilesToFraction(4000), rmAreaTilesToFraction(5000));
      rmSetAreaTerrainType(bonusIslandID, "Hadesbuildable1"); 
      rmSetAreaWarnFailure(bonusIslandID, false);
/*      rmAddAreaConstraint(bonusIslandID, playerEdgeConstraint); */
      rmAddAreaConstraint(bonusIslandID, islandConstraint); 
      rmAddAreaToClass(bonusIslandID, classIsland);
      rmAddAreaToClass(bonusIslandID, classBonusIsland);

      rmSetAreaCoherence(bonusIslandID, 0.25);

      rmSetAreaSmoothDistance(bonusIslandID, 12);
      rmSetAreaHeightBlend(bonusIslandID, 2);

      rmSetAreaBaseHeight(bonusIslandID, 12.0);


   }

   rmBuildAllAreas();

   for(i=1; <realNumberPlayers*10)
   {
      // Beautification sub area.
      int id3=rmCreateArea("Grass patch"+i);
      rmSetAreaSize(id3, rmAreaTilesToFraction(10), rmAreaTilesToFraction(50));
      rmSetAreaTerrainType(id3, "Hadesbuildable2");
      rmSetAreaMinBlobs(id3, 1);
      rmSetAreaMaxBlobs(id3, 5);
      rmSetAreaWarnFailure(id3, false);
      rmSetAreaMinBlobDistance(id3, 16.0);
      rmSetAreaMaxBlobDistance(id3, 40.0);
      rmSetAreaCoherence(id3, 0.0);
      rmAddAreaConstraint(id3, shortAvoidImpassableLand); 
      rmBuildArea(id3);
   }


   // Settlements.

   for(i=1; <realNumberPlayers)
   {
      rmPlaceObjectDefInArea(farSettlementID, 0, rmAreaID("player"+i), 1);
      rmPlaceObjectDefInArea(bonusSettlementID, 0, rmAreaID("bonus island"+i), 1);
      rmPlaceObjectDefInArea(bonusSettlementID, 0, rmAreaID("bonus island"+(i + 2 * realNumberPlayers)), 1);
      rmPlaceObjectDefInArea(bonusSettlementID, 0, rmAreaID("bonus island"+0), 1);
   }

  // Text
   rmSetStatusText("",0.40);



   

   // Portals

   for (i=1; < realNumberNonGaiaPlayers * 5 + 10) {
      rmPlaceObjectDefInArea(portalID, 0,  rmAreaID("bonus island"+i), 4);
   }

   for (i=1; < realNumberNonGaiaPlayers * 2)
      rmPlaceObjectDefInRandomAreaOfClass(portalID, 0, classBonusIsland);
   

   // Medium things....
   // Gold
   rmPlaceObjectDefPerPlayer(mediumGoldID, false);

  
   for(i=1; <realNumberPlayers)
      rmPlaceObjectDefAtLoc(mediumPigsID, 0, rmPlayerLocXFraction(i), rmPlayerLocZFraction(i), 2);
      
   // Far things.
   
   // Gold, 2 in player lands, 1 on bonus islands
   for(i=1; <realNumberPlayers * 3)
		rmPlaceObjectDefInRandomAreaOfClass(farGoldID, 0, classBonusIsland);


//      rmPlaceObjectDefInArea(farGoldID, 0, rmAreaID("player"+i), 2);

   for(i=1; <realNumberPlayers * 3)
   rmPlaceObjectDefInRandomAreaOfClass(bonusGoldID, 0, classBonusIsland);


   // Relics
   for(i=1; <realNumberPlayers)
      rmPlaceObjectDefInArea(relicID, 0, rmAreaID("player"+i));

   for (i=1; < realNumberNonGaiaPlayers * 2) {
      rmPlaceObjectDefInRandomAreaOfClass(relicID, 0, classBonusIsland);
   }


   // Pigs
   for(i=1; <realNumberPlayers)
      rmPlaceObjectDefInArea(farPigsID, 0, rmAreaID("player"+i));

   // Bonus huntable.
   for(i=1; <realNumberPlayers)
      rmPlaceObjectDefInArea(bonusHuntableID, 0, rmAreaID("player"+i));

   for(i=1; <realNumberPlayers * 5)
      rmPlaceObjectDefInRandomAreaOfClass(bonusHuntableID, 0, classBonusIsland);

   // Predators
   //for(i=1; <realNumberPlayers)
      //rmPlaceObjectDefInArea(farPredatorID, 0, rmAreaID("player"+i));

rmPlaceObjectDefPerPlayer(farPredatorID, false);

   // Random trees.
   rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*realNumberNonGaiaPlayers);

   for(i=1; <realNumberPlayers * 20)
       rmPlaceObjectDefInRandomAreaOfClass(randomTreeID, 0, classBonusIsland);



  // Text
   rmSetStatusText("",0.60);

   int avoidBuildings=rmCreateTypeDistanceConstraint("avoid buildings", "Building", 5.0);
   int classForest=rmDefineClass("forest");
   int forestObjConstraint=rmCreateTypeDistanceConstraint("forest obj", "all", 6.0);
   int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 25.0);
   int forestSettleConstraint=rmCreateClassDistanceConstraint("forest settle", rmClassID("starting settlement"), 15.0);
   int forestTerrain=rmCreateTerrainDistanceConstraint("forest terrain", "Land", false, 3.0);

   // Player forests
   int failCount = 0;
   for(i=1; <realNumberPlayers)
   {
      failCount=0;
      int forestCount=rmRandInt(5, 8);
      for(j=0; <forestCount)
      {
         int forestID=rmCreateArea("player"+i+"forest"+j, rmAreaID("player"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "hades forest");
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

	


  // Text
   rmSetStatusText("",0.80);

   // Random island forests.
   int forestConstraint2=rmCreateClassDistanceConstraint("forest v forest2", rmClassID("forest"), 10.0);
   for(i=0; <bonusCount)
   {
      forestCount=rmRandInt(2, 3);
      for(j=0; <forestCount)
      {
         forestID=rmCreateArea("bonus"+i+"forest"+j, rmAreaID("bonus island"+i));
         rmSetAreaSize(forestID, rmAreaTilesToFraction(25), rmAreaTilesToFraction(100));
         rmSetAreaWarnFailure(forestID, false);
         rmSetAreaForestType(forestID, "hades forest");
         rmAddAreaConstraint(forestID, forestSettleConstraint);
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

         rmBuildArea(forestID);
      }
   }

    // Grass
   int avoidAll=rmCreateTypeDistanceConstraint("avoid all", "all", 5.0);
   int avoidGrass=rmCreateTypeDistanceConstraint("avoid grass", "galactic mist", 12.0);
   int grassID=rmCreateObjectDef("grass");
   rmAddObjectDefItem(grassID, "underworld smoke", 1, 1.0);
   rmSetObjectDefMinDistance(grassID, 0.0);
   rmSetObjectDefMaxDistance(grassID, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(grassID, avoidGrass);
   rmAddObjectDefConstraint(grassID, avoidImpassableLand);
   rmPlaceObjectDefAtLoc(grassID, 0, 0.5, 0.5, 40*realNumberNonGaiaPlayers);
   
   int farHarpyID=rmCreateObjectDef("far birds");
   rmAddObjectDefItem(farHarpyID, "harpy", 1, 0.0);
   rmSetObjectDefMinDistance(farHarpyID, 0.0);
   rmSetObjectDefMaxDistance(farHarpyID, rmXFractionToMeters(0.5));
   rmPlaceObjectDefPerPlayer(farHarpyID, false, 2); 


   int avoidRuins=rmCreateTypeDistanceConstraint("avoid ruins", "columns broken", 8.0);
   int ruinsID2=rmCreateObjectDef("ruins  group");
   rmAddObjectDefItem(ruinsID2, "ruins", rmRandInt(1,4), 6.0);
   rmAddObjectDefItem(ruinsID2, "columns broken", rmRandInt(1,2), 4.0);
   rmAddObjectDefItem(ruinsID2, "rock limestone sprite", rmRandInt(6,12), 10.0);
   rmSetObjectDefMinDistance(ruinsID2, 0.0);
   rmSetObjectDefMaxDistance(ruinsID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(ruinsID2, avoidAll);
   rmAddObjectDefConstraint(ruinsID2, avoidImpassableLand);
   rmAddObjectDefConstraint(ruinsID2, avoidRuins);
   //rmPlaceObjectDefAtLoc(ruinsID2, 0, 0.5, 0.5, 5*realNumberNonGaiaPlayers);
   rmPlaceObjectDefAtLoc(ruinsID2, 0, 0.5, 0.5, 10*realNumberNonGaiaPlayers); 


   int stagID2=rmCreateObjectDef("stag group");
   rmAddObjectDefItem(stagID2, "Stalagmite", 1, 2.0);
   rmSetObjectDefMinDistance(stagID2, 0.0);
   rmSetObjectDefMaxDistance(stagID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(stagID2, avoidAll);
   rmAddObjectDefConstraint(stagID2, avoidImpassableLand);
   rmAddObjectDefConstraint(stagID2, avoidRuins);
   rmAddObjectDefConstraint(stagID2, mediumAvoidSettlement);
   rmPlaceObjectDefAtLoc(stagID2, 0, 0.5, 0.5, 20*realNumberNonGaiaPlayers); 

   int avoidShades=rmCreateTypeDistanceConstraint("avoid shades", "Shade of Erebus", 12.0);
   int shadeID2=rmCreateObjectDef("shade group");
   rmAddObjectDefItem(shadeID2, "Shade of Erebus", 1, 2.0);
   rmSetObjectDefMinDistance(shadeID2, 0.0);
   rmSetObjectDefMaxDistance(shadeID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(shadeID2, avoidAll);
   rmAddObjectDefConstraint(shadeID2, avoidImpassableLand);
   rmAddObjectDefConstraint(shadeID2, avoidRuins);
   rmAddObjectDefConstraint(shadeID2, avoidShades);
   rmAddObjectDefConstraint(shadeID2, mediumAvoidSettlement);
   for(i=1; <realNumberPlayers * 2) {
       rmPlaceObjectDefInRandomAreaOfClass(shadeID2, 0, classBonusIsland);
	rmPlaceObjectDefInArea(shadeID2, 0,  rmAreaID("bonus island"+0), 1);
   }

   int avoidSnakes=rmCreateTypeDistanceConstraint("avoid snakes", "Serpent", 12.0);
   int snakeID2=rmCreateObjectDef("snake group");
   rmAddObjectDefItem(snakeID2, "Serpent", 2, 2.0);
   rmSetObjectDefMinDistance(snakeID2, 0.0);
   rmSetObjectDefMaxDistance(snakeID2, rmXFractionToMeters(0.5));
   rmAddObjectDefConstraint(snakeID2, avoidAll);
   rmAddObjectDefConstraint(snakeID2, avoidImpassableLand);
   rmAddObjectDefConstraint(snakeID2, avoidRuins);
   rmAddObjectDefConstraint(snakeID2, avoidSnakes);
   rmAddObjectDefConstraint(snakeID2, mediumAvoidSettlement);
   for(i=1; <realNumberPlayers * 2)
       rmPlaceObjectDefInRandomAreaOfClass(snakeID2, 0, classBonusIsland);


 int fireID=rmCreateObjectDef("fire group");
   rmAddObjectDefItem(fireID, "Hades Fire", 1, 0.0);
   rmSetObjectDefMinDistance(fireID, 0.0);
   rmSetObjectDefMaxDistance(fireID, rmXFractionToMeters(0.5));
 rmAddObjectDefConstraint(fireID, fireConstraint);
   rmPlaceObjectDefAtLoc(fireID, 0, 0.5, 0.5, 200*realNumberNonGaiaPlayers); 

// RM X Finalize.
	rmxFinalize();

  // Text
   rmSetStatusText("",1.0);

}  





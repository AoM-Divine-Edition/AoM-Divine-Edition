//==============================================================================
// AoMXai.xs
//
//This is the default AOM XPack AI script code for Computer Player AI players.
// Do not use it directly, use an AoMXloader*.xs file to load it.
//==============================================================================


//==============================================================================
//The first part of this file is just a long list of global variables.  The
//'extern' keyword allows them to be used in any of the included files.  These
//are here to facilitate information sharing, etc.  The global variables are
//attempted to be named appropriately, but you should take a look at how they are
//used before making any assumptions about their actual utility.


//==============================================================================
//Map-Related Globals.
extern bool gWaterMap=false;			  // Set true if fishing is likely to be good.
extern bool gTransportMap=false;		  // Set true if transports are needed or very useful, i.e. island and shallow-chokepoint maps.

//==============================================================================
//Escrow stuff.
extern int gEconomyUnitEscrowID=-1; // Identifies which escrow account is used to pay for economic units 
extern int gEconomyTechEscrowID=-1; // Identifies which escrow account is used for economic research
extern int gEconomyBuildingEscrowID=-1;   // Ditto buildings
extern int gMilitaryUnitEscrowID=-1;		 // etc.
extern int gMilitaryTechEscrowID=-1;
extern int gMilitaryBuildingEscrowID=-1;

//==============================================================================
//Housing & PopCap.
extern int gHouseBuildLimit=-1;
extern int gHouseAvailablePopRebuild=10;	 // Build a house when pop is within this amount of the current pop limit
extern int gBuildersPerHouse=1;
extern int gHardEconomyPopCap=-1;   // Sets an absolute upper limit on the number of villagers maintained in the updateEM rules
extern int gEarlySettlementTarget = 1;   // How many age 1/2 settlements do we want?

//==============================================================================
//Econ Globals.
extern int   gGatherGoalPlanID=-1;
extern int   gCivPopPlanID=-1;
extern int   gNumBoatsToMaintain=6; // Target number of fishing boats
extern int   gAgeToStartFarming=2;  // Obsolete
extern bool  gAgeCapHouses=false;
extern float gMaxFoodImbalance=1500.0;  // Obsolete
extern float gMaxWoodImbalance=1500.0;  // Obsolete
extern float gMaxGoldImbalance=1500.0;  // Obsolete
extern float gMinWoodMarketSellCost=20.0; // Obsolete
extern float gMinFoodMarketSellCost=20.0; // Obsolete
extern bool  gFarming=false;			  // Set true when a farming plan is created, used to forecast farm resource needs.
extern bool  gFishing=false;			  // Set true when a fishing plan is created, used to forecast fish boat wood demand
extern float gGoldForecast = 0.0;   // Forecasted demand over the next few minutes
extern float gWoodForecast = 0.0;
extern float gFoodForecast = 0.0;
extern int   gStartTime = 0;			  // Time game started in milliseconds...reset if cvDelayStart is used
extern int   gHerdPlanID = -1;  // Herds animals to base
extern float gGlutRatio = 0.0;  // 1.0 indicates all resources at 3 min forecast.  2.0 means all at least double.  Used to trim econ pop.
extern int   gLastAgeHandled = cAge1;   // Set to cAge2..cAge5 as the age handlers run. Used to detect age-ups granted via triggers and starting conditions, 
										  // ensures age handlers get run properly.
extern int   gGardenBuildLimit = 0;

// Trade globals
extern int   gMaxTradeCarts=20;  // Max trade carts in 4th age on an excellent route.  Half that in third age.  Less if route isn't good.
extern int   gTradePlanID=-1;
extern int   gTradeMaintainPlanID=-1;   // Makes the trade carts
extern bool  gExtraMarket=false;		  // Used to indicate if an extra (non-trade) market has been requested, i.e. for DM speed reasons
extern int   gTradeMarketUnitID=-1; // Used to identify the market being used in our trade plan.
extern vector gTradeMarketLocation=cInvalidVector; // Tracks requested trade market location, used to decide which market is the trade market.


//==============================================================================
//Military Globals.
extern bool gBuildWalls = false;
extern int  gWallPlanID = -1;
extern bool gBuildTowers = false;
extern int gTowerEscrowID=cMilitaryEscrowID;
extern int gRushUPID=-1;			// Unit picker ID for age 2 (cAge2) armies.
extern int gLateUPID=-1;			// Unit picker for age 3/4 (cAge3 and cAge4).
extern int gNavalUPID=-1;
extern int gNumberBuildings=3;  // Number of buildings requested for late unit picker
extern int gNavalAttackGoalID=-1;
extern int gRushGoalID=-1;
extern int gLandAttackGoalID=-1;
extern int gIdleAttackGID=-1;   // Attack goal, inactive, used to maintain mil pop after rush and/or before age 3 (cAge3) attack.
extern int gSiegeUnitReserveSize = 2;  // Number of siege units to keep on hand in cAge3, doubled in cAge4
extern int gSiegeUnitType = -1;
extern int gSiegeReservePlanID = -1;
extern int gDefendPlanID = -1;  // Uses military units to defend main base while waiting to mass an attack army
extern int gWonderDefendPlan = -1;   // Uber-plan to defend my wonder
extern int gEnemyWonderDefendPlan = -1;   // Uber-uber-plan to attack or defend other wonder
extern int gObeliskClearingPlanID = -1;   // Small attack plan used to remove enemy obelisks
extern int gMostRecentAttackPlanID = -1;	  // Used by attackMonitor rule
extern int gTargetNavySize = 0;  // Set periodically based on difficulty, enemy navy/fish boat count. Units, not pop slots.

//==============================================================================
//Minor Gods.
extern int gAge2MinorGod = -1;
extern int gAge3MinorGod = -1;
extern int gAge4MinorGod = -1;


//==============================================================================
//God Powers
extern int gAge1GodPowerID = -1;
extern int gAge2GodPowerID = -1;
extern int gAge3GodPowerID = -1;
extern int gAge4GodPowerID = -1;
extern int gAge5GodPowerID = -1;
extern int gAge1GodPowerPlanID = -1;
extern int gAge2GodPowerPlanID = -1;
extern int gAge3GodPowerPlanID = -1;
extern int gAge4GodPowerPlanID = -1;
extern int gAge5GodPowerPlanID = -1;
extern int gTownDefenseGodPowerPlanID = -1;
extern int gTownDefenseEvalModel = -1;
extern int gTownDefensePlayerID = -1;
extern int gUnbuildPlanID = -1;
extern int gPlaceTitanGatePlanID = -1;

//==============================================================================
//Special Case Stuff
extern int gDwarvenMinePlanID = -1;
extern int gLandScout = -1;
extern int gAirScout = -1;
extern int gWaterScout = -1;
extern int gMaintainNumberLandScouts = 1;
extern int gMaintainNumberAirScouts = 1;
extern int gMaintainNumberWaterScouts = 1;
extern int gEmpowerPlanID = -1;
extern int gRelicGatherPlanID = -1;
extern int gMaintainWaterXPortPlanID=-1;
extern int gResignType = -1;
extern int gVinlandsagaTransportExplorePlanID=-1;
extern int gVinlandsagaInitialBaseID=-1;
extern int gNomadExplorePlanID1=-1;
extern int gNomadExplorePlanID2=-1;
extern int gNomadExplorePlanID3=-1;
extern int gNomadSettlementBuildPlanID=-1;
extern int gKOTHPlentyUnitID=-1;
extern int gDwarfMaintainPlanID=-1;
extern int gLandExplorePlanID=-1;
extern int gFarmBaseID = -1;
extern int gTargetNumTowers = 0;	// Set to a positive int if towering is activated
extern int gUlfsarkMaintainPlanID = -1;   // Used to maintain a small pop of ulfsarks for building
extern int gUlfsarkMaintainMilPlanID = -1;   // Shadow plan, used in case main plan is econ pop-capped
//==============================================================================
// tracking expansion
extern int gTrackingPlayer = -1;
extern int gNumberTrackedPlayerSettlements=-1;
extern int gNumberMySettlements=-1;

//==============================================================================
//Base Globals.
extern int gGoldBaseID=-1;  // Base used for gathering gold, although main base is used if gold exists there
extern int gWoodBaseID=-1;  // Ditto for wood
extern float gMaximumBaseResourceDistance=85.0;

//==============================================================================
//Age Progression Plan IDs.
extern int gAge2ProgressionPlanID = -1;
extern int gAge3ProgressionPlanID = -1;
extern int gAge4ProgressionPlanID = -1;

//==============================================================================
//Forward declarations.
//==============================================================================
mutable void setOverrides(void) {}  // Used in loader file to override init parameters, called at end of main()
mutable void setParameters(void) {} // Used in loader file to set control parameters, called at start of main()
mutable void setMilitaryUnitPrefs(int primaryType = -1, int secondaryType = -1, int tertiaryType = -1) {}   // Used by loader to override unitPicker choices
mutable void age2Handler(int age=1) { }
mutable void age3Handler(int age=2) { }
mutable void age4Handler(int age=3) { }
mutable void towerInBase( string planName="BUG", bool los = true, int numTowers = 6, int escrowID=-1 ) { }
mutable int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1) { }
mutable bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
   bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1) { }
mutable void buildHandler(int protoID=-1) { }
mutable void gpHandler(int powerID=-1)  { }
mutable void wonderDeathHandler(int playerID=-1) { }
mutable void retreatHandler(int planID=-1) {}
mutable void relicHandler(int relicID=-1) {}
mutable int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1, bool autoUpdate=true, int pri=90) { }
mutable int getEconPop(void) {}
mutable int getMilPop(void) {}
mutable int getSoftPopCap(void) {}
mutable void unbuildHandler() { }
mutable void age5Handler(int age=4) { }
mutable int getOwnUnit(int unitType = -1, int action = -1, vector center = vector(-1, -1, -1), int radius = -1, int state = -1) { }

//==============================================================================
// Some new incudes that have to be used everywhere
// Plan extension functions
include "Plan Variable.xs";
// Player data
include "Player.xs";
// Difficulty data
include "Difficulty.xs";
// Game mode data
include "Game Mode.xs";

//==============================================================================
//Economy Include.
//-- The Econ module needs to define these things:
// void econAge2Handler( int age = 0 )
// void econAge3Handler( int age = 0 )
// void econAge4Handler( int age = 0 )
// void initEcon()
include "AoMXaiEcon.xs";

//==============================================================================
//Progress Include.
//-- The Progress module needs to define these things:
// void progressAge2Handler( int age = 0 )
// void progressAge3Handler( int age = 0 )
// void progressAge4Handler( int age = 0 )
// void initProgress()
include "AoMXaiProg.xs";

//==============================================================================
//Military Include.
include "AoMXaiMil.xs";

//==============================================================================
//God Powers Include.
//-- The GP module needs to define these things:
// void gpAge2Handler( int age = 0 )
// void gpAge3Handler( int age = 0 )
// void gpAge4Handler( int age = 0 )
// void initGodPowers()
include "AoMXaiGP.xs";




rule updatePlayerToAttack
   minInterval 27
   active
   runImmediately
{
	// Here is where the magic happens
	int comparePlayerID = pickPlayerToAttack();
	// Now let the AI handle special events like wonders etc.
	int actualPlayerID = -1;
	// If we have not defined a special player to attack
	if(cvPlayerToAttack == -1)
	{
		actualPlayerID = aiCalculateMostHatedPlayerID(comparePlayerID);
	}
	else
	{
		actualPlayerID = cvPlayerToAttack;
	}
	
	SetTarget(comparePlayerID);
}

rule checkEscrow	 // Verify that escrow totals and real inventory are in sync
   minInterval 6
   active
{
   static int failCount = 0;
   static bool initialResetDone = false;

   if (initialResetDone == false)
   {
	  initialResetDone = true;
	  kbEscrowAllocateCurrentResources();
	  return;
   }

   bool fishingReset = false;   // Special reset in first 5 minutes for wood imbalance while fishing
								 // (Every fishing boat trained gets double-billed.)
   bool needReset = false;
   int res = -1;
   for (res=0; <3)
   {
	  int escrowQty = -1;
	  int actualQty = -1;
	  int delta = -1;
	  escrowQty = kbEscrowGetAmount(cEconomyEscrowID, res);
	  escrowQty = escrowQty + kbEscrowGetAmount(cMilitaryEscrowID, res);
	  escrowQty = escrowQty + kbEscrowGetAmount(cRootEscrowID, res);
	  actualQty = kbResourceGet(res);
	  delta = actualQty - escrowQty;
	  if (delta < 0)
		 delta = delta * -1;
	  if ( (delta > 20) && (delta > actualQty/5) ) // Off by at least 20, and 20%
	  {
		 needReset = true;
		 if (res == cResourceGold)
			aiEcho("Gold imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
		 if (res == cResourceWood)
		 {
			aiEcho("Wood imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
			if ( (gFishing == true) && (xsGetTime()<(8*60*1000)) )
			   fishingReset = true; // We're fishing, it's in the first 8 min, and wood is off.
		 }
		 if (res == cResourceFood)
			aiEcho("Food imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
		 if (res == cResourceFavor)
			aiEcho("Favor imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
	  }
   }
   
   if (fishingReset == true)
   {
	  kbEscrowAllocateCurrentResources();
	  return;
   }
   if (needReset == true)
   {
	  failCount = failCount+1;
	  if ( (failCount > 5) || ( (failCount>0)&&(xsGetTime()<30000) ) )
	  {
		 aiEcho("ERROR:  Escrow balances invalid.  Reallocating");
		 kbEscrowAllocateCurrentResources();
	  }
   }
   else
	  failCount = 0;
}


//==============================================================================
// setTownLocation
//==============================================================================
void setTownLocation(void)
{
   static int tcQueryID=-1;
   //If we don't have a query ID, create it.
   if (tcQueryID < 0)
   {
	  tcQueryID=kbUnitQueryCreate("TownLocationQuery");
	  //If we still don't have one, bail.
	  if (tcQueryID < 0)
		 return;
	  //Else, setup the query data.
	  kbUnitQuerySetPlayerID(tcQueryID, cMyID);
	  kbUnitQuerySetUnitType(tcQueryID, cUnitTypeAbstractSettlement);
	  kbUnitQuerySetState(tcQueryID, cUnitStateAlive);
   }

   //Reset the results.
   kbUnitQueryResetResults(tcQueryID);
   //Run the query.  Be dumb and just take the first TC for now.
   if (kbUnitQueryExecute(tcQueryID) > 0)
   {
	  int tcID=kbUnitQueryGetResult(tcQueryID, 0);
	  kbSetTownLocation(kbUnitGetPosition(tcID));
   }
}

//==============================================================================
//createSimpleMaintainPlan
//==============================================================================
int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1)
{
   //Create a the plan name.
   string planName="Military";
   if (economy == true)
	  planName="Economy";
   planName=planName+kbGetProtoUnitName(puid)+"Maintain";
   int planID=aiPlanCreate(planName, cPlanTrain);
   if (planID < 0)
	  return(-1);

   //Economy or Military.
   if (economy == true)
	  aiPlanSetEconomy(planID, true);
   else
	  aiPlanSetMilitary(planID, true);
   //Unit type.
   aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
   //Number.
   aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, number);

   //If we have a base ID, use it.
   if (baseID >= 0)
   {
	  aiPlanSetBaseID(planID, baseID);
	  if  (economy == false)
		 aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
   }

   aiPlanSetActive(planID);

   //Done.
   return(planID);
}

//==============================================================================
//createSimpleBuildPlan
//==============================================================================
bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
   bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1)
{
   //Create the right number of plans.
   for (i=0; < number)
   {
	   int planID=aiPlanCreate("SimpleBuild"+kbGetUnitTypeName(puid)+" "+number, cPlanBuild);
	  if (planID < 0)
		 return(false);
	  //Puid.
	  aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, puid);
	  //Border layers.
	   aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 2, kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, baseID)) );
	  //Priority.
	  aiPlanSetDesiredPriority(planID, pri);
	  //Mil vs. Econ.
	  aiPlanSetMilitary(planID, military);
	  aiPlanSetEconomy(planID, economy);
	  //Escrow.
	  aiPlanSetEscrowID(planID, escrowID);
	  //Builders.
	   aiPlanAddUnitType(planID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0),
		 numberBuilders, numberBuilders, numberBuilders);
	  //Base ID.
	  aiPlanSetBaseID(planID, baseID);

	  //Go.
	  aiPlanSetActive(planID);
   }
}

//==============================================================================
//getSoftPopLimit   Calculate our pop limit if we had all houses built
//==============================================================================
int getSoftPopCap(void)
{
   int houseProtoID = cUnitTypeHouse;
   if (cMyCulture == cCultureAtlantean)
	   houseProtoID = cUnitTypeManor;
   int houseCount = -1;

   int maxHouses = 10;
   int popPerHouse = 10;

   if (cMyCulture == cCultureAtlantean)
   {
//  if (kbGetTechStatus(cTechMilkStones) >= cTechStatusActive)
		 popPerHouse = 20;
//  else
//   popPerHouse = 15;

	  maxHouses = 5;
   }

   houseCount = kbUnitCount(cMyID, houseProtoID, cUnitStateAlive); // Do not count houses being built

   int retVal = -1;

   retVal = kbGetPopCap();

   retVal = retVal + (maxHouses-houseCount)*popPerHouse;  // Add pop for missing houses

   return(retVal);
}




//==============================================================================
// updateEM
//==============================================================================
void updateEM(int econPop=-1, int milPop=-1, float econPercentage=0.5,
   float rootEscrow=0.2, float econFoodEscrow=0.5, float econWoodEscrow=0.5,
   float econGoldEscrow=0.5, float econFavorEscrow=0.5)
{
   if (cMyCulture == cCultureNorse) // Make room for at least 3 oxcarts
   {
	  if (econPop < 25)
		 econPop = econPop + 3;
   }

   //Econ Pop (if we're allowed to change it).
   if ((gHardEconomyPopCap > 0) && (econPop > gHardEconomyPopCap))
	  econPop=gHardEconomyPopCap;
   if ( (econPop > cvMaxGathererPop)  && (cvMaxGathererPop >= 0) )
	  econPop = cvMaxGathererPop;

   // Check if we're second age.  If so, consider capping the mil lower for boomers
   if (kbGetAge() == cAge2)
   {
	  if ( (gRushGoalID == -1) ||   /* If we don't have a rush goal, or... */
		 (aiPlanGetVariableInt(gRushGoalID, cGoalPlanExecuteCount, 0) >= aiPlanGetVariableInt(gRushGoalID, cGoalPlanRepeat, 0)) 
		 )  // We have a rush goal, but we're done rushing
	  {
		 // Let's decrease our military pop
		 float milPopDelta = (cvRushBoomSlider*4.0)/5.0;	// Zero for balanced, -.80 for extreme boom
		 if (milPopDelta > 0) 
			milPopDelta = 0;  // Don't increase for rushers
		 // Adjust it for econ/mil scale.  If military, soften the decrease, if economic, preserve full.
		 milPopDelta = milPopDelta / (2.0 + cvMilitaryEconSlider);
		 milPop = milPop + (milPop * milPopDelta);
		 if (milPop < 10) 
			milPop = 10;
	  }
   }

   

   if ((milPop < 0) && (cvMaxMilPop >= 0))  // milPop says no limit, but cvMaxMilPop has one
	  milPop = cvMaxMilPop;   
   if ((milPop > cvMaxMilPop) && (cvMaxMilPop >= 0))  // cvMaxMilPop has limit and milPop is over it
	  milPop = cvMaxMilPop;


   aiSetEconomyPop(econPop);
   aiSetMilitaryPop(milPop);

   // Check to make sure attack goals have ranges below our milPop limit
   int upID = gRushUPID;
   if (kbGetAge() > cAge2)
	  upID = gLateUPID;

   int milMin = kbUnitPickGetMinimumPop(upID);
   int milMax = kbUnitPickGetMaximumPop(upID);
   if (milMax > milPop) // We have a problem
   {
	  aiEcho("***** MilPop is "+milPop+", resetting military goals.");
	  kbUnitPickSetMaximumPop(upID,(milPop*4)/5);
	  kbUnitPickSetMinimumPop(upID,(milPop*3)/5);
   }


   //Percentages.
/* Freeze at 0.5 each
   aiSetEconomyPercentage(econPercentage);
   aiSetMilitaryPercentage(1.0-econPercentage);
*/
   aiSetEconomyPercentage(1.0);
   aiSetMilitaryPercentage(1.0);

   //Get the amount of the non-root pie.
   float nonRootEscrow=1.0-rootEscrow;
   //Track whether or not we need to redistribute the resources.
   //Econ Food Escrow.
   float v=nonRootEscrow*econFoodEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceFood, v);
   //Econ Wood Escrow
   v=nonRootEscrow*econWoodEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceWood, v);
   //Econ Gold Escrow
   v=nonRootEscrow*econGoldEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceGold, v);
   //Econ Favor Escrow
   v=nonRootEscrow*econFavorEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceFavor, v);
   //Military Escrow.
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFood, nonRootEscrow*(1.0-econFoodEscrow));
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceWood, nonRootEscrow*(1.0-econWoodEscrow));
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceGold, nonRootEscrow*(1.0-econGoldEscrow));
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFavor, nonRootEscrow*(1.0-econFavorEscrow));


   int vilPop= aiGetEconomyPop();   // Total econ
   if (gFishing == true)
   {
	  int fishCount = gNumBoatsToMaintain;
	  if ( (aiGetGameMode() == cGameModeLightning) && (fishCount > 5) )
		 fishCount = 5;
	  vilPop = vilPop - fishCount; // Less fishing
   }
   if (gTradeMaintainPlanID >= 0)   // Less trade units
   {
	  int tradeCount = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
	  if ( (aiGetGameMode() == cGameModeLightning) && (tradeCount > 5) )
		 tradeCount = 5;
	  vilPop = vilPop - tradeCount;  // Vils = total-trade
   }
   if (cMyCulture == cCultureAtlantean)
	  vilPop = vilPop / 3;

   // Brutal hack to make Lightning work.
   if (aiGetGameMode() == cGameModeLightning)
   {	 // Make sure we don't try to overtrain villagers
	  int lightningLimit = 25;  // Greek/Egyptian;
	  if (cMyCulture == cCultureNorse)
		 lightningLimit = 20;
	  if (cMyCulture == cCultureAtlantean)
		 lightningLimit = 6;
	  if (vilPop > lightningLimit)
		 vilPop = lightningLimit;
   }

   //Update the number of vils to maintain.
   aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0, vilPop);
}

//==============================================================================
// updateEMAge1
//==============================================================================
rule updateEMAge1   // i.e. cAge1
   minInterval 12
   active
{
   static int civPopTarget=-1;
   static int milPopTarget=-1;
   if (civPopTarget < 0)
   {
	  if (aiGetWorldDifficulty() == cDifficultyEasy)
	  {
		 civPopTarget = 10;
		 milPopTarget = 10;
		 if (cMyCulture == cCultureAtlantean)
			civPopTarget = 12;   // Make up for oracles
	  }
	  else if (aiGetWorldDifficulty() == cDifficultyModerate)
	  {
		 civPopTarget = 15;
		 milPopTarget = 30;
	  }
	  else if (aiGetWorldDifficulty() == cDifficultyHard)
	  {
		 civPopTarget = 30;
		 milPopTarget = 60;
	  }
	  else
	  {
		 civPopTarget = 25;
		 milPopTarget = 80;
	  }
   }

   //All econ in the first age.
   updateEM(civPopTarget, milPopTarget, 1.0, 0.2, 1.0, 1.0, 1.0, 1.0);
}


float adjustSigmoid(float var=0.0, float fraction=0.0,  float lowerLimit=0.0, float upperLimit=1.0)
{  // Adjust the variable by fraction amount.  Dampen it for movement near the limits like a sigmoid curve. 
   // A fraction of +.5 means increase it by the lesser of 50% of its original value, or 50% of the space remaining.
   // A fraction of -.5 means decrease it by the lesser of 50% of its original value, or 50% of the distance from the upper limit.

   float spaceAbove = upperLimit - var;

   float adjustRaw = var * fraction;			// .8 at -.5 gives -.4  // .8 at .5 gives 1.2
   float adjustLimit = spaceAbove * fraction;   // .2 at -.5 gives -.1  // .2 at .5 gives .1
   float retVal = 0.0;
   if (fraction > 0) // increasing it
   {
	  // choose the smaller of the two
	  if (adjustRaw < adjustLimit)
		 retVal = var + adjustRaw;
	  else
		 retVal = var + adjustLimit;
   }
   else  // decreasing it
   {
	  // The "smaller" adjustment is the higher number, i.e. -.1 is a smaller adjustment than -.4
	  if (adjustRaw < adjustLimit)
		 retVal = var + adjustLimit;
	  else
		 retVal = var + adjustRaw;
   }
   return(retVal);
}

//==============================================================================
// updateEMAge2
//==============================================================================
rule updateEMAge2
   minInterval 12
   inactive
{
   int civPopTarget=-1;
   int milPopTarget=-1;

   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	  civPopTarget = 15;
	  if (cMyCulture == cCultureAtlantean)
		 civPopTarget = 12;   // Make up for oracles
	  milPopTarget = 22 + (cvRushBoomSlider*10.99);   // + 10 in extreme 'rush'
   }
   else if (aiGetWorldDifficulty() == cDifficultyModerate)
   {
	  civPopTarget = 20 - (cvRushBoomSlider*3.99); // adds variance of +/- 3, smaller in rush
	  if (aiGetGameMode() == cGameModeLightning)
		 civPopTarget = 15;
	  milPopTarget = 30 + (cvRushBoomSlider*10.99);   // +/- 10, bigger in rush, smaller in boom
   }
   else if (aiGetWorldDifficulty() == cDifficultyHard)
   {
	  civPopTarget = 65 - (cvRushBoomSlider*5.99); // +/- 5, smaller in rush
	  if (getSoftPopCap() > 115)
		 civPopTarget = civPopTarget + 0.3 * (getSoftPopCap()-115);  // Adjust if Atlantean based on TCs
	  if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		 civPopTarget = 35;   // reserve pop slots for mil use.
	  milPopTarget = getSoftPopCap() - civPopTarget;
   }
   else
   {
	  civPopTarget = 35 - (cvRushBoomSlider*5.99); // +/- 5, smaller in rush;
	  if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		 civPopTarget = 35;  
	  milPopTarget = getSoftPopCap() - civPopTarget;
   }


   float econPercent = 0.50;	 // Econ priority rating, range 0..1
   float econEscrow = 0.50;   // Economy's share of non-root escrow, range 0..1

   float econAdjust = -.5 * cvMilitaryEconSlider;  // For econ purist, do lesser of 50% econ boost or 50% mil cut
												   // For hawk, vice versa 
   econPercent = adjustSigmoid(econPercent, econAdjust, 0.0, 1.0);   // Adjust econ up or mil down by econAdjust amount, whichever is smaller
   econEscrow = econPercent;

   //More military in second age
   updateEM(civPopTarget, milPopTarget, econPercent, 0.2, econEscrow, econEscrow, econEscrow, econEscrow);
}





//==============================================================================
// updateEMAge3
//==============================================================================
rule updateEMAge3
   minInterval 12
   inactive
{
   static int civPopTarget=-1;
   static int milPopTarget=-1;
   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	  civPopTarget = 10 + aiRandInt(3);
	  if (cMyCulture == cCultureAtlantean)
		 civPopTarget = 12 + aiRandInt(3);   // Make up for oracles
	  milPopTarget = 26 + aiRandInt(8);   
   }
   else if (aiGetWorldDifficulty() == cDifficultyModerate)
   {
	  civPopTarget = 30; 
	  if (aiGetGameMode() == cGameModeLightning)
		 civPopTarget = 15;
	  milPopTarget = 40;
   }
   else if (aiGetWorldDifficulty() == cDifficultyHard)
   {
	  civPopTarget = 65 - (cvRushBoomSlider*5.99); // +/- 5, smaller in rush; 
	  if (getSoftPopCap() > 115)
		 civPopTarget = civPopTarget + 0.3 * (getSoftPopCap()-115);
	  if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		 civPopTarget = 35;
	  milPopTarget = getSoftPopCap() - civPopTarget;
	  kbUnitPickSetMinimumPop(gLateUPID, milPopTarget*.5);
	  kbUnitPickSetMaximumPop(gLateUPID, milPopTarget*.75);
   }
   else
   {
	  civPopTarget = 34 - (cvRushBoomSlider*5.99);  // +/- 5
	  if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		 civPopTarget = 35;  milPopTarget = getSoftPopCap() - civPopTarget;
	  kbUnitPickSetMinimumPop(gLateUPID, milPopTarget*.5);
	  kbUnitPickSetMaximumPop(gLateUPID, milPopTarget*.75);
   }

   float econPercent = 0.3;  // Econ priority rating, range 0..1
   float econEscrow = 0.3;  // Economy's share of non-root escrow, range 0..1

   float econAdjust = -.5 * cvMilitaryEconSlider;  // For econ purist, do lesser of 50% econ boost or 50% mil cut
												   // For hawk, vice versa 

   // Check and see if we're way below our target econ pop.  If so, boost the econ.
   float econShortage = aiGetAvailableEconomyPop();   // i.e., target minus actual
   float econTarget = aiGetEconomyPop();				 // i.e. our script-defined limit. 
   econShortage = econShortage / econTarget;	// i.e. 1.0 means we have no villagers, 0.0 means we're at target
   econAdjust = econAdjust + econShortage;  // if we're 30% low, boost it 30%
   
   if (econAdjust > 1.0)
		econAdjust = 1.0;
	if (econAdjust < -1.0)
		econAdjust = -1.0;

   econPercent = adjustSigmoid(econPercent, econAdjust, 0.0, 1.0);   // Adjust econ up or mil down by econAdjust amount, whichever is smaller
   econEscrow = econPercent;

   //More military in second age
   updateEM(civPopTarget, milPopTarget, econPercent, 0.2, econEscrow, econEscrow, econEscrow, econEscrow);
}



//==============================================================================
// updateEMAge4
//==============================================================================
rule updateEMAge4
   minInterval 12
   inactive
{
   static int civPopTarget=-1;
   static int milPopTarget=-1;


   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	  civPopTarget = 10 + aiRandInt(3);
	  if (cMyCulture == cCultureAtlantean)
		 civPopTarget = 12 + aiRandInt(3);   // Make up for oracles
	  milPopTarget = 26 + aiRandInt(8);  
   }
   else if (aiGetWorldDifficulty() == cDifficultyModerate)
   {
	  civPopTarget = 34; 
	  if (aiGetGameMode() == cGameModeLightning)
		 civPopTarget = 15;
	  milPopTarget = 50;
   }
   else if (aiGetWorldDifficulty() == cDifficultyHard)
   {
	  civPopTarget = 55;	  // 55 of first 115
	  if (gGlutRatio > 1.0)
		 civPopTarget = civPopTarget / gGlutRatio;
	  if ( (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 60*8*1000) )
		 civPopTarget = 20;   // limited for first 10 minutes while resource glut remains
	  civPopTarget = civPopTarget + 0.2 * (getSoftPopCap()-115);  // Plus 20% over 115
	  if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		 civPopTarget = 35;
	  milPopTarget = getSoftPopCap() - civPopTarget;  // Whatever's left (i.e. 60 + 80% over 115)
	  kbUnitPickSetMinimumPop(gLateUPID, milPopTarget*.5);
	  kbUnitPickSetMaximumPop(gLateUPID, milPopTarget*.75);   }
   else
   {
	  civPopTarget = 40; 
	  if (gGlutRatio > 1.0)
		 civPopTarget = civPopTarget / gGlutRatio;
	  if ( (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 60*8*1000) )
		 civPopTarget = 20;   // limited for first 10 minutes while resource glut remains
	  civPopTarget = civPopTarget + 0.2 * (getSoftPopCap()-115);  // Plus 20% over 115
	  if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )  // Can't use more than 35 in lightning,
		 civPopTarget = 35;
	  milPopTarget = getSoftPopCap() - civPopTarget;
	  kbUnitPickSetMinimumPop(gLateUPID, milPopTarget*.5);
	  kbUnitPickSetMaximumPop(gLateUPID, milPopTarget*.75);
   }

   float econPercent = 0.15;	 // Econ priority rating, range 0..1
   float econEscrow = 0.15;   // Economy's share of non-root escrow, range 0..1

   float econAdjust = -.5 * cvMilitaryEconSlider;  // For econ purist, do lesser of 50% econ boost or 50% mil cut
												   // For hawk, vice versa 


   // Check and see if we're way below our target econ pop.  If so, boost the econ.
   float econShortage = aiGetAvailableEconomyPop();   // i.e., target minus actual
   float econTarget = aiGetEconomyPop();				 // i.e. our script-defined limit. 
   econShortage = econShortage / econTarget;	// i.e. 1.0 means we have no villagers, 0.0 means we're at target
   econAdjust = econAdjust + econShortage;  // if we're 30% low, boost it 30%
   if (econAdjust > 1.0)
		econAdjust = 1.0;
	if (econAdjust < -1.0)
		econAdjust = -1.0;
		
   econPercent = adjustSigmoid(econPercent, econAdjust, 0.0, 1.0);   // Adjust econ up or mil down by econAdjust amount, whichever is smaller
   econEscrow = econPercent;

   //More military in second age
   updateEM(civPopTarget, milPopTarget, econPercent, 0.2, econEscrow, econEscrow, econEscrow, econEscrow);
}




//==============================================================================
//
// updatePrices
// 
// This rule constantly compares actual supply vs. forecast, updates AICost 
// values (internal resource prices), and buys/sells at the market as appropriate
//==============================================================================
rule updatePrices
active
minInterval 6
{
	// check for valid forecasts, exit if not ready
	if ( (gGoldForecast + gWoodForecast + gFoodForecast) < 100 )
		return; 
	float scaleFactor = 5.0;	  // Higher values make prices more volatile
	float goldStatus = 0.0;
	float woodStatus = 0.0;
	float foodStatus = 0.0;
	float minForecast = 200.0 * (1+kbGetAge()); // 200, 400, 600, 800 in ages 1-4, prevents small amount from looking large if forecast is very low
	if (gGoldForecast > minForecast)
		goldStatus = scaleFactor * kbResourceGet(cResourceGold)/gGoldForecast;
	else
		goldStatus = scaleFactor * kbResourceGet(cResourceGold)/minForecast;
	if (gFoodForecast > minForecast)
		foodStatus = scaleFactor * kbResourceGet(cResourceFood)/gFoodForecast;
	else
		foodStatus = scaleFactor * kbResourceGet(cResourceFood)/minForecast;
	if (gWoodForecast > minForecast)
		woodStatus = scaleFactor * kbResourceGet(cResourceWood)/gWoodForecast;
	else
		woodStatus = scaleFactor * kbResourceGet(cResourceWood)/minForecast;
		
	// Status now equals inventory/forecast
	// Calculate value rate of wood:gold and food:gold.  1.0 means they're of the same status, 2.0 means 
	// that the resource is one forecast more scarce, 0.5 means one forecast more plentiful, i.e. lower value.
	float woodRate = (1.0 + goldStatus)/(1.0 + woodStatus);
	float foodRate = (1.0 + goldStatus)/(1.0 + foodStatus);
	
	// The rates are now the instantaneous price for each resource.  Set the long-term prices by averaging this in
	// at a 5% weight.
	
	float cost = 0.0;

	// wood
	cost = kbGetAICostWeight(cResourceWood);
	cost = (cost * 0.95) + (woodRate * .05);
	kbSetAICostWeight(cResourceWood, cost);

	// food
	cost = kbGetAICostWeight(cResourceFood);
	cost = (cost * 0.95) + (foodRate * .05);
	kbSetAICostWeight(cResourceFood, cost);

	// Gold
	kbSetAICostWeight(cResourceGold, 1.00); // gold always 1.0, others relative to gold
	// Favor
   float favorCost = 15.0 - (14.0*(kbResourceGet(cResourceFavor)/100.0));   // 15 when empty, 2.0 when full
   if (favorCost < 1.0)
	  favorCost = 1.0;
   kbSetAICostWeight(cResourceFavor, favorCost);  
	//kbSetAICostWeight(cResourceFavor, 10.00); // Favor 10 for now 
	
	//Compare that to the market price.  Buy if
	// the market price is lower and we have at least 
	// 1/3 forecast of gold.  Sell if market price is higher and
	// we have at least 1/3 forecast of the resource.
	if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0)
	{
		if ( (goldStatus > 0.33) && (kbResourceGet(cResourceGold) > 200) )  // We have one minute's worth of gold (at scale 1.0), OK to buy
		{
			if ( (aiGetMarketBuyCost(cResourceFood)/100.0) < kbGetAICostWeight(cResourceFood) ) // Market cheaper than our rate?
			{
				aiBuyResourceOnMarket(cResourceFood);
				aiEcho("Buying food.");
			}
			if ( (aiGetMarketBuyCost(cResourceWood)/100.0) < kbGetAICostWeight(cResourceWood) ) // Market cheaper than our rate?
			{
				aiBuyResourceOnMarket(cResourceWood);
				aiEcho("Buying wood.");
			}
		}
		if ( (woodStatus > 0.33) && (kbResourceGet(cResourceWood) > 200) )  // We have one minute's worth of wood, OK to sell
		{
			if ( (aiGetMarketSellCost(cResourceWood)/100.0) > kbGetAICostWeight(cResourceWood) )	// Market rate higher??
			{
				aiSellResourceOnMarket(cResourceWood);
				aiEcho("Selling wood.");
			}
		}
		if ( (foodStatus > 0.33) && (kbResourceGet(cResourceFood) > 200) )  // We have one minute's worth of food, OK to sell
		{
			if ( (aiGetMarketSellCost(cResourceFood)/100.0) > kbGetAICostWeight(cResourceFood) )	// Market rate higher??
			{
				aiSellResourceOnMarket(cResourceFood);
				aiEcho("Selling food.");
			}
		}
	}
	
	// Update the gather plan goal
	int i=0;
	for (i=0; < 3)
	{
		aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, i, kbGetAICostWeight(i));
	}
}



//==============================================================================
// updateGathererRatios()
//==============================================================================
// Check the forecast variables, check inventory, set assignments
void updateGathererRatios(void)
{
	float goldSupply = kbResourceGet(cResourceGold);
	float woodSupply = kbResourceGet(cResourceWood);
	float foodSupply = kbResourceGet(cResourceFood);

   float foodMultiplier = 1.2;  // Because food is so much slower to gather, inflate need
   gFoodForecast = gFoodForecast * foodMultiplier;

	float goldShortage = gGoldForecast - goldSupply;
	if (goldShortage < 0)
		goldShortage = 0;
	float woodShortage = gWoodForecast - woodSupply;
	if (woodShortage < 0)
		woodShortage = 0;
	float foodShortage = gFoodForecast - foodSupply;
	if (foodShortage < 0)
		foodShortage = 0;

   gGlutRatio = 100.0;   // ludicrously high
   if ( (goldSupply/gGoldForecast) < gGlutRatio )
	  gGlutRatio = goldSupply/gGoldForecast;
   if ( (woodSupply/gWoodForecast) < gGlutRatio )
	  gGlutRatio = woodSupply/gWoodForecast;
   if ( (foodSupply/gFoodForecast) < gGlutRatio )
	  gGlutRatio = foodSupply/gFoodForecast;
   gGlutRatio = gGlutRatio * 2.0;   // Double it, i.e. start reducing civ pop when all resources are > 50% of forecast.
   if (gGlutRatio > 3.0)
	  gGlutRatio = 3.0; // Never cut econ below 1/3 of normal
   if (gGlutRatio > 1)
	  aiEcho("Glut ratio = "+gGlutRatio);
//   aiEcho("Forecast/supply  Gold:"+gGoldForecast+"/"+goldSupply+" Wood:"+gWoodForecast+"/"+woodSupply+" Food:"+gFoodForecast+"/"+foodSupply);

   float totalShortage = goldShortage + woodShortage + foodShortage;
   if (totalShortage < 1)
	  totalShortage = 1;

   float worstShortageRatio = goldShortage/(gGoldForecast+1);
   if ( (woodShortage/(gWoodForecast+1)) > worstShortageRatio)
	  worstShortageRatio = woodShortage/(gWoodForecast+1);
   if ( (foodShortage/(gFoodForecast+1)) > worstShortageRatio)
	  worstShortageRatio = foodShortage/(gFoodForecast+1);

		
	float totalForecast = gGoldForecast + gWoodForecast + gFoodForecast;
	if (totalForecast < 1)
		totalForecast = 1;  // Avoid div by 0.
	
	
	float numGatherers = kbUnitCount(cMyID,cUnitTypeAbstractVillager, cUnitStateAlive);
   if (cMyCulture == cCultureAtlantean)
	  numGatherers = numGatherers * 3;  // Account for pop slots
	
	float numTradeCarts = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0), cUnitStateAlive);
	
	float numFishBoats = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive);
   if (numFishBoats >= 1)
	  numFishBoats = numFishBoats - 1; // Ignore scout
	
	float civPopTotal = numGatherers + numTradeCarts + numFishBoats;

   int doomedID = -1;   // Who to kill...
   if (civPopTotal > (aiGetEconomyPop()+5))
   {  // We need to delete something
	  if ( numGatherers > numTradeCarts ) // Gatherer or fish boat
	  {
		 if (numGatherers > numFishBoats)
		 {
			doomedID = findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractVillager);
			aiEcho("Deleting a villager. "+doomedID);
		 }
		 else
		 {
			doomedID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0));
			aiEcho("Deleting a fishing boat. "+doomedID);
		 }
	  }
	  else  // Trade cart or fish boat
	  {
		 if (numTradeCarts > numFishBoats)
		 {
			doomedID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0));
			aiEcho("Deleting a trade cart. "+doomedID);
		 }
		 else
		 {
			doomedID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0));
			aiEcho("Deleting a fishing boat. "+doomedID);
		 }
	  }
	  aiTaskUnitDelete(doomedID);
	  if (cMyCulture == cCultureAtlantean)
		 numGatherers = numGatherers - 3;
	  else
		 numGatherers = numGatherers - 1;
   }
	
	// Figure out what percent of our total civ pop we want working on each resource.  To do that,
	// figure out what the percentages would be to match our shortages, and the percents to match
	// our forecast, and come up with a weighted average of the two.  That way, if we don't have a wood shortage
	// at the moment, but we do expect to keep using wood, we'll keep some villagers on wood.
	
		// This much (forecastWeight) of the allocation is based on forecast, the rest on shortages.
		// If the biggest shortage is nearly equal to the forecast (nothing on hand), let
		// the shortage dominate.  If the shortage is relatively small, let the
		// forecast dominate
	float forecastWeight = 1.0 - worstShortageRatio;	
	float goldForecastRatio = gGoldForecast / totalForecast;
	float woodForecastRatio = gWoodForecast / totalForecast;
	float foodForecastRatio = gFoodForecast / totalForecast;
	
	float goldShortageRatio = 0.0;
	if (totalShortage > 0)
		goldShortageRatio = goldShortage / totalShortage;
	float woodShortageRatio = 0.0;
	if (totalShortage > 0)
		woodShortageRatio = woodShortage / totalShortage;
	float foodShortageRatio = 0.0;
	if (totalShortage > 0)
		foodShortageRatio = foodShortage / totalShortage;
		
	float desiredGoldRatio = forecastWeight*goldForecastRatio + (1.0-forecastWeight)*goldShortageRatio;
	float desiredWoodRatio = forecastWeight*woodForecastRatio + (1.0-forecastWeight)*woodShortageRatio;
	float desiredFoodRatio = forecastWeight*foodForecastRatio + (1.0-forecastWeight)*foodShortageRatio;
	
	// We now have the desired ratios, which can be converted to total civilian units, but then need to be adjusted for trade
	// carts and fishing boats.
	float desiredGoldUnits = desiredGoldRatio * civPopTotal;
	float desiredWoodUnits = desiredWoodRatio * civPopTotal;
	float desiredFoodUnits = desiredFoodRatio * civPopTotal;
	
	float neededGoldGatherers = desiredGoldUnits - numTradeCarts;
	float neededFoodGatherers = desiredFoodUnits - numFishBoats;
	float neededWoodGatherers = desiredWoodUnits;
	
	aiEcho("Forecast ratios:  Gold "+goldForecastRatio+", Wood "+woodForecastRatio+", Food "+foodForecastRatio);
	aiEcho("Shortage ratios:  Gold "+goldShortageRatio+", Wood "+woodShortageRatio+", Food "+foodShortageRatio);
	aiEcho("Forecast weight:  "+forecastWeight);
   int intGather = numGatherers;
   int intFish = numFishBoats;
   int intFood = neededFoodGatherers + 0.5;
   int intWood = neededWoodGatherers + 0.5;
   int intGold = neededGoldGatherers + 0.5;
   int intTrade = numTradeCarts;
   aiEcho(">>> "+intGather+" villagers:  "+"Food "+intFood+", Wood "+intWood+", Gold "+intGold+"  (Fish "+intFish+", Trade "+intTrade+") <<<");
		
	if (neededGoldGatherers < 0)
		neededGoldGatherers = 0;
	if (neededFoodGatherers < 0)
		neededFoodGatherers = 0;
	if (neededWoodGatherers < 0)
		neededWoodGatherers = 0;
		
	float totalNeededGatherers = neededGoldGatherers + neededFoodGatherers + neededWoodGatherers;
	// Note, this total may be different than the total gatherers, if the trade carts are more than needed, or if
	// the fishing boats supply more food than we need, so this number may be lower...and should be used as the basis
	// for assigning villager percentages.
	
	float goldAssignment = neededGoldGatherers / totalNeededGatherers;
	float woodAssignment = neededWoodGatherers / totalNeededGatherers;
	float foodAssignment = neededFoodGatherers / totalNeededGatherers;
	
	aiSetResourceGathererPercentageWeight( cRGPScript, 1.0);
	aiSetResourceGathererPercentageWeight( cRGPCost, 0.0);
	aiSetResourceGathererPercentage( cResourceGold, goldAssignment, false, cRGPScript);
	aiSetResourceGathererPercentage( cResourceWood, woodAssignment, false, cRGPScript);
	aiSetResourceGathererPercentage( cResourceFood, foodAssignment, false, cRGPScript);
	if ( (cMyCulture == cCultureGreek) && (kbGetAge() > cAge1) )
		aiSetResourceGathererPercentage( cResourceFavor, 0.05, false, cRGPScript);
	aiNormalizeResourceGathererPercentages( cRGPScript );
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, aiGetResourceGathererPercentage(cResourceGold, cRGPScript));
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, aiGetResourceGathererPercentage(cResourceWood, cRGPScript));
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, aiGetResourceGathererPercentage(cResourceFood, cRGPScript));
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, aiGetResourceGathererPercentage(cResourceFavor, cRGPScript));
}



//==============================================================================
// setMilitaryUnitCostForecast
// Checks the current age, looks into the appropriate unit picker,
// calculates approximate resource needs for the next few (3?) minutes,
// adds this amount to the global vars.
//==============================================================================
void setMilitaryUnitCostForecast(void)
{
	int upID = -1;  // ID of the unit picker to query
	float totalAmount = 0.0;	// Total resources to be spent in near future
	if (kbGetAge() == cAge2)
	{
		upID = gRushUPID;
		totalAmount = 1200;
	}
	if (kbGetAge() == cAge3)
	{
		upID = gLateUPID;
		totalAmount = 3000;
	}
	if (kbGetAge() >= cAge4)
	{
		upID = gLateUPID;
		totalAmount = 5000;
	}

   int origGold = gGoldForecast;
   int origWood = gWoodForecast;
   int origFood = gFoodForecast;
		

   float goldCost = 0.0;
   float woodCost = 0.0;
   float foodCost = 0.0;
   float totalCost = 0.0;

	int unitID = kbUnitPickGetResult( upID, 0); // Primary unit
	float weight = 1.0;
   int numUnits = kbUnitPickGetDesiredNumberUnitTypes(upID);

   if (numUnits == 2)
	  weight = 0.67; // 2/3 and 1/3
   if (numUnits >= 3)
	  weight = 0.50; // 1/2, 1/3, 1/6
   aiEcho("Military Unit Cost Forecast:");
   aiEcho(" Main unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
   
   goldCost = kbUnitCostPerResource(unitID, cResourceGold);
   woodCost = kbUnitCostPerResource(unitID, cResourceWood);
   foodCost = kbUnitCostPerResource(unitID, cResourceFood);
   totalCost = goldCost+woodCost+foodCost;
	
	gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);

   if (numUnits > 1)
   {  // Do second unit
	  unitID = kbUnitPickGetResult(upID, 1);
	  weight = 0.33;	// Second is 1/3 regardless 
	  aiEcho("   Secondary unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
	  goldCost = kbUnitCostPerResource(unitID, cResourceGold);
	  woodCost = kbUnitCostPerResource(unitID, cResourceWood);
	  foodCost = kbUnitCostPerResource(unitID, cResourceFood);
	  totalCost = goldCost+woodCost+foodCost;
	   
	   gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	   gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	   gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
   }

   if (numUnits > 2)
   {  // Do third unit
	  unitID = kbUnitPickGetResult(upID, 2);
	  weight = 0.167;   // Third unit, if used, is 1/6
	  aiEcho("   Tertiary unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
	  goldCost = kbUnitCostPerResource(unitID, cResourceGold);
	  woodCost = kbUnitCostPerResource(unitID, cResourceWood);
	  foodCost = kbUnitCostPerResource(unitID, cResourceFood);
	  totalCost = goldCost+woodCost+foodCost;
	   
	   gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	   gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	   gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
   }
   aiEcho(" Mil forecast gold: "+(gGoldForecast-origGold)+", wood: "+(gWoodForecast-origWood)+", food: "+(gFoodForecast-origFood));
}

void addUnitForecast(int unitTypeID=-1, int qty=1)
{
   if (unitTypeID < 0)
	  return;
   gGoldForecast = gGoldForecast + kbUnitCostPerResource(unitTypeID, cResourceGold)*qty;
   gWoodForecast = gWoodForecast + kbUnitCostPerResource(unitTypeID, cResourceWood)*qty;
   gFoodForecast = gFoodForecast + kbUnitCostPerResource(unitTypeID, cResourceFood)*qty;
}


void addTechForecast(int techID=-1)
{
   if (techID < 0)
	  return;
   gGoldForecast = gGoldForecast + kbTechCostPerResource(techID, cResourceGold);
   gWoodForecast = gWoodForecast + kbTechCostPerResource(techID, cResourceWood);
   gFoodForecast = gFoodForecast + kbTechCostPerResource(techID, cResourceFood);
}

//==============================================================================
// econForecastAge4
//==============================================================================
rule econForecastAge4   // Rule activates when age 4 research begins
minInterval 11
inactive
runImmediately
{   
	if ( (kbGetAge() == cAge3) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) )   // Upgrade failed, revert
	{
		aiEcho("Age 4 upgrade failed.");
		xsDisableSelf();
		xsEnableRule("econForecastAge3Mid");
		return;
	}
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;
	
	/*
	Baseline assumptions...assumes we'll need the following:
	  300f, 200w, 500g for generic upgrades
	  1 Settlement
	  (Villagers, fish boats, trade carts, farms, towers and military units will be counted below.)
	*/
	
	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 900;
		gWoodForecast = 500;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 800;
		gWoodForecast = 800;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 800;
		gWoodForecast = 800;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gGoldForecast = 700;
		gWoodForecast = 800;
		gFoodForecast = 400;
	}
	else if (cMyCulture == cCultureChinese)
	{
		gGoldForecast = 700;
		gWoodForecast = 800;
		gFoodForecast = 400;
	}

	
	int temp = 0;
	// Assume all towers built.  Since we don't replace towers, doing a count is dangerous.
	
	// tower upgrades
	if (gBuildTowers == true)
		// BallistaTower
		if ( (cMyCulture == cCultureEgyptian) && (kbGetTechStatus(cTechBallistaTower) < cTechStatusResearching) )
			addTechForecast(cTechBallistaTower);	
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  // How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);   // Number of villagers we have, including dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  // Makes up for counting dwarves toward our villager total
	if (temp > 12)
		temp = 12;  // Just 3 minutes worth, please.
   if (temp < 0)
	  temp = 0;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
	  if (temp > 8 )
		 temp = 8;  // more than we'll build in 3 minutes

		if (temp > 0)
			addUnitForecast(cUnitTypeFarm, temp);
	}
	
	// Market
	if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 2)
		addUnitForecast(cUnitTypeMarket, 1);
	
   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
   {
	  gWoodForecast = gWoodForecast + 100*temp;
	  gGoldForecast = gGoldForecast + 50*temp;
   }

	// Trade carts
	if (gTradeMaintainPlanID >= 0)
	{   // We're making trade carts
		int cartsNeeded = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
		cartsNeeded = cartsNeeded - kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
		if (cartsNeeded > 0)
		   addUnitForecast(aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanUnitType, 0),cartsNeeded);
	}

	// Fortress, etc.
	int bigBuildingID = cUnitTypeMigdolStronghold;
	if (cMyCulture == cCultureGreek)
		bigBuildingID = cUnitTypeFortress;
	if (cMyCulture == cCultureNorse)
		bigBuildingID = cUnitTypeHillFort;
	if(cMyCulture == cCultureChinese)
		bigBuildingID = cUnitTypeCastle;
	if (kbUnitCount(cMyID, bigBuildingID, cUnitStateAliveOrBuilding) < 1) 
	  addUnitForecast(bigBuildingID, 1);
   
	setMilitaryUnitCostForecast();   // Get the estimate of military needs
		
	aiEcho("Age 4 Forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}



//==============================================================================
// econForecastAge3Mid
//==============================================================================
rule econForecastAge3Mid		// Rule activates when 2 minutes into age 3, turns off when age 4 research begins
minInterval 11
inactive
runImmediately
{
	if ( kbGetTechStatus(gAge4MinorGod) >=  cTechStatusResearching )	// On our way to age 4, hand off...
	{
		xsEnableRule("econForecastAge4");
		econForecastAge4();
		xsDisableSelf();
		return;  // We're done
	}
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;
	
	/*
	Baseline assumptions...assumes we'll need the following:
	  1 more normal military building
	  300f, 200w, 500g for generic upgrades
	  4 more outposts (Egypt)
	  1 more dropsite (greek) 
	  Upgrade to age 4.
	  1 Settlement 
	  (Villagers, fish boats, trade carts, farms, towers and military units will be counted below.)
	*/
	
	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 2035;
		gWoodForecast = 600;
		gFoodForecast = 1400;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 1800;
		gWoodForecast = 990;
		gFoodForecast = 1300;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 1800;
		gWoodForecast = 1150;
		gFoodForecast = 1300;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gGoldForecast = 1725;
		gWoodForecast = 975;
		gFoodForecast = 1400;
	}
	else if (cMyCulture == cCultureChinese)
	{
		gGoldForecast = 1725;
		gWoodForecast = 975;
		gFoodForecast = 1400;
	}
	int temp = 0;

   // Milk Stones
//   if ( (cMyCulture == cCultureNorse) &&(kbGetTechStatus(cTechMilkStones) < cTechStatusResearching) )
//  addTechForecast(cTechMilkStones);

   // Fortified TC
   if ( kbGetTechStatus(cTechFortifyTownCenter) < cTechStatusResearching) 
	  addTechForecast(cTechFortifyTownCenter);

	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;
   if (temp > 0)
	  addUnitForecast(cUnitTypeTower, temp);
 
	// tower upgrades
	if (gBuildTowers == true)
	{
		// GuardTower
		if ( (cMyCulture != cCultureNorse) &&(kbGetTechStatus(cTechGuardTower) < cTechStatusResearching) )
		{
			addTechForecast(cTechGuardTower);   
		}
		// Carrier Pigeons
		if ( kbGetTechStatus(cTechCarrierPigeons) < cTechStatusResearching)
		{
		 addTechForecast(cTechCarrierPigeons);
		}
		// Boiling Oil
		if ( kbGetTechStatus(cTechBoilingOil) < cTechStatusResearching)
		{
		 addTechForecast(cTechBoilingOil);
		}
	}
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  // How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);   // Number of villagers we have, including dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  // Makes up for counting dwarves toward our villager total
	if (temp > 12)
		temp = 12;  // Just 3 minutes worth, please.
   if (cMyCulture == cCultureAtlantean)
	  if (temp > 4)
		 temp = 4;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
	  if (temp > 8 )
		 temp = 8;  // more than we'll build in 3 minutes

		if (temp > 0)
		 addUnitForecast(cUnitTypeFarm, temp);
	}
	
   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
   {
	  gWoodForecast = gWoodForecast + 100*temp;
	  gGoldForecast = gGoldForecast + 50*temp;
   }

	// Market
	if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 1)
	{
	  addUnitForecast(cUnitTypeMarket, 1);
	}
	
	// Trade carts
	if (gTradeMaintainPlanID >= 0)
	{   // We're making trade carts
		int cartsNeeded = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
		cartsNeeded = cartsNeeded - kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
		if (cartsNeeded > 0)
		   addUnitForecast(aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanUnitType, 0),cartsNeeded);
	}

	// Fortress, etc.
	int bigBuildingID = cUnitTypeMigdolStronghold;
	if (cMyCulture == cCultureGreek)
		bigBuildingID = cUnitTypeFortress;
	if (cMyCulture == cCultureNorse)
		bigBuildingID = cUnitTypeHillFort;
	if(cMyCulture == cCultureChinese)
		bigBuildingID = cUnitTypeCastle;
	if (kbUnitCount(cMyID, bigBuildingID, cUnitStateAliveOrBuilding) < 1) 
	  addUnitForecast(bigBuildingID, 1);
	
	setMilitaryUnitCostForecast();  
	
	aiEcho("Age 3 (mid) Forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}




//==============================================================================
// econForecastAge3Early
//==============================================================================
rule econForecastAge3Early  // Rule activates when age2 research begins, turns off when we've been in age 2 for 2 minutes
minInterval 11
inactive
runImmediately
{
	static int  ageStartTime = -1;
	
	if ( (kbGetAge() == cAge2) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching) )   // Upgrade failed, revert
	{
		//aiEcho("Age 3 upgrade failed.");
		xsDisableSelf();
		xsEnableRule("econForecastAge2Mid");
		return;
	}
	
	if ( (kbGetAge() >= cAge3) && (ageStartTime == -1))
		ageStartTime = xsGetTime();
		
	if ( (kbGetAge() >= cAge3) && ((xsGetTime() - ageStartTime) > 120000) ) // more than 2 minutes in second age?
	{
		//aiEcho("Enabling econForecastAge3Mid.");
		xsEnableRule("econForecastAge3Mid");
		econForecastAge3Mid();
		xsDisableSelf();
		return;  // We're done
	}
	
	// If we've made it here, we're in researching age 3, or we're in the first
	// 2 minutes of age 3.  Let's see what we need.
		
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;	 
	
	/*
	Baseline assumptions...assumes we'll need the following:
	  3 more normal military buildings
	  300f, 200w, 400g for generic upgrades
	  4 more outposts (Egypt)
	  1 more dropsite (greek)
	  A market and a fortress/hill fort/migdol fortress
	  Fortified TC upgrade or a settlement
	 Milk Stones for Atlanteans
	  (Villagers, fish boats, trade carts, farms, towers and military units will be counted below.)
	*/
	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 1485;
		gWoodForecast = 800;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 1000;
		gWoodForecast = 1310;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 1100;
		gWoodForecast = 1600;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gGoldForecast = 1325;
		gWoodForecast = 1575;
		gFoodForecast = 400;
	}   
	else if(cMyCulture == cCultureChinese)
	{
		gGoldForecast = 1325;
		gWoodForecast = 1575;
		gFoodForecast = 400; 
	}
	int temp = 0;
	
	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;
   if (temp>0)
	  addUnitForecast(cUnitTypeTower, temp);

	// tower upgrades
	if (gBuildTowers == true)
	{
		// GuardTower
		if ( (cMyCulture != cCultureNorse) &&(kbGetTechStatus(cTechGuardTower) < cTechStatusResearching) )
		 addTechForecast(cTechGuardTower);  

		// Carrier Pigeons
		if ( kbGetTechStatus(cTechCarrierPigeons) < cTechStatusResearching)
		 addTechForecast(cTechCarrierPigeons);

		// Boiling Oil
		if ( kbGetTechStatus(cTechBoilingOil) < cTechStatusResearching)
		 addTechForecast(cTechBoilingOil);
	}
		
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  // How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);   // Number of villagers we need, ignoring dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  // Makes up for counting dwarves toward our villager total
	if (cMyCulture != cCultureAtlantean)
   {
	  if (temp > 12)
		temp = 12;  // Just 3 minutes worth, please.
   }
   else
	  if (temp > 4)
		 temp = 4;
   
	if (cMyCulture != cCultureAtlantean)
   {
	if (temp < 8)
		   temp = 8;		// In transition, we won't have the age 2 villie target, so assume at least 8 more.
   }
   else
	  if (temp < 3)
		 temp = 3;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
   {
	  gWoodForecast = gWoodForecast + 100*temp;
	  gGoldForecast = gGoldForecast + 50*temp;
   }

	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
	  if (temp > 8 )
		 temp = 8;  // more than we'll build in 3 minutes

		if (temp > 0)
		 addUnitForecast(cUnitTypeFarm, temp);
	}
   // 1 Settlement for atlanteans
   if ((cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) <= 3))
	  addUnitForecast(cUnitTypeSettlementLevel1, 1);

	setMilitaryUnitCostForecast();  
	aiEcho("Age 3 (early) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");

	updateGathererRatios();
}



//==============================================================================
// econForecastAge2Mid
//==============================================================================
rule econForecastAge2Mid		// Rule activates when 2 minutes into age 2, turns off when age 3 research begins
minInterval 11
inactive
runImmediately
{
	if ( kbGetTechStatus(gAge3MinorGod) >=  cTechStatusResearching)  // On our way to age 3, hand off...
	{
		//aiEcho("Enabling econForecastAge3Early.");
		xsEnableRule("econForecastAge3Early");
		econForecastAge3Early();
		xsDisableSelf();
		return;  // We're done
	}
	
	// If we've made it here, we're in mid age 2.
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;
	
	/*
	Baseline assumptions...assumes we'll need the following:
	  2 more houses
	  1 more normal military building
	  200f, 100w, 300g for generic upgrades
	  4 more outposts (Egypt)
	  2 more dropsites (greek) or 1 (norse)
	  Upgrade to age 3.
	  (Villagers, fish boats, trade carts, farms, towers and military units will be counted below.)
	*/
	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 835;
		gWoodForecast = 100;
		gFoodForecast = 1100;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 700;
		gWoodForecast = 490;
		gFoodForecast = 1150;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 700;
		gWoodForecast = 550;
		gFoodForecast = 1100;
	}
   if (cMyCulture == cCultureAtlantean)
   {
	  gGoldForecast = 895;
	  gWoodForecast = 315;
	  gFoodForecast = 1000;
   }
  else if(cMyCulture == cCultureChinese)
  {
	  gGoldForecast = 895;
	  gWoodForecast = 315;
	  gFoodForecast = 1000;
  }
	
	int temp = 0;

	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers/2) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;
   if (temp > 0)
	  addUnitForecast(cUnitTypeTower, temp);

	// tower upgrades
	if (gBuildTowers == true)
	{
		// Watchtower
		if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) <= cTechStatusResearching))
		 addTechForecast(cTechWatchTower);

		// Crenallations
		if ( kbGetTechStatus(cTechCrenellations) < cTechStatusResearching)
		 addTechForecast(cTechCrenellations);

		// Signal Fires
		if ( kbGetTechStatus(cTechSignalFires) < cTechStatusResearching)
		 addTechForecast(cTechSignalFires);
	}

   // Settlements
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);  // Settlements paid for
   temp = gEarlySettlementTarget - numberSettlements;   // To be paid for
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
	  addUnitForecast(cUnitTypeSettlementLevel1, temp);
   aiEcho("Adding forecast for "+temp+" early settlements.");
	// outposts
	if (cMyCulture == cCultureEgyptian)
	{
		temp = 10 - kbUnitCount(cMyID, cUnitTypeOutpost, cUnitStateAliveOrBuilding);
		if (temp > 0)
		 addUnitForecast(cUnitTypeOutpost, temp);
	}   

   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
   {
	  gWoodForecast = gWoodForecast + 100*temp;
	  gGoldForecast = gGoldForecast + 50*temp;
   }
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  // How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);   // Number of villagers we have, including dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  // Makes up for counting dwarves toward our villager total
	if (temp > 12)
		temp = 12;  // Just 3 minutes worth, please.
   if (cMyCulture == cCultureAtlantean)
	  if (temp > 4)
		 temp = 4;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
	  if (temp > 8 )
		 temp = 8;  // more than we'll build in 3 minutes

		if (temp > 0)
		 addUnitForecast(cUnitTypeFarm, temp);
	}   
   // 1 Settlement for atlanteans
   if ((cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) <= 3))
	  addUnitForecast(cUnitTypeSettlementLevel1, 1);

	setMilitaryUnitCostForecast();  
	
	aiEcho("Age 2 (mid) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}





//==============================================================================
// econForecastAge2Early
//==============================================================================
rule econForecastAge2Early  // Rule activates when age2 research begins, turns off when we've been in age 2 for 2 minutes
minInterval 11
inactive
runImmediately
{
	static int  ageStartTime = -1;
	
	if ( (kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching) )   // Upgrade failed, revert
	{
		//aiEcho("Age 2 upgrade failed.");
		xsDisableSelf();
		xsEnableRule("econForecastAge1Mid");
		return;
	}
	
	if ( (kbGetAge() >= cAge2) && (ageStartTime == -1))
		ageStartTime = xsGetTime();
		
	if ( (kbGetAge() >= cAge2) && ((xsGetTime() - ageStartTime) > 120000) ) // more than 2 minutes in second age?
	{
		//aiEcho("Enabling econForecastAge2Mid.");
		xsEnableRule("econForecastAge2Mid");
		econForecastAge2Mid();
		xsDisableSelf();
		return;  // We're done
	}
	
	// If we've made it here, we're in researching age 2, or we're in the first
	// 2 minutes of age 2.  Let's see what we need.
	
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 200.0;   // Keep a bit of extra food around
		
   int temp=0;

	// Houses...assume we'll need a total of 2 more
   if (cMyCulture == cCultureAtlantean)
	  addUnitForecast(cUnitTypeManor, 2);
   else
	  addUnitForecast(cUnitTypeHouse, 2);

   // fish boats
   if (gFishing == true)
   {
	  // get current fish boat count
	  int fishBoatType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
	  int boatCount = kbUnitCount(cMyID, fishBoatType, cUnitStateAlive);
	  temp = gNumBoatsToMaintain - boatCount;
	  if (temp > 0)
		 addUnitForecast(fishBoatType, temp);
	  if (temp > 0)
		 aiEcho("Need "+temp+" fishing boats.");

	  temp = 1 - kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
	  if (temp < 0)
		 temp = 0;
	  if (temp > 0)
		 addUnitForecast(cUnitTypeDock, 1);
   }
   // Guild
   if (cMyCulture == cCultureAtlantean)
   {
	  if(kbUnitCount(cMyID,cUnitTypeGuild, cUnitStateAliveOrBuilding) <= 0)
		 addUnitForecast(cUnitTypeGuild, 1);
   }

	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers/2) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;

   if (temp > 0)
	  addUnitForecast(cUnitTypeTower, temp);

	// first tower upgrade
	if (gBuildTowers == true)
	{
		if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) <= cTechStatusResearching))
		 addTechForecast(cTechWatchTower);
	}

   // Settlements
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);  // Settlements paid for
   temp = gEarlySettlementTarget - numberSettlements;   // To be paid for
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
	  addUnitForecast(cUnitTypeSettlementLevel1, temp);
   aiEcho("Adding forecast for "+temp+" early settlements.");
	// outposts
	if (cMyCulture == cCultureEgyptian)
	{
		temp = 10 - kbUnitCount(cMyID, cUnitTypeOutpost, cUnitStateAliveOrBuilding);
		if (temp > 0)
		 addUnitForecast(cUnitTypeOutpost, temp);
	}   
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  // How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);   // Number of villagers we need, ignoring dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  // Makes up for counting dwarves toward our villager total
	if (cMyCulture != cCultureAtlantean)
   {
	  if (temp > 12)
		temp = 12;  // Just 3 minutes worth, please.
   }
   else
	  if (temp > 4)
		 temp = 4;
   
	if (cMyCulture != cCultureAtlantean)
   {
	if (temp < 8)
		   temp = 8;		// In transition, we won't have the age 2 villie target, so assume at least 8 more.
   }
   else
	  if (temp < 3)
		 temp = 3;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

	
	// dropsites, assume 1 for norse, 2 for greek.
	if (cMyCulture == cCultureGreek)
	{
		temp =2;
		gWoodForecast = gWoodForecast + 50*temp;
	}
	if (cMyCulture == cCultureNorse)
	{
		temp = 1;
		gWoodForecast = gWoodForecast + 50*temp;
		gFoodForecast = gFoodForecast + 50*temp;
	}
	
	// military buildings, assume 1 needed regardless of how many we have
	if (cMyCulture == cCultureGreek)
	{
		gWoodForecast = gWoodForecast + 100;
	}
	if (cMyCulture == cCultureNorse)
	{
		gWoodForecast = gWoodForecast + 110;
	}
	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = gGoldForecast + 75;
	}
   if (cMyCulture == cCultureAtlantean)
   {
		gWoodForecast = gWoodForecast + 75;
		gGoldForecast = gGoldForecast + 25;
   }
	else if(cMyCulture == cCultureChinese)
	{
		gWoodForecast = gWoodForecast + 75;
		gGoldForecast = gGoldForecast + 25;
	}


	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
	  if (temp > 8 )
		 temp = 8;  // more than we'll build in 3 minutes
		if (temp > 0)
		 addUnitForecast(cUnitTypeFarm, temp);
	}
	
   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
	  temp = 0;
   if (temp > 0)
   {
	  gWoodForecast = gWoodForecast + 100*temp;
	  gGoldForecast = gGoldForecast + 50*temp;
   }

	// Techs
	if ( kbGetTechStatus(cTechPlow) < cTechStatusResearching)
	  addTechForecast(cTechPlow);
   if ( kbGetTechStatus(cTechHusbandry) < cTechStatusResearching)
	  addTechForecast(cTechHusbandry);
	if ( kbGetTechStatus(cTechHuntingDogs) < cTechStatusResearching)
	  addTechForecast(cTechHuntingDogs);
	if ( kbGetTechStatus(cTechHandAxe) < cTechStatusResearching)
	  addTechForecast(cTechHandAxe);	
	if ( kbGetTechStatus(cTechPickaxe) < cTechStatusResearching)
	  addTechForecast(cTechPickaxe);


   // 1 Settlement for atlanteans
   if ((cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) <= 1))
   {
		gGoldForecast = gGoldForecast + 200;
		gWoodForecast = gWoodForecast + 200;
		gFoodForecast = gFoodForecast + 100;	 
   }
	aiEcho("Age 2 (early) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}





//==============================================================================
// econForecastAge1Mid
//==============================================================================
rule econForecastAge1Mid		// Rule active for mid age 1 (cAge1), starting 2 minutes in age, ending when next age upgrade starts
minInterval 11
inactive
{
	static int  ageStartTime = -1;
	
	int age = kbGetAge();
	if (age > cAge1)
	{
		xsDisableSelf();
		xsEnableRule("econForecastAge2Early");
		return;
	}
	
	if (ageStartTime == -1)
		ageStartTime = xsGetTime();
		

	if ( kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching ) 
	{   // Next age upgrade is on the way
		xsDisableSelf();
		xsEnableRule("econForecastAge2Early");
		econForecastAge2Early();	// Since runImmediately doesn't seem to be working
		return;
	}
	
	// If we've made it here, we're in age 1 (cAge1), we've been in the age at least 2 minutes,
	// and we haven't started the age 3 upgrade.  Let's see what we need.
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;
			
	// Houses...assume we'll need 2
	int temp = 2;
   if (cMyCulture == cCultureAtlantean)
	  addUnitForecast(cUnitTypeManor, 2);
   else
	  addUnitForecast(cUnitTypeHouse, 2);

	// temple
	temp = 1 - kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding);
   if (temp > 0)
   {
	  addUnitForecast(cUnitTypeTemple, temp); 
	  if (xsGetTime() > 3*60*1000)
		 addUnitForecast(cUnitTypeTemple, 1);   // Add an extra, we need it soon!
   }

   if (cMyCiv == cCivThor)  // add 100 to cover early dwarfage
	  gGoldForecast = gGoldForecast + 100*temp;


   // Settlements, even if we won't build them until age 2...
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);  // Settlements paid for
   temp = gEarlySettlementTarget - numberSettlements;   // To be paid for
   if (temp < 0)
	  temp = 0;
   if ( (temp > 0) && (cMyCulture == cCultureAtlantean) )
   {
	  addUnitForecast(cUnitTypeSettlementLevel1, temp);
	  aiEcho("Adding forecast for "+temp+" early settlements.");
   }

	// outposts
	if (cMyCulture == cCultureEgyptian)
	{
		addUnitForecast(cUnitTypeOutpost, 4);  // Assume we'll need a few more
	}   
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);  // How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);   // Number of villagers we need, ignoring dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);  // Makes up for counting dwarves toward our villager total
   if (cMyCulture == cCultureAtlantean)
   {
	  if(temp > 5)
		 temp = 5;  // Just a few minutes' worth
   }
   else
   {
	  if(temp > 13)
		 temp = 13;   // Just a few minutes' worth
   }

	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

   // fish boats
   if (gFishing == true)
   {
	  // get current fish boat count
	  int fishBoatType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
	  int boatCount = kbUnitCount(cMyID, fishBoatType, cUnitStateAlive);
	  temp = gNumBoatsToMaintain - boatCount;
	  gWoodForecast = gWoodForecast + 50*temp;
	  if (temp > 0)
		 aiEcho("Need "+temp+" fishing boats.");

	  temp = 1 - kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
	  if (temp < 0)
		 temp = 0;
	  if (temp > 0)
		 addUnitForecast(cUnitTypeDock, 1);
   }
	
	// Age 2 upgrade
	gFoodForecast = gFoodForecast + 400;
	
	// dropsites
	if (cMyCulture == cCultureGreek)
	{
		temp = 2;
		gWoodForecast = gWoodForecast + 50*temp;
	}
	if (cMyCulture == cCultureNorse)
	{
		temp = 1;
		gWoodForecast = gWoodForecast + 50*temp;
		gFoodForecast = gFoodForecast + 50*temp;
	}
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);   // Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
	  if (temp > 5)
		 temp = 5;
		if (temp > 0)
		 addUnitForecast(cUnitTypeFarm, temp);
	}
	aiEcho("Age 1 (mid) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios(); 
}




//==============================================================================
//initGreek
//==============================================================================
void initGreek(void)
{
   aiEcho("GREEK Init:");

   //Modify our favor need.  A pseudo-hack.
   aiSetFavorNeedModifier(10.0);

   //Greek scout types.
   gLandScout=cUnitTypeScout;
   gAirScout=cUnitTypePegasus;
   gWaterScout=cUnitTypeFishingShipGreek;
   //Create the Greek scout plan.

   int exploreID=aiPlanCreate("Explore_SpecialGreek", cPlanExplore);
   if (exploreID >= 0)
   {
	  aiPlanAddUnitType(exploreID, cUnitTypeScout, 1, 1, 1);
	  aiPlanSetActive(exploreID);
   }

   //Zeus.
   if (cMyCiv == cCivZeus)
   {
	  //Create a simple plan to maintain 1 water scout.
	  if ((gWaterMap == true) || (gTransportMap == true))
		 createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

	  //Random Age2 God.
	  gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get Underworld Passage if we have a transport map.  Else, random.
	  if (gTransportMap == true)
		 gAge3MinorGod=cTechAge3Apollo;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Get Lightning if we're rushing.  Else, random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge4MinorGod=cTechAge4Hera;
	  else
		 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   //Poseidon.
   else if (cMyCiv == cCivPoseidon)
   {
	  //Give him the hippocampus as his water scout.
	  gWaterScout=cUnitTypeHippocampus;
	  aiEcho("Poseidon's water scout is the "+kbGetUnitTypeName(gWaterScout)+".");

	  //Random Age2 God.
	  gAge2MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Random Age3 God.
	  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Get EQ if we're rushing.  Else, random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge4MinorGod=cTechAge4Artemis;
	  else
		 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   //Hades.
   else if (cMyCiv == cCivHades)
   {
	  //Create a simple plan to maintain 1 water scout.
	  if ((gWaterMap == true) || (gTransportMap == true))
		 createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

	  //Random Age2 God.
	  gAge2MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get Underworld Passage if we have a transport map.  Else, random.
	  if (gTransportMap == true)
		 gAge3MinorGod=cTechAge3Apollo;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Get EQ if we're rushing.  Else, random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge4MinorGod=cTechAge4Artemis;
	  else
		 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   if (cvAge2GodChoice != -1)
	  gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
	  gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
	  gAge4MinorGod = cvAge4GodChoice;

}

//==============================================================================
//initEgyptian
//==============================================================================
void initEgyptian(void)
{
   aiEcho("EGYPTIAN Init:");

   //Create a simple TC empower plan if we're not on Vinlandsaga.
   if ((cvRandomMapName != "vinlandsaga") && (cvRandomMapName != "team migration"))
   {
	  gEmpowerPlanID=aiPlanCreate("Pharaoh Empower", cPlanEmpower);
	  if (gEmpowerPlanID >= 0)
	  {
		 aiPlanSetEconomy(gEmpowerPlanID, true);
		 aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 1, 1, 1);
		 aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeGranary);
		 aiPlanSetActive(gEmpowerPlanID);
	  }
   }

   //Egyptian scout types.
   gLandScout=cUnitTypePriest;
   gAirScout=-1;
   gWaterScout=cUnitTypeFishingShipEgyptian;
   //Create a simple plan to maintain Priests for land exploration.
   createSimpleMaintainPlan(cUnitTypePriest, gMaintainNumberLandScouts, true, kbBaseGetMainID(cMyID));
   //Create a simple plan to maintain 1 water scout.
   if ((gWaterMap == true) || (gTransportMap == true))
	  createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

   //Turn off auto favor gather.
   aiSetAutoFavorGather(false);

   //Set the build limit for Outposts.
   aiSetMaxLOSProtoUnitLimit(4);

   //Isis.
   if (cMyCiv == cCivIsis)
   {
	  //Random Age2 God.
	  gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge3MinorGod=cTechAge3Nephthys;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Random Age4 God.
	  gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   //Ra.
   else if (cMyCiv == cCivRa)
   {
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge2MinorGod=cTechAge2Ptah;
	  else
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge3MinorGod=cTechAge3Hathor;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Random Age4 God.
	  gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   //Set.
   else if (cMyCiv == cCivSet)
   {
	  //Create air explore plans for the hyena.
	  int explorePID=aiPlanCreate("Explore_SpecialSetHyena", cPlanExplore);
	  if (explorePID >= 0)
	  {
		 aiPlanAddUnitType(explorePID, cUnitTypeHyenaofSet, 1, 1, 1);
		 aiPlanSetActive(explorePID);
	  }
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge2MinorGod=cTechAge2Anubis;
	  else
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge3MinorGod=cTechAge3Nephthys;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Random Age4 God.
	  gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   if (cvAge2GodChoice != -1)
	  gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
	  gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
	  gAge4MinorGod = cvAge4GodChoice;
}


rule ulfsarkMaintain
inactive
mininterval 15
{
   if (cMyCulture != cCultureNorse)
   {
	  xsDisableSelf();
	  return;
   }
   if (gUlfsarkMaintainPlanID >= 0)
	  return;  // already exists
   gUlfsarkMaintainPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, true, kbBaseGetMainID(cMyID));
   aiPlanSetDesiredPriority(gUlfsarkMaintainPlanID, 98); // Outrank civPopPlanID for villagers
   gUlfsarkMaintainMilPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, false, kbBaseGetMainID(cMyID));
   aiPlanSetDesiredPriority(gUlfsarkMaintainMilPlanID, 98); // Outrank civPopPlanID for villagers
   xsDisableSelf();
}


//==============================================================================
//initNorse
//==============================================================================
void initNorse(void)
{
   aiEcho("NORSE Init:");

   //Set our trained dropsite PUID.
   aiSetTrainedDropsiteUnitTypeID(cUnitTypeOxCart);

   //Create a reserve plan for our main base for some Ulfsarks if we're not on VS, TM, or Nomad.
   if ((cvRandomMapName != "nomad") && (cvRandomMapName != "vinlandsaga") && (cvRandomMapName != "team migration"))
   {
	  int ulfsarkReservePlanID=aiPlanCreate("UlfsarkBuilderReserve", cPlanReserve);
	  if (ulfsarkReservePlanID >= 0)
	  {
		 aiPlanSetDesiredPriority(ulfsarkReservePlanID, 49);
		 aiPlanSetBaseID(ulfsarkReservePlanID, kbBaseGetMainID(cMyID));
		 aiPlanAddUnitType(ulfsarkReservePlanID, cUnitTypeAbstractInfantry, 1, 1, 1); 
		 aiPlanSetVariableInt(ulfsarkReservePlanID, cReservePlanPlanType, 0, cPlanBuild);
		 aiPlanSetActive(ulfsarkReservePlanID);
	  }

	  //Create a simple plan to maintain X Ulfsarks.
	  xsEnableRule("ulfsarkMaintain");
   }

   // On easy or moderate, get two extra oxcarts ASAP before we're at econ pop cap
   if ( aiGetWorldDifficulty() <= cDifficultyModerate )
   {
	  int easyOxPlan=aiPlanCreate("Easy/Moderate Oxcarts", cPlanTrain);
	  if (easyOxPlan >= 0)
	  {
		 aiPlanSetVariableInt(easyOxPlan, cTrainPlanUnitType, 0, cUnitTypeOxCart);
		 //Train off of economy escrow.
		 aiPlanSetEscrowID(easyOxPlan, cEconomyEscrowID);
		 aiPlanSetVariableInt(easyOxPlan, cTrainPlanNumberToTrain, 0, 2); 
		 aiPlanSetVariableInt(easyOxPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement); 
		 aiPlanSetDesiredPriority(easyOxPlan, 100); 
		 aiPlanSetActive(easyOxPlan);
	  }
   }

   //Turn off auto favor gather.
   aiSetAutoFavorGather(false);

   if (aiGetGameMode() == cGameModeDeathmatch)
   {
	  int dmUlfPlan=aiPlanCreate("dm ulfsarks", cPlanTrain);
	  if (dmUlfPlan >= 0)
	  {
		 aiPlanSetVariableInt(dmUlfPlan, cTrainPlanUnitType, 0, cUnitTypeUlfsark);
		 //Train off of economy escrow.
		 aiPlanSetEscrowID(dmUlfPlan, cEconomyEscrowID);
		 aiPlanSetVariableInt(dmUlfPlan, cTrainPlanNumberToTrain, 0, 5); 
		 aiPlanSetVariableInt(dmUlfPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement); 
		 aiPlanSetDesiredPriority(dmUlfPlan, 99); 
		 aiPlanSetActive(dmUlfPlan);
	  }
   }


   //Norse scout types.
   gLandScout=cUnitTypeUlfsark;
   gAirScout=-1;
   gWaterScout=cUnitTypeFishingShipNorse;
   //Create a simple plan to maintain 1 water scout.
   if ((gWaterMap == true) || (gTransportMap == true))
	  createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

   //Odin.
   if (cMyCiv == cCivOdin)
   {
	  //Create air explore plans for the ravens.
	  int explorePID=aiPlanCreate("Explore_SpecialOdinAir1", cPlanExplore);
	  if (explorePID >= 0)
	  {
		 aiPlanAddUnitType(explorePID, cUnitTypeRaven, 1, 1, 1);
		 aiPlanSetActive(explorePID);
	  }
	  explorePID=aiPlanCreate("Explore_SpecialOdinAir2", cPlanExplore);
	  if (explorePID >= 0)
	  {
		 aiPlanAddUnitType(explorePID, cUnitTypeRaven, 1, 1, 1);
		 aiPlanSetVariableBool(explorePID, cExplorePlanDoLoops, 0, false);
		 aiPlanSetActive(explorePID);
	  }

	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge2MinorGod=cTechAge2Heimdall;
	  else
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Random Age3 God.
	  gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Random Age4 God.
	  gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

   }
   //Thor.
   else if (cMyCiv == cCivThor)
   {
	  //Random Age2 God.
	  gAge2MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge3MinorGod=cTechAge3Bragi;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Random Age4 God.
	  gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

	  //Thor likes dwarves.
	  if (aiGetGameMode() != cGameModeLightning)
		 gDwarfMaintainPlanID=createSimpleMaintainPlan(cUnitTypeDwarf, 2, true, -1);
   }
   //Loki.
   else if (cMyCiv == cCivLoki)
   {
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge2MinorGod=cTechAge2Heimdall;
	  else
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
	  //Get X if we're rushing, else random.
	  if (aiGetPersonality() == "defaultRush")
		 gAge3MinorGod=cTechAge3Bragi;
	  else
		 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
	  //Random Age4 God.
	  gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
   }
   if (cvAge2GodChoice != -1)
	  gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
	  gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
	  gAge4MinorGod = cvAge4GodChoice;

   //Enable our no-infantry check.
   xsEnableRule("norseInfantryCheck");
}


//==============================================================================
//initAtlantean
//==============================================================================
void initAtlantean(void)
{
   aiEcho("ATLANTEAN Init:");

   // Atlantean

   gLandScout=cUnitTypeOracleScout;
   gWaterScout=cUnitTypeFishingShipAtlantean;
   aiSetMinNumberNeedForGatheringAggressvies(3);	  // Rather than 8

   //Create the atlantean scout plans.
   int exploreID=-1;
   int i = 0;
   for (i=0; <3)
   {
	  exploreID = aiPlanCreate("Explore_SpecialAtlantean"+i, cPlanExplore);
	  if (exploreID >= 0)
	  {
		 aiPlanAddUnitType(exploreID, cUnitTypeOracleScout, 0, 1, 1);
		 aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
		 aiPlanSetVariableBool(exploreID, cExplorePlanOracleExplore, 0, true);
		 aiPlanSetDesiredPriority(exploreID, 25);  // Allow oracleHero relic plan to steal one
		 aiPlanSetActive(exploreID);
	  }
   }  

   // Make sure we always have at least 2 oracles
   int oracleMaintainPlanID = createSimpleMaintainPlan(cUnitTypeOracleScout, 2, true, kbBaseGetMainID(cMyID));


   // Special emergency manor build for Lightning
   if (aiGetGameMode() == cGameModeLightning)
   {								   
	  // Build a manor, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
	  createSimpleBuildPlan(cUnitTypeManor, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
   }
   
   aiSetAutoFavorGather(false);

   // Default to random minor god choices, override below if needed
   gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
   //Random Age3 God.
   gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
   //Random Age4 God.
   gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

   if (cMyCiv == cCivGaia)
   {
	  // Age 2 is a toss up, both are good for defense/boomer
	  // Age3Theia for military-oriented players
	  if (cvMilitaryEconSlider > 0.3)
		 gAge3MinorGod = cTechAge3Theia;
	  // Age4...atlas for Defense/Econ (buildings), Hekate for offense/mil
	  if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) > 0.6 )
		 gAge3MinorGod = cTechAge4Hekate;
	  if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.6 )
		 gAge4MinorGod = cTechAge4Atlas;	  
   }


   if (cMyCiv == cCivKronos)
   {
	  // Age 2 Leto for defense/boomer
	  if ( (cvRushBoomSlider + cvOffenseDefenseSlider) > -0.6)
		 gAge2MinorGod = cTechAge2Leto;
	  // Age is a toss up
	  // Age4...atlas for Offense/mil (implode), Helios (vortex) for defense/econ
	  if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) > 0.6 )
		 gAge3MinorGod = cTechAge4Atlas;
	  if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.6 )
		 gAge4MinorGod = cTechAge4Helios;   
   }

   if (cMyCiv == cCivOuranos)
   {
	  // Age 2 oceanus for defense (carnivora)
	  if (cvOffenseDefenseSlider < -0.3)
		 gAge2MinorGod = cTechAge2Okeanus;
	  // Age3Theia for military-oriented players
	  if (cvMilitaryEconSlider > 0.3)
		 gAge3MinorGod = cTechAge3Theia;
	  // Age4...Helios for Defense/Econ (vortex), Hekate for offense/mil
	  if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) > 0.6 )
		 gAge3MinorGod = cTechAge4Hekate;
	  if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.6 )
		 gAge4MinorGod = cTechAge4Helios;   
   }

   // Control variable overrides
   if (cvAge2GodChoice != -1)
	  gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
	  gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
	  gAge4MinorGod = cvAge4GodChoice;

   // If I'm Kronos.. turn on unbuild..
   if (cMyCiv == cCivKronos)
	   unbuildHandler();

   if (cMyCiv == cCivOuranos)
	  xsEnableRule("buildSkyPassages");

}

//==============================================================================
//initChinese
//==============================================================================
void initChinese(void)
{
	aiEcho("CHINESE Init:");

	//Modify our favor need.  A pseudo-hack.
	aiSetFavorNeedModifier(10.0);

	//Greek scout types.
	gLandScout  = cUnitTypeScoutChinese;
	gAirScout   = -1;
	gWaterScout = cUnitTypeFishingShipChinese;
	//Create the Chinese scout plan.

	int exploreID = aiPlanCreate("Explore_SpecialChinese", cPlanExplore);
	if (exploreID >= 0)
	{
		aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 1, 1, 1);
		aiPlanSetActive(exploreID);
	}
  
	exploreID = aiPlanCreate("Explore_SpecialChinese", cPlanExplore);
	if (exploreID >= 0)
	{
		aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 1, 1, 1);
		aiPlanSetActive(exploreID);
	}

	//Fuxi
	if (cMyCiv == cCivFuxi)
	{
	   //Create a simple plan to maintain 1 water scout.
	   if ((gWaterMap == true) || (gTransportMap == true))
		  createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

	   //Random Age2 God.
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
		  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);

		  gAge4MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
		  // Special speed construction speed up
		  xsEnableRule("rSpeedUpBuilding");
	}
	//Nuwa
	else if (cMyCiv == cCivNuwa)
	{
	   //Create a simple plan to maintain 1 water scout.
	   if ((gWaterMap == true) || (gTransportMap == true))
		  createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);
	   //Random Age2 God.
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
		  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);

		  gAge4MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	}
	//Shennong
	else if (cMyCiv == cCivShennong)
	{
	   //Create a simple plan to maintain 1 water scout.
	   if ((gWaterMap == true) || (gTransportMap == true))
		  createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);
	   //Random Age2 God.
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
		  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);

		  gAge4MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	}
	if(cvAge2GodChoice != -1)
		gAge2MinorGod = cvAge2GodChoice;
	if(cvAge3GodChoice != -1)
		gAge3MinorGod = cvAge3GodChoice;
	if(cvAge4GodChoice != -1)
		gAge4MinorGod = cvAge4GodChoice;
	   
	xsEnableRule("chooseGardenResource");
}

//==============================================================================
// norseInfantryCheck
//==============================================================================
rule norseInfantryCheck
   minInterval 10
   inactive
   group Norse
{
   //Get a count of our ulfsarks.
   int ulfCount=kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive);
   if (ulfCount > 1)	 
	  return;

   if (xsGetTime() < 90000)
	  return;   // Don't do it in first 90 seconds

   //If we're low on infantry, make sure we have at least X pop slots free.
   int availablePopSlots=kbGetPopCap()-kbGetPop();
   if (availablePopSlots >= 3)  // Room for current vil-in-training and ulfsark
	  return;

   //Else, find a villager to delete.
   //Create/get our query.
   static int vQID=-1;
   if (vQID < 0)
   {
	  vQID=kbUnitQueryCreate("NorseInfantryCheckVillagers");
	  if (vQID < 0)
	  {
		 xsDisableSelf();
		 return;
	  }
   }
	kbUnitQuerySetPlayerID(vQID, cMyID);
   kbUnitQuerySetUnitType(vQID, cUnitTypeAbstractVillager);
   kbUnitQuerySetState(vQID, cUnitStateAlive);
   kbUnitQueryResetResults(vQID);
	int numberVillagers=kbUnitQueryExecute(vQID);
   for (i=0; < numberVillagers)
   {
	  int villagerID=kbUnitQueryGetResult(vQID, i);
	  aiEcho("***** Deleting villager "+villagerID);
	  if (aiTaskUnitDelete(villagerID) == true)
	  {
		 availablePopSlots = availablePopSlots+1;
		 if (availablePopSlots >= 3)
			return;
	  }
   }
}

//==============================================================================
// initUnitPicker
//==============================================================================
int initUnitPicker(string name="BUG", int numberTypes=1, int minUnits=10,
   int maxUnits=20, int minPop=-1, int maxPop=-1, int numberBuildings=1,
   bool guessEnemyUnitType=false)
{
   //Create it.
   int upID=kbUnitPickCreate(name);
   if (upID < 0)
	  return(-1);

   //Default init.
   kbUnitPickResetAll(upID);
   //1 Part Preference, 2 Parts CE, 2 Parts Cost.  Testing 1/10/4
   kbUnitPickSetPreferenceWeight(upID, 2.0);
   kbUnitPickSetCombatEfficiencyWeight(upID, 4.0);
   kbUnitPickSetCostWeight(upID, 7.0);
   //Desired number units types, buildings.
   kbUnitPickSetDesiredNumberUnitTypes(upID, numberTypes, numberBuildings, true);
   //Min/Max units and Min/Max pop.
   kbUnitPickSetMinimumNumberUnits(upID, minUnits);
   kbUnitPickSetMaximumNumberUnits(upID, maxUnits);
   kbUnitPickSetMinimumPop(upID, minPop);
   kbUnitPickSetMaximumPop(upID, maxPop);
   //Default to land units.
   kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeLandMilitary);
   kbUnitPickSetGoalCombatEfficiencyType(upID, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);

   //Setup the military unit preferences.  These are just various strategies of unit
   //combos and what-not that are more or less setup to coincide with the bonuses
   //and mainline units of each civ.  We start with a random choice.  If we have
   //an enemy unit type to preference against, we override that random choice.
   //0:  Counter infantry (i.e. enemyUnitTypeID == cUnitTypeAbstractInfantry).
   //1:  Counter archer (i.e. enemyUnitTypeID == cUnitTypeAbstractArcher).
   //2:  Counter cavalry (i.e. enemyUnitTypeID == cUnitTypeAbstractCavalry).
   int upRand=aiRandInt(3);

   //Figure out what we're going to assume our opponent is building.
   int enemyUnitTypeID=-1;
   int mostHatedPlayerID=aiGetMostHatedPlayerID();
   if ((guessEnemyUnitType == true) && (mostHatedPlayerID > 0))
   {
	  //If the enemy is Norse, assume infantry.
	  //Zeus is infantry.
	  if ((kbGetCultureForPlayer(mostHatedPlayerID) == cCultureNorse) ||
		 (kbGetCivForPlayer(mostHatedPlayerID) == cCivZeus))
	  {
		 enemyUnitTypeID=cUnitTypeAbstractInfantry;
		 upRand=0;
		 aiEcho("Setting unit picker "+upID+" to counter infantry.");
	  }  
	  //Hades is archers.
	  else if (kbGetCivForPlayer(mostHatedPlayerID) == cCivHades)
	  {
		 enemyUnitTypeID=cUnitTypeAbstractArcher;
		 upRand=1;
		 aiEcho("Setting unit picker "+upID+" to counter archers.");
	  }
	  //Poseidon is cavalry.
	  else if (kbGetCivForPlayer(mostHatedPlayerID) == cCivPoseidon)
	  {
		 enemyUnitTypeID=cUnitTypeAbstractCavalry;
		 aiEcho("Setting unit picker "+upID+" to counter cavalry.");
		 upRand=2;
	  }
	  else
	  {
		 switch(upRand)
		 {
		 case 0:
			{
			   aiEcho("Randomly setting unit picker "+upID+" to counter infantry.");
			   break;
			}
		 case 1:
			{
			   aiEcho("Randomly setting unit picker "+upID+" to counter archers.");
			   break;
			}
		 case 2:
			{
			   aiEcho("Randomly setting unit picker "+upID+" to counter cavalry.");
			   break;
			}
		 }
	  }
   }



if (cvPrimaryMilitaryUnit == -1)	// Skip this whole thing otherwise
{
   aiEcho("Before switch, upRand is "+upRand);
   //Do the preference actual work now.
   switch (cMyCiv)
   {
	  //Zeus.
	  case cCivZeus:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);  // Was .5 vs. inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);	// Was .8 vs. archers
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);  // Was .2 vs. archers
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.8);  // Was .5 vs. archers
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);  // Was .1 vs. cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMedusa, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Poseidon.
	  case cCivPoseidon:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3);  // Was .9 vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.4);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Hades.
	  case cCivHades:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// Was .2 vs. inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);  // Was .9 vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);  // Was .4
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.8);	// Was .6
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);  // Was .6
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.4);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);  // Was .2 vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Isis.
	  case cCivIsis:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
		 }
		 break;
	  }
	  //Ra.
	  case cCivRa:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4);	// Was .2 
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3);  // Was .9 vs. inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);	// Was .4 vs archers
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);  // Was .5
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.8);	 // Was .5
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);   // Was .9 vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Set.
	  case cCivSet:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);  // Was .6 vs. cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);  // Was .3
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
		 }
		 break;
	  }
	  //Loki.
	  case cCivLoki:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Odin.
	  case cCivOdin:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Thor.
	  case cCivThor:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.3);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.9);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
		 }
		 break;
	  }
	  //Kronos, myth and siege higher
	  case cCivKronos:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);	// vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);	// vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 break;
	  }
	  //Ouranos, myth lower
	  case cCivOuranos:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);	// vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);	// vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
		 }
		 break;
	  }
	  //Gaia.
	  case cCivGaia:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);	// vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);	// vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 break;
	  }
	  //Fuxi copy of Kronos atm
	  case cCivFuxi:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);	// vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);	// vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 break;
	  }
	  //Ouranos copy of Ouranos
	  case cCivNuwa:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);	// vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);	// vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
		 }
		 break;
	  }
	  //Copy of Gaia
	  case cCivShennong:
	  {
		 if (upRand == 0)
		 {
			aiEcho("Executing case 0, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);	// vs inf
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else if (upRand == 1)
		 {
			aiEcho("Executing case 1, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);	// vs archer
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 else
		 {
			aiEcho("Executing case 2, upRand = "+upRand);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);	// vs cav
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
			kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
		 }
		 break;
	  }
   }
   kbUnitPickSetPreferenceFactor(upID, cUnitTypeDryad, 0.0);	  // This should *only* be produced through the hesperides rule
}  // End if / cvPrimaryMilitaryUnit


   if (cvNumberMilitaryUnitTypes >= 0)
   {  
	  kbUnitPickSetDesiredNumberUnitTypes(upID, cvNumberMilitaryUnitTypes, numberBuildings, true);
	  setMilitaryUnitPrefs(cvPrimaryMilitaryUnit, cvSecondaryMilitaryUnit, cvTertiaryMilitaryUnit);
   }

   //Done.
   return(upID);
}

//==============================================================================
// init( void )
//==============================================================================
void init(void)
{
	//aiEcho("Treaty time left: "+ kbGetTreatyTime());
   xsEnableRule("updateWoodBreakdown");
   xsEnableRule("updateFoodBreakdown");
   xsEnableRule("updateGoldBreakdown");
   //We're in a random map.
   aiSetRandomMap(true);
   if (cvRandomMapName == "None")
	  cvRandomMapName = cRandomMapName;

   //Adjust control variable sliders by random amount
   cvRushBoomSlider = (cvRushBoomSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvRushBoomSlider > 1.0) cvRushBoomSlider = 1.0;
   if (cvRushBoomSlider < -1.0) cvRushBoomSlider = -1.0;
   cvMilitaryEconSlider = (cvMilitaryEconSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvMilitaryEconSlider > 1.0) cvMilitaryEconSlider = 1.0;
   if (cvMilitaryEconSlider < -1.0) cvMilitaryEconSlider = -1.0;
   cvOffenseDefenseSlider = (cvOffenseDefenseSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvOffenseDefenseSlider > 1.0) cvOffenseDefenseSlider = 1.0;
   if (cvOffenseDefenseSlider < -1.0) cvOffenseDefenseSlider = -1.0;
   aiEcho("Sliders are...RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);

	

   //Startup messages.
   aiEcho("Init(): AI Player Name is "+cMyName+".");
   aiEcho("AI Filename='"+cFilename+"'.");
   aiEcho("Map size is ("+kbGetMapXSize()+", "+kbGetMapZSize()+").");
   aiEcho("MapName="+cvRandomMapName+".");
   aiEcho("FirstRand="+aiRandInt(10000000)+".");
   aiEcho("Civ="+kbGetCivName(cMyCiv)+".");
   aiEcho("Culture="+kbGetCultureName(cMyCulture)+".");
   aiEcho("DifficultyLevel="+aiGetWorldDifficultyName(aiGetWorldDifficulty())+".");
   aiEcho("Personality="+aiGetPersonality()+".");
   aiEcho("Game mode is "+aiGetGameMode());

	if(aiGetGameMode() == cGameModeTreaty)
	{
		// Set our Treaty attack transition time
		// Atleast 2 mins
		int transitionTime = 120;
		// Rushes want more transition time, boomers want less
		transitionTime = transitionTime + (cvRushBoomSlider*60);
		// Mil wants more time, econ wants less
		transitionTime = transitionTime + (cvMilitaryEconSlider*40);
		// Offense wants more time, defense wants less
		transitionTime = transitionTime + (cvOffenseDefenseSlider*40);
		aiEcho("Transition time: + " + transitionTime);
		SetTreatyTransitionTime(transitionTime);
	}
   //Decide if we have a water map - is it good for fishing?
   if ((cvRandomMapName == "mediterranean") ||
	  (cvRandomMapName == "midgard") ||
	  (cvRandomMapName == "archipelago") ||
	  (cvRandomMapName == "river nile") ||
	  (cvRandomMapName == "vinlandsaga") ||
	  (cvRandomMapName == "islands") ||   
	  (cvRandomMapName == "anatolia") ||
	  (cvRandomMapName == "team migration") ||
	  (cvRandomMapName == "black sea") ||
	  (cvRandomMapName == "river styx") ||  // No fish
	  (cvRandomMapName == "sea of worms") ||
	  (cvRandomMapName == "sudden death") ||
	  (cvRandomMapName == "Yellow River") ||
	  (cvWaterMap == true) )	 // If the loader file already set it, keep it.
   {
	  gWaterMap=true;
	  aiEcho("This is a water map.");
	  xsEnableRule("fishing");
   }

   // In any case, scale down fishing to match difficulty
   if (aiGetWorldDifficulty() == cDifficultyEasy)
	  gNumBoatsToMaintain = 2;
   if (aiGetWorldDifficulty() == cDifficultyModerate)
	  gNumBoatsToMaintain = 4;


   
   //Decide if we have a transport-needed map.
   if ((cvRandomMapName == "archipelago") ||
	  (cvRandomMapName == "river nile") ||
	  (cvRandomMapName == "vinlandsaga") ||
	  (cvRandomMapName == "team migration") ||
	  (cvRandomMapName == "black sea") ||
	  (cvRandomMapName == "river styx") ||
	  (cvRandomMapName == "highland") ||
	  (cvRandomMapName == "islands") ||   
	  (cvRandomMapName == "sudden death") ||
	  (cvRandomMapName == "mediterranean") ||
	  (cvRandomMapName == "None") ||				// If we don't know, prepare to make transports
	  (cvRandomMapName == "the unknown") ||
	  (cvRandomMapName == "land unknown") ||
	  (cvRandomMapName == "Yellow River") ||
	  (cvTransportMap == true) )
   {
	  gTransportMap=true;
	  aiEcho("This may be a transport-needed map.");
	  //Tell the AI that this map is valid for transporting
	  aiSetWaterMap(gWaterMap);
   }


   //Find someone to hate.
   if (cvPlayerToAttack < 1)
	  updatePlayerToAttack();
   else
	  aiSetMostHatedPlayerID(cvPlayerToAttack);
   aiEcho("MostHatedPlayer is Player #"+aiGetMostHatedPlayerID()+".");

   //Bind our age handlers.
   aiSetAgeEventHandler(cAge2, "age2Handler");
   aiSetAgeEventHandler(cAge3, "age3Handler");
   aiSetAgeEventHandler(cAge4, "age4Handler");
   // Something new.. an Age5 handler..
   aiSetAgeEventHandler(cAge5, "age5Handler");

   if (cvMaxAge <= kbGetAge())  // Are we starting at or beyond our max age?
   {
	  aiEcho("Suspending age upgrades.");
	  aiSetPauseAllAgeUpgrades(true);
   }

   //Setup god power handler
   aiSetGodPowerEventHandler("gpHandler");
   //Setup build handler
   aiSetBuildEventHandler("buildHandler");
   //Setup the wonder handler
   aiSetWonderDeathEventHandler("wonderDeathHandler");
   //Setup the retreat handler
   aiSetRetreatEventHandler("retreatHandler");
   //Setup the relic handler
   aiSetRelicEventHandler("relicHandler");
	//Setup the resign handler
   aiSetResignEventHandler("resignHandler");


   //Set our town location.
   setTownLocation();

   //Economy.
   initEcon();
   //Progress.
   initProgress();
   //God Powers
   initGodPowers();


   //Various map overrides.
   //Erebus and River Styx.
   if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
   {
	  aiSetMinNumberNeedForGatheringAggressvies(2);
	  kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 85.0);
   }
   //Vinlandsaga.
   if ((cvRandomMapName == "vinlandsaga") || (cvRandomMapName == "team migration"))
   {
	  //Enable the rule that looks for the mainland.
	  xsEnableRule("findVinlandsagaBase");
	  //Turn off auto dropsite building.
	  aiSetAllowAutoDropsites(false);
	  aiSetAllowBuildings(false);

	  // Move the transport toward map center to find continent quickly.
	  int transportID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
	  vector nearCenter = kbGetMapCenter();
	  nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;   // Halfway between start and center
	  nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
	  aiTaskUnitMove(transportID, nearCenter);
	  aiEcho("Sending transport "+transportID+" to near map center at "+nearCenter);
	  xsEnableRule("vinlandsagaFailsafe");  // In case something prevents transport from reaching, turn on the explore plan.
	  //Turn off fishing.
	  xsDisableRule("fishing");
	  //Pause the age upgrades.
	  aiSetPauseAllAgeUpgrades(true);
   }
   //Nomad.
   else if (cvRandomMapName == "nomad")
   {
	  xsEnableRule("nomadSearchMode");

   }
   //Unknown, or unspecified
   else if ((cvRandomMapName == "the unknown") || (cvRandomMapName == "None") )
   {
	  xsEnableRule("findFish");
   }
   //Make a scout plan to find the plenty vault/
   else if (cvRandomMapName == "king of the hill")
   {
	  aiEcho("looking for KOTH plenty Vault");
	  int KOTHunitQueryID = kbUnitQueryCreate("findPlentyVault");
	  kbUnitQuerySetPlayerRelation(KOTHunitQueryID, cPlayerRelationAny);
	  kbUnitQuerySetUnitType(KOTHunitQueryID, cUnitTypePlentyVaultKOTH);
	  kbUnitQuerySetState(KOTHunitQueryID, cUnitStateAny);
	   kbUnitQueryResetResults(KOTHunitQueryID);
	   int numberFound = kbUnitQueryExecute(KOTHunitQueryID);
	  gKOTHPlentyUnitID = kbUnitQueryGetResult(KOTHunitQueryID, 0);
	  kbSetForwardBasePosition(kbUnitGetPosition(gKOTHPlentyUnitID));

	  xsEnableRule("findFish");
   }


   //Create bases for all of our settlements.  Ignore any that already have
   //bases set.  If we have an invalid main base, the first base we create
   //will be our main base.
   int settlementQueryID=kbUnitQueryCreate("MySettlements");
   if (settlementQueryID > -1)
   {
		kbUnitQuerySetPlayerID(settlementQueryID, cMyID);
	  kbUnitQuerySetUnitType(settlementQueryID, cUnitTypeAbstractSettlement);
	  kbUnitQuerySetState(settlementQueryID, cUnitStateAlive);
	  kbUnitQueryResetResults(settlementQueryID);
	   int numberSettlements=kbUnitQueryExecute(settlementQueryID);
	  for(i=0; < numberSettlements)
	  {
		 int settlementID=kbUnitQueryGetResult(settlementQueryID, i);
		 //Skip this settlement if it already has a base.
		 if (kbUnitGetBaseID(settlementID) >= 0)
			continue;

		 vector settlementPosition=kbUnitGetPosition(settlementID);
		 //Create a new base.
		 int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), settlementPosition, 75.0);
		 if (newBaseID > -1)
		 {
			//Figure out the front vector.
			vector baseFront=xsVectorNormalize(kbGetMapCenter()-settlementPosition);
			kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
			//Military gather point.
			vector militaryGatherPoint=settlementPosition+baseFront*40.0;
			kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
			//Set the other flags.
			kbBaseSetMilitary(cMyID, newBaseID, true);
			kbBaseSetEconomy(cMyID, newBaseID, true);
			//Set the resource distance limit.
			kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
			//Add the settlement to the base.
			kbBaseAddUnit(cMyID, newBaseID, settlementID);
			kbBaseSetSettlement(cMyID, newBaseID, true);
			//Set the main-ness of the base.
			kbBaseSetMain(cMyID, newBaseID, true);
		 }
	  }
   }


   //Culture setup.
   switch (cMyCulture)
   {
	  case cCultureGreek:
	  {
		 initGreek();
		 break;
	  }
	  case cCultureEgyptian:
	  {
		 initEgyptian();
		 break;
	  }
	  case cCultureNorse:
	  {
		 initNorse();
		 break;
	  }
	  case cCultureAtlantean:
	  {
		 initAtlantean();
		 break;
	  }
	 case cCultureChinese:
	 {
		 initChinese();
		 break;
	 }
   }
   //Setup the progression to follow these minor gods.
   kbTechTreeAddMinorGodPref(gAge2MinorGod);
   kbTechTreeAddMinorGodPref(gAge3MinorGod);
   kbTechTreeAddMinorGodPref(gAge4MinorGod);
   aiEcho("Minor god plan is "+kbGetTechName(gAge2MinorGod)+", "+kbGetTechName(gAge3MinorGod)+", "+kbGetTechName(gAge4MinorGod));

   //Set the Explore Danger Threshold.
   aiSetExploreDangerThreshold(300.0);
   //Auto gather our military units.
   aiSetAutoGatherMilitaryUnits(true);

   //Get our house build limit.
   gHouseBuildLimit=kbGetBuildLimit(cMyID, cUnitTypeHouse);
   if (cMyCulture == cCultureAtlantean)
	  gHouseBuildLimit = kbGetBuildLimit(cMyID, cUnitTypeManor);
   //Set the housing rebuild bound to 4 for the first age.
   gHouseAvailablePopRebuild=4;
   if (cMyCulture == cCultureEgyptian)
	  gHouseAvailablePopRebuild=8;
   if (cMyCulture == cCultureAtlantean)
	  gHouseAvailablePopRebuild=8;

   //Set the hard pop caps.
   if (aiGetGameMode() == cGameModeLightning)
   {
	  gHardEconomyPopCap=35;
	  //If we're Norse, get our 5 dwarfs.
	  if (cMyCulture == cCultureNorse)
		 createSimpleMaintainPlan(cUnitTypeDwarf, 5, true, -1);
   }
   else if (aiGetGameMode() == cGameModeDeathmatch)
	  gHardEconomyPopCap=5;   // Essentially shut off vill production until age 4.
   else
   {
	  if (aiGetWorldDifficulty() == cDifficultyEasy)
		 gHardEconomyPopCap=20;
	  else if (aiGetWorldDifficulty() == cDifficultyModerate)
		 gHardEconomyPopCap=40;
	  else
		 gHardEconomyPopCap=-1;
   }

   //Set the default attack response distance.
   if (aiGetWorldDifficulty() == cDifficultyEasy)
	  aiSetAttackResponseDistance(15.0);// Increased to 15 as 1 is retarded
   else if (aiGetWorldDifficulty() == cDifficultyModerate)
	  aiSetAttackResponseDistance(30.0);
   else
	  aiSetAttackResponseDistance(65.0);



   if ( (cvOffenseDefenseSlider < 0.0) && (cvRandomMapName != "vinlandsaga") &&
									  (cvRandomMapName != "team migration") )
   {
	  // Consider walling if we're defensive and the map doesn't make walling look stupid.
	  float wallOdds = -1.0 * cvOffenseDefenseSlider;   // Now 1 for defense, -1 for offense
	  wallOdds = wallOdds - 0.2;					// -1.2 to +.8, must be 20% or more defensive
	  if (wallOdds < 0)
		 wallOdds = 0;  // Now 0 to .8;
	  wallOdds = wallOdds * 100;				   // 0 to 80
	  if (cMyCulture == cCultureNorse)
		 wallOdds = wallOdds / 2;
	  if (cMyCulture == cCultureEgyptian)
		 wallOdds = wallOdds * 1.5; 
	  aiEcho("Wall odds: "+wallOdds);
	  int result = aiRandInt(101) -1;   //-1..+99
	  // i.e. 80% chance for cvOffDef at -1.0, and linear odds from 
	  // 0 at cvOffDef 0.2 and below to 80% at -1.0
	  // Net result:  Defensive often wall, offensive never do.
	  if ( result < wallOdds )  
		 gBuildWalls = true;
	  if ( (cvOkToBuildWalls == false) || (aiGetGameMode() ==cGameModeDeathmatch))
		 gBuildWalls = false;
	  if (gBuildWalls == true)
	  {
		 xsEnableRule("wallUpgrade");
		 aiEcho("Decided to build walls.");
	  }
   }

   if ( cvOffenseDefenseSlider < 0.4 )   
   {
	  // Consider towering if we're not extremely offenseive.
	  float towerOdds = -1.0 * cvOffenseDefenseSlider;  // Now 1 for def, -1 for off
	  towerOdds = towerOdds + 0.4;   // Now -.6 to 1.4
	  if (towerOdds < 0.0)
		 towerOdds = 0.0;   // Now 0 - 1.4, won't be considered if more than 40% offensive
			
	  towerOdds = (towerOdds * 100.0);   // Now 0.0 - 140.0, numbers over 100 guarantee towering

	  result = -1;
	  result = aiRandInt(101) -1;   //-1..99
	  // i.e. 100% chance for cvOffenseDefenseSlider below -.6, and linear odds from 
	  // 0% at cvOffenseDefenseSlider +.4 to 100% at -0.6
	  // Net result:  Heavy defenders always tower, lite defenders usually do, mildly aggressives sometimes do.
	  aiEcho("Tower odds: "+towerOdds);
	  if ( result < towerOdds )  
	  {
		 gBuildTowers = true;
		 gTargetNumTowers = towerOdds/10;   // Up to 14 for a mil/econ balanced player
		 gTargetNumTowers = gTargetNumTowers * (1+(cvMilitaryEconSlider/2));  // +/- 50% based on mil/econ
		if ( gBuildWalls == true)
			gTargetNumTowers = gTargetNumTowers / 2;	 // Halve the towers if we're doing walls
		if ( aiGetWorldDifficulty() == cDifficultyEasy )
		   gTargetNumTowers = gTargetNumTowers / 2;   // Not so many on easy
	  }
	  if ( (cvOffenseDefenseSlider < 0.6) && (gBuildTowers == false) )  // If we're not totally offensive, get upgrades
	  {
		 gBuildTowers = true;
		 gTargetNumTowers = 0;   // Just do some upgrades
	  }
	  if (cvOkToBuildTowers == false)
	  {
		 gBuildTowers = false;
		 gTargetNumTowers = 0;
	  }
	  aiEcho("Decided to build "+gTargetNumTowers+" towers.");
   }


   //If we're on easy, set our default stance to defensive.
   if (aiGetWorldDifficulty() == cDifficultyEasy)   
	  aiSetDefaultStance(cUnitStanceDefensive);

   
   //Decide whether or not we're doing a rush/raid.
   // Rushers will use a smaller econ to age up faster, send more waves and larger waves.
   // Boomers will use a larger econ, hit age 2 later, make smaller armies, and send zero or few waves, hitting age 3 much sooner.

   int rushCount=0;
   if (cvRushBoomSlider > -0.5) 
	  rushCount = 1;	// Rushcount acts as a bool for the moment.  Rush unless strong boomer.


   int rushSize=70;   // Total pop to use in rush armies.
   rushSize = rushSize + (cvRushBoomSlider*(rushSize*0.6)); // Increase/decrease the size up to 60% for rushing 
   if (cvOffenseDefenseSlider > 0)
	  rushSize = rushSize + (cvOffenseDefenseSlider*(rushSize*0.6)); // Increase the size up to 60% for offense 

   if (aiGetWorldDifficulty() == cDifficultyModerate)   // Take it easy on moderate
	  rushSize = rushSize/2;
 

   if (aiGetWorldDifficulty() == cDifficultyEasy)  // Never rush on easy
   {
	  rushCount = 0;
	  rushSize = 10;
   }

   if (aiGetGameMode() == cGameModeDeathmatch)   // Never rush in DM
	  rushCount = 0;

   if ((cvRandomMapName == "king of the hill") && (rushCount < 2))
	  rushCount = 1;							   // Always rush in KotH, even on easy.

   //Specific maps prevent rushing.
   if ((cvRandomMapName == "vinlandsaga") ||
	  (cvRandomMapName == "river nile") ||
	  (cvRandomMapName == "team migration") ||
	  (cvRandomMapName == "archipelago") ||
	  (cvRandomMapName == "black sea") ||
	  (cvRandomMapName == "river styx"))
	  rushCount=0;  

   if ( (gBuildWalls == true) && (rushCount > 0) )
   {	 // Knock up to 40 pop slots off plan
	  if (rushSize > 80)
		 rushSize = rushSize - 40;
	  else
		 rushSize = rushSize/2;
   }


   if ( (gTargetNumTowers > 0) && (rushCount > 0) )   // Remove 2 pop slots for each tower's cost
   {
	  int reduce = 2*gTargetNumTowers;
	  if (rushSize < reduce)
		 rushSize = 0;
	  else
		 rushSize = rushSize - reduce;
   }


   int numTypes = 2;
   if (rushSize < 40)
	  numTypes = 1;  // Were doing a few or no rushes of small size, just make 1 unit type

   // Finally, adjust rushSize to the per-wave number we need
   if (rushCount > 0)
   {
	  rushCount = (rushSize+20)/40;   // +20 to round to closest value
	  rushSize = rushSize / rushCount;
   }

   if (rushSize > 50)
	  rushSize = 50;

   if ( (rushCount > 0) && (rushSize < 20) )
	  rushSize = 20;	// anything less isn't worth sending

   if (rushSize < 5)
	  rushSize = 5;  // Give unitpicker something to do...

   if (cMyCulture == cCultureEgyptian)
	  gRushUPID=initUnitPicker("Rush", numTypes, -1, -1, rushSize, rushSize*1.25, 3, true);  // 3 buildings if egyptian
   else
	  gRushUPID=initUnitPicker("Rush", numTypes, -1, -1, rushSize, rushSize*1.25, 2, true); // Rush with rushSize pop slots of two types, 2 buildings, do guess enemy unit type

   aiEcho("Setting rush unit picker for "+rushCount+" rushes with "+rushSize+" pop slots used.");

   // Set a smaller number for first wave.
   int newRushSize = 0;
   newRushSize = rushSize;
   if (rushCount >= 3)
	  newRushSize = rushSize/3;
   if (rushCount == 2)
	  newRushSize = rushSize/2;
   if (newRushSize != rushSize)
   {
	  kbUnitPickSetMinimumPop(gRushUPID, newRushSize);
	  aiEcho("Initial attack wave will use "+newRushSize+" pop slots.");
   }


/*   int forwardBaseGoalID=-1;
	  
	  //If we're rushing, decide if we want to build a forward base.
	  if (rushCount > 0)
	  {
		 if ((aiGetPersonality() == "defaultrush") || ((aiGetPersonality() == "default") && (aiRandInt(5) == 0)) )   // 20% chance of forward base in default.
			forwardBaseGoalID=createBaseGoal("Forward Base", cGoalPlanGoalTypeForwardBase, -1, 1, 1, -1, kbBaseGetMainID(cMyID));
	  }
*/

	  //Create our UP.
	  if (gRushUPID >= 0)
	  {
		 //No myth units in the second age.
		 //kbUnitPickSetPreferenceFactor(gRushUPID, cUnitTypeMythUnit, 0.0);
		 //Reset a few of the UP parms.
		 kbUnitPickSetPreferenceWeight(gRushUPID, 2.0);
		 kbUnitPickSetCombatEfficiencyWeight(gRushUPID, 4.0);
		 kbUnitPickSetCostWeight(gRushUPID, 7.0);
		 //Setup the retreat to only be allowed on non-transport maps.
		 bool allowRetreat = true;
		 if ((gTransportMap == true) || (cvRandomMapName == "king of the hill"))
			allowRetreat = false;
		 if (allowRetreat == true)  // i.e., if it's permitted
		 {
			int oddsOfRetreat = -50 * cvOffenseDefenseSlider; // 50 for totally defensive, 0 for neutral or aggressive
			if (aiRandInt(101) > oddsOfRetreat)
			   allowRetreat = false;
		 }
		 //Create the rush goal if we're rushing.
		 if (rushCount > 0)  // Deleted conditions that suppress rushing if we're walling or towering...OK to do some of each.
		 {
			//Create the attack.
			aiEcho("Creating rush goal and idle goal");
			gRushGoalID=createSimpleAttackGoal("Rush Land Attack", -1, gRushUPID, rushCount+1, 1, 1, kbBaseGetMainID(cMyID), allowRetreat);
			//-- attach a callbackgoal to this rush goal
			if (gRushGoalID > 0)
			{
			   //Go for hitpoint upgrade first.
			   aiPlanSetVariableInt(gRushGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
			   //Set the callback.
			   int callbackGID=createCallbackGoal("Attack Callback", "attackChatCallback",1, 0, 2, false);
			   if (callbackGID >= 0)
				  aiPlanSetVariableInt(gRushGoalID, cGoalPlanExecuteGoal, 0, callbackGID);
			   //Create an idle attack goal that will maintain our military until the next age after
			   //we're done rushing.
			   gIdleAttackGID=createSimpleAttackGoal("Rush Idle", -1, gRushUPID, -1, 1, 1, -1, allowRetreat);
			   if (gIdleAttackGID >= 0)
			   {
				  aiPlanSetVariableBool(gIdleAttackGID, cGoalPlanIdleAttack, 0, true);
				  aiPlanSetVariableBool(gIdleAttackGID, cGoalPlanAutoUpdateState, 0, false);
				  aiPlanSetVariableInt(gRushGoalID, cGoalPlanDoneGoal, 0, gIdleAttackGID);
				  aiPlanSetVariableInt(gIdleAttackGID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
			   }
			}
		 }
		 //Else, if we're not on Moderate and we're not attacking, create some military anyway.
		 else if (aiGetWorldDifficulty() != cDifficultyModerate)
		 {
			aiEcho("Just creating idle goal, no rush");
			//Create an idle attack goal that will maintain our military until the next age.
			gIdleAttackGID=createSimpleAttackGoal("Idle Force", -1, gRushUPID, -1, 1, 1, -1, allowRetreat);
			if (gIdleAttackGID >= 0)
			{
			   aiPlanSetVariableBool(gIdleAttackGID, cGoalPlanIdleAttack, 0, true);
			   //Go for hitpoint upgrades.
			   aiPlanSetVariableInt(gIdleAttackGID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
			   //Reset the rushUPID down to 1 unit type and 1 building.
			   kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, 1, 1, true);
			}
		 }
	  }

	  //If our rush count is 0, enable the rule that monitors our main base
	  //for being under attack before we're ready.
	  if (rushCount <= 0)
		 xsEnableRule("townDefense");

   //Create our late age attack goal.
   if (cvRandomMapName == "king of the hill")
	  gNumberBuildings=1;
   if (aiGetWorldDifficulty() == cDifficultyEasy)
	  gLateUPID=initUnitPicker("Late", 1, -1, -1, 8, 16, gNumberBuildings, false);
   else if (aiGetWorldDifficulty() == cDifficultyModerate)
   {
	  int minPop=20+aiRandInt(14);
	  int maxPop=minPop+16;
	  //If we're on KOTH, make the attack groups smaller.
	  if (cvRandomMapName == "king of the hill")
	  {
		 minPop=minPop-10;
		 maxPop=maxPop-10;
	  }
	  if ( aiGetGameMode() != cGameModeDeathmatch )
		 gLateUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, gNumberBuildings, false);   // Attack with at least 20-33 pop slots, no more than 36-49.
	  else  // DM, double number of buildings
		 gLateUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, 2*gNumberBuildings, false);   // Attack with at least 20-33 pop slots, no more than 36-49.
   }
   else
   {
	  minPop=40+aiRandInt(20);
	  maxPop=70;
	  if (aiGetWorldDifficulty() > cDifficultyHard)
		 maxPop = 90;
	  //If we're on KOTH, make the attack groups smaller.
	  if (cvRandomMapName == "king of the hill")
	  {
		 minPop=minPop-16;
		 maxPop=maxPop-16;
	  }
	  if ( aiGetGameMode() != cGameModeDeathmatch )
		 gLateUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, gNumberBuildings, true);   // Min: 40-59, max 70 pop slots
	  else  // Double buildings in DM
		 gLateUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, 2*gNumberBuildings, true); // Min: 40-59, max 70 pop slots
   }
   int lateAttackAge=2;
   if (gLateUPID >= 0)
   {
	  if (aiGetGameMode() == cGameModeDeathmatch)
		 lateAttackAge=3;

	  gLandAttackGoalID=createSimpleAttackGoal("Main Land Attack", -1, gLateUPID, -1, lateAttackAge, -1, kbBaseGetMainID(cMyID), false);

	  //-- attach a callbackgoal to this attack goal
	  if (gLandAttackGoalID >= 0)
	  {
		 //If this is easy, this is an idle attack.
		 if (aiGetWorldDifficulty() == cDifficultyEasy)
			aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, true);
		 else
		 {
			callbackGID=createCallbackGoal("Attack Callback", "attackChatCallback", 1, 0, lateAttackAge, false);
			if (callbackGID >= 0)
			   aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanExecuteGoal, 0, callbackGID);
		 }

		 aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
	  }
   }

   //Create our naval attack starter if we're on a water map.
   if ((gWaterMap == true) || (gTransportMap == true))
	  xsEnableRule("NavalGoalMonitor");

   //If we're going to build walls and we're not rushing, we have a 50% chance to build a wonder.
   if ((aiGetGameMode() == cGameModeSupremacy) && (gBuildWalls == true) &&
	  (rushCount == 0) && (aiRandInt(2) == 0))
   {
	  //-- reserve some building space in the base for the wonder.
	  int wonderBPID = kbBuildingPlacementCreate( "WonderBP" );
	  if(wonderBPID != -1)
	  {
		 kbBuildingPlacementSetBuildingType( cUnitTypeWonder );
		 kbBuildingPlacementSetBaseID( kbBaseGetMainID(cMyID), cBuildingPlacementPreferenceBack );
		 kbBuildingPlacementStart();
	  }
	  
	  createBuildBuildingGoal("Wonder Goal", cUnitTypeWonder, 1, 3, 4, kbBaseGetMainID(cMyID),
		 50, cUnitTypeAbstractVillager, true, 100, wonderBPID);
   }


   //Create our econ goal (which is really just to store stuff together).
   gGatherGoalPlanID=aiPlanCreate("GatherGoals", cPlanGatherGoal);
   if (gGatherGoalPlanID >= 0)
   {
	  //Overall percentages.
	  aiPlanSetDesiredPriority(gGatherGoalPlanID, 90);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 0.0);
	  aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanGathererPct, 4, true);
	  //Egyptians like gold.
	  if (cMyCulture == cCultureEgyptian)
	  {
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.0);
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.0);
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, 1.00);
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, 0.0);
		 if ((cvRandomMapName == "vinlandsaga") || (cvRandomMapName == "team migration"))
		 {
			aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.10);
			aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.15);
		 }
	  }
	  else
	  {
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.0);
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.0);
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, 1.0);
		 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, 0.0);
	  }

	  //Standard RB setup.
	  aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, 5, true);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 1);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, 0);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 0);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, 0);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, 0);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, 0);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 0);
	  //Hunt on Erebus and River Styx.
	  if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
	  {
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 2);
	  }

	  //Min resource amounts.
	  aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, 4, true);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceGold, 500.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceWood, 500.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceFood, 500.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceFavor, 50.0);
	  //Resource skew.
	  aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, 4, true);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceGold, 1000.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceWood, 1000.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceFood, 1000.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceFavor, 100.0);
	  //Cost weights.
	  aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, 4, true);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold, 1.5);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood, 1.0);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood, 1.5);
	  aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor, 10.0);

	  //Set our farm limits.
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0, 20);  //  Up from 4
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanMaxFarmLimit, 0, 40);   //  Up from 24
	  aiSetFarmLimit(aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0));
	  //Do our late econ init.
	  postInitEcon();
	  //Lastly, update our EM.
	  updateEMAge1();
   }

   if ( (aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning) )  // Add an emergency temple, and 10 houses)
   {
	  if (cMyCulture == cCultureAtlantean)
	  {
		 createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
		 if (aiGetGameMode() == cGameModeDeathmatch)
			createSimpleBuildPlan(cUnitTypeManor, 2, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  }
	  else
	  {
		 createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 3);
		 if (aiGetGameMode() == cGameModeDeathmatch)
			createSimpleBuildPlan(cUnitTypeHouse, 4, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  }
   } 

   if (cMyCulture == cCultureAtlantean)
	  {
		 createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  }

   setOverrides();  // Allow the loader to override anything it needs to.
}



rule nomadSearchMode
inactive
minInterval 1
{
	  //Enable the rule that looks for a settlement.
/*
	  int nomadSettlementGoalID=createBuildSettlementGoal("BuildNomadSettlement", 0, -1, -1, 1,
		 kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0), true, 100);
	  if (nomadSettlementGoalID != -1)
	  {
		 //Create the callback goal.
		 int nomadCallbackGID=createCallbackGoal("Nomad BuildSettlement Callback", "nomadBuildSettlementCallBack", 1, 0, -1, false);
		 if (nomadCallbackGID >= 0)
			aiPlanSetVariableInt(nomadSettlementGoalID, cGoalPlanDoneGoal, 0, nomadCallbackGID);
	  }
*/
	  //Make plans to explore with the initial villagers and goats.
	  aiEcho("Making nomad explore plans.");
	   gNomadExplorePlanID1=aiPlanCreate("Nomad Explore 1", cPlanExplore);
	   if (gNomadExplorePlanID1 >= 0)
	   {
		   if(cMyCulture == cCultureChinese)
		   {
			 aiPlanAddUnitType(gNomadExplorePlanID1, cUnitTypeVillagerChinese, 1, 1, 1);
		   }
		   else
		 aiPlanAddUnitType(gNomadExplorePlanID1, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
		   aiPlanSetDesiredPriority(gNomadExplorePlanID1, 90);
		 aiPlanSetVariableBool(gNomadExplorePlanID1, cExplorePlanDoLoops, 0, false);
		 aiPlanSetActive(gNomadExplorePlanID1);
		 aiPlanSetEscrowID(gNomadExplorePlanID1);
	   }
	   gNomadExplorePlanID2=aiPlanCreate("Nomad Explore 2", cPlanExplore);
	   if (gNomadExplorePlanID2 >= 0)
	   {
		   if(cMyCulture == cCultureChinese)
		   {
			 aiPlanAddUnitType(gNomadExplorePlanID2, cUnitTypeVillagerChinese, 1, 1, 1);
		   }
		   else
		 aiPlanAddUnitType(gNomadExplorePlanID2, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
		   aiPlanSetDesiredPriority(gNomadExplorePlanID2, 90);
		 aiPlanSetVariableBool(gNomadExplorePlanID2, cExplorePlanDoLoops, 0, false);
		 aiPlanSetActive(gNomadExplorePlanID2);
		 aiPlanSetEscrowID(gNomadExplorePlanID2);
	   }
	  gNomadExplorePlanID3=aiPlanCreate("Nomad Explore 3", cPlanExplore);
	   if (gNomadExplorePlanID3 >= 0)
	   {
		   if(cMyCulture == cCultureChinese)
		   {
			 aiPlanAddUnitType(gNomadExplorePlanID3, cUnitTypeVillagerChinese, 1, 2, 2);
		   }
		   else
		 aiPlanAddUnitType(gNomadExplorePlanID3, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 2, 2);   // Grab last Egyptian
		   aiPlanSetDesiredPriority(gNomadExplorePlanID3, 90);
		 aiPlanSetVariableBool(gNomadExplorePlanID3, cExplorePlanDoLoops, 0, false);
		 aiPlanSetActive(gNomadExplorePlanID3);
		 aiPlanSetEscrowID(gNomadExplorePlanID3);
	   }	  

	  //Turn off fishing.
	  xsDisableRule("fishing");
	  //Turn off buildhouse.
	  xsDisableRule("buildHouse");
	  //Pause the age upgrades.
	  //aiSetPauseAllAgeUpgrades(true);

	  xsDisableRule("earlySettlementTracker");  // Normal settlement-building rule

	  xsEnableRule("nomadBuildMode");
	  xsDisableSelf();
	  aiEcho("Enabling nomadBuildMode");

}


rule nomadBuildMode  // Go to build mode when a suitable settlement is found
inactive
minInterval 1
{
   int count = -1;   // How many settlements found?

   static int settlementQuery = -1; // All gaia settlements
   if (settlementQuery < 0)
   {
	  settlementQuery = kbUnitQueryCreate("Nomad Settlement");
	  kbUnitQuerySetPlayerID(settlementQuery, 0);
	  kbUnitQuerySetUnitType(settlementQuery, cUnitTypeAbstractSettlement);
   }

   static int builderQuery = -1;	  // All builders within 20 meters of a gaia settlement
   if (builderQuery < 0)
   {
	  builderQuery = kbUnitQueryCreate("Nomad Builder");
	  kbUnitQuerySetPlayerID(builderQuery, cMyID);
	  if(cMyCulture == cCultureChinese)
	  {
		  kbUnitQuerySetUnitType(builderQuery, cUnitTypeVillagerChinese);
	  }
	  else
	  kbUnitQuerySetUnitType(builderQuery, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
	  kbUnitQuerySetState(builderQuery, cUnitStateAlive);
	  kbUnitQuerySetMaximumDistance(builderQuery, 30.0);
	  kbUnitQuerySetAscendingSort(builderQuery, true);
   }  

   kbUnitQueryResetResults(settlementQuery);
   count = kbUnitQueryExecute(settlementQuery);
   if (count < 1)
	  return;   // No settlements seen, give up

   // Settlements seen, check if you have a builder close by
   aiEcho("Found "+count+" settlements.");
   int i = -1;
   int settlement = -1;
   int foundSettlement = -1;

   for (i=0; < count)
   {
	  settlement = kbUnitQueryGetResult(settlementQuery, i);
	  aiEcho("  Checking settlement "+settlement+" at "+kbUnitGetPosition(settlement));
	  kbUnitQuerySetPosition(builderQuery, kbUnitGetPosition(settlement));
	  kbUnitQueryResetResults(builderQuery);
	  if ( kbUnitQueryExecute(builderQuery) > 0)   // Builder nearby
	  {
		 foundSettlement = settlement;
		 aiEcho("   Builder found, we'll use "+settlement);
		 break;
	  }
	  aiEcho("  No builders nearby.");
   }
   
   // If we found a usable settlement, build on it.  Otherwise, keep this rule active
   if (foundSettlement < 0)
	  return;
   
   // We have one, let's use it and monitor for completion

   /*
   gNomadSettlementBuildPlanID=aiPlanCreate(name, cPlanGoal);
   if (gNomadSettlementBuildPlanID < 0)
	  return(-1);

   aiEcho("Configuring build goal.");


   //Goal Type.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuildSettlement);
   //Base ID.
   aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
   //Auto update.
   aiPlanSetVariableBool(gNomadSettlementBuildPlanID, cGoalPlanAutoUpdateState, 0, true);
   //Building Type ID.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanBuildingTypeID, 0, cUnitTypeAbstractSettlement);
   //Building Search ID.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanBuildingSearchID, 0, cUnitTypeAbstractSettlement);
   //Set the builder parms.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMinUnitNumber, 0, 1);
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMaxUnitNumber, 0, 3);
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanUnitTypeID, 0, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
   
   //Priority.
   aiPlanSetDesiredPriority(gNomadSettlementBuildPlanID, 100);
   //Ages.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMinAge, 0, 0);
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanMaxAge, 0, -1);
   //Repeat.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cGoalPlanRepeat, 0, -1);
   */
   aiEcho("Making main base.");
   int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), kbUnitGetPosition(settlement), 75.0);
   if (newBaseID > -1)
   {
	  //Figure out the front vector.
	  vector baseFront=xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(settlement));
	  kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
	  aiEcho("Setting front vector to "+baseFront);
	  //Military gather point.
	  vector militaryGatherPoint=kbUnitGetPosition(settlement)+baseFront*40.0;
	  kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
	  //Set the other flags.
	  kbBaseSetMilitary(cMyID, newBaseID, true);
	  kbBaseSetEconomy(cMyID, newBaseID, true);
	  //Set the resource distance limit.
	  kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
	  //Add the settlement to the base.
//  kbBaseAddUnit(cMyID, newBaseID, settlementID);
	  kbBaseSetSettlement(cMyID, newBaseID, true);
	  //Set the main-ness of the base.
	  kbBaseSetMain(cMyID, newBaseID, true);
   }
//EnableRule("buildSettlements");

   aiEcho("Main base is "+newBaseID+" "+kbBaseGetMainID(cMyID));

   aiEcho("Creating simple build plan");

	gNomadSettlementBuildPlanID=aiPlanCreate("Nomad settlement build", cPlanBuild);
   if (gNomadSettlementBuildPlanID < 0)
	  return;
   //Puid.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
   //Priority.
   aiPlanSetDesiredPriority(gNomadSettlementBuildPlanID, 100);
   //Mil vs. Econ.
   aiPlanSetMilitary(gNomadSettlementBuildPlanID, false);
   aiPlanSetEconomy(gNomadSettlementBuildPlanID, true);
   //Escrow.
   aiPlanSetEscrowID(gNomadSettlementBuildPlanID, cEconomyEscrowID);
   //Builders.
   if(cMyCulture == cCultureChinese)
   {
		aiPlanAddUnitType(gNomadSettlementBuildPlanID, cUnitTypeVillagerChinese, 4, 4, 4); 
   }
   else
	aiPlanAddUnitType(gNomadSettlementBuildPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 4, 4, 4);
   //Base ID.
   aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
   aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanCenterPosition, 0, kbUnitGetPosition(foundSettlement));
   aiPlanSetVariableFloat(gNomadSettlementBuildPlanID, cBuildPlanCenterPositionDistance, 0, 2.0);
//   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanFoundationID, 0, foundSettlement);
   aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanSettlementPlacementPoint, 0, kbUnitGetPosition(foundSettlement));
   //Go.
   aiPlanSetActive(gNomadSettlementBuildPlanID);


   aiEcho("Killing explore plans.");
   aiPlanDestroy(gNomadExplorePlanID1);
   aiPlanDestroy(gNomadExplorePlanID2);
   aiPlanDestroy(gNomadExplorePlanID3);

   xsEnableRule("nomadMonitor");
   xsDisableSelf();
   aiEcho("Activating nomad monitor rule");
}


rule nomadMonitor   // Watch the build goal.  When a settlement is up, turn on normal function.  If goal fails, restart.
inactive
minInterval 1
{
   if ( (aiPlanGetState(gNomadSettlementBuildPlanID) >= 0) && (aiPlanGetState(gNomadSettlementBuildPlanID) != cPlanStateDone) )
	  return;   // Plan exists, is not finished

   // plan is done or died.  Check if we have a settlement
   if (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0) // AliveOrBuilding in case state isn't updated instantly
   {  // We have a settlement, go normal
	  aiEcho("Settlement is finished, normal start.");
	  xsDisableSelf();
	  xsEnableRule("earlySettlementTracker");
	  //Turn on fishing.
	  xsEnableRule("fishing");	  
	  //Turn off buildhouse.
	  xsEnableRule("buildHouse");

	  int tc = findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement);
	  if ( tc >= 0)   
	  {

		 // Set main base
		 int oldMainBase = kbBaseGetMainID(cMyID);
		 aiEcho("Old main base was "+oldMainBase);
			aiEcho("Killing early gather plans.");
			aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, oldMainBase);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, oldMainBase);
			aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, oldMainBase);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, oldMainBase);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, oldMainBase);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, oldMainBase);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, oldMainBase);
			aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, -1);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, -1);
			aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, -1);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, -1);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, -1);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, -1);
			aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, -1);
			aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, -1);
			aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));

		 if ( kbUnitGetBaseID(tc) != oldMainBase )
		 {
			kbBaseDestroy(cMyID, oldMainBase);
			kbBaseSetMain(cMyID, kbUnitGetBaseID(tc),true);
		 }
		 aiEcho("TC is in base "+kbUnitGetBaseID(tc));
		 aiEcho("New main base is "+kbBaseGetMainID(cMyID));
		 vector front = cInvalidVector;
		 front = xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(tc));
		 kbBaseSetFrontVector(cMyID, kbBaseGetMainID(cMyID), front);
		 aiEcho("Front vector is "+front);
		 gFarmBaseID = kbBaseGetMainID(cMyID);
		 // Fix herdable plans
		  aiPlanDestroy(gHerdPlanID);
		 gHerdPlanID=aiPlanCreate("GatherHerdable Plan Nomad", cPlanHerd);
		 if (gHerdPlanID >= 0)
		 {
			aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
			aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingID, 0, tc);
			aiPlanSetActive(gHerdPlanID);
		 }
		 aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));
		 updateFoodBreakdown();

	  }




	  // Fix god power plan for age 1
	  aiPlanSetBaseID(gAge1GodPowerPlanID, kbBaseGetMainID(cMyID));



	  // force the temple soon
	  createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  //Unpause the age upgrades.
	  aiSetPauseAllAgeUpgrades(false);
	  //Unpause the pause kicker.
	  xsEnableRule("unPauseAge2");
	  xsSetRuleMinInterval("unPauseAge2", 15);

   }
   else
   {  // No settlement, restart chain
	  aiEcho("No settlement exists, restart nomad chain.");
	  xsEnableRule("nomadSearchMode");
	  xsDisableSelf();
   }
}

//==============================================================================
// Age 2 Handler
//==============================================================================
void age2Handler(int age=1)
{
   gLastAgeHandled = cAge2;
   aiEcho("I'm now in Age "+age+".");
   if (cvMaxAge == age)
   {
	  aiEcho("Suspending age upgrades.");
	  aiSetPauseAllAgeUpgrades(true);
   }

   //xsEnableRule("expandGatherPlans");
   xsEnableRule("defendPlanRule");

   //Econ.
   econAge2Handler(age);
   //Progress.
   progressAge2Handler(age);
   //GP.
   gpAge2Handler(age);
   aiEcho("  Done with misc handlers.");

   //Set the housing rebuild bound.
   gHouseAvailablePopRebuild=20;
   if (cMyCulture == cCultureEgyptian)
	  gHouseAvailablePopRebuild=30;
   if (cMyCulture == cCultureAtlantean)
	  gHouseAvailablePopRebuild=30;

   //Switch the EM rule.
   xsDisableRule("updateEMAge1");
   xsEnableRule("updateEMAge2");
   updateEMAge2();  // Make it run right now

   //Enable building repair.
   if (aiGetWorldDifficulty() != cDifficultyEasy)
	  xsEnableRule("repairBuildings");

   //Misc Econ.
   if (gGatherGoalPlanID >= 0)
   {
	  //Greeks need favor.
	  if (cMyCulture == cCultureGreek)
	  {
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 1);
		 aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 40, 1.0, kbBaseGetMainID(cMyID));
	  }
   }

   //If we're building towers, do that.  
   if (gBuildTowers == true)
	  towerInBase("Age2TowerBuild", false, gTargetNumTowers/(2.0 + (-1.0*cvRushBoomSlider)), cMilitaryEscrowID);	 // If rusher, all now, if boomer, 1/3 now

   //Maintain a water transport, if this is a transport map.
   if ((gTransportMap == true) && (gMaintainWaterXPortPlanID < 0))
   {
		// Make sure we have a dock
		if(kbUnitCount(cMyID,cUnitTypeDock) == 0)
		{
			int areaID	= kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
			int buildDock = aiPlanCreate("BuildDock", cPlanBuild);
			if (buildDock >= 0)
			{
			   aiEcho("Building dock for scouting.");
			   //BP Type and Priority.
			   aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
			   aiPlanSetDesiredPriority(buildDock, 100);
			   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
			   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, kbAreaGetCenter(areaID));
			   aiPlanAddUnitType(buildDock, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
			   aiPlanSetEscrowID(buildDock, cEconomyEscrowID);
			   aiPlanSetActive(buildDock);
			}
		}
		gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 2, false, -1);
		aiPlanSetDesiredPriority(gMaintainWaterXPortPlanID, 95);
   }

   //If we're building walls and/or towers, start those up.
   if (gBuildWalls == true)
	  xsEnableRule("wallUpgrade");
   if (gBuildTowers == true)
	  xsEnableRule("towerUpgrade");

   //Store our relic gatherer type.
   int gatherRelicType=-1;

   //Init our myth unit rule.
   xsEnableRule("trainMythUnit");

   //Greek.
   if (cMyCulture == cCultureGreek)
   {
	  //Greeks gather with heros.
	  gatherRelicType=cUnitTypeHero;

	  //Always want 4 hoplites.
	  //createSimpleMaintainPlan(cUnitTypeHoplite, 4, false, kbBaseGetMainID(cMyID));

	  //Create our hero maintain plans.  These do first and second age heroes.
	  if (cMyCiv == cCivZeus)
	  {
		 createSimpleMaintainPlan(cUnitTypeHeroGreekJason, 1, false, kbBaseGetMainID(cMyID));
		 createSimpleMaintainPlan(cUnitTypeHeroGreekOdysseus, 1, false, kbBaseGetMainID(cMyID));
	  }
	  else if (cMyCiv == cCivPoseidon)
	  {
		 createSimpleMaintainPlan(cUnitTypeHeroGreekTheseus, 1, false, kbBaseGetMainID(cMyID));
		 createSimpleMaintainPlan(cUnitTypeHeroGreekHippolyta, 1, false, kbBaseGetMainID(cMyID));
	  }
	  else if (cMyCiv == cCivHades)
	  {
		 createSimpleMaintainPlan(cUnitTypeHeroGreekAjax, 1, false, kbBaseGetMainID(cMyID));
		 createSimpleMaintainPlan(cUnitTypeHeroGreekChiron, 1, false, kbBaseGetMainID(cMyID));
	  }
   }
   if (cMyCiv == cCivHades)
   {
	  //Get VOE.
	  int voePID=aiPlanCreate("HadesVaultsOfErebus", cPlanProgression);
	   if (voePID != 0)
	  {
		 aiPlanSetVariableInt(voePID, cProgressionPlanGoalTechID, 0, cTechVaultsofErebus);
		  aiPlanSetDesiredPriority(voePID, 25);
		  aiPlanSetEscrowID(voePID, cEconomyEscrowID);
		  aiPlanSetActive(voePID);
	  }
   }
   //Egyptian.
   else if (cMyCulture == cCultureEgyptian)
   {
	  //Egyptians gather relics with their Pharaoh.
	  gatherRelicType=cUnitTypePharaoh;

	  //Move our pharaoh empower to a generic "dropsite"
	  if (gEmpowerPlanID > -1)
		 aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeDropsite);

	  //Always want 4 axeman.
	  //createSimpleMaintainPlan(cUnitTypeAxeman, 4, false, kbBaseGetMainID(cMyID));

	  //If we're Ra, create some more priests and empower with them.
	  if (cMyCiv == cCivRa)
	  {
		 createSimpleMaintainPlan(cUnitTypePriest, 4, true, -1);
		 int ePlanID=aiPlanCreate("Mining Camp Empower", cPlanEmpower);
		 if (ePlanID >= 0)
		 {
			aiPlanSetEconomy(ePlanID, true);
			aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
			aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMiningCamp);
			aiPlanSetActive(ePlanID);
		 }
		 ePlanID=aiPlanCreate("Lumber Camp Empower", cPlanEmpower);
		 if (ePlanID >= 0)
		 {
			aiPlanSetEconomy(ePlanID, true);
			aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
			aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeLumberCamp);
			aiPlanSetActive(ePlanID);
		 }
		 ePlanID=aiPlanCreate("Monument Empower", cPlanEmpower);
		 if (ePlanID >= 0)
		 {
			aiPlanSetEconomy(ePlanID, true);
			aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
			aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeAbstractMonument);
			aiPlanSetActive(ePlanID);
		 }
	  }

	  //Up the build limit for Outposts.
	  aiSetMaxLOSProtoUnitLimit(8);
   }
   //Norse.
   else if (cMyCulture == cCultureNorse)
   {
	  // add and extra ulfsark builder
	  aiPlanSetVariableInt(gUlfsarkMaintainPlanID, cTrainPlanNumberToMaintain, 0, 
		 aiPlanGetVariableInt(gUlfsarkMaintainPlanID, cTrainPlanNumberToMaintain, 0)+1);
	  aiPlanSetVariableInt(gUlfsarkMaintainMilPlanID, cTrainPlanNumberToMaintain, 0, 
		 aiPlanGetVariableInt(gUlfsarkMaintainMilPlanID, cTrainPlanNumberToMaintain, 0)+1);   //Norse gather with their heros.
	  gatherRelicType=cUnitTypeHeroNorse;

	  //We always want 2 Norse heroes.
	  createSimpleMaintainPlan(cUnitTypeHeroNorse, 2, false, kbBaseGetMainID(cMyID));

	  //Force a long house to go down.
	   int longhousePlanID=aiPlanCreate("NorseBuildLonghouse", cPlanBuild);
	  if (longhousePlanID >= 0)
	  {
		 aiPlanSetVariableInt(longhousePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeLonghouse);
		   aiPlanSetVariableInt(longhousePlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());  
		 aiPlanSetDesiredPriority(longhousePlanID, 100);
		   aiPlanAddUnitType(longhousePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0),
			gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
		 aiPlanSetEscrowID(longhousePlanID, cMilitaryEscrowID);
		 aiPlanSetBaseID(longhousePlanID, kbBaseGetMainID(cMyID));
		 aiPlanSetActive(longhousePlanID);
	  }

	  //Up our Thor dwarf count.
	  if (gDwarfMaintainPlanID > -1)
		 aiPlanSetVariableInt(gDwarfMaintainPlanID, cTrainPlanNumberToMaintain, 0, 4);


   }
   else if (cMyCulture == cCultureAtlantean)
   {
	  //Always want 4 Swordsman
	  //createSimpleMaintainPlan(cUnitTypeSwordsman, 4, false, kbBaseGetMainID(cMyID));

	  // Use hero oracle for gathering relics
	  gatherRelicType = cUnitTypeOracleHero;
	  xsEnableRule("makeOracleHero");  // Keep at least one oracle hero around

	  // Build a guild
	   int guildPlanID=aiPlanCreate("BuildGuild", cPlanBuild);
	  if (guildPlanID >= 0)
	  {
		 aiPlanSetVariableInt(guildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeGuild);
		   aiPlanSetVariableInt(guildPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());  
		 aiPlanSetDesiredPriority(guildPlanID, 100);
		   aiPlanAddUnitType(guildPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0),
			gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
		 aiPlanSetEscrowID(guildPlanID, cEconomyEscrowID);
		 aiPlanSetBaseID(guildPlanID, kbBaseGetMainID(cMyID));
		 aiPlanSetActive(guildPlanID);
	  }
   }
	else if(cMyCulture == cCultureChinese)
	{   
		createSimpleMaintainPlan(cUnitTypeHeroChineseImmortal, 2, false, kbBaseGetMainID(cMyID));
	}
   //Relics:  Always on Hard or Nightmare, 50% of the time on Moderate, Never on Easy.
   bool gatherRelics=true;
   if ((aiGetWorldDifficulty() == cDifficultyEasy) ||
	  ((aiGetWorldDifficulty() == cDifficultyModerate) && (aiRandInt(2) == 0)) )
	  gatherRelics=false;
   //If we're going to gather relics, do it.
   if (cvOkToGatherRelics == false)
	  gatherRelics = false;
   if (gatherRelics == true)
   {
	  aiEcho("Creating relic gathering plan with unit type "+gatherRelicType);
	  gRelicGatherPlanID=aiPlanCreate("Relic Gather", cPlanGatherRelic);
	  if (gRelicGatherPlanID >= 0)
	  {
		 aiPlanAddUnitType(gRelicGatherPlanID, gatherRelicType, 1, 1, 1);
		 aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanTargetTypeID, 0, cUnitTypeRelic);
		   aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanDropsiteTypeID, 0, cUnitTypeTemple);
		 aiPlanSetBaseID(gRelicGatherPlanID, kbBaseGetMainID(cMyID));
		 aiPlanSetDesiredPriority(gRelicGatherPlanID, 100);
		   aiPlanSetActive(gRelicGatherPlanID);
	  }
	   gGardenBuildLimit = 2;
   }

   //Build walls if we should.
   if (gBuildWalls==true)
   {
/*old
	  gWallPlanID = aiPlanCreate("WallInBase", cPlanBuildWall);
	  if (gWallPlanID != -1)
	  {
		 aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeRing);
		 aiPlanAddUnitType(gWallPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
		 aiPlanSetVariableVector(gWallPlanID, cBuildWallPlanWallRingCenterPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
		 aiPlanSetVariableFloat(gWallPlanID, cBuildWallPlanWallRingRadius, 0, 45.0 - (10.0*cvRushBoomSlider));
		 aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanNumberOfGates, 0, 5);
		 aiPlanSetBaseID(gWallPlanID, kbBaseGetMainID(cMyID));
		 aiPlanSetEscrowID(gWallPlanID, cMilitaryEscrowID);
		 aiPlanSetDesiredPriority(gWallPlanID, 100);
		 aiPlanSetActive(gWallPlanID, true);
		 //Enable our wall gap rule, too.
		 xsEnableRule("fillInWallGaps");

		 if (cMyCulture != cCultureAtlantean)   // Two extra one-vill wall plans let them leapfrog...faster wall construction
		 {
			int wallPlanID2 = aiPlanCreate("WallInBase2", cPlanBuildWall);
			aiPlanSetVariableInt(wallPlanID2, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeRing);
			aiPlanAddUnitType(wallPlanID2, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
			aiPlanSetVariableVector(wallPlanID2, cBuildWallPlanWallRingCenterPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
			aiPlanSetVariableFloat(wallPlanID2, cBuildWallPlanWallRingRadius, 0, 45.0 - (10.0*cvRushBoomSlider));
			aiPlanSetVariableInt(wallPlanID2, cBuildWallPlanNumberOfGates, 0, 5);
			aiPlanSetBaseID(wallPlanID2, kbBaseGetMainID(cMyID));
			aiPlanSetEscrowID(wallPlanID2, cMilitaryEscrowID);
			aiPlanSetDesiredPriority(wallPlanID2, 100);
			aiPlanSetActive(wallPlanID2, true);

			int wallPlanID3 = aiPlanCreate("WallInBase3", cPlanBuildWall);
			aiPlanSetVariableInt(wallPlanID3, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeRing);
			aiPlanAddUnitType(wallPlanID3, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
			aiPlanSetVariableVector(wallPlanID3, cBuildWallPlanWallRingCenterPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
			aiPlanSetVariableFloat(wallPlanID3, cBuildWallPlanWallRingRadius, 0, 45.0 - (10.0*cvRushBoomSlider));
			aiPlanSetVariableInt(wallPlanID3, cBuildWallPlanNumberOfGates, 0, 5);
			aiPlanSetBaseID(wallPlanID3, kbBaseGetMainID(cMyID));
			aiPlanSetEscrowID(wallPlanID3, cMilitaryEscrowID);
			aiPlanSetDesiredPriority(wallPlanID3, 100);
			aiPlanSetActive(wallPlanID3, true);
		 }
	  }
*/

	  gWallPlanID = aiPlanCreate("WallInBase", cPlanBuildWall);   // Empty wall plan, will store area list there.

	  float baseRadius = 32.0 - (11.0*cvRushBoomSlider);			 // Not really a 'radius', will be edge of square
	  /*
		 New area-based walling.  The concept is to get a list of appropriate areas, pass them to the walling plan,
		 and have it build a wall around the convex hull defined by that area list.  To do this, I take this approach.
		 1) Define a 'radius', which is the length of a square zone that we want to enclose.
		 2) Add the center area to the list.
		 3) For each area within 2 layers of that center area, include it if its in the same area group and
		   a) its center is within that area, or
		   b) it is a gold area, or
		   c) it is a settlement area.
	  */

	  aiPlanSetNumberVariableValues(gWallPlanID, cBuildWallPlanAreaIDs, 20, true);
	  int numAreasAdded = 0;
	  aiEcho("  ");
	  aiEcho("  ");

	  int mainArea = -1;
	  vector mainCenter = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	  float mainX = xsVectorGetX(mainCenter);
	  float mainZ = xsVectorGetZ(mainCenter);
	  mainArea = kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	  aiEcho("My main area is "+mainArea+", at "+mainCenter);
	  aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
	  numAreasAdded = numAreasAdded + 1;
	  
	  int firstRingCount = -1;  // How many areas are in first ring around main?
	  int firstRingIndex = -1;  // Which one are we on?
	  int secondRingCount = -1;  // How many border areas does the current first ring area have?
	  int secondRingIndex = -1;  
	  int firstRingID = -1;   // Actual ID of current 1st ring area
	  int secondRingID = -1;
	  vector areaCenter = cInvalidVector;   // Center point of this area
	  float areaX = 0.0;
	  float dx = 0.0;
	  float areaZ = 0.0;
	  float dz = 0.0;
	  int areaType = -1;
	  bool  needToSave = false;

	  firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
	  for (firstRingIndex = 0; < firstRingCount)	  // Check each border area of the main area
	  {
		 needToSave = true;   // We'll save this unless we have a problem
		 firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
		 areaCenter = kbAreaGetCenter(firstRingID);
		 // Now, do the checks.
			areaX = xsVectorGetX(areaCenter);
			areaZ = xsVectorGetZ(areaCenter);
			dx = mainX - areaX;
			dz = mainZ - areaZ;
			if ( (dx > baseRadius) || (dx < (-1.0*baseRadius)) )
			{
			   needToSave = false;
			}
			if ( (dz > baseRadius) || (dz < (-1.0*baseRadius)) )
			{
			   needToSave = false;
			}
			// Override if it's a special type
			areaType = kbAreaGetType(firstRingID);
			if ( areaType == cAreaTypeGold)
			{
			   needToSave = true;
			}
			if ( areaType == cAreaTypeSettlement )
			{
			   needToSave = true;
			}
		 // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
		 if (needToSave == true)
		 {
			int i = -1;
			bool found =false;
			for (i=0; < numAreasAdded)
			{
			   if (aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, i) == firstRingID)
			   {
				  found = true;  // It's in there, don't add it
			   }
			}
			if ((found == false) && (numAreasAdded < 20))  // add it
			{
			   aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
			   numAreasAdded = numAreasAdded + 1;
			   // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
				  secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);	 // How many does it touch?
				  for (secondRingIndex=0; < secondRingCount)
				  {  // Check each border area.  If it's gold or settlement and not already in list, add it.
					 secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
					 if ( (kbAreaGetType(secondRingID) == cAreaTypeSettlement) || (kbAreaGetType(secondRingID) == cAreaTypeGold) )
					 {
						bool skipme = false;	   // Skip it if center is more than 10m outside normal radius
						areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
						areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
						dx = mainX - areaX;
						dz = mainZ - areaZ;
						if ( (dx > (baseRadius+10.0)) || (dx < (-1.0*(baseRadius+10.0))) )
						{
						   skipme = true;
						}
						if ( (dz > (baseRadius+10.0)) || (dz < (-1.0*(baseRadius+10.0))) )
						{
						   skipme = true;
						}
						bool alreadyIn = false;
						int m=0;
						for (m=0; < numAreasAdded)
						{
						   if (aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, m) == secondRingID)
						   {
							  alreadyIn = true;  // It's in there, don't add it
						   }
						}
						if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
						{
						   aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
						   numAreasAdded = numAreasAdded + 1;
						}
					 }
				  }
			}
		 }
	  }

	  int j = -1;
	  aiEcho("  Area list:");
	  for (j=0; < numAreasAdded)
		 aiEcho("   "+aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, j));

	  // Set the true number of area variables, preserving existing values, then turn on the plan
	  aiPlanSetNumberVariableValues(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

	  aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
	  if( cMyCulture == cCultureChinese)
	  {
		aiPlanAddUnitType(gWallPlanID, cUnitTypeVillagerChinese, 1, 3, 3);
	  }
	  else
	  aiPlanAddUnitType(gWallPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 3, 3);
	  if (cMyCulture == cCultureAtlantean)
		 aiPlanAddUnitType(gWallPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanNumberOfGates, 0, 10);
	  aiPlanSetVariableFloat(gWallPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
	  aiPlanSetBaseID(gWallPlanID, kbBaseGetMainID(cMyID));
	  aiPlanSetEscrowID(gWallPlanID, cMilitaryEscrowID);
	  aiPlanSetDesiredPriority(gWallPlanID, 100);
	  aiPlanSetActive(gWallPlanID, true);

	  // Add 2 ulfsarks from econ budget for walling
	  int planID=aiPlanCreate("Wall Ulfsarks", cPlanTrain);
	  if (planID >= 0)
	  {
		 aiEcho("Adding two ulfsarks for walling.");
		 aiPlanSetEconomy(planID, true);
		 aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeUlfsark);
		 aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 2);
		 aiPlanSetDesiredPriority(planID, 98);
		 aiPlanSetActive(planID);
	  }

	  //Enable our wall gap rule, too.
	  xsEnableRule("fillInWallGaps");
	  aiEcho("Wall planning complete.");
	  aiEcho("  ");
	  aiEcho("  ");
   }


/* handled in econ file
   //If we're in deathmatch, immediately build our armory.
   if (aiGetGameMode() == cGameModeDeathmatch)
   {
	  gHardEconomyPopCap=15;
	  if (cMyCiv == cCivThor)
		 createSimpleBuildPlan(cUnitTypeDwarfFoundry, 1, 100, false, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 5);
	  else
		 createSimpleBuildPlan(cUnitTypeArmory, 1, 100, false, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 5);
	  createSimpleBuildPlan(cUnitTypeHouse, 3, 90, false, false, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
   }
*/
}



rule rebuildMarket  // If market dies, restart
minInterval 19
inactive				// activated in tradeWithCaravans, after market is built
{
   //if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) < 1)
   if (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0)
   {
	  xsEnableRule("tradeWithCaravans");
	  xsDisableSelf();
	  gTradeMarketUnitID = -1;
	  aiEcho("***** Restarting market trade rule.");
   }
}


//==============================================================================
// RULE monitorTrade
//==============================================================================
rule monitorTrade
inactive
minInterval 27
{
  // Set the number of trade carts based on age and quality of trade route.
   int destID = aiPlanGetVariableInt(gTradePlanID,cTradePlanTargetUnitID, 0);
   int marketID = aiPlanGetVariableInt(gTradePlanID, cTradePlanMarketID, 0);
   int oldTradePop = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
   int tradeTargetPop = gMaxTradeCarts;
   if ( (cvMaxTradePop >= 0) && (tradeTargetPop > cvMaxTradePop))   // Stay under control variable limit
	  tradeTargetPop = cvMaxTradePop;
   if (kbGetAge() < cAge4)  // Ramp up in age 3, not too many...
	  tradeTargetPop = tradeTargetPop/2;
   if ( (destID >= 0) && (marketID >= 0) ) // Have dest and a market
   {
	  float routeLength = xsVectorLength( kbUnitGetPosition(destID) -  kbUnitGetPosition(marketID));
	  float routeRatio = (routeLength*2) / (kbGetMapXSize() + kbGetMapZSize());
	  float routeQuality = routeRatio / .75;	   // Define 75% of map length as "perfect".
	  if (routeQuality > 1.0)
		 routeQuality = 1.0;
	  tradeTargetPop = tradeTargetPop * routeQuality;   
	  aiPlanSetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0, tradeTargetPop);
   }
   else
   {  // No market, or no destination
	  tradeTargetPop = 0;
	  aiPlanSetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0, tradeTargetPop);	// Don't make trade carts
   }
   if (oldTradePop != tradeTargetPop)
   {
	  aiEcho("Trade:  Route quality is "+routeQuality);
	  aiEcho("Changing target number of trade units from "+oldTradePop+" to "+tradeTargetPop+".");
   } 
}




//==============================================================================
// RULE makeExtraMarket
//
// If it takes more than 5 minutes to place our trade market, throw down a local one
//==============================================================================
rule makeExtraMarket
inactive
minInterval 10
{
   static int endTime = -1;

   if (endTime < 0)
	  endTime = xsGetTime() + 300000;  // Five minutes later

   if (xsGetTime() < endTime)
	  return;

   // Time has expired, add another market.
	int marketPlanID=aiPlanCreate("BuildNearbyMarket", cPlanBuild);
   if (marketPlanID >= 0)
   {
	  aiPlanSetVariableInt(marketPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
		aiPlanSetVariableInt(marketPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());	  
	  aiPlanSetDesiredPriority(marketPlanID, 100);
	  if(cMyCulture == cCultureChinese)
	  {
			aiPlanAddUnitType(marketPlanID, cUnitTypeVillagerChinese, 1, 1, 1);
	  }
	  else
		aiPlanAddUnitType(marketPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetEscrowID(marketPlanID, cEconomyEscrowID);
	  aiPlanSetBaseID(marketPlanID, kbBaseGetMainID(cMyID));
	  aiPlanSetActive(marketPlanID);
   }
   gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.
   xsDisableSelf();
}


rule goAge4
minInterval 10
inactive
{

   if ( (gAge4ProgressionPlanID < 0) && (kbGetAge() < cAge4) )
   {
	  static bool age4started = false;
	  if (age4started == false)
	  {
		 gAge4ProgressionPlanID=aiPlanCreate("Age 4", cPlanProgression);
		 aiEcho("***** Age 4 progression is plan ID "+gAge4ProgressionPlanID);
		 aiEcho("Age 4 minor god is "+gAge4MinorGod);
		 if ((gAge4ProgressionPlanID >= 0) && (gAge4MinorGod != -1))
		 { 
			aiPlanSetVariableInt(gAge4ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge4MinorGod);
			aiPlanSetDesiredPriority(gAge4ProgressionPlanID, 100);
			  aiPlanSetEscrowID(gAge4ProgressionPlanID, cEconomyEscrowID);
			aiPlanSetBaseID(gAge4ProgressionPlanID, kbBaseGetMainID(cMyID));
			aiPlanSetActive(gAge4ProgressionPlanID);
		 }
		 age4started = true;
	  }
   }

   xsDisableSelf();
}

//==============================================================================
// RULE tradeWithCaravans
//==============================================================================
rule tradeWithCaravans
   minInterval 11
   inactive
{
   //Force build a market.
   static int failedBase = -1;  // Set to the main base ID if no valid market position exists, so we don't retry forever.

   if (failedBase == kbBaseGetMainID(cMyID))  // We've failed at this spot before
   {
	  xsSetRuleMinInterval("tradeWithCaravans", 180);
	  aiEcho("Failed base = "+failedBase+", base = "+kbBaseGetMainID(cMyID));
	  aiEcho("Can't position a trade market for this base.");
	  return;
   }

   static bool builtMarket=false;
   static int marketTime = -1;   // Set when we create the build plan
   static int buildPlanID = -1;
   int targetNumMarkets = 1;
   if (gExtraMarket == true)
	  targetNumMarkets = 2;   // One near main base, one for trade

//   if ( (marketTime < (xsGetTime()-300000) ) && (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 1) )
//  builtMarket = false;  // It's been 5 minutes, and I still don't have a market.
							  // Either it failed, or it's been destroyed.

   if (builtMarket == false)
   {
	  string buildPlanName="BuildMarket";
	  buildPlanID=aiPlanCreate(buildPlanName, cPlanBuild);
	  if (buildPlanID < 0)
		 return;

	  vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));  // my base location
	  vector allyLocation = cInvalidVector;
	  vector marketLocation = cInvalidVector;

	  // Since we can't specify a target TC, if we have allies, we'll build in the corner
	  // that is nearest the most distant ally TC, which should give us a good run back
	  // to our TCs.  If no allies, or if ally corner == our corner, choose the
	  // corner that is second closest to our base.

	  // MK: This is *really* an ugly process in XS without arrays or trig calls.  Would be a good
	  // candidate to push down to C++.

	  // Do simple dx+dz distance check for each corner
	  float bottom = -1;
	  float top = -1;
	  float right = -1;
	  float left = -1;
	  int closestToMe = -1;
	  int closestToAlly = -1;
	  int secondClosestToMe = -1;
	  float min = -1.0;

	  bottom = xsVectorGetX(location) + xsVectorGetZ(location); // dist to bottom
	  left = xsVectorGetX(location) + (kbGetMapZSize() - xsVectorGetZ(location));
	  right = (kbGetMapXSize() - xsVectorGetX(location)) + xsVectorGetZ(location);
	  top = (kbGetMapXSize() - xsVectorGetX(location)) + (kbGetMapZSize() - xsVectorGetZ(location)); 

	  // Find closest corner, and mark it as distant so we can then find the second closest
	  if ( xsVectorGetX(location) < (kbGetMapXSize()/2) )
	  {  // we're on bottom left half
		 if ( xsVectorGetZ(location) < (kbGetMapZSize()/2) )
		 {  // we're lower right half ergo bottom corner
			bottom = 10000;  // Won't be closest
			closestToMe = 0;  // x0,z0
		 }
		 else
		 {  // we're on upper left half, ergo left
			left = 10000;
			closestToMe = 1;  // x0, z1
		 }
	  }
	  else
	  {  // we're on upper right half
		 if ( xsVectorGetZ(location) > (kbGetMapZSize()/2) )
		 {  // we're upper left half ergo top corner
			top = 10000;	 // Won't be closest
			closestToMe = 3;  // x1, z1
		 }
		 else
		 {  // we're on bottom right half, ergo right
			right = 10000;
			closestToMe = 2;  // x1, z0
		 }
	  }
	  
	  // Find second closest to me.
	  min = 9000.0;
	  if ( bottom < min )
	  {
		 min = bottom;
		 secondClosestToMe = 0;
		 aiEcho("Bottom is second closest to me.");
	  }
	  if ( top < min )
	  {
		 min = top;
		 secondClosestToMe = 3;
		 aiEcho("Top is second closest to me.");
	  }
	  if ( left < min )
	  {
		 min = left;
		 secondClosestToMe = 1;
		 aiEcho("Left is second closest to me.");
	  }
	  if ( right < min )
	  {
		 min = right;
		 secondClosestToMe = 2;
		 aiEcho("Right is second closest to me.");
	  }
 
	  // We've found the closest and second closest corners.  If we have an ally, find its closest corner

	  // Look for an ally TC.  If we find one, use it to determine position.  
	  //If we don't have a query ID, create it.
	  static int distantAllyTCQuery=-1;
	  if (distantAllyTCQuery < 0)
	  {
		 distantAllyTCQuery=kbUnitQueryCreate("MarketQuery");
		 //If we still don't have one, bail.
		 if (distantAllyTCQuery < 0)
			return;
		 //Else, setup the query data.
		 kbUnitQuerySetPlayerRelation(distantAllyTCQuery, cPlayerRelationAlly);
		 kbUnitQuerySetUnitType(distantAllyTCQuery, cUnitTypeAbstractSettlement);
		 kbUnitQuerySetState(distantAllyTCQuery, cUnitStateAlive);
		 kbUnitQuerySetPosition(distantAllyTCQuery, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
		 kbUnitQuerySetAscendingSort(distantAllyTCQuery, true);
	  }
	  kbUnitQueryResetResults(distantAllyTCQuery);
	  int tcCount = kbUnitQueryExecute(distantAllyTCQuery);
	  int tcID = -1;
	  if (tcCount > 0)
	  {
		 tcID = kbUnitQueryGetResult(distantAllyTCQuery, tcCount-1);
		 allyLocation = kbUnitGetPosition(tcID);
	  }

	  if ( xsVectorGetX(allyLocation) < (kbGetMapXSize()/2) )
	  {  // we're on bottom left half
		 if ( xsVectorGetZ(allyLocation) < (kbGetMapZSize()/2) )
		 {  // we're lower right half ergo bottom corner
			closestToAlly = 0;  // x0,z0
		 }
		 else
		 {  // we're on upper left half, ergo left
			closestToAlly = 1;  // x0, z1
		 }
	  }
	  else
	  {  // we're on upper right half
		 if ( xsVectorGetZ(allyLocation) > (kbGetMapZSize()/2) )
		 {  // we're upper left half ergo top corner
			closestToAlly = 3;  // x1, z1
		 }
		 else
		 {  // we're on bottom right half, ergo right
			closestToAlly = 2;  // x1, z0
		 }
	  }

	  // Now, sort it all out...
	  // Since we can't override the tendency to trade with our own settlements, this is what we'll do.
	  // If the most distant ally's closest corner is not the same as ours, we'll go there.  
	  // If we don't have an ally, or the ally's closest corner is the same as ours, we'll use our 
	  // second closest corner.

	  int chosenCorner = -1;

	  aiEcho("Closest to me "+closestToMe+", second "+secondClosestToMe+", ally "+closestToAlly);

	  if ( (tcID < 0) || (closestToAlly == closestToMe))
	  {
		 chosenCorner = secondClosestToMe;
		 aiEcho("Choosing second closest to me "+secondClosestToMe);
	  }
	  else
	  {
		 chosenCorner = closestToAlly;
		 aiEcho("Choosing closest to ally "+closestToAlly);
	  }

	  switch(chosenCorner)
	  {
	  case 0:
		 {  // X and Z low
			marketLocation = xsVectorSetX(marketLocation, 2);
			marketLocation = xsVectorSetZ(marketLocation, 2);
			break;
		 }
	  case 1:
		 {  // X low, Z hi
			marketLocation = xsVectorSetX(marketLocation, 2);
			marketLocation = xsVectorSetZ(marketLocation, kbGetMapZSize()-2);
			break;
		 }
	  case 2:
		 {  // X hi, Z lo
			marketLocation = xsVectorSetX(marketLocation, kbGetMapXSize()-2);
			marketLocation = xsVectorSetZ(marketLocation, 2);
			break;
		 }
	  case 3:
		 {  // X hi, Z hi
			marketLocation = xsVectorSetX(marketLocation, kbGetMapXSize()-2);
			marketLocation = xsVectorSetZ(marketLocation, kbGetMapZSize()-2);
			break;
		 }
	  }

	  marketLocation = xsVectorSetY(marketLocation, 0);

	  // Figure out if it's on our areaGroup.  If not, step 5% closer until it is.
	  int homeAreaGroup = -1;
	  int marketAreaGroup = -1;
	  homeAreaGroup = kbAreaGroupGetIDByPosition(location);
	  aiEcho("Home location "+location+" is in areaGroup "+homeAreaGroup);

	  int i = -1;
	  vector towardHome = cInvalidVector;
	  towardHome = location - marketLocation;
	  towardHome = towardHome / 20; // 5% of distance from market to home
	  bool success = false;

	  for (i=0; <18)	// Keep testing until areaGroups match
	  {
		 marketAreaGroup = kbAreaGroupGetIDByPosition(marketLocation);
		 if (marketAreaGroup == homeAreaGroup)
		 {
			success = true;
			aiEcho("Market location "+marketLocation+" is in areaGroup "+marketAreaGroup);
			break;
		 }
		 else
		 {
			aiEcho("Market location "+marketLocation+" is in areaGroup "+marketAreaGroup);
			marketLocation = marketLocation + towardHome;   // Try a bit closer
		 }
	  }
   
	  if (success == false)
	  {
		 aiEcho("Can't find a market spot, we'll give up and let the age4 plan build one.");
		 failedBase = kbBaseGetMainID(cMyID);
		 xsEnableRule("goAge4");
		 return;
	  }

	  aiEcho("Market target location is "+marketLocation+" in areaGroup "+kbAreaGroupGetIDByPosition(marketLocation));
	  gTradeMarketLocation = marketLocation; // Set the global var for later reference in identifying the trade market.

	  //Setup the build plan.
	  aiPlanSetVariableInt(buildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
	  aiPlanSetVariableVector(buildPlanID, cBuildPlanInfluencePosition, 0, marketLocation);
	  aiPlanSetVariableFloat(buildPlanID, cBuildPlanInfluencePositionDistance, 0, 30.0);
	  aiPlanSetVariableFloat(buildPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
	  aiPlanSetVariableInt(buildPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(marketLocation));
	  aiPlanSetVariableInt(buildPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);
	  aiPlanSetDesiredPriority(buildPlanID, 100);
	  if(cMyCulture == cCultureChinese)
	  {
		aiPlanAddUnitType(buildPlanID, cUnitTypeVillagerChinese, 1, 1, 1);
	  }
	  else
	  aiPlanAddUnitType(buildPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetEscrowID(buildPlanID, cEconomyEscrowID);
	  aiPlanSetActive(buildPlanID);
	 
	  builtMarket = true;
	  marketTime = xsGetTime();
	  xsEnableRule("makeExtraMarket");  // Will build a local market in 5 minutes if this one isn't done
   }  // Force-build market
   
   //If we don't have a query ID, create it.
   static int marketQueryID=-1;
   if (marketQueryID < 0)
   {
	  marketQueryID=kbUnitQueryCreate("MarketQuery");
	  //If we still don't have one, bail.
	  if (marketQueryID < 0)
		 return;
	  //Else, setup the query data.
	  kbUnitQuerySetPlayerID(marketQueryID, cMyID);
	  kbUnitQuerySetUnitType(marketQueryID, cUnitTypeMarket);
	  kbUnitQuerySetState(marketQueryID, cUnitStateAlive);
   }
   kbUnitQuerySetPosition(marketQueryID, gTradeMarketLocation);
   kbUnitQuerySetAscendingSort(marketQueryID, true);

   //Reset the results.
   kbUnitQueryResetResults(marketQueryID);
   //Run the query.  
   int numMarkets = kbUnitQueryExecute(marketQueryID);
   aiEcho("***** Market plan ("+buildPlanID+") status is "+aiPlanGetState(buildPlanID));
   aiEcho("  We have "+numMarkets+" markets out of "+targetNumMarkets+" planned.");   
   if (numMarkets <= 0)
   {
	  if(aiPlanGetState(buildPlanID) < 0)   // No market, and not building or placing
	  {  
		 aiPlanDestroy(buildPlanID);		 // Scrap it an start over
		 buildPlanID = -1;
		 builtMarket = false;
		 aiEcho("***** Market build failed, restarting");
	  }
	  return;   // No market at all, bail
   }
   // At least one market exists
   xsDisableRule("makeExtraMarket");	  // If it hasn't run already, we don't need it
   xsEnableRule("goAge4");



   if (numMarkets < targetNumMarkets)   // Trade market not done yet
   {
	  if(aiPlanGetState(buildPlanID) < 0)   // No trade market, and not building or placing
	  {  
		 aiPlanDestroy(buildPlanID);		 // Scrap it and start over
		 buildPlanID = -1;
		 builtMarket = false;
		 aiEcho("***** Market build failed, restarting");
	  }
	  return;
   }

   // We have our target number of markets
   aiEcho("***** We have our target number of markets, starting trade plan.");

   int marketUnitID=kbUnitQueryGetResult(marketQueryID, 0); // Closest to target point
   if (marketUnitID == -1)
	  return;
   gTradeMarketLocation = kbUnitGetPosition(marketUnitID);
   gTradeMarketUnitID = marketUnitID;

	// We have a market for trade, activate the rule to rebuild if lost
   xsEnableRule("rebuildMarket");   // Will restart process if market is lost

   //Create the market trade plan.
   if (gTradePlanID >= 0)
	  aiPlanDestroy(gTradePlanID);  // Delete old one based on previous market, if any.
   string planName="MarketTrade";
   gTradePlanID=aiPlanCreate(planName, cPlanTrade);
   if (gTradePlanID < 0)
	  return;

   //Get our cart PUID.
   int tradeCartPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0);
   aiPlanSetVariableInt(gTradePlanID, cTradePlanTargetUnitTypeID, 0, cUnitTypeAbstractSettlement);
   aiPlanSetDesiredPriority(gTradePlanID, 100);
   aiPlanSetInitialPosition(gTradePlanID, kbUnitGetPosition(marketUnitID));
   aiPlanSetVariableVector(gTradePlanID, cTradePlanStartPosition, 0, kbUnitGetPosition(marketUnitID));
   aiPlanSetVariableInt(gTradePlanID, cTradePlanTradeUnitType, 0, tradeCartPUID);

   aiPlanSetVariableInt(gTradePlanID, cTradePlanMarketID, 0, marketUnitID);
   aiPlanAddUnitType(gTradePlanID, tradeCartPUID, 1, 1, 100);   // Just one to start, maintain plan will adjust later based on route quality

   aiPlanSetEconomy(gTradePlanID, true);
   aiPlanSetActive(gTradePlanID);

   // Activate the rule to monitor it
   xsEnableRule("monitorTrade");

   gTradeMaintainPlanID = createSimpleMaintainPlan(tradeCartPUID, 1, true);   // Just one to start, monitorTrade rule will adjust as needed

   //Go away.
   xsDisableSelf();
}


//==============================================================================
// Age 3 Handler
//==============================================================================
void age3Handler(int age=2)
{
   aiEcho("I'm now in Age "+age+".");
   gLastAgeHandled = cAge3;
   if (cvMaxAge == age)
   {
	  aiEcho("Suspending age upgrades.");
	  aiSetPauseAllAgeUpgrades(true);
   }
   //Econ.
   econAge3Handler(age);
   //Progress.
   progressAge3Handler(age);
   //GP.
   gpAge3Handler(age);
   aiEcho("  Done with misc handlers.");

   if (gBuildTowers == true)
	  towerInBase("Age3TowerBuild", false, gTargetNumTowers -  (gTargetNumTowers/(2.0 + (-1.0*cvRushBoomSlider))), cMilitaryEscrowID); // Whatever not done in age 2

   //Disable town defense (in case it's active).
   xsDisableRule("townDefense");

   //Switch the EM rule.
   xsDisableRule("updateEMAge2");
   xsEnableRule("updateEMAge3");
	updateEMAge3();
	
   //We can trade now.
   xsEnableRule("tradeWithCaravans");

   //Up the number of water transports to maintain.
   if (gMaintainWaterXPortPlanID >= 0)
	  aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 2);

   //Create new greek hero maintain plans.
   if (cMyCulture == cCultureGreek)
   {
	  if (cMyCiv == cCivZeus)
		 createSimpleMaintainPlan(cUnitTypeHeroGreekHeracles, 1, false, kbBaseGetMainID(cMyID));
	  else if (cMyCiv == cCivPoseidon)
		 createSimpleMaintainPlan(cUnitTypeHeroGreekAtalanta, 1, false, kbBaseGetMainID(cMyID));
	  else if (cMyCiv == cCivHades)
		 createSimpleMaintainPlan(cUnitTypeHeroGreekAchilles, 1, false, kbBaseGetMainID(cMyID));

	  //Build a fortress and train some catapults.
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
	  {
		 /*  covered below for all civs
		  int fortressPlanID=aiPlanCreate("BuildFortress", cPlanBuild);
		 if (fortressPlanID >= 0)
		 {
			aiPlanSetVariableInt(fortressPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeFortress);
			  aiPlanSetVariableInt(fortressPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());	  
			aiPlanSetDesiredPriority(fortressPlanID, 100);
			  aiPlanAddUnitType(fortressPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
			aiPlanSetEscrowID(fortressPlanID, cMilitaryEscrowID);
			aiPlanSetBaseID(fortressPlanID, kbBaseGetMainID(cMyID));
			aiPlanSetActive(fortressPlanID);
		 }
		 */
		 gSiegeUnitType = cUnitTypePetrobolos;
	  }
   }
   else if (cMyCulture == cCultureEgyptian)
   {
	  //Build a siege workshop.
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
	  {
		  int siegeCampPlanID=aiPlanCreate("BuildSiegeCamp", cPlanBuild);
		 if (siegeCampPlanID >= 0)
		 {
			aiPlanSetVariableInt(siegeCampPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSiegeCamp);
			  aiPlanSetVariableInt(siegeCampPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());   
			aiPlanSetDesiredPriority(siegeCampPlanID, 100);
			  aiPlanAddUnitType(siegeCampPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
			aiPlanSetEscrowID(siegeCampPlanID, cMilitaryEscrowID);
			aiPlanSetBaseID(siegeCampPlanID, kbBaseGetMainID(cMyID));
			aiPlanSetActive(siegeCampPlanID);
		 }
		 //Maintain a couple of siege towers.
		 gSiegeUnitType = cUnitTypeSiegeTower;
	 }

	  //Set the build limit for Outposts.
	  aiSetMaxLOSProtoUnitLimit(9);
   }
   else if (cMyCulture == cCultureNorse)
   {
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
		 gSiegeUnitType = cUnitTypePortableRam;

	  //Up our Thor dwarf count.
	  if (gDwarfMaintainPlanID > -1)
		 aiPlanSetVariableInt(gDwarfMaintainPlanID, cTrainPlanNumberToMaintain, 0, 6);
   }
   else if (cMyCulture == cCultureAtlantean)
   {
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
		 gSiegeUnitType = cUnitTypeChieroballista; // For age 3.  We'll use the fire siphon for age 4.
   }
	else if(cMyCulture == cCultureChinese)
	{
		gGardenBuildLimit = 6;
	}

	  // Build a fortress/palace/whatever...or 4 in DM
   int buildingType = -1;
   int numBuilders = -1;
   switch(cMyCulture)
   {
	  case cCultureGreek:
		 {
			buildingType = cUnitTypeFortress;
			numBuilders = 3;
			break;
		 }
	  case cCultureEgyptian:
		 {
			buildingType = cUnitTypeMigdolStronghold;
			numBuilders = 5;
			break;
		 }
	  case cCultureNorse:
		 {
			buildingType = cUnitTypeHillFort;
			numBuilders = 2;
			break;
		 }
	  case cCultureAtlantean:
		 {
			buildingType = cUnitTypePalace;
			numBuilders = 1;
			break;
		 }
		case cCultureChinese:
		{
			buildingType = cUnitTypeCastle;
			numBuilders  = 3;
		}
   }
	int strongBuildPlanID=aiPlanCreate("Build Strong Building ", cPlanBuild);
   if (strongBuildPlanID >= 0)
   {
	  aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
		aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());   
	  aiPlanSetDesiredPriority(strongBuildPlanID, 90);
	  if(cMyCulture == cCultureChinese)
	  {
		aiPlanAddUnitType(strongBuildPlanID, cUnitTypeVillagerChinese,1, numBuilders, numBuilders);
	  }
	  else
		aiPlanAddUnitType(strongBuildPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0),
		 1, numBuilders, numBuilders);
	  aiPlanSetEscrowID(strongBuildPlanID, cMilitaryEscrowID);
	  aiPlanSetBaseID(strongBuildPlanID, kbBaseGetMainID(cMyID));
	  aiPlanSetActive(strongBuildPlanID);
   }

   if (gSiegeUnitType != -1)
	  gSiegeReservePlanID = createSimpleMaintainPlan(gSiegeUnitType, gSiegeUnitReserveSize, false, kbBaseGetMainID(cMyID));

   tradeWithCaravans(); // Call to get it going ASAP.
/* handled in econ file
   //If we're in deathmatch, immediately build some more houses and build a market.  
   if (aiGetGameMode() == cGameModeDeathmatch)
   {
	  gHardEconomyPopCap=20;
	  createSimpleBuildPlan(cUnitTypeHouse, 2, 99, false, false, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
	   int marketPlanID=aiPlanCreate("BuildNearbyMarket", cPlanBuild);
	  if (marketPlanID >= 0)
	  {
		 aiPlanSetVariableInt(marketPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
		   aiPlanSetVariableInt(marketPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());   
		 aiPlanSetDesiredPriority(marketPlanID, 100);
		   aiPlanAddUnitType(marketPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
		 aiPlanSetEscrowID(marketPlanID, cEconomyEscrowID);
		 aiPlanSetBaseID(marketPlanID, kbBaseGetMainID(cMyID));
		 aiPlanSetActive(marketPlanID);
	  }
	  gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.
   }
   */
}


rule buildTitanGate
minInterval 5
inactive
{
   // Set up the build plan to make villagers contstruct the titan gate.
}

rule placeTitanGate
minInterval 1
inactive
{
   // Set up the god power to place the titan gate


   xsDisableSelf();
   xsEnableRule("buildTitanGate");
}

//==============================================================================
// Age 4 Handler
//==============================================================================
void age4Handler(int age=3)
{
   aiEcho("I'm now in Age "+age+".");
   if (cvMaxAge == age)
   {
	  aiEcho("Suspending age upgrades.");
	  aiSetPauseAllAgeUpgrades(true);
   }
   gLastAgeHandled = cAge4;
   //Econ.
   econAge4Handler(age);
   //Progress.
   progressAge4Handler(age);
   //GP.
   gpAge4Handler(age);
   aiEcho("  Done with misc handlers.");

   if ( (aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch) )
	  xsEnableRule("makeWonder");   // Make a wonder if you have spare resources

   //Switch the EM rule.
   xsDisableRule("updateEMAge3");
   //xsEnableRule("updateEMAge4");
	updateEMAge4();
	
   //Enable our siege rule.
   xsEnableRule("increaseSiegeWeaponUP");
   //Enable our degrade unit preference rule.
   xsEnableRule("degradeUnitPreference");
   //Enable our omniscience rule.
   xsEnableRule("getOmniscience");

   // Double the siege reserve
   if (gSiegeReservePlanID >= 0)
	  aiPlanSetVariableInt(gSiegeReservePlanID, cTrainPlanNumberToMaintain, 0, 2*gSiegeUnitReserveSize);

   if (cMyCulture == cCultureAtlantean)   // Change the siege type
   {
	  gSiegeUnitType = cUnitTypeFireSiphon;
	  aiPlanSetVariableInt(gSiegeReservePlanID, cTrainPlanUnitType, 0, gSiegeUnitType);
   }

	 // Get speed upgrade
	int tradeUpgradePlanID=aiPlanCreate("coinageUpgrade", cPlanProgression);
	if (tradeUpgradePlanID != 0)
   {
	  aiPlanSetVariableInt(tradeUpgradePlanID, cProgressionPlanGoalTechID, 0, cTechCoinage);
	   aiPlanSetDesiredPriority(tradeUpgradePlanID, 100);   // Do it ASAP!
	   aiPlanSetEscrowID(tradeUpgradePlanID, cEconomyEscrowID);
	   aiPlanSetActive(tradeUpgradePlanID);
	  aiEcho("Getting coinage upgrade.");
   }

   //Econ.

   //Create new greek hero maintain plans.
   if (cMyCulture == cCultureGreek)
   {
	  if (cMyCiv == cCivZeus)
	  {
		 createSimpleMaintainPlan(cUnitTypeHeroGreekBellerophon, 1, false, kbBaseGetMainID(cMyID));
	  }
	  else if (cMyCiv == cCivPoseidon)
		 createSimpleMaintainPlan(cUnitTypeHeroGreekPolyphemus, 1, false, kbBaseGetMainID(cMyID));
	  else if (cMyCiv == cCivHades)
		 createSimpleMaintainPlan(cUnitTypeHeroGreekPerseus, 1, false, kbBaseGetMainID(cMyID));
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
		 createSimpleMaintainPlan(cUnitTypeHelepolis, 1, false, kbBaseGetMainID(cMyID));
   }
   else if (cMyCulture == cCultureEgyptian)
   {
	  //Catapults.
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
		 createSimpleMaintainPlan(cUnitTypeCatapult, 2, false, kbBaseGetMainID(cMyID));
	  //Set the build limit for Outposts.
	  aiSetMaxLOSProtoUnitLimit(11);
	  
	  if(gAge4MinorGod == cTechAge4Thoth)
	  {
		 int botPID=aiPlanCreate("GetBookOfThoth", cPlanProgression);
		  if (botPID != 0)
		 {
			aiPlanSetVariableInt(botPID, cProgressionPlanGoalTechID, 0, cTechBookofThoth);
			 aiPlanSetDesiredPriority(botPID, 25);
			 aiPlanSetEscrowID(botPID, cMilitaryEscrowID);
			 aiPlanSetActive(botPID);
		 }
	  }
	  else if(gAge4MinorGod == cTechAge4Osiris)
	  {
		 int nkPID=aiPlanCreate("GetnewKingdom", cPlanProgression);
		  if (nkPID != 0)
		 {
			aiPlanSetVariableInt(nkPID, cProgressionPlanGoalTechID, 0, cTechNewKingdom);
			 aiPlanSetDesiredPriority(nkPID, 25);
			 aiPlanSetEscrowID(nkPID, cMilitaryEscrowID);
			 aiPlanSetActive(nkPID);
		 }
	  }
   }
 else if(cMyCulture == cCultureChinese)
 {
	 gGardenBuildLimit = 10;
 }

   //If we're in deathmatch, no more hard pop cap.
   if (aiGetGameMode() == cGameModeDeathmatch)
   {
	  gHardEconomyPopCap=-1;
//  createSimpleBuildPlan(cUnitTypeHouse, 2, 99, false, false, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
	  kbEscrowAllocateCurrentResources();
   }


   // Make a progression to get Titan
   int titanPID=aiPlanCreate("GetTitan", cPlanProgression);
	if (titanPID != 0)
   {
	  aiPlanSetVariableInt(titanPID, cProgressionPlanGoalTechID, 0, cTechSecretsoftheTitans);
	   aiPlanSetDesiredPriority(titanPID, 50);
	   aiPlanSetEscrowID(titanPID, cMilitaryEscrowID);
	   aiPlanSetActive(titanPID);
	  xsEnableRule("placeTitanGate");
   }

}

//==============================================================================
// Age 5 Handler
//==============================================================================
void age5Handler(int age=4)
{
   aiEcho("I'm now in Age "+age+".");
   gLastAgeHandled = cAge5;

   // Just do one thing.. enable the titanplacement rule..
   xsEnableRule("rPlaceTitanGate");


}

//==============================================================================
// degradeUnitPreference
//==============================================================================
rule degradeUnitPreference
   minInterval 119
   inactive
{
   //If we're not 4th age, skip.
   if (kbGetAge() < 3)
	  return;
   float newPreferenceWeight=kbUnitPickGetPreferenceWeight(gLateUPID);
   if (newPreferenceWeight <= 0.0)
	  return;
//   newPreferenceWeight=newPreferenceWeight*0.9;
//   kbUnitPickSetPreferenceWeight(gLateUPID, newPreferenceWeight);
}

//==============================================================================
// towerUpgrade
//==============================================================================
rule towerUpgrade
   minInterval 31
   inactive
   runImmediately
{
   //Must be setup for wood before we do any of this.
   if (cMyCulture != cCultureAtlantean)   // A non-issue for Atlanteans...
	  if (kbSetupForResource(kbBaseGetMainID(cMyID), cResourceWood, 25.0, 400) == false)
		 return;
	  
   //Start upgrading my defenses.
   int pid=aiPlanCreate("towerUpgrade", cPlanProgression);
   if (pid >= 0)
   { 
	  aiPlanSetVariableBool(pid, cProgressionPlanRunInParallel, 0, true);
	  aiPlanSetDesiredPriority(pid, 30);
		aiPlanSetEscrowID(pid, gTowerEscrowID);
	  aiPlanSetBaseID(pid, kbBaseGetMainID(cMyID));
	  
	  if(cMyCulture == cCultureGreek)
	  {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechSignalFires);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechCarrierPigeons);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechBoilingOil);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechGuardTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
		 aiPlanSetActive(pid);
	  }
	  else if(cMyCulture == cCultureEgyptian)
	  {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechSignalFires);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechCarrierPigeons);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechBoilingOil);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechGuardTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechBallistaTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechCrenellations);
		 aiPlanSetActive(pid);
	  }
	  else if(cMyCulture == cCultureNorse)
	  {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 5, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechSignalFires);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechCarrierPigeons);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechBoilingOil);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
		 aiPlanSetActive(pid);
	  }
	  else if(cMyCulture == cCultureAtlantean)
	  {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechSignalFires);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechCarrierPigeons);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechBoilingOil);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechGuardTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechCrenellations);
		 aiEcho("**** Activating tower upgrades.");
		 aiPlanSetActive(pid);
	  }
	 else if(cMyCulture == cCultureChinese)
	 {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechSignalFires);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechCarrierPigeons);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechBoilingOil);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechGuardTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechCrenellations);
		 aiEcho("**** Activating tower upgrades.");
		 aiPlanSetActive(pid);
	 }
	  else
		 aiPlanDestroy(pid);

	  xsDisableSelf();
   }
}

//==============================================================================
// wallUpgrade
//==============================================================================
rule wallUpgrade
   minInterval 30
   inactive
   runImmediately
{
   //Must be setup for wood first.
//   if (kbSetupForResource(kbBaseGetMainID(cMyID), cResourceWood, 25.0, 600) == false)
//  return;

   if (kbGetAge() < cAge2)
	  return;   // Seems to mess up initial temple and escrow if run in first age 

   aiEcho("Starting wall upgrades.");
	  
   //Start upgrading my defenses.
   int pid=aiPlanCreate("wallUpgrade", cPlanProgression);
   if (pid >= 0)
   { 
	  aiPlanSetVariableBool(pid, cProgressionPlanRunInParallel, 0, true);
	  aiPlanSetDesiredPriority(pid, 30);
		aiPlanSetEscrowID(pid, cMilitaryEscrowID);
	  aiPlanSetBaseID(pid, kbBaseGetMainID(cMyID));
	  if( cMyCulture == cCultureNorse )
	  {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 1, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechStoneWall);
	  }
	  else
	  {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 2, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechStoneWall);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechFortifiedWall);
	  }
	  aiPlanSetActive(pid);
	  aiEcho("Wall plan is #"+pid);
	  xsDisableSelf();
   }
   xsDisableSelf();
}


//==============================================================================
// makeAtlanteanHeroes
//==============================================================================
rule makeAtlanteanHeroes
   minInterval 127
   active
{
   if (cMyCulture != cCultureAtlantean)
   {
	  xsDisableSelf();
	  return;
   }
   if ( kbResourceGet(cResourceFavor) < 60 )
	  return;

   if (gDefendPlanID < 0)
	  return;  // No defend plan units to upgrade

   int numUnits = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
   aiEcho("***** Defend plan ("+gDefendPlanID+") has "+numUnits+" units.");

   if (numUnits < 4)
	  return;

   // The defend plan has at least 4 units, and we have at least 50 favor.  Let's try to uprade a bunch of them
   int firstIndex = aiRandInt(1 + (numUnits-4));   // Rand int from 0 to numInts-5
   int unit = -1;
   int i=0;
   for (i=firstIndex; < (firstIndex+4))
   {
	  unit = aiPlanGetUnitByIndex(gDefendPlanID, i);
	  aiTaskUnitTransform(unit);
   }

}

//==============================================================================
// makeAtlanteanVillagerHeroes - maintain 3 villager heroes for atlantean on lightning
//==============================================================================
// 225/45/3
rule makeAtlanteanVillagerHeroes
   minInterval 36
   active
{
   if ( (cMyCulture != cCultureAtlantean) || (aiGetGameMode() != cGameModeLightning) )
   {
	  xsDisableSelf();
	  return;
   }

   if (kbUnitCount(cMyID, cUnitTypeVillagerAtlanteanHero, cUnitStateAlive) >= 2)
	  return;   // At max

   if ( (kbResourceGet(cResourceFood)<225) || (kbResourceGet(cResourceWood)<45) || (kbResourceGet(cResourceFavor)<3) )
	  return;   // Can't afford it

   int villagerID = findUnit(cMyID, cUnitStateAlive, cUnitTypeVillagerAtlantean);
   if (villagerID >= 0)
   {
	  aiEcho("Upgrading atlantean villager "+villagerID+" to hero status for lightning mode.");
	  aiTaskUnitTransform(villagerID);
   }
}



//==============================================================================
// makeOracleHero
//==============================================================================
rule makeOracleHero
   minInterval 65
   inactive
{
   if (kbUnitCount(cMyID, cUnitTypeOracleHero, cUnitStateAlive) > 0)
	  return;   // Already have a hero

   if (kbUnitCount(cMyID, cUnitTypeOracleScout, cUnitStateAlive) < 1)
	  return;   // No oracles to upgrade

   int targetUnit = findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeOracleScout);
   if (targetUnit < 0)
	  return;  // failed

   aiTaskUnitTransform(targetUnit); // Become a hero
   aiEcho("***** Attempting to upgrade oracle "+targetUnit+" to hero status.");
}

//==============================================================================
// periodicSaveGames
//==============================================================================
rule periodicSaveGames
   minInterval 5
   active
{
   //Dont save if we are told not to.
   if (aiGetAutosaveOn() == false)
   {
	  xsDisableSelf();
	  return;
   }

   int firstCPPlayerID = -1;
   for(i=0; < cNumberPlayers)
   {
	  if(kbIsPlayerHuman(i) == true)
		 continue;

	  firstCPPlayerID = i;
   }
   if (cMyID != firstCPPlayerID)
	  return;

   //Create the savegame name.
   static int psCount=0;
   //Save it.
   if (cvDoAutoSaves == true)
   {
	  aiQueueAutoSavegame(psCount);
	  //Inc our count.
	  psCount=psCount+1;
   }

   //After the first time, set it to every five minutes.
   xsSetRuleMinIntervalSelf(300);
}


//==============================================================================
// towerInBase
//==============================================================================
void towerInBase(string planName="BUG", bool los = true, int numTowers = 6, int escrowID=-1)
{
   aiEcho("Starting plan to build "+numTowers+" towers.");
   int baseID = kbBaseGetMainID(cMyID);
   int planID=aiPlanCreate(planName, cPlanTower);
   if (planID >= 0)
   {

	  //Save the escrow ID.
	  if (escrowID == -1)
		 escrowID = cMilitaryEscrowID;
	  gTowerEscrowID=escrowID;

	  float spacing = 0.9;
	  if (kbGetAge() > cAge2)
		 spacing = 1.8;
	  aiPlanSetVariableFloat(planID, cTowerPlanDistanceFromCenter, 0, 120.0);   // Absolute max?

	  aiPlanSetVariableVector(planID, cTowerPlanCenterLocation, 0, kbBaseGetLocation(cMyID, baseID) );
	  if(los == true)
	  {
		 aiPlanSetVariableBool(planID, cTowerPlanMaximizeLOS, 0, true);
		 aiPlanSetVariableBool(planID, cTowerPlanMaximizeAttack, 0, false);
		 aiPlanSetVariableFloat(planID, cTowerPlanLOSModifier, 0, spacing);
		 aiPlanSetVariableFloat(planID, cTowerPlanAttackLOSModifier, 0, spacing);
	  }
	  else
	  {
		 aiPlanSetVariableBool(planID, cTowerPlanMaximizeLOS, 0, false);
		 aiPlanSetVariableBool(planID, cTowerPlanMaximizeAttack, 0, true);
		 aiPlanSetVariableFloat(planID, cTowerPlanAttackLOSModifier, 0, spacing);
		 aiPlanSetVariableFloat(planID, cTowerPlanLOSModifier, 0, spacing);
	  }
	  
	  aiPlanSetVariableInt(planID, cTowerPlanNumberToBuild, 0, numTowers);
	  aiPlanSetVariableInt(planID, cTowerPlanProtoIDToBuild, 0, cUnitTypeTower);
	  
	  aiPlanSetDesiredPriority(planID, 100);
	  aiPlanSetEscrowID(planID, gTowerEscrowID);
	  aiPlanSetBaseID(planID, baseID);
	  aiPlanSetActive(planID);
   }
}


//==============================================================================
// ShouldIResign
//==============================================================================
rule ShouldIResign
   minInterval 7
   active
{
   //Don't resign in MP games.
   if(aiIsMultiplayer() == true)
   {
	  xsDisableSelf();
	  return;
   }

   if(cvOkToResign == false)
   {
	  xsDisableSelf();   // Must be re-enabled if cvOkToResign is set true.
	  return;   
   }

   //Don't resign if you're teamed with a human.
   static bool checkTeamedWithHuman=true;
   if (checkTeamedWithHuman == true)
   {
	  for (i=1; < cNumberPlayers)
	  {
		 if (i == cMyID)
			continue;
		 //Skip if not human.
		 if (kbIsPlayerHuman(i) == false)
			continue;
		 //If this is a mutually allied human, go away.
		 if (kbIsPlayerMutualAlly(i) == true)
		 {
			xsDisableSelf();
			return;
		 }
	  }
	  //Don't check again.
	  checkTeamedWithHuman=false;
   }

   //Don't resign too soon.
   if (xsGetTime() < 600000)
	 return;

   int numSettlements=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
   //If on easy, don't only resign if you have no settlements.
   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	  if (numSettlements <= 0)
	  {
		 aiEcho("Resign: Easy numSettlements("+numSettlements+")");
		 gResignType = cResignSettlements;
		 aiAttemptResign(cAICommPromptResignQuestion);
		 xsDisableSelf();
		 return;
	  }
	  return;
   }

   //Don't resign if we have over 30 active pop slots.
   if (kbGetPop() >= 30)
	  return;
   
   //If we don't have any builders, we're not Norse, and we cannot afford anymore, try to resign.
   int builderUnitID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
   if(cMyCulture == cCultureChinese)
		builderUnitID = cUnitTypeVillagerChinese;
   int numBuilders=kbUnitCount(cMyID, builderUnitID, cUnitStateAliveOrBuilding);   
   if ((numBuilders <= 0) && (cMyCulture != cCultureNorse))
   {
	  if (kbCanAffordUnit(builderUnitID, cEconomyEscrowID) == false)
	  {
		aiEcho("Resign: numBuilders("+numBuilders+")");
		gResignType=cResignGatherers;
		//aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignGatherers, -1);
		aiAttemptResign(cAICommPromptResignQuestion);
		xsDisableSelf();
		return;
	  }
   }

   if ((numSettlements <= 0) && (numBuilders <= 10))
   {
	  if ((kbCanAffordUnit(cUnitTypeSettlementLevel1, cEconomyEscrowID) == false) || (numBuilders <= 0))
	  {
		 aiEcho("Resign: numSettlements("+numSettlements+"): numBuilders("+numBuilders+")");
		 gResignType = cResignSettlements;
		 //aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignSettlements, -1);
		 aiAttemptResign(cAICommPromptResignQuestion);
		 xsDisableSelf();
		 return;
	  }
   }
   //Don't quit if we have more than one settlement.
   if (numSettlements > 1)
	  return;

   //3. if all of my teammates have left the game.
   int activeEnemies=0;
   int activeTeammates=0;
   int deadTeammates=0;
   float currentEnemyMilPop=0.0;
   float currentMilPop=0.0;
   for (i=1; < cNumberPlayers)
   {
	  if (i == cMyID)
	  {
		 currentMilPop=currentMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
		 continue;
	  }

	  if (kbIsPlayerAlly(i) == false)
	  {
		 //Increment the active number of enemies there currently are.
		 if (kbIsPlayerResigned(i) == false)
		 {
			activeEnemies=activeEnemies+1;
			currentEnemyMilPop=currentEnemyMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
		 }
		 continue;
	  }
	 
	  //If I still have an active teammate, don't resign.
	  if (kbIsPlayerResigned(i) == true)
		 deadTeammates=deadTeammates+1;
	  else
		 activeTeammates=activeTeammates+1;
   }

   //3a. if at least one player from my team has left the game and I am the only player left on my team, 
   //   and the other team(s) have 2 or more players in the game.
   if ((activeEnemies >= 2) && (activeTeammates <= 0) && (deadTeammates>0))
   {
	  aiEcho("Resign: activeEnemies ("+activeEnemies +"): activeTeammates ("+activeTeammates +"), deadTeammates ("+deadTeammates +")");
	  gResignType=cResignTeammates;
	  //aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignActiveEnemies, -1);
	  aiAttemptResign(cAICommPromptResignQuestion);
	  xsDisableSelf();
	  return;
   }
   
   //4. my mil pop is low and the enemy's mil pop is high,
   //Don't do this eval until 4th age and at least 30 min. into the game.
   if ((xsGetTime() < 1800000) || (kbGetAge() < 3))
	 return;
   
   static float enemyMilPopTotal=0.0;
   static float myMilPopTotal=0.0;
   static float count=0.0;
   count=count+1.0;
   enemyMilPopTotal=enemyMilPopTotal+currentEnemyMilPop;
   myMilPopTotal=myMilPopTotal+currentMilPop;
   if (count >= 10.0)
   {
	  if ((enemyMilPopTotal > (7.0*myMilPopTotal)) || (myMilPopTotal <= count))
	  {
		 aiEcho("Resign: Count("+count+"): EMP Total("+enemyMilPopTotal+"), MMP Total("+myMilPopTotal+")");
		 aiEcho("Resign: EMP Current("+currentEnemyMilPop+"), MMP Current("+currentMilPop+")");
		
		 gResignType=cResignMilitaryPop;
		 //aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignActiveEnemies, -1);
		 aiAttemptResign(cAICommPromptResignQuestion);
		 xsDisableSelf();
		 return;
	  }

	  count=0.0;
	  enemyMilPopTotal=0.0;
	  myMilPopTotal=0.0;
   }
}


//==============================================================================
// resignTimer
//==============================================================================
rule resignTimer
   minInterval 60
   inactive
{
   //This rule turns the resign rule back on after a bit of time.
   //Used when the human player refuses to allow quarter

   static bool bFirstUpdate=false;
   if (bFirstUpdate == false)
   {
	  bFirstUpdate=true;
	  return;
   }
   xsEnableRule("ShouldIResign");
}


//==============================================================================
// findVinlandsagaBase
//==============================================================================
rule findVinlandsagaBase
   minInterval 2
   inactive
{
   //Save our initial base ID.
   gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);

   //Get our initial location.
   vector location=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   //Find the mainland area group.
   int mainlandGroupID=-1;
   if (cvRandomMapName == "vinlandsaga")
	  mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 3.0, kbAreaGetIDByPosition(location));
   else
	  mainlandGroupID=kbFindAreaGroupByLocation(cAreaGroupTypeLand, 0.5, 0.5);  // Can fail if mountains at map center
//  mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 1.2, kbAreaGetIDByPosition(location));   // Instead, look for one 20% larger than start area group.

   if (mainlandGroupID < 0)
	  return;
   aiEcho("findVinlandsagaBase: Found the mainland, AGID="+mainlandGroupID+".");

   // stop the transport right away
   int transportID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
   aiEcho("Stopping transport "+transportID);
   aiTaskUnitMove(transportID, kbUnitGetPosition(transportID));

   //Create the mainland base.
   int mainlandBaseGID=createBaseGoal("Mainland Base", cGoalPlanGoalTypeMainBase,
	  -1, 1, 0, -1, kbBaseGetMainID(cMyID));
   if (mainlandBaseGID >= 0)
   {
	  //Set the area ID.
	  aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanAreaGroupID, 0, mainlandGroupID);
	  //Create the callback goal.
	  int callbackGID=createCallbackGoal("Vinlandsaga Base Callback", "vinlandsagaBaseCallback",
		 1, 0, -1, false);
	  if (callbackGID >= 0)
		 aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanDoneGoal, 0, callbackGID);
   }

   //Done.
   xsDisableSelf();
}  



//==============================================================================
// vinlandsagaFailsafe
//==============================================================================
rule vinlandsagaFailsafe
   minInterval 60
   inactive
{
   //Make a plan to explore with the initial transport.
	gVinlandsagaTransportExplorePlanID=aiPlanCreate("Vinlandsaga Transport Explore", cPlanExplore);
   aiEcho("Transport explore plan: "+gVinlandsagaTransportExplorePlanID);
	if (gVinlandsagaTransportExplorePlanID >= 0)
	{
	  aiPlanAddUnitType(gVinlandsagaTransportExplorePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 1, 1, 1);
		aiPlanSetDesiredPriority(gVinlandsagaTransportExplorePlanID, 1);
	  aiPlanSetVariableBool(gVinlandsagaTransportExplorePlanID, cExplorePlanDoLoops, 0, false);
	  aiPlanSetActive(gVinlandsagaTransportExplorePlanID);
	  aiPlanSetEscrowID(gVinlandsagaTransportExplorePlanID);
	}
   xsDisableSelf();
}

//==============================================================================
// vinlandsagaEnableFishing
//==============================================================================
rule vinlandsagaEnableFishing
   minInterval 10
   inactive
{
   //See how many wood dropsites we have.
   static int wdQueryID=-1;
   //If we don't have a query ID, create it.
   if (wdQueryID < 0)
   {
	  wdQueryID=kbUnitQueryCreate("Wood Dropsite Query");
	  //If we still don't have one, bail.
	  if (wdQueryID < 0)
		 return;
	  //Else, setup the query data.
	  kbUnitQuerySetPlayerID(wdQueryID, cMyID);
	  if (cMyCulture == cCultureGreek)
		 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStorehouse);
	  else if (cMyCulture == cCultureEgyptian)
		 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLumberCamp);
	  else if (cMyCulture == cCultureNorse)
		 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLogicalTypeLandMilitary);
	  else if (cMyCulture == cCultureChinese)
	  {
		 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStoragePit);
	  }
	  kbUnitQuerySetAreaGroupID(wdQueryID, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) );
	  kbUnitQuerySetState(wdQueryID, cUnitStateAlive);
   }
   //Reset the results.
   kbUnitQueryResetResults(wdQueryID);
   //Run the query.  If we don't have anything, skip.
   if ( (kbUnitQueryExecute(wdQueryID)<= 0) && (cMyCulture == cCultureGreek))
	  return;

   //Enable the rule.
   xsEnableRule("fishing");
   //Unpause the age upgrades.
   aiSetPauseAllAgeUpgrades(false);
   //Unpause the pause kicker.
   xsEnableRule("unPauseAge2");
   xsSetRuleMinInterval("unPauseAge2", 15);

   //Create a simple plan to maintain X Ulfsarks (since we didn't do this as part of initNorse).
   createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, true, kbBaseGetMainID(cMyID));

   //Disable us.
   xsDisableSelf();
}  


bool hasWaterNeighbor(int areaID = -1)  // True if the test area has a water area neighbor
{
   int areaCount = -1;
   int areaIndex = -1;
   int testArea = -1;
   bool hasWater = false;

   areaCount = kbAreaGetNumberBorderAreas(areaID);
   if (areaCount > 0)
   {
	  for (areaIndex=0; < areaCount)
	  {
		 testArea = kbAreaGetBorderAreaID(areaID, areaIndex);
		 if ( kbAreaGetType(testArea) == cAreaTypeWater )
			hasWater = true;
	  }
   }
   if (hasWater == true)
	  aiEcho("  "+areaID+" has a water neighbor.");
//   else
//  aiEcho("  "+areaID);

   return(hasWater);
}


//==============================================================================
// verifyVinlandsagaBase - verify that this area borders water, find another if it doesn't.
//==============================================================================
int verifyVinlandsagaBase(int goalAreaID = -1, int recurseCount = 3 )
{
   int newAreaID = goalAreaID;  // New area will be the one we use.  By default,
									// we'll start with the one passed to us.
   bool done = false;   // Set true when we find an acceptable one
   int index = -1;  // Which number are we checking
   int areaCount = -1;  // How many areas to search
   int testArea = -1;

   if (recurseCount == 3)   // 3 more levels allowed
	  aiEcho("***** Beginning verifyVinlandsagaBase "+goalAreaID);
   else if (recurseCount == 2)
	  aiEcho("  "+goalAreaID);
   else if (recurseCount == 1)
	  aiEcho("  "+goalAreaID);
   else if (recurseCount == 0)
	  aiEcho("   "+goalAreaID);

   if (hasWaterNeighbor(goalAreaID) == true)	// Simple case
   {
	  aiEcho("Target area "+goalAreaID+" has a water neighbor...using it.");
	  return(goalAreaID);
   }
/*
   // Test each border area, breadth first
   for (index=0; < kbAreaGetNumberBorderAreas(goalAreaID))  // Get each border area
   {
	  testArea = kbAreaGetBorderAreaID(goalAreaID, index);
	  if ( hasWaterNeighbor(testArea) == true)
	  {
		 newAreaID = testArea;
		 done = true;
		 break;
	  }
   }

   if (done == true)
   {
	  aiEcho("Will use area "+newAreaID);
	  return(newAreaID);
   }
*/
   int recurseLevel = 0;
   if (recurseCount > 0)
   {
	  for( recurseLevel=0; < recurseCount)
	  {
		 aiEcho("Area "+goalAreaID+" has "+kbAreaGetNumberBorderAreas(goalAreaID)+" neighbors.");
		 aiEcho("Testing "+(recurseLevel+1)+" layers around area "+goalAreaID);
		 // Test each area that borders each border area.  
		 for (index=0; < kbAreaGetNumberBorderAreas(goalAreaID))  // Get each border area
		 {
			testArea = kbAreaGetBorderAreaID(goalAreaID, index);
			if ( verifyVinlandsagaBase(testArea, recurseLevel) > 0)
			{
			   return(testArea);
			}
		 }
//   if (recurseLevel == 2)
//  breakpoint;
	  }
   }


   if (recurseCount == 3)   // Sigh, just fail and return -1.
	  aiEcho("Couldn't find a water-bordered area.");
   return(-1);
}


//==============================================================================
// vinlandsagaBaseCallback
//==============================================================================
void vinlandsagaBaseCallback(int parm1=-1)
{
   aiEcho("VinlandsagaBaseCallback:");

   //Get our water transport type.
   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   if (transportPUID < 0)
	  return;
   //Get our main base.  This needs to be different than our initial base.
   if (kbBaseGetMainID(cMyID) == gVinlandsagaInitialBaseID)
	  return;

   //Kill the transport explore plan.
   aiPlanDestroy(gVinlandsagaTransportExplorePlanID);
   xsDisableRule("vinlandsagaFailsafe");
   //Kill the land scout explore.
   aiPlanDestroy(gLandExplorePlanID);
   //Create a new land based explore plan for the mainland.
	gLandExplorePlanID=aiPlanCreate("Explore_Land_VS", cPlanExplore);
   if (gLandExplorePlanID >= 0)
   {
	  aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);
	  aiPlanSetActive(gLandExplorePlanID);
	  aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
	  aiPlanSetBaseID(gLandExplorePlanID, kbBaseGetMainID(cMyID));
	  //Don't loop as egyptian.
	  if (cMyCulture == cCultureEgyptian)
		 aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
   }

   //Get our start area ID.
   int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
   //Get our goal area ID.
   int goalAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

   goalAreaID = verifyVinlandsagaBase( goalAreaID );  // Make sure it borders water,or find one that does.
/*
   //Create the scout xport plan.  If it works, add the unit type(s).
   int planID=createTransportPlan("Scout Transport", startAreaID, goalAreaID,
	  false, transportPUID, 100, gVinlandsagaInitialBaseID);
   if (planID >= 0)
   {
	  aiPlanAddUnitType(planID, gLandScout, 1, 1, 1);
	  if (cMyCulture == cCultureNorse)
		 aiPlanAddUnitType(planID, cUnitTypeOxCart, 1, 1, 1);
	  //We require all need units on this one.
	  aiPlanSetRequiresAllNeedUnits(planID, true);
   }
*/
   //Create the scout/villager xport plan.  If it works, add the unit type(s).
   int planID=createTransportPlan("Villager Transport", startAreaID, goalAreaID,
	  true, transportPUID, 100, gVinlandsagaInitialBaseID);
   if (planID >= 0)
   {
	  aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 1, 5, 5);
	  if (cMyCulture == cCultureAtlantean)
			 aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 1, 3, 3);
	  aiPlanAddUnitType(planID, cUnitTypeLogicalTypeLandMilitary, 0, 1, 1);
	  aiPlanAddUnitType(planID, gLandScout, 1, 1, 1);
	  if (cMyCulture == cCultureNorse)
		 aiPlanAddUnitType(planID, cUnitTypeOxCart, 0, 1, 4);
   }
   aiEcho("Transport plan ID is "+planID);

   //change the farming baseID
   gFarmBaseID=kbBaseGetMainID(cMyID);

   //Allow auto dropsites again.
   aiSetAllowAutoDropsites(true);
   aiSetAllowBuildings(true);

   xsDisableRule("setEarlyEcon");
   xsEnableRule("econForecastAge1Mid");

   //Enable the rule that will eventually enable fishing and other stuff.
   xsEnableRule("vinlandsagaEnableFishing");
}

//==============================================================================
// nomadBuildSettlementCallBack
//==============================================================================
void nomadBuildSettlementCallBack(int parm1=-1)
{
   aiEcho("nomadBuildSettlementCallBack:");

   //Find our one settlement.and make it the main base.
   int settlementID=findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement);
   if (settlementID < 0)
   {
	  //Enable the rule that looks for a settlement.
	  int nomadSettlementGoalID = -1;
	  if(cMyCulture == cCultureChinese)
	  {
		nomadSettlementGoalID = createBuildSettlementGoal("BuildNomadSettlement", 0, -1, -1, 1, cUnitTypeVillagerChinese, true, 100);
	  }
	  else
	  nomadSettlementGoalID  = createBuildSettlementGoal("BuildNomadSettlement", 0, -1, -1, 1, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0), true, 100);
	  if (nomadSettlementGoalID != -1)
	  {
		 //Create the callback goal.
		 int nomadCallbackGID=createCallbackGoal("Nomad BuildSettlement Callback", "nomadBuildSettlementCallBack", 1, 0, -1, false);
		 if (nomadCallbackGID >= 0)
			aiPlanSetVariableInt(nomadSettlementGoalID, cGoalPlanDoneGoal, 0, nomadCallbackGID);
	  }
	  return;
   }

   //Kill the villie explore plan.
   aiPlanDestroy(gNomadExplorePlanID1);

   //Find our one settlement and make it the main base.
   int newBaseID=kbUnitGetBaseID(findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement));
   aiSwitchMainBase(newBaseID, true);
   kbBaseSetMain(cMyID, newBaseID, true);

   //Unpause the age upgrades.
   aiSetPauseAllAgeUpgrades(false);
   //Unpause the pause kicker.
   xsEnableRule("unPauseAge2");
   xsSetRuleMinInterval("unPauseAge2", 15);

   //Turn on buildhouse.
   xsEnableRule("buildHouse");
   xsDisableSelf();
}

//==============================================================================
// build handler
//==============================================================================
void buildHandler(int protoID=-1) 
{
   if (protoID == cUnitTypeSettlement)
   {
	  for (i=1; < cNumberPlayers)
	  {
		 if (i == cMyID)
			continue;
		 if (kbIsPlayerAlly(i) == true)
			continue;
		 if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptAIBuildSettlement, -1);
	  }
   }
}

//==============================================================================
// god power handler
//==============================================================================
void gpHandler(int powerProtoID=-1)
{ 
   if (powerProtoID == -1)
	  return;
   if (powerProtoID == cPowerSpy)
	  return;

	// If the power is TitanGate, then we need to launch the repair plan to build it..
   if (powerProtoID == cPowerTitanGate)
   {
	  aiEcho("======< Titan Gate placed!!!>=======");
	  // Don't look for it now, just set up the rule that looks for it
	  // and then launches a repair plan to build it. 
	  xsEnableRule("repairTitanGate");
	   return;
   }


   //Most hated player chats.
   if ((powerProtoID == cPowerPlagueofSerpents) ||
	  (powerProtoID == cPowerEarthquake)		||
	  (powerProtoID == cPowerCurse) ||
	  (powerProtoID == cPowerFlamingWeapons)	|| 
	  (powerProtoID == cPowerForestFire)		||
	  (powerProtoID == cPowerFrost) ||
	  (powerProtoID == cPowerLightningStorm)	||
	  (powerProtoID == cPowerLocustSwarm)   ||
	  (powerProtoID == cPowerMeteor)			||
	  (powerProtoID == cPowerAncestors)   ||
	  (powerProtoID == cPowerFimbulwinter)  ||
	  (powerProtoID == cPowerTornado)   ||
	  (powerProtoID == cPowerBolt))
   {
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptOffensiveGodPower, -1);
	  return;
   }
   
   //Any player chats.
   int type=cAICommPromptGenericGodPower;
   if ((powerProtoID == cPowerProsperity) || 
	  (powerProtoID == cPowerPlenty)	  ||
	  (powerProtoID == cPowerLure)  ||
	  (powerProtoID == cPowerDwarvenMine) ||
	  (powerProtoID == cPowerGreatHunt)   ||
	  (powerProtoID == cPowerRain))
   {
	  type=cAICommPromptEconomicGodPower;
   }

   //Tell all the enemy players
   for (i=1; < cNumberPlayers)
   {
	  if (i == cMyID)
		 continue;
	  if (kbIsPlayerAlly(i) == true)
		 continue;
	  if( cvOkToChat == true ) aiCommsSendStatement(i, type, -1);
   }
}

//==============================================================================
// wonder death handler
//==============================================================================
void wonderDeathHandler(int playerID = -1)
{
   if (playerID == cMyID)
   {
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWonderDestroyed, -1);
	  return;
   }
   if (playerID == aiGetMostHatedPlayerID())
	  if( cvOkToChat == true ) aiCommsSendStatement(playerID, cAICommPromptPlayerWonderDestroyed, -1);
}


//==============================================================================
// retreat handler
//==============================================================================
void retreatHandler(int planID = -1)
{
   if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIRetreat, -1);
}

//==============================================================================
// relic handler
//==============================================================================
void relicHandler(int relicID = -1)
{
   if (aiRandInt(3) != 0)
	  return;

   for (i=1; < cNumberPlayers)
   {
	  if (i == cMyID)
		 continue;

	  //Only a 33% chance for either of these chats
	  if (kbIsPlayerAlly(i) == true)
	  {
		 if (relicID != -1)
		 {
			vector position = kbUnitGetPosition(relicID);
			if( cvOkToChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptTakingAllyRelic, -1, position);
		 }
		 else 
			if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptTakingAllyRelic, -1);
	  }
	  else 
		 if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptTakingEnemyRelic, -1);
   }
}

//==============================================================================
// relic handler
//==============================================================================
void resignHandler(int result =-1)
{
   if (result == 0)
   {
	  //xsEnableRule("resignTimer");
	  return;
   }

   if (gResignType == cResignGatherers)
   {
	  aiResign();
	  return;
   }
   if (gResignType == cResignSettlements)
   {
	  aiResign();
	  return;
   }
   if (gResignType == cResignTeammates)
   {
	  aiResign();
	  return;
   }
   if (gResignType == cResignMilitaryPop)
   {
	 aiResign();
	 return;
   }
}



//==============================================================================
// attackMonitor
//==============================================================================
rule attackMonitor
minInterval 6
active
{

   // Find the attack plans
   int numPlans = aiPlanGetNumber(cPlanAttack, -1, true );  // Attack plans, any state, active only
   
   int highestID = aiPlanGetIDByIndex(cPlanAttack, -1, true, numPlans - 1); // Assuming most recent at end
   if ( (highestID > gMostRecentAttackPlanID) && (aiPlanGetVariableInt(highestID, cAttackPlanFromGoalID, 0) != gNavalAttackGoalID) )
   {	 // It's not the last land attack, and this one isn't naval...
	  gMostRecentAttackPlanID = highestID;
	  aiEcho("New attack plan, "+gMostRecentAttackPlanID);
	  //aiPlanSetNumberVariableValues(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 4, true);
	  //aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeDropsite);
	  //aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeOxCart);
	  //aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeUnit);
	  //aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeBuilding);
	  //aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRefreshFrequency, 0, 15);
	  // Reactivate the defend plan
	  xsEnableRule("defendPlanRule");

	  // Adjust the "retreat factor" for the next attack
	  if ( cvOffenseDefenseSlider < 0)
	  {
		 int goalID = -1;
		 if (kbGetAge() == cAge2)
		 {
			goalID = gRushGoalID;  
		 }
		 else  // Age 3 or 4
		 {
			goalID = gLandAttackGoalID;
		 }
		 int oddsOfRetreat = -50 * cvOffenseDefenseSlider; // 50 for totally defensive, 0 for neutral or aggressive
		 if (aiRandInt(101) < oddsOfRetreat)
		 {
			aiEcho("Next attack is allowed to retreat.");
			aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, true);
		 }
		 else
		 {
			aiEcho("Next attack is not allowed to retreat.");
			aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, false);
		 }
	  }
   }

   if (gMostRecentAttackPlanID >= 0)
   {  
	  if ( aiPlanGetNumberVariableValues(gMostRecentAttackPlanID, cAttackPlanTargetAreaGroups) > 1 )  // Plan could attack other continent
	  {
		 if (aiPlanGetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0) != cAttackPlanRetreatModeNone )   // It's allowed to retreat
		 {
			aiEcho("***** Turning off retreat for possible remote attack plan "+gMostRecentAttackPlanID);
			aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
		 }
	  }
	  
	  // Check to see if the gather phase is taking too long and just launch the attack if so.
	  if (aiPlanGetState(gMostRecentAttackPlanID) == cPlanStateGather)
		 if ( aiPlanGetVariableInt(gMostRecentAttackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime()-20000) )
		 {
			aiPlanSetVariableFloat(gMostRecentAttackPlanID, cAttackPlanGatherDistance, 0, 300.0);
			//aiEcho("*****  Gather timed out, attacking anyway.");
		 }
   }

}

//==============================================================================
// attackChatCallback
//==============================================================================
void attackChatCallback(int parm1=-1)
{
	if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIAttack, -1); 
	aiEcho("Launching an attack.");
	if (kbGetAge() == cAge2)
	{
	   // This was a rush.  If it was the first of several, adjust the attack size in the unit picker
	   int numPlanned = -1;
	   int numLaunched = -1;
	   int numRemaining = -1;
	   int fullSize = 0;
	   int targetSize = 0;
	   float   adjustFraction = 0.0;
	   numPlanned = aiPlanGetVariableInt(gRushGoalID, cGoalPlanRepeat, 0);
	   numLaunched = aiPlanGetVariableInt(gRushGoalID,cGoalPlanExecuteCount, 0);
	   numRemaining = numPlanned - numLaunched;
	   if (numPlanned < 2)   // No adjustments if 0 or 1 planned
		  return;
	   if (numRemaining <= 0)   // Done, no adjustments needed
		  return;
	   if (numLaunched >= 3)	 // Adjust twice at most
		  return;

	   fullSize = kbUnitPickGetMaximumPop(gRushUPID);
	   fullSize = (fullSize * 4) / 5;   // Eventual size is 80% of max

	   adjustFraction = 1.0;  // Assuming this is only called once
	   targetSize = kbUnitPickGetMinimumPop(gRushUPID) + (fullSize - kbUnitPickGetMinimumPop(gRushUPID)) * adjustFraction;
	   kbUnitPickSetMinimumPop(gRushUPID, targetSize);
	   aiEcho("Adjusting attack size to "+targetSize);
	}
}

//==============================================================================
// findTownDefenseGP
//==============================================================================
void findTownDefenseGP(int baseID=-1)
{

   if (gTownDefenseGodPowerPlanID != -1)
	  return;
   gTownDefenseGodPowerPlanID=aiFindBestTownDefenseGodPowerPlan();
   if (gTownDefenseGodPowerPlanID == -1)
	  return;

   //Change the evaluation model (and remember it).
   gTownDefenseEvalModel=aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0);
   aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
   //Change the player (and remember it).
   gTownDefensePlayerID=aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0);
   //Set the location.
   aiPlanSetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) );
}

//==============================================================================
// releaseTownDefenseGP
//==============================================================================
void releaseTownDefenseGP()
{
   if (gTownDefenseGodPowerPlanID == -1)
	  return;
   //Change the evaluation model back.
   aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, gTownDefenseEvalModel);
   //Reset the player.
   aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0, gTownDefensePlayerID);
   //Release the plan.
   gTownDefenseGodPowerPlanID=-1;
   gTownDefenseEvalModel=-1; 
   gTownDefensePlayerID=-1;
}

//==============================================================================
// RULE introChat
//==============================================================================
rule introChat
   minInterval 15
   active
{
   if (aiGetWorldDifficulty() != cDifficultyEasy)
   {
	  for (i=1; < cNumberPlayers)
	  {
		 if (i == cMyID)
			continue;
		 if (kbIsPlayerAlly(i) == true)
			continue;
		 if (kbIsPlayerHuman(i) == true)
			if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptIntro, -1);
	  }
   }

   xsDisableSelf();
}


//==============================================================================
// RULE myAgeTracker
//==============================================================================
rule myAgeTracker
   minInterval 60
   active
{
   static bool bMessage=false;
   static int messageAge=-1;

   //Disable this in deathmatch.
   if (aiGetGameMode() == cGameModeDeathmatch)
   {
	  xsDisableSelf();
	  return;
   }

   //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
	  return;

   //Are we greater age than our most hated enemy?
   int myAge=kbGetAge();
   int hatedPlayerAge=kbGetAgeForPlayer(aiGetMostHatedPlayerID());

   //Reset the message counter if we have changed ages.
   if (bMessage == true)
   {
	  if (messageAge == myAge)
		 return;
	  bMessage=false;
   }

   //Make a message??
   if ((myAge > hatedPlayerAge) && (bMessage == false))
   {
	  bMessage=true;
	  messageAge=myAge;
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWinningAgeRace, -1);
   }
   if ((hatedPlayerAge > myAge) && (bMessage == false))
   {
	  bMessage=true;
	  messageAge=myAge;
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILosingAgeRace, -1);
   }

   //Stop when we reach the finish line.
   if (myAge == cAge4)
	  xsDisableSelf();
}

//==============================================================================
// RULE mySettlementTracker
//==============================================================================
rule mySettlementTracker
   minInterval 11
   active
{
   static int tcCountQueryID=-1;
   //Only the captain does this
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
	  return;

   //If we don't have a query ID, create it.
   if (tcCountQueryID < 0)
   {
	  tcCountQueryID=kbUnitQueryCreate("SettlementCount");
	  //If we still don't have one, bail.
	  if (tcCountQueryID < 0)
		 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerID(tcCountQueryID, cMyID);
   kbUnitQuerySetUnitType(tcCountQueryID, cUnitTypeAbstractSettlement);
   kbUnitQuerySetState(tcCountQueryID, cUnitStateAlive);

   //Reset the results.
   kbUnitQueryResetResults(tcCountQueryID);
   //Run the query.  Be dumb and just take the first TC for now.
   int count=kbUnitQueryExecute(tcCountQueryID);

   if ((count < gNumberMySettlements) && (gNumberMySettlements != -1))
   {
	  if (count == 0)
		 if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILostLastSettlement, -1);
	  else
		 if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILostSettlement, -1);
   }

   //Set the number.
   gNumberMySettlements=count;
}


//==============================================================================
// RULE earlySettlementTracker
//==============================================================================
rule earlySettlementTracker
   minInterval 15
   active
{
   //If this is 3rd age, go away.
   if (kbGetAge() >= 2)
   {
	  xsDisableSelf();
	  return;
   }

   //If we have no alive or building settlements, return.
   if (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0)
	  return;
   //If we have a plan to build a settlement, return.
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSettlementLevel1) > -1)
	  return;

   xsEnableRule("buildSettlements");
   xsDisableSelf();
}

//==============================================================================
// RULE enemySettlementTracker
//==============================================================================
rule enemySettlementTracker
   minInterval 9
   active
{
  //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
	  return;

   if (gTrackingPlayer == -1)
	  gTrackingPlayer = aiGetMostHatedPlayerID(); 

   bool reset=false;
   if (aiGetMostHatedPlayerID() != gTrackingPlayer)
   {
	  gTrackingPlayer = aiGetMostHatedPlayerID();
	  gNumberTrackedPlayerSettlements = -1;
	  reset = true;
   }

   if (gTrackingPlayer == -1)
	  return;

   static int tcCountQueryID=-1;
   //If we don't have a query ID, create it.
   if (tcCountQueryID < 0)
   {
	  tcCountQueryID=kbUnitQueryCreate("SettlementCount");
	  //If we still don't have one, bail.
	  if (tcCountQueryID < 0)
		 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerID(tcCountQueryID, gTrackingPlayer);
   kbUnitQuerySetUnitType(tcCountQueryID, cUnitTypeAbstractSettlement);
   kbUnitQuerySetState(tcCountQueryID, cUnitStateAlive);

   //Reset the results.
   kbUnitQueryResetResults(tcCountQueryID);
   //Run the query.  Be dumb and just take the first TC for now.
   int count=kbUnitQueryExecute(tcCountQueryID);

   //If we are doing a reset, then just get out after storing the count.
   if (reset == true)
   {
	  gNumberTrackedPlayerSettlements=count;
	  return;
   }

   //If the number of settlements is greater than 1, and we have not sent a message.
   if ((count > 1) && (gNumberTrackedPlayerSettlements == -1))
   {
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptEnemyBuildSettlement, -1);
	  gNumberTrackedPlayerSettlements=count;
   }

   //If the number of settlements is equal to one and we have sent a message
   //about them growing, then send one about the loss of territory
   if ((count == 1) && (gNumberTrackedPlayerSettlements > 1))
   {
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptEnemyLostSettlement, -1);
	  gNumberTrackedPlayerSettlements=1;
   }

   //The count is = 0, and we think they have nothing left, and we have already sent a message
   if ((count == 0) && (gNumberTrackedPlayerSettlements != -1))
   { 
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptEnemyLostSettlement, -1);
	  gNumberTrackedPlayerSettlements=-1;
   }
}

//==============================================================================
// RULE enemyWallTracker
//==============================================================================
rule enemyWallTracker
   minInterval 61
   active
{
   static int wallCountQueryID=-1;
   //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
	  return;

   //If we don't have a query ID, create it.
   if (wallCountQueryID < 0)
   {
	  wallCountQueryID=kbUnitQueryCreate("WallCount");
	  //If we still don't have one, bail.
	  if (wallCountQueryID < 0)
		 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerID(wallCountQueryID, aiGetMostHatedPlayerID());
   kbUnitQuerySetUnitType(wallCountQueryID, cUnitTypeAbstractWall);
   kbUnitQuerySetState(wallCountQueryID, cUnitStateAlive);

   //Reset the results.
   kbUnitQueryResetResults(wallCountQueryID);
   //Run the query. 
   int count=kbUnitQueryExecute(wallCountQueryID);

   //Do we have enough knowledge of walls to send a message?
   if (count > 10)
   {
	  if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptPlayerBuildingWalls, -1); 
	  //Kill this rule.
	  xsDisableSelf();  
   }
}

//==============================================================================
// RULE baseAttackTracker
//==============================================================================
rule baseAttackTracker
   minInterval 23
   active
{
   static bool messageSent=false;
   //Set our min interval back to 23 if it has been changed.
   if (messageSent == true)
   {
	  xsSetRuleMinIntervalSelf(23);
	  messageSent=false;
   }

   //Get our main base.
   int mainBaseID=kbBaseGetMainID(cMyID);
   if (mainBaseID < 0)
	  return;

   //Get the time under attack.
   int secondsUnderAttack=kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
   if (secondsUnderAttack < 30)
		 return;

   vector location=kbBaseGetLastKnownDamageLocation(cMyID, kbBaseGetMainID(cMyID));
   for (i=1; < cNumberPlayers)
   {
	  if (i == cMyID)
		 continue;
	  if(kbIsPlayerAlly(i) == true)
		 if( cvOkToChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptHelpHere, -1, location);
   } 
   
   //Try to use a god power to help us.
   findTownDefenseGP(kbBaseGetMainID(cMyID));  

   //Keep the books
   messageSent=true;
   xsSetRuleMinIntervalSelf(600);  
}

//==============================================================================
// RULE repairBuildings
//==============================================================================
rule repairBuildings
   minInterval 12
   inactive
{
   int buildingID=kbFindBestBuildingToRepair(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), 50.0, 1.0, cUnitTypeBuildingsThatShoot);
   if (buildingID >= 0)
   {
	  //Don't create another plan for the same building.
	  if (aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true) >= 0)
		 return;
	  
	  //Create the plan.
	  static int num=0;
	  num=num+1;
	  string planName="Repair_"+num;
	  int planID=aiPlanCreate(planName, cPlanRepair);
	  if (planID < 0)
		 return;

	  aiPlanSetDesiredPriority(planID, 100);
	  aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
	  aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
	  aiPlanSetInitialPosition(planID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	  if(cMyCulture == cCultureChinese)
	  {
		aiPlanAddUnitType(planID, cUnitTypeVillagerChinese, 1, 1, 5); 
	  }
	  else
	  aiPlanAddUnitType(planID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 5);
	  if (cMyCulture == cCultureAtlantean)
		 aiPlanAddUnitType(planID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetActive(planID);
   }
}

//==============================================================================
// RULE townDefense
//==============================================================================
rule townDefense
   minInterval 11
   inactive
{
   //Get our main base ID.
   int mainBaseID=kbBaseGetMainID(cMyID);
   if (mainBaseID < 0)
	  return;
   //Get the time under attack.
   int secondsUnderAttack=kbBaseGetTimeUnderAttack(cMyID, mainBaseID);

   //Factor in a dulled Moderate response for the rest of this.
   if (aiGetWorldDifficulty() == cDifficultyModerate)
   {
	  if (secondsUnderAttack < 30)
		 return;
   }
   else
   {
	  if (secondsUnderAttack < 10)
		 return;
   }

   //If the enemy has > 4 military units that we've seen and we've been attacked in our town,
   //tower up.
   if (gBuildTowers == false)
   {
	  int numHatedUnits=kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeMilitary, cUnitStateAlive);
	  if (numHatedUnits > 4)
	  {
		 aiEcho("townDefense:  Player "+aiGetMostHatedPlayerID()+" has "+numHatedUnits+" units, upgrading towers.");
		 //gBuildTowers=true;
		 //towerInBase("Defensive Towers", false, 2, cMilitaryEscrowID);   // Removed tower decision here, just get upgrades
		 xsEnableRule("towerUpgrade");
	  }
   }

   //If we've been under siege for long enough, see if we have enough stuff to
   //be worried.
   int numberEnemyUnits=kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeUnit);
   int numberEnemyMilitaryBuildings=kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeMilitaryBuilding);
   if ((numberEnemyUnits < 2) && (numberEnemyMilitaryBuildings <= 0))
	  return;

   //We're worried.  If we're in the first age, ensure that we go up fast.  If 
   //we're not in the first age, ensure that we have an attack goal setup for
   //the current age. If not, create one.
   /*Disabled because it messes with pop distribution
   switch (kbGetAge())
   {
	  //First age.
	  case 0:
	  {
		 //Go attack econ with minimal villagers.
		 updateEM(50, 12, 0.5, 0.75, 0.5, 0.5, 0.5, 0.0);
		 //Turn off the standard rule.
		 xsDisableRule("updateEMAge1");
		 break;
	  }

	  //Second age.
	  case 1:
	  {
		 //Go attack econ with minimal villagers.
		 updateEM(75, 22, 0.5, 0.75, 0.0, 0.0, 0.0, 0.0);
		 //Turn off the standard rule.
		 xsDisableRule("updateEMAge2");
		 break;
	  }

	  //Don't do anything else in 3rd or 4th.
   }
   */
}

//==============================================================================
// RULE fillInWallGaps
//==============================================================================
rule fillInWallGaps
   minInterval 31
   inactive
{
   //If we're not building walls, go away.
   if (gBuildWalls == false)
   {
	  xsDisableSelf();
	  return;
   }

   //If we already have a build wall plan, don't make another one.
   if(aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true) >= 0)
	  return;
/*old
   int wallPlanID=aiPlanCreate("FillInWallGaps", cPlanBuildWall);
   if (wallPlanID != -1)
   {
	  aiPlanSetVariableInt(wallPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeRing);
	  aiPlanAddUnitType(wallPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetVariableVector(wallPlanID, cBuildWallPlanWallRingCenterPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	  aiPlanSetVariableFloat(wallPlanID, cBuildWallPlanWallRingRadius, 0, 45.0 - (10.0*cvRushBoomSlider));
	  aiPlanSetVariableInt(wallPlanID, cBuildWallPlanNumberOfGates, 0, 5);
	  aiPlanSetBaseID(wallPlanID, kbBaseGetMainID(cMyID));
	  aiPlanSetEscrowID(wallPlanID, cMilitaryEscrowID);
	  aiPlanSetDesiredPriority(wallPlanID, 100);
	  aiPlanSetActive(wallPlanID, true);
   }
*/
	  gWallPlanID = aiPlanCreate("FillInWallGaps", cPlanBuildWall);   // Empty wall plan, will store area list there.

	  float baseRadius = 32.0 - (11.0*cvRushBoomSlider);			  // Not really a 'radius', will be edge of square
	  /*
		 New area-based walling.  The concept is to get a list of appropriate areas, pass them to the walling plan,
		 and have it build a wall around the convex hull defined by that area list.  To do this, I take this approach.
		 1) Define a 'radius', which is the length of a square zone that we want to enclose.
		 2) Add the center area to the list.
		 3) For each area within 2 layers of that center area, include it if its in the same area group and
		   a) its center is within that area, or
		   b) it is a gold area, or
		   c) it is a settlement area.
	  */

	  aiPlanSetNumberVariableValues(gWallPlanID, cBuildWallPlanAreaIDs, 20, true);
	  int numAreasAdded = 0;

	  int mainArea = -1;
	  vector mainCenter = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	  float mainX = xsVectorGetX(mainCenter);
	  float mainZ = xsVectorGetZ(mainCenter);
	  mainArea = kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	  aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
	  numAreasAdded = numAreasAdded + 1;
	  
	  int firstRingCount = -1;  // How many areas are in first ring around main?
	  int firstRingIndex = -1;  // Which one are we on?
	  int secondRingCount = -1;  // How many border areas does the current first ring area have?
	  int secondRingIndex = -1;  
	  int firstRingID = -1;   // Actual ID of current 1st ring area
	  int secondRingID = -1;
	  vector areaCenter = cInvalidVector;   // Center point of this area
	  float areaX = 0.0;
	  float dx = 0.0;
	  float areaZ = 0.0;
	  float dz = 0.0;
	  int areaType = -1;
	  bool  needToSave = false;

	  firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
	  for (firstRingIndex = 0; < firstRingCount)	  // Check each border area of the main area
	  {
		 needToSave = true;   // We'll save this unless we have a problem
		 firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
		 areaCenter = kbAreaGetCenter(firstRingID);
		 // Now, do the checks.
			areaX = xsVectorGetX(areaCenter);
			areaZ = xsVectorGetZ(areaCenter);
			dx = mainX - areaX;
			dz = mainZ - areaZ;
			if ( (dx > baseRadius) || (dx < (-1.0*baseRadius)) )
			{
			   needToSave = false;
			}
			if ( (dz > baseRadius) || (dz < (-1.0*baseRadius)) )
			{
			   needToSave = false;
			}
			// Override if it's a special type
			areaType = kbAreaGetType(firstRingID);
			if ( areaType == cAreaTypeGold)
			{
			   needToSave = true;
			}
			if ( areaType == cAreaTypeSettlement )
			{
			   needToSave = true;
			}
		 // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
		 if (needToSave == true)
		 {
			int i = -1;
			bool found =false;
			for (i=0; < numAreasAdded)
			{
			   if (aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, i) == firstRingID)
			   {
				  found = true;  // It's in there, don't add it
			   }
			}
			if ((found == false) && (numAreasAdded < 20))  // add it
			{
			   aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
			   numAreasAdded = numAreasAdded + 1;
			   // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
				 secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);  // How many does it touch?
				  for (secondRingIndex=0; < secondRingCount)
				  {  // Check each border area.  If it's gold or settlement and not already in list, add it.
					 secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
					 if ( (kbAreaGetType(secondRingID) == cAreaTypeSettlement) || (kbAreaGetType(secondRingID) == cAreaTypeGold) )
					 {
						bool skipme = false;	   // Skip it if center is more than 10m outside normal radius
						areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
						areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
						dx = mainX - areaX;
						dz = mainZ - areaZ;
						if ( (dx > (baseRadius+10.0)) || (dx < (-1.0*(baseRadius+10.0))) )
						{
						   skipme = true;
						}
						if ( (dz > (baseRadius+10.0)) || (dz < (-1.0*(baseRadius+10.0))) )
						{
						   skipme = true;
						}
						bool alreadyIn = false;
						int m=0;
						for (m=0; < numAreasAdded)
						{
						   if (aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, m) == secondRingID)
						   {
							  alreadyIn = true;  // It's in there, don't add it
						   }
						}
						if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
						{
						   aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
						   numAreasAdded = numAreasAdded + 1;
						}
					 }
				  }
			 }
		 }
	  }

	  int j = -1;
//  aiEcho("  Area list:");
//  for (j=0; < numAreasAdded)
//   aiEcho("   "+aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, j));

	  // Set the true number of area variables, preserving existing values, then turn on the plan
	  aiPlanSetNumberVariableValues(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

	  aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
	  if(cMyCulture == cCultureChinese)
	  {
		aiPlanAddUnitType(gWallPlanID, cUnitTypeVillagerChinese, 1, 1, 1);
	  }
	  else
	  aiPlanAddUnitType(gWallPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanNumberOfGates, 0, 10);
	  aiPlanSetVariableFloat(gWallPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
	  aiPlanSetBaseID(gWallPlanID, kbBaseGetMainID(cMyID));
	  aiPlanSetEscrowID(gWallPlanID, cMilitaryEscrowID);
	  aiPlanSetDesiredPriority(gWallPlanID, 100);
	  aiPlanSetActive(gWallPlanID, true);
}


//==============================================================================
// RULE findFish:  We don't know if this is a water map...if you see fish, it is.
//==============================================================================
rule findFish
   minInterval 11
   inactive
{
   //Create the fish query.
   static int unitQueryID=-1;
   if(unitQueryID < 0)
	  unitQueryID = kbUnitQueryCreate("findFish");
	//Define a query to get all matching units
	if (unitQueryID == -1)
	  return;

   //Run it.
	kbUnitQuerySetPlayerID(unitQueryID, 0);
   kbUnitQuerySetUnitType(unitQueryID, cUnitTypeFish);
   kbUnitQuerySetState(unitQueryID, cUnitStateAny);
	kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);
   if (numberFound > 0)
   {
	  gWaterMap=true;
	  
	  //Tell the AI what kind of map we are on.
	  aiSetWaterMap(gWaterMap);

	  xsEnableRule("fishing");

	  if (cMyCiv != cCivPoseidon)
		 createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

	  //Enable our naval attack goal starter.
	  if (aiGetWorldDifficulty() != cDifficultyEasy)
		 xsEnableRule("NavalGoalMonitor");

	  //Fire up.
	  if (gMaintainWaterXPortPlanID < 0)
		 gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 1, false, -1);

	  xsDisableSelf();
   }
}

//==============================================================================
// RULE getKingOfTheHillVault
//==============================================================================
rule getKingOfTheHillVault
   minInterval 17
   runImmediately
   active
{
   //If we're not on KOTH, go away.
   if ((cvRandomMapName != "king of the hill") || (gKOTHPlentyUnitID == -1))
   {
	  xsDisableSelf();
	  return;
   }

   //If we already have a attack goals, then quit.
   if (aiPlanGetIDByTypeAndVariableType(cPlanGoal, cGoalPlanGoalType, cGoalPlanGoalTypeAttack, true) >= 0)
	  return;
   //If we already have a scout plan for this, bail.
   if (aiPlanGetIDByTypeAndVariableType(cPlanExplore, cExplorePlanNumberOfLoops, -1, true) >= 0)
	  return;
   
   //Create an explore plan to go there.
   vector unitLocation=kbUnitGetPosition(gKOTHPlentyUnitID);
   int exploreID=aiPlanCreate("getPlenty", cPlanExplore);
	if (exploreID >= 0)
	{
	  aiPlanAddUnitType(exploreID, cUnitTypeLogicalTypeLandMilitary, 5, 5, 5);
	  aiPlanAddWaypoint(exploreID, unitLocation);
	  aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
	  aiPlanSetVariableBool(exploreID, cExplorePlanQuitWhenPointIsVisible, 0, true);
	  aiPlanSetVariableBool(exploreID, cExplorePlanAvoidingAttackedAreas, 0, false);
	  aiPlanSetVariableInt(exploreID, cExplorePlanNumberOfLoops, 0, -1);
	  aiPlanSetRequiresAllNeedUnits(exploreID, true);
	  aiPlanSetVariableVector(exploreID, cExplorePlanQuitWhenPointIsVisiblePt, 0, unitLocation);
		aiPlanSetDesiredPriority(exploreID, 100);
	  aiPlanSetActive(exploreID);
	}
}

//==============================================================================
// RULE trainMythUnit
// AI checks whether we have sufficient resources before starting on a mythunit
//==============================================================================
rule trainMythUnit
   minInterval 60
   inactive
{
	// The treaty prevents us from doing stuff
	if(TreatyPrevents())
	{
		return;
	}
	
	int favorReqs = 75;
	if(kbGetAge() != cAge4)// In mythic we want a titan
	{
		favorReqs = 15;
	}
	
	

   static int planID = -1;

	//Get the PUID of a myth unit that we can train right now.
	int puid   = kbGetRandomEnabledPUID(cUnitTypeMythUnit, cMilitaryEscrowID);// Here is our real issue
	bool found = false;
	for(i=0;<25)// 25 attempts
	{
		aiEcho("TrainMythUnit gets "+puid);
		// We don't want these
		if(puid < 0||puid == cUnitTypeFlyingMedic||puid == cUnitTypePegasus||puid == cUnitTypeDryad||puid == cUnitTypeServant||puid == cUnitTypeRoc)
		{
			// Try again
			puid = kbGetRandomEnabledPUID(cUnitTypeMythUnit, cMilitaryEscrowID);
		}
		else
		{
			found = true;
			break;
		}
	}
	if(found == false)
	{
		xsSetRuleMinIntervalSelf(15);// If we failed to find one then try again 
		return;
	}
	else
	{
		xsSetRuleMinIntervalSelf(60);
	}
   if (planID != -1)
	  aiPlanDestroy(planID);	 // Kill old one to keep from stacking up.

   //Create the plan.
   string planName="Myth Train "+kbGetProtoUnitName(puid);
   aiEcho("Training a myth unit: "+kbGetProtoUnitName(puid));
   planID=aiPlanCreate(planName, cPlanTrain);
   if (planID < 0)
	  return;
   //Military.
   aiPlanSetMilitary(planID, true);
   //Unit type.
   aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
   //Number.
   aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 1);
   //Train at main base.
   int mainBaseID=kbBaseGetMainID(cMyID);
   if (mainBaseID >= 0)
   {
	  aiPlanSetBaseID(planID, mainBaseID);
	  aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, mainBaseID));
   }

   aiPlanSetActive(planID);
}

//==============================================================================
// RULE increaseSiegeWeaponUP
//==============================================================================
rule increaseSiegeWeaponUP
   minInterval 21
   inactive
{
   //See how many walls our enemies have built.  Create our query if
   //we don't already have one.
   static int wallQID=-1;
   if (wallQID < 0)
   {
	  wallQID=kbUnitQueryCreate("wallQuery");
	  kbUnitQuerySetPlayerRelation(wallQID, cPlayerRelationEnemy);
	  kbUnitQuerySetUnitType(wallQID, cUnitTypeAbstractWall);
	  kbUnitQuerySetState(wallQID, cUnitStateAlive);
   }
   //Reset the results.
	kbUnitQueryResetResults(wallQID);

   //If we find a "lot" of walls, bump our siege weapon percentage and go away.
	int numberWalls=kbUnitQueryExecute(wallQID);
   if (numberWalls > 20)
   {
	  kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAbstractSiegeWeapon, 1.0);
//  kbUnitPickSetCostWeight(gLateUPID, 0.25);
	  xsDisableSelf();
   }
}

//==============================================================================
// RULE NavalGoalMonitor
// Adjusted for treaty
//==============================================================================
rule NavalGoalMonitor
   minInterval 13
   inactive
{
   //Don't do anything in the first age.
   if ((kbGetAge() < 1) || (aiGetMostHatedPlayerID() < 0))
	  return;

	// The treaty prevents us from doing stuff
	if(TreatyPrevents())
	{
		return;
	}

   //See if we have any enemy warships running around.
   int numberEnemyWarships=0;
   //Find the largest warship count for any of our enemies.
   for (i=0; < cNumberPlayers)
   {
	  if ((kbIsPlayerEnemy(i) == true) &&
		 (kbIsPlayerResigned(i) == false) &&
		 (kbHasPlayerLost(i) == false))
	  {
		 int tempNumberEnemyWarships=kbUnitCount(i, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
		 if ( aiGetWorldDifficulty() > cDifficultyModerate )
		 {
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipGreek, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipNorse, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipAtlantean, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipEgyptian, cUnitStateAlive)/2;
		 }
		 //int tempNumberEnemyDocks=kbUnitCount(i, cUnitTypeDock, cUnitStateAlive);
		 if (tempNumberEnemyWarships > numberEnemyWarships)
			numberEnemyWarships=tempNumberEnemyWarships;
	  }
   }
   //Figure out the min/max number of warships we want.
   int minShips=0;
   int maxShips=0;
   if (numberEnemyWarships > 0)
   {
	  //Build at most 2 ships on easy.
	  if (aiGetWorldDifficulty() == cDifficultyEasy)
	  {
		 minShips=1;
		 maxShips=2;
	  }
	  //Build at most "6" ships on moderate.
	  else if (aiGetWorldDifficulty() == cDifficultyModerate)
	  {
		 minShips=numberEnemyWarships/2;
		 maxShips=numberEnemyWarships*3/4;
		 if (minShips < 1)
			minShips=1;
		 if (maxShips < 1)
			maxShips=1;
		 if (minShips > 3)
			minShips=3;
		 if (maxShips > 6)
			maxShips=6;
	  }
	  //Build the "same" number (within reason) on Hard/Titan.
	  else
	  {
		 minShips=numberEnemyWarships*3/4;
		 maxShips=numberEnemyWarships;
		 if (minShips < 1)
			minShips=1;
		 if (maxShips < 1)
			maxShips=1;
		 if (minShips > 5)
			minShips=5;
		 if (maxShips > 8)
			maxShips=8;
	  }
   }

   //If this is enabled on KOTH, that means we have the water version.  Pretend the enemy
   //has lots of boats so that we will have lots, too.
   if (cvRandomMapName == "king of the hill")
   {
	  minShips=6;
	  maxShips=12;
   }

   //  At 2-3 pop each, don't let this take up most of our military space.
   if ( maxShips > aiGetMilitaryPop()/5 )
	  maxShips = aiGetMilitaryPop()/5;

   if ( minShips > maxShips)
	  minShips = maxShips;

   gTargetNavySize = maxShips;   // Set the global var for forecasting

   //If we already have a Naval UP, just set the numbers and be done.  If we don't
   //want anything, just set 1 since we've already done it before.
   if (gNavalUPID >= 0)
   {
	  if (maxShips <= 0)
	  {
		 kbUnitPickSetMinimumNumberUnits(gNavalUPID, 1);
		 kbUnitPickSetMaximumNumberUnits(gNavalUPID, 1);
	  }
	  else
	  {
		 kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
		 kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
	  }
	  return;
   }

   //Else, we don't have a Naval attack goal yet.  If we don't want any ships,
   //just return.
   if (maxShips <= 0)
	  return;
	
   //Else, create the Naval attack goal.
   aiEcho("Creating NavalAttackGoal for "+maxShips+" ships since I've seen "+numberEnemyWarships+" for Player "+aiGetMostHatedPlayerID()+".");
   gNavalUPID=kbUnitPickCreate("Naval");
   if (gNavalUPID < 0)
   {
	  xsDisableSelf();
	  return;
   }
   //Fill in the UP.
   kbUnitPickResetAll(gNavalUPID);
   kbUnitPickSetPreferenceWeight(gNavalUPID, 2.0);
   kbUnitPickSetCombatEfficiencyWeight(gNavalUPID, 4.0);
   kbUnitPickSetCostWeight(gNavalUPID, 7.0);
   kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, 3, 2, true);
   kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
   kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
   kbUnitPickSetAttackUnitType(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary);
   kbUnitPickSetGoalCombatEfficiencyType(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary);
   kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary, 1.0);
   kbUnitPickSetMovementType(gNavalUPID, cMovementTypeWater);
   //Create the attack goal.
   gNavalAttackGoalID=createSimpleAttackGoal("Naval Attack", -1, gNavalUPID, -1, kbGetAge(), -1, -1, false);
   if (gNavalAttackGoalID < 0)
   {
	  xsDisableSelf();
	  return;
   }
   aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanAutoUpdateBase, 0, false);
   aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanSetAreaGroups, 0, false);
}

//==============================================================================
// RULE getOmniscience
//==============================================================================
rule getOmniscience
   minInterval 24
   inactive
{
   //If we can afford it twice over, then get it.
   float goldCost=kbTechCostPerResource(cTechOmniscience, cResourceGold) * 2.0;
   float currentGold=kbResourceGet(cResourceGold);
   if(goldCost>currentGold)
	  return;

   //Get Omniscience
   int voePID=aiPlanCreate("GetOmniscience", cPlanProgression);
	if (voePID != 0)
   {
	  aiPlanSetVariableInt(voePID, cProgressionPlanGoalTechID, 0, cTechOmniscience);
	   aiPlanSetDesiredPriority(voePID, 25);
	   aiPlanSetEscrowID(voePID, cMilitaryEscrowID);
	   aiPlanSetActive(voePID);
   }
   xsDisableSelf();
}

//==============================================================================
// RULE getOlympicParentage
//==============================================================================
rule getOlympicParentage
   minInterval 16
   active
{
   //If we're not Zeus, go away.
   if (cMyCiv != cCivZeus)
   {
	  xsDisableSelf();
	  return;
   }
   //Skip if in 1st or 2nd age.
   if (kbGetAge() < 2)
	  return;
   //If in 3rd, make sure we have enough food.
   if (kbGetAge() == 2)
   {
	  if(kbResourceGet(cResourceFood) < 600)
		 return;
   }

   //Get Olympic Parentage.
   int opPID=aiPlanCreate("GetOlympicParentage", cPlanProgression);
   if (opPID != 0)
   {
	  aiPlanSetVariableInt(opPID, cProgressionPlanGoalTechID, 0, cTechOlympicParentage);
	   aiPlanSetDesiredPriority(opPID, 25);
	   aiPlanSetEscrowID(opPID, cMilitaryEscrowID);
	   aiPlanSetActive(opPID);
   }

   xsDisableSelf();
}

//==============================================================================
// RULE repairTitanGate
//==============================================================================
rule repairTitanGate
   minInterval 10
   inactive
{
 
   int buildingID = -1;

   // Find the Titan Gate..
   static int tgQueryID=-1;
   //If we don't have a query ID, create it.
   if (tgQueryID < 0)
   {
	 aiEcho("   ======< Creating Titan Gate Query>=======");
	 tgQueryID=kbUnitQueryCreate("TitanGateQuery");
	 //If we still don't have one, bail.
	 if (tgQueryID < 0)
	 {
	   aiEcho(" ======< Unable to create query.  Returning.>=======");
		 xsDisableSelf();
		return;
	 }
	 //Else, setup the query data.
	 kbUnitQuerySetPlayerID(tgQueryID, cMyID);
	 kbUnitQuerySetUnitType(tgQueryID, cUnitTypeTitanGate);
	 kbUnitQuerySetState(tgQueryID, cUnitStateBuilding);
   }

   int numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	  // Used to set fractions we use for the titan gate
   if (cMyCulture == cCultureNorse)
	  numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive); // Get all inf, not just ulfsarks
   aiEcho("Found "+numBuilders+" total builders available.");

   //Reset the results.
   kbUnitQueryResetResults(tgQueryID);
   //Run the query.  
   if (kbUnitQueryExecute(tgQueryID) > 0)
	 buildingID = kbUnitQueryGetResult(tgQueryID, 0);

   if (buildingID >= 0)
   {
	 aiEcho("   ======< Executed query.  Found at least 1 gate.>=======");
	 //Don't create another plan for the same building.
	 if (aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true) >= 0)
	 {
		 xsDisableSelf();
		return;
	 }

	 //Create the plan.
	 int planID=aiPlanCreate("BuildTitanGate", cPlanRepair);
	 if (planID < 0)
	 {
	   aiEcho(" ======< Failed to create Plan. >=======");
		 xsDisableSelf();
		return;
	 }

	 aiPlanSetDesiredPriority(planID, 100);
	 aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
	 aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
	 aiPlanSetInitialPosition(planID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	 if (cMyCulture != cCultureNorse)
		aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, numBuilders/3, numBuilders/2, (numBuilders*2)/3);
	 else
		aiPlanAddUnitType(planID, cUnitTypeAbstractInfantry, numBuilders/3, numBuilders/2, (numBuilders*2)/3);
	 aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);
	 aiPlanSetActive(planID);
	 xsDisableSelf();
   }
   else
	 aiEcho("   ======< No Gates found.  No AI plan launched.>=======");

   return;

}


//==============================================================================
// RULE makeWonder
//==============================================================================
rule makeWonder
minInterval 6
inactive	   //  Activated on reaching age 4 if game isn't conquest
{

   int   targetArea = -1;
   vector target = cInvalidVector;   // Will be used to center the building placement behind the town.
   target = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   vector offset = cInvalidVector;
   offset = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
   offset = offset * 30.0;
   target = target + offset;
   targetArea = kbAreaGetIDByPosition(target);
   aiEcho("**** Starting wonder progression for vector "+target+" in area "+targetArea);

	int planID=aiPlanCreate("Wonder Build", cPlanBuild);
   if (planID < 0)
	  return;

   aiEcho("Wonder build plan ID is "+planID);
   aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeWonder);

//  aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 2, targetArea);

   aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, targetArea);
	aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, 2);


//   aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, target);
//   aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 40.0);
//   aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, target);
//   aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 25.0);
//   aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 100.0);

   aiPlanSetDesiredPriority(planID, 99);

   //Mil vs. Econ.
   aiPlanSetMilitary(planID, false);
   aiPlanSetEconomy(planID, true);

   //Escrow.
   aiPlanSetEscrowID(planID, cEconomyEscrowID);

   int builderUnit = cUnitTypeAbstractVillager;
   if (cMyCulture == cCultureNorse)
	  builderUnit = cUnitTypeAbstractInfantry;

   aiEcho("Builder unit is "+builderUnit);

   int builderCount = -1;
   builderCount = kbUnitCount(cMyID, builderUnit, cUnitStateAlive);

   //Builders.
	aiPlanAddUnitType(planID, builderUnit,
	  (2*builderCount)/3, builderCount, (3*builderCount)/2);   // Two thirds, all, or 150%...in case new builders are created.
   //Base ID.
   aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));

   //Go.
   aiPlanSetActive(planID);

   aiEcho("Activating watchForWonder rule.");
   xsEnableRule("watchForWonder");   // Looks for wonder placement, starts defensive reaction.
   xsDisableSelf();
}



//==============================================================================
// RULE watchForFirstWonderStart 
//==============================================================================
// Look for any wonder being built.  If found, activate the high-speed rule that
// watches for completion
rule watchForFirstWonderStart
active
minInterval 90  // Hopefully nobody will build one faster than this
{
   static int wonderQueryStart = -1;
   if (wonderQueryStart < 0)
   {
	  wonderQueryStart = kbUnitQueryCreate("Start wonder query");
	  if ( wonderQueryStart == -1)
	  {
		 xsDisableSelf();
		 return;
	  }
	  kbUnitQuerySetPlayerRelation(wonderQueryStart, cPlayerRelationAny);
	  kbUnitQuerySetUnitType(wonderQueryStart, cUnitTypeWonder);
	  kbUnitQuerySetState(wonderQueryStart, cUnitStateAliveOrBuilding);  // Any wonder under construction
   }

   kbUnitQueryResetResults(wonderQueryStart);
   if (kbUnitQueryExecute(wonderQueryStart) > 0)
   {
	  aiEcho("**** Someone is building a wonder!");
	  xsDisableSelf();
	  xsEnableRule("watchForFirstWonderDone");
   }
}

//==============================================================================
// RULE watchForFirstWonderDone 
//==============================================================================
// See who makes the first wonder, note its ID, make a defend plan to kill it,
// kill defend plan when it's gone.
rule watchForFirstWonderDone
inactive
minInterval 1   // Timing is crucial
{
   static int enemyWonderQuery = -1;
   static int wonderID = -1;
   static vector wonderLocation = cInvalidVector;

   if (enemyWonderQuery < 0)
   {
	  enemyWonderQuery = kbUnitQueryCreate("enemy wonder query");
	  if ( enemyWonderQuery == -1)
	  {
		 xsDisableSelf();
		 return;
	  }
	  kbUnitQuerySetPlayerRelation(enemyWonderQuery, cPlayerRelationEnemy);
	  kbUnitQuerySetUnitType(enemyWonderQuery, cUnitTypeWonder);
	  kbUnitQuerySetState(enemyWonderQuery, cUnitStateAlive);   // Only completed wonders count
   }
  
   static int allyWonderQuery = -1;
   if (allyWonderQuery < 0)
   {
	  allyWonderQuery = kbUnitQueryCreate("ally wonder query");
	  if ( allyWonderQuery == -1)
	  {
		 xsDisableSelf();
		 return;
	  }
	  kbUnitQuerySetPlayerRelation(allyWonderQuery, cPlayerRelationAlly);
	  kbUnitQuerySetUnitType(allyWonderQuery, cUnitTypeWonder);
	  kbUnitQuerySetState(allyWonderQuery, cUnitStateAlive);	 // Only completed wonders count
   }

   static int myWonderQuery = -1;
   if (myWonderQuery < 0)
   {
	  myWonderQuery = kbUnitQueryCreate("my wonder query");
	  if ( myWonderQuery == -1)
	  {
		 xsDisableSelf();
		 return;
	  }
	  kbUnitQuerySetPlayerRelation(myWonderQuery, cPlayerRelationSelf);
	  kbUnitQuerySetUnitType(myWonderQuery, cUnitTypeWonder);
	  kbUnitQuerySetState(myWonderQuery, cUnitStateAlive);   // Only completed wonders count
   }

   if (wonderID < 0) // No wonder has been built, look for them
   {
	  kbUnitQueryResetResults(myWonderQuery);
	  if (kbUnitQueryExecute(myWonderQuery) > 0)   // I win, quit.
	  {
		 aiEcho("**** I made the first wonder!");
		 xsDisableSelf();
		 return;
	  }

	  kbUnitQueryResetResults(enemyWonderQuery);
	  if (kbUnitQueryExecute(enemyWonderQuery) > 0)
	  {
		 aiEcho("**** The enemy made the first wonder!");
		 // Create highest-priority defend plan to go kill it
		 wonderID = kbUnitQueryGetResult(enemyWonderQuery, 0);
		 wonderLocation = kbUnitGetPosition(wonderID);
/*
		 gEnemyWonderDefendPlan =aiPlanCreate("Enemy Wonder Defend Plan", cPlanDefend);
		 if (gEnemyWonderDefendPlan >= 0)
		 {
			aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeMilitary, 200, 200, 200);	// All mil units
			aiPlanSetDesiredPriority(gEnemyWonderDefendPlan, 98);   // Uber-plan
			aiPlanSetVariableVector(gEnemyWonderDefendPlan, cDefendPlanDefendPoint, 0, wonderLocation);
			aiPlanSetVariableFloat(gEnemyWonderDefendPlan, cDefendPlanEngageRange, 0, 10.0);	// Very tight
			aiPlanSetVariableBool(gEnemyWonderDefendPlan, cDefendPlanPatrol, 0, false);

			aiPlanSetVariableFloat(gEnemyWonderDefendPlan, cDefendPlanGatherDistance, 0, 20.0);
			aiPlanSetInitialPosition(gEnemyWonderDefendPlan, wonderLocation);
			aiPlanSetUnitStance(gEnemyWonderDefendPlan, cUnitStanceDefensive);

			aiPlanSetVariableInt(gEnemyWonderDefendPlan, cDefendPlanRefreshFrequency, 0, 5);
			aiPlanSetVariableInt(gEnemyWonderDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeBuilding); // Only target buildings
			aiPlanSetActive(gEnemyWonderDefendPlan); 
			aiEcho("Creating enemy wonder defend plan");
		 }
*/
			// Making an attack plan instead, they do a better job of transporting and ignoring some targets en route.
			gEnemyWonderDefendPlan=aiPlanCreate("Enemy wonder attack plan", cPlanAttack);
			if (gEnemyWonderDefendPlan < 0)
			   return;

			int n=0;
			for (n=1; <= cNumberPlayers)
			{
			   if (kbUnitCount(n, cUnitTypeWonder, cUnitStateAlive) > 0)
			   {
				  aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanPlayerID, 0, n);
				  aiEcho("Player "+n+" has the wonder.");
			   }
			}

//  aiPlanSetNumberVariableValues(gEnemyWonderDefendPlan, cAttackPlanTargetTypeID, 0, true);
//  aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanTargetTypeID, 0, cUnitTypeWonder);


			// Specify other continent so that armies will transport
			aiPlanSetNumberVariableValues( gEnemyWonderDefendPlan, cAttackPlanTargetAreaGroups,  1, true);  
			aiEcho("Area group for wonder is "+kbAreaGroupGetIDByPosition(kbUnitGetPosition(wonderID)));
			aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(kbUnitGetPosition(wonderID)));
   
			aiPlanSetVariableVector(gEnemyWonderDefendPlan, cAttackPlanGatherPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
			aiPlanSetVariableFloat(gEnemyWonderDefendPlan, cAttackPlanGatherDistance, 0, 200.0);   // Insta-gather, just GO!

			aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);


			aiPlanSetInitialPosition(gEnemyWonderDefendPlan, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
			aiPlanSetRequiresAllNeedUnits(gEnemyWonderDefendPlan, false);
			aiPlanSetDesiredPriority(gEnemyWonderDefendPlan, 80);  
//  aiPlanSetUnitStance(gEnemyWonderDefendPlan, cUnitStancePassive);
			aiPlanSetVariableBool(gEnemyWonderDefendPlan, cAttackPlanMoveAttack, 0, false);
			aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanSpecificTargetID, 0, wonderID);

			aiPlanSetActive(gEnemyWonderDefendPlan);

	  }
	  else
	  {
		 kbUnitQueryResetResults(allyWonderQuery);
		 if (kbUnitQueryExecute(allyWonderQuery) > 0)
		 {
			aiEcho("**** An ally made the first wonder!");
			// Create highest-priority defend plan to go protect it
			wonderID = kbUnitQueryGetResult(allyWonderQuery, 0);
			wonderLocation = kbUnitGetPosition(wonderID);
			if ( kbAreaGroupGetIDByPosition(wonderLocation) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) )
			{  // It's on my continent, go help
			   gEnemyWonderDefendPlan =aiPlanCreate("Ally Wonder Defend Plan", cPlanDefend);		 // Uses "enemy" plan for allies, too.
			   if (gEnemyWonderDefendPlan >= 0)
			   {
				  aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeMilitary, 200, 200, 200);  // All mil units
				  aiPlanSetDesiredPriority(gEnemyWonderDefendPlan, 98);  // Uber-plan, except for norse wonder-build plan
				  aiPlanSetVariableVector(gEnemyWonderDefendPlan, cDefendPlanDefendPoint, 0, wonderLocation);
				  aiPlanSetVariableFloat(gEnemyWonderDefendPlan, cDefendPlanEngageRange, 0, 50.0);
				  aiPlanSetVariableBool(gEnemyWonderDefendPlan, cDefendPlanPatrol, 0, false);

				  aiPlanSetVariableFloat(gEnemyWonderDefendPlan, cDefendPlanGatherDistance, 0, 40.0);
				  aiPlanSetInitialPosition(gEnemyWonderDefendPlan, wonderLocation);
				  aiPlanSetUnitStance(gEnemyWonderDefendPlan, cUnitStanceDefensive);

				  aiPlanSetVariableInt(gEnemyWonderDefendPlan, cDefendPlanRefreshFrequency, 0, 5);
				  aiPlanSetNumberVariableValues(gEnemyWonderDefendPlan, cDefendPlanAttackTypeID, 2, true);
				  aiPlanSetVariableInt(gEnemyWonderDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
				  aiPlanSetVariableInt(gEnemyWonderDefendPlan, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);

				  aiPlanSetActive(gEnemyWonderDefendPlan); 
				  aiEcho("Creating enemy wonder defend plan");
			   }
			}
		 }
	  }
   }
   else  // A wonder was built...if it's down, kill the uber-plan
   {
	  aiPlanSetNoMoreUnits(gEnemyWonderDefendPlan, false);  // Make sure the enemy wonder 'defend' plan stays open
	  if (kbUnitGetCurrentHitpoints(wonderID) <= 0)
	  {
		 aiPlanDestroy(gEnemyWonderDefendPlan);
		 xsDisableSelf();
		 aiEcho("**** Wonder "+wonderID+" has been destroyed!");
	  }
   }
}


//==============================================================================
// RULE watchForWonder
//==============================================================================
rule watchForWonder  // See if my wonder has been placed.  If so, go build it.
inactive
minInterval 21
{
   if ( kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) < 1 )
	  return;

   aiEcho("**** A wonder is being built.  Activating wonderDefend plan.");
   xsEnableRule("watchWonderLost"); // Kill the defend plan if the wonder is destroyed.

   int wonderID = findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeWonder);
   vector wonderLocation = kbUnitGetPosition(wonderID);
   aiEcho("Wonder is at "+wonderLocation);

   // Make the defend plan
   gWonderDefendPlan =aiPlanCreate("Wonder Defend Plan", cPlanDefend);
   if (gWonderDefendPlan >= 0)
   {
	  aiPlanAddUnitType(gWonderDefendPlan, cUnitTypeMilitary, 200, 200, 200);   // All mil units
	  aiPlanSetDesiredPriority(gWonderDefendPlan, 97);   // Uber-plan, except for enemy-wonder plan and wonder-build plan
	  aiPlanSetVariableVector(gWonderDefendPlan, cDefendPlanDefendPoint, 0, wonderLocation);
	  aiPlanSetVariableFloat(gWonderDefendPlan, cDefendPlanEngageRange, 0, 50.0);
	  aiPlanSetVariableBool(gWonderDefendPlan, cDefendPlanPatrol, 0, false);

	  aiPlanSetVariableFloat(gWonderDefendPlan, cDefendPlanGatherDistance, 0, 40.0);
	  aiPlanSetInitialPosition(gWonderDefendPlan, wonderLocation);
	  aiPlanSetUnitStance(gWonderDefendPlan, cUnitStanceDefensive);

	  aiPlanSetVariableInt(gWonderDefendPlan, cDefendPlanRefreshFrequency, 0, 5);
	  aiPlanSetNumberVariableValues(gWonderDefendPlan, cDefendPlanAttackTypeID, 2, true);
	  aiPlanSetVariableInt(gWonderDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
	  aiPlanSetVariableInt(gWonderDefendPlan, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);

	  aiPlanSetActive(gWonderDefendPlan); 
	  aiEcho("Creating wonder defend plan");
   }
   xsDisableSelf();
}


//==============================================================================
// RULE watchWonderLost 
//==============================================================================
rule watchWonderLost	// Kill the uber-defend plan if wonder falls
inactive
minInterval 8
{
   if ( kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) > 0 )
	  return;

   aiPlanDestroy(gWonderDefendPlan);
   aiEcho("My wonder is gone.  Sigh.  Maybe I'll make another one.  Or not.");
   xsEnableRule("makeWonder");  // Try again if we get a chance
   xsDisableSelf();
}



//==============================================================================
// RULE buildSkyPassages
//==============================================================================
rule buildSkyPassages
   minInterval 28
   inactive
{
   aiEcho("Sky Passages check running...");
   // Make sure we have a sky passage at home, and one near the nearest TC of 
   // our Most Hated Player.  
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSkyPassage) > -1)
	  return;  // Quit if we're already building one

   if (kbBaseGetNumberUnits(cMyID, kbBaseGetMainID(cMyID), cPlayerRelationSelf, cUnitTypeSkyPassage) < 1)
   {  // We don't have one...make sure we have a plan in the works
	  aiEcho("  Creating a local sky passage.");
	   int planID=aiPlanCreate("BuildLocalSkyPassage", cPlanBuild);
	  if (planID < 0)
		 return;
	  aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
	   aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, 
		 kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) );
	  aiPlanSetDesiredPriority(planID, 70);
	  aiPlanSetMilitary(planID, true);
	  aiPlanSetEconomy(planID, false);
	  aiPlanSetEscrowID(planID, cMilitaryEscrowID);
	   aiPlanAddUnitType(planID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0),
		 1, 1, 1);
	  aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
	  aiPlanSetActive(planID);

	  return;  // Don't start second until first is done
   }


   // Local base is covered, now let's check near our Most Hated Player's TC
   static int nearestMhpTCQueryID = -1;
   if (nearestMhpTCQueryID < 0)
   {
	  nearestMhpTCQueryID = kbUnitQueryCreate("MostHatedPlayerTC");
   }
   kbUnitQuerySetPlayerID(nearestMhpTCQueryID, aiGetMostHatedPlayerID());
   kbUnitQuerySetUnitType(nearestMhpTCQueryID, cUnitTypeAbstractSettlement);
   kbUnitQuerySetState(nearestMhpTCQueryID, cUnitStateAliveOrBuilding);
   kbUnitQuerySetPosition(nearestMhpTCQueryID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
   kbUnitQuerySetAscendingSort(nearestMhpTCQueryID, true);

   kbUnitQueryResetResults(nearestMhpTCQueryID);
   aiEcho("*****	Checking for most hated player ("+aiGetMostHatedPlayerID()+") TC.");
   int numTCs = kbUnitQueryExecute(nearestMhpTCQueryID);
   if (numTCs < 1)
	  return;  // No enemy TCs
   int enemyTC = kbUnitQueryGetResult(nearestMhpTCQueryID, aiRandInt(numTCs));   // ID of enemy TC we want to search, random selection
   vector enemyTCvec = kbUnitGetPosition(enemyTC);
   aiEcho(" TC is at "+enemyTCvec);

   // We now know the nearest enemyTC, let's look for a sky passage near there
   static int skyPassageQueryID = -1;
   if (skyPassageQueryID < 0)
   {
	  skyPassageQueryID = kbUnitQueryCreate("RemoteSkyPassage");
	  kbUnitQuerySetPlayerID(skyPassageQueryID, cMyID);
	  kbUnitQuerySetUnitType(skyPassageQueryID, cUnitTypeSkyPassage);
	  kbUnitQuerySetState(skyPassageQueryID, cUnitStateAliveOrBuilding);
	  kbUnitQuerySetMaximumDistance(skyPassageQueryID, 80.0);
   }
   kbUnitQuerySetPosition(skyPassageQueryID, enemyTCvec);
   kbUnitQueryResetResults(skyPassageQueryID);
   aiEcho(" Looking for sky passage near "+enemyTCvec);
   if (kbUnitQueryExecute(skyPassageQueryID) < 1)
   {  // None found, we need one...and we don't have an active plan.
	  // First, pick a center location on our side of the enemy TC
	  vector offset = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) - enemyTCvec;
	  offset = xsVectorNormalize(offset);
	  vector target = enemyTCvec + (offset * 60.0);
	  
	  aiEcho("  Considering target location "+target);

	  // Now, check if that's on ground, and just give up if it isn't
//  int targetArea = kbAreaGetIDByPosition(target);
//  if ( (kbAreaGetType(targetArea) == cAreaTypeWater) || (kbAreaGetType(targetArea) == cAreaTypeImpassableLand) )
//   return;
	  // Figure out if it's on our enemy's areaGroup.  If not, step 5% closer until it is.
	  int enemyAreaGroup = -1;
	  int testAreaGroup = -1;
	  testAreaGroup = kbAreaGroupGetIDByPosition(target);
	  enemyAreaGroup = kbAreaGroupGetIDByPosition(enemyTCvec);
	  aiEcho("  Target location "+target+" is in areaGroup "+testAreaGroup);
	  aiEcho("  Enemy TC is in areaGroup "+enemyAreaGroup);

	  int i = -1;

	  vector towardEnemy = offset * -5.0;   // 5m away from me, toward enemy TC
	  bool success = false;

	  for (i=0; <18)	// Keep testing until areaGroups match
	  {
		 testAreaGroup = kbAreaGroupGetIDByPosition(target);
		 if (testAreaGroup == enemyAreaGroup)
		 {
			success = true;
			aiEcho("	Test location "+target+" is in areaGroup "+testAreaGroup);
			break;
		 }
		 else
		 {
			aiEcho("	Test location "+target+" is in areaGroup "+testAreaGroup);
			target = target + towardEnemy;   // Try a bit closer
		 }
	  }
  

	  // We have a target and it's on land...
	  aiEcho("  Creating a remote sky passage at "+target);
	   int remotePlanID=aiPlanCreate("BuildRemoteSkyPassage", cPlanBuild);
	  if (remotePlanID < 0)
		 return;
	  aiPlanSetVariableInt(remotePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
	  aiPlanSetVariableInt(remotePlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(target));
	   aiPlanSetVariableInt(remotePlanID, cBuildPlanNumAreaBorderLayers, 0, 1);
	  aiPlanSetDesiredPriority(remotePlanID, 70);
	  aiPlanSetMilitary(remotePlanID, true);
	  aiPlanSetEconomy(remotePlanID, false);
	  aiPlanSetEscrowID(remotePlanID, cMilitaryEscrowID);
	   aiPlanAddUnitType(remotePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
	  aiPlanSetActive(remotePlanID);
   }
}


rule hesperides   // Watch for ownership of a hesperides tree, make driads if you own it.
   minInterval 34
   active
{
   static bool iHaveOne = false;
   static int driadPlan = -1;

   if (iHaveOne == true)   // I think I have one...verify, kill maintain plan if not.
   {
	  if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) < 1)   // It's gone!
	  {
		 aiEcho("Lost the hesperides tree.");
		 aiPlanDestroy(driadPlan);
		 iHaveOne = false;
	  }
   }
   else  // I don't think I have one...see if one has appeared, and set up maintain plan if it has
   {
	  if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) > 0)   // I have one!
	  {
		 aiEcho("I have a hesperides tree.");
		 iHaveOne = true;
		 driadPlan = createSimpleMaintainPlan(cUnitTypeDryad, 5, false, kbBaseGetMainID(cMyID)) ;
	  }
   }
}


//==============================================================================
// RULE milPopMonitor...monitor mil pop, fix UP targets if jammed
//==============================================================================
rule milPopMonitor
   minInterval 13
   active
{
   static int mode = 0; // 0 is monitor; 1 is reducing pop target
   static int originalGoal = -1;	// What was the UP's minimum pop target before reduction?
   static int lastKnownPlan = -1;   // The last attack plan this rule knows about...
   int attackGoalID = -1;   // Currently active attack goal
   int UPID = -1;   // Currently active unit picker
   static int lastKnownAge = -1;	// The age we were last working in


	// The treaty prevents us from doing stuff so no army
	if(TreatyPrevents())
	{
		kbUnitPickSetMinimumPop(gRushUPID, 0);
		kbUnitPickSetMaximumPop(gRushUPID, 0);
		kbUnitPickSetMinimumPop(gLateUPID, 0);
		kbUnitPickSetMaximumPop(gLateUPID, 0);
		return;
	}

   if (kbGetAge() < cAge2) 
	  return;   // Don't mess with age 1

	
   if (kbGetAge() != lastKnownAge)
   {
	  if (lastKnownAge == cAge2)
	  {
		 mode = 0;  // In case we were reducing an age 2 UP when the age advanced
	  }
	  lastKnownAge = kbGetAge();
   }

   if (kbGetAge() == cAge2)
   {
	  attackGoalID = gRushGoalID;
	  UPID = gRushUPID;
   }
   else
   {
	  attackGoalID = gLandAttackGoalID;
	  UPID = gLateUPID;
   }

   if (mode == 1)   // We're in reduction mode
   {
	  if ( aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanFromGoalID, attackGoalID) >= 0  )  // There's a new plan!
	  {
		 mode = 0;  // Back to monitoring
		 kbUnitPickSetMinimumPop(UPID, originalGoal);  // restore UP target
		 lastKnownPlan = aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanFromGoalID, attackGoalID);
		 aiEcho("Returning to military monitor mode at pop "+originalGoal+", attack plan "+lastKnownPlan+" has been created.");
	  }
	  else  // no plan
	  {
		 if (aiGetAvailableMilitaryPop() > 10)
		 {  // Our army has been killed, go to monitor
			mode = 0;
			kbUnitPickSetMinimumPop(UPID, originalGoal);  // restore UP target
			aiEcho("Returning to military monitor mode at pop "+originalGoal+", no longer at mil pop limit.");
			return;
		 }
		 if ( kbUnitPickGetMinimumPop(UPID) > 3)
		 {
			kbUnitPickSetMinimumPop(UPID, kbUnitPickGetMinimumPop(UPID) - 3);   // Lower by 3
			aiEcho("Pop goal is now "+kbUnitPickGetMinimumPop(UPID));
		 }
		 else
			aiEcho("Error, military pop goal is <= 3.");
	  }
   }
   else  // We're in monitor mode...see if we're pop capped without an attack plan
   {
	  if (attackGoalID == -1)   // No rush goal, just the idle goal, don't worry about it.
		 return;

	  if (aiPlanGetVariableBool(attackGoalID, cGoalPlanIdleAttack, 0) == true)
		 return;				 // No real attacks, probably easy difficulty

	  if (aiPlanGetState(attackGoalID) == cPlanStateDone)   // No more attacks, waiting to age up.
		 return;

	  if (aiGetAvailableMilitaryPop() > 10)
		 return;				 // No sense worrying about it if we still have pop room.

	  // look for a land attack plan
	  if ( aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanFromGoalID, attackGoalID) >= 0 )
		 return;	 // We have one

	  // If we're here, we're near our mil pop cap and we don't have an attack plan.
	  aiEcho("Going to military goal reduction mode.");
	  mode = 1;
	  originalGoal = kbUnitPickGetMinimumPop(UPID);
   }
}




//==============================================================================
// RULE spotAgeUpgrades...detect age upgrades given as starting condtions or via triggers
//==============================================================================
rule spotAgeUpgrades
   minInterval 21
   active
{
   if ( gLastAgeHandled < kbGetAge() )  // If my current age is higher than the last upgrade I remember...do the handler
   {
	  if (gLastAgeHandled == cAge1)
		 age2Handler();
	  if (gLastAgeHandled == cAge2)
		 age3Handler();
	  if (gLastAgeHandled == cAge3)
		 age4Handler();
	  if (gLastAgeHandled == cAge4)
		 age5Handler();

   }
}
 
//=================================================================================================================================
// getgetOwnUnitUnit( int unitType, int action, vector center, int Radius, int State) 
//							  
// Returns a unit of the specified type, doing the specified action.			  
// Defaults = any unit, any action.  
// Searches units owned by this player only, can include buildings.   
// If a location is specified, the nearest matching unit is returned.   
//=================================================================================================================================
int   getgetOwnUnitUnit(int unitType = -1, int action = -1, vector center = vector(-1, -1, -1), int radius = -1, int state = -1)
{

	int   retVal = -1;
	int   count = -1;
	int   unitQueryID = kbUnitQueryCreate("unit");

	// Define a query to get all matching units
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);   // only my units
		if (unitType != -1)
			kbUnitQuerySetUnitType(unitQueryID, unitType);   // only if specified
		if (action != -1)
			kbUnitQuerySetActionType(unitQueryID, action);   // only if specified
		if (center != vector(-1,-1,-1))
		{
			kbUnitQuerySetPosition(unitQueryID, center);
			if (radius != -1)
			{
				kbUnitQuerySetMaximumDistance(unitQueryID, radius);
			}
			kbUnitQuerySetAscendingSort(unitQueryID, true);
		}
		if (state == -1)//Default to alive
		{
			kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
		}
		else
		{
			kbUnitQuerySetState(unitQueryID, state);
		}
	}
	else
	{
		kbUnitQueryDestroy(unitQueryID);
		return(-1);
	}

	kbUnitQueryResetResults(unitQueryID);
	count = kbUnitQueryExecute(unitQueryID);
	kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
	count = kbUnitQueryExecute(unitQueryID);

	// Pick a unit and return its ID, or return -1.
	if ( count > 0 )
		if (center != vector(-1,-1,-1))
			retVal = kbUnitQueryGetResult(unitQueryID, 0);   // closest unit
		else
			retVal = kbUnitQueryGetResult(unitQueryID, aiRandInt(count));   // get the ID of a random unit
	else
		retVal = -1;
	kbUnitQueryDestroy(unitQueryID);
	return(retVal);
}

//==============================================================================
// MAIN.
//==============================================================================
void main(void)
{
	//Set our random seed.  "-1" is a random init.
	aiRandSetSeed(-1);

	//Calculate some areas.
	kbAreaCalculate();

	setParameters();  // Set the control variables before anything else
	// Init the new stuff
	initPlayer();
	initDifficulty();
	initGameMode();

	//Go.
	if (cvDelayStart != true)
		init();
	else
		xsDisableRule("age1Progress");
	// setOverrides() is the last line of init().
}

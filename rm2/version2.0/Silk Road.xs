// Silk Road
// Trade is for life.

include "MmM_FE_lib.xs";

int tradingPost_1 = 0;
int tradingPost_2 = 0;
int tradingPost_3 = 0;
int tradingPost_4 = 0;
int tradingPost_5 = 0;

int rmGetTradingPostAreaID(int num=-1) {
	if(num==1) return(tradingPost_1);
	if(num==2) return(tradingPost_2);
	if(num==3) return(tradingPost_3);
	if(num==4) return(tradingPost_4);
	if(num==5) return(tradingPost_5);
	return(0);	// should never be reached
}

int tp_Counter = 0;
int tpConClass = 0;

float tpx1 = 0.0;	float tpy1 = 0.0;
float tpx2 = 0.0;	float tpy2 = 0.0;
float tpx3 = 0.0;	float tpy3 = 0.0;
float tpx4 = 0.0;	float tpy4 = 0.0;
float tpx5 = 0.0;	float tpy5 = 0.0;

float rmGetTradingPostXLoc(int tp=1){
	if(tp == 1) return(tpx1);
	if(tp == 2) return(tpx2);
	if(tp == 3) return(tpx3);
	if(tp == 4) return(tpx4);
	if(tp == 5) return(tpx5);
	return(0);	// should never be reached
}

float rmGetTradingPostYLoc(int tp=1){
	if(tp == 1) return(tpy1);
	if(tp == 2) return(tpy2);
	if(tp == 3) return(tpy3); 
	if(tp == 4) return(tpy4);
	if(tp == 5) return(tpy5);
	return(0);	// should never be reached
}

void initLocs(){
	if(cNumberNonGaiaPlayers == 2){
		tpx1 = 0.05;	tpy1 = 0.95;
		tpx2 = 0.10;	tpy2 = 0.50;
		tpx3 = 0.50;	tpy3 = 0.50;
		tpx4 = 0.90;	tpy4 = 0.50;
		tpx5 = 0.95;	tpy5 = 0.05;
	} else if(cNumberNonGaiaPlayers == 4){
		tpx1 = 0.10;	tpy1 = 0.90;
		tpx2 = 0.90;	tpy2 = 0.90;
		tpx3 = 0.50;	tpy3 = 0.50;
		tpx4 = 0.10;	tpy4 = 0.10;
		tpx5 = 0.90;	tpy5 = 0.10;
	} else if(cNumberTeams == 2){
		tpx1 = 0.62706;	tpy1 = 0.654452;
		tpx2 = 0.39237;	tpy2 = 0.668570;
		tpx3 = 0.30642;	tpy3 = 0.449730;
		tpx4 = 0.48799;	tpy4 = 0.300361;
		tpx5 = 0.68615;	tpy5 = 0.426887;
		//placePointsCircle(0.2, 5);
	} else {
		tpx1 = 0.10;	tpy1 = 0.90;
		tpx2 = 0.25;	tpy2 = 0.50;
		tpx3 = 0.65;	tpy3 = 0.65;
		tpx4 = 0.50;	tpy4 = 0.25;
		tpx5 = 0.90;	tpy5 = 0.10;
	}
}

int createTradingRouteArea(){
	
	tp_Counter++;
	int tp = rmCreateArea("TradingPost_"+tp_Counter);
	rmSetAreaSize(tp, 0.005, 0.005);
	rmSetAreaWarnFailure(tp, true);
	rmSetAreaTerrainType(tp, "PlainDirt75");
	rmAddAreaTerrainLayer(tp, "PlainDirt50", 0, 1);
	rmSetAreaBaseHeight(tp, 2.0);
	rmSetAreaHeightBlend(tp, 2);
	rmSetAreaSmoothDistance(tp, 6);
	rmSetAreaCoherence(tp, 0.9);
	rmSetAreaLocation(tp, rmGetTradingPostXLoc(tp_Counter), rmGetTradingPostYLoc(tp_Counter));
	if(tp_Counter == 1){ 	  tradingPost_1 = tp; }
	else if(tp_Counter == 2){ tradingPost_2 = tp; }
	else if(tp_Counter == 3){ tradingPost_3 = tp; }
	else if(tp_Counter == 4){ tradingPost_4 = tp; }
	else if(tp_Counter == 5){ tradingPost_5 = tp; }
	return (tp);
}

int tp_con1 = 0; 
int tp_con2 = 0;
int tp_con3 = 0;
int tp_con4 = 0; 
int tp_con5 = 0; 

int rmGetTP_Connection(int num = -1) {
	if(num==1) return(tp_con1); 
	if(num==2) return(tp_con2);
	if(num==3) return(tp_con3); 
	if(num==4) return(tp_con4);
	if(num==5) return(tp_con5); 
	return(0);	// should never be reached
}
	
int rmSetTP_Connection(int num = -1, int val = 0) {
	if(num==1) tp_con1 = val;
	if(num==2) tp_con2 = val;
	if(num==3) tp_con3 = val;
	if(num==4) tp_con4 = val; 
	if(num==5) tp_con5 = val;
	return(0);	// should never be reached
}


int prevConID = -1;
int createTradingRouteConnection(){

	int conID = rmCreateConnection("connection_"+prevConID);
	prevConID = conID;
	
	rmAddConnectionTerrainReplacement(conID, "PlainA", "GreekRoadA");
	rmSetConnectionType(conID, cConnectAreas, false, 1.0);
	rmSetConnectionWarnFailure(conID, false); 
	rmSetConnectionWidth(conID, 8, 0);
	rmAddConnectionToClass(conID, tpConClass);
	rmSetConnectionPositionVariance(conID, 0.75);
	rmSetConnectionBaseHeight(conID, 1.0);
	rmSetConnectionHeightBlend(conID, 2);
	return (conID);
}


// Main entry point for random map script
void main(void){

	//Basic Initialization
	rmSetStatusText("",0.01);
	int mapSizeMultiplier = 1;
	int playerTiles=7500;
	if(cMapSize == 1){
		playerTiles = 9500;
		rmEchoInfo("Large map");
	} else if(cMapSize == 2){
		playerTiles = 16000;
		mapSizeMultiplier = 2;
		rmEchoInfo("Giant map");
	}
	
	int size=2.0*sqrt(cNumberNonGaiaPlayers*playerTiles/0.95);
	rmSetMapSize(size, size);
	rmEchoInfo("Map size="+size+"m x "+size+"m");
	
	rmSetSeaLevel(0.0);
	rmSetSeaType("Yellow River");
	rmTerrainInitialize("PlainA");
	
	/*******************************/
	/* Step 1: create Player areas */	rmSetStatusText("",0.15);
	/*******************************/
	int playerClass=rmDefineClass("player");
	
	//Generate player positions.
	float playerRadius = 0.38;			//use a radius of 0.38 <- this might need to be changed.
	if(cNumberNonGaiaPlayers == 2){
		playerRadius = 0.37;
	}
	
	placePointsCircle(playerRadius, cNumberNonGaiaPlayers, -1.0, 0.05, true);	//use the recorded angle.
	rmRecordPlayerLocations();
	
	// Set up player areas.
	float playerFraction=rmAreaTilesToFraction(1200);
	for(i=1; <cNumberPlayers){
		int id=rmCreateArea("Player"+i);
		rmSetPlayerArea(i, id);		//Set area to player.
		rmSetAreaLocPlayer(id, i);	//Grab the location that placePointsCircle selected above.
		rmSetAreaSize(id, playerFraction, playerFraction);
		rmAddAreaToClass(id, playerClass);
		rmSetAreaWarnFailure(id, true);
		rmSetAreaTerrainType(id, "PlainDirt75");
		rmAddAreaTerrainLayer(id, "PlainA", 0, 8);
		rmAddAreaTerrainLayer(id, "PlainDirt25", 8, 16);
		rmAddAreaTerrainLayer(id, "PlainDirt50", 16, 24);
		rmSetAreaBaseHeight(id, 2.0);
		rmSetAreaHeightBlend(id, 2);
		rmSetAreaSmoothDistance(id, 6);
		
		rmSetAreaMinBlobs(id, 1);
		rmSetAreaMaxBlobs(id, 5);
		rmSetAreaCoherence(id, 0.75);
	}
	rmBuildAllAreas();
	
	/*********************************/
	/* Step 2: create Trading Routes */	rmSetStatusText("",0.20);
	/*********************************/
	initLocs();
	int TPclass = rmDefineClass("tradingPost");
	
	int tradingPostID=rmCreateObjectDef("Trading Posts");
	rmAddObjectDefItem(tradingPostID, "Cinematic Block", 1, 0.0);
	rmAddObjectDefItem(tradingPostID, "Plenty Vault KOTH", 1, 0.0);
	rmAddObjectDefToClass(tradingPostID, TPclass);
	rmSetObjectDefMinDistance(tradingPostID, 0.0);
	rmSetObjectDefMaxDistance(tradingPostID, 0.0);
	
	for(i = 0; < 5){
		createTradingRouteArea();
		rmPlaceObjectDefAtLoc(tradingPostID, 0, rmGetTradingPostXLoc(i+1), rmGetTradingPostYLoc(i+1), 1);
	}
	
	tradingPostID=rmCreateObjectDef("Trading Posts revealers");
	rmAddObjectDefItem(tradingPostID, "Revealer", 1, 0.0);
	rmSetObjectDefMinDistance(tradingPostID, 0.0);
	rmSetObjectDefMaxDistance(tradingPostID, 0.0);
	
	for(i = 0; < 5){
		rmPlaceObjectDefAtLoc(tradingPostID, 0, rmGetTradingPostXLoc(i+1), rmGetTradingPostYLoc(i+1), 1);
	}
	
	/**********************************/
	/* Step 3: connect Trading Routes */	rmSetStatusText("",0.30);
	/**********************************/
	
	tpConClass=rmDefineClass("tradingPost Connection");
	if(cNumberNonGaiaPlayers == 4){
		for(i = 1; < 6){
			if(i == 3){
				continue;
			}
			rmSetTP_Connection(i, createTradingRouteConnection());
			rmAddConnectionArea(rmGetTP_Connection(i), rmGetTradingPostAreaID(3));
			rmAddConnectionArea(rmGetTP_Connection(i), rmGetTradingPostAreaID(i));
		}
	} else {
		for(i = 1; < 5){
			rmSetTP_Connection(i, createTradingRouteConnection());
			rmAddConnectionArea(rmGetTP_Connection(i), rmGetTradingPostAreaID(i));
			rmAddConnectionArea(rmGetTP_Connection(i), rmGetTradingPostAreaID(i+1));
		}
	}
	
	for(i = 1; < 6){
		rmBuildArea(rmGetTradingPostAreaID(i));
	}
	for(i = 1; < 6){
		rmBuildConnection(rmGetTP_Connection(i));
	}
	
	/***********************************************/
	/* Step 4: place FairLocs & Starting resources */	rmSetStatusText("",0.45);
	/***********************************************/
	
	int avoidTPCons=rmCreateClassDistanceConstraint("stuff v TP connections", tpConClass, 2.0);
	int farAvoidTPCons=rmCreateClassDistanceConstraint("far avoid TP connections", tpConClass, 10.0);
	int avoidTPs=rmCreateClassDistanceConstraint("stuff v TPs", TPclass, 20.0);
	int farAvoidTPs = rmCreateClassDistanceConstraint("far avoid TPs", TPclass, 40.0);
	
	int avoidSettlement=rmCreateTypeDistanceConstraint("avoid TCs", "AbstractSettlement", 30.0);
	int farAvoidSettlement=rmCreateTypeDistanceConstraint("far avoid TCs", "AbstractSettlement", 50.0);
	
	int avoidPlayers=rmCreateClassDistanceConstraint("avoid players", playerClass, 10.0);
	
	int startingSettlementID=rmCreateObjectDef("starting settlement");
	rmAddObjectDefItem(startingSettlementID, "Settlement Level 1", 1, 0.0);
	rmSetObjectDefMinDistance(startingSettlementID, 0.0);
	rmSetObjectDefMaxDistance(startingSettlementID, 0.0);
	rmPlaceObjectDefPerPlayer(startingSettlementID, true);

	int startingGoldFairLocID=rmAddFairLoc("Starting Gold", false, false, 18, 19, 0, 10);
	if(rmPlaceFairLocs()){
		int startingGoldID=rmCreateObjectDef("Starting Gold");
		rmAddObjectDefItem(startingGoldID, "Gold Mine Small", 1, 0.0);
		for(i=1; <cNumberPlayers){
			for(j=0; <rmGetNumberFairLocs(i)){
				rmPlaceObjectDefAtLoc(startingGoldID, i, rmFairLocXFraction(i, j), rmFairLocZFraction(i, j), 1);
			}
		}
	}
	rmResetFairLocs();
	
	//Add a new FairLoc every time. This will have to be removed at the end of the block.
	id=rmAddFairLoc("Settlement", false, false, 65, 80, 0, 16);

	rmAddFairLocConstraint(id, farAvoidSettlement);	//Avoid player owned TCs
	rmAddFairLocConstraint(id, farAvoidTPs);		//Avoid Trading Routes
	rmAddFairLocConstraint(id, farAvoidTPCons);		//Avoid Trading Route Connections
	
	if(rmPlaceFairLocs()){
		for(p = 1; <= cNumberNonGaiaPlayers){
			id=rmCreateObjectDef("far settlement"+p);
			rmAddObjectDefItem(id, "Settlement", 1, 1.0);
			for(j=0; < rmGetNumberFairLocs(p)) {
				int settleArea = rmCreateArea("settlement area"+p +j);
				rmSetAreaLocation(settleArea, rmFairLocXFraction(p, j), rmFairLocZFraction(p, j));
				rmSetAreaSize(settleArea, 0.005, 0.005);
				rmSetAreaTerrainType(settleArea, "PlainDirt75");
				rmAddAreaTerrainLayer(settleArea, "PlainA", 0, 1);
				rmAddAreaTerrainLayer(settleArea, "PlainDirt25", 1, 3);
				rmAddAreaTerrainLayer(settleArea, "PlainDirt50", 3, 6);
				rmSetAreaCoherence(settleArea, 0.75);
				rmAddAreaConstraint(settleArea, farAvoidTPs);
				rmAddAreaConstraint(settleArea, farAvoidTPCons);
				rmBuildArea(settleArea);
				rmPlaceObjectDefAtAreaLoc(id, p, settleArea);
			}
		}
	}
	rmResetFairLocs();	//Reset the data so that the next player doesn't place an extra TC.
	
	int freeTCID=rmCreateObjectDef("free settlement");
	rmAddObjectDefItem(freeTCID, "Settlement", 1, 0.0);
	rmSetObjectDefMinDistance(freeTCID, 60.0);
	rmSetObjectDefMaxDistance(freeTCID, 70.0+10*cNumberNonGaiaPlayers);
	rmAddObjectDefConstraint(freeTCID, farAvoidTPs);
	rmAddObjectDefConstraint(freeTCID, farAvoidTPCons);
	rmAddObjectDefConstraint(freeTCID, farAvoidSettlement);
	rmPlaceObjectDefPerPlayer(freeTCID, false, 1);
	
	if(cMapSize == 2){
		rmSetObjectDefMaxDistance(freeTCID, 100.0+30*cNumberNonGaiaPlayers);
		rmPlaceObjectDefPerPlayer(freeTCID, false, 1);
		rmSetObjectDefMaxDistance(freeTCID, 100.0+60*cNumberNonGaiaPlayers);
		rmPlaceObjectDefPerPlayer(freeTCID, false, 1);
	}
	
	//Starting Hunt
	int huntShortAvoidsStartingGoldMilky=rmCreateTypeDistanceConstraint("short hunty avoid gold", "gold", 10.0);
	int startingHuntableID=rmCreateObjectDef("starting hunt");
	rmAddObjectDefItem(startingHuntableID, "deer", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 23.0);
	rmSetObjectDefMaxDistance(startingHuntableID, 26.0);
	rmAddObjectDefConstraint(startingHuntableID, huntShortAvoidsStartingGoldMilky);
	rmAddObjectDefConstraint(startingHuntableID, rmCreateTypeDistanceConstraint("short hunt avoid TC", "AbstractSettlement", 8.0));
	rmPlaceObjectDefPerPlayer(startingHuntableID, false);
	
	int littlePiggiesID=rmCreateObjectDef("This little piggy is just really hairy");
	rmAddObjectDefItem(littlePiggiesID, "Yak", 3, 2.0);
	rmSetObjectDefMinDistance(littlePiggiesID, 25.0);
	rmSetObjectDefMaxDistance(littlePiggiesID, 30.0);
	rmPlaceObjectDefPerPlayer(littlePiggiesID, true);
	
	int birdiessStayNearShore=rmCreateTerrainMaxDistanceConstraint("near shore", "water", true, 12.0);
	
	int numCrane=rmRandInt(6, 8);
	int startingBirdiesID=rmCreateObjectDef("starting birdies");
	rmAddObjectDefItem(startingBirdiesID, "duck", numCrane, 8.0);
	rmSetObjectDefMinDistance(startingBirdiesID, 35.0);
	rmSetObjectDefMaxDistance(startingBirdiesID, 45.0);
	rmPlaceObjectDefPerPlayer(startingBirdiesID, false);
	
	//Towers last
	int startingTowerID=rmCreateObjectDef("Starting tower");
	rmAddObjectDefItem(startingTowerID, "tower", 1, 0.0);
	rmSetObjectDefMinDistance(startingTowerID, 24.0);
	rmSetObjectDefMaxDistance(startingTowerID, 26.0);
	rmAddObjectDefConstraint(startingTowerID, rmCreateTypeDistanceConstraint("avoid tower", "tower", 24.0));
	rmPlaceObjectDefPerPlayer(startingTowerID, true, 4);
	
	
	/*******************************/
	/* Step 5: place far resources */	rmSetStatusText("",0.60);
	/*******************************/
	
	int avoidGold=rmCreateTypeDistanceConstraint("avoid gold", "gold", 30.0);
	int farAvoidGold=rmCreateTypeDistanceConstraint("far avoid gold", "gold", 50.0);
	
	int shortAvoidFood=rmCreateTypeDistanceConstraint("short avoid food", "food", 20.0);
	int avoidFood=rmCreateTypeDistanceConstraint("avoid food", "food", 40.0);
	int farAvoidFood=rmCreateTypeDistanceConstraint("far avoid food", "food", 60.0);
	
	int goldAvoidSettlement=rmCreateTypeDistanceConstraint("gold avoid TCs", "AbstractSettlement", 18.0);

	//Medium Gold
	int mediumGoldID=rmCreateObjectDef("medium gold");
	rmAddObjectDefItem(mediumGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(mediumGoldID, 50.0);
	rmSetObjectDefMaxDistance(mediumGoldID, 60.0);
	rmAddObjectDefConstraint(mediumGoldID, farAvoidGold);
	rmAddObjectDefConstraint(mediumGoldID, avoidTPs);
	rmAddObjectDefConstraint(mediumGoldID, goldAvoidSettlement);
	rmPlaceObjectDefPerPlayer(mediumGoldID, false);
	
	//Far Gold
	int farGoldID=rmCreateObjectDef("far gold");
	rmAddObjectDefItem(farGoldID, "Gold mine", 1, 0.0);
	rmSetObjectDefMinDistance(farGoldID, 70.0);
	rmSetObjectDefMaxDistance(farGoldID, 85.0);
	rmAddObjectDefConstraint(farGoldID, farAvoidGold);
	rmAddObjectDefConstraint(farGoldID, avoidTPs);
	rmAddObjectDefConstraint(farGoldID, goldAvoidSettlement);
	rmPlaceObjectDefPerPlayer(farGoldID, false, 2);

	//Medium Hunt
	int medHuntID=rmCreateObjectDef("medium hunt");
	rmAddObjectDefItem(medHuntID, "deer", rmRandInt(4,5), 3.0);
	rmSetObjectDefMaxDistance(medHuntID, 50.0);
	rmSetObjectDefMaxDistance(medHuntID, 60.0);
	rmAddObjectDefConstraint(medHuntID, avoidGold);
	rmAddObjectDefConstraint(medHuntID, avoidFood);
	rmAddObjectDefConstraint(medHuntID, avoidTPs);
	rmAddObjectDefConstraint(medHuntID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(medHuntID, false);
		
	//Far Hunt
	int farHuntID=rmCreateObjectDef("far hunt");
	rmAddObjectDefItem(farHuntID, "deer", 5, 3.0);
	rmSetObjectDefMaxDistance(farHuntID, 75.0);
	rmSetObjectDefMaxDistance(farHuntID, 85.0);
	rmAddObjectDefConstraint(farHuntID, avoidGold);
	rmAddObjectDefConstraint(farHuntID, farAvoidFood);
	rmAddObjectDefConstraint(farHuntID, avoidTPs);
	rmAddObjectDefConstraint(farHuntID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(farHuntID, false);
	
	//Far Herd
	int bigPiggiesID=rmCreateObjectDef("This little piggy is just misunderstood");
	rmAddObjectDefItem(bigPiggiesID, "Yak", 3, 2.0);
	rmSetObjectDefMinDistance(bigPiggiesID, 80.0);
	rmSetObjectDefMaxDistance(bigPiggiesID, 100.0);
	rmAddObjectDefConstraint(bigPiggiesID, avoidGold);
	rmAddObjectDefConstraint(bigPiggiesID, avoidFood);
	rmAddObjectDefConstraint(bigPiggiesID, avoidTPs);
	rmAddObjectDefConstraint(bigPiggiesID, avoidSettlement);
	rmPlaceObjectDefPerPlayer(bigPiggiesID, false, 2);
	
	if(cMapSize == 2){
		rmSetObjectDefMinDistance(farGoldID, 95.0);
		rmSetObjectDefMaxDistance(farGoldID, rmXFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(farGoldID, false, 2);
	
		rmSetObjectDefMinDistance(bigPiggiesID, 100.0);
		rmSetObjectDefMaxDistance(bigPiggiesID, rmXFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(bigPiggiesID, false, 2);
		
		rmSetObjectDefMaxDistance(farHuntID, 100.0);
		rmSetObjectDefMaxDistance(farHuntID, rmXFractionToMeters(0.35));
		rmPlaceObjectDefPerPlayer(farHuntID, false, 1);
	}
	
	/************************************/
	/* Step 6: place some small forests */	rmSetStatusText("",0.75);
	/************************************/
	
	int classForest=rmDefineClass("forest");
	int forestVsEdge=rmCreateBoxConstraint("forest v edge of map", rmXTilesToFraction(4), rmZTilesToFraction(4), 1.0-rmXTilesToFraction(4), 1.0-rmZTilesToFraction(4));
	int forestAvoidGold=rmCreateTypeDistanceConstraint("forest v gold", "gold", 16.0);
	int forestAvoidFood=rmCreateTypeDistanceConstraint("forest v food", "food", 14.0);
	int forestConstraint=rmCreateClassDistanceConstraint("forest v forest", rmClassID("forest"), 16.0);
	
	int forestCount=12*cNumberNonGaiaPlayers;
	if(cMapSize == 2){
		forestCount = 1.5*forestCount;
	}
	
	int failCount=0;
	for(i=0; <forestCount) {
		int forestID=rmCreateArea("forest"+i);
		rmSetAreaSize(forestID, rmAreaTilesToFraction(50), rmAreaTilesToFraction(100));
		if(cMapSize == 2) {
			rmSetAreaSize(forestID, rmAreaTilesToFraction(150), rmAreaTilesToFraction(200));
		}
		
		rmSetAreaWarnFailure(forestID, false);
		rmSetAreaForestType(forestID, "Mixed Plain Forest");
		rmAddAreaConstraint(forestID, forestAvoidGold);
		rmAddAreaConstraint(forestID, forestConstraint);
		rmAddAreaConstraint(forestID, forestAvoidFood);
		rmAddAreaConstraint(forestID, avoidTPs);
		rmAddAreaConstraint(forestID, avoidTPCons);
		rmAddAreaConstraint(forestID, forestVsEdge);
		rmAddAreaConstraint(forestID, goldAvoidSettlement);
		rmAddAreaToClass(forestID, classForest);
		
		rmSetAreaMinBlobs(forestID, 2);
		rmSetAreaMaxBlobs(forestID, 4);
		rmSetAreaMinBlobDistance(forestID, 16.0);
		rmSetAreaMaxBlobDistance(forestID, 20.0);
		rmSetAreaCoherence(forestID, 0.0);
		rmSetAreaBaseHeight(forestID, 0);
		rmSetAreaSmoothDistance(forestID, 4);
		rmSetAreaHeightBlend(forestID, 2);
		
		if(rmBuildArea(forestID)==false) {
			// Stop trying once we fail 3 times in a row.
			failCount++;
			if(failCount==3) {
				break;
			}
		} else {
			failCount=0;
		}
	}

	
	/*************************/
	/* Step 7: Pretty Things */	rmSetStatusText("",0.90);
	/*************************/
	
	int prettyVsForest=rmCreateClassDistanceConstraint("pretty v forest", rmClassID("forest"), 1.0);
	int shortAvoidSettlement=rmCreateTypeDistanceConstraint("pretty avoid TCs", "AbstractSettlement", 6.0);
	
	// Old and wrinkly
	for(i=1; <cNumberPlayers*6){
		int elevID=rmCreateArea("wrinkle "+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(16));
		rmSetAreaBaseHeight(elevID, rmRandFloat(2.0, 3.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, prettyVsForest);
		rmAddAreaConstraint(elevID, avoidTPCons);
		rmAddAreaConstraint(elevID, shortAvoidSettlement);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		rmBuildArea(elevID);
	}
	for(i=1; <cNumberPlayers*6*mapSizeMultiplier){
		elevID=rmCreateArea("wrinkle "+i);
		rmSetAreaSize(elevID, rmAreaTilesToFraction(15), rmAreaTilesToFraction(16));
		rmSetAreaBaseHeight(elevID, rmRandFloat(-1.0, -2.0));
		rmSetAreaHeightBlend(elevID, 1);
		rmSetAreaMinBlobs(elevID, 1);
		rmSetAreaMaxBlobs(elevID, 3);
		rmSetAreaWarnFailure(elevID, false);
		rmAddAreaConstraint(elevID, prettyVsForest);
		rmAddAreaConstraint(elevID, avoidTPCons);
		rmAddAreaConstraint(elevID, shortAvoidSettlement);
		rmSetAreaMinBlobDistance(elevID, 16.0);
		rmSetAreaMaxBlobDistance(elevID, 40.0);
		rmSetAreaCoherence(elevID, 0.0);
		
		rmBuildArea(elevID);
	}
	
	// Beautification sub area.
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier){
		int id4=rmCreateArea("Grass patch 1 "+i);
		rmSetAreaSize(id4, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16));
		rmSetAreaTerrainType(id4, "DirtB");
		rmAddAreaTerrainLayer(id4, "PlainDirt75", 0, 1);
		rmSetAreaMinBlobs(id4, 1);
		rmSetAreaMaxBlobs(id4, 5);
		rmSetAreaWarnFailure(id4, false);
		rmAddAreaConstraint(id4, prettyVsForest);
		rmAddAreaConstraint(id4, avoidTPCons);
		rmAddAreaConstraint(id4, shortAvoidSettlement);
		rmSetAreaMinBlobDistance(id4, 16.0);
		rmSetAreaMaxBlobDistance(id4, 40.0);
		rmSetAreaCoherence(id4, 0.0);
		
		rmBuildArea(id4);
	}
	
	// Beautification sub area.
	for(i=1; <cNumberPlayers*10*mapSizeMultiplier){
		int id6=rmCreateArea("Grass patch 2 "+i);
		rmSetAreaSize(id6, rmAreaTilesToFraction(5), rmAreaTilesToFraction(16));
		rmSetAreaTerrainType(id6, "CliffPlainB");
		rmSetAreaMinBlobs(id6, 1);
		rmSetAreaMaxBlobs(id6, 3);
		rmSetAreaWarnFailure(id6, false);
		rmAddAreaConstraint(id6, prettyVsForest);
		rmAddAreaConstraint(id6, avoidTPCons);
		rmAddAreaConstraint(id6, shortAvoidSettlement);
		rmSetAreaMinBlobDistance(id6, 16.0);
		rmSetAreaMaxBlobDistance(id6, 40.0);
		rmSetAreaCoherence(id6, 0.0);
		
		rmBuildArea(id6);
	}
	
	// Beautification sub area.
	for(i=1; <cNumberPlayers*8*mapSizeMultiplier){
		int id5=rmCreateArea("Grass patch 3 "+i);
		rmSetAreaSize(id5, rmAreaTilesToFraction(25), rmAreaTilesToFraction(75));
		rmSetAreaTerrainType(id5, "PlainB");
		rmAddAreaConstraint(id5, prettyVsForest);
		rmAddAreaConstraint(id5, avoidTPCons);
		rmAddAreaConstraint(id5, shortAvoidSettlement);
		rmSetAreaWarnFailure(id5, false);
		rmSetAreaCoherence(id5, 0.0);
		
		rmBuildArea(id5);
	}

	int avoidPredator=rmCreateTypeDistanceConstraint("avoid predator", "animalPredator", 40.0);
	
	// pick Tigers or Lizards as predators
	// avoid TCs and other animals
	int farPredatorID=rmCreateObjectDef("far predator");
	rmSetObjectDefMinDistance(farPredatorID, 50.0);
	rmSetObjectDefMaxDistance(farPredatorID, 100.0);
	rmAddObjectDefConstraint(farPredatorID, avoidPredator);
	rmAddObjectDefConstraint(farPredatorID, avoidSettlement);
	rmAddObjectDefConstraint(farPredatorID, shortAvoidFood);
	
	float predatorSpecies=rmRandFloat(0, 1);
	if(predatorSpecies<0.4){
		rmAddObjectDefItem(farPredatorID, "lizard", 2, 4.0);
		rmPlaceObjectDefPerPlayer(farPredatorID, false, 1);
	} else {
		rmAddObjectDefItem(farPredatorID, "Tiger", rmRandInt(1,2), 4.0);
		rmPlaceObjectDefPerPlayer(farPredatorID, false, 2);
	}
	
	
	// Random trees.
	int randomTreeID=rmCreateObjectDef("random tree");
	rmAddObjectDefItem(randomTreeID, "Tree Jungle", 1, 0.0);
	rmSetObjectDefMinDistance(randomTreeID, 0.0);
	rmSetObjectDefMaxDistance(randomTreeID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(randomTreeID, rmCreateTypeDistanceConstraint("random tree", "all", 4.0));
	rmAddObjectDefConstraint(randomTreeID, avoidGold);
	rmAddObjectDefConstraint(randomTreeID, avoidSettlement);
	rmPlaceObjectDefAtLoc(randomTreeID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	int logID=rmCreateObjectDef("log");
	rmAddObjectDefItem(logID, "bush", rmRandInt(1,3), 3.0);
	rmAddObjectDefItem(logID, "grass", rmRandInt(6,8), 12.0);
	rmSetObjectDefMinDistance(logID, 0.0);
	rmSetObjectDefMaxDistance(logID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(logID, avoidGold);
	rmAddObjectDefConstraint(logID, avoidSettlement);
	rmPlaceObjectDefAtLoc(logID, 0, 0.5, 0.5, 10*cNumberNonGaiaPlayers*mapSizeMultiplier);
	
	// Relics avoid TCs
	int relicID=rmCreateObjectDef("relic");
	rmAddObjectDefItem(relicID, "relic", 1, 0.0);
	rmSetObjectDefMinDistance(relicID, 0.0);
	rmSetObjectDefMaxDistance(relicID, rmZFractionToMeters(0.5));
	rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic", "relic", 70.0));
	rmAddObjectDefConstraint(relicID, prettyVsForest);
	rmAddObjectDefConstraint(relicID, avoidPlayers);
	rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	if(cMapSize == 2){
		rmAddObjectDefConstraint(relicID, rmCreateTypeDistanceConstraint("relic vs relic Giant", "relic", 120.0));
		rmPlaceObjectDefAtLoc(relicID, 0, 0.5, 0.5, cNumberNonGaiaPlayers);
	}
	
	/*****************************/
	/* Step 8: Change to gardens */	rmSetStatusText("",0.90);
	/*****************************/
	
	rmCreateTrigger("Change");
	rmSetTriggerPriority(3);
	rmSetTriggerActive(true);
	rmSetTriggerRunImmediately(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("Always");
	for(i=1; <cNumberPlayers){
		rmAddTriggerEffect("Set Tech Status");
		rmSetTriggerEffectParamInt("PlayerID", i);
		rmSetTriggerEffectParam("TechID", "378");
		rmSetTriggerEffectParam("Status", "4");
	}
	for(i = 0; < 5){
		code("trUnitSelectClear();trUnitSelect(\""+i+"\");");
		code("trUnitChangeProtoUnit(\"Plenty Vault KOTH\");");
	}
//	for(i = 5; < 10){
//		code("trUnitSelectClear();trUnitSelect(\""+i+"\");trUnitDestroy();");
//	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	rmSetStatusText("",1.00);
}
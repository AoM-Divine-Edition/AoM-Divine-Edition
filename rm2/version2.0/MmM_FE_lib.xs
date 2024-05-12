/*	MILKMAN MATTY'S (Forgotten Empires) RANDOM MAP SCRIPT LIBRARY
**
**	This file is full of goodies, tips and tricks for getting certain things done easier, quicker or more reliable than what is normally possible.
**	
**	Credits to SlySherZ for increasing the efficiency of the Math functions (originally from Matei and TwentyOneScore).
*/

mutable void initiateLocation() { }

/*************************
****** MATH LIBRARY ******
*************************/
extern const float PI = 3.141592;

bool Math_even( int x = 0 ){
	return (x % 2 == 0);
}

float Math_abs(float a = 0) {
	if(a>=0) {return (0.0+a);}
	else {return (0.0-a);}
}

float Math_sin(float n = 0.0)	{
	float pow = n;
	float fact = 1.0;
	float r = n;
    for(i = 1; < 100) {
        int j = 2.0 * i + 1.0;
        pow = pow * n * n;
        fact = fact * j * (j - 1.0);
        float k = pow / fact;
        if(k == 0) break;
        if(Math_even(i)) 	r = r + k;
        else 				r = r - k;
    }
    return (r);
}

float Math_atan(float n = 0.0){
    float m = n;
    if(n > 1.0) m = 1.0 / n;
    if(n < -1.0) m = -1.0 / n;
    float r = m;
	float pow = m;
    for(i = 1; < 10 * 100) {
		pow = pow * m * m;
        int j = 2.0 * i + 1.0;
        float k = pow / j;
        if(k == 0) break;
        if(i % 2 == 0) r = r + k;
        else r = r - k;
    }
    if(n > 1.0 || n < -1.0) r = PI / 2.0 - r;
    if(n < -1.0) r = 0.0 - r;

    return (r);
}

float Math_cos(float n = 0.0) {
	float pow = 1.0;
	float fact = 1.0;
    float r = 1.0;
    for(i = 1; < 100) {
        int j = 2.0 * i;
		pow = pow * n * n;
        fact = fact * j * (j - 1.0);
        float k = pow / fact;
        if(k == 0) break;
        if(Math_even(i)) 	r = r + k;
        else 				r = r - k;
    }
    return (r);
}

float Math_sqr(float number = 0){
	return (number*number);
}

/* Converts Polar into Cartesian X.
**
** @param angle:	the angle to convert.
** @param radius:	the radius to convert.
** @param offsetX:	this should be the X Cartesian coordinate for the middle of the circle.
** @returns:	the Cartesian X coordinate converted from the polar coordinates provided.
*/
float getXFromPolar( float angle = -1.0, float radius = -1.0, float ofsetX = 0.0 ){
	return ( 0.0 + ofsetX + 1.0 * radius * Math_cos( angle ) );
	
}

/* Converts Polar into Cartesian Z
**
** @param angle:	the angle to convert.
** @param radius:	the radius to convert.
** @param offsetY:	this should be the Y Cartesian coordinate for the middle of the circle.
** @returns:	the Cartesian Y coordinate converted from the polar coordinates provided.
*/
float getZFromPolar( float angle = -1.0, float radius = -1.0, float ofsetY = 0.0 ){
	return ( 0.0 + ofsetY + 1.0 * radius * Math_sin( angle ) );
	
}

/*************************
**** TRIGGER LIBRARY *****
*************************/

void code(string xs = ""){
	rmAddTriggerEffect("Write To Log");
	rmSetTriggerEffectParam("Message", "\");"+xs+"//");
}

void condition(string xs="") {
	rmAddTriggerCondition("Quest Var Check");
	rmSetTriggerConditionParam("QuestVar", "Milky");
	rmSetTriggerConditionParam("Op", "==");
	rmSetTriggerConditionParam("Value", "0 && "+xs+"", false);
}

int safe_msg = -1;
void chat(bool spoofed = false, string msg = "", bool all = true, int toPlayer = 1, bool safe = false){
	if(safe){
		safe_msg++;
		rmCreateTrigger("safe"+safe_msg);
		rmSwitchToTrigger(rmTriggerID("safe"+safe_msg));
		rmSetTriggerActive(true);
		rmSetTriggerPriority(3);
		rmSetTriggerLoop(false);
	}
	if(all){
		if(spoofed){
			code("trChatSendSpoofed(0, \""+msg+"\");");
		} else {
			code("trChatSend(0, \""+msg+"\");");
		}
	} else {
		if(toPlayer > 0){
			if(spoofed){
				code("trChatSendSpoofedToPlayer(0, toPlayer,\""+msg+"\");");
			} else {
				code("trChatSendToPlayer(0, toPlayer,\""+msg+"\");");
			}
		}
	}
}


/*************************
* OBJECT SETTING LIBRARY *
*************************/

extern string init = "";
extern int gaiaGod = -1;

extern string treeType = "";
extern string treesType = "";
extern string terrainType1 = "";
extern string terrainType2 = "";
extern string terrainType3 = "";
extern string terrainBeauty = "";
extern string cliffType = "";
extern string cliffTile = "";
extern string roadType = "";
extern string rockType = "";
extern string spriteType = "";

extern string coral1 = "";
extern string coral2 = "";
extern string coral3 = "";
extern string coral4 = "";
extern string terrainType4 = "";
extern string terrainType5 = "";

extern string mainHunt = "";
extern string secondHunt = "";
extern string bonusHunt = "";
extern string bonusHunt2 = "";
extern string herd = "";
extern string preds = "";
extern string birdType = "";

extern string beautyObject1 = "";
extern string beautyObject2 = "";
extern string beautyObject3 = "";
extern string environmentObj = "";

int water_lib = -1;
int season_lib = -1;
extern int location_lib = -1;
bool needToRunOnce = true;

int rmGetLocation(){
	if(location_lib == -1){
		location_lib = rmRandInt(0,4);
		//location_lib = 4;
		if(needToRunOnce){
			needToRunOnce = false;
			initiateLocation();
		}
	}
	return (location_lib);
}

int rmGetWater(){
	if(water_lib == -1){
		water_lib = rmRandInt(0,1);
	}
	return (water_lib);
}

void initiateLocation(){
	
		if(rmGetLocation() == 0){
			//Egypt
			init = "SandA";
			gaiaGod = cCivIsis;
			
			treeType = "savannah tree";
			treesType = "savannah forest";
			
			cliffType  = "Egyptian";
			cliffTile  = "CliffEgyptianA";
			roadType = "EgyptianRoadA";
			terrainType1 = "SandC";
			terrainType2 = "SandB";
			terrainType3 = "SandD";
			terrainBeauty = "SavannahA";
			//rmSetLightingSet("anatolia");
			
			mainHunt = "Gazelle";
			secondHunt = "giraffe";
			bonusHunt = "Hippo";
			bonusHunt2 = "rhinocerous";
			herd = "pig";
			if(rmRandInt(0,1) == 0){
				preds = "lion";
			} else {
				preds = "hyena";
			}
			birdType = "vulture";
			
			beautyObject1 = "Statue Pharaoh";
			beautyObject2 = "Statue Lion Left";
			beautyObject3 = "Statue Lion Right";
			environmentObj = "Sand Drift Plain";
			rockType = "rock sandstone small";
			spriteType = "rock sandstone sprite";			
			
		} else if(rmGetLocation() == 1){
			//Greek
			init = "GrassA";
			gaiaGod = cCivZeus;
			
			treeType = "pine";
			treesType = "pine forest";
			
			cliffType  = "Greek";
			cliffTile  = "CliffGreekA";
			roadType = "GreekRoadA";
			terrainType1 = "CliffGreekB";
			terrainType2 = "GrassDirt25";
			terrainType3 = "GrassDirt50";
			terrainBeauty = "grassB";
			//rmSetLightingSet("alfheim");
			
			mainHunt = "deer";
			secondHunt = "deer";
			bonusHunt = "Aurochs";
			bonusHunt2 = "Aurochs";
			herd = "goat";
			if(rmRandInt(0,1) == 0){
				preds = "bear";
			} else {
				preds = "wolf";
			}
			birdType = "hawk";
			
			beautyObject1 = "GaiaCreepFlowers";
			beautyObject2 = "Gaia Forest effect";
			beautyObject3 = "Milestone";
			environmentObj = "Blowing leaves";
			rockType = "rock limestone small";
			spriteType = "Rock limestone Sprite";
			
		} else if(rmGetLocation() == 2){
			//Norse
			init = "SnowA";
			gaiaGod = cCivThor;
			
			treeType = "pine snow";
			treesType = "snow pine forest";
			
			cliffType  = "Norse";
			cliffTile  = "CliffNorseA";
			roadType = "NorseRoadA";
			terrainType1 = "snowgrass25";
			terrainType2 = "snowgrass50";
			terrainType3 = "snowgrass75";
			terrainBeauty = "snowB";
			//rmSetLightingSet("fimbulwinter");
			
			mainHunt = "Elk";
			secondHunt = "Caribou";
			bonusHunt = "Walrus";
			bonusHunt2 = "Walrus";
			herd = "Cow";
			preds = "Polar Bear";
			birdType = "hawk";
			
			beautyObject1 = "Runestone";
			beautyObject2 = "Rock Symbols";
			beautyObject3 = "Rock Snow";
			environmentObj = "Snow Drift Settlements";
			rockType = "rock river icy";
			spriteType = "rock granite sprite";			
		} else if(rmGetLocation() == 3) {
			//Erebus
			init = "Hadesbuildable1";
			gaiaGod = cCivHades;
			
			treeType = "Pine Dead";
			treesType = "Hades Forest";
			
			cliffType  = "Hades";
			cliffTile  = "HadesCliff";
			roadType = "GreekRoad Burnt";
			terrainType1 = "Hadesbuildable1";
			terrainType2 = "Hadesbuildable2";
			terrainType3 = "Hadesbuildable2";
			terrainBeauty = "Hades5";
			//rmSetLightingSet("erebus");
			
			mainHunt = "Boar";
			secondHunt = "Boar";
			bonusHunt = "Shade of Erebus";
			bonusHunt2 = "boar";
			herd = "pig";
			preds = "serpent";
			birdType = "harpy";
			
			beautyObject1 = "fire Hades";
			beautyObject2 = "stalagmite";
			beautyObject3 = "ruins";
			environmentObj = "lava bubbling";
			rockType = "Rock Granite Big";
			spriteType = "rock limestone sprite";
		} else if(rmGetLocation() == 4) {
			//Atlantis
			init = "coralC";
			//gaiaGod = cCivKronos;
			
			treeType = "Gaia Forest tree";
			treesType = "Palm forest";
			
			cliffType  = "Greek";
			cliffTile  = "CliffGreekA";
			roadType = "CityTileAtlantis";
			terrainType1 = "grassB";
			terrainType2 = "GaiaCreepB";
			terrainType3 = "GaiaCreepBorderSand";
			terrainBeauty = "GaiaCreepA";
			
			terrainType4 = "CliffGreekB";
			terrainType5 = "GaiaCreepBorder";
			
			coral1 = "CityTileAtlantiscoral";
			coral2 = "coralC2";
			coral3 = "coralB";
			coral4 = "CoralA";
			
			//rmSetLightingSet("olympus");
			
			mainHunt = "deer";
			secondHunt = "Crowned Crane";
			bonusHunt = "Crowned Crane";
			bonusHunt2 = "Water Buffalo";
			herd = "pig";
			preds = "wolf";
			birdType = "hawk";
			
			beautyObject1 = "GaiaCreepFlowers";
			beautyObject2 = "Columns";
			beautyObject3 = "Ruins";
			environmentObj = "Audrey Base";
			rockType = "rock limestone Big";
			spriteType = "Rock limestone Sprite";
		} else {
			//Chinese
			init = "PlainA";
			gaiaGod = cCivNature;
			
			treeType = "Tree Jungle";
			treesType = "Plain forest";
			
			cliffType  = "Plain";
			cliffTile  = "CliffGreekA";
			roadType = "PlainRoadA";
			terrainType1 = "PlainDirt25";
			terrainType2 = "PlainDirt50";
			terrainType3 = "PlainDirt75";
			terrainBeauty = "PlainB";
			
			terrainType4 = "CliffPlainB";
			terrainType5 = "DirtA";
			
			//rmSetLightingSet("olympus");
			
			mainHunt = "deer";
			secondHunt = "Duck";
			bonusHunt = "Ram";
			bonusHunt2 = "Ram";
			herd = "Yak";
			preds = "wolf";
			birdType = "parrot";
			
			beautyObject1 = "GaiaCreepFlowers";
			beautyObject2 = "Gaia Forest effect";
			beautyObject3 = "Milestone";
			environmentObj = "Blowing leaves";
			rockType = "rock limestone small";
			spriteType = "Rock limestone Sprite";
		}
}

/*************************
**** PLAYER PLACEMENT ****
*************************/

float x_P1 = 0;		float x_P2 = 0;		float x_P3 = 0;		float x_P4 = 0;
float z_P1 = 0;		float z_P2 = 0;		float z_P3 = 0;		float z_P4 = 0;

float x_P5 = 0;		float x_P6 = 0;		float x_P7 = 0;		float x_P8 = 0;
float z_P5 = 0;		float z_P6 = 0;		float z_P7 = 0;		float z_P8 = 0;

float x_P9 = 0;		float x_P10 = 0;	float x_P11 = 0;	float x_P12 = 0;
float z_P9 = 0;		float z_P10 = 0;	float z_P11 = 0;	float z_P12 = 0;

//Don't need else since it will exit upon true conditions - and now it aligns :D
float rmGetPlayerX(int player = 1){
	if(player == 1){	return(x_P1);}
	if(player == 2){	return(x_P2);}
	if(player == 3){	return(x_P3);}
	if(player == 4){	return(x_P4);}
	if(player == 5){	return(x_P5);}
	if(player == 6){	return(x_P6);}
	if(player == 7){	return(x_P7);}
	if(player == 8){	return(x_P8);}
	if(player == 9){	return(x_P9);}
	if(player == 10){	return(x_P10);}
	if(player == 11){	return(x_P11);}
	if(player == 12){	return(x_P12);}
}

float rmGetPlayerZ(int player = 1){
	if(player == 1){	return(z_P1);}
	if(player == 2){	return(z_P2);}
	if(player == 3){	return(z_P3);}
	if(player == 4){	return(z_P4);}
	if(player == 5){	return(z_P5);}
	if(player == 6){	return(z_P6);}
	if(player == 7){	return(z_P7);}
	if(player == 8){	return(z_P8);}
	if(player == 9){	return(z_P9);}
	if(player == 10){	return(z_P10);}
	if(player == 11){	return(z_P11);}
	if(player == 12){	return(z_P12);}
}

void rmSetPlayerX(int player = 1, float val = -1){
	if(player == 1){	x_P1 = val;}
	if(player == 2){	x_P2 = val;}
	if(player == 3){	x_P3 = val;}
	if(player == 4){	x_P4 = val;}
	if(player == 5){	x_P5 = val;}
	if(player == 6){	x_P6 = val;}
	if(player == 7){	x_P7 = val;}
	if(player == 8){	x_P8 = val;}
	if(player == 9){	x_P9 = val;}
	if(player == 10){	x_P10 = val;}
	if(player == 11){	x_P11 = val;}
	if(player == 12){	x_P12 = val;}
}

void rmSetPlayerZ(int player = 1, float val = -1){
	if(player == 1){	z_P1 = val;}
	if(player == 2){	z_P2 = val;}
	if(player == 3){	z_P3 = val;}
	if(player == 4){	z_P4 = val;}
	if(player == 5){	z_P5 = val;}
	if(player == 6){	z_P6 = val;}
	if(player == 7){	z_P7 = val;}
	if(player == 8){	z_P8 = val;}
	if(player == 9){	z_P9 = val;}
	if(player == 10){	z_P10 = val;}
	if(player == 11){	z_P11 = val;}
	if(player == 12){	z_P12 = val;}
}

void rmRecordPlayerLocations(){
	for(player = 1; <= cNumberNonGaiaPlayers){
		rmSetPlayerX(player, rmPlayerLocXFraction(player));
		rmSetPlayerZ(player, rmPlayerLocZFraction(player));
	}
}

bool rmGetNextPlayer(int player = 1){
	if(player == cNumberNonGaiaPlayers){
		return(1);
	}
	return(player+1);
}

bool rmGetPreviousPlayer(int player = 1){
	if(player == 1 || player > cNumberNonGaiaPlayers){
		return(cNumberNonGaiaPlayers);
	}
	return(player-1);
}

float xA = 0;		float xB = 0;		float xC = 0;		float xD = 0;
float zA = 0;		float zB = 0;		float zC = 0;		float zD = 0;

float xE = 0;		float xF = 0;		float xG = 0;		float xH = 0;
float zE = 0;		float zF = 0;		float zG = 0;		float zH = 0;

float xI = 0;		float xJ = 0;		float xK = 0;		float xL = 0;
float zI = 0;		float zJ = 0;		float zK = 0;		float zL = 0;

//Don't need else since it will exit upon true conditions - and now it aligns :D
float rmGetCustomLocXForPlayer(int player = 1){
	if(player == 1){	return(xA);}
	if(player == 2){	return(xB);}
	if(player == 3){	return(xC);}
	if(player == 4){	return(xD);}
	if(player == 5){	return(xE);}
	if(player == 6){	return(xF);}
	if(player == 7){	return(xG);}
	if(player == 8){	return(xH);}
	if(player == 9){	return(xI);}
	if(player == 10){	return(xJ);}
	if(player == 11){	return(xK);}
	if(player == 12){	return(xL);}
}

float rmGetCustomLocZForPlayer(int player = 1){
	if(player == 1){	return(zA);}
	if(player == 2){	return(zB);}
	if(player == 3){	return(zC);}
	if(player == 4){	return(zD);}
	if(player == 5){	return(zE);}
	if(player == 6){	return(zF);}
	if(player == 7){	return(zG);}
	if(player == 8){	return(zH);}
	if(player == 9){	return(zI);}
	if(player == 10){	return(zJ);}
	if(player == 11){	return(zK);}
	if(player == 12){	return(zL);}
}

float rmSetCustomLocXForPlayer(int player = 1, float val = -1){
	if(player == 1){	xA = val;}
	if(player == 2){	xB = val;}
	if(player == 3){	xC = val;}
	if(player == 4){	xD = val;}
	if(player == 5){	xE = val;}
	if(player == 6){	xF = val;}
	if(player == 7){	xG = val;}
	if(player == 8){	xH = val;}
	if(player == 9){	xI = val;}
	if(player == 10){	xJ = val;}
	if(player == 11){	xK = val;}
	if(player == 12){	xL = val;}
}

float rmSetCustomLocZForPlayer(int player = 1, float val = -1){
	if(player == 1){	zA = val;}
	if(player == 2){	zB = val;}
	if(player == 3){	zC = val;}
	if(player == 4){	zD = val;}
	if(player == 5){	zE = val;}
	if(player == 6){	zF = val;}
	if(player == 7){	zG = val;}
	if(player == 8){	zH = val;}
	if(player == 9){	zI = val;}
	if(player == 10){	zJ = val;}
	if(player == 11){	zK = val;}
	if(player == 12){	zL = val;}
}

int errorCounter = 0;

float placePointsCircle(float radius = -1.0, int numberOfPlayers = cNumberNonGaiaPlayers, float angleToUse = -1.0, float locX = -1.0, bool setPlayerLocation = false, bool half = false){

	//First select a random number within the radius
	float distanceConstant = (2.0*PI/numberOfPlayers);
	float startingXpoint = rmRandFloat(0.0, radius);
	if(locX != -1.0){
		startingXpoint = locX;
	}
	float startingZpoint = sqrt(Math_sqr(radius) - Math_sqr(startingXpoint));
	float angle = Math_atan(startingZpoint/startingXpoint);
	if(angleToUse != -1.0){
		angle = angleToUse;
	}
	angleToUse = angle;
	
	rmSetCustomLocXForPlayer(1, radius * Math_cos(angle) + 0.5);
	rmSetCustomLocZForPlayer(1, radius * Math_sin(angle) + 0.5);
	
	rmEchoInfo("Old: "+(startingXpoint+0.5)+", "+(startingZpoint+0.5));
	rmEchoInfo("New: "+rmGetCustomLocXForPlayer(1)+", "+rmGetCustomLocZForPlayer(1));
	
	if(half){
		angle = angle + distanceConstant/2.0;
		xA = radius * Math_cos(angle) + 0.5; 
		zA = radius * Math_sin(angle) + 0.5;
	}
	//rmEchoError("angle = "+angle);
	
	for(i = 2; <= numberOfPlayers){
		rmSetCustomLocXForPlayer(i, radius * Math_cos(angle + distanceConstant) + 0.5);
		rmSetCustomLocZForPlayer(i, radius * Math_sin(angle + distanceConstant) + 0.5);
		angle = angle + distanceConstant;
	}
	
	//Set Player Location
	if(setPlayerLocation){
		for(player = 1; <= numberOfPlayers){
			rmSetPlayerLocation(player, rmGetCustomLocXForPlayer(player), rmGetCustomLocZForPlayer(player));
		}
	}
	rmEchoError("returning angle: "+angleToUse);
	
	rmCreateTrigger("rmEchoInfo "+errorCounter);
	rmSetTriggerPriority(0);
	rmSetTriggerActive(false);
	rmSetTriggerRunImmediately(false);
	rmSetTriggerLoop(false);
	rmAddTriggerCondition("always");
	for(p = 1; <= numberOfPlayers){
		rmAddTriggerEffect("Write To Log");
		rmSetTriggerEffectParam("Message", "angleToUse: "+angleToUse);
		rmAddTriggerEffect("Write To Log");
		rmSetTriggerEffectParam("Message", ""+rmGetCustomLocXForPlayer(p)+", "+rmGetCustomLocZForPlayer(p));
	}
	errorCounter++;
	return (angleToUse);
}

//This allows you to specify where to place the circle's centre. The other method always uses the centre of the map (0.5, 0.5). Here you can use your own.
float placePointsCircleCustom(float radius = -1.0, int numberOfIntervals = cNumberNonGaiaPlayers, float angleToUse = -1.0, float locX = -1.0, float centreX = 0.5, float centreZ = 0.5, bool setPlayerLocation = false, bool half = false){

	//First select a random number within the radius
	float distanceConstant = (2.0*PI/numberOfIntervals);
	float startingXpoint = rmRandFloat(0.0, radius);
	if(locX != -1.0){
		startingXpoint = locX;
	}
	float startingZpoint = sqrt(Math_sqr(radius) - Math_sqr(startingXpoint));
	float angle = Math_atan(startingZpoint/startingXpoint);
	if(angleToUse != -1.0){
		angle = angleToUse;
	}
	
	xA = startingXpoint + centreX;
	zA = startingZpoint + centreZ;
	
	if(half){
		angle = angle + distanceConstant/2.0;
		xA = radius * Math_cos(angle) + centreX; 
		zA = radius * Math_sin(angle) + centreZ;
	}
	rmEchoInfo("angle = "+angle);
	
	for(i = 2; <= numberOfIntervals){
		rmSetCustomLocXForPlayer(i, radius * Math_cos(angle + distanceConstant) + centreX);
		rmSetCustomLocZForPlayer(i, radius * Math_sin(angle + distanceConstant) + centreZ);
		angle = angle + distanceConstant;
	}
	
	//Set Player Location
	if(setPlayerLocation){
		for(player = 1; <= numberOfIntervals){
			rmSetPlayerLocation(player, rmGetCustomLocXForPlayer(player), rmGetCustomLocZForPlayer(player));
		}
	}
	return (angle);
}

bool rmPlaceObjectNotInBox(int ObjID = -1, int playerID = 0, int placeAtATime = 1, int placeCount = 1, float minDist = 0.0, float maxDist = 0.0, float ax = 0.0, float az = 0.0, float bx = 0.0, float bz = 0.0, float minVariance = 0.0, float maxVariance = 1.0){
	
	rmCreateTrigger("AoMEE Echo Error");
	rmSetTriggerActive(true);
	rmSetTriggerPriority(4);
	
	if(ObjID == -1){
		rmEchoError("rmPlaceObjectNotInBox: No object to place");
		chat(true, "No object to place", false, 0);
		return (false);
	} else if(placeCount < 1 || placeAtATime < 1){
		rmEchoError("Cannot place 0");
		chat(true, "rmPlaceObjectNotInBox: Cannot place 0", false, 0);
		return (false);
	}
	
	float temp = -1;
	if(ax > bx){
		temp = ax;
		ax = bx;
		bx = temp;
	} if(az > bz){
		temp = az;
		az = bz;
		bz = temp;
	} if(minVariance > maxVariance){
		temp = minVariance;
		minVariance = maxVariance;
		maxVariance = temp;
	}
	
	minDist = rmXMetersToFraction(minDist);
	maxDist = rmXMetersToFraction(maxDist);
	rmEchoError("distances: "+minDist+", "+maxDist);
	chat(true, "distances: "+minDist+", "+maxDist, false, 1);
	float spreadX = rmRandFloat(minDist, maxDist);
	float spreadZ = rmRandFloat(minDist, maxDist);
	
	float Xpoint = rmRandFloat(minDist, maxDist) + rmGetPlayerX(playerID);
	if(rmRandFloat(0,1) > 0.5){
		Xpoint = rmRandFloat(-1.0*minDist, -1.0*maxDist) + rmGetPlayerX(playerID);
	}
	float Zpoint = rmRandFloat(minDist, maxDist) + rmGetPlayerZ(playerID);
	if(rmRandFloat(0,1) > 0.5){
		Xpoint = rmRandFloat(-1.0*minDist, -1.0*maxDist) + rmGetPlayerX(playerID);
	}
	
	while((Xpoint >= ax && Xpoint <= bx) && (Zpoint >= az && Zpoint <= bz)){
		Xpoint = rmRandFloat(minDist, maxDist) + rmGetPlayerX(playerID);
		if(rmRandFloat(0,1) > 0.5){
			Xpoint = rmRandFloat(-1.0*minDist, -1.0*maxDist) + rmGetPlayerX(playerID);
		}
		Zpoint = rmRandFloat(minDist, maxDist) + rmGetPlayerZ(playerID);
		if(rmRandFloat(0,1) > 0.5){
			Xpoint = rmRandFloat(-1.0*minDist, -1.0*maxDist) + rmGetPlayerX(playerID);
		}
	}
	rmEchoInfo("Placing object out of box at: "+Xpoint+", "+Zpoint);
	
	rmSetObjectDefMinDistance(ObjID, minVariance);
	rmSetObjectDefMaxDistance(ObjID, maxVariance);
	
	int attempts = 0;
	while(true){
		if(attempts > 50){
			return (false);
		}
		rmPlaceObjectDefAtLoc(ObjID, 0, Xpoint, Zpoint, placeAtATime);
		if(rmGetNumberUnitsPlaced(ObjID) >= placeCount){
			break;
		}
		rmSetObjectDefMaxDistance(ObjID, maxVariance+attempts);
		attempts++;
	}
	return (true);
}


//This allows you to specify an Ellipse to place and object within. ObjectID is always placed as Gaia. Places one per player.
float rmPlaceEllipseFromPlayerLoc(float minRadius = -1.0, float maxRadius = -1.0, float radiusMuliplier = 2.0, int ObjID = -1){
	
	if(ObjID == -1){
		return (-1.0);
	}
	
	float startAngle = Math_atan( (rmGetPlayerZ(1) - 0.5) / (rmGetPlayerX(1) - 0.5) ) - (PI / cNumberPlayers); //Players+1
	float distanceConstant = (2.0*PI/cNumberNonGaiaPlayers);
	
	float startingXpoint = -1.0;
	float startingZpoint = -1.0;
	
	float tempAngle = -1;
	float tempRadius = -1;
	
	int numTimesPlaced = rmGetNumberUnitsPlaced(ObjID);
	
	rmCreateTrigger("AoMEE Echo Error");
	rmSetTriggerActive(true);
	rmSetTriggerPriority(4);
	
	for(p = 1; <= cNumberNonGaiaPlayers){
		for(placeAttempt = 0; < 350){

			tempAngle = rmRandFloat(0, (2.0*PI/cNumberPlayers));
			tempRadius = rmRandFloat(minRadius, maxRadius);
			
			tempRadius = tempRadius * (Math_abs(tempAngle - ((2.0*PI/(cNumberNonGaiaPlayers*1.0))/2.0) ) / (2.0*PI/(cNumberNonGaiaPlayers*1.0))) * radiusMuliplier;
			
			startingXpoint = getXFromPolar(startAngle + tempAngle + ((cNumberNonGaiaPlayers-1) * distanceConstant), tempRadius, 0.5);
			startingZpoint = getZFromPolar(startAngle + tempAngle + ((cNumberNonGaiaPlayers-1) * distanceConstant), tempRadius, 0.5);
			
			rmPlaceObjectDefAtLoc(ObjID, 0, startingXpoint, startingZpoint, 1);
			if(rmGetNumberUnitsPlaced(ObjID) > numTimesPlaced){
				chat(true, "numTimesPlaced: "+numTimesPlaced, false, 0);
				break;
			}
			maxRadius = maxRadius + 0.001;
			chat(true, "placeAttempt: "+placeAttempt, false, 0);
		}
		numTimesPlaced++;
		distanceConstant = distanceConstant + distanceConstant;
	}
	return (startAngle);
}

//Places a set number of points in a line between to locations with the same Z coordinate. Records the first 12 points in the line.
void rmPlacePointsLineX(int spots = 1, float constantZ = -1.0, float startX = 0.0, float endX = 0.0){
	
	if(constantZ == -1.0){
		return;
	}
	
	for(p = 1; <= spots){
		rmSetCustomLocZForPlayer(p, constantZ);
	}
	
	float modifier = 0;
	if(startX > endX){
		modifier = (startX - endX) / spots;
	} else {
		modifier = (endX - startX) / spots;
	}
	
	float placementX = modifier;
	zA = placementX;
	placementX = placementX + modifier;
	
	if(spots > 1){
		zB = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 2){
		zC = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 3){
		zD = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 4){
		zE = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 5){
		zF = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 6){
		zG = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 7){
		zH = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 8){
		zI = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 9){
		zJ = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 10){
		zK = placementX;
		placementX = placementX + modifier;
	}
	if(spots > 11){
		zL = placementX;
	}
}

//Places a set number of points in a line between to locations with the same X coordinate. Records the first 12 points in the line.
void rmPlacePointsLineZ(int spots = 1, float constantX = -1.0, float startZ = 0.0, float endZ = 0.0){
	
	if(constantX == -1.0){
		return;
	}
	
	for(p = 1; <= spots){
		rmSetCustomLocXForPlayer(p, constantX);
	}
	
	float interval = 0.0;
	float temp = 0.0;
	if(startZ > endZ){
		temp = startZ;
		startZ = endZ;
		endZ = temp;
	}
	
	if(spots == 1){
		interval = 0.5;
	} else {
		interval = (endZ - startZ) / (spots-1);
	}
	
	float placementZ = startZ;
	
	for(loop = 1; <= spots){
		rmSetCustomLocZForPlayer(loop, placementZ);
		placementZ = placementZ + interval;
	}
}

//Places an ObjectDef in a line between to locations with the same Z coordinate. Objects placed this way cannot have their place location tracked!
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

//Places an ObjectDef in a line between to locations with the same X coordinate. Objects placed this way cannot have their place location tracked!
void rmPlaceObjectDefInLineZ(int ObjID = -1, int playerID = 0, int spots = 1, float constantX = -1.0, float startZ = 0.0, float endZ = 0.0, float varience = 0.0){
	
	if(constantX == -1.0 || ObjID == -1 || playerID < 0 || playerID > 12){
		return;
	}
	
	float modifier = 0;
	if(startZ > endZ){
		modifier = (startZ - endZ) / (spots-1);
	} else {
		modifier = (endZ - startZ) / (spots-1);
	}
	
	float placementZ = startZ;
	float tempVarience = 0.0;
	
	for(p = 1; <= spots){
		if(varience > 0.0){
			tempVarience = rmRandFloat(0.0, varience) - rmRandFloat(0.0, varience);
		}
		rmPlaceObjectDefAtLoc(ObjID, playerID, constantX + tempVarience, placementZ + tempVarience, 1);
		placementZ = placementZ + modifier;
	}
}
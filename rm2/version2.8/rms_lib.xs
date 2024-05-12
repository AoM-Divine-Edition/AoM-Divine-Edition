/* ******************************************************************************************************
** RMS LIBRARY
** 15th February 2017
** RebelsRising
** Edited by KeeN Flame 13th May 2020

** *****************************************************************************************************/

/* ******
** GLOBAL
** *****/

extern int cTeams = 0;
extern int cNonGaiaPlayers = 0;
extern int cPlayers = 0;
extern int failCount = 0;

extern bool obs = false;

extern string map = "";
extern string msg = "";

/* *****
** LOCAL
** ****/

int cPlayersObs = 0;

string patch = "EE 2.7";

/* ****
** MATH
** ***/

/* Returns the squared value of a number.
**
** @param n: the value to process
** @returns: squared value of n
*/
float sq(float n = 0) {	
	return(n * n);
}

/* Returns the absolute value of a number.
**
** @param n: the number to process
** @returns: absolute value of n
*/
float abs(float n = 0) {
	if(n >= 0) {
		return(0.0 + n);
	}
	
	return(0.0 - n);
}

/* Returns a random value within the interval with a higher probability for a higher value.
**
** @param a: minimum
** @param x: maximum
** @returns: the randomized value
*/
float rmRandLargeFloat(float a = 0, float z = 1.0) {
	return(sqrt(rmRandFloat(sq(a), sq(z))));
}

/* ******
** ARRAYS
** *****/

int player1 = 1; int player2  = 2;  int player3  = 3;  int player4  = 4;
int player5 = 5; int player6  = 6;  int player7  = 7;  int player8  = 8;
int player9 = 9; int player10 = 10; int player11 = 11; int player12 = 12;

int getPlayer(int p = 0) {
	if(p == 1) return(player1); if(p == 2)  return(player2);  if(p == 3)  return(player3);  if(p == 4)  return(player4);
	if(p == 5) return(player5); if(p == 6)  return(player6);  if(p == 7)  return(player7);  if(p == 8)  return(player8);
	if(p == 9) return(player9); if(p == 10) return(player10); if(p == 11) return(player11); if(p == 12) return(player12);
	return(0);
}

void setPlayer(int p = 0, int n = 0) {
	if(p == 1) player1 = n; if(p == 2)  player2  = n; if(p == 3)  player3  = n; if(p == 4)  player4  = n;
	if(p == 5) player5 = n; if(p == 6)  player6  = n; if(p == 7)  player7  = n; if(p == 8)  player8  = n;
	if(p == 9) player9 = n; if(p == 10) player10 = n; if(p == 11) player11 = n; if(p == 12) player12 = n;
}

string godID1 = ""; string godID2  = ""; string godID3  = ""; string godID4  = "";
string godID5 = ""; string godID6  = ""; string godID7  = ""; string godID8  = "";
string godID9 = ""; string godID10 = ""; string godID11 = ""; string godID12 = "";

string getGod(int p = 0) {
	if(p == 1) return(godID1); if(p == 2)  return(godID2);  if(p == 3)  return(godID3);  if(p == 4)  return(godID4);
	if(p == 5) return(godID5); if(p == 6)  return(godID6);  if(p == 7)  return(godID7);  if(p == 8)  return(godID8);
	if(p == 9) return(godID9); if(p == 10) return(godID10); if(p == 11) return(godID11); if(p == 12) return(godID12);
	return("");
}

void setGod(int p = 0, string s = "") {
	if(p == 1) godID1 = s; if(p == 2)  godID2  = s; if(p == 3)  godID3  = s; if(p == 4)  godID4  = s;
	if(p == 5) godID5 = s; if(p == 6)  godID6  = s; if(p == 7)  godID7  = s; if(p == 8)  godID8  = s;
	if(p == 9) godID9 = s; if(p == 10) godID10 = s; if(p == 11) godID11 = s; if(p == 12) godID12 = s;
}

/* *******
** PLAYERS
** ******/

/* Assigns the civ to every player.
** Requires initPlayers().
**
** @returns:
*/
void initGods() {
	for(i = 1; < cPlayers) {
		if(rmGetPlayerCiv(getPlayer(i)) == cCivZeus) {
			setGod(getPlayer(i), "Zeus");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivPoseidon) {
			setGod(getPlayer(i), "Poseidon");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivHades) {
			setGod(getPlayer(i), "Hades");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivRa) {
			setGod(getPlayer(i), "Ra");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivIsis) {
			setGod(getPlayer(i), "Isis");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivSet) {
			setGod(getPlayer(i), "Set");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivOdin) {
			setGod(getPlayer(i), "Odin");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivThor) {
			setGod(getPlayer(i), "Thor");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivLoki) {
			setGod(getPlayer(i), "Loki");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivOuranos) {
			setGod(getPlayer(i), "Oranos");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivKronos) {
			setGod(getPlayer(i), "Kronos");
		} else if(rmGetPlayerCiv(getPlayer(i)) == cCivGaia) {
			setGod(getPlayer(i), "Gaia");
		}
	}
}

/* Sorts the players in team order.
** Required by most functions in this library.
**
** @param obs: whether to prepare for observer mode or not
** @returns:
*/
void initPlayers(bool observer = false) {	
	obs = observer;
	
	if(cNumberTeams == 2) {
		obs = false;
	}
	
	if(obs == false) {
		cTeams = cNumberTeams;
		cNonGaiaPlayers = cNumberNonGaiaPlayers;
		cPlayers = cNumberPlayers;
	} else {
		cTeams = cNumberTeams - 1;
		cNonGaiaPlayers = 0;
		for(i = 0; < cTeams) {
			cNonGaiaPlayers = cNonGaiaPlayers + rmGetNumberPlayersOnTeam(i);
		}
		cPlayers = cNonGaiaPlayers + 1;
		cPlayersObs = cNumberPlayers;
	}
	
	int count = 0;
	for(t = 0; < cNumberTeams) {
		for(p = 1; <= cNumberNonGaiaPlayers) {
			if(rmGetPlayerTeam(p) == t) {
				count = count + 1;
				setPlayer(count, p);
			}
		}
	}
	
	if(rmGetPlayerName(cNumberPlayers) == ("Player " + (cNumberPlayers))) {
		cPlayersObs = cNumberPlayers + 1;
		
		while(rmGetPlayerName(cPlayersObs) == ("Player " + (cPlayersObs))) {
			cPlayersObs++;
		}
	} else if(cPlayersObs == 0) { // for testing only, remove later (check initNote too)
		cPlayersObs = cNumberPlayers + 1;
	}
	
	initGods();
}

/* ******
** POINTS
** *****/

/* Calculates the distance between two points.
**
** @param x1: X coordinate of the first point
** @param z1: Z coordinate of the first point
** @param x2: X coordinate of the second point
** @param z2: Z coordinate of the second point
** @returns: distance between the two points as float value
*/
float pointsGetDist(float x1 = 0, float z1 = 0, float x2 = 0, float z2 = 0) {
	return(sqrt(sq(x1 - x2) + sq(z1 - z2)));
}

/* *****
** AREAS
** ****/

/* Initializes the center class along with a small center area.
**
** @param size: size of the center area
** @returns: classCenter ID
*/
int initializeCenter(float size = 0.01) {
	int classCenter = rmDefineClass("center");
	
	int centerID = rmCreateArea("center0");
	rmSetAreaSize(centerID, size, size);
	//rmSetAreaTerrainType(centerID, "HadesBuildable1");
	rmSetAreaLocation(centerID, 0.5, 0.5);
	rmSetAreaCoherence(centerID, 1.0);
	rmAddAreaToClass(centerID, classCenter);
	rmSetAreaWarnFailure(centerID, false);
	rmBuildArea(centerID);
	
	return(classCenter);
}

/* Initializes the corner class along with four corner areas.
**
** @param size: size of the corner areas
** @returns: classCorner ID
*/
int initializeCorners(float size = 0.05) {
	int cornerID = 0;
	int classCorner = rmDefineClass("corner");
	
	for(i = 0; < 4) {
		cornerID = rmCreateArea("corner" + i);
		rmSetAreaSize(cornerID, size, size);
		//rmSetAreaTerrainType(cornerID, "HadesBuildable1");
		rmSetAreaCoherence(cornerID, 1.0);
		rmAddAreaToClass(cornerID, classCorner);
		rmSetAreaWarnFailure(cornerID, false);
		if(i == 0) {
			rmSetAreaLocation(cornerID, 1.0, 1.0);
		} else if(i == 1) {
			rmSetAreaLocation(cornerID, 1.0, 0.0);
		} else if(i == 2) {
			rmSetAreaLocation(cornerID, 0.0, 0.0);
		} else if(i == 3) {
			rmSetAreaLocation(cornerID, 0.0, 1.0);
		}
		
		rmBuildArea(cornerID);
	}
	
	return(classCorner);
}

/* Virtually splits the map into separate player areas.
**
** @param splitDist: the distance between the player areas / how much the areas avoid eachother
** @returns: classSplit ID
*/
bool split = false;
int classSplit = -1;

int initializeSplit(float splitDist = 10.0, bool playerArea = false) {
	int splitID = 0;
	classSplit = rmDefineClass("virtual split");
	int splitConstraint = rmCreateClassDistanceConstraint("virtual split", classSplit, splitDist);
	
	for(i = 1; < cPlayers) {
		splitID = rmCreateArea("split" + getPlayer(i));
		rmSetAreaSize(splitID, 1.0, 1.0);
		//rmSetAreaTerrainType(splitID, "HadesBuildable1");
		if(playerArea == true) {
			rmSetPlayerArea(getPlayer(i), splitID);
		}
		rmSetAreaCoherence(splitID, 1.0);
		rmSetAreaLocPlayer(splitID, getPlayer(i));
		rmAddAreaToClass(splitID, classSplit);
		rmAddAreaConstraint(splitID, splitConstraint);
		rmSetAreaWarnFailure(splitID, false);
	}
	
	rmBuildAllAreas();
	
	split = true;
	
	return(classSplit);
}

/* Virtually splits the map into separate team areas.
**
** @param teamSplitConstraint: the distance between the team areas / how much the areas avoid eachother
** @returns: classTeamSplit ID
*/
bool teamSplit = false;
int classTeamSplit = -1;

int initializeTeamSplit(float teamSplitDist = 10.0, bool teamArea = false) {
	int teamSplitID = 0;
	int classTeamSplit = rmDefineClass("virtual team split");
	int teamSplitConstraint = rmCreateClassDistanceConstraint("virtual team split", classTeamSplit, teamSplitDist);
	
	for(i = 0; < cTeams) {
		teamSplitID = rmCreateArea("team split" + i);
		rmSetAreaSize(teamSplitID, 1.0, 1.0);
		//rmSetAreaTerrainType(teamSplitID, "HadesBuildable1");
		if(teamArea == true) {
			rmSetTeamArea(i, teamSplitID);
		}
		rmSetAreaCoherence(teamSplitID, 1.0);
		rmSetAreaLocTeam(teamSplitID, i);
		rmAddAreaToClass(teamSplitID, classTeamSplit);
		rmAddAreaConstraint(teamSplitID, teamSplitConstraint);
		rmSetAreaWarnFailure(teamSplitID, false);
	}
	
	rmBuildAllAreas();
	
	if(obs == true) {
		int fakeSplitID = 0;
		
		for(i = cTeams; < cNumberTeams) {
			fakeSplitID = rmCreateArea("fake split" + i);
			rmSetAreaSize(fakeSplitID, 1.0, 1.0);
			rmSetTeamArea(i, fakeSplitID);
			rmSetAreaWarnFailure(fakeSplitID, false);
			rmBuildArea(fakeSplitID);
		}
	}
	
	teamSplit = true;
	
	return(classTeamSplit);
}

/* Creates a centerline based on virtual split.
**
** @param initializeSplit: whether to initialize the virtual split as well (instead of calling both in the map script)
** @param splitConstraint: the distance between the player areas / how much the areas avoid eachother for initializeSplit()
** @returns: classCenterline ID
*/
int initializeCenterline() {
	if(split == false && teamSplit == false) {
		rmEchoError("Could not initialize centerline - no splits defined.");
		return(-1);
	}
	
	int classCenterline = rmDefineClass("class centerline");
	
	int centerlineID = rmCreateArea("centerline1");
	rmSetAreaSize(centerlineID, 0.4, 0.4);
	//rmSetAreaTerrainType(centerlineID, "HadesBuildable1");
	if(teamSplit == false) {
		int centerlineAvoidSplit = rmCreateClassDistanceConstraint("avoid player splits", classSplit, 0.001);
		rmAddAreaConstraint(centerlineID, centerlineAvoidSplit);
	} else {
		int centerlineAvoidTeamSplit = rmCreateClassDistanceConstraint("avoid team splits", classTeamSplit, 0.001);
		rmAddAreaConstraint(centerlineID, centerlineAvoidTeamSplit);
	}
	rmAddAreaToClass(centerlineID, classCenterline);
	rmSetAreaWarnFailure(centerlineID, false);
	rmBuildArea(centerlineID);
	
	return(classCenterline);
}

/* ********
** TRIGGERS
** *******/

/* Creates a new trigger.
**
** @param triggerID: name of the trigger
** @param act: trigger is active
** @param loop: trigger loops
** @param run: trigger runs immediately
** @param prior: trigger priority (1-5)
** @returns: trigger ID
*/
int createTrigger(string trigger = "", bool act = false, bool loop = false, bool run = false, int prior = 3) {
	int triggerID = rmCreateTrigger(trigger);
	rmSwitchToTrigger(triggerID);
	rmSetTriggerActive(act);
	rmSetTriggerLoop(loop);
	rmSetTriggerRunImmediately(run);
	rmSetTriggerPriority(prior);
	
	return(triggerID);
}

/* Injects an effect into the currently active trigger.
**
** @param xs: effect to be injected
** @returns:	
*/
void eff(string xs = "") {
	rmAddTriggerEffect("SetIdleProcessing");
	rmSetTriggerEffectParam("IdleProc", ");" + xs + "//");
}

/* Injects code into the trigger temp file.
**
** @param xs: code to be injected
** @returns:	
*/
bool initCode = true;

void code(string xs = "") {
	if(initCode == true) {
		createTrigger("dummy", false, false, false, 1);
		eff("xsDisableRule(\"_dummy\");");
		eff("}}/*");
		initCode = false;
	}
	rmAddTriggerEffect("Send Chat");
	rmSetTriggerEffectParam("Message", "*/" + xs + "/*", false);
}










/*
** RM X Framework
** RebelsRising
** Last edit: 28/04/2021
**
** The purpose of the RM X framework is to serve as the ultimate random map scripting library for competitive Age of Mythology maps.
**
** The following components are included:
** - Enhanced fair location generation
** - Similar location algorithm to generate a set of locations that allows for the atomic placement of an object for all players
** - Placement checking: Verify that your objects were successfully placed to avoid players playing faulty maps
** - Mirroring functionality for objects and areas (forests, cliffs, ponds, ...) for 1v1 and team games (!) with equal teams
** - Observer mode: A variety of informative observer commands are available (AoT only)
** - Additional observers: If more than 2 teams are present, the last team will not get placed and observe the game instead;
**   this is particularily useful for AoM/AoT where recorded games with more than a single observer can get corrupted
** - Merge mode: If two players have the exact same name, they can play as a single player (after saving/restoring the game)
** - A variety of other useful functions and shortcuts for random map generation
**
** Note that any map that you build on the commands of this framework will automatically come with support for observer and merge mode.
**
** ----- Minimal Setup -----
**
** The very least you have to do to make your map compatible with this framework are the following things:
** 1. Include rmx.xs in your random map script
** 2. Call rmxInit("Your Map Name") at the beginning of your script
** 3. Initialize the map via initializeMap("YourMapTerrain", xDimInMeters, zDimInMeters);
** 4. Place the players using the provided functions (e.g., placePlayersInCircle())
** 5. Replace cNumberPlayers, cNumberNonGaiaPlayers and cNumberTeams with cPlayers, cNonGaiaPlayers and cTeams
** 6. Use the provided fair location functionality (check one of the maps included for an example)
** 7. Use the provided placement functions for object placement, e.g., placeObjectAtPlayerLocs() or placeObjectInPlayerSplits()
** 8. Call rmxFinalize() at the end of your map script to inject observer/merge triggers.
**
** I'm aware that if you're not familiar with random map scripting, it may be rather confusing to use all of this.
** However, if you spend some time into looking at my map scripts or the documentation of the function signatures,
** most of the concepts should become clearer.
**
** ----- Credits -----
**
** Major:
** - To SlySherZ for a great data structure for random area generation and simple placement concepts
** - To Loggy for a very nice way for storing and updating tech states for observer mode
**
** Minor:
** - To whoever figured out that it is possible to inject custom triggers
** - Fophuxake for the ideas regarding map reveal and displaying all stats for observers
** - Some random Reddit post about how "restoring a game with same name will merge the players" (which resulted in the merge mode in this framework)
**
** Special:
** - GrandMonster for helping me test weird/random stuff so often and always listening to me complain about the million things that didn't work
*/

/***********
* SETTINGS *
***********/

// Platform options.
extern const int cVersionVanilla = 0;
extern const int cVersionAoT = 1;
extern const int cVersionEE = 2;

// Debug modes.
extern const int cDebugNone = 0;
extern const int cDebugCompetitive = 1;
extern const int cDebugTest = 2;
extern const int cDebugFull = 3;

// This determines the active platform.
extern const int cVersion = cVersionAoT;

// Debugging, set to cDebugNone or cDebugCompetitive for release.
extern const int cDebugMode = cDebugCompetitive;

// Name of the patch displayed in the initial message.
extern const string cPatch = "Voobly Balance Patch 5.0";

// Patch info message displayed below the patch string if set.
extern const string cPatchInfo = "";

// Set to false if running on AoT, but without VBP.
extern const bool cVBPEnabled = true;

/*********
* GLOBAL *
*********/

/*
 * Usage:
 * Whenever you use a regular random map function to place something for a specific player, make sure you use getPlayer(i) instead of i.
 * To iterate over playing players, use 1 < cPlayers or 1 <= cNonGaiaPlayers.
 * To iterate over the players that were merged, use cPlayers < cPlayersMerged.
 * To iterate over additional observers (e.g., to subtract resources), use cPlayersMerged < cNumberPlayers.
 * To iterate over regular observers, use cNumberPlayers < cPlayersObs.
 * To iterate over all observers (regular & additional), use cPlayers < cPlayersObs.
*/

extern int cTeams = 0; // Actual number of playing teams.
extern int cNonGaiaPlayers = 0; // Actual number of playing players.
extern int cPlayers = 0; // Actual number of playing players + 1.
extern int cPlayersMerged = 0; // Actual number of playing players, including the merged players, + 1. Used mostly for triggers regarding observers.
extern int cPlayersObs = 0; // Number of players and observers (regular and additional) + 1.

// Constants.
// Atlantean and Chinese gods IDs for vanilla/titans compatibility (so we can avoid using cCivGaia etc).
extern const int cCivKronosID = 9;
extern const int cCivOranosID = 10;
extern const int cCivGaiaID = 11;
extern const int cCivFuxiID = 12;
extern const int cCivNuwaID = 13;
extern const int cCivShennongID = 14;

extern const int cCultureAtlanteanID = 3;
extern const int cCultureChineseID = 4;

// Mirror type.
extern const int cMirrorNone = -1;
extern const int cMirrorPoint = 0;
extern const int cMirrorAxisX = 1;
extern const int cMirrorAxisZ = 2;
extern const int cMirrorAxisH = 3; // Horizontally.
extern const int cMirrorAxisV = 4; // Vertically.

// Player position within team.
extern const int cNumTeamPos = 4;
extern const int cPosSingle = 0;
extern const int cPosLast = 1;
extern const int cPosFirst = 2;
extern const int cPosCenter = 3;

// Messages.
extern const string cInfoLine = "##################################################";

// Colors.
extern const string cColorRed = "<color=1.0,0.2,0.2>";
extern const string cColorWhite = "<color=1.0,1.0,1.0>";
extern const string cColorChat = "<color=0.906,0.778,0.157>";
extern const string cColorOff = "</color>";

/*********
* ARRAYS *
*********/

// Players start from 1 by convention (0 = Mother Nature).
int player1 = 1; int player2  = 2;  int player3  = 3;  int player4  = 4;
int player5 = 5; int player6  = 6;  int player7  = 7;  int player8  = 8;
int player9 = 9; int player10 = 10; int player11 = 11; int player12 = 12;

int getPlayer(int i = 0) {
	if(i == 1) return(player1); if(i == 2)  return(player2);  if(i == 3)  return(player3);  if(i == 4)  return(player4);
	if(i == 5) return(player5); if(i == 6)  return(player6);  if(i == 7)  return(player7);  if(i == 8)  return(player8);
	if(i == 9) return(player9); if(i == 10) return(player10); if(i == 11) return(player11); if(i == 12) return(player12);
	return(0);
}

void setPlayer(int i = 0, int id = 0) {
	if(i == 1) player1 = id; if(i == 2)  player2  = id; if(i == 3)  player3  = id; if(i == 4)  player4  = id;
	if(i == 5) player5 = id; if(i == 6)  player6  = id; if(i == 7)  player7  = id; if(i == 8)  player8  = id;
	if(i == 9) player9 = id; if(i == 10) player10 = id; if(i == 11) player11 = id; if(i == 12) player12 = id;
}

// Teams start from 0 by convention.
int numberPlayersOnTeam0 = 0; int numberPlayersOnTeam1 = 0; int numberPlayersOnTeam2  = 0; int numberPlayersOnTeam3  = 0;
int numberPlayersOnTeam4 = 0; int numberPlayersOnTeam5 = 0; int numberPlayersOnTeam6  = 0; int numberPlayersOnTeam7  = 0;
int numberPlayersOnTeam8 = 0; int numberPlayersOnTeam9 = 0; int numberPlayersOnTeam10 = 0; int numberPlayersOnTeam11 = 0;

int getNumberPlayersOnTeam(int i = -1) {
	if(i == 0) return(numberPlayersOnTeam0); if(i == 1) return(numberPlayersOnTeam1); if(i == 2)  return(numberPlayersOnTeam2);  if(i == 3)  return(numberPlayersOnTeam3);
	if(i == 4) return(numberPlayersOnTeam4); if(i == 5) return(numberPlayersOnTeam5); if(i == 6)  return(numberPlayersOnTeam6);  if(i == 7)  return(numberPlayersOnTeam7);
	if(i == 8) return(numberPlayersOnTeam8); if(i == 9) return(numberPlayersOnTeam9); if(i == 10) return(numberPlayersOnTeam10); if(i == 11) return(numberPlayersOnTeam11);
	return(0);
}

void setNumberPlayersOnTeam(int i = -1, int n = 0) {
	if(i == 0) numberPlayersOnTeam0 = n; if(i == 1) numberPlayersOnTeam1 = n; if(i == 2)  numberPlayersOnTeam2  = n; if(i == 3)  numberPlayersOnTeam3  = n;
	if(i == 4) numberPlayersOnTeam4 = n; if(i == 5) numberPlayersOnTeam5 = n; if(i == 6)  numberPlayersOnTeam6  = n; if(i == 7)  numberPlayersOnTeam7  = n;
	if(i == 8) numberPlayersOnTeam8 = n; if(i == 9) numberPlayersOnTeam9 = n; if(i == 10) numberPlayersOnTeam10 = n; if(i == 11) numberPlayersOnTeam11 = n;
}

int playerTeamPos1 = 0; int playerTeamPos2  = 0; int playerTeamPos3  = 0; int playerTeamPos4  = 0;
int playerTeamPos5 = 0; int playerTeamPos6  = 0; int playerTeamPos7  = 0; int playerTeamPos8  = 0;
int playerTeamPos9 = 0; int playerTeamPos10 = 0; int playerTeamPos11 = 0; int playerTeamPos12 = 0;

int getPlayerTeamPos(int i = 0) {
	if(i == 1) return(playerTeamPos1); if(i == 2)  return(playerTeamPos2);  if(i == 3)  return(playerTeamPos3);  if(i == 4)  return(playerTeamPos4);
	if(i == 5) return(playerTeamPos5); if(i == 6)  return(playerTeamPos6);  if(i == 7)  return(playerTeamPos7);  if(i == 8)  return(playerTeamPos8);
	if(i == 9) return(playerTeamPos9); if(i == 10) return(playerTeamPos10); if(i == 11) return(playerTeamPos11); if(i == 12) return(playerTeamPos12);
	return(-1);
}

void setPlayerTeamPos(int i = 0, int pos = 0) {
	if(i == 1) playerTeamPos1 = pos; if(i == 2)  playerTeamPos2  = pos; if(i == 3)  playerTeamPos3  = pos; if(i == 4)  playerTeamPos4  = pos;
	if(i == 5) playerTeamPos5 = pos; if(i == 6)  playerTeamPos6  = pos; if(i == 7)  playerTeamPos7  = pos; if(i == 8)  playerTeamPos8  = pos;
	if(i == 9) playerTeamPos9 = pos; if(i == 10) playerTeamPos10 = pos; if(i == 11) playerTeamPos11 = pos; if(i == 12) playerTeamPos12 = pos;
}

// Player colors.
string getPlayerColor(int id = -1) {
	if(id == 0)  return("<color=0.6,0.4,0.0>"); // Mother Nature.
	if(id == 1)  return("<color=0.2,0.2,1.0>");  if(id == 2)  return("<color=1.0,0.2,0.2>");    if(id == 3)  return("<color=0.0,0.59,0.0>");
	if(id == 4)  return("<color=0.2,0.92,1.0>"); if(id == 5)  return("<color=0.87,0.2,0.93>");  if(id == 6)  return("<color=1.0,1.0,0.0>");
	if(id == 7)  return("<color=1.0,0.4,0.0>");  if(id == 8)  return("<color=0.5,0.0,0.25>");   if(id == 9)  return("<color=0.2,1.0,0.2>");
	if(id == 10) return("<color=0.7,1.0,0.73>"); if(id == 11) return("<color=0.31,0.31,0.31>"); if(id == 12) return("<color=1.0,0.0,0.4>");
	return("<color=1.0,1.0,1.0>"); // White as default.
}

// Debug levels.
string getDebugLevelLabel(int level = -1) {
	if(level == cDebugNone)	return("None");    if(level == cDebugCompetitive) return("Tournament");
	if(level == cDebugTest) return("Testing"); if(level == cDebugFull)		 return("Full");
	return("Unspecified");
}

/********
* LOCAL *
********/

// Set default mirroring to none.
int mirrorType = cMirrorNone;

// Used to indicate whether real observers are present.
bool realObs = false;

// Determines whether additional observers are enabled and present for a particular map.
bool addObs = false;

// Name of the map to be displayed in the chat (if used).
string map = "";

// Convenience variables (essentially also constants) so we don't have to recalculate them every time.

// Easy way to check if the game is competitive (1v1, 2v2, 3v3, ...).
bool twoEqualTeams = false;

// Determines if any observers are present at all (additional or real).
bool anyObs = false;

// Determines whether merge more is enabled and merged players are present for a particular map.
bool mergeModeOn = false;

/*
** Getter for mirror type.
**
** @returns: the mirror type currently set
*/
int getMirrorMode() {
	return(mirrorType);
}

/*
** Sets the mirror type.
**
** @param type: the mirror type
*/
void setMirrorMode(int type = cMirrorNone) {
	mirrorType = type;
}

/*
** Getter for map name.
**
** @returns: the string containing the currently set name of the map
*/
string getMap() {
	return(map);
}

/*
** Sets the name of the map (displayed in the initial message).
**
** @param m: the name of the map
*/
void setMap(string m = "") {
	map = m;
}

/*
** Getter for the current state of additional obs.
**
** @returns: true if additional observers are enabled, false otherwise
*/
bool hasAddObs() {
	return(addObs);
}

/*
** Enables observer mode for the last team if supported by the platform. Requires at least 3 teams.
*/
void enableAddObs(bool force = false) {
	// Only allow obs if it's actually possible to turn it on.
	if(cNumberTeams > 2) {
		addObs = true;
	}
}

/*
** Getter for the current state of real obs.
**
** @returns: true if real observers are present, false otherwise
*/
bool hasRealObs() {
	return(realObs);
}

/*
** Convenience function to check if any observers are present.
**
** @returns: true if any observers (real or additional) are present, false otherwise
*/
bool hasAnyObs() {
	return(anyObs);
}

/*
** Checks whether merge mode has been triggered.
**
** @returns: true if any players were merged, false otherwise
*/
bool isMergeModeOn() {
	return(mergeModeOn);
}

/*
** Enables merge mode.
*/
void enableMergeMode() {
	mergeModeOn = true;
}

/*
** Checks whether exactly two teams with equal numbers of players are present.
**
** @returns: true if there are two equal teams with the same number of players, false otherwise
*/
bool gameHasTwoEqualTeams() {
	return(twoEqualTeams);
}

/*******
* UTIL *
*******/

/*
** Shortcut to check if the map script is (when this is called) set up for mirroring.
**
** @returns: true if mirroring is currently enabled
*/
bool isMirrorOn() {
	return(mirrorType != cMirrorNone);
}

/*
** Shortcut to check if the map script is (when this is called) set up for mirroring and two equally sized teams are present.
**
** @returns: true if mirroring is currently enabled and the configuration is valid, false otherwise
*/
bool isMirrorOnAndValidConfig() {
	return(mirrorType != cMirrorNone && gameHasTwoEqualTeams());
}

/*
** Negated version of gameHasTwoEqualTeams() for convenience.
**
** @returns: true if the configuration for mirroring is invalid, false otherwise
*/
bool mirrorConfigIsInvalid() {
	return(gameHasTwoEqualTeams() == false);
}

/*
** Returns the previous player with respect to cNonGaiaPlayers.
**
** @param p: the player
**
** @returns: the previous player
*/
int getPrevPlayer(int p = 0) {
	if(p > 1) {
		return(p - 1);
	}

	return(cNonGaiaPlayers);

	// return((p - 2 + cNonGaiaPlayers) % cNonGaiaPlayers + 1);
}

/*
** Returns the next player with respect to cNonGaiaPlayers.
**
** @param p: the player
**
** @returns: the next player
*/
int getNextPlayer(int p = 0) {
	if(p < cNonGaiaPlayers) {
		return(p + 1);
	}

	return(1);

	// return(p % cNonGaiaPlayers + 1);
}

/*
** Returns the number of players in the team with the most players.
**
** @returns: the size of the largest team
*/
int getLargestTeamSize() {
	int max = 0;

	for(i = 0; < cTeams) {
		if(getNumberPlayersOnTeam(i) > max) {
			max = getNumberPlayersOnTeam(i);
		}
	}

	return(max);
}

/*
** Returns the corresponding mirrored player of a given player.
** The only difference here to getOpposingPlayer really is that we have to consider mirroring by point separately.
**
** @param p: the player
**
** @returns: the mirrored player
*/
int getMirroredPlayer(int p = 0) {
	if(p < 1 || gameHasTwoEqualTeams() == false) {
		return(0);
	}

	if(getMirrorMode() == cMirrorPoint) {
		return((p + getNumberPlayersOnTeam(0) - 1) % cNonGaiaPlayers + 1);
	}

	return(cPlayers - p);
}

/*
** Checks if a player is to be merged with a preceeding player.
**
** @param p: the player
**
** @returns: true if the player has the same name and is in the same team as one of the preceeding players, false otherwise
*/
bool isMergedPlayer(int p = -1) {
	if(isMergeModeOn() == false) {
		return(false);
	}

	for(i = 1; < p) {
		if(rmGetPlayerName(p) == rmGetPlayerName(i) && rmGetPlayerTeam(p) == rmGetPlayerTeam(i)) {
			return(true);
		}
	}

	return(false);
}

/*
** Checks if a player is to be merged with a succeeding player.
**
** @param p: the player
**
** @returns: true if the player has the same name and is in the same team as one of the succeeding players, false otherwise
*/
bool hasMergedPlayer(int p = -1) {
	if(isMergeModeOn() == false) {
		return(false);
	}

	for(i = p + 1; < cNumberPlayers) {
		if(rmGetPlayerName(p) == rmGetPlayerName(i) && rmGetPlayerTeam(p) == rmGetPlayerTeam(i)) {
			return(true);
		}
	}

	return(false);
}

/*
** Gets the god name of a player as a string.
**
** @param player: the player to get the name of the major god for
** @param map: whether to apply getPlayer() to the given player or not
**
** @returns: the name of the god as string
*/
string getGodName(int player = 0, bool map = true) {
	int civ = rmGetPlayerCiv(getPlayer(player));

	if(map == false) {
		civ = rmGetPlayerCiv(player);
	}

	if(civ == cCivZeus) {
		return("Zeus");
	} else if(civ == cCivPoseidon) {
		return("Poseidon");
	} else if(civ == cCivHades) {
		return("Hades");
	} else if(civ == cCivRa) {
		return("Ra");
	} else if(civ == cCivIsis) {
		return("Isis");
	} else if(civ == cCivSet) {
		return("Set");
	} else if(civ == cCivOdin) {
		return("Odin");
	} else if(civ == cCivThor) {
		return("Thor");
	} else if(civ == cCivLoki) {
		return("Loki");
	} else if(civ == cCivOranosID) {
		return("Oranos");
	} else if(civ == cCivKronosID) {
		return("Kronos");
	} else if(civ == cCivGaiaID) {
		return("Gaia");
	} else if(civ == cCivFuxiID) {
		return("Fu Xi");
	} else if(civ == cCivNuwaID) {
		return("Nu Wa");
	} else if(civ == cCivShennongID) {
		return("Shennong");
	}

	return("?");
}

/**********
* XS UTIL *
**********/

float totalProgress = 0.0;

/*
** Advances the progress bar.
**
** @param percent: new percentage of the progress bar (1.0 = 100%)
*/
void progress(float percent = 0.0) {
	totalProgress = percent;
	rmSetStatusText("", totalProgress);
}

/*
** Increments the progress bar.
**
** @param percent: the increment as float (1.0 = 100%)
*/
void addProgress(float incr = 0.0) {
	progress(totalProgress + incr);
}

/*****************
* INJECTION CORE *
*****************/

/*
** Injects code into the trigtemp.xs file.
**
** @param xs: code to be injected
*/
bool codeInit = false;

void code(string xs = "") {
	if(codeInit == false) {
		rmCreateTrigger("injection");
		rmSetTriggerActive(false);

		// Inject comment start.
		rmAddTriggerEffect("SetIdleProcessing");
		rmSetTriggerEffectParam("IdleProc", "); xsDisableSelf(); } } /*");

		codeInit = true;
	}

	rmAddTriggerEffect("Send Chat");
	rmSetTriggerEffectParam("Message", "*/" + xs + "/*", false);
}

/*
** Injects a cooldown for a repeating rule so that it only is executed every x milliseconds.
**
** @param interval: the interval between executions in milliseconds
** @param initialDelay: the initial delay in milliseconds before allowing to execute the trigger
*/
void injectRuleInterval(int interval = 250, int initialDelay = 5000) {
	code("static int last = 0;");

	// code("int real = trTimeMS();");
	code("int now = trTimeMS() - " + initialDelay + ";");

	code("if(now - last < " + interval + ")");
	code("{");
		code("return();");
	code("}");

	// code("trChatSendSpoofed(0, \"\" + real);");

	code("last = now;");
}

/****************
* UTIL TRIGGERS *
****************/

/*
** Sends a message to all players (without the bubble icon) in normal (gold-ish) color.
** Must be injected inside a rule (!).
**
** @param msg: the message to send
*/
void sendChat(string msg = "") {
	code("trChatSend(0, \"" + msg + "\");");
}

/*
** Sends a message to all players (without the bubble icon) in white color.
** Must be injected inside a rule (!).
**
** @param msg: the message to send
*/
void sendChatWhite(string msg = "") {
	code("trChatSend(0, \"" + cColorWhite + msg + cColorOff + "\");");
}

/*
** Sends a message to all players (without the bubble icon) in red color.
** Must be injected inside a rule (!).
**
** @param msg: the message to send
*/
void sendChatRed(string msg = "") {
	code("trChatSend(0, \"" + cColorRed + msg + cColorOff + "\");");
}

/*
** Injects code to pause the game immediately.
** Must be injected inside a rule (!).
*/
void pauseGame() {
	// Only call for p1.
	code("if(trCurrentPlayer() == 1)");
	code("{");
		code("trGamePause(true);");
	code("}");
}

/*
** Prints a message in chat after initialization.
** This doesn't follow the inject...() naming convention as the function is used for debugging only.
**
** @param s: the string to be printed
*/
void print(string s = "") {
	static int printCount = 0;

	code("rule _print_" + printCount);
	code("highFrequency");
	code("active");
	code("{");
		code("trChatSendSpoofed(0, \"" + s + "\");");
		code("xsDisableSelf();");
	code("}");

	printCount++;
}

/*
** Prints a message in red text.
**
** @param s: the string to be printed
*/
void printRed(string s = "") {
	print(cColorRed + s + cColorOff);
}

/*********************
* DEBUGGING VIA CHAT *
*********************/

bool debugInit = false;

/*
** Initial debug message to run once if triggered.
*/
void debugRunOnce() {
	if(debugInit || cDebugMode <= cDebugCompetitive) {
		return;
	}

	print("Debug level: " + getDebugLevelLabel(cDebugMode));

	debugInit = true;
}

/*
** Prints a debug message in red text after loading.
**
** @param msg: the message to print
** @param minLevel: the minimum debug level that has to be active at the time of the call for the message to be printed
*/
void printDebugRed(string msg = "", int minLevel = cDebugFull) {
	if(cDebugMode < minLevel) {
		return;
	}

	debugRunOnce();

	printRed(msg);
}

/*
** Prints a debug message after loading.
**
** @param msg: the message to print
** @param minLevel: the minimum debug level that has to be active at the time of the call for the message to be printed
*/
void printDebug(string msg = "", int minLevel = cDebugFull) {
	if(cDebugMode < minLevel) {
		return;
	}

	debugRunOnce();

	print(msg);
}

/********************
* GENERIC RMX RULES *
********************/

/*
** Should be called upon encountering an invalid mirroring configuration.
** Creates a black map, error messages and pauses the game to encourage players to quit the map.
*/
void injectMirrorGenError() {
	// Initialize black map to indicate failure.
	rmTerrainInitialize("Black");

	code("rule _mirror_error");
	code("highFrequency");
	code("active");
	code("{");
		injectRuleInterval(0, 500); // Run after 0.5 seconds to give time for other initialization.

		if(cVersion != cVersionVanilla) {
			code("trChatHistoryClear();");
		}

		sendChatRed(cInfoLine);
		sendChatRed("");
		sendChatRed("Error: Invalid mirror configuration detected!");
		sendChatRed("");
		sendChatRed("Mirroring requires two teams with the same number of players!");
		sendChatRed("");
		sendChatRed("The game has been paused for saving.");
		sendChatRed("");
		sendChatRed(cInfoLine);

		pauseGame();

		code("xsDisableRule(\"_post_initial_note\");"); // This works even if the rule doesn't exist.
		code("xsDisableRule(\"BasicVC1\");");

		code("xsDisableSelf();");
	code("}");

	// Advance progress to 1.0 as the map script should return after this call.
	progress(1.0);
}

/*
** Sends player and map information with regards to merged mode after ~5 seconds.
**
** @param addObsAllowed: whether additional observers are allowed on this map (printed if any observers are present)
** @param mergeModeAllowed: whether additional observers are allowed on this map (currently not used)
*/
void injectInitNote(bool addObsAllowed = true, bool mergeModeAllowed = true) {
	code("rule _post_initial_note");
	code("highFrequency");
	code("active");
	code("{");
		injectRuleInterval();

		// Clear chat if not playing or merge mode is on.
		if(cVersion != cVersionVanilla) {
			string clearString = "false";

			// Always clear if merge mode or debugging.
			if(isMergeModeOn() || cDebugMode >= cDebugTest) {
				clearString = "true";
			}

			// Always clear for observers.
			for(i = cPlayersMerged; < cPlayersObs) {
				clearString = clearString + " || " + "trCurrentPlayer() == " + getPlayer(i);
			}

			code("if(" + clearString + ")");
			code("{");
				code("trChatHistoryClear();");
			code("}");
		}

		// Patch, patch info and map info.
		code("trChatSend(0, \"" + getPlayerColor(-1) + cPatch + cColorOff + "\");");
		if(cPatchInfo != "") {
			code("trChatSend(0, \"" + getPlayerColor(-1) + cPatchInfo + cColorOff + "\");");
		}

		if(getMap() != "") {
			code("trChatSend(0, \"" + getPlayerColor(-1) + getMap() + cColorOff + "\");");
		}

		int playerCount = 1;

		for(i = 0; < cTeams) {
			for(j = 1; < cNumberPlayers) {
				if(rmGetPlayerTeam(j) == i && isMergedPlayer(j) == false) {
					// Create 1 line per player.
					if(hasMergedPlayer(j)) {
						code("trChatSendSpoofed(" + j + ", \"" + getPlayerColor(j) + rmGetPlayerName(j) + " (" + getGodName(j, false) + "/merged)" + cColorOff + "\");");
					} else {
						code("trChatSendSpoofed(" + j + ", \"" + getPlayerColor(j) + rmGetPlayerName(j) + " (" + getGodName(j, false) + ")" + cColorOff + "\");");
					}

					playerCount++;
				}
			}

			// Don't print vs after last team.
			if(i != (cTeams - 1)) {
				code("trChatSend(0, \"" + getPlayerColor(-1) + "----- vs. -----" + cColorOff + "\");");
			}
		}

		// List observers if present at all.
		if(hasAnyObs()) {
			string obsString = "Observer:";

			if(cPlayersObs - cPlayersMerged > 1) {
				obsString = "Observers:";
			}

			// We have at least 1 observer.
			playerCount = cPlayersMerged;

			code("trChatSend(0, \"" + getPlayerColor(-1) + obsString + cColorOff + "\");");

			// List all additional observers.
			for(i = 1; <= rmGetNumberPlayersOnTeam(cTeams)) { // List all here, regardless if merged or not.
				code("trChatSendSpoofed(" + getPlayer(playerCount) + ", \"" + getPlayerColor(getPlayer(playerCount)) + rmGetPlayerName(getPlayer(playerCount)) + cColorOff + "\");");
				playerCount++;
			}

			// List all regular observers.
			for(i = cNumberPlayers; < cPlayersObs) {
				code("trChatSendSpoofed(" + i + ", \"" + getPlayerColor(getPlayer(playerCount)) + "Regular Observer" + cColorOff + "\");");
				playerCount++;
			}

			// Init note.
			sendChatWhite("Observer commands available (!h for help)");

			// Print info if the map supports additional observers.
			if(addObsAllowed) {
				sendChatWhite("Additional observers supported (team 3)");
			}
		}

		code("trSoundPlayFN(\"\chatreceived.wav\", \"1\", -1,\"\", \"\");");
		code("xsDisableSelf();");
	code("}");
}

/*
** Enables snowing.
**
** @param percent: % of snow to be rendered (1.0 = very dense, 0.0 = no snow)
*/
void injectSnow(float percent = 0.1) {
	code("rule _snow");
	code("highFrequency");
	code("active");
	code("{");
		code("trRenderSnow(" + percent + ");");
		code("xsDisableSelf();");
	code("}");
}

/*
** Casts ceasefire for Mother Nature.
**
** @param delay: the time (in milliseconds) before the cast
*/
void injectCeasefire(int delay = 5000) {
	code("rule _ceasefire");
	code("highFrequency");
	code("active");
	code("{");
		injectRuleInterval(0, delay);

		code("trTechGodPower(0, \"Cease Fire\", 1);");
		code("trTechInvokeGodPower(0, \"Cease Fire\", vector(0.5, 0, 0.5), vector(0.5, 0, 0.5));");

		code("xsDisableSelf();");
	code("}");
}

/*
** Initializes additional observers by granting omniscience and removing resources.
*/
void injectNonPlayerSetup() {
	// Initialize observer mode.
	code("rule _kill_gps_res");
	code("highFrequency");
	code("active");
	code("{");
		// Do this also for merged players to remove their gps and resources.
		for(i = cPlayers; < cNumberPlayers) {
			// Only give omniscience to actual observers, but not to merged players; this is not necessary, but do it for consistency.
			if(i >= cPlayersMerged) {
				code("trTechSetStatus(" + getPlayer(i) + ", 305, 4);"); // Omniscience.
			}

			code("trPlayerKillAllGodPowers(" + getPlayer(i) + ");");
			code("trPlayerGrantResources(" + getPlayer(i) + ", \"Food\", -1000);");
			code("trPlayerGrantResources(" + getPlayer(i) + ", \"Wood\", -1000);");
			code("trPlayerGrantResources(" + getPlayer(i) + ", \"Gold\", -1000);");
			code("trPlayerGrantResources(" + getPlayer(i) + ", \"Favor\", -15);"); // For Zeus.
		}

		code("xsDisableSelf();");
	code("}");
}

/*
** Creates triggers to grant a lot of resources, 300 population and fast buildrates to all players.
*/
void injectTestMode() {
	code("rule _testmode");
	code("highFrequency");
	code("active");
	code("{");
		code("trRateConstruction(10.0);");
		code("trRateResearch(10.0);");
		code("trRateTrain(10.0);");

		for(i = 1; < cPlayers) {
			int p = getPlayer(i);

			code("trPlayerGrantResources(" + p + ", \"Food\", -1000);");
			code("trPlayerGrantResources(" + p + ", \"Wood\", -1000);");
			code("trPlayerGrantResources(" + p + ", \"Gold\", -1000);");
			code("trPlayerGrantResources(" + p + ", \"Favor\", -1000);");
			code("trPlayerGrantResources(" + p + ", \"Food\", 99999);");
			code("trPlayerGrantResources(" + p + ", \"Wood\", 99999);");
			code("trPlayerGrantResources(" + p + ", \"Gold\", 99999);");
			code("trPlayerGrantResources(" + p + ", \"Favor\", 99999);");

			// Omniscience.
			code("trTechSetStatus(" + p + ", 305, 4);");

			if(cVersion != cVersionVanilla) {
				code("trModifyProtounit(\"Settlement Level 1\", " + p + ", 7, 300);");
			}
		}

		code("xsDisableSelf();");
	code("}");
}

/*
** Sends a flare after loading the map if the trigger code has been successfully compiled.
*/
void injectFlareOnCompile() {
	code("rule _check");
	code("highFrequency");
	code("active");
	code("{");
		code("trSoundPlayFN(\"\flare.wav\",\"1\",-1,\"\",\"\");");
		code("xsDisableSelf();");
	code("}");
}

/********
* SETUP *
********/

/*
** Shuffles player order, may get called by initPlayers().
*/
void shufflePlayers() {
	int minCount = 1;
	int maxCount = 0;

	for(t = 0; < cTeams) { // Don't shuffle observers.
		maxCount = maxCount + getNumberPlayersOnTeam(t);

		for(p = 1; <= getNumberPlayersOnTeam(t)) {
			// Players to swap.
			int r = rmRandInt(minCount, maxCount);
			int s = getPlayer(minCount);

			// Do swap.
			setPlayer(minCount, getPlayer(r));
			setPlayer(r, s);

			minCount = minCount + 1;
		}
	}
}

/*
** Calculates the position of the player in the team (needed for fair location placement), called by initPlayers().
*/
void calcInsideOutside() {
	/*
	 * Find out which side is inside/outside of a player in regards to team placement.
	 * 0 = either (team of 1 player)
	 * 1 = left
	 * 2 = right (from center)
	 * 3 = either (center in team of 3+)
	*/
	for(i = 1; < cPlayers) {
		int insideInt = 0;
		int t = rmGetPlayerTeam(getPlayer(i));

		if(getNumberPlayersOnTeam(t) > 1) { // Leave teams of size 1 at int value 0.
			// Check teams of previous and next player.
			if(rmGetPlayerTeam(getPlayer(getPrevPlayer(i))) == t) { // getPrevPlayer() does NOT return the mapped player!
				// Previous player in same team -> option for inside.
				insideInt = insideInt + cPosLast;
			}

			if(rmGetPlayerTeam(getPlayer(getNextPlayer(i))) == t) {
				// Next player in same team -> option for inside.
				insideInt = insideInt + cPosFirst;
			}
		}

		setPlayerTeamPos(i, insideInt);
	}
}

/*
** The heart of the entire engine.
** Arranging the players ourselves is necessary so we know who is placed where.
** This is crucial for any sort of player placement, fair locations, triggers, or mirroring.
**
** @param shuffle: whether to shuffle players within teams of not (defaults to true)
*/
void initPlayers(bool shuffle = true) {
	if(hasAddObs() == false) {
		// No obs, use normal values.
		cTeams = cNumberTeams;
	} else {
		// Obs, adjust counts.
		cTeams = cNumberTeams - 1;
	}

	// Count all non-merged, non-observing players.
	for(i = 1; < cNumberPlayers) {
		if(rmGetPlayerTeam(i) < cTeams && isMergedPlayer(i) == false) {
			cNonGaiaPlayers++;
		}
	}

	cPlayers = cNonGaiaPlayers + 1;
	cPlayersObs = cNumberPlayers;

	int currPlayer = 0;

	// 1. Order actually playing players.
	for(t = 0; < cTeams) {
		for(p = 1; < cNumberPlayers) {
			if(rmGetPlayerTeam(p) == t && isMergedPlayer(p) == false) {
				currPlayer++;
				setPlayer(currPlayer, p);
				setNumberPlayersOnTeam(t, getNumberPlayersOnTeam(t) + 1);
			}
		}
	}

	// 2. Add merged players.
	for(t = 0; < cTeams) {
		for(p = 1; < cNumberPlayers) {
			if(rmGetPlayerTeam(p) == t && isMergedPlayer(p)) {
				currPlayer++;
				setPlayer(currPlayer, p);
			}
		}
	}

	// Increment cPlayersMerged by 1 because it's the number of playing players + 1.
	cPlayersMerged = currPlayer + 1;

	// 3. Add observing players.
	for(p = 1; < cNumberPlayers) { // Start from 3 as we must have at least 2 playing players.
		if(rmGetPlayerTeam(p) == cTeams) {
			currPlayer++;
			setPlayer(currPlayer, p);
			setNumberPlayersOnTeam(cTeams, getNumberPlayersOnTeam(cTeams) + 1);
		}
	}

	// Add regular observers to observer counter if they exist.
	while(rmGetPlayerName(cPlayersObs) != "") {
		realObs = true;
		cPlayersObs++;
	}

	// Set additional information regarding the player setup.
	anyObs = realObs || addObs;
	mergeModeOn = cPlayers != cPlayersMerged; // Overrides merge mode settings if no merged players are present.
	twoEqualTeams = getNumberPlayersOnTeam(0) == getNumberPlayersOnTeam(1) && cTeams == 2;

	// Shuffle if requested.
	if(shuffle) {
		shufflePlayers();
	}

	// Determine position within the team.
	calcInsideOutside();
}

/*
** General math functionality.
** RebelsRising
** Last edit: 07/03/2021
*/

/************
* CONSTANTS *
************/

extern const float PI = 3.14159265359;
extern const float e = 2.71828182846;
extern const float SQRT_2 = 1.4142135624;
extern const float HALF_SQRT_2 = 0.7071067812;
extern const float INF = 9999999.0;
extern const float NINF = -9999999.0;
extern const float TOL = 0.0000001;
extern const int MAX_IT = 100;

/**********
* GENERAL *
**********/

/*
** Calculates the smaller of two floats.
**
** @param x: first float to compare
** @param y: second float to compare
**
** @returns: the smaller of the two floats
*/
float min(float x = 0.0, float y = INF) {
	if(x > y) {
		return(y);
	}

	return(x);
}

/*
** Calculates the larger of two floats.
**
** @param x: first float to compare
** @param y: second float to compare
**
** @returns: the larger of the two floats
*/
float max(float x = 0.0, float y = NINF) {
	if(x < y) {
		return(y);
	}

	return(x);
}

/*
** Floor function for floats.
**
** @param x: the float
**
** @returns: the floor value of x
*/
float floor(float x = 0.0) {
	return(0.0 + 1 * x);
}

/*
** Ceiling function for floats.
**
** @param x: the float
**
** @returns: the ceiling value of x
*/
float ceil(float x = 0.0) {
	return(0.0 + (1 * x + 1));
}

/*
** Rounds a value for a given threshold.
**
** @param x: the value to round
** @param t: the threshold in (0.0, 1.0) to use for rounding up
**
** @returns: the rounded value
*/
float round(float x = 0.0, float t = 0.5) {
	int i = x;

	if(x - i >= t) {
		return(0.0 + (i + 1));
	}

	return(0.0 + i);
}

/*
** Calculates the absolute value of a float.
**
** @param x: the float to take the absolute value from
**
** @returns: the absolute value
*/
float abs(float x = 0.0) {
	if(x >= 0) {
		return(0.0 + x);
	}

	return(0.0 - x);
}

/*
** Calculates the squared value of a float.
**
** @param x: the float to square
**
** @returns: the squared value
*/
float sq(float x = 0.0) {
	return(x * x);
}

/*
** Calculates the signum of a float.
**
** @param a: the float to take the signum from
**
** @returns: the signum as a float (NOT int!)
*/
float sgn(float x = 0.0) {
	if(x > 0.0) {
		return(1.0);
	}

	if(x < 0.0) {
		return(-1.0);
	}

	return(0.0);
}

/*
** Calculates the power of a float.
**
** @param x: the base
** @param n: the exponent
**
** @returns: x^n
*/
float pow(float x = 0.0, int n = 0) {
	if(n == 0) {
		return(1.0);
	}

	float res = x;

	for(i = 1; < n) {
		res = res * x;
	}

	return(res);
}

/*
** Calculates the factorial of a float or int (floor applied to floats before, e.g.: 5.4! = 1 * 2 * 3 * 4 * 5).
**
** @param n: the float to calculate the factorial for
**
** @returns: n!
*/
int fact(float n = 0.0) {
	float res = 1;

	for(i = 1; <= n) {
		res = res * i;
	}

	return(res);
}

/*
** Natural logarithm, also accurate for large values (!).
** Partially taken from https://math.stackexchange.com/a/977836
** Adjusted so it also works for numbers close to 0.
**
** @param x: the float to calculate the natural logarithm for
**
** @returns x: ln(x)
*/
float log(float x = 0.0) {
	// Return infinity right away.
	if(x == 0.0) {
		return(INF);
	}

	// Convert to float and take absolute value.
	float a = abs(x);
	int n = 0;

	// Shift until we have a number of format x.[x].
	if(a >= 10.0) {
		// Shift right and count until single digit.
		while(a * 0.1 >= 1.0) {
			a = a * 0.1;
			n++;
		}
	} else if(a < 1.0) {
		// Shift left and count until >= 1.0.
		while(a * 10.0 < 1.0) {
			a = a * 10.0;
			n--;
		}
	}

	float sum = 0.0;
	float y = (a - 1.0) / (a + 1.0);

	int i = 0;
	float curr = y;
	float prec = TOL / pow(10.0, n); // Adjust precision because we're shifting.

	while(i < MAX_IT && curr > prec) {
		sum = sum + curr / (2 * i + 1);
		curr = curr * sq(y);
		i++;
	}

	// Return as log(10) * n + 2.0 * sum.
	return(2.30258509299 * n + 2.0 * sum);
}

/***************
* TRIGONOMETRY *
***************/

/*
** Approximates sin(x) via Taylor. Note that two iterations are executed per step.
**
** @param x: the value to take the sine of
**
** @returns: sin(x)
*/
float sin(float x = 0.0) {
	int n = 1;
	float res = 0.0;
	float curr = x; // Stores all the x^n / n! so we don't have to recalculate every time.

	while(n < MAX_IT && abs(curr) > TOL) {
		res = res + curr;
		curr = 0.0 - curr * (x / (n + 1)) * (x / (n + 2));
		n = n + 2;
	}

	return(res);
}

/*
** Approximates cos(x) via Taylor. Note that two iterations are executed per step.
**
** @param x: the value to take the cosine of
**
** @returns: cos(x)
*/
float cos(float x = 0.0) {
	int n = 1;
	float res = 0.0;
	float curr = 1.0; // Stores all the x^n / n! so we don't have to recalculate every time.

	while(n < MAX_IT && abs(curr) > TOL) {
		res = res + curr;
		curr = 0.0 - curr * (x / n) * (x / (n + 1));
		n = n + 2;
	}

	return(res);
}

/*
** Approximates atan(x) via Taylor.
** This can probably be approximated a lot more efficiently.
**
** @param x: the value to take the arcus tangens of
**
** @returns: atan(x)
*/
float atan(float x = 0.0) {
	float x0 = x;

	// Transform if not in [-1.0, 1.0].
	if(abs(x) > 1.0) {
		x0 = sgn(x0) / x;
	}

	int n = 1;
	float res = 0.0;
	float curr = x0; // Stores all the x0^n so we don't have to recalculate every time.
	float x0sq = sq(x0);

	while(n < MAX_IT && abs(curr) > TOL) {
		res = res + curr / n;
		curr = 0.0 - curr * x0sq;
		n = n + 2;
	}

	// Transform back if x wasn't in [-1.0, 1.0].
	if(abs(x) > 1.0) {
		res = 0.5 * PI - res;
	}

	if(x < -1.0) {
		res = 0.0 - res;
	}

	return(res);
}

/*
** atan2(). Used to get the angle of a point in the Cartesian coordinate system.
** An offset can be set, defaults to the center of the map.
**
** @param x: x coordinate in [0.0, 1.0]
** @param z: z coordinate in [0.0, 1.0]
** @param offsetX: x offset, 0.5 = middle of the x axis
** @param offsetZ: z offset, 0.5 = middle of the z axis
**
** @returns: the angle of (x, z)
*/
float getAngleFromCartesian(float x = 0.0, float z = 0.0, float offsetX = 0.5, float offsetZ = 0.5) {
	x = x - offsetX;
	z = z - offsetZ;

	float frac = z / x;

	// atan2(). Considers cases where x is very small and frac gets very large.
	if(abs(frac) > INF && z > 0.0) {
		return(0.5 * PI);
	}

	if(abs(frac) > INF && z < 0.0) {
		return(0.0 - 0.5 * PI);
	}

	if(x > 0.0) {
		return(atan(frac));
	}

	if(x < 0.0 && z >= 0.0) {
		return(atan(frac) + PI);
	}

	if(x < 0.0 && z < 0.0) {
		return(atan(frac) - PI);
	}

	// x == z == 0 -> undefined angle; this will likely never happen because 0.5 - 0.5 can result in -0.000...
	return(0.0);
}

/*
** Counterpart of getAngleFromCartesian() (atan2()). Returns the radius of a point in the Cartesian coordinate system with respect to an offset.
**
** @param x: x coordinate in [0.0, 1.0]
** @param z: z coordinate in [0.0, 1.0]
** @param offsetX: x offset, 0.5 = middle of the x axis
** @param offsetZ: z offset, 0.5 = middle of the z axis
**
** @returns: the radius of (x, z)
*/
float getRadiusFromCartesian(float x = 0.0, float z = 0.0, float offsetX = 0.5, float offsetZ = 0.5) {
	return(sqrt(sq(x - offsetX) + sq(z - offsetZ)));
}

/*********
* POINTS *
*********/

/*
** Calculates the x coordinate in the Cartesian coordinate system from polar coordinates.
**
** @param r: the radius
** @param a: angle in radians
** @param offset: x offset, 0.5 = middle of the x axis
**
** @returns: x in Cartesian coordinates
*/
float getXFromPolar(float r = 0.0, float a = 0.0, float offset = 0.5) {
	return(cos(a) * r + offset);
}

/*
** Calculates the z coordinate in the Cartesian coordinate system from polar coordinates.
**
** @param r: the radius
** @param a: angle in radians
** @param offset: z offset, 0.5 = middle of the z axis
**
** @returns: z in Cartesian coordinates
*/
float getZFromPolar(float r = 0.0, float a = 0.0, float offset = 0.5) {
	return(sin(a) * r + offset);
}

/*
** Rotates a point (or vector if you want) around an angle.
**
** @param x: x coordinate
** @param z: z coordinate
** @param a: the angle to rotate the point around
**
** @returns: the x coordinate of the rotated point
*/
float getXRotatePoint(float x = 0.0, float z = 0.0, float a = 0.0) {
	return(cos(a) * x - sin(a) * z);
}

/*
** Rotates a point (or vector if you want) around an angle.
**
** @param x: x coordinate
** @param z: z coordinate
** @param a: the angle to rotate the point around
**
** @returns: the z coordinate of the rotated point
*/
float getZRotatePoint(float x = 0.0, float z = 0.0, float a = 0.0) {
	return(cos(a) * z + sin(a) * x);
}

/*
** Maps a point in the Cartesian coordinate system from circular to square by stretching.
** Source: https://arxiv.org/ftp/arxiv/papers/1509/1509.06344.pdf
**
** @param x: x coordinate in [0.0, 1.0]
** @param z: z coordinate in [0.0, 1.0]
**
** @returns: the x coordinate of the stretched point
*/
float mapXToSquare(float x = 0.0, float z = 1.0) {
	float xSq = sq(x);
	float zSq = sq(z);

	if(xSq >= zSq) {
		return(sgn(x) * sqrt(xSq + zSq));
	}

	return(sgn(z) * (x / z) * sqrt(xSq + zSq));
}

/*
** Maps a point in the Cartesian coordinate system from circular to square by stretching.
** Source: https://arxiv.org/ftp/arxiv/papers/1509/1509.06344.pdf
**
** @param x: x coordinate in [0.0, 1.0]
** @param z: z coordinate in [0.0, 1.0]
**
** @returns: the z coordinate of the stretched point
*/
float mapZToSquare(float x = 1.0, float z = 0.0) {
	float xSq = sq(x);
	float zSq = sq(z);

	if(xSq >= zSq) {
		return(sgn(x) * (z / x) * sqrt(xSq + zSq));
	}

	return(sgn(z) * sqrt(xSq + zSq));
}

/*
** Calculates the distance between two points in the Cartesian coordinate system.
**
** @param x1: x value of point 1
** @param z1: z value of point 1
** @param x2: x value of point 2
** @param z2: z value of point 2
**
** @returns: the distance between the two points
*/
float pointsGetDist(float x1 = 0.0, float z1 = 0.0, float x2 = 0.0, float z2 = 0.0) {
	return(sqrt(sq(x1 - x2) + sq(z1 - z2)));
}

/*
** Determines whether a location is valid (within the map boundaries) or not.
** A tolerance value can be set to allow edges smaller than 0.0/1.0.
**
** @param x: x value of the location
** @param z: z value of the location
** @param tolX: tolerance value for x
** @param tolZ: tolerance value for z
**
** @returns: true if the point is valid, false otherwise
*/
bool isLocValid(float x = 0.0, float z = 0.0, float tolX = 0.0, float tolZ = 0.0) {
	return(x >= tolX && x <= 1.0 - tolX && z >= tolZ && z <= 1.0 - tolZ);
}

/*********
* ANGLES *
*********/

/*
** Calculates the section between two angles, where the second angle is assumed to "follow" the first one (counterclockwise).
** Example: getAngleBetweenConsecutiveAngles(1.0 * PI, 1.5 * PI) = 0.5 * PI.
**
** @param a1: the first angle
** @param a2: the second angle
**
** @returns: the section between the two angles (in radians)
*/
float getSectionBetweenConsecutiveAngles(float a1 = 0.0, float a2 = 0.0) {
	while(a2 < a1) {
		a2 = a2 + 2.0 * PI;
	}

	return(a2 - a1);
}

/*
** Calculates the angle between two angles, where the second angle is assumed to "follow" the first one (counterclockwise).
** The difference to the above function is that this function returns an angle with offset.
**
** @param a1: the first angle
** @param a2: the second angle
**
** @returns: the angle between the two angles (in radians)
*/
float getAngleBetweenConsecutiveAngles(float a1 = 0.0, float a2 = 0.0) {
	return(a1 + 0.5 * getSectionBetweenConsecutiveAngles(a1, a2));
}

/*
** Conversions, scaling, randomization, constraints, player placement, and core areas.
** RebelsRising
** Last edit: 16/04/2021
*/

// include "rmx_core.xs";
// include "rmx_math.xs";

/************
* CONSTANTS *
************/

extern const string cSplitClassName = "rmx virtual split";
extern const string cTeamSplitClassName = "rmx virtual team split";
extern const string cCenterlineClassName = "rmx centerline";
extern const string cCenterClassName = "rmx center";
extern const string cCornerClassName = "rmx corner";

extern const string cSplitName = "rmx split";
extern const string cTeamSplitName = "rmx team split";
extern const string cFakeTeamSplitName = "rmx fake team split";
extern const string cCenterlineName = "rmx centerline";
extern const string cCenterName = "rmx center";
extern const string cCornerName = "rmx corner";

/*********
* ARRAYS *
*********/

/*
 * Player angles from player placement. Mapping is as follows:
 * getPlayerAngle(2) is the angle of player getPlayer(2).
 * This avoids redundant calls to getPlayer within getPlayerAngle.
*/
float playerAngle1 = 0.0; float playerAngle2  = 0.0; float playerAngle3  = 0.0; float playerAngle4  = 0.0;
float playerAngle5 = 0.0; float playerAngle6  = 0.0; float playerAngle7  = 0.0; float playerAngle8  = 0.0;
float playerAngle9 = 0.0; float playerAngle10 = 0.0; float playerAngle11 = 0.0; float playerAngle12 = 0.0;

float getPlayerAngle(int p = 0) {
	if(p == 0) return(0.0); // We use 0 frequently, return early.
	if(p == 1) return(playerAngle1); if(p == 2)  return(playerAngle2);  if(p == 3)  return(playerAngle3);  if(p == 4)  return(playerAngle4);
	if(p == 5) return(playerAngle5); if(p == 6)  return(playerAngle6);  if(p == 7)  return(playerAngle7);  if(p == 8)  return(playerAngle8);
	if(p == 9) return(playerAngle9); if(p == 10) return(playerAngle10); if(p == 11) return(playerAngle11); if(p == 12) return(playerAngle12);
	return(0.0);
}

void setPlayerAngle(int p = 0, float a = 0) {
	if(p == 1) playerAngle1 = a; if(p == 2)  playerAngle2  = a; if(p == 3)  playerAngle3  = a;  if(p == 4)  playerAngle4  = a;
	if(p == 5) playerAngle5 = a; if(p == 6)  playerAngle6  = a; if(p == 7)  playerAngle7  = a;  if(p == 8)  playerAngle8  = a;
	if(p == 9) playerAngle9 = a; if(p == 10) playerAngle10 = a; if(p == 11) playerAngle11 = a;  if(p == 12) playerAngle12 = a;
}

// Team angles (teams start from 0).
float teamAngle0 = 0.0; float teamAngle1 = 0.0; float teamAngle2  = 0.0; float teamAngle3  = 0.0;
float teamAngle4 = 0.0; float teamAngle5 = 0.0; float teamAngle6  = 0.0; float teamAngle7  = 0.0;
float teamAngle8 = 0.0; float teamAngle9 = 0.0; float teamAngle10 = 0.0; float teamAngle11 = 0.0;

float getTeamAngle(int id = 0) {
	if(id == 0) return(teamAngle0); if(id == 1) return(teamAngle1); if(id == 2)  return(teamAngle2);  if(id == 3)  return(teamAngle3);
	if(id == 4) return(teamAngle4); if(id == 5) return(teamAngle5); if(id == 6)  return(teamAngle6);  if(id == 7)  return(teamAngle7);
	if(id == 8) return(teamAngle8); if(id == 9) return(teamAngle9); if(id == 10) return(teamAngle10); if(id == 11) return(teamAngle11);
	return(0.0);
}

void setTeamAngle(int id = 0, float a = 0.0) {
	if(id == 0) teamAngle0 = a; if(id == 1) teamAngle1 = a; if(id == 2)  teamAngle2  = a; if(id == 3)  teamAngle3  = a;
	if(id == 4) teamAngle4 = a; if(id == 5) teamAngle5 = a; if(id == 6)  teamAngle6  = a; if(id == 7)  teamAngle7  = a;
	if(id == 8) teamAngle8 = a; if(id == 9) teamAngle9 = a; if(id == 10) teamAngle10 = a; if(id == 11) teamAngle11 = a;
}

// Player offset angles describing how much a player's angle differs from the angle the team is facing.
float playerTeamOffsetAngle1 = 0.0; float playerTeamOffsetAngle2  = 0.0; float playerTeamOffsetAngle3  = 0.0; float playerTeamOffsetAngle4  = 0.0;
float playerTeamOffsetAngle5 = 0.0; float playerTeamOffsetAngle6  = 0.0; float playerTeamOffsetAngle7  = 0.0; float playerTeamOffsetAngle8  = 0.0;
float playerTeamOffsetAngle9 = 0.0; float playerTeamOffsetAngle10 = 0.0; float playerTeamOffsetAngle11 = 0.0; float playerTeamOffsetAngle12 = 0.0;

float getPlayerTeamOffsetAngle(int t = 0) {
	if(t == 1) return(playerTeamOffsetAngle1); if(t == 2)  return(playerTeamOffsetAngle2);  if(t == 3)  return(playerTeamOffsetAngle3);  if(t == 4)  return(playerTeamOffsetAngle4);
	if(t == 5) return(playerTeamOffsetAngle5); if(t == 6)  return(playerTeamOffsetAngle6);  if(t == 7)  return(playerTeamOffsetAngle7);  if(t == 8)  return(playerTeamOffsetAngle8);
	if(t == 9) return(playerTeamOffsetAngle9); if(t == 10) return(playerTeamOffsetAngle10); if(t == 11) return(playerTeamOffsetAngle11); if(t == 12) return(playerTeamOffsetAngle12);
	return(0.0);
}

void setPlayerTeamOffsetAngle(int t = 0, float a = 0) {
	if(t == 1) playerTeamOffsetAngle1 = a; if(t == 2)  playerTeamOffsetAngle2  = a; if(t == 3)  playerTeamOffsetAngle3  = a; if(t == 4)  playerTeamOffsetAngle4  = a;
	if(t == 5) playerTeamOffsetAngle5 = a; if(t == 6)  playerTeamOffsetAngle6  = a; if(t == 7)  playerTeamOffsetAngle7  = a; if(t == 8)  playerTeamOffsetAngle8  = a;
	if(t == 9) playerTeamOffsetAngle9 = a; if(t == 10) playerTeamOffsetAngle10 = a; if(t == 11) playerTeamOffsetAngle11 = a; if(t == 12) playerTeamOffsetAngle12 = a;
}

/*******************
* TYPE CONVERSIONS *
*******************/

/*
** Convets a bool to a string.
**
** @param b: the bool to convert
**
** @returns: "true" if b is true, "false" otherwise
*/
string boolToString(bool b = true) {
	if(b) {
		return("true");
	}

	return("false");
}

/*
** Convets an int to a float (I often prefer to use 1.0 * ... directly instead of this).
**
** @param i: the int to convert
**
** @returns: the converted int as a float
*/
float intToFloat(int i = 0) {
	return(0.0 + i);
}

/*
** Convets a float to an int.
**
** @param f: the float to convert
**
** @returns: the converted float as an int
*/
int floatToInt(float f = 0.0) {
	return(1 * f);
}

/*****************
* MAP DIMENSIONS *
*****************/

// If one side is larger than the other, you can squash it using this factor (1.0 for the smaller side, < 1.0 for the larger side).
float dimFactorX = 1.0;
float dimFactorZ = 1.0;

// "Constants" that are set via setMapSize() so we don't have to calculate them over and over again.
float xMeters = 0.0;
float zMeters = 0.0;

/*
** Shortcut to the most common function used to determine the length of the x/z dimensions.
**
** @param playerTiles: the number of tiles to use per player
** @param tileDivisor: the divisior used to further adjust the tile value (default 0.9, set to 1.0 on some maps)
** @param preFactor: the factor to apply after calculating the sqrt (default 2.0)
** @param sizeFactor: the factor used to scale the map (normal/large/...); used as factor with sizeFactor^cMapSize
** @param playerOverride: overrides cNonGaiaPlayers if set
**
** @returns: the calculated map size (to be used as meters)
*/
float getStandardMapDimInMeters(int playerTiles = 7500, float tileDivisor = 0.9, float preFactor = 2.0, float sizeFactor = 1.3, int playerOverride = -1) {
	if(playerOverride < 0) {
		playerOverride = cNonGaiaPlayers;
	}

	return(preFactor * sqrt(playerOverride * (pow(sizeFactor, cMapSize) * playerTiles) / tileDivisor));
}

/*
** Returns the distance from the center to the corner in meters.
**
** @returns: distance from center to corner in meters
*/
float getCornerRadiusInMeters() {
	return(sqrt(sq(0.5 * xMeters) + sq(0.5 * zMeters)));
}

/*
** Has to be used instead of rmSetMapSize() and rmTerrainInitialize().
**
** The reason we have two factors (dimFactorX and dimFactorZ is that we can always easily shorten the longer side.
** This way we can stick to the distances we are used to (in meters), even in rectangular maps.
**
** The x/z dimension length will be converted to integers if provided as float,
** since the argument type overrides the type in the function signature in xs.
**
** @param terrain: the type of terrain to initialize; "Water" for initializing to water
** @param x0: x dimension in meters
** @param z0: z dimension in meters
*/
void initializeMap(string terrain = "Water", int x0 = 0, int z0 = -1) {
	// Force conversion to int if parameters were provided as floats (xs doesn't convert them to int despite the function signature).
	int x = x0;
	int z = z0;

	if(z < 0) {
		z = x;
	}

	rmSetMapSize(x, z);

	rmTerrainInitialize(terrain);

	xMeters = rmXFractionToMeters(1.0);
	zMeters = rmZFractionToMeters(1.0);

	if(x >= z) {
		// X longer dimension.
		dimFactorX = 1.0 * z / x; // * 1.0 to avoid int division.
	} else {
		// Z longer dimension.
		dimFactorZ = 1.0 * x / z; // * 1.0 to avoid int division.
	}

	printDebug("Map size: " + x + " x " + z, cDebugTest);
	printDebug("Radius to corner: " + floatToInt(getCornerRadiusInMeters()), cDebugTest);
}

/*
** Gets the dimension factor for x axis.
**
** @returns: the dimension factor of the x axis as float.
*/
float getDimFacX() {
	return(dimFactorX);
}

/*
** Gets the dimension factor for z axis.
**
** @returns: the dimension factor of the z axis as float.
*/
float getDimFacZ() {
	return(dimFactorZ);
}

/*
** Returns the length of the x axis.
**
** @returns: length of the x axis in meters
*/
float getFullXMeters() {
	return(xMeters);
}

/*
** Returns the length of the z axis.
**
** @returns: length of the z axis in meters
*/
float getFullZMeters() {
	return(zMeters);
}

/*
** Checks if the x dimension of this map is larger than the z dimension.
**
** @returns: true if the x dimension is larger, false otherwise
*/
bool isXLargerZ() {
	return(xMeters > zMeters);
}

/*
** Adjusts a single coordinate to fit within the map in [0, 1.0].
**
** @param x: the coordinate as a fraction
**
** @returns: the adjusted coordinate value
*/
float fitToMap(float x = 0.0) {
	if(x < 0.0) {
		return(0.0);
	}

	if(x > 1.0) {
		return(1.0);
	}

	return(x);
}

/**********************
* SPATIAL CONVERSIONS *
**********************/

/*
** Converts/stretches a square radius (as used by the original placement functions) to a circular one.
** Useful to adjust the maximum radius of an object if you want to use the original ES ranges, but use it with circular placement.
**
** @param r: the old radius
**
** @returns: the stretched radius
*/
float squaredToCircularRadius(float r = 0.0) {
	return(SQRT_2 * r);
}

/*
** Can be used to wrap a radius (in meters) for rmSetAreaSize().
** Since the latter function considers its input as a fraction of the total map area (i.e., size of x * size of z) to cover,
** this can be used to place areas with a certain radius size (as long as they are within map bounds!).
**
** This function considers rectangular maps, i.e., will maintain the radius of the circle regardless of the map dimensions.
**
** @param r: the radius to wrap in meters
**
** @returns: the wrapped radius in meters
*/
float areaRadiusMetersToFraction(float r = 0.0) {
	return(sq(r) * PI / (getFullXMeters() * getFullZMeters()));
}

/*
** Converts a fraction to meters according to the smaller dimension of the map.
**
** @param frac: the fraction to convert
**
** @returns: the converted fraction in meters
*/
float smallerFractionToMeters(float frac = 0.0) {
	if(isXLargerZ()) {
		return(rmZFractionToMeters(frac));
	}

	return(rmXFractionToMeters(frac));
}

/*
** Converts a fraction to meters according to the larger dimension of the map.
**
** @param frac: the fraction to convert
**
** @returns: the converted fraction in meters
*/
float largerFractionToMeters(float frac = 0.0) {
	if(isXLargerZ()) {
		return(rmXFractionToMeters(frac));
	}

	return(rmZFractionToMeters(frac));
}

/*
** Converts meters to a fraction according to the smaller dimension of the map.
**
** @param meters: the meters to convert
**
** @returns: the resulting fraction
*/
float smallerMetersToFraction(float meters = 0.0) {
	if(isXLargerZ()) {
		return(rmZMetersToFraction(meters));
	}

	return(rmXMetersToFraction(meters));
}

/*
** Converts meters to a fraction according to the larger dimension of the map.
**
** @param meters: the meters to convert
**
** @returns: the resulting fraction
*/
float largerMetersToFraction(float meters = 0.0) {
	if(isXLargerZ()) {
		return(rmXMetersToFraction(meters));
	}

	return(rmZMetersToFraction(meters));
}

/*********************
* RANDOMIZATION UTIL *
*********************/

/*
** Randomly returns true or false for a given chance.
**
** @param trueChance: the chance to return true
**
** @returns: true if the randomized value lies in [0, 0.5), false otherwise
*/
bool randChance(float trueChance = 0.5) {
	if(rmRandFloat(0.0, 1.0) < trueChance) {
		return(true);
	}

	return(false);
}

/*
** Calculates a random float with a higher chance for a smaller value.
**
** @param x: minimum value
** @param y: maximum value
**
** @returns: the randomized float
*/
float randSmallFloat(float x = 0.0, float y = 1.0) {
	return(sq(rmRandFloat(sqrt(x), sqrt(y))));
}

/*
** Calculates a random float with a higher chance for a larger value.
**
** @param x: minimum value
** @param y: maximum value
**
** @returns: the randomized float
*/
float randLargeFloat(float x = 0.0, float y = 1.0) {
	return(sqrt(rmRandFloat(sq(x), sq(y))));
}

/*
** Calculates a random int with a higher chance for a smaller value.
**
** @param x: minimum value
** @param y: maximum value
**
** @returns: the randomized int
*/
int randSmallInt(int x = 0, int y = 0) {
	return(0 + sq(rmRandFloat(sqrt(x), sqrt(y + 1))));
}

/*
** Calculates a random int with a higher chance for a larger value.
**
** @param x: minimum value
** @param y: maximum value
**
** @returns: the randomized int
*/
int randLargeInt(int x = 0, int y = 0) {
	return(0 + sqrt(rmRandFloat(sq(x), sq(y + 1))));
}

/*
** Calculates a random angle in [-PI, PI].
**
** @returns: the randomized angle in radians
*/
float randRadian() {
	return(rmRandFloat(0.0 - PI, PI));
}

/*
** Randomizes an equally distributed value from two intervals.
** Essentially, this concatenates the intervals and adds an offset after randomizing if a value in range of the second interval was chosen.
**
** @param aStart: start of the first interval
** @param aEnd: end of the first interval
** @param bStart: start of the second interval
** @param bEnd: end of the second interval
**
** @returns: the randomized value
*/
float randFromIntervals(float aStart = 0.0, float aEnd = 0.0, float bStart = INF, float bEnd = INF) {
	if(abs(bEnd - bStart) < TOL) {
		return(rmRandFloat(aStart, aEnd));
	}

	float diff = bStart - aEnd;
	float rand = rmRandFloat(aStart, aEnd + (bEnd - bStart));

	if(rand > aEnd) {
		rand = rand + diff;
	}

	return(rand);
}

/*
** Calculates a random radius within a given interval [minDist, maxDist] with respect to map dimensions.
** Note that this function expects the radius in meters as input (and not as a fraction) and returns the radius as a fraction!
** Uses the shorter dimension for calculation.
**
** @param minDist: the minimum radius distance in meters
** @param maxDist: the maximum radius distance in meters
**
** @returns: the randomized radius as a fraction (!)
*/
float randRadiusFromInterval(float minDist = 0.0, float maxDist = -1.0) {
	if(maxDist < 0.0) {
		maxDist = minDist;
	}

	if(getFullXMeters() > getFullZMeters()) {
		return(rmZMetersToFraction(rmRandFloat(minDist, maxDist)));
	}

	return(rmXMetersToFraction(rmRandFloat(minDist, maxDist)));
}

/*
** Calculates a random radius within [0, r] with respect to map dimensions.
**
** Also see randRadiusFromInterval().
**
** @param r: the maximum radius distance in meters
**
** @returns: the randomized radius as a fraction (!)
*/
float randRadiusFromZero(float r = 0.0) {
	return(randRadiusFromInterval(0.0, r));
}

/*
** Calculates a random radius between minDist and the edge of the map with respect to map dimensions.
**
** Also see randRadiusFromInterval().
**
** @param r: the maximum radius distance in meters
**
** @returns: the randomized radius as a fraction (!)
*/
float randRadiusFromCenterToEdge(float minDist = 0.0) {
	float maxDist = sqrt(sq(0.5 * getFullXMeters()) + sq(0.5 * getFullZMeters())); // Max distance to reach from center.

	return(randRadiusFromInterval(minDist, maxDist));
}

/******************
* PLAYER LOC UTIL *
******************/

/*
** Retrieves a player's x location, including for player 0 (Mother Nature) at 0.5/0.5.
**
** @param player: the player (unmapped)
**
** @returns: the x coordinate of the player's location
*/
float getPlayerLocXFraction(int player = 0) {
	if(player == 0) {
		return(0.5);
	}

	return(rmPlayerLocXFraction(getPlayer(player)));
}

/*
** Retrieves a player's z location, including for player 0 (Mother Nature) at 0.5/0.5.
**
** @param player: the player (unmapped)
**
** @returns: the x coordinate of the player's location
*/
float getPlayerLocZFraction(int player = 0) {
	if(player == 0) {
		return(0.5);
	}

	return(rmPlayerLocZFraction(getPlayer(player)));
}

/*
** Calculates the x coordinate of a location with respect to a player, including player 0 (Mother Nature).
**
** @param player: the player (unmapped)
** @param radius: the radius as a fraction
** @param angle: the angle in radians
** @param square: if true, the radius will be transformed to a square instead of a circle from the player's origin
**
** @returns: the calculated x coordinate
*/
float getXFromPolarForPlayer(int player = 0, float radius = 0.0, float angle = 0.0, bool square = false) {
	angle = angle + getPlayerAngle(player);

	// Square vs. circular distance from origin.
	if(square) {
		// Allow the range to be a square instead of a circle (as the original placement functions do).
		float xPol = getXFromPolar(radius, angle, 0.0) * getDimFacX();
		float zPol = getZFromPolar(radius, angle, 0.0) * getDimFacZ();

		return(mapXToSquare(xPol, zPol) + getPlayerLocXFraction(player));
	}

	return(getXFromPolar(radius, angle, 0.0) * getDimFacX() + getPlayerLocXFraction(player));
}

/*
** Calculates the z coordinate of a location with respect to a player, including player 0 (Mother Nature).
**
** @param player: the player (unmapped)
** @param radius: the radius as a fraction
** @param angle: the angle in radians
** @param square: if true, the radius will be transformed to a square instead of a circle from the player's origin
**
** @returns: the calculated z coordinate
*/
float getZFromPolarForPlayer(int player = 0, float radius = 0.0, float angle = 0.0, bool square = false) {
	angle = angle + getPlayerAngle(player);

	// Square vs. circular distance from origin.
	if(square) {
		// Allow the range to be a square instead of a circle (as the original placement functions do).
		float xPol = getXFromPolar(radius, angle, 0.0) * getDimFacX();
		float zPol = getZFromPolar(radius, angle, 0.0) * getDimFacZ();

		return(mapZToSquare(xPol, zPol) + getPlayerLocZFraction(player));
	}

	return(getZFromPolar(radius, angle, 0.0) * getDimFacZ() + getPlayerLocZFraction(player));
}

/*******************
* PLAYER PLACEMENT *
*******************/

/*
** Calculates the angles of the teams (i.e., the direction the team is facing towards the center).
** This is currently not ideal when placing teams separately (e.g. on Anatolia) as this is called multiple times.
** However, I would refrain from requiring a separate call to this as it could easily be forgotten and is not much overhead anyway.
**
** If you place players yourself you have to call this manually.
** Furthermore, if you place players in a fashion such that getPlayer(1) is not next to getPlayer(2) etc., you may have to calculate team angles yourself.
** Calculating this value is crucial for fair locations and for mirroring.
*/
void calcPlayerTeamOffsetAngles() {
	int currPlayer = 1;
	int angleOffsetPlayer = 1;
	float lastAngle = NINF;

	for(i = 0; < cTeams) {
		float teamAngle = 0.0;

		// For every team, iterate over players and sum up angles to calculate the offset of a player from team direction.
		for(j = 0; < getNumberPlayersOnTeam(i)) {
			float playerAngle = getPlayerAngle(currPlayer);

			// Adjust angle so we always have increasing player angles. Note that some functions of the framework take this assumption for granted!
			while(playerAngle < lastAngle) {
				playerAngle = playerAngle + 2.0 * PI;
			}

			setPlayerAngle(currPlayer, playerAngle);
			teamAngle = teamAngle + playerAngle;

			lastAngle = playerAngle;
			currPlayer++;
		}

		float normalizedTeamAngle = teamAngle / getNumberPlayersOnTeam(i);

		while(normalizedTeamAngle > 2.0 * PI) {
			normalizedTeamAngle = normalizedTeamAngle - 2.0 * PI;
		}

		setTeamAngle(i, normalizedTeamAngle);

		float teamOffsetAngle = teamAngle / getNumberPlayersOnTeam(i);

		for(j = 0; < getNumberPlayersOnTeam(i)) {
			setPlayerTeamOffsetAngle(angleOffsetPlayer, teamOffsetAngle - getPlayerAngle(angleOffsetPlayer)); // Team angle array starts also at 1.
			angleOffsetPlayer++;
		}
	}
}

/*
** Places players in a circle. Placement occurs counterclockwise from the starting angle.
** This is just an example of a circular placement function, for specific maps it may be sensible to implement your own function.
**
** @param minRadius: the minimum radius to randomize from in the shorter dimension as a fraction
** @param maxRadius: the maximum radius to randomize from in the shorter dimension as a fraction
** @param spacing: spacing modifier; 1.0 -> equidistant spacing between players, < 1.0 -> teams closer together
** @param range: percentage of the circle to use for placement (1.0 = 360 degrees)
** @param angle: angle (radian) at which to place the first player at, randomized on default
** @param offsetX: x offset (0.5 = center of x axis)
** @param offsetZ: z offset (0.5 = center of z axis)
**
** @returns: the radius that was chosen to place the players as a fraction
*/
float placePlayersInCircle(float minRadius = 0.0, float maxRadius = -1.0, float spacing = 1.0, float range = 1.0, float angle = INF, float offsetX = 0.5, float offsetZ = 0.5) {
	if(maxRadius < minRadius) {
		maxRadius = minRadius;
	}

	float radius = rmRandFloat(minRadius, maxRadius);

	printDebug("Player placement radius: " + radius, cDebugTest);

	// Calculate the segment to append after every iteration. Regular = within team, last = before next team gets placed (due to spacing).
	float reg = spacing * ((2.0 * PI) / cNonGaiaPlayers);
	float last = reg + (2.0 * PI - reg * cNonGaiaPlayers) / cTeams;

	// Adjust if custom range set.
	if(range < 1.0) {
		reg = spacing * ((2.0 * PI * range) / (cNonGaiaPlayers - 1));
		last = reg + (2.0 * PI * range - reg * (cNonGaiaPlayers - 1)) / (cTeams - 1);
	}

	if(angle == INF) {
		angle = randRadian();
	}

	float a = angle; // Just to make sure because 0 is interpreted as an int if we use the parameter variable.

	int player = 1;

	for(i = 0; < cTeams) {
		for(j = 0; < getNumberPlayersOnTeam(i)) {
			float x = getXFromPolar(radius, a, 0.0) * getDimFacX() + offsetX;
			float z = getZFromPolar(radius, a, 0.0) * getDimFacZ() + offsetZ;

			// Place player and set angle.
			rmPlacePlayer(getPlayer(player), x, z);
			setPlayerAngle(player, a);

			// Add current angle and prepare next iteration.
			if(j < getNumberPlayersOnTeam(i) - 1) {
				a = a + reg;
			} else {
				a = a + last;
			}

			player++;
		}
	}

	calcPlayerTeamOffsetAngles();

	// Return the randomed radius in case it's needed in the map script.
	return(radius);
}

/*
** Places players of a given team in a circle. Placement occurs counterclockwise from the starting angle.
** The different order of parameters compared to placePlayersInCircle() is chosen due to range being a lot less relevant here.
** Doesn't take a min/max to randomize from due to placing separate teams with different radii should not be necessarily.
** Therefore, you should randomize the radius directly in the random map script and then use the same radius for all teams when using this function for placement.
**
** @param teamID: the ID of the team (starting at 0)
** @param radius: radius in the shorter dimension as a fraction
** @param range: percentage of the circle to use for placement (1.0 = 360 degrees)
** @param angle: angle (radian) at which to place the first player at, randomized on default
** @param offsetX: x offset (0.5 = center of x axis)
** @param offsetZ: z offset (0.5 = center of z axis)
*/
void placeTeamInCircle(int teamID = -1, float radius = 0.0, float range = 1.0, float angle = INF, float offsetX = 0.5, float offsetZ = 0.5) {
	printDebug("Team " + teamID + " placement radius: " + radius, cDebugTest);

	int numPlayers = getNumberPlayersOnTeam(teamID);
	int player = 1;

	for(i = 0; < teamID) {
		player = player + getNumberPlayersOnTeam(i);
	}

	float reg = (2.0 * PI) / numPlayers;

	// Adjust if custom range set.
	if(range < 1.0) {
		reg = (2.0 * PI * range) / max(1, numPlayers - 1);
	}

	// Set initial angle.
	if(angle == INF) {
		angle = randRadian();
	}

	float a = angle; // Just to make sure because 0 is interpreted as an int if we use the parameter variable.

	// Adjust initial angle by team offset.
	if(range != 1.0 && numPlayers > 1) {
		a = a - range * PI;
	}

	for(i = 0; < numPlayers) {
		float x = getXFromPolar(radius, a, 0.0) * getDimFacX() + offsetX;
		float z = getZFromPolar(radius, a, 0.0) * getDimFacZ() + offsetZ;

		// Place player and set angle.
		rmPlacePlayer(getPlayer(player), x, z);
		setPlayerAngle(player, a);

		// Add current angle and prepare next iteration.
		a = a + reg;
		player++;
	}

	calcPlayerTeamOffsetAngles();
}

/*
** Places players in a square.
** Note that this mimicks the original rmPlacePlayersSquare function and does not necessarily result in equidistant player placement.
** Instead, if the next player is placed around a corner, the distance will be shorter.
**
** If you want to do fancier stuff like placing each team in a U shape, I'd recommend tweaking the circular placement function (with range) by mapping the circle to a square.
** This can be achieved with mapXToSquare() and mapZToSquare() (mind that the offset has to be added AFTER this calculation) and will result in equidistant square placement.
**
** @param minRadius: the minimum radius to randomize from in the shorter dimension as a fraction
** @param maxRadius: the maximum radius to randomize from in the shorter dimension as a fraction
** @param spacing: spacing modifier; 1.0 -> equidistant spacing between players, < 1.0 -> teams closer together
**
** @returns: the radius that was chosen to place the players as a fraction
*/
float placePlayersInSquare(float minRadius = 0.0, float maxRadius = -1.0, float spacing = 1.0) {
	if(maxRadius < minRadius) {
		maxRadius = minRadius;
	}

	float radius = rmRandFloat(minRadius, maxRadius);

	printDebug("Placement radius: " + radius, cDebugTest);

	// Edge distance in meters.
	float edgeDist = (0.5 * getFullXMeters() - rmXFractionToMeters(radius)) * getDimFacX();

	// Throughout this function, x and z are considered in meters.
	float x = 0.0;
	float z = 0.0;

	// Sets the direction we're moving; true = along x axis, false = along z axis.
	bool xStep = false;

	// Randomize starting point.
	if(randChance()) {
		// Fix x on either side, randomize z anywhere along the z axis.
		if(randChance()) {
			x = edgeDist;
		} else {
			x = getFullXMeters() - edgeDist;
		}

		z = rmRandFloat(edgeDist, getFullZMeters() - edgeDist);
	} else {
		// Fix z on either side, randomize x anywhere along the x axis.
		if(randChance()) {
			z = edgeDist;
		} else {
			z = getFullZMeters() - edgeDist;
		}

		x = rmRandFloat(edgeDist, getFullXMeters() - edgeDist);
		xStep = true;
	}

	// Circumference.
	float circ = 2.0 * getFullXMeters() + 2.0 * getFullZMeters() - 8.0 * edgeDist;

	// Distance between players of the same team (smaller if spacing is < 1.0).
	float sameTeamDist = (circ / cNonGaiaPlayers) * spacing;

	// Distance between players of different teams (larger if spacing is < 1.0).
	float diffTeamDist = sameTeamDist + (circ - (sameTeamDist * cNonGaiaPlayers)) / cTeams;

	int player = 1;

	// Iterate over teams.
	for(i = 0; < cTeams) {

		// Iterate over players per team.
		for(j = 0; < getNumberPlayersOnTeam(i)) {

			// Get starting position as fraction.
			float xFrac = rmXMetersToFraction(x);
			float zFrac = rmZMetersToFraction(z);

			// Place player and set angle.
			rmPlacePlayer(getPlayer(player), xFrac, zFrac);
			setPlayerAngle(player, getAngleFromCartesian(xFrac, zFrac, 0.5, 0.5));
			player++;

			float dist = 0.0;
			float nextDist = 0.0;

			if(j == getNumberPlayersOnTeam(i) - 1) {
				nextDist = diffTeamDist; // New team next, larger gap.
			} else {
				nextDist = sameTeamDist; // Same team next, smaller gap if team spacing has been set.
			}

			// Move along the square until the next position is reached. Ignore redundant ultimate iteration.
			while(dist < nextDist && (i != cTeams - 1 || j != getNumberPlayersOnTeam(i) - 1)) {
				/*
				 * xStep:
				 * z > 0.5 * getFullZMeters(): Currently in upper half, subtract.
				 * z < 0.5 * getFullZMeters(): Currently in lower half, add.
				 *
				 * zStep:
				 * x > 0.5 * getFullXMeters(): Currently in right half, add.
				 * x < 0.5 * getFullXMeters(): Currently in left half, subtract.
				 *
				 * Note that we have to add some minimum value (set to 0.1) to ensure progress due to inaccuracies in float addition.
				*/
				float newVal = 0.0;

				if(xStep == true) {

					if(z < 0.5 * getFullZMeters()) {
						// Lower half: Add as much as possible before overshooting.
						newVal = min(x + (nextDist - dist), getFullXMeters() - edgeDist);
						dist = dist + max(newVal - x, 0.1);
					} else {
						// Upper half: Subtract as much as possible before overshooting.
						newVal = max(x - (nextDist - dist), edgeDist);
						dist = dist + max(x - newVal, 0.1);
					}

					x = newVal;

					if(x >= getFullXMeters() - edgeDist || x <= edgeDist) {
						xStep = false;
					}

				} else {

					if(x < 0.5 * getFullXMeters()) {
						// Left half: Subtract as much as possible before overshooting.
						newVal = max(z - (nextDist - dist), edgeDist);
						dist = dist + max(z - newVal, 0.1);
					} else {
						// Right half: Add as much as possible before overshooting.
						newVal = min(z + (nextDist - dist), getFullZMeters() - edgeDist);
						dist = dist + max(newVal - z, 0.1);
					}

					z = newVal;

					if(z >= getFullZMeters() - edgeDist || z <= edgeDist) {
						xStep = true;
					}

				}
			}

		}

	}

	calcPlayerTeamOffsetAngles();

	return(radius);
}

/*
** Places players of a team in a line.
**
** @param teamID: ID of the team to be placed, starting at 0
** @param x1: x fraction of the placement starting location
** @param z1: z fraction of the placement starting location
** @param x2: x fraction of the placement ending location
** @param z2: z fraction of the placement ending location
*/
void placeTeamInLine(int teamID = -1, float x1 = 0.0, float z1 = 0.0, float x2 = 0.0, float z2 = 0.0) {
	int numPlayers = getNumberPlayersOnTeam(teamID);

	float xDist = (x2 - x1) / (numPlayers - 1);
	float zDist = (z2 - z1) / (numPlayers - 1);

	float x = x1;
	float z = z1;
	int player = 1;

	for(i = 0; < teamID) {
		player = player + getNumberPlayersOnTeam(i);
	}

	// Special case for 1 player in team.
	if(getNumberPlayersOnTeam(teamID) == 1) {
		x = x + 0.5 * (x2 - x1);
		z = z + 0.5 * (z2 - z1);
	}

	for(j = 0; < getNumberPlayersOnTeam(i)) {
		// Place player and set angle.
		rmPlacePlayer(getPlayer(player), x, z);
		setPlayerAngle(player, getAngleFromCartesian(x, z, 0.5, 0.5));
		player++;

		// Update coordinates for next iteration.
		x = x + xDist;
		z = z + zDist;
	}

	calcPlayerTeamOffsetAngles();
}

/*
** Places all players in a line.
**
** @param x1: x fraction of the placement starting location
** @param z1: z fraction of the placement starting location
** @param x2: x fraction of the placement ending location
** @param z2: z fraction of the placement ending location
** @param spacing: spacing modifier; 1.0 -> equidistant spacing between players, < 1.0 -> teams closer together
*/
void placePlayersInLine(float x1 = 0.0, float z1 = 0.0, float x2 = 0.0, float z2 = 0.0, float spacing = 1.0) {
	float xDistSameTeam = (x2 - x1) / (cNonGaiaPlayers - 1) * spacing;
	float zDistSameTeam = (z2 - z1) / (cNonGaiaPlayers - 1) * spacing;

	float xDistDiffTeam = ((x2 - x1) - (xDistSameTeam * (cNonGaiaPlayers - cTeams))) / (cTeams - 1);
	float zDistDiffTeam = ((z2 - z1) - (zDistSameTeam * (cNonGaiaPlayers - cTeams))) / (cTeams - 1);

	float x = x1;
	float z = z1;
	int player = 1;

	for(i = 0; < cTeams) {
		for(j = 0; < getNumberPlayersOnTeam(i)) {
			// Place player and set angle.
			rmPlacePlayer(getPlayer(player), x, z);
			setPlayerAngle(player, getAngleFromCartesian(x, z, 0.5, 0.5));
			player++;

			if(j == getNumberPlayersOnTeam(i) - 1) {
				// New team next, larger gap.
				x = x + xDistDiffTeam;
				z = z + zDistDiffTeam;
			} else {
				// Same team next, smaller gap if team spacing has been set.
				x = x + xDistSameTeam;
				z = z + zDistSameTeam;
			}
		}
	}

	calcPlayerTeamOffsetAngles();
}

/*********************
* CONSTRAINT UTILITY *
*********************/

// Since we cannot retrieve created constraints by name, the label only has descriptive purpose.
const string cConstraintName = "rmx constraint";

int constraintCount = 0;

/*
** Creates a box constraint without needing to specify a label.
**
** @param startX: start of the x value of the box
** @param startZ: start of the z value of the box
** @param endX: end of the x value of the box
** @param endZ: end of the z value of the box
** @param bufferFraction: one of the few values that I am still unsure what it does - bad if missing, so just provide it anyway
**
** @returns: the ID of the created constraint
*/
int createBoxConstraint(float startX = 0.0, float startZ = 0.0, float endX = 0.0, float endZ = 0.0, float bufferFraction = NINF) {
	constraintCount++;

	if(bufferFraction == NINF) {
		return(rmCreateBoxConstraint(cConstraintName + constraintCount, startX, startZ, endX, endZ));
	}

	return(rmCreateBoxConstraint(cConstraintName + constraintCount, startX, startZ, endX, endZ, bufferFraction));
}

/*
** Creates a symmetric box constraint.
**
** @param distX: start/end of the x value of the box as a fraction
** @param distZ: start/end of the z value of the box as a fraction
** @param bufferFraction: one of the few values that I am still unsure what it does - bad if missing, so just provide it anyway
**
** @returns: the ID of the created constraint
*/
int createSymmetricBoxConstraint(float distX = 0.0, float distZ = -1.0, float bufferFraction = NINF) {
	constraintCount++;

	if(distZ < 0.0) {
		distZ = distX;
	}

	// Use without bufferFraction argument if it has not been set.
	if(bufferFraction == NINF) {
		return(rmCreateBoxConstraint(cConstraintName + constraintCount, distX, distZ, 1.0 - distX, 1.0 - distZ));
	}

	return(rmCreateBoxConstraint(cConstraintName + constraintCount, distX, distZ, 1.0 - distX, 1.0 - distZ, bufferFraction));
}


/*
** Creates an area overlap constraint without needing to specify a label.
**
** @param areaID: the ID of the area to avoid overlapping with
**
** @returns: the ID of the created constraint
*/
int createAreaOverlapConstraint(int areaID = -1) {
	constraintCount++;
	return(rmCreateAreaOverlapConstraint(cConstraintName + constraintCount, areaID));
}

/*
** Creates an area constraint without needing to specify a label.
**
** @param areaID: the ID of the area to force an object or area to be placed in
**
** @returns: the ID of the created constraint
*/
int createAreaConstraint(int areaID = -1) {
	constraintCount++;
	return(rmCreateAreaConstraint(cConstraintName + constraintCount, areaID));
}

/*
** Creates an area distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the minimum distance an object or area can be from the area
**
** @returns: the ID of the created constraint
*/
int createAreaDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateAreaDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates an area maximum distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the maximum distance an object or area can be from the area
**
** @returns: the ID of the created constraint
*/
int createAreaMaxDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateAreaMaxDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates an edge constraint without needing to specify a label.
**
** @param areaID: the ID of the area of the edge to force an object or area to be placed in
**
** @returns: the ID of the created constraint
*/
int createEdgeConstraint(int areaID = -1) {
	constraintCount++;
	return(rmCreateEdgeConstraint(cConstraintName + constraintCount, areaID));
}

/*
** Creates an edge distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the minimum distance an object or area can be from the area's edge
**
** @returns: the ID of the created constraint
*/
int createEdgeDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateEdgeDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates an edge maximum distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the maximum distance an object or area can be from the area's edge
**
** @returns: the ID of the created constraint
*/
int createEdgeMaxDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateEdgeMaxDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates a cliff edge constraint without needing to specify a label.
**
** @param areaID: the ID of the area of the edge to force an object or area to be placed in
**
** @returns: the ID of the created constraint
*/
int createCliffEdgeConstraint(int areaID = -1) {
	constraintCount++;
	return(rmCreateCliffEdgeConstraint(cConstraintName + constraintCount, areaID));
}

/*
** Creates a cliff edge distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the minimum distance an object or area can be from the area's edge
**
** @returns: the ID of the created constraint
*/
int createCliffEdgeDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateCliffEdgeDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates a cliff edge maximum distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the maximum distance an object or area can be from the area's edge
**
** @returns: the ID of the created constraint
*/
int createCliffEdgeMaxDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateCliffEdgeMaxDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates a cliff ramp constraint without needing to specify a label.
**
** @param areaID: the ID of the area of the ramp to force an object or area to be placed in
**
** @returns: the ID of the created constraint
*/
int createCliffRampConstraint(int areaID = -1) {
	constraintCount++;
	return(rmCreateCliffRampConstraint(cConstraintName + constraintCount, areaID));
}

/*
** Creates a cliff ramp distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the minimum distance an object or area can be from the area's ramp
**
** @returns: the ID of the created constraint
*/
int createCliffRampDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateCliffRampDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates a cliff ramp maximum distance constraint without needing to specify a label.
**
** @param areaID: the ID of the area
** @param dist: the maximum distance an object or area can be from the area's ramp
**
** @returns: the ID of the created constraint
*/
int createCliffRampMaxDistConstraint(int areaID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateCliffRampMaxDistanceConstraint(cConstraintName + constraintCount, areaID, dist));
}

/*
** Creates a type distance constraint without needing to specify a label.
**
** @param type: the type to create a constraint for, like "All", "Gold", "Huntable", "Chicken", ...
** @param dist: the minimum distance in meters
**
** @returns: the ID of the created constraint
*/
int createTypeDistConstraint(string type = "", float dist = 0.0) {
	constraintCount++;
	return(rmCreateTypeDistanceConstraint(cConstraintName + constraintCount, type, dist));
}

/*
** Creates a class distance constraint without needing to specify a label.
**
** @param classID: the ID of the class to avoid
** @param dist: the minimum distance in meters
**
** @returns: the ID of the created constraint
*/
int createClassDistConstraint(int classID = -1, float dist = 0.0) {
	constraintCount++;
	return(rmCreateClassDistanceConstraint(cConstraintName + constraintCount, classID, dist));
}

/*
** Creates a class distance constraint without needing to specify a label.
**
** @param type: the type of terrain to create a constraint for, like "Land"
** @param passable: whether the terrain is passable or not
** @param dist: the minimum distance in meters
**
** @returns: the ID of the created constraint
*/
int createTerrainDistConstraint(string type = "", bool passable = false, float dist = 0.0) {
	constraintCount++;
	return(rmCreateTerrainDistanceConstraint(cConstraintName + constraintCount, type, passable, dist));
}

/*
** Creates a maximum class distance constraint without needing to specify a label.
**
** @param type: the type of terrain to create a constraint for, like "Land"
** @param passable: whether the terrain is passable or not
** @param dist: the maximum distance in meters
**
** @returns: the ID of the created constraint
*/
int createTerrainMaxDistConstraint(string type = "", bool passable = false, float dist = 0.0) {
	constraintCount++;
	return(rmCreateTerrainMaxDistanceConstraint(cConstraintName + constraintCount, type, passable, dist));
}

/*********************
* OBJECT DEF UTILITY *
*********************/

/*
** Sets the min/max distance of an object at the same time.
**
** @param objectID: the ID of the object
** @param minDist: the minimum distance to set
** @param maxDist: the maximum distance to set
*/
void setObjectDefDistance(int objectID = -1, float minDist = 0.0, float maxDist = -1.0) {
	if(maxDist < 0.0) {
		maxDist = minDist;
	}

	rmSetObjectDefMinDistance(objectID, minDist);
	rmSetObjectDefMaxDistance(objectID, maxDist);
}

/*
** Sets the min/max distance from 0.0 to the edge of the map (with center offset).
** Very useful for all the embellishment that is placed at 0.5/0.5 with range [0, rmFractionToMeters(0.5)].
** Could also be done for number/distance of area blobs, but these are used a lot frequently than object definitions.
**
** @param objectID: the ID of the object
** @param minDist: the minimum distance to set
*/
void setObjectDefDistanceToMax(int objectID = -1, float minDist = 0.0) {
	rmSetObjectDefMinDistance(objectID, minDist);
	rmSetObjectDefMaxDistance(objectID, largerFractionToMeters(0.5));
}

/*************
* CORE AREAS *
*************/

int playerAreaConstraint1 = -1; int playerAreaConstraint2  = -1; int playerAreaConstraint3  = -1; int playerAreaConstraint4  = -1;
int playerAreaConstraint5 = -1; int playerAreaConstraint6  = -1; int playerAreaConstraint7  = -1; int playerAreaConstraint8  = -1;
int playerAreaConstraint9 = -1; int playerAreaConstraint10 = -1; int playerAreaConstraint11 = -1; int playerAreaConstraint12 = -1;

int getPlayerAreaConstraint(int id = -1) {
	if(id == 1) return(playerAreaConstraint1); if(id == 2)  return(playerAreaConstraint2);  if(id == 3)  return(playerAreaConstraint3);  if(id == 4)  return(playerAreaConstraint4);
	if(id == 5) return(playerAreaConstraint5); if(id == 6)  return(playerAreaConstraint6);  if(id == 7)  return(playerAreaConstraint7);  if(id == 8)  return(playerAreaConstraint8);
	if(id == 9) return(playerAreaConstraint9); if(id == 10) return(playerAreaConstraint10); if(id == 11) return(playerAreaConstraint11); if(id == 12) return(playerAreaConstraint12);
	return(-1);
}

void setPlayerAreaConstraint(int id = -1, int cID = -1) {
	if(id == 1) playerAreaConstraint1 = cID; if(id == 2)  playerAreaConstraint2  = cID; if(id == 3)  playerAreaConstraint3  = cID; if(id == 4)  playerAreaConstraint4  = cID;
	if(id == 5) playerAreaConstraint5 = cID; if(id == 6)  playerAreaConstraint6  = cID; if(id == 7)  playerAreaConstraint7  = cID; if(id == 8)  playerAreaConstraint8  = cID;
	if(id == 9) playerAreaConstraint9 = cID; if(id == 10) playerAreaConstraint10 = cID; if(id == 11) playerAreaConstraint11 = cID; if(id == 12) playerAreaConstraint12 = cID;
}

int teamAreaConstraint1 = -1; int teamAreaConstraint2  = -1; int teamAreaConstraint3  = -1; int teamAreaConstraint4  = -1;
int teamAreaConstraint5 = -1; int teamAreaConstraint6  = -1; int teamAreaConstraint7  = -1; int teamAreaConstraint8  = -1;
int teamAreaConstraint9 = -1; int teamAreaConstraint10 = -1; int teamAreaConstraint11 = -1; int teamAreaConstraint12 = -1;

int getTeamAreaConstraint(int id = 0) {
	if(id == 1) return(teamAreaConstraint1); if(id == 2)  return(teamAreaConstraint2);  if(id == 3)  return(teamAreaConstraint3);  if(id == 4)  return(teamAreaConstraint4);
	if(id == 5) return(teamAreaConstraint5); if(id == 6)  return(teamAreaConstraint6);  if(id == 7)  return(teamAreaConstraint7);  if(id == 8)  return(teamAreaConstraint8);
	if(id == 9) return(teamAreaConstraint9); if(id == 10) return(teamAreaConstraint10); if(id == 11) return(teamAreaConstraint11); if(id == 12) return(teamAreaConstraint12);
	return(-1);
}

void setTeamAreaConstraint(int id = 0, int cID = -1) {
	if(id == 1) teamAreaConstraint1 = cID; if(id == 2)  teamAreaConstraint2  = cID; if(id == 3)  teamAreaConstraint3  = cID; if(id == 4)  teamAreaConstraint4  = cID;
	if(id == 5) teamAreaConstraint5 = cID; if(id == 6)  teamAreaConstraint6  = cID; if(id == 7)  teamAreaConstraint7  = cID; if(id == 8)  teamAreaConstraint8  = cID;
	if(id == 9) teamAreaConstraint9 = cID; if(id == 10) teamAreaConstraint10 = cID; if(id == 11) teamAreaConstraint11 = cID; if(id == 12) teamAreaConstraint12 = cID;
}

/*
 * This section contains important areas.
 * Split: Divides the map into sections, one per player (imagine having every player a piece of the cake).
 * Team Split: Same as split, but the areas are for teams (for instance, with 2 teams, each team gets half the map).
 * Centerline: Uses the splits to build line(s) between the players (filling out the space "left" by the split).
 * Center: Creates a single center area.
 * Corner: Creates areas in all 4 corners.
 *
 * The last three of these are more utility than anything else, but I put them here anyway so everything is found in one place.
*/

// IDs.
int classSplit = -1;
int classTeamSplit = -1;
int classCenterline = -1;
int classCenter = -1;
int classCorner = -1;

// Run once.
bool playerAreaConstraintsInitialized = false;
bool teamAreaConstraintsInitialized = false;

/*
** Virtually splits the map into separate player areas.
**
** @param splitDist: the distance between the player areas in meters (how much the areas avoid each other)
**
** @returns: ID of classSplit
*/
int initializeSplit(float splitDist = 10.0) {
	if(classSplit != -1) {
		return(classSplit);
	}

	classSplit = rmDefineClass(cSplitClassName);

	int splitConstraint = createClassDistConstraint(classSplit, splitDist);

	for(i = 1; < cPlayers) {
		int splitID = rmCreateArea(cSplitName + " " + i);
		rmSetAreaLocPlayer(splitID, getPlayer(i));
		rmSetPlayerArea(getPlayer(i), splitID);
		rmSetAreaSize(splitID, 1.0);
		// rmSetAreaTerrainType(splitID, "HadesBuildable1");
		// rmSetAreaBaseHeight(splitID, 2.0);
		rmSetAreaCoherence(splitID, 1.0);
		rmAddAreaToClass(splitID, classSplit);
		rmAddAreaConstraint(splitID, splitConstraint);
		rmSetAreaWarnFailure(splitID, false);
	}

	rmBuildAllAreas();

	return(classSplit);
}

/*
** Virtually splits the map into separate team areas.
**
** @param teamSplitDist: the distance between the team areas in meters (how much the areas avoid each other)
**
** @returns: ID of classTeamSplit
*/
int initializeTeamSplit(float teamSplitDist = 10.0) {
	if(classTeamSplit != -1) {
		return(classTeamSplit);
	}

	classTeamSplit = rmDefineClass(cTeamSplitClassName);

	int teamSplitConstraint = createClassDistConstraint(classTeamSplit, teamSplitDist);

	for(i = 0; < cTeams) {
		int teamSplitID = rmCreateArea(cTeamSplitName + " " + i);
		rmSetTeamArea(i, teamSplitID);
		rmSetAreaLocTeam(teamSplitID, i);
		rmSetAreaSize(teamSplitID, 1.0);
		// rmSetAreaTerrainType(teamSplitID, "HadesBuildable1");
		// rmSetAreaBaseHeight(teamSplitID, 2.0);
		rmSetAreaCoherence(teamSplitID, 1.0);
		rmAddAreaToClass(teamSplitID, classTeamSplit);
		rmAddAreaConstraint(teamSplitID, teamSplitConstraint);
		rmSetAreaWarnFailure(teamSplitID, false);
	}

	rmBuildAllAreas();

	return(classTeamSplit);
}

/*
** Creates a centerline based on virtual split.
** Note that this creates player or team splits if they do not already exists, as they are needed to build the center lines.
**
** @param onPlayerSplit: whether to use the player split or not (team split used if false), will be created if not defined already
** @param splitDist: the distance between the split areas in meters (how much the areas avoid each other) used to create the splits if not defined already
**
** @returns: ID of classCenterline
*/
int initializeCenterline(bool onPlayerSplit = true, float splitDist = 10.0) {
	if(classCenterline != -1) {
		return(classCenterline);
	}

	classCenterline = rmDefineClass(cCenterlineClassName);

	int centerlineID = rmCreateArea(cCenterlineName);
	rmSetAreaSize(centerlineID, 0.4);
	// rmSetAreaTerrainType(centerlineID, "HadesBuildable1");
	// rmSetAreaBaseHeight(centerlineID, 2.0);
	rmAddAreaToClass(centerlineID, classCenterline);
	if(onPlayerSplit) {
		initializeSplit(splitDist);
		rmAddAreaConstraint(centerlineID, createClassDistConstraint(classSplit, rmXMetersToFraction(1.0)));
	} else {
		initializeTeamSplit(splitDist);
		rmAddAreaConstraint(centerlineID, createClassDistConstraint(classTeamSplit, rmXMetersToFraction(1.0)));
	}
	rmSetAreaWarnFailure(centerlineID, false);

	rmBuildArea(centerlineID);

	return(classCenterline);
}

/*
** Initializes the center class along with a center area.
**
** @param radius: radius of the center area
**
** @returns: classCenter ID
*/
int initializeCenter(float radius = 25.0) {
	if(classCenter != -1) {
		return(classCenter);
	}

	classCenter = rmDefineClass(cCenterClassName);

	int centerID = rmCreateArea(cCenterName);
	rmSetAreaSize(centerID, areaRadiusMetersToFraction(radius));
	rmSetAreaLocation(centerID, 0.5, 0.5);
	// rmSetAreaTerrainType(centerID, "HadesBuildable1");
	// rmSetAreaBaseHeight(centerID, 2.0);
	rmSetAreaCoherence(centerID, 1.0);
	rmAddAreaToClass(centerID, classCenter);
	rmSetAreaWarnFailure(centerID, false);

	rmBuildArea(centerID);

	return(classCenter);
}

/*
** Initializes the corner class along with four corner areas.
**
** @param radius: radius of the corner areas
**
** @returns: ID of classCorner
*/
int initializeCorners(float radius = 40.0) {
	if(classCorner != -1) {
		return(classCorner);
	}

	classCorner = rmDefineClass(cCornerClassName);

	int cornerID = 0;

	for(i = 0; < 4) {
		cornerID = rmCreateArea(cCornerName + " " + i);
		// Adjust size; since the area is on the corner, we only need 1/4 of the area (we can only place by area, not by radius).
		rmSetAreaSize(cornerID, areaRadiusMetersToFraction(radius) / 4.0);
		// rmSetAreaLocation(cornerID, (i % 2), min(1, (i % 3))); // (Yes this would also cover all corners.)
		if(i == 0) {
			rmSetAreaLocation(cornerID, 1.0, 1.0);
		} else if(i == 1) {
			rmSetAreaLocation(cornerID, 0.0, 1.0);
		} else if(i == 2) {
			rmSetAreaLocation(cornerID, 1.0, 0.0);
		} else if(i == 3) {
			rmSetAreaLocation(cornerID, 0.0, 0.0);
		}
		// rmSetAreaTerrainType(cornerID, "HadesBuildable1");
		// rmSetAreaBaseHeight(cornerID, 2.0);
		rmSetAreaCoherence(cornerID, 1.0);
		rmAddAreaToClass(cornerID, classCorner);
		rmSetAreaWarnFailure(cornerID, false);

		rmBuildArea(cornerID);
	}

	return(classCorner);
}

/*
** Initializes player area constraints. Calls initializeSplit() if not called previously.
**
** @param splitDist: the distance between the player areas in meters (how much the areas avoid each other) in case player splits were not yet created
*/
void initializePlayerAreaConstraints(float splitDist = 10.0) {
	if(playerAreaConstraintsInitialized) {
		return;
	}

	initializeSplit(splitDist);

	for(i = 1; < cPlayers) {
		setPlayerAreaConstraint(i, createAreaConstraint(rmAreaID(cSplitName + " " + i)));
	}

	playerAreaConstraintsInitialized = true;
}

/*
** Initializes player area constraints. Calls initializeSplit() if not called previously.
**
** @param teamSplitDist: the distance between the team areas in meters (how much the areas avoid each other)
*/
void initializeTeamAreaConstraints(float teamSplitDist = 10.0) {
	if(teamAreaConstraintsInitialized) {
		return;
	}

	initializeTeamSplit(teamSplitDist);

	for(i = 1; < cPlayers) {
		setTeamAreaConstraint(i, createAreaConstraint(rmAreaID(cTeamSplitName + " " + rmGetPlayerTeam(getPlayer(i)))));
	}

	teamAreaConstraintsInitialized = true;
}

/*
** Location storage data structure.
** RebelsRising
** Last edit: 07/03/2021
*/

// include "rmx_util.xs";

/*******************
* LOCATION STORAGE *
*******************/

/*
 * Used by regular object placement and all (objects & areas) mirrored placement.
 * Has to be enabled via enableLocStorage() to be active. Once full, any additional entries will be discarded!
 * Therefore, using disableLocStorage() is important not needing the storage anymore.
 *
 * Note that mirrored locations and objects for players are usually placed in the order of mirroring.
 * If t1p(1) means team 1 player 1, then the placement is as follows:
 *
 * Mirroring through point: t1p(1), t2p(1), t1p(2), t2p(2), ...
 * Mirroring through axis:  t1p(1), t2p(n), t1p(2), t2p(n-1), ...
 * Placing the same object multiple times will do so per mirrored player pair.
 * Example for 4 players placing twice: p1, p3, p1, p3, p2, p4, p2, p4.
*/

const int cAreaStorageSize = 64;

int locCounter = 0;
bool isStorageActive = false;

// Location X storage, starts at 1 due to often being used in combination with players.
float locX1  = -1.0; float locX2  = -1.0; float locX3  = -1.0; float locX4  = -1.0;
float locX5  = -1.0; float locX6  = -1.0; float locX7  = -1.0; float locX8  = -1.0;
float locX9  = -1.0; float locX10 = -1.0; float locX11 = -1.0; float locX12 = -1.0;
float locX13 = -1.0; float locX14 = -1.0; float locX15 = -1.0; float locX16 = -1.0;
float locX17 = -1.0; float locX18 = -1.0; float locX19 = -1.0; float locX20 = -1.0;
float locX21 = -1.0; float locX22 = -1.0; float locX23 = -1.0; float locX24 = -1.0;
float locX25 = -1.0; float locX26 = -1.0; float locX27 = -1.0; float locX28 = -1.0;
float locX29 = -1.0; float locX30 = -1.0; float locX31 = -1.0; float locX32 = -1.0;
float locX33 = -1.0; float locX34 = -1.0; float locX35 = -1.0; float locX36 = -1.0;
float locX37 = -1.0; float locX38 = -1.0; float locX39 = -1.0; float locX40 = -1.0;
float locX41 = -1.0; float locX42 = -1.0; float locX43 = -1.0; float locX44 = -1.0;
float locX45 = -1.0; float locX46 = -1.0; float locX47 = -1.0; float locX48 = -1.0;
float locX49 = -1.0; float locX50 = -1.0; float locX51 = -1.0; float locX52 = -1.0;
float locX53 = -1.0; float locX54 = -1.0; float locX55 = -1.0; float locX56 = -1.0;
float locX57 = -1.0; float locX58 = -1.0; float locX59 = -1.0; float locX60 = -1.0;
float locX61 = -1.0; float locX62 = -1.0; float locX63 = -1.0; float locX64 = -1.0;

float getLocX(int i = 0) {
	if(i == 1)  return(locX1);  if(i == 2)  return(locX2);  if(i == 3)  return(locX3);  if(i == 4)  return(locX4);
	if(i == 5)  return(locX5);  if(i == 6)  return(locX6);  if(i == 7)  return(locX7);  if(i == 8)  return(locX8);
	if(i == 9)  return(locX9);  if(i == 10) return(locX10); if(i == 11) return(locX11); if(i == 12) return(locX12);
	if(i == 13) return(locX13); if(i == 14) return(locX14); if(i == 15) return(locX15); if(i == 16) return(locX16);
	if(i == 17) return(locX17); if(i == 18) return(locX18); if(i == 19) return(locX19); if(i == 20) return(locX20);
	if(i == 21) return(locX21); if(i == 22) return(locX22); if(i == 23) return(locX23); if(i == 24) return(locX24);
	if(i == 25) return(locX25); if(i == 26) return(locX26); if(i == 27) return(locX27); if(i == 28) return(locX28);
	if(i == 29) return(locX29); if(i == 30) return(locX30); if(i == 31) return(locX31); if(i == 32) return(locX32);
	if(i == 33) return(locX33); if(i == 34) return(locX34); if(i == 35) return(locX35); if(i == 36) return(locX36);
	if(i == 37) return(locX37); if(i == 38) return(locX38); if(i == 39) return(locX39); if(i == 40) return(locX40);
	if(i == 41) return(locX41); if(i == 42) return(locX42); if(i == 43) return(locX43); if(i == 44) return(locX44);
	if(i == 45) return(locX45); if(i == 46) return(locX46); if(i == 47) return(locX47); if(i == 48) return(locX48);
	if(i == 49) return(locX49); if(i == 50) return(locX50); if(i == 51) return(locX51); if(i == 52) return(locX52);
	if(i == 53) return(locX53); if(i == 54) return(locX54); if(i == 55) return(locX55); if(i == 56) return(locX56);
	if(i == 57) return(locX57); if(i == 58) return(locX58); if(i == 59) return(locX59); if(i == 60) return(locX60);
	if(i == 61) return(locX61); if(i == 62) return(locX62); if(i == 63) return(locX63); if(i == 64) return(locX64);
	return(-1.0);
}

float setLocX(int i = 0, float val = -1.0) {
	if(i == 1)  locX1  = val; if(i == 2)  locX2  = val; if(i == 3)  locX3  = val; if(i == 4)  locX4  = val;
	if(i == 5)  locX5  = val; if(i == 6)  locX6  = val; if(i == 7)  locX7  = val; if(i == 8)  locX8  = val;
	if(i == 9)  locX9  = val; if(i == 10) locX10 = val; if(i == 11) locX11 = val; if(i == 12) locX12 = val;
	if(i == 13) locX13 = val; if(i == 14) locX14 = val; if(i == 15) locX15 = val; if(i == 16) locX16 = val;
	if(i == 17) locX17 = val; if(i == 18) locX18 = val; if(i == 19) locX19 = val; if(i == 20) locX20 = val;
	if(i == 21) locX21 = val; if(i == 22) locX22 = val; if(i == 23) locX23 = val; if(i == 24) locX24 = val;
	if(i == 25) locX25 = val; if(i == 26) locX26 = val; if(i == 27) locX27 = val; if(i == 28) locX28 = val;
	if(i == 29) locX29 = val; if(i == 30) locX30 = val; if(i == 31) locX31 = val; if(i == 32) locX32 = val;
	if(i == 33) locX33 = val; if(i == 34) locX34 = val; if(i == 35) locX35 = val; if(i == 36) locX36 = val;
	if(i == 37) locX37 = val; if(i == 38) locX38 = val; if(i == 39) locX39 = val; if(i == 40) locX40 = val;
	if(i == 41) locX41 = val; if(i == 42) locX42 = val; if(i == 43) locX43 = val; if(i == 44) locX44 = val;
	if(i == 45) locX45 = val; if(i == 46) locX46 = val; if(i == 47) locX47 = val; if(i == 48) locX48 = val;
	if(i == 49) locX49 = val; if(i == 50) locX50 = val; if(i == 51) locX51 = val; if(i == 52) locX52 = val;
	if(i == 53) locX53 = val; if(i == 54) locX54 = val; if(i == 55) locX55 = val; if(i == 56) locX56 = val;
	if(i == 57) locX57 = val; if(i == 58) locX58 = val; if(i == 59) locX59 = val; if(i == 60) locX60 = val;
	if(i == 61) locX61 = val; if(i == 62) locX62 = val; if(i == 63) locX63 = val; if(i == 64) locX64 = val;
}

// Location Z storage, starts at 1 due to often being used in combination with players.
float locZ1  = -1.0; float locZ2  = -1.0; float locZ3  = -1.0; float locZ4  = -1.0;
float locZ5  = -1.0; float locZ6  = -1.0; float locZ7  = -1.0; float locZ8  = -1.0;
float locZ9  = -1.0; float locZ10 = -1.0; float locZ11 = -1.0; float locZ12 = -1.0;
float locZ13 = -1.0; float locZ14 = -1.0; float locZ15 = -1.0; float locZ16 = -1.0;
float locZ17 = -1.0; float locZ18 = -1.0; float locZ19 = -1.0; float locZ20 = -1.0;
float locZ21 = -1.0; float locZ22 = -1.0; float locZ23 = -1.0; float locZ24 = -1.0;
float locZ25 = -1.0; float locZ26 = -1.0; float locZ27 = -1.0; float locZ28 = -1.0;
float locZ29 = -1.0; float locZ30 = -1.0; float locZ31 = -1.0; float locZ32 = -1.0;
float locZ33 = -1.0; float locZ34 = -1.0; float locZ35 = -1.0; float locZ36 = -1.0;
float locZ37 = -1.0; float locZ38 = -1.0; float locZ39 = -1.0; float locZ40 = -1.0;
float locZ41 = -1.0; float locZ42 = -1.0; float locZ43 = -1.0; float locZ44 = -1.0;
float locZ45 = -1.0; float locZ46 = -1.0; float locZ47 = -1.0; float locZ48 = -1.0;
float locZ49 = -1.0; float locZ50 = -1.0; float locZ51 = -1.0; float locZ52 = -1.0;
float locZ53 = -1.0; float locZ54 = -1.0; float locZ55 = -1.0; float locZ56 = -1.0;
float locZ57 = -1.0; float locZ58 = -1.0; float locZ59 = -1.0; float locZ60 = -1.0;
float locZ61 = -1.0; float locZ62 = -1.0; float locZ63 = -1.0; float locZ64 = -1.0;

float getLocZ(int i = 0) {
	if(i == 1)  return(locZ1);  if(i == 2)  return(locZ2);  if(i == 3)  return(locZ3);  if(i == 4)  return(locZ4);
	if(i == 5)  return(locZ5);  if(i == 6)  return(locZ6);  if(i == 7)  return(locZ7);  if(i == 8)  return(locZ8);
	if(i == 9)  return(locZ9);  if(i == 10) return(locZ10); if(i == 11) return(locZ11); if(i == 12) return(locZ12);
	if(i == 13) return(locZ13); if(i == 14) return(locZ14); if(i == 15) return(locZ15); if(i == 16) return(locZ16);
	if(i == 17) return(locZ17); if(i == 18) return(locZ18); if(i == 19) return(locZ19); if(i == 20) return(locZ20);
	if(i == 21) return(locZ21); if(i == 22) return(locZ22); if(i == 23) return(locZ23); if(i == 24) return(locZ24);
	if(i == 25) return(locZ25); if(i == 26) return(locZ26); if(i == 27) return(locZ27); if(i == 28) return(locZ28);
	if(i == 29) return(locZ29); if(i == 30) return(locZ30); if(i == 31) return(locZ31); if(i == 32) return(locZ32);
	if(i == 33) return(locZ33); if(i == 34) return(locZ34); if(i == 35) return(locZ35); if(i == 36) return(locZ36);
	if(i == 37) return(locZ37); if(i == 38) return(locZ38); if(i == 39) return(locZ39); if(i == 40) return(locZ40);
	if(i == 41) return(locZ41); if(i == 42) return(locZ42); if(i == 43) return(locZ43); if(i == 44) return(locZ44);
	if(i == 45) return(locZ45); if(i == 46) return(locZ46); if(i == 47) return(locZ47); if(i == 48) return(locZ48);
	if(i == 49) return(locZ49); if(i == 50) return(locZ50); if(i == 51) return(locZ51); if(i == 52) return(locZ52);
	if(i == 53) return(locZ53); if(i == 54) return(locZ54); if(i == 55) return(locZ55); if(i == 56) return(locZ56);
	if(i == 57) return(locZ57); if(i == 58) return(locZ58); if(i == 59) return(locZ59); if(i == 60) return(locZ60);
	if(i == 61) return(locZ61); if(i == 62) return(locZ62); if(i == 63) return(locZ63); if(i == 64) return(locZ64);
	return(-1.0);
}

float setLocZ(int i = 0, float val = -1.0) {
	if(i == 1)  locZ1  = val; if(i == 2)  locZ2  = val; if(i == 3)  locZ3  = val; if(i == 4)  locZ4  = val;
	if(i == 5)  locZ5  = val; if(i == 6)  locZ6  = val; if(i == 7)  locZ7  = val; if(i == 8)  locZ8  = val;
	if(i == 9)  locZ9  = val; if(i == 10) locZ10 = val; if(i == 11) locZ11 = val; if(i == 12) locZ12 = val;
	if(i == 13) locZ13 = val; if(i == 14) locZ14 = val; if(i == 15) locZ15 = val; if(i == 16) locZ16 = val;
	if(i == 17) locZ17 = val; if(i == 18) locZ18 = val; if(i == 19) locZ19 = val; if(i == 20) locZ20 = val;
	if(i == 21) locZ21 = val; if(i == 22) locZ22 = val; if(i == 23) locZ23 = val; if(i == 24) locZ24 = val;
	if(i == 25) locZ25 = val; if(i == 26) locZ26 = val; if(i == 27) locZ27 = val; if(i == 28) locZ28 = val;
	if(i == 29) locZ29 = val; if(i == 30) locZ30 = val; if(i == 31) locZ31 = val; if(i == 32) locZ32 = val;
	if(i == 33) locZ33 = val; if(i == 34) locZ34 = val; if(i == 35) locZ35 = val; if(i == 36) locZ36 = val;
	if(i == 37) locZ37 = val; if(i == 38) locZ38 = val; if(i == 39) locZ39 = val; if(i == 40) locZ40 = val;
	if(i == 41) locZ41 = val; if(i == 42) locZ42 = val; if(i == 43) locZ43 = val; if(i == 44) locZ44 = val;
	if(i == 45) locZ45 = val; if(i == 46) locZ46 = val; if(i == 47) locZ47 = val; if(i == 48) locZ48 = val;
	if(i == 49) locZ49 = val; if(i == 50) locZ50 = val; if(i == 51) locZ51 = val; if(i == 52) locZ52 = val;
	if(i == 53) locZ53 = val; if(i == 54) locZ54 = val; if(i == 55) locZ55 = val; if(i == 56) locZ56 = val;
	if(i == 57) locZ57 = val; if(i == 58) locZ58 = val; if(i == 59) locZ59 = val; if(i == 60) locZ60 = val;
	if(i == 61) locZ61 = val; if(i == 62) locZ62 = val; if(i == 63) locZ63 = val; if(i == 64) locZ64 = val;
}

// Location owner storage, starts at 1 due to often being used in combination with players.
int locOwner1  = 0; int locOwner2  = 0; int locOwner3  = 0; int locOwner4  = 0;
int locOwner5  = 0; int locOwner6  = 0; int locOwner7  = 0; int locOwner8  = 0;
int locOwner9  = 0; int locOwner10 = 0; int locOwner11 = 0; int locOwner12 = 0;
int locOwner13 = 0; int locOwner14 = 0; int locOwner15 = 0; int locOwner16 = 0;
int locOwner17 = 0; int locOwner18 = 0; int locOwner19 = 0; int locOwner20 = 0;
int locOwner21 = 0; int locOwner22 = 0; int locOwner23 = 0; int locOwner24 = 0;
int locOwner25 = 0; int locOwner26 = 0; int locOwner27 = 0; int locOwner28 = 0;
int locOwner29 = 0; int locOwner30 = 0; int locOwner31 = 0; int locOwner32 = 0;
int locOwner33 = 0; int locOwner34 = 0; int locOwner35 = 0; int locOwner36 = 0;
int locOwner37 = 0; int locOwner38 = 0; int locOwner39 = 0; int locOwner40 = 0;
int locOwner41 = 0; int locOwner42 = 0; int locOwner43 = 0; int locOwner44 = 0;
int locOwner45 = 0; int locOwner46 = 0; int locOwner47 = 0; int locOwner48 = 0;
int locOwner49 = 0; int locOwner50 = 0; int locOwner51 = 0; int locOwner52 = 0;
int locOwner53 = 0; int locOwner54 = 0; int locOwner55 = 0; int locOwner56 = 0;
int locOwner57 = 0; int locOwner58 = 0; int locOwner59 = 0; int locOwner60 = 0;
int locOwner61 = 0; int locOwner62 = 0; int locOwner63 = 0; int locOwner64 = 0;

int getLocOwner(int i = 0) {
	if(i == 1)  return(locOwner1);  if(i == 2)  return(locOwner2);  if(i == 3)  return(locOwner3);  if(i == 4)  return(locOwner4);
	if(i == 5)  return(locOwner5);  if(i == 6)  return(locOwner6);  if(i == 7)  return(locOwner7);  if(i == 8)  return(locOwner8);
	if(i == 9)  return(locOwner9);  if(i == 10) return(locOwner10); if(i == 11) return(locOwner11); if(i == 12) return(locOwner12);
	if(i == 13) return(locOwner13); if(i == 14) return(locOwner14); if(i == 15) return(locOwner15); if(i == 16) return(locOwner16);
	if(i == 17) return(locOwner17); if(i == 18) return(locOwner18); if(i == 19) return(locOwner19); if(i == 20) return(locOwner20);
	if(i == 21) return(locOwner21); if(i == 22) return(locOwner22); if(i == 23) return(locOwner23); if(i == 24) return(locOwner24);
	if(i == 25) return(locOwner25); if(i == 26) return(locOwner26); if(i == 27) return(locOwner27); if(i == 28) return(locOwner28);
	if(i == 29) return(locOwner29); if(i == 30) return(locOwner30); if(i == 31) return(locOwner31); if(i == 32) return(locOwner32);
	if(i == 33) return(locOwner33); if(i == 34) return(locOwner34); if(i == 35) return(locOwner35); if(i == 36) return(locOwner36);
	if(i == 37) return(locOwner37); if(i == 38) return(locOwner38); if(i == 39) return(locOwner39); if(i == 40) return(locOwner40);
	if(i == 41) return(locOwner41); if(i == 42) return(locOwner42); if(i == 43) return(locOwner43); if(i == 44) return(locOwner44);
	if(i == 45) return(locOwner45); if(i == 46) return(locOwner46); if(i == 47) return(locOwner47); if(i == 48) return(locOwner48);
	if(i == 49) return(locOwner49); if(i == 50) return(locOwner50); if(i == 51) return(locOwner51); if(i == 52) return(locOwner52);
	if(i == 53) return(locOwner53); if(i == 54) return(locOwner54); if(i == 55) return(locOwner55); if(i == 56) return(locOwner56);
	if(i == 57) return(locOwner57); if(i == 58) return(locOwner58); if(i == 59) return(locOwner59); if(i == 60) return(locOwner60);
	if(i == 61) return(locOwner61); if(i == 62) return(locOwner62); if(i == 63) return(locOwner63); if(i == 64) return(locOwner64);
	return(0);
}

int setLocOwner(int i = 0, int o = 0) {
	if(i == 1)  locOwner1  = o; if(i == 2)  locOwner2  = o; if(i == 3)  locOwner3  = o; if(i == 4)  locOwner4  = o;
	if(i == 5)  locOwner5  = o; if(i == 6)  locOwner6  = o; if(i == 7)  locOwner7  = o; if(i == 8)  locOwner8  = o;
	if(i == 9)  locOwner9  = o; if(i == 10) locOwner10 = o; if(i == 11) locOwner11 = o; if(i == 12) locOwner12 = o;
	if(i == 13) locOwner13 = o; if(i == 14) locOwner14 = o; if(i == 15) locOwner15 = o; if(i == 16) locOwner16 = o;
	if(i == 17) locOwner17 = o; if(i == 18) locOwner18 = o; if(i == 19) locOwner19 = o; if(i == 20) locOwner20 = o;
	if(i == 21) locOwner21 = o; if(i == 22) locOwner22 = o; if(i == 23) locOwner23 = o; if(i == 24) locOwner24 = o;
	if(i == 25) locOwner25 = o; if(i == 26) locOwner26 = o; if(i == 27) locOwner27 = o; if(i == 28) locOwner28 = o;
	if(i == 29) locOwner29 = o; if(i == 30) locOwner30 = o; if(i == 31) locOwner31 = o; if(i == 32) locOwner32 = o;
	if(i == 33) locOwner33 = o; if(i == 34) locOwner34 = o; if(i == 35) locOwner35 = o; if(i == 36) locOwner36 = o;
	if(i == 37) locOwner37 = o; if(i == 38) locOwner38 = o; if(i == 39) locOwner39 = o; if(i == 40) locOwner40 = o;
	if(i == 41) locOwner41 = o; if(i == 42) locOwner42 = o; if(i == 43) locOwner43 = o; if(i == 44) locOwner44 = o;
	if(i == 45) locOwner45 = o; if(i == 46) locOwner46 = o; if(i == 47) locOwner47 = o; if(i == 48) locOwner48 = o;
	if(i == 49) locOwner49 = o; if(i == 50) locOwner50 = o; if(i == 51) locOwner51 = o; if(i == 52) locOwner52 = o;
	if(i == 53) locOwner53 = o; if(i == 54) locOwner54 = o; if(i == 55) locOwner55 = o; if(i == 56) locOwner56 = o;
	if(i == 57) locOwner57 = o; if(i == 58) locOwner58 = o; if(i == 59) locOwner59 = o; if(i == 60) locOwner60 = o;
	if(i == 61) locOwner61 = o; if(i == 62) locOwner62 = o; if(i == 63) locOwner63 = o; if(i == 64) locOwner64 = o;
}

// Location X backup storage, starts at 1 due to often being used in combination with players.
float locBackupX1  = -1.0; float locBackupX2  = -1.0; float locBackupX3  = -1.0; float locBackupX4  = -1.0;
float locBackupX5  = -1.0; float locBackupX6  = -1.0; float locBackupX7  = -1.0; float locBackupX8  = -1.0;
float locBackupX9  = -1.0; float locBackupX10 = -1.0; float locBackupX11 = -1.0; float locBackupX12 = -1.0;
float locBackupX13 = -1.0; float locBackupX14 = -1.0; float locBackupX15 = -1.0; float locBackupX16 = -1.0;
float locBackupX17 = -1.0; float locBackupX18 = -1.0; float locBackupX19 = -1.0; float locBackupX20 = -1.0;
float locBackupX21 = -1.0; float locBackupX22 = -1.0; float locBackupX23 = -1.0; float locBackupX24 = -1.0;
float locBackupX25 = -1.0; float locBackupX26 = -1.0; float locBackupX27 = -1.0; float locBackupX28 = -1.0;
float locBackupX29 = -1.0; float locBackupX30 = -1.0; float locBackupX31 = -1.0; float locBackupX32 = -1.0;
float locBackupX33 = -1.0; float locBackupX34 = -1.0; float locBackupX35 = -1.0; float locBackupX36 = -1.0;
float locBackupX37 = -1.0; float locBackupX38 = -1.0; float locBackupX39 = -1.0; float locBackupX40 = -1.0;
float locBackupX41 = -1.0; float locBackupX42 = -1.0; float locBackupX43 = -1.0; float locBackupX44 = -1.0;
float locBackupX45 = -1.0; float locBackupX46 = -1.0; float locBackupX47 = -1.0; float locBackupX48 = -1.0;
float locBackupX49 = -1.0; float locBackupX50 = -1.0; float locBackupX51 = -1.0; float locBackupX52 = -1.0;
float locBackupX53 = -1.0; float locBackupX54 = -1.0; float locBackupX55 = -1.0; float locBackupX56 = -1.0;
float locBackupX57 = -1.0; float locBackupX58 = -1.0; float locBackupX59 = -1.0; float locBackupX60 = -1.0;
float locBackupX61 = -1.0; float locBackupX62 = -1.0; float locBackupX63 = -1.0; float locBackupX64 = -1.0;

float getLocBackupX(int i = 0) {
	if(i == 1)  return(locBackupX1);  if(i == 2)  return(locBackupX2);  if(i == 3)  return(locBackupX3);  if(i == 4)  return(locBackupX4);
	if(i == 5)  return(locBackupX5);  if(i == 6)  return(locBackupX6);  if(i == 7)  return(locBackupX7);  if(i == 8)  return(locBackupX8);
	if(i == 9)  return(locBackupX9);  if(i == 10) return(locBackupX10); if(i == 11) return(locBackupX11); if(i == 12) return(locBackupX12);
	if(i == 13) return(locBackupX13); if(i == 14) return(locBackupX14); if(i == 15) return(locBackupX15); if(i == 16) return(locBackupX16);
	if(i == 17) return(locBackupX17); if(i == 18) return(locBackupX18); if(i == 19) return(locBackupX19); if(i == 20) return(locBackupX20);
	if(i == 21) return(locBackupX21); if(i == 22) return(locBackupX22); if(i == 23) return(locBackupX23); if(i == 24) return(locBackupX24);
	if(i == 25) return(locBackupX25); if(i == 26) return(locBackupX26); if(i == 27) return(locBackupX27); if(i == 28) return(locBackupX28);
	if(i == 29) return(locBackupX29); if(i == 30) return(locBackupX30); if(i == 31) return(locBackupX31); if(i == 32) return(locBackupX32);
	if(i == 33) return(locBackupX33); if(i == 34) return(locBackupX34); if(i == 35) return(locBackupX35); if(i == 36) return(locBackupX36);
	if(i == 37) return(locBackupX37); if(i == 38) return(locBackupX38); if(i == 39) return(locBackupX39); if(i == 40) return(locBackupX40);
	if(i == 41) return(locBackupX41); if(i == 42) return(locBackupX42); if(i == 43) return(locBackupX43); if(i == 44) return(locBackupX44);
	if(i == 45) return(locBackupX45); if(i == 46) return(locBackupX46); if(i == 47) return(locBackupX47); if(i == 48) return(locBackupX48);
	if(i == 49) return(locBackupX49); if(i == 50) return(locBackupX50); if(i == 51) return(locBackupX51); if(i == 52) return(locBackupX52);
	if(i == 53) return(locBackupX53); if(i == 54) return(locBackupX54); if(i == 55) return(locBackupX55); if(i == 56) return(locBackupX56);
	if(i == 57) return(locBackupX57); if(i == 58) return(locBackupX58); if(i == 59) return(locBackupX59); if(i == 60) return(locBackupX60);
	if(i == 61) return(locBackupX61); if(i == 62) return(locBackupX62); if(i == 63) return(locBackupX63); if(i == 64) return(locBackupX64);
	return(-1.0);
}

float setLocBackupX(int i = 0, float val = -1.0) {
	if(i == 1)  locBackupX1  = val; if(i == 2)  locBackupX2  = val; if(i == 3)  locBackupX3  = val; if(i == 4)  locBackupX4  = val;
	if(i == 5)  locBackupX5  = val; if(i == 6)  locBackupX6  = val; if(i == 7)  locBackupX7  = val; if(i == 8)  locBackupX8  = val;
	if(i == 9)  locBackupX9  = val; if(i == 10) locBackupX10 = val; if(i == 11) locBackupX11 = val; if(i == 12) locBackupX12 = val;
	if(i == 13) locBackupX13 = val; if(i == 14) locBackupX14 = val; if(i == 15) locBackupX15 = val; if(i == 16) locBackupX16 = val;
	if(i == 17) locBackupX17 = val; if(i == 18) locBackupX18 = val; if(i == 19) locBackupX19 = val; if(i == 20) locBackupX20 = val;
	if(i == 21) locBackupX21 = val; if(i == 22) locBackupX22 = val; if(i == 23) locBackupX23 = val; if(i == 24) locBackupX24 = val;
	if(i == 25) locBackupX25 = val; if(i == 26) locBackupX26 = val; if(i == 27) locBackupX27 = val; if(i == 28) locBackupX28 = val;
	if(i == 29) locBackupX29 = val; if(i == 30) locBackupX30 = val; if(i == 31) locBackupX31 = val; if(i == 32) locBackupX32 = val;
	if(i == 33) locBackupX33 = val; if(i == 34) locBackupX34 = val; if(i == 35) locBackupX35 = val; if(i == 36) locBackupX36 = val;
	if(i == 37) locBackupX37 = val; if(i == 38) locBackupX38 = val; if(i == 39) locBackupX39 = val; if(i == 40) locBackupX40 = val;
	if(i == 41) locBackupX41 = val; if(i == 42) locBackupX42 = val; if(i == 43) locBackupX43 = val; if(i == 44) locBackupX44 = val;
	if(i == 45) locBackupX45 = val; if(i == 46) locBackupX46 = val; if(i == 47) locBackupX47 = val; if(i == 48) locBackupX48 = val;
	if(i == 49) locBackupX49 = val; if(i == 50) locBackupX50 = val; if(i == 51) locBackupX51 = val; if(i == 52) locBackupX52 = val;
	if(i == 53) locBackupX53 = val; if(i == 54) locBackupX54 = val; if(i == 55) locBackupX55 = val; if(i == 56) locBackupX56 = val;
	if(i == 57) locBackupX57 = val; if(i == 58) locBackupX58 = val; if(i == 59) locBackupX59 = val; if(i == 60) locBackupX60 = val;
	if(i == 61) locBackupX61 = val; if(i == 62) locBackupX62 = val; if(i == 63) locBackupX63 = val; if(i == 64) locBackupX64 = val;
}

// LocationZ backup storage, starts at 1 due to often being used in combination with players.
float locBackupZ1  = -1.0; float locBackupZ2  = -1.0; float locBackupZ3  = -1.0; float locBackupZ4  = -1.0;
float locBackupZ5  = -1.0; float locBackupZ6  = -1.0; float locBackupZ7  = -1.0; float locBackupZ8  = -1.0;
float locBackupZ9  = -1.0; float locBackupZ10 = -1.0; float locBackupZ11 = -1.0; float locBackupZ12 = -1.0;
float locBackupZ13 = -1.0; float locBackupZ14 = -1.0; float locBackupZ15 = -1.0; float locBackupZ16 = -1.0;
float locBackupZ17 = -1.0; float locBackupZ18 = -1.0; float locBackupZ19 = -1.0; float locBackupZ20 = -1.0;
float locBackupZ21 = -1.0; float locBackupZ22 = -1.0; float locBackupZ23 = -1.0; float locBackupZ24 = -1.0;
float locBackupZ25 = -1.0; float locBackupZ26 = -1.0; float locBackupZ27 = -1.0; float locBackupZ28 = -1.0;
float locBackupZ29 = -1.0; float locBackupZ30 = -1.0; float locBackupZ31 = -1.0; float locBackupZ32 = -1.0;
float locBackupZ33 = -1.0; float locBackupZ34 = -1.0; float locBackupZ35 = -1.0; float locBackupZ36 = -1.0;
float locBackupZ37 = -1.0; float locBackupZ38 = -1.0; float locBackupZ39 = -1.0; float locBackupZ40 = -1.0;
float locBackupZ41 = -1.0; float locBackupZ42 = -1.0; float locBackupZ43 = -1.0; float locBackupZ44 = -1.0;
float locBackupZ45 = -1.0; float locBackupZ46 = -1.0; float locBackupZ47 = -1.0; float locBackupZ48 = -1.0;
float locBackupZ49 = -1.0; float locBackupZ50 = -1.0; float locBackupZ51 = -1.0; float locBackupZ52 = -1.0;
float locBackupZ53 = -1.0; float locBackupZ54 = -1.0; float locBackupZ55 = -1.0; float locBackupZ56 = -1.0;
float locBackupZ57 = -1.0; float locBackupZ58 = -1.0; float locBackupZ59 = -1.0; float locBackupZ60 = -1.0;
float locBackupZ61 = -1.0; float locBackupZ62 = -1.0; float locBackupZ63 = -1.0; float locBackupZ64 = -1.0;

float getLocBackupZ(int i = 0) {
	if(i == 1)  return(locBackupZ1);  if(i == 2)  return(locBackupZ2);  if(i == 3)  return(locBackupZ3);  if(i == 4)  return(locBackupZ4);
	if(i == 5)  return(locBackupZ5);  if(i == 6)  return(locBackupZ6);  if(i == 7)  return(locBackupZ7);  if(i == 8)  return(locBackupZ8);
	if(i == 9)  return(locBackupZ9);  if(i == 10) return(locBackupZ10); if(i == 11) return(locBackupZ11); if(i == 12) return(locBackupZ12);
	if(i == 13) return(locBackupZ13); if(i == 14) return(locBackupZ14); if(i == 15) return(locBackupZ15); if(i == 16) return(locBackupZ16);
	if(i == 17) return(locBackupZ17); if(i == 18) return(locBackupZ18); if(i == 19) return(locBackupZ19); if(i == 20) return(locBackupZ20);
	if(i == 21) return(locBackupZ21); if(i == 22) return(locBackupZ22); if(i == 23) return(locBackupZ23); if(i == 24) return(locBackupZ24);
	if(i == 25) return(locBackupZ25); if(i == 26) return(locBackupZ26); if(i == 27) return(locBackupZ27); if(i == 28) return(locBackupZ28);
	if(i == 29) return(locBackupZ29); if(i == 30) return(locBackupZ30); if(i == 31) return(locBackupZ31); if(i == 32) return(locBackupZ32);
	if(i == 33) return(locBackupZ33); if(i == 34) return(locBackupZ34); if(i == 35) return(locBackupZ35); if(i == 36) return(locBackupZ36);
	if(i == 37) return(locBackupZ37); if(i == 38) return(locBackupZ38); if(i == 39) return(locBackupZ39); if(i == 40) return(locBackupZ40);
	if(i == 41) return(locBackupZ41); if(i == 42) return(locBackupZ42); if(i == 43) return(locBackupZ43); if(i == 44) return(locBackupZ44);
	if(i == 45) return(locBackupZ45); if(i == 46) return(locBackupZ46); if(i == 47) return(locBackupZ47); if(i == 48) return(locBackupZ48);
	if(i == 49) return(locBackupZ49); if(i == 50) return(locBackupZ50); if(i == 51) return(locBackupZ51); if(i == 52) return(locBackupZ52);
	if(i == 53) return(locBackupZ53); if(i == 54) return(locBackupZ54); if(i == 55) return(locBackupZ55); if(i == 56) return(locBackupZ56);
	if(i == 57) return(locBackupZ57); if(i == 58) return(locBackupZ58); if(i == 59) return(locBackupZ59); if(i == 60) return(locBackupZ60);
	if(i == 61) return(locBackupZ61); if(i == 62) return(locBackupZ62); if(i == 63) return(locBackupZ63); if(i == 64) return(locBackupZ64);
	return(-1.0);
}

float setLocBackupZ(int i = 0, float val = -1.0) {
	if(i == 1)  locBackupZ1  = val; if(i == 2)  locBackupZ2  = val; if(i == 3)  locBackupZ3  = val; if(i == 4)  locBackupZ4  = val;
	if(i == 5)  locBackupZ5  = val; if(i == 6)  locBackupZ6  = val; if(i == 7)  locBackupZ7  = val; if(i == 8)  locBackupZ8  = val;
	if(i == 9)  locBackupZ9  = val; if(i == 10) locBackupZ10 = val; if(i == 11) locBackupZ11 = val; if(i == 12) locBackupZ12 = val;
	if(i == 13) locBackupZ13 = val; if(i == 14) locBackupZ14 = val; if(i == 15) locBackupZ15 = val; if(i == 16) locBackupZ16 = val;
	if(i == 17) locBackupZ17 = val; if(i == 18) locBackupZ18 = val; if(i == 19) locBackupZ19 = val; if(i == 20) locBackupZ20 = val;
	if(i == 21) locBackupZ21 = val; if(i == 22) locBackupZ22 = val; if(i == 23) locBackupZ23 = val; if(i == 24) locBackupZ24 = val;
	if(i == 25) locBackupZ25 = val; if(i == 26) locBackupZ26 = val; if(i == 27) locBackupZ27 = val; if(i == 28) locBackupZ28 = val;
	if(i == 29) locBackupZ29 = val; if(i == 30) locBackupZ30 = val; if(i == 31) locBackupZ31 = val; if(i == 32) locBackupZ32 = val;
	if(i == 33) locBackupZ33 = val; if(i == 34) locBackupZ34 = val; if(i == 35) locBackupZ35 = val; if(i == 36) locBackupZ36 = val;
	if(i == 37) locBackupZ37 = val; if(i == 38) locBackupZ38 = val; if(i == 39) locBackupZ39 = val; if(i == 40) locBackupZ40 = val;
	if(i == 41) locBackupZ41 = val; if(i == 42) locBackupZ42 = val; if(i == 43) locBackupZ43 = val; if(i == 44) locBackupZ44 = val;
	if(i == 45) locBackupZ45 = val; if(i == 46) locBackupZ46 = val; if(i == 47) locBackupZ47 = val; if(i == 48) locBackupZ48 = val;
	if(i == 49) locBackupZ49 = val; if(i == 50) locBackupZ50 = val; if(i == 51) locBackupZ51 = val; if(i == 52) locBackupZ52 = val;
	if(i == 53) locBackupZ53 = val; if(i == 54) locBackupZ54 = val; if(i == 55) locBackupZ55 = val; if(i == 56) locBackupZ56 = val;
	if(i == 57) locBackupZ57 = val; if(i == 58) locBackupZ58 = val; if(i == 59) locBackupZ59 = val; if(i == 60) locBackupZ60 = val;
	if(i == 61) locBackupZ61 = val; if(i == 62) locBackupZ62 = val; if(i == 63) locBackupZ63 = val; if(i == 64) locBackupZ64 = val;
}

// Location owner storage, starts at 1 due to often being used in combination with players.
int locBackupOwner1  = 0; int locBackupOwner2  = 0; int locBackupOwner3  = 0; int locBackupOwner4  = 0;
int locBackupOwner5  = 0; int locBackupOwner6  = 0; int locBackupOwner7  = 0; int locBackupOwner8  = 0;
int locBackupOwner9  = 0; int locBackupOwner10 = 0; int locBackupOwner11 = 0; int locBackupOwner12 = 0;
int locBackupOwner13 = 0; int locBackupOwner14 = 0; int locBackupOwner15 = 0; int locBackupOwner16 = 0;
int locBackupOwner17 = 0; int locBackupOwner18 = 0; int locBackupOwner19 = 0; int locBackupOwner20 = 0;
int locBackupOwner21 = 0; int locBackupOwner22 = 0; int locBackupOwner23 = 0; int locBackupOwner24 = 0;
int locBackupOwner25 = 0; int locBackupOwner26 = 0; int locBackupOwner27 = 0; int locBackupOwner28 = 0;
int locBackupOwner29 = 0; int locBackupOwner30 = 0; int locBackupOwner31 = 0; int locBackupOwner32 = 0;
int locBackupOwner33 = 0; int locBackupOwner34 = 0; int locBackupOwner35 = 0; int locBackupOwner36 = 0;
int locBackupOwner37 = 0; int locBackupOwner38 = 0; int locBackupOwner39 = 0; int locBackupOwner40 = 0;
int locBackupOwner41 = 0; int locBackupOwner42 = 0; int locBackupOwner43 = 0; int locBackupOwner44 = 0;
int locBackupOwner45 = 0; int locBackupOwner46 = 0; int locBackupOwner47 = 0; int locBackupOwner48 = 0;
int locBackupOwner49 = 0; int locBackupOwner50 = 0; int locBackupOwner51 = 0; int locBackupOwner52 = 0;
int locBackupOwner53 = 0; int locBackupOwner54 = 0; int locBackupOwner55 = 0; int locBackupOwner56 = 0;
int locBackupOwner57 = 0; int locBackupOwner58 = 0; int locBackupOwner59 = 0; int locBackupOwner60 = 0;
int locBackupOwner61 = 0; int locBackupOwner62 = 0; int locBackupOwner63 = 0; int locBackupOwner64 = 0;

int getLocBackupOwner(int i = 0) {
	if(i == 1)  return(locBackupOwner1);  if(i == 2)  return(locBackupOwner2);  if(i == 3)  return(locBackupOwner3);  if(i == 4)  return(locBackupOwner4);
	if(i == 5)  return(locBackupOwner5);  if(i == 6)  return(locBackupOwner6);  if(i == 7)  return(locBackupOwner7);  if(i == 8)  return(locBackupOwner8);
	if(i == 9)  return(locBackupOwner9);  if(i == 10) return(locBackupOwner10); if(i == 11) return(locBackupOwner11); if(i == 12) return(locBackupOwner12);
	if(i == 13) return(locBackupOwner13); if(i == 14) return(locBackupOwner14); if(i == 15) return(locBackupOwner15); if(i == 16) return(locBackupOwner16);
	if(i == 17) return(locBackupOwner17); if(i == 18) return(locBackupOwner18); if(i == 19) return(locBackupOwner19); if(i == 20) return(locBackupOwner20);
	if(i == 21) return(locBackupOwner21); if(i == 22) return(locBackupOwner22); if(i == 23) return(locBackupOwner23); if(i == 24) return(locBackupOwner24);
	if(i == 25) return(locBackupOwner25); if(i == 26) return(locBackupOwner26); if(i == 27) return(locBackupOwner27); if(i == 28) return(locBackupOwner28);
	if(i == 29) return(locBackupOwner29); if(i == 30) return(locBackupOwner30); if(i == 31) return(locBackupOwner31); if(i == 32) return(locBackupOwner32);
	if(i == 33) return(locBackupOwner33); if(i == 34) return(locBackupOwner34); if(i == 35) return(locBackupOwner35); if(i == 36) return(locBackupOwner36);
	if(i == 37) return(locBackupOwner37); if(i == 38) return(locBackupOwner38); if(i == 39) return(locBackupOwner39); if(i == 40) return(locBackupOwner40);
	if(i == 41) return(locBackupOwner41); if(i == 42) return(locBackupOwner42); if(i == 43) return(locBackupOwner43); if(i == 44) return(locBackupOwner44);
	if(i == 45) return(locBackupOwner45); if(i == 46) return(locBackupOwner46); if(i == 47) return(locBackupOwner47); if(i == 48) return(locBackupOwner48);
	if(i == 49) return(locBackupOwner49); if(i == 50) return(locBackupOwner50); if(i == 51) return(locBackupOwner51); if(i == 52) return(locBackupOwner52);
	if(i == 53) return(locBackupOwner53); if(i == 54) return(locBackupOwner54); if(i == 55) return(locBackupOwner55); if(i == 56) return(locBackupOwner56);
	if(i == 57) return(locBackupOwner57); if(i == 58) return(locBackupOwner58); if(i == 59) return(locBackupOwner59); if(i == 60) return(locBackupOwner60);
	if(i == 61) return(locBackupOwner61); if(i == 62) return(locBackupOwner62); if(i == 63) return(locBackupOwner63); if(i == 64) return(locBackupOwner64);
	return(0);
}

int setLocBackupOwner(int i = 0, int o = 0) {
	if(i == 1)  locBackupOwner1  = o; if(i == 2)  locBackupOwner2  = o; if(i == 3)  locBackupOwner3  = o; if(i == 4)  locBackupOwner4  = o;
	if(i == 5)  locBackupOwner5  = o; if(i == 6)  locBackupOwner6  = o; if(i == 7)  locBackupOwner7  = o; if(i == 8)  locBackupOwner8  = o;
	if(i == 9)  locBackupOwner9  = o; if(i == 10) locBackupOwner10 = o; if(i == 11) locBackupOwner11 = o; if(i == 12) locBackupOwner12 = o;
	if(i == 13) locBackupOwner13 = o; if(i == 14) locBackupOwner14 = o; if(i == 15) locBackupOwner15 = o; if(i == 16) locBackupOwner16 = o;
	if(i == 17) locBackupOwner17 = o; if(i == 18) locBackupOwner18 = o; if(i == 19) locBackupOwner19 = o; if(i == 20) locBackupOwner20 = o;
	if(i == 21) locBackupOwner21 = o; if(i == 22) locBackupOwner22 = o; if(i == 23) locBackupOwner23 = o; if(i == 24) locBackupOwner24 = o;
	if(i == 25) locBackupOwner25 = o; if(i == 26) locBackupOwner26 = o; if(i == 27) locBackupOwner27 = o; if(i == 28) locBackupOwner28 = o;
	if(i == 29) locBackupOwner29 = o; if(i == 30) locBackupOwner30 = o; if(i == 31) locBackupOwner31 = o; if(i == 32) locBackupOwner32 = o;
	if(i == 33) locBackupOwner33 = o; if(i == 34) locBackupOwner34 = o; if(i == 35) locBackupOwner35 = o; if(i == 36) locBackupOwner36 = o;
	if(i == 37) locBackupOwner37 = o; if(i == 38) locBackupOwner38 = o; if(i == 39) locBackupOwner39 = o; if(i == 40) locBackupOwner40 = o;
	if(i == 41) locBackupOwner41 = o; if(i == 42) locBackupOwner42 = o; if(i == 43) locBackupOwner43 = o; if(i == 44) locBackupOwner44 = o;
	if(i == 45) locBackupOwner45 = o; if(i == 46) locBackupOwner46 = o; if(i == 47) locBackupOwner47 = o; if(i == 48) locBackupOwner48 = o;
	if(i == 49) locBackupOwner49 = o; if(i == 50) locBackupOwner50 = o; if(i == 51) locBackupOwner51 = o; if(i == 52) locBackupOwner52 = o;
	if(i == 53) locBackupOwner53 = o; if(i == 54) locBackupOwner54 = o; if(i == 55) locBackupOwner55 = o; if(i == 56) locBackupOwner56 = o;
	if(i == 57) locBackupOwner57 = o; if(i == 58) locBackupOwner58 = o; if(i == 59) locBackupOwner59 = o; if(i == 60) locBackupOwner60 = o;
	if(i == 61) locBackupOwner61 = o; if(i == 62) locBackupOwner62 = o; if(i == 63) locBackupOwner63 = o; if(i == 64) locBackupOwner64 = o;
}

/*
** Sets both x and z value for a given index in the array.
** Note that the arrays have to be managed manually.
**
** @param i: the index in the array
** @param x: the x value to set
** @param z: the z value to set
** @param owner: the owner of the location to set
*/
void setLocXZ(int i = 0, float x = -1.0, float z = -1.0, int owner = 0) {
	setLocX(i, x);
	setLocZ(i, z);
	setLocOwner(i, owner);
}

/*
** Sets both x and z value for a given index in the backup array.
** Note that the arrays have to be managed manually.
**
** @param i: the index in the backup array
** @param x: the x value to set
** @param z the z value to set
** @param owner: the owner of the location to set
*/
void setLocBackupXZ(int i = 0, float x = -1.0, float z = -1.0, int owner = 0) {
	setLocBackupX(i, x);
	setLocBackupZ(i, z);
	setLocBackupOwner(i, z);
}

/*
** Moves the current content of the location arrays to the backupLocation arrays.
*/
void backupLocStorage() {
	for(i = 1; <= cAreaStorageSize) {
		setLocBackupXZ(i, getLocX(i), getLocZ(i), getLocOwner(i));
	}
}

/*
** Adds a location to the next unoccupied slot in the array.
** Don't call this from outside this file.
**
** @param x: the x value to set
** @param z: the z value to set
** @param owner: the owner of the location to set
*/
void storeLocXZ(float x = -1.0, float z = -1.0, int owner = 0) {
	locCounter++;
	setLocXZ(locCounter, x, z, owner);
}

/*
** Forcefully adds a location to the next unoccupied slot in the array.
**
** @param x: the x value to set
** @param z: the z value to set
** @param owner: the owner of the location to set
*/
void forceAddLocToStorage(float x = -1.0, float z = -1.0, int owner = 0) {
	storeLocXZ(x, z, owner);
}

/*
** Adds a location to the next unoccupied slot in the array if storing is enabled.
**
** @param x: the x value to set
** @param z: the z value to set
** @param owner: the owner of the location to set
*/
void addLocToStorage(float x = -1.0, float z = -1.0, int owner = 0) {
	if(isStorageActive) {
		storeLocXZ(x, z, owner);
	}
}

/*
** Converts a polar location to cartesian coordinate and adds the value to the next unoccupied slot in the array if storing is enabled.
**
** @param player: the player to use as offset (0 = 0.5/0.5)
** @param radius: the radius as a fraction
** @param angle: the angle in radians
*/
void addLocPolarWithOffsetToLocStorage(int player = 0, float radius = 0.0, float angle = 0.0) {
	if(isStorageActive) {
		storeLocXZ(getXFromPolarForPlayer(player, radius, angle), getZFromPolarForPlayer(player, radius, angle), player);
	}
}

/*
** Set the location counter to a specific value/offset.
**
** @param loc: the new value
*/
void setLocCounter(int loc = 0) {
	locCounter = loc;
}

/*
** Resets the location storage by setting the counter to 0.
*/
void resetLocStorage() {
	locCounter = 0;
}

/*
** Returns the current size of the location storage.
** Keep in mind that the indices start at 1 when using this to iterate over the array.
**
** @returns: the current size of the array
*/
int getLocStorageSize() {
	return(locCounter);
}

/*
** Enables the storage.
*/
void enableLocStorage() {
	isStorageActive = true;
}

/*
** Disables the storage.
*/
void disableLocStorage() {
	isStorageActive = false;
}

/*
** Setter for the storage.
**
** @param active: true to activate, false to deactivate
*/
void setLocStorageActive(bool state = true) {
	isStorageActive = state;
}

/*
** Checks if the location storage is currently active.
**
** @returns: true if the storage is active, false otherwise
*/
bool isLocStorageActive() {
	return(isStorageActive);
}

/*****************************
* LOCATION PLACEMENT UTILITY *
*****************************/

/*
** Creates locations between teams and stores them in the location storage.
** Locations get appended at the current position the array is at, use resetLocStorage() if you want them at the beginning.
**
** @param radius: radius from the center to the location
*/
void placeLocationsBetweenTeams(float radius = 0.0) {
	for(i = 1; <= cTeams) {
		float angleBetweenTeams = getAngleBetweenConsecutiveAngles(getTeamAngle(i - 1), getTeamAngle(i % cTeams));

		// Calculate x and z, use map center as offset.
		float x = getXFromPolar(radius, angleBetweenTeams);
		float z = getZFromPolar(radius, angleBetweenTeams);

		// Fit to map and add to storage regardless of setting.
		forceAddLocToStorage(fitToMap(x), fitToMap(z));
	}
}

/*
** Creates locations between allies and stores them in the location storage.
** Locations get appended at the current position the array is at, use resetLocStorage() if you want them at the beginning.
**
** @param radius: radius from the center to the location
*/
void placeLocationsBetweenAllies(float radius = 0.0) {
	int player = 1;

	for(i = 1; <= cTeams) {
		for(j = 1; < getNumberPlayersOnTeam(i - 1)) { // Skip last player.
			float a = getPlayerAngle(player);
			float b = getPlayerAngle(getNextPlayer(player));
			float angleBetweenPlayers = getAngleBetweenConsecutiveAngles(a, b);

			// Calculate x and z, use map center as offset.
			float x = getXFromPolar(radius, angleBetweenPlayers);
			float z = getZFromPolar(radius, angleBetweenPlayers);

			// Fit to map and add to storage regardless of setting.
			forceAddLocToStorage(fitToMap(x), fitToMap(z));

			player++;
		}

		player++;
	}
}

/*
** Creates locations between all players and stores them in the location storage.
** Locations get appended at the current position the array is at, use resetLocStorage() if you want them at the beginning.
**
** @param radius: radius from the center to the location
*/
void placeLocationsBetweenPlayers(float radius = 0.0) {
	int player = 1;

	for(i = 1; <= cTeams) {
		for(j = 1; <= getNumberPlayersOnTeam(i - 1)) {
			float a = getPlayerAngle(player);
			float b = getPlayerAngle(getNextPlayer(player));
			float angleBetweenPlayers = getAngleBetweenConsecutiveAngles(a, b);

			// Calculate x and z, use map center as offset.
			float x = getXFromPolar(radius, angleBetweenPlayers);
			float z = getZFromPolar(radius, angleBetweenPlayers);

			// Fit to map and add to storage regardless of setting.
			forceAddLocToStorage(fitToMap(x), fitToMap(z));

			player++;
		}
	}
}

/*
** Creates locations in a circle and stores them in the location storage.
** Locations get appended at the current position the array is at, use resetLocStorage() if you want them at the beginning.
**
** @param n: the number of locations to place
** @param radius: radius from the offset to place the circle at
** @param angle: the angle to start placement at; note that for an arc (range < 1.0), this will be the center of the arc
** @param range: 1.0 for full circle, 0.5 for half of a circle, etc.
** @param offsetX: the center of the circle that will be used as offset; defaults to center of the map (0.5/0.5)
** @param offsetZ: the center of the circle that will be used as offset; defaults to center of the map (0.5/0.5)
*/
void placeLocationsInCircle(int n = 1, float radius = 0.0, float angle = 0.0, float range = 1.0, float offsetX = 0.5, float offsetZ = 0.5) {
	float a = angle; // Just to make sure because 0 is interpreted as an int if we use the parameter variable.

	// Angle interval between locations.
	float interval = (2.0 * PI) / n;

	if(range < 1.0) {
		// Sector segments.
		interval = (2.0 * PI * range) / (n - 1);
		a = a - ((1.0 * (n - 1)) / 2.0) * interval;
	}

	for(i = 1; <= n) {
		float x = getXFromPolar(radius, a, 0.0) + offsetX;
		float z = getZFromPolar(radius, a, 0.0) + offsetZ;

		// Don't fit to map if location invalid.
		forceAddLocToStorage(x, z);

		a = a + interval;
	}
}

/*
** Creates locations in a line and stores them in the location storage.
** Locations get appended at the current position the array is at, use resetLocStorage() if you want them at the beginning.
**
** @param n: the number of locations to place
** @param x1: the x coordinate of the first point
** @param z1: the z coordinate of the first point
** @param x2: the x coordinate of the second point
** @param x2: the z coordinate of the second point
** @param range: can be used to shrink (< 1.0) or to stretch (> 1.0) the line
*/
void placeLocationsInLine(int n = 1, float x1 = 0.0, float z1 = 0.0, float x2 = 0.0, float z2 = 0.0, float range = 1.0) {
	float xDist = (range * (x2 - x1)) / (n - 1);
	float zDist = (range * (z2 - z1)) / (n - 1);

	// Adjust the first point in case a range was set.
	x1 = x1 + ((1.0 - range) * (x2 - x1)) / 2.0;
	z1 = z1 + ((1.0 - range) * (z2 - z1)) / 2.0;

	// Special case for n = 1: Place between the two locations.
	if(n == 1) {
		x1 = (x2 + x1) / 2.0;
		z1 = (z2 + z1) / 2.0;
	}

	for(i = 1; <= n) {
		float x = x1 + 1.0 * (i - 1) * xDist;
		float z = z1 + 1.0 * (i - 1) * zDist;

		// Don't fit to map if location invalid.
		forceAddLocToStorage(x, z);
	}
}

/*
** Spawn checking for non-mirrored object IDs and proto names.
** RebelsRising
** Last edit: 14/04/2021
**
** You have two options to verify placement:
**
** 1. By adding a check via trigger for a specific proto name.
**    To do so, you have call addProtoPlacementCheck() (see the proto check section below).
**
** 2. Checking immediately when placing the object whether placement succeeded.
**    There are several things you have to do for correct tracking:
**    1. Use createObjectDefVerify() to create the object definition (it returns an integer so you can replace rmCreateObjectDef() 1:1).
**    2. Use addObjectDefItemVerify() instead of rmAddObjectDefItem(), can also be replaced 1:1.
**    3. DO NOT use the regular rm placement functions for placing that object. Use anything from the RM X library
**       (e.g. the default placeObjectAtPlayerLocs that replaces rmPlaceObjectDefPerPlayer()).
**       The usage of the standard placement functions for anything except embellishment objects is strongly discouraged in this framework.
*/

// include "rmx_locations.xs";

/**************
* PROTO CHECK *
**************/

int protoCheckCount = 0;

// Contains the proto name of the object.
string protoName0   = "?"; string protoName1   = "?"; string protoName2   = "?"; string protoName3   = "?";
string protoName4   = "?"; string protoName5   = "?"; string protoName6   = "?"; string protoName7   = "?";
string protoName8   = "?"; string protoName9   = "?"; string protoName10  = "?"; string protoName11  = "?";
string protoName12  = "?"; string protoName13  = "?"; string protoName14  = "?"; string protoName15  = "?";
string protoName16  = "?"; string protoName17  = "?"; string protoName18  = "?"; string protoName19  = "?";
string protoName20  = "?"; string protoName21  = "?"; string protoName22  = "?"; string protoName23  = "?";
string protoName24  = "?"; string protoName25  = "?"; string protoName26  = "?"; string protoName27  = "?";
string protoName28  = "?"; string protoName29  = "?"; string protoName30  = "?"; string protoName31  = "?";
string protoName32  = "?"; string protoName33  = "?"; string protoName34  = "?"; string protoName35  = "?";
string protoName36  = "?"; string protoName37  = "?"; string protoName38  = "?"; string protoName39  = "?";
string protoName40  = "?"; string protoName41  = "?"; string protoName42  = "?"; string protoName43  = "?";
string protoName44  = "?"; string protoName45  = "?"; string protoName46  = "?"; string protoName47  = "?";
string protoName48  = "?"; string protoName49  = "?"; string protoName50  = "?"; string protoName51  = "?";
string protoName52  = "?"; string protoName53  = "?"; string protoName54  = "?"; string protoName55  = "?";
string protoName56  = "?"; string protoName57  = "?"; string protoName58  = "?"; string protoName59  = "?";
string protoName60  = "?"; string protoName61  = "?"; string protoName62  = "?"; string protoName63  = "?";
string protoName64  = "?"; string protoName65  = "?"; string protoName66  = "?"; string protoName67  = "?";
string protoName68  = "?"; string protoName69  = "?"; string protoName70  = "?"; string protoName71  = "?";
string protoName72  = "?"; string protoName73  = "?"; string protoName74  = "?"; string protoName75  = "?";
string protoName76  = "?"; string protoName77  = "?"; string protoName78  = "?"; string protoName79  = "?";
string protoName80  = "?"; string protoName81  = "?"; string protoName82  = "?"; string protoName83  = "?";
string protoName84  = "?"; string protoName85  = "?"; string protoName86  = "?"; string protoName87  = "?";
string protoName88  = "?"; string protoName89  = "?"; string protoName90  = "?"; string protoName91  = "?";
string protoName92  = "?"; string protoName93  = "?"; string protoName94  = "?"; string protoName95  = "?";
string protoName96  = "?"; string protoName97  = "?"; string protoName98  = "?"; string protoName99  = "?";
string protoName100 = "?"; string protoName101 = "?"; string protoName102 = "?"; string protoName103 = "?";
string protoName104 = "?"; string protoName105 = "?"; string protoName106 = "?"; string protoName107 = "?";
string protoName108 = "?"; string protoName109 = "?"; string protoName110 = "?"; string protoName111 = "?";
string protoName112 = "?"; string protoName113 = "?"; string protoName114 = "?"; string protoName115 = "?";
string protoName116 = "?"; string protoName117 = "?"; string protoName118 = "?"; string protoName119 = "?";
string protoName120 = "?"; string protoName121 = "?"; string protoName122 = "?"; string protoName123 = "?";
string protoName124 = "?"; string protoName125 = "?"; string protoName126 = "?"; string protoName127 = "?";
string protoName128 = "?"; string protoName129 = "?"; string protoName130 = "?"; string protoName131 = "?";
string protoName132 = "?"; string protoName133 = "?"; string protoName134 = "?"; string protoName135 = "?";
string protoName136 = "?"; string protoName137 = "?"; string protoName138 = "?"; string protoName139 = "?";
string protoName140 = "?"; string protoName141 = "?"; string protoName142 = "?"; string protoName143 = "?";
string protoName144 = "?"; string protoName145 = "?"; string protoName146 = "?"; string protoName147 = "?";
string protoName148 = "?"; string protoName149 = "?"; string protoName150 = "?"; string protoName151 = "?";
string protoName152 = "?"; string protoName153 = "?"; string protoName154 = "?"; string protoName155 = "?";
string protoName156 = "?"; string protoName157 = "?"; string protoName158 = "?"; string protoName159 = "?";
string protoName160 = "?"; string protoName161 = "?"; string protoName162 = "?"; string protoName163 = "?";
string protoName164 = "?"; string protoName165 = "?"; string protoName166 = "?"; string protoName167 = "?";
string protoName168 = "?"; string protoName169 = "?"; string protoName170 = "?"; string protoName171 = "?";
string protoName172 = "?"; string protoName173 = "?"; string protoName174 = "?"; string protoName175 = "?";
string protoName176 = "?"; string protoName177 = "?"; string protoName178 = "?"; string protoName179 = "?";
string protoName180 = "?"; string protoName181 = "?"; string protoName182 = "?"; string protoName183 = "?";
string protoName184 = "?"; string protoName185 = "?"; string protoName186 = "?"; string protoName187 = "?";
string protoName188 = "?"; string protoName189 = "?"; string protoName190 = "?"; string protoName191 = "?";
string protoName192 = "?"; string protoName193 = "?"; string protoName194 = "?"; string protoName195 = "?";
string protoName196 = "?"; string protoName197 = "?"; string protoName198 = "?"; string protoName199 = "?";
string protoName200 = "?"; string protoName201 = "?"; string protoName202 = "?"; string protoName203 = "?";
string protoName204 = "?"; string protoName205 = "?"; string protoName206 = "?"; string protoName207 = "?";
string protoName208 = "?"; string protoName209 = "?"; string protoName210 = "?"; string protoName211 = "?";
string protoName212 = "?"; string protoName213 = "?"; string protoName214 = "?"; string protoName215 = "?";
string protoName216 = "?"; string protoName217 = "?"; string protoName218 = "?"; string protoName219 = "?";
string protoName220 = "?"; string protoName221 = "?"; string protoName222 = "?"; string protoName223 = "?";
string protoName224 = "?"; string protoName225 = "?"; string protoName226 = "?"; string protoName227 = "?";
string protoName228 = "?"; string protoName229 = "?"; string protoName230 = "?"; string protoName231 = "?";
string protoName232 = "?"; string protoName233 = "?"; string protoName234 = "?"; string protoName235 = "?";
string protoName236 = "?"; string protoName237 = "?"; string protoName238 = "?"; string protoName239 = "?";

string getProtoName(int i = -1) {
	if(i == 0)   return(protoName0);   if(i == 1)   return(protoName1);   if(i == 2)   return(protoName2);   if(i == 3)   return(protoName3);
	if(i == 4)   return(protoName4);   if(i == 5)   return(protoName5);   if(i == 6)   return(protoName6);   if(i == 7)   return(protoName7);
	if(i == 8)   return(protoName8);   if(i == 9)   return(protoName9);   if(i == 10)  return(protoName10);  if(i == 11)  return(protoName11);
	if(i == 12)  return(protoName12);  if(i == 13)  return(protoName13);  if(i == 14)  return(protoName14);  if(i == 15)  return(protoName15);
	if(i == 16)  return(protoName16);  if(i == 17)  return(protoName17);  if(i == 18)  return(protoName18);  if(i == 19)  return(protoName19);
	if(i == 20)  return(protoName20);  if(i == 21)  return(protoName21);  if(i == 22)  return(protoName22);  if(i == 23)  return(protoName23);
	if(i == 24)  return(protoName24);  if(i == 25)  return(protoName25);  if(i == 26)  return(protoName26);  if(i == 27)  return(protoName27);
	if(i == 28)  return(protoName28);  if(i == 29)  return(protoName29);  if(i == 30)  return(protoName30);  if(i == 31)  return(protoName31);
	if(i == 32)  return(protoName32);  if(i == 33)  return(protoName33);  if(i == 34)  return(protoName34);  if(i == 35)  return(protoName35);
	if(i == 36)  return(protoName36);  if(i == 37)  return(protoName37);  if(i == 38)  return(protoName38);  if(i == 39)  return(protoName39);
	if(i == 40)  return(protoName40);  if(i == 41)  return(protoName41);  if(i == 42)  return(protoName42);  if(i == 43)  return(protoName43);
	if(i == 44)  return(protoName44);  if(i == 45)  return(protoName45);  if(i == 46)  return(protoName46);  if(i == 47)  return(protoName47);
	if(i == 48)  return(protoName48);  if(i == 49)  return(protoName49);  if(i == 50)  return(protoName50);  if(i == 51)  return(protoName51);
	if(i == 52)  return(protoName52);  if(i == 53)  return(protoName53);  if(i == 54)  return(protoName54);  if(i == 55)  return(protoName55);
	if(i == 56)  return(protoName56);  if(i == 57)  return(protoName57);  if(i == 58)  return(protoName58);  if(i == 59)  return(protoName59);
	if(i == 60)  return(protoName60);  if(i == 61)  return(protoName61);  if(i == 62)  return(protoName62);  if(i == 63)  return(protoName63);
	if(i == 64)  return(protoName64);  if(i == 65)  return(protoName65);  if(i == 66)  return(protoName66);  if(i == 67)  return(protoName67);
	if(i == 68)  return(protoName68);  if(i == 69)  return(protoName69);  if(i == 70)  return(protoName70);  if(i == 71)  return(protoName71);
	if(i == 72)  return(protoName72);  if(i == 73)  return(protoName73);  if(i == 74)  return(protoName74);  if(i == 75)  return(protoName75);
	if(i == 76)  return(protoName76);  if(i == 77)  return(protoName77);  if(i == 78)  return(protoName78);  if(i == 79)  return(protoName79);
	if(i == 80)  return(protoName80);  if(i == 81)  return(protoName81);  if(i == 82)  return(protoName82);  if(i == 83)  return(protoName83);
	if(i == 84)  return(protoName84);  if(i == 85)  return(protoName85);  if(i == 86)  return(protoName86);  if(i == 87)  return(protoName87);
	if(i == 88)  return(protoName88);  if(i == 89)  return(protoName89);  if(i == 90)  return(protoName90);  if(i == 91)  return(protoName91);
	if(i == 92)  return(protoName92);  if(i == 93)  return(protoName93);  if(i == 94)  return(protoName94);  if(i == 95)  return(protoName95);
	if(i == 96)  return(protoName96);  if(i == 97)  return(protoName97);  if(i == 98)  return(protoName98);  if(i == 99)  return(protoName99);
	if(i == 100) return(protoName100); if(i == 101) return(protoName101); if(i == 102) return(protoName102); if(i == 103) return(protoName103);
	if(i == 104) return(protoName104); if(i == 105) return(protoName105); if(i == 106) return(protoName106); if(i == 107) return(protoName107);
	if(i == 108) return(protoName108); if(i == 109) return(protoName109); if(i == 110) return(protoName110); if(i == 111) return(protoName111);
	if(i == 112) return(protoName112); if(i == 113) return(protoName113); if(i == 114) return(protoName114); if(i == 115) return(protoName115);
	if(i == 116) return(protoName116); if(i == 117) return(protoName117); if(i == 118) return(protoName118); if(i == 119) return(protoName119);
	if(i == 120) return(protoName120); if(i == 121) return(protoName121); if(i == 122) return(protoName122); if(i == 123) return(protoName123);
	if(i == 124) return(protoName124); if(i == 125) return(protoName125); if(i == 126) return(protoName126); if(i == 127) return(protoName127);
	if(i == 128) return(protoName128); if(i == 129) return(protoName129); if(i == 130) return(protoName130); if(i == 131) return(protoName131);
	if(i == 132) return(protoName132); if(i == 133) return(protoName133); if(i == 134) return(protoName134); if(i == 135) return(protoName135);
	if(i == 136) return(protoName136); if(i == 137) return(protoName137); if(i == 138) return(protoName138); if(i == 139) return(protoName139);
	if(i == 140) return(protoName140); if(i == 141) return(protoName141); if(i == 142) return(protoName142); if(i == 143) return(protoName143);
	if(i == 144) return(protoName144); if(i == 145) return(protoName145); if(i == 146) return(protoName146); if(i == 147) return(protoName147);
	if(i == 148) return(protoName148); if(i == 149) return(protoName149); if(i == 150) return(protoName150); if(i == 151) return(protoName151);
	if(i == 152) return(protoName152); if(i == 153) return(protoName153); if(i == 154) return(protoName154); if(i == 155) return(protoName155);
	if(i == 156) return(protoName156); if(i == 157) return(protoName157); if(i == 158) return(protoName158); if(i == 159) return(protoName159);
	if(i == 160) return(protoName160); if(i == 161) return(protoName161); if(i == 162) return(protoName162); if(i == 163) return(protoName163);
	if(i == 164) return(protoName164); if(i == 165) return(protoName165); if(i == 166) return(protoName166); if(i == 167) return(protoName167);
	if(i == 168) return(protoName168); if(i == 169) return(protoName169); if(i == 170) return(protoName170); if(i == 171) return(protoName171);
	if(i == 172) return(protoName172); if(i == 173) return(protoName173); if(i == 174) return(protoName174); if(i == 175) return(protoName175);
	if(i == 176) return(protoName176); if(i == 177) return(protoName177); if(i == 178) return(protoName178); if(i == 179) return(protoName179);
	if(i == 180) return(protoName180); if(i == 181) return(protoName181); if(i == 182) return(protoName182); if(i == 183) return(protoName183);
	if(i == 184) return(protoName184); if(i == 185) return(protoName185); if(i == 186) return(protoName186); if(i == 187) return(protoName187);
	if(i == 188) return(protoName188); if(i == 189) return(protoName189); if(i == 190) return(protoName190); if(i == 191) return(protoName191);
	if(i == 192) return(protoName192); if(i == 193) return(protoName193); if(i == 194) return(protoName194); if(i == 195) return(protoName195);
	if(i == 196) return(protoName196); if(i == 197) return(protoName197); if(i == 198) return(protoName198); if(i == 199) return(protoName199);
	if(i == 200) return(protoName200); if(i == 201) return(protoName201); if(i == 202) return(protoName202); if(i == 203) return(protoName203);
	if(i == 204) return(protoName204); if(i == 205) return(protoName205); if(i == 206) return(protoName206); if(i == 207) return(protoName207);
	if(i == 208) return(protoName208); if(i == 209) return(protoName209); if(i == 210) return(protoName210); if(i == 211) return(protoName211);
	if(i == 212) return(protoName212); if(i == 213) return(protoName213); if(i == 214) return(protoName214); if(i == 215) return(protoName215);
	if(i == 216) return(protoName216); if(i == 217) return(protoName217); if(i == 218) return(protoName218); if(i == 219) return(protoName219);
	if(i == 220) return(protoName220); if(i == 221) return(protoName221); if(i == 222) return(protoName222); if(i == 223) return(protoName223);
	if(i == 224) return(protoName224); if(i == 225) return(protoName225); if(i == 226) return(protoName226); if(i == 227) return(protoName227);
	if(i == 228) return(protoName228); if(i == 229) return(protoName229); if(i == 230) return(protoName230); if(i == 231) return(protoName231);
	if(i == 232) return(protoName232); if(i == 233) return(protoName233); if(i == 234) return(protoName234); if(i == 235) return(protoName235);
	if(i == 236) return(protoName236); if(i == 237) return(protoName237); if(i == 238) return(protoName238); if(i == 239) return(protoName239);
	return("?");
}

void setProtoName(int i = -1, string lab = "") {
	if(i == 0)   protoName0   = lab; if(i == 1)   protoName1   = lab; if(i == 2)   protoName2   = lab; if(i == 3)   protoName3   = lab;
	if(i == 4)   protoName4   = lab; if(i == 5)   protoName5   = lab; if(i == 6)   protoName6   = lab; if(i == 7)   protoName7   = lab;
	if(i == 8)   protoName8   = lab; if(i == 9)   protoName9   = lab; if(i == 10)  protoName10  = lab; if(i == 11)  protoName11  = lab;
	if(i == 12)  protoName12  = lab; if(i == 13)  protoName13  = lab; if(i == 14)  protoName14  = lab; if(i == 15)  protoName15  = lab;
	if(i == 16)  protoName16  = lab; if(i == 17)  protoName17  = lab; if(i == 18)  protoName18  = lab; if(i == 19)  protoName19  = lab;
	if(i == 20)  protoName20  = lab; if(i == 21)  protoName21  = lab; if(i == 22)  protoName22  = lab; if(i == 23)  protoName23  = lab;
	if(i == 24)  protoName24  = lab; if(i == 25)  protoName25  = lab; if(i == 26)  protoName26  = lab; if(i == 27)  protoName27  = lab;
	if(i == 28)  protoName28  = lab; if(i == 29)  protoName29  = lab; if(i == 30)  protoName30  = lab; if(i == 31)  protoName31  = lab;
	if(i == 32)  protoName32  = lab; if(i == 33)  protoName33  = lab; if(i == 34)  protoName34  = lab; if(i == 35)  protoName35  = lab;
	if(i == 36)  protoName36  = lab; if(i == 37)  protoName37  = lab; if(i == 38)  protoName38  = lab; if(i == 39)  protoName39  = lab;
	if(i == 40)  protoName40  = lab; if(i == 41)  protoName41  = lab; if(i == 42)  protoName42  = lab; if(i == 43)  protoName43  = lab;
	if(i == 44)  protoName44  = lab; if(i == 45)  protoName45  = lab; if(i == 46)  protoName46  = lab; if(i == 47)  protoName47  = lab;
	if(i == 48)  protoName48  = lab; if(i == 49)  protoName49  = lab; if(i == 50)  protoName50  = lab; if(i == 51)  protoName51  = lab;
	if(i == 52)  protoName52  = lab; if(i == 53)  protoName53  = lab; if(i == 54)  protoName54  = lab; if(i == 55)  protoName55  = lab;
	if(i == 56)  protoName56  = lab; if(i == 57)  protoName57  = lab; if(i == 58)  protoName58  = lab; if(i == 59)  protoName59  = lab;
	if(i == 60)  protoName60  = lab; if(i == 61)  protoName61  = lab; if(i == 62)  protoName62  = lab; if(i == 63)  protoName63  = lab;
	if(i == 64)  protoName64  = lab; if(i == 65)  protoName65  = lab; if(i == 66)  protoName66  = lab; if(i == 67)  protoName67  = lab;
	if(i == 68)  protoName68  = lab; if(i == 69)  protoName69  = lab; if(i == 70)  protoName70  = lab; if(i == 71)  protoName71  = lab;
	if(i == 72)  protoName72  = lab; if(i == 73)  protoName73  = lab; if(i == 74)  protoName74  = lab; if(i == 75)  protoName75  = lab;
	if(i == 76)  protoName76  = lab; if(i == 77)  protoName77  = lab; if(i == 78)  protoName78  = lab; if(i == 79)  protoName79  = lab;
	if(i == 80)  protoName80  = lab; if(i == 81)  protoName81  = lab; if(i == 82)  protoName82  = lab; if(i == 83)  protoName83  = lab;
	if(i == 84)  protoName84  = lab; if(i == 85)  protoName85  = lab; if(i == 86)  protoName86  = lab; if(i == 87)  protoName87  = lab;
	if(i == 88)  protoName88  = lab; if(i == 89)  protoName89  = lab; if(i == 90)  protoName90  = lab; if(i == 91)  protoName91  = lab;
	if(i == 92)  protoName92  = lab; if(i == 93)  protoName93  = lab; if(i == 94)  protoName94  = lab; if(i == 95)  protoName95  = lab;
	if(i == 96)  protoName96  = lab; if(i == 97)  protoName97  = lab; if(i == 98)  protoName98  = lab; if(i == 99)  protoName99  = lab;
	if(i == 100) protoName100 = lab; if(i == 101) protoName101 = lab; if(i == 102) protoName102 = lab; if(i == 103) protoName103 = lab;
	if(i == 104) protoName104 = lab; if(i == 105) protoName105 = lab; if(i == 106) protoName106 = lab; if(i == 107) protoName107 = lab;
	if(i == 108) protoName108 = lab; if(i == 109) protoName109 = lab; if(i == 110) protoName110 = lab; if(i == 111) protoName111 = lab;
	if(i == 112) protoName112 = lab; if(i == 113) protoName113 = lab; if(i == 114) protoName114 = lab; if(i == 115) protoName115 = lab;
	if(i == 116) protoName116 = lab; if(i == 117) protoName117 = lab; if(i == 118) protoName118 = lab; if(i == 119) protoName119 = lab;
	if(i == 120) protoName120 = lab; if(i == 121) protoName121 = lab; if(i == 122) protoName122 = lab; if(i == 123) protoName123 = lab;
	if(i == 124) protoName124 = lab; if(i == 125) protoName125 = lab; if(i == 126) protoName126 = lab; if(i == 127) protoName127 = lab;
	if(i == 128) protoName128 = lab; if(i == 129) protoName129 = lab; if(i == 130) protoName130 = lab; if(i == 131) protoName131 = lab;
	if(i == 132) protoName132 = lab; if(i == 133) protoName133 = lab; if(i == 134) protoName134 = lab; if(i == 135) protoName135 = lab;
	if(i == 136) protoName136 = lab; if(i == 137) protoName137 = lab; if(i == 138) protoName138 = lab; if(i == 139) protoName139 = lab;
	if(i == 140) protoName140 = lab; if(i == 141) protoName141 = lab; if(i == 142) protoName142 = lab; if(i == 143) protoName143 = lab;
	if(i == 144) protoName144 = lab; if(i == 145) protoName145 = lab; if(i == 146) protoName146 = lab; if(i == 147) protoName147 = lab;
	if(i == 148) protoName148 = lab; if(i == 149) protoName149 = lab; if(i == 150) protoName150 = lab; if(i == 151) protoName151 = lab;
	if(i == 152) protoName152 = lab; if(i == 153) protoName153 = lab; if(i == 154) protoName154 = lab; if(i == 155) protoName155 = lab;
	if(i == 156) protoName156 = lab; if(i == 157) protoName157 = lab; if(i == 158) protoName158 = lab; if(i == 159) protoName159 = lab;
	if(i == 160) protoName160 = lab; if(i == 161) protoName161 = lab; if(i == 162) protoName162 = lab; if(i == 163) protoName163 = lab;
	if(i == 164) protoName164 = lab; if(i == 165) protoName165 = lab; if(i == 166) protoName166 = lab; if(i == 167) protoName167 = lab;
	if(i == 168) protoName168 = lab; if(i == 169) protoName169 = lab; if(i == 170) protoName170 = lab; if(i == 171) protoName171 = lab;
	if(i == 172) protoName172 = lab; if(i == 173) protoName173 = lab; if(i == 174) protoName174 = lab; if(i == 175) protoName175 = lab;
	if(i == 176) protoName176 = lab; if(i == 177) protoName177 = lab; if(i == 178) protoName178 = lab; if(i == 179) protoName179 = lab;
	if(i == 180) protoName180 = lab; if(i == 181) protoName181 = lab; if(i == 182) protoName182 = lab; if(i == 183) protoName183 = lab;
	if(i == 184) protoName184 = lab; if(i == 185) protoName185 = lab; if(i == 186) protoName186 = lab; if(i == 187) protoName187 = lab;
	if(i == 188) protoName188 = lab; if(i == 189) protoName189 = lab; if(i == 190) protoName190 = lab; if(i == 191) protoName191 = lab;
	if(i == 192) protoName192 = lab; if(i == 193) protoName193 = lab; if(i == 194) protoName194 = lab; if(i == 195) protoName195 = lab;
	if(i == 196) protoName196 = lab; if(i == 197) protoName197 = lab; if(i == 198) protoName198 = lab; if(i == 199) protoName199 = lab;
	if(i == 200) protoName200 = lab; if(i == 201) protoName201 = lab; if(i == 202) protoName202 = lab; if(i == 203) protoName203 = lab;
	if(i == 204) protoName204 = lab; if(i == 205) protoName205 = lab; if(i == 206) protoName206 = lab; if(i == 207) protoName207 = lab;
	if(i == 208) protoName208 = lab; if(i == 209) protoName209 = lab; if(i == 210) protoName210 = lab; if(i == 211) protoName211 = lab;
	if(i == 212) protoName212 = lab; if(i == 213) protoName213 = lab; if(i == 214) protoName214 = lab; if(i == 215) protoName215 = lab;
	if(i == 216) protoName216 = lab; if(i == 217) protoName217 = lab; if(i == 218) protoName218 = lab; if(i == 219) protoName219 = lab;
	if(i == 220) protoName220 = lab; if(i == 221) protoName221 = lab; if(i == 222) protoName222 = lab; if(i == 223) protoName223 = lab;
	if(i == 224) protoName224 = lab; if(i == 225) protoName225 = lab; if(i == 226) protoName226 = lab; if(i == 227) protoName227 = lab;
	if(i == 228) protoName228 = lab; if(i == 229) protoName229 = lab; if(i == 230) protoName230 = lab; if(i == 231) protoName231 = lab;
	if(i == 232) protoName232 = lab; if(i == 233) protoName233 = lab; if(i == 234) protoName234 = lab; if(i == 235) protoName235 = lab;
	if(i == 236) protoName236 = lab; if(i == 237) protoName237 = lab; if(i == 238) protoName238 = lab; if(i == 239) protoName239 = lab;
}

// Contains the counts for the objects.
int protoTargetCount0   = 0; int protoTargetCount1   = 0; int protoTargetCount2   = 0; int protoTargetCount3   = 0;
int protoTargetCount4   = 0; int protoTargetCount5   = 0; int protoTargetCount6   = 0; int protoTargetCount7   = 0;
int protoTargetCount8   = 0; int protoTargetCount9   = 0; int protoTargetCount10  = 0; int protoTargetCount11  = 0;
int protoTargetCount12  = 0; int protoTargetCount13  = 0; int protoTargetCount14  = 0; int protoTargetCount15  = 0;
int protoTargetCount16  = 0; int protoTargetCount17  = 0; int protoTargetCount18  = 0; int protoTargetCount19  = 0;
int protoTargetCount20  = 0; int protoTargetCount21  = 0; int protoTargetCount22  = 0; int protoTargetCount23  = 0;
int protoTargetCount24  = 0; int protoTargetCount25  = 0; int protoTargetCount26  = 0; int protoTargetCount27  = 0;
int protoTargetCount28  = 0; int protoTargetCount29  = 0; int protoTargetCount30  = 0; int protoTargetCount31  = 0;
int protoTargetCount32  = 0; int protoTargetCount33  = 0; int protoTargetCount34  = 0; int protoTargetCount35  = 0;
int protoTargetCount36  = 0; int protoTargetCount37  = 0; int protoTargetCount38  = 0; int protoTargetCount39  = 0;
int protoTargetCount40  = 0; int protoTargetCount41  = 0; int protoTargetCount42  = 0; int protoTargetCount43  = 0;
int protoTargetCount44  = 0; int protoTargetCount45  = 0; int protoTargetCount46  = 0; int protoTargetCount47  = 0;
int protoTargetCount48  = 0; int protoTargetCount49  = 0; int protoTargetCount50  = 0; int protoTargetCount51  = 0;
int protoTargetCount52  = 0; int protoTargetCount53  = 0; int protoTargetCount54  = 0; int protoTargetCount55  = 0;
int protoTargetCount56  = 0; int protoTargetCount57  = 0; int protoTargetCount58  = 0; int protoTargetCount59  = 0;
int protoTargetCount60  = 0; int protoTargetCount61  = 0; int protoTargetCount62  = 0; int protoTargetCount63  = 0;
int protoTargetCount64  = 0; int protoTargetCount65  = 0; int protoTargetCount66  = 0; int protoTargetCount67  = 0;
int protoTargetCount68  = 0; int protoTargetCount69  = 0; int protoTargetCount70  = 0; int protoTargetCount71  = 0;
int protoTargetCount72  = 0; int protoTargetCount73  = 0; int protoTargetCount74  = 0; int protoTargetCount75  = 0;
int protoTargetCount76  = 0; int protoTargetCount77  = 0; int protoTargetCount78  = 0; int protoTargetCount79  = 0;
int protoTargetCount80  = 0; int protoTargetCount81  = 0; int protoTargetCount82  = 0; int protoTargetCount83  = 0;
int protoTargetCount84  = 0; int protoTargetCount85  = 0; int protoTargetCount86  = 0; int protoTargetCount87  = 0;
int protoTargetCount88  = 0; int protoTargetCount89  = 0; int protoTargetCount90  = 0; int protoTargetCount91  = 0;
int protoTargetCount92  = 0; int protoTargetCount93  = 0; int protoTargetCount94  = 0; int protoTargetCount95  = 0;
int protoTargetCount96  = 0; int protoTargetCount97  = 0; int protoTargetCount98  = 0; int protoTargetCount99  = 0;
int protoTargetCount100 = 0; int protoTargetCount101 = 0; int protoTargetCount102 = 0; int protoTargetCount103 = 0;
int protoTargetCount104 = 0; int protoTargetCount105 = 0; int protoTargetCount106 = 0; int protoTargetCount107 = 0;
int protoTargetCount108 = 0; int protoTargetCount109 = 0; int protoTargetCount110 = 0; int protoTargetCount111 = 0;
int protoTargetCount112 = 0; int protoTargetCount113 = 0; int protoTargetCount114 = 0; int protoTargetCount115 = 0;
int protoTargetCount116 = 0; int protoTargetCount117 = 0; int protoTargetCount118 = 0; int protoTargetCount119 = 0;
int protoTargetCount120 = 0; int protoTargetCount121 = 0; int protoTargetCount122 = 0; int protoTargetCount123 = 0;
int protoTargetCount124 = 0; int protoTargetCount125 = 0; int protoTargetCount126 = 0; int protoTargetCount127 = 0;
int protoTargetCount128 = 0; int protoTargetCount129 = 0; int protoTargetCount130 = 0; int protoTargetCount131 = 0;
int protoTargetCount132 = 0; int protoTargetCount133 = 0; int protoTargetCount134 = 0; int protoTargetCount135 = 0;
int protoTargetCount136 = 0; int protoTargetCount137 = 0; int protoTargetCount138 = 0; int protoTargetCount139 = 0;
int protoTargetCount140 = 0; int protoTargetCount141 = 0; int protoTargetCount142 = 0; int protoTargetCount143 = 0;
int protoTargetCount144 = 0; int protoTargetCount145 = 0; int protoTargetCount146 = 0; int protoTargetCount147 = 0;
int protoTargetCount148 = 0; int protoTargetCount149 = 0; int protoTargetCount150 = 0; int protoTargetCount151 = 0;
int protoTargetCount152 = 0; int protoTargetCount153 = 0; int protoTargetCount154 = 0; int protoTargetCount155 = 0;
int protoTargetCount156 = 0; int protoTargetCount157 = 0; int protoTargetCount158 = 0; int protoTargetCount159 = 0;
int protoTargetCount160 = 0; int protoTargetCount161 = 0; int protoTargetCount162 = 0; int protoTargetCount163 = 0;
int protoTargetCount164 = 0; int protoTargetCount165 = 0; int protoTargetCount166 = 0; int protoTargetCount167 = 0;
int protoTargetCount168 = 0; int protoTargetCount169 = 0; int protoTargetCount170 = 0; int protoTargetCount171 = 0;
int protoTargetCount172 = 0; int protoTargetCount173 = 0; int protoTargetCount174 = 0; int protoTargetCount175 = 0;
int protoTargetCount176 = 0; int protoTargetCount177 = 0; int protoTargetCount178 = 0; int protoTargetCount179 = 0;
int protoTargetCount180 = 0; int protoTargetCount181 = 0; int protoTargetCount182 = 0; int protoTargetCount183 = 0;
int protoTargetCount184 = 0; int protoTargetCount185 = 0; int protoTargetCount186 = 0; int protoTargetCount187 = 0;
int protoTargetCount188 = 0; int protoTargetCount189 = 0; int protoTargetCount190 = 0; int protoTargetCount191 = 0;
int protoTargetCount192 = 0; int protoTargetCount193 = 0; int protoTargetCount194 = 0; int protoTargetCount195 = 0;
int protoTargetCount196 = 0; int protoTargetCount197 = 0; int protoTargetCount198 = 0; int protoTargetCount199 = 0;
int protoTargetCount200 = 0; int protoTargetCount201 = 0; int protoTargetCount202 = 0; int protoTargetCount203 = 0;
int protoTargetCount204 = 0; int protoTargetCount205 = 0; int protoTargetCount206 = 0; int protoTargetCount207 = 0;
int protoTargetCount208 = 0; int protoTargetCount209 = 0; int protoTargetCount210 = 0; int protoTargetCount211 = 0;
int protoTargetCount212 = 0; int protoTargetCount213 = 0; int protoTargetCount214 = 0; int protoTargetCount215 = 0;
int protoTargetCount216 = 0; int protoTargetCount217 = 0; int protoTargetCount218 = 0; int protoTargetCount219 = 0;
int protoTargetCount220 = 0; int protoTargetCount221 = 0; int protoTargetCount222 = 0; int protoTargetCount223 = 0;
int protoTargetCount224 = 0; int protoTargetCount225 = 0; int protoTargetCount226 = 0; int protoTargetCount227 = 0;
int protoTargetCount228 = 0; int protoTargetCount229 = 0; int protoTargetCount230 = 0; int protoTargetCount231 = 0;
int protoTargetCount232 = 0; int protoTargetCount233 = 0; int protoTargetCount234 = 0; int protoTargetCount235 = 0;
int protoTargetCount236 = 0; int protoTargetCount237 = 0; int protoTargetCount238 = 0; int protoTargetCount239 = 0;

int getProtoTargetCount(int i = -1) {
	if(i == 0)   return(protoTargetCount0);   if(i == 1)   return(protoTargetCount1);   if(i == 2)   return(protoTargetCount2);   if(i == 3)   return(protoTargetCount3);
	if(i == 4)   return(protoTargetCount4);   if(i == 5)   return(protoTargetCount5);   if(i == 6)   return(protoTargetCount6);   if(i == 7)   return(protoTargetCount7);
	if(i == 8)   return(protoTargetCount8);   if(i == 9)   return(protoTargetCount9);   if(i == 10)  return(protoTargetCount10);  if(i == 11)  return(protoTargetCount11);
	if(i == 12)  return(protoTargetCount12);  if(i == 13)  return(protoTargetCount13);  if(i == 14)  return(protoTargetCount14);  if(i == 15)  return(protoTargetCount15);
	if(i == 16)  return(protoTargetCount16);  if(i == 17)  return(protoTargetCount17);  if(i == 18)  return(protoTargetCount18);  if(i == 19)  return(protoTargetCount19);
	if(i == 20)  return(protoTargetCount20);  if(i == 21)  return(protoTargetCount21);  if(i == 22)  return(protoTargetCount22);  if(i == 23)  return(protoTargetCount23);
	if(i == 24)  return(protoTargetCount24);  if(i == 25)  return(protoTargetCount25);  if(i == 26)  return(protoTargetCount26);  if(i == 27)  return(protoTargetCount27);
	if(i == 28)  return(protoTargetCount28);  if(i == 29)  return(protoTargetCount29);  if(i == 30)  return(protoTargetCount30);  if(i == 31)  return(protoTargetCount31);
	if(i == 32)  return(protoTargetCount32);  if(i == 33)  return(protoTargetCount33);  if(i == 34)  return(protoTargetCount34);  if(i == 35)  return(protoTargetCount35);
	if(i == 36)  return(protoTargetCount36);  if(i == 37)  return(protoTargetCount37);  if(i == 38)  return(protoTargetCount38);  if(i == 39)  return(protoTargetCount39);
	if(i == 40)  return(protoTargetCount40);  if(i == 41)  return(protoTargetCount41);  if(i == 42)  return(protoTargetCount42);  if(i == 43)  return(protoTargetCount43);
	if(i == 44)  return(protoTargetCount44);  if(i == 45)  return(protoTargetCount45);  if(i == 46)  return(protoTargetCount46);  if(i == 47)  return(protoTargetCount47);
	if(i == 48)  return(protoTargetCount48);  if(i == 49)  return(protoTargetCount49);  if(i == 50)  return(protoTargetCount50);  if(i == 51)  return(protoTargetCount51);
	if(i == 52)  return(protoTargetCount52);  if(i == 53)  return(protoTargetCount53);  if(i == 54)  return(protoTargetCount54);  if(i == 55)  return(protoTargetCount55);
	if(i == 56)  return(protoTargetCount56);  if(i == 57)  return(protoTargetCount57);  if(i == 58)  return(protoTargetCount58);  if(i == 59)  return(protoTargetCount59);
	if(i == 60)  return(protoTargetCount60);  if(i == 61)  return(protoTargetCount61);  if(i == 62)  return(protoTargetCount62);  if(i == 63)  return(protoTargetCount63);
	if(i == 64)  return(protoTargetCount64);  if(i == 65)  return(protoTargetCount65);  if(i == 66)  return(protoTargetCount66);  if(i == 67)  return(protoTargetCount67);
	if(i == 68)  return(protoTargetCount68);  if(i == 69)  return(protoTargetCount69);  if(i == 70)  return(protoTargetCount70);  if(i == 71)  return(protoTargetCount71);
	if(i == 72)  return(protoTargetCount72);  if(i == 73)  return(protoTargetCount73);  if(i == 74)  return(protoTargetCount74);  if(i == 75)  return(protoTargetCount75);
	if(i == 76)  return(protoTargetCount76);  if(i == 77)  return(protoTargetCount77);  if(i == 78)  return(protoTargetCount78);  if(i == 79)  return(protoTargetCount79);
	if(i == 80)  return(protoTargetCount80);  if(i == 81)  return(protoTargetCount81);  if(i == 82)  return(protoTargetCount82);  if(i == 83)  return(protoTargetCount83);
	if(i == 84)  return(protoTargetCount84);  if(i == 85)  return(protoTargetCount85);  if(i == 86)  return(protoTargetCount86);  if(i == 87)  return(protoTargetCount87);
	if(i == 88)  return(protoTargetCount88);  if(i == 89)  return(protoTargetCount89);  if(i == 90)  return(protoTargetCount90);  if(i == 91)  return(protoTargetCount91);
	if(i == 92)  return(protoTargetCount92);  if(i == 93)  return(protoTargetCount93);  if(i == 94)  return(protoTargetCount94);  if(i == 95)  return(protoTargetCount95);
	if(i == 96)  return(protoTargetCount96);  if(i == 97)  return(protoTargetCount97);  if(i == 98)  return(protoTargetCount98);  if(i == 99)  return(protoTargetCount99);
	if(i == 100) return(protoTargetCount100); if(i == 101) return(protoTargetCount101); if(i == 102) return(protoTargetCount102); if(i == 103) return(protoTargetCount103);
	if(i == 104) return(protoTargetCount104); if(i == 105) return(protoTargetCount105); if(i == 106) return(protoTargetCount106); if(i == 107) return(protoTargetCount107);
	if(i == 108) return(protoTargetCount108); if(i == 109) return(protoTargetCount109); if(i == 110) return(protoTargetCount110); if(i == 111) return(protoTargetCount111);
	if(i == 112) return(protoTargetCount112); if(i == 113) return(protoTargetCount113); if(i == 114) return(protoTargetCount114); if(i == 115) return(protoTargetCount115);
	if(i == 116) return(protoTargetCount116); if(i == 117) return(protoTargetCount117); if(i == 118) return(protoTargetCount118); if(i == 119) return(protoTargetCount119);
	if(i == 120) return(protoTargetCount120); if(i == 121) return(protoTargetCount121); if(i == 122) return(protoTargetCount122); if(i == 123) return(protoTargetCount123);
	if(i == 124) return(protoTargetCount124); if(i == 125) return(protoTargetCount125); if(i == 126) return(protoTargetCount126); if(i == 127) return(protoTargetCount127);
	if(i == 128) return(protoTargetCount128); if(i == 129) return(protoTargetCount129); if(i == 130) return(protoTargetCount130); if(i == 131) return(protoTargetCount131);
	if(i == 132) return(protoTargetCount132); if(i == 133) return(protoTargetCount133); if(i == 134) return(protoTargetCount134); if(i == 135) return(protoTargetCount135);
	if(i == 136) return(protoTargetCount136); if(i == 137) return(protoTargetCount137); if(i == 138) return(protoTargetCount138); if(i == 139) return(protoTargetCount139);
	if(i == 140) return(protoTargetCount140); if(i == 141) return(protoTargetCount141); if(i == 142) return(protoTargetCount142); if(i == 143) return(protoTargetCount143);
	if(i == 144) return(protoTargetCount144); if(i == 145) return(protoTargetCount145); if(i == 146) return(protoTargetCount146); if(i == 147) return(protoTargetCount147);
	if(i == 148) return(protoTargetCount148); if(i == 149) return(protoTargetCount149); if(i == 150) return(protoTargetCount150); if(i == 151) return(protoTargetCount151);
	if(i == 152) return(protoTargetCount152); if(i == 153) return(protoTargetCount153); if(i == 154) return(protoTargetCount154); if(i == 155) return(protoTargetCount155);
	if(i == 156) return(protoTargetCount156); if(i == 157) return(protoTargetCount157); if(i == 158) return(protoTargetCount158); if(i == 159) return(protoTargetCount159);
	if(i == 160) return(protoTargetCount160); if(i == 161) return(protoTargetCount161); if(i == 162) return(protoTargetCount162); if(i == 163) return(protoTargetCount163);
	if(i == 164) return(protoTargetCount164); if(i == 165) return(protoTargetCount165); if(i == 166) return(protoTargetCount166); if(i == 167) return(protoTargetCount167);
	if(i == 168) return(protoTargetCount168); if(i == 169) return(protoTargetCount169); if(i == 170) return(protoTargetCount170); if(i == 171) return(protoTargetCount171);
	if(i == 172) return(protoTargetCount172); if(i == 173) return(protoTargetCount173); if(i == 174) return(protoTargetCount174); if(i == 175) return(protoTargetCount175);
	if(i == 176) return(protoTargetCount176); if(i == 177) return(protoTargetCount177); if(i == 178) return(protoTargetCount178); if(i == 179) return(protoTargetCount179);
	if(i == 180) return(protoTargetCount180); if(i == 181) return(protoTargetCount181); if(i == 182) return(protoTargetCount182); if(i == 183) return(protoTargetCount183);
	if(i == 184) return(protoTargetCount184); if(i == 185) return(protoTargetCount185); if(i == 186) return(protoTargetCount186); if(i == 187) return(protoTargetCount187);
	if(i == 188) return(protoTargetCount188); if(i == 189) return(protoTargetCount189); if(i == 190) return(protoTargetCount190); if(i == 191) return(protoTargetCount191);
	if(i == 192) return(protoTargetCount192); if(i == 193) return(protoTargetCount193); if(i == 194) return(protoTargetCount194); if(i == 195) return(protoTargetCount195);
	if(i == 196) return(protoTargetCount196); if(i == 197) return(protoTargetCount197); if(i == 198) return(protoTargetCount198); if(i == 199) return(protoTargetCount199);
	if(i == 200) return(protoTargetCount200); if(i == 201) return(protoTargetCount201); if(i == 202) return(protoTargetCount202); if(i == 203) return(protoTargetCount203);
	if(i == 204) return(protoTargetCount204); if(i == 205) return(protoTargetCount205); if(i == 206) return(protoTargetCount206); if(i == 207) return(protoTargetCount207);
	if(i == 208) return(protoTargetCount208); if(i == 209) return(protoTargetCount209); if(i == 210) return(protoTargetCount210); if(i == 211) return(protoTargetCount211);
	if(i == 212) return(protoTargetCount212); if(i == 213) return(protoTargetCount213); if(i == 214) return(protoTargetCount214); if(i == 215) return(protoTargetCount215);
	if(i == 216) return(protoTargetCount216); if(i == 217) return(protoTargetCount217); if(i == 218) return(protoTargetCount218); if(i == 219) return(protoTargetCount219);
	if(i == 220) return(protoTargetCount220); if(i == 221) return(protoTargetCount221); if(i == 222) return(protoTargetCount222); if(i == 223) return(protoTargetCount223);
	if(i == 224) return(protoTargetCount224); if(i == 225) return(protoTargetCount225); if(i == 226) return(protoTargetCount226); if(i == 227) return(protoTargetCount227);
	if(i == 228) return(protoTargetCount228); if(i == 229) return(protoTargetCount229); if(i == 230) return(protoTargetCount230); if(i == 231) return(protoTargetCount231);
	if(i == 232) return(protoTargetCount232); if(i == 233) return(protoTargetCount233); if(i == 234) return(protoTargetCount234); if(i == 235) return(protoTargetCount235);
	if(i == 236) return(protoTargetCount236); if(i == 237) return(protoTargetCount237); if(i == 238) return(protoTargetCount238); if(i == 239) return(protoTargetCount239);
	return(0);
}

void setProtoTargetCount(int i = -1, int n = 0) {
	if(i == 0)   protoTargetCount0   = n; if(i == 1)   protoTargetCount1   = n; if(i == 2)   protoTargetCount2   = n; if(i == 3)   protoTargetCount3   = n;
	if(i == 4)   protoTargetCount4   = n; if(i == 5)   protoTargetCount5   = n; if(i == 6)   protoTargetCount6   = n; if(i == 7)   protoTargetCount7   = n;
	if(i == 8)   protoTargetCount8   = n; if(i == 9)   protoTargetCount9   = n; if(i == 10)  protoTargetCount10  = n; if(i == 11)  protoTargetCount11  = n;
	if(i == 12)  protoTargetCount12  = n; if(i == 13)  protoTargetCount13  = n; if(i == 14)  protoTargetCount14  = n; if(i == 15)  protoTargetCount15  = n;
	if(i == 16)  protoTargetCount16  = n; if(i == 17)  protoTargetCount17  = n; if(i == 18)  protoTargetCount18  = n; if(i == 19)  protoTargetCount19  = n;
	if(i == 20)  protoTargetCount20  = n; if(i == 21)  protoTargetCount21  = n; if(i == 22)  protoTargetCount22  = n; if(i == 23)  protoTargetCount23  = n;
	if(i == 24)  protoTargetCount24  = n; if(i == 25)  protoTargetCount25  = n; if(i == 26)  protoTargetCount26  = n; if(i == 27)  protoTargetCount27  = n;
	if(i == 28)  protoTargetCount28  = n; if(i == 29)  protoTargetCount29  = n; if(i == 30)  protoTargetCount30  = n; if(i == 31)  protoTargetCount31  = n;
	if(i == 32)  protoTargetCount32  = n; if(i == 33)  protoTargetCount33  = n; if(i == 34)  protoTargetCount34  = n; if(i == 35)  protoTargetCount35  = n;
	if(i == 36)  protoTargetCount36  = n; if(i == 37)  protoTargetCount37  = n; if(i == 38)  protoTargetCount38  = n; if(i == 39)  protoTargetCount39  = n;
	if(i == 40)  protoTargetCount40  = n; if(i == 41)  protoTargetCount41  = n; if(i == 42)  protoTargetCount42  = n; if(i == 43)  protoTargetCount43  = n;
	if(i == 44)  protoTargetCount44  = n; if(i == 45)  protoTargetCount45  = n; if(i == 46)  protoTargetCount46  = n; if(i == 47)  protoTargetCount47  = n;
	if(i == 48)  protoTargetCount48  = n; if(i == 49)  protoTargetCount49  = n; if(i == 50)  protoTargetCount50  = n; if(i == 51)  protoTargetCount51  = n;
	if(i == 52)  protoTargetCount52  = n; if(i == 53)  protoTargetCount53  = n; if(i == 54)  protoTargetCount54  = n; if(i == 55)  protoTargetCount55  = n;
	if(i == 56)  protoTargetCount56  = n; if(i == 57)  protoTargetCount57  = n; if(i == 58)  protoTargetCount58  = n; if(i == 59)  protoTargetCount59  = n;
	if(i == 60)  protoTargetCount60  = n; if(i == 61)  protoTargetCount61  = n; if(i == 62)  protoTargetCount62  = n; if(i == 63)  protoTargetCount63  = n;
	if(i == 64)  protoTargetCount64  = n; if(i == 65)  protoTargetCount65  = n; if(i == 66)  protoTargetCount66  = n; if(i == 67)  protoTargetCount67  = n;
	if(i == 68)  protoTargetCount68  = n; if(i == 69)  protoTargetCount69  = n; if(i == 70)  protoTargetCount70  = n; if(i == 71)  protoTargetCount71  = n;
	if(i == 72)  protoTargetCount72  = n; if(i == 73)  protoTargetCount73  = n; if(i == 74)  protoTargetCount74  = n; if(i == 75)  protoTargetCount75  = n;
	if(i == 76)  protoTargetCount76  = n; if(i == 77)  protoTargetCount77  = n; if(i == 78)  protoTargetCount78  = n; if(i == 79)  protoTargetCount79  = n;
	if(i == 80)  protoTargetCount80  = n; if(i == 81)  protoTargetCount81  = n; if(i == 82)  protoTargetCount82  = n; if(i == 83)  protoTargetCount83  = n;
	if(i == 84)  protoTargetCount84  = n; if(i == 85)  protoTargetCount85  = n; if(i == 86)  protoTargetCount86  = n; if(i == 87)  protoTargetCount87  = n;
	if(i == 88)  protoTargetCount88  = n; if(i == 89)  protoTargetCount89  = n; if(i == 90)  protoTargetCount90  = n; if(i == 91)  protoTargetCount91  = n;
	if(i == 92)  protoTargetCount92  = n; if(i == 93)  protoTargetCount93  = n; if(i == 94)  protoTargetCount94  = n; if(i == 95)  protoTargetCount95  = n;
	if(i == 96)  protoTargetCount96  = n; if(i == 97)  protoTargetCount97  = n; if(i == 98)  protoTargetCount98  = n; if(i == 99)  protoTargetCount99  = n;
	if(i == 100) protoTargetCount100 = n; if(i == 101) protoTargetCount101 = n; if(i == 102) protoTargetCount102 = n; if(i == 103) protoTargetCount103 = n;
	if(i == 104) protoTargetCount104 = n; if(i == 105) protoTargetCount105 = n; if(i == 106) protoTargetCount106 = n; if(i == 107) protoTargetCount107 = n;
	if(i == 108) protoTargetCount108 = n; if(i == 109) protoTargetCount109 = n; if(i == 110) protoTargetCount110 = n; if(i == 111) protoTargetCount111 = n;
	if(i == 112) protoTargetCount112 = n; if(i == 113) protoTargetCount113 = n; if(i == 114) protoTargetCount114 = n; if(i == 115) protoTargetCount115 = n;
	if(i == 116) protoTargetCount116 = n; if(i == 117) protoTargetCount117 = n; if(i == 118) protoTargetCount118 = n; if(i == 119) protoTargetCount119 = n;
	if(i == 120) protoTargetCount120 = n; if(i == 121) protoTargetCount121 = n; if(i == 122) protoTargetCount122 = n; if(i == 123) protoTargetCount123 = n;
	if(i == 124) protoTargetCount124 = n; if(i == 125) protoTargetCount125 = n; if(i == 126) protoTargetCount126 = n; if(i == 127) protoTargetCount127 = n;
	if(i == 128) protoTargetCount128 = n; if(i == 129) protoTargetCount129 = n; if(i == 130) protoTargetCount130 = n; if(i == 131) protoTargetCount131 = n;
	if(i == 132) protoTargetCount132 = n; if(i == 133) protoTargetCount133 = n; if(i == 134) protoTargetCount134 = n; if(i == 135) protoTargetCount135 = n;
	if(i == 136) protoTargetCount136 = n; if(i == 137) protoTargetCount137 = n; if(i == 138) protoTargetCount138 = n; if(i == 139) protoTargetCount139 = n;
	if(i == 140) protoTargetCount140 = n; if(i == 141) protoTargetCount141 = n; if(i == 142) protoTargetCount142 = n; if(i == 143) protoTargetCount143 = n;
	if(i == 144) protoTargetCount144 = n; if(i == 145) protoTargetCount145 = n; if(i == 146) protoTargetCount146 = n; if(i == 147) protoTargetCount147 = n;
	if(i == 148) protoTargetCount148 = n; if(i == 149) protoTargetCount149 = n; if(i == 150) protoTargetCount150 = n; if(i == 151) protoTargetCount151 = n;
	if(i == 152) protoTargetCount152 = n; if(i == 153) protoTargetCount153 = n; if(i == 154) protoTargetCount154 = n; if(i == 155) protoTargetCount155 = n;
	if(i == 156) protoTargetCount156 = n; if(i == 157) protoTargetCount157 = n; if(i == 158) protoTargetCount158 = n; if(i == 159) protoTargetCount159 = n;
	if(i == 160) protoTargetCount160 = n; if(i == 161) protoTargetCount161 = n; if(i == 162) protoTargetCount162 = n; if(i == 163) protoTargetCount163 = n;
	if(i == 164) protoTargetCount164 = n; if(i == 165) protoTargetCount165 = n; if(i == 166) protoTargetCount166 = n; if(i == 167) protoTargetCount167 = n;
	if(i == 168) protoTargetCount168 = n; if(i == 169) protoTargetCount169 = n; if(i == 170) protoTargetCount170 = n; if(i == 171) protoTargetCount171 = n;
	if(i == 172) protoTargetCount172 = n; if(i == 173) protoTargetCount173 = n; if(i == 174) protoTargetCount174 = n; if(i == 175) protoTargetCount175 = n;
	if(i == 176) protoTargetCount176 = n; if(i == 177) protoTargetCount177 = n; if(i == 178) protoTargetCount178 = n; if(i == 179) protoTargetCount179 = n;
	if(i == 180) protoTargetCount180 = n; if(i == 181) protoTargetCount181 = n; if(i == 182) protoTargetCount182 = n; if(i == 183) protoTargetCount183 = n;
	if(i == 184) protoTargetCount184 = n; if(i == 185) protoTargetCount185 = n; if(i == 186) protoTargetCount186 = n; if(i == 187) protoTargetCount187 = n;
	if(i == 188) protoTargetCount188 = n; if(i == 189) protoTargetCount189 = n; if(i == 190) protoTargetCount190 = n; if(i == 191) protoTargetCount191 = n;
	if(i == 192) protoTargetCount192 = n; if(i == 193) protoTargetCount193 = n; if(i == 194) protoTargetCount194 = n; if(i == 195) protoTargetCount195 = n;
	if(i == 196) protoTargetCount196 = n; if(i == 197) protoTargetCount197 = n; if(i == 198) protoTargetCount198 = n; if(i == 199) protoTargetCount199 = n;
	if(i == 200) protoTargetCount200 = n; if(i == 201) protoTargetCount201 = n; if(i == 202) protoTargetCount202 = n; if(i == 203) protoTargetCount203 = n;
	if(i == 204) protoTargetCount204 = n; if(i == 205) protoTargetCount205 = n; if(i == 206) protoTargetCount206 = n; if(i == 207) protoTargetCount207 = n;
	if(i == 208) protoTargetCount208 = n; if(i == 209) protoTargetCount209 = n; if(i == 210) protoTargetCount210 = n; if(i == 211) protoTargetCount211 = n;
	if(i == 212) protoTargetCount212 = n; if(i == 213) protoTargetCount213 = n; if(i == 214) protoTargetCount214 = n; if(i == 215) protoTargetCount215 = n;
	if(i == 216) protoTargetCount216 = n; if(i == 217) protoTargetCount217 = n; if(i == 218) protoTargetCount218 = n; if(i == 219) protoTargetCount219 = n;
	if(i == 220) protoTargetCount220 = n; if(i == 221) protoTargetCount221 = n; if(i == 222) protoTargetCount222 = n; if(i == 223) protoTargetCount223 = n;
	if(i == 224) protoTargetCount224 = n; if(i == 225) protoTargetCount225 = n; if(i == 226) protoTargetCount226 = n; if(i == 227) protoTargetCount227 = n;
	if(i == 228) protoTargetCount228 = n; if(i == 229) protoTargetCount229 = n; if(i == 230) protoTargetCount230 = n; if(i == 231) protoTargetCount231 = n;
	if(i == 232) protoTargetCount232 = n; if(i == 233) protoTargetCount233 = n; if(i == 234) protoTargetCount234 = n; if(i == 235) protoTargetCount235 = n;
	if(i == 236) protoTargetCount236 = n; if(i == 237) protoTargetCount237 = n; if(i == 238) protoTargetCount238 = n; if(i == 239) protoTargetCount239 = n;
}

// Contains the owner of the objects (defaults to Mother Nature).
int protoOwner0   = 0; int protoOwner1   = 0; int protoOwner2   = 0; int protoOwner3   = 0;
int protoOwner4   = 0; int protoOwner5   = 0; int protoOwner6   = 0; int protoOwner7   = 0;
int protoOwner8   = 0; int protoOwner9   = 0; int protoOwner10  = 0; int protoOwner11  = 0;
int protoOwner12  = 0; int protoOwner13  = 0; int protoOwner14  = 0; int protoOwner15  = 0;
int protoOwner16  = 0; int protoOwner17  = 0; int protoOwner18  = 0; int protoOwner19  = 0;
int protoOwner20  = 0; int protoOwner21  = 0; int protoOwner22  = 0; int protoOwner23  = 0;
int protoOwner24  = 0; int protoOwner25  = 0; int protoOwner26  = 0; int protoOwner27  = 0;
int protoOwner28  = 0; int protoOwner29  = 0; int protoOwner30  = 0; int protoOwner31  = 0;
int protoOwner32  = 0; int protoOwner33  = 0; int protoOwner34  = 0; int protoOwner35  = 0;
int protoOwner36  = 0; int protoOwner37  = 0; int protoOwner38  = 0; int protoOwner39  = 0;
int protoOwner40  = 0; int protoOwner41  = 0; int protoOwner42  = 0; int protoOwner43  = 0;
int protoOwner44  = 0; int protoOwner45  = 0; int protoOwner46  = 0; int protoOwner47  = 0;
int protoOwner48  = 0; int protoOwner49  = 0; int protoOwner50  = 0; int protoOwner51  = 0;
int protoOwner52  = 0; int protoOwner53  = 0; int protoOwner54  = 0; int protoOwner55  = 0;
int protoOwner56  = 0; int protoOwner57  = 0; int protoOwner58  = 0; int protoOwner59  = 0;
int protoOwner60  = 0; int protoOwner61  = 0; int protoOwner62  = 0; int protoOwner63  = 0;
int protoOwner64  = 0; int protoOwner65  = 0; int protoOwner66  = 0; int protoOwner67  = 0;
int protoOwner68  = 0; int protoOwner69  = 0; int protoOwner70  = 0; int protoOwner71  = 0;
int protoOwner72  = 0; int protoOwner73  = 0; int protoOwner74  = 0; int protoOwner75  = 0;
int protoOwner76  = 0; int protoOwner77  = 0; int protoOwner78  = 0; int protoOwner79  = 0;
int protoOwner80  = 0; int protoOwner81  = 0; int protoOwner82  = 0; int protoOwner83  = 0;
int protoOwner84  = 0; int protoOwner85  = 0; int protoOwner86  = 0; int protoOwner87  = 0;
int protoOwner88  = 0; int protoOwner89  = 0; int protoOwner90  = 0; int protoOwner91  = 0;
int protoOwner92  = 0; int protoOwner93  = 0; int protoOwner94  = 0; int protoOwner95  = 0;
int protoOwner96  = 0; int protoOwner97  = 0; int protoOwner98  = 0; int protoOwner99  = 0;
int protoOwner100 = 0; int protoOwner101 = 0; int protoOwner102 = 0; int protoOwner103 = 0;
int protoOwner104 = 0; int protoOwner105 = 0; int protoOwner106 = 0; int protoOwner107 = 0;
int protoOwner108 = 0; int protoOwner109 = 0; int protoOwner110 = 0; int protoOwner111 = 0;
int protoOwner112 = 0; int protoOwner113 = 0; int protoOwner114 = 0; int protoOwner115 = 0;
int protoOwner116 = 0; int protoOwner117 = 0; int protoOwner118 = 0; int protoOwner119 = 0;
int protoOwner120 = 0; int protoOwner121 = 0; int protoOwner122 = 0; int protoOwner123 = 0;
int protoOwner124 = 0; int protoOwner125 = 0; int protoOwner126 = 0; int protoOwner127 = 0;
int protoOwner128 = 0; int protoOwner129 = 0; int protoOwner130 = 0; int protoOwner131 = 0;
int protoOwner132 = 0; int protoOwner133 = 0; int protoOwner134 = 0; int protoOwner135 = 0;
int protoOwner136 = 0; int protoOwner137 = 0; int protoOwner138 = 0; int protoOwner139 = 0;
int protoOwner140 = 0; int protoOwner141 = 0; int protoOwner142 = 0; int protoOwner143 = 0;
int protoOwner144 = 0; int protoOwner145 = 0; int protoOwner146 = 0; int protoOwner147 = 0;
int protoOwner148 = 0; int protoOwner149 = 0; int protoOwner150 = 0; int protoOwner151 = 0;
int protoOwner152 = 0; int protoOwner153 = 0; int protoOwner154 = 0; int protoOwner155 = 0;
int protoOwner156 = 0; int protoOwner157 = 0; int protoOwner158 = 0; int protoOwner159 = 0;
int protoOwner160 = 0; int protoOwner161 = 0; int protoOwner162 = 0; int protoOwner163 = 0;
int protoOwner164 = 0; int protoOwner165 = 0; int protoOwner166 = 0; int protoOwner167 = 0;
int protoOwner168 = 0; int protoOwner169 = 0; int protoOwner170 = 0; int protoOwner171 = 0;
int protoOwner172 = 0; int protoOwner173 = 0; int protoOwner174 = 0; int protoOwner175 = 0;
int protoOwner176 = 0; int protoOwner177 = 0; int protoOwner178 = 0; int protoOwner179 = 0;
int protoOwner180 = 0; int protoOwner181 = 0; int protoOwner182 = 0; int protoOwner183 = 0;
int protoOwner184 = 0; int protoOwner185 = 0; int protoOwner186 = 0; int protoOwner187 = 0;
int protoOwner188 = 0; int protoOwner189 = 0; int protoOwner190 = 0; int protoOwner191 = 0;
int protoOwner192 = 0; int protoOwner193 = 0; int protoOwner194 = 0; int protoOwner195 = 0;
int protoOwner196 = 0; int protoOwner197 = 0; int protoOwner198 = 0; int protoOwner199 = 0;
int protoOwner200 = 0; int protoOwner201 = 0; int protoOwner202 = 0; int protoOwner203 = 0;
int protoOwner204 = 0; int protoOwner205 = 0; int protoOwner206 = 0; int protoOwner207 = 0;
int protoOwner208 = 0; int protoOwner209 = 0; int protoOwner210 = 0; int protoOwner211 = 0;
int protoOwner212 = 0; int protoOwner213 = 0; int protoOwner214 = 0; int protoOwner215 = 0;
int protoOwner216 = 0; int protoOwner217 = 0; int protoOwner218 = 0; int protoOwner219 = 0;
int protoOwner220 = 0; int protoOwner221 = 0; int protoOwner222 = 0; int protoOwner223 = 0;
int protoOwner224 = 0; int protoOwner225 = 0; int protoOwner226 = 0; int protoOwner227 = 0;
int protoOwner228 = 0; int protoOwner229 = 0; int protoOwner230 = 0; int protoOwner231 = 0;
int protoOwner232 = 0; int protoOwner233 = 0; int protoOwner234 = 0; int protoOwner235 = 0;
int protoOwner236 = 0; int protoOwner237 = 0; int protoOwner238 = 0; int protoOwner239 = 0;

int getProtoOwner(int i = -1) {
	if(i == 0)   return(protoOwner0);   if(i == 1)   return(protoOwner1);   if(i == 2)   return(protoOwner2);   if(i == 3)   return(protoOwner3);
	if(i == 4)   return(protoOwner4);   if(i == 5)   return(protoOwner5);   if(i == 6)   return(protoOwner6);   if(i == 7)   return(protoOwner7);
	if(i == 8)   return(protoOwner8);   if(i == 9)   return(protoOwner9);   if(i == 10)  return(protoOwner10);  if(i == 11)  return(protoOwner11);
	if(i == 12)  return(protoOwner12);  if(i == 13)  return(protoOwner13);  if(i == 14)  return(protoOwner14);  if(i == 15)  return(protoOwner15);
	if(i == 16)  return(protoOwner16);  if(i == 17)  return(protoOwner17);  if(i == 18)  return(protoOwner18);  if(i == 19)  return(protoOwner19);
	if(i == 20)  return(protoOwner20);  if(i == 21)  return(protoOwner21);  if(i == 22)  return(protoOwner22);  if(i == 23)  return(protoOwner23);
	if(i == 24)  return(protoOwner24);  if(i == 25)  return(protoOwner25);  if(i == 26)  return(protoOwner26);  if(i == 27)  return(protoOwner27);
	if(i == 28)  return(protoOwner28);  if(i == 29)  return(protoOwner29);  if(i == 30)  return(protoOwner30);  if(i == 31)  return(protoOwner31);
	if(i == 32)  return(protoOwner32);  if(i == 33)  return(protoOwner33);  if(i == 34)  return(protoOwner34);  if(i == 35)  return(protoOwner35);
	if(i == 36)  return(protoOwner36);  if(i == 37)  return(protoOwner37);  if(i == 38)  return(protoOwner38);  if(i == 39)  return(protoOwner39);
	if(i == 40)  return(protoOwner40);  if(i == 41)  return(protoOwner41);  if(i == 42)  return(protoOwner42);  if(i == 43)  return(protoOwner43);
	if(i == 44)  return(protoOwner44);  if(i == 45)  return(protoOwner45);  if(i == 46)  return(protoOwner46);  if(i == 47)  return(protoOwner47);
	if(i == 48)  return(protoOwner48);  if(i == 49)  return(protoOwner49);  if(i == 50)  return(protoOwner50);  if(i == 51)  return(protoOwner51);
	if(i == 52)  return(protoOwner52);  if(i == 53)  return(protoOwner53);  if(i == 54)  return(protoOwner54);  if(i == 55)  return(protoOwner55);
	if(i == 56)  return(protoOwner56);  if(i == 57)  return(protoOwner57);  if(i == 58)  return(protoOwner58);  if(i == 59)  return(protoOwner59);
	if(i == 60)  return(protoOwner60);  if(i == 61)  return(protoOwner61);  if(i == 62)  return(protoOwner62);  if(i == 63)  return(protoOwner63);
	if(i == 64)  return(protoOwner64);  if(i == 65)  return(protoOwner65);  if(i == 66)  return(protoOwner66);  if(i == 67)  return(protoOwner67);
	if(i == 68)  return(protoOwner68);  if(i == 69)  return(protoOwner69);  if(i == 70)  return(protoOwner70);  if(i == 71)  return(protoOwner71);
	if(i == 72)  return(protoOwner72);  if(i == 73)  return(protoOwner73);  if(i == 74)  return(protoOwner74);  if(i == 75)  return(protoOwner75);
	if(i == 76)  return(protoOwner76);  if(i == 77)  return(protoOwner77);  if(i == 78)  return(protoOwner78);  if(i == 79)  return(protoOwner79);
	if(i == 80)  return(protoOwner80);  if(i == 81)  return(protoOwner81);  if(i == 82)  return(protoOwner82);  if(i == 83)  return(protoOwner83);
	if(i == 84)  return(protoOwner84);  if(i == 85)  return(protoOwner85);  if(i == 86)  return(protoOwner86);  if(i == 87)  return(protoOwner87);
	if(i == 88)  return(protoOwner88);  if(i == 89)  return(protoOwner89);  if(i == 90)  return(protoOwner90);  if(i == 91)  return(protoOwner91);
	if(i == 92)  return(protoOwner92);  if(i == 93)  return(protoOwner93);  if(i == 94)  return(protoOwner94);  if(i == 95)  return(protoOwner95);
	if(i == 96)  return(protoOwner96);  if(i == 97)  return(protoOwner97);  if(i == 98)  return(protoOwner98);  if(i == 99)  return(protoOwner99);
	if(i == 100) return(protoOwner100); if(i == 101) return(protoOwner101); if(i == 102) return(protoOwner102); if(i == 103) return(protoOwner103);
	if(i == 104) return(protoOwner104); if(i == 105) return(protoOwner105); if(i == 106) return(protoOwner106); if(i == 107) return(protoOwner107);
	if(i == 108) return(protoOwner108); if(i == 109) return(protoOwner109); if(i == 110) return(protoOwner110); if(i == 111) return(protoOwner111);
	if(i == 112) return(protoOwner112); if(i == 113) return(protoOwner113); if(i == 114) return(protoOwner114); if(i == 115) return(protoOwner115);
	if(i == 116) return(protoOwner116); if(i == 117) return(protoOwner117); if(i == 118) return(protoOwner118); if(i == 119) return(protoOwner119);
	if(i == 120) return(protoOwner120); if(i == 121) return(protoOwner121); if(i == 122) return(protoOwner122); if(i == 123) return(protoOwner123);
	if(i == 124) return(protoOwner124); if(i == 125) return(protoOwner125); if(i == 126) return(protoOwner126); if(i == 127) return(protoOwner127);
	if(i == 128) return(protoOwner128); if(i == 129) return(protoOwner129); if(i == 130) return(protoOwner130); if(i == 131) return(protoOwner131);
	if(i == 132) return(protoOwner132); if(i == 133) return(protoOwner133); if(i == 134) return(protoOwner134); if(i == 135) return(protoOwner135);
	if(i == 136) return(protoOwner136); if(i == 137) return(protoOwner137); if(i == 138) return(protoOwner138); if(i == 139) return(protoOwner139);
	if(i == 140) return(protoOwner140); if(i == 141) return(protoOwner141); if(i == 142) return(protoOwner142); if(i == 143) return(protoOwner143);
	if(i == 144) return(protoOwner144); if(i == 145) return(protoOwner145); if(i == 146) return(protoOwner146); if(i == 147) return(protoOwner147);
	if(i == 148) return(protoOwner148); if(i == 149) return(protoOwner149); if(i == 150) return(protoOwner150); if(i == 151) return(protoOwner151);
	if(i == 152) return(protoOwner152); if(i == 153) return(protoOwner153); if(i == 154) return(protoOwner154); if(i == 155) return(protoOwner155);
	if(i == 156) return(protoOwner156); if(i == 157) return(protoOwner157); if(i == 158) return(protoOwner158); if(i == 159) return(protoOwner159);
	if(i == 160) return(protoOwner160); if(i == 161) return(protoOwner161); if(i == 162) return(protoOwner162); if(i == 163) return(protoOwner163);
	if(i == 164) return(protoOwner164); if(i == 165) return(protoOwner165); if(i == 166) return(protoOwner166); if(i == 167) return(protoOwner167);
	if(i == 168) return(protoOwner168); if(i == 169) return(protoOwner169); if(i == 170) return(protoOwner170); if(i == 171) return(protoOwner171);
	if(i == 172) return(protoOwner172); if(i == 173) return(protoOwner173); if(i == 174) return(protoOwner174); if(i == 175) return(protoOwner175);
	if(i == 176) return(protoOwner176); if(i == 177) return(protoOwner177); if(i == 178) return(protoOwner178); if(i == 179) return(protoOwner179);
	if(i == 180) return(protoOwner180); if(i == 181) return(protoOwner181); if(i == 182) return(protoOwner182); if(i == 183) return(protoOwner183);
	if(i == 184) return(protoOwner184); if(i == 185) return(protoOwner185); if(i == 186) return(protoOwner186); if(i == 187) return(protoOwner187);
	if(i == 188) return(protoOwner188); if(i == 189) return(protoOwner189); if(i == 190) return(protoOwner190); if(i == 191) return(protoOwner191);
	if(i == 192) return(protoOwner192); if(i == 193) return(protoOwner193); if(i == 194) return(protoOwner194); if(i == 195) return(protoOwner195);
	if(i == 196) return(protoOwner196); if(i == 197) return(protoOwner197); if(i == 198) return(protoOwner198); if(i == 199) return(protoOwner199);
	if(i == 200) return(protoOwner200); if(i == 201) return(protoOwner201); if(i == 202) return(protoOwner202); if(i == 203) return(protoOwner203);
	if(i == 204) return(protoOwner204); if(i == 205) return(protoOwner205); if(i == 206) return(protoOwner206); if(i == 207) return(protoOwner207);
	if(i == 208) return(protoOwner208); if(i == 209) return(protoOwner209); if(i == 210) return(protoOwner210); if(i == 211) return(protoOwner211);
	if(i == 212) return(protoOwner212); if(i == 213) return(protoOwner213); if(i == 214) return(protoOwner214); if(i == 215) return(protoOwner215);
	if(i == 216) return(protoOwner216); if(i == 217) return(protoOwner217); if(i == 218) return(protoOwner218); if(i == 219) return(protoOwner219);
	if(i == 220) return(protoOwner220); if(i == 221) return(protoOwner221); if(i == 222) return(protoOwner222); if(i == 223) return(protoOwner223);
	if(i == 224) return(protoOwner224); if(i == 225) return(protoOwner225); if(i == 226) return(protoOwner226); if(i == 227) return(protoOwner227);
	if(i == 228) return(protoOwner228); if(i == 229) return(protoOwner229); if(i == 230) return(protoOwner230); if(i == 231) return(protoOwner231);
	if(i == 232) return(protoOwner232); if(i == 233) return(protoOwner233); if(i == 234) return(protoOwner234); if(i == 235) return(protoOwner235);
	if(i == 236) return(protoOwner236); if(i == 237) return(protoOwner237); if(i == 238) return(protoOwner238); if(i == 239) return(protoOwner239);
	return(0);
}

void setProtoOwner(int i = -1, int n = 0) {
	if(i == 0)   protoOwner0   = n; if(i == 1)   protoOwner1   = n; if(i == 2)   protoOwner2   = n; if(i == 3)   protoOwner3   = n;
	if(i == 4)   protoOwner4   = n; if(i == 5)   protoOwner5   = n; if(i == 6)   protoOwner6   = n; if(i == 7)   protoOwner7   = n;
	if(i == 8)   protoOwner8   = n; if(i == 9)   protoOwner9   = n; if(i == 10)  protoOwner10  = n; if(i == 11)  protoOwner11  = n;
	if(i == 12)  protoOwner12  = n; if(i == 13)  protoOwner13  = n; if(i == 14)  protoOwner14  = n; if(i == 15)  protoOwner15  = n;
	if(i == 16)  protoOwner16  = n; if(i == 17)  protoOwner17  = n; if(i == 18)  protoOwner18  = n; if(i == 19)  protoOwner19  = n;
	if(i == 20)  protoOwner20  = n; if(i == 21)  protoOwner21  = n; if(i == 22)  protoOwner22  = n; if(i == 23)  protoOwner23  = n;
	if(i == 24)  protoOwner24  = n; if(i == 25)  protoOwner25  = n; if(i == 26)  protoOwner26  = n; if(i == 27)  protoOwner27  = n;
	if(i == 28)  protoOwner28  = n; if(i == 29)  protoOwner29  = n; if(i == 30)  protoOwner30  = n; if(i == 31)  protoOwner31  = n;
	if(i == 32)  protoOwner32  = n; if(i == 33)  protoOwner33  = n; if(i == 34)  protoOwner34  = n; if(i == 35)  protoOwner35  = n;
	if(i == 36)  protoOwner36  = n; if(i == 37)  protoOwner37  = n; if(i == 38)  protoOwner38  = n; if(i == 39)  protoOwner39  = n;
	if(i == 40)  protoOwner40  = n; if(i == 41)  protoOwner41  = n; if(i == 42)  protoOwner42  = n; if(i == 43)  protoOwner43  = n;
	if(i == 44)  protoOwner44  = n; if(i == 45)  protoOwner45  = n; if(i == 46)  protoOwner46  = n; if(i == 47)  protoOwner47  = n;
	if(i == 48)  protoOwner48  = n; if(i == 49)  protoOwner49  = n; if(i == 50)  protoOwner50  = n; if(i == 51)  protoOwner51  = n;
	if(i == 52)  protoOwner52  = n; if(i == 53)  protoOwner53  = n; if(i == 54)  protoOwner54  = n; if(i == 55)  protoOwner55  = n;
	if(i == 56)  protoOwner56  = n; if(i == 57)  protoOwner57  = n; if(i == 58)  protoOwner58  = n; if(i == 59)  protoOwner59  = n;
	if(i == 60)  protoOwner60  = n; if(i == 61)  protoOwner61  = n; if(i == 62)  protoOwner62  = n; if(i == 63)  protoOwner63  = n;
	if(i == 64)  protoOwner64  = n; if(i == 65)  protoOwner65  = n; if(i == 66)  protoOwner66  = n; if(i == 67)  protoOwner67  = n;
	if(i == 68)  protoOwner68  = n; if(i == 69)  protoOwner69  = n; if(i == 70)  protoOwner70  = n; if(i == 71)  protoOwner71  = n;
	if(i == 72)  protoOwner72  = n; if(i == 73)  protoOwner73  = n; if(i == 74)  protoOwner74  = n; if(i == 75)  protoOwner75  = n;
	if(i == 76)  protoOwner76  = n; if(i == 77)  protoOwner77  = n; if(i == 78)  protoOwner78  = n; if(i == 79)  protoOwner79  = n;
	if(i == 80)  protoOwner80  = n; if(i == 81)  protoOwner81  = n; if(i == 82)  protoOwner82  = n; if(i == 83)  protoOwner83  = n;
	if(i == 84)  protoOwner84  = n; if(i == 85)  protoOwner85  = n; if(i == 86)  protoOwner86  = n; if(i == 87)  protoOwner87  = n;
	if(i == 88)  protoOwner88  = n; if(i == 89)  protoOwner89  = n; if(i == 90)  protoOwner90  = n; if(i == 91)  protoOwner91  = n;
	if(i == 92)  protoOwner92  = n; if(i == 93)  protoOwner93  = n; if(i == 94)  protoOwner94  = n; if(i == 95)  protoOwner95  = n;
	if(i == 96)  protoOwner96  = n; if(i == 97)  protoOwner97  = n; if(i == 98)  protoOwner98  = n; if(i == 99)  protoOwner99  = n;
	if(i == 100) protoOwner100 = n; if(i == 101) protoOwner101 = n; if(i == 102) protoOwner102 = n; if(i == 103) protoOwner103 = n;
	if(i == 104) protoOwner104 = n; if(i == 105) protoOwner105 = n; if(i == 106) protoOwner106 = n; if(i == 107) protoOwner107 = n;
	if(i == 108) protoOwner108 = n; if(i == 109) protoOwner109 = n; if(i == 110) protoOwner110 = n; if(i == 111) protoOwner111 = n;
	if(i == 112) protoOwner112 = n; if(i == 113) protoOwner113 = n; if(i == 114) protoOwner114 = n; if(i == 115) protoOwner115 = n;
	if(i == 116) protoOwner116 = n; if(i == 117) protoOwner117 = n; if(i == 118) protoOwner118 = n; if(i == 119) protoOwner119 = n;
	if(i == 120) protoOwner120 = n; if(i == 121) protoOwner121 = n; if(i == 122) protoOwner122 = n; if(i == 123) protoOwner123 = n;
	if(i == 124) protoOwner124 = n; if(i == 125) protoOwner125 = n; if(i == 126) protoOwner126 = n; if(i == 127) protoOwner127 = n;
	if(i == 128) protoOwner128 = n; if(i == 129) protoOwner129 = n; if(i == 130) protoOwner130 = n; if(i == 131) protoOwner131 = n;
	if(i == 132) protoOwner132 = n; if(i == 133) protoOwner133 = n; if(i == 134) protoOwner134 = n; if(i == 135) protoOwner135 = n;
	if(i == 136) protoOwner136 = n; if(i == 137) protoOwner137 = n; if(i == 138) protoOwner138 = n; if(i == 139) protoOwner139 = n;
	if(i == 140) protoOwner140 = n; if(i == 141) protoOwner141 = n; if(i == 142) protoOwner142 = n; if(i == 143) protoOwner143 = n;
	if(i == 144) protoOwner144 = n; if(i == 145) protoOwner145 = n; if(i == 146) protoOwner146 = n; if(i == 147) protoOwner147 = n;
	if(i == 148) protoOwner148 = n; if(i == 149) protoOwner149 = n; if(i == 150) protoOwner150 = n; if(i == 151) protoOwner151 = n;
	if(i == 152) protoOwner152 = n; if(i == 153) protoOwner153 = n; if(i == 154) protoOwner154 = n; if(i == 155) protoOwner155 = n;
	if(i == 156) protoOwner156 = n; if(i == 157) protoOwner157 = n; if(i == 158) protoOwner158 = n; if(i == 159) protoOwner159 = n;
	if(i == 160) protoOwner160 = n; if(i == 161) protoOwner161 = n; if(i == 162) protoOwner162 = n; if(i == 163) protoOwner163 = n;
	if(i == 164) protoOwner164 = n; if(i == 165) protoOwner165 = n; if(i == 166) protoOwner166 = n; if(i == 167) protoOwner167 = n;
	if(i == 168) protoOwner168 = n; if(i == 169) protoOwner169 = n; if(i == 170) protoOwner170 = n; if(i == 171) protoOwner171 = n;
	if(i == 172) protoOwner172 = n; if(i == 173) protoOwner173 = n; if(i == 174) protoOwner174 = n; if(i == 175) protoOwner175 = n;
	if(i == 176) protoOwner176 = n; if(i == 177) protoOwner177 = n; if(i == 178) protoOwner178 = n; if(i == 179) protoOwner179 = n;
	if(i == 180) protoOwner180 = n; if(i == 181) protoOwner181 = n; if(i == 182) protoOwner182 = n; if(i == 183) protoOwner183 = n;
	if(i == 184) protoOwner184 = n; if(i == 185) protoOwner185 = n; if(i == 186) protoOwner186 = n; if(i == 187) protoOwner187 = n;
	if(i == 188) protoOwner188 = n; if(i == 189) protoOwner189 = n; if(i == 190) protoOwner190 = n; if(i == 191) protoOwner191 = n;
	if(i == 192) protoOwner192 = n; if(i == 193) protoOwner193 = n; if(i == 194) protoOwner194 = n; if(i == 195) protoOwner195 = n;
	if(i == 196) protoOwner196 = n; if(i == 197) protoOwner197 = n; if(i == 198) protoOwner198 = n; if(i == 199) protoOwner199 = n;
	if(i == 200) protoOwner200 = n; if(i == 201) protoOwner201 = n; if(i == 202) protoOwner202 = n; if(i == 203) protoOwner203 = n;
	if(i == 204) protoOwner204 = n; if(i == 205) protoOwner205 = n; if(i == 206) protoOwner206 = n; if(i == 207) protoOwner207 = n;
	if(i == 208) protoOwner208 = n; if(i == 209) protoOwner209 = n; if(i == 210) protoOwner210 = n; if(i == 211) protoOwner211 = n;
	if(i == 212) protoOwner212 = n; if(i == 213) protoOwner213 = n; if(i == 214) protoOwner214 = n; if(i == 215) protoOwner215 = n;
	if(i == 216) protoOwner216 = n; if(i == 217) protoOwner217 = n; if(i == 218) protoOwner218 = n; if(i == 219) protoOwner219 = n;
	if(i == 220) protoOwner220 = n; if(i == 221) protoOwner221 = n; if(i == 222) protoOwner222 = n; if(i == 223) protoOwner223 = n;
	if(i == 224) protoOwner224 = n; if(i == 225) protoOwner225 = n; if(i == 226) protoOwner226 = n; if(i == 227) protoOwner227 = n;
	if(i == 228) protoOwner228 = n; if(i == 229) protoOwner229 = n; if(i == 230) protoOwner230 = n; if(i == 231) protoOwner231 = n;
	if(i == 232) protoOwner232 = n; if(i == 233) protoOwner233 = n; if(i == 234) protoOwner234 = n; if(i == 235) protoOwner235 = n;
	if(i == 236) protoOwner236 = n; if(i == 237) protoOwner237 = n; if(i == 238) protoOwner238 = n; if(i == 239) protoOwner239 = n;
}

/*
** Adds a new proto to the check along with the desired count.
**
** @param protoName: the proto name of the object to check
** @param totalCount: the total amount of times the object has to be present on the map
** @param protoOwner: the player number of the owner (unmapped!)
**/
void addProtoPlacementCheck(string protoName = "", int totalCount = 0, int protoOwner = 0) {
	setProtoName(protoCheckCount, protoName);
	setProtoTargetCount(protoCheckCount, totalCount);
	setProtoOwner(protoCheckCount, getPlayer(protoOwner));

	protoCheckCount++;
}

/******************
* PLACEMENT CHECK *
******************/

int objectCheckCount = 0;

// Contains object IDs for objects to check when placed.
int objectID0  = 0; int objectID1  = 0; int objectID2  = 0; int objectID3  = 0;
int objectID4  = 0; int objectID5  = 0; int objectID6  = 0; int objectID7  = 0;
int objectID8  = 0; int objectID9  = 0; int objectID10 = 0; int objectID11 = 0;
int objectID12 = 0; int objectID13 = 0; int objectID14 = 0; int objectID15 = 0;
int objectID16 = 0; int objectID17 = 0; int objectID18 = 0; int objectID19 = 0;
int objectID20 = 0; int objectID21 = 0; int objectID22 = 0; int objectID23 = 0;
int objectID24 = 0; int objectID25 = 0; int objectID26 = 0; int objectID27 = 0;
int objectID28 = 0; int objectID29 = 0; int objectID30 = 0; int objectID31 = 0;
int objectID32 = 0; int objectID33 = 0; int objectID34 = 0; int objectID35 = 0;
int objectID36 = 0; int objectID37 = 0; int objectID38 = 0; int objectID39 = 0;
int objectID40 = 0; int objectID41 = 0; int objectID42 = 0; int objectID43 = 0;
int objectID44 = 0; int objectID45 = 0; int objectID46 = 0; int objectID47 = 0;
int objectID48 = 0; int objectID49 = 0; int objectID50 = 0; int objectID51 = 0;
int objectID52 = 0; int objectID53 = 0; int objectID54 = 0; int objectID55 = 0;
int objectID56 = 0; int objectID57 = 0; int objectID58 = 0; int objectID59 = 0;
int objectID60 = 0; int objectID61 = 0; int objectID62 = 0; int objectID63 = 0;

int getObjectID(int i = -1) {
	if(i == 0)  return(objectID0);  if(i == 1)  return(objectID1);  if(i == 2)  return(objectID2);  if(i == 3)  return(objectID3);
	if(i == 4)  return(objectID4);  if(i == 5)  return(objectID5);  if(i == 6)  return(objectID6);  if(i == 7)  return(objectID7);
	if(i == 8)  return(objectID8);  if(i == 9)  return(objectID9);  if(i == 10) return(objectID10); if(i == 11) return(objectID11);
	if(i == 12) return(objectID12); if(i == 13) return(objectID13); if(i == 14) return(objectID14); if(i == 15) return(objectID15);
	if(i == 16) return(objectID16); if(i == 17) return(objectID17); if(i == 18) return(objectID18); if(i == 19) return(objectID19);
	if(i == 20) return(objectID20); if(i == 21) return(objectID21); if(i == 22) return(objectID22); if(i == 23) return(objectID23);
	if(i == 24) return(objectID24); if(i == 25) return(objectID25); if(i == 26) return(objectID26); if(i == 27) return(objectID27);
	if(i == 28) return(objectID28); if(i == 29) return(objectID29); if(i == 30) return(objectID30); if(i == 31) return(objectID31);
	if(i == 32) return(objectID32); if(i == 33) return(objectID33); if(i == 34) return(objectID34); if(i == 35) return(objectID35);
	if(i == 36) return(objectID36); if(i == 37) return(objectID37); if(i == 38) return(objectID38); if(i == 39) return(objectID39);
	if(i == 40) return(objectID40); if(i == 41) return(objectID41); if(i == 42) return(objectID42); if(i == 43) return(objectID43);
	if(i == 44) return(objectID44); if(i == 45) return(objectID45); if(i == 46) return(objectID46); if(i == 47) return(objectID47);
	if(i == 48) return(objectID48); if(i == 49) return(objectID49); if(i == 50) return(objectID50); if(i == 51) return(objectID51);
	if(i == 52) return(objectID52); if(i == 53) return(objectID53); if(i == 54) return(objectID54); if(i == 55) return(objectID55);
	if(i == 56) return(objectID56); if(i == 57) return(objectID57); if(i == 58) return(objectID58); if(i == 59) return(objectID59);
	if(i == 60) return(objectID60); if(i == 61) return(objectID61); if(i == 62) return(objectID62); if(i == 63) return(objectID63);
	return(-1);
}

void setObjectID(int i = -1, int id = 0) {
	if(i == 0)  objectID0  = id; if(i == 1)  objectID1  = id; if(i == 2)  objectID2  = id; if(i == 3)  objectID3  = id;
	if(i == 4)  objectID4  = id; if(i == 5)  objectID5  = id; if(i == 6)  objectID6  = id; if(i == 7)  objectID7  = id;
	if(i == 8)  objectID8  = id; if(i == 9)  objectID9  = id; if(i == 10) objectID10 = id; if(i == 11) objectID11 = id;
	if(i == 12) objectID12 = id; if(i == 13) objectID13 = id; if(i == 14) objectID14 = id; if(i == 15) objectID15 = id;
	if(i == 16) objectID16 = id; if(i == 17) objectID17 = id; if(i == 18) objectID18 = id; if(i == 19) objectID19 = id;
	if(i == 20) objectID20 = id; if(i == 21) objectID21 = id; if(i == 22) objectID22 = id; if(i == 23) objectID23 = id;
	if(i == 24) objectID24 = id; if(i == 25) objectID25 = id; if(i == 26) objectID26 = id; if(i == 27) objectID27 = id;
	if(i == 28) objectID28 = id; if(i == 29) objectID29 = id; if(i == 30) objectID30 = id; if(i == 31) objectID31 = id;
	if(i == 32) objectID32 = id; if(i == 33) objectID33 = id; if(i == 34) objectID34 = id; if(i == 35) objectID35 = id;
	if(i == 36) objectID36 = id; if(i == 37) objectID37 = id; if(i == 38) objectID38 = id; if(i == 39) objectID39 = id;
	if(i == 40) objectID40 = id; if(i == 41) objectID41 = id; if(i == 42) objectID42 = id; if(i == 43) objectID43 = id;
	if(i == 44) objectID44 = id; if(i == 45) objectID45 = id; if(i == 46) objectID46 = id; if(i == 47) objectID47 = id;
	if(i == 48) objectID48 = id; if(i == 49) objectID49 = id; if(i == 50) objectID50 = id; if(i == 51) objectID51 = id;
	if(i == 52) objectID52 = id; if(i == 53) objectID53 = id; if(i == 54) objectID54 = id; if(i == 55) objectID55 = id;
	if(i == 56) objectID56 = id; if(i == 57) objectID57 = id; if(i == 58) objectID58 = id; if(i == 59) objectID59 = id;
	if(i == 60) objectID60 = id; if(i == 61) objectID61 = id; if(i == 62) objectID62 = id; if(i == 63) objectID63 = id;
}

// Contains the label (given into rmCreateObjectDef()) of the objects.
string objectLabel0  = "?"; string objectLabel1  = "?"; string objectLabel2  = "?"; string objectLabel3  = "?";
string objectLabel4  = "?"; string objectLabel5  = "?"; string objectLabel6  = "?"; string objectLabel7  = "?";
string objectLabel8  = "?"; string objectLabel9  = "?"; string objectLabel10 = "?"; string objectLabel11 = "?";
string objectLabel12 = "?"; string objectLabel13 = "?"; string objectLabel14 = "?"; string objectLabel15 = "?";
string objectLabel16 = "?"; string objectLabel17 = "?"; string objectLabel18 = "?"; string objectLabel19 = "?";
string objectLabel20 = "?"; string objectLabel21 = "?"; string objectLabel22 = "?"; string objectLabel23 = "?";
string objectLabel24 = "?"; string objectLabel25 = "?"; string objectLabel26 = "?"; string objectLabel27 = "?";
string objectLabel28 = "?"; string objectLabel29 = "?"; string objectLabel30 = "?"; string objectLabel31 = "?";
string objectLabel32 = "?"; string objectLabel33 = "?"; string objectLabel34 = "?"; string objectLabel35 = "?";
string objectLabel36 = "?"; string objectLabel37 = "?"; string objectLabel38 = "?"; string objectLabel39 = "?";
string objectLabel40 = "?"; string objectLabel41 = "?"; string objectLabel42 = "?"; string objectLabel43 = "?";
string objectLabel44 = "?"; string objectLabel45 = "?"; string objectLabel46 = "?"; string objectLabel47 = "?";
string objectLabel48 = "?"; string objectLabel49 = "?"; string objectLabel50 = "?"; string objectLabel51 = "?";
string objectLabel52 = "?"; string objectLabel53 = "?"; string objectLabel54 = "?"; string objectLabel55 = "?";
string objectLabel56 = "?"; string objectLabel57 = "?"; string objectLabel58 = "?"; string objectLabel59 = "?";
string objectLabel60 = "?"; string objectLabel61 = "?"; string objectLabel62 = "?"; string objectLabel63 = "?";

string getObjectLabel(int i = -1) {
	if(i == 0)  return(objectLabel0);  if(i == 1)  return(objectLabel1);  if(i == 2)  return(objectLabel2);  if(i == 3)  return(objectLabel3);
	if(i == 4)  return(objectLabel4);  if(i == 5)  return(objectLabel5);  if(i == 6)  return(objectLabel6);  if(i == 7)  return(objectLabel7);
	if(i == 8)  return(objectLabel8);  if(i == 9)  return(objectLabel9);  if(i == 10) return(objectLabel10); if(i == 11) return(objectLabel11);
	if(i == 12) return(objectLabel12); if(i == 13) return(objectLabel13); if(i == 14) return(objectLabel14); if(i == 15) return(objectLabel15);
	if(i == 16) return(objectLabel16); if(i == 17) return(objectLabel17); if(i == 18) return(objectLabel18); if(i == 19) return(objectLabel19);
	if(i == 20) return(objectLabel20); if(i == 21) return(objectLabel21); if(i == 22) return(objectLabel22); if(i == 23) return(objectLabel23);
	if(i == 24) return(objectLabel24); if(i == 25) return(objectLabel25); if(i == 26) return(objectLabel26); if(i == 27) return(objectLabel27);
	if(i == 28) return(objectLabel28); if(i == 29) return(objectLabel29); if(i == 30) return(objectLabel30); if(i == 31) return(objectLabel31);
	if(i == 32) return(objectLabel32); if(i == 33) return(objectLabel33); if(i == 34) return(objectLabel34); if(i == 35) return(objectLabel35);
	if(i == 36) return(objectLabel36); if(i == 37) return(objectLabel37); if(i == 38) return(objectLabel38); if(i == 39) return(objectLabel39);
	if(i == 40) return(objectLabel40); if(i == 41) return(objectLabel41); if(i == 42) return(objectLabel42); if(i == 43) return(objectLabel43);
	if(i == 44) return(objectLabel44); if(i == 45) return(objectLabel45); if(i == 46) return(objectLabel46); if(i == 47) return(objectLabel47);
	if(i == 48) return(objectLabel48); if(i == 49) return(objectLabel49); if(i == 50) return(objectLabel50); if(i == 51) return(objectLabel51);
	if(i == 52) return(objectLabel52); if(i == 53) return(objectLabel53); if(i == 54) return(objectLabel54); if(i == 55) return(objectLabel55);
	if(i == 56) return(objectLabel56); if(i == 57) return(objectLabel57); if(i == 58) return(objectLabel58); if(i == 59) return(objectLabel59);
	if(i == 60) return(objectLabel60); if(i == 61) return(objectLabel61); if(i == 62) return(objectLabel62); if(i == 63) return(objectLabel63);
	return("?");
}

void setObjectLabel(int i = -1, string lab = "") {
	if(i == 0)  objectLabel0  = lab; if(i == 1)  objectLabel1  = lab; if(i == 2)  objectLabel2  = lab; if(i == 3)  objectLabel3  = lab;
	if(i == 4)  objectLabel4  = lab; if(i == 5)  objectLabel5  = lab; if(i == 6)  objectLabel6  = lab; if(i == 7)  objectLabel7  = lab;
	if(i == 8)  objectLabel8  = lab; if(i == 9)  objectLabel9  = lab; if(i == 10) objectLabel10 = lab; if(i == 11) objectLabel11 = lab;
	if(i == 12) objectLabel12 = lab; if(i == 13) objectLabel13 = lab; if(i == 14) objectLabel14 = lab; if(i == 15) objectLabel15 = lab;
	if(i == 16) objectLabel16 = lab; if(i == 17) objectLabel17 = lab; if(i == 18) objectLabel18 = lab; if(i == 19) objectLabel19 = lab;
	if(i == 20) objectLabel20 = lab; if(i == 21) objectLabel21 = lab; if(i == 22) objectLabel22 = lab; if(i == 23) objectLabel23 = lab;
	if(i == 24) objectLabel24 = lab; if(i == 25) objectLabel25 = lab; if(i == 26) objectLabel26 = lab; if(i == 27) objectLabel27 = lab;
	if(i == 28) objectLabel28 = lab; if(i == 29) objectLabel29 = lab; if(i == 30) objectLabel30 = lab; if(i == 31) objectLabel31 = lab;
	if(i == 32) objectLabel32 = lab; if(i == 33) objectLabel33 = lab; if(i == 34) objectLabel34 = lab; if(i == 35) objectLabel35 = lab;
	if(i == 36) objectLabel36 = lab; if(i == 37) objectLabel37 = lab; if(i == 38) objectLabel38 = lab; if(i == 39) objectLabel39 = lab;
	if(i == 40) objectLabel40 = lab; if(i == 41) objectLabel41 = lab; if(i == 42) objectLabel42 = lab; if(i == 43) objectLabel43 = lab;
	if(i == 44) objectLabel44 = lab; if(i == 45) objectLabel45 = lab; if(i == 46) objectLabel46 = lab; if(i == 47) objectLabel47 = lab;
	if(i == 48) objectLabel48 = lab; if(i == 49) objectLabel49 = lab; if(i == 50) objectLabel50 = lab; if(i == 51) objectLabel51 = lab;
	if(i == 52) objectLabel52 = lab; if(i == 53) objectLabel53 = lab; if(i == 54) objectLabel54 = lab; if(i == 55) objectLabel55 = lab;
	if(i == 56) objectLabel56 = lab; if(i == 57) objectLabel57 = lab; if(i == 58) objectLabel58 = lab; if(i == 59) objectLabel59 = lab;
	if(i == 60) objectLabel60 = lab; if(i == 61) objectLabel61 = lab; if(i == 62) objectLabel62 = lab; if(i == 63) objectLabel63 = lab;
}

// Contains the total number of elements in an object (e.g., 6 Gazelles and 2 Deer = 8).
int objectItemCount0  = 0; int objectItemCount1  = 0; int objectItemCount2  = 0; int objectItemCount3  = 0;
int objectItemCount4  = 0; int objectItemCount5  = 0; int objectItemCount6  = 0; int objectItemCount7  = 0;
int objectItemCount8  = 0; int objectItemCount9  = 0; int objectItemCount10 = 0; int objectItemCount11 = 0;
int objectItemCount12 = 0; int objectItemCount13 = 0; int objectItemCount14 = 0; int objectItemCount15 = 0;
int objectItemCount16 = 0; int objectItemCount17 = 0; int objectItemCount18 = 0; int objectItemCount19 = 0;
int objectItemCount20 = 0; int objectItemCount21 = 0; int objectItemCount22 = 0; int objectItemCount23 = 0;
int objectItemCount24 = 0; int objectItemCount25 = 0; int objectItemCount26 = 0; int objectItemCount27 = 0;
int objectItemCount28 = 0; int objectItemCount29 = 0; int objectItemCount30 = 0; int objectItemCount31 = 0;
int objectItemCount32 = 0; int objectItemCount33 = 0; int objectItemCount34 = 0; int objectItemCount35 = 0;
int objectItemCount36 = 0; int objectItemCount37 = 0; int objectItemCount38 = 0; int objectItemCount39 = 0;
int objectItemCount40 = 0; int objectItemCount41 = 0; int objectItemCount42 = 0; int objectItemCount43 = 0;
int objectItemCount44 = 0; int objectItemCount45 = 0; int objectItemCount46 = 0; int objectItemCount47 = 0;
int objectItemCount48 = 0; int objectItemCount49 = 0; int objectItemCount50 = 0; int objectItemCount51 = 0;
int objectItemCount52 = 0; int objectItemCount53 = 0; int objectItemCount54 = 0; int objectItemCount55 = 0;
int objectItemCount56 = 0; int objectItemCount57 = 0; int objectItemCount58 = 0; int objectItemCount59 = 0;
int objectItemCount60 = 0; int objectItemCount61 = 0; int objectItemCount62 = 0; int objectItemCount63 = 0;

int getObjectItemCount(int i = -1) {
	if(i == 0)  return(objectItemCount0);  if(i == 1)  return(objectItemCount1);  if(i == 2)  return(objectItemCount2);  if(i == 3)  return(objectItemCount3);
	if(i == 4)  return(objectItemCount4);  if(i == 5)  return(objectItemCount5);  if(i == 6)  return(objectItemCount6);  if(i == 7)  return(objectItemCount7);
	if(i == 8)  return(objectItemCount8);  if(i == 9)  return(objectItemCount9);  if(i == 10) return(objectItemCount10); if(i == 11) return(objectItemCount11);
	if(i == 12) return(objectItemCount12); if(i == 13) return(objectItemCount13); if(i == 14) return(objectItemCount14); if(i == 15) return(objectItemCount15);
	if(i == 16) return(objectItemCount16); if(i == 17) return(objectItemCount17); if(i == 18) return(objectItemCount18); if(i == 19) return(objectItemCount19);
	if(i == 20) return(objectItemCount20); if(i == 21) return(objectItemCount21); if(i == 22) return(objectItemCount22); if(i == 23) return(objectItemCount23);
	if(i == 24) return(objectItemCount24); if(i == 25) return(objectItemCount25); if(i == 26) return(objectItemCount26); if(i == 27) return(objectItemCount27);
	if(i == 28) return(objectItemCount28); if(i == 29) return(objectItemCount29); if(i == 30) return(objectItemCount30); if(i == 31) return(objectItemCount31);
	if(i == 32) return(objectItemCount32); if(i == 33) return(objectItemCount33); if(i == 34) return(objectItemCount34); if(i == 35) return(objectItemCount35);
	if(i == 36) return(objectItemCount36); if(i == 37) return(objectItemCount37); if(i == 38) return(objectItemCount38); if(i == 39) return(objectItemCount39);
	if(i == 40) return(objectItemCount40); if(i == 41) return(objectItemCount41); if(i == 42) return(objectItemCount42); if(i == 43) return(objectItemCount43);
	if(i == 44) return(objectItemCount44); if(i == 45) return(objectItemCount45); if(i == 46) return(objectItemCount46); if(i == 47) return(objectItemCount47);
	if(i == 48) return(objectItemCount48); if(i == 49) return(objectItemCount49); if(i == 50) return(objectItemCount50); if(i == 51) return(objectItemCount51);
	if(i == 52) return(objectItemCount52); if(i == 53) return(objectItemCount53); if(i == 54) return(objectItemCount54); if(i == 55) return(objectItemCount55);
	if(i == 56) return(objectItemCount56); if(i == 57) return(objectItemCount57); if(i == 58) return(objectItemCount58); if(i == 59) return(objectItemCount59);
	if(i == 60) return(objectItemCount60); if(i == 61) return(objectItemCount61); if(i == 62) return(objectItemCount62); if(i == 63) return(objectItemCount63);
	return(0);
}

void setObjectItemCount(int i = -1, int count = 0) {
	if(i == 0)  objectItemCount0  = count; if(i == 1)  objectItemCount1  = count; if(i == 2)  objectItemCount2  = count; if(i == 3)  objectItemCount3  = count;
	if(i == 4)  objectItemCount4  = count; if(i == 5)  objectItemCount5  = count; if(i == 6)  objectItemCount6  = count; if(i == 7)  objectItemCount7  = count;
	if(i == 8)  objectItemCount8  = count; if(i == 9)  objectItemCount9  = count; if(i == 10) objectItemCount10 = count; if(i == 11) objectItemCount11 = count;
	if(i == 12) objectItemCount12 = count; if(i == 13) objectItemCount13 = count; if(i == 14) objectItemCount14 = count; if(i == 15) objectItemCount15 = count;
	if(i == 16) objectItemCount16 = count; if(i == 17) objectItemCount17 = count; if(i == 18) objectItemCount18 = count; if(i == 19) objectItemCount19 = count;
	if(i == 20) objectItemCount20 = count; if(i == 21) objectItemCount21 = count; if(i == 22) objectItemCount22 = count; if(i == 23) objectItemCount23 = count;
	if(i == 24) objectItemCount24 = count; if(i == 25) objectItemCount25 = count; if(i == 26) objectItemCount26 = count; if(i == 27) objectItemCount27 = count;
	if(i == 28) objectItemCount28 = count; if(i == 29) objectItemCount29 = count; if(i == 30) objectItemCount30 = count; if(i == 31) objectItemCount31 = count;
	if(i == 32) objectItemCount32 = count; if(i == 33) objectItemCount33 = count; if(i == 34) objectItemCount34 = count; if(i == 35) objectItemCount35 = count;
	if(i == 36) objectItemCount36 = count; if(i == 37) objectItemCount37 = count; if(i == 38) objectItemCount38 = count; if(i == 39) objectItemCount39 = count;
	if(i == 40) objectItemCount40 = count; if(i == 41) objectItemCount41 = count; if(i == 42) objectItemCount42 = count; if(i == 43) objectItemCount43 = count;
	if(i == 44) objectItemCount44 = count; if(i == 45) objectItemCount45 = count; if(i == 46) objectItemCount46 = count; if(i == 47) objectItemCount47 = count;
	if(i == 48) objectItemCount48 = count; if(i == 49) objectItemCount49 = count; if(i == 50) objectItemCount50 = count; if(i == 51) objectItemCount51 = count;
	if(i == 52) objectItemCount52 = count; if(i == 53) objectItemCount53 = count; if(i == 54) objectItemCount54 = count; if(i == 55) objectItemCount55 = count;
	if(i == 56) objectItemCount56 = count; if(i == 57) objectItemCount57 = count; if(i == 58) objectItemCount58 = count; if(i == 59) objectItemCount59 = count;
	if(i == 60) objectItemCount60 = count; if(i == 61) objectItemCount61 = count; if(i == 62) objectItemCount62 = count; if(i == 63) objectItemCount63 = count;
}

// Counts how many times the object should have been placed (targeted).
int objectTargetPlaced0  = 0; int objectTargetPlaced1  = 0; int objectTargetPlaced2  = 0; int objectTargetPlaced3  = 0;
int objectTargetPlaced4  = 0; int objectTargetPlaced5  = 0; int objectTargetPlaced6  = 0; int objectTargetPlaced7  = 0;
int objectTargetPlaced8  = 0; int objectTargetPlaced9  = 0; int objectTargetPlaced10 = 0; int objectTargetPlaced11 = 0;
int objectTargetPlaced12 = 0; int objectTargetPlaced13 = 0; int objectTargetPlaced14 = 0; int objectTargetPlaced15 = 0;
int objectTargetPlaced16 = 0; int objectTargetPlaced17 = 0; int objectTargetPlaced18 = 0; int objectTargetPlaced19 = 0;
int objectTargetPlaced20 = 0; int objectTargetPlaced21 = 0; int objectTargetPlaced22 = 0; int objectTargetPlaced23 = 0;
int objectTargetPlaced24 = 0; int objectTargetPlaced25 = 0; int objectTargetPlaced26 = 0; int objectTargetPlaced27 = 0;
int objectTargetPlaced28 = 0; int objectTargetPlaced29 = 0; int objectTargetPlaced30 = 0; int objectTargetPlaced31 = 0;
int objectTargetPlaced32 = 0; int objectTargetPlaced33 = 0; int objectTargetPlaced34 = 0; int objectTargetPlaced35 = 0;
int objectTargetPlaced36 = 0; int objectTargetPlaced37 = 0; int objectTargetPlaced38 = 0; int objectTargetPlaced39 = 0;
int objectTargetPlaced40 = 0; int objectTargetPlaced41 = 0; int objectTargetPlaced42 = 0; int objectTargetPlaced43 = 0;
int objectTargetPlaced44 = 0; int objectTargetPlaced45 = 0; int objectTargetPlaced46 = 0; int objectTargetPlaced47 = 0;
int objectTargetPlaced48 = 0; int objectTargetPlaced49 = 0; int objectTargetPlaced50 = 0; int objectTargetPlaced51 = 0;
int objectTargetPlaced52 = 0; int objectTargetPlaced53 = 0; int objectTargetPlaced54 = 0; int objectTargetPlaced55 = 0;
int objectTargetPlaced56 = 0; int objectTargetPlaced57 = 0; int objectTargetPlaced58 = 0; int objectTargetPlaced59 = 0;
int objectTargetPlaced60 = 0; int objectTargetPlaced61 = 0; int objectTargetPlaced62 = 0; int objectTargetPlaced63 = 0;

int getObjectTargetPlaced(int i = -1) {
	if(i == 0)  return(objectTargetPlaced0);  if(i == 1)  return(objectTargetPlaced1);  if(i == 2)  return(objectTargetPlaced2);  if(i == 3)  return(objectTargetPlaced3);
	if(i == 4)  return(objectTargetPlaced4);  if(i == 5)  return(objectTargetPlaced5);  if(i == 6)  return(objectTargetPlaced6);  if(i == 7)  return(objectTargetPlaced7);
	if(i == 8)  return(objectTargetPlaced8);  if(i == 9)  return(objectTargetPlaced9);  if(i == 10) return(objectTargetPlaced10); if(i == 11) return(objectTargetPlaced11);
	if(i == 12) return(objectTargetPlaced12); if(i == 13) return(objectTargetPlaced13); if(i == 14) return(objectTargetPlaced14); if(i == 15) return(objectTargetPlaced15);
	if(i == 16) return(objectTargetPlaced16); if(i == 17) return(objectTargetPlaced17); if(i == 18) return(objectTargetPlaced18); if(i == 19) return(objectTargetPlaced19);
	if(i == 20) return(objectTargetPlaced20); if(i == 21) return(objectTargetPlaced21); if(i == 22) return(objectTargetPlaced22); if(i == 23) return(objectTargetPlaced23);
	if(i == 24) return(objectTargetPlaced24); if(i == 25) return(objectTargetPlaced25); if(i == 26) return(objectTargetPlaced26); if(i == 27) return(objectTargetPlaced27);
	if(i == 28) return(objectTargetPlaced28); if(i == 29) return(objectTargetPlaced29); if(i == 30) return(objectTargetPlaced30); if(i == 31) return(objectTargetPlaced31);
	if(i == 32) return(objectTargetPlaced32); if(i == 33) return(objectTargetPlaced33); if(i == 34) return(objectTargetPlaced34); if(i == 35) return(objectTargetPlaced35);
	if(i == 36) return(objectTargetPlaced36); if(i == 37) return(objectTargetPlaced37); if(i == 38) return(objectTargetPlaced38); if(i == 39) return(objectTargetPlaced39);
	if(i == 40) return(objectTargetPlaced40); if(i == 41) return(objectTargetPlaced41); if(i == 42) return(objectTargetPlaced42); if(i == 43) return(objectTargetPlaced43);
	if(i == 44) return(objectTargetPlaced44); if(i == 45) return(objectTargetPlaced45); if(i == 46) return(objectTargetPlaced46); if(i == 47) return(objectTargetPlaced47);
	if(i == 48) return(objectTargetPlaced48); if(i == 49) return(objectTargetPlaced49); if(i == 50) return(objectTargetPlaced50); if(i == 51) return(objectTargetPlaced51);
	if(i == 52) return(objectTargetPlaced52); if(i == 53) return(objectTargetPlaced53); if(i == 54) return(objectTargetPlaced54); if(i == 55) return(objectTargetPlaced55);
	if(i == 56) return(objectTargetPlaced56); if(i == 57) return(objectTargetPlaced57); if(i == 58) return(objectTargetPlaced58); if(i == 59) return(objectTargetPlaced59);
	if(i == 60) return(objectTargetPlaced60); if(i == 61) return(objectTargetPlaced61); if(i == 62) return(objectTargetPlaced62); if(i == 63) return(objectTargetPlaced63);
	return(0);
}

void setObjectTargetPlaced(int i = -1, int num = 0) {
	if(i == 0)  objectTargetPlaced0  = num; if(i == 1)  objectTargetPlaced1  = num; if(i == 2)  objectTargetPlaced2  = num; if(i == 3)  objectTargetPlaced3  = num;
	if(i == 4)  objectTargetPlaced4  = num; if(i == 5)  objectTargetPlaced5  = num; if(i == 6)  objectTargetPlaced6  = num; if(i == 7)  objectTargetPlaced7  = num;
	if(i == 8)  objectTargetPlaced8  = num; if(i == 9)  objectTargetPlaced9  = num; if(i == 10) objectTargetPlaced10 = num; if(i == 11) objectTargetPlaced11 = num;
	if(i == 12) objectTargetPlaced12 = num; if(i == 13) objectTargetPlaced13 = num; if(i == 14) objectTargetPlaced14 = num; if(i == 15) objectTargetPlaced15 = num;
	if(i == 16) objectTargetPlaced16 = num; if(i == 17) objectTargetPlaced17 = num; if(i == 18) objectTargetPlaced18 = num; if(i == 19) objectTargetPlaced19 = num;
	if(i == 20) objectTargetPlaced20 = num; if(i == 21) objectTargetPlaced21 = num; if(i == 22) objectTargetPlaced22 = num; if(i == 23) objectTargetPlaced23 = num;
	if(i == 24) objectTargetPlaced24 = num; if(i == 25) objectTargetPlaced25 = num; if(i == 26) objectTargetPlaced26 = num; if(i == 27) objectTargetPlaced27 = num;
	if(i == 28) objectTargetPlaced28 = num; if(i == 29) objectTargetPlaced29 = num; if(i == 30) objectTargetPlaced30 = num; if(i == 31) objectTargetPlaced31 = num;
	if(i == 32) objectTargetPlaced32 = num; if(i == 33) objectTargetPlaced33 = num; if(i == 34) objectTargetPlaced34 = num; if(i == 35) objectTargetPlaced35 = num;
	if(i == 36) objectTargetPlaced36 = num; if(i == 37) objectTargetPlaced37 = num; if(i == 38) objectTargetPlaced38 = num; if(i == 39) objectTargetPlaced39 = num;
	if(i == 40) objectTargetPlaced40 = num; if(i == 41) objectTargetPlaced41 = num; if(i == 42) objectTargetPlaced42 = num; if(i == 43) objectTargetPlaced43 = num;
	if(i == 44) objectTargetPlaced44 = num; if(i == 45) objectTargetPlaced45 = num; if(i == 46) objectTargetPlaced46 = num; if(i == 47) objectTargetPlaced47 = num;
	if(i == 48) objectTargetPlaced48 = num; if(i == 49) objectTargetPlaced49 = num; if(i == 50) objectTargetPlaced50 = num; if(i == 51) objectTargetPlaced51 = num;
	if(i == 52) objectTargetPlaced52 = num; if(i == 53) objectTargetPlaced53 = num; if(i == 54) objectTargetPlaced54 = num; if(i == 55) objectTargetPlaced55 = num;
	if(i == 56) objectTargetPlaced56 = num; if(i == 57) objectTargetPlaced57 = num; if(i == 58) objectTargetPlaced58 = num; if(i == 59) objectTargetPlaced59 = num;
	if(i == 60) objectTargetPlaced60 = num; if(i == 61) objectTargetPlaced61 = num; if(i == 62) objectTargetPlaced62 = num; if(i == 63) objectTargetPlaced63 = num;
}

/*
** Looks up the index of a given object ID in the object array.
**
** @param objID: the ID of the object to look up in the array
**
** @returns: the index of the object ID
*/
int getIndexForObjectID(int objID = -1) {
	for(i = 0; < objectCheckCount) {
		if(getObjectID(i) == objID) {
			return(i);
		}
	}

	return(-1);
}

/*
** Adds a value to the item count of an object.
** The reason we do this is because rmGetNumberUnitsPlaced() returns the total number of "elements" of an object.
** For instance, an object consisting of 2 Gazelles and 3 Zebras has a count of 5.
**
** @param objID: the ID of the object
** @param count: the number to add to the element count of an object
*/
void addToObjectItemCount(int objID = -1, int count = 0) {
	int id = getIndexForObjectID(objID);

	if(id > -1) {
		// Entry found, increment existing.
		setObjectItemCount(id, getObjectItemCount(id) + count);
	}
}

/*
** Creates a new check from a previously created/existing ID.
**
** @param objLabel: the label of the object; should be meaningful
** @param objID: the ID of the object
*/
void registerObjectDefVerifyFromID(string objLabel = "", int objID = -1) {
	setObjectID(objectCheckCount, objID);
	setObjectLabel(objectCheckCount, objLabel);

	objectCheckCount++;
}

/*
** Creates a new object definiton and adds it to the objects array.
**
** @param objLabel: the label of the object; should be meaningful
** @param playerCheck: convenience parameter to disable this function under certain circumstances
**
** @returns: the ID of the definition created.
*/
int createObjectDefVerify(string objLabel = "", bool playerCheck = true) {
	int objID = rmCreateObjectDef(objLabel);

	// If the check was false, return directly.
	if(playerCheck == false) {
		return(objID);
	}

	registerObjectDefVerifyFromID(objLabel, objID);

	return(objID);
}

/*
** Adds an object definition and records it for tracking to later on determine if the object was successfully placed.
**
** @param objID: the ID of the object
** @param proto: the proto name of the object to be placed (e.g., "Gazelle")
** @param num: the number of times the proto item should be placed
** @param dist: the distance the objects can be apart from each other
*/
void addObjectDefItemVerify(int objID = -1, string proto = "", int num = 0, float dist = 0.0) {
	addToObjectItemCount(objID, num);

	rmAddObjectDefItem(objID, proto, num, dist);
}

/*
** Updates the placement count of an object. This adds to the number of times and object SHOULD have been placed.
** Used to later calculate whether all objects were successfully placed.
**
** @param objID: the ID of the object to be updated
** @param num: the number of times the object should have been placed (will be added, not overwritten)
*/
void updateObjectTargetPlaced(int objID = -1, int num = 0) {
	int idx = getIndexForObjectID(objID);

	if(idx == -1) {
		return;
	}

	setObjectTargetPlaced(idx, getObjectTargetPlaced(idx) + num);
}

/*
** Checks if all items of an object with a given ID were placed (at the time of the call).
**
** @param objID: the ID of the object
*/
void adjustPlaced(int objID = -1) {
	int i = getIndexForObjectID(objID);

	// Adjust goal.
	setObjectTargetPlaced(i, rmGetNumberUnitsPlaced(getObjectID(i)) / getObjectItemCount(i));
}

/*
** Checks if all items of an object with a given ID were placed (at the time of the call).
**
** @param objID: the ID of the object
**
** @returns: true if all placements for object objID were successful, false otherwise
*/
bool allObjectsPlaced(int objID = -1) {
	int i = getIndexForObjectID(objID);

	return(getObjectTargetPlaced(i) <= rmGetNumberUnitsPlaced(getObjectID(i)) / getObjectItemCount(i));
}

/***************
* CUSTOM CHECK *
***************/

// Remember to iterate from 0 < customCheckCount because indices start with 0 here.
int customCheckCount = 0;

// Allows the user to add manual checks that failed with any label.
string checkLabel0  = "?"; string checkLabel1  = "?"; string checkLabel2  = "?"; string checkLabel3  = "?";
string checkLabel4  = "?"; string checkLabel5  = "?"; string checkLabel6  = "?"; string checkLabel7  = "?";
string checkLabel8  = "?"; string checkLabel9  = "?"; string checkLabel10 = "?"; string checkLabel11 = "?";
string checkLabel12 = "?"; string checkLabel13 = "?"; string checkLabel14 = "?"; string checkLabel15 = "?";
string checkLabel16 = "?"; string checkLabel17 = "?"; string checkLabel18 = "?"; string checkLabel19 = "?";
string checkLabel20 = "?"; string checkLabel21 = "?"; string checkLabel22 = "?"; string checkLabel23 = "?";
string checkLabel24 = "?"; string checkLabel25 = "?"; string checkLabel26 = "?"; string checkLabel27 = "?";
string checkLabel28 = "?"; string checkLabel29 = "?"; string checkLabel30 = "?"; string checkLabel31 = "?";

string getCheckLabel(int i = -1) {
	if(i == 0)  return(checkLabel0);  if(i == 1)  return(checkLabel1);  if(i == 2)  return(checkLabel2);  if(i == 3)  return(checkLabel3);
	if(i == 4)  return(checkLabel4);  if(i == 5)  return(checkLabel5);  if(i == 6)  return(checkLabel6);  if(i == 7)  return(checkLabel7);
	if(i == 8)  return(checkLabel8);  if(i == 9)  return(checkLabel9);  if(i == 10) return(checkLabel10); if(i == 11) return(checkLabel11);
	if(i == 12) return(checkLabel12); if(i == 13) return(checkLabel13); if(i == 14) return(checkLabel14); if(i == 15) return(checkLabel15);
	if(i == 16) return(checkLabel16); if(i == 17) return(checkLabel17); if(i == 18) return(checkLabel18); if(i == 19) return(checkLabel19);
	if(i == 20) return(checkLabel20); if(i == 21) return(checkLabel21); if(i == 22) return(checkLabel22); if(i == 23) return(checkLabel23);
	if(i == 24) return(checkLabel24); if(i == 25) return(checkLabel25); if(i == 26) return(checkLabel26); if(i == 27) return(checkLabel27);
	if(i == 28) return(checkLabel28); if(i == 29) return(checkLabel29); if(i == 30) return(checkLabel30); if(i == 31) return(checkLabel31);
	return("?");
}

void setCheckLabel(int i = -1, string lab = "") {
	if(i == 0)  checkLabel0  = lab; if(i == 1)  checkLabel1  = lab; if(i == 2)  checkLabel2  = lab; if(i == 3)  checkLabel3  = lab;
	if(i == 4)  checkLabel4  = lab; if(i == 5)  checkLabel5  = lab; if(i == 6)  checkLabel6  = lab; if(i == 7)  checkLabel7  = lab;
	if(i == 8)  checkLabel8  = lab; if(i == 9)  checkLabel9  = lab; if(i == 10) checkLabel10 = lab; if(i == 11) checkLabel11 = lab;
	if(i == 12) checkLabel12 = lab; if(i == 13) checkLabel13 = lab; if(i == 14) checkLabel14 = lab; if(i == 15) checkLabel15 = lab;
	if(i == 16) checkLabel16 = lab; if(i == 17) checkLabel17 = lab; if(i == 18) checkLabel18 = lab; if(i == 19) checkLabel19 = lab;
	if(i == 20) checkLabel20 = lab; if(i == 21) checkLabel21 = lab; if(i == 22) checkLabel22 = lab; if(i == 23) checkLabel23 = lab;
	if(i == 24) checkLabel24 = lab; if(i == 25) checkLabel25 = lab; if(i == 26) checkLabel26 = lab; if(i == 27) checkLabel27 = lab;
	if(i == 28) checkLabel28 = lab; if(i == 29) checkLabel29 = lab; if(i == 30) checkLabel30 = lab; if(i == 31) checkLabel31 = lab;
}

bool checkCrucial0  = false; bool checkCrucial1  = false; bool checkCrucial2  = false; bool checkCrucial3  = false;
bool checkCrucial4  = false; bool checkCrucial5  = false; bool checkCrucial6  = false; bool checkCrucial7  = false;
bool checkCrucial8  = false; bool checkCrucial9  = false; bool checkCrucial10 = false; bool checkCrucial11 = false;
bool checkCrucial12 = false; bool checkCrucial13 = false; bool checkCrucial14 = false; bool checkCrucial15 = false;
bool checkCrucial16 = false; bool checkCrucial17 = false; bool checkCrucial18 = false; bool checkCrucial19 = false;
bool checkCrucial20 = false; bool checkCrucial21 = false; bool checkCrucial22 = false; bool checkCrucial23 = false;
bool checkCrucial24 = false; bool checkCrucial25 = false; bool checkCrucial26 = false; bool checkCrucial27 = false;
bool checkCrucial28 = false; bool checkCrucial29 = false; bool checkCrucial30 = false; bool checkCrucial31 = false;

bool getCheckCrucial(int i = -1) {
	if(i == 0)  return(checkCrucial0);  if(i == 1)  return(checkCrucial1);  if(i == 2)  return(checkCrucial2);  if(i == 3)  return(checkCrucial3);
	if(i == 4)  return(checkCrucial4);  if(i == 5)  return(checkCrucial5);  if(i == 6)  return(checkCrucial6);  if(i == 7)  return(checkCrucial7);
	if(i == 8)  return(checkCrucial8);  if(i == 9)  return(checkCrucial9);  if(i == 10) return(checkCrucial10); if(i == 11) return(checkCrucial11);
	if(i == 12) return(checkCrucial12); if(i == 13) return(checkCrucial13); if(i == 14) return(checkCrucial14); if(i == 15) return(checkCrucial15);
	if(i == 16) return(checkCrucial16); if(i == 17) return(checkCrucial17); if(i == 18) return(checkCrucial18); if(i == 19) return(checkCrucial19);
	if(i == 20) return(checkCrucial20); if(i == 21) return(checkCrucial21); if(i == 22) return(checkCrucial22); if(i == 23) return(checkCrucial23);
	if(i == 24) return(checkCrucial24); if(i == 25) return(checkCrucial25); if(i == 26) return(checkCrucial26); if(i == 27) return(checkCrucial27);
	if(i == 28) return(checkCrucial28); if(i == 29) return(checkCrucial29); if(i == 30) return(checkCrucial30); if(i == 31) return(checkCrucial31);
	return(false);
}

void setCheckCrucial(int i = -1, bool crucial = false) {
	if(i == 0)  checkCrucial0  = crucial; if(i == 1)  checkCrucial1  = crucial; if(i == 2)  checkCrucial2  = crucial; if(i == 3)  checkCrucial3  = crucial;
	if(i == 4)  checkCrucial4  = crucial; if(i == 5)  checkCrucial5  = crucial; if(i == 6)  checkCrucial6  = crucial; if(i == 7)  checkCrucial7  = crucial;
	if(i == 8)  checkCrucial8  = crucial; if(i == 9)  checkCrucial9  = crucial; if(i == 10) checkCrucial10 = crucial; if(i == 11) checkCrucial11 = crucial;
	if(i == 12) checkCrucial12 = crucial; if(i == 13) checkCrucial13 = crucial; if(i == 14) checkCrucial14 = crucial; if(i == 15) checkCrucial15 = crucial;
	if(i == 16) checkCrucial16 = crucial; if(i == 17) checkCrucial17 = crucial; if(i == 18) checkCrucial18 = crucial; if(i == 19) checkCrucial19 = crucial;
	if(i == 20) checkCrucial20 = crucial; if(i == 21) checkCrucial21 = crucial; if(i == 22) checkCrucial22 = crucial; if(i == 23) checkCrucial23 = crucial;
	if(i == 24) checkCrucial24 = crucial; if(i == 25) checkCrucial25 = crucial; if(i == 26) checkCrucial26 = crucial; if(i == 27) checkCrucial27 = crucial;
	if(i == 28) checkCrucial28 = crucial; if(i == 29) checkCrucial29 = crucial; if(i == 30) checkCrucial30 = crucial; if(i == 31) checkCrucial31 = crucial;
}

// Actually a bool despite the name, consider refactoring if it turns out to be too confusing.
bool checkState0  = true; bool checkState1  = true; bool checkState2  = true; bool checkState3  = true;
bool checkState4  = true; bool checkState5  = true; bool checkState6  = true; bool checkState7  = true;
bool checkState8  = true; bool checkState9  = true; bool checkState10 = true; bool checkState11 = true;
bool checkState12 = true; bool checkState13 = true; bool checkState14 = true; bool checkState15 = true;
bool checkState16 = true; bool checkState17 = true; bool checkState18 = true; bool checkState19 = true;
bool checkState20 = true; bool checkState21 = true; bool checkState22 = true; bool checkState23 = true;
bool checkState24 = true; bool checkState25 = true; bool checkState26 = true; bool checkState27 = true;
bool checkState28 = true; bool checkState29 = true; bool checkState30 = true; bool checkState31 = true;

bool getCheckState(int i = -1) {
	if(i == 0)  return(checkState0);  if(i == 1)  return(checkState1);  if(i == 2)  return(checkState2);  if(i == 3)  return(checkState3);
	if(i == 4)  return(checkState4);  if(i == 5)  return(checkState5);  if(i == 6)  return(checkState6);  if(i == 7)  return(checkState7);
	if(i == 8)  return(checkState8);  if(i == 9)  return(checkState9);  if(i == 10) return(checkState10); if(i == 11) return(checkState11);
	if(i == 12) return(checkState12); if(i == 13) return(checkState13); if(i == 14) return(checkState14); if(i == 15) return(checkState15);
	if(i == 16) return(checkState16); if(i == 17) return(checkState17); if(i == 18) return(checkState18); if(i == 19) return(checkState19);
	if(i == 20) return(checkState20); if(i == 21) return(checkState21); if(i == 22) return(checkState22); if(i == 23) return(checkState23);
	if(i == 24) return(checkState24); if(i == 25) return(checkState25); if(i == 26) return(checkState26); if(i == 27) return(checkState27);
	if(i == 28) return(checkState28); if(i == 29) return(checkState29); if(i == 30) return(checkState30); if(i == 31) return(checkState31);
	return(true);
}

void setCheckState(int i = -1, bool state = true) {
	if(i == 0)  checkState0  = state; if(i == 1)  checkState1  = state; if(i == 2)  checkState2  = state; if(i == 3)  checkState3  = state;
	if(i == 4)  checkState4  = state; if(i == 5)  checkState5  = state; if(i == 6)  checkState6  = state; if(i == 7)  checkState7  = state;
	if(i == 8)  checkState8  = state; if(i == 9)  checkState9  = state; if(i == 10) checkState10 = state; if(i == 11) checkState11 = state;
	if(i == 12) checkState12 = state; if(i == 13) checkState13 = state; if(i == 14) checkState14 = state; if(i == 15) checkState15 = state;
	if(i == 16) checkState16 = state; if(i == 17) checkState17 = state; if(i == 18) checkState18 = state; if(i == 19) checkState19 = state;
	if(i == 20) checkState20 = state; if(i == 21) checkState21 = state; if(i == 22) checkState22 = state; if(i == 23) checkState23 = state;
	if(i == 24) checkState24 = state; if(i == 25) checkState25 = state; if(i == 26) checkState26 = state; if(i == 27) checkState27 = state;
	if(i == 28) checkState28 = state; if(i == 29) checkState29 = state; if(i == 30) checkState30 = state; if(i == 31) checkState31 = state;
}

/*
** Adds a custom check and its state to the array.
**
** @param checkLabel: the name of the check (to be shown in the debug message if triggered)
** @param isCrucial: whether the check is crucial or not (if set to true, a failed check will be shown in the debug message)
** @param hasSucceeded: true if the check for label succeded, false otherwise
*/
void addCustomCheck(string checkLabel = "?", bool isCrucial = false, bool hasSucceeded = true) {
	setCheckLabel(customCheckCount, checkLabel);
	setCheckCrucial(customCheckCount, isCrucial);
	setCheckState(customCheckCount, hasSucceeded);

	customCheckCount++;
}

/******************
* PLACEMENT CHECK *
******************/

/*
** Verifies the placement of the objects and proto stuff previously specified.
** Since we don't want two independent error messages (one for object and one for proto check), we combine them here.
** This rule is not in rmx_triggers.xs because it is heavily tied to everything in this file.
**
** @param requireEqualTeams: set to true if the check should only be executed if the game has two equally sized teams playing
** @param maxNumberOfPlayers: if more players than the specified number are present, skip the check
*/
void injectObjectCheck(bool requireEqualTeams = true, int maxNumberOfPlayers = 12) {
	// Check if equal teams are required for the check.
	if(requireEqualTeams && gameHasTwoEqualTeams() == false) {
		return;
	}

	// Check if we have more players than the maximum to perform the check.
	if(cNonGaiaPlayers > maxNumberOfPlayers) {
		return;
	}

	/*
	 * The major "problem" here is that we have to check once via array
	 * and once through triggers if the message header/footer has to be printed at all.
	*/
	bool objectFailed = false;
	bool customFailed = false;

	// Step 1: Check if any of the object placements failed.
	for(i = 0; < objectCheckCount) {
		if(getObjectTargetPlaced(i) > rmGetNumberUnitsPlaced(getObjectID(i)) / getObjectItemCount(i)) {
			objectFailed = true;
			break;
		}
	}

	// Step 2: Check if any of the custom placements failed.
	for(i = 0; < customCheckCount) {
		// Print if the check failed and is crucial.
		if(getCheckState(i) == false && getCheckCrucial(i)) {
			customFailed = true;
			break;
		}
	}

	code("rule _print_error_msg");
	code("highFrequency");
	code("active");
	code("{");
		injectRuleInterval(0, 500); // Run after 0.5 seconds to give time for other initialization.

		code("bool failed = ((1 == " + objectFailed + ") || (1 == " + customFailed + "))");
		// Step 3: Check if any of the proto checks fail.
		for(i = 0; < protoCheckCount) {
			code(" || (trPlayerUnitCountSpecific(" + getProtoOwner(i) + ", \"" + getProtoName(i) + "\") < " + getProtoTargetCount(i) + ")");

		}
		code(";");

		// Step 4: Print the error if something failed.
		code("if(failed)");
		code("{");
			// At least one failed.
			sendChatRed(cInfoLine);
			sendChatRed("");
			sendChatRed("Warning: Object placement failed!");
			sendChatRed("");
			sendChatRed("Error(s):");

			// Print custom entries like simLoc/fairLocs.
			for(i = 0; < customCheckCount) {
				if(getCheckState(i) == false && getCheckCrucial(i)) {
					sendChatRed(getCheckLabel(i) + ": failed");
				}
			}

			// Divide rmGetNumberUnitsPlaced() by getObjectItemCount() to get the actual number placed.
			for(i = 0; < objectCheckCount) {
				if(getObjectTargetPlaced(i) > rmGetNumberUnitsPlaced(getObjectID(i)) / getObjectItemCount(i)) {
					sendChatRed(getObjectLabel(i) + ": " + rmGetNumberUnitsPlaced(getObjectID(i)) / getObjectItemCount(i) + "/" + getObjectTargetPlaced(i));
				}
			}

			// Print proto check errors.
			for(i = 0; < protoCheckCount) {
				code("int count" + i + " = trPlayerUnitCountSpecific(" + getProtoOwner(i) + ", \"" + getProtoName(i) + "\");");
				code("if(count" + i + " < " + getProtoTargetCount(i) + ")");
				code("{");
					sendChatRed(getProtoName(i) + ": \" + count" + i + " + \"/\" + " + getProtoTargetCount(i) + " + \"");
				code("}");
			}

			sendChatRed("");
			sendChatRed("Consider saving this seed.");
			sendChatRed("");
			sendChatRed(cInfoLine);

			pauseGame();
		code("}");

		code("xsDisableSelf();");
	code("}");
}

/*
** Fair location generation.
** RebelsRising
** Last edit: 07/03/2021
**
** Potential TODOs:
** - Adjust failCount handling.
** - Adjust angle generation for matchups that are not XvX.
**   -> Scale up to full [0.0, 2.0] * PI range depending on gameHasTwoEqualTeams() for an easy fix.
*/

// include "rmx_placement_check.xs";

/************
* CONSTANTS *
************/

const string cFairLocName = "rmx fair loc";
const string cFairLocAreaName = "rmx fair loc area";

/************
* LOCATIONS *
************/

// Counter for fair location names so we don't end up with duplicates.
int fairLocNameCounter = 0;

// Counter for fair location area names so we don't end up with duplicates.
int fairLocAreaNameCounter = 0;

// Last added.
int lastAddedFairLocID = -1;

// Fair loc count.
int fairLocCount = 0;

/*
** Returns the number of added fair locations. This does not indicate whether creation of those fair locations was successful!
**
** @returns: the current number of fair locations
*/
int getNumFairLocs() {
	return(fairLocCount);
}

// Fair loc iteration counter.
int lastFairLocIters = -1;

/*
** Returns the number of iterations for the last placed fair location.
** Also gets reset by resetFairLocs().
**
** @returns: the number of iterations of the algorithm for the last created/attempted fair locs.
*/
int getLastFairLocIters() {
	return(lastFairLocIters);
}

// The arrays in here start from 1 due to always being associated to players.

// Fair locations X values.
float fairLoc1X1 = -1.0; float fairLoc1X2  = -1.0; float fairLoc1X3  = -1.0; float fairLoc1X4  = -1.0;
float fairLoc1X5 = -1.0; float fairLoc1X6  = -1.0; float fairLoc1X7  = -1.0; float fairLoc1X8  = -1.0;
float fairLoc1X9 = -1.0; float fairLoc1X10 = -1.0; float fairLoc1X11 = -1.0; float fairLoc1X12 = -1.0;

float getFairLoc1X(int id = 0) {
	if(id == 1) return(fairLoc1X1); if(id == 2)  return(fairLoc1X2);  if(id == 3)  return(fairLoc1X3);  if(id == 4)  return(fairLoc1X4);
	if(id == 5) return(fairLoc1X5); if(id == 6)  return(fairLoc1X6);  if(id == 7)  return(fairLoc1X7);  if(id == 8)  return(fairLoc1X8);
	if(id == 9) return(fairLoc1X9); if(id == 10) return(fairLoc1X10); if(id == 11) return(fairLoc1X11); if(id == 12) return(fairLoc1X12);
	return(-1.0);
}

void setFairLoc1X(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc1X1 = val; if(id == 2)  fairLoc1X2  = val; if(id == 3)  fairLoc1X3  = val; if(id == 4)  fairLoc1X4  = val;
	if(id == 5) fairLoc1X5 = val; if(id == 6)  fairLoc1X6  = val; if(id == 7)  fairLoc1X7  = val; if(id == 8)  fairLoc1X8  = val;
	if(id == 9) fairLoc1X9 = val; if(id == 10) fairLoc1X10 = val; if(id == 11) fairLoc1X11 = val; if(id == 12) fairLoc1X12 = val;
}

float fairLoc2X1 = -1.0; float fairLoc2X2  = -1.0; float fairLoc2X3  = -1.0; float fairLoc2X4  = -1.0;
float fairLoc2X5 = -1.0; float fairLoc2X6  = -1.0; float fairLoc2X7  = -1.0; float fairLoc2X8  = -1.0;
float fairLoc2X9 = -1.0; float fairLoc2X10 = -1.0; float fairLoc2X11 = -1.0; float fairLoc2X12 = -1.0;

float getFairLoc2X(int id = 0) {
	if(id == 1) return(fairLoc2X1); if(id == 2)  return(fairLoc2X2);  if(id == 3)  return(fairLoc2X3);  if(id == 4)  return(fairLoc2X4);
	if(id == 5) return(fairLoc2X5); if(id == 6)  return(fairLoc2X6);  if(id == 7)  return(fairLoc2X7);  if(id == 8)  return(fairLoc2X8);
	if(id == 9) return(fairLoc2X9); if(id == 10) return(fairLoc2X10); if(id == 11) return(fairLoc2X11); if(id == 12) return(fairLoc2X12);
	return(-1.0);
}

void setFairLoc2X(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc2X1 = val; if(id == 2)  fairLoc2X2  = val; if(id == 3)  fairLoc2X3  = val; if(id == 4)  fairLoc2X4  = val;
	if(id == 5) fairLoc2X5 = val; if(id == 6)  fairLoc2X6  = val; if(id == 7)  fairLoc2X7  = val; if(id == 8)  fairLoc2X8  = val;
	if(id == 9) fairLoc2X9 = val; if(id == 10) fairLoc2X10 = val; if(id == 11) fairLoc2X11 = val; if(id == 12) fairLoc2X12 = val;
}

float fairLoc3X1 = -1.0; float fairLoc3X2  = -1.0; float fairLoc3X3  = -1.0; float fairLoc3X4  = -1.0;
float fairLoc3X5 = -1.0; float fairLoc3X6  = -1.0; float fairLoc3X7  = -1.0; float fairLoc3X8  = -1.0;
float fairLoc3X9 = -1.0; float fairLoc3X10 = -1.0; float fairLoc3X11 = -1.0; float fairLoc3X12 = -1.0;

float getFairLoc3X(int id = 0) {
	if(id == 1) return(fairLoc3X1); if(id == 2)  return(fairLoc3X2);  if(id == 3)  return(fairLoc3X3);  if(id == 4)  return(fairLoc3X4);
	if(id == 5) return(fairLoc3X5); if(id == 6)  return(fairLoc3X6);  if(id == 7)  return(fairLoc3X7);  if(id == 8)  return(fairLoc3X8);
	if(id == 9) return(fairLoc3X9); if(id == 10) return(fairLoc3X10); if(id == 11) return(fairLoc3X11); if(id == 12) return(fairLoc3X12);
	return(-1.0);
}

void setFairLoc3X(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc3X1 = val; if(id == 2)  fairLoc3X2  = val; if(id == 3)  fairLoc3X3  = val; if(id == 4)  fairLoc3X4  = val;
	if(id == 5) fairLoc3X5 = val; if(id == 6)  fairLoc3X6  = val; if(id == 7)  fairLoc3X7  = val; if(id == 8)  fairLoc3X8  = val;
	if(id == 9) fairLoc3X9 = val; if(id == 10) fairLoc3X10 = val; if(id == 11) fairLoc3X11 = val; if(id == 12) fairLoc3X12 = val;
}

float fairLoc4X1 = -1.0; float fairLoc4X2  = -1.0; float fairLoc4X3  = -1.0; float fairLoc4X4  = -1.0;
float fairLoc4X5 = -1.0; float fairLoc4X6  = -1.0; float fairLoc4X7  = -1.0; float fairLoc4X8  = -1.0;
float fairLoc4X9 = -1.0; float fairLoc4X10 = -1.0; float fairLoc4X11 = -1.0; float fairLoc4X12 = -1.0;

float getFairLoc4X(int id = 0) {
	if(id == 1) return(fairLoc4X1); if(id == 2)  return(fairLoc4X2);  if(id == 3)  return(fairLoc4X3);  if(id == 4)  return(fairLoc4X4);
	if(id == 5) return(fairLoc4X5); if(id == 6)  return(fairLoc4X6);  if(id == 7)  return(fairLoc4X7);  if(id == 8)  return(fairLoc4X8);
	if(id == 9) return(fairLoc4X9); if(id == 10) return(fairLoc4X10); if(id == 11) return(fairLoc4X11); if(id == 12) return(fairLoc4X12);
	return(-1.0);
}

void setFairLoc4X(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc4X1 = val; if(id == 2)  fairLoc4X2  = val; if(id == 3)  fairLoc4X3  = val; if(id == 4)  fairLoc4X4  = val;
	if(id == 5) fairLoc4X5 = val; if(id == 6)  fairLoc4X6  = val; if(id == 7)  fairLoc4X7  = val; if(id == 8)  fairLoc4X8  = val;
	if(id == 9) fairLoc4X9 = val; if(id == 10) fairLoc4X10 = val; if(id == 11) fairLoc4X11 = val; if(id == 12) fairLoc4X12 = val;
}

/*
** Gets the x coordinate of a fair location.
**
** @param fairLocID: the ID of the fair location
** @param id: the index of the coordinate in the array
**
** @returns: the x coordinate of the fair location
*/
float getFairLocX(int fairLocID = 0, int id = 0) {
	if(fairLocID == 1) return(getFairLoc1X(id)); if(fairLocID == 2) return(getFairLoc2X(id));
	if(fairLocID == 3) return(getFairLoc3X(id)); if(fairLocID == 4) return(getFairLoc4X(id));
	return(-1.0);
}

/*
** Sets the x coordinate of a fair location.
**
** @param fairLocID: the ID of the fair location
** @param id: the index of the coordinate in the array
** @param val: the value to set
*/
void setFairLocX(int fairLocID = 0, int id = 0, float val = -1.0) {
	if(fairLocID == 1) setFairLoc1X(id, val); if(fairLocID == 2) setFairLoc2X(id, val);
	if(fairLocID == 3) setFairLoc3X(id, val); if(fairLocID == 4) setFairLoc4X(id, val);
}

// Fair locations Z values.
float fairLoc1Z1 = -1.0;  float fairLoc1Z2  = -1.0; float fairLoc1Z3  = -1.0; float fairLoc1Z4  = -1.0;
float fairLoc1Z5 = -1.0;  float fairLoc1Z6  = -1.0; float fairLoc1Z7  = -1.0; float fairLoc1Z8  = -1.0;
float fairLoc1Z9 = -1.0;  float fairLoc1Z10 = -1.0; float fairLoc1Z11 = -1.0; float fairLoc1Z12 = -1.0;

float getFairLoc1Z(int id = 0) {
	if(id == 1) return(fairLoc1Z1); if(id == 2)  return(fairLoc1Z2);  if(id == 3)  return(fairLoc1Z3);  if(id == 4)  return(fairLoc1Z4);
	if(id == 5) return(fairLoc1Z5); if(id == 6)  return(fairLoc1Z6);  if(id == 7)  return(fairLoc1Z7);  if(id == 8)  return(fairLoc1Z8);
	if(id == 9) return(fairLoc1Z9); if(id == 10) return(fairLoc1Z10); if(id == 11) return(fairLoc1Z11); if(id == 12) return(fairLoc1Z12);
	return(-1.0);
}

void setFairLoc1Z(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc1Z1 = val; if(id == 2)  fairLoc1Z2  = val; if(id == 3)  fairLoc1Z3  = val; if(id == 4)  fairLoc1Z4  = val;
	if(id == 5) fairLoc1Z5 = val; if(id == 6)  fairLoc1Z6  = val; if(id == 7)  fairLoc1Z7  = val; if(id == 8)  fairLoc1Z8  = val;
	if(id == 9) fairLoc1Z9 = val; if(id == 10) fairLoc1Z10 = val; if(id == 11) fairLoc1Z11 = val; if(id == 12) fairLoc1Z12 = val;
}

float fairLoc2Z1 = -1.0;  float fairLoc2Z2  = -1.0; float fairLoc2Z3  = -1.0; float fairLoc2Z4  = -1.0;
float fairLoc2Z5 = -1.0;  float fairLoc2Z6  = -1.0; float fairLoc2Z7  = -1.0; float fairLoc2Z8  = -1.0;
float fairLoc2Z9 = -1.0;  float fairLoc2Z10 = -1.0; float fairLoc2Z11 = -1.0; float fairLoc2Z12 = -1.0;

float getFairLoc2Z(int id = 0) {
	if(id == 1) return(fairLoc2Z1); if(id == 2)  return(fairLoc2Z2);  if(id == 3)  return(fairLoc2Z3);  if(id == 4)  return(fairLoc2Z4);
	if(id == 5) return(fairLoc2Z5); if(id == 6)  return(fairLoc2Z6);  if(id == 7)  return(fairLoc2Z7);  if(id == 8)  return(fairLoc2Z8);
	if(id == 9) return(fairLoc2Z9); if(id == 10) return(fairLoc2Z10); if(id == 11) return(fairLoc2Z11); if(id == 12) return(fairLoc2Z12);
	return(-1.0);
}

void setFairLoc2Z(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc2Z1 = val; if(id == 2)  fairLoc2Z2  = val; if(id == 3)  fairLoc2Z3  = val; if(id == 4)  fairLoc2Z4  = val;
	if(id == 5) fairLoc2Z5 = val; if(id == 6)  fairLoc2Z6  = val; if(id == 7)  fairLoc2Z7  = val; if(id == 8)  fairLoc2Z8  = val;
	if(id == 9) fairLoc2Z9 = val; if(id == 10) fairLoc2Z10 = val; if(id == 11) fairLoc2Z11 = val; if(id == 12) fairLoc2Z12 = val;
}

float fairLoc3Z1 = -1.0;  float fairLoc3Z2  = -1.0; float fairLoc3Z3  = -1.0; float fairLoc3Z4  = -1.0;
float fairLoc3Z5 = -1.0;  float fairLoc3Z6  = -1.0; float fairLoc3Z7  = -1.0; float fairLoc3Z8  = -1.0;
float fairLoc3Z9 = -1.0;  float fairLoc3Z10 = -1.0; float fairLoc3Z11 = -1.0; float fairLoc3Z12 = -1.0;

float getFairLoc3Z(int id = 0) {
	if(id == 1) return(fairLoc3Z1); if(id == 2)  return(fairLoc3Z2);  if(id == 3)  return(fairLoc3Z3);  if(id == 4)  return(fairLoc3Z4);
	if(id == 5) return(fairLoc3Z5); if(id == 6)  return(fairLoc3Z6);  if(id == 7)  return(fairLoc3Z7);  if(id == 8)  return(fairLoc3Z8);
	if(id == 9) return(fairLoc3Z9); if(id == 10) return(fairLoc3Z10); if(id == 11) return(fairLoc3Z11); if(id == 12) return(fairLoc3Z12);
	return(-1.0);
}

void setFairLoc3Z(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc3Z1 = val; if(id == 2)  fairLoc3Z2  = val; if(id == 3)  fairLoc3Z3  = val; if(id == 4)  fairLoc3Z4  = val;
	if(id == 5) fairLoc3Z5 = val; if(id == 6)  fairLoc3Z6  = val; if(id == 7)  fairLoc3Z7  = val; if(id == 8)  fairLoc3Z8  = val;
	if(id == 9) fairLoc3Z9 = val; if(id == 10) fairLoc3Z10 = val; if(id == 11) fairLoc3Z11 = val; if(id == 12) fairLoc3Z12 = val;
}

float fairLoc4Z1 = -1.0;  float fairLoc4Z2  = -1.0; float fairLoc4Z3  = -1.0; float fairLoc4Z4  = -1.0;
float fairLoc4Z5 = -1.0;  float fairLoc4Z6  = -1.0; float fairLoc4Z7  = -1.0; float fairLoc4Z8  = -1.0;
float fairLoc4Z9 = -1.0;  float fairLoc4Z10 = -1.0; float fairLoc4Z11 = -1.0; float fairLoc4Z12 = -1.0;

float getFairLoc4Z(int id = 0) {
	if(id == 1) return(fairLoc4Z1); if(id == 2)  return(fairLoc4Z2);  if(id == 3)  return(fairLoc4Z3);  if(id == 4)  return(fairLoc4Z4);
	if(id == 5) return(fairLoc4Z5); if(id == 6)  return(fairLoc4Z6);  if(id == 7)  return(fairLoc4Z7);  if(id == 8)  return(fairLoc4Z8);
	if(id == 9) return(fairLoc4Z9); if(id == 10) return(fairLoc4Z10); if(id == 11) return(fairLoc4Z11); if(id == 12) return(fairLoc4Z12);
	return(-1.0);
}

void setFairLoc4Z(int id = 0, float val = -1.0) {
	if(id == 1) fairLoc4Z1 = val; if(id == 2)  fairLoc4Z2  = val; if(id == 3)  fairLoc4Z3  = val; if(id == 4)  fairLoc4Z4  = val;
	if(id == 5) fairLoc4Z5 = val; if(id == 6)  fairLoc4Z6  = val; if(id == 7)  fairLoc4Z7  = val; if(id == 8)  fairLoc4Z8  = val;
	if(id == 9) fairLoc4Z9 = val; if(id == 10) fairLoc4Z10 = val; if(id == 11) fairLoc4Z11 = val; if(id == 12) fairLoc4Z12 = val;
}

/*
** Gets the z coordinate of a fair location.
**
** @param fairLocID: the ID of the fair location
** @param id: the index of the coordinate in the array
**
** @returns: the z coordinate of the fair location
*/
float getFairLocZ(int fairLocID = 0, int id = 0) {
	if(fairLocID == 1) return(getFairLoc1Z(id)); if(fairLocID == 2) return(getFairLoc2Z(id));
	if(fairLocID == 3) return(getFairLoc3Z(id)); if(fairLocID == 4) return(getFairLoc4Z(id));
	return(-1.0);
}

/*
** Sets the z coordinate of a fair location.
**
** @param fairLocID: the ID of the fair location
** @param id: the index of the coordinate in the array
** @param val: the value to set
*/
void setFairLocZ(int fairLocID = 0, int id = 0, float val = -1.0) {
	if(fairLocID == 1) setFairLoc1Z(id, val); if(fairLocID == 2) setFairLoc2Z(id, val);
	if(fairLocID == 3) setFairLoc3Z(id, val); if(fairLocID == 4) setFairLoc4Z(id, val);
}

/*
** Sets both coordinates for a fair location.
**
** @param fairLocID: the ID of the fair location
** @param id: the index of the coordinate in the array
** @param x: the x value to set
** @param z: the z value to set
*/
void setFairLocXZ(int fairLocID = 0, int id = 0, float x = -1.0, float z = -1.0) {
	setFairLocX(fairLocID, id, x);
	setFairLocZ(fairLocID, id, z);
}

/**************
* CONSTRAINTS *
**************/

// Fair location constraints.
int fairLocConstraintCount1 = 0; int fairLocConstraintCount2 = 0; int fairLocConstraintCount3 = 0; int fairLocConstraintCount4 = 0;

int fairLoc1Constraint1 = -1; int fairLoc1Constraint2  = -1; int fairLoc1Constraint3  = -1; int fairLoc1Constraint4  = -1;
int fairLoc1Constraint5 = -1; int fairLoc1Constraint6  = -1; int fairLoc1Constraint7  = -1; int fairLoc1Constraint8  = -1;
int fairLoc1Constraint9 = -1; int fairLoc1Constraint10 = -1; int fairLoc1Constraint11 = -1; int fairLoc1Constraint12 = -1;

int getFairLoc1Constraint(int id = 0) {
	if(id == 1) return(fairLoc1Constraint1); if(id == 2)  return(fairLoc1Constraint2);  if(id == 3)  return(fairLoc1Constraint3);  if(id == 4)  return(fairLoc1Constraint4);
	if(id == 5) return(fairLoc1Constraint5); if(id == 6)  return(fairLoc1Constraint6);  if(id == 7)  return(fairLoc1Constraint7);  if(id == 8)  return(fairLoc1Constraint8);
	if(id == 9) return(fairLoc1Constraint9); if(id == 10) return(fairLoc1Constraint10); if(id == 11) return(fairLoc1Constraint11); if(id == 12) return(fairLoc1Constraint12);
	return(-1);
}

void setFairLoc1Constraint(int id = 0, int cID = -1) {
	if(id == 1) fairLoc1Constraint1 = cID; if(id == 2)  fairLoc1Constraint2  = cID; if(id == 3)  fairLoc1Constraint3  = cID; if(id == 4)  fairLoc1Constraint4  = cID;
	if(id == 5) fairLoc1Constraint5 = cID; if(id == 6)  fairLoc1Constraint6  = cID; if(id == 7)  fairLoc1Constraint7  = cID; if(id == 8)  fairLoc1Constraint8  = cID;
	if(id == 9) fairLoc1Constraint9 = cID; if(id == 10) fairLoc1Constraint10 = cID; if(id == 11) fairLoc1Constraint11 = cID; if(id == 12) fairLoc1Constraint12 = cID;
}

int fairLoc2Constraint1 = -1; int fairLoc2Constraint2  = -1; int fairLoc2Constraint3  = -1; int fairLoc2Constraint4  = -1;
int fairLoc2Constraint5 = -1; int fairLoc2Constraint6  = -1; int fairLoc2Constraint7  = -1; int fairLoc2Constraint8  = -1;
int fairLoc2Constraint9 = -1; int fairLoc2Constraint10 = -1; int fairLoc2Constraint11 = -1; int fairLoc2Constraint12 = -1;

int getFairLoc2Constraint(int id = 0) {
	if(id == 1) return(fairLoc2Constraint1); if(id == 2)  return(fairLoc2Constraint2);  if(id == 3)  return(fairLoc2Constraint3);  if(id == 4)  return(fairLoc2Constraint4);
	if(id == 5) return(fairLoc2Constraint5); if(id == 6)  return(fairLoc2Constraint6);  if(id == 7)  return(fairLoc2Constraint7);  if(id == 8)  return(fairLoc2Constraint8);
	if(id == 9) return(fairLoc2Constraint9); if(id == 10) return(fairLoc2Constraint10); if(id == 11) return(fairLoc2Constraint11); if(id == 12) return(fairLoc2Constraint12);
	return(-1);
}

void setFairLoc2Constraint(int id = 0, int cID = -1) {
	if(id == 1) fairLoc2Constraint1 = cID; if(id == 2)  fairLoc2Constraint2  = cID; if(id == 3)  fairLoc2Constraint3  = cID; if(id == 4)  fairLoc2Constraint4  = cID;
	if(id == 5) fairLoc2Constraint5 = cID; if(id == 6)  fairLoc2Constraint6  = cID; if(id == 7)  fairLoc2Constraint7  = cID; if(id == 8)  fairLoc2Constraint8  = cID;
	if(id == 9) fairLoc2Constraint9 = cID; if(id == 10) fairLoc2Constraint10 = cID; if(id == 11) fairLoc2Constraint11 = cID; if(id == 12) fairLoc2Constraint12 = cID;
}

int fairLoc3Constraint1 = -1; int fairLoc3Constraint2  = -1; int fairLoc3Constraint3  = -1; int fairLoc3Constraint4  = -1;
int fairLoc3Constraint5 = -1; int fairLoc3Constraint6  = -1; int fairLoc3Constraint7  = -1; int fairLoc3Constraint8  = -1;
int fairLoc3Constraint9 = -1; int fairLoc3Constraint10 = -1; int fairLoc3Constraint11 = -1; int fairLoc3Constraint12 = -1;

int getFairLoc3Constraint(int id = 0) {
	if(id == 1) return(fairLoc3Constraint1); if(id == 2)  return(fairLoc3Constraint2);  if(id == 3)  return(fairLoc3Constraint3);  if(id == 4)  return(fairLoc3Constraint4);
	if(id == 5) return(fairLoc3Constraint5); if(id == 6)  return(fairLoc3Constraint6);  if(id == 7)  return(fairLoc3Constraint7);  if(id == 8)  return(fairLoc3Constraint8);
	if(id == 9) return(fairLoc3Constraint9); if(id == 10) return(fairLoc3Constraint10); if(id == 11) return(fairLoc3Constraint11); if(id == 12) return(fairLoc3Constraint12);
	return(-1);
}

void setFairLoc3Constraint(int id = 0, int cID = -1) {
	if(id == 1) fairLoc3Constraint1 = cID; if(id == 2)  fairLoc3Constraint2  = cID; if(id == 3)  fairLoc3Constraint3  = cID; if(id == 4)  fairLoc3Constraint4  = cID;
	if(id == 5) fairLoc3Constraint5 = cID; if(id == 6)  fairLoc3Constraint6  = cID; if(id == 7)  fairLoc3Constraint7  = cID; if(id == 8)  fairLoc3Constraint8  = cID;
	if(id == 9) fairLoc3Constraint9 = cID; if(id == 10) fairLoc3Constraint10 = cID; if(id == 11) fairLoc3Constraint11 = cID; if(id == 12) fairLoc3Constraint12 = cID;
}

int fairLoc4Constraint1 = -1; int fairLoc4Constraint2  = -1; int fairLoc4Constraint3  = -1; int fairLoc4Constraint4  = -1;
int fairLoc4Constraint5 = -1; int fairLoc4Constraint6  = -1; int fairLoc4Constraint7  = -1; int fairLoc4Constraint8  = -1;
int fairLoc4Constraint9 = -1; int fairLoc4Constraint10 = -1; int fairLoc4Constraint11 = -1; int fairLoc4Constraint12 = -1;

int getFairLoc4Constraint(int id = 0) {
	if(id == 1) return(fairLoc4Constraint1); if(id == 2)  return(fairLoc4Constraint2);  if(id == 3)  return(fairLoc4Constraint3);  if(id == 4)  return(fairLoc4Constraint4);
	if(id == 5) return(fairLoc4Constraint5); if(id == 6)  return(fairLoc4Constraint6);  if(id == 7)  return(fairLoc4Constraint7);  if(id == 8)  return(fairLoc4Constraint8);
	if(id == 9) return(fairLoc4Constraint9); if(id == 10) return(fairLoc4Constraint10); if(id == 11) return(fairLoc4Constraint11); if(id == 12) return(fairLoc4Constraint12);
	return(-1);
}

void setFairLoc4Constraint(int id = 0, int cID = -1) {
	if(id == 1) fairLoc4Constraint1 = cID; if(id == 2)  fairLoc4Constraint2  = cID; if(id == 3)  fairLoc4Constraint3  = cID; if(id == 4)  fairLoc4Constraint4  = cID;
	if(id == 5) fairLoc4Constraint5 = cID; if(id == 6)  fairLoc4Constraint6  = cID; if(id == 7)  fairLoc4Constraint7  = cID; if(id == 8)  fairLoc4Constraint8  = cID;
	if(id == 9) fairLoc4Constraint9 = cID; if(id == 10) fairLoc4Constraint10 = cID; if(id == 11) fairLoc4Constraint11 = cID; if(id == 12) fairLoc4Constraint12 = cID;
}

/*
** Obtains a stored constraint for a given fair location.
**
** @param fairLocID: the ID of the fair location
** @param id: the index of the constraint in the constraint array
**
** @returns: the ID of the constraint
*/
int getFairLocConstraint(int fairLocID = 0, int id = 0) {
	if(fairLocID == 1) return(getFairLoc1Constraint(id)); if(fairLocID == 2) return(getFairLoc2Constraint(id));
	if(fairLocID == 3) return(getFairLoc3Constraint(id)); if(fairLocID == 4) return(getFairLoc4Constraint(id));
	return(-1);
}

/*
** Adds an area constraint to a certain fair location.
**
** The signature of this function may seem a little inconsistent, but it's a lot more convenient.
** Since usually the current fair location is used, the second argument can often be omitted.
** The exception (and reason why the second argument exists) are cases where you may want to have
** fair locations added in a different order depending on the number of players.
** Remember that the fair locations with the lower IDs are placed first.
**
** @param cID: the ID of the constraint
** @param fairLocID: the ID of the fair location the constraint should belong to
*/
void addFairLocConstraint(int cID = -1, int fairLocID = -1) {
	if(fairLocID < 0) {
		fairLocID = fairLocCount + 1;
	}

	if(fairLocID == 1) {
		fairLocConstraintCount1++;
		setFairLoc1Constraint(fairLocConstraintCount1, cID);
	} else if(fairLocID == 2) {
		fairLocConstraintCount2++;
		setFairLoc2Constraint(fairLocConstraintCount2, cID);
	} else if(fairLocID == 3) {
		fairLocConstraintCount3++;
		setFairLoc3Constraint(fairLocConstraintCount3, cID);
	} else if(fairLocID == 4) {
		fairLocConstraintCount4++;
		setFairLoc4Constraint(fairLocConstraintCount4, cID);
	}
}

/*
** Returns the number of constraints for a certain fair location.
**
** @param fairLocID: the ID of the fair location
**
** @returns: the number of constraints that have been added
*/
int getFairLocConstraintCount(int fairLocID = 0) {
	if(fairLocID == 1) return(fairLocConstraintCount1); if(fairLocID == 2) return(fairLocConstraintCount2);
	if(fairLocID == 3) return(fairLocConstraintCount3); if(fairLocID == 4) return(fairLocConstraintCount4);
	return(-1);
}

/*************
* PARAMETERS *
*************/

// Min dist.
float fairLoc1MinDist = 0.0; float fairLoc2MinDist = 0.0; float fairLoc3MinDist = 0.0; float fairLoc4MinDist = 0.0;

float getFairLocMinDist(int id = 0) {
	if(id == 1) return(fairLoc1MinDist); if(id == 2) return(fairLoc2MinDist); if(id == 3) return(fairLoc3MinDist); if(id == 4) return(fairLoc4MinDist);
	return(0.0);
}

void setFairLocMinDist(int id = 0, float val = 0.0) {
	if(id == 1) fairLoc1MinDist = val; if(id == 2) fairLoc2MinDist = val; if(id == 3) fairLoc3MinDist = val; if(id == 4) fairLoc4MinDist = val;
}

// Max dist.
float fairLoc1MaxDist = 0.0; float fairLoc2MaxDist = 0.0; float fairLoc3MaxDist = 0.0; float fairLoc4MaxDist = 0.0;

float getFairLocMaxDist(int id = 0) {
	if(id == 1) return(fairLoc1MaxDist); if(id == 2) return(fairLoc2MaxDist); if(id == 3) return(fairLoc3MaxDist); if(id == 4) return(fairLoc4MaxDist);
	return(0.0);
}

void setFairLocMaxDist(int id = 0, float val = 0.0) {
	if(id == 1) fairLoc1MaxDist = val; if(id == 2) fairLoc2MaxDist = val; if(id == 3) fairLoc3MaxDist = val; if(id == 4) fairLoc4MaxDist = val;
}

// Forward.
bool fairLoc1Forward = false; bool fairLoc2Forward = false; bool fairLoc3Forward = false; bool fairLoc4Forward = false;

bool getFairLocForward(int id = 0) {
	if(id == 1) return(fairLoc1Forward); if(id == 2) return(fairLoc2Forward); if(id == 3) return(fairLoc3Forward); if(id == 4) return(fairLoc4Forward);
	return(false);
}

void setFairLocForward(int id = 0, bool val = false) {
	if(id == 1) fairLoc1Forward = val; if(id == 2) fairLoc2Forward = val; if(id == 3) fairLoc3Forward = val; if(id == 4) fairLoc4Forward = val;
}

// Inside.
bool fairLoc1Inside = false; bool fairLoc2Inside = false; bool fairLoc3Inside = false; bool fairLoc4Inside = false;

bool getFairLocInside(int id = 0) {
	if(id == 1) return(fairLoc1Inside); if(id == 2) return(fairLoc2Inside); if(id == 3) return(fairLoc3Inside); if(id == 4) return(fairLoc4Inside);
	return(false);
}

void setFairLocInside(int id = 0, bool val = false) {
	if(id == 1) fairLoc1Inside = val; if(id == 2) fairLoc2Inside = val; if(id == 3) fairLoc3Inside = val; if(id == 4) fairLoc4Inside = val;
}

// Area dist.
float fairLoc1AreaDist = 0.0; float fairLoc2AreaDist = 0.0; float fairLoc3AreaDist = 0.0; float fairLoc4AreaDist = 0.0;

float getFairLocAreaDist(int id = 0) {
	if(id == 1) return(fairLoc1AreaDist); if(id == 2) return(fairLoc2AreaDist); if(id == 3) return(fairLoc3AreaDist); if(id == 4) return(fairLoc4AreaDist);
	return(0.0);
}

void setFairLocAreaDist(int id = 0, float val = 0.0) {
	if(id == 1) fairLoc1AreaDist = val; if(id == 2) fairLoc2AreaDist = val; if(id == 3) fairLoc3AreaDist = val; if(id == 4) fairLoc4AreaDist = val;
}

// Edge dist x.
float fairLoc1DistX = 0.0; float fairLoc2DistX = 0.0; float fairLoc3DistX = 0.0; float fairLoc4DistX = 0.0;

float getFairLocDistX(int id = 0) {
	if(id == 1) return(fairLoc1DistX); if(id == 2) return(fairLoc2DistX); if(id == 3) return(fairLoc3DistX); if(id == 4) return(fairLoc4DistX);
	return(0.0);
}

void setFairLocDistX(int id = 0, float val = 0.0) {
	if(id == 1) fairLoc1DistX = val; if(id == 2) fairLoc2DistX = val; if(id == 3) fairLoc3DistX = val; if(id == 4) fairLoc4DistX = val;
}

// Edge dist z.
float fairLoc1DistZ = 0.0; float fairLoc2DistZ = 0.0; float fairLoc3DistZ = 0.0; float fairLoc4DistZ = 0.0;

float getFairLocDistZ(int id = 0) {
	if(id == 1) return(fairLoc1DistZ); if(id == 2) return(fairLoc2DistZ); if(id == 3) return(fairLoc3DistZ); if(id == 4) return(fairLoc4DistZ);
	return(0.0);
}

void setFairLocDistZ(int id = 0, float val = 0.0) {
	if(id == 1) fairLoc1DistZ = val; if(id == 2) fairLoc2DistZ = val; if(id == 3) fairLoc3DistZ = val; if(id == 4) fairLoc4DistZ = val;
}

// Inside out.
bool fairLoc1InsideOut = true; bool fairLoc2InsideOut = true; bool fairLoc3InsideOut = true; bool fairLoc4InsideOut = true;

bool getFairLocInsideOut(int id = 0) {
	if(id == 1) return(fairLoc1InsideOut); if(id == 2) return(fairLoc2InsideOut); if(id == 3) return(fairLoc3InsideOut); if(id == 4) return(fairLoc4InsideOut);
	return(true);
}

void setFairLocInsideOut(int id = 0, bool val = true) {
	if(id == 1) fairLoc1InsideOut = val; if(id == 2) fairLoc2InsideOut = val; if(id == 3) fairLoc3InsideOut = val; if(id == 4) fairLoc4InsideOut = val;
}

// In player area.
bool fairLoc1InPlayerArea = false; bool fairLoc2InPlayerArea = false; bool fairLoc3InPlayerArea = false; bool fairLoc4InPlayerArea = false;

bool getFairLocInPlayerArea(int id = 0) {
	if(id == 1) return(fairLoc1InPlayerArea); if(id == 2) return(fairLoc2InPlayerArea); if(id == 3) return(fairLoc3InPlayerArea); if(id == 4) return(fairLoc4InPlayerArea);
	return(false);
}

void setFairLocInPlayerArea(int id = 0, bool val = false) {
	if(id == 1) fairLoc1InPlayerArea = val; if(id == 2) fairLoc2InPlayerArea = val; if(id == 3) fairLoc3InPlayerArea = val; if(id == 4) fairLoc4InPlayerArea = val;
}

// In team area.
bool fairLoc1InTeamArea = false; bool fairLoc2InTeamArea = false; bool fairLoc3InTeamArea = false; bool fairLoc4InTeamArea = false;

bool getFairLocInTeamArea(int id = 0) {
	if(id == 1) return(fairLoc1InTeamArea); if(id == 2) return(fairLoc2InTeamArea);	if(id == 3) return(fairLoc3InTeamArea); if(id == 4) return(fairLoc4InTeamArea);
	return(false);
}

void setFairLocInTeamArea(int id = 0, bool val = false) {
	if(id == 1) fairLoc1InTeamArea = val; if(id == 2) fairLoc2InTeamArea = val; if(id == 3) fairLoc3InTeamArea = val; if(id == 4) fairLoc4InTeamArea = val;
}

// Whether to use square placement or not.
bool fairLoc1IsSquare = false; bool fairLoc2IsSquare = false; bool fairLoc3IsSquare = false; bool fairLoc4IsSquare = false;

bool getFairLocIsSquare(int id = 0) {
	if(id == 1) return(fairLoc1IsSquare); if(id == 2) return(fairLoc2IsSquare);	if(id == 3) return(fairLoc3IsSquare); if(id == 4) return(fairLoc4IsSquare);
	return(false);
}

void setFairLocIsSquare(int id = 0, bool val = false) {
	if(id == 1) fairLoc1IsSquare = val; if(id == 2) fairLoc2IsSquare = val; if(id == 3) fairLoc3IsSquare = val; if(id == 4) fairLoc4IsSquare = val;
}

// Default two player tolerance.
float fairLoc1TwoPlayerTol = -1.0; float fairLoc2TwoPlayerTol = -1.0; float fairLoc3TwoPlayerTol = -1.0; float fairLoc4TwoPlayerTol = -1.0;

float getFairLocTwoPlayerTol(int id = 0) {
	if(id == 1) return(fairLoc1TwoPlayerTol); if(id == 2) return(fairLoc2TwoPlayerTol); if(id == 3) return(fairLoc3TwoPlayerTol); if(id == 4) return(fairLoc4TwoPlayerTol);
	return(-1.0);
}

void setFairLocTwoPlayerTol(int id = 0, float val = 0.125) {
	if(id == 1) fairLoc1TwoPlayerTol = val; if(id == 2) fairLoc2TwoPlayerTol = val; if(id == 3) fairLoc3TwoPlayerTol = val; if(id == 4) fairLoc4TwoPlayerTol = val;
}

/*
** Sets the maximum ratio for the two player check to tolerate.
**
** @param twoPlayerTol: the ratio as a float
** @param fairLocID: the ID of the fair location to set the segment size for
*/
void enableFairLocTwoPlayerCheck(float twoPlayerTol = 0.125, int fairLocID = -1) {
	if(fairLocID < 0) { // Use current fairLoc if defaulted.
		fairLocID = fairLocCount + 1;
	}

	setFairLocTwoPlayerTol(fairLocID, twoPlayerTol);
}

// Inter dist.
float fairLocInterDistMin = 0.0;
float fairLocInterDistMax = INF;

/*
** Gets the minimum distance fair locations of a player have to be separated by.
**
** @returns: the distance in meters
*/
float getFairLocInterDistMin() {
	return(fairLocInterDistMin);
}

/*
** Sets a minimum distance that fair locations of a player have to be separated by.
**
** @param val: the distance in meters
*/
void setFairLocInterDistMin(float val = 0.0) {
	fairLocInterDistMin = val;
}

/*
** Gets the maximum distance fair locations of a player have to be separated by.
**
** @returns: the distance in meters
*/
float getFairLocInterDistMax() {
	return(fairLocInterDistMax);
}

/*
** Sets a maximum distance that fair locations of a player can be separated by.
**
** @param val: the distance in meters
*/
void setFairLocInterDistMax(float val = INF) {
	fairLocInterDistMax = val;
}

// Min cross distance.
float fairLocMinCrossDist = 0.0;

/*
** Calculates the minimum cross distance that has to be guaranteed.
** This is the minimum distance that the separately specified fair locations (addFairLoc()) have to be apart from each other.
** Example: 2 fair locations were added with 80.0 and 60.0 areaDist, this means that the minimum cross distance is 60.0.
**
** Distance within the specific fair locations is checked separately.
**
** @returns: the minimum area distance of all specified fair locations.
*/
float calcFairLocMinCrossDist() {
	float tempMinCrossDist = INF;

	for(i = 1; <= fairLocCount) {
		if(getFairLocAreaDist(i) < tempMinCrossDist) {
			tempMinCrossDist = getFairLocAreaDist(i);
		}
	}

	fairLocMinCrossDist = tempMinCrossDist;
}

// Players start from 1 by convention (0 = Mother Nature).
int fairLoc1Player1 = -1; int fairLoc1Player2  = -1; int fairLoc1Player3  = -1; int fairLoc1Player4  = -1;
int fairLoc1Player5 = -1; int fairLoc1Player6  = -1; int fairLoc1Player7  = -1; int fairLoc1Player8  = -1;
int fairLoc1Player9 = -1; int fairLoc1Player10 = -1; int fairLoc1Player11 = -1; int fairLoc1Player12 = -1;

int getFairLoc1Player(int i = 0) {
	if(i == 1) return(fairLoc1Player1); if(i == 2)  return(fairLoc1Player2);  if(i == 3)  return(fairLoc1Player3);  if(i == 4)  return(fairLoc1Player4);
	if(i == 5) return(fairLoc1Player5); if(i == 6)  return(fairLoc1Player6);  if(i == 7)  return(fairLoc1Player7);  if(i == 8)  return(fairLoc1Player8);
	if(i == 9) return(fairLoc1Player9); if(i == 10) return(fairLoc1Player10); if(i == 11) return(fairLoc1Player11); if(i == 12) return(fairLoc1Player12);
	return(-1);
}

void setFairLoc1Player(int i = 0, int id = -1) {
	if(i == 1) fairLoc1Player1 = id; if(i == 2)  fairLoc1Player2  = id; if(i == 3)  fairLoc1Player3  = id; if(i == 4)  fairLoc1Player4  = id;
	if(i == 5) fairLoc1Player5 = id; if(i == 6)  fairLoc1Player6  = id; if(i == 7)  fairLoc1Player7  = id; if(i == 8)  fairLoc1Player8  = id;
	if(i == 9) fairLoc1Player9 = id; if(i == 10) fairLoc1Player10 = id; if(i == 11) fairLoc1Player11 = id; if(i == 12) fairLoc1Player12 = id;
}

int fairLoc2Player1 = -1; int fairLoc2Player2  = -1; int fairLoc2Player3  = -1; int fairLoc2Player4  = -1;
int fairLoc2Player5 = -1; int fairLoc2Player6  = -1; int fairLoc2Player7  = -1; int fairLoc2Player8  = -1;
int fairLoc2Player9 = -1; int fairLoc2Player10 = -1; int fairLoc2Player11 = -1; int fairLoc2Player12 = -1;

int getFairLoc2Player(int i = 0) {
	if(i == 1) return(fairLoc2Player1); if(i == 2)  return(fairLoc2Player2);  if(i == 3)  return(fairLoc2Player3);  if(i == 4)  return(fairLoc2Player4);
	if(i == 5) return(fairLoc2Player5); if(i == 6)  return(fairLoc2Player6);  if(i == 7)  return(fairLoc2Player7);  if(i == 8)  return(fairLoc2Player8);
	if(i == 9) return(fairLoc2Player9); if(i == 10) return(fairLoc2Player10); if(i == 11) return(fairLoc2Player11); if(i == 12) return(fairLoc2Player12);
	return(-1);
}

void setFairLoc2Player(int i = 0, int id = -1) {
	if(i == 1) fairLoc2Player1 = id; if(i == 2)  fairLoc2Player2  = id; if(i == 3)  fairLoc2Player3  = id; if(i == 4)  fairLoc2Player4  = id;
	if(i == 5) fairLoc2Player5 = id; if(i == 6)  fairLoc2Player6  = id; if(i == 7)  fairLoc2Player7  = id; if(i == 8)  fairLoc2Player8  = id;
	if(i == 9) fairLoc2Player9 = id; if(i == 10) fairLoc2Player10 = id; if(i == 11) fairLoc2Player11 = id; if(i == 12) fairLoc2Player12 = id;
}

int fairLoc3Player1 = -1; int fairLoc3Player2  = -1; int fairLoc3Player3  = -1; int fairLoc3Player4  = -1;
int fairLoc3Player5 = -1; int fairLoc3Player6  = -1; int fairLoc3Player7  = -1; int fairLoc3Player8  = -1;
int fairLoc3Player9 = -1; int fairLoc3Player10 = -1; int fairLoc3Player11 = -1; int fairLoc3Player12 = -1;

int getFairLoc3Player(int i = 0) {
	if(i == 1) return(fairLoc3Player1); if(i == 2)  return(fairLoc3Player2);  if(i == 3)  return(fairLoc3Player3);  if(i == 4)  return(fairLoc3Player4);
	if(i == 5) return(fairLoc3Player5); if(i == 6)  return(fairLoc3Player6);  if(i == 7)  return(fairLoc3Player7);  if(i == 8)  return(fairLoc3Player8);
	if(i == 9) return(fairLoc3Player9); if(i == 10) return(fairLoc3Player10); if(i == 11) return(fairLoc3Player11); if(i == 12) return(fairLoc3Player12);
	return(-1);
}

void setFairLoc3Player(int i = 0, int id = -1) {
	if(i == 1) fairLoc3Player1 = id; if(i == 2)  fairLoc3Player2  = id; if(i == 3)  fairLoc3Player3  = id; if(i == 4)  fairLoc3Player4  = id;
	if(i == 5) fairLoc3Player5 = id; if(i == 6)  fairLoc3Player6  = id; if(i == 7)  fairLoc3Player7  = id; if(i == 8)  fairLoc3Player8  = id;
	if(i == 9) fairLoc3Player9 = id; if(i == 10) fairLoc3Player10 = id; if(i == 11) fairLoc3Player11 = id; if(i == 12) fairLoc3Player12 = id;
}

int fairLoc4Player1 = -1; int fairLoc4Player2  = -1; int fairLoc4Player3  = -1; int fairLoc4Player4  = -1;
int fairLoc4Player5 = -1; int fairLoc4Player6  = -1; int fairLoc4Player7  = -1; int fairLoc4Player8  = -1;
int fairLoc4Player9 = -1; int fairLoc4Player10 = -1; int fairLoc4Player11 = -1; int fairLoc4Player12 = -1;

int getFairLoc4Player(int i = 0) {
	if(i == 1) return(fairLoc4Player1); if(i == 2)  return(fairLoc4Player2);  if(i == 3)  return(fairLoc4Player3);  if(i == 4)  return(fairLoc4Player4);
	if(i == 5) return(fairLoc4Player5); if(i == 6)  return(fairLoc4Player6);  if(i == 7)  return(fairLoc4Player7);  if(i == 8)  return(fairLoc4Player8);
	if(i == 9) return(fairLoc4Player9); if(i == 10) return(fairLoc4Player10); if(i == 11) return(fairLoc4Player11); if(i == 12) return(fairLoc4Player12);
	return(-1);
}

void setFairLoc4Player(int i = 0, int id = -1) {
	if(i == 1) fairLoc4Player1 = id; if(i == 2)  fairLoc4Player2  = id; if(i == 3)  fairLoc4Player3  = id; if(i == 4)  fairLoc4Player4  = id;
	if(i == 5) fairLoc4Player5 = id; if(i == 6)  fairLoc4Player6  = id; if(i == 7)  fairLoc4Player7  = id; if(i == 8)  fairLoc4Player8  = id;
	if(i == 9) fairLoc4Player9 = id; if(i == 10) fairLoc4Player10 = id; if(i == 11) fairLoc4Player11 = id; if(i == 12) fairLoc4Player12 = id;
}

/*
** Gets a player in the array that stores the placement order of a fair location.
**
** @param fairLocID: the ID of the fair location
** @param i: the index in the array to retrieve
** @param id: the player number to store in the specified array and index
*/
void setFairLocPlayer(int fairLocID = -1, int i = 0, int id = -1) {
	if(fairLocID == 1) {
		setFairLoc1Player(i, id);
	} else if(fairLocID == 2) {
		setFairLoc2Player(i, id);
	} else if(fairLocID == 3) {
		setFairLoc3Player(i, id);
	} else if(fairLocID == 4) {
		setFairLoc4Player(i, id);
	}
}

/*
** Gets a player from the array that stores the placement order of a fair location.
**
** @param fairLocID: the ID of the fair location
** @param i: the index in the array to retrieve
**
** @returns: the player stored in the specified array (fairLocID) and index
*/
int getFairLocPlayer(int fairLocID = -1, int i = 0) {
	if(fairLocID == 1) {
		return(getFairLoc1Player(i));
	} else if(fairLocID == 2) {
		return(getFairLoc2Player(i));
	} else if(fairLocID == 3) {
		return(getFairLoc3Player(i));
	} else if(fairLocID == 4) {
		return(getFairLoc4Player(i));
	}

	// Should never be reached.
	return(-1);
}

/*
** Sets the order in which fair locations are placed for a given fair location ID.
** This can be either inside out or outside in according to playerTeamPos values, i.e., the position of a player in a team.
** For instance, for 4v4 this means (F = first, C = center, L = last):
**
** 1 (F) <-> 8 (L)
** 2 (C) <-> 7 (C)
** 3 (C) <-> 6 (C)
** 4 (L) <-> 5 (F)
**
** For inside out, the players are ordered such that the center players (2, 3, 6, 7) have their locations placed first, then 1 and 5 and finally 4 and 8.
** For outside in, the inverse is done.
**
** For mirroring, the behavior is different: The respective mirrored player is inserted right after the "original" player.
**
** @param fairLocID: the ID of the fair location
*/
void setFairLocPlayerOrder(int fairLocID = -1) {
	int posStart = 0;
	int posEnd = cNumTeamPos - 1;

	// Go from negatve positions to 0 if we're placing inside out and take abs of p when used.
	if(getFairLocInsideOut(fairLocID)) {
		posStart = 0 - posEnd;
		posEnd = 0;
	}

	int currPlayer = 1;
	int numPlayers = cNonGaiaPlayers;

	if(isMirrorOnAndValidConfig()) {
		numPlayers = getNumberPlayersOnTeam(0);
	}

	// Iterate over positions.
	for(p = posStart; <= posEnd) {

		// Iterate over players that have the current position.
		for(i = 1; <= numPlayers) {
			if(getPlayerTeamPos(i) != abs(p)) {
				// Player doesn't have current position, move on to next player.
				continue;
			}

			// Set mirrored player first (as it's position is also evaluated first).
			if(isMirrorOnAndValidConfig()) {
				setFairLocPlayer(fairLocID, currPlayer, getMirroredPlayer(i));
				currPlayer++;
			}

			setFairLocPlayer(fairLocID, currPlayer, i);

			currPlayer++;
		}

	}
}

/*
** Adds a fair location.
** Note that additional options such as enableFairLocTwoPlayerCheck() has to be called before this or it will apply to the next fair location.
**
** @param minDist: the minimum distance of the radius for the fair location from the player location
** @param maxDist: the maximum distance of the radius for the fair location from the player location
** @param forward: whether the location should be forward or backward with respect to the player
** @param inside: whether the location should be inside or outside with respect to the player
** @param areaDist: the distances between the areas that will be enforced (!)
** @param distX: edge distance of the x axis of the location
** @param distZ: edge distance of the z axis of the location
** @param inPlayerArea: whether the location should be enforced to lie within a player's section of the map
** @param inTeamArea: whether the location should be enforced to lie within a player's team section of the map
** @param isSquare: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param insideOut: whether to start from the inner players or from the outer players when placing the locations
** @param fairLocID: the ID of the fair location; if not given, the default counter is used (starting at 1)
*/
void addFairLoc(float minDist = 0.0, float maxDist = -1.0, bool forward = false, bool inside = false, float areaDist = 0.0, float distX = 0.0, float distZ = -1.0,
				bool inPlayerArea = false, bool inTeamArea = false, bool isSquare = false, bool insideOut = true, int fairLocID = -1) {
	fairLocCount++;

	if(distZ < 0.0) {
		distZ = distX;
	}

	if(fairLocID < 0) {
		fairLocID = fairLocCount;
	}

	setFairLocMinDist(fairLocID, minDist);
	setFairLocMaxDist(fairLocID, maxDist);
	setFairLocForward(fairLocID, forward);
	setFairLocInside(fairLocID, inside);
	setFairLocAreaDist(fairLocID, areaDist);
	setFairLocDistX(fairLocID, distX);
	setFairLocDistZ(fairLocID, distZ);
	setFairLocInPlayerArea(fairLocID, inPlayerArea);
	setFairLocInTeamArea(fairLocID, inTeamArea);
	setFairLocIsSquare(fairLocID, isSquare);
	setFairLocInsideOut(fairLocID, insideOut);

	// Update minCrossDist.
	calcFairLocMinCrossDist();

	// Set player order.
	setFairLocPlayerOrder(fairLocID);
}

/*
** Adds a fair location and uses the same constraints as the previous fairLoc did (but NOT same twoPlayerTol, etc.).
**
** @param minDist: the minimum distance of the radius for the fair location from the player location
** @param maxDist: the maximum distance of the radius for the fair location from the player location
** @param forward: whether the location should be forward or backward with respect to the player
** @param inside: whether the location should be inside or outside with respect to the player
** @param areaDist: the distances between the areas that will be enforced (!)
** @param distX: edge distance of the x axis of the location
** @param distZ: edge distance of the z axis of the location
** @param inPlayerArea: whether the location should be enforced to lie within a player's section of the map
** @param inTeamArea: whether the location should be enforced to lie within a player's team section of the map
** @param isSquare: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param insideOut: whether to start from the inner players or from the outer players when placing the locations
** @param fairLocID: the ID of the fair location; if not given, the default counter is used (starting at 1)
*/
void addFairLocWithPrevConstraints(float minDist = 0.0, float maxDist = -1.0, bool forward = false, bool inside = false, float areaDist = 0.0,
								   float distX = 0.0, float distZ = -1.0, bool inPlayerArea = false, bool inTeamArea = false, bool isSquare = false,
								   bool insideOut = true, int fairLocID = -1) {
	if(fairLocID < 0) {
		fairLocID = fairLocCount + 1;
	}

	if(lastAddedFairLocID > 0) {
		for(i = 1; <= getFairLocConstraintCount(lastAddedFairLocID)) {
			addFairLocConstraint(getFairLocConstraint(lastAddedFairLocID, i), fairLocID);
		}
	}

	// Set player order.
	setFairLocPlayerOrder(fairLocID);
}

/*
** Resets all fair loc values.
*/
void resetFairLocVals() {
	fairLoc1X1 = -1.0; fairLoc1X2  = -1.0; fairLoc1X3  = -1.0; fairLoc1X4  = -1.0;
	fairLoc1X5 = -1.0; fairLoc1X6  = -1.0; fairLoc1X7  = -1.0; fairLoc1X8  = -1.0;
	fairLoc1X9 = -1.0; fairLoc1X10 = -1.0; fairLoc1X11 = -1.0; fairLoc1X12 = -1.0;

	fairLoc2X1 = -1.0; fairLoc2X2  = -1.0; fairLoc2X3  = -1.0; fairLoc2X4  = -1.0;
	fairLoc2X5 = -1.0; fairLoc2X6  = -1.0; fairLoc2X7  = -1.0; fairLoc2X8  = -1.0;
	fairLoc2X9 = -1.0; fairLoc2X10 = -1.0; fairLoc2X11 = -1.0; fairLoc2X12 = -1.0;

	fairLoc3X1 = -1.0; fairLoc3X2  = -1.0; fairLoc3X3  = -1.0; fairLoc3X4  = -1.0;
	fairLoc3X5 = -1.0; fairLoc3X6  = -1.0; fairLoc3X7  = -1.0; fairLoc3X8  = -1.0;
	fairLoc3X9 = -1.0; fairLoc3X10 = -1.0; fairLoc3X11 = -1.0; fairLoc3X12 = -1.0;

	fairLoc4X1 = -1.0; fairLoc4X2  = -1.0; fairLoc4X3  = -1.0; fairLoc4X4  = -1.0;
	fairLoc4X5 = -1.0; fairLoc4X6  = -1.0; fairLoc4X7  = -1.0; fairLoc4X8  = -1.0;
	fairLoc4X9 = -1.0; fairLoc4X10 = -1.0; fairLoc4X11 = -1.0; fairLoc4X12 = -1.0;

	fairLoc1Z1 = -1.0; fairLoc1Z2  = -1.0; fairLoc1Z3  = -1.0; fairLoc1Z4  = -1.0;
	fairLoc1Z5 = -1.0; fairLoc1Z6  = -1.0; fairLoc1Z7  = -1.0; fairLoc1Z8  = -1.0;
	fairLoc1Z9 = -1.0; fairLoc1Z10 = -1.0; fairLoc1Z11 = -1.0; fairLoc1Z12 = -1.0;

	fairLoc2Z1 = -1.0; fairLoc2Z2  = -1.0; fairLoc2Z3  = -1.0; fairLoc2Z4  = -1.0;
	fairLoc2Z5 = -1.0; fairLoc2Z6  = -1.0; fairLoc2Z7  = -1.0; fairLoc2Z8  = -1.0;
	fairLoc2Z9 = -1.0; fairLoc2Z10 = -1.0; fairLoc2Z11 = -1.0; fairLoc2Z12 = -1.0;

	fairLoc3Z1 = -1.0; fairLoc3Z2  = -1.0; fairLoc3Z3  = -1.0; fairLoc3Z4  = -1.0;
	fairLoc3Z5 = -1.0; fairLoc3Z6  = -1.0; fairLoc3Z7  = -1.0; fairLoc3Z8  = -1.0;
	fairLoc3Z9 = -1.0; fairLoc3Z10 = -1.0; fairLoc3Z11 = -1.0; fairLoc3Z12 = -1.0;

	fairLoc4Z1 = -1.0; fairLoc4Z2  = -1.0; fairLoc4Z3  = -1.0; fairLoc4Z4  = -1.0;
	fairLoc4Z5 = -1.0; fairLoc4Z6  = -1.0; fairLoc4Z7  = -1.0; fairLoc4Z8  = -1.0;
	fairLoc4Z9 = -1.0; fairLoc4Z10 = -1.0; fairLoc4Z11 = -1.0; fairLoc4Z12 = -1.0;
}

/*
** Clean fair location settings. Should be called after placing a set of fair locations (and before the next ones are defined).
*/
void resetFairLocs() {
	fairLocCount = 0;
	lastFairLocIters = -1;
	lastAddedFairLocID = -1;

	fairLocMinCrossDist = 0.0;
	fairLocInterDistMin = 0.0;
	fairLocInterDistMax = INF;

	// Write the resetting a bit more compact to save some lines.
	fairLocConstraintCount1 = 0; fairLocConstraintCount2 = 0;	fairLocConstraintCount3 = 0; fairLocConstraintCount4 = 0;
	fairLoc1TwoPlayerTol = -1.0; fairLoc2TwoPlayerTol = -1.0; fairLoc3TwoPlayerTol = -1.0; fairLoc4TwoPlayerTol = -1.0;

	fairLoc1Player1 = -1; fairLoc1Player2  = -1; fairLoc1Player3  = -1; fairLoc1Player4  = -1;
	fairLoc1Player5 = -1; fairLoc1Player6  = -1; fairLoc1Player7  = -1; fairLoc1Player8  = -1;
	fairLoc1Player9 = -1; fairLoc1Player10 = -1; fairLoc1Player11 = -1; fairLoc1Player12 = -1;

	fairLoc2Player1 = -1; fairLoc2Player2  = -1; fairLoc2Player3  = -1; fairLoc2Player4  = -1;
	fairLoc2Player5 = -1; fairLoc2Player6  = -1; fairLoc2Player7  = -1; fairLoc2Player8  = -1;
	fairLoc2Player9 = -1; fairLoc2Player10 = -1; fairLoc2Player11 = -1; fairLoc2Player12 = -1;

	fairLoc3Player1 = -1; fairLoc3Player2  = -1; fairLoc3Player3  = -1; fairLoc3Player4  = -1;
	fairLoc3Player5 = -1; fairLoc3Player6  = -1; fairLoc3Player7  = -1; fairLoc3Player8  = -1;
	fairLoc3Player9 = -1; fairLoc3Player10 = -1; fairLoc3Player11 = -1; fairLoc3Player12 = -1;

	fairLoc4Player1 = -1; fairLoc4Player2  = -1; fairLoc4Player3  = -1; fairLoc4Player4  = -1;
	fairLoc4Player5 = -1; fairLoc4Player6  = -1; fairLoc4Player7  = -1; fairLoc4Player8  = -1;
	fairLoc4Player9 = -1; fairLoc4Player10 = -1; fairLoc4Player11 = -1; fairLoc4Player12 = -1;

	// As of now, the following resets are actually not needed, but we do it anyway to keep it clean.
	resetFairLocVals();
}

/**************
* FAIR ANGLES *
**************/

/*
 * Note that most functions here are mutable, i.e., you can overwrite them in your own script by redefining them.
 * This should allow for specific fair location generation if your map is not suitable for the default angles that work for most maps.
 *
 * Angle orientation (as seen from the center when looking towards a player):
 * 0		= Behind
 * PI / 2	= Left (seen from center!)
 * PI;		= Front
 * 3PI / 2	= Right (seen from center!)
 *
 * Note that these angles are always relative to a player as they are added to the player angle when placing fair locations.
 * For instance, an angle of PI / 2 directs exactly perpendicular to the left of a player when looking from the center towards the player's location.
*/

/*****************
* FORWARD ANGLES *
*****************/

/*
 * The following functions all have the same signature so I won't document them all individually.
 * All of them are used to randomize backward angles for the different settings in randBackward().
 *
 * A larger tolerance means that the angle search range has been extended by the algorithm
 * due to failing too often to find a valid location.
 *
 * tol: the tolerance in [0, 1.0]
 *
 * returns: the randomized angle.
*/

mutable float randFwdInsideFirst(float tol = 0.0) {
	return(rmRandFloat(0.7 - 0.3 * tol, 1.0 + 0.5 * tol) * PI);
}

mutable float randFwdOutsideFirst(float tol = 0.0) {
	return(rmRandFloat(1.0 - 0.5 * tol, 1.3 + 0.2 * tol) * PI);
}

mutable float randFwdInsideLast(float tol = 0.0) {
	return(rmRandFloat(1.0 - 0.5 * tol, 1.3 + 0.2 * tol) * PI);
}

mutable float randFwdOutsideLast(float tol = 0.0) {
	return(rmRandFloat(0.7 - 0.3 * tol, 1.0 + 0.5 * tol) * PI);
}

mutable float randFwdCenter(float tol = 0.0) {
	if(tol == 0.0) {
		return(rmRandFloat(0.8, 1.2) * PI);
	} else {
		return(randFromIntervals(0.8 - 0.6 * tol, 0.8, 1.2, 1.2 + 0.6 * tol) * PI);
	}
}

mutable float randFwdInsideSingle(float tol = 0.0) {
	if(randChance()) {
		return(randFwdInsideFirst(tol));
	} else {
		return(randFwdInsideLast(tol));
	}
}

mutable float randFwdOutsideSingle(float tol = 0.0) {
	if(randChance()) {
		return(randFwdInsideFirst(tol));
	} else {
		return(randFwdInsideLast(tol));
	}
}

/*
** Randomizes an angle for a forward position with respect to a given player team position.
**
** @param inside: whether the angle should be towards the team or away from the team
** @param playerTeamPos: the orientation of the player within the team
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: the randomized angle in radians
*/
mutable float randForward(bool inside = false, int playerTeamPos = -1, float tol = 0.0) {
	if(playerTeamPos == cPosSingle) {
		if(inside) {
			return(randFwdInsideSingle(tol));
		} else {
			return(randFwdOutsideSingle(tol));
		}
	}

	if(playerTeamPos == cPosFirst) {
		if(inside) {
			return(randFwdInsideFirst(tol));
		} else {
			return(randFwdOutsideFirst(tol));
		}
	}

	if(playerTeamPos == cPosLast) {
		if(inside) {
			return(randFwdInsideLast(tol));
		} else {
			return(randFwdOutsideLast(tol));
		}
	}

	if(playerTeamPos == cPosCenter) {
		return(randFwdCenter(tol));
	}

	return(rmRandFloat(0.0, 2.0 * PI)); // Should never happen.
}

/******************
* BACKWARD ANGLES *
******************/

/*
** The following functions all have the same signature so I won't document them all individually.
** All of them are used to randomize backward angles for the different settings in randBackward().
**
** A larger tolerance means that the angle search range has been extended by the algorithm
** due to failing too often to find a valid location.
**
** tol: the tolerance in [0, 1.0]
**
** returns: the randomized angle.
*/

mutable float randBackInsideFirst(float tol = 0.0) {
	return(rmRandFloat(-0.05 - 0.45 * tol, 0.3 + 0.3 * tol) * PI);
}

mutable float randBackOutsideFirst(float tol = 0.0) {
	return(rmRandFloat(1.7 - 0.3 * tol, 2.05 + 0.45 * tol) * PI);
}

mutable float randBackInsideLast(float tol = 0.0) {
	return(rmRandFloat(1.7 - 0.3 * tol, 2.05 + 0.45 * tol) * PI);
}

mutable float randBackOutsideLast(float tol = 0.0) {
	return(rmRandFloat(-0.05 - 0.45 * tol, 0.3 + 0.3 * tol) * PI);
}

mutable float randBackCenter(float tol = 0.0) {
	if(tol == 0.0) {
		return(rmRandFloat(-0.3, 0.3) * PI);
	} else {
		return(randFromIntervals(-0.3 - tol * 0.5, -0.3, 0.3, 0.3 + tol * 0.5) * PI);
	}
}

mutable float randBackInsideSingle(float tol = 0.0) {
	return(rmRandFloat(-0.4 - 0.4 * tol, 0.4 + 0.4 * tol) * PI);

}

mutable float randBackOutsideSingle(float tol = 0.0) {
	return(rmRandFloat(-0.4 - 0.4 * tol, 0.4 + 0.4 * tol) * PI);
}

/*
** Randomizes an angle for a backward position with respect to a given player team position.
**
** @param inside: whether the angle should be towards the team or away from the team
** @param playerTeamPos: the orientation of the player within the team
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: the randomized angle in radians
*/
mutable float randBackward(bool inside = false, int playerTeamPos = -1, float tol = 0.0) {
	if(playerTeamPos == cPosSingle) {
		if(inside) {
			return(randBackInsideSingle(tol));
		} else {
			return(randBackOutsideSingle(tol));
		}
	}

	if(playerTeamPos == cPosFirst) {
		if(inside) {
			return(randBackInsideFirst(tol));
		} else {
			return(randBackOutsideFirst(tol));
		}
	}

	if(playerTeamPos == cPosLast) {
		if(inside) {
			return(randBackInsideLast(tol));
		} else {
			return(randBackOutsideLast(tol));
		}
	}

	if(playerTeamPos == cPosCenter) {
		return(randBackCenter(tol));
	}

	return(rmRandFloat(0.0, 2.0 * PI)); // Should never happen.
}

/*
** Randomizes a fair angle for a given player according to forward/inside settings.
**
** @param player: the player number (already mapped; player = 1 corresponds to getPlayer(1))
** @param forward: whether the location should be forward or backward with respect to the player
** @param inside: whether the location should be inside or outside with respect to the player
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: the randomized angle in radians
*/
mutable float getRandomFairAngle(int player = 0, bool forward = false, bool inside = false, float tol = 0.0) {
	int playerTeamPos = getPlayerTeamPos(player);

	if(forward) {
		return(randForward(inside, playerTeamPos, tol));
	} else {
		return(randBackward(inside, playerTeamPos, tol));
	}
}

/*************
* GENERATION *
*************/

/*
** Performs an additional check that leads to very balanced placement in 1v1 situations.
** This check essentially calculates the ratio of the players' distance to the fair location of the respective other player.
** The fraction has to be smaller than twoPlayerTol to succeed, i.e., less than a certain percentage (0.125 -> difference in distance is less than 12.5%).
**
** @param fairLocID: the location ID of the fair location to check
**
** @returns: true if the check succeeded, false otherwise
*/
bool performFairLocTwoPlayerCheck(int fairLocID = -1) {
	if(cNonGaiaPlayers != 2) {
		return(true);
	}

	float twoPlayerTol = getFairLocTwoPlayerTol(fairLocID);

	if(twoPlayerTol < 0.0) { // Not set.
		return(true);
	}

	// Get the distance in meters between p1 and the fair loc of p2 and the other way around.
	float distP1 = pointsGetDist(rmXFractionToMeters(getPlayerLocXFraction(1)), rmZFractionToMeters(getPlayerLocZFraction(1)),
								 rmXFractionToMeters(getFairLocX(fairLocID, 2)), rmZFractionToMeters(getFairLocZ(fairLocID, 2)));

	float distP2 = pointsGetDist(rmXFractionToMeters(getPlayerLocXFraction(2)), rmZFractionToMeters(getPlayerLocZFraction(2)),
								 rmXFractionToMeters(getFairLocX(fairLocID, 1)), rmZFractionToMeters(getFairLocZ(fairLocID, 1)));

	// Divide the smaller distance by the larger to get the fraction.
	if(distP1 < distP2) {
		if(1.0 - distP1 / distP2 > twoPlayerTol) {
			return(false);
		}
	} else {
		if(1.0 - distP2 / distP1 > twoPlayerTol) {
			return(false);
		}
	}

	return(true);
}

/*
** Checks if a fair location with a radius and angle is valid (within map coordinates) and sets the values for the player.
** Also sets the x/z values for the mirrored player if mirroring is enabled.
**
** @param fairLocID: the ID of the fair location
** @param player: the player
** @param radius: the radius to use for the location
** @param angle: the angle in radians to use
**
** @returns: true if a valid location was obtained, false otherwise
*/
bool checkAndSetFairLoc(int fairLocID = -1, int player = 0, float radius = 0.0, float angle = 0.0) {
	float x = getXFromPolarForPlayer(player, radius, angle, getFairLocIsSquare(fairLocID));
	float z = getZFromPolarForPlayer(player, radius, angle, getFairLocIsSquare(fairLocID));

	if(isLocValid(x, z, rmXMetersToFraction(getFairLocDistX(fairLocID)), rmZMetersToFraction(getFairLocDistZ(fairLocID))) == false) {
		return(false);
	}

	setFairLocXZ(fairLocID, player, x, z);

	// Also set mirrored coordinates if necessary.
	if(isMirrorOnAndValidConfig()) {
		player = getMirroredPlayer(player);

		if(getMirrorMode() != cMirrorPoint) {
			angle = 0.0 - angle;
		}

		x = getXFromPolarForPlayer(player, radius, angle, getFairLocIsSquare(fairLocID));
		z = getZFromPolarForPlayer(player, radius, angle, getFairLocIsSquare(fairLocID));

		setFairLocXZ(fairLocID, player, x, z);
	}

	return(true);
}

/*
** Compares two fair locations and evaluates their validity according to the specified constraints.
**
** The following constraints are checked:
** 1. fairLocInterDistMin (if specified): minimum distance fair locations of a player have to be apart from each other.
**    If not set, the cross distance is used as value (in the cross distance check as this is always performed).
**
** 2. fairLocInterDistMax (if specified): maximum distance fair locations of a player can be apart from each other.
**
** 3. fairLocAreaDist: minimum distance fair locations with the same fair location ID have to be apart from each other.
**
** 4. fairLocMinCrossDist: minimum distance all specified fair locations have to be apart from each other.
**    This corresponds to the minimum areaDist value set when using addFairLoc().
**
** @param fairLocID1: fairLocID of the first fair location
** @param player1: player owning the first fair location
** @param fairLocID2: fairLocID of the second fair location
** @param player2: player owning the second fair location
**
** @returns: true if the comparison succeeded, false otherwise
*/
bool compareFairLocs(int fairLocID1 = -1, int player1 = 0, int fairLocID2 = -1, int player2 = 0) {
	float dist = pointsGetDist(rmXFractionToMeters(getFairLocX(fairLocID1, player1)), rmZFractionToMeters(getFairLocZ(fairLocID1, player1)),
							   rmXFractionToMeters(getFairLocX(fairLocID2, player2)), rmZFractionToMeters(getFairLocZ(fairLocID2, player2)));

	// Calculate fair loc inter distance (distance among fair locs of a player).
	if(player1 == player2) {
		if(dist < fairLocInterDistMin) {
			return(false);
		}

		if(dist > fairLocInterDistMax) {
			return(false);
		}
	}

	// Calculate fair loc intra distance (compare fair loc to the same fair loc of the other players).
	if(fairLocID1 == fairLocID2 && dist < getFairLocAreaDist(fairLocID1)) {
		return(false);
	}

	// Calculate fair loc cross distance.
	if(dist < fairLocMinCrossDist) {
		return(false);
	}

	return(true);
}

/*
** Performs checks to ensure that a fair location adheres to the specified settings (distance settings, NOT area constraints!).
** The check involves comparing the current fair location to be placed against all other fair locations that were previously placed.
**
** @param fairLocID: the fair location ID of the location to check
** @param player: the player owning the fair location
**
** @returns: true if the check succeeded, false otherwise
*/
bool checkFairLoc(int fairLocID = -1, int player = 0) {
	// Iterate over fair locs.
	for(f = 1; <= fairLocID) {

		// Iterate over players.
		for(i = 1; < cPlayers) {
			// Map player to loc player array.
			int p = getFairLocPlayer(f, i);

			if(f == fairLocID && p == player) {
				// Terminate early if we made it this far, skip remaining player for last fairLoc as they have not had their fairLoc placed yet.
				return(true);
			}

			if(compareFairLocs(fairLocID, player, f, p) == false) {
				return(false);
			}
		}

	}
}

/*
** Attempts to build a previously placed fair location with respect to the constraints.
** Also adds player area and team area constraints if specified.
**
** @param fairLocID: the ID of the fair location
** @param player: the player (unmapped)
**
** @returns: true if the area was built, false otherwise
*/
bool buildFairLoc(int fairLocID = -1, int player = 0) {
	// Define areas, apply constraints and try to place.
	int areaID = rmCreateArea(cFairLocName + " " + fairLocNameCounter);

	rmSetAreaLocation(areaID, getFairLocX(fairLocID, player), getFairLocZ(fairLocID, player));

	rmSetAreaSize(areaID, rmXMetersToFraction(0.1));
	//rmSetAreaTerrainType(areaID, "HadesBuildable1");
	//rmSetAreaBaseHeight(areaID, 10.0);
	rmSetAreaCoherence(areaID, 1.0);
	rmSetAreaWarnFailure(areaID, false);

	fairLocNameCounter++;

	// Add all defined constraints.
	for(j = 1; <= getFairLocConstraintCount(fairLocID)) {
		rmAddAreaConstraint(areaID, getFairLocConstraint(fairLocID, j));
	}

	// Add player area constraint if enabled.
	if(getFairLocInPlayerArea(fairLocID)) {
		rmAddAreaConstraint(areaID, getPlayerAreaConstraint(player));
	}

	// Add team area constraint if enabled.
	if(getFairLocInTeamArea(fairLocID)) {
		rmAddAreaConstraint(areaID, getTeamAreaConstraint(player));
	}

	return(rmBuildArea(areaID));
}

/*
** Single attempt to create a fair location.
**
** @param fairLocID: the location ID of the fair location
** @param player: the player owning the fair location
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: true upon success, false otherwise
*/
bool createFairLocForPlayer(int fairLocID = -1, int player = 0, float tol = 0.0) {
	float angle = getRandomFairAngle(player, getFairLocForward(fairLocID), getFairLocInside(fairLocID), tol) + getPlayerTeamOffsetAngle(player);
	float radius = randRadiusFromInterval(getFairLocMinDist(fairLocID), getFairLocMaxDist(fairLocID));

	if(checkAndSetFairLoc(fairLocID, player, radius, angle) == false) {
		return(false);
	}

	// This is probably not necessary because the next check also considers the location placed for getMirroredPlayer(player).
	// if(isMirrorOnAndValidConfig()) {
		// if(checkFairLoc(fairLocID, getMirroredPlayer(player)) == false) {
			// return(false)
		// }
	// }

	if(checkFairLoc(fairLocID, player) == false) {
		return(false);
	}

	if(isMirrorOnAndValidConfig()) {
		if(buildFairLoc(fairLocID, getMirroredPlayer(player)) == false) {
			return(false);
		}
	}

	return(buildFairLoc(fairLocID, player));
}

/*
** Tries to create a valid fair location for a player according to the parameters specified by addFairLoc().
** The algorithm tries to find a valid location for a given number of times.
**
** @param fairLocID: the location ID of the fair location
** @param player: the player owning the fair location
** @param maxIter: the number of attempts to find the location
**
** @returns: the number of iterations that were required to find a location; -1 indicates failure
*/
int createFairLocFromParams(int fairLocID = -1, int player = 0, int maxIter = 100) {
	float tol = 0.0;
	int localIter = 0;
	int failCount = 0;

	while(localIter < maxIter) {
		// Increase tolerance upon failing several times.
		if(failCount >= 10) {
			failCount = 5;
			tol = min(tol + 0.1, 1.0); // Make sure we don't exceed 100% tolerance.
		}

		localIter++;

		// Try to find valid location.
		if(createFairLocForPlayer(fairLocID, player, tol)) {
			return(localIter);
		}

		failCount++;
	}

	// -1 = failed to find a location within maxIter iterations, caller can decide what to do with this value.
	return(-1);
}

/*
** Runs the fair location placement algorithm.
** If a mirror mode is set, the created fair locations will be mirrored.
**
** @param maxIter: the maximum number of iterations to run the algorithm for
** @param localMaxIter: the maximum attempts to find a fair location for every player before starting over
**
** @returns: true upon success, false otherwise
*/
bool runFairLocs(int maxIter = 5000, int localMaxIter = 100) {
	int currIter = 0;
	int numPlayers = cNonGaiaPlayers;
	bool done = false;

	// Adjust player number in case we mirror.
	if(isMirrorOnAndValidConfig()) {
		numPlayers = getNumberPlayersOnTeam(0);
	}

	while(currIter < maxIter && done == false) {
		done = true;

		// Iterate over fair locations.
		for(f = 1; <= fairLocCount) {

			// Iterate over players.
			for(i = 1; <= numPlayers) {
				int p = getFairLocPlayer(f, i);

				if(isMirrorOnAndValidConfig()) {
					p = getFairLocPlayer(f, (i - 1) * 2 + 1);
				}

				int numIter = createFairLocFromParams(f, p, localMaxIter);

				if(numIter < 0) { // Failed, increment currIter; could also penalize fails later in the algorithm harder.
					currIter = currIter + localMaxIter;
					done = false;
					break;
				}

				currIter = currIter + numIter;
			}

			if(done == false) {
				break;
			} else if(performFairLocTwoPlayerCheck(f) == false) {
				done = false;
				break;
			}
		}
	}

	if(done == false) {
		lastFairLocIters = -1;
		return(false);
	}

	lastFairLocIters = currIter;
	return(true);
}

/*
** Attempts to create fair locations according to the added definitions and chosen settings.
** Also considers mirroring if a mirror mode was set prior to the call.
**
** @param fairLocLabel: the name of the fair location (only used for debugging purposes)
** @param isCrucial: whether the fair loc is crucial and players should be warned if it fails or not
** @param maxIter: the maximum number of iterations to run the algorithm for
** @param localMaxIter: the maximum attempts to find a fair location for every player before starting over
**
** @returns: true if the locations were successfully generated, false otherwise
*/
bool createFairLocs(string fairLocLabel = "", bool isCrucial = true,  int maxIter = 5000, int localMaxIter = 100) {
	// Initialize splits if not already done.
	initializePlayerAreaConstraints();
	initializeTeamAreaConstraints();

	bool success = runFairLocs(maxIter, localMaxIter);

	// Clear values if not debugging.
	if(success == false && cDebugMode < cDebugTest) {
		resetFairLocVals();
	}

	// Print message if debugging.
	string varSpace = " ";

	if(fairLocLabel == "") {
		varSpace = "";
	}

	if(lastFairLocIters >= 0) {
		printDebug("fairLoc" + varSpace + fairLocLabel + " succeeded: i = " + lastFairLocIters, cDebugTest);
	}

	// Log result.
	addCustomCheck("fairLoc" + varSpace + fairLocLabel, isCrucial, success);

	return(success);
}

/*
** Creates (fake) areas on the fair locations and adds them to a class.
** Useful if you need to block fair areas, but do not want to place objects on them yet.
**
** @param classID: the ID of the class to add the fair locations to
** @param areaMeterRadius: the radius of the (invisible) area to create
** @param fairLocID: the ID of the fair location to create the areas from; if defaulted to -1, all stored fair locations will have locations generated
*/
void fairLocAreasToClass(int classID = -1, float areaMeterRadius = 5.0, int fairLocID = -1) {
	int fairLocStartID = 1;

	if(fairLocID < 0) {
		fairLocID = fairLocCount;
	} else {
		fairLocStartID = fairLocID;
	}

	for(i = fairLocStartID; <= fairLocID) {
		for(j = 1; < cPlayers) {
			int fairLocAreaID = rmCreateArea(cFairLocAreaName + " " + fairLocAreaNameCounter + " " + i + " " + j);
			rmSetAreaLocation(fairLocAreaID, getFairLocX(i, j), getFairLocZ(i, j));
			rmSetAreaSize(fairLocAreaID, areaRadiusMetersToFraction(areaMeterRadius));
			rmSetAreaCoherence(fairLocAreaID, 1.0);
			rmAddAreaToClass(fairLocAreaID, classID);
		}
	}

	rmBuildAllAreas();

	fairLocAreaNameCounter++;
}

/*
** Stores the current set of fair locations in the location storage.
*/
void storeFairLocs() {
	for(i = 1; <= fairLocCount) {
		for(j = 1; < cPlayers) {
			forceAddLocToStorage(getFairLocX(i, j), getFairLocZ(i, j), j);
		}
	}
}

/*
** Similar location generation.
** RebelsRising
** Last edit: 07/03/2021
*/

// include "rmx_fair_locs.xs";

/************
* CONSTANTS *
************/

// Bias constants.
extern const int cBiasNone = -1;
extern const int cBiasForward = 0;
extern const int cBiasBackward = 1;
extern const int cBiasSide = 2;
extern const int cBiasAggressive = 3; // More aggressive version of cBiasForward.
extern const int cBiasDefensive = 4; // More defensive version of cBiasBackward.
extern const int cBiasNotDefensive = 5; // All except the most defensive quarter.
extern const int cBiasNotAggressive = 6; // All except the most aggressive quarter.

const string cSimLocName = "rmx similar loc";
const string cSimLocAreaName = "rmx similar loc area";

/************
* LOCATIONS *
************/

// Counter for similar location names so we don't end up with duplicates.
int simLocNameCounter = 0;

// Counter for fair location area names so we don't end up with duplicates.
int simLocAreaNameCounter = 0;

// Last added.
int lastAddedSimLocID = -1;

// Similar loc count.
int simLocCount = 0;

/*
** Returns the number of added similar locations. This does not indicate whether creation of those similar locations was successful!
**
** @returns: the current number of similar locations
*/
int getNumSimLocs() {
	return(simLocCount);
}

// Sim loc iteration counter.
int lastSimLocIters = -1;

/*
** Returns the number of iterations for the last placed similar location.
** Also gets reset by resetSimLocs().
**
** @returns: the number of iterations of the algorithm for the last created/attempted similar locs.
*/
int getLastSimLocIters() {
	return(lastSimLocIters);
}

// The arrays in here start from 1 due to always being associated to players.

// Similar locations X values.
float simLoc1X1 = -1.0;  float simLoc1X2  = -1.0; float simLoc1X3  = -1.0; float simLoc1X4  = -1.0;
float simLoc1X5 = -1.0;  float simLoc1X6  = -1.0; float simLoc1X7  = -1.0; float simLoc1X8  = -1.0;
float simLoc1X9 = -1.0;  float simLoc1X10 = -1.0; float simLoc1X11 = -1.0; float simLoc1X12 = -1.0;

float getSimLoc1X(int id = 0) {
	if(id == 1) return(simLoc1X1); if(id == 2)  return(simLoc1X2);  if(id == 3)  return(simLoc1X3);  if(id == 4)  return(simLoc1X4);
	if(id == 5) return(simLoc1X5); if(id == 6)  return(simLoc1X6);  if(id == 7)  return(simLoc1X7);  if(id == 8)  return(simLoc1X8);
	if(id == 9) return(simLoc1X9); if(id == 10) return(simLoc1X10); if(id == 11) return(simLoc1X11); if(id == 12) return(simLoc1X12);
	return(-1.0);
}

void setSimLoc1X(int id = 0, float val = -1.0) {
	if(id == 1) simLoc1X1 = val; if(id == 2)  simLoc1X2  = val; if(id == 3)  simLoc1X3  = val; if(id == 4)  simLoc1X4  = val;
	if(id == 5) simLoc1X5 = val; if(id == 6)  simLoc1X6  = val; if(id == 7)  simLoc1X7  = val; if(id == 8)  simLoc1X8  = val;
	if(id == 9) simLoc1X9 = val; if(id == 10) simLoc1X10 = val; if(id == 11) simLoc1X11 = val; if(id == 12) simLoc1X12 = val;
}

float simLoc2X1 = -1.0;  float simLoc2X2  = -1.0; float simLoc2X3  = -1.0; float simLoc2X4  = -1.0;
float simLoc2X5 = -1.0;  float simLoc2X6  = -1.0; float simLoc2X7  = -1.0; float simLoc2X8  = -1.0;
float simLoc2X9 = -1.0;  float simLoc2X10 = -1.0; float simLoc2X11 = -1.0; float simLoc2X12 = -1.0;

float getSimLoc2X(int id = 0) {
	if(id == 1) return(simLoc2X1); if(id == 2)  return(simLoc2X2);  if(id == 3)  return(simLoc2X3);  if(id == 4)  return(simLoc2X4);
	if(id == 5) return(simLoc2X5); if(id == 6)  return(simLoc2X6);  if(id == 7)  return(simLoc2X7);  if(id == 8)  return(simLoc2X8);
	if(id == 9) return(simLoc2X9); if(id == 10) return(simLoc2X10); if(id == 11) return(simLoc2X11); if(id == 12) return(simLoc2X12);
	return(-1.0);
}

void setSimLoc2X(int id = 0, float val = -1.0) {
	if(id == 1) simLoc2X1 = val; if(id == 2)  simLoc2X2  = val; if(id == 3)  simLoc2X3  = val; if(id == 4)  simLoc2X4  = val;
	if(id == 5) simLoc2X5 = val; if(id == 6)  simLoc2X6  = val; if(id == 7)  simLoc2X7  = val; if(id == 8)  simLoc2X8  = val;
	if(id == 9) simLoc2X9 = val; if(id == 10) simLoc2X10 = val; if(id == 11) simLoc2X11 = val; if(id == 12) simLoc2X12 = val;
}

float simLoc3X1 = -1.0;  float simLoc3X2  = -1.0; float simLoc3X3  = -1.0; float simLoc3X4  = -1.0;
float simLoc3X5 = -1.0;  float simLoc3X6  = -1.0; float simLoc3X7  = -1.0; float simLoc3X8  = -1.0;
float simLoc3X9 = -1.0;  float simLoc3X10 = -1.0; float simLoc3X11 = -1.0; float simLoc3X12 = -1.0;

float getSimLoc3X(int id = 0) {
	if(id == 1) return(simLoc3X1); if(id == 2)  return(simLoc3X2);  if(id == 3)  return(simLoc3X3);  if(id == 4)  return(simLoc3X4);
	if(id == 5) return(simLoc3X5); if(id == 6)  return(simLoc3X6);  if(id == 7)  return(simLoc3X7);  if(id == 8)  return(simLoc3X8);
	if(id == 9) return(simLoc3X9); if(id == 10) return(simLoc3X10); if(id == 11) return(simLoc3X11); if(id == 12) return(simLoc3X12);
	return(-1.0);
}

void setSimLoc3X(int id = 0, float val = -1.0) {
	if(id == 1) simLoc3X1 = val; if(id == 2)  simLoc3X2  = val; if(id == 3)  simLoc3X3  = val; if(id == 4)  simLoc3X4  = val;
	if(id == 5) simLoc3X5 = val; if(id == 6)  simLoc3X6  = val; if(id == 7)  simLoc3X7  = val; if(id == 8)  simLoc3X8  = val;
	if(id == 9) simLoc3X9 = val; if(id == 10) simLoc3X10 = val; if(id == 11) simLoc3X11 = val; if(id == 12) simLoc3X12 = val;
}

float simLoc4X1 = -1.0;  float simLoc4X2  = -1.0; float simLoc4X3  = -1.0; float simLoc4X4  = -1.0;
float simLoc4X5 = -1.0;  float simLoc4X6  = -1.0; float simLoc4X7  = -1.0; float simLoc4X8  = -1.0;
float simLoc4X9 = -1.0;  float simLoc4X10 = -1.0; float simLoc4X11 = -1.0; float simLoc4X12 = -1.0;

float getSimLoc4X(int id = 0) {
	if(id == 1) return(simLoc4X1); if(id == 2)  return(simLoc4X2);  if(id == 3)  return(simLoc4X3);  if(id == 4)  return(simLoc4X4);
	if(id == 5) return(simLoc4X5); if(id == 6)  return(simLoc4X6);  if(id == 7)  return(simLoc4X7);  if(id == 8)  return(simLoc4X8);
	if(id == 9) return(simLoc4X9); if(id == 10) return(simLoc4X10); if(id == 11) return(simLoc4X11); if(id == 12) return(simLoc4X12);
	return(-1.0);
}

void setSimLoc4X(int id = 0, float val = -1.0) {
	if(id == 1) simLoc4X1 = val; if(id == 2)  simLoc4X2  = val; if(id == 3)  simLoc4X3  = val; if(id == 4)  simLoc4X4  = val;
	if(id == 5) simLoc4X5 = val; if(id == 6)  simLoc4X6  = val; if(id == 7)  simLoc4X7  = val; if(id == 8)  simLoc4X8  = val;
	if(id == 9) simLoc4X9 = val; if(id == 10) simLoc4X10 = val; if(id == 11) simLoc4X11 = val; if(id == 12) simLoc4X12 = val;
}

/*
** Gets the x coordinate of a similar location.
**
** @param simLocID: the ID of the similar location
** @param id: the index of the coordinate in the array
**
** @returns: the x coordinate of the similar location
*/
float getSimLocX(int simLocID = 0, int id = 0) {
	if(simLocID == 1) return(getSimLoc1X(id)); if(simLocID == 2) return(getSimLoc2X(id));
	if(simLocID == 3) return(getSimLoc3X(id)); if(simLocID == 4) return(getSimLoc4X(id));
	return(-1.0);
}

/*
** Sets the x coordinate of a similar location.
**
** @param simLocID: the ID of the similar location
** @param id: the index of the coordinate in the array
** @param val: the value to set
*/
void setSimLocX(int simLocID = 0, int id = 0, float val = -1.0) {
	if(simLocID == 1) setSimLoc1X(id, val); if(simLocID == 2) setSimLoc2X(id, val);
	if(simLocID == 3) setSimLoc3X(id, val); if(simLocID == 4) setSimLoc4X(id, val);
}

// Similar locations Z values.
float simLoc1Z1 = -1.0; float simLoc1Z2  = -1.0; float simLoc1Z3  = -1.0; float simLoc1Z4  = -1.0;
float simLoc1Z5 = -1.0; float simLoc1Z6  = -1.0; float simLoc1Z7  = -1.0; float simLoc1Z8  = -1.0;
float simLoc1Z9 = -1.0; float simLoc1Z10 = -1.0; float simLoc1Z11 = -1.0; float simLoc1Z12 = -1.0;

float getSimLoc1Z(int id = 0) {
	if(id == 1) return(simLoc1Z1); if(id == 2)  return(simLoc1Z2);  if(id == 3)  return(simLoc1Z3);  if(id == 4)  return(simLoc1Z4);
	if(id == 5) return(simLoc1Z5); if(id == 6)  return(simLoc1Z6);  if(id == 7)  return(simLoc1Z7);  if(id == 8)  return(simLoc1Z8);
	if(id == 9) return(simLoc1Z9); if(id == 10) return(simLoc1Z10); if(id == 11) return(simLoc1Z11); if(id == 12) return(simLoc1Z12);
	return(-1.0);
}

void setSimLoc1Z(int id = 0, float val = -1.0) {
	if(id == 1) simLoc1Z1 = val; if(id == 2)  simLoc1Z2  = val; if(id == 3)  simLoc1Z3  = val; if(id == 4)  simLoc1Z4  = val;
	if(id == 5) simLoc1Z5 = val; if(id == 6)  simLoc1Z6  = val; if(id == 7)  simLoc1Z7  = val; if(id == 8)  simLoc1Z8  = val;
	if(id == 9) simLoc1Z9 = val; if(id == 10) simLoc1Z10 = val; if(id == 11) simLoc1Z11 = val; if(id == 12) simLoc1Z12 = val;
}

float simLoc2Z1 = -1.0; float simLoc2Z2  = -1.0; float simLoc2Z3  = -1.0; float simLoc2Z4  = -1.0;
float simLoc2Z5 = -1.0; float simLoc2Z6  = -1.0; float simLoc2Z7  = -1.0; float simLoc2Z8  = -1.0;
float simLoc2Z9 = -1.0; float simLoc2Z10 = -1.0; float simLoc2Z11 = -1.0; float simLoc2Z12 = -1.0;

float getSimLoc2Z(int id = 0) {
	if(id == 1) return(simLoc2Z1); if(id == 2)  return(simLoc2Z2);  if(id == 3)  return(simLoc2Z3);  if(id == 4)  return(simLoc2Z4);
	if(id == 5) return(simLoc2Z5); if(id == 6)  return(simLoc2Z6);  if(id == 7)  return(simLoc2Z7);  if(id == 8)  return(simLoc2Z8);
	if(id == 9) return(simLoc2Z9); if(id == 10) return(simLoc2Z10); if(id == 11) return(simLoc2Z11); if(id == 12) return(simLoc2Z12);
	return(-1.0);
}

void setSimLoc2Z(int id = 0, float val = -1.0) {
	if(id == 1) simLoc2Z1 = val; if(id == 2)  simLoc2Z2  = val; if(id == 3)  simLoc2Z3  = val; if(id == 4)  simLoc2Z4  = val;
	if(id == 5) simLoc2Z5 = val; if(id == 6)  simLoc2Z6  = val; if(id == 7)  simLoc2Z7  = val; if(id == 8)  simLoc2Z8  = val;
	if(id == 9) simLoc2Z9 = val; if(id == 10) simLoc2Z10 = val; if(id == 11) simLoc2Z11 = val; if(id == 12) simLoc2Z12 = val;
}

float simLoc3Z1 = -1.0; float simLoc3Z2  = -1.0; float simLoc3Z3  = -1.0; float simLoc3Z4  = -1.0;
float simLoc3Z5 = -1.0; float simLoc3Z6  = -1.0; float simLoc3Z7  = -1.0; float simLoc3Z8  = -1.0;
float simLoc3Z9 = -1.0; float simLoc3Z10 = -1.0; float simLoc3Z11 = -1.0; float simLoc3Z12 = -1.0;

float getSimLoc3Z(int id = 0) {
	if(id == 1) return(simLoc3Z1); if(id == 2)  return(simLoc3Z2);  if(id == 3)  return(simLoc3Z3);  if(id == 4)  return(simLoc3Z4);
	if(id == 5) return(simLoc3Z5); if(id == 6)  return(simLoc3Z6);  if(id == 7)  return(simLoc3Z7);  if(id == 8)  return(simLoc3Z8);
	if(id == 9) return(simLoc3Z9); if(id == 10) return(simLoc3Z10); if(id == 11) return(simLoc3Z11); if(id == 12) return(simLoc3Z12);
	return(-1.0);
}

void setSimLoc3Z(int id = 0, float val = -1.0) {
	if(id == 1) simLoc3Z1 = val; if(id == 2)  simLoc3Z2  = val; if(id == 3)  simLoc3Z3  = val; if(id == 4)  simLoc3Z4  = val;
	if(id == 5) simLoc3Z5 = val; if(id == 6)  simLoc3Z6  = val; if(id == 7)  simLoc3Z7  = val; if(id == 8)  simLoc3Z8  = val;
	if(id == 9) simLoc3Z9 = val; if(id == 10) simLoc3Z10 = val; if(id == 11) simLoc3Z11 = val; if(id == 12) simLoc3Z12 = val;
}

float simLoc4Z1 = -1.0; float simLoc4Z2  = -1.0; float simLoc4Z3  = -1.0; float simLoc4Z4  = -1.0;
float simLoc4Z5 = -1.0; float simLoc4Z6  = -1.0; float simLoc4Z7  = -1.0; float simLoc4Z8  = -1.0;
float simLoc4Z9 = -1.0; float simLoc4Z10 = -1.0; float simLoc4Z11 = -1.0; float simLoc4Z12 = -1.0;

float getSimLoc4Z(int id = 0) {
	if(id == 1) return(simLoc4Z1); if(id == 2)  return(simLoc4Z2);  if(id == 3)  return(simLoc4Z3);  if(id == 4)  return(simLoc4Z4);
	if(id == 5) return(simLoc4Z5); if(id == 6)  return(simLoc4Z6);  if(id == 7)  return(simLoc4Z7);  if(id == 8)  return(simLoc4Z8);
	if(id == 9) return(simLoc4Z9); if(id == 10) return(simLoc4Z10); if(id == 11) return(simLoc4Z11); if(id == 12) return(simLoc4Z12);
	return(-1.0);
}

void setSimLoc4Z(int id = 0, float val = -1.0) {
	if(id == 1) simLoc4Z1 = val; if(id == 2)  simLoc4Z2  = val; if(id == 3)  simLoc4Z3  = val; if(id == 4)  simLoc4Z4  = val;
	if(id == 5) simLoc4Z5 = val; if(id == 6)  simLoc4Z6  = val; if(id == 7)  simLoc4Z7  = val; if(id == 8)  simLoc4Z8  = val;
	if(id == 9) simLoc4Z9 = val; if(id == 10) simLoc4Z10 = val; if(id == 11) simLoc4Z11 = val; if(id == 12) simLoc4Z12 = val;
}

/*
** Gets the z coordinate of a similar location.
**
** @param simLocID: the ID of the similar location
** @param id: the index of the coordinate in the array
**
** @returns: the z coordinate of the similar location
*/
float getSimLocZ(int simLocID = 0, int id = 0) {
	if(simLocID == 1) return(getSimLoc1Z(id)); if(simLocID == 2) return(getSimLoc2Z(id));
	if(simLocID == 3) return(getSimLoc3Z(id)); if(simLocID == 4) return(getSimLoc4Z(id));
	return(-1.0);
}

/*
** Sets the z coordinate of a similar location.
**
** @param simLocID: the ID of the similar location
** @param id: the index of the coordinate in the array
** @param val: the value to set
*/
void setSimLocZ(int simLocID = 0, int id = 0, float val = -1.0) {
	if(simLocID == 1) setSimLoc1Z(id, val); if(simLocID == 2) setSimLoc2Z(id, val);
	if(simLocID == 3) setSimLoc3Z(id, val); if(simLocID == 4) setSimLoc4Z(id, val);
}

/*
** Sets both coordinates for a similar location.
**
** @param simLocID: the ID of the similar location
** @param id: the index of the coordinate in the array
** @param x: the x value to set
** @param z: the z value to set
*/
void setSimLocXZ(int simLocID = 0, int id = 0, float x = -1.0, float z = -1.0) {
	setSimLocX(simLocID, id, x);
	setSimLocZ(simLocID, id, z);
}

/**************
* CONSTRAINTS *
**************/

// Similar location constraints.
int simLocConstraintCount1 = 0; int simLocConstraintCount2 = 0; int simLocConstraintCount3 = 0; int simLocConstraintCount4 = 0;

int simLoc1Constraint1 = -1; int simLoc1Constraint2  = -1; int simLoc1Constraint3  = -1; int simLoc1Constraint4  = -1;
int simLoc1Constraint5 = -1; int simLoc1Constraint6  = -1; int simLoc1Constraint7  = -1; int simLoc1Constraint8  = -1;
int simLoc1Constraint9 = -1; int simLoc1Constraint10 = -1; int simLoc1Constraint11 = -1; int simLoc1Constraint12 = -1;

int getSimLoc1Constraint(int id = 0) {
	if(id == 1) return(simLoc1Constraint1); if(id == 2)  return(simLoc1Constraint2);  if(id == 3)  return(simLoc1Constraint3);  if(id == 4)  return(simLoc1Constraint4);
	if(id == 5) return(simLoc1Constraint5); if(id == 6)  return(simLoc1Constraint6);  if(id == 7)  return(simLoc1Constraint7);  if(id == 8)  return(simLoc1Constraint8);
	if(id == 9) return(simLoc1Constraint9); if(id == 10) return(simLoc1Constraint10); if(id == 11) return(simLoc1Constraint11); if(id == 12) return(simLoc1Constraint12);
	return(-1);
}

void setSimLoc1Constraint(int id = 0, int cID = -1) {
	if(id == 1) simLoc1Constraint1 = cID; if(id == 2)  simLoc1Constraint2  = cID; if(id == 3)  simLoc1Constraint3  = cID; if(id == 4)  simLoc1Constraint4  = cID;
	if(id == 5) simLoc1Constraint5 = cID; if(id == 6)  simLoc1Constraint6  = cID; if(id == 7)  simLoc1Constraint7  = cID; if(id == 8)  simLoc1Constraint8  = cID;
	if(id == 9) simLoc1Constraint9 = cID; if(id == 10) simLoc1Constraint10 = cID; if(id == 11) simLoc1Constraint11 = cID; if(id == 12) simLoc1Constraint12 = cID;
}

int simLoc2Constraint1 = -1; int simLoc2Constraint2  = -1; int simLoc2Constraint3  = -1; int simLoc2Constraint4  = -1;
int simLoc2Constraint5 = -1; int simLoc2Constraint6  = -1; int simLoc2Constraint7  = -1; int simLoc2Constraint8  = -1;
int simLoc2Constraint9 = -1; int simLoc2Constraint10 = -1; int simLoc2Constraint11 = -1; int simLoc2Constraint12 = -1;

int getSimLoc2Constraint(int id = 0) {
	if(id == 1) return(simLoc2Constraint1); if(id == 2)  return(simLoc2Constraint2);  if(id == 3)  return(simLoc2Constraint3);  if(id == 4)  return(simLoc2Constraint4);
	if(id == 5) return(simLoc2Constraint5); if(id == 6)  return(simLoc2Constraint6);  if(id == 7)  return(simLoc2Constraint7);  if(id == 8)  return(simLoc2Constraint8);
	if(id == 9) return(simLoc2Constraint9); if(id == 10) return(simLoc2Constraint10); if(id == 11) return(simLoc2Constraint11); if(id == 12) return(simLoc2Constraint12);
	return(-1);
}

void setSimLoc2Constraint(int id = 0, int cID = -1) {
	if(id == 1) simLoc2Constraint1 = cID; if(id == 2)  simLoc2Constraint2  = cID; if(id == 3)  simLoc2Constraint3  = cID; if(id == 4)  simLoc2Constraint4  = cID;
	if(id == 5) simLoc2Constraint5 = cID; if(id == 6)  simLoc2Constraint6  = cID; if(id == 7)  simLoc2Constraint7  = cID; if(id == 8)  simLoc2Constraint8  = cID;
	if(id == 9) simLoc2Constraint9 = cID; if(id == 10) simLoc2Constraint10 = cID; if(id == 11) simLoc2Constraint11 = cID; if(id == 12) simLoc2Constraint12 = cID;
}

int simLoc3Constraint1 = -1; int simLoc3Constraint2  = -1; int simLoc3Constraint3  = -1; int simLoc3Constraint4  = -1;
int simLoc3Constraint5 = -1; int simLoc3Constraint6  = -1; int simLoc3Constraint7  = -1; int simLoc3Constraint8  = -1;
int simLoc3Constraint9 = -1; int simLoc3Constraint10 = -1; int simLoc3Constraint11 = -1; int simLoc3Constraint12 = -1;

int getSimLoc3Constraint(int id = 0) {
	if(id == 1) return(simLoc3Constraint1); if(id == 2)  return(simLoc3Constraint2);  if(id == 3)  return(simLoc3Constraint3);  if(id == 4)  return(simLoc3Constraint4);
	if(id == 5) return(simLoc3Constraint5); if(id == 6)  return(simLoc3Constraint6);  if(id == 7)  return(simLoc3Constraint7);  if(id == 8)  return(simLoc3Constraint8);
	if(id == 9) return(simLoc3Constraint9); if(id == 10) return(simLoc3Constraint10); if(id == 11) return(simLoc3Constraint11); if(id == 12) return(simLoc3Constraint12);
	return(-1);
}

void setSimLoc3Constraint(int id = 0, int cID = -1) {
	if(id == 1) simLoc3Constraint1 = cID; if(id == 2)  simLoc3Constraint2  = cID; if(id == 3)  simLoc3Constraint3  = cID; if(id == 4)  simLoc3Constraint4  = cID;
	if(id == 5) simLoc3Constraint5 = cID; if(id == 6)  simLoc3Constraint6  = cID; if(id == 7)  simLoc3Constraint7  = cID; if(id == 8)  simLoc3Constraint8  = cID;
	if(id == 9) simLoc3Constraint9 = cID; if(id == 10) simLoc3Constraint10 = cID; if(id == 11) simLoc3Constraint11 = cID; if(id == 12) simLoc3Constraint12 = cID;
}

int simLoc4Constraint1 = -1; int simLoc4Constraint2  = -1; int simLoc4Constraint3  = -1; int simLoc4Constraint4  = -1;
int simLoc4Constraint5 = -1; int simLoc4Constraint6  = -1; int simLoc4Constraint7  = -1; int simLoc4Constraint8  = -1;
int simLoc4Constraint9 = -1; int simLoc4Constraint10 = -1; int simLoc4Constraint11 = -1; int simLoc4Constraint12 = -1;

int getSimLoc4Constraint(int id = 0) {
	if(id == 1) return(simLoc4Constraint1); if(id == 2)  return(simLoc4Constraint2);  if(id == 3)  return(simLoc4Constraint3);  if(id == 4)  return(simLoc4Constraint4);
	if(id == 5) return(simLoc4Constraint5); if(id == 6)  return(simLoc4Constraint6);  if(id == 7)  return(simLoc4Constraint7);  if(id == 8)  return(simLoc4Constraint8);
	if(id == 9) return(simLoc4Constraint9); if(id == 10) return(simLoc4Constraint10); if(id == 11) return(simLoc4Constraint11); if(id == 12) return(simLoc4Constraint12);
	return(-1);
}

void setSimLoc4Constraint(int id = 0, int cID = -1) {
	if(id == 1) simLoc4Constraint1 = cID; if(id == 2)  simLoc4Constraint2  = cID; if(id == 3)  simLoc4Constraint3  = cID; if(id == 4)  simLoc4Constraint4  = cID;
	if(id == 5) simLoc4Constraint5 = cID; if(id == 6)  simLoc4Constraint6  = cID; if(id == 7)  simLoc4Constraint7  = cID; if(id == 8)  simLoc4Constraint8  = cID;
	if(id == 9) simLoc4Constraint9 = cID; if(id == 10) simLoc4Constraint10 = cID; if(id == 11) simLoc4Constraint11 = cID; if(id == 12) simLoc4Constraint12 = cID;
}

/*
** Obtains a stored constraint for a given similar location.
**
** @param simLocID: the ID of the similar location
** @param id: the index of the constraint in the constraint array
**
** @returns: the ID of the constraint
*/
int getSimLocConstraint(int simLocID = 0, int id = 0) {
	if(simLocID == 1) return(getSimLoc1Constraint(id)); if(simLocID == 2) return(getSimLoc2Constraint(id));
	if(simLocID == 3) return(getSimLoc3Constraint(id)); if(simLocID == 4) return(getSimLoc4Constraint(id));
	return(-1);
}

/*
** Adds an area constraint to a certain similar location.
**
** The signature of this function may seem a little inconsistent, but it's a lot more convenient.
** Since usually the current similar location is used, the second argument can often be omitted.
** The exception (and reason why the second argument exists) are cases where you may want to have
** similar locations added in a different order depending on the number of players.
** Remember that the similar locations with the lower IDs are placed first.
**
** @param cID: the ID of the constraint
** @param simLocID: the ID of the similar location the constraint should belong to
*/
void addSimLocConstraint(int cID = -1, int simLocID = -1) {
	if(simLocID < 0) {
		simLocID = simLocCount + 1;
	}

	if(simLocID == 1) {
		simLocConstraintCount1++;
		setSimLoc1Constraint(simLocConstraintCount1, cID);
	} else if(simLocID == 2) {
		simLocConstraintCount2++;
		setSimLoc2Constraint(simLocConstraintCount2, cID);
	} else if(simLocID == 3) {
		simLocConstraintCount3++;
		setSimLoc3Constraint(simLocConstraintCount3, cID);
	} else if(simLocID == 4) {
		simLocConstraintCount4++;
		setSimLoc4Constraint(simLocConstraintCount4, cID);
	}
}

/*
** Returns the number of constraints for a certain similar location.
**
** @param simLocID: the ID of the similar location
**
** @returns: the number of constraints that have been added
*/
int getSimLocConstraintCount(int simLocID = 0) {
	if(simLocID == 1) return(simLocConstraintCount1); if(simLocID == 2) return(simLocConstraintCount2);
	if(simLocID == 3) return(simLocConstraintCount3); if(simLocID == 4) return(simLocConstraintCount4);
	return(-1);
}

/*************
* PARAMETERS *
*************/

// Min dist.
float simLoc1MinDist = 0.0; float simLoc2MinDist = 0.0; float simLoc3MinDist = 0.0; float simLoc4MinDist = 0.0;

float getSimLocMinDist(int id = 0) {
	if(id == 1) return(simLoc1MinDist); if(id == 2) return(simLoc2MinDist); if(id == 3) return(simLoc3MinDist); if(id == 4) return(simLoc4MinDist);
	return(0.0);
}

void setSimLocMinDist(int id = 0, float val = 0.0) {
	if(id == 1) simLoc1MinDist = val; if(id == 2) simLoc2MinDist = val; if(id == 3) simLoc3MinDist = val; if(id == 4) simLoc4MinDist = val;
}

// Max dist.
float simLoc1MaxDist = 0.0; float simLoc2MaxDist = 0.0; float simLoc3MaxDist = 0.0; float simLoc4MaxDist = 0.0;

float getSimLocMaxDist(int id = 0) {
	if(id == 1) return(simLoc1MaxDist); if(id == 2) return(simLoc2MaxDist); if(id == 3) return(simLoc3MaxDist); if(id == 4) return(simLoc4MaxDist);
	return(0.0);
}

void setSimLocMaxDist(int id = 0, float val = 0.0) {
	if(id == 1) simLoc1MaxDist = val; if(id == 2) simLoc2MaxDist = val; if(id == 3) simLoc3MaxDist = val; if(id == 4) simLoc4MaxDist = val;
}

// Area dist.
float simLoc1AreaDist = 0.0; float simLoc2AreaDist = 0.0; float simLoc3AreaDist = 0.0; float simLoc4AreaDist = 0.0;

float getSimLocAreaDist(int id = 0) {
	if(id == 1) return(simLoc1AreaDist); if(id == 2) return(simLoc2AreaDist); if(id == 3) return(simLoc3AreaDist); if(id == 4) return(simLoc4AreaDist);
	return(0.0);
}

void setSimLocAreaDist(int id = 0, float val = 0.0) {
	if(id == 1) simLoc1AreaDist = val; if(id == 2) simLoc2AreaDist = val; if(id == 3) simLoc3AreaDist = val; if(id == 4) simLoc4AreaDist = val;
}

// Edge dist x.
float simLoc1DistX = 0.0; float simLoc2DistX = 0.0; float simLoc3DistX = 0.0; float simLoc4DistX = 0.0;

float getSimLocDistX(int id = 0) {
	if(id == 1) return(simLoc1DistX); if(id == 2) return(simLoc2DistX); if(id == 3) return(simLoc3DistX); if(id == 4) return(simLoc4DistX);
	return(0.0);
}

void setSimLocDistX(int id = 0, float val = 0.0) {
	if(id == 1) simLoc1DistX = val; if(id == 2) simLoc2DistX = val; if(id == 3) simLoc3DistX = val; if(id == 4) simLoc4DistX = val;
}

// Edge dist z.
float simLoc1DistZ = 0.0; float simLoc2DistZ = 0.0; float simLoc3DistZ = 0.0; float simLoc4DistZ = 0.0;

float getSimLocDistZ(int id = 0) {
	if(id == 1) return(simLoc1DistZ); if(id == 2) return(simLoc2DistZ); if(id == 3) return(simLoc3DistZ); if(id == 4) return(simLoc4DistZ);
	return(0.0);
}

void setSimLocDistZ(int id = 0, float val = 0.0) {
	if(id == 1) simLoc1DistZ = val; if(id == 2) simLoc2DistZ = val; if(id == 3) simLoc3DistZ = val; if(id == 4) simLoc4DistZ = val;
}

// Inside out.
bool simLoc1InsideOut = true; bool simLoc2InsideOut = true; bool simLoc3InsideOut = true; bool simLoc4InsideOut = true;

bool getSimLocInsideOut(int id = 0) {
	if(id == 1) return(simLoc1InsideOut); if(id == 2) return(simLoc2InsideOut); if(id == 3) return(simLoc3InsideOut); if(id == 4) return(simLoc4InsideOut);
	return(true);
}

void setSimLocInsideOut(int id = 0, bool val = true) {
	if(id == 1) simLoc1InsideOut = val; if(id == 2) simLoc2InsideOut = val; if(id == 3) simLoc3InsideOut = val; if(id == 4) simLoc4InsideOut = val;
}

// In player area.
bool simLoc1InPlayerArea = false; bool simLoc2InPlayerArea = false; bool simLoc3InPlayerArea = false; bool simLoc4InPlayerArea = false;

bool getSimLocInPlayerArea(int id = 0) {
	if(id == 1) return(simLoc1InPlayerArea); if(id == 2) return(simLoc2InPlayerArea); if(id == 3) return(simLoc3InPlayerArea); if(id == 4) return(simLoc4InPlayerArea);
	return(false);
}

void setSimLocInPlayerArea(int id = 0, bool val = false) {
	if(id == 1) simLoc1InPlayerArea = val; if(id == 2) simLoc2InPlayerArea = val; if(id == 3) simLoc3InPlayerArea = val; if(id == 4) simLoc4InPlayerArea = val;
}

// In team area.
bool simLoc1InTeamArea = false; bool simLoc2InTeamArea = false; bool simLoc3InTeamArea = false; bool simLoc4InTeamArea = false;

bool getSimLocInTeamArea(int id = 0) {
	if(id == 1) return(simLoc1InTeamArea); if(id == 2) return(simLoc2InTeamArea);	if(id == 3) return(simLoc3InTeamArea); if(id == 4) return(simLoc4InTeamArea);
	return(false);
}

void setSimLocInTeamArea(int id = 0, bool val = false) {
	if(id == 1) simLoc1InTeamArea = val; if(id == 2) simLoc2InTeamArea = val; if(id == 3) simLoc3InTeamArea = val; if(id == 4) simLoc4InTeamArea = val;
}

// Whether to use square placement or not.
bool simLoc1IsSquare = false; bool simLoc2IsSquare = false; bool simLoc3IsSquare = false; bool simLoc4IsSquare = false;

bool getSimLocIsSquare(int id = 0) {
	if(id == 1) return(simLoc1IsSquare); if(id == 2) return(simLoc2IsSquare);	if(id == 3) return(simLoc3IsSquare); if(id == 4) return(simLoc4IsSquare);
	return(false);
}

void setSimLocIsSquare(int id = 0, bool val = false) {
	if(id == 1) simLoc1IsSquare = val; if(id == 2) simLoc2IsSquare = val; if(id == 3) simLoc3IsSquare = val; if(id == 4) simLoc4IsSquare = val;
}

// Angle bias, starting range.
float simLoc1BiasRangeFrom = 0.0; float simLoc2BiasRangeFrom = 0.0; float simLoc3BiasRangeFrom = 0.0; float simLoc4BiasRangeFrom = 0.0;

float getSimLocBiasRangeFrom(int id = 0) {
	if(id == 1) return(simLoc1BiasRangeFrom); if(id == 2) return(simLoc2BiasRangeFrom); if(id == 3) return(simLoc3BiasRangeFrom); if(id == 4) return(simLoc4BiasRangeFrom);
	return(0.0);
}

void setSimLocBiasRangeFrom(int id = 0, float val = 0.0) {
	if(id == 1) simLoc1BiasRangeFrom = val; if(id == 2) simLoc2BiasRangeFrom = val; if(id == 3) simLoc3BiasRangeFrom = val; if(id == 4) simLoc4BiasRangeFrom = val;
}

// Angle bias, ending range.
float simLoc1BiasRangeTo = 1.0; float simLoc2BiasRangeTo = 1.0; float simLoc3BiasRangeTo = 1.0; float simLoc4BiasRangeTo = 1.0;

float getSimLocBiasRangeTo(int id = 0) {
	if(id == 1) return(simLoc1BiasRangeTo); if(id == 2) return(simLoc2BiasRangeTo); if(id == 3) return(simLoc3BiasRangeTo); if(id == 4) return(simLoc4BiasRangeTo);
	return(1.0);
}

void setSimLocBiasRangeTo(int id = 0, float val = 1.0) {
	if(id == 1) simLoc1BiasRangeTo = val; if(id == 2) simLoc2BiasRangeTo = val; if(id == 3) simLoc3BiasRangeTo = val; if(id == 4) simLoc4BiasRangeTo = val;
}

/*
** Sets an angle bias for a similar location.
** This bias restricts the range of angles that a location can be in with respect to the player.
** The maximum range is [0, PI] which is the entire left half when looking from a player's spawn towards the center of the map.
** Since this range is always "mirrored" such that the angle may be randomized from either side, [0, PI] essentially spans the entire angle range.
** For instance, [0.5, 1.0] * PI means that we can only randomize forward angles (effectively from 0.5 * PI to 1.5 * PI with the mirroring of [0.5, 1.0] * PI to [1.0, 1.5] * PI).
**
** @param biasConst: one of the bias constants
** @param simLocID: the ID of the similar location to apply the bias to
*/
void setSimLocBias(int biasConst = cBiasNone, int simLocID = -1) {
	if(simLocID < 0) { // Use current simLoc if defaulted.
		simLocID = simLocCount + 1;
	}

	// The bias values only have to be set for one side, as the algorithm will automatically randomize from the other side (symmetrically) as well.
	if(biasConst == cBiasNone) {
		setSimLocBiasRangeFrom(simLocID, NINF);
		setSimLocBiasRangeTo(simLocID, NINF);
	} else if(biasConst == cBiasForward) { // [0.5, 1.0] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.5);
		setSimLocBiasRangeTo(simLocID, 1.0);
	} else if(biasConst == cBiasBackward) { // [0.0, 0.5] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.0);
		setSimLocBiasRangeTo(simLocID, 0.5);
	} else if(biasConst == cBiasSide) { // [0.25, 0.75] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.25);
		setSimLocBiasRangeTo(simLocID, 0.75);
	} else if(biasConst == cBiasAggressive) { // [0.75, 1.0] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.75);
		setSimLocBiasRangeTo(simLocID, 1.0);
	} else if(biasConst == cBiasDefensive) { // [0.0, 0.25] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.0);
		setSimLocBiasRangeTo(simLocID, 0.25);
	} else if(biasConst == cBiasNotDefensive) { // [0.25, 1.0] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.25);
		setSimLocBiasRangeTo(simLocID, 1.0);
	} else if(biasConst == cBiasNotAggressive) { // [0.0, 0.75] * PI.
		setSimLocBiasRangeFrom(simLocID, 0.0);
		setSimLocBiasRangeTo(simLocID, 0.75);
	}
}

/*
** Sets a custom bias for the range.
**
** Only use this if you understand the concept or you may break stuff!
**
** DON'T MULTIPLY THE RANGES WITH PI YET, THE RANDOMIZATION FUNCTION WILL DO THAT!
** For instance, if you want to restrict the angles to forward angles only, use setSimLocCustomBias(0.5, 1.0, mySimLocID).
**
** @param rangeFrom: the starting fraction in [0, 2.0] of the section
** @param rangeTo: the ending fraction in [0, 2.0] of the section; has to be greater than rangeFrom (!)
** @param simLocID: the ID of the similar location to set the bias for
*/
void setSimLocCustomBias(float rangeFrom = 0.0, float rangeTo = 1.0, int simLocID = -1) {
	if(simLocID < 0) { // Use current simLoc if defaulted.
		simLocID = simLocCount + 1;
	}

	setSimLocBiasRangeFrom(simLocID, rangeFrom);
	setSimLocBiasRangeTo(simLocID, rangeTo);
}

// Radius interval.
float simLoc1RadiusInterval = 30.0; float simLoc2RadiusInterval = 30.0; float simLoc3RadiusInterval = 30.0; float simLoc4RadiusInterval = 30.0;

float getSimLocRadiusInterval(int id = 0) {
	if(id == 1) return(simLoc1RadiusInterval); if(id == 2) return(simLoc2RadiusInterval); if(id == 3) return(simLoc3RadiusInterval); if(id == 4) return(simLoc4RadiusInterval);
	return(0.0);
}

void setSimLocRadiusInterval(int id = 0, float val = 30.0) {
	if(id == 1) simLoc1RadiusInterval = val; if(id == 2) simLoc2RadiusInterval = val; if(id == 3) simLoc3RadiusInterval = val; if(id == 4) simLoc4RadiusInterval = val;
}

/*
** Sets the interval around the randomized radius, which is then used to randomize individual radii.
** Gets constrained by upper/lower bound if exceeding those.
**
** @param interval: the interval to set (half of this value is subtracted/added to the randomized angle)
** @param simLocID: the ID of the similar location to set the interval for
*/
void setSimLocInterval(float interval = 30.0, int simLocID = -1) {
	if(simLocID < 0) { // Use current simLoc if defaulted.
		simLocID = simLocCount + 1;
	}

	setSimLocRadiusInterval(simLocID, interval);
}

// Default segment size.
float simLoc1AngleSegSize = 0.25; float simLoc2AngleSegSize = 0.25; float simLoc3AngleSegSize = 0.25; float simLoc4AngleSegSize = 0.25;

float getSimLocAngleSegSize(int id = 0) {
	if(id == 1) return(simLoc1AngleSegSize); if(id == 2) return(simLoc2AngleSegSize); if(id == 3) return(simLoc3AngleSegSize); if(id == 4) return(simLoc4AngleSegSize);
	return(0.0);
}

void setSimLocAngleSegSize(int id = 0, float val = 0.25) {
	if(id == 1) simLoc1AngleSegSize = val; if(id == 2) simLoc2AngleSegSize = val; if(id == 3) simLoc3AngleSegSize = val; if(id == 4) simLoc4AngleSegSize = val;
}

/*
** Sets the segment size for a given similar location.
** The segment size is (contrary to "size") the angle that is used to extend the initially randomized angle for all players.
** This range of angles is then used to randomize the individual player angles.
**
** @param segSize: the segment size in [0, 1.0].
** @param simLocID: the ID of the similar location to set the segment size for
*/
void setSimLocSegSize(float segSize = 0.25, int simLocID = -1) {
	if(simLocID < 0) { // Use current simLoc if defaulted.
		simLocID = simLocCount + 1;
	}

	setSimLocAngleSegSize(simLocID, segSize);
}

// Default two player tolerance.
float simLoc1TwoPlayerTol = -1.0; float simLoc2TwoPlayerTol = -1.0; float simLoc3TwoPlayerTol = -1.0; float simLoc4TwoPlayerTol = -1.0;

float getSimLocTwoPlayerTol(int id = 0) {
	if(id == 1) return(simLoc1TwoPlayerTol); if(id == 2) return(simLoc2TwoPlayerTol); if(id == 3) return(simLoc3TwoPlayerTol); if(id == 4) return(simLoc4TwoPlayerTol);
	return(-1.0);
}

void setSimLocTwoPlayerTol(int id = 0, float val = 0.2) {
	if(id == 1) simLoc1TwoPlayerTol = val; if(id == 2) simLoc2TwoPlayerTol = val; if(id == 3) simLoc3TwoPlayerTol = val; if(id == 4) simLoc4TwoPlayerTol = val;
}

/*
** Sets the maximum ratio for the two player check to tolerate.
**
** @param twoPlayerTol: the ratio as a float
** @param simLocID: the ID of the similar location to set the segment size for
*/
void enableSimLocTwoPlayerCheck(float twoPlayerTol = 0.2, int simLocID = -1) {
	if(simLocID < 0) { // Use current simLoc if defaulted.
		simLocID = simLocCount + 1;
	}

	setSimLocTwoPlayerTol(simLocID, twoPlayerTol);
}

// Inter dist.
float simLocInterDistMin = 0.0;
float simLocInterDistMax = INF;

/*
** Gets the minimum distance similar locations of a player have to be separated by.
**
** @returns: the distance in meters
*/
float getSimLocInterDistMin() {
	return(simLocInterDistMin);
}

/*
** Sets a minimum distance that similar locations of a player have to be separated by.
**
** @param val: the distance in meters
*/
void setSimLocInterDistMin(float val = 0.0) {
	simLocInterDistMin = val;
}

/*
** Gets the maximum distance similar locations of a player have to be separated by.
**
** @returns: the distance in meters
*/
float getSimLocInterDistMax() {
	return(simLocInterDistMax);
}

/*
** Sets a maximum distance that similar locations of a player can be separated by.
**
** @param val: the distance in meters
*/
void setSimLocInterDistMax(float val = INF) {
	simLocInterDistMax = val;
}

// Min cross distance.
float simLocMinCrossDist = 0.0;

/*
** Calculates the minimum cross distance that has to be guaranteed.
** This is the minimum distance that the separately specified similar locations (addSimLoc()) have to be apart from each other.
** Example: 2 similar locations were added with 80.0 and 60.0 areaDist, this means that the minimum cross distance is 60.0.
**
** Distance within the specific similar locations is checked separately.
*/
void calcSimLocMinCrossDist() {
	float tempMinCrossDist = INF;

	for(i = 1; <= simLocCount) {
		if(getSimLocAreaDist(i) < tempMinCrossDist) {
			tempMinCrossDist = getSimLocAreaDist(i);
		}
	}

	simLocMinCrossDist = tempMinCrossDist;
}

// Players start from 1 by convention (0 = Mother Nature).
int simLoc1Player1 = -1; int simLoc1Player2  = -1; int simLoc1Player3  = -1; int simLoc1Player4  = -1;
int simLoc1Player5 = -1; int simLoc1Player6  = -1; int simLoc1Player7  = -1; int simLoc1Player8  = -1;
int simLoc1Player9 = -1; int simLoc1Player10 = -1; int simLoc1Player11 = -1; int simLoc1Player12 = -1;

int getSimLoc1Player(int i = 0) {
	if(i == 1) return(simLoc1Player1); if(i == 2)  return(simLoc1Player2);  if(i == 3)  return(simLoc1Player3);  if(i == 4)  return(simLoc1Player4);
	if(i == 5) return(simLoc1Player5); if(i == 6)  return(simLoc1Player6);  if(i == 7)  return(simLoc1Player7);  if(i == 8)  return(simLoc1Player8);
	if(i == 9) return(simLoc1Player9); if(i == 10) return(simLoc1Player10); if(i == 11) return(simLoc1Player11); if(i == 12) return(simLoc1Player12);
	return(-1);
}

void setSimLoc1Player(int i = 0, int id = -1) {
	if(i == 1) simLoc1Player1 = id; if(i == 2)  simLoc1Player2  = id; if(i == 3)  simLoc1Player3  = id; if(i == 4)  simLoc1Player4  = id;
	if(i == 5) simLoc1Player5 = id; if(i == 6)  simLoc1Player6  = id; if(i == 7)  simLoc1Player7  = id; if(i == 8)  simLoc1Player8  = id;
	if(i == 9) simLoc1Player9 = id; if(i == 10) simLoc1Player10 = id; if(i == 11) simLoc1Player11 = id; if(i == 12) simLoc1Player12 = id;
}

int simLoc2Player1 = -1; int simLoc2Player2  = -1; int simLoc2Player3  = -1; int simLoc2Player4  = -1;
int simLoc2Player5 = -1; int simLoc2Player6  = -1; int simLoc2Player7  = -1; int simLoc2Player8  = -1;
int simLoc2Player9 = -1; int simLoc2Player10 = -1; int simLoc2Player11 = -1; int simLoc2Player12 = -1;

int getSimLoc2Player(int i = 0) {
	if(i == 1) return(simLoc2Player1); if(i == 2)  return(simLoc2Player2);  if(i == 3)  return(simLoc2Player3);  if(i == 4)  return(simLoc2Player4);
	if(i == 5) return(simLoc2Player5); if(i == 6)  return(simLoc2Player6);  if(i == 7)  return(simLoc2Player7);  if(i == 8)  return(simLoc2Player8);
	if(i == 9) return(simLoc2Player9); if(i == 10) return(simLoc2Player10); if(i == 11) return(simLoc2Player11); if(i == 12) return(simLoc2Player12);
	return(-1);
}

void setSimLoc2Player(int i = 0, int id = -1) {
	if(i == 1) simLoc2Player1 = id; if(i == 2)  simLoc2Player2  = id; if(i == 3)  simLoc2Player3  = id; if(i == 4)  simLoc2Player4  = id;
	if(i == 5) simLoc2Player5 = id; if(i == 6)  simLoc2Player6  = id; if(i == 7)  simLoc2Player7  = id; if(i == 8)  simLoc2Player8  = id;
	if(i == 9) simLoc2Player9 = id; if(i == 10) simLoc2Player10 = id; if(i == 11) simLoc2Player11 = id; if(i == 12) simLoc2Player12 = id;
}

int simLoc3Player1 = -1; int simLoc3Player2  = -1; int simLoc3Player3  = -1; int simLoc3Player4  = -1;
int simLoc3Player5 = -1; int simLoc3Player6  = -1; int simLoc3Player7  = -1; int simLoc3Player8  = -1;
int simLoc3Player9 = -1; int simLoc3Player10 = -1; int simLoc3Player11 = -1; int simLoc3Player12 = -1;

int getSimLoc3Player(int i = 0) {
	if(i == 1) return(simLoc3Player1); if(i == 2)  return(simLoc3Player2);  if(i == 3)  return(simLoc3Player3);  if(i == 4)  return(simLoc3Player4);
	if(i == 5) return(simLoc3Player5); if(i == 6)  return(simLoc3Player6);  if(i == 7)  return(simLoc3Player7);  if(i == 8)  return(simLoc3Player8);
	if(i == 9) return(simLoc3Player9); if(i == 10) return(simLoc3Player10); if(i == 11) return(simLoc3Player11); if(i == 12) return(simLoc3Player12);
	return(-1);
}

void setSimLoc3Player(int i = 0, int id = -1) {
	if(i == 1) simLoc3Player1 = id; if(i == 2)  simLoc3Player2  = id; if(i == 3)  simLoc3Player3  = id; if(i == 4)  simLoc3Player4  = id;
	if(i == 5) simLoc3Player5 = id; if(i == 6)  simLoc3Player6  = id; if(i == 7)  simLoc3Player7  = id; if(i == 8)  simLoc3Player8  = id;
	if(i == 9) simLoc3Player9 = id; if(i == 10) simLoc3Player10 = id; if(i == 11) simLoc3Player11 = id; if(i == 12) simLoc3Player12 = id;
}

int simLoc4Player1 = -1; int simLoc4Player2  = -1; int simLoc4Player3  = -1; int simLoc4Player4  = -1;
int simLoc4Player5 = -1; int simLoc4Player6  = -1; int simLoc4Player7  = -1; int simLoc4Player8  = -1;
int simLoc4Player9 = -1; int simLoc4Player10 = -1; int simLoc4Player11 = -1; int simLoc4Player12 = -1;

int getSimLoc4Player(int i = 0) {
	if(i == 1) return(simLoc4Player1); if(i == 2)  return(simLoc4Player2);  if(i == 3)  return(simLoc4Player3);  if(i == 4)  return(simLoc4Player4);
	if(i == 5) return(simLoc4Player5); if(i == 6)  return(simLoc4Player6);  if(i == 7)  return(simLoc4Player7);  if(i == 8)  return(simLoc4Player8);
	if(i == 9) return(simLoc4Player9); if(i == 10) return(simLoc4Player10); if(i == 11) return(simLoc4Player11); if(i == 12) return(simLoc4Player12);
	return(-1);
}

void setSimLoc4Player(int i = 0, int id = -1) {
	if(i == 1) simLoc4Player1 = id; if(i == 2)  simLoc4Player2  = id; if(i == 3)  simLoc4Player3  = id; if(i == 4)  simLoc4Player4  = id;
	if(i == 5) simLoc4Player5 = id; if(i == 6)  simLoc4Player6  = id; if(i == 7)  simLoc4Player7  = id; if(i == 8)  simLoc4Player8  = id;
	if(i == 9) simLoc4Player9 = id; if(i == 10) simLoc4Player10 = id; if(i == 11) simLoc4Player11 = id; if(i == 12) simLoc4Player12 = id;
}

/*
** Gets a player in the array that stores the placement order of a similar location.
**
** @param simLocID: the ID of the similar location
** @param i: the index in the array to retrieve
** @param id: the player number to store in the specified array and index
*/
void setSimLocPlayer(int simLocID = -1, int i = 0, int id = -1) {
	if(simLocID == 1) {
		setSimLoc1Player(i, id);
	} else if(simLocID == 2) {
		setSimLoc2Player(i, id);
	} else if(simLocID == 3) {
		setSimLoc3Player(i, id);
	} else if(simLocID == 4) {
		setSimLoc4Player(i, id);
	}
}

/*
** Gets a player from the array that stores the placement order of a similar location.
**
** @param simLocID: the ID of the similar location
** @param i: the index in the array to retrieve
**
** @returns: the player stored in the specified array (simLocID) and index
*/
int getSimLocPlayer(int simLocID = -1, int i = 0) {
	if(simLocID == 1) {
		return(getSimLoc1Player(i));
	} else if(simLocID == 2) {
		return(getSimLoc2Player(i));
	} else if(simLocID == 3) {
		return(getSimLoc3Player(i));
	} else if(simLocID == 4) {
		return(getSimLoc4Player(i));
	}

	// Should never be reached.
	return(-1);
}

/*
** Sets the order in which similar locations are placed for a given similar location ID.
** This can be either inside out or outside in according to playerTeamPos values, i.e., the position of a player in a team.
** For instance, for 4v4 this means (F = first, C = center, L = last):
**
** 1 (F) <-> 8 (L)
** 2 (C) <-> 7 (C)
** 3 (C) <-> 6 (C)
** 4 (L) <-> 5 (F)
**
** For inside out, the players are ordered such that the center players (2, 3, 6, 7) have their locations placed first, then 1 and 5 and finally 4 and 8.
** For outside in, the inverse is done.
**
** For mirroring, the behavior is different: The respective mirrored player is inserted right after the "original" player.
**
** @param simLocID: the ID of the similar location
*/
void setSimLocPlayerOrder(int simLocID = -1) {
	int posStart = 0;
	int posEnd = cNumTeamPos - 1;

	// Go from negatve positions to 0 if we're placing inside out and take abs of p when used.
	if(getSimLocInsideOut(simLocID)) {
		posStart = 0 - posEnd;
		posEnd = 0;
	}

	int currPlayer = 1;
	int numPlayers = cNonGaiaPlayers;

	if(isMirrorOnAndValidConfig()) {
		numPlayers = getNumberPlayersOnTeam(0);
	}

	// Iterate over positions.
	for(p = posStart; <= posEnd) {

		// Iterate over players that have the current position.
		for(i = 1; <= numPlayers) {
			if(getPlayerTeamPos(i) != abs(p)) {
				// Player doesn't have current position, move on to next player.
				continue;
			}

			// Set mirrored player first (as it's position is also evaluated first).
			if(isMirrorOnAndValidConfig()) {
				setSimLocPlayer(simLocID, currPlayer, getMirroredPlayer(i));
				currPlayer++;
			}

			setSimLocPlayer(simLocID, currPlayer, i);

			currPlayer++;
		}

	}
}

/*
** Adds a similar location.
** Note that additional options such as enableSimLocTwoPlayerCheck() has to be called before this (or a simLocID has to be specified).
**
** @param minDist: the minimum distance of the radius for the similar location from the player location
** @param maxDist: the maximum distance of the radius for the similar location from the player location
** @param areaDist: the distances between the areas that will be enforced (!)
** @param distX: edge distance of the x axis of the location
** @param distZ: edge distance of the z axis of the location
** @param inPlayerArea: whether the location should be enforced to lie within a player's section of the map
** @param inTeamArea: whether the location should be enforced to lie within a player's team section of the map
** @param isSquare: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param insideOut: whether to start from the inner players or from the outer players when placing the locations
** @param simLocID: the ID of the similar location; if not given, the default counter is used (starting at 1) - only use this if you know what you're doing!
*/
void addSimLoc(float minDist = 0.0, float maxDist = -1.0, float areaDist = 0.0, float distX = 0.0, float distZ = -1.0,
			   bool inPlayerArea = false, bool inTeamArea = false, bool isSquare = false, bool insideOut = true, int simLocID = -1) {
	simLocCount++;

	if(distZ < 0.0) {
		distZ = distX;
	}

	if(simLocID < 0) {
		simLocID = simLocCount;
	}

	// Set last added ID.
	lastAddedSimLocID = simLocID;

	setSimLocMinDist(simLocID, minDist);
	setSimLocMaxDist(simLocID, maxDist);
	setSimLocAreaDist(simLocID, areaDist);
	setSimLocDistX(simLocID, distX);
	setSimLocDistZ(simLocID, distZ);
	setSimLocInPlayerArea(simLocID, inPlayerArea);
	setSimLocInTeamArea(simLocID, inTeamArea);
	setSimLocIsSquare(simLocID, isSquare);
	setSimLocInsideOut(simLocID, insideOut);

	// Update minCrossDist.
	calcSimLocMinCrossDist();

	// Set player order.
	setSimLocPlayerOrder(simLocID);
}

/*
** Adds a similar location and uses the same constraints as the previous simLoc did (but NOT same bias, twoPlayerTol, etc.).
**
** @param minDist: the minimum distance of the radius for the similar location from the player location
** @param maxDist: the maximum distance of the radius for the similar location from the player location
** @param areaDist: the distances between the areas that will be enforced (!)
** @param distX: edge distance of the x axis of the location
** @param distZ: edge distance of the z axis of the location
** @param inPlayerArea: whether the location should be enforced to lie within a player's section of the map
** @param inTeamArea: whether the location should be enforced to lie within a player's team section of the map
** @param isSquare: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param insideOut: whether to start from the inner players or from the outer players when placing the locations
** @param simLocID: the ID of the similar location; if not given, the default counter is used (starting at 1) - only use this if you know what you're doing!
*/
void addSimLocWithPrevConstraints(float minDist = 0.0, float maxDist = -1.0, float areaDist = 0.0, float distX = 0.0, float distZ = -1.0,
								  bool inPlayerArea = false, bool inTeamArea = false, bool isSquare = false, bool insideOut = true, int simLocID = -1) {
	if(simLocID < 0) {
		simLocID = simLocCount + 1;
	}

	if(lastAddedSimLocID > 0) {
		for(i = 1; <= getSimLocConstraintCount(lastAddedSimLocID)) {
			addSimLocConstraint(getSimLocConstraint(lastAddedSimLocID, i), simLocID);
		}
	}

	addSimLoc(minDist, maxDist, areaDist, distX, distZ, inPlayerArea, inTeamArea, insideOut, isSquare, simLocID);
}

/*
** Resets all similar loc values.
*/
void resetSimLocVals() {
	simLoc1X1 = -1.0; simLoc1X2  = -1.0; simLoc1X3  = -1.0; simLoc1X4  = -1.0;
	simLoc1X5 = -1.0; simLoc1X6  = -1.0; simLoc1X7  = -1.0; simLoc1X8  = -1.0;
	simLoc1X9 = -1.0; simLoc1X10 = -1.0; simLoc1X11 = -1.0; simLoc1X12 = -1.0;

	simLoc2X1 = -1.0; simLoc2X2  = -1.0; simLoc2X3  = -1.0; simLoc2X4  = -1.0;
	simLoc2X5 = -1.0; simLoc2X6  = -1.0; simLoc2X7  = -1.0; simLoc2X8  = -1.0;
	simLoc2X9 = -1.0; simLoc2X10 = -1.0; simLoc2X11 = -1.0; simLoc2X12 = -1.0;

	simLoc3X1 = -1.0; simLoc3X2  = -1.0; simLoc3X3  = -1.0; simLoc3X4  = -1.0;
	simLoc3X5 = -1.0; simLoc3X6  = -1.0; simLoc3X7  = -1.0; simLoc3X8  = -1.0;
	simLoc3X9 = -1.0; simLoc3X10 = -1.0; simLoc3X11 = -1.0; simLoc3X12 = -1.0;

	simLoc4X1 = -1.0; simLoc4X2  = -1.0; simLoc4X3  = -1.0; simLoc4X4  = -1.0;
	simLoc4X5 = -1.0; simLoc4X6  = -1.0; simLoc4X7  = -1.0; simLoc4X8  = -1.0;
	simLoc4X9 = -1.0; simLoc4X10 = -1.0; simLoc4X11 = -1.0; simLoc4X12 = -1.0;

	simLoc1Z1 = -1.0; simLoc1Z2  = -1.0; simLoc1Z3  = -1.0; simLoc1Z4  = -1.0;
	simLoc1Z5 = -1.0; simLoc1Z6  = -1.0; simLoc1Z7  = -1.0; simLoc1Z8  = -1.0;
	simLoc1Z9 = -1.0; simLoc1Z10 = -1.0; simLoc1Z11 = -1.0; simLoc1Z12 = -1.0;

	simLoc2Z1 = -1.0; simLoc2Z2  = -1.0; simLoc2Z3  = -1.0; simLoc2Z4  = -1.0;
	simLoc2Z5 = -1.0; simLoc2Z6  = -1.0; simLoc2Z7  = -1.0; simLoc2Z8  = -1.0;
	simLoc2Z9 = -1.0; simLoc2Z10 = -1.0; simLoc2Z11 = -1.0; simLoc2Z12 = -1.0;

	simLoc3Z1 = -1.0; simLoc3Z2  = -1.0; simLoc3Z3  = -1.0; simLoc3Z4  = -1.0;
	simLoc3Z5 = -1.0; simLoc3Z6  = -1.0; simLoc3Z7  = -1.0; simLoc3Z8  = -1.0;
	simLoc3Z9 = -1.0; simLoc3Z10 = -1.0; simLoc3Z11 = -1.0; simLoc3Z12 = -1.0;

	simLoc4Z1 = -1.0; simLoc4Z2  = -1.0; simLoc4Z3  = -1.0; simLoc4Z4  = -1.0;
	simLoc4Z5 = -1.0; simLoc4Z6  = -1.0; simLoc4Z7  = -1.0; simLoc4Z8  = -1.0;
	simLoc4Z9 = -1.0; simLoc4Z10 = -1.0; simLoc4Z11 = -1.0; simLoc4Z12 = -1.0;
}

/*
** Cleans similar location settings. Should be called after placing a set of similar locations (and before the next ones are defined).
*/
void resetSimLocs() {
	simLocCount = 0;
	lastSimLocIters = -1;
	lastAddedSimLocID = -1;

	simLocMinCrossDist = 0.0;
	simLocInterDistMin = 0.0;
	simLocInterDistMax = INF;

	// Write the resetting a bit more compact to save some lines.
	simLocConstraintCount1 = 0; simLocConstraintCount2 = 0;	simLocConstraintCount3 = 0; simLocConstraintCount4 = 0;
	simLoc1TwoPlayerTol = -1.0; simLoc2TwoPlayerTol = -1.0; simLoc3TwoPlayerTol = -1.0; simLoc4TwoPlayerTol = -1.0;

	simLoc1BiasRangeFrom = 0.0; simLoc2BiasRangeFrom = 0.0; simLoc3BiasRangeFrom = 0.0; simLoc4BiasRangeFrom = 0.0;
	simLoc1BiasRangeTo = 1.0; simLoc2BiasRangeTo = 1.0; simLoc3BiasRangeTo = 1.0; simLoc4BiasRangeTo = 1.0;
	simLoc1RadiusInterval = 30.0; simLoc2RadiusInterval = 30.0; simLoc3RadiusInterval = 30.0; simLoc4RadiusInterval = 30.0;
	simLoc1AngleSegSize = 0.25; simLoc2AngleSegSize = 0.25; simLoc3AngleSegSize = 0.25; simLoc4AngleSegSize = 0.25;

	// As of now, the following resets are actually not needed, but we do it anyway to keep it clean.
	resetSimLocVals();

	simLoc1Player1 = -1; simLoc1Player2  = -1; simLoc1Player3  = -1; simLoc1Player4  = -1;
	simLoc1Player5 = -1; simLoc1Player6  = -1; simLoc1Player7  = -1; simLoc1Player8  = -1;
	simLoc1Player9 = -1; simLoc1Player10 = -1; simLoc1Player11 = -1; simLoc1Player12 = -1;

	simLoc2Player1 = -1; simLoc2Player2  = -1; simLoc2Player3  = -1; simLoc2Player4  = -1;
	simLoc2Player5 = -1; simLoc2Player6  = -1; simLoc2Player7  = -1; simLoc2Player8  = -1;
	simLoc2Player9 = -1; simLoc2Player10 = -1; simLoc2Player11 = -1; simLoc2Player12 = -1;

	simLoc3Player1 = -1; simLoc3Player2  = -1; simLoc3Player3  = -1; simLoc3Player4  = -1;
	simLoc3Player5 = -1; simLoc3Player6  = -1; simLoc3Player7  = -1; simLoc3Player8  = -1;
	simLoc3Player9 = -1; simLoc3Player10 = -1; simLoc3Player11 = -1; simLoc3Player12 = -1;

	simLoc4Player1 = -1; simLoc4Player2  = -1; simLoc4Player3  = -1; simLoc4Player4  = -1;
	simLoc4Player5 = -1; simLoc4Player6  = -1; simLoc4Player7  = -1; simLoc4Player8  = -1;
	simLoc4Player9 = -1; simLoc4Player10 = -1; simLoc4Player11 = -1; simLoc4Player12 = -1;
}

// Temporary angles and radii used during calculation.
float simLocTempAngle1 = NINF; float simLocTempAngle2  = NINF; float simLocTempAngle3  = NINF; float simLocTempAngle4  = NINF;
float simLocTempAngle5 = NINF; float simLocTempAngle6  = NINF; float simLocTempAngle7  = NINF; float simLocTempAngle8  = NINF;
float simLocTempAngle9 = NINF; float simLocTempAngle10 = NINF; float simLocTempAngle11 = NINF; float simLocTempAngle12 = NINF;

float getSimLocTempAngle(int id = 0) {
	if(id == 1) return(simLocTempAngle1); if(id == 2)  return(simLocTempAngle2);  if(id == 3)  return(simLocTempAngle3);  if(id == 4)  return(simLocTempAngle4);
	if(id == 5) return(simLocTempAngle5); if(id == 6)  return(simLocTempAngle6);  if(id == 7)  return(simLocTempAngle7);  if(id == 8)  return(simLocTempAngle8);
	if(id == 9) return(simLocTempAngle9); if(id == 10) return(simLocTempAngle10); if(id == 11) return(simLocTempAngle11); if(id == 12) return(simLocTempAngle12);
	return(NINF);
}

void setSimLocTempAngle(int id = 0, float val = NINF) {
	if(id == 1) simLocTempAngle1 = val; if(id == 2)  simLocTempAngle2  = val; if(id == 3)  simLocTempAngle3  = val; if(id == 4)  simLocTempAngle4  = val;
	if(id == 5) simLocTempAngle5 = val; if(id == 6)  simLocTempAngle6  = val; if(id == 7)  simLocTempAngle7  = val; if(id == 8)  simLocTempAngle8  = val;
	if(id == 9) simLocTempAngle9 = val; if(id == 10) simLocTempAngle10 = val; if(id == 11) simLocTempAngle11 = val; if(id == 12) simLocTempAngle12 = val;
}

float simLocTempRadius1 = NINF; float simLocTempRadius2  = NINF; float simLocTempRadius3  = NINF; float simLocTempRadius4  = NINF;
float simLocTempRadius5 = NINF; float simLocTempRadius6  = NINF; float simLocTempRadius7  = NINF; float simLocTempRadius8  = NINF;
float simLocTempRadius9 = NINF; float simLocTempRadius10 = NINF; float simLocTempRadius11 = NINF; float simLocTempRadius12 = NINF;

float getSimLocTempRadius(int id = 0) {
	if(id == 1) return(simLocTempRadius1); if(id == 2)  return(simLocTempRadius2);  if(id == 3)  return(simLocTempRadius3);  if(id == 4)  return(simLocTempRadius4);
	if(id == 5) return(simLocTempRadius5); if(id == 6)  return(simLocTempRadius6);  if(id == 7)  return(simLocTempRadius7);  if(id == 8)  return(simLocTempRadius8);
	if(id == 9) return(simLocTempRadius9); if(id == 10) return(simLocTempRadius10); if(id == 11) return(simLocTempRadius11); if(id == 12) return(simLocTempRadius12);
	return(NINF);
}

void setSimLocTempRadius(int id = 0, float val = NINF) {
	if(id == 1) simLocTempRadius1 = val; if(id == 2)  simLocTempRadius2  = val; if(id == 3)  simLocTempRadius3  = val; if(id == 4)  simLocTempRadius4  = val;
	if(id == 5) simLocTempRadius5 = val; if(id == 6)  simLocTempRadius6  = val; if(id == 7)  simLocTempRadius7  = val; if(id == 8)  simLocTempRadius8  = val;
	if(id == 9) simLocTempRadius9 = val; if(id == 10) simLocTempRadius10 = val; if(id == 11) simLocTempRadius11 = val; if(id == 12) simLocTempRadius12 = val;
}

/*
** Cleans the temporary values.
** HAS to be called before starting a new iteration for a similar location ID as functions may expect unset values to be NINF.
*/
void resetSimLocTempVals() {
	simLocTempAngle1 = NINF; simLocTempAngle2  = NINF; simLocTempAngle3  = NINF; simLocTempAngle4  = NINF;
	simLocTempAngle5 = NINF; simLocTempAngle6  = NINF; simLocTempAngle7  = NINF; simLocTempAngle8  = NINF;
	simLocTempAngle9 = NINF; simLocTempAngle10 = NINF; simLocTempAngle11 = NINF; simLocTempAngle12 = NINF;

	simLocTempRadius1 = NINF; simLocTempRadius2  = NINF; simLocTempRadius3  = NINF; simLocTempRadius4  = NINF;
	simLocTempRadius5 = NINF; simLocTempRadius6  = NINF; simLocTempRadius7  = NINF; simLocTempRadius8  = NINF;
	simLocTempRadius9 = NINF; simLocTempRadius10 = NINF; simLocTempRadius11 = NINF; simLocTempRadius12 = NINF;
}

/*************
* GENERATION *
*************/

/*
** Performs an additional check that leads to very balanced placement in 1v1 situations.
** This check essentially calculates the ratio of the players' distance to the similar location of the respective other player.
** The fraction has to be smaller than twoPlayerTol to succeed, i.e., less than a certain percentage (0.125 -> difference in distance is less than 12.5%).
**
** @param simLocID: the location ID of the similar location to check
**
** @returns: true if the check succeeded, false otherwise
*/
bool performSimLocTwoPlayerCheck(int simLocID = -1) {
	if(cNonGaiaPlayers != 2) {
		return(true);
	}

	float twoPlayerTol = getSimLocTwoPlayerTol(simLocID);

	if(twoPlayerTol < 0.0) { // Not set.
		return(true);
	}

	// Get the distance in meters between p1 and the similar loc of p2 and the other way around.
	float distP1 = pointsGetDist(rmXFractionToMeters(getPlayerLocXFraction(1)), rmZFractionToMeters(getPlayerLocZFraction(1)),
								 rmXFractionToMeters(getSimLocX(simLocID, 2)), rmZFractionToMeters(getSimLocZ(simLocID, 2)));

	float distP2 = pointsGetDist(rmXFractionToMeters(getPlayerLocXFraction(2)), rmZFractionToMeters(getPlayerLocZFraction(2)),
								 rmXFractionToMeters(getSimLocX(simLocID, 1)), rmZFractionToMeters(getSimLocZ(simLocID, 1)));

	// Divide the smaller distance by the larger to get the fraction.
	if(distP1 < distP2) {
		if(1.0 - distP1 / distP2 > twoPlayerTol) {
			return(false);
		}
	} else {
		if(1.0 - distP2 / distP1 > twoPlayerTol) {
			return(false);
		}
	}

	return(true);
}

/*
** Randomizes a similar location angle according to the specified ranges.
**
** @param simLocID: the ID of the similar location to randomize an angle for
**
** @returns: the randomized angle
*/
float randSimLocAngle(int simLocID = -1) {
	float rangeFrom = getSimLocBiasRangeFrom(simLocID);
	float rangeTo = getSimLocBiasRangeTo(simLocID);

	if(rangeFrom == NINF || rangeTo == NINF) {
		return(randRadian()); // Unset bias, randomize from full range.
	}

	return(rmRandFloat(rangeFrom, rangeTo) * PI);
}

/*
** Randomizes a similar location radius according to the specified ranges.
**
** @param simLocID: the ID of the similar location to randomize a radius for
**
** @returns: the randomized radius
*/
float randSimLocRadius(int simLocID = -1) {
	return(rmRandFloat(getSimLocMinDist(simLocID), getSimLocMaxDist(simLocID)));
}

/*
** Randomizes an angle for a similar location for a player.
**
** @param simLocID: the ID of the similar location
** @param player: the player
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: the randomized angle
*/
float findSimLocAngleForPlayer(int simLocID = -1, int player = 0, float tol = 0.0) {
	float angle = getSimLocTempAngle(player);
	float segment = getSimLocAngleSegSize(simLocID); // Segment used to extend both sides (effectively forming an angle of 2 * segment * PI).
	float rangeFrom = getSimLocBiasRangeFrom(simLocID);
	float rangeTo = getSimLocBiasRangeTo(simLocID);

	// Adjust ranges based on segment and the received angle.
	rangeFrom = max(angle - segment * PI, rangeFrom * PI);
	rangeTo = min(angle + segment * PI, rangeTo * PI);

	float tolAdjust = (PI - (rangeTo - rangeFrom)) * tol;

	// Randomize from a segment around the given angle.
	// angle = randFromIntervals(rangeFrom - tolAdjust, rangeTo + tolAdjust, 2.0 * PI - rangeTo - tolAdjust, 2.0 * PI - rangeFrom + tolAdjust);
	angle = randFromIntervals(max(rangeFrom - tolAdjust, 0.0), min(rangeTo + tolAdjust, PI),
							  max(2.0 * PI - rangeTo - tolAdjust, PI), min(2.0 * PI - rangeFrom + tolAdjust, 2.0 * PI));
	angle = angle + getPlayerTeamOffsetAngle(player);

	return(angle);
}

/*
** Randomizes a radius for a similar location for a player.
**
** @param simLocID: the ID of the similar location
** @param player: the player
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: the randomized radius
*/
float findSimLocRadiusForPlayer(int simLocID = -1, int player = 0, float tol = 0.0) {
	// Randomize from an interval around the given radius.
	float radius = getSimLocTempRadius(player);
	float interval = 0.5 * getSimLocRadiusInterval(simLocID); // Half of the interval since we apply it to both ends of the range.

	// TODO Consider scaling the interval here via increasing tol.

	radius = randRadiusFromInterval(max(radius - interval, getSimLocMinDist(simLocID)), min(radius + interval, getSimLocMaxDist(simLocID)));

	return(radius);
}

/*
** Checks if a similar location with a radius and angle is valid (within map coordinates) and sets the values for the player.
** Also sets the x/z values for the mirrored player if mirroring is enabled.
**
** @param simLocID: the ID of the similar location
** @param player: the player
** @param radius: the radius to use for the location
** @param angle: the angle in radians to use
**
** @returns: true if a valid location was obtained, false otherwise
*/
bool checkAndSetSimLoc(int simLocID = -1, int player = 0, float radius = 0.0, float angle = 0.0) {
	float x = getXFromPolarForPlayer(player, radius, angle, getSimLocIsSquare(simLocID));
	float z = getZFromPolarForPlayer(player, radius, angle, getSimLocIsSquare(simLocID));

	if(isLocValid(x, z, rmXMetersToFraction(getSimLocDistX(simLocID)), rmZMetersToFraction(getSimLocDistZ(simLocID))) == false) {
		return(false);
	}

	setSimLocXZ(simLocID, player, x, z);

	// Also set mirrored coordinates if necessary.
	if(isMirrorOnAndValidConfig()) {
		player = getMirroredPlayer(player);

		if(getMirrorMode() != cMirrorPoint) {
			angle = 0.0 - angle;
		}

		x = getXFromPolarForPlayer(player, radius, angle, getSimLocIsSquare(simLocID));
		z = getZFromPolarForPlayer(player, radius, angle, getSimLocIsSquare(simLocID));

		setSimLocXZ(simLocID, player, x, z);
	}

	return(true);
}

/*
** Compares two similar locations and evaluates their validity according to the specified constraints.
**
** The following constraints are checked:
** 1. simLocInterDistMin (if specified): minimum distance similar locations of a player have to be apart from each other.
**    If not set, the cross distance is used as value (in the cross distance check as this is always performed).
**
** 2. simLocInterDistMax (if specified): maximum distance similar locations of a player can be apart from each other.
**
** 3. simLocAreaDist: minimum distance similar locations with the same similar location ID have to be apart from each other.
**
** 4. simLocMinCrossDist: minimum distance all specified similar locations have to be apart from each other.
**    This corresponds to the minimum areaDist value set when using addSimLoc().
**
** @param simLocID1: simLocID of the first similar location
** @param player1: player owning the first similar location
** @param simLocID2: simLocID of the second similar location
** @param player2: player owning the second similar location
**
** @returns: true if the comparison succeeded, false otherwise
*/
bool compareSimLocs(int simLocID1 = -1, int player1 = 0, int simLocID2 = -1, int player2 = 0) {
	float dist = pointsGetDist(rmXFractionToMeters(getSimLocX(simLocID1, player1)), rmZFractionToMeters(getSimLocZ(simLocID1, player1)),
							   rmXFractionToMeters(getSimLocX(simLocID2, player2)), rmZFractionToMeters(getSimLocZ(simLocID2, player2)));

	// Calculate similar loc inter distance (distance among similar locs of a player).
	if(player1 == player2) {
		if(dist < simLocInterDistMin) {
			return(false);
		}

		if(dist > simLocInterDistMax) {
			return(false);
		}
	}

	// Calculate similar loc intra distance (compare similar loc to the same similar loc of the other players).
	if(simLocID1 == simLocID2 && dist < getSimLocAreaDist(simLocID1)) {
		return(false);
	}

	// Calculate similar loc cross distance.
	if(dist < simLocMinCrossDist) {
		return(false);
	}

	return(true);
}

/*
** Performs checks to ensure that a similar location adheres to the specified settings (distance settings, NOT area constraints!).
** The check involves comparing the current similar location to be placed against all other similar locations that were previously placed.
**
** @param simLocID: the similar location ID of the location to check
** @param player: the player owning the similar location
**
** @returns: true if the check succeeded, false otherwise
*/
bool checkSimLoc(int simLocID = -1, int player = 0) {
	// Iterate over similar locs.
	for(s = 1; <= simLocID) {

		// Iterate over players.
		for(i = 1; < cPlayers) {
			// Map player to loc player array.
			int p = getSimLocPlayer(s, i);

			if(s == simLocID && p == player) {
				// Terminate early if we made it this far, skip remaining player for last simLoc as they have not had their simLoc placed yet.
				return(true);
			}

			if(compareSimLocs(simLocID, player, s, p) == false) {
				return(false);
			}
		}

	}
}

/*
** Attempts to build a previously placed similar location with respect to the constraints.
** Also adds player area and team area constraints if specified.
**
** @param simLocID: the ID of the similar location
** @param player: the player
**
** @returns: true if the area was successfully built, false otherwise
*/
bool buildSimLoc(int simLocID = -1, int player = 0) {
	// Define areas, apply constraints and try to place.
	int areaID = rmCreateArea(cSimLocName + " " + simLocNameCounter);

	rmSetAreaLocation(areaID, getSimLocX(simLocID, player), getSimLocZ(simLocID, player));

	rmSetAreaSize(areaID, rmXMetersToFraction(0.1));
	//rmSetAreaTerrainType(areaID, "HadesBuildable1");
	//rmSetAreaBaseHeight(areaID, 10.0);
	rmSetAreaCoherence(areaID, 1.0);
	rmSetAreaWarnFailure(areaID, false);

	simLocNameCounter++;

	// Add all defined constraints.
	for(j = 1; <= getSimLocConstraintCount(simLocID)) {
		rmAddAreaConstraint(areaID, getSimLocConstraint(simLocID, j));
	}

	// Add player area constraint if enabled.
	if(getSimLocInPlayerArea(simLocID)) {
		rmAddAreaConstraint(areaID, getPlayerAreaConstraint(player));
	}

	// Add team area constraint if enabled.
	if(getSimLocInTeamArea(simLocID)) {
		rmAddAreaConstraint(areaID, getTeamAreaConstraint(player));
	}

	return(rmBuildArea(areaID));
}

/*
** Single attempt to create a similar location.
**
** @param simLocID: the location ID of the similar location
** @param player: the player owning the similar location
** @param tol: tolerance for the angle; larger tolerance means that the angle may not lie within the original section anymore
**
** @returns: true upon success, false otherwise
*/
bool createSimLocForPlayer(int simLocID = -1, int player = 0, float tol = 0.0) {
	float angle = findSimLocAngleForPlayer(simLocID, player, tol);
	float radius = findSimLocRadiusForPlayer(simLocID, player, tol);

	if(checkAndSetSimLoc(simLocID, player, radius, angle) == false) {
		return(false);
	}

	// This is probably not necessary because the next check also considers the location placed for getMirroredPlayer(player).
	// if(isMirrorOnAndValidConfig()) {
		// if(checkSimLoc(simLocID, getMirroredPlayer(player)) == false) {
			// return(false)
		// }
	// }

	if(checkSimLoc(simLocID, player) == false) {
		return(false);
	}

	if(isMirrorOnAndValidConfig()) {
		if(buildSimLoc(simLocID, getMirroredPlayer(player)) == false) {
			return(false);
		}
	}

	return(buildSimLoc(simLocID, player));
}

/*
** Tries to create a valid similar location for a player according to the parameters specified by addSimLoc().
** The algorithm tries to find a valid location for a given number of times.
**
** @param simLocID: the location ID of the similar location
** @param player: the player owning the similar location
** @param maxIter: the number of attempts to find the location
**
** @returns: the number of iterations that were required to find a location; -1 indicates failure
*/
int createSimLocFromParams(int simLocID = -1, int player = 0, int maxIter = 100) {
	float tol = 0.0;
	int localIter = 0;
	int failCount = 0;

	while(localIter < maxIter) {
		// Increase tolerance upon failing several times.
		if(failCount >= 5) {
			failCount = 0;
			tol = min(tol + 0.05, 1.0); // Make sure we don't exceed 100% tolerance.
		}

		localIter++;

		// Try to find valid location.
		if(createSimLocForPlayer(simLocID, player, tol)) {
			return(localIter);
		}

		failCount++;
	}

	// -1 = failed to find a location within maxIter iterations, caller can decide what to do with this value.
	return(-1);
}

/*
** Sets the temporary angle/radius to use for the current pair of players.
**
** @param simLocID: the location ID of the similar location
** @param player: the player owning the similar location
*/
void setSimLocTempParams(int simLocID = -1, int player = 0) {
	// Determine opposing player to see if we already set an angle/radius for either of the current pair of players.
	int op = getMirroredPlayer(player);

	// Adjust angle and radius depending on setup.
	if(isMirrorOnAndValidConfig() || gameHasTwoEqualTeams() == false || getSimLocTempAngle(op) == NINF) {
		// Create new angle/radius.
		setSimLocTempAngle(player, randSimLocAngle(simLocID));
		setSimLocTempRadius(player, randSimLocRadius(simLocID));
	} else {
		// Load stored angle/radius from mirrored/opposing player.
		setSimLocTempAngle(player, getSimLocTempAngle(op));
		setSimLocTempRadius(player, getSimLocTempRadius(op));
	}
}

/*
** Runs the similar location placement algorithm.
** If a mirror mode is set, the created similar locations will be mirrored.
**
** @param maxIter: the maximum number of iterations to run the algorithm for
** @param localMaxIter: the maximum attempts to find a similar location for every player before starting over
**
** @returns: true upon success, false otherwise
*/
bool runSimLocs(int maxIter = 5000, int localMaxIter = 100) {
	int currIter = 0;
	int numPlayers = cNonGaiaPlayers;
	bool done = false;

	// Adjust player number in case we mirror, place only first half.
	if(isMirrorOnAndValidConfig()) {
		numPlayers = getNumberPlayersOnTeam(0);
	}

	while(currIter < maxIter && done == false) {
		done = true;

		// Iterate over similar locations.
		for(s = 1; <= simLocCount) {
			resetSimLocTempVals(); // Reset values for current simLoc.

			// Iterate over players.
			for(i = 1; <= numPlayers) {
				int p = getSimLocPlayer(s, i);

				if(isMirrorOnAndValidConfig()) {
					p = getSimLocPlayer(s, (i - 1) * 2 + 1);
				}

				// Determine angle and radius to use for the current player.
				setSimLocTempParams(s, p);

				// Try to create a similar location.
				int numIter = createSimLocFromParams(s, p, localMaxIter);

				if(numIter < 0) { // Failed, increment currIter; could also penalize fails later in the algorithm harder.
					currIter = currIter + localMaxIter;
					done = false;
					break;
				}

				currIter = currIter + numIter;
			}

			if(done == false) {
				break;
			} else if(performSimLocTwoPlayerCheck(s) == false) {
				done = false;
				break;
			}
		}
	}

	if(done == false) {
		lastSimLocIters = -1;
		return(false);
	}

	lastSimLocIters = currIter;
	return(true);
}

/*
** Attempts to create similar locations according to the added definitions and chosen settings.
** Also considers mirroring if a mirror mode was set prior to the call.
**
** @param simLocLabel: the name of the similar location (only used for debugging purposes)
** @param isCrucial: whether the similar loc is crucial and players should be warned if it fails or not
** @param maxIter: the maximum number of iterations to run the algorithm for
** @param localMaxIter: the maximum attempts to find a similar location for every player before starting over
**
** @returns: true if the locations were successfully generated, false otherwise
*/
bool createSimLocs(string simLocLabel = "", bool isCrucial = true, int maxIter = 5000, int localMaxIter = 100) {
	// Initialize splits if not already done.
	initializePlayerAreaConstraints();
	initializeTeamAreaConstraints();

	bool success = runSimLocs(maxIter, localMaxIter);

	// Clear values if not debugging.
	if(success == false && cDebugMode < cDebugTest) {
		resetSimLocVals();
	}

	// Print message if debugging.
	string varSpace = " ";

	if(simLocLabel == "") {
		varSpace = "";
	}

	if(lastSimLocIters >= 0) {
		printDebug("simLoc" + varSpace + simLocLabel + " succeeded: i = " + lastSimLocIters, cDebugTest);
	}

	// Log result.
	addCustomCheck("simLoc" + varSpace + simLocLabel, isCrucial, success);

	return(success);
}

/*
** Creates (fake) areas on the similar locations and adds them to a class.
** Useful if you need to block similar areas, but do not want to place objects on them yet.
**
** @param classID: the ID of the class to add the similar locations to
** @param areaMeterRadius: the radius of the (invisible) area to create
** @param simLocID: the ID of the similar location to create the areas from; if defaulted to -1, all stored similar locations will have locations generated
*/
void simLocAreasToClass(int classID = -1, float areaMeterRadius = 5.0, int simLocID = -1) {
	int simLocStartID = 1;

	if(simLocID < 0) {
		simLocID = simLocCount;
	} else {
		simLocStartID = simLocID;
	}

	for(i = simLocStartID; <= simLocID) {
		for(j = 1; < cPlayers) {
			int simLocAreaID = rmCreateArea(cSimLocAreaName + " " + simLocAreaNameCounter + " " + i + " " + j);
			rmSetAreaLocation(simLocAreaID, getSimLocX(i, j), getSimLocZ(i, j));
			rmSetAreaSize(simLocAreaID, areaRadiusMetersToFraction(areaMeterRadius));
			rmSetAreaCoherence(simLocAreaID, 1.0);
			rmAddAreaToClass(simLocAreaID, classID);
		}
	}

	rmBuildAllAreas();

	simLocAreaNameCounter++;
}

/*
** Stores the current set of similar locations in the location storage.
*/
void storeSimLocs() {
	for(i = 1; <= simLocCount) {
		for(j = 1; < cPlayers) {
			forceAddLocToStorage(getSimLocX(i, j), getSimLocZ(i, j), j);
		}
	}
}

/*
** Adds all stored constraints to an object.
** Useful if you need to apply the constraints to an already created object,
** for example, if you need to place the object normally instead of using sim locs due to the player number.
*/
void applySimLocConstraintsToObject(int objectID = -1, int simLocID = -1) {
	if(simLocID < 0) {
		simLocID = simLocCount;
	}

	for(i = 1; <= getSimLocConstraintCount(simLocID)) {
		rmAddObjectDefConstraint(objectID, getSimLocConstraint(simLocID, i));
	}
}

/*
** Shape generation.
** RebelsRising
** Last edit: 07/03/2021
**
** This implementation is based on a data structure described as below and adjusted from an implementation of SlySherZ.
**
** I'm using a different approach for blob placement and to map the blob grid to the actual map.
** Furthermore, data access methods are adjusted to fit the approach I'm taking for forest generation (see areas.xs)
** to achieve irregular (yet mirrored) forest placement with good variance.
**
** The core principle is to start with a single (center) area, then expand slowly and randomly to areas adjacent to this center area.
** To do so, consider all areas around already chosen areas as possible attachment points.
** Due to non-continuity, this only allows to consider areas in a square or a cross around a given area, e.g.:
**
** - - -
** - + -
** - - -
**
** To do this, we maintain two lists of states (near and full). Full blobs are blobs that are used for placement,
** where as near blobs are in consideration for the next possible blob to be placed.
** The lists can be searched and elements can be deleted (where the last element is copied on to the position
** of the element to be deleted).
**
** After making the center '+' of the upper example a full blob, we get:
**
** - - - - -
** - + + + -           x = full blob
** - + x + -   where   + = near blob
** - + + + -           - = empty blob
** - - - - -
*/

// include "rmx_sim_locs.xs";

/************
* CONSTANTS *
************/

extern const int cBlobInvalid = -1;
extern const int cBlobEmpty = 0;
extern const int cBlobNear = 1;
extern const int cBlobFull = 2;

const int cFirstState = 1;
const int cTotalStates = 2;

/***************
* BLOB REMOVAL *
***************/

/*
 * Although not used in this file, this array is declared here to be used in combination with the shape generator.
 *
 * The idea is to place a shape and then build fake areas one by one. This allows to determine how many of the blobs were actually built.
 * Based on this, you can specify a minimum percentage (or number) of blobs that must be built successfully for a shape to be actually placed.
 *
 * This should greatly improve the quality of areas generated (check "forests.xs" for an example of this technique).
*/

int blobForRemoval0  = 0; int blobForRemoval1  = 0; int blobForRemoval2  = 0; int blobForRemoval3  = 0;
int blobForRemoval4  = 0; int blobForRemoval5  = 0; int blobForRemoval6  = 0; int blobForRemoval7  = 0;
int blobForRemoval8  = 0; int blobForRemoval9  = 0; int blobForRemoval10 = 0; int blobForRemoval11 = 0;
int blobForRemoval12 = 0; int blobForRemoval13 = 0; int blobForRemoval14 = 0; int blobForRemoval15 = 0;
int blobForRemoval16 = 0; int blobForRemoval17 = 0; int blobForRemoval18 = 0; int blobForRemoval19 = 0;
int blobForRemoval20 = 0; int blobForRemoval21 = 0; int blobForRemoval22 = 0; int blobForRemoval23 = 0;
int blobForRemoval24 = 0; int blobForRemoval25 = 0; int blobForRemoval26 = 0; int blobForRemoval27 = 0;
int blobForRemoval28 = 0; int blobForRemoval29 = 0; int blobForRemoval30 = 0; int blobForRemoval31 = 0;
int blobForRemoval32 = 0; int blobForRemoval33 = 0; int blobForRemoval34 = 0; int blobForRemoval35 = 0;
int blobForRemoval36 = 0; int blobForRemoval37 = 0; int blobForRemoval38 = 0; int blobForRemoval39 = 0;
int blobForRemoval40 = 0; int blobForRemoval41 = 0; int blobForRemoval42 = 0; int blobForRemoval43 = 0;
int blobForRemoval44 = 0; int blobForRemoval45 = 0; int blobForRemoval46 = 0; int blobForRemoval47 = 0;
int blobForRemoval48 = 0; int blobForRemoval49 = 0; int blobForRemoval50 = 0; int blobForRemoval51 = 0;
int blobForRemoval52 = 0; int blobForRemoval53 = 0; int blobForRemoval54 = 0; int blobForRemoval55 = 0;
int blobForRemoval56 = 0; int blobForRemoval57 = 0; int blobForRemoval58 = 0; int blobForRemoval59 = 0;
int blobForRemoval60 = 0; int blobForRemoval61 = 0; int blobForRemoval62 = 0; int blobForRemoval63 = 0;

int getBlobForRemoval(int i = -1) {
	if(i == 0)  return(blobForRemoval0);  if(i == 1)  return(blobForRemoval1);  if(i == 2)  return(blobForRemoval2);  if(i == 3)  return(blobForRemoval3);
	if(i == 4)  return(blobForRemoval4);  if(i == 5)  return(blobForRemoval5);  if(i == 6)  return(blobForRemoval6);  if(i == 7)  return(blobForRemoval7);
	if(i == 8)  return(blobForRemoval8);  if(i == 9)  return(blobForRemoval9);  if(i == 10) return(blobForRemoval10); if(i == 11) return(blobForRemoval11);
	if(i == 12) return(blobForRemoval12); if(i == 13) return(blobForRemoval13); if(i == 14) return(blobForRemoval14); if(i == 15) return(blobForRemoval15);
	if(i == 16) return(blobForRemoval16); if(i == 17) return(blobForRemoval17); if(i == 18) return(blobForRemoval18); if(i == 19) return(blobForRemoval19);
	if(i == 20) return(blobForRemoval20); if(i == 21) return(blobForRemoval21); if(i == 22) return(blobForRemoval22); if(i == 23) return(blobForRemoval23);
	if(i == 24) return(blobForRemoval24); if(i == 25) return(blobForRemoval25); if(i == 26) return(blobForRemoval26); if(i == 27) return(blobForRemoval27);
	if(i == 28) return(blobForRemoval28); if(i == 29) return(blobForRemoval29); if(i == 30) return(blobForRemoval30); if(i == 31) return(blobForRemoval31);
	if(i == 32) return(blobForRemoval32); if(i == 33) return(blobForRemoval33); if(i == 34) return(blobForRemoval34); if(i == 35) return(blobForRemoval35);
	if(i == 36) return(blobForRemoval36); if(i == 37) return(blobForRemoval37); if(i == 38) return(blobForRemoval38); if(i == 39) return(blobForRemoval39);
	if(i == 40) return(blobForRemoval40); if(i == 41) return(blobForRemoval41); if(i == 42) return(blobForRemoval42); if(i == 43) return(blobForRemoval43);
	if(i == 44) return(blobForRemoval44); if(i == 45) return(blobForRemoval45); if(i == 46) return(blobForRemoval46); if(i == 47) return(blobForRemoval47);
	if(i == 48) return(blobForRemoval48); if(i == 49) return(blobForRemoval49); if(i == 50) return(blobForRemoval50); if(i == 51) return(blobForRemoval51);
	if(i == 52) return(blobForRemoval52); if(i == 53) return(blobForRemoval53); if(i == 54) return(blobForRemoval54); if(i == 55) return(blobForRemoval55);
	if(i == 56) return(blobForRemoval56); if(i == 57) return(blobForRemoval57); if(i == 58) return(blobForRemoval58); if(i == 59) return(blobForRemoval59);
	if(i == 60) return(blobForRemoval60); if(i == 61) return(blobForRemoval61); if(i == 62) return(blobForRemoval62); if(i == 63) return(blobForRemoval63);
	return(0);
}

int setBlobForRemoval(int i = -1, int blobID = 0) {
	if(i == 0)  blobForRemoval0  = blobID; if(i == 1)  blobForRemoval1  = blobID; if(i == 2)  blobForRemoval2  = blobID; if(i == 3)  blobForRemoval3  = blobID;
	if(i == 4)  blobForRemoval4  = blobID; if(i == 5)  blobForRemoval5  = blobID; if(i == 6)  blobForRemoval6  = blobID; if(i == 7)  blobForRemoval7  = blobID;
	if(i == 8)  blobForRemoval8  = blobID; if(i == 9)  blobForRemoval9  = blobID; if(i == 10) blobForRemoval10 = blobID; if(i == 11) blobForRemoval11 = blobID;
	if(i == 12) blobForRemoval12 = blobID; if(i == 13) blobForRemoval13 = blobID; if(i == 14) blobForRemoval14 = blobID; if(i == 15) blobForRemoval15 = blobID;
	if(i == 16) blobForRemoval16 = blobID; if(i == 17) blobForRemoval17 = blobID; if(i == 18) blobForRemoval18 = blobID; if(i == 19) blobForRemoval19 = blobID;
	if(i == 20) blobForRemoval20 = blobID; if(i == 21) blobForRemoval21 = blobID; if(i == 22) blobForRemoval22 = blobID; if(i == 23) blobForRemoval23 = blobID;
	if(i == 24) blobForRemoval24 = blobID; if(i == 25) blobForRemoval25 = blobID; if(i == 26) blobForRemoval26 = blobID; if(i == 27) blobForRemoval27 = blobID;
	if(i == 28) blobForRemoval28 = blobID; if(i == 29) blobForRemoval29 = blobID; if(i == 30) blobForRemoval30 = blobID; if(i == 31) blobForRemoval31 = blobID;
	if(i == 32) blobForRemoval32 = blobID; if(i == 33) blobForRemoval33 = blobID; if(i == 34) blobForRemoval34 = blobID; if(i == 35) blobForRemoval35 = blobID;
	if(i == 36) blobForRemoval36 = blobID; if(i == 37) blobForRemoval37 = blobID; if(i == 38) blobForRemoval38 = blobID; if(i == 39) blobForRemoval39 = blobID;
	if(i == 40) blobForRemoval40 = blobID; if(i == 41) blobForRemoval41 = blobID; if(i == 42) blobForRemoval42 = blobID; if(i == 43) blobForRemoval43 = blobID;
	if(i == 44) blobForRemoval44 = blobID; if(i == 45) blobForRemoval45 = blobID; if(i == 46) blobForRemoval46 = blobID; if(i == 47) blobForRemoval47 = blobID;
	if(i == 48) blobForRemoval48 = blobID; if(i == 49) blobForRemoval49 = blobID; if(i == 50) blobForRemoval50 = blobID; if(i == 51) blobForRemoval51 = blobID;
	if(i == 52) blobForRemoval52 = blobID; if(i == 53) blobForRemoval53 = blobID; if(i == 54) blobForRemoval54 = blobID; if(i == 55) blobForRemoval55 = blobID;
	if(i == 56) blobForRemoval56 = blobID; if(i == 57) blobForRemoval57 = blobID; if(i == 58) blobForRemoval58 = blobID; if(i == 59) blobForRemoval59 = blobID;
	if(i == 60) blobForRemoval60 = blobID; if(i == 61) blobForRemoval61 = blobID; if(i == 62) blobForRemoval62 = blobID; if(i == 63) blobForRemoval63 = blobID;
}

/*************
* FULL BLOBS *
*************/

int fullBlobsCount = 0;

int fullBlobX0  = 0; int fullBlobX1  = 0; int fullBlobX2  = 0; int fullBlobX3  = 0;
int fullBlobX4  = 0; int fullBlobX5  = 0; int fullBlobX6  = 0; int fullBlobX7  = 0;
int fullBlobX8  = 0; int fullBlobX9  = 0; int fullBlobX10 = 0; int fullBlobX11 = 0;
int fullBlobX12 = 0; int fullBlobX13 = 0; int fullBlobX14 = 0; int fullBlobX15 = 0;
int fullBlobX16 = 0; int fullBlobX17 = 0; int fullBlobX18 = 0; int fullBlobX19 = 0;
int fullBlobX20 = 0; int fullBlobX21 = 0; int fullBlobX22 = 0; int fullBlobX23 = 0;
int fullBlobX24 = 0; int fullBlobX25 = 0; int fullBlobX26 = 0; int fullBlobX27 = 0;
int fullBlobX28 = 0; int fullBlobX29 = 0; int fullBlobX30 = 0; int fullBlobX31 = 0;
int fullBlobX32 = 0; int fullBlobX33 = 0; int fullBlobX34 = 0; int fullBlobX35 = 0;
int fullBlobX36 = 0; int fullBlobX37 = 0; int fullBlobX38 = 0; int fullBlobX39 = 0;
int fullBlobX40 = 0; int fullBlobX41 = 0; int fullBlobX42 = 0; int fullBlobX43 = 0;
int fullBlobX44 = 0; int fullBlobX45 = 0; int fullBlobX46 = 0; int fullBlobX47 = 0;
int fullBlobX48 = 0; int fullBlobX49 = 0; int fullBlobX50 = 0; int fullBlobX51 = 0;
int fullBlobX52 = 0; int fullBlobX53 = 0; int fullBlobX54 = 0; int fullBlobX55 = 0;
int fullBlobX56 = 0; int fullBlobX57 = 0; int fullBlobX58 = 0; int fullBlobX59 = 0;
int fullBlobX60 = 0; int fullBlobX61 = 0; int fullBlobX62 = 0; int fullBlobX63 = 0;

int fullBlobZ0  = 0; int fullBlobZ1  = 0; int fullBlobZ2  = 0; int fullBlobZ3  = 0;
int fullBlobZ4  = 0; int fullBlobZ5  = 0; int fullBlobZ6  = 0; int fullBlobZ7  = 0;
int fullBlobZ8  = 0; int fullBlobZ9  = 0; int fullBlobZ10 = 0; int fullBlobZ11 = 0;
int fullBlobZ12 = 0; int fullBlobZ13 = 0; int fullBlobZ14 = 0; int fullBlobZ15 = 0;
int fullBlobZ16 = 0; int fullBlobZ17 = 0; int fullBlobZ18 = 0; int fullBlobZ19 = 0;
int fullBlobZ20 = 0; int fullBlobZ21 = 0; int fullBlobZ22 = 0; int fullBlobZ23 = 0;
int fullBlobZ24 = 0; int fullBlobZ25 = 0; int fullBlobZ26 = 0; int fullBlobZ27 = 0;
int fullBlobZ28 = 0; int fullBlobZ29 = 0; int fullBlobZ30 = 0; int fullBlobZ31 = 0;
int fullBlobZ32 = 0; int fullBlobZ33 = 0; int fullBlobZ34 = 0; int fullBlobZ35 = 0;
int fullBlobZ36 = 0; int fullBlobZ37 = 0; int fullBlobZ38 = 0; int fullBlobZ39 = 0;
int fullBlobZ40 = 0; int fullBlobZ41 = 0; int fullBlobZ42 = 0; int fullBlobZ43 = 0;
int fullBlobZ44 = 0; int fullBlobZ45 = 0; int fullBlobZ46 = 0; int fullBlobZ47 = 0;
int fullBlobZ48 = 0; int fullBlobZ49 = 0; int fullBlobZ50 = 0; int fullBlobZ51 = 0;
int fullBlobZ52 = 0; int fullBlobZ53 = 0; int fullBlobZ54 = 0; int fullBlobZ55 = 0;
int fullBlobZ56 = 0; int fullBlobZ57 = 0; int fullBlobZ58 = 0; int fullBlobZ59 = 0;
int fullBlobZ60 = 0; int fullBlobZ61 = 0; int fullBlobZ62 = 0; int fullBlobZ63 = 0;

/*
** Adds a blob to the list of full blobs.
** The ID parameter should not be set unless you keep track of which blobs are set (note how fullBlobsCount is only incremented on id == -1).
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
** @param id: ID of the blob to be added
*/
void setFullBlob(int x = -1, int z = -1, int id = -1) {
	if(id == -1) {
		// If the ID is not specified, set state for next free blob.
		id = fullBlobsCount;

		// Since we don't overwrite an existing blob, increase the number of full blobs.
		fullBlobsCount++;
	}

	if(id == 0)  { fullBlobX0  = x; fullBlobZ0  = z; return; } if(id == 1)  { fullBlobX1  = x; fullBlobZ1  = z; return; }
	if(id == 2)  { fullBlobX2  = x; fullBlobZ2  = z; return; } if(id == 3)  { fullBlobX3  = x; fullBlobZ3  = z; return; }
	if(id == 4)  { fullBlobX4  = x; fullBlobZ4  = z; return; } if(id == 5)  { fullBlobX5  = x; fullBlobZ5  = z; return; }
	if(id == 6)  { fullBlobX6  = x; fullBlobZ6  = z; return; } if(id == 7)  { fullBlobX7  = x; fullBlobZ7  = z; return; }
	if(id == 8)  { fullBlobX8  = x; fullBlobZ8  = z; return; } if(id == 9)  { fullBlobX9  = x; fullBlobZ9  = z; return; }
	if(id == 10) { fullBlobX10 = x; fullBlobZ10 = z; return; } if(id == 11) { fullBlobX11 = x; fullBlobZ11 = z; return; }
	if(id == 12) { fullBlobX12 = x; fullBlobZ12 = z; return; } if(id == 13) { fullBlobX13 = x; fullBlobZ13 = z; return; }
	if(id == 14) { fullBlobX14 = x; fullBlobZ14 = z; return; } if(id == 15) { fullBlobX15 = x; fullBlobZ15 = z; return; }
	if(id == 16) { fullBlobX16 = x; fullBlobZ16 = z; return; } if(id == 17) { fullBlobX17 = x; fullBlobZ17 = z; return; }
	if(id == 18) { fullBlobX18 = x; fullBlobZ18 = z; return; } if(id == 19) { fullBlobX19 = x; fullBlobZ19 = z; return; }
	if(id == 20) { fullBlobX20 = x; fullBlobZ20 = z; return; } if(id == 21) { fullBlobX21 = x; fullBlobZ21 = z; return; }
	if(id == 22) { fullBlobX22 = x; fullBlobZ22 = z; return; } if(id == 23) { fullBlobX23 = x; fullBlobZ23 = z; return; }
	if(id == 24) { fullBlobX24 = x; fullBlobZ24 = z; return; } if(id == 25) { fullBlobX25 = x; fullBlobZ25 = z; return; }
	if(id == 26) { fullBlobX26 = x; fullBlobZ26 = z; return; } if(id == 27) { fullBlobX27 = x; fullBlobZ27 = z; return; }
	if(id == 28) { fullBlobX28 = x; fullBlobZ28 = z; return; } if(id == 29) { fullBlobX29 = x; fullBlobZ29 = z; return; }
	if(id == 30) { fullBlobX30 = x; fullBlobZ30 = z; return; } if(id == 31) { fullBlobX31 = x; fullBlobZ31 = z; return; }
	if(id == 32) { fullBlobX32 = x; fullBlobZ32 = z; return; } if(id == 33) { fullBlobX33 = x; fullBlobZ33 = z; return; }
	if(id == 34) { fullBlobX34 = x; fullBlobZ34 = z; return; } if(id == 35) { fullBlobX35 = x; fullBlobZ35 = z; return; }
	if(id == 36) { fullBlobX36 = x; fullBlobZ36 = z; return; } if(id == 37) { fullBlobX37 = x; fullBlobZ37 = z; return; }
	if(id == 38) { fullBlobX38 = x; fullBlobZ38 = z; return; } if(id == 39) { fullBlobX39 = x; fullBlobZ39 = z; return; }
	if(id == 40) { fullBlobX40 = x; fullBlobZ40 = z; return; } if(id == 41) { fullBlobX41 = x; fullBlobZ41 = z; return; }
	if(id == 42) { fullBlobX42 = x; fullBlobZ42 = z; return; } if(id == 43) { fullBlobX43 = x; fullBlobZ43 = z; return; }
	if(id == 44) { fullBlobX44 = x; fullBlobZ44 = z; return; } if(id == 45) { fullBlobX45 = x; fullBlobZ45 = z; return; }
	if(id == 46) { fullBlobX46 = x; fullBlobZ46 = z; return; } if(id == 47) { fullBlobX47 = x; fullBlobZ47 = z; return; }
	if(id == 48) { fullBlobX48 = x; fullBlobZ48 = z; return; } if(id == 49) { fullBlobX49 = x; fullBlobZ49 = z; return; }
	if(id == 50) { fullBlobX50 = x; fullBlobZ50 = z; return; } if(id == 51) { fullBlobX51 = x; fullBlobZ51 = z; return; }
	if(id == 52) { fullBlobX52 = x; fullBlobZ52 = z; return; } if(id == 53) { fullBlobX53 = x; fullBlobZ53 = z; return; }
	if(id == 54) { fullBlobX54 = x; fullBlobZ54 = z; return; } if(id == 55) { fullBlobX55 = x; fullBlobZ55 = z; return; }
	if(id == 56) { fullBlobX56 = x; fullBlobZ56 = z; return; } if(id == 57) { fullBlobX57 = x; fullBlobZ57 = z; return; }
	if(id == 58) { fullBlobX58 = x; fullBlobZ58 = z; return; } if(id == 59) { fullBlobX59 = x; fullBlobZ59 = z; return; }
	if(id == 60) { fullBlobX60 = x; fullBlobZ60 = z; return; } if(id == 61) { fullBlobX61 = x; fullBlobZ61 = z; return; }
	if(id == 62) { fullBlobX62 = x; fullBlobZ62 = z; return; } if(id == 63) { fullBlobX63 = x; fullBlobZ63 = z; return; }
}

/*
** Gets the x coordinate of a blob in the list of full blobs.
**
** @param id: ID of the blob
**
** @returns: the x coordinate of the blob
*/
int getFullBlobX(int id = -1) {
	if(id == 0)  return(fullBlobX0);  if(id == 1)  return(fullBlobX1);  if(id == 2)  return(fullBlobX2);  if(id == 3)  return(fullBlobX3);
	if(id == 4)  return(fullBlobX4);  if(id == 5)  return(fullBlobX5);  if(id == 6)  return(fullBlobX6);  if(id == 7)  return(fullBlobX7);
	if(id == 8)  return(fullBlobX8);  if(id == 9)  return(fullBlobX9);  if(id == 10) return(fullBlobX10); if(id == 11) return(fullBlobX11);
	if(id == 12) return(fullBlobX12); if(id == 13) return(fullBlobX13); if(id == 14) return(fullBlobX14); if(id == 15) return(fullBlobX15);
	if(id == 16) return(fullBlobX16); if(id == 17) return(fullBlobX17); if(id == 18) return(fullBlobX18); if(id == 19) return(fullBlobX19);
	if(id == 20) return(fullBlobX20); if(id == 21) return(fullBlobX21); if(id == 22) return(fullBlobX22); if(id == 23) return(fullBlobX23);
	if(id == 24) return(fullBlobX24); if(id == 25) return(fullBlobX25); if(id == 26) return(fullBlobX26); if(id == 27) return(fullBlobX27);
	if(id == 28) return(fullBlobX28); if(id == 29) return(fullBlobX29); if(id == 30) return(fullBlobX30); if(id == 31) return(fullBlobX31);
	if(id == 32) return(fullBlobX32); if(id == 33) return(fullBlobX33); if(id == 34) return(fullBlobX34); if(id == 35) return(fullBlobX35);
	if(id == 36) return(fullBlobX36); if(id == 37) return(fullBlobX37); if(id == 38) return(fullBlobX38); if(id == 39) return(fullBlobX39);
	if(id == 40) return(fullBlobX40); if(id == 41) return(fullBlobX41); if(id == 42) return(fullBlobX42); if(id == 43) return(fullBlobX43);
	if(id == 44) return(fullBlobX44); if(id == 45) return(fullBlobX45); if(id == 46) return(fullBlobX46); if(id == 47) return(fullBlobX47);
	if(id == 48) return(fullBlobX48); if(id == 49) return(fullBlobX49); if(id == 50) return(fullBlobX50); if(id == 51) return(fullBlobX51);
	if(id == 52) return(fullBlobX52); if(id == 53) return(fullBlobX53); if(id == 54) return(fullBlobX54); if(id == 55) return(fullBlobX55);
	if(id == 56) return(fullBlobX56); if(id == 57) return(fullBlobX57); if(id == 58) return(fullBlobX58); if(id == 59) return(fullBlobX59);
	if(id == 60) return(fullBlobX60); if(id == 61) return(fullBlobX61); if(id == 62) return(fullBlobX62); if(id == 63) return(fullBlobX63);

	return(0);
}

/*
** Gets the z coordinate of a blob in the list of full blobs.
**
** @param id: ID of the blob
**
** @returns: the z coordinate of the blob
*/
int getFullBlobZ(int id = -1) {
	if(id == 0)  return(fullBlobZ0);  if(id == 1)  return(fullBlobZ1);  if(id == 2)  return(fullBlobZ2);  if(id == 3)  return(fullBlobZ3);
	if(id == 4)  return(fullBlobZ4);  if(id == 5)  return(fullBlobZ5);  if(id == 6)  return(fullBlobZ6);  if(id == 7)  return(fullBlobZ7);
	if(id == 8)  return(fullBlobZ8);  if(id == 9)  return(fullBlobZ9);  if(id == 10) return(fullBlobZ10); if(id == 11) return(fullBlobZ11);
	if(id == 12) return(fullBlobZ12); if(id == 13) return(fullBlobZ13); if(id == 14) return(fullBlobZ14); if(id == 15) return(fullBlobZ15);
	if(id == 16) return(fullBlobZ16); if(id == 17) return(fullBlobZ17); if(id == 18) return(fullBlobZ18); if(id == 19) return(fullBlobZ19);
	if(id == 20) return(fullBlobZ20); if(id == 21) return(fullBlobZ21); if(id == 22) return(fullBlobZ22); if(id == 23) return(fullBlobZ23);
	if(id == 24) return(fullBlobZ24); if(id == 25) return(fullBlobZ25); if(id == 26) return(fullBlobZ26); if(id == 27) return(fullBlobZ27);
	if(id == 28) return(fullBlobZ28); if(id == 29) return(fullBlobZ29); if(id == 30) return(fullBlobZ30); if(id == 31) return(fullBlobZ31);
	if(id == 32) return(fullBlobZ32); if(id == 33) return(fullBlobZ33); if(id == 34) return(fullBlobZ34); if(id == 35) return(fullBlobZ35);
	if(id == 36) return(fullBlobZ36); if(id == 37) return(fullBlobZ37); if(id == 38) return(fullBlobZ38); if(id == 39) return(fullBlobZ39);
	if(id == 40) return(fullBlobZ40); if(id == 41) return(fullBlobZ41); if(id == 42) return(fullBlobZ42); if(id == 43) return(fullBlobZ43);
	if(id == 44) return(fullBlobZ44); if(id == 45) return(fullBlobZ45); if(id == 46) return(fullBlobZ46); if(id == 47) return(fullBlobZ47);
	if(id == 48) return(fullBlobZ48); if(id == 49) return(fullBlobZ49); if(id == 50) return(fullBlobZ50); if(id == 51) return(fullBlobZ51);
	if(id == 52) return(fullBlobZ52); if(id == 53) return(fullBlobZ53); if(id == 54) return(fullBlobZ54); if(id == 55) return(fullBlobZ55);
	if(id == 56) return(fullBlobZ56); if(id == 57) return(fullBlobZ57); if(id == 58) return(fullBlobZ58); if(id == 59) return(fullBlobZ59);
	if(id == 60) return(fullBlobZ60); if(id == 61) return(fullBlobZ61); if(id == 62) return(fullBlobZ62); if(id == 63) return(fullBlobZ63);

	return(0);
}

/*
** Searches the list of full blobs for the ID of a blob with given coordinates.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
**
** @returns: the ID of the blob
*/
int findFullBlob(int x = -1, int z = -1) {
	if(fullBlobX0  == x && fullBlobZ0  == z) return(0);  if(fullBlobX1  == x && fullBlobZ1 ==  z) return(1);
	if(fullBlobX2  == x && fullBlobZ2  == z) return(2);  if(fullBlobX3  == x && fullBlobZ3 ==  z) return(3);
	if(fullBlobX4  == x && fullBlobZ4  == z) return(4);  if(fullBlobX5  == x && fullBlobZ5 ==  z) return(5);
	if(fullBlobX6  == x && fullBlobZ6  == z) return(6);  if(fullBlobX7  == x && fullBlobZ7 ==  z) return(7);
	if(fullBlobX8  == x && fullBlobZ8  == z) return(8);  if(fullBlobX9  == x && fullBlobZ9 ==  z) return(9);
	if(fullBlobX10 == x && fullBlobZ10 == z) return(10); if(fullBlobX11 == x && fullBlobZ11 == z) return(11);
	if(fullBlobX12 == x && fullBlobZ12 == z) return(12); if(fullBlobX13 == x && fullBlobZ13 == z) return(13);
	if(fullBlobX14 == x && fullBlobZ14 == z) return(14); if(fullBlobX15 == x && fullBlobZ15 == z) return(15);
	if(fullBlobX16 == x && fullBlobZ16 == z) return(16); if(fullBlobX17 == x && fullBlobZ17 == z) return(17);
	if(fullBlobX18 == x && fullBlobZ18 == z) return(18); if(fullBlobX19 == x && fullBlobZ19 == z) return(19);
	if(fullBlobX20 == x && fullBlobZ20 == z) return(20); if(fullBlobX21 == x && fullBlobZ21 == z) return(21);
	if(fullBlobX22 == x && fullBlobZ22 == z) return(22); if(fullBlobX23 == x && fullBlobZ23 == z) return(23);
	if(fullBlobX24 == x && fullBlobZ24 == z) return(24); if(fullBlobX25 == x && fullBlobZ25 == z) return(25);
	if(fullBlobX26 == x && fullBlobZ26 == z) return(26); if(fullBlobX27 == x && fullBlobZ27 == z) return(27);
	if(fullBlobX28 == x && fullBlobZ28 == z) return(28); if(fullBlobX29 == x && fullBlobZ29 == z) return(29);
	if(fullBlobX30 == x && fullBlobZ30 == z) return(30); if(fullBlobX31 == x && fullBlobZ31 == z) return(31);
	if(fullBlobX32 == x && fullBlobZ32 == z) return(32); if(fullBlobX33 == x && fullBlobZ33 == z) return(33);
	if(fullBlobX34 == x && fullBlobZ34 == z) return(34); if(fullBlobX35 == x && fullBlobZ35 == z) return(35);
	if(fullBlobX36 == x && fullBlobZ36 == z) return(36); if(fullBlobX37 == x && fullBlobZ37 == z) return(37);
	if(fullBlobX38 == x && fullBlobZ38 == z) return(38); if(fullBlobX39 == x && fullBlobZ39 == z) return(39);
	if(fullBlobX40 == x && fullBlobZ40 == z) return(40); if(fullBlobX41 == x && fullBlobZ41 == z) return(41);
	if(fullBlobX42 == x && fullBlobZ42 == z) return(42); if(fullBlobX43 == x && fullBlobZ43 == z) return(43);
	if(fullBlobX44 == x && fullBlobZ44 == z) return(44); if(fullBlobX45 == x && fullBlobZ45 == z) return(45);
	if(fullBlobX46 == x && fullBlobZ46 == z) return(46); if(fullBlobX47 == x && fullBlobZ47 == z) return(47);
	if(fullBlobX48 == x && fullBlobZ48 == z) return(48); if(fullBlobX49 == x && fullBlobZ49 == z) return(49);
	if(fullBlobX50 == x && fullBlobZ50 == z) return(50); if(fullBlobX51 == x && fullBlobZ51 == z) return(51);
	if(fullBlobX52 == x && fullBlobZ52 == z) return(52); if(fullBlobX53 == x && fullBlobZ53 == z) return(53);
	if(fullBlobX54 == x && fullBlobZ54 == z) return(54); if(fullBlobX55 == x && fullBlobZ55 == z) return(55);
	if(fullBlobX56 == x && fullBlobZ56 == z) return(56); if(fullBlobX57 == x && fullBlobZ57 == z) return(57);
	if(fullBlobX58 == x && fullBlobZ58 == z) return(58); if(fullBlobX59 == x && fullBlobZ59 == z) return(59);
	if(fullBlobX60 == x && fullBlobZ60 == z) return(60); if(fullBlobX61 == x && fullBlobZ61 == z) return(61);
	if(fullBlobX62 == x && fullBlobZ62 == z) return(62); if(fullBlobX63 == x && fullBlobZ63 == z) return(63);

	return (-1);
}

/*
** Removes a full blob from the list of full blobs.
**
** @param id: the ID of the blob to be removed
*/
void removeFullBlob(int id = -1) {
	if(id == -1 || fullBlobsCount == 0) {
		return;
	}

	fullBlobsCount--;

	// Shift entries in the array to maintain contiguousness.
	for(i = id; < fullBlobsCount) {
		setFullBlob(getFullBlobX(i + 1), getFullBlobZ(i + 1), i);
	}
}

/*************
* NEAR BLOBS *
*************/

int nearBlobsCount = 0;

int nearBlobX0  = 0; int nearBlobX1  = 0; int nearBlobX2  = 0; int nearBlobX3  = 0;
int nearBlobX4  = 0; int nearBlobX5  = 0; int nearBlobX6  = 0; int nearBlobX7  = 0;
int nearBlobX8  = 0; int nearBlobX9  = 0; int nearBlobX10 = 0; int nearBlobX11 = 0;
int nearBlobX12 = 0; int nearBlobX13 = 0; int nearBlobX14 = 0; int nearBlobX15 = 0;
int nearBlobX16 = 0; int nearBlobX17 = 0; int nearBlobX18 = 0; int nearBlobX19 = 0;
int nearBlobX20 = 0; int nearBlobX21 = 0; int nearBlobX22 = 0; int nearBlobX23 = 0;
int nearBlobX24 = 0; int nearBlobX25 = 0; int nearBlobX26 = 0; int nearBlobX27 = 0;
int nearBlobX28 = 0; int nearBlobX29 = 0; int nearBlobX30 = 0; int nearBlobX31 = 0;
int nearBlobX32 = 0; int nearBlobX33 = 0; int nearBlobX34 = 0; int nearBlobX35 = 0;
int nearBlobX36 = 0; int nearBlobX37 = 0; int nearBlobX38 = 0; int nearBlobX39 = 0;
int nearBlobX40 = 0; int nearBlobX41 = 0; int nearBlobX42 = 0; int nearBlobX43 = 0;
int nearBlobX44 = 0; int nearBlobX45 = 0; int nearBlobX46 = 0; int nearBlobX47 = 0;
int nearBlobX48 = 0; int nearBlobX49 = 0; int nearBlobX50 = 0; int nearBlobX51 = 0;
int nearBlobX52 = 0; int nearBlobX53 = 0; int nearBlobX54 = 0; int nearBlobX55 = 0;
int nearBlobX56 = 0; int nearBlobX57 = 0; int nearBlobX58 = 0; int nearBlobX59 = 0;
int nearBlobX60 = 0; int nearBlobX61 = 0; int nearBlobX62 = 0; int nearBlobX63 = 0;

int nearBlobZ0  = 0; int nearBlobZ1  = 0; int nearBlobZ2  = 0; int nearBlobZ3  = 0;
int nearBlobZ4  = 0; int nearBlobZ5  = 0; int nearBlobZ6  = 0; int nearBlobZ7  = 0;
int nearBlobZ8  = 0; int nearBlobZ9  = 0; int nearBlobZ10 = 0; int nearBlobZ11 = 0;
int nearBlobZ12 = 0; int nearBlobZ13 = 0; int nearBlobZ14 = 0; int nearBlobZ15 = 0;
int nearBlobZ16 = 0; int nearBlobZ17 = 0; int nearBlobZ18 = 0; int nearBlobZ19 = 0;
int nearBlobZ20 = 0; int nearBlobZ21 = 0; int nearBlobZ22 = 0; int nearBlobZ23 = 0;
int nearBlobZ24 = 0; int nearBlobZ25 = 0; int nearBlobZ26 = 0; int nearBlobZ27 = 0;
int nearBlobZ28 = 0; int nearBlobZ29 = 0; int nearBlobZ30 = 0; int nearBlobZ31 = 0;
int nearBlobZ32 = 0; int nearBlobZ33 = 0; int nearBlobZ34 = 0; int nearBlobZ35 = 0;
int nearBlobZ36 = 0; int nearBlobZ37 = 0; int nearBlobZ38 = 0; int nearBlobZ39 = 0;
int nearBlobZ40 = 0; int nearBlobZ41 = 0; int nearBlobZ42 = 0; int nearBlobZ43 = 0;
int nearBlobZ44 = 0; int nearBlobZ45 = 0; int nearBlobZ46 = 0; int nearBlobZ47 = 0;
int nearBlobZ48 = 0; int nearBlobZ49 = 0; int nearBlobZ50 = 0; int nearBlobZ51 = 0;
int nearBlobZ52 = 0; int nearBlobZ53 = 0; int nearBlobZ54 = 0; int nearBlobZ55 = 0;
int nearBlobZ56 = 0; int nearBlobZ57 = 0; int nearBlobZ58 = 0; int nearBlobZ59 = 0;
int nearBlobZ60 = 0; int nearBlobZ61 = 0; int nearBlobZ62 = 0; int nearBlobZ63 = 0;

/*
** Adds a blob to the list of near blobs.
** The ID parameter should not be set unless you keep track of which blobs are set (note how fullBlobsCount is only incremented on id == -1).
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
** @param id: ID of the blob to be added
*/
void setNearBlob(int x = -1, int z = -1, int id = -1) {
	if(id == -1) {
		// If the ID is not specified, set state for next free blob.
		id = nearBlobsCount;

		// Since we don't overwrite an existing blob, increase the number of full blobs.
		nearBlobsCount++;
	}

	if(id == 0)  { nearBlobX0  = x; nearBlobZ0  = z; return; } if(id == 1)  { nearBlobX1  = x; nearBlobZ1  = z; return; }
	if(id == 2)  { nearBlobX2  = x; nearBlobZ2  = z; return; } if(id == 3)  { nearBlobX3  = x; nearBlobZ3  = z; return; }
	if(id == 4)  { nearBlobX4  = x; nearBlobZ4  = z; return; } if(id == 5)  { nearBlobX5  = x; nearBlobZ5  = z; return; }
	if(id == 6)  { nearBlobX6  = x; nearBlobZ6  = z; return; } if(id == 7)  { nearBlobX7  = x; nearBlobZ7  = z; return; }
	if(id == 8)  { nearBlobX8  = x; nearBlobZ8  = z; return; } if(id == 9)  { nearBlobX9  = x; nearBlobZ9  = z; return; }
	if(id == 10) { nearBlobX10 = x; nearBlobZ10 = z; return; } if(id == 11) { nearBlobX11 = x; nearBlobZ11 = z; return; }
	if(id == 12) { nearBlobX12 = x; nearBlobZ12 = z; return; } if(id == 13) { nearBlobX13 = x; nearBlobZ13 = z; return; }
	if(id == 14) { nearBlobX14 = x; nearBlobZ14 = z; return; } if(id == 15) { nearBlobX15 = x; nearBlobZ15 = z; return; }
	if(id == 16) { nearBlobX16 = x; nearBlobZ16 = z; return; } if(id == 17) { nearBlobX17 = x; nearBlobZ17 = z; return; }
	if(id == 18) { nearBlobX18 = x; nearBlobZ18 = z; return; } if(id == 19) { nearBlobX19 = x; nearBlobZ19 = z; return; }
	if(id == 20) { nearBlobX20 = x; nearBlobZ20 = z; return; } if(id == 21) { nearBlobX21 = x; nearBlobZ21 = z; return; }
	if(id == 22) { nearBlobX22 = x; nearBlobZ22 = z; return; } if(id == 23) { nearBlobX23 = x; nearBlobZ23 = z; return; }
	if(id == 24) { nearBlobX24 = x; nearBlobZ24 = z; return; } if(id == 25) { nearBlobX25 = x; nearBlobZ25 = z; return; }
	if(id == 26) { nearBlobX26 = x; nearBlobZ26 = z; return; } if(id == 27) { nearBlobX27 = x; nearBlobZ27 = z; return; }
	if(id == 28) { nearBlobX28 = x; nearBlobZ28 = z; return; } if(id == 29) { nearBlobX29 = x; nearBlobZ29 = z; return; }
	if(id == 30) { nearBlobX30 = x; nearBlobZ30 = z; return; } if(id == 31) { nearBlobX31 = x; nearBlobZ31 = z; return; }
	if(id == 32) { nearBlobX32 = x; nearBlobZ32 = z; return; } if(id == 33) { nearBlobX33 = x; nearBlobZ33 = z; return; }
	if(id == 34) { nearBlobX34 = x; nearBlobZ34 = z; return; } if(id == 35) { nearBlobX35 = x; nearBlobZ35 = z; return; }
	if(id == 36) { nearBlobX36 = x; nearBlobZ36 = z; return; } if(id == 37) { nearBlobX37 = x; nearBlobZ37 = z; return; }
	if(id == 38) { nearBlobX38 = x; nearBlobZ38 = z; return; } if(id == 39) { nearBlobX39 = x; nearBlobZ39 = z; return; }
	if(id == 40) { nearBlobX40 = x; nearBlobZ40 = z; return; } if(id == 41) { nearBlobX41 = x; nearBlobZ41 = z; return; }
	if(id == 42) { nearBlobX42 = x; nearBlobZ42 = z; return; } if(id == 43) { nearBlobX43 = x; nearBlobZ43 = z; return; }
	if(id == 44) { nearBlobX44 = x; nearBlobZ44 = z; return; } if(id == 45) { nearBlobX45 = x; nearBlobZ45 = z; return; }
	if(id == 46) { nearBlobX46 = x; nearBlobZ46 = z; return; } if(id == 47) { nearBlobX47 = x; nearBlobZ47 = z; return; }
	if(id == 48) { nearBlobX48 = x; nearBlobZ48 = z; return; } if(id == 49) { nearBlobX49 = x; nearBlobZ49 = z; return; }
	if(id == 50) { nearBlobX50 = x; nearBlobZ50 = z; return; } if(id == 51) { nearBlobX51 = x; nearBlobZ51 = z; return; }
	if(id == 52) { nearBlobX52 = x; nearBlobZ52 = z; return; } if(id == 53) { nearBlobX53 = x; nearBlobZ53 = z; return; }
	if(id == 54) { nearBlobX54 = x; nearBlobZ54 = z; return; } if(id == 55) { nearBlobX55 = x; nearBlobZ55 = z; return; }
	if(id == 56) { nearBlobX56 = x; nearBlobZ56 = z; return; } if(id == 57) { nearBlobX57 = x; nearBlobZ57 = z; return; }
	if(id == 58) { nearBlobX58 = x; nearBlobZ58 = z; return; } if(id == 59) { nearBlobX59 = x; nearBlobZ59 = z; return; }
	if(id == 60) { nearBlobX60 = x; nearBlobZ60 = z; return; } if(id == 61) { nearBlobX61 = x; nearBlobZ61 = z; return; }
	if(id == 62) { nearBlobX62 = x; nearBlobZ62 = z; return; } if(id == 63) { nearBlobX63 = x; nearBlobZ63 = z; return; }
}

/*
** Gets the x coordinate of a blob in the list of near blobs.
**
** @param id: ID of the blob
**
** @returns: the x coordinate of the blob
*/
int getNearBlobX(int id = -1) {
	if(id == 0)  return(nearBlobX0);  if(id == 1)  return(nearBlobX1);  if(id == 2)  return(nearBlobX2);  if(id == 3)  return(nearBlobX3);
	if(id == 4)  return(nearBlobX4);  if(id == 5)  return(nearBlobX5);  if(id == 6)  return(nearBlobX6);  if(id == 7)  return(nearBlobX7);
	if(id == 8)  return(nearBlobX8);  if(id == 9)  return(nearBlobX9);  if(id == 10) return(nearBlobX10); if(id == 11) return(nearBlobX11);
	if(id == 12) return(nearBlobX12); if(id == 13) return(nearBlobX13); if(id == 14) return(nearBlobX14); if(id == 15) return(nearBlobX15);
	if(id == 16) return(nearBlobX16); if(id == 17) return(nearBlobX17); if(id == 18) return(nearBlobX18); if(id == 19) return(nearBlobX19);
	if(id == 20) return(nearBlobX20); if(id == 21) return(nearBlobX21); if(id == 22) return(nearBlobX22); if(id == 23) return(nearBlobX23);
	if(id == 24) return(nearBlobX24); if(id == 25) return(nearBlobX25); if(id == 26) return(nearBlobX26); if(id == 27) return(nearBlobX27);
	if(id == 28) return(nearBlobX28); if(id == 29) return(nearBlobX29); if(id == 30) return(nearBlobX30); if(id == 31) return(nearBlobX31);
	if(id == 32) return(nearBlobX32); if(id == 33) return(nearBlobX33); if(id == 34) return(nearBlobX34); if(id == 35) return(nearBlobX35);
	if(id == 36) return(nearBlobX36); if(id == 37) return(nearBlobX37); if(id == 38) return(nearBlobX38); if(id == 39) return(nearBlobX39);
	if(id == 40) return(nearBlobX40); if(id == 41) return(nearBlobX41); if(id == 42) return(nearBlobX42); if(id == 43) return(nearBlobX43);
	if(id == 44) return(nearBlobX44); if(id == 45) return(nearBlobX45); if(id == 46) return(nearBlobX46); if(id == 47) return(nearBlobX47);
	if(id == 48) return(nearBlobX48); if(id == 49) return(nearBlobX49); if(id == 50) return(nearBlobX50); if(id == 51) return(nearBlobX51);
	if(id == 52) return(nearBlobX52); if(id == 53) return(nearBlobX53); if(id == 54) return(nearBlobX54); if(id == 55) return(nearBlobX55);
	if(id == 56) return(nearBlobX56); if(id == 57) return(nearBlobX57); if(id == 58) return(nearBlobX58); if(id == 59) return(nearBlobX59);
	if(id == 60) return(nearBlobX60); if(id == 61) return(nearBlobX61); if(id == 62) return(nearBlobX62); if(id == 63) return(nearBlobX63);

	return(0);
}

/*
** Gets the z coordinate of a blob in the list of near blobs.
**
** @param id: ID of the blob
**
** @returns: the z coordinate of the blob
*/
int getNearBlobZ(int id = -1) {
	if(id == 0)  return(nearBlobZ0);  if(id == 1)  return(nearBlobZ1);  if(id == 2)  return(nearBlobZ2);  if(id == 3)  return(nearBlobZ3);
	if(id == 4)  return(nearBlobZ4);  if(id == 5)  return(nearBlobZ5);  if(id == 6)  return(nearBlobZ6);  if(id == 7)  return(nearBlobZ7);
	if(id == 8)  return(nearBlobZ8);  if(id == 9)  return(nearBlobZ9);  if(id == 10) return(nearBlobZ10); if(id == 11) return(nearBlobZ11);
	if(id == 12) return(nearBlobZ12); if(id == 13) return(nearBlobZ13); if(id == 14) return(nearBlobZ14); if(id == 15) return(nearBlobZ15);
	if(id == 16) return(nearBlobZ16); if(id == 17) return(nearBlobZ17); if(id == 18) return(nearBlobZ18); if(id == 19) return(nearBlobZ19);
	if(id == 20) return(nearBlobZ20); if(id == 21) return(nearBlobZ21); if(id == 22) return(nearBlobZ22); if(id == 23) return(nearBlobZ23);
	if(id == 24) return(nearBlobZ24); if(id == 25) return(nearBlobZ25); if(id == 26) return(nearBlobZ26); if(id == 27) return(nearBlobZ27);
	if(id == 28) return(nearBlobZ28); if(id == 29) return(nearBlobZ29); if(id == 30) return(nearBlobZ30); if(id == 31) return(nearBlobZ31);
	if(id == 32) return(nearBlobZ32); if(id == 33) return(nearBlobZ33); if(id == 34) return(nearBlobZ34); if(id == 35) return(nearBlobZ35);
	if(id == 36) return(nearBlobZ36); if(id == 37) return(nearBlobZ37); if(id == 38) return(nearBlobZ38); if(id == 39) return(nearBlobZ39);
	if(id == 40) return(nearBlobZ40); if(id == 41) return(nearBlobZ41); if(id == 42) return(nearBlobZ42); if(id == 43) return(nearBlobZ43);
	if(id == 44) return(nearBlobZ44); if(id == 45) return(nearBlobZ45); if(id == 46) return(nearBlobZ46); if(id == 47) return(nearBlobZ47);
	if(id == 48) return(nearBlobZ48); if(id == 49) return(nearBlobZ49); if(id == 50) return(nearBlobZ50); if(id == 51) return(nearBlobZ51);
	if(id == 52) return(nearBlobZ52); if(id == 53) return(nearBlobZ53); if(id == 54) return(nearBlobZ54); if(id == 55) return(nearBlobZ55);
	if(id == 56) return(nearBlobZ56); if(id == 57) return(nearBlobZ57); if(id == 58) return(nearBlobZ58); if(id == 59) return(nearBlobZ59);
	if(id == 60) return(nearBlobZ60); if(id == 61) return(nearBlobZ61); if(id == 62) return(nearBlobZ62); if(id == 63) return(nearBlobZ63);

	return(0);
}

/*
** Searches the list of near blobs for the ID of a blob with given coordinates.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
**
** @returns: the ID of the blob
*/
int findNearBlob(int x = -1, int z = -1) {
	if(nearBlobX0  == x && nearBlobZ0  == z) return(0);  if(nearBlobX1  == x && nearBlobZ1  == z) return(1);
	if(nearBlobX2  == x && nearBlobZ2  == z) return(2);  if(nearBlobX3  == x && nearBlobZ3  == z) return(3);
	if(nearBlobX4  == x && nearBlobZ4  == z) return(4);  if(nearBlobX5  == x && nearBlobZ5  == z) return(5);
	if(nearBlobX6  == x && nearBlobZ6  == z) return(6);  if(nearBlobX7  == x && nearBlobZ7  == z) return(7);
	if(nearBlobX8  == x && nearBlobZ8  == z) return(8);  if(nearBlobX9  == x && nearBlobZ9  == z) return(9);
	if(nearBlobX10 == x && nearBlobZ10 == z) return(10); if(nearBlobX11 == x && nearBlobZ11 == z) return(11);
	if(nearBlobX12 == x && nearBlobZ12 == z) return(12); if(nearBlobX13 == x && nearBlobZ13 == z) return(13);
	if(nearBlobX14 == x && nearBlobZ14 == z) return(14); if(nearBlobX15 == x && nearBlobZ15 == z) return(15);
	if(nearBlobX16 == x && nearBlobZ16 == z) return(16); if(nearBlobX17 == x && nearBlobZ17 == z) return(17);
	if(nearBlobX18 == x && nearBlobZ18 == z) return(18); if(nearBlobX19 == x && nearBlobZ19 == z) return(19);
	if(nearBlobX20 == x && nearBlobZ20 == z) return(20); if(nearBlobX21 == x && nearBlobZ21 == z) return(21);
	if(nearBlobX22 == x && nearBlobZ22 == z) return(22); if(nearBlobX23 == x && nearBlobZ23 == z) return(23);
	if(nearBlobX24 == x && nearBlobZ24 == z) return(24); if(nearBlobX25 == x && nearBlobZ25 == z) return(25);
	if(nearBlobX26 == x && nearBlobZ26 == z) return(26); if(nearBlobX27 == x && nearBlobZ27 == z) return(27);
	if(nearBlobX28 == x && nearBlobZ28 == z) return(28); if(nearBlobX29 == x && nearBlobZ29 == z) return(29);
	if(nearBlobX30 == x && nearBlobZ30 == z) return(30); if(nearBlobX31 == x && nearBlobZ31 == z) return(31);
	if(nearBlobX32 == x && nearBlobZ32 == z) return(32); if(nearBlobX33 == x && nearBlobZ33 == z) return(33);
	if(nearBlobX34 == x && nearBlobZ34 == z) return(34); if(nearBlobX35 == x && nearBlobZ35 == z) return(35);
	if(nearBlobX36 == x && nearBlobZ36 == z) return(36); if(nearBlobX37 == x && nearBlobZ37 == z) return(37);
	if(nearBlobX38 == x && nearBlobZ38 == z) return(38); if(nearBlobX39 == x && nearBlobZ39 == z) return(39);
	if(nearBlobX40 == x && nearBlobZ40 == z) return(40); if(nearBlobX41 == x && nearBlobZ41 == z) return(41);
	if(nearBlobX42 == x && nearBlobZ42 == z) return(42); if(nearBlobX43 == x && nearBlobZ43 == z) return(43);
	if(nearBlobX44 == x && nearBlobZ44 == z) return(44); if(nearBlobX45 == x && nearBlobZ45 == z) return(45);
	if(nearBlobX46 == x && nearBlobZ46 == z) return(46); if(nearBlobX47 == x && nearBlobZ47 == z) return(47);
	if(nearBlobX48 == x && nearBlobZ48 == z) return(48); if(nearBlobX49 == x && nearBlobZ49 == z) return(49);
	if(nearBlobX50 == x && nearBlobZ50 == z) return(50); if(nearBlobX51 == x && nearBlobZ51 == z) return(51);
	if(nearBlobX52 == x && nearBlobZ52 == z) return(52); if(nearBlobX53 == x && nearBlobZ53 == z) return(53);
	if(nearBlobX54 == x && nearBlobZ54 == z) return(54); if(nearBlobX55 == x && nearBlobZ55 == z) return(55);
	if(nearBlobX56 == x && nearBlobZ56 == z) return(56); if(nearBlobX57 == x && nearBlobZ57 == z) return(57);
	if(nearBlobX58 == x && nearBlobZ58 == z) return(58); if(nearBlobX59 == x && nearBlobZ59 == z) return(59);
	if(nearBlobX60 == x && nearBlobZ60 == z) return(60); if(nearBlobX61 == x && nearBlobZ61 == z) return(61);
	if(nearBlobX62 == x && nearBlobZ62 == z) return(62); if(nearBlobX63 == x && nearBlobZ63 == z) return(63);

	return(-1);
}

/*
** Removes a full blob from the list of near blobs.
**
** @param id: the ID of the blob to be removed
*/
void removeNearBlob(int id = -1) {
	if(id == -1 || nearBlobsCount == 0) {
		return;
	}

	nearBlobsCount--;

	// Shift entries in the array to maintain contiguousness.
	for(i = id; < nearBlobsCount) {
		setNearBlob(getNearBlobX(i + 1), getNearBlobZ(i + 1), i);
	}
}

/**************
* BLOB ACCESS *
**************/

/*
** Resets all blob counters and coordinats to 0.
*/
void resetBlobs() {
	fullBlobsCount = 0;
	nearBlobsCount = 0;

	// It's necessary to clear here for getBlobIndex() (otherwise blobs that do not actually exist can be found).
	fullBlobX0  = 0; fullBlobX1  = 0; fullBlobX2  = 0; fullBlobX3  = 0;
	fullBlobX4  = 0; fullBlobX5  = 0; fullBlobX6  = 0; fullBlobX7  = 0;
	fullBlobX8  = 0; fullBlobX9  = 0; fullBlobX10 = 0; fullBlobX11 = 0;
	fullBlobX12 = 0; fullBlobX13 = 0; fullBlobX14 = 0; fullBlobX15 = 0;
	fullBlobX16 = 0; fullBlobX17 = 0; fullBlobX18 = 0; fullBlobX19 = 0;
	fullBlobX20 = 0; fullBlobX21 = 0; fullBlobX22 = 0; fullBlobX23 = 0;
	fullBlobX24 = 0; fullBlobX25 = 0; fullBlobX26 = 0; fullBlobX27 = 0;
	fullBlobX28 = 0; fullBlobX29 = 0; fullBlobX30 = 0; fullBlobX31 = 0;
	fullBlobX32 = 0; fullBlobX33 = 0; fullBlobX34 = 0; fullBlobX35 = 0;
	fullBlobX36 = 0; fullBlobX37 = 0; fullBlobX38 = 0; fullBlobX39 = 0;
	fullBlobX40 = 0; fullBlobX41 = 0; fullBlobX42 = 0; fullBlobX43 = 0;
	fullBlobX44 = 0; fullBlobX45 = 0; fullBlobX46 = 0; fullBlobX47 = 0;
	fullBlobX48 = 0; fullBlobX49 = 0; fullBlobX50 = 0; fullBlobX51 = 0;
	fullBlobX52 = 0; fullBlobX53 = 0; fullBlobX54 = 0; fullBlobX55 = 0;
	fullBlobX56 = 0; fullBlobX57 = 0; fullBlobX58 = 0; fullBlobX59 = 0;
	fullBlobX60 = 0; fullBlobX61 = 0; fullBlobX62 = 0; fullBlobX63 = 0;

	fullBlobZ0  = 0; fullBlobZ1  = 0; fullBlobZ2  = 0; fullBlobZ3  = 0;
	fullBlobZ4  = 0; fullBlobZ5  = 0; fullBlobZ6  = 0; fullBlobZ7  = 0;
	fullBlobZ8  = 0; fullBlobZ9  = 0; fullBlobZ10 = 0; fullBlobZ11 = 0;
	fullBlobZ12 = 0; fullBlobZ13 = 0; fullBlobZ14 = 0; fullBlobZ15 = 0;
	fullBlobZ16 = 0; fullBlobZ17 = 0; fullBlobZ18 = 0; fullBlobZ19 = 0;
	fullBlobZ20 = 0; fullBlobZ21 = 0; fullBlobZ22 = 0; fullBlobZ23 = 0;
	fullBlobZ24 = 0; fullBlobZ25 = 0; fullBlobZ26 = 0; fullBlobZ27 = 0;
	fullBlobZ28 = 0; fullBlobZ29 = 0; fullBlobZ30 = 0; fullBlobZ31 = 0;
	fullBlobZ32 = 0; fullBlobZ33 = 0; fullBlobZ34 = 0; fullBlobZ35 = 0;
	fullBlobZ36 = 0; fullBlobZ37 = 0; fullBlobZ38 = 0; fullBlobZ39 = 0;
	fullBlobZ40 = 0; fullBlobZ41 = 0; fullBlobZ42 = 0; fullBlobZ43 = 0;
	fullBlobZ44 = 0; fullBlobZ45 = 0; fullBlobZ46 = 0; fullBlobZ47 = 0;
	fullBlobZ48 = 0; fullBlobZ49 = 0; fullBlobZ50 = 0; fullBlobZ51 = 0;
	fullBlobZ52 = 0; fullBlobZ53 = 0; fullBlobZ54 = 0; fullBlobZ55 = 0;
	fullBlobZ56 = 0; fullBlobZ57 = 0; fullBlobZ58 = 0; fullBlobZ59 = 0;
	fullBlobZ60 = 0; fullBlobZ61 = 0; fullBlobZ62 = 0; fullBlobZ63 = 0;

	nearBlobX0  = 0; nearBlobX1  = 0; nearBlobX2  = 0; nearBlobX3  = 0;
	nearBlobX4  = 0; nearBlobX5  = 0; nearBlobX6  = 0; nearBlobX7  = 0;
	nearBlobX8  = 0; nearBlobX9  = 0; nearBlobX10 = 0; nearBlobX11 = 0;
	nearBlobX12 = 0; nearBlobX13 = 0; nearBlobX14 = 0; nearBlobX15 = 0;
	nearBlobX16 = 0; nearBlobX17 = 0; nearBlobX18 = 0; nearBlobX19 = 0;
	nearBlobX20 = 0; nearBlobX21 = 0; nearBlobX22 = 0; nearBlobX23 = 0;
	nearBlobX24 = 0; nearBlobX25 = 0; nearBlobX26 = 0; nearBlobX27 = 0;
	nearBlobX28 = 0; nearBlobX29 = 0; nearBlobX30 = 0; nearBlobX31 = 0;
	nearBlobX32 = 0; nearBlobX33 = 0; nearBlobX34 = 0; nearBlobX35 = 0;
	nearBlobX36 = 0; nearBlobX37 = 0; nearBlobX38 = 0; nearBlobX39 = 0;
	nearBlobX40 = 0; nearBlobX41 = 0; nearBlobX42 = 0; nearBlobX43 = 0;
	nearBlobX44 = 0; nearBlobX45 = 0; nearBlobX46 = 0; nearBlobX47 = 0;
	nearBlobX48 = 0; nearBlobX49 = 0; nearBlobX50 = 0; nearBlobX51 = 0;
	nearBlobX52 = 0; nearBlobX53 = 0; nearBlobX54 = 0; nearBlobX55 = 0;
	nearBlobX56 = 0; nearBlobX57 = 0; nearBlobX58 = 0; nearBlobX59 = 0;
	nearBlobX60 = 0; nearBlobX61 = 0; nearBlobX62 = 0; nearBlobX63 = 0;

	nearBlobZ0  = 0; nearBlobZ1  = 0; nearBlobZ2  = 0; nearBlobZ3  = 0;
	nearBlobZ4  = 0; nearBlobZ5  = 0; nearBlobZ6  = 0; nearBlobZ7  = 0;
	nearBlobZ8  = 0; nearBlobZ9  = 0; nearBlobZ10 = 0; nearBlobZ11 = 0;
	nearBlobZ12 = 0; nearBlobZ13 = 0; nearBlobZ14 = 0; nearBlobZ15 = 0;
	nearBlobZ16 = 0; nearBlobZ17 = 0; nearBlobZ18 = 0; nearBlobZ19 = 0;
	nearBlobZ20 = 0; nearBlobZ21 = 0; nearBlobZ22 = 0; nearBlobZ23 = 0;
	nearBlobZ24 = 0; nearBlobZ25 = 0; nearBlobZ26 = 0; nearBlobZ27 = 0;
	nearBlobZ28 = 0; nearBlobZ29 = 0; nearBlobZ30 = 0; nearBlobZ31 = 0;
	nearBlobZ32 = 0; nearBlobZ33 = 0; nearBlobZ34 = 0; nearBlobZ35 = 0;
	nearBlobZ36 = 0; nearBlobZ37 = 0; nearBlobZ38 = 0; nearBlobZ39 = 0;
	nearBlobZ40 = 0; nearBlobZ41 = 0; nearBlobZ42 = 0; nearBlobZ43 = 0;
	nearBlobZ44 = 0; nearBlobZ45 = 0; nearBlobZ46 = 0; nearBlobZ47 = 0;
	nearBlobZ48 = 0; nearBlobZ49 = 0; nearBlobZ50 = 0; nearBlobZ51 = 0;
	nearBlobZ52 = 0; nearBlobZ53 = 0; nearBlobZ54 = 0; nearBlobZ55 = 0;
	nearBlobZ56 = 0; nearBlobZ57 = 0; nearBlobZ58 = 0; nearBlobZ59 = 0;
	nearBlobZ60 = 0; nearBlobZ61 = 0; nearBlobZ62 = 0; nearBlobZ63 = 0;
}

/*
** Retrieves the x coodinate of a blob with a certain ID depending on its state.
**
** @param id: the ID of the blob
** @param state: the state of the blob (i.e., the list of blobs to search)
**
** @returns: the x coodinate of the blob on the grid
*/
int getBlobX(int id = -1, int state = cBlobInvalid) {
	if(state == cBlobFull) {
		return(getFullBlobX(id));
	} else if(state == cBlobNear) {
		return(getNearBlobX(id));
	}

	return(cBlobInvalid);
}

/*
** Retrieves the z coodinate of a blob with a certain ID depending on its state.
**
** @param id: the ID of the blob
** @param state: the state of the blob (i.e., the list of blobs to search)
**
** @returns: the z coodinate of the blob on the grid
*/
int getBlobZ(int id = -1, int state = cBlobInvalid) {
	if(state == cBlobFull) {
		return(getFullBlobZ(id));
	} else if(state == cBlobNear) {
		return(getNearBlobZ(id));
	}

	return(cBlobInvalid);
}

/*
** Retrieves the size of a list of blobs.
**
** @param state: the list to retrieve the size of
**
** @returns: the list size
*/
int getStateSize(int state = cBlobInvalid) {
	if(state == cBlobFull) {
		return(fullBlobsCount);
	} else if(state == cBlobNear) {
		return(nearBlobsCount);
	}

	return(cBlobInvalid);
}

/*
** Appends a blob to a list depending on its state.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
** @param state: the state of the blob (i.e., the list of blobs to append to)
*/
void writeBlob(int x = -1, int z = -1, int state = cBlobInvalid) {
	if(state == cBlobFull) {
		setFullBlob(x, z);
	} else if(state == cBlobNear) {
		setNearBlob(x, z);
	}
}

/*
** Removes a blob from the list depending on its state.
**
** @param id: the ID of the blob
** @param state: the state of the blob (i.e., the list of blobs to remove the blob from)
*/
void removeBlob(int id = -1, int state = cBlobInvalid) {
	if(state == cBlobFull) {
		removeFullBlob(id);
	} else if(state == cBlobNear) {
		removeNearBlob(id);
	}
}

/*
** Gets the ID of a blob given its coordinates and state.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
** @param state: the state of the blob (i.e., the list of blobs to scan)
**
** @returns: the ID of the blob
*/
int getBlobIndex(int x = -1, int z = -1, int state = cBlobInvalid) {
	if(state == cBlobFull) {
		return(findFullBlob(x, z));
	} else if(state == cBlobNear) {
		return(findNearBlob(x, z));
	}

	return(cBlobInvalid);
}

/*
** Gets the state of a blob given its coordinates.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
**
** @returns: the state of the blob
*/
int getBlobState(int x = -1, int z = -1) {
	for(i = cFirstState; <= cTotalStates) {
		if(getBlobIndex(x, z, i) != -1) {
			return(i);
		}
	}

	return(cBlobEmpty);
}

/*
** Gets the blob distance from the center of 0/0.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
**
** @returns: the distance from the center as float
*/
float getBlobDistance(int x = -1, int z = -1) {
	// Don't bother taking the square root here, the values only have to be comparable, not exact.
	return(1.0 * sq(x) + sq(z));
}

/*******************
* SHAPE GENERATION *
*******************/

/*
** Gets the minimum distance from any near blob to the center.
**
** @returns: the minimum distance of any blob to the center as a float
*/
float getMinBlobDistance() {
	float minDist = INF;

	for(i = 0; < getStateSize(cBlobNear)) {
		int x = getBlobX(i, cBlobNear);
		int z = getBlobZ(i, cBlobNear);

		float distance = getBlobDistance(x, z);

		if(distance < minDist) {
			minDist = distance;
		}
	}

	return(minDist);
}

/*
** Gets the maximum distance from any near blob to the center.
**
** @returns: the maximum distance of any blob to the center as a float
*/
float getMaxBlobDistance() {
	float maxDist = 0.0;

	for(i = 0; < getStateSize(cBlobNear)) {
		int x = getBlobX(i, cBlobNear);
		int z = getBlobZ(i, cBlobNear);

		float distance = getBlobDistance(x, z);

		if(distance > maxDist) {
			maxDist = distance;
		}
	}

	return(maxDist);
}

/*
** Calculates the chance for a single blob to be filled based on coordinates, coherence and distance to the center.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
** @param coherence: [-1.0, 0.0]: long shapes (-1.0 = a line); [0.0, 1.0]: circular shapes (1.0 = circle)
** @param minDist: the current minimum distance of any blob to the center
** @param maxDist: the current maximum distance of any blob to the center
**
** @returns: the chance for the particular blob to be filled
*/
float getBlobChance(int x = -1, int z = -1, float coherence = 0.0, float minDist = -1.0, float maxDist = -1.0) {
	float distance = getBlobDistance(x, z);

	// Guarantee 100% for first blob at 0/0.
	if(distance == 0.0) {
		return(1.0);
	}

	// Upon negative coherence, give a higher probability for blobs further away.
	if(coherence < 0.0) {
		coherence = 0.0 - coherence;

		float maxPart = distance / maxDist;

		return(coherence * pow(maxPart, 3) + (1.0 - coherence));
	}

	float minPart = 0.0;

	/*
	 * Otherwise, guarantee 1.0 for closest blobs if coherence >= 0. If not closest blob, return 1.0 - coherence.
	 * For a coherence of 1.0, blobs that don't have minimum distance thus have a 0% chance of getting picked.
	 * For a coherence of 0.0, all blobs have a chance of 1.0 of being picked, regardless if closest or not.
	*/
	if(distance == minDist) {
		minPart = 1.0;
	}

	return(coherence * minPart + (1.0 - coherence));
}

/*
** Fills a certain blob. The blob has to be near already to be filled.
** If this is the case, all adjacent blobs are marked as near, and the targeted blob is filled.
**
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
*/
void fillBlob(int x = -1, int z = -1) {
	// Fills a single blob and marks all blobs surrounding the x/z coordinates as near.
	if(getBlobState(x, z) != cBlobNear) {
		// Blob has to be near, otherwise it can't be filled!
		return;
	}

	for(j = -1; <= 1) {
		for(k = -1; <= 1) {
			if(j == 0 && k == 0) {
				// Remove chosen blob from near blobs and add to full blobs.
				removeBlob(getBlobIndex(x, z, cBlobNear), cBlobNear);
				writeBlob(x, z, cBlobFull);
			} else if(getBlobState(x + j, z + k) == cBlobEmpty) {
				// Add adjacent blobs to near blobs.
				writeBlob(x + j, z + k, cBlobNear);
			}
		}
	}
}

/*
** Adds a new blob to the shape.
**
** @param coherence: [-1.0, 0.0]: long shapes (-1.0 = line); [0.0, 1.0]: circular shapes (1.0 = circle)
*/
void addBlob(float coherence = 1.0) {
	float maxChance = 0.0;
	float maxDistance = getMaxBlobDistance(); // Distance of furthest near blob.
	float minDistance = getMinBlobDistance(); // Distance of closest near blob.

	for(i = 0; < getStateSize(cBlobNear)) {
		int x = getBlobX(i, cBlobNear);
		int z = getBlobZ(i, cBlobNear);
		maxChance = maxChance + getBlobChance(x, z, coherence, minDistance, maxDistance);
	}

	// Return if we have a summed chance of 0%.
	if(maxChance == 0.0) {
		return;
	}

	float randomChance = rmRandFloat(0.0, maxChance);
	maxChance = 0.0;

	// Pick a random blob, blobs with higher chances will get selected more likely.
	for(i = 0; < getStateSize(cBlobNear)) {
		x = getBlobX(i, cBlobNear);
		z = getBlobZ(i, cBlobNear);
		maxChance = maxChance + getBlobChance(x, z, coherence, minDistance, maxDistance);

		// Over threshold, select current blob.
		if(maxChance >= randomChance) {
			fillBlob(x, z);
			return;
		}
	}
}

/*
** Creates a new random shape.
**
** @param numBlobs: the number of blobs to use for the shape
** @param coherence: [-1.0, 0.0]: long shapes (-1.0 = line); [0.0, 1.0]: circular shapes (1.0 = circle)
*/
void createRandomShape(int numBlobs = 0, float coherence = 1.0) {
	resetBlobs();

	writeBlob(0, 0, cBlobNear);

	for(i = 0; < numBlobs) {
		addBlob(coherence);
	}
}

/*
** Sets the area location for a single blob, i.e., maps the blob coodinate system onto the random map coodinate system.
**
** @param radius: the radius at which the random shape should be placed
** @param angle: the angle at which the random shape should be placed
** @param areaID: the area ID of this specific blob as int
** @param blobRadius: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
** @param x: x coordinate on the grid
** @param z: z coordinate on the grid
** @param player: the player to place the area for; if this is set, player angle offset is used instead of the center of the map
*/
void placeBlob(float radius = -1.0, float angle = -1.0, int areaID = -1, float blobRadius = -1.0, float blobSpacing = 1.0, float x = -1.0, float z = -1.0, int player = 0) {
	rmSetAreaSize(areaID, areaRadiusMetersToFraction(blobRadius));
	rmSetAreaCoherence(areaID, 1.0);
	rmSetAreaWarnFailure(areaID, false);

	// Calculate position and rotate by angle.
	float posX = getXFromPolarForPlayer(player, radius, angle) + rmXMetersToFraction(blobSpacing) * getXRotatePoint(x, z, angle + getPlayerAngle(player));
	float posZ = getZFromPolarForPlayer(player, radius, angle) + rmZMetersToFraction(blobSpacing) * getZRotatePoint(x, z, angle + getPlayerAngle(player));

	// Set area location and fit to map.
	rmSetAreaLocation(areaID, fitToMap(posX), fitToMap(posZ));
}

/*
** Calculates the mirrored angle of a shape based on a given angle and whether center offset or player offset is used.
**
** @param angle: the angle to mirror
** @param hasCenterOffset: whether center offset is used or not (= player offset is used)
**
** @returns: the mirrored angle
*/
float getMirrorAngleForShape(float angle = 0.0, bool hasCenterOffset = true) {
	int mode = getMirrorMode();

	// Mirror by point: Rotate by 180 degree.
	if(mode == cMirrorPoint) {
		if(hasCenterOffset) {
			return(angle + PI);
		} else {
			return(angle);
		}
	}

	// Mirror by axis.
	angle = 0.0 - angle;

	// When using player offset, just return 0.0 - angle.
	if(hasCenterOffset == false) {
		return(angle);
	}

	// Center offset: 4 possibilities for all 4 possible axis mirror cases.
	if(mode == cMirrorAxisX) {
		return(angle);
	} else if(mode == cMirrorAxisZ) {
		return(angle + PI);
	} else if(mode == cMirrorAxisH) {
		return(angle + 1.5 * PI);
	} else if(mode == cMirrorAxisV) {
		return(angle + 0.5 * PI);
	}

	// Should never happen.
	return(0.0);
}

/*
** Places a previously created shape on the map and mirrors it. This sets the locations of the areas and requires areas to be defined as
** areaName + " " + i + " " + j where i is in {0, 1} for the original and mirrored area and j is the number of blobs the shape has (starting from 0).
** The mirrored shape will be placed according to the mirror mode set.
** If a player is set, the area will be mirrored for the corresponding mirrored player (also depending on the mirror mode that has been set).
**
** @param radius: the radius in meters at which the random shape should be placed
** @param angle: the angle at which the random shape should be placed
** @param name: the name of the areas; format: "myAreaName 0 0", "myAreaName 0 1", ..., "myAreaName 1 0", "myAreaName 1 1", ...
** @param blobRadius: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
** @param player: the player to place the area for; if this is set, player angle offset is used instead of the center of the map
*/
void placeRandomShapeMirrored(float radius = 0.0, float angle = 0.0, string name = "", float blobRadius = 4.5, float blobSpacing = 4.5, int player = 0) {
	// Convert radius to fraction.
	radius = smallerMetersToFraction(radius);

	// Mirrored player and adjusted angle
	int mirrorPlayer = getMirroredPlayer(player);
	float mirrorAngle = getMirrorAngleForShape(angle, player == 0);

	// Place original shape.
	for(i = 0; < getStateSize(cBlobFull)) {
		int x = getBlobX(i, cBlobFull);
		int z = getBlobZ(i, cBlobFull);

		// Original shape.
		placeBlob(radius, angle, rmAreaID(name + " " + 0 + " " + i), blobRadius, blobSpacing, 0.0 + x, 0.0 + z, player);

		// Mirrored shape.
		if(getMirrorMode() == cMirrorPoint) {
			placeBlob(radius, mirrorAngle, rmAreaID(name + " " + 1 + " " + i), blobRadius, blobSpacing, 0.0 + x, 0.0 + z, mirrorPlayer);
		} else {
			/*
			 * By axis requires the inversion of the z axis of the shape grid.
			 * We don't invert the x axis here because we always want the same part of the shape to point towards the inside.
			 * While this may not sound very intuitive, if you draw a shape and try to rotate it and then mirror it, it will make sense.
			*/
			placeBlob(radius, mirrorAngle, rmAreaID(name + " " + 1 + " " + i), blobRadius, blobSpacing, 0.0 + x, 0.0 - z, mirrorPlayer);
		}
	}

	// Store locations.
	addLocPolarWithOffsetToLocStorage(player, radius, angle);
	addLocPolarWithOffsetToLocStorage(mirrorPlayer, radius, mirrorAngle);
}

/*
** Places a random shape on the map. This has to be called prior to rmBuildAllAreas(), which will then build the placed shape.
** This function is not used frequently as you probably only want to generate and place shapes when mirroring which is already covered by placeRandomShapeMirrored().
**
** @param radius: the radius in meters at which the random shape should be placed
** @param angle: the angle at which the random shape should be placed
** @param name: the name of the areas; format: "myAreaName 0", "myAreaName 1", ... (starting at 0)
** @param blobRadius: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
** @param player: the player to place the area for; if this is set, player angle offset is used instead of the center of the map
*/
void placeRandomShape(float radius = 0.0, float angle = 0.0, string name = "", float blobRadius = 4.5, float blobSpacing = 4.5, int player = 0) {
	radius = smallerMetersToFraction(radius);

	for(i = 0; < getStateSize(cBlobFull)) {
		int x = getBlobX(i, cBlobFull);
		int z = getBlobZ(i, cBlobFull);

		placeBlob(radius, angle, rmAreaID(name + " " + i), blobRadius, blobSpacing, 0.0 + x, 0.0 + z, player);
	}
}

/*
** Default mirrored area generation.
** RebelsRising
** Last edit: 07/03/2021
*/

// include "rmx_shape_gen.xs";

/************
* CONSTANTS *
************/

const string cAreaClassString = "rmx area class";

const string cAreaBlobString = "rmx area blob";
const string cFakeAreaString = "rmx fake area";

/**************
* CONSTRAINTS *
**************/

// Area constraints.
int areaConstraintCount = 0;

int areaConstraint0 = 0; int areaConstraint1 = 0; int areaConstraint2  = 0; int areaConstraint3  = 0;
int areaConstraint4 = 0; int areaConstraint5 = 0; int areaConstraint6  = 0; int areaConstraint7  = 0;
int areaConstraint8 = 0; int areaConstraint9 = 0; int areaConstraint10 = 0; int areaConstraint11 = 0;

int getAreaConstraint(int i = 0) {
	if(i == 0) return(areaConstraint0); if(i == 1) return(areaConstraint1); if(i == 2)  return(areaConstraint2);  if(i == 3)  return(areaConstraint3);
	if(i == 4) return(areaConstraint4); if(i == 5) return(areaConstraint5); if(i == 6)  return(areaConstraint6);  if(i == 7)  return(areaConstraint7);
	if(i == 8) return(areaConstraint8); if(i == 9) return(areaConstraint9); if(i == 10) return(areaConstraint10); if(i == 11) return(areaConstraint11);
	return(0);
}

void setAreaConstraint(int i = 0, int cID = 0) {
	if(i == 0) areaConstraint0 = cID; if(i == 1) areaConstraint1 = cID; if(i == 2)  areaConstraint2  = cID; if(i == 3)  areaConstraint3  = cID;
	if(i == 4) areaConstraint4 = cID; if(i == 5) areaConstraint5 = cID; if(i == 6)  areaConstraint6  = cID; if(i == 7)  areaConstraint7  = cID;
	if(i == 8) areaConstraint8 = cID; if(i == 9) areaConstraint9 = cID; if(i == 10) areaConstraint10 = cID; if(i == 11) areaConstraint11 = cID;
}

/*
** Resets area constraints.
*/
void resetAreaConstraints() {
	areaConstraintCount = 0;
}

/*
** Adds a constraint to the area constraints.
** Note that these should NOT include constraints that makes areas avoid themselves or buildArea() won't work properly!
**
** @param cID: the ID of the constraint
*/
void addAreaConstraint(int cID = 0) {
	setAreaConstraint(areaConstraintCount, cID);
	areaConstraintCount++;
}

/*************
* PARAMETERS *
*************/

// Used to keep track of the area class (if we need multiple classes).
int areaClassCount = -1;

// Counter for the number of areas so we don't run out of names.
int areaBlobCount = -1; // -1 since we increment before using the value.

// Default settings.
int classFakeArea = -1; // Set by initAreaClass().

int areaMinBlobs = 0;
int areaMaxBlobs = 0;

float areaBlobRequiredRatio = 0.5;

float areaBlobSize = 0.0;
float areaBlobSpacing = 0.0;

float areaMinCoherence = -1.0;
float areaMaxCoherence = 1.0;

float areaMinRadius = 20.0;
float areaMaxRadius = -1.0;

// Constraint for self avoidance.
int areaAvoidSelfID = -1;

// Whether to enforce constraints.
bool areaEnforceConstraints = false;

// Type.
string areaTerrainType = "";
string areaWaterType = "";

// Other properties.
float areaHeight = INF;
int areaSmoothDistance = -1;
int areaHeightBlend = -1;

// Layering doesn't make much sense because we place many small areas.

/*
** Sets a constraint for areas to avoid themselves.
**
** @param dist: distance in meters for areas to avoid each other
*/
void setAreaAvoidSelf(float dist = 0.0) {
	if(dist > 0.0) {
		areaAvoidSelfID = createClassDistConstraint(classFakeArea, dist);
	} else {
		areaAvoidSelfID = -1;
	}
}

/*
** Can be set to true to enforce constraints or all blobs instead of just applying them to fake blobs (at the cost of area precision).
**
** @param enforce: true to enforce constraints, false otherwise
*/
void setAreaEnforceConstraints(bool enforce = false) {
	areaEnforceConstraints = enforce;
}

/*
** Sets a minimum and maximum number of blobs for the areas.
**
** @param minBlobs: minimum number of blobs
** @param maxBlobs: maximum number of blobs, will be adjusted to minBlobs if not set
*/
void setAreaBlobs(int minBlobs = 0, int maxBlobs = -1) {
	if(maxBlobs < 0) {
		maxBlobs = minBlobs;
	}

	areaMinBlobs = minBlobs;
	areaMaxBlobs = maxBlobs;
}

/*
** Sets blob settings.
**
** @param blobSize: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
*/
void setAreaBlobParams(float blobSize = 0.0, float blobSpacing = 0.0) {
	areaBlobSize = blobSize;
	areaBlobSpacing = blobSpacing;
}

/*
** Sets additional parameters for the areas.
**
** @param height: the area height
** @param heightBlend: the hight blend parameter (0, 1 or 2) for areas
** @param smoothDistance: the smooth distance for areas
*/
void setAreaParams(float height = INF, int heightBlend = -1, int smoothDistance = -1) {
	areaHeight = height;
	areaSmoothDistance = smoothDistance;
	areaHeightBlend = heightBlend;
}

/*
** Sets the terrain type for the area.
**
** @param type: the terrain type as string
*/
void setAreaTerrainType(string type = "", float blobSize = -1.0, float blobSpacing = -1.0) {
	areaTerrainType = type;

	if(blobSize >= 0.0 && blobSpacing >= 0.0) {
		setAreaBlobParams(blobSize, blobSpacing);
	}
}

/*
** Sets the water type for the area.
**
** @param type: the water type as string
*/
void setAreaWaterType(string type = "", float blobSize = -1.0, float blobSpacing = -1.0) {
	areaWaterType = type;

	if(blobSize >= 0.0 && blobSpacing >= 0.0) {
		setAreaBlobParams(blobSize, blobSpacing);
	}
}

/*
** Sets the required ratio for an area to be built.
**
** @param requiredRatio: the minimum ratio of blobs successfully built required to build the entire area
*/
void setAreaRequiredRatio(float requiredRatio = 0.5) {
	areaBlobRequiredRatio = requiredRatio;
}

/*
** Sets a minimum and maximum coherence (compactness) for areas to randomize from.
**
** @param minCoherence: mimumum coherence (smallest possible value: -1.0), linear areas
** @param maxCoherence: maximum coherence (largest possible value: 1.0), circular areas
*/
void setAreaCoherence(float minCoherence = -1.0, float maxCoherence = 1.0) {
	areaMinCoherence = minCoherence;
	areaMaxCoherence = maxCoherence;
}

/*
** Sets a minimum and maximum radius in meters to consider when placing areas.
** Note that the default of -1.0 will be overwritten with the radius from the center to the corner at area generation time.
**
** @param minRadius: minimum radius in meters to randomize
** @param maxRadius: maximum radius in meters to randomize (-1.0 = up to corners)
*/
void setAreaSearchRadius(float minRadius = 20.0, float maxRadius = -1.0) {
	areaMinRadius = minRadius;
	areaMaxRadius = maxRadius;
}

/*
** Resets area settings (types, constraints, and search radius).
*/
void resetAreas() {
	classFakeArea = -1;

	resetAreaConstraints();

	setAreaTerrainType();
	setAreaWaterType();

	setAreaBlobs();
	setAreaBlobParams();
	setAreaParams();
	setAreaCoherence();
	setAreaSearchRadius();
	setAreaAvoidSelf();
	setAreaEnforceConstraints();
	setAreaRequiredRatio();
}

/******************
* AREA GENERATION *
******************/

/*
** Initializes the area class.
**
** @param clazz: use an existing class for the areas instead of a new one if set
**
** @returns: the ID of the created class (can be used to set constraints!)
*/
int initAreaClass(int clazz = -1) {
	if(clazz == -1) {
		classFakeArea = rmDefineClass(cAreaClassString + " " + areaClassCount);
		areaClassCount++;
	} else {
		classFakeArea = clazz;
	}

	return(classFakeArea);
}

/*
** Randomizes a radius while considering a areaMaxRadius of -1.0.
**
** @returns: the randomized area radius in meters
*/
float getAreaLocRadius() {
	// Adjust maximum radius if necessary (i.e., set to < 0).
	if(areaMaxRadius < 0) {
		areaMaxRadius = largerFractionToMeters(HALF_SQRT_2);
	}

	return(rmRandFloat(areaMinRadius, areaMaxRadius));
}

/*
** Checks if the location for a area is valid.
**
** @param radius: the radius in meters
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
bool isAreaLocValid(float radius = 0.0, float angle = 0.0, int player = 0) {
	float tolX = rmXMetersToFraction(areaBlobSize);
	float tolZ = rmZMetersToFraction(areaBlobSize);

	float x = getXFromPolarForPlayer(player, rmXMetersToFraction(radius), angle);
	float z = getZFromPolarForPlayer(player, rmZMetersToFraction(radius), angle);

	return(isLocValid(x, z, tolX, tolZ));
}

/*
** Creates blob areas for area according to given settings.
**
** @param numBlobs: the number of blobs to create areas for
** @param areaID: the template for area IDs (will have appended " " + i during the loop)
** @param paintTerrain: whether to paint the area or not
** @param addToClass: whether to add the area to the area class
** @param avoidSelf: whether to apply the constraint for self-avoidance
*/
void createAreaBlobAreas(int numBlobs = 0, string areaID = "", bool paintTerrain = false, bool addToClass = false, bool avoidSelf = true) {
	for(i = 0; < numBlobs) {
		int blobID = rmCreateArea(areaID + " " + i);

		// Add to class.
		if(addToClass) {
			rmAddAreaToClass(blobID, classFakeArea);
		}

		// Add type.
		if(paintTerrain) {
			// Normal blob.
			if(areaWaterType != "") {
				rmSetAreaWaterType(blobID, areaWaterType);
			} else if (areaTerrainType != "") {
				rmSetAreaTerrainType(blobID, areaTerrainType);
			}
		}

		// Set other properties.
		if(areaHeight != INF) {
			rmSetAreaBaseHeight(blobID, areaHeight);
		}

		if(areaHeightBlend != -1) {
			rmSetAreaHeightBlend(blobID, areaHeightBlend);
		}

		if(areaSmoothDistance != -1) {
			rmSetAreaSmoothDistance(blobID, areaSmoothDistance);
		}

		if(paintTerrain == false || areaEnforceConstraints) {
			// Apply constraints for fake blob or if enforced.
			for(c = 0; < areaConstraintCount) {
				rmAddAreaConstraint(blobID, getAreaConstraint(c));
			}
		}

		// Avoid self if exists.
		if(avoidSelf && areaAvoidSelfID >= 0) {
			rmAddAreaConstraint(blobID, areaAvoidSelfID);
		}
	}
}

/*
** Attempts to randomly place and build a area from a previously built random shape.
**
** @param numBlobs: the number of blobs to create
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
**
** @returns: true if the area has been built successfully, false otherwise
*/
bool buildAreaShape(int numBlobs = 0, int player = 0) {
	// Increase the counter here already because we may return early.
	areaBlobCount++;

	// Create fake blobs.
	createAreaBlobAreas(numBlobs, cFakeAreaString + " " + areaBlobCount);

	// Randomize angle and radius.
	float radius = getAreaLocRadius();
	float angle = randRadian();

	int numTries = 0;

	while(isAreaLocValid(radius, angle, player) == false && numTries < 100) {
		radius = getAreaLocRadius();
		angle = randRadian();
		numTries++;
	}

	if(numTries >= 100) {
		return(false);
	}

	placeRandomShape(radius, angle, cFakeAreaString + " " + areaBlobCount, areaBlobSize, areaBlobSpacing, player);

	// Check how many we can build successfully.
	int numBuilt = 0;

	for(i = 0; < numBlobs) {
		if(rmBuildArea(rmAreaID(cFakeAreaString + " " + areaBlobCount + " " + i))) {
			numBuilt++;
		} else {
			setBlobForRemoval(i - numBuilt, numBuilt);
		}
	}

	// Return false in case we failed to build the required ratio of blobs.
	if(numBuilt < areaBlobRequiredRatio * numBlobs) {
		return(false);
	}

	// Remove unbuilt blobs if we ended up in a valid state.
	for(i = 0; < numBlobs - numBuilt) {
		removeFullBlob(getBlobForRemoval(i));
	}

	// Define two areas of blobs, the original one and the mirrored one.
	for(i = 0; < 2) {
		createAreaBlobAreas(numBuilt, cAreaBlobString + " " + areaBlobCount + " " + i, true, true, false);
	}

	// Place the two previously generated areas.
	placeRandomShapeMirrored(radius, angle, cAreaBlobString + " " + areaBlobCount, areaBlobSize, areaBlobSpacing, player);

	rmBuildAllAreas();

	return(true);
}

/*
** Attempts to build a number of mirrored areas based on the defined parameters and arguments given.
**
** If you need more customized support, feel free to use this and the above function as a template and adjust them to your needs (or provide your own).
**
** @param numAreas: the number of areas to build
** @param prog: advances the progress bar by a fraction of the specified value for every area placed; if using this, make sure you use progress() instead of rmSetStatusText()
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
** @param numTries: number of attempts to place the desired amount of areas (default 250)
**
** @returns: the number of areas built (and mirrored) successfully
*/
int buildAreas(int numAreas = 0, float prog = 0.0, int player = 0, int numTries = 250) {
	int numBuilt = 0;

	// Prepare first iteration.
	int numBlobs = rmRandInt(areaMinBlobs, areaMaxBlobs);
	float coherence = rmRandInt(areaMinCoherence, areaMaxCoherence);

	// Build a random shape.
	createRandomShape(numBlobs, coherence);

	for(i = 0; < numTries) {
		if(buildAreaShape(numBlobs, player) == false) {
			continue;
		}

		numBuilt++;
		addProgress(prog / numAreas);

		if(numBuilt >= numAreas) {
			break;
		}

		// Prepare for next iteration.
		numBlobs = rmRandInt(areaMinBlobs, areaMaxBlobs);
		coherence = rmRandInt(areaMinCoherence, areaMaxCoherence);

		createRandomShape(numBlobs, coherence);
	}

	return(numBuilt);
}

/*
** Attempts to build a given number of mirrored areas around every player according to the previously specified parameters.
** The function iterates over the number of players in the team and places an area for every player and their mirrored counterpart.
**
** If it should ever be necessary to verify how many areas very successfully built and for which pair of players, make a custom version of this function
** along with a data structure to store the return result of buildAreas().
**
** @param numAreas: the number of areas to build
** @param prog: advances the progress bar by a fraction of the specified value for every area placed; if using this, make sure you use progress() instead of rmSetStatusText()
** @param numTries: number of attempts to place the desired amount of areas (default 250)
**
** @returns: the number of areas built (and mirrored) successfully
*/
int buildPlayerAreas(int numAreas = 0, float prog = 0.0, int numTries = 250) {
	int numBuilt = 0;
	int numPlayers = getNumberPlayersOnTeam(0);

	prog = prog / numPlayers;

	for(i = 1; <= numPlayers) {
		if(randChance(0.5)) {
			numBuilt = numBuilt + buildAreas(numAreas, prog, i, numTries);
		} else {
			numBuilt = numBuilt + buildAreas(numAreas, prog, getMirroredPlayer(i), numTries);
		}
	}

	return(numBuilt);
}

/*
** Utility function to create a single mirrored area based on the specified parameters at a given location.
** Note that this function does not check if a minimum number of blobs can be built and tries to place the areas directly.
**
** @param radius: the radius in meters
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
void buildMirroredAreaAtLocation(float radius = 0.0, float angle = 0.0, int player = 0) {
	areaBlobCount++;

	// Randomize blobs and coherence.
	int numBlobs = rmRandInt(areaMinBlobs, areaMaxBlobs);
	float coherence = rmRandInt(areaMinCoherence, areaMaxCoherence);

	// Build a random shape.
	createRandomShape(numBlobs, coherence);

	// Define two areas of blobs, the original one and the mirrored one.
	for(i = 0; < 2) {
		createAreaBlobAreas(numBlobs, cAreaBlobString + " " + areaBlobCount + " " + i, true, true, false);
	}

	// Place the two previously generated areas.
	placeRandomShapeMirrored(radius, angle, cAreaBlobString + " " + areaBlobCount, areaBlobSize, areaBlobSpacing, player);

	rmBuildAllAreas();
}

/*
** Default mirrored forest generation.
** RebelsRising
** Last edit: 07/03/2021
*/

// include "rmx_areas.xs";

/************
* CONSTANTS *
************/

const string cForestClassString = "rmx forest class";

const string cForestString = "rmx forest";
const string cFakeForestString = "rmx fake forest";

/**************
* CONSTRAINTS *
**************/

// Forest constraints.
int forestConstraintCount = 0;

int forestConstraint0 = 0; int forestConstraint1 = 0; int forestConstraint2  = 0; int forestConstraint3  = 0;
int forestConstraint4 = 0; int forestConstraint5 = 0; int forestConstraint6  = 0; int forestConstraint7  = 0;
int forestConstraint8 = 0; int forestConstraint9 = 0; int forestConstraint10 = 0; int forestConstraint11 = 0;

int getForestConstraint(int i = 0) {
	if(i == 0) return(forestConstraint0); if(i == 1) return(forestConstraint1); if(i == 2)  return(forestConstraint2);  if(i == 3)  return(forestConstraint3);
	if(i == 4) return(forestConstraint4); if(i == 5) return(forestConstraint5); if(i == 6)  return(forestConstraint6);  if(i == 7)  return(forestConstraint7);
	if(i == 8) return(forestConstraint8); if(i == 9) return(forestConstraint9); if(i == 10) return(forestConstraint10); if(i == 11) return(forestConstraint11);
	return(0);
}

void setForestConstraint(int i = 0, int cID = 0) {
	if(i == 0) forestConstraint0 = cID; if(i == 1) forestConstraint1 = cID; if(i == 2)  forestConstraint2  = cID; if(i == 3)  forestConstraint3  = cID;
	if(i == 4) forestConstraint4 = cID; if(i == 5) forestConstraint5 = cID; if(i == 6)  forestConstraint6  = cID; if(i == 7)  forestConstraint7  = cID;
	if(i == 8) forestConstraint8 = cID; if(i == 9) forestConstraint9 = cID; if(i == 10) forestConstraint10 = cID; if(i == 11) forestConstraint11 = cID;
}

/*
** Resets forest constraints.
*/
void resetForestConstraints() {
	forestConstraintCount = 0;
}

/*
** Adds a constraint to the forest constraints.
** Note that these should NOT include constraints that makes forests avoid themselves or buildForests() won't work properly!
**
** @param cID: the ID of the constraint
*/
void addForestConstraint(int cID = 0) {
	setForestConstraint(forestConstraintCount, cID);

	forestConstraintCount++;
}

/********
* TYPES *
********/

// Forest types.
int forestTypeCount = 0;

string forestType0 = ""; string forestType1 = ""; string forestType2  = ""; string forestType3  = "";
string forestType4 = ""; string forestType5 = ""; string forestType6  = ""; string forestType7  = "";
string forestType8 = ""; string forestType9 = ""; string forestType10 = ""; string forestType11 = "";

string getForestType(int i = 0) {
	if(i == 0) return(forestType0); if(i == 1) return(forestType1); if(i == 2)  return(forestType2);  if(i == 3)  return(forestType3);
	if(i == 4) return(forestType4); if(i == 5) return(forestType5); if(i == 6)  return(forestType6);  if(i == 7)  return(forestType7);
	if(i == 8) return(forestType8); if(i == 9) return(forestType9); if(i == 10) return(forestType10); if(i == 11) return(forestType11);
	return("");
}

void setForestType(int i = 0, string type = "") {
	if(i == 0) forestType0 = type; if(i == 1) forestType1 = type; if(i == 2)  forestType2  = type; if(i == 3)  forestType3  = type;
	if(i == 4) forestType4 = type; if(i == 5) forestType5 = type; if(i == 6)  forestType6  = type; if(i == 7)  forestType7  = type;
	if(i == 8) forestType8 = type; if(i == 9) forestType9 = type; if(i == 10) forestType10 = type; if(i == 11) forestType11 = type;
}

// Forest type chance.
float forestTotalChance = 0.0;

float forestTypeChance0 = 0.0; float forestTypeChance1 = 0.0; float forestTypeChance2  = 0.0; float forestTypeChance3  = 0.0;
float forestTypeChance4 = 0.0; float forestTypeChance5 = 0.0; float forestTypeChance6  = 0.0; float forestTypeChance7  = 0.0;
float forestTypeChance8 = 0.0; float forestTypeChance9 = 0.0; float forestTypeChance10 = 0.0; float forestTypeChance11 = 0.0;

float getForestTypeChance(int i = 0) {
	if(i == 0) return(forestTypeChance0); if(i == 1) return(forestTypeChance1); if(i == 2)  return(forestTypeChance2);  if(i == 3)  return(forestTypeChance3);
	if(i == 4) return(forestTypeChance4); if(i == 5) return(forestTypeChance5); if(i == 6)  return(forestTypeChance6);  if(i == 7)  return(forestTypeChance7);
	if(i == 8) return(forestTypeChance8); if(i == 9) return(forestTypeChance9); if(i == 10) return(forestTypeChance10); if(i == 11) return(forestTypeChance11);
	return(0.0);
}

void setForestTypeChance(int i = 0, float chance = 0.0) {
	if(i == 0) forestTypeChance0 = chance; if(i == 1) forestTypeChance1 = chance; if(i == 2)  forestTypeChance2  = chance; if(i == 3)  forestTypeChance3  = chance;
	if(i == 4) forestTypeChance4 = chance; if(i == 5) forestTypeChance5 = chance; if(i == 6)  forestTypeChance6  = chance; if(i == 7)  forestTypeChance7  = chance;
	if(i == 8) forestTypeChance8 = chance; if(i == 9) forestTypeChance9 = chance; if(i == 10) forestTypeChance10 = chance; if(i == 11) forestTypeChance11 = chance;
}

/*
** Adds a type and the chance to randomize that type to the array of forest types.
**
** @param type: the forest type as string
** @param chance: chance to randomize the forest type in [0, 1]
*/
void addForestType(string type = "", float chance = 0.0) {
	setForestType(forestTypeCount, type);
	setForestTypeChance(forestTypeCount, chance);
	forestTotalChance = forestTotalChance + chance;

	forestTypeCount++;
}

/*
** Resets forest types.
*/
void resetForestTypes() {
	forestTypeCount = 0;
	forestTotalChance = 0.0;
}

/*************
* PARAMETERS *
*************/

// Used to keep track of the forest class (if we need multiple classes).
int forestClassCount = -1;

// Counter for the number of areas so we don't run out of names.
int forestAreaCount = -1; // -1 since we increment before using the value.

// Default settings.
int classFakeForest = -1; // Set by initForestClass().

int forestMinBlobs = 0;
int forestMaxBlobs = 0;

float forestBlobSize = 0.0;
float forestBlobSpacing = 0.0;
float forestBlobRequiredRatio = 0.5;

float forestMinCoherence = -1.0;
float forestMaxCoherence = 1.0;

float forestMinRadius = 20.0;
float forestMaxRadius = -1.0;

// Constraint for self avoidance.
int forestAvoidSelfID = -1;

// Other properties.
float forestHeight = INF;
int forestSmoothDistance = -1;
int forestHeightBlend = -1;

/*
** Sets a constraint for forests to avoid themselves.
** This is necessary because real forest blobs won't spawn if they have this constraint applied when being built.
**
** @param dist: distance in meters for forests to avoid each other
*/
void setForestAvoidSelf(float dist = 0.0) {
	if(dist > 0.0) {
		forestAvoidSelfID = createClassDistConstraint(classFakeForest, dist);
	} else {
		forestAvoidSelfID = -1;
	}
}

/*
** Sets a minimum and maximum number of blobs for the forests.
**
** @param minBlobs: minimum number of blobs
** @param maxBlobs: maximum number of blobs, will be adjusted to minBlobs if not set
*/
void setForestBlobs(int minBlobs = 0, int maxBlobs = -1) {
	if(maxBlobs < 0) {
		maxBlobs = minBlobs;
	}

	forestMinBlobs = minBlobs;
	forestMaxBlobs = maxBlobs;
}

/*
** Sets blob settings.
**
** @param blobSize: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
*/
void setForestBlobParams(float blobSize = 0.0, float blobSpacing = 0.0) {
	forestBlobSize = blobSize;
	forestBlobSpacing = blobSpacing;
}

/*
** Sets additional parameters for the areas.
**
** @param height: the area height
** @param heightBlend: the hight blend parameter (0, 1 or 2) for areas
** @param smoothDistance: the smooth distance for areas
*/
void setForestParams(float height = INF, int heightBlend = -1, int smoothDistance = -1) {
	forestHeight = height;
	forestSmoothDistance = smoothDistance;
	forestHeightBlend = heightBlend;
}

/*
** Sets the required ratio for an area to be built.
**
** @param requiredRatio: the minimum ratio of blobs successfully built required to build the entire area
*/
void setForestMinRatio(float requiredRatio = 0.5) {
	forestBlobRequiredRatio = requiredRatio;
}

/*
** Sets a minimum and maximum coherence (compactness) for forests to randomize from.
**
** @param minCoherence: mimumum coherence (smallest possible value: -1.0), linear areas
** @param maxCoherence: maximum coherence (largest possible value: 1.0), circular areas
*/
void setForestCoherence(float minCoherence = -1.0, float maxCoherence = 1.0) {
	forestMinCoherence = minCoherence;
	forestMaxCoherence = maxCoherence;
}

/*
** Sets a minimum and maximum radius in meters to consider when placing forests.
** Note that the default of -1.0 will be overwritten with the radius from the center to the corner at forest generation time.
**
** @param minRadius: minimum radius in meters to randomize
** @param maxRadius: maximum radius in meters to randomize (-1.0 = up to corners)
*/
void setForestSearchRadius(float minRadius = 20.0, float maxRadius = -1.0) {
	forestMinRadius = minRadius;
	forestMaxRadius = maxRadius;
}

/*
** Resets forest settings (types, constraints, and search radius).
*/
void resetForests() {
	classFakeForest = -1;

	resetForestConstraints();
	resetForestTypes();

	setForestBlobs();
	setForestBlobParams();
	setForestParams();
	setForestCoherence();
	setForestSearchRadius();
	setForestAvoidSelf();
	setForestMinRatio();
}

/********************
* FOREST GENERATION *
********************/

/*
** Initializes the cliff class.
**
** @param altClass: use an existing class for the ponds instead of a new one if set
**
** @returns: the ID of the created class (can be used to set constraints!)
*/
int initForestClass(int clazz = -1) {
	if(clazz == -1) {
		classFakeForest = rmDefineClass(cForestClassString + " " + forestClassCount);
		forestClassCount++;
	} else {
		classFakeForest = clazz;
	}

	return(classFakeForest);
}

/*
** Randomizes a radius while considering a forestMaxRadius of -1.0.
**
** @returns: the randomized forest radius in meters
*/
float getForestLocRadius() {
	// Adjust maximum radius if necessary (i.e., set to < 0).
	if(forestMaxRadius < 0) {
		forestMaxRadius = largerFractionToMeters(HALF_SQRT_2);
	}

	// Consider using randLargeFloat here instead.
	return(rmRandFloat(forestMinRadius, forestMaxRadius));
}

/*
** Checks if the location for a forest is valid.
**
** @param radius: the radius in meters
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
bool isForestLocValid(float radius = 0.0, float angle = 0.0, int player = 0) {
	// Allow origin of a forest to be slightly outside of the map for more variability.
	float tolX = rmXMetersToFraction(0.0 - forestBlobSize);
	float tolZ = rmZMetersToFraction(0.0 - forestBlobSize);

	float x = getXFromPolarForPlayer(player, rmXMetersToFraction(radius), angle);
	float z = getZFromPolarForPlayer(player, rmZMetersToFraction(radius), angle);

	return(isLocValid(x, z, tolX, tolZ));
}

/*
** Randomizes the forest time according the set forest types and chances.
**
** @returns: the randomized forest type
*/
string randomizeForestType() {
	// Determine forest type.
	float forestChance = rmRandFloat(0.0, forestTotalChance);
	string forestType = getForestType(0);
	float summedProbabilities = getForestTypeChance(0);

	for(i = 1; < forestTypeCount) {
		if(summedProbabilities >= forestChance) {
			forestType = getForestType(i);
			break;
		}

		summedProbabilities = summedProbabilities + getForestTypeChance(i);
	}

	return(forestType);
}

/*
** Creates blob areas for forest according to given settings.
**
** @param numBlobs: the number of blobs to create areas for
** @param areaID: the template for area IDs (will have appended " " + i during the loop)
** @param paintTerrain: whether to paint the area or not
** @param addToClass: whether to add the area to the forest class
** @param avoidSelf: whether to apply the constraint for self-avoidance
*/
void createForestBlobAreas(int numBlobs = 0, string areaID = "", bool paintTerrain = false, bool addToClass = false, bool avoidSelf = true) {
	string type = randomizeForestType();

	for(i = 0; < numBlobs) {
		int blobID = rmCreateArea(areaID + " " + i);

		/*
		 * Applying constraints to all blobs, fake and normal ones, affects the placement as follows:
		 * Due to constraints in the fake blobs, it is possible that they get built, but not as perfect circles.
		 * This is due to the game engine trying to reach the minimum tile count for an area if it's constrained/placed on the edge.
		 * Unfortunately, this means that the area is still built, but not as circle and will cause the fake blob to remain in the shape.
		 * This is one of the reasons why we sometimes see imperfect forests.
		*/
		for(c = 0; < forestConstraintCount) {
			rmAddAreaConstraint(blobID, getForestConstraint(c));
		}

		// Add to class.
		if(addToClass) {
			rmAddAreaToClass(blobID, classFakeForest);
		}

		// Add forest type.
		if(paintTerrain) {
			rmSetAreaForestType(blobID, type);
		}

		// Set other properties.
		if(forestHeight != INF) {
			rmSetAreaBaseHeight(blobID, forestHeight);
		}

		if(forestHeightBlend != -1) {
			rmSetAreaHeightBlend(blobID, forestHeightBlend);
		}

		if(forestSmoothDistance != -1) {
			rmSetAreaSmoothDistance(blobID, forestSmoothDistance);
		}

		// Avoid self if exists.
		if(avoidSelf && forestAvoidSelfID >= 0) {
			rmAddAreaConstraint(blobID, forestAvoidSelfID);
		}
	}
}

/*
** Attempts to randomly place and build a forest from a previously built random shape.
**
** @param numBlobs: the number of blobs to create
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
**
** @returns: true if the forest has been built successfully, false otherwise
*/
bool buildForestShape(int numBlobs = 0, int player = 0) {
	// Increase the counter here already because we may return early.
	forestAreaCount++;

	// Create fake blobs.
	createForestBlobAreas(numBlobs, cFakeForestString + " " + forestAreaCount);

	// Randomize angle and radius.
	float radius = getForestLocRadius();
	float angle = randRadian();

	int numTries = 0;

	while(isForestLocValid(radius, angle, player) == false && numTries < 100) {
		radius = getForestLocRadius();
		angle = randRadian();
		numTries++;
	}

	if(numTries >= 100) {
		return(false);
	}

	placeRandomShape(radius, angle, cFakeForestString + " " + forestAreaCount, forestBlobSize, forestBlobSpacing, player);

	// Check how many we can build successfully.
	int numBuilt = 0;

	for(i = 0; < numBlobs) {
		if(rmBuildArea(rmAreaID(cFakeForestString + " " + forestAreaCount + " " + i))) {
			numBuilt++;
		} else {
			setBlobForRemoval(i - numBuilt, numBuilt);
		}
	}

	// Return false in case we failed to build the required ratio of blobs.
	if(numBuilt < forestBlobRequiredRatio * numBlobs) {
		return(false);
	}

	// Remove unbuilt blobs if we ended up in a valid state.
	for(i = 0; < numBlobs - numBuilt) {
		removeFullBlob(getBlobForRemoval(i));
	}

	// Define two areas of blobs, the original one and the mirrored one.
	for(i = 0; < 2) {
		createForestBlobAreas(numBuilt, cForestString + " " + forestAreaCount + " " + i, true, true, false);
	}

	// Place the two previously generated areas.
	placeRandomShapeMirrored(radius, angle, cForestString + " " + forestAreaCount, forestBlobSize, forestBlobSpacing, player);

	rmBuildAllAreas();

	return(true);
}

/*
** Attempts to build a number of forests (mirrored) based on the defined parameters and arguments given.
**
** If you need more customized support, feel free to use this and the above function as a template and adjust them to your needs (or provide your own).
**
** @param numForests: the number of forests to build
** @param prog: advances the progress bar by a fraction of the specified value for every forest placed; only keeps the value if progress() was used to advance the bar prior
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
** @param numTries: number of attempts to place the desired amount of forests (default 250)
**
** @returns: the number of forests built (and mirrored) successfully
*/
int buildForests(int numForests = 0, float prog = 0.0, int player = 0, int numTries = 250) {
	int numBuilt = 0;

	// Prepare first iteration.
	int numBlobs = rmRandInt(forestMinBlobs, forestMaxBlobs);
	float coherence = rmRandInt(forestMinCoherence, forestMaxCoherence);

	// Build a random shape.
	createRandomShape(numBlobs, coherence);

	for(i = 0; < numTries) {
		if(buildForestShape(numBlobs, player) == false) {
			continue;
		}

		numBuilt++;
		addProgress(prog / numForests);

		if(numBuilt >= numForests) {
			break;
		}

		// Prepare for next iteration.
		numBlobs = rmRandInt(forestMinBlobs, forestMaxBlobs);
		coherence = rmRandInt(forestMinCoherence, forestMaxCoherence);

		createRandomShape(numBlobs, coherence);
	}

	return(numBuilt);
}

/*
** Attempts to build a given number of forests around every player according to the previously specified parameters.
** The function iterates over the number of players in the team and places a forest for every player and its mirrored counterpart.
**
** If it should ever be necessary to verify how many forests very successfully built and for which pair of players, make a custom version of this function
** along with a data structure to store the return result of buildForests().
**
** @param numForests: the number of forests to build
** @param prog: advances the progress bar by a fraction of the specified value for every forest placed; only keeps the value if progress() was used to advance the bar prior
** @param numTries: number of attempts to place the desired amount of forests (default 250)
**
** @returns: the number of forests built (and mirrored) successfully
*/
int buildPlayerForests(int numForests = 0, float prog = 0.0, int numTries = 250) {
	int numBuilt = 0;
	int numPlayers = getNumberPlayersOnTeam(0);

	prog = prog / numPlayers;

	for(i = 1; <= numPlayers) {
		if(randChance(0.5)) {
			numBuilt = numBuilt + buildForests(numForests, prog, i);
		} else {
			numBuilt = numBuilt + buildForests(numForests, prog, getMirroredPlayer(i));
		}
	}

	return(numBuilt);
}

/*
** Utility function to create a single mirrored forest based on the specified parameters at a given location.
** Note that this function does not check if a minimum number of blobs can be built and tries to place the areas directly.
**
** @param radius: the radius from the center in meters
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
void buildMirroredForestAtLocation(float radius = 0.0, float angle = 0.0, int player = 0) {
	forestAreaCount++;

	// Randomize blobs and coherence.
	int numBlobs = rmRandInt(forestMinBlobs, forestMaxBlobs);
	float coherence = rmRandInt(forestMinCoherence, forestMaxCoherence);

	// Build a random shape.
	createRandomShape(numBlobs, coherence);

	// Define two areas of blobs, the original one and the mirrored one.
	for(i = 0; < 2) {
		createForestBlobAreas(numBlobs, cForestString + " " + forestAreaCount + " " + i, true, true, false);
	}

	// Place the two previously generated areas.
	placeRandomShapeMirrored(radius, angle, cForestString + " " + forestAreaCount, forestBlobSize, forestBlobSpacing, player);

	rmBuildAllAreas();
}

/*
** Default mirrored cliff generation.
** RebelsRising
** Last edit: 07/03/2021
*/

// include "rmx_forests.xs";

/************
* CONSTANTS *
************/

const string cCliffClassString = "rmx cliff class";

const string cInnerCliffString = "rmx inner cliff";
const string cOuterCliffString = "rmx outer cliff";
const string cRampCliffString = "rmx ramp cliff";
const string cFakeCliffString = "rmx fake cliff";

const int cCliffTypeFake = -1;
const int cCliffTypeInner = 0;
const int cCliffTypeOuter = 1;
const int cCliffTypeRamp = 2;

/********
* RAMPS *
********/

// Near blobs for ramp ID list.
int rampListSize = 0;

int rampID0 = 0; int rampID1 = 0; int rampID2  = 0; int rampID3  = 0;
int rampID4 = 0; int rampID5 = 0; int rampID6  = 0; int rampID7  = 0;
int rampID8 = 0; int rampID9 = 0; int rampID10 = 0; int rampID11 = 0;

int getRampID(int i = -1) {
	if(i == 0) return(rampID0); if(i == 1) return(rampID1); if(i == 2)  return(rampID2);  if(i == 3)  return(rampID3);
	if(i == 4) return(rampID4); if(i == 5) return(rampID5); if(i == 6)  return(rampID6);  if(i == 7)  return(rampID7);
	if(i == 8) return(rampID8); if(i == 9) return(rampID9); if(i == 10) return(rampID10); if(i == 11) return(rampID11);
	return(0);
}

void setRampID(int i = 0, int id = 0) {
	if(i == 0) rampID0 = id; if(i == 1) rampID1 = id; if(i == 2)  rampID2  = id; if(i == 3)  rampID3  = id;
	if(i == 4) rampID4 = id; if(i == 5) rampID5 = id; if(i == 6)  rampID6  = id; if(i == 7)  rampID7  = id;
	if(i == 8) rampID8 = id; if(i == 9) rampID9 = id; if(i == 10) rampID10 = id; if(i == 11) rampID11 = id;
}

/*
** Calculates one of the possible adjacent blobs.
** This is important for ramps as we need 2 blobs to form a ramp - 1 may not grant access if we have a corner blob.
**
** @param currX: the x value (on the shape grid!) of the blob to find the next blob for
** @param currZ: the z value (on the shape grid!) of the blob to find the next blob for
**
** @returns: the ID of the chosen blob
*/
int getNextBlobID(int currX = 0, int currZ = 0) {
	float shortest = INF;
	int blobID = -1;

	// Go through the entire list of near blobs.
	for(i = 0; < getStateSize(cBlobNear)) {
		int nextX = getBlobX(i, cBlobNear);
		int nextZ = getBlobZ(i, cBlobNear);

		if(nextX == currX && nextZ == currZ) {
			continue; // Skip current.
		}

		// Calculate the distance between the current blob and the potential neighbor.
		float dist = pointsGetDist(currX, currZ, nextX, nextZ);

		// Keep the blob if it's closest to the current blob.
		if(abs(dist - shortest) < TOL) {

			// Same distance as the blob currently selected (blobID), pick the one that is further away to catch corner blobs.
			if(pointsGetDist(nextX, nextZ, 0.0, 0.0) > pointsGetDist(getBlobX(blobID, cBlobNear), getBlobZ(blobID, cBlobNear), 0.0, 0.0)) {
				blobID = i;
			}

		} else if(dist < shortest) {

			shortest = dist;
			blobID = i;

		}
	}

	return(blobID);
}

/*
** Tries to add a new ramp ID (near blob) to the list.
** The ID must not be already present and pass the check for not being too close (angle) to the IDs already in the list.
**
** @param rampID: the ID of the near blob that should be added
** @param minAngle: the minimum angle the blob must be away from all other blobs in the list
**
** @returns: true on success, false otherwise
*/
bool addRampToList(int rampID = -1, float minAngle = 0.0) {
	float blobX = getBlobX(rampID, cBlobNear);
	float blobZ = getBlobZ(rampID, cBlobNear);
	float blobAngle = getAngleFromCartesian(blobX, blobZ, 0.0, 0.0);

	for(i = 0; < rampListSize) {
		int currID = getRampID(i);

		// Return early if the ID is already in the list.
		if(rampID == currID) {
			return(false);
		}

		// Cet the current angle.
		float currX = getBlobX(currID, cBlobNear);
		float currZ = getBlobZ(currID, cBlobNear);
		float currAngle = getAngleFromCartesian(currX, currZ, 0.0, 0.0);

		float diff = 0.0;

		// Calculate the difference of the angles depending on which angle comes "first".
		if(currAngle < blobAngle) {
			// currAngle first.
			diff = min(blobAngle - currAngle, 2.0 * PI - (blobAngle - currAngle));
		} else {
			// blobAngle first.
			diff = min(currAngle - blobAngle, 2.0 * PI - (currAngle - blobAngle));
		}

		if(diff < minAngle) {
			return(false);
		}
	}

	// Succeeded.
	setRampID(rampListSize, rampID);
	rampListSize++;

	/*
	 * Also add close blob to it so that the ramps will always grant access.
	 * Otherwise we may end up with a single corner blob.
	 * Note that this blob will not adhere to the angle restrictions set above.
	*/
	setRampID(rampListSize, getNextBlobID(blobX, blobZ));
	rampListSize++;

	return(true);
}

/*
** Resets the list of ramp IDs.
** Note that this does not reset the IDs as they are only being read if they were rewritten since this function was called last.
*/
void resetRampList() {
	rampListSize = 0;
}

/**************
* CONSTRAINTS *
**************/

// Cliff constraints.
int cliffConstraintCount = 0;

int cliffConstraint0 = 0; int cliffConstraint1 = 0; int cliffConstraint2  = 0; int cliffConstraint3  = 0;
int cliffConstraint4 = 0; int cliffConstraint5 = 0; int cliffConstraint6  = 0; int cliffConstraint7  = 0;
int cliffConstraint8 = 0; int cliffConstraint9 = 0; int cliffConstraint10 = 0; int cliffConstraint11 = 0;

int getCliffConstraint(int i = 0) {
	if(i == 0) return(cliffConstraint0); if(i == 1) return(cliffConstraint1); if(i == 2)  return(cliffConstraint2);  if(i == 3)  return(cliffConstraint3);
	if(i == 4) return(cliffConstraint4); if(i == 5) return(cliffConstraint5); if(i == 6)  return(cliffConstraint6);  if(i == 7)  return(cliffConstraint7);
	if(i == 8) return(cliffConstraint8); if(i == 9) return(cliffConstraint9); if(i == 10) return(cliffConstraint10); if(i == 11) return(cliffConstraint11);
	return(0);
}

void setCliffConstraint(int i = 0, int cID = 0) {
	if(i == 0) cliffConstraint0 = cID; if(i == 1) cliffConstraint1 = cID; if(i == 2)  cliffConstraint2  = cID; if(i == 3)  cliffConstraint3  = cID;
	if(i == 4) cliffConstraint4 = cID; if(i == 5) cliffConstraint5 = cID; if(i == 6)  cliffConstraint6  = cID; if(i == 7)  cliffConstraint7  = cID;
	if(i == 8) cliffConstraint8 = cID; if(i == 9) cliffConstraint9 = cID; if(i == 10) cliffConstraint10 = cID; if(i == 11) cliffConstraint11 = cID;
}

/*
** Resets cliff constraints.
*/
void resetCliffConstraints() {
	cliffConstraintCount = 0;
}

/*
** Adds a constraint to the cliff constraints.
** Note that these should NOT include constraints that makes cliffs avoid themselves or the behavior of the algorithm is undefined!
**
** @param cID: the ID of the constraint
*/
void addCliffConstraint(int cID = 0) {
	setCliffConstraint(cliffConstraintCount, cID);

	cliffConstraintCount++;
}

/*************
* PARAMETERS *
*************/

// Settings for outer cliffs.
string outerTerrainType = "";
float outerBlobSize = 0.0;
float outerBlobSpacing = 0.0;

float outerHeight = INF;
int outerSmoothDistance = -1;
int outerHeightBlend = -1;

/*
** Sets the parameters for the outer part of the cliffs.
**
** @param terrainType: the terrain to use (can also be impassable terrain like CliffEgyptianA)
** @param blobSize: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
*/
void setOuterCliff(string terrainType = "", float blobSize = 0.0, float blobSpacing = 0.0) {
	outerTerrainType = terrainType;
	outerBlobSize = blobSize;
	outerBlobSpacing = blobSpacing;
}

/*
** Sets additional parameters for outer cliffs.
**
** @param height: the area height
** @param heightBlend: the hight blend parameter (0, 1 or 2) for areas
** @param smoothDistance: the smooth distance for areas
*/
void setOuterCliffParams(float height = INF, int heightBlend = -1, int smoothDistance = -1) {
	outerHeight = height;
	outerSmoothDistance = smoothDistance;
	outerHeightBlend = heightBlend;
}

// Settings for inner cliffs.
string innerTerrainType = "";
float innerBlobSize = 0.0;
float innerBlobSpacing = 0.0;
string innerCliffType = "";

float innerHeight = INF;
int innerSmoothDistance = -1;
int innerHeightBlend = -1;

/*
** Sets the parameters for the inner part of the cliffs.
** Has the cliffType as optional argument since the first
**
** @param terrainType: the terrain to use (can also be impassable terrain like CliffEgyptianA)
** @param blobSize: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
** @param cliffType: sets the cliff type; this will use rmSetAreaCliffType() instead of just a regular area, should be used if no outer cliff is needed
*/
void setInnerCliff(string terrainType = "", float blobSize = 0.0, float blobSpacing = 0.0, string cliffType = "") {
	innerTerrainType = terrainType;
	innerBlobSize = blobSize;
	innerBlobSpacing = blobSpacing;
	innerCliffType = cliffType;
}

/*
** Sets additional parameters for inner cliffs.
**
** @param height: the area height
** @param heightBlend: the hight blend parameter (0, 1 or 2) for areas
** @param smoothDistance: the smooth distance for areas
*/
void setInnerCliffParams(float height = INF, int heightBlend = -1, int smoothDistance = -1) {
	innerHeight = height;
	innerSmoothDistance = smoothDistance;
	innerHeightBlend = heightBlend;
}

// Settings for ramps.
string rampTerrainType = "";
float rampBlobSize = 0.0;
float rampBlobSpacing = 0.0;

float rampHeight = INF;
int rampSmoothDistance = -1;
int rampHeightBlend = -1;

/*
** Sets the parameters for ramps.
**
** @param terrainType: the terrain to use (can also be impassable terrain like CliffEgyptianA)
** @param blobSize: the radius of the blob in meters
** @param blobSpacing: the distance between the blobs in meters (independent of blob radius)
*/
void setCliffRamp(string terrainType = "", float blobSize = 0.0, float blobSpacing = 0.0) {
	rampTerrainType = terrainType;
	rampBlobSize = blobSize;
	rampBlobSpacing = blobSpacing;
}

/*
** Sets additional parameters for the ramps.
**
** @param height: the area height
** @param heightBlend: the hight blend parameter (0, 1 or 2) for areas
** @param smoothDistance: the smooth distance for areas
*/
void setCliffRampParams(float height = INF, int heightBlend = -1, int smoothDistance = -1) {
	rampHeight = height;
	rampSmoothDistance = smoothDistance;
	rampHeightBlend = heightBlend;
}

/*
** Getter for terrain type by cliff type.
**
** @param type: the type (one of cCliffTypeFake, cCliffTypeInner, cCliffTypeOuter, cCliffTypeRamp)
**
** @returns: the terrain type
*/
string cliffGetTerrainType(int type = cCliffTypeFake) {
	if(type == cCliffTypeInner) {
		return(innerTerrainType);
	} else if(type == cCliffTypeOuter) {
		return(outerTerrainType);
	} else if(type == cCliffTypeRamp) {
		return(rampTerrainType);
	}

	return("");
}

/*
** Getter for height by cliff type.
**
** @param type: the type (one of cCliffTypeFake, cCliffTypeInner, cCliffTypeOuter, cCliffTypeRamp)
**
** @returns: the height value
*/
float cliffGetHeight(int type = cCliffTypeFake) {
	if(type == cCliffTypeInner) {
		return(innerHeight);
	} else if(type == cCliffTypeOuter) {
		return(outerHeight);
	} else if(type == cCliffTypeRamp) {
		return(rampHeight);
	}

	return(2.0);
}

/*
** Getter for height blend by cliff type.
**
** @param type: the type (one of cCliffTypeFake, cCliffTypeInner, cCliffTypeOuter, cCliffTypeRamp)
**
** @returns: the height blend value
*/
int cliffGetHeightBlend(int type = cCliffTypeFake) {
	if(type == cCliffTypeInner) {
		return(innerHeightBlend);
	} else if(type == cCliffTypeOuter) {
		return(outerHeightBlend);
	} else if(type == cCliffTypeRamp) {
		return(rampHeightBlend);
	}

	return(0);
}

/*
** Getter for smooth distance by cliff type.
**
** @param type: the type (one of cCliffTypeFake, cCliffTypeInner, cCliffTypeOuter, cCliffTypeRamp)
**
** @returns: the smooth distance value
*/
int cliffGetSmoothDistance(int type = cCliffTypeFake) {
	if(type == cCliffTypeInner) {
		return(innerSmoothDistance);
	} else if(type == cCliffTypeOuter) {
		return(outerSmoothDistance);
	} else if(type == cCliffTypeRamp) {
		return(rampSmoothDistance);
	}

	return(0);
}

// Cliff settings.
// Used to keep track of the cliff class (if we need multiple classes).
int cliffClassCount = -1;

// Counter for the number of areas so we don't run out of names.
int cliffAreaCount = -1; // -1 since we increment before using the value.

// Default settings.
int classFakeCliff = -1; // Set by initCliffClass().

int cliffMinBlobs = 0;
int cliffMaxBlobs = 0;

int cliffMinRamps = 0;
int cliffMaxRamps = 0;

float cliffBlobRequiredRatio = 1.0;

float cliffMinCoherence = -1.0;
float cliffMaxCoherence = 1.0;

float cliffMinRadius = 20.0;
float cliffMaxRadius = -1.0;

// Constraint for self avoidance.
int cliffAvoidSelfID = -1;

// Whether to enforce constraints.
bool cliffEnforceConstraints = false;

/*
** Sets a constraint for cliffs to avoid themselves.
** This is necessary because real cliff blobs won't spawn if they have this constraint applied when being built.
**
** @param dist: distance in meters for cliffs to avoid each other
*/
void setCliffAvoidSelf(float dist = 0.0) {
	if(dist > 0.0) {
		cliffAvoidSelfID = createClassDistConstraint(classFakeCliff, dist);
	} else {
		cliffAvoidSelfID = -1;
	}
}

/*
** Can be set to either enforce constraints not just for fake blobs (at the cost of precision) or to not do so.
**
** @param enforce: true to enforce constraints, false otherwise
*/
void setCliffEnforceConstraints(bool enforce = false) {
	cliffEnforceConstraints = enforce;
}

/*
** Sets a minimum and maximum number of blobs for the cliffs.
**
** @param minBlobs: minimum number of blobs
** @param maxBlobs: maximum number of blobs, will be adjusted to minBlobs if not set
*/
void setCliffBlobs(int minBlobs = 0, int maxBlobs = -1) {
	if(maxBlobs < 0) {
		maxBlobs = minBlobs;
	}

	cliffMinBlobs = minBlobs;
	cliffMaxBlobs = maxBlobs;
}

/*
** Sets a minimum and maximum number of ramps for the cliffs.
**
** @param minRamps: minimum number of ramps
** @param maxRamps: maximum number of ramps, will be adjusted to minRamps if not set
*/
void setCliffNumRamps(int minRamps = 0, int maxRamps = -1) {
	if(maxRamps < 0) {
		maxRamps = minRamps;
	}

	cliffMinRamps = minRamps;
	cliffMaxRamps = maxRamps;
}

/*
** Sets the required ratio for an area to be built.
**
** @param requiredRatio: the minimum ratio of blobs successfully built required to build the entire area
*/
void setCliffRequiredRatio(float requiredRatio = 1.0) {
	cliffBlobRequiredRatio = requiredRatio;
}

/*
** Sets a minimum and maximum coherence (compactness) for cliffs to randomize from.
**
** @param minCoherence: mimumum coherence (smallest possible value: -1.0), linear areas
** @param maxCoherence: maximum coherence (largest possible value: 1.0), circular areas
*/
void setCliffCoherence(float minCoherence = -1.0, float maxCoherence = 1.0) {
	cliffMinCoherence = minCoherence;
	cliffMaxCoherence = maxCoherence;
}

/*
** Sets a minimum and maximum radius in meters to consider when placing cliffs.
** Note that the default of -1.0 will be overwritten with the radius from the center to the corner at cliff generation time.
**
** @param minRadius: minimum radius in meters to randomize
** @param maxRadius: maximum radius in meters to randomize (-1.0 = up to corners)
*/
void setCliffSearchRadius(float minRadius = 20.0, float maxRadius = -1.0) {
	cliffMinRadius = minRadius;
	cliffMaxRadius = maxRadius;
}

/*
** Resets cliff settings and restores defaults.
*/
void resetCliffs() {
	classFakeCliff = -1;

	resetCliffConstraints();

	setInnerCliff();
	setInnerCliffParams();
	setOuterCliff();
	setOuterCliffParams();
	setCliffRamp();
	setCliffRampParams();

	setCliffBlobs();
	setCliffCoherence();
	setCliffNumRamps();
	setCliffSearchRadius();
	setCliffAvoidSelf();
	setCliffEnforceConstraints();
	setCliffRequiredRatio();
}

/*******************
* CLIFF GENERATION *
*******************/

/*
** Initializes the cliff class.
**
** @param clazz: use an existing class for the ponds instead of a new one if set
**
** @returns: the ID of the created class (can be used to set constraints!)
*/
int initCliffClass(int clazz = -1) {
	if(clazz == -1) {
		classFakeCliff = rmDefineClass(cCliffClassString + " " + cliffClassCount);
		cliffClassCount++;
	} else {
		classFakeCliff = clazz;
	}

	return(classFakeCliff);
}

/*
** Randomizes a radius while considering a cliffMaxRadius of -1.0.
**
** @returns: the randomized cliff radius in meters
*/
float getCliffLocRadius() {
	// Adjust maximum radius if necessary (i.e., set to < 0).
	if(cliffMaxRadius < 0) {
		cliffMaxRadius = largerFractionToMeters(HALF_SQRT_2);
	}

	return(rmRandFloat(cliffMinRadius, cliffMaxRadius));
}

/*
** Checks if the location for a cliff is valid.
**
** @param radius: the radius in meters
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
bool isCliffLocValid(float radius = 0.0, float angle = 0.0, int player = 0) {
	// Require the center of the area to avoid the egde by at least the radius of the inner blob.
	float tolX = rmXMetersToFraction(innerBlobSize);
	float tolZ = rmZMetersToFraction(innerBlobSize);

	float x = getXFromPolarForPlayer(player, rmXMetersToFraction(radius), angle);
	float z = getZFromPolarForPlayer(player, rmZMetersToFraction(radius), angle);

	return(isLocValid(x, z, tolX, tolZ));
}

/*
** Places the areas for the inner part of the cliff. Both areas must be defined (normal and mirrored).
** Note that we place the near blobs here and take them as border for the cliff.
**
** @param radius: the radius in the polar coordinate system
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
void placeOuterCliffShape(float radius = 0.0, float angle = 0.0, int player = 0) {
	// Convert radius to fraction.
	radius = smallerMetersToFraction(radius);

	// Mirrored player and adjusted angle
	int mirrorPlayer = getMirroredPlayer(player);
	float mirrorAngle = getMirrorAngleForShape(angle, mirrorPlayer == 0);

	// Place original shape.
	for(i = 0; < getStateSize(cBlobNear)) {
		int x = getBlobX(i, cBlobNear);
		int z = getBlobZ(i, cBlobNear);

		// Original shape.
		placeBlob(radius, angle, rmAreaID(cOuterCliffString + " " + cliffAreaCount + " " + 0 + " " + i), outerBlobSize, outerBlobSpacing, 0.0 + x, 0.0 + z, player);

		// Mirrored shape.
		if(getMirrorMode() == cMirrorPoint) {
			placeBlob(radius, mirrorAngle, rmAreaID(cOuterCliffString + " " + cliffAreaCount + " " + 1 + " " + i), outerBlobSize, outerBlobSpacing, 0.0 + x, 0.0 + z, mirrorPlayer);
		} else {
			/*
			 * By axis requires the inversion of the z axis of the shape grid.
			 * We don't invert the x axis here because we always want the same part of the shape to point towards the inside.
			 * While this may not sound very intuitive, if you draw a shape and try to rotate it and then mirror it, it will make sense.
			*/
			placeBlob(radius, mirrorAngle, rmAreaID(cOuterCliffString + " " + cliffAreaCount + " " + 1 + " " + i), outerBlobSize, outerBlobSpacing, 0.0 + x, 0.0 - z, mirrorPlayer);
		}
	}
}

/*
** Places the areas for the inner part of the cliff. Both areas must be defined (normal and mirrored).
** Note that this uses some of the near blobs and overwrites them with textures according to the defined ramp parameters.
**
** @param numRamps: the number of ramp areas to place
** @param radius: the radius in the polar coordinate system
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
void placeRampCliffShape(int numRamps = 0, float radius = 0.0, float angle = 0.0, int player = 0) {
	// Convert radius to fraction.
	radius = smallerMetersToFraction(radius);

	// Mirrored player and adjusted angle
	int mirrorPlayer = getMirroredPlayer(player);
	float mirrorAngle = getMirrorAngleForShape(angle, mirrorPlayer == 0);

	// Place original shape.
	for(i = 0; < numRamps) {
		int x = getBlobX(getRampID(i), cBlobNear);
		int z = getBlobZ(getRampID(i), cBlobNear);

		// Original shape.
		placeBlob(radius, angle, rmAreaID(cRampCliffString + " " + cliffAreaCount + " " + 0 + " " + i), rampBlobSize, rampBlobSpacing, 0.0 + x, 0.0 + z, player);

		// Mirrored shape.
		if(getMirrorMode() == cMirrorPoint) {
			placeBlob(radius, mirrorAngle, rmAreaID(cRampCliffString + " " + cliffAreaCount + " " + 1 + " " + i), rampBlobSize, rampBlobSpacing, 0.0 + x, 0.0 + z, mirrorPlayer);
		} else {
			/*
			 * By axis requires the inversion of the z axis of the shape grid.
			 * We don't invert the x axis here because we always want the same part of the shape to point towards the inside.
			 * While this may not sound very intuitive, if you draw a shape and try to rotate it and then mirror it, it will make sense.
			*/
			placeBlob(radius, mirrorAngle, rmAreaID(cRampCliffString + " " + cliffAreaCount + " " + 1 + " " + i), rampBlobSize, rampBlobSpacing, 0.0 + x, 0.0 - z, mirrorPlayer);
		}
	}
}

/*
** Creates blob areas for cliffs according to given settings.
**
** @param numBlobs: the number of blobs to create areas for
** @param areaID: the template for area IDs (will have appended " " + i during the loop)
** @param type: the type (one of cCliffTypeFake, cCliffTypeInner, cCliffTypeOuter, cCliffTypeRamp)
** @param addToClass: whether to add the area to the forest class
** @param avoidSelf: whether to apply the constraint for self-avoidance
*/
void createCliffBlobAreas(int numBlobs = 0, string areaID = "", int type = cCliffTypeFake, bool addToClass = false, bool avoidSelf = true) {
	for(i = 0; < numBlobs) {
		int blobID = rmCreateArea(areaID + " " + i);

		// Add to class.
		if(addToClass) {
			rmAddAreaToClass(blobID, classFakeCliff);
		}

		// Avoid self if exists.
		if(avoidSelf && cliffAvoidSelfID >= 0) {
			rmAddAreaConstraint(blobID, cliffAvoidSelfID);
		}

		// Add constraints for fake cliffs or if enforced.
		if(cliffEnforceConstraints == true || type == cCliffTypeFake) {
			for(c = 0; < cliffConstraintCount) {
				rmAddAreaConstraint(blobID, getCliffConstraint(c));
				// rmSetAreaTerrainType(blobID, "SnowA");
			}
		}

		// Specific things first.
		if(type == cCliffTypeFake) {
			continue;
		} else if(type == cCliffTypeInner && innerCliffType != "") {
			rmSetAreaCliffType(blobID, innerCliffType);
			rmSetAreaCliffEdge(blobID, 1, 1.0, 0.0, 0.0, 0);
			rmSetAreaCliffPainting(blobID, true, false, true, 1.5, false);
		}

		// Generic things.
		string terrain = cliffGetTerrainType(type);
		float height = cliffGetHeight(type);
		int heightBlend = cliffGetHeightBlend(type);
		int smoothDistance = cliffGetSmoothDistance(type);

		if(terrain != "") {
			rmSetAreaTerrainType(blobID, terrain);
		}

		if(height != INF) {
			rmSetAreaBaseHeight(blobID, height);
		}

		if(heightBlend > -1) {
			rmSetAreaHeightBlend(blobID, heightBlend);
		}

		if(smoothDistance > 0) {
			rmSetAreaSmoothDistance(blobID, smoothDistance);
		}
	}
}

/*
** Attempts to randomly place and build a cliff from a previously built random shape.
**
** @param numBlobs: the number of blobs to create
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
**
** @returns: true if the cliff has been built successfully, false otherwise
*/
bool buildCliffShape(int numBlobs = 0, int player = 0) {
	// Increase the counter here already because we may return early.
	cliffAreaCount++;

	// Create fake blobs.
	createCliffBlobAreas(numBlobs, cFakeCliffString + " " + cliffAreaCount, cCliffTypeFake);

	// Randomize angle and radius.
	float radius = getCliffLocRadius();
	float angle = randRadian();

	int numTries = 0;

	while(isCliffLocValid(radius, angle, player) == false && numTries < 100) {
		radius = getCliffLocRadius();
		angle = randRadian();
		numTries++;
	}

	if(numTries >= 100) {
		return(false);
	}

	placeRandomShape(radius, angle, cFakeCliffString + " " + cliffAreaCount, innerBlobSize, innerBlobSpacing, player);

	// Check how many we can build successfully.
	int numBuilt = 0;

	for(i = 0; < numBlobs) {
		if(rmBuildArea(rmAreaID(cFakeCliffString + " " + cliffAreaCount + " " + i))) {
			numBuilt++;
		} else {
			setBlobForRemoval(i - numBuilt, numBuilt);
		}
	}

	// Return false in case we failed to build the required ratio of blobs.
	if(numBuilt < cliffBlobRequiredRatio * numBlobs) {
		return(false);
	}

	// Remove unbuilt blobs if we ended up in a valid state.
	for(i = 0; < numBlobs - numBuilt) {
		removeFullBlob(getBlobForRemoval(i));
	}

	// Place outer cliffs.
	for(i = 0; < 2) {
		createCliffBlobAreas(getStateSize(cBlobNear), cOuterCliffString + " " + cliffAreaCount + " " + i, cCliffTypeOuter, true, false);
	}

	placeOuterCliffShape(radius, angle, player);

	rmBuildAllAreas();

	// Place inner cliffs.
	for(i = 0; < 2) {
		createCliffBlobAreas(numBuilt, cInnerCliffString + " " + cliffAreaCount + " " + i, cCliffTypeInner, true, false);
	}

	placeRandomShapeMirrored(radius, angle, cInnerCliffString + " " + cliffAreaCount, innerBlobSize, innerBlobSpacing, player);

	rmBuildAllAreas();

	// Place ramps.
	resetRampList();

	numTries = 0;
	int succ = 0; // Could also use rampListSize here but better stay in scope for readability.
	int numRamps = rmRandInt(cliffMinRamps, cliffMaxRamps);

	// Randomize new entry in case its already present in the list.
	while(succ < numRamps && numTries < 100) {
		/*
		 * Try to add a new blob to the list of ramps.
		 * Use PI / numRamps as minimum angle to separate ramps; 2.0 * PI / numRamps would be exact.
		 * However, this would scale poorly and create artificial results.
		*/
		if(addRampToList(rmRandInt(0, getStateSize(cBlobNear) - 1), PI / numRamps)) {
			succ++;
		}

		numTries++;
	}

	// Place ramps.
	for(i = 0; < 2) {
		createCliffBlobAreas(rampListSize, cRampCliffString + " " + cliffAreaCount + " " + i, cCliffTypeRamp, true, false);
	}

	placeRampCliffShape(rampListSize, radius, angle, player);

	rmBuildAllAreas();

	return(true);
}

/*
** Attempts to build a number of cliffs (mirrored) based on the defined parameters and arguments given.
**
** If you need more customized support, feel free to use this and the above function as a template and adjust them to your needs (or provide your own).
**
** @param numCliffs: the number of cliffs to build
** @param prog: advances the progress bar by a fraction of the specified value for every cliff placed; only keeps the value if progress() was used to advance the bar prior
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
** @param numTries: number of attempts to place the desired amount of cliffs (default 250)
**
** @returns: the number of cliffs built (and mirrored) successfully
*/
int buildCliffs(int numCliffs = 0, float prog = 0.0, int player = 0, int numTries = 250) {
	int numBuilt = 0;

	// Prepare first iteration.
	int numBlobs = rmRandInt(cliffMinBlobs, cliffMaxBlobs);
	float coherence = rmRandInt(cliffMinCoherence, cliffMaxCoherence);

	// Build a random shape.
	createRandomShape(numBlobs, coherence);

	for(i = 0; < numTries) {
		if(buildCliffShape(numBlobs, player) == false) {
			continue;
		}

		numBuilt++;
		addProgress(prog / numCliffs);

		if(numBuilt >= numCliffs) {
			break;
		}

		// Prepare for next iteration.
		numBlobs = rmRandInt(cliffMinBlobs, cliffMaxBlobs);
		coherence = rmRandInt(cliffMinCoherence, cliffMaxCoherence);

		createRandomShape(numBlobs, coherence);
	}

	return(numBuilt);
}

/*
** Attempts to build a given number of mirrored cliffs around every player according to the previously specified parameters.
** The function iterates over the number of players in the team and places a cliff for every player and their mirrored counterpart.
**
** If it should ever be necessary to verify how many cliffs very successfully built and for which pair of players, make a custom version of this function
** along with a data structure to store the return result of buildCliffs().
**
** @param numCliffs: the number of cliffs to build
** @param prog: advances the progress bar by a fraction of the specified value for every area placed; if using this, make sure you use progress() instead of rmSetStatusText()
** @param numTries: number of attempts to place the desired amount of cliffs (default 250)
**
** @returns: the number of cliffs built (and mirrored) successfully
*/
int buildPlayerCliffs(int numCliffs = 0, float prog = 0.0, int numTries = 250) {
	int numBuilt = 0;
	int numPlayers = getNumberPlayersOnTeam(0);

	prog = prog / numPlayers;

	for(i = 1; <= numPlayers) {
		if(randChance(0.5)) {
			numBuilt = numBuilt + buildCliffs(numCliffs, prog, i, numTries);
		} else {
			numBuilt = numBuilt + buildCliffs(numCliffs, prog, getMirroredPlayer(i), numTries);
		}
	}

	return(numBuilt);
}

/*
** Utility function to create a single mirrored cliff based on the specified parameters at a given location.
** Note that this function does not check if a minimum number of blobs can be built and tries to place the areas directly.
**
** @param radius: the radius from the center in meters
** @param angle: the angle in the polar coordinate system
** @param player: if set to > 0, the player's location will be used as offset instead of the center of the map (0.5/0.5)
*/
void buildMirroredCliffAtLocation(float radius = 0.0, float angle = 0.0, int player = 0) {
	cliffAreaCount++;

	// Randomize blobs and coherence.
	int numBlobs = rmRandInt(cliffMinBlobs, cliffMaxBlobs);
	float coherence = rmRandInt(cliffMinCoherence, cliffMaxCoherence);

	// Build a random shape.
	createRandomShape(numBlobs, coherence);

	// Place outer cliffs.
	for(i = 0; < 2) {
		createCliffBlobAreas(getStateSize(cBlobNear), cOuterCliffString + " " + cliffAreaCount + " " + i, cCliffTypeOuter, true, false);
	}

	placeOuterCliffShape(radius, angle, player);

	rmBuildAllAreas();

	// Place inner cliffs.
	for(i = 0; < 2) {
		createCliffBlobAreas(numBlobs, cInnerCliffString + " " + cliffAreaCount + " " + i, cCliffTypeInner, true, false);
	}

	placeRandomShapeMirrored(radius, angle, cInnerCliffString + " " + cliffAreaCount, innerBlobSize, innerBlobSpacing, player);

	rmBuildAllAreas();

	// Place ramps.
	resetRampList();

	int numTries = 0;
	int succ = 0; // Could also use rampListSize here but better stay in scope for readability.
	int numRamps = rmRandInt(cliffMinRamps, cliffMaxRamps);

	// Randomize new entry in case its already present in the list.
	while(succ < numRamps && numTries < 100) {
		if(addRampToList(rmRandInt(0, getStateSize(cBlobNear) - 1), PI / numRamps)) {
			succ++;
		}

		numTries++;
	}

	// Place ramps.
	for(i = 0; < 2) {
		createCliffBlobAreas(rampListSize, cRampCliffString + " " + cliffAreaCount + " " + i, cCliffTypeRamp, true, false);
	}

	placeRampCliffShape(rampListSize, radius, angle, player);

	rmBuildAllAreas();
}

/*
** Object storage arrays and object placement.
** RebelsRising
** Last edit: 07/03/2021
*/

// include "rmx_cliffs.xs";

/*****************
* OBJECT STORAGE *
*****************/

/*
 * Arrays to store object information that is otherwise stroed in object IDs.
 * Particularily useful if you need to create multiple identical object definitions and then apply separate/different constraints,
 * like when placing objects near different locations for every player (e.g., near starting towers).
*/

// Proto unit.
string objectStorageProto0 = ""; string objectStorageProto1 = ""; string objectStorageProto2  = ""; string objectStorageProto3  = "";
string objectStorageProto4 = ""; string objectStorageProto5 = ""; string objectStorageProto6  = ""; string objectStorageProto7  = "";
string objectStorageProto8 = ""; string objectStorageProto9 = ""; string objectStorageProto10 = ""; string objectStorageProto11 = "";

string getObjectStorageProto(int i = -1) {
	if(i == 0) return(objectStorageProto0); if(i == 1) return(objectStorageProto1); if(i == 2)  return(objectStorageProto2);  if(i == 3)  return(objectStorageProto3);
	if(i == 4) return(objectStorageProto4); if(i == 5) return(objectStorageProto5); if(i == 6)  return(objectStorageProto6);  if(i == 7)  return(objectStorageProto7);
	if(i == 8) return(objectStorageProto8); if(i == 9) return(objectStorageProto9); if(i == 10) return(objectStorageProto10); if(i == 11) return(objectStorageProto11);
	return("");
}

void setObjectStorageProto(int i = -1, string proto = "") {
	if(i == 0) objectStorageProto0 = proto; if(i == 1) objectStorageProto1 = proto; if(i == 2)  objectStorageProto2  = proto; if(i == 3)  objectStorageProto3  = proto;
	if(i == 4) objectStorageProto4 = proto; if(i == 5) objectStorageProto5 = proto; if(i == 6)  objectStorageProto6  = proto; if(i == 7)  objectStorageProto7  = proto;
	if(i == 8) objectStorageProto8 = proto; if(i == 9) objectStorageProto9 = proto; if(i == 10) objectStorageProto10 = proto; if(i == 11) objectStorageProto11 = proto;
}

// Count.
int objectStorageItemCount0 = 0; int objectStorageItemCount1 = 0; int objectStorageItemCount2  = 0; int objectStorageItemCount3  = 0;
int objectStorageItemCount4 = 0; int objectStorageItemCount5 = 0; int objectStorageItemCount6  = 0; int objectStorageItemCount7  = 0;
int objectStorageItemCount8 = 0; int objectStorageItemCount9 = 0; int objectStorageItemCount10 = 0; int objectStorageItemCount11 = 0;

int getObjectStorageItemCount(int i = -1) {
	if(i == 0) return(objectStorageItemCount0); if(i == 1) return(objectStorageItemCount1); if(i == 2)  return(objectStorageItemCount2);  if(i == 3)  return(objectStorageItemCount3);
	if(i == 4) return(objectStorageItemCount4); if(i == 5) return(objectStorageItemCount5); if(i == 6)  return(objectStorageItemCount6);  if(i == 7)  return(objectStorageItemCount7);
	if(i == 8) return(objectStorageItemCount8); if(i == 9) return(objectStorageItemCount9); if(i == 10) return(objectStorageItemCount10); if(i == 11) return(objectStorageItemCount11);
	return(0);
}

void setObjectStorageItemCount(int i = -1, int count = 0) {
	if(i == 0) objectStorageItemCount0 = count; if(i == 1) objectStorageItemCount1 = count; if(i == 2)  objectStorageItemCount2  = count; if(i == 3)  objectStorageItemCount3  = count;
	if(i == 4) objectStorageItemCount4 = count; if(i == 5) objectStorageItemCount5 = count; if(i == 6)  objectStorageItemCount6  = count; if(i == 7)  objectStorageItemCount7  = count;
	if(i == 8) objectStorageItemCount8 = count; if(i == 9) objectStorageItemCount9 = count; if(i == 10) objectStorageItemCount10 = count; if(i == 11) objectStorageItemCount11 = count;
}

// Cluster distance.
float objectStorageDist0 = 0.0; float objectStorageDist1 = 0.0; float objectStorageDist2  = 0.0; float objectStorageDist3  = 0.0;
float objectStorageDist4 = 0.0; float objectStorageDist5 = 0.0; float objectStorageDist6  = 0.0; float objectStorageDist7  = 0.0;
float objectStorageDist8 = 0.0; float objectStorageDist9 = 0.0; float objectStorageDist10 = 0.0; float objectStorageDist11 = 0.0;

float getObjectStorageDist(int i = -1) {
	if(i == 0) return(objectStorageDist0); if(i == 1) return(objectStorageDist1); if(i == 2)  return(objectStorageDist2);  if(i == 3)  return(objectStorageDist3);
	if(i == 4) return(objectStorageDist4); if(i == 5) return(objectStorageDist5); if(i == 6)  return(objectStorageDist6);  if(i == 7)  return(objectStorageDist7);
	if(i == 8) return(objectStorageDist8); if(i == 9) return(objectStorageDist9); if(i == 10) return(objectStorageDist10); if(i == 11) return(objectStorageDist11);
	return(0.0);
}

void setObjectStorageDist(int i = -1, float dist = 0.0) {
	if(i == 0) objectStorageDist0 = dist; if(i == 1) objectStorageDist1 = dist; if(i == 2)  objectStorageDist2  = dist; if(i == 3)  objectStorageDist3  = dist;
	if(i == 4) objectStorageDist4 = dist; if(i == 5) objectStorageDist5 = dist; if(i == 6)  objectStorageDist6  = dist; if(i == 7)  objectStorageDist7  = dist;
	if(i == 8) objectStorageDist8 = dist; if(i == 9) objectStorageDist9 = dist; if(i == 10) objectStorageDist10 = dist; if(i == 11) objectStorageDist11 = dist;
}

// Constraints.
int objectStorageConstraint0 = 0; int objectStorageConstraint1 = 0; int objectStorageConstraint2  = 0; int objectStorageConstraint3  = 0;
int objectStorageConstraint4 = 0; int objectStorageConstraint5 = 0; int objectStorageConstraint6  = 0; int objectStorageConstraint7  = 0;
int objectStorageConstraint8 = 0; int objectStorageConstraint9 = 0; int objectStorageConstraint10 = 0; int objectStorageConstraint11 = 0;

int getObjectStorageConstraint(int i = -1) {
	if(i == 0) return(objectStorageConstraint0); if(i == 1) return(objectStorageConstraint1); if(i == 2)  return(objectStorageConstraint2);  if(i == 3)  return(objectStorageConstraint3);
	if(i == 4) return(objectStorageConstraint4); if(i == 5) return(objectStorageConstraint5); if(i == 6)  return(objectStorageConstraint6);  if(i == 7)  return(objectStorageConstraint7);
	if(i == 8) return(objectStorageConstraint8); if(i == 9) return(objectStorageConstraint9); if(i == 10) return(objectStorageConstraint10); if(i == 11) return(objectStorageConstraint11);
	return(0);
}

void setObjectStorageConstraint(int i = -1, int cID = 0) {
	if(i == 0) objectStorageConstraint0 = cID; if(i == 1) objectStorageConstraint1 = cID; if(i == 2)  objectStorageConstraint2  = cID; if(i == 3)  objectStorageConstraint3  = cID;
	if(i == 4) objectStorageConstraint4 = cID; if(i == 5) objectStorageConstraint5 = cID; if(i == 6)  objectStorageConstraint6  = cID; if(i == 7)  objectStorageConstraint7  = cID;
	if(i == 8) objectStorageConstraint8 = cID; if(i == 9) objectStorageConstraint9 = cID; if(i == 10) objectStorageConstraint10 = cID; if(i == 11) objectStorageConstraint11 = cID;
}

const string cObjectLabel = "stored object";

int objectStorageCount = 0;
int objectConstraintCount = 0;
int objectLabelCount = 0;

/*
** Stores an item for an object.
**
** @param proto: the proto name of the object to be placed (e.g., "Gazelle")
** @param num: the number of times the proto item should be placed
** @param dist: the distance the objects can be apart from each other
*/
void storeObjectDefItem(string proto = "", int num = 0, float dist = 0.0) {
	setObjectStorageProto(objectStorageCount, proto);
	setObjectStorageItemCount(objectStorageCount, num);
	setObjectStorageDist(objectStorageCount, dist);

	objectStorageCount++;
}

/*
** Stores a constraint for an object.
**
** @param cID: the ID of the constraint
*/
void storeObjectConstraint(int cID = -1) {
	setObjectStorageConstraint(objectConstraintCount, cID);

	objectConstraintCount++;
}

/*
** Creates a new object with the currently stored properties.
**
** @param objLabel: the label to use for creating the definition
** @param verify: whether to create the object definition with verification properties or not
** @param applyConstraints: whether to apply constraints or not
**
** @returns: the created object ID
*/
int createObjectFromStorage(string objLabel = "", bool verify = true, bool applyConstraints = true) {
	int objectID = -1;

	// Create label if not given.
	if(objLabel == "") {
		objLabel = cObjectLabel + " " + objectLabelCount;
		objectLabelCount++;
	}

	// Create object and add definitions based on whether to verify or not.
	if(verify) {
		objectID = createObjectDefVerify(objLabel);

		for(i = 0; < objectStorageCount) {
			addObjectDefItemVerify(objectID, getObjectStorageProto(i), getObjectStorageItemCount(i), getObjectStorageDist(i));
		}
	} else {
		objectID = rmCreateObjectDef(objLabel);

		for(i = 0; < objectStorageCount) {
			rmAddObjectDefItem(objectID, getObjectStorageProto(i), getObjectStorageItemCount(i), getObjectStorageDist(i));
		}
	}

	// Add constraints.
	if(applyConstraints) {
		for(i = 0; < objectConstraintCount) {
			rmAddObjectDefConstraint(objectID, getObjectStorageConstraint(i));
		}
	}

	return(objectID);
}

/*
** Resets the object storage.
*/
void resetObjectStorage() {
	objectStorageCount = 0;
	objectConstraintCount = 0;
}

/*******************
* OBJECT LOCATIONS *
*******************/

/*
 * Array for storing the coordinates of the last object placed for every player (!).
 * Therefore, the index here corresponds to the player number (unlike in the location storage!).
 * For simplicity, only the last iteration of an object will be stored here.
 *
 * If you need more than this, enable the location storage from location.xs via enableLocStorage() before placing the object.
 * After placement, you will find the locations of all (up to 64 total) objects in the array there.
 * Make sure you turn it off again via disableLocStorage() if you don't need it anymore!
*/

// Object X storage.
float lastObjX0 = -1.0; // Also store for Mother Nature.
float lastObjX1 = -1.0; float lastObjX2  = -1.0; float lastObjX3  = -1.0; float lastObjX4  = -1.0;
float lastObjX5 = -1.0; float lastObjX6  = -1.0; float lastObjX7  = -1.0; float lastObjX8  = -1.0;
float lastObjX9 = -1.0; float lastObjX10 = -1.0; float lastObjX11 = -1.0; float lastObjX12 = -1.0;

float getLastObjX(int i = -1) {
	if(i == 0) return(lastObjX0);
	if(i == 1) return(lastObjX1);  if(i == 2)  return(lastObjX2);  if(i == 3)  return(lastObjX3);  if(i == 4)  return(lastObjX4);
	if(i == 5) return(lastObjX5);  if(i == 6)  return(lastObjX6);  if(i == 7)  return(lastObjX7);  if(i == 8)  return(lastObjX8);
	if(i == 9) return(lastObjX9);  if(i == 10) return(lastObjX10); if(i == 11) return(lastObjX11); if(i == 12) return(lastObjX12);
	return(-1.0);
}

float setLastObjX(int i = -1, float val = -1.0) {
	if(i == 0) lastObjX0 = val;
	if(i == 1) lastObjX1 = val; if(i == 2)  lastObjX2  = val; if(i == 3)  lastObjX3  = val; if(i == 4)  lastObjX4  = val;
	if(i == 5) lastObjX5 = val; if(i == 6)  lastObjX6  = val; if(i == 7)  lastObjX7  = val; if(i == 8)  lastObjX8  = val;
	if(i == 9) lastObjX9 = val; if(i == 10) lastObjX10 = val; if(i == 11) lastObjX11 = val; if(i == 12) lastObjX12 = val;
}

// Object Z storage.
float lastObjZ0 = -1.0; // Also store for Mother Nature.
float lastObjZ1 = -1.0; float lastObjZ2  = -1.0; float lastObjZ3  = -1.0; float lastObjZ4  = -1.0;
float lastObjZ5 = -1.0; float lastObjZ6  = -1.0; float lastObjZ7  = -1.0; float lastObjZ8  = -1.0;
float lastObjZ9 = -1.0; float lastObjZ10 = -1.0; float lastObjZ11 = -1.0; float lastObjZ12 = -1.0;

float getLastObjZ(int i = -1) {
	if(i == 0) return(lastObjZ0);
	if(i == 1) return(lastObjZ1);  if(i == 2)  return(lastObjZ2);  if(i == 3)  return(lastObjZ3);  if(i == 4)  return(lastObjZ4);
	if(i == 5) return(lastObjZ5);  if(i == 6)  return(lastObjZ6);  if(i == 7)  return(lastObjZ7);  if(i == 8)  return(lastObjZ8);
	if(i == 9) return(lastObjZ9);  if(i == 10) return(lastObjZ10); if(i == 11) return(lastObjZ11); if(i == 12) return(lastObjZ12);
	return(-1.0);
}

float setLastObjZ(int i = -1, float val = -1.0) {
	if(i == 0) lastObjZ0 = val;
	if(i == 1) lastObjZ1 = val; if(i == 2)  lastObjZ2  = val; if(i == 3)  lastObjZ3  = val; if(i == 4)  lastObjZ4  = val;
	if(i == 5) lastObjZ5 = val; if(i == 6)  lastObjZ6  = val; if(i == 7)  lastObjZ7  = val; if(i == 8)  lastObjZ8  = val;
	if(i == 9) lastObjZ9 = val; if(i == 10) lastObjZ10 = val; if(i == 11) lastObjZ11 = val; if(i == 12) lastObjZ12 = val;
}

/*
** Sets the x and z value for a single entry.
**
** @param i: the index to set
** @param x: the x value (fraction)
** @param z: the z value (fraction)
*/
void setLastObjXZ(int i = 0, float x = -1.0, float z = -1.0) {
	setLastObjX(i, x);
	setLastObjZ(i, z);
}

/*****************************
* COMMON PLACEMENT FUNCTIONS *
*****************************/

/*
** Attempts to place an object for a player at a given location.
**
** @param objectID: the ID of the object to be placed
** @param player: the player (already mapped) owning the object (0 = Mother Nature)
** @param x: x coordinate of the location
** @param z: z coordinate of the location
** @param force: has to be set to true if the object must be placed (note that this alone will not guarantee placement though, see function below)
**
** @returns: true if placement succeeded, false otherwise
*/
bool placeObjectForPlayer(int objectID = -1, int player = 0, float x = -1.0, float z = -1.0, bool force = false) {
	if(force == false && isLocValid(x, z) == false) {
		return(false);
	}

	return(rmPlaceObjectDefAtLoc(objectID, player, x, z) > 0);
}

/*
** Enforces placement for an object for a player by steadily increasing MaxDistance of the object until placement succeeded.
**
** @param objectID: the ID of the object to be placed
** @param player: the player (already mapped) owning the object (0 = Mother Nature)
** @param x: x coordinate of the location
** @param z: z coordinate of the location
*/
void forcePlaceObjectForPlayer(int objectID = -1, int player = 0, float x = -1.0, float z = -1.0) {
	// Calculate diagonal.
	int numForceTries = 100;
	float diag = sqrt(sq(getFullXMeters()) + sq(getFullZMeters()));
	float range = 1.0;

	for(i = 1; < numForceTries) {
		// Increase maximum distance allowed to be placed from original location, try to place, increment.
		rmSetObjectDefMaxDistance(objectID, range);

		if(placeObjectForPlayer(objectID, player, x, z, true) || range > diag) {
			// Reset max distance if placed successfully (in case we place same object again) and return.
			rmSetObjectDefMaxDistance(objectID, 0.0);
			return;
		}

		range = 2.0 * range;
	}
}

/**************************************
* MIRRORED PLACEMENT ANGLE PARAMETERS *
**************************************/

// Object angle randomization settings.
float objectMinAngle = INF;
float objectMaxAngle = PI;
bool useIntervalOnce = true;

/*
** Sets the interval to randomize from.
** 0 is behind the player, PI is in front. 0.5 * PI is to the right when watching from the player towards the center, -0.5 * PI to the left.
**
** @param minAngle: the minimum angle to randomize
** @param maxAngle: the maximum angle to randomize
** @param runOnce: whether to reset the interval after placing an object for every player or keep it until changed
*/
void setObjectAngleInterval(float minAngle = INF, float maxAngle = PI, bool runOnce = true) {
	objectMinAngle = minAngle;
	objectMaxAngle = maxAngle;
	useIntervalOnce = runOnce;
}

// Far object angle slice setting.
float farObjectAngleSlice = INF;
bool useFarSliceOnce = true;

/*
** Sets the far object player angle slice.
** Note that the far angle is inverted, i.e., PI is straight through/behind the player and 0 is in front.
**
** @param slice: the slice (angle) to randomize from with respect to player offset (example: PI -> rmRandFloat(-0.5 * PI, 0.5 * PI)
** @param runOnce: whether to reset the interval after placing an object for every player or keep it until changed
*/
void setFarObjectAngleSlice(float slice = INF, bool runOnce = true) {
	farObjectAngleSlice = slice;
	useFarSliceOnce = runOnce;
}

/*
** Returns the far angle segment to randomize from (or half of it to be accurate).
** Considers the angle slice parameter if set.
**
** @param player: the player to calculate the angle segment for
**
** @returns: half of the angle segment
*/
float getFarAngleSegment(int player = 0) {
	if(player == 0) {
		return(PI);
	}

	if(farObjectAngleSlice < INF) {
		return(0.5 * farObjectAngleSlice);
	}

	// Less priority than set angle.
	if(cNonGaiaPlayers == 2) {
		return(PI);
	}

	// Return the larger section which makes 0.5 of the total section that will be used for randomization.
	float diffPrev = getSectionBetweenConsecutiveAngles(getPlayerAngle(getPrevPlayer(player)), getPlayerAngle(player));
	float diffNext = getSectionBetweenConsecutiveAngles(getPlayerAngle(player), getPlayerAngle(getNextPlayer(player)));

	if(diffPrev > diffNext) {
		return(diffPrev);
	}

	return(diffNext);
}

/*********************
* MIRRORED PLACEMENT *
*********************/

/*
** Attempts to place an object at a specific location (defined in polar coordinates) for a player and its mirrored counterpart.
**
** @param player: the player number of the player and their mirrored counterpart to place the object for
** @param objectID: the ID of the object to be placed
** @param radius: radius as fraction
** @param angle: angle in radians
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
**
** @returns: true if placement succeeded, false otherwise
*/
bool placeObjectForMirroredPlayersAtAngle(int player = 0, int objectID = -1, float radius = 0.0, float angle = 0.0, bool playerOwned = false, bool square = false, int altObjID = -1) {
	float owner = 0; // Mother Nature.

	for(i = 0; < 2) {
		if(playerOwned) { // Set owner to player.
			owner = getPlayer(player);
		}

		float x = getXFromPolarForPlayer(player, radius, angle, square);
		float z = getZFromPolarForPlayer(player, radius, angle, square);

		if(placeObjectForPlayer(objectID, owner, x, z) == false) {
			// Failed to place for first player, return.
			if(i == 0) {
				return(false);
			}

			// Failed to place for second player, enforce placement.
			forcePlaceObjectForPlayer(objectID, owner, x, z);
		}

		// Make entry in location array.
		setLastObjXZ(player, x, z);

		// Store location.
		addLocToStorage(x, z, player);

		// If we get here with i == 1 we're done.
		if(i == 1) {
			return(true);
		}

		// Prepare for next iteration.
		// Adjust angle.
		if(getMirrorMode() != cMirrorPoint) {
			angle = 0.0 - angle;
		}

		// Use alt object if defined.
		if(altObjID > -1) {
			objectID = altObjID;
		}

		// Prepare player for next iteration.
		player = getMirroredPlayer(player);
	}
}

/*
** Attempts to place a mirrored object for a player and their mirrored counterpart.
**
** @param player: the player number of the player and their mirrored counterpart to place the object for
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of objects to place per player
** @param minDist: minimum distance from the player
** @param maxDist: maximum distance from the player
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
**
** @returns: the number of objects placed successfully placed for both players
*/
int placeObjectForMirroredPlayers(int player = 0, int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 0.0, float maxDist = -1.0, bool square = false, int altObjID = -1) {
	if(maxDist < 0) {
		maxDist = minDist;
	}

	int numIter = 500 * num;
	int placed = 0;
	float angle = 0.0;

	for(i = 0; < numIter) {
		// Randomize radius and angle and try to place.
		float radius = randRadiusFromInterval(minDist, maxDist);

		if(objectMinAngle < INF) {
			angle = rmRandFloat(objectMinAngle, objectMaxAngle);
		} else {
			angle = randRadian();
		}

		if(placeObjectForMirroredPlayersAtAngle(player, objectID, radius, angle, playerOwned, square, altObjID)) {
			placed++;

			if(placed == num) {
				break;
			}
		}
	}

	return(placed);
}

/*
** Attempts to place a mirrored object for all players.
** This is done by separately mirroring an object for every pair of mirrored players.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of objects to place per player
** @param minDist: minimum distance from the player
** @param maxDist: maximum distance from the player
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
** @param backupObjID: if set, this object will be used for backup placement in case the original object fails to place in some instances
**
** @returns: true on success, false on any failures
*/
bool placeObjectMirrored(int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 0.0, float maxDist = -1.0, bool square = false, int altObjID = -1, int backupObjID = -1) {
	int succeeded = 0;

	for(p = 1; <= getNumberPlayersOnTeam(0)) {
		int player = p;

		if(randChance()) {
			player = getMirroredPlayer(player);
		}

		int placed = placeObjectForMirroredPlayers(player, objectID, playerOwned, num, minDist, maxDist, square, altObjID);

		if(placed == num) {
			succeeded++;
		} else if(backupObjID != -1) {
			if(placeObjectForMirroredPlayers(player, backupObjID, playerOwned, num - placed, minDist, maxDist, square, altObjID) == num - placed) {
				succeeded++;
			}
		}
	}

	if(useIntervalOnce) {
		setObjectAngleInterval();
	}

	return(succeeded == 0.5 * cNonGaiaPlayers);
}

/*
** Attempts to place an object at a specific location (defined in polar coordinates) for a player and its mirrored counterpart.
**
** The difference here is that we try to place the object from the middle towards the player instead of the other way around.
** This is good for far objects as we can directly avoid the center circle and still place the object in the player's section.
**
** @param player: the player number of the player and their mirrored counterpart to place the object for
** @param objectID: the ID of the object to be placed
** @param radius: radius as fraction
** @param angle: angle in radians from the center (!), 0 points towards the center and PI towards the edge of the map with respect to the player
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
**
** @returns: true if placement succeeded, false otherwise
*/
bool placeFarObjectForMirroredPlayersAtAngle(int player = 0, int objectID = -1, float radius = 0.0, float angle = 0.0, bool playerOwned = false, int altObjID = -1) {
	float owner = 0;

	for(i = 0; < 2) {
		if(playerOwned) { // Set owner to player.
			owner = getPlayer(player);
		}

		/*
		 * Always use player 0 (0.5/0.5) as offset here, resulting in the player angle not being added in getFromPolarForPlayer().
		 * To still achieve the offset relative to the player so that you can actually specify a meaningful angle argument for this function,
		 * we add the player angle manually.
		 * Since we are placing from the middle, the angles are now inverted: 0.0 points towards the center, PI follows the player angle from the center.
		*/
		float x = getXFromPolarForPlayer(0, radius, angle + getPlayerAngle(player));
		float z = getZFromPolarForPlayer(0, radius, angle + getPlayerAngle(player));

		if(placeObjectForPlayer(objectID, owner, x, z) == false) {
			// Failed to place for p1, return.
			if(i == 0) {
				return(false);
			}

			// Failed to place for another player, enforce placement.
			forcePlaceObjectForPlayer(objectID, owner, x, z);
		}

		// Make entry in location array.
		setLastObjXZ(player, x, z);

		// Store location.
		addLocToStorage(x, z, player);

		// If we get here with i == 1 we're done.
		if(i == 1) {
			return(true);
		}

		// Prepare for next iteration.
		// Adjust angle.
		if(getMirrorMode() != cMirrorPoint) {
			angle = 0.0 - angle;
		}

		// Use alt object if defined.
		if(altObjID > -1) {
			objectID = altObjID;
		}

		// Prepare player for next iteration.
		player = getMirroredPlayer(player);
	}
}

/*
** Attempts to place a mirrored object for a player and their mirrored counterpart.
**
** The difference here is that we try to place the object from the middle towards the player instead of the other way around.
** This is good for far objects as we can directly avoid the center circle and still place the object in the player's section.
**
** @param player: the player number of the player and their mirrored counterpart to place the object for
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of objects to place per player
** @param minDist: the minimum distance of the objects to be from the center (to avoid very close spawns)
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
**
** @returns: the number of objects placed successfully placed for both players
*/
int placeFarObjectForMirroredPlayers(int player = 0, int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 20.0, int altObjID = -1) {
	int numIter = 500 * num;
	int placed = 0;

	// Get angle range to place towards (offset to player).
	float maxAngle = getFarAngleSegment(player);
	float minAngle = 0.0 - maxAngle;

	for(i = 0; < numIter) {
		float radius = randRadiusFromCenterToEdge(minDist);
		float angle = rmRandFloat(minAngle, maxAngle);

		if(placeFarObjectForMirroredPlayersAtAngle(player, objectID, radius, angle, playerOwned, altObjID)) {
			placed++;

			if(placed == num) {
				break;
			}
		}
	}

	return(placed);
}

/*
** Attempts to place a far object mirrored for all players.
** You have to use constraints to make the object avoid the player, it can be placed anywhere in the player's section.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of objects to place per player
** @param minDist: the minimum distance of the objects to be from the center (to avoid very close spawns)
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
** @param backupObjID: if set, this object will be used for backup placement in case the original object fails to place in some instances
**
** @returns: true on success, false on any failures
*/
bool placeFarObjectMirrored(int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 20.0, int altObjID = -1, int backupObjID = -1) {
	int succeeded = 0;

	for(p = 1; <= getNumberPlayersOnTeam(0)) {
		int player = p;

		if(randChance(0.0)) {
			player = getMirroredPlayer(player);
		}

		int placed = placeFarObjectForMirroredPlayers(player, objectID, playerOwned, num, minDist, altObjID);

		if(placed == num) {
			succeeded++;
		} else if(backupObjID != -1) {
			if(placeFarObjectForMirroredPlayers(player, backupObjID, playerOwned, num - placed, minDist, altObjID) == num - placed) {
				succeeded++;
			}
		}
	}

	if(useFarSliceOnce) {
		setFarObjectAngleSlice();
	}

	return(succeeded == 0.5 * cNonGaiaPlayers);
}

/********************
* REGULAR PLACEMENT *
********************/

float placeObjectMinAngle = 0.0;
float placeObjectMaxAngle = 2.0;

/*
** Sets the minimum/maximum angle to randomize from for placeObjectDefForPlayer().
**
** @param startAngle: starting angle in radians but without multiplied by PI (basically the angle in radians / PI)
** @param endAngle: ending angle in radians but without multiplied by PI (basically the angle in radians / PI)
*/
void setPlaceObjectAngleRange(float startAngle = 0.0, float endAngle = 2.0) {
	placeObjectMinAngle = startAngle;
	placeObjectMaxAngle = endAngle;
}

/*
** Resets the angles to default values. Has to be called manually if using placeObjectDefForPlayer() instead of placeObjectDefPerPlayer()!
*/
void resetPlaceObjectAngle() {
	setPlaceObjectAngleRange();
}

/*
** Attempts to place a regular object for a single player.
**
** @param player: the player
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the player, false means it is owned by Mother Nature
** @param num: the number of objects to place
** @param minDist: minimum distance from the player
** @param maxDist: maximum distance from the player
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param verify: whether to verify placement or not (disable this for heuristic approaches); requires an object created with createObjectDefVerify()
** @param numTries: the number of attempts per object instance
**
** @returns: the number of objects placed successfully placed for both players (the number of actual objects, NOT the number of items * the number of objects!)
*/
int placeObjectDefForPlayer(int player = 0, int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 0.0, float maxDist = -1.0, bool square = false, bool verify = true, int numTries = 1000) {
	setObjectDefDistance(objectID, 0.0, 0.0);

	if(maxDist < 0) {
		maxDist = minDist;
	}

	int numIter = numTries * num;
	int placed = 0;
	float owner = 0; // Mother Nature.

	if(playerOwned) { // Set owner to player.
		owner = getPlayer(player);
	}

	for(i = 0; < numIter) {
		float radius = randRadiusFromInterval(minDist, maxDist);
		float angle = rmRandFloat(placeObjectMinAngle, placeObjectMaxAngle) * PI;

		float x = getXFromPolarForPlayer(player, radius, angle, square);
		float z = getZFromPolarForPlayer(player, radius, angle, square);

		if(placeObjectForPlayer(objectID, owner, x, z)) {
			setLastObjXZ(player, x, z);
			addLocToStorage(x, z, player);
			placed++;

			if(placed == num) {
				break;
			}
		}
	}

	setObjectDefDistance(objectID, minDist, maxDist);

	// Verification stuff.
	if(verify) {
		updateObjectTargetPlaced(objectID, num);
	}

	return(placed);
}

/*
** Places an object within a given distance interval for a certain player.
**
** Replaces rmPlaceObjectDefPerPlayer().
** If you use this function, be aware that the min/max distance of the object definition gets overwritten with the parameters used here.
**
** @param objectID: the object definition ID
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of times the object should be placed
** @param minDist: the minimum distance from the player location the object can be
** @param maxDist: the maximum distance from the player location the object can be
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
**
** @returns: true on success, false on any failures
*/
bool placeObjectDefPerPlayer(int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 0.0, float maxDist = -1.0, bool square = false) {
	int succeeded = 0;

	for(p = 1; < cPlayers) {
		if(placeObjectDefForPlayer(p, objectID, playerOwned, num, minDist, maxDist, square) == num) {
			succeeded++;
		}
	}

	// updateObjectTargetPlaced(objectID, num * cNonGaiaPlayers); // Already done in placeObjectDefForPlayer().

	// Reset angle.
	resetPlaceObjectAngle();

	return(succeeded == cNonGaiaPlayers);
}

/*
** Replaces rmPlaceObjectDefAtLoc() to allow placement checking.
**
** @param objectID: the ID of the object to be placed
** @param owner: the object owner; 0 -> nature, 1 <= owner <= 12 -> one of the actual players
** @param x: the x coordinate of the location as a fraction
** @param z: the z coordinate of the location as a fraction
** @param num: the number of times the object should be placed
**
** @returns: the number of placed object items, not the number of actual object definitions placed (!)
*/
int placeObjectDefAtLoc(int objectID = -1, int owner = 0, float x = 0.0, float z = 0.0, int num = 1) {
	int res = rmPlaceObjectDefAtLoc(objectID, getPlayer(owner), x, z, num);

	updateObjectTargetPlaced(objectID, num);

	return(res);
}

/*
** Replaces rmPlaceObjectDefAtAreaLoc() to allow placement checking.
**
** @param objectID: the ID of the object to be placed
** @param owner: the object owner; 0 -> nature, 1 <= owner <= 12 -> one of the actual players
** @param areaID: the ID of the area to place the object at
** @param num: the number of times the object should be placed
**
** @returns: the number of placed object items, not the number of actual object definitions placed (!)
*/
int placeObjectDefAtAreaLoc(int objectID = -1, int owner = 0, int areaID = -1, int num = 1) {
	int res = rmPlaceObjectDefAtAreaLoc(objectID, getPlayer(owner), areaID, num);

	updateObjectTargetPlaced(objectID, num);

	return(res);
}

/*
** Replaces rmPlaceObjectDefInArea() to allow placement checking.
**
** @param objectID: the ID of the object to be placed
** @param owner: the object owner; 0 -> nature, 1 <= owner <= 12 -> one of the actual players
** @param areaID: the ID of the area to place the object at
** @param num: the number of times the object should be placed
**
** @returns: the number of placed object items, not the number of actual object definitions placed (!)
*/
int placeObjectDefInArea(int objectID = -1, int owner = 0, int areaID = -1, int num = 1) {
	int res = rmPlaceObjectDefInArea(objectID, getPlayer(owner), areaID, num);

	updateObjectTargetPlaced(objectID, num);

	return(res);
}

/*
** Replaces rmPlaceObjectDefAtRandomAreaOfClass() to allow placement checking.
**
** @param objectID: the ID of the object to be placed
** @param owner: the object owner; 0 -> nature, 1 <= owner <= 12 -> one of the actual players
** @param classID: the ID of the class to randomly select an area from
** @param num: the number of times the object should be placed
**
** @returns: the number of placed object items, not the number of actual object definitions placed (!)
*/
int placeObjectDefAtRandomAreaOfClass(int objectID = -1, int owner = 0, int classID = -1, int num = 1) {
	int res = rmPlaceObjectDefAtRandomAreaOfClass(objectID, getPlayer(owner), classID, num);

	updateObjectTargetPlaced(objectID, num);

	return(res);
}

/*
** Replaces rmPlaceObjectDefInRandomAreaOfClass() to allow placement checking.
**
** @param objectID: the ID of the object to be placed
** @param owner: the object owner; 0 -> nature, 1 <= owner <= 12 -> one of the actual players
** @param classID: the ID of the class to randomly select an area from
** @param num: the number of times the object should be placed
**
** @returns: the number of placed object items, not the number of actual object definitions placed (!)
*/
int placeObjectDefInRandomAreaOfClass(int objectID = -1, int owner = 0, int classID = -1, int num = 1) {
	int res = rmPlaceObjectDefInRandomAreaOfClass(objectID, getPlayer(owner), classID, num);

	updateObjectTargetPlaced(objectID, num);

	return(res);
}

/*
** Places an object at a specific player location. Player 0 (Mother Nature) has offset 0.5/0.5.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param player: the player to use as offset
** @param num: the number of times the object should be placed
**
** @returns: the number of placed object items, not the number of actual object definitions placed (!)
*/
int placeObjectAtPlayerLoc(int objectID = -1, bool playerOwned = false, int player = 0, int num = 1) {
	int res = 0;

	if(playerOwned) {
		res = placeObjectDefAtLoc(objectID, player, getPlayerLocXFraction(player), getPlayerLocZFraction(player), num);
	} else {
		res = placeObjectDefAtLoc(objectID, 0, getPlayerLocXFraction(player), getPlayerLocZFraction(player), num);
	}

	return(res);
}

/*
** Places the same object for every player, starting (rmSetObjectDefMinDistance() = 0.0) from the player's spawn.
** This is a direct replacement for rmPlaceObjectDefPerPlayer(), which should NOT be used due to observers/merged players.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param num: the number of times the object should be placed
*/
void placeObjectAtPlayerLocs(int objectID = -1, bool playerOwned = false, int num = 1) {
	for(i = 1; < cPlayers) {
		placeObjectAtPlayerLoc(objectID, playerOwned, i, num);
	}
}

/*
** Places an object for every player somewhere in their split.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param num: the number of times the object should be placed
*/
void placeObjectInPlayerSplits(int objectID = -1, bool playerOwned = false, int num = 1) {
	// Initialize splits if not already done.
	initializeSplit();

	for(i = 1; < cPlayers) {
		if(playerOwned) {
			placeObjectDefInArea(objectID, i, rmAreaID(cSplitName + " " + i), num);
		} else {
			placeObjectDefInArea(objectID, 0, rmAreaID(cSplitName + " " + i), num);
		}
	}
}

/*
** Places an object for every player somewhere in the split of their team.
** This should be used instead of randomly placing objects from 0.5/0.5 with a huge maximum distance (e.g., bonus hunt on Oasis).
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param num: the number of times the object should be placed
*/
void placeObjectInTeamSplits(int objectID = -1, bool playerOwned = false, int num = 1) {
	// Initialize splits if not already done.
	initializeTeamSplit(10.0);

	for(i = 1; < cPlayers) {
		if(playerOwned) {
			placeObjectDefInArea(objectID, i, rmAreaID(cTeamSplitName + " " + rmGetPlayerTeam(getPlayer(i))), num);
		} else {
			placeObjectDefInArea(objectID, 0, rmAreaID(cTeamSplitName + " " + rmGetPlayerTeam(getPlayer(i))), num);
		}
	}
}

/*************************
* FAIR/SIM LOC PLACEMENT *
**************************

/*
** Places a given object at the location of the specified fair location for every player.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param fairLocID: the ID of the fair location
*/
void placeObjectAtFairLoc(int objectID = -1, bool playerOwned = false, int fairLocID = 1) {
	for(i = 1; < cPlayers) {
		float x = getFairLocX(fairLocID, i);
		float z = getFairLocZ(fairLocID, i);

		if(playerOwned) {
			placeObjectDefAtLoc(objectID, i, x, z);
		} else {
			placeObjectDefAtLoc(objectID, 0, x, z);
		}
	}
}

/*
** Places a given object at the location of all generated fair locations.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
*/
void placeObjectAtAllFairLocs(int objectID = -1, bool playerOwned = false) {
	int numFairLocs = getNumFairLocs();

	for(f = 1; <= numFairLocs) {
		placeObjectAtFairLoc(objectID, playerOwned, f);
	}
}

/*
** Convenience function to place objects at defined fair locations in atomic (all-or-nothing) fashion.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param fairLocLabel: the name of the fair location (only used for debugging purposes)
** @param isCrucial: whether the fair loc is crucial and players should be warned if it fails or not
** @param maxIter: the maximum number of iterations to run the algorithm for
** @param localMaxIter: the maximum attempts to find a fair location for every player before starting over
**
** @returns: true upon successfully generating the locations (and placing the objects), false upon any failure (abort)
*/
bool placeObjectAtNewFairLocs(int objectID = -1, bool playerOwned = false, string fairLocLabel = "", bool isCrucial = true, int maxIter = 5000, int localMaxIter = 100) {
	bool success = createFairLocs(fairLocLabel, isCrucial, maxIter, localMaxIter);

	if(success) {
		// Place.
		placeObjectAtAllFairLocs(objectID, playerOwned);
	}

	// Reset.
	resetFairLocs();

	return(success);
}

/*
** Places a given object at the location of the specified fair location for every player.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param simLocID: the ID of the fair location
*/
void placeObjectAtSimLoc(int objectID = -1, bool playerOwned = false, int simLocID = 1) {
	for(i = 1; < cPlayers) {
		float x = getSimLocX(simLocID, i);
		float z = getSimLocZ(simLocID, i);

		if(playerOwned) {
			placeObjectDefAtLoc(objectID, i, x, z);
		} else {
			placeObjectDefAtLoc(objectID, 0, x, z);
		}
	}
}

/*
** Places a given object at the location of all generated fair locations.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
*/
void placeObjectAtAllSimLocs(int objectID = -1, bool playerOwned = false) {
	int numSimLocs = getNumSimLocs();

	for(f = 1; <= numSimLocs) {
		placeObjectAtSimLoc(objectID, playerOwned, f);
	}
}

/*
** Convenience function to place objects at defined similar locations in atomic (all-or-nothing) fashion.
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: defaults to false (= Mother Nature); players will own the object if set to true
** @param simLocLabel: the name of the similar location (only used for debugging purposes)
** @param isCrucial: whether the fair loc is crucial and players should be warned if it fails or not
** @param maxIter: the maximum number of iterations to run the algorithm for
** @param localMaxIter: the maximum attempts to find a similar location for every player before starting over
**
** @returns: true upon successfully generating the locations (and placing the objects), false upon any failure (abort)
*/
bool placeObjectAtNewSimLocs(int objectID = -1, bool playerOwned = false, string simLocLabel = "", bool isCrucial = true, int maxIter = 5000, int localMaxIter = 100) {
	bool success = createSimLocs(simLocLabel, isCrucial, maxIter, localMaxIter);

	if(success) {
		// Place.
		placeObjectAtAllSimLocs(objectID, playerOwned);
	}

	// Reset.
	resetSimLocs();

	return(success);
}

/*************************
* PLACEMENT NEAR OBJECTS *
*************************/

const string cAltObjLabel = "rmx near alt object";
const string cBackupObjLabel = "rmx near backup object";
const string cObjAreaLabel = "rmx near object area";
const string cObjLabel = "rmx near object";
const string cObjString = "rmx object near area";

int objCounter = 0;

// Mirrored.

/*
** Places and stores a mirrored object in the location storage.
** Note that this resets the storage and also calls disableLocStorage() before returning.
** Also see placeObjectMirrored().
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of objects to place per player
** @param minDist: minimum distance from the player
** @param maxDist: maximum distance from the player
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param altObjID: if set, this object will be used for the mirrored player instead of objectID
**                  (e.g., without constraints in case it is placed close to the center)
** @param backupObjID: if set, this object will be used for backup placement in case the original object fails to place in some instances
**
** @returns: true on success, false on any failures
*/
bool placeAndStoreObjectMirrored(int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 0.0, float maxDist = -1.0, bool square = false, int altObjID = -1, int backupObjID = -1) {
	resetLocStorage();
	enableLocStorage();

	bool success = placeObjectMirrored(objectID, playerOwned, num, minDist, maxDist, square, altObjID, backupObjID);

	disableLocStorage();

	return(success);
}

/*
** Reads from the first n entries of the location storage to place a mirrored object close to one (!) of the locations per player.
** Since this requires a new object (with different area constraints for every player), you have to use storeObject...() functions
** and this function will use the object information that is currently stored.
** Note that players will only get objects placed close to locations they actually own (as per getLocOwner()).
**
** @param nLocs: the number of locations per player to consider from the location storage
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param minPlayerDist: the minimum distance from the player location the object can be
** @param maxPlayerDist: the maximum distance from the player location the object can be
** @param objectDist: the maximum distance the object can be from the previously placed object
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
*/
void placeStoredObjectMirroredNearStoredLocs(int nLocs = 0, bool playerOwned = false, float minPlayerDist = 0.0, float maxPlayerDist = 0.0, float objectDist = 0.0, bool square = false) {
	int altObjectID = createObjectFromStorage(cAltObjLabel + " " + objCounter, false, false); // No constraints.
	int backupObjectID = createObjectFromStorage(cBackupObjLabel + " " + objCounter, false, true); // With constraints, but no area constraint later on.

	for(p = 0; < getNumberPlayersOnTeam(0)) {
		bool done = false;

		for(o = 1; <= nLocs) {
			// 2 * p * nLocs = 2 locations for every pair of mirrored players per location used as offset.
			// 2 * o - 1 = We only look at the first location for mirrored players (index 1, 3, 5, ...).
			int idx = 2 * o - 1 + 2 * p * nLocs;
			float x = getLocX(idx);
			float z = getLocZ(idx);

			int fakeAreaID = rmCreateArea(cObjAreaLabel + " " + objCounter + " " + p + " " + o);
			rmSetAreaLocation(fakeAreaID, x, z);
			rmSetAreaSize(fakeAreaID, rmXMetersToFraction(0.1));
			rmSetAreaCoherence(fakeAreaID, 1.0);
			rmBuildArea(fakeAreaID);

			// New object with the constraint forcing it close to one of the areas.
			int nearObjectID = createObjectFromStorage(cObjLabel + " " + objCounter + " " + p + " " + o, false, true);

			// Create individual constraint so the object actually places close to the area.
			rmAddObjectDefConstraint(nearObjectID, createAreaMaxDistConstraint(fakeAreaID, objectDist));

			if(placeObjectForMirroredPlayers(getLocOwner(idx), nearObjectID, playerOwned, 1, minPlayerDist, maxPlayerDist, square, altObjectID) > 0) {
				done = true;
				break;
			}
		}

		if(done == false) {
			// Backup.
			placeObjectForMirroredPlayers(p, backupObjectID, playerOwned, 1, minPlayerDist, maxPlayerDist, square, altObjectID);
		}
	}

	objCounter++;
}

// Non-mirrored.

/*
** Places and stores an object in the location storage.
** Note that this resets the storage and also calls disableLocStorage() before returning.
** Also see placeObjectDefPerPlayer().
**
** @param objectID: the ID of the object to be placed
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param num: the number of objects to place per player
** @param minDist: minimum distance from the player
** @param maxDist: maximum distance from the player
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
**
** @returns: true on success, false on any failures
*/
bool placeAndStoreObjectAtPlayerLocs(int objectID = -1, bool playerOwned = false, int num = 1, float minDist = 0.0, float maxDist = -1.0, bool square = false) {
	resetLocStorage();
	enableLocStorage();

	bool success = placeObjectDefPerPlayer(objectID, playerOwned, num, minDist, maxDist, square);

	disableLocStorage();

	return(success);
}

/*
** Reads from the first n entries of the location storage to place an object close to one (!) of the locations per player.
** Since this requires a new object (with different area constraints for every player), you have to use storeObject...() functions
** and this function will use the object information that is currently stored.
** Note that players will only get objects placed close to locations they actually own (as per getLocOwner()).
** Does NOT verify object placement, make sure to do that via trigger if you intend to use this.
**
** @param nLocs: the number of locations per player to consider from the location storage
** @param playerOwned: true means the object is owned by the players, false means it is owned by Mother Nature
** @param minPlayerDist: the minimum distance from the player location the object can be
** @param maxPlayerDist: the maximum distance from the player location the object can be
** @param objectDist: the maximum distance the object can be from the previously placed object
** @param square: if true, the radius is converted to a square (the original rmPlaceObjectDef does this)
** @param verify: whether to verify placement or not (disable this for heuristic approaches)
*/
void placeStoredObjectNearStoredLocs(int nLocs = 0, bool playerOwned = false, float minPlayerDist = 0.0, float maxPlayerDist = 0.0, float objectDist = 0.0, bool square = true, bool verify = true) {
	for(p = 0; < cNonGaiaPlayers) {
		int nearObjectID = -1;

		for(o = 1; <= nLocs) {
			// Multiple objects placed for a single player are contiguous in the array, use o + offset (number of locations * the player).
			int idx = o + p * nLocs;
			float x = getLocX(idx);
			float z = getLocZ(idx);

			int fakeAreaID = rmCreateArea(cObjAreaLabel + " " + objCounter + " " + p + " " + o);
			rmSetAreaLocation(fakeAreaID, x, z);
			rmSetAreaSize(fakeAreaID, rmXMetersToFraction(0.1));
			rmSetAreaCoherence(fakeAreaID, 1.0);
			rmBuildArea(fakeAreaID);

			// New object with the constraint forcing it close to one of the areas.
			nearObjectID = createObjectFromStorage(cObjLabel + " " + objCounter + " " + p + " " + o, false); // Don't verify here to avoid blowing up the storage.

			// Create individual constraint so the object actually places close to the area.
			rmAddObjectDefConstraint(nearObjectID, createAreaMaxDistConstraint(fakeAreaID, objectDist));

			if(placeObjectDefForPlayer(getLocOwner(idx), nearObjectID, playerOwned, 1, minPlayerDist, maxPlayerDist, square, false) > 0) {
				break;
			}
		}

		// Update verification. Not very clean, but necessary to properly verify without blowing up the storage.
		if(verify) {
			// Use the last/placed object ID and store it.
			registerObjectDefVerifyFromID(cObjLabel + " " + objCounter + " " + p, nearObjectID);

			// Apply all stored items to the object.
			for(i = 0; < objectStorageCount) {
				addObjectDefItemVerify(nearObjectID, getObjectStorageProto(i), getObjectStorageItemCount(i), getObjectStorageDist(i));
			}

			// At this point, the object has double the items (but only half of them are tracked); since we won't be placing it anymore this is not a problem.

			// Enforce the check with the previously added items.
			updateObjectTargetPlaced(nearObjectID, 1);
		}
	}

	objCounter++;
}

/*****************
* MISC PLACEMENT *
*****************/

/*
** Places objects in a line.
**
** @param objectID: the object ID to place
** @param owner: the player number the object should belong to
** @param num: the number of objects to place in a line
** @param x1: x fraction of the placement starting location
** @param z1: z fraction of the placement starting location
** @param x2: x fraction of the placement ending location
** @param z2: z fraction of the placement ending location
** @param xVar: variance as a fraction in the x dimension
** @param zVar: variance as a fraction in the z dimension
*/
void placeObjectInLine(int objectID = -1, int owner = 0, int num = 0, float x1 = 0.0, float z1 = 0.0, float x2 = 0.0, float z2 = 0.0, float xVar = 0.0, float zVar = 0.0) {
	float xDist = (x2 - x1) / (num - 1);
	float zDist = (z2 - z1) / (num - 1);

	float x = x1;
	float z = z1;

	// Special case for 1 object.
	if(num == 1) {
		x = x + 0.5 * (x2 - x1);
		z = z + 0.5 * (z2 - z1);
	}

	for(j = 0; < num) {
		float tempXVar = rmRandFloat(0.0 - xVar, xVar);
		float tempZVar = rmRandFloat(0.0 - zVar, zVar);

		// Place object.
		placeObjectDefAtLoc(objectID, owner, x + tempXVar, z + tempZVar, 1);

		// Update coordinates for next iteration.
		x = x + xDist;
		z = z + zDist;
	}
}

/*
** Triggers for observer mode, merge mode, and balance rules.
** RebelsRising
** Last edit: 09/03/2021
**
** Code style in this file is not consistent for the sake of readability when injecting code.
**
** The triggers here could be a lot more efficient, consistent and simplified.
** This is especially the case for the live/continuous update triggers.
**
** As for injection, I try to inject as much as possible unless it is necessary to use "regular" commands (e.g. getPlayer(i)).
*/

// include "rmx_objects.xs";

/************************
* CONSTANTS & FUNCTIONS *
************************/

/*
** Injects the player constants and player mapping array.
*/
void injectPlayerConstants() {
	code("const int cTeams = " + cTeams + ";");
	code("const int cNonGaiaPlayers = " + cNonGaiaPlayers + ";");
	code("const int cPlayers = " + cPlayers + ";");
	code("const int cPlayersObs = " + cPlayersObs + ";");
	code("const int cPlayersMerged = " + cPlayersMerged + ";");
	code("const int cNumberTeams = " + cNumberTeams + ";");
	code("const int cNumberNonGaiaPlayers = " + cNumberNonGaiaPlayers + ";");
	code("const int cNumberPlayers = " + cNumberPlayers + ";");

	// Carry over values from rm script for player mapping.
	code("int getPlayer(int p = 0)");
	code("{");
		code("if(p == 1) return(" + getPlayer(1) + "); if(p == 2)  return(" + getPlayer(2) + ");  if(p == 3)  return(" + getPlayer(3) + ");  if(p == 4)  return(" + getPlayer(4) + ");");
		code("if(p == 5) return(" + getPlayer(5) + "); if(p == 6)  return(" + getPlayer(6) + ");  if(p == 7)  return(" + getPlayer(7) + ");  if(p == 8)  return(" + getPlayer(8) + ");");
		code("if(p == 9) return(" + getPlayer(9) + "); if(p == 10) return(" + getPlayer(10) + "); if(p == 11) return(" + getPlayer(11) + "); if(p == 12) return(" + getPlayer(12) + ");");
		code("return(0);");
	code("}");
}

/*
** Injects game constants (tech status, culture, major/minor god, techs).
*/
void injectGameConstants() {
	// Tech status constants.
	code("const int cTechStatusUnobtainable = 0;");
	code("const int cTechStatusObtainable = 1;");
	code("const int cTechStatusAvailable = 2;");
	code("const int cTechStatusResearching = 3;");
	code("const int cTechStatusActive = 4;");
	code("const int cTechStatusPersistent = 5;");

	// Culture constants.
	code("const int cCultureGreekID = 0;");
	code("const int cCultureEgyptianID = 1;");
	code("const int cCultureNorseID = 2;");
	code("const int cCultureAtlanteanID = 3;");
	// code("const int cCultureChineseID = 4;"); // Techs not supported.

	// Major god constants.
	code("const int cCivZeus = 0;");
	code("const int cCivPoseidon = 1;");
	code("const int cCivHades = 2;");
	code("const int cCivIsis = 3;");
	code("const int cCivRa = 4;");
	code("const int cCivSet = 5;");
	code("const int cCivOdin = 6;");
	code("const int cCivThor = 7;");
	code("const int cCivLoki = 8;");
	code("const int cCivKronos = 9;");
	code("const int cCivOuranos = 10;");
	code("const int cCivGaia = 11;");
	// code("const int cCivFuxiID = 12;"); // Techs not supported.
	// code("const int cCivNuwaID = 13;"); // Techs not supported.
	// code("const int cCivShennongID = 14;"); // Techs not supported.

	// Minor god constants.
	code("const int cMinorAthena = 0;");
	code("const int cMinorHermes = 1;");
	code("const int cMinorAres = 2;");
	code("const int cMinorApollo = 3;");
	code("const int cMinorDionysos = 4;");
	code("const int cMinorAphrodite = 5;");
	code("const int cMinorHephaestus = 6;");
	code("const int cMinorHera = 7;");
	code("const int cMinorArtemis = 8;");
	code("const int cMinorAnubis = 9;");
	code("const int cMinorBast = 10;");
	code("const int cMinorPtah = 11;");
	code("const int cMinorHathor = 12;");
	code("const int cMinorNephthys = 13;");
	code("const int cMinorSekhmet = 14;");
	code("const int cMinorOsiris = 15;");
	code("const int cMinorThoth = 16;");
	code("const int cMinorHorus = 17;");
	code("const int cMinorFreyja = 18;");
	code("const int cMinorHeimdall = 19;");
	code("const int cMinorForseti = 20;");
	code("const int cMinorNjord = 21;");
	code("const int cMinorSkadi = 22;");
	code("const int cMinorBragi = 23;");
	code("const int cMinorBaldr = 24;");
	code("const int cMinorTyr = 25;");
	code("const int cMinorHel = 26;");
	code("const int cMinorPrometheus = 27;");
	code("const int cMinorLeto = 28;");
	code("const int cMinorOceanus = 29;");
	code("const int cMinorHyperion = 30;");
	code("const int cMinorRheia = 31;");
	code("const int cMinorTheia = 32;");
	code("const int cMinorHelios = 33;");
	code("const int cMinorAtlas = 34;");
	code("const int cMinorHekate = 35;");

	// Tech IDs.
	code("const int cTechAge1 = 0;");
	code("const int cTechAge2 = 1;");
	code("const int cTechAge3 = 2;");
	code("const int cTechMediumArchers = 3;");
	code("const int cTechHeavyArchers = 4;");
	code("const int cTechChampionArchers = 5;");
	code("const int cTechMediumInfantry = 6;");
	code("const int cTechHeavyInfantry = 7;");
	code("const int cTechChampionInfantry = 8;");
	code("const int cTechHusbandry = 9;");
	code("const int cTechPlow = 10;");
	code("const int cTechIrrigation = 11;");
	code("const int cTechCopperWeapons = 12;");
	code("const int cTechBronzeWeapons = 13;");
	code("const int cTechIronWeapons = 14;");
	code("const int cTechCopperMail = 15;");
	code("const int cTechBronzeMail = 16;");
	code("const int cTechIronMail = 17;");
	code("const int cTechCopperShields = 18;");
	code("const int cTechBronzeShields = 19;");
	code("const int cTechIronShields = 20;");
	code("const int cTechAmbassadors = 21;");
	code("const int cTechTaxCollectors = 22;");
	code("const int cTechCoinage = 23;");
	code("const int cTechMediumCavalry = 24;");
	code("const int cTechHeavyCavalry = 25;");
	code("const int cTechChampionCavalry = 26;");
	code("const int cTechWatchTower = 27;");
	code("const int cTechGuardTower = 28;");
	code("const int cTechBallistaTower = 29;");
	code("const int cTechBoilingOil = 30;");
	code("const int cTechLevyInfantry = 31;");
	code("const int cTechBurningPitch = 32;");
	code("const int cTechMasons = 33;");
	code("const int cTechPickaxe = 34;");
	code("const int cTechHandAxe = 35;");
	code("const int cTechShaftMine = 36;");
	code("const int cTechBowSaw = 37;");
	code("const int cTechQuarry = 38;");
	code("const int cTechCarpenters = 39;");
	code("const int cTechBravery = 40;");
	code("const int cTechValleyOfTheKings = 41;");
	code("const int cTechLightningStorm = 42;");
	code("const int cTechLocustSwarm = 43;");
	code("const int cTechTornado = 44;");
	code("const int cTechWinterHarvest = 45;");
	code("const int cTechSafeguard = 46;");
	code("const int cTechRampage = 47;");
	code("const int cTechMithrilBreastplate = 48;");
	code("const int cTechCallOfValhalla = 49;");
	code("const int cTechArcticWinds = 50;");
	code("const int cTechArcticGale = 51;");
	code("const int cTechWrathOfTheDeep = 52;");
	code("const int cTechSpiritedCharge = 53;");
	code("const int cTechThunderingHooves = 54;");
	code("const int cTechBerserkergang = 55;");
	code("const int cTechRime = 56;");
	code("const int cTechFrost = 57;");
	code("const int cTechDraftHorses = 58;");
	code("const int cTechEngineers = 59;");
	code("const int cTechArchitects = 60;");
	code("const int cTechMeteor = 61;");
	code("const int cTechBoneBow = 62;");
	code("const int cTechAxeOfVengeance = 63;");
	code("const int cTechDesertWind = 64;");
	code("const int cTechEnclosedDeck = 65;");
	code("const int cTechArrowShipCladding = 66;");
	code("const int cTechFortifiedWall = 67;");
	code("const int cTechAge1Zeus = 68;");
	code("const int cTechSkinOfTheRhino = 69;");
	code("const int cTechAge15Egyptian = 70;");
	code("const int cTechSacredCats = 71;");
	code("const int cTechGraniteBlood = 72;");
	code("const int cTechHamarrtroll = 73;");
	code("const int cTechCriosphinx = 74;");
	code("const int cTechHieracosphinx = 75;");
	code("const int cTechMonstrousRage = 76;");
	code("const int cTechPhobosSpearOfPanic = 77;");
	code("const int cTechBacchanalia = 78;");
	code("const int cTechSunRay = 79;");
	code("const int cTechSylvanLore = 80;");
	code("const int cTechForgeOfOlympus = 81;");
	code("const int cTechAge1Hades = 82;");
	code("const int cTechAge1Poseidon = 83;");
	code("const int cTechCreateGold = 84;");
	code("const int cTechAge1Ra = 85;");
	code("const int cTechAge1Isis = 86;");
	code("const int cTechAge1Set = 87;");
	code("const int cTechAge1Odin = 88;");
	code("const int cTechAge1Thor = 89;");
	code("const int cTechAge1Loki = 90;");
	code("const int cTechAuroraBorealis = 91;");
	code("const int cTechAge2Athena = 92;");
	code("const int cTechAge2Ares = 93;");
	code("const int cTechAge2Hermes = 94;");
	code("const int cTechAge3Dionysos = 95;");
	code("const int cTechAge3Apollo = 96;");
	code("const int cTechAge3Aphrodite = 97;");
	code("const int cTechAge4Hera = 98;");
	code("const int cTechAge4Artemis = 99;");
	code("const int cTechAge4Hephaestus = 100;");
	code("const int cTechHuntingDogs = 101;");
	code("const int cTechHandOfTalos = 102;");
	code("const int cTechSarissa = 103;");
	code("const int cTechAegisShield = 104;");
	code("const int cTechWingedMessenger = 105;");
	code("const int cTechAge2Anubis = 106;");
	code("const int cTechAge2Bast = 107;");
	code("const int cTechAge2Ptah = 108;");
	code("const int cTechAge3Hathor = 109;");
	code("const int cTechAge3Nephthys = 110;");
	code("const int cTechAge3Sekhmet = 111;");
	code("const int cTechAge4Thoth = 112;");
	code("const int cTechAge4Osiris = 113;");
	code("const int cTechAge4Horus = 114;");
	code("const int cTechFeetOfTheJackal = 115;");
	code("const int cTechAge4 = 116;");
	code("const int cTechAge2Forseti = 117;");
	code("const int cTechAge2Heimdall = 118;");
	code("const int cTechAge2Freyja = 119;");
	code("const int cTechAge3Skadi = 120;");
	code("const int cTechAge3Bragi = 121;");
	code("const int cTechAge3Njord = 122;");
	code("const int cTechAge4Hel = 123;");
	code("const int cTechAge4Baldr = 124;");
	code("const int cTechAge4Tyr = 125;");
	code("const int cTechSignalFires = 126;");
	code("const int cTechStoneWall = 127;");
	code("const int cTechShoulderOfTalos = 128;");
	code("const int cTechSkeletonPower = 129;");
	code("const int cTechBookOfThoth = 130;");
	code("const int cTechFaceOfTheGorgon = 131;");
	code("const int cTechCitadelWall = 132;");
	code("const int cTechUnderworldPassage = 133;");
	code("const int cTechRestoration = 134;");
	code("const int cTechConscriptInfantry = 135;");
	code("const int cTechLevyArchers = 136;");
	code("const int cTechConscriptArchers = 137;");
	code("const int cTechLevyCavalry = 138;");
	code("const int cTechConscriptCavalry = 139;");
	code("const int cTechCarrierPigeons = 140;");
	code("const int cTechFloodControl = 141;");
	code("const int cTechPharaohRespawn = 142;");
	code("const int cTechStartingUnitsNorse = 143;");
	code("const int cTechStartingUnitsGreek = 144;");
	code("const int cTechStartingUnitsEgyptian = 145;");
	code("const int cTechGreatHunt = 146;");
	code("const int cTechCeaseFire = 147;");
	code("const int cTechMonument1 = 148;");
	code("const int cTechMonument2 = 149;");
	code("const int cTechMonument3 = 150;");
	code("const int cTechMonument4 = 151;");
	code("const int cTechUndermine = 152;");
	code("const int cTechDwarvenMail = 153;");
	code("const int cTechDwarvenShields = 154;");
	code("const int cTechDwarvenWeapons = 155;");
	code("const int cTechRain = 156;");
	code("const int cTechSerpentSpear = 157;");
	code("const int cTechFloodOfTheNile = 158;");
	code("const int cTechVaultsOfErebus = 159;");
	code("const int cTechLordOfHorses = 160;");
	code("const int cTechOlympicParentage = 161;");
	code("const int cTechPigSticker = 162;");
	code("const int cTechLoneWanderer = 163;");
	code("const int cTechEyesInTheForest = 164;");
	code("const int cTechScallopedAxe = 165;");
	code("const int cTechRingGiver = 166;");
	code("const int cTechLongSerpent = 167;");
	code("const int cTechSwineArray = 168;");
	code("const int cTechAge15Norse = 169;");
	code("const int cTechAge15Greek = 170;");
	code("const int cTechOdinsRavenRespawn = 171;");
	code("const int cTechSnowStorm = 172;");
	code("const int cTechHeavyCamelry = 173;");
	code("const int cTechChampionCamelry = 174;");
	code("const int cTechBronze = 175;");
	code("const int cTechPharaohRespawnOsiris = 176;");
	code("const int cTechNewKingdom = 177;");
	code("const int cTechMedjay = 178;");
	code("const int cTechFuneralRites = 179;");
	code("const int cTechSpiritOfMaat = 180;");
	code("const int cTechCityOfTheDead = 181;");
	code("const int cTechFortifyTownCenter = 182;");
	code("const int cTechHeroesZeusAge2 = 183;");
	code("const int cTechHeroesZeusAge3 = 184;");
	code("const int cTechHeroesZeusAge4 = 185;");
	code("const int cTechHeroesPoseidonAge2 = 186;");
	code("const int cTechHeroesPoseidonAge3 = 187;");
	code("const int cTechHeroesPoseidonAge4 = 188;");
	code("const int cTechHeroesHadesAge2 = 189;");
	code("const int cTechHeroesHadesAge3 = 190;");
	code("const int cTechHeroesHadesAge4 = 191;");
	code("const int cTechShaduf = 192;");
	code("const int cTechMonument0 = 193;");
	code("const int cTechRelicAnkhOfRa = 194;");
	code("const int cTechRelicEyeOfHorus = 195;");
	code("const int cTechRelicSistrumOfBast = 196;");
	code("const int cTechRelicHeadOfOrpheus = 197;");
	code("const int cTechRelicRingOfTheNibelung = 198;");
	code("const int cTechRelicStaffOfDionysus = 199;");
	code("const int cTechRelicFettersOfFenrir = 200;");
	code("const int cTechRelicOdinsSpear = 201;");
	code("const int cTechRelicKitharaOfApollo = 202;");
	code("const int cTechRelicMithrilHorseshoes = 203;");
	code("const int cTechRelicBowOfArtemis = 204;");
	code("const int cTechRelicWedjatEye = 205;");
	code("const int cTechRelicNoseOfTheSphinx = 206;");
	code("const int cTechGoldenApples = 207;");
	code("const int cTechElhrimnirKettle = 208;");
	code("const int cTechRelicArrowsOfAlfar = 209;");
	code("const int cTechRelicToothedArrows = 210;");
	code("const int cTechRelicWandOfGambantein = 211;");
	code("const int cTechProsperity = 212;");
	code("const int cTechPegasusRelicRespawn = 213;");
	code("const int cTechRelicGoldenBridleOfPegasus = 214;");
	code("const int cTechEclipse = 215;");
	code("const int cTechWillOfKronos = 216;");
	code("const int cTechLabyrinthOfMinos = 217;");
	code("const int cTechFlamesOfTyphon = 218;");
	code("const int cTechDivineBlood = 219;");
	code("const int cTechShaftsOfPlague = 220;");
	code("const int cTechVision = 221;");
	code("const int cTechBolt = 222;");
	code("const int cTechSpy = 223;");
	code("const int cTechFlamingWeapons = 224;");
	code("const int cTechFlamingWeaponsActive = 225;");
	code("const int cTechLossOfLOS = 226;");
	code("const int cTechSerpents = 227;");
	code("const int cTechAnimalMagnetism = 228;");
	code("const int cTechHealingSpring = 229;");
	code("const int cTechCurse = 230;");
	code("const int cTechSentinel = 231;");
	code("const int cTechSandstorm = 232;");
	code("const int cTechCitadel = 233;");
	code("const int cTechWalkingWoods = 234;");
	code("const int cTechRagnorok = 235;");
	code("const int cTechNidhogg = 236;");
	code("const int cTechPlenty = 237;");
	code("const int cTechSonOfOsiris = 238;");
	code("const int cTechPharaohRespawnCityOfTheDead = 239;");
	code("const int cTechEarthquake = 240;");
	code("const int cTechAthenianWall = 241;");
	code("const int cTechHeroesHadesAge1 = 242;");
	code("const int cTechHeroesPoseidonAge1 = 243;");
	code("const int cTechHeroesZeusAge1 = 244;");
	code("const int cTechDwarvenAuger = 245;");
	code("const int cTechPurseSeine = 246;");
	code("const int cTechReinforcedRam = 247;");
	code("const int cTechHuntressAxe = 248;");
	code("const int cTechForestFire = 249;");
	code("const int cTechPestilence = 250;");
	code("const int cTechRelicTriosBow = 251;");
	code("const int cTechRelicShardOfBlueCrystal = 252;");
	code("const int cTechRelicArmorOfAchilles = 253;");
	code("const int cTechRelicShipOfFingernails = 254;");
	code("const int cTechCrocodopolis = 255;");
	code("const int cTechLeatherFrameShield = 256;");
	code("const int cTechElectrumBullets = 257;");
	code("const int cTechStonesOfRedLinen = 258;");
	code("const int cTechSpearOnTheHorizon = 259;");
	code("const int cTechFeral = 260;");
	code("const int cTechAnastrophe = 261;");
	code("const int cTechTrierarch = 262;");
	code("const int cTechThracianHorses = 263;");
	code("const int cTechRelicShinglesOfSteel = 264;");
	code("const int cTechRelicEyeOfOrnlu = 265;");
	code("const int cTechRelicTuskOfTheIronBoar = 266;");
	code("const int cTechAssignLOS = 267;");
	code("const int cTechRoarOfOrthus = 268;");
	code("const int cTechAtefCrown = 269;");
	code("const int cTechConscriptSailors = 270;");
	code("const int cTechNavalOxybeles = 271;");
	code("const int cTechEnyosBowOfHorror = 272;");
	code("const int cTechDeimosSwordOfDread = 273;");
	code("const int cTechChampionElephants = 274;");
	code("const int cTechHallOfThanes = 275;");
	code("const int cTechAdzeOfWepwawet = 276;");
	code("const int cTechSlingsOfTheSun = 277;");
	code("const int cTechRamOfTheWestWind = 278;");
	code("const int cTechSunDriedMudBrick = 279;");
	code("const int cTechFuneralBarge = 280;");
	code("const int cTechNecropolis = 281;");
	code("const int cTechDisableArmoryForThor = 282;");
	code("const int cTechIronMailThor = 283;");
	code("const int cTechBronzeMailThor = 284;");
	code("const int cTechBronzeShieldsThor = 285;");
	code("const int cTechBronzeWeaponsThor = 286;");
	code("const int cTechIronShieldsThor = 287;");
	code("const int cTechIronWeaponsThor = 288;");
	code("const int cTechBurningPitchThor = 289;");
	code("const int cTechHammerOfTheGods = 290;");
	code("const int cTechMeteoricIronMail = 291;");
	code("const int cTechDragonscaleShields = 292;");
	code("const int cTechTusksOfApedemak = 293;");
	code("const int cTechRelicPandorasBox = 294;");
	code("const int cTechRelicHerasThundercloudShawl = 295;");
	code("const int cTechRelicHarmoniasNecklace = 296;");
	code("const int cTechRelicDwarfenCalipers = 297;");
	code("const int cTechOracle = 298;");
	code("const int cTechSonsOfSleipnir = 299;");
	code("const int cTechSetAge2Critter = 300;");
	code("const int cTechSetAge3Critter = 301;");
	code("const int cTechSetAge4Critter = 302;");
	code("const int cTechPoseidonHippocampusRespawn = 303;");
	code("const int cTechEgyptianBuildingBonus = 304;");
	code("const int cTechOmniscience = 305;");
	code("const int cTechMediumAxemen = 306;");
	code("const int cTechHeavyAxemen = 307;");
	code("const int cTechChampionAxemen = 308;");
	code("const int cTechMediumSpearmen = 309;");
	code("const int cTechHeavySpearmen = 310;");
	code("const int cTechChampionSpearmen = 311;");
	code("const int cTechHeavyChariots = 312;");
	code("const int cTechChampionChariots = 313;");
	code("const int cTechHeavyElephants = 314;");
	code("const int cTechLevyBarracksSoldiers = 315;");
	code("const int cTechConscriptBarracksSoldiers = 316;");
	code("const int cTechLevyMigdolSoldiers = 317;");
	code("const int cTechConscriptMigdolSoldiers = 318;");
	code("const int cTechMediumSlingers = 319;");
	code("const int cTechHeavySlingers = 320;");
	code("const int cTechChampionSlingers = 321;");
	code("const int cTechRelicGoldenLions = 322;");
	code("const int cTechRelicMonkeyHead = 323;");
	code("const int cTechLevyLonghouseSoldiers = 324;");
	code("const int cTechConscriptLonghouseSoldiers = 325;");
	code("const int cTechConscriptHillFortSoldiers = 326;");
	code("const int cTechLevyHillFortSoldiers = 327;");
	code("const int cTechThurisazRune = 328;");
	code("const int cTechGoldenLionsRelicRespawn = 329;");
	code("const int cTechMonkeyHeadRelicRespawn = 330;");
	code("const int cTechRelicCanopicJarOfImsety = 331;");
	code("const int cTechRelicTowerOfSestus = 332;");
	code("const int cTechRelicTrojanGateHinge = 333;");
	code("const int cTechSPCMeteor = 334;");
	code("const int cTechOdinsFirstRavens = 335;");
	code("const int cTechHeroesEgyptianAge1 = 336;");
	code("const int cTechWeakenAge1Units = 337;");
	code("const int cTechSaltAmphora = 338;");
	code("const int cTechMediumMigdolShadow = 339;");
	code("const int cTechPoseidonFirstHippocampus = 340;");
	code("const int cTechTempleOfHealing = 341;");
	code("const int cTechGreatestOfFifty = 342;");
	code("const int cTechCopperMailThor = 343;");
	code("const int cTechCopperShieldsThor = 344;");
	code("const int cTechCopperWeaponsThor = 345;");
	code("const int cTechWeaponOfTheTitans = 346;");
	code("const int cTechAge2Fake = 347;");
	code("const int cTechAge3Fake = 348;");
	code("const int cTechAge4Fake = 349;");
	code("const int cTechCrenellations = 350;");
	code("const int cTechBlessingOfZeus = 351;");
	code("const int cTechRelicGirdleOfHippolyta = 352;");
	code("const int cTechSharedLOS = 353;");
	code("const int cTechRelicPygmalionsStatue = 354;");
	code("const int cTechRelicBlackLotus = 355;");
	code("const int cTechDeathmatchGreek = 356;");
	code("const int cTechDeathmatchEgyptian = 357;");
	code("const int cTechDeathmatchNorse = 358;");
	code("const int cTechCeasefireEffect = 359;");
	code("const int cTechNorsebuildingBonus = 360;");
	code("const int cTechLightningMode = 361;");
	code("const int cTechFortifiedTents = 362;");
	code("const int cTechDwarvenShieldsEffect = 363;");
	code("const int cTechRelicHartersFolly = 364;");
	code("const int cTechRelicScarabPendant = 365;");
	code("const int cTechWellOfUrd = 366;");
	code("const int cTechRelicBootsOfKickEverything = 367;");
	code("const int cTechRelicAnvilOfHephaestus = 368;");
	code("const int cTechRelicPeltOfArgus = 369;");
	code("const int cTechRelicOsebergWagon = 370;");
	code("const int cTechRelicBuhenFlagstone = 371;");
	code("const int cTechRelicCatoblepasScales = 372;");
	code("const int cTechRelicTailOfCerberus = 373;");
	code("const int cTechRelicBlanketOfEmpressZoe = 374;");
	code("const int cTechRelicKhopeshOfHorus = 375;");
	code("const int cTechCeaseFireNomad = 376;");
	code("const int cTechEclipseActive = 377;");
	code("const int cTechPlentyKOTHenable = 378;");
	code("const int cTechStartingUnitsThor = 379;");
	code("const int cTechSetAge1Critter = 380;");
	code("const int cTechStartingResourcesEgyptian = 381;");
	code("const int cTechStartingResourcesGreek = 382;");
	code("const int cTechStartingResourcesNorse = 383;");
	code("const int cTechRelicReedOfNekhebet = 384;");
	code("const int cTechWeakenTrojanGate = 385;");
	code("const int cTechBuildTCFaster = 386;");
	code("const int cTechIncreaseRegeneration = 387;");
	code("const int cTechChickenStorm = 388;");
	code("const int cTechWalkingBerryBushes = 389;");
	code("const int cTechEliteHersir = 390;");
	code("const int cTechGoatunheim = 391;");
	code("const int cTechAge1Kronos = 392;");
	code("const int cTechAge1Gaia = 393;");
	code("const int cTechStartingUnitsAtlantean = 394;");
	code("const int cTechAge1Ouranos = 395;");
	code("const int cTechStartingResourcesAtlantean = 396;");
	code("const int cTechAge2Oceanus = 397;");
	code("const int cTechAge2Prometheus = 398;");
	code("const int cTechAge2Leto = 399;");
	code("const int cTechAge3Hyperion = 400;");
	code("const int cTechAge3Rheia = 401;");
	code("const int cTechAge3Theia = 402;");
	code("const int cTechAge4Helios = 403;");
	code("const int cTechAge4Hekate = 404;");
	code("const int cTechAge4Atlas = 405;");
	code("const int cTechReverseTime = 406;");
	code("const int cTechAudrey = 407;");
	code("const int cTechTraitors = 408;");
	code("const int cTechChaos = 409;");
	code("const int cTechVolcano = 410;");
	code("const int cTechBronzeWall = 411;");
	code("const int cTechIronWall = 412;");
	code("const int cTechOrichalkosWall = 413;");
	code("const int cTechTremor = 414;");
	code("const int cTechHeavyFireship = 415;");
	code("const int cTechHeartOfTheTitans = 416;");
	code("const int cTechHephaestusRevenge = 417;");
	code("const int cTechGaiaForest = 418;");
	code("const int cTechTartarianGate = 419;");
	code("const int cTechLevyMainlineUnits = 420;");
	code("const int cTechLevySpecialtyUnits = 421;");
	code("const int cTechLevyPalaceUnits = 422;");
	code("const int cTechConscriptMainlineUnits = 423;");
	code("const int cTechConscriptSpecialtyUnits = 424;");
	code("const int cTechConscriptPalaceUnits = 425;");
	code("const int cTechHaloOfTheSun = 426;");
	code("const int cTechHornsOfConsecration = 427;");
	code("const int cTechLemurianDescendants = 428;");
	code("const int cTechChannels = 429;");
	code("const int cTechAlluvialClay = 430;");
	code("const int cTechVortex = 431;");
	code("const int cTechMythicRejuvenation = 432;");
	code("const int cTechHeroicRenewal = 433;");
	code("const int cTechReverseWonder = 434;");
	code("const int cTechBiteOfTheShark = 435;");
	code("const int cTechHesperides = 436;");
	code("const int cTechHeavyChieroballista = 437;");
	code("const int cTechSpiders = 438;");
	code("const int cTechHeroize = 439;");
	code("const int cTechGemino = 440;");
	code("const int cTechNorseArmory = 441;");
	code("const int cTechImplode = 442;");
	code("const int cTechSecretsOfTheTitans = 443;");
	code("const int cTechTitanGate = 444;");
	code("const int cTechDisableTitan = 445;");
	code("const int cTechFocus = 446;");
	code("const int cTechSafePassage = 447;");
	code("const int cTechHeroicFleet = 448;");
	code("const int cTechWeightlessMace = 449;");
	code("const int cTechEyesOfAtlas = 450;");
	code("const int cTechAsperBlood = 451;");
	code("const int cTechTitanShield = 452;");
	code("const int cTechPoseidonsSecret = 453;");
	code("const int cTechRelicWhirlwindSPC = 454;");
	code("const int cTechRelicOfBronzeSPC = 455;");
	code("const int cTechRelicOfEarthquakeSPC = 456;");
	code("const int cTechBronzeXP05 = 457;");
	code("const int cTechTornadoXP05 = 458;");
	code("const int cTechRelicTitansTreasure = 459;");
	code("const int cTechVolcanicForge = 460;");
	code("const int cTechRelicGaiasBookOfKnowledge = 461;");
	code("const int cTechChangeCyclops = 462;");
	code("const int cTechChangeChimera = 463;");
	code("const int cTechChangeCaladria = 464;");
	code("const int cTechChangeManticore = 465;");
	code("const int cTechChangeNemean = 466;");
	code("const int cTechChangeHydra = 467;");
	code("const int cTechSPCLightningStorm = 468;");
	code("const int cTechDeathmatchAtlantean = 469;");
	code("const int cTechMailOfOrichalkos = 470;");
	code("const int cTechHandsOfThePharaoh = 471;");
	code("const int cTechBronzeAll = 472;");
	code("const int cTechBronzeAllThor = 473;");
	code("const int cTechCopperAll = 474;");
	code("const int cTechCopperAllThor = 475;");
	code("const int cTechIronAll = 476;");
	code("const int cTechIronAllThor = 477;");
	code("const int cTechMediumAll = 478;");
	code("const int cTechHeavyAll = 479;");
	code("const int cTechChampionAll = 480;");
	code("const int cTechRheiasGift = 481;");
	code("const int cTechTimeShiftFake = 482;");
	code("const int cTechFocusTurbo = 483;");
	code("const int cTechCelerity = 484;");
	code("const int cTechSeedOfGaia = 485;");
	code("const int cTechGrantPhoenixEgg = 486;");
	code("const int cTechIoGuardian = 487;");
	code("const int cTechDisableAtlanteanFavor = 488;");
	code("const int cTechTimeShiftFake2 = 489;");
	code("const int cTechAxeOfMuspell = 490;");
	code("const int cTechChampionChieroballista = 491;");
	code("const int cTechTraitorsSPC = 492;");
	code("const int cTechSuperRocs = 493;");
	code("const int cTechBeastSlayer = 494;");
	code("const int cTechLanceOfStone = 495;");
	code("const int cTechSuddenDeathAtlantean = 496;");
	code("const int cTechRelicOfAncestorsSPC = 497;");
	code("const int cTechSuperTitanSPC = 498;");
	code("const int cTechSuperNidhoggSPC = 499;");
	code("const int cTechPetrified = 500;");
	code("const int cTechPrometheusWeak = 501;");
	code("const int cTechPrometheusWeakest = 502;");
	code("const int cTechAge2AtlanteanHeroes = 503;");
	code("const int cTechAge4AtlanteanHeroes = 504;");
	code("const int cTechAge15Atlantean = 505;");
	code("const int cTechGaiaForestSPC = 506;");
	code("const int cTechRainFix = 507;");
	code("const int cTechAge2Odin = 508;");
	code("const int cTechAge3Odin = 509;");
	code("const int cTechAge4Odin = 510;");
	code("const int cTechGaiaPlow = 511;");
	code("const int cTechGaiaIrrigation = 512;");
	code("const int cTechGaiaFloodControl = 513;");
	code("const int cTechGaiaPickaxe = 514;");
	code("const int cTechGaiaShaftMine = 515;");
	code("const int cTechGaiaQuarry = 516;");
	code("const int cTechGaiaHandAxe = 517;");
	code("const int cTechGaiaBowSaw = 518;");
	code("const int cTechGaiaCarpenters = 519;");
	code("const int cTechGaiaHusbandry = 520;");
	code("const int cTechGaiaHuntingDogs = 521;");
	code("const int cTechGaiaPurseSeine = 522;");
	code("const int cTechGaiaSaltAmphora = 523;");
	code("const int cTechSetAge1AnimalSpeed = 524;");
}

/*
** Injects misc utility functions.
*/
void injectMiscUtil() {
	// Minimum.
	code("int min(int a = 0, int b = 9999999)");
	code("{");
		code("if(a > b)");
		code("{");
			code("return(b);");
		code("}");

		code("return(a);");
	code("}");

	// Function to calculate timestamp.
	code("string timeStamp(int time = 0)");
	code("{");

		code("int s = time;");

		// Modulo doesn't work here, find seconds manually.
		code("while(s >= 60)");
		code("{");
			code("s = s - 60;");
		code("}");

		// If less than 10 seconds, add a 0 (e.g., for 05) and return in mm:ss format.
		code("if(s < 10)");
		code("{");
			code("return(\"\" + time / 60 + \":0\" + s);");
		code("} else {");
			code("return(\"\" + time / 60 + \":\" + s);");
		code("}");

	code("}");
}

/*
** Injects array functionality.
*/
void injectArrayUtil() {
	// Keeps track of position for UnitPicks (increased by size of array upon array creation).
	code("int numUnitPicks = -1;");

	// Creates a new array.
	code("int arrayCreate(int size = 1)");
	code("{");
		code("int oldContext = xsGetContextPlayer();");
		code("xsSetContextPlayer(0);");

		code("if(numUnitPicks == -1)");
		code("{");

			// 2867 = max value to use.
			code("for(i = 0; < 2867)");
			code("{");
				code("kbUnitPickCreate(\"\" + i);");
				code("kbUnitPickSetMinimumPop(i, -1);");
				code("kbUnitPickSetMaximumPop(i, -1);");
				code("kbUnitPickSetPreferenceWeight(i, -1);");
			code("}");

			code("numUnitPicks = 0;");
		code("}");


		code("int ret = numUnitPicks;");
		code("numUnitPicks = numUnitPicks + size;");
		code("kbUnitPickSetMaximumPop(ret, 0);");
		code("xsSetContextPlayer(oldContext);");

		code("return(ret);");
	code("}");

	// Retrieves a value stored in an array as int.
	code("int arrayGetInt(int array = -1, int index = -1, bool asFloat = false)");
	code("{");
		code("int oldContext = xsGetContextPlayer();");
		code("xsSetContextPlayer(0);");
		code("int ret = -1;");

		code("if(asFloat == false)");
		code("{");
			code("ret = kbUnitPickGetMinimumPop(array + index);");
		code("} else {");
			code("ret = kbUnitPickGetPreferenceWeight(array + index);");
		code("}");

		code("xsSetContextPlayer(oldContext);");

		code("return(ret);");
	code("}");

	// Sets an int in an array.
	code("void arraySetInt(int array = -1, int index = -1, int value = -1, bool asFloat = false)");
	code("{");
		code("int oldContext = xsGetContextPlayer();");
		code("xsSetContextPlayer(0);");

		code("if(asFloat == false)");
		code("{");
			code("kbUnitPickSetMinimumPop(array + index, value);");
		code("} else {");
			code("float val = value;");
			code("kbUnitPickSetPreferenceWeight(array + index, val);");
		code("}");

		code("if(index >= kbUnitPickGetMaximumPop(array))");
		code("{");
			code("kbUnitPickSetMaximumPop(array, index + 1);");
		code("}");

		code("xsSetContextPlayer(oldContext);");
	code("}");

	// Retrieves the size of an array.
	code("int arrayGetSize(int array = -1)");
	code("{");
		code("int oldContext = xsGetContextPlayer();");
		code("xsSetContextPlayer(0);");

		code("int ret = kbUnitPickGetMaximumPop(array);");

		code("xsSetContextPlayer(oldContext);");

		code("return(ret);");
	code("}");

	// Appends a value to an array.
	code("void arrayAppend(int array = -1, int value = -1)");
	code("{");
		code("int oldContext = xsGetContextPlayer();");
		code("xsSetContextPlayer(0);");

		code("int index = kbUnitPickGetMaximumPop(array);");
		code("kbUnitPickSetMaximumPop(array, index + 1);");
		code("kbUnitPickSetMinimumPop(array + index, value);");

		code("xsSetContextPlayer(oldContext);");
	code("}");

	// Removes a value from an array (effectively decreasing the size).
	code("void arrayRemoveInt(int array = -1, int index = -1)");
	code("{");
		code("for(i = index; < arrayGetSize(array))");
		code("{");
			code("arraySetInt(array, i, arrayGetInt(array, i + 1));");
			code("arraySetInt(array, i, arrayGetInt(array, i + 1, true), true);");
		code("}");

		code("int oldContext = xsGetContextPlayer();");
		code("xsSetContextPlayer(0);");

		code("int size = kbUnitPickGetMaximumPop(array);");
		code("if(size > 0)");
		code("{");
			code("kbUnitPickSetMaximumPop(array, size - 1);");
		code("}");

		code("xsSetContextPlayer(oldContext);");
	code("}");
}

/*
** Injects utility functions to add techs to an array depending on the civilization.
*/
void injectTechArrayUtil() {
	// Adds all techs of a minor god to an array.
	code("void addMinorGod(int array = -1, int m = -1)");
	code("{");
		code("if(m == cMinorAthena) {");
			code("arrayAppend(array, cTechLabyrinthOfMinos);");
			code("arrayAppend(array, cTechAegisShield);");
			code("arrayAppend(array, cTechSarissa);");
		code("}");
		code("else if(m == cMinorHermes) {");
			code("arrayAppend(array, cTechSylvanLore);");
			code("arrayAppend(array, cTechWingedMessenger);");
			code("arrayAppend(array, cTechSpiritedCharge);");
		code("}");
		code("else if(m == cMinorAres) {");
			code("arrayAppend(array, cTechWillOfKronos);");
			code("arrayAppend(array, cTechPhobosSpearOfPanic);");
			code("arrayAppend(array, cTechDeimosSwordOfDread);");
			code("arrayAppend(array, cTechEnyosBowOfHorror);");
		code("}");
		code("else if(m == cMinorApollo) {");
			code("arrayAppend(array, cTechSunRay);");
			code("arrayAppend(array, cTechOracle);");
			code("arrayAppend(array, cTechTempleOfHealing);");
		code("}");
		code("else if(m == cMinorDionysos) {");
			code("arrayAppend(array, cTechBacchanalia);");
			code("arrayAppend(array, cTechThracianHorses);");
			code("arrayAppend(array, cTechAnastrophe);");
		code("}");
		code("else if(m == cMinorAphrodite) {");
			code("arrayAppend(array, cTechDivineBlood);");
			code("arrayAppend(array, cTechGoldenApples);");
			code("arrayAppend(array, cTechRoarOfOrthus);");
		code("}");
		code("else if(m == cMinorHephaestus) {");
			code("arrayAppend(array, cTechForgeOfOlympus);");
			code("arrayAppend(array, cTechWeaponOfTheTitans);");
			code("arrayAppend(array, cTechShoulderOfTalos);");
			code("arrayAppend(array, cTechHandOfTalos);");
		code("}");
		code("else if(m == cMinorHera) {");
			code("arrayAppend(array, cTechMonstrousRage);");
			code("arrayAppend(array, cTechAthenianWall);");
			code("arrayAppend(array, cTechFaceOfTheGorgon);");
		code("}");
		code("else if(m == cMinorArtemis) {");
			code("arrayAppend(array, cTechShaftsOfPlague);");
			code("arrayAppend(array, cTechFlamesOfTyphon);");
			code("arrayAppend(array, cTechTrierarch);");
		code("}");
		code("else if(m == cMinorAnubis) {");
			code("arrayAppend(array, cTechNecropolis);");
			code("arrayAppend(array, cTechSerpentSpear);");
			code("arrayAppend(array, cTechFeetOfTheJackal);");
		code("}");
		code("else if(m == cMinorBast) {");
			code("arrayAppend(array, cTechAdzeOfWepwawet);");
			code("arrayAppend(array, cTechSacredCats);");
			code("arrayAppend(array, cTechCriosphinx);");
			code("arrayAppend(array, cTechHieracosphinx);");
		code("}");
		code("else if(m == cMinorPtah) {");
			code("arrayAppend(array, cTechShaduf);");
			code("arrayAppend(array, cTechScallopedAxe);");
			code("arrayAppend(array, cTechLeatherFrameShield);");
			code("arrayAppend(array, cTechElectrumBullets);");
		code("}");
		code("else if(m == cMinorHathor) {");
			code("arrayAppend(array, cTechMedjay);");
			code("arrayAppend(array, cTechCrocodopolis);");
			code("arrayAppend(array, cTechSunDriedMudBrick);");
		code("}");
		code("else if(m == cMinorNephthys) {");
			code("arrayAppend(array, cTechSpiritOfMaat);");
			code("arrayAppend(array, cTechFuneralRites);");
			code("arrayAppend(array, cTechCityOfTheDead);");
		code("}");
		code("else if(m == cMinorSekhmet) {");
			code("arrayAppend(array, cTechStonesOfRedLinen);");
			code("arrayAppend(array, cTechRamOfTheWestWind);");
			code("arrayAppend(array, cTechSlingsOfTheSun);");
			code("arrayAppend(array, cTechBoneBow);");
		code("}");
		code("else if(m == cMinorOsiris) {");
			code("arrayAppend(array, cTechAtefCrown);");
			code("arrayAppend(array, cTechDesertWind);");
			code("arrayAppend(array, cTechNewKingdom);");
			code("arrayAppend(array, cTechFuneralBarge);");
		code("}");
		code("else if(m == cMinorThoth) {");
			code("arrayAppend(array, cTechValleyOfTheKings);");
			code("arrayAppend(array, cTechTusksOfApedemak);");
			code("arrayAppend(array, cTechBookOfThoth);");
		code("}");
		code("else if(m == cMinorHorus) {");
			code("arrayAppend(array, cTechAxeOfVengeance);");
			code("arrayAppend(array, cTechGreatestOfFifty);");
			code("arrayAppend(array, cTechSpearOnTheHorizon);");
		code("}");
		code("else if(m == cMinorFreyja) {");
			code("arrayAppend(array, cTechAuroraBorealis);");
			code("arrayAppend(array, cTechThunderingHooves);");
		code("}");
		code("else if(m == cMinorHeimdall) {");
			code("arrayAppend(array, cTechSafeguard);");
			code("arrayAppend(array, cTechElhrimnirKettle);");
			code("arrayAppend(array, cTechArcticWinds);");
		code("}");
		code("else if(m == cMinorForseti) {");
			code("arrayAppend(array, cTechHallOfThanes);");
			code("arrayAppend(array, cTechMithrilBreastplate);");
			code("arrayAppend(array, cTechHamarrtroll);");
		code("}");
		code("else if(m == cMinorNjord) {");
			code("arrayAppend(array, cTechRingGiver);");
			code("arrayAppend(array, cTechWrathOfTheDeep);");
			code("arrayAppend(array, cTechLongSerpent);");
		code("}");
		code("else if(m == cMinorSkadi) {");
			code("arrayAppend(array, cTechRime);");
			code("arrayAppend(array, cTechWinterHarvest);");
			code("arrayAppend(array, cTechHuntressAxe);");
		code("}");
		code("else if(m == cMinorBragi) {");
			code("arrayAppend(array, cTechSwineArray);");
			code("arrayAppend(array, cTechThurisazRune);");
			code("arrayAppend(array, cTechCallOfValhalla);");
		code("}");
		code("else if(m == cMinorBaldr) {");
			code("arrayAppend(array, cTechArcticGale);");
			code("arrayAppend(array, cTechSonsOfSleipnir);");
			code("arrayAppend(array, cTechDwarvenAuger);");
		code("}");
		code("else if(m == cMinorTyr) {");
			code("arrayAppend(array, cTechBerserkergang);");
			code("arrayAppend(array, cTechBravery);");
		code("}");
		code("else if(m == cMinorHel) {");
			code("arrayAppend(array, cTechRampage);");
			code("arrayAppend(array, cTechGraniteBlood);");
		code("}");
		code("else if(m == cMinorPrometheus) {");
			code("arrayAppend(array, cTechHeartOfTheTitans);");
			code("arrayAppend(array, cTechAlluvialClay);");
		code("}");
		code("else if(m == cMinorLeto) {");
			code("arrayAppend(array, cTechHephaestusRevenge);");
			code("arrayAppend(array, cTechVolcanicForge);");
		code("}");
		code("else if(m == cMinorOceanus) {");
			code("arrayAppend(array, cTechBiteOfTheShark);");
			code("arrayAppend(array, cTechWeightlessMace);");
		code("}");
		code("else if(m == cMinorHyperion) {");
			code("arrayAppend(array, cTechGemino);");
			code("arrayAppend(array, cTechHeroicRenewal);");
		code("}");
		code("else if(m == cMinorRheia) {");
			code("arrayAppend(array, cTechHornsOfConsecration);");
			code("arrayAppend(array, cTechMailOfOrichalkos);");
			code("arrayAppend(array, cTechRheiasGift);");
		code("}");
		code("else if(m == cMinorTheia) {");
			code("arrayAppend(array, cTechLanceOfStone);");
			code("arrayAppend(array, cTechPoseidonsSecret);");
			code("arrayAppend(array, cTechLemurianDescendants);");
		code("}");
		code("else if(m == cMinorHelios) {");
			code("arrayAppend(array, cTechPetrified);");
			code("arrayAppend(array, cTechHaloOfTheSun);");
		code("}");
		code("else if(m == cMinorAtlas) {");
			code("arrayAppend(array, cTechTitanShield);");
			code("arrayAppend(array, cTechEyesOfAtlas);");
			code("arrayAppend(array, cTechIoGuardian);");
		code("}");
		code("else if(m == cMinorHekate) {");
			code("arrayAppend(array, cTechMythicRejuvenation);");
			code("arrayAppend(array, cTechCelerity);");
			code("arrayAppend(array, cTechAsperBlood);");
		code("}");
	code("}");

	// Assigns all available techs of the current context player to an array.
	code("void assignTechs(int array = -1)");
	code("{");
		code("int civ = kbGetCiv();");

		// Armory techs.
		code("if(civ == cCivThor) {");
			code("arrayAppend(array, cTechBronzeWeaponsThor);");
			code("arrayAppend(array, cTechBronzeMailThor);");
			code("arrayAppend(array, cTechBronzeShieldsThor);");
			code("arrayAppend(array, cTechCopperWeaponsThor);");
			code("arrayAppend(array, cTechCopperMailThor);");
			code("arrayAppend(array, cTechCopperShieldsThor);");
			code("arrayAppend(array, cTechIronWeaponsThor);");
			code("arrayAppend(array, cTechIronMailThor);");
			code("arrayAppend(array, cTechIronShieldsThor);");
			code("arrayAppend(array, cTechBurningPitchThor);");
			code("arrayAppend(array, cTechHammerOfTheGods);");
			code("arrayAppend(array, cTechDragonscaleShields);");
			code("arrayAppend(array, cTechMeteoricIronMail);");
		code("} else {");
			code("arrayAppend(array, cTechBronzeWeapons);");
			code("arrayAppend(array, cTechBronzeMail);");
			code("arrayAppend(array, cTechBronzeShields);");
			code("arrayAppend(array, cTechCopperWeapons);");
			code("arrayAppend(array, cTechCopperMail);");
			code("arrayAppend(array, cTechCopperShields);");
			code("arrayAppend(array, cTechIronWeapons);");
			code("arrayAppend(array, cTechIronMail);");
			code("arrayAppend(array, cTechIronShields);");
			code("arrayAppend(array, cTechBurningPitch);");
		code("}");

		// Mythological techs and minor gods.
		code("if(civ == cCivZeus) {");
			code("addMinorGod(array, cMinorHermes);");
			code("addMinorGod(array, cMinorAthena);");
			code("addMinorGod(array, cMinorApollo);");
			code("addMinorGod(array, cMinorDionysos);");
			code("addMinorGod(array, cMinorHephaestus);");
			code("addMinorGod(array, cMinorHera);");
			code("arrayAppend(array, cTechOlympicParentage);");
			code("arrayAppend(array, cTechAge2Hermes);");
			code("arrayAppend(array, cTechAge2Athena);");
			code("arrayAppend(array, cTechAge3Apollo);");
			code("arrayAppend(array, cTechAge3Dionysos);");
			code("arrayAppend(array, cTechAge4Hephaestus);");
			code("arrayAppend(array, cTechAge4Hera);");
		code("}");
		code("else if(civ == cCivPoseidon) {");
			code("addMinorGod(array, cMinorHermes);");
			code("addMinorGod(array, cMinorAres);");
			code("addMinorGod(array, cMinorDionysos);");
			code("addMinorGod(array, cMinorAphrodite);");
			code("addMinorGod(array, cMinorHephaestus);");
			code("addMinorGod(array, cMinorArtemis);");
			code("arrayAppend(array, cTechLordOfHorses);");
			code("arrayAppend(array, cTechAge2Hermes);");
			code("arrayAppend(array, cTechAge2Ares);");
			code("arrayAppend(array, cTechAge3Dionysos);");
			code("arrayAppend(array, cTechAge3Aphrodite);");
			code("arrayAppend(array, cTechAge4Hephaestus);");
			code("arrayAppend(array, cTechAge4Artemis);");
		code("}");
		code("else if(civ == cCivHades) {");
			code("addMinorGod(array, cMinorAres);");
			code("addMinorGod(array, cMinorAthena);");
			code("addMinorGod(array, cMinorApollo);");
			code("addMinorGod(array, cMinorAphrodite);");
			code("addMinorGod(array, cMinorHephaestus);");
			code("addMinorGod(array, cMinorArtemis);");
			code("arrayAppend(array, cTechVaultsOfErebus);");
			code("arrayAppend(array, cTechAge2Ares);");
			code("arrayAppend(array, cTechAge2Athena);");
			code("arrayAppend(array, cTechAge3Apollo);");
			code("arrayAppend(array, cTechAge3Aphrodite);");
			code("arrayAppend(array, cTechAge4Hephaestus);");
			code("arrayAppend(array, cTechAge4Artemis);");
		code("}");
		code("else if(civ == cCivSet) {");
			code("addMinorGod(array, cMinorAnubis);");
			code("addMinorGod(array, cMinorPtah);");
			code("addMinorGod(array, cMinorSekhmet);");
			code("addMinorGod(array, cMinorNephthys);");
			code("addMinorGod(array, cMinorHorus);");
			code("addMinorGod(array, cMinorThoth);");
			code("arrayAppend(array, cTechFeral);");
			code("arrayAppend(array, cTechAge2Anubis);");
			code("arrayAppend(array, cTechAge2Ptah);");
			code("arrayAppend(array, cTechAge3Sekhmet);");
			code("arrayAppend(array, cTechAge3Nephthys);");
			code("arrayAppend(array, cTechAge4Horus);");
			code("arrayAppend(array, cTechAge4Thoth);");
		code("}");
		code("else if(civ == cCivIsis) {");
			code("addMinorGod(array, cMinorAnubis);");
			code("addMinorGod(array, cMinorBast);");
			code("addMinorGod(array, cMinorHathor);");
			code("addMinorGod(array, cMinorNephthys);");
			code("addMinorGod(array, cMinorThoth);");
			code("addMinorGod(array, cMinorOsiris);");
			code("arrayAppend(array, cTechFloodOfTheNile);");
			code("arrayAppend(array, cTechAge2Anubis);");
			code("arrayAppend(array, cTechAge2Bast);");
			code("arrayAppend(array, cTechAge3Hathor);");
			code("arrayAppend(array, cTechAge3Nephthys);");
			code("arrayAppend(array, cTechAge4Thoth);");
			code("arrayAppend(array, cTechAge4Osiris);");
		code("}");
		code("else if(civ == cCivRa) {");
			code("addMinorGod(array, cMinorBast);");
			code("addMinorGod(array, cMinorPtah);");
			code("addMinorGod(array, cMinorSekhmet);");
			code("addMinorGod(array, cMinorHathor);");
			code("addMinorGod(array, cMinorOsiris);");
			code("addMinorGod(array, cMinorHorus);");
			code("arrayAppend(array, cTechSkinOfTheRhino);");
			code("arrayAppend(array, cTechAge2Bast);");
			code("arrayAppend(array, cTechAge2Ptah);");
			code("arrayAppend(array, cTechAge3Sekhmet);");
			code("arrayAppend(array, cTechAge3Hathor);");
			code("arrayAppend(array, cTechAge4Osiris);");
			code("arrayAppend(array, cTechAge4Horus);");
		code("}");
		code("else if(civ == cCivThor) {");
			code("addMinorGod(array, cMinorFreyja);");
			code("addMinorGod(array, cMinorForseti);");
			code("addMinorGod(array, cMinorBragi);");
			code("addMinorGod(array, cMinorSkadi);");
			code("addMinorGod(array, cMinorBaldr);");
			code("addMinorGod(array, cMinorTyr);");
			code("arrayAppend(array, cTechPigSticker);");
			code("arrayAppend(array, cTechAge2Freyja);");
			code("arrayAppend(array, cTechAge2Forseti);");
			code("arrayAppend(array, cTechAge3Bragi);");
			code("arrayAppend(array, cTechAge3Skadi);");
			code("arrayAppend(array, cTechAge4Baldr);");
			code("arrayAppend(array, cTechAge4Tyr);");
		code("}");
		code("else if(civ == cCivLoki) {");
			code("addMinorGod(array, cMinorHeimdall);");
			code("addMinorGod(array, cMinorForseti);");
			code("addMinorGod(array, cMinorBragi);");
			code("addMinorGod(array, cMinorNjord);");
			code("addMinorGod(array, cMinorTyr);");
			code("addMinorGod(array, cMinorHel);");
			code("arrayAppend(array, cTechEyesInTheForest);");
			code("arrayAppend(array, cTechAge2Heimdall);");
			code("arrayAppend(array, cTechAge2Forseti);");
			code("arrayAppend(array, cTechAge3Bragi);");
			code("arrayAppend(array, cTechAge3Njord);");
			code("arrayAppend(array, cTechAge4Tyr);");
			code("arrayAppend(array, cTechAge4Hel);");
		code("}");
		code("else if(civ == cCivOdin) {");
			code("addMinorGod(array, cMinorHeimdall);");
			code("addMinorGod(array, cMinorFreyja);");
			code("addMinorGod(array, cMinorSkadi);");
			code("addMinorGod(array, cMinorNjord);");
			code("addMinorGod(array, cMinorTyr);");
			code("addMinorGod(array, cMinorBaldr);");
			code("arrayAppend(array, cTechLoneWanderer);");
			code("arrayAppend(array, cTechAge2Heimdall);");
			code("arrayAppend(array, cTechAge2Freyja);");
			code("arrayAppend(array, cTechAge3Skadi);");
			code("arrayAppend(array, cTechAge3Njord);");
			code("arrayAppend(array, cTechAge4Tyr);");
			code("arrayAppend(array, cTechAge4Baldr);");
		code("}");
		code("else if(civ == cCivOuranos) {");
			code("addMinorGod(array, cMinorPrometheus);");
			code("addMinorGod(array, cMinorOceanus);");
			code("addMinorGod(array, cMinorTheia);");
			code("addMinorGod(array, cMinorHyperion);");
			code("addMinorGod(array, cMinorHelios);");
			code("addMinorGod(array, cMinorHekate);");
			code("arrayAppend(array, cTechSafePassage);");
			code("arrayAppend(array, cTechAge2Prometheus);");
			code("arrayAppend(array, cTechAge2Oceanus);");
			code("arrayAppend(array, cTechAge3Theia);");
			code("arrayAppend(array, cTechAge3Hyperion);");
			code("arrayAppend(array, cTechAge4Helios);");
			code("arrayAppend(array, cTechAge4Hekate);");
		code("}");
		code("else if(civ == cCivKronos) {");
			code("addMinorGod(array, cMinorPrometheus);");
			code("addMinorGod(array, cMinorLeto);");
			code("addMinorGod(array, cMinorRheia);");
			code("addMinorGod(array, cMinorHyperion);");
			code("addMinorGod(array, cMinorHelios);");
			code("addMinorGod(array, cMinorAtlas);");
			code("arrayAppend(array, cTechFocus);");
			code("arrayAppend(array, cTechAge2Prometheus);");
			code("arrayAppend(array, cTechAge2Leto);");
			code("arrayAppend(array, cTechAge3Rheia);");
			code("arrayAppend(array, cTechAge3Hyperion);");
			code("arrayAppend(array, cTechAge4Helios);");
			code("arrayAppend(array, cTechAge4Atlas);");
		code("}");
		code("else if(civ == cCivGaia) {");
			code("addMinorGod(array, cMinorLeto);");
			code("addMinorGod(array, cMinorOceanus);");
			code("addMinorGod(array, cMinorTheia);");
			code("addMinorGod(array, cMinorRheia);");
			code("addMinorGod(array, cMinorHekate);");
			code("addMinorGod(array, cMinorAtlas);");
			code("arrayAppend(array, cTechChannels);");
			code("arrayAppend(array, cTechAge2Leto);");
			code("arrayAppend(array, cTechAge2Oceanus);");
			code("arrayAppend(array, cTechAge3Theia);");
			code("arrayAppend(array, cTechAge3Rheia);");
			code("arrayAppend(array, cTechAge4Hekate);");
			code("arrayAppend(array, cTechAge4Atlas);");
		code("}");

		// Eco techs.
		code("if(civ == cCivGaia && " + boolToString(cVBPEnabled) + " == true) {");
			// Gaia.
			code("arrayAppend(array, cTechGaiaHandAxe);");
			code("arrayAppend(array, cTechGaiaPickaxe);");
			code("arrayAppend(array, cTechGaiaHusbandry);");
			code("arrayAppend(array, cTechGaiaHuntingDogs);");
			code("arrayAppend(array, cTechGaiaPlow);");
			code("arrayAppend(array, cTechGaiaBowSaw);");
			code("arrayAppend(array, cTechGaiaShaftMine);");
			code("arrayAppend(array, cTechGaiaCarpenters);");
			code("arrayAppend(array, cTechGaiaQuarry);");
			code("arrayAppend(array, cTechGaiaIrrigation);");
			code("arrayAppend(array, cTechGaiaFloodControl);");
			code("arrayAppend(array, cTechGaiaPurseSeine);");
			code("arrayAppend(array, cTechGaiaSaltAmphora);");
		code("} else {");
			// Everyone else.
			code("arrayAppend(array, cTechHandAxe);");
			code("arrayAppend(array, cTechPickaxe);");
			code("arrayAppend(array, cTechHusbandry);");
			code("arrayAppend(array, cTechHuntingDogs);");
			code("arrayAppend(array, cTechPlow);");
			code("arrayAppend(array, cTechBowSaw);");
			code("arrayAppend(array, cTechShaftMine);");
			code("arrayAppend(array, cTechCarpenters);");
			code("arrayAppend(array, cTechQuarry);");
			code("arrayAppend(array, cTechIrrigation);");
			code("arrayAppend(array, cTechFloodControl);");
			code("arrayAppend(array, cTechPurseSeine);");
			code("arrayAppend(array, cTechSaltAmphora);");
		code("}");

		// Common techs.
		code("arrayAppend(array, cTechSecretsOfTheTitans);");
		code("arrayAppend(array, cTechMasons);");
		code("arrayAppend(array, cTechArchitects);");
		code("arrayAppend(array, cTechStoneWall);");
		code("arrayAppend(array, cTechSignalFires);");
		code("arrayAppend(array, cTechCarrierPigeons);");
		code("arrayAppend(array, cTechCrenellations);");
		code("arrayAppend(array, cTechAmbassadors);");
		code("arrayAppend(array, cTechTaxCollectors);");
		code("arrayAppend(array, cTechCoinage);");
		code("arrayAppend(array, cTechBoilingOil);");
		code("arrayAppend(array, cTechDraftHorses);");
		code("arrayAppend(array, cTechEngineers);");
		code("arrayAppend(array, cTechEnclosedDeck);");
		code("arrayAppend(array, cTechHeroicFleet);");
		code("arrayAppend(array, cTechArrowShipCladding);");
		code("arrayAppend(array, cTechReinforcedRam);");
		code("arrayAppend(array, cTechNavalOxybeles);");
		code("arrayAppend(array, cTechConscriptSailors);");
		code("arrayAppend(array, cTechFortifyTownCenter);");

		// Culture-related techs.
		code("if(civ == cCivZeus || civ == cCivPoseidon || civ == cCivHades) {");
			code("arrayAppend(array, cTechLevyInfantry);");
			code("arrayAppend(array, cTechLevyArchers);");
			code("arrayAppend(array, cTechLevyCavalry);");
			code("arrayAppend(array, cTechConscriptInfantry);");
			code("arrayAppend(array, cTechConscriptArchers);");
			code("arrayAppend(array, cTechConscriptCavalry);");
			code("arrayAppend(array, cTechMediumInfantry);");
			code("arrayAppend(array, cTechMediumArchers);");
			code("arrayAppend(array, cTechMediumCavalry);");
			code("arrayAppend(array, cTechHeavyInfantry);");
			code("arrayAppend(array, cTechHeavyArchers);");
			code("arrayAppend(array, cTechHeavyCavalry);");
			code("arrayAppend(array, cTechChampionInfantry);");
			code("arrayAppend(array, cTechChampionArchers);");
			code("arrayAppend(array, cTechChampionCavalry);");
			code("arrayAppend(array, cTechBeastSlayer);");
			code("arrayAppend(array, cTechGuardTower);");
			code("arrayAppend(array, cTechFortifiedWall);");
			code("arrayAppend(array, cTechWatchTower);");
		code("}");
		code("else if(civ == cCivOdin || civ == cCivThor || civ == cCivLoki) {");
			code("arrayAppend(array, cTechLevyLonghouseSoldiers);");
			code("arrayAppend(array, cTechLevyHillFortSoldiers);");
			code("arrayAppend(array, cTechConscriptLonghouseSoldiers);");
			code("arrayAppend(array, cTechConscriptHillFortSoldiers);");
			code("arrayAppend(array, cTechMediumInfantry);");
			code("arrayAppend(array, cTechMediumCavalry);");
			code("arrayAppend(array, cTechHeavyInfantry);");
			code("arrayAppend(array, cTechHeavyCavalry);");
			code("arrayAppend(array, cTechChampionInfantry);");
			code("arrayAppend(array, cTechChampionCavalry);");
			code("arrayAppend(array, cTechAxeOfMuspell);");
			code("arrayAppend(array, cTechWatchTower);");
		code("}");
		code("else if(civ == cCivOuranos || civ == cCivKronos || civ == cCivGaia) {");
			code("arrayAppend(array, cTechMediumInfantry);");
			code("arrayAppend(array, cTechMediumArchers);");
			code("arrayAppend(array, cTechMediumCavalry);");
			code("arrayAppend(array, cTechHeavyInfantry);");
			code("arrayAppend(array, cTechHeavyArchers);");
			code("arrayAppend(array, cTechHeavyCavalry);");
			code("arrayAppend(array, cTechChampionInfantry);");
			code("arrayAppend(array, cTechChampionArchers);");
			code("arrayAppend(array, cTechChampionCavalry);");
			code("arrayAppend(array, cTechLevyMainlineUnits);");
			code("arrayAppend(array, cTechLevySpecialtyUnits);");
			code("arrayAppend(array, cTechLevyPalaceUnits);");
			code("arrayAppend(array, cTechConscriptMainlineUnits);");
			code("arrayAppend(array, cTechConscriptSpecialtyUnits);");
			code("arrayAppend(array, cTechConscriptPalaceUnits);");
			code("arrayAppend(array, cTechWatchTower);");
			code("arrayAppend(array, cTechHeavyChieroballista);");
			code("arrayAppend(array, cTechChampionChieroballista);");
			code("arrayAppend(array, cTechIronWall);");
			code("arrayAppend(array, cTechBronzeWall);");
			code("arrayAppend(array, cTechOrichalkosWall);");
			code("arrayAppend(array, cTechGuardTower);");
		code("}");
		code("else if(civ == cCivRa || civ == cCivSet || civ == cCivIsis) {");
			code("arrayAppend(array, cTechMediumSpearmen);");
			code("arrayAppend(array, cTechMediumAxemen);");
			code("arrayAppend(array, cTechMediumSlingers);");
			code("arrayAppend(array, cTechHeavySpearmen);");
			code("arrayAppend(array, cTechHeavyAxemen);");
			code("arrayAppend(array, cTechHeavySlingers);");
			code("arrayAppend(array, cTechChampionSpearmen);");
			code("arrayAppend(array, cTechChampionAxemen);");
			code("arrayAppend(array, cTechChampionSlingers);");
			code("arrayAppend(array, cTechHeavyChariots);");
			code("arrayAppend(array, cTechHeavyCamelry);");
			code("arrayAppend(array, cTechHeavyElephants);");
			code("arrayAppend(array, cTechChampionChariots);");
			code("arrayAppend(array, cTechChampionCamelry);");
			code("arrayAppend(array, cTechChampionElephants);");
			code("arrayAppend(array, cTechLevyBarracksSoldiers);");
			code("arrayAppend(array, cTechLevyMigdolSoldiers);");
			code("arrayAppend(array, cTechConscriptBarracksSoldiers);");
			code("arrayAppend(array, cTechConscriptMigdolSoldiers);");
			code("arrayAppend(array, cTechHandsOfThePharaoh);");
			code("arrayAppend(array, cTechBallistaTower);");
			code("arrayAppend(array, cTechCitadelWall);");
			code("arrayAppend(array, cTechFortifiedWall);");
			code("arrayAppend(array, cTechGuardTower);");
		code("}");
	code("}");
}

/*
** Injects utility functions for techs to get tech icons and to check if a tech is an age-up tech.
*/
void injectTechUtil() {
	// Function for tech icons.
	code("string getTechIcon(int techID = -1)");
	code("{");
		// Convert patched Gaia techs right away.
		code("if(techID == cTechGaiaHandAxe) techID = cTechHandAxe;");
		code("else if(techID == cTechGaiaPickaxe) techID = cTechPickaxe;");
		code("else if(techID == cTechGaiaHuntingDogs) techID = cTechHuntingDogs;");
		code("else if(techID == cTechGaiaHusbandry) techID = cTechHusbandry;");
		code("else if(techID == cTechGaiaPlow) techID = cTechPlow;");
		code("else if(techID == cTechGaiaBowSaw) techID = cTechBowSaw;");
		code("else if(techID == cTechGaiaShaftMine) techID = cTechShaftMine;");
		code("else if(techID == cTechGaiaCarpenters) techID = cTechCarpenters;");
		code("else if(techID == cTechGaiaQuarry) techID = cTechQuarry;");
		code("else if(techID == cTechGaiaIrrigation) techID = cTechIrrigation;");
		code("else if(techID == cTechGaiaFloodControl) techID = cTechFloodControl;");
		code("else if(techID == cTechGaiaPurseSeine) techID = cTechPurseSeine;");
		code("else if(techID == cTechGaiaSaltAmphora) techID = cTechSaltAmphora;");

		// Variables.
		code("bool hasExpSuffix = false;");
		code("string techName = kbGetTechName(techID);");
		code("string prefix = \"<icon=(20)(icons/improvement \";");
		code("string suffix = \" icon)>\";");
		code("string expSuffix = \" icons 64)>\";");

		// Greek.
		// Minor gods.
		code("if(techID == cTechAge2Athena) techName = \"athena\";");
		code("else if(techID == cTechAge2Hermes) techName = \"hermes\";");
		code("else if(techID == cTechAge2Ares) techName = \"ares\";");
		code("else if(techID == cTechAge3Apollo) techName = \"apollo\";");
		code("else if(techID == cTechAge3Dionysos) techName = \"dionysos\";");
		code("else if(techID == cTechAge3Aphrodite) techName = \"aphrodite\";");
		code("else if(techID == cTechAge4Hephaestus) techName = \"hephaestus\";");
		code("else if(techID == cTechAge4Hera) techName = \"hera\";");
		code("else if(techID == cTechAge4Artemis) techName = \"artemis\";");

		// Mythology.
		code("else if(techID == cTechBeastSlayer) hasExpSuffix = true;");
		code("else if(techID == cTechOlympicParentage) techName = \"olympic patronage\";");
		code("else if(techID == cTechLordOfHorses) techName = \"lord of the horses\";");
		code("else if(techID == cTechVaultsOfErebus) techName = \"wealth of erebus\";");
		code("else if(techID == cTechMonstrousRage) techName = \"monsterous rage\";");
		code("else if(techID == cTechHandOfTalos) techName = \"iron colossus\";");
		code("else if(techID == cTechShoulderOfTalos) techName = \"bronze colossus\";");
		code("else if(techID == cTechFlamesOfTyphon)");
		code("{");
			code("return(\"<icon=(20)(icons/god power inferno icon)>\");"); // Directly return this as it's completely different.
		code("}");

		// Military.
		code("else if(techID == cTechMediumArchers) techName = \"medium archer\";");
		code("else if(techID == cTechHeavyArchers) techName = \"heavy archer\";");
		code("else if(techID == cTechChampionArchers) techName = \"champion archer\";");

		// Egyptian.
		// Minor gods.
		code("else if(techID == cTechAge2Anubis) techName = \"anubis\";");
		code("else if(techID == cTechAge2Bast) techName = \"bast\";");
		code("else if(techID == cTechAge2Ptah) techName = \"ptah\";");
		code("else if(techID == cTechAge3Hathor) techName = \"hathor\";");
		code("else if(techID == cTechAge3Nephthys) techName = \"nephthys\";");
		code("else if(techID == cTechAge3Sekhmet) techName = \"sekhmet\";");
		code("else if(techID == cTechAge4Osiris) techName = \"osiris\";");
		code("else if(techID == cTechAge4Thoth) techName = \"thoth\";");
		code("else if(techID == cTechAge4Horus) techName = \"horus\";");

		// Mythology.
		code("else if(techID == cTechHandsOfThePharaoh) hasExpSuffix = true;");
		code("else if(techID == cTechHieracosphinx) techName = \"hieraco sphinx\";");
		code("else if(techID == cTechCriosphinx) techName = \"crio sphinx\";");
		code("else if(techID == cTechSunDriedMudBrick) techName = \"sun dried brick\";");
		code("else if(techID == cTechAxeOfVengeance) techName = \"vengeance\";");
		code("else if(techID == cTechRamOfTheWestWind) techName = \"ram of the wind\";");

		// Military.
		code("else if(techID == cTechLevyBarracksSoldiers) techName = \"levy barracks\";");
		code("else if(techID == cTechLevyMigdolSoldiers) techName = \"levy migdol\";");
		code("else if(techID == cTechMediumSlingers) techName = \"medium slinger\";");
		code("else if(techID == cTechHeavySlingers) techName = \"heavy slinger\";");
		code("else if(techID == cTechChampionSlingers) techName = \"champion slinger\";");
		code("else if(techID == cTechHeavyElephants) techName = \"heavy elephant\";");
		code("else if(techID == cTechChampionElephants) techName = \"champion elephant\";");
		code("else if(techID == cTechChampionChariots) techName = \"champion archer\";");

		// Norse.
		// Minor gods.
		code("else if(techID == cTechAge2Freyja) techName = \"freyja\";");
		code("else if(techID == cTechAge2Heimdall) techName = \"heimdall\";");
		code("else if(techID == cTechAge2Forseti) techName = \"forseti\";");
		code("else if(techID == cTechAge3Njord) techName = \"njord\";");
		code("else if(techID == cTechAge3Skadi) techName = \"frigg\";");
		code("else if(techID == cTechAge3Bragi) techName = \"bragi\";");
		code("else if(techID == cTechAge4Baldr) techName = \"baldr\";");
		code("else if(techID == cTechAge4Tyr) techName = \"tyr\";");
		code("else if(techID == cTechAge4Hel) techName = \"hel\";");

		// Thor upgrades.
		code("else if(techID == cTechBronzeWeaponsThor) techName = \"bronze weapons\";");
		code("else if(techID == cTechBronzeMailThor) techName = \"bronze mail\";");
		code("else if(techID == cTechBronzeShieldsThor) techName = \"bronze shields\";");
		code("else if(techID == cTechCopperWeaponsThor) techName = \"copper weapons\";");
		code("else if(techID == cTechCopperMailThor) techName = \"copper mail\";");
		code("else if(techID == cTechCopperShieldsThor) techName = \"copper shields\";");
		code("else if(techID == cTechIronWeaponsThor) techName = \"iron weapons\";");
		code("else if(techID == cTechIronMailThor) techName = \"iron mail\";");
		code("else if(techID == cTechIronShieldsThor) techName = \"iron shields\";");
		code("else if(techID == cTechBurningPitchThor) techName = \"burning pitch\";");
		code("else if(techID == cTechHammerOfTheGods) techName = \"dwarven weapons\";");
		code("else if(techID == cTechDragonscaleShields) techName = \"dwarven shields\";");
		code("else if(techID == cTechMeteoricIronMail) techName = \"dwarven mail\";");

		// Mythology.
		code("else if(techID == cTechHamarrtroll) techName = \"hamar troll\";");
		code("else if(techID == cTechWinterHarvest) techName = \"bountiful harvest\";");
		code("else if(techID == cTechElhrimnirKettle) techName = \"elminer kettle\";");
		code("else if(techID == cTechArcticWinds) techName = \"arctic wind\";");

		// Military.
		code("else if(techID == cTechAxeOfMuspell) hasExpSuffix = true;");
		code("else if(techID == cTechLevyLonghouseSoldiers) techName = \"levy longhouse\";");
		code("else if(techID == cTechConscriptLonghouseSoldiers) techName = \"conscript longhouse\";");
		code("else if(techID == cTechLevyHillFortSoldiers) techName = \"levy hillfort\";");
		code("else if(techID == cTechConscriptHillFortSoldiers) techName = \"conscript hillfort\";");

		// Atlanteans.
		// Minor gods. Directly return these as they are completely different.
		code("else if(techID == cTechAge2Prometheus) return(\"<icon=(20)(icons/god major prometheus icons 64)>\");");
		code("else if(techID == cTechAge2Leto) return(\"<icon=(20)(icons/god major leto icons 64)>\");");
		code("else if(techID == cTechAge2Oceanus) return(\"<icon=(20)(icons/god major okeanus icons 64)>\");");
		code("else if(techID == cTechAge3Hyperion) return(\"<icon=(20)(icons/god major hyperion icons 64)>\");");
		code("else if(techID == cTechAge3Rheia) return(\"<icon=(20)(icons/god major rheia icons 64)>\");");
		code("else if(techID == cTechAge3Theia) return(\"<icon=(20)(icons/god major theia icons 64)>\");");
		code("else if(techID == cTechAge4Helios) return(\"<icon=(20)(icons/god major helios icons 64)>\");");
		code("else if(techID == cTechAge4Atlas) return(\"<icon=(20)(icons/god major atlas icons 64)>\");");
		code("else if(techID == cTechAge4Hekate) return(\"<icon=(20)(icons/god major hekate icons 64)>\");");

		// Mytholoy.
		code("else if(techID == cTechFocus) hasExpSuffix = true;");
		code("else if(techID == cTechChannels) hasExpSuffix = true;");
		code("else if(techID == cTechSafePassage) hasExpSuffix = true;");
		code("else if(techID == cTechAxeOfMuspell) hasExpSuffix = true;");
		code("else if(techID == cTechHeartOfTheTitans) hasExpSuffix = true;");
		code("else if(techID == cTechAlluvialClay) hasExpSuffix = true;");
		code("else if(techID == cTechHephaestusRevenge) hasExpSuffix = true;");
		code("else if(techID == cTechVolcanicForge) hasExpSuffix = true;");
		code("else if(techID == cTechBiteOfTheShark) hasExpSuffix = true;");
		code("else if(techID == cTechWeightlessMace) hasExpSuffix = true;");
		code("else if(techID == cTechGemino) hasExpSuffix = true;");
		code("else if(techID == cTechHeroicRenewal) hasExpSuffix = true;");
		code("else if(techID == cTechHornsOfConsecration) hasExpSuffix = true;");
		code("else if(techID == cTechMailOfOrichalkos) hasExpSuffix = true;");
		code("else if(techID == cTechRheiasGift) hasExpSuffix = true;");
		code("else if(techID == cTechLanceOfStone) hasExpSuffix = true;");
		code("else if(techID == cTechPoseidonsSecret) hasExpSuffix = true;");
		code("else if(techID == cTechLemurianDescendants) { hasExpSuffix = true; techName = \"lemurian descendant\"; }");
		code("else if(techID == cTechPetrified) hasExpSuffix = true;");
		code("else if(techID == cTechHaloOfTheSun) hasExpSuffix = true;");
		code("else if(techID == cTechTitanShield) hasExpSuffix = true;");
		code("else if(techID == cTechEyesOfAtlas) hasExpSuffix = true;");
		code("else if(techID == cTechIoGuardian) { hasExpSuffix = true; techName = \"guardian\"; }");
		code("else if(techID == cTechMythicRejuvenation) hasExpSuffix = true;");
		code("else if(techID == cTechCelerity) hasExpSuffix = true;");
		code("else if(techID == cTechAsperBlood) hasExpSuffix = true;");

		// Military.
		code("else if(techID == cTechLevyMainlineUnits) { hasExpSuffix = true; techName = \"levy mainline\"; }");
		code("else if(techID == cTechLevySpecialtyUnits){ hasExpSuffix = true; techName = \"levy specialty\"; }");
		code("else if(techID == cTechLevyPalaceUnits) { hasExpSuffix = true; techName = \"levy palace\"; }");
		code("else if(techID == cTechConscriptMainlineUnits) { hasExpSuffix = true; techName = \"conscript mainline\"; }");
		code("else if(techID == cTechConscriptSpecialtyUnits) { hasExpSuffix = true; techName = \"conscript specialty\"; }");
		code("else if(techID == cTechConscriptPalaceUnits) { hasExpSuffix = true; techName = \"conscript palace\"; }");
		code("else if(techID == cTechHeavyChieroballista) hasExpSuffix = true;");
		code("else if(techID == cTechChampionChieroballista) hasExpSuffix = true;");
		code("else if(techID == cTechIronWall) hasExpSuffix = true;");
		code("else if(techID == cTechBronzeWall) hasExpSuffix = true;");
		code("else if(techID == cTechOrichalkosWall) { hasExpSuffix = true; techName = \"orichalkos wall\"; }");

		// Common.
		// Sectrets of the Titans.
		code("else if(techID == cTechSecretsOfTheTitans) hasExpSuffix = true;");

		// Buildings.
		code("else if(techID == cTechFortifyTownCenter) techName = \"fortified town center\";");
		code("else if(techID == cTechCrenellations) techName = \"crenelations\";");
		code("else if(techID == cTechBoilingOil) techName = \"murder holes\";");

		// Dock.
		code("else if(techID == cTechConscriptSailors) techName = \"conscript naval\";");
		code("else if(techID == cTechEnclosedDeck) techName = \"enclosed decks\";");
		code("else if(techID == cTechHeroicFleet) hasExpSuffix = true;");

		// Apply suffix and return.
		code("if(hasExpSuffix)");
		code("{");
			code("suffix = expSuffix;");
		code("}");

		code("return(prefix + techName + suffix);");
	code("}");

	// Checks if a tech is an age-up tech.
	code("bool isTechAgeUp(int tech = -1)");
	code("{");
		code("if(tech == cTechAge2Anubis) return(true);");
		code("else if(tech == cTechAge2Ares) return(true);");
		code("else if(tech == cTechAge2Athena) return(true);");
		code("else if(tech == cTechAge2Bast) return(true);");
		code("else if(tech == cTechAge2Forseti) return(true);");
		code("else if(tech == cTechAge2Freyja) return(true);");
		code("else if(tech == cTechAge2Heimdall) return(true);");
		code("else if(tech == cTechAge2Hermes) return(true);");
		code("else if(tech == cTechAge2Leto) return(true);");
		code("else if(tech == cTechAge2Oceanus) return(true);");
		code("else if(tech == cTechAge2Prometheus) return(true);");
		code("else if(tech == cTechAge2Ptah) return(true);");
		code("else if(tech == cTechAge3Aphrodite) return(true);");
		code("else if(tech == cTechAge3Apollo) return(true);");
		code("else if(tech == cTechAge3Bragi) return(true);");
		code("else if(tech == cTechAge3Dionysos) return(true);");
		code("else if(tech == cTechAge3Hathor) return(true);");
		code("else if(tech == cTechAge3Hyperion) return(true);");
		code("else if(tech == cTechAge3Nephthys) return(true);");
		code("else if(tech == cTechAge3Njord) return(true);");
		code("else if(tech == cTechAge3Rheia) return(true);");
		code("else if(tech == cTechAge3Sekhmet) return(true);");
		code("else if(tech == cTechAge3Skadi) return(true);");
		code("else if(tech == cTechAge3Theia) return(true);");
		code("else if(tech == cTechAge4Artemis) return(true);");
		code("else if(tech == cTechAge4Atlas) return(true);");
		code("else if(tech == cTechAge4Baldr) return(true);");
		code("else if(tech == cTechAge4Hekate) return(true);");
		code("else if(tech == cTechAge4Hel) return(true);");
		code("else if(tech == cTechAge4Helios) return(true);");
		code("else if(tech == cTechAge4Hephaestus) return(true);");
		code("else if(tech == cTechAge4Hera) return(true);");
		code("else if(tech == cTechAge4Horus) return(true);");
		code("else if(tech == cTechAge4Osiris) return(true);");
		code("else if(tech == cTechAge4Thoth) return(true);");
		code("else if(tech == cTechAge4Tyr) return(true);");

		code("return(false);");
	code("}");

	code("const int cTechUpdateStart = 0;");
	code("const int cTechUpdateComplete = 1;");
	code("const int cTechUpdateAbort = 2;");

	// Global tech updates to observers. Currently only active for age-ups.
	code("void techUpdateToObs(int type = -1, int p = -1, int tech = -1)");
	code("{");
		code("if(isTechAgeUp(tech) && type != cTechUpdateComplete)"); // Only send if age-up tech and either started or aborted.
		code("{");
			code("string m = \"\";");

			code("if(type == cTechUpdateStart)");
			code("{");
				code("m = \"Started: \" + getTechIcon(tech) + \" \" + kbGetTechName(tech) + \" (\" + timeStamp(trTime()) + \")\";");
			code("} else {");
				code("m = \"Aborted: \" + getTechIcon(tech) + \" \" + kbGetTechName(tech) + \" (\" + timeStamp(trTime()) + \")\";");
			code("}");

			for(i = cPlayersMerged; < cPlayersObs) {
				code("trChatSendSpoofedToPlayer(p, " + getPlayer(i) + ", m);");
			}
		code("}");
	code("}");
}

/*****************
* OBSERVER RULES *
*****************/

/*
 * This section is extremely messy.
 * Like above, functions are not independent from each other and have to be called
 * in the order they are listed here to work properly.
*/

/*
** Injects the constants and variables needed for the update toggles.
*/
void injectToggleVars() {
	// Techs request toggle states.
	code("const int cToggleOff = 0;");
	code("const int cToggleRunOnce = 1;"); // !r and !t respectively.
	code("const int cToggleOn = 2;");

	// States for live resources and techs.
	for(i = cPlayersMerged; < cPlayersObs) {
		code("int resState" + getPlayer(i) + " = cToggleOff;");
		code("int techState" + getPlayer(i) + " = cToggleOff;");
		code("int detailPlayerState" + getPlayer(i) + " = cToggleOff;"); // Obtains details for the specified player if enabled.
		code("int detailPlayer" + getPlayer(i) + " = 0;");
	}

	for(i = cPlayersMerged; < cPlayersObs) {
		for(j = 1; < cPlayers) {
			code("int playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
			code("int playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
		}
	}
}

/*
** Tech update core.
** Creates arrays and stores the state of every update for every player, removing techs that are already reseached from the check.
** Has an upper limit per pass (cTechBatchSize) - 1 iteration will never check more than this value.
*/
void injectTechUpdateCore() {
	// Core for filling and updating the arrays holding the tech states. Credits to Loggy for the great concept.
	code("const int cTechArraySize = 120;"); // ~100 is the maximum number of techs for civs.
	code("const int cTechBatchSize = 50;"); // Try to update about half the (initial) techs of a player per round.

	// An array with an entry for every player, where each value is the index of another array that stores tech statuses.
	code("int dataArray = -1;");

	for(i = cPlayersMerged; < cPlayersObs) {
		code("rule _update_techs_" + getPlayer(i));
		code("active");
		code("highFrequency");
		code("{");
			injectRuleInterval(200);

			code("static int currentPlayer = 1;");
			code("static int currentTech = 0;"); // Not a tech, but rather the position in currentPlayer's array that we got to last time.
			code("static bool init = false;");

			// Only do for observers.
			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				code("if(init == false)");
				code("{");
					// Initialization.
					code("if(dataArray == -1)");
					code("{");
						code("dataArray = arrayCreate(cPlayers);");
					code("}");

					code("int arrData = arrayCreate(cTechArraySize);");
					code("arraySetInt(dataArray, currentPlayer, arrData);");

					// Use different updates to build all arrays.
					code("int oldContext = xsGetContextPlayer();");
					code("xsSetContextPlayer(getPlayer(currentPlayer));");

					code("assignTechs(arrData);");

					// Next player.
					code("currentPlayer++;");

					code("if(currentPlayer > cNonGaiaPlayers)");
					code("{");
						code("init = true;");
					code("}");

					code("xsSetContextPlayer(oldContext);");

					code("xsSetRuleMinIntervalSelf(0);");
				code("} else {");
					// Silently update the tech arrays every now and then.
					// Reset counter.
					code("if(currentPlayer > cNonGaiaPlayers)");
					code("{");
						code("currentPlayer = 1;");
					code("}");

					code("int p = getPlayer(currentPlayer);");

					code("oldContext = xsGetContextPlayer();");
					code("xsSetContextPlayer(p);");

					// Obtain player array; don't use offset of -1, [0] empty.
					code("int arrPlayerArray = arrayGetInt(dataArray, currentPlayer);");

					// Number of techs to check this iteration.
					code("int count = min(cTechBatchSize, arrayGetSize(arrPlayerArray) - currentTech);");
					// code("trChatSend(0, \"\" + p + \" \" + arrayGetSize(arrPlayerArray));");
					code("int thisCount = count;");

					code("while(count > 0)");
					code("{");
						code("int tech = arrayGetInt(arrPlayerArray, currentTech);");
						code("int savedStatus = arrayGetInt(arrPlayerArray, currentTech, true);");
						code("int status = kbGetTechStatus(tech);");

						code("if(status != savedStatus)");
						code("{");
							code("if(savedStatus != cTechStatusResearching && status == cTechStatusResearching)"); // If we don't check for != cTechStatusResearching we may miss some.
							code("{");
								// Case 1: Started researching tech since last update.
								code("techUpdateToObs(cTechUpdateStart, p, tech);");

								code("arraySetInt(arrPlayerArray, currentTech, cTechStatusResearching, true);");
							code("} else if(status == cTechStatusActive) {");
								// Case 2: Tech has been successfully researched.
								// code("techUpdateToObs(cTechUpdateComplete, p, tech);");

								// Remove researched tech from array.
								code("arrayRemoveInt(arrPlayerArray, currentTech);");

								// Decrement currentTech as we also reduce array size.
								code("currentTech--;");
							code("} else if(status == cTechStatusAvailable && savedStatus == cTechStatusResearching) {");
								// This may miss cancellations if the tech was unavailable and then got available, researching and cancelled before the next update.

								// Case 3: Researchment was cancelled.
								// code("techUpdateToObs(cTechUpdateAbort, p, tech);");

								code("arraySetInt(arrPlayerArray, currentTech, cTechStatusAvailable, true);");
							code("} else {");
								// Case 4: Update in any other case.
								code("arraySetInt(arrPlayerArray, currentTech, status, true);");
							code("}");
						code("}");

						code("currentTech++;");
						code("count--;");
					code("}");

					// See if we need to move onto the next player.
					code("if(currentTech >= arrayGetSize(arrPlayerArray))");
					code("{");
						code("currentPlayer++;");
						code("currentTech = 0;");

						// Avoid having a minInterval of 0 permenantly if the array is small.
						code("if(arrayGetSize(arrPlayerArray) > thisCount)");
						code("{");
							code("xsSetRuleMinIntervalSelf(0);");
						code("}");
					code("}");

					code("xsSetContextPlayer(oldContext);");
				code("}");
			code("}");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_update_techs_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** !x command to clear all active toggles and the chat.
*/
void injectCmdToggleClear() {
	for(i = cPlayersMerged; < cPlayersObs) {
		code("rule _clear_toggles_" + getPlayer(i));
		code("active");
		code("{");
			injectRuleInterval();

			// Only do for observers.
			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				// Don't merge ifs because XS evaluates both conditions in an && even if the first one is false.
				code("if(trChatHistoryContains(\"!x\", " + getPlayer(i) + "))");
				code("{");
					// Kill active !lr and !lt.
					code("techState" + getPlayer(i) + " = false;");
					code("resState" + getPlayer(i) + " = false;");
					code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayer" + getPlayer(i) + " = 0;");

					for(j = 1; < cPlayers) {
						code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
						code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
					}

					code("trChatHistoryClear();");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", \"Chat cleared.\");");
				code("}");
			code("}");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_clear_toggles_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** !h command to display all available commands (clears active toggles).
*/
void injectCmdHelp() {
	// List of commands. This has be generated before !lr and !lt to properly shut them down if active.
	for(i = cPlayersMerged; < cPlayersObs) {
		code("rule _get_commands_" + getPlayer(i));
		code("active");
		code("{");
			injectRuleInterval();

			// Only do for observers.
			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				// Don't merge ifs because XS evaluates both conditions in an && even if the first one is false.
				code("if(trChatHistoryContains(\"!h\", " + getPlayer(i) + "))");
				code("{");
					// Kill active !lr and !lt.
					code("techState" + getPlayer(i) + " = cToggleOff;");
					code("resState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayer" + getPlayer(i) + " = 0;");

					code("trChatHistoryClear();");

					code("string cp = \"" + cColorChat + "\";");
					code("string cs = \"" + cColorOff + "\";");

					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!m\" + cs + \" toggles map reveal\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!i\" + cs + \" shows the current resources and techs of player i (example: !2)\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!r\" + cs + \" shows the current resources of all players\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!t\" + cs + \" shows all techs currently being researched\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!li\" + cs + \" toggles live resources and techs for player i (example: !l2)\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!lra\" + cs + \" toggles live resources for all players\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!lri\" + cs + \" toggles live resources for player i (example: !lr2)\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!lta\" + cs + \" toggles live techs for all players\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!lti\" + cs + \" toggles live techs for player i (example: !lt2)\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!la\" + cs + \" toggles live resources and techs for all players (1v1 only)\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", cp + \"!x\" + cs + \" clears the chat (and all active toggles)\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", \"You will be unable to see player chat while any live (!l*) command is enabled.\");");
					code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", \"Chat is always cleared when a command is issued.\");");
				code("}");
			code("}");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_get_commands_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** !m command to reveal the map.
** Has to be injected before the toggles to be usable while toggles are active.
** The command in the chat will get cleared by active toggles otherwise, as rules are iterated over sequentially in each pass.
*/
void injectCmdMapReveal() {
	for(i = cPlayers; < cPlayersObs) {
		code("rule _toggle_map_reveal_" + getPlayer(i));
		code("active");
		code("{");
			injectRuleInterval();

			// Only do for observers.
			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				// Static variable rm holds state over calls of this rule.
				code("static bool mapRevealed" + getPlayer(i) + " = true;");

				code("if(trChatHistoryContains(\"!m\", " + getPlayer(i) + "))");
				code("{");
					code("trChatHistoryClear();");

					// Change state of variable.
					code("if(mapRevealed" + getPlayer(i) + ")");
					code("{");
						code("mapRevealed" + getPlayer(i) + " = false;");
					code("} else {");
						code("mapRevealed" + getPlayer(i) + " = true;");
					code("}");

					// Toggle black map/fog.
					code("trSetFogAndBlackmap(mapRevealed" + getPlayer(i) + ", mapRevealed" + getPlayer(i) + ");");

				code("}");
			code("}");

			code("xsDisableRule(\"_toggle_map_reveal_" + getPlayer(i) + "\");");
			code("trDelayedRuleActivation(\"_toggle_map_reveal_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** Listener for all stats/tech commands.
*/
void injectCmdListener() {
	// This is admittedly super messy but I don't think it's more useful to have all listeners in separate rules or functions.
	for(i = cPlayersMerged; < cPlayersObs) {
		code("rule _toggle_live_stats_" + getPlayer(i));
		code("active");
		code("{");
			injectRuleInterval();

			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				code("bool switchOff = false;");

			// One indentation level less so the injected code aligns.
			if(cNonGaiaPlayers <= 3) {
				// Live toggle all (!la), only for 1v1.
				code("if(trChatHistoryContains(\"!la\", " + getPlayer(i) + "))");
				code("{");
					code("trChatHistoryClear();");

					code("if(");
				for(k = 1; < cPlayers-1) {
					code("playerResState" + getPlayer(k) + "X" + getPlayer(i) + " == cToggleOn &&");
					code("playerTechState" + getPlayer(k) + "X" + getPlayer(i) + " == cToggleOn &&");
				}
					code("true)");
					code("{");
						// Both turned on, disable.
						code("resState" + getPlayer(i) + " = cToggleOff;");
						code("techState" + getPlayer(i) + " = cToggleOff;");

						for(j = 1; < cPlayers-1) {
							code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
							code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
						}
					code("} else {");
						// At least one not turned on, enable everything.
						code("resState" + getPlayer(i) + " = cToggleOn;");
						code("techState" + getPlayer(i) + " = cToggleOn;");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
						code("detailPlayer" + getPlayer(i) + " = 0;");

						for(j = 1; < cPlayers-1) {
							code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOn;");
							code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOn;");
						}
					code("}");
			} else {
				code("if(false)"); // Ridiculous but we can nicely inject else ifs after this.
				code("{");
			}

				// Live resource toggle (!lr).
				code("} else if(trChatHistoryContains(\"!lra\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					code("if(resState" + getPlayer(i) + " == cToggleOn)");
					code("{");
						code("resState" + getPlayer(i) + " = cToggleOff;");

						for(j = 1; < cPlayers) {
							code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
						}
					code("} else {");
						code("resState" + getPlayer(i) + " = cToggleOn;");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
						code("detailPlayer" + getPlayer(i) + " = 0;");

						for(j = 1; < cPlayers) {
							code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOn;");
						}
					code("}");

			// One indentation level less because we're injecting else ifs.
			for(j = 1; < cPlayers) {
				code("} else if(trChatHistoryContains(\"!lr" + getPlayer(j) + "\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					code("if(playerResState" + getPlayer(j) + "X" + getPlayer(i) + " == cToggleOn)");
					code("{");
						code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");

						// Check if we have to disable.
						code("switchOff = true;");

						code("if(false)"); // Ridiculous but we can nicely inject else ifs after this.
						code("{");
					for(k = 1; < cPlayers) {
						code("} else if (playerResState" + getPlayer(k) + "X" + getPlayer(i) + " == cToggleOn) {");
						code("switchOff = false;");
					}
						code("}");

						code("if(switchOff)");
						code("{");
							code("resState" + getPlayer(i) + " = cToggleOff;");
						code("}");
					code("} else {");
						code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOn;");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
						code("detailPlayer" + getPlayer(i) + " = 0;");

						// At least 1 is running, turn on.
						code("resState" + getPlayer(i) + " = cToggleOn;");
					code("}");
			}

				// Live tech toggle (!lt).
				code("} else if(trChatHistoryContains(\"!lta\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					code("if(techState" + getPlayer(i) + " == cToggleOn)");
					code("{");
						code("techState" + getPlayer(i) + " = cToggleOff;");

						for(j = 1; < cPlayers) {
							code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
						}
					code("} else {");
						code("techState" + getPlayer(i) + " = cToggleOn;");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
						code("detailPlayer" + getPlayer(i) + " = 0;");

						for(j = 1; < cPlayers) {
							code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOn;");
						}
					code("}");

			// One indentation level less because we're injecting else ifs.
			for(j = 1; < cPlayers) {
				code("} else if(trChatHistoryContains(\"!lt" + getPlayer(j) + "\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					code("if(playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " == cToggleOn)");
					code("{");
						code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");

						// Check if we have to disable.
						code("switchOff = true;");

						code("if(false)"); // Ridiculous but we can nicely inject else ifs after this.
						code("{");
					for(k = 1; < cPlayers) {
						code("} else if (playerTechState" + getPlayer(k) + "X" + getPlayer(i) + " == cToggleOn) {");
							code("switchOff = false;");
					}
						code("}");

						code("if(switchOff)");
						code("{");
							code("techState" + getPlayer(i) + " = cToggleOff;");
						code("}");
					code("} else {");
						code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOn;");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
						code("detailPlayer" + getPlayer(i) + " = 0;");

						// At least 1 is running, turn on.
						code("techState" + getPlayer(i) + " = cToggleOn;");
					code("}");
			}

			// Player stat toggle (!li).
			// One indentation level less because we're injecting else ifs.
			for(j = 1; < cPlayers) {
				code("} else if(trChatHistoryContains(\"!l" + getPlayer(j) + "\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					code("if(detailPlayerState" + getPlayer(i) + " == cToggleOn && detailPlayer" + getPlayer(i) + " == " + getPlayer(j) + ")");
					code("{");
						// Same player, turn off.
						code("detailPlayer" + getPlayer(i) + " = 0;");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("} else {");
						// Different player, turn on.
						code("detailPlayer" + getPlayer(i) + " = " + getPlayer(j) + ";");
						code("detailPlayerState" + getPlayer(i) + " = cToggleOn;");

						// Disable everything else.
						for(k = 1; < cPlayers) {
							code("playerResState" + getPlayer(k) + "X" + getPlayer(i) + " = cToggleOff;");
							code("playerTechState" + getPlayer(k) + "X" + getPlayer(i) + " = cToggleOff;");
						}

						code("resState" + getPlayer(i) + " = cToggleOff;");
						code("techState" + getPlayer(i) + " = cToggleOff;");
					code("}");
			}
				// Resource once (!r).
				code("} else if(trChatHistoryContains(\"!r\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					// Set to run once.
					code("resState" + getPlayer(i) + " = cToggleRunOnce;");

					// Disable every toggle.
					for(j = 1; < cPlayers) {
						code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
						code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
					}

					code("techState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayer" + getPlayer(i) + " = 0;");
				// Techs once (!t).
				code("} else if(trChatHistoryContains(\"!t\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					// Set to run once.
					code("techState" + getPlayer(i) + " = cToggleRunOnce;");

						// Disable every toggle.
					for(j = 1; < cPlayers) {
						code("playerResState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
						code("playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " = cToggleOff;");
					}

					code("resState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("detailPlayer" + getPlayer(i) + " = 0;");

			// Player stats once.
			// One indentation level less because we're injecting else ifs.
			for(j = 1; < cPlayers) {
				code("} else if(trChatHistoryContains(\"!" + getPlayer(j) + "\", " + getPlayer(i) + ")) {");
					code("trChatHistoryClear();");

					code("if(detailPlayerState" + getPlayer(i) + " == cToggleOn && detailPlayer" + getPlayer(i) + " == " + getPlayer(j) + ")");
					code("{");
						// Same player, turn off.
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("} else {");
						// Different player, turn on.
						code("detailPlayer" + getPlayer(i) + " = " + getPlayer(j) + ";");
						code("detailPlayerState" + getPlayer(i) + " = cToggleRunOnce;");

						// Disable everything else.
						for(k = 1; < cPlayers) {
							code("playerResState" + getPlayer(k) + "X" + getPlayer(i) + " = cToggleOff;");
							code("playerTechState" + getPlayer(k) + "X" + getPlayer(i) + " = cToggleOff;");
						}

						code("resState" + getPlayer(i) + " = cToggleOff;");
						code("techState" + getPlayer(i) + " = cToggleOff;");
					code("}");
			}

				code("}");
			code("}");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_toggle_live_stats_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** Stats for !lra, !lta, !r, and !t.
*/
void injectCmdUpdateGlobal() {
	// Live updates.
	code("string attyIconFish = \"<icon=(20)(icons/boat x fishing ship atlantean icons 32)>\";");

	// Global update. Used by !lra, !lta, !r and !t.
	for(i = cPlayersMerged; < cPlayersObs) {
		code("rule _update_live_stats_" + getPlayer(i));
		code("active");
		code("{");
			code("static int techCount" + getPlayer(i) + " = 0;");

			injectRuleInterval();

			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				code("if(resState" + getPlayer(i) + " + techState" + getPlayer(i) + " != 0)");
				code("{");
					code("int oldContext = xsGetContextPlayer();");

					// Clean chat for next messages.
					code("xsSetContextPlayer(" + getPlayer(i) + ");");
					code("trChatHistoryClear();");

					// Define variables here because scoping doesn't exist.
					// Global.
					code("int currTechCount = 0;");

					// Local (overwritten for every player upon iterations).
					code("string f = \"\";");
					code("string w = \"\";");
					code("string g = \"\";");
					code("string favor = \"\";");
					code("string pop = \"\";");

					code("int tradeCount = 0;");
					code("int fishCount = 0;");
					code("int villSum = 0;");

					code("string vills = \"\";");
					code("string trade = \"\";");
					code("string fishing = \"\";");

					code("int playerArray = 0;");
					code("int p = 0;");
					code("int pt = 0;");
					code("string s = \"\";");
					code("int arrSize = 0;");
					code("int tech = 0;");
					code("int status = 0;");
					code("bool runOnce = true;");

					for(j = 1; < cPlayers) {
						code("if(playerResState" + getPlayer(j) + "X" + getPlayer(i) + " != 0 || resState" + getPlayer(i) + " == cToggleRunOnce)");
						code("{");
							code("xsSetContextPlayer(" + getPlayer(j) + ");");

							code("favor = \"<icon=(20)(icons/icon resource favor)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"favor\");");
							code("pop = \"<icon=(20)(icons/icon resource population)>\" + kbGetPop() + \"/\" + kbGetPopCap();");
							code("f = \"<icon=(20)(icons/icon resource food)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"food\");");
							code("w = \"<icon=(20)(icons/icon resource wood)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"wood\");");
							code("g = \"<icon=(20)(icons/icon resource gold)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"gold\");");

							code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", \"" + rmGetPlayerName(getPlayer(j)) + " (" + getGodName(j) + "): \" + pop + \" \" + favor);");
							code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", f + \"\" + w + \"\" + g);");

							if(cNonGaiaPlayers == 2) {
								// Depending on culture, obtain villager/fishing/caravan stats.
								int cultureCompact = rmGetPlayerCulture(getPlayer(j));

								if(cultureCompact == cCultureGreek) {
									code("vills = \"<icon=(20)(icons/villager g male icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Greek\");");

									code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Greek\");");
									code("fishing = \"<icon=(20)(icons/boat g fishing boat icon)>\" + fishCount;");

									code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Greek\");");
									code("trade = \"<icon=(20)(icons/trade g caravan icon)>\" + tradeCount;");
								} else if(cultureCompact == cCultureEgyptian) {
									code("vills = \"<icon=(20)(icons/villager e male icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Egyptian\");");

									code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Egyptian\");");
									code("fishing = \"<icon=(20)(icons/boat e fishing boat icon)>\" + fishCount;");

									code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Egyptian\");");
									code("trade = \"<icon=(20)(icons/trade e caravan icon)>\" + tradeCount;");
								} else if(cultureCompact == cCultureNorse) {
									code("villSum = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Norse\") + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Dwarf\");");
									code("vills = \"<icon=(20)(icons/villager n male icon)>\" + villSum;");

									code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Norse\");");
									code("fishing = \"<icon=(20)(icons/boat n fishing boat icon)>\" + fishCount;");

									code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Norse\");");
									code("trade = \"<icon=(20)(icons/trade n caravan icon)>\" + tradeCount;");
								} else if(cultureCompact == cCultureAtlanteanID) {
									code("villSum = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Atlantean\") + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Atlantean Hero\");");
									code("vills = \"<icon=(20)(icons/villager x male icons 32)>\" + villSum;");

									code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Atlantean\");");
									code("fishing = attyIconFish + fishCount;");

									code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Atlantean\");");
									code("trade = \"<icon=(20)(icons/trade x caravan icons 32)>\" + tradeCount;");
								}

								// Villagers, trade and fish. These don't fit onto a single line.
								code("if(tradeCount > 0 && fishCount > 0 && techCount" + getPlayer(i) + " < 6)");
								code("{");
									// Only show everything if 5 or less techs are being researched so we don't exceed the max chat lines (2 * 4 + 5 = 13).
									code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", vills + trade);");
									code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", fishing);");
								code("} else if(techCount" + getPlayer(i) + " < 8) {");
									// Otherwise we can show one line of vill/trade/fish stats if 7 or less techs are being researched (2 * 3 + 7 = 13).
									code("if(tradeCount > 0) {");
										code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", vills + trade);");
									code("} else if(fishCount > 0) {");
										code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", vills + fishing);");
									code("} else {");
										code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", vills);");
									code("}");
								code("}");
							}
						code("}");

						code("if(playerTechState" + getPlayer(j) + "X" + getPlayer(i) + " != cToggleOff || techState" + getPlayer(i) + " == cToggleRunOnce)");
						code("{");
							// Print info message once.
							code("if(runOnce && techState" + getPlayer(i) + " == cToggleRunOnce)");
							code("{");
								code("trChatSendSpoofedToPlayer(" + getPlayer(i) + ", " + getPlayer(i) + ", \"Techs currently being researched:\");");
								code("runOnce = false;");
							code("}");

							// Obtain techs.
							code("p = " + getPlayer(j) + ";");

							code("xsSetContextPlayer(p);");
							code("playerArray = arrayGetInt(dataArray, " + j + ");");
							code("arrSize = arrayGetSize(playerArray);");

							code("for(techIter = 0; < arrSize)");
							code("{");
								// Get tech and current status.
								code("tech = arrayGetInt(playerArray, techIter);");
								code("status = arrayGetInt(playerArray, techIter, true);");

								code("if(status == cTechStatusResearching)");
								code("{");
									// Calculate percentage.
									code("pt = 100 * kbGetTechPercentComplete(tech);");
									code("s = getTechIcon(tech) + \" \" + kbGetTechName(tech) + \" (\" + pt + \" pct)\";");
									code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", s);");
									code("currTechCount++;");
								code("}");
							code("}");
						code("}");
					}

					code("if(resState" + getPlayer(i) + " == cToggleRunOnce)");
					code("{");
						// Decrement if called only once.
						code("resState" + getPlayer(i) + " = cToggleOff;");
					code("}");

					code("if(techState" + getPlayer(i) + " == cToggleRunOnce)");
					code("{");
						// Decrement if called only once.
						code("techState" + getPlayer(i) + " = cToggleOff;");
					code("}");

					// Update tech count.
					code("techCount" + getPlayer(i) + " = currTechCount;");

					code("xsSetContextPlayer(oldContext);");
				code("}");
			code("}");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_update_live_stats_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** Stats for !i and !li.
*/
void injectCmdUpdateSingle() {
	// Player update. Used for !i and !li.
	for(i = cPlayersMerged; < cPlayersObs) {
		code("rule _get_player_info_" + getPlayer(i));
		code("active");
		code("{");
			injectRuleInterval();

			code("if(trCurrentPlayer() == " + getPlayer(i) + ")");
			code("{");
				code("if(detailPlayerState" + getPlayer(i) + " != cToggleOff)");
				code("{");
					code("int oldContext = xsGetContextPlayer();");

					// Clean chat for next messages.
					code("xsSetContextPlayer(" + getPlayer(i) + ");");
					code("trChatHistoryClear();");

					// Variables to store values in.
					code("string vills = \"\";");
					code("string dwarfs = \"\";"); // Remains empty for Greek/Egyptian, used by Atlantean hero citizens.
					code("string oxcart = \"\";"); // Only used by Norse.
					code("string trade = \"\";");
					code("string fishing = \"\";");

					code("int tradeCount = 0;");
					code("int fishCount = 0;");

					code("string f = \"\";");
					code("string w = \"\";");
					code("string g = \"\";");
					code("string favor = \"\";");
					code("string pop = \"\";");

					code("string time = \"\";");

					code("int playerArray = 0;");
					code("int pt = 0;");
					code("int arrSize = 0;");
					code("int tech = 0;");
					code("int status = 0;");
					code("string s = \"\";");

					for(j = 1; < cPlayers) {
						code("if(detailPlayer" + getPlayer(i) + " == " + getPlayer(j) + ")");
						code("{");
							code("xsSetContextPlayer(" + getPlayer(j) + ");");

							code("favor = \"<icon=(20)(icons/icon resource favor)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"favor\");");
							code("pop = \"<icon=(20)(icons/icon resource population)>\" + kbGetPop() + \"/\" + kbGetPopCap();");
							code("f = \"<icon=(20)(icons/icon resource food)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"food\");");
							code("w = \"<icon=(20)(icons/icon resource wood)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"wood\");");
							code("g = \"<icon=(20)(icons/icon resource gold)>\" + trPlayerResourceCount(" + getPlayer(j) + ", \"gold\");");

							// Different order etc. compared to !r.
							code("time = timeStamp(trTime());");
							code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", \"" + rmGetPlayerName(getPlayer(j)) + " (" + getGodName(j) + ") (\" + time + \"): \");");
							code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", f + \"\" + w + \"\" + g);");
							code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", pop + \" \" + favor);");

							// Depending on culture, obtain villager/fishing/caravan stats.
							int cultureDetailed = rmGetPlayerCulture(getPlayer(j));

							if(cultureDetailed == cCultureGreek) {
								code("vills = \"<icon=(20)(icons/villager g male icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Greek\");");

								code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Greek\");");
								code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Greek\");");

								code("trade = \"<icon=(20)(icons/trade g caravan icon)>\" + tradeCount;");
								code("fishing = \"<icon=(20)(icons/boat g fishing boat icon)>\" + fishCount;");
							} else if(cultureDetailed == cCultureEgyptian) {
								code("vills = \"<icon=(20)(icons/villager e male icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Egyptian\");");

								code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Egyptian\");");
								code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Egyptian\");");

								code("trade = \"<icon=(20)(icons/trade e caravan icon)>\" + tradeCount;");
								code("fishing = \"<icon=(20)(icons/boat e fishing boat icon)>\" + fishCount;");
							} else if(cultureDetailed == cCultureNorse) {
								code("vills = \"<icon=(20)(icons/villager n male icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Norse\");");
								code("dwarfs = \"<icon=(20)(icons/villager n dwarf icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Dwarf\");");
								code("oxcart = \"<icon=(20)(icons/villager n oxcart icon)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Ox Cart\");");

								code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Norse\");");
								code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Norse\");");

								code("trade = \"<icon=(20)(icons/trade n caravan icon)>\"  + tradeCount;");
								code("fishing = \"<icon=(20)(icons/boat n fishing boat icon)>\" + fishCount;");
							} else if(cultureDetailed == cCultureAtlanteanID) {
								code("vills = \"<icon=(20)(icons/villager x male icons 32)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Atlantean\");");
								code("dwarfs = \"<icon=(20)(icons/villager x male hero icons 32)>\" + trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Villager Atlantean Hero\");");

								code("tradeCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Caravan Atlantean\");");
								code("fishCount = trPlayerUnitCountSpecific(" + getPlayer(j) + ", \"Fishing Ship Atlantean\");");

								code("trade = \"<icon=(20)(icons/trade x caravan icons 32)>\" + tradeCount;");
								code("fishing = attyIconFish + fishCount;");
							}

							// Villagers and dwarfs, always show.
							code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", vills + dwarfs);");

							// Ox carts for norse, always show.
							if(cultureDetailed == cCultureNorse) {
								code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", oxcart);");
							}

							// Trade and fishing - only show if > 0 exist.
							code("if(tradeCount > 0 && fishCount > 0)");
							code("{");
								code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", trade + fishing);");
							code("} else if (tradeCount > 0) {");
								code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", trade);");
							code("} else if(fishCount > 0) {");
								code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", fishing);");
							code("}");

							// Techs.
							code("playerArray = arrayGetInt(dataArray, " + j + ");");
							code("arrSize = arrayGetSize(playerArray);");

							code("for(techIter = 0; < arrSize)");
							code("{");
								// Get tech and current status.
								code("tech = arrayGetInt(playerArray, techIter);");
								code("status = arrayGetInt(playerArray, techIter, true);");

								code("if(status == cTechStatusResearching)");
								code("{");
									code("pt = 100 * kbGetTechPercentComplete(tech);");
									code("s = getTechIcon(tech) + \" \" + kbGetTechName(tech) + \" (\" + pt + \" pct)\";");
									code("trChatSendSpoofedToPlayer(" + getPlayer(j) + ", " + getPlayer(i) + ", s);");
								code("}");
							code("}");
						code("}");
					}

					code("xsSetContextPlayer(oldContext);");

					code("if(detailPlayerState" + getPlayer(i) + " == cToggleRunOnce)");
					code("{");
						// Decrement if called only once.
						code("detailPlayerState" + getPlayer(i) + " = cToggleOff;");
					code("}");
				code("}");
			code("}");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_get_player_info_" + getPlayer(i) + "\");");
		code("}");
	}
}

/*
** Injects all the previously defined observer commands.
** Requires player constants and game constants to be injected as well.
**
** Do NOT change the order unless you know what you're doing.
**
** @param injectConstants: whether to also inject player and game constants (defaults to false)
*/
void injectObsRules(bool injectConstants = false) {
	// Inject constants if necessary.
	if(injectConstants) {
		injectPlayerConstants();
		injectGameConstants();
	}

	// Util.
	injectMiscUtil();
	injectArrayUtil();
	injectTechUtil();
	injectTechArrayUtil();

	// Commands.
	injectToggleVars();
	injectTechUpdateCore();
	injectCmdToggleClear();
	injectCmdHelp();
	injectCmdMapReveal();
	injectCmdListener();
	injectCmdUpdateGlobal();
	injectCmdUpdateSingle();
}

/****************
* VICTORY RULES *
****************/

/*
** Injects rules to handle VC with additional observers.
*/
void injectVC() {
	// Disables the basic victory condition rule.
	code("rule _disable_basic_vc");
	code("active");
	code("{");
		code("xsDisableRule(\"BasicVC1\");");
		code("xsDisableSelf();");
	code("}");

	// Called to defeat players associated with another player when merged.
	code("void defeatMergedPlayers(int playerID = -1)");
	code("{");
		// Inject defeat triggers for all necessary merges.
		for(i = 1; <= cPlayersMerged) {
			if(isMergedPlayer(i) == false) {
				code("if(playerID == " + i + ")");
				code("{");
				for(j = i + 1; <= cPlayersMerged) {
					if(rmGetPlayerName(j) == rmGetPlayerName(i) && rmGetPlayerTeam(j) == rmGetPlayerTeam(i)) {
						code("trSetPlayerDefeated(" + j + ");");
					}
				}
				code("}");
			}
		}
	code("}");

	// Called when a player resigned or got defeated, defeats observers if the game is over.
	code("void runGameOverCheck()");
	code("{");
		code("int numTeamsAlive = cTeams;");
		code("bool teamAlive = false;");

		// Check if at least one player of a team is alive, otherwise decrement.
		int playerCount = 1;

		for(i = 0; < cTeams) {
			int teamPlayers = playerCount + getNumberPlayersOnTeam(i);

			code("for(j = " + playerCount + "; < " + teamPlayers + ")");
			code("{");
				code("if(kbHasPlayerLost(getPlayer(j)) == false && kbIsPlayerResigned(getPlayer(j)) == false)");
				code("{");
					code("teamAlive = true;");
					code("break;");
				code("}");
			code("}");

			code("if(teamAlive == false)");
			code("{");
				code("numTeamsAlive--;");
			code("} else {");
				// Team was alive, set to false for next iteration.
				code("teamAlive = false;");
			code("}");

			playerCount = teamPlayers;
		}

		// If only 1 team remains, defeat obs.
		code("if(numTeamsAlive <= 1)");
		code("{");
			code("for(j = cPlayersMerged; < cNumberPlayers)");
			code("{");
				code("trSetPlayerDefeated(getPlayer(j));");
			code("}");
		code("}");
	code("}");

	// Rule for handling defeat.
	code("rule _check_defeat_vc");
	code("active");
	code("{");
		// Check once every 3 seconds.
		injectRuleInterval(3000);

		code("int oldContext = xsGetContextPlayer();");
		code("int count = 0;");

		// Consider only the players that were actually placed on the map.
		for(i = 1; < cPlayers) {
			code("xsSetContextPlayer(" + getPlayer(i) + ");");

			// Player hasn't lost yet; count all units that prevent from being defeated.
			code("if(kbHasPlayerLost(" + getPlayer(i) + ") == false)");
			code("{");
				code("count = kbUnitCount(" + getPlayer(i) + ", cUnitTypeLogicalTypeNeededForVictory, cUnitStateAlive);");

				// If the count is <= 0, the player has lost; defeat them and all players that are in the same team.
				code("if(count <= 0)");
				code("{");
					// Defeat player.
					code("trSetPlayerDefeated(" + getPlayer(i) + ");");
					code("defeatMergedPlayers(" + getPlayer(i) + ");");

					// Update vc for obs.
					code("runGameOverCheck();");
				code("}");
			code("}");
		}

		code("xsSetContextPlayer(oldContext);");

		code("xsDisableSelf();");
		code("trDelayedRuleActivation(\"_check_defeat_vc\");");
	code("}");

	// Rule for handling resign, 1 per player that is turned off after running once.
	for(i = 1; < cPlayers) {
		code("rule _check_resign_vc_" + getPlayer(i));
		code("active");
		code("{");
			// Check once per second.
			injectRuleInterval(1000);

			code("int oldContext = xsGetContextPlayer();");
			code("xsSetContextPlayer(" + getPlayer(i) + ");");

			// Player hasn't lost yet; count all units that prevent from being defeated.
			code("if(kbIsPlayerResigned(" + getPlayer(i) + "))");
			code("{");
				code("defeatMergedPlayers(" + getPlayer(i) + ");");

				// Update vc for obs.
				code("runGameOverCheck();");
				code("xsSetContextPlayer(oldContext);");

				code("xsDisableSelf();");

				// Don't reactivate after running once.
				code("return;");
			code("}");

			code("xsSetContextPlayer(oldContext);");

			code("xsDisableSelf();");
			code("trDelayedRuleActivation(\"_check_resign_vc_" + getPlayer(i) + "\");");
		code("}");
	}
}

/**************
* MERGE RULES *
**************/

/*
** Injects a rule to pause the game immediately after launch.
*/
void injectMergePause() {
	code("rule _merge_pause");
	code("highFrequency");
	code("active");
	// code("runImmediately"); // Don't run immediately to give time for other triggers to fire before (e.g. checks).
	code("{");
		injectRuleInterval(0, 500); // Run after 0.5 seconds to give time for other initialization.

		if(cVersion != cVersionVanilla) {
			code("trChatHistoryClear();");
		}

		sendChatWhite("");
		sendChatWhite("");
		sendChatWhite(cInfoLine);
		sendChatWhite("");
		sendChatWhite("Merge detected.");
		sendChatWhite("");
		sendChatWhite("Save and restore the game to enable merge mode.");
		sendChatWhite("");
		sendChatWhite("The game has been paused for saving.");
		sendChatWhite("");
		sendChatWhite(cInfoLine);
		sendChatWhite("");
		sendChatWhite("");

		pauseGame();

		code("xsDisableSelf();");
	code("}");
}

/*
** Injects a rule to start recording the game for merge mode.
** For some reason trGamePause() from injectMergePause() takes too much time to activate so we can't invoke this from injectMergePause() in a clean way.
*/
void injectMergeRecGame() {
	code("rule _merge_rec_game");
	code("highFrequency");
	code("active");
	code("{");
		// 1.0 sec delay before initializing recorded game (may have to change this depending on rec desync results).
		injectRuleInterval(0, 1000);

		if(cVersion != cVersionVanilla) {
			code("trChatHistoryClear();");
		}

		sendChatWhite("");
		sendChatWhite("");
		sendChatWhite(cInfoLine);
		sendChatWhite("");
		sendChatWhite("Merge mode enabled.");

		if(cVersion != cVersionEE) {
			sendChatWhite("");
			sendChatWhite("Initializing recorded game.");
			sendChatWhite("");
			sendChatRed("The game will freeze for some seconds.");
		}

		sendChatWhite("");
		sendChatWhite(cInfoLine);
		sendChatWhite("");
		sendChatWhite("");

		if(cVersion != cVersionEE) {
			code("trStartGameRecord();");
		}

		code("xsDisableSelf();");
	code("}");
}

/****************
* BALANCE RULES *
****************/

/*
** Injects the rain fix that addresses the 50% enhanced wood gather rate for the caster (hardcoded).
** Requires game constants to be injected (techs/tech status).
*/
void injectRainFix() {
	// Inject as much as possible here to gain maximum performance.
	for(i = 1; < cPlayers) {
		int p = getPlayer(i);

        if(rmGetPlayerCiv(p) == cCivRa) {
			// Global tech status variables.
			code("int handAxeStatus" + p + " = cTechStatusUnobtainable;");
			code("int bowSawStatus" + p + " = cTechStatusUnobtainable;");
			code("int carpentersStatus" + p + " = cTechStatusUnobtainable;");
			code("int adzeStatus" + p + " = cTechStatusUnobtainable;");

			code("rule _rain_update_check_" + p);
			code("inactive");
			code("highFrequency");
			code("{");
	            // injectRuleInterval(); // No interval, check as often as possible.

				code("if(trCheckGPActive(\"Rain\", " + p + ") == false)");
				code("{");
					// Rain ended.
					// code("trChatSend(" + p + ", \"rain ended\");");

					// Remove penalty tech.
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusUnobtainable);");

					// Done.
					code("xsDisableSelf();");
					code("return;");
				code("}");

				code("int oldContext = xsGetContextPlayer();");
				code("xsSetContextPlayer(" + p + ");");

				code("int tempHandAxeStatus = kbGetTechStatus(cTechHandAxe);");
				code("int tempBowSawStatus = kbGetTechStatus(cTechBowSaw);");
				code("int tempCarpentersStatus = kbGetTechStatus(cTechCarpenters);");
				code("int tempAdzeStatus = kbGetTechStatus(cTechAdzeOfWepwawet);");

				// This is extremely ugly due to the possibility of completing research of Adze at the same time as one of the 3 other upgrades.
				code("bool adzeNew = adzeStatus" + p + " != tempAdzeStatus && tempAdzeStatus == cTechStatusActive;");

				code("if(adzeNew)");
				code("{");
					code("trTechSetStatus(" + p + ", cTechAdzeOfWepwawet, cTechStatusUnobtainable);");
				code("}");

				code("if(handAxeStatus" + p + " != tempHandAxeStatus && tempHandAxeStatus == cTechStatusActive)");
				code("{");
					code("trTechSetStatus(" + p + ", cTechHandAxe, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechHandAxe, cTechStatusActive);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusActive);");
				code("}");
				code("if(bowSawStatus" + p + " != tempBowSawStatus && tempBowSawStatus == cTechStatusActive)");
				code("{");
					code("trTechSetStatus(" + p + ", cTechBowSaw, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechBowSaw, cTechStatusActive);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusActive);");
				code("}");
				code("if(carpentersStatus" + p + " != tempCarpentersStatus && tempCarpentersStatus == cTechStatusActive)");
				code("{");
					code("trTechSetStatus(" + p + ", cTechCarpenters, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechCarpenters, cTechStatusActive);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusActive);");
				code("}");
				code("if(adzeNew)");
				code("{");
					// code("trTechSetStatus(" + p + ", cTechAdzeOfWepwawet, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusUnobtainable);");
					code("trTechSetStatus(" + p + ", cTechAdzeOfWepwawet, cTechStatusActive);");
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusActive);");
				code("}");

				code("handAxeStatus" + p + " = kbGetTechStatus(cTechHandAxe);");
				code("bowSawStatus" + p + " = kbGetTechStatus(cTechBowSaw);");
				code("carpentersStatus" + p + " = kbGetTechStatus(cTechCarpenters);");
				code("adzeStatus" + p + " = kbGetTechStatus(cTechAdzeOfWepwawet);");

				code("xsSetContextPlayer(oldContext);");
	        code("}");

            code("rule _rain_enable_check_" + p);
	        code("active");
			code("highFrequency");
	        code("{");
	            // injectRuleInterval(); // No interval, check as often as possible.

				code("if(trCheckGPActive(\"Rain\", " + p + "))");
				code("{");
					// Rain active.
					// code("trChatSend(" + p + ", \"rain active\");");

					// Set context.
					code("int oldContext = xsGetContextPlayer();");
					code("xsSetContextPlayer(" + p + ");");

					// Store current tech status.
					code("handAxeStatus" + p + " = kbGetTechStatus(cTechHandAxe);");
					code("bowSawStatus" + p + " = kbGetTechStatus(cTechBowSaw);");
					code("carpentersStatus" + p + " = kbGetTechStatus(cTechCarpenters);");
					code("adzeStatus" + p + " = kbGetTechStatus(cTechAdzeOfWepwawet);");

					code("xsSetContextPlayer(oldContext);");

					// Grant penalty tech.
					code("trTechSetStatus(" + p + ", cTechRainFix, cTechStatusActive);");

					// Toggle update to compensate for new wood upgrades researched during rain.
					code("trDelayedRuleActivation(\"_rain_update_check_" + p + "\");");

					code("xsDisableSelf();");
				code("}");

	        code("}");
        }
    }
}

/*
** RM X Framework.
** RebelsRising
** Last edit: 14/04/2021
**
** Lowest library file in the hierarchy - include this in your random map script.
** Check core.xs for more details about the RM X framework.
**
** Use rmxInit() before using any of the functionality of the framework.
** Use rmxFinalize() to inject the triggers and placement checks at the end of your script.
*/

// include "rmx_triggers.xs"; // Contains all the other files in the hierarchy so we only have to include this one.

/*
** Initializes core RM X functionality. Should be called at the beginning of your random map script.
**
** @param mapName: sets the name of the map for trigger-related calls
** @param shuffle: whether to shuffle players within teams or not
** @param toggleMerge: whether to allow merge mode or not (set to false for original ES maps that do not use RM X placement functions), disable for ES maps
** @param toggleObs: whether to make the last team observing for > 2 teams present, disable for ES maps
** @param initNote: whether to print the initial message
*/
void rmxInit(string mapName = "", bool shuffle = true, bool toggleMerge = true, bool toggleObs = true, bool initNote = true) {
	// Set map name.
	setMap(mapName);

	// Enabling merge mode has to occur before players are initialized.
	if(toggleMerge) {
		enableMergeMode();
	}

	// Enabling additional obs has to occur before players are initialized.
	if(toggleObs && cVersion != cVersionEE) {
		enableAddObs();
	}

	// Initialize players.
	initPlayers(shuffle);

	// Inject the initial note if set to true.
	if(initNote) {
		injectInitNote(toggleObs, toggleMerge);
	}

	// Always inject constants, must happen after initPlayers().
	injectPlayerConstants();
	injectGameConstants();

	// If we're debugging, do stuff here.
	if(cDebugMode == cDebugFull) {
		injectTestMode();
		injectFlareOnCompile();
	}
}

/*
** Executes things that have to be done at the end of a random map script. Should be called last.
*/
void rmxFinalize() {
	// Inject observer code and rain fix.
	if(cVersion == cVersionAoT) {
		if(hasAnyObs()) {
			injectObsRules();
		}

		// Inject Rain fix for AoT.
		if(cVBPEnabled) {
			injectRainFix();
		}
	}

	// Adjust observers and run custom victory conditions.
	if(isMergeModeOn() || hasAddObs()) {
		injectNonPlayerSetup();
		injectVC();
	}

	// Pause the game immediately and start recording after some time.
	if(isMergeModeOn()) {
		injectMergePause();
		injectMergeRecGame();
	}

	// Execute object check.
	if(cDebugMode >= cDebugTest) {
		injectObjectCheck(false, 12); // Check for every possible configuration if we're debugging.
	} else if(cDebugMode >= cDebugCompetitive) {
		injectObjectCheck(true, 12); // Only check for two teams of equal players.
	}
}

//=================================================================================================================================
// extendedmechanics.xs
// Creator: WarriorMario
//
// Some extended functionality for certain units. Is not dependend on the victory conditions and can be run without in for example
// scenarios.
// Created with ADE v0.09
//=================================================================================================================================

// Globals for tuning
float healSpeed  = -50;
float healRange  = 10;

// Global variables
int qilinDeathQuery = -1;
int qilinID   = -1;

rule initExtendedMechanics
active
runImmediately
minInterval 0
maxInterval 0
priority 100
{
	xsEnableRule("QilinDeathHack");
	qilinID   = kbGetProtoUnitID("Qilin Heal");
	xsDisableSelf();
}

//=================================================================================================================================
// QilinDeathHack
// This rule adds the heal on death functionality for the Qilin
// It's just an instant heal so we do not need to care how often we run as long as we run it once
//=================================================================================================================================
rule QilinDeathHack
inactive
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);
		int Qid = kbUnitQueryCreate("Qilin");
		kbUnitQuerySetPlayerID(Qid, pid);
		kbUnitQuerySetUnitType(Qid,qilinID);
		kbUnitQuerySetState(Qid,2);
		
		int num = kbUnitQueryExecute(Qid);
		for(i=0;<num)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(Qid,i));
			trDamageUnitsInArea(pid,"LogicalTypeCanBeHealed",healRange,healSpeed);
			trUnitDelete(false);
		}
	}
	xsSetContextPlayer(prevPlayer);
}
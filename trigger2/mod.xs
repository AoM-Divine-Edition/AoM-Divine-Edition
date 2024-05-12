include "cVariables.xs";
int NightmareActive = 0;
int tempModIndex = 0;
int plagueMod = 5;


// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< If you've seen the RotG vc scripts, I apologize for the mess lmao >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


rule RecordedHack
minInterval 0
maxInterval 0
inactive 
{
	trTechSetStatus(1, 1097, cTechStatusUnobtainable);
	trTechSetStatus(2, 1097, cTechStatusUnobtainable);
	trTechSetStatus(1, 1102, cTechStatusActive);
	trTechSetStatus(2, 1098, cTechStatusActive);
	xsDisableSelf();
}



rule Debug
minInterval 0
maxInterval 0
active
{
    int testVariables = cTechStatusUnobtainable;
    trChatSend(0, "VC works and variables loaded!");
    //trChatSend(0, kbGetTechName(678) ); // Wrath of Ithaqua
    //trChatSend(0, kbGetTechName(679) ); // Wrath of Ithaqua Prime
    //trChatSend(0, kbGetTechName(695) ); // Nightmare Shade
    //trChatSend(0, kbGetTechName(696) ); // Nightmare Beacons Light
    //trChatSend(0, kbGetTechName(710) ); // Yith Exclusion 1
    //trChatSend(0, kbGetTechName(652) ); // Age 1 Yog-Sothoth
    //trChatSend(0, kbGetTechName(653) ); // Age 1 Shub-Niggurath
    //trChatSend(0, kbGetTechName(777) ); // Age 1 Izanami
	//trChatSend(0, kbGetTechName(654) ); // Eldritch Civ
	//trChatSend(0, kbGetTechName(650) ); // Zeus Real
	//trChatSend(0, kbGetTechName(68)  ); // Age 1 Zeus
	//trChatSend(0, kbGetTechName(959)  ); // Age 1 Hanwi Fake
	//trChatSend(0, kbGetTechName(978)  ); // Age 1 Wi
	//trchatsend(0, kbGetTechName(1021)  ); // Medicinal Knowledge
	//trchatsend(0, kbGetTechName(1033)  ); // Fushimi Pilgrimage
	//trchatsend(0, kbGetTechName(1096)  ); // God Picked
	//trchatsend(0, kbGetTechName(1145)  ); // Age 2 Apollo
	//trChatSend(0, kbGetTechName(1236)  ); // Demeter Triggered
	//trChatSend(0, kbGetTechName(1273)  ); // Age 1 Aten
	//trChatSend(0, kbGetTechName(304)  ); // Omniscience
	//trChatSend(0, kbGetTechName(1267)  ); // Springtime Radiance
	//trChatSend(0, kbGetTechName(1312)  ); // Rays of Life
	//trChatSend(0, kbGetTechName(1326)  ); // Age 1 Freyr
	//trChatSend(0, kbGetTechName(1271)  ); // Homeland Fortification
	//trChatSend(0, kbGetTechName(1358)  ); // Age 1 Iapetus Real
	//trChatSend(0, kbGetTechName(1385)  ); // Age 1 Nameless Mist


	trTechSetStatus(0, 304, cTechStatusActive);
	trTechSetStatus(0, 1238, cTechStatusActive);

		
    xsDisableSelf();
}


rule romeLimits
minInterval 0
maxInterval 0
active 
{
	for (i=1; < cNumberPlayers)
    {			
	xsSetContextPlayer(i);
		if (kbGetTechStatus(1134) == cTechStatusActive) {
			int q_id = kbUnitQueryCreate("Legionary");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Legionary"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);
			trModifyProtounit( "optio", i, 10, (q_len / 2) - kbGetBuildLimit(i, kbGetProtoUnitID("Optio") ));

			

			q_id = kbUnitQueryCreate("Optio");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Optio"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);
			trModifyProtounit( "Centurion", i, 10, (q_len / 2) - kbGetBuildLimit(i, kbGetProtoUnitID("Centurion") ));

			
			q_id = kbUnitQueryCreate("Imperator");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Imperator"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);
			trModifyProtounit( "Legate", i, 10, (q_len / 2) - kbGetBuildLimit(i, kbGetProtoUnitID("Legate") ));
			
			q_id = kbUnitQueryCreate("Equite");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Equite"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);
			trModifyProtounit( "Decurion", i, 10, (q_len / 2) - kbGetBuildLimit(i, kbGetProtoUnitID("Decurion") ));
			
			q_id = kbUnitQueryCreate("Praetorian");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Praetorian"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);
			if (q_len >= 5) {
				trModifyProtounit( "Praetorian Prefect", i, 10, 1 - kbGetBuildLimit(i, kbGetProtoUnitID("Praetorian Prefect") ));
			} else {
				trModifyProtounit( "Praetorian Prefect", i, 10, 0 - kbGetBuildLimit(i, kbGetProtoUnitID("Praetorian Prefect") ));
			}


		}
	}
}

int portalIndex = 0;
int isAbaddon = 0;

rule portalTest
minInterval 0
maxInterval 0
active 
{
    
	xsSetContextPlayer(0);
	int q_id = kbUnitQueryCreate("Sky Passage");
	kbUnitQuerySetPlayerID(q_id, 0);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Sky Passage"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);
	
	int realNumberPlayers = cNumberPlayers - 1;
	vector center1 = vector(0,0,0);
	vector center2 = vector(0,0,0);

	if (q_len == 1) {
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
		trUnitChangeInArea(0, 1 - 1, "Sky Passage", "Revealer to Player", 1.5);
		for (i=1; < realNumberPlayers){
			trPlayerSetDiplomacy(cNumberPlayers - 1, i, "ally");
			trPlayerSetDiplomacy(i, cNumberPlayers - 1, "ally");
		}
		xsEnableRule("PortalShift");
		xsDisableSelf();
	} else if (portalIndex > 0) {
		if (q_len >= 2) {
		
			if (q_len > (3 * realNumberPlayers) + portalIndex) {
				center1 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,0));
				center2 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,(3 * realNumberPlayers) + portalIndex ));

					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
					trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "Revealer to Player", 1.5);
					//trUnitDelete(false);
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,(3 * realNumberPlayers) + portalIndex ));
					if ((portalIndex <= (realNumberPlayers - 1) * 8) && (portalIndex > (realNumberPlayers - 1) * 4) && (isAbaddon == 1)) {
						trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "vortex landing silent", 1.5);
					} else {
						trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "Revealer to Player", 1.5);
					}
					//trUnitDelete(false);

				trTechInvokeGodPower(0, "void portal", center1, center2);

				portalIndex = portalIndex + 2;
			}  else {
				 center1 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,0));
				 center2 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,q_len-1));

					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
					trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "Revealer to Player", 1.5);
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,q_len-1));
					trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "Revealer to Player", 1.5);				

		
				trTechInvokeGodPower(0, "void portal", center1, center2);
			}
		} else {
			for (i=1; < realNumberPlayers)
			{
				trPlayerSetDiplomacy(cNumberPlayers - 1, i, "ally");
				trPlayerSetDiplomacy(i, cNumberPlayers - 1, "ally");
			}
			trPlayerResetBlackMapForAllPlayers();
		xsEnableRule("PortalShift");

			xsDisableSelf();
		}

	} else if(q_len > 0){

		trPlayerKillAllBuildings(cNumberPlayers - 1);
		trPlayerKillAllUnits(cNumberPlayers - 1);
		trTechGodPower(cNumberPlayers - 1, "void portal", 99999); 
		trModifyProtounit( "void portal", cNumberPlayers - 1, 0, 100000);
		//trModifyProtounit( "void portal", cNumberPlayers - 1, 2, -100);

			for (i=1; < realNumberPlayers)
			{
				trPlayerSetDiplomacy(cNumberPlayers - 1, i, "ally");
				trPlayerSetDiplomacy(i, cNumberPlayers - 1, "ally");
				//trTechSetStatus(i, 378, cTechStatusActive);
			}

		int q_id2 = kbUnitQueryCreate("Shade");
		kbUnitQuerySetPlayerID(q_id2, 0);
		kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Shade"));
		kbUnitQuerySetState(q_id2,2);
		int q_len2 = kbUnitQueryExecute(q_id2);

		if (q_len2 > 0) {
			//isAbaddon = 1;
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id2,0));
			trUnitDelete(false);
		}


		for (j=0;<realNumberPlayers - 1) {
			center1 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
			center2 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j + realNumberPlayers - 1 ));

			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			if (isAbaddon == 0) {
				trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "vortex landing silent", 1.5);
			} else {
				trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "vortex landing silent", 1.5);
			}
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j + realNumberPlayers - 1 ));
			trUnitChangeInArea(0, cNumberPlayers - 1, "Sky Passage", "vortex landing silent", 1.5);
			trTechInvokeGodPower(cNumberPlayers - 1, "void portal", center1, center2);

		}


		portalIndex = 2;


	} else {

		xsDisableSelf();
	}


}


rule OdinsAltarPlentyAlert
minInterval 15
maxInterval 15
active 
{


	xsSetContextPlayer( 0);
	int q_id = kbUnitQueryCreate("Odins Tower");
	kbUnitQuerySetPlayerID(q_id, 0);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Odins Tower"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);

	if(q_len > 0) {
		trChatSend(0, "Plenty Vaults disabled until 4:30!");

	}
	xsDisableSelf();
}


rule OdinsAltarPlenty
minInterval 270
maxInterval 270
active 
{


	xsSetContextPlayer( 0);
	int q_id = kbUnitQueryCreate("Odins Tower");
	kbUnitQuerySetPlayerID(q_id, 0);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Odins Tower"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);

	if(q_len > 0) {
		trChatSend(0, "Plenty Vaults active!");

		for (i=1; < cNumberPlayers-1){
			trTechSetStatus(i, 378, cTechStatusActive);
		}

	}
	xsDisableSelf();
}


rule OuranosHackA
minInterval 15
maxInterval 15
inactive 
{


	xsSetContextPlayer( cNumberPlayers-1);
	int q_id = kbUnitQueryCreate("void portal");
	kbUnitQuerySetPlayerID(q_id, cNumberPlayers-1);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("void portal"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);

	if(q_len > 0) {

		for (i=1;<cNumberPlayers-1) {
				xsSetContextPlayer(i);

			if (kbGetTechStatus(967) == cTechStatusActive){

				xsSetContextPlayer(0);
				q_id = kbUnitQueryCreate("Settlement");
				kbUnitQuerySetPlayerID(q_id, 0);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Settlement"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				for(j=0;<q_len)
				{
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
					trUnitChangeInArea(0, i, "Settlement", "Revealer to Player", 7.5);
				}

				xsSetContextPlayer(i);
				q_id = kbUnitQueryCreate("Revealer to Player");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Revealer to Player"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);

				trChatSend(0, "hi: " + q_len);


				for(j=0;<q_len)
				{
					trChatSend(0, "fg");
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitChangeInArea(i, 0, "Revealer to Player", "Settlement", 7.5);
				}

			}
		}

		
				

	}

	xsDisableSelf();

}

				



rule PortalShift
minInterval 0
maxInterval 0
active 
{
	

	xsSetContextPlayer(0);
	int q_id = kbUnitQueryCreate("void portal");
	kbUnitQuerySetPlayerID(q_id, 0);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("void portal"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);
	
	for (j=0;<q_len) {
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
		trUnitChangeInArea(0, cNumberPlayers - 1, "void portal", "void portal", 1.5);
	}


	for (j=1;<cNumberPlayers-1) {
		xsSetContextPlayer(j);
		for (i=1;<cNumberPlayers-1) {
			if (kbIsPlayerAlly(i)) {
				trPlayerModifyLOS(i, true, j);
			}
		}
	}
	xsDisableSelf();


}



rule MinervaGP
minInterval 1
maxInterval 1
active
{


	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);

		if (kbGetTechStatus(1133) == cTechStatusActive) {
			if (kbGetTechStatus(1166) == cTechStatusActive) {
			
				
				
				if (kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP")) > 0) {
					


					if  (kbGetTechStatus(1229) == cTechStatusActive && trPlayerResourceCount(i, "Food") >= 400) {
						trChatSend(0, "C: "  );
						trPlayerGrantResources(i, "Food", -400);
						trTechSetStatus(i, 1229, cTechStatusUnobtainable);

						int techID = 1143 + kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"));
						trTechSetStatus(i, techID, cTechStatusActive);
						trTechSetStatus(i, 1166, cTechStatusUnobtainable);
						trChatSend(0, "A: " + kbGetTechName(techID)  );
						trModifyProtounit( "MinervaGP", i, 10, (0 - kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"))) );

					} else if  (kbGetTechStatus(1230) == cTechStatusActive && (trPlayerResourceCount(i, "Food") >= 800 && trPlayerResourceCount(i, "Gold") >= 500)) {
						trPlayerGrantResources(i, "Food", -800);
						trPlayerGrantResources(i, "Gold", -500);
						trTechSetStatus(i, 1230, cTechStatusUnobtainable);
						trChatSend(0, "D: "  );

						techID = 1143 + kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"));
						trTechSetStatus(i, techID, cTechStatusActive);
						trTechSetStatus(i, 1166, cTechStatusUnobtainable);
						trChatSend(0, "A: " + kbGetTechName(techID)  );
						trModifyProtounit( "MinervaGP", i, 10, (0 - kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"))) );

					} else if  (kbGetTechStatus(1231) == cTechStatusActive && (trPlayerResourceCount(i, "Food") >= 1000 && trPlayerResourceCount(i, "Gold") >= 1000)) {
						trPlayerGrantResources(i, "Food", -1000);
						trPlayerGrantResources(i, "Gold", -1000);
						trTechSetStatus(i, 1231, cTechStatusUnobtainable);
						trChatSend(0, "E: "  );

						techID = 1143 + kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"));
						trTechSetStatus(i, techID, cTechStatusActive);
						trTechSetStatus(i, 1166, cTechStatusUnobtainable);
						trChatSend(0, "A: " + kbGetTechName(techID)  );
						trModifyProtounit( "MinervaGP", i, 10, (0 - kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"))) );
					}

				}

				for (checkID = 1144; <1144 + 9) {

					float perc = kbGetTechPercentComplete(checkID);
					float limit = 0.0;
					if (checkID - 1144 < 3) {
						limit = 0.8;
					} else if (checkID - 1144 < 6) {
						limit = 0.4;
					} else {
						limit = 0.1;
					}

					if (perc > limit && perc < 1.0) {

						trChatSend(0, "B: " + kbGetTechName(checkID)  );

						int q_id = kbUnitQueryCreate("SettlementsThatTrainVillagers");
						kbUnitQuerySetPlayerID(q_id, i);
						kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Settlement Level 1"));
						kbUnitQuerySetState(q_id,2);
						int q_len = kbUnitQueryExecute(q_id);
						for(j=0;<q_len)
						{
							researchCancelByID(checkID, kbUnitQueryGetResult(q_id,j), i);
						}

						trModifyProtounit( "MinervaGP", i, 10, (checkID - 1143 - kbGetBuildLimit(i, kbGetProtoUnitID("MinervaGP"))) );
						//trchatsend(0, kbGetTechName(checkID)  );


						if (checkID - 1144 < 3) {
							trTechSetStatus(i, 1229, cTechStatusActive);
						} else if (checkID - 1144 < 6) {
							trTechSetStatus(i, 1230, cTechStatusActive);
						} else {
							trTechSetStatus(i, 1231, cTechStatusActive);
						}




						break;
						//trTechSetStatus(i, 1145, cTechStatusActive);
					}

				}
				
			}
		}
	}
}

rule AtlanteanAIHack
active
maxInterval 180
minInterval 180
priority 100
{
	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);
		if(kbIsPlayerHuman(i))
		{
			
		}
		else 
		{



			if(kbGetTechStatus(965) == cTechStatusActive || kbGetTechStatus(966) == cTechStatusActive || kbGetTechStatus(967) == cTechStatusActive) {
				int q_id2 = kbUnitQueryCreate("Manor");
				kbUnitQuerySetPlayerID(q_id2, i);
				kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Manor"));
				kbUnitQuerySetState(q_id2,2);
				int q_len2 = kbUnitQueryExecute(q_id2);
				for(j2=0;<1) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
					trUnitChangeInArea(i, i, "Manor", "Temple", 1.5);

				}

			}
		}

	}

	xsDisableSelf();

}


rule CultistInTwistedSpire
minInterval 1
maxInterval 1
active
{
    for (i=1; < cNumberPlayers)
    {
        
		xsSetContextPlayer(i);

		if(kbGetTechStatus(654) == cTechStatusActive)
		{

			int q_id = kbUnitQueryCreate("Cultist");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Cultist"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

				

				if (trUnitGetIsContained("Twisted Spire")) {
					trUnitChangeProtoUnit("Twisted Spire Skull");
				}
			}

			q_id = kbUnitQueryCreate("Sacrificial Lamb");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Sacrificial Lamb"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

				

				if (trUnitGetIsContained("Twisted Spire")) {
					trUnitChangeProtoUnit("Twisted Spire Skull");
				}
			}

		}
	}
}

rule Vengeance
active
minInterval 1
maxInterval 1
priority 100
{
	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);
		if(kbGetTechStatus(1326) == cTechStatusActive)
		{


			int q_id = kbUnitQueryCreate("Vengeance Active");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Vengeance Active"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

				for(pid2=1;<cNumberPlayers)
				{		
					if (kbIsPlayerEnemy(pid2)) {
						trDamageUnitsInArea(pid2,"All",30.00,1000.00);
					}
				}
				trUnitDelete(false);
			}

		}
	}

}

rule FreyrValue
active
minInterval 5
maxInterval 5
priority 100
{

	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);

		
		
		if(kbGetTechStatus(1326) == cTechStatusActive) {

			int totalFavor = kbTotalResourceGet(3);
			int priorFavor = kbGetBuildLimit(i, kbGetProtoUnitID("Rock Snow"));

			int newFavor = totalFavor - priorFavor;

			trPlayerGrantResources(i, "Food", 8*newFavor);
			trPlayerGrantResources(i, "Wood", 6*newFavor);
			trPlayerGrantResources(i, "Gold", 4*newFavor);

			trModifyProtounit( "Rock Snow", i, 10, newFavor );

			if(kbGetTechStatus(1344) == cTechStatusActive) {
				trPlayerGrantResources(i, "Food", 8*newFavor);
				trPlayerGrantResources(i, "Wood", 6*newFavor);
				trPlayerGrantResources(i, "Gold", 4*newFavor);
			}
			

		}
	}
}


rule HuitzilopochtliPower
active
//runImmediately
minInterval 120
maxInterval 120
priority 100
{

	//trChatSend(0, kbGetTechName(873)  ); // Age 1 Huitzilopochtli
	//trEchoStatValue(1, 0); // tribute received
	//trEchoStatValue(1, 1); // tribute sent
	//trEchoStatValue(1, 2); // units killed
	//trEchoStatValue(1, 3); // buildings killed
	//trEchoStatValue(1, 4); // units killed cost
	//trEchoStatValue(1, 5); // buildings killed cost 
	//trEchoStatValue(1, 6); // Units lost
	//trEchoStatValue(1, 7); // buildings lost
	//trEchoStatValue(1, 8); // units lost cost
	//trEchoStatValue(1, 9); // buildings lost cost
	//trEchoStatValue(1, 10); // map explored
	//trEchoStatValue(1, 11); // trade profit

	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);
		
		if(kbGetTechStatus(873) == cTechStatusActive) {
			//trEchoStatValue(1, 2); // units killed
			//trEchoStatValue(1, 6); // Units lost
			if (trGetStatValue(i, 2) > trGetStatValue(i, 6)) {
				trTechGodPowerAtPosition(i, "Solar Beam", 1 + kbGetAgeForPlayer(i), 1);
				trChatSendToPlayer(0, i, "Solar Beam Charge(s) Granted");
			}
		}
	}
}

rule HuitzilopochtliStrength
active
//runImmediately
minInterval 5
maxInterval 5
priority 100
{


	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);
		if(kbGetTechStatus(873) == cTechStatusActive) {
			//trChatSend(0, kbGetTechName(1091)  ); // Huitzilopochtli Strength 1
			//trChatSend(0, "" );
			//trEchoStatValue(1, 4); // units killed cost
			//trEchoStatValue(1, 5); // buildings killed cost 
			//trEchoStatValue(1, 8); // units lost cost
			//trEchoStatValue(1, 9); // buildings lost cost

			int kill_cost = trGetStatValue(i, 4) + trGetStatValue(i, 5);
			int lost_cost = trGetStatValue(i, 8) + trGetStatValue(i, 9);

			trChatSendToPlayer(0, i, "Your K/D is " + trGetStatValue(i, 2) + " to " + trGetStatValue(i, 6));
			trChatSendToPlayer(0, i, "Your cost K/D is " + kill_cost + " to " + lost_cost);

			if (kill_cost - 50 > lost_cost) {
				
				if (trTechStatusActive(i, 1091)) {
				} else {
					trTechSetStatus(i, 1091, cTechStatusActive);
				}
				if (kill_cost - 125 - 100 > lost_cost * 1.125) {
					
					if (trTechStatusActive(i, 1092)) {
					} else {
						trTechSetStatus(i, 1092, cTechStatusActive);
					}
					if (kill_cost - 250 - 150 > lost_cost * 1.25) {
						
						if (trTechStatusActive(i, 1093)) {
						} else {
							trTechSetStatus(i, 1093, cTechStatusActive);
						}
						if (kill_cost - 900 > lost_cost * 1.5) {
							
							if (trTechStatusActive(i, 1094)) {
							} else {
								trTechSetStatus(i, 1094, cTechStatusActive);
							}
							if (kill_cost - 1600 > lost_cost * 2) {
								trChatSend(0, "Strength level 5");
								if (trTechStatusActive(i, 1095)) {
								} else {
									trTechSetStatus(i, 1095, cTechStatusActive);
								}
							} else {
								trTechSetStatus(i, 1095, cTechStatusUnobtainable);
								trChatSendToPlayer(0, i, "Strength level 4");
							}
						} else {
							trTechSetStatus(i, 1095, cTechStatusUnobtainable);
							trTechSetStatus(i, 1094, cTechStatusUnobtainable);
							trChatSendToPlayer(0, i,  "Strength level 3");
						}

					} else {
						trTechSetStatus(i, 1095, cTechStatusUnobtainable);
						trTechSetStatus(i, 1094, cTechStatusUnobtainable);
						trTechSetStatus(i, 1093, cTechStatusUnobtainable);
						trChatSendToPlayer(0, i,  "Strength level 2");
					}

				} else {
					trTechSetStatus(i, 1095, cTechStatusUnobtainable);
					trTechSetStatus(i, 1094, cTechStatusUnobtainable);
					trTechSetStatus(i, 1093, cTechStatusUnobtainable);
					trTechSetStatus(i, 1092, cTechStatusUnobtainable);
					trChatSendToPlayer(0, i,  "Strength level 1");
				}

			} else {
				trTechSetStatus(i, 1095, cTechStatusUnobtainable);
				trTechSetStatus(i, 1094, cTechStatusUnobtainable);
				trTechSetStatus(i, 1093, cTechStatusUnobtainable);
				trTechSetStatus(i, 1092, cTechStatusUnobtainable);
				trTechSetStatus(i, 1091, cTechStatusUnobtainable);
				trChatSend(0, "Strength level 0");
			}
		}
	}
}

rule AiPickZeus
inactive
//runImmediately
minInterval 1
maxInterval 1
priority 100
{
	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);
		if(kbIsPlayerHuman(i))
		{
			
		}
		else 
		{
			if(kbGetTechStatus(68) == cTechStatusActive) {
				trChatSend(0, "AI set to Zeus");
				trTechSetStatus(i, 650, cTechStatusActive);
			} else if(kbGetTechStatus(83) == cTechStatusActive) {
				trChatSend(0, "AI set to Poseidon");
				trTechSetStatus(i, 860, cTechStatusActive);
			} else if(kbGetTechStatus(82) == cTechStatusActive) {
				trChatSend(0, "AI set to Hades");
				trTechSetStatus(i, 859, cTechStatusActive);
			} else if(kbGetTechStatus(516) == cTechStatusActive) {
				trChatSend(0, "AI set to Fu Xi");
				trTechSetStatus(i, 880, cTechStatusActive);
			} else if(kbGetTechStatus(517) == cTechStatusActive) {
				trChatSend(0, "AI set to Nu Wa");
				trTechSetStatus(i, 881, cTechStatusActive);
			} else if(kbGetTechStatus(518) == cTechStatusActive) {
				trChatSend(0, "AI set to Shennong");
				trTechSetStatus(i, 882, cTechStatusActive);
			} else if(kbGetTechStatus(85) == cTechStatusActive) {
				trChatSend(0, "AI set to Ra");
				trTechSetStatus(i, 968, cTechStatusActive);
			} else if(kbGetTechStatus(86) == cTechStatusActive) {
				trChatSend(0, "AI set to Isis");
				trTechSetStatus(i, 969, cTechStatusActive);
			} else if(kbGetTechStatus(87) == cTechStatusActive) {
				trChatSend(0, "AI set to Set");
				trTechSetStatus(i, 970, cTechStatusActive);
			} else if(kbGetTechStatus(88) == cTechStatusActive) {
				trChatSend(0, "AI set to Odin");
				trTechSetStatus(i, 971, cTechStatusActive);
			} else if(kbGetTechStatus(89) == cTechStatusActive) {
				trChatSend(0, "AI set to Thor");
				trTechSetStatus(i, 972, cTechStatusActive);
			} else if(kbGetTechStatus(90) == cTechStatusActive) {
				trChatSend(0, "AI set to Loki");
				trTechSetStatus(i, 973, cTechStatusActive);
			} else if(kbGetTechStatus(392) == cTechStatusActive) {
				trChatSend(0, "AI set to Kronos");
				trTechSetStatus(i, 974, cTechStatusActive);
			} else if(kbGetTechStatus(393) == cTechStatusActive) {
				trChatSend(0, "AI set to Gaia");
				trTechSetStatus(i, 975, cTechStatusActive);
			} else if(kbGetTechStatus(395) == cTechStatusActive) {
				trChatSend(0, "AI set to Ouranos");
				trTechSetStatus(i, 976, cTechStatusActive);
			}


		}
	}
	xsDisableSelf();
}

rule KillTheMusic
active
runImmediately
minInterval 0
maxInterval 0
priority 100
{
	trMusicStop();
	xsDisableSelf();
}

rule PlayMusic
active
minInterval 75
maxInterval 75
priority 100
{
	trMusicSetCurrentMusicSet();
	trMusicPlayCurrent();
	xsDisableSelf();
}

int allDone = 0;




rule SetGodTest
minInterval 0
maxInterval 0
active
{
	int done = 1;

    for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);

		//if(kbGetTechStatus(395) == cTechStatusActive) {
		//	trPlayerResetBlackMap(i);
		//}


		if(kbGetTechStatus(1097) == cTechStatusActive) {
			trChatSend(i, "I picked the old god!");


			if(kbGetTechStatus(68) == cTechStatusActive) {
				trTechSetStatus(i, 650, cTechStatusActive);
			} else if(kbGetTechStatus(83) == cTechStatusActive) {
				trTechSetStatus(i, 860, cTechStatusActive);
			} else if(kbGetTechStatus(82) == cTechStatusActive) {
				trTechSetStatus(i, 859, cTechStatusActive);
			} else if(kbGetTechStatus(516) == cTechStatusActive) {
				trTechSetStatus(i, 880, cTechStatusActive);
			} else if(kbGetTechStatus(517) == cTechStatusActive) {
				trTechSetStatus(i, 881, cTechStatusActive);
			} else if(kbGetTechStatus(518) == cTechStatusActive) {
				trTechSetStatus(i, 882, cTechStatusActive);
			} else if(kbGetTechStatus(85) == cTechStatusActive) {
				trTechSetStatus(i, 968, cTechStatusActive);
			} else if(kbGetTechStatus(86) == cTechStatusActive) {
				trTechSetStatus(i, 969, cTechStatusActive);
			} else if(kbGetTechStatus(87) == cTechStatusActive) {
				trTechSetStatus(i, 970, cTechStatusActive);
			} else if(kbGetTechStatus(88) == cTechStatusActive) {
				trTechSetStatus(i, 971, cTechStatusActive);
			} else if(kbGetTechStatus(89) == cTechStatusActive) {
				trTechSetStatus(i, 972, cTechStatusActive);
			} else if(kbGetTechStatus(90) == cTechStatusActive) {
				trTechSetStatus(i, 973, cTechStatusActive);
			} else if(kbGetTechStatus(392) == cTechStatusActive) {
				trTechSetStatus(i, 974, cTechStatusActive);
			} else if(kbGetTechStatus(393) == cTechStatusActive) {
				trTechSetStatus(i, 975, cTechStatusActive);
			} else if(kbGetTechStatus(395) == cTechStatusActive) {
				trTechSetStatus(i, 976, cTechStatusActive);
			}


		} else if(kbGetTechStatus(1098) == cTechStatusActive) {
			trChatSend(i, "I picked azathoth!");
			trTechSetStatus(i, 864, cTechStatusActive);
		} else if(kbGetTechStatus(1099) == cTechStatusActive) {
			trChatSend(i, "I picked yog-sothoth!");
			trTechSetStatus(i, 865, cTechStatusActive);
		} else if(kbGetTechStatus(1100) == cTechStatusActive) {
			trChatSend(i, "I picked shub-niggurath!");
			trTechSetStatus(i, 866, cTechStatusActive);
		} else if(kbGetTechStatus(1104) == cTechStatusActive) {
			trChatSend(i, "I picked izanagi!");
			//trTechSetStatus(i, 867, cTechStatusActive);						// UNCOMMENT WHEN DEVELOPING
		} else if(kbGetTechStatus(1105) == cTechStatusActive) {
			trChatSend(i, "I picked izanami!");
			//trTechSetStatus(i, 868, cTechStatusActive);						// UNCOMMENT WHEN DEVELOPING
		} else if(kbGetTechStatus(1106) == cTechStatusActive) {
			trChatSend(i, "I picked kagu!");
			//trTechSetStatus(i, 869, cTechStatusActive);						// UNCOMMENT WHEN DEVELOPING
		} else if(kbGetTechStatus(1101) == cTechStatusActive) {
			trChatSend(i, "I picked tezcat!");
			trSetCivAndCulture(i, 14, 4);
			trTechSetStatus(i, 874, cTechStatusActive);
			trTechSetStatus(i, 1101, cTechStatusActive);
			
			trPlayerKillAllGodPowers(i);
		} else if(kbGetTechStatus(1102) == cTechStatusActive) {
			trChatSend(i, "I picked	quetzal!");
			trSetCivAndCulture(i, 14, 4);
			trTechSetStatus(i, 875, cTechStatusActive);
			trTechSetStatus(i, 1102, cTechStatusActive);
			trPlayerKillAllGodPowers(i);
		} else if(kbGetTechStatus(1103) == cTechStatusActive) {
			trChatSend(i, "I picked huitzil!");
			trSetCivAndCulture(i, 14, 4);
			trTechSetStatus(i, 876, cTechStatusActive);
			trTechSetStatus(i, 1103, cTechStatusActive);
			trPlayerKillAllGodPowers(i);
		} else if(kbGetTechStatus(1107) == cTechStatusActive) {
			trChatSend(i, "I picked khaos!");
			trChatSend(i, "lol jk it's demeter!");
			trPlayerKillAllGodPowers(i);
			trTechSetStatus(i, 1236, cTechStatusActive);
		} else if(kbGetTechStatus(1108) == cTechStatusActive) {
			trChatSend(i, "I picked chronos!");
			trChatSend(i, "lol jk it's aten!");
			trPlayerKillAllGodPowers(i);
			trSetCivAndCulture(i, 4, 1);
			trPlayerKillAllGodPowers(i);
			trTechSetStatus(i, 1273, cTechStatusActive);
		} else if(kbGetTechStatus(1109) == cTechStatusActive) {
			trChatSend(i, "I picked ananke!");

			trChatSend(i, "lol jk it's freyr!");
			trPlayerKillAllGodPowers(i);
			trSetCivAndCulture(i, 7, 2);
			trPlayerKillAllGodPowers(i);
			trTechSetStatus(i, 1326, cTechStatusActive);
			
		} else if(kbGetTechStatus(1110) == cTechStatusActive) {
			trChatSend(i, "I picked nyx!");
			trChatSend(i, "lol jk it's iapetus!");
			trPlayerKillAllGodPowers(i);
			trSetCivAndCulture(i, 10, 3);
			trPlayerKillAllGodPowers(i);
			trTechSetStatus(i, 1358, cTechStatusActive);

		} else if(kbGetTechStatus(1111) == cTechStatusActive) {
			trChatSend(i, "I picked tartarus!");
			trChatSend(i, "lol jk it's the Nameless Mist!");
			trPlayerKillAllGodPowers(i);
			trTechSetStatus(i, 1385, cTechStatusActive);
		} else if(kbGetTechStatus(1112) == cTechStatusActive) {
			trChatSend(i, "I picked erebus!");
		}else if(kbGetTechStatus(1113) == cTechStatusActive) {
			trChatSend(i, "I picked jupiter!");
			trSetCivAndCulture(i, 14, 0);
			trTechSetStatus(i, 1128, cTechStatusActive);
			trTechSetStatus(i, 1113, cTechStatusActive);
			trPlayerKillAllGodPowers(i);
		}else if(kbGetTechStatus(1114) == cTechStatusActive) {
			trChatSend(i, "I picked juno!");
			trSetCivAndCulture(i, 14, 0);
			trTechSetStatus(i, 1129, cTechStatusActive);
			trTechSetStatus(i, 1114, cTechStatusActive);
			trPlayerKillAllGodPowers(i);
		}else if(kbGetTechStatus(1115) == cTechStatusActive) {
			trChatSend(i, "I picked minerva!");
			trSetCivAndCulture(i, 14, 0);
			trTechSetStatus(i, 1130, cTechStatusActive);
			trTechSetStatus(i, 1115, cTechStatusActive);
			trPlayerKillAllGodPowers(i);
		}else if(kbGetTechStatus(1116) == cTechStatusActive) {
			trChatSend(i, "I picked Ymir!");
		}else if(kbGetTechStatus(1117) == cTechStatusActive) {
			trChatSend(i, "I picked surtr!");
		}else if(kbGetTechStatus(1118) == cTechStatusActive) {
			trChatSend(i, "I picked aegir!");
		}else if(kbGetTechStatus(1119) == cTechStatusActive) {
			trChatSend(i, "I picked wi!");
			trTechSetStatus(i, 981, cTechStatusActive);						// UNCOMMENT WHEN DEVELOPING
		}else if(kbGetTechStatus(1120) == cTechStatusActive) {
			trChatSend(i, "I picked unci makha!");
			trTechSetStatus(i, 982, cTechStatusActive);						// UNCOMMENT WHEN DEVELOPING
		}else if(kbGetTechStatus(1121) == cTechStatusActive) {
			trChatSend(i, "I picked Hihan-Kaga!");
			trTechSetStatus(i, 983, cTechStatusActive);						// UNCOMMENT WHEN DEVELOPING
		}else if(kbGetTechStatus(1122) == cTechStatusActive) {
			trChatSend(i, "I picked the dagda!");
		}else if(kbGetTechStatus(1123) == cTechStatusActive) {
			trChatSend(i, "I picked lugh!");
		}else if(kbGetTechStatus(1124) == cTechStatusActive) {
			trChatSend(i, "I picked morrigan!");
		}else if(kbGetTechStatus(1125) == cTechStatusActive) {
			trChatSend(i, "I picked enlil!");

			trChatSend(i, "lol jk it's Fu Xi fixed!");
			trPlayerKillAllGodPowers(i);
			trSetCivAndCulture(i, 12, 4);
			trPlayerKillAllGodPowers(i);

			trTechSetStatus(i, 1377, cTechStatusActive);
		}else if(kbGetTechStatus(1126) == cTechStatusActive) {
			trChatSend(i, "I picked inanna!");

			trChatSend(i, "lol jk it's Nu Wa fixed!");
			trPlayerKillAllGodPowers(i);
			trSetCivAndCulture(i, 13, 4);
			trPlayerKillAllGodPowers(i);

			trTechSetStatus(i, 1378, cTechStatusActive);
		}else if(kbGetTechStatus(1127) == cTechStatusActive) {
			trChatSend(i, "I picked marduk!");

			trChatSend(i, "lol jk it's Shennong fixed!");
			trPlayerKillAllGodPowers(i);
			trSetCivAndCulture(i, 14, 4);
			trPlayerKillAllGodPowers(i);

			trTechSetStatus(i, 1379, cTechStatusActive);
		} else {
			done = 0;
		}
	}



	if (done == 1) {
		trChatSend(0, "Everyone's done!");
		allDone = 1;
		xsDisableSelf();
	}

}

rule GodSwapTest
active
//runImmediately
minInterval 0
maxInterval 0
priority 100
{
	if (allDone == 1) {
	
		for (i=1; < cNumberPlayers)
		{

			xsSetContextPlayer(i);
			if (kbGetTechStatus(860) == cTechStatusActive) { // poseidon
				//trSetCivAndCulture(i, 1, 0);

				trPlayerKillAllGodPowers(i);

				trTechSetStatus(i, 863, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Poseidon");
			} else if (kbGetTechStatus(859) == cTechStatusActive) { // hades
				//trSetCivAndCulture(i, 2, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 862, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Hades");
			} else if (kbGetTechStatus(650) == cTechStatusActive) { // zeus
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 861, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Zeus");
			} else if (kbGetTechStatus(864) == cTechStatusActive) { // azathoth
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 651, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Azathoth");
			} else if (kbGetTechStatus(866) == cTechStatusActive) { // shub-niggurath
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 653, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Shub-Niggurath");
			} else if (kbGetTechStatus(865) == cTechStatusActive) { // yog-sothoth
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 652, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Yog-Sothoth");
			} else if (kbGetTechStatus(867) == cTechStatusActive) { // izanagi
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 776, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Izanagi");
			} else if (kbGetTechStatus(868) == cTechStatusActive) { // izanami
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 777, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Izanami");
			} else if (kbGetTechStatus(869) == cTechStatusActive) { // kagu-tsuchi
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 778, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Kagu-Tsuchi");
			} else if (kbGetTechStatus(880) == cTechStatusActive) { // fu xi
				//trSetCivAndCulture(i, 12, 4);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 877, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Fu Xi");
			} else if (kbGetTechStatus(881) == cTechStatusActive) { // nu wa
				//trSetCivAndCulture(i, 13, 4);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 878, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Nu Wa");
			} else if (kbGetTechStatus(882) == cTechStatusActive) { // shennong
				//trSetCivAndCulture(i, 14, 4);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 879, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Shennong");
			} else if (kbGetTechStatus(874) == cTechStatusActive) { // Tezcatlipoca
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 871, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Tezcatlipoca");
			} else if (kbGetTechStatus(875) == cTechStatusActive) { // Quetzalcoatl
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 872, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Quetzalcoatl");
			} else if (kbGetTechStatus(876) == cTechStatusActive) { // Huitzilopochtli
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 873, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Huitzilopochtli");
			}  else if (kbGetTechStatus(968) == cTechStatusActive) { // Ra
				//trSetCivAndCulture(i, 4, 1);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 959, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Ra");
			} else if (kbGetTechStatus(969) == cTechStatusActive) { // Isis
				//trSetCivAndCulture(i, 3, 1);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 960, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Isis");
			} else if (kbGetTechStatus(970) == cTechStatusActive) { // Set
				//trSetCivAndCulture(i, 5, 1);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 961, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Set");
			}  else if (kbGetTechStatus(972) == cTechStatusActive) { // Thor
				//trSetCivAndCulture(i, 7, 2);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 963, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Thor");
			} else if (kbGetTechStatus(971) == cTechStatusActive) { // Odin
				//trSetCivAndCulture(i, 6, 2);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 962, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Odin");
			} else if (kbGetTechStatus(973) == cTechStatusActive) { // Loki
				//trSetCivAndCulture(i, 8, 2);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 964, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Loki");
			}  else if (kbGetTechStatus(974) == cTechStatusActive) { // Kronos
				//trSetCivAndCulture(i, 9, 3);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 965, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Kronos");
			} else if (kbGetTechStatus(976) == cTechStatusActive) { // Ouranos
				//trSetCivAndCulture(i, 10, 3);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 967, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Ouranos");

				//xsSetContextPlayer(0);
				//int q_id = kbUnitQueryCreate("Settlement");
				//kbUnitQuerySetPlayerID(q_id, 0);
				//kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Settlement"));
				//kbUnitQuerySetState(q_id,2);
				//int q_len = kbUnitQueryExecute(q_id);
				//for(j=0;<q_len)
				//{
				//	trUnitSelectClear();
				//	trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
				//	trUnitChangeInArea(0, i, "Settlement", "Ouranos Settlement Hack", 7.5);
				//}

				//xsSetContextPlayer(i);
				//q_id = kbUnitQueryCreate("Ouranos Settlement Hack");
				//kbUnitQuerySetPlayerID(q_id, i);
				//kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ouranos Settlement Hack"));
				//kbUnitQuerySetState(q_id,2);
				//q_len = kbUnitQueryExecute(q_id);
				//for(j=0;<q_len)
				//{
				//	trUnitSelectClear();
				//	trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

				//	trUnitChangeInArea(i, 0, "Ouranos Settlement Hack", "Settlement", 7.5);
				//}




			} else if (kbGetTechStatus(975) == cTechStatusActive) { // Gaia
				//trSetCivAndCulture(i, 11, 3);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 966, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Gaia");
				trGenerateLush();
			} else if (kbGetTechStatus(981) == cTechStatusActive) { // Wi
				//trSetCivAndCulture(i, 10, 3);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 978, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Wi");

				
				trUnitSelectByID(1);
				trUnitChangeInArea(i, i, "Tower", "Lakota Sodhouse", 100000.0);

			} else if (kbGetTechStatus(982) == cTechStatusActive) { // Unci Makha
				//trSetCivAndCulture(i, 10, 3);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 979, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Unci Makha");

				trUnitSelectByID(1);
				trUnitChangeInArea(i, i, "Tower", "Lakota Sodhouse", 100000.0);

			} else if (kbGetTechStatus(983) == cTechStatusActive) { // Hihan-Kaga
				//trSetCivAndCulture(i, 10, 3);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 980, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Hihan-Kaga");

				trUnitSelectByID(1);
				trUnitChangeInArea(i, i, "Tower", "Lakota Sodhouse", 100000.0);

			} else if (kbGetTechStatus(1128) == cTechStatusActive) { // Jupiter
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 1131, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Jupiter");
			} else if (kbGetTechStatus(1129) == cTechStatusActive) { // Juno
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 1132, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Juno");
			} else if (kbGetTechStatus(1130) == cTechStatusActive) { // Minerva
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 1133, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Minerva");
			} else if (kbGetTechStatus(1236) == cTechStatusActive) { // Demeter
				//trPlayerKillAllGodPowers(i);
				//trTechSetStatus(i, 1133, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Demeter");
			} else if (kbGetTechStatus(1273) == cTechStatusActive) { // Aten
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "Aten");
				
			} else if (kbGetTechStatus(1326) == cTechStatusActive) { // Freyr
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "Freyr");
				
			} else if (kbGetTechStatus(1358) == cTechStatusActive) { // Iapetus
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "Iapetus");
				
			} else if (kbGetTechStatus(1385) == cTechStatusActive) { // Nameless Mist
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "The Nameless Mist");
				
			} else if (kbGetTechStatus(1377) == cTechStatusActive) { // Fu Xi Fixed
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "Fu Xi 2");
			} else if (kbGetTechStatus(1378) == cTechStatusActive) { // Nu Wa Fixed
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "Nu Wa 2");
			} else if (kbGetTechStatus(1379) == cTechStatusActive) { // Shennong Fixed
				trPlayerKillAllGodPowers(i);
				trSetCivilizationNameOverride(i, "Shennong 2");
			}
			
			else {													// Nothing selected
				trChatSend(i, "This god was unimplemented -- I am playing as Zeus.");
				//trSetCivAndCulture(i, 0, 0);
				trPlayerKillAllGodPowers(i);
				trTechSetStatus(i, 861, cTechStatusActive);
				trSetCivilizationNameOverride(i, "Zeus");
			}
			
		
		}
		xsDisableSelf();
	}
}


rule Migrate
minInterval 1
maxInterval 1
active
{
	for (i=1; < cNumberPlayers) {

		xsSetContextPlayer(i);	

		if(kbGetTechStatus(984) == cTechStatusActive) { // Lakota Civ

			// this is inefficient, change later -- maybe use Nate's arrays?


			int q_id = kbUnitQueryCreate("Settlement Level 1");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Settlement Level 1"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);

			
			if(kbGetTechStatus(1004) == cTechStatusActive) { // Migration Trigger Age 2
				if(kbGetTechStatus(1005) != cTechStatusActive) { // Migration Flag Age 2
					// trChatSend(0, "Migration Flag Found 2" );
					for(j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						trUnitChangeInArea(i, i, "Settlement Level 1", "Dead Town Center", 7.5);
						// trChatSend(0, "TC Killed 2" );
					}
					trTechSetStatus(i, 1005, cTechStatusActive);
				} else if(kbGetTechStatus(1006) != cTechStatusActive) { // Migration Not Done Age 2
					// trChatSend(0, "Searching for TC" );
					if (0 < q_len) {
						trTechSetStatus(i, 1006, cTechStatusActive);
						trTechSetStatus(i, 1007, cTechStatusActive);
						// trChatSend(0, "TC Found 2" );
					}
				}
			}

			if(kbGetTechStatus(1008) == cTechStatusActive) { // Migration Trigger Age 3
				if(kbGetTechStatus(1009) != cTechStatusActive) { // Migration Flag Age 3
					// trChatSend(0, "Migration Flag Found 3" );
					for(j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						trUnitChangeInArea(i, i, "Settlement Level 1", "Dead Town Center", 7.5);
						// trChatSend(0, "TC Killed 3" );
					}
					trTechSetStatus(i, 1009, cTechStatusActive);
				} else if(kbGetTechStatus(1010) != cTechStatusActive) { // Migration Not Done Age 2
					// trChatSend(0, "Searching for TC" );
					if (0 < q_len) {
						trTechSetStatus(i, 1010, cTechStatusActive);
						trTechSetStatus(i, 1011, cTechStatusActive);
						// trChatSend(0, "TC Found 3" );
					}
				}
			}


			if(kbGetTechStatus(1012) == cTechStatusActive) { // Migration Trigger Age 4
				if(kbGetTechStatus(1013) != cTechStatusActive) { // Migration Flag Age 4
					// trChatSend(0, "Migration Flag Found 4" );
					for(j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						trUnitChangeInArea(i, i, "Settlement Level 1", "Dead Town Center", 7.5);
						// trChatSend(0, "TC Killed 4" );
					}
					trTechSetStatus(i, 1013, cTechStatusActive);
				} else if(kbGetTechStatus(1014) != cTechStatusActive) { // Migration Not Done Age 4
					// trChatSend(0, "Searching for TC" );
					if (0 < q_len) {
						trTechSetStatus(i, 1014, cTechStatusActive);
						trTechSetStatus(i, 1015, cTechStatusActive);
						// trChatSend(0, "TC Found 4" );
					}
				}
			}

		}
	}


}



rule HealJap
minInterval 1
maxInterval 1
active
{

    //Iterate over the players, we start at 1 as gaia should
    // not be checked (she's always popcapped anyways)
    for (i=1; < cNumberPlayers)
    {
        xsSetContextPlayer(i);

		
		
		
	if(kbGetTechStatus(775) == cTechStatusActive)
	{

			if(kbGetTechStatus(1043) == cTechStatusActive) {
				if(trPlayerResourceCount(i, "Favor") >= 50) {
					if (kbGetTechStatus(1044) != cTechStatusActive) {
						trTechSetStatus(i, 1044, cTechStatusActive);
					}
				} else {
					trTechSetStatus(i, 1044, cTechStatusUnobtainable);
				}
			}



			int q_id2 = kbUnitQueryCreate("Healing Palace");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("jhgkjhgkjhgkjhg"));
			kbUnitQuerySetState(q_id2,2);
			int q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
					if (trUnitGetIsContained("Healing Palace")) {
						trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + 2 + kbUnitGetMaximumHitpoints(kbUnitQueryGetResult(q_id2,j2)) * 0.01 );
					}
					if (kbGetTechStatus(1038) == cTechStatusActive && trUnitGetIsContained("SettlementsThatTrainVillagers")) {
						trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + 2 + kbUnitGetMaximumHitpoints(kbUnitQueryGetResult(q_id2,j2)) * 0.01 );
					}



					if(kbGetTechStatus(1022) == cTechStatusActive)
					{
						
								if (trUnitGetIsContained("Healing Palace")) {
									trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + kbUnitGetMaximumHitpoints(kbUnitQueryGetResult(q_id2,j2)) * 0.01 );
								}
								if (kbGetTechStatus(1038) == cTechStatusActive && trUnitGetIsContained("SettlementsThatTrainVillagers")) {
									trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + kbUnitGetMaximumHitpoints(kbUnitQueryGetResult(q_id2,j2)) * 0.01 );
								}
						
					}

					if(kbGetTechStatus(802) == cTechStatusActive)
					{
						
								if (trUnitGetIsContained("Healing Palace")) {
									trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + kbUnitGetMaximumHitpoints(kbUnitQueryGetResult(q_id2,j2)) * 0.01 );
								}
								if (kbGetTechStatus(1038) == cTechStatusActive && trUnitGetIsContained("SettlementsThatTrainVillagers")) {
									trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + kbUnitGetMaximumHitpoints(kbUnitQueryGetResult(q_id2,j2)) * 0.01 );
								}
				
						
					}
				
			}

			if(kbGetTechStatus(1021) == cTechStatusActive)
			{
				q_id2 = kbUnitQueryCreate("Healing Palace Medicinal 1");
				kbUnitQuerySetPlayerID(q_id2, i);
				kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id2,2);
				q_len2 = kbUnitQueryExecute(q_id2);
				for(j2=0;<q_len2) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
						if (trUnitGetIsContained("Healing Palace")) {
							trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + 2 );
						}
						if (kbGetTechStatus(1038) == cTechStatusActive && trUnitGetIsContained("SettlementsThatTrainVillagers")) {
							trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + 2 );
						}
					
				}
				q_id2 = kbUnitQueryCreate("Healing Palace Medicinal 2");
				kbUnitQuerySetPlayerID(q_id2, i);
				kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Villager Japanese Skilled"));
				kbUnitQuerySetState(q_id2,2);
				q_len2 = kbUnitQueryExecute(q_id2);
				for(j2=0;<q_len2) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
						if (trUnitGetIsContained("Healing Palace")) {
							trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + 2 );
						}
						if (kbGetTechStatus(1038) == cTechStatusActive && trUnitGetIsContained("SettlementsThatTrainVillagers")) {
							trUnitSetHP(kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(q_id2,j2)) + 2 );
						}
					
				}
			}

			




			
			q_id2 = kbUnitQueryCreate("DivineIntervention");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("DivineIntervention"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
				for(j2=0;<q_len2)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));

				vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id2,j2));
				int center_id = kbUnitQueryGetResult(q_id2,j2);


				trTechGodPowerAtPosition(i, kbGetTechName(aiGetGodPowerTechIDForSlot(1)), 1, 1);
				trTechGodPowerAtPosition(i, kbGetTechName(aiGetGodPowerTechIDForSlot(2)), 1, 1);
				trTechGodPowerAtPosition(i, kbGetTechName(aiGetGodPowerTechIDForSlot(3)), 1, 1);

		
		
				trUnitDelete(false);
			}


			q_id2 = kbUnitQueryCreate("Invoker of Golden Hour");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Invoker of Golden Hour"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
				for(j2=0;<q_len2)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));

				trTechGodPowerAtPosition(i, "Golden Hour", 1, 1);
				trUnitDelete(false);
			}



			int gakko_id = -1;

			q_id2 = kbUnitQueryCreate("Gakko");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Gakko"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			if(0<q_len2)
			{
				gakko_id = kbUnitQueryGetResult(q_id2,0);
			}


			q_id2 = kbUnitQueryCreate("Skilled Serf Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Skilled Serf Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				int gakko_success = 0;
				int q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				int q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Villager Japanese Skilled");
				} else {
					trUnitDelete(false);
			}	}

			q_id2 = kbUnitQueryCreate("Otsuchiman Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Otsuchiman Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				gakko_success = 0;
				q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Ashigaru Otsuchiman");
				} else {
					trUnitDelete(false);
			}	}

			q_id2 = kbUnitQueryCreate("Pikeman Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Pikeman Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				gakko_success = 0;
				q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Ashigaru Pikeman");
				} else {
					trUnitDelete(false);
			}	}

			q_id2 = kbUnitQueryCreate("Archer Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Archer Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				gakko_success = 0;
				q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Ashigaru Archer");
				} else {
					trUnitDelete(false);
			}	}

			q_id2 = kbUnitQueryCreate("Hata-Gumi Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Hata-Gumi Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				gakko_success = 0;
				q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Hata-Gumi");
				} else {
					trUnitDelete(false);
			}	}

			q_id2 = kbUnitQueryCreate("Kajutsu Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Kajutsu Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				gakko_success = 0;
				q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Kajutsu Shinobi");
				} else {
					trUnitDelete(false);
			}	}

			q_id2 = kbUnitQueryCreate("Shinobi Lesson");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Shinobi Lesson"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				gakko_success = 0;
				q_id = kbUnitQueryCreate("Villager Japanese");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
				kbUnitQuerySetState(q_id,2);
				q_len = kbUnitQueryExecute(q_id);
				if (q_len > 0 && gakko_id > -1) {
					for (j=0;<q_len) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
						if (trUnitGetIsContained("Gakko")) {
							trUnitChangeProtoUnit("Arrow");
							gakko_success = 1;
							break;
				}	}	}
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				if (gakko_success == 1) {
					trUnitChangeProtoUnit("Shinobi");
				} else {
					trUnitDelete(false);
			}	}




			q_id2 = kbUnitQueryCreate("Emperor Lightning");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Emperor Lightning"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
				for(j2=0;<q_len2)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));

				center = kbUnitGetPosition(kbUnitQueryGetResult(q_id2,j2));
				center_id = kbUnitQueryGetResult(q_id2,j2);
				trSetDisableGPBlocking(true);
				trTechInvokeGodPower(0, "Bazinga", center, center);
				
				
		
				//trUnitDelete(false); // only uncomment this if you want it to work under god power blockers without the lightning effect.
			}

			if (q_len2 == 0) {
				trSetDisableGPBlocking(false);
			}




				 

			
			
    }

	}

}


rule Thunderbird
minInterval 0
maxInterval 0
active
{

 for (i=1; < cNumberPlayers)
    {
        xsSetContextPlayer(i);
			int q_id2 = kbUnitQueryCreate("Thunderbird Lightning");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Thunderbird Lightning"));
			kbUnitQuerySetState(q_id2,2);
			int q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));

				vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id2,j2));
				trTechInvokeGodPower(0, "Bazinga", center, center);
			}

		}

}


rule RefreshGodPowers
minInterval 1
maxInterval 1
active
{
    for (i=1; < cNumberPlayers)
    {
        
		xsSetContextPlayer(i);

		if(kbGetTechStatus(654) == cTechStatusActive)
		{

		int q_id = kbUnitQueryCreate("Invoker of Bazinga");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Bazinga"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Bazinga", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Eyegate");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Eyegate"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Eyegate", 1, 1);
		}
		q_id = kbUnitQueryCreate("Invoker of Voidlance");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Voidlance"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Voidlance", 1, 1);
		}
		q_id = kbUnitQueryCreate("Invoker of Bubbling Flesh");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Bubbling Flesh"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Bubbling Flesh", 1, 1);
		}
		q_id = kbUnitQueryCreate("Invoker of Spacial Fracture");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Spacial Fracture"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Spacial Fracture", 1, 1);
		}
		q_id = kbUnitQueryCreate("Invoker of Time Hunt");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Time Hunt"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Time Hunt", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Schism");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Schism"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Schism", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Maw");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Maw"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Maw", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Howling Gale");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Howling Gale"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Howling Gale", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Spinners Call");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Spinners Call"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Spinners Call", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Wrath of the Vile");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Wrath of the Vile"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Wrath of the Vile", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of The End");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of The End"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "The End", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Plague");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Plague"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Plague", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Yigs Curse");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Yigs Curse"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Yigs Curse", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Pillars of Irem");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Pillars of Irem"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Pillars of Irem", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Pull of the Deep");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Pull of the Deep"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Grand Schism", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Volcano");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Volcano"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Volcano", 1, 1);
		}

		q_id = kbUnitQueryCreate("Invoker of Grand Schism");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Grand Schism"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			trTechGodPowerAtPosition(i, "Ritual of Serpents", 1, 1);
		}


		}

	}


}




// REPLACE THIS WITH PURE TECHTREE 
rule BlightEffect
minInterval 1
maxInterval 1
active
{

    //Iterate over the players, we start at 1 as gaia should
    // not be checked
    for (i=1; < cNumberPlayers)
    {
        
		xsSetContextPlayer(i);
		int q_id = kbUnitQueryCreate("Blight Debuff");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Blight Debuff"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		if (q_len > 0) {
			if (trTechStatusActive(i, 1240)) {
			} else {
				trTechSetStatus(i, 1240, cTechStatusActive);
			}

		} else {
			trTechSetStatus(i, 1240, cTechStatusUnobtainable);
		}


    }
}


// REPLACE THIS WITH PURE TECHTREE 
rule YithStrength
minInterval 2
maxInterval 2
active
{

    //Iterate over the players, we start at 1 as gaia should
    // not be checked
    for (i=1; < cNumberPlayers)
    {
        
        xsSetContextPlayer(i);
	int q_id = kbUnitQueryCreate("Yith-Possessed");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Yith-Possessed"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);
    if (q_len <= 7) {
		if (trTechStatusActive(i, 710)) {
		} else {
			trTechSetStatus(i, 710, cTechStatusActive);
		}
		if (q_len <= 4) {
			if (trTechStatusActive(i, 711)) {
			} else {
				trTechSetStatus(i, 711, cTechStatusActive);
			}
			if (q_len <= 2) {
				if (trTechStatusActive(i, 712)) {
				} else {
					trTechSetStatus(i, 712, cTechStatusActive);
				}
				if (q_len <= 1) {
					if (trTechStatusActive(i, 713)) {
					} else {
						trTechSetStatus(i, 713, cTechStatusActive);
					}
				} else {
					trTechSetStatus(i, 713, cTechStatusUnobtainable);
				}

			} else {
				trTechSetStatus(i, 712, cTechStatusUnobtainable);
				trTechSetStatus(i, 713, cTechStatusUnobtainable);
			}

		} else {
			trTechSetStatus(i, 711, cTechStatusUnobtainable);
			trTechSetStatus(i, 712, cTechStatusUnobtainable);
			trTechSetStatus(i, 713, cTechStatusUnobtainable);
		}

	} else {
		trTechSetStatus(i, 710, cTechStatusUnobtainable);
		trTechSetStatus(i, 711, cTechStatusUnobtainable);
		trTechSetStatus(i, 712, cTechStatusUnobtainable);
		trTechSetStatus(i, 713, cTechStatusUnobtainable);
	}


    }
}


rule ConductRituals
minInterval 1
maxInterval 1
active
{
    int checkNightmare = 0;

    //Iterate over the players, we start at 1 as gaia should
    // not be checked
    for (i=1; < cNumberPlayers)
    {
        
        xsSetContextPlayer(i);

			if(kbGetTechStatus(654) == cTechStatusActive)
	{


	trPlayerSetDiplomacy(0, i, "enemy");
	int q_id = kbUnitQueryCreate("Ritual of Lightning");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of Lightning"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
		//trUnitDistanceToPoint(float x, float y, float z);
		//trTechInvokeGodPower(0, "Wrath of Gaea", vector(60.03, 20.00, 60.67), vector(0,0,0));
		trTechInvokeGodPower(0, "Wrath of Gaea", kbUnitGetPosition(kbUnitQueryGetResult(q_id,j)), kbUnitGetPosition(kbUnitQueryGetResult(q_id,j)));
		//trUnitDelete(false);
	}



	q_id = kbUnitQueryCreate("Dreamers Invocation");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Dreamers Invocation"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		int center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Dreamers Invocation", center, center);
		
		trUnitDelete(false);
	}

	q_id = kbUnitQueryCreate("Black Hole");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Black Hole"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Black Hole", center, center);
		
		trUnitDelete(false);
	}

	q_id = kbUnitQueryCreate("The King in Yellow");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("The King in Yellow"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trUnitChangeInArea(i, i, "The King in Yellow", "Invoker Yellow Temp", 1.0);

		trTechInvokeGodPower(0, "The King In Yellow Prelude", center, center);
		
		trUnitDelete(false);
	}

	q_id = kbUnitQueryCreate("Invoker Yellow Active");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker Yellow Active"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "The King in Yellow", center, center);
		
		trUnitDelete(false);
	}

	q_id = kbUnitQueryCreate("Black Grove");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Black Grove"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Black Grove", center, center);
		
		trUnitDelete(false);
	}

	
	xsSetContextPlayer(0);

	int q_id2 = kbUnitQueryCreate("Voormis 4");
	kbUnitQuerySetPlayerID(q_id2, 0);
	kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Voormis 4"));
	kbUnitQuerySetState(q_id2,2);
	int q_len2 = kbUnitQueryExecute(q_id2);
        for(k=0;<q_len2)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id2,k));
	
		//trUnitConvert(i);
	}

	xsSetContextPlayer(i);

	q_id = kbUnitQueryCreate("Invoker of Voormis");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Voormis"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));


		
		trUnitChangeInArea(0, i, "Voormis 4", "Voormis 4", 30.0);

		trUnitDelete(false);
	}

	q_id = kbUnitQueryCreate("Ritual of the Voormi");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of the Voormi"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Voormisian", center, center);

		trUnitDelete(false);
	}

	

	
	
	

	q_id = kbUnitQueryCreate("Ritual of the New Moon");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of the New Moon"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Ritual of the New Moon A", center, center);
		trTechInvokeGodPower(0, "Ritual of the New Moon B", center, center);
		
		trUnitDelete(false);
	}


	q_id = kbUnitQueryCreate("Annihilation Ceremony");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Annihilation Ceremony"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "The End Ritual", center, center);
		
		trUnitDelete(false);
	}
	

	q_id = kbUnitQueryCreate("Dark Awakening");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Dark Awakening"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
    for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));


		int q_id3 = kbUnitQueryCreate("Townsfolk");
		kbUnitQuerySetPlayerID(q_id3, i);
		kbUnitQuerySetUnitType(q_id3,kbGetProtoUnitID("Townsfolk"));
		kbUnitQuerySetState(q_id3,2);
		int q_len3 = kbUnitQueryExecute(q_id3);
		
		trPlayerGrantResources(i, "Favor", 2 * q_len3);
		
		trUnitChangeInArea(i, i, "Townsfolk", "Cultist", 20000.0);
		
	}


	q_id = kbUnitQueryCreate("Ritual of Serpents");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of Serpents"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Ritual of Serpents", center, center);
		
		trUnitDelete(false);
	}


	q_id = kbUnitQueryCreate("Ritual of Loyalty");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of Loyalty"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Ritual of Loyalty", center, center);
		
		trUnitDelete(false);
	}





	q_id = kbUnitQueryCreate("Ritual of the Black Flame");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of the Black Flame"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trTechInvokeGodPower(0, "Ritual of the Black Flame", center, center);
		
		trUnitDelete(false);
	}


	q_id = kbUnitQueryCreate("Altar");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Altar"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trUnitChangeInArea(i, i, "Cultist", "Super Appealing Form", 2.0);
		trUnitChangeInArea(i, i, "Sacrificial Lamb", "Super Appealing Form", 2.0);

	}

	
	q_id = kbUnitQueryCreate("Ritual of the Gate");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of the Gate"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(2 == q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));

		vector center1 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,0));
		vector center2 = kbUnitGetPosition(kbUnitQueryGetResult(q_id,1));

		trTechInvokeGodPower(0, "Ritual of the Gate", center1, center2);
		trTechInvokeGodPower(0, "Ritual of the Gate", center2, center1);
		
		trUnitDelete(false);

		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,1));
		trUnitDelete(false);
	}


	q_id = kbUnitQueryCreate("Ritual of The Key");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of The Key"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(1 == q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));


		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);


		q_id2 = kbUnitQueryCreate("Cultist");
		kbUnitQuerySetPlayerID(q_id2, i);
		kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Cultist of Yog-Sothoth"));
		kbUnitQuerySetState(q_id2,2);
		q_len2 = kbUnitQueryExecute(q_id2);

		int foundOne = 0;
        	for(k=0;<q_len2)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id2,k));
			if (trUnitDistanceToUnitID(center_id) <= 8.0)
			{
				if (foundOne == 0) 
				{
					foundOne = 1;
				}
				else 
				{
					foundOne = 0;
					break;
				}
				
			}
		}

		
		if (foundOne == 1) {
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,0));

			trUnitChangeInArea(i, i,"Cultist of Yog-Sothoth","Carterite", 8.0);


			trForbidProtounit(i, "Ritual of The Key");
			trUnitDelete(false);
		}
	}

	q_id = kbUnitQueryCreate("Carterite Dead");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Carterite Dead"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(q_len > 0)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
		trUnforbidProtounit(i, "Ritual of The Key");
		trUnitDelete(false);
	}


	q_id = kbUnitQueryCreate("Ritual of the Blessed Birth");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of the Blessed Birth"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(1 == q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));


		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);


		q_id2 = kbUnitQueryCreate("Cultist");
		kbUnitQuerySetPlayerID(q_id2, i);
		kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Cultist of Shub-Niggurath"));
		kbUnitQuerySetState(q_id2,2);
		q_len2 = kbUnitQueryExecute(q_id2);

		foundOne = 0;
        	for(k=0;<q_len2)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id2,k));
			if (trUnitDistanceToUnitID(center_id) <= 8.0)
			{
				if (foundOne == 0) 
				{
					foundOne = 1;
				}
				else 
				{
					foundOne = 0;
					break;
				}
				
			}
		}

		
		if (foundOne == 1) {
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,0));

			trUnitChangeInArea(i, i,"Cultist of Shub-Niggurath","Blessed One", 8.0);


			trForbidProtounit(i, "Ritual of the Blessed Birth");
			trUnitDelete(false);
		}
	}

	q_id = kbUnitQueryCreate("Blessed One Dead");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Blessed One Dead"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(q_len > 0)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
		trUnforbidProtounit(i, "Ritual of the Blessed Birth");
		trUnitDelete(false);
	}

if(0 == 1) {
	q_id = kbUnitQueryCreate("Temp Maw");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Temp Maw"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(0 < q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));


		trUnitChangeInArea(0, i,"Deep Gate","Deep Gate", 8.0);
		trUnitDelete(false);

		
	}
}

	q_id = kbUnitQueryCreate("Maw of the Deep");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Maw of the Deep"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(0 < q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));


		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		trUnitChangeInArea(i, i,"Cultist","Cthulhi", 8.0);
		trUnitChangeInArea(i, i,"Sacrificial Lamb","Cthulhi", 8.0);

if (0 == 1) {
		trUnitChangeInArea(i, i,"Sacrificial Lamb","Temp Deep", 8.0);
		trUnitChangeInArea(i, i,"Cultist","Temp Deep", 8.0);


		q_id2 = kbUnitQueryCreate("Temp Deep");
		kbUnitQuerySetPlayerID(q_id2, i);
		kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Temp Deep"));
		kbUnitQuerySetState(q_id2,2);
		q_len2 = kbUnitQueryExecute(q_id2);

        	for(k=0;<q_len2)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id2,k));
			
			if (trUnitDistanceToUnitID(center_id) <= 8.0)
			{
				vector center_c = kbUnitGetPosition(kbUnitQueryGetResult(q_id2,k));
				trUnitDelete(false);
				trTechInvokeGodPower(0, "Pulse of the Deep", center_c, center_c);
				
			}
			
		}

		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
		trUnitChangeInArea(i, i,"Maw of the Deep","Temp Maw", 8.0);
}
		
	}


	q_id = kbUnitQueryCreate("Ritual of Wrath Active");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ritual of Wrath Active"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(q_len > 0)
	{
		//trUnitSelectClear();
		//trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
		//trUnitDelete(false);
		
		if (trTechStatusActive(i, 678)) {
		} else {
			trTechSetStatus(i, 679, cTechStatusActive);
			trChatSend(i, "AAARRRGH I BE ANGRY");
			for (j=1; < cNumberPlayers)
    			{
			trTechSetStatus(j, 678, cTechStatusActive);
			trChatSend(j, "AAARRRGH I BE ANGRY");
			}
		}
	} else {
		if (trTechStatusActive(i, 679)) {
			trTechSetStatus(i, 679, cTechStatusUnobtainable);
			trChatSend(i, "I feel much better now, whew");
			for (j=1; < cNumberPlayers)
    			{
			trTechSetStatus(j, 678, cTechStatusUnobtainable);
			trChatSend(j, "I feel much better now, whew");
			}
		}
		
	}

	q_id = kbUnitQueryCreate("Nightmare Beacon");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Nightmare Beacon"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        if(q_len > 0)
	{
		checkNightmare = 1;
		//trUnitSelectClear();
		//trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
		//trUnitDelete(false);
		
		if (trTechStatusActive(i, 696)) {
		} else {
			trTechSetStatus(i, 696, cTechStatusActive);
			trChatSend(i, "I BECKON THE NIGHTMARE");

		}
	} else {
		if (trTechStatusActive(i, 696)) {
			trTechSetStatus(i, 696, cTechStatusUnobtainable);
			trChatSend(i, "I am no longer beckoning the nightmare");

		}
		
	}

	q_id = kbUnitQueryCreate("Weavers Transformation");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Weavers Transformation"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		//rmAddPlayerResource(i, "Gold", 10000);
		
		//int resources = trPlayerResourceCount(i, "Food")+trPlayerResourceCount(i, "Wood")+trPlayerResourceCount(i, "Gold");
		//trPlayerGrantResources(i, "Food", (resources / 3)-trPlayerResourceCount(i, "Food"));
		//trPlayerGrantResources(i, "Wood", (resources / 3)-trPlayerResourceCount(i, "Wood"));
		//trPlayerGrantResources(i, "Gold", (resources / 3)-trPlayerResourceCount(i, "Gold"));

		
		int favor = trPlayerResourceCount(i, "Favor");
		trPlayerGrantResources(i, "Food", favor * 10);
		trPlayerGrantResources(i, "Wood", favor * 10);
		trPlayerGrantResources(i, "Gold", favor * 10);
		trPlayerGrantResources(i, "Favor", 0 - favor);

		trUnitDelete(false);
	}



	// has to be the last one in the list -- diplomacy goes wonky

	q_id = kbUnitQueryCreate("Ephiriams Ritual");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Ephiriams Ritual"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
		center_id = kbUnitQueryGetResult(q_id,j);

		//trUnitDelete(false);
		

		q_id2 = kbUnitQueryCreate("Cultist Of Azathoth");
		kbUnitQuerySetPlayerID(q_id2, i);
		kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Cultist of Azathoth"));
		kbUnitQuerySetState(q_id2,2);
		q_len2 = kbUnitQueryExecute(q_id2);

		int count = 0;
        	for(k=0;<q_len2)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id2,k));
			if (trUnitDistanceToUnitID(center_id) < 5)
			{
				count = count + 1;
				trUnitDelete(false);
			}
			if (count == 1)
			{
				break;
			}
		}

		if (count == 0)
		{
			trUnitSelectByID(center_id);
			//trUnitDelete(false);
			
		}

		
		for(k=0;<count)
		{
			trPlayerSetDiplomacy(0, i, "ally");
			//for (l=1; < cNumberPlayers)
			//{
			//	if (l != i){
			//	if (trPlayerGetDiplomacy(i, l) == "ally")
			//	{
			//		trPlayerSetDiplomacy(0, l, "ally");
			//	}
			//	}
			//}
			trTechInvokeGodPower(0, "Body Swap", center, center);
			//for (l=1; < cNumberPlayers)
			//{
			//	if (l != i){
			//	if (trPlayerGetDiplomacy(i, l) == "ally")
			//	{
			//		trPlayerSetDiplomacy(0, l, "enemy");
			//	}
			//	}
			//}
			
		}
		
	}

    }
    if (checkNightmare == 1 && NightmareActive == 0)
    {
	NightmareActive = 1;
	for (j=1; < cNumberPlayers)
    	{
		trTechSetStatus(j, 695, cTechStatusActive);
		trChatSend(j, "I can't see");
	}

    }

    if (checkNightmare == 0 && NightmareActive == 1)
    {
	NightmareActive = 0;

	for (j=1; < cNumberPlayers)
    	{
		trTechSetStatus(j, 695, cTechStatusUnobtainable);
		trChatSend(j, "I can see");
	}

    }

	}

}

rule SpreadPlague
minInterval 1
maxInterval 1
active
{
    //tempModIndex = tempModIndex + 1;
    //tempModIndex = tempModIndex % plagueMod ;

    for (i=0; < 1)
    {
        
        xsSetContextPlayer(i);

		int q_id = kbUnitQueryCreate("Zombie Marker");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Zombie Marker"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			//if (j % plagueMod == tempModIndex) {
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

				vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
				trTechInvokeGodPower(0, "Infect", center, center);


			//}

		}

    }

}





rule UnwravelerEat
minInterval 1
maxInterval 1
active
{
    for (i=1; < cNumberPlayers)
    {
        
        xsSetContextPlayer(i);
	int q_id = kbUnitQueryCreate("Unwraveler");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Unwraveler"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
		if (trUnitPercentDamaged() < 9) {
			trDamageUnitPercent(9-trUnitPercentDamaged());
		}
	}

	q_id = kbUnitQueryCreate("Yellow One Attack");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Yellow One Attack"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
		trDamageUnitPercent(5);
		
	}

	q_id = kbUnitQueryCreate("Endbringer");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Endbringer"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
		trDamageUnitPercent(3.3);
		
	}

    }
}

rule SacrificeUnits
minInterval 4
maxInterval 4
active
{
    for (i=1; < cNumberPlayers)
    {
        
        xsSetContextPlayer(i);
		int q_id = kbUnitQueryCreate("Town Hall Readylkjlkjlk");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Town Hall Readylkjlkjlkjl"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			//if (trUnitGetContained() > 0) {
			//	trPlayerGrantResources(i, "Favor", (trUnitGetContained() * 7.5));
			//	trUnitDelete(false);
			//}


			if (trUnitGetIsContained("Town Hall")) {
				trUnitChangeProtoUnit("Heavenlight");
				trPlayerGrantResources(i, "Favor", 5.0);
			}

		}
    }
}

rule DemeterFarms
minInterval 1
maxInterval 1
active
{

    for (i=1; < cNumberPlayers)
    {
        
        xsSetContextPlayer(i);



	if(kbGetTechStatus(1236) == cTechStatusActive)
	{


		
		int q_id = kbUnitQueryCreate("Settlement Level 1");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Settlement Level 1"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));


			trUnitChangeInArea(0, i, "Farm", "Farm", 17.5);
			trTechInvokeGodPower(0, "FarmGP", center, center);

		}
	}

	}

}



rule ConvertSouls
minInterval 1
maxInterval 1
active
{

    for (i=1; < cNumberPlayers)
    {
        
        xsSetContextPlayer(i);


	if(kbGetTechStatus(775) == cTechStatusActive)
	{
		if(trPlayerResourceCount(i, "Favor")>100) {
			trPlayerGrantResources(i, "Favor", 100-trPlayerResourceCount(i, "Favor"));
		}
	}

	

	if(kbGetTechStatus(1463) == cTechStatusActive)
	{
		if(trPlayerResourceCount(i, "Favor")>150) {
			trPlayerGrantResources(i, "Favor", 150-trPlayerResourceCount(i, "Favor"));
		}
	} else if(kbGetTechStatus(984) == cTechStatusActive)
	{
		if(trPlayerResourceCount(i, "Favor")>100) {
			trPlayerGrantResources(i, "Favor", 100-trPlayerResourceCount(i, "Favor"));
		}
	}

	if(kbGetTechStatus(1236) == cTechStatusActive)
	{
		if(trPlayerResourceCount(i, "Favor")>100) {
			trPlayerGrantResources(i, "Favor", 100-trPlayerResourceCount(i, "Favor"));
		}
		
	}


	int q_id = kbUnitQueryCreate("Soul Rune");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Soul Rune"));
	kbUnitQuerySetState(q_id,2);
	int q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		trUnitChangeInArea(0, i, "Soul Light Wild", "Soul Light Tame", 7.5);
	}

	q_id = kbUnitQueryCreate("Soul Release");
	kbUnitQuerySetPlayerID(q_id, i);
	kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Soul Release"));
	kbUnitQuerySetState(q_id,2);
	q_len = kbUnitQueryExecute(q_id);
        for(j=0;<q_len)
	{
		trUnitSelectClear();
		trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

		trUnitChangeInArea(i, i, "Soul Light Tame", "Soul Light Dead", 7.5);
		trUnitDelete(false);
	}






    }

}


rule Fushimi
minInterval 300
maxInterval 300
active
{


    //Iterate over the players, we start at 1 as gaia should
    // not be checked (she's always popcapped anyways)
    for (i=1; < cNumberPlayers)
    {
        xsSetContextPlayer(i);
		
		if(kbGetTechStatus(1033) == cTechStatusActive)
		{


			int q_id = kbUnitQueryCreate("Villager Japanese fush");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Villager Japanese"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);

			int q_id2 = kbUnitQueryCreate("Villager Japanese Skilled fush");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Villager Japanese Skilled"));
			kbUnitQuerySetState(q_id2,2);
			int q_len2 = kbUnitQueryExecute(q_id2);


			if(kbGetTechStatus(1031) == cTechStatusActive) {
				trPlayerGrantResources(i, "Food", trPlayerResourceCount(i, "Food") * (q_len * 4 + q_len2 * 10 ) / 1000);
				trPlayerGrantResources(i, "Wood", trPlayerResourceCount(i, "Wood") * (q_len * 4 + q_len2 * 10) / 1000);
				trPlayerGrantResources(i, "Gold", trPlayerResourceCount(i, "Gold") * (q_len * 4 + q_len2 * 10) / 1000);
				trPlayerGrantResources(i, "Favor", trPlayerResourceCount(i, "Favor") * (q_len * 4 + q_len2 * 10 ) / 1000);
			} else {
				trPlayerGrantResources(i, "Food", trPlayerResourceCount(i, "Food") * (q_len * 2 + q_len2 * 5 ) / 1000);
				trPlayerGrantResources(i, "Wood", trPlayerResourceCount(i, "Wood") * (q_len * 2 + q_len2 * 5 ) / 1000);
				trPlayerGrantResources(i, "Gold", trPlayerResourceCount(i, "Gold") * (q_len * 2 + q_len2 * 5 ) / 1000);
				trPlayerGrantResources(i, "Favor", trPlayerResourceCount(i, "Favor") * (q_len * 2 + q_len2 * 5 ) / 1000);
			}
			

		}
	}
}



rule AmaterasuRefresh
minInterval 10
maxInterval 10
active
{

    //Iterate over the players, we start at 1 as gaia should
    // not be checked (she's always popcapped anyways)
    for (i=1; < cNumberPlayers) {
        xsSetContextPlayer(i);
		if(kbGetTechStatus(775) == cTechStatusActive) {
			int q_id = kbUnitQueryCreate("Amaterasu Refresh");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Amaterasu Refresh"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len) {
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

				trUnitDelete(false);
			}

			if (q_len > 0) {
				kbUnitQueryCreate("Emperor Japanese 1");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 1"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 2");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 2"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 3");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 3"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 4");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 4"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 5");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 5"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 6");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 6"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 7");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 7"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(true);
				}
				kbUnitQueryCreate("Emperor Japanese 1 Dead");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 1 Dead"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}
				kbUnitQueryCreate("Emperor Japanese 2 Dead");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 2 Dead"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}
				kbUnitQueryCreate("Emperor Japanese 3 Dead");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 3 Dead"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}
				kbUnitQueryCreate("Emperor Japanese 4 Dead");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 4 Dead"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}
				kbUnitQueryCreate("Emperor Japanese 5 Dead");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 5 Dead"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}
				kbUnitQueryCreate("Emperor Japanese 6 Dead");
				kbUnitQuerySetPlayerID(q_id, i);
				kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Emperor Japanese 6 Dead"));
				kbUnitQuerySetState(q_id,2);
				kbUnitQueryExecute(q_id);
				for(j=0;<q_len) {
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}
			}
		}
	}
}

rule VenusTempleHeal
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);

		

			int Qid = kbUnitQueryCreate("Temple Venus");
			kbUnitQuerySetPlayerID(Qid, pid);
			kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Temple Venus"));
			kbUnitQuerySetState(Qid,2);
		
			int num = kbUnitQueryExecute(Qid);
			for(i=0;<num)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(Qid,i));
				//trDamageUnitsInArea(pid,"AbstractVillager",30,-1.0);

				for(pid2=1;<cNumberPlayers)
				{		
					if (kbIsPlayerAlly(pid2)) {
						trDamageUnitsInArea(pid2,"AbstractVillager",30,-1.0);
					}
				}
			}
		
	}
	xsSetContextPlayer(prevPlayer);
}

rule PersephoneGP
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);

		if (kbGetTechStatus(1267) == cTechStatusActive) {
			int Qid = kbUnitQueryCreate("Farm");
			kbUnitQuerySetPlayerID(Qid, pid);
			kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Farm"));
			kbUnitQuerySetState(Qid,2);
		
			int num = kbUnitQueryExecute(Qid);
			for(i=0;<num)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(Qid,i));

				for(pid2=1;<cNumberPlayers)
				{		
					if (kbIsPlayerAlly(pid2)) {
						trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",10,-15.0);
						trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",15,-10.0);
					}
				}
			}
		}
	}
	xsSetContextPlayer(prevPlayer);
}

rule HomelandFortification
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);

		if (kbGetTechStatus(1271) == cTechStatusActive) {
			int Qid = kbUnitQueryCreate("Settlement Level 1");
			kbUnitQuerySetPlayerID(Qid, pid);
			kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Settlement Level 1"));
			kbUnitQuerySetState(Qid,2);
		
			int num = kbUnitQueryExecute(Qid);
			for(i=0;<num)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(Qid,i));

				for(pid2=1;<cNumberPlayers)
				{		
					if (kbIsPlayerAlly(pid2)) {
						trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",15,-5.0);
						trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",10,-5.0);
						trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",7,-10.0);
					}
				}
			}
		}
	}
	xsSetContextPlayer(prevPlayer);
}

rule MercuryTempleHeal
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);
		int Qid = kbUnitQueryCreate("Temple Mercury");
		kbUnitQuerySetPlayerID(Qid, pid);
		kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Temple Mercury"));
		kbUnitQuerySetState(Qid,2);
		
		int num = kbUnitQueryExecute(Qid);
		for(i=0;<num)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(Qid,i));
			//trDamageUnitsInArea(pid,"AbstractTradeUnit",40,-5.0);
			for(pid2=1;<cNumberPlayers)
			{		
				if (kbIsPlayerAlly(pid2)) {
					trDamageUnitsInArea(pid2,"AbstractTradeUnit",40,-5.0);
				}
			}
		}
	}
	xsSetContextPlayer(prevPlayer);
}


rule CeresTempleFood
active
minInterval 5
maxInterval 5
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);
		int Qid = kbUnitQueryCreate("Temple Ceres");
		kbUnitQuerySetPlayerID(Qid, pid);
		kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Temple Ceres"));
		kbUnitQuerySetState(Qid,2);
		
		int num = kbUnitQueryExecute(Qid);
		for(i=0;<num)
		{
			int foodCeres = 0;
			//trUnitSelectClear();
			//trUnitSelectByID(kbUnitQueryGetResult(Qid,i));
			//trDamageUnitsInArea(pid,"AbstractTradeUnit",40,-5.0);

			int Qid2 = kbUnitQueryCreate("Farm");
			kbUnitQuerySetPlayerID(Qid2, pid);
			kbUnitQuerySetUnitType(Qid2,kbGetProtoUnitID("Farm"));
			kbUnitQuerySetState(Qid2,2);
		
			int num2 = kbUnitQueryExecute(Qid2);
			for(i2=0;<num2)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(Qid2,i2));
				if (trUnitDistanceToUnitID(kbUnitQueryGetResult(Qid,i)) <= 18.0)
				{
					foodCeres = foodCeres + 1;
				}
				if (trUnitDistanceToUnitID(kbUnitQueryGetResult(Qid,i)) <= 10.0)
				{
					foodCeres = foodCeres + 1;
				}
				if (trUnitDistanceToUnitID(kbUnitQueryGetResult(Qid,i)) <= 5.0)
				{
					foodCeres = foodCeres + 1;
				}
			}
			trPlayerGrantResources(pid, "Food", foodCeres);
		}
	}
	xsSetContextPlayer(prevPlayer);
}

rule MarsTemple
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);
		int Qid = kbUnitQueryCreate("Temple Mars");
		kbUnitQuerySetPlayerID(Qid, pid);
		kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Temple Mars"));
		kbUnitQuerySetState(Qid,2);
		
		int num = kbUnitQueryExecute(Qid);
		for(i=0;<num)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(Qid,i));
			//trDamageUnitsInArea(pid,"HumanSoldier",15,-1.0);

			for(pid2=1;<cNumberPlayers)
			{		
				if (kbIsPlayerEnemy(pid2)) {
					trDamageUnitsInArea(pid2,"HumanSoldier",20,2.0);
				} else if (kbIsPlayerAlly(pid2)) {
					trDamageUnitsInArea(pid2,"HumanSoldier",15,-1.0);
				}
			}
		}
	}
	xsSetContextPlayer(prevPlayer);
}

rule AtenPharaoh
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(pid=0;<cNumberPlayers)
	{
		xsSetContextPlayer(pid);

		if (kbGetTechStatus(1273) == cTechStatusActive) {

			int Qid = kbUnitQueryCreate("Pharaoh");
			kbUnitQuerySetPlayerID(Qid, pid);
			kbUnitQuerySetUnitType(Qid,kbGetProtoUnitID("Pharaoh"));
			kbUnitQuerySetState(Qid,2);

			int age = kbGetAgeForPlayer(pid);

			float factor = 1.0;

			if (kbGetTechStatus(1312) == cTechStatusActive) {
				factor = 1.5;
			}
		
			int num = kbUnitQueryExecute(Qid);
			for(i=0;<num)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(Qid,i));

				for(pid2=1;<cNumberPlayers)
				{		
					if (kbIsPlayerEnemy(pid2)) {
						trDamageUnitsInArea(pid2,"All",7, (1.0 + age) * factor / 1.5);
						trDamageUnitsInArea(pid2,"Military",7, (1.0 * age) * factor / 1.5);
					} else if (kbIsPlayerAlly(pid2)) {
						trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",10,(-1.0 - 2.0 * age) * factor / 1.5);
					}
				}
			}

		}
	}
	xsSetContextPlayer(prevPlayer);
}


rule RomeMUs
minInterval 1
maxInterval 1
active
{


	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);

		if (kbGetTechStatus(1134) == cTechStatusActive) {

			int civChosen = -1;

			int q_id = kbUnitQueryCreate("Roman Eagle");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Roman Eagle"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);
			for(j=0;<q_len) {
				xsSetContextPlayer(i);
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
				vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));
				int center_id = kbUnitQueryGetResult(q_id,j);

				trUnitSelectClear();

				for (k=1; <cNumberPlayers) {
					xsSetContextPlayer(k);
					int q_id3 = kbUnitQueryCreate("Town Center");
				
					kbUnitQuerySetPlayerID(q_id3, k);
					kbUnitQuerySetUnitType(q_id3,kbGetProtoUnitID("Settlement Level 1"));
					kbUnitQuerySetState(q_id3,2);

					//kbUnitQuerySetPosition(q_id3, center);
					//kbUnitQuerySetMaximumDistance(q_id3, 10.0);
					int q_len3 = kbUnitQueryExecute(q_id3); 

					for(j3=0;<q_len3) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id3,j3));
						if (trUnitDistanceToUnitID(center_id) < 5) {
							//trChatSend(k, "Found a TC!");
							civChosen = k;
							break;
						}
					}
					if (civChosen != -1) {
						break;
					}
				}

				for (k=1; <cNumberPlayers) {
					xsSetContextPlayer(k);
					q_id3 = kbUnitQueryCreate("Town Center");
				
					kbUnitQuerySetPlayerID(q_id3, k);
					kbUnitQuerySetUnitType(q_id3,kbGetProtoUnitID("Citadel Center"));
					kbUnitQuerySetState(q_id3,2);

					//kbUnitQuerySetPosition(q_id3, center);
					//kbUnitQuerySetMaximumDistance(q_id3, 10.0);
					q_len3 = kbUnitQueryExecute(q_id3); 

					for(j3=0;<q_len3) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id3,j3));
						if (trUnitDistanceToUnitID(center_id) < 5) {
							//trChatSend(k, "Found a Citadel!");
							civChosen = k;
							break;
						}
					}
					if (civChosen != -1) {
						break;
					}
				}

				for (k=1; <cNumberPlayers) {
					xsSetContextPlayer(k);
					q_id3 = kbUnitQueryCreate("Town Center");
				
					kbUnitQuerySetPlayerID(q_id3, k);
					kbUnitQuerySetUnitType(q_id3,kbGetProtoUnitID("Settlement Level 1"));
					kbUnitQuerySetState(q_id3,2);

					//kbUnitQuerySetPosition(q_id3, center);
					//kbUnitQuerySetMaximumDistance(q_id3, 10.0);
					q_len3 = kbUnitQueryExecute(q_id3); 

					for(j3=0;<q_len3) {
						trUnitSelectClear();
						trUnitSelectByID(kbUnitQueryGetResult(q_id3,j3));
						if (trUnitDistanceToUnitID(center_id) < 5) {
							//trChatSend(k, "Found a TC!");
							civChosen = k;
							break;
						}
					}
					if (civChosen != -1) {
						break;
					}
				}
			}



			if (civChosen != -1) {
			xsSetContextPlayer(civChosen);

			if (kbGetTechStatus(863) == cTechStatusActive) { // poseidon
				civChosen = 3;
			} else if (kbGetTechStatus(862) == cTechStatusActive) { // hades
				civChosen = 2;
			} else if (kbGetTechStatus(861) == cTechStatusActive) { // zeus
				civChosen = 1;
			} else if (kbGetTechStatus(651) == cTechStatusActive) { // azathoth
				civChosen = 16;
			} else if (kbGetTechStatus(653) == cTechStatusActive) { // shub-niggurath
				civChosen = 18;
			} else if (kbGetTechStatus(652) == cTechStatusActive) { // yog-sothoth
				civChosen = 17;
			} else if (kbGetTechStatus(959) == cTechStatusActive) { // ra
				civChosen = 4;
			} else if (kbGetTechStatus(960) == cTechStatusActive) { // isis
				civChosen = 5;
			} else if (kbGetTechStatus(961) == cTechStatusActive) { // set
				civChosen = 6;
			} else if (kbGetTechStatus(963) == cTechStatusActive) { // thor
				civChosen = 7;
			} else if (kbGetTechStatus(962) == cTechStatusActive) { // odin
				civChosen = 8;
			} else if (kbGetTechStatus(964) == cTechStatusActive) { // loki
				civChosen = 9;
			} else if (kbGetTechStatus(965) == cTechStatusActive) { // kronos
				civChosen = 10;
			} else if (kbGetTechStatus(967) == cTechStatusActive) { // oranos
				civChosen = 11;
			} else if (kbGetTechStatus(966) == cTechStatusActive) { // gaia
				civChosen = 12;
			} else if (kbGetTechStatus(877) == cTechStatusActive) { // fu xi
				civChosen = 13;
			} else if (kbGetTechStatus(878) == cTechStatusActive) { // nu wa
				civChosen = 14;
			} else if (kbGetTechStatus(879) == cTechStatusActive) { // shennong
				civChosen = 15;
			} else if (kbGetTechStatus(871) == cTechStatusActive) { // tezcatlipoca
				civChosen = 19;
			} else if (kbGetTechStatus(872) == cTechStatusActive) { // quetzalcoatl
				civChosen = 20;
			} else if (kbGetTechStatus(873) == cTechStatusActive) { // huitzilopochtli
				civChosen = 21;
			} else if (kbGetTechStatus(1131) == cTechStatusActive) { // jupiter
				civChosen = 0;
			} else if (kbGetTechStatus(1132) == cTechStatusActive) { // juno
				civChosen = 0;
			} else if (kbGetTechStatus(1133) == cTechStatusActive) { // minerva
				civChosen = 0;
			} else if (kbGetTechStatus(1236) == cTechStatusActive) { // demeter
				civChosen = 22;
			} else if (kbGetTechStatus(1273) == cTechStatusActive) { // aten
				civChosen = 23;
			} else if (kbGetTechStatus(1326) == cTechStatusActive) { // freyr
				civChosen = 24;
			} else if (kbGetTechStatus(1358) == cTechStatusActive) { // iapetus
				civChosen = 25;
			} else if (kbGetTechStatus(1385) == cTechStatusActive) { // nameless mist
				civChosen = 26;
			} else if (kbGetTechStatus(978) == cTechStatusActive) { // wi
				civChosen = 27;
			} else if (kbGetTechStatus(979) == cTechStatusActive) { // unci makha
				civChosen = 28;
			} else if (kbGetTechStatus(980) == cTechStatusActive) { // hihan kaga
				civChosen = 29;
			}

			
			
			}



			xsSetContextPlayer(i);
			int q_id2 = kbUnitQueryCreate("Rome MU Placeholder 1");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Rome MU Placeholder 1"));
			kbUnitQuerySetState(q_id2,2);
			int q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));


				switch( civChosen ) {
				case 1: { if (j2 < 2) {													// Zeus
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Minotaur", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 2: { if (j2 < 2) {													// Hades
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Cyclops", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 3: { if (j2 < 2) {													// Poseidon
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Centaur", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 4: { if (j2 < 2) {													// Ra
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Wadjet", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Wadjet", 0.01);
				} }
				case 5: { if (j2 < 2) {													// Isis
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Sphinx", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 6: { if (j2 < 2) {													// Set
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Anubite", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Anubite", 0.01);
				} }
				case 7: { if (j2 < 2) {													// Thor
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Valkyrie", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 8: { if (j2 < 2) {													// Odin
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Einheriar", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 9: { if (j2 < 2) {													// Loki
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Troll", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Troll", 0.01);
				} }
				case 10: { if (j2 < 2) {													// Kronos
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Promethean", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Promethean", 0.01);
				} }
				case 11: { if (j2 < 2) {													// Oranos
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Caladria", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 12: { if (j2 < 2) {													// Gaia
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Automaton", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Automaton", 0.01);
				} }
				case 13: { if (j2 < 2) {													// Fu Xi
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Terracotta Soldier", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Terracotta Soldier", 0.01);
				} }
				case 14: { if (j2 < 2) {													// Nu Wa
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Qulin", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 15: { if (j2 < 2) {													// Shennong
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Monkey King", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 16: { if (j2 < 2) {													// Azathoth
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Formless Spawn", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Formless Spawn", 0.01);
				} }
				case 17: { if (j2 < 2) {													// Yog-Sothoth
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Spider of Leng", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 18: { if (j2 < 2) {													// Shub-Niggurath
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Unwraveler", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 19: { if (j2 < 2) {													// Tezcatlipoca
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Amoxoaque", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 20: { if (j2 < 2) {													// Quetzalcoatl
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Ahuizotl", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 21: { if (j2 < 2) {													// Huitzilopochtli
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Roc Capture", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 22: { if (j2 < 2) {													// Demeter
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Caucasian Eagle", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 23: { if (j2 < 2) {													// Aten
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Scavenger Roc", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Giant Scorpion", 0.01);
				} }
				case 24: { if (j2 < 2) {													// Freyr
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Trollkarien", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Trollkarien", 0.01);
				} }
				case 25: { if (j2 < 2) {													// Iapetus
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Aster", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Aster", 0.01);
				} }
				case 26: { if (j2 < 2) {													// Nameless Mist
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Wendigo", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Wendigo", 0.01);
				} }
				case 27: { if (j2 < 2) {													// Wi
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Zuzeca Zuya", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				case 28: { if (j2 < 2) {													// Unci Mahka
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Waawayanka", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Waawayanka", 0.01);
				} }
				case 29: { if (j2 < 2) {													// Hihan Kaga
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Tathanka Gnaskiyan", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} }
				default: { if (j2 < 1) {												// Roman/else
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Manes", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 1", "Arrow", 0.01);
				} } }


				
			}


			q_id2 = kbUnitQueryCreate("Rome MU Placeholder 2");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Rome MU Placeholder 2"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				switch( civChosen ) {
				case 1: { if (j2 < 2) {													// Zeus
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Hydra", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 2: { if (j2 < 2) {													// Hades
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Manticore", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 3: { if (j2 < 2) {													// Poseidon
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Nemean Lion", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 4: { if (j2 < 2) {													// Ra
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Petsuchos", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 5: { if (j2 < 2) {													// Isis
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Scorpion Man", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 6: { if (j2 < 2) {													// Set
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Scarab", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 7: { if (j2 < 2) {													// Thor
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Frost Giant", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 8: { if (j2 < 2) {													// Odin
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Mountain Giant", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 9: { if (j2 < 2) {													// Loki
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Battle Boar", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 10: { if (j2 < 2) {													// Kronos
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Satyr", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Satyr", 0.01);
				} }
				case 11: { if (j2 < 2) {													// Oranos
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Stymphalian Bird", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 12: { if (j2 < 2) {													// Gaia
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Behemoth", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 13: { if (j2 < 2) {													// Fu Xi
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Pixiu", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Pixiu", 0.01);
				} }
				case 14: { if (j2 < 2) {													// Nu Wa
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "War Salamander", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 15: { if (j2 < 2) {													// Shennong
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Jaingshi", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Jaingshi", 0.01);
				} }
				case 16: { if (j2 < 2) {													// Azathoth
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Serpent of Yig", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Serpent of Yig", 0.01);
				} }
				case 17: { if (j2 < 2) {													// Yog-Sothoth
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Dimensional Shambler", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 18: { if (j2 < 2) {													// Shub-Niggurath
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Deep One", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Deep One", 0.01);
				} }
				case 19: { if (j2 < 1) {													// Tezcatlipoca
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Plumed Serpent", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Quinametzin", 0.01);
				} }
				case 20: { if (j2 < 2) {													// Quetzalcoatl
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Camazotz", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 21: { if (j2 < 2) {													// Huitzilopochtli
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Cloud Giant", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 22: { if (j2 < 2) {													// Demeter
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Harpy MU", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 23: { if (j2 < 2) {													// Aten
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "ReApep", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 24: { if (j2 < 2) {													// Freyr
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Draugr", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 25: { if (j2 < 2) {													// Iapetus
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Erymanthian Boar", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 26: { if (j2 < 2) {													// Nameless Mist
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Ghoul", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 27: { if (j2 < 2) {													// Wi
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Canotila", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 28: { if (j2 < 2) {													// Unci Makha
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Deer Woman", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				case 29: { if (j2 < 2) {													// Hihan Kaga
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Thunderbird", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} }
				default: { if (j2 < 2) {												// Roman/else
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Manes", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 2", "Arrow", 0.01);
				} } }
			}

			q_id2 = kbUnitQueryCreate("Rome MU Placeholder 3");
			kbUnitQuerySetPlayerID(q_id2, i);
			kbUnitQuerySetUnitType(q_id2,kbGetProtoUnitID("Rome MU Placeholder 3"));
			kbUnitQuerySetState(q_id2,2);
			q_len2 = kbUnitQueryExecute(q_id2);
			for(j2=0;<q_len2) {
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id2,j2));
				switch( civChosen ) {
				case 1: { if (j2 < 2) {													// Zeus
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Medusa", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 2: { if (j2 < 2) {													// Hades
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Colossus", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 3: { if (j2 < 2) {													// Poseidon
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Chimera", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 4: { if (j2 < 2) {													// Ra
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Avenger", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Avenger", 0.01);
				} }
				case 5: { if (j2 < 2) {													// Isis
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Mummy", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 6: { if (j2 < 2) {													// Set
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Phoenix", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Phoenix", 0.01);
				} }
				case 7: { if (j2 < 2) {													// Thor
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Fire Giant", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 8: { if (j2 < 2) {													// Odin
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Fenris Wolf", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Fenris Wolf", 0.01);
				} }
				case 9: { if (j2 < 1) {													// Loki
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Fire Giant", 0.01);
				} else if (j2 < 2) {													
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Mountain Giant", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Frost Giant", 0.01);
				} }
				case 10: { if (j2 < 2) {													// Kronos
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Argus", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Argus", 0.01);
				} }
				case 11: { if (j2 < 2) {													// Oranos
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Heka Gigantes", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 12: { if (j2 < 2) {													// Gaia
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Lampades", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Lampades", 0.01);
				} }
				case 13: { if (j2 < 2) {													// Fu Xi
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Azure Dragon", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 14: { if (j2 < 2) {													// Nu Wa
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Vermilion Bird", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 15: { if (j2 < 2) {													// Shennong
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "White Tiger", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 16: { if (j2 < 2) {													// Azathoth
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Faceless One", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 17: { if (j2 < 2) {													// Yog-Sothoth
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Yellow One", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 18: { if (j2 < 2) {													// Shub-Niggurath
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Shoggoth", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 19: { if (j2 < 2) {													// Tezcatlipoca
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Cihuateteo", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 20: { if (j2 < 2) {													// Quetzalcoatl
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Dark Lady Fly", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 21: { if (j2 < 2) {													// Huitzilopochtli
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Xochitonal", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 22: { if (j2 < 2) {													// Demeter
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Gryphon", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 23: { if (j2 < 2) {													// Aten
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Sand Monster", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 24: { if (j2 < 2) {													// Freyr
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Heidrun", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 25: { if (j2 < 2) {													// Iapetus
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Orthus", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Orthus", 0.01);
				} }
				case 26: { if (j2 < 2) {													// Nameless Mist
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Hound of Tindalos", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Hound of Tindalos", 0.01);
				} }
				case 27: { if (j2 < 2) {													// Wi
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Wi Can", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 28: { if (j2 < 2) {													// Unci Makha
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Unktehi Winyela", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				case 29: { if (j2 < 2) {													// Hihan Kaga
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Woniya Thanka", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Arrow", 0.01);
				} }
				default: { if (j2 < 2) {												// Roman/else
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Manes", 0.01);
				} else {
					trUnitChangeInArea(i, i, "Rome MU Placeholder 3", "Manes", 0.01);
				} } }
			}

		}

	}

}


rule summonBison
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(i=0;<cNumberPlayers)
	{
		xsSetContextPlayer(i);

		

		int q_id = kbUnitQueryCreate("Invoker of Bison Small");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Bison Small"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));

			trTechInvokeGodPower(0, "Bison Generate Small", center, center);
		
			trUnitDelete(false);
		}

		q_id = kbUnitQueryCreate("Invoker of Bison Medium");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Bison Medium"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));

			trTechInvokeGodPower(0, "Bison Generate Medium", center, center);
		
			trUnitDelete(false);
		}

		q_id = kbUnitQueryCreate("Invoker of Bison Large");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Bison Large"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));

			trTechInvokeGodPower(0, "Bison Generate Large", center, center);
		
			trUnitDelete(false);
		}

		q_id = kbUnitQueryCreate("Invoker of Bison Convert");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Bison Convert"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));

			
			trUnitChangeInArea(0, i, "Bison", "Bison Owned", 50);
			trUnitChangeInArea(0, i, "Gold Bison", "Gold Bison", 50);
		
			trUnitDelete(false);
		}

		q_id = kbUnitQueryCreate("Invoker of Gold Bison");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of Gold Bison"));
		kbUnitQuerySetState(q_id,2);
		q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));

			trTechInvokeGodPower(0, "Bison Generate Gold", center, center);
		
			trUnitDelete(false);
		}

	}

}


rule WiTree
active
minInterval 60
maxInterval 60
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(i=0;<cNumberPlayers)
	{
		xsSetContextPlayer(i);

		

		int q_id = kbUnitQueryCreate("Wagacan Tree");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Wagacan Tree"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,j));


			trTechInvokeGodPower(0, "Tree Spawn", center, center);

		}


	}

}
		

rule OwlSoldier
active
minInterval 2
maxInterval 2
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(i=1;<cNumberPlayers)
	{
		xsSetContextPlayer(i);

		

		int q_id = kbUnitQueryCreate("Lakota Temple");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Lakota Temple"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			
			trUnitChangeInArea(i, i, "Owl Soldier", "Owl Soldier Owl Temp", 5.0);
			trUnitChangeInArea(i, i, "Owl Soldier 2", "Owl Soldier Owl Temp", 5.0);

		}


	}

}


rule CrazyBull
active
minInterval 1
maxInterval 1
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(i=1;<cNumberPlayers)
	{
		xsSetContextPlayer(i);

		

		int q_id = kbUnitQueryCreate("Tathanka Gnaskiyan Insane");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Tathanka Gnaskiyan Insane"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		if(0<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
			vector center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,0));

			
			trTechInvokeGodPower(0, "Crazy Bull Chaos", center, center);

		} else {
		
			q_id = kbUnitQueryCreate("Zombie");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Zombie"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);
			if(0<q_len)
			{
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,0));
				center = kbUnitGetPosition(kbUnitQueryGetResult(q_id,0));

				trChatSend(0, "zombie!");

			
				trTechInvokeGodPower(0, "Crazy Bull Chaos", center, center);

			} 
		
		}


	}

}
	
	
	
rule IRS
active
minInterval 5
maxInterval 5
priority 100
{
	int prevPlayer = xsGetContextPlayer();
	for(i=1;<cNumberPlayers)
	{
		xsSetContextPlayer(i);

		

		int q_id = kbUnitQueryCreate("Invoker of IRS");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Invoker of IRS"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));
			trUnitDelete(false);
			
			int enemy_num = 0;

			for(k=1;<cNumberPlayers)
			{
				if (kbIsPlayerEnemy(k)) {
					enemy_num = enemy_num + 1;
				}
			}


			float tax_percent = 0.5 / enemy_num;

			for(k=1;<cNumberPlayers)
			{
				if (kbIsPlayerEnemy(k)) {

					float gold_owed = trPlayerResourceCount(k, "Gold") * tax_percent;
					

					int gold_real = (1*gold_owed+1);


					trPlayerGrantResources(i, "Gold",  gold_real);

					trPlayerGrantResources(k, "Gold", -1* gold_real);
					trChatSend(k, "I pay " + gold_real +" gold!");

				}
			}

		}


	}

}
	


rule WopheFire
active
minInterval 1
maxInterval 1
priority 100
{
	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);
		int q_id = kbUnitQueryCreate("Wophe Fire");
		kbUnitQuerySetPlayerID(q_id, i);
		kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Wophe Fire"));
		kbUnitQuerySetState(q_id,2);
		int q_len = kbUnitQueryExecute(q_id);
		for(j=0;<q_len)
		{
			trUnitSelectClear();
			trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

			for(pid2=1;<cNumberPlayers)
			{		
				if (kbIsPlayerAlly(pid2)) {
					trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",10,-5.0);
					trDamageUnitsInArea(pid2,"LogicalTypeCanBeHealed",15,-5.0);
				}
			}
		}

		
	}

}

rule HihanResurrect
active
minInterval 5
maxInterval 5
priority 100
{
	for (i=1; < cNumberPlayers)
    {
		xsSetContextPlayer(i);

		if (kbGetTechStatus(1482) == cTechStatusActive) {

			int q_id = kbUnitQueryCreate("Akicita Dead");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Akicita Dead"));
			kbUnitQuerySetState(q_id,2);
			int q_len = kbUnitQueryExecute(q_id);

			trChatSend(0, "num: " + q_len);

			if (q_len >= 13) {

				
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,q_len-1));
				trUnitChangeInArea(i, i, "Akicita Dead", "Owl Soldier 2", 0.1);

				for(j=0;<12)
				{
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}

				
			}

		}
		if (kbGetTechStatus(1484) == cTechStatusActive) {

			q_id = kbUnitQueryCreate("Medicine Woman Dead");
			kbUnitQuerySetPlayerID(q_id, i);
			kbUnitQuerySetUnitType(q_id,kbGetProtoUnitID("Medicine Woman Dead"));
			kbUnitQuerySetState(q_id,2);
			q_len = kbUnitQueryExecute(q_id);

			trChatSend(0, "num: " + q_len);

			if (q_len >= 5) {

				
				trUnitSelectClear();
				trUnitSelectByID(kbUnitQueryGetResult(q_id,q_len-1));
				trUnitChangeInArea(i, i, "Medicine Woman Dead", "Owl Soldier 2", 0.1);

				for(j=0;<4)
				{
					trUnitSelectClear();
					trUnitSelectByID(kbUnitQueryGetResult(q_id,j));

					trUnitDelete(false);
				}

				
			}

		}
	}
}
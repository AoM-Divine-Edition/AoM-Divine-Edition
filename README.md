### Age of Mythology: Divine Edition

This is the largest and most ambitious mod for Age of Mythology in the history of the game, and will one day add a total of 45 new major gods to the game. Currently, the added civilizations are:

- The Eldritch
  - Azathoth
  - Yog-Sothoth
  - Shub-Niggurath
  - The Nameless Mist <-- Temporarily replacing Erebus
- The Aztecs (First Cosmology)
  - Tezcatlipoca
  - Quetzalcoatl
  - Huitzilopochtli
- The Romans 
  - Jupiter
  - Juno
  - Minerva
- The Lakota
  - Wi
  - Unci Mahka
  - Hihan Kaga
- Extended Pantheons
  - Demeter (Greek) <-- Temporarily replacing Khaos
  - Aten (Egyptian) <-- Temporarily replacing Chronos
  - Freyr (Norse) <-- Temporarily replacing Ananke
  - Iapetus (Atlantean) <-- Temporarily replacing Nyx
- Chinese 2.0
  - Fu Xi <-- Available under Enlil
  - Nu Wa <-- Available under Inanna
  - Shennong <-- Available under Marduk
  

As the mod is very large, hosting it on Steam Workshop is not practical. As such, users of this mod will need to keep it up-to-date by either pulling changes using git or re-downloading it after every patch. For patch notifications and general discussions, join our discord! https://discord.gg/ZuZKfWzV2Z

### Instructions

1. Download the mod folder (if you're not Git-savvy, click the green button that says "<> CODE" and then click on "Download ZIP") and place it in the /mods/ folder in your Age of Mythology files.
	1. In order for multiplayer to work properly, make sure the folder is named "AoM-Divine-Edition".
2. Subscribe to the following mods on Steam Workshop, and make sure that they are of lower priority than Divine Edition. If, when you start a game, all your units die instantly, that means Divine Edition was not top priority. BE AWARE: Steam can and will tell you to subscribe to other mods when you subscribe to those file packs. You do not have to and probably should not. 
      1. AOM Alpha-Beta Content by AL: https://steamcommunity.com/sharedfiles/filedetails/?id=2070833856
      2. UMC Ancient Unit Pack: https://steamcommunity.com/sharedfiles/filedetails/?id=851936808
	3. Age of Wrath - Files 1: https://steamcommunity.com/sharedfiles/filedetails/?id=2862754011
	4. Age of Wrath - Files 2: https://steamcommunity.com/sharedfiles/filedetails/?id=2862754194
3. Exclude the /injector/ folder in Divine Edition from your antivirus. This is because the injector executable, as it directly edits another program (that being Age of Mythology), will look like a possible virus to most antivirus programs. If, when you run the .exe, it vanishes, that means your antivirus deleted it. 
4. Start Age of Mythology.
5. When you get to the main menu screen, run inject.exe from the /injector/ folder. You can do this either via the command line (where it should print out the process number) or by double-clicking. 
6. Proceed to random maps or multiplayer, and have fun! 

### Known Issues/Unfinished Portions/Rough Edges

- The sudden death and nomad maps will not work seamlessly. This is due to how they are set up with the random map generation. They are still playable, however.
- Lightning and Deathmatch modes are not currently supported. This is partially due to balance reasons, as we have not yet determined how to properly balance the Eldritch in particular. If you decide to try those modes out anyway, I recommend not having headphones on. It gets loud. 
- Playing in online games against AI opponents may cause desyncs. This is a rare but well-documented issue and affects many mods. 
- With spectators in an online game, the gods picked will be shifted up by one for each player under a spectator. As an example, if P1 is a spectator who prior to selecting spectator picked Yog-Sothoth, if P2 is an active player, P2 will be assigned to Yog-Sothoth. As such it is strongly recommended for all spectators to be at the bottom of the player list.
- If you invite a friend via Steam invite, you may cause the game to desync immediately upon starting the match.
- The AI cannot play any of the new gods and, if somehow given a new god, will default to an old one. Moreover, the AI will not react properly to many strategies, such as ignoring Eldritch rituals, not properly quarantining during the use of Plague, and massing counter-infantry against Roman legion units. 
- The AI for Zeus is currently offended by some unknown change. As such, the game will lag significantly when an AI playing as Zeus advances to the mythic age, advances to the titan age, or researches omniscience.
- The menu music is from Age of Wrath, and will soon be changed to Divine Edition-exclusive music.
- Some units cannot be autocued. Specifically, cultists, fire siphons, and most chinese units. This is due to a hardcoded bug which we ourselves discovered.
- Many assets, particularly for the Eldritch, are placeholders. As the Eldritch are visually distinct and very much playable, making their assets is considered a low-priority. 
- Picking an unfinished god will default you to Zeus.
- Picking a random god will pick a random god from the first thirty. As several out of the second fifteen are unfinished, they will default to Zeus. 
- The major god summary pages are incomplete for the Aztecs, and there are issues with the rollover text. We are still trying to find an elegant solution for this.
- The fake techtrees visible in the in-game techtree viewer are unfinished for the Eldritch and Roman gods. This is because making fake techtrees is agonizing and nobody has wanted to do it yet. 
- Many icons, particularly the Aztec and Eldritch icons, are placeholders and are not owned by the Divine Edition modding team.
- Many histories are not yet written.
- The culture-specific music that plays at the start of matches is considered a sound and so is unaffected by adjusting the music volume.
- The UI is almost completely untouched.
- The Roman titan is the Greek titan.
- Some units and buildings lack player color.
- For some relatively low-specs systems, there may be a moment of lag when clicking on "Random Map" or "Multiplayer" after playing several successive matches.
- Balance. There _will_ be severe, glaring balance issues. Please inform us of any you identify in the above discord! 
- Broken interactions. Despite our best efforts, there are almost certainly dozens of cross-civilization interactions which either do not work properly or are flagrantly overpowered. Once again, please inform us of any you identify in the above discord.
- The Eldritch navy is just the Greek navy. This is mostly due to Dagon's potency in water maps being relatively unknown at this point.
- When using the editor, you will have to set one of the "old god picked" or "new god X picked" techs for each player at the beginning of the game. This will clear all of their god powers and techs so if you grant any god powers or set any techs I recommend doing this at around 0.1 seconds into the game.
- Also when using the editor, you will see several units with the same name (many of which don't exist) and many techs with the same name (most of which also don't exist). This is because I am lazy, so I have no good excuse.
- This mod will violently conflict with almost any other mods you have active. 
- Using the "LETS GO!  NOW!" cheat at the beginning of the game will result in overlapping music from 1-2 minutes in.
- In multiplayer, with more than six players all playing Eldritch or Japanese, you may experience slightly more lag.
- I have no idea how saved games will react to this mod, try at your own risk. 
- Recorded games require that you jump through several hoops (see discord post on the topic).
- To edit hotkeys for many units, you will need to enter the hotkey twice: once to make the hotkey work, once to make it display properly ingame. 
- It is very possible that your units lost counter for the Eldritch will be insanely inaccurate. I haven't tested that fully yet.
- Your favorite unit/favorite myth unit may be incorrect. I thought I got all of the tags correct, but it's possible I missed some.
- Some relics may not properly benefit new units, or may benefit them unfairly. 
- Some buildings have unusual clickboxes, making them slightly annoying to highlight in a pinch.
- Some units have unusual hp bar locations, which can make the hp bars rapidly move during certain animations.
- Missing, sub-par, or inaccurate unit line and armory upgrade visual changes.
- Drastic difference in quality between assets. 
- Overall jank that you will almost certainly experience.
- You will have to run the injector each and every time you want to play the mod. 

IF YOU EXPERIENCE ANY DESYNCS IN ONLINE PLAY NOT INVOLVING AI, PLEASE RECORD THE EXACT SCENARIO AND INFORM THE DEVELOPMENT TEAM AT ONCE

### Contributors
ABI3 

Alan Wake (AKA WintorGod) (Aztec Main Designer) (Emeritus, went off to focus on his YouTube, ModdingAoM) 

Ana Winters (Lakota Main Designer) 

AProperGentleman (Project Lead) (Eldritch|Japanese|Roman Main Designer) 

HAMLET (Voice Actor)

Kaoru 

Nick3069 (Created the human soldier and myth unit upgraded textures and models from the Myth Unit Upgrade Pack and Human Units Visible Upgrades) (Never part of Divine Edition)

Soully 

Tiger Baron (Never part of Divine Edition, but created the original Roman mod)

Nox118 (Protogenoi Main Designer)

Zeus (AKA Cannibalh) (Jotunn Main Designer) 

### Associates
Stu (Significant and integral contributions to the injector code and method)

Nottud (Source code vetting and verification)

The Retun of the Gods Team (The ROTG Aztecs 2nd Cosmology, Mayans, and Incas will be added to Divine Edition once they are finished)

### Music Credits
Ritual by Victor Wayne

Sakuya by Sana Bibliothecam

Jotunn by The Muspelheim

Awakening of the Great Old Ones by Rage Sound

Epic Battle Music Remix Rome Total War Soundtrack by Soundtrack Refinery

Mother of Abominations by Cradle of Filth

Microsoft and the original AoM and AoE soundtracks

and numerous pieces by JeHathor

### Join Our Team!
If you're a modder, especially with modeling/animation experience, we would love to have you on our team! If there's a civilization that you really want in the game, then join us and make the assets for it! That's exactly how we got the Romans, who were never originally part of the plan. 

There are currently two open spaces (each with three major gods) so if you've ever wanted to see the Hindus, Slavs, Yoruba, Polynesians, or anyone else, then sign up quick and make your dream a reality! 



<!--
**AoM-Divine-Edition/AoM-Divine-Edition** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->

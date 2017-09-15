
class IsometricGameInfo extends GameInfo
config(game)
config(Database);

var array<Controller> EveryPlayer;

var vector TotalX, TotalY, TotalX2, TotalY2; //TotalX = max, TotalY = min
var string WorldNameGame;

var MU_Minimap GameMinimap;

var vector SpawnLoc;

var bool bSpawnFromKismet;

var Pawn PlayerPawn;

//=============================================================================
// Save/Load Game Variables
//=============================================================================
// Pending save game state file name
var private string PendingSaveGameFileName;
// Pending player pawn for the player controller to spawn when loading a game state
var Pawn PendingPlayerPawn;
// Save game state used for when streaming levels is waiting to be finished. This is cleared when streaming levels are completed.
var SaveGameState StreamingSaveGameState;
//=============================================================================

//=============================================================================
// Database Variables and functions
//=============================================================================
//var private DB_DatabaseMgr mDatabase;
//var private DB_FileMgr mFilemanager;

var SQLProject_Manager DBManager;


/*final function DB_DatabaseMgr getDBMgr()
{
  return mDatabase;
}

final function DB_FileMgr getFileMgr()
{
  return mFilemanager;
}*/

//=============================================================================

event InitGame( string Options, out string ErrorMessage )
{
	local MU_Minimap ThisMinimap;

	Super.InitGame(Options,ErrorMessage);
	
	//mDatabase.initDatabase(self);
	//mFilemanager.initFilemanager(mDatabase);
	if (DBManager == none) DBManager = Spawn(class 'SQLProject_Manager');

  	foreach AllActors(class'IsometricGame.MU_Minimap',ThisMinimap)
	{
		GameMinimap = ThisMinimap;
		//`log("Minimap: "@GameMinimap);
		break;
	}

	//MonsterSpawnTimer();

	// do enter function
	//performServerTravelDone(Options);

	// Set the pending save game file name if required
	if (HasOption(Options, "SaveGameState"))
	{
		PendingSaveGameFileName = ParseOption(Options, "SaveGameState");
	}
	else
	{
		PendingSaveGameFileName = "";
	}
}

/**
 * Start the match - inform all actors that the match is starting, and spawn player pawns. Remember that StartMatch is called automatically if bDelayedStart is false and bWaitingToStartMatch is true within 
 * GameInfo::PostLogin(). If these variables don't make sense on your game type, remember to call StartMatch() yourself when the game should start. However, the code within this function may be moved around
 * as it only needs a valid PlayerController.
 */
function StartMatch()
{
	local SaveGameState SaveGameState;
	local PlayerController PlayerController;
	local int i;

	// Check if we need to load the game or not
	if (PendingSaveGameFileName != "")
	{
		// Instance the save game state
		SaveGameState = new () class'SaveGameState';
		if (SaveGameState == None)
		{
			return;
		}

		// Attempt to deserialize the save game state object from disk
		if (class'Engine'.static.BasicLoadObject(SaveGameState, PendingSaveGameFileName, true, class'SaveGameState'.const.SAVEGAMESTATE_REVISION))
		{
			// Synchrously load in any streaming levels
			if (SaveGameState.StreamingMapFileNames.Length > 0)
			{
				// Ask every player controller to load up the streaming map
				ForEach WorldInfo.AllControllers(class'PlayerController', PlayerController)
				{
					// Stream map files now
					for (i = 0; i < SaveGameState.StreamingMapFileNames.Length; ++i)
					{												
						PlayerController.ClientUpdateLevelStreamingStatus(Name(SaveGameState.StreamingMapFileNames[i]), true, true, true);
					}

					// Block everything until pending loading is done
					PlayerController.ClientFlushLevelStreaming();
				}

				// Store the save game state in StreamingSaveGameState
				StreamingSaveGameState = SaveGameState;
				// Start the looping timer which waits for all streaming levels to finish loading
				//SetTimer(0.05f, true, NameOf(WaitingForStreamingLevelsTimer));
				return;
			}

			// Load the game state
			SaveGameState.LoadGameState();
		}

		// Send a message to all player controllers that we've loaded the save game state
		ForEach WorldInfo.AllControllers(class'PlayerController', PlayerController)
		{
			PlayerController.ClientMessage("Loaded save game state from "$PendingSaveGameFileName$".", 'System');
		}
	}

	Super.StartMatch();
}

/**
 * Restarts a controller
 *
 * @param		NewPlayer		Player to restart
 */
function RestartPlayer(Controller NewPlayer)
{
	local int Idx;
	local array<SequenceObject> Events;
	local SaveGameState_SeqEvent_SavedGameStateLoaded SavedGameStateLoaded;
	local LocalPlayer LP; 
	local PlayerController PC; 

	// Ensure that we have a controller
	if (NewPlayer == None)
	{
		return;
	}

	// If we have a pending player pawn, then just possess that one
	if (PendingPlayerPawn != None)
	{
		`log("THERE IS A PENDINGPAWN!");
		// Assign the pending player pawn as the new player's pawn
		NewPlayer.Pawn = PendingPlayerPawn;

		// Initialize and start it up
		if (PlayerController(NewPlayer) != None)
		{
			PlayerController(NewPlayer).TimeMargin = -0.1;
		}

		NewPlayer.Pawn.LastStartTime = WorldInfo.TimeSeconds;
		NewPlayer.Possess(NewPlayer.Pawn, false);		
		NewPlayer.ClientSetRotation(NewPlayer.Pawn.Rotation, true);

		/*if (!WorldInfo.bNoDefaultInventoryForPlayer)
		{
			AddDefaultInventory(NewPlayer.Pawn);
		}*/

		//SetPlayerDefaults(NewPlayer.Pawn);

		// Activate saved game state loaded events
		if (WorldInfo.GetGameSequence() != None)
		{
			WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SaveGameState_SeqEvent_SavedGameStateLoaded', true, Events);
			for (Idx = 0; Idx < Events.Length; Idx++)
			{
				SavedGameStateLoaded = SaveGameState_SeqEvent_SavedGameStateLoaded(Events[Idx]);				
				if (SavedGameStateLoaded != None)
				{
					SavedGameStateLoaded.CheckActivate(NewPlayer, NewPlayer);
				}
			}
		}

		// Clear the pending pawn
		PendingPlayerPawn = None;
	}
	else // Otherwise spawn a new pawn for the player to possess
	{
		Super.RestartPlayer(NewPlayer);
	}

	// To fix custom post processing chain when not running in editor or PIE.
	PC = PlayerController(NewPlayer);
	if (PC != none)
	{
		LP = LocalPlayer(PC.Player); 

		if (LP != None) 
		{ 
			LP.RemoveAllPostProcessingChains(); 
			LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(), INDEX_NONE, true);

			if (PC.myHUD != None)
			{
				PC.myHUD.NotifyBindPostProcessEffects();
			}
		} 
	}
}

/*function performServerTravel(string aURL)
{
  if(Class == class'IsometricGameInfo'){
    `log("<<<< GameInfo.performServerTravel(): DO NOT SAVE TRANSITION MAP");
  }else{
    `log("<<<< GameInfo.performServerTravel(): SAVE TRANSITION MAP");
    mFilemanager.saveTransition();
  }
  WorldInfo.ServerTravel(aURL);
}

function performServerTravelDone(string aOptions)
{
  if(Class == class'IsometricGameInfo'){
    `log("<<<< GameInfo.performServerTravel(): DO NOT LOAD TRANSITION MAP");
    return;
  }

  `log("<<<< GameInfo.performServerTravel(): LOAD TRANSITION MAP");
  mFilemanager.loadTransition();
}*/

// Function that is executed after each kill
function ScoreKill(Controller Killer, Controller Other)
{
local IsometricGamePlayerController PC;
 
super.ScoreKill(Killer, Other);
 
// Cast to the custom MyPlayerController class
PC = IsometricGamePlayerController(Killer);
// Give XP through our custom function to our PlayerController, change 100 to whatever amount you want
PC.GiveXP(100);

//SetTimer(10, false, 'MonsterSpawnTimer');
}

/**
 * Returns a pawn of the default pawn class
 *
 * @param       NewPlayer - Controller for whom this pawn is spawned
 * @param       StartSpot - PlayerStart at which to spawn pawn
 *
 * @return      pawn
 */
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
        local Pawn ResultPawn;

        ResultPawn = super.SpawnDefaultPawnFor(NewPlayer, StartSpot);

       //`log("Spawn Info stuff");

        if(ResultPawn != none)
        {
                IsometricGamePlayerController(NewPlayer).PlayerSpawned(StartSpot);
        }

		PlayerPawn = ResultPawn;

        return ResultPawn;
}

//The function that updates based on time. Anytime we need to update something--like say, a poll position--we can use this.
function Tick(float DeltaTime)
{
	local Controller CurrentPlayer;
	local PlayerReplicant RCRep;
	local array <Controller> SortedControllers;
	local int i;

super.Tick(DeltaTime);

	foreach WorldInfo.AllControllers(class'Controller', CurrentPlayer)
	{
		RCRep=PlayerReplicant(CurrentPlayer.PlayerReplicationInfo);

		//if (RCRep != none)
		//{
			/*for(i=0; i<SortedControllers.Length; i++)
			{
				CompareRCRep = PlayerReplicant(SortedControllers[i].PlayerReplicationInfo);
				if (RCRep.currentLap > CompareRCRep.currentLap)
				{
					break;
				}
				else if (RCRep.currentLap == CompareRCRep.currentLap)
				{
					if (RCRep.nextCheckpoint > CompareRCRep.nextCheckpoint)
					{
						break;
					}
					else if (RCRep.NextCheckpoint == CompareRCRep.NextCheckpoint)
					{
						CheckpointLoc = Checkpoints[RCRep.nextCheckpoint].GetCenter();
						PawnLoc=CurrentPlayer.Pawn.Location;
						OtherPawnLoc = SortedControllers[i].Pawn.Location;

						if (VSize(CheckpointLoc-PawnLoc) < VSize(CheckpointLoc-OtherPawnLoc))
						{
							break;
						}
					}
				}
			}*/

			if (CurrentPlayer != none)
			{
				SortedControllers.Insert(i,1);
				SortedControllers[i]=CurrentPlayer;
				EveryPlayer = SortedControllers;
				//`log(EveryPlayer[i]);
			}
		}
	//}

}

function PostBeginPlay()
{
	local actor ActorNow;
	local box aBox;
	local Terrain ter;
	local string xmax,ymax,xmin,ymin;
	local vector Vxmax,Vymax,Vxmin,Vymin,Test;
	local vector TerrainOffset,ActorOffset;
	local Actor Axmax,Aymax,Axmin,Aymin;

	Super.PostBeginPlay();

	TotalX = vect(0,0,0);
	TotalY = vect(0,0,0);
	TotalX2 = vect(0,0,0);
	TotalY2 = vect(0,0,0);

	/*foreach AllActors(class'Actor', ActorNow) 
	{
		if (ActorNow.isA('Terrain')) 
		{
			`log("terrain sem off: "@ActorNow.Location);
			ter = Terrain(ActorNow);
			TerrainOffset.X = abs(ter.Location.X);
			TerrainOffset.Y = abs(ter.Location.Y);
			TerrainOffset.Z = abs(ter.Location.Z);
			`log("TerrainOffset: "@TerrainOffset);
			ter.Move(vect(0,0,0));
			`log("Terrain Loc: "@ter.Location);
		}
	}

	foreach AllActors(class'Actor', ActorNow) 
	{
		//`log("Loc: "@ActorNow.Location);
		if (ActorNow.Location == TotalX)
		{
			`log(ActorNow.Name);
		}
		ActorOffset.X = - TerrainOffset.X;//abs(ActorNow.Location.X) - TerrainOffset.X;
		ActorOffset.Y = - TerrainOffset.Y;//abs(ActorNow.Location.Y) - TerrainOffset.Y;
		ActorOffset.Z = - TerrainOffset.Z;//abs(ActorNow.Location.Z) - TerrainOffset.Z;
		//`log("Offset: "@ActorOffset);
		booltest = ActorNow.Move(ActorOffset);

		/*if (ActorNow.CollisionType == COLLIDE_NoCollision) 
		{
			`log(ActorNow.Name);
			booltest = ActorNow.SetLocation(ActorOffset);
		}
		if (ActorNow.CollisionType == COLLIDE_BlockAll) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_BlockAll);
		}
		if (ActorNow.CollisionType == COLLIDE_BlockWeapons) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_BlockWeapons);
		}
		if (ActorNow.CollisionType == COLLIDE_TouchAll) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_TouchAll);
		}
		if (ActorNow.CollisionType == COLLIDE_TouchWeapons) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_TouchWeapons);
		}
		if (ActorNow.CollisionType == COLLIDE_BlockAllButWeapons) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_BlockAllButWeapons);
		}
		if (ActorNow.CollisionType == COLLIDE_TouchAllButWeapons) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_TouchAllButWeapons);
		}
		if (ActorNow.CollisionType == COLLIDE_BlockWeaponsKickable) 
		{
			`log(ActorNow.Name);
			ActorNow.SetCollisionType(COLLIDE_NoCollision);
			booltest = ActorNow.SetLocation(ActorOffset);
			ActorNow.SetCollisionType(COLLIDE_BlockWeaponsKickable);
		}*/

		//`log("Final Loc: "@ActorNow.Location);
		`log(booltest);
		if (ActorNow.isA('Terrain')) 
		{
			`log("Offset: "@ActorOffset);
			`log("Final Loc: "@ActorNow.Location);
		}
	}*/

	/*foreach AllActors(class'Actor', ActorNow) 
	{
		if (ActorNow.isA('Terrain')) 
		{
			ter = Terrain(ActorNow);
			if (ter.Location.x<Totaly2.x) xmin = "terrain";
			TotalY2.x = fmin(TotalY2.x, ter.Location.x);
			if (ter.Location.y<Totaly2.y) ymin = "terrain";
			TotalY2.y = fmin(TotalY2.y, ter.Location.y);

			if ((ter.Location.x + ter.NumPatchesX*ter.drawScale3d.x)>TotalX2.x) xmax = "terrain";
			TotalX2.x = fmax(TotalX2.x, ter.Location.x + ter.NumPatchesX*ter.drawScale3d.x);
			if ((ter.Location.y + ter.NumPatchesY*ter.drawScale3d.y)>TotalX2.y) ymax = "terrain";
			TotalX2.y = fmax(TotalX2.y, ter.Location.y + ter.NumPatchesY*ter.drawScale3d.y);
		}

		else if (ActorNow.CollisionType != COLLIDE_NoCollision) 
		{
			ActorNow.GetComponentsBoundingBox(aBox);
			if (aBox.max.x>TotalX2.x) 
			{
				xmax = string(ActorNow.Name);
				Vxmax = ActorNow.Location;
				Axmax = ActorNow;
			}
			TotalX2.x = fmax(TotalX2.x, aBox.max.x); //max.x
			if (aBox.max.y>TotalX2.y) 
			{
				ymax = string(ActorNow.Name);
				Vymax = ActorNow.Location;
				Aymax = ActorNow;
			}
			TotalX2.y = fmax(TotalX2.y, aBox.max.y); //max.y
			if (aBox.min.x<Totaly2.x) 
			{
				xmin = string(ActorNow.Name);
				Vxmin = ActorNow.Location;
				Axmin = ActorNow;
			}
			TotalY2.x = fmin(TotalY2.x, aBox.min.x); //min.x
			if (aBox.min.y<Totaly2.y) 
			{
				ymin = string(ActorNow.Name);
				Vymin = ActorNow.Location;
				Aymin = ActorNow;
			}
			TotalY2.y = fmin(TotalY2.y, aBox.min.y); //min.y
		}
	}*/

	foreach AllActors(class'Actor', ActorNow) 
	{
		if (ActorNow.isA('Terrain')) 
		{
			ter = Terrain(ActorNow);
			if (ter.Location.x<Totaly.x) xmin = "terrain";
			TotalY.x = fmin(TotalY.x, ter.Location.x);
			if (ter.Location.y<Totaly.y) ymin = "terrain";
			TotalY.y = fmin(TotalY.y, ter.Location.y);

			if ((ter.Location.x + ter.NumPatchesX*ter.drawScale3d.x)>TotalX.x) xmax = "terrain";
			TotalX.x = fmax(TotalX.x, ter.Location.x + ter.NumPatchesX*ter.drawScale3d.x);
			if ((ter.Location.y + ter.NumPatchesY*ter.drawScale3d.y)>TotalX.y) ymax = "terrain";
			TotalX.y = fmax(TotalX.y, ter.Location.y + ter.NumPatchesY*ter.drawScale3d.y);
		}

		else if ((ActorNow.CollisionType != COLLIDE_NoCollision) && (ActorNow.isA('FluidSurfaceActor') != true) && (ActorNow.isA('Volume') != true)) 
		{
			ActorNow.GetComponentsBoundingBox(aBox);
			if (aBox.max.x>TotalX.x) 
			{
				xmax = string(ActorNow.Name);
				Vxmax = ActorNow.Location;
				Axmax = ActorNow;
			}
			TotalX.x = fmax(TotalX.x, aBox.max.x); //max.x
			if (aBox.max.y>TotalX.y) 
			{
				ymax = string(ActorNow.Name);
				Vymax = ActorNow.Location;
				Aymax = ActorNow;
			}
			TotalX.y = fmax(TotalX.y, aBox.max.y); //max.y
			if (aBox.min.x<Totaly.x) 
			{
				xmin = string(ActorNow.Name);
				Vxmin = ActorNow.Location;
				Axmin = ActorNow;
			}
			TotalY.x = fmin(TotalY.x, aBox.min.x); //min.x
			if (aBox.min.y<Totaly.y) 
			{
				ymin = string(ActorNow.Name);
				Vymin = ActorNow.Location;
				Aymin = ActorNow;
			}
			TotalY.y = fmin(TotalY.y, aBox.min.y); //min.y
		}
	}
	
	/*TotalX.X = Axmax.Location.X;
	TotalX.Y = Aymax.Location.Y;
	TotalY.X = Axmin.Location.X;
	TotalY.Y = Aymin.Location.Y;*/

	/*`log("max.x "@xmax);
	`log("max.y "@ymax);
	`log("min.x "@xmin);
	`log("min.y "@ymin);
	`log("Locmax "@Vxmax);
	`log("Locmax "@Vymax);
	`log("Locmin "@Vxmin);
	`log("Locmin "@Vymin);*/
	TotalX.Z = abs(TotalX.X - TotalY.X); //X = abs(max.x - min.x)
	TotalY.Z = abs(TotalX.Y - TotalY.Y); //Y = abs(max.y - min.y)
	/*`log("Total X:");
	`log(TotalX);
	`log("Total Y:");
	`log(TotalY);*/
	WorldNameGame = WorldInfo.GetMapName();
	//StartMatch();
}

function MonsterSpawnTimer()
{
	`log("Monster Spawned");
	Spawn(class 'MonsterPawn',,'NPCPlayer', SpawnLoc,);
}

DefaultProperties
{
	bUseClassicHUD=true
	bDelayedStart=false
	bWaitingToStartMatch=true
	PlayerControllerClass=class'IsometricGame.IsometricGamePlayerController'
	DefaultPawnClass=class'IsometricGame.MyPawn'
    HUDType=class'MyHUD'

	//Don't want to score with kills
	bScoreDeaths = false;
	
	//Don't want to give the physics gun 
	bGivePhysicsGun=false;

	TotalX = 1;
	TotalY = 1;

	SpawnLoc = (X=50000, Y=50000, Z=-1900)

	bSpawnFromKismet = false;

	/*Begin Object Class=DB_DatabaseMgr Name=DatabaseMgr
	End Object
	mDatabase=DatabaseMgr

	Begin Object Class=DB_FileMgr Name=FileMgr
	End Object

	mFilemanager=FileMgr*/

	//I reject your player replication info and substitute it with my own! 
	PlayerReplicationInfoClass = class'IsometricGame.PlayerReplicant'
}

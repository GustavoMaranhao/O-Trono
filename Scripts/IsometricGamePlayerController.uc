
class IsometricGamePlayerController extends GamePlayerController
	dependson(DB_DLLAPI)
	Implements(SaveGameStateInterface);

/*****************************************************************/

var Vector2D    PlayerMouse;                //Hold calculated mouse position (this is calculated in HUD)

var Vector      MouseHitWorldLocation;      //Hold where the ray casted from the mouse in 3d coordinate intersect with world geometry. We will
											//use this information for our movement target when not in pathfinding.

var Vector      MouseHitWorldNormal;        //Hold the normalized vector of world location to get direction to MouseHitWorldLocation (calculated in HUD, not used)
var Vector      MousePosWorldLocation;      //Hold deprojected mouse location in 3d world coordinates. (calculated in HUD, not used)
var Vector      MousePosWorldNormal;        //Hold deprojected mouse location normal. (calculated in HUD, used for camera ray from above)

var float someFloat;
var string someString;
var bool someBoolean;

/***************************************************************** 
 *  Calculated in Hud after mouse deprojection, uses MousePosWorldNormal as direction vector 
 *  This is what calculated MouseHitWorldLocation and MouseHitWorldNormal.
 *  
 *  See Hud.PostRender, Mouse deprojection needs Canvas variable.
 *  
 *  **/
var vector      StartTrace;                 //Hold calculated start of ray from camera
var Vector      EndTrace;                   //Hold calculated end of ray from camera to ground
var vector      RayDir;                     //Hold the direction for the ray query.
var Vector      PawnEyeLocation;            //Hold location of pawn eye for rays that query if an obstacle exist to destination to pathfind.
var Actor       TraceActor;                 //If an actor is found under mouse cursor when mouse moves, its going to end up here.

var MeshMouseCursor MouseCursor;              //Hold the 3d mouse cursor
var ParticleSystem CursorParticle;
var ParticleSystemComponent CursorPool;
var int particlenum;
var StaticMeshComponent MouseIndicator;       //Particle for mouse click
var bool bDestroy;

/*****************************************************************
 *
 *  Mouse button handling
 *
 */

var bool        bLeftMousePressed;          //Initialize this function in StartFire and off in StopFire
var bool        bRightMousePressed;         //Initialize this function in StartFire and off in StopFire
var float       DeltaTimeAccumulated;       //Accumulate time to check for mouse clicks


// Mouse event enum
enum EMouseEvent
{
  LeftMouseButton,
  RightMouseButton,
  MiddleMouseButton,
  ScrollWheelUp,
  ScrollWheelDown,
};

/*****************************************************************/

var bool bPawnNearDestination; //This indicates if pawn is within acceptable offset of destination to stop moving.
var float DistanceRemaining; //This is the calculated distance the pawn has left to get to MouseHitWorldLocation.

var bool bFreeLookMode;
var Rotator   ViewRotation;


/*****************************************************************
 *
 *  PATH FINDING
 *
 * The following variables where taken as is from AiController.uc
 *
 */
var Actor       ScriptedMoveTarget;
/** Route from last scripted action; if valid, sets ScriptedMoveTarget with the points along the route */
var Route       ScriptedRoute;
/** if ScriptedRoute is valid, the index of the current point we're moving to */
var int         ScriptedRouteIndex;
/*****************************************************************/

/** Temp Destination for navmesh destination */
var()   Vector  TempDest;
var bool        GotToDest;
var     Vector  NavigationDestination;
var Vector2D  DistanceCheck;
/*****************************************************************/
var Actor       Target;
var bool        CurrentTargetIsReachable;

/** Experience and Level Related**/
const MAX_LEVEL = 50;
const XP_INCREMENT = 500; // Amount of XP that is added to the amount of XP required for a level, after each level progression
 
var int XP; // Total amount of gathered XP
var int Level; // Current level
var int XPGatheredForNextLevel; // Amount of XP gathered for the next level
var int XPRequiredForNextLevel; // Amount of XP required for the next level
var int Mana;
var int ManaMax;
/*****************************************************************/

/**************************Pawn Spawn******************************/

var class<Pawn> FollowerPawnClass, PlayerPawnClass;
var Pawn        Followers[3];
/*****************************************************************/

/*******************Other Vars***********************/
var bool TriggerActivated;
//var bool TooFar;
var vector OldLoc, NewLoc;
var Pawn OldPawn2;
var Controller Cont2;
var bool bPlayerInput;
var Actor LastEnemy;
var ParticleSystem TargetParticle;
var ParticleSystemComponent TargetPool;

var MyHUD HUDVar;
var bool bInventObject;

var vector DeathPlace;
var rotator DeathRot;

var MyPawn DefaultPawn;

var int NumQuestItems;
var string CurrentQuestItem;

var int ManaRecovered;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("***********************I am alive !****************************");

	if (MyPawn(self.Pawn) == none) IsometricGameInfo(WorldInfo.Game).StartMatch();

	CalculateLevelProgress(); // Calculate XP-related properties at the start of the game
	//MouseCursor = Spawn(class'MeshMouseCursor', self, 'marker');
	SetTimer(1.0,false);
}

function Timer()
{
	HUDVar = MyHUD(myHUD);
	DefaultPawn = MyPawn(Pawn);
	consolecommand("setres 1024x768w");
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
	Pawn.GroundSpeed = 600;
	`log(Pawn.GroundSpeed);
}

event UnPossess()
{
	Pawn.GroundSpeed = 50;
	super.Unpossess();
}


// Handle mouse inputs
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
  local MyHUD MouseInterfaceHUD;

  // Type cast to get our HUD
 MouseInterfaceHUD = MyHUD(myHUD);

  if (MouseInterfaceHUD != None)
  {
    // Detect what kind of input this is
    if (InputEvent == IE_Pressed)
    {
      // Handle pressed event
      switch (MouseEvent)
      {
        case LeftMouseButton:
     MouseInterfaceHUD.PendingLeftPressed = true;
     break;

   case RightMouseButton:
     MouseInterfaceHUD.PendingRightPressed = true;
     break;

   case MiddleMouseButton:
     MouseInterfaceHUD.PendingMiddlePressed = true;
     break;

   case ScrollWheelUp:
     MouseInterfaceHUD.PendingScrollUp = true;
     break;

   case ScrollWheelDown:
     MouseInterfaceHUD.PendingScrollDown = true;
     break;

   default:
     break;
      }
    }
    else if (InputEvent == IE_Released)
    {
      // Handle released event
      switch (MouseEvent)
      {
        case LeftMouseButton:
     MouseInterfaceHUD.PendingLeftReleased = true;
     break;

   case RightMouseButton:
     MouseInterfaceHUD.PendingRightReleased = true;
     break;

   case MiddleMouseButton:
     MouseInterfaceHUD.PendingMiddleReleased = true;
     break;

   default:
     break;
      }
    }
  }
}

// Called when the middle mouse button is pressed
exec function MiddleMousePressed()
{
  HandleMouseInput(MiddleMouseButton, IE_Pressed);
  `log("MMBPressed");
}

// Called when the middle mouse button is released
exec function MiddleMouseReleased()
{
  HandleMouseInput(MiddleMouseButton, IE_Released);
 // //`log("MMBReleased");
}

// Called when the middle mouse wheel is scrolled up
exec function MiddleMouseScrollUp()
{
  HandleMouseInput(ScrollWheelUp, IE_Pressed);
 // //`log("MouseScrollUp");
}

// Called when the middle mouse wheel is scrolled down
exec function MiddleMouseScrollDown()
{
  HandleMouseInput(ScrollWheelDown, IE_Pressed);
 // //`log("MouseScrollDown");
}

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting
{
  exec function StartFire(optional byte FireModeNum)
  {
    Global.StartFire(FireModeNum);
  }
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  PlayerTick is called once per frame
 *
 ******************************************************************/
event PlayerTick( float DeltaTime )
{
		Local Controller Cont;
        Local Pawn OldPawn;
		local rotator Camera1;

		/*if (PlayerReplicant(PlayerReplicationInfo).CurrentInvent[0].ItemTypeName == none) 
		{
			PlayerReplicant(Pawn.PlayerReplicationInfo).Deserialize();
		}*/

		//`log(PlayerReplicant(Pawn.PlayerReplicationInfo).CurrentInvent[0].ItemTypeName);

		if (MyPawn(self.Pawn) == none) 
		{
			`log(self@"I HAVE NO PAWN!");
			self.Destroy();
			//Possess(IsometricGameInfo(WorldInfo.Game).PendingPlayerPawn,false);
			//IsometricGameInfo(WorldInfo.Game).PendingPlayerPawn = none;
		}

        super.PlayerTick(DeltaTime);

		//if ((self.Pawn != none) && (self.myHUD != none))
		//{
			bInventObject = MyHUD(MyHUD).HUDMovie.bFlashMC;

			//Set the location of the 3d marker that moves with the mouse.
			//MouseCursor.SetLocation(MouseHitWorldLocation); 
			if (!bInventObject)
			{
			//We use the right mouse button to move, change it to suit your need !
			if((bLeftMousePressed) && (bPlayerInput))
			{

					//accumulate the time for knowing how much time the button was pressed.
					DeltaTimeAccumulated += DeltaTime;

					//Update destination so that while holding the mouse down the destination changes
					//with the mouse move.
					SetDestinationPosition(MouseHitWorldLocation);

					//If its not already pushed, push the state that makes the pawn run to destination
					//until mouse is unpressed. Make sure we do it after the allocated time for a single
					//click or else two states could be pushed simultaneously
					if(DeltaTimeAccumulated >= 0.2f)
					{
							if(!IsInState('MoveMousePressedAndHold'))
							{
									////`log("Pushed MoveMousePressedAndHold state");
									PushState('MoveMousePressedAndHold');
							}
							else
							{
									//Specify execution of current state, starting from label Begin:, ignoring all events and
									//keeping our current pushed state MoveMousePressedAndHold. To better understand why this
									//continually execute each frame from our Begin: label, see
									//http://udn.epicgames.com/Three/MasteringUnrealScriptStates.html,
									//11.3 - BASIC STATE TRANSITIONS
                        			GotoState('MoveMousePressedAndHold', 'Begin', false, true);
									CursorSpawn(MouseHitWorldLocation);                                
							}
					}
			}

			if (bRightMousePressed)
			{
				 switch(TraceActor.class)
							{
									case class'FollowerPawn' :
									case class'MyPawn':
												if (TraceActor != self.Pawn)
												{
													Camera1 = PlayerCamera.Rotation;
													//Reference our current pawn to make it possessed by AI.
													OldPawn = Pawn;
													OldPawn2 = Pawn;
													OldLoc = OldPawn.Location;
															////`log(OldLoc);
													//Get AI Controller of target pawn
													Cont = Pawn(TraceActor).Controller;
													Pawn.SetPhysics(PHYS_None);
													//Unpossess our selected player
													UnPossess();
													//Unpossess our target player
													Cont.UnPossess();
													//Possess target player
													Possess(Pawn(TraceActor), false);
													SetRotation(Camera1);
													//Old player becomes an AI
													Cont.Possess(OldPawn, false);

													bRightMousePressed = false;
												}
									break;

									case class 'MonsterPawn':
													LastEnemy = TraceActor;
													PushState('Attack');
									break;

									default:
													PushState('Attack');
									break;
							}
			}

			//NewLoc = Pawn.Location;
			}

		/*if ((OldLoc.X - NewLoc.X >= 2000) || (OldLoc.Y - NewLoc.Y >= 2000) || (OldLoc.Z - NewLoc.Z >= 2000))
		{
			if(!IsInState('MoveMousePressedAndHold'))
                        {
                                //`log("Pushed MoveMousePressedAndHold state");
                                PushState('MoveMousePressedAndHold');
                        }
                        else
                        {
                        		GotoState('MoveMousePressedAndHold', 'Begin', false, true);                               
                        }
			//`log(NewLoc);
		}*/

		/*if ((OldLoc.X - NewLoc.X >= 1900) || (OldLoc.Y - NewLoc.Y >= 1900) || (OldLoc.Z - NewLoc.Z >= 1900))
		{
			TooFar = true;
		}
		else
			TooFar = false;*/

        //DumpStateStack();
			if(!Pawn.IsInState('Attack') && (MyPawn(Pawn).Mana < MyPawn(Pawn).ManaMax)) 
			{
				//`log("Pawn Mana:"@MyPawn(Pawn).Mana@"Pawn Max"@MyPawn(Pawn).ManaMax@ManaRecovered);
				if (ManaRecovered >= 20) 
				{
					MyPawn(Pawn).Mana += 0.55;
					HUDVar.HUDMovie.ManaUsed(0.55,MyPawn(Pawn).ManaMax,true);
					ManaRecovered = 0;
				}
				else ManaRecovered++;
			}
		//}
		//else self.Destroy();
}

function RecoverManaNow()
{
	`log("recover now");
	ManaRecovered = 0;
	MyPawn(Pawn).Mana += 0.5;
	HUDVar.HUDMovie.ManaUsed(0.5,MyPawn(Pawn).ManaMax,true);
}

exec function NextWeapon()
{
	////`log("MouseScrollUp");
	if(PlayerCamera.FreeCamDistance <= 512)
	PlayerCamera.FreeCamDistance += 32;
}

exec function PrevWeapon()
{
	////`log("MouseScrollDown");
	if(PlayerCamera.FreeCamDistance >= 64)
	{
	PlayerCamera.FreeCamDistance -= 32;
	}
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  StartFire is called on mouse pressed, here to calculate a mouse click we
 *  set the timer to 0, then initialize mouseButtons according to function
 *  parameter and set the initial destination of the mouse press. Real
 *  process is in PlayerTick function.
 *
 ******************************************************************/
exec function StartFire(optional byte FireModeNum)
{
	local Vector Dest;

	if (!bInventObject)
	{
        //Pop all states to get pawn in auto moving to mouse target location.
        PopState(true);

        //Set timer
        DeltaTimeAccumulated =0;

        //Set initial location of destination
        SetDestinationPosition(MouseHitWorldLocation);
		Dest.X = MouseHitWorldLocation.X;
		Dest.Y = MouseHitWorldLocation.Y;
		Dest.Z = MouseHitWorldLocation.Z;

		////`log(MouseHitWorldLocation);

        //Initialize this to false, so we can at least do one state-frame and evaluate distance again.
        bPawnNearDestination = false;

        //Initialize mouse pressed over time.
        bLeftMousePressed = FireModeNum == 0;
        bRightMousePressed = FireModeNum == 1;

		if (bLeftMousePressed)
		{
		CursorSpawn(Dest);
		}


 		//comment these if not needed
		//if(bLeftMousePressed) //`log("Left Mouse pressed");
		//if(bRightMousePressed) //`log("Right Mouse pressed");

	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Pressed);
 // Super.StartFire(FireModeNum);
	}
}

function DestroyTimer()
{
	bDestroy = true;
}

function ParticleDestroyTimer()
{
    CursorPool.DeactivateSystem();
	particlenum -= 1;
	////`log('Particle Deactivated');
}

function CursorSpawn(vector Dest)
{
	particlenum = 0;
	CursorPool = WorldInfo.MyEmitterPool.SpawnEmitter(CursorParticle,Dest,);
	particlenum += 1;
	if (particlenum >= 1)
		SetTimer(1, false, 'ParticleDestroyTimer');
	////`log('Particle Created');
}

// Function for free cam mode

exec function FreeCamMode()
{
	BeginFreeLook();
	`log("Middle Mouse pressed");
}

exec function NonFreeCamMode()
{
	StopFreeLook();
	`log("Middle Mouse released");
}

// Free Look Mode

function BeginFreeLook()
{
	bFreeLookMode = true;
	////`log("bFreeLookMode true");
}

function StopFreeLook()
{
	bFreeLookMode = false;
	////`log("bFreeLookMode False");
}

function UpdateRotation( float DeltaTime )
	{
	    local rotator    DeltaRot;//, newRotation;
		local vector     Dest;

	    if (bFreeLookMode)
	    {	
			ViewRotation = Rotation;
			Dest.X = MouseHitWorldLocation.X - Pawn.Location.X;
			Dest.Y = MouseHitWorldLocation.Y - Pawn.Location.Y;
			Dest.Z = MouseHitWorldLocation.Z - Pawn.Location.Z;
	        DeltaRot.Yaw     = PlayerInput.aTurn;
	        DeltaRot.Pitch   = PlayerInput.aLookUp;
			DeltaRot.Roll    = 0;

			MyHUD(MyHUD).GetDeltaRot(DeltaRot);

			 ProcessViewRotation(DeltaTime,ViewRotation,DeltaRot);
			 SetRotation(ViewRotation);
	    }
	}


/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  StopFire is called on mouse release, here check the time the buttons have
 *  been pressed (this should be enhanced, but it was kept simple for the tutorial).
 *  if DeltaAccumulated < 0.200 (medium time mouse click) then we calculate it as
 *  a mouse click, else simply stop any state running. EDIT: You must understand only
 *  a single timer has been kept for all mouse button, you should duplicate a timer
 *  for each individual mouse button if you want to support thing like auto-fire while
 *  walking in a direction.
 *
 ******************************************************************/
exec function StopFire(optional byte FireModeNum )
{
	if (!bInventObject)
	{
		////`log("delta accumulated"@DeltaTimeAccumulated);
        //Un-Initialize mouse pressed over time.
        if(bLeftMousePressed && FireModeNum == 0)
        {
                bLeftMousePressed = false;
                ////`log("Left Mouse released");
        }
        if(bRightMousePressed && FireModeNum == 1)
        {
                bRightMousePressed = false;
				Pawn.StopFire(0);
                ////`log("Right Mouse released");
        }

        //If we are not near destination and click occured
        if(!bPawnNearDestination && DeltaTimeAccumulated < 0.2f && FireModeNum != 1)
        {
                //Our pawn has been ordered to a single location on mouse release.
                //Simulate a firing bullet. If it would be ok (clear sight) then we can move to and simply ignore pathfinding.
                if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true))
                {
                        //Simply move to destination.
                        MovePawnToDestination();
                }
                else
                {
                        //fire up pathfinding
                        ExecutePathFindMove();
                }
        }
        else
        {
                //Stop player from going on in that direction forever. This normally needs to be done
                //after a long mouse held. This will make the player stop its current MoveMousePressedAndHold
                //state.
                PopState();
        }

        //reset accumulated timer for mouse held button
        DeltaTimeAccumulated = 0;


		  HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Released);
  Super.StopFire(FireModeNum);
  }
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  MovePawnToDestination will push a MoveMouseClick state that will make
 *  the pawn go to a single destination with a mouse click and then
 *  stop near the destination.
 *
 ******************************************************************/
function MovePawnToDestination()
{
		local int i;


        ////`log("Moving to location without pathfinding!");
        SetDestinationPosition(MouseHitWorldLocation);
        PushState('MoveMouseClick');
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  ExecutePathFindMove makes the call to the FindPathTo so that a list
 *  of possible PathNodes will be cached in RouteCache.
 *
 ******************************************************************/
function ExecutePathFindMove()
{
        ScriptedMoveTarget = FindPathTo(GetDestinationPosition());
        ////`log("Route length is"@RouteCache.Length);
        if( RouteCache.Length > 0 )
        {
                ////`log("Launching PathFind");
                PushState('PathFind');
        }
		else
	{
		//Lets find path with navmesh
		////`log("Launching PathFind with navmesh");
		PushState('NavMeshSeeking');	
	}
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  This is a timer function, it prevents the MoveMouseClick state from
 *  looking to get stuck in an obstacle. After a set of seconds it
 *  pushes the entire state stack so the pawn revert to PlayerMove
 *  automatic state.
 *
 ******************************************************************/
function StopLingering()
{
	//Remove all current move state and query for input from now on.
	////`log("Stopped lingering...");
	PopState(true);
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  PlayerMove is called each frame, we declare it here inside the
 *  PlayerController so its general to all states. It can be possible
 *  to declare this function in each single state, having multiple
 *  PlayerMove scenario, but for the simplicity of the tutorial
 *  we have put it here in the class. It controls the player in that
 *  it does a distance check when moving. It calculates the remaining
 *  distance to the target. If target is within 2D(X,Y) offset, then
 *  set the var bPawnNearDestination for state control.
 *  
 *  Rotation
 *  
 *  This function overrides the controller rotation of the pawn. Depending
 *  on the situation (state) the pawn will either face a direction or rotate
 *  to face the destination.
 *
 ******************************************************************/
function PlayerMove(float DeltaTime)
{
	local Vector PawnXYLocation;
	local Vector DestinationXYLocation;
	local Vector    Destination;
	local Vector2D  DistanceCheck;
	local vector PInputs;

	super.PlayerMove(DeltaTime);

	//Get player destination for a check on distance left. (calculate distance)
	Destination = GetDestinationPosition();
	DistanceCheck.X = Destination.X - Pawn.Location.X;
	DistanceCheck.Y = Destination.Y - Pawn.Location.Y;
	DistanceRemaining = Sqrt((DistanceCheck.X*DistanceCheck.X) + (DistanceCheck.Y*DistanceCheck.Y));
	
	////`log("DistanceCheck is"@DistanceCheck.X@DistanceCheck.Y);
	////`log("Distance remaining"@DistanceRemaining);
	
	if (PlayerInput.aStrafe == 0)
	{
	bPawnNearDestination = DistanceRemaining < 15.0f;
	////`log("Has pawn come near destination ?"@bPawnNearDestination);
	}
	else
	{
		StopLingering();
	}
	if (PlayerInput.aForward != 0)
	{
		StopLingering();
	}
	if (bFreeLookMode)
	{
		UpdateRotation(0.01);
	}

	PawnXYLocation.X = Pawn.Location.X;
	PawnXYLocation.Y = Pawn.Location.Y;

	DestinationXYLocation.X = GetDestinationPosition().X;
	DestinationXYLocation.Y = GetDestinationPosition().Y;

	Pawn.SetRotation(Rotator(DestinationXYLocation - PawnXYLocation));
}



/******************************************************************
 *                      STATES
 *****************************************************************/


/******************************************************************
 *
 *  TUTORIAL STATE (MoveMouseClick)
 *
 *  MoveMouseClick is the state when a mouse button is pressed
 *  once (simple click). Simply go to a set destination.
 *
 *
 ******************************************************************/
state MoveMouseClick
{
        event PoppedState()
        {
               ////`log("MoveMouseClick state popped, disabling StopLingering timer.");
                //Disable all active timers to stop lingering if they are active.
                if(IsTimerActive(nameof(StopLingering)))
                {
                        ClearTimer(nameof(StopLingering));
                }
        }

        event PushedState()
        {
                //Set a function timer. If the pawn is stuck it will stop moving
                //by itself.
                SetTimer(3, false, nameof(StopLingering));
                if (Pawn != None)
                {
                        // make sure the pawn physics are initialized
                        Pawn.SetMovementPhysics();
                }
        }

Begin:
        while(!bPawnNearDestination)
        {
                ////`log("Simple Move in progress");
				MoveTo(GetDestinationPosition());
        }
       ////`log("MoveMouseClick: Pawn is near destination, go out of this state");
        PopState();
}

/******************************************************************
 *
 *  TUTORIAL STATE (MoveMousePressedAndHold)
 *
 *  MoveMousePressedAndHold is the state when a mouse button is pressed
 *  and kept to move the pawn freely.
 *
 *
 ******************************************************************/
state MoveMousePressedAndHold
{
Begin:
        if(!bPawnNearDestination)
        {
                ////`log("MoveMousePressedAndHold at pos"@GetDestinationPosition());
                MoveTo(GetDestinationPosition());
        }
        else
        {
                PopState();
        }
}


/******************************************************************
 *
 *  TUTORIAL STATE (PathFind)
 *
 *  This is almost the same if not identical to AiController
 *  ScriptedRouteMove. For each route in the RouteCache (initialized
 *  with a call to FindPathTo(destVector), push a state that will
 *  make the pawn goto a location determined by a PathNode location.
 *  You will need to have multiple PathNodes on your map for this to
 *  work properly. This does not use NavigationMeshes, only Linked
 *  PathNodes. PathNodes are manually placed. NavigationMeshes uses
 *  Pylons and other type of actors, so the two systems are different.
 *
 ******************************************************************/
state PathFind
{
Begin:
        if( RouteCache.Length > 0 )
        {
                //for each route in routecache push a ScriptedMove state.
                ScriptedRouteIndex = 0;
                while (Pawn != None && ScriptedRouteIndex < RouteCache.length && ScriptedRouteIndex >= 0)
                {
                        //Get the next route (PathNode actor) as next MoveTarget.
                        ScriptedMoveTarget = RouteCache[ScriptedRouteIndex];
                        if (ScriptedMoveTarget != None)
                        {
                                ////`log("ScriptedRoute is launching ScriptedMove index:"@ScriptedRouteIndex);
                                PushState('ScriptedMove');
                        }
                        else
                        {
                                ////`log("ScriptedMoveTarget is invalid for index:"@ScriptedRouteIndex);
                        }
                        ScriptedRouteIndex++;
                }
                PopState();
        }
}

/******************************************************************
 *
 *  TUTORIAL STATE (ScriptedMove)
 *
 *  This is the state that is put on the state stack for each PathNode
 *  found when pathfinding. So if you click on a destination and it has
 *  3 PathNode on its route, this state will be stacked 3 times for
 *  moving to a destination. The destination actor represented
 *  by ScriptedMoveTarget is the PathNode.
 *
 ******************************************************************/
state ScriptedMove
{
Begin:
        while(ScriptedMoveTarget != none && Pawn != none && !Pawn.ReachedDestination(ScriptedMoveTarget))
        {
                // check to see if it is directly reachable
                if (ActorReachable(ScriptedMoveTarget))
                {
                        // then move directly to the actor
                        MoveToward(ScriptedMoveTarget, ScriptedMoveTarget);
                        SetDestinationPosition(ScriptedMoveTarget.Location);
                }
                else
                {
                        // attempt to find a path to the target
                        MoveTarget = FindPathToward(ScriptedMoveTarget);
                        if (MoveTarget != None)
                        {
                                // move to the first node on the path
                                MoveToward(MoveTarget, MoveTarget);
                                SetDestinationPosition(MoveTarget.Location);
                        }
                        else
                        {
                                // abort the move
                                `warn("Failed to find path to"@ScriptedMoveTarget);
                                ScriptedMoveTarget = None;
                        }
                }
        }
        PopState();
}

/////////////// NAVMESH PATHFINDING ///////////////

//Overwrite AIController's ScriptedMove state to make use of the NavigationHandle instead of the old way
state NavMeshSeeking
{
        function bool FindNavMeshPath()
        {
                // Clear cache and constraints (ignore recycling for the moment)
                NavigationHandle.PathConstraintList = none;
                NavigationHandle.PathGoalList = none;

                // Create constraints
                class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle, NavigationDestination );
                class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, NavigationDestination, 50, );

                // Find path
                return NavigationHandle.FindPath();
        }

        Begin:
                ////`log("BEGIN STATE SCRIPTEDMOVE");
                // while we have a valid pawn and move target, and
                // we haven't reached the target yet
                NavigationDestination = GetDestinationPosition();

                if( FindNavMeshPath() )
                {
                        NavigationHandle.SetFinalDestination(NavigationDestination);
                       ////`log("FindNavMeshPath returned TRUE");
                        FlushPersistentDebugLines();
                        NavigationHandle.DrawPathCache(,TRUE);

                        //!Pawn.ReachedPoint here, i do not know how to handle second param, this makes the pawn
                        //stop at the first navmesh patch
                       ////`log("GetDestinationPosition before navigation (destination)"@NavigationDestination);
                        while( Pawn != None && !Pawn.ReachedPoint(NavigationDestination, None) )
                        {
                                if( NavigationHandle.PointReachable( NavigationDestination ) )
                                {
                                        // then move directly to the actor
                                        MoveTo( NavigationDestination, None, , true );
                                        ////`log("Point is reachable");
                                }
                                else
                                {
                                        ////`log("Point is not reachable");
                                        // move to the first node on the path
                                        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
                                        {
                                                ////`log("Got next move location in TempDest " @ TempDest);
                                                // suggest move preparation will return TRUE when the edge's
                                            // logic is getting the bot to the edge point
                                                        // FALSE if we should run there ourselves
                                                if (!NavigationHandle.SuggestMovePreparation( TempDest,self))
                                                {
                                                        ////`log("SuggestMovePreparation in TempDest " @ TempDest);
                                                        MoveTo( TempDest, None, , true );
                                                }
                                        }
                                }
                                DistanceCheck.X = NavigationDestination.X - Pawn.Location.X;
                                DistanceCheck.Y = NavigationDestination.Y - Pawn.Location.Y;
                                DistanceRemaining = Sqrt((DistanceCheck.X*DistanceCheck.X) + (DistanceCheck.Y*DistanceCheck.Y));
                                ////`log("distance from pawn"@Pawn.Location@" to location "@ NavigationDestination@" is "@DistanceRemaining );
                                ////`log("Is pawn valid ?" @Pawn);
                                GotToDest = Pawn.ReachedPoint(NavigationDestination, None);
                               ////`log("Has pawn reached point ?"@GotToDest);

                                if( DistanceRemaining < 15) break;
                        }
                }
                else
                {
                        //give up because the nav mesh failed to find a path
                        `warn("FindNavMeshPath failed to find a path to"@ScriptedMoveTarget);
                        ScriptedMoveTarget = None;
                }   

        ////`log("POPPING STATE!");
        Pawn.ZeroMovementVariables();
        // return to the previous state
        PopState();
}

state PlayerWalking 
{

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, NewRotation;
        local bool bSaveJump;

        if( Pawn == None )
        {
            GotoState('Dead');
        }
        else
        {
            GetAxes(Rotation,X,Y,Z);

            // Update acceleration.
           // X.X=1;
            //Y.Y=1;

            NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
            NewAccel = Pawn.AccelRate * Normal(NewAccel);
            //Pawn.Acceleration = NewAccel;
			////`log(X@"//"@Y@"//"@Z);
            
            DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

            // Update rotation.
           OldRotation = Rotation;
           UpdateRotation( DeltaTime );
            bDoubleJump = false;

            if( bPressedJump && Pawn.CannotJumpNow() )
            {
                bSaveJump = true;
                bPressedJump = false;
            }
            else
            {
                bSaveJump = false;
            }

            if( Role < ROLE_Authority ) // then save this move and replicate it
            {
                ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
            }
            else
            {
                ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
            }
            
         
            bPressedJump = bSaveJump;
			NewRotation = ViewRotation;


			if ( Pawn != None && (PlayerInput.aForward !=0 /*|| PlayerInput.aStrafe != 0*/) )
				Pawn.FaceRotation(NewRotation, DeltaTime);
        }
    }
}

state Attack
{
Begin:
	////`log("Is in attack state!");
	////`log(LastEnemy);

	if (LastEnemy != none)	
	{
		Pawn.StartFire(0);
		Pawn.SetDesiredRotation(Rotator(Normal(LastEnemy.Location - Pawn.Location)));
		//TargetPool = WorldInfo.MyEmitterPool.SpawnEmitter(CursorParticle,Dest,);
		WorldInfo.MyEmitterPool.SpawnEmitter(TargetParticle,LastEnemy.Location,);
		if (TraceActor == LastEnemy) ClearTimer('AcquireAgain');
		else SetTimer(5, false, 'AcquireAgain');
	}

	if (self.Pawn == MyPawn(Pawn)) MyPawn(Pawn).AttackAnim();	
	if (self.Pawn == FollowerPawn(Pawn)) FollowerPawn(Pawn).AttackAnim();	
	////`log(TraceActor);
	PopState();

}

function AcquireAgain()
{
	////`log("Function OK");
	LastEnemy = none;
	Pawn.StopFire(0);
	////`log(LastEnemy);
}

public function AddXP(SeqAct_GiveXP action)// The function that is called from Kismet
{
GiveXP(action.Amount); // Give the player the amount of XP specified in the Kismet action
}

public function GiveXP(int amount)
{
	XP += amount;

	CalculateLevelProgress();

	while (XPGatheredForNextLevel >= XPRequiredForNextLevel && Level < MAX_LEVEL)
	{
		PlayerReplicant(Pawn.PlayerReplicationInfo).level += 1;
		Level++;
		HUDVar.HUDMovie.AddLvl(1);
		
		// Recalculate level progress after leveling up
		CalculateLevelProgress();
	}

	HUDVar.HUDMovie.XPReceived(XPGatheredForNextLevel, XPRequiredForNextLevel);
}

private function CalculateLevelProgress()
{
	local int xpToCurrentLevel; // Total amount of XP gathered with current and previous levels
	
	xpToCurrentLevel = 0.5*Level*(Level-1)*XP_INCREMENT;
	XPGatheredForNextLevel = XP - xpToCurrentLevel;
	XPRequiredForNextLevel = Level * XP_INCREMENT;
}


/*someFloat = 1337;
someString = "Boo!";
someBoolean = true;*/

function GetUnrealVariable(string VarName, string VarType)
{
  //local MouseObject TempObj;
  local ASValue asval;
  local array<ASValue> args;
   
    asval.Type = AS_Number;
	/*
  case ("string"):
    asval.Type = AS_String;
    break;

  case ("bool"):
    asval.Type = AS_Boolean;
    break;

  default:
    break;
  }*/
     
  /*switch(VarName)
  {
  case ("someFloatx"):*/
    asval.n = MousePosWorldLocation.x;
    /*break;

	case ("someFloaty"):
    asval.n = MousePosWorldLocation.y;
    break;
      
  case ("someString"):
    asval.s = someString;
    break;
       
  case ("someBoolean"):
    asval.b = someBoolean;
    break;

  default:
    break;
  }*/
   
  args[0] = asval;
  //TempObj.X = MousePosWorldLocation.x;
  //TempObj.Y = MousePosWorldLocation.y;

 // return args;
}

/*public function CollectSet(CollectQuest action)// The function that is called from Kismet
{
	TriggerActivated = true;
	CollectQuestFunction(action.ItemAmount, action.ItemActor, action.ItemAmount, action.Completed, action.IsActive);
}

public function CollectQuestFunction(int NumRequisitado, actor ActorNecessario, out int NumAtual, bool Completed, bool IsActive)
{

	//`log('out of foreach');
	foreach AllActors(class 'CollectQuest ItemActor', ActorNecessario)
	{
		//`log('Checking foreach');

		if (((Pawn.Location.X - ActorNecessario.Location.X) <= 30.0f) && (Pawn.Location.Y - ActorNecessario.Location.Y) <= 30.0f && TriggerActivated && IsActive)
		{
			NumAtual += 1;
			//`log(NumAtual);
		}
		if ((NumAtual >= NumRequisitado) && (IsActive))
		{
			Completed = true;
			//`log(Completed);
		}
	}
}*/

/*exec function LetterEUsed()
{
	Local FollowerAIController Cont;
    Local Pawn OldPawn;
	local rotator Camera1;
	local int i;
	local MyPawn OldPawn2;

	/*Ccase class'MyPawn':
												Camera1 = PlayerCamera.Rotation;
                                                //Reference our current pawn to make it possessed by AI.
                                                OldPawn = Pawn;
												OldPawn2 = Pawn;
                                                //Get AI Controller of target pawn
                                                Cont = Pawn(TraceActor).Controller;
                                                //Unpossess our selected player
                                                UnPossess();
                                                //Unpossess our target player
                                                Cont.UnPossess();
                                                //Possess target player
                                                Possess(Pawn(TraceActor), false);
												SetRotation(Camera1);
                                                //Old player becomes an AI
                                                Cont.Possess(OldPawn, false);

                                                bRightMousePressed = false;
                                break;
                        }*/
	switch(Pawn.class)
                        {
                                case class'FollowerPawn' :
												Camera1 = PlayerCamera.Rotation;
                                                //Reference our current pawn to make it possessed by AI.
                                                OldPawn = Pawn;
												//OldPawn2 = MyPawn;
                                                //Get AI Controller of target pawn
                                               // Cont = FollowerAIController(MyPawn(Pawn).Controller);
												//Cont=YourController(MyPawn(Pawn).Controller);
                                                //Unpossess our selected player
                                                //UnPossess();												
                                                //Unpossess our target player											
												FollowerAIController(MyPawn(Pawn).Controller).UnPossess();
												/*if (MyPawn(Pawn).Controller == none)
												{
													//Unpossess our selected player
                                                UnPossess();
                                                //Possess target player
                                                Possess(MyPawn(Pawn), false);
												SetRotation(Camera1);
                                                //Old player becomes an AI
												FollowerAIController(OldPawn.Controller).Possess(FollowerPawn(Pawn),false);
												}*/
												
												fscommand('avatar MyPawn');
												//`log('Q Pressed');
                                break;
                        }
}

exec function LetterEReleased()
{
	//`log('Q Released');
}*/

/*function vector PawnLocation()
{
	local vector Temp;

	Temp = Pawn.Location;
	return Temp;
}*/

function PlayerSpawned(NavigationPoint StartLocation)
{
	////`log("Follower is alive");
	/*Followers[0] = Spawn(class 'MyPawn',,'NPCPlayer', StartLocation.Location - vect(400,400,0), StartLocation.Rotation);
	FollowerPawn(Followers[0]).ChooseAnotherMesh(0);
	MyPawn(Followers[0]).SpawnOtherController(class 'IsometricGame.IsometricGamePlayerController');
	Followers[1] = Spawn(FollowerPawnClass,,'NPCPlayer', StartLocation.Location - vect(800,400,0), StartLocation.Rotation);
	FollowerPawn(Followers[1]).ChooseAnotherMesh(1);
	Followers[2] = Spawn(FollowerPawnClass,,'NPCPlayer', StartLocation.Location - vect(400,800,0), StartLocation.Rotation);
	FollowerPawn(Followers[2]).ChooseAnotherMesh(2);*/
}

exec function KillFollowers()
{
	local int i;
	for(i=0;i<=2;i++) 
	{
		if (Followers[i].Controller.Class != class 'IsometricGamePlayerController')
		{
			Followers[i].Controller.destroy();
			Followers[i].destroy();
		}
		else DefaultPawn.destroy();
	}
}


exec function SkillFunction()
{
	HUDVar.HUDMovie.ToggleSkill();
}

exec function InventoryFunction()
{
	HUDVar.HUDMovie.ToggleInv();
}

exec function skill1()
{
	`log("Skill 1 used");
	EvalSkill(1);
}

exec function skill2()
{
	`log("Skill 2 used");
	EvalSkill(2);
}

exec function skill3()
{
	`log("Skill 3 used");
	EvalSkill(3);
}

exec function skill4()
{
	`log("Skill 4 used");
	EvalSkill(4);
}

exec function skill5()
{
	`log("Skill 5 used");
	EvalSkill(5);
}

exec function skill6()
{
	`log("Skill 6 used");
	EvalSkill(6);
}

exec function skill7()
{
	`log("Skill 7 used");
	EvalSkill(7);
}

exec function skill8()
{
	`log("Skill 8 used");
	EvalSkill(8);
}

exec function skill9()
{
	`log("Skill 9 used");
	EvalSkill(9);
}

exec function skill10()
{
	`log("Skill 10 used");
	EvalSkill(10);
}

exec function skill11()
{
	`log("Skill 11 used");
	EvalSkill(11);
}

exec function skill12()
{
	`log("Skill 12 used");
	EvalSkill(12);
}

function EvalSkill(int number)
{
	local string Type;
	local bool Cooldown;
	local AnimNodeSlot FullBodyAnimSlot;
	local int TimeLeft;
	local vector JumpVel,temp;
	local particlesystem parttemp;

	`log("Antes:"@MyPawn(Pawn).Mana);
	if(MyPawn(Pawn).Mana >= 10) //>= ManaRequired
	{
		HUDVar.HUDMovie.GetSkillType(number,Type);
		Cooldown = HUDVar.HUDMovie.GetCooldown(string(number), TimeLeft);
		//HUDVar.HUDMovie.DamageTaken(10,MyPawn(Pawn).HealthMax);
		//MyPawn(Pawn).Health2 -= 10;
		//`log(MyPawn(Pawn).Health2);
		if (Cooldown)
		{
			switch (Type)
			{
				case "Heal": 
					if (MyPawn(Pawn).Health2 < MyPawn(Pawn).HealthMax) 
					{
						WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'StarShipPack.Ammo.BOOM',Pawn.Location,); 
						MyPawn(Pawn).Health2 += 10;
						if (MyPawn(Pawn).Health2 > MyPawn(Pawn).HealthMax) 
						{
							`log("Over Full HP");
							HUDVar.HUDMovie.DamageTaken(MyPawn(Pawn).HealthMax, MyPawn(Pawn).HealthMax,true);
							MyPawn(Pawn).Health2 = MyPawn(Pawn).HealthMax;
						}
						else HUDVar.HUDMovie.DamageTaken(10, MyPawn(Pawn).HealthMax,true);
						`log(MyPawn(Pawn).Health2);
						HUDVar.HUDMovie.ManaUsed(10,MyPawn(Pawn).ManaMax,false);
						MyPawn(Pawn).Mana -= 10;
						HUDVar.HUDMovie.SetCooldown(string(number), 10);
						`log("Depois:"@MyPawn(Pawn).Mana);
					}
					else WorldInfo.Game.Broadcast(self,"At full health!");
					break;
				case "FireBall": 
					/*temp = Pawn.Location;
					temp.Z += 100;
					Pawn.SuggestJumpVelocity(JumpVel, temp, Pawn.Location);
					Pawn.Velocity = JumpVel;*/
					//MyPawn(Pawn).DoCustomJump(false);
					FullBodyAnimSlot = AnimNodeSlot(Pawn.mesh.FindAnimNode('FullBodySlot'));
					FullBodyAnimSlot.PlayCustomAnim('humana_ataque01', 1.0, , , false);
					SetTimer(0.5,false,'FireBallTimer');
					//parttemp = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'particulas_skills.Particles.boladefogo',Pawn.Location,); 
					HUDVar.HUDMovie.ManaUsed(10,MyPawn(Pawn).ManaMax,false);
					MyPawn(Pawn).Mana -= 10;
					HUDVar.HUDMovie.SetCooldown(string(number), 10);
					break;
				case "Buff": break;
				case "Summon": break;
			}
		}
		else WorldInfo.Game.Broadcast(self,Type@"on Cooldown."@TimeLeft@"seconds left.");
	}
	else WorldInfo.Game.Broadcast(self,"Not enough Mana!");
	if(number == 10) 
	{
		`log("Dead");
		MyPawn(Pawn).Health2 = 0;
		if (MyPawn(Pawn).Health2 <= 0) MyPawn(Pawn).GoToState('Dead');
	}
}

function FireBallTimer()
{
	super.StartFire(1);
	super.StopFire(1);
}

function Respawn()
{
	local MyPawn PCtemp;
	local float HealthTemp, ManaTemp;
	local int i;

	HealthTemp = MyPawn(Pawn).HealthMax;
	ManaTemp = MyPawn(Pawn).ManaMax;
	MyPawn(Pawn).destroy();
	PCtemp = Spawn(class 'MyPawn',,'Player', DeathPlace-vect(20,20,0), DeathRot);
	while (PCtemp == none) 
	{
		PCtemp = Spawn(class 'MyPawn',,'Player', DeathPlace-vect(20,20,0)*i, DeathRot);
		i++;
		`log(PCtemp);
	}
	HUDVar.HUDMovie.DamageTaken(HealthTemp, HealthTemp, true);
	HUDVar.HUDMovie.ManaUsed(ManaTemp, ManaTemp, true);
	IgnoreMoveInput(false);
	Possess(PCtemp, false);
}

/* *************************** *
 * SAVE/LOAD GAME STATES BLOCK *
 * *************************** */

/**
 * This exec function will save the game state to the file name provided.
 *
 * @param		FileName		File name to save the SaveGameState to
 */
exec function SaveGameState(string FileName)
{
	local SaveGameState SaveGameState;

	// Instance the save game state
	SaveGameState = new () class'SaveGameState';
	if (SaveGameState == None)
	{
		return;
	}

	// Scrub the file name
	FileName = ScrubFileName(FileName);

	// Ask the save game state to save the game
	SaveGameState.SaveGameState();

	// Serialize the save game state object onto disk
	if (class'Engine'.static.BasicSaveObject(SaveGameState, FileName, true, class'SaveGameState'.const.SAVEGAMESTATE_REVISION))
	{
		// If successful then send a message
		ClientMessage("Saved game state to "$FileName$".", 'System');
	}
}

/**
 * This exec function will load the game state from the file name provided
 *
 * @param		FileName		File name of load the SaveGameState from
 */
exec function LoadGameState(string FileName)
{
	local SaveGameState SaveGameState;

	// Instance the save game state
	SaveGameState = new () class'SaveGameState';
	if (SaveGameState == None)
	{
		return;
	}

	// Scrub the file name
	FileName = ScrubFileName(FileName);

	// Attempt to deserialize the save game state object from disk
	if (class'Engine'.static.BasicLoadObject(SaveGameState, FileName, true, class'SaveGameState'.const.SAVEGAMESTATE_REVISION))
	{
		// Start the map with the command line parameters required to then load the save game state
		ConsoleCommand("start "$SaveGameState.PersistentMapFileName$"?Game="$SaveGameState.GameInfoClassName$"?SaveGameState="$FileName);
	}
}

/**
 * This function just scrubs the FileName to ensure that it is valid
 *
 * @param		FileName		Unscrubbed file name
 * @return						Returns the scrubbed file name
 */
function String ScrubFileName(string FileName)
{
	// Add the extension if it does not exist
	if (InStr(FileName, ".sav",, true) == INDEX_NONE)
	{
		FileName $= ".sav";
	}

	// If the file name has spaces, replace then with under scores
	FileName = Repl(FileName, " ", "_");

	return FileName;
}

function String Serialize()
{
	local JSonObject JSonObject;

	// Instance the JSonObject, abort if one could not be created
	JSonObject = new () class'JSonObject';
	if (JSonObject == None)
	{
		`Warn(Self$" could not be serialized for saving the game state.");
		return "";
	}

	// Serialize the path name so that it can be looked up later
	JSonObject.SetStringValue("Name", PathName(Self));

	// Serialize the object archetype, in case this needs to be spawned
	JSonObject.SetStringValue("ObjectArchetype", PathName(ObjectArchetype));

	// Save the location
	JSonObject.SetFloatValue("Location_X", Location.X);
	JSonObject.SetFloatValue("Location_Y", Location.Y);
	JSonObject.SetFloatValue("Location_Z", Location.Z);

	// Save the rotation
	JSonObject.SetIntValue("Rotation_Pitch", Rotation.Pitch);
	JSonObject.SetIntValue("Rotation_Yaw", Rotation.Yaw);
	JSonObject.SetIntValue("Rotation_Roll", Rotation.Roll);

	// If the controller is the player controller, then saved a flag to say that it should be repossessed by the player when we reload the game state
	JSonObject.SetIntValue("IsPlayerControlled", (self != None) ? 1 : 0);

	// Send the encoded JSonObject
	return class'JSonObject'.static.EncodeJson(JSonObject);
}

/**
 * Deserializes the actor from the data given
 *
 * @param		Data		JSon data representing the differential state of this actor
 */
function Deserialize(JSonObject Data)
{
	local Vector SavedLocation;
	local Rotator SavedRotation;
	local IsometricGameInfo SaveGameStateGameInfo;

	// Deserialize the location and set it
	SavedLocation.X = Data.GetFloatValue("Location_X");
	SavedLocation.Y = Data.GetFloatValue("Location_Y");
	SavedLocation.Z = Data.GetFloatValue("Location_Z");
	SetLocation(SavedLocation);

	// Deserialize the rotation and set it
	SavedRotation.Pitch = Data.GetIntValue("Rotation_Pitch");
	SavedRotation.Yaw = Data.GetIntValue("Rotation_Yaw");
	SavedRotation.Roll = Data.GetIntValue("Rotation_Roll");
	SetRotation(SavedRotation);
}

exec function ShowInventory()
{
	PlayerReplicant(Pawn.PlayerReplicationInfo).ShowInvContents();
	MyPawn(Pawn).UManager.ShowInventCont();
}


DefaultProperties
{
	CameraClass=class'IsometricGame.IsometricCamera'
	InputClass=class'IsometricGame.MouseInterfacePlayerInput'

	Level = 1;
	XP = 0;

	Mana = 100//PlayerPawn.Mana;
	ManaMax = 100//PlayerPawn.ManaMax;

	CursorParticle = ParticleSystem'Gustavo_Pacote1.Effects.ParticleMouse2'
	//UTILIZAR PARTÍCULA COM KILLONDEACTIVATE LIGADO! (PROPRIEDADE NO REQUIRED DO UNREAL CASCADE)
	TargetParticle = ParticleSystem'Gustavo_Pacote1.Effects.Targetting'
	bDestroy = false;

	Completed = false;
	IsActive = false;

	TriggerActivated = false;

	FollowerPawnClass=class'IsometricGame.FollowerPawn'
	PlayerPawnClass=class'IsometricGame.MyPawn'

	PlayerMoved = false;

	bPlayerInput = true;
	bInventObject = false;

	ManaRecovered = 0;

	NumQuestItems = 0;
	CurrentQuestItem = ""
}





/*Bindings=(Name="W",Command="GBA_MoveForward")
Bindings=(Name="S",Command="GBA_Backward")
Bindings=(Name="A",Command="GBA_StrafeLeft")
Bindings=(Name="D",Command="GBA_StrafeRight")
Bindings=(Name="E",Command="GBA_Use")*/

	//ParticleSystem'CTF_Flag_IronGuard.Effects.P_CTF_Flag_IronGuard_Idle_Blue'
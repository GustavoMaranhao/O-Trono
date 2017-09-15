
class MyHUD extends HUD;

var bool    bDrawTraces;    //Hold exec console function switch to display debug of trace lines & Paths.
var FontRenderInfo  TextRenderInfo;         //Font for outputed text to viewport

// The texture which represents the cursor on the screen
var Texture2D CursorTexture; 
// The color of the cursor
var Color CursorColor;


// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Pending right mouse button pressed event
var bool PendingRightPressed;
// Pending right mouse button released event
var bool PendingRightReleased;
// Pending middle mouse button pressed event
var bool PendingMiddlePressed;
// Pending middle mouse button released event
var bool PendingMiddleReleased;
// Pending mouse wheel scroll up event
var bool PendingScrollUp;
// Pending mouse wheel scroll down event
var bool PendingScrollDown;
// Cached mouse world origin
var Vector CachedMouseWorldOrigin;
// Cached mouse world direction
var Vector CachedMouseWorldDirection;
// Last mouse interaction interface
var MouseInterfaceInteractionInterface LastMouseInteractionInterface;

var GameGFxMiniMap HUDMovie; //The name of our GFX UI movie.

var rotator HUDDeltaRot;

var vector World;
var string WorldName;

var vector PlayerInputs, abc;

//var bool TooFar;

//***message pickup properties***
var string Message;
var int TAmount;
var string ItemName;
var float Alpha;
var bool bItemPickedUp;
var Font PlayerFont;
//***end***

simulated event PostBeginPlay()
{
	//local float newwidth,newheight;

	super.PostBeginPlay();
	//`log("The custom hud is alive !");

	//Create a new instance of our custom GFX HUD class. 
	HudMovie = new class'GameGFxMiniMap'; 
	
	//Set it to realtime updating.
	HudMovie.SetTimingMode(TM_Real);

	//Adjusting Minimap dimensions
	World.X = IsometricGameInfo(WorldInfo.Game).TotalX.Z;
	World.Y = IsometricGameInfo(WorldInfo.Game).TotalY.Z;
	World.Z = World.X/World.Y;
	HUDMovie.GetWorldVar(World);
	HUDMovie.GetMiniMapVar(IsometricGameInfo(WorldInfo.Game).GameMinimap);
	WorldName = IsometricGameInfo(WorldInfo.Game).WorldNameGame;
	//`log(World);
	//`log(WorldName);

	//Calls an initialization function inside the custom GFX HUD class 
	HudMovie.Init();

	/*newwidth = HUDMovie.GetVariableNumber("minimap_MC._width")*World.Z;
	newheight = HUDMovie.GetVariableNumber("minimap_MC._height")/World.Z;
	HUDMovie.SetVariableNumber("minimap_MC._width",newwidth);
	HUDMovie.SetVariableNumber("minimap_MC._height",newheight);
	`log("HUD mini width "@newwidth);
	`log("HUD mini height "@newheight);*/

	SetTimer(0.5, false);

}

/******************************************************************
 *  TUTORIAL FUNCTION
 *
 *  Declare a new console command to control debug of 3d line
 *  debug drawing. This will also control of showing the paths
 *  the pawn will have available into its calculated routes.
 *
 ******************************************************************/
exec function ToggleIsometricDebug()
{
	bDrawTraces = !bDrawTraces;
	if(bDrawTraces)
	{
		//`log("Showing debug line trace for mouse");
	}
	else
	{
		//`log("Disabling debug line trace for mouse");
	}
}

/******************************************************************
 * 
 * TUTORIAL FUNCTION
 * 
 * This function will fetch mouse coordinates from the UI
 * Hierarchy in the UIController of the PlayerController
 * 
 * 
 ******************************************************************/
function Vector2d GetMouseCoordinates()
{
	local Vector2D MousePos;
	local MouseInterfacePlayerInput MouseInterfacePlayerInput;
	
	if (PlayerOwner != None) 
	{
		MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput); 

		if (MouseInterfacePlayerInput != None)
		{
			MousePos.X = HUDMovie.tempMouse.X;
			MousePos.Y = HUDMovie.tempMouse.Y; //MouseInterfacePlayerInput.MousePosition.Y;
		}
	}
	return MousePos;
}

/******************************************************************
 * 
 * PostRender event
 * 
 * Use postRender function to define and call all hud drawing 
 * routine.
 * 
 * 
 ******************************************************************/

event PostRender()
{
	local int i;

	local IsometricCamera PlayerCam;
	local IsometricGamePlayerController IsoPlayerController;

	local MyPawn Pawn;

	local MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local MouseInterfaceInteractionInterface MouseInteractionInterface;
	local Vector HitLocation, HitNormal;

  /*// Ensure that we have a valid PlayerOwner and CursorTexture
  if (PlayerOwner != None && CursorTexture != None) 
  {
    // Cast to get the MouseInterfacePlayerInput
    MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput); 

    if (MouseInterfacePlayerInput != None)
    {
      // Set the canvas position to the mouse position
      Canvas.SetPos(MouseInterfacePlayerInput.MousePosition.X, MouseInterfacePlayerInput.MousePosition.Y); 
      // Set the cursor color
      Canvas.DrawColor = CursorColor;
      // Draw the texture on the screen
      Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
    }
  }*/

	HandlePickUpMessage();

	//HudMovie.TickHUD();
	super.PostRender();
	//PostRender is the equivalent of a "tick" function for a HUD wrapper class.


    if (HudMovie != none)
	{
		//As long as we have a HUD, we call the TickHUD function on every tick.
		HudMovie.TickHUD();
	}

	//Get a type casted reference to our custom player controller.
	IsoPlayerController = IsometricGamePlayerController(PlayerOwner);

	//Get the mouse coordinates from the GameUISceneClient
	IsoPlayerController.PlayerMouse = GetMouseCoordinates();
	//Deproject the 2d mouse coordinate into 3d world. Store the MousePosWorldLocation and normal (direction).
	Canvas.DeProject(IsoPlayerController.PlayerMouse, IsoPlayerController.MousePosWorldLocation, IsoPlayerController.MousePosWorldNormal);

	//Get a type casted reference to our custom camera.
	PlayerCam = IsometricCamera(IsoPlayerController.PlayerCamera);

	//Calculate a trace from Player camera + 100 up(z) in direction of deprojected MousePosWorldNormal (the direction of the mouse).
	//-----------------
	//Set the ray direction as the mouseWorldnormal
	IsoPlayerController.RayDir = IsoPlayerController.MousePosWorldNormal;
	//Start the trace at the player camera (isometric) + 100 unit z and a little offset in front of the camera (direction *10)
	IsoPlayerController.StartTrace = (PlayerCam.ViewTarget.POV.Location + vect(0,0,0)) + IsoPlayerController.RayDir * 10;
	//End this ray at start + the direction multiplied by given distance (5000 unit is far enough generally)
	IsoPlayerController.EndTrace = IsoPlayerController.StartTrace + IsoPlayerController.RayDir * 5000;

	//Trace MouseHitWorldLocation each frame to world location (here you can get from the trace the actors that are hit by the trace, for the sake of this
	//simple tutorial, we do noting with the result, but if you would filter clicks only on terrain, or if the player clicks on an npc, you would want to inspect
	//the object hit in the StartFire function
	IsoPlayerController.TraceActor = Trace(IsoPlayerController.MouseHitWorldLocation, IsoPlayerController.MouseHitWorldNormal, IsoPlayerController.EndTrace, IsoPlayerController.StartTrace, true);
	
	//Calculate the pawn eye location for debug ray and for checking obstacles on click.
	IsoPlayerController.PawnEyeLocation = Pawn(PlayerOwner.ViewTarget).Location + Pawn(PlayerOwner.ViewTarget).EyeHeight * vect(0,0,1);



    // Ensure that we have a valid PlayerOwner
    if (PlayerOwner != None)
    {
      // Cast to get the MouseInterfacePlayerInput
      MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);
    }

	// Get the current mouse interaction interface
  MouseInteractionInterface = GetMouseActor(HitLocation, HitNormal);

  // Handle mouse over and mouse out
  // Did we previously had a mouse interaction interface?
  if (LastMouseInteractionInterface != None)
  {
    // If the last mouse interaction interface differs to the current mouse interaction
    if (LastMouseInteractionInterface != MouseInteractionInterface)
    {
      // Call the mouse out function
      LastMouseInteractionInterface.MouseOut(CachedMouseWorldOrigin, CachedMouseWorldDirection);
      // Assign the new mouse interaction interface
      LastMouseInteractionInterface = MouseInteractionInterface; 

      // If the last mouse interaction interface is not none
      if (LastMouseInteractionInterface != None)
      {
        // Call the mouse over function
        LastMouseInteractionInterface.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); // Call mouse over
      }
	      }
  }
  else if (MouseInteractionInterface != None)
  {
    // Assign the new mouse interaction interface
    LastMouseInteractionInterface = MouseInteractionInterface; 
    // Call the mouse over function
    LastMouseInteractionInterface.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); 
  }

  if (LastMouseInteractionInterface != None)
  {
    // Handle left mouse button
    if (PendingLeftPressed)
    {
      if (PendingLeftReleased)
      {
        // This is a left click, so discard
        PendingLeftPressed = false;
        PendingLeftReleased = false;
      }
      else
      {
        // Left is pressed
        PendingLeftPressed = false;
        LastMouseInteractionInterface.MouseLeftPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
      }
    }
    else if (PendingLeftReleased)
    {
      // Left is released
      PendingLeftReleased = false;
      LastMouseInteractionInterface.MouseLeftReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle right mouse button
    if (PendingRightPressed)
    {
      if (PendingRightReleased)
      {
        // This is a right click, so discard
        PendingRightPressed = false;
        PendingRightReleased = false;
      }
      else
      {
        // Right is pressed
        PendingRightPressed = false;
        LastMouseInteractionInterface.MouseRightPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
      }
    }
    else if (PendingRightReleased)
    {
      // Right is released
      PendingRightReleased = false;
      LastMouseInteractionInterface.MouseRightReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle middle mouse button
    if (PendingMiddlePressed)
    {
      if (PendingMiddleReleased)
      {
        // This is a middle click, so discard 
        PendingMiddlePressed = false;
        PendingMiddleReleased = false;
      }
      else
      {
        // Middle is pressed
        PendingMiddlePressed = false;
        LastMouseInteractionInterface.MouseMiddlePressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
      }
    }
    else if (PendingMiddleReleased)
    {
      PendingMiddleReleased = false;
      LastMouseInteractionInterface.MouseMiddleReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle middle mouse button scroll up
    if (PendingScrollUp)
    {
      PendingScrollUp = false;
      LastMouseInteractionInterface.MouseScrollUp(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle middle mouse button scroll down
    if (PendingScrollDown)
    {
      PendingScrollDown = false;
      LastMouseInteractionInterface.MouseScrollDown(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }
  }


  	//Your basic draw hud routine
	DrawHUD();

	if(bDrawTraces)
	{
		//If display is enabled from console, then draw Pathfinding routes and rays.
		super.DrawRoute(Pawn(PlayerOwner.ViewTarget));
		DrawTraceDebugRays();
	}


	for (i=0; i<IsometricGameInfo(WorldInfo.Game).EveryPlayer.Length; i++) //Counts through the "everyplayer" array we made for the racing game info class.
	{
		/*HUDMovie.PopulateMiniMap(IsometricGameInfo(WorldInfo.Game).EveryPlayer[i].Pawn, i);
		HUDMovie.SetVariableNumber("populatelayer", 0);*/
		HUDMovie.UpdateMiniMap(IsometricGameInfo(WorldInfo.Game).EveryPlayer[i].Pawn);//Updates the players' positions on the mini-map.
	}

	if (PlayerOwner.Pawn.Acceleration != vect(0,0,0)) //or player is falling (ainda não implementado)
	{
		HUDMovie.MoveMinimap();
		//`log(PlayerOwner.PlayerInput.aStrafe);
	}

}

function MouseInterfaceInteractionInterface GetMouseActor(optional out Vector HitLocation, optional out Vector HitNormal)
{
  local MouseInterfaceInteractionInterface MouseInteractionInterface;
  local MouseInterfacePlayerInput MouseInterfacePlayerInput;
  local Vector2D MousePosition;
  local Actor HitActor;

  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    return None;
  }

  // Type cast to get the new player input
  MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (MouseInterfacePlayerInput == None)
  {
    return None;
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
  MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors
  Canvas.DeProject(MousePosition, CachedMouseWorldOrigin, CachedMouseWorldDirection);

  // Perform a trace actor interator. An interator is used so that we get the top most mouse interaction
  // interface. This covers cases when other traceable objects (such as static meshes) are above mouse
  // interaction interfaces.
  ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, CachedMouseWorldOrigin + CachedMouseWorldDirection * 65536.f, CachedMouseWorldOrigin,,, TRACEFLAG_Bullet)
  {
    // Type cast to see if the HitActor implements that mouse interaction interface
    MouseInteractionInterface = MouseInterfaceInteractionInterface(HitActor);
    if (MouseInteractionInterface != None)
    {
      return MouseInteractionInterface;
    }
  }

  PlayerInputs.X = PlayerOwner.Pawn.Velocity.X;
  PlayerInputs.Y = PlayerOwner.Pawn.Velocity.Y;
  PlayerInputs.Z = 0;
 // `log(PlayerInputs.X@"//"@PlayerInputs.Y@"//"@PlayerInputs.Z);
  HUDMovie.GetMoves(PlayerInputs);

  return None;
}



function Vector GetMouseWorldLocation()
{
  local MouseInterfacePlayerInput MouseInterfacePlayerInput;
  local Vector2D MousePosition;
  local Vector MouseWorldOrigin, MouseWorldDirection, HitLocation, HitNormal;

  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    return Vect(0, 0, 0);
  }

  // Type cast to get the new player input
  MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (MouseInterfacePlayerInput == None)
  {
    return Vect(0, 0, 0);
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
  MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors
  Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

  // Perform a trace to get the actual mouse world location.
  Trace(HitLocation, HitNormal, MouseWorldOrigin + MouseWorldDirection * 65536.f, MouseWorldOrigin , true,,, TRACEFLAG_Bullet);
  return HitLocation;
}




/*******************************************************************
 *  TUTORIAL FUNCTION
 *
 *  Helper trace for you to visually see where collision and tracing 
 *  extend to.
 *
 *******************************************************************/
function DrawTraceDebugRays()
{
	local IsometricGamePlayerController IsoPlayerController;
	IsoPlayerController = IsometricGamePlayerController(PlayerOwner);
	
	//Draw Trace from the camera to the world using
	Draw3DLine(IsoPlayerController.StartTrace, IsoPlayerController.EndTrace, MakeColor(255,128,128,255));

	//Draw eye ray for collision and determine if a clear running is permitted(no obstacles between pawn && destination)
	Draw3DLine(IsoPlayerController.PawnEyeLocation, IsoPlayerController.MouseHitWorldLocation, MakeColor(0,200,255,255));
}

/**
 * This is the main drawing pump.  It will determine which hud we need to draw (Game or PostGame).  Any drawing that should occur
 * regardless of the game state should go here.
 */
function DrawHUD()
{
	//local Vector Direction;
	local string StringMessage;
	local IsometricGamePlayerController PC;
	local MouseInterfacePlayerInput MouseInterfacePlayerInput;
	//local IsometricGamePlayerController TooFar2;
	
	//Display traced actor class under mouse cursor for fun :)
	if(IsometricGamePlayerController(PlayerOwner).TraceActor != none)
	{
		StringMessage = "Actor selected:"@IsometricGamePlayerController(PlayerOwner).TraceActor;
		if(IsometricGamePlayerController(PlayerOwner).TraceActor.class == class 'U_WorldItemPickup') HUDMovie.GetActorTrace(U_WorldItemPickup(IsometricGamePlayerController(PlayerOwner).TraceActor));
	}
	
	// now draw string with GoldColor color defined in defaultproperties. note you can
	// alternatively use MakeColor(R,G,B,A)
	Canvas.DrawColor = MakeColor(255,183,11,255);
	Canvas.SetPos( 250, 10 );
	Canvas.DrawText( StringMessage, false, , , TextRenderInfo );

	/*TooFar2 = IsometricGamePlayerController(PlayerOwner);
	if (TooFar2.TooFar)
	{
		Canvas.DrawColor = MakeColor(255,183,11,255);
		Canvas.SetPos( 500, 500 );
		Canvas.DrawText( 'Follower Too Far From Player', false, , , TextRenderInfo );
		`log('Drawed');
	}*/


	PC = IsometricGamePlayerController(PlayerOwner);
	/*if ( !PlayerOwner.IsDead() && !PlayerOwner.IsInState('Spectating'))
    {
        DrawBar("Pontos de Vida:"@PlayerOwner.Pawn.Health$"%",PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,20,20,200,80,80);
		DrawBar("Pontos de Mana:"@PC.Mana$"%",PC.Mana, PC.ManaMax,20,40,80,80,200);
		DrawBar("Level:"@PC.Level, PC.Level, PC.MAX_LEVEL ,20,60,200,200,200); //...and our level-bar
		if ( PC.Level != PC.MAX_LEVEL ) //If our player hasn't reached the highest level...
		{
			DrawBar("XP:"@PC.XPGatheredForNextLevel$"/"$PC.XPRequiredForNextLevel, PC.XPGatheredForNextLevel, PC.XPRequiredForNextLevel, 20, 80, 80, 255, 80); //...draw our XP-bar
		}
    }*/


	 // Ensure that we have a valid PlayerOwner and CursorTexture
	 if (PlayerOwner != None && CursorTexture != None) 
	 {
		 // Cast to get the MouseInterfacePlayerInput
		 MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput); 

		 if (MouseInterfacePlayerInput != None)
		 {
			// Set the canvas position to the mouse position
			Canvas.SetPos(MouseInterfacePlayerInput.MousePosition.X, MouseInterfacePlayerInput.MousePosition.Y); 
			// Set the cursor color
			Canvas.DrawColor = CursorColor;
			// Draw the texture on the screen
			//Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
			HUDMovie.GetMouseStats(string(IsometricGamePlayerController(PlayerOwner).TraceActor.class));
		 }
	 }

}

/*function GetMouseText(out Texture2D MouseTex)//, Color MouseColor)
{
	//CursorTexture = MouseTex;
}

function GetMouseColor(out Color MouseColor)
{
	CursorColor = MouseColor;
	Canvas.DrawColor = MakeColor(255,183,11,255);
}*/

function DrawBar(String Title, float Value, float MaxValue,int X, int Y, int R, int G, int B)
{

    local int PosX;
	local int BarSizeX; //Declare our variable representing the size of our bar

    PosX = X; // Where we should draw the next rectangle
	BarSizeX = 300 * FMin(Value / MaxValue, 1); // size of active rectangle

    /* Displays active rectangles */
        Canvas.SetPos(PosX,Y);
		Canvas.SetDrawColor(R, G, B, 200);
		Canvas.DrawRect(BarSizeX, 12);

    /* Displays desactived rectangles */
        Canvas.SetPos(BarSizeX+X,Y);
		Canvas.SetDrawColor(255, 255, 255, 80);
		Canvas.DrawRect(300 - BarSizeX, 12); //Change 300 to however big you want your bar to be

    /* Displays a title */
    Canvas.SetPos(PosX+300+5, Y); //Change 300 to however big your bar is
    Canvas.SetDrawColor(R,G,B,200);
    Canvas.Font = class'Engine'.static.GetSmallFont();
    Canvas.DrawText(Title);

} 

simulated function Timer(){//Our timer function. Until such time as I find a better place than "Postbeginplay" to put the info for populating the minimap, this is our hotfix.
	//`log("Flash Width (timer): "@HUDMovie.GetVariableNumber("minimap_MC.Mapa._width"));
	//`log("Flash Height (timer): "@HUDMovie.GetVariableNumber("minimap_MC.Mapa._height"));
	//`log("minimapWidth (timer): "@HUDMovie.MiniMapWidth);
	//`log("minimapHeight (timer): "@HUDMovie.MiniMapHeight);
	Populater(); //Calls the "Populater" function I wrote earlier.  TALVEZ Dê PROBLEMA, INSERINDO NPCS ANTES DE CALCULAR O TAMANHO DO MAPA
	HUDMovie.ChooseMap(WorldName);
	//Populater(); //Calls the "Populater" function I wrote earlier.    IMAGEM SOME?!
	//`log("Flash Width (timer after choose): "@HUDMovie.GetVariableNumber("minimap_MC._width"));
	//`log("Flash Height(timer after choose): "@HUDMovie.GetVariableNumber("minimap_MC._height"));
	//`log("minimapWidth(timer after choose): "@HUDMovie.MiniMapWidth);
	//`log("minimapHeight(timer after choose): "@HUDMovie.MiniMapHeight);
	//`log("Flash Map Width(timer after choose): "@HUDMovie.GetVariableNumber("minimap_MC.Mapa._width"));
	//`log("Flash Map Height(timer after choose): "@HUDMovie.GetVariableNumber("minimap_MC.Mapa._height"));
}

//"Populater" function. Counts through every player in our game info class and adds them to the GFX HUD's minimap.
function Populater()
{
	local int i,j;
	//Counts through the "everyplayer" array we made for the game info class.
	for (i=0; i<IsometricGameInfo(WorldInfo.Game).EveryPlayer.Length; i++)
	{
		HUDMovie.PopulateMiniMap(IsometricGameInfo(WorldInfo.Game).EveryPlayer[i].Pawn, i);
	}

	/*local Pawn Cont;
	local int i;
	
	i = 0;

	foreach WorldInfo.AllPawns(class 'Pawn',Cont)
	{
		HUDMovie.PopulateMiniMap(Cont, i);
		i++;
	}*/
}

singular event Destroyed()//An event for cleaning up the HUD if the player pawn gets destroyed; IE if someone leaves a game. Just copy this event.
{
	if (HUDMovie != none)
	{
		HUDMovie.Close(true);
		HUDMovie=none;
	}
	Destroy();
}

function GetDeltaRot (rotator abc)
{
	HUDMovie.GetInputs(abc);
}

//Shows the picked up item as well as handle fading
function HandlePickUpMessage()
{
   local float RenderTime;
   local float X,Y,UL,VL;

   Canvas.Font = PlayerFont;
  
   Canvas.TextSize(""@Message$" "@TAmount$" "@ItemName$"(s)",UL,VL);

		X =  (SizeX / 2) - (UL/2);
		Y =  (200) - (VL/2);

		Canvas.SetPos( X, Y);


         // Set the cursor color
   Canvas.SetDrawColor(255, 255, 255, Alpha);
   
   Canvas.DrawText(""@Message$" "@TAmount$" "@ItemName$"(s)");

   if(bItemPickedUp == true)
   {
     if(RenderTime == 0)
        RenderTime = WorldInfo.TimeSeconds;
   }

    if(`TimeSince(RenderTime) > 1.0)
    {

        Alpha = Lerp(Alpha, 0 , 0.05);
        RenderTime -= 0.1;
    }
   else
   {
     RenderTime = 0;
     Alpha = 255;
     bItemPickedUp = false;
   }
}

DefaultProperties
{
  CursorColor=(R=255,G=255,B=255,A=255)
  CursorTexture=Texture2D'EngineResources.Cursors.Arrow'

  PlayerFont = MultiFont'UI_Fonts_Final.menus.Fonts_AmbexHeavy'
}


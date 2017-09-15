
class GameGFxMiniMap extends GFxMoviePlayer;

var float MiniMapWidth, MiniMapHeight;
var vector WorldFromHUD;
//var vector Xtot, Ytot;
var MU_Minimap GameMinimap;
var rotator PlayerInputs;
var vector PlayerMoves;
var vector DeltaMovMini, tempMouse;
var float temp;
var() float ArrowSize;
var MouseInterfacePlayerInput MousePositionVar;
var string MouseOver;
var bool bMouseMove;
var bool bFlashMC;
var U_WorldItemPickup UnderMouse;
var int temporaryNumber;

function Init( optional LocalPlayer LocPlay )
{
//Gets all the other intialization stuff we need.
super.Init (LocPlay);
//Starts the GFx Movie that's attached to this script (IE: our HUD). 
Start(); 
//Advances the frame to the first one.
Advance(0.f);

//`log("Flash Width: "@GetVariableNumber("minimap_MC._width"));
//`log("Flash Height: "@GetVariableNumber("minimap_MC._height"));

MiniMapWidth = GetVariableNumber("minimap_MC._width");
MiniMapHeight = GetVariableNumber("minimap_MC._height");

SetVariableNumber("Mask._y",80);
SetVariableNumber("Mask._x",950);

temp = 0;

TickHUD();//Gets the HUD going on its first tick.
ToggleInv();
ToggleSkill();

/*AddFocusIgnoreKey('I');
AddFocusIgnoreKey('LeftMouseButton');
AddFocusIgnoreKey('MiddleMouseButton');
AddFocusIgnoreKey('RightMouseButton');*/
//AddCaptureKey('MiddleMouseButton');

SetVariableNumber("_root.barraXP._width",0.1);
SetVariableString("_root.textoLvl.text", "01");


/*`log("Mini X: "@ GetVariableNumber("minimap_MC._x"));
`log("Mini Y: "@ GetVariableNumber("minimap_MC._y"));
`log("Flash Width: "@GetVariableNumber("minimap_MC._width"));
`log("Flash Height: "@GetVariableNumber("minimap_MC._height"));
`log("MiniMapWidth: "@MiniMapWidth);
`log("MiniMapHeight: "@MiniMapHeight);
`log(WorldFromHUD);*/

//SetViewport(0, 0, 800, 600);

}

function GetWorldVar (vector abc)
{
	WorldFromHUD = abc;
}

function GetMiniMapVar (MU_Minimap abc)
{
	GameMinimap = abc;
}

function GetInputs (rotator abc)
{
	PlayerInputs = abc;
}

function GetMoves (vector abc)
{
	PlayerMoves = abc;
}

function GetMouseStats (string bcd)
{
	MouseOver = bcd;
}

function GetActorTrace (U_WorldItemPickup bcd)
{
	UnderMouse = bcd;
}

//Calls every tick; we set this up ourselves in the PostRender function in the HUD wrapper.
function TickHUD()
{
local PlayerReplicant RCRep;//Stores the current player's replication info.
local float nowXP; //Stores the current lap.
local float nowLvl; //Stores the current score.
local vector PlayerVect;

RCRep=PlayerReplicant(GetPC().Pawn.PlayerReplicationInfo); //Gets the player's racing replication info.
nowXP = RCRep.xp; //Now that we HAVE the player's replication info, we can update the current xp to that which is stored in the replication info.
nowLvl = RCRep.level; //Same with level.

//SetCompass();

//passing variables to Flash
//SetVariableNumber("Laps",nowXP);
//SetVariableNumber("Place",nowLvl);

if (temp == 0)
{
	SetVariableNumber("minimap_MC.firstplayer._y", ConvertX(GetPC().Pawn.Location.X));
	SetVariableNumber("minimap_MC.firstplayer._x", ConvertY(GetPC().Pawn.Location.Y));

	SetVariableNumber("_root.minimap_MC.firstplayer._width", ArrowSize/7.5);
	SetVariableNumber("_root.minimap_MC.firstplayer._height", ArrowSize/7.5);

	SetVariableNumber("minimap_MC.cone._width", ArrowSize/3);
	SetVariableNumber("minimap_MC.cone._height", ArrowSize/3);

	temp = 1;
	//`log ("temp == 0");
}

SetVariableNumber("_root.minimap_MC.firstplayer._rotation", RadToDeg*UnrRotToRad*GetPC().Pawn.Rotation.Yaw);
//SetVariableNumber("_root.minimap_MC.firstplayer._width", ArrowSize/5);
//SetVariableNumber("_root.minimap_MC.firstplayer._height", ArrowSize/5);
SetVariableNumber("minimap_MC.cone._rotation", RadToDeg*UnrRotToRad*IsometricGamePlayerController(GetPC()).ViewRotation.Yaw);
SetVariableNumber("minimap_MC.cone._x", GetVariableNumber("_root.minimap_MC.firstplayer._x"));
SetVariableNumber("minimap_MC.cone._y", GetVariableNumber("_root.minimap_MC.firstplayer._y"));
//SetVariableNumber("minimap_MC.cone._width", ArrowSize/1.5);
//SetVariableNumber("minimap_MC.cone._height", ArrowSize/1.5);

if (IsometricGamePlayerController(getPC()).bFreeLookMode) 
{
	MouseOver = "null";
	//SetVariableNumber("MouseArt._x", tempMouse.X);
	//SetVariableNumber("MouseArt._y", tempMouse.Y);
}
else
{
	tempMouse.X = GetVariableNumber("_root._xmouse");
	tempMouse.Y = GetVariableNumber("_root._ymouse");

	SetVariableNumber("MouseArt._x", tempMouse.X);
	SetVariableNumber("MouseArt._y", tempMouse.Y);

	MousePositionVar = MouseInterfacePlayerInput(getPC().PlayerInput); 
}

bFlashMC = GetVariableBool("bIsInventItem");

switch(MouseOver)
{
	case "FollowerPawn": MouseOver = "Friend"; break;
	case "MyPawn": MouseOver = "Friend"; break;
	case "MonsterPawn": MouseOver = "Attack"; break;
	case "QuestPawn": MouseOver = "Quest"; break;
	case "U_WorldItemPickup": MouseOver = "Drop"; 
							  SetVariableBool("_root.Box._visible",true);
							  //`log(UnderMouse.ItemName);
							  CallUpdateItemInfo(UnderMouse.ItemLink,UnderMouse.FlashItemType,UnderMouse.ItemName,UnderMouse.ItemProperty,UnderMouse.ItemDescription,UnderMouse.ItemTypeString,1, UnderMouse.ItemRange);
							  break;
	case "none": MouseOver = "Still"; break;
	case "null": MouseOver = "null"; if (!bFlashMC) SetVariableBool("_root.Box._visible",false); break;
	default: MouseOver = "Still"; if (!bFlashMC) SetVariableBool("_root.Box._visible",false); break;
}

SetVariableString("MouseType", MouseOver);

//MousePositionVar = MouseInterfacePlayerInput(getPC().PlayerInput); 

//SetVariableNumber("MouseArt._x", MousePositionVar.MousePosition.X);
//SetVariableNumber("MouseArt._y", MousePositionVar.MousePosition.Y);
//SetVariableString("MouseType", MouseOver);

	//`log("temp != 0");
	//DeltaMovMini.X = PlayerVect.X;
	//DeltaMovMini.Y = PlayerVect.Y;
	//DeltaMovMini.Z = 0;
	/*
	DeltaMovMini.X = ConvertToScreenX(GetVariableNumber("minimap_MC.firstplayer._x"));
	DeltaMovMini.Y = ConvertToScreenY(GetVariableNumber("minimap_MC.firstplayer._y"));
	DeltaMovMini.Z = 0;
	`log("Initial position: "@DeltaMovMini);

	SetVariableNumber("minimap_MC.firstplayer._y", ConvertX(GetPC().Pawn.Location.X));
	SetVariableNumber("minimap_MC.firstplayer._x", ConvertY(GetPC().Pawn.Location.Y));
	PlayerVect.X = ConvertToScreenX(ConvertY(GetPC().Pawn.Location.Y));
	PlayerVect.Y = ConvertToScreenY(ConvertX(GetPC().Pawn.Location.X));
	//SetVariableNumber("_root.minimap_MC.firstplayer._y", GetVariableNumber("Symbol1._y"));
	//SetVariableNumber("_root.minimap_MC.firstplayer._x", GetVariableNumber("Symbol1._x"));

	//DeltaMovMini.X = GetVariableNumber("minimap_MC.firstplayer._x") - DeltaMovMini.X;
	//DeltaMovMini.Y = GetVariableNumber("minimap_MC.firstplayer._y") - DeltaMovMini.Y;
	//DeltaMovMini.Z = 0;

	DeltaMovMini.X = -PlayerVect.X + DeltaMovMini.X;
	DeltaMovMini.Y = -PlayerVect.Y + DeltaMovMini.Y;
	DeltaMovMini.Z = 0;

	//SetVariableNumber("_root.minimap_MC.firstplayer._y", GetVariableNumber("minimap_MC.firstplayer._y") - ConvertX(DeltaMovMini.Y));
	//SetVariableNumber("_root.minimap_MC.firstplayer._x", GetVariableNumber("minimap_MC.firstplayer._x") - ConvertY(DeltaMovMini.X));

	`log("Final Position: "@PlayerVect);
	`log("Delta: "@DeltaMovMini);
	//SetVariableNumber("_root.minimap_MC.firstplayer._y", -50);
	//SetVariableNumber("_root.minimap_MC.firstplayer._x", 50);
	//`log(DeltaMovMini);

	//SetVariableNumber("_root.minimap_MC.firstplayer._y", GetVariableNumber("Symbol1._y"));
	//SetVariableNumber("_root.minimap_MC.firstplayer._x", GetVariableNumber("Symbol1._x"));

	//`log("Player X: "@(GetPC().Pawn.Location.X));
	//`log("Player Y: "@(GetPC().Pawn.Location.Y));
	//`log("Marker X: "@GetVariableNumber("_root.minimap_MC.firstplayer._x"));
	//`log("Marker Y: "@GetVariableNumber("_root.minimap_MC.firstplayer._y"));
	//`log(DeltaMovMini);
*/
}

function InsertPlayer(float param1, float param2)
{
local vector PlayerDim;

ActionScriptVoid("_root.InsertPlayer");

PlayerDim.X = GetVariableNumber("minimap_MC.firstplayer._width")*WorldFromHUD.Z;         //Melhor Insert no Mapa (movieClip)
PlayerDim.Y = GetVariableNumber("minimap_MC.firstplayer._height")/WorldFromHUD.Z;

SetVariableNumber("minimap_MC.firstplayer._width",PlayerDim.X);
SetVariableNumber("minimap_MC.firstplayer._height",PlayerDim.Y);
}

function InsertOtherPlayer(float param1, float param2, string param3, float param4)
{
	local vector NPCDim;
	local String Path, PathX, PathY;

	ActionScriptVoid("_root.InsertOtherPlayer");

	Path = "minimap_MC.";
	Path $= param3;
	PathX = Path$"._width";
	PathY = Path$"._height";

	if (Path != "minimap_MC.IsometricGamePlayerController_0")
	{		
		NPCDim.X = GetVariableNumber(PathX)*WorldFromHUD.Z;
		NPCDim.Y = GetVariableNumber(PathY)/WorldFromHUD.Z;

		SetVariableNumber(PathX,NPCDim.X);
		SetVariableNumber(PathY,NPCDim.Y);
	}

}


function ChooseMap(string param1)
{

ActionScriptVoid("_root.ChooseMap");

MiniMapWidth = GetVariableNumber("minimap_MC._width")/WorldFromHUD.Z;
MiniMapHeight = GetVariableNumber("minimap_MC._height")*WorldFromHUD.Z;

SetVariableNumber("minimap_MC._width", MiniMapWidth);
SetVariableNumber("minimap_MC._height", MiniMapHeight);

/*`log("WorldfromHUD: "@WorldFromHUD);
`log("Compass Wid: "@GetVariableNumber("Compass_MC._width"));
`log("Compass Height: "@GetVariableNumber("Compass_MC._height"));*/

/*SetVariableNumber("_root.minimap_MC._y", GetVariableNumber("Compass_MC._y") + ConvertY(GetPC().Pawn.Location.Y));
SetVariableNumber("_root.minimap_MC._x", GetVariableNumber("Compass_MC._x") + ConvertX(GetPC().Pawn.Location.X));
SetVariableNumber("_root.minimap_MC.firstplayer._y", GetVariableNumber("Symbol1._y"));
SetVariableNumber("_root.minimap_MC.firstplayer._x", GetVariableNumber("Symbol1._x"));*/

//`log("Loc X: "@ GetVariableNumber("minimap_MC.firstplayer._x"));
//`log("Loc Y: "@ GetVariableNumber("minimap_MC.firstplayer._y"));
/*`log("Mini X: "@ GetVariableNumber("minimap_MC._x"));
`log("Mini Y: "@ GetVariableNumber("minimap_MC._y"));
`log("Flash Width: "@GetVariableNumber("minimap_MC._width"));
`log("Flash Height: "@GetVariableNumber("minimap_MC._height"));
`log("MiniMapWidth: "@MiniMapWidth);
`log("MiniMapHeight: "@MiniMapHeight);*/

//SetVariableNumber("minimap_MC._y",500);//ConvertY(GetPC().Pawn.Location.Y));
//SetVariableNumber("minimap_MC._x",500); //ConvertX(GetPC().Pawn.Location.X));

InsertPlayer(ConvertX(GetPC().Pawn.Location.X),ConvertY(GetPC().Pawn.Location.Y));

//SetVariableNumber("minimap_MC.firstplayer._y", ConvertX(GetPC().Pawn.Location.X));
//SetVariableNumber("minimap_MC.firstplayer._x", ConvertY(GetPC().Pawn.Location.Y));

SetVariableNumber("minimap_MC._y",GetVariableNumber("Mask._y") - GetVariableNumber("_root.minimap_MC.firstplayer._y"));
SetVariableNumber("minimap_MC._x",GetVariableNumber("Mask._x") - GetVariableNumber("_root.minimap_MC.firstplayer._x"));
temp = 0;
}

function float ConvertX(float ConvertA)
{
	local float ConvertedX;

	ConvertedX = -(ConvertA/(WorldFromHUD.X))*MiniMapWidth*WorldFromHUD.Z;

	return ConvertedX;
}

function float ConvertY(float ConvertB)
{
	local float ConvertedY;

	ConvertedY = (ConvertB/(WorldFromHUD.Y))*MiniMapHeight/WorldFromHUD.Z;

	return ConvertedY;
}

function float ConvertToScreenX(float ConvertA)
{
	local float ConvertToScreenX;

	ConvertToScreenX = (ConvertA/(GetVariableNumber("minimap_MC._width")))*GetVariableNumber("Stage.width");

	return ConvertToScreenX;
}

function float ConvertToScreenY(float ConvertB)
{
	local float ConvertToScreenY;

	ConvertToScreenY = -(ConvertB/(GetVariableNumber("minimap_MC._height")))*GetVariableNumber("Stage.height");

	return ConvertToScreenY;
}


function PopulateMiniMap(Pawn PlayerPawn, float Depth)
{
	local float Xposition;
	local float Yposition;

		//Self-explanitory. The X and Y positions of our pawn.
	if (PlayerPawn != none)
	{
		if (PlayerPawn != GetPC().Pawn) //If the pawn that we pass into this function is NOT the player that owns this HUD, we go ahead with the functionality.
		{
			Xposition=ConvertX(PlayerPawn.Location.X);
			Yposition=ConvertY(PlayerPawn.Location.Y);
			//Again, X and Y positions for the minimap are converted from the location of our pawn.

			//We send the InsertOtherPlayer function the X and Y positions that we want to insert the current player's icon at. We also throw in a string that contains the current pawn's name, and the Depth value that we got passed from the HUD wrapper.
			InsertOtherPlayer(Xposition, Yposition, String(PlayerPawn.Name), Depth);
			//`log(PlayerPawn.Name);
			//`log(getvariablenumber("_root.minimap_MC.MonsterPawn_0._x"));
		}
	}
}

//Function for updating the minimap; gets passed data on each individual pawn in the game from RC_HUD, AKA our HUD wrapper.
function UpdateMiniMap(Pawn PlayerPawn)
{
	local float Xposition;
	local float Yposition;
	local String Path;
	local String PathX;
	local String PathY;
	//We have the X and Y positions of the pawns, as well as a couple of strings that will help us dynamically get the names of each individual map icon.

	if (PlayerPawn != none)
	{
		Path = "_root.minimap_MC.";
		//Every player pawn gets placed inside the minimap movieclip's bounds, so that's how we start off.
		Path $= String(PlayerPawn.Name);
		// $ is the "concatinate" character when working with strings. We use this instead of using "+" to add two strings together. In this case we're casting the name of the player pawn as a string and then adding it to the end of the last string we made. In a later script for populating the minimap, we assign each minimap icon that we instanciate the pawn's name. I advise you look at "PopulateMiniMap" to understand this better.
		PathX = Path$"._x";
		//For the "PathX" variable, we add the necessary string to get the X position of the player's icon in the minimap.
		PathY = Path$"._y";
		//Same thing with "PathY."

		//As long as the player pawn we have now DOESN'T have the same controller as the one that this GFxHUD is assigned to...
		if (PlayerPawn != GetPC().Pawn)
		{
			Xposition=ConvertX(PlayerPawn.Location.X);
			Yposition=ConvertY(PlayerPawn.Location.Y);
			//We assign the X and Y position variables we have in this function with--of course--the X and Y locations of the pawn in Unreal Space, converted with our custom ConvertX function to the coordinates inside our minimap movieclip.

			SetVariableNumber(PathY, Xposition);
			SetVariableNumber(PathX, Yposition);
			//To recap; PathX is going to come out looking something like THIS: "_root.minimap_MC.FollowerPawn_0._x" -- So, throwing PathX in the "path" for our setvariablenumber call ends up assigning the X position that we calculated to that pawn's icon in the minimap.
		}
	}
}

function float GetPlayerHeading()
{
	local Float PlayerHeading;
	local Rotator PlayerRotation;
	local Vector v;

	PlayerRotation.Yaw = getPC().Pawn.Rotation.Yaw;
	v = vector(PlayerRotation);
	PlayerHeading = GetHeadingAngle(v);
	PlayerHeading = UnwindHeading(PlayerHeading);

	while (PlayerHeading < 0)
		PlayerHeading += PI * 2.0f;
	
	return PlayerHeading;
}

function SetCompass()
{	
	local float TrueNorth, PlayerHeading;
	local Float MapRotation,CompassRotation;
	local Vector v;
	local float f;

	TrueNorth = GameMinimap.GetDegreeHeading();
	Playerheading = GetPlayerHeading();//getPC().PlayerInput.aTurn; GetPlayerHeading();
	//`log("Rotation: "@TrueNorth);
	//Calculate rotation values
	if(GameMinimap.bForwardAlwaysUp)
	{
		MapRotation = PlayerHeading;
		CompassRotation = PlayerHeading - TrueNorth;
	}
	else
	{
		MapRotation = PlayerHeading - TrueNorth;
		CompassRotation = MapRotation;
	}
	/*if (PlayerInputs != rot(0,0,0))
	{
		v = vector(PlayerInputs);

		f = GetHeadingAngle(v);
		f = UnwindHeading(f);

		while (f < 0)
			f += PI * 2.0f;

		f *= RadToDeg;

		CompassRotation = CompassRotation + f;
	}*/
	CompassRotation = -CompassRotation;
	//`log("Rotation: "@CompassRotation);
	SetVariableNumber("_root.Compass_MC._rotation",CompassRotation);
}

function MoveMinimap()
{
local vector test;

	//`log("Antes: X "@GetVariableNumber("minimap_MC._x")@" Y "@GetVariableNumber("minimap_MC._y"));
	//`log("ConvertY "@ConvertToScreenY(ConvertY(GetPC().Pawn.Location.Y))@" ConvertX "@ConvertToScreenX(ConvertX(GetPC().Pawn.Location.X)));

	/*test.Y = -GetVariableNumber("minimap_MC.firstplayer._y") + ConvertToScreenX(ConvertX(GetPC().Pawn.Location.X)/WorldFromHUD.Z/10);
	test.X = -GetVariableNumber("minimap_MC.firstplayer._x") + ConvertToScreenY(ConvertY(GetPC().Pawn.Location.Y)*WorldFromHUD.Z/10);
	SetVariableNumber("minimap_MC._x", GetVariableNumber("Compass_MC._x") + test.X);
	SetVariableNumber("minimap_MC._y", GetVariableNumber("Compass_MC._y") + test.Y);
	SetVariableNumber("minimap_MC.firstplayer._x", ConvertY(GetPC().Pawn.Location.Y));
	SetVariableNumber("minimap_MC.firstplayer._y", ConvertX(GetPC().Pawn.Location.X));*/

	//`log("Pawn Loc: "@GetPC().Pawn.Location);

	test.X = GetVariableNumber("minimap_MC.firstplayer._x");// + ConvertToScreenX(ConvertX(GetPC().Pawn.Location.X)/WorldFromHUD.Z/10);
	test.Y = GetVariableNumber("minimap_MC.firstplayer._y");// + ConvertToScreenY(ConvertY(GetPC().Pawn.Location.Y)*WorldFromHUD.Z/10);
	SetVariableNumber("minimap_MC._x", GetVariableNumber("Mask._x") + ConvertX(GetPC().Pawn.Location.Y));
	SetVariableNumber("minimap_MC._y", GetVariableNumber("Mask._y") + ConvertY(GetPC().Pawn.Location.X));
	SetVariableNumber("minimap_MC.firstplayer._x", ConvertY(GetPC().Pawn.Location.Y));
	SetVariableNumber("minimap_MC.firstplayer._y", ConvertX(GetPC().Pawn.Location.X));

	//`log("Result "@test);
	//`log("X"@ConvertToScreenX(ConvertX(GetPC().Pawn.Location.X)/WorldFromHUD.Z/10));
	//`log("Y"@ConvertToScreenY(ConvertY(GetPC().Pawn.Location.Y)*WorldFromHUD.Z/10));
	//`log(ConvertX(GetPC().Pawn.Location.X)/WorldFromHUD.Z);
	//`log(ConvertY(GetPC().Pawn.Location.Y)*WorldFromHUD.Z);
	//1024x768
}

function ToggleSkill()
{
        ActionScriptVoid("_root.toggleskillsvisibility");
}

function ToggleInv()
{
	ActionScriptVoid("_root.togglevisiblity");
}

function CallUpdateItemInfo(string UnrItemTName, string UnrItemType, string UnrItemName, int UnrItemProperty, string UnrDescription, string UnrClass, int UnrAmmount, int UnrRange)
{ 
	ActionScriptVoid("UpdateItemInfo"); 
} 

//ItemLink,FlashItemType,ItemName,ItemProperty,ItemDescription,ItemTypeString,1,ItemRange
function CallNewInventoryItemIncomming()//(string UnrItemTName, string UnrItemType, string UnrItemName, int UnrItemProperty, string UnrDescription, string UnrClass, int UnrAmmount)
{ 
	ActionScriptVoid("NewInventoryItemIncomming"); 
} 

function CallSameInventoryItemIncomming(int UnrItemIdx, int UnrItemAmount)
{ 
	ActionScriptVoid("SameInventoryItemIncomming"); 
} 

function QuitFromFlash()
{
	MyPawn(getPC().Pawn).ConsoleCommand("quit");
}

function DamageTaken(float ammount, float TotalHealth, bool recover)
{
	local float tempwidth,result,percent,TotalWidth;
	local PlayerReplicant RCRep;//Stores the current player's replication info.

	RCRep=PlayerReplicant(GetPC().Pawn.PlayerReplicationInfo); //Gets the player's racing replication info.

	percent = ammount/TotalHealth;
	TotalWidth = 227.25; 
	tempwidth = GetVariableNumber("_root.barraHP._width");
	result = percent*TotalWidth;
	if(!recover) 
	{
		result = tempwidth - result;
		RCRep.Health -= ammount;
	}
	else 
	{
		result = tempwidth + result;
		if (result >= TotalWidth) result = TotalWidth;
		RCRep.Health += ammount;
	}
	if (result <= 0) result = 0;
	SetVariableNumber("_root.barraHP._width",result);
}

function ManaUsed(float ammount, float TotalMana, bool recover)
{
	local float tempwidth,result,percent,TotalWidth;
	local PlayerReplicant RCRep;//Stores the current player's replication info.

	RCRep=PlayerReplicant(GetPC().Pawn.PlayerReplicationInfo); //Gets the player's racing replication info.

	percent = ammount/TotalMana;
	TotalWidth = 227.25; 
	tempwidth = GetVariableNumber("_root.barraMP._width");
	result = percent*TotalWidth;
	if(!recover) 
	{
		result = tempwidth - result;
		RCRep.Mana -= ammount;
	}
	else 
	{
		result = tempwidth + result;
		if (result >= TotalWidth) result = TotalWidth;
		RCRep.Mana += ammount;
	}
	if (result <= 0) result = 0;
	SetVariableNumber("_root.barraMP._width",result);
	`log("result"@result@"Total Mana"@TotalMana@"percent"@percent);
	`log(RCRep.Mana);
}

function XPReceived(float ammount, float TotalXP)
{
	local float tempwidth,result,percent,TotalWidth;

	percent = ammount/TotalXP;
	if (percent >= 1) 
	{
		percent -= 1;
		AddLvl(1);
		SetVariableNumber("_root.barraXP._width",0.1);
	}
	TotalWidth = 227.25; 
	tempwidth = GetVariableNumber("_root.barraXP._width");
	result = percent*TotalWidth;
	result = tempwidth + result;
	if (result >= TotalWidth) 
	{
		AddLvl(1);
		SetVariableNumber("_root.barraXP._width",0.1);
	}
	else SetVariableNumber("_root.barraXP._width",result);
}

function AddLvl(int ammount)
{
	local int tempLvl;
	local PlayerReplicant RCRep;//Stores the current player's replication info.

	RCRep=PlayerReplicant(GetPC().Pawn.PlayerReplicationInfo); //Gets the player's racing replication info.

	tempLvl = RCRep.level+1;
	//tempLvl = int(GetVariableString("_root.textoLvl.text"));
	tempLvl += ammount;
	if (tempLvl<10) SetVariableString("_root.textoLvl.text", "0"$string(tempLvl));
	else SetVariableString("_root.textoLvl.text", string(tempLvl));
}

function int GetInventorySize()
{
	local int GetInventorySize;

	GetInventorySize = GetVariableNumber("_root.slots_array.length");

	return GetInventorySize;
}

function int GetCurrentInventorySize()
{
	local int GetCurrentInventorySize;

	GetCurrentInventorySize = GetVariableNumber("_root.items_array.length");

	return GetCurrentInventorySize;
}

function GFxRemoveItems(string FlashClass,int FlashAmmount)
{
	FlashClass = "IsometricGame."$FlashClass;
	MyPawn(getPC().Pawn).UManager.RemoveItems(FlashClass,FlashAmmount);
	`log(FlashAmmount@"Items Removed");
}

function WeaponEquipped(string FlashClass)
{
	local SwordTest Inv;

	FlashClass = "SwordTest";
	FlashClass = "IsometricGame."$FlashClass;
	/*foreach MyPawn(WorldInfo.GamegetPC().Pawn).InvManager.InventoryActors( Class'SwordTest', Inv )
    {
         InvManager.SetCurrentWeapon( Weapon(Inv) );
         break;
    }*/
	`log("Weapon Equipped called");
}

function WeaponUnequipped()
{
	//local RocketLauncherTest Inv;
	//GameInventoryManager(MyPawn(getPC().Pawn).InvManager).SwitchWeapon(1);//(class'IsometricGame.RocketLauncherTest');
	//foreach GameInventoryManager(InvManager).InventoryActors( Class'RocketLauncherTest', Inv )
    //{
         GameInventoryManager(MyPawn(getPC().Pawn).InvManager).CallSetCurrentWeapon();
         //break;
    //}	
	`log("Weapon Unequipped called");
}

function ArmorEquipped(string FlashClass)
{
	local SwordTest Inv;

	FlashClass = "SwordTest";
	FlashClass = "IsometricGame."$FlashClass;
	GameInventoryManager(MyPawn(getPC().Pawn).InvManager).CallNewArmor();
	/*foreach MyPawn(WorldInfo.GamegetPC().Pawn).InvManager.InventoryActors( Class'SwordTest', Inv )
    {
         InvManager.SetCurrentWeapon( Weapon(Inv) );
         break;
    }*/
	`log("Armor Equipped called");
}

function ArmorUnequipped()
{
	//local RocketLauncherTest Inv;
	//GameInventoryManager(MyPawn(getPC().Pawn).InvManager).SwitchWeapon(1);//(class'IsometricGame.RocketLauncherTest');
	//foreach GameInventoryManager(InvManager).InventoryActors( Class'RocketLauncherTest', Inv )
    //{
         //GameInventoryManager(MyPawn(getPC().Pawn).InvManager).CallNewArmor();
         //break;
    //}	
	`log("Armor Unequipped called");
}

function GetSkillType(int SkillNumber, out string FlashType)
{
	FlashType = "_root.f"$string(SkillNumber)$".itemID";
	FlashType = GetVariableString(FlashType);
	`log(FlashType);
}

function SetCooldown(string SkillNumber, int SkillCool)
{
	local string tempName, tempPath;
	local int i;

	tempPath = "_root.f"$SkillNumber;
	tempName = GetVariableString(tempPath$".itemID");
	`log("Path:"@tempPath@"Name:"@tempName);
	for (i=0;i<=GetVariableNumber("hotkeys_array.length");i++)
	{
		`log("Path:"@GetVariableString("_root.f"$i$".itemID")@"Name:"@tempName);
		if((GetVariableString("_root.f"$i$".itemID") == tempName) && (GetVariableBool("_root.f"$i$".clickable")))
		{
			SkillNumber = String(i);
			ActionScriptVoid("CooldownMC");
		}
	}
}

function bool GetCooldown(string SkillNumber,out int LeftTime)
{
	local string temp;
	local bool result;

	temp = "_root.f"$SkillNumber$".clickable";
	LeftTime = GetVariableNumber("tempNumber"$SkillNumber);
	result = GetVariableBool(temp);
	`log(result);
	return result;
}

DefaultProperties
{
//The path to the swf asset
MovieInfo=SwfMovie'O_Trono.Minimapa'
bDisplayWithHudOff=false
bIgnoreMouseInput=false
bAutoPlay=true
bCaptureInput=false;

ArrowSize = 64;

MousePositionVar = (500,400,0)

bFlashMC=false
}
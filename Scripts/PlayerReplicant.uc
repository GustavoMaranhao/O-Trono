
class PlayerReplicant extends UTPlayerReplicationInfo
Implements(SaveGameStateInterface);

var float level;
var float totalxp,xp;
var float manamax,Mana;
var float healthmax,Health;
var array<object> items;
var IsometricGameInfo TotX, TotY;

struct InventoryContents
{
  var string ItemTypeName;
  var string ItemType;
  var string ItemName;
  var int ItemProperty;
  var string ItemDescription;
  var string ItemClass;
  var int ItemAmmount;
  var int ItemRange;
  var int ItemIdx;
};

var() array<InventoryContents> CurrentInvent;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

    `log("testing UTReplicant");

	SetTimer(2.0,false);
	
	//ClientMessage("After LoadInv.", 'System');
}

function Timer()
{
	if ((Owner.class != class 'IsometricGamePlayerController') || (Owner.class == none)) {self.destroy(); `log("Destroyed");}
	else {LoadInvContents(); `log("AFTER INVLOAD"@Owner@GameInventoryManager(IsometricGamePlayerController(Owner).Pawn.InvManager));}
}

function ShowInvContents()
{
	local int i;

	for (i=0;i<CurrentInvent.Length;i++)
	{
		`log(CurrentInvent[i].ItemName);
	}
	`log(CurrentInvent.Length);
}

function LoadInvContents()
{
	local InventoryContents IteratingInvent;
	local int i;

	`log("!!!"@MyPawn(Owner)@CurrentInvent.Length@"!!!");

	if (Owner != none)
	{
		foreach CurrentInvent(IteratingInvent, i)
		{
			`log(IteratingInvent.ItemName@i);
			`log("Flash Item To Add First:"@IteratingInvent.ItemClass@IteratingInvent.ItemAmmount);
			if (IteratingInvent.ItemClass != "")
			{
				//MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.ItemsIndx.AddItem("IsometricGame."$IteratingInvent.ItemClass);
				//MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.ItemsNumber.AddItem(1);
				`log("Flash Item To Add:"@IteratingInvent.ItemClass@IteratingInvent.ItemAmmount);

				MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.TransferParameters(IteratingInvent.ItemAmmount, IteratingInvent.ItemName, IteratingInvent.ItemType, IteratingInvent.ItemProperty,
																										IteratingInvent.ItemTypeName, IteratingInvent.ItemDescription, IteratingInvent.ItemClass, IteratingInvent.ItemIdx);

				//MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.ItemsIndx.AddItem("IsometricGame."$IteratingInvent.ItemClass);
				//MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.ItemsNumber.AddItem(IteratingInvent.ItemAmmount);

				`log("Flash Item To Add:"@IteratingInvent.ItemClass@IteratingInvent.ItemAmmount);

				if(!(MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.CheckInventorySize("IsometricGame."$IteratingInvent.ItemClass, IteratingInvent.ItemAmmount)))
				{
					`log("Flash Item To Add:"@IteratingInvent.ItemClass@IteratingInvent.ItemAmmount);

					/*if (IteratingInvent.ItemAmmount == 1)
					{
						/*IsometricGamePlayerController(Owner).HUDVar.HUDMovie.CallUpdateItemInfo(IteratingInvent.ItemTypeName, IteratingInvent.ItemType,
																												IteratingInvent.ItemName, IteratingInvent.ItemProperty,
																												IteratingInvent.ItemDescription, IteratingInvent.ItemClass,
																												1,IteratingInvent.ItemRange);
						IsometricGamePlayerController(Owner).HUDVar.HUDMovie.CallNewInventoryItemIncomming(); */
					}
					else
						IsometricGamePlayerController(Owner).HUDVar.HUDMovie.CallSameInventoryItemIncomming(i, IteratingInvent.ItemAmmount);*/

					MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager.AddItems("IsometricGame."$IteratingInvent.ItemClass, IteratingInvent.ItemAmmount);

					`log("Flash Item To Add:"@IteratingInvent.ItemClass@IteratingInvent.ItemAmmount);

					`log("If OK!");
					`log(MyPawn(IsometricGamePlayerController(Owner).Pawn).UManager);
					`log(Owner);
				}
				`log(IteratingInvent.ItemTypeName@i);
			}
			else {CurrentInvent.Remove(i,1); `log("Removing number"@i@CurrentInvent.Length);}
			`log("Flash Item To Add Final:"@IteratingInvent.ItemClass@IteratingInvent.ItemAmmount);
		}
	}
	`log("Final number"@CurrentInvent.Length);

	//IsometricGamePlayerController(Owner).HUDVar.HUDMovie.AddLvl(level);
	//IsometricGamePlayerController(Owner).Level = level+1;

	IsometricGamePlayerController(Owner).GiveXP(xp);
	//IsometricGamePlayerController(Owner).XP = xp;

	MyPawn(IsometricGamePlayerController(Owner).Pawn).Health2 = Health;
	IsometricGamePlayerController(Owner).HUDVar.HUDMovie.DamageTaken(Health,healthmax,true);

	MyPawn(IsometricGamePlayerController(Owner).Pawn).Mana = Mana;
	IsometricGamePlayerController(Owner).HUDVar.HUDMovie.ManaUsed(Mana,manamax,true);

}

function String Serialize()
{
	local JSonObject JSonObject;
	local int i;

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

	for (i=0;i<CurrentInvent.Length;i++)
	{
		JSonObject.SetStringValue("ItemTypeName"$i, CurrentInvent[i].ItemTypeName);
		JSonObject.SetStringValue("ItemType"$i, CurrentInvent[i].ItemType);
		JSonObject.SetStringValue("ItemName"$i, CurrentInvent[i].ItemName);
		JSonObject.SetIntValue("ItemProperty"$i, CurrentInvent[i].ItemProperty);
		JSonObject.SetStringValue("ItemDescription"$i, CurrentInvent[i].ItemDescription);
		JSonObject.SetStringValue("ItemClass"$i, CurrentInvent[i].ItemClass);
		JSonObject.SetIntValue("ItemAmmount"$i, CurrentInvent[i].ItemAmmount);
		JSonObject.SetIntValue("ItemRange"$i, CurrentInvent[i].ItemRange);
		JSonObject.SetIntValue("ItemIdx"$i, CurrentInvent[i].ItemIdx);
		`log(i@"item saved"@CurrentInvent[i].ItemTypeName@CurrentInvent[i].ItemAmmount);
	}

	JSonObject.SetIntValue("Level", IsometricGamePlayerController(Owner).Level);
	JSonObject.SetFloatValue("Xp", IsometricGamePlayerController(Owner).XP);
	JSonObject.SetFloatValue("TotalXp", IsometricGamePlayerController(Owner).XPRequiredForNextLevel);
	JSonObject.SetFloatValue("Health", Health);
	JSonObject.SetFloatValue("Mana", Mana);	
	`log("Level:"@level@"Xp:"@xp@"Health:"@Health@"Mana:"@Mana);

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
	local int i;
	local string test;

	//CurrentInv.ClearAllEntries;

	i=0;

	if (Owner != none)
	{
		Do
		{
			test = Data.GetStringValue("ItemTypeName"$i);
			`log(i);
			`log(test);
			if (test != "")
			{
				CurrentInvent.Insert(i,1);
				CurrentInvent[i].ItemTypeName = Data.GetStringValue("ItemTypeName"$i);
				CurrentInvent[i].ItemType = Data.GetStringValue("ItemType"$i);
				CurrentInvent[i].ItemName = Data.GetStringValue("ItemName"$i);
				CurrentInvent[i].ItemProperty = Data.GetIntValue("ItemProperty"$i);
				CurrentInvent[i].ItemDescription = Data.GetStringValue("ItemDescription"$i);
				CurrentInvent[i].ItemClass = Data.GetStringValue("ItemClass"$i);
				CurrentInvent[i].ItemAmmount = Data.GetIntValue("ItemAmmount"$i);
				CurrentInvent[i].ItemRange = Data.GetIntValue("ItemRange"$i);
				CurrentInvent[i].ItemIdx = Data.GetIntValue("ItemIdx"$i);
				`log(i@"!!!!!!!!!!item loaded"@CurrentInvent[i].ItemTypeName@"!!!!!!!!!!!!!");
			}
			i++;
			//test = Data.GetStringValue("ItemTypeName"$i);
		}	
		Until (test == "");

		level = Data.GetIntValue("Level");
		//IsometricGamePlayerController(Owner).HUDVar.HUDMovie.AddLvl(level);
		xp = Data.GetFloatValue("Xp");
		totalxp = Data.GetFloatValue("TotalXp");
		//IsometricGamePlayerController(Owner).HUDVar.HUDMovie.XPReceived(xp,totalxp);
		/*Health = Data.GetFloatValue("Health");
		MyPawn(IsometricGamePlayerController(Owner).Pawn).Health2 = Health;
		IsometricGamePlayerController(Owner).HUDVar.HUDMovie.DamageTaken(Health,healthmax,true);
		Mana = Data.GetFloatValue("Mana");
		MyPawn(IsometricGamePlayerController(Owner).Pawn).Mana = Mana;
		IsometricGamePlayerController(Owner).HUDVar.HUDMovie.ManaUsed(Mana,manamax,true);*/
		`log("@@@@@@@@@@@@@@@@@@@@@@@Level:"@level@"Xp:"@xp@"Health:"@Health@"Mana:"@Mana@"ManaMax:"@manamax@"@@@@@@@@@@@@@@@@@@@@@@@@@@");

		`log("Function Deserialize"@CurrentInvent.Length);
		//LoadInvContents();
	}
}

DefaultProperties
{
	level = 0;
	xp = 0;
	manamax = 100;
	healthmax = 100;
	Health = 100;
	Mana = 100;
	TotX = IsometricGameInfo.TotalX;
}

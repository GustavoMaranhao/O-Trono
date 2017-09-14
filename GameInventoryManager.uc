//=============================================================================

// Manages all of the inventory in the game. performs checks it its full and 
// handles removing and adding inventory

//=============================================================================

class GameInventoryManager extends InventoryManager
dependson(PlayerReplicant);

//Array of items in the inventory
var array<U_Items> UItems;
// Used to spawn and add item into inventory
var U_Items AddItemVar;
var int Gold, MaxGold;
var MyHUD HUD;
var array<int> ItemsNumber;
var array<string> ItemsIndx;

var() string ItemLink;
var() string ItemName,FlashItemType,ItemDescription,ItemTypeString;
var() int ItemAmount_ADD,ItemProperty,ItemIdx,ItemRange;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("Custom Inventory up");
    
	//find the playercontroller and reference it
    //if(Owner.Class != class 'MyPawn') StartingInventory();
	//ItemsIndx[0] = "";
	//ItemsNumber[0] = 0;
}

function AddGold(int GoldAmount)
{
    if(Gold + GoldAmount >= MaxGold)
    {
        Gold = MaxGold;
    }
    else
    {
        Gold += GoldAmount;
    }
}

function TransferParameters(int TAmmount,string TName,string TFlashType,int TProperty,string TLink,string TDescription,string TTypeString, int TIdx)
{
	ItemAmount_ADD = TAmmount;
	ItemName = TName;
	FlashItemType = TFlashType;
	ItemProperty = TProperty;
	ItemLink = TLink;
	ItemDescription = TDescription;
	ItemTypeString = TTypeString; 
	ItemIdx = TIdx;
}

//@params ItemToCheck item specified in the U_WorldItemPickup class
//@params AmountWantingToAdd the int amount that is specified in the U_WorldItemPickUp class
//returns false if there is space in the inventory returns true if there is not enough space.
function bool CheckInventorySize(string ItemToCheck, int AmountWantingToAdd)
{
  local int i, temp, NullReference, ArrayInd;
  local float MaxSize,CurrentSize;
  local MyHUD PawnHUD;
  local bool SameAdded;
  local PlayerReplicant PlayerRep;//Stores the current player's replication info.
  local string test;

  MaxSize = IsometricGamePlayerController(MyPawn(Owner).Controller).HUDVar.HUDMovie.GetInventorySize();
  CurrentSize = IsometricGamePlayerController(MyPawn(Owner).Controller).HUDVar.HUDMovie.GetCurrentInventorySize();
  PawnHUD = IsometricGamePlayerController(MyPawn(Owner).Controller).HUDVar;
  SameAdded = false;

  PlayerRep=PlayerReplicant(MyPawn(Owner).PlayerReplicationInfo); //Gets the player's racing replication info.

  temp = -1;
  for(i=0;i<ItemsIndx.Length;++i)
  {
	if (ItemsIndx[i] == ItemToCheck)
	{
		temp = i; 
		SameAdded = true;
		`log("***********"@ItemsIndx[i]@"***********");
		`log("***********"@ItemsNumber[i]@"***********");
		break;
	}
  }
  if (temp == -1)
  {
	if(CurrentSize<=MaxSize)
		{
			`log("***********Calling OK*************");
			 PawnHUD.HUDMovie.CallUpdateItemInfo(ItemLink,FlashItemType,ItemName,ItemProperty,ItemDescription,ItemTypeString,1,ItemRange);
			 PawnHUD.HUDMovie.CallNewInventoryItemIncomming();          //AddDifferentType();
			 ItemsIndx.AddItem(ItemToCheck);
			 if (PlayerRep.CurrentInvent[ItemsIndx.Length-1].ItemAmmount != 0)
			 {
			 	ItemsNumber.AddItem(PlayerRep.CurrentInvent[ItemsIndx.Length].ItemAmmount);
				test = Split(ItemsIndx[ItemsIndx.Length-1],".",true);
				ArrayInd = PlayerRep.CurrentInvent.Find('ItemClass', test);
				ItemsNumber[ItemsIndx.Length-1] = PlayerRep.CurrentInvent[ArrayInd].ItemAmmount;
				if (PlayerRep.CurrentInvent[ItemsIndx.Length-1].ItemAmmount != 1) 
					PawnHUD.HUDMovie.CallSameInventoryItemIncomming(ItemIdx,ItemsNumber[ItemsIndx.Length-1]);
			 }
			 else ItemsNumber.AddItem(1);
			 //temp = ItemsNumber.Length;
			 `log("***********"@ItemsIndx[0]@"***********");
			 `log("******1*****"@ItemsNumber[0]@"******1********");
			 `log("has Space for items");
			 return false;
		}
		else
		{
			`log("no more Space for different items");
			`log("*****2******"@ItemsNumber[temp]@"*******2*******");
			return true;
		}
  }
  else 
  {   
	if((ItemsNumber[temp] + AmountWantingToAdd) >= 99)
	{
	  ItemsNumber[temp] = 99;
      `log("no more Space for same items");
	  `log("*******3****"@ItemsNumber[temp]@"********3******");
	  SameAdded = false;
      return true;
	}
	else
	{
		if (SameAdded) 
		{
			if(FlashItemType == "Item")
			{
				ItemsNumber[temp] += AmountWantingToAdd;
				`log("********4***"@ItemsNumber[temp]@"******4********");
				`log("********4***"@AmountWantingToAdd@"******4********");
				if (ItemName == IsometricGamePlayerController(MyPawn(Owner).Controller).CurrentQuestItem) 
				{
					`log("Added");
					IsometricGamePlayerController(MyPawn(Owner).Controller).NumQuestItems++;
				}
				//PawnHUD.HUDMovie.CallUpdateItemInfo(ItemLink,FlashItemType,ItemName,ItemProperty,ItemDescription,ItemTypeString,1);
				PawnHUD.HUDMovie.CallSameInventoryItemIncomming(ItemIdx,ItemsNumber[temp]); //AddSameItemType();
			}
			else 
			{
				`log("It's an equipment");
				PawnHUD.HUDMovie.CallUpdateItemInfo(ItemLink,FlashItemType,ItemName,ItemProperty,ItemDescription,ItemTypeString,1,ItemRange);
				PawnHUD.HUDMovie.CallNewInventoryItemIncomming();          //AddDifferentType();
				ItemsIndx.AddItem(ItemToCheck);
				ItemsNumber.AddItem(1);
				//temp = ItemsNumber.Length;
				`log("***********"@ItemsIndx[0]@"***********");
				`log("******1*****"@ItemsNumber[0]@"******1********");
				`log("has Space for items");
				return false;
			}
		}
	}
  }
}

//default stuff in the beggining of the game (you always have a herb on game start incase the player saves the game with low low health.)
function StartingInventory()
{
	TransferParameters(1,"Healing Herb","Item",10,"Herb","A magical herb with healing properties","UHerb_Items",0);
	CheckInventorySize("IsometricGame.UHerb_Items",1);
	AddItems("UHerb_Items", 1);
}


//Add items to the current inventory
function AddItems(string ItemToAdd, int Amount )
{
	local int i, ArrayInd;
	local class<Actor>       aClass;
	local PlayerReplicant PlayerRep;//Stores the current player's replication info.
	local InventoryContents TempItem, test;

	aClass = class<Actor>(DynamicLoadObject(ItemToAdd, class'Class'));

	`log(self@Owner);

	PlayerRep=PlayerReplicant(MyPawn(Owner).PlayerReplicationInfo); //Gets the player's racing replication info.

    for ( i=0; i<Amount; i++ )
    {
       //Spawn the abstract item when the physical object is picked up and store it
       AddItemVar = U_Items(Spawn(aClass));
       UItems.AddItem(AddItemVar);
    }

	if (ItemName == IsometricGamePlayerController(MyPawn(Owner).Controller).CurrentQuestItem) 
	{
		`log("Added");
		IsometricGamePlayerController(MyPawn(Owner).Controller).NumQuestItems++;
	}
    `log("There are" @ UItems.length @ "Items");

	ArrayInd = PlayerRep.CurrentInvent.Find('ItemTypeName',ItemLink);
	if(ArrayInd == -1)
	{
		TempItem.ItemTypeName = ItemLink;
		TempItem.ItemType = FlashItemType;
		TempItem.ItemName = ItemName;
		TempItem.ItemProperty = ItemProperty;
		TempItem.ItemDescription = ItemDescription;
		TempItem.ItemClass = ItemTypeString;
		TempItem.ItemAmmount = 1;
		TempItem.ItemRange = ItemRange;
		TempItem.ItemIdx = ItemIdx;
		PlayerRep.CurrentInvent.AddItem(TempItem);
		//if(ItemsIndx.Length != PlayerRep.CurrentInvent.Length) ItemsIndx.Remove(ItemsIndx.Length,1);
	}
	else PlayerRep.CurrentInvent[ArrayInd].ItemAmmount = ItemsNumber[ArrayInd];

	foreach PlayerRep.CurrentInvent(test)
	{
		`log("*****************Descripion:"@test.ItemAmmount@test.ItemDescription@"****************************");
	}
}

//Remove items from the current inventory either when used or dropped.
function RemoveItems(string ItemToRemove, int Amount)
{
	local int			i,temp,ArrayInd;
    local U_Items		Item;
	local class<Actor>       aClass;
	local PlayerReplicant PlayerRep;//Stores the current player's replication info.
	local InventoryContents TempItem, test;

	aClass = class<Actor>(DynamicLoadObject(ItemToRemove, class'Class'));

    for (i=0;i<UItems.Length;i++)
    {
		//When the iterator reaches a class that macthes the one that you want to use or remove. 
        // Remove it [i] and then use it.
        if (UItems[i].Class == aClass)
        {
	        UItems.Remove(i,Amount);
			if (ItemName == IsometricGamePlayerController(MyPawn(Owner).Controller).CurrentQuestItem) 
			{
				`log("Removed");
				IsometricGamePlayerController(MyPawn(Owner).Controller).NumQuestItems--;
			}
            break;
        }
    }

  temp = -1;
  for(i=0;i<ItemsIndx.Length;++i)
  {
	if (ItemsIndx[i] == ItemToRemove)
	{
		temp = i; 
		break;
	}
  }
  if (temp != -1)
  {
	  `log("******remove*****"@ItemsIndx[temp]@"*****remove******");
	  `log("*****remove******"@ItemsNumber[temp]@"***remove********");
	  ItemsIndx.Remove(temp, 1);
	  ItemsNumber.Remove(temp, 1);
  }
  else `log("No Items to remove!");

	PlayerRep=PlayerReplicant(MyPawn(Owner).PlayerReplicationInfo); //Gets the player's racing replication info.
	ArrayInd = PlayerRep.CurrentInvent.Find('ItemTypeName',ItemLink);
	if(ArrayInd != -1)
	{
		PlayerRep.CurrentInvent.Remove(ArrayInd,Amount);
	}

	foreach PlayerRep.CurrentInvent(test)
	{
		`log("*****************Descripion:"@test.ItemAmmount@test.ItemDescription@"****************************");
	}

    `log("Now there are only" @ UItems.length @ "Items!");

    //Display the items left just for debugging.
	foreach UItems(Item, i)
	{
		`log("Index=" $ i @ "Value=" $ aClass);
	}
}

function NotifyHUDMessage(string Message, optional int Amount, optional string ItemName)
{
  foreach AllActors(class'MyHUD', HUD)
  {
	HUD.Message = Message;
	HUD.TAmount = Amount;
	HUD.ItemName = ItemName;
	HUD.bItemPickedUp = true;
  }
}

function CallSetCurrentWeapon()
{
	local RocketLauncherTest Inv;

	foreach InventoryActors( Class'RocketLauncherTest', Inv )
    {
		`log(Inv);
		DiscardInventory();
         //SetCurrentWeapon( Inv );
		Inv.Activate();
         break;
    }
}

function CallNewArmor()
{
	local UBasic_Upper Armor;

	Armor = Spawn(class 'UBasic_Upper');
	Armor.SetPosition(MyPawn(Owner));
	Armor.AttachArmor(MyPawn(Owner).Mesh,'HeadShotGoreSocket');
}

function ShowInventCont()
{
	local int i;
	`log(self);
	`log(Owner);
	for (i=0;i<UItems.Length;i++)
	{
		`log("Invent:"@UItems[i]@"("@ItemsIndx[i]@")"@"with"@ItemsNumber[i]@"at"@self);
	}
}

DefaultProperties
{
	PendingFire(0)=0
	PendingFire(1)=0

	Gold = 500
	MaxGold = 99999
}

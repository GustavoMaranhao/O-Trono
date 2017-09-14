
class U_WorldItemPickup extends Actor placeable;

var() editconst const CylinderComponent	CylinderComponent;
var() const editconst DynamicLightEnvironmentComponent LightEnvironment;

//the physical pickup that is seen in the world as a "Bag" which will contain any kind of inventory and a certain amount.
var     GameInventoryManager	InvManager;
var()	string	ItemName,ItemLink,FlashItemType,ItemDescription,ItemTypeString;
var()   string	PickupMessage;			// Human readable description when picked up.
var() SoundCue PickupSound;
var() class<U_Items> ItemType;
var() int ItemAmount_ADD,ItemProperty,ItemIdx,ItemRange;
var MyPawn UHP;
var class<Actor> aClass;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	ItemAmount_ADD = 1;
    SetItemParameters();
}

event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

	`log(Other);
    UHP = MyPawn(Other);
	UHP.UManager.TransferParameters(1,ItemName,FlashItemType,ItemProperty,ItemLink,ItemDescription,ItemTypeString,ItemIdx);

	`log("TypeName: "@ItemName@"Type: "@FlashItemType@"Property: "@ItemProperty);
	`log("Name: "@ItemLink@"Description"@ItemDescription@"Class"@ItemTypeString);

	`log(ItemTypeString);
	ItemTypeString = "IsometricGame."$ItemTypeString;
	aClass = class<Actor>(DynamicLoadObject(ItemTypeString, class'Class'));
	`log(aClass);

    if (UHP != none)
    {
       //If the inventory check returns false (has space) add the item.
       if(!(UHP.UManager.CheckInventorySize(ItemTypeString, ItemAmount_ADD)))
       {
         //Add the picked up item
		`log(ItemTypeString@ItemName@ItemAmount_ADD);
         GiveTo(UHP);
         PlaySound(PickUpSound);
         UHP.UManager.NotifyHUDMessage(PickUpMessage, ItemAmount_ADD, ItemName);
       }
    }
}


//Add to pawns inventory once picked up
//If you still have space add it to the inventory
 function GiveTo( MyPawn Other )
{
	if ( Other != None && Other.UManager != None )
	{
		Other.UManager.AddItems(ItemTypeString, ItemAmount_ADD );
		Destroy();
	}
	//IsometricGamePlayerController(UHP.Controller).HUDVar.HUDMovie.CallNewInventoryItemIncomming(ItemLink,FlashItemType,ItemName,ItemProperty,ItemDescription,ItemTypeString,1);
}

function SetItemParameters()
{
	IsometricGameInfo(WorldInfo.Game).DBManager.SQL_GetItem(ItemAmount_ADD,ItemName,FlashItemType,ItemProperty,ItemLink,ItemDescription,ItemTypeString,ItemIdx,ItemRange);
	if ((ItemName == "") || (ItemLink == "")) SetItemParameters();
	//IsometricGamePlayerController(UHP.Controller).HUDVar.HUDMovie.CallNewInventoryItemIncomming(ItemLink,FlashItemType);
	//`log("****TESTE!:******"@ItemName@FlashItemType@ItemProperty@ItemLink@ItemTypeString);
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object

    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)


    Begin Object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'StaticMeshes.bag'
        Scale = 1.0
		Translation=(X=10,Y=80,Z=-35)                           
        LightEnvironment=MyLightEnvironment
		CollideActors=true
		BlockNonZeroExtent = false
		Materials(0)=Material'StaticMeshesCompleted.Bag_Mat'
    End Object
    Components.Add(BaseMesh)
    
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollisionRadius=+0020.000000
		CollisionHeight=+0020.000000 
		Translation=(X=0,Y=0,Z=-20)
		CollideActors=true
		BlockZeroExtent = true
	End Object
	Components.Add(CollisionCylinder)

	bHidden=false
	bCollideActors=true
	bBlockActors = true
	bBlockZeroExtent = true
	bBlockNonZeroExtent = true
}

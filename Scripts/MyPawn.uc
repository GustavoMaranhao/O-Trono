
class MyPawn extends UDKPawn
	placeable
	Implements(SaveGameStateInterface);

var float Mana, Health2;
var float ManaMax, HealthMax;

/** anim node used for feign death recovery animations */
var AnimNodeBlend FeignDeathBlend;

/** Slot node used for playing full body anims. */
var AnimNodeSlot FullBodyAnimSlot;

/** Slot node used for playing animations only on the top half. */
var AnimNodeSlot TopHalfAnimSlot;

var(LightEnvironment) DynamicLightEnvironmentComponent LightEnvironment;

var class<GameInventoryManager>		UInventory;
var repnotify GameInventoryManager			UManager;


simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("****************************"@Controller@"*******************************");
	`log("******************************");
	`log("Custom Pawn up");
	////`log("****************************"@Controller@"*******************************");
	//Mana = 100;
	//ManaMax = 100;

	//wake the physics up
    SetPhysics(PHYS_Falling);
    AddDefaultInventory();
    //Set up custom inventory manager
    if (UInventory != None)
	{
		UManager = Spawn(UInventory, Self);
		`log(UManager);
		if ( UManager == None )
		`log("Warning! Couldn't spawn InventoryManager" @ UInventory @ "for" @ Self @  GetHumanReadableName() );
	}
	//consolecommand("setres 1024x768w");
}

function SpawnOtherController(class OtherController)
{
	if ( Controller != None )
	{
		`log("SpawnDefaultController" @ Self @ ", Controller != None" @ Controller );
		return;
	}

	if ( OtherController != None )
	{
		//IsometricGamePlayerController(Controller) = Spawn(OtherController);
	}

	if ( OtherController != None )
	{
		Controller.Possess( Self, false );
	}
}

function AttackAnim()
{
	//FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
	TopHalfAnimSlot = AnimNodeSlot(mesh.FindAnimNode('TopHalfSlot'));
	TopHalfAnimSlot.PlayCustomAnim('humana_ataque01', 1.0, , , false);
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;

   return POVRot;
}

function AddDefaultInventory()
{
	//InvManager.CreateInventory(class'IsometricGame.SwordTest');
    InvManager.CreateInventory(class'IsometricGame.RocketLauncherTest'); //InvManager is the pawn's InventoryManager
}

function bool DoCustomJump( bool bUpdating )
{
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
	{
		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = 1200;
		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			Velocity.Z += Base.Velocity.Z;
		}
		SetPhysics(PHYS_Falling);
		return true;
	}
	return false;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	IsometricGamePlayerController(Controller).HUDVar.HUDMovie.DamageTaken(DamageAmount, HealthMax,false);
	//super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	Health2 -= DamageAmount;
	`log("Pawn"@Health@Health2);
	WorldInfo.Game.Broadcast(self,"Ouch, Damage Taken:"@DamageAmount);
	if (Health2 <= 0) GoToState('Dead');
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
	JSonObject.SetIntValue("IsPlayerControlled", (PlayerController(Controller) != None) ? 1 : 0);

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

	// Deserialize if this was a player controlled pawn, if it was then tell the game info about it
	if (Data.GetIntValue("IsPlayerControlled") == 1)
	{
		SaveGameStateGameInfo = IsometricGameInfo(WorldInfo.Game);
		if (SaveGameStateGameInfo != None)
		{
			SaveGameStateGameInfo.PendingPlayerPawn = Self;
		}
	}
}

state Dead
{
Begin:

FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
FullBodyAnimSlot.PlayCustomAnim('Death_Stinger', 1.0, , , false);
TriggerEventClass(class'SeqEvent_Death',self);
WorldInfo.Game.Broadcast(self,"You are dead");
IsometricGamePlayerController(Controller).DeathPlace = Location;
IsometricGamePlayerController(Controller).DeathRot = Rotation;
IsometricGamePlayerController(Controller).IgnoreMoveInput(true);
sleep(1);
Mesh.SetHidden(true);
sleep(2);
IsometricGamePlayerController(Controller).Respawn();
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=0.25
		MinTimeBetweenFullUpdates=0.2
		AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		LightShadowMode=LightShadow_ModulateBetter
		ShadowFilterQuality=SFQ_High
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		BlockNonZeroExtent=TRUE
		PhysicsAsset=PhysicsAsset'pacote_personagem.Physics.elfo3_Physics'
		AnimSets(0)=AnimSet'pacote_personagem.elfo.andando'
		AnimSets(1)=AnimSet'pacote_personagem.elfo.Run3'
        AnimSets(2)=AnimSet'pacote_personagem.elfo.walk01'
		AnimSets(3)=AnimSet'pacote_personagem.elfo.walk_elfo'
		AnimSets(4)=AnimSet'pacote_personagem.elfo.idle_elfo'
		AnimSets(5)=AnimSet'pacote_personagem.elfo.flechada_elfo'
		AnimSets(6)=AnimSet'pacote_personagem.elfo.pulo_elfo'
		AnimSets(7)=AnimSet'pacote_personagem.elfo.espada01_elfo'
		AnimSets(8)=AnimSet'pacote_personagem.elfo.espadada02_elfo'
		AnimSets(9)=AnimSet'pacote_personagem.elfo.nadar_frente_elfo'
		AnimSets(10)=AnimSet'pacote_personagem.elfo.nadar_idle_elfo'
        AnimSets(11)=AnimSet'pacote_personagem.elfa.elfa_idle'
        AnimSets(12)=AnimSet'pacote_personagem.elfa.elfa_correndo'
        AnimSets(13)=AnimSet'pacote_personagem.elfa.elfa_idle'
        AnimSets(14)=AnimSet'pacote_personagem.humana.humana_correndo'
        AnimSets(15)=AnimSet'pacote_personagem.humana.humana_idle'
        AnimSets(16)=AnimSet'pacote_personagem.humana.humana_pulo'
        AnimSets(17)=AnimSet'pacote_personagem.humana.humana_pulo2'
        AnimSets(18)=AnimSet'pacote_personagem.humana.humana_pulo3' 
        AnimSets(19)=AnimSet'pacote_personagem.humana.humana_nadando'
        AnimSets(20)=AnimSet'pacote_personagem.humana.humana_nadando_idle'
        AnimSets(21)=AnimSet'pacote_personagem.humana.humana_ataque01' 
		AnimTreeTemplate=AnimTree'pacote_personagem.humana.humana_mulher_animtree'
		SkeletalMesh=SkeletalMesh'pacote_personagem.humana.humana2'
		Translation=(X=0,Y=0,Z=-40)
		Rotation=(Yaw=-16384,Roll=0,Pitch=0)
		Scale=2.7
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	CollisionType=COLLIDE_BlockAll
	Begin Object Name=CollisionCylinder
	CollisionRadius=+0034.000000
	CollisionHeight=+0034.000000
	End Object
	CylinderComponent=CollisionCylinder



	//Mana = 100
	ManaMax = 100
	//Health2 = 100
	HealthMax = 100

	GroundSpeed = 600

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object class=AnimNodeSequence Name=MeshSequenceB
	End Object

	bCanPickUpInventory = true
	InventoryManagerClass=class'IsometricGame.GameInventoryManager'
	UInventory = GameInventoryManager

	DefaultInventory(0)=class'IsometricGame.SwordTest'
	DefaultInventory(1)=class'IsometricGame.RocketLauncherTest'
}


	//.Bindings=(Name="MiddleMouseButton",Command="MiddleMousePressed | OnRelease MiddleMouseReleased")
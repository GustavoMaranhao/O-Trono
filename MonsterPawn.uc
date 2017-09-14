
class MonsterPawn extends GamePawn
	placeable;

var(LightEnvironment) DynamicLightEnvironmentComponent LightEnvironment;

var AnimNodeSlot FullBodyAnimSlot;

var bool PawnAttacked;
var Actor DamagerPawn;
var string MonsterWeap;
var U_WorldItemPickup Drop;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	//wake the physics up
   SetPhysics(PHYS_Falling);
   SetCollisionType(COLLIDE_BlockAll);
   AddDefaultInventory();
   SpawnDefaultController();
}

function AttackAnim()
{
	FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
	FullBodyAnimSlot.PlayCustomAnim('hoverboardjumpltstart', 1.0, , , false);
}

function AddDefaultInventory()
{
	//if (!IsometricGameInfo(WorldInfo.Game).bSpawnFromKismet)
	//{
		switch(MonsterWeap)
		{
			case"Sword": InvManager.CreateInventory(class'IsometricGame.SwordTest'); break;
			case"Launcher": InvManager.CreateInventory(class'IsometricGame.RocketLauncherTest'); break;
			default: break;
		}
	//}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	WorldInfo.Game.Broadcast(self,"Damage Taken:"@DamageAmount);
	PawnAttacked = true;
	DamagerPawn = DamageCauser;
	if (Health <= 0) GoToState('Dead');
}

function SpawnMonster(SeqAction_SpawnMonster action)// The function that is called from Kismet
{
	SetPhysics(PHYS_Falling);
	`log("**********************************************************");
	`log("*********************"@self@"*******************");
	`log("*********************"@action.Monster@"*******************");
	`log("*********************"@Location@"*******************");
	`log("*********************"@Mesh.SkeletalMesh@"*******************");
	`log("**********************************************************");
	switch(action.Monster)
	{
		case "Lobo": 
			Mesh.SetSkeletalMesh(SkeletalMesh'pacote_npc.deusa.deusa_ellyansil'); 
			Mesh.SetPhysicsAsset(PhysicsAsset'pacote_personagem.Physics.elfo3_Physics');//action.Physics;
			//Mesh.SetAnimTreeTemplate(AnimTree'pacote_personagem.elfa.elfa');
			CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z/2);
			Mesh.SetTranslation(vect(0,0,-50));
			break;
		case "Robo":
			Mesh.SetSkeletalMesh(SkeletalMesh'pacote_npc.skeletal.lobo');
			Mesh.SetPhysicsAsset(PhysicsAsset'pacote_personagem.Physics.elfo3_Physics');//action.Physics;
			Mesh.SetAnimTreeTemplate(AnimTree'pacote_npc.skeletal.lobo_animtree');
			CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z/2);
			Mesh.SetTranslation(vect(0,0,-50));
			break;
		/*default: 
			Mesh.SetSkeletalMesh(SkeletalMesh'pacote_personagem.npc.soldado_npc'); 
			Mesh.SetPhysicsAsset(PhysicsAsset'pacote_personagem.Physics.elfo3_Physics');//action.Physics;
			Mesh.SetAnimTreeTemplate(AnimTree'pacote_personagem.npc.npc_animtree');
			CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z/2);
			break;*/
	}
	//CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z);
	`log("*********************"@Mesh.SkeletalMesh@"*******************");
	self.SetLocation(vect(50060, 50060, -1900));// action.Location;
	SetPhysics(PHYS_Falling);
	//Mesh.AnimSets = action.Animation;
	AirSpeed = action.Speed;
	GroundSpeed = action.Speed;
	SightRadius = action.Sight;
	HearingThreshold = action.Hear;
	PeripheralVision = action.Periph;
	MonsterWeap = "test";//action.Weapon;
	AddDefaultInventory();
	IsometricGameInfo(WorldInfo.Game).bSpawnFromKismet = false;
	//`log("*************************************"@Mesh@"******************************************");
}

State Dead
{
	function bool IsDead() { return TRUE; }
	
Begin:
	FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
	FullBodyAnimSlot.PlayCustomAnim('Death_Stinger', 1.0, , , false);
	TriggerEventClass(class'SeqEvent_Death',self);
	sleep(1);
	IsometricGameInfo(WorldInfo.Game).SpawnLoc = MonsterController(Controller).Center;
	////`log("I'm Dead!");


	SetCollisionType(COLLIDE_NoCollision);
	//InitialSkeletalMesh.Destroy();

	Drop = Spawn(class 'U_WorldItemPickup',,'Drop2',Location);
	`log(Drop.tag);
	//Drop.SetItemParameters();

	Destroy();
}

DefaultProperties
{
	InventoryManagerClass=class'IsometricGame.GameInventoryManager'
	MonsterWeap = "Sword"

	/*Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	End Object*/

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0034.000000
		CollisionHeight=+0034.000000
		BlockZeroExtent=FALSE
	End Object

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
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'pacote_npc.deusa.deusa_idle'
		AnimSets(1)=AnimSet'pacote_npc.deusa.deusa_correndo'
		AnimSets(2)=AnimSet'pacote_npc.deusa.deusa_attack1'
		//AnimSets(3)=AnimSet'pacote_personagem.elfo.idle_elfo' -> lobo idle
		AnimSets(4)=AnimSet'pacote_npc.skeletal.lobo_walk'
		AnimSets(5)=AnimSet'pacote_npc.skeletal.lobo_ataque'
		//AnimSets(6)=AnimSet'pacote_npc.soldado.idle_npc'
		//AnimSets(7)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale' -> npc correndo
		//AnimSets(8)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale' -> npc atacando
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		Scale=3.0
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	RagdollLifespan=3 //how long the dead body will hang around for

	AirSpeed=200
	GroundSpeed=200

	ControllerClass=class'MonsterController'
	bDontPossess=false

	SightRadius=1500

	HearingThreshold=1000

	PeripheralVision=-0.7

	PawnAttacked = false;

	CustomGravityScaling=1.0
}

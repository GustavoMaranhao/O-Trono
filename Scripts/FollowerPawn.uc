
class FollowerPawn extends GamePawn
	placeable;

var(LightEnvironment) DynamicLightEnvironmentComponent LightEnvironment;

var AnimNodeSlot FullBodyAnimSlot;



simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SpawnDefaultController();
	SetMovementPhysics();
}


simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
    return 'Isometric';
}

function AttackAnim()
{
	FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
	FullBodyAnimSlot.PlayCustomAnim('hoverboardjumpltstart', 1.0, , , false);
}

function ChooseAnotherMesh (int number)
{
	/*switch(number)
	{
		case 0: Mesh.SetSkeletalMesh(SkeletalMesh'pacote_personagem.elfa.elfa_porlandy'); 
				Mesh.SetPhysicsAsset(PhysicsAsset'pacote_personagem.Physics.elfo3_Physics');//action.Physics;
				Mesh.SetAnimTreeTemplate(AnimTree'pacote_personagem.elfa.elfa');
				CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z/2);
				break;
		case 1: Mesh.SetSkeletalMesh(SkeletalMesh'pacote_personagem.elfo.elfoporlandy');
				Mesh.SetPhysicsAsset(PhysicsAsset'pacote_personagem.Physics.elfo3_Physics');//action.Physics;
				Mesh.SetAnimTreeTemplate(AnimTree'pacote_personagem.elffo_animetree');
				CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z/2);
				break;
		case 2: Mesh.SetSkeletalMesh(SkeletalMesh'pacote_personagem.npc.soldado_npc'); 
				Mesh.SetPhysicsAsset(PhysicsAsset'pacote_personagem.Physics.elfo3_Physics');//action.Physics;
				Mesh.SetAnimTreeTemplate(AnimTree'pacote_personagem.npc.npc_animtree');
				CylinderComponent.SetCylinderSize(fmax(Mesh.Bounds.BoxExtent.X,Mesh.Bounds.BoxExtent.Y)/2,Mesh.Bounds.BoxExtent.Z/2);
				break;
	}
	Mesh.SetTranslation(vect(0,0,-50));*/
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator, HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if (Health <= 0) GoToState('Dead');
}

State Dead
{
	function bool IsDead() { return TRUE; }
	
Begin:
	FullBodyAnimSlot = AnimNodeSlot(mesh.FindAnimNode('FullBodySlot'));
	FullBodyAnimSlot.PlayCustomAnim('idle_elfo', 1.0, , , false);
	self.destroy();
}


defaultproperties
{
	ControllerClass=class'IsometricGame.FollowerAIController'

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
		BlockActors=false
        BlockZeroExtent=true;
		BlockNonZeroExtent=TRUE
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateSkelWhenNotRendered=FALSE
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'pacote_personagem.elfa.elfa_idle'
		AnimSets(1)=AnimSet'pacote_personagem.elfa.elfa_correndo'
		AnimSets(2)=AnimSet'pacote_personagem.elfa.elfa_ataque01'
		AnimSets(3)=AnimSet'pacote_personagem.elfo.idle_elfo'
		AnimSets(4)=AnimSet'pacote_personagem.elfo.Run2'
		AnimSets(5)=AnimSet'pacote_personagem.elfo.espada01_elfo'
		//AnimSets(6)=AnimSet'pacote_npc.soldado.idle_npc'
		//AnimSets(7)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale' -> npc correndo
		//AnimSets(8)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale' -> npc atacando
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	name='FollowerOne';

	GroundSpeed = 50;
}
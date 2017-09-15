
class SeqAction_SpawnMonster extends SequenceAction;

var() string Monster;
var() string Weapon;
var() vector Location;
var() array<AnimSet> Animation;
var() float Speed, Sight, Periph, Hear;
var() PhysicsAsset Physics;
var MonsterPawn MonsterSpawned;

event Activated()
{
	local MonsterPawn MPawn;
	IsometricGameInfo(GetWorldInfo().Game).bSpawnFromKismet = true;
	MPawn = GetWorldInfo().Spawn(class 'MonsterPawn');
	MPawn.SpawnMonster(self);
	MonsterSpawned = MPawn;
	//`log("**********************************************************");
}

DefaultProperties
{
	// Name that will apear in the Kismet Editor
	ObjName="Spawn Monster"
	ObjCategory="Spawn"
 
	// Expose the Amount property in Kismet
	VariableLinks.Empty;
	VariableLinks(0)=(ExpectedType=class'SeqVar_String', LinkDesc="MonsterMesh", bWriteable=true, PropertyName=Monster)
	VariableLinks(1)=(ExpectedType=class'SeqVar_String', LinkDesc="Weapon", bWriteable=true, PropertyName=Weapon)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector', LinkDesc="Location", bWriteable=true, PropertyName=Location)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Object', LinkDesc="Animation", bWriteable=true, PropertyName=Animation)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Float', LinkDesc="Speed", bWriteable=true, PropertyName=Speed)
	VariableLinks(5)=(ExpectedType=class'SeqVar_Float', LinkDesc="SightRange", bWriteable=true, PropertyName=Sight)
	VariableLinks(6)=(ExpectedType=class'SeqVar_Float', LinkDesc="PeripheralVisionConeAngle", bWriteable=true, PropertyName=Periph)
	VariableLinks(7)=(ExpectedType=class'SeqVar_Float', LinkDesc="HearingRange", bWriteable=true, PropertyName=Hear)
	VariableLinks(8)=(ExpectedType=class'SeqVar_Object', LinkDesc="PhysicsAsset", bWriteable=true, PropertyName=Physics)
	VariableLinks(9)=(ExpectedType=class'SeqVar_Object', LinkDesc="MonsterSpawned", bWriteable=true, PropertyName=MonsterSpawned)

	//Monster=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'

	Animation(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
	Animation(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	Weapon="Sword"
	Speed=200
	Sight=1500
	Periph=-0.7
	Hear=1000
}

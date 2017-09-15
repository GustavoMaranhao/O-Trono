class SeqAct_ChangePlayerMesh extends SequenceAction;

var() SkeletalMesh newMesh;

var MaterialInterface defaultMaterial0;
var() AnimTree newAnimTree;
var() array<AnimSet> newAnimSet;
var() PhysicsAsset newPhysicsAsset;

event Activated()
{
    local int i;
    local IsometricGamePlayerController PC;
    PC = IsometricGamePlayerController(GetWorldInfo().GetALocalPlayerController());

    PC.Pawn.Mesh.SetSkeletalMesh(newMesh);
    PC.Pawn.Mesh.SetPhysicsAsset(newPhysicsAsset);
    PC.Pawn.Mesh.AnimSets=newAnimSet;
    PC.Pawn.Mesh.SetAnimTreeTemplate(newAnimTree);

    for (i = 0; i < PC.Pawn.Mesh.SkeletalMesh.Materials.length; i++)
    {
        PC.Pawn.Mesh.SetMaterial( i, defaultMaterial0 );
    }
}

defaultproperties
{
    ObjName="ChangePlayerMesh"
    ObjCategory="Change Player Mesh"
    VariableLinks.empty;
}
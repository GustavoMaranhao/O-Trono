
class MeleeWeapon extends UDKWeapon;

simulated event SetPosition(UDKPawn Holder)
{
    local vector FinalLocation;
    local vector X,Y,Z;
	local SkeletalMeshComponent compo;
    local SkeletalMeshSocket socket;

    compo = Holder.Mesh;
    if (compo != none)
    {
	socket = compo.GetSocketByName('WeaponPoint');
	if (socket != none)
	{
	    FinalLocation = compo.GetBoneLocation(socket.BoneName);
	}
    }
    //And we probably should do something similar for the rotation :)
    SetLocation(FinalLocation); 

    Holder.GetAxes(Holder.Controller.Rotation,X,Y,Z);
	
    FinalLocation= Holder.GetPawnViewLocation(); //this is in world space.

    FinalLocation= FinalLocation- Y * 12 - Z * 32; // Rough position adjustment

    SetHidden(False);
    SetLocation(FinalLocation);
    SetBase(Holder);

    SetRotation(Holder.Controller.Rotation);
}

simulated function TimeWeaponEquipping()
{
    AttachWeaponTo( Instigator.Mesh,'WeaponPoint' );
    super.TimeWeaponEquipping();
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
    MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}

DefaultProperties
{
	FiringStatesArray(1)=WeaponFiring //We don't need to define a new state
    WeaponFireTypes(1)=EWFT_InstantHit
    FireInterval(1)=1
    Spread(1)=0
	WeaponRange(1) = 50
	InstantHitDamage(1) = 10
	bMeleeWeapon = true
	bInstantHit = true

	Begin Object class=SkeletalMeshComponent Name=MeleeMesh
	SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_3P'
	HiddenGame=FALSE 
	HiddenEditor=FALSE
    end object
    Mesh=MeleeMesh
    Components.Add(MeleeMesh)
}


class SwordTest extends UDKWeapon;

simulated event SetPosition(UDKPawn Holder)
{
	local SkeletalMeshComponent compo;
	local vector X,Y,Z;
	local SkeletalMeshSocket socket;
	local Vector FinalLocation;

	compo = Holder.Mesh;
	if (compo != none)
	{
		socket = compo.GetSocketByName('WeaponPoint');
		if (socket != none)
		{
			FinalLocation = compo.GetBoneLocation(socket.BoneName);
		}
	}
	SetLocation(FinalLocation);

	Holder.GetAxes(Holder.Controller.Rotation,X,Y,Z);
	
    FinalLocation= Holder.GetPawnViewLocation(); //this is in world space.

    FinalLocation= FinalLocation - Y*12 - Z*32; // Rough position adjustment

    SetHidden(False);
    SetLocation(FinalLocation);
    SetBase(Holder);

    SetRotation(Holder.Controller.Rotation);
}

simulated function TimeWeaponEquipping()
{
	super.TimeWeaponEquipping();
	AttachWeaponTo( Instigator.Mesh,'WeaponPoint' );
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}

DefaultProperties
{
	Begin Object class=SkeletalMeshComponent Name=GunMesh
		SkeletalMesh=SkeletalMesh'rafael_pacote_07.Weapons.Espada01'
		HiddenGame=FALSE
		HiddenEditor=FALSE
		//Scale=2.0
		Translation = (X=0,Y=0,Z=-10)
	end object
	Mesh=GunMesh
	Components.Add(GunMesh)

	FiringStatesArray(0)=WeaponFiring
    WeaponFireTypes(0)=EWFT_InstantHit
    FireInterval(0)=1
    Spread(0)=0
	WeaponRange(0) = 100
	InstantHitDamage(0) = 5
	bMeleeWeapon = true
	bInstantHit = true

	/*FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'IsometricGame.TestShot'
	WeaponRange(0) = 2000
	bMeleeWeapon = false

	FireInterval(0) = 1*/

	InventoryGroup=0
}

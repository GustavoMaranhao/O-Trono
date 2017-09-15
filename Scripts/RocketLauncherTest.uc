
class RocketLauncherTest extends UDKWeapon;

var name MuzzleFlashSocket;

var UDKPawn HolderPawn;

simulated event SetPosition(UDKPawn Holder)
{
	local SkeletalMeshComponent compo;
	local vector X,Y,Z;
	local SkeletalMeshSocket socket;
	local Vector FinalLocation;

	HolderPawn = Holder;

	compo = Holder.Mesh;
	if (compo != none)
	{
		socket = compo.GetSocketByName('Spells');

		if (socket != none)
		{
			FinalLocation = compo.GetBoneLocation(socket.BoneName);
		}
	}
	SetLocation(FinalLocation);

	Holder.GetAxes(Holder.Controller.Rotation,X,Y,Z);
	
    FinalLocation= Holder.GetPawnViewLocation(); //this is in world space.

    //FinalLocation= FinalLocation - Y*12 - Z*32; // Rough position adjustment

    //SetHidden(False);
    SetLocation(FinalLocation);
    SetBase(Holder);

    SetRotation(Holder.Controller.Rotation);
}

simulated function TimeWeaponEquipping()
{
	super.TimeWeaponEquipping();
	AttachWeaponTo( Instigator.Mesh,'Spells' );
}

simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	Local SkeletalMeshComponent AttachedMesh;
	local vector SocketLocation;

	AttachedMesh = SkeletalMeshComponent(Mesh);
	AttachedMesh.GetSocketWorldLocationAndRotation(MuzzleFlashSocket,SocketLocation);

	return SocketLocation;
}

simulated function Projectile ProjectileFire()
 {
	local vector        RealStartLoc;
	local Projectile    SpawnedProjectile;
	local rotator       RotationStart;

 // tell remote clients that we fired, to trigger effects
	IncrementFlashCount();
	`log("**************************TEST******************************");

	if( Role == ROLE_Authority )
	{
		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc();
		SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation(MuzzleFlashSocket,RealStartLoc,RotationStart);

		// Spawn projectile
		SpawnedProjectile = Spawn(GetProjectileClass(),,, RealStartLoc,RotationStart);
		if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
		{
			//SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc )) );
			SpawnedProjectile.Init( Vector(RotationStart) );
		}

		// Return it up the line
		return SpawnedProjectile;
	}

	return None;
 }

DefaultProperties
{
	Begin Object class=SkeletalMeshComponent Name=GunMesh
		SkeletalMesh=SkeletalMesh'Gustavo_Pacote1.Weapons.SK_WP_RocketLauncher_1P'
		HiddenGame=true
		HiddenEditor=true
		Scale=0.1
	end object
	Mesh=GunMesh
	Components.Add(GunMesh)

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'IsometricGame.TestShot'
	WeaponRange(0) = 2000
	bMeleeWeapon = false

	FireInterval(0) = 1

	MuzzleFlashSocket=MuzzleFlashSocketA

	InventoryGroup=1

	FiringStatesArray(1)=WeaponFiring
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(1)=class'IsometricGame.Fireball'
	//WeaponRange(1) = 2000
	//InstantHitDamage(1)=25
	FireInterval(1) = 10
	Spread(1) = 300

	/*FiringStatesArray(2)=WeaponFiring
	WeaponFireTypes(2)=EWFT_Projectile
	WeaponProjectiles(2)=class'SpaceShipGame.TestShot2'
	//WeaponRange(2) = 2000
	//InstantHitDamage(1)=25
	FireInterval(2) = 0.1
	Spread(2) = 0

	FiringStatesArray(3)=WeaponFiring
	WeaponFireTypes(3)=EWFT_Projectile
	WeaponProjectiles(3)=class'SpaceShipGame.BombShot'
	//InstantHitDamage(0)=25
	FireInterval(3) = 0.1
	Spread(3) = 0*/
}

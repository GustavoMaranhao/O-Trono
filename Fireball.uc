
class Fireball extends UTProjectile;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`log("Shot!");
	settimer(0.5,false,'Delay');
}

function Delay()
{
	self.Explode(Location, vect(0,0,0));
	WorldInfo.Game.Broadcast(self,"BOOM!");
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if ( Other != Instigator )
	{
		/*WorldInfo.MyDecalManager.SpawnDecal
		(
			DecalMaterial'Gustavo_Pacote1.Projectile.DM_Decals_SkyHole_01',
			HitLocation,                //Location
			rotator(-HitNormal),        //Facing away from the angle hit
			128, 128,                   //Width, Height
			256,                        //Thickness
			false,                      //noclip
			FRand() * 360,              //Random Rotation
			none                        //Other variables nullified
		);*/

		Other.TakeDamage( Damage, InstigatorController, Location, MomentumTransfer * Normal(Velocity), MyDamageType,, self);

		self.Explode(Location, HitNormal);
		WorldInfo.Game.Broadcast(self,"BOOM!");
	}
}

simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	/*WorldInfo.MyDecalManager.SpawnDecal
	(
		DecalMaterial'Gustavo_Pacote1.Projectile.DM_Decals_SkyHole_01',
		Location,                   //Location
		rotator(-HitNormal),        //Facing away from the angle hit
		128, 128,                   //Width, Height
		256,                        //Thickness
		false,                      //noclip
		FRand() * 360,              //Random Rotation
		none                        //Other variables nullified
	);*/

	self.Explode(Location, HitNormal);
	WorldInfo.Game.Broadcast(self,"BOOM!");
}

simulated function bool HurtRadius
(
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	optional Actor		IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool       bDoFullDamage
)
{
	local Actor	Victim;
	local bool bCausedDamage;
	local TraceHitInfo HitInfo;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;

	// Prevent HurtRadius() from being reentrant.
	if ( bHurtEntry )
		return false;

	bHurtEntry = true;
	bCausedDamage = false;
	foreach VisibleCollidingActors( class'Actor', Victim, DamageRadius, HurtOrigin,,,,, HitInfo )
	{
		if ( Victim.bWorldGeometry && (Victim != IsometricGameInfo(WorldInfo.Game).PlayerPawn) )
		{
			// check if it can become dynamic
			// @TODO note that if using StaticMeshCollectionActor (e.g. on Consoles), only one component is returned.  Would need to do additional octree radius check to find more components, if desired
			HitComponent = StaticMeshComponent(HitInfo.HitComponent);
			if ( (HitComponent != None) && HitComponent.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
				if ( NewKActor != None )
				{
					Victim = NewKActor;
				}
			}
		}
		if ( !Victim.bWorldGeometry && (Victim != self) && (Victim != IgnoredActor) && (Victim.bCanBeDamaged || Victim.bProjTarget) && (Victim != IsometricGameInfo(WorldInfo.Game).PlayerPawn) )
		{
			Victim.TakeRadiusDamage(InstigatedByController, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bDoFullDamage, self);
			bCausedDamage = bCausedDamage || Victim.bProjTarget;
		}
	}
	bHurtEntry = false;
	return bCausedDamage;
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
	CollisionRadius=8
	CollisionHeight=16
	End Object

	/*Begin Object class=FracturedStaticMeshComponent Name=BombMesh
		SkeletalMesh=SkeletalMesh'Gustavo_Pacote1.Weapons.SK_WP_RocketLauncher_1P'
		HiddenGame=true
		HiddenEditor=FALSE
		Scale=0.5
	end object
	Mesh=BombMesh
	Components.Add(BombMesh)*/

	//ProjFlightTemplate=ParticleSystem'StarShipPack.Ammo.Ship1Shot3'
	//ProjFlightTemplate=BombMesh
	ProjFlightTemplate=ParticleSystem'FirePackage.Particles.PS_Fire_Small'
	//ProjExplosionTemplate=ParticleSystem'StarShipPack.Ammo.BOOM'
	ProjExplosionTemplate=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_VehicleDeathExplosion'
	DrawScale=3.0

	Velocity = 2;

	ExplosionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Shot'
	SpawnSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileEject'
	
	Damage=250000
	MomentumTransfer=1000
	DamageRadius = 200
}

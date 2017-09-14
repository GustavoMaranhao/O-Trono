
class TestShot extends UTProjectile;;

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

		Destroy();
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

	Destroy();
}


DefaultProperties
{
	Begin Object Name=CollisionCylinder
	CollisionRadius=8
	CollisionHeight=16
	End Object

	//ProjFlightTemplate=ParticleSystem'Gustavo_Pacote1.Projectile.P_FX_Smoke_SubUV_01'
	ProjFlightTemplate=ParticleSystem'Gustavo_Pacote1.Effects.ParticleMouse2'
	//DrawScale=2.8

	ExplosionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Shot'
	SpawnSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileEject'
	
	Damage=25
	MomentumTransfer=10
}


class UBasic_Upper extends U_Items;

var() int ItemAmountInInventory;

simulated event SetPosition(UDKPawn Holder)
{
	local SkeletalMeshComponent compo;
	local vector X,Y,Z;
	local SkeletalMeshSocket socket;
	local Vector FinalLocation;

	compo = Holder.Mesh;
	if (compo != none)
	{
		socket = compo.GetSocketByName('HeadShotGoreSocket');
		if (socket != none)
		{
			FinalLocation = compo.GetBoneLocation(socket.BoneName);
		}
	}
	SetLocation(FinalLocation);

	Holder.GetAxes(Holder.Controller.Rotation,X,Y,Z);
	
    FinalLocation= Holder.GetPawnViewLocation(); //this is in world space.

    FinalLocation= FinalLocation - Z*64; // Rough position adjustment

    SetHidden(False);
    SetLocation(FinalLocation);
    SetBase(Holder);

    SetRotation(Holder.Controller.Rotation);
}

simulated function AttachArmor( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	//MeshCpnt.AttachComponentToSocket(self.Mesh,SocketName);
	//`log(Mesh);
}

DefaultProperties
{
	ItemAmountInInventory = 0;

	Begin Object class=SkeletalMeshComponent Name=ArmorMesh
		SkeletalMesh=SkeletalMesh'Gustavo_Pacote1.ArmorSkel'
		Materials(0)=Material'pacote_gustavo.Armor_Mat'
		HiddenGame=FALSE
		HiddenEditor=FALSE
		Scale=0.3
	end object
	Mesh=ArmorMesh
	Components.Add(ArmorMesh)
}

class MyGFxHUD extends GFxMoviePlayer;

/** guarda o valor do sangue do jogador */
var float LastHealthpc;

/** guarda o valor da munição do jogador */
var int LastAmmopc;

// variáveis que guardam o valor dos MovieClips e Text Fields do swf
var GFxObject HealthMC, WeaponBarMC;
var GFxObject AmmoCountTF, MoneyCountTF;

// função inicial do Hud
function Init(optional LocalPlayer player)
{
	super.Init(player);
	// carrega o swf
	Start();
	Advance(0.f);

	//define o valor das variávies para um valor diferente do que irá ser utilizado para que atualize assim que rodar o Tick
	LastHealthpc = -1337;
	LastAmmopc = -1337;

	// seta os valores dos MovieClips e Text Fields do swf
	HealthMC = GetVariableObject("_root.Health_mc.HealthBar_mc");
	//MoneyCountTF = GetVariableObject("_root.Money_mc.Money_txt");
	//WeaponBarMC = GetVariableObject("_root.Weapon_mc");
	//AmmoCountTF = GetVariableObject("_root.Balas_mc.Ammo_txt");
}

// função executada o tempo todo (varia o tempo dependendo do clock do pc)
function TickHUD() 
{
	local PlayerController PC;
	local UTPawn UTP;
	local UTWeapon Weapon;
	local int AmmoCount;

	PC = GetPC();
	UTP = UTPawn(PC.Pawn);
	Weapon = UTWeapon(UTP.Weapon);

	if (LastHealthpc != UTP.Health)
			LastHealthpc = UTP.Health;

	// se o jogador estiver vivo, ajusta a escala da barra de vida no eixo x, conforme o valor do sangue
	if (UTP != none )
			HealthMC.SetFloat("_xscale", (LastHealthpc > 100) ? 100.0f : LastHealthpc);

	// se o jogador estiver morto, zera a barra de vida (se deixar em 0, ele reconhece como o valor pradrão)
	if (UTP == none) 
		HealthMC.SetFloat("_xscale", -1.0);

	// se o jogador tiver arma, abilita o display de arma e o contador de munição, altera o display da arma para o frame correspondente ao do inventário d arma e seta o valor da munição
	if (Weapon != none)
	{
		WeaponBarMC.SetVisible(true);
		WeaponBarMC.GotoAndStopI(Weapon.InventoryGroup);
		AmmoCount = Weapon.GetAmmoCount();

		if (AmmoCount != LastAmmopc)
		{
			LastAmmopc = AmmoCount;
			AmmoCountTF.SetText(AmmoCount);
		}
	}

	// se o jogador não tiver arma, desabilitao display de arma e o contador de munição
	else if (Weapon == none)
	{
		AmmoCountTF.SetText("");
		LastAmmopc = -1337;
		WeaponBarMC.SetVisible(false);
	}
}

DefaultProperties
{
	bDisplayWithHudOff=false           // se for verdadeiro, mantem o Hud funcionando mesmo que o bShowHud seja falso
	MovieInfo=SwfMovie'Gustavo_Pacote1.Filmes.HUD_Test'     // swf do Hud
}
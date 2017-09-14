
class SQLProject_DataProvider_Items extends DB_DataProvider;

function int NumberOfEntries()
{
	`log(GetDataCount());
	return GetDataCount();
}

function SetDataType(string Type)
{
	switch(Type)
	{
		case "Consumables": mCommands[0]="SELECT * FROM Consumables;"; break;
		case "Swords": mCommands[0]="SELECT * FROM Swords;"; break;
		case "UpperArmor": mCommands[0]="SELECT * FROM UpperArmor;"; break;
		case "AtributesArmor": mCommands[0]="SELECT * FROM AtributesArmor;"; break;
		case "AtributesWeapon": mCommands[0]="SELECT * FROM AtributesWeapon;"; break;
	}
}

DefaultProperties
{
	//mCommands(0)="SELECT * FROM Consumables;"
}

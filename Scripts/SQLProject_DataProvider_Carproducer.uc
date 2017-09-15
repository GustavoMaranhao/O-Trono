/**
 * \file SQLProject_DataProvider_Carproducer .uc
 * \brief SQLProject_DataProvider_Carproducer 
 */
//=============================================================================
// Author: Sebastian Schlicht, 2010-2012 Arkanology Games
//=============================================================================
/**
 * \class SQLProject_DataProvider_Carproducer 
 * \extends DB_DataProvider
 * \brief SQLProject_DataProvider_Carproducer 
 */
class SQLProject_DataProvider_Carproducer extends DB_DataProvider;

//=============================================================================
// Functions
//=============================================================================
/**
* DataProvider convenience function for adding a new value to the database
*/
function AddCarproducer(string aName, string aCountry)
{
  local array<SBindInfo> lBindInfos;
  local SBindInfo lNewBindInfo;

  mCommands[0]="SELECT * FROM Consumables;";
  mCommands[2]="INSERT INTO Consumables (Name, Country) VALUES (@Name, @Country);";

  lNewBindInfo.BindType = 3; // String

  lNewBindInfo.BindParam = "@Name";
  lNewBindInfo.BindValue = aName;  
  lBindInfos[lBindInfos.Length] = lNewBindInfo;

  lNewBindInfo.BindParam = "@Country";
  lNewBindInfo.BindValue = aCountry;  
  lBindInfos[lBindInfos.Length] = lNewBindInfo;

  BindValues(lBindInfos);
  Insert();
}


DefaultProperties
{
  mCommands(0)="SELECT * FROM Consumables;"
  mCommands(2)="INSERT INTO Consumables (Name, Country) VALUES (@Name, @Country);"
}

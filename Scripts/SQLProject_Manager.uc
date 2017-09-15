/**
 * \file SQLProject_Manager.uc
 * \brief SQLProject_Manager
 */
//=============================================================================
// Author: Sebastian Schlicht, 2010-2012 Arkanology Games
//=============================================================================
/**
 * \class SQLProject_Manager
 * \extends DB_Manager
 * \brief SQLProject_Manager
 */
class SQLProject_Manager extends DB_Manager;

//=============================================================================
// Variables
//=============================================================================
var int mFirstDBIdx;
var int mSecondDBIdx;
var int mItemsDBIdx;

var string ItemsDBPath;

var ESQLDriver mSQLDriver;

//=============================================================================
// Functions
//=============================================================================
/**
* Initialise the databasedriver (here SQLite) and create 2 database for further testing
* - This version does NOT automatically create an empty database on initalize the driver
*/
function PostBeginPlay()
{
  super.PostBeginPlay();
	// ------------------------------------------------
	// Following example is done for SQLite
	// ------------------------------------------------
  mDLLAPI.InitDriver(mSQLDriver); // mSQLDriver=SQLDrv_SQLite

  mItemsDBIdx = mDLLAPI.CreateDatabase();
  mDLLAPI.LoadDatabase(ItemsDBPath);
	
  //TestDatabase();
}
/*
/**
* Function to test several imported DLLBind functions of UDKProjectDLL (using SQLite driver).
* - Used to create a SQL Driver, which automatically creates a in-memory database.
* - Create a table and fill it with data.
* - Save database to disc
* - Query table content and print on console
* 
* After initalising the SQLDriver it would be possible to load a presaved database from disc, its content
* would be load into the current in-memory database.
* @see bool SQL_loadDatabase(string aFilename)
*/
function TestDatabase()
{
  local int il, lDataCount;
  local array<string> lResultData;

  local SQLProject_DataProvider_Carproducer mMainDBProvider;
  local SQLProject_DataProvider_Carproducer mSecondDBProvider;

  mMainDBProvider   = SQLProject_DataProvider_Carproducer(RegisterDataProvider(mFirstDBIdx, class'SQLProject_DataProvider_Carproducer', "MainDBDataProvider"));
  mSecondDBProvider = SQLProject_DataProvider_Carproducer(RegisterDataProvider(mSecondDBIdx, class'SQLProject_DataProvider_Carproducer', "SecondDBDataProvider"));


  mDLLAPI.SelectDatabase(mSecondDBIdx);
  mSecondDBProvider.AddCarproducer("Volkswagen", "Germany");
  mSecondDBProvider.AddCarproducer("Opel", "Germany");
  mSecondDBProvider.AddCarproducer("Ford", "Germany");
  mSecondDBProvider.AddCarproducer("BMW", "Germany");
  mSecondDBProvider.AddCarproducer("Audi", "Germany");
  mDLLAPI.SaveDatabase("test2ndDB.db"); // ONLY work with mSQLDriver=SQLDrv_SQLite


  mDLLAPI.SelectDatabase(mFirstDBIdx);
  mMainDBProvider.AddCarproducer("Volkswagen", "Germany");
  mMainDBProvider.AddCarproducer("Opel", "Germany");
  mMainDBProvider.AddCarproducer("Ford", "Germany");
  mMainDBProvider.AddCarproducer("BMW", "Germany");
  mMainDBProvider.AddCarproducer("Audi", "Germany");
	mDLLAPI.SaveDatabase("testDB.db"); // ONLY work with mSQLDriver=SQLDrv_SQLite


  mDLLAPI.SelectDatabase(mSecondDBIdx);
  mSecondDBProvider.AddCarproducer("Toyota", "Japan");
	mDLLAPI.SaveDatabase("test2ndDB.db"); // ONLY work with mSQLDriver=SQLDrv_SQLite


  mMainDBProvider.Select();
  lDataCount = mMainDBProvider.GetDataCount();
  for (il=0; il<lDataCount; il++)
  {
    lResultData = mMainDBProvider.GetDataSet(il);
    `log("Carproducer: Id: "$lResultData[0]$", Name: "$lResultData[1]$", Country: "$lResultData[2]);
  }


  mSecondDBProvider.Select();
  lDataCount = mSecondDBProvider.GetDataCount();
  for (il=0; il<lDataCount; il++)
  {
    lResultData = mSecondDBProvider.GetDataSet(il);
    `log("Carproducer: Id: "$lResultData[0]$", Name: "$lResultData[1]$", Country: "$lResultData[2]);
  }
  `log("********************************************************************************************");
  `log("********************************************************************************************");
  `log("********************************************************************************************");
}*/

function SQL_GetItem(int Ammount, out string SQLName, out string SQLType, out int SQLProperty, out string SQLLink, out string SQLDescription, out string SQLClass,out int SQLIndx, out int SQLRange)
{
  local int il, lDataCount,RowNbr;
  local array<string> lResultData;

  local SQLProject_DataProvider_Items mItemsDBProvider;

  mItemsDBProvider  = SQLProject_DataProvider_Items(IsometricGameInfo(WorldInfo.Game).DBManager.RegisterDataProvider(mItemsDBIdx, class'SQLProject_DataProvider_Items', "ItemsDBDataProvider"));
  mItemsDBProvider.SetDataType("Consumables");
	
  `log("Is working");

	//test = mDLLAPI.SelectDatabase(mFirstDBIdx);
	//`log(test);

	mDLLAPI.IO_fileExists(ItemsDBPath);
	`log(ItemsDBPath);

	mItemsDBProvider.Select();
	mDLLAPI.LoadDatabase(ItemsDBPath);
	RowNbr = mItemsDBProvider.NumberOfEntries();
	`log("RowNumber:"@RowNbr);
	  for (il=0; il<Ammount; il++)
	  {
		//if (il>mItemsDBProvider.ColumnCount(0)) break;
		lDataCount = Rand(RowNbr);
		lResultData = mItemsDBProvider.GetDataSet(lDataCount);
		SQLIndx = int(lResultData[0]);
		SQLName = lResultData[1];
		SQLProperty = int(lResultData[2]);
		SQLType = lResultData[3];
		SQLDescription = lResultData[4];
		SQLLink = lResultData[5];
		SQLClass = lResultData[6];
		SQLRange = int(lResultData[7]);
		`log("Item Name: "$SQLName@SQLProperty@SQLType@SQLLink@SQLClass);
	  }
}


DefaultProperties
{
  mSQLDriver=SQLDrv_SQLite
  Name="Default__SQLProject_Manager"

	//C:\UDK\UDK-2012-05\Binaries\Win32\UserCode
  //ItemsDBPath = "C:/UDK/UDK-2012-05/Binaries/Win32/UserCode/Items.s3db"
  ItemsDBPath = "C:/Users/Gustavo/Desktop/UDK-2012-05/Binaries/Win32/UserCode/Items.s3db"
  //ItemsDBPath = "C:/UDK/UDK-2011-03/Binaries/Win32/UserCode/Items.s3db"
}

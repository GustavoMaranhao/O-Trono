//=============================================================================
// Author: Sebastian Schlicht, 2010-2012 Arkanology Games
//=============================================================================
/**
 * Database - Database manager.
 * Used to initialize and set up all game databases.
 * Used to save and load savegame databases.
 */
class DB_Manager extends Actor
	dependson(DB_DLLAPI)
	config(Database)
  abstract;

//=============================================================================
// Variables
//=============================================================================
var array<DB_DataProvider> mDataProviders;
var protected DB_DLLAPI mDLLAPI;

var config ESQLDriver mDefaultDatabaseDriver;


//=============================================================================
// Functions
//=============================================================================

/**
 * Get the created DLLAPI object to gain access of all the API functions.
 * 
 * \return Allocated DLLAPI object
 */
final function DB_DLLAPI getDLLAPI()
{
	return mDLLAPI;
}

/**
 * Initialise the databasedriver and creat/load the default databases
 */
function PostBeginPlay()
{
  super.PostBeginPlay();

  // SQLite: automatically create one empty DB
  // mDLLAPI.InitDriver(mDefaultDatabaseDriver);

  // mDLLAPI.Connect("<IP>;<User>;<Pass>;<Database>;<Port>;"); // MySQL: Connect to remote database

  mDataProviders.Length = 0;
}

function DB_DataProvider RegisterDataProvider(int aDbIdx, class<DB_DataProvider> aDataProviderClass, string aDataProviderName)
{
  local DB_DataProvider newProvider;

  newProvider = Spawn(aDataProviderClass);
  
  if (newProvider == none)
    return none;

  newProvider.mName = aDataProviderName;
  newProvider.mDBId = aDbIdx;
  newProvider.mDLLAPI = getDLLAPI();

  newProvider.InitCommands();

  mDataProviders[mDataProviders.Length] = newProvider;

  return newProvider;
}

function ReleaseDataProvider(DB_DataProvider aDataProvider)
{
  mDataProviders.RemoveItem(aDataProvider);
}

function DB_DataProvider GetDataProvider(string aDataProviderName)
{
  local int il;
  
  for(il=0; il<mDataProviders.Length; il++)
  {
    if (mDataProviders[il].mName == aDataProviderName)
      return mDataProviders[il];
  }
  return none;
}


DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Begin Object Class=DB_DLLAPI Name=DllApiInstance
	End Object
	mDLLAPI=DllApiInstance

	Name="Default__DB_Manager"
}

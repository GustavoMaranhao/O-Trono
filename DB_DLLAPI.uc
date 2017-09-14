class DB_DLLAPI extends Object
	DLLBind(UDKProjectDLL);

enum ESQLDriver
{
	SQLDrv_None,
	SQLDrv_SQLite,
	SQLDrv_MySQL,
};

var private int mDriverIdent;

/**
 * SQL FUNCTIONS - PLEASE DO NOT USE (see wrappers below)
 */
dllimport final function int SQL_initSQLDriver(int aSQLDriver);
dllimport final function bool SQL_selectSQLDriver(int aSQLDriverIdent);

/**
 * SQLite: aDatabaseConnector: Filename (loaded into memory)
 * MySQL: Ip;User;Pass;Database;Port; (Connection stored in memory)
          Example: 127.0.0.1;root;12345;test;3306;
*/
dllimport final function int SQL_connectDatabase(string aFilename);
dllimport final function int SQL_currentDatabase();
dllimport final function bool SQL_selectDatabase(int aDbIdx);

dllimport final function int SQL_createDatabase();
dllimport final function SQL_closeDatabase(int aDbIdx);
dllimport final function bool SQL_loadDatabase(string aFilename);
dllimport final function bool SQL_saveDatabase(string aFilename);

dllimport final function int SQL_getTableCount();
dllimport final function SQL_getTableName(int aTableIdx, string aValue);

dllimport final function bool SQL_bindValueInt(int aParamIndex, int aValue);
dllimport final function bool SQL_bindNamedValueInt(string aParamName, int aValue);
dllimport final function bool SQL_bindValueFloat(int aParamIndex, float aValue);
dllimport final function bool SQL_bindNamedValueFloat(string aParamName, float aValue);
dllimport final function bool SQL_bindValueString(int aParamIndex, string aValue);
dllimport final function bool SQL_bindNamedValueString(string aParamName, string aValue);

dllimport final function SQL_getIntVal(int aResultIdx, string aParamName, out int aValue);
dllimport final function SQL_getFloatVal(int aResultIdx, string aParamName, out float aValue);
dllimport final function SQL_getStringVal(int aResultIdx, string aParamName, out string aValue);

dllimport final function SQL_prepareStatement(string aStatement);
dllimport final function int SQL_queryDatabase(string aStatement);
dllimport final function int SQL_executeStatement();
dllimport final function int SQL_lastInsertID();
dllimport final function bool SQL_nextResult(int aResultIdx);

dllimport final function int SQL_getColumnCount(int aResultIdx);
dllimport final function SQL_getColumnInfo(int aResultIdx, int aColumnIdx, out string aColumnName, out int aColumnType, out int aColumnDetail);


/**
 * IO FUNCTIONS
 */
dllimport final function bool IO_directoryExists(string aDirectoryPath);
dllimport final function bool IO_createDirectory(string aDirectoryPath);
dllimport final function bool IO_deleteDirectory(string aDirectoryPath, int aRecursive);
dllimport final function bool IO_fileExists(string aFilePath);
dllimport final function bool IO_deleteFile(string aFilePath);

dllimport final function bool IO_encryptFile(string aFilePath, string aKey);
dllimport final function bool IO_decryptFile(string aFilePath, string aKey);
dllimport final function bool IO_encryptString(string aInStr, string aKey, string aOutStr);
dllimport final function bool IO_decryptString(string aInPath, string aKey, string aOutString);
dllimport final function bool IO_MD5(string aInString, out string aOutString);

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

/**
 * Function-Wrappers to be called by the scripts
 */

final function InitDriver(int aSQLDriver)
{
  mDriverIdent = SQL_initSQLDriver(aSQLDriver);
}

final function int Connect(string aFilename)
{
//  if (SQL_selectSQLDriver(mDriverIdent))
  return SQL_connectDatabase(aFilename);
}

final function int Current()
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_currentDatabase();
  return -1;
}

final function bool SelectDatabase(int aDbIdx)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_selectDatabase(aDbIdx);
  return false;
}

final function int CreateDatabase()
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_createDatabase();
  return -1;
}

final function CloseDatabase(int aDbIdx)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_closeDatabase(aDbIdx);
}

final function bool LoadDatabase(string aFilename)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_loadDatabase(aFilename);
  return false;
}

final function bool SaveDatabase(string aFilename)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_saveDatabase(aFilename);
  return false;
}

final function int GetTableCount()
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_getTableCount();
  return -1;
}

final function GetTableName(int aTableIdx, string aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_getTableName(aTableIdx, aValue);
}

final function bool BindValueInt(int aParamIndex, int aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_bindValueInt(aParamIndex, aValue);
  return false;
}

final function bool BindNamedValueInt(string aParamName, int aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_bindNamedValueInt(aParamName, aValue);
  return false;
}

final function bool BindValueFloat(int aParamIndex, float aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_bindValueFloat(aParamIndex, aValue);
  return false;
}

final function bool BindNamedValueFloat(string aParamName, float aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_bindNamedValueFloat(aParamName, aValue);
  return false;
}

final function bool BindValueString(int aParamIndex, string aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_bindValueString(aParamIndex, aValue);
  return false;
}

final function bool BindNamedValueString(string aParamName, string aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_bindNamedValueString(aParamName, aValue);
  return false;
}

final function GetIntVal(int aResultIdx, string aParamName, out int aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_getIntVal(aResultIdx, aParamName, aValue);
}

final function GetFloatVal(int aResultIdx, string aParamName, out float aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_getFloatVal(aResultIdx, aParamName, aValue);
}

final function GetStringVal(int aResultIdx, string aParamName, out string aValue)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_getStringVal(aResultIdx, aParamName, aValue);
}

final function PrepareStatement(string aStatement)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_prepareStatement(aStatement);
}

final function int QueryDatabase(string aStatement)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_queryDatabase(aStatement);
  return -1;
}

final function int ExecuteStatement()
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_executeStatement();
  return -1;
}

final function int LastInsertID()
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_lastInsertID();  
  return -1;
}

final function bool NextResult(int aResultIdx)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_nextResult(aResultIdx);
  return false;
}

final function int GetColumnCount(int aResultIdx)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    return SQL_getColumnCount(aResultIdx);
  return -1;
}

final function GetColumnInfo(int aResultIdx, int aColumnIdx, out string aColumnName, out int aColumnType, out int aColumnDetail)
{
  if (SQL_selectSQLDriver(mDriverIdent))
    SQL_getColumnInfo(aResultIdx, aColumnIdx, aColumnName, aColumnType, aColumnDetail);
}

/*final function string MD5Hash(string aInString)
{
  local string lMD5Hash;

  `DB_InitString(lMD5Hash,32);
  IO_MD5(aInString, lMD5Hash);
  return lMD5Hash;
}*/

DefaultProperties
{
	Name="Default__DB_DLLAPI"
}

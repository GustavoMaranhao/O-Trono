//=============================================================================
// Author: Sebastian Schlicht, 2010-2012 Arkanology Games
//=============================================================================
/**
 * Database - Data provider class.
 * Base class for all data providers gathering data from loaded databases.
 */
class DB_DataProvider extends Actor
	dependson(DB_DLLAPI);

//=============================================================================
// Structs & Enumerations
//=============================================================================
struct SBindInfo
{
  var int    BindType;
  
  var string BindParam;
  var int    BindIdx;

  var string BindValue;

  structdefaultproperties
  {
    BindType = -1
    BindParam = ""
    Bindidx = -1
    BindValue = ""
  }
};

struct SDataItem
{
  var array<string> Data;
};

struct SDataSet
{
  var array<string> ColumnNames;
  var array<int>    ColumnTypes;
  var array<int>    ColumnDetails;

  var int              DataCount;
  var array<SDataItem> Data;
};

enum ECommandType
{
  ECT_SELECT,
  ECT_UPDATE,
  ECT_INSERT,
  ECT_DELETE,

  ECT_COMMAND_COUNT
};

//=============================================================================
// Variables
//=============================================================================
var DB_DLLAPI mDLLAPI;  // backreference to DB_Manager.mDLLAPI
var string    mName;

var int mDBId;          // referenced database ID
var string mStatement;  // data provider statement
var string mCommands[4];

var protected SDataSet mDataSet;  // current dataset of this provider
var private array<SBindInfo> mBindingInfo;


//=============================================================================
// Functions
//=============================================================================
function InitCommands()
{
  local int il;

  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  for(il=0; il<ECT_COMMAND_COUNT; il++)
  {
    if(Len(mCommands[il]) > 0)
      mDLLAPI.PrepareStatement(mCommands[il]);  
  }
}

function SetCommand(ECommandType aType, string aCommand)
{
  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  mCommands[aType] = aCommand;
  mDLLAPI.PrepareStatement(aCommand);
}


//=============================================================================
// Database handling
//=============================================================================
function fill(int aResultIdx, out SDataSet aDataSet)
{
  local int il, lColumnCount;

  local string lColumnName;
  local int lColumnType;
  local int lColumnDetail;

  local SDataItem lNewDataItem;
  local int lNewIntVal, lNewDataCount;
  local float lNewFloatVal;
  local string lNewStrVal;

  aDataSet.ColumnNames.Length = 0;
  aDataSet.ColumnTypes.Length = 0;
  aDataSet.ColumnDetails.Length = 0;
  aDataSet.DataCount = 0;
  aDataSet.Data.Length = 0;

  if(aResultIdx >= 0)
  {
    lNewDataCount = 0;
    while(mDLLAPI.NextResult(aResultIdx))
    {
      if (lNewDataCount == 0)
      {
        lColumnCount = mDLLAPI.GetColumnCount(aResultIdx);
        for(il=0; il<lColumnCount; ++il)
        {
          `DB_InitString(lColumnName,255);

          mDLLAPI.GetColumnInfo(aResultIdx, il, lColumnName, lColumnType, lColumnDetail);
          aDataSet.ColumnNames[il] = lColumnName;
          aDataSet.ColumnTypes[il] = lColumnType;
          aDataSet.ColumnDetails[il] = lColumnDetail;
        }
      }

      lNewDataCount++;
      lNewDataItem.Data.Length = 0;
      for(il=0; il<lColumnCount; ++il)
      {
        switch(aDataSet.ColumnTypes[il])
        {
          case 0:
            lNewDataItem.Data[il] = "";
            break;
          case 1:
            mDLLAPI.GetIntVal(aResultIdx, aDataSet.ColumnNames[il], lNewIntVal);
            lNewDataItem.Data[il] = string(lNewIntVal);
            break;
          case 2:
            mDLLAPI.GetFloatVal(aResultIdx, aDataSet.ColumnNames[il], lNewFloatVal);
            lNewDataItem.Data[il] = string(lNewFloatVal);
            break;
          case 3:
            `DB_InitString(lNewStrVal, aDataSet.ColumnDetails[il]);
            mDLLAPI.GetStringVal(aResultIdx, aDataSet.ColumnNames[il], lNewStrVal);
            lNewDataItem.Data[il] = lNewStrVal;
            break;
        }
      }
      aDataSet.Data[aDataSet.Data.Length] = lNewDataItem;
    }
    aDataSet.DataCount = lNewDataCount;
  }
}

//=============================================================================
// DataProvider control functions
//=============================================================================
function Select()
{
  local int lResIdx;

  if (mCommands[ECT_SELECT] == "")
    return;
  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  mDLLAPI.PrepareStatement(mCommands[ECT_SELECT]);
  PerformBind();
  lResIdx = mDLLAPI.ExecuteStatement();
  fill(lResIdx, mDataSet);
}

function Update()
{
  if (mCommands[ECT_UPDATE] == "")
    return;
  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  mDLLAPI.PrepareStatement(mCommands[ECT_UPDATE]);
  PerformBind();
  mDLLAPI.ExecuteStatement();
  Select();
}

function Insert()
{
  if (mCommands[ECT_INSERT] == "")
    return;
  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  mDLLAPI.PrepareStatement(mCommands[ECT_INSERT]);
  PerformBind();
  mDLLAPI.ExecuteStatement();
  Select();
}

function Delete()
{
  if (mCommands[ECT_DELETE] == "")
    return;
  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  mDLLAPI.PrepareStatement(mCommands[ECT_DELETE]);
  PerformBind();
  mDLLAPI.ExecuteStatement();
  Select();
}

function BindValues(array<SBindInfo> aBindingInfo)
{
  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  mBindingInfo = aBindingInfo;
}

function PerformBind()
{  
  local int il, lBindInfoCount;

  if (!mDLLAPI.SelectDatabase(mDBId))
    return;

  lBindInfoCount = mBindingInfo.Length;

  for(il=0; il<lBindInfoCount; il++)
  {
    switch(mBindingInfo[il].BindType)
    {
      case 0:
        break;
      case 1:
        if (mBindingInfo[il].BindParam != "" && mBindingInfo[il].BindIdx == -1)
          mDLLAPI.BindNamedValueInt(mBindingInfo[il].BindParam, int(mBindingInfo[il].BindValue));
        else if (mBindingInfo[il].BindIdx >= 0)
          mDLLAPI.BindValueInt(mBindingInfo[il].BindIdx, int(mBindingInfo[il].BindValue));
        break;
      case 2:
        if (mBindingInfo[il].BindParam != "" && mBindingInfo[il].BindIdx == -1)
          mDLLAPI.BindNamedValueFloat(mBindingInfo[il].BindParam, float(mBindingInfo[il].BindValue));
        else if (mBindingInfo[il].BindIdx >= 0)
          mDLLAPI.BindValueFloat(mBindingInfo[il].BindIdx, float(mBindingInfo[il].BindValue));
        break;
      case 3:
        if (mBindingInfo[il].BindParam != "" && mBindingInfo[il].BindIdx == -1)
          mDLLAPI.BindNamedValueString(mBindingInfo[il].BindParam, mBindingInfo[il].BindValue);
        else if (mBindingInfo[il].BindIdx >= 0)
          mDLLAPI.BindValueString(mBindingInfo[il].BindIdx, mBindingInfo[il].BindValue);
        break;
    }
  }
  mBindingInfo.Length = 0;
}

function int GetDataCount()
{
  return mDataSet.DataCount;
}

function array<string> GetDataSet(int aDataIdx)
{
  local int il;
  local array<string> lResult;

  lResult.Length=0;

  for (il=0; il<mDataSet.Data[aDataIdx].Data.Length; il++)
  {
    lResult[lResult.Length] = mDataSet.Data[aDataIdx].Data[il];
  }
  return lResult;
}

function int LastInsertID()
{
  return mDLLAPI.LastInsertID();
}

DefaultProperties
{
  TickGroup=TG_DuringAsyncWork

	bHidden=TRUE
	Physics=PHYS_None
	bReplicateMovement=FALSE
	bStatic=FALSE
	bNoDelete=FALSE

	Name="Default__DB_DataProvider"
}

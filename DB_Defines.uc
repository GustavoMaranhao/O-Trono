/**
 * UDK Database global defines.
 * Provide static functions for the UDK project.
 */
class DB_Defines extends Object;

/**
* Static method to create an empty string object with given length.
* Used in conjunction with DLLBind functions, because memory has to be allocated before assign any data.
* 
* @param aStrLen [int]
* 
* @return string
*/
static function string initString(int aStrLen)
{
	local int il;
	local string aResult;
	for(il=0; il<=aStrLen; ++il){
		aResult $= " ";
	}
	return aResult;
}

/**
 * String a vector from an input string like: X.X,Y.Y,Z.Z
 * 
 * @param[in] aStr [string]
 * 
 * @return Vector
 */
static function Vector string2Vec(string aStr)
{
	local Vector lVector;
  local array<string> lStringSplitted;

	lStringSplitted = SplitString(aStr);
  if(lStringSplitted.Length == 3){
    lVector.X = float(lStringSplitted[0]);
    lVector.Y = float(lStringSplitted[1]);
    lVector.Z = float(lStringSplitted[2]);
  }

	return lVector;
}

/**
 * String a rotator from an input string like: X.X,Y.Y,Z.Z
 * 
 * @param[in] aStr [string]
 * 
 * @return Rotator
 */
static function Rotator string2Rot(string aStr)
{
	local Rotator lRotator;
  local array<string> lStringSplitted;

	lStringSplitted = SplitString(aStr);
  if(lStringSplitted.Length == 3){
    lRotator.Pitch = float(lStringSplitted[0]);
    lRotator.Yaw = float(lStringSplitted[1]);
    lRotator.Roll = float(lStringSplitted[2]);
  }

	return lRotator;
}


DefaultProperties
{
	Name="Default__DB_Defines"
}


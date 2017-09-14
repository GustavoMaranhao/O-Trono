//=============================================================================
// SaveGameState: Object which handles loading and saving of the game state
//
// This object can be instanced to then perform saving of the world. It can 
// also be instanced, loaded using BasicLoadObject and then loading the game
// state can occur.
// 
// Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class SaveGameState extends Object;

// SaveGameState revision number
const SAVEGAMESTATE_REVISION = 1;
// File name of the map that this save game state is associated with
var string PersistentMapFileName;
// Game info that this save game state is associated with
var string GameInfoClassName;
// File names of the streaming maps that this save game state is associated with
var array<string> StreamingMapFileNames;
// Serialized world data
var array<String> SerializedWorldData;

/**
 * Saves the game state by serializing all of the actors that implement the SaveGameStateInterface, Kismet and Matinee.
 */
function SaveGameState()
{
	local WorldInfo WorldInfo;
	local Actor Actor;
	local String SerializedActorData;
	local SaveGameStateInterface SaveGameStateInterface;
	local int i;

	// Get the world info, abort if the world info could not be found
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if (WorldInfo == None)
	{
		return;
	}

	// Save the persistent map file name
	PersistentMapFileName = String(WorldInfo.GetPackageName());

	// Save the currently streamed in map file names
	if (WorldInfo.StreamingLevels.Length > 0)
	{
		// Iterate through the streaming levels
		for (i = 0; i < WorldInfo.StreamingLevels.Length; ++i)
		{
			// Levels that are visible and has a load request pending should be included in the streaming levels list
			if (WorldInfo.StreamingLevels[i] != None && (WorldInfo.StreamingLevels[i].bIsVisible || WorldInfo.StreamingLevels[i].bHasLoadRequestPending))
			{				
				StreamingMapFileNames.AddItem(String(WorldInfo.StreamingLevels[i].PackageName));
			}
		}
	}

	// Save the game info class 
	GameInfoClassName = PathName(WorldInfo.Game.Class);

	// Iterate through all of the actors that implement SaveGameStateInterface and ask them to serialize themselves
	ForEach WorldInfo.DynamicActors(class'Actor', Actor, class'SaveGameStateInterface')
	{
		// Type cast to the SaveGameStateInterface
		SaveGameStateInterface = SaveGameStateInterface(Actor);
		if (SaveGameStateInterface != None)
		{
			// Serialize the actor
			SerializedActorData = SaveGameStateInterface.Serialize();
			// If the serialzed actor data is valid, then add it to the serialized world data array
			if (SerializedActorData != "")
			{
				SerializedWorldData.AddItem(SerializedActorData);
			}
		}
	}

	// Serialize Kismet
	SaveKismetState();

	// Serialize Matinee
	SaveMatineeState();
}

/**
 * Saves the Kismet game state
 */
protected function SaveKismetState()
{
	local WorldInfo WorldInfo;
	local array<Sequence> RootSequences;
	local array<SequenceObject> SequenceObjects;
	local SequenceEvent SequenceEvent;
	local SeqVar_Bool SeqVar_Bool;
 	local SeqVar_Float SeqVar_Float;
 	local SeqVar_Int SeqVar_Int;
 	local SeqVar_Object	SeqVar_Object;
 	local SeqVar_String	SeqVar_String;
 	local SeqVar_Vector	SeqVar_Vector;
	local int i, j;
	local JSonObject JSonObject;

	// Get the world info, abort if it does not exist
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if (WorldInfo == None)
	{
		return;
	}

	// Get all of the root sequences within the world, abort if there are no root sequences
	RootSequences = WorldInfo.GetAllRootSequences();
	if (RootSequences.Length <= 0)
	{
		return;
	}
	
	// Serialize all SequenceEvents and SequenceVariables
	for (i = 0; i < RootSequences.Length; ++i)
	{
		if (RootSequences[i] != None)
		{
			// Serialize Kismet Events
			RootSequences[i].FindSeqObjectsByClass(class'SequenceEvent', true, SequenceObjects);
			if (SequenceObjects.Length > 0)
			{
				for (j = 0; j < SequenceObjects.Length; ++j)
				{
					SequenceEvent = SequenceEvent(SequenceObjects[j]);
					if (SequenceEvent != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SequenceEvent so it can found later
							JSonObject.SetStringValue("Name", PathName(SequenceEvent));
							// Calculate the activation time of what it should be when the saved game state is loaded. This is done as the retrigger delay minus the difference between the current world time
							// and the last activation time. If the result is negative, then it means this was never triggered before, so always make sure it is larger or equal to zero.
							JsonObject.SetFloatValue("ActivationTime", FMax(SequenceEvent.ReTriggerDelay - (WorldInfo.TimeSeconds - SequenceEvent.ActivationTime), 0.f));
							// Save the current trigger count
							JSonObject.SetIntValue("TriggerCount", SequenceEvent.TriggerCount);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}
					}
				}
			}

			// Serialize Kismet Variables
			RootSequences[i].FindSeqObjectsByClass(class'SequenceVariable', true, SequenceObjects);
			if (SequenceObjects.Length > 0)
			{
				for (j = 0; j < SequenceObjects.Length; ++j)
				{
					// Attempt to serialize as a boolean variable
					SeqVar_Bool = SeqVar_Bool(SequenceObjects[j]);
					if (SeqVar_Bool != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqVar_Bool so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqVar_Bool));
							// Save the boolean value
							JSonObject.SetIntValue("Value", SeqVar_Bool.bValue);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}

						// Continue to the next one within the array as we're done with this array index
						continue;
					}

					// Attempt to serialize as a float variable
					SeqVar_Float = SeqVar_Float(SequenceObjects[j]);
					if (SeqVar_Float != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqVar_Float so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqVar_Float));
							// Save the float value
							JSonObject.SetFloatValue("Value", SeqVar_Float.FloatValue);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}

						// Continue to the next one within the array as we're done with this array index
						continue;
					}

					// Attempt to serialize as an int variable
					SeqVar_Int = SeqVar_Int(SequenceObjects[j]);
					if (SeqVar_Int != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqVar_Int so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqVar_Int));
							// Save the int value
							JSonObject.SetIntValue("Value", SeqVar_Int.IntValue);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}

						// Continue to the next one within the array as we're done with this array index
						continue;
					}

					// Attempt to serialize as an object variable
					SeqVar_Object = SeqVar_Object(SequenceObjects[j]);
					if (SeqVar_Object != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqVar_Object so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqVar_Object));
							// Save the object value
							JSonObject.SetStringValue("Value", PathName(SeqVar_Object.GetObjectValue()));
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}

						// Continue to the next one within the array as we're done with this array index
						continue;
					}
	
					// Attempt to serialize as a string variable
					SeqVar_String = SeqVar_String(SequenceObjects[j]);
					if (SeqVar_String != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqVar_String so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqVar_String));
							// Save the string value
							JSonObject.SetStringValue("Value", SeqVar_String.StrValue);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}

						// Continue to the next one within the array as we're done with this array index
						continue;
					}

					// Attempt to serialize as a vector variable
					SeqVar_Vector = SeqVar_Vector(SequenceObjects[j]);
					if (SeqVar_Vector != None)
					{
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqVar_Vector so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqVar_Vector));
							// Save the vector value
							JSonObject.SetFloatValue("Value_X", SeqVar_Vector.VectValue.X);
							JSonObject.SetFloatValue("Value_Y", SeqVar_Vector.VectValue.Y);
							JSonObject.SetFloatValue("Value_Z", SeqVar_Vector.VectValue.Z);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}

						// Continue to the next one within the array as we're done with this array index
						continue;
					}
				}
			}
		}
	}
}

/**
 * Saves the Matinee game state
 */
protected function SaveMatineeState()
{
	local WorldInfo WorldInfo;
	local array<Sequence> RootSequences;
	local array<SequenceObject> SequenceObjects;
	local SeqAct_Interp SeqAct_Interp;
	local int i, j;
	local JSonObject JSonObject;

	// Get the world info, abort if it does not exist
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if (WorldInfo == None)
	{
		return;
	}

	// Get all of the root sequences within the world, abort if there are no root sequences
	RootSequences = WorldInfo.GetAllRootSequences();
	if (RootSequences.Length <= 0)
	{
		return;
	}
	
	// Serialize all SequenceEvents and SequenceVariables
	for (i = 0; i < RootSequences.Length; ++i)
	{
		if (RootSequences[i] != None)
		{
			// Serialize Matinee Kismet Sequence Actions
			RootSequences[i].FindSeqObjectsByClass(class'SeqAct_Interp', true, SequenceObjects);
			if (SequenceObjects.Length > 0)
			{
				for (j = 0; j < SequenceObjects.Length; ++j)
				{
					SeqAct_Interp = SeqAct_Interp(SequenceObjects[j]);
					if (SeqAct_Interp != None)
					{
						// Attempt to serialize the data
						JSonObject = new () class'JSonObject';
						if (JSonObject != None)
						{
							// Save the path name of the SeqAct_Interp so it can found later
							JSonObject.SetStringValue("Name", PathName(SeqAct_Interp));
							// Save the current position of the SeqAct_Interp
							JSonObject.SetFloatValue("Position", SeqAct_Interp.Position);
							// Save if the SeqAct_Interp is playing or not
							JSonObject.SetIntValue("IsPlaying", (SeqAct_Interp.bIsPlaying) ? 1 : 0);
							// Save if the SeqAct_Interp is paused or not
							JSonObject.SetIntValue("Paused", (SeqAct_Interp.bPaused) ? 1 : 0);
							// Encode this and append it to the save game data array
							SerializedWorldData.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
						}
					}
				}
			}
		}
	}
}

/**
 * Loads the game state by deserializing all of the serialized data and applying the data to the actors that implement the SaveGameStateInterface, Kisment and Matinee.
 */
function LoadGameState()
{
	local WorldInfo WorldInfo;
	local int i;
	local JSonObject JSonObject;
	local String ObjectName;
	local SaveGameStateInterface SaveGameStateInterface;
	local Actor Actor, ActorArchetype;
	
	// No serialized world data to load!
	if (SerializedWorldData.Length <= 0)
	{
		return;
	}

	// Grab the world info, abort if no valid world info
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if (WorldInfo == None)
	{
		return;
	}

	// For each serialized data object
	for (i = 0; i < SerializedWorldData.Length; ++i)
	{
		if (SerializedWorldData[i] != "")
		{
			// Decode the JSonObject from the encoded string
			JSonObject = class'JSonObject'.static.DecodeJson(SerializedWorldData[i]);
			if (JSonObject != None)
			{
				// Get the object name
				ObjectName = JSonObject.GetStringValue("Name");
				// Check if the object name contains SeqAct_Interp, if so deserialize Matinee
				if (InStr(ObjectName, "SeqAct_Interp",, true) != INDEX_NONE)
				{
					LoadMatineeState(ObjectName, JSonObject);
				}
				// Check if the object name contains SeqEvent or SeqVar, if so deserialize Kismet
				else if (InStr(ObjectName, "SeqEvent",, true) != INDEX_NONE || InStr(ObjectName, "SeqVar",, true) != INDEX_NONE)
				{
					LoadKismetState(ObjectName, JSonObject);
				}
				// Otherwise it is some other type of actor
				else
				{
					// Try to find the persistent level actor
					Actor = Actor(FindObject(ObjectName, class'Actor'));

					// If the actor was not in the persistent level, then it must have been transient then attempt to spawn it
					if (Actor == None)
					{
						// Spawn the actor
						ActorArchetype = GetActorArchetypeFromName(JSonObject.GetStringValue("ObjectArchetype"));
						if (ActorArchetype != None)
						{
							Actor = WorldInfo.Spawn(ActorArchetype.Class,,,,, ActorArchetype, true);
						}
					}

					if (Actor != None)
					{
						// Cast to the save game state interface
						SaveGameStateInterface = SaveGameStateInterface(Actor);
						if (SaveGameStateInterface != None)
						{
							// Deserialize the actor
							SaveGameStateInterface.Deserialize(JSonObject);
						}
					}
				}
			}
		}
	}
}

/**
 * Returns an actor archetype from the name
 *
 * @return		Returns an actor archetype from the string representation
 */
function Actor GetActorArchetypeFromName(string ObjectArchetypeName)
{
	local WorldInfo WorldInfo;
	
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if (WorldInfo == None)
	{
		return None;
	}

	// Use static look ups if on the console, for static look ups to work
	//  * Force cook the classes or packaged archetypes to the maps
	//  * Add packaged archetypes to the StartupPackage list
	//  * Reference the packages archetypes somewhere within Unrealscript
	if (WorldInfo.IsConsoleBuild())
	{
		return Actor(FindObject(ObjectArchetypeName, class'Actor'));
	}
	else // Use dynamic look ups if on the PC
	{
		return Actor(DynamicLoadObject(ObjectArchetypeName, class'Actor'));
	}
}

/**
 * Loads the Kismet Sequence state based on the data provided
 *
 * @param		ObjectName		Name of the Kismet object in the level
 * @param		Data			Data as JSon for the Kismet object
 */
function LoadKismetState(string ObjectName, JSonObject Data)
{
	local SequenceEvent SequenceEvent;
	local SeqVar_Bool SeqVar_Bool;
 	local SeqVar_Float SeqVar_Float;
 	local SeqVar_Int SeqVar_Int;
 	local SeqVar_Object	SeqVar_Object;
 	local SeqVar_String	SeqVar_String;
 	local SeqVar_Vector	SeqVar_Vector;
	local Object SequenceObject;
	local WorldInfo WorldInfo;

	// Attempt to find the sequence object
	SequenceObject = FindObject(ObjectName, class'Object');

	// Could not find sequence object, so abort
	if (SequenceObject == None)
	{
		return;
	}

	// Deserialize Kismet Event
	SequenceEvent = SequenceEvent(SequenceObject);
	if (SequenceEvent != None)
	{
		WorldInfo = class'WorldInfo'.static.GetWorldInfo();
		if (WorldInfo != None)
		{
			SequenceEvent.ActivationTime = WorldInfo.TimeSeconds + Data.GetFloatValue("ActivationTime");
		}

		SequenceEvent.TriggerCount = Data.GetIntValue("TriggerCount");
		return;
	}

	// Deserialize Kismet Variable Bool
	SeqVar_Bool = SeqVar_Bool(SequenceObject);
	if (SeqVar_Bool != None)
	{
		SeqVar_Bool.bValue = Data.GetIntValue("Value");
		return;
	}

	// Deserialize Kismet Variable Float
	SeqVar_Float = SeqVar_Float(SequenceObject);
	if (SeqVar_Float != None)
	{
		SeqVar_Float.FloatValue = Data.GetFloatValue("Value");
		return;
	}

	// Deserialize Kismet Variable Int
	SeqVar_Int = SeqVar_Int(SequenceObject);
	if (SeqVar_Int != None)
	{
		SeqVar_Int.IntValue = Data.GetIntValue("Value");
		return;
	}

	// Deserialize Kismet Variable Object
	SeqVar_Object = SeqVar_Object(SequenceObject);
	if (SeqVar_Object != None)
	{
		SeqVar_Object.SetObjectValue(FindObject(Data.GetStringValue("Value"), class'Object'));
		return;
	}

	// Deserialize Kismet Variable String
	SeqVar_String = SeqVar_String(SequenceObject);
	if (SeqVar_String != None)
	{
		SeqVar_String.StrValue = Data.GetStringValue("Value");
		return;
	}

	// Deserialize Kismet Variable Vector
	SeqVar_Vector = SeqVar_Vector(SequenceObject);
	if (SeqVar_Vector != None)
	{
		SeqVar_Vector.VectValue.X = Data.GetFloatValue("Value_X");
		SeqVar_Vector.VectValue.Y = Data.GetFloatValue("Value_Y");
		SeqVar_Vector.VectValue.Z = Data.GetFloatValue("Value_Z");
		return;
	}
}

/**
 * Loads up the Matinee state based on the data
 *
 * @param		ObjectName		Name of the Matinee Kismet object
 * @param		Data			Saved Matinee Kismet data 
 */
function LoadMatineeState(string ObjectName, JSonObject Data)
{
	local SeqAct_Interp SeqAct_Interp;
	local float OldForceStartPosition;
	local bool OldbForceStartPos;

	// Find the matinee kismet object
	SeqAct_Interp = SeqAct_Interp(FindObject(ObjectName, class'Object'));
	if (SeqAct_Interp == None)
	{
		return;
	}
	
	if (Data.GetIntValue("IsPlaying") == 1)
	{
		OldForceStartPosition = SeqAct_Interp.ForceStartPosition;
		OldbForceStartPos = SeqAct_Interp.bForceStartPos;

		// Play the matinee at the forced position
		SeqAct_Interp.ForceStartPosition = Data.GetFloatValue("Position");
		SeqAct_Interp.bForceStartPos = true;
		SeqAct_Interp.ForceActivateInput(0);

		// Reset the start position and start pos
		SeqAct_Interp.ForceStartPosition = OldForceStartPosition;
		SeqAct_Interp.bForceStartPos = OldbForceStartPos;
	}
	else
	{
		// Set the position of the matinee
		SeqAct_Interp.SetPosition(Data.GetFloatValue("Position"), true);
	}

	// Set the paused 
	SeqAct_Interp.bPaused = (Data.GetIntValue("Paused") == 1) ? true : false;
}

defaultproperties
{
}
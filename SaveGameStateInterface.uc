//=============================================================================
// SaveGameStateInterface: Interface which allows actors to be serialized and
// deserialized using SaveGameState
//
// This interface is scanned for when the SaveGameState object wants to 
// serialize the world actors. Only actors that implement this interface will
// be serialized and deserialized.
// 
// Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
//=============================================================================
interface SaveGameStateInterface;

/**
 * Serializes the actor's data into JSon
 *
 * @return		JSon data representing the state of this actor
 */
function String Serialize();

/**
 * Deserializes the actor from the data given
 *
 * @param		Data		JSon data representing the differential state of this actor
 */
function Deserialize(JSonObject Data);
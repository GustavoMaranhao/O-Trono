//=============================================================================
// SaveGameState_SeqEvent_SavedGameStateLoaded: Kismet Sequence Event
//
// This Kismet Sequence Object will be triggered when a saved game state is
// loaded.
// 
// Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class SaveGameState_SeqEvent_SavedGameStateLoaded extends SequenceEvent;

defaultproperties
{
	ObjName="Saved Game State Loaded"
	MaxTriggerCount=0
	VariableLinks.Empty
	OutputLinks(0)=(LinkDesc="Loaded")
	bPlayerOnly=false
}

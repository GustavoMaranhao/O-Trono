// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class DeliverQuest extends SequenceAction;

var() bool IsActive;
var() vector Finish;
var() bool Completed;

event Activated()
{
	//local IsometricGamePlayerController Loc;
	local vector subt;

	//Loc = IsometricGamePlayerController.PawnLocation;
	//IsActive = true;
	//subt = (Loc - Finish);
	//subt2 = (Finish - Loc);

	//if ((subt <= ExpectedDistance) || (subt2 <= ExpectedDistance))
	/*if (IsActive && (Finish.X != IsometricGamePlayerController.Pawn.Location.X))
	{
		Completed = true;
		ActivateOutputLink(2);
	}
	else
	{*/
		ActivateOutputLink(0);
	//}

}

defaultproperties
{
	ObjName="Deliver/Go to Quest"
	ObjCategory="Quests"

	bAutoActivateOutputLinks=false
	bCallHandler=false

	IsActive = false;
	Completed = false;
	Finish = (0,0,0);
	TimeToFinish = 0;          // 0 se o tempo for infinito
	ExpectedDistance = 0;

	InputLinks(0)=(LinkDesc="Start");

	OutputLinks(0)=(LinkDesc="Not There Yet");
	OutputLinks(1)=(LinkDesc="Time's Up");
	OutputLinks(2)=(LinkDesc="Quest Done");

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Active", bWriteable=true, PropertyName=IsActive)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Completed", bWriteable=true, PropertyName=Completed)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector', LinkDesc="Finish", bWriteable=true, PropertyName=Finish)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Int', LinkDesc="TimeToFinish", bWriteable=true, PropertyName=TimeToFinish)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Float', LinkDesc="ExpectedDistance", bWriteable=true, PropertyName=ExpectedDistance)
}

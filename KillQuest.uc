
// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class KillQuest extends SequenceAction;

var() bool IsActive;
var() bool Completed;
var() int  KillAmount;
var() int  KillCount;

event Activated()
{
	/*if (InputLinks[0].bHasImpulse)
	{
		IsActive = true;
		Completed = false;
		KillCount = 1;
		ActivateOutputLink(0);
	}

	if (InputLinks[1].bHasImpulse)
	{
		if ((KillCount >= KillAmount) && IsActive)
		{
			Completed = true;
			ActivateOutputLink(2);
		}
		else
		{
			if (Actor.Died(IsometricGameInfo.ScoreKill(IsometricGamePlayerController(Killer),),,))
			{
				KillCount += 1;
				ActivateOutputLink(1);
			}
		}
	}*/
}

defaultproperties
{
	ObjName="Kill Quest"
	ObjCategory="Quests"

	bAutoActivateOutputLinks=false
	bCallHandler=false

	IsActive = false;
	Completed = false;
	KillAmount = 0;
	KillCount = 0;
	Actor = none;

	InputLinks(0)=(LinkDesc="Set");
	InputLinks(1)=(LinkDesc="Add");

	OutputLinks(0)=(LinkDesc="Set Done");
	OutputLinks(1)=(LinkDesc="Mob Killed");
	OutputLinks(2)=(LinkDesc="Quest Done");

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Active", bWriteable=true, PropertyName=IsActive)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Completed", bWriteable=true, PropertyName=Completed)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Int', LinkDesc="KillAmount", bWriteable=true, PropertyName=KillAmount)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Int', LinkDesc="KillCount", bWriteable=true, PropertyName=KillCount)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Character', LinkDesc="Actor", PropertyName=Actor)
}

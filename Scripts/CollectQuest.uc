
class CollectQuest extends SequenceAction;

var() bool IsActive;
var() bool Completed;
var() int  ItemAmount;
var() int  Collected;

event Activated()
{
	if (InputLinks[0].bHasImpulse)
	{
		IsActive = true;
		Completed = false;
		Collected = 1;
		ActivateOutputLink(0);
	}

	if (InputLinks[1].bHasImpulse)
	{
		if ((Collected >= ItemAmount) && IsActive)
		{
			Completed = true;
			ActivateOutputLink(3);
		}
		else
		{
			Collected += 1;
			ActivateOutputLink(1);
		}
	}

	if (InputLinks[2].bHasImpulse)
	{
		if (IsActive)
		{
		Collected -= 1;
		ActivateOutputLink(2);
		}
	}
}

DefaultProperties
{
	bAutoActivateOutputLinks=false
	bCallHandler=false

	// Name that will apear in the Kismet Editor
	ObjName="Collect Quest"
	ObjCategory="Quests"
  
	IsActive = false;
	Completed = false;
	ItemAmount = 1;
	ItemActor = none;
	Collected = 1;

	InputLinks(0)=(LinkDesc="Set");
	InputLinks(1)=(LinkDesc="Add");
	InputLinks(2)=(LinkDesc="Subtract");

	OutputLinks(0)=(LinkDesc="Set Done");
	OutputLinks(1)=(LinkDesc="Add Done");
	OutputLinks(2)=(LinkDesc="Subtract Done");
	OutputLinks(3)=(LinkDesc="Quest Done");
 
	// Expose the Amount property in Kismet
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Active", bWriteable=true, PropertyName=IsActive)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Bool', LinkDesc="Completed", bWriteable=true, PropertyName=Completed)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Int', LinkDesc="ItemAmount", bWriteable=true, PropertyName=ItemAmount)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Int', LinkDesc="CurrentAmount", bWriteable=true, PropertyName=Collected)
}

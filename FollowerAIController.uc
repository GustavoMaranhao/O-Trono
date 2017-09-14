
class FollowerAIController extends GameAIController;

var()   Vector  TempDest;
var     float   OffsetToHero;
var Actor target;
var Pawn OldPawn;
var bool bAttack, bWalk;
var float Distance, OffsetToPlayer;
var vector MaxMov, MinMov, Center, BackToCenter;
var Actor  ActorMaxMov;
var Vector MyTarget, MyTarget2;
var vector InFront;
var vector X,Y,Z;
var vector HitLoc, HitNormal;
var Actor	HitActor;

var MyPawn P, TargetPawn;     //your player pawn class

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	//start the brain going at 10 seconds intervals
	SetTimer(0.1, true, 'WanderAround');
	SetTimer(7.5, true, 'WalkOK');
	SetTimer(2.0, false, 'UpdateMaxMov');
}

function UpdateMaxMov()
{
	Center = Pawn.Location;
	MinMov = Pawn.Location - MaxMov;
	MaxMov = Pawn.Location + MaxMov;
	OffsetToPlayer = FollowerPawn(Pawn).Mesh.Bounds.BoxExtent.X/2;
}

function WanderAround()
{
	local int temp;

	temp = FRand();
	//`log("Wander Around");

	if (temp >= 0.67)
	{
		GetAxes(Pawn.Rotation, X,Y,Z);
		InFront = Pawn.Location + RandRange(2500,3500)*X;

		HitActor = Trace(HitLoc, HitNormal, InFront, Pawn.Location);  //trace in front
		//DrawDebugSphere( HitLoc, 30, 10, 0, 255, 0 );

		if (HitActor != None) //theres something in front
		{
			TraceRandom();      //trace randomly left or right
		}
		else  //theres nothing in front
		{
			MyTarget = InFront; //move forward
			GoToState('MoveAbout');
		}
	}
	else
	{
		TraceRandom();
	}
}

function TraceRandom()
{
  local int LeftRight;
  //`log("Trace Random");

  LeftRight = RandRange(2500,3500) - RandRange(2500,3500);    //make a random number

  GetAxes(Pawn.Rotation, X,Y,Z);

  InFront = Pawn.Location + LeftRight*Y;
  
  HitActor = Trace(HitLoc, HitNormal, InFront, Pawn.Location);  //do another trace to a random location left or right
  //DrawDebugSphere( HitLoc, 30, 10, 255, 0, 0 );

  if (HitActor != None)  //if we trace something
  {
	Return;
  }
  else  //if we trace nothing
  {
	MyTarget = InFront;     //move there
    GoToState('MoveAbout');
  }
}

function WalkOK()
{
	//`log("Function WalkOK");
	MyTarget2 = MyTarget;
	////`log(Pawn.Location);
	////`log(MyTarget2);
	Pawn.SetDesiredRotation(Rotator(Normal( -Pawn.Location + MyTarget)));
	bWalk = true;
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}

state MoveAbout
{
Begin:
	//`log("MoveAbout Else");
	if (bWalk)
		{
			if ((Pawn.Location.X < MaxMov.X)&&(Pawn.Location.X > MinMov.X) && ((Pawn.Location.Y < MaxMov.Y)&&(Pawn.Location.Y > MinMov.Y)))
			{
				////`log("Pawn Loc: "@Pawn.Location);
				//`log("WalkOK");
				bAttack = false;
				MoveTo(MyTarget2);
				bWalk = false;
			}
			else
			{
				//`log("Out of Bounds");
				ClearTimer('WanderAround');
				ClearTimer('WalkOK');
				BackToCenter.X = RandRange(MinMov.X,MaxMov.X);
				BackToCenter.Y = RandRange(MinMov.Y,MaxMov.Y);
				BackToCenter.Z = Center.Z;
				MoveTo(BackToCenter);
				////`log("Back To Center: "@BackToCenter);
				bWalk = false;
				SetTimer(0.1, true, 'WanderAround');
				SetTimer(7.5, true, 'WalkOK');
			}
		}
}

/*function SetOrders(name NewOrders, Controller OrderGiver)
{
	local Actor DestActor;

	////`log("Received order : "@NewOrders);
	if(NewOrders == 'Follow')
	{
		if(IsInState('ScriptedMove'))
		{
			PopState(true);
		}

		DestActor = OrderGiver.Pawn;
		ScriptedRoute = Route(DestActor);
		ScriptedRouteIndex = 0;
		if (ScriptedRoute.RouteList.length == 0)
		{
			//`warn("Invalid route with empty MoveList for scripted move");
			ScriptedMoveTarget = DestActor;
			PushState('ScriptedMove');
		}
		else
		{
			PushState('ScriptedRouteMove');
		}
	}
}*/

//I'm adding an default idle state so the Pawn doesn't try to follow a player that doesn' exist yet.
/*auto state Idle
{
    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        target = Seen;
        GotoState('Follow');
    }
Begin:
}*/

/*state Follow
{
    ignores SeePlayer;
    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;

        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,target );
        class'NavMeshGoal_At'.static.AtActor( NavigationHandle, target,32 );

        // Find path
        return NavigationHandle.FindPath();
    }
Begin:

    if( NavigationHandle.ActorReachable( target) )
    {
        FlushPersistentDebugLines();
        //Direct move
        MoveToward( target, target, 75 );
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(target.Location);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);
        
        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
            DrawDebugSphere(TempDest,16,20,255,0,0,true);
            MoveTo( TempDest, target, 75 );
        }
    }
    else
    {
        //We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        GotoState('Idle');
    }
    goto 'Begin';
}

//Overwrite AIController's ScriptedMove state to make use of the NavigationHandle instead of the old way
state ScriptedMove
{
	ignores SeePlayer;

	function bool FindNavMeshPath()
	{
		// Clear cache and constraints (ignore recycling for the moment)
		NavigationHandle.PathConstraintList = none;
		NavigationHandle.PathGoalList = none;

		// Create constraints
		class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,ScriptedMoveTarget );
		class'NavMeshGoal_At'.static.AtActor( NavigationHandle, ScriptedMoveTarget );

		// Find path
		return NavigationHandle.FindPath();
	}

	Begin:
		////`log("BEGIN STATE SCRIPTEDMOVE");
		// while we have a valid pawn and move target, and
		// we haven't reached the target yet
		if( FindNavMeshPath() )
		{
			NavigationHandle.SetFinalDestination(ScriptedMoveTarget.Location);
			////`log("FindNavMeshPath returned TRUE");
			FlushPersistentDebugLines();
			NavigationHandle.DrawPathCache(,TRUE);

			while( Pawn != None && ScriptedMoveTarget != None && !Pawn.ReachedDestination(ScriptedMoveTarget) )
			{
				if( NavigationHandle.ActorReachable( ScriptedMoveTarget) )
				{
					// then move directly to the actor
					MoveTo( ScriptedMoveTarget.Location,ScriptedFocus, OffsetToHero, true );
				}
				else
				{
					// move to the first node on the path
					if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
					{
						// suggest move preparation will return TRUE when the edge's
					    // logic is getting the bot to the edge point
							// FALSE if we should run there ourselves
						if (!NavigationHandle.SuggestMovePreparation( TempDest,self))
						{
							MoveTo( TempDest, ScriptedFocus, OffsetToHero, true );
						}
					}
				}
			}
		}
		else
		{
			//give up because the nav mesh failed to find a path
			`warn("FindNavMeshPath failed to find a path to"@ScriptedMoveTarget);
			ScriptedMoveTarget = None;
		}   

	////`log("POPPING STATE!");
	Pawn.ZeroMovementVariables();
	// return to the previous state
	PopState();
}*/

DefaultProperties
{
	OffsetToHero=75;

	bAttack = false;
	bWalk = false;

	MaxMov = (X=500, Y=500, Z=0)
	MinMov = (X=0, Y=0, Z=0)
	BackToCenter = (X=0, Y=0, Z=0)

}
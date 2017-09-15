
class MonsterController extends GameAIController;

var Vector MyTarget, MyTarget2;
var vector InFront;
var vector X,Y,Z;
var vector HitLoc, HitNormal;
var Actor	HitActor;
var bool bAttack, bWalk;
var float Distance, OffsetToPlayer;
var vector MaxMov, MinMov, Center, BackToCenter;
var Actor  ActorMaxMov;

var MyPawn P, TargetPawn;     //your player pawn class
var FollowerPawn P2, TargetPawn2;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	//start the brain going at 10 seconds intervals
	SetTimer(0.1, true, 'BrainTimer');
	SetTimer(7.5, true, 'WalkOK');
	SetTimer(2.0, false, 'UpdateMaxMov');
}

function UpdateMaxMov()
{
	Center = Pawn.Location;
	MinMov = Pawn.Location - MaxMov;
	MaxMov = Pawn.Location + MaxMov;
	OffsetToPlayer = MonsterPawn(Pawn).Mesh.Bounds.BoxExtent.X/2;
}

event Tick( float DeltaTime )
{
super.Tick(DeltaTime);
	if (MonsterPawn(Pawn).PawnAttacked)     //Was attacked
	{
		bAttack = true;		
		Pawn.SetDesiredRotation(Rotator(Normal(MonsterPawn(Pawn).DamagerPawn.Location)));   //look at it
		TargetPawn = MyPawn(MonsterPawn(Pawn).DamagerPawn);
		MyTarget = MonsterPawn(Pawn).DamagerPawn.Location;      //make the pawn our target
		GoToState('MoveAbout');     //go to it
	}
}

function BrainTimer()
{
	//`log(bAttack);
    //////////////////
    //use colliding actors
    foreach WorldInfo.AllPawns(class 'MyPawn', P)
	{
		if (P != None)   //if theres a player pawn
        {
			////`log("Found a MyPawn!");
            Distance = VSize2D(Pawn.Location - P.Location);		//get the distance
            if (Distance <= 600)        //if its close
            {
				////`log("Close enough!");
				if (CanSee(P))
                {
					////`log("I See You!");
					bAttack = true;		
					Pawn.SetDesiredRotation(Rotator(Normal(P.Location)));   //look at it
					TargetPawn = P;
					MyTarget = P.Location;      //make the pawn our target
					GoToState('MoveAbout');     //go to it
				}
                else  //cant see it so wander
				{
					bAttack = false;
					Pawn.StopFire(0);
					WanderAround();
				}
            }
            else  //its too far so wander
            {
				//bAttack = false;
				Pawn.StopFire(0);
				WanderAround();
            }
          }
	}
	//if (Pawn.Location == MyTarget2) //`log("Same Locations!");
	if (Pawn == none) Destroy();


	foreach WorldInfo.AllPawns(class 'FollowerPawn', P2)
	{
		if (P != None)   //if theres a player pawn
        {
			////`log("Found a MyPawn!");
            Distance = VSize2D(Pawn.Location - P.Location);		//get the distance
            if (Distance <= 600)        //if its close
            {
				////`log("Close enough!");
				if (CanSee(P))
                {
					////`log("I See You!");
					bAttack = true;		
					Pawn.SetDesiredRotation(Rotator(Normal(P.Location)));   //look at it
					TargetPawn2 = P2;
					MyTarget = P2.Location;      //make the pawn our target
					GoToState('MoveAbout');     //go to it
				}
                else  //cant see it so wander
				{
					bAttack = false;
					Pawn.StopFire(0);
					WanderAround();
				}
            }
            else  //its too far so wander
            {
				//bAttack = false;
				Pawn.StopFire(0);
				WanderAround();
            }
          }
	}
	//if (Pawn.Location == MyTarget2) //`log("Same Locations!");
	if (Pawn == none) Destroy();
}

function WanderAround()
{
	local int temp;

	temp = FRand();

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
	////`log("Function WalkOK");
	MyTarget2 = MyTarget;
	////`log(Pawn.Location);
	////`log(MyTarget2);
	Pawn.SetDesiredRotation(Rotator(Normal( -Pawn.Location + MyTarget)));
	bWalk = true;
}

state MoveAbout
{
Begin:
	////`log("In MoveAbout State");
	////`log("Pawn Location: ("@Pawn.Location.X@" , "@Pawn.Location.Y@") MyTarget: "@MyTarget.X@" , "@MyTarget.Y@").");
	if (bAttack)
	{
		ClearTimer('BrainTimer');
		//`log("MoveAbout Pushed");
		PushState('Attack');
		////`log("State Popped?");
		SetTimer(0.1, true, 'BrainTimer');
	}
	else
	{
		////`log("MoveAbout Else");
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
				ClearTimer('BrainTimer');
				ClearTimer('WalkOK');
				BackToCenter.X = RandRange(MinMov.X,MaxMov.X);
				BackToCenter.Y = RandRange(MinMov.Y,MaxMov.Y);
				BackToCenter.Z = Center.Z;
				MoveTo(BackToCenter);
				////`log("Back To Center: "@BackToCenter);
				bWalk = false;
				SetTimer(0.1, true, 'BrainTimer');
				SetTimer(7.5, true, 'WalkOK');
			}
		}
	}
}

state Attack
{
Begin:
	////`log("In Attack State");
	bWalk = false;
	Distance = VSize2D(Pawn.Location - TargetPawn.Location);
	////`log(Distance);
	`log(TargetPawn.Health2);

	if ((Distance >= 1000) || (TargetPawn.Health2 <= 0))
	{
		`log("Pawn Dead or too far");
		//SetTimer(5, true, 'BrainTimer');
		Pawn.StopFire(0);
		bAttack = false;
		bWalk = false;
		MonsterPawn(Pawn).PawnAttacked = false;

		PopState(true);
	}
	else 
	{
		//`log("Went to Attack State Again");
		MonsterPawn(Pawn).AttackAnim();
		//Pawn.StartFire(0);  //shoot it
		MoveTo(MyTarget - vect(1.1,0,0)*OffsetToPlayer + vect(0,1,0)*RandRange(-1,1));
		//Pawn.SetDesiredRotation(Rotator(Normal(TargetPawn.Location)));
		MyTarget = TargetPawn.Location;
		Pawn.StartFire(0);  //shoot it
		GoToState('Attack', 'Begin');
	}
}

DefaultProperties
{

	bAttack = false;
	bWalk = false;

	MaxMov = (X=500, Y=500, Z=0)
	MinMov = (X=0, Y=0, Z=0)
	BackToCenter = (X=0, Y=0, Z=0)

}

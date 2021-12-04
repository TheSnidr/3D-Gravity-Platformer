/// @description

//Player variables
x = 200;
z = 1000;
prevX = x;
prevY = y;
prevZ = z;
upX = 0;
upY = 0;
upZ = 1;
ground = false;
radius = 16;
horFriction = .9;
verFriction = .95;
normalGravity = .8;
gravityStrength = normalGravity;
moveSpd = 1;
jumpHeight = 1;
canMove = true;

xscale = 1;
yscale = 1;
zscale = 1;
xscaleTarget = 1;
yscaleTarget = 1;
zscaleTarget = 1;
xscaleSpd = 0;
yscaleSpd = 0;
zscaleSpd = 0;
scaleAcceleration = .3;
scaleFriction = .75;

jumpIndex = 0;
jumpTimer = 0;
doubleJump = 0;
headTilt = 0;

//The character matrix stores the player's world matrix so that it looks in the direction it's moving
charMat = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);

//Create player model
playerModel = smf_model_load("Mushroom.smf");
mainInst = new smf_instance(playerModel);

//Create movement functions
function shakeScreen()
{
	oSystem.screenShake = 5;
}

function playerInput()
{
	if (!canMove)
	{
		hInput = 0;
		vInput = 0;
		jumpInput = 0;
		inputDirX = 0;
		inputDirY = 0;
		inputDirZ = 0;
		walkInput = 0;
		groundPoundInput = 0;
		exit;
	}
	hInput = global.hInput;
	vInput = global.vInput;
	jumpInput = global.jumpInput;
	walkInput = global.walkInput;
	crouchInput = global.crouchInput;
	groundPoundInput = global.groundPoundInput;
	
	var camMat = oSystem.camMat;
	inputDirX = camMat[0] * vInput + camMat[4] * hInput;
	inputDirY = camMat[1] * vInput + camMat[5] * hInput;
	inputDirZ = camMat[2] * vInput + camMat[6] * hInput;
}
playerInput()

function collide()
{
	ground = false;
	if (z < radius)
	{
		ground = true;
		z = radius;
	}
} 

function movement()
{
	//Verlet integration, figure out the speed from the previous frame based on how far the player has moved
	spdX = x - prevX;
	spdY = y - prevY;
	spdZ = z - prevZ;

	//Update previous position so that it's ready for the next frame
	prevX = x;
	prevY = y;
	prevZ = z;
	
	//Split speed into horizontal and vertical components
	spd = point_distance_3d(0, 0, 0, spdX, spdY, spdZ);
	spdVer = dot_product_3d(spdX, spdY, spdZ, upX, upY, upZ);
	spdHorX = spdX - upX * spdVer;
	spdHorY = spdY - upY * spdVer;
	spdHorZ = spdZ - upZ * spdVer;
	spdHor = point_distance_3d(0, 0, 0, spdHorX, spdHorY, spdHorZ);
	
	//Update speed vector
	spdX = spdHorX * horFriction + upX * spdVer * verFriction;
	spdY = spdHorY * horFriction + upY * spdVer * verFriction;
	spdZ = spdHorZ * horFriction + upZ * spdVer * verFriction;

	//Apply gravity
	spdX -= upX * gravityStrength;
	spdY -= upY * gravityStrength;
	spdZ -= upZ * gravityStrength;
	
	//Apply player input
	spdX += moveSpd * inputDirX;
	spdY += moveSpd * inputDirY;
	spdZ += moveSpd * inputDirZ;
	
	//Apply speed to position
	x += spdX;
	y += spdY;
	z += spdZ;
	
	collide();
	
	//Update the player's matrix, making it point in the direction the player is moving, and making the up direction point upwards
	charMat[12] = x;
	charMat[13] = y;
	charMat[14] = z;
	charMat[8] += upX * .2;
	charMat[9] += upY * .2;
	charMat[10] += upZ * .2;
	var turnSpd = moveSpd * .3 * (1. + .5 * walkInput);
	charMat[0] += turnSpd * inputDirX;
	charMat[1] += turnSpd * inputDirY;
	charMat[2] += turnSpd * inputDirZ;
	matrix_orthogonalize(charMat);
}

function playAnimation(inst, name, speedMultiplier, lerpTime, resetTimer)
{
	static playSpd = 1000 / game_get_speed(gamespeed_fps);
	var anim = playerModel.get_animation(name);
	var animSpd = speedMultiplier * playSpd / anim.playTime;
	inst.play(name, animSpd, lerpTime, resetTimer);
}

//Create a new finite state machine
fsm = new finiteStateMachine();

//Add states
fsm.addState("Idle", function(){
		horFriction = .85;
		verFriction = .9;
		moveSpd = 1;
		doubleJump = 0;
		xscaleTarget = 1;
		yscaleTarget = 1;
		zscaleTarget = 1;
		playAnimation(mainInst, "Idle", 1, .16, false);},
	function(){
		if (jumpTimer > 0)
		{
			jumpTimer --;
			if (jumpTimer == 0)
			{
				jumpIndex = 0;
			}
		}
		playerInput();
		movement();
	});
		
fsm.addState("Move", function(){
		horFriction = .86;
		verFriction = .9;
		moveSpd = 1;},
	function(){
		playerInput();
		movement();
		if (jumpTimer > 0)
		{
			jumpTimer --;
			if (jumpTimer == 0)
			{
				jumpIndex = 0;
			}
		}
		if (walkInput)
		{
			playAnimation(mainInst, "Walk", 1, .15, false);	
			moveSpd = .3;
		}
		else
		{
			playAnimation(mainInst, "Run", 1, .15, false);	
			moveSpd = .85;
		}
	});
		
fsm.addState("Fall", function(){
		horFriction = .98;
		verFriction = .99;
		moveSpd = .1;
		playAnimation(mainInst, "Fall", 1, .15, false);},
	function(){
		playerInput();
		movement();
	});
		
fsm.addState("Crouch", function(){
		horFriction = .9;
		verFriction = .9;
		moveSpd = 0;
		playAnimation(mainInst, "Crouch", 1, .25, false);
	},
	function(){
		playerInput();
		movement();
	});
		
fsm.addState("SharpTurn", function(){
		horFriction = .85;
		verFriction = .85;
		moveSpd = 0;
		charMat[0] *= -1;
		charMat[1] *= -1;
		charMat[2] *= -1;
		matrix_orthogonalize(charMat);
		if (spdHor < 2){playAnimation(mainInst, "SharpTurnWalk", 1, 1, true);}
		else{playAnimation(mainInst, "SharpTurn", 1, 1, true);}
	},
	function(){
		playerInput();
		movement();
	});
	
fsm.addState("GroundPound", function(){
		gravityStrength = 12;
		horFriction = 0;
		verFriction = .5;
		moveSpd = 0;
		playAnimation(mainInst, "GroundPound", 1, .4, false);},
	function(){
		playerInput();
		movement();
		groundPoundTimer ++;
	});
		
fsm.setState("Idle");

//Add idle transitions
fsm.addTransition("Idle", "", "Move", 
	function(){return (hInput != 0 || vInput != 0);},
	function(){return 0;},
	function(){});
fsm.addTransition("Idle", "", "Fall", 
	function(){return !ground;},
	function(){return 0;},
	function(){});
fsm.addTransition("Idle", "Jump", "Fall", 
	function(){return jumpInput;},
	function(){return 40;},
	function(){
		vibrate(5, .4, .4, -.05, -.05);
		playAnimation(mainInst, "Jump1", 1, .15, false);
		jumpHeight = 14;
		x += upX * jumpHeight;
		y += upY * jumpHeight;
		z += upZ * jumpHeight;
	});
fsm.addTransition("Idle", "Instant", "Crouch", 
	function(){return crouchInput;},
	function(){return 0;},
	function(){});
fsm.addTransition("Idle", "", "Idle", 
	function(){return random(100) < 1 && mainInst.timer > .95;},
	function(){return mainInst.get_animation_time();},
	function(){playAnimation(mainInst, "FaceScratch", 1, .2, true);});

//Add move transitions
fsm.addTransition("Move", "", "Idle", 
	function(){return (hInput == 0 && vInput == 0);},
	function(){return 0;},
	function(){});
fsm.addTransition("Move", "Instant", "SharpTurn", 
	function(){return dot_product_3d(inputDirX, inputDirY, inputDirZ, charMat[0], charMat[1], charMat[2]) < -.7}, 
	function(){return 0;}, 
	function(){});
fsm.addTransition("Move", "Jump", "Fall", 
	function(){return jumpInput;},
	function(){
		if (jumpIndex == 0){return mainInst.get_animation_time();}
		return 40},
	function(){
		switch jumpIndex
		{
			case 0:
				playAnimation(mainInst, "Jump1", 1, .15, false);
				jumpLength = 2;
				jumpHeight = 14;
				vibrate(5, .3, .3, -.05, -.05);
				break;
			case 1:
				playAnimation(mainInst, "Jump2", 1, .15, false);
				jumpLength = 3;
				jumpHeight = 18;
				vibrate(5, .4, .4, -.05, -.05);
				break;
			case 2:
				playAnimation(mainInst, "Jump3", 1, .15, true);
				jumpLength = 5;
				jumpHeight = 25;
				vibrate(5, .5, .5, -.05, -.05);
				break;
		}
		jumpIndex = (jumpIndex + 1) mod 3;
		jumpTimer = 20;
		x += charMat[0] * jumpLength + upX * jumpHeight;
		y += charMat[1] * jumpLength + upY * jumpHeight;
		z += charMat[2] * jumpLength + upZ * jumpHeight;
	});
fsm.addTransition("Move", "Instant", "Crouch", 
	function(){return crouchInput;},
	function(){return 0;},
	function(){});
	
//Fall transitions
fsm.addTransition("Fall", "Land", "Idle", 
	function(){return ground && (spdVer > -30);}, 
	function(){return mainInst.get_animation_time();}, 
	function(){
		vibrate(5, .4, .4, -.05, -.05);
		zscaleSpd = -.15;
		if fsm.transitionName == "Backflip"{playAnimation(mainInst, "Present", 1, .2, true);}
		else{playAnimation(mainInst, "Land", .7, .3, true);}
	});
fsm.addTransition("Fall", "Squish", "Idle", 
	function(){return ground && (spdVer <= -30);}, 
	function(){return -30;},
	function(){
		vibrate(20, 1, 1, -.02, -.02);
		horFriction = .8;
		verFriction = .8;
		moveSpd = .2;
		xscaleTarget = 1.3;
		yscaleTarget = 1.3;
		zscaleTarget = .5;});
fsm.addTransition("Fall", "GroundPoundBegin", "GroundPound", 
	function(){return !ground && groundPoundInput && (fsm.transitionTimer != 0);}, 
	function(){return mainInst.get_animation_time();},
	function(){
		groundPoundTimer = 0;
		zscaleSpd = -.1;
		gravityStrength = 0;
		horFriction = 0;
		verFriction = 0;
		moveSpd = 0;
		playAnimation(mainInst, "GroundPoundBegin", 1, .15, true);
	});
fsm.addTransition("Fall", "DoubleJump", "Fall", 
	function(){return doubleJump == 0 && jumpInput;}, 
	function(){return mainInst.get_animation_time();},
	function(){
		vibrate(5, .5, .5, 0, 0);
		jumpIndex = 0;
		doubleJump = 1;
		xscaleSpd = .2;
		yscaleSpd = .2;
		zscaleSpd = -.2;
		playAnimation(mainInst, "DoubleJump", 1, .2, true);
		jumpLength = 5;
		jumpHeight = 14;
		//Cancel previous speed
		x -= upX * spdVer;
		y -= upY * spdVer;
		z -= upZ * spdVer;
		//Jump
		x += inputDirX * jumpLength + upX * jumpHeight;
		y += inputDirY * jumpLength + upY * jumpHeight;
		z += inputDirZ * jumpLength + upZ * jumpHeight;});

//Sharp turn transitions
fsm.addTransition("SharpTurn", "Instant", "Move", 
	function(){return mainInst.timer >= 1;},
	function(){return 0;},
	function(){});
fsm.addTransition("SharpTurn", "Jump", "Fall", 
	function(){return jumpInput;},
	function(){return mainInst.get_animation_time();},
	function(){
		vibrate(5, .5, .5, -.05, -.05);
		playAnimation(mainInst, "SideJump", 1, .2, true);
		if (walkInput)
		{
			jumpLength = 5;
			jumpHeight = 17;
		}
		else
		{
			jumpLength = 10;
			jumpHeight = 19;
		}
		x += charMat[0] * jumpLength + upX * jumpHeight;
		y += charMat[1] * jumpLength + upY * jumpHeight;
		z += charMat[2] * jumpLength + upZ * jumpHeight;
	});

//Crouch transitions
fsm.addTransition("Crouch", "Instant", "Idle",
	function(){return !ground || !crouchInput;},
	function(){return 0;},
	function(){});
fsm.addTransition("Crouch", "LongJump", "Fall",
	function(){return (dot_product_3d(spdX, spdY, spdZ, charMat[0], charMat[1], charMat[2]) > 1) && jumpInput;},
	function(){return mainInst.get_animation_time();},
	function(){
		vibrate(5, .6, .6, -.05, -.05);
		playAnimation(mainInst, "LongJump", 1, .3, true);
		jumpLength = 15;
		jumpHeight = 17;
		x += charMat[0] * jumpLength + upX * jumpHeight;
		y += charMat[1] * jumpLength + upY * jumpHeight;
		z += charMat[2] * jumpLength + upZ * jumpHeight;});
fsm.addTransition("Crouch", "Backflip", "Fall",
	function(){return (dot_product_3d(spdX, spdY, spdZ, charMat[0], charMat[1], charMat[2]) <= 1) && jumpInput;},
	function(){return mainInst.get_animation_time();},
	function(){
		vibrate(5, .6, .6, -.05, -.05);
		playAnimation(mainInst, "Backflip", 1, .3, true);
		jumpLength = -5;
		jumpHeight = 22;
		x += charMat[0] * jumpLength + upX * jumpHeight;
		y += charMat[1] * jumpLength + upY * jumpHeight;
		z += charMat[2] * jumpLength + upZ * jumpHeight;});

//Ground pound transitions
fsm.addTransition("GroundPound", "Pound", "Idle", 
	function(){return ground}, 
	function(){return - mainInst.get_animation_time();}, 
	function(){
		vibrate(15, 1, 1, -.05, -.05);
		shakeScreen();
		doubleJump = 0;
		zscaleSpd = -.6;
		xscaleSpd = .5;
		yscaleSpd = .5;
		gravityStrength = normalGravity;
		horFriction = .5;
		verFriction = .5;
		moveSpd = 0;
		playAnimation(mainInst, "GroundPoundEnd", 1, .8, true);
	});
fsm.addTransition("GroundPound", "Instant", "Fall", 
	function(){return groundPoundTimer > 45;}, 
	function(){return 0;}, 
	function(){gravityStrength = normalGravity;});
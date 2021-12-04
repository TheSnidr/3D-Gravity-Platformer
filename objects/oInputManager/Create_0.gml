/// @description
#macro vibrate oInputManager._vibrate
vibLeftSpd = 0;
vibLeftAcc = 0;
vibRightSpd = 0;
vibRightAcc = 0;
/// @func vibrate(timer, leftSpeed, rightSpeed, leftAcc, rightAcc)
function _vibrate(timer, leftSpeed, rightSpeed, leftAcc, rightAcc)
{
	alarm[0] = timer;
	vibLeftSpd = leftSpeed;
	vibLeftAcc = leftAcc;
	vibRightSpd = rightSpeed;
	vibRightAcc = rightAcc;
}
function checkKeyboard()
{
	global.vInput = keyboard_check(ord("W")) - keyboard_check(ord("S"));
	global.hInput = keyboard_check(ord("D")) - keyboard_check(ord("A"));
	global.jumpInput = keyboard_check_pressed(vk_space);
	global.walkInput = keyboard_check(vk_alt);
	global.groundPoundInput = keyboard_check_pressed(vk_shift);
	global.crouchInput = keyboard_check(vk_shift);
		
	global.vInputCam = 0;
	global.hInputCam = 0;
	
	//Normalize the input vector
	if (global.hInput != 0 || global.vInput != 0)
	{
		var l = point_distance(0, 0, global.hInput, global.vInput);
		global.vInput /= l;
		global.hInput /= l;
	}
		
	//Move the camera when the right mouse button is held down
	if mouse_check_button(mb_right)
	{
		//Don't move the camera if the button was just pressed (to avoid "jumpy" movements)
		if !mouse_check_button_pressed(mb_right)
		{
			//Find the difference between the mouse' current position and the middle of the screen
			var dx = window_mouse_get_x() - window_get_width() / 2;
			var dy = window_mouse_get_y() - window_get_height() / 2;
		
			//Smoothly change the yaw and pitch
			global.hInputCam = - dx * .1;
			global.vInputCam = dy * .1;
		}
	
		//Reset the mouse position to the middle of the screen
		window_mouse_set(window_get_width() / 2, window_get_height() / 2);
	}
		
	//Return true if any of the inputs have been pressed
	if (global.vInput != 0 || global.hInput != 0 || global.jumpInput != 0 || global.walkInput != 0 || global.groundPoundInput != 0 || global.vInputCam != 0 || global.hInputCam != 0 || global.crouchInput != 0)
	{
		return true;
	}
	return false;
}

function checkControllers()
{
	global.vInput = 0;
	global.hInput = 0;
	global.jumpInput = 0;
	global.groundPoundInput = 0;
	global.walkInput = 0;
	global.crouchInput = 0;
		
	global.vInputCam = 0;
	global.hInputCam = 0;
		
	if (!gamepad_is_supported()){return false;}
	var gp_num = gamepad_get_device_count();
	for (var i = 0; i < gp_num; i ++)
	{
		if !gamepad_is_connected(i){continue;}
		global.vInput = - gamepad_axis_value(i, gp_axislv);
		global.hInput = gamepad_axis_value(i, gp_axislh);
		global.jumpInput = gamepad_button_check_pressed(i, gp_face1);
		global.groundPoundInput = gamepad_button_check_pressed(i, gp_shoulderrb);
		global.crouchInput = gamepad_button_check(i, gp_shoulderrb);
			
		global.vInputCam = gamepad_axis_value(i, gp_axisrv);
		global.hInputCam = - gamepad_axis_value(i, gp_axisrh);
	
		//Normalize the input vector
		var l = point_distance(0, 0, global.hInput, global.vInput);
		if (l > .1)
		{
			global.hInput /= l;
			global.vInput /= l;
			global.walkInput = (l < .8);
		}
		else
		{
			global.hInput = 0;
			global.vInput = 0;
		}
			
		//Normalize the input vector
		var l = point_distance(0, 0, global.vInputCam, global.hInputCam);
		if (l < .1)
		{
			global.hInputCam = 0;
			global.vInputCam = 0;
		}
		
		//Return true if any of the inputs have been pressed
		if (global.vInput != 0 || global.hInput != 0 || global.jumpInput != 0 || global.walkInput != 0 || global.groundPoundInput != 0 || global.vInputCam != 0 || global.hInputCam != 0 || global.crouchInput != 0)
		{
			return true;
		}
	}
	return false;
}

checkKeyboard();
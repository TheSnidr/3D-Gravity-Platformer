/// @description
if !checkKeyboard()
{
	checkControllers();
}

if (alarm[0] > 0)
{
	vibLeftSpd += vibLeftAcc;
	vibRightSpd += vibRightAcc;
	var gp_num = gamepad_get_device_count();
	for (var i = 0; i < gp_num; i ++)
	{
		if !gamepad_is_connected(i){continue;}
		gamepad_set_vibration(i, vibLeftSpd, vibRightSpd);
	}
}
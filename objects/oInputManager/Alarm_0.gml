/// @description
var gp_num = gamepad_get_device_count();
for (var i = 0; i < gp_num; i ++)
{
	if !gamepad_is_connected(i){continue;}
	gamepad_set_vibration(i, 0, 0);
}
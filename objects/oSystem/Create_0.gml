/// @description
//game_set_speed(9999, gamespeed_fps)
//Initialize camera
/*
	There are many ways to do this, I like using views and assigning a camera to a view.
*/
window_set_fullscreen(true)
screenShake = 0;
global.lightDir = [0, 0, -1];

view_enabled = true;
view_visible[0] = true;
view_set_camera(0, camera_create());
camera_set_proj_mat(view_camera[0], matrix_build_projection_perspective_fov(-60, -window_get_width() / window_get_height(), 1, 32000));

//Some important GPU settings when working with 3D. Especially the two first ones are mandatory for enabling the depth buffer
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_texrepeat(true);
gpu_set_cullmode(cull_counterclockwise);

//Mouse movement variables
pitch = 30;
yawVel = 0;
pitchVel = 0;

//Player variables
z = 500;
prevX = x;
prevY = y;
prevZ = z;
upX = 0;
upY = 0;
upZ = 1;
ground = false;
radius = 16;

//The character matrix stores the player's world matrix so that it looks in the direction it's moving
charMat = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);

//The camera matrix stores the camera's orientation around the player
camMat = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);

/*
	An enumerator containing possible geometric objects.
*/
enum eGeometry
{
	Sphere, 
	Capsule,
	Torus,
	Disk,
	Block,
	Cylinder,
	Num
}


//The geometry list contains all the geometry of the level
function addSphere(geometryList, X, Y, Z, R)
{
	var M = matrix_build(X, Y, Z, 0, 0, 0, R, R, R);
	ds_list_add(geometryList, [eGeometry.Sphere, M, 0]);
}
function addCapsule(geometryList, X1, Y1, Z1, X2, Y2, Z2, R)
{
	var dist = point_distance_3d(X1, Y1, Z1, X2, Y2, Z2);
	var M = matrix_build_from_vector(X1, Y1, Z1, X2 - X1, Y2 - Y1, Z2 - Z1, R, R, dist);
	ds_list_add(geometryList, [eGeometry.Capsule, M, R])
}
function addTorus(geometryList, X, Y, Z, Nx, Ny, Nz, R, r)
{
	var M = matrix_build_from_vector(X, Y, Z, Nx, Ny, Nz, R, R, R);
	ds_list_add(geometryList, [eGeometry.Torus, M, r, R])
}
function addDisk(geometryList, X, Y, Z, Nx, Ny, Nz, R, r)
{
	var M = matrix_build_from_vector(X, Y, Z, Nx, Ny, Nz, R, R, R);
	ds_list_add(geometryList, [eGeometry.Disk, M, r, R])
}
function addBlock(geometryList, X, Y, Z, xto, yto, zto, xup, yup, zup, toScale, sideScale, upScale)
{
	var M = [xto, yto, zto, 0, 0, 0, 0, 0, xup, yup, zup, 0, X, Y, Z, 1];
	matrix_orthogonalize(M);
	matrix_scale(M, toScale, sideScale, upScale);
	ds_list_add(geometryList, [eGeometry.Block, M, 0])
}
function addCylinder(geometryList, X1, Y1, Z1, X2, Y2, Z2, R)
{
	var dist = point_distance_3d(X1, Y1, Z1, X2, Y2, Z2);
	var M = matrix_build_from_vector(X1, Y1, Z1, X2 - X1, Y2 - Y1, Z2 - Z1, R, R, dist);
	ds_list_add(geometryList, [eGeometry.Cylinder, M, 0, R])
}
geometryList = ds_list_create();
blackHoleList = ds_list_create();

blackHoleSurf = -1;
accretionDiskSurf = -1;

//Create a simple level
addDisk(geometryList, 0, 0, -40, 0, 0, 1, 1500, 40);

//Create accretion disk
accretionDisk = create_accretiondisk(16);

//Create reusable primitives
global.primVbuff = array_create(eGeometry.Num);
global.primVbuff[eGeometry.Sphere] = create_sphere(48, 24, 5, 5);
global.primVbuff[eGeometry.Capsule] = create_capsule(48, 24, 5, 5);
global.primVbuff[eGeometry.Torus] = create_torus(48, 24, 5, 5);
global.primVbuff[eGeometry.Disk] = create_disk(48, 24, 5, 5);
global.primVbuff[eGeometry.Block] = create_block(5, 5);
global.primVbuff[eGeometry.Cylinder] = create_cylinder(32, 5, 5);


instance_create_depth(0, 0, -999999, oSky);
instance_create_depth(0, 0, 20, oInputManager);
instance_create_depth(0, 0, -10, oPlayer);
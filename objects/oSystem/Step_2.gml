/// @description

//Smoothly change the yaw and pitch
yawVel += global.hInputCam - yawVel * .3;
pitchVel += global.vInputCam - pitchVel * .3;
pitch = clamp(pitch + pitchVel, -40, 89);

camMat = matrix_multiply(matrix_build(0, 0, 0, 0, 0, yawVel, 1, 1, 1), camMat);

var upX = oPlayer.upX;
var upY = oPlayer.upY;
var upZ = oPlayer.upZ;

//Update camera matrix' up direction, and orthogonalize it
camMat[8] += upX * .1;
camMat[9] += upY * .1;
camMat[10] += upZ * .1;
matrix_orthogonalize(camMat);

//Use the camera matrix and pitch variable to figure out how to displace the camera
var c = dcos(pitch);
var s = dsin(pitch);
camDirX = - camMat[0] * c + camMat[8] * s;
camDirY = - camMat[1] * c + camMat[9] * s;
camDirZ = - camMat[2] * c + camMat[10] * s;
var dist = 150;
camXfrom = oPlayer.x + camDirX * dist + random_range(-screenShake, screenShake);
camYfrom = oPlayer.y + camDirY * dist + random_range(-screenShake, screenShake);
camZfrom = oPlayer.z + camDirZ * dist + random_range(-screenShake, screenShake);
camXto = oPlayer.x + random_range(-screenShake, screenShake);
camYto = oPlayer.y + random_range(-screenShake, screenShake);
camZto = oPlayer.z + random_range(-screenShake, screenShake);
screenShake *= .8;

//Update view matrix
camera_set_view_mat(view_camera[0], matrix_build_lookat(camXfrom, camYfrom, camZfrom, camXto, camYto, camZto, camMat[8], camMat[9], camMat[10]));
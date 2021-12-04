/// @description
fsm.step();
mainInst.step(1);

//Scale bouncing
xscaleSpd += (xscaleTarget - xscale) * scaleAcceleration;
yscaleSpd += (yscaleTarget - yscale) * scaleAcceleration;
zscaleSpd += (zscaleTarget - zscale) * scaleAcceleration;
xscaleSpd *= scaleFriction;
yscaleSpd *= scaleFriction;
zscaleSpd *= scaleFriction;
xscale += xscaleSpd;
yscale += yscaleSpd;
zscale += zscaleSpd;

//Tilt the torso bone
var targetTilt = 0;
var cx = charMat[1] * inputDirZ - charMat[2] * inputDirY;
var cy = charMat[2] * inputDirX - charMat[0] * inputDirZ;
var cz = charMat[0] * inputDirY - charMat[1] * inputDirX;
targetTilt = - 60 * dot_product_3d(cx, cy, cz, upX, upY, upZ) * moveSpd;
headTilt += (targetTilt - headTilt) * .1;
mainInst.node_rotate_x(1, headTilt);
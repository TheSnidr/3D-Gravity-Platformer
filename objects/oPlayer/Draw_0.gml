/// @description
/*
	This is an ingenious way of projecting a 3D circular shadow down onto geometry.
	I am not the inventor of this technique, I learned it from GreenBlizzzard, but I have refined it slightly
	and reduced the required number of draw calls from three to two.
	It makes use of a trick using blend modes, and the destination alpha channel, which normally isn't used for anything.
*/

//Draw inverted cylinder to the hidden destination alpha channel
var shadowAlpha = .5;
gpu_set_zwriteenable(false);
shader_set(sh_shadow);
gpu_set_blendmode_ext_sepalpha(bm_zero, bm_one, bm_one, bm_zero);
matrix_set(matrix_world, matrix_multiply(matrix_build(0, 0, 0, 0, 0, 0, -radius * xscale, radius * yscale, -200), charMat));
gpu_set_cullmode(cull_clockwise);

shader_set_uniform_f(shader_get_uniform(sh_shadow, "u_color"), 0, 0, 0, 1 - shadowAlpha);
vertex_submit(global.primVbuff[eGeometry.Cylinder], pr_trianglelist, -1);

//Draw cylinder with a special blend mode that filters away the parts of the cylinder that are drawn above the inverted cylinder, resulting in a projected circle
gpu_set_blendmode_ext_sepalpha(bm_dest_color, bm_inv_dest_alpha, bm_one, bm_zero);
shader_set_uniform_f(shader_get_uniform(sh_shadow, "u_color"), 1 - shadowAlpha, 1 - shadowAlpha, 1 - shadowAlpha, 1);
gpu_set_cullmode(cull_counterclockwise);
vertex_submit(global.primVbuff[eGeometry.Cylinder], pr_trianglelist, -1);
gpu_set_zwriteenable(true);
gpu_set_blendmode(bm_normal);

//Draw the player
shader_set(sh_smf_animate_rimlight);
shader_set_uniform_f(shader_get_uniform(sh_smf_animate_rimlight, "u_lightDir"), global.lightDir[0], global.lightDir[1], global.lightDir[2]);
var scale = 13;
matrix_set(matrix_world, matrix_multiply(matrix_build(0, 0, -radius, 0, 0, 0, scale * xscale, scale * yscale, scale * zscale), charMat));
mainInst.draw();
matrix_set(matrix_world, matrix_build_identity());
shader_reset();
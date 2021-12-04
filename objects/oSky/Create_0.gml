/// @description

//Set some GPU settings
gpu_set_texfilter(true);
gpu_set_ztestenable(false);
gpu_set_zwriteenable(false);
gpu_set_texrepeat(true);
gpu_set_cullmode(cull_noculling);


//Precalculate the Worley noise
worleySurfSize = 512;
worleyLayerNumSqrt = 8; //The square root of the number of layers in the z axis. If set to 8, the number of layers will be 8*8 = 64
worleyCellNumSqrt = 8; //The number of cells to compute whorley noise for (must be larger than 5)
var s = surface_create(worleySurfSize, worleySurfSize);
surface_set_target(s);
draw_clear(c_black);
gpu_set_blendmode_ext(bm_one, bm_zero); //This is necessary since we want to use the alpha channel as well
shader_set(sh_worley);
shader_set_uniform_f(shader_get_uniform(sh_worley, "u_cells"), worleyLayerNumSqrt);
shader_set_uniform_f(shader_get_uniform(sh_worley, "u_worldSize"), worleyCellNumSqrt);
shader_set_uniform_f(shader_get_uniform(sh_worley, "u_texelSize"), 1 / worleySurfSize);
draw_primitive_begin(pr_trianglestrip);
draw_vertex(0, 0);
draw_vertex(1, 0);
draw_vertex(0, 1);
draw_vertex(1, 1);
draw_primitive_end();
shader_reset();
surface_reset_target();
bakedWorley = sprite_create_from_surface(s, 0, 0, worleySurfSize, worleySurfSize, 0, 0, 0, 0);
surface_free(s);


function addTri(vbuff, V1, V2, V3, u1, v1, u2, v2, u3, v3, texelSize)
{
	var t = 1 - 2 * texelSize;
	vertex_position_3d(vbuff, V1[0], V1[1], V1[2]);
	vertex_texcoord(vbuff, texelSize + u1 * t, texelSize + v1 * t);
	vertex_position_3d(vbuff, V2[0], V2[1], V2[2]);
	vertex_texcoord(vbuff, texelSize + u2 * t, texelSize + v2 * t);
	vertex_position_3d(vbuff, V3[0], V3[1], V3[2]);
	vertex_texcoord(vbuff, texelSize + u3 * t, texelSize + v3 * t);
}
octmapSize = 1024;
octmapTexel = 1 / octmapSize;

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
format = vertex_format_end();

skyvbuff = vertex_create_buffer();
vertex_begin(skyvbuff, format);
addTri(skyvbuff, [0, 0,  1],  [1, 0, 0], [0, 1, 0],		.5, .5,		1, .5,	.5, 1, octmapTexel);
addTri(skyvbuff, [0, 0, -1],  [1, 0, 0], [0, 1, 0],		 1,  1,		1, .5,	.5, 1, octmapTexel);
addTri(skyvbuff, [0, 0,  1], [-1, 0, 0], [0, 1, 0],		.5, .5,		0, .5,	.5, 1, octmapTexel);
addTri(skyvbuff, [0, 0, -1], [-1, 0, 0], [0, 1, 0],		 0,  1,		0, .5,	.5, 1, octmapTexel);
addTri(skyvbuff, [0, 0,  1],  [1, 0, 0], [0,-1, 0],		.5, .5,		1, .5,	.5, 0, octmapTexel);
addTri(skyvbuff, [0, 0, -1],  [1, 0, 0], [0,-1, 0],		 1,  0,		1, .5,	.5, 0, octmapTexel);
addTri(skyvbuff, [0, 0,  1], [-1, 0, 0], [0,-1, 0],		.5, .5,		0, .5,	.5, 0, octmapTexel);
addTri(skyvbuff, [0, 0, -1], [-1, 0, 0], [0,-1, 0],		 0,  0,		0, .5,	.5, 0, octmapTexel);
vertex_end(skyvbuff);

var s = surface_create(octmapSize, octmapSize);
surface_set_target(s);
draw_clear(c_white);

shader_set(sh_sky2);
shader_set_uniform_f(shader_get_uniform(sh_sky2, "u_octmaptexelsize"), 1 / octmapSize);
shader_set_uniform_f(shader_get_uniform(sh_sky2, "u_cells"), worleyLayerNumSqrt);
shader_set_uniform_f(shader_get_uniform(sh_sky2, "u_invWorldSize"), 1 / worleyCellNumSqrt, 1 / worleyCellNumSqrt, worleyLayerNumSqrt * worleyLayerNumSqrt / worleyCellNumSqrt);
shader_set_uniform_f(shader_get_uniform(sh_sky2, "u_texelSize"), 1 / worleySurfSize);
shader_set_uniform_f(shader_get_uniform(sh_sky2, "u_sparsity"), 2);
vertex_submit(skyvbuff, pr_trianglelist, sprite_get_texture(bakedWorley, 0));
surface_reset_target();
shader_reset();

var s2 = surface_create(octmapSize, octmapSize);
surface_set_target(s2);
draw_surface(s, 0, 0);
//Draw edges
draw_surface_part_ext(s, 1, 1, octmapSize - 2, 1, octmapSize - 1, 0, -1, 1, c_white, 1);
draw_surface_part_ext(s, 1, octmapSize - 2, octmapSize - 2, 1, octmapSize - 1, octmapSize - 1, -1, 1, c_white, 1);
draw_surface_part_ext(s, 1, 1, 1, octmapSize - 2, 0, octmapSize - 1, 1, -1, c_white, 1);
draw_surface_part_ext(s, octmapSize - 2, 1, 1, octmapSize - 2, octmapSize - 1, octmapSize - 1, 1, -1, c_white, 1);
//Draw corners
draw_surface_part(s, 1, 1, 1, 1, 0, 0);
draw_surface_part(s, 1, 1, 1, 1, octmapSize - 1, 0);
draw_surface_part(s, 1, 1, 1, 1, 0, octmapSize - 1);
draw_surface_part(s, 1, 1, 1, 1, octmapSize - 1, octmapSize - 1);
surface_reset_target();
bakedSkyNoise = sprite_create_from_surface(s2, 0, 0, octmapSize, octmapSize, 0, 0, 0, 0);
surface_free(s);
surface_free(s2);
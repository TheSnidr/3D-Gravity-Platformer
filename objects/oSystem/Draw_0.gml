/// @description

//Loop through level geometry and draw them
gpu_set_texrepeat(true);
shader_set(sh_planet);
shader_set_uniform_f(shader_get_uniform(sh_planet, "u_lightDir"), global.lightDir[0], global.lightDir[1], global.lightDir[2]);
var num = ds_list_size(geometryList);
for (var i = 0; i < num; i ++)
{
	var geo = geometryList[| i];
	var type = geo[0];
	matrix_set(matrix_world, geo[1]);
	shader_set_uniform_f(shader_get_uniform(sh_planet, "u_radius"), geo[2]);
	vertex_submit(global.primVbuff[type], pr_trianglelist, sprite_get_texture(texPlanet, 0));
}

//Loop through the black holes of the level
var num = ds_list_size(blackHoleList);
if (num > 0)
{
	//Create the surface onto which we will copy the application surface
	if (!surface_exists(blackHoleSurf))
	{
		blackHoleSurf = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
	}
	//Create the texture for the accretion disk
	if (!surface_exists(accretionDiskSurf))
	{
		accretionDiskSurf = surface_create(512, 512);
		gpu_set_cullmode(cull_noculling);
		surface_set_target(accretionDiskSurf);
		draw_clear(c_black);
		shader_set(sh_create_accretiondisk);
		draw_primitive_begin(pr_trianglestrip);
		draw_vertex(-1, -1);
		draw_vertex(1, -1);
		draw_vertex(-1, 1);
		draw_vertex(1, 1);
		draw_primitive_end();
		shader_reset();
		surface_reset_target();
	}
	var accTex = surface_get_texture(accretionDiskSurf);
	gpu_set_cullmode(cull_counterclockwise);
	gpu_set_zwriteenable(false);
	for (var i = 0; i < num; i ++)
	{
		var geo = blackHoleList[| i];
		var type = geo[0];
		
		var s = 2;
		var h = .3;
		
		//Draw an accretion disk containing "solid" material
		gpu_set_cullmode(cull_clockwise);
		gpu_set_blendmode(bm_normal);
		matrix_set(matrix_world, matrix_multiply(matrix_build(0, 0, 0, 0, 0, current_time / 5, s, s, h), geo[1]));
		shader_set(sh_accretiondisk_solid);
		shader_set_uniform_f(shader_get_uniform(sh_accretiondisk_solid, "u_min"), 1 / s);
		vertex_submit(accretionDisk, pr_trianglelist, accTex);
		
		//Draw an accretion disk to the application surface before copying to the new surface
		gpu_set_cullmode(cull_counterclockwise);
		gpu_set_blendmode_ext_sepalpha(bm_one, bm_one, bm_one, bm_zero);
		matrix_set(matrix_world, matrix_multiply(matrix_build(0, 0, 0, 0, 0, current_time / 10, s, s, h), geo[1]));
		shader_set(sh_accretiondisk);
		shader_set_uniform_f(shader_get_uniform(sh_accretiondisk, "u_alpha"), 0);
		shader_set_uniform_f(shader_get_uniform(sh_accretiondisk, "u_min"), 1 / s);
		vertex_submit(accretionDisk, pr_trianglelist, accTex);
		
		//Draw the polar jets
		matrix_set(matrix_world, matrix_multiply(matrix_build(0, 0, 0, 0, 0, current_time * 2, .1, .1, s), geo[1]));
		shader_set_uniform_f(shader_get_uniform(sh_accretiondisk, "u_min"), 0);
		vertex_submit(accretionDisk, pr_trianglelist, accTex);
	}
	
	//Duplicate the application surface
	shader_reset();
	gpu_set_ztestenable(false);
	gpu_set_cullmode(cull_noculling);
	matrix_set(matrix_world, matrix_build_identity());
	gpu_set_blendmode_ext_sepalpha(bm_one, bm_zero, bm_zero, bm_one);
	surface_set_target(blackHoleSurf);
	draw_clear(c_black);
	draw_surface(application_surface, 0, 0);
	surface_reset_target();
	gpu_set_ztestenable(true);
	gpu_set_zwriteenable(true);
	gpu_set_cullmode(cull_counterclockwise);
	
	//Draw the black holes and their accretion disks
	for (var i = 0; i < num; i ++)
	{
		shader_set(sh_blackhole);
		var geo = blackHoleList[| i];
		var type = geo[0];
		matrix_set(matrix_world, geo[1]);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		shader_set_uniform_f(shader_get_uniform(sh_blackhole, "u_radius"), geo[2]);
		vertex_submit(global.primVbuff[type], pr_trianglelist, surface_get_texture(blackHoleSurf));
		
		var s = 2;
		var h = .3;
		shader_set(sh_accretiondisk);
		gpu_set_blendmode_ext_sepalpha(bm_dest_alpha, bm_one, bm_one, bm_zero);
		matrix_set(matrix_world, matrix_multiply(matrix_build(0, 0, 0, 0, 0, current_time / 10, s, s, h), geo[1]));
		shader_set_uniform_f(shader_get_uniform(sh_accretiondisk, "u_min"), 1 / s);
		shader_set_uniform_f(shader_get_uniform(sh_accretiondisk, "u_alpha"), 1);
		vertex_submit(accretionDisk, pr_trianglelist, accTex);
	}
	shader_reset();
}
matrix_set(matrix_world, matrix_build_identity());
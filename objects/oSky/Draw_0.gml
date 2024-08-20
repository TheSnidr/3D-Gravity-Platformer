/// @description

//Set some GPU settings
gpu_set_texfilter(true);
gpu_set_texrepeat(true);
gpu_set_ztestenable(true);
gpu_set_zwriteenable(false);
gpu_set_cullmode(cull_noculling);

//Day and night cycle
var V = matrix_get(matrix_view);
global.lightDir[0] = cos(current_time / 20000);
global.lightDir[2] = - sin(current_time / 20000);
global.lightModifier = lerp(global.lightModifier, dot_product_3d(V[2], V[6], V[10], global.lightDir[0], global.lightDir[1], global.lightDir[2]), .07);
camera_apply(view_camera[0]);
shader_set(sh_sky3);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_texScale"), 1 - 2 / octmapSize);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_time"), frac(current_time / 80000));
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_cells"), worleyLayerNumSqrt);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_invWorldSize"), 1 / worleyCellNumSqrt, 1 / worleyCellNumSqrt, worleyLayerNumSqrt * worleyLayerNumSqrt / worleyCellNumSqrt);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_texelSize"), 1 / worleySurfSize);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_sparsity"), 4. + .5 * sin(current_time / 10000));
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_lightModifier"), global.lightModifier);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_lightDir"), global.lightDir[0], global.lightDir[1], global.lightDir[2]);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_sunColor"), 1.2, 1.2, 1.0);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_skyColBright"), .2, .4, .9);
shader_set_uniform_f(shader_get_uniform(sh_sky3, "u_skyColDark"), .15, .14, .4);
texture_set_stage(shader_get_sampler_index(sh_sky3, "u_noiseSampler"), sprite_get_texture(bakedWorley, 0));
vertex_submit(skyvbuff, pr_trianglelist, sprite_get_texture(bakedSkyNoise, 0));
shader_reset();

//Reset GPU settings
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_counterclockwise);
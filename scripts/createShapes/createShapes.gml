//A very bare-bones custom format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
global.format = vertex_format_end();

//Function for creating a sphere as a pr_trianglelist vertex buffer
function create_sphere(hVerts, vVerts, hRep, vRep)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi;
			var ya2 = (yy+1) / vVerts * pi;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			vertex_position_3d(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			
			vertex_position_3d(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
		}
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

//Function for creating a block as a pr_trianglelist vertex buffer
function create_block(hRep, vRep)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	
	//+z
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, 0, 0, 1);
	vertex_texcoord(vbuff, 0, 0);
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 0, 0, 1);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, 0, 0, 1);
	vertex_texcoord(vbuff, 0, vRep);
	
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, 0, 0, 1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 0, 0, 1);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 0, 0, 1);
	vertex_texcoord(vbuff, hRep, vRep);
	
	//-z
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, 0, 0, -1);
	vertex_texcoord(vbuff, 0, 0);
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, 0, 0, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 0, 0, -1);
	vertex_texcoord(vbuff, hRep, 0);
	
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, 0, 0, -1);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 0, 0, -1);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 0, 0, -1);
	vertex_texcoord(vbuff, hRep, 0);
	
	//+x
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 1, 0, 0);
	vertex_texcoord(vbuff, 0, 0);
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 1, 0, 0);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 1, 0, 0);
	vertex_texcoord(vbuff, hRep, 0);
	
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 1, 0, 0);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 1, 0, 0);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 1, 0, 0);
	vertex_texcoord(vbuff, hRep, 0);
	
	//-x
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, -1, 0, 0);
	vertex_texcoord(vbuff, 0, 0);
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, -1, 0, 0);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, -1, 0, 0);
	vertex_texcoord(vbuff, 0, vRep);
	
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, -1, 0, 0);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, -1, 0, 0);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, -1, 0, 0);
	vertex_texcoord(vbuff, hRep, vRep);
	
	//+y
	vertex_position_3d(vbuff, -1, 1, -1);
	vertex_normal(vbuff, 0, 1, 0);
	vertex_texcoord(vbuff, 0, 0);
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, 0, 1, 0);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 0, 1, 0);
	vertex_texcoord(vbuff, 0, vRep);
	
	vertex_position_3d(vbuff, 1, 1, -1);
	vertex_normal(vbuff, 0, 1, 0);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, -1, 1, 1);
	vertex_normal(vbuff, 0, 1, 0);
	vertex_texcoord(vbuff, hRep, 0);
	vertex_position_3d(vbuff, 1, 1, 1);
	vertex_normal(vbuff, 0, 1, 0);
	vertex_texcoord(vbuff, hRep, vRep);
	
	//-y
	vertex_position_3d(vbuff, -1, -1, -1);
	vertex_normal(vbuff, 0, -1, 0);
	vertex_texcoord(vbuff, 0, 0);
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 0, -1, 0);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, 0, -1, 0);
	vertex_texcoord(vbuff, hRep, 0);
	
	vertex_position_3d(vbuff, 1, -1, -1);
	vertex_normal(vbuff, 0, -1, 0);
	vertex_texcoord(vbuff, 0, vRep);
	vertex_position_3d(vbuff, 1, -1, 1);
	vertex_normal(vbuff, 0, -1, 0);
	vertex_texcoord(vbuff, hRep, vRep);
	vertex_position_3d(vbuff, -1, -1, 1);
	vertex_normal(vbuff, 0, -1, 0);
	vertex_texcoord(vbuff, hRep, 0);
	
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

//Function for creating a torus as a pr_trianglelist vertex buffer
function create_torus(hVerts, vVerts, hRep, vRep)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * 2 * pi;
			var ya2 = (yy+1) / vVerts * 2 * pi;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
		}
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

//Function for creating a disk as a pr_trianglelist vertex buffer
function create_disk(hVerts, vVerts, hRep, vRep)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		vertex_position_3d(vbuff, 1, 0, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, hRep, 0);
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, xc1 * hRep, xs1 * vRep);
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, xc2 * hRep, xs2 * vRep);
		
		vertex_position_3d(vbuff, 1, 0, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, hRep, 0);
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, xc2 * hRep, xs2 * vRep);
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, xc1 * hRep, xs1 * vRep);
		
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi;
			var ya2 = (yy+1) / vVerts * pi;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			
			vertex_position_3d(vbuff, xc1, xs1, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, xc2, xs2, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
		}
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

//Function for creating a capsule as a pr_trianglelist vertex buffer
function create_capsule(hVerts, vVerts, hRep, vRep)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	for (var xx = 0; xx < hVerts; xx ++)
	{
		var xa1 = xx / hVerts * 2 * pi;
		var xa2 = (xx+1) / hVerts * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		vertex_position_3d(vbuff, 0, 0, 0);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / hVerts * hRep, 0);
		vertex_position_3d(vbuff, 0, 0, 0);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, 0);
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / hVerts * hRep, vRep);
		
		vertex_position_3d(vbuff, 0, 0, 0);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, 0);
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, vRep);
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / hVerts * hRep, vRep);
		
		for (var yy = 0; yy < vVerts; yy ++)
		{
			var ya1 = yy / vVerts * pi / 2;
			var ya2 = (yy+1) / vVerts * pi / 2;
			var yc1 = cos(ya1);
			var ys1 = sin(ya1);
			var yc2 = cos(ya2);
			var ys2 = sin(ya2);
			
			//Draw the bottom hemisphere
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, - yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, - yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, - yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, - yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, - yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 0);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, - yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			
			//Draw top hemisphere
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc1 * ys1, xs1 * ys1, yc1);
			vertex_texcoord(vbuff, xx / hVerts * hRep, yy / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
			
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc1 * ys2, xs1 * ys2, yc2);
			vertex_texcoord(vbuff, xx / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc2 * ys2, xs2 * ys2, yc2);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, (yy+1) / vVerts * vRep);
			vertex_position_3d(vbuff, 0, 0, 1);
			vertex_normal(vbuff, xc2 * ys1, xs2 * ys1, yc1);
			vertex_texcoord(vbuff, (xx+1) / hVerts * hRep, yy / vVerts * vRep);
		}
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}

//Function for creating a cylinder as a pr_trianglelist vertex buffer
function create_cylinder(steps, hRep, vRep)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	for (var xx = 0; xx < steps; xx ++)
	{
		var xa1 = xx / steps * 2 * pi;
		var xa2 = (xx+1) / steps * 2 * pi;
		var xc1 = cos(xa1);
		var xs1 = sin(xa1);
		var xc2 = cos(xa2);
		var xs2 = sin(xa2);
		
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / steps * hRep, 0);
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / steps * hRep, 0);
		vertex_position_3d(vbuff, xc1, xs1, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / steps * hRep, vRep);
		
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / steps * hRep, 0);
		vertex_position_3d(vbuff, xc2, xs2, 1);
		vertex_normal(vbuff, xc2, xs2, 0);
		vertex_texcoord(vbuff, (xx+1) / steps * hRep, vRep);
		vertex_position_3d(vbuff, xc1, xs1, 1);
		vertex_normal(vbuff, xc1, xs1, 0);
		vertex_texcoord(vbuff, xx / steps * hRep, vRep);
		
		//Bottom lid
		vertex_position_3d(vbuff, 1, 0, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, hRep, .5 * vRep);
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, (.5 + .5 * xc2) * hRep, (.5 + .5 * xs2) * vRep);
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, (.5 + .5 * xc1) * hRep, (.5 + .5 * xs1) * vRep);
		
		//Top lid
		vertex_position_3d(vbuff, 1, 0, 1);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, hRep, .5 * vRep);
		vertex_position_3d(vbuff, xc1, xs1, 1);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, (.5 + .5 * xc1) * hRep, (.5 + .5 * xs1) * vRep);
		vertex_position_3d(vbuff, xc2, xs2, 1);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, (.5 + .5 * xc2) * hRep, (.5 + .5 * xs2) * vRep);
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}



//Function for creating a disk as a pr_trianglelist vertex buffer
function create_accretiondisk(verts)
{
	var vbuff = vertex_create_buffer();
	vertex_begin(vbuff, global.format);
	
	var s = sqrt(1. + sqr(sin(pi / verts)));
	
	for (var xx = 0; xx < verts; xx ++)
	{
		var xa1 = xx / verts * 2 * pi;
		var xa2 = (xx+1) / verts * 2 * pi;
		var xc1 = s * cos(xa1);
		var xs1 = s * sin(xa1);
		var xc2 = s * cos(xa2);
		var xs2 = s * sin(xa2);
		
		vertex_position_3d(vbuff, 0, 0, 1);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, 0, 0);
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, 0, 0);
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, 1);
		vertex_texcoord(vbuff, 0, 0);
		
		vertex_position_3d(vbuff, 0, 0, -1);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, 0, 0);
		vertex_position_3d(vbuff, xc2, xs2, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, 0, 0);
		vertex_position_3d(vbuff, xc1, xs1, 0);
		vertex_normal(vbuff, 0, 0, -1);
		vertex_texcoord(vbuff, 0, 0);
	}
	vertex_end(vbuff);
	vertex_freeze(vbuff);
	return vbuff;
}
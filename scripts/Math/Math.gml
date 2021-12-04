function matrix_orthogonalize(M)
{
	/*
		This is a super important function for games like this!
		It makes sure the three vectors of the given matrix are all unit length
		and perpendicular to each other, using the up direciton as master.
		GameMaker does something similar when creating a lookat matrix actually. People often use [0, 0, 1]
		as the up direction, but this vector is not used directly for creating the view matrix - rather, 
		it's being used as reference, and the entire view matrix is being orthogonalized to the looking direction.
	*/
	var l = M[8] * M[8] + M[9] * M[9] + M[10] * M[10];
	if (l == 0){exit;}
	l = 1 / sqrt(l);
	M[@ 8] *= l;
	M[@ 9] *= l;
	M[@ 10] *= l;
	
	M[@ 4] = M[9] * M[2] - M[10] * M[1];
	M[@ 5] = M[10] * M[0] - M[8] * M[2];
	M[@ 6] = M[8] * M[1] - M[9] * M[0];
	var l = M[4] * M[4] + M[5] * M[5] + M[6] * M[6];
	if (l == 0){exit;}
	l = 1 / sqrt(l);
	M[@ 4] *= l;
	M[@ 5] *= l;
	M[@ 6] *= l;
	
	M[@ 0] = M[9] * M[6] - M[10] * M[5];
	M[@ 1] = M[10] * M[4] - M[8] * M[6];
	M[@ 2] = M[8] * M[5] - M[9] * M[4];
	var l = M[0] * M[0] + M[1] * M[1] + M[2] * M[2];
	if (l == 0){exit;}
	l = - 1 / sqrt(l);
	M[@ 0] *= l;
	M[@ 1] *= l;
	M[@ 2] *= l;
}

function matrix_scale(M, toScale, siScale, upScale)
{
	M[@ 0] *= toScale;
	M[@ 1] *= toScale;
	M[@ 2] *= toScale;
	M[@ 4] *= siScale;
	M[@ 5] *= siScale;
	M[@ 6] *= siScale;
	M[@ 8] *= upScale;
	M[@ 9] *= upScale;
	M[@ 10] *= upScale;
	return M;
}
function matrix_build_from_vector(X, Y, Z, vx, vy, vz, toScale, siScale, upScale)
{
	var M = [0, 1, 1, 0, 0, 0, 0, 0, vx, vy, vz, 0, X, Y, Z, 1];
	if abs(vx) < min(abs(vy), abs(vz))
	{
		M[0] = 1;
	}
	matrix_orthogonalize(M);
	matrix_scale(M, toScale, siScale, upScale)
	return M;
}
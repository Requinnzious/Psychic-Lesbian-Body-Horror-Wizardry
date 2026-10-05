//Clear the screen
draw_clear(#8fEfff);

//Rotate the camera around the center of the tile we're in
xOffset = HalfTile - dcos(lookDir + lookDirOffset) * HalfTile;
yOffset = HalfTile + dsin(lookDir + lookDirOffset) * HalfTile;


//Screenshake
var shakeX = screenShake * random_range(-screenShakeIntensity, screenShakeIntensity);
var shakeY = screenShake * random_range(-screenShakeIntensity, screenShakeIntensity);
var shakeZ = screenShake * random_range(-screenShakeIntensity, screenShakeIntensity);
screenShake = max(screenShake - 1, 0);


//Set up camera projection
xFrom = shakeX + x + xOffset + xFromOffset;
yFrom = shakeY + y + yOffset + yFromOffset;
zFrom = shakeZ + z           + zFromOffset;

xTo   = xFrom + dcos(lookDir + lookDirOffset) + xToOffset;
yTo   = yFrom - dsin(lookDir + lookDirOffset) + yToOffset;
zTo   = zFrom - dsin(lookPit + lookPitOffset) + zToOffset;

projMat = matrix_build_projection_perspective_fov(80, -16/9, 1, 32000);
viewMat = matrix_build_lookat(xFrom, yFrom, zFrom, xTo, yTo, zTo, 0, 0, -1);


//Apply camera transforms
var camera  = camera_get_active();
camera_set_proj_mat(camera, projMat);
camera_set_view_mat(camera, viewMat);
camera_apply(camera);


//Render everything after the transforms are set
shader_set(shDefault);
	World.render();
shader_reset();

matrix_set(matrix_world, World.identityMatrix);
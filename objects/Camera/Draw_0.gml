screenShake = max(screenShake - 1, 0);

draw_clear(#8fEfff);

xOffset = 16 - dcos(lookDir + lookDirOffset) * 16
yOffset = 16 + dsin(lookDir + lookDirOffset) * 16

//Set up camera projection
var shakeX = screenShake * random_range(-screenShakeIntensity, screenShakeIntensity);
var shakeY = screenShake * random_range(-screenShakeIntensity, screenShakeIntensity);
var shakeZ = screenShake * random_range(-screenShakeIntensity, screenShakeIntensity);

xFrom = shakeX + x + xOffset + xFromOffset;
yFrom = shakeY + y + yOffset + yFromOffset;
zFrom = shakeZ + z + zOffset;

xTo = xFrom + dcos(lookDir + lookDirOffset) + xToOffset;
yTo = yFrom - dsin(lookDir + lookDirOffset) + yToOffset;
zTo = zFrom - dsin(lookPit + lookPitOffset) + zToOffset;

var camera  = camera_get_active();
projMat = matrix_build_projection_perspective_fov(80, -16/9, 1, 32000);
viewMat = matrix_build_lookat(xFrom, yFrom, zFrom, xTo, yTo, zTo, 0, 0, -1);

camera_set_proj_mat(camera, projMat);
camera_set_view_mat(camera, viewMat);
camera_apply(camera);

//Render everything after the transforms are set
shader_set(shDefault);
World.render();
shader_reset();

matrix_set(matrix_world, World.identityMatrix);
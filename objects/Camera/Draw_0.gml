draw_clear(#8fEfff);

//Set up camera projection
xFrom = x + xOffset + xFromOffset;
yFrom = y + yOffset + yFromOffset;
zFrom = z + zOffset;

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
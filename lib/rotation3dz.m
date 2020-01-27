function rotation = rotation3dz(theta)
%ROTATION3DX Creates a 3D rotation matrix to rotate around the x axis
rotation = [
    cos(theta) -sin(theta) 0;
    sin(theta) cos(theta) 0;
    0 0 1;
];
end


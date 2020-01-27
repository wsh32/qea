function rotation = rotation3dx(theta)
%ROTATION3DX Creates a 3D rotation matrix to rotate around the x axis
rotation = [
    1 0 0;
    0 cos(theta) -sin(theta);
    0 sin(theta) cos(theta)
];
end


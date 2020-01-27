function rotation = rotation3dy(theta)
%ROTATION3DX Creates a 3D rotation matrix to rotate around the x axis
rotation = [
    cos(theta) 0 sin(theta);
    0 1 0;
    -sin(theta) 0 cos(theta);
];
end


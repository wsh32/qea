function rot = rotation2d(theta)
%ROTATION2D Creates a 3D rotation matrix to rotate around the x axis
    rot = [
        cos(theta) -sin(theta);
        sin(theta)  cos(theta);
    ];
end

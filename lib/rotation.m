function rot = rotation(theta)
    rot = [
        cos(theta) -sin(theta);
        sin(theta)  cos(theta);
    ];
end

hold on
axis equal

rect = [1 -1 -1 1 1; 2 2 -2 -2 2];
stretch = [2 0; 0 1/3];
rect_transform = stretch * rect;

% plot rectangle
plot(rect(1, :), rect(2, :), 'bx-')
plot(rect_transform(1, :), rect_transform(2, :), 'rx-')
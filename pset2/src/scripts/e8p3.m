4.7
hold off
clf()
hold on
axis equal
clear

rect = [1 -1 -1 1 1; 2 2 -2 -2 2; 1 1 1 1 1];
translate = [1 0 2; 0 1 3; 0 0 1];
rect_transform = translate * rect;

% plot rectangle
plot(rect(1, :), rect(2, :), 'bx-')
plot(rect_transform(1, :), rect_transform(2, :), 'rx-')
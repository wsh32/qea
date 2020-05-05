function [r_pos, circle_center, circle_radius] = generate_map(r, theta)

hold on

% load('data/gauntlet_scans.mat')
warning('off','all')

% r = r_all(:,1);
% theta = theta_all(:,1);

% Plot lidar scan
r_clean_index = find((r ~= 0) & (r < 3));
r_clean = r(r_clean_index);
theta_clean = theta(r_clean_index);
[x_scan, y_scan] = pol2cart(theta_clean, r_clean);
points = [x_scan y_scan];
plot(x_scan, y_scan, '.')
axis equal

resolution = 0.05;
offset = 0.5;
x_grid = resolution * round((min(x_scan)-offset:resolution:max(x_scan)+offset) / resolution);
y_grid = resolution * round((min(y_scan)-offset:resolution:max(y_scan)+offset) / resolution);
[x, y] = meshgrid(x_grid, y_grid);
f = 0;

% find walls
d = 0.01;
n = 500;
wall_weight = 0.0125;
% should be 3 walls
for i=1:3
    [endpoints, inliers, outliers, m, b] = ransac_line_fit(points, d, n, 0);
    for j=1:length(inliers)
        f = f - wall_weight * (log(sqrt((x-inliers(j,1)).^2 + (y-inliers(j,2)).^2)));
    end
    points=outliers;
end

% Find circle
d = 0.01;
n = 10000;
r_max = 0.3;
circle_weight = 1;
[circle_endpoints, circle_inliers, circle_outliers, near_matches, circle_center, circle_radius] = ransac_circle_fit(points, r_max, d, n, 0);

% place sink at circle center
f = f + circle_weight * log(sqrt((x-circle_center(1)).^2 + (y-circle_center(2)).^2));

% find obstacles
d = 0.01;
n = 1000;
obstacle_weight = 0.0125;
% should be 3 walls
while length(points) >= 3
    [endpoints, inliers, outliers, m, b] = ransac_line_fit(points, d, n, 0);
    for j=1:length(inliers)
        f = f - obstacle_weight * (log(sqrt((x-inliers(j,1)).^2 + (y-inliers(j,2)).^2)));
    end
    points=outliers;
end


contour(x, y, f, 'ShowText', 'On')
[u, v] = gradient(f);
quiver(x, y, -u, -v)

% Find path of robot from origin
r = [0 0];
lambda = .75;
delta = 0.99;
threshold = -5;
r_pos = [];
while 1
    r_pos = [r_pos; r];
    r_round = resolution * round(r / resolution);
    r_grad = -[u(y_grid == r_round(2), x_grid == r_round(1)), v(y_grid == r_round(2), x_grid == r_round(1))] * lambda;
    quiver(r(1), r(2), r_grad(1), r_grad(2), 'c', 'LineWidth', 2, 'MaxHeadSize', 0.5)
    
    r = r + r_grad;
    %z = double(subs(f, [x, y], [r(1), r(2)]));
    lambda = lambda * delta;
    
    %if f(y_grid == r_round(2), x_grid == r_round(1)) < threshold
    distance_from_center = r - circle_center
    if norm(distance_from_center) < .1
        r_pos = [r_pos; r];
        break
    end
end

end
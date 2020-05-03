clear
clf
hold on

load('data/gauntlet_scans.mat')
warning('off','all')

r = r_all(:,1);
theta = theta_all(:,1);

% Plot lidar scan
r_clean_index = find((r ~= 0) & (r < 3));
r_clean = r(r_clean_index);
theta_clean = theta(r_clean_index);
[x_scan, y_scan] = pol2cart(theta_clean, r_clean);
points = [x_scan y_scan];
plot(x_scan, y_scan, '.')
axis equal

[x, y] = meshgrid(min(x_scan)-0.5:0.05:max(x_scan)+0.5, min(y_scan)-0.5:0.05:max(y_scan)+0.5);
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
circle_weight = 5;
[circle_endpoints, circle_inliers, circle_outliers, near_matches, center, radius] = ransac_circle_fit(points, r_max, d, n, 0);

% place sink at circle center
f = f + circle_weight * log(sqrt((x-center(1)).^2 + (y-center(2)).^2));

% find obstacles
d = 0.01;
n = 1000;
obstacle_weight = 0.025;
% should be 3 walls
while length(points) >= 3
    [endpoints, inliers, outliers, m, b] = ransac_line_fit(points, d, n, 0);
    for j=1:length(inliers)
        f = f - obstacle_weight * (log(sqrt((x-inliers(j,1)).^2 + (y-inliers(j,2)).^2)));
    end
    points=outliers;
end


contour(x, y, f)
[u, v] = gradient(f);
quiver(x, y, -u, -v)
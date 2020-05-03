function [inliers, outliers, near_matches, center, radius] = ransac_circle_fit_single(points, pointa, pointb, pointc, d, visualize)
    % lienar regression for center and radius of circle
    A = [
        pointa(1) pointa(2) 1;
        pointb(1) pointb(2) 1;
        pointc(1) pointc(2) 1;
    ];
    b = [
        (-pointa(1)^2 - pointa(2)^2);
        (-pointb(1)^2 - pointb(2)^2);
        (-pointc(1)^2 - pointc(2)^2);
    ];
    w = A\b;  % perform linear regression
    % extract center point and radius
    % A = -2h
    % B = -2k
    % C = h^2 + k^2 - r^2
    h = w(1) / -2;
    k = w(2) / -2;
    center = [h k];
    radius = sqrt(h^2 + k^2 - w(3));
    
    % find relative position from center
    diff_points = points - center;
    % find difference of radius
    r_points = vecnorm(diff_points');
    diff_r = r_points - radius;
    % check if in range
    inlier_indexes = abs(diff_r) <= d;
    outlier_indexes = abs(diff_r) > d;
    near_match_indexes = (abs(diff_r) < d*2) & ~(abs(diff_r) <= d);
    
    inliers = points(inlier_indexes, :);
    outliers = points(outlier_indexes, :);
    near_matches = points(near_match_indexes, :);
    
    if visualize == 1
        clf
        hold on
        plot(inliers(:,1), inliers(:,2), 'g.');
        plot(outliers(:,1), outliers(:,2), 'r.');
        plot_circle(center, radius, 'k');
        plot(pointa(1), pointa(2), 'bo')
        plot(pointb(1), pointb(2), 'bo')
        plot(pointc(1), pointc(2), 'bo')
        axis equal
    end
end
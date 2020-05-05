function [inliers, outliers] = ransac_line_fit_single(points, pointa, pointb, d, visualize)
    v = pointb - pointa;
    orthv = [-v(2); v(1)] / norm([-v(2); v(1)]);
    
    % get difference
    diff_points = points - pointa;
    % project difference onto orthagonal
    diff_orth = diff_points * orthv;
    
    % check if in range
    inlier_indexes = abs(diff_orth) <= d;
    outlier_indexes = abs(diff_orth) > d;
    
    inliers = points(inlier_indexes, :);
    outliers = points(outlier_indexes, :);
    
    if visualize == 1
        clf
        hold on
        plot(inliers(:,1), inliers(:,2), 'g.');
        plot(outliers(:,1), outliers(:,2), 'r.');
        plot(pointa(1), pointa(2), 'ko', pointb(1), pointb(2), 'ko', 'MarkerFaceColor', 'k');
        axis equal
    end
end
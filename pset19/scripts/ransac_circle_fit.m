function [best_endpoints, best_inliers, best_outliers, best_near_matches, c, r] = ransac_circle_fit(points, r_max, d, n, visualize)
    best_inliers = [];
    best_outliers = [];
    best_endpoints = [];
    best_near_matches = [];
    found_candidate = 0;
    for i=1:n
        endpoints = datasample(points, 3, 'Replace', false);
        [inliers, outliers, near_matches, center, radius] = ransac_circle_fit_single(points, endpoints(1,:), endpoints(2,:), endpoints(3,:), d, 0);
        if length(inliers) > length(best_inliers) && (radius < r_max) && isempty(near_matches)
            found_candidate = 1;
            best_inliers = inliers;
            best_outliers = outliers;
            best_endpoints = endpoints;
            best_near_matches = near_matches;
            c = center;
            r = radius;
        end
    end
    
    if visualize == 1 && found_candidate == 1
        clf
        hold on
        plot(best_inliers(:,1), best_inliers(:,2), 'g.');
        plot(best_outliers(:,1), best_outliers(:,2), 'r.');
        plot(best_near_matches(:,1), best_near_matches(:,2), 'r*');
        plot_circle(c, r, 'k');
        plot(best_endpoints(1, 1), best_endpoints(1, 2), 'bo')
        plot(best_endpoints(2, 1), best_endpoints(2, 2), 'bo')
        plot(best_endpoints(3, 1), best_endpoints(3, 2), 'bo')
        axis equal
    end
    
    if found_candidate == 0
        disp("No circle found")
    end
end
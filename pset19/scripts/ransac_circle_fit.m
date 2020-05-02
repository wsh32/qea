function [best_endpoints, best_inliers, best_outliers, c, r] = ransac_circle_fit(points, r_max, d, n, visualize)
    best_inliers = [];
    best_outliers = [];
    best_endpoints = [];
    for i=1:n
        endpoints = datasample(points, 3, 'Replace', false);
        [inliers, outliers, center, radius] = ransac_circle_fit_single(points, endpoints(1,:), endpoints(2,:), endpoints(3,:), d, 0);
        if length(inliers) > length(best_inliers) && radius < r_max
            best_inliers = inliers;
            best_outliers = outliers;
            best_endpoints = endpoints;
            c = center;
            r = radius;
        end
    end
    
    if visualize == 1
        clf
        hold on
        plot(inliers(:,1), inliers(:,2), 'g.');
        plot(outliers(:,1), outliers(:,2), 'r.');
        plot_circle(center, radius, 'k');
        plot(best_endpoints(1, 1), best_endpoints(1, 2), 'bo')
        plot(best_endpoints(2, 1), best_endpoints(2, 2), 'bo')
        plot(best_endpoints(3, 1), best_endpoints(3, 2), 'bo')
        axis equal
    end
end
function [best_endpoints, best_inliers, best_outliers, m, b] = ransac(points, d, n, visualize)
    best_inliers = [];
    best_outliers = [];
    best_endpoints = [];
    for i=1:n
        endpoints = datasample(points, 2, 'Replace', false);
        [inliers, outliers] = run_ransac_single(points, endpoints(1,:), endpoints(2,:), d, 0);
        if length(inliers) > length(best_inliers)
            best_inliers = inliers;
            best_outliers = outliers;
            best_endpoints = endpoints;
        end
    end
    
    m = (best_endpoints(2, 2) - best_endpoints(1, 2)) / (best_endpoints(1, 2) - best_endpoints(1, 1));
    b = best_endpoints(1, 2) - m * best_endpoints(1, 1);
    
    if visualize == 1
        clf
        hold on
        plot(best_inliers(:,1), best_inliers(:,2), 'g.');
        plot(best_outliers(:,1), best_outliers(:,2), 'r.');
        plot(best_endpoints(:,1), best_endpoints(:,2), 'ko-', 'MarkerFaceColor', 'k');
        axis equal
    end
end
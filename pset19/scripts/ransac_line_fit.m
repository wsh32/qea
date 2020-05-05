function [best_endpoints, best_inliers, best_outliers, m, b] = ransac_line_fit(points, d, n, consider_max_dist, visualize)
    best_inliers = [];
    best_outliers = [];
    best_endpoints = [];
    for i=1:n
        endpoints = datasample(points, 2, 'Replace', false);
        [inliers, outliers] = ransac_line_fit_single(points, endpoints(1,:), endpoints(2,:), d, 0);
        
        biggest_gap = max(vecnorm(diff(inliers)'));
        
        if (biggest_gap < 0.2 || consider_max_dist==0) && length(inliers) > length(best_inliers)
            best_inliers = inliers;
            best_outliers = outliers;
            best_endpoints = endpoints;
        end
    end
    
    m = (best_endpoints(2, 2) - best_endpoints(1, 2)) / (best_endpoints(1, 2) - best_endpoints(1, 1));
    b = best_endpoints(1, 2) - m * best_endpoints(1, 1);
    
    inliers_sorted = sortrows(best_inliers);
    best_endpoints = [inliers_sorted(1,:); inliers_sorted(end,:)];
    
    if visualize == 1
        clf
        hold on
        plot(best_outliers(:,1), best_outliers(:,2), 'r.');
        plot(best_inliers(:,1), best_inliers(:,2), 'g.');
        plot(best_endpoints(:,1), best_endpoints(:,2), 'ko-');%, 'MarkerFaceColor', 'k');
        axis equal
    end
end
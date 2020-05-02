function [] = plot_circle(center, radius, options)
    % x = r * cos(t) + center x
    % y = r * sin(t) + center y
    t = linspace(0, 2*pi, 100);
    
    x = radius * cos(t) + center(1);
    y = radius * sin(t) + center(2);
    plot(x, y, options);
end


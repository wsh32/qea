clear
syms x y
assume(x, {'real'})
assume(y, {'real'})

f = x * y - x^2 - y^2 - 2*x - 2*y - 4;
grad = [diff(f, x), diff(f, y)];

[x_grid, y_grid] = meshgrid(-3:0.1:1, -3:0.1:1);
f_grid = x_grid.*y_grid - x_grid.^2 - y_grid.^2 - 2*x_grid - 2*y_grid + 4;

figure()
hold on
[px, py] = gradient(f_grid, 0.1, 0.1);
contour(f_grid)
quiver(px, py)

figure()
hold on
contourf(x_grid, y_grid, f_grid)
axis equal
r = [1 -1];
lambda = 0.1;
delta = 1.2;
threshold = 0.1;
while 1
    r_grad = double(subs(grad, [x, y], [r(1), r(2)])) * lambda;
    quiver(r(1), r(2), r_grad(1), r_grad(2), 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5)
    
    r = r + r_grad;
    %z = double(subs(f, [x, y], [r(1), r(2)]));
    lambda = lambda * delta;
    
    if norm(r_grad) < threshold
        break
    end
end

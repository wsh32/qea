A = [2 1; 3 -1; 0 4];
v = [-2; 1];
u = [2 -3 1];

A * v
% ans = 
%     -3
%     -7
%     -4

u * A
% ans =
%     -5    -9

A(1:2, :) * v
% ans =
%     -3
%     -7

u * A(:, 2)
% ans = 9
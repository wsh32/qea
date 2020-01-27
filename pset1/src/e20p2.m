loads('temps.mat')  % load T
offset = 32 * ones(size(T))
scale = 5 / 9 * eye(4)

% convert farenheit to celsius
T_celsius = scale * (T - offset)
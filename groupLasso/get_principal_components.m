function [result, v] = get_principal_components(X, numComponents)

X = scal(X, mean(X));

[~, ~, v] = svd(X);

v = v(:, 1:numComponents);
result = X*v;


function [flag, i] = check_solution(X, beta, res, indices, penalties, lambda, alpha, tol)

flag = 1;
for i = 1:numel(indices)
    if any(any(beta(indices{i}, :) ~= 0)) && abs(norm(X(:, indices{i})'*res, 'fro') - penalties(i)*lambda - 2*alpha*norm(beta(indices{i}, :), 'fro')) > tol
        flag = 0;
        break;
    end
end
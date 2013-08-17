function [beta, objValues, res] = get_solution_frobenius(X, Y, betaInit, lambda, alpha, tol, maxIter, penalties, indices)

    G = numel(indices);
    n = numel(Y);
    objValues = zeros(1, maxIter);
    activeIndex = ones(1, G);
    iter = 0;

    [U, D, V] = get_svd(X, indices);
    penalties = penalties * lambda;
    beta = betaInit;
    res = Y - X*beta;
    pen = get_penalty(beta, penalties, alpha, indices);
    while iter < maxIter
        for i = find(activeIndex > 0)
            r = res + X(:, indices{i}) * beta(indices{i}, :);
            pen = pen - penalties(i)*norm(beta(indices{i}, :), 'fro') - alpha*norm(beta(indices{i}, :), 'fro')^2;
            u = X(:, indices{i})' * r;
            if norm(u, 'fro') > penalties(i)
                activeIndex(i) = 1;
                theta = get_root(r, U{i}, D{i}, penalties(i), alpha, beta(indices{i}, :));
                beta(indices{i}, :) = V{i} * ((D{i}*D{i} + (penalties(i)/theta+2*alpha)*eye(size(D{i}))) \ (D{i} * U{i}' * r));
                res = r - X(:, indices{i}) * beta(indices{i}, :);
                pen = pen + penalties(i)*norm(beta(indices{i}, :), 'fro') + alpha*norm(beta(indices{i}, :), 'fro')^2;
            else
                activeIndex(i) = 0;
                beta(indices{i}, :) = 0 * beta(indices{i}, :);
                res = r;
            end
            obj =  0.5*norm(res, 'fro')^2 + pen;
            iter = iter + 1;
            objValues(iter) = obj;
        end
        %check kkt conditions
        kktNorms = zeros(1, G);
        betaNorms = zeros(1, G);
        for i = 1:G
            kktNorms(i) = norm(X(:, indices{i})'*res, 'fro');
            betaNorms(i) = norm(beta(indices{i}, :), 'fro');
        end
        idx = find(activeIndex > 0);
        if isempty(idx) || max(abs(kktNorms(idx) - penalties(idx) - 2*alpha*betaNorms(idx))) < tol
            %converged, so check if remaining variables should be nonzero
            idx = activeIndex;
            for i = 1:G
                if idx(i) == 0 && kktNorms(i) > penalties(i)
                    idx(i) = 1;
                end
            end
            if any(idx ~= activeIndex)
                activeIndex = idx;
            else
                break;
            end
        end
    end
    objValues = objValues(1:iter);
end

function penalty = get_penalty(beta, penalties, alpha, indices)
    penalty = 0;
    p = numel(penalties);
    for i = 1:p
        penalty = penalty + penalties(i)*norm(beta(indices{i}, :), 'fro') + alpha*norm(beta(indices{i}, :), 'fro')^2;
    end
end

function [U, D, V] = get_svd(X, indices)
    p = numel(indices);
    U = cell(1, p);
    D = cell(1, p);
    V = cell(1, p);
    for i = 1:p
        [U{i}, D{i}, V{i}] = svd(X(:, indices{i}), 'econ');
    end
end

function root = get_root(r, U, D, penalty, alpha, beta)
    alpha = 2*alpha;
    p = size(D, 1);
    tol = 1e-5;
    root = norm(beta, 'fro');
    tolerance = 1;
    eta = 0.8;
    Dsquared = D*D;
    DsquaredPlusAlpha = (Dsquared + alpha*eye(p)).^(0.5);
    DUr = D*U'*r;
    temp = Dsquared*root + (penalty+alpha*root)*eye(p);
    a = temp \ DUr;
    while tolerance > tol
        step = 1;
        f = norm(a, 'fro')^2 - 1;
        b = temp.^(0.5) \ (DsquaredPlusAlpha * a);
        fPrime = -2 * norm(b, 'fro')^2;
        while root - step*f/fPrime <= 0
            step = step * eta;
        end
        root = root - step * f / fPrime;
        temp = Dsquared*root + (penalty+alpha*root)*eye(p);
        a = temp \ DUr;
        tolerance = abs(norm(a, 'fro')^2 - 1);
    end
end

function root = get_root_old(r, U, D, penalty, beta)
    tol = 1e-5;
    root = norm(beta, 'fro');
    tolerance = 1;
    eta = 0.8;
    Dsquared = D*D;
    p = size(D, 1);
    temp = Dsquared*root + penalty*eye(p);
    a = temp \ (D*U'*r);
    while tolerance > tol
        step = 1;
        f = norm(a, 'fro')^2 - 1;
        b = temp.^(0.5) \ (D * a);
        f_prime = -2 * norm(b, 'fro')^2;
        while root - step*f/f_prime <= 0
            step = step * eta;
        end
        root = root - step * f / f_prime;
        temp = Dsquared*root + penalty*eye(p);
        a = temp \ (D*U'*r);
        tolerance = abs(norm(a, 'fro')^2 - 1);
    end
end
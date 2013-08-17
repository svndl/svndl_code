function penalties = get_group_penalties(X, indices)
    p = numel(indices);
    penalties = zeros(1, p);
    for i = 1:p
	penalties(i) = norm(X(:, indices{i}), 'fro');
    end
end

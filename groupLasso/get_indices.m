function indices = get_indices(grpSize)
    range = [0 cumsum(grpSize)];
    p = numel(grpSize);
    indices = cell(1, p);
    for i = 1:p
	indices{i} = (range(i)+1) : range(i+1);
    end
end

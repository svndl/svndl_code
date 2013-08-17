%Computes the indices of the big estimated beta that corresponds to
%subject. In particular, the big beta consists of the coefficients for
%every subject's area 1, followed by area 2, and so on. So if we want to
%recover the right voxels for a given subject, we need to index correctly.

function indices = return_index(grpSize, rois, subject)

    grpRange = [0, cumsum(grpSize)];
    
    G = numel(grpSize);
    
    indices = [];
    for g = 1:G
        [first, last] = get_range(rois, subject, g);
        indices = [indices, (grpRange(g)+first):(grpRange(g)+last)];
    end
    
end


function [first, last] = get_range(rois, subject, g)

    if subject == 1
        first = 1;
        last = numel(rois{1}.ndx{g});
    else
        temp = 0;
        for i = 1:(subject-1)
            temp = temp + numel(rois{i}.ndx{g});
        end
        first = temp + 1;
        last = temp + numel(rois{subject}.ndx{g});
    end
end

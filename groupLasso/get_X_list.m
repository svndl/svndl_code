function [Xlist, Vlist, grpSize] = get_X_list(fwdMatrix, rois, numComponents)

numSubjects = numel(fwdMatrix);
numVisualAreas = numel(rois{1}.ndx);

Xlist = cell(1, numSubjects);
Vlist = cell(1, numSubjects);
grpSize = zeros(1, numVisualAreas);

for i = 1:numSubjects
    Xlist{i} = cell(1, numVisualAreas);
    for g = 1:numVisualAreas
        grpSize(g) = grpSize(g) + numel(rois{i}.ndx{g});
        [Xlist{i}{g}, Vlist{i}{g}] = get_principal_components(fwdMatrix{i}(:, rois{i}.ndx{g}), numComponents);
    end
end

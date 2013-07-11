function S = getFSLhdStruct(fileName,verbose)
% Get info from a nifti header in a more Matlab-friendly structure
% using fslhd
% 
% USAGE: S = getFSLhdStruct(fileName,[verbose])
%
% NOTES: fields of S contain strings, not numerical values

if nargin == 1
	verbose = false;
end

if iscell(fileName)
	S = getFSLhdStruct(fileName{1},verbose);
	for i = 2:numel(fileName)
		S(i) = getFSLhdStruct(fileName{i},verbose);
	end
	return
end

FSLheader = runSystemCmd( sprintf('fslhd -x %s',fileName), verbose );

[~,hd] = regexp(FSLheader,'(?<name>\w*) = ''(?<val>[\w-\s/.+]*)''','tokens','names');

S = struct;
for i = 1:numel(hd)
	S.(hd(i).name) = hd(i).val;
end

% "sto_ijk matrix" is missing an underscore, thus becomes field "matrix" in S
oldField = 'matrix';
newField = 'sto_ijk_matrix';
if isfield(S,oldField) && ~isfield(S,newField)
	S.(newField) = S.(oldField);
	S = rmfield(S,oldField);
end

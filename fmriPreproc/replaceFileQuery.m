function [replaceFile,replaceAll] = replaceFileQuery(fileName,replaceAll)
% decide whether to overwrite a file
%
% USAGE:   [replaceFile,replaceAll] = replaceFileQuery(fileName,replaceAll)
%
% INPUTS:     fileName = string to check with exist(fileName,'file')
%           replaceAll = 0 ask
%                        1 automatically do it
%                       -1 automatically don't 
% OUTPUTS: replaceFile = logical flag for overwrite
%          replaceAll  = new value of replaceAll 

if replaceAll == 1
	replaceFile = true;
elseif exist(fileName,'file');
	if replaceAll == -1
		replaceFile = false;
	else	% replaceAll == 0
		q = questdlg([fileName,' exists, replace?'],mfilename,'No','Yes','Yes All','No');
		if isempty(q)
			error('User abort')
		end
		replaceFile = strncmp(q,'Yes',3);
		replaceAll(:) = double( strcmp(q,'Yes All') );
	end
else
	replaceFile = true;
end


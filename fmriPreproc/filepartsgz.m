function [pathName,fileName,extName] = filepartsgz(fileName)
% because double extensions e.g. *.nii.gz aren't handled properly by fileparts.m
%
% USAGE: [pathName,fileName,extName] = filepartsgz(fileName)

if iscell(fileName)
	[pathName,fileName,extName] = cellfun( @(s) filepartsgz(s), fileName, 'UniformOutput', false );
	return
end

kSep = fileName == filesep;
n = numel(kSep);
if any(kSep)
	iSep = find(kSep,1,'last');
	if iSep == 1
		pathName = fileName(1);
		fileName = fileName(2:n);
	elseif iSep == n
		iSep2 = find(kSep,2,'last');
		if numel(iSep2) == 2
			if iSep2(1) == 1
				pathName = fileName(1);
				fileName = fileName(2:n-1);
			else
				pathName = fileName(1:iSep2(1)-1);
				fileName = fileName(iSep(1)+1:n-1);
			end
		else
			pathName = '';
			fileName = fileName(1:n-1);
		end
	else
		pathName = fileName(1:iSep-1);
		fileName = fileName(iSep+1:n);
	end
else
	pathName = '';
end
[fileName,extName] = strtok(fileName,'.');

% or...
% [pathName,fileName,extName] = fileparts(fileName);
% if any(fileName=='.')
% 	[fileName,ext] = strtok(fileName,'.');
% 	extName = [ext,extName];
% end

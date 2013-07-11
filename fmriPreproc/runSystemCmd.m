function out = runSystemCmd(cmd,verbose)
% USAGE:   result = runSystemCmd(cmd,verbose)
% INPUTS:     cmd = string to run with Matlab's system
%         verbose = logical for dumping cmd to command window prior to attempting to run it
% OUTPUT:  result = string returned by cmd

if nargin == 1
	verbose = false;
end
if verbose
	fprintf('%s\n',cmd)
end
[status,result] = system(cmd);
if status ~= 0
	error(result)
end
if nargout
	out = result;
end

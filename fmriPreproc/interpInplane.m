function interpFile = interpInplane(fileName,verbose)
% In case your inplanes have 1 more slice than functionals:
% linearly interpolate to new slices halfway between existing slices
%
% USAGE: outputFile = interpInplane(inputFile,[verbose])

if nargin == 1
	verbose = false;
end

[pathName,fileName,extName] = filepartsgz(fileName);

file0 = fullfile(pathName,fileName);
file1 = fullfile(pathName,[fileName,'_interp']);
file2 = fullfile(pathName,[fileName,'_temp4trash']);

if ~replaceFileQuery([file1,extName],0)
	return
end

% get dimensions
n = zeros(1,3);
cmdFmt = 'fslval %s dim%d';
for i = 1:3
	result = runSystemCmd(sprintf(cmdFmt,file0,i),verbose);
	n(i) = eval(result);
end

cmdFmt = 'fslroi %s %s 0 %d 0 %d %d %d';
% drop last slice
runSystemCmd(sprintf(cmdFmt,file0,file1,n(1),n(2),0,n(3)-1),verbose)
% drop first slice
runSystemCmd(sprintf(cmdFmt,file0,file2,n(1),n(2),1,n(3)-1),verbose)
% average
runSystemCmd(sprintf('fslmaths %s -add %s -div 2 %s',file1,file2,file1),verbose)
% cleanup
runSystemCmd(sprintf('rm %s%s',file2,extName),verbose)

% get qform
result = runSystemCmd(sprintf('fslorient -getqform %s',file1),verbose);
qform = reshape(eval(['[',result,']']),4,4)';
% shift by half a voxel in slice dimension
zVoxShift = eye(4);
zVoxShift(3,4) = 0.5;
qform(:) = qform * zVoxShift;
% set qform & copy to sform
runSystemCmd(sprintf('fslorient -setqform %s %s',sprintf(' %0.4f',qform'),file1),verbose)
runSystemCmd(sprintf('fslorient -copyqform2sform %s',file1),verbose)

if nargout > 0
	interpFile = [file1,getFSLextension];
end
	
% if verbose
% 	disp('done')
% end


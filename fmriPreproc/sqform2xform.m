function xfm = sqform2xform(sq,inFile,refFile)
% create a flirt-format transform from sform or qform data in input & reference files
%
% USAGE: xfm = sqform2xform(sq,inFile,refFile)

Sin  = getFSLhdStruct( inFile);
Sref = getFSLhdStruct(refFile);

% get sform or qform as requested
f = [lower(sq),'to_xyz_matrix'];
sqIn  = reshape(eval(strcat('[', Sin.(f),']')),4,4)';
sqRef = reshape(eval(strcat('[',Sref.(f),']')),4,4)';

% get scaling transforms
 dIn = diag([ eval( Sin.dx), eval( Sin.dy), eval( Sin.dz), 1 ]);
dRef = diag([ eval(Sref.dx), eval(Sref.dy), eval(Sref.dz), 1 ]);

% account for x-flips with NEUROLOGICAL orientation
oriCmdFmt = 'fslorient -getorient %s';
if strcmp(strtok(runSystemCmd(sprintf(oriCmdFmt,inFile))),'NEUROLOGICAL')
	xFlipIn      = diag([-1 1 1 1]);
	xFlipIn(1,4) = eval(Sin.nx) - 1;
else
	xFlipIn = eye(4);
end
if strcmp(strtok(runSystemCmd(sprintf(oriCmdFmt,refFile))),'NEUROLOGICAL')
	xFlipRef      = diag([-1 1 1 1]);
	xFlipRef(1,4) = eval(Sref.nx) - 1;
else
	xFlipRef = eye(4);
end

% estimate FSL-style transform
xfm = dRef*xFlipRef*(sqRef\sqIn)/xFlipIn/dIn;

% notes:
%          qRef*Ref =                    qIn*In = [RAS(mm)]
% dRef*xFlipRef*Ref = flirtXfm * dIn*xFlipIn*In


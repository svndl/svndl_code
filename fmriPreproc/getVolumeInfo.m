function [volDim,volRes,volOrd,volOri,Xrad] = getVolumeInfo(fileName)
% USAGE: [volDim,volRes,volOrd,volOri,Xrad] = getVolumeInfo(S)
%        S = a string file name, or a structure output by getFSLhdStruct.m
%
% NOTE: volOrd = order under RADIOLOGICAL orientation
%       There will be an x-flip on the input volume if volOri = 'NEUROLOGICAL'

verbose = false;

if isstruct(fileName);
	H = fileName;
else
	H = getFSLhdStruct(fileName,verbose);
end

% 3D dimensions
% volDim = eval(sprintf('[%s %s %s]',H.nx,H.ny,H.nz));
volDim = [ eval(H.nx), eval(H.ny), eval(H.nz) ];

% 3D resolution
volRes = [ eval(H.dx), eval(H.dy), eval(H.dz) ];

% Dimension order in head-referenced axes
volOrd  = 'ijk';
for iOrd = 1:numel(volOrd)
	fieldName = sprintf('qform_%s_orientation',volOrd(iOrd));
	if strcmp(H.(fieldName),H.(strrep(fieldName,'qform','sform')))
		ca = regexp(H.(fieldName),'\w*','match');		% e.g. ca = {'Right','to','Left}
		volOrd(iOrd) = ca{3}(1);
	else
		error('qform & sform oriented differently in %s',fileName)
	end
end
if ~all( ismember(volOrd,'LRAPIS') )
	error('unknown dimension order %s',volOrd)		% Shouldn't need this check
end

% Orientation from fslorient
volOri = strtok( runSystemCmd( sprintf('fslorient -getorient %s',fileName), verbose ) );		% linefeed char @ end
switch volOri
case 'NEUROLOGICAL'
	% Flip 1st dimension of volume if NEUROLOGICAL orientation
	Xrad = [ -1 0 0 volDim(1)-1; 0 1 0 0; 0 0 1 0; 0 0 0 1 ];
	switch volOrd(1)
	case 'L'
		volOrd(1) = 'R';
	case 'R'
		volOrd(1) = 'L';
	case 'P'
		volOrd(1) = 'A';
	case 'A'
		volOrd(1) = 'P';
	case 'I'
		volOrd(1) = 'S';
	case 'S'
		volOrd(1) = 'I';
	end
case 'RADIOLOGICAL'
	Xrad = eye(4);
otherwise
	error('unknown orientation %s',volOri)			% Shouldn't need this check
end


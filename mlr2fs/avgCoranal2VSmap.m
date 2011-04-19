function avgCoranal2VSmap(avg,S,FSdir)
% convert corAnal averages across subjects to vistasoft gray view parameter map

% SCN - 8/23/07

FSsurf = 'smoothwm';
FSsubj = S.FSname;
flipLRflag = S.FSflipLR;
VSdir = S.VSdir;
iDT = S.VSiDT;
% layer = 1;

% Load Freesurfer meshes [RAS], only need vertices ===================================
if strcmpi(FSsurf,'tri')
	vL = freesurfer_read_tri(fullfile(FSdir,FSsubj,'surf',['lh.',FSsurf]));
	vR = freesurfer_read_tri(fullfile(FSdir,FSsubj,'surf',['rh.',FSsurf]));
else
	vL = freesurfer_read_surf(fullfile(FSdir,FSsubj,'surf',['lh.',FSsurf]));
	vR = freesurfer_read_surf(fullfile(FSdir,FSsubj,'surf',['rh.',FSsurf]));
end
% Correct Freesurfer L/R flip
% for older subjects, hemiphere's are misnamed and meshes are [LAS] instead of [RAS]
if flipLRflag
	% swap hemispheres
	tmp = vL;
	vL = vR;
	vR = tmp;
	% flip L/R
	vL(:,1) = -vL(:,1);	
	vR(:,1) = -vR(:,1);
end
% Reorient vertices to [IPR] to match VistaSoft gray coords
kPermute = [3 2 1];
vL = vL(:,kPermute);				% now [SAR]
vR = vR(:,kPermute);
vL(:,1:2) = -vL(:,1:2);			% now [IPR]
vR(:,1:2) = -vR(:,1:2);
% Translate Freesurfer vertices to align with Vistasoft space
vL = vL + 128;
vR = vR + 128;


% Load Vistasoft gray coords.mat file ================================================
% gray coords are [IPR], nodes are [PIR]
% note: GrayCoords.coords = GrayCoords.nodes([2 1 3],:);
GrayCoords  = load(fullfile(VSdir,'Gray','coords.mat'));
% kLayer = GrayCoords.nodes(6,:) == layer;		% limit map to layer?

[iG2VL,d2L] = nearpoints(GrayCoords.coords,vL');		% vL(iG2VL,:)' approximates GrayCoords.coords(:,kLayer)
[iG2VR,d2R] = nearpoints(GrayCoords.coords,vR');
% find closest hemishere
k = d2R < d2L;
% d2L(k) = d2R(k);
% % apply distance tolerance
% d2tol = 5^2;					% tolerance for distance^2 (mm?)
% badVal = 1e-3;

% save average corAnal in regular corAnal format
out2mat = struct('amp',[],'ph',[],'co',[]);
mrSESSION = load(fullfile(VSdir,'mrSESSION.mat'));

% amplitude & phase
% WEDGE
LH = avg.wedgeLH(iG2VL);
RH = avg.wedgeRH(iG2VR);
LH(k) = RH(k);
out2mat.amp{1} = abs(LH)';
out2mat.ph{1} = angle(LH)';
out2mat.ph{1}(out2mat.ph{1}<0) = out2mat.ph{1}(out2mat.ph{1}<0) + 2*pi;
% RING
LH = avg.ringLH(iG2VL);
RH = avg.ringRH(iG2VR);
LH(k) = RH(k);
out2mat.amp{2} = abs(LH)';
out2mat.ph{2} = angle(LH)';
out2mat.ph{2}(out2mat.ph{2}<0) = out2mat.ph{2}(out2mat.ph{2}<0) + 2*pi;
% coherence
% WEDGE
LH = avg.wedgeLHco(iG2VL);
RH = avg.wedgeRHco(iG2VR);
LH(k) = RH(k);
out2mat.co{1} = LH';
% RING
LH = avg.ringLHco(iG2VL);
RH = avg.ringRHco(iG2VR);
LH(k) = RH(k);
out2mat.co{2} = LH';

mapfile = fullfile(VSdir,'Gray',mrSESSION.dataTYPES(iDT).name,'avgCorAnal.mat');
if exist(mapfile,'file')
	disp([mapfile,' already exists.  exiting'])
	return
end
save(mapfile,'-struct','out2mat')



return
%{
% save separate parameter maps
out2mat1 = struct('map',[],'mapName','avg amplitude');
out2mat2 = struct('map',[],'mapName','avg phase');
mrSESSION = load(fullfile(VSdir,'mrSESSION.mat'));

% amplitude & phase
% WEDGE
LH = avg.wedgeLH(iG2VL);
RH = avg.wedgeRH(iG2VR);
LH(k) = RH(k);
out2mat1.map{1} = abs(LH)';
out2mat2.map{1} = angle(LH)';
out2mat2.map{1}(out2mat2.map{1}<0) = out2mat2.map{1}(out2mat2.map{1}<0) + 2*pi;
% RING
LH = avg.ringLH(iG2VL);
RH = avg.ringRH(iG2VR);
LH(k) = RH(k);
out2mat1.map{2} = abs(LH)';
out2mat2.map{2} = angle(LH)';
out2mat2.map{2}(out2mat2.map{2}<0) = out2mat2.map{2}(out2mat2.map{2}<0) + 2*pi;

mapfile = fullfile(VSdir,'Gray',mrSESSION.dataTYPES(iDT).name,'avgAmp.mat');
if exist(mapfile,'file')
	disp([mapfile,' already exists.  exiting'])
	return
end
save(mapfile,'-struct','out2mat1')

mapfile = fullfile(VSdir,'Gray',mrSESSION.dataTYPES(iDT).name,'avgPh.mat');
if exist(mapfile,'file')
	disp([mapfile,' already exists.  exiting'])
	return
end
save(mapfile,'-struct','out2mat2')

% coherence
% WEDGE
LH = avg.wedgeLHco(iG2VL);
RH = avg.wedgeRHco(iG2VR);
LH(k) = RH(k);
out2mat1.map{1} = LH';
out2mat1.mapName = 'avg coherence';
% RING
LH = avg.ringLHco(iG2VL);
RH = avg.ringRHco(iG2VR);
LH(k) = RH(k);
out2mat1.map{2} = LH';

mapfile = fullfile(VSdir,'Gray',mrSESSION.dataTYPES(iDT).name,'avgCo.mat');
if exist(mapfile,'file')
	disp([mapfile,' already exists.  exiting'])
	return
end
save(mapfile,'-struct','out2mat1')

%}



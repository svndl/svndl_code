mrVistaHOMEDIR = '.';
subjid = 'skeri0055';
reconOptions.mrVistaCycles=10;

subjAnatDir = fullfile(getpref('VISTA','defaultAnatomyPath'),subjid);
subjNiftiDir = fullfile( subjAnatDir, 'nifti' );

P.annotations = 'tst'


xfm12File = '../xfmFlirt.txt'
xfmFlirt = load(xfm12File,'-ascii');
inplaneFile = '../0006_01_T1w_inplane_3D.nii.gz'

structVolFSL        = 'vAnat';			% w/o extension
subjStructFile = fullfile(subjNiftiDir,structVolFSL);

mrSessionFile = fullfile(mrVistaHOMEDIR,'mrSESSION.mat');

% Convert flirt transform to mrVista alignment

% Voxel scaling to mm
[~,inplaneVolRes,~,~,Xinplane] = getVolumeInfo( inplaneFile );
[structVolDim,structVolRes,structVolOrd,structVolOri] = getVolumeInfo( subjStructFile );

Dstruct  = diag([ structVolRes 1]);
Dinplane = diag([inplaneVolRes 1]);

% 1-based indexing to zero-based indexing voxel shift
V0 = [ eye(3), -ones(3,1); 0 0 0 1 ];


% Transform notes:
% Dstruct*[struct-IPR-RAD] = xfmFlirt * Dinplane*Xinplane*[inplane-NEURO]
%                          = xfmFlirt * Dinplane         *[inplane-RAD]
% inv(V0)*[struct-IPR-RAD] = xfmVista *           inv(V0)*[inplane-whatever]
%
% Dstruct*V0*xfmVista*inv(V0) = xfmFlirt*Dinplane*Xinplane
xfmVista = (V0\(Dstruct\xfmFlirt*Dinplane*Xinplane))*V0;


S = load(mrSessionFile);
nScan = numel(S.mrSESSION.functionals);
S.mrSESSION.alignment = xfmVista;
S.dataTYPES.scanParams = struct(...
	'annotation',P.annotations',...
	'nFrames',{S.mrSESSION.functionals.nFrames},...
	'framePeriod',{S.mrSESSION.functionals.framePeriod},...
	'slices',{S.mrSESSION.functionals.slices},...
	'cropSize',{S.mrSESSION.functionals.cropSize},...
	'PfileName',{S.mrSESSION.functionals.PfileName},...
	'parfile','',...
	'scanGroup','');
S.dataTYPES.blockedAnalysisParams = struct(...
	'blockedAnalysis',num2cell(ones(1,nScan)),...
	'detrend',1,...
	'inhomoCorrect',1,...
	'temporalNormalization',0,...
	'nCycles',reconOptions.mrVistaCycles);
S.dataTYPES.eventAnalysisParams = repmat(er_defaultParams,1,nScan);
S.vANATOMYPATH = fullfile(subjAnatDir,'vAnatomy.dat');

save(fullfile(mrVistaHOMEDIR,'mrSESSION.mat'),'-struct','S')
fprintf('& updated dataTYPES.  done.\n')
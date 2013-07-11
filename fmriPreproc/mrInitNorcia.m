function mrInitNorcia(subjid,inputDir,TR)
% USAGE: mrInitNorcia(subjid,[inputDir],[TR])
% where: subjid   = subject ID string to locate vAantomy, or skeri #
%        inputDir = directory where functional nifti files are found
%        TR       = force repetition time of user's choice
%
% e.g.
% >> mrInitNorcia(123)
% >> mrInitNorcia('skeri0123')
% >> mrInitNorcia('jones','/raid/MRI/data/study/fMRI/session')
% >> mrInitNorcia('nl-0007','',2)

error(nargchk(1,3,nargin))

if isnumeric(subjid)
	subjid = sprintf('skeri%04d',subjid);
end

if ~exist('inputDir','var') || isempty(inputDir)
	inputDir = pwd;
elseif ~isdir(inputDir)
	error('source-file directory %s does not exist',inputDir)
end

if ~exist('TR','var') %|| isempty(TR)
	TR = [];
end


% freesurfer SUBJECTS_DIR Matlab preference will override system environment variable
if ispref('freesurfer','SUBJECTS_DIR')
	SUBJECTS_DIR = getpref('freesurfer','SUBJECTS_DIR');
else
	% Check Freesurfer's SUBJECTS_DIR environment variable
	SUBJECTS_DIR = getenv('SUBJECTS_DIR');									% returns empty if none
	if isempty(SUBJECTS_DIR)
		error('no SUBJECTS_DIR environment variable')
	end
end
if ~isdir(SUBJECTS_DIR)
	error('SUBJECTS_DIR %s isn''t a directory',SUBJECTS_DIR)
end

% Check FSL's FSLOUTPUTTYPE environment variable
FSLOUTPUTTYPE = getenv('FSLOUTPUTTYPE');
expectedFSLoutput = 'NIFTI_GZ';
if ~strcmp(FSLOUTPUTTYPE,expectedFSLoutput)
	error('FSLOUTPUTTYPE environment variable = %s, expecting = %s',FSLOUTPUTTYPE,expectedFSLoutput)
end

% Find mrVista anatomy directory
if ispref('VISTA','defaultAnatomyPath')
	subjAnatDir = fullfile(getpref('VISTA','defaultAnatomyPath'),subjid);
	if ~isdir(subjAnatDir)
		error('anatomy directory %s does not exist',subjAnatDir)
	end
else
	% NOTE: getpref('VISTA','defaultAnatomyPath') should return one level above your default anatomy directory
	% e.g. /raid/MRI, not /raid/MRI/anatomy
	error('VISTA preference "defaultAnatomyPath" isn''t set')
end
subjNiftiDir = fullfile( subjAnatDir, 'nifti' );
if ~isdir(subjNiftiDir)
	runSystemCmd( sprintf('mkdir %s',subjNiftiDir) );		% can't use runSysCmd yet because reconOptions doesn't exist
end

% Inputs from user
[fMRIfiles,inputDir] = uigetfile(fullfile(inputDir,'*.nii.gz'),'CHOOSE fMRI FILE(S)','MultiSelect','on');
if isnumeric(fMRIfiles)
	return
elseif ~iscell(fMRIfiles)
	% uigetfile returns a string if only 1 file is selected
	fMRIfiles = {fMRIfiles};
end


[inplaneName,inplaneDir] = uigetfile(fullfile(inputDir,'*.nii.gz'),'CHOOSE INPLANE FILE (cancel for none)','MultiSelect','off');
boldInplane = isnumeric(inplaneName);		% Use mean of ref scan in place of inplane scan
if boldInplane
	inplaneName = '';
	inplaneDir = inputDir;
else
	inplaneFile = fullfile(inplaneDir,inplaneName);
end
[wholeHeadName,wholeHeadDir] = uigetfile(fullfile(inputDir,'*.nii.gz'),'CHOOSE WHOLE HEAD T1 (cancel for none)','MultiSelect','off');
if isnumeric(wholeHeadName)
	wholeHeadName = '';
	wholeHeadDir = inputDir;
else
	wholeHeadFile = fullfile(wholeHeadDir,wholeHeadName);
end
mrVistaHOMEDIR = uigetdir(inputDir,'mrVista project directory');
if isnumeric(mrVistaHOMEDIR)
	return
end


% Index of refernce functional.  auto set iRef from file sequence strings?
nFunc = numel(fMRIfiles);
if nFunc == 1
	iRef = 1;
else
	iRef = menu('Choose reference scan:',fMRIfiles);
	if iRef == 0
		return
	end
end

% Default options
reconOptions = struct(...
	'subjid',subjid,...
	'FSsubjid',[subjid,'_fs4'],...
	'skipVols',0,...
	'keepVols',Inf,...
	'doSliceTimeCorr',true,...
	'doMotionCorr',true,...
	'sliceTimeFirstFlag',true,...		% true = slice time correction before motion correction
	'sliceUpFlag',true,...				% true = 1:N, false = N:-1:1
	'sliceInterleave',1,...				% 0 = sequential, 1 = odd,even, 2 = even,odd
	'revSliceOrderFlag',true,...		% slicetimer corrects properly when slice-order file is reverse of true order
	'replaceAll',0,...					% -1 = don't replace any existing files, 0 = ask, 1 = replace all existing files
	'verbose',~false,...					% dump system commands to Matlab command window
	'betFlag',~true,...					% bet before aligning to freesurfer space
	'iRef',iRef,...
	'mrVistaSession','',...
	'mrVistaDescription','',...
	'mrVistaComment','',...
	'mrVistaCycles',1	);

funcVolCount = zeros(1,nFunc);
rawFiles = cellfun( @(s) fullfile(inputDir,s), fMRIfiles,'UniformOutput',false);
for i = 1:nFunc
	funcVolCount(i) = eval( runSystemCmd( sprintf('fslval %s dim4',rawFiles{i}) ) );
end
fprintf('Volumes per selected scan:')
fprintf('   %d',funcVolCount)
fprintf('\n')


% User options
reconOptions = ReconOptionsDialog(reconOptions);
if islogical(reconOptions)
	return
end

fprintf('Recon options:\n')
disp(reconOptions)

extFSL = getFSLextension;


tic
fprintf('---------------- %s (%s) ----------------\n',mfilename,datestr(now))


% ===================================================================================== FUNCTIONALS

% Test functionals for matching prescriptions, ignoring #vols
[funcVolDim,funcVolRes,funcVolOrd,funcVolOri] = getVolumeInfo(rawFiles{1});
for i = 2:nFunc
	[tmpDim,tmpRes,tmpOrd,tmpOri] = getVolumeInfo(rawFiles{i});
	if ~strcmp(tmpOrd,funcVolOrd) || ~strcmp(tmpOri,funcVolOri) || ~all(tmpDim==funcVolDim) || ~all(tmpRes==funcVolRes)
		error('functional volumes have mismatched order, orientation, dimensions, or resolution')
	end
end

% Trim unwanted volumes from functionals
[rawPath,rawBase] = filepartsgz(rawFiles);
trimFiles = cell(1,nFunc);
skipVols = reconOptions.skipVols;
keepVols = reconOptions.keepVols;
for i = 1:nFunc
	if ~isinf(keepVols) && ( (skipVols+keepVols) > funcVolCount(i) )
		error('requesting volumes [%d:%d] out of [1:%d] %s',skipVols+1,skipVols+keepVols,funcVolCount(i),rawFiles{i})
	elseif ( skipVols > 0 ) || ( keepVols < funcVolCount(i) )
		trimFiles{i} = fullfile(rawPath{i},[rawBase{i},'_trim',extFSL]);
		if replaceFileFlag(trimFiles{i})
			runSysCmd( sprintf('fslroi %s %s %d %d',rawFiles{i},trimFiles{i},skipVols,min(keepVols,funcVolCount(i)-skipVols)) );
            %jma added to fix mangled header
            fixSliceInfo( rawFiles{i}, trimFiles{i} )
		elseif reconOptions.verbose
			fprintf('Skipping fslroi %s\n',rawBase{i})
		end
	else
		trimFiles{i} = rawFiles{i};
	end
end

% Pre-process functionals
if reconOptions.sliceTimeFirstFlag
	if reconOptions.doSliceTimeCorr
		timedFiles = runFSLslicetimer(trimFiles,reconOptions);
	else
		timedFiles = trimFiles;
	end
	if reconOptions.doMotionCorr
		mcwFiles = runFSLmotionCorrection(timedFiles,1,reconOptions);
		[mcbFiles,meanFiles,mcxFiles] = runFSLmotionCorrection(mcwFiles,2,reconOptions,strrep(mcwFiles,['_mcw',extFSL],['_mcb',extFSL]));
	else
		mcbFiles = timedFiles;
	end
	outFiles = mcbFiles;
else
	if reconOptions.doMotionCorr
		mcwFiles = runFSLmotionCorrection(trimFiles,1,reconOptions);
		[mcbFiles,meanFiles,mcxFiles] = runFSLmotionCorrection(mcwFiles,2,reconOptions,strrep(mcwFiles,['_mcw',extFSL],['_mcb',extFSL]));
	else
		mcbFiles = trimFiles;
	end
	if reconOptions.doSliceTimeCorr
		timedFiles = runFSLslicetimer(mcbFiles,reconOptions);
	else
		timedFiles = mcbFiles;
	end
	outFiles = timedFiles;
end

if ~isempty(TR)
	TRstr = num2str(TR);
	for i = 1:nFunc
		TRfound = eval( runSystemCmd( sprintf('fslval %s pixdim4',outFiles{i}) ) );
		if TRfound ~= TR
			changeHeaderElement(outFiles{i},'dt',TRstr,outFiles{i})
			if reconOptions.verbose
				fprintf('Changed TR from %g to %g in %s\n',TRfound,TR,outFiles{i})
			end
		end
	end
end
[~,outNames] = filepartsgz(outFiles(:));


% ========================================================================================= INPLANE


% If no inplane, use mean of ref scan
if boldInplane
	if reconOptions.doMotionCorr
		inplaneFile = meanFiles{reconOptions.iRef};
		[inplaneDir,inplaneName,inplaneExt] = filepartsgz(inplaneFile);
		inplaneName = strcat(inplaneName,inplaneExt);
	else
		inplaneDir = inputDir;
		inplaneName = [outNames{reconOptions.iRef},'_mean',extFSL];
		inplaneFile = fullfile(inplaneDir,inplaneName);
		if replaceFileFlag(inplaneFile)
			runSysCmd( sprintf('fslmaths %s -Tmean %s',outFiles{reconOptions.iRef},inplaneFile) )
            %jma added to fix mangled header
            fixSliceInfo( outFiles{reconOptions.iRef}, inplaneFile )

		elseif reconOptions.verbose
			fprintf('Skipping Tmean %s\n',outFiles{reconOptions.iRef})
		end
	end
end

% Handle 4D inplane volumes (with size of 4th dim = 1)
hInplane = getFSLhdStruct(inplaneFile,false);	%reconOptions.verbose);
if strcmp(hInplane.ndim,'4')
	if strcmp(hInplane.nt,'1')
% 		fprintf('Inplane volume coded as 4D\n')
		inplaneName = [strtok(inplaneName,'.'),'_3D',extFSL];
		newFile3D = fullfile(inplaneDir,inplaneName);
		if replaceFileFlag( newFile3D )
			fprintf('Making 3D duplicate of 4D inplane so readFileNifti won''t crash.\n')
			runSysCmd( sprintf('flirt -in %s -ref %s -applyxfm -out %s',inplaneFile,inplaneFile,newFile3D) );

            %jma added to fix mangled header
            fixSliceInfo(inplaneFile, newFile3D )

%			changeHeaderElement(inplaneFile,'ndim','3',newFile3D)		% flirt chokes on 3D file made this way, but not above?  also readFileNifti reads it as all zeros!
		elseif reconOptions.verbose
			fprintf('Skipping creation of 3D duplicate of 4D inplane\n')
		end
		inplaneFile = newFile3D;
	else
		error('Inplane volume is not 3D %s',inplaneFile)
	end
end

% Handle inplane with one more slice than funtionals
if eval(hInplane.nz) == (funcVolDim(3)+1)
	inplaneFile = interpInplane(inplaneFile,reconOptions.verbose);
end

% =============================================== COMPUTE ALIGNMENT OF INPLANE TO SEGMENTED ANATOMY

% Make nifti version of Freesurfer T1 or brain volume
if reconOptions.betFlag
	structVolFreeSurfer = 'brain.mgz';
	structVolFSL        = 'vBrain';
else
	structVolFreeSurfer = 'T1.mgz';
	structVolFSL        = 'vAnat';			% w/o extension
end
subjStructFile = fullfile(subjNiftiDir,structVolFSL);
if replaceFileFlag( [subjStructFile,extFSL] )
	freesurferVol = fullfile(SUBJECTS_DIR,reconOptions.FSsubjid,'mri',structVolFreeSurfer);
	if ~exist(freesurferVol,'file')
		error('%s does not exist',freesurferVol)
	end
	runSysCmd( sprintf('mri_convert %s %s%s',freesurferVol,subjStructFile,extFSL) );
	runSysCmd( sprintf('fslswapdim %s SI AP LR %s',subjStructFile,subjStructFile) );
elseif reconOptions.verbose
	fprintf('Skipping mri_convert %s to nifti\n',structVolFreeSurfer)
end
% Verify that nifti volume is IPR RADIOLOGICAL, to match vAnatomy.dat
[structVolDim,structVolRes,structVolOrd,structVolOri] = getVolumeInfo( subjStructFile );
if ~strcmp(structVolOrd,'IPR') || ~strcmp(structVolOri,'RADIOLOGICAL') || ~all(structVolDim==256) || ~all(structVolRes==1)
	error('%s incompatible with vAnatomy.dat',subjStructFile)
end

% Calculate transform using flirt
flirtOpts = '-dof 6 -usesqform -nosearch';
% flirtOpts = '-dof 6 -usesqform -coarsesearch 8 -finesearch 1 -searchrx -45 45 -searchry -45 45 -searchrz -45 45';
if boldInplane
	flirtBold = ' -cost mutualinfo';
% 	flirtBold = ' -cost mutualinfo -searchcost mutualinfo';
else
	flirtBold = '';
end
if isempty(wholeHeadName)
	% Register inplane volume to Freesurfer space
	% requires smart use of  betFlag, i.e. don't do it with partial brain prescriptions
	xfm12File = fullfile(inputDir,'xfmFlirt.txt');
	if replaceFileFlag( xfm12File )
		if reconOptions.betFlag
			brainFile = fullfile(inplaneDir,[strtok(inplaneName,'.'),'_bet']);
			if replaceFileFlag( [brainFile,extFSL] )
				runSysCmd( sprintf('bet2 %s %s',inplaneFile,brainFile) );
			elseif reconOptions.verbose
				fprintf('Skipping brain extraction of inplane\n')
			end
			regFile = brainFile;
		else
			regFile = inplaneFile;
		end
		if boldInplane
			% with mean BOLD it's better to align structural to inplane & invert?   do it anyway?
			% might want to set an initial transform too using sqform2xform, results are different though not much?
			xfm12invFile = fullfile(inputDir,'xfmFlirtInv.txt');
			if replaceFileFlag( xfm12File )
				runSysCmd( sprintf('flirt %s -in %s -ref %s -omat %s',[flirtOpts,flirtBold],subjStructFile,regFile,xfm12invFile) );
			else
				fprintf('Skipping registration of segmented structural to inplane\n')
			end
			runSysCmd( sprintf('convert_xfm -omat %s -inverse %s',xfm12File,xfm12invFile) );
		else
			runSysCmd( sprintf('flirt %s -in %s -ref %s -omat %s',[flirtOpts,flirtBold],regFile,subjStructFile,xfm12File) );
		end
	elseif reconOptions.verbose
		fprintf('Skipping registration of inplane to segmented structural\n')
	end
else
	% Register inplane volume to whole head, don't brain extract
	xfm1File = fullfile(inputDir,'xfmStep1.txt');
	if replaceFileFlag( xfm1File )
		runSysCmd( sprintf('flirt %s -in %s -ref %s -omat %s',[flirtOpts,flirtBold],inplaneFile,wholeHeadFile,xfm1File) );
	elseif reconOptions.verbose
		fprintf('Skipping registration of inplane to whole head\n')
	end
	% Register whole head to Freesurfer space
	xfm2File = fullfile(inputDir,'xfmStep2.txt');
	if replaceFileFlag( xfm2File )
		if reconOptions.betFlag
			brainFile = fullfile(wholeHeadDir,[strtok(wholeHeadName,'.'),'_bet']);
			if replaceFileFlag( [brainFile,extFSL] )
				% trusting bet's default parameters
				runSysCmd( sprintf('bet2 %s %s',wholeHeadFile,brainFile) );
			elseif reconOptions.verbose
				fprintf('Skipping brain extraction of whole head\n')
			end
			regFile = brainFile;
		else
			regFile = wholeHeadFile;
		end
		runSysCmd( sprintf('flirt %s -in %s -ref %s -omat %s',flirtOpts,regFile,subjStructFile,xfm2File) );
	elseif reconOptions.verbose
		fprintf('Skipping registration of whole head to segmented structural\n')
	end
	% Combine transforms
	xfm12File = fullfile(inputDir,'xfmFlirt.txt');
	if replaceFileFlag( xfm12File )
		runSysCmd( sprintf('convert_xfm -omat %s -concat %s %s',xfm12File,xfm2File,xfm1File) );
	elseif reconOptions.verbose
		fprintf('Skipping concatenation of flirt transforms\n')
	end
end
xfmFlirt = load(xfm12File,'-ascii');

% Convert flirt transform to mrVista alignment

% Voxel scaling to mm
[~,inplaneVolRes,~,~,Xinplane] = getVolumeInfo( inplaneFile );
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

et = [ 0 0 toc ];
et(1) = floor(et(3)/3600);
et(2) = floor(et(3)/60-et(1)*60);
et(3) = et(3)-et(1:2)*[3600;60];
fprintf('\nelapsed time = %0.0f:%02d:%02.0f\n\n',et)

% ====================================================================== INITIALIZE mrVISTA PROJECT

if ~isdir(mrVistaHOMEDIR)
	runSysCmd( sprintf('mkdir %s',mrVistaHOMEDIR) );
end

P = mrInitDefaultParams;
P.sessionDir = mrVistaHOMEDIR;
P.sessionCode = reconOptions.mrVistaSession;
P.doDescription   = 1;
P.doCrop          = 0;
P.doAnalParams    = 0;
P.doPreprocessing = 0;
P.doSkipFrames    = 0;

% [P,OK] = mrInitGUI_main(P);
P.inplane = inplaneFile;
P.functionals = outFiles(:);
P.vAnatomy = fullfile(subjAnatDir,'vAnatomy.dat');

% P = mrInitGUI_description(P);
P.subject = subjid;
P.description = reconOptions.mrVistaDescription;
P.comments = reconOptions.mrVistaComment;
P.annotations = outNames;

% P = mrInitGUI_skipFrames(P);
% P.keepFrames = [ 0 -1; 0 -1 ];		% skip #keep (-1=all), or leave empty??

% P = mrInitGUI_crop(P);
% P.crop = [];		% 2x2 matrix

% P = mrInitGUI_analParams(P);
% P.parfile = {};
% P.coParams = {};
% P.glmParams = {};
% P.scanGroups = {};

% P = mrInitGUI_preprocessing(P);
P.applyGlm = 0;
P.applyCorAnal = [];
P.motionComp = 0;
P.sliceTimingCorrection = 0;
P.motionCompRefScan = 1;
P.motionCompRefFrame = 1;

mrSessionFile = fullfile(mrVistaHOMEDIR,'mrSESSION.mat');
if replaceFileFlag( mrSessionFile )
	OK = mrInit2(P);
	if OK ~= 1
		error('Problem with mrInit2.m')
	end
	fprintf('\n\ninitialized mrVista,\n')
elseif reconOptions.verbose
	fprintf('Skipping mrInit2, but still updating mrSESSION.alignment\n')
end


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
S.vANATOMYPATH = P.vAnatomy;

save(fullfile(mrVistaHOMEDIR,'mrSESSION.mat'),'-struct','S')
fprintf('& updated dataTYPES.  done.\n')

% toc

return	% ========================================================================================


	function result = runSysCmd(cmd)
		result = runSystemCmd(cmd,reconOptions.verbose);
	end

	function replaceFlag = replaceFileFlag(fileName)
		[replaceFlag,reconOptions.replaceAll] = replaceFileQuery(fileName,reconOptions.replaceAll);
	end


end

function [] = mrSimScript(projectDir,params)
%function [] = mrSimScript(params)
%
%params is a structure that determines the simulation 

% $Log: mrSimScript.m,v $
% Revision 1.13  2009/08/31 21:02:24  ales
% *** empty log message ***
%
% Revision 1.12  2009/08/31 20:57:12  ales
% Change error check
%
% Revision 1.11  2009/08/31 20:49:28  ales
% Added check for missing roi
%
% Revision 1.10  2009/08/31 20:46:31  ales
% Added some error checking
%
% Revision 1.9  2009/06/26 21:15:48  ales
% modified simulations to default to parameters that produce ~microvolt scalp activity
%
% Revision 1.8  2009/06/26 21:12:30  ales
% mrSimScript does arbitrary waveforms
% skeriDefaultSimParameters has updated help
% makeDefaultCortexMorphMap returns an identity matrix for mapping an individual on to itself
% makeForwardMatrixFromMne has some added help
%

if ~exist('params')   
    error('Please set the params')
end

if ~isfield(params, 'activeRoiList')  
    params.activeRoiList = { 'V1-L' };
end

if ~isfield(params, 'sphereModel')

    params.sphereModel = false;
end


if ~isfield(params, 'condNumber')
    condNumber = num2str(999);
end

if params.condNumber < 300
    error(['Condition number: ' num2str(params.condNumber) ' too low.\nPlease choose a number over 300'])
end

if ~isfield(params, 'stepTimeByRoi'),
    params.stepTimeByRoi = true;
end


if ~isfield(params,'noise')
    params.noise.type = 1; %1 = white, 2 = colored
    params.noise.level = 0;
end

if ischar(params.noise.type),    
    params.noise.type = find(strcmp( params.noise.type,{'white' 'colored'} ));
end


if length(params.activeRoiList) ~= length(params.roiHarm)
    error(['Mismatch between activeRoiList and roiHarm in simulation parameters']);
end



if ispref('freesurfer','SUBJECTS_DIR'),

    freesurfDir = getpref('freesurfer','SUBJECTS_DIR');
else
    disp('');
    disp('PREFERENCE SETTING FOR YOUR FREESURFER SUBJECT DIRECTORY NOT FOUND!');
    disp('PLEASE SET YOUR FREESURFER SUBJECTS DIRECTORY');
    disp('');
    disp('The preceeding message was brought to you in all caps to ensure that you would read it.');
    disp('...');
    disp('You probably didn''t read it anyway. Well don''t blame me when this script does not work.');
    disp('If you want to avoid this message in the future use the following:');
    disp('setpref(''freesurfer'',''SUBJECTS_DIR'',''/path/to/FREESURFER_SUBS/'')')
    
    freesurfDir = uigetdir('PICK FREESURFER SUBJECTS DIRECTORY');
end




if ~exist(projectDir,'dir')
    msg = sprintf('Project directory not found: %s\n Thank You, Please Play Again.\n',projectDir);
    error(msg);
end


if ispref('mrCurrent','AnatomyFolder'),
    
    anatDir = getpref('mrCurrent','AnatomyFolder');
else
    disp('');
    disp('Cannot find mrCurrent anatomy folder!!');
    disp('Attempting to guess');
    disp('Good luck with that');

    n = regexp(freesurfDir(1:end-1),[filesep '*' ],'start')

    anatDir = freesurfDir(1:n(end));

    disp('My guess is: %s', anatDir);

end


subjectList = dir(projectDir);

for iSubj = 3:length(subjectList),

    optionString = '';

    if subjectList(iSubj).isdir==false;
        continue;
    end


    subjId = subjectList(iSubj).name;

    if strcmp(subjId,'skeri9999')
        display('Skipping skeri9999')
        continue;
    end

    if strncmp(subjId,'.',1)
        display(['skipping folder: ' subjId])
        continue;
    end

    logFile = fullfile(projectDir,subjId,'_dev_',['mrSim_log_' datestr(now,'yyyymmdd_HHMM_FFF')  '.txt']);
    diary(logFile)


    disp(['Processing subject: ' subjId ])

    PDname = dir(fullfile(projectDir,subjId,'Exp_MATL_*'));

    if isempty(PDname)
        error(['\n Cannot find PD Export directory\n\n-----> Check: ' projectDir ' for proper directory']);
    end

    powerDivaExportDir = fullfile(projectDir,subjId,PDname(1).name)


    str2num(subjId(end-3:end))
    subjNum = str2num(subjId(end-3:end))

    SUBJECT=[subjId '_fs4'];

    %Find source space file
    srcSpaceFile = fullfile(freesurfDir,SUBJECT,'bem',[ SUBJECT '-ico-5p-src.fif']);
    if ~exist(srcSpaceFile,'file'),
        error(['Cannot find find source space file: ' srcSpaceFile]);
    end

    srcSpace = mne_read_source_spaces(srcSpaceFile);

    %read in forward file
    if params.sphereModel ==true
        mneFwdFileName = [subjId '-sph-fwd.fif' ];
        optionString = [optionString 'sphere_'];
    else
        mneFwdFileName = [subjId '-fwd.fif' ];
        optionString = [optionString 'bem_'];
    end

    mneFwdFile = fullfile(projectDir,subjId,'_MNE_',mneFwdFileName);

    fwd = mne_read_forward_solution(mneFwdFile);

    %Combine srcspace and fwd model to create full matrix
    G = makeForwardMatrixFromMne(fwd,srcSpace);

    exportFileList = dir(fullfile(powerDivaExportDir,'Axx_*.mat'));

    if isempty(exportFileList)
        msg = sprintf('No .mat diva exports found in: %s\n Thank You, Please Play Again.\n',powerDivaExportDir);
        error(msg);
    end

    dataFile = fullfile(powerDivaExportDir,exportFileList(1).name);

    pdExport = load(dataFile);

    waveShapes = dftmtx(pdExport.nT);
    waveShapes = waveShapes(2:end,:);

    srcCov = [];


    subjRoiDir = fullfile(anatDir,subjId,'Standard','meshes','ROIs');
    [roiList leftVerts rightVerts leftSizes rightSizes] = getRoisByType(subjRoiDir,'all');
    totalDx = [leftVerts rightVerts];


    %    srcSize = sum([srcSpace.nuse]); % <- Note tricky use of grouping
    %[srcSpace.nuse] -> [nuse nuse]
    %sum of that gives the total # of
    %vertices in the source space


    %   srcCov = sparse(srcSize,srcSize);

    totalWave = zeros(size(pdExport.Wave));
    totalAmp = zeros(size(pdExport.Amp));
    totalSin = zeros(size(pdExport.Sin));
    totalCos = zeros(size(pdExport.Cos));

    if ~isfield(params,'roiHarm')
        params.roiHarm = { 1 };
    end

    baseline = round(.2*pdExport.nT)
    timePerRoi = floor((pdExport.nT-baseline)/length(params.activeRoiList));
    
    for iRoi =1:length(params.activeRoiList),

        roiIdx = strcmp(params.activeRoiList{iRoi},{roiList.name});

        if sum(roiIdx)==0
            warning(['Cannot find: ' params.activeRoiList{iRoi} ' in subject: ' subjId])
            continue;
        end
        
        activeSources = roiList(roiIdx).meshIndices;
        thisTopo = sum(G(:,activeSources),2);


        harmCoeff = params.roiHarm{iRoi};

        harmIdx = [pdExport.i1F1:pdExport.i1F1:pdExport.i1F1*length(harmCoeff)] +1;

        
        if params.stepTimeByRoi
            thisStart = (baseline + timePerRoi*(iRoi-1));
            thisIndex = thisStart:(thisStart+(timePerRoi-1));
            thisWave = zeros(pdExport.nT,1);
            thisWave(thisIndex) = 1e-4;
        
        elseif isfield(params,'roiTime') && ~isempty(params.roiTime),
            thisWave = params.roiTime{iRoi};
        
        else
            %This is dumb. I should create the waveform a better way ... JMA
            thisWave = real(waveShapes(1:length(harmCoeff),:))'*real(harmCoeff)'+ ...
                imag(waveShapes(1:length(harmCoeff),:))'*imag(harmCoeff)';
        end
        
        thisWave = thisTopo*thisWave';
        
        thisSin = real(thisTopo*harmCoeff);
        thisCos = imag(thisTopo*harmCoeff);
        thisAmp = abs(thisTopo*harmCoeff);


        totalWave = totalWave + thisWave';        
        totalSin(harmIdx,:) = totalSin(harmIdx,:) + thisSin';
        totalCos(harmIdx,:) = totalCos(harmIdx,:) + thisCos';
        totalAmp(harmIdx,:) = totalAmp(harmIdx,:) + thisAmp';

    end
    
    
    
    simExport= pdExport; % Set simExport to be equal to the first condition unless we change things.
    
    waveNoise = zeros(size(totalWave));
    
    if params.noise.level >0 
        warning('mrSim:params','Warning: noise is only applied to time domain data at present');
    end
    
    %noise level is set at a percent of the mean activation level
    thisSubjNoiseLevel = params.noise.level*mean(abs(totalWave(:)));
    
    if params.noise.type == 1, %white noise
        
        waveNoise = thisSubjNoiseLevel*randn(size(waveNoise));
        simExport.Cov = thisSubjNoiseLevel*eye(size(pdExport.Cov));
    elseif params.noise.type == 2, %colored noise taken from PD export
        
        mu = zeros(pdExport.nCh,1); %zero mean noise
        sigma = pdExport.Cov; %covariance set by pd measured data
        
        sigma = sigma./mean(diag(pdExport.Cov)); %normalize covariance so that the mean diagnol is unity
                                                 %this lets us set the
                                                 %noise level for the sim
                                                 
        %generate random noise with covariance set by sigma                                         
        waveNoise = thisSubjNoiseLevel*mvnrnd(mu,sigma,pdExport.nT); 
        simExport.Cov = sigma;
    end
    
    
    condNumber = num2str(params.condNumber);
    simExport.Sin = totalSin;
    simExport.Cos = totalCos;
    simExport.Amp = totalAmp;
    simExport.Wave = totalWave+waveNoise;
    simExport.cndNmb = condNumber;
    simExport.isSim = true;
    simExport.simParams = params;




    simFile = fullfile(powerDivaExportDir,['Axx_c' condNumber '.mat']);


    eval(['save ' simFile ' -STRUCT simExport']);

end








    
    
    





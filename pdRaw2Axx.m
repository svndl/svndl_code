function pdRaw2Axx(projectInfo,optns)
%function pdOdd2Eeglab(projectInfo)
%
%Function to take powerdiva raw data and read it into EEGlab.
%
%
%optns.lowpass
%optns.highpass
%optns.lock2reaction
%optns.cndNumOffset


% Axx fields to fake:
% 
%          cndNmb: 2
%            nTrl: 25
%             nCh: 128
%              nT: 432
%             nFr: 108
%            dTms: 2.3125
%            dFHz: 0.5000
%            i1F1: 2
%            i1F2: 72
%     DataUnitStr: 'microVolts'
%            Wave: [432x128 double]
%             Cos: [108x128 double]
%             Sin: [108x128 double]
%             Amp: [108x128 double]
%             Cov: [128x128 double]

%outputDir = fullfile(projectInfo.projectDir,projectInfo.subjId,'_dev_');
outputDir = projectInfo.powerDivaExportDir;


%
allRaw = dir(fullfile(projectInfo.powerDivaExportDir,'Raw_*.mat'));

%Parse all raw files for number of conditions and trials
%Note tricky use of [] to turn struct into 1 long string;

if isempty([allRaw.name])
    error(['Cannot find RAW, single trial exports, for subject: ' projectInfo.subjId])
end

%Validate input:
if ~isfield(optns,'lock2reaction') || isempty(optns.lock2reaction)
    disp('Warning: optns.lock2reaction is not set. Defaulting to STIMULUS locked');
    optns.lock2reaction = false;
end

if  ~isfield(optns,'shuffleReactionTime') || isempty(optns.shuffleReactionTime)
    disp('Warning: optns.shuffleReactionTime is not set. Defaulting to REAL (correct) locked');
    optns.shuffleReactionTime = false;
       
end

%optns.lock2reaction == false ||

%optns.cndNumOffset

 if ~isfield(optns,'cndNum2Sort') || isempty(optns.cndNum2Sort)
     
     
     condAndTrialNum = sscanf([allRaw.name],'Raw_c%d_t%d.mat');
     
     %Finds unique condition numbers in the export directory.
     condNum = unique(condAndTrialNum(1:2:end))';
 else
     condNum = optns.cndNum2Sort;
 end
 


% Axx fields to fake:
% 
%          cndNmb: 2
%            nTrl: 25
%             nCh: 128
%              nT: 432
%             nFr: 108
%            dTms: 2.3125
%            dFHz: 0.5000
%            i1F1: 2
%            i1F2: 72
%     DataUnitStr: 'microVolts'
%            Wave: [432x128 double]
%             Cos: [108x128 double]
%             Sin: [108x128 double]
%             Amp: [108x128 double]
%             Cov: [128x128 double]

  

for iCond = condNum,

%     condFilename = sprintf('Raw_c%0.3d_t*.mat',iCond);
%   
%     rawList = dir(fullfile(projectInfo.powerDivaExportDir,condFilename));
%     
%     for iRaw = 1:length(rawList),
%         
%         rawFiles{iRaw} = fullfile(projectInfo.powerDivaExportDir,rawList(iRaw).name);
%     end
% 
    
   
    iCond
%    [data info] = loadPDraw(rawFiles,0);
    clear dat paddedDat shiftedDat;

    
%    [dat respTime condInfo] = sortOddStep(projectInfo.powerDivaExportDir,optns,iCond);
     [dat condInfo] = sortEpoch(projectInfo.powerDivaExportDir,optns,iCond);
  
    
    
    
    goodTrials = condInfo{1}.goodTrialLabel;

    % Axx fields that are not part of spec, used for documentation
    Axx.optns = optns;
    
    % Axx fields that are correct:
    %
    Axx.cndNmb      = iCond;
    Axx.nTrl        = size(dat{1}, 2);
    if Axx.nTrl ==0
        continue
    end
    
    Axx.nCh         = size(dat{1},3);
    Axx.nT          = size(dat{1},1);
    Axx.dTms        = 10^3*(condInfo{1}.FreqHz)^-1;

    for iTrial = 1:size(goodTrials,1),        
        %if channel for this trial is ~good set to NaN
        dat{1}(:,iTrial,~goodTrials(iTrial,:)) = NaN;
    end
    
    

    
    % Creat Axx.Wave data
    if optns.lock2reaction == true
        
        
        
        
        %Get response time in samples from beginning of "odd step"
        %odd step is the middle event in dat
        stepLength = Axx.nT/3
        
        
        respTimeSamps = round(respTime{1}*condInfo{1}.FreqHz+stepLength);
        
        
        %Shuffle reaction times to generate null distribution for response
        %locked data.
        if optns.shuffleReactionTime == true
           [null permuteIdx] = sort(rand(size(respTimeSamps)));
           respTimeSamps = respTimeSamps(permuteIdx);
           
            disp('WARNING: Making _SHUFFLED_ Response Locked Average (NULL distribution!)');
            
        else
            disp('Making Response Locked Average');
        end
        
            
            
%        medRespSamp = median(respTimeSamps);
        
        %align button press to this sample
        %sample2Align = round(2*condInfo{1}.FreqHz);
        sample2Align = round((2/3)*Axx.nT)
        
        %Per trial resp time shift about alignment point
        %negative early, positive late
        perTrialShift = respTimeSamps-sample2Align;
        maxShift = max(abs(perTrialShift));
        paddedDat = padarray(dat{1},[maxShift 0 0],NaN);
        
        shiftedDat = zeros(size(paddedDat));
        
        for iTrial = 1:size(paddedDat,2),
            
            %Shift data to align onto button press
            shiftedDat(:,iTrial,:) = circshift(paddedDat(:,iTrial,:),[-perTrialShift(iTrial) 0 0]);
        end
    
    
        Axx.Wave        = squeeze(nanmean(shiftedDat(maxShift+1:maxShift+Axx.nT, :,:),2));
    else
        disp('Making Stimulus Locked Average');
         
        Axx.Wave        = squeeze(nanmean(dat{1},2));
   
    end
    
        
    %Hacky multiplier, fix this ---JMA
    Axx.Wave = 1e6*Axx.Wave;
    Axx.DataUnitStr = 'microVolts';

    % Create frequency domain data
    
    Axx.nFr = round(size(Axx.Wave,1)/2);
    dft = dftmtx(Axx.nT);   

    dftDat = dft*Axx.Wave;
    dftDat = dftDat(1:Axx.nFr,:);
    
    Axx.dFHz = (condInfo{1}.FreqHz)/size(Axx.Wave,1)

    % i1f1 = 3, means 1 Hz because of 3 oddsteps
    % Stuff tends to be multiples of 1 Hz. But we don't have that info
    % here so we are just going to set the index to 1 to make nF1 be all
    % freqs
    Axx.i1F1       = 1;
    Axx.i1F2       = 0;

    %JMA
    %WARNING FREQ DOMAIN DATA IS PROBABLY NOT PROPER!!!
    Axx.Amp = abs(2*(dftDat/Axx.nFr));
    Axx.Cos = 2*real(dftDat)/Axx.nFr;
    Axx.Sin = -2*imag(dftDat)/Axx.nFr;
    
    %This is faked:
    Axx.Cov = eye(Axx.nCh);

    
    if isfield(optns,'cndNumOffset') && ~isempty(optns.cndNumOffset),

        condNum2Write = optns.cndNumOffset +iCond;

        if condNum2Write >= 1000,
            warning('CONDITION NUMBER TOO LARGE! File will be written but expect problems buddy.');
        end

    else

        if optns.lock2reaction == true

            condNum2Write = 200+iCond;
        else
            condNum2Write = 100+iCond;
        end
    end

         
         
      Axx.cndNmb = condNum2Write;
      
      filename=['Axx_c' num2str(condNum2Write,'%0.3d') '.mat'];
      file2write = fullfile(projectInfo.powerDivaExportDir,filename);
      
      
      save(file2write,'-struct','Axx')
    


end



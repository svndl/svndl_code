function computeICAonRaw( projectInfo,optns )
%function prepareProjectForMne( [projectDir])
%optns.nComps


if nargin<=1 || isempty(optns) || ~isfield(optns,'nComps') || isempty(optns.nComps); 
    optns.nComps = 64;
end

projectDir = projectInfo.projectDir;
subjId = projectInfo.subjId;

PDname = dir(fullfile(projectDir,subjId,'Exp_MATL_*'));
powerDivaExportDir = fullfile(projectDir,subjId,PDname(1).name);
    
rawList = dir(fullfile(powerDivaExportDir,'Raw_*.mat'));
   

for iRaw = 1:length(rawList),
        
    rawFiles{iRaw} = fullfile(powerDivaExportDir,rawList(iRaw).name);
end
    
    
   
    
data = loadPDraw(rawFiles(1:end/2),0);
data = 1e6*data;
[weights,sphere] = runica(data,'extended',1,'pca',optns.nComps);
    
%     data = loadPDraw(rawFiles((end/2+1):end),0);
%     data = 1e6*data;


%     [weights2,sphere2] = runica(data,'extended',1,'pca',64,'weights',weights1);
% 
saveName = fullfile(projectInfo.currentDir,'_dev_','ICAdata.mat');
    
%save(saveName,'weights1','sphere1','weights2','sphere2');
save(saveName,'weights','sphere');
    
    

    
    

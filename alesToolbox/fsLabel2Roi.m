function [] = fsLabel2Roi(subjId,labelNames)



freesurfDir = getpref('freesurfer','SUBJECTS_DIR');
anatDir = getpref('mrCurrent','AnatomyFolder');

if ~strncmp(subjId(end-3:end),'fs4',3)
    subjDir=[subjId '_fs4'];
else
    subjDir = subjId;
    subjId = subjId(1:end-4)
end

[ctx] = readDefaultCortex(subjId);

lastLeftVertex = length(ctx.vertices)/2;

hemis = { 'L', 'R'};  

values = [];

for iRoi = 1:length(labelNames)
  
    thisRoi = labelNames{iRoi};
    [l v ] = fsLabel2mneLabel(subjId,thisRoi);
   
    for iHemi =1:2,
        
        hemiName = hemis{iHemi};
        
        if iHemi ==1
            vertList = l(l<=lastLeftVertex);
        else
            vertList = l(l>lastLeftVertex);
        end
        
        %labelFilename = fullfile(freesurfDir,subjDir,'label',[ hemiName '.' labelName '.label']);
    
        clear ROI

        ROI.name = ['fs' upper(thisRoi)];
        ROI.coords = [];
        ROI.color = [1 .5 .9];
        ROI.ViewType = 'Gray';
        ROI.meshIndices = vertList; 
        %fill the mesh hash field, I don't think this is the right
        %value to use, but I'm not sure where this get's used
        ROI.meshHash = hashOld(ctx.vertices(:),'md5');
        ROI.date = datestr(now,0);
        ROI.comment = 'Freesurfer label made by fsLabel2Roi.m';

        roiFilename = fullfile(anatDir,subjId,[ROI.name '-' upper(hemiName)]);
        
        
        roiFilename
        save(roiFilename,'ROI')
        
    end
    
    
end

    
%% Collect functionally defined ROIs and transform to the MNI105 surface


freesurfDir = getpref('freesurfer','SUBJECTS_DIR');
anatDir = getpref('mrCurrent','AnatomyFolder')

toSubj = 'mni0001'


roiList = { ...
'V1' ...
'V1D' ...
'V1V' ...
'V2D' ...
'V2V' ...
'V3A' ... 
'V3D' ...
'V3V' ...
'V4' ...
'MT' ...
'LOC' ...
'IPS' ...
'TOPJ' ...
'VO1' ...
'VO2'};


subjDirList = dir(fullfile(freesurfDir,'skeri*_fs4'));
correctList = regexp({subjDirList.name},'skeri\d{4,4}_fs4');

for i=1:length(correctList)
    realSubjs(i) = ~isempty(correctList{i});
end

subjDirList = subjDirList(realSubjs);

    
nSubj = length(subjDirList);

hemiName = {'L' 'R'};

subjIdx = 0;

for iSubj=1:length(subjDirList),
    
    sbjName = subjDirList(iSubj).name
    disp(['Processing: ' sbjName]);
    
    srcFilename = fullfile(freesurfDir,sbjName,'bem',[sbjName '-ico-5p-src.fif']);
    if ~exist(srcFilename,'file')
        disp(['Cannot find SOURCE SPACE FILE for subject: ' sbjName])
        continue;
    end
    
    
    roiDir = fullfile(anatDir,sbjName(1:end-4),'Standard','meshes','ROIs');

    [mapMtx] = makeDefaultCortexMorphMap(sbjName(1:end-4),'mni0001');
    
    if iSubj ==1;
        allRoisMap = zeros(length(roiList),2,size(mapMtx,2));
        clear allRois;
    end
    subjIdx = subjIdx + 1;
    
    for iRoi = 1:length(roiList),
        disp(['Loading ROI: ' roiList{iRoi}])
        
        for iHemi = 1:2,
            
            if iSubj ==1;
                allRois(iRoi,iHemi).map = zeros(size(mapMtx,2),1);
                roiSubjNum = zeros(length(roiList),2);
            end
            
            
            roiFilename = fullfile(roiDir,[roiList{iRoi} '-' hemiName{iHemi} '.mat']);
            
            
            if ~exist(roiFilename,'file')
                disp(['Subject: ' sbjName ' missing roi: ' roiList{iRoi} '-' hemiName{iHemi}]);
                continue;
            end
            
            origRoi = zeros(size(mapMtx,2),1);
            thisROI = load(roiFilename);
            origRoi(thisROI.ROI.meshIndices) = 1;
            
            transRoi = mapMtx*origRoi;
            
            %allRois(iRoi,iHemi).map = allRois(iRoi,iHemi).map+transRoi;
            allRoisMap(iRoi,iHemi,:) = squeeze(allRoisMap(iRoi,iHemi,:))+transRoi;
            roiSubjNum(iRoi,iHemi) = roiSubjNum(iRoi,iHemi) +1;
            allRois(iRoi,iHemi).sbjName{subjIdx} = sbjName;
            allRois(iRoi,iHemi).ROI(iSubj) = thisROI.ROI;  
            
                
        end
    end
end

        
    




%% Write out combined ROI files


tstFS = -nrmAllRois(1,2,:)+nrmAllRois(4,2,:)-nrmAllRois(7,2,:)+nrmAllRois(6,2,:)+nrmAllRois(5,2,:)-nrmAllRois(8,2,:)+nrmAllRois(9,2,:)+nrmAllRois(10,2,:)-nrmAllRois(11,2,:);


for iRoi = 1:length(roiList),
       for iHemi = 1:2,
    
           groupVerts = find(nrmAllRois(iRoi,iHemi,:)>.1);
           
           ROI = allRois(iRoi,iHemi).ROI(1);
           
           ROI.meshIndices = groupVerts;
           
           ROI.comment = ['ROI averaged over ' num2str(roiSubjNum(iRoi,iHemi)) ' subjects'];
           ROI.created = datestr(now,0);
           ROI.modified = datestr(now,0);
           ROI.date = datestr(now,0);

           outputFilename = [ ROI.name '.mat']
           save(outputFilename,'ROI')
           
       end
end



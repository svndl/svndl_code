function [srcCor] = makeBilatRoiSrcCor(subjId,srcSize)
%function [srcCor] = makeRoiSrcCor(subjId)


if ~exist('srcSize','var') || isempty(srcSize)
    srcSize = 20484;
end

anatDir = getpref('mrCurrent','AnatomyFolder');
        
subjRoiDir = fullfile(anatDir,subjId,'Standard','meshes','ROIs');

[roiList leftVerts rightVerts leftSizes rightSizes] = getRoisByType(subjRoiDir,'func');

totalDx = [leftVerts rightVerts];
       

          
                                       
srcCor = sparse(srcSize,srcSize);
                             

leftRoiList = find([roiList(:).isLeft]);
rightRoiList = find([roiList(:).isRight]);
leftRoi = roiList(leftRoiList);
rightRoi = roiList(rightRoiList);



if length(leftRoiList) ~= length(rightRoiList)
    error('Bilateral ROI creation ERROR, non paired rois found');
end


for iRoi = 1:length(leftRoi),
             
    
    leftSrcIdx = leftRoi(iRoi).meshIndices;
    leftName = upper(leftRoi(iRoi).name(1:end-2));
    
    rightIdx = strncmp(upper(leftName),upper({rightRoi.name}),length(leftName));
    
    [iRoi rightIdx]
    
    rightSrcIdx = rightRoi(rightIdx).meshIndices;

    srcIdx = [leftSrcIdx rightSrcIdx];
    
    srcVec = sparse(srcSize,1);
    srcVec(srcIdx) = 1;
%     roiWeight = length(srcIdx).^-params.areaExp %Inverse area weighting
%     %            srcVec(srcIdx) = length(srcIdx).^-2; %Inverse area weighting
    
    srcCor = srcCor+(srcVec*srcVec');
            
end
        
%             totalSizes = [leftSizes rightSizes];
%             
%             srcVec(totalDx) = totalSizes.^-1; % <- Scale power with the inverse area
%             
%             srcCov = srcVec*srcVec';

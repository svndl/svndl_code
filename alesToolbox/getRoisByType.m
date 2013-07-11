function [roiInfo leftVerts rightVerts leftSizes rightSizes] = getRoisByType(roiDir,type)
%function [roiInfo] = getRoisByType(roiDir,type)
%function [chunker] = createChunkerFromMeshRoi(roiDir,nTotalVert)
%The chunker matrix maps the full(~128 x nTotalVert) forward/inverse matrix
%onto onto a chunked 128xnMeshRois
%
%Inputs:
%roiDir is the director that contains the mesh ROI files.
%type is one of: 'func', 'anat', 'all'
%
%Outputs:
%
% roiInfo: A struct with all the ROI info in it.
%
% leftVerts: A concated vector of all the left ROI vertices
% rightVerts: a concatenated vector of all the rigth ROI vertices

% $Log: getRoisByType.m,v $
% Revision 1.4  2009/05/19 20:46:08  ales
% Fixed naming problem
%
% Revision 1.3  2009/05/19 19:32:03  ales
% Fixed a stupid bug to do with different ROI structures between functional
% and ROIs
%
% Revision 1.2  2008/10/13 22:04:56  ales
% *** empty log message ***
%
% Revision 1.1  2008/09/16 18:41:46  ales
% more fixes/changes to the MNE pipeline
%


%AroiDir = '/Volumes/MRI-1/anatomy/ales/Standard/meshes/ROIs/';

roiList = dir(fullfile(roiDir, '*.mat'));

nAreas = length(roiList);
%length(areas2Lump);



if ~isempty(strfind(type,'func'))
    
    tagString = 'MLR';
    
elseif ~isempty(strfind(type,'anat'))
    tagString = 'anat';
else
    tagString = '';
end


idx = 1;
leftVerts =[];
rightVerts =[];
leftSizes =[];
rightSizes =[];

for iArea=1:nAreas,       
    load(fullfile(roiDir,roiList(iArea).name));
    
    [pathstr roiName ext] = fileparts(roiList(iArea).name);

    if ~strcmp(type,'all')
        if isempty(strfind(ROI.comment,tagString));
           continue;
        end
    end
    
    ROI.meshIndices = ROI.meshIndices(find(ROI.meshIndices>0));
    
    roiSize = length(ROI.meshIndices);
    ROI.name = roiName;
    
    if strcmp(ROI.name(end-1:end),'-L')
        ROI.isLeft  = true;
        ROI.isRight = false;
        
        leftVerts = [leftVerts ROI.meshIndices];
        leftSizes = [leftSizes roiSize*ones(size(ROI.meshIndices))];
    elseif strcmp(ROI.name(end-1:end),'-R')
        ROI.isLeft  = false;
        ROI.isRight = true;
        rightVerts = [rightVerts ROI.meshIndices];   
        rightSizes = [rightSizes roiSize*ones(size(ROI.meshIndices))];
    else
        ROI.isLeft  = false;
        ROI.isRight = false;
    end
    
    rf2 = fieldnames(ROI);

    nameList = rf2;%union(rf1,rf2);
    for i=1:length(nameList)
        roiInfo(idx).( [nameList{i}] ) = ROI.([nameList{i}]);
    end


    %    roiInfo(idx) = ROI;
    idx = idx+1;
    
end

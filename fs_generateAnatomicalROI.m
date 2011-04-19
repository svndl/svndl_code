function [labeledVert colortable indices] = fs_generateAnatomicalROI(fsSubjectDir,emseMeshFilename,annotName);
%fs_generateAnatomicalROI - generates ROI files for use with mrCURRENT
%function [labeledVert colortable indices] = fs_generateAnatomicalROI(fsSubjectDir,emseMeshFilename,annotFilename,roiDir);
%
%This function takes a subject that's been run through the freesurfer
%pipeline and an emse wireframe and generates ROI's based on the anatomical
%labelling freesurfer does.
%
%fsSubjectDir = The freesurfer directory for this subject
%emseMeshFilename = the .wfr file that contains both hemispheres
%                    concatenated together
%annotName    = 'aparc' or 'aparc.a2005s' 
%                aparc is the Desikan et al. 2007 atlas
%                aparc.a2005s is the Fischl et al. atlas



[emseVertex,emseFace]=mesh_emse2matlab(emseMeshFilename);


%Loop through the left and right hemispheres
for hemi = [ 'l' 'r'],
        
    %construct the fs filename
    fsMeshFilename = [fsSubjectDir filesep 'surf' filesep hemi 'h.pial'];

%    [fsVertex,fsFace]=freesurfer_read_surf(fsMeshFilename);

    

    % Emse to FS coordinate systems are driving me bonkers -jma
    % the following code recreates the transforms that happen when writing
    % out an emse .wfr file, these transformations seem to span a few files:
    % fs_writeEMSEMeshfromFreesurfer does the first one
    % mesh_write_emse does the last 3,
    % I'm  fairly befuddled as to where/how/why this transformations occur
    % but this seems to work
    [fsVertex,fsFace]=freesurfer_read_surf(fsMeshFilename);

    fsVertex = fsVertex(:,[2 3 1]);

    fsVertex = rz(fsVertex,-90,'degrees'); % default -90 **** LGA
    fsVertex(:,3)=-fsVertex(:,3);
   
    fsVertex = fsVertex+128;
%    vertex.(hemi) = fsVertex;

%vertex.both = [vertex.r;vertex.l];
%fsVertexList.r = 1:length(vertex.r);
%fsVertexList.l = [1:length(vertex.l)]+length(vertex.r);



%[indices sqError] = nearpoints(emseVertex,vertex.both');
[indices sqError] = nearpoints(emseVertex,fsVertex');

%let's get all the vertices that match the current hemisphere we've loaded
%from freesurfer, everything with an error on the order of epsilon ~ 10^-16
%indices(find(sqError>100*eps))=1;
thisHemiVerts = find(sqError<100*eps);

%averageDistanceError = mean(sqrt(sqError))
%Let's do a little sanity checking, there shouldn't be any error
%between the subset vertices and the high res meshes.
if (length(indices) < length(emseVertex)/4)
    error('Meshes do not align, number of extracted vertices anomalous')
end


%for hemi =[ 'r' 'l'],

 %   thisList = fsVertexList.(hemi);
    
    annotFilename = [fsSubjectDir filesep 'label' filesep hemi 'h.' annotName '.annot'];
    
    [vertIndices label colortable ] = read_annotation(annotFilename);

 %   annotLabel.(hemi) = label

%annotLabel.both=[anootLabel.r;annotLabel.l];
%Tricky business choosing the right vertices.
%Emse mesh has both lh and rh glued together, the freesurfer meshes
%are in two files
%
labeledVert = zeros(length(emseVertex),1);
labeledVert(thisHemiVerts) = label(indices(thisHemiVerts));


    nLabels = length(colortable.struct_names);
    
    %here we make up the ROI structure, pulling information from various
    %sources.
    for iLabel = 1:nLabels,

        %here I grab the label id for this label from the colortable
        thisID=colortable.table(iLabel,5);
        vertList = find(labeledVert==thisID);
        
        clear ROI

        ROI.name = colortable.struct_names{iLabel};
        ROI.coords = [];
        ROI.color = colortable.table(iLabel,1:3);
        ROI.ViewType = 'Gray';
        ROI.meshIndices = vertList; 
        %fill the mesh hash field, I don't think this is the right
        %value to use, but I'm not sure where this get's used
        ROI.meshHash = hashOld(emseVertex(:),'md5');
        ROI.date = datestr(now,0);
        ROI.comment = 'Freesurfer anatomical labeling made by fs_generateAnotomicalROI.m';

        roiFilename = [ROI.name '-' upper(hemi)];
        
        roiFilename
        save(roiFilename,'ROI')
		
% THe following code plots labeled vertices. Good for debugging, and
% diagnoising errors
%{
        figure(42)
        cp=campos;
        clf
        scatter3(emseVertex(1,1:end),emseVertex(2,1:end),emseVertex(3,1:end),60,'g')
        hold on;
        scatter3(emseVertex(1,vertList),emseVertex(2,vertList),emseVertex(3,vertList),30,'r','filled')
        axis equal
        campos(cp);
        pause;
%}        


    end


end


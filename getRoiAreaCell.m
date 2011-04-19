%% Load data:

stdDir = '/raid/MRI/anatomy/ales/Standard/';

wfrFile = [stdDir '/EMSE_Headmodel_Parts/decp1_pial_102207_cortex.wfr'];
%wfrFile = [stdDir '/EMSE_Headmodel_Parts/cortex_decp01_pial_070505_cortex.wfr'];
%wfrFile = [stdDir '/EMSE_Headmodel_Parts/cortex_pial_decp01_060105_cortex.wfr'];

roiDir =  [stdDir 'meshes/ROIs/'];

[vertex face] = emse_read_wfr(wfrFile);
FV.faces = [face.vertex1; face.vertex2; face.vertex3]';
FV.vertices  = [vertex.x; vertex.y; vertex.z]';
area = mesh_face_area(FV);

[funcChunk list] = createChunkerFromMeshRoi(roiDir,length(FV.vertices));

%retinoChunk = funcChunk(:,3:22);
retinoChunk = funcChunk(:,[3:6 9:end]);

%%
roiArea = [];

for iRetino = size(retinoChunk,2),


    roiVertList = find(retinoChunk(:,iRetino));

    [roiFaceList,c] = find(ismember(FV.faces,roiVertList));

    roiArea(iRetino) = sum(area(unique(roiFaceList)));

end


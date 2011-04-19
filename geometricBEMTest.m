% Set-up paths -----------------------------------------------------

% 1) Add BrainStorm path 
%addpath('e:\brainstorm2001\toolbox')  % EDIT

% 2) Where is your data ? Create a database entry
% a) Anatomy (i.e. so-called SUBJECTS folder)
UserDB(1).STUDIES = '/Users/ales/cvs/ales/premadeMeshes/'; % EDIT
% b) Functional (e.g. MEG/EEG, so-called STUDIES folder)
UserDB(1).SUBJECTS = '/Users/ales/cvs/ales/premadeMeshes/'; % EDIT
UserDB(1).FILELIST = '';

% Store this information in Matlab's preferences
setpref('BrainStorm','UserDataBase',UserDB);
setpref('BrainStorm','iUserDataBase',1);
    

clear fwOPTIONS

fwOPTIONS = bst_headmodeler;

% Store arguments to be passed to main script in fwOPTIONS structure
%StudyFile = '/home/ales/data/new_ucb/study/Testing/Testing_brainstormstudy.mat'; % path to BrainStorm studyfile (i.e. database entry) % EDIT
fwOPTIONS.Method = {'eeg_bem'}; 
fwOPTIONS.ChannelFile = '/Users/ales/cvs/ales/premadeMeshes/hemi_Channel.mat';
fwOPTIONS.rooot = '/Users/ales/cvs/ales/premadeMeshes';
fwOPTIONS.ChannelType = 'EEG';

% Use scalp tessellation to fit sphere to head
%fwOPTIONS.Scalp.FileName = '/home/ales/data/new_ucb/subject/JMA/jma_head_meters_tess';  % EDIT
%fwOPTIONS.Scalp.iGrid = 2; % Location of head envelope in .FileName tessellation cell arrays % EDIT % 

% Use cortex or white/gray interface to distribute sphere to distribute source models
%fwOPTIONS.Cortex.FileName = 'I:\Data\Subjects\NDiaye\S10\S10_tess.mat';  % EDIT
%fwOPTIONS.Cortex.iGrid = 4; % WARNING : for all subjects in this study but S7 where .iGrid = 10 % EDIT % 

fwOPTIONS.Cortex.FileName = '/Users/ales/cvs/ales/premadeMeshes/hemi_cortex.mat';
fwOPTIONS.Cortex.iGrid = 1; 

%fwOPTIONS.Cortex
%fwOPTIONS.VolumeSourceGrid = 1;
%fwOPTIONS.VolumeSourceGridSpacing = 4;
%fwOPTIONS.Cortex
%fwOPTIONS.ApplyGridOrient = 1;
fwOPTIONS.VolumeSourceGrid = 0;
%fwOPTIONS.VolumeSourceGridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceLoc =  sourceLocs; % 3xN
%fwOPTIONS.GridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceOrient =  sourceNormals; % 3xN
fwhOPTIONS.ImageGridBlockSize =1000;



% Type HELP BST_HEADMODELER.M for further info on the following arguments 
%fwOPTIONS.HeadModelFile = 'tcBEM';
%fwOPTIONS.ImageGridFile = 'tcBEM';
fwOPTIONS.Verbose = 1;


%Options for creating a boundary element model
fwOPTIONS.BEM.Interpolative = 0;
fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/hemi_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'inner_skull';



fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/hemi_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'outer_skull';


fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/hemi_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{3}.TessName = 'scalp';

% fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'brain';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'skull';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessName = 'scalp';


fwOPTIONS.BEM.Basis = 'linear';
fwOPTIONS.BEM.Test = 'Collocation';
fwOPTIONS.BEM.ISA = 1;
fwOPTIONS.BEM.NVertMax = 3000;
fwOPTIONS.BEM.checksurf = 0;
fwOPTIONS.ForceXferComputation =true;

fwOPTIONS.Conductivity = [.33 .0042 .33];

fwOPTIONS.HeadModelFile = 'test_hemi';
%%
% Call main function
[OPTIONS.HeadModelFile, tmp] = bst_headmodeler(fwOPTIONS);
% -> Done with Forward modelling 






%% CYLINDER TEST
   

clear fwOPTIONS

fwOPTIONS = bst_headmodeler;


sourceZ = -.07:.005:.07;
sourceX = zeros(size(sourceZ));
sourceY = zeros(size(sourceZ));

sourceLocs = [sourceX; sourceY; sourceZ];

% Store arguments to be passed to main script in fwOPTIONS structure
%StudyFile = '/home/ales/data/new_ucb/study/Testing/Testing_brainstormstudy.mat'; % path to BrainStorm studyfile (i.e. database entry) % EDIT
fwOPTIONS.Method = {'eeg_bem'}; 
fwOPTIONS.ChannelFile = '/Users/ales/cvs/ales/premadeMeshes/cyl_Channel.mat';
fwOPTIONS.rooot = '/Users/ales/cvs/ales/premadeMeshes';
fwOPTIONS.ChannelType = 'EEG';

% Use scalp tessellation to fit sphere to head
%fwOPTIONS.Scalp.FileName = '/home/ales/data/new_ucb/subject/JMA/jma_head_meters_tess';  % EDIT
%fwOPTIONS.Scalp.iGrid = 2; % Location of head envelope in .FileName tessellation cell arrays % EDIT % 

% Use cortex or white/gray interface to distribute sphere to distribute source models
%fwOPTIONS.Cortex.FileName = 'I:\Data\Subjects\NDiaye\S10\S10_tess.mat';  % EDIT
%fwOPTIONS.Cortex.iGrid = 4; % WARNING : for all subjects in this study but S7 where .iGrid = 10 % EDIT % 

%fwOPTIONS.Cortex.FileName = '/Users/ales/cvs/ales/premadeMeshes/cyl_cortex.mat';
%fwOPTIONS.Cortex.iGrid = 1; 

%fwOPTIONS.Cortex
%fwOPTIONS.VolumeSourceGrid = 1;
fwOPTIONS.VolumeSourceGridSpacing = 4;
%fwOPTIONS.Cortex
%fwOPTIONS.ApplyGridOrient = 1;
fwOPTIONS.VolumeSourceGrid = 0;
fwOPTIONS.VolumeSourceGridLoc =  sourceLocs; % 3xN
fwOPTIONS.SourceLoc =  sourceLocs; % 3xN
fwOPTIONS.GridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceOrient =  sourceNormals; % 3xN
fwhOPTIONS.ImageGridBlockSize =1000;



% Type HELP BST_HEADMODELER.M for further info on the following arguments 
%fwOPTIONS.HeadModelFile = 'tcBEM';
%fwOPTIONS.ImageGridFile = 'tcBEM';
fwOPTIONS.Verbose = 1;


%Options for creating a boundary element model
fwOPTIONS.BEM.Interpolative = 1;
fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/cyl_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'inner_skull';



fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/cyl_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'outer_skull';


fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/cyl_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{3}.TessName = 'scalp';

% fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'brain';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'skull';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessName = 'scalp';


fwOPTIONS.BEM.Basis = 'linear';
fwOPTIONS.BEM.Test = 'Collocation';
fwOPTIONS.BEM.ISA = 1;
fwOPTIONS.BEM.NVertMax = 3000;
fwOPTIONS.BEM.checksurf = 0;
fwOPTIONS.ForceXferComputation =true;

fwOPTIONS.Conductivity = [.33 .0042 .33];

fwOPTIONS.HeadModelFile = 'test_cyl';

% Call main function
[OPTIONS.HeadModelFile, tmp] = bst_headmodeler(fwOPTIONS);
% -> Done with Forward modelling 








%% Make SPHERE and ELLIPSOIDS

emse_write_wfr('sphere_scalp.wfr',pSph2*.1,triSph2,'scalp','hspace')
emse_write_wfr('sphere_outer_skull.wfr',pSph2*.09,triSph2,'outer skull','hspace')
emse_write_wfr('sphere_inner_skull.wfr',pSph2*.08,triSph2,'inner skull','hspace')

pEllipX(:,1) = pSph2(:,1)*.75;

emse_write_wfr('sphere_cortex.wfr',pEllipX*.07,triSph2,'cortex','hspace')

mesh_emse2brainstorm('sphere_',{'cortex', 'inner_skull','outer_skull','scalp'})

emse_write_wfr('sphereBig_scalp.wfr',pSph3*.1,triSph3,'scalp','hspace')
emse_write_wfr('sphereBig_outer_skull.wfr',pSph3*.09,triSph3,'outer skull','hspace')
emse_write_wfr('sphereBig_inner_skull.wfr',pSph3*.08,triSph3,'inner skull','hspace')

pEllipX(:,1) = pSph2(:,1)*.75;

emse_write_wfr('lineSource_cortex.wfr',pEllipX*.07,triSph2,'cortex','hspace')

mesh_emse2brainstorm('sphereBig_',{'cortex', 'inner_skull','outer_skull','scalp'})




emse_write_wfr('egg_scalp.wfr',pEllipX*.1,triSph2,'scalp','hspace')
emse_write_wfr('egg_outer_skull.wfr',pEllipX*.09,triSph2,'outer skull','hspace')
emse_write_wfr('egg_inner_skull.wfr',pEllipX*.08,triSph2,'inner skull','hspace')

emse_write_wfr('egg_cortex.wfr',pEllipX*.07,triSph2,'cortex','hspace')



pEllipX(:,1) = pSph2(:,1)*.75;

pLine= pSph2*.08;

pLine(:,[2 3])= pLine(:,[2 3])*.001;

emse_write_wfr('line_cortex.wfr',pLine,triSph2,'cortex','hspace')

mesh_emse2brainstorm('line_',{'cortex'})


mesh_emse2brainstorm('egg_',{'cortex', 'inner_skull','outer_skull','scalp'})
for i=1:435,
Channel(i).Loc=pEllipX(i,:)'*.1;
end
save egg_Channel.mat Channel;


%% Do SPherical BEM

clear fwOPTIONS

fwOPTIONS = bst_headmodeler;


sourceZ = -.07:.005:.07;
sourceX = zeros(size(sourceZ));
sourceY = zeros(size(sourceZ));

sourceLocs = [sourceX; sourceY; sourceZ];

% Store arguments to be passed to main script in fwOPTIONS structure
%StudyFile = '/home/ales/data/new_ucb/study/Testing/Testing_brainstormstudy.mat'; % path to BrainStorm studyfile (i.e. database entry) % EDIT
fwOPTIONS.Method = {'eeg_bem'}; 
fwOPTIONS.ChannelFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphere_Channel.mat';

%fwOPTIONS.ChannelFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/egg_Channel.mat';
fwOPTIONS.rooot = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/';
fwOPTIONS.ChannelType = 'EEG';

% Use scalp tessellation to fit sphere to head
%fwOPTIONS.Scalp.FileName = '/home/ales/data/new_ucb/subject/JMA/jma_head_meters_tess';  % EDIT
%fwOPTIONS.Scalp.iGrid = 2; % Location of head envelope in .FileName tessellation cell arrays % EDIT % 

% Use cortex or white/gray interface to distribute sphere to distribute source models
%fwOPTIONS.Cortex.FileName = 'I:\Data\Subjects\NDiaye\S10\S10_tess.mat';  % EDIT
%fwOPTIONS.Cortex.iGrid = 4; % WARNING : for all subjects in this study but S7 where .iGrid = 10 % EDIT % 

%fwOPTIONS.Cortex.FileName = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphere_subjecttess.mat';

%fwOPTIONS.Cortex.FileName = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphere_subjecttess.mat';

%fwOPTIONS.Cortex.FileName = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/egg_subjecttess.mat';
fwOPTIONS.Cortex.FileName = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/line_subjecttess.mat';
fwOPTIONS.Cortex.iGrid = 1; 

%fwOPTIONS.Cortex
%fwOPTIONS.VolumeSourceGrid = 1;
%fwOPTIONS.VolumeSourceGridSpacing = 4;
%fwOPTIONS.Cortex
fwOPTIONS.ApplyGridOrient = 0;
fwOPTIONS.VolumeSourceGrid = 0;
%fwOPTIONS.VolumeSourceGridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceLoc =  sourceLocs; % 3xN
%fwOPTIONS.GridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceOrient =  sourceNormals; % 3xN
%fwhOPTIONS.ImageGridBlockSize =100;



% Type HELP BST_HEADMODELER.M for further info on the following arguments 
%fwOPTIONS.HeadModelFile = 'tcBEM';
%fwOPTIONS.ImageGridFile = 'tcBEM';
fwOPTIONS.Verbose = 1;


%Options for creating a boundary element model
%fwOPTIONS.BEM.Interpolative = 0;
%fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphere_subjecttess';
%fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphere_subjecttess';
%fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphere_subjecttess';

fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphereBig_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphereBig_subjecttess';
fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/sphereBig_subjecttess';


% fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/egg_subjecttess';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/egg_subjecttess';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/Users/ales/cvs/ales/premadeMeshes/eggWorld/egg_subjecttess';
% 

fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'inner_skull';
fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'outer_skull';
fwOPTIONS.BEM.EnvelopeNames{3}.TessName = 'scalp';

% fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'brain';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'skull';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/home/ales/data/new_ucb/subject/JMA/nestedSpheres_origin_tess';
% fwOPTIONS.BEM.EnvelopeNames{3}.TessName = 'scalp';


fwOPTIONS.BEM.Basis = 'linear';
fwOPTIONS.BEM.Test = 'Collocation';
fwOPTIONS.BEM.ISA = 1;
fwOPTIONS.BEM.NVertMax = 3000;
fwOPTIONS.BEM.checksurf = 0;
fwOPTIONS.ForceXferComputation =true;

fwOPTIONS.Conductivity = [.33 .025 .33];
%fwOPTIONS.Radii = [ .08 .09 .1];

fwOPTIONS.HeadModelFile = 'test_sphere';

% Call main function
[OPTIONS.HeadModelFile, tmp Gxyz] = bst_headmodeler(fwOPTIONS);
% -> Done with Forward modelling 








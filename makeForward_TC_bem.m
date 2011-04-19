% Set-up paths -----------------------------------------------------

% 1) Add BrainStorm path 
%addpath('e:\brainstorm2001\toolbox')  % EDIT

% 2) Where is your data ? Create a database entry
% a) Anatomy (i.e. so-called SUBJECTS folder)
UserDB(1).STUDIES = '/data/ales/atlasData/TC'; % EDIT
% b) Functional (e.g. MEG/EEG, so-called STUDIES folder)
UserDB(1).SUBJECTS = '/data/ales/atlasData/TC'; % EDIT
UserDB(1).FILELIST = '';

% Store this information in Matlab's preferences
setpref('BrainStorm','UserDataBase',UserDB);
setpref('BrainStorm','iUserDataBase',1);
    

clear fwOPTIONS

fwOPTIONS = bst_headmodeler;

% Store arguments to be passed to main script in fwOPTIONS structure
%StudyFile = '/home/ales/data/new_ucb/study/Testing/Testing_brainstormstudy.mat'; % path to BrainStorm studyfile (i.e. database entry) % EDIT
fwOPTIONS.Method = {'eeg_bem'}; 
fwOPTIONS.ChannelFile = '/data/ales/atlasData/TC/tcAlignedBEM_Channel.mat';
fwOPTIONS.rooot = '/data/ales/atlasData/TC';
fwOPTIONS.ChannelType = 'EEG';

% Use scalp tessellation to fit sphere to head
%fwOPTIONS.Scalp.FileName = '/home/ales/data/new_ucb/subject/JMA/jma_head_meters_tess';  % EDIT
%fwOPTIONS.Scalp.iGrid = 2; % Location of head envelope in .FileName tessellation cell arrays % EDIT % 

% Use cortex or white/gray interface to distribute sphere to distribute source models
%fwOPTIONS.Cortex.FileName = 'I:\Data\Subjects\NDiaye\S10\S10_tess.mat';  % EDIT
%fwOPTIONS.Cortex.iGrid = 4; % WARNING : for all subjects in this study but S7 where .iGrid = 10 % EDIT % 

fwOPTIONS.Cortex.FileName = '/data/ales/atlasData/TC/tc_cortex_tess';
fwOPTIONS.Cortex.iGrid = 1; 

%fwOPTIONS.Cortex
%fwOPTIONS.VolumeSourceGrid = 1;
%fwOPTIONS.VolumeSourceGridSpacing = 4;
%fwOPTIONS.Cortex
fwOPTIONS.ApplyGridOrient = 1;
fwOPTIONS.VolumeSourceGrid = 0;
%fwOPTIONS.VolumeSourceGridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceLoc =  sourceLocs; % 3xN
%fwOPTIONS.GridLoc =  sourceLocs; % 3xN
%fwOPTIONS.SourceOrient =  sourceNormals; % 3xN
fwhOPTIONS.ImageGridBlockSize =400000;



% Type HELP BST_HEADMODELER.M for further info on the following arguments 
%fwOPTIONS.HeadModelFile = 'tcBEM';
%fwOPTIONS.ImageGridFile = 'tcBEM';
fwOPTIONS.Verbose = 1;


%Options for creating a boundary element model
fwOPTIONS.BEM.Interpolative = 0;

fwOPTIONS.BEM.EnvelopeNames{1}.TessFile = '/data/ales/atlasData/TC/tc_brain_tess';
fwOPTIONS.BEM.EnvelopeNames{1}.TessName = 'brain';



fwOPTIONS.BEM.EnvelopeNames{2}.TessFile = '/data/ales/atlasData/TC/tc_skull_tess';
fwOPTIONS.BEM.EnvelopeNames{2}.TessName = 'skull';


fwOPTIONS.BEM.EnvelopeNames{3}.TessFile = '/data/ales/atlasData/TC/tc_scalp_tess';
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
fwOPTIONS.BEM.NVertMax = 1000;
fwOPTIONS.BEM.checksurf = 1;
fwOPTIONS.ForceXferComputation =1;

fwOPTIONS.Conductivity = [.33 .025 .33];


% Call main function
[OPTIONS.HeadModelFile, tmp] = bst_headmodeler(fwOPTIONS);
% -> Done with Forward modelling 
































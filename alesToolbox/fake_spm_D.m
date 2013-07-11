%% make D
clear D D2 datafile

val = 1;

myFileName = 'test.dat';
D = [];

D.Fsample = 1000;

nchan = 128;
D.channels = repmat(struct('bad', 0), 1, nchan);
D.timeOnset = 0;

D.Nsamples = 2;
ntrial = 1;

D.data.fnamedat = myFileName;
D.data.datatype = 'float32-le';

datafile = file_array(D.data.fnamedat, [nchan D.Nsamples ntrial], D.data.datatype);


D.trials(1).label = 'Trial 1';
D.trials(1).onset = 0;
%D.trials(1).events = 1;
% select_events(event, [ trl(1, 1)./D.Fsample-S.eventpadding  trl(1, 2)./D.Fsample+S.eventpadding]);

datafile(:, :, 1) = EEG_fwd(:,[repmat(1,1,D.Nsamples)]);%zeros(nchan,D.Nsamples,1);

D.sensors.eeg = [];
D.fname = myFileName;
D2{1} = meeg(D);
%save(D);


%D = spm_eeg_prep(S1);

% 
% D{1} = DATA;


%
%load('/Volumes/Denali_MRI/toolbox/matlab_toolboxes/Benoit_toolbox/MEEG_simulation_toolbox/Initialisation.mat');


inv.gainmat = EEG_fwd;
inv.forward(1).modality = 'eeg';
inv.mesh.tess_mni.vert = s48_vertices;
inv.mesh.tess_mni.face = s48_faces;

inv.inverse.modality = 'eeg';
inv.inverse.rad = 5000;
inv.inverse.type = 'LOR';

D2{1}.inv{1} = {inv};
D = spm_eeg_invert_stanford(D2);


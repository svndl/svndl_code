

%% build project structure
% likova has incompatbile freesurfer & vistasoft meshes
% schira isn't flipped in freesurfer like everybody else
clear
FSdir = '/raid/MRI/anatomy/FREESURFER_SUBS';
OUTdir = '/raid/MRI/projects/nicholas/Averaging';
Subj = struct(	'FSname',{'ferree_fs','kontsevich_fs','likova_fs','nicholas_fs','norcia_fs','pettet_fs','schira_fs','still_fs','tyler_fs','vildavski_fs'},...
					'FSflipLR',{true,true,true,false,true,true,false,true,true,true},...
					'VSdir',{	'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Ferree_011204_ret',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/KONTSEVICH/041904_kontsevich_ret',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/LIKOVA_RESTORE',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Nicholas_090706',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Norcia_091803_ret_BEST',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Pettet_082603_ret',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Schira_111004_ret',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Still_032405',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Tyler2_031803_ret',...
									'/raid/darwin_MRI/data/CWT_MAPPING/ADVANCED_RETINOTOPY/Viildavski_062403_ret'	},...
					'VSiDT',				{3,3,3,3,3,4,3,3,3,4},...
					'VSiScanWedge',	{1,[],1,1,2,1,1,1,1,1},...
					'VSiScanRing',		{2,[],2,2,1,2,2,2,2,2}	);
trgSubj = Subj(1).FSname;
% trgSubj = 'ico';

% addpath('/raid/MRI/toolbox/matlab_toolboxes/EEG_MEG_Toolbox/eeg_toolbox',0)
% addpath('/raid/MRI/toolbox/SperoToolbox/MRI',0)


%% test 
VScorAnal2FSwfiles(Subj(10),FSdir,true);
% ferree - blurred 2mm averages, OK
% kontsevich - unscaled rings/wedges, blurred 5mm averages, too many scans?
% likova - blurred 2mm averages, gray surface doesn't line up with freesurfer
% nicholas - unblurred averages, no LR flip
% norcia - blurred 3mm averages, OK
% pettet - blurred 4mm(dataType3) or 2mm(dataType4) averages, OK
% schira - blurred 2mm averages, no LR flip
% still - blurred 3mm averages, not clear what scans are what?, gray surface doesn't line up with smoothwm
% tyler - blurred 2mm averages, empty gray coords
% vildavski - blurred 3mm(dataType3) or 2mm(dataType4) averages, OK


%% write retinotopic corAnal w-files
Subj = Subj([1 5 6 10]);
nSubj = numel(Subj);
for iSubj = 1:nSubj
	subjid = strtok(Subj(iSubj).FSname,'_');
	Subj(iSubj).wedgeAmpL = fullfile(OUTdir,[subjid,'_wedge_amp_LH.w']);
	Subj(iSubj).wedgeAmpR = fullfile(OUTdir,[subjid,'_wedge_amp_RH.w']);
	Subj(iSubj).wedgePhL = fullfile(OUTdir,[subjid,'_wedge_ph_LH.w']);
	Subj(iSubj).wedgePhR = fullfile(OUTdir,[subjid,'_wedge_ph_RH.w']);
	Subj(iSubj).wedgeCoL = fullfile(OUTdir,[subjid,'_wedge_co_LH.w']);
	Subj(iSubj).wedgeCoR = fullfile(OUTdir,[subjid,'_wedge_co_RH.w']);	
	Subj(iSubj).ringAmpL = fullfile(OUTdir,[subjid,'_ring_amp_LH.w']);
	Subj(iSubj).ringAmpR = fullfile(OUTdir,[subjid,'_ring_amp_RH.w']);
	Subj(iSubj).ringPhL = fullfile(OUTdir,[subjid,'_ring_ph_LH.w']);
	Subj(iSubj).ringPhR = fullfile(OUTdir,[subjid,'_ring_ph_RH.w']);
	Subj(iSubj).ringCoL = fullfile(OUTdir,[subjid,'_ring_co_LH.w']);
	Subj(iSubj).ringCoR = fullfile(OUTdir,[subjid,'_ring_co_RH.w']);
end
Subj = VScorAnal2FSwfiles(Subj,FSdir,false);
disp('converted Gray corAnal to w-files')


%% resample onto common cortical surface
if any([Subj(:).FSflipLR]~=Subj(1).FSflipLR)
	error('All subject must have consistent Left/Right flip')
end
% FSbinDir = '/raid/MRI/toolbox/MGH/freesurfer/bin';
FSbinDir = '/raid/MRI/toolbox/MGH/freesurfer/bin/Linux';

if strcmp(trgSubj,'ico')
	% note: icosahedral projections will all have 10*(4^icoorder)+2 vertices
	trgSubj = [trgSubj,' --trgicoorder 7'];
end
switch 2
case 1	% Alex's parameters
	FSstr = [fullfile(FSbinDir,'mri_surf2surf'),' --srcsubject %s --srcsurfval %s --trgsubject ',trgSubj,' --trgsurfval %s',...
		' --hemi %s --src_type paint --trg_type w --mapmethod nnf --nsmooth-out 4'];
case 2	% forward-reverse mapping
	FSstr = [fullfile(FSbinDir,'mri_surf2surf'),' --srcsubject %s --srcsurfval %s --trgsubject ',trgSubj,' --trgsurfval %s',...
		' --hemi %s --src_type paint --trg_type w --mapmethod nnfr --nsmooth-in 1 --nsmooth-out 4'];
end

hemi = {'lh','rh'};
prefix = ['proj2',strtok(trgSubj,'_ '),'_'];
wFiles = {'wedgeAmp','wedgePh','wedgeCo','ringAmp','ringPh','ringCo'};
for iSubj = 1:nSubj
	for w = 1:numel(wFiles)
		% LH
		srcField = [wFiles{w},'L'];
		trgField = [srcField,'proj'];
		[pathstr,name,ext] = fileparts(Subj(iSubj).(srcField));
		Subj(iSubj).(trgField) = fullfile(pathstr,[prefix,name,ext]);
		FScom = sprintf(FSstr,Subj(iSubj).FSname,Subj(iSubj).(srcField),Subj(iSubj).(trgField),hemi{1+Subj(iSubj).FSflipLR});
		[status,result] = system(FScom);
		if status
			disp(result)
		else
			disp(['Wrote ',Subj(iSubj).(trgField)])
		end
		% RH
		srcField = [wFiles{w},'R'];
		trgField = [srcField,'proj'];
		[pathstr,name,ext] = fileparts(Subj(iSubj).(srcField));
		Subj(iSubj).(trgField) = fullfile(pathstr,[prefix,name,ext]);
		FScom = sprintf(FSstr,Subj(iSubj).FSname,Subj(iSubj).(srcField),Subj(iSubj).(trgField),hemi{2-Subj(iSubj).FSflipLR});
		[status,result] = system(FScom);
		if status
			disp(result)
		else
			disp(['Wrote ',Subj(iSubj).(trgField)])
		end
	end
end
disp(['resampled w-files to ',trgSubj])



%% average resampled files
j = sqrt(-1);		% just in case
nSubj = numel(Subj);
% wedge amplitude,phase
LH = freesurfer_read_wfile(Subj(1).wedgeAmpLproj) .* exp( j * freesurfer_read_wfile(Subj(1).wedgePhLproj) );
RH = freesurfer_read_wfile(Subj(1).wedgeAmpRproj) .* exp( j * freesurfer_read_wfile(Subj(1).wedgePhRproj) );
for iSubj = 2:nSubj
	LH = LH + freesurfer_read_wfile(Subj(iSubj).wedgeAmpLproj) .* exp( j * freesurfer_read_wfile(Subj(iSubj).wedgePhLproj) );
	RH = RH + freesurfer_read_wfile(Subj(iSubj).wedgeAmpRproj) .* exp( j * freesurfer_read_wfile(Subj(iSubj).wedgePhRproj) );
end
avg.wedgeLH = LH / nSubj;
avg.wedgeRH = RH / nSubj;
% wedge coherence
LH = freesurfer_read_wfile(Subj(1).wedgeCoLproj);
RH = freesurfer_read_wfile(Subj(1).wedgeCoRproj);
for iSubj = 2:nSubj
	LH = LH + freesurfer_read_wfile(Subj(iSubj).wedgeCoLproj);
	RH = RH + freesurfer_read_wfile(Subj(iSubj).wedgeCoRproj);
end
avg.wedgeLHco = LH / nSubj;
avg.wedgeRHco = RH / nSubj;
% ring amplitude,phase
LH = freesurfer_read_wfile(Subj(1).ringAmpLproj) .* exp( j * freesurfer_read_wfile(Subj(1).ringPhLproj) );
RH = freesurfer_read_wfile(Subj(1).ringAmpRproj) .* exp( j * freesurfer_read_wfile(Subj(1).ringPhRproj) );
for iSubj = 2:nSubj
	LH = LH + freesurfer_read_wfile(Subj(iSubj).ringAmpLproj) .* exp( j * freesurfer_read_wfile(Subj(iSubj).ringPhLproj) );
	RH = RH + freesurfer_read_wfile(Subj(iSubj).ringAmpRproj) .* exp( j * freesurfer_read_wfile(Subj(iSubj).ringPhRproj) );
end
avg.ringLH = LH / nSubj;
avg.ringRH = RH / nSubj;
% ring coherence
LH = freesurfer_read_wfile(Subj(1).ringCoLproj);
RH = freesurfer_read_wfile(Subj(1).ringCoRproj);
for iSubj = 2:nSubj
	LH = LH + freesurfer_read_wfile(Subj(iSubj).ringCoLproj);
	RH = RH + freesurfer_read_wfile(Subj(iSubj).ringCoRproj);
end
avg.ringLHco = LH / nSubj;
avg.ringRHco = RH / nSubj;




%% convert back to vistasoft map
iSubj = strcmp({Subj(:).FSname},trgSubj);
if sum(iSubj)~=1
	error('expecting exactly one instance of "trgSubj" in the "Subj" structure')
end
avgCorAnal2VSmap(avg,Subj(iSubj),FSdir)







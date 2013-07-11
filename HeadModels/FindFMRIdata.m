function [mrvDir,dataType,iScan,scanName,domEye,hand,diagnosis] = FindFMRIdata(skeriNum,findScan)
% [mrvDir,dataType,iScan,scanName,domEye,hand] = FindFMRIdata(skeriNum,findScan)
%
% skeriNum = integer code
% findScan = ['GUI'], 'Wedge', 'Ring', 'MT', or 'LOC'

% keep scanName output for GUI case

if nargin == 0
	help(mfilename)
	error('Must specify at least the skeriNum argument.')
end
if ~exist('findScan','var') || isempty(findScan)
	findScan = 'GUI';
end

subjId = sprintf('skeri%04d',skeriNum);
mriDir = getpref('VISTA','defaultAnatomyPath');

relRetPath = subjId;
relLOCPath = dir(fullfile(mriDir,'data','LOCMT_fMRI',[subjId,'*']));
switch numel(relLOCPath)
case 1
	relLOCPath = relLOCPath.name;
case 0
	relLOCPath = 'xxx';	%subjId;
otherwise
	error('Multiple LOCMT sessions for subject %s.',subjId)
end

[diagnosis,domEye,hand] = deal('');
[DTret,DTloc] = deal('Blurred3mm');			% Gray dataType to load corAnal from
[iWedge,iRing,iMT,iLOC] = deal(NaN);

% Strabismus - 
%		Esotropia - nasal
%		Exotropia - temporal
%		Hypertropia - upward
%		Hypotropia - downward
% Amblyopia - poor vision one eye (brain)
%		Anisometropia - different refractive errors between eyes

% Subject to analyze
switch skeriNum
	
	case 1
		[domEye,hand] = deal('R','R');
		DTret = 'BlurredAvs3mm';
		[iWedge,iRing] = deal(2,1);	% 4,3?
		[iMT,iLOC] = deal(1,3);			% Flat-usethisone
	case 3
		DTret = 'BlurredAv2mm';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);			% Flat-80
	case 4
		[domEye,hand] = deal('L','L');
		DTret = 'Blurred3mmAverages';
		[iWedge,iRing] = deal(2,1);
		[iMT,iLOC] = deal(2,1);
	case 5
		DTret = 'BlurredAv2mm';
		[iWedge,iRing] = deal(1,2);
% 		relLOCPath = '../RETINOTOPY/skeri0005';
	case 9
		DTret = 'BlurredAv2mm';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 17
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 35
		[domEye,hand] = deal('L','R');
		DTret = 'Averages';
		[iWedge,iRing] = deal(5,6);
		% X:\data\4dImaging\Projects\MTLocalizer\fMRI\skeri0035 ?
	case 36
		[iWedge,iRing] = deal(2,1);
		DTloc = '3mmBlurred';
		[iMT,iLOC] = deal(2,1);
	case 37
		DTret = 'Averages';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'blurred3p5Avs';
		[iMT,iLOC] = deal(2,1);
	case 39
		[domEye,hand] = deal('R','R');
		DTret = 'BlurredAv3mm';
		[iWedge,iRing] = deal(2,1);	% 4,3? - wedges 2&4 same, rings 1&3 different
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 44
		[domEye,hand] = deal('L','');
		DTret = 'BlurredAv2mm';
		[iWedge,iRing] = deal(1,2);
		relLOCPath = '../RETINOTOPY/skeri0044';
		DTloc = 'BlurredAv2mm';
		[iMT,iLOC] = deal(4,3);
	case 47
		[domEye,hand] = deal('L','R');
		DTret = 'Blurred3mmAvs';
		[iWedge,iRing] = deal(3,4);		% 1,2?
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 48
		[domEye,hand] = deal('L','R');
		DTret = 'Blurred2mmAvs';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 49
		DTret = 'Blurred3mmAverages';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(0,1);			% LOC is 1, there is no labelling or data entry for this MT = 4,2?
	case 50
		DTret = 'blurred3mmAverages';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 51
		[domEye,hand] = deal('R','');
		DTret = 'Averages';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(3,2);		% 3,1?
	case 52
		[domEye,hand] = deal('R','');
		DTret = 'Blurred2mmAverages';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 53
		[domEye,hand] = deal('R','');
		DTret = 'Blurred3mmAvg';
		[iWedge,iRing] = deal(1,2);
		DTloc = '4mmBlurredAvs';
		[iMT,iLOC] = deal(2,3);		% 1=high contrast MT, 2=low contrast MT
	case 54
		[domEye,hand] = deal('R','R');
		DTret = '2.5mmBlurredAvs';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 55
		[domEye,hand] = deal('R','R');
		DTret = 'AvgBlurred3mm';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Blurred3mmAvs';
		[iMT,iLOC] = deal(2,1);
	case 56
		[domEye,hand] = deal('L','');
% 		[iWedge,iRing] = deal(1,2);	% 3,2?	Flat-fov60
		DTret = 'Averages';
		[iWedge,iRing] = deal(4,5);	% Flat-fov60
		DTloc = 'Averages';
		[iMT,iLOC] = deal(4,3);			% Flat-fov90
	case 57
		[domEye,hand] = deal('L','');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 58
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(NaN,1);
	case 59
		DTret = 'Blurred3mmAvg';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(NaN);
	case 61		% has MT,LOC scans (not reconned) no ret
		[iWedge,iRing]  = deal(NaN);
	case 60
		DTret = 'Averages';
		[iWedge,iRing]= deal(1,2);		% 3,4?
		[iMT,iLOC] = deal(NaN);
	case 62
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 63
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		relLOCPath = [relLOCPath,filesep,'Session1'];
		[iMT,iLOC] = deal(2,1);
	case 64
		DTret = 'Blurred3mmAvg';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 65
		[iWedge,iRing]  = deal(NaN);
		[iMT,iLOC] = deal(2,1);
	case 66
		[domEye,hand] = deal('R','');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 67
		diagnosis = 'Strabismus';
		domEye = 'L';
		[iWedge,iRing] = deal(2,3);
		relLOCPath = '../RETINOTOPY/skeri0067';
		[iMT,iLOC] = deal(1,NaN);		% in RETINOTOPY session
	case 68
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'R';
		[iWedge,iRing] = deal(1,2);
		relLOCPath = '../RETINOTOPY/skeri0068';
		[iMT,iLOC] = deal(3,NaN);		% in RETINOTOPY session
	case 69
		[domEye,hand] = deal('L','L');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 71
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 72
		[iWedge,iRing] = deal(1,2);
		relLOCPath = '../RETINOTOPY/skeri0072';
		[iMT,iLOC] = deal(3,NaN);
	case 73
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 74
		[domEye,hand] = deal('L','');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 75
		relRetPath = '../LOCMT_fMRI/skeri0075_012109';		% ALSO HAS REGULAR RETINOTOPY?
		[iWedge,iRing] = deal(3,4);
		[iMT,iLOC] = deal(1,2);
	case 76
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(3,4);
		relLOCPath = '../RETINOTOPY/skeri0076';
		[iMT,iLOC] = deal(1,2);
	case 77
		[domEye,hand] = deal('L','R');
		[iWedge,iRing] = deal(3,NaN);
		relLOCPath = '../RETINOTOPY/skeri0077';
		[iMT,iLOC] = deal(1,2);
	case 78
		diagnosis = 'Anisometropia+Amblyopia';
		domEye = 'R';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 79
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 81
		[domEye,hand] = deal('L','L');
% 		DTret = 'Blurred3mmMC';		% take it or leave it?  about the same as Blurred3mm.
 		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 82
		[domEye,hand] = deal('L','R');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 83
		diagnosis = 'Anisometropia+Amblyopia';
		domEye = 'L';
		[iWedge,iRing] = deal(NaN,NaN);		% no Retinotopy Scan
		[iMT,iLOC] = deal(NaN,NaN);			% LOCMT session not motion corrected,averaged/blurred yet
	case 84
		diagnosis = 'Anisometropia+Amblyopia';
		domEye = 'R';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 87
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'L';
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Averages';
		[iMT,iLOC] = deal(2,1);		% in Averages dataTYPE, not Blurred3mm
	case 93
		[domEye,hand] = deal('R','L');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);		% !!!Needs a new unfold.  MT clearly cropped!!! (10/6/10)
	case 94
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'L';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 95
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 96
		diagnosis = 'Amblyopia+???';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);		% Bad LOC ROI - ventral piece selected!!! (10/6/10), fixed 8/16/11 along with MT
	case 97		% no binocular retinotopies?
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'L';
		switch 1
		case 1
			relRetPath = [subjId,'/skeri0097_GoodEye_113009'];		% retinotopy not in normal place
			[iWedge,iRing] = deal(1,2);
		case 2
			relRetPath = [subjId,'/skeri0097_LeftRight_120909'];
			[iWedge,iRing] = deal(1,2);		% [ LE W(CW), LE R(E), LE R(C), LE W(CCW), RE W(CW), RE R(E), RE W(CCW), RE R(C) ]
		case 3
			relRetPath = [subjId,'/skeri0097_BadEye_021610'];
			[iWedge,iRing] = deal(1,2);
		end
		DTloc = 'Averages';
% 		[iMT,iLOC] = deal(2,1);		% in Averages dataTYPE, not Blurred3mm
		[iMT,iLOC] = deal(4,3);		% in Averages dataTYPE, not Blurred3mm
	case 98
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'R';
		[iWedge,iRing] = deal(1,2);
% 		[iMT,iLOC] = deal(?,?);		% no scans yet
	case 99		% wrong dimensions of morph-maps!!! - fixed for mni0001_fs4, but not other morph-maps
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'L';
		[iWedge,iRing] = deal(1,2);	% [Wedge Ring Wedge Ring] w/ lst 2 empty?, bunch of other dataTYPES w/o corAnals
		[iMT,iLOC] = deal(1,2);
	case 100
		[domEye,hand] = deal('R','');
		relRetPath = [subjId,'/fslMC'];
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 101
		[domEye,hand] = deal('R','R');
		DTret = 'Averages';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(1,2);
	case 102
		[domEye,hand] = deal('R','');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 103
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(NaN,NaN);
	case 108
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		relLOCPath = '../RETINOTOPY/skeri0108';
		[iMT,iLOC] = deal(4,3);
	case 109
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'R';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 112
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 116
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Averages';
		[iMT,iLOC] = deal(2,1);
	case 122
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'R';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 125
		[domEye,hand] = deal('R','R');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 127
		diagnosis = 'Strabismus+Amblyopia';
		domEye = 'L';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 128
		[domEye,hand] = deal('L','R');
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 129
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 131
		diagnosis = 'Amblyopia+???';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 133
		diagnosis = 'Amblyopia+???';
		[iWedge,iRing] = deal(1,2);
% 		[iMT,iLOC] = deal(?,?);		% no scans yet
	case 134
		[iWedge,iRing] = deal(1,2);
		DTloc = 'Averages';
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 135
		[iWedge,iRing] = deal(1,3);
		[iMT,iLOC] = deal(2,1);
	case 136
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 137
		diagnosis = 'Amblyopia+???';
		[iWedge,iRing] = deal(1,2);
% 		[iMT,iLOC] = deal(?,?);		% no scans yet
	case 138
		[iWedge,iRing] = deal(1,2);
% 		[iMT,iLOC] = deal(?,?);		% no scans yet
	case 140
		[iWedge,iRing] = deal(1,2);
		[iMT,iLOC] = deal(2,1);
	case 144
		[iWedge,iRing] = deal(1,2);		
		[iMT,iLOC] = deal(2,1);

	otherwise
		error('Unrecognized subject %d',skeriNum)

end


% -------------------------------------------------------------------


switch lower(findScan)
case 'gui'
	% Choose which scan of specified dataType to use
	dataType = DTret;
	mrvDir = fullfile(mriDir,'data','RETINOTOPY',relRetPath);
	DT = load(fullfile(mrvDir,'mrSESSION.mat'),'dataTYPES');
	iDT = strcmp({DT.dataTYPES.name},dataType);
	switch sum(iDT)
	case 1
	case 0
		error('No dataType %s found in %s retinotopy mrSESSION',dataType,subjId)
	otherwise
		warning('Multiple dataTypes %s found in %s retinotopy mrSESSION???',dataType,subjId)
		iDT = find(iDT,1,'first');
	end
	switch numel( DT.dataTYPES(iDT).scanParams )
	case 1
		iScan = 1;
	case 0
		error('No scans in dataType %s',dataType)
	otherwise
		iScan = menu('Choose scan:',{DT.dataTYPES(iDT).scanParams.annotation});
		if iScan == 0
			return
		end
	end
	scanName = DT.dataTYPES(iDT).scanParams(iScan).annotation;
% 	clear DT iDT
case {'wedge','ring'}
	dataType = DTret;
	mrvDir = fullfile(mriDir,'data','RETINOTOPY',relRetPath);
% 	iScan = eval(['i',regexprep(lower(findScan),'(^.)','${upper($1)}')]);
	if strcmpi(findScan,'wedge')		% doing it this clunkier way to avoid unused variable warnings.
		iScan = iWedge;
	else
		iScan = iRing;
	end
	scanName = findScan;
case {'mt','loc'}
	dataType = DTloc;
	mrvDir = fullfile(mriDir,'data','LOCMT_fMRI',relLOCPath);
% 	iScan = eval(['i',upper(findScan)]);
	if strcmpi(findScan,'mt')
		iScan = iMT;
	else
		iScan = iLOC;
	end
	scanName = findScan;
end

if isnan(iScan)
% 	warning('No %s scan for %s.',scanName,subjId)
	fprintf('WARNING: No %s scan for %s.\n',scanName,subjId)
	return
end

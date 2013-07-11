clear

startPath = 'X:\data\RETINOTOPY';
dirName = 'RawDicom';
ext = '.dcm';
hdrFileName = 'RawDicom-headers.txt';

% genpath is slow
fprintf('Searching %s for %s...\n',startPath,dirName)
tic
% pathTree = genpath(startPath);												% 1x1114124 char ;-delimited
pathTree = strread(genpath(startPath),'%s','delimiter',';');		% 16279x1 cell
toc
% 24+ minutes on wocket

%%

% find all subdirectories of startPath named dirName
nTree = numel(pathTree);
kDir = false(nTree,1);
for i = 1:nTree
	[par,cur] = fileparts(pathTree{i});
	kDir(i) = strcmp(cur,dirName);
end

nExt = numel(ext);
extFlip = fliplr(ext);

% this is slow too
tic
fprintf('\n\nNon-candidate directories:\n')
nDir = sum(kDir);
kClean = false(nDir,1);
kDir = find(kDir);
for i = 1:nDir
	% look what's inside
	d = dir(pathTree{kDir(i)});
	% only keep checking if it contains nothing but directories (no files)
	if all([d.isdir])
		% ignore ".", "..", and anything else starting with "."
		kRealDir = ~strncmp({d.name},'.',1);
		nReal = sum(kRealDir);
		if nReal > 0
			kRealDir = find(kRealDir);
			kClean(i) = true;
			for j = 1:nReal
				% look one layer deeper
				path2= fullfile(pathTree{kDir(i)},d(kRealDir(j)).name);
				d2 = dir(path2);
				kRealDir2 = ~strncmp({d2.name},'.',1);
				% if there is more than one layer deeper stop
				if ~any([d2(kRealDir2).isdir])
					% OK if everything has the right extension (non-case-sensitive)
					if ~all( strncmpi( cellfun(@fliplr,{d2(kRealDir2).name},'UniformOutput',false), extFlip, nExt ) )
						kClean(i) = false;
						fprintf('%s - Non %s files\n',path2,ext)
					end
				else
					kClean(i) = false;
					fprintf('%s - Subdirectories have subdirectories\n',path2)
				end
			end
		else
			fprintf('%s - No subdirectories\n',pathTree{kDir(i)})
		end
	else
		fprintf('%s - Has files%s\n',pathTree{kDir(i)})
	end
end

nClean = sum(kClean);
kClean = find(kClean);
fprintf('\n\nCandidates for archiving:\n')
for i = 1:nClean
	fprintf('%s\n',pathTree{kDir(kClean(i))})

	baseDir = fileparts( pathTree{kDir(kClean(i))} );
% 	hdrFile = fullfile(baseDir,hdrFileName);
% 	fid = fopen(hdrFile,'w');
	cd(baseDir)
	error('Under construction!')
	diary(hdrFileName)			% appends?, check for existence.

	% now redrill & read DICOM header of 1st file in each subfolder and save as text, append all into 1 file?
	d = dir(pathTree{kDir(kClean(i))});
	kRealDir = ~strncmp({d.name},'.',1);
	nReal = sum(kRealDir);
	kRealDir = find(kRealDir);
	for j = 1:nReal
		path2 = fullfile(pathTree{kDir(kClean(i))},d(kRealDir(j)).name);
		d2 = dir(path2);
		kRealDir2 = ~strncmp({d2.name},'.',1);
		hdr = dicominfo( fullfile(path2,d2(find(kRealDir2,1,'first')).name) );
		
% 		hdrFields = fieldnames(hdr);
% 		nField = numel(hdrFields);
% 		for k = 1:nField
% 			fprintf(fid,'%s:???',hdrFields{k},hdr.(hdrFields{k}))		% try diary or logfile?
% 		end
		fprintf(1,'================================================================================\n')		% \n does a CR+LF at least on a PC
		disp(hdr)
		fprintf(1,'\n\n')
	end
	
% 	if fclose(fid) ~= 0
% 		warning('problem closing %s',hdrFile)
% 	end
	diary('off')
	
	% figure out writing the headers & build in tarballing of RawDicom directory for linux
% 	if isunix
% 		[status,result] = system(['chmod 444 ',hdrFileName]);
% 		if status ~= 0
% 			warning(result)
% 		end
% 		[status,result] = system('tar -czvf RawDicom.tgz RawDicom');
% 		if status == 0
% 			[status,result] = system('rm -rf RawDicom');
% 			if status ~= 0
% 				warning(result)
% 			end
% 		else
% 			warning(result)
% 		end
% 	end
	
end
toc


%{
Non-candidate directories:
X:\data\RETINOTOPY\castain\E5976\RawDicom\10 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\11 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\12 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\13 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\14 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\15 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\2 - Non .dcm files
X:\data\RETINOTOPY\castain\E5976\RawDicom\3 - Non .dcm files
X:\data\RETINOTOPY\castain\E5976\RawDicom\7 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\8 - Subdirectories have subdirectories
X:\data\RETINOTOPY\castain\E5976\RawDicom\9 - Subdirectories have subdirectories
X:\data\RETINOTOPY\kontsevich\051605_kontsevich_hemifild\E3468\RawDicom\4 - Non .dcm files
X:\data\RETINOTOPY\palomares\SKERIPCM010407\E6649\RawDicom - No subdirectories
X:\data\RETINOTOPY\schen\schen_051205_retino\RawDicom\2 - Non .dcm files
X:\data\RETINOTOPY\skeri0039\RawDicom - Has filesX:\data\RETINOTOPY\skeri0047\RawDicom\10 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\11 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\12 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\13 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\14 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\15 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\7 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\8 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0047\RawDicom\9 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\11 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\12 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\13 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\14 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\15 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\8 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0048\RawDicom\9 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0049\RawDicom\10 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0049\RawDicom\7 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0049\RawDicom\8 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0049\RawDicom\9 - Subdirectories have subdirectories
X:\data\RETINOTOPY\skeri0052\RawDicom\2 - Non .dcm files
X:\data\RETINOTOPY\skeri0052\RawDicom\3 - Non .dcm files
X:\data\RETINOTOPY\skeri0052\RawDicom\4 - Non .dcm files
X:\data\RETINOTOPY\skeri0056\combined\RawDicom - No subdirectories
X:\data\RETINOTOPY\skeri0064\RawDicom - No subdirectories
X:\data\RETINOTOPY\skeri0082\RawDicom - Has files

Candidates for archiving:
X:\data\RETINOTOPY\PRF\Ring_event_related\SMTJUZ_W\RawDicom
X:\data\RETINOTOPY\PRF\Ring_event_related\skeri0001_070210\RawDicom
X:\data\RETINOTOPY\PRF\Ring_event_related\skeri0055_070210\RawDicom
X:\data\RETINOTOPY\PRF\Ring_event_related\skeri0066_060710\RawDicom
X:\data\RETINOTOPY\PRF\Ring_event_related\skeri0081_071910\RawDicom
X:\data\RETINOTOPY\PRF\Ring_event_related\skeri0082_060710\RawDicom
X:\data\RETINOTOPY\PRF\Ring_event_related\skeri0128_092310\RawDicom
X:\data\RETINOTOPY\PRF\skeri0001_011910\RawDicom
X:\data\RETINOTOPY\PRF\skeri0001_070210\RawDicom
X:\data\RETINOTOPY\PRF\skeri0001_112509\SinewaveBars\RawDicom
X:\data\RETINOTOPY\PRF\skeri0001_112509\WedgesRings\RawDicom
X:\data\RETINOTOPY\PRF\skeri0055_042710\RawDicom
X:\data\RETINOTOPY\PRF\skeri0055_070210\RawDicom
X:\data\RETINOTOPY\PRF\skeri0066_011910\RawDicom
X:\data\RETINOTOPY\PRF\skeri0066_042310\RawDicom
X:\data\RETINOTOPY\PRF\skeri0066_060710\RawDicom
X:\data\RETINOTOPY\PRF\skeri0066_112509\SinewaveBars\RawDicom
X:\data\RETINOTOPY\PRF\skeri0066_112509\WedgesRings\RawDicom
X:\data\RETINOTOPY\PRF\skeri0081_071910\RawDicom
X:\data\RETINOTOPY\PRF\skeri0082_060710\RawDicom
X:\data\RETINOTOPY\PRF\skeri0101_042210\RawDicom
X:\data\RETINOTOPY\PRF\skeri0101_042210\skeri0101_fixedFrames_042210\RawDicom
X:\data\RETINOTOPY\PRF\skeri0128_092310\RawDicom
X:\data\RETINOTOPY\allen\SKERIAJC040606\E5242\RawDicom
X:\data\RETINOTOPY\dk\RawDicom
X:\data\RETINOTOPY\likova\042105_likova_V1localizers\likova_v1Localizers_042105\RawDicom
X:\data\RETINOTOPY\likova\051605_likova_hemifield\E3467\RawDicom
X:\data\RETINOTOPY\norcia\E2756\RawDicom
X:\data\RETINOTOPY\sak\RawDicom
X:\data\RETINOTOPY\schira\111705_schira_quartermap\RawDicom
X:\data\RETINOTOPY\schira\SKERI_SM_050305\RawDicom
X:\data\RETINOTOPY\skeri0001\newDataJune2010\RawDicom
X:\data\RETINOTOPY\skeri0004_USCF32ch\LGN\RawDicom
X:\data\RETINOTOPY\skeri0004_USCF32ch\Vibhas_SKERI-1\RawDicom
X:\data\RETINOTOPY\skeri0044\RawDicom
X:\data\RETINOTOPY\skeri0050\RawDicom
X:\data\RETINOTOPY\skeri0051\RawDicom
X:\data\RETINOTOPY\skeri0053\RawDicom
X:\data\RETINOTOPY\skeri0054\RawDicom
X:\data\RETINOTOPY\skeri0055\RawDicom
X:\data\RETINOTOPY\skeri0056\RawDicom
X:\data\RETINOTOPY\skeri0056\ret110107\RawDicom
X:\data\RETINOTOPY\skeri0057\RawDicom
X:\data\RETINOTOPY\skeri0058\RawDicom
X:\data\RETINOTOPY\skeri0059\RawDicom
X:\data\RETINOTOPY\skeri0060\RawDicom
X:\data\RETINOTOPY\skeri0060\bas\RawDicom
X:\data\RETINOTOPY\skeri0062\RawDicom
X:\data\RETINOTOPY\skeri0063\RawDicom
X:\data\RETINOTOPY\skeri0066\RawDicom
X:\data\RETINOTOPY\skeri0067\RawDicom
X:\data\RETINOTOPY\skeri0068\RawDicom
X:\data\RETINOTOPY\skeri0069\RawDicom
X:\data\RETINOTOPY\skeri0071\RawDicom
X:\data\RETINOTOPY\skeri0072\RawDicom
X:\data\RETINOTOPY\skeri0073\RawDicom
X:\data\RETINOTOPY\skeri0074\RawDicom
X:\data\RETINOTOPY\skeri0074\skeri0074_100708_bakcup\RawDicom
X:\data\RETINOTOPY\skeri0074\skeri0074_100708_bakcup\skeri0074_100708\RawDicom
X:\data\RETINOTOPY\skeri0075\RawDicom
X:\data\RETINOTOPY\skeri0076\RawDicom
X:\data\RETINOTOPY\skeri0077\RawDicom
X:\data\RETINOTOPY\skeri0078\RawDicom
X:\data\RETINOTOPY\skeri0079\RawDicom
X:\data\RETINOTOPY\skeri0081\RawDicom
X:\data\RETINOTOPY\skeri0084\RawDicom
X:\data\RETINOTOPY\skeri0087\RawDicom
X:\data\RETINOTOPY\skeri0093\RawDicom
X:\data\RETINOTOPY\skeri0094\RawDicom
X:\data\RETINOTOPY\skeri0095\RawDicom
X:\data\RETINOTOPY\skeri0096\RawDicom
X:\data\RETINOTOPY\skeri0097\skeri0097_BadEyePRF_021610\RawDicom
X:\data\RETINOTOPY\skeri0097\skeri0097_BadEye_021610\RawDicom
X:\data\RETINOTOPY\skeri0097\skeri0097_GoodEye_113009\RawDicom
X:\data\RETINOTOPY\skeri0097\skeri0097_LeftRight_120909\RawDicom
X:\data\RETINOTOPY\skeri0098\RawDicom
X:\data\RETINOTOPY\skeri0099\RawDicom
X:\data\RETINOTOPY\skeri0100\fslMC\RawDicom
X:\data\RETINOTOPY\skeri0101\RawDicom
X:\data\RETINOTOPY\skeri0102\RawDicom
X:\data\RETINOTOPY\skeri0103\RawDicom
X:\data\RETINOTOPY\skeri0104\RawDicom
X:\data\RETINOTOPY\skeri0108\RawDicom
X:\data\RETINOTOPY\skeri0109\RawDicom
X:\data\RETINOTOPY\skeri0112\RawDicom
X:\data\RETINOTOPY\skeri0116\RawDicom
X:\data\RETINOTOPY\skeri0122\RawDicom
X:\data\RETINOTOPY\skeri0125\RawDicom
X:\data\RETINOTOPY\skeri0127\RawDicom
X:\data\RETINOTOPY\skeri0128\RawDicom
X:\data\RETINOTOPY\skeri0129\RawDicom
X:\data\RETINOTOPY\skeri0131\RawDicom
X:\data\RETINOTOPY\skeri0133\RawDicom
X:\data\RETINOTOPY\skeri0134\RawDicom
X:\data\RETINOTOPY\skeri0136\RawDicom
X:\data\RETINOTOPY\skeri0137\RawDicom
X:\data\RETINOTOPY\skeri0138\RawDicom
X:\data\RETINOTOPY\skeri0140\RawDicom
X:\data\RETINOTOPY\skeri0144\RawDicom
X:\data\RETINOTOPY\skeri0151\RawDicom
X:\data\RETINOTOPY\tyler\tyler_hemifields_052605\RawDicom
X:\data\RETINOTOPY\vildavski\111705_vildavski_quartermap\RawDicom
X:\data\RETINOTOPY\wade\SKERIWRA050305\wade_retinoLocalizers_050305\RawDicom

%}
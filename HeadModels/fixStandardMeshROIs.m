function fixStandardMeshROIs(skeriNum)
% Corrects Mesh ROIs for color, warns of other problems

warning('Not rewriting mesh ROI-files at the moment, just checking.')	% !!!

subj = sprintf('skeri%04d',skeriNum);
roiDir = fullfile(SKERIanatDir,subj,'Standard','meshes','ROIs');
roiList = {'V1','V2D','V2V','V3D','V3V','V3A','V4','LOC','MT'};
hemi = 'LR';
fprintf('\n================ %s ================\n\n',roiDir)
for iROI = 1:numel(roiList)
	for iHemi = 1:numel(hemi)
		roiName = [roiList{iROI},'-',hemi(iHemi)];
		roiFile = fullfile(roiDir,[roiName,'.mat']);
		if exist(roiFile,'file')
			load(roiFile)
			[changedName,changedIndices,changedColor] = deal(false);
			fOppositeHemi = 0;
			fixable = true;		% safe to overwrite
			if ~strcmp(ROI.name,roiName)
				fprintf('%s has bad name = %s\n',roiFile,ROI.name)
				ROI.name = roiName;
				changedName = true;
				if ~strcmpi(ROI.name,roiName)
					fixable = false;
				end
			end
			switch hemi(iHemi)
			case 'L'
				k = ROI.meshIndices > 10242;
				if any(k)
					fprintf('%s has %d / %d indices in the right hemisphere\n',roiFile,sum(k),numel(k))
					ROI.meshIndices = ROI.meshIndices(~k);
					changedIndices = true;
					fOppositeHemi = sum(k)/numel(k);
					if fOppositeHemi > 0.1
						fixable = false;
					end
				end
			case 'R'
				k = ROI.meshIndices <= 10242;
				if any(k)
					fprintf('%s has %d / %d indices in the left hemisphere\n',roiFile,sum(k),numel(k))
					ROI.meshIndices = ROI.meshIndices(~k);
					changedIndices = true;
					fOppositeHemi = sum(k)/numel(k);
					if fOppositeHemi > 0.1
						fixable = false;
					end
				end
			end
			switch roiList{iROI}
			case 'V1'
				goodColor = 'r';
				badColor = ( ischar(ROI.color) && ~strcmp(ROI.color,goodColor) ) || ( ~ischar(ROI.color) && ~all(ROI.color==[1 0 0]) );
			case {'V2D','V2V'}
				goodColor = 'g';
				badColor = ( ischar(ROI.color) && ~strcmp(ROI.color,goodColor) ) || ( ~ischar(ROI.color) && ~all(ROI.color==[0 1 0]) );
			case {'V3D','V3V'}
				goodColor = 'b';
				badColor = ( ischar(ROI.color) && ~strcmp(ROI.color,goodColor) ) || ( ~ischar(ROI.color) && ~all(ROI.color==[0 0 1]) );
			case 'V3A'
				goodColor = 'c';
				badColor = ( ischar(ROI.color) && ~strcmp(ROI.color,goodColor) ) || ( ~ischar(ROI.color) && ~all(ROI.color==[0 1 1]) );
			case 'V4'
				goodColor = 'm';
				badColor = ( ischar(ROI.color) && ~strcmp(ROI.color,goodColor) ) || ( ~ischar(ROI.color) && ~all(ROI.color==[1 0 1]) );
			case 'LOC'
				goodColor = [1 0.5 0];
				badColor = ( ischar(ROI.color) ) || ( ~ischar(ROI.color) && ~all(ROI.color==goodColor) );
			case 'MT'
				goodColor = 'y';
				badColor = ( ischar(ROI.color) && ~strcmp(ROI.color,goodColor) ) || ( ~ischar(ROI.color) && ~all(ROI.color==[1 1 0]) );
			end
			if badColor
				if fixable
					fixStr = '* ';
				else
					fixStr = '  ';
				end
				if ischar(ROI.color)
					fprintf('%s%s has bad color = %s\n',fixStr,roiName,ROI.color)
				else
					fprintf('%s%s has bad color = [%g %g %g]\n',fixStr,roiName,ROI.color)
				end
				ROI.color = goodColor;
				changedColor = true;
			end
			if fixable && any([changedName changedIndices changedColor])
				try
% 	 				save(roiFile,'ROI')
					fprintf('Corrected %s\n\n',roiFile)
				catch
					fprintf('Couldn''t write %s\n\n',roiFile)
				end
			end
		else
			disp([roiFile,' doesn''t exist.'])
		end
	end
end

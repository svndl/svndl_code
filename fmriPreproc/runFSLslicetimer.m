function timedFile = runFSLslicetimer(inFile,options,outFile)
% USAGE: outputFiles = runFSLslicetimer(inputFiles,[options],[outputFiles])
%
% DEFAULTS:
%
% options.sliceInterleave   = 1, [odd,even]
% options.sliceUpFlag       = true
% options.revSliceOrderFlag = true
% options.replaceAll        = 0, ask
% options.verbose           = false
%
% outputFiles{i} = [inputFiles{i},'_timed']

if ischar(inFile)
	inFile = {inFile};
end
nFile = numel(inFile);

% Defaults
sliceInterleave = 1;
sliceUpFlag = true;
revSliceOrderFlag = true;
replaceAll = 0;
verbose = false;
if ~exist('options','var') || isempty(options)
	options = struct('sliceInterleave',sliceInterleave,'sliceUpFlag',sliceUpFlag,...
		'revSliceOrderFlag',revSliceOrderFlag,'replaceAll',replaceAll,'verbose',verbose);
end
for f = {'sliceInterleave','sliceUpFlag','revSliceOrderFlag','replaceAll','verbose'}
	if ~isfield(options,f{1})
		options.(f{1}) = eval(f{1});
	end
end
[replaceAllTxt,replaceAllImg] = deal(options.replaceAll);

if ~exist('outFile','var') || isempty(outFile)
	[outPath,outFile,outExt] = filepartsgz(inFile);
	outFile(:) = strcat(outPath,filesep,outFile,'_timed');
else
	if ischar(outFile)
		outFile = {outFile};
	end
	if numel(outFile) ~= nFile
		error('Different # of input & output files')
	end
	[outPath,outFile(:),outExt] = filepartsgz(outFile);
	outFile(:) = strcat(outPath,filesep,outFile);
end
outExt(cellfun(@isempty,outExt)) = {getFSLextension};



if options.revSliceOrderFlag
	sliceFileFmt = 'sliceOrderRev%d.txt';
else
	sliceFileFmt = 'sliceOrder%d.txt';
end
replaceFile = false;
nSlice = 0;
newSliceFiles = {};
alreadyAsked = false;
S = getFSLhdStruct(inFile);	%,options.verbose);		% only used for #slices


for iFile = 1:nFile

	% Determine the slice order for FSL's slicetimer
	nSlice(:) = eval(S(iFile).nz);
	if options.sliceUpFlag
		sliceOrder = (1:nSlice)';
	else
		sliceOrder = (nSlice:-1:1)';
	end
	switch options.sliceInterleave
	case 0
		sliceOrder(:) = sliceOrder(1:nSlice);
	case 1
		sliceOrder(:) = sliceOrder([1:2:nSlice,2:2:nSlice]);
	case 2
		sliceOrder(:) = sliceOrder([1:2:nSlice,2:2:nSlice]);
	end
	if options.revSliceOrderFlag
		sliceOrder(:) = sliceOrder(nSlice:-1:1);		% reverse slice order file for FSL's slicetimer
	end

	% Make the slice order file
	sliceFile = fullfile(fileparts(outFile{iFile}),sprintf(sliceFileFmt,nSlice));
	alreadyAsked(:) = any(strcmp(newSliceFiles,sliceFile));
	if alreadyAsked
		replaceFile(:) = false;
	else
		[replaceFile(:),replaceAllTxt(:)] = replaceFileQuery(sliceFile,replaceAllTxt);
		newSliceFiles = cat(1,newSliceFiles,sliceFile);		
	end
	if replaceFile
		fid = fopen(sliceFile,'w');
		if fid == -1
			error('Problem opening %s',sliceFile)
		end
		% standard line terminations are CR+LF on PC, LF on Linux, ? on Mac
		for iSlice = 1:nSlice
			fprintf(fid,'%d\r\n',sliceOrder(iSlice));
		end
		if fclose(fid) ~= 0
			error('Problem closing %s',sliceFile)
		end
	elseif ~alreadyAsked && options.verbose
		fprintf('Skipping creation of %s\n',sliceFile)
	end

	% Run slicetimer
	[replaceFile(:),replaceAllImg(:)] = replaceFileQuery([outFile{iFile},outExt{iFile}],replaceAllImg);
	if replaceFile
		% -r option doesn't seem to have any bearing on slicetimer, and -d 3 is the default.  could skip these.
		% slicetimer preserves TR
		runSystemCmd( sprintf('slicetimer -i %s -o %s --ocustom=%s -d 3',inFile{iFile},outFile{iFile},sliceFile), options.verbose )
        %jma added to fix mangled header
        fixSliceInfo(inFile{iFile},outFile{iFile} )
	elseif options.verbose
		fprintf('Skipping slicetimer %s\n',inFile{iFile})
	end

end

if nargout > 0
	timedFile = strcat(outFile,outExt);
end
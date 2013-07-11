function [mcFile,meanFile,xfmFile] = runFSLmotionCorrection(inFile,stage,options,outFile)
% USAGE: outputFiles = runFSLmotionCorrection(inputFiles,stage,[options],[outputFiles])
%
% stage = 1 for within-scan correction, 2 for between-scan correction
%
% DEFAULTS:
%
% options.iRef       = [], ask
% options.replaceAll =  0, ask
% options.verbose    = false
%
% outputFiles{i} = [inputFiles{i},'_mcw'], stage=1
%                = [inputFiles{i},'_mcb'], stage=2

switch stage
case {1,2}		% intended usage
case 0
	if nargout > 0
		[mcFile,meanFile,xfmFile] = deal({});
	end
	return
otherwise
	help(mfilename)
	error('input "stage" must be 1 or 2')
end

iRef = [];
replaceAll = 0;
verbose = false;
if ~exist('options','var') || isempty(options)
	options = struct('iRef',iRef,'replaceAll',replaceAll,'verbose',verbose);
end
for f = {'iRef','replaceAll','verbose'}
	if ~isfield(options,f{1})
		options.(f{1}) = eval(f{1});
	end
end

if ischar(inFile)
	inFile = {inFile};
end
nFile = numel(inFile);

% mcflirt -in infile -o outfile [-dof 6] [-cost normcorr] [-stages 4] [-sinc_final] [-mats] [-plots]
% save transforms or parameters?
mcflirtOpts = '-dof 6';

flirtOpts = '-dof 6 -searchrx -10 10 -searchry -10 10 -searchrz -10 10 -coarsesearch 4 -finesearch 0.5';


if ~exist('outFile','var') || isempty(outFile)
	[outPath,outBase,outExt] = filepartsgz(inFile);
	switch stage
	case 1
		outFile = strcat(outPath,filesep,outBase,'_mcw');
	case 2
		outFile = strcat(outPath,filesep,outBase,'_mcb');
	end
	inBase = outBase;
else
	if ischar(outFile)
		outFile = {outFile};
	end
	if numel(outFile) ~= nFile
		error('Different # of input & output files')
	end
	[outPath,outBase,outExt] = filepartsgz(outFile);
	outFile(:) = strcat(outPath,filesep,outBase);
	[~,inBase] = filepartsgz(inFile);
end
extFSL = getFSLextension;
outExt(cellfun(@isempty,outExt)) = {extFSL};


replaceFile = false;

if stage == 1
	
	% Within-scan correction
	for i = 1:nFile
		[replaceFile(:),options.replaceAll(:)] = replaceFileQuery([outFile{i},outExt{i}],options.replaceAll);
		if replaceFile
			runSystemCmd( sprintf('mcflirt -in %s -o %s %s',inFile{i},outFile{i},mcflirtOpts), options.verbose )            
            %jma added to fix mangled header
            fixSliceInfo( inFile{i},outFile{i} )
		elseif options.verbose
			fprintf('Skipping mcflirt %s\n',inFile{i})
		end
	end
	if nargout > 1
		[meanFile,xfmFile] = deal({});
	end

else

	if isempty(options.iRef)
		if nFile == 1
			options.iRef = 1;
		else
			options.iRef = menu('Choose reference scan:',inFile);
			if options.iRef == 0
				error('Motion correction cancelled by user')
			end
		end
	elseif ~ismember(options.iRef,1:nFile)
		error('input "iRef" must be between 1 and numel(inFile)')
	end
	
	meanFile = strcat(outPath,filesep,inBase,'_mean');
	 xfmFile = strcat(outPath,filesep,inBase,'_mcx.txt');
	
	% Calculate means
	for i = 1:nFile
		[replaceFile(:),options.replaceAll(:)] = replaceFileQuery([meanFile{i},extFSL],options.replaceAll);
		if replaceFile
			runSystemCmd( sprintf('fslmaths %s -Tmean %s',inFile{i},meanFile{i}), options.verbose )
            %jma added to fix mangled header
            fixSliceInfo( inFile{i},meanFile{i} )
		elseif options.verbose
			fprintf('Skipping Tmean %s\n',inFile{i})
		end
	end

	% Between-scan correction
	[replaceFile(:),options.replaceAll(:)] = replaceFileQuery([outFile{options.iRef},outExt{options.iRef}],options.replaceAll);
	if replaceFile
		[~,~,inExt] = filepartsgz(inFile{options.iRef});
		if isempty(inExt)
			runSystemCmd( sprintf('cp -p %s%s %s%s',inFile{options.iRef},extFSL,outFile{options.iRef},outExt{options.iRef}), options.verbose )
		else
			runSystemCmd( sprintf('cp -p %s %s%s',inFile{options.iRef},outFile{options.iRef},outExt{options.iRef}), options.verbose )
		end
	elseif options.verbose
		fprintf('Skipping copy %s\n',inFile{options.iRef})
	end
	for i = setdiff(1:nFile,options.iRef)
		[replaceFile(:),options.replaceAll(:)] = replaceFileQuery(xfmFile{i},options.replaceAll);
		if replaceFile
			runSystemCmd( sprintf('flirt %s -in %s -ref %s -omat %s',flirtOpts,meanFile{i},meanFile{options.iRef},xfmFile{i}), options.verbose )
		elseif options.verbose
			fprintf('Skipping flirt to ref %s\n',meanFile{i})
		end
		[replaceFile(:),options.replaceAll(:)] = replaceFileQuery([outFile{i},outExt{i}],options.replaceAll);
		if replaceFile
			runSystemCmd( sprintf('flirt -in %s -ref %s -out %s -applyxfm -init %s',inFile{i},outFile{options.iRef},outFile{i},xfmFile{i}), options.verbose )
            %jma added to fix mangled header
            fixSliceInfo( inFile{i},outFile{i} )
		elseif options.verbose
			fprintf('Skipping flirt to ref %s\n',inFile{i})
		end
		% check & fix TR?		Stanford nifti files have pixdim4 = 1 even though named 2sec???
		TR = eval( runSystemCmd( sprintf('fslval %s pixdim4',inFile{i}) ) );
		if eval( runSystemCmd( sprintf('fslval %s pixdim4',outFile{i}) ) ) ~= TR
			changeHeaderElement(inFile{i},'dt',num2str(TR),[],options.verbose)
		end
	end
	
	if nargout > 1
		meanFile = strcat(meanFile,extFSL);
	end
end

if nargout > 0
	mcFile = strcat(outFile,outExt);
end


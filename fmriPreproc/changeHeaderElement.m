function changeHeaderElement(inFileName,parName,valStr,outFileName,verbose)
% change values of elements in nifti headers using fslhd & fslcreatehd
%
% USAGE: changeHeaderElement(inputFileName,parameterName,valueString,[outputFileName])
% use xml-style parameter names
% if outputFileName is not specified it will overwrite the inputFile
% you can omit extensions if you choose
%
% e.g. 
% change TR to  2: changeHeaderElement('imageName','dt','2')
% change 4D to 3D: changeHeaderElement('imageName','ndim','3','newDir/newImage')

if ~exist('outFileName','var') || isempty(outFileName)
	outFileName = inFileName;
end

if ~exist('verbose','var') || isempty(verbose)
	verbose = false;
end

[pathName0,fileName0] = filepartsgz( inFileName);
[pathName1,fileName1] = filepartsgz(outFileName);

file0 = fullfile(pathName0,fileName0);
file1 = fullfile(pathName1,fileName1);

if isempty(strfind(runSystemCmd( sprintf('fslhd -x %s',file0) ),[parName,' = ']))		% strfind or regexp work
	error('%s in not a fslhd -x header element',parName)
end

fileTxt = fullfile(pathName1,'temp-hdr.txt');

runSystemCmd( sprintf('fslhd -x %s | sed "s/%s = .*/%s = \\''%s\\''/" > %s',file0,parName,parName,valStr,fileTxt), verbose )
runSystemCmd( sprintf('fslcreatehd %s %s',fileTxt,file1), verbose )
runSystemCmd( sprintf('rm %s',fileTxt), verbose )
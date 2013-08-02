function [ isGood ] = checkFslSetup(  )
%checkFslSetup Checks that matlab is setup to execute fsl commands
% This function checks for several things that need to be setup for FSL 
%to work when called from MATLAB
%
%1) Environment Variables
%2) Fsl file in fsldir/bin

isGood = true;
FSLOUTPUTTYPE = getenv('FSLOUTPUTTYPE');
expectedFSLoutput = 'NIFTI_GZ';

if ~strcmp(FSLOUTPUTTYPE,expectedFSLoutput)

    disp('Expected environment variable necessary for FSL to function is not present');
  
	fprintf('FSLOUTPUTTYPE environment variable = %s, expecting = %s\n',FSLOUTPUTTYPE,expectedFSLoutput);
    isGood = false;
end

fsldir = getenv('FSLDIR');

if isempty(fsldir) 
    disp('Cannot find environment variable $FSLDIR');
    isGood = false;
    
elseif ~isdir(fsldir)
    
    disp(sprintf('Cannot find FSLDIR: %s',fsldir));
    isGood = false;
else

%Looking for fslroi as our check for fsl commands
fslFile = fullfile(fsldir,'bin','fslroi');

if ~exist(fslFile,'file')
    fprintf('Error validating fsl, cannot find: %s\n',fslFile);
    isGood = false;
end
end


end


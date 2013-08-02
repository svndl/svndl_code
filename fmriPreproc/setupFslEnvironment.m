function [ setupSucceeded ] = setupFslEnvironment(  )
%setupFslEnvironment Attempts to automagically setup fsl

%Default is we didn't succeed
setupSucceeded = false;

if ispc
    disp('Sorry WINDOWS is not supported')
    return;
end

fsldir = getenv('FSLDIR');

if isempty(fsldir)
    
    
    
    disp('FSLDIR not set. Attempting to find fsl myself.')
    if exist('/usr/local/fsl/bin/fslroi','file')
        
        disp('Found fsl in default location: /usr/local/fsl')
        fsldir = '/usr/local/fsl';
    else
        disp('Searching ENTIRE SYSTEM for possible FSL install. ')
        [status result] = system('find / -name fslroi 2>/dev/null');
        if isempty(result)
            disp('Failed to find fsl, please install FSL')
            return
        end
        
        firstFound = textscan(result,'%s\n',1);
        fslRoiPath = firstFound{1};
        fsldir = fslRoiPath(1:end-11);
        
        if ~isdir(fsldir)
            disp('Failed to find fsl, please install FSL')
            return
        end
        fprintf('I think I found fsl at: %s\n', fsldir);
        
    end
    
    setenv('FSLDIR',fsldir);
end


path1 = getenv('PATH');
path1 = [path1 pathsep fsldir filesep 'bin'];
setenv('PATH', path1);
!echo $PATH
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
setenv( 'FSLDIR', fsldir);

fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
setupSucceeded = true;
end


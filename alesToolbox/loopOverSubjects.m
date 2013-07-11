function [outputBySubject] = loopOverSubjects(functionHandle, projectDir, varargin )
%loopOverSubjects - runs a function for all subjects in an mrc project
%
%function loopOverSubjects(functionHandle, projectDir, [optns ...] )
%
%This function loops over all subjects in a mrCurrent project and executes
%functionHandle on each subject. 
%Any extra arguments are passed into the functionHandle.
%
%functionHandle takes 1 argument: projectInfo with the fields:
%projectInfo.projectDir -> the project directory currently being analyzed
%projectInfo.subjId -> the current subject, eg skeri0001
%projectInfo.currentDir -> full path to the current subjects directory
%projectInfo.powerDivaExportDir -> full path to directory containing PD exports;
%
%
%outputBySubject -> a cell array containing possible output of @functionHandle
%                   in one cell for each subject
%
%functionHandle must only return 1 variable. But it can be a structure.
%

% $Log: loopOverSubjects.m,v $
% Revision 1.7  2010/03/31 22:28:16  SKI+ales
% *** empty log message ***
%
% Revision 1.6  2009/12/10 21:18:09  ales
% Added routines to draw anatomical figures
%
% modified routines for creating/faking Axx data from raw exports
%
% Revision 1.5  2009/11/02 19:04:13  ales
% changed some comments
%
% Revision 1.4  2009/11/02 17:53:26  ales
% Changed help slightly
%

if  ~exist('projectDir','var') || isempty(projectDir)|| ~exist(projectDir,'dir'),
    projectDir = uigetdir('.','Pick your project directory');
end

%
if projectDir == false,
    
    error('Canceled by user!')
end

subjectList = dir(projectDir);

if isempty(varargin)
    optns.null = true;
    varargin{1} = optns;
end

subjNumber = 1;

for iSubj = 3:length(subjectList),
    
    if subjectList(iSubj).isdir==false;
        continue;
    end
    
    subjId = subjectList(iSubj).name;

    if strcmp(subjId,'skeri9999')
        display('Skipping skeri9999')
        continue;
    end

    if strncmp(subjId,'.',1)
        display(['skipping folder: ' subjId])
        continue;
    end

    
    
    PDname = dir(fullfile(projectDir,subjId,'Exp_MATL_*'));

    if isempty(PDname)
        display(['For: ' subjId ' ---- Cannot find PowerDiva MATLAB export directory. Looking for Text Export'])
            
    
    PDname = dir(fullfile(projectDir,subjId,'Exp_TEXT_*'));

    if isempty(PDname)
        display(['---Warning: ' subjId ' ---- Cannot find ANY PowerDiva export directory.'])
        continue
    else
        display(['---For: ' subjId ' ---- found PowerDiva TEXT export directory.'])
    end
    
    end
    disp(['Processing subject: ' subjId ])
    
    powerDivaExportDir = fullfile(projectDir,subjId,PDname(1).name);

    projectInfo.projectDir = projectDir;
    projectInfo.subjId = subjId;
    projectInfo.currentDir = fullfile(projectDir,subjId);
    projectInfo.powerDivaExportDir = powerDivaExportDir;
    
    if ~isempty(varargin)
        if nargout(functionHandle) > 0 
            [ outputBySubject{subjNumber} ] = functionHandle(projectInfo,varargin{:});
        else
            functionHandle(projectInfo,varargin{:});
			outputBySubject{subjNumber} = [];
        end
    else
        if nargout(functionHandle) > 0 
            [ outputBySubject{subjNumber} ] = functionHandle(projectInfo);
		else
			
            functionHandle(projectInfo);
			outputBySubject{subjNumber} = [];
        end
    end
    
    subjNumber = subjNumber+1;
 
    
    
end




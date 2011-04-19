function prepareProjectForMne( projectDir )
%function prepareProjectForMne( [projectDir])


if nargin ~= 1,
    projectDir = uigetdir('.','Pick your project directory');
end

if projectDir == false,
    
    error('Canceled by user!')
end

subjectList = dir(projectDir);

allIsGood = true;

for iSubj = 3:length(subjectList),
    
    if subjectList(iSubj).isdir==false;
        continue;
    end
    
    subjId = subjectList(iSubj).name;

    if strcmp(subjId,'skeri9999')
        display('Skipping skeri9999');
        continue;
    end
    
    if strncmp(subjId,'.',1)
        display(['Skipping: ' subjId])
        continue;
    end
    
    
    %disp(['Processing subject: ' subjId ])
% 
%     ELPname = dir(fullfile(projectDir,subjId,'Polhemus','*.elp'));
%  
%     if isempty(ELPname),
%         error(['\n Cannot find Polhemus file, please add electrodes']);
%     end
% 
%     elpFile = fullfile(projectDir,subjId,'Polhemus',ELPname(1).name);
% 
%     if ~exist(elpFile,'file'),
%         error(['Cannot find Polhemus file, please add elp file']);
%     end

    
    ELPname = dir(fullfile(projectDir,subjId,'Polhemus','*Edited.elp'));
    
    if isempty(ELPname),
        
        ELPname = dir(fullfile(projectDir,subjId,'Polhemus','*.elp'));

        if isempty(ELPname),
            error(['\n Cannot find Polhemus file, please add data']);
        else 
            display(['Using file: ' ELPname(1).name]);
        end
        
    else
        display(['Found edited ELP file, using file: ' ELPname(1).name ]);
    end
        
    elpFile = fullfile(projectDir,subjId,'Polhemus',ELPname(1).name);

    

    subjNum = str2num(subjId(end-3:end));

    elpGood = isElpFileGood(elpFile);
    
    if elpGood
        display([subjId ' passes this test.']);
    elseif ~elpGood
        display(['WARNING! ---> ' subjId ' has an intersecting net <---']);
        allIsGood = false;
    end
        

end


if allIsGood,
    display('Hooray! your project is fine.');
else
    display('------------------------------');
    display('I am sorry. I detected a snarled net');
end







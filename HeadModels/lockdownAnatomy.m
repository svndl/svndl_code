function lockdownAnatomy

% to do: run as root & don't sweat ownership?

if ~isunix
	error('%s only runs on linux.',mfilename)
end

anatDir = '/raid/MRI/anatomy';

skeriIDs = dir(fullfile(anatDir,'skeri*'));
skeriIDs = skeriIDs([skeriIDs.isdir]);									% only keep directories
skeriIDs = skeriIDs(cellfun(@numel,{skeriIDs.name})==9);			% with 9 character names & numeric chars 6-9
skeriIDs = {skeriIDs(cellfun( @(s) all(abs(s(6:9))>=48) && all(abs(s(6:9))<=57),{skeriIDs.name})).name};

testOnly = true;

pCode = '444';
pString = strrep(pCode,  '0','---');
pString = strrep(pString,'1','--x');
pString = strrep(pString,'2','-w-');
pString = strrep(pString,'3','-wx');
pString = strrep(pString,'4','r--');
pString = strrep(pString,'5','r-x');
pString = strrep(pString,'6','rw-');
pString = strrep(pString,'7','rwx');


for i = 1:numel(skeriIDs)

% 	searchStr = fullfile(anatDir,skeriIDs{i},'vAnatomy.dat');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'left','left.Class');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'left','left.Gray');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'left','3DMeshes','left.MrM');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'right','right.Class');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'right','right.Class');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'right','3DMeshes','right.MrM');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','meshes');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','meshes','ROIs');
	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','meshes','defaultCortex.mat');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','meshes','ROIs_correlation.mat');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','meshes','ROIs','V1-L.mat');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','Gray');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','Gray','ROIs');
% 	searchStr = fullfile(anatDir,skeriIDs{i},'Standard','Gray','ROIs','V1-L.mat');
	
	if isdir(searchStr)
		[status,result] = system(['ls -dl ',searchStr]);
	else
		[status,result] = system(['ls -l ',searchStr]);
	end
	
	if status == 0
		c = textscan(result,'%s');		% permissions,?,owner,group,size,date,time,file
		if numel(c{1}) == 8
			checkOwnerGroup = all(strcmp(c{1}(3:4),{'SKI+spero';'SKI+bic'}));
			if strcmp(c{1}{1}(2:end),pString)
				if ~checkOwnerGroup
					fprintf('%s: locked but owner=%s, group=%s\n',skeriIDs{i},c{1}{3},c{1}{4})
				end
			elseif checkOwnerGroup
				if testOnly
	 				fprintf('%s: permissions=%s\n',skeriIDs{i},c{1}{1})
				else
					[status,result] = system(['chmod ',pCode,' ',searchStr]);
					if status ~= 0
						fprintf(result)
					end
				end
			else
				fprintf('%s: owner=%s, group=%s, permissions=%s\n',skeriIDs{i},c{1}{3},c{1}{4},c{1}{1})
			end
		else
			fprintf('%s: problem parsing ls results\n',skeriIDs{i})
		end		
	else
		fprintf(result)	% already ends in linefeed
	end
end


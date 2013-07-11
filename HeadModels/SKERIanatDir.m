function anatDir = SKERIanatDir

if ispref('mrCurrent','AnatomyFolder')
	anatDir = getpref('mrCurrent','AnatomyFolder');
elseif ispref('VISTA','defaultAnatomyPath')
	anatDir = fullfile(getpref('VISTA','defaultAnatomyPath'),'anatomy');
elseif isunix
	anatDir = '/raid/MRI/anatomy';
elseif ispc
	anatDir = 'X:\anatomy';
elseif ismac
	anatDir = '/Volumes/MRI/anatomy';
else
	error('Unable to determine anatomy directory')
end

if ~isdir(anatDir)
	error('%s in not a directory',anatDir)
end
	

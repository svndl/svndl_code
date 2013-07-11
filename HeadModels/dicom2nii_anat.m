function dicom2nii_anat(anatDir,ext)
% dicom2nii_anat(anatDir,ext)

%       opts - options
%              'all'      - all DICOM files (default)
%              'mosaic'   - the mosaic images
%              'standard' - standard DICOM files
%              'spect'    - SIEMENS Spectroscopy DICOMs (position only)
%                           This will write out a mask image volume with 1's
%                           set at the position of spectroscopy voxel(s).
%              'raw'      - convert raw FIDs (not implemented)
%       root_dir - 'flat' - SPM5 standard, do not produce file tree
%                  With all other options, files will be sorted into
%                  directories according to their sequence/protocol names
%                  'date_time' - Place files under ./<StudyDate-StudyTime>
%                  'patid'         - Place files under ./<PatID>
%                  'patid_date'    - Place files under ./<PatID-StudyDate>
%                  'patname'          - Place files under ./<PatName>
%       format - output format
%                'img' Two file (hdr+img) NIfTI format (default)
%                'nii' Single file NIfTI format
%                      All images will contain a single 3D dataset, 4D images
%                      will not be created.
opts     = 'all';
% root_dir = 'patid';
root_dir = 'flat';	% writes to wherever you are, not location of source files
format   = 'nii';

if isempty(ext)
	fileList = dir(anatDir);
	fileList = fileList(~[fileList.isdir]);	% drop . & ..
elseif strncmp(ext,'.',1)
	fileList = dir(fullfile(anatDir,['*',ext]));
else
	fileList = dir(fullfile(anatDir,['*.',ext]));
end

fileNames = {fileList(:).name};
for i = 1:numel(fileNames)
	fileNames{i} = fullfile(anatDir,fileNames{i});
end

disp('Generating headers')
hdr = spm_dicom_headers(strvcat(fileNames));
disp('Converting dicoms')
spm_dicom_convert(hdr,opts,root_dir,format);
disp('Done');

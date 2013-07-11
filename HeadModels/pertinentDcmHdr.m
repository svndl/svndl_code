function pertinentDcmHdr(startDir)
% dump subset of dicom header to command window

if nargin == 0
	startDir = pwd;
end
if isdir(startDir)
	[filename,pathname]=uigetfile({'*.dcm;*.DCM','Dicom files';'*.*','All files'},'choose dicom file',startDir);
	if isnumeric(filename)
		return
	end
	hdr = dicominfo([pathname,filename]);
else
	hdr = dicominfo(startDir);
end

fprintf('\n')
fprintf('file: %s\n',hdr.Filename)
fprintf('date: %s\n',hdr.AcquisitionDate)
fprintf('time: %s\n',hdr.AcquisitionTime)
fprintf('scanner: %s\n',hdr.InstitutionName)
if isfield(hdr.PatientName,'GivenName')
	fprintf('subject: %s %s\n',hdr.PatientName.GivenName,hdr.PatientName.FamilyName)
else
	fprintf('subject: %s\n',hdr.PatientName.FamilyName)
end
fprintf('ID: %s\n',hdr.PatientID)
fprintf('sex: %s\n',hdr.PatientSex)
fprintf('dob: %s\n',hdr.PatientBirthDate)
fprintf('age: %s\n',hdr.PatientAge)
fprintf('protocol: %s\n',hdr.ProtocolName)
if isfield(hdr,'StudyDescription')
	fprintf('study: %s\n',hdr.StudyDescription)
end
fprintf('series: %s\n',hdr.SeriesDescription)
fprintf('inplane resolution: %g x %g mm\n',hdr.PixelSpacing)
fprintf('slice thickness: %g mm\n',hdr.SliceThickness)
if isfield(hdr,'SpacingBetweenSlices')
	fprintf('slice spacing: %g mm\n',hdr.SpacingBetweenSlices)
end
fprintf('TR: %g ms\n',hdr.RepetitionTime)
fprintf('TE: %g ms\n',hdr.EchoTime)
fprintf('flip angle: %g\n',hdr.FlipAngle)
fprintf('rows: %g\n',hdr.Rows)
fprintf('columns: %g\n',hdr.Columns)
if isfield(hdr,'Private_0019_100a')
	fprintf('slices: %g\n',hdr.Private_0019_100a)
end
fprintf('\n')




% 									Filename: [1x103 char]
%                           FileModDate: '19-Oct-2007 03:04:13'
%                                 Width: 768
%                                Height: 768
%                              BitDepth: 12
%                             ColorType: 'grayscale'
%                  InstanceCreationDate: '20071018'
%                  InstanceCreationTime: '161435.234000'
%                             StudyDate: '20071018'
%                            SeriesDate: '20071018'
%                       AcquisitionDate: '20071018'
%                           ContentDate: '20071018'
%                             StudyTime: '153817.140000'
%                            SeriesTime: '161435.234000'
%                       AcquisitionTime: '161421.082500'
%                           ContentTime: '161435.234000'
%                          Manufacturer: 'SIEMENS'
%                       InstitutionName: 'Neuroscience Imaging Center'
%                      StudyDescription: 'SKERI^NorciaLab'
%                     SeriesDescription: 'ep2d_pace_dynt_moco_128'
%                           PatientName: [1x1 struct]
%                             PatientID: 'SKERI_WM_101807'
%                      PatientBirthDate: '19810126'
%                            PatientSex: 'M'
%                            PatientAge: '026Y'
%                           PatientSize: 1.7272
%                         PatientWeight: 74.8428
%                      ScanningSequence: 'EP'
%                          SequenceName: '*epfid2d1_128'
%                        SliceThickness: 2
%                        RepetitionTime: 2000
%                              EchoTime: 28
%                      NumberOfAverages: 1
%                      ImagingFrequency: 123.2457
%                         ImagedNucleus: '1H'
%                            EchoNumber: 1
%                 MagneticFieldStrength: 3
%                  SpacingBetweenSlices: 2.0000
%            NumberOfPhaseEncodingSteps: 127
%                       EchoTrainLength: 1
%                       PercentSampling: 100
%               PercentPhaseFieldOfView: 100
%                        PixelBandwidth: 1860
%                          ProtocolName: 'ep2d_pace_dynt_moco_128'
%                      TransmitCoilName: 'Body'
%                     AcquisitionMatrix: [4x1 uint16]
%         InPlanePhaseEncodingDirection: 'ROW'
%                             FlipAngle: 80
%                 VariableFlipAngleFlag: 'N'
%                                   SAR: 0.1475
%                                  dBdt: 0
%                       PatientPosition: 'HFS'
%                     AcquisitionNumber: 1
%                        InstanceNumber: 1
%                  ImagePositionPatient: [3x1 double]
%               ImageOrientationPatient: [6x1 double]
%                         SliceLocation: 21.3394
%                                  Rows: 768
%                               Columns: 768
%                          PixelSpacing: [2x1 double]
%         RequestedProcedureDescription: 'SKERI NorciaLab'
%       PerformedProcedureStepStartDate: '20071018'
%       PerformedProcedureStepStartTime: '153817.203000'
%     PerformedProcedureStepDescription: 'SKERI^NorciaLab'

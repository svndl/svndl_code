function [fullDataCell ] = loadPowerDivaRaw(directory,conditionNum);
%function [output] = loadPowerDivaRaw(directory,conditionNum);
% %{
% 	Files Raw_cXXX_tYYY.mat, where XXX is a Condition number, and YYY is a Trial
% 	number contain the following Matlab variables:
% 	'RawTrial'( nmb_of_samples, nmb_of_channels) - "16-bit signed integer" - raw data matrix
% 	'Ampl'( nmb_of_channels, 1) - "double" - amplitude scaling coefficients
% 	'Shift'( nmb_of_channels, 1) - "double" -  DC offset coefficients
% 	The number_of_channels dimension equals to the number of analog channels in
% 	the Session, not necessary the number of EEG channels, which is defined by
% 	the explicit Matlab variable (see below). 
% 	'NmbChanEEG' - number of EEG channels ( <= nmb_of_channels)
% 	'NmbEpochs' - total number of epochs in a trial 
% 	'NmbPreludeEpochs' - number of prelude/postlude epochs
% 	'IsEpochOK'( 'NmbEpochs', nmb_of_QA_channels) - "8-bit unsigned integer" - 
% 	quality assurance matrix with the values of 1 if corresponding epoch is "good",
% 	or 0 if the epoch is "bad" (contains artifact).
% 	The nmb_of_QA_channels dimention could be different from the nmb_of_channels and
% 	the 'NmbChanEEG', but nmb_of_QA_channels always >= 'NmbChanEEG', i.e. there is
% 	always the quality assurance data for all EEG channels.
% 	'inpStates'( nmb_inputs, 'NmbEpochs') - "32-bit unsigned integer" - exported only for
% 	the sequence Conditions, includes prelude states.
% 	'FreqHz'(1,1) - "double" - data acquisition rate in Hz
% 	'DataUnitStr' - "string", one of { "Volts", "microVolts", "AmpsPerSqMtr", "picoAmpsPerSqMtr" }
% 
% 	To get the value of the EEG signal in Volts one should apply the formula
% 	EEG = ( RawTrial + Shift) * Ampl
% 	using corresponding array subscripts.
% 	Notes:
% 	(1) Numbering of Conditions and Trials is 1-based, the XXX and YYY numbers are always
% 	3-digits with leading zeroes.
% 	(2) There might be gaps in the sequencies of Condition numbers and Trial numbers.
% 	(3) All Trials of a given Condition are "compatible", i.e. nmb_of_samples and 'NmbEpochs'
% 	values are the same for all the Trials of the Condition.
% 	(4) The length of a Trial ( nmb_of_samples) is always an integer multiple of 'NmbEpochs'
% 	i.e. nmb_of_samples % 'NmbEpochs' = 0. 
% 
% 	We do not use Matlab "StructArrays", because they aren't easy to deal with 
% 	in terms of individual fields access.
% 
%}

searchString = sprintf('Raw_c%.3i*',conditionNum);

fileList = dir(fullfile(directory,searchString));

if length(fileList)==0,
    disp('!!!!!!!!!!!!!!!!!!!!!')
    disp('Error opening projcect')
    error('No RAW files found')
end



for iTrial=1:length(fileList),
    
    thisFile = fullfile(directory,fileList(iTrial).name);
    
    fullDataCell{iTrial} = load(thisFile);
    
    thisRaw =   double(fullDataCell{iTrial}.RawTrial);
    thisShift = repmat(fullDataCell{iTrial}.Shift',size(thisRaw,1),1);
    thisAmpl = repmat(fullDataCell{iTrial}.Ampl',size(thisRaw,1),1);
    
    fullDataCell{iTrial}.EEG = ( thisRaw + thisShift) .* thisAmpl;
    fullDataCell{iTrial}.trialNumber = iTrial;
    
    
end



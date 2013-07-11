function [trialData stimStart trialEvent] = load_sbin_trial(filename,conditionCode,nSampsPre,nSampsPost,event)

if ~exist('event','var') || isempty(event)
    [event.code, segHdr, event.data] = read_sbin_events(filename);
end


[header] = ft_read_header(filename);

condIdx = strmatch(conditionCode,event.code);
din4Idx = strmatch('DIN7',event.code);

nEvents = length(event.code);

din4Start = find(event.data(din4Idx,:));
condStart = find(event.data(condIdx,:));

nTrials = length(condStart);


nSamples = nSampsPre+nSampsPost+1;
nChannels = header.nChans;
trialData = zeros(nTrials,nChannels,nSamples);
stimStart = zeros(nTrials,1);

for iTrial = 1:nTrials,
    
    [y, thisDin4] = min(abs(din4Start-condStart(iTrial)));
    
    
    trialStart = din4Start(thisDin4)-nSampsPre;
    trialEnd   = din4Start(thisDin4)+nSampsPost;

    stimStart(iTrial) = din4Start(thisDin4);
    trialData(iTrial,:,:) = read_sbin_data(filename, header, trialStart, trialEnd,1:nChannels);
    trialEvent(iTrial,:,:) = read_sbin_data(filename, header, trialStart, trialEnd,nChannels+1:nChannels+nEvents);
end


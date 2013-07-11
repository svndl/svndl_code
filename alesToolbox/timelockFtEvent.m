function [ outputData ] = timelockFtEvent(inputData,cfg )
%UNTITLED3 Summary of this function goes here
%   cfg.event = event structue
%   cfg.trialdef.eventtype  = 'string'
%   cfg.trialdef.eventvalue = number, string or list with numbers or strings

%   cfg.trialdef.prestim    = number, latency in seconds (optional)
%   cfg.trialdef.poststim   = number, latency in seconds (optional)%   Detailed explanation goes here



eventIdx = find(strcmp({cfg.event.value},cfg.trialdef.eventvalue));
nSamps = cfg.trialdef.prestim+cfg.trialdef.poststim+1;
nTrials = length(eventIdx);

outputData = zeros(size(inputData,1),nSamps,nTrials);

iTrial = 1;
for iEvent = eventIdx;
    
    begsample = cfg.event(iEvent).sample-cfg.trialdef.prestim;
    endsample = cfg.event(iEvent).sample+cfg.trialdef.poststim;
    
    if begsample <1 || endsample > size(inputData,2);
        disp(['Skipping invlaid trial: ' num2str(iEvent) ' due to requested trial window outside of data range']);
        continue;
    end
    
    outputData(:,:,iTrial) = inputData(:,begsample:endsample);
    
    iTrial = iTrial+1;
    
    

end


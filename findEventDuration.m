%function newEvent = findDinDuration(event)
%This function finds runs of consectutive events and codes their durations
function newEvent = findEventDuration(event)


nEvents = length(event)

newEvent = event;

eventNames = unique({event.value});


curEventIdx = 0;

for iEventType=1:length(eventNames),
    
    
    thisEventName = eventNames{iEventType};
    
     eventIdx = find(strcmp({event.value},thisEventName));

     
    nThisEvent = length(eventIdx);
     
    
    
     curEventIdx = curEventIdx+1;
     newEvent(curEventIdx) = event(eventIdx(1));
     
     for iEvent = eventIdx(2:end),
     
         
         
         %Sample difference between two events.
         sampDiff = event(iEvent).sample-event(iEvent-1).sample;
         
         if sampDiff >1;
             curEventIdx = curEventIdx+1;
             newEvent(curEventIdx) = event(iEvent);
             
         else
             newEvent(curEventIdx).duration = newEvent(curEventIdx).duration+1;
         end
         
         
         
         
         
     end
     
     
end


%Truncate unused events
newEvent = newEvent(1:curEventIdx);

%Sort by event sample.
[null I] = sort([newEvent.sample]);
newEvent = newEvent(I);

end

function [eye,input] = importEyeLink(filepath,varargin);
% [eye,input] = importEyeLink(filepath,[options]);
%
% Parse ASCII eyelink data file for eye position information. Provide
% FILEPATH with complete path to ascii file (.asc extention). You must
% first convert the original EDF file to ASC using EDC2ASC on the EyeLink
% host computer.
%
% Accepts OPTIONS as name value pairs. In particular:
% bitForceExtract (binary) to force extraction of
% EyeLink data from ASCII file even if previously save extraction exists.
%
% syncOnCode (integer) 8-bit integer representation of sync pulse. E.g., all 8 lines on = 11111111 
    % in binary and 255 as an integer.
% syncOffCode (integer) When line 1 goes off, 11111101, the corresponding
    % "Off" code is 253
% syncDurExpected (integer)  expected length of sync pulse in ms
%
% bitFigSyncDur (binary) to plot histogram of sync pulse durations when
% some are not as expected
%
% bitFigEyePos (binary) to plot eye position and pupil size vs time for
% entire file
% 
% Returns EYE structure with eye position information in horizontal (.x)
% and vertical (.y) dimensions, as well as timestamp (.t) and pupil size
% (.p). 
%
% Returns INPUT structure that contains time of specific digital input
% events, including a synchronization pulse start (.syncTime) and stop
% times (.syncOffTime).  INPUT.syncOffTime may have more entries than
% .syncTime.  INPUT.syncDur contains durations of valid sync pulses which
% can be used to recreate valid syncOff times if necessary.
%
% Additional events, such as on-line saccades, are not yet returned.
%
% Automatically saves output to file with suffix "_parsed.mat"
%
% Daniel Kimmel, August 19, 2008
%

%% optional input parameter defaults
 
bitForceExtract = 0;

% filepath = 'C:\DOCS\MATLAB\DATA\Cody_EyeTracker\C_2008_08_13\C080813a.asc';
% filepath = 'C:\DOCS\Newsome\Eye Tracker\sample data\test01.asc';

nCol = 1; % max number of columns to return. Could be equivlent to longest 
    % number of parameters (e.g., for ESACC event), but for now just take
    % first column.
    
syncOnCode = 253; % 8-bit integer representation of sync pulse. E.g., all 8 lines on = 11111111 
    % in binary and 255 as an integer.
syncOffCode = 255; % When line 1 goes off, 11111101, the corresponding "Off" code is 253
syncDurExpected = 50; % expected length of sync pulse in ms

bitFigSyncDur = 1; % display histogram of sync pulse durations if some are not as expected
    
bitFigEyePos = 1; % plot eye position and pupil size vs time for entire file.

%% collect optional input vars:
warnopts(assignopts(who, varargin));

%% store additional vars:
input.syncOnCode = syncOnCode; 
input.syncOffCode = syncOffCode; 
input.syncDurExpected = syncDurExpected; 


%% load saved values, if present
[dirpath, filename] = fileparts(filepath);
savePathStem = fullfile(dirpath,[filename,'*.mat']);
foo = dir(savePathStem);
if ~isempty(foo)
    savePath = fullfile(dirpath,foo.name);
else
    savePath = [];
end
clear foo

if bitForceExtract == 0 & ~isempty(savePath)
    load(savePath);
    disp(['LOADING SAVED EYELINK DATA FROM ',savePath]);
    return
end
    

%% textscan on first column only

% open file
fid = fopen(filepath);

% collect data
clear c1
[c1] = textscan(fid,'%s %*[^\n]');
c1 = c1{1};

% number of lines:
nLine = length(c1);

% close file
fclose(fid);

%% find rows of interest

% messages 
bitMsg = strcmp(c1,'MSG');

% digital inputs
bitInput = strcmp(c1,'INPUT');

% start times
bitStart = strcmp(c1,'START');
bitStop = strcmp(c1,'END');

% eye position
% loop through all rows finding those whose first col is numeric
% without actually doing conversion:
foo = isstrprop(c1, 'digit');
bitEyePos = NaN(size(foo));
for i = 1:length(foo)
    bitEyePos(i,1) = foo{i}(1);
end
bitEyePos = logical(bitEyePos);
clear foo;

clear c1;

%% scan text file line by line

% open file
fid = fopen(filepath);

% initialize vars:
input.t = NaN(sum(bitInput),1);
input.code = NaN(sum(bitInput),1);
input.startTime = NaN(sum(bitStart),1);
input.stopTime = NaN(sum(bitStop),1);
input.expoName = [];

eye.t = NaN(sum(bitEyePos),1);
eye.x = NaN(sum(bitEyePos),1);
eye.y = NaN(sum(bitEyePos),1);
eye.p = NaN(sum(bitEyePos),1);

lineN = 1;
inputN = 0;
eyePosN = 0;
startN = 0;
stopN = 0;

% must while loop (instead of for) because we need to control lineN, since
% textscan does not count empty lines as line numbers, but fgetl does.
while 1
    
%     % read in first column:
%     [c1,pos] = textscan(fid,'%s %*[^\n]',1);
    
    % get line
    tline = fgetl(fid);
    
    % break if end-of-file
    if tline == -1
        break
    end

    % blank line, do not continue and do not increment lineN
    if isempty(tline)
        continue
    end
    
    % do different things depending on content of first column
    if bitInput(lineN) == 1
        % EVENTS
        inputN = inputN + 1;
        [c2,pos] = textscan(tline,'%*s %f %f %*[^\n]',1,'MultipleDelimsAsOne',1);
        
        % store:
        input.t(inputN) = c2{1};
        input.code(inputN) = c2{2};
        
    elseif bitEyePos(lineN) == 1
        % EYE POSITION

        eyePosN = eyePosN + 1;
        
        [c2,pos] = textscan(tline,'%f %f %f %f %*[^\n]',1, ...
            'MultipleDelimsAsOne',1,'treatAsEmpty', {'.','...'});

        % store
        eye.t(eyePosN) = c2{1};
        eye.x(eyePosN) = c2{2};
        eye.y(eyePosN) = c2{3};
        eye.p(eyePosN) = c2{4};
        
    elseif bitStart(lineN) == 1
        % START RECORDING TIME
        startN = startN + 1;
        [c2,pos] = textscan(tline,'%*s %f %*[^\n]',1,'MultipleDelimsAsOne',1);

        % store
        input.startTime(startN) = c2{1};

    elseif bitStop(lineN) == 1
        % STOP RECORDING TIME
        stopN = stopN + 1;
        [c2,pos] = textscan(tline,'%*s %f %*[^\n]',1,'MultipleDelimsAsOne',1);

        % store
        input.stopTime(stopN) = c2{1};
        
    elseif bitMsg(lineN) == 1
        % MESSAGES ABOUT CORRESPONDING EXPO FILE
        [c2,pos] = textscan(tline,'%*s %*f %s %*[^\n]',1,'MultipleDelimsAsOne',1);
       
        % store if matches [text]#[number] format:
        if regexpi(c2{1}{1},'^[a-z]*#\d\d$') == 1
            if isempty(input.expoName)
                input.expoName = c2{1}{1};
            else
                error(['MULTIPLE EXPO NAMES STORED IN EYELINK EDF ',filepath]);
            end
        end
    end

% increment line number (only for non-empty lines, i.e., also counted
    % as line by textscan()).
    lineN = lineN+1;
    
end

% close file
fclose(fid);

%% check that there are an equal number of start and end times:
if length(input.startTime) ~= length(input.stopTime)
    error(['Unequal number of recording start (',num2str(length(input.startTime)),') and stop (',num2str(length(input.stopTime)),') events']);
end

if any(input.stopTime - input.startTime < 0)
    error('Some recording stop times occur before their corresponding start times');
end


%% process events data:

% find sync pulse times:
input.syncTime = input.t(input.code == input.syncOnCode);
input.syncOffTime = input.t(input.code == input.syncOffCode);

% eliminate events that are not within a recording period:
for i = 1:length(input.startTime)
    if i == 1
        input.syncTime(input.syncTime < input.startTime(i)) = [];
        input.syncOffTime(input.syncOffTime < input.startTime(i)) = [];
    else
        input.syncTime(input.syncTime < input.startTime(i) & ...
            input.syncTime > input.stopTime(i-1)) = [];
        input.syncOffTime(input.syncOffTime < input.startTime(i) & ...
            input.syncOffTime > input.stopTime(i-1)) = [];
    end
    
    if i == length(input.startTime)
        input.syncTime(input.syncTime > input.stopTime(i)) = [];
        input.syncOffTime(input.syncOffTime > input.stopTime(i)) = [];
    end
end

% eliminate sync end times that are before the first start time or are
% repeated after the last start-end pair:
foo = input.syncOffTime(input.syncOffTime > input.syncTime(1));
goo = find(foo >= input.syncTime(end));
% only take first end time value that is greater than the last start time
% value
if length(goo) > 1
    foo(goo(2:end)) = [];
end
input.syncOffTime = foo;
clear foo goo

% find sync pulse durations
input.syncDur = input.syncOffTime - input.syncTime;

% check durations:
if any(input.syncDur ~= input.syncDurExpected)
    warning(['Not all sync pulses equal to expected duration (',num2str(input.syncDurExpected),'ms)']);
    if bitFigSyncDur == 1
        figure;
        set(gcf,'Name','Histogram of sync pulse duration');
        hist(input.syncDur);
        title('Histogram of sync pulse duration (ms)');
    end
end


%% save vars

if ~isempty(input.expoName)
    str = ['_',input.expoName];
else
    str = [];
end
savePath = fullfile(dirpath,[filename,str,'.mat']);
clear str
save(savePath,'eye','input');
disp(['SAVED EYELINK DATA TO ',savePath]);


%% plot x, y, and pupil

if bitFigEyePos == 1
    figure;
    strTitle = ['Eye position and pupil vs time - ',filename];
    set(gcf,'Name',strTitle);
    [ax,h1,h2] = plotyy(eye.t,eye.x,eye.t,eye.p);
    axes(ax(1));
    hold on; 
    title(strTitle)
    ylabel('Eye Position');
    h3 = plot(eye.t,eye.y,'r'); 
    yLim = get(gca,'YLim');
    h = line([input.syncTime, input.syncTime],yLim);
    set(h,'Color','c');
    axes(ax(2));
    legend([h1,h3,h2],{'x','y','pupil'});
    ylabel('Pupil Size');
    xlabel('absolute time (ms)');
end

% %% RETURN
% return
% 
% %% textscan
% % open file
% fid = fopen(filepath);
% 
% % determine maximum number of columns:
% % c = textscan(fid,'');
% % nCol = length(c);
% % clear c
% 
% % build format string
% fmt = '';
% for i = 1:nCol
%     fmt = [fmt,'%s'];
% end
% % go to end of line:
% fmt = [fmt,'%*[^\n]'];
% 
% % collect data
% clear c1
% c1 = textscan(fid,fmt);
% c1 = c1{1};
% 
% % close file
% fclose(fid);
% 
% %% collect whole lines
% 
% % open file
% fid = fopen(filepath);
% 
% % collect data
% clear l
% l = textscan(fid,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
% 
% % close file
% fclose(fid);
% 
% %% get "input" data
% bitInput = strcmp(c1,'INPUT');
% inputLine = l{1}(bitInput);
% 
% %goo = cell2mat(foo);
% 
% clear input
% % parse input lines:
% for i = 1:2
%     [token,inputLine] = strtok(inputLine);
%     if i==2
%         input.t = str2double(token);
%         input.code = str2double(inputLine);
%     end
% end
% 
% % find sync pulse times:
% input.syncTime = input.t(input.code == syncOnCode);
% input.syncOffTime = input.t(input.code == syncOffCode);
% 
% % find sync pulse durations
% foo = input.syncOffTime(input.syncOffTime > input.syncTime(1));
% goo = find(foo > input.syncTime(end));
% % only take first end time value that is greater than the last start time
% % value
% if length(goo) > 1
%     foo(goo(2:end)) = [];
% end
% input.syncDur = foo - input.syncTime;
% clear foo goo
% 
% % check durations:
% if any(input.syncDur ~= syncDur)
%     warning(['Not all sync pulses equal to expected duration (',num2str(syncDur),'ms)']);
%     if bitFigSyncDur == 1
%         figure;
%         set(gcf,'Name','Histogram of sync pulse duration');
%         hist(input.syncDur);
%         title('Histogram of sync pulse duration (ms)');
%     end
% end
%     
% %% get eye position data
% 
% % % find eye pos rows
% % bitEyePos = ~isnan(str2double(c1));
% 
% % alt: loop through all rows finding those whose first col is numeric
% % without actually doing conversion:
% foo = isstrprop(c1, 'digit');
% bitEyePos = NaN(size(foo));
% for i = 1:length(foo)
%     bitEyePos(i,1) = foo{i}(1);
% end
% bitEyePos = logical(bitEyePos);
% 
% % for i = 1:length(foo)
% %     bitEyePos(i,1) = all(foo{i});
% % end
% 
% % for i = 1:length(c1)
% %     bitEyePos(i,1) = all(isstrprop(c1{i}, 'digit'));
% % end
% 
% % convert eyepos lines to text
% eyePosLine = l{1}(bitEyePos);
% 
% % eyePosLineMat = cell2mat(eyePosLine);
% % e = textscan(eyePosLineMat,'%f %f %f %f %*[^\n]','MultipleDelimsAsOne',1, ...
% %     'treatAsEmpty', {'.','...'});
% 
% % parse eyepos lines:
% for i = 1:3
%     [token,eyePosLine] = strtok(eyePosLine);
%     switch i
%         case 1
%             eye.t = str2double(token);
%         case 2
%             eye.x = str2double(token);
%         case 3
%             eye.y = str2double(token);
%             eye.p = str2double(eyePosLine);
%     end
% end
% 
% %% clear
% clear c1 l
% 
% %% scan text file line by line, checking first column first.
% % open file
% fid = fopen(filepath);
% 
% posLast = 0; % original position of file.
% 
% % initialize vars:
% clear input
% input.t = [];
% input.code = [];
% clear eye
% eye.t =[];
% eye.x = [];
% eye.y = [];
% eye.p = [];
% 
% lineN = 0;
% 
% while 1
%     lineN = lineN+1;
%     
%     % read in first column:
%     [c1,pos] = textscan(fid,'%s %*[^\n]',1);
%     
%     % break if end-of-file
%     if isempty(c1{1})
%         break
%     end
%     
%     % do different things depending on content of first column
%     if strcmp(c1{1},'INPUT')
%         % EVENTS
%         % back up to beginning of line
%         fseek(fid,posLast-pos,'cof');
%         [c2,pos] = textscan(fid,'%*s %f %f %*[^\n]',1,'MultipleDelimsAsOne',1);
%         
%         % store:
%         input.t(end+1,1) = c2{1};
%         input.code(end+1,1) = c2{2};
%     elseif ~isnan(str2double(c1{1}))
%         % EYE POSITION
%         % back up to beginning of line
%         fseek(fid,posLast-pos,'cof');
%         [c2,pos] = textscan(fid,'%f %f %f %f %*[^\n]',1, ...
%             'MultipleDelimsAsOne',1,'treatAsEmpty', {'.','...'});
% 
%         % store
%         eye.t(end+1,1) = c2{1};
%         eye.x(end+1,1) = c2{2};
%         eye.y(end+1,1) = c2{3};
%         eye.p(end+1,1) = c2{4};
%         
%     end
%     
%     posLast = pos;
% end
% 
% % close file
% fclose(fid);

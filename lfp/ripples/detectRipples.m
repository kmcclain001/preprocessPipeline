function detectRipples(varargin)

methodTest = @(x) sum(strcmp(x,{'singleChan','template'}))>0;

p = inputParser;

addParameter(p,'basepath',cd,@isstr)
addParameter(p,'shanksToDetect',[],@isnumeric)
addParameter(p,'thresholdPrctile',97.5,@isnumeric)
addParameter(p,'rippleBand',[110 250],@isnumeric)
%addParameter(p,'minRipDuration',0.01,@isnumeric)
addParameter(p,'saveEvents',true,@islogical)
addParameter(p,'detectionMethod','singleChan',methodTest);

parse(p,varargin{:})
basepath = p.Results.basepath;
shanksToDetect = p.Results.shanksToDetect;
thresholdPrctile = p.Results.thresholdPrctile;
rippleBand = p.Results.rippleBand;
%minRipDuration = p.Results.minRipDuration;
saveEvents = p.Results.saveEvents;
detectionMethod = p.Results.detectionMethod;

% Get good channels, metadata
chInfo = hackInfo('basepath',basepath);
channels = chInfo.one.channels;
badChans = chInfo.one.badChannels;
sr = chInfo.lfpSR;
nShank = chInfo.nShank;

if isempty(shanksToDetect)
    shanksToDetect = 1:nShank;
end

% Group channels for ripples to be detected on separately
% (combine into one group if detecting across all channels together)
chGroups = chInfo.one.AnatGrps;
nGroups = length(chGroups);
for i = 1:nGroups
    chGroups{i} = chGroups{i}(~ismember(chGroups{i},badChans));
end

% Choose shanks to detect on
chGroups = chGroups(shanksToDetect);
nGroups = length(shanksToDetect);

% Load Data
fMerge = checkFile('basepath',basepath,'fileType','.MergePoints.events.mat');
load([fMerge.folder filesep fMerge.name]);
lfp = bz_GetLFP(channels,'basepath',basepath,'interval',MergePoints.timestamps(end,:));
lfpData = double(lfp.data);
timestamps = lfp.timestamps;
rippleCh = findRippleChan('basepath',basepath,'lfp',lfp,'channelGroups',chGroups);

% lfp = bz_GetLFP(channels,'basepath',basepath,'interval',MergePoints.timestamps);
% lfpData = double(vertcat(lfp(3).data));
% timestamps = vertcat(lfp(3).timestamps);
% 
% % Identify best channel on each shank
% rippleCh = findRippleChan('basepath',basepath,'lfp',lfp(end),'channelGroups',chGroups);

clear ripples
if saveEvents
    eventsFileName = [basepath filesep chInfo.recordingName '.rip.evt'];
    %eventsFileName = [basepath filesep 'rip.evt'];
    fid = fopen(eventsFileName,'w');
end
for grIdx = 1:nGroups
    
    bestChan = rippleCh.maxRippleChanPerGroup(grIdx);
    bestInd = find(chGroups{grIdx}==bestChan);
    
    switch detectionMethod
        case 'template'
            [r,template] = rippleTemplateMatch(lfpData(:,chGroups{grIdx}),bestInd,'rippleBand',rippleBand,'similarity','corr');
            threshold = prctile(r,thresholdPrctile);
            
            r_thresh = r>threshold;
            tmpInts = findIntervals(r_thresh);%,'minLength',minRipDuration*sr);
            
            r_power = rippleFromOneChan(lfpData(:,bestChan),'rippleBand',rippleBand);
            meanPowInt = zeros(size(tmpInts,1),1);
            for i = 1:size(tmpInts,1)
                meanPowInt(i) = mean(r_power(tmpInts(i,1):tmpInts(i,2)));
            end
            
            powThresh = prctile(r_power,65);
            lowPowInts = tmpInts(meanPowInt<powThresh,:);
            for i = 1:length(lowPowInts)
                r_thresh(lowPowInts(i,1):lowPowInts(i,2))=false;
            end
    case 'singleChan'
            r = rippleFromOneChan(lfpData(:,bestChan),'rippleBand',rippleBand);
            threshold = prctile(r,thresholdPrctile);
            r_thresh = r>threshold;
    end
    
    r_thresh = removeHoles(r_thresh,.005*sr,.01*sr);
    rippleInts = findIntervals(r_thresh);
    
    ripples.shank(grIdx).intervals = rippleInts;
    ripples.shank(grIdx).timestamps = timestamps(rippleInts);
    
    if saveEvents
        for i = 1:size(rippleInts,1)
            fprintf(fid,'%f\t%s\n',timestamps(rippleInts(i,1))*1000,['Ripple start ' num2str(shanksToDetect(grIdx))]);
            fprintf(fid,'%f\t%s\n',timestamps(rippleInts(i,2))*1000,['Ripple end ' num2str(shanksToDetect(grIdx))]);
        end
    end
end

save([basepath filesep chInfo.recordingName '.ripples.mat'],'ripples')

if saveEvents
    fclose(fid)
end

end
    
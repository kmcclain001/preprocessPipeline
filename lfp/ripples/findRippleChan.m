function rippleCh = findRippleChan(varargin)
% find best ripple channel on each shank
% inputs:
%   -basepath
%   -lfp = structure from bz_GetLFP isolated to immobility period(s)
%           can also put in matrix, will assume channels go from 1 to n
%           columns and they are all part of same channel group
%   -channelGroups = subsets of channels associated with regions to detect
%   ripple, e.g. if ripples wanted on each shank individually, each group
%   should contain channels on each shank
% return:
%   -channels for each shank
%   -ripple goodness score
%
% might be good to be able to specify interval to make less long 
checkLfp = @(x) (isstruct(x)||ismatrix(x));

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'lfp',[],checkLfp);
addParameter(p,'channelGroups',[],@iscell);

parse(p,varargin{:});
basepath = p.Results.basepath;
lfp = p.Results.lfp;
channelGroups = p.Results.channelGroups;

chInfo = hackInfo('basepath',basepath);
sr = chInfo.lfpSR;

% collect lfp
if isempty(lfp)
    fMerge = checkFile('basepath',basepath,'fileType','.MergePoints.events.mat');
    load([fMerge.folder filesep fMerge.name]);
    
    % choose last chunk of data (could make smarter..)
    immobInts = MergePoints.timestamps(end,:);
    channels = setdiff(chInfo.one.channels,chInfo.one.badChannels);
    lfp = bz_GetLFP(channels,'basepath',basepath,'interval',immobInts);

    lfpData = vertcat(lfp(:).data);

elseif isstruct(lfp)
    lfpData = vertcat(lfp(:).data);
    channels = lfp.channels;

else
    lfpData = lfp;
    channels = 1:size(lfpData,2);
    channelGroups = {channels};
    
end

% collect channel groups
if isempty(channelGroups)
    channelGroups = chInfo.one.AnatGrps;
end
nGroups = length(channelGroups);

% compute power of each channel in magic frequency bands
L = size(lfpData,1);
freq = sr*(0:(L-1))/L;

lowInds = freq>4&freq<8;
midInds = freq>65&freq<80;
highInds = freq>120&freq<250;

powerBands = nan(chInfo.nChannel,3);
for chIdx = 1:length(channels)
    tmpCh = channels(chIdx);
    f = fft(lfpData(:,chIdx));
    powerBands(tmpCh,1) = mean(abs(f(lowInds)));
    powerBands(tmpCh,2) = mean(abs(f(midInds)));
    powerBands(tmpCh,3) = mean(abs(f(highInds)));
end

% find ratio of power in magic bands
ratio = powerBands(:,3)./prod(powerBands(:,1:2),2);
zratio = nanzscore(ratio);

maxRippleChanPerGroup = zeros(1,nGroups);
rippleScorePerGroup = zeros(1,nGroups);

% identify channel with max score on each channel group
for groupIdx = 1:nGroups
    
    rippleScores = zratio(channelGroups{groupIdx});
    [maxScore, maxInd] = max(rippleScores);
    
    maxRippleChanPerGroup(groupIdx) = channelGroups{groupIdx}(maxInd);
    rippleScorePerGroup(groupIdx) = maxScore;
    
end

rippleCh.maxRippleChanPerGroup = maxRippleChanPerGroup;
rippleCh.rippleScorePerGroup = rippleScorePerGroup;

end
function thetaCh = findThetaChan(varargin)
% find channel on each shank with max theta power, normalized by broadband
% power
% return:
%   -channels for each shank
%   -mean theta power/mean broad power for max chan (max theta power per
%   shank)

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'intervals',[],@isfloat);

parse(p,varargin{:});
basepath = p.Results.basepath;
intervals = p.Results.intervals;

%get behavior, ephys details
if isempty(intervals)
    fBehav = checkFile('basepath',basepath,'fileType','.behavior.mat');
    load([fBehav.folder filesep fBehav.name]);
    intervals = behavior.events.trialIntervals;
end

chInfo = hackInfo('basepath',basepath);
sr = chInfo.lfpSR;
channels = setdiff(chInfo.one.channels,chInfo.one.badChannels);

%Get lfp
lfp = bz_GetLFP(channels,'basepath',basepath,'interval',intervals);
lfpData = double(vertcat(lfp(:).data));

%get rid 60Hz
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',sr);

%compute theta power across intervals for each channel
passband = [7 12];
[b,a] = butter(4,[passband(1)/(sr/2) passband(2)/(sr/2)],'bandpass');
broadPower = zeros(length(channels),1);
thetaPower = zeros(length(channels),1);
powerProf = nan(round(chInfo.nChannel/chInfo.nShank),chInfo.nShank);
for chIdx = 1:length(channels)
    tmpCh = channels(chIdx);
    lfpCh = filtfilt(d,lfpData(:,chIdx));
    broadPower(chIdx) = rms(lfpCh);
    thetaSig = FilterM(b,a,lfpCh);
    thetaPower(chIdx) = rms(thetaSig);
    
    tmpSh = chInfo.shankID(tmpCh);
    tmpDep = find(chInfo.one.AnatGrps{tmpSh}==tmpCh);
    powerProf(tmpDep,tmpSh) = thetaPower(chIdx)/broadPower(chIdx);
end

%pick channels with greatest power
[maxThetaPowerPerShank, maxInd] = max(powerProf);

maxThetaChanPerShank = zeros(1, chInfo.nShank);
for i =1:chInfo.nShank
    maxThetaChanPerShank(i) = chInfo.one.AnatGrps{i}(maxInd(i));
end

thetaCh.maxPowerPerShank = maxThetaPowerPerShank;
thetaCh.maxChanPerShank = maxThetaChanPerShank;


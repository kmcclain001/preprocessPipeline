%% Make data file with theta phase during each trial at each shank, structured like:
% thetaInfo - trials{:}
%   * timestamps (nx1)
%   * data (nxnShank) = theta phase for each shank identified by peak to peak
%   * peaks {(nPeaksx1)xnShank} = indices with peaks in theta lfp

function create_thetaInfo_object(varargin)

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);

parse(p,varargin{:});
basepath = p.Results.basepath;

fBehav = checkFile('basepath',basepath,'fileType','.behavior.mat');
load([fBehav.folder filesep fBehav.name]);
intervals = behavior.events.trialIntervals;

session = bz_getSession('basepath',basepath);

%get channel number(s)
chInfo = hackInfo('basepath',basepath);
thetaCh = findThetaChan('basepath',basepath);
[~,maxCh] = max(thetaCh.maxPowerPerShank);
chan = thetaCh.maxChanPerShank(maxCh);

clear thetaInfo
thetaInfo.nShank = chInfo.nShank;
thetaInfo.bestChanPerShank = thetaCh.maxChanPerShank;
thetaInfo.starChan = chan;

%make filter
passband = [4 15];
lfp_rate = chInfo.lfpSR;
[b,a] = butter(4,[passband(1)/(lfp_rate/2) passband(2)/(lfp_rate/2)],'bandpass');

for t = 1:size(intervals,1)
    
    interval = intervals(t,:);
    lfp = bz_GetLFP(thetaCh.maxChanPerShank,'basepath',basepath,'interval',interval);
    
    data = zeros(length(lfp.timestamps),chInfo.nShank);
    peakInds = cell(1,chInfo.nShank);
    for i = 1:chInfo.nShank
        theta_filt = FilterM(b,a,double(lfp.data(:,i)));
    
        [phase_peak,peak_locs] = phase_from_peaks(theta_filt);
        peakInds{i} = peak_locs;
        data(:,i) = phase_peak;
    end
    
    thetaInfo.trial{t}.timestamps = lfp.timestamps;
    thetaInfo.trial{t}.data = data;
    thetaInfo.trial{t}.peaks = peakInds;
    
end

save([basepath filesep session.general.name '.thetaInfo.mat'],'thetaInfo')


end
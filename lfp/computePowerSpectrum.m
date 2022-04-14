function powerSpectrum = computePowerSpectrum(basepath)

chInfo = hackInfo('basepath',basepath);
channels = chInfo.one.channels;
badChans = chInfo.one.badChannels;
channels = setdiff(channels,badChans);

sr = chInfo.lfpSR;

% compute sleep spectra
fMerge = checkFile('basepath',basepath,'fileType','.MergePoints.events.mat');
load([fMerge.folder filesep fMerge.name]);
lfp = bz_GetLFP(channels,'basepath',basepath,'interval',MergePoints.timestamps(end,:));
lfpData = double(lfp.data);

[tmpSpectra,f] = pspectrum(lfpData,sr,'FrequencyLimits',[0 300],'FrequencyResolution',.1);

spectrum = zeros(size(tmpSpectra,1),chInfo.nChannel);
spectrum(:,channels) = tmpSpectra;

powerSpectrum.sleep = spectrum;
powerSpectrum.freq = f;

% compute running spectra
fBehav = checkFile('basepath',basepath,'fileType','.behavior.mat');
load([fBehav.folder filesep fBehav.name]);
intervals = behavior.events.trialIntervals;

lfp = bz_GetLFP(channels,'basepath',basepath,'interval',intervals);

lfpData = double(vertcat(lfp(:).data));
tmpSpectra = pspectrum(lfpData,sr,'FrequencyLimits',[0 300],'FrequencyResolution',.1);

spectrum = zeros(length(f),chInfo.nChannel);
spectrum(:,channels) = tmpSpectra;

powerSpectrum.running = spectrum;

save([basepath filesep chInfo.recordingName '.powerSpec.mat'],'powerSpectrum')
end


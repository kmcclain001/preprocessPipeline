function NoiseRemoval(varargin)
%must have already computed lfp

methodTest = @(x) sum(strcmp(x,{'differential','filter'}))>0;

p = inputParser;
addParameter(p,'basepath',cd,@isstr)
addParameter(p,'saveEvents',true,@islogical)
addParameter(p,'detectionMethod','differential',methodTest);
addParameter(p,'upSampleRatio',16,@isnumeric)
addParameter(p,'makeFigure',true,@islogical)

parse(p,varargin{:})
basepath = p.Results.basepath;
saveEvents = p.Results.saveEvents;
detectionMethod = p.Results.detectionMethod;
upSampleRatio = p.Results.upSampleRatio;
makeFigure = p.Results.makeFigure;

chInfo = hackInfo('basepath',basepath);
channels = setdiff(chInfo.one.channels,chInfo.one.badChannels);
sf = chInfo.lfpSR;
dat_path = [basepath,filesep, chInfo.recordingName, '.dat'];
lfp = bz_GetLFP(channels,'basepath',basepath);
timestamps = lfp.timestamps;

% Identify Noise intervals
mean_lfp_raw = mean(lfp.data,2);

switch detectionMethod
    case 'differential'
        [bb,aa] = butter(4,[59.5, 60.5]/sf*2, 'stop');
        mean_lfp = FilterM(bb,aa,mean_lfp_raw);
        [bb,aa] = butter(4,[59.5, 60.5]/sf*2, 'stop');
        mean_lfp = FilterM(bb,aa,mean_lfp_raw);
        x = [0; abs(diff(mean_lfp))];
        x2 = [0;0;abs(diff(mean_lfp,2))];
        yz = zscore(x).*zscore(x2);
        
        yz = zscore(conv(yz,gausswin(21,1.5),'same'));
        figure();plot(yz);
        thresh = .75;
        above_thresh = yz>thresh;
        above_thresh = conv(above_thresh,ones(5,1),'same')>0;
        above_thresh = removeHoles(above_thresh,20/1000*sf,3/1000*sf);
        
    case 'filter'
        error('This version of noise removal has some bugs to work out-- probably dont use yet')
        %this kind of doesn't work because filter shifts signal in time,
        %could fix with grpdelay function (see NoiseRemoval_inspect.m)
        [bb,aa] = butter(4,[62, 120]/sf*2, 'bandpass');
        hi_lfp = FilterM(bb,aa,mean_lfp_raw);
        hi_pow = abs(hilbert((hi_lfp)));
        %kern = gausswin(round(.05*sf));
        %hi_pow_smoo = conv(hi_pow,kern,'same');
        %thresh = mean(hi_pow_smo) + 6 * std(hi_pow_smo);
        %above_thresh = hi_pow_smoo>thresh;
        %thresh = prctile(hi_pow,99);
        yz = zscore(hi_pow);
        thresh = 9;
        above_thresh = yz>thresh;

end
clear lfp;

noiseIntsSlo = findIntervals(above_thresh);

if saveEvents
    eventsFileName = [basepath filesep chInfo.recordingName '.noi.evt'];
    fid = fopen(eventsFileName,'w');
    
    for i = 1:size(noiseIntsSlo,1)
        fprintf(fid,'%f\t%s\n',timestamps(noiseIntsSlo(i,1))*1000,'Noise start');
        fprintf(fid,'%f\t%s\n',timestamps(noiseIntsSlo(i,2))*1000,'Noise end');
    end
    
    fclose(fid);
end

clear noiseInfo
noiseInfo.score = yz;
noiseInfo.datThreshold = thresh;
noiseInfo.intervals = noiseIntsSlo;
noiseInfo.timestamps = timestamps(noiseIntsSlo);

save([basepath filesep chInfo.recordingName '.noise.mat'],'noiseInfo')

noiseIntsFast = noiseIntsSlo*upSampleRatio; %adjust for 8x sampling rate in dat file [FIX THIS]

%% plot info

if makeFigure
    tmpInts = noiseInfo.timestamps;
    
    figure;
    subplot(2,1,1)
    histogram(diff(tmpInts,[],2))
    title([num2str(size(tmpInts,2)), ' noise intervals removed'])
    subplot(2,1,2)
    scatter(tmpInts(:,1)-timestamps(1),ones(size(tmpInts,1),1),'.')
    xlim([0 (timestamps(end)-timestamps(1))])
    title([num2str(sum(diff(tmpInts,[],1))),' seconds of noise removed'])
    
    savefig(gcf,[basepath '\sanityCheckFigures\noiseRemoval.fig'])
    saveas(gcf,[basepath '\sanityCheckFigures\noiseRemoval.jpg'])
end

%%
% Replace in dat file
nChannels = chInfo.nChannel;
m = memmapfile(dat_path, 'Format','int16','Writable',true);
nPnt = round(length(m.Data)/nChannels);
intWindow = 5;

for chIdx = 1:nChannels

    for intIdx = 1:size(noiseIntsFast,1)
        noiseInds = noiseIntsFast(intIdx,1):noiseIntsFast(intIdx,2);
        frameInds = (noiseIntsFast(intIdx,1)-intWindow):(noiseIntsFast(intIdx,2)+intWindow);
        frameInds(ismember(frameInds,noiseInds)) = [];
        frameInds(frameInds>nPnt|frameInds<1) = []; 
        frameIndsFlat = sub2ind([nChannels,nPnt],chIdx*ones(size(frameInds)),frameInds);
        noiseIndsFlat = sub2ind([nChannels,nPnt],chIdx*ones(size(noiseInds)),noiseInds);
        sig = m.Data(frameIndsFlat);
        fillVals = interp1(frameInds,double(sig),noiseInds);
        m.Data(noiseIndsFlat) = int16(fillVals);
    end

end

end

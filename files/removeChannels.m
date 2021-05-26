function removeChannels(basepath,varargin)

p = inputParser;
addParameter(p,'badChannels',[],@isnumeric);

parse(p,varargin{:});
badChannels = p.Results.badChannels;

chInfo = hackInfo('basepath',basepath);
nChannels = chInfo.nChannel;

if isempty(badChannels)
    badChannels = chInfo.one.badChannels;
end

if isempty(badChannels)
    return;
end

session = bz_getSession('basepath',basepath);
basename = session.general.name;
goodChannels = setdiff(chInfo.one.channels,badChannels);

spikeFileName = [basepath, filesep, basename, '_0.dat'];
tmpSpike = [basepath,filesep,basename,'_0tmp.dat'];
lfpFileName = [basepath, filesep, basename, '_1.dat'];
tmpLFP = [basepath,filesep,basename,'_1tmp.dat'];

%% Remove channels from spiking file

m = memmapfile(spikeFileName,'Format','int16');
nPnt = round(length(m.Data)/nChannels);
batchLength = 5*session.extracellular.sr; %1 second batches
batchInds = round(linspace(0,nPnt,nPnt/batchLength));
nBatch = length(batchInds)-1;

clear m
m = memmapfile(spikeFileName,'Format',{'int16',[nChannels,nPnt],'x'});

% read and write to new file in batches
fid = fopen(tmpSpike,'w');
tic
for i = 1:nBatch
    
    d = m.Data.x(:,(batchInds(i)+1):batchInds(i+1));
    dCut = d(goodChannels,:);
    fwrite(fid,dCut(:),'int16');
end
fclose(fid);

clear m
toc

delete(spikeFileName)
movefile(tmpSpike,spikeFileName)

%% Remove channels from lfp file

m = memmapfile(lfpFileName,'Format','int16');
nPnt = round(length(m.Data)/nChannels);
batchLength = 100*session.extracellular.srLfp; %100 second batches
batchInds = round(linspace(0,nPnt,nPnt/batchLength));
nBatch = length(batchInds)-1;

clear m
m = memmapfile(lfpFileName,'Format',{'int16',[nChannels,nPnt],'x'});

% read and write to new file in batches
fid = fopen(tmpLFP,'w');
tic
for i = 1:nBatch
    
    d = m.Data.x(:,(batchInds(i)+1):batchInds(i+1));
    dCut = d(goodChannels,:);
    fwrite(fid,dCut(:),'int16');
end
fclose(fid);

clear m
toc

delete(lfpFileName)
movefile(tmpLFP,lfpFileName)

%% Delete bad channels from session file

shiftChannels = 1:length(goodChannels);
newChanMatch = zeros(1,nChannels);
newChanMatch(goodChannels) = shiftChannels;

tmpSpikeGroups = cellfun(@(s) newChanMatch(s), session.extracellular.spikeGroups.channels,'UniformOutput',false);
session.extracellular.spikeGroups.channels = cellfun(@(s) s(s~=0), tmpSpikeGroups,'UniformOutput',false);
tmpElecGroups = cellfun(@(s) newChanMatch(s), session.extracellular.electrodeGroups.channels,'UniformOutput',false);
session.extracellular.electrodeGroups.channels = cellfun(@(s) s(s~=0), tmpElecGroups,'UniformOutput',false);

tagTypes = fields(session.channelTags);
for i = 1:length(tagTypes)
    tmp = session.channelTags.(tagTypes{i}).channels;
    tmp = newChanMatch(tmp);
    session.channelTags.(tagTypes{i}).channels = tmp(tmp~=0);
end

regions = fields(session.brainRegions);
for i = 1:length(regions)
    tmp = session.brainRegions.(regions{i}).channels;
    tmp = newChanMatch(tmp);
    session.brainRegions.(regions{i}).channels = tmp(tmp~=0);
end

session.extracellular.nChannels = length(goodChannels);
session.extracellular.OGchannels = newChanMatch;
save([basepath,filesep,basename,'.session.mat'],'session')
end
    


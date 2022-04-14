function spikes = bz_GetSpikes_km(varargin)
% bz_getSpikes - Get spike timestamps.
%       if loading from clu/res/fet/spk files - must be formatted as:
%       baseName.clu.shankNum
%
% USAGE
%
%    spikes = bz_getSpikes(varargin)
% 
% INPUTS
%
%    spikeGroups     -vector subset of shank IDs to load (Default: all)
%    region          -string region ID to load neurons from specific region
%                     (requires sessionInfo file or units->structures in xml)
%    UID             -vector subset of UID's to load 
%    basepath        -path to recording (where .dat/.clu/etc files are)
%    getWaveforms    -logical (default=true) to load mean of raw waveform data
%    forceReload     -logical (default=false) to force loading from
%                     res/clu/spk files
%    onlyLoad        -[shankID cluID] pairs to EXCLUSIVELY LOAD from 
%                       clu/res/fet to spikes.cellinfo.mat file
%    saveMat         -logical (default=false) to save in buzcode format
%    noPrompts       -logical (default=false) to supress any user prompts
%    verbose         -logical (default=false)
%    keepCluWave     -logical (default=false) to keep waveform from
%                       previous bz_getSpikes functions (before 2019). It only
%                       affects clu inputs.
%    sortingMethod   - [], 'kilosort' or 'clu'. If [], tries to detect a
%                   kilosort folder or clu files. 
%    
% OUTPUTS
%
%    spikes - cellinfo struct with the following fields
%          .sessionName    -name of recording file
%          .UID            -unique identifier for each neuron in a recording
%          .times          -cell array of timestamps (seconds) for each neuron
%          .spindices      -sorted vector of [spiketime UID], useful for 
%                           input to some functions and plotting rasters
%          .region         -region ID for each neuron (especially important large scale, high density probes)
%          .shankID        -shank ID that each neuron was recorded on
%          .maxWaveformCh  -channel # with largest amplitude spike for each neuron
%          .rawWaveform    -average waveform on maxWaveformCh (from raw .dat)
%          .cluID          -cluster ID, NOT UNIQUE ACROSS SHANKS
%          .numcells       -number of cells/UIDs
%          .filtWaveform   -average filtered waveform on maxWaveformCh
%           
% NOTES
%
% This function can be used in several ways to load spiking data.
% Specifically, it loads spiketimes for individual neurons and other
% sessionInfodata that describes each neuron.  Spiketimes can be loaded using the
% UID(1-N), the shank the neuron was on, or the region it was recorded in.
% The default behavior is to load all spikes in a recording. The .shankID
% and .cluID fields can be used to reconstruct the 'units' variable often
% used in FMAToolbox.
% units = [spikes.shankID spikes.cluID];
% 
% 
% first usage recommendation:
% 
%   spikes = bz_getSpikes('saveMat',true); Loads and saves all spiking data
%                                          into buzcode format .cellinfo. struct
% other examples:
%
%   spikes = bz_getSpikes('spikeGroups',1:5); first five shanks
%
%   spikes = bz_getSpikes('region','CA1'); cells tagged as recorded in CA1
%
%   spikes = bz_getSpikes('UID',[1:20]); first twenty neurons
%
%
% written by David Tingley, 2017
% added Phy loading by Manu Valero, 2019 (previos bz_LoadPhy)
% km2021
% TO DO: Get waveforms by an independent function (ie getWaveform) that
% generates a waveform.cellinfo.mat file with all channels waves.
%% Deal With Inputs 
spikeGroupsValidation = @(x) assert(isnumeric(x) || strcmp(x,'all'),...
    'spikeGroups must be numeric or "all"');

p = inputParser;
addParameter(p,'spikeGroups','all',spikeGroupsValidation);
addParameter(p,'region','',@isstr); % won't work without sessionInfodata 
addParameter(p,'UID',[],@isvector);
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'getWaveforms',true)
addParameter(p,'forceReload',false,@islogical);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'noPrompts',false,@islogical);
addParameter(p,'onlyLoad',[]);
addParameter(p,'verbose',true,@islogical);
addParameter(p,'keepCluWave',false,@islogical);
addParameter(p,'sortingMethod',[],@isstr);

parse(p,varargin{:})

spikeGroups = p.Results.spikeGroups;
region = p.Results.region;
UID = p.Results.UID;
basepath = p.Results.basepath;
getWaveforms = p.Results.getWaveforms;
forceReload = p.Results.forceReload;
saveMat = p.Results.saveMat;
noPrompts = p.Results.noPrompts;
onlyLoad = p.Results.onlyLoad;
verbose = p.Results.verbose;
keepCluWave = p.Results.keepCluWave;
sortingMethod = p.Results.sortingMethod;

%[sessionInfo] = bz_getSessionInfo(basepath, 'noPrompts', noPrompts);
%baseName = bz_BasenameFromBasepath(basepath);
session = bz_getSession('basepath',basepath);
chInfo = hackInfo('basepath',basepath);

spikes.samplingRate = chInfo.spikeSR;
nChannels = chInfo.nChannel;

cellinfofile = [basepath filesep session.general.name '.spikes.cellinfo.mat'];
kilosort_path = dir([basepath filesep '*kilosort*']);

%% Load data from clu files
if strcmpi(sortingMethod, 'kilosort') || ~isempty(kilosort_path) % LOADING FROM KILOSORT
    
    disp('loading spikes from Kilosort/Phy format...')
    fs = spikes.samplingRate;
    spike_cluster_index = readNPY(fullfile(kilosort_path.name, 'spike_clusters.npy'));
    spike_times = readNPY(fullfile(kilosort_path.name, 'spike_times.npy'));
    cluster_group = tdfread(fullfile(kilosort_path.name,'cluster_group.tsv'));
%     try
%         shanks = readNPY(fullfile(kilosort_path.name, 'shanks.npy')); % done
%     catch
%         shanks = ones(size(cluster_group.cluster_id));
%         warning('No shanks.npy file, assuming single shank!');
%     end
    
    spikes.sessionName = session.general.name;
    jj = 1;
    for ii = 1:length(cluster_group.group)
        if strcmpi(strtrim(cluster_group.group(ii,:)),'good')
            ids = find(spike_cluster_index == cluster_group.cluster_id(ii)); % cluster id
            spikes.cluID(jj) = cluster_group.cluster_id(ii);
            spikes.UID(jj) = jj;
            spikes.times{jj} = double(spike_times(ids))/fs; % cluster time
            spikes.ts{jj} = double(spike_times(ids)); % cluster time
%             cluster_id = find(cluster_group.cluster_id == spikes.cluID(jj));
%             spikes.shankID(jj) = double(shanks(cluster_id));
            
            jj = jj + 1;
        end
    end
    nCell = jj-1;
else
    error('Unit format not recognized...');
end

%% Load waveforms
if any(getWaveforms) && ~keepCluWave
    nPull = 1000;  % number of spikes to pull out
    wfWin = 0.008; % Larger size of waveform windows for filterning
    filtFreq = 500;
    hpFilt = designfilt('highpassiir','FilterOrder',3, 'PassbandFrequency',filtFreq,'PassbandRipple',0.1, 'SampleRate',fs);
    wfWin = round((wfWin * fs)/2);
    
    spikes.rawWaveform = cell(nCell,1);
    spikes.filtWaveform = cell(nCell,1);
    spikes.maxWaveformCh = zeros(nCell,1);
    spikes.shankID = zeros(nCell,1);
    for ii = 1 : nCell
        spkTmp = spikes.ts{ii};
        if length(spkTmp) > nPull
            spkTmp = spkTmp(randperm(length(spkTmp)));
            spkTmp = spkTmp(1:nPull);
        end
        
        wf = [];
        for jj = 1 : length(spkTmp)
            if verbose
                fprintf(' ** %3.i/%3.i for cluster %3.i/%3.i  \n',jj, length(spkTmp), ii, size(spikes.times,2));
            end
            wf = cat(3,wf,bz_LoadBinary([session.general.name '.dat'],'offset',spkTmp(jj) - (wfWin),...
                'samples',(wfWin * 2)+1,'frequency',chInfo.spikeSR,'nChannels',chInfo.nChannel));
        end
        wf = mean(wf,3);
        if ~isempty(chInfo.one.badChannels)
            wf(:,chInfo.one.badChannels)=0;
        end
        for jj = 1 : size(wf,2)
            wfF(:,jj) = filtfilt(hpFilt,wf(:,jj) - mean(wf(:,jj)));
        end
        [~, maxCh] = max(abs(wfF(wfWin,:)));
        rawWaveform = detrend(wf(:,maxCh) - mean(wf(:,maxCh)));
        filtWaveform = wfF(:,maxCh) - mean(wfF(:,maxCh));
        spikes.rawWaveform{ii} = rawWaveform(wfWin-(0.002*fs):wfWin+(0.002*fs)); % keep only +- 1ms of waveform
        spikes.filtWaveform{ii} = filtWaveform(wfWin-(0.002*fs):wfWin+(0.002*fs));
        maxWaveCh = chInfo.one.channels(maxCh);
        spikes.maxWaveformCh(ii) = maxWaveCh;
        spikes.shankID(ii) = chInfo.shankID(maxWaveCh);
        
    end

    % add region according to max wave form channel
    spikes.region = cell(length(spikes.times),1);
    regions = fieldnames(session.brainRegions);
    for regIdx = 1:length(regions)
        chInRegion = session.brainRegions.(regions{regIdx});
        spikes.region(ismember(spikes.maxWaveformCh,chInRegion.channels)) = regions(regIdx);
    end
    
end

if ~isempty(onlyLoad)
    toRemove = true(size(spikes.UID));
    for cc = 1:size(onlyLoad,1)
        whichUID = ismember(spikes.shankID,onlyLoad(cc,1)) & ismember(spikes.cluID,onlyLoad(cc,2));
        toRemove(whichUID) = false;
        if ~any(whichUID)
            display(['No unit with shankID:',num2str(onlyLoad(cc,1)),...
                ' cluID:',num2str(onlyLoad(cc,2))])
        end
    end
    spikes = removeCells(toRemove,spikes,getWaveforms);
end

%% save to buzcode format (before exclusions)
if saveMat
    save(cellinfofile,'spikes')
end



%% EXCLUSIONS %%

%filter by spikeGroups input
if ~strcmp(spikeGroups,'all')
    [toRemove] = ~ismember(spikes.shankID,spikeGroups);
    spikes = removeCells(toRemove,spikes,getWaveforms);
end

%filter by region input
if ~isempty(region)
    if ~isfield(spikes,'region') %if no region information in metadata
        error(['You selected to load cells from region "',region,...
            '", but there is no region information in your sessionInfo'])
    end
    
    toRemove = ~ismember(spikes.region,region);
    if sum(toRemove)==length(spikes.UID) %if no cells from selected region
        warning(['You selected to load cells from region "',region,...
            '", but none of your cells are from that region'])
    end
    
    spikes = removeCells(toRemove,spikes,getWaveforms);
end

%filter by UID input
if ~isempty(UID)
    [toRemove] = ~ismember(spikes.UID,UID);
    spikes = removeCells(toRemove,spikes,getWaveforms);
end
spikes.numcells = length(spikes.UID);


% %% Generate spindices matrics
% 
% for cc = 1:spikes.numcells
%     groups{cc}=spikes.UID(cc).*ones(size(spikes.times{cc}));
% end
% if spikes.numcells>0
%     alltimes = cat(1,spikes.times{:}); groups = cat(1,groups{:}); %from cell to array
%     [alltimes,sortidx] = sort(alltimes); groups = groups(sortidx); %sort both
%     spikes.spindices = [alltimes groups];
% end

%% Check if any cells made it through selection
if isempty(spikes.times) | spikes.numcells == 0
    spikes = [];
end

end

%%
function spikes = removeCells(toRemove,spikes,getWaveforms)
%Function to remove cells from the structure. toRemove is the INDEX of
%the UID in spikes.UID
spikes.UID(toRemove) = [];
spikes.times(toRemove) = [];
spikes.region(toRemove) = [];
spikes.shankID(toRemove) = [];
if isfield(spikes,'cluID')
    spikes.cluID(toRemove) = [];
elseif isfield(spikes,'UID_kilosort')
    spikes.UID_kilosort(toRemove) = [];
end

if any(getWaveforms)
    spikes.rawWaveform(toRemove) = [];
    spikes.maxWaveformCh(toRemove) = [];
    if isfield(spikes,'filtWaveform')
        spikes.filtWaveform(toRemove) = [];
    end
end
end






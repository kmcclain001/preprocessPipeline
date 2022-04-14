basepath = pwd;

%% Pull meta data

% Get session names
if strcmp(basepath(end),filesep)
    basepath = basepath(1:end-1);
end
[~,basename] = fileparts(basepath);

% for now manually put desired xml in basepath - should probably automate
xmlFile = checkFile('fileType','.xml','searchSubdirs',false);
xmlFile = xmlFile(1);

%% Make SessionInfo
% assumes manual selection of bad channels

session = sessionTemplate(pwd,'showGUI',true); %
save([basename '.session.mat'],'session');

%% Find data paths

fileInfo = dataPathsNP(basepath);

%% Concatenate dats

cd(basepath);

disp('Concatenate session folders...');
bz_ConcatenateDats_NP(fileInfo)

%% Remove bad channels from concatenated dat files

removeChannels(basepath)

%% Make LFP file

bz_LFPfromDat_km(basepath,'datFile',[basename '_1.dat'],'inFs',2500,'outFS',1250); %downsample here


%% Get tracking

getSessionTracking_km('basepath',basepath,'method','neuropixel');

%% Kilosort

createChannelMapFile_NP(basepath);

savepath = KiloSortWrapper('SSD_path','H:');

PhyAutoClustering_km(savepath);

%% NOW SPIKE SORT %%
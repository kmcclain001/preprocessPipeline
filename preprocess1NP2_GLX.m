function  preprocess1NP2_GLX(varargin)

p = inputParser;
addParameter(p,'basepath',pwd,@isfolder); % by default, current folder
addParameter(p,'removeNoise',true,@islogical);

parse(p,varargin{:});
basepath = p.Results.basepath;
removeNoise = p.Results.removeNoise;

if ~exist('basepath','var')
    error('path provided does not exist')
end
cd(basepath);

%% Pull meta data

% Name session after session folder
if strcmp(basepath(end),filesep)
    basepath = basepath(1:end-1);
end
[~,basename] = fileparts(basepath);

% Move first xml found to basepath
xmlFile = checkFile('fileType','.xml','searchSubdirs',true);
xmlFile = xmlFile(1);
if ~(strcmp(xmlFile.folder,basepath)&&strcmp(xmlFile.name(1:end-4),basename))
    copyfile([xmlFile.folder,filesep,xmlFile.name],[basepath,filesep,basename,'.xml'])
end

%% Make SessionInfo
% assumes manual selection of bad channels

session = sessionTemplate(pwd,'showGUI',true); %
save([basename '.session.mat'],'session');

mkdir([basepath '\sanityCheckFigures'])

%% Concatenate dats

disp('Concatenate session folders...');
bz_ConcatenateDats_NP2_GLX('basepath',basepath)

%% Make LFP file
  
bz_LFPfromDat_km(basepath,'outFs',1250,'lopass',625); %downsample here

%% Get tracking

getSessionTracking_km('basepath',basepath,'method','glx');

%% Kilosort

probeNumber = createChannelMap_NP2_GLX(basepath);

if removeNoise
    datFileMeanSubtraction('basepath',basepath,'probeNumber',probeNumber,'method','subtractMedian');
    fclose('all');
end


savepath = KSW_wrapper('basepath',basepath,'config','km','splitSorting',true);

%% NOW SPIKE SORT %%
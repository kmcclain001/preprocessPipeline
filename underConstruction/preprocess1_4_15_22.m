function  preprocess1(varargin)

%         bz_PreprocessSession(varargin)

%   Master function to run the basic pre-processing pipeline for an
%   individual sessions. Is based on sessionsPipeline.m but in this case
%   works on an individual session basis no in a folfer with multiple ones.
% 

% INPUTS
%   <options>       optional list of property-value pairs (see table below)
%   basepath        - Basepath for experiment. It contains all session
%                       folders. If not provided takes pwd.
%   analogCh       - List of analog channels with pulses to be detected (it support Intan Buzsaki Edition).
%   forceSum       - Force make folder summary (overwrite, if necessary). Default false.
%   cleanArtifacts - Remove artifacts from dat file. By default, if there is analogEv in folder, is true.
%   stateScore     - Run automatic brain state detection with SleepScoreMaster. Default true.
%   spikeSort      - Run automatic spike sorting using Kilosort. Default true.
%   getPos         - get tracking positions. Default true. 
%   runSummary     - run summary analysis using AnalysisBatchScrip. Default false.
%   pullData       - Path for raw data. Look for not analized session to copy to the main folder basepath. To do...
%
%  HISTORY: 
%     - KM

%  TO DO:
%   - Verify that data format and alysis output are compatible with CellExplorer
%   - Include Kilosort2 support
%   - Improve auto-clustering routine 

% write file to keep track of 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up parameters and parse inputs

p = inputParser;
addParameter(p,'basepath',pwd,@isfolder); % by default, current folder
addParameter(p,'fillMissingDatFiles',true,@islogical);
addParameter(p,'fillTypes',[],@iscellstr);
addParameter(p,'getAcceleration',false,@islogical);
addParameter(p,'stateScore',false,@islogical);
addParameter(p,'spikeSort',true,@islogical);
addParameter(p,'getPos',true,@islogical);
addParameter(p,'removeNoise',true,@islogical);

% addParameter(p,'pullData',[],@isdir); To do... 
parse(p,varargin{:});

basepath = p.Results.basepath;
fillMissingDatFiles = p.Results.fillMissingDatFiles;
fillTypes = p.Results.fillTypes;
getAcceleration = p.Results.getAcceleration;
stateScore = p.Results.stateScore;
spikeSort = p.Results.spikeSort;
removeNoise = p.Results.removeNoise;
getPos = p.Results.getPos;

if ~exist('basepath')
    error('path provided does not exist')
end
cd(basepath);

%% Pull meta data

% Get session names
if strcmp(basepath(end),filesep)
    basepath = basepath(1:end-1);
end
[~,basename] = fileparts(basepath);

% % % % Get xml file in order
% % % xmlFile = checkFile('fileType','.xml','searchSubdirs',true);
% % % xmlFile = xmlFile(1);
% % % if ~(strcmp(xmlFile.folder,basepath)&&strcmp(xmlFile.name(1:end-4),basename))
% % %     copyfile([xmlFile.folder,filesep,xmlFile.name],[basepath,filesep,basename,'.xml'])
% % % end
% % % 
% % % %% Make SessionInfo
% % % % ID bad channels at this point. automating would be good
% % % 
% % % session = sessionTemplate(basepath,'showGUI',true); %
% % % save([basename '.session.mat'],'session');
% % % 
% % % mkdir([basepath '\sanityCheckFigures'])

% % % %% Fill missing dat files of zeros
% % % if fillMissingDatFiles
% % %     if isempty(fillTypes)
% % %         fillTypes = {'analogin';'digitalin';'auxiliary';'time';'supply'};
% % %     end
% % %     for ii = 1:length(fillTypes)
% % %         fillMissingDats('basepath',basepath,'fileType',fillTypes{ii});
% % %     end
% % % end
% % % 
% % % %% Concatenate sessions
% % % 
% % % cd(basepath);
% % % 
% % % disp('Concatenate session folders...');
% % % bz_ConcatenateDats_km('basepath',basepath);
% % % 
% % % %% Process additional inputs
% % % 
% % % % Auxilary input
% % % if getAcceleration
% % %     accel = bz_computeIntanAccel('saveMat',true); % uses the old sessionInfo
% % % end
% % % 
% % % %% Get tracking positions 
% % % 
% % % if getPos
% % %     getSessionTracking_km('basepath',basepath);
% % % end
% % % 
% % % %% Make LFP
% % % 
% % % bz_LFPfromDat_km(basepath,'outFs',1250,'lopass',625); % generating lfp

%% remove noise from data for cleaner spike sorting

% NEED TO EDIT CHANNEL MAP FUNCTIONS
probeNumber = createChannelMap_DVB(basepath);

if removeNoise
    datFileMeanSubtraction('basepath',basepath,'probeNumber',probeNumber,'method','subtractMedian');
    fclose('all');
end

%% Kilosort concatenated sessions

savepath = KiloSortWrapper('basepath',basepath);

PhyAutoClustering_km(savepath);

%% Get brain states 
%not working for me, i think there are some issues selecting best channels
if stateScore
    SleepScoreMaster_km(pwd,'noPrompts',true);
end

%% NOW SPIKE SORT %%

end

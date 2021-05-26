function bz_ConcatenateDats_NP(fileInfo,varargin)
% bz_ConcatenateDats - Concatenate raw .dat files found in a session folder
% - for intan type recordings 
% 
% ALGORITHM OUTLINE: looks for .dat files in a folder (or in subfolders) to
% concatenate together.  The concatenation happens via system commands 
% ("cat" command for linux/mac, "copy" command if windows/pc).  Uses
% different assumptions to find and recognize relevant .dats depending on
% the acquisition system.  
% 
% REQUIREMENTS: Assumes you are in or pointed to a directory containing 
% subdirectories for various recording files from a single session. *It is 
% assumed that an earlier-acquired data file/folder will have a name that
% is sorted alphanumerically earlier.  Alphanumeric sorting order is
% assumed to be the recording temporal sequence.
% Works with acquisition systems: Intan  - 
%   1) intan: wherein subfolders are inside the session folder.  Each
%   subfolder contains simultaneously-recorded .dat files recorded for a
%   continuous period of time.  Start/stop recording commands each create a
%   new folder.  *It is assumed that the alphanumeric sorting of these 
%   folders corresponds with their sequence in acquisiton time.*  
%   These folders contain
%       - info.rhd files with metadata about the recording. 
%       - amplifier.dat - int16 file with usually neural data from the
%           headstage
%       - auxiliary.dat (optional) - uint16 file from auxiliary channels on
%           the headstage - often accelerometer
%       - analogin.dat (optional) - uint16 file from analogin channels on 
%           main board 
%       - digitalin.dat (optional) - uint16 file recording all 16 digital 
%           channels on main board 
%       - time.dat - int32 file giving recording sample indicies (e.g. 
%           0,1,2,3...) for each sample recorded in other channels
%       - supply.dat - uint16 file showing voltage supplied to (?preamp?)
%   
%
%  USAGE
%
%    bz_ConcatenateDats(basepath,deleteoriginaldatsbool,sortFiles)
%
%  INPUTS
%
%    basepath          computer path to session folder.  Defaults to
%                      current folder if no input given
%    deleteoriginaldatsbool  - boolean denoting whether to delete (1) or
%                              not delete (0) original .dats after
%                              concatenation.  Default = 0. Not recommended.
%    sortFiles               - boolean denoting whether to sort files according 
%                              to time of recording (1) or
%                              not (0) and thus sort them alphabetically 
%                              Default = 0.
%
%  OUTPUT
%     Operates on files in specified folder.  No output variable
%
%  EXAMPLES
%      Can be called directly or via bz_PreprocessExtracellEphysSession.m
%
% Copyright (C) 2017 by Brendon Watson
% Modified by Antonio FR, 2018
% kathryn mcclain 2020


%% Handling inputs
% basic session name and and path
p = inputParser;
addParameter(p,'basepath',cd,@isstr)

parse(p,varargin{:})
basepath = p.Results.basepath;

%% Get session info
session = bz_getSession('basepath',basepath); 
basename = fileInfo.basename;
basepath = fileInfo.basepath;

%% If the dats are already merged quit
if exist(fullfile(basepath,[basename,'.dat']),'file')
    disp('.dat already exists in session directory, not merging subdats')
    return
end

%% Concatenate lfp files
newPath = [basepath,filesep,basename,'_1.dat'];

oldPaths = cell(fileInfo.nFolders,1);
fileSize = zeros(fileInfo.nFolders,1);
for fIdx = 1:fileInfo.nFolders
    oldPaths{fIdx} = [basepath,filesep,fileInfo.folder{fIdx},fileInfo.lfpPath,'continuous.dat'];
    fileSize(fIdx) = dir(oldPaths{fIdx}).bytes;
end

if isunix
    cs = strjoin(oldPaths);
    catstring = ['! cat ', cs, ' > ',newPath];
elseif ispc
    cs = strjoin(oldPaths, ' + ');
    catstring = ['! copy /b ', cs, ' ',newPath];
end

eval(catstring)%execute concatenation
 
% Check that size of resultant .dat is equal to the sum of the components
newSize = dir(newPath).bytes;
oldSize = sum(fileSize);
if newSize==oldSize
    disp(['lfp concatenated and size checked'])
    sizeCheck.lfp = true;
else
    error('New lfp .dat size not right')
end


%% Concatenate spike files
newPath = [basepath,filesep,basename,'_0.dat'];

oldPaths = cell(fileInfo.nFolders,1);
fileSize = zeros(fileInfo.nFolders,1);
for fIdx = 1:fileInfo.nFolders
    oldPaths{fIdx} = [basepath,filesep,fileInfo.folder{fIdx},fileInfo.spikePath,'continuous.dat'];
    fileSize(fIdx) = dir(oldPaths{fIdx}).bytes;
end

if isunix
    cs = strjoin(oldPaths);
    catstring = ['! cat ', cs, ' > ',newPath];
elseif ispc
    cs = strjoin(oldPaths, ' + ');
    catstring = ['! copy /b ', cs, ' ',newPath];
end

eval(catstring)%execute concatenation
 
% Check that size of resultant .dat is equal to the sum of the components
newSize = dir(newPath).bytes;
oldSize = sum(fileSize);
if newSize==oldSize
    disp(['spikes concatenated and size checked'])
    sizeCheck.spikes = true;
else
    error('New spikes .dat size not right')
end

%% Concatenate time files
% file of time points corresponding to each datapoint in high-pass dat file

timeFile = [basepath,filesep,'time.dat'];

timeData = cell(fileInfo.nFolders,1);

firstLastInds = zeros(fileInfo.nFolders,2);
count = 0;%start on index 1
for fIdx = 1:fileInfo.nFolders
    tmpTime = readNPY([basepath,filesep,fileInfo.folder{fIdx},fileInfo.spikePath,'timestamps.npy']);
    firstLastInds(fIdx,:) = [tmpTime(1) tmpTime(end)]+count;
    timeData{fIdx} = tmpTime+count;
    count = firstLastInds(fIdx,2);
end

timestamps = (vertcat(timeData{:})-1)/session.extracellular.sr; %start at time 0
timeFileID = fopen(timeFile,'w');
fwrite(timeFileID,timestamps);
fclose(timeFileID);

 %% I think i actually don't need this... Concatenate TTLs
% % index of datapoints in high-pass dat file corresponding to ttl pulse
% 
% ttlFile = [basepath,filesep,'ttl.dat'];
% TTLData = cell(fileInfo.nFolders,1);
% 
% for fIdx = 1:fileInfo.nFolders
%     tmpTTLValue = readNPY([basepath,filesep,fileInfo.folder{fIdx},fileInfo.ttlPath,'channel_states.npy']);
%     tmpInds = readNPY([basepath,filesep,fileInfo.folder{fIdx},fileInfo.ttlPath,'timestamps.npy']);
%     tmpTTLPulse = tmpInds(tmpTTLValue==1)+firstLastInds(fIdx,1)-1;
%     TTLData{fIdx} = tmpTTLPulse;
% end
% 
% TTLInds = vertcat(TTLData{:});
% ttlFileID = fopen(ttlFile,'w');
% fwrite(ttlFileID,TTLInds);
% fclose(ttlFileID);

%% Compute merge points
eventsfilename = [basepath,filesep,basename,'.MergePoints.events.mat'];

transitiontimes_sec = (firstLastInds-1)./session.extracellular.sr;

MergePoints.timestamps = transitiontimes_sec;
MergePoints.timestamps_samples = firstLastInds;
MergePoints.firstlasttimepoints_samples = diff(firstLastInds)+1;
MergePoints.foldernames = fileInfo.folder;
MergePoints.sizecheck = sizeCheck;

save(eventsfilename,'MergePoints');
end




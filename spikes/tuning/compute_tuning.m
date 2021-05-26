% Compute firing maps by trial
% each cell has a matrix of nPos X nTrials
% and each entry is the number of spikes at that position
% then theres an overarching occupancy map that is
% nPos x nTrials
% Could also be helpful to have location at which each spike occured

function Tuning = compute_tuning(varargin)

% Parse Inputs

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);

parse(p,varargin{:});
basepath = p.Results.basepath;

session = bz_getSession('basepath',basepath);
fname = session.general.name;
tuneFile = [basepath filesep fname '.Tuning.cellinfo.mat'];

% Load spikes and behavior
fSpike = checkFile('basepath',basepath,'fileType','.spikes.cellinfo.mat');
load([fSpike.folder filesep fSpike.name])

fBehav = checkFile('basepath',basepath,'fileType','.behavior.mat');
load([fBehav.folder filesep fBehav.name]);

Tuning.UID = spikes.UID;
Tuning.nTrials = length(behavior.events.trials);
Tuning.nCells = length(spikes.UID);
Tuning.region = spikes.region;
Tuning.nPos = height(behavior.trackGraph.Nodes);
Tuning.occupancy = zeros(Tuning.nTrials,Tuning.nPos);
Tuning.spikeCount = zeros(Tuning.nTrials,Tuning.nPos,Tuning.nCells);
Tuning.trialType = behavior.events.trialType;
Tuning.shankID = spikes.shankID;
 
for i = 1:Tuning.nTrials
    traj = behavior.events.trials{i}.l;
    for j = 1:length(traj)
        Tuning.occupancy(i,traj(j)) = Tuning.occupancy(i,traj(j))+1;
        t1 = behavior.timestamps(behavior.events.trials{i}.indices(j));
        t2 = t1 + 1/behavior.samplingRate;
        for k = 1:Tuning.nCells
            nSpikes = sum(spikes.times{k}>=t1&spikes.times{k}<t2);
            Tuning.spikeCount(i,traj(j),k) = Tuning.spikeCount(i,traj(j),k) + nSpikes;
        end
    end
end

% Convert occupancy to seconds
Tuning.occupancy = Tuning.occupancy./behavior.samplingRate;

save(tuneFile,'Tuning')
end
    
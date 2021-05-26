function linearize_position(varargin)

p = inputParser;
addParameter(p,'basepath',pwd,@isfolder);

parse(p,varargin{:});
basepath = p.Results.basepath;

behavefile = checkFile('basepath',basepath,'fileType','.behavior.mat');

% Linearize track
[f,G,fig] = linearize_track([behavefile.folder filesep behavefile.name], true);

% Load original behavior file
load([behavefile.folder filesep behavefile.name])
n_trials = size(behavior.events.trials,2);
behavior.trackGraph = G;
behavior.trackDistanceMatrix = distances(G);
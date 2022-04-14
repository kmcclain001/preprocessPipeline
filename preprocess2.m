function preprocess2(varargin)

%to be run after manual spike sorting
p = inputParser;
addParameter(p,'basepath',pwd,@isfolder); % by default, current folder
parse(p,varargin{:});
basepath = p.Results.basepath;

session = bz_getSession('basepath',basepath);

%% Compute spike info 
bz_GetSpikes_km('basepath',pwd,'sortingMethod','kilosort','verbose',false)

%% Classify cell types
getCellTypes('basepath',basepath);

%% Further process behavioral data (could go in preprocess1 too)

trialSegmentation('basepath',pwd);

linearize_position('basepath',pwd); %would be cool to incorporate acceleration from headstage here

%% Compute tuning of cells
compute_tuning('basepath',pwd);

fr_maps_session('basepath',pwd);

compute_place_fields_session('basepath',pwd);

%% Get theta info

create_thetaInfo_object('basepath',pwd);

%% Detect ripples

%detectRipples('shanksToDetect',6,'detectionMethod','template','thresholdPrctile',65);


function preprocess2(varargin)

%to be run after manual spike sorting
p = inputParser;
addParameter(p,'basepath',pwd,@isfolder); % by default, current folder
parse(p,varargin{:});
basepath = p.Results.basepath;

session = bz_getSession('basepath',basepath);

%% Compute spike info 
bz_GetSpikes_km_0('basepath',pwd,'verbose',false)

%% Classify cell types
getCellTypes('basepath',basepath);

%% Further process behavioral data (could go in preprocess1 too)


trialSegmentation('basepath',pwd);
disp('hi 1')

linearize_position('basepath',pwd); %would be cool to incorporate acceleration from headstage here
disp('hi 2')

%% Compute tuning of cells
compute_tuning('basepath',pwd);
disp('hi 3')

fr_maps_session('basepath',pwd);
disp('hi 4')

compute_place_fields_session('basepath',pwd);
disp('hi 5')

%% Get theta info

create_thetaInfo_object('basepath',pwd);
disp('hi 6')

%% Detect ripples

%detectRipples('shanksToDetect',6,'detectionMethod','template','thresholdPrctile',65);


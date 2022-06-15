function trialSegmentation(varargin)

p = inputParser;
addParameter(p,'basepath',pwd,@isfolder); 
addParameter(p,'speedSmoothing',5/6,@isfloat);
addParameter(p,'endZonePercentile',5,@isfloat);
addParameter(p,'midZonePercentile',30,@isfloat);
addParameter(p,'outlierPercentile',1,@isfloat);
addParameter(p,'speedThresh',0.25,@isfloat);
addParameter(p,'acelThresh',.02,@isfloat);
addParameter(p,'durationThresh',5,@isfloat);
addParameter(p,'plotSummary',true,@islogical);

parse(p,varargin{:});
basepath = p.Results.basepath;
smoothing_param = p.Results.speedSmoothing;
endZonePercentile = p.Results.endZonePercentile;
midZonePercentile = p.Results.midZonePercentile;
outlierPercentile = p.Results.outlierPercentile;
speedThresh = p.Results.speedThresh;
durationThresh = p.Results.durationThresh;
acelThresh = p.Results.acelThresh;
plotSummary = p.Results.plotSummary;

f = checkFile('basepath',basepath,'fileType','.behavior.mat');
load([f.folder filesep f.name]);

% Compute speed across session
x = behavior.position.x;
y = behavior.position.y;
z = behavior.position.z;

sigma = smoothing_param*behavior.samplingRate;
kern = gausswin(round(sigma));
kern = kern./sum(kern);

dx = diff(x);
dy = diff(y);
ds_raw = (dx.^2+dy.^2).^.5;
ds = nanconv(ds_raw,kern,'same');

speed_AU = interp1(1:length(ds),ds,0:length(ds),'linear');
speed = speed_AU' * behavior.samplingRate;

% % Get Acceleration (maybe not needed)
derivFilt =  [0.10689 0.28461 0.0  -0.28461  -0.10689];
accel_AU = convNoPad(speed,derivFilt,'padMeanRatio',1/1000);
accel = accel_AU * behavior.samplingRate;
%accel = convNoPad(accel,kern,'padMeanRatio',1/1000);
accel_norm = zscore(accel_AU);
accel_smoo = convNoPad(accel_norm,kern,'padMeanRatio',1/1000);

% Find position extremity (specific to current set up)
x_set = unique(x);
end_zone_marks = prctile(x_set,[endZonePercentile,100-endZonePercentile]);
mid_zone_marks = prctile(x_set,[midZonePercentile,100-midZonePercentile]);

y_outlier_set = prctile(y,[outlierPercentile,100-outlierPercentile]);
z_outlier_set = prctile(z,[outlierPercentile,100-outlierPercentile]);

y_outlier = inRange(y,y_outlier_set,true);
z_outlier = inRange(z,z_outlier_set,true);

% identify stationary intervals
endZone1 = x<end_zone_marks(1);
endZone2 = x>end_zone_marks(2);
midZone1 = x<mid_zone_marks(1);
midZone2 = x>mid_zone_marks(2);

stop1 = midZone1 &(speed<speedThresh|endZone1|abs(accel_smoo)<acelThresh);
stop2 = midZone2 &(speed<speedThresh|endZone2|abs(accel_smoo)<acelThresh);

stop_int1 = findIntervals(stop1);
int1 = stop_int1(:);
stop_int2 = findIntervals(stop2);
int2 = stop_int2(:);

% identify trials
allInt = [int1;int2];
allID = ones(length(allInt),1);
allID(length(int1)+1:end) = -1;

[intSort,sortInds] = sort(allInt);
sortID = allID(sortInds);

trialIDs = diff(sortID);

trialIDInds = find(trialIDs~=0);
trialInts = zeros(length(trialIDInds),2);

trialInts(:,1) = allInt(sortInds(trialIDInds));
trialInts(:,2) = allInt(sortInds(trialIDInds+1));

% exclude trials that are too long
trialDur = diff(trialInts,[],2);
longTrials = find(abs(trialDur-median(trialDur))>durationThresh*mad(trialDur));
trialInts(longTrials,:) = [];
trialIDInds(longTrials) = [];
trialDur(longTrials) = [];

trialTypes = ones(size(trialInts,1),1);
trialTypes(trialIDs(trialIDInds)<0) = 2;

behavior.events.trialIntervals = behavior.timestamps(trialInts);
behavior.events.trialType = trialTypes;

for trialIdx = 1:size(trialInts,1)
    tmpInds = trialInts(trialIdx,1):trialInts(trialIdx,2);
    behavior.events.trials{trialIdx}.x = x(tmpInds);
    behavior.events.trials{trialIdx}.y = y(tmpInds);
    behavior.events.trials{trialIdx}.speed = speed(tmpInds);
    behavior.events.trials{trialIdx}.accel = accel(tmpInds);
    behavior.events.trials{trialIdx}.indices = tmpInds;
end

save([f.folder filesep f.name],'behavior');

if plotSummary
    
    figure;
    n = 4;
    subplot(n,1,1); hold on
    plot(behavior.timestamps,behavior.position.x)
    scatter(behavior.timestamps(trialInts(:,1)),behavior.position.x(trialInts(:,1)),'g*');
    scatter(behavior.timestamps(trialInts(:,2)),behavior.position.x(trialInts(:,2)),'r*');
    title('Trial times')
    
    subplot(n,1,2);
    histogram(trialDur/behavior.samplingRate)
    title('Trial duration')
    
    subplot(n,1,3);
    trialSpd = getCellStructValue(behavior.events.trials,'speed');
    trialSpd = trialSpd(:);
    histogram(trialSpd);
    title('In-trial speed distribution')
   
    subplot(n,1,4);
    histogram(trialTypes);
    title('trial types');
    
    savefig(gcf,[basepath '\sanityCheckFigures\trialSegment.fig'])
    saveas(gcf,[basepath '\sanityCheckFigures\trialSegment.jpg'])
    
end
    
end
% could filter trials if speed drops below a certain value or trial takes
% too long



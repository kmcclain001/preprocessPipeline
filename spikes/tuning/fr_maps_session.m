%% Add usable trials, smooth occupancy & spike count, add fr

function Tuning = fr_maps_session(varargin)

% Parse Inputs

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'plotSummary',true,@islogical);

parse(p,varargin{:});
basepath = p.Results.basepath;
plotSummary = p.Results.plotSummary;

% load shit
fBehav = checkFile('basepath',basepath,'fileType','.behavior.mat');
load([fBehav.folder filesep fBehav.name]);
fTuning = checkFile('basepath',basepath,'fileType','.Tuning.cellinfo.mat');
load([fTuning.folder filesep fTuning.name]);

% good trial conditions
usable_types = [];
for j = 1:max(behavior.events.trialType)
    if sum(behavior.events.trialType==j)>=10
        usable_types = [usable_types j];
    end
end
behavior.usableTypes = usable_types;
Tuning.usableTypes = usable_types;

% smooth occupancy
Tuning.occupancySmooth = gaussian_smooth_graph(behavior.trackGraph,Tuning.occupancy,10);

% smooth spike counts
smoothed_spikes = zeros(size(Tuning.spikeCount));
for j = 1:Tuning.nCells
    %K%if strcmp(Tuning.region{j},'hpc')
        smoothed_spikes(:,:,j) = gaussian_smooth_graph(behavior.trackGraph,Tuning.spikeCount(:,:,j),10);
    %K%end
end
Tuning.spikeCountSmoothed = smoothed_spikes;

% add fr
Tuning.fr = Tuning.spikeCountSmoothed./rep_zero(Tuning.occupancySmooth);

% add rate maps
for j = 1:max(Tuning.trialType)
    trial_inds = find(Tuning.trialType==j);
    pos_inds = behavior.events.mapLinear{j};
    rate_maps{j} = zeros(Tuning.nCells,length(pos_inds));
    se_maps{j} = zeros(Tuning.nCells,length(pos_inds));
    for k = 1:Tuning.nCells
        rate_maps{j}(k,:) = mean(Tuning.fr(trial_inds,pos_inds,k),1);
        se_maps{j}(k,:) = std(Tuning.fr(trial_inds,pos_inds,k),1)/(length(trial_inds).^.5);
    end
end
Tuning.rateMaps = rate_maps;
Tuning.seMaps = se_maps;
    
% save shit
save([fBehav.folder filesep fBehav.name],'behavior')
save([fTuning.folder filesep fTuning.name],'Tuning')

if plotSummary
    figure;
    nRows = ceil(Tuning.nCells/3);
    for cellIdx = 1:Tuning.nCells
        subplot(nRows,3,cellIdx);hold on
        for trialType = 1:length(usable_types)
            plot(Tuning.rateMaps{usable_types(trialType)}(cellIdx,:));
        end
    end
    
    savefig(gcf,[basepath '\sanityCheckFigures\rateMaps.fig'])
    saveas(gcf,[basepath '\sanityCheckFigures\rateMaps.jpg'])
    
    for trialType = 1:length(usable_types)
        t = usable_types(trialType);
        trialInds=find(Tuning.trialType==t);
        figure;
        for cellIdx = 1:Tuning.nCells
            subplot(nRows,3,cellIdx);hold on
            imagesc(Tuning.fr(trialInds,:,cellIdx))
        end
        
        savefig(gcf,[basepath '\sanityCheckFigures\rateTrial_' num2str(t) '.fig'])
        saveas(gcf,[basepath '\sanityCheckFigures\rateTrial_' num2str(t) '.jpg'])
    end
    
end
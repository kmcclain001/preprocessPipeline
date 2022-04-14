function Tuning = compute_place_fields_session(varargin)

% Parse Inputs

p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'plotSummary',true,@islogical);

parse(p,varargin{:});
basepath = p.Results.basepath;
plotSummary = p.Results.plotSummary;

% Load tuning cell type and behavior
fTuning = checkFile('basepath',basepath,'fileType','.Tuning.cellinfo.mat');
load([fTuning.folder filesep fTuning.name]);
fBehav = checkFile('basepath',basepath,'fileType','.behavior.mat');
load([fBehav.folder filesep fBehav.name]);
fCell = checkFile('basepath',basepath,'fileType','.CellClass.cellinfo.mat');
load([fCell.folder filesep fCell.name]);


G = behavior.trackGraph;
hasField = zeros(Tuning.nCells,max(Tuning.trialType));

% For each trial type
for i=1:max(Tuning.trialType)
    
    if ismember(i,Tuning.usableTypes)
        
        % compute firing rate
        position_type_inds = behavior.events.mapLinear{i};
        trial_type_inds = Tuning.trialType==i;
        subG = G.subgraph(position_type_inds);
        FR = Tuning.fr(trial_type_inds,position_type_inds,:);
        
        % for each cell
         for j=1:Tuning.nCells
            
            if true%strcmp(Tuning.region{j},'CA1') %&& CellClass.Pyr(j)==1
                
                % find fields
                [node_inds,field_labels] = find_place_fields(subG,FR(:,:,j),...
                    'max_frac',.2,'FR_thresh',3,'spatial_co_thresh',-1,'smoothed',Tuning.rateMaps{i}(j,:));
                % This part of structure is kind of gross:
                % Tuning > cell index > trial group > fields and labels
                Tuning.placeFields{j}.trialType{i}.fieldInds = node_inds;
                Tuning.placeFields{j}.trialType{i}.fieldLabel = field_labels;
                
                if ~isempty(node_inds)
                    hasField(j,i) = max(field_labels);
                end
            else
                Tuning.placeFields{j}.trialType{i}.fieldInds = [];
                Tuning.placeFields{j}.trialType{i}.fieldLabel = [];
            end
        end
    else
        for j=1:Tuning.nCells
            Tuning.placeFields{j}.trialType{i}.fieldInds = [];
            Tuning.placeFields{j}.trialType{i}.fieldLabel = [];
        end
    end
end

% make list of cells with fields
for cellIdx = 1:Tuning.nCells
    Tuning.placeFields{cellIdx}.hasField = sum(hasField(cellIdx,:))>0;
end

Tuning.hasField = hasField;

save([fTuning.folder filesep fTuning.name],'Tuning')
colors = {'b','r'};
if plotSummary
    pcInds = find(sum(hasField,2)>0);
    nRows = ceil(length(pcInds)/2);
    figure;
    for ii = 1:length(pcInds)
        cellIdx = pcInds(ii);
        subplot(nRows,2,ii);hold on
        fieldType = find(hasField(cellIdx,:)>0);
        for jj = 1:length(fieldType)
            trType = fieldType(jj);
            tmpFR = Tuning.rateMaps{trType}(cellIdx,:);
            plot(tmpFR,colors{trType});
            for kk = 1:hasField(cellIdx,trType)
                fieldInds = Tuning.placeFields{cellIdx}.trialType{trType}.fieldInds;
                scatter(fieldInds,.3*trType*ones(1,length(fieldInds)),[colors{trType} '.'])
            end
        end
        title(['cell ' num2str(cellIdx)])
    end
    
    savefig(gcf,[basepath '\sanityCheckFigures\placeFields.fig'])
    saveas(gcf,[basepath '\sanityCheckFigures\placeFields.jpg'])
    
    
end
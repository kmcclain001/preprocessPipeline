function getCellTypes(varargin)

p = inputParser;

addParameter(p,'basepath',pwd,@isfolder);
addParameter(p,'plotSummary',true,@islogical);

parse(p,varargin{:});

basepath = p.Results.basepath;
plotSummary = p.Results.plotSummary;

session = bz_getSession('basepath',basepath);

load('CellClassificationParams.mat')

feature_means = mean(Data);
feature_stds = std(Data);

cell_class_file = [basepath filesep session.general.name '.CellClass.cellinfo.mat'];

fSpikes = checkFile('basepath',pwd,'fileType','.spikes.cellinfo.mat');
load([fSpikes.folder filesep fSpikes.name])

CellClass = classify_cell_types(spikes,centroids,feature_means,feature_stds,false);
CellClass.region = spikes.region;
save(cell_class_file,'CellClass')

if plotSummary
    cellID = CellClass.PyrInt;
    
    figure;
    subplot(2,2,1);hold on
    histogram(cellID,[-1.5,-.5,.5,1.5])
    title('number of each type')
    
    subplot(2,2,2);hold on
    waveforms = getCellStructValue(CellClass.params,'waveform');
    plot(waveforms(cellID==1,:)','r');
    plot(waveforms(cellID==-1,:)','b');
    title('waveforms')
    
    subplot(2,2,3);hold on
    acgs = getCellStructValue(CellClass.params,'ACG');
    plot(acgs(cellID==1,:)','r');
    plot(acgs(cellID==-1,:)','b');
    title('ACGS')
    
    subplot(2,2,4);hold on
    frs =getCellStructValue(CellClass.params,'Rate');
    cdfplot(frs(cellID==-1));
    cdfplot(frs(cellID==1));
    title('firing rate distributions')
    legend('int','pyr')
    
    savefig(gcf,[basepath '\sanityCheckFigures\cellClass.fig'])
    saveas(gcf,[basepath '\sanityCheckFigures\cellClass.jpg'])
end

    
end
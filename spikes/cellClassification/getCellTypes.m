function getCellTypes(varargin)

p = inputParser;

addParameter(p,'basepath',pwd,@isfolder);

parse(p,varargin{:});

basepath = p.Results.basepath;

session = bz_getSession('basepath',basepath);

load('C:\Users\kmcla\Dropbox\apAxis\apDataProcessing\CellClassificationParams.mat')

feature_means = mean(Data);
feature_stds = std(Data);

cell_class_file = [basepath filesep session.general.name '.CellClass.cellinfo.mat'];

fSpikes = checkFile('basepath',pwd,'fileType','.spikes.cellinfo.mat');
load([fSpikes.folder filesep fSpikes.name])

CellClass = classify_cell_types(spikes,centroids,feature_means,feature_stds,false);
CellClass.region = spikes.region;
save(cell_class_file,'CellClass')

end
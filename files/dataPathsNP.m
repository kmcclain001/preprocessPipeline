function fileInfo = dataPathsNP(basepath)

d = dir(basepath);
dataFoldersInds = horzcat(d.isdir) & cellfun(@(s) length(s),{d.name})>2;
dataFolders = d(dataFoldersInds);

nFolders = length(dataFolders);

fileInfo.nFolders = nFolders;
fileInfo.basepath = basepath;
[~,basename] = fileparts(basepath);
fileInfo.basename = basename;


folder = cell(1,nFolders);
for fIdx = 1:nFolders
    
    folder{fIdx} = [dataFolders(fIdx).folder,filesep,dataFolders(fIdx).name];
    t = strsplit(dataFolders(fIdx).name,{'-','_'});
    fileInfo.recordingTime(fIdx) = str2num(horzcat(t{:}));
    
end

%just make sure files are in correct temporal order
[~,i] = sort(fileInfo.recordingTime);
fileInfo.folder = folder(i);
fileInfo.recordingTime = fileInfo.recordingTime(i);

fileInfo.spikePath = '\experiment1\recording1\continuous\Neuropix-PXI-100.0\';
fileInfo.lfpPath = '\experiment1\recording1\continuous\Neuropix-PXI-100.1\';
fileInfo.ttlPath = '\experiment1\recording1\events\Neuropil-PXI-100.0\TTL_1\';

end
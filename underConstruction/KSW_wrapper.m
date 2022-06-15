function savepath = KSW_wrapper(varargin)

p = inputParser;
addParameter(p,'basepath',pwd,@ischar)
addParameter(p,'config','',@ischar)    
addParameter(p,'splitSorting',false,@islogical)
addParameter(p,'autoCluster',false,@islogical)

parse(p,varargin{:})

basepath = p.Results.basepath;
config = p.Results.config;
splitSorting = p.Results.splitSorting;
autoCluster = p.Results.autoCluster;

chInfo = hackInfo('basepath',basepath);

basename = chInfo.recordingName;

if ~splitSorting
    savepath = KiloSortWrapper('basepath',basepath,'basename',basename,'config',config);
    
    if autoCluster
        PhyAutoClustering_km(savepath);
    end
        
else
    
    chanFile = checkFile('basepath',basepath,'filename','chanMap.mat');
    load([chanFile.folder filesep chanFile.name]);
    connected_OG = connected;
    folderNames = cell(chInfo.nShank,1);
    
    for shIdx = 1:chInfo.nShank
        
        disp(['Starting Shank ' num2str(shIdx)])
        shChans = chInfo.one.AnatGrps{shIdx};
        shChans = shChans(~ismember(shChans,chInfo.one.badChannels));
        
        connected(:) = 0;
        connected(shChans) = 1;
        
        save([basepath,filesep,'chanMap.mat'],...
            'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');
        
        savepath = KiloSortWrapper('basepath',basepath,'basename',basename,'config',config);
        
        if autoCluster
            PhyAutoClustering_km(savepath);
        end
        
        folderNames{shIdx} = savepath;
        
    end
    connected = connected_OG;
    save([basepath,filesep,'chanMap.mat'],...
            'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');
        
    folderFile = ['KSxShankFolders_',datestr(clock,'yyyy-mm-dd_HHMMSS')];
    
    save([basepath filesep folderFile],'folderNames')
   
    savepath = [basepath filesep folderFile];
end
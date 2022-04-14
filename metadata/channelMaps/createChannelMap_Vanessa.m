function createChannelMap_Vanessa(basepath)

chInfo = hackInfo('basepath',basepath);

chanMap = chInfo.one.channels;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;
xcoords = zeros(1,chInfo.nChannel);
ycoords = zeros(1,chInfo.nChannel);
kcoords = zeros(1,chInfo.nChannel);

xCenter = 100;

for shIdx = 1:2
    
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;
    
    y = -10;
    for chIdx = 1:2:length(channels)
        Rchan = channels(chIdx);
        Lchan = channels(chIdx+1);
        
        xcoords(Lchan) = xCenter;
        xcoords(Rchan) = xCenter+22.5;
        
        ycoords(Rchan) = y;
        ycoords(Lchan) = y-12.5;
        
        y = y-25;
    end
    
    xCenter = xCenter + 500;
    
end

xCenter = 100+1000;
for shIdx = 3:6
    
    channels = chInfo.one.AnatGrps{shIdx};
    
    kcoords(channels) = shIdx;
    xcoords(channels) = xCenter;
    
    y = -10;
    for chIdx = 1:length(channels)
        ycoords(channels(chIdx)) = y;
        y = y-25;
    end
    
    xCenter = xCenter+150;
    
end

chanMap0ind = chanMap-1;

save([basepath,filesep,'chanMap.mat'],...
    'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');
end
    
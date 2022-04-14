function createChannelMap_DVA(basepath)

chInfo = hackInfo('basepath',basepath);

chanMap = chInfo.one.channels;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;
xcoords = zeros(1,chInfo.nChannel);
ycoords = zeros(1,chInfo.nChannel);
kcoords = zeros(1,chInfo.nChannel);

xCenter = 150;
for shIdx = 1:8
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;
    xcoords(channels) = xCenter;
    
    y = -50;
    for chIdx = 1:length(channels)
        ycoords(channels(chIdx)) = y;
        y = y-50;
    end
    
    xCenter = xCenter+150;
end

xCenter = 150+2000;
for shIdx = 9:12
    
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;
    xcoords(channels) = xCenter;
    
    y = -25;
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
function createChannelMap_km(basepath)
%K% edited 3/11/21

chInfo = hackInfo('basepath',basepath);

chanMap = chInfo.one.channels;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;
xcoords = zeros(1,chInfo.nChannel);
ycoords = zeros(1,chInfo.nChannel);
kcoords = zeros(1,chInfo.nChannel);

x = 860;
for shIdx = 1:chInfo.nShank
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;
    xcoords(channels) = x;
    y = 0-25;
    for chIdx = 1:length(channels)
        ycoords(channels(chIdx)) = y;
        y = y - 25;
    end
    
   x = x+860;
   
end

chanMap0ind = chanMap-1;

save([basepath,filesep,'chanMap.mat'],...
    'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');

end
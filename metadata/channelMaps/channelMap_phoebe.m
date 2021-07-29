function createChannelMap_phoebe(basepath)

chInfo = hackInfo('basepath',basepath);

chanMap = chInfo.one.channels;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;
xcoords = zeros(1,chInfo.nChannel);
ycoords = zeros(1,chInfo.nChannel);
kcoords = zeros(1,chInfo.nChannel);

x = 200;
for shIdx = 1:chInfo.nShank
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;

    y = -165;
    for chIdx = 1:length(channels)
        tmpCh = channels(end-(chIdx-1));
        if mod(chIdx,2)==1
            xcoords(tmpCh) = x-8.25;
        else
            xcoords(tmpCh) = x+8.25;
        end
        ycoords(channels(chIdx)) = y;
        y = y + 15;
    end
    
   x = x+200;
   
end

chanMap0ind = chanMap-1;

save([basepath,filesep,'chanMap.mat'],...
    'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');

end


function createChannelMap_DVB(basepath)

chInfo = hackInfo('basepath',basepath);

chanMap = chInfo.one.channels;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;
xcoords = zeros(1,chInfo.nChannel);
ycoords = zeros(1,chInfo.nChannel);
kcoords = zeros(1,chInfo.nChannel);

xCenter = 150;
for shIdx = 1:4
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;
    
    %high channel
    xcoords(channels(1)) = xCenter;
    ycoords(channels(1)) = 1200-(200*(shIdx-1));
    
    %lowest channel
    xcoords(channels(end)) = xCenter;
    ycoords(channels(end)) = -330;
    
    %rest of channels
    y = -15;
    for chIdx = 2:3:(length(channels)-1)
        Lchan = channels(chIdx);
        Rchan = channels(chIdx+1);
        Cchan = channels(chIdx+2);
        
        xcoords(Lchan) = xCenter-18.5;
        xcoords(Rchan) = xCenter+18.5;
        xcoords(Cchan) = xCenter;
        
        ycoords(Lchan) = y;
        ycoords(Rchan) = y;
        ycoords(Cchan) = y-15;
        
        y = y-30;
    end
    
    xCenter = xCenter+150;
end

xCenter = 200+1000;
xDifFromPrev = [37 -33 29 -25 21 -17 8.5];

for shIdx = 5:12
    channels = chInfo.one.AnatGrps{shIdx};
    kcoords(channels) = shIdx;
    
    y = -20;
    x = xCenter;
    for chIdx = 1:8
        
        chan = channels(chIdx);
        
        xcoords(chan) = x;
        ycoords(chan) = y;
        
        if chIdx ~= 8
            x = x + xDifFromPrev(chIdx);
            y = y-20;
        end
        
    end
    
    xCenter = xCenter + 200;
end


chanMap0ind = chanMap-1;

save([basepath,filesep,'chanMap.mat'],...
    'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');

end
function createChannelMapFile_NP(basepath)

chInfo = hackInfo('basepath',basepath);

session = bz_getSession('basepath',basepath);

if isfield(session.extracellular,'OGchannels')
    nChanTotal = length(session.extracellular.OGchannels);
    keepChans = session.extracellular.OGchannels>0;
else
    nChanTotal = chInfo.nChannel;
    keepChans = true(1,chInfo.nChannel);
end

chanMap = chInfo.one.channels;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;
kcoords = ones(chInfo.nChannel,1);

xKern = [20 60 0 40];
xcoords = repmat(xKern,1,round(nChanTotal/length(xKern)));
yKern = flip(-20*(1:round(nChanTotal/2)));
ycoords = repelem(yKern,2);

xcoords = xcoords(keepChans);
ycoords = ycoords(keepChans);

chanMap0ind = chanMap-1;

save([basepath,filesep,'chanMap.mat'],...
    'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');

end
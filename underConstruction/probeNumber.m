%
%% Convert imro file to channel map

function probeNumber = createChannelMap_NP2_GLX(basepath)

fImro = checkFile('fileType','imro');

imroFile = [fImro.folder filesep fImro.name];

chInfo = hackInfo('basepath',basepath); 

textData = fileread(imroFile);

textData = textData(9:end); %remove (24,384) at beginning

data = textscan(textData,' %d %d %*d %*d %d', 'Delimiter',{'(',')',' ',','},'MultipleDelimsAsOne',true);

channelID = data{1}+1;
shankID = data{2}+1;
electrodeID = data{3};
evenID = mod(electrodeID,2)==0;

chanMap = channelID;
connected = ones(chInfo.nChannel,1);
connected(chInfo.one.badChannels) = 0;

xcoords = zeros(1,chInfo.nChannel);
ycoords = zeros(1,chInfo.nChannel);
kcoords = zeros(1,chInfo.nChannel);
probeNumber = ones(1,chInfo.nChannel);

kcords(channelID) = shankID;

xcoords(channelID(evenID)) = 250*(shankID(evenID));
xcoords(channelID(~evenID)) = 250*(shankID(~evenID))+32;

ycoords(channelID(evenID)) = 15*electrodeID(evenID)/2;
ycoords(channelID(~evenID)) = 15*(electrodeID(~evenID)-1)/2;

%temporary fix for extra channel
xcoords = xcoords(1:end-1);
ycoords = ycoords(1:end-1);
kcoords = kcoords(1:end-1);
probeNumber = probeNumber(1:end-1);
chanMap = chanMap(1:end-1);

chanMap0ind = chanMap-1;

save([basepath,filesep,'chanMap.mat'],...
    'chanMap','connected','xcoords','ycoords','kcoords','chanMap0ind');

end
function session = removeChannelSess(session,ch)

session.extracellular.nChannels = session.extracellular.nChannels-1;

for i=1:length(session.extracellular.electrodeGroups.channels)
    d = find(session.extracellular.electrodeGroups.channels{i}==ch);
    session.extracellular.electrodeGroups.channels{i}(d) = [];
    
    if isempty(session.extracellular.electrodeGroups.channels{i})
        session.extracellular.electrodeGroups.channels(i) = [];
    end
end

session.extracellular.spikeGroups = session.extracellular.electrodeGroups;

session.extracellular.nElectrodeGroups = length(session.extracellular.electrodeGroups.channels);
session.extracellular.nSpikeGroups = session.extracellular.nElectrodeGroups;

tags = fieldnames(session.channelTags);
for i=1:length(tags)
    session.channelTags.(tags{i}).channels(session.channelTags.(tags{i}).channels==ch) = [];
end

regs = fieldnames(session.brainRegions);
for i=1:length(tags)
    session.brainRegions.(regs{i}).channels(session.brainRegions.(regs{i}).channels==ch) = [];
end

end
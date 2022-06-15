function datFileMeanSubtraction(varargin)
% Remove mean/median across channels
%
% USAGE
%   datFileMeanSubtraction(basepath,ints,varargin)
% 
% INPUT
% basepath      If not provided, takes pwd
% ch            Affected channels.
% method        'subtractMedian' or 'subtratMean' (defaut)
% separateProbes compute mean/median separately for each probe
% probeNumber   probe designation for each channel
% keepDat       Default, false.
%
% <optional>
% option        'remove' or 'zeroes' (default). 
%
% Manu Valero-BuzsakiLab 2021
% km 2022
%% Defaults and Parms
p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'method','subtractMean',@ischar);
addParameter(p,'keepDat',false,@islogical);
addParameter(p,'separateProbes',true,@islogical);
addParameter(p,'probeNumber',[],@isnumeric);

parse(p,varargin{:});
basepath = p.Results.basepath;
method = p.Results.method;
keepDat = p.Results.keepDat;
separateProbes = p.Results.separateProbes;
probeNumber = p.Results.probeNumber;

chInfo = hackInfo('basepath',basepath);
goodChannels = setdiff(chInfo.one.channels,chInfo.one.badChannels);
sf = chInfo.lfpSR;
old_dat_path = [basepath,filesep,chInfo.recordingName,'.dat'];
new_dat_path = [basepath,filesep,chInfo.recordingName,'_new.dat'];
nChannels = chInfo.nChannel;

if isempty(probeNumber) || ~separateProbes
    probeNumber = ones(1,nChannels);
end

chunkDuration = 60; %seconds
fidOld = fopen(old_dat_path,'r');
fidNew = fopen(new_dat_path,'a');

% Split channels according to probe
probeList = unique(probeNumber);
probeChannels = cell(length(probeList),1);

for pIdx = 1:length(probeList)
    channelSet = find(probeNumber==probeList(pIdx));
    probeChannels{pIdx} = intersect(channelSet,goodChannels);
end
    
while 1
    data = fread(fidOld,[nChannels sf*chunkDuration],'int16');
    if isempty(data)
        break;
    end
    
    % compute mean/median for each probe (or all channels if not
    % separateProbes)
    for pIdx = 1:length(probeList)
        
        if strcmpi('subtractMedian',method)
            m_data = median(data(probeChannels{pIdx},:));
        elseif strcmpi('subtractMean',method)
            m_data = mean(data(probeChannels{pIdx},:));
        end

        data(probeChannels{pIdx},:) = int16(data(probeChannels{pIdx},:)-m_data);
    end
    
    fwrite(fidNew,data,'int16');
    
end
fclose(fidOld);
fclose(fidNew);

% if ~keepDat
%     copyfile(filename, [C{1} '_original.dat']);
% end
% 
new_old_dat = [basepath,filesep,chInfo.recordingName,'_orig.dat'];
movefile(old_dat_path,new_old_dat);
movefile(new_dat_path,old_dat_path);
% delete(filename);
% movefile(filenameOut, filename);

end
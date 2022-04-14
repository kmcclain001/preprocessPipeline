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

parse(p,varargin{:});
basepath = p.Results.basepath;
method = p.Results.method;
keepDat = p.Results.keepDat;

chInfo = hackInfo('basepath',basepath);
channels = setdiff(chInfo.one.channels,chInfo.one.badChannels);
sf = chInfo.lfpSR;
old_dat_path = [basepath,filesep,chInfo.recordingName,'.dat'];
new_dat_path = [basepath,filesep,chInfo.recordingName,'_new.dat'];
nChannels = chInfo.nChannel;

chunkDuration = 60; %seconds
fidOld = fopen(old_dat_path,'r');
fidNew = fopen(new_dat_path,'a');

while 1
    data = fread(fidOld,[nChannels sf*chunkDuration],'int16');
    if isempty(data)
        break;
    end
    
    if strcmpi('subtractMedian',method)
        m_data = median(data(channels,:));
    elseif strcmpi('subtractMean',method)
        m_data = mean(data(channels,:));
    end

    data(channels,:) = int16(data(channels,:)-m_data);
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
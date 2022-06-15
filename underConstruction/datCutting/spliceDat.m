function spliceDat(filepath, SR, nChannel, varargin)

p = inputParser;
addParameter(p,'startTime',0,@isnumeric)
addParameter(p,'endTime','end',@isnumeric)
addParameter(p,'zeroFill',true,@islogical)

parse(p,varargin{:})
startTime = p.Results.startTime;
endTime = p.Results.endTime;
zeroFill = p.Results.zeroFill;

fileInfo = dir(filepath);
numSamples = fileinfo.bytes/(nChannel*2);

timeline = (1:numSamples)/SR;
startInd = find(timeline>startTime,1);

if ischar(endTime) && strcmp('endTime','end')
    endInd = numSamples;
else
    endInd = find(timeline>=endTime,1);
end

tempFilePath = [filepath, '_tmp'];

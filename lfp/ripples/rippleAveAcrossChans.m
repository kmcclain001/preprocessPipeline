function rippliness = rippleAveAcrossChans(lfpData, varargin)

p = inputParser;
addParameter(p,'rippleBand',[110,250],@isnumeric)
addParameter(p,'sr',1250,@isnumeric)

parse(p,varargin{:});
rippleBand = p.Results.rippleBand;
sr = p.Results.sr;

meanLfp = mean(lfpData,2);
meanLfp = double(meanLfp);

[b,a] = butter(4,[rippleBand(1)/(sr/2) rippleBand(2)/(sr/2)],'bandpass');

ripFilt = FilterM(b,a,meanLfp);

ripPow = fastrms(ripFilt);

rippliness = normalize(ripPow,'zscore','robust');

end
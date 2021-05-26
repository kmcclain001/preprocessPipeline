function out = convNoPad(x,filt,varargin)
p = inputParser;
addParameter(p,'padMeanRatio',1/10,@isnumeric);
parse(p,varargin{:});
padMeanRatio = p.Results.padMeanRatio;

padWin = round(length(x)*padMeanRatio);
x = reshape(x,[length(x),1]);
startVal = nanmean(x(1:padWin));
endVal = nanmean(x((end-padWin):end));

xTra = [startVal*ones(length(filt),1); x; endVal*ones(length(filt),1)];

if sum(isnan(xTra))
    xTra = fillmissing(xTra,'linear');
end

c = conv(xTra,filt,'same');
out = c((length(filt)+1):(end-length(filt)));

end
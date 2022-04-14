function x_onehot = binVariable(x,nBins,rangeX)
% x = vector of positions 
%
% USE FOR SPIKES
%   spkBins = binVariable(spkTimes,length(t),[t(1) t(end)]);
%   spkCounts = sum(spkBins,2);

xScale = (x-rangeX(1))*nBins/diff(rangeX);

x_onehot = full(ind2vec(ceil(xScale'),nBins));

end

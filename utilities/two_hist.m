function two_hist(l1,l2,varargin)

p = inputParser;
addParameter(p,'nBins',[],@isnumeric)
parse(p,varargin{:});
nBins = p.Results.nBins;

l1 = reshape(l1,1,length(l1));
l2 = reshape(l2,1,length(l2));
[~,b] = histcounts([l1,l2],nBins);
% leftlim = min([l1 l2]);
% rightlim = max([l1 l2]);
% n = round(mean([length(l1) length(l2)])/10);
% b = linspace(leftlim,rightlim,n);

figure();hold on
histogram(l1,b,'Normalization','Probability');
histogram(l2,b,'Normalization','Probability');

end
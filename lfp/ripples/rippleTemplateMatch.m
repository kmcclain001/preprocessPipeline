function [rippliness, template] = rippleTemplateMatch(lfpData, bestChannel, varargin)

p = inputParser;
addParameter(p,'rippleBand',[110,250],@isnumeric)
addParameter(p,'sr',1250,@isnumeric)
addParameter(p,'similarity','dotProd',@isstr)


parse(p,varargin{:});
rippleBand = p.Results.rippleBand;
sr = p.Results.sr;
similarity = p.Results.similarity;

nChan = size(lfpData,2);

[b,a] = butter(4,[rippleBand(1)/(sr/2) rippleBand(2)/(sr/2)],'bandpass');

% find likely ripple times
protoRip = rippleFromOneChan(lfpData(:,bestChannel),'rippleBand',rippleBand,'sr',sr);
ripInds = find(protoRip>4&protoRip<9);

% filter all channels in ripple band
lfpData = double(lfpData);
ripplePow = zeros(size(lfpData));
for chIdx = 1:nChan
    tmpRipSig = FilterM(b,a,lfpData(:,chIdx));
    tmpRipPow = fastrms(tmpRipSig);
    ripplePow(:,chIdx) = tmpRipPow;
end

% normalize power across channels, time
ripPowMeanSub = ripplePow-median(ripplePow,1);
%powerScale = sum(ripPowMeanSub.^2,2).^.5;
%powerScale = vecnorm(ripPowMeanSub,4,2);
pNorm = vecnorm(ripPowMeanSub,2,2);
powerScale = ((pNorm./mean(pNorm)).^0)./(pNorm);
ripPowNorm = ripPowMeanSub.*powerScale;

% calculate template
template = mean(ripPowNorm(ripInds,:),1)';
nClust =5;
[kid,templates] = kmeans(ripPowNorm(ripInds,:),nClust);
ratios = histcounts(kid,.5:1:(nClust+.5),'Normalization','probability');
templatesTrim = templates(ratios>.1,:);

tempMatches = zeros(size(ripPowNorm,1),size(templatesTrim,1));
for i = 1:size(templatesTrim,1)
    tempMatches(:,i) = corr(ripPowNorm',templatesTrim(i,:)');
end

kern = ones(25,1);
kern = kern/sum(kern);
%tempMatchRect = conv2(tempMatches.^3,kern,'same');
tempMatchRect = tempMatches;
tempMatchRect(tempMatchRect<0) = 0;
innerProd = fuzzyOR(tempMatchRect);

%innerProd = prod(tempMatches,2);

% match template with normalized power
% switch similarity
%     case 'dotProd'
%         innerProd = ripPowNorm*template;
%     case 'corr'
%         innerProd = corr(ripPowNorm',template);
%     otherwise
%         error('unrecognized similarity')
% end


%tLim = [9.2166e+04 1.0127e+05];
rippliness = innerProd;
% kern = ones(25,1);
% kern = kern/sum(kern);
% rippliness = exp(exp(conv(innerProd,kern,'same'))-1)-1;


%rippliness = normalize(innerProd,'zscore','robust');
% ripplinessRaw = innerProd;%normalize(exp(innerProd),'zscore','robust');
% [c,d] = butter(4, 30/(sr/2),'low');
% rippliness = FilterM(c,d,ripplinessRaw);

end




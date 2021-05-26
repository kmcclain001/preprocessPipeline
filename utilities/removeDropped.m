function out = removeDropped(data,dropInds)

s = size(data);
if length(s)>2
    error('too many dimensions in data')
end
if min(s) >1
    error('should be column vector')
end

data(dropInds) = interp1(find(~dropInds),data(~dropInds),find(dropInds),'pchip');

out = data;
end